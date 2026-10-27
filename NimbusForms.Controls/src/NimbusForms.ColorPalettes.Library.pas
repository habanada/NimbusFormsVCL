{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.ColorPalettes.Library;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections, Vcl.Graphics;

type
  TNimbusColorPalette = class
  private
    FId: string;
    FName: string;
    FOrigin: string;
    FColors: TArray<TColor>;
  public
    property Id: string read FId;
    property Name: string read FName;
    property Origin: string read FOrigin;
    property Colors: TArray<TColor> read FColors;
    function ColorCount: Integer;
    function ColorAt(AIndex: Integer): TColor;
  end;

  TNimbusColorPaletteCategory = class
  private
    FId: string;
    FName: string;
    FPalettes: TObjectList<TNimbusColorPalette>;
  public
    constructor Create;
    destructor Destroy; override;
    function PaletteCount: Integer;
    function PaletteAt(AIndex: Integer): TNimbusColorPalette;
    property Id: string read FId;
    property Name: string read FName;
  end;

  TNimbusColorPaletteLibrary = class(TComponent)
  private
    FCategories: TObjectList<TNimbusColorPaletteCategory>;
    FFileName: string;
    FOnChange: TNotifyEvent;
    function GetCategoryCount: Integer;
    procedure SetFileName(const AValue: string);
    procedure Changed;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear;
    procedure LoadFromFile(const AFileName: string);
    procedure LoadFromJson(const AJson: string);
    function CategoryAt(AIndex: Integer): TNimbusColorPaletteCategory;
    function FindCategory(const AId: string): Integer;
    function FindPalette(ACategoryIndex: Integer; const AId: string): Integer;
    property CategoryCount: Integer read GetCategoryCount;
  published
    property FileName: string read FFileName write SetFileName;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

implementation

uses
  System.JSON, System.IOUtils, Winapi.Windows;

function JsonString(AObject: TJSONObject; const AKey: string): string;
var V: TJSONValue;
begin
  Result := '';
  if AObject = nil then Exit;
  V := AObject.GetValue(AKey);
  if V <> nil then Result := V.Value;
end;

function ParseHtmlColor(const S: string; out AColor: TColor): Boolean;
var V: Integer; H: string;
begin
  H := Trim(S);
  if (Length(H) <> 7) or (H[1] <> '#') then Exit(False);
  Result := TryStrToInt('$' + Copy(H, 2, 6), V);
  if Result then AColor := RGB((V shr 16) and $FF, (V shr 8) and $FF, V and $FF);
end;

function TNimbusColorPalette.ColorCount: Integer;
begin
  Result := Length(FColors);
end;

function TNimbusColorPalette.ColorAt(AIndex: Integer): TColor;
begin
  if (AIndex < 0) or (AIndex >= Length(FColors)) then
    raise EArgumentOutOfRangeException.Create('Palette color index out of range');
  Result := FColors[AIndex];
end;

constructor TNimbusColorPaletteCategory.Create;
begin
  inherited Create;
  FPalettes := TObjectList<TNimbusColorPalette>.Create(True);
end;

destructor TNimbusColorPaletteCategory.Destroy;
begin
  FPalettes.Free;
  inherited Destroy;
end;

function TNimbusColorPaletteCategory.PaletteCount: Integer;
begin
  Result := FPalettes.Count;
end;

function TNimbusColorPaletteCategory.PaletteAt(AIndex: Integer): TNimbusColorPalette;
begin
  Result := FPalettes[AIndex];
end;

constructor TNimbusColorPaletteLibrary.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCategories := TObjectList<TNimbusColorPaletteCategory>.Create(True);
end;

destructor TNimbusColorPaletteLibrary.Destroy;
begin
  FCategories.Free;
  inherited Destroy;
end;

function TNimbusColorPaletteLibrary.GetCategoryCount: Integer;
begin
  Result := FCategories.Count;
end;

function TNimbusColorPaletteLibrary.CategoryAt(AIndex: Integer): TNimbusColorPaletteCategory;
begin
  Result := FCategories[AIndex];
end;

function TNimbusColorPaletteLibrary.FindCategory(const AId: string): Integer;
var I: Integer;
begin
  Result := -1;
  for I := 0 to FCategories.Count - 1 do
    if SameText(FCategories[I].Id, AId) then Exit(I);
end;

function TNimbusColorPaletteLibrary.FindPalette(ACategoryIndex: Integer; const AId: string): Integer;
var C: TNimbusColorPaletteCategory; I: Integer;
begin
  Result := -1;
  if (ACategoryIndex < 0) or (ACategoryIndex >= FCategories.Count) then Exit;
  C := FCategories[ACategoryIndex];
  for I := 0 to C.PaletteCount - 1 do
    if SameText(C.PaletteAt(I).Id, AId) then Exit(I);
end;

procedure TNimbusColorPaletteLibrary.Changed;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusColorPaletteLibrary.Clear;
begin
  FCategories.Clear;
  Changed;
end;

procedure TNimbusColorPaletteLibrary.SetFileName(const AValue: string);
begin
  if FFileName = AValue then Exit;
  if (AValue <> '') and not (csDesigning in ComponentState) then
    LoadFromFile(AValue);
  FFileName := AValue;
end;

procedure TNimbusColorPaletteLibrary.LoadFromFile(const AFileName: string);
begin
  LoadFromJson(TFile.ReadAllText(AFileName, TEncoding.UTF8));
  FFileName := AFileName;
end;

procedure TNimbusColorPaletteLibrary.LoadFromJson(const AJson: string);
var
  Root, CV, PV: TJSONValue;
  Obj, CatObj, PalObj: TJSONObject;
  CatArray, PalArray, ColorArray: TJSONArray;
  NewCategories: TObjectList<TNimbusColorPaletteCategory>;
  Category: TNimbusColorPaletteCategory;
  Palette: TNimbusColorPalette;
  I, J, K, Count: Integer;
  C: TColor;
begin
  Root := TJSONObject.ParseJSONValue(AJson);
  if Root = nil then raise EConvertError.Create('Invalid palette JSON');
  NewCategories := TObjectList<TNimbusColorPaletteCategory>.Create(True);
  try
    if not (Root is TJSONObject) then raise EConvertError.Create('Palette root must be an object');
    Obj := TJSONObject(Root);
    CV := Obj.GetValue('categories');
    if not (CV is TJSONArray) then raise EConvertError.Create('Missing categories array');
    CatArray := TJSONArray(CV);
    for I := 0 to CatArray.Count - 1 do
    begin
      if not (CatArray.Items[I] is TJSONObject) then Continue;
      CatObj := TJSONObject(CatArray.Items[I]);
      Category := TNimbusColorPaletteCategory.Create;
      NewCategories.Add(Category);
      Category.FId := JsonString(CatObj, 'id');
      Category.FName := JsonString(CatObj, 'name');
      PV := CatObj.GetValue('palettes');
      if not (PV is TJSONArray) then Continue;
      PalArray := TJSONArray(PV);
      for J := 0 to PalArray.Count - 1 do
      begin
        if not (PalArray.Items[J] is TJSONObject) then Continue;
        PalObj := TJSONObject(PalArray.Items[J]);
        PV := PalObj.GetValue('colors');
        if not (PV is TJSONArray) then Continue;
        ColorArray := TJSONArray(PV);
        Palette := TNimbusColorPalette.Create;
        Category.FPalettes.Add(Palette);
        Palette.FId := JsonString(PalObj, 'id');
        Palette.FName := JsonString(PalObj, 'name');
        Palette.FOrigin := JsonString(PalObj, 'origin');
        SetLength(Palette.FColors, ColorArray.Count);
        Count := 0;
        for K := 0 to ColorArray.Count - 1 do
          if ParseHtmlColor(ColorArray.Items[K].Value, C) then
          begin
            Palette.FColors[Count] := C;
            Inc(Count);
          end;
        SetLength(Palette.FColors, Count);
      end;
    end;
    FCategories.Free;
    FCategories := NewCategories;
    NewCategories := nil;
    Changed;
  finally
    NewCategories.Free;
    Root.Free;
  end;
end;

end.

{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.PropertyGrid.Types;

interface

uses
  System.Classes,
  System.SysUtils,
  System.TypInfo,
  System.Variants,
  System.DateUtils,
  System.Generics.Collections,
  System.UITypes,
  Vcl.Graphics,
  NimbusForms.Controls.PropertyGrid.Adapters;

type
  TThemedPropertyGridSortMode = (pgsCategory, pgsAlphabetical);
  TThemedPropertyGridDescriptionMode = (pgdHidden, pgdBottom);
  TThemedPropertyGridIndexedKind = (pgikNone, pgikString, pgikCollection, pgikVariant, pgikListText, pgikListInteger, pgikListInt64, pgikListFloat, pgikListBoolean, pgikAdapter);
  TThemedPropertyGridEditorKind = (pgeAuto, pgeText, pgeNumeric, pgeBoolean, pgeColor, pgeDateTime, pgeFile, pgeFolder, pgeImage, pgeIcon);
  TThemedPropertyGridGetVirtualEvent = procedure(Sender: TObject; var AValue: Variant) of object;
  TThemedPropertyGridSetVirtualEvent = procedure(Sender: TObject; const AValue: Variant) of object;
  TThemedPropertyGridMetadataEvent = procedure(Sender: TObject; const APath: string; var ADisplayName, ACategory, ADescription: string; var AVisible: Boolean) of object;
  TThemedPropertyGridValidateEvent = procedure(Sender: TObject; const APath: string; const AValue: Variant; var AError: string) of object;

  TThemedPropertyGridItem = class;

  TThemedPropertyGridMetadata = class
  private
    FDisplayName, FCategory, FDescription: string;
    FHasDisplayName, FHasCategory, FHasDescription: Boolean;
    FBrowsable, FReadOnly: Boolean;
    FHasBrowsable, FHasReadOnly: Boolean;
    FDefaultValue: Variant;
    FHasDefaultValue: Boolean;
    FHasMinimum, FHasMaximum: Boolean;
    FMinimum, FMaximum, FIncrement: Extended;
    FDecimalPlaces: Integer;
    FEditorKind: TThemedPropertyGridEditorKind;
    FPathFilter: string;
    FPathCheckExists: Boolean;
    procedure SetDisplayName(const AValue: string);
    procedure SetCategory(const AValue: string);
    procedure SetDescription(const AValue: string);
    procedure SetBrowsable(const AValue: Boolean);
    procedure SetReadOnly(const AValue: Boolean);
    procedure SetDefaultValue(const AValue: Variant);
    procedure SetMinimum(const AValue: Extended);
    procedure SetMaximum(const AValue: Extended);
  public
    constructor Create;
    procedure ApplyTo(AItem: TThemedPropertyGridItem);
    property DisplayName: string read FDisplayName write SetDisplayName;
    property Category: string read FCategory write SetCategory;
    property Description: string read FDescription write SetDescription;
    property Browsable: Boolean read FBrowsable write SetBrowsable;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly;
    property DefaultValue: Variant read FDefaultValue write SetDefaultValue;
    property Minimum: Extended read FMinimum write SetMinimum;
    property Maximum: Extended read FMaximum write SetMaximum;
    property Increment: Extended read FIncrement write FIncrement;
    property DecimalPlaces: Integer read FDecimalPlaces write FDecimalPlaces;
    property EditorKind: TThemedPropertyGridEditorKind read FEditorKind write FEditorKind;
    property PathFilter: string read FPathFilter write FPathFilter;
    property PathCheckExists: Boolean read FPathCheckExists write FPathCheckExists;
    property HasBrowsable: Boolean read FHasBrowsable;
    property HasMinimum: Boolean read FHasMinimum;
    property HasMaximum: Boolean read FHasMaximum;
  end;

  TThemedPropertyGridVirtualProperty = class
  public
    Name: string;
    DisplayName: string;
    Category: string;
    Description: string;
    DefaultValue: Variant;
    HasDefaultValue: Boolean;
    IsReadOnly: Boolean;
    IsBrowsable: Boolean;
    OnGetValue: TThemedPropertyGridGetVirtualEvent;
    OnSetValue: TThemedPropertyGridSetVirtualEvent;
    constructor Create(const AName: string; AGetter: TThemedPropertyGridGetVirtualEvent; ASetter: TThemedPropertyGridSetVirtualEvent);
  end;

  TThemedPropertyGridItem = class
  private
    FTargets: TArray<TPersistent>;
    FParts: TArray<string>;
    FVirtual: TThemedPropertyGridVirtualProperty;
    FPropInfo: PPropInfo;
    FIndexedKind: TThemedPropertyGridIndexedKind;
    FIndexedPosition: Integer;
    FOriginal: TArray<Variant>;
    function IndexedPropertyInfo(AOwner: TObject): PPropInfo;
    function ResolveIndexedSource(ATarget: TPersistent): TObject;
    function ResolveOwner(ATarget: TPersistent): TObject;
    function ResolveInfo(AOwner: TObject): PPropInfo;
    function GetKind: TTypeKind;
    function GetReadOnly: Boolean;
    function GetValueText: string;
  public
    Path: string;
    Name: string;
    DisplayName: string;
    Category: string;
    Description: string;
    IndentLevel: Integer;
    Favorite: Boolean;
    Dirty: Boolean;
    MultipleValues: Boolean;
    ExpressionMode: Boolean;
    ExpressionText: string;
    OriginalExpressionMode: Boolean;
    OriginalExpressionText: string;
    ValidationError: string;
    DefaultValue: Variant;
    HasDefaultValue: Boolean;
    MetadataReadOnly: Boolean;
    NumericMinimum, NumericMaximum, NumericIncrement: Extended;
    NumericHasMinimum, NumericHasMaximum: Boolean;
    NumericDecimalPlaces: Integer;
    EditorKind: TThemedPropertyGridEditorKind;
    PathFilter: string;
    PathCheckExists: Boolean;
    constructor Create(const ATargets: TArray<TPersistent>; const APath: string; APropInfo: PPropInfo; AVirtual: TThemedPropertyGridVirtualProperty = nil; AIndexedKind: TThemedPropertyGridIndexedKind = pgikNone);
    function ReadValues: TArray<Variant>;
    function ReadValue: Variant;
    procedure WriteValues(const AValues: TArray<Variant>);
    procedure WriteValue(const AValue: Variant);
    function PreviewGraphic: TGraphic;
    function CapturePictures: TObjectList<TPicture>;
    procedure RestorePictures(APictures: TObjectList<TPicture>);
    function CaptureCollections: TObjectList<TCollection>;
    procedure RestoreCollections(ACollections: TObjectList<TCollection>);
    procedure AcceptChanges;
    procedure UpdateState;
    property Kind: TTypeKind read GetKind;
    property IsReadOnly: Boolean read GetReadOnly;
    property ValueText: string read GetValueText;
    property VirtualProperty: TThemedPropertyGridVirtualProperty read FVirtual;
    property OriginalValues: TArray<Variant> read FOriginal write FOriginal;
    property PropInfo: PPropInfo read FPropInfo;
    property IndexedKind: TThemedPropertyGridIndexedKind read FIndexedKind;
  end;

  TThemedPropertyGridRow = class
  public
    Item: TThemedPropertyGridItem;
    Category: string;
    Expanded: Boolean;
    Expandable: Boolean;
    Top: Integer;
    Height: Integer;
    function IsCategory: Boolean;
  end;

  TThemedPropertyGridChange = class
  public
    Path: string;
    OldValues: TArray<Variant>;
    NewValues: TArray<Variant>;
    OldPictures: TObjectList<TPicture>;
    NewPictures: TObjectList<TPicture>;
    OldCollections: TObjectList<TCollection>;
    NewCollections: TObjectList<TCollection>;
    OldIndexed: TArray<Variant>;
    NewIndexed: TArray<Variant>;
    IndexedChange: Boolean;
    ObjectOrderChange: Boolean;
    OldObjectOrder, NewObjectOrder: TArray<TPersistent>;
    IndexedKind: TThemedPropertyGridIndexedKind;
    ExpressionTracked: Boolean;
    OldExpressionMode, NewExpressionMode: Boolean;
    OldExpressionText, NewExpressionText: string;
    destructor Destroy; override;
  end;

function NimbusPropertyGridCategory(const AName: string): string;
function NimbusPropertyGridCollectionFingerprint(ACollection: TCollection): string;
function NimbusPropertyGridListKind(AObject: TObject): TThemedPropertyGridIndexedKind;
function NimbusPropertyGridIndexedCount(AObject: TObject; AKind: TThemedPropertyGridIndexedKind): Integer;
function NimbusPropertyGridIndexedRead(AObject: TObject; AKind: TThemedPropertyGridIndexedKind; AIndex: Integer): Variant;
procedure NimbusPropertyGridIndexedWrite(AObject: TObject; AKind: TThemedPropertyGridIndexedKind; AIndex: Integer; const AValue: Variant);
function NimbusPropertyGridIndexedCanRestructure(AObject: TObject; AKind: TThemedPropertyGridIndexedKind): Boolean;
function NimbusPropertyGridIndexedCanReorder(AObject: TObject; AKind: TThemedPropertyGridIndexedKind): Boolean;
function NimbusPropertyGridIndexedObjectOrder(AObject: TObject; AKind: TThemedPropertyGridIndexedKind): TArray<TPersistent>;
procedure NimbusPropertyGridIndexedRestoreObjectOrder(AObject: TObject; AKind: TThemedPropertyGridIndexedKind; const AOrder: TArray<TPersistent>);
procedure NimbusPropertyGridIndexedAdd(AObject: TObject; AKind: TThemedPropertyGridIndexedKind);
procedure NimbusPropertyGridIndexedDelete(AObject: TObject; AKind: TThemedPropertyGridIndexedKind; AIndex: Integer);
procedure NimbusPropertyGridIndexedMove(AObject: TObject; AKind: TThemedPropertyGridIndexedKind; AFrom, ATo: Integer);
function NimbusPropertyGridIndexedSnapshot(AObject: TObject; AKind: TThemedPropertyGridIndexedKind): TArray<Variant>;
procedure NimbusPropertyGridIndexedRestore(AObject: TObject; AKind: TThemedPropertyGridIndexedKind; const AValues: TArray<Variant>);
function NimbusPropertyGridFontValue(const AFont: TFont): string;

implementation

uses
  System.Math,
  System.StrUtils,
  System.Hash;

function NimbusPropertyGridListKind(AObject: TObject): TThemedPropertyGridIndexedKind;
begin
  if NimbusFindPropertyGridAdapter(AObject) <> nil then Exit(pgikNone);
  if AObject is TList<string> then Exit(pgikListText);
  if AObject is TList<Integer> then Exit(pgikListInteger);
  if AObject is TList<Int64> then Exit(pgikListInt64);
  if AObject is TList<Double> then Exit(pgikListFloat);
  if AObject is TList<Boolean> then Exit(pgikListBoolean);
  Result := pgikNone;
end;

function NimbusPropertyGridIndexedCount(AObject: TObject; AKind: TThemedPropertyGridIndexedKind): Integer;
begin
  case AKind of
    pgikString: if AObject is TStrings then Exit(TStrings(AObject).Count);
    pgikCollection: if AObject is TCollection then Exit(TCollection(AObject).Count);
    pgikListText: if AObject is TList<string> then Exit(TList<string>(AObject).Count);
    pgikListInteger: if AObject is TList<Integer> then Exit(TList<Integer>(AObject).Count);
    pgikListInt64: if AObject is TList<Int64> then Exit(TList<Int64>(AObject).Count);
    pgikListFloat: if AObject is TList<Double> then Exit(TList<Double>(AObject).Count);
    pgikListBoolean: if AObject is TList<Boolean> then Exit(TList<Boolean>(AObject).Count);
    pgikAdapter: if NimbusFindPropertyGridAdapter(AObject) <> nil then Exit(NimbusFindPropertyGridAdapter(AObject).Count(AObject));
  end;
  Result := -1;
end;

function NimbusPropertyGridIndexedRead(AObject: TObject; AKind: TThemedPropertyGridIndexedKind; AIndex: Integer): Variant;
begin
  if (AIndex < 0) or (AIndex >= NimbusPropertyGridIndexedCount(AObject, AKind)) then
    raise EPropertyError.Create('Indexed property is unavailable');
  case AKind of
    pgikString: Result := TStrings(AObject)[AIndex];
    pgikCollection: Result := TCollection(AObject).Items[AIndex].DisplayName;
    pgikListText: Result := TList<string>(AObject)[AIndex];
    pgikListInteger: Result := TList<Integer>(AObject)[AIndex];
    pgikListInt64: Result := TList<Int64>(AObject)[AIndex];
    pgikListFloat: Result := TList<Double>(AObject)[AIndex];
    pgikListBoolean: Result := TList<Boolean>(AObject)[AIndex];
    pgikAdapter: Result := NimbusFindPropertyGridAdapter(AObject).ReadValue(AObject, AIndex);
  else raise EPropertyError.Create('Unsupported indexed property');
  end;
end;

procedure NimbusPropertyGridIndexedWrite(AObject: TObject; AKind: TThemedPropertyGridIndexedKind; AIndex: Integer; const AValue: Variant);
begin
  if (AIndex < 0) or (AIndex >= NimbusPropertyGridIndexedCount(AObject, AKind)) then
    raise EPropertyError.Create('Indexed property is unavailable');
  case AKind of
    pgikString: TStrings(AObject)[AIndex] := VarToStr(AValue);
    pgikListText: TList<string>(AObject)[AIndex] := VarToStr(AValue);
    pgikListInteger: TList<Integer>(AObject)[AIndex] := StrToInt(VarToStr(AValue));
    pgikListInt64: TList<Int64>(AObject)[AIndex] := StrToInt64(VarToStr(AValue));
    pgikListFloat: TList<Double>(AObject)[AIndex] := StrToFloat(VarToStr(AValue));
    pgikListBoolean: TList<Boolean>(AObject)[AIndex] := StrToBool(VarToStr(AValue));
    pgikAdapter: NimbusFindPropertyGridAdapter(AObject).WriteValue(AObject, AIndex, AValue);
  else raise EPropertyError.Create('Indexed property is read-only');
  end;
end;

function NimbusPropertyGridIndexedCanRestructure(AObject: TObject; AKind: TThemedPropertyGridIndexedKind): Boolean;
var
  I: Integer;
begin
  Result := False;
  case AKind of
    pgikString:
      begin
        Result := AObject is TStrings;
        if Result then for I := 0 to TStrings(AObject).Count - 1 do
          if TStrings(AObject).Objects[I] <> nil then Exit(False);
      end;
    pgikCollection: Result := AObject is TCollection;
    pgikListText, pgikListInteger, pgikListInt64, pgikListFloat, pgikListBoolean:
      Result := NimbusPropertyGridIndexedCount(AObject, AKind) >= 0;
    pgikAdapter:
      begin
        var LAdapter := NimbusFindPropertyGridAdapter(AObject);
        Result := False;
        if LAdapter <> nil then Result := LAdapter.CanChangeStructure and (LAdapter.Kind(AObject) <> tkClass);
      end;
  end;
end;

function NimbusPropertyGridIndexedCanReorder(AObject: TObject; AKind: TThemedPropertyGridIndexedKind): Boolean;
var
  LAdapter: TNimbusPropertyGridIndexedAdapter;
  LSeen: TDictionary<TPersistent, Boolean>;
  LItem: TPersistent;
  I: Integer;
begin
  if AKind <> pgikAdapter then Exit(NimbusPropertyGridIndexedCanRestructure(AObject, AKind));
  LAdapter := NimbusFindPropertyGridAdapter(AObject);
  Result := (LAdapter <> nil) and LAdapter.CanReorder;
  if not Result then Exit;
  if LAdapter.Kind(AObject) <> tkClass then Exit;
  LSeen := TDictionary<TPersistent, Boolean>.Create;
  try
    for I := 0 to LAdapter.Count(AObject) - 1 do
    begin
      LItem := LAdapter.ObjectAt(AObject, I);
      if (LItem = nil) or LSeen.ContainsKey(LItem) then Exit(False);
      LSeen.Add(LItem, True);
    end;
  finally
    LSeen.Free;
  end;
end;

function NimbusPropertyGridIndexedObjectOrder(AObject: TObject; AKind: TThemedPropertyGridIndexedKind): TArray<TPersistent>;
var
  LAdapter: TNimbusPropertyGridIndexedAdapter;
  LSeen: TDictionary<TPersistent, Boolean>;
  I: Integer;
begin
  if AKind <> pgikAdapter then raise EPropertyError.Create('Object order snapshot is not supported');
  LAdapter := NimbusFindPropertyGridAdapter(AObject);
  if LAdapter = nil then raise EPropertyError.Create('Object list adapter is unavailable');
  if (LAdapter.Kind(AObject) <> tkClass) or not LAdapter.CanReorder then
    raise EPropertyError.Create('Object order snapshot is not supported');
  SetLength(Result, LAdapter.Count(AObject));
  LSeen := TDictionary<TPersistent, Boolean>.Create;
  try
    for I := 0 to High(Result) do
    begin
      Result[I] := LAdapter.ObjectAt(AObject, I);
      if Result[I] = nil then raise EPropertyError.Create('Cannot reorder a list containing nil objects');
      if LSeen.ContainsKey(Result[I]) then raise EPropertyError.Create('Cannot reorder duplicate object references');
      LSeen.Add(Result[I], True);
    end;
  finally
    LSeen.Free;
  end;
end;

procedure NimbusPropertyGridIndexedRestoreObjectOrder(AObject: TObject; AKind: TThemedPropertyGridIndexedKind; const AOrder: TArray<TPersistent>);
var
  LAdapter: TNimbusPropertyGridIndexedAdapter;
  LCurrent: TArray<TPersistent>;
  LMatched: TArray<Boolean>;
  I, J, LPosition: Integer;
begin
  LCurrent := NimbusPropertyGridIndexedObjectOrder(AObject, AKind);
  if Length(LCurrent) <> Length(AOrder) then raise EPropertyError.Create('Object list changed since the operation');
  SetLength(LMatched, Length(LCurrent));
  for I := 0 to High(AOrder) do
  begin
    LPosition := -1;
    for J := 0 to High(LCurrent) do
      if not LMatched[J] and (LCurrent[J] = AOrder[I]) then begin LPosition := J; Break; end;
    if LPosition < 0 then raise EPropertyError.Create('Object list contains different objects');
    LMatched[LPosition] := True;
  end;
  LAdapter := NimbusFindPropertyGridAdapter(AObject);
  for I := 0 to High(AOrder) do
  begin
    if LAdapter.ObjectAt(AObject, I) = AOrder[I] then Continue;
    LPosition := -1;
    for J := I + 1 to High(AOrder) do
      if LAdapter.ObjectAt(AObject, J) = AOrder[I] then begin LPosition := J; Break; end;
    if LPosition < 0 then raise EPropertyError.Create('Object list changed during reorder');
    LAdapter.Move(AObject, LPosition, I);
  end;
end;

procedure NimbusPropertyGridIndexedAdd(AObject: TObject; AKind: TThemedPropertyGridIndexedKind);
begin
  if not NimbusPropertyGridIndexedCanRestructure(AObject, AKind) then raise EPropertyError.Create('Cannot add an indexed item');
  case AKind of
    pgikString: TStrings(AObject).Add('');
    pgikCollection: TCollection(AObject).Add;
    pgikListText: TList<string>(AObject).Add('');
    pgikListInteger: TList<Integer>(AObject).Add(0);
    pgikListInt64: TList<Int64>(AObject).Add(0);
    pgikListFloat: TList<Double>(AObject).Add(0);
    pgikListBoolean: TList<Boolean>(AObject).Add(False);
    pgikAdapter: NimbusFindPropertyGridAdapter(AObject).Add(AObject);
  end;
end;

procedure NimbusPropertyGridIndexedDelete(AObject: TObject; AKind: TThemedPropertyGridIndexedKind; AIndex: Integer);
begin
  if not NimbusPropertyGridIndexedCanRestructure(AObject, AKind) then raise EPropertyError.Create('Cannot remove an indexed item');
  if (AIndex < 0) or (AIndex >= NimbusPropertyGridIndexedCount(AObject, AKind)) then raise EArgumentOutOfRangeException.Create('AIndex');
  case AKind of
    pgikString: TStrings(AObject).Delete(AIndex);
    pgikCollection: TCollection(AObject).Items[AIndex].Free;
    pgikListText: TList<string>(AObject).Delete(AIndex);
    pgikListInteger: TList<Integer>(AObject).Delete(AIndex);
    pgikListInt64: TList<Int64>(AObject).Delete(AIndex);
    pgikListFloat: TList<Double>(AObject).Delete(AIndex);
    pgikListBoolean: TList<Boolean>(AObject).Delete(AIndex);
    pgikAdapter: NimbusFindPropertyGridAdapter(AObject).Delete(AObject, AIndex);
  end;
end;

procedure NimbusPropertyGridIndexedMove(AObject: TObject; AKind: TThemedPropertyGridIndexedKind; AFrom, ATo: Integer);
begin
  if not NimbusPropertyGridIndexedCanReorder(AObject, AKind) then raise EPropertyError.Create('Cannot move an indexed item');
  if (AFrom < 0) or (ATo < 0) or (AFrom >= NimbusPropertyGridIndexedCount(AObject, AKind)) or (ATo >= NimbusPropertyGridIndexedCount(AObject, AKind)) then
    raise EArgumentOutOfRangeException.Create('AFrom');
  case AKind of
    pgikString: TStrings(AObject).Exchange(AFrom, ATo);
    pgikCollection: TCollection(AObject).Items[AFrom].Index := ATo;
    pgikListText: TList<string>(AObject).Move(AFrom, ATo);
    pgikListInteger: TList<Integer>(AObject).Move(AFrom, ATo);
    pgikListInt64: TList<Int64>(AObject).Move(AFrom, ATo);
    pgikListFloat: TList<Double>(AObject).Move(AFrom, ATo);
    pgikListBoolean: TList<Boolean>(AObject).Move(AFrom, ATo);
    pgikAdapter: NimbusFindPropertyGridAdapter(AObject).Move(AObject, AFrom, ATo);
  end;
end;

function NimbusPropertyGridIndexedSnapshot(AObject: TObject; AKind: TThemedPropertyGridIndexedKind): TArray<Variant>;
var
  I, LCount: Integer;
begin
  if AKind = pgikCollection then raise EPropertyError.Create('Collection requires an object snapshot');
  LCount := NimbusPropertyGridIndexedCount(AObject, AKind);
  if LCount < 0 then raise EPropertyError.Create('Indexed source is unavailable');
  SetLength(Result, LCount);
  for I := 0 to LCount - 1 do Result[I] := NimbusPropertyGridIndexedRead(AObject, AKind, I);
end;

procedure NimbusPropertyGridIndexedRestore(AObject: TObject; AKind: TThemedPropertyGridIndexedKind; const AValues: TArray<Variant>);
var
  I: Integer;
begin
  if not NimbusPropertyGridIndexedCanRestructure(AObject, AKind) or (AKind = pgikCollection) then
    raise EPropertyError.Create('Indexed snapshot is not supported');
  while NimbusPropertyGridIndexedCount(AObject, AKind) > Length(AValues) do
    NimbusPropertyGridIndexedDelete(AObject, AKind, NimbusPropertyGridIndexedCount(AObject, AKind) - 1);
  while NimbusPropertyGridIndexedCount(AObject, AKind) < Length(AValues) do NimbusPropertyGridIndexedAdd(AObject, AKind);
  for I := 0 to High(AValues) do NimbusPropertyGridIndexedWrite(AObject, AKind, I, AValues[I]);
end;

function NimbusPropertyGridCollectionFingerprint(ACollection: TCollection): string;
var
  LItem: TCollectionItem;
  LInfo: PPropInfo;
  LList: PPropList;
  LObject: TObject;
  LValue: string;
  I, J, LCount: Integer;
begin
  Result := IntToStr(ACollection.Count);
  for I := 0 to ACollection.Count - 1 do
  begin
    LItem := ACollection.Items[I];
    Result := Result + #30 + LItem.ClassName;
    if LItem.ClassInfo = nil then Continue;
    LCount := GetPropList(LItem.ClassInfo, tkAny, nil);
    if LCount = 0 then Continue;
    GetMem(LList, LCount * SizeOf(Pointer));
    try
      GetPropList(LItem.ClassInfo, tkAny, LList);
      for J := 0 to LCount - 1 do
      begin
        LInfo := LList^[J];
        if LInfo.GetProc = nil then Continue;
        case LInfo.PropType^.Kind of
          tkInteger, tkInt64, tkFloat, tkEnumeration, tkSet, tkString, tkLString, tkWString, tkUString, tkChar, tkWChar, tkVariant:
            LValue := VarToStr(GetPropValue(LItem, string(LInfo.Name), True));
          tkClass:
            begin
              LObject := GetObjectProp(LItem, LInfo);
              if LObject is TStrings then LValue := TStrings(LObject).Text
              else if LObject is TFont then LValue := NimbusPropertyGridFontValue(TFont(LObject))
              else if LObject = nil then LValue := ''
              else LValue := LObject.ClassName;
            end;
        else Continue;
        end;
        Result := Result + #31 + string(LInfo.Name) + ':' + IntToStr(Length(LValue)) + ':' + LValue;
      end;
    finally
      FreeMem(LList);
    end;
  end;
end;

function NimbusPropertyGridCategory(const AName: string): string;
begin
  if SameText(AName, 'Name') or SameText(AName, 'Tag') or SameText(AName, 'DataSource') or SameText(AName, 'DataField') then Result := 'Data'
  else if SameText(AName, 'Left') or SameText(AName, 'Top') or SameText(AName, 'Width') or SameText(AName, 'Height') or SameText(AName, 'Align') or SameText(AName, 'Anchors') or SameText(AName, 'Margins') or SameText(AName, 'Padding') or SameText(AName, 'Constraints') then Result := 'Layout'
  else if SameText(AName, 'Color') or SameText(AName, 'Font') or SameText(AName, 'Caption') or SameText(AName, 'Text') or SameText(AName, 'ParentColor') or SameText(AName, 'ParentFont') or SameText(AName, 'Visible') or SameText(AName, 'Style') then Result := 'Appearance'
  else if SameText(AName, 'Enabled') or SameText(AName, 'TabOrder') or SameText(AName, 'TabStop') or SameText(AName, 'ReadOnly') or SameText(AName, 'ShowHint') then Result := 'Behavior'
  else Result := 'Misc';
end;

function NimbusPropertyGridFontValue(const AFont: TFont): string;
var
  LStyles: Integer;
begin
  LStyles := 0;
  if fsBold in AFont.Style then LStyles := LStyles or 1;
  if fsItalic in AFont.Style then LStyles := LStyles or 2;
  if fsUnderline in AFont.Style then LStyles := LStyles or 4;
  if fsStrikeOut in AFont.Style then LStyles := LStyles or 8;
  Result := AFont.Name + #9 + IntToStr(AFont.Size) + #9 + IntToStr(Integer(AFont.Color)) + #9 + IntToStr(AFont.Charset) + #9 + IntToStr(LStyles);
end;

constructor TThemedPropertyGridMetadata.Create;
begin
  inherited Create;
  FBrowsable := True;
  FIncrement := 0;
  FDecimalPlaces := -1;
  FEditorKind := pgeAuto;
  FPathFilter := 'All files (*.*)|*.*';
end;

procedure TThemedPropertyGridMetadata.SetDisplayName(const AValue: string);
begin
  FDisplayName := AValue;
  FHasDisplayName := True;
end;

procedure TThemedPropertyGridMetadata.SetCategory(const AValue: string);
begin
  FCategory := AValue;
  FHasCategory := True;
end;

procedure TThemedPropertyGridMetadata.SetDescription(const AValue: string);
begin
  FDescription := AValue;
  FHasDescription := True;
end;

procedure TThemedPropertyGridMetadata.SetBrowsable(const AValue: Boolean);
begin
  FBrowsable := AValue;
  FHasBrowsable := True;
end;

procedure TThemedPropertyGridMetadata.SetReadOnly(const AValue: Boolean);
begin
  FReadOnly := AValue;
  FHasReadOnly := True;
end;

procedure TThemedPropertyGridMetadata.SetDefaultValue(const AValue: Variant);
begin
  FDefaultValue := AValue;
  FHasDefaultValue := True;
end;

procedure TThemedPropertyGridMetadata.SetMinimum(const AValue: Extended);
begin
  FMinimum := AValue;
  FHasMinimum := True;
end;

procedure TThemedPropertyGridMetadata.SetMaximum(const AValue: Extended);
begin
  FMaximum := AValue;
  FHasMaximum := True;
end;

procedure TThemedPropertyGridMetadata.ApplyTo(AItem: TThemedPropertyGridItem);
begin
  if AItem = nil then Exit;
  if FHasDisplayName then AItem.DisplayName := FDisplayName;
  if FHasCategory then AItem.Category := FCategory;
  if FHasDescription then AItem.Description := FDescription;
  if FHasReadOnly then AItem.MetadataReadOnly := FReadOnly;
  if FHasDefaultValue then
  begin
    AItem.DefaultValue := FDefaultValue;
    AItem.HasDefaultValue := True;
  end;
  if FHasMinimum then
  begin
    AItem.NumericMinimum := FMinimum;
    AItem.NumericHasMinimum := True;
  end;
  if FHasMaximum then
  begin
    AItem.NumericMaximum := FMaximum;
    AItem.NumericHasMaximum := True;
  end;
  if FIncrement > 0 then AItem.NumericIncrement := FIncrement;
  if FDecimalPlaces >= 0 then AItem.NumericDecimalPlaces := FDecimalPlaces;
  if FEditorKind <> pgeAuto then AItem.EditorKind := FEditorKind;
  if FPathFilter <> '' then AItem.PathFilter := FPathFilter;
  if FPathCheckExists then AItem.PathCheckExists := True;
end;

constructor TThemedPropertyGridVirtualProperty.Create(const AName: string; AGetter: TThemedPropertyGridGetVirtualEvent; ASetter: TThemedPropertyGridSetVirtualEvent);
begin
  inherited Create;
  if AName = '' then raise EArgumentException.Create('Virtual property name is required');
  Name := AName;
  DisplayName := AName;
  Category := 'Virtual';
  IsBrowsable := True;
  IsReadOnly := not Assigned(ASetter);
  OnGetValue := AGetter;
  OnSetValue := ASetter;
end;

constructor TThemedPropertyGridItem.Create(const ATargets: TArray<TPersistent>; const APath: string; APropInfo: PPropInfo; AVirtual: TThemedPropertyGridVirtualProperty; AIndexedKind: TThemedPropertyGridIndexedKind);
var
  I, LStart, LBracket: Integer;
begin
  inherited Create;
  FTargets := Copy(ATargets);
  FVirtual := AVirtual;
  FPropInfo := APropInfo;
  FIndexedKind := AIndexedKind;
  FIndexedPosition := -1;
  NumericIncrement := 0;
  NumericDecimalPlaces := -1;
  EditorKind := pgeAuto;
  Path := APath;
  LStart := 1;
  for I := 1 to Length(APath) do
    if APath[I] = '.' then
    begin
      SetLength(FParts, Length(FParts) + 1);
      FParts[High(FParts)] := Copy(APath, LStart, I - LStart);
      LStart := I + 1;
    end;
  SetLength(FParts, Length(FParts) + 1);
  FParts[High(FParts)] := Copy(APath, LStart, MaxInt);
  Name := FParts[High(FParts)];
  if FIndexedKind <> pgikNone then
  begin
    LBracket := LastDelimiter('[', Name);
    if (LBracket = 0) or (Name[Length(Name)] <> ']') or not TryStrToInt(Copy(Name, LBracket + 1, Length(Name) - LBracket - 1), FIndexedPosition) then
      raise EArgumentException.CreateFmt('Invalid indexed property path: %s', [APath]);
  end;
  DisplayName := Name;
  Category := NimbusPropertyGridCategory(Name);
  IndentLevel := Length(FParts) - 1;
  for I := 1 to Length(APath) do if APath[I] = '[' then Inc(IndentLevel);
  if FIndexedKind <> pgikNone then DisplayName := '[' + IntToStr(FIndexedPosition) + ']';
  if FVirtual <> nil then
  begin
    DisplayName := FVirtual.DisplayName;
    Category := FVirtual.Category;
    Description := FVirtual.Description;
    DefaultValue := FVirtual.DefaultValue;
    HasDefaultValue := FVirtual.HasDefaultValue;
  end
  else if (FPropInfo <> nil) and (FPropInfo.Default <> LongInt($80000000)) and (Kind in [tkInteger, tkInt64, tkEnumeration]) then
  begin
    DefaultValue := FPropInfo.Default;
    if Kind = tkEnumeration then DefaultValue := GetEnumName(FPropInfo.PropType^, FPropInfo.Default);
    HasDefaultValue := True;
  end;
  FOriginal := ReadValues;
  UpdateState;
end;

function TThemedPropertyGridItem.ResolveOwner(ATarget: TPersistent): TObject;
var
  I, LBracket, LIndex: Integer;
  LInfo: PPropInfo;
  LName, LPart: string;
begin
  Result := ATarget;
  for I := 0 to High(FParts) - 1 do
  begin
    if Result = nil then Exit(nil);
    LPart := FParts[I];
    LBracket := Pos('[', LPart);
    if LBracket > 0 then LName := Copy(LPart, 1, LBracket - 1) else LName := LPart;
    LInfo := GetPropInfo(Result.ClassInfo, LName);
    if (LInfo = nil) or (LInfo.PropType^.Kind <> tkClass) then Exit(nil);
    Result := GetObjectProp(Result, LInfo);
    if LBracket > 0 then
    begin
      if (LPart[Length(LPart)] <> ']') or not TryStrToInt(Copy(LPart, LBracket + 1, Length(LPart) - LBracket - 1), LIndex) then Exit(nil);
      if Result is TCollection then
      begin
        if (LIndex < 0) or (LIndex >= TCollection(Result).Count) then Exit(nil);
        Result := TCollection(Result).Items[LIndex];
      end
      else
      begin
        var LAdapter := NimbusFindPropertyGridAdapter(Result);
        if (LAdapter = nil) or (LAdapter.Kind(Result) <> tkClass) or (LIndex < 0) or (LIndex >= LAdapter.Count(Result)) then Exit(nil);
        Result := LAdapter.ObjectAt(Result, LIndex);
      end;
    end;
  end;
end;

function TThemedPropertyGridItem.IndexedPropertyInfo(AOwner: TObject): PPropInfo;
var
  LBracket: Integer;
begin
  Result := nil;
  if AOwner = nil then Exit;
  LBracket := Pos('[', Name);
  if LBracket = 0 then Exit;
  Result := GetPropInfo(AOwner.ClassInfo, Copy(Name, 1, LBracket - 1));
end;

function TThemedPropertyGridItem.ResolveIndexedSource(ATarget: TPersistent): TObject;
var
  LOwner: TObject;
  LInfo: PPropInfo;
  LName: string;
  LBracket: Integer;
begin
  Result := nil;
  LOwner := ResolveOwner(ATarget);
  if LOwner = nil then Exit;
  LBracket := Pos('[', Name);
  if LBracket = 0 then Exit;
  LName := Copy(Name, 1, LBracket - 1);
  LInfo := GetPropInfo(LOwner.ClassInfo, LName);
  if (LInfo = nil) or (LInfo.PropType^.Kind <> tkClass) then Exit;
  Result := GetObjectProp(LOwner, LInfo);
  if (FIndexedKind <> pgikNone) and (FIndexedKind <> pgikVariant) and
    (FIndexedPosition >= NimbusPropertyGridIndexedCount(Result, FIndexedKind)) then Result := nil;
end;

function TThemedPropertyGridItem.ResolveInfo(AOwner: TObject): PPropInfo;
begin
  if AOwner = nil then Exit(nil);
  Result := GetPropInfo(AOwner.ClassInfo, Name);
end;

function TThemedPropertyGridItem.GetKind: TTypeKind;
begin
  if FVirtual <> nil then Exit(tkVariant);
  if FIndexedKind = pgikString then Exit(tkUString);
  if FIndexedKind = pgikCollection then Exit(tkClass);
  if FIndexedKind in [pgikListText] then Exit(tkUString);
  if FIndexedKind in [pgikListInteger] then Exit(tkInteger);
  if FIndexedKind in [pgikListInt64] then Exit(tkInt64);
  if FIndexedKind in [pgikListFloat] then Exit(tkFloat);
  if FIndexedKind in [pgikListBoolean] then Exit(tkEnumeration);
  if FIndexedKind = pgikAdapter then
  begin
    if Length(FTargets) = 0 then Exit(tkUnknown);
    var LSource := ResolveIndexedSource(FTargets[0]);
    var LAdapter := NimbusFindPropertyGridAdapter(LSource);
    if LAdapter <> nil then Exit(LAdapter.Kind(LSource));
    Exit(tkUnknown);
  end;
  if FIndexedKind = pgikVariant then Exit(tkVariant);
  if FPropInfo <> nil then Exit(FPropInfo.PropType^.Kind);
  Result := tkUnknown;
end;

function TThemedPropertyGridItem.GetReadOnly: Boolean;
begin
  if MetadataReadOnly then Exit(True);
  if FVirtual <> nil then Exit(FVirtual.IsReadOnly or not Assigned(FVirtual.OnSetValue));
  if FIndexedKind = pgikVariant then
  begin
    if Length(FTargets) = 0 then Exit(True);
    var LOwner := ResolveOwner(FTargets[0]);
    var LIndexedInfo := IndexedPropertyInfo(LOwner);
    Exit((LIndexedInfo = nil) or (LIndexedInfo.SetProc = nil));
  end;
  if FIndexedKind = pgikAdapter then
  begin
    if Length(FTargets) = 0 then Exit(True);
    var LSource := ResolveIndexedSource(FTargets[0]);
    var LAdapter := NimbusFindPropertyGridAdapter(LSource);
    Exit((LAdapter = nil) or not LAdapter.CanWrite);
  end;
  if FIndexedKind <> pgikNone then Exit(FIndexedKind = pgikCollection);
  if FPropInfo = nil then Exit(True);
  Result := FPropInfo.SetProc = nil;
  if Kind = tkVariant then
  begin
    if Length(FTargets) > 0 then
    begin
      var LOwner := ResolveOwner(FTargets[0]);
      if (LOwner <> nil) and VarIsArray(GetVariantProp(LOwner, FPropInfo)) then Exit(True);
    end;
  end;
  if Kind = tkClass then
  begin
    Result := True;
    if Length(FTargets) > 0 then
    begin
      var LOwner := ResolveOwner(FTargets[0]);
      if LOwner <> nil then
      begin
        var LObject := GetObjectProp(LOwner, FPropInfo);
        Result := not ((LObject is TStrings) or (LObject is TFont) or (LObject is TPicture) or (LObject is TGraphic) or (LObject is TCollection));
      end;
    end;
  end;
end;

function TThemedPropertyGridItem.ReadValues: TArray<Variant>;
var
  I: Integer;
  LOwner, LObject: TObject;
  LInfo: PPropInfo;
  LValue: Variant;
  LGraphic: TGraphic;
  LStream: TMemoryStream;
  LBytes: TBytes;
  LHash: THashSHA2;
begin
  if FVirtual <> nil then
  begin
    LValue := Null;
    if Assigned(FVirtual.OnGetValue) then FVirtual.OnGetValue(FVirtual, LValue);
    SetLength(Result, 1);
    Result[0] := LValue;
    Exit;
  end;
  SetLength(Result, Length(FTargets));
  if FIndexedKind <> pgikNone then
  begin
    for I := 0 to High(FTargets) do
    begin
      if FIndexedKind = pgikVariant then
      begin
        LOwner := ResolveOwner(FTargets[I]);
        LInfo := IndexedPropertyInfo(LOwner);
        if (LInfo = nil) or (LInfo.PropType^.Kind <> tkVariant) then raise EPropertyError.CreateFmt('Indexed property %s is unavailable', [Path]);
        LValue := GetVariantProp(LOwner, LInfo);
        if not VarIsArray(LValue) or (VarArrayDimCount(LValue) <> 1) or (FIndexedPosition < VarArrayLowBound(LValue, 1)) or
          (FIndexedPosition > VarArrayHighBound(LValue, 1)) then raise EPropertyError.CreateFmt('Array element %s is unavailable', [Path]);
        Result[I] := VarArrayGet(LValue, [FIndexedPosition]);
      end
      else
      begin
        LObject := ResolveIndexedSource(FTargets[I]);
        if LObject = nil then raise EPropertyError.CreateFmt('Indexed property %s is unavailable', [Path]);
        Result[I] := NimbusPropertyGridIndexedRead(LObject, FIndexedKind, FIndexedPosition);
      end;
    end;
    Exit;
  end;
  for I := 0 to High(FTargets) do
  begin
    LOwner := ResolveOwner(FTargets[I]);
    LInfo := ResolveInfo(LOwner);
    if LInfo = nil then raise EPropertyError.CreateFmt('Property %s is missing', [Path]);
    case LInfo.PropType^.Kind of
      tkClass:
        begin
          LObject := GetObjectProp(LOwner, LInfo);
          if LObject is TStrings then Result[I] := TStrings(LObject).Text
          else if LObject is TFont then Result[I] := NimbusPropertyGridFontValue(TFont(LObject))
          else if (LObject is TPicture) or (LObject is TGraphic) then
          begin
            if LObject is TPicture then LGraphic := TPicture(LObject).Graphic else LGraphic := TGraphic(LObject);
            if (LGraphic = nil) or LGraphic.Empty then Result[I] := '(empty image)'
            else
            begin
              LStream := TMemoryStream.Create;
              try
                LGraphic.SaveToStream(LStream);
                SetLength(LBytes, LStream.Size);
                if LStream.Size > 0 then Move(LStream.Memory^, LBytes[0], LStream.Size);
                LHash := THashSHA2.Create;
                LHash.Update(LBytes);
                Result[I] := LGraphic.ClassName + ':' + LHash.HashAsString;
              finally
                LStream.Free;
              end;
            end;
          end
          else if LObject is TCollection then Result[I] := NimbusPropertyGridCollectionFingerprint(TCollection(LObject))
          else if (NimbusPropertyGridListKind(LObject) <> pgikNone) or (NimbusFindPropertyGridAdapter(LObject) <> nil) then
          begin
            var LListKind := NimbusPropertyGridListKind(LObject);
            if LListKind = pgikNone then LListKind := pgikAdapter;
            Result[I] := IntToStr(NimbusPropertyGridIndexedCount(LObject, LListKind));
            for var LIndex := 0 to NimbusPropertyGridIndexedCount(LObject, LListKind) - 1 do
            begin
              var LEntry := NimbusPropertyGridIndexedRead(LObject, LListKind, LIndex);
              var LText := VarToStr(LEntry);
              Result[I] := VarToStr(Result[I]) + #31 + IntToStr(VarType(LEntry)) + ':' + IntToStr(Length(LText)) + ':' + LText;
            end;
          end
          else if LObject = nil then Result[I] := '(nil)'
          else Result[I] := '(' + LObject.ClassName + ')';
        end;
      tkVariant:
        begin
          LValue := GetVariantProp(LOwner, LInfo);
          if VarIsArray(LValue) then
          begin
            Result[I] := 'Array dimensions: ' + IntToStr(VarArrayDimCount(LValue));
            if VarArrayDimCount(LValue) = 1 then
            begin
              Result[I] := VarToStr(Result[I]) + ':' + IntToStr(VarArrayLowBound(LValue, 1)) + ':' + IntToStr(VarArrayHighBound(LValue, 1));
              for var LIndex := VarArrayLowBound(LValue, 1) to VarArrayHighBound(LValue, 1) do
              begin
                var LElement := VarArrayGet(LValue, [LIndex]);
                if VarIsArray(LElement) then Result[I] := VarToStr(Result[I]) + #31 + '(nested array)'
                else Result[I] := VarToStr(Result[I]) + #31 + IntToStr(VarType(LElement)) + ':' + IntToStr(Length(VarToStr(LElement))) + ':' + VarToStr(LElement);
              end;
            end;
          end
          else Result[I] := LValue;
        end;
      tkSet: Result[I] := GetSetProp(LOwner, LInfo, True);
      tkEnumeration: Result[I] := GetEnumName(LInfo.PropType^, GetOrdProp(LOwner, LInfo));
      tkFloat: Result[I] := GetFloatProp(LOwner, LInfo);
      tkInteger:
        if GetTypeData(LInfo.PropType^).OrdType = otULong then Result[I] := Cardinal(GetOrdProp(LOwner, LInfo))
        else Result[I] := GetOrdProp(LOwner, LInfo);
      tkChar, tkWChar: Result[I] := GetOrdProp(LOwner, LInfo);
      tkInt64: Result[I] := GetInt64Prop(LOwner, LInfo);
    else Result[I] := GetPropValue(LOwner, Name, True);
    end;
  end;
end;

function TThemedPropertyGridItem.ReadValue: Variant;
var
  LValues: TArray<Variant>;
begin
  LValues := ReadValues;
  if Length(LValues) = 0 then Exit(Null);
  Result := LValues[0];
end;

procedure TThemedPropertyGridItem.WriteValues(const AValues: TArray<Variant>);
var
  I, J: Integer;
  LOwner, LObject: TObject;
  LInfo: PPropInfo;
  LBefore: TArray<Variant>;
  LString: string;
  LEnumValue: Integer;
  LColor: TColor;
  LFloat: Double;
  LDate: TDateTime;
  LParts: TArray<string>;
  LStyles: Integer;
  LFont: TFont;
  LFontStyle: TFontStyles;
  LIndexedObjects: TArray<TObject>;
  LVariantOwners: TArray<TObject>;
  LVariantInfos: TArray<PPropInfo>;
  LVariantValues: TArray<Variant>;
begin
  if IsReadOnly then raise EPropertyError.CreateFmt('Property %s is read-only', [Path]);
  if FVirtual <> nil then
  begin
    if Length(AValues) <> 1 then raise EArgumentException.Create('Invalid virtual property values');
    FVirtual.OnSetValue(FVirtual, AValues[0]);
    UpdateState;
    Exit;
  end;
  if Length(AValues) <> Length(FTargets) then raise EArgumentException.Create('Invalid number of property values');
  if FIndexedKind = pgikVariant then
  begin
    SetLength(LVariantOwners, Length(FTargets));
    SetLength(LVariantInfos, Length(FTargets));
    SetLength(LVariantValues, Length(FTargets));
    for I := 0 to High(FTargets) do
    begin
      LVariantOwners[I] := ResolveOwner(FTargets[I]);
      LVariantInfos[I] := IndexedPropertyInfo(LVariantOwners[I]);
      if (LVariantInfos[I] = nil) or (LVariantInfos[I].SetProc = nil) then raise EPropertyError.CreateFmt('Array property %s is read-only', [Path]);
      LVariantValues[I] := GetVariantProp(LVariantOwners[I], LVariantInfos[I]);
      if not VarIsArray(LVariantValues[I]) or (VarArrayDimCount(LVariantValues[I]) <> 1) or
        (FIndexedPosition < VarArrayLowBound(LVariantValues[I], 1)) or (FIndexedPosition > VarArrayHighBound(LVariantValues[I], 1)) then
        raise EPropertyError.CreateFmt('Array element %s is unavailable', [Path]);
    end;
    LBefore := ReadValues;
    for I := 0 to High(AValues) do
      try
        var LUpdated := GetVariantProp(LVariantOwners[I], LVariantInfos[I]);
        VarArrayPut(LUpdated, AValues[I], [FIndexedPosition]);
        SetVariantProp(LVariantOwners[I], LVariantInfos[I], LUpdated);
      except
        for J := I downto 0 do
        begin
          var LRestore := GetVariantProp(LVariantOwners[J], LVariantInfos[J]);
          VarArrayPut(LRestore, LBefore[J], [FIndexedPosition]);
          SetVariantProp(LVariantOwners[J], LVariantInfos[J], LRestore);
        end;
        raise;
      end;
    UpdateState;
    Exit;
  end;
  if FIndexedKind in [pgikString, pgikListText, pgikListInteger, pgikListInt64, pgikListFloat, pgikListBoolean, pgikAdapter] then
  begin
    SetLength(LIndexedObjects, Length(FTargets));
    for I := 0 to High(FTargets) do
    begin
      LIndexedObjects[I] := ResolveIndexedSource(FTargets[I]);
      if LIndexedObjects[I] = nil then raise EPropertyError.CreateFmt('Indexed property %s is unavailable', [Path]);
    end;
    LBefore := ReadValues;
    for I := 0 to High(AValues) do
      try
        NimbusPropertyGridIndexedWrite(LIndexedObjects[I], FIndexedKind, FIndexedPosition, AValues[I]);
      except
        for J := I - 1 downto 0 do NimbusPropertyGridIndexedWrite(LIndexedObjects[J], FIndexedKind, FIndexedPosition, LBefore[J]);
        raise;
      end;
    UpdateState;
    Exit;
  end;
  LBefore := ReadValues;
  for I := 0 to High(AValues) do
  begin
    LOwner := ResolveOwner(FTargets[I]);
    LInfo := ResolveInfo(LOwner);
    if LInfo = nil then raise EPropertyError.CreateFmt('Property %s is missing', [Path]);
    LString := VarToStr(AValues[I]);
    try
      case LInfo.PropType^.Kind of
        tkClass:
          begin
            LObject := GetObjectProp(LOwner, LInfo);
            if LObject is TStrings then TStrings(LObject).Text := LString
            else if LObject is TFont then
            begin
              LParts := LString.Split([#9]);
              if Length(LParts) <> 5 then raise EConvertError.Create('Invalid font description');
              LFont := TFont.Create;
              try
                LFont.Assign(TFont(LObject));
                LFont.Name := LParts[0];
                LFont.Size := StrToInt(LParts[1]);
                LFont.Color := TColor(StrToInt64(LParts[2]));
                LFont.Charset := TFontCharset(StrToInt(LParts[3]));
                LStyles := StrToInt(LParts[4]);
                LFontStyle := [];
                if LStyles and 1 <> 0 then Include(LFontStyle, fsBold);
                if LStyles and 2 <> 0 then Include(LFontStyle, fsItalic);
                if LStyles and 4 <> 0 then Include(LFontStyle, fsUnderline);
                if LStyles and 8 <> 0 then Include(LFontStyle, fsStrikeOut);
                LFont.Style := LFontStyle;
                TFont(LObject).Assign(LFont);
              finally
                LFont.Free;
              end;
            end
            else raise EPropertyError.Create('Use the dedicated object editor');
          end;
        tkSet: SetSetProp(LOwner, LInfo, LString);
        tkEnumeration:
          begin
            LEnumValue := GetEnumValue(LInfo.PropType^, LString);
            if LEnumValue < 0 then raise EConvertError.CreateFmt('Invalid enum value: %s', [LString]);
            SetOrdProp(LOwner, LInfo, LEnumValue);
          end;
        tkInteger:
          begin
            if SameText(string(LInfo.PropType^.Name), 'TColor') then
            begin
              LColor := StringToColor(LString);
              SetOrdProp(LOwner, LInfo, LColor);
            end
            else if GetTypeData(LInfo.PropType^).OrdType = otULong then
              SetOrdProp(LOwner, LInfo, LongInt(Cardinal(StrToInt64(LString))))
            else SetOrdProp(LOwner, LInfo, StrToInt64(LString));
          end;
        tkInt64: SetInt64Prop(LOwner, LInfo, StrToInt64(LString));
        tkFloat:
          begin
            if SameText(string(LInfo.PropType^.Name), 'TDateTime') or SameText(string(LInfo.PropType^.Name), 'TDate') or SameText(string(LInfo.PropType^.Name), 'TTime') then
            begin
              if VarIsNumeric(AValues[I]) then LFloat := AValues[I]
              else if TryStrToDateTime(LString, LDate) then LFloat := LDate
              else if not TryStrToFloat(LString, LFloat) then raise EConvertError.Create('Invalid date or time');
            end
            else LFloat := StrToFloat(LString);
            SetFloatProp(LOwner, LInfo, LFloat);
          end;
        tkChar, tkWChar:
          begin
            if Length(LString) <> 1 then raise EConvertError.Create('A single character is required');
            SetOrdProp(LOwner, LInfo, Ord(LString[1]));
          end;
      else SetPropValue(LOwner, Name, AValues[I]);
      end;
    except
      for J := I downto 0 do
      begin
          LOwner := ResolveOwner(FTargets[J]);
          LInfo := ResolveInfo(LOwner);
          case LInfo.PropType^.Kind of
            tkClass:
              begin
                LObject := GetObjectProp(LOwner, LInfo);
                if LObject is TStrings then TStrings(LObject).Text := VarToStr(LBefore[J])
                else if LObject is TFont then
                begin
                  LParts := VarToStr(LBefore[J]).Split([#9]);
                  if Length(LParts) <> 5 then raise EConvertError.Create('Invalid font snapshot');
                  LFont := TFont( LObject );
                  LFont.Name := LParts[0];
                  LFont.Size := StrToInt(LParts[1]);
                  LFont.Color := TColor(StrToInt64(LParts[2]));
                  LFont.Charset := TFontCharset(StrToInt(LParts[3]));
                  LStyles := StrToInt(LParts[4]);
                  LFontStyle := [];
                  if LStyles and 1 <> 0 then Include(LFontStyle, fsBold);
                  if LStyles and 2 <> 0 then Include(LFontStyle, fsItalic);
                  if LStyles and 4 <> 0 then Include(LFontStyle, fsUnderline);
                  if LStyles and 8 <> 0 then Include(LFontStyle, fsStrikeOut);
                  LFont.Style := LFontStyle;
                end;
              end;
            tkSet: SetSetProp(LOwner, LInfo, VarToStr(LBefore[J]));
            tkEnumeration: SetOrdProp(LOwner, LInfo, GetEnumValue(LInfo.PropType^, VarToStr(LBefore[J])));
            tkInteger:
              if GetTypeData(LInfo.PropType^).OrdType = otULong then
                SetOrdProp(LOwner, LInfo, LongInt(Cardinal(StrToInt64(VarToStr(LBefore[J])))))
              else SetOrdProp(LOwner, LInfo, StrToInt64(VarToStr(LBefore[J])));
            tkChar, tkWChar: SetOrdProp(LOwner, LInfo, StrToInt64(VarToStr(LBefore[J])));
            tkInt64: SetInt64Prop(LOwner, LInfo, StrToInt64(VarToStr(LBefore[J])));
            tkFloat: SetFloatProp(LOwner, LInfo, LBefore[J]);
          else SetPropValue(LOwner, Name, LBefore[J]);
          end;
      end;
      raise;
    end;
  end;
  UpdateState;
end;

procedure TThemedPropertyGridItem.WriteValue(const AValue: Variant);
var
  LValues: TArray<Variant>;
  I: Integer;
begin
  SetLength(LValues, IfThen(FVirtual <> nil, 1, Length(FTargets)));
  for I := 0 to High(LValues) do LValues[I] := AValue;
  WriteValues(LValues);
end;

function TThemedPropertyGridItem.PreviewGraphic: TGraphic;
var
  LOwner, LObject: TObject;
begin
  Result := nil;
  if MultipleValues or (Length(FTargets) = 0) or (FPropInfo = nil) or (Kind <> tkClass) then Exit;
  LOwner := ResolveOwner(FTargets[0]);
  if LOwner = nil then Exit;
  LObject := GetObjectProp(LOwner, ResolveInfo(LOwner));
  if LObject is TPicture then Result := TPicture(LObject).Graphic
  else if LObject is TGraphic then Result := TGraphic(LObject);
  if (Result <> nil) and Result.Empty then Result := nil;
end;

function TThemedPropertyGridItem.CapturePictures: TObjectList<TPicture>;
var
  LTarget: TPersistent;
  LOwner, LObject: TObject;
  LPicture: TPicture;
begin
  Result := TObjectList<TPicture>.Create(True);
  try
    for LTarget in FTargets do
    begin
      LOwner := ResolveOwner(LTarget);
      if LOwner = nil then raise EPropertyError.CreateFmt('Property %s is missing', [Path]);
      LObject := GetObjectProp(LOwner, ResolveInfo(LOwner));
      if not ((LObject is TPicture) or (LObject is TGraphic)) then raise EPropertyError.Create('Property is not an image');
      LPicture := TPicture.Create;
      try
        if LObject is TPicture then LPicture.Assign(TPicture(LObject)) else LPicture.Graphic := TGraphic(LObject);
        Result.Add(LPicture);
        LPicture := nil;
      finally
        LPicture.Free;
      end;
    end;
  except
    Result.Free;
    raise;
  end;
end;

procedure TThemedPropertyGridItem.RestorePictures(APictures: TObjectList<TPicture>);
var
  I: Integer;
  LOwner, LObject: TObject;
begin
  if APictures.Count <> Length(FTargets) then raise EArgumentException.Create('Invalid image target count');
  for I := 0 to High(FTargets) do
  begin
    LOwner := ResolveOwner(FTargets[I]);
    if LOwner = nil then raise EPropertyError.CreateFmt('Property %s is missing', [Path]);
    LObject := GetObjectProp(LOwner, ResolveInfo(LOwner));
    if LObject is TPicture then TPicture(LObject).Assign(APictures[I])
    else if LObject is TGraphic then TGraphic(LObject).Assign(APictures[I].Graphic)
    else raise EPropertyError.Create('Property is not an image');
  end;
  UpdateState;
end;

function TThemedPropertyGridItem.CaptureCollections: TObjectList<TCollection>;
var
  LTarget: TPersistent;
  LOwner, LObject: TObject;
  LCollection: TCollection;
begin
  Result := TObjectList<TCollection>.Create(True);
  try
    for LTarget in FTargets do
    begin
      LOwner := ResolveOwner(LTarget);
      if LOwner = nil then raise EPropertyError.CreateFmt('Property %s is missing', [Path]);
      LObject := GetObjectProp(LOwner, ResolveInfo(LOwner));
      if not (LObject is TCollection) then raise EPropertyError.Create('Property is not a collection');
      LCollection := TCollection.Create(TCollection(LObject).ItemClass);
      try
        LCollection.Assign(TCollection(LObject));
        Result.Add(LCollection);
        LCollection := nil;
      finally
        LCollection.Free;
      end;
    end;
  except
    Result.Free;
    raise;
  end;
end;

procedure TThemedPropertyGridItem.RestoreCollections(ACollections: TObjectList<TCollection>);
var
  LBackups: TObjectList<TCollection>;
  LTargets: TArray<TCollection>;
  LOwner, LObject: TObject;
  I, J: Integer;
begin
  if (ACollections = nil) or (ACollections.Count <> Length(FTargets)) then raise EArgumentException.Create('Invalid collection target count');
  SetLength(LTargets, Length(FTargets));
  for I := 0 to High(FTargets) do
  begin
    LOwner := ResolveOwner(FTargets[I]);
    if LOwner = nil then raise EPropertyError.CreateFmt('Property %s is missing', [Path]);
    LObject := GetObjectProp(LOwner, ResolveInfo(LOwner));
    if not (LObject is TCollection) then raise EPropertyError.Create('Property is not a collection');
    if TCollection(LObject).ItemClass <> ACollections[I].ItemClass then raise EPropertyError.Create('Incompatible collection item type');
    LTargets[I] := TCollection(LObject);
  end;
  LBackups := CaptureCollections;
  try
    try
      for I := 0 to High(LTargets) do LTargets[I].Assign(ACollections[I]);
    except
      for J := High(LTargets) downto 0 do LTargets[J].Assign(LBackups[J]);
      raise;
    end;
  finally
    LBackups.Free;
  end;
  UpdateState;
end;

procedure TThemedPropertyGridItem.UpdateState;
var
  I: Integer;
  LValues: TArray<Variant>;
begin
  LValues := ReadValues;
  MultipleValues := False;
  Dirty := False;
  for I := 1 to High(LValues) do
    if not VarSameValue(LValues[0], LValues[I]) then MultipleValues := True;
  if Length(FOriginal) <> Length(LValues) then FOriginal := Copy(LValues);
  for I := 0 to High(LValues) do
    if not VarSameValue(FOriginal[I], LValues[I]) then Dirty := True;
  if (ExpressionMode <> OriginalExpressionMode) or (ExpressionMode and (ExpressionText <> OriginalExpressionText)) then Dirty := True;
end;

procedure TThemedPropertyGridItem.AcceptChanges;
begin
  FOriginal := ReadValues;
  OriginalExpressionMode := ExpressionMode;
  OriginalExpressionText := ExpressionText;
  Dirty := False;
end;

function TThemedPropertyGridItem.GetValueText: string;
var
  LValue: Variant;
begin
  if ExpressionMode then Exit('=' + ExpressionText);
  if MultipleValues then Exit('(multiple values)');
  LValue := ReadValue;
  if VarIsNull(LValue) or VarIsEmpty(LValue) then Exit('');
  if (Kind = tkClass) and (FPropInfo <> nil) then
  begin
    if SameText(string(FPropInfo.PropType^.Name), 'TPicture') or SameText(string(FPropInfo.PropType^.Name), 'TBitmap') or SameText(string(FPropInfo.PropType^.Name), 'TIcon') then
    begin
      if VarToStr(LValue) = '(empty image)' then Exit('(empty image)');
      Exit('(image)');
    end
    else if (Length(FTargets) > 0) and (ResolveOwner(FTargets[0]) <> nil) and
      (GetObjectProp(ResolveOwner(FTargets[0]), FPropInfo) is TCollection) then
      Exit(Format('(%d items)', [TCollection(GetObjectProp(ResolveOwner(FTargets[0]), FPropInfo)).Count]))
    else if SameText(string(FPropInfo.PropType^.Name), 'TFont') then
    begin
      var LParts := VarToStr(LValue).Split([#9]);
      if Length(LParts) >= 2 then Exit(LParts[0] + ', ' + LParts[1] + ' pt');
    end
    else if (Length(FTargets) > 0) and (ResolveOwner(FTargets[0]) <> nil) and
      (GetObjectProp(ResolveOwner(FTargets[0]), FPropInfo) is TStrings) then
      Exit(Format('(%d lines)', [TStrings(GetObjectProp(ResolveOwner(FTargets[0]), FPropInfo)).Count]))
    else if (Length(FTargets) > 0) and (ResolveOwner(FTargets[0]) <> nil) then
    begin
      var LObject := GetObjectProp(ResolveOwner(FTargets[0]), FPropInfo);
      var LListKind := NimbusPropertyGridListKind(LObject);
      if LListKind = pgikNone then
      begin
        if NimbusFindPropertyGridAdapter(LObject) <> nil then LListKind := pgikAdapter;
      end;
      if LListKind <> pgikNone then Exit(Format('(%d items)', [NimbusPropertyGridIndexedCount(LObject, LListKind)]));
    end;
  end;
  if (Kind = tkVariant) and (FPropInfo <> nil) and (Length(FTargets) > 0) then
  begin
    var LOwner := ResolveOwner(FTargets[0]);
    if LOwner <> nil then
    begin
      var LArray := GetVariantProp(LOwner, FPropInfo);
      if VarIsArray(LArray) and (VarArrayDimCount(LArray) = 1) then
        Exit(Format('(%d items)', [VarArrayHighBound(LArray, 1) - VarArrayLowBound(LArray, 1) + 1]));
    end;
  end;
  if (Kind = tkFloat) and (FPropInfo <> nil) then
  begin
    if SameText(string(FPropInfo.PropType^.Name), 'TDateTime') then Exit(DateTimeToStr(LValue));
    if SameText(string(FPropInfo.PropType^.Name), 'TDate') then Exit(DateToStr(LValue));
    if SameText(string(FPropInfo.PropType^.Name), 'TTime') then Exit(TimeToStr(LValue));
  end;
  Result := VarToStr(LValue);
  if (Kind = tkInteger) and (FPropInfo <> nil) and SameText(string(FPropInfo.PropType^.Name), 'TColor') then
    Result := ColorToString(TColor(Integer(LValue)));
end;

destructor TThemedPropertyGridChange.Destroy;
begin
  OldPictures.Free;
  NewPictures.Free;
  OldCollections.Free;
  NewCollections.Free;
  inherited Destroy;
end;

function TThemedPropertyGridRow.IsCategory: Boolean;
begin
  Result := Item = nil;
end;

end.

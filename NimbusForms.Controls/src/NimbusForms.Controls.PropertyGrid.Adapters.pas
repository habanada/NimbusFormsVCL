{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.PropertyGrid.Adapters;

interface

uses
  System.Classes, System.SysUtils, System.TypInfo, System.Variants, System.Generics.Collections;

type
  TNimbusPropertyGridIndexedAdapter = class
  public
    function Matches(AObject: TObject): Boolean; virtual; abstract;
    function Count(AObject: TObject): Integer; virtual; abstract;
    function Kind(AObject: TObject): TTypeKind; virtual; abstract;
    function ReadValue(AObject: TObject; AIndex: Integer): Variant; virtual; abstract;
    procedure WriteValue(AObject: TObject; AIndex: Integer; const AValue: Variant); virtual;
    function ObjectAt(AObject: TObject; AIndex: Integer): TPersistent; virtual;
    function CanWrite: Boolean; virtual;
    function CanChangeStructure: Boolean; virtual;
    function CanReorder: Boolean; virtual;
    procedure Add(AObject: TObject); virtual;
    procedure Delete(AObject: TObject; AIndex: Integer); virtual;
    procedure Move(AObject: TObject; AFrom, ATo: Integer); virtual;
  end;

  TNimbusPropertyGridValueReader<T> = reference to function(const AValue: T): Variant;
  TNimbusPropertyGridValueWriter<T> = reference to function(const AValue: Variant): T;

  TNimbusPropertyGridListAdapter<T> = class(TNimbusPropertyGridIndexedAdapter)
  private
    FRead: TNimbusPropertyGridValueReader<T>;
    FWrite: TNimbusPropertyGridValueWriter<T>;
    FKind: TTypeKind;
    FCanInsert: Boolean;
  public
    constructor Create(AKind: TTypeKind; ARead: TNimbusPropertyGridValueReader<T>; AWrite: TNimbusPropertyGridValueWriter<T>; ACanInsert: Boolean = True);
    function Matches(AObject: TObject): Boolean; override;
    function Count(AObject: TObject): Integer; override;
    function Kind(AObject: TObject): TTypeKind; override;
    function ReadValue(AObject: TObject; AIndex: Integer): Variant; override;
    procedure WriteValue(AObject: TObject; AIndex: Integer; const AValue: Variant); override;
    function CanWrite: Boolean; override;
    function CanChangeStructure: Boolean; override;
    procedure Add(AObject: TObject); override;
    procedure Delete(AObject: TObject; AIndex: Integer); override;
    procedure Move(AObject: TObject; AFrom, ATo: Integer); override;
  end;

  TNimbusPropertyGridObjectListAdapter<T: TPersistent> = class(TNimbusPropertyGridIndexedAdapter)
  public
    function Matches(AObject: TObject): Boolean; override;
    function Count(AObject: TObject): Integer; override;
    function Kind(AObject: TObject): TTypeKind; override;
    function ReadValue(AObject: TObject; AIndex: Integer): Variant; override;
    function ObjectAt(AObject: TObject; AIndex: Integer): TPersistent; override;
    function CanReorder: Boolean; override;
    procedure Move(AObject: TObject; AFrom, ATo: Integer); override;
  end;

  TNimbusPropertyGridArray<T> = class(TPersistent)
  private
    FValues: TArray<T>;
  public
    procedure Load(const AValues: TArray<T>);
    function Values: TArray<T>;
    function Count: Integer;
    function Item(AIndex: Integer): T;
    procedure SetItem(AIndex: Integer; const AValue: T);
    procedure Add(const AValue: T);
    procedure Delete(AIndex: Integer);
    procedure Move(AFrom, ATo: Integer);
  end;

  TNimbusPropertyGridArrayAdapter<T> = class(TNimbusPropertyGridIndexedAdapter)
  private
    FRead: TNimbusPropertyGridValueReader<T>;
    FWrite: TNimbusPropertyGridValueWriter<T>;
    FKind: TTypeKind;
    FCanInsert: Boolean;
  public
    constructor Create(AKind: TTypeKind; ARead: TNimbusPropertyGridValueReader<T>; AWrite: TNimbusPropertyGridValueWriter<T>; ACanInsert: Boolean = True);
    function Matches(AObject: TObject): Boolean; override;
    function Count(AObject: TObject): Integer; override;
    function Kind(AObject: TObject): TTypeKind; override;
    function ReadValue(AObject: TObject; AIndex: Integer): Variant; override;
    procedure WriteValue(AObject: TObject; AIndex: Integer; const AValue: Variant); override;
    function CanWrite: Boolean; override;
    function CanChangeStructure: Boolean; override;
    procedure Add(AObject: TObject); override;
    procedure Delete(AObject: TObject; AIndex: Integer); override;
    procedure Move(AObject: TObject; AFrom, ATo: Integer); override;
  end;

procedure NimbusRegisterPropertyGridAdapter(AAdapter: TNimbusPropertyGridIndexedAdapter);
function NimbusFindPropertyGridAdapter(AObject: TObject): TNimbusPropertyGridIndexedAdapter;

implementation

var
  GAdapters: TObjectList<TNimbusPropertyGridIndexedAdapter>;

procedure NimbusRegisterPropertyGridAdapter(AAdapter: TNimbusPropertyGridIndexedAdapter);
begin
  if AAdapter = nil then raise EArgumentNilException.Create('Adapter');
  if GAdapters = nil then GAdapters := TObjectList<TNimbusPropertyGridIndexedAdapter>.Create(True);
  GAdapters.Add(AAdapter);
end;

function NimbusFindPropertyGridAdapter(AObject: TObject): TNimbusPropertyGridIndexedAdapter;
var
  I: Integer;
begin
  Result := nil;
  if (AObject = nil) or (GAdapters = nil) then Exit;
  for I := GAdapters.Count - 1 downto 0 do
    if GAdapters[I].Matches(AObject) then Exit(GAdapters[I]);
end;

procedure TNimbusPropertyGridIndexedAdapter.WriteValue(AObject: TObject; AIndex: Integer; const AValue: Variant);
begin
  raise EPropertyError.Create('Indexed value is read-only');
end;

function TNimbusPropertyGridIndexedAdapter.ObjectAt(AObject: TObject; AIndex: Integer): TPersistent;
begin
  Result := nil;
end;

function TNimbusPropertyGridIndexedAdapter.CanWrite: Boolean;
begin
  Result := False;
end;

function TNimbusPropertyGridIndexedAdapter.CanChangeStructure: Boolean;
begin
  Result := False;
end;

function TNimbusPropertyGridIndexedAdapter.CanReorder: Boolean;
begin
  Result := CanChangeStructure;
end;

procedure TNimbusPropertyGridIndexedAdapter.Add(AObject: TObject);
begin
  raise EPropertyError.Create('Insert is not supported');
end;

procedure TNimbusPropertyGridIndexedAdapter.Delete(AObject: TObject; AIndex: Integer);
begin
  raise EPropertyError.Create('Remove is not supported');
end;

procedure TNimbusPropertyGridIndexedAdapter.Move(AObject: TObject; AFrom, ATo: Integer);
begin
  raise EPropertyError.Create('Move is not supported');
end;

constructor TNimbusPropertyGridListAdapter<T>.Create(AKind: TTypeKind; ARead: TNimbusPropertyGridValueReader<T>; AWrite: TNimbusPropertyGridValueWriter<T>; ACanInsert: Boolean);
begin
  inherited Create;
  FKind := AKind;
  FRead := ARead;
  FWrite := AWrite;
  FCanInsert := ACanInsert;
  if not Assigned(FRead) then raise EArgumentNilException.Create('Reader');
end;

function TNimbusPropertyGridListAdapter<T>.Matches(AObject: TObject): Boolean;
begin
  Result := AObject is TList<T>;
end;

function TNimbusPropertyGridListAdapter<T>.Count(AObject: TObject): Integer;
begin
  Result := TList<T>(AObject).Count;
end;

function TNimbusPropertyGridListAdapter<T>.Kind(AObject: TObject): TTypeKind;
begin
  Result := FKind;
end;

function TNimbusPropertyGridListAdapter<T>.ReadValue(AObject: TObject; AIndex: Integer): Variant;
begin
  Result := FRead(TList<T>(AObject)[AIndex]);
end;

procedure TNimbusPropertyGridListAdapter<T>.WriteValue(AObject: TObject; AIndex: Integer; const AValue: Variant);
begin
  if not Assigned(FWrite) then inherited WriteValue(AObject, AIndex, AValue)
  else TList<T>(AObject)[AIndex] := FWrite(AValue);
end;

function TNimbusPropertyGridListAdapter<T>.CanWrite: Boolean;
begin
  Result := Assigned(FWrite);
end;

function TNimbusPropertyGridListAdapter<T>.CanChangeStructure: Boolean;
begin
  Result := Assigned(FWrite) and FCanInsert;
end;

procedure TNimbusPropertyGridListAdapter<T>.Add(AObject: TObject);
begin
  if not CanChangeStructure then inherited Add(AObject)
  else TList<T>(AObject).Add(Default(T));
end;

procedure TNimbusPropertyGridListAdapter<T>.Delete(AObject: TObject; AIndex: Integer);
begin
  if not CanChangeStructure then inherited Delete(AObject, AIndex)
  else TList<T>(AObject).Delete(AIndex);
end;

procedure TNimbusPropertyGridListAdapter<T>.Move(AObject: TObject; AFrom, ATo: Integer);
begin
  if not CanChangeStructure then inherited Move(AObject, AFrom, ATo)
  else TList<T>(AObject).Move(AFrom, ATo);
end;

function TNimbusPropertyGridObjectListAdapter<T>.Matches(AObject: TObject): Boolean;
begin
  Result := AObject is TObjectList<T>;
end;

function TNimbusPropertyGridObjectListAdapter<T>.Count(AObject: TObject): Integer;
begin
  if not Matches(AObject) then Exit(0);
  Result := TObjectList<T>(AObject).Count;
end;

function TNimbusPropertyGridObjectListAdapter<T>.Kind(AObject: TObject): TTypeKind;
begin
  Result := tkClass;
end;

function TNimbusPropertyGridObjectListAdapter<T>.ReadValue(AObject: TObject; AIndex: Integer): Variant;
var
  LItem: TPersistent;
begin
  LItem := ObjectAt(AObject, AIndex);
  if LItem = nil then Result := '(nil)' else Result := '(' + LItem.ClassName + ')';
end;

function TNimbusPropertyGridObjectListAdapter<T>.ObjectAt(AObject: TObject; AIndex: Integer): TPersistent;
begin
  Result := nil;
  if not Matches(AObject) then Exit;
  if (AIndex < 0) or (AIndex >= TObjectList<T>(AObject).Count) then Exit;
  Result := TObjectList<T>(AObject)[AIndex];
end;

function TNimbusPropertyGridObjectListAdapter<T>.CanReorder: Boolean;
begin
  Result := True;
end;

procedure TNimbusPropertyGridObjectListAdapter<T>.Move(AObject: TObject; AFrom, ATo: Integer);
var
  LList: TObjectList<T>;
  I: Integer;
begin
  if not Matches(AObject) then raise EPropertyError.Create('Object list type mismatch');
  LList := TObjectList<T>(AObject);
  if (AFrom < 0) or (ATo < 0) or (AFrom >= LList.Count) or (ATo >= LList.Count) then
    raise EArgumentOutOfRangeException.Create('AFrom');
  if AFrom < ATo then for I := AFrom to ATo - 1 do LList.Exchange(I, I + 1)
  else for I := AFrom downto ATo + 1 do LList.Exchange(I, I - 1);
end;

procedure TNimbusPropertyGridArray<T>.Load(const AValues: TArray<T>);
begin
  FValues := Copy(AValues);
end;

function TNimbusPropertyGridArray<T>.Values: TArray<T>;
begin
  Result := Copy(FValues);
end;

function TNimbusPropertyGridArray<T>.Count: Integer;
begin
  Result := Length(FValues);
end;

function TNimbusPropertyGridArray<T>.Item(AIndex: Integer): T;
begin
  Result := FValues[AIndex];
end;

procedure TNimbusPropertyGridArray<T>.SetItem(AIndex: Integer; const AValue: T);
begin
  FValues[AIndex] := AValue;
end;

procedure TNimbusPropertyGridArray<T>.Add(const AValue: T);
begin
  SetLength(FValues, Length(FValues) + 1);
  FValues[High(FValues)] := AValue;
end;

procedure TNimbusPropertyGridArray<T>.Delete(AIndex: Integer);
var
  I: Integer;
begin
  if (AIndex < 0) or (AIndex >= Length(FValues)) then raise ERangeError.Create('Invalid array index');
  for I := AIndex to High(FValues) - 1 do FValues[I] := FValues[I + 1];
  SetLength(FValues, Length(FValues) - 1);
end;

procedure TNimbusPropertyGridArray<T>.Move(AFrom, ATo: Integer);
var
  LValue: T;
  I: Integer;
begin
  if (AFrom < 0) or (AFrom >= Length(FValues)) or (ATo < 0) or (ATo >= Length(FValues)) then raise ERangeError.Create('Invalid array index');
  LValue := FValues[AFrom];
  if AFrom < ATo then for I := AFrom to ATo - 1 do FValues[I] := FValues[I + 1]
  else for I := AFrom downto ATo + 1 do FValues[I] := FValues[I - 1];
  FValues[ATo] := LValue;
end;

constructor TNimbusPropertyGridArrayAdapter<T>.Create(AKind: TTypeKind; ARead: TNimbusPropertyGridValueReader<T>; AWrite: TNimbusPropertyGridValueWriter<T>; ACanInsert: Boolean);
begin
  inherited Create;
  FKind := AKind;
  FRead := ARead;
  FWrite := AWrite;
  FCanInsert := ACanInsert;
  if not Assigned(FRead) then raise EArgumentNilException.Create('Reader');
end;

function TNimbusPropertyGridArrayAdapter<T>.Matches(AObject: TObject): Boolean;
begin
  Result := AObject is TNimbusPropertyGridArray<T>;
end;

function TNimbusPropertyGridArrayAdapter<T>.Count(AObject: TObject): Integer;
begin
  Result := TNimbusPropertyGridArray<T>(AObject).Count;
end;

function TNimbusPropertyGridArrayAdapter<T>.Kind(AObject: TObject): TTypeKind;
begin
  Result := FKind;
end;

function TNimbusPropertyGridArrayAdapter<T>.ReadValue(AObject: TObject; AIndex: Integer): Variant;
begin
  Result := FRead(TNimbusPropertyGridArray<T>(AObject).Item(AIndex));
end;

procedure TNimbusPropertyGridArrayAdapter<T>.WriteValue(AObject: TObject; AIndex: Integer; const AValue: Variant);
begin
  if not Assigned(FWrite) then inherited WriteValue(AObject, AIndex, AValue)
  else TNimbusPropertyGridArray<T>(AObject).SetItem(AIndex, FWrite(AValue));
end;

function TNimbusPropertyGridArrayAdapter<T>.CanWrite: Boolean;
begin
  Result := Assigned(FWrite);
end;

function TNimbusPropertyGridArrayAdapter<T>.CanChangeStructure: Boolean;
begin
  Result := Assigned(FWrite) and FCanInsert;
end;

procedure TNimbusPropertyGridArrayAdapter<T>.Add(AObject: TObject);
begin
  if not CanChangeStructure then inherited Add(AObject)
  else TNimbusPropertyGridArray<T>(AObject).Add(Default(T));
end;

procedure TNimbusPropertyGridArrayAdapter<T>.Delete(AObject: TObject; AIndex: Integer);
begin
  if not CanChangeStructure then inherited Delete(AObject, AIndex)
  else TNimbusPropertyGridArray<T>(AObject).Delete(AIndex);
end;

procedure TNimbusPropertyGridArrayAdapter<T>.Move(AObject: TObject; AFrom, ATo: Integer);
begin
  if not CanChangeStructure then inherited Move(AObject, AFrom, ATo)
  else TNimbusPropertyGridArray<T>(AObject).Move(AFrom, ATo);
end;
initialization
finalization
  GAdapters.Free;

end.

unit NimbusForms.Grid.DataSetController;

{$SCOPEDENUMS ON}

interface

uses
  System.SysUtils,
  System.Classes,
  System.Rtti,
  System.TypInfo,
  Data.DB,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.DataControllerBase;

type
  IThemedGridDataSetAccess = interface
    ['{B6D2A4F1-3E58-4C97-8A0B-9F1C6E2D7A35}']
    function ReadFieldValue(const AIndex: Integer; const AFieldName: string): TValue;
    function GetDataSet: TDataSet;
  end;

  IThemedGridDataSetRow = interface
    ['{E1C7F093-5A2D-4B68-91E4-2D8A0C6B3F57}']
    function GetIndex: Integer;
    function GetDataSet: TDataSet;
    function GetValue(const AFieldName: string): TValue;
    property Index: Integer read GetIndex;
    property DataSet: TDataSet read GetDataSet;
    property Values[const AFieldName: string]: TValue read GetValue; default;
  end;

  TThemedGridDataSetController = class sealed(TThemedGridDataControllerBase, IThemedGridDataSetAccess)
  private
    FDataSet: TDataSet;
    FWatcher: TComponent;
    function GetDataSetObject: TDataSet;
    function IThemedGridDataSetAccess.GetDataSet = GetDataSetObject;
    procedure DataSetRemoved;
    function ReadFieldValue(const AIndex: Integer; const AFieldName: string): TValue;
    function MoveTo(const AIndex: Integer): Boolean;
    function FindField(const AColumn: TThemedGridColumn): TField;
    class function GetFieldName(const AColumn: TThemedGridColumn): string; static;
  protected
    function GetDataSourceRowCount: Integer; override;
  public
    constructor Create(const ADataSet: TDataSet);
    destructor Destroy; override;
    function GetDataSource: TValue; override;
    function GetCanAddRows: Boolean; override;
    function GetCanRemoveRows: Boolean; override;
    function CreateRowObject: TValue; override;
    function CloneRowState(const ADataSourceIndex: Integer): TValue; override;
    function AddRow(const AInsertBeforeDataSourceIndex: Integer; const ARowState: TValue): Integer; override;
    function RemoveRow(const ADataSourceIndex: Integer): Boolean; override;
    function GetRowObject(const ADataSourceIndex: Integer): TValue; override;
    function GetValue(const ADataSourceIndex: Integer; const AColumn: TThemedGridColumn): TValue; override;
    procedure SetValue(const ADataSourceIndex: Integer; const AColumn: TThemedGridColumn; const AValue: TValue); override;
    function GetValueType(const AColumn: TThemedGridColumn): PTypeInfo; override;
    function CanSetValue(const AColumn: TThemedGridColumn): Boolean; override;
  end;

function ThemedGridFieldTypeInfo(const ADataType: TFieldType): PTypeInfo;
function ThemedGridFieldValueType(const AField: TField): PTypeInfo;
function ThemedGridFieldToValue(const AField: TField): TValue;

implementation

uses
  NimbusForms.Grid.DataStrings,
  NimbusForms.Grid.ValueConverter;

type
  TConv = TThemedGridValueConverter;

  TDataSetWatcher = class(TComponent)
  private
    FDataSet: TDataSet;
    FOnRemoved: TProc;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(const ADataSet: TDataSet; const AOnRemoved: TProc); reintroduce;
    destructor Destroy; override;
  end;

  TDataSetRow = class(TInterfacedObject, IThemedGridDataSetRow)
  private
    FAccess: IThemedGridDataSetAccess;
    FIndex: Integer;
    function GetIndex: Integer;
    function GetDataSet: TDataSet;
    function GetValue(const AFieldName: string): TValue;
  public
    constructor Create(const AAccess: IThemedGridDataSetAccess; const AIndex: Integer);
  end;

function ThemedGridFieldTypeInfo(const ADataType: TFieldType): PTypeInfo;
begin
  case ADataType of
    ftString, ftWideString, ftFixedChar, ftFixedWideChar, ftMemo, ftWideMemo, ftFmtMemo:
      Result := System.TypeInfo(string);
    ftSmallint, ftInteger, ftWord, ftAutoInc, ftShortint, ftByte:
      Result := System.TypeInfo(Integer);
    ftLargeint, ftLongWord:
      Result := System.TypeInfo(Int64);
    ftFloat, ftSingle, ftExtended:
      Result := System.TypeInfo(Double);
    ftCurrency, ftBCD, ftFMTBcd:
      Result := System.TypeInfo(Currency);
    ftBoolean:
      Result := System.TypeInfo(Boolean);
    ftDate, ftTime, ftDateTime, ftTimeStamp:
      Result := System.TypeInfo(TDateTime);
    ftGuid:
      Result := System.TypeInfo(TGUID);
    ftBlob, ftGraphic, ftBytes, ftVarBytes:
      Result := System.TypeInfo(TBytes);
  else
    Result := nil;
  end;
end;

function ThemedGridFieldValueType(const AField: TField): PTypeInfo;
begin
  if AField = nil then
    Exit(nil);
  Result := ThemedGridFieldTypeInfo(AField.DataType);
end;

function ThemedGridFieldToValue(const AField: TField): TValue;
var
  LType: PTypeInfo;
begin
  if (AField = nil) or AField.IsNull then
    Exit(TValue.Empty);
  LType := ThemedGridFieldValueType(AField);
  if LType = System.TypeInfo(string) then
    Exit(TValue.From<string>(AField.AsString));
  if LType = System.TypeInfo(Integer) then
    Exit(TValue.From<Integer>(AField.AsInteger));
  if LType = System.TypeInfo(Int64) then
    Exit(TValue.From<Int64>(AField.AsLargeInt));
  if LType = System.TypeInfo(Double) then
    Exit(TValue.From<Double>(AField.AsFloat));
  if LType = System.TypeInfo(Currency) then
    Exit(TValue.From<Currency>(AField.AsCurrency));
  if LType = System.TypeInfo(Boolean) then
    Exit(TValue.From<Boolean>(AField.AsBoolean));
  if LType = System.TypeInfo(TDateTime) then
    Exit(TValue.From<TDateTime>(AField.AsDateTime));
  if (LType = System.TypeInfo(TGUID)) and (AField is TGuidField) then
    Exit(TValue.From<TGUID>(TGuidField(AField).AsGuid));
  if LType = System.TypeInfo(TBytes) then
    Exit(TValue.From<TBytes>(AField.AsBytes));
  Result := TValue.FromVariant(AField.AsVariant);
end;

procedure AssignFieldValue(const AField: TField; const AValue: TValue);
var
  LType: PTypeInfo;
  LConverted: TValue;
begin
  if TConv.IsNull(AValue) then
  begin
    AField.Clear;
    Exit;
  end;
  LType := ThemedGridFieldValueType(AField);
  if not TConv.TryConvert(AValue, LType, LConverted) then
    raise EConvertError.Create(ThemedGridDataStrings.ErrCannotConvert);
  if LType = System.TypeInfo(Integer) then
    AField.AsInteger := Integer(LConverted.AsOrdinal)
  else if LType = System.TypeInfo(Int64) then
    AField.AsLargeInt := LConverted.AsInt64
  else if LType = System.TypeInfo(Double) then
    AField.AsFloat := LConverted.AsExtended
  else if LType = System.TypeInfo(Currency) then
    AField.AsCurrency := LConverted.AsCurrency
  else if LType = System.TypeInfo(Boolean) then
    AField.AsBoolean := LConverted.AsBoolean
  else if LType = System.TypeInfo(TDateTime) then
    AField.AsDateTime := LConverted.AsType<TDateTime>
  else if (LType = System.TypeInfo(TGUID)) and (AField is TGuidField) then
    TGuidField(AField).AsGuid := LConverted.AsType<TGUID>
  else if LType = System.TypeInfo(TBytes) then
    AField.AsBytes := LConverted.AsType<TBytes>
  else
    AField.AsString := TConv.ToText(LConverted);
end;


constructor TDataSetWatcher.Create(const ADataSet: TDataSet; const AOnRemoved: TProc);
begin
  inherited Create(nil);
  FDataSet := ADataSet;
  FOnRemoved := AOnRemoved;
  FDataSet.FreeNotification(Self);
end;

destructor TDataSetWatcher.Destroy;
begin
  if FDataSet <> nil then
    FDataSet.RemoveFreeNotification(Self);
  inherited Destroy;
end;

procedure TDataSetWatcher.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FDataSet) then
  begin
    FDataSet := nil;
    if Assigned(FOnRemoved) then
      FOnRemoved();
  end;
end;


constructor TDataSetRow.Create(const AAccess: IThemedGridDataSetAccess; const AIndex: Integer);
begin
  inherited Create;
  FAccess := AAccess;
  FIndex := AIndex;
end;

function TDataSetRow.GetIndex: Integer;
begin
  Result := FIndex;
end;

function TDataSetRow.GetDataSet: TDataSet;
begin
  Result := FAccess.GetDataSet;
end;

function TDataSetRow.GetValue(const AFieldName: string): TValue;
begin
  Result := FAccess.ReadFieldValue(FIndex, AFieldName);
end;


constructor TThemedGridDataSetController.Create(const ADataSet: TDataSet);
begin
  if ADataSet = nil then
    raise EArgumentNilException.Create('dataSet');
  if ADataSet.IsUniDirectional then
    raise ENotSupportedException.Create(ThemedGridDataStrings.ErrDataSourceNotSupported);
  inherited Create;
  FDataSet := ADataSet;
  FWatcher := TDataSetWatcher.Create(ADataSet,
    procedure
    begin
      DataSetRemoved;
    end);
end;

destructor TThemedGridDataSetController.Destroy;
begin
  FWatcher.Free;
  inherited Destroy;
end;

procedure TThemedGridDataSetController.DataSetRemoved;
begin
  FDataSet := nil;
  ResetIndex;
end;

function TThemedGridDataSetController.GetDataSetObject: TDataSet;
begin
  Result := FDataSet;
end;

function TThemedGridDataSetController.GetDataSourceRowCount: Integer;
begin
  if (FDataSet = nil) or (not FDataSet.Active) then
    Exit(0);
  Result := FDataSet.RecordCount;
end;

function TThemedGridDataSetController.GetDataSource: TValue;
begin
  Result := TValue.From<TObject>(FDataSet);
end;

function TThemedGridDataSetController.MoveTo(const AIndex: Integer): Boolean;
begin
  Result := False;
  if (FDataSet = nil) or (not FDataSet.Active) then
    Exit;
  if (AIndex < 0) or (AIndex >= FDataSet.RecordCount) then
    Exit;
  try
    if FDataSet.RecNo <> AIndex + 1 then
      FDataSet.RecNo := AIndex + 1;
    Result := FDataSet.RecNo = AIndex + 1;
  except
    on Exception do
      Result := False;
  end;
end;

class function TThemedGridDataSetController.GetFieldName(const AColumn: TThemedGridColumn): string;
begin
  if AColumn.FieldName <> '' then
    Result := AColumn.FieldName
  else
    Result := AColumn.Name;
end;

function TThemedGridDataSetController.FindField(const AColumn: TThemedGridColumn): TField;
var
  LName: string;
begin
  Result := nil;
  if (FDataSet = nil) or (AColumn = nil) then
    Exit;
  LName := GetFieldName(AColumn);
  if LName = '' then
    Exit;
  Result := FDataSet.FindField(LName);
end;

function TThemedGridDataSetController.ReadFieldValue(const AIndex: Integer; const AFieldName: string): TValue;
var
  LField: TField;
begin
  if (FDataSet = nil) or (AFieldName = '') or (not MoveTo(AIndex)) then
    Exit(TValue.Empty);
  LField := FDataSet.FindField(AFieldName);
  if LField = nil then
    Exit(TValue.Empty);
  Result := ThemedGridFieldToValue(LField);
end;

function TThemedGridDataSetController.GetCanAddRows: Boolean;
begin
  Result := (FDataSet <> nil) and FDataSet.Active and FDataSet.CanModify;
end;

function TThemedGridDataSetController.GetCanRemoveRows: Boolean;
begin
  Result := (FDataSet <> nil) and FDataSet.Active and FDataSet.CanModify;
end;

function TThemedGridDataSetController.CreateRowObject: TValue;
begin
  Result := TValue.Empty;
end;

function TThemedGridDataSetController.CloneRowState(const ADataSourceIndex: Integer): TValue;
var
  LValues: TArray<TValue>;
  I: Integer;
begin
  if (FDataSet = nil) or (not MoveTo(ADataSourceIndex)) then
    Exit(TValue.Empty);
  SetLength(LValues, FDataSet.FieldCount);
  for I := 0 to FDataSet.FieldCount - 1 do
    LValues[I] := ThemedGridFieldToValue(FDataSet.Fields[I]);
  Result := TValue.From<TArray<TValue>>(LValues);
end;

function TThemedGridDataSetController.AddRow(const AInsertBeforeDataSourceIndex: Integer;
  const ARowState: TValue): Integer;
var
  LValues: TArray<TValue>;
  LField: TField;
  I: Integer;
begin
  Result := -1;
  if not GetCanAddRows then
    Exit;
  try
    if (AInsertBeforeDataSourceIndex >= 0) and (AInsertBeforeDataSourceIndex < FDataSet.RecordCount) and
       MoveTo(AInsertBeforeDataSourceIndex) then
      FDataSet.Insert
    else
      FDataSet.Append;
    try
      if (ARowState.TypeInfo = System.TypeInfo(TArray<TValue>)) then
      begin
        LValues := ARowState.AsType<TArray<TValue>>;
        if Length(LValues) = FDataSet.FieldCount then
          for I := 0 to FDataSet.FieldCount - 1 do
          begin
            LField := FDataSet.Fields[I];
            if LField.ReadOnly or (LField.DataType = ftAutoInc) then
              Continue;
            AssignFieldValue(LField, LValues[I]);
          end;
      end;
      FDataSet.Post;
    except
      if FDataSet.State in dsEditModes then
        FDataSet.Cancel;
      raise;
    end;
    Touch;
    Result := FDataSet.RecNo - 1;
  except
    on Exception do
      Result := -1;
  end;
end;

function TThemedGridDataSetController.RemoveRow(const ADataSourceIndex: Integer): Boolean;
begin
  Result := False;
  if not GetCanRemoveRows then
    Exit;
  if not MoveTo(ADataSourceIndex) then
    Exit;
  try
    FDataSet.Delete;
    Touch;
    Result := True;
  except
    on Exception do
      Result := False;
  end;
end;

function TThemedGridDataSetController.GetRowObject(const ADataSourceIndex: Integer): TValue;
var
  LRow: IThemedGridDataSetRow;
begin
  if (FDataSet = nil) or (not FDataSet.Active) or (ADataSourceIndex < 0) or
     (ADataSourceIndex >= FDataSet.RecordCount) then
    Exit(TValue.Empty);
  LRow := TDataSetRow.Create(Self, ADataSourceIndex);
  Result := TValue.From<IThemedGridDataSetRow>(LRow);
end;

function TThemedGridDataSetController.GetValue(const ADataSourceIndex: Integer;
  const AColumn: TThemedGridColumn): TValue;
var
  LRow: TValue;
  LField: TField;
begin
  if AColumn = nil then
    Exit(TValue.Empty);
  if Assigned(AColumn.ValueGetter) then
  begin
    LRow := GetRowObject(ADataSourceIndex);
    if TConv.IsNull(LRow) then
      Exit(TValue.Empty);
    Exit(AColumn.ValueGetter(LRow));
  end;
  LField := FindField(AColumn);
  if (LField = nil) or (not MoveTo(ADataSourceIndex)) then
    Exit(TValue.Empty);
  Result := ThemedGridFieldToValue(LField);
end;

procedure TThemedGridDataSetController.SetValue(const ADataSourceIndex: Integer;
  const AColumn: TThemedGridColumn; const AValue: TValue);
var
  LRow: TValue;
  LField: TField;
begin
  if AColumn = nil then
    Exit;
  if Assigned(AColumn.ValueSetter) then
  begin
    LRow := GetRowObject(ADataSourceIndex);
    if TConv.IsNull(LRow) then
      Exit;
    try
      AColumn.ValueSetter(LRow, AValue);
      RefreshIndexAfterValueChanged;
    except
      on Exception do
        ;
    end;
    Exit;
  end;
  LField := FindField(AColumn);
  if (LField = nil) or LField.ReadOnly or (FDataSet = nil) or (not FDataSet.CanModify) then
    Exit;
  if not MoveTo(ADataSourceIndex) then
    Exit;
  try
    FDataSet.Edit;
    try
      AssignFieldValue(LField, AValue);
      FDataSet.Post;
    except
      if FDataSet.State in dsEditModes then
        FDataSet.Cancel;
      raise;
    end;
    RefreshIndexAfterValueChanged;
  except
    on Exception do
      ;
  end;
end;

function TThemedGridDataSetController.GetValueType(const AColumn: TThemedGridColumn): PTypeInfo;
begin
  if AColumn = nil then
    Exit(nil);
  if AColumn.ValueType <> nil then
    Exit(AColumn.ValueType);
  Result := ThemedGridFieldValueType(FindField(AColumn));
end;

function TThemedGridDataSetController.CanSetValue(const AColumn: TThemedGridColumn): Boolean;
var
  LField: TField;
begin
  if AColumn = nil then
    Exit(False);
  if AColumn.ReadOnly then
    Exit(False);
  if Assigned(AColumn.ValueSetter) then
    Exit(True);
  LField := FindField(AColumn);
  Result := (LField <> nil) and (not LField.ReadOnly) and (FDataSet <> nil) and FDataSet.CanModify;
end;

end.

unit NimbusForms.Grid.ListDataController;

{$SCOPEDENUMS ON}

interface

uses
  System.SysUtils,
  System.Rtti,
  System.TypInfo,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.RowList,
  NimbusForms.Grid.DataControllerIntf,
  NimbusForms.Grid.DataControllerBase;

type
  TThemedGridListDataController = class sealed(TThemedGridDataControllerBase, IThemedGridRowStateOwner)
  private
    FList: IThemedGridRowList;
    class function GetFieldName(const AColumn: TThemedGridColumn): string; static;
  protected
    function GetDataSourceRowCount: Integer; override;
  public
    constructor Create(const AList: IThemedGridRowList);
    function GetDataSource: TValue; override;
    function GetCanMoveRows: Boolean; override;
    function MoveRow(const AFromDataSourceIndex, AToDataSourceIndex: Integer): Boolean; override;
    function GetCanAddRows: Boolean; override;
    function GetCanRemoveRows: Boolean; override;
    function CreateRowObject: TValue; override;
    function CloneRowState(const ADataSourceIndex: Integer): TValue; override;
    function AddRow(const AInsertBeforeDataSourceIndex: Integer; const ARowState: TValue): Integer; override;
    function RemoveRow(const ADataSourceIndex: Integer): Boolean; override;
    function GetOwnsRemovedRows: Boolean;
    procedure DisposeRowState(const ARowState: TValue);
    function GetRowObject(const ADataSourceIndex: Integer): TValue; override;
    function GetValue(const ADataSourceIndex: Integer; const AColumn: TThemedGridColumn): TValue; override;
    procedure SetValue(const ADataSourceIndex: Integer; const AColumn: TThemedGridColumn; const AValue: TValue); override;
    function GetValueType(const AColumn: TThemedGridColumn): PTypeInfo; override;
    function CanSetValue(const AColumn: TThemedGridColumn): Boolean; override;
  end;

implementation

uses
  NimbusForms.Grid.DataStrings,
  NimbusForms.Grid.ValueConverter,
  NimbusForms.Grid.ValueAccessor;

type
  TConv = TThemedGridValueConverter;

constructor TThemedGridListDataController.Create(const AList: IThemedGridRowList);
begin
  if AList = nil then
    raise EArgumentNilException.Create(ThemedGridDataStrings.ErrListRequired);
  inherited Create;
  FList := AList;
end;

function TThemedGridListDataController.GetDataSourceRowCount: Integer;
begin
  Result := FList.Count;
end;

function TThemedGridListDataController.GetDataSource: TValue;
begin
  Result := FList.Source;
end;

class function TThemedGridListDataController.GetFieldName(const AColumn: TThemedGridColumn): string;
begin
  if AColumn.FieldName <> '' then
    Result := AColumn.FieldName
  else
    Result := AColumn.Name;
end;

function TThemedGridListDataController.GetCanMoveRows: Boolean;
begin
  Result := (not FList.IsReadOnly) and (not FList.IsFixedSize) and (not GetIsSorted);
end;

function TThemedGridListDataController.MoveRow(const AFromDataSourceIndex, AToDataSourceIndex: Integer): Boolean;
begin
  if not GetCanMoveRows then
    Exit(False);
  if (AFromDataSourceIndex < 0) or (AFromDataSourceIndex >= FList.Count) then
    Exit(False);
  if (AToDataSourceIndex < 0) or (AToDataSourceIndex > FList.Count - 1) then
    Exit(False);
  if AFromDataSourceIndex = AToDataSourceIndex then
    Exit(False);
  FList.Move(AFromDataSourceIndex, AToDataSourceIndex);
  Touch;
  Result := True;
end;

function TThemedGridListDataController.GetCanAddRows: Boolean;
begin
  Result := (not FList.IsReadOnly) and (not FList.IsFixedSize);
end;

function TThemedGridListDataController.GetCanRemoveRows: Boolean;
begin
  Result := (not FList.IsReadOnly) and (not FList.IsFixedSize);
end;

function TThemedGridListDataController.CreateRowObject: TValue;
begin
  Result := FList.CreateItem;
end;

function TThemedGridListDataController.CloneRowState(const ADataSourceIndex: Integer): TValue;
begin
  Result := GetRowObject(ADataSourceIndex);
end;

function TThemedGridListDataController.AddRow(const AInsertBeforeDataSourceIndex: Integer;
  const ARowState: TValue): Integer;
var
  LRow: TValue;
  LIndex: Integer;
begin
  if not GetCanAddRows then
    Exit(-1);
  LRow := ARowState;
  if TConv.IsNull(LRow) then
    LRow := CreateRowObject;
  if TConv.IsNull(LRow) then
    Exit(-1);
  LIndex := AInsertBeforeDataSourceIndex;
  if (LIndex < 0) or (LIndex > FList.Count) then
    LIndex := FList.Count;
  FList.Insert(LIndex, LRow);
  Touch;
  Result := LIndex;
end;

function TThemedGridListDataController.RemoveRow(const ADataSourceIndex: Integer): Boolean;
begin
  if not GetCanRemoveRows then
    Exit(False);
  if (ADataSourceIndex < 0) or (ADataSourceIndex >= FList.Count) then
    Exit(False);
  FList.Extract(ADataSourceIndex);
  Touch;
  Result := True;
end;

function TThemedGridListDataController.GetOwnsRemovedRows: Boolean;
begin
  Result := FList.OwnsItems;
end;

procedure TThemedGridListDataController.DisposeRowState(const ARowState: TValue);
begin
  if ARowState.IsObject then
    ARowState.AsObject.Free;
end;

function TThemedGridListDataController.GetRowObject(const ADataSourceIndex: Integer): TValue;
begin
  if (ADataSourceIndex < 0) or (ADataSourceIndex >= FList.Count) then
    Exit(TValue.Empty);
  Result := FList[ADataSourceIndex];
end;

function TThemedGridListDataController.GetValue(const ADataSourceIndex: Integer;
  const AColumn: TThemedGridColumn): TValue;
var
  LRow, LValue: TValue;
  LField: string;
  LAccessor: IThemedGridValueAccessor;
begin
  if AColumn = nil then
    Exit(TValue.Empty);
  LRow := GetRowObject(ADataSourceIndex);
  if TConv.IsNull(LRow) then
    Exit(TValue.Empty);
  if Assigned(AColumn.ValueGetter) then
    Exit(AColumn.ValueGetter(LRow));
  LField := GetFieldName(AColumn);
  if LField = '' then
    Exit(TValue.Empty);
  LAccessor := TThemedGridValueAccessorCache.GetAccessor(LRow, LField);
  if not LAccessor.CanRead then
    Exit(TValue.Empty);
  LValue := LAccessor.GetValue(LRow);
  if TConv.IsNull(LValue) then
    Exit(TValue.Empty);
  Result := LValue;
end;

procedure TThemedGridListDataController.SetValue(const ADataSourceIndex: Integer;
  const AColumn: TThemedGridColumn; const AValue: TValue);
var
  LRow, LConverted: TValue;
  LField: string;
  LAccessor: IThemedGridValueAccessor;
begin
  if AColumn = nil then
    Exit;
  LRow := GetRowObject(ADataSourceIndex);
  if TConv.IsNull(LRow) then
    Exit;
  if Assigned(AColumn.ValueSetter) then
  begin
    AColumn.ValueSetter(LRow, AValue);
    RefreshIndexAfterValueChanged;
    Exit;
  end;
  LField := GetFieldName(AColumn);
  if LField = '' then
    Exit;
  LAccessor := TThemedGridValueAccessorCache.GetAccessor(LRow, LField);
  if not LAccessor.CanWrite then
    Exit;
  if LAccessor.IsDictionary then
    LConverted := AValue
  else
    LConverted := TConv.Convert(AValue, LAccessor.ValueType);
  LAccessor.SetValue(LRow, LConverted);
  RefreshIndexAfterValueChanged;
end;

function TThemedGridListDataController.GetValueType(const AColumn: TThemedGridColumn): PTypeInfo;
var
  I: Integer;
  LRow, LValue: TValue;
  LField: string;
  LAccessor: IThemedGridValueAccessor;
begin
  if AColumn = nil then
    Exit(nil);
  if AColumn.ValueType <> nil then
    Exit(AColumn.ValueType);
  LField := GetFieldName(AColumn);
  if LField = '' then
    Exit(nil);
  for I := 0 to FList.Count - 1 do
  begin
    LRow := FList[I];
    if TConv.IsNull(LRow) then
      Continue;
    LAccessor := TThemedGridValueAccessorCache.GetAccessor(LRow, LField);
    if not LAccessor.CanRead then
      Continue;
    if not LAccessor.IsDictionary then
      Exit(LAccessor.ValueType);
    LValue := LAccessor.GetValue(LRow);
    if not TConv.IsNull(LValue) then
      Exit(ThemedGridRuntimeTypeOf(LValue));
  end;
  Result := nil;
end;

function TThemedGridListDataController.CanSetValue(const AColumn: TThemedGridColumn): Boolean;
var
  I: Integer;
  LRow: TValue;
  LField: string;
begin
  if AColumn = nil then
    Exit(False);
  if AColumn.ReadOnly then
    Exit(False);
  if Assigned(AColumn.ValueSetter) then
    Exit(True);
  LField := GetFieldName(AColumn);
  if LField = '' then
    Exit(False);
  for I := 0 to FList.Count - 1 do
  begin
    LRow := FList[I];
    if TConv.IsNull(LRow) then
      Continue;
    Exit(TThemedGridValueAccessorCache.GetAccessor(LRow, LField).CanWrite);
  end;
  Result := False;
end;

end.

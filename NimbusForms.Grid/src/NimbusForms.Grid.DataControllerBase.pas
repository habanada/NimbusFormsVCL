unit NimbusForms.Grid.DataControllerBase;

{$SCOPEDENUMS ON}

interface

uses
  System.SysUtils,
  System.Rtti,
  System.TypInfo,
  System.Generics.Collections,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.FilterDescriptor,
  NimbusForms.Grid.FilterEvaluator,
  NimbusForms.Grid.DataControllerIntf;

type
  TThemedGridDataControllerBase = class(TInterfacedObject, IThemedGridDataController)
  private
    FFilterEvaluator: TThemedGridFilterEvaluator;
    FFilters: TObjectList<TThemedGridFilterDescriptor>;
    FVisibleToDataSourceIndex: TList<Integer>;
    FDataSourceToVisibleIndex: TArray<Integer>;
    FSortColumn: TThemedGridColumn;
    FSortDirection: TThemedGridSortDirection;
    FVersion: Integer;
    FIndexValid: Boolean;
    FLastDataSourceRowCount: Integer;
    function RemoveFilter(const AColumnName: string): Boolean;
    function PrepareFilterClone(const AFilter: TThemedGridFilterDescriptor): TThemedGridFilterDescriptor;
    procedure EnsureIndex;
    procedure RebuildIndex;
    function MatchesFilters(const ADataSourceIndex: Integer): Boolean;
    function CompareDataSourceIndexes(const ALeft, ARight: Integer): Integer;
  protected
    function GetDataSourceRowCount: Integer; virtual; abstract;
    procedure Touch;
    procedure ResetIndex;
    procedure RefreshIndexAfterValueChanged;
    function CompareValues(const ALeft, ARight: TValue): Integer; virtual;
  public
    constructor Create;
    destructor Destroy; override;
    function GetRowCount: Integer;
    function GetDataSource: TValue; virtual; abstract;
    function GetIsSorted: Boolean;
    function GetSortColumn: TThemedGridColumn;
    function GetSortDirection: TThemedGridSortDirection;
    function GetIsFiltered: Boolean;
    function GetFilters: TArray<TThemedGridFilterDescriptor>;
    function GetVersion: Integer;
    function GetCanMoveRows: Boolean; virtual;
    function GetCanAddRows: Boolean; virtual;
    function GetCanRemoveRows: Boolean; virtual;
    function GetRowObject(const ADataSourceIndex: Integer): TValue; virtual; abstract;
    function GetValue(const ADataSourceIndex: Integer; const AColumn: TThemedGridColumn): TValue; virtual; abstract;
    procedure SetValue(const ADataSourceIndex: Integer; const AColumn: TThemedGridColumn; const AValue: TValue); virtual; abstract;
    function GetValueType(const AColumn: TThemedGridColumn): PTypeInfo; virtual; abstract;
    function CanSetValue(const AColumn: TThemedGridColumn): Boolean; virtual; abstract;
    function MoveRow(const AFromDataSourceIndex, AToDataSourceIndex: Integer): Boolean; virtual;
    function CreateRowObject: TValue; virtual;
    function CloneRowState(const ADataSourceIndex: Integer): TValue; virtual;
    function AddRow(const AInsertBeforeDataSourceIndex: Integer; const ARowState: TValue): Integer; virtual;
    function RemoveRow(const ADataSourceIndex: Integer): Boolean; virtual;
    function GetDataSourceIndex(const AVisibleRowIndex: Integer): Integer;
    function GetVisibleRowIndex(const ADataSourceIndex: Integer): Integer;
    procedure ApplySort(const AColumn: TThemedGridColumn; const ADirection: TThemedGridSortDirection);
    procedure ClearSort;
    procedure ApplyFilter(const AFilter: TThemedGridFilterDescriptor);
    procedure ApplyFilters(const AFilters: array of TThemedGridFilterDescriptor);
    procedure ClearFilter(const AColumnName: string);
    procedure ClearFilters;
    procedure Refresh;
  end;

implementation

uses
  System.Math,
  System.Generics.Defaults,
  NimbusForms.Grid.ValueConverter;

constructor TThemedGridDataControllerBase.Create;
begin
  inherited Create;
  FFilterEvaluator := TThemedGridFilterEvaluator.Create;
  FFilters := TObjectList<TThemedGridFilterDescriptor>.Create(True);
  FVisibleToDataSourceIndex := TList<Integer>.Create;
  FLastDataSourceRowCount := -1;
end;

destructor TThemedGridDataControllerBase.Destroy;
begin
  FVisibleToDataSourceIndex.Free;
  FFilters.Free;
  FFilterEvaluator.Free;
  inherited Destroy;
end;

function TThemedGridDataControllerBase.GetRowCount: Integer;
begin
  EnsureIndex;
  Result := FVisibleToDataSourceIndex.Count;
end;

function TThemedGridDataControllerBase.GetIsSorted: Boolean;
begin
  Result := (FSortColumn <> nil) and (FSortDirection <> TThemedGridSortDirection.None);
end;

function TThemedGridDataControllerBase.GetSortColumn: TThemedGridColumn;
begin
  Result := FSortColumn;
end;

function TThemedGridDataControllerBase.GetSortDirection: TThemedGridSortDirection;
begin
  Result := FSortDirection;
end;

function TThemedGridDataControllerBase.GetIsFiltered: Boolean;
begin
  Result := FFilters.Count > 0;
end;

function TThemedGridDataControllerBase.GetFilters: TArray<TThemedGridFilterDescriptor>;
var
  I: Integer;
begin
  SetLength(Result, FFilters.Count);
  for I := 0 to FFilters.Count - 1 do
    Result[I] := FFilters[I];
end;

function TThemedGridDataControllerBase.GetVersion: Integer;
begin
  Result := FVersion;
end;

function TThemedGridDataControllerBase.GetCanMoveRows: Boolean;
begin
  Result := False;
end;

function TThemedGridDataControllerBase.GetCanAddRows: Boolean;
begin
  Result := False;
end;

function TThemedGridDataControllerBase.GetCanRemoveRows: Boolean;
begin
  Result := False;
end;

function TThemedGridDataControllerBase.MoveRow(const AFromDataSourceIndex, AToDataSourceIndex: Integer): Boolean;
begin
  Result := False;
end;

function TThemedGridDataControllerBase.CreateRowObject: TValue;
begin
  Result := TValue.Empty;
end;

function TThemedGridDataControllerBase.CloneRowState(const ADataSourceIndex: Integer): TValue;
begin
  Result := TValue.Empty;
end;

function TThemedGridDataControllerBase.AddRow(const AInsertBeforeDataSourceIndex: Integer;
  const ARowState: TValue): Integer;
begin
  Result := -1;
end;

function TThemedGridDataControllerBase.RemoveRow(const ADataSourceIndex: Integer): Boolean;
begin
  Result := False;
end;

function TThemedGridDataControllerBase.GetDataSourceIndex(const AVisibleRowIndex: Integer): Integer;
begin
  EnsureIndex;
  if (AVisibleRowIndex < 0) or (AVisibleRowIndex >= FVisibleToDataSourceIndex.Count) then
    Exit(-1);
  Result := FVisibleToDataSourceIndex[AVisibleRowIndex];
end;

function TThemedGridDataControllerBase.GetVisibleRowIndex(const ADataSourceIndex: Integer): Integer;
begin
  EnsureIndex;
  if (ADataSourceIndex < 0) or (ADataSourceIndex >= Length(FDataSourceToVisibleIndex)) then
    Exit(-1);
  Result := FDataSourceToVisibleIndex[ADataSourceIndex];
end;

procedure TThemedGridDataControllerBase.ApplySort(const AColumn: TThemedGridColumn;
  const ADirection: TThemedGridSortDirection);
begin
  if ADirection = TThemedGridSortDirection.None then
    FSortColumn := nil
  else
    FSortColumn := AColumn;
  FSortDirection := ADirection;
  RebuildIndex;
end;

procedure TThemedGridDataControllerBase.ClearSort;
begin
  FSortColumn := nil;
  FSortDirection := TThemedGridSortDirection.None;
  RebuildIndex;
end;

function TThemedGridDataControllerBase.PrepareFilterClone(const AFilter: TThemedGridFilterDescriptor): TThemedGridFilterDescriptor;
begin
  Result := nil;
  if (AFilter = nil) or (not AFilter.IsActive) then
    Exit;
  if (AFilter.ColumnName = '') and (AFilter.Column <> nil) then
    AFilter.ColumnName := AFilter.Column.Name;
  if AFilter.ColumnName = '' then
    Exit;
  Result := AFilter.Clone;
end;

function TThemedGridDataControllerBase.RemoveFilter(const AColumnName: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := FFilters.Count - 1 downto 0 do
    if SameText(FFilters[I].ColumnName, AColumnName) then
    begin
      FFilters.Delete(I);
      Result := True;
    end;
end;

procedure TThemedGridDataControllerBase.ApplyFilter(const AFilter: TThemedGridFilterDescriptor);
var
  LClone: TThemedGridFilterDescriptor;
begin
  LClone := PrepareFilterClone(AFilter);
  if LClone = nil then
    Exit;
  RemoveFilter(LClone.ColumnName);
  FFilters.Add(LClone);
  RebuildIndex;
end;

procedure TThemedGridDataControllerBase.ApplyFilters(const AFilters: array of TThemedGridFilterDescriptor);
var
  LClones: TList<TThemedGridFilterDescriptor>;
  LClone: TThemedGridFilterDescriptor;
  I: Integer;
begin
  LClones := TList<TThemedGridFilterDescriptor>.Create;
  try
    for I := 0 to High(AFilters) do
    begin
      LClone := PrepareFilterClone(AFilters[I]);
      if LClone <> nil then
        LClones.Add(LClone);
    end;
    FFilters.Clear;
    for I := 0 to LClones.Count - 1 do
    begin
      RemoveFilter(LClones[I].ColumnName);
      FFilters.Add(LClones[I]);
    end;
  finally
    LClones.Free;
  end;
  RebuildIndex;
end;

procedure TThemedGridDataControllerBase.ClearFilter(const AColumnName: string);
begin
  if AColumnName = '' then
    Exit;
  if not RemoveFilter(AColumnName) then
    Exit;
  RebuildIndex;
end;

procedure TThemedGridDataControllerBase.ClearFilters;
begin
  if FFilters.Count = 0 then
    Exit;
  FFilters.Clear;
  RebuildIndex;
end;

procedure TThemedGridDataControllerBase.Refresh;
begin
  RebuildIndex;
end;

procedure TThemedGridDataControllerBase.Touch;
begin
  FIndexValid := False;
  Inc(FVersion);
end;

procedure TThemedGridDataControllerBase.ResetIndex;
begin
  FVisibleToDataSourceIndex.Clear;
  SetLength(FDataSourceToVisibleIndex, 0);
  FIndexValid := False;
  Touch;
end;

procedure TThemedGridDataControllerBase.RefreshIndexAfterValueChanged;
begin
end;

procedure TThemedGridDataControllerBase.EnsureIndex;
var
  LCount: Integer;
begin
  LCount := Max(0, GetDataSourceRowCount);
  if FIndexValid and (FLastDataSourceRowCount = LCount) then
    Exit;
  RebuildIndex;
end;

procedure TThemedGridDataControllerBase.RebuildIndex;
var
  LCount, I, LDataSourceIndex: Integer;
begin
  LCount := Max(0, GetDataSourceRowCount);
  FVisibleToDataSourceIndex.Clear;
  for I := 0 to LCount - 1 do
    if MatchesFilters(I) then
      FVisibleToDataSourceIndex.Add(I);

  if GetIsSorted then
    FVisibleToDataSourceIndex.Sort(TComparer<Integer>.Construct(
      function(const ALeft, ARight: Integer): Integer
      begin
        Result := CompareDataSourceIndexes(ALeft, ARight);
      end));

  SetLength(FDataSourceToVisibleIndex, LCount);
  for I := 0 to High(FDataSourceToVisibleIndex) do
    FDataSourceToVisibleIndex[I] := -1;
  for I := 0 to FVisibleToDataSourceIndex.Count - 1 do
  begin
    LDataSourceIndex := FVisibleToDataSourceIndex[I];
    if (LDataSourceIndex >= 0) and (LDataSourceIndex < Length(FDataSourceToVisibleIndex)) then
      FDataSourceToVisibleIndex[LDataSourceIndex] := I;
  end;
  FLastDataSourceRowCount := LCount;
  FIndexValid := True;
  Inc(FVersion);
end;

function TThemedGridDataControllerBase.MatchesFilters(const ADataSourceIndex: Integer): Boolean;
var
  I: Integer;
  LFilter: TThemedGridFilterDescriptor;
  LColumn: TThemedGridColumn;
begin
  if FFilters.Count = 0 then
    Exit(True);
  for I := 0 to FFilters.Count - 1 do
  begin
    LFilter := FFilters[I];
    if (LFilter = nil) or (not LFilter.IsActive) then
      Continue;
    LColumn := LFilter.Column;
    if LColumn = nil then
      Exit(False);
    if not FFilterEvaluator.Matches(GetValue(ADataSourceIndex, LColumn), GetValueType(LColumn), LFilter) then
      Exit(False);
  end;
  Result := True;
end;

function TThemedGridDataControllerBase.CompareDataSourceIndexes(const ALeft, ARight: Integer): Integer;
begin
  Result := CompareValues(GetValue(ALeft, FSortColumn), GetValue(ARight, FSortColumn));
  if FSortDirection = TThemedGridSortDirection.Descending then
    Result := -Result;
  if Result = 0 then
    Result := CompareValue(ALeft, ARight);
end;

function TThemedGridDataControllerBase.CompareValues(const ALeft, ARight: TValue): Integer;
begin
  Result := TThemedGridValueConverter.Compare(ALeft, ARight);
end;

end.

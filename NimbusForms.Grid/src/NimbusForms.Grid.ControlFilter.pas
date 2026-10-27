unit NimbusForms.Grid.ControlFilter;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  System.Types,
  System.Rtti,
  System.TypInfo,
  System.Generics.Collections,
  Vcl.Controls,
  Vcl.Forms,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.Events,
  NimbusForms.Grid.FilterDescriptor,
  NimbusForms.Grid.ControlSearch;

type
  TThemedGridControlFilter = class(TThemedGridControlSearch)
  private
    FOwnedFilters: TObjectList<TThemedGridFilterDescriptor>;
    FOnColumnFilterChanged: TThemedGridColumnFilterEvent;
    FOnFilterChanged: TThemedGridFilterChangedEvent;
    function ResolveFilterColumn(const AFilter: TThemedGridFilterDescriptor): TThemedGridColumn;
    function ResolveFilterValueType(const AColumn: TThemedGridColumn): PTypeInfo;
    procedure SetColumnFilter(const AColumn: TThemedGridColumn; const AFilter: TThemedGridFilterDescriptor);
    procedure RefreshAfterFilterChange;
    function GetFilterSourceValue(const ARowIndex: Integer; const AColumnName: string): TValue;
  protected
    procedure DataSourceReset; override;
    procedure ShowColumnFilterPopup(const AColumnIndex: Integer; const AColumn: TThemedGridColumn;
      const AFilter: TThemedGridFilterDescriptor); override;
    procedure DoColumnFilterChanged(const AColumn: TThemedGridColumn; const AColumnIndex: Integer;
      const AFilter: TThemedGridFilterDescriptor); virtual;
    procedure DoFilterChanged; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyFilter(const AColumnName: string; const AOperator: TThemedGridFilterOperator;
      const AValue: TValue); overload;
    procedure ApplyFilter(const AFilter: TThemedGridFilterDescriptor); overload;
    procedure ApplyBetweenFilter(const AColumnName: string; const AValue, AValue2: TValue);
    procedure ClearFilter(const AColumnName: string);
    procedure ClearFilters;
    property OnColumnFilterChanged: TThemedGridColumnFilterEvent
      read FOnColumnFilterChanged write FOnColumnFilterChanged;
    property OnFilterChanged: TThemedGridFilterChangedEvent read FOnFilterChanged write FOnFilterChanged;
  end;

implementation

uses
  NimbusForms.Grid.DistinctValue,
  NimbusForms.Grid.DistinctValueProvider,
  NimbusForms.Grid.HeaderFilterPopup,
  NimbusForms.Grid.GridFilter;

type
  TFilterValueSource = class(TInterfacedObject, IThemedGridValueSource)
  private
    FOwner: TThemedGridControlFilter;
  public
    constructor Create(const AOwner: TThemedGridControlFilter);
    function GetRowCount: Integer;
    function GetValue(const ARowIndex: Integer; const AColumnName: string): TValue;
    function GetCacheIdentity: NativeInt;
  end;

function IsEmptyBounds(const ARect: TRect): Boolean;
begin
  Result := (ARect.Right <= ARect.Left) or (ARect.Bottom <= ARect.Top);
end;

constructor TFilterValueSource.Create(const AOwner: TThemedGridControlFilter);
begin
  inherited Create;
  FOwner := AOwner;
end;

function TFilterValueSource.GetRowCount: Integer;
begin
  Result := FOwner.RowCount;
end;

function TFilterValueSource.GetValue(const ARowIndex: Integer; const AColumnName: string): TValue;
begin
  Result := FOwner.GetFilterSourceValue(ARowIndex, AColumnName);
end;

function TFilterValueSource.GetCacheIdentity: NativeInt;
begin
  Result := NativeInt(FOwner);
end;

constructor TThemedGridControlFilter.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOwnedFilters := TObjectList<TThemedGridFilterDescriptor>.Create(True);
end;

destructor TThemedGridControlFilter.Destroy;
var
  I: Integer;
begin
  for I := 0 to Columns.Count - 1 do
    if Columns[I] <> nil then
      Columns[I].Filter := nil;
  FOwnedFilters.Free;
  inherited Destroy;
end;

procedure TThemedGridControlFilter.DataSourceReset;
var
  I: Integer;
begin
  inherited DataSourceReset;
  if FOwnedFilters = nil then
    Exit;
  for I := 0 to Columns.Count - 1 do
    if Columns[I] <> nil then
    begin
      Columns[I].Filter := nil;
      Columns[I].IsFiltered := False;
    end;
  FOwnedFilters.Clear;
end;

function TThemedGridControlFilter.GetFilterSourceValue(const ARowIndex: Integer; const AColumnName: string): TValue;
var
  LDataSourceIndex: Integer;
  LColumn: TThemedGridColumn;
begin
  Result := TValue.Empty;
  if DataController = nil then
    Exit;
  LDataSourceIndex := GetViewRowDataSourceIndex(ARowIndex);
  if LDataSourceIndex < 0 then
    Exit;
  LColumn := Columns.FindByName(AColumnName);
  if LColumn = nil then
    Exit;
  Result := DataController.GetValue(LDataSourceIndex, LColumn);
end;

function TThemedGridControlFilter.ResolveFilterColumn(const AFilter: TThemedGridFilterDescriptor): TThemedGridColumn;
begin
  Result := nil;
  if AFilter = nil then
    Exit;
  if AFilter.Column <> nil then
    Exit(AFilter.Column);
  if AFilter.ColumnName <> '' then
    Result := GetColumn(AFilter.ColumnName);
end;

function TThemedGridControlFilter.ResolveFilterValueType(const AColumn: TThemedGridColumn): PTypeInfo;
begin
  Result := nil;
  if AColumn = nil then
    Exit;
  Result := AColumn.ValueType;
  if (Result = nil) and (DataController <> nil) then
    Result := DataController.GetValueType(AColumn);
end;

procedure TThemedGridControlFilter.SetColumnFilter(const AColumn: TThemedGridColumn;
  const AFilter: TThemedGridFilterDescriptor);
var
  LOld: TObject;
begin
  if AColumn = nil then
  begin
    AFilter.Free;
    Exit;
  end;
  LOld := AColumn.Filter;
  AColumn.Filter := AFilter;
  AColumn.IsFiltered := AFilter <> nil;
  if AFilter <> nil then
    FOwnedFilters.Add(AFilter);
  if (LOld <> nil) and (LOld <> AFilter) and (LOld is TThemedGridFilterDescriptor) then
    FOwnedFilters.Remove(TThemedGridFilterDescriptor(LOld));
end;

procedure TThemedGridControlFilter.RefreshAfterFilterChange;
begin
  InvalidateSummaryCache;
  FirstVisibleRowIndex := 0;
  CurrentRowIndex := -1;
  CurrentColumnIndex := -1;
  TThemedGridDistinctValueProvider.ClearCache;
  CheckRowsChanged;
  NormalizeScrollValues;
  RunSearch;
end;

procedure TThemedGridControlFilter.ApplyFilter(const AColumnName: string; const AOperator: TThemedGridFilterOperator;
  const AValue: TValue);
var
  LFilter: TThemedGridFilterDescriptor;
begin
  LFilter := TThemedGridFilter.Make(AColumnName, AOperator, AValue);
  try
    ApplyFilter(LFilter);
  finally
    LFilter.Free;
  end;
end;

procedure TThemedGridControlFilter.ApplyBetweenFilter(const AColumnName: string; const AValue, AValue2: TValue);
var
  LFilter: TThemedGridFilterDescriptor;
begin
  LFilter := TThemedGridFilter.Between(AColumnName, AValue, AValue2);
  try
    ApplyFilter(LFilter);
  finally
    LFilter.Free;
  end;
end;

procedure TThemedGridControlFilter.ApplyFilter(const AFilter: TThemedGridFilterDescriptor);
var
  LColumn: TThemedGridColumn;
  LColumnIndex: Integer;
  LRequestClone, LApplied, LEventClone: TThemedGridFilterDescriptor;
  LArgs: TThemedGridColumnFilterEventArgs;
begin
  if (AFilter = nil) or not AFilter.IsActive then
    Exit;
  LColumn := ResolveFilterColumn(AFilter);
  if (LColumn = nil) or not LColumn.AllowFilter then
    Exit;
  LColumnIndex := GetColumnIndex(LColumn);
  LRequestClone := AFilter.Clone;
  try
    LArgs := TThemedGridColumnFilterEventArgs.Create(LColumn, LColumnIndex, LRequestClone);
    try
      DoColumnFilterRequested(LArgs);
      if LArgs.Cancel then
        Exit;
      LApplied := LArgs.Filter;
    finally
      LArgs.Free;
    end;
    if (LApplied = nil) or not LApplied.IsActive then
      Exit;
    if LApplied.ColumnName = '' then
      LApplied.ColumnName := LColumn.Name;
    LApplied.Column := LColumn;
    SetColumnFilter(LColumn, LApplied.Clone);
    if DataController <> nil then
    begin
      DataController.ApplyFilter(LApplied);
      RefreshAfterFilterChange;
    end;
    LEventClone := LApplied.Clone;
    try
      DoColumnFilterChanged(LColumn, LColumnIndex, LEventClone);
    finally
      LEventClone.Free;
    end;
    DoFilterChanged;
    Invalidate;
  finally
    LRequestClone.Free;
  end;
end;

procedure TThemedGridControlFilter.ClearFilter(const AColumnName: string);
var
  LColumn: TThemedGridColumn;
begin
  if AColumnName = '' then
    Exit;
  LColumn := GetColumn(AColumnName);
  if LColumn <> nil then
    SetColumnFilter(LColumn, nil);
  if DataController <> nil then
  begin
    DataController.ClearFilter(AColumnName);
    RefreshAfterFilterChange;
  end;
  if LColumn <> nil then
    DoColumnFilterChanged(LColumn, GetColumnIndex(LColumn), nil);
  DoFilterChanged;
  Invalidate;
end;

procedure TThemedGridControlFilter.ClearFilters;
begin
  ClearColumnFilterStates;
  FOwnedFilters.Clear;
  if DataController <> nil then
  begin
    DataController.ClearFilters;
    RefreshAfterFilterChange;
  end;
  DoFilterChanged;
  Invalidate;
end;

procedure TThemedGridControlFilter.ShowColumnFilterPopup(const AColumnIndex: Integer;
  const AColumn: TThemedGridColumn; const AFilter: TThemedGridFilterDescriptor);
var
  LButton: TRect;
  LPopup: TThemedGridHeaderFilterPopup;
  LSource: IThemedGridValueSource;
  LLoader: TThemedGridDistinctValueLoader;
  LColumn: TThemedGridColumn;
  LVersion: Integer;
  LForm: TCustomForm;
  LBelow, LAbove: TPoint;
  LWork: TRect;
begin
  if AColumn = nil then
    Exit;
  LColumn := AColumn;
  LButton := GetColumnFilterButtonBounds(AColumnIndex);
  if IsEmptyBounds(LButton) then
    LButton := GetHeaderCellBounds(AColumnIndex);
  LSource := TFilterValueSource.Create(Self);
  LLoader :=
    function: TObjectList<TThemedGridDistinctValue>
    begin
      if DataController <> nil then
        LVersion := DataController.Version
      else
        LVersion := -1;
      Result := TThemedGridDistinctValueProvider.GetValues(LSource, LColumn, LVersion, 100000, 1000);
    end;

  LPopup := TThemedGridHeaderFilterPopup.CreatePopup(Self, LColumn, ResolveFilterValueType(LColumn), AFilter,
    LLoader, CurrentPPI);
  try
    if Palette <> nil then
      LPopup.ApplyTheme(Palette);
    LBelow := ClientToScreen(Point(LButton.Left, LButton.Bottom));
    LAbove := ClientToScreen(Point(LButton.Left, LButton.Top));
    LWork := Screen.MonitorFromPoint(LBelow).WorkareaRect;
    LPopup.Left := LBelow.X;
    LPopup.Top := LBelow.Y;
    if LPopup.Left + LPopup.Width > LWork.Right then
      LPopup.Left := LWork.Right - LPopup.Width;
    if LPopup.Top + LPopup.Height > LWork.Bottom then
      LPopup.Top := LAbove.Y - LPopup.Height;
    if LPopup.Left < LWork.Left then
      LPopup.Left := LWork.Left;
    if LPopup.Top < LWork.Top then
      LPopup.Top := LWork.Top;
    LForm := GetParentForm(Self);
    if LForm <> nil then
    begin
      LPopup.PopupMode := pmExplicit;
      LPopup.PopupParent := LForm;
    end;
    if LPopup.ShowModal <> mrOk then
      Exit;
    if LPopup.ClearRequested then
    begin
      ClearFilter(LColumn.Name);
      Exit;
    end;
    if (LPopup.Filter = nil) or not LPopup.Filter.IsActive then
      Exit;
    ApplyFilter(LPopup.Filter);
  finally
    LPopup.Free;
  end;
end;

procedure TThemedGridControlFilter.DoColumnFilterChanged(const AColumn: TThemedGridColumn;
  const AColumnIndex: Integer; const AFilter: TThemedGridFilterDescriptor);
var
  LArgs: TThemedGridColumnFilterEventArgs;
begin
  if not Assigned(FOnColumnFilterChanged) then
    Exit;
  LArgs := TThemedGridColumnFilterEventArgs.Create(AColumn, AColumnIndex, AFilter);
  try
    FOnColumnFilterChanged(Self, LArgs);
  finally
    LArgs.Free;
  end;
end;

procedure TThemedGridControlFilter.DoFilterChanged;
var
  LArgs: TThemedGridFilterChangedEventArgs;
  LCount: Integer;
begin
  if not Assigned(FOnFilterChanged) then
    Exit;
  if DataController <> nil then
    LCount := Length(DataController.Filters)
  else
    LCount := 0;
  LArgs := TThemedGridFilterChangedEventArgs.Create(LCount, RowCount);
  try
    FOnFilterChanged(Self, LArgs);
  finally
    LArgs.Free;
  end;
end;

end.

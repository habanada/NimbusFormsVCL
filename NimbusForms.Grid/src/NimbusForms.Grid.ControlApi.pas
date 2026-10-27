unit NimbusForms.Grid.ControlApi;

{$SCOPEDENUMS ON}

interface

uses
  System.Classes,
  System.SysUtils,
  System.Types,
  System.Rtti,
  System.Generics.Collections,
  System.Generics.Defaults,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Primitives,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.Cell,
  NimbusForms.Grid.Row,
  NimbusForms.Grid.ViewRow,
  NimbusForms.Grid.HitInfo,
  NimbusForms.Grid.Events,
  NimbusForms.Grid.FormatStyle,
  NimbusForms.Grid.FormatCondition,
  NimbusForms.Grid.ExportData,
  NimbusForms.Grid.ExportOptions,
  NimbusForms.Grid.ClipboardExporter,
  NimbusForms.Grid.ControlFormatConditions;

type
  TThemedGridControlApi = class(TThemedGridControlFormatConditions)
  private
    FSuppressColumnVisibleEvent: Boolean;
    FOnColumnVisibleChanged: TThemedGridColumnVisibleChangedEvent;
    procedure SetColumnFixedStyleCore(const AColumn: TThemedGridColumn; const AFixedStyle: TThemedGridColumnFixedStyle);
    procedure SetColumnFixedStyle(const AColumn: TThemedGridColumn; const AFixedStyle: TThemedGridColumnFixedStyle);
    procedure FinishFixedColumnUpdate;
    function CreateExportColumns(const AData: TThemedGridExportData;
      const AOptions: TThemedGridExportOptions): TList<TThemedGridColumn>;
    function GetAllColumnsForExport: TList<TThemedGridColumn>;
    procedure AddGroupExportRow(const AData: TThemedGridExportData; const AExportColumns: TList<TThemedGridColumn>;
      const AViewRow: TThemedGridViewRow; const ARowIndex: Integer; const AOptions: TThemedGridExportOptions);
    procedure FillExportCell(const ACell: TThemedGridCell; const ARow: TThemedGridRow;
      const ARowIndex, AExportColumnIndex, ADataSourceIndex: Integer; const ARowObject: TValue;
      const AColumn: TThemedGridColumn);
    function BuildExportData(const AOptions: TThemedGridExportOptions): TThemedGridExportData;
    function BuildExportOptions(const AOptions: TThemedGridExportOptions;
      out AOwned: TThemedGridExportOptions): TThemedGridExportOptions;
    class function CompareExportColumns(const ALeft, ARight: TThemedGridColumn): Integer; static;
    class function GetExportHeaderText(const AColumn: TThemedGridColumn): string; static;
    class function GetExportCellText(const ACell: TThemedGridCell): string; static;
  private
    function GetCurrentCellAddress: TThemedGridCurrentCell;
    function GetHasRows: Boolean;
  protected
    procedure DoColumnVisibleChanged(const AColumn: TThemedGridColumn; const AColumnIndex: Integer;
      const AVisible: Boolean); virtual;
  public
    function AddRowFormatCondition(const AColumnName: string; const AOperator: TThemedGridFormatConditionOperator;
      const AValue: TValue; const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition;
    function AddBetweenFormatCondition(const AColumnName: string; const AValue, AValue2: TValue;
      const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition;
    function AddInFormatCondition(const AColumnName: string; const AValues: array of TValue;
      const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition;
    function AddNotInFormatCondition(const AColumnName: string; const AValues: array of TValue;
      const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition;
    function AddCustomFormatCondition(const APredicate: TThemedGridFormatConditionPredicate;
      const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition;
    procedure EnableFormatConditions;
    procedure DisableFormatConditions;
    procedure SetFormatConditionsEnabled(const AEnabled: Boolean);
    procedure EnableAllFormatConditions;
    procedure DisableAllFormatConditions;
    procedure SetAllFormatConditionsEnabled(const AEnabled: Boolean);
    procedure SetColumnVisible(const AColumnName: string; const AVisible: Boolean); overload;
    procedure SetColumnVisible(const AColumn: TThemedGridColumn; const AVisible: Boolean); overload;
    procedure ShowColumn(const AColumnName: string);
    procedure HideColumn(const AColumnName: string);
    procedure ShowAllColumns;
    procedure HideAllColumns;
    procedure SetAllColumnsVisible(const AVisible: Boolean);
    procedure SetColumnBand(const AColumnName, ABandName: string);
    procedure ClearColumnBands;
    procedure AutoCreateColumnBands;
    procedure FreezeColumn(const AColumnName: string; const AFixedStyle: TThemedGridColumnFixedStyle); overload;
    procedure FreezeColumn(const AColumnIndex: Integer; const AFixedStyle: TThemedGridColumnFixedStyle); overload;
    procedure UnfreezeColumn(const AColumnName: string); overload;
    procedure UnfreezeColumn(const AColumnIndex: Integer); overload;
    procedure FreezeColumnsLeft(const ACount: Integer);
    procedure FreezeColumnsRight(const ACount: Integer);
    procedure ClearFrozenColumns;
    function GetColumnAt(const AX: Integer): TThemedGridColumn;
    function GetRowAt(const AY: Integer): TThemedGridRow;
    function GetCellAt(const AX, AY: Integer): TThemedGridCell; overload;
    function GetCellAt(const ALocation: TPoint): TThemedGridCell; overload;
    function GetCellTag(const ARowIndex, AColumnIndex: Integer): TValue;
    procedure SetCellTag(const ARowIndex, AColumnIndex: Integer; const ATag: TValue);
    function CreateExportData: TThemedGridExportData; overload;
    function CreateExportData(const AOptions: TThemedGridExportOptions): TThemedGridExportData; overload;
    function ExportToCsv: string; overload;
    function ExportToCsv(const AOptions: TThemedGridExportOptions): string; overload;
    function ExportToJson: string; overload;
    function ExportToJson(const AOptions: TThemedGridExportOptions): string; overload;
    function ExportToHtml: string; overload;
    function ExportToHtml(const AOptions: TThemedGridExportOptions): string; overload;
    function CreateClipboardPayload: TThemedGridClipboardPayload; overload;
    function CreateClipboardPayload(const AOptions: TThemedGridExportOptions): TThemedGridClipboardPayload; overload;
    procedure CopyExportToClipboard; overload;
    procedure CopyExportToClipboard(const AOptions: TThemedGridExportOptions); overload;
    property CurrentCellAddress: TThemedGridCurrentCell read GetCurrentCellAddress;
    property HasRows: Boolean read GetHasRows;
    property FixedLeftWidth: Integer read GetFixedLeftWidth;
    property FixedRightWidth: Integer read GetFixedRightWidth;
    property ScrollableColumnsWidth: Integer read GetScrollableColumnsWidth;
    property OnColumnVisibleChanged: TThemedGridColumnVisibleChangedEvent
      read FOnColumnVisibleChanged write FOnColumnVisibleChanged;
  end;

implementation

uses
  NimbusForms.Grid.CellMetadata,
  NimbusForms.Grid.Export;

function TThemedGridControlApi.GetCurrentCellAddress: TThemedGridCurrentCell;
begin
  Result := SelectionModel.CurrentCell;
end;

function TThemedGridControlApi.GetHasRows: Boolean;
begin
  Result := RowCount > 0;
end;

function TThemedGridControlApi.AddRowFormatCondition(const AColumnName: string;
  const AOperator: TThemedGridFormatConditionOperator; const AValue: TValue;
  const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition;
begin
  Result := FormatConditions.AddRow(AColumnName, AOperator, AValue, AStyle);
end;

function TThemedGridControlApi.AddBetweenFormatCondition(const AColumnName: string; const AValue, AValue2: TValue;
  const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition;
begin
  Result := FormatConditions.AddBetween(AColumnName, AValue, AValue2, AStyle);
end;

function TThemedGridControlApi.AddInFormatCondition(const AColumnName: string; const AValues: array of TValue;
  const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition;
begin
  Result := FormatConditions.AddIn(AColumnName, AValues, AStyle);
end;

function TThemedGridControlApi.AddNotInFormatCondition(const AColumnName: string; const AValues: array of TValue;
  const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition;
begin
  Result := FormatConditions.AddNotIn(AColumnName, AValues, AStyle);
end;

function TThemedGridControlApi.AddCustomFormatCondition(const APredicate: TThemedGridFormatConditionPredicate;
  const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition;
begin
  Result := FormatConditions.AddCustom(APredicate, AStyle);
end;

procedure TThemedGridControlApi.EnableFormatConditions;
begin
  FormatConditionsEnabled := True;
end;

procedure TThemedGridControlApi.DisableFormatConditions;
begin
  FormatConditionsEnabled := False;
end;

procedure TThemedGridControlApi.SetFormatConditionsEnabled(const AEnabled: Boolean);
begin
  FormatConditionsEnabled := AEnabled;
end;

procedure TThemedGridControlApi.EnableAllFormatConditions;
begin
  FormatConditions.EnableAll;
end;

procedure TThemedGridControlApi.DisableAllFormatConditions;
begin
  FormatConditions.DisableAll;
end;

procedure TThemedGridControlApi.SetAllFormatConditionsEnabled(const AEnabled: Boolean);
begin
  FormatConditions.SetAllConditionEnabled(AEnabled);
end;

procedure TThemedGridControlApi.DoColumnVisibleChanged(const AColumn: TThemedGridColumn;
  const AColumnIndex: Integer; const AVisible: Boolean);
var
  LArgs: TThemedGridColumnVisibleChangedEventArgs;
begin
  if not Assigned(FOnColumnVisibleChanged) then
    Exit;
  LArgs := TThemedGridColumnVisibleChangedEventArgs.Create(AColumn, AColumnIndex, AVisible);
  try
    FOnColumnVisibleChanged(Self, LArgs);
  finally
    LArgs.Free;
  end;
end;

procedure TThemedGridControlApi.SetColumnVisible(const AColumnName: string; const AVisible: Boolean);
var
  LColumn: TThemedGridColumn;
begin
  LColumn := GetColumn(AColumnName);
  if LColumn = nil then
    Exit;
  SetColumnVisible(LColumn, AVisible);
end;

procedure TThemedGridControlApi.SetColumnVisible(const AColumn: TThemedGridColumn; const AVisible: Boolean);
var
  LColumnIndex: Integer;
begin
  if AColumn = nil then
    Exit;
  LColumnIndex := Columns.IndexOf(AColumn);
  if AColumn.Visible = AVisible then
    Exit;
  AColumn.Visible := AVisible;
  if not FSuppressColumnVisibleEvent then
    DoColumnVisibleChanged(AColumn, LColumnIndex, AVisible);
  NormalizeScrollValues;
  Invalidate;
end;

procedure TThemedGridControlApi.ShowColumn(const AColumnName: string);
begin
  SetColumnVisible(AColumnName, True);
end;

procedure TThemedGridControlApi.HideColumn(const AColumnName: string);
begin
  SetColumnVisible(AColumnName, False);
end;

procedure TThemedGridControlApi.ShowAllColumns;
begin
  SetAllColumnsVisible(True);
end;

procedure TThemedGridControlApi.HideAllColumns;
begin
  SetAllColumnsVisible(False);
end;

procedure TThemedGridControlApi.SetAllColumnsVisible(const AVisible: Boolean);
var
  I: Integer;
begin
  FSuppressColumnVisibleEvent := True;
  try
    for I := 0 to Columns.Count - 1 do
      SetColumnVisible(Columns[I], AVisible);
  finally
    FSuppressColumnVisibleEvent := False;
  end;
  NormalizeScrollValues;
  Invalidate;
end;

procedure TThemedGridControlApi.SetColumnBand(const AColumnName, ABandName: string);
var
  LColumn: TThemedGridColumn;
begin
  LColumn := GetColumn(AColumnName);
  if LColumn = nil then
    Exit;
  if LColumn.BandName = ABandName then
    Exit;
  LColumn.BandName := ABandName;
  NormalizeScrollValues;
  Invalidate;
end;

procedure TThemedGridControlApi.ClearColumnBands;
var
  I: Integer;
begin
  for I := 0 to Columns.Count - 1 do
    Columns[I].BandName := '';
  NormalizeScrollValues;
  Invalidate;
end;

procedure TThemedGridControlApi.AutoCreateColumnBands;
var
  I: Integer;
  LBandName: string;
begin
  ColumnBands.Clear;
  for I := 0 to Columns.Count - 1 do
  begin
    LBandName := Columns[I].BandName;
    if LBandName = '' then
      Continue;
    if not ColumnBands.Contains(LBandName) then
      ColumnBands.Add(LBandName, LBandName);
  end;
  NormalizeScrollValues;
  Invalidate;
end;

procedure TThemedGridControlApi.SetColumnFixedStyleCore(const AColumn: TThemedGridColumn;
  const AFixedStyle: TThemedGridColumnFixedStyle);
begin
  if AColumn = nil then
    Exit;
  if AColumn.FixedStyle = AFixedStyle then
    Exit;
  AColumn.FixedStyle := AFixedStyle;
end;

procedure TThemedGridControlApi.FinishFixedColumnUpdate;
begin
  NormalizeScrollValues;
  if CurrentColumnIndex >= 0 then
    EnsureVisible(CurrentRowIndex, CurrentColumnIndex);
  Invalidate;
end;

procedure TThemedGridControlApi.SetColumnFixedStyle(const AColumn: TThemedGridColumn;
  const AFixedStyle: TThemedGridColumnFixedStyle);
begin
  if AColumn = nil then
    Exit;
  SetColumnFixedStyleCore(AColumn, AFixedStyle);
  FinishFixedColumnUpdate;
end;

procedure TThemedGridControlApi.FreezeColumn(const AColumnName: string;
  const AFixedStyle: TThemedGridColumnFixedStyle);
begin
  SetColumnFixedStyle(GetColumn(AColumnName), AFixedStyle);
end;

procedure TThemedGridControlApi.FreezeColumn(const AColumnIndex: Integer;
  const AFixedStyle: TThemedGridColumnFixedStyle);
begin
  SetColumnFixedStyle(GetColumn(AColumnIndex), AFixedStyle);
end;

procedure TThemedGridControlApi.UnfreezeColumn(const AColumnName: string);
begin
  FreezeColumn(AColumnName, TThemedGridColumnFixedStyle.None);
end;

procedure TThemedGridControlApi.UnfreezeColumn(const AColumnIndex: Integer);
begin
  FreezeColumn(AColumnIndex, TThemedGridColumnFixedStyle.None);
end;

procedure TThemedGridControlApi.FreezeColumnsLeft(const ACount: Integer);
var
  LVisible: TList<TThemedGridColumn>;
  LCount: Integer;
  I: Integer;
begin
  LVisible := Columns.GetVisibleColumns;
  try
    LCount := ACount;
    if LCount < 0 then
      LCount := 0;
    if LCount > LVisible.Count then
      LCount := LVisible.Count;
    for I := 0 to LVisible.Count - 1 do
      if I < LCount then
        SetColumnFixedStyleCore(LVisible[I], TThemedGridColumnFixedStyle.Left)
      else
        SetColumnFixedStyleCore(LVisible[I], TThemedGridColumnFixedStyle.None);
  finally
    LVisible.Free;
  end;
  FinishFixedColumnUpdate;
end;

procedure TThemedGridControlApi.FreezeColumnsRight(const ACount: Integer);
var
  LVisible: TList<TThemedGridColumn>;
  LCount: Integer;
  LFirstRight: Integer;
  I: Integer;
begin
  LVisible := Columns.GetVisibleColumns;
  try
    LCount := ACount;
    if LCount < 0 then
      LCount := 0;
    if LCount > LVisible.Count then
      LCount := LVisible.Count;
    LFirstRight := LVisible.Count - LCount;
    for I := 0 to LVisible.Count - 1 do
      if I >= LFirstRight then
        SetColumnFixedStyleCore(LVisible[I], TThemedGridColumnFixedStyle.Right)
      else
        SetColumnFixedStyleCore(LVisible[I], TThemedGridColumnFixedStyle.None);
  finally
    LVisible.Free;
  end;
  FinishFixedColumnUpdate;
end;

procedure TThemedGridControlApi.ClearFrozenColumns;
var
  LVisible: TList<TThemedGridColumn>;
  I: Integer;
begin
  LVisible := Columns.GetVisibleColumns;
  try
    for I := 0 to LVisible.Count - 1 do
      SetColumnFixedStyleCore(LVisible[I], TThemedGridColumnFixedStyle.None);
  finally
    LVisible.Free;
  end;
  FinishFixedColumnUpdate;
end;

function TThemedGridControlApi.GetColumnAt(const AX: Integer): TThemedGridColumn;
var
  LHit: TThemedGridHitInfo;
begin
  LHit := HitTest(Point(AX, DataBounds.Top + 1));
  try
    Result := LHit.Column;
  finally
    LHit.Free;
  end;
end;

function TThemedGridControlApi.GetRowAt(const AY: Integer): TThemedGridRow;
var
  LHit: TThemedGridHitInfo;
begin
  Result := nil;
  LHit := HitTest(Point(DataBounds.Left + 1, AY));
  try
    if LHit.Row <> nil then
      Result := GetRow(LHit.RowIndex);
  finally
    LHit.Free;
  end;
end;

function TThemedGridControlApi.GetCellAt(const ALocation: TPoint): TThemedGridCell;
var
  LHit: TThemedGridHitInfo;
begin
  Result := nil;
  LHit := HitTest(ALocation);
  try
    if LHit.Cell <> nil then
      Result := GetCell(LHit.RowIndex, LHit.ColumnIndex);
  finally
    LHit.Free;
  end;
end;

function TThemedGridControlApi.GetCellAt(const AX, AY: Integer): TThemedGridCell;
begin
  Result := GetCellAt(Point(AX, AY));
end;

function TThemedGridControlApi.GetCellTag(const ARowIndex, AColumnIndex: Integer): TValue;
var
  LCell: TThemedGridCell;
  LMetadata: TThemedGridCellMetadata;
begin
  Result := TValue.Empty;
  LCell := GetCell(ARowIndex, AColumnIndex);
  if LCell = nil then
    Exit;
  try
    LMetadata := GetMetadata(LCell.DataSourceIndex, LCell.Column.Name, False);
    if LMetadata <> nil then
      Result := LMetadata.Tag;
  finally
    LCell.Free;
  end;
end;

procedure TThemedGridControlApi.SetCellTag(const ARowIndex, AColumnIndex: Integer; const ATag: TValue);
var
  LCell: TThemedGridCell;
  LMetadata: TThemedGridCellMetadata;
begin
  LCell := GetCell(ARowIndex, AColumnIndex);
  if LCell = nil then
    Exit;
  try
    LMetadata := GetMetadata(LCell.DataSourceIndex, LCell.Column.Name, True);
    LMetadata.Tag := ATag;
  finally
    LCell.Free;
  end;
  InvalidateCell(ARowIndex, AColumnIndex);
end;

class function TThemedGridControlApi.CompareExportColumns(const ALeft, ARight: TThemedGridColumn): Integer;
var
  LLeftIndex: Integer;
  LRightIndex: Integer;
begin
  if ALeft = ARight then
    Exit(0);
  if ALeft = nil then
    Exit(-1);
  if ARight = nil then
    Exit(1);
  if ALeft.VisibleIndex >= 0 then
    LLeftIndex := ALeft.VisibleIndex
  else
    LLeftIndex := MaxInt;
  if ARight.VisibleIndex >= 0 then
    LRightIndex := ARight.VisibleIndex
  else
    LRightIndex := MaxInt;
  if LLeftIndex < LRightIndex then
    Exit(-1);
  if LLeftIndex > LRightIndex then
    Exit(1);
  Result := CompareText(ALeft.Name, ARight.Name);
end;

class function TThemedGridControlApi.GetExportHeaderText(const AColumn: TThemedGridColumn): string;
begin
  if AColumn = nil then
    Exit('');
  if AColumn.HeaderText <> '' then
    Exit(AColumn.HeaderText);
  if AColumn.Name <> '' then
    Exit(AColumn.Name);
  Result := AColumn.FieldName;
end;

class function TThemedGridControlApi.GetExportCellText(const ACell: TThemedGridCell): string;
begin
  Result := '';
  if ACell = nil then
    Exit;
  if ACell.DisplayText <> '' then
    Exit(ACell.DisplayText);
  if not ACell.DisplayValue.IsEmpty then
    Exit(ACell.DisplayValue.ToString);
  if not ACell.Value.IsEmpty then
    Result := ACell.Value.ToString;
end;

function TThemedGridControlApi.GetAllColumnsForExport: TList<TThemedGridColumn>;
var
  I: Integer;
begin
  Result := TList<TThemedGridColumn>.Create;
  for I := 0 to Columns.Count - 1 do
    if Columns[I] <> nil then
      Result.Add(Columns[I]);
  Result.Sort(TComparer<TThemedGridColumn>.Construct(
    function(const ALeft, ARight: TThemedGridColumn): Integer
    begin
      Result := CompareExportColumns(ALeft, ARight);
    end));
end;

function TThemedGridControlApi.CreateExportColumns(const AData: TThemedGridExportData;
  const AOptions: TThemedGridExportOptions): TList<TThemedGridColumn>;
var
  LSource: TList<TThemedGridColumn>;
  LColumn: TThemedGridColumn;
  LExportColumn: TThemedGridExportColumn;
  I: Integer;
begin
  if AOptions.IncludeHiddenColumns then
    LSource := GetAllColumnsForExport
  else
    LSource := Columns.GetVisibleColumns;
  Result := TList<TThemedGridColumn>.Create;
  try
    for I := 0 to LSource.Count - 1 do
    begin
      LColumn := LSource[I];
      if LColumn = nil then
        Continue;
      if (not LColumn.Visible) and (not AOptions.IncludeHiddenColumns) then
        Continue;
      Result.Add(LColumn);
    end;
    Result.Sort(TComparer<TThemedGridColumn>.Construct(
      function(const ALeft, ARight: TThemedGridColumn): Integer
      begin
        Result := CompareExportColumns(ALeft, ARight);
      end));
    for I := 0 to Result.Count - 1 do
    begin
      LColumn := Result[I];
      LExportColumn := AData.AddColumn(LColumn.Name, GetExportHeaderText(LColumn));
      LExportColumn.DisplayIndex := I;
      LExportColumn.Visible := LColumn.Visible;
      LExportColumn.Width := LColumn.Width;
      LExportColumn.Format := LColumn.FormatString;
    end;
  finally
    LSource.Free;
  end;
end;

procedure TThemedGridControlApi.AddGroupExportRow(const AData: TThemedGridExportData;
  const AExportColumns: TList<TThemedGridColumn>; const AViewRow: TThemedGridViewRow; const ARowIndex: Integer;
  const AOptions: TThemedGridExportOptions);
var
  LExportRow: TThemedGridExportRow;
  LExportCell: TThemedGridExportCell;
  LText: string;
  LColumn: TThemedGridColumn;
  I: Integer;
begin
  if (AData = nil) or (AExportColumns = nil) or (AViewRow = nil) then
    Exit;
  LExportRow := AData.AddRow;
  LExportRow.Index := ARowIndex;
  LExportRow.Key := AViewRow.Key.ToString;
  LExportRow.Visible := True;
  LText := AViewRow.DisplayText;
  if (AOptions <> nil) and AOptions.IncludeTreeIndent and (AViewRow.Level > 0) then
    LText := StringOfChar(' ', AViewRow.Level * 2) + LText;
  for I := 0 to AExportColumns.Count - 1 do
  begin
    LColumn := AExportColumns[I];
    if I = 0 then
      LExportCell := LExportRow.AddCell(AViewRow.GroupValue, LText)
    else
      LExportCell := LExportRow.AddCell(TValue.Empty, '');
    if LColumn <> nil then
      LExportCell.ColumnKey := LColumn.Name
    else
      LExportCell.ColumnKey := '';
    LExportCell.Format := '';
  end;
end;

procedure TThemedGridControlApi.FillExportCell(const ACell: TThemedGridCell; const ARow: TThemedGridRow;
  const ARowIndex, AExportColumnIndex, ADataSourceIndex: Integer; const ARowObject: TValue;
  const AColumn: TThemedGridColumn);
var
  LValue: TValue;
  LMetadata: TThemedGridCellMetadata;
begin
  LValue := DataController.GetValue(ADataSourceIndex, AColumn);
  LMetadata := GetMetadata(ADataSourceIndex, AColumn.Name, False);
  ACell.RowIndex := ARowIndex;
  ACell.ColumnIndex := AExportColumnIndex;
  ACell.DataSourceIndex := ADataSourceIndex;
  ACell.Column := AColumn;
  ACell.Row := ARow;
  ACell.RowObject := ARowObject;
  ACell.Value := LValue;
  ACell.DisplayValue := LValue;
  ACell.DisplayText := FormatDisplayText(LValue, AColumn, LMetadata);
  ACell.Bounds := TRect.Empty;
  ACell.Metadata := LMetadata;
  ACell.SearchMatches := nil;
  if LMetadata <> nil then
    ACell.Tag := LMetadata.Tag
  else
    ACell.Tag := TValue.Empty;
  if AColumn.ReadOnly then
    ACell.State := [TThemedGridCellStateFlag.ReadOnly]
  else
    ACell.State := [];
  if (LMetadata <> nil) and (LMetadata.ErrorText <> '') then
    ACell.State := ACell.State + [TThemedGridCellStateFlag.Error];
  ApplyFormatting(ACell);
end;

function TThemedGridControlApi.BuildExportOptions(const AOptions: TThemedGridExportOptions;
  out AOwned: TThemedGridExportOptions): TThemedGridExportOptions;
begin
  AOwned := nil;
  if AOptions <> nil then
    Exit(AOptions);
  AOwned := TThemedGridExportOptions.Create;
  Result := AOwned;
end;

function TThemedGridControlApi.BuildExportData(const AOptions: TThemedGridExportOptions): TThemedGridExportData;
var
  LExportColumns: TList<TThemedGridColumn>;
  LCell: TThemedGridCell;
  LRowInfo: TThemedGridRow;
  LViewRow: TThemedGridViewRow;
  LExportRow: TThemedGridExportRow;
  LExportCell: TThemedGridExportCell;
  LColumn: TThemedGridColumn;
  LRowObject: TValue;
  LDataSourceIndex: Integer;
  LRowIndex: Integer;
  LColumnIndex: Integer;
  LDataSource: TValue;
begin
  Result := TThemedGridExportData.Create;
  Result.Title := Text;
  LDataSource := DataSource;
  if (not LDataSource.IsEmpty) and (LDataSource.TypeInfo <> nil) then
    Result.SourceName := string(LDataSource.TypeInfo.Name)
  else
    Result.SourceName := '';
  LExportColumns := CreateExportColumns(Result, AOptions);
  try
    if (DataController = nil) or (LExportColumns.Count = 0) then
      Exit;
    EnsureRowView;
    LCell := TThemedGridCell.Create;
    LRowInfo := TThemedGridRow.Create;
    try
      for LRowIndex := 0 to RowCount - 1 do
      begin
        LViewRow := GetViewRow(LRowIndex);
        if LViewRow = nil then
          Continue;
        if LViewRow.Kind = TThemedGridViewRowKind.GroupHeader then
        begin
          if AOptions.IncludeGroupRows then
            AddGroupExportRow(Result, LExportColumns, LViewRow, LRowIndex, AOptions);
          Continue;
        end;
        if (LViewRow.Kind = TThemedGridViewRowKind.Detail) and (not AOptions.IncludeDetailRows) then
          Continue;
        if not LViewRow.IsDataRow then
          Continue;
        LDataSourceIndex := LViewRow.DataSourceIndex;
        if LDataSourceIndex < 0 then
          Continue;
        LRowObject := LViewRow.RowObject;
        if LRowObject.IsEmpty then
          LRowObject := DataController.GetRowObject(LDataSourceIndex);
        LRowInfo.RowIndex := LRowIndex;
        LRowInfo.DataSourceIndex := LDataSourceIndex;
        LRowInfo.RowObject := LRowObject;
        LRowInfo.Bounds := TRect.Empty;
        if LViewRow.Height > 0 then
          LRowInfo.Height := LViewRow.Height
        else
          LRowInfo.Height := Metrics.RowHeight;
        LRowInfo.Tag := LViewRow.Tag;
        LRowInfo.Selected := False;
        LRowInfo.Current := False;
        LRowInfo.Hovered := False;
        LRowInfo.Visible := True;
        LExportRow := Result.AddRow;
        LExportRow.Index := LRowIndex;
        LExportRow.Key := IntToStr(LDataSourceIndex);
        LExportRow.Visible := True;
        for LColumnIndex := 0 to LExportColumns.Count - 1 do
        begin
          LColumn := LExportColumns[LColumnIndex];
          if LColumn = nil then
            Continue;
          FillExportCell(LCell, LRowInfo, LRowIndex, LColumnIndex, LDataSourceIndex, LRowObject, LColumn);
          LExportCell := LExportRow.AddCell(LCell.Value, GetExportCellText(LCell));
          LExportCell.ColumnKey := LColumn.Name;
          LExportCell.Format := LColumn.FormatString;
        end;
      end;
    finally
      LRowInfo.Free;
      LCell.Free;
    end;
  finally
    LExportColumns.Free;
  end;
end;

function TThemedGridControlApi.CreateExportData: TThemedGridExportData;
begin
  Result := CreateExportData(nil);
end;

function TThemedGridControlApi.CreateExportData(const AOptions: TThemedGridExportOptions): TThemedGridExportData;
var
  LOwned: TThemedGridExportOptions;
  LOptions: TThemedGridExportOptions;
begin
  LOptions := BuildExportOptions(AOptions, LOwned);
  try
    Result := BuildExportData(LOptions);
  finally
    LOwned.Free;
  end;
end;

function TThemedGridControlApi.ExportToCsv: string;
begin
  Result := ExportToCsv(nil);
end;

function TThemedGridControlApi.ExportToCsv(const AOptions: TThemedGridExportOptions): string;
var
  LOwned: TThemedGridExportOptions;
  LOptions: TThemedGridExportOptions;
  LData: TThemedGridExportData;
begin
  LOptions := BuildExportOptions(AOptions, LOwned);
  try
    LData := BuildExportData(LOptions);
    try
      Result := TThemedGridExport.ToCsv(LData, LOptions);
    finally
      LData.Free;
    end;
  finally
    LOwned.Free;
  end;
end;

function TThemedGridControlApi.ExportToJson: string;
begin
  Result := ExportToJson(nil);
end;

function TThemedGridControlApi.ExportToJson(const AOptions: TThemedGridExportOptions): string;
var
  LOwned: TThemedGridExportOptions;
  LOptions: TThemedGridExportOptions;
  LData: TThemedGridExportData;
begin
  LOptions := BuildExportOptions(AOptions, LOwned);
  try
    LData := BuildExportData(LOptions);
    try
      Result := TThemedGridExport.ToJson(LData, LOptions);
    finally
      LData.Free;
    end;
  finally
    LOwned.Free;
  end;
end;

function TThemedGridControlApi.ExportToHtml: string;
begin
  Result := ExportToHtml(nil);
end;

function TThemedGridControlApi.ExportToHtml(const AOptions: TThemedGridExportOptions): string;
var
  LOwned: TThemedGridExportOptions;
  LOptions: TThemedGridExportOptions;
  LData: TThemedGridExportData;
begin
  LOptions := BuildExportOptions(AOptions, LOwned);
  try
    LData := BuildExportData(LOptions);
    try
      Result := TThemedGridExport.ToHtml(LData, LOptions);
    finally
      LData.Free;
    end;
  finally
    LOwned.Free;
  end;
end;

function TThemedGridControlApi.CreateClipboardPayload: TThemedGridClipboardPayload;
begin
  Result := CreateClipboardPayload(nil);
end;

function TThemedGridControlApi.CreateClipboardPayload(
  const AOptions: TThemedGridExportOptions): TThemedGridClipboardPayload;
var
  LOwned: TThemedGridExportOptions;
  LOptions: TThemedGridExportOptions;
  LData: TThemedGridExportData;
begin
  LOptions := BuildExportOptions(AOptions, LOwned);
  try
    LData := BuildExportData(LOptions);
    try
      Result := TThemedGridExport.ToClipboardPayload(LData, LOptions);
    finally
      LData.Free;
    end;
  finally
    LOwned.Free;
  end;
end;

procedure TThemedGridControlApi.CopyExportToClipboard;
begin
  CopyExportToClipboard(nil);
end;

procedure TThemedGridControlApi.CopyExportToClipboard(const AOptions: TThemedGridExportOptions);
var
  LOwned: TThemedGridExportOptions;
  LOptions: TThemedGridExportOptions;
  LData: TThemedGridExportData;
begin
  LOptions := BuildExportOptions(AOptions, LOwned);
  try
    LData := BuildExportData(LOptions);
    try
      TThemedGridExport.CopyToClipboard(LData, LOptions);
    finally
      LData.Free;
    end;
  finally
    LOwned.Free;
  end;
end;

end.

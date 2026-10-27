unit NimbusForms.Grid.ControlCells;

{$SCOPEDENUMS ON}

interface

uses
  System.Classes,
  System.SysUtils,
  System.Rtti,
  System.Generics.Collections,
  NimbusForms.Theming.Types,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.Cell,
  NimbusForms.Grid.CellMetadata,
  NimbusForms.Grid.Primitives,
  NimbusForms.Grid.Row,
  NimbusForms.Grid.SearchMatch,
  NimbusForms.Grid.RenderContext,
  NimbusForms.Grid.FormatStyle,
  NimbusForms.Grid.FormatCondition,
  NimbusForms.Grid.FormatConditionContext,
  NimbusForms.Grid.Events,
  NimbusForms.Grid.ControlBase,
  NimbusForms.Grid.ControlLayout;

type
  TThemedGridControlCells = class(TThemedGridControlLayout)
  private
    FStylePool: TObjectList<TThemedGridFormatStyle>;
    FTempMetadata: TObjectList<TThemedGridCellMetadata>;
    FRenderRow: TThemedGridRow;
    FRenderCell: TThemedGridCell;
    FPainting: Boolean;
    function EnsureCellMetadata(const ACell: TThemedGridCell): TThemedGridCellMetadata;
    function PoolStyle(const AStyle: TThemedGridFormatStyle): TThemedGridFormatStyle;
  protected
    procedure FillCellEventArgs(const AArgs: TThemedGridCellEventArgs; const ACell: TThemedGridCell);
    function FillRow(const ARow: TThemedGridRow; const ARowIndex: Integer): Boolean;
    function FillCell(const ACell: TThemedGridCell; const ARowIndex, AColumnIndex: Integer;
      const ARenderCell: Boolean): Boolean;
    function CreateCellState(const ARowIndex, AColumnIndex: Integer; const AColumn: TThemedGridColumn): TThemedGridCellState;
    function IsCellSelected(const ARowIndex, AColumnIndex: Integer): Boolean;
    function IsRowSelected(const ARowIndex: Integer): Boolean;
    function ResolveSearchMatches(const AKey: TThemedGridCellKey): TList<TThemedGridSearchMatch>; virtual;
    procedure ApplyFormatting(const ACell: TThemedGridCell);
    procedure ApplyFormatConditions(const ACell: TThemedGridCell);
    procedure ApplyCellVisualStyle(const ACell: TThemedGridCell; const ARowStyle: TThemedGridFormatStyle;
      const AContext: TThemedGridRenderContext);
    function CreateRowStyle(const ARowIndex: Integer; const AContext: TThemedGridRenderContext): TThemedGridFormatStyle;
    function CreateFormatConditionStyle(const ACell: TThemedGridCell): TThemedGridFormatStyle;
    function ConditionTargetsCell(const ACondition: TThemedGridFormatCondition; const ACell: TThemedGridCell): Boolean;
    function CreateFormatConditionContext(const ACondition: TThemedGridFormatCondition;
      const ACell: TThemedGridCell): TThemedGridFormatConditionContext;
    function ResolveFormatConditionColumn(const ACondition: TThemedGridFormatCondition;
      const ACell: TThemedGridCell): TThemedGridColumn;
    function MergeFormatStyle(const ACurrent, ANext: TThemedGridFormatStyle): TThemedGridFormatStyle;
    function ResolveCurrentBackColor(const AContext: TThemedGridRenderContext;
      const AStyle: TThemedGridFormatStyle): TThemeColor;
    function ResolveCurrentForeColor(const AContext: TThemedGridRenderContext;
      const AStyle: TThemedGridFormatStyle): TThemeColor;
    procedure ResetStylePool;
    procedure BeginPainting;
    procedure EndPainting;
    property RenderRow: TThemedGridRow read FRenderRow;
    property RenderCell: TThemedGridCell read FRenderCell;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetRow(const ARowIndex: Integer): TThemedGridRow;
    function GetCell(const ARowIndex, AColumnIndex: Integer): TThemedGridCell; overload;
    function GetCell(const ARowIndex: Integer; const AColumnName: string): TThemedGridCell; overload;
    function IsCellSelectedPublic(const ARowIndex, AColumnIndex: Integer): Boolean;
  end;

implementation

uses
  System.Math,
  NimbusForms.Grid.ViewRow,
  NimbusForms.Grid.FormatConditionEvaluator;

const
  CDefaultBack = TThemeColor($FFFFFFFF);
  CDefaultFore = TThemeColor($FF000000);
  CStylePoolLimit = 2048;

constructor TThemedGridControlCells.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FStylePool := TObjectList<TThemedGridFormatStyle>.Create(True);
  FTempMetadata := TObjectList<TThemedGridCellMetadata>.Create(True);
  FRenderRow := TThemedGridRow.Create;
  FRenderCell := TThemedGridCell.Create;
end;

destructor TThemedGridControlCells.Destroy;
begin
  FRenderCell.Free;
  FRenderRow.Free;
  FTempMetadata.Free;
  FStylePool.Free;
  inherited Destroy;
end;

function TThemedGridControlCells.EnsureCellMetadata(const ACell: TThemedGridCell): TThemedGridCellMetadata;
begin
  Result := ACell.Metadata;
  if Result <> nil then
    Exit;
  if FPainting then
  begin
    Result := TThemedGridCellMetadata.Create;
    FTempMetadata.Add(Result);
  end
  else
    Result := GetMetadata(ACell.DataSourceIndex, ACell.Column.Name, True);
  ACell.Metadata := Result;
end;

function TThemedGridControlCells.PoolStyle(const AStyle: TThemedGridFormatStyle): TThemedGridFormatStyle;
begin
  if AStyle <> nil then
    FStylePool.Add(AStyle);
  Result := AStyle;
end;

procedure TThemedGridControlCells.ResetStylePool;
var
  LMetadata: TThemedGridCellMetadata;
begin
  for LMetadata in CellMetadata.Values do
    if LMetadata.Style.IsObject and (LMetadata.Style.AsObject is TThemedGridFormatStyle) then
      LMetadata.Style := TValue.Empty;
  FStylePool.Clear;
  FTempMetadata.Clear;
end;

procedure TThemedGridControlCells.BeginPainting;
begin
  FPainting := True;
  ResetStylePool;
end;

procedure TThemedGridControlCells.EndPainting;
begin
  FPainting := False;
end;

procedure TThemedGridControlCells.FillCellEventArgs(const AArgs: TThemedGridCellEventArgs;
  const ACell: TThemedGridCell);
begin
  AArgs.RowIndex := ACell.RowIndex;
  AArgs.ColumnIndex := ACell.ColumnIndex;
  AArgs.DataSourceIndex := ACell.DataSourceIndex;
  AArgs.Column := ACell.Column;
  AArgs.Row := ACell.Row;
  AArgs.Cell := ACell;
  AArgs.RowObject := ACell.RowObject;
  AArgs.Value := ACell.Value;
  AArgs.CellTag := ACell.Tag;
  AArgs.Bounds := ACell.Bounds;
end;

function TThemedGridControlCells.ResolveSearchMatches(const AKey: TThemedGridCellKey): TList<TThemedGridSearchMatch>;
begin
  Result := nil;
end;

function TThemedGridControlCells.GetRow(const ARowIndex: Integer): TThemedGridRow;
begin
  Result := TThemedGridRow.Create;
  if not FillRow(Result, ARowIndex) then
  begin
    Result.Free;
    Result := nil;
  end;
end;

function TThemedGridControlCells.FillRow(const ARow: TThemedGridRow; const ARowIndex: Integer): Boolean;
var
  LViewRow: TThemedGridViewRow;
begin
  if (ARow = nil) or (DataController = nil) then
    Exit(False);
  LViewRow := GetViewRow(ARowIndex);
  if LViewRow = nil then
    Exit(False);
  if LViewRow.IsDataRow and (LViewRow.DataSourceIndex < 0) then
    Exit(False);
  ARow.RowIndex := ARowIndex;
  ARow.DataSourceIndex := LViewRow.DataSourceIndex;
  ARow.RowObject := GetViewRowObject(LViewRow);
  if LViewRow.Height > 0 then
    ARow.Height := LViewRow.Height
  else
    ARow.Height := Metrics.RowHeight;
  ARow.Visible := LViewRow.Visible;
  ARow.Current := ARowIndex = CurrentRowIndex;
  ARow.Hovered := ARowIndex = HoverRowIndex;
  ARow.Selected := IsRowSelected(ARowIndex);
  ARow.Bounds := GetRowBounds(ARowIndex);
  ARow.Tag := LViewRow.Tag;
  Result := True;
end;

function TThemedGridControlCells.GetCell(const ARowIndex, AColumnIndex: Integer): TThemedGridCell;
begin
  if (not FPainting) and (FStylePool.Count > CStylePoolLimit) then
    ResetStylePool;
  Result := TThemedGridCell.Create;
  if not FillCell(Result, ARowIndex, AColumnIndex, False) then
  begin
    Result.Free;
    Result := nil;
  end;
end;

function TThemedGridControlCells.GetCell(const ARowIndex: Integer; const AColumnName: string): TThemedGridCell;
var
  LColumnIndex: Integer;
begin
  LColumnIndex := GetColumnVisibleIndex(AColumnName);
  if LColumnIndex < 0 then
    Exit(nil);
  Result := GetCell(ARowIndex, LColumnIndex);
end;

function TThemedGridControlCells.FillCell(const ACell: TThemedGridCell; const ARowIndex, AColumnIndex: Integer;
  const ARenderCell: Boolean): Boolean;
var
  LColumn: TThemedGridColumn;
  LViewRow: TThemedGridViewRow;
  LDataSourceIndex: Integer;
  LRow: TThemedGridRow;
  LValue: TValue;
  LMetadata: TThemedGridCellMetadata;
  LKey: TThemedGridCellKey;
begin
  if (ACell = nil) or (DataController = nil) then
    Exit(False);
  LColumn := GetColumn(AColumnIndex);
  if LColumn = nil then
    Exit(False);
  LViewRow := GetViewRow(ARowIndex);
  if (LViewRow = nil) or (not LViewRow.CanRenderCells) then
    Exit(False);
  LDataSourceIndex := LViewRow.DataSourceIndex;
  if LDataSourceIndex < 0 then
    Exit(False);

  if ARenderCell then
  begin
    if not FillRow(FRenderRow, ARowIndex) then
      Exit(False);
    LRow := FRenderRow;
    ACell.Row := LRow;
  end
  else
  begin
    LRow := GetRow(ARowIndex);
    ACell.OwnRow(LRow);
  end;

  LValue := DataController.GetValue(LDataSourceIndex, LColumn);
  LMetadata := GetMetadata(LDataSourceIndex, LColumn.Name, False);

  ACell.RowIndex := ARowIndex;
  ACell.ColumnIndex := AColumnIndex;
  ACell.DataSourceIndex := LDataSourceIndex;
  ACell.Column := LColumn;
  if LRow <> nil then
    ACell.RowObject := LRow.RowObject
  else
    ACell.RowObject := TValue.Empty;
  ACell.Value := LValue;
  ACell.DisplayValue := LValue;
  ACell.DisplayText := FormatDisplayText(LValue, LColumn, LMetadata);
  ACell.Bounds := GetCellBounds(ARowIndex, AColumnIndex);
  ACell.Metadata := LMetadata;
  LKey := TThemedGridCellKey.Create(LDataSourceIndex, LColumn.Name);
  ACell.SearchMatches := ResolveSearchMatches(LKey);
  if LMetadata <> nil then
    ACell.Tag := LMetadata.Tag
  else
    ACell.Tag := TValue.Empty;
  ACell.State := CreateCellState(ARowIndex, AColumnIndex, LColumn);
  if (LMetadata <> nil) and (LMetadata.ErrorText <> '') then
    ACell.State := ACell.State + [TThemedGridCellStateFlag.Error];
  ApplyFormatting(ACell);
  Result := True;
end;

function TThemedGridControlCells.CreateCellState(const ARowIndex, AColumnIndex: Integer;
  const AColumn: TThemedGridColumn): TThemedGridCellState;
begin
  Result := [];
  if (ARowIndex = CurrentRowIndex) and (AColumnIndex = CurrentColumnIndex) then
    Include(Result, TThemedGridCellStateFlag.Current);
  if IsCellSelected(ARowIndex, AColumnIndex) then
    Include(Result, TThemedGridCellStateFlag.Selected);
  if (ARowIndex = HoverRowIndex) and (AColumnIndex = HoverColumnIndex) then
    Include(Result, TThemedGridCellStateFlag.Hovered);
  if (ARowIndex = PressedRowIndex) and (AColumnIndex = PressedColumnIndex) and PressedContent then
    Include(Result, TThemedGridCellStateFlag.Pressed);
  if Focused then
    Include(Result, TThemedGridCellStateFlag.Focused);
  if (AColumn <> nil) and AColumn.ReadOnly then
    Include(Result, TThemedGridCellStateFlag.ReadOnly);
end;

function TThemedGridControlCells.IsCellSelected(const ARowIndex, AColumnIndex: Integer): Boolean;
begin
  if SelectionMode = TThemedGridSelectionMode.None then
    Exit(False);
  if SelectionModel.IsCellSelected(ARowIndex, AColumnIndex) then
    Exit(True);
  if (SelectionMode = TThemedGridSelectionMode.Row) or (SelectionMode = TThemedGridSelectionMode.RowRange) then
    Exit(ARowIndex = CurrentRowIndex);
  if (SelectionMode = TThemedGridSelectionMode.Column) or (SelectionMode = TThemedGridSelectionMode.ColumnRange) then
    Exit(AColumnIndex = CurrentColumnIndex);
  Result := (ARowIndex = CurrentRowIndex) and (AColumnIndex = CurrentColumnIndex);
end;

function TThemedGridControlCells.IsRowSelected(const ARowIndex: Integer): Boolean;
begin
  if SelectionModel.IsRowSelected(ARowIndex) then
    Exit(True);
  if (SelectionMode = TThemedGridSelectionMode.Row) or (SelectionMode = TThemedGridSelectionMode.RowRange) then
    Exit(ARowIndex = CurrentRowIndex);
  Result := False;
end;

function TThemedGridControlCells.IsCellSelectedPublic(const ARowIndex, AColumnIndex: Integer): Boolean;
begin
  Result := IsCellSelected(ARowIndex, AColumnIndex);
end;

procedure TThemedGridControlCells.ApplyFormatting(const ACell: TThemedGridCell);
var
  LArgs: TThemedGridCellFormattingEventArgs;
begin
  if ACell = nil then
    Exit;
  LArgs := TThemedGridCellFormattingEventArgs.Create;
  try
    FillCellEventArgs(LArgs, ACell);
    LArgs.DisplayText := ACell.DisplayText;
    LArgs.DisplayValue := ACell.DisplayValue;
    if ACell.Column <> nil then
    begin
      LArgs.FormatString := ACell.Column.FormatString;
      if ACell.Column.HasFormatProvider then
        LArgs.FormatProvider := ACell.Column.FormatProvider;
    end;
    DoCellFormatting(LArgs);
    ACell.DisplayText := LArgs.DisplayText;
    ACell.DisplayValue := LArgs.DisplayValue;
  finally
    LArgs.Free;
  end;
end;

function TThemedGridControlCells.MergeFormatStyle(const ACurrent, ANext: TThemedGridFormatStyle): TThemedGridFormatStyle;
begin
  if ANext = nil then
    Exit(ACurrent);
  if ACurrent = nil then
    Exit(PoolStyle(ANext.Clone));
  ACurrent.MergeFrom(ANext);
  Result := ACurrent;
end;

function TThemedGridControlCells.ResolveFormatConditionColumn(const ACondition: TThemedGridFormatCondition;
  const ACell: TThemedGridCell): TThemedGridColumn;
begin
  if ACondition = nil then
  begin
    if ACell <> nil then
      Exit(ACell.Column);
    Exit(nil);
  end;
  if ACondition.ColumnName <> '' then
    Exit(GetColumn(ACondition.ColumnName));
  if ACell <> nil then
    Result := ACell.Column
  else
    Result := nil;
end;

function TThemedGridControlCells.ConditionTargetsCell(const ACondition: TThemedGridFormatCondition;
  const ACell: TThemedGridCell): Boolean;
var
  LTarget: TThemedGridColumn;
begin
  if (ACondition = nil) or (ACell = nil) or (ACell.Column = nil) then
    Exit(False);
  if (ACondition.ColumnName <> '') and (ResolveFormatConditionColumn(ACondition, ACell) = nil) then
    Exit(False);
  if ACondition.TargetColumnName = '' then
    Exit(True);
  LTarget := GetColumn(ACondition.TargetColumnName);
  if LTarget = nil then
    Exit(False);
  Result := SameText(LTarget.Name, ACell.Column.Name) or
    SameText(LTarget.FieldName, ACell.Column.FieldName) or
    SameText(ACondition.TargetColumnName, ACell.Column.Name) or
    SameText(ACondition.TargetColumnName, ACell.Column.FieldName);
end;

function TThemedGridControlCells.CreateFormatConditionContext(const ACondition: TThemedGridFormatCondition;
  const ACell: TThemedGridCell): TThemedGridFormatConditionContext;
var
  LColumn: TThemedGridColumn;
begin
  Result := TThemedGridFormatConditionContext.Create;
  Result.Grid := Self;
  Result.Cell := ACell;
  Result.Column := ACell.Column;
  Result.RowIndex := ACell.RowIndex;
  Result.ColumnIndex := ACell.ColumnIndex;
  Result.DataSourceIndex := ACell.DataSourceIndex;
  Result.RowObject := ACell.RowObject;
  Result.Value := ACell.Value;
  LColumn := ResolveFormatConditionColumn(ACondition, ACell);
  Result.ConditionColumn := LColumn;
  if (LColumn <> nil) and (DataController <> nil) then
    Result.ConditionValue := DataController.GetValue(ACell.DataSourceIndex, LColumn)
  else
    Result.ConditionValue := ACell.Value;
end;

procedure TThemedGridControlCells.ApplyFormatConditions(const ACell: TThemedGridCell);
var
  I: Integer;
  LCondition: TThemedGridFormatCondition;
  LContext: TThemedGridFormatConditionContext;
  LStyle: TThemedGridFormatStyle;
  LMatches: Boolean;
begin
  if ACell = nil then
    Exit;
  if ACell.Metadata <> nil then
    ACell.Metadata.Style := TValue.Empty;
  if (not FormatConditions.Enabled) or (FormatConditions.Count = 0) then
    Exit;
  LStyle := nil;
  for I := 0 to FormatConditions.Count - 1 do
  begin
    LCondition := FormatConditions[I];
    if (LCondition = nil) or (not LCondition.Enabled) or (LCondition.Style = nil) then
      Continue;
    if not ConditionTargetsCell(LCondition, ACell) then
      Continue;
    LContext := CreateFormatConditionContext(LCondition, ACell);
    try
      if (LContext.ConditionColumn = nil) and (LCondition.ColumnName <> '') then
        Continue;
      LMatches := TThemedGridFormatConditionEvaluator.Matches(LCondition, LContext);
    finally
      LContext.Free;
    end;
    if not LMatches then
      Continue;
    LStyle := MergeFormatStyle(LStyle, LCondition.Style);
  end;
  if LStyle = nil then
    Exit;
  EnsureCellMetadata(ACell).Style := TValue.From<TObject>(LStyle);
end;

function TThemedGridControlCells.CreateFormatConditionStyle(const ACell: TThemedGridCell): TThemedGridFormatStyle;
var
  I: Integer;
  LCondition: TThemedGridFormatCondition;
  LContext: TThemedGridFormatConditionContext;
  LMatches: Boolean;
begin
  Result := nil;
  if (ACell = nil) or (FormatConditions.Count = 0) then
    Exit;
  for I := 0 to FormatConditions.Count - 1 do
  begin
    LCondition := FormatConditions[I];
    if (LCondition = nil) or (not LCondition.Enabled) or (LCondition.Style = nil) then
      Continue;
    if not ConditionTargetsCell(LCondition, ACell) then
      Continue;
    LContext := CreateFormatConditionContext(LCondition, ACell);
    try
      LMatches := TThemedGridFormatConditionEvaluator.Matches(LCondition, LContext);
    finally
      LContext.Free;
    end;
    if not LMatches then
      Continue;
    Result := MergeFormatStyle(Result, LCondition.Style);
  end;
end;

function TThemedGridControlCells.ResolveCurrentBackColor(const AContext: TThemedGridRenderContext;
  const AStyle: TThemedGridFormatStyle): TThemeColor;
begin
  if AContext = nil then
    Exit(CDefaultBack);
  Result := AContext.BackColor;
  if (AStyle <> nil) and AStyle.HasBackColor then
    Result := AStyle.BackColor;
end;

function TThemedGridControlCells.ResolveCurrentForeColor(const AContext: TThemedGridRenderContext;
  const AStyle: TThemedGridFormatStyle): TThemeColor;
begin
  if AContext = nil then
    Exit(CDefaultFore);
  Result := AContext.ForeColor;
  if (AStyle <> nil) and AStyle.HasForeColor then
    Result := AStyle.ForeColor;
end;

function TThemedGridControlCells.CreateRowStyle(const ARowIndex: Integer;
  const AContext: TThemedGridRenderContext): TThemedGridFormatStyle;
var
  LArgs: TThemedGridRowStyleEventArgs;
begin
  Result := nil;
  if DataController = nil then
    Exit;
  if not FillRow(FRenderRow, ARowIndex) then
    Exit;
  LArgs := TThemedGridRowStyleEventArgs.Create;
  try
    LArgs.RowIndex := FRenderRow.RowIndex;
    LArgs.DataSourceIndex := FRenderRow.DataSourceIndex;
    LArgs.Row := FRenderRow;
    LArgs.RowObject := FRenderRow.RowObject;
    LArgs.Bounds := FRenderRow.Bounds;
    if AContext <> nil then
    begin
      LArgs.CurrentBackColor := AContext.BackColor;
      LArgs.CurrentForeColor := AContext.ForeColor;
    end
    else
    begin
      LArgs.CurrentBackColor := CDefaultBack;
      LArgs.CurrentForeColor := CDefaultFore;
    end;
    DoRowStyleNeeded(LArgs);
    if LArgs.HasStyle then
      Result := PoolStyle(LArgs.Style.Clone);
  finally
    LArgs.Free;
  end;
end;

procedure TThemedGridControlCells.ApplyCellVisualStyle(const ACell: TThemedGridCell;
  const ARowStyle: TThemedGridFormatStyle; const AContext: TThemedGridRenderContext);
var
  LStyle: TThemedGridFormatStyle;
  LCellArgs: TThemedGridCellStyleEventArgs;
  LSelectionArgs: TThemedGridSelectionStyleEventArgs;
begin
  if ACell = nil then
    Exit;
  LStyle := nil;
  if ARowStyle <> nil then
    LStyle := MergeFormatStyle(LStyle, ARowStyle);
  LStyle := MergeFormatStyle(LStyle, CreateFormatConditionStyle(ACell));

  LCellArgs := TThemedGridCellStyleEventArgs.Create;
  try
    FillCellEventArgs(LCellArgs, ACell);
    LCellArgs.Style := LStyle;
    LCellArgs.CurrentBackColor := ResolveCurrentBackColor(AContext, LStyle);
    LCellArgs.CurrentForeColor := ResolveCurrentForeColor(AContext, LStyle);
    DoCellStyleNeeded(LCellArgs);
    if LCellArgs.HasStyle and (LCellArgs.Style <> LStyle) then
      LStyle := PoolStyle(LCellArgs.Style.Clone);
  finally
    LCellArgs.Free;
  end;

  LSelectionArgs := TThemedGridSelectionStyleEventArgs.Create;
  try
    FillCellEventArgs(LSelectionArgs, ACell);
    LSelectionArgs.Style := LStyle;
    LSelectionArgs.CurrentBackColor := ResolveCurrentBackColor(AContext, LStyle);
    LSelectionArgs.CurrentForeColor := ResolveCurrentForeColor(AContext, LStyle);
    if AContext <> nil then
    begin
      LSelectionArgs.SelectionBackColor := AContext.SelectionBackColor;
      LSelectionArgs.SelectionForeColor := AContext.SelectionForeColor;
      LSelectionArgs.HoverBackColor := AContext.HoverBackColor;
      LSelectionArgs.CurrentBorderColor := AContext.FocusColor;
    end;
    LSelectionArgs.HoverForeColor := LSelectionArgs.CurrentForeColor;
    LSelectionArgs.Selected := ACell.IsSelected;
    LSelectionArgs.Hovered := ACell.IsHovered;
    LSelectionArgs.Current := ACell.IsCurrent;
    DoSelectionStyleNeeded(LSelectionArgs);
    if LSelectionArgs.HasStyle and (LSelectionArgs.Style <> LStyle) then
      LStyle := PoolStyle(LSelectionArgs.Style.Clone);
  finally
    LSelectionArgs.Free;
  end;

  if LStyle = nil then
  begin
    if ACell.Metadata <> nil then
      ACell.Metadata.Style := TValue.Empty;
    Exit;
  end;
  EnsureCellMetadata(ACell).Style := TValue.From<TObject>(LStyle);
end;

end.

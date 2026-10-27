unit NimbusForms.Grid.SimpleView;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.SysUtils,
  System.Types,
  System.Rtti,
  System.Generics.Collections,
  Vcl.Controls,
  Vcl.Graphics,
  NimbusForms.Theming.Palette,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.ColumnCollection,
  NimbusForms.Grid.Cell,
  NimbusForms.Grid.ViewRow,
  NimbusForms.Grid.RenderMetrics,
  NimbusForms.Grid.RenderContext,
  NimbusForms.Grid.Renderer,
  NimbusForms.Grid.RowList,
  NimbusForms.Grid.RowView,
  NimbusForms.Grid.StringSet,
  NimbusForms.Grid.GroupDescriptor,
  NimbusForms.Grid.GroupDescriptorCollection,
  NimbusForms.Grid.GroupingOptions,
  NimbusForms.Grid.DataControllerIntf;

type
  TThemedGridSimpleView = class(TCustomControl)
  private
    FColumns: TThemedGridColumnCollection;
    FController: IThemedGridDataController;
    FRowView: TThemedGridRowView;
    FGroups: TThemedGridGroupDescriptorCollection;
    FGroupingOptions: TThemedGridGroupingOptions;
    FCollapsed: TThemedGridStringSet;
    FRenderer: TThemedGridRenderer;
    FMetrics: TThemedGridRenderMetrics;
    FPalette: TThemePalette;
    FHoverRow: Integer;
    FCurrentRow: Integer;
    FCurrentCol: Integer;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    function RowAtY(const AY: Integer): Integer;
    function ColumnAtX(const AColumns: TList<TThemedGridColumn>; const AX: Integer): Integer;
    procedure ToggleSort(const AColumn: TThemedGridColumn);
    procedure RebuildView;
    procedure ResetInteraction;
    procedure DrawGroupRow(const AContext: TThemedGridRenderContext; const ARow: TThemedGridViewRow;
      const ABounds: TRect; const AHover: Boolean);
  protected
    procedure Paint; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetRows(const ARows: IThemedGridRowList);
    procedure SetPalette(const APalette: TThemePalette);
    procedure Reload;
    procedure GroupBy(const AColumnName: string);
    procedure ClearGrouping;
    property Columns: TThemedGridColumnCollection read FColumns;
    property Controller: IThemedGridDataController read FController;
  end;

implementation

uses
  Winapi.GDIPOBJ,
  NimbusForms.Theming.Types,
  NimbusForms.Grid.GdiCache,
  NimbusForms.Grid.GdiText,
  NimbusForms.Grid.RowViewBuilder,
  NimbusForms.Grid.ListDataController,
  NimbusForms.Grid.ValueFormatter;

constructor TThemedGridSimpleView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csCaptureMouse, csClickEvents, csDoubleClicks, csOpaque];
  Width := 640;
  Height := 400;
  DoubleBuffered := True;
  FColumns := TThemedGridColumnCollection.Create;
  FRowView := TThemedGridRowView.Create;
  FGroups := TThemedGridGroupDescriptorCollection.Create;
  FGroupingOptions := TThemedGridGroupingOptions.Create;
  FCollapsed := TThemedGridStringSet.Create;
  FRenderer := TThemedGridRenderer.Create;
  FMetrics := TThemedGridRenderMetrics.Create;
  FHoverRow := -1;
  FCurrentRow := -1;
  FCurrentCol := -1;
  Font.Name := 'Segoe UI';
  Font.Size := 9;
end;

destructor TThemedGridSimpleView.Destroy;
begin
  FController := nil;
  FMetrics.Free;
  FRenderer.Free;
  FCollapsed.Free;
  FGroupingOptions.Free;
  FGroups.Free;
  FRowView.Free;
  FColumns.Free;
  inherited Destroy;
end;

procedure TThemedGridSimpleView.ResetInteraction;
begin
  FHoverRow := -1;
  FCurrentRow := -1;
  FCurrentCol := -1;
end;

procedure TThemedGridSimpleView.RebuildView;
begin
  TThemedGridRowViewBuilder.Build(FController, FRowView, FMetrics.RowHeight, FGroups, FCollapsed, FGroupingOptions);
end;

procedure TThemedGridSimpleView.SetRows(const ARows: IThemedGridRowList);
begin
  FController := TThemedGridListDataController.Create(ARows);
  ResetInteraction;
  RebuildView;
  Invalidate;
end;

procedure TThemedGridSimpleView.SetPalette(const APalette: TThemePalette);
begin
  FPalette := APalette;
  Invalidate;
end;

procedure TThemedGridSimpleView.Reload;
begin
  ResetInteraction;
  RebuildView;
  Invalidate;
end;

procedure TThemedGridSimpleView.GroupBy(const AColumnName: string);
var
  LDescriptor: TThemedGridGroupDescriptor;
begin
  FGroups.BeginUpdate;
  try
    FGroups.Clear;
    FCollapsed.Clear;
    LDescriptor := FGroups.Add(AColumnName);
    LDescriptor.Column := FColumns.FindByName(AColumnName);
  finally
    FGroups.EndUpdate;
  end;
  Reload;
end;

procedure TThemedGridSimpleView.ClearGrouping;
begin
  FGroups.Clear;
  FCollapsed.Clear;
  Reload;
end;

procedure TThemedGridSimpleView.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

function TThemedGridSimpleView.RowAtY(const AY: Integer): Integer;
begin
  if AY < FMetrics.HeaderHeight then
    Exit(-1);
  Result := (AY - FMetrics.HeaderHeight) div FMetrics.RowHeight;
  if (Result < 0) or (Result >= FRowView.Count) then
    Result := -1;
end;

function TThemedGridSimpleView.ColumnAtX(const AColumns: TList<TThemedGridColumn>; const AX: Integer): Integer;
var
  I, LX: Integer;
begin
  LX := 0;
  for I := 0 to AColumns.Count - 1 do
  begin
    if (AX >= LX) and (AX < LX + AColumns[I].Width) then
      Exit(I);
    Inc(LX, AColumns[I].Width);
  end;
  Result := -1;
end;

procedure TThemedGridSimpleView.ToggleSort(const AColumn: TThemedGridColumn);
var
  LNext: TThemedGridSortDirection;
  I: Integer;
begin
  if FController = nil then
    Exit;
  case AColumn.SortDirection of
    TThemedGridSortDirection.None: LNext := TThemedGridSortDirection.Ascending;
    TThemedGridSortDirection.Ascending: LNext := TThemedGridSortDirection.Descending;
  else
    LNext := TThemedGridSortDirection.None;
  end;
  for I := 0 to FColumns.Count - 1 do
    FColumns[I].SortDirection := TThemedGridSortDirection.None;
  AColumn.SortDirection := LNext;
  FController.ApplySort(AColumn, LNext);
  ResetInteraction;
  RebuildView;
  Invalidate;
end;

procedure TThemedGridSimpleView.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LRow: Integer;
begin
  inherited MouseMove(Shift, X, Y);
  LRow := RowAtY(Y);
  if LRow <> FHoverRow then
  begin
    FHoverRow := LRow;
    Invalidate;
  end;
end;

procedure TThemedGridSimpleView.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LRow, LCol: Integer;
  LColumns: TList<TThemedGridColumn>;
  LViewRow: TThemedGridViewRow;
  LKey: string;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if CanFocus then
    SetFocus;
  LColumns := FColumns.GetVisibleColumns;
  try
    LCol := ColumnAtX(LColumns, X);
    if (LCol < 0) and (Y < FMetrics.HeaderHeight) then
      Exit;
    if Y < FMetrics.HeaderHeight then
    begin
      ToggleSort(LColumns[LCol]);
      Exit;
    end;
    LRow := RowAtY(Y);
    if LRow < 0 then
      Exit;
    LViewRow := FRowView.GetRow(LRow);
    if LViewRow = nil then
      Exit;
    if LViewRow.IsGroupRow then
    begin
      LKey := LViewRow.Key.AsString;
      if not FCollapsed.Remove(LKey) then
        FCollapsed.Add(LKey);
      RebuildView;
      Invalidate;
      Exit;
    end;
    if LCol < 0 then
      Exit;
    FCurrentRow := LRow;
    FCurrentCol := LCol;
    Invalidate;
  finally
    LColumns.Free;
  end;
end;

procedure TThemedGridSimpleView.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if FHoverRow <> -1 then
  begin
    FHoverRow := -1;
    Invalidate;
  end;
end;

procedure TThemedGridSimpleView.DrawGroupRow(const AContext: TThemedGridRenderContext;
  const ARow: TThemedGridViewRow; const ABounds: TRect; const AHover: Boolean);
var
  LBack: TThemeColor;
  LTextBounds: TRect;
  LGlyph: string;
begin
  if AHover then
    LBack := AContext.HoverBackColor
  else
    LBack := AContext.HeaderBackColor;
  AContext.Graphics.FillRectangle(TThemedGridGdiCache.Brush(LBack), ABounds.Left, ABounds.Top,
    ABounds.Width, ABounds.Height);
  AContext.Graphics.DrawLine(TThemedGridGdiCache.Pen(AContext.GridLineColor), ABounds.Left,
    ABounds.Bottom - 1, ABounds.Right, ABounds.Bottom - 1);
  if ARow.Expanded then
    LGlyph := '-'
  else
    LGlyph := '+';
  LTextBounds := TRect.Create(ABounds.Left + 6 + ARow.Level * FGroupingOptions.IndentWidth, ABounds.Top,
    ABounds.Right, ABounds.Bottom);
  TThemedGridGdiText.DrawText(AContext, '[' + LGlyph + '] ' + ARow.DisplayText, Font, LTextBounds,
    AContext.HeaderForeColor, TThemedGridContentAlignment.MiddleLeft, True);
end;

procedure TThemedGridSimpleView.Paint;
var
  LContext: TThemedGridRenderContext;
  LColumns: TList<TThemedGridColumn>;
  LColumn: TThemedGridColumn;
  LCell: TThemedGridCell;
  LViewRow: TThemedGridViewRow;
  LIndex, LCol, LX, LY, LDataIndex: Integer;
  LHeaderBounds, LCellBounds, LRowBounds: TRect;
  LValue, LRowObject: TValue;
begin
  LContext := TThemedGridRenderContext.Create(Canvas.Handle, ClientRect, Font, FPalette, FMetrics);
  LColumns := FColumns.GetVisibleColumns;
  LCell := TThemedGridCell.Create;
  try
    FRenderer.DrawBackground(LContext);

    LX := 0;
    for LCol := 0 to LColumns.Count - 1 do
    begin
      LColumn := LColumns[LCol];
      LHeaderBounds := TRect.Create(LX, 0, LX + LColumn.Width, FMetrics.HeaderHeight);
      FRenderer.HeaderRenderer.DrawColumnHeader(LContext, LColumn, LCol, LHeaderBounds, False, False);
      FRenderer.HeaderRenderer.DrawSortGlyph(LContext, LHeaderBounds, LColumn.SortDirection);
      Inc(LX, LColumn.Width);
    end;

    if FController <> nil then
      for LIndex := 0 to FRowView.Count - 1 do
      begin
        LY := FMetrics.HeaderHeight + FRowView.GetRowTop(LIndex, FMetrics.RowHeight);
        if LY > ClientHeight then
          Break;
        LViewRow := FRowView.GetRow(LIndex);
        if LViewRow = nil then
          Continue;
        if LViewRow.IsGroupRow then
        begin
          LRowBounds := TRect.Create(0, LY, ClientWidth, LY + LViewRow.Height);
          DrawGroupRow(LContext, LViewRow, LRowBounds, LIndex = FHoverRow);
          Continue;
        end;
        if not LViewRow.CanRenderCells then
          Continue;
        LDataIndex := LViewRow.DataSourceIndex;
        LRowObject := FController.GetRowObject(LDataIndex);
        LX := 0;
        for LCol := 0 to LColumns.Count - 1 do
        begin
          LColumn := LColumns[LCol];
          LCellBounds := TRect.Create(LX, LY, LX + LColumn.Width, LY + LViewRow.Height);
          LValue := FController.GetValue(LDataIndex, LColumn);

          LCell.RowIndex := LIndex;
          LCell.ColumnIndex := LCol;
          LCell.DataSourceIndex := LDataIndex;
          LCell.Column := LColumn;
          LCell.RowObject := LRowObject;
          LCell.Value := LValue;
          LCell.DisplayText := TThemedGridValueFormatter.Format(LValue, LColumn, nil);
          LCell.Bounds := LCellBounds;
          LCell.State := [];
          if LIndex = FHoverRow then
            LCell.State := LCell.State + [TThemedGridCellStateFlag.Hovered];
          if (LIndex = FCurrentRow) and (LCol = FCurrentCol) then
            LCell.State := LCell.State + [TThemedGridCellStateFlag.Current, TThemedGridCellStateFlag.Selected];

          FRenderer.ResolveCellRenderer(LCell).Draw(LContext, LCell);
          Inc(LX, LColumn.Width);
        end;
      end;

    FRenderer.DrawBorder(LContext);
  finally
    LCell.Free;
    LColumns.Free;
    LContext.Free;
  end;
end;

end.

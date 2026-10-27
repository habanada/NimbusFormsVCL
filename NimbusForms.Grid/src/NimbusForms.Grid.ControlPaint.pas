unit NimbusForms.Grid.ControlPaint;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.UITypes,
  System.SysUtils,
  System.Types,
  System.Math,
  System.Generics.Collections,
  Vcl.Controls,
  Vcl.Graphics,
  Winapi.GDIPOBJ,
  Winapi.GDIPAPI,
  NimbusForms.Theming.Types,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Primitives,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.ColumnBand,
  NimbusForms.Grid.Cell,
  NimbusForms.Grid.ViewRow,
  NimbusForms.Grid.Row,
  NimbusForms.Grid.RenderContext,
  NimbusForms.Grid.SelectionRenderer,
  NimbusForms.Grid.FormatStyle,
  NimbusForms.Grid.Events,
  NimbusForms.Grid.ControlAutoSize;

type
  TThemedGridControlPaint = class(TThemedGridControlAutoSize)
  private
    FSelectionRenderer: TThemedGridSelectionRenderer;
    FPaintArgs: TThemedGridCellPaintingEventArgs;
    FHoverFilterButtonColumnIndex: Integer;
    FPressedFilterButtonColumnIndex: Integer;
    FDraggingColumnHeader: Boolean;
    FDragColumnIndex: Integer;
    FDragTargetColumnIndex: Integer;
    FDraggingVerticalScrollThumb: Boolean;
    FDraggingHorizontalScrollThumb: Boolean;
    FFocusedDetailParentDataSourceIndex: Integer;
    FDetailPaintText: string;
    FHoverDetailExpanderRowIndex: Integer;
    procedure DrawColumnHeaders(const AContext: TThemedGridRenderContext);
    procedure DrawColumnBandHeadersInClip(const AContext: TThemedGridRenderContext;
      const AFixedStyle: TThemedGridColumnFixedStyle; const AClipBounds: TRect);
    procedure DrawCurrentBandHeader(const AContext: TThemedGridRenderContext; const ABand: TThemedGridColumnBand;
      const ABandName: string; const ABounds, AClipBounds: TRect);
    procedure DrawColumnHeadersInClip(const AContext: TThemedGridRenderContext;
      const AFixedStyle: TThemedGridColumnFixedStyle; const AClipBounds: TRect);
    procedure DrawColumnDropMarker(const AContext: TThemedGridRenderContext; const AColumnIndex: Integer);
    procedure DrawRows(const AContext: TThemedGridRenderContext);
    procedure DrawGroupRow(const AContext: TThemedGridRenderContext; const AViewRow: TThemedGridViewRow;
      const ARowIndex: Integer);
    procedure DrawGroupGlyph(const AContext: TThemedGridRenderContext; const ABounds: TRect;
      const AExpanded: Boolean; const AGlyphColor, ABorderColor: TThemeColor);
    procedure DrawDetailRow(const AContext: TThemedGridRenderContext; const AViewRow: TThemedGridViewRow;
      const ARowIndex: Integer);
    procedure DrawRowCells(const AContext: TThemedGridRenderContext; const ARowIndex: Integer);
    procedure DrawRowCellsInClip(const AContext: TThemedGridRenderContext; const ARowIndex: Integer;
      const AFixedStyle: TThemedGridColumnFixedStyle; const AClipBounds: TRect);
    procedure DrawFixedColumnSeparators(const AContext: TThemedGridRenderContext);
    procedure DrawFixedSeparator(const AContext: TThemedGridRenderContext; const AX: Integer; const AFooterBottom: Integer);
    procedure DrawSummaryFooter(const AContext: TThemedGridRenderContext);
    procedure DrawSummaryFooterBackground(const AContext: TThemedGridRenderContext);
    procedure DrawSummaryFooterRowHeader(const AContext: TThemedGridRenderContext);
    procedure DrawSummaryFooterInClip(const AContext: TThemedGridRenderContext;
      const AFixedStyle: TThemedGridColumnFixedStyle; const AClipBounds: TRect);
    procedure DrawSummaryFooterCell(const AContext: TThemedGridRenderContext; const AColumnIndex: Integer;
      const AColumn: TThemedGridColumn; const ABounds: TRect);
    procedure DrawSelectedRows(const AContext: TThemedGridRenderContext);
    procedure DrawSelectedRow(const AContext: TThemedGridRenderContext; const ARowIndex: Integer);
    procedure DrawSelectedColumns(const AContext: TThemedGridRenderContext);
    procedure DrawSelectionRanges(const AContext: TThemedGridRenderContext);
    procedure DrawSelectionRangeInClip(const AContext: TThemedGridRenderContext; const ARange: TThemedGridCellRange;
      const AFixedStyle: TThemedGridColumnFixedStyle; const AClipBounds: TRect);
    function GetRangeBounds(const ARange: TThemedGridCellRange; const AFixedStyle: TThemedGridColumnFixedStyle;
      const AClipBounds: TRect): TRect;
    function GetColumnVisibleBounds(const AColumnIndex: Integer): TRect;
    procedure DrawScrollBars(const AContext: TThemedGridRenderContext);
    function ResolveColumnBandName(const AColumn: TThemedGridColumn): string;
    function GetPanelBackColor: TThemeColor;
    function GetPanelForeColor: TThemeColor;
    function GetPanelBorderColor: TThemeColor;
    function GetPanelHoverColor: TThemeColor;
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure DrawDropIndicator(const AContext: TThemedGridRenderContext); virtual;
    procedure DrawRowMoveIndicator(const AContext: TThemedGridRenderContext); virtual;
    function TryDrawCellVisual(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell): Boolean; virtual;
    function TryDrawGroupVisual(const AContext: TThemedGridRenderContext; const AViewRow: TThemedGridViewRow;
      const ARowIndex: Integer; const ABounds: TRect; const AForeColor: TThemeColor): Boolean; virtual;
    function DrawDetailContent(const AContext: TThemedGridRenderContext; const AViewRow: TThemedGridViewRow;
      const ARowIndex: Integer; const ABounds, AContentBounds: TRect; const AFocused: Boolean): Boolean; virtual;
    procedure EnsureDetailRowCustomized(const ARowIndex: Integer; const AViewRow: TThemedGridViewRow); virtual;
    procedure DrawDetailBody(const AContext: TThemedGridRenderContext; const AViewRow: TThemedGridViewRow;
      const ARowIndex: Integer; const ABounds, AContentBounds: TRect; const ADetailText: string); virtual;
    procedure BeginDetailLayout; virtual;
    procedure EndDetailLayout; virtual;
    function GetDetailContentBounds(const ABounds: TRect): TRect;
    property DetailPaintText: string read FDetailPaintText write FDetailPaintText;
    function GetColumnFilterButtonBounds(const AColumnIndex: Integer): TRect;
    function GetColumnFilterButtonIndex(const ALocation: TPoint): Integer;
    function GetGroupGlyphBounds(const AViewRow: TThemedGridViewRow; const ARowIndex: Integer): TRect;
    function GetDetailParentDataSourceIndex(const ARowIndex: Integer): Integer;
    function CanExpandDetailRow(const ARowIndex: Integer): Boolean;
    function IsDetailExpanderVisible(const ARowIndex: Integer): Boolean;
    function IsDetailRowExpanded(const ARowIndex: Integer): Boolean;
    property HoverFilterButtonColumnIndex: Integer read FHoverFilterButtonColumnIndex write FHoverFilterButtonColumnIndex;
    property PressedFilterButtonColumnIndex: Integer read FPressedFilterButtonColumnIndex write FPressedFilterButtonColumnIndex;
    property DraggingColumnHeader: Boolean read FDraggingColumnHeader write FDraggingColumnHeader;
    property DragColumnIndex: Integer read FDragColumnIndex write FDragColumnIndex;
    property DragTargetColumnIndex: Integer read FDragTargetColumnIndex write FDragTargetColumnIndex;
    property DraggingVerticalScrollThumb: Boolean read FDraggingVerticalScrollThumb write FDraggingVerticalScrollThumb;
    property DraggingHorizontalScrollThumb: Boolean read FDraggingHorizontalScrollThumb write FDraggingHorizontalScrollThumb;
    property FocusedDetailParentDataSourceIndex: Integer
      read FFocusedDetailParentDataSourceIndex write FFocusedDetailParentDataSourceIndex;
    property HoverDetailExpanderRowIndex: Integer
      read FHoverDetailExpanderRowIndex write FHoverDetailExpanderRowIndex;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

uses
  NimbusForms.Grid.GdiCache,
  NimbusForms.Grid.GdiText,
  NimbusForms.Grid.RowViewBuilder,
  NimbusForms.Grid.CellRendererIntf,
  NimbusForms.Grid.PaintStrings;

const
  CFallbackPanel = TThemeColor($FFF0F0F0);
  CFallbackFore = TThemeColor($FF000000);
  CFallbackBorder = TThemeColor($FFA0A0A0);
  CFallbackHover = TThemeColor($FFE3E3E3);
  CFallbackAccent = TThemeColor($FF3399FF);
  CFallbackBlack = TThemeColor($FF000000);
  CFallbackWhite = TThemeColor($FFFFFFFF);

function EmptyRect: TRect;
begin
  Result := Rect(0, 0, 0, 0);
end;

function IsEmptyRect(const ARect: TRect): Boolean;
begin
  Result := (ARect.Right <= ARect.Left) or (ARect.Bottom <= ARect.Top);
end;

function WithAlpha(const AColor: TThemeColor; const AAlpha: Byte): TThemeColor;
begin
  Result := ThemeColor(AAlpha, ThemeColorRed(AColor), ThemeColorGreen(AColor), ThemeColorBlue(AColor));
end;

function BlendThemeColor(const ABase, AOverlay: TThemeColor; const AAmount: Integer): TThemeColor;
var
  LAmount, LR, LG, LB: Integer;
begin
  LAmount := AAmount;
  if LAmount < 0 then
    LAmount := 0;
  if LAmount > 255 then
    LAmount := 255;
  LR := ThemeColorRed(ABase) + ((ThemeColorRed(AOverlay) - ThemeColorRed(ABase)) * LAmount div 255);
  LG := ThemeColorGreen(ABase) + ((ThemeColorGreen(AOverlay) - ThemeColorGreen(ABase)) * LAmount div 255);
  LB := ThemeColorBlue(ABase) + ((ThemeColorBlue(AOverlay) - ThemeColorBlue(ABase)) * LAmount div 255);
  Result := ThemeColor(ThemeColorAlpha(ABase), LR, LG, LB);
end;

function ClipTo(const AGraphics: TGPGraphics; const ARect: TRect): GraphicsState;
begin
  Result := AGraphics.Save;
  AGraphics.SetClip(MakeRect(ARect.Left, ARect.Top, ARect.Right - ARect.Left, ARect.Bottom - ARect.Top));
end;

procedure FillRect(const AGraphics: TGPGraphics; const AColor: TThemeColor; const ARect: TRect);
begin
  AGraphics.FillRectangle(TThemedGridGdiCache.Brush(AColor), ARect.Left, ARect.Top,
    ARect.Right - ARect.Left, ARect.Bottom - ARect.Top);
end;

procedure OutlineRect(const AGraphics: TGPGraphics; const AColor: TThemeColor; const ARect: TRect);
begin
  AGraphics.DrawRectangle(TThemedGridGdiCache.Pen(AColor), ARect.Left, ARect.Top,
    ARect.Right - ARect.Left - 1, ARect.Bottom - ARect.Top - 1);
end;

constructor TThemedGridControlPaint.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSelectionRenderer := TThemedGridSelectionRenderer.Create;
  FPaintArgs := TThemedGridCellPaintingEventArgs.Create;
  FHoverFilterButtonColumnIndex := -1;
  FPressedFilterButtonColumnIndex := -1;
  FDragColumnIndex := -1;
  FDragTargetColumnIndex := -1;
  FFocusedDetailParentDataSourceIndex := -1;
  FHoverDetailExpanderRowIndex := -1;
end;

destructor TThemedGridControlPaint.Destroy;
begin
  FPaintArgs.Free;
  FSelectionRenderer.Free;
  inherited Destroy;
end;

function TThemedGridControlPaint.GetPanelBackColor: TThemeColor;
begin
  if Palette <> nil then
    Result := Palette.PanelBackColor
  else
    Result := CFallbackPanel;
end;

function TThemedGridControlPaint.GetPanelForeColor: TThemeColor;
begin
  if Palette <> nil then
    Result := Palette.ControlForeColor
  else
    Result := CFallbackFore;
end;

function TThemedGridControlPaint.GetPanelBorderColor: TThemeColor;
begin
  if Palette <> nil then
    Result := Palette.ControlBorderColor
  else
    Result := CFallbackBorder;
end;

function TThemedGridControlPaint.GetPanelHoverColor: TThemeColor;
begin
  if Palette <> nil then
    Result := Palette.HoverBackColor
  else
    Result := CFallbackHover;
end;

procedure TThemedGridControlPaint.Paint;
var
  LContext: TThemedGridRenderContext;
begin
  CheckRowsChanged;
  CalculateLayout;
  NormalizeScrollValues;
  ApplyAutoSizeModes;
  BeginPainting;
  BeginDetailLayout;
  try
    LContext := TThemedGridRenderContext.Create(Canvas.Handle, ClientRect, Font, Palette, Metrics);
    try
      LContext.HorizontalOffset := HorizontalOffset;
      LContext.FirstVisibleRowIndex := FirstVisibleRowIndex;
      LContext.HeaderBounds := HeaderBounds;
      LContext.RowHeaderBounds := RowHeaderBounds;
      LContext.DataBounds := DataBounds;
      LContext.VerticalScrollBarBounds := VerticalScrollBarBounds;
      LContext.HorizontalScrollBarBounds := HorizontalScrollBarBounds;
      LContext.ScrollCornerBounds := ScrollCornerBounds;

      Renderer.DrawBackground(LContext);
      if ShowColumnHeaders and ShowRowHeaders then
        Renderer.HeaderRenderer.DrawTopLeftHeader(LContext,
          Rect(0, HeaderBounds.Top, Metrics.RowHeaderWidth, HeaderBounds.Top + GetEffectiveHeaderHeight));
      DrawColumnHeaders(LContext);
      DrawRows(LContext);
      DrawSummaryFooter(LContext);
      DrawSelectionRanges(LContext);
      DrawDropIndicator(LContext);
      DrawRowMoveIndicator(LContext);
      DrawFixedColumnSeparators(LContext);
      DrawScrollBars(LContext);
      Renderer.DrawBorder(LContext);
    finally
      LContext.Free;
    end;
  finally
    EndDetailLayout;
    EndPainting;
  end;
end;

procedure TThemedGridControlPaint.Resize;
begin
  AutoSizePending := True;
  NormalizeScrollValues;
  inherited Resize;
  Invalidate;
end;

procedure TThemedGridControlPaint.DoEnter;
begin
  inherited DoEnter;
  Invalidate;
end;

procedure TThemedGridControlPaint.DoExit;
begin
  inherited DoExit;
  Invalidate;
end;

procedure TThemedGridControlPaint.DrawDropIndicator(const AContext: TThemedGridRenderContext);
begin
end;

procedure TThemedGridControlPaint.DrawRowMoveIndicator(const AContext: TThemedGridRenderContext);
begin
end;

function TThemedGridControlPaint.TryDrawCellVisual(const AContext: TThemedGridRenderContext;
  const ACell: TThemedGridCell): Boolean;
begin
  Result := False;
end;

function TThemedGridControlPaint.TryDrawGroupVisual(const AContext: TThemedGridRenderContext;
  const AViewRow: TThemedGridViewRow; const ARowIndex: Integer; const ABounds: TRect;
  const AForeColor: TThemeColor): Boolean;
begin
  Result := False;
end;

function TThemedGridControlPaint.DrawDetailContent(const AContext: TThemedGridRenderContext;
  const AViewRow: TThemedGridViewRow; const ARowIndex: Integer; const ABounds, AContentBounds: TRect;
  const AFocused: Boolean): Boolean;
begin
  if AViewRow <> nil then
    FDetailPaintText := AViewRow.DisplayText
  else
    FDetailPaintText := '';
  Result := False;
end;

procedure TThemedGridControlPaint.EnsureDetailRowCustomized(const ARowIndex: Integer;
  const AViewRow: TThemedGridViewRow);
begin
end;

procedure TThemedGridControlPaint.BeginDetailLayout;
begin
end;

procedure TThemedGridControlPaint.EndDetailLayout;
begin
end;

procedure TThemedGridControlPaint.DrawDetailBody(const AContext: TThemedGridRenderContext;
  const AViewRow: TThemedGridViewRow; const ARowIndex: Integer; const ABounds, AContentBounds: TRect;
  const ADetailText: string);
var
  LForeColor: TThemeColor;
begin
  if ADetailText = '' then
    Exit;
  if Palette <> nil then
    LForeColor := Palette.MutedForeColor
  else
    LForeColor := CFallbackFore;
  TThemedGridGdiText.DrawText(AContext, ADetailText, Font, AContentBounds, LForeColor,
    TThemedGridContentAlignment.TopLeft, True);
end;

function TThemedGridControlPaint.GetDetailContentBounds(const ABounds: TRect): TRect;
var
  LFixedLeftWidth, LFixedRightWidth, LDetailLeft, LDetailRight: Integer;
begin
  LFixedLeftWidth := Max(0, GetFixedLeftWidth);
  LFixedRightWidth := Max(0, GetFixedRightWidth);
  LDetailLeft := DataBounds.Left + LFixedLeftWidth;
  LDetailRight := DataBounds.Right - LFixedRightWidth;
  if LDetailLeft < DataBounds.Left then
    LDetailLeft := DataBounds.Left;
  if LDetailRight > DataBounds.Right then
    LDetailRight := DataBounds.Right;
  if LDetailRight <= LDetailLeft + ScaleInt(48) then
  begin
    LDetailLeft := DataBounds.Left;
    LDetailRight := DataBounds.Right;
  end;
  Result := Rect(LDetailLeft + ScaleInt(24), ABounds.Top + ScaleInt(6), LDetailRight - ScaleInt(8),
    ABounds.Bottom - ScaleInt(6));
end;

function TThemedGridControlPaint.ResolveColumnBandName(const AColumn: TThemedGridColumn): string;
begin
  if AColumn = nil then
    Exit('');
  Result := AColumn.BandName;
end;

procedure TThemedGridControlPaint.DrawColumnHeaders(const AContext: TThemedGridRenderContext);
begin
  if not ShowColumnHeaders then
    Exit;
  if ShowColumnBandHeaders then
  begin
    DrawColumnBandHeadersInClip(AContext, TThemedGridColumnFixedStyle.None, GetScrollableHeaderViewportBounds);
    DrawColumnBandHeadersInClip(AContext, TThemedGridColumnFixedStyle.Left, GetFixedLeftHeaderViewportBounds);
    DrawColumnBandHeadersInClip(AContext, TThemedGridColumnFixedStyle.Right, GetFixedRightHeaderViewportBounds);
  end;
  DrawColumnHeadersInClip(AContext, TThemedGridColumnFixedStyle.None, GetScrollableHeaderViewportBounds);
  DrawColumnHeadersInClip(AContext, TThemedGridColumnFixedStyle.Left, GetFixedLeftHeaderViewportBounds);
  DrawColumnHeadersInClip(AContext, TThemedGridColumnFixedStyle.Right, GetFixedRightHeaderViewportBounds);
end;

procedure TThemedGridControlPaint.DrawColumnBandHeadersInClip(const AContext: TThemedGridRenderContext;
  const AFixedStyle: TThemedGridColumnFixedStyle; const AClipBounds: TRect);
var
  LState: GraphicsState;
  LColumns: TList<TThemedGridColumn>;
  I: Integer;
  LColumn: TThemedGridColumn;
  LHeaderBounds, LBandBounds, LCurrentBounds: TRect;
  LBandName, LCurrentBandName: string;
  LBand, LCurrentBand: TThemedGridColumnBand;
begin
  if IsEmptyRect(AClipBounds) then
    Exit;
  LState := ClipTo(AContext.Graphics, AClipBounds);
  try
    LColumns := GetVisibleColumns;
    LCurrentBandName := '';
    LCurrentBand := nil;
    LCurrentBounds := EmptyRect;
    for I := 0 to LColumns.Count - 1 do
    begin
      LColumn := LColumns[I];
      if LColumn.FixedStyle <> AFixedStyle then
        Continue;
      LHeaderBounds := GetHeaderCellBounds(I);
      if (LHeaderBounds.Right - LHeaderBounds.Left) <= 0 then
        Continue;
      LBandBounds := Rect(LHeaderBounds.Left, HeaderBounds.Top, LHeaderBounds.Right,
        HeaderBounds.Top + ColumnBandHeaderHeight);
      LBandName := ResolveColumnBandName(LColumn);
      if LBandName <> '' then
        LBand := ColumnBands.FindByName(LBandName)
      else
        LBand := nil;
      if (not SameText(LCurrentBandName, LBandName)) or IsEmptyRect(LCurrentBounds) then
      begin
        DrawCurrentBandHeader(AContext, LCurrentBand, LCurrentBandName, LCurrentBounds, AClipBounds);
        LCurrentBandName := LBandName;
        LCurrentBand := LBand;
        LCurrentBounds := LBandBounds;
      end
      else
        LCurrentBounds := Rect(LCurrentBounds.Left, LCurrentBounds.Top, LBandBounds.Right, LCurrentBounds.Bottom);
    end;
    DrawCurrentBandHeader(AContext, LCurrentBand, LCurrentBandName, LCurrentBounds, AClipBounds);
  finally
    AContext.Graphics.Restore(LState);
  end;
end;

procedure TThemedGridControlPaint.DrawCurrentBandHeader(const AContext: TThemedGridRenderContext;
  const ABand: TThemedGridColumnBand; const ABandName: string; const ABounds, AClipBounds: TRect);
begin
  if IsEmptyRect(ABounds) then
    Exit;
  if not IsEmptyRect(TRect.Intersect(ABounds, AClipBounds)) then
    Renderer.HeaderRenderer.DrawColumnBandHeader(AContext, ABand, ABandName, ABounds, False, False);
end;

procedure TThemedGridControlPaint.DrawColumnHeadersInClip(const AContext: TThemedGridRenderContext;
  const AFixedStyle: TThemedGridColumnFixedStyle; const AClipBounds: TRect);
var
  LState: GraphicsState;
  LColumns: TList<TThemedGridColumn>;
  I: Integer;
  LColumn: TThemedGridColumn;
  LBounds, LFilterBounds: TRect;
  LHovered, LResizeHovered: Boolean;
  LMouse: TPoint;
begin
  if IsEmptyRect(AClipBounds) then
    Exit;
  LState := ClipTo(AContext.Graphics, AClipBounds);
  try
    LColumns := GetVisibleColumns;
    LMouse := ScreenToClient(Mouse.CursorPos);
    for I := 0 to LColumns.Count - 1 do
    begin
      LColumn := LColumns[I];
      if LColumn.FixedStyle <> AFixedStyle then
        Continue;
      LBounds := GetHeaderCellBounds(I);
      if IsEmptyRect(TRect.Intersect(LBounds, AClipBounds)) then
        Continue;
      LHovered := (HoverRowIndex < 0) and (HoverColumnIndex = I);
      LResizeHovered := PtInRect(GetColumnResizeGripBounds(I), LMouse);
      Renderer.HeaderRenderer.DrawColumnHeader(AContext, LColumn, I, LBounds, LHovered, False);
      Renderer.HeaderRenderer.DrawSortGlyph(AContext, LBounds, LColumn.SortDirection);
      if LColumn.AllowFilter then
      begin
        LFilterBounds := GetColumnFilterButtonBounds(I);
        Renderer.HeaderRenderer.DrawFilterGlyph(AContext, LFilterBounds, LColumn.IsFiltered,
          FHoverFilterButtonColumnIndex = I, FPressedFilterButtonColumnIndex = I);
      end;
      if AllowColumnResize then
        Renderer.HeaderRenderer.DrawColumnResizeGrip(AContext, LBounds, LResizeHovered);
    end;
    if FDraggingColumnHeader and (FDragTargetColumnIndex >= 0) then
      DrawColumnDropMarker(AContext, FDragTargetColumnIndex);
  finally
    AContext.Graphics.Restore(LState);
  end;
end;

function TThemedGridControlPaint.GetColumnFilterButtonBounds(const AColumnIndex: Integer): TRect;
var
  LBounds: TRect;
  LColumn: TThemedGridColumn;
  LSize, LRight: Integer;
  LHeight: Integer;
begin
  LBounds := GetHeaderCellBounds(AColumnIndex);
  if IsEmptyRect(LBounds) then
    Exit(EmptyRect);
  LColumn := GetColumn(AColumnIndex);
  if (LColumn = nil) or (not LColumn.AllowFilter) then
    Exit(EmptyRect);
  LHeight := LBounds.Bottom - LBounds.Top;
  LSize := Min(22, Max(18, LHeight - 6));
  LRight := LBounds.Right - ColumnResizeGripWidth - 2;
  if LColumn.SortDirection <> TThemedGridSortDirection.None then
    Dec(LRight, 16);
  Result := Rect(LRight - LSize, LBounds.Top + (LHeight - LSize) div 2, LRight,
    LBounds.Top + (LHeight - LSize) div 2 + LSize);
  if Result.Left < LBounds.Left + 4 then
    Result := EmptyRect;
end;

function TThemedGridControlPaint.GetColumnFilterButtonIndex(const ALocation: TPoint): Integer;
var
  LColumns: TList<TThemedGridColumn>;
  I: Integer;
  LBounds: TRect;
begin
  if not ShowColumnHeaders then
    Exit(-1);
  if not PtInRect(HeaderBounds, ALocation) then
    Exit(-1);
  LColumns := GetVisibleColumns;
  for I := 0 to LColumns.Count - 1 do
  begin
    if not LColumns[I].AllowFilter then
      Continue;
    LBounds := GetColumnFilterButtonBounds(I);
    if (not IsEmptyRect(LBounds)) and PtInRect(LBounds, ALocation) then
      Exit(I);
  end;
  Result := -1;
end;

procedure TThemedGridControlPaint.DrawColumnDropMarker(const AContext: TThemedGridRenderContext;
  const AColumnIndex: Integer);
var
  LBounds: TRect;
  LX: Integer;
begin
  LBounds := GetHeaderCellBounds(AColumnIndex);
  if IsEmptyRect(LBounds) then
    Exit;
  LX := LBounds.Left;
  if FDragColumnIndex < AColumnIndex then
    LX := LBounds.Right;
  AContext.Graphics.DrawLine(TThemedGridGdiCache.Pen(AContext.FocusColor, 2.0), LX, 0, LX, DataBounds.Bottom);
end;

function TThemedGridControlPaint.GetDetailParentDataSourceIndex(const ARowIndex: Integer): Integer;
var
  LViewRow: TThemedGridViewRow;
begin
  LViewRow := GetViewRow(ARowIndex);
  if LViewRow = nil then
    Exit(-1);
  if LViewRow.IsDataRow then
    Exit(LViewRow.DataSourceIndex);
  if LViewRow.IsDetailRow then
    Exit(LViewRow.ParentDataSourceIndex);
  Result := -1;
end;

function TThemedGridControlPaint.CanExpandDetailRow(const ARowIndex: Integer): Boolean;
var
  LViewRow: TThemedGridViewRow;
begin
  if (DetailOptions = nil) or (not DetailOptions.Enabled) then
    Exit(False);
  LViewRow := GetViewRow(ARowIndex);
  if (LViewRow = nil) or (not LViewRow.IsDataRow) then
    Exit(False);
  Result := LViewRow.DataSourceIndex >= 0;
end;

function TThemedGridControlPaint.IsDetailExpanderVisible(const ARowIndex: Integer): Boolean;
begin
  if not CanExpandDetailRow(ARowIndex) then
    Exit(False);
  Result := DetailOptions.HasExpandTrigger(TThemedGridDetailExpandTrigger.RowHeaderButton);
end;

function TThemedGridControlPaint.IsDetailRowExpanded(const ARowIndex: Integer): Boolean;
var
  LDataSourceIndex: Integer;
begin
  LDataSourceIndex := GetDetailParentDataSourceIndex(ARowIndex);
  if LDataSourceIndex < 0 then
    Exit(False);
  Result := ExpandedDetailKeys.Contains(TThemedGridRowViewBuilder.CreateDetailKey(LDataSourceIndex));
end;

procedure TThemedGridControlPaint.DrawRows(const AContext: TThemedGridRenderContext);
var
  LFirst, LLast, LUsedBottom, LRowIndex: Integer;
  LViewRow: TThemedGridViewRow;
  LRow: TThemedGridRow;
  LHeaderBounds, LEmptyBounds: TRect;
  LShowExpander: Boolean;
begin
  if DataController = nil then
    Exit;
  EnsureRowView;
  GetVisibleRowRange(LFirst, LLast, LUsedBottom);
  if (LFirst >= 0) and (LLast >= LFirst) then
  begin
    for LRowIndex := LFirst to LLast do
    begin
      LViewRow := GetViewRow(LRowIndex);
      if LViewRow = nil then
        Continue;
      if LViewRow.Kind = TThemedGridViewRowKind.GroupHeader then
      begin
        DrawGroupRow(AContext, LViewRow, LRowIndex);
        Continue;
      end;
      if LViewRow.Kind = TThemedGridViewRowKind.Detail then
      begin
        EnsureDetailRowCustomized(LRowIndex, LViewRow);
        DrawDetailRow(AContext, LViewRow, LRowIndex);
        Continue;
      end;
      if not FillRow(RenderRow, LRowIndex) then
        Continue;
      LRow := RenderRow;
      LHeaderBounds := GetRowHeaderCellBounds(LRowIndex);
      if ShowRowHeaders then
      begin
        LShowExpander := IsDetailExpanderVisible(LRowIndex);
        Renderer.HeaderRenderer.DrawRowHeader(AContext, LRow, LHeaderBounds, LShowExpander,
          LShowExpander and IsDetailRowExpanded(LRowIndex),
          LShowExpander and (FHoverDetailExpanderRowIndex = LRowIndex));
      end;
      DrawRowCells(AContext, LRowIndex);
    end;
  end;
  if LUsedBottom < DataBounds.Bottom then
  begin
    LEmptyBounds := Rect(DataBounds.Left, Max(DataBounds.Top, LUsedBottom), DataBounds.Right, DataBounds.Bottom);
    Renderer.DrawEmptyArea(AContext, LEmptyBounds);
  end;
end;

function TThemedGridControlPaint.GetGroupGlyphBounds(const AViewRow: TThemedGridViewRow;
  const ARowIndex: Integer): TRect;
var
  LRowBounds: TRect;
  LFixedLeft, LFixedRight, LContentLeft, LContentRight, LIndent, LGlyphSize, LLevel, LLeft, LTop: Integer;
begin
  LRowBounds := GetRowBounds(ARowIndex);
  if IsEmptyRect(LRowBounds) then
    Exit(EmptyRect);
  LFixedLeft := Max(0, GetFixedLeftWidth);
  LFixedRight := Max(0, GetFixedRightWidth);
  LContentLeft := DataBounds.Left + LFixedLeft;
  LContentRight := DataBounds.Right - LFixedRight;
  if LContentLeft < DataBounds.Left then
    LContentLeft := DataBounds.Left;
  if LContentRight > DataBounds.Right then
    LContentRight := DataBounds.Right;
  if LContentRight <= LContentLeft + ScaleInt(48) then
  begin
    LContentLeft := DataBounds.Left;
    LContentRight := DataBounds.Right;
  end;
  if GroupingOptions <> nil then
  begin
    LIndent := ScaleInt(GroupingOptions.IndentWidth);
    LGlyphSize := ScaleInt(GroupingOptions.GlyphSize);
  end
  else
  begin
    LIndent := ScaleInt(18);
    LGlyphSize := ScaleInt(11);
  end;
  if AViewRow <> nil then
    LLevel := Max(0, AViewRow.Level)
  else
    LLevel := 0;
  LLeft := LContentLeft + ScaleInt(8) + LLevel * LIndent;
  LTop := LRowBounds.Top + ((LRowBounds.Bottom - LRowBounds.Top) - LGlyphSize) div 2;
  if LLeft + LGlyphSize > LContentRight - ScaleInt(4) then
    Exit(EmptyRect);
  Result := Rect(LLeft, LTop, LLeft + LGlyphSize, LTop + LGlyphSize);
end;

procedure TThemedGridControlPaint.DrawGroupGlyph(const AContext: TThemedGridRenderContext; const ABounds: TRect;
  const AExpanded: Boolean; const AGlyphColor, ABorderColor: TThemeColor);
var
  LPoints: array[0..2] of TGPPointF;
  LWidth, LHeight: Single;
begin
  if IsEmptyRect(ABounds) then
    Exit;
  OutlineRect(AContext.Graphics, ABorderColor, ABounds);
  LWidth := ABounds.Right - ABounds.Left;
  LHeight := ABounds.Bottom - ABounds.Top;
  if AExpanded then
  begin
    LPoints[0] := MakePoint(ABounds.Left + LWidth * 0.25, ABounds.Top + LHeight * 0.38);
    LPoints[1] := MakePoint(ABounds.Left + LWidth * 0.75, ABounds.Top + LHeight * 0.38);
    LPoints[2] := MakePoint(ABounds.Left + LWidth * 0.5, ABounds.Top + LHeight * 0.68);
  end
  else
  begin
    LPoints[0] := MakePoint(ABounds.Left + LWidth * 0.4, ABounds.Top + LHeight * 0.25);
    LPoints[1] := MakePoint(ABounds.Left + LWidth * 0.4, ABounds.Top + LHeight * 0.75);
    LPoints[2] := MakePoint(ABounds.Left + LWidth * 0.7, ABounds.Top + LHeight * 0.5);
  end;
  AContext.Graphics.FillPolygon(TThemedGridGdiCache.Brush(AGlyphColor), PGPPointF(@LPoints[0]), 3);
end;

procedure TThemedGridControlPaint.DrawGroupRow(const AContext: TThemedGridRenderContext;
  const AViewRow: TThemedGridViewRow; const ARowIndex: Integer);
var
  LBounds, LDataRowBounds, LFixedLeftBounds, LFixedRightBounds, LContentBounds, LHeaderBounds, LGlyphBounds, LTextBounds: TRect;
  LBackColor, LForeColor, LBorderColor, LGlyphColor, LLevelLineColor: TThemeColor;
  LFixedLeftWidth, LFixedRightWidth, LContentLeft, LContentRight, LTextLeft: Integer;
  LVisualHandled: Boolean;
  LFont: TFont;
  LGraphics: TGPGraphics;
begin
  if (AContext = nil) or (AContext.Graphics = nil) or (AViewRow = nil) then
    Exit;
  LBounds := GetRowBounds(ARowIndex);
  if IsEmptyRect(LBounds) then
    Exit;
  LGraphics := AContext.Graphics;
  LBackColor := GetPanelBackColor;
  LForeColor := GetPanelForeColor;
  LBorderColor := GetPanelBorderColor;
  LGlyphColor := LForeColor;
  LLevelLineColor := WithAlpha(LBorderColor, 80);
  if ARowIndex = HoverRowIndex then
    LBackColor := GetPanelHoverColor;

  LFixedLeftWidth := Max(0, GetFixedLeftWidth);
  LFixedRightWidth := Max(0, GetFixedRightWidth);
  LDataRowBounds := Rect(DataBounds.Left, LBounds.Top, DataBounds.Right, LBounds.Bottom);
  if LFixedLeftWidth > 0 then
    LFixedLeftBounds := Rect(DataBounds.Left, LBounds.Top,
      DataBounds.Left + Min(LFixedLeftWidth, DataBounds.Right - DataBounds.Left), LBounds.Bottom)
  else
    LFixedLeftBounds := EmptyRect;
  if LFixedRightWidth > 0 then
    LFixedRightBounds := Rect(Max(DataBounds.Left, DataBounds.Right - LFixedRightWidth), LBounds.Top,
      Max(DataBounds.Left, DataBounds.Right - LFixedRightWidth) + Min(LFixedRightWidth, DataBounds.Right - DataBounds.Left),
      LBounds.Bottom)
  else
    LFixedRightBounds := EmptyRect;

  LContentLeft := DataBounds.Left + LFixedLeftWidth;
  LContentRight := DataBounds.Right - LFixedRightWidth;
  if LContentLeft < DataBounds.Left then
    LContentLeft := DataBounds.Left;
  if LContentRight > DataBounds.Right then
    LContentRight := DataBounds.Right;
  if LContentRight <= LContentLeft + ScaleInt(48) then
  begin
    LContentLeft := DataBounds.Left;
    LContentRight := DataBounds.Right;
    LFixedLeftBounds := EmptyRect;
    LFixedRightBounds := EmptyRect;
  end;
  LContentBounds := Rect(LContentLeft, LBounds.Top, LContentRight, LBounds.Bottom);

  FillRect(LGraphics, LBackColor, LDataRowBounds);
  if not IsEmptyRect(LFixedLeftBounds) then
    FillRect(LGraphics, LBackColor, LFixedLeftBounds);
  if not IsEmptyRect(LFixedRightBounds) then
    FillRect(LGraphics, LBackColor, LFixedRightBounds);

  if ShowRowHeaders then
  begin
    LHeaderBounds := GetRowHeaderCellBounds(ARowIndex);
    FillRect(LGraphics, LBackColor, LHeaderBounds);
    OutlineRect(LGraphics, LBorderColor, LHeaderBounds);
  end;

  LGlyphBounds := GetGroupGlyphBounds(AViewRow, ARowIndex);
  if (not IsEmptyRect(LGlyphBounds)) and PtInRect(LContentBounds, Point(LGlyphBounds.Left, LGlyphBounds.Top)) then
    DrawGroupGlyph(AContext, LGlyphBounds, AViewRow.Expanded, LGlyphColor, LBorderColor);

  if IsEmptyRect(LGlyphBounds) then
    LTextLeft := LContentBounds.Left + ScaleInt(8)
  else
    LTextLeft := LGlyphBounds.Right + ScaleInt(7);
  if LTextLeft < LContentBounds.Left + ScaleInt(8) then
    LTextLeft := LContentBounds.Left + ScaleInt(8);
  LTextBounds := Rect(LTextLeft, LContentBounds.Top, LContentBounds.Right - ScaleInt(8), LContentBounds.Bottom);

  LVisualHandled := False;
  if (LTextBounds.Right - LTextBounds.Left) > ScaleInt(12) then
    LVisualHandled := TryDrawGroupVisual(AContext, AViewRow, ARowIndex, LTextBounds, LForeColor);

  if (not LVisualHandled) and ((LTextBounds.Right - LTextBounds.Left) > ScaleInt(12)) then
  begin
    if AViewRow.Level <= 0 then
    begin
      LFont := TFont.Create;
      try
        LFont.Assign(Font);
        LFont.Style := LFont.Style + [fsBold];
        TThemedGridGdiText.DrawText(AContext, AViewRow.DisplayText, LFont, LTextBounds, LForeColor,
          TThemedGridContentAlignment.MiddleLeft, True);
      finally
        LFont.Free;
      end;
    end
    else
      TThemedGridGdiText.DrawText(AContext, AViewRow.DisplayText, Font, LTextBounds, LForeColor,
        TThemedGridContentAlignment.MiddleLeft, True);
  end;

  LGraphics.DrawLine(TThemedGridGdiCache.Pen(LLevelLineColor), LContentBounds.Left, LContentBounds.Bottom - 1,
    LContentBounds.Right, LContentBounds.Bottom - 1);
  if not IsEmptyRect(LFixedLeftBounds) then
    LGraphics.DrawLine(TThemedGridGdiCache.Pen(LLevelLineColor), LFixedLeftBounds.Left, LFixedLeftBounds.Bottom - 1,
      LFixedLeftBounds.Right, LFixedLeftBounds.Bottom - 1);
  if not IsEmptyRect(LFixedRightBounds) then
    LGraphics.DrawLine(TThemedGridGdiCache.Pen(LLevelLineColor), LFixedRightBounds.Left, LFixedRightBounds.Bottom - 1,
      LFixedRightBounds.Right, LFixedRightBounds.Bottom - 1);
end;

procedure TThemedGridControlPaint.DrawDetailRow(const AContext: TThemedGridRenderContext;
  const AViewRow: TThemedGridViewRow; const ARowIndex: Integer);
var
  LBounds, LFixedLeftBounds, LFixedRightBounds, LDetailBounds, LHeaderBounds, LContentBounds, LFocusBounds: TRect;
  LBackColor, LFixedBackColor, LBorderColor, LAccentColor: TThemeColor;
  LFixedLeftWidth, LFixedRightWidth, LDetailLeft, LDetailRight, LX, LY1, LY2: Integer;
  LFocused: Boolean;
  LGraphics: TGPGraphics;
  LPen: TGPPen;
begin
  if (AContext = nil) or (AContext.Graphics = nil) or (AViewRow = nil) then
    Exit;
  LBounds := GetRowBounds(ARowIndex);
  if IsEmptyRect(LBounds) then
    Exit;
  LGraphics := AContext.Graphics;
  if Palette <> nil then
  begin
    LBackColor := Palette.ControlBackColor;
    LAccentColor := Palette.AccentColor;
  end
  else
  begin
    LBackColor := AContext.BackColor;
    LAccentColor := CFallbackAccent;
  end;
  LFixedBackColor := GetPanelBackColor;
  LBorderColor := GetPanelBorderColor;
  LFocused := (DetailOptions <> nil) and (AViewRow.ParentDataSourceIndex >= 0) and
    (AViewRow.ParentDataSourceIndex = FFocusedDetailParentDataSourceIndex);

  LFixedLeftWidth := Max(0, GetFixedLeftWidth);
  LFixedRightWidth := Max(0, GetFixedRightWidth);
  if LFixedLeftWidth > 0 then
    LFixedLeftBounds := Rect(DataBounds.Left, LBounds.Top,
      DataBounds.Left + Min(LFixedLeftWidth, DataBounds.Right - DataBounds.Left), LBounds.Bottom)
  else
    LFixedLeftBounds := EmptyRect;
  if LFixedRightWidth > 0 then
    LFixedRightBounds := Rect(Max(DataBounds.Left, DataBounds.Right - LFixedRightWidth), LBounds.Top,
      Max(DataBounds.Left, DataBounds.Right - LFixedRightWidth) + Min(LFixedRightWidth, DataBounds.Right - DataBounds.Left),
      LBounds.Bottom)
  else
    LFixedRightBounds := EmptyRect;
  LDetailLeft := DataBounds.Left + LFixedLeftWidth;
  LDetailRight := DataBounds.Right - LFixedRightWidth;
  if LDetailLeft < DataBounds.Left then
    LDetailLeft := DataBounds.Left;
  if LDetailRight > DataBounds.Right then
    LDetailRight := DataBounds.Right;
  if LDetailRight <= LDetailLeft + ScaleInt(48) then
  begin
    LDetailLeft := DataBounds.Left;
    LDetailRight := DataBounds.Right;
    LFixedLeftBounds := EmptyRect;
    LFixedRightBounds := EmptyRect;
  end;
  LDetailBounds := Rect(LDetailLeft, LBounds.Top, LDetailRight, LBounds.Bottom);

  FillRect(LGraphics, LBackColor, LBounds);
  if not IsEmptyRect(LFixedLeftBounds) then
  begin
    FillRect(LGraphics, LFixedBackColor, LFixedLeftBounds);
    LGraphics.DrawLine(TThemedGridGdiCache.Pen(LBorderColor), LFixedLeftBounds.Right - 1, LFixedLeftBounds.Top,
      LFixedLeftBounds.Right - 1, LFixedLeftBounds.Bottom - 1);
  end;
  if not IsEmptyRect(LFixedRightBounds) then
  begin
    FillRect(LGraphics, LFixedBackColor, LFixedRightBounds);
    LGraphics.DrawLine(TThemedGridGdiCache.Pen(LBorderColor), LFixedRightBounds.Left, LFixedRightBounds.Top,
      LFixedRightBounds.Left, LFixedRightBounds.Bottom - 1);
  end;
  if ShowRowHeaders then
  begin
    LHeaderBounds := GetRowHeaderCellBounds(ARowIndex);
    FillRect(LGraphics, LFixedBackColor, LHeaderBounds);
    OutlineRect(LGraphics, LBorderColor, LHeaderBounds);
  end;

  LContentBounds := Rect(LDetailBounds.Left + ScaleInt(24), LBounds.Top + ScaleInt(6),
    LDetailBounds.Right - ScaleInt(8), LBounds.Bottom - ScaleInt(6));

  if DrawDetailContent(AContext, AViewRow, ARowIndex, LBounds, LContentBounds, LFocused) then
    Exit;
  if LFocused and DetailOptions.ShowFocusedDetailBorder then
  begin
    LFocusBounds := Rect(LDetailBounds.Left + ScaleInt(10), LBounds.Top + ScaleInt(5),
      LDetailBounds.Right - ScaleInt(10), LBounds.Bottom - ScaleInt(5));
    LPen := TGPPen.Create(MakeColor(DetailOptions.FocusedDetailBorderAlpha, ThemeColorRed(LAccentColor),
      ThemeColorGreen(LAccentColor), ThemeColorBlue(LAccentColor)), 1);
    try
      LPen.SetDashStyle(DashStyleDot);
      LPen.SetAlignment(PenAlignmentInset);
      LGraphics.DrawRectangle(LPen, LFocusBounds.Left, LFocusBounds.Top,
        Max(0, LFocusBounds.Right - LFocusBounds.Left - 1), Max(0, LFocusBounds.Bottom - LFocusBounds.Top - 1));
    finally
      LPen.Free;
    end;
  end;
  if LFocused and DetailOptions.ShowFocusedDetailLine then
  begin
    LX := LDetailBounds.Left + ScaleInt(12);
    LY1 := LBounds.Top + ScaleInt(6);
    LY2 := LBounds.Bottom - ScaleInt(6);
    LGraphics.DrawLine(TThemedGridGdiCache.Pen(WithAlpha(LAccentColor, DetailOptions.FocusedDetailLineAlpha),
      Max(1, ScaleInt(2))), LX, LY1, LX, LY2);
  end;

  DrawDetailBody(AContext, AViewRow, ARowIndex, LBounds, LContentBounds, FDetailPaintText);
  LGraphics.DrawLine(TThemedGridGdiCache.Pen(LBorderColor), DataBounds.Left, LBounds.Bottom - 1,
    DataBounds.Right, LBounds.Bottom - 1);
end;

procedure TThemedGridControlPaint.DrawRowCells(const AContext: TThemedGridRenderContext; const ARowIndex: Integer);
begin
  DrawRowCellsInClip(AContext, ARowIndex, TThemedGridColumnFixedStyle.None, GetScrollableViewportBounds);
  DrawRowCellsInClip(AContext, ARowIndex, TThemedGridColumnFixedStyle.Left, GetFixedLeftViewportBounds);
  DrawRowCellsInClip(AContext, ARowIndex, TThemedGridColumnFixedStyle.Right, GetFixedRightViewportBounds);
end;

procedure TThemedGridControlPaint.DrawRowCellsInClip(const AContext: TThemedGridRenderContext;
  const ARowIndex: Integer; const AFixedStyle: TThemedGridColumnFixedStyle; const AClipBounds: TRect);
var
  LState: GraphicsState;
  LColumns: TList<TThemedGridColumn>;
  LRowStyle: TThemedGridFormatStyle;
  LColumnIndex: Integer;
  LColumn: TThemedGridColumn;
  LBounds: TRect;
  LRenderer: IThemedGridCellRenderer;
begin
  if IsEmptyRect(AClipBounds) then
    Exit;
  LState := ClipTo(AContext.Graphics, AClipBounds);
  try
    LColumns := GetVisibleColumns;
    LRowStyle := CreateRowStyle(ARowIndex, AContext);
    for LColumnIndex := 0 to LColumns.Count - 1 do
    begin
      LColumn := LColumns[LColumnIndex];
      if LColumn.FixedStyle <> AFixedStyle then
        Continue;
      LBounds := GetCellBounds(ARowIndex, LColumnIndex);
      if IsEmptyRect(TRect.Intersect(LBounds, AClipBounds)) then
        Continue;
      if not FillCell(RenderCell, ARowIndex, LColumnIndex, True) then
        Continue;
      RenderCell.Bounds := LBounds;
      ApplyCellVisualStyle(RenderCell, LRowStyle, AContext);
      FillCellEventArgs(FPaintArgs, RenderCell);
      FPaintArgs.Graphics := AContext.Graphics;
      FPaintArgs.State := RenderCell.State;
      FPaintArgs.Handled := False;
      DoCellPainting(FPaintArgs);
      if not FPaintArgs.Handled then
        if not TryDrawCellVisual(AContext, RenderCell) then
        begin
          LRenderer := Renderer.ResolveCellRenderer(RenderCell);
          LRenderer.Draw(AContext, RenderCell);
        end;
    end;
  finally
    AContext.Graphics.Restore(LState);
  end;
end;

procedure TThemedGridControlPaint.DrawFixedSeparator(const AContext: TThemedGridRenderContext; const AX: Integer;
  const AFooterBottom: Integer);
var
  LFirst, LLast, LUsedBottom, LRowIndex: Integer;
  LViewRow: TThemedGridViewRow;
  LRowBounds: TRect;
  LPen: TGPPen;
  LGraphics: TGPGraphics;
begin
  LGraphics := AContext.Graphics;
  LPen := TThemedGridGdiCache.Pen(AContext.FocusColor);
  LGraphics.DrawLine(LPen, AX, HeaderBounds.Top, AX, DataBounds.Top);
  GetVisibleRowRange(LFirst, LLast, LUsedBottom);
  if (LFirst >= 0) and (LLast >= LFirst) then
  begin
    for LRowIndex := LFirst to LLast do
    begin
      LViewRow := GetViewRow(LRowIndex);
      LRowBounds := GetRowBounds(LRowIndex);
      if IsEmptyRect(LRowBounds) then
        Continue;
      if (LViewRow <> nil) and (LViewRow.Kind = TThemedGridViewRowKind.GroupHeader) then
        Continue;
      LGraphics.DrawLine(LPen, AX, LRowBounds.Top, AX, LRowBounds.Bottom - 1);
    end;
    if LUsedBottom < DataBounds.Bottom then
      LGraphics.DrawLine(LPen, AX, Max(DataBounds.Top, LUsedBottom), AX, DataBounds.Bottom);
  end
  else
    LGraphics.DrawLine(LPen, AX, DataBounds.Top, AX, DataBounds.Bottom);
  if AFooterBottom > DataBounds.Bottom then
    LGraphics.DrawLine(LPen, AX, DataBounds.Bottom, AX, AFooterBottom);
end;

procedure TThemedGridControlPaint.DrawFixedColumnSeparators(const AContext: TThemedGridRenderContext);
var
  LLeftBounds, LRightBounds: TRect;
  LBottom: Integer;
begin
  if (AContext = nil) or (AContext.Graphics = nil) then
    Exit;
  LLeftBounds := GetFixedLeftViewportBounds;
  LRightBounds := GetFixedRightViewportBounds;
  if not IsEmptyRect(SummaryFooterBounds) then
    LBottom := SummaryFooterBounds.Bottom
  else
    LBottom := DataBounds.Bottom;
  if not IsEmptyRect(LLeftBounds) then
    DrawFixedSeparator(AContext, LLeftBounds.Right - 1, LBottom);
  if not IsEmptyRect(LRightBounds) then
    DrawFixedSeparator(AContext, LRightBounds.Left, LBottom);
end;

procedure TThemedGridControlPaint.DrawSummaryFooter(const AContext: TThemedGridRenderContext);
begin
  if not ShowSummaryFooter then
    Exit;
  if IsEmptyRect(SummaryFooterBounds) then
    Exit;
  DrawSummaryFooterBackground(AContext);
  DrawSummaryFooterInClip(AContext, TThemedGridColumnFixedStyle.None, GetScrollableSummaryFooterViewportBounds);
  DrawSummaryFooterInClip(AContext, TThemedGridColumnFixedStyle.Left, GetFixedLeftSummaryFooterViewportBounds);
  DrawSummaryFooterInClip(AContext, TThemedGridColumnFixedStyle.Right, GetFixedRightSummaryFooterViewportBounds);
  if ShowRowHeaders and (Metrics.RowHeaderWidth > 0) then
    DrawSummaryFooterRowHeader(AContext);
end;

procedure TThemedGridControlPaint.DrawSummaryFooterBackground(const AContext: TThemedGridRenderContext);
begin
  FillRect(AContext.Graphics, GetPanelBackColor, SummaryFooterBounds);
  AContext.Graphics.DrawLine(TThemedGridGdiCache.Pen(AContext.GridLineColor), SummaryFooterBounds.Left,
    SummaryFooterBounds.Top, SummaryFooterBounds.Right, SummaryFooterBounds.Top);
end;

procedure TThemedGridControlPaint.DrawSummaryFooterRowHeader(const AContext: TThemedGridRenderContext);
var
  LBounds: TRect;
begin
  LBounds := Rect(0, SummaryFooterBounds.Top, Metrics.RowHeaderWidth, SummaryFooterBounds.Bottom);
  FillRect(AContext.Graphics, GetPanelBackColor, LBounds);
  TThemedGridGdiText.DrawText(AContext, TThemedGridPaintStrings.SummaryRowHeaderGlyph, Font, LBounds,
    AContext.HeaderForeColor, TThemedGridContentAlignment.MiddleCenter, False);
  AContext.Graphics.DrawLine(TThemedGridGdiCache.Pen(AContext.GridLineColor), LBounds.Left, LBounds.Top,
    LBounds.Right, LBounds.Top);
  AContext.Graphics.DrawLine(TThemedGridGdiCache.Pen(AContext.GridLineColor), LBounds.Right - 1, LBounds.Top,
    LBounds.Right - 1, LBounds.Bottom);
end;

procedure TThemedGridControlPaint.DrawSummaryFooterInClip(const AContext: TThemedGridRenderContext;
  const AFixedStyle: TThemedGridColumnFixedStyle; const AClipBounds: TRect);
var
  LState: GraphicsState;
  LColumns: TList<TThemedGridColumn>;
  LColumnIndex: Integer;
  LColumn: TThemedGridColumn;
  LBounds: TRect;
begin
  if IsEmptyRect(AClipBounds) then
    Exit;
  LState := ClipTo(AContext.Graphics, AClipBounds);
  try
    LColumns := GetVisibleColumns;
    for LColumnIndex := 0 to LColumns.Count - 1 do
    begin
      LColumn := LColumns[LColumnIndex];
      if LColumn.FixedStyle <> AFixedStyle then
        Continue;
      LBounds := GetSummaryFooterCellBounds(LColumnIndex);
      if IsEmptyRect(TRect.Intersect(LBounds, AClipBounds)) then
        Continue;
      DrawSummaryFooterCell(AContext, LColumnIndex, LColumn, LBounds);
    end;
  finally
    AContext.Graphics.Restore(LState);
  end;
end;

procedure TThemedGridControlPaint.DrawSummaryFooterCell(const AContext: TThemedGridRenderContext;
  const AColumnIndex: Integer; const AColumn: TThemedGridColumn; const ABounds: TRect);
var
  LBackColor, LForeColor, LLineColor: TThemeColor;
  LText: string;
  LPadding: Integer;
  LTextBounds: TRect;
  LFont: TFont;
  LGraphics: TGPGraphics;
begin
  LGraphics := AContext.Graphics;
  LBackColor := GetPanelBackColor;
  LForeColor := GetPanelForeColor;
  LLineColor := AContext.GridLineColor;
  if AColumnIndex = SummaryPressedColumnIndex then
    LBackColor := BlendThemeColor(LBackColor, CFallbackBlack, 32)
  else if AColumnIndex = SummaryHoverColumnIndex then
    LBackColor := BlendThemeColor(LBackColor, CFallbackWhite, 18);
  FillRect(LGraphics, LBackColor, ABounds);
  LGraphics.DrawLine(TThemedGridGdiCache.Pen(LLineColor), ABounds.Left, ABounds.Top, ABounds.Right, ABounds.Top);
  LGraphics.DrawLine(TThemedGridGdiCache.Pen(LLineColor), ABounds.Left, ABounds.Bottom - 1, ABounds.Right,
    ABounds.Bottom - 1);
  LGraphics.DrawLine(TThemedGridGdiCache.Pen(LLineColor), ABounds.Right - 1, ABounds.Top, ABounds.Right - 1,
    ABounds.Bottom);
  LText := GetSummaryText(AColumn);
  if LText = '' then
    Exit;
  LPadding := Max(4, ScaleInt(7));
  LTextBounds := Rect(ABounds.Left + LPadding, ABounds.Top, ABounds.Right - LPadding, ABounds.Bottom);
  if (AColumn.SummaryType = TThemedGridSummaryType.Sum) or (AColumn.SummaryType = TThemedGridSummaryType.Average) then
  begin
    LFont := TFont.Create;
    try
      LFont.Assign(Font);
      LFont.Style := LFont.Style + [fsBold];
      TThemedGridGdiText.DrawText(AContext, LText, LFont, LTextBounds, LForeColor, AColumn.TextAlignment, True);
    finally
      LFont.Free;
    end;
  end
  else
    TThemedGridGdiText.DrawText(AContext, LText, Font, LTextBounds, LForeColor, AColumn.TextAlignment, True);
end;

procedure TThemedGridControlPaint.DrawSelectedRows(const AContext: TThemedGridRenderContext);
var
  LRange: TThemedGridCellRange;
  LFirstVisible, LLastVisible, LUsedBottom, LFirstRow, LLastRow, LRowIndex: Integer;
begin
  if (SelectionMode <> TThemedGridSelectionMode.Row) and (SelectionMode <> TThemedGridSelectionMode.RowRange) then
    Exit;
  LRange := SelectionModel.PrimaryRange;
  if LRange.IsValid and (LRange.RowCount > 1) then
  begin
    GetVisibleRowRange(LFirstVisible, LLastVisible, LUsedBottom);
    if (LFirstVisible < 0) or (LLastVisible < LFirstVisible) then
      Exit;
    LFirstRow := Max(LRange.Row1, LFirstVisible);
    LLastRow := Min(LRange.Row2, LLastVisible);
    for LRowIndex := LFirstRow to LLastRow do
      DrawSelectedRow(AContext, LRowIndex);
    Exit;
  end;
  if CurrentRowIndex >= 0 then
    DrawSelectedRow(AContext, CurrentRowIndex);
end;

procedure TThemedGridControlPaint.DrawSelectedRow(const AContext: TThemedGridRenderContext; const ARowIndex: Integer);
var
  LBounds, LRowBounds: TRect;
begin
  LBounds := GetRowBounds(ARowIndex);
  if IsEmptyRect(LBounds) then
    Exit;
  LRowBounds := TRect.Intersect(Rect(DataBounds.Left, LBounds.Top, DataBounds.Right, LBounds.Bottom), DataBounds);
  if not IsEmptyRect(LRowBounds) then
    FSelectionRenderer.DrawRow(AContext, LRowBounds);
end;

function TThemedGridControlPaint.GetColumnVisibleBounds(const AColumnIndex: Integer): TRect;
var
  LColumns: TList<TThemedGridColumn>;
  LFirstCell, LClip: TRect;
begin
  LColumns := GetVisibleColumns;
  if (AColumnIndex < 0) or (AColumnIndex >= LColumns.Count) then
    Exit(EmptyRect);
  LFirstCell := GetCellBounds(FirstVisibleRowIndex, AColumnIndex);
  if IsEmptyRect(LFirstCell) then
    Exit(EmptyRect);
  Result := Rect(LFirstCell.Left, DataBounds.Top, LFirstCell.Right, DataBounds.Bottom);
  if LColumns[AColumnIndex].FixedStyle = TThemedGridColumnFixedStyle.Left then
    LClip := GetFixedLeftViewportBounds
  else if LColumns[AColumnIndex].FixedStyle = TThemedGridColumnFixedStyle.Right then
    LClip := GetFixedRightViewportBounds
  else
    LClip := GetScrollableViewportBounds;
  Result := TRect.Intersect(Result, LClip);
end;

procedure TThemedGridControlPaint.DrawSelectedColumns(const AContext: TThemedGridRenderContext);
var
  LBounds: TRect;
begin
  if (SelectionMode <> TThemedGridSelectionMode.Column) and (SelectionMode <> TThemedGridSelectionMode.ColumnRange) then
    Exit;
  if CurrentColumnIndex < 0 then
    Exit;
  LBounds := GetColumnVisibleBounds(CurrentColumnIndex);
  if IsEmptyRect(LBounds) then
    Exit;
  FSelectionRenderer.DrawColumn(AContext, LBounds);
end;

function TThemedGridControlPaint.GetRangeBounds(const ARange: TThemedGridCellRange;
  const AFixedStyle: TThemedGridColumnFixedStyle; const AClipBounds: TRect): TRect;
var
  LFirstVisible, LLastVisible, LUsedBottom, LFirstRow, LLastRow, LRowIndex, LColumnIndex: Integer;
  LColumns: TList<TThemedGridColumn>;
  LCellBounds: TRect;
begin
  Result := EmptyRect;
  if not ARange.IsValid then
    Exit;
  GetVisibleRowRange(LFirstVisible, LLastVisible, LUsedBottom);
  if (LFirstVisible < 0) or (LLastVisible < LFirstVisible) then
    Exit;
  LColumns := GetVisibleColumns;
  LFirstRow := Max(ARange.Row1, LFirstVisible);
  LLastRow := Min(ARange.Row2, LLastVisible);
  for LRowIndex := LFirstRow to LLastRow do
    for LColumnIndex := ARange.Column1 to ARange.Column2 do
    begin
      if (LColumnIndex < 0) or (LColumnIndex >= LColumns.Count) then
        Continue;
      if LColumns[LColumnIndex].FixedStyle <> AFixedStyle then
        Continue;
      LCellBounds := GetCellBounds(LRowIndex, LColumnIndex);
      if IsEmptyRect(TRect.Intersect(LCellBounds, AClipBounds)) then
        Continue;
      LCellBounds := TRect.Intersect(LCellBounds, AClipBounds);
      if IsEmptyRect(Result) then
        Result := LCellBounds
      else
        Result := TRect.Union(Result, LCellBounds);
    end;
  if IsEmptyRect(Result) then
    Exit(EmptyRect);
  Result := TRect.Intersect(Result, AClipBounds);
end;

procedure TThemedGridControlPaint.DrawSelectionRangeInClip(const AContext: TThemedGridRenderContext;
  const ARange: TThemedGridCellRange; const AFixedStyle: TThemedGridColumnFixedStyle; const AClipBounds: TRect);
var
  LBounds: TRect;
  LState: GraphicsState;
begin
  if IsEmptyRect(AClipBounds) then
    Exit;
  LBounds := GetRangeBounds(ARange, AFixedStyle, AClipBounds);
  if IsEmptyRect(LBounds) then
    Exit;
  LState := ClipTo(AContext.Graphics, AClipBounds);
  try
    FSelectionRenderer.DrawRange(AContext, LBounds);
  finally
    AContext.Graphics.Restore(LState);
  end;
end;

procedure TThemedGridControlPaint.DrawSelectionRanges(const AContext: TThemedGridRenderContext);
var
  LRange: TThemedGridCellRange;
  LAnchor: TThemedGridCurrentCell;
  LAnchorBounds: TRect;
begin
  DrawSelectedRows(AContext);
  DrawSelectedColumns(AContext);
  LRange := SelectionModel.PrimaryRange;
  if not LRange.IsValid then
    Exit;
  if (LRange.RowCount <= 1) and (LRange.ColumnCount <= 1) then
    Exit;
  DrawSelectionRangeInClip(AContext, LRange, TThemedGridColumnFixedStyle.None, GetScrollableViewportBounds);
  DrawSelectionRangeInClip(AContext, LRange, TThemedGridColumnFixedStyle.Left, GetFixedLeftViewportBounds);
  DrawSelectionRangeInClip(AContext, LRange, TThemedGridColumnFixedStyle.Right, GetFixedRightViewportBounds);
  LAnchor := SelectionModel.AnchorCell;
  if LAnchor.IsValid then
  begin
    LAnchorBounds := GetCellBounds(LAnchor.RowIndex, LAnchor.ColumnIndex);
    if (not IsEmptyRect(LAnchorBounds)) and (not IsEmptyRect(TRect.Intersect(LAnchorBounds, DataBounds))) then
      FSelectionRenderer.DrawAnchor(AContext, LAnchorBounds);
  end;
end;

procedure TThemedGridControlPaint.DrawScrollBars(const AContext: TThemedGridRenderContext);
begin
  if VerticalScrollVisible then
  begin
    Renderer.DrawScrollBarTrack(AContext, VerticalScrollBarBounds, True);
    Renderer.DrawScrollBarThumb(AContext, VerticalScrollThumbBounds, False, FDraggingVerticalScrollThumb);
  end;
  if HorizontalScrollVisible then
  begin
    Renderer.DrawScrollBarTrack(AContext, HorizontalScrollBarBounds, False);
    Renderer.DrawScrollBarThumb(AContext, HorizontalScrollThumbBounds, False, FDraggingHorizontalScrollThumb);
  end;
  if VerticalScrollVisible and HorizontalScrollVisible then
    Renderer.DrawScrollCorner(AContext, ScrollCornerBounds);
end;

end.

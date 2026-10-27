unit NimbusForms.Grid.CellRenderer;

{$SCOPEDENUMS ON}

interface

uses
  System.Types,
  Vcl.Graphics,
  NimbusForms.Theming.Types,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Cell,
  NimbusForms.Grid.HitInfo,
  NimbusForms.Grid.RenderContext,
  NimbusForms.Grid.CellRendererParts,
  NimbusForms.Grid.CellRendererIntf;

type
  TThemedGridCellRenderer = class(TInterfacedObject, IThemedGridCellRenderer)
  public
    procedure Draw(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell);
    function Measure(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell): TSize;
    function HitTestContent(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell;
      const ALocation: TPoint): TThemedGridHitInfo;
  end;

implementation

uses
  NimbusForms.Grid.GdiText;

function ResolveCellText(const ACell: TThemedGridCell): string;
begin
  if ACell = nil then
    Exit('');
  if ACell.DisplayText <> '' then
    Exit(ACell.DisplayText);
  if not ACell.Value.IsEmpty then
    Exit(ACell.Value.ToString);
  Result := '';
end;

procedure TThemedGridCellRenderer.Draw(const AContext: TThemedGridRenderContext;
  const ACell: TThemedGridCell);
var
  LBounds, LTextBounds: TRect;
  LText: string;
  LAlignment: TThemedGridContentAlignment;
  LForeColor: TThemeColor;
  LFont: TFont;
begin
  if (AContext = nil) or (AContext.Graphics = nil) or (ACell = nil) then
    Exit;
  LBounds := ACell.Bounds;
  if (LBounds.Width <= 0) or (LBounds.Height <= 0) then
    Exit;

  TThemedGridCellRendererParts.FillCell(AContext, ACell);
  TThemedGridCellRendererParts.DrawSearchHighlight(AContext, ACell);

  LTextBounds := TThemedGridCellRendererParts.GetContentBounds(AContext, LBounds);
  LText := ResolveCellText(ACell);

  if ACell.Column <> nil then
    LAlignment := ACell.Column.TextAlignment
  else
    LAlignment := TThemedGridContentAlignment.MiddleLeft;

  LForeColor := TThemedGridCellRendererParts.GetCellForeColor(AContext, ACell);
  LFont := TThemedGridCellRendererParts.GetCellFont(AContext, ACell);
  try
    TThemedGridGdiText.DrawText(AContext, LText, LFont, LTextBounds, LForeColor, LAlignment, True);
  finally
    if TThemedGridCellRendererParts.RequiresDisposableFont(AContext, ACell, LFont) then
      LFont.Free;
  end;

  TThemedGridCellRendererParts.DrawGridLines(AContext, ACell);
  TThemedGridCellRendererParts.DrawFocus(AContext, ACell);
  TThemedGridCellRendererParts.DrawError(AContext, ACell);
end;

function TThemedGridCellRenderer.Measure(const AContext: TThemedGridRenderContext;
  const ACell: TThemedGridCell): TSize;
var
  LText: string;
  LSize: TSize;
begin
  if (AContext = nil) or (ACell = nil) then
    Exit(TSize.Create(0, 0));
  LText := ResolveCellText(ACell);
  LSize := TThemedGridGdiText.MeasureText(AContext, LText, AContext.Font);
  Result := TSize.Create(
    LSize.cx + AContext.Metrics.CellPadding.Left + AContext.Metrics.CellPadding.Right,
    LSize.cy + AContext.Metrics.CellPadding.Top + AContext.Metrics.CellPadding.Bottom);
end;

function TThemedGridCellRenderer.HitTestContent(const AContext: TThemedGridRenderContext;
  const ACell: TThemedGridCell; const ALocation: TPoint): TThemedGridHitInfo;
begin
  Result := TThemedGridCellRendererParts.CreateCellHit(ACell, ALocation);
end;

end.

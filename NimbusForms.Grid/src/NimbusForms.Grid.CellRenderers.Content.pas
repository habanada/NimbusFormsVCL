unit NimbusForms.Grid.CellRenderers.Content;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  System.Types,
  System.Math,
  System.SysUtils,
  Vcl.Graphics,
  Winapi.GDIPOBJ,
  Winapi.GDIPAPI,
  NimbusForms.Theming.Types,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Cell,
  NimbusForms.Grid.HitInfo,
  NimbusForms.Grid.RenderContext,
  NimbusForms.Grid.CellRendererParts,
  NimbusForms.Grid.CellRendererIntf,
  NimbusForms.Grid.InlineEditorGeometry,
  NimbusForms.Grid.ValueFormatter,
  NimbusForms.Grid.GdiCache,
  NimbusForms.Grid.GdiText;

type
  TThemedGridIconCellRenderer = class(TInterfacedObject, IThemedGridCellRenderer)
  public
    procedure Draw(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell);
    function Measure(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell): TSize;
    function HitTestContent(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell; const ALocation: TPoint): TThemedGridHitInfo;
  end;

  TThemedGridBadgeCellRenderer = class(TInterfacedObject, IThemedGridCellRenderer)
  public
    procedure Draw(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell);
    function Measure(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell): TSize;
    function HitTestContent(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell; const ALocation: TPoint): TThemedGridHitInfo;
  end;

  TThemedGridLinkCellRenderer = class(TInterfacedObject, IThemedGridCellRenderer)
  public
    procedure Draw(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell);
    function Measure(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell): TSize;
    function HitTestContent(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell; const ALocation: TPoint): TThemedGridHitInfo;
  end;

  TThemedGridRatingCellRenderer = class(TInterfacedObject, IThemedGridCellRenderer)
  private
    FStarPoints: array[0..9] of TGPPointF;
    procedure CreateStarPoints(const ABounds: TRect);
    procedure DrawStar(const AGraphics: TGPGraphics; const ABounds: TRect; const AFillColor, ABorderColor: TThemeColor);
  public
    procedure Draw(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell);
    function Measure(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell): TSize;
    function HitTestContent(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell; const ALocation: TPoint): TThemedGridHitInfo;
  end;

implementation

const
  CWhite = TThemeColor($FFFFFFFF);
  CBadgeDone = TThemeColor($FF4EC9B0);
  CBadgeError = TThemeColor($FFF44747);
  CBadgeWarn = TThemeColor($FFDCDCAA);
  CBadgeRunning = TThemeColor($FF569CD6);

function TryGetIcon(const ACell: TThemedGridCell; out AIcon: TIcon): Boolean;
var
  LObject: TObject;
begin
  AIcon := nil;
  if (ACell = nil) or ACell.Value.IsEmpty or (not ACell.Value.IsObject) then
    Exit(False);
  LObject := ACell.Value.AsObject;
  if LObject is TIcon then
  begin
    AIcon := TIcon(LObject);
    Exit(True);
  end;
  Result := False;
end;


procedure TThemedGridIconCellRenderer.Draw(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell);
var
  LBounds, LIconBounds: TRect;
  LIcon: TIcon;
  LSize: Integer;
begin
  if (AContext = nil) or (AContext.Graphics = nil) or (ACell = nil) then
    Exit;
  LBounds := ACell.Bounds;
  TThemedGridCellRendererParts.FillCell(AContext, ACell);
  TThemedGridCellRendererParts.DrawSearchHighlight(AContext, ACell);

  if TryGetIcon(ACell, LIcon) then
  begin
    LSize := Min(AContext.Metrics.GlyphSize, Min(LBounds.Width - 8, LBounds.Height - 8));
    if LSize > 0 then
    begin
      LIconBounds := TRect.Create(
        LBounds.Left + (LBounds.Width - LSize) div 2,
        LBounds.Top + (LBounds.Height - LSize) div 2,
        LBounds.Left + (LBounds.Width - LSize) div 2 + LSize,
        LBounds.Top + (LBounds.Height - LSize) div 2 + LSize);
      DrawIconEx(AContext.DC, LIconBounds.Left, LIconBounds.Top, LIcon.Handle,
        LSize, LSize, 0, 0, DI_NORMAL);
    end;
  end;

  TThemedGridCellRendererParts.DrawGridLines(AContext, ACell);
  TThemedGridCellRendererParts.DrawFocus(AContext, ACell);
  TThemedGridCellRendererParts.DrawError(AContext, ACell);
end;

function TThemedGridIconCellRenderer.Measure(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell): TSize;
var
  LSize: Integer;
begin
  if AContext <> nil then
    LSize := AContext.Metrics.GlyphSize
  else
    LSize := 16;
  Result := TSize.Create(LSize + 12, LSize + 8);
end;

function TThemedGridIconCellRenderer.HitTestContent(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell; const ALocation: TPoint): TThemedGridHitInfo;
begin
  Result := TThemedGridCellRendererParts.CreateCellHit(ACell, ALocation);
end;


function ResolveBadgeColor(const AContext: TThemedGridRenderContext; const AText: string): TThemeColor;
var
  LValue: string;
begin
  LValue := LowerCase(AText);
  if (Pos('done', LValue) > 0) or (Pos('ok', LValue) > 0) or (Pos('active', LValue) > 0) then
    Exit(CBadgeDone);
  if (Pos('blocked', LValue) > 0) or (Pos('error', LValue) > 0) then
    Exit(CBadgeError);
  if (Pos('review', LValue) > 0) or (Pos('warn', LValue) > 0) then
    Exit(CBadgeWarn);
  if Pos('running', LValue) > 0 then
    Exit(CBadgeRunning);
  Result := AContext.FocusColor;
end;

procedure TThemedGridBadgeCellRenderer.Draw(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell);
var
  LBounds, LBadge: TRect;
  LText: string;
  LTextSize: TSize;
  LBadgeWidth, LBadgeHeight: Integer;
  LBadgeBack, LBadgeFore: TThemeColor;
begin
  if (AContext = nil) or (AContext.Graphics = nil) or (ACell = nil) then
    Exit;
  LBounds := ACell.Bounds;
  TThemedGridCellRendererParts.FillCell(AContext, ACell);
  TThemedGridCellRendererParts.DrawSearchHighlight(AContext, ACell);

  LText := ACell.DisplayText;
  LTextSize := TThemedGridGdiText.MeasureText(AContext, LText, AContext.Font);
  LBadgeWidth := Min(LBounds.Width - 10, Max(34, LTextSize.cx + 18));
  LBadgeHeight := Min(LBounds.Height - 8, Max(18, LTextSize.cy + 4));

  if (LBadgeWidth > 0) and (LBadgeHeight > 0) then
  begin
    LBadge := TRect.Create(
      LBounds.Left + 6,
      LBounds.Top + (LBounds.Height - LBadgeHeight) div 2,
      LBounds.Left + 6 + LBadgeWidth,
      LBounds.Top + (LBounds.Height - LBadgeHeight) div 2 + LBadgeHeight);
    LBadgeBack := ResolveBadgeColor(AContext, LText);
    LBadgeFore := CWhite;

    AContext.Graphics.FillRectangle(TThemedGridGdiCache.Brush(LBadgeBack),
      LBadge.Left, LBadge.Top, LBadge.Width, LBadge.Height);
    AContext.Graphics.DrawRectangle(TThemedGridGdiCache.Pen(AContext.BorderColor),
      LBadge.Left, LBadge.Top, LBadge.Width - 1, LBadge.Height - 1);
    TThemedGridGdiText.DrawText(AContext, LText, AContext.Font, LBadge, LBadgeFore,
      TThemedGridContentAlignment.MiddleCenter, True);
  end;

  TThemedGridCellRendererParts.DrawGridLines(AContext, ACell);
  TThemedGridCellRendererParts.DrawFocus(AContext, ACell);
  TThemedGridCellRendererParts.DrawError(AContext, ACell);
end;

function TThemedGridBadgeCellRenderer.Measure(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell): TSize;
var
  LSize: TSize;
begin
  if (AContext = nil) or (ACell = nil) then
    Exit(TSize.Create(80, 24));
  LSize := TThemedGridGdiText.MeasureText(AContext, ACell.DisplayText, AContext.Font);
  Result := TSize.Create(LSize.cx + 24, Max(24, LSize.cy + 8));
end;

function TThemedGridBadgeCellRenderer.HitTestContent(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell; const ALocation: TPoint): TThemedGridHitInfo;
begin
  Result := TThemedGridCellRendererParts.CreateCellHit(ACell, ALocation);
end;


procedure TThemedGridLinkCellRenderer.Draw(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell);
var
  LBounds, LTextBounds: TRect;
  LLinkColor: TThemeColor;
  LPressed: Boolean;
  LSize: TSize;
  LY, LRight: Integer;
begin
  if (AContext = nil) or (AContext.Graphics = nil) or (ACell = nil) then
    Exit;
  LBounds := ACell.Bounds;
  TThemedGridCellRendererParts.FillCell(AContext, ACell);
  TThemedGridCellRendererParts.DrawSearchHighlight(AContext, ACell);

  LTextBounds := TThemedGridCellRendererParts.GetContentBounds(AContext, LBounds);
  LLinkColor := AContext.FocusColor;
  LPressed := TThemedGridCellStateFlag.Pressed in ACell.State;
  if LPressed then
    LLinkColor := AContext.BorderColor;
  if ACell.IsSelected then
    LLinkColor := AContext.SelectionForeColor;

  TThemedGridGdiText.DrawText(AContext, ACell.DisplayText, AContext.Font, LTextBounds, LLinkColor,
    TThemedGridContentAlignment.MiddleLeft, True);

  if ACell.IsHovered then
  begin
    LSize := TThemedGridGdiText.MeasureText(AContext, ACell.DisplayText, AContext.Font);
    LY := LTextBounds.Top + (LTextBounds.Height + LSize.cy) div 2 - 2;
    LRight := Min(LTextBounds.Right, LTextBounds.Left + LSize.cx);
    AContext.Graphics.DrawLine(TThemedGridGdiCache.Pen(LLinkColor),
      LTextBounds.Left, LY, LRight, LY);
  end;

  TThemedGridCellRendererParts.DrawGridLines(AContext, ACell);
  TThemedGridCellRendererParts.DrawFocus(AContext, ACell);
end;

function TThemedGridLinkCellRenderer.Measure(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell): TSize;
var
  LSize: TSize;
begin
  if (AContext = nil) or (ACell = nil) then
    Exit(TSize.Create(90, 24));
  LSize := TThemedGridGdiText.MeasureText(AContext, ACell.DisplayText, AContext.Font);
  Result := TSize.Create(LSize.cx + 12, LSize.cy + 8);
end;

function TThemedGridLinkCellRenderer.HitTestContent(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell; const ALocation: TPoint): TThemedGridHitInfo;
var
  LContent: TRect;
begin
  Result := TThemedGridCellRendererParts.CreateCellHit(ACell, ALocation);
  if ACell <> nil then
  begin
    LContent := ACell.Bounds;
    LContent.Inflate(-6, -2);
    if LContent.Contains(ALocation) then
      Result.HitArea := TThemedGridHitArea.Editor;
  end;
end;


procedure TThemedGridRatingCellRenderer.CreateStarPoints(const ABounds: TRect);
var
  LAngle, LStep, LRadius: Double;
  LCx, LCy, LOuter, LInner: Single;
  I: Integer;
begin
  LAngle := -Pi / 2.0;
  LStep := Pi / 5.0;
  LCx := ABounds.Left + ABounds.Width / 2.0;
  LCy := ABounds.Top + ABounds.Height / 2.0;
  LOuter := Min(ABounds.Width, ABounds.Height) / 2.0;
  LInner := LOuter * 0.45;
  for I := 0 to High(FStarPoints) do
  begin
    if I mod 2 = 0 then
      LRadius := LOuter
    else
      LRadius := LInner;
    FStarPoints[I].X := LCx + Cos(LAngle) * LRadius;
    FStarPoints[I].Y := LCy + Sin(LAngle) * LRadius;
    LAngle := LAngle + LStep;
  end;
end;

procedure TThemedGridRatingCellRenderer.DrawStar(const AGraphics: TGPGraphics; const ABounds: TRect;
  const AFillColor, ABorderColor: TThemeColor);
begin
  CreateStarPoints(ABounds);
  AGraphics.FillPolygon(TThemedGridGdiCache.Brush(AFillColor), PGPPointF(@FStarPoints[0]), Length(FStarPoints));
  AGraphics.DrawPolygon(TThemedGridGdiCache.Pen(ABorderColor), PGPPointF(@FStarPoints[0]), Length(FStarPoints));
end;

procedure TThemedGridRatingCellRenderer.Draw(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell);
var
  LBounds, LItemBounds: TRect;
  LMaximum, I: Integer;
  LValue: Extended;
  LFillColor, LEmptyColor, LBorderColor: TThemeColor;
begin
  if (AContext = nil) or (AContext.Graphics = nil) or (ACell = nil) then
    Exit;
  LBounds := ACell.Bounds;
  TThemedGridCellRendererParts.FillCell(AContext, ACell);
  TThemedGridCellRendererParts.DrawSearchHighlight(AContext, ACell);

  LMaximum := TThemedGridInlineEditorGeometry.ResolveRatingMaximum(ACell.Column);
  LValue := TThemedGridValueFormatter.ToDecimal(ACell.Value);
  if LValue < 0 then
    LValue := 0;
  if LValue > LMaximum then
    LValue := LMaximum;

  LFillColor := TThemedGridCellRendererParts.GetCellForeColor(AContext, ACell);
  LEmptyColor := AContext.GridLineColor;
  if ACell.IsHovered then
    LBorderColor := AContext.FocusColor
  else
    LBorderColor := AContext.BorderColor;

  for I := 0 to LMaximum - 1 do
  begin
    LItemBounds := TThemedGridInlineEditorGeometry.GetRatingItemBounds(LBounds, LMaximum, I);
    if LItemBounds.Right > LBounds.Right then
      Break;
    if LValue >= I + 1 then
      DrawStar(AContext.Graphics, LItemBounds, LFillColor, LBorderColor)
    else
      DrawStar(AContext.Graphics, LItemBounds, LEmptyColor, LBorderColor);
  end;

  TThemedGridCellRendererParts.DrawGridLines(AContext, ACell);
  TThemedGridCellRendererParts.DrawFocus(AContext, ACell);
  TThemedGridCellRendererParts.DrawError(AContext, ACell);
end;

function TThemedGridRatingCellRenderer.Measure(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell): TSize;
var
  LMaximum, LItemSize, LTotalWidth: Integer;
begin
  if ACell <> nil then
  begin
    LMaximum := TThemedGridInlineEditorGeometry.ResolveRatingMaximum(ACell.Column);
    LItemSize := TThemedGridInlineEditorGeometry.GetRatingItemSize(ACell.Bounds);
  end
  else
  begin
    LMaximum := TThemedGridInlineEditorGeometry.RatingDefaultMaximum;
    LItemSize := TThemedGridInlineEditorGeometry.RatingMaximumItemSize;
  end;
  LTotalWidth := LMaximum * LItemSize + (LMaximum - 1) * TThemedGridInlineEditorGeometry.RatingItemSpacing;
  Result := TSize.Create(LTotalWidth + TThemedGridInlineEditorGeometry.RatingHorizontalPadding * 2, LItemSize + 8);
end;

function TThemedGridRatingCellRenderer.HitTestContent(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell; const ALocation: TPoint): TThemedGridHitInfo;
begin
  Result := TThemedGridCellRendererParts.CreateCellHit(ACell, ALocation);
end;

end.

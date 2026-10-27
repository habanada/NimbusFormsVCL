unit NimbusForms.Grid.CellRenderers.Input;

{$SCOPEDENUMS ON}

interface

uses
  System.Types,
  System.Math,
  System.SysUtils,
  System.TypInfo,
  Winapi.GDIPOBJ,
  Winapi.GDIPAPI,
  NimbusForms.Theming.Types,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Cell,
  NimbusForms.Grid.HitInfo,
  NimbusForms.Grid.RenderContext,
  NimbusForms.Grid.RenderMetrics,
  NimbusForms.Grid.CellRendererParts,
  NimbusForms.Grid.CellRendererIntf,
  NimbusForms.Grid.InlineEditorGeometry,
  NimbusForms.Grid.NumericRange,
  NimbusForms.Grid.ValueFormatter,
  NimbusForms.Grid.GdiCache,
  NimbusForms.Grid.GdiText;

type
  TThemedGridCheckBoxCellRenderer = class(TInterfacedObject, IThemedGridCellRenderer)
  public
    procedure Draw(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell);
    function Measure(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell): TSize;
    function HitTestContent(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell; const ALocation: TPoint): TThemedGridHitInfo;
  end;

  TThemedGridToggleCellRenderer = class(TInterfacedObject, IThemedGridCellRenderer)
  public
    procedure Draw(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell);
    function Measure(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell): TSize;
    function HitTestContent(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell; const ALocation: TPoint): TThemedGridHitInfo;
  end;

  TThemedGridProgressBarCellRenderer = class(TInterfacedObject, IThemedGridCellRenderer)
  public
    procedure Draw(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell);
    function Measure(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell): TSize;
    function HitTestContent(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell; const ALocation: TPoint): TThemedGridHitInfo;
  end;

  TThemedGridSliderCellRenderer = class(TInterfacedObject, IThemedGridCellRenderer)
  public
    procedure Draw(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell);
    function Measure(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell): TSize;
    function HitTestContent(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell; const ALocation: TPoint): TThemedGridHitInfo;
  end;

implementation

function PanelBackColor(const AContext: TThemedGridRenderContext): TThemeColor;
begin
  if AContext.Palette <> nil then
    Result := AContext.Palette.PanelBackColor
  else
    Result := AContext.BackColor;
end;

function CreateRoundRectPath(const ABounds: TRect; const ARadius: Integer): TGPGraphicsPath;
var
  LDiameter: Integer;
begin
  Result := TGPGraphicsPath.Create;
  LDiameter := ARadius * 2;
  if LDiameter <= 0 then
  begin
    Result.AddRectangle(MakeRect(ABounds.Left, ABounds.Top, ABounds.Width, ABounds.Height));
    Exit;
  end;
  Result.AddArc(ABounds.Left, ABounds.Top, LDiameter, LDiameter, 180, 90);
  Result.AddArc(ABounds.Right - LDiameter, ABounds.Top, LDiameter, LDiameter, 270, 90);
  Result.AddArc(ABounds.Right - LDiameter, ABounds.Bottom - LDiameter, LDiameter, LDiameter, 0, 90);
  Result.AddArc(ABounds.Left, ABounds.Bottom - LDiameter, LDiameter, LDiameter, 90, 90);
  Result.CloseFigure;
end;

procedure FillRoundRect(const AGraphics: TGPGraphics; const AColor: TThemeColor; const ABounds: TRect; const ARadius: Integer);
var
  LPath: TGPGraphicsPath;
begin
  LPath := CreateRoundRectPath(ABounds, ARadius);
  try
    AGraphics.FillPath(TThemedGridGdiCache.Brush(AColor), LPath);
  finally
    LPath.Free;
  end;
end;

procedure DrawRoundRect(const AGraphics: TGPGraphics; const AColor: TThemeColor; const ABounds: TRect; const ARadius: Integer);
var
  LPath: TGPGraphicsPath;
begin
  LPath := CreateRoundRectPath(ABounds, ARadius);
  try
    AGraphics.DrawPath(TThemedGridGdiCache.Pen(AColor), LPath);
  finally
    LPath.Free;
  end;
end;

function FormatPercent(const ARatio: Extended): string;
begin
  Result := FloatToStrF(ARatio * 100, ffFixed, 15, 0) + ' %';
end;

{ TThemedGridCheckBoxCellRenderer }

procedure TThemedGridCheckBoxCellRenderer.Draw(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell);
var
  LBounds, LBox: TRect;
  LChecked: Boolean;
  LSize: Integer;
  LCheckColor, LBorderColor: TThemeColor;
  LPen: TGPPen;
begin
  if (AContext = nil) or (AContext.Graphics = nil) or (ACell = nil) then
    Exit;
  LBounds := ACell.Bounds;
  TThemedGridCellRendererParts.FillCell(AContext, ACell);
  TThemedGridCellRendererParts.DrawSearchHighlight(AContext, ACell);

  TThemedGridValueFormatter.TryGetBoolean(ACell.Value, LChecked);

  if AContext.Metrics <> nil then
    LSize := AContext.Metrics.CheckBoxSize
  else
    LSize := TThemedGridInlineEditorGeometry.DefaultCheckBoxSize;
  LBox := TThemedGridInlineEditorGeometry.GetCheckBoxBounds(LBounds, LSize);

  if (LBox.Width > 0) and (LBox.Height > 0) then
  begin
    LBorderColor := AContext.BorderColor;
    if LChecked then
    begin
      LCheckColor := AContext.FocusColor;
      FillRoundRect(AContext.Graphics, LCheckColor, LBox, 2);
      DrawRoundRect(AContext.Graphics, LCheckColor, LBox, 2);
      LPen := TThemedGridGdiCache.Pen(ThemeColor(255, 255, 255, 255), 2);
      AContext.Graphics.DrawLine(LPen,
        LBox.Left + Round(LBox.Width * 0.22), LBox.Top + Round(LBox.Height * 0.52),
        LBox.Left + Round(LBox.Width * 0.42), LBox.Top + Round(LBox.Height * 0.72));
      AContext.Graphics.DrawLine(LPen,
        LBox.Left + Round(LBox.Width * 0.42), LBox.Top + Round(LBox.Height * 0.72),
        LBox.Left + Round(LBox.Width * 0.78), LBox.Top + Round(LBox.Height * 0.28));
    end
    else
    begin
      FillRoundRect(AContext.Graphics, PanelBackColor(AContext), LBox, 2);
      DrawRoundRect(AContext.Graphics, LBorderColor, LBox, 2);
    end;
  end;

  TThemedGridCellRendererParts.DrawGridLines(AContext, ACell);
  TThemedGridCellRendererParts.DrawFocus(AContext, ACell);
  TThemedGridCellRendererParts.DrawError(AContext, ACell);
end;

function TThemedGridCheckBoxCellRenderer.Measure(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell): TSize;
var
  LSize: Integer;
begin
  if (AContext <> nil) and (AContext.Metrics <> nil) then
    LSize := AContext.Metrics.CheckBoxSize
  else
    LSize := TThemedGridInlineEditorGeometry.DefaultCheckBoxSize;
  Result := TSize.Create(LSize + 12, LSize + 8);
end;

function TThemedGridCheckBoxCellRenderer.HitTestContent(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell; const ALocation: TPoint): TThemedGridHitInfo;
begin
  Result := TThemedGridCellRendererParts.CreateCellHit(ACell, ALocation);
end;

{ TThemedGridToggleCellRenderer }

procedure TThemedGridToggleCellRenderer.Draw(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell);
var
  LBounds, LToggle, LThumb: TRect;
  LChecked: Boolean;
  LWidth, LHeight, LRadius, LThumbSize, LThumbLeft: Integer;
  LOnColor, LOffColor, LTrackColor, LBorderColor, LThumbColor: TThemeColor;
begin
  if (AContext = nil) or (AContext.Graphics = nil) or (ACell = nil) then
    Exit;
  LBounds := ACell.Bounds;
  TThemedGridCellRendererParts.FillCell(AContext, ACell);
  TThemedGridCellRendererParts.DrawSearchHighlight(AContext, ACell);

  TThemedGridValueFormatter.TryGetBoolean(ACell.Value, LChecked);

  LWidth := Min(44, Max(28, LBounds.Width - 12));
  LHeight := Min(20, Max(14, LBounds.Height - 8));
  LToggle := TRect.Create(
    LBounds.Left + (LBounds.Width - LWidth) div 2,
    LBounds.Top + (LBounds.Height - LHeight) div 2,
    LBounds.Left + (LBounds.Width - LWidth) div 2 + LWidth,
    LBounds.Top + (LBounds.Height - LHeight) div 2 + LHeight);

  LRadius := LHeight div 2;
  LOffColor := PanelBackColor(AContext);
  LOnColor := AContext.FocusColor;
  if LChecked then
    LTrackColor := LOnColor
  else
    LTrackColor := LOffColor;
  if LChecked then
    LBorderColor := LOnColor
  else
    LBorderColor := AContext.BorderColor;
  if ACell.IsSelected then
    LThumbColor := AContext.SelectionForeColor
  else
    LThumbColor := ThemeColor(255, 255, 255, 255);

  FillRoundRect(AContext.Graphics, LTrackColor, LToggle, LRadius);
  DrawRoundRect(AContext.Graphics, LBorderColor, LToggle, LRadius);

  LThumbSize := Max(8, LHeight - 6);
  if LChecked then
    LThumbLeft := LToggle.Right - LThumbSize - 3
  else
    LThumbLeft := LToggle.Left + 3;
  LThumb := TRect.Create(LThumbLeft, LToggle.Top + (LToggle.Height - LThumbSize) div 2,
    LThumbLeft + LThumbSize, LToggle.Top + (LToggle.Height - LThumbSize) div 2 + LThumbSize);

  AContext.Graphics.FillEllipse(TThemedGridGdiCache.Brush(LThumbColor),
    LThumb.Left, LThumb.Top, LThumb.Width, LThumb.Height);

  TThemedGridCellRendererParts.DrawGridLines(AContext, ACell);
  TThemedGridCellRendererParts.DrawFocus(AContext, ACell);
  TThemedGridCellRendererParts.DrawError(AContext, ACell);
end;

function TThemedGridToggleCellRenderer.Measure(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell): TSize;
begin
  Result := TSize.Create(58, 24);
end;

function TThemedGridToggleCellRenderer.HitTestContent(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell; const ALocation: TPoint): TThemedGridHitInfo;
begin
  Result := TThemedGridCellRendererParts.CreateCellHit(ACell, ALocation);
end;

{ TThemedGridProgressBarCellRenderer }

procedure TThemedGridProgressBarCellRenderer.Draw(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell);
var
  LBounds, LBarOuter, LBarInner: TRect;
  LRange: TThemedGridNumericRange;
  LRatio: Extended;
  LTrackColor, LFillColor, LForeColor: TThemeColor;
  LValueType: PTypeInfo;
  LText: string;
begin
  if (AContext = nil) or (AContext.Graphics = nil) or (ACell = nil) then
    Exit;
  LBounds := ACell.Bounds;
  TThemedGridCellRendererParts.FillCell(AContext, ACell);
  TThemedGridCellRendererParts.DrawSearchHighlight(AContext, ACell);

  if ACell.Column <> nil then
    LValueType := ACell.Column.ValueType
  else
    LValueType := nil;
  LRange := TThemedGridNumericRange.Resolve(ACell.Column, LValueType);
  LRatio := LRange.GetNormalizedValue(ACell.Value);

  LBarOuter := TThemedGridInlineEditorGeometry.GetBarBounds(LBounds);
  if (LBarOuter.Width > 0) and (LBarOuter.Height > 0) then
  begin
    LTrackColor := PanelBackColor(AContext);
    LFillColor := AContext.FocusColor;
    LForeColor := TThemedGridCellRendererParts.GetCellForeColor(AContext, ACell);

    AContext.Graphics.FillRectangle(TThemedGridGdiCache.Brush(LTrackColor),
      LBarOuter.Left, LBarOuter.Top, LBarOuter.Width, LBarOuter.Height);

    LBarInner := LBarOuter;
    LBarInner.Width := Round(LBarOuter.Width * LRatio);
    if LBarInner.Width > 0 then
      AContext.Graphics.FillRectangle(TThemedGridGdiCache.Brush(LFillColor),
        LBarInner.Left, LBarInner.Top, LBarInner.Width, LBarInner.Height);

    AContext.Graphics.DrawRectangle(TThemedGridGdiCache.Pen(AContext.BorderColor),
      LBarOuter.Left, LBarOuter.Top, LBarOuter.Width - 1, LBarOuter.Height - 1);

    LText := ACell.DisplayText;
    if LText = '' then
      LText := FormatPercent(LRatio);
    TThemedGridGdiText.DrawText(AContext, LText, AContext.Font, LBarOuter, LForeColor,
      TThemedGridContentAlignment.MiddleCenter, True);
  end;

  TThemedGridCellRendererParts.DrawGridLines(AContext, ACell);
  TThemedGridCellRendererParts.DrawFocus(AContext, ACell);
  TThemedGridCellRendererParts.DrawError(AContext, ACell);
end;

function TThemedGridProgressBarCellRenderer.Measure(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell): TSize;
begin
  Result := TSize.Create(90, 24);
end;

function TThemedGridProgressBarCellRenderer.HitTestContent(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell; const ALocation: TPoint): TThemedGridHitInfo;
begin
  Result := TThemedGridCellRendererParts.CreateCellHit(ACell, ALocation);
end;

{ TThemedGridSliderCellRenderer }

procedure TThemedGridSliderCellRenderer.Draw(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell);
var
  LBounds, LTrack, LThumb, LFilled: TRect;
  LRange: TThemedGridNumericRange;
  LRatio: Extended;
  LTrackColor, LFillColor, LForeColor, LThumbColor: TThemeColor;
  LValueType: PTypeInfo;
  LText: string;
  LFillRight: Integer;
begin
  if (AContext = nil) or (AContext.Graphics = nil) or (ACell = nil) then
    Exit;
  LBounds := ACell.Bounds;
  TThemedGridCellRendererParts.FillCell(AContext, ACell);
  TThemedGridCellRendererParts.DrawSearchHighlight(AContext, ACell);

  if ACell.Column <> nil then
    LValueType := ACell.Column.ValueType
  else
    LValueType := nil;
  LRange := TThemedGridNumericRange.Resolve(ACell.Column, LValueType);
  LRatio := LRange.GetNormalizedValue(ACell.Value);

  LTrack := TThemedGridInlineEditorGeometry.GetSliderTrackBounds(LBounds);
  if (LTrack.Width > 0) and (LTrack.Height > 0) then
  begin
    LThumb := TThemedGridInlineEditorGeometry.GetSliderThumbBounds(LBounds, LRatio);
    LTrackColor := PanelBackColor(AContext);
    LFillColor := AContext.FocusColor;
    LForeColor := TThemedGridCellRendererParts.GetCellForeColor(AContext, ACell);
    if ACell.IsHovered then
      LThumbColor := AContext.FocusColor
    else
      LThumbColor := LFillColor;

    AContext.Graphics.FillRectangle(TThemedGridGdiCache.Brush(LTrackColor),
      LTrack.Left, LTrack.Top, LTrack.Width, LTrack.Height);

    LFillRight := LThumb.Left + LThumb.Width div 2;
    if LFillRight > LTrack.Left then
    begin
      LFilled := TRect.Create(LTrack.Left, LTrack.Top, Min(LFillRight, LTrack.Right), LTrack.Bottom);
      if LFilled.Width > 0 then
        AContext.Graphics.FillRectangle(TThemedGridGdiCache.Brush(LFillColor),
          LFilled.Left, LFilled.Top, LFilled.Width, LFilled.Height);
    end;

    AContext.Graphics.DrawRectangle(TThemedGridGdiCache.Pen(AContext.BorderColor),
      LTrack.Left, LTrack.Top, LTrack.Width - 1, LTrack.Height - 1);

    LText := ACell.DisplayText;
    if LText = '' then
      LText := FormatPercent(LRatio);
    TThemedGridGdiText.DrawText(AContext, LText, AContext.Font, LBounds, LForeColor,
      TThemedGridContentAlignment.MiddleCenter, True);

    AContext.Graphics.FillEllipse(TThemedGridGdiCache.Brush(LThumbColor),
      LThumb.Left, LThumb.Top, LThumb.Width, LThumb.Height);
    AContext.Graphics.DrawEllipse(TThemedGridGdiCache.Pen(AContext.BorderColor),
      LThumb.Left, LThumb.Top, LThumb.Width - 1, LThumb.Height - 1);
  end;

  TThemedGridCellRendererParts.DrawGridLines(AContext, ACell);
  TThemedGridCellRendererParts.DrawFocus(AContext, ACell);
  TThemedGridCellRendererParts.DrawError(AContext, ACell);
end;

function TThemedGridSliderCellRenderer.Measure(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell): TSize;
begin
  Result := TSize.Create(120, 24);
end;

function TThemedGridSliderCellRenderer.HitTestContent(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell; const ALocation: TPoint): TThemedGridHitInfo;
begin
  Result := TThemedGridCellRendererParts.CreateCellHit(ACell, ALocation);
end;

end.

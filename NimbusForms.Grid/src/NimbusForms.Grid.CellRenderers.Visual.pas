unit NimbusForms.Grid.CellRenderers.Visual;

{$SCOPEDENUMS ON}

interface

uses
  System.Types,
  System.Math,
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
  NimbusForms.Grid.ColorValue,
  NimbusForms.Grid.GdiCache,
  NimbusForms.Grid.GdiText;

type
  TThemedGridColorSwatchCellRenderer = class(TInterfacedObject, IThemedGridCellRenderer)
  public
    procedure Draw(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell);
    function Measure(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell): TSize;
    function HitTestContent(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell; const ALocation: TPoint): TThemedGridHitInfo;
  end;

  TThemedGridButtonCellRenderer = class(TInterfacedObject, IThemedGridCellRenderer)
  public
    procedure Draw(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell);
    function Measure(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell): TSize;
    function HitTestContent(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell; const ALocation: TPoint): TThemedGridHitInfo;
  end;

  TThemedGridImageCellRenderer = class(TInterfacedObject, IThemedGridCellRenderer)
  public
    procedure Draw(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell);
    function Measure(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell): TSize;
    function HitTestContent(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell; const ALocation: TPoint): TThemedGridHitInfo;
  end;

implementation

const
  CWhite = TThemeColor($FFFFFFFF);
  CGainsboro = TThemeColor($FFDCDCDC);

function PanelBackColor(const AContext: TThemedGridRenderContext): TThemeColor;
begin
  if AContext.Palette <> nil then
    Result := AContext.Palette.PanelBackColor
  else
    Result := AContext.BackColor;
end;

function TryGetGraphic(const ACell: TThemedGridCell; out AGraphic: TGraphic): Boolean;
var
  LObject: TObject;
begin
  AGraphic := nil;
  if (ACell = nil) or ACell.Value.IsEmpty or (not ACell.Value.IsObject) then
    Exit(False);
  LObject := ACell.Value.AsObject;
  if LObject is TGraphic then
  begin
    AGraphic := TGraphic(LObject);
    Exit(True);
  end;
  Result := False;
end;

function GetScaledBounds(const AImageSize: TSize; const ABounds: TRect): TRect;
var
  LRatioX, LRatioY, LRatio: Single;
  LWidth, LHeight: Integer;
begin
  if (AImageSize.cx <= 0) or (AImageSize.cy <= 0) or (ABounds.Width <= 0) or (ABounds.Height <= 0) then
    Exit(TRect.Empty);
  LRatioX := ABounds.Width / AImageSize.cx;
  LRatioY := ABounds.Height / AImageSize.cy;
  LRatio := Min(LRatioX, LRatioY);
  LWidth := Max(1, Trunc(AImageSize.cx * LRatio));
  LHeight := Max(1, Trunc(AImageSize.cy * LRatio));
  Result := TRect.Create(
    ABounds.Left + (ABounds.Width - LWidth) div 2,
    ABounds.Top + (ABounds.Height - LHeight) div 2,
    ABounds.Left + (ABounds.Width - LWidth) div 2 + LWidth,
    ABounds.Top + (ABounds.Height - LHeight) div 2 + LHeight);
end;

procedure DrawAlphaBackdrop(const AGraphics: TGPGraphics; const ABounds: TRect);
var
  LCellSize, Y, X, LStartX, LWidth, LHeight: Integer;
  LOffset: Boolean;
begin
  AGraphics.FillRectangle(TThemedGridGdiCache.Brush(CWhite),
    ABounds.Left, ABounds.Top, ABounds.Width, ABounds.Height);
  LCellSize := Max(3, ABounds.Height div 3);
  LOffset := False;
  Y := ABounds.Top;
  while Y < ABounds.Bottom do
  begin
    if LOffset then
      LStartX := ABounds.Left + LCellSize
    else
      LStartX := ABounds.Left;
    LOffset := not LOffset;
    X := LStartX;
    while X < ABounds.Right do
    begin
      LWidth := Min(LCellSize, ABounds.Right - X);
      LHeight := Min(LCellSize, ABounds.Bottom - Y);
      if (LWidth > 0) and (LHeight > 0) then
        AGraphics.FillRectangle(TThemedGridGdiCache.Brush(CGainsboro), X, Y, LWidth, LHeight);
      Inc(X, LCellSize * 2);
    end;
    Inc(Y, LCellSize);
  end;
end;


procedure TThemedGridColorSwatchCellRenderer.Draw(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell);
var
  LBounds, LSwatch, LTextBounds: TRect;
  LColor, LBorderColor: TThemeColor;
  LHasColor: Boolean;
  LTextLeft: Integer;
  LText: string;
begin
  if (AContext = nil) or (AContext.Graphics = nil) or (ACell = nil) then
    Exit;
  LBounds := ACell.Bounds;
  TThemedGridCellRendererParts.FillCell(AContext, ACell);
  TThemedGridCellRendererParts.DrawSearchHighlight(AContext, ACell);

  LHasColor := TThemedGridColorValue.TryGetColor(ACell.Value, LColor);
  LSwatch := TThemedGridInlineEditorGeometry.GetColorSwatchBounds(LBounds,
    TThemedGridInlineEditorGeometry.ColorSwatchWidth,
    TThemedGridInlineEditorGeometry.ColorSwatchHorizontalPadding,
    TThemedGridInlineEditorGeometry.ColorSwatchVerticalPadding);
  LBorderColor := TThemedGridCellRendererParts.GetCellBorderColor(AContext, ACell);

  if not LSwatch.IsEmpty then
  begin
    if LHasColor then
    begin
      if ThemeColorAlpha(LColor) < 255 then
        DrawAlphaBackdrop(AContext.Graphics, LSwatch);
      AContext.Graphics.FillRectangle(TThemedGridGdiCache.Brush(LColor),
        LSwatch.Left, LSwatch.Top, LSwatch.Width, LSwatch.Height);
    end;
    AContext.Graphics.DrawRectangle(TThemedGridGdiCache.Pen(LBorderColor),
      LSwatch.Left, LSwatch.Top, LSwatch.Width - 1, LSwatch.Height - 1);
    if not LHasColor then
      AContext.Graphics.DrawLine(TThemedGridGdiCache.Pen(LBorderColor),
        LSwatch.Left, LSwatch.Bottom - 1, LSwatch.Right - 1, LSwatch.Top);
  end;

  if LSwatch.IsEmpty then
    LTextLeft := LBounds.Left + TThemedGridInlineEditorGeometry.ColorSwatchHorizontalPadding
  else
    LTextLeft := LSwatch.Right + TThemedGridInlineEditorGeometry.ColorSwatchTextGap;

  LTextBounds := TRect.Create(LTextLeft, LBounds.Top,
    LBounds.Right - TThemedGridInlineEditorGeometry.ColorSwatchTextGap, LBounds.Bottom);

  LText := ACell.DisplayText;
  if (LText = '') and LHasColor then
    LText := TThemedGridColorValue.Format(LColor);

  if LTextBounds.Width > 0 then
    TThemedGridGdiText.DrawText(AContext, LText, AContext.Font, LTextBounds,
      TThemedGridCellRendererParts.GetCellForeColor(AContext, ACell),
      TThemedGridContentAlignment.MiddleLeft, True);

  TThemedGridCellRendererParts.DrawGridLines(AContext, ACell);
  TThemedGridCellRendererParts.DrawFocus(AContext, ACell);
  TThemedGridCellRendererParts.DrawError(AContext, ACell);
end;

function TThemedGridColorSwatchCellRenderer.Measure(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell): TSize;
begin
  Result := TSize.Create(120, 24);
end;

function TThemedGridColorSwatchCellRenderer.HitTestContent(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell; const ALocation: TPoint): TThemedGridHitInfo;
begin
  Result := TThemedGridCellRendererParts.CreateCellHit(ACell, ALocation);
end;


procedure TThemedGridButtonCellRenderer.Draw(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell);
var
  LBounds, LButton: TRect;
  LHot, LPressed: Boolean;
  LButtonBack, LBorderColor: TThemeColor;
begin
  if (AContext = nil) or (AContext.Graphics = nil) or (ACell = nil) then
    Exit;
  LBounds := ACell.Bounds;
  TThemedGridCellRendererParts.FillCell(AContext, ACell);
  TThemedGridCellRendererParts.DrawSearchHighlight(AContext, ACell);

  LButton := TRect.Create(LBounds.Left + 5, LBounds.Top + 4, LBounds.Right - 5, LBounds.Bottom - 4);
  LHot := ACell.IsHovered;
  LPressed := TThemedGridCellStateFlag.Pressed in ACell.State;

  LButtonBack := PanelBackColor(AContext);
  if LPressed then
  begin
    if AContext.Palette <> nil then
      LButtonBack := AContext.Palette.PressedBackColor;
  end
  else if LHot then
    LButtonBack := AContext.HoverBackColor;

  AContext.Graphics.FillRectangle(TThemedGridGdiCache.Brush(LButtonBack),
    LButton.Left, LButton.Top, LButton.Width, LButton.Height);
  if LHot then
    LBorderColor := AContext.FocusColor
  else
    LBorderColor := AContext.BorderColor;
  AContext.Graphics.DrawRectangle(TThemedGridGdiCache.Pen(LBorderColor),
    LButton.Left, LButton.Top, LButton.Width - 1, LButton.Height - 1);

  if LPressed then
    LButton.Offset(1, 1);

  TThemedGridGdiText.DrawText(AContext, ACell.DisplayText, AContext.Font, LButton,
    TThemedGridCellRendererParts.GetCellForeColor(AContext, ACell),
    TThemedGridContentAlignment.MiddleCenter, True);

  TThemedGridCellRendererParts.DrawGridLines(AContext, ACell);
  TThemedGridCellRendererParts.DrawFocus(AContext, ACell);
  TThemedGridCellRendererParts.DrawError(AContext, ACell);
end;

function TThemedGridButtonCellRenderer.Measure(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell): TSize;
begin
  Result := TSize.Create(90, 24);
end;

function TThemedGridButtonCellRenderer.HitTestContent(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell; const ALocation: TPoint): TThemedGridHitInfo;
var
  LButton: TRect;
begin
  Result := TThemedGridCellRendererParts.CreateCellHit(ACell, ALocation);
  if ACell <> nil then
  begin
    LButton := TRect.Create(ACell.Bounds.Left + 5, ACell.Bounds.Top + 4,
      ACell.Bounds.Right - 5, ACell.Bounds.Bottom - 4);
    if LButton.Contains(ALocation) then
      Result.HitArea := TThemedGridHitArea.Editor;
  end;
end;


procedure TThemedGridImageCellRenderer.Draw(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell);
var
  LBounds, LContent, LImageBounds: TRect;
  LGraphic: TGraphic;
  LBitmap: TBitmap;
  LGPBitmap: TGPBitmap;
  LOwnsBitmap: Boolean;
begin
  if (AContext = nil) or (AContext.Graphics = nil) or (ACell = nil) then
    Exit;
  LBounds := ACell.Bounds;
  TThemedGridCellRendererParts.FillCell(AContext, ACell);
  TThemedGridCellRendererParts.DrawSearchHighlight(AContext, ACell);

  if TryGetGraphic(ACell, LGraphic) and (LGraphic.Width > 0) and (LGraphic.Height > 0) then
  begin
    LOwnsBitmap := False;
    if LGraphic is TBitmap then
      LBitmap := TBitmap(LGraphic)
    else
    begin
      LBitmap := TBitmap.Create;
      LBitmap.SetSize(LGraphic.Width, LGraphic.Height);
      LBitmap.Canvas.Draw(0, 0, LGraphic);
      LOwnsBitmap := True;
    end;
    try
      LContent := LBounds;
      LContent.Inflate(-5, -4);
      LImageBounds := GetScaledBounds(TSize.Create(LBitmap.Width, LBitmap.Height), LContent);
      if not LImageBounds.IsEmpty then
      begin
        LGPBitmap := TGPBitmap.Create(LBitmap.Handle, 0);
        try
          AContext.Graphics.DrawImage(LGPBitmap, LImageBounds.Left, LImageBounds.Top,
            LImageBounds.Width, LImageBounds.Height);
        finally
          LGPBitmap.Free;
        end;
      end;
    finally
      if LOwnsBitmap then
        LBitmap.Free;
    end;
  end;

  TThemedGridCellRendererParts.DrawGridLines(AContext, ACell);
  TThemedGridCellRendererParts.DrawFocus(AContext, ACell);
  TThemedGridCellRendererParts.DrawError(AContext, ACell);
end;

function TThemedGridImageCellRenderer.Measure(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell): TSize;
var
  LGraphic: TGraphic;
begin
  if TryGetGraphic(ACell, LGraphic) then
    Result := TSize.Create(LGraphic.Width + 10, LGraphic.Height + 8)
  else
    Result := TSize.Create(40, 24);
end;

function TThemedGridImageCellRenderer.HitTestContent(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell; const ALocation: TPoint): TThemedGridHitInfo;
begin
  Result := TThemedGridCellRendererParts.CreateCellHit(ACell, ALocation);
end;

end.

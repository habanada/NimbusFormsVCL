unit NimbusForms.Grid.HeaderRenderer;

{$SCOPEDENUMS ON}

interface

uses
  System.Types,
  System.Math,
  System.SysUtils,
  Winapi.GDIPOBJ,
  Winapi.GDIPAPI,
  NimbusForms.Theming.Types,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.ColumnBand,
  NimbusForms.Grid.Row,
  NimbusForms.Grid.RenderContext,
  NimbusForms.Grid.GdiCache,
  NimbusForms.Grid.GdiText,
  NimbusForms.Grid.InlineEditorGeometry;

type
  TThemedGridHeaderRenderer = class
  public
    procedure DrawColumnBandHeader(const AContext: TThemedGridRenderContext; const ABand: TThemedGridColumnBand; const ABandName: string; const ABounds: TRect; const AHovered, APressed: Boolean);
    procedure DrawColumnHeader(const AContext: TThemedGridRenderContext; const AColumn: TThemedGridColumn; const AColumnIndex: Integer; const ABounds: TRect; const AHovered, APressed: Boolean);
    procedure DrawColumnResizeGrip(const AContext: TThemedGridRenderContext; const ABounds: TRect; const AHovered: Boolean);
    procedure DrawSortGlyph(const AContext: TThemedGridRenderContext; const ABounds: TRect; const ADirection: TThemedGridSortDirection);
    procedure DrawFilterGlyph(const AContext: TThemedGridRenderContext; const ABounds: TRect; const AActive, AHovered, APressed: Boolean);
    procedure DrawRowHeader(const AContext: TThemedGridRenderContext; const ARow: TThemedGridRow; const ABounds: TRect; const AShowExpander, AExpanded, AHovered: Boolean);
    procedure DrawDetailExpander(const AContext: TThemedGridRenderContext; const ABounds: TRect; const AExpanded, AHovered: Boolean);
    procedure DrawTopLeftHeader(const AContext: TThemedGridRenderContext; const ABounds: TRect);
  end;

implementation

const
  CWhite = TThemeColor($FFFFFFFF);

function IsSet(const AColor: TThemeColor): Boolean;
begin
  Result := Cardinal(AColor) <> 0;
end;

procedure DrawHeaderBorders(const AContext: TThemedGridRenderContext; const ABounds: TRect; const AColor: TThemeColor);
var
  LPen: TGPPen;
begin
  LPen := TThemedGridGdiCache.Pen(AColor);
  AContext.Graphics.DrawLine(LPen, ABounds.Left, ABounds.Bottom - 1, ABounds.Right, ABounds.Bottom - 1);
  AContext.Graphics.DrawLine(LPen, ABounds.Right - 1, ABounds.Top, ABounds.Right - 1, ABounds.Bottom);
end;

procedure TThemedGridHeaderRenderer.DrawColumnBandHeader(const AContext: TThemedGridRenderContext; const ABand: TThemedGridColumnBand; const ABandName: string; const ABounds: TRect; const AHovered, APressed: Boolean);
var
  LBackColor, LForeColor, LBorderColor: TThemeColor;
  LTextBounds: TRect;
  LText: string;
begin
  if (AContext = nil) or (AContext.Graphics = nil) then
    Exit;
  if (ABounds.Width <= 0) or (ABounds.Height <= 0) then
    Exit;

  if (ABand <> nil) and IsSet(ABand.BackColor) then
    LBackColor := ABand.BackColor
  else
    LBackColor := AContext.HeaderBackColor;
  if (ABand <> nil) and IsSet(ABand.ForeColor) then
    LForeColor := ABand.ForeColor
  else
    LForeColor := AContext.HeaderForeColor;
  if (ABand <> nil) and IsSet(ABand.BorderColor) then
    LBorderColor := ABand.BorderColor
  else
    LBorderColor := AContext.GridLineColor;

  if APressed then
  begin
    if AContext.Palette <> nil then
      LBackColor := AContext.Palette.PressedBackColor;
  end
  else if AHovered then
    LBackColor := AContext.HoverBackColor;

  AContext.Graphics.FillRectangle(TThemedGridGdiCache.Brush(LBackColor), ABounds.Left, ABounds.Top, ABounds.Width, ABounds.Height);

  if ABand <> nil then
    LText := ABand.GetBestText
  else
    LText := ABandName;

  LTextBounds := TRect.Create(
    ABounds.Left + AContext.Metrics.HeaderPadding.Left,
    ABounds.Top + AContext.Metrics.HeaderPadding.Top,
    ABounds.Right - AContext.Metrics.HeaderPadding.Right,
    ABounds.Bottom - AContext.Metrics.HeaderPadding.Bottom);
  TThemedGridGdiText.DrawText(AContext, LText, AContext.Font, LTextBounds, LForeColor, TThemedGridContentAlignment.MiddleCenter, True);
  DrawHeaderBorders(AContext, ABounds, LBorderColor);
end;

procedure TThemedGridHeaderRenderer.DrawColumnHeader(const AContext: TThemedGridRenderContext; const AColumn: TThemedGridColumn; const AColumnIndex: Integer; const ABounds: TRect; const AHovered, APressed: Boolean);
var
  LBackColor, LForeColor: TThemeColor;
  LReservedRight: Integer;
  LTextBounds: TRect;
begin
  if (AContext = nil) or (AContext.Graphics = nil) or (AColumn = nil) then
    Exit;

  LBackColor := AContext.HeaderBackColor;
  LForeColor := AContext.HeaderForeColor;
  if APressed then
  begin
    if AContext.Palette <> nil then
      LBackColor := AContext.Palette.PressedBackColor;
  end
  else if AHovered then
    LBackColor := AContext.HoverBackColor;

  AContext.Graphics.FillRectangle(TThemedGridGdiCache.Brush(LBackColor), ABounds.Left, ABounds.Top, ABounds.Width, ABounds.Height);

  LReservedRight := 6;
  if AColumn.AllowFilter then
    Inc(LReservedRight, 22);
  if AColumn.SortDirection <> TThemedGridSortDirection.None then
    Inc(LReservedRight, 16);

  LTextBounds := TRect.Create(
    ABounds.Left + AContext.Metrics.HeaderPadding.Left,
    ABounds.Top + AContext.Metrics.HeaderPadding.Top,
    ABounds.Right - AContext.Metrics.HeaderPadding.Right - LReservedRight,
    ABounds.Bottom - AContext.Metrics.HeaderPadding.Bottom);
  if LTextBounds.Width < 4 then
    LTextBounds.Width := 4;

  TThemedGridGdiText.DrawText(AContext, AColumn.GetBestHeaderText, AContext.Font, LTextBounds, LForeColor, TThemedGridContentAlignment.MiddleLeft, True);
  DrawHeaderBorders(AContext, ABounds, AContext.GridLineColor);
end;

procedure TThemedGridHeaderRenderer.DrawColumnResizeGrip(const AContext: TThemedGridRenderContext; const ABounds: TRect; const AHovered: Boolean);
var
  LGrip: TRect;
  LColor: TThemeColor;
  X: Integer;
begin
  if (AContext = nil) or (AContext.Graphics = nil) then
    Exit;
  LGrip := TRect.Create(ABounds.Right - 4, ABounds.Top + 4, ABounds.Right, ABounds.Bottom - 4);
  if AHovered then
    LColor := AContext.FocusColor
  else
    LColor := AContext.GridLineColor;
  X := LGrip.Left + 1;
  AContext.Graphics.DrawLine(TThemedGridGdiCache.Pen(LColor), X, LGrip.Top, X, LGrip.Bottom);
end;

procedure TThemedGridHeaderRenderer.DrawSortGlyph(const AContext: TThemedGridRenderContext; const ABounds: TRect; const ADirection: TThemedGridSortDirection);
var
  LSize, X, Y: Integer;
  LPoints: array[0..2] of TGPPoint;
begin
  if (AContext = nil) or (AContext.Graphics = nil) then
    Exit;
  if ADirection = TThemedGridSortDirection.None then
    Exit;
  LSize := 7;
  X := ABounds.Right - 16;
  Y := ABounds.Top + (ABounds.Height - LSize) div 2;
  if ADirection = TThemedGridSortDirection.Ascending then
  begin
    LPoints[0] := MakePoint(X, Y + LSize);
    LPoints[1] := MakePoint(X + LSize, Y + LSize);
    LPoints[2] := MakePoint(X + LSize div 2, Y);
  end
  else
  begin
    LPoints[0] := MakePoint(X, Y);
    LPoints[1] := MakePoint(X + LSize, Y);
    LPoints[2] := MakePoint(X + LSize div 2, Y + LSize);
  end;
  AContext.Graphics.FillPolygon(TThemedGridGdiCache.Brush(AContext.HeaderForeColor), PGPPoint(@LPoints[0]), 3);
end;

procedure TThemedGridHeaderRenderer.DrawFilterGlyph(const AContext: TThemedGridRenderContext; const ABounds: TRect; const AActive, AHovered, APressed: Boolean);
var
  LBackColor, LBorderColor, LGlyphColor: TThemeColor;
  LButton, LFunnel, LDot: TRect;
  LTop, LStem: array[0..3] of TGPPoint;
begin
  if (AContext = nil) or (AContext.Graphics = nil) then
    Exit;
  if (ABounds.Width <= 0) or (ABounds.Height <= 0) then
    Exit;

  LBackColor := TThemeColor(0);
  LBorderColor := TThemeColor(0);
  if AActive then
  begin
    if AContext.Palette <> nil then
      LBackColor := AContext.Palette.SelectedBackColor;
    LBorderColor := AContext.FocusColor;
  end;
  if APressed then
  begin
    if AContext.Palette <> nil then
      LBackColor := AContext.Palette.PressedBackColor;
    LBorderColor := AContext.FocusColor;
  end
  else if AHovered then
  begin
    LBackColor := AContext.HoverBackColor;
    LBorderColor := AContext.FocusColor;
  end;

  LButton := ABounds;
  LButton.Inflate(-1, -2);
  if IsSet(LBackColor) then
    AContext.Graphics.FillRectangle(TThemedGridGdiCache.Brush(LBackColor), LButton.Left, LButton.Top, LButton.Width, LButton.Height);
  if IsSet(LBorderColor) then
    AContext.Graphics.DrawRectangle(TThemedGridGdiCache.Pen(LBorderColor), LButton.Left, LButton.Top, LButton.Width - 1, LButton.Height - 1);

  if AActive then
    LGlyphColor := CWhite
  else
    LGlyphColor := AContext.HeaderForeColor;

  LFunnel := TRect.Create(
    ABounds.Left + Max(4, (ABounds.Width - 12) div 2),
    ABounds.Top + Max(5, (ABounds.Height - 12) div 2),
    ABounds.Left + Max(4, (ABounds.Width - 12) div 2) + 12,
    ABounds.Top + Max(5, (ABounds.Height - 12) div 2) + 12);

  LTop[0] := MakePoint(LFunnel.Left, LFunnel.Top);
  LTop[1] := MakePoint(LFunnel.Right, LFunnel.Top);
  LTop[2] := MakePoint(LFunnel.Left + 7, LFunnel.Top + 6);
  LTop[3] := MakePoint(LFunnel.Left + 5, LFunnel.Top + 6);
  LStem[0] := MakePoint(LFunnel.Left + 5, LFunnel.Top + 6);
  LStem[1] := MakePoint(LFunnel.Left + 7, LFunnel.Top + 6);
  LStem[2] := MakePoint(LFunnel.Left + 7, LFunnel.Bottom);
  LStem[3] := MakePoint(LFunnel.Left + 5, LFunnel.Bottom);

  AContext.Graphics.FillPolygon(TThemedGridGdiCache.Brush(LGlyphColor), PGPPoint(@LTop[0]), 4);
  AContext.Graphics.FillPolygon(TThemedGridGdiCache.Brush(LGlyphColor), PGPPoint(@LStem[0]), 4);

  if AActive then
  begin
    LDot := TRect.Create(ABounds.Right - 7, ABounds.Top + 4, ABounds.Right - 2, ABounds.Top + 9);
    AContext.Graphics.FillEllipse(TThemedGridGdiCache.Brush(AContext.FocusColor), LDot.Left, LDot.Top, LDot.Width, LDot.Height);
    AContext.Graphics.DrawEllipse(TThemedGridGdiCache.Pen(CWhite), LDot.Left, LDot.Top, LDot.Width - 1, LDot.Height - 1);
  end;
end;

procedure TThemedGridHeaderRenderer.DrawDetailExpander(const AContext: TThemedGridRenderContext; const ABounds: TRect; const AExpanded, AHovered: Boolean);
var
  LBorderColor, LGlyphColor: TThemeColor;
  LCenterX, LCenterY, LArm: Integer;
  LPen: TGPPen;
begin
  if (AContext = nil) or (AContext.Graphics = nil) or ABounds.IsEmpty then
    Exit;
  if AHovered then
  begin
    LBorderColor := AContext.FocusColor;
    LGlyphColor := AContext.FocusColor;
  end
  else
  begin
    LBorderColor := AContext.GridLineColor;
    LGlyphColor := AContext.HeaderForeColor;
  end;
  AContext.Graphics.FillRectangle(TThemedGridGdiCache.Brush(AContext.HeaderBackColor), ABounds.Left, ABounds.Top, ABounds.Width, ABounds.Height);
  AContext.Graphics.DrawRectangle(TThemedGridGdiCache.Pen(LBorderColor), ABounds.Left, ABounds.Top, ABounds.Width - 1, ABounds.Height - 1);
  LCenterX := ABounds.Left + ABounds.Width div 2;
  LCenterY := ABounds.Top + ABounds.Height div 2;
  LArm := Max(2, ABounds.Width div 2 - 3);
  LPen := TThemedGridGdiCache.Pen(LGlyphColor);
  AContext.Graphics.DrawLine(LPen, LCenterX - LArm, LCenterY, LCenterX + LArm, LCenterY);
  if not AExpanded then
    AContext.Graphics.DrawLine(LPen, LCenterX, LCenterY - LArm, LCenterX, LCenterY + LArm);
end;

procedure TThemedGridHeaderRenderer.DrawRowHeader(const AContext: TThemedGridRenderContext; const ARow: TThemedGridRow; const ABounds: TRect; const AShowExpander, AExpanded, AHovered: Boolean);
var
  LText: string;
  LTextBounds, LExpanderBounds: TRect;
begin
  if (AContext = nil) or (AContext.Graphics = nil) then
    Exit;
  AContext.Graphics.FillRectangle(TThemedGridGdiCache.Brush(AContext.HeaderBackColor), ABounds.Left, ABounds.Top, ABounds.Width, ABounds.Height);

  if (ARow <> nil) and (ARow.RowIndex >= 0) then
    LText := IntToStr(ARow.RowIndex + 1)
  else
    LText := '';

  LTextBounds := ABounds;
  LExpanderBounds := TRect.Empty;
  if AShowExpander then
  begin
    LExpanderBounds := TThemedGridInlineEditorGeometry.GetDetailExpanderBounds(ABounds);
    if not LExpanderBounds.IsEmpty then
      LTextBounds := TRect.Create(LExpanderBounds.Right + 2, ABounds.Top, ABounds.Right, ABounds.Bottom);
  end;

  if LTextBounds.Width > 0 then
    TThemedGridGdiText.DrawText(AContext, LText, AContext.Font, LTextBounds, AContext.HeaderForeColor, TThemedGridContentAlignment.MiddleCenter, True);

  if AShowExpander and (not LExpanderBounds.IsEmpty) then
    DrawDetailExpander(AContext, LExpanderBounds, AExpanded, AHovered);

  DrawHeaderBorders(AContext, ABounds, AContext.GridLineColor);
end;

procedure TThemedGridHeaderRenderer.DrawTopLeftHeader(const AContext: TThemedGridRenderContext; const ABounds: TRect);
begin
  if (AContext = nil) or (AContext.Graphics = nil) then
    Exit;
  AContext.Graphics.FillRectangle(TThemedGridGdiCache.Brush(AContext.HeaderBackColor), ABounds.Left, ABounds.Top, ABounds.Width, ABounds.Height);
  DrawHeaderBorders(AContext, ABounds, AContext.GridLineColor);
end;

end.

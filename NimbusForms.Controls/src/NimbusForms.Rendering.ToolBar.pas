{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.ToolBar;

interface

uses
  System.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Canvas;

type
  TThemedToolBarRenderContext = record
    Bounds: TRect;
    GripBounds: TRect;
    OverflowBounds: TRect;
    Palette: TThemePalette;
    ShowBorder: Boolean;
    ShowGrip: Boolean;
    ShowOverflowButton: Boolean;
    OverflowHot: Boolean;
    OverflowPressed: Boolean;
    Enabled: Boolean;
    PPI: Integer;
  end;

  TThemedToolBarRenderer = class
  private
    class function Scale(const AContext: TThemedToolBarRenderContext; const AValue: Integer): Integer; static;
    class procedure DrawGrip(const ACanvas: INimbusRenderCanvas; const AContext: TThemedToolBarRenderContext); static;
    class procedure DrawOverflow(const ACanvas: INimbusRenderCanvas; const AContext: TThemedToolBarRenderContext); static;
  public
    class procedure Render(const ACanvas: INimbusRenderCanvas; const AContext: TThemedToolBarRenderContext); static;
  end;

implementation

uses
  Winapi.Windows,
  System.Math,
  NimbusForms.Theming.Types,
  NimbusForms.Rendering.Types;

class function TThemedToolBarRenderer.Scale(const AContext: TThemedToolBarRenderContext; const AValue: Integer): Integer;
begin
  Result := NimbusScaleValue(AValue, AContext.PPI);
end;

class procedure TThemedToolBarRenderer.DrawGrip(const ACanvas: INimbusRenderCanvas; const AContext: TThemedToolBarRenderContext);
var
  LColor: TThemeColor;
  LDot, LX, LY, I: Integer;
  LRect: TRect;
begin
  if not AContext.ShowGrip or NimbusRectIsEmpty(AContext.GripBounds) then Exit;
  if AContext.Enabled then LColor := NimbusMutedForeColor(AContext.Palette) else LColor := NimbusDisabledForeColor(AContext.Palette);
  LDot := Max(1, Scale(AContext, 2));
  LX := AContext.GripBounds.Left + (AContext.GripBounds.Width - (LDot * 2 + Scale(AContext, 3))) div 2;
  LY := AContext.GripBounds.Top + (AContext.GripBounds.Height - (LDot * 3 + Scale(AContext, 6))) div 2;
  for I := 0 to 2 do
  begin
    LRect := Rect(LX, LY + I * (LDot + Scale(AContext, 3)), LX + LDot, LY + I * (LDot + Scale(AContext, 3)) + LDot);
    ACanvas.FillEllipse(LColor, LRect);
    OffsetRect(LRect, LDot + Scale(AContext, 3), 0);
    ACanvas.FillEllipse(LColor, LRect);
  end;
end;

class procedure TThemedToolBarRenderer.DrawOverflow(const ACanvas: INimbusRenderCanvas; const AContext: TThemedToolBarRenderContext);
var
  LBack, LBorder, LFore: TThemeColor;
  LCX, LCY, LS, LGap: Integer;
begin
  if not AContext.ShowOverflowButton or NimbusRectIsEmpty(AContext.OverflowBounds) then Exit;
  LBack := ThemeColor(0, 0, 0, 0);
  LBorder := ThemeColor(0, 0, 0, 0);
  if AContext.Enabled then LFore := NimbusControlForeColor(AContext.Palette) else LFore := NimbusDisabledForeColor(AContext.Palette);
  if AContext.Enabled and AContext.OverflowPressed then
  begin
    LBack := NimbusPressedBackColor(AContext.Palette);
    LBorder := NimbusFocusBorderColor(AContext.Palette);
  end
  else if AContext.Enabled and AContext.OverflowHot then
  begin
    LBack := NimbusHoverBackColor(AContext.Palette);
    LBorder := NimbusControlBorderColor(AContext.Palette);
  end;
  if ThemeColorAlpha(LBack) <> 0 then ACanvas.FillRectangle(LBack, AContext.OverflowBounds);
  if ThemeColorAlpha(LBorder) <> 0 then ACanvas.DrawRectangle(LBorder, AContext.OverflowBounds);
  LCX := AContext.OverflowBounds.Left + AContext.OverflowBounds.Width div 2 - Scale(AContext, 2);
  LCY := AContext.OverflowBounds.Top + AContext.OverflowBounds.Height div 2;
  LS := Max(2, Scale(AContext, 3));
  LGap := Max(1, Scale(AContext, 2));
  ACanvas.DrawLine(LFore, LCX - LS, LCY - LS, LCX, LCY, 1.0);
  ACanvas.DrawLine(LFore, LCX, LCY, LCX - LS, LCY + LS, 1.0);
  ACanvas.DrawLine(LFore, LCX + LGap, LCY - LS, LCX + LGap + LS, LCY, 1.0);
  ACanvas.DrawLine(LFore, LCX + LGap + LS, LCY, LCX + LGap, LCY + LS, 1.0);
end;

class procedure TThemedToolBarRenderer.Render(const ACanvas: INimbusRenderCanvas; const AContext: TThemedToolBarRenderContext);
var
  LBorder: TThemeColor;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(AContext.Bounds) then Exit;
  ACanvas.FillRectangle(NimbusPanelBackColor(AContext.Palette), AContext.Bounds);
  DrawGrip(ACanvas, AContext);
  DrawOverflow(ACanvas, AContext);
  if AContext.ShowBorder then
  begin
    LBorder := NimbusControlBorderColor(AContext.Palette);
    ACanvas.DrawLine(LBorder, AContext.Bounds.Left, AContext.Bounds.Bottom - 1, AContext.Bounds.Right - 1, AContext.Bounds.Bottom - 1, 1.0);
  end;
end;

end.

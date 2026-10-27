{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.MenuBar;

interface

uses
  Winapi.Windows,
  System.Types,
  Vcl.Graphics,
  NimbusForms.Controls.MenuBar,
  NimbusForms.Theming.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Canvas;

type
  TThemedMenuBarRenderContext = record
    Bounds: TRect;
    OverflowBounds: TRect;
    Palette: TThemePalette;
    ShowBottomBorder: Boolean;
    ShowOverflowButton: Boolean;
    OverflowHot: Boolean;
    OverflowPressed: Boolean;
    RightToLeft: Boolean;
    Enabled: Boolean;
    CornerRadius: Integer;
    PPI: Integer;
  end;

  TThemedMenuBarItemRenderContext = record
    Bounds: TRect;
    Caption: string;
    Font: TFont;
    Palette: TThemePalette;
    Kind: TThemedMenuBarItemKind;
    DisplayStyle: TThemedMenuBarDisplayStyle;
    Appearance: TThemedMenuBarItemAppearance;
    IconHandle: HICON;
    ImageSize: Integer;
    ImageTextSpacing: Integer;
    Enabled: Boolean;
    Hot: Boolean;
    Pressed: Boolean;
    Focused: Boolean;
    Opened: Boolean;
    Checked: Boolean;
    ShowArrow: Boolean;
    RightToLeft: Boolean;
    PaddingLeft: Integer;
    PaddingTop: Integer;
    PaddingRight: Integer;
    PaddingBottom: Integer;
    ArrowWidth: Integer;
    CornerRadius: Integer;
    PPI: Integer;
  end;

  TThemedMenuBarRenderer = class
  private
    class function Scale(const APPI, AValue: Integer): Integer; static;
    class procedure RenderSeparator(const ACanvas: INimbusRenderCanvas; const AContext: TThemedMenuBarItemRenderContext); static;
    class procedure RenderArrow(const ACanvas: INimbusRenderCanvas; const AContext: TThemedMenuBarItemRenderContext; const AColor: TThemeColor); static;
    class procedure RenderOverflow(const ACanvas: INimbusRenderCanvas; const AContext: TThemedMenuBarRenderContext); static;
  public
    class procedure RenderBackground(const ACanvas: INimbusRenderCanvas; const AContext: TThemedMenuBarRenderContext); static;
    class procedure RenderItem(const ACanvas: INimbusRenderCanvas; const AContext: TThemedMenuBarItemRenderContext); static;
  end;

implementation

uses
  System.UITypes,
  System.Math,
  NimbusForms.Rendering.Types;

class function TThemedMenuBarRenderer.Scale(const APPI, AValue: Integer): Integer;
begin
  Result := NimbusScaleValue(AValue, APPI);
end;

class procedure TThemedMenuBarRenderer.RenderOverflow(const ACanvas: INimbusRenderCanvas; const AContext: TThemedMenuBarRenderContext);
var
  LBack, LBorder, LFore: TThemeColor;
  LCX, LCY, LS, LGap, LRadius, LDirection: Integer;
begin
  if not AContext.ShowOverflowButton or NimbusRectIsEmpty(AContext.OverflowBounds) then Exit;
  LBack := ThemeColor(0, 0, 0, 0);
  LBorder := ThemeColor(0, 0, 0, 0);
  if AContext.Enabled then LFore := NimbusControlForeColor(AContext.Palette) else LFore := NimbusDisabledForeColor(AContext.Palette);
  if AContext.Enabled and AContext.OverflowPressed then
  begin
    LBack := NimbusPressedBackColor(AContext.Palette);
    LBorder := NimbusControlBorderColor(AContext.Palette);
  end
  else if AContext.Enabled and AContext.OverflowHot then
  begin
    LBack := NimbusHoverBackColor(AContext.Palette);
    LBorder := NimbusControlBorderColor(AContext.Palette);
  end;
  LRadius := Scale(AContext.PPI, AContext.CornerRadius);
  if ThemeColorAlpha(LBack) <> 0 then ACanvas.FillRoundedRectangle(LBack, AContext.OverflowBounds, LRadius);
  if ThemeColorAlpha(LBorder) <> 0 then ACanvas.DrawRoundedRectangle(LBorder, AContext.OverflowBounds, LRadius, 1.0);
  LCX := AContext.OverflowBounds.Left + AContext.OverflowBounds.Width div 2;
  LCY := AContext.OverflowBounds.Top + AContext.OverflowBounds.Height div 2;
  LS := Max(2, Scale(AContext.PPI, 3));
  LGap := Max(1, Scale(AContext.PPI, 2));
  if AContext.RightToLeft then LDirection := -1 else LDirection := 1;
  ACanvas.DrawLine(LFore, LCX - LDirection * (LGap div 2 + LS), LCY - LS, LCX - LDirection * (LGap div 2), LCY, 1.0);
  ACanvas.DrawLine(LFore, LCX - LDirection * (LGap div 2), LCY, LCX - LDirection * (LGap div 2 + LS), LCY + LS, 1.0);
  ACanvas.DrawLine(LFore, LCX + LDirection * (LGap div 2), LCY - LS, LCX + LDirection * (LGap div 2 + LS), LCY, 1.0);
  ACanvas.DrawLine(LFore, LCX + LDirection * (LGap div 2 + LS), LCY, LCX + LDirection * (LGap div 2), LCY + LS, 1.0);
end;

class procedure TThemedMenuBarRenderer.RenderBackground(const ACanvas: INimbusRenderCanvas; const AContext: TThemedMenuBarRenderContext);
var
  LBack, LBorder: TThemeColor;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(AContext.Bounds) then Exit;
  if AContext.Palette <> nil then LBack := AContext.Palette.DockHeaderBackColor else LBack := ColorToThemeColor(clBtnFace);
  LBorder := NimbusControlBorderColor(AContext.Palette);
  ACanvas.FillRectangle(LBack, AContext.Bounds);
  RenderOverflow(ACanvas, AContext);
  if AContext.ShowBottomBorder then
    ACanvas.DrawLine(LBorder, AContext.Bounds.Left, AContext.Bounds.Bottom - 1, AContext.Bounds.Right - 1, AContext.Bounds.Bottom - 1, 1.0);
end;

class procedure TThemedMenuBarRenderer.RenderSeparator(const ACanvas: INimbusRenderCanvas; const AContext: TThemedMenuBarItemRenderContext);
var
  LX, LY1, LY2: Integer;
begin
  LX := AContext.Bounds.Left + AContext.Bounds.Width div 2;
  LY1 := AContext.Bounds.Top + Scale(AContext.PPI, 4);
  LY2 := AContext.Bounds.Bottom - Scale(AContext.PPI, 4);
  ACanvas.DrawLine(NimbusSeparatorColor(AContext.Palette), LX, LY1, LX, LY2, 1.0);
end;

class procedure TThemedMenuBarRenderer.RenderArrow(const ACanvas: INimbusRenderCanvas; const AContext: TThemedMenuBarItemRenderContext; const AColor: TThemeColor);
var
  LRect: TRect;
  LCX, LCY, LS: Integer;
begin
  if not AContext.ShowArrow then Exit;
  if AContext.RightToLeft then
    LRect := Rect(AContext.Bounds.Left, AContext.Bounds.Top, AContext.Bounds.Left + Scale(AContext.PPI, AContext.ArrowWidth), AContext.Bounds.Bottom)
  else
    LRect := Rect(AContext.Bounds.Right - Scale(AContext.PPI, AContext.ArrowWidth), AContext.Bounds.Top, AContext.Bounds.Right, AContext.Bounds.Bottom);
  LS := Max(2, Scale(AContext.PPI, 3));
  LCX := LRect.Left + LRect.Width div 2;
  LCY := LRect.Top + LRect.Height div 2;
  ACanvas.FillTriangle(AColor,
    Point(LCX - LS, LCY - Max(1, LS div 2)),
    Point(LCX + LS, LCY - Max(1, LS div 2)),
    Point(LCX, LCY + LS));
end;

class procedure TThemedMenuBarRenderer.RenderItem(const ACanvas: INimbusRenderCanvas; const AContext: TThemedMenuBarItemRenderContext);
var
  LBack, LBorder, LFore: TThemeColor;
  LTextRect, LContentRect, LImageRect: TRect;
  LTextSize: TSize;
  LFlags: TNimbusTextFlags;
  LRadius, LArrowReserve, LImageSize, LSpacing, LX, LCY, LTotalWidth: Integer;
  LFrameRect: TRect;
  LHasImage, LHasText: Boolean;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(AContext.Bounds) then Exit;
  if AContext.Kind = tmbikSeparator then
  begin
    RenderSeparator(ACanvas, AContext);
    Exit;
  end;
  if AContext.Kind in [tmbikSpring, tmbikTextBox, tmbikSearchBox, tmbikComboBox] then Exit;

  LBack := ThemeColor(0, 0, 0, 0);
  LBorder := ThemeColor(0, 0, 0, 0);
  if AContext.Enabled then LFore := NimbusControlForeColor(AContext.Palette) else LFore := NimbusDisabledForeColor(AContext.Palette);

  if AContext.Enabled and (AContext.Opened or AContext.Pressed) and (AContext.Kind <> tmbikLabel) then
  begin
    LBack := NimbusPressedBackColor(AContext.Palette);
    LBorder := NimbusControlBorderColor(AContext.Palette);
  end
  else if AContext.Enabled and AContext.Checked and (AContext.Kind <> tmbikLabel) then
  begin
    LBack := NimbusBlendColor(NimbusControlBackColor(AContext.Palette), NimbusAccentColor(AContext.Palette), 52);
    LBorder := NimbusControlBorderColor(AContext.Palette);
  end
  else if AContext.Enabled and (AContext.Hot or AContext.Focused) and (AContext.Kind <> tmbikLabel) then
  begin
    LBack := NimbusHoverBackColor(AContext.Palette);
    LBorder := NimbusControlBorderColor(AContext.Palette);
  end;

  LFrameRect := AContext.Bounds;
  LRadius := Scale(AContext.PPI, AContext.CornerRadius);
  if AContext.Appearance = tmbiaAccentPill then
  begin
    InflateRect(LFrameRect, -Scale(AContext.PPI, 2), -Scale(AContext.PPI, 3));
    LRadius := Scale(AContext.PPI, 4);
    LBorder := NimbusControlBorderColor(AContext.Palette);
    if not AContext.Enabled then
    begin
      LBack := NimbusDisabledBackColor(AContext.Palette);
      LFore := NimbusDisabledForeColor(AContext.Palette);
    end
    else if AContext.Opened or AContext.Pressed then
    begin
      LBack := NimbusPressedBackColor(AContext.Palette);
      LFore := NimbusControlForeColor(AContext.Palette);
    end
    else if AContext.Hot or AContext.Focused then
    begin
      LBack := NimbusHoverBackColor(AContext.Palette);
      LFore := NimbusControlForeColor(AContext.Palette);
    end
    else
    begin
      LBack := NimbusBlendColor(NimbusControlBackColor(AContext.Palette), NimbusAccentColor(AContext.Palette), 36);
      LFore := NimbusControlForeColor(AContext.Palette);
    end;
  end;
  if ThemeColorAlpha(LBack) <> 0 then ACanvas.FillRoundedRectangle(LBack, LFrameRect, LRadius);
  if ThemeColorAlpha(LBorder) <> 0 then ACanvas.DrawRoundedRectangle(LBorder, LFrameRect, LRadius, 1.0);

  LContentRect := AContext.Bounds;
  Inc(LContentRect.Left, Scale(AContext.PPI, AContext.PaddingLeft));
  Inc(LContentRect.Top, Scale(AContext.PPI, AContext.PaddingTop));
  Dec(LContentRect.Right, Scale(AContext.PPI, AContext.PaddingRight));
  Dec(LContentRect.Bottom, Scale(AContext.PPI, AContext.PaddingBottom));
  LArrowReserve := 0;
  if AContext.ShowArrow then LArrowReserve := Scale(AContext.PPI, AContext.ArrowWidth);
  if LArrowReserve > 0 then
  begin
    if AContext.RightToLeft then Inc(LContentRect.Left, LArrowReserve) else Dec(LContentRect.Right, LArrowReserve);
  end;

  LHasImage := (AContext.IconHandle <> 0) and (AContext.DisplayStyle <> tmbdsText);
  LHasText := (AContext.Caption <> '') and (AContext.DisplayStyle <> tmbdsImage);
  LImageSize := Scale(AContext.PPI, AContext.ImageSize);
  LSpacing := Scale(AContext.PPI, AContext.ImageTextSpacing);
  if LHasText then LTextSize := ACanvas.MeasureText(AContext.Caption, AContext.Font, 10000, [ntfSingleLine]) else LTextSize := TSize.Create(0, 0);
  if AContext.Kind in [tmbikButton, tmbikToggleButton] then
  begin
    LTotalWidth := 0;
    if LHasImage then Inc(LTotalWidth, LImageSize);
    if LHasImage and LHasText then Inc(LTotalWidth, LSpacing);
    if LHasText then Inc(LTotalWidth, LTextSize.cx);
    if (LTotalWidth > 0) and (LTotalWidth < LContentRect.Width) then
    begin
      LX := LContentRect.Left + (LContentRect.Width - LTotalWidth) div 2;
      LContentRect := Rect(LX, LContentRect.Top, LX + LTotalWidth, LContentRect.Bottom);
    end;
  end;
  LTextRect := LContentRect;

  if LHasImage then
  begin
    LCY := LContentRect.Top + LContentRect.Height div 2;
    if not LHasText then
      LX := LContentRect.Left + Max(0, (LContentRect.Width - LImageSize) div 2)
    else if AContext.RightToLeft then
      LX := LContentRect.Right - LImageSize
    else
      LX := LContentRect.Left;
    LImageRect := Rect(LX, LCY - LImageSize div 2, LX + LImageSize, LCY - LImageSize div 2 + LImageSize);
    ACanvas.DrawIcon(AContext.IconHandle, LImageRect);
    if LHasText then
    begin
      if AContext.RightToLeft then
        LTextRect.Right := LImageRect.Left - LSpacing
      else
        LTextRect.Left := LImageRect.Right + LSpacing;
    end;
  end;

  if LHasText then
  begin
    LFlags := [ntfSingleLine, ntfVCenter, ntfEndEllipsis];
    if AContext.RightToLeft then Include(LFlags, ntfRightToLeft);
    ACanvas.DrawText(AContext.Caption, AContext.Font, LFore, LTextRect, LFlags);
  end;
  RenderArrow(ACanvas, AContext, LFore);
end;

end.

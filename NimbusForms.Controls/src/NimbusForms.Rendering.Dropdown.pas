{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.Dropdown;

interface

uses
  System.Types,
  System.UITypes,
  Vcl.Graphics,
  NimbusForms.Theming.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.Controls.Dropdown.Types,
  NimbusForms.Rendering.Canvas;

type
  TThemedDropdownRenderContext = record
    Bounds: TRect;
    Palette: TThemePalette;
    StyleMode: TThemedDropdownStyleMode;
    ValidationState: TThemedDropdownValidationState;
    Enabled: Boolean;
    Focused: Boolean;
    Hovered: Boolean;
    Pressed: Boolean;
    DroppedDown: Boolean;
    ShowFocusGlow: Boolean;
    BackColor: System.UITypes.TColor;
    ForeColor: System.UITypes.TColor;
    CustomBorderColor: System.UITypes.TColor;
    CustomFocusBorderColor: System.UITypes.TColor;
    CustomBackColor: System.UITypes.TColor;
    CustomForeColor: System.UITypes.TColor;
    CustomCueColor: System.UITypes.TColor;
    BorderThickness: Integer;
    PPI: Integer;
  end;

  TThemedDropdownListRenderContext = record
    Bounds: TRect;
    Palette: TThemePalette;
    StyleMode: TThemedDropdownStyleMode;
    Enabled: Boolean;
    ShowCheckboxes: Boolean;
    SelectedIndex: Integer;
    HoveredIndex: Integer;
    CheckBoxSize: Integer;
    PPI: Integer;
    Font: TFont;
    GroupFont: TFont;
  end;

  TThemedDropdownRenderer = class
  private
    class function CustomOrThemeColor(const ACustom: System.UITypes.TColor; const ATheme: TThemeColor): TThemeColor; static;
    class function FocusBorderColor(const AContext: TThemedDropdownRenderContext): TThemeColor; static;
    class function BorderColor(const AContext: TThemedDropdownRenderContext): TThemeColor; static;
    class function InputBackColor(const AContext: TThemedDropdownRenderContext): TThemeColor; static;
    class function InputForeColor(const AContext: TThemedDropdownRenderContext): TThemeColor; static;
    class function ArrowColor(const AContext: TThemedDropdownRenderContext): TThemeColor; static;
    class function ArrowBackColor(const AContext: TThemedDropdownRenderContext): TThemeColor; static;
    class function Scale(const AValue, APPI: Integer): Integer; static;
  public
    class procedure RenderControl(const ACanvas: INimbusRenderCanvas; const AContext: TThemedDropdownRenderContext; const AArrowRect, AClearRect: TRect; const AShowClear, AClearHovered, AClearPressed: Boolean); static;
    class procedure RenderSelectedImage(const ACanvas: INimbusRenderCanvas; const AContext: TThemedDropdownRenderContext; const AImage: Vcl.Graphics.TBitmap; const ATextRect: TRect); static;
    class procedure RenderListBackground(const ACanvas: INimbusRenderCanvas; const AContext: TThemedDropdownListRenderContext); static;
    class procedure RenderListItem(const ACanvas: INimbusRenderCanvas; const AContext: TThemedDropdownListRenderContext; const AItem: TThemedDropdownItem; const AIndex: Integer; const ARect: TRect); static;
    class procedure RenderListBorder(const ACanvas: INimbusRenderCanvas; const AContext: TThemedDropdownListRenderContext); static;
  end;

implementation

uses
  Winapi.Windows,
  System.Math,
  NimbusForms.Rendering.Types;

class function TThemedDropdownRenderer.Scale(const AValue, APPI: Integer): Integer;
begin
  Result := NimbusScaleValue(AValue, APPI);
end;

class function TThemedDropdownRenderer.CustomOrThemeColor(const ACustom: System.UITypes.TColor; const ATheme: TThemeColor): TThemeColor;
begin
  if ACustom <> System.UITypes.TColor(clNone) then
    Result := ColorToThemeColor(ACustom)
  else
    Result := ATheme;
end;

class function TThemedDropdownRenderer.FocusBorderColor(const AContext: TThemedDropdownRenderContext): TThemeColor;
begin
  Result := CustomOrThemeColor(AContext.CustomFocusBorderColor, NimbusFocusBorderColor(AContext.Palette));
end;

class function TThemedDropdownRenderer.BorderColor(const AContext: TThemedDropdownRenderContext): TThemeColor;
begin
  if not AContext.Enabled then
    Exit(NimbusControlBorderColor(AContext.Palette));
  case AContext.ValidationState of
    tdvError: Exit(NimbusDangerColor);
    tdvWarning: Exit(NimbusWarningColor);
    tdvSuccess: Exit(NimbusSuccessColor);
  end;
  if AContext.Focused or AContext.DroppedDown then
    Exit(FocusBorderColor(AContext));
  if AContext.Hovered then
    Exit(NimbusBlendColor(NimbusControlBorderColor(AContext.Palette), NimbusAccentColor(AContext.Palette), 56));
  Result := CustomOrThemeColor(AContext.CustomBorderColor, NimbusInputBorderColor(AContext.Palette));
end;

class function TThemedDropdownRenderer.InputBackColor(const AContext: TThemedDropdownRenderContext): TThemeColor;
begin
  if not AContext.Enabled then
    Exit(NimbusDisabledBackColor(AContext.Palette));
  Result := CustomOrThemeColor(AContext.CustomBackColor, NimbusInputBackColor(AContext.Palette));
end;

class function TThemedDropdownRenderer.InputForeColor(const AContext: TThemedDropdownRenderContext): TThemeColor;
begin
  if not AContext.Enabled then
    Exit(NimbusDisabledForeColor(AContext.Palette));
  Result := CustomOrThemeColor(AContext.CustomForeColor, NimbusInputForeColor(AContext.Palette));
end;

class function TThemedDropdownRenderer.ArrowColor(const AContext: TThemedDropdownRenderContext): TThemeColor;
begin
  if not AContext.Enabled then
    Exit(NimbusDisabledForeColor(AContext.Palette));
  if AContext.Focused or AContext.DroppedDown then
    Exit(InputForeColor(AContext));
  Result := NimbusMutedForeColor(AContext.Palette);
end;

class function TThemedDropdownRenderer.ArrowBackColor(const AContext: TThemedDropdownRenderContext): TThemeColor;
begin
  if not AContext.Enabled then
    Exit(NimbusDisabledBackColor(AContext.Palette));
  if AContext.Pressed or AContext.DroppedDown then
    Exit(NimbusPressedBackColor(AContext.Palette));
  if AContext.Hovered then
    Exit(NimbusHoverBackColor(AContext.Palette));
  Result := InputBackColor(AContext);
end;

class procedure TThemedDropdownRenderer.RenderControl(const ACanvas: INimbusRenderCanvas; const AContext: TThemedDropdownRenderContext; const AArrowRect, AClearRect: TRect; const AShowClear, AClearHovered, AClearPressed: Boolean);
var
  LBorderRect, LGlowRect, LHoverRect: TRect;
  LBorder, LArrow, LBack, LClearColor: TThemeColor;
  LThickness, LArrowDX, LArrowDY, LCX, LCY, LXSize: Integer;
  P1, P2, P3: TPoint;
begin
  if ACanvas = nil then Exit;
  LBack := InputBackColor(AContext);
  ACanvas.FillRectangle(LBack, AContext.Bounds);
  LBorder := BorderColor(AContext);
  LThickness := Max(1, AContext.BorderThickness);
  LBorderRect := AContext.Bounds;
  if (AContext.StyleMode = tdsIdeCompact) and AContext.ShowFocusGlow and AContext.Enabled and
    (AContext.Focused or AContext.DroppedDown) and (AContext.ValidationState = tdvNormal) then
  begin
    LGlowRect := Rect(LBorderRect.Left + 1, LBorderRect.Top + 1, LBorderRect.Right - 1, LBorderRect.Bottom - 1);
    ACanvas.DrawRectangle(NimbusColorWithAlpha(FocusBorderColor(AContext), 80), LGlowRect, LThickness);
  end;
  if AContext.StyleMode = tdsIdeCompact then
  begin
    ACanvas.FillRectangle(ArrowBackColor(AContext), AArrowRect);
    ACanvas.DrawLine(LBorder, AArrowRect.Left, AArrowRect.Top + 1, AArrowRect.Left, AArrowRect.Bottom - 2, 1.0);
  end;
  LArrow := ArrowColor(AContext);
  LArrowDX := Scale(4, AContext.PPI);
  LArrowDY := Scale(2, AContext.PPI);
  LCX := (AArrowRect.Left + AArrowRect.Right) div 2;
  LCY := (AArrowRect.Top + AArrowRect.Bottom) div 2;
  if AContext.DroppedDown then Inc(LCY);
  P1 := Point(LCX - LArrowDX, LCY - LArrowDY);
  P2 := Point(LCX + LArrowDX, LCY - LArrowDY);
  P3 := Point(LCX, LCY + LArrowDY);
  ACanvas.FillTriangle(LArrow, P1, P2, P3);
  if AShowClear and (AContext.StyleMode = tdsIdeCompact) then
  begin
    if AClearHovered or AClearPressed then
    begin
      LHoverRect := Rect(AClearRect.Left + 3, AClearRect.Top + 3, AClearRect.Right - 3, AClearRect.Bottom - 3);
      if AClearPressed then ACanvas.FillRectangle(NimbusPressedBackColor(AContext.Palette), LHoverRect)
      else ACanvas.FillRectangle(NimbusHoverBackColor(AContext.Palette), LHoverRect);
    end;
    LXSize := Scale(9, AContext.PPI);
    LCX := (AClearRect.Left + AClearRect.Right) div 2;
    LCY := (AClearRect.Top + AClearRect.Bottom) div 2;
    LClearColor := NimbusMutedForeColor(AContext.Palette);
    ACanvas.DrawLine(LClearColor, LCX - LXSize div 2, LCY - LXSize div 2, LCX + LXSize div 2, LCY + LXSize div 2, 1.4);
    ACanvas.DrawLine(LClearColor, LCX + LXSize div 2, LCY - LXSize div 2, LCX - LXSize div 2, LCY + LXSize div 2, 1.4);
  end;
  ACanvas.DrawRectangle(LBorder, LBorderRect, LThickness);
end;

class procedure TThemedDropdownRenderer.RenderSelectedImage(const ACanvas: INimbusRenderCanvas; const AContext: TThemedDropdownRenderContext; const AImage: Vcl.Graphics.TBitmap; const ATextRect: TRect);
var
  LSize: Integer;
  LRect: TRect;
begin
  if (ACanvas = nil) or (AImage = nil) or AImage.Empty then Exit;
  if AContext.StyleMode = tdsIdeCompact then LSize := Scale(14, AContext.PPI) else LSize := Scale(16, AContext.PPI);
  LRect := Rect(ATextRect.Left, ATextRect.Top + (ATextRect.Height - LSize) div 2, ATextRect.Left + LSize, ATextRect.Top + (ATextRect.Height - LSize) div 2 + LSize);
  ACanvas.DrawBitmap(AImage, LRect);
end;

class procedure TThemedDropdownRenderer.RenderListBackground(const ACanvas: INimbusRenderCanvas; const AContext: TThemedDropdownListRenderContext);
begin
  if ACanvas = nil then Exit;
  ACanvas.FillRectangle(NimbusMenuBackColor(AContext.Palette), AContext.Bounds);
end;

class procedure TThemedDropdownRenderer.RenderListItem(const ACanvas: INimbusRenderCanvas; const AContext: TThemedDropdownListRenderContext; const AItem: TThemedDropdownItem; const AIndex: Integer; const ARect: TRect);
var
  LBack, LFore, LSeparator, LGroup, LAccent, LDisabled, LInputBack: TThemeColor;
  LLeftPadding, LImageSize, LImageSpacing, LRightPadding, LInset, LCurrentX, LCheckSize: Integer;
  LRect, LImageRect, LTextRect: TRect;
  LFlags: TNimbusTextFlags;
  LCheckRect: TRect;
  X1, Y1: Integer;
begin
  if (ACanvas = nil) or (AItem = nil) then Exit;
  LBack := NimbusMenuBackColor(AContext.Palette);
  LFore := NimbusMenuForeColor(AContext.Palette);
  LSeparator := NimbusControlBorderColor(AContext.Palette);
  LGroup := NimbusMutedForeColor(AContext.Palette);
  LAccent := NimbusAccentColor(AContext.Palette);
  LDisabled := NimbusDisabledForeColor(AContext.Palette);
  LInputBack := NimbusInputBackColor(AContext.Palette);
  if AContext.StyleMode = tdsIdeCompact then
  begin
    LLeftPadding := Scale(6, AContext.PPI);
    LImageSize := Scale(14, AContext.PPI);
  end
  else
  begin
    LLeftPadding := Scale(8, AContext.PPI);
    LImageSize := Scale(16, AContext.PPI);
  end;
  LImageSpacing := Scale(6, AContext.PPI);
  LRightPadding := Scale(8, AContext.PPI);
  LInset := Scale(8, AContext.PPI);
  if AItem.IsSeparator then
  begin
    Y1 := (ARect.Top + ARect.Bottom) div 2;
    ACanvas.DrawLine(LSeparator, ARect.Left + LInset, Y1, ARect.Right - LInset, Y1, 1.0);
    Exit;
  end;
  if AItem.Selectable then
  begin
    if AIndex = AContext.SelectedIndex then
    begin
      LBack := NimbusMenuSelectedBackColor(AContext.Palette);
      LFore := NimbusSelectedForeColor(AContext.Palette);
    end
    else if AIndex = AContext.HoveredIndex then
      LBack := NimbusHoverBackColor(AContext.Palette);
  end;
  ACanvas.FillRectangle(LBack, ARect);
  LFlags := [ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix];
  if AItem.IsGroupHeader then
  begin
    LRect := Rect(ARect.Left + LLeftPadding, ARect.Top, ARect.Right - LLeftPadding, ARect.Bottom);
    ACanvas.DrawText(AItem.GroupText, AContext.GroupFont, LGroup, LRect, LFlags);
    Exit;
  end;
  LCurrentX := ARect.Left + LLeftPadding;
  if AContext.ShowCheckboxes then
  begin
    LCheckSize := AContext.CheckBoxSize;
    LCheckRect := Rect(LCurrentX, ARect.Top + (ARect.Height - LCheckSize) div 2, LCurrentX + LCheckSize, ARect.Top + (ARect.Height - LCheckSize) div 2 + LCheckSize);
    ACanvas.FillRectangle(LInputBack, LCheckRect);
    if AItem.Enabled then ACanvas.DrawRectangle(LAccent, LCheckRect, 1.0) else ACanvas.DrawRectangle(LDisabled, LCheckRect, 1.0);
    if AItem.Checked then
    begin
      X1 := LCheckRect.Left;
      if AItem.Enabled then LFore := LAccent else LFore := LDisabled;
      ACanvas.DrawLine(LFore, X1 + Scale(3, AContext.PPI), LCheckRect.Top + Scale(7, AContext.PPI), X1 + Scale(6, AContext.PPI), LCheckRect.Top + Scale(10, AContext.PPI), 2.0);
      ACanvas.DrawLine(LFore, X1 + Scale(6, AContext.PPI), LCheckRect.Top + Scale(10, AContext.PPI), X1 + Scale(11, AContext.PPI), LCheckRect.Top + Scale(4, AContext.PPI), 2.0);
    end;
    Inc(LCurrentX, LCheckSize + LImageSpacing);
  end;
  if not AItem.Image.Empty then
  begin
    LImageRect := Rect(LCurrentX, ARect.Top + (ARect.Height - LImageSize) div 2, LCurrentX + LImageSize, ARect.Top + (ARect.Height - LImageSize) div 2 + LImageSize);
    ACanvas.DrawBitmap(AItem.Image, LImageRect);
    Inc(LCurrentX, LImageSize + LImageSpacing);
  end;
  LTextRect := Rect(LCurrentX, ARect.Top, ARect.Right - LRightPadding, ARect.Bottom);
  if not AItem.Enabled then LFore := LDisabled;
  ACanvas.DrawText(AItem.Text, AContext.Font, LFore, LTextRect, LFlags);
end;

class procedure TThemedDropdownRenderer.RenderListBorder(const ACanvas: INimbusRenderCanvas; const AContext: TThemedDropdownListRenderContext);
begin
  if ACanvas = nil then Exit;
  ACanvas.DrawRectangle(NimbusMenuBorderColor(AContext.Palette), AContext.Bounds, 1.0);
end;

end.

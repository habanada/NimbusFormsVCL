{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.Button;

interface

uses
  Winapi.Windows,
  System.Types,
  Vcl.Graphics,
  NimbusForms.Theming.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Types,
  NimbusForms.Rendering.Canvas,
  NimbusForms.Controls.Types;

type
  TThemedButtonRenderContext = record
    Bounds: TRect;
    MainBounds: TRect;
    DropDownBounds: TRect;
    ContentBounds: TRect;
    ImageBounds: TRect;
    TextBounds: TRect;
    ShortcutBounds: TRect;
    BadgeBounds: TRect;
    Caption: string;
    LoadingText: string;
    ShortcutText: string;
    BadgeText: string;
    Font: TFont;
    Palette: TThemePalette;
    IconHandle: HICON;
    Kind: TThemedButtonKind;
    Style: TThemedButtonStyle;
    HighlightStyle: TThemedButtonHighlightStyle;
    DisplayMode: TThemedButtonDisplayMode;
    IndicatorPlacement: TThemedButtonIndicatorPlacement;
    Shape: TThemedButtonShape;
    DropDownMode: TThemedButtonDropDownMode;
    ImagePlacement: TThemedButtonImagePlacement;
    ColorMode: TThemedButtonColorMode;
    AnimationMode: TThemedButtonAnimationMode;
    FocusStyle: TThemedButtonFocusStyle;
    TextAlign: TThemedContentAlignment;
    BorderThickness: Integer;
    CornerRadius: Integer;
    SpinnerSize: Integer;
    ImageSize: Integer;
    ImageTextSpacing: Integer;
    DropDownWidth: Integer;
    IndicatorThickness: Integer;
    SpinnerAngle: Single;
    AnimationProgress: Single;
    PressScale: Single;
    Enabled: Boolean;
    Hot: Boolean;
    Pressed: Boolean;
    DropDownHot: Boolean;
    DropDownPressed: Boolean;
    Checked: Boolean;
    Loading: Boolean;
    ShowBorder: Boolean;
    ShowFocusIndicator: Boolean;
    Focused: Boolean;
    Multiline: Boolean;
    AutoEllipsis: Boolean;
    UseMnemonic: Boolean;
    IndicatorVisible: Boolean;
    RightToLeft: Boolean;
    SurfaceBackColor: TThemeColor;
    CustomBackColor: TThemeColor;
    CustomForeColor: TThemeColor;
    CustomBorderColor: TThemeColor;
    CustomHoverBackColor: TThemeColor;
    CustomPressedBackColor: TThemeColor;
    CustomCheckedBackColor: TThemeColor;
    BadgeBackColor: TThemeColor;
    BadgeForeColor: TThemeColor;
    IndicatorColor: TThemeColor;
  end;

  TThemedButtonRenderer = class
  private
    class function BlendColor(const AFrom, ATo: TThemeColor; const AProgress: Single): TThemeColor; static;
    class function RelativeLuminance(const AColor: TThemeColor): Double; static;
    class function ContrastRatio(const AFirst, ASecond: TThemeColor): Double; static;
    class function EnsureReadableForeColor(const APreferred, ABackground: TThemeColor): TThemeColor; static;
    class procedure ApplyButtonStyle(const AContext: TThemedButtonRenderContext; const ASurface, AAccent: TThemeColor; var ABack, AFore, ABorder: TThemeColor); static;
    class procedure ResolveHighlightColors(const AContext: TThemedButtonRenderContext; const ABaseBack, ABaseBorder, AAccent: TThemeColor; out ATargetBack, ATargetBorder: TThemeColor); static;
    class procedure ResolveColors(const AContext: TThemedButtonRenderContext; out ABack, AFore, ABorder: TThemeColor); static;
    class function EffectiveRadius(const AContext: TThemedButtonRenderContext; const ARect: TRect): Integer; static;
    class function ScaleRectAround(const ARect: TRect; const ACenterX, ACenterY, AScale: Single): TRect; static;
    class procedure ApplyPressScale(var AContext: TThemedButtonRenderContext); static;
    class function TextFlags(const AContext: TThemedButtonRenderContext; const AAlignment: TThemedContentAlignment): TNimbusTextFlags; static;
    class procedure DrawBackground(const ACanvas: INimbusRenderCanvas; const AContext: TThemedButtonRenderContext; const ABack, ABorder: TThemeColor); static;
    class procedure DrawIndicator(const ACanvas: INimbusRenderCanvas; const AContext: TThemedButtonRenderContext; const AFore: TThemeColor); static;
    class procedure DrawContent(const ACanvas: INimbusRenderCanvas; const AContext: TThemedButtonRenderContext; const AFore: TThemeColor); static;
    class procedure DrawDropDown(const ACanvas: INimbusRenderCanvas; const AContext: TThemedButtonRenderContext; const AFore, ABorder: TThemeColor); static;
    class procedure DrawFocus(const ACanvas: INimbusRenderCanvas; const AContext: TThemedButtonRenderContext; const AFore: TThemeColor); static;
  public
    class procedure Render(const ACanvas: INimbusRenderCanvas; const AContext: TThemedButtonRenderContext); static;
  end;

implementation

uses
  System.Math;

class function TThemedButtonRenderer.BlendColor(const AFrom, ATo: TThemeColor; const AProgress: Single): TThemeColor;
var
  P: Single;
  A, R, G, B: Integer;
begin
  P := EnsureRange(AProgress, 0.0, 1.0);
  A := Round(ThemeColorAlpha(AFrom) + (ThemeColorAlpha(ATo) - ThemeColorAlpha(AFrom)) * P);
  R := Round(ThemeColorRed(AFrom) + (ThemeColorRed(ATo) - ThemeColorRed(AFrom)) * P);
  G := Round(ThemeColorGreen(AFrom) + (ThemeColorGreen(ATo) - ThemeColorGreen(AFrom)) * P);
  B := Round(ThemeColorBlue(AFrom) + (ThemeColorBlue(ATo) - ThemeColorBlue(AFrom)) * P);
  Result := ThemeColor(Byte(A), Byte(R), Byte(G), Byte(B));
end;

class function TThemedButtonRenderer.RelativeLuminance(const AColor: TThemeColor): Double;
  function Linearize(const AValue: Double): Double;
  begin
    if AValue <= 0.03928 then Result := AValue / 12.92 else Result := Power((AValue + 0.055) / 1.055, 2.4);
  end;
var
  R, G, B: Double;
begin
  R := Linearize(ThemeColorRed(AColor) / 255.0);
  G := Linearize(ThemeColorGreen(AColor) / 255.0);
  B := Linearize(ThemeColorBlue(AColor) / 255.0);
  Result := 0.2126 * R + 0.7152 * G + 0.0722 * B;
end;

class function TThemedButtonRenderer.ContrastRatio(const AFirst, ASecond: TThemeColor): Double;
var
  L1, L2: Double;
begin
  L1 := RelativeLuminance(AFirst);
  L2 := RelativeLuminance(ASecond);
  if L2 > L1 then
  begin
    Result := L1;
    L1 := L2;
    L2 := Result;
  end;
  Result := (L1 + 0.05) / (L2 + 0.05);
end;

class function TThemedButtonRenderer.EnsureReadableForeColor(const APreferred, ABackground: TThemeColor): TThemeColor;
var
  LBlack, LWhite: TThemeColor;
begin
  if ContrastRatio(APreferred, ABackground) >= 3.2 then Exit(APreferred);
  LBlack := ThemeColor(ThemeColorAlpha(APreferred), 24, 24, 24);
  LWhite := ThemeColor(ThemeColorAlpha(APreferred), 255, 255, 255);
  if ContrastRatio(LWhite, ABackground) >= ContrastRatio(LBlack, ABackground) then Result := LWhite else Result := LBlack;
end;

class procedure TThemedButtonRenderer.ApplyButtonStyle(const AContext: TThemedButtonRenderContext; const ASurface, AAccent: TThemeColor; var ABack, AFore, ABorder: TThemeColor);
var
  LSemantic: TThemeColor;
begin
  case AContext.Style of
    tbstOutline:
      begin
        if ThemeColorAlpha(ABorder) = 0 then LSemantic := AAccent else LSemantic := ABorder;
        ABack := ASurface;
        ABorder := LSemantic;
        AFore := EnsureReadableForeColor(LSemantic, ABack);
      end;
    tbstFlat:
      begin
        ABack := BlendColor(ASurface, ABack, 0.14);
        ABorder := ThemeColor(0, 0, 0, 0);
        AFore := EnsureReadableForeColor(AFore, ABack);
      end;
    tbstGhost:
      begin
        ABack := ASurface;
        ABorder := ThemeColor(0, 0, 0, 0);
        AFore := EnsureReadableForeColor(AFore, ABack);
      end;
    tbstLink:
      begin
        ABack := ASurface;
        ABorder := ThemeColor(0, 0, 0, 0);
        AFore := AAccent;
      end;
  end;
end;

class procedure TThemedButtonRenderer.ResolveHighlightColors(const AContext: TThemedButtonRenderContext; const ABaseBack, ABaseBorder, AAccent: TThemeColor; out ATargetBack, ATargetBorder: TThemeColor);
var
  LHover: TThemeColor;
begin
  ATargetBack := ABaseBack;
  ATargetBorder := ABaseBorder;
  if AContext.CustomHoverBackColor <> 0 then LHover := AContext.CustomHoverBackColor else LHover := NimbusHoverBackColor(AContext.Palette);
  case AContext.HighlightStyle of
    tbhsNone: Exit;
    tbhsBorder:
      begin
        ATargetBorder := AAccent;
        Exit;
      end;
    tbhsAccent:
      begin
        ATargetBack := BlendColor(ABaseBack, AAccent, 0.20);
        ATargetBorder := BlendColor(ABaseBorder, AAccent, 0.70);
        Exit;
      end;
    tbhsFilled:
      begin
        ATargetBack := BlendColor(ABaseBack, LHover, 0.55);
        ATargetBorder := BlendColor(ABaseBorder, ATargetBack, 0.72);
        Exit;
      end;
    tbhsGlow:
      begin
        ATargetBack := BlendColor(ABaseBack, AAccent, 0.12);
        ATargetBorder := AAccent;
        Exit;
      end;
  end;
  ATargetBack := BlendColor(ABaseBack, LHover, 0.24);
  ATargetBorder := BlendColor(ABaseBorder, ATargetBack, 0.48);
end;

class procedure TThemedButtonRenderer.ResolveColors(const AContext: TThemedButtonRenderContext; out ABack, AFore, ABorder: TThemeColor);
const
  SuccessBack = TThemeColor($FF28A745);
  SuccessBorder = TThemeColor($FF228E3B);
  WarningBack = TThemeColor($FFFFC107);
  WarningFore = TThemeColor($FF232323);
  WarningBorder = TThemeColor($FFDAA506);
  DangerBack = TThemeColor($FFDC3545);
  DangerBorder = TThemeColor($FFBB2D3B);
var
  LThemeBack, LThemeFore, LThemeBorder, LAccent: TThemeColor;
  LBaseBack, LBaseBorder, LTargetBack, LTargetBorder: TThemeColor;
  LProgress: Single;
  LAnimated: Boolean;
begin
  LThemeBack := NimbusControlBackColor(AContext.Palette);
  LThemeFore := NimbusControlForeColor(AContext.Palette);
  LThemeBorder := NimbusControlBorderColor(AContext.Palette);
  LAccent := NimbusAccentColor(AContext.Palette);
  ABack := LThemeBack;
  AFore := LThemeFore;
  ABorder := LThemeBorder;
  case AContext.Kind of
    tbkPrimary:
      begin
        ABack := LAccent;
        AFore := NimbusSelectedForeColor(AContext.Palette);
        ABorder := LAccent;
      end;
    tbkSuccess:
      begin
        ABack := SuccessBack;
        AFore := TThemeColor($FFFFFFFF);
        ABorder := SuccessBorder;
      end;
    tbkWarning:
      begin
        ABack := WarningBack;
        AFore := WarningFore;
        ABorder := WarningBorder;
      end;
    tbkDanger:
      begin
        ABack := DangerBack;
        AFore := TThemeColor($FFFFFFFF);
        ABorder := DangerBorder;
      end;
    tbkGhost:
      begin
        ABack := NimbusPanelBackColor(AContext.Palette);
        AFore := LThemeFore;
        ABorder := ThemeColor(0, 0, 0, 0);
      end;
    tbkLink:
      begin
        ABack := NimbusPanelBackColor(AContext.Palette);
        AFore := LAccent;
        ABorder := ThemeColor(0, 0, 0, 0);
      end;
  end;
  if (AContext.ColorMode = tbcmCustom) or (AContext.Kind = tbkCustom) then
  begin
    if AContext.CustomBackColor <> 0 then ABack := AContext.CustomBackColor;
    if AContext.CustomForeColor <> 0 then AFore := AContext.CustomForeColor;
    if AContext.CustomBorderColor <> 0 then ABorder := AContext.CustomBorderColor;
  end;
  ApplyButtonStyle(AContext, LThemeBack, LAccent, ABack, AFore, ABorder);
  if not AContext.Enabled then
  begin
    ABack := NimbusDisabledBackColor(AContext.Palette);
    AFore := NimbusDisabledForeColor(AContext.Palette);
    ABorder := AFore;
    Exit;
  end;
  if AContext.Checked then
  begin
    if AContext.CustomCheckedBackColor <> 0 then LTargetBack := AContext.CustomCheckedBackColor else if AContext.Palette <> nil then LTargetBack := AContext.Palette.SelectedBackColor else LTargetBack := BlendColor(LAccent, TThemeColor($FFFFFFFF), 0.35);
    ABack := LTargetBack;
    ABorder := BlendColor(ABorder, LTargetBack, 0.65);
  end;
  LBaseBack := ABack;
  LBaseBorder := ABorder;
  LTargetBack := LBaseBack;
  LTargetBorder := LBaseBorder;
  LAnimated := False;
  if AContext.Pressed or AContext.DropDownPressed then
  begin
    if AContext.CustomPressedBackColor <> 0 then LTargetBack := AContext.CustomPressedBackColor else if AContext.HighlightStyle = tbhsFilled then LTargetBack := BlendColor(LBaseBack, NimbusPressedBackColor(AContext.Palette), 0.62) else LTargetBack := BlendColor(LBaseBack, NimbusPressedBackColor(AContext.Palette), 0.42);
    LTargetBorder := BlendColor(LBaseBorder, LTargetBack, 0.70);
    LAnimated := AContext.HighlightStyle <> tbhsNone;
  end
  else if AContext.Hot or AContext.DropDownHot then
  begin
    ResolveHighlightColors(AContext, LBaseBack, LBaseBorder, LAccent, LTargetBack, LTargetBorder);
    LAnimated := AContext.HighlightStyle <> tbhsNone;
  end;
  LProgress := 1.0;
  if LAnimated and (AContext.AnimationMode in [tbamColorFade, tbamColorFadeAndPress]) then LProgress := EnsureRange(AContext.AnimationProgress, 0.0, 1.0);
  ABack := BlendColor(LBaseBack, LTargetBack, LProgress);
  ABorder := BlendColor(LBaseBorder, LTargetBorder, LProgress);
  AFore := EnsureReadableForeColor(AFore, ABack);
end;

class function TThemedButtonRenderer.EffectiveRadius(const AContext: TThemedButtonRenderContext; const ARect: TRect): Integer;
begin
  case AContext.Shape of
    tbsRectangle: Result := 0;
    tbsPill: Result := Max(1, ARect.Height div 2);
  else
    Result := Max(0, AContext.CornerRadius);
  end;
end;

class function TThemedButtonRenderer.ScaleRectAround(const ARect: TRect; const ACenterX, ACenterY, AScale: Single): TRect;
begin
  if NimbusRectIsEmpty(ARect) then begin Result := ARect; Exit; end;
  Result.Left := Round(ACenterX + (ARect.Left - ACenterX) * AScale);
  Result.Top := Round(ACenterY + (ARect.Top - ACenterY) * AScale);
  Result.Right := Round(ACenterX + (ARect.Right - ACenterX) * AScale);
  Result.Bottom := Round(ACenterY + (ARect.Bottom - ACenterY) * AScale);
end;

class procedure TThemedButtonRenderer.ApplyPressScale(var AContext: TThemedButtonRenderContext);
var
  LScale, CX, CY: Single;
begin
  if not AContext.Pressed or (AContext.PressScale >= 0.999) then Exit;
  LScale := EnsureRange(AContext.PressScale, 0.85, 1.0);
  CX := AContext.Bounds.Left + AContext.Bounds.Width / 2.0;
  CY := AContext.Bounds.Top + AContext.Bounds.Height / 2.0;
  AContext.Bounds := ScaleRectAround(AContext.Bounds, CX, CY, LScale);
  AContext.MainBounds := ScaleRectAround(AContext.MainBounds, CX, CY, LScale);
  AContext.DropDownBounds := ScaleRectAround(AContext.DropDownBounds, CX, CY, LScale);
  AContext.ContentBounds := ScaleRectAround(AContext.ContentBounds, CX, CY, LScale);
  AContext.ImageBounds := ScaleRectAround(AContext.ImageBounds, CX, CY, LScale);
  AContext.TextBounds := ScaleRectAround(AContext.TextBounds, CX, CY, LScale);
  AContext.ShortcutBounds := ScaleRectAround(AContext.ShortcutBounds, CX, CY, LScale);
  AContext.BadgeBounds := ScaleRectAround(AContext.BadgeBounds, CX, CY, LScale);
end;

class function TThemedButtonRenderer.TextFlags(const AContext: TThemedButtonRenderContext; const AAlignment: TThemedContentAlignment): TNimbusTextFlags;
begin
  Result := [];
  if not AContext.Multiline then Include(Result, ntfSingleLine) else Include(Result, ntfWordWrap);
  if AContext.AutoEllipsis then Include(Result, ntfEndEllipsis);
  if not AContext.UseMnemonic then Include(Result, ntfNoPrefix);
  if AContext.RightToLeft then Include(Result, ntfRightToLeft);
  case AAlignment of
    tcaTopCenter, tcaMiddleCenter, tcaBottomCenter: Include(Result, ntfCenter);
    tcaTopRight, tcaMiddleRight, tcaBottomRight: Include(Result, ntfRight);
  end;
  case AAlignment of
    tcaMiddleLeft, tcaMiddleCenter, tcaMiddleRight: Include(Result, ntfVCenter);
    tcaBottomLeft, tcaBottomCenter, tcaBottomRight: Include(Result, ntfBottom);
  end;
end;

class procedure TThemedButtonRenderer.DrawBackground(const ACanvas: INimbusRenderCanvas; const AContext: TThemedButtonRenderContext; const ABack, ABorder: TThemeColor);
var
  LFillRect, LBorderRect: TRect;
  LRadius, LInset: Integer;
begin
  LFillRect := AContext.Bounds;
  Dec(LFillRect.Right);
  Dec(LFillRect.Bottom);
  if NimbusRectIsEmpty(LFillRect) then Exit;
  LRadius := EffectiveRadius(AContext, LFillRect);
  ACanvas.FillRoundedRectangle(ABack, LFillRect, LRadius);
  if not AContext.ShowBorder or (AContext.Kind = tbkLink) or (ThemeColorAlpha(ABorder) = 0) then Exit;
  LInset := Max(1, Ceil(Max(1, AContext.BorderThickness) / 2.0));
  LBorderRect := LFillRect;
  InflateRect(LBorderRect, -LInset, -LInset);
  if NimbusRectIsEmpty(LBorderRect) then Exit;
  ACanvas.DrawRoundedRectangle(ABorder, LBorderRect, Max(0, LRadius - LInset), Max(1, AContext.BorderThickness));
end;

class procedure TThemedButtonRenderer.DrawIndicator(const ACanvas: INimbusRenderCanvas; const AContext: TThemedButtonRenderContext; const AFore: TThemeColor);
var
  LColor: TThemeColor;
  LRect: TRect;
  LThickness: Integer;
begin
  if not AContext.IndicatorVisible or (AContext.IndicatorPlacement = tbipNone) or (AContext.IndicatorThickness <= 0) then Exit;
  if AContext.IndicatorColor <> 0 then LColor := AContext.IndicatorColor else LColor := NimbusAccentColor(AContext.Palette);
  if LColor = 0 then LColor := AFore;
  LRect := AContext.MainBounds;
  LThickness := Min(AContext.IndicatorThickness, Min(LRect.Width, LRect.Height));
  case AContext.IndicatorPlacement of
    tbipLeft: LRect.Right := LRect.Left + LThickness;
    tbipTop: LRect.Bottom := LRect.Top + LThickness;
    tbipRight: LRect.Left := LRect.Right - LThickness;
    tbipBottom: LRect.Top := LRect.Bottom - LThickness;
  end;
  ACanvas.FillRectangle(LColor, LRect);
end;

class procedure TThemedButtonRenderer.DrawContent(const ACanvas: INimbusRenderCanvas; const AContext: TThemedButtonRenderContext; const AFore: TThemeColor);
var
  LBadgeBack, LBadgeFore: TThemeColor;
  LTextValue: string;
  LSpinner: TRect;
  LBadgeRadius: Integer;
  LSpinnerWidth: Single;
begin
  if AContext.Loading and (AContext.LoadingText <> '') then LTextValue := AContext.LoadingText else LTextValue := AContext.Caption;
  if AContext.Loading then
  begin
    LSpinner := Rect(AContext.ContentBounds.Left, AContext.ContentBounds.Top + (AContext.ContentBounds.Height - AContext.SpinnerSize) div 2, AContext.ContentBounds.Left + AContext.SpinnerSize, AContext.ContentBounds.Top + (AContext.ContentBounds.Height - AContext.SpinnerSize) div 2 + AContext.SpinnerSize);
    LSpinnerWidth := AContext.SpinnerSize / 8.0;
    if LSpinnerWidth < 2.0 then LSpinnerWidth := 2.0;
    ACanvas.DrawArc(AFore, LSpinner, AContext.SpinnerAngle, 270.0, LSpinnerWidth);
  end
  else if (AContext.IconHandle <> 0) and not NimbusRectIsEmpty(AContext.ImageBounds) then
    ACanvas.DrawIcon(AContext.IconHandle, AContext.ImageBounds);
  if (LTextValue <> '') and not NimbusRectIsEmpty(AContext.TextBounds) then ACanvas.DrawText(LTextValue, AContext.Font, AFore, AContext.TextBounds, TextFlags(AContext, AContext.TextAlign));
  if (AContext.ShortcutText <> '') and not NimbusRectIsEmpty(AContext.ShortcutBounds) then ACanvas.DrawText(AContext.ShortcutText, AContext.Font, AFore, AContext.ShortcutBounds, [ntfRight, ntfVCenter, ntfSingleLine, ntfNoPrefix]);
  if (AContext.BadgeText <> '') and not NimbusRectIsEmpty(AContext.BadgeBounds) then
  begin
    if AContext.BadgeBackColor <> 0 then LBadgeBack := AContext.BadgeBackColor else LBadgeBack := NimbusAccentColor(AContext.Palette);
    if AContext.BadgeForeColor <> 0 then LBadgeFore := AContext.BadgeForeColor else LBadgeFore := TThemeColor($FFFFFFFF);
    LBadgeRadius := AContext.BadgeBounds.Height div 2;
    ACanvas.FillRoundedRectangle(LBadgeBack, AContext.BadgeBounds, LBadgeRadius);
    ACanvas.DrawText(AContext.BadgeText, AContext.Font, LBadgeFore, AContext.BadgeBounds, [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix]);
  end;
end;

class procedure TThemedButtonRenderer.DrawDropDown(const ACanvas: INimbusRenderCanvas; const AContext: TThemedButtonRenderContext; const AFore, ABorder: TThemeColor);
var
  CX, CY: Integer;
  P1, P2, P3: TPoint;
begin
  if (AContext.DropDownMode = tbddNone) or NimbusRectIsEmpty(AContext.DropDownBounds) then Exit;
  if AContext.DropDownMode = tbddSplitButton then ACanvas.DrawLine(ABorder, AContext.DropDownBounds.Left, AContext.DropDownBounds.Top + 4, AContext.DropDownBounds.Left, AContext.DropDownBounds.Bottom - 4, 1.0);
  CX := AContext.DropDownBounds.Left + AContext.DropDownBounds.Width div 2;
  CY := AContext.DropDownBounds.Top + AContext.DropDownBounds.Height div 2;
  P1 := Point(CX - 4, CY - 2);
  P2 := Point(CX + 4, CY - 2);
  P3 := Point(CX, CY + 3);
  ACanvas.FillTriangle(AFore, P1, P2, P3);
end;

class procedure TThemedButtonRenderer.DrawFocus(const ACanvas: INimbusRenderCanvas; const AContext: TThemedButtonRenderContext; const AFore: TThemeColor);
var
  LRect: TRect;
  LInset: Integer;
  LColor: TThemeColor;
begin
  if not AContext.Focused or not AContext.ShowFocusIndicator or (AContext.FocusStyle = tbfsNone) then Exit;
  if AContext.FocusStyle = tbfsContent then LRect := AContext.ContentBounds else LRect := AContext.Bounds;
  if AContext.FocusStyle = tbfsBorder then LInset := 1 else LInset := 4;
  InflateRect(LRect, -LInset, -LInset);
  if NimbusRectIsEmpty(LRect) then Exit;
  LColor := NimbusFocusBorderColor(AContext.Palette);
  if LColor = 0 then LColor := AFore;
  ACanvas.DrawDashedRectangle(LColor, LRect, 1.0);
end;

class procedure TThemedButtonRenderer.Render(const ACanvas: INimbusRenderCanvas; const AContext: TThemedButtonRenderContext);
var
  LContext: TThemedButtonRenderContext;
  LBack, LFore, LBorder: TThemeColor;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(AContext.Bounds) then Exit;
  LContext := AContext;
  ResolveColors(LContext, LBack, LFore, LBorder);
  ACanvas.FillRectangle(LContext.SurfaceBackColor, LContext.Bounds);
  ApplyPressScale(LContext);
  DrawBackground(ACanvas, LContext, LBack, LBorder);
  DrawIndicator(ACanvas, LContext, LFore);
  DrawContent(ACanvas, LContext, LFore);
  DrawDropDown(ACanvas, LContext, LFore, LBorder);
  DrawFocus(ACanvas, LContext, LFore);
end;

end.

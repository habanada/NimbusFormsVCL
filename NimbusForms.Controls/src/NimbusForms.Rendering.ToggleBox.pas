{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.ToggleBox;

interface

uses
  System.Types,
  System.UITypes,
  Vcl.Graphics,
  NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Types,
  NimbusForms.Rendering.Canvas;

type
  TToggleTextMode = (ttmNone, ttmOnOff, ttmYesNo, ttmIO, ttmCustom);
  TToggleLabelPosition = (tlpRight, tlpLeft, tlpTop, tlpBottom, tlpHidden);
  TToggleSwitchAlignment = (tsaLeft, tsaRight, tsaCenter);
  TToggleChangeSource = (tcsCode, tcsMouse, tcsKeyboard);
  TToggleFocusCueStyle = (tfcsNone, tfcsUnderline, tfcsOutline, tfcsBorder);

  TThemedToggleBoxRenderContext = record
    Bounds: TRect;
    Caption: string;
    OnText: string;
    OffText: string;
    Font: TFont;
    InnerFont: TFont;
    Palette: TThemePalette;
    State: TNimbusVisualState;
    Enabled: Boolean;
    Hovered: Boolean;
    Pressed: Boolean;
    Checked: Boolean;
    ReadOnly: Boolean;
    ShowBorder: Boolean;
    ShowFocusCue: Boolean;
    FocusCueStyle: TToggleFocusCueStyle;
    TextMode: TToggleTextMode;
    LabelPosition: TToggleLabelPosition;
    SwitchAlignment: TToggleSwitchAlignment;
    SwitchWidth: Integer;
    SwitchWidthWithText: Integer;
    SwitchHeight: Integer;
    PaddingSmall: Integer;
    PaddingText: Integer;
    InnerOffset: Integer;
    ThumbInset: Integer;
    AnimationValue: Single;
    OnBackColor: TColor;
    OffBackColor: TColor;
    ThumbColor: TColor;
    BorderColor: TColor;
    Focused: Boolean;
    RightToLeft: Boolean;
  end;

  TThemedToggleBoxRenderer = class
  public
    class procedure Render(const ACanvas: INimbusRenderCanvas; const AContext: TThemedToggleBoxRenderContext); static;
  end;

implementation

uses
  NimbusForms.Theming.Types;

function EffectiveLabelPosition(const AContext: TThemedToggleBoxRenderContext): TToggleLabelPosition;
begin
  Result := AContext.LabelPosition;
  if not AContext.RightToLeft then
    Exit;
  if Result = tlpRight then
    Result := tlpLeft
  else if Result = tlpLeft then
    Result := tlpRight;
end;

function EffectiveSwitchAlignment(const AContext: TThemedToggleBoxRenderContext): TToggleSwitchAlignment;
begin
  Result := AContext.SwitchAlignment;
  if not AContext.RightToLeft then
    Exit;
  if Result = tsaLeft then
    Result := tsaRight
  else if Result = tsaRight then
    Result := tsaLeft;
end;

function SwitchRect(const AContext: TThemedToggleBoxRenderContext): TRect;
var
  LWidth, LHeight, LX, LY: Integer;
  LLabelPosition: TToggleLabelPosition;
  LAlignment: TToggleSwitchAlignment;
begin
  if AContext.TextMode = ttmNone then
    LWidth := AContext.SwitchWidth
  else
    LWidth := AContext.SwitchWidthWithText;
  LHeight := AContext.SwitchHeight;
  LLabelPosition := EffectiveLabelPosition(AContext);
  LAlignment := EffectiveSwitchAlignment(AContext);

  if LLabelPosition in [tlpTop, tlpBottom, tlpHidden] then
  begin
    case LAlignment of
      tsaRight: LX := AContext.Bounds.Right - LWidth;
      tsaCenter: LX := AContext.Bounds.Left + (AContext.Bounds.Width - LWidth) div 2;
    else
      LX := AContext.Bounds.Left;
    end;

    if LLabelPosition = tlpTop then
      LY := AContext.Bounds.Bottom - LHeight
    else if LLabelPosition = tlpBottom then
      LY := AContext.Bounds.Top
    else
      LY := AContext.Bounds.Top + (AContext.Bounds.Height - LHeight) div 2;
    Result := Rect(LX, LY, LX + LWidth, LY + LHeight);
    Exit;
  end;

  LY := AContext.Bounds.Top + (AContext.Bounds.Height - LHeight) div 2;
  if LLabelPosition = tlpLeft then
  begin
    if LAlignment = tsaLeft then
      LX := AContext.Bounds.Right - LWidth
    else
      LX := AContext.Bounds.Left;
    Result := Rect(LX, LY, LX + LWidth, LY + LHeight);
    Exit;
  end;

  if LAlignment = tsaRight then
    LX := AContext.Bounds.Right - LWidth
  else if (LAlignment = tsaCenter) and (AContext.Caption = '') then
    LX := AContext.Bounds.Left + (AContext.Bounds.Width - LWidth) div 2
  else
    LX := AContext.Bounds.Left;
  Result := Rect(LX, LY, LX + LWidth, LY + LHeight);
end;

function LabelRect(const AContext: TThemedToggleBoxRenderContext; const ASwitchRect: TRect): TRect;
var
  LLabelPosition: TToggleLabelPosition;
begin
  Result := Rect(0, 0, 0, 0);
  LLabelPosition := EffectiveLabelPosition(AContext);
  if (AContext.Caption = '') or (LLabelPosition = tlpHidden) then
    Exit;

  case LLabelPosition of
    tlpLeft: Result := Rect(AContext.Bounds.Left, AContext.Bounds.Top, ASwitchRect.Left - AContext.PaddingText, AContext.Bounds.Bottom);
    tlpRight: Result := Rect(ASwitchRect.Right + AContext.PaddingText, AContext.Bounds.Top, AContext.Bounds.Right, AContext.Bounds.Bottom);
    tlpTop: Result := Rect(AContext.Bounds.Left, AContext.Bounds.Top, AContext.Bounds.Right, ASwitchRect.Top - AContext.PaddingText);
    tlpBottom: Result := Rect(AContext.Bounds.Left, ASwitchRect.Bottom + AContext.PaddingText, AContext.Bounds.Right, AContext.Bounds.Bottom);
  end;
end;

function ResolveCustomColor(const AColor: TColor; const AFallback: TThemeColor): TThemeColor;
begin
  if AColor = Vcl.Graphics.clNone then
    Result := AFallback
  else
    Result := ColorToThemeColor(AColor);
end;

class procedure TThemedToggleBoxRenderer.Render(const ACanvas: INimbusRenderCanvas; const AContext: TThemedToggleBoxRenderContext);
var
  LTrack, LThumb, LLabel, LInnerRect, LFocus: TRect;
  LTrackOff, LTrackOn, LTrackBack, LBorder, LEffectiveBorder, LThumbBack, LFore, LInnerFore: TThemeColor;
  LThumbSize, LMinX, LMaxX, LThumbX, LThumbY, LWeight, LInset, LY: Integer;
  LBorderWidth, LFocusWidth: Single;
  LInnerText: string;
  LUseFocusBorder, LDrawTrackBorder: Boolean;
  LLabelPosition: TToggleLabelPosition;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(AContext.Bounds) then
    Exit;

  ACanvas.FillRectangle(NimbusPanelBackColor(AContext.Palette), AContext.Bounds);

  LTrackOff := ResolveCustomColor(AContext.OffBackColor, NimbusControlBorderColor(AContext.Palette));
  LTrackOn := ResolveCustomColor(AContext.OnBackColor, NimbusAccentColor(AContext.Palette));
  LBorder := ResolveCustomColor(AContext.BorderColor, NimbusControlBorderColor(AContext.Palette));
  if AContext.ThumbColor <> Vcl.Graphics.clNone then
    LThumbBack := ColorToThemeColor(AContext.ThumbColor)
  else if (AContext.Palette <> nil) and AContext.Palette.IsDark then
    LThumbBack := ThemeColor(255, 240, 240, 240)
  else
    LThumbBack := ThemeColor(255, 255, 255, 255);
  LFore := NimbusControlForeColor(AContext.Palette);

  if not AContext.Enabled then
  begin
    LTrackOff := NimbusDisabledBackColor(AContext.Palette);
    LTrackOn := LTrackOff;
    LThumbBack := NimbusDisabledForeColor(AContext.Palette);
    LFore := NimbusDisabledForeColor(AContext.Palette);
    LBorder := NimbusDisabledForeColor(AContext.Palette);
  end
  else
  begin
    if AContext.Hovered and not AContext.Checked then
      LTrackOff := NimbusHoverBackColor(AContext.Palette);
    if AContext.ReadOnly then
      LFore := NimbusMutedForeColor(AContext.Palette);
  end;

  if AContext.AnimationValue <= 0 then
    LWeight := 0
  else if AContext.AnimationValue >= 1 then
    LWeight := 255
  else
    LWeight := Round(AContext.AnimationValue * 255);
  LTrackBack := NimbusBlendColor(LTrackOff, LTrackOn, Byte(LWeight));

  LTrack := SwitchRect(AContext);
  if NimbusRectIsEmpty(LTrack) then
    Exit;
  ACanvas.FillRoundedRectangle(LTrackBack, LTrack, LTrack.Height div 2);

  LUseFocusBorder := AContext.ShowFocusCue and AContext.Focused and AContext.Enabled and
    (AContext.FocusCueStyle = tfcsBorder);
  if LUseFocusBorder then
    LEffectiveBorder := NimbusFocusBorderColor(AContext.Palette)
  else
    LEffectiveBorder := LBorder;
  LDrawTrackBorder := (AContext.ShowBorder or LUseFocusBorder) and
    (LUseFocusBorder or not AContext.Checked or AContext.ReadOnly or not AContext.Enabled);
  if LDrawTrackBorder then
  begin
    if LUseFocusBorder then
      LBorderWidth := 1.25
    else
      LBorderWidth := 1.0;
    ACanvas.DrawRoundedRectangle(LEffectiveBorder, LTrack, LTrack.Height div 2, LBorderWidth);
  end;

  LThumbSize := LTrack.Height - AContext.ThumbInset;
  if LThumbSize < 1 then LThumbSize := 1;
  LMinX := LTrack.Left + AContext.PaddingSmall;
  LMaxX := LTrack.Right - LThumbSize - AContext.PaddingSmall;
  if LMaxX < LMinX then LMaxX := LMinX;
  LThumbX := LMinX + Round((LMaxX - LMinX) * AContext.AnimationValue);
  if AContext.Pressed and AContext.Enabled and not AContext.ReadOnly then
  begin
    if AContext.Checked then
      Dec(LThumbX)
    else
      Inc(LThumbX);
  end;
  LThumbY := LTrack.Top + AContext.PaddingSmall;
  LThumb := Rect(LThumbX, LThumbY, LThumbX + LThumbSize, LThumbY + LThumbSize);

  if AContext.TextMode <> ttmNone then
  begin
    if AContext.Checked then
      LInnerText := AContext.OnText
    else
      LInnerText := AContext.OffText;
    if AContext.Checked then
      LInnerFore := NimbusSelectedForeColor(AContext.Palette)
    else
      LInnerFore := NimbusControlForeColor(AContext.Palette);
    if not AContext.Enabled then
      LInnerFore := NimbusDisabledForeColor(AContext.Palette);
    if LInnerText <> '' then
    begin
      if AContext.Checked then
        LInset := LTrack.Left + AContext.InnerOffset
      else
        LInset := LTrack.Left + LThumbSize + AContext.PaddingSmall;
      LInnerRect := Rect(LInset, LTrack.Top, LInset + LTrack.Width - LThumbSize - AContext.InnerOffset, LTrack.Bottom);
      if LInnerRect.Right > LTrack.Right then LInnerRect.Right := LTrack.Right;
      ACanvas.DrawText(LInnerText, AContext.InnerFont, LInnerFore, LInnerRect,
        [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix, ntfEndEllipsis]);
    end;
  end;

  ACanvas.FillEllipse(LThumbBack, LThumb);
  if AContext.ShowBorder then
    ACanvas.DrawEllipse(ThemeColor(50, 0, 0, 0), LThumb, 1.0);

  LLabel := LabelRect(AContext, LTrack);
  if not NimbusRectIsEmpty(LLabel) and (AContext.Caption <> '') then
  begin
    LLabelPosition := EffectiveLabelPosition(AContext);
    if LLabelPosition in [tlpTop, tlpBottom] then
      ACanvas.DrawText(AContext.Caption, AContext.Font, LFore, LLabel,
        [ntfCenter, ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix])
    else if AContext.RightToLeft then
      ACanvas.DrawText(AContext.Caption, AContext.Font, LFore, LLabel,
        [ntfRight, ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix, ntfRightToLeft])
    else
      ACanvas.DrawText(AContext.Caption, AContext.Font, LFore, LLabel,
        [ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix]);
  end;

  if not AContext.ShowFocusCue or not AContext.Focused or not AContext.Enabled or
    (AContext.FocusCueStyle in [tfcsNone, tfcsBorder]) then
    Exit;

  if AContext.FocusCueStyle = tfcsOutline then
  begin
    LFocus := Rect(LTrack.Left, LTrack.Top, LTrack.Right - 1, LTrack.Bottom - 1);
    ACanvas.DrawRoundedRectangle(NimbusColorWithAlpha(NimbusFocusBorderColor(AContext.Palette), 180),
      LFocus, LFocus.Height div 2, 1.0);
    Exit;
  end;

  LInset := AContext.PaddingSmall;
  if LInset < 5 then LInset := 5;
  LY := LTrack.Bottom - 1;
  LFocusWidth := 1.5;
  ACanvas.DrawLine(NimbusColorWithAlpha(NimbusFocusBorderColor(AContext.Palette), 220),
    LTrack.Left + LInset, LY, LTrack.Right - LInset, LY, LFocusWidth);
end;

end.

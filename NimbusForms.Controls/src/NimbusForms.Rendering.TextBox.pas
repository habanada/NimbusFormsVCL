{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.TextBox;

interface

uses
  System.Types,
  Vcl.Graphics,
  NimbusForms.Theming.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Canvas,
  NimbusForms.Controls.Types;

type
  TThemedTextBoxRenderContext = record
    Bounds: TRect;
    Font: TFont;
    Palette: TThemePalette;
    PrefixText: string;
    SuffixText: string;
    PrefixRect: TRect;
    SuffixRect: TRect;
    ClearRect: TRect;
    PasswordRect: TRect;
    ValidationRect: TRect;
    BorderThickness: Integer;
    CornerRadius: Integer;
    UseRoundedCorners: Boolean;
    Enabled: Boolean;
    Focused: Boolean;
    Hovered: Boolean;
    ReadOnly: Boolean;
    ShowClearButton: Boolean;
    ShowPasswordButton: Boolean;
    ShowValidationIcon: Boolean;
    ClearHovered: Boolean;
    ClearPressed: Boolean;
    PasswordHovered: Boolean;
    PasswordPressed: Boolean;
    PasswordVisible: Boolean;
    ValidationState: TThemedTextBoxValidationState;
    RightToLeft: Boolean;
  end;

  TThemedTextBoxRenderer = class
  private
    class function ResolveBackColor(const AContext: TThemedTextBoxRenderContext): TThemeColor; static;
    class function ResolveBorderColor(const AContext: TThemedTextBoxRenderContext): TThemeColor; static;
    class function CenterIcon(const AArea: TRect; const ASize: Integer): TRect; static;
  public
    class procedure Render(const ACanvas: INimbusRenderCanvas; const AContext: TThemedTextBoxRenderContext; const AIconSize: Integer); static;
  end;

implementation

uses
  System.Math,
  NimbusForms.Rendering.Types;

class function TThemedTextBoxRenderer.ResolveBackColor(const AContext: TThemedTextBoxRenderContext): TThemeColor;
begin
  if not AContext.Enabled then Result := NimbusDisabledBackColor(AContext.Palette)
  else if AContext.ReadOnly then Result := NimbusPanelBackColor(AContext.Palette)
  else Result := NimbusInputBackColor(AContext.Palette);
end;

class function TThemedTextBoxRenderer.ResolveBorderColor(const AContext: TThemedTextBoxRenderContext): TThemeColor;
begin
  case AContext.ValidationState of
    tvsSuccess: Exit(NimbusSuccessColor);
    tvsWarning: Exit(NimbusWarningColor);
    tvsError: Exit(NimbusDangerColor);
  end;
  if not AContext.Enabled then Result := NimbusControlBorderColor(AContext.Palette)
  else if AContext.Focused then Result := NimbusFocusBorderColor(AContext.Palette)
  else if AContext.Hovered then Result := NimbusControlBorderColor(AContext.Palette)
  else Result := NimbusInputBorderColor(AContext.Palette);
end;

class function TThemedTextBoxRenderer.CenterIcon(const AArea: TRect; const ASize: Integer): TRect;
var
  LSize: Integer;
begin
  LSize := ASize;
  if LSize < 1 then LSize := 1;
  if LSize > AArea.Width then LSize := AArea.Width;
  if LSize > AArea.Height then LSize := AArea.Height;
  Result := Rect(AArea.Left + (AArea.Width - LSize) div 2, AArea.Top + (AArea.Height - LSize) div 2,
    AArea.Left + (AArea.Width - LSize) div 2 + LSize, AArea.Top + (AArea.Height - LSize) div 2 + LSize);
end;

class procedure TThemedTextBoxRenderer.Render(const ACanvas: INimbusRenderCanvas; const AContext: TThemedTextBoxRenderContext; const AIconSize: Integer);
var
  LBack, LBorder, LFore, LMuted, LIconBack, LValidationColor: TThemeColor;
  LRadius, LThickness, LOffset: Integer;
  LIconRect, LEyeRect: TRect;
  LFlags: TNimbusTextFlags;
  LGlyph: string;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(AContext.Bounds) then
    Exit;
  LBack := ResolveBackColor(AContext);
  LBorder := ResolveBorderColor(AContext);
  if AContext.Enabled then LFore := NimbusInputForeColor(AContext.Palette) else LFore := NimbusDisabledForeColor(AContext.Palette);
  LMuted := NimbusMutedForeColor(AContext.Palette);
  LRadius := AContext.CornerRadius;
  if not AContext.UseRoundedCorners then LRadius := 0;
  LThickness := AContext.BorderThickness;
  if LThickness < 1 then LThickness := 1;
  ACanvas.FillRectangle(NimbusPanelBackColor(AContext.Palette), AContext.Bounds);
  ACanvas.FillRoundedRectangle(LBack, AContext.Bounds, LRadius);
  ACanvas.DrawRoundedRectangle(LBorder, AContext.Bounds, LRadius, LThickness);
  LFlags := [ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix];
  if AContext.RightToLeft then Include(LFlags, ntfRightToLeft);
  if AContext.PrefixText <> '' then ACanvas.DrawText(AContext.PrefixText, AContext.Font, LMuted, AContext.PrefixRect, LFlags);
  if AContext.SuffixText <> '' then ACanvas.DrawText(AContext.SuffixText, AContext.Font, LMuted, AContext.SuffixRect, LFlags);
  if AContext.ShowValidationIcon then
  begin
    LIconRect := CenterIcon(AContext.ValidationRect, AIconSize);
    case AContext.ValidationState of
      tvsSuccess: begin LValidationColor := NimbusSuccessColor; LGlyph := #$2713; end;
      tvsWarning: begin LValidationColor := NimbusWarningColor; LGlyph := '!'; end;
      tvsError: begin LValidationColor := NimbusDangerColor; LGlyph := #$00D7; end;
    else
      LValidationColor := LBorder;
      LGlyph := '';
    end;
    if LGlyph <> '' then
    begin
      ACanvas.FillEllipse(LValidationColor, LIconRect);
      ACanvas.DrawText(LGlyph, AContext.Font, TThemeColor($FFFFFFFF), LIconRect, [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix]);
    end;
  end;
  if AContext.ShowClearButton then
  begin
    LIconRect := CenterIcon(AContext.ClearRect, AIconSize);
    if AContext.ClearPressed then LIconBack := NimbusPressedBackColor(AContext.Palette)
    else if AContext.ClearHovered then LIconBack := NimbusHoverBackColor(AContext.Palette)
    else LIconBack := TThemeColor(0);
    if ThemeColorAlpha(LIconBack) <> 0 then ACanvas.FillEllipse(LIconBack, LIconRect);
    LOffset := Max(2, AIconSize div 4);
    ACanvas.DrawLine(LFore, LIconRect.Left + LOffset, LIconRect.Top + LOffset, LIconRect.Right - LOffset, LIconRect.Bottom - LOffset, 1.5);
    ACanvas.DrawLine(LFore, LIconRect.Right - LOffset, LIconRect.Top + LOffset, LIconRect.Left + LOffset, LIconRect.Bottom - LOffset, 1.5);
  end;
  if AContext.ShowPasswordButton then
  begin
    LIconRect := CenterIcon(AContext.PasswordRect, AIconSize);
    if AContext.PasswordPressed then LIconBack := NimbusPressedBackColor(AContext.Palette)
    else if AContext.PasswordHovered or AContext.PasswordVisible then LIconBack := NimbusHoverBackColor(AContext.Palette)
    else LIconBack := TThemeColor(0);
    if ThemeColorAlpha(LIconBack) <> 0 then ACanvas.FillEllipse(LIconBack, LIconRect);
    LEyeRect := Rect(LIconRect.Left + 3, LIconRect.Top + 5, LIconRect.Right - 3, LIconRect.Bottom - 5);
    if not NimbusRectIsEmpty(LEyeRect) then
    begin
      ACanvas.DrawEllipse(LFore, LEyeRect, 1.4);
      ACanvas.FillEllipse(LFore, Rect((LEyeRect.Left + LEyeRect.Right) div 2 - 2, (LEyeRect.Top + LEyeRect.Bottom) div 2 - 2,
        (LEyeRect.Left + LEyeRect.Right) div 2 + 2, (LEyeRect.Top + LEyeRect.Bottom) div 2 + 2));
    end;
    if not AContext.PasswordVisible then ACanvas.DrawLine(LFore, LIconRect.Left + 3, LIconRect.Bottom - 3, LIconRect.Right - 3, LIconRect.Top + 3, 1.4);
  end;
end;

end.

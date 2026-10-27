{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.BadgeLabel;

interface

uses
  System.Types, Vcl.Graphics, NimbusForms.Theming.Types, NimbusForms.Theming.Palette, NimbusForms.Rendering.Canvas;

type
  TThemedBadgeKind = (tbkAccent, tbkInfo, tbkSuccess, tbkWarning, tbkError, tbkNeutral, tbkCustom);
  TThemedBadgeShape = (tbsPill, tbsRoundedRectangle, tbsRectangle, tbsCircle);
  TThemedBadgeImageAlign = (tbiaLeft, tbiaRight);

  TThemedBadgeLabelRenderer = class
  public
    class procedure Render(const ACanvas: INimbusRenderCanvas; const ARect: TRect; const AText: string; const AFont: TFont; const APalette: TThemePalette; const AKind: TThemedBadgeKind; const AShape: TThemedBadgeShape; const ACustomBack, ACustomFore, ACustomBorder: TColor; const AShowBorder, AEnabled, AHot, APressed: Boolean; const ARadius, ABorderWidth: Integer; const AImage: Vcl.Graphics.TBitmap; const AImageRect, ATextRect, ACloseRect: TRect); static;
  end;

implementation

uses
  System.UITypes, NimbusForms.Rendering.Types;

function BadgeFore(const ABackground: TThemeColor): TThemeColor;
var
  Brightness: Integer;
begin
  Brightness := ThemeColorRed(ABackground) * 299 + ThemeColorGreen(ABackground) * 587 + ThemeColorBlue(ABackground) * 114;
  if Brightness >= 145000 then Result := ThemeColor(255, 25, 29, 36) else Result := ThemeColor(255, 255, 255, 255);
end;

class procedure TThemedBadgeLabelRenderer.Render(const ACanvas: INimbusRenderCanvas; const ARect: TRect; const AText: string; const AFont: TFont; const APalette: TThemePalette; const AKind: TThemedBadgeKind; const AShape: TThemedBadgeShape; const ACustomBack, ACustomFore, ACustomBorder: TColor; const AShowBorder, AEnabled, AHot, APressed: Boolean; const ARadius, ABorderWidth: Integer; const AImage: Vcl.Graphics.TBitmap; const AImageRect, ATextRect, ACloseRect: TRect);
var
  Base, Back, Fore, Border: TThemeColor;
  R, Stroke: TRect;
  Radius: Integer;
  X, Y, Size: Integer;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(ARect) then Exit;
  case AKind of
    tbkInfo: Base := ThemeColor(255, 54, 140, 245);
    tbkSuccess: Base := NimbusSuccessColor;
    tbkWarning: Base := NimbusWarningColor;
    tbkError: Base := NimbusDangerColor;
    tbkNeutral: Base := NimbusMutedForeColor(APalette);
    tbkCustom: Base := ColorToThemeColor(ACustomBack);
  else
    Base := NimbusAccentColor(APalette);
  end;
  if (APalette <> nil) and (AKind <> tbkCustom) then Base := NimbusBlendColor(Base, APalette.AccentColor, 25);
  if AKind = tbkCustom then
  begin
    Back := ColorToThemeColor(ACustomBack);
    Fore := ColorToThemeColor(ACustomFore);
    Border := ColorToThemeColor(ACustomBorder);
  end
  else
  begin
    Back := NimbusBlendColor(NimbusPanelBackColor(APalette), Base, 35);
    Fore := Base;
    Border := NimbusBlendColor(Back, Base, 125);
  end;
  if AKind = tbkNeutral then Fore := NimbusControlForeColor(APalette);
  if AHot then Back := NimbusBlendColor(Back, Base, 34);
  if APressed then Back := NimbusBlendColor(Back, Base, 55);
  if not AEnabled then
  begin
    Back := NimbusDisabledBackColor(APalette);
    Fore := NimbusDisabledForeColor(APalette);
    Border := NimbusControlBorderColor(APalette);
  end;
  R := ARect;
  Radius := ARadius;
  if AShape = tbsPill then Radius := (R.Bottom - R.Top) div 2;
  if AShape = tbsRectangle then Radius := 0;
  if AShape = tbsCircle then Radius := (R.Bottom - R.Top) div 2;
  if Radius > (R.Bottom - R.Top) div 2 then Radius := (R.Bottom - R.Top) div 2;
  if Radius < 0 then Radius := 0;
  if AShape = tbsCircle then ACanvas.FillEllipse(Back, R)
  else if Radius > 0 then ACanvas.FillRoundedRectangle(Back, R, Radius)
  else ACanvas.FillRectangle(Back, R);
  if AShowBorder then
  begin
    Stroke := Rect(R.Left, R.Top, R.Right - 1, R.Bottom - 1);
    if AShape = tbsCircle then ACanvas.DrawEllipse(Border, Stroke, ABorderWidth)
    else if Radius > 0 then ACanvas.DrawRoundedRectangle(Border, Stroke, Radius, ABorderWidth)
    else ACanvas.DrawRectangle(Border, Stroke, ABorderWidth);
  end;
  if (AImage <> nil) and not AImage.Empty and not NimbusRectIsEmpty(AImageRect) then ACanvas.DrawBitmap(AImage, AImageRect);
  if AText <> '' then ACanvas.DrawText(AText, AFont, Fore, ATextRect, [ntfSingleLine, ntfVCenter, ntfCenter, ntfEndEllipsis, ntfNoPrefix]);
  if not NimbusRectIsEmpty(ACloseRect) then
  begin
    X := (ACloseRect.Left + ACloseRect.Right) div 2;
    Y := (ACloseRect.Top + ACloseRect.Bottom) div 2;
    Size := (ACloseRect.Bottom - ACloseRect.Top) div 5;
    if Size < 2 then Size := 2;
    ACanvas.DrawLine(Fore, X - Size, Y - Size, X + Size, Y + Size, 1.4);
    ACanvas.DrawLine(Fore, X - Size, Y + Size, X + Size, Y - Size, 1.4);
  end;
end;

end.

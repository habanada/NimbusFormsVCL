{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.DateRange;

interface

uses
  System.Types, Vcl.Graphics, NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Canvas;

type
  TThemedDateRangeRenderer = class
  public
    class procedure Render(const ACanvas: INimbusRenderCanvas; const AFont: TFont;
      const APalette: TThemePalette; const ABounds: TRect; const AText: string;
      const AEnabled, AHot, AFocused, AHasValue, AShowClear: Boolean;
      const APPI: Integer; const ACompact: Boolean = False); static;
  end;

implementation

uses
  NimbusForms.Rendering.Types, NimbusForms.Theming.Types;

class procedure TThemedDateRangeRenderer.Render(const ACanvas: INimbusRenderCanvas;
  const AFont: TFont; const APalette: TThemePalette; const ABounds: TRect;
  const AText: string; const AEnabled, AHot, AFocused, AHasValue,
  AShowClear: Boolean; const APPI: Integer; const ACompact: Boolean);
var
  R, TextRect, IconRect, ClearRect: TRect;
  Back, Fore, Border, Accent: TThemeColor;
  CX, CY, S: Integer;
begin
  Back := NimbusInputBackColor(APalette);
  Fore := NimbusInputForeColor(APalette);
  Border := NimbusInputBorderColor(APalette);
  Accent := NimbusAccentColor(APalette);
  if not AEnabled then
  begin
    Back := NimbusDisabledBackColor(APalette);
    Fore := NimbusDisabledForeColor(APalette);
  end
  else if AFocused then
    Border := NimbusFocusBorderColor(APalette)
  else if AHot then
    Border := Accent;
  ACanvas.FillRoundedRectangle(Back, ABounds, NimbusScaleValue(5 - Ord(ACompact), APPI));
  R := ABounds;
  Dec(R.Right);
  Dec(R.Bottom);
  ACanvas.DrawRoundedRectangle(Border, R, NimbusScaleValue(5 - Ord(ACompact), APPI), 1.0);
  S := NimbusScaleValue(26 - Ord(ACompact) * 5, APPI);
  IconRect := Rect(R.Right - S, R.Top, R.Right, R.Bottom);
  if AShowClear and AHasValue then
  begin
    ClearRect := Rect(IconRect.Left - S, R.Top, IconRect.Left, R.Bottom);
    CX := (ClearRect.Left + ClearRect.Right) div 2;
    CY := (ClearRect.Top + ClearRect.Bottom) div 2;
    S := NimbusScaleValue(4, APPI);
    ACanvas.DrawLine(Fore, CX - S, CY - S, CX + S, CY + S, 1.4);
    ACanvas.DrawLine(Fore, CX - S, CY + S, CX + S, CY - S, 1.4);
    TextRect := Rect(R.Left + NimbusScaleValue(9 - Ord(ACompact) * 2, APPI), R.Top,
      ClearRect.Left - NimbusScaleValue(4, APPI), R.Bottom)
  end
  else
    TextRect := Rect(R.Left + NimbusScaleValue(9 - Ord(ACompact) * 2, APPI), R.Top,
      IconRect.Left - NimbusScaleValue(4, APPI), R.Bottom);
  CX := (IconRect.Left + IconRect.Right) div 2;
  CY := (IconRect.Top + IconRect.Bottom) div 2;
  S := NimbusScaleValue(5, APPI);
  ACanvas.DrawRectangle(Fore, Rect(CX - S - 1, CY - S + 1, CX + S + 2, CY + S + 2), 1.2);
  ACanvas.DrawLine(Fore, CX - S, CY - 1, CX + S, CY - 1, 1.2);
  ACanvas.DrawLine(Fore, CX - S + 2, CY - S - 1, CX - S + 2, CY - S + 3, 1.2);
  ACanvas.DrawLine(Fore, CX + S - 2, CY - S - 1, CX + S - 2, CY - S + 3, 1.2);
  if not AHasValue then Fore := NimbusMutedForeColor(APalette);
  ACanvas.DrawText(AText, AFont, Fore, TextRect,
    [ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix]);
end;

end.

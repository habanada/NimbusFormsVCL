{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.IdeDateRange;

interface

uses
  System.Types, Vcl.Graphics, NimbusForms.Theming.Types, NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Canvas;

type
  TThemedIdeDateRangeRenderer = class
  public
    class procedure RenderField(const C: INimbusRenderCanvas; const F: TFont;
      const P: TThemePalette; const R: TRect; const S: string;
      const Hot, Focused, HasValue, ShowClear, ShowCalendarIcon, Detailed: Boolean;
      const CornerRadius: Integer); static;
    class procedure Surface(const C: INimbusRenderCanvas;
      const P: TThemePalette; const R: TRect;
      const CornerRadius: Integer); static;
    class procedure Cell(const C: INimbusRenderCanvas; const F: TFont;
      const P: TThemePalette; const R: TRect; const S: string;
      const InRange, Endpoint, Today, Disabled, Hovered: Boolean;
      const DayBack, DayFore, DayBorder: TThemeColor;
      const UseDayBack, UseDayFore, UseDayBorder: Boolean); static;
    class procedure Command(const C: INimbusRenderCanvas; const F: TFont;
      const P: TThemePalette; const R: TRect; const S: string;
      const Hovered, Primary: Boolean); static;
  end;

implementation

uses
  NimbusForms.Rendering.Types;

class procedure TThemedIdeDateRangeRenderer.RenderField(const C: INimbusRenderCanvas;
  const F: TFont; const P: TThemePalette; const R: TRect; const S: string;
  const Hot, Focused, HasValue, ShowClear, ShowCalendarIcon, Detailed: Boolean;
  const CornerRadius: Integer);
var
  Border, Fore: TThemeColor;
  T: TRect;
begin
  Border := NimbusInputBorderColor(P);
  if Focused then Border := NimbusFocusBorderColor(P)
  else if Hot then Border := NimbusAccentColor(P);
  C.FillRoundedRectangle(NimbusInputBackColor(P), R, CornerRadius);
  T := R;
  Dec(T.Right);
  Dec(T.Bottom);
  C.DrawRoundedRectangle(Border, T, CornerRadius, 1);
  Fore := NimbusInputForeColor(P);
  if not HasValue then Fore := NimbusMutedForeColor(P);
  if ShowClear and HasValue then
  begin
    C.DrawLine(NimbusMutedForeColor(P), R.Right - 48, (R.Top + R.Bottom) div 2 - 5,
      R.Right - 38, (R.Top + R.Bottom) div 2 + 5, 1.3);
    C.DrawLine(NimbusMutedForeColor(P), R.Right - 48, (R.Top + R.Bottom) div 2 + 5,
      R.Right - 38, (R.Top + R.Bottom) div 2 - 5, 1.3);
  end;
  if Detailed then
    T := Rect(R.Left + 12, R.Top + 2, R.Right - 59, (R.Top + R.Bottom) div 2 + 1)
  else
    T := Rect(R.Left + 12, R.Top, R.Right - 59, R.Bottom);
  if ShowCalendarIcon then
    Dec(T.Right, 27);
  C.DrawText(S, F, Fore, T, [ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix]);
  if ShowCalendarIcon then
  begin
    C.DrawRoundedRectangle(NimbusMutedForeColor(P),
      Rect(R.Right - 84, (R.Top + R.Bottom) div 2 - 7,
        R.Right - 70, (R.Top + R.Bottom) div 2 + 7), 2, 1);
    C.DrawLine(NimbusMutedForeColor(P), R.Right - 83,
      (R.Top + R.Bottom) div 2 - 3, R.Right - 71,
      (R.Top + R.Bottom) div 2 - 3, 1);
    C.DrawLine(NimbusMutedForeColor(P), R.Right - 80,
      (R.Top + R.Bottom) div 2 - 9, R.Right - 80,
      (R.Top + R.Bottom) div 2 - 5, 1);
    C.DrawLine(NimbusMutedForeColor(P), R.Right - 74,
      (R.Top + R.Bottom) div 2 - 9, R.Right - 74,
      (R.Top + R.Bottom) div 2 - 5, 1);
  end;
  C.DrawLine(NimbusMutedForeColor(P), R.Right - 22, (R.Top + R.Bottom) div 2 - 3,
    R.Right - 16, (R.Top + R.Bottom) div 2 + 3, 1.5);
  C.DrawLine(NimbusMutedForeColor(P), R.Right - 16, (R.Top + R.Bottom) div 2 + 3,
    R.Right - 10, (R.Top + R.Bottom) div 2 - 3, 1.5);
end;

class procedure TThemedIdeDateRangeRenderer.Surface(const C: INimbusRenderCanvas;
  const P: TThemePalette; const R: TRect;
  const CornerRadius: Integer);
begin
  C.FillRoundedRectangle(NimbusPanelBackColor(P), R, CornerRadius);
  C.DrawRoundedRectangle(NimbusInputBorderColor(P),
    Rect(R.Left, R.Top, R.Right - 1, R.Bottom - 1), CornerRadius, 1);
end;

class procedure TThemedIdeDateRangeRenderer.Cell(const C: INimbusRenderCanvas;
  const F: TFont; const P: TThemePalette; const R: TRect; const S: string;
  const InRange, Endpoint, Today, Disabled, Hovered: Boolean;
  const DayBack, DayFore, DayBorder: TThemeColor;
  const UseDayBack, UseDayFore, UseDayBorder: Boolean);
var
  Fore: TThemeColor;
begin
  Fore := NimbusInputForeColor(P);
  if InRange then C.FillRectangle(NimbusBlendColor(NimbusPanelBackColor(P), NimbusAccentColor(P), 25), R);
  if Endpoint then
  begin
    C.FillRoundedRectangle(NimbusAccentColor(P), R, 5);
    Fore := NimbusInputBackColor(P);
  end
  else if Hovered and not Disabled then
    C.FillRoundedRectangle(NimbusBlendColor(NimbusPanelBackColor(P), NimbusAccentColor(P), 15), R, 5);
  if UseDayBack then C.FillRoundedRectangle(DayBack,
    Rect(R.Left + 1, R.Top + 1, R.Right - 1, R.Bottom - 1), 5);
  if UseDayBorder then C.DrawRoundedRectangle(DayBorder,
    Rect(R.Left + 1, R.Top + 1, R.Right - 1, R.Bottom - 1), 5, 1);
  if UseDayFore then Fore := DayFore;
  if Today and not Endpoint then C.DrawRoundedRectangle(NimbusAccentColor(P),
    Rect(R.Left + 1, R.Top + 1, R.Right - 1, R.Bottom - 1), 5, 1);
  if Disabled then Fore := NimbusDisabledForeColor(P);
  C.DrawText(S, F, Fore, R, [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix]);
end;

class procedure TThemedIdeDateRangeRenderer.Command(const C: INimbusRenderCanvas;
  const F: TFont; const P: TThemePalette; const R: TRect; const S: string;
  const Hovered, Primary: Boolean);
var
  Fore: TThemeColor;
begin
  Fore := NimbusInputForeColor(P);
  if Primary then
  begin
    C.FillRoundedRectangle(NimbusAccentColor(P), R, 5);
    Fore := NimbusInputBackColor(P);
  end
  else if Hovered then
    C.FillRoundedRectangle(NimbusBlendColor(NimbusPanelBackColor(P), NimbusAccentColor(P), 17), R, 5);
  C.DrawText(S, F, Fore, R, [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix]);
end;

end.

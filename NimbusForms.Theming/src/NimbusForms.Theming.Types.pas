{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Theming.Types;

interface

uses
  Winapi.Windows,
  Vcl.Graphics;

type
  TThemeColor = type Cardinal;

  TThemeScope = (tsSelf, tsChildren, tsSelfAndChildren);

function ThemeColor(const A, R, G, B: Byte): TThemeColor; inline;
function ThemeColorAlpha(const AColor: TThemeColor): Byte; inline;
function ThemeColorRed(const AColor: TThemeColor): Byte; inline;
function ThemeColorGreen(const AColor: TThemeColor): Byte; inline;
function ThemeColorBlue(const AColor: TThemeColor): Byte; inline;
function ThemeColorToColor(const AColor: TThemeColor): TColor; inline;
function ColorToThemeColor(const AColor: TColor; const AAlpha: Byte = 255): TThemeColor; inline;
function ThemeColorToColorRef(const AColor: TThemeColor): COLORREF; inline;

const
  SThemeColorOpaque = TThemeColor($FF000000);

implementation

function ThemeColor(const A, R, G, B: Byte): TThemeColor;
begin
  Result := TThemeColor((Cardinal(A) shl 24) or (Cardinal(R) shl 16) or
    (Cardinal(G) shl 8) or Cardinal(B));
end;

function ThemeColorAlpha(const AColor: TThemeColor): Byte;
begin
  Result := Byte((Cardinal(AColor) shr 24) and $FF);
end;

function ThemeColorRed(const AColor: TThemeColor): Byte;
begin
  Result := Byte((Cardinal(AColor) shr 16) and $FF);
end;

function ThemeColorGreen(const AColor: TThemeColor): Byte;
begin
  Result := Byte((Cardinal(AColor) shr 8) and $FF);
end;

function ThemeColorBlue(const AColor: TThemeColor): Byte;
begin
  Result := Byte(Cardinal(AColor) and $FF);
end;

function ThemeColorToColor(const AColor: TThemeColor): TColor;
begin
  Result := TColor(RGB(ThemeColorRed(AColor), ThemeColorGreen(AColor),
    ThemeColorBlue(AColor)));
end;

function ColorToThemeColor(const AColor: TColor; const AAlpha: Byte): TThemeColor;
var
  LRgb: COLORREF;
begin
  LRgb := ColorToRGB(AColor);
  Result := ThemeColor(AAlpha, GetRValue(LRgb), GetGValue(LRgb), GetBValue(LRgb));
end;

function ThemeColorToColorRef(const AColor: TThemeColor): COLORREF;
begin
  Result := RGB(ThemeColorRed(AColor), ThemeColorGreen(AColor),
    ThemeColorBlue(AColor));
end;

end.

{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.TagInput;



interface



uses

  System.Types, System.Math, Vcl.Graphics, System.Classes, NimbusForms.Theming.Types,

  NimbusForms.Theming.Palette, NimbusForms.Rendering.Canvas, NimbusForms.Rendering.Types;



type

  TThemedTagColorMode = (ttcmUniform, ttcmHarmonized, ttcmColorful);

  TThemedTagInputRenderer = class

  public

    class procedure Render(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const APalette: TThemePalette; const AFont: TFont; const ATags: TStrings; const ATagRects, ACloseRects: TArray<TRect>; const AHoverIndex: Integer; const AFocused, AHovered, AEnabled: Boolean; const AColorMode: TThemedTagColorMode; const AStroke: Single); static;

  end;



implementation



function TagColorForText(const AText: string; const APalette: TThemePalette; const AMode: TThemedTagColorMode): TThemeColor;

const

  Seed: array[0..9, 0..2] of Byte = ((225, 87, 100), (80, 160, 227), (76, 178, 133), (199, 133, 222), (227, 160, 78), (74, 181, 190), (206, 104, 154), (147, 164, 80), (119, 129, 222), (218, 133, 112));

var

  I, Index: Integer;

  Hash: Cardinal;

  Accent, Back: TThemeColor;

  R, G, B: Integer;

begin

  Hash := 2166136261;

  for I := 1 to Length(AText) do Hash := Cardinal((UInt64(Hash xor Cardinal(Ord(AText[I]))) * UInt64(16777619)) and UInt64($FFFFFFFF));

  Index := Integer(Hash mod 10);

  Accent := NimbusForms.Rendering.Types.NimbusAccentColor(APalette);

  Back := NimbusForms.Rendering.Types.NimbusInputBackColor(APalette);

  if AMode = ttcmHarmonized then
  begin
    R := (Seed[Index, 0] * 20 + ThemeColorRed(Accent) * 75 + ThemeColorRed(Back) * 5) div 100;
    G := (Seed[Index, 1] * 20 + ThemeColorGreen(Accent) * 75 + ThemeColorGreen(Back) * 5) div 100;
    B := (Seed[Index, 2] * 20 + ThemeColorBlue(Accent) * 75 + ThemeColorBlue(Back) * 5) div 100;
  end
  else
  begin
    R := (Seed[Index, 0] * 60 + ThemeColorRed(Accent) * 35 + ThemeColorRed(Back) * 5) div 100;
    G := (Seed[Index, 1] * 60 + ThemeColorGreen(Accent) * 35 + ThemeColorGreen(Back) * 5) div 100;
    B := (Seed[Index, 2] * 60 + ThemeColorBlue(Accent) * 35 + ThemeColorBlue(Back) * 5) div 100;
  end;

  Result := ThemeColor(255, Byte(R), Byte(G), Byte(B));

end;



function TagChannelLuminance(const AValue: Byte): Double;
var
  LValue: Double;
begin
  LValue := AValue / 255;
  if LValue <= 0.04045 then Result := LValue / 12.92
  else Result := Power((LValue + 0.055) / 1.055, 2.4);
end;

function TagLuminance(const AColor: TThemeColor): Double;
begin
  Result := 0.2126 * TagChannelLuminance(ThemeColorRed(AColor)) + 0.7152 * TagChannelLuminance(ThemeColorGreen(AColor)) + 0.0722 * TagChannelLuminance(ThemeColorBlue(AColor));
end;

function TagReadableFore(const ABack: TThemeColor): TThemeColor;
var
  Luminance, DarkContrast, LightContrast: Double;
begin
  Luminance := TagLuminance(ABack);
  DarkContrast := (Luminance + 0.05) / 0.05;
  LightContrast := 1.05 / (Luminance + 0.05);
  if DarkContrast >= LightContrast then Result := ThemeColor(255, 0, 0, 0)
  else Result := ThemeColor(255, 255, 255, 255);
end;

function TagCloseHoverBack(const ABack, AFore: TThemeColor): TThemeColor;
begin
  Result := ThemeColor(255, Byte((ThemeColorRed(ABack) * 78 + ThemeColorRed(AFore) * 22) div 100), Byte((ThemeColorGreen(ABack) * 78 + ThemeColorGreen(AFore) * 22) div 100), Byte((ThemeColorBlue(ABack) * 78 + ThemeColorBlue(AFore) * 22) div 100));
end;

class procedure TThemedTagInputRenderer.Render(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const APalette: TThemePalette; const AFont: TFont; const ATags: TStrings; const ATagRects, ACloseRects: TArray<TRect>; const AHoverIndex: Integer; const AFocused, AHovered, AEnabled: Boolean; const AColorMode: TThemedTagColorMode; const AStroke: Single);

var

  I, CX, CY, D: Integer;

  Back, Border, TagBack, TagFore: TThemeColor;

  R, T: TRect;

  ItemBack, ItemFore: TThemeColor;

begin

  Back := NimbusForms.Rendering.Types.NimbusInputBackColor(APalette);

  Border := NimbusForms.Rendering.Types.NimbusInputBorderColor(APalette);

  TagBack := NimbusForms.Rendering.Types.NimbusAccentColor(APalette);

  TagFore := NimbusForms.Rendering.Types.NimbusSelectedForeColor(APalette);

  if not AEnabled then

  begin

    Back := NimbusForms.Rendering.Types.NimbusDisabledBackColor(APalette);

    TagBack := NimbusForms.Rendering.Types.NimbusControlBorderColor(APalette);

    TagFore := NimbusForms.Rendering.Types.NimbusDisabledForeColor(APalette);

  end

  else if AFocused then Border := NimbusForms.Rendering.Types.NimbusFocusBorderColor(APalette)

  else if AHovered then Border := NimbusForms.Rendering.Types.NimbusControlBorderColor(APalette);

  if AEnabled and (AColorMode = ttcmUniform) then TagFore := TagReadableFore(TagBack);

  ACanvas.FillRectangle(Back, ABounds);

  ACanvas.DrawRectangle(Border, Rect(ABounds.Left, ABounds.Top, ABounds.Right - 1, ABounds.Bottom - 1));

  for I := 0 to ATags.Count - 1 do

  begin

    if I >= Length(ATagRects) then Break;

    R := ATagRects[I];

    T := ACloseRects[I];

    ItemBack := TagBack;

    ItemFore := TagFore;

    if (AColorMode <> ttcmUniform) and AEnabled then

    begin

      ItemBack := TagColorForText(ATags[I], APalette, AColorMode);

      ItemFore := TagReadableFore(ItemBack);

    end;

    ACanvas.FillRoundedRectangle(ItemBack, R, (R.Bottom - R.Top) div 2);

    ACanvas.DrawText(ATags[I], AFont, ItemFore, Rect(R.Left + (R.Bottom - R.Top) div 3, R.Top, T.Left - 2, R.Bottom), [NimbusForms.Rendering.Types.ntfVCenter, NimbusForms.Rendering.Types.ntfSingleLine, NimbusForms.Rendering.Types.ntfEndEllipsis, NimbusForms.Rendering.Types.ntfNoPrefix]);

    if I = AHoverIndex then ACanvas.FillEllipse(TagCloseHoverBack(ItemBack, ItemFore), T);

    CX := (T.Left + T.Right) div 2;

    CY := (T.Top + T.Bottom) div 2;

    D := (T.Right - T.Left) div 4;

    if D < 2 then D := 2;

    ACanvas.DrawLine(ItemFore, CX - D, CY - D, CX + D, CY + D, AStroke);

    ACanvas.DrawLine(ItemFore, CX - D, CY + D, CX + D, CY - D, AStroke);

  end;

end;



end.


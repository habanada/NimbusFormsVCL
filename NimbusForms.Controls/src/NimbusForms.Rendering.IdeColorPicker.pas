{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.IdeColorPicker;

interface

uses
  System.Types, System.UITypes, Vcl.Graphics,
  NimbusForms.Theming.Types, NimbusForms.Theming.Palette, NimbusForms.Rendering.Canvas;

function IdeHSVColor(AHue, ASaturation, ABrightness: Single): TColor;

type
  TIdeColorPickerRenderer = class
  public
    class procedure Surface(const C: INimbusRenderCanvas; const R: TRect; const P: TThemePalette); static;
    class procedure Tab(const C: INimbusRenderCanvas; const R: TRect; const P: TThemePalette;
      const F: TFont; const S: string; Selected, Hover: Boolean); static;
    class procedure Cell(const C: INimbusRenderCanvas; const R: TRect; const P: TThemePalette;
      AColor: TColor; Selected, Hover: Boolean); static;
    class procedure Button(const C: INimbusRenderCanvas; const R: TRect; const P: TThemePalette;
      const F: TFont; const S: string; Hover: Boolean; Pressed: Boolean); static;
    class procedure Gradient(const C: INimbusRenderCanvas;
      const AGradient, AHueBar, ABrightnessBar, AAlphaBar: TRect;
      const P: TThemePalette; const F: TFont; AHue, ASaturation, ABrightness: Single;
      AColor: TColor; ASelectedAlpha: Byte; AShowAlpha: Boolean; AMarkerRadius: Integer); static;
    class procedure Slider(const C: INimbusRenderCanvas; const R: TRect; const P: TThemePalette;
      const F: TFont; const Caption: string; Value: Integer; AColor: TColor); static;
  end;

implementation

uses
  System.Math, System.SysUtils, Winapi.Windows, NimbusForms.Rendering.Types;

function IdeHSVColor(AHue, ASaturation, ABrightness: Single): TColor;
var H,S,V,P,Q,T,F,R,G,B: Single; I: Integer;
begin
  H := AHue/60;
  S := EnsureRange(ASaturation,0,1);
  V := EnsureRange(ABrightness,0,1);
  I := Floor(H) mod 6;
  F := H-Floor(H);
  P := V*(1-S);
  Q := V*(1-S*F);
  T := V*(1-S*(1-F));
  case I of
    0: begin R:=V; G:=T; B:=P; end;
    1: begin R:=Q; G:=V; B:=P; end;
    2: begin R:=P; G:=V; B:=T; end;
    3: begin R:=P; G:=Q; B:=V; end;
    4: begin R:=T; G:=P; B:=V; end;
  else begin R:=V; G:=P; B:=Q; end;
  end;
  Result := RGB(Round(R*255),Round(G*255),Round(B*255));
end;

class procedure TIdeColorPickerRenderer.Gradient(const C: INimbusRenderCanvas;
  const AGradient, AHueBar, ABrightnessBar, AAlphaBar: TRect;
  const P: TThemePalette; const F: TFont; AHue, ASaturation, ABrightness: Single;
  AColor: TColor; ASelectedAlpha: Byte; AShowAlpha: Boolean; AMarkerRadius: Integer);
var I,J: Integer; K: TColor; Value: Single; CR: COLORREF;
  procedure DrawBar(const B: TRect; AKind: Integer);
  var U: Integer; D: TColor; V: Single;
  begin
    for U := 0 to 47 do
    begin
      V := U/47;
      case AKind of
        0: D := IdeHSVColor(V*359,1,1);
        1: D := IdeHSVColor(AHue,ASaturation,V);
      else
        D := RGB(Round(255+(GetRValue(CR)-255)*V),
          Round(255+(GetGValue(CR)-255)*V),
          Round(255+(GetBValue(CR)-255)*V));
      end;
      C.FillRectangle(ColorToThemeColor(D),
        Rect(B.Left+MulDiv(B.Width,U,48),B.Top,
          B.Left+MulDiv(B.Width,U+1,48),B.Bottom));
    end;
    C.DrawRectangle(NimbusControlBorderColor(P),B);
  end;
begin
  CR := ColorToRGB(AColor);
  for J := 0 to 15 do
    for I := 0 to 31 do
    begin
      K := IdeHSVColor(AHue,I/31,1-J/15);
      C.FillRectangle(ColorToThemeColor(K),
        Rect(AGradient.Left+MulDiv(AGradient.Width,I,32),
          AGradient.Top+MulDiv(AGradient.Height,J,16),
          AGradient.Left+MulDiv(AGradient.Width,I+1,32),
          AGradient.Top+MulDiv(AGradient.Height,J+1,16)));
    end;
  C.DrawRectangle(NimbusControlBorderColor(P),AGradient);
  C.DrawEllipse(NimbusSelectedForeColor(P),
    Rect(AGradient.Left+Round(ASaturation*AGradient.Width)-AMarkerRadius,
      AGradient.Top+Round((1-ABrightness)*AGradient.Height)-AMarkerRadius,
      AGradient.Left+Round(ASaturation*AGradient.Width)+AMarkerRadius,
      AGradient.Top+Round((1-ABrightness)*AGradient.Height)+AMarkerRadius),2);
  C.DrawText('Hue',F,NimbusMutedForeColor(P),
    Rect(AHueBar.Left-42,AHueBar.Top-4,AHueBar.Left-3,AHueBar.Bottom+4),
    [ntfVCenter,ntfSingleLine]);
  C.DrawText('Value',F,NimbusMutedForeColor(P),
    Rect(ABrightnessBar.Left-42,ABrightnessBar.Top-4,ABrightnessBar.Left-3,ABrightnessBar.Bottom+4),
    [ntfVCenter,ntfSingleLine]);
  DrawBar(AHueBar,0);
  C.DrawLine(NimbusSelectedForeColor(P),
    AHueBar.Left+Round(AHue/360*AHueBar.Width),AHueBar.Top-2,
    AHueBar.Left+Round(AHue/360*AHueBar.Width),AHueBar.Bottom+2,2);
  DrawBar(ABrightnessBar,1);
  C.DrawLine(NimbusSelectedForeColor(P),
    ABrightnessBar.Left+Round(ABrightness*ABrightnessBar.Width),ABrightnessBar.Top-2,
    ABrightnessBar.Left+Round(ABrightness*ABrightnessBar.Width),ABrightnessBar.Bottom+2,2);
  if AShowAlpha then
  begin
    C.DrawText('Alpha',F,NimbusMutedForeColor(P),
      Rect(AAlphaBar.Left-42,AAlphaBar.Top-4,AAlphaBar.Left-3,AAlphaBar.Bottom+4),
      [ntfVCenter,ntfSingleLine]);
    DrawBar(AAlphaBar,2);
    C.DrawLine(NimbusSelectedForeColor(P),
      AAlphaBar.Left+MulDiv(AAlphaBar.Width,ASelectedAlpha,255),AAlphaBar.Top-2,
      AAlphaBar.Left+MulDiv(AAlphaBar.Width,ASelectedAlpha,255),AAlphaBar.Bottom+2,2);
  end;
end;

class procedure TIdeColorPickerRenderer.Surface(const C: INimbusRenderCanvas; const R: TRect; const P: TThemePalette);
begin
  C.FillRectangle(NimbusPanelBackColor(P), R);
  C.DrawRoundedRectangle(NimbusControlBorderColor(P), R, 7);
end;

class procedure TIdeColorPickerRenderer.Tab(const C: INimbusRenderCanvas; const R: TRect; const P: TThemePalette;
  const F: TFont; const S: string; Selected, Hover: Boolean);
begin
  if Selected then C.FillRoundedRectangle(NimbusInputBackColor(P), R, 5)
  else if Hover then C.FillRoundedRectangle(NimbusHoverBackColor(P), R, 5);
  if Selected then C.DrawRoundedRectangle(NimbusAccentColor(P), R, 5);
  C.DrawText(S, F, NimbusControlForeColor(P), R, [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix]);
end;

class procedure TIdeColorPickerRenderer.Cell(const C: INimbusRenderCanvas; const R: TRect; const P: TThemePalette;
  AColor: TColor; Selected, Hover: Boolean);
var X,Y: Integer; T: TThemeColor;
begin
  T := ColorToThemeColor(AColor);
  C.FillRoundedRectangle(T, Rect(R.Left+2,R.Top+2,R.Right-2,R.Bottom-2), 3);
  if Selected then C.DrawRoundedRectangle(NimbusAccentColor(P), R, 5, 2)
  else if Hover then C.DrawRoundedRectangle(NimbusControlForeColor(P), R, 5);
end;

class procedure TIdeColorPickerRenderer.Button(const C: INimbusRenderCanvas; const R: TRect; const P: TThemePalette;
  const F: TFont; const S: string; Hover: Boolean; Pressed: Boolean);
var TextR: TRect;
begin
  if Pressed then C.FillRoundedRectangle(NimbusBlendColor(NimbusInputBackColor(P),NimbusAccentColor(P),25), R, 4)
  else if Hover then C.FillRoundedRectangle(NimbusHoverBackColor(P), R, 4)
  else C.FillRoundedRectangle(NimbusInputBackColor(P), R, 4);
  if Pressed then C.DrawRoundedRectangle(NimbusAccentColor(P), R, 4)
  else C.DrawRoundedRectangle(NimbusControlBorderColor(P), R, 4);
  TextR := R;
  if Pressed then OffsetRect(TextR, 0, 1);
  C.DrawText(S, F, NimbusControlForeColor(P), TextR, [ntfCenter,ntfVCenter,ntfSingleLine,ntfNoPrefix]);
end;

class procedure TIdeColorPickerRenderer.Slider(const C: INimbusRenderCanvas; const R: TRect; const P: TThemePalette;
  const F: TFont; const Caption: string; Value: Integer; AColor: TColor);
var B, FillR: TRect; V: Integer;
begin
  V := EnsureRange(Value,0,255);
  C.DrawText(Caption, F, NimbusControlForeColor(P), Rect(R.Left,R.Top,R.Left+42,R.Bottom),
    [ntfVCenter,ntfSingleLine,ntfNoPrefix]);
  B := Rect(R.Left+46,R.Top+6,R.Right-33,R.Bottom-6);
  C.FillRoundedRectangle(NimbusInputBackColor(P),B,3);
  FillR := B; FillR.Right := B.Left + MulDiv(B.Width,V,255);
  if FillR.Width > 0 then C.FillRoundedRectangle(ColorToThemeColor(AColor),FillR,3);
  C.DrawRectangle(NimbusControlBorderColor(P),B);
  if (B.Right > B.Left) and (B.Bottom > B.Top) then
  begin
    FillR := Rect(B.Left + MulDiv(B.Width-1,V,255)-2,B.Top-3,
      B.Left + MulDiv(B.Width-1,V,255)+3,B.Bottom+3);
    C.FillRoundedRectangle(NimbusSelectedForeColor(P),FillR,2);
    C.DrawRoundedRectangle(NimbusControlBorderColor(P),FillR,2);
  end;
  C.DrawText(IntToStr(V),F,NimbusControlForeColor(P),Rect(R.Right-31,R.Top,R.Right,R.Bottom),
    [ntfCenter,ntfVCenter,ntfSingleLine]);
end;

end.

{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.IdeStatusBar;

interface

uses
  System.Types, Vcl.Graphics, Vcl.ImgList,
  NimbusForms.Controls.IdeStatusBar, NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Canvas;

type
  TThemedIdeStatusBarRenderer = class
  public
    class procedure Background(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const APalette: TThemePalette; const ATopBorder: Boolean); static;
    class procedure Item(const ACanvas: INimbusRenderCanvas; const AItem: TThemedIdeStatusBarItem; const AFont: TFont; const APalette: TThemePalette; const AEnabled, AHot, APressed, AFocused: Boolean; const APPI: Integer; const AImages: TCustomImageList; const AIconBuffer: Vcl.Graphics.TBitmap; const AImageSize, AImageTextSpacing, AArrowSize: Integer); static;
  end;

implementation

uses
  Winapi.Windows, System.Math, System.UITypes,
  NimbusForms.Theming.Types, NimbusForms.Rendering.Types;

class procedure TThemedIdeStatusBarRenderer.Background(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const APalette: TThemePalette; const ATopBorder: Boolean);
var LBack: TThemeColor;
begin
  if APalette <> nil then LBack := APalette.StatusBackColor else LBack := NimbusPanelBackColor(nil);
  ACanvas.FillRectangle(LBack,ABounds);
  if ATopBorder then ACanvas.DrawLine(NimbusSeparatorColor(APalette),ABounds.Left,ABounds.Top,ABounds.Right-1,ABounds.Top,1);
end;

class procedure TThemedIdeStatusBarRenderer.Item(const ACanvas: INimbusRenderCanvas; const AItem: TThemedIdeStatusBarItem; const AFont: TFont; const APalette: TThemePalette; const AEnabled, AHot, APressed, AFocused: Boolean; const APPI: Integer; const AImages: TCustomImageList; const AIconBuffer: Vcl.Graphics.TBitmap; const AImageSize, AImageTextSpacing, AArrowSize: Integer);
var
  R, T, P: TRect;
  C, B: TThemeColor;
  I, S, V, X: Integer;
  HasImage, HasText: Boolean;
  Bitmap: Vcl.Graphics.TBitmap;
begin
  R := AItem.Bounds;
  if IsRectEmpty(R) then Exit;
  S := NimbusScaleValue(13,APPI);
  if AEnabled and AItem.Enabled then C := NimbusControlForeColor(APalette) else C := NimbusDisabledForeColor(APalette);
  if (AItem.Kind in [sikButton,sikToggleButton,sikCheckBox,sikDropDown,sikCustom]) then
  begin
    B := ThemeColor(0,0,0,0);
    if APressed then B := NimbusPressedBackColor(APalette)
    else if AItem.Checked then B := NimbusMenuSelectedBackColor(APalette)
    else if AHot or AFocused then B := NimbusHoverBackColor(APalette);
    if ThemeColorAlpha(B) <> 0 then ACanvas.FillRoundedRectangle(B,R,NimbusScaleValue(3,APPI));
  end;
  if AItem.Kind = sikSeparator then
  begin
    I := (R.Left+R.Right) div 2;
    ACanvas.DrawLine(NimbusSeparatorColor(APalette),I,R.Top+NimbusScaleValue(4,APPI),I,R.Bottom-NimbusScaleValue(4,APPI));
    Exit;
  end;
  if AItem.Kind = sikSpring then Exit;
  if AItem.Kind = sikProgress then
  begin
    P := Rect(R.Left+NimbusScaleValue(4,APPI),R.Top+NimbusScaleValue(6,APPI),R.Right-NimbusScaleValue(4,APPI),R.Bottom-NimbusScaleValue(6,APPI));
    ACanvas.FillRoundedRectangle(NimbusProgressBackColor(APalette),P,NimbusScaleValue(2,APPI));
    if AItem.ProgressMaximum > AItem.ProgressMinimum then
    begin
      V := MulDiv(P.Width,AItem.ProgressValue-AItem.ProgressMinimum,AItem.ProgressMaximum-AItem.ProgressMinimum);
      P.Right := P.Left + EnsureRange(V,0,P.Width);
      if P.Right > P.Left then ACanvas.FillRoundedRectangle(NimbusProgressFillColor(APalette),P,NimbusScaleValue(2,APPI));
    end;
    Exit;
  end;
  X := R.Left+NimbusScaleValue(5,APPI);
  if AItem.Kind = sikCheckBox then
  begin
    T := Rect(X,R.Top+(R.Height-S) div 2,X+S,R.Top+(R.Height+S) div 2);
    ACanvas.DrawRoundedRectangle(C,T,NimbusScaleValue(2,APPI));
    if AItem.Checked then
    begin
      ACanvas.DrawLine(C,T.Left+2,T.Top+S div 2,T.Left+S div 2,T.Bottom-3,1.5);
      ACanvas.DrawLine(C,T.Left+S div 2,T.Bottom-3,T.Right-2,T.Top+2,1.5);
    end;
    Inc(X,S+NimbusScaleValue(3,APPI));
  end;
  HasImage := (AImages <> nil) and (AItem.ImageIndex >= 0) and (AItem.ImageIndex < AImages.Count) and (AItem.DisplayStyle <> sdsText);
  HasText := (AItem.Text <> '') and (AItem.DisplayStyle <> sdsImage);
  if HasImage then
  begin
    Bitmap := AIconBuffer;
    if Bitmap <> nil then
    begin
      AImages.GetBitmap(AItem.ImageIndex,Bitmap);
      ACanvas.DrawBitmap(Bitmap,Rect(X,R.Top+(R.Height-NimbusScaleValue(AImageSize,APPI)) div 2,X+NimbusScaleValue(AImageSize,APPI),R.Top+(R.Height+NimbusScaleValue(AImageSize,APPI)) div 2));
    end;
    Inc(X,NimbusScaleValue(AImageSize+AImageTextSpacing,APPI));
  end;
  if HasText then
  begin
    T := Rect(X,R.Top,R.Right-NimbusScaleValue(5,APPI),R.Bottom);
    if AItem.Kind = sikDropDown then Dec(T.Right,NimbusScaleValue(AArrowSize+6,APPI));
    ACanvas.DrawText(AItem.Text,AFont,C,T,[ntfVCenter,ntfSingleLine,ntfEndEllipsis,ntfNoPrefix]);
  end;
  if AItem.Kind = sikDropDown then
  begin
    I := R.Right-NimbusScaleValue(AArrowSize+3,APPI);
    V := (R.Top+R.Bottom) div 2;
    ACanvas.FillTriangle(C,Point(I-NimbusScaleValue(AArrowSize,APPI) div 2,V-1),Point(I+NimbusScaleValue(AArrowSize,APPI) div 2,V-1),Point(I,V+NimbusScaleValue(AArrowSize,APPI) div 2));
  end;
end;

end.

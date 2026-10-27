{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.PropertyGrid;

interface

uses
  System.Types,
  Vcl.Graphics,
  NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Canvas;

type
  TThemedPropertyGridRowLayout = record
    Bounds: TRect;
    ExpanderRect: TRect;
    NameRect: TRect;
    ValueRect: TRect;
  end;

  TThemedPropertyGridRowVisual = record
    Layout: TThemedPropertyGridRowLayout;
    Name: string;
    Value: string;
    Indent: Integer;
    Category: Boolean;
    Expandable: Boolean;
    Expanded: Boolean;
    Selected: Boolean;
    Hovered: Boolean;
    Focused: Boolean;
    ReadOnly: Boolean;
    EditorButton: Boolean;
    Dirty: Boolean;
    Favorite: Boolean;
    MultipleValues: Boolean;
    Expression: Boolean;
    VirtualProperty: Boolean;
    Graphic: TGraphic;
    Invalid: Boolean;
  end;

  TThemedPropertyGridRenderer = class sealed
  public
    class function RowLayout(const ABounds: TRect; const ANameWidth, AIndent: Integer; const ACategory: Boolean): TThemedPropertyGridRowLayout; static;
    class procedure DrawSurface(const ACanvas: INimbusRenderCanvas; const APalette: TThemePalette; const ABounds, AToolbarRect, ASearchRect, ADescriptionRect: TRect; const AToolbarVisible, ASearchVisible, ADescriptionVisible, ASearchFocused: Boolean); static;
    class procedure DrawRow(const ACanvas: INimbusRenderCanvas; const APalette: TThemePalette; const AFont, AHeaderFont: TFont; const ARow: TThemedPropertyGridRowVisual); static;
    class procedure DrawImagePreview(const ACanvas: INimbusRenderCanvas; const APalette: TThemePalette; const ABounds: TRect; AGraphic: TGraphic); static;
    class procedure DrawDescription(const ACanvas: INimbusRenderCanvas; const APalette: TThemePalette; const AFont, AHeaderFont: TFont; const ABounds: TRect; const ATitle, AText: string); static;
  end;

implementation

uses
  Winapi.Windows,
  System.Math,
  NimbusForms.Theming.Types,
  NimbusForms.Rendering.Types;

class function TThemedPropertyGridRenderer.RowLayout(const ABounds: TRect; const ANameWidth, AIndent: Integer; const ACategory: Boolean): TThemedPropertyGridRowLayout;
var
  LDivider: Integer;
begin
  Result := Default(TThemedPropertyGridRowLayout);
  Result.Bounds := ABounds;
  Result.ExpanderRect := Rect(ABounds.Left + 7 + AIndent * 14, ABounds.Top + (ABounds.Height - 12) div 2, ABounds.Left + 19 + AIndent * 14, ABounds.Top + (ABounds.Height + 12) div 2);
  LDivider := Min(ABounds.Right - 32, Max(ABounds.Left + 72, ANameWidth));
  if ACategory then
  begin
    Result.NameRect := Rect(ABounds.Left + 25, ABounds.Top, ABounds.Right - 8, ABounds.Bottom);
    Result.ValueRect := Rect(0, 0, 0, 0);
  end
  else
  begin
    Result.NameRect := Rect(ABounds.Left + 25 + AIndent * 14, ABounds.Top + 1, LDivider - 6, ABounds.Bottom - 1);
    Result.ValueRect := Rect(LDivider + 7, ABounds.Top + 1, ABounds.Right - 7, ABounds.Bottom - 1);
  end;
end;

class procedure TThemedPropertyGridRenderer.DrawSurface(const ACanvas: INimbusRenderCanvas; const APalette: TThemePalette; const ABounds, AToolbarRect, ASearchRect, ADescriptionRect: TRect; const AToolbarVisible, ASearchVisible, ADescriptionVisible, ASearchFocused: Boolean);
var
  LBack, LBorder, LHeader: TThemeColor;
begin
  LBack := NimbusControlBackColor(APalette);
  LBorder := NimbusControlBorderColor(APalette);
  LHeader := NimbusInputBackColor(APalette);
  ACanvas.FillRectangle(LBack, ABounds);
  if AToolbarVisible then
  begin
    ACanvas.FillRectangle(NimbusPanelBackColor(APalette), AToolbarRect);
    ACanvas.DrawLine(LBorder, AToolbarRect.Left, AToolbarRect.Bottom - 1, AToolbarRect.Right, AToolbarRect.Bottom - 1);
  end;
  if ASearchVisible then
  begin
    if ASearchRect.Top >= AToolbarRect.Bottom then
    begin
      ACanvas.FillRectangle(LHeader, Rect(ABounds.Left, AToolbarRect.Bottom, ABounds.Right, ASearchRect.Bottom + 3));
      ACanvas.DrawLine(LBorder, ABounds.Left, ASearchRect.Bottom + 2, ABounds.Right, ASearchRect.Bottom + 2);
    end;
    ACanvas.FillRoundedRectangle(NimbusInputBackColor(APalette), ASearchRect, 2);
    if ASearchFocused then ACanvas.DrawRoundedRectangle(NimbusFocusBorderColor(APalette), ASearchRect, 2)
    else ACanvas.DrawRoundedRectangle(NimbusInputBorderColor(APalette), ASearchRect, 2);
    ACanvas.DrawEllipse(NimbusMutedForeColor(APalette), Rect(ASearchRect.Left + 6, ASearchRect.Top + 6, ASearchRect.Left + 12, ASearchRect.Top + 12));
    ACanvas.DrawLine(NimbusMutedForeColor(APalette), ASearchRect.Left + 11, ASearchRect.Top + 11, ASearchRect.Left + 14, ASearchRect.Top + 14);
  end;
  if ADescriptionVisible then
  begin
    ACanvas.FillRectangle(LHeader, ADescriptionRect);
    ACanvas.DrawLine(LBorder, ADescriptionRect.Left, ADescriptionRect.Top, ADescriptionRect.Right, ADescriptionRect.Top);
  end;
  ACanvas.DrawRectangle(LBorder, ABounds);
end;

class procedure TThemedPropertyGridRenderer.DrawRow(const ACanvas: INimbusRenderCanvas; const APalette: TThemePalette; const AFont, AHeaderFont: TFont; const ARow: TThemedPropertyGridRowVisual);
var
  LBack, LFore, LBorder, LAccent, LMuted, LMark: TThemeColor;
  R, G: TRect;
  LName: string;
  LValueRect, LPreviewRect: TRect;
  I, LX, LSize: Integer;
begin
  R := ARow.Layout.Bounds;
  LBack := NimbusControlBackColor(APalette);
  LFore := NimbusControlForeColor(APalette);
  LBorder := NimbusControlBorderColor(APalette);
  LAccent := NimbusAccentColor(APalette);
  LMuted := NimbusMutedForeColor(APalette);
  if ARow.Category then
  begin
    LBack := NimbusInputBackColor(APalette);
    if ARow.Selected then LBack := NimbusBlendColor(LBack, LAccent, 32)
    else if ARow.Hovered then LBack := NimbusHoverBackColor(APalette);
    ACanvas.FillRectangle(LBack, R);
    ACanvas.DrawLine(LBorder, R.Left, R.Bottom - 1, R.Right, R.Bottom - 1);
    if ARow.Selected then
    begin
      ACanvas.FillRectangle(LAccent, Rect(R.Left, R.Top + 1, R.Left + 2, R.Bottom - 1));
      if ARow.Focused then
      begin
        ACanvas.DrawLine(LAccent, R.Left + 2, R.Top, R.Right - 1, R.Top);
        ACanvas.DrawLine(LAccent, R.Left + 2, R.Bottom - 1, R.Right - 1, R.Bottom - 1);
      end;
    end;
    G := ARow.Layout.ExpanderRect;
    if ARow.Expanded then
    begin
      ACanvas.DrawLine(LFore, G.Left + 2, G.Top + 4, (G.Left + G.Right) div 2, G.Bottom - 3);
      ACanvas.DrawLine(LFore, (G.Left + G.Right) div 2, G.Bottom - 3, G.Right - 2, G.Top + 4);
    end
    else
    begin
      ACanvas.DrawLine(LFore, G.Left + 4, G.Top + 2, G.Right - 3, (G.Top + G.Bottom) div 2);
      ACanvas.DrawLine(LFore, G.Right - 3, (G.Top + G.Bottom) div 2, G.Left + 4, G.Bottom - 2);
    end;
    ACanvas.DrawText(ARow.Name, AHeaderFont, LFore, ARow.Layout.NameRect, [ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix]);
    Exit;
  end;
  if ARow.Selected then LBack := NimbusBlendColor(LBack, LAccent, 32)
  else if ARow.Hovered then LBack := NimbusHoverBackColor(APalette);
  ACanvas.FillRectangle(LBack, R);
  ACanvas.DrawLine(NimbusBlendColor(LBorder, LBack, 110), R.Left, R.Bottom - 1, R.Right, R.Bottom - 1);
  ACanvas.DrawLine(NimbusBlendColor(LBorder, LBack, 70), ARow.Layout.ValueRect.Left - 8, R.Top, ARow.Layout.ValueRect.Left - 8, R.Bottom);
  if ARow.Selected then
  begin
    ACanvas.FillRectangle(LAccent, Rect(R.Left, R.Top + 1, R.Left + 2, R.Bottom - 1));
    if ARow.Focused then
    begin
      ACanvas.DrawLine(LAccent, R.Left + 2, R.Top, R.Right - 1, R.Top);
      ACanvas.DrawLine(LAccent, R.Left + 2, R.Bottom - 1, R.Right - 1, R.Bottom - 1);
    end;
  end;
  if ARow.Dirty then ACanvas.FillRectangle(LAccent, Rect(R.Left + 3, R.Top + 3, R.Left + 6, R.Bottom - 3));
  if ARow.Expression then ACanvas.FillRectangle(ThemeColor(255, 95, 158, 236), Rect(R.Left + 6, R.Top + 3, R.Left + 9, R.Bottom - 3));
  if ARow.VirtualProperty then ACanvas.FillRectangle(ThemeColor(255, 170, 125, 210), Rect(R.Left + 9, R.Top + 3, R.Left + 12, R.Bottom - 3));
  if ARow.Invalid then ACanvas.FillRectangle(ThemeColor(255, 208, 64, 64), Rect(R.Right - 4, R.Top + 3, R.Right - 2, R.Bottom - 3));
  if ARow.Indent > 0 then
  begin
    for I := 0 to Min(ARow.Indent - 1, 8) do
    begin
      LX := R.Left + 12 + I * 14;
      ACanvas.DrawLine(NimbusBlendColor(LBorder, LBack, 85), LX, R.Top, LX, R.Bottom);
    end;
    LX := R.Left + 12 + (ARow.Indent - 1) * 14;
    ACanvas.DrawLine(NimbusBlendColor(LBorder, LBack, 60), LX, (R.Top + R.Bottom) div 2, LX + 8, (R.Top + R.Bottom) div 2);
  end;
  if ARow.Expandable then
  begin
    G := ARow.Layout.ExpanderRect;
    if ARow.Expanded then
    begin
      ACanvas.DrawLine(LMuted, G.Left + 2, G.Top + 4, (G.Left + G.Right) div 2, G.Bottom - 3);
      ACanvas.DrawLine(LMuted, (G.Left + G.Right) div 2, G.Bottom - 3, G.Right - 2, G.Top + 4);
    end
    else
    begin
      ACanvas.DrawLine(LMuted, G.Left + 4, G.Top + 2, G.Right - 3, (G.Top + G.Bottom) div 2);
      ACanvas.DrawLine(LMuted, G.Right - 3, (G.Top + G.Bottom) div 2, G.Left + 4, G.Bottom - 2);
    end;
  end;
  if ARow.ReadOnly then LFore := LMuted;
  LName := ARow.Name;
  if ARow.Favorite then LName := '★ ' + LName;
  ACanvas.DrawText(LName, AFont, LFore, ARow.Layout.NameRect, [ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix]);
  if ARow.MultipleValues then LMark := LMuted else LMark := LFore;
  LValueRect := ARow.Layout.ValueRect;
  if ARow.Graphic <> nil then
  begin
    LSize := Min(LValueRect.Height - 4, 40);
    LPreviewRect := Rect(LValueRect.Left + 2, LValueRect.Top + 2, LValueRect.Left + 2 + LSize, LValueRect.Top + 2 + LSize);
    DrawImagePreview(ACanvas, APalette, LPreviewRect, ARow.Graphic);
    LValueRect.Left := LPreviewRect.Right + 6;
  end;
  if ARow.EditorButton and (LValueRect.Width > 22) then
  begin
    G := Rect(LValueRect.Right - 15, R.Top + 3, LValueRect.Right + 5, R.Bottom - 3);
    ACanvas.FillRectangle(NimbusInputBackColor(APalette), G);
    ACanvas.DrawLine(LBorder, G.Left, G.Top, G.Left, G.Bottom);
    ACanvas.DrawLine(LFore, G.Left + 6, (G.Top + G.Bottom) div 2 - 2, G.Left + 10, (G.Top + G.Bottom) div 2 + 2);
    ACanvas.DrawLine(LFore, G.Left + 10, (G.Top + G.Bottom) div 2 + 2, G.Left + 14, (G.Top + G.Bottom) div 2 - 2);
    LValueRect.Right := G.Left - 4;
  end;
  if LValueRect.Right > LValueRect.Left then ACanvas.DrawText(ARow.Value, AFont, LMark, LValueRect, [ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix]);
end;

class procedure TThemedPropertyGridRenderer.DrawImagePreview(const ACanvas: INimbusRenderCanvas; const APalette: TThemePalette; const ABounds: TRect; AGraphic: TGraphic);
var
  LBitmap: Vcl.Graphics.TBitmap;
  LRect: TRect;
  LWidth, LHeight: Integer;
begin
  ACanvas.FillRectangle(NimbusInputBackColor(APalette), ABounds);
  ACanvas.DrawRectangle(NimbusControlBorderColor(APalette), ABounds);
  if (AGraphic = nil) or AGraphic.Empty or (AGraphic.Width <= 0) or (AGraphic.Height <= 0) then Exit;
  LRect := Rect(ABounds.Left + 3, ABounds.Top + 3, ABounds.Right - 3, ABounds.Bottom - 3);
  if (LRect.Width <= 0) or (LRect.Height <= 0) then Exit;
  if Int64(AGraphic.Width) * LRect.Height > Int64(AGraphic.Height) * LRect.Width then
  begin
    LHeight := Max(1, MulDiv(AGraphic.Height, LRect.Width, AGraphic.Width));
    LRect.Top := LRect.Top + (LRect.Height - LHeight) div 2;
    LRect.Bottom := LRect.Top + LHeight;
  end
  else
  begin
    LWidth := Max(1, MulDiv(AGraphic.Width, LRect.Height, AGraphic.Height));
    LRect.Left := LRect.Left + (LRect.Width - LWidth) div 2;
    LRect.Right := LRect.Left + LWidth;
  end;
  if AGraphic is TIcon then ACanvas.DrawIcon(TIcon(AGraphic).Handle, LRect)
  else if AGraphic is Vcl.Graphics.TBitmap then ACanvas.DrawBitmap(Vcl.Graphics.TBitmap(AGraphic), LRect)
  else
  begin
    LBitmap := Vcl.Graphics.TBitmap.Create;
    try
      LBitmap.PixelFormat := pf32bit;
      LBitmap.SetSize(Max(1, Min(AGraphic.Width, 512)), Max(1, Min(AGraphic.Height, 512)));
      LBitmap.Canvas.StretchDraw(Rect(0, 0, LBitmap.Width, LBitmap.Height), AGraphic);
      ACanvas.DrawBitmap(LBitmap, LRect);
    finally
      LBitmap.Free;
    end;
  end;
end;

class procedure TThemedPropertyGridRenderer.DrawDescription(const ACanvas: INimbusRenderCanvas; const APalette: TThemePalette; const AFont, AHeaderFont: TFont; const ABounds: TRect; const ATitle, AText: string);
var
  LTitleRect, LBodyRect: TRect;
begin
  LTitleRect := Rect(ABounds.Left + 9, ABounds.Top + 5, ABounds.Right - 9, ABounds.Top + 25);
  LBodyRect := Rect(ABounds.Left + 9, ABounds.Top + 26, ABounds.Right - 9, ABounds.Bottom - 3);
  ACanvas.DrawText(ATitle, AHeaderFont, NimbusControlForeColor(APalette), LTitleRect, [ntfSingleLine, ntfVCenter, ntfEndEllipsis, ntfNoPrefix]);
  ACanvas.DrawText(AText, AFont, NimbusMutedForeColor(APalette), LBodyRect, [ntfWordWrap, ntfEndEllipsis, ntfNoPrefix]);
end;

end.

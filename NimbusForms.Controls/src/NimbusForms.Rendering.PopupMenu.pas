{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.PopupMenu;

interface

uses
  Winapi.Windows,
  System.Types,
  Vcl.Graphics,
  Vcl.Menus,
  NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Canvas;

type
  TThemedPopupMenuRenderer = class
  public
    class procedure MeasureItem(const ACanvas: INimbusRenderCanvas; const AFont: TFont;
      const AMenuItem: TMenuItem; const APPI: Integer; var AWidth, AHeight: Integer); static;
    class procedure RenderItem(const ACanvas: INimbusRenderCanvas; const AMenuItem: TMenuItem;
      const AFont: TFont; const ARect: TRect; const AState: TOwnerDrawState;
      const APalette: TThemePalette; const APPI: Integer); static;
  end;

implementation

uses
  Winapi.CommCtrl,
  System.SysUtils,
  System.UITypes,
  Vcl.ImgList,
  NimbusForms.Theming.Types,
  NimbusForms.Rendering.Types;

class procedure TThemedPopupMenuRenderer.MeasureItem(const ACanvas: INimbusRenderCanvas;
  const AFont: TFont; const AMenuItem: TMenuItem; const APPI: Integer;
  var AWidth, AHeight: Integer);
var
  LCaptionSize, LShortcutSize: TSize;
  LImages: TCustomImageList;
  LGutter, LGap, LPadding, LArrow, LMinimumHeight: Integer;
  LShortcut: string;
  LOldStyle: TFontStyles;
begin
  if (ACanvas = nil) or (AFont = nil) or (AMenuItem = nil) then
    Exit;
  if AMenuItem.IsLine then
  begin
    AWidth := NimbusScaleValue(80, APPI);
    AHeight := NimbusScaleValue(8, APPI);
    Exit;
  end;
  LGutter := NimbusScaleValue(28, APPI);
  LGap := NimbusScaleValue(24, APPI);
  LPadding := NimbusScaleValue(12, APPI);
  LArrow := NimbusScaleValue(14, APPI);
  LMinimumHeight := NimbusScaleValue(26, APPI);
  LOldStyle := AFont.Style;
  try
    if AMenuItem.Default then AFont.Style := LOldStyle + [fsBold];
    LCaptionSize := ACanvas.MeasureText(AMenuItem.Caption, AFont, 0, [ntfSingleLine]);
  finally
    AFont.Style := LOldStyle;
  end;
  LShortcut := ShortCutToText(AMenuItem.ShortCut);
  LShortcutSize := ACanvas.MeasureText(LShortcut, AFont, 0, [ntfSingleLine, ntfNoPrefix]);
  AWidth := LGutter + LPadding + LCaptionSize.cx + LPadding + LArrow;
  if LShortcut <> '' then Inc(AWidth, LGap + LShortcutSize.cx);
  AHeight := LCaptionSize.cy + NimbusScaleValue(8, APPI);
  LImages := AMenuItem.GetImageList;
  if (LImages <> nil) and (AMenuItem.ImageIndex >= 0) and (AMenuItem.ImageIndex < LImages.Count) then
    if AHeight < LImages.Height + NimbusScaleValue(8, APPI) then
      AHeight := LImages.Height + NimbusScaleValue(8, APPI);
  if AHeight < LMinimumHeight then AHeight := LMinimumHeight;
end;

class procedure TThemedPopupMenuRenderer.RenderItem(const ACanvas: INimbusRenderCanvas;
  const AMenuItem: TMenuItem; const AFont: TFont; const ARect: TRect;
  const AState: TOwnerDrawState; const APalette: TThemePalette; const APPI: Integer);
var
  LBack, LFore, LBorder, LGlyph: TThemeColor;
  LImages: TCustomImageList;
  LTextRect, LShortcutRect, LIndicatorRect, LImageRect: TRect;
  LShortcutSize: TSize;
  LGutter, LPadding, LArrow, LGap, LArrowHalf, LCenterY, LImageX, LImageY: Integer;
  LShortcut: string;
  LSelected, LRTL: Boolean;
  LOldStyle: TFontStyles;
  LIcon: HICON;
  LImageFlags: UINT;
begin
  if (ACanvas = nil) or (AFont = nil) or (AMenuItem = nil) or NimbusRectIsEmpty(ARect) then
    Exit;
  LSelected := odSelected in AState;
  LRTL := (AMenuItem.GetParentMenu <> nil) and AMenuItem.GetParentMenu.IsRightToLeft;
  if LSelected then LBack := NimbusMenuSelectedBackColor(APalette) else LBack := NimbusMenuBackColor(APalette);
  if AMenuItem.Enabled then LFore := NimbusMenuForeColor(APalette) else LFore := NimbusDisabledForeColor(APalette);
  LBorder := NimbusMenuBorderColor(APalette);
  if AMenuItem.Enabled then LGlyph := NimbusAccentColor(APalette) else LGlyph := NimbusDisabledForeColor(APalette);
  ACanvas.FillRectangle(LBack, ARect);
  if LSelected then ACanvas.DrawRectangle(LBorder, ARect, 1.0);
  if AMenuItem.IsLine then
  begin
    LCenterY := (ARect.Top + ARect.Bottom) div 2;
    ACanvas.DrawLine(NimbusSeparatorColor(APalette), ARect.Left + NimbusScaleValue(8, APPI), LCenterY,
      ARect.Right - NimbusScaleValue(8, APPI), LCenterY, 1.0);
    Exit;
  end;
  LGutter := NimbusScaleValue(28, APPI);
  LPadding := NimbusScaleValue(8, APPI);
  LArrow := NimbusScaleValue(14, APPI);
  LGap := NimbusScaleValue(20, APPI);
  LCenterY := (ARect.Top + ARect.Bottom) div 2;
  if LRTL then
    LIndicatorRect := Rect(ARect.Right - LGutter, ARect.Top, ARect.Right, ARect.Bottom)
  else
    LIndicatorRect := Rect(ARect.Left, ARect.Top, ARect.Left + LGutter, ARect.Bottom);
  LImages := AMenuItem.GetImageList;
  if (LImages <> nil) and (AMenuItem.ImageIndex >= 0) and (AMenuItem.ImageIndex < LImages.Count) then
  begin
    LImageX := LIndicatorRect.Left + (LIndicatorRect.Width - LImages.Width) div 2;
    LImageY := LIndicatorRect.Top + (LIndicatorRect.Height - LImages.Height) div 2;
    LImageRect := Rect(LImageX, LImageY, LImageX + LImages.Width, LImageY + LImages.Height);
    LImageFlags := ILD_TRANSPARENT;
    if not AMenuItem.Enabled then LImageFlags := LImageFlags or ILD_BLEND50;
    LIcon := ImageList_GetIcon(LImages.Handle, AMenuItem.ImageIndex, LImageFlags);
    if LIcon <> 0 then
    try
      ACanvas.DrawIcon(LIcon, LImageRect);
    finally
      DestroyIcon(LIcon);
    end;
  end
  else if AMenuItem.Checked then
  begin
    LIndicatorRect := Rect(LIndicatorRect.Left + NimbusScaleValue(8, APPI), LCenterY - NimbusScaleValue(6, APPI),
      LIndicatorRect.Right - NimbusScaleValue(8, APPI), LCenterY + NimbusScaleValue(6, APPI));
    if AMenuItem.RadioItem then
    begin
      InflateRect(LIndicatorRect, -1, -1);
      ACanvas.FillEllipse(LGlyph, LIndicatorRect);
    end
    else
    begin
      ACanvas.DrawLine(LGlyph, LIndicatorRect.Left, LCenterY, LIndicatorRect.Left + LIndicatorRect.Width div 3,
        LIndicatorRect.Bottom - 1, 2.0);
      ACanvas.DrawLine(LGlyph, LIndicatorRect.Left + LIndicatorRect.Width div 3, LIndicatorRect.Bottom - 1,
        LIndicatorRect.Right, LIndicatorRect.Top + 1, 2.0);
    end;
  end;
  LShortcut := ShortCutToText(AMenuItem.ShortCut);
  if LRTL then
  begin
    LTextRect := Rect(ARect.Left + LArrow + LPadding, ARect.Top, ARect.Right - LGutter - LPadding, ARect.Bottom);
    LShortcutRect := LTextRect;
  end
  else
  begin
    LTextRect := Rect(ARect.Left + LGutter + LPadding, ARect.Top, ARect.Right - LArrow - LPadding, ARect.Bottom);
    LShortcutRect := LTextRect;
  end;
  if LShortcut <> '' then
  begin
    LShortcutSize := ACanvas.MeasureText(LShortcut, AFont, 0, [ntfSingleLine, ntfNoPrefix]);
    if LRTL then
    begin
      LShortcutRect.Right := LShortcutRect.Left + LShortcutSize.cx;
      ACanvas.DrawText(LShortcut, AFont, LFore, LShortcutRect, [ntfVCenter, ntfSingleLine, ntfNoPrefix, ntfRightToLeft]);
      LTextRect.Left := LShortcutRect.Right + LGap;
    end
    else
    begin
      ACanvas.DrawText(LShortcut, AFont, LFore, LShortcutRect, [ntfRight, ntfVCenter, ntfSingleLine, ntfNoPrefix]);
      LTextRect.Right := LTextRect.Right - LShortcutSize.cx - LGap;
    end;
  end;
  LOldStyle := AFont.Style;
  try
    if AMenuItem.Default then AFont.Style := LOldStyle + [fsBold];
    if LRTL then
      ACanvas.DrawText(AMenuItem.Caption, AFont, LFore, LTextRect, [ntfRight, ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfRightToLeft])
    else
      ACanvas.DrawText(AMenuItem.Caption, AFont, LFore, LTextRect, [ntfVCenter, ntfSingleLine, ntfEndEllipsis]);
  finally
    AFont.Style := LOldStyle;
  end;
  if AMenuItem.Count > 0 then
  begin
    LArrowHalf := NimbusScaleValue(3, APPI);
    if LRTL then
    begin
      ACanvas.DrawLine(LFore, ARect.Left + LPadding + LArrowHalf, LCenterY - LArrowHalf,
        ARect.Left + LPadding, LCenterY, 1.5);
      ACanvas.DrawLine(LFore, ARect.Left + LPadding, LCenterY,
        ARect.Left + LPadding + LArrowHalf, LCenterY + LArrowHalf, 1.5);
    end
    else
    begin
      ACanvas.DrawLine(LFore, ARect.Right - LPadding - LArrowHalf, LCenterY - LArrowHalf,
        ARect.Right - LPadding, LCenterY, 1.5);
      ACanvas.DrawLine(LFore, ARect.Right - LPadding, LCenterY,
        ARect.Right - LPadding - LArrowHalf, LCenterY + LArrowHalf, 1.5);
    end;
  end;
end;

end.

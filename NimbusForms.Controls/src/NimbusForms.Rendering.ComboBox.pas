{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.ComboBox;

interface

uses
  System.Types,
  Vcl.Graphics,
  NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Canvas;

type
  TThemedComboBoxRenderContext = record
    Bounds: TRect;
    Text: string;
    Font: TFont;
    Palette: TThemePalette;
    Enabled: Boolean;
    Hovered: Boolean;
    DroppedDown: Boolean;
    ButtonWidth: Integer;
    TextLeft: Integer;
    TextTop: Integer;
    TextRight: Integer;
    TextBottom: Integer;
    ArrowHalfWidth: Integer;
    ArrowTopOffset: Integer;
    ArrowBottomOffset: Integer;
    RightToLeft: Boolean;
  end;

  TThemedComboBoxItemRenderContext = record
    Bounds: TRect;
    Text: string;
    Font: TFont;
    Palette: TThemePalette;
    Selected: Boolean;
    Disabled: Boolean;
    Focused: Boolean;
    TextInset: Integer;
    RightToLeft: Boolean;
  end;

  TThemedComboBoxRenderer = class
  public
    class procedure RenderControl(const ACanvas: INimbusRenderCanvas; const AContext: TThemedComboBoxRenderContext); static;
    class procedure RenderItem(const ACanvas: INimbusRenderCanvas; const AContext: TThemedComboBoxItemRenderContext); static;
  end;

implementation

uses
  NimbusForms.Theming.Types,
  NimbusForms.Rendering.Types;

class procedure TThemedComboBoxRenderer.RenderControl(const ACanvas: INimbusRenderCanvas; const AContext: TThemedComboBoxRenderContext);
var
  LBackColor, LForeColor, LBorderColor, LButtonColor, LDisabledFore: TThemeColor;
  LButtonRect, LTextRect: TRect;
  LCenter: TPoint;
  LP1, LP2, LP3: TPoint;
  LTextFlags: TNimbusTextFlags;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(AContext.Bounds) then
    Exit;
  LBackColor := NimbusInputBackColor(AContext.Palette);
  LForeColor := NimbusInputForeColor(AContext.Palette);
  LBorderColor := NimbusInputBorderColor(AContext.Palette);
  LButtonColor := NimbusControlBackColor(AContext.Palette);
  LDisabledFore := NimbusDisabledForeColor(AContext.Palette);
  if AContext.Enabled then
  begin
    if AContext.DroppedDown then
      LButtonColor := NimbusPressedBackColor(AContext.Palette)
    else if AContext.Hovered then
      LButtonColor := NimbusHoverBackColor(AContext.Palette);
  end;
  ACanvas.FillRectangle(LBackColor, AContext.Bounds);
  if AContext.RightToLeft then
    LButtonRect := Rect(AContext.Bounds.Left, AContext.Bounds.Top, AContext.Bounds.Left + AContext.ButtonWidth, AContext.Bounds.Bottom)
  else
    LButtonRect := Rect(AContext.Bounds.Right - AContext.ButtonWidth, AContext.Bounds.Top, AContext.Bounds.Right, AContext.Bounds.Bottom);
  ACanvas.FillRectangle(LButtonColor, LButtonRect);
  ACanvas.DrawRectangle(LBorderColor, AContext.Bounds, 1.0);
  if AContext.RightToLeft then
    ACanvas.DrawLine(LBorderColor, LButtonRect.Right, LButtonRect.Top, LButtonRect.Right, LButtonRect.Bottom - 1, 1.0)
  else
    ACanvas.DrawLine(LBorderColor, LButtonRect.Left, LButtonRect.Top, LButtonRect.Left, LButtonRect.Bottom - 1, 1.0);
  LCenter := Point(LButtonRect.Left + LButtonRect.Width div 2, LButtonRect.Top + LButtonRect.Height div 2);
  LP1 := Point(LCenter.X - AContext.ArrowHalfWidth, LCenter.Y - AContext.ArrowTopOffset);
  LP2 := Point(LCenter.X + AContext.ArrowHalfWidth, LCenter.Y - AContext.ArrowTopOffset);
  LP3 := Point(LCenter.X, LCenter.Y + AContext.ArrowBottomOffset);
  if AContext.Enabled then ACanvas.FillTriangle(LForeColor, LP1, LP2, LP3) else ACanvas.FillTriangle(LDisabledFore, LP1, LP2, LP3);
  if AContext.RightToLeft then
    LTextRect := Rect(LButtonRect.Right + AContext.TextRight - AContext.TextLeft, AContext.Bounds.Top + AContext.TextTop,
      AContext.Bounds.Right - AContext.TextLeft, AContext.Bounds.Bottom - AContext.TextBottom + AContext.TextTop)
  else
    LTextRect := Rect(AContext.Bounds.Left + AContext.TextLeft, AContext.Bounds.Top + AContext.TextTop,
      AContext.Bounds.Right - AContext.ButtonWidth - AContext.TextRight + AContext.TextLeft, AContext.Bounds.Bottom - AContext.TextBottom + AContext.TextTop);
  LTextFlags := [ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix];
  if AContext.RightToLeft then
  begin
    Include(LTextFlags, ntfRightToLeft);
    Include(LTextFlags, ntfRight);
  end;
  if AContext.Enabled then
    ACanvas.DrawText(AContext.Text, AContext.Font, LForeColor, LTextRect, LTextFlags)
  else
    ACanvas.DrawText(AContext.Text, AContext.Font, LDisabledFore, LTextRect, LTextFlags);
end;

class procedure TThemedComboBoxRenderer.RenderItem(const ACanvas: INimbusRenderCanvas; const AContext: TThemedComboBoxItemRenderContext);
var
  LBackColor, LForeColor: TThemeColor;
  LTextRect, LFocusRect: TRect;
  LFlags: TNimbusTextFlags;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(AContext.Bounds) then
    Exit;
  LBackColor := NimbusInputBackColor(AContext.Palette);
  LForeColor := NimbusInputForeColor(AContext.Palette);
  if AContext.Selected then
  begin
    if AContext.Palette <> nil then LBackColor := AContext.Palette.SelectedBackColor else LBackColor := NimbusAccentColor(nil);
    LForeColor := NimbusSelectedForeColor(AContext.Palette);
  end;
  if AContext.Disabled then LForeColor := NimbusDisabledForeColor(AContext.Palette);
  ACanvas.FillRectangle(LBackColor, AContext.Bounds);
  LTextRect := AContext.Bounds;
  Inc(LTextRect.Left, AContext.TextInset);
  Dec(LTextRect.Right, AContext.TextInset);
  LFlags := [ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix];
  if AContext.RightToLeft then
  begin
    Include(LFlags, ntfRightToLeft);
    Include(LFlags, ntfRight);
  end;
  ACanvas.DrawText(AContext.Text, AContext.Font, LForeColor, LTextRect, LFlags);
  if AContext.Focused then
  begin
    LFocusRect := AContext.Bounds;
    InflateRect(LFocusRect, -1, -1);
    ACanvas.DrawFocusRectangle(NimbusFocusBorderColor(AContext.Palette), LFocusRect);
  end;
end;

end.

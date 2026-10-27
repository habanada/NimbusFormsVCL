{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.TrackBar;

interface

uses
  System.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Canvas;

type
  TThemedTrackBarRenderContext = record
    Bounds: TRect;
    Palette: TThemePalette;
    Minimum: Integer;
    Maximum: Integer;
    Value: Integer;
    ThumbSize: Integer;
    TrackThickness: Integer;
    Enabled: Boolean;
    Hovered: Boolean;
    Dragging: Boolean;
    Focused: Boolean;
  end;

  TThemedTrackBarRenderer = class
  public
    class function CalculateThumbRect(const AContext: TThemedTrackBarRenderContext): TRect; static;
    class procedure Render(const ACanvas: INimbusRenderCanvas; const AContext: TThemedTrackBarRenderContext); static;
  end;

implementation

uses
  System.Math,
  NimbusForms.Theming.Types,
  NimbusForms.Rendering.Types;

class function TThemedTrackBarRenderer.CalculateThumbRect(const AContext: TThemedTrackBarRenderContext): TRect;
var
  LTrackWidth, LRange, LX, LY: Integer;
  LRatio: Double;
begin
  LTrackWidth := AContext.Bounds.Width - AContext.ThumbSize;
  if LTrackWidth < 0 then LTrackWidth := 0;
  LRange := AContext.Maximum - AContext.Minimum;
  if LRange > 0 then
    LRatio := (AContext.Value - AContext.Minimum) / LRange
  else
    LRatio := 0;
  if LRatio < 0 then LRatio := 0;
  if LRatio > 1 then LRatio := 1;
  LX := AContext.Bounds.Left + Round(LRatio * LTrackWidth);
  LY := AContext.Bounds.Top + (AContext.Bounds.Height - AContext.ThumbSize) div 2;
  Result := Rect(LX, LY, LX + AContext.ThumbSize, LY + AContext.ThumbSize);
end;

class procedure TThemedTrackBarRenderer.Render(const ACanvas: INimbusRenderCanvas; const AContext: TThemedTrackBarRenderContext);
var
  LTrackColor, LFillColor, LThumbColor, LBackColor: TThemeColor;
  LTrackRect, LFillRect, LThumbRect, LFocusRect: TRect;
  LTrackY: Integer;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(AContext.Bounds) then
    Exit;
  LBackColor := NimbusPanelBackColor(AContext.Palette);
  ACanvas.FillRectangle(LBackColor, AContext.Bounds);
  LTrackColor := NimbusControlBorderColor(AContext.Palette);
  LFillColor := NimbusAccentColor(AContext.Palette);
  if AContext.Dragging then
    LThumbColor := NimbusPressedBackColor(AContext.Palette)
  else if AContext.Hovered then
    LThumbColor := NimbusHoverBackColor(AContext.Palette)
  else
    LThumbColor := NimbusControlForeColor(AContext.Palette);
  if not AContext.Enabled then
  begin
    LTrackColor := NimbusDisabledBackColor(AContext.Palette);
    LFillColor := NimbusDisabledForeColor(AContext.Palette);
    LThumbColor := LFillColor;
  end;
  LTrackY := AContext.Bounds.Top + (AContext.Bounds.Height - AContext.TrackThickness) div 2;
  LTrackRect := Rect(AContext.Bounds.Left + AContext.ThumbSize div 2, LTrackY,
    AContext.Bounds.Right - AContext.ThumbSize div 2, LTrackY + AContext.TrackThickness);
  if not NimbusRectIsEmpty(LTrackRect) then
    ACanvas.FillRectangle(LTrackColor, LTrackRect);
  LThumbRect := CalculateThumbRect(AContext);
  if LThumbRect.Left > AContext.Bounds.Left then
  begin
    LFillRect := Rect(LTrackRect.Left, LTrackY, LThumbRect.Left + AContext.ThumbSize div 2, LTrackY + AContext.TrackThickness);
    if LFillRect.Right > LTrackRect.Right then LFillRect.Right := LTrackRect.Right;
    if not NimbusRectIsEmpty(LFillRect) then ACanvas.FillRectangle(LFillColor, LFillRect);
  end;
  ACanvas.FillEllipse(LThumbColor, LThumbRect);
  if AContext.Focused and AContext.Enabled then
  begin
    LFocusRect := AContext.Bounds;
    InflateRect(LFocusRect, -1, -1);
    ACanvas.DrawFocusRectangle(NimbusFocusBorderColor(AContext.Palette), LFocusRect);
  end;
end;

end.

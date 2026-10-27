{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.RangeTrackBar;

interface

uses
  System.Types,
  Vcl.Graphics,
  NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Canvas;

type
  TThemedRangeTrackBarRenderContext = record
    Bounds: TRect;
    Font: TFont;
    Palette: TThemePalette;
    Minimum: Integer;
    Maximum: Integer;
    StartValue: Integer;
    EndValue: Integer;
    ThumbSize: Integer;
    TrackThickness: Integer;
    SidePadding: Integer;
    TopPadding: Integer;
    LabelSpacing: Integer;
    LabelHorizontalPadding: Integer;
    StartText: string;
    EndText: string;
    ShowValueLabels: Boolean;
    Enabled: Boolean;
    Focused: Boolean;
    HoverStart: Boolean;
    HoverEnd: Boolean;
    DragStart: Boolean;
    DragEnd: Boolean;
    RightToLeft: Boolean;
  end;

  TThemedRangeTrackBarRenderer = class
  public
    class function CalculateTrackRect(const AContext: TThemedRangeTrackBarRenderContext): TRect; static;
    class function CalculateThumbRect(const AContext: TThemedRangeTrackBarRenderContext; const AValue: Integer): TRect; static;
    class procedure Render(const ACanvas: INimbusRenderCanvas; const AContext: TThemedRangeTrackBarRenderContext); static;
  end;

implementation

uses
  System.Math,
  NimbusForms.Theming.Types,
  NimbusForms.Rendering.Types;

class function TThemedRangeTrackBarRenderer.CalculateTrackRect(const AContext: TThemedRangeTrackBarRenderContext): TRect;
var
  LWidth: Integer;
begin
  LWidth := AContext.Bounds.Width - AContext.SidePadding * 2 - AContext.ThumbSize;
  if LWidth < 1 then LWidth := 1;
  Result.Left := AContext.Bounds.Left + AContext.SidePadding + AContext.ThumbSize div 2;
  Result.Top := AContext.Bounds.Top + AContext.TopPadding + (AContext.ThumbSize - AContext.TrackThickness) div 2;
  Result.Right := Result.Left + LWidth;
  Result.Bottom := Result.Top + Max(1, AContext.TrackThickness);
end;

class function TThemedRangeTrackBarRenderer.CalculateThumbRect(const AContext: TThemedRangeTrackBarRenderContext; const AValue: Integer): TRect;
var
  LTrack: TRect;
  LRange, LValue, LCenterX: Integer;
  LRatio: Double;
begin
  LTrack := CalculateTrackRect(AContext);
  LRange := AContext.Maximum - AContext.Minimum;
  LValue := AValue;
  if LValue < AContext.Minimum then LValue := AContext.Minimum;
  if LValue > AContext.Maximum then LValue := AContext.Maximum;
  if LRange > 0 then LRatio := (LValue - AContext.Minimum) / LRange else LRatio := 0;
  LCenterX := LTrack.Left + Round(LRatio * LTrack.Width);
  Result := Rect(LCenterX - AContext.ThumbSize div 2, AContext.Bounds.Top + AContext.TopPadding,
    LCenterX - AContext.ThumbSize div 2 + AContext.ThumbSize, AContext.Bounds.Top + AContext.TopPadding + AContext.ThumbSize);
end;

class procedure TThemedRangeTrackBarRenderer.Render(const ACanvas: INimbusRenderCanvas; const AContext: TThemedRangeTrackBarRenderContext);
var
  LTrack, LStartThumb, LEndThumb, LSelected, LFocusRect, LStartTextRect, LEndTextRect: TRect;
  LTrackColor, LRangeColor, LThumbColor, LStartColor, LEndColor, LLabelColor: TThemeColor;
  LStartSize, LEndSize: TSize;
  LStartCenter, LEndCenter: Integer;
  LStartFlags, LEndFlags: TNimbusTextFlags;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(AContext.Bounds) then
    Exit;
  ACanvas.FillRectangle(NimbusPanelBackColor(AContext.Palette), AContext.Bounds);
  if AContext.Enabled then
  begin
    LTrackColor := NimbusControlBorderColor(AContext.Palette);
    LRangeColor := NimbusAccentColor(AContext.Palette);
    LThumbColor := NimbusControlForeColor(AContext.Palette);
    LLabelColor := NimbusControlForeColor(AContext.Palette);
  end
  else
  begin
    LTrackColor := NimbusDisabledBackColor(AContext.Palette);
    LRangeColor := NimbusDisabledForeColor(AContext.Palette);
    LThumbColor := NimbusDisabledForeColor(AContext.Palette);
    LLabelColor := NimbusDisabledForeColor(AContext.Palette);
  end;
  LTrack := CalculateTrackRect(AContext);
  LStartThumb := CalculateThumbRect(AContext, AContext.StartValue);
  LEndThumb := CalculateThumbRect(AContext, AContext.EndValue);
  ACanvas.FillRoundedRectangle(LTrackColor, LTrack, Max(1, LTrack.Height div 2));
  LStartCenter := LStartThumb.Left + LStartThumb.Width div 2;
  LEndCenter := LEndThumb.Left + LEndThumb.Width div 2;
  if LEndCenter < LStartCenter then LEndCenter := LStartCenter;
  LSelected := Rect(LStartCenter, LTrack.Top, LEndCenter, LTrack.Bottom);
  if not NimbusRectIsEmpty(LSelected) then ACanvas.FillRectangle(LRangeColor, LSelected);
  LStartColor := LThumbColor;
  if AContext.DragStart then LStartColor := NimbusPressedBackColor(AContext.Palette)
  else if AContext.HoverStart then LStartColor := NimbusHoverBackColor(AContext.Palette);
  LEndColor := LThumbColor;
  if AContext.DragEnd then LEndColor := NimbusPressedBackColor(AContext.Palette)
  else if AContext.HoverEnd then LEndColor := NimbusHoverBackColor(AContext.Palette);
  ACanvas.FillEllipse(LStartColor, LStartThumb);
  ACanvas.FillEllipse(LEndColor, LEndThumb);
  if AContext.ShowValueLabels and (AContext.Font <> nil) then
  begin
    LStartFlags := [ntfSingleLine, ntfVCenter, ntfNoPrefix];
    LEndFlags := [ntfRight, ntfSingleLine, ntfVCenter, ntfNoPrefix];
    if AContext.RightToLeft then
    begin
      Include(LStartFlags, ntfRightToLeft);
      Include(LEndFlags, ntfRightToLeft);
    end;
    LStartSize := ACanvas.MeasureText(AContext.StartText, AContext.Font, MaxInt, LStartFlags);
    LEndSize := ACanvas.MeasureText(AContext.EndText, AContext.Font, MaxInt, LEndFlags);
    LStartTextRect := Rect(AContext.Bounds.Left + AContext.SidePadding, LTrack.Bottom + AContext.LabelSpacing,
      AContext.Bounds.Left + AContext.SidePadding + LStartSize.cx + AContext.LabelHorizontalPadding * 2,
      LTrack.Bottom + AContext.LabelSpacing + LStartSize.cy);
    LEndTextRect := Rect(AContext.Bounds.Right - AContext.SidePadding - LEndSize.cx - AContext.LabelHorizontalPadding * 2,
      LTrack.Bottom + AContext.LabelSpacing, AContext.Bounds.Right - AContext.SidePadding,
      LTrack.Bottom + AContext.LabelSpacing + LEndSize.cy);
    ACanvas.DrawText(AContext.StartText, AContext.Font, LLabelColor, LStartTextRect, LStartFlags);
    ACanvas.DrawText(AContext.EndText, AContext.Font, LLabelColor, LEndTextRect, LEndFlags);
  end;
  if AContext.Focused and AContext.Enabled then
  begin
    LFocusRect := AContext.Bounds;
    InflateRect(LFocusRect, -2, -2);
    if not NimbusRectIsEmpty(LFocusRect) then ACanvas.DrawFocusRectangle(NimbusFocusBorderColor(AContext.Palette), LFocusRect);
  end;
end;

end.

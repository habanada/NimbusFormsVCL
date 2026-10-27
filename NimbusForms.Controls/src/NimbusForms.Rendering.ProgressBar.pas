{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.ProgressBar;

interface

uses
  System.Types,
  Vcl.Graphics,
  NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Canvas;

type
  TThemedProgressBarRenderContext = record
    Bounds: TRect;
    Font: TFont;
    Palette: TThemePalette;
    Minimum: Integer;
    Maximum: Integer;
    Position: Integer;
    ShowPercentage: Boolean;
    CornerRadius: Integer;
    Enabled: Boolean;
  end;

  TThemedProgressBarRenderer = class
  public
    class procedure Render(const ACanvas: INimbusRenderCanvas;
      const AContext: TThemedProgressBarRenderContext); static;
  end;

implementation

uses
  System.SysUtils,
  NimbusForms.Theming.Types,
  NimbusForms.Rendering.Types;

class procedure TThemedProgressBarRenderer.Render(const ACanvas: INimbusRenderCanvas;
  const AContext: TThemedProgressBarRenderContext);
var
  LFillRect: TRect;
  LRange, LValue, LWidth, LPercent: Int64;
  LBack, LFill, LBorder, LFore: TThemeColor;
  LText: string;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(AContext.Bounds) then
    Exit;

  if AContext.Enabled then
  begin
    LBack := NimbusProgressBackColor(AContext.Palette);
    LFill := NimbusProgressFillColor(AContext.Palette);
    LBorder := NimbusControlBorderColor(AContext.Palette);
    LFore := NimbusControlForeColor(AContext.Palette);
  end
  else
  begin
    LBack := NimbusDisabledBackColor(AContext.Palette);
    LFill := NimbusDisabledForeColor(AContext.Palette);
    LBorder := NimbusControlBorderColor(AContext.Palette);
    LFore := NimbusDisabledForeColor(AContext.Palette);
  end;

  ACanvas.FillRectangle(NimbusPanelBackColor(AContext.Palette), AContext.Bounds);
  ACanvas.FillRoundedRectangle(LBack, AContext.Bounds, AContext.CornerRadius);
  LRange := Int64(AContext.Maximum) - Int64(AContext.Minimum);
  LValue := Int64(AContext.Position) - Int64(AContext.Minimum);
  if LRange > 0 then
    LWidth := (Int64(AContext.Bounds.Width) * LValue) div LRange
  else
    LWidth := 0;
  if LWidth < 0 then LWidth := 0;
  if LWidth > AContext.Bounds.Width then LWidth := AContext.Bounds.Width;
  if LWidth > 0 then
  begin
    LFillRect := AContext.Bounds;
    LFillRect.Right := LFillRect.Left + Integer(LWidth);
    ACanvas.FillRoundedRectangle(LFill, LFillRect, AContext.CornerRadius);
  end;
  ACanvas.DrawRoundedRectangle(LBorder, AContext.Bounds, AContext.CornerRadius, 1.0);

  if AContext.ShowPercentage then
  begin
    if LRange > 0 then LPercent := (LValue * 100) div LRange else LPercent := 0;
    if LPercent < 0 then LPercent := 0;
    if LPercent > 100 then LPercent := 100;
    LText := IntToStr(LPercent) + '%';
    ACanvas.DrawText(LText, AContext.Font, LFore, AContext.Bounds,
      [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix]);
  end;
end;

end.

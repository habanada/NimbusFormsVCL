{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.RadioButton;

interface

uses
  System.Types,
  Vcl.Graphics,
  NimbusForms.Theming.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Types,
  NimbusForms.Rendering.Canvas;

type
  TThemedRadioButtonRenderContext = record
    Bounds: TRect;
    Caption: string;
    Font: TFont;
    Palette: TThemePalette;
    State: TNimbusVisualState;
    Checked: Boolean;
    CircleSize: Integer;
    CircleOffsetX: Integer;
    TextSpacing: Integer;
    DotSize: Integer;
    CircleBorderThickness: Single;
    Focused: Boolean;
    RightToLeft: Boolean;
  end;

  TThemedRadioButtonRenderer = class
  public
    class procedure Render(const ACanvas: INimbusRenderCanvas; const AContext: TThemedRadioButtonRenderContext); static;
  end;

implementation

class procedure TThemedRadioButtonRenderer.Render(const ACanvas: INimbusRenderCanvas; const AContext: TThemedRadioButtonRenderContext);
var
  LCircle, LBorderCircle, LDot, LText: TRect;
  LBack, LBorder, LFore, LDotColor: TThemeColor;
  LCircleSize, LDotSize, LTop, LDotX, LDotY: Integer;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(AContext.Bounds) then
    Exit;

  ACanvas.FillRectangle(NimbusPanelBackColor(AContext.Palette), AContext.Bounds);

  LCircleSize := AContext.CircleSize;
  if LCircleSize < 1 then LCircleSize := 1;
  LTop := AContext.Bounds.Top + (AContext.Bounds.Height - LCircleSize) div 2;
  if AContext.RightToLeft then
    LCircle := Rect(AContext.Bounds.Right - AContext.CircleOffsetX - LCircleSize, LTop,
      AContext.Bounds.Right - AContext.CircleOffsetX, LTop + LCircleSize)
  else
    LCircle := Rect(AContext.Bounds.Left + AContext.CircleOffsetX, LTop,
      AContext.Bounds.Left + AContext.CircleOffsetX + LCircleSize, LTop + LCircleSize);

  if AContext.State = nvsDisabled then
  begin
    LBack := NimbusDisabledBackColor(AContext.Palette);
    LBorder := NimbusDisabledForeColor(AContext.Palette);
    LFore := NimbusDisabledForeColor(AContext.Palette);
    LDotColor := NimbusDisabledForeColor(AContext.Palette);
  end
  else
  begin
    if AContext.State = nvsPressed then
      LBack := NimbusPressedBackColor(AContext.Palette)
    else if AContext.State = nvsHot then
      LBack := NimbusHoverBackColor(AContext.Palette)
    else
      LBack := NimbusInputBackColor(AContext.Palette);
    if AContext.Checked or (AContext.State = nvsHot) then
      LBorder := NimbusAccentColor(AContext.Palette)
    else
      LBorder := NimbusControlBorderColor(AContext.Palette);
    LFore := NimbusControlForeColor(AContext.Palette);
    LDotColor := NimbusAccentColor(AContext.Palette);
  end;

  ACanvas.FillEllipse(LBack, LCircle);
  LBorderCircle := LCircle;
  Inc(LBorderCircle.Right);
  Inc(LBorderCircle.Bottom);
  ACanvas.DrawEllipse(LBorder, LBorderCircle, AContext.CircleBorderThickness);

  if AContext.Checked then
  begin
    LDotSize := AContext.DotSize;
    if LDotSize < 1 then LDotSize := 1;
    if LDotSize > LCircleSize then LDotSize := LCircleSize;
    LDotX := LCircle.Left + (LCircle.Width - LDotSize) div 2;
    LDotY := LCircle.Top + (LCircle.Height - LDotSize) div 2;
    LDot := Rect(LDotX, LDotY, LDotX + LDotSize, LDotY + LDotSize);
    ACanvas.FillEllipse(LDotColor, LDot);
  end;

  if AContext.RightToLeft then
    LText := Rect(AContext.Bounds.Left, AContext.Bounds.Top, LCircle.Left - AContext.TextSpacing, AContext.Bounds.Bottom)
  else
    LText := Rect(LCircle.Right + AContext.TextSpacing, AContext.Bounds.Top, AContext.Bounds.Right, AContext.Bounds.Bottom);

  if AContext.Caption <> '' then
    if AContext.RightToLeft then
      ACanvas.DrawText(AContext.Caption, AContext.Font, LFore, LText, [ntfRight, ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix, ntfRightToLeft])
    else
      ACanvas.DrawText(AContext.Caption, AContext.Font, LFore, LText, [ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix]);
end;

end.

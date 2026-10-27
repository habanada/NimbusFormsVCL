{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.CheckBox;

interface

uses
  System.Types,
  Vcl.Graphics,
  Vcl.StdCtrls,
  NimbusForms.Theming.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Types,
  NimbusForms.Rendering.Canvas;

type
  TThemedCheckBoxRenderContext = record
    Bounds: TRect;
    Caption: string;
    Font: TFont;
    Palette: TThemePalette;
    State: TNimbusVisualState;
    CheckState: TCheckBoxState;
    BoxSize: Integer;
    Spacing: Integer;
    CornerRadius: Integer;
    Focused: Boolean;
    RightToLeft: Boolean;
  end;

  TThemedCheckBoxRenderer = class
  public
    class procedure Render(const ACanvas: INimbusRenderCanvas;
      const AContext: TThemedCheckBoxRenderContext); static;
  end;

implementation

class procedure TThemedCheckBoxRenderer.Render(const ACanvas: INimbusRenderCanvas;
  const AContext: TThemedCheckBoxRenderContext);
var
  LBox, LText, LFocus: TRect;
  LBack, LBorder, LFore, LGlyph: TThemeColor;
  LCenterY, LPad: Integer;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(AContext.Bounds) then
    Exit;

  ACanvas.FillRectangle(NimbusPanelBackColor(AContext.Palette), AContext.Bounds);
  LCenterY := AContext.Bounds.Top + AContext.Bounds.Height div 2;
  if AContext.RightToLeft then
    LBox := Rect(AContext.Bounds.Right - AContext.BoxSize, LCenterY - AContext.BoxSize div 2,
      AContext.Bounds.Right, LCenterY - AContext.BoxSize div 2 + AContext.BoxSize)
  else
    LBox := Rect(AContext.Bounds.Left, LCenterY - AContext.BoxSize div 2,
      AContext.Bounds.Left + AContext.BoxSize, LCenterY - AContext.BoxSize div 2 + AContext.BoxSize);

  if AContext.State = nvsDisabled then
  begin
    LBack := NimbusDisabledBackColor(AContext.Palette);
    LBorder := NimbusDisabledForeColor(AContext.Palette);
    LFore := NimbusDisabledForeColor(AContext.Palette);
    LGlyph := NimbusDisabledBackColor(AContext.Palette);
  end
  else
  begin
    if AContext.CheckState <> cbUnchecked then
      LBack := NimbusAccentColor(AContext.Palette)
    else if AContext.State = nvsPressed then
      LBack := NimbusPressedBackColor(AContext.Palette)
    else if AContext.State = nvsHot then
      LBack := NimbusHoverBackColor(AContext.Palette)
    else
      LBack := NimbusInputBackColor(AContext.Palette);
    if (AContext.CheckState <> cbUnchecked) or (AContext.State = nvsHot) then
      LBorder := NimbusAccentColor(AContext.Palette)
    else
      LBorder := NimbusControlBorderColor(AContext.Palette);
    LFore := NimbusControlForeColor(AContext.Palette);
    LGlyph := NimbusSelectedForeColor(AContext.Palette);
  end;

  ACanvas.FillRoundedRectangle(LBack, LBox, AContext.CornerRadius);
  ACanvas.DrawRoundedRectangle(LBorder, LBox, AContext.CornerRadius, 1.0);

  LPad := AContext.BoxSize div 4;
  if AContext.CheckState = cbChecked then
  begin
    ACanvas.DrawLine(LGlyph, LBox.Left + LPad - 1, LBox.Top + AContext.BoxSize div 2,
      LBox.Left + AContext.BoxSize div 2 - 1, LBox.Bottom - LPad, 2.0);
    ACanvas.DrawLine(LGlyph, LBox.Left + AContext.BoxSize div 2 - 1, LBox.Bottom - LPad,
      LBox.Right - LPad + 1, LBox.Top + LPad, 2.0);
  end
  else if AContext.CheckState = cbGrayed then
    ACanvas.DrawLine(LGlyph, LBox.Left + LPad, LCenterY, LBox.Right - LPad, LCenterY, 2.0);

  if AContext.RightToLeft then
    LText := Rect(AContext.Bounds.Left, AContext.Bounds.Top, LBox.Left - AContext.Spacing, AContext.Bounds.Bottom)
  else
    LText := Rect(LBox.Right + AContext.Spacing, AContext.Bounds.Top, AContext.Bounds.Right, AContext.Bounds.Bottom);
  if AContext.Caption <> '' then
    if AContext.RightToLeft then
      ACanvas.DrawText(AContext.Caption, AContext.Font, LFore, LText, [ntfRight, ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfRightToLeft])
    else
      ACanvas.DrawText(AContext.Caption, AContext.Font, LFore, LText, [ntfVCenter, ntfSingleLine, ntfEndEllipsis]);

  if AContext.Focused and (AContext.State <> nvsDisabled) then
  begin
    LFocus := LText;
    if NimbusRectIsEmpty(LFocus) then LFocus := LBox;
    InflateRect(LFocus, -1, -2);
    if not NimbusRectIsEmpty(LFocus) then
      ACanvas.DrawRoundedRectangle(NimbusFocusBorderColor(AContext.Palette), LFocus, 2, 1.0);
  end;
end;

end.

{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.SplitContainer;

interface

uses
  System.Types, NimbusForms.Theming.Palette, NimbusForms.Rendering.Canvas;

type
  TThemedSplitterStyle = (tssStandard, tssSubtle, tssGrip);

  TThemedSplitRenderContext = record
    Bounds: TRect;
    SplitterRect: TRect;
    FirstButtonRect: TRect;
    SecondButtonRect: TRect;
    Palette: TThemePalette;
    Vertical: Boolean;
    Enabled: Boolean;
    Hovered: Boolean;
    HotButton: Integer;
    Dragging: Boolean;
    ShowCollapseButtons: Boolean;
    SplitterStyle: TThemedSplitterStyle;
    PPI: Integer;
  end;

  TThemedSplitContainerRenderer = class
  public
    class procedure Render(const ACanvas: INimbusRenderCanvas; const AContext: TThemedSplitRenderContext); static;
  end;

implementation

uses
  System.Math, Winapi.Windows, NimbusForms.Rendering.Types, NimbusForms.Theming.Types;

class procedure TThemedSplitContainerRenderer.Render(const ACanvas: INimbusRenderCanvas; const AContext: TThemedSplitRenderContext);
var
  LBack, LBorder, LFore: TThemeColor;
  I, CX, CY, LDot, LStep, LOffset: Integer;
  R: TRect;
  procedure DrawArrow(const ARect: TRect; const AReverse: Boolean; const AHot: Boolean);
  var
    X, Y, S, Dir: Integer;
  begin
    if NimbusRectIsEmpty(ARect) then Exit;
    if AHot then
    begin
      ACanvas.FillRoundedRectangle(NimbusHoverBackColor(AContext.Palette), ARect, Max(2, MulDiv(3, AContext.PPI, 96)));
      ACanvas.DrawRoundedRectangle(NimbusSeparatorColor(AContext.Palette), ARect, Max(2, MulDiv(3, AContext.PPI, 96)), 0.75);
    end
    else
      ACanvas.FillRoundedRectangle(NimbusControlBackColor(AContext.Palette), ARect, Max(2, MulDiv(3, AContext.PPI, 96)));
    X := (ARect.Left + ARect.Right) div 2;
    Y := (ARect.Top + ARect.Bottom) div 2;
    S := Max(2, MulDiv(3, AContext.PPI, 96));
    Dir := 1;
    if AReverse then Dir := -1;
    if AContext.Vertical then
    begin
      ACanvas.DrawLine(LFore, X - Dir * S, Y - S, X, Y, 1.5);
      ACanvas.DrawLine(LFore, X, Y, X - Dir * S, Y + S, 1.5);
    end
    else
    begin
      ACanvas.DrawLine(LFore, X - S, Y - Dir * S, X, Y, 1.5);
      ACanvas.DrawLine(LFore, X, Y, X + S, Y - Dir * S, 1.5);
    end;
  end;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(AContext.Bounds) then Exit;
  ACanvas.FillRectangle(NimbusPanelBackColor(AContext.Palette), AContext.Bounds);
  if NimbusRectIsEmpty(AContext.SplitterRect) then Exit;
  LBack := NimbusControlBackColor(AContext.Palette);
  LBorder := NimbusSeparatorColor(AContext.Palette);
  LFore := NimbusControlBorderColor(AContext.Palette);
  if AContext.Hovered then LBack := NimbusHoverBackColor(AContext.Palette);
  if AContext.Dragging then LBack := NimbusPressedBackColor(AContext.Palette);
  if not AContext.Enabled then LFore := NimbusDisabledForeColor(AContext.Palette);
  if AContext.SplitterStyle <> tssSubtle then ACanvas.FillRectangle(LBack, AContext.SplitterRect);
  if AContext.Vertical then
  begin
    CX := (AContext.SplitterRect.Left + AContext.SplitterRect.Right) div 2;
    ACanvas.DrawLine(LBorder, CX, AContext.SplitterRect.Top, CX, AContext.SplitterRect.Bottom, 1);
  end
  else
  begin
    CY := (AContext.SplitterRect.Top + AContext.SplitterRect.Bottom) div 2;
    ACanvas.DrawLine(LBorder, AContext.SplitterRect.Left, CY, AContext.SplitterRect.Right, CY, 1);
  end;
  if AContext.SplitterStyle = tssGrip then
  begin
    LDot := Max(2, MulDiv(2, AContext.PPI, 96));
    LStep := Max(4, MulDiv(6, AContext.PPI, 96));
    CX := (AContext.SplitterRect.Left + AContext.SplitterRect.Right) div 2;
    CY := (AContext.SplitterRect.Top + AContext.SplitterRect.Bottom) div 2;
    for I := -2 to 2 do
    begin
      LOffset := I * LStep;
      if AContext.Vertical then R := Rect(CX - LDot div 2, CY + LOffset - LDot div 2, CX - LDot div 2 + LDot, CY + LOffset - LDot div 2 + LDot)
      else R := Rect(CX + LOffset - LDot div 2, CY - LDot div 2, CX + LOffset - LDot div 2 + LDot, CY - LDot div 2 + LDot);
      ACanvas.FillEllipse(LFore, R);
    end;
  end;
  if AContext.ShowCollapseButtons then
  begin
    DrawArrow(AContext.FirstButtonRect, False, AContext.HotButton = 1);
    DrawArrow(AContext.SecondButtonRect, True, AContext.HotButton = 2);
  end;
end;

end.

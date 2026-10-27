{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.Splitter;

interface

uses System.Types, NimbusForms.Theming.Palette, NimbusForms.Rendering.Canvas;

type
  TThemedSplitterRenderContext = record
    Bounds: TRect;
    Palette: TThemePalette;
    PPI: Integer;
    Vertical, Enabled, Hovered, Pressed, Focused, ShowGrip, ShowLine: Boolean;
  end;
  TThemedSplitterRenderer = class
  public
    class procedure Render(const Canvas: INimbusRenderCanvas; const Context: TThemedSplitterRenderContext); static;
  end;

implementation

uses Winapi.Windows, System.Math, NimbusForms.Theming.Types, NimbusForms.Rendering.Types;

class procedure TThemedSplitterRenderer.Render(const Canvas: INimbusRenderCanvas; const Context: TThemedSplitterRenderContext);
var Back, LineColor, GripColor: TThemeColor; CX, CY, DotSize, Step, Gap, I, Offset: Integer; R: TRect;
begin
  if (Canvas = nil) or Context.Bounds.IsEmpty then Exit;
  Back := NimbusPanelBackColor(Context.Palette); LineColor := NimbusSeparatorColor(Context.Palette);
  GripColor := NimbusControlBorderColor(Context.Palette);
  if Context.Hovered or Context.Focused then Back := NimbusHoverBackColor(Context.Palette);
  if Context.Pressed then Back := NimbusPressedBackColor(Context.Palette);
  if not Context.Enabled then GripColor := NimbusDisabledForeColor(Context.Palette);
  Canvas.FillRectangle(Back, Context.Bounds);
  CX := (Context.Bounds.Left + Context.Bounds.Right) div 2; CY := (Context.Bounds.Top + Context.Bounds.Bottom) div 2;
  DotSize := Max(1, MulDiv(3, Context.PPI, 96)); Step := Max(DotSize + 1, MulDiv(6, Context.PPI, 96));
  if Context.Vertical then DotSize := Min(DotSize, Context.Bounds.Width) else DotSize := Min(DotSize, Context.Bounds.Height);
  Gap := 0; if Context.ShowGrip then Gap := Step * 2 + DotSize + Max(1, MulDiv(3, Context.PPI, 96));
  if Context.ShowLine then
    if Context.Vertical then
    begin
      if CY - Gap > Context.Bounds.Top then Canvas.DrawLine(LineColor, CX, Context.Bounds.Top, CX, CY - Gap, 1);
      if CY + Gap < Context.Bounds.Bottom then Canvas.DrawLine(LineColor, CX, CY + Gap, CX, Context.Bounds.Bottom, 1);
    end
    else
    begin
      if CX - Gap > Context.Bounds.Left then Canvas.DrawLine(LineColor, Context.Bounds.Left, CY, CX - Gap, CY, 1);
      if CX + Gap < Context.Bounds.Right then Canvas.DrawLine(LineColor, CX + Gap, CY, Context.Bounds.Right, CY, 1);
    end;
  if Context.ShowGrip then
    for I := -2 to 2 do
    begin
      Offset := I * Step;
      if Context.Vertical then R := Rect(CX - DotSize div 2, CY + Offset - DotSize div 2, CX - DotSize div 2 + DotSize, CY + Offset - DotSize div 2 + DotSize)
      else R := Rect(CX + Offset - DotSize div 2, CY - DotSize div 2, CX + Offset - DotSize div 2 + DotSize, CY - DotSize div 2 + DotSize);
      if Context.Bounds.Contains(R.TopLeft) and (R.Right <= Context.Bounds.Right) and (R.Bottom <= Context.Bounds.Bottom) then Canvas.FillRectangle(GripColor, R);
    end;
end;

end.

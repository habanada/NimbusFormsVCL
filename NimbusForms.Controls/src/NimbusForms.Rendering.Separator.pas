{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.Separator;

interface

uses
  System.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Canvas,
  NimbusForms.Controls.Types;

type
  TThemedSeparatorRenderContext = record
    Bounds: TRect;
    Palette: TThemePalette;
    Orientation: TThemedSeparatorOrientation;
    Thickness: Integer;
  end;

  TThemedSeparatorRenderer = class
  public
    class procedure Render(const ACanvas: INimbusRenderCanvas; const AContext: TThemedSeparatorRenderContext); static;
  end;

implementation

uses
  NimbusForms.Rendering.Types;

class procedure TThemedSeparatorRenderer.Render(const ACanvas: INimbusRenderCanvas; const AContext: TThemedSeparatorRenderContext);
var
  LRect: TRect;
  LThickness: Integer;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(AContext.Bounds) then
    Exit;
  ACanvas.FillRectangle(NimbusPanelBackColor(AContext.Palette), AContext.Bounds);
  LThickness := AContext.Thickness;
  if LThickness < 1 then LThickness := 1;
  if AContext.Orientation = tsoHorizontal then
  begin
    if LThickness > AContext.Bounds.Height then LThickness := AContext.Bounds.Height;
    LRect := Rect(AContext.Bounds.Left, AContext.Bounds.Top + (AContext.Bounds.Height - LThickness) div 2,
      AContext.Bounds.Right, AContext.Bounds.Top + (AContext.Bounds.Height - LThickness) div 2 + LThickness);
  end
  else
  begin
    if LThickness > AContext.Bounds.Width then LThickness := AContext.Bounds.Width;
    LRect := Rect(AContext.Bounds.Left + (AContext.Bounds.Width - LThickness) div 2, AContext.Bounds.Top,
      AContext.Bounds.Left + (AContext.Bounds.Width - LThickness) div 2 + LThickness, AContext.Bounds.Bottom);
  end;
  ACanvas.FillRectangle(NimbusSeparatorColor(AContext.Palette), LRect);
end;

end.

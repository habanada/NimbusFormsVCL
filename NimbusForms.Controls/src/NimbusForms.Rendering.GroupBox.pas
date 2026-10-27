{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.GroupBox;

interface

uses
  System.Types,
  Vcl.Graphics,
  NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Canvas;

type
  TThemedGroupBoxRenderContext = record
    Bounds: TRect;
    Caption: string;
    Font: TFont;
    Palette: TThemePalette;
    TextLeft: Integer;
    LineTextSpacing: Integer;
    LeftLineWidth: Integer;
    BorderThickness: Integer;
    RightToLeft: Boolean;
  end;

  TThemedGroupBoxRenderer = class
  public
    class procedure Render(const ACanvas: INimbusRenderCanvas; const AContext: TThemedGroupBoxRenderContext); static;
  end;

implementation

uses
  System.UITypes,
  NimbusForms.Theming.Types,
  NimbusForms.Rendering.Types;

class procedure TThemedGroupBoxRenderer.Render(const ACanvas: INimbusRenderCanvas; const AContext: TThemedGroupBoxRenderContext);
var
  LBackColor, LForeColor, LBorderColor: TThemeColor;
  LTextSize: TSize;
  LTextRect: TRect;
  LTopY, LBorderWidth, LLeftLineEnd, LRightLineStart: Integer;
  LTextFlags: TNimbusTextFlags;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(AContext.Bounds) then
    Exit;
  if AContext.Palette <> nil then
  begin
    LBackColor := AContext.Palette.PanelBackColor;
    LForeColor := AContext.Palette.ForeColor;
    LBorderColor := AContext.Palette.GroupBoxBorderColor;
  end
  else
  begin
    LBackColor := ColorToThemeColor(clBtnFace);
    LForeColor := ColorToThemeColor(clBtnText);
    LBorderColor := ColorToThemeColor(clBtnShadow);
  end;
  ACanvas.FillRectangle(LBackColor, AContext.Bounds);
  LTextFlags := [ntfSingleLine];
  if AContext.RightToLeft then Include(LTextFlags, ntfRightToLeft);
  LTextSize := ACanvas.MeasureText(AContext.Caption, AContext.Font, 0, LTextFlags);
  if LTextSize.cy < 1 then LTextSize.cy := AContext.Font.Height;
  if LTextSize.cy < 1 then LTextSize.cy := 1;
  LTopY := AContext.Bounds.Top + LTextSize.cy div 2;
  LBorderWidth := AContext.BorderThickness;
  if LBorderWidth < 1 then LBorderWidth := 1;
  LLeftLineEnd := AContext.Bounds.Left + AContext.LeftLineWidth;
  if AContext.Caption <> '' then
  begin
    if AContext.RightToLeft then
    begin
      LTextRect := Rect(AContext.Bounds.Right - AContext.TextLeft - LTextSize.cx, AContext.Bounds.Top,
        AContext.Bounds.Right - AContext.TextLeft, AContext.Bounds.Top + LTextSize.cy);
      LRightLineStart := LTextRect.Left - AContext.LineTextSpacing;
      ACanvas.DrawLine(LBorderColor, AContext.Bounds.Left, LTopY, LRightLineStart, LTopY, LBorderWidth);
      ACanvas.DrawLine(LBorderColor, LTextRect.Right + AContext.LineTextSpacing, LTopY, AContext.Bounds.Right - 1, LTopY, LBorderWidth);
    end
    else
    begin
      LTextRect := Rect(AContext.Bounds.Left + AContext.TextLeft, AContext.Bounds.Top,
        AContext.Bounds.Left + AContext.TextLeft + LTextSize.cx, AContext.Bounds.Top + LTextSize.cy);
      ACanvas.DrawLine(LBorderColor, AContext.Bounds.Left, LTopY, LLeftLineEnd, LTopY, LBorderWidth);
      ACanvas.DrawLine(LBorderColor, LTextRect.Right + AContext.LineTextSpacing, LTopY, AContext.Bounds.Right - 1, LTopY, LBorderWidth);
    end;
    ACanvas.FillRectangle(LBackColor, LTextRect);
    ACanvas.DrawText(AContext.Caption, AContext.Font, LForeColor, LTextRect, LTextFlags);
  end
  else
    ACanvas.DrawLine(LBorderColor, AContext.Bounds.Left, LTopY, AContext.Bounds.Right - 1, LTopY, LBorderWidth);
  ACanvas.DrawLine(LBorderColor, AContext.Bounds.Left, LTopY, AContext.Bounds.Left, AContext.Bounds.Bottom - 1, LBorderWidth);
  ACanvas.DrawLine(LBorderColor, AContext.Bounds.Right - 1, LTopY, AContext.Bounds.Right - 1, AContext.Bounds.Bottom - 1, LBorderWidth);
  ACanvas.DrawLine(LBorderColor, AContext.Bounds.Left, AContext.Bounds.Bottom - 1, AContext.Bounds.Right - 1, AContext.Bounds.Bottom - 1, LBorderWidth);
end;

end.

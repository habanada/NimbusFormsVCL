{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.ListBox;

interface

uses
  System.Types,
  Vcl.Graphics,
  NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Canvas;

type
  TThemedListBoxItemRenderContext = record
    Bounds: TRect;
    Text: string;
    Font: TFont;
    Palette: TThemePalette;
    BackColor: TColor;
    ForeColor: TColor;
    Selected: Boolean;
    Disabled: Boolean;
    Focused: Boolean;
    TextPadding: Integer;
    RightToLeft: Boolean;
  end;

  TThemedListBoxRenderer = class
  public
    class procedure RenderItem(const ACanvas: INimbusRenderCanvas; const AContext: TThemedListBoxItemRenderContext); static;
  end;

implementation

uses
  System.UITypes,
  NimbusForms.Theming.Types,
  NimbusForms.Rendering.Types;

class procedure TThemedListBoxRenderer.RenderItem(const ACanvas: INimbusRenderCanvas; const AContext: TThemedListBoxItemRenderContext);
var
  LBackColor, LForeColor, LFocusColor: TThemeColor;
  LTextRect, LFocusRect: TRect;
  LFlags: TNimbusTextFlags;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(AContext.Bounds) then
    Exit;
  if AContext.Palette <> nil then
  begin
    LBackColor := AContext.Palette.InputBackColor;
    LForeColor := AContext.Palette.InputForeColor;
    LFocusColor := AContext.Palette.FocusBorderColor;
  end
  else
  begin
    LBackColor := ColorToThemeColor(AContext.BackColor);
    LForeColor := ColorToThemeColor(AContext.ForeColor);
    LFocusColor := ColorToThemeColor(clHighlight);
  end;
  if AContext.Selected then
  begin
    if AContext.Palette <> nil then
    begin
      LBackColor := AContext.Palette.SelectedBackColor;
      LForeColor := AContext.Palette.SelectedForeColor;
    end
    else
    begin
      LBackColor := ColorToThemeColor(clHighlight);
      LForeColor := ColorToThemeColor(clHighlightText);
    end;
  end;
  if AContext.Disabled then
  begin
    if AContext.Palette <> nil then
      LForeColor := AContext.Palette.DisabledForeColor
    else
      LForeColor := ColorToThemeColor(clGrayText);
  end;
  ACanvas.FillRectangle(LBackColor, AContext.Bounds);
  LTextRect := AContext.Bounds;
  Inc(LTextRect.Left, AContext.TextPadding);
  Dec(LTextRect.Right, AContext.TextPadding);
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
    ACanvas.DrawFocusRectangle(LFocusColor, LFocusRect);
  end;
end;

end.

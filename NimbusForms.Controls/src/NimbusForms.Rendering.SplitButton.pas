{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.SplitButton;

interface

uses
  Winapi.Windows,
  System.Types,
  Vcl.Graphics,
  NimbusForms.Theming.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Types,
  NimbusForms.Rendering.Canvas;

type
  TThemedSplitButtonRenderContext = record
    Bounds: TRect;
    MainBounds: TRect;
    SplitBounds: TRect;
    Caption: string;
    Font: TFont;
    Palette: TThemePalette;
    IconHandle: HICON;
    IconWidth: Integer;
    IconHeight: Integer;
    ArrowWidth: Integer;
    ArrowHeight: Integer;
    TextPadding: Integer;
    FocusPadding: Integer;
    Enabled: Boolean;
    HoverMain: Boolean;
    HoverSplit: Boolean;
    PressedMain: Boolean;
    PressedSplit: Boolean;
    Focused: Boolean;
    RightToLeft: Boolean;
  end;

  TThemedSplitButtonRenderer = class
  public
    class procedure Render(const ACanvas: INimbusRenderCanvas; const AContext: TThemedSplitButtonRenderContext); static;
  end;

implementation

class procedure TThemedSplitButtonRenderer.Render(const ACanvas: INimbusRenderCanvas; const AContext: TThemedSplitButtonRenderContext);
var
  LBack, LFore, LBorder, LHover, LPressed: TThemeColor;
  LTextRect, LImageRect, LFocusRect: TRect;
  LTextFlags: TNimbusTextFlags;
  LArrowX, LArrowY: Integer;
  LPoint1, LPoint2, LPoint3: TPoint;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(AContext.Bounds) then Exit;
  LBack := NimbusControlBackColor(AContext.Palette);
  LFore := NimbusControlForeColor(AContext.Palette);
  LBorder := NimbusControlBorderColor(AContext.Palette);
  LHover := NimbusHoverBackColor(AContext.Palette);
  LPressed := NimbusPressedBackColor(AContext.Palette);
  if not AContext.Enabled then
  begin
    LBack := NimbusDisabledBackColor(AContext.Palette);
    LFore := NimbusDisabledForeColor(AContext.Palette);
  end;
  ACanvas.FillRectangle(LBack, AContext.Bounds);
  if AContext.Enabled then
  begin
    if AContext.PressedMain then ACanvas.FillRectangle(LPressed, AContext.MainBounds)
    else if AContext.HoverMain then ACanvas.FillRectangle(LHover, AContext.MainBounds);
    if AContext.PressedSplit then ACanvas.FillRectangle(LPressed, AContext.SplitBounds)
    else if AContext.HoverSplit then ACanvas.FillRectangle(LHover, AContext.SplitBounds);
  end;
  ACanvas.DrawRectangle(LBorder, AContext.Bounds, 1.0);
  if not NimbusRectIsEmpty(AContext.SplitBounds) then
    ACanvas.DrawLine(LBorder, AContext.SplitBounds.Left, AContext.SplitBounds.Top, AContext.SplitBounds.Left, AContext.SplitBounds.Bottom - 1, 1.0);
  LTextRect := AContext.MainBounds;
  InflateRect(LTextRect, -AContext.TextPadding, -AContext.TextPadding);
  LTextFlags := [ntfCenter, ntfVCenter, ntfSingleLine, ntfEndEllipsis];
  if AContext.RightToLeft then Include(LTextFlags, ntfRightToLeft);
  ACanvas.DrawText(AContext.Caption, AContext.Font, LFore, LTextRect, LTextFlags);
  if (AContext.IconHandle <> 0) and (AContext.IconWidth > 0) and (AContext.IconHeight > 0) then
  begin
    LImageRect.Left := AContext.MainBounds.Left + (AContext.MainBounds.Width - AContext.IconWidth) div 2;
    LImageRect.Top := AContext.MainBounds.Top + (AContext.MainBounds.Height - AContext.IconHeight) div 2;
    LImageRect.Right := LImageRect.Left + AContext.IconWidth;
    LImageRect.Bottom := LImageRect.Top + AContext.IconHeight;
    ACanvas.DrawIcon(AContext.IconHandle, LImageRect);
  end;
  if not NimbusRectIsEmpty(AContext.SplitBounds) then
  begin
    LArrowX := AContext.SplitBounds.Left + (AContext.SplitBounds.Width - AContext.ArrowWidth) div 2;
    LArrowY := AContext.SplitBounds.Top + (AContext.SplitBounds.Height - AContext.ArrowHeight) div 2;
    LPoint1 := Point(LArrowX, LArrowY);
    LPoint2 := Point(LArrowX + AContext.ArrowWidth, LArrowY);
    LPoint3 := Point(LArrowX + AContext.ArrowWidth div 2, LArrowY + AContext.ArrowHeight);
    ACanvas.FillTriangle(LFore, LPoint1, LPoint2, LPoint3);
  end;
  if AContext.Focused and AContext.Enabled then
  begin
    LFocusRect := AContext.MainBounds;
    InflateRect(LFocusRect, -AContext.FocusPadding, -AContext.FocusPadding);
    if not NimbusRectIsEmpty(LFocusRect) then ACanvas.DrawDashedRectangle(NimbusFocusBorderColor(AContext.Palette), LFocusRect, 1.0);
  end;
end;

end.

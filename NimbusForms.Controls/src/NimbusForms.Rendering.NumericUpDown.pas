{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.NumericUpDown;

interface

uses
  System.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Canvas;

type
  TThemedNumericUpDownRenderContext = record
    Bounds: TRect;
    Palette: TThemePalette;
    BorderThickness: Integer;
    ButtonWidth: Integer;
    Enabled: Boolean;
    Focused: Boolean;
    Hovered: Boolean;
    HoverUp: Boolean;
    HoverDown: Boolean;
    PressedUp: Boolean;
    PressedDown: Boolean;
  end;

  TThemedNumericUpDownRenderer = class
  public
    class function CalculateUpRect(const AContext: TThemedNumericUpDownRenderContext): TRect; static;
    class function CalculateDownRect(const AContext: TThemedNumericUpDownRenderContext): TRect; static;
    class procedure Render(const ACanvas: INimbusRenderCanvas; const AContext: TThemedNumericUpDownRenderContext); static;
  end;

implementation

uses
  System.Math,
  NimbusForms.Theming.Types,
  NimbusForms.Rendering.Types;

class function TThemedNumericUpDownRenderer.CalculateUpRect(const AContext: TThemedNumericUpDownRenderContext): TRect;
var
  LBorder, LButtonWidth, LHeight: Integer;
begin
  LBorder := Max(1, AContext.BorderThickness);
  LButtonWidth := Max(1, AContext.ButtonWidth);
  LHeight := (AContext.Bounds.Height - LBorder * 2) div 2;
  if LHeight < 1 then LHeight := 1;
  Result := Rect(AContext.Bounds.Right - LButtonWidth - LBorder, AContext.Bounds.Top + LBorder,
    AContext.Bounds.Right - LBorder, AContext.Bounds.Top + LBorder + LHeight);
end;

class function TThemedNumericUpDownRenderer.CalculateDownRect(const AContext: TThemedNumericUpDownRenderContext): TRect;
var
  LUp: TRect;
  LBorder: Integer;
begin
  LBorder := Max(1, AContext.BorderThickness);
  LUp := CalculateUpRect(AContext);
  Result := Rect(LUp.Left, LUp.Bottom, LUp.Right, AContext.Bounds.Bottom - LBorder);
end;

class procedure TThemedNumericUpDownRenderer.Render(const ACanvas: INimbusRenderCanvas; const AContext: TThemedNumericUpDownRenderContext);
var
  LBorderColor, LBackColor, LArrowColor, LUpColor, LDownColor: TThemeColor;
  LUp, LDown: TRect;
  LCX, LCY, LHalfWidth, LHalfHeight: Integer;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(AContext.Bounds) then
    Exit;
  if AContext.Enabled then
  begin
    LBackColor := NimbusInputBackColor(AContext.Palette);
    LArrowColor := NimbusInputForeColor(AContext.Palette);
    if AContext.Focused then LBorderColor := NimbusFocusBorderColor(AContext.Palette)
    else if AContext.Hovered then LBorderColor := NimbusControlBorderColor(AContext.Palette)
    else LBorderColor := NimbusInputBorderColor(AContext.Palette);
  end
  else
  begin
    LBackColor := NimbusDisabledBackColor(AContext.Palette);
    LArrowColor := NimbusDisabledForeColor(AContext.Palette);
    LBorderColor := NimbusControlBorderColor(AContext.Palette);
  end;
  LUpColor := LBackColor;
  LDownColor := LBackColor;
  if AContext.Enabled then
  begin
    if AContext.PressedUp then LUpColor := NimbusPressedBackColor(AContext.Palette)
    else if AContext.HoverUp then LUpColor := NimbusHoverBackColor(AContext.Palette);
    if AContext.PressedDown then LDownColor := NimbusPressedBackColor(AContext.Palette)
    else if AContext.HoverDown then LDownColor := NimbusHoverBackColor(AContext.Palette);
  end;
  ACanvas.FillRectangle(LBackColor, AContext.Bounds);
  ACanvas.DrawRectangle(LBorderColor, AContext.Bounds, Max(1, AContext.BorderThickness));
  LUp := CalculateUpRect(AContext);
  LDown := CalculateDownRect(AContext);
  ACanvas.FillRectangle(LUpColor, LUp);
  ACanvas.FillRectangle(LDownColor, LDown);
  ACanvas.DrawLine(LBorderColor, LUp.Left, LUp.Top, LUp.Left, LDown.Bottom, 1.0);
  ACanvas.DrawLine(LBorderColor, LDown.Left, LDown.Top, LDown.Right, LDown.Top, 1.0);
  LHalfWidth := Max(2, Min(LUp.Width, LUp.Height) div 5);
  LHalfHeight := Max(1, LHalfWidth div 2);
  LCX := LUp.Left + LUp.Width div 2;
  LCY := LUp.Top + LUp.Height div 2;
  ACanvas.FillTriangle(LArrowColor, Point(LCX - LHalfWidth, LCY + LHalfHeight), Point(LCX + LHalfWidth, LCY + LHalfHeight), Point(LCX, LCY - LHalfHeight));
  LCX := LDown.Left + LDown.Width div 2;
  LCY := LDown.Top + LDown.Height div 2;
  ACanvas.FillTriangle(LArrowColor, Point(LCX - LHalfWidth, LCY - LHalfHeight), Point(LCX + LHalfWidth, LCY - LHalfHeight), Point(LCX, LCY + LHalfHeight));
end;

end.

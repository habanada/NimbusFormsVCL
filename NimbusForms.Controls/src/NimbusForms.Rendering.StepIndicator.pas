{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.StepIndicator;

interface

uses
  System.Types, Winapi.Windows, Vcl.Graphics, NimbusForms.Theming.Palette, NimbusForms.Rendering.Canvas;

type
  TThemedStepDensity = (tsdNormal, tsdCompact, tsdUltraCompact);
  TThemedStepStatus = (tssAutomatic, tssPending, tssActive, tssCompleted, tssWarning, tssFailed);
  TThemedStepRenderItem = record
    Caption: string;
    Status: TThemedStepStatus;
  end;
  TThemedStepRenderContext = record
    Bounds: TRect;
    Palette: TThemePalette;
    Font: TFont;
    Items: TArray<TThemedStepRenderItem>;
    CurrentStep: Integer;
    CircleSize: Integer;
    LineThickness: Integer;
    Density: TThemedStepDensity;
    Enabled: Boolean;
    ShowCaptions: Boolean;
    Focused: Boolean;
  end;
  TThemedStepIndicatorRenderer = class
  public
    class procedure Render(const ACanvas: INimbusRenderCanvas; const AContext: TThemedStepRenderContext); static;
  end;

implementation

uses
  System.SysUtils, System.Math, NimbusForms.Theming.Types, NimbusForms.Rendering.Types;

class procedure TThemedStepIndicatorRenderer.Render(const ACanvas: INimbusRenderCanvas; const AContext: TThemedStepRenderContext);
var I, LCount, LPad, LRadius, LX, LY, LX2, LSize, LGap: Integer;
    LAccent, LBack, LBorder, LFore, LFill, LStroke, LText, LLink: TThemeColor;
    LStatus: TThemedStepStatus;
    LCircle, LTextRect: TRect;
    LNumber: string;
begin
  if (ACanvas = nil) or (Length(AContext.Items) = 0) then Exit;
  LCount := Length(AContext.Items);
  LSize := AContext.CircleSize;
  LRadius := LSize div 2;
  LPad := Max(LRadius + 3, 12);
  LY := AContext.Bounds.Top + 7 + LRadius;
  LGap := Max(2, LSize div 4);
  LAccent := NimbusAccentColor(AContext.Palette);
  LBack := NimbusControlBackColor(AContext.Palette);
  LBorder := NimbusControlBorderColor(AContext.Palette);
  LFore := NimbusControlForeColor(AContext.Palette);
  if not AContext.Enabled then
  begin
    LAccent := NimbusDisabledForeColor(AContext.Palette);
    LFore := LAccent;
  end;
  for I := 0 to LCount - 2 do
  begin
    LX := AContext.Bounds.Left + LPad + MulDiv(Max(0, AContext.Bounds.Width - 2 * LPad), I, LCount - 1);
    LX2 := AContext.Bounds.Left + LPad + MulDiv(Max(0, AContext.Bounds.Width - 2 * LPad), I + 1, LCount - 1);
    LLink := LBorder;
    if I < AContext.CurrentStep then LLink := LAccent;
    if LX2 - LX > LSize then ACanvas.DrawLine(LLink, LX + LRadius, LY, LX2 - LRadius, LY, AContext.LineThickness);
  end;
  for I := 0 to LCount - 1 do
  begin
    if LCount = 1 then LX := AContext.Bounds.Left + AContext.Bounds.Width div 2
    else LX := AContext.Bounds.Left + LPad + MulDiv(Max(0, AContext.Bounds.Width - 2 * LPad), I, LCount - 1);
    LCircle := Rect(LX - LRadius, LY - LRadius, LX - LRadius + LSize, LY - LRadius + LSize);
    LStatus := AContext.Items[I].Status;
    if LStatus = tssAutomatic then
    begin
      if I < AContext.CurrentStep then LStatus := tssCompleted
      else if I = AContext.CurrentStep then LStatus := tssActive
      else LStatus := tssPending;
    end;
    LFill := LBack;
    LStroke := LBorder;
    LText := LFore;
    case LStatus of
      tssActive, tssCompleted: begin LFill := LAccent; LStroke := LAccent; LText := NimbusSelectedForeColor(AContext.Palette); end;
      tssWarning: begin LFill := NimbusWarningColor; LStroke := NimbusWarningColor; LText := TThemeColor($FF171717); end;
      tssFailed: begin LFill := NimbusDangerColor; LStroke := NimbusDangerColor; LText := TThemeColor($FFFFFFFF); end;
    end;
    if not AContext.Enabled then begin LFill := NimbusDisabledBackColor(AContext.Palette); LStroke := NimbusDisabledForeColor(AContext.Palette); LText := NimbusDisabledForeColor(AContext.Palette); end;
    ACanvas.FillEllipse(LFill, LCircle);
    ACanvas.DrawEllipse(LStroke, LCircle, Max(1, AContext.LineThickness));
    if AContext.Focused and (I = AContext.CurrentStep) then ACanvas.DrawEllipse(NimbusFocusBorderColor(AContext.Palette), Rect(LCircle.Left - 2, LCircle.Top - 2, LCircle.Right + 2, LCircle.Bottom + 2), 1);
    if AContext.Density = tsdUltraCompact then
    begin
      if LStatus = tssFailed then
      begin
        ACanvas.DrawLine(LText, LX - 2, LY - 2, LX + 2, LY + 2, 1.4);
        ACanvas.DrawLine(LText, LX - 2, LY + 2, LX + 2, LY - 2, 1.4);
      end
      else if LStatus = tssWarning then ACanvas.DrawLine(LText, LX, LY - 3, LX, LY + 1, 1.5)
      else if LStatus = tssCompleted then ACanvas.FillEllipse(LText, Rect(LX - 2, LY - 2, LX + 2, LY + 2));
    end
    else
    begin
      LNumber := IntToStr(I + 1);
      if LStatus = tssFailed then LNumber := '!'
      else if LStatus = tssWarning then LNumber := '!';
      ACanvas.DrawText(LNumber, AContext.Font, LText, LCircle, [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix]);
    end;
    if AContext.ShowCaptions and (AContext.Density <> tsdUltraCompact) and (AContext.Items[I].Caption <> '') then
    begin
      LTextRect := Rect(LX - Max(15, AContext.Bounds.Width div Max(2, LCount * 2)), LCircle.Bottom + LGap, LX + Max(15, AContext.Bounds.Width div Max(2, LCount * 2)), AContext.Bounds.Bottom);
      ACanvas.DrawText(AContext.Items[I].Caption, AContext.Font, LFore, LTextRect, [ntfCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix]);
    end;
  end;
end;

end.

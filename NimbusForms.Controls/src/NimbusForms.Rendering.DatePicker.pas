{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.DatePicker;

interface

uses
  System.Types,
  Vcl.Graphics,
  NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Canvas;

type
  TDatePickerDayRects = array[0..41] of TRect;
  TDatePickerDayDates = array[0..41] of TDateTime;
  TDatePickerDayNames = array[0..6] of string;

  TThemedDatePickerRenderContext = record
    Bounds: TRect;
    Font: TFont;
    Palette: TThemePalette;
    Enabled: Boolean;
    Hovered: Boolean;
    Focused: Boolean;
    DroppedDown: Boolean;
    BorderThickness: Integer;
    FormattedText: string;
    RightToLeft: Boolean;
    PPI: Integer;
  end;

  TThemedDatePickerCalendarRenderContext = record
    Bounds: TRect;
    Font: TFont;
    BoldFont: TFont;
    Palette: TThemePalette;
    MonthTitle: string;
    DayNames: TDatePickerDayNames;
    DayRects: TDatePickerDayRects;
    DayDates: TDatePickerDayDates;
    SelectedDate: TDateTime;
    ViewMonth: TDateTime;
    MinDate: TDateTime;
    MaxDate: TDateTime;
    PrevYearRect: TRect;
    PrevMonthRect: TRect;
    NextMonthRect: TRect;
    NextYearRect: TRect;
    HourUpRect: TRect;
    HourDownRect: TRect;
    MinuteUpRect: TRect;
    MinuteDownRect: TRect;
    TodayRect: TRect;
    ConfirmRect: TRect;
    HoveredDayIndex: Integer;
    HoverPrevYear: Boolean;
    HoverPrevMonth: Boolean;
    HoverNextMonth: Boolean;
    HoverNextYear: Boolean;
    HourUpHover: Boolean;
    HourDownHover: Boolean;
    MinuteUpHover: Boolean;
    MinuteDownHover: Boolean;
    TodayHover: Boolean;
    ConfirmHover: Boolean;
    PrevYearEnabled: Boolean;
    PrevMonthEnabled: Boolean;
    NextMonthEnabled: Boolean;
    NextYearEnabled: Boolean;
    HourUpEnabled: Boolean;
    HourDownEnabled: Boolean;
    MinuteUpEnabled: Boolean;
    MinuteDownEnabled: Boolean;
    TodayEnabled: Boolean;
    RightToLeft: Boolean;
    ShowTime: Boolean;
    ShowTodayButton: Boolean;
    ShowConfirmButton: Boolean;
    HourText: string;
    MinuteText: string;
    TodayText: string;
    ConfirmText: string;
    PPI: Integer;
  end;

  TThemedDatePickerRenderer = class
  private
    class procedure DrawCalendarIcon(const ACanvas: INimbusRenderCanvas; const ARect: TRect; const AColor: Cardinal; const APPI: Integer); static;
    class procedure DrawArrow(const ACanvas: INimbusRenderCanvas; const ARect: TRect; const AColor: Cardinal; const ALeft: Boolean; const ADouble: Boolean; const APPI: Integer); static;
    class procedure DrawMiniArrow(const ACanvas: INimbusRenderCanvas; const ARect: TRect; const AColor: Cardinal; const AUp: Boolean; const APPI: Integer); static;
    class procedure DrawButton(const ACanvas: INimbusRenderCanvas; const ARect: TRect; const AText: string; const AHovered, AEnabled, ARightToLeft: Boolean; const AFont: TFont; const AForeColor, AAccentColor, AHoverColor, ABorderColor, ADisabledColor: Cardinal); static;
  public
    class procedure RenderPicker(const ACanvas: INimbusRenderCanvas; const AContext: TThemedDatePickerRenderContext); static;
    class procedure RenderCalendar(const ACanvas: INimbusRenderCanvas; const AContext: TThemedDatePickerCalendarRenderContext); static;
  end;

implementation

uses
  Winapi.Windows,
  System.SysUtils,
  System.DateUtils,
  NimbusForms.Theming.Types,
  NimbusForms.Rendering.Types;


function PickColor(const ACondition: Boolean; const ATrueColor, AFalseColor: TThemeColor): TThemeColor; inline;
begin
  if ACondition then Result := ATrueColor else Result := AFalseColor;
end;

class procedure TThemedDatePickerRenderer.DrawCalendarIcon(const ACanvas: INimbusRenderCanvas; const ARect: TRect; const AColor: Cardinal; const APPI: Integer);
var
  LSize, LX, LY, LTopOffset, LBindingOffset, LHeaderOffset: Integer;
  LBody: TRect;
begin
  LSize := NimbusScaleValue(12, APPI);
  LX := ARect.Left + (ARect.Width - LSize) div 2;
  LY := ARect.Top + (ARect.Height - LSize) div 2;
  LTopOffset := NimbusScaleValue(2, APPI);
  LBindingOffset := NimbusScaleValue(3, APPI);
  LHeaderOffset := NimbusScaleValue(6, APPI);
  LBody := Rect(LX, LY + LTopOffset, LX + LSize + 1, LY + LSize + 1);
  ACanvas.DrawRectangle(TThemeColor(AColor), LBody, 1.5);
  ACanvas.DrawLine(TThemeColor(AColor), LX + LBindingOffset, LY, LX + LBindingOffset, LY + NimbusScaleValue(4, APPI), 1.5);
  ACanvas.DrawLine(TThemeColor(AColor), LX + LSize - LBindingOffset, LY, LX + LSize - LBindingOffset, LY + NimbusScaleValue(4, APPI), 1.5);
  ACanvas.DrawLine(TThemeColor(AColor), LX, LY + LHeaderOffset, LX + LSize, LY + LHeaderOffset, 1.5);
end;

class procedure TThemedDatePickerRenderer.DrawArrow(const ACanvas: INimbusRenderCanvas; const ARect: TRect; const AColor: Cardinal; const ALeft, ADouble: Boolean; const APPI: Integer);
var
  LCenterX, LCenterY, LDX, LDY, LOffset, I, LX: Integer;
begin
  LCenterX := (ARect.Left + ARect.Right) div 2;
  LCenterY := (ARect.Top + ARect.Bottom) div 2;
  LDX := NimbusScaleValue(3, APPI);
  LDY := NimbusScaleValue(4, APPI);
  if ADouble then LOffset := NimbusScaleValue(4, APPI) else LOffset := 0;
  for I := 0 to Ord(ADouble) do
  begin
    if ADouble then LX := LCenterX - LOffset div 2 + I * LOffset else LX := LCenterX;
    if ALeft then
    begin
      ACanvas.DrawLine(TThemeColor(AColor), LX + LDX, LCenterY - LDY, LX - LDX, LCenterY, 1.6);
      ACanvas.DrawLine(TThemeColor(AColor), LX - LDX, LCenterY, LX + LDX, LCenterY + LDY, 1.6);
    end
    else
    begin
      ACanvas.DrawLine(TThemeColor(AColor), LX - LDX, LCenterY - LDY, LX + LDX, LCenterY, 1.6);
      ACanvas.DrawLine(TThemeColor(AColor), LX + LDX, LCenterY, LX - LDX, LCenterY + LDY, 1.6);
    end;
  end;
end;

class procedure TThemedDatePickerRenderer.DrawMiniArrow(const ACanvas: INimbusRenderCanvas; const ARect: TRect; const AColor: Cardinal; const AUp: Boolean; const APPI: Integer);
var
  LCenterX, LCenterY, LDX, LDY: Integer;
begin
  LCenterX := (ARect.Left + ARect.Right) div 2;
  LCenterY := (ARect.Top + ARect.Bottom) div 2;
  LDX := NimbusScaleValue(3, APPI);
  LDY := NimbusScaleValue(2, APPI);
  if AUp then
  begin
    ACanvas.DrawLine(TThemeColor(AColor), LCenterX - LDX, LCenterY + LDY, LCenterX, LCenterY - LDY, 1.3);
    ACanvas.DrawLine(TThemeColor(AColor), LCenterX, LCenterY - LDY, LCenterX + LDX, LCenterY + LDY, 1.3);
  end
  else
  begin
    ACanvas.DrawLine(TThemeColor(AColor), LCenterX - LDX, LCenterY - LDY, LCenterX, LCenterY + LDY, 1.3);
    ACanvas.DrawLine(TThemeColor(AColor), LCenterX, LCenterY + LDY, LCenterX + LDX, LCenterY - LDY, 1.3);
  end;
end;

class procedure TThemedDatePickerRenderer.DrawButton(const ACanvas: INimbusRenderCanvas; const ARect: TRect; const AText: string; const AHovered, AEnabled, ARightToLeft: Boolean; const AFont: TFont; const AForeColor, AAccentColor, AHoverColor, ABorderColor, ADisabledColor: Cardinal);
var
  LBack, LBorder, LFore: TThemeColor;
  LFlags: TNimbusTextFlags;
begin
  if NimbusRectIsEmpty(ARect) then Exit;
  if AEnabled and AHovered then
  begin
    LBack := TThemeColor(AHoverColor);
    LBorder := TThemeColor(AAccentColor);
  end
  else
  begin
    LBack := ThemeColor(0, 0, 0, 0);
    LBorder := TThemeColor(ABorderColor);
  end;
  if AEnabled then LFore := TThemeColor(AForeColor) else LFore := TThemeColor(ADisabledColor);
  if ThemeColorAlpha(LBack) <> 0 then ACanvas.FillRectangle(LBack, ARect);
  ACanvas.DrawRectangle(LBorder, ARect, 1.0);
  LFlags := [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix, ntfEndEllipsis];
  if ARightToLeft then Include(LFlags, ntfRightToLeft);
  ACanvas.DrawText(AText, AFont, LFore, ARect, LFlags);
end;

class procedure TThemedDatePickerRenderer.RenderPicker(const ACanvas: INimbusRenderCanvas; const AContext: TThemedDatePickerRenderContext);
var
  LBack, LFore, LBorder: TThemeColor;
  LTextRect, LIconRect, LBorderRect: TRect;
  LIconWidth, LTextInset, LRightInset: Integer;
  LFlags: TNimbusTextFlags;
begin
  if not AContext.Enabled then
  begin
    LBack := NimbusDisabledBackColor(AContext.Palette);
    LFore := NimbusDisabledForeColor(AContext.Palette);
    LBorder := NimbusInputBorderColor(AContext.Palette);
  end
  else
  begin
    LBack := NimbusInputBackColor(AContext.Palette);
    LFore := NimbusInputForeColor(AContext.Palette);
    if AContext.Focused or AContext.DroppedDown then LBorder := NimbusFocusBorderColor(AContext.Palette)
    else if AContext.Hovered then LBorder := NimbusControlBorderColor(AContext.Palette)
    else LBorder := NimbusInputBorderColor(AContext.Palette);
  end;
  ACanvas.FillRectangle(LBack, AContext.Bounds);
  LBorderRect := AContext.Bounds;
  if AContext.BorderThickness > 1 then
  begin
    Inc(LBorderRect.Left, AContext.BorderThickness div 2);
    Inc(LBorderRect.Top, AContext.BorderThickness div 2);
    Dec(LBorderRect.Right, AContext.BorderThickness div 2);
    Dec(LBorderRect.Bottom, AContext.BorderThickness div 2);
  end;
  if AContext.BorderThickness > 0 then ACanvas.DrawRectangle(LBorder, LBorderRect, AContext.BorderThickness);
  LIconWidth := NimbusScaleValue(28, AContext.PPI);
  LTextInset := NimbusScaleValue(7, AContext.PPI);
  LRightInset := NimbusScaleValue(2, AContext.PPI);
  LTextRect := AContext.Bounds;
  if AContext.RightToLeft then
  begin
    LIconRect := Rect(AContext.Bounds.Left, AContext.Bounds.Top, AContext.Bounds.Left + LIconWidth, AContext.Bounds.Bottom);
    LTextRect.Left := LIconRect.Right + LRightInset;
    LTextRect.Right := AContext.Bounds.Right - LTextInset;
    LFlags := [ntfRight, ntfVCenter, ntfSingleLine, ntfNoPrefix, ntfEndEllipsis, ntfRightToLeft];
  end
  else
  begin
    LIconRect := Rect(AContext.Bounds.Right - LIconWidth, AContext.Bounds.Top, AContext.Bounds.Right, AContext.Bounds.Bottom);
    LTextRect.Left := AContext.Bounds.Left + LTextInset;
    LTextRect.Right := LIconRect.Left - LRightInset;
    LFlags := [ntfVCenter, ntfSingleLine, ntfNoPrefix, ntfEndEllipsis];
  end;
  ACanvas.DrawText(AContext.FormattedText, AContext.Font, LFore, LTextRect, LFlags);
  DrawCalendarIcon(ACanvas, LIconRect, Cardinal(LFore), AContext.PPI);
end;

class procedure TThemedDatePickerRenderer.RenderCalendar(const ACanvas: INimbusRenderCanvas; const AContext: TThemedDatePickerCalendarRenderContext);
var
  LBack, LFore, LAccent, LSelectedFore, LMuted, LHover, LBorder, LDisabled: TThemeColor;
  LHeaderRect, LDayHeader, LRect, LIndicator, LTimeTextRect: TRect;
  I, LCurrentMonth, LSelected, LHovered, LToday, LEnabled: Integer;
  LSeparatorY, LTextY, LTextHeight: Integer;
  LTextColor, LArrowColor: TThemeColor;
  LTextFlags: TNimbusTextFlags;
begin
  LBack := NimbusMenuBackColor(AContext.Palette);
  LFore := NimbusMenuForeColor(AContext.Palette);
  LAccent := NimbusAccentColor(AContext.Palette);
  LSelectedFore := NimbusSelectedForeColor(AContext.Palette);
  LMuted := NimbusMutedForeColor(AContext.Palette);
  LHover := NimbusHoverBackColor(AContext.Palette);
  LBorder := NimbusMenuBorderColor(AContext.Palette);
  LDisabled := NimbusDisabledForeColor(AContext.Palette);
  ACanvas.FillRectangle(LBack, AContext.Bounds);
  ACanvas.DrawRectangle(LBorder, AContext.Bounds, 1.0);
  LHeaderRect := Rect(AContext.Bounds.Left + NimbusScaleValue(58, AContext.PPI), AContext.Bounds.Top + NimbusScaleValue(5, AContext.PPI), AContext.Bounds.Right - NimbusScaleValue(58, AContext.PPI), AContext.Bounds.Top + NimbusScaleValue(29, AContext.PPI));
  LTextFlags := [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix, ntfEndEllipsis];
  if AContext.RightToLeft then Include(LTextFlags, ntfRightToLeft);
  ACanvas.DrawText(AContext.MonthTitle, AContext.BoldFont, LFore, LHeaderRect, LTextFlags);
  if AContext.PrevYearEnabled then LArrowColor := PickColor(AContext.HoverPrevYear, LAccent, LFore) else LArrowColor := LDisabled;
  DrawArrow(ACanvas, AContext.PrevYearRect, Cardinal(LArrowColor), not AContext.RightToLeft, True, AContext.PPI);
  if AContext.PrevMonthEnabled then LArrowColor := PickColor(AContext.HoverPrevMonth, LAccent, LFore) else LArrowColor := LDisabled;
  DrawArrow(ACanvas, AContext.PrevMonthRect, Cardinal(LArrowColor), not AContext.RightToLeft, False, AContext.PPI);
  if AContext.NextMonthEnabled then LArrowColor := PickColor(AContext.HoverNextMonth, LAccent, LFore) else LArrowColor := LDisabled;
  DrawArrow(ACanvas, AContext.NextMonthRect, Cardinal(LArrowColor), AContext.RightToLeft, False, AContext.PPI);
  if AContext.NextYearEnabled then LArrowColor := PickColor(AContext.HoverNextYear, LAccent, LFore) else LArrowColor := LDisabled;
  DrawArrow(ACanvas, AContext.NextYearRect, Cardinal(LArrowColor), AContext.RightToLeft, True, AContext.PPI);
  for I := 0 to 6 do
  begin
    LDayHeader := AContext.DayRects[I];
    LDayHeader.Top := NimbusScaleValue(35, AContext.PPI);
    LDayHeader.Bottom := LDayHeader.Top + NimbusScaleValue(20, AContext.PPI);
    LTextFlags := [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix, ntfEndEllipsis];
    if AContext.RightToLeft then Include(LTextFlags, ntfRightToLeft);
    ACanvas.DrawText(AContext.DayNames[I], AContext.Font, LMuted, LDayHeader, LTextFlags);
  end;
  for I := 0 to 41 do
  begin
    LRect := AContext.DayRects[I];
    LIndicator := LRect;
    InflateRect(LIndicator, -NimbusScaleValue(4, AContext.PPI), -NimbusScaleValue(4, AContext.PPI));
    LCurrentMonth := Ord((MonthOf(AContext.DayDates[I]) = MonthOf(AContext.ViewMonth)) and (YearOf(AContext.DayDates[I]) = YearOf(AContext.ViewMonth)));
    LSelected := Ord(DateOf(AContext.DayDates[I]) = DateOf(AContext.SelectedDate));
    LHovered := Ord(I = AContext.HoveredDayIndex);
    LToday := Ord(DateOf(AContext.DayDates[I]) = Date);
    LEnabled := Ord((DateOf(AContext.DayDates[I]) >= DateOf(AContext.MinDate)) and (DateOf(AContext.DayDates[I]) <= DateOf(AContext.MaxDate)));
    if LSelected <> 0 then ACanvas.FillEllipse(LAccent, LIndicator)
    else if LHovered <> 0 then ACanvas.FillEllipse(LHover, LIndicator);
    if (LToday <> 0) and (LSelected = 0) then ACanvas.DrawEllipse(LAccent, LIndicator, 1.4);
    if LEnabled = 0 then LTextColor := LDisabled
    else if LSelected <> 0 then LTextColor := LSelectedFore
    else if LCurrentMonth <> 0 then LTextColor := LFore
    else LTextColor := LMuted;
    ACanvas.DrawText(IntToStr(DayOf(AContext.DayDates[I])), AContext.Font, LTextColor, LRect, [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix]);
  end;
  if AContext.ShowTime then
  begin
    LSeparatorY := AContext.HourUpRect.Top - NimbusScaleValue(6, AContext.PPI);
    ACanvas.DrawLine(LBorder, AContext.Bounds.Left + NimbusScaleValue(10, AContext.PPI), LSeparatorY, AContext.Bounds.Right - NimbusScaleValue(10, AContext.PPI), LSeparatorY, 1.0);
    LTextY := AContext.HourUpRect.Top - NimbusScaleValue(3, AContext.PPI);
    LTextHeight := AContext.HourUpRect.Height + AContext.HourDownRect.Height + NimbusScaleValue(7, AContext.PPI);
    if AContext.RightToLeft then
      LTimeTextRect := Rect((AContext.Bounds.Left + AContext.Bounds.Right) div 2 + NimbusScaleValue(12, AContext.PPI), LTextY, (AContext.Bounds.Left + AContext.Bounds.Right) div 2 + NimbusScaleValue(38, AContext.PPI), LTextY + LTextHeight)
    else
      LTimeTextRect := Rect((AContext.Bounds.Left + AContext.Bounds.Right) div 2 - NimbusScaleValue(58, AContext.PPI), LTextY, (AContext.Bounds.Left + AContext.Bounds.Right) div 2 - NimbusScaleValue(32, AContext.PPI), LTextY + LTextHeight);
    ACanvas.DrawText(AContext.HourText, AContext.Font, LFore, LTimeTextRect, [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix]);
    LTimeTextRect := Rect((AContext.Bounds.Left + AContext.Bounds.Right) div 2 - NimbusScaleValue(4, AContext.PPI), LTextY, (AContext.Bounds.Left + AContext.Bounds.Right) div 2 + NimbusScaleValue(4, AContext.PPI), LTextY + LTextHeight);
    ACanvas.DrawText(':', AContext.Font, LFore, LTimeTextRect, [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix]);
    if AContext.RightToLeft then
      LTimeTextRect := Rect((AContext.Bounds.Left + AContext.Bounds.Right) div 2 - NimbusScaleValue(58, AContext.PPI), LTextY, (AContext.Bounds.Left + AContext.Bounds.Right) div 2 - NimbusScaleValue(32, AContext.PPI), LTextY + LTextHeight)
    else
      LTimeTextRect := Rect((AContext.Bounds.Left + AContext.Bounds.Right) div 2 + NimbusScaleValue(12, AContext.PPI), LTextY, (AContext.Bounds.Left + AContext.Bounds.Right) div 2 + NimbusScaleValue(38, AContext.PPI), LTextY + LTextHeight);
    ACanvas.DrawText(AContext.MinuteText, AContext.Font, LFore, LTimeTextRect, [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix]);
    if AContext.HourUpEnabled then LArrowColor := PickColor(AContext.HourUpHover, LAccent, LMuted) else LArrowColor := LDisabled;
    DrawMiniArrow(ACanvas, AContext.HourUpRect, Cardinal(LArrowColor), True, AContext.PPI);
    if AContext.HourDownEnabled then LArrowColor := PickColor(AContext.HourDownHover, LAccent, LMuted) else LArrowColor := LDisabled;
    DrawMiniArrow(ACanvas, AContext.HourDownRect, Cardinal(LArrowColor), False, AContext.PPI);
    if AContext.MinuteUpEnabled then LArrowColor := PickColor(AContext.MinuteUpHover, LAccent, LMuted) else LArrowColor := LDisabled;
    DrawMiniArrow(ACanvas, AContext.MinuteUpRect, Cardinal(LArrowColor), True, AContext.PPI);
    if AContext.MinuteDownEnabled then LArrowColor := PickColor(AContext.MinuteDownHover, LAccent, LMuted) else LArrowColor := LDisabled;
    DrawMiniArrow(ACanvas, AContext.MinuteDownRect, Cardinal(LArrowColor), False, AContext.PPI);
  end;
  if AContext.ShowTodayButton then DrawButton(ACanvas, AContext.TodayRect, AContext.TodayText, AContext.TodayHover, AContext.TodayEnabled, AContext.RightToLeft, AContext.Font, Cardinal(LFore), Cardinal(LAccent), Cardinal(LHover), Cardinal(LBorder), Cardinal(LDisabled));
  if AContext.ShowConfirmButton then DrawButton(ACanvas, AContext.ConfirmRect, AContext.ConfirmText, AContext.ConfirmHover, True, AContext.RightToLeft, AContext.Font, Cardinal(LFore), Cardinal(LAccent), Cardinal(LHover), Cardinal(LBorder), Cardinal(LDisabled));
end;

end.

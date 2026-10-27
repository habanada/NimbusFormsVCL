{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.DatePicker;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.SysUtils,
  System.Types,
  System.UITypes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.AppEvnts,
  NimbusForms.Theming.Palette,
  NimbusForms.Controls.Types,
  NimbusForms.Controls.Base,
  NimbusForms.Rendering.DatePicker;

type
  TThemedDatePickerDayOfWeek = (dpdowSunday, dpdowMonday, dpdowTuesday, dpdowWednesday, dpdowThursday, dpdowFriday, dpdowSaturday);
  TThemedDatePickerDropDownOpeningEvent = procedure(Sender: TObject; var ACancel: Boolean) of object;

  TCustomThemedDatePicker = class;
  TThemedDatePickerCalendar = class;
  TThemedDatePickerPopupForm = class;

  TCustomThemedDatePicker = class(TCustomNimbusControl)
  private
    FValue: TDateTime;
    FMinDate: TDateTime;
    FMaxDate: TDateTime;
    FShowTime: Boolean;
    FCustomFormat: string;
    FCustomFormatExplicitlySet: Boolean;
    FCultureName: string;
    FUseCultureFirstDayOfWeek: Boolean;
    FFirstDayOfWeek: TThemedDatePickerDayOfWeek;
    FMinuteIncrement: Integer;
    FCloseOnDateSelected: Boolean;
    FShowTodayButton: Boolean;
    FShowConfirmButton: Boolean;
    FHovered: Boolean;
    FFocused: Boolean;
    FDroppedDown: Boolean;
    FBorderThickness: Integer;
    FPopup: TThemedDatePickerPopupForm;
    FApplicationEvents: TApplicationEvents;
    FFormatSettings: TFormatSettings;
    FFormatSettingsValid: Boolean;
    FInternalCalendarValueChange: Boolean;
    FOpeningDropDown: Boolean;
    FSynchronizingPopup: Boolean;
    FOnValueChanged: TNotifyEvent;
    FOnDateSelected: TNotifyEvent;
    FOnDateConfirmed: TNotifyEvent;
    FOnDropDownOpening: TThemedDatePickerDropDownOpeningEvent;
    FOnDropDownOpened: TNotifyEvent;
    FOnDropDownClosed: TNotifyEvent;
    procedure SetValue(const AValue: TDateTime);
    procedure SetMinDate(const AValue: TDateTime);
    procedure SetMaxDate(const AValue: TDateTime);
    procedure SetShowTime(const AValue: Boolean);
    procedure SetCustomFormat(const AValue: string);
    procedure SetCultureName(const AValue: string);
    procedure SetUseCultureFirstDayOfWeek(const AValue: Boolean);
    procedure SetFirstDayOfWeek(const AValue: TThemedDatePickerDayOfWeek);
    procedure SetMinuteIncrement(const AValue: Integer);
    procedure SetCloseOnDateSelected(const AValue: Boolean);
    procedure SetShowTodayButton(const AValue: Boolean);
    procedure SetShowConfirmButton(const AValue: Boolean);
    procedure EnsurePopup;
    procedure SynchronizePopup;
    procedure RefreshPopupBounds;
    function GetPopupBounds: TRect;
    function PointInControlScreen(const APoint: TPoint): Boolean;
    function PointInPopupScreen(const APoint: TPoint): Boolean;
    function BuildFormatSettings: TFormatSettings;
    function GetEffectiveFirstDayOfWeek: TThemedDatePickerDayOfWeek;
    function GetFormattedValue: string;
    function ConstrainValue(const AValue: TDateTime): TDateTime;
    procedure ValidateFormat(const AFormat: string);
    procedure InternalSetValue(const AValue: TDateTime; const ADateSelection: Boolean);
    procedure InternalConfirmValue(const AValue: TDateTime);
    procedure ApplicationMessage(var Msg: TMsg; var Handled: Boolean);
    procedure ApplicationDeactivate(Sender: TObject);
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure CMDialogKey(var Message: TCMDialogKey); message CM_DIALOGKEY;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMVisibleChanged(var Message: TMessage); message CM_VISIBLECHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMBiDiModeChanged(var Message: TMessage); message CM_BIDIMODECHANGED;
    procedure CMCancelMode(var Message: TCMCancelMode); message CM_CANCELMODE;
  protected
    procedure StyleModeChanged; override;
    procedure Paint; override;
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure DoValueChanged; virtual;
    procedure DoDateSelected; virtual;
    procedure DoDateConfirmed; virtual;
    procedure DoDropDownOpening(var ACancel: Boolean); virtual;
    procedure DoDropDownOpened; virtual;
    procedure DoDropDownClosed; virtual;
    property Value: TDateTime read FValue write SetValue;
    property MinDate: TDateTime read FMinDate write SetMinDate;
    property MaxDate: TDateTime read FMaxDate write SetMaxDate;
    property ShowTime: Boolean read FShowTime write SetShowTime default False;
    property CustomFormat: string read FCustomFormat write SetCustomFormat;
    property CultureName: string read FCultureName write SetCultureName;
    property UseCultureFirstDayOfWeek: Boolean read FUseCultureFirstDayOfWeek write SetUseCultureFirstDayOfWeek default True;
    property FirstDayOfWeek: TThemedDatePickerDayOfWeek read FFirstDayOfWeek write SetFirstDayOfWeek default dpdowMonday;
    property MinuteIncrement: Integer read FMinuteIncrement write SetMinuteIncrement default 1;
    property CloseOnDateSelected: Boolean read FCloseOnDateSelected write SetCloseOnDateSelected default True;
    property ShowTodayButton: Boolean read FShowTodayButton write SetShowTodayButton default True;
    property ShowConfirmButton: Boolean read FShowConfirmButton write SetShowConfirmButton default True;
    property OnValueChanged: TNotifyEvent read FOnValueChanged write FOnValueChanged;
    property OnDateSelected: TNotifyEvent read FOnDateSelected write FOnDateSelected;
    property OnDateConfirmed: TNotifyEvent read FOnDateConfirmed write FOnDateConfirmed;
    property OnDropDownOpening: TThemedDatePickerDropDownOpeningEvent read FOnDropDownOpening write FOnDropDownOpening;
    property OnDropDownOpened: TNotifyEvent read FOnDropDownOpened write FOnDropDownOpened;
    property OnDropDownClosed: TNotifyEvent read FOnDropDownClosed write FOnDropDownClosed;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette); override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure ShowDropDown;
    procedure CloseDropDown;
    procedure BindAction(const AAction: TBasicAction);
    procedure UnbindAction;
    procedure SyncAction;
    property DroppedDown: Boolean read FDroppedDown;
  end;

  TThemedDatePicker = class(TCustomThemedDatePicker)
  published
    property StyleMode;
    property Action;
    property Align;
    property Anchors;
    property BiDiMode;
    property Constraints;
    property Enabled;
    property Font;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property Value;
    property MinDate;
    property MaxDate;
    property ShowTime;
    property CustomFormat;
    property CultureName;
    property UseCultureFirstDayOfWeek;
    property FirstDayOfWeek;
    property MinuteIncrement;
    property CloseOnDateSelected;
    property ShowTodayButton;
    property ShowConfirmButton;
    property OnClick;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnValueChanged;
    property OnDateSelected;
    property OnDateConfirmed;
    property OnDropDownOpening;
    property OnDropDownOpened;
    property OnDropDownClosed;
  end;

  TThemedDatePickerCalendar = class(TCustomNimbusControl)
  private
    FOwnerPicker: TCustomThemedDatePicker;
    FViewMonth: TDateTime;
    FSelectedDate: TDateTime;
    FMinDate: TDateTime;
    FMaxDate: TDateTime;
    FFormatSettings: TFormatSettings;
    FFirstDayOfWeek: TThemedDatePickerDayOfWeek;
    FShowTime: Boolean;
    FShowTodayButton: Boolean;
    FShowConfirmButton: Boolean;
    FMinuteIncrement: Integer;
    FBoldFont: TFont;
    FDayRects: TDatePickerDayRects;
    FDayDates: TDatePickerDayDates;
    FPrevYearRect: TRect;
    FPrevMonthRect: TRect;
    FNextMonthRect: TRect;
    FNextYearRect: TRect;
    FHourUpRect: TRect;
    FHourDownRect: TRect;
    FMinuteUpRect: TRect;
    FMinuteDownRect: TRect;
    FTodayRect: TRect;
    FConfirmRect: TRect;
    FHoveredDayIndex: Integer;
    FHoverPrevYear: Boolean;
    FHoverPrevMonth: Boolean;
    FHoverNextMonth: Boolean;
    FHoverNextYear: Boolean;
    FHourUpHover: Boolean;
    FHourDownHover: Boolean;
    FMinuteUpHover: Boolean;
    FMinuteDownHover: Boolean;
    FTodayHover: Boolean;
    FConfirmHover: Boolean;
    procedure UpdateBoldFont;
    procedure CalculateLayout;
    function GetColumnRect(const AColumn, AY, AHeight: Integer): TRect;
    function IsDateEnabled(const AValue: TDateTime): Boolean;
    function HitTestDay(const APoint: TPoint): Integer;
    function Constrain(const AValue: TDateTime): TDateTime;
    function CanChangeTime(const AMinutes: Integer): Boolean;
    function CanChangeViewMonth(const AMonths: Integer): Boolean;
    function CanChangeViewYear(const AYears: Integer): Boolean;
    function IsTodayEnabled: Boolean;
    procedure SetSelectedDate(const ADate: TDateTime; const ADateSelection: Boolean);
    procedure ChangeTime(const AMinutes: Integer);
    procedure ChangeViewMonth(const AMonths: Integer);
    procedure ChangeViewYear(const AYears: Integer);
    procedure ClearHover;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMBiDiModeChanged(var Message: TMessage); message CM_BIDIMODECHANGED;
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor CreateForPicker(AOwner: TComponent; APicker: TCustomThemedDatePicker); reintroduce;
    destructor Destroy; override;
    procedure SetState(const ADate: TDateTime; const AShowTime: Boolean; const AMinDate, AMaxDate: TDateTime; const AFormatSettings: TFormatSettings; const AFirstDayOfWeek: TThemedDatePickerDayOfWeek; const AMinuteIncrement: Integer; const AShowTodayButton, AShowConfirmButton: Boolean);
    procedure ProcessKey(var Key: Word; Shift: TShiftState);
    procedure ScrollMonth(const AWheelDelta: Integer);
    function PreferredPopupSize: TSize;
  end;

  TThemedDatePickerPopupForm = class(TForm)
  private
    FCalendar: TThemedDatePickerCalendar;
    FPopupVisible: Boolean;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMMouseActivate(var Message: TWMMouseActivate); message WM_MOUSEACTIVATE;
  public
    constructor CreateForPicker(APicker: TCustomThemedDatePicker); reintroduce;
    procedure ApplyTheme(const APalette: TThemePalette);
    procedure SyncSize;
    procedure ShowPopup(const ABounds: TRect);
    procedure ClosePopup;
    property Calendar: TThemedDatePickerCalendar read FCalendar;
    property PopupVisible: Boolean read FPopupVisible;
  end;

implementation

uses
  System.Math,
  System.DateUtils,
  NimbusForms.Theming.Types,
  NimbusForms.Rendering.Types;

resourcestring
  SDatePickerToday = 'Today';
  SDatePickerConfirm = 'OK';
  SDatePickerInvalidCulture = 'Invalid culture name: %s';
  SDatePickerInvalidMinuteIncrement = 'MinuteIncrement must be between 1 and 59.';
  SDatePickerMinAfterMax = 'MinDate cannot be greater than MaxDate.';
  SDatePickerMaxBeforeMin = 'MaxDate cannot be less than MinDate.';
  SDatePickerDateOutOfRange = 'Date values must be between 01/01/0001 and 12/31/9999.';

const
  CDefaultDateFormat = 'dd.MM.yyyy';
  CDefaultDateTimeFormat = 'dd.MM.yyyy hh:nn';
  CDefaultWidth = 160;
  CDefaultHeight = 28;

function DayOfWeekIndex(const AValue: TThemedDatePickerDayOfWeek): Integer; inline;
begin
  Result := Ord(AValue);
end;

function DatePickerDayOfWeekFromIndex(const AValue: Integer): TThemedDatePickerDayOfWeek; inline;
begin
  Result := TThemedDatePickerDayOfWeek((AValue mod 7 + 7) mod 7);
end;

function SameDateTime(const ALeft, ARight: TDateTime): Boolean; inline;
begin
  Result := ALeft = ARight;
end;

function MinimumSupportedDateTime: TDateTime; inline;
begin
  Result := EncodeDate(1, 1, 1);
end;

function MaximumSupportedDateTime: TDateTime; inline;
begin
  Result := EncodeDate(9999, 12, 31) + EncodeTime(23, 59, 59, 999);
end;

function IsSupportedDateTime(const AValue: TDateTime): Boolean; inline;
begin
  Result := (AValue >= MinimumSupportedDateTime) and (AValue <= MaximumSupportedDateTime);
end;

function SafeIncDay(const AValue: TDateTime; const ADays: Integer): TDateTime;
begin
  try
    Result := IncDay(AValue, ADays);
  except
    on E: EConvertError do if ADays < 0 then Result := EncodeDate(1, 1, 1) else Result := EncodeDate(9999, 12, 31);
  end;
end;

function SafeIncMinute(const AValue: TDateTime; const AMinutes: Integer): TDateTime;
begin
  try
    Result := IncMinute(AValue, AMinutes);
  except
    on E: EConvertError do if AMinutes < 0 then Result := EncodeDate(1, 1, 1) else Result := EncodeDate(9999, 12, 31) + EncodeTime(23, 59, 59, 999);
  end;
end;

function SafeIncMonth(const AValue: TDateTime; const AMonths: Integer): TDateTime;
begin
  try
    Result := IncMonth(AValue, AMonths);
  except
    on E: EConvertError do if AMonths < 0 then Result := EncodeDate(1, 1, 1) else Result := EncodeDate(9999, 12, 31);
  end;
end;

function SafeIncYear(const AValue: TDateTime; const AYears: Integer): TDateTime;
begin
  try
    Result := IncYear(AValue, AYears);
  except
    on E: EConvertError do if AYears < 0 then Result := EncodeDate(1, 1, 1) else Result := EncodeDate(9999, 12, 31);
  end;
end;

constructor TCustomThemedDatePicker.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csCaptureMouse, csClickEvents];
  Width := CDefaultWidth;
  Height := CDefaultHeight;
  TabStop := True;
  Cursor := crHandPoint;
  Font.Name := 'Segoe UI';
  Font.Size := 9;
  FValue := Now;
  FMinDate := MinimumSupportedDateTime;
  FMaxDate := MaximumSupportedDateTime;
  FCustomFormat := CDefaultDateFormat;
  FUseCultureFirstDayOfWeek := True;
  FFirstDayOfWeek := dpdowMonday;
  FMinuteIncrement := 1;
  FCloseOnDateSelected := True;
  FShowTodayButton := True;
  FShowConfirmButton := True;
  FBorderThickness := 1;
  FFormatSettings := TFormatSettings.Create;
  FFormatSettingsValid := True;
  FApplicationEvents := TApplicationEvents.Create(Self);
  FApplicationEvents.OnMessage := ApplicationMessage;
  FApplicationEvents.OnDeactivate := ApplicationDeactivate;
end;

destructor TCustomThemedDatePicker.Destroy;
begin
  if FApplicationEvents <> nil then
  begin
    FApplicationEvents.OnMessage := nil;
    FApplicationEvents.OnDeactivate := nil;
  end;
  FDroppedDown := False;
  if FPopup <> nil then
  begin
    FPopup.ClosePopup;
    FPopup.Free;
    FPopup := nil;
  end;
  inherited Destroy;
end;

procedure TCustomThemedDatePicker.ApplyTheme(const APalette: TThemePalette);
begin
  inherited ApplyTheme(APalette);
  if FPopup <> nil then FPopup.ApplyTheme(Palette);
end;

procedure TCustomThemedDatePicker.StyleModeChanged;
begin
  inherited StyleModeChanged;
  UpdateStyleHeight(CDefaultHeight, 23);
end;

procedure TCustomThemedDatePicker.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  if FDroppedDown then RefreshPopupBounds;
end;

procedure TCustomThemedDatePicker.SetValue(const AValue: TDateTime);
var
  LValue: TDateTime;
begin
  LValue := ConstrainValue(AValue);
  if SameDateTime(FValue, LValue) then Exit;
  FValue := LValue;
  if FDroppedDown and not FInternalCalendarValueChange then SynchronizePopup;
  Invalidate;
  DoValueChanged;
end;

procedure TCustomThemedDatePicker.SetMinDate(const AValue: TDateTime);
begin
  if not IsSupportedDateTime(AValue) then raise EArgumentOutOfRangeException.Create(SDatePickerDateOutOfRange);
  if AValue > FMaxDate then raise EArgumentOutOfRangeException.Create(SDatePickerMinAfterMax);
  if SameDateTime(FMinDate, AValue) then Exit;
  FMinDate := AValue;
  if FValue < FMinDate then Value := FMinDate else if FDroppedDown then SynchronizePopup;
  Invalidate;
end;

procedure TCustomThemedDatePicker.SetMaxDate(const AValue: TDateTime);
begin
  if not IsSupportedDateTime(AValue) then raise EArgumentOutOfRangeException.Create(SDatePickerDateOutOfRange);
  if AValue < FMinDate then raise EArgumentOutOfRangeException.Create(SDatePickerMaxBeforeMin);
  if SameDateTime(FMaxDate, AValue) then Exit;
  FMaxDate := AValue;
  if FValue > FMaxDate then Value := FMaxDate else if FDroppedDown then SynchronizePopup;
  Invalidate;
end;

procedure TCustomThemedDatePicker.SetShowTime(const AValue: Boolean);
begin
  if FShowTime = AValue then Exit;
  FShowTime := AValue;
  if not FCustomFormatExplicitlySet then
    if FShowTime then FCustomFormat := CDefaultDateTimeFormat else FCustomFormat := CDefaultDateFormat;
  if FDroppedDown then SynchronizePopup;
  Invalidate;
end;

procedure TCustomThemedDatePicker.SetCustomFormat(const AValue: string);
var
  LValue, LDefault: string;
begin
  if FShowTime then LDefault := CDefaultDateTimeFormat else LDefault := CDefaultDateFormat;
  LValue := Trim(AValue);
  if LValue = '' then LValue := LDefault;
  ValidateFormat(LValue);
  if FCustomFormat = LValue then Exit;
  FCustomFormat := LValue;
  FCustomFormatExplicitlySet := FCustomFormat <> LDefault;
  Invalidate;
end;

procedure TCustomThemedDatePicker.SetCultureName(const AValue: string);
var
  LValue: string;
  LBuffer: array[0..84] of Char;
  LSettings: TFormatSettings;
begin
  LValue := Trim(AValue);
  if SameText(FCultureName, LValue) then Exit;
  if (LValue <> '') and (GetLocaleInfoEx(PChar(LValue), LOCALE_SNAME, PChar(@LBuffer[0]), Length(LBuffer)) = 0) then
    raise EArgumentException.CreateFmt(SDatePickerInvalidCulture, [LValue]);
  if LValue = '' then LSettings := TFormatSettings.Create else LSettings := TFormatSettings.Create(LValue);
  FCultureName := LValue;
  FFormatSettings := LSettings;
  FFormatSettingsValid := True;
  if FDroppedDown then SynchronizePopup;
  Invalidate;
end;

procedure TCustomThemedDatePicker.SetUseCultureFirstDayOfWeek(const AValue: Boolean);
begin
  if FUseCultureFirstDayOfWeek = AValue then Exit;
  FUseCultureFirstDayOfWeek := AValue;
  if FDroppedDown then SynchronizePopup;
  Invalidate;
end;

procedure TCustomThemedDatePicker.SetFirstDayOfWeek(const AValue: TThemedDatePickerDayOfWeek);
begin
  if FFirstDayOfWeek = AValue then Exit;
  FFirstDayOfWeek := AValue;
  if FDroppedDown then SynchronizePopup;
  Invalidate;
end;

procedure TCustomThemedDatePicker.SetMinuteIncrement(const AValue: Integer);
begin
  if (AValue < 1) or (AValue > 59) then raise EArgumentOutOfRangeException.Create(SDatePickerInvalidMinuteIncrement);
  if FMinuteIncrement = AValue then Exit;
  FMinuteIncrement := AValue;
  if FDroppedDown then SynchronizePopup;
end;

procedure TCustomThemedDatePicker.SetCloseOnDateSelected(const AValue: Boolean);
begin
  if FCloseOnDateSelected = AValue then Exit;
  FCloseOnDateSelected := AValue;
end;

procedure TCustomThemedDatePicker.SetShowTodayButton(const AValue: Boolean);
begin
  if FShowTodayButton = AValue then Exit;
  FShowTodayButton := AValue;
  if FDroppedDown then SynchronizePopup;
end;

procedure TCustomThemedDatePicker.SetShowConfirmButton(const AValue: Boolean);
begin
  if FShowConfirmButton = AValue then Exit;
  FShowConfirmButton := AValue;
  if FDroppedDown then SynchronizePopup;
end;

function TCustomThemedDatePicker.BuildFormatSettings: TFormatSettings;
begin
  if not FFormatSettingsValid then
  begin
    if FCultureName = '' then FFormatSettings := TFormatSettings.Create else FFormatSettings := TFormatSettings.Create(FCultureName);
    FFormatSettingsValid := True;
  end;
  Result := FFormatSettings;
end;

function TCustomThemedDatePicker.GetEffectiveFirstDayOfWeek: TThemedDatePickerDayOfWeek;
var
  LBuffer: array[0..15] of Char;
  LCount, LWindowsIndex: Integer;
  LLocaleName: PChar;
begin
  if not FUseCultureFirstDayOfWeek then Exit(FFirstDayOfWeek);
  if FCultureName = '' then LLocaleName := nil else LLocaleName := PChar(FCultureName);
  FillChar(LBuffer, SizeOf(LBuffer), 0);
  LCount := GetLocaleInfoEx(LLocaleName, LOCALE_IFIRSTDAYOFWEEK, PChar(@LBuffer[0]), Length(LBuffer));
  if LCount <= 0 then Exit(FFirstDayOfWeek);
  LWindowsIndex := StrToIntDef(string(PChar(@LBuffer[0])), 0);
  Result := DatePickerDayOfWeekFromIndex((LWindowsIndex + 1) mod 7);
end;

function TCustomThemedDatePicker.GetFormattedValue: string;
var
  LSettings: TFormatSettings;
begin
  LSettings := BuildFormatSettings;
  try
    Result := FormatDateTime(FCustomFormat, FValue, LSettings);
  except
    on E: EConvertError do
      if FShowTime then Result := FormatDateTime(CDefaultDateTimeFormat, FValue, LSettings)
      else Result := FormatDateTime(CDefaultDateFormat, FValue, LSettings);
  end;
end;

function TCustomThemedDatePicker.ConstrainValue(const AValue: TDateTime): TDateTime;
begin
  if AValue < FMinDate then Result := FMinDate
  else if AValue > FMaxDate then Result := FMaxDate
  else Result := AValue;
end;

procedure TCustomThemedDatePicker.ValidateFormat(const AFormat: string);
var
  LSettings: TFormatSettings;
  LValue: string;
begin
  LSettings := BuildFormatSettings;
  LValue := FormatDateTime(AFormat, Now, LSettings);
  if LValue = '' then Exit;
end;

procedure TCustomThemedDatePicker.EnsurePopup;
begin
  if FPopup <> nil then Exit;
  FPopup := TThemedDatePickerPopupForm.CreateForPicker(Self);
  FPopup.ApplyTheme(Palette);
end;

procedure TCustomThemedDatePicker.SynchronizePopup;
var
  LSettings: TFormatSettings;
begin
  if (FPopup = nil) or FSynchronizingPopup then Exit;
  FSynchronizingPopup := True;
  try
    LSettings := BuildFormatSettings;
    if FPopup.CurrentPPI <> CurrentPPI then FPopup.ScaleForPPI(CurrentPPI);
    FPopup.Calendar.BiDiMode := BiDiMode;
    FPopup.Calendar.Font.Assign(Font);
    FPopup.Calendar.SetState(FValue, FShowTime, FMinDate, FMaxDate, LSettings, GetEffectiveFirstDayOfWeek, FMinuteIncrement, FShowTodayButton, FShowConfirmButton);
    FPopup.SyncSize;
    if FDroppedDown then RefreshPopupBounds;
  finally
    FSynchronizingPopup := False;
  end;
end;

function TCustomThemedDatePicker.GetPopupBounds: TRect;
var
  LSize: TSize;
  LOrigin, LBottomRight: TPoint;
  LControlRect, LWork: TRect;
  LMonitor: TMonitor;
  LGap, LX, LY: Integer;
begin
  EnsurePopup;
  LSize := FPopup.Calendar.PreferredPopupSize;
  LOrigin := ClientToScreen(Point(0, 0));
  LBottomRight := ClientToScreen(Point(Width, Height));
  LControlRect := Rect(LOrigin.X, LOrigin.Y, LBottomRight.X, LBottomRight.Y);
  LMonitor := Screen.MonitorFromRect(LControlRect);
  if LMonitor <> nil then LWork := LMonitor.WorkareaRect else LWork := Screen.WorkAreaRect;
  LGap := ScaleValue(2);
  if BiDiMode = bdRightToLeft then LX := LOrigin.X + Width - LSize.cx else LX := LOrigin.X;
  LY := LOrigin.Y + Height + LGap;
  if LX + LSize.cx > LWork.Right then LX := LWork.Right - LSize.cx;
  if LX < LWork.Left then LX := LWork.Left;
  if LY + LSize.cy > LWork.Bottom then LY := LOrigin.Y - LSize.cy - LGap;
  if LY < LWork.Top then LY := LWork.Top;
  Result := Rect(LX, LY, LX + LSize.cx, LY + LSize.cy);
end;

procedure TCustomThemedDatePicker.RefreshPopupBounds;
var
  LBounds: TRect;
begin
  if (FPopup = nil) or not FDroppedDown then Exit;
  LBounds := GetPopupBounds;
  FPopup.ShowPopup(LBounds);
end;

function TCustomThemedDatePicker.PointInControlScreen(const APoint: TPoint): Boolean;
var
  LTopLeft, LBottomRight: TPoint;
  LRect: TRect;
begin
  LTopLeft := ClientToScreen(Point(0, 0));
  LBottomRight := ClientToScreen(Point(Width, Height));
  LRect := Rect(LTopLeft.X, LTopLeft.Y, LBottomRight.X, LBottomRight.Y);
  Result := PtInRect(LRect, APoint);
end;

function TCustomThemedDatePicker.PointInPopupScreen(const APoint: TPoint): Boolean;
var
  LRect: TRect;
begin
  Result := False;
  if (FPopup = nil) or not FPopup.PopupVisible or not FPopup.HandleAllocated then Exit;
  if GetWindowRect(FPopup.Handle, LRect) then Result := PtInRect(LRect, APoint);
end;

procedure TCustomThemedDatePicker.ShowDropDown;
var
  LCancel: Boolean;
  LBounds: TRect;
begin
  if FDroppedDown or FOpeningDropDown or not Enabled or not Visible then Exit;
  FOpeningDropDown := True;
  try
    LCancel := False;
    DoDropDownOpening(LCancel);
    if LCancel then Exit;
    if Action <> nil then Action.Execute;
    if not Enabled or not Visible then Exit;
    EnsurePopup;
    FPopup.ApplyTheme(Palette);
    SynchronizePopup;
    LBounds := GetPopupBounds;
    FDroppedDown := True;
    FPopup.ShowPopup(LBounds);
    Invalidate;
  finally
    FOpeningDropDown := False;
  end;
  DoDropDownOpened;
end;

procedure TCustomThemedDatePicker.CloseDropDown;
begin
  if not FDroppedDown then Exit;
  FDroppedDown := False;
  if FPopup <> nil then FPopup.ClosePopup;
  Invalidate;
  DoDropDownClosed;
end;

procedure TCustomThemedDatePicker.InternalSetValue(const AValue: TDateTime; const ADateSelection: Boolean);
begin
  FInternalCalendarValueChange := True;
  try
    Value := AValue;
  finally
    FInternalCalendarValueChange := False;
  end;
  if ADateSelection then
  begin
    DoDateSelected;
    if FCloseOnDateSelected then
    begin
      DoDateConfirmed;
      CloseDropDown;
    end;
  end;
end;

procedure TCustomThemedDatePicker.InternalConfirmValue(const AValue: TDateTime);
begin
  FInternalCalendarValueChange := True;
  try
    Value := AValue;
  finally
    FInternalCalendarValueChange := False;
  end;
  DoDateSelected;
  DoDateConfirmed;
  CloseDropDown;
end;

procedure TCustomThemedDatePicker.ApplicationMessage(var Msg: TMsg; var Handled: Boolean);
var
  LPoint: TPoint;
  LForm: TCustomForm;
begin
  if not FDroppedDown then Exit;
  case Msg.message of
    WM_LBUTTONDOWN, WM_RBUTTONDOWN, WM_MBUTTONDOWN, WM_NCLBUTTONDOWN, WM_NCRBUTTONDOWN, WM_NCMBUTTONDOWN:
      begin
        GetCursorPos(LPoint);
        if not PointInControlScreen(LPoint) and not PointInPopupScreen(LPoint) then CloseDropDown;
      end;
    WM_MOVE, WM_SIZE:
      begin
        LForm := GetParentForm(Self);
        if ((LForm <> nil) and LForm.HandleAllocated and (Msg.hwnd = LForm.Handle)) or
           ((Parent <> nil) and Parent.HandleAllocated and (Msg.hwnd = Parent.Handle)) then
          CloseDropDown;
      end;
  end;
end;

procedure TCustomThemedDatePicker.ApplicationDeactivate(Sender: TObject);
begin
  if FDroppedDown then CloseDropDown;
end;

procedure TCustomThemedDatePicker.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  Message.Result := Message.Result or DLGC_WANTARROWS or DLGC_WANTCHARS;
end;

procedure TCustomThemedDatePicker.CMDialogKey(var Message: TCMDialogKey);
var
  LKey: Word;
begin
  if Enabled and FDroppedDown and (Message.CharCode in [VK_RETURN, VK_ESCAPE]) then
  begin
    if Message.CharCode = VK_ESCAPE then
      CloseDropDown
    else if FPopup <> nil then
    begin
      LKey := VK_RETURN;
      FPopup.Calendar.ProcessKey(LKey, KeyDataToShiftState(Message.KeyData));
    end;
    Message.Result := 1;
    Exit;
  end;
  if Enabled and not FDroppedDown and (Message.CharCode = VK_RETURN) and Focused then
  begin
    ShowDropDown;
    Message.Result := 1;
    Exit;
  end;
  inherited;
end;

procedure TCustomThemedDatePicker.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  if not Enabled and FDroppedDown then CloseDropDown;
  if not Enabled then FHovered := False;
  Invalidate;
end;

procedure TCustomThemedDatePicker.CMVisibleChanged(var Message: TMessage);
begin
  inherited;
  if not Visible and FDroppedDown then CloseDropDown;
end;

procedure TCustomThemedDatePicker.CMFontChanged(var Message: TMessage);
begin
  inherited;
  if FDroppedDown then SynchronizePopup;
end;

procedure TCustomThemedDatePicker.CMBiDiModeChanged(var Message: TMessage);
begin
  inherited;
  Invalidate;
  if FDroppedDown then SynchronizePopup;
end;

procedure TCustomThemedDatePicker.CMCancelMode(var Message: TCMCancelMode);
begin
  inherited;
  if FDroppedDown and (Message.Sender <> Self) and
     ((FPopup = nil) or ((Message.Sender <> FPopup) and (Message.Sender <> FPopup.Calendar))) then
    CloseDropDown;
end;

procedure TCustomThemedDatePicker.Paint;
var
  LContext: TThemedDatePickerRenderContext;
begin
  LContext.Bounds := ClientRect;
  LContext.Font := Font;
  LContext.Palette := Palette;
  LContext.Enabled := Enabled;
  LContext.Hovered := FHovered;
  LContext.Focused := FFocused;
  LContext.DroppedDown := FDroppedDown;
  LContext.BorderThickness := FBorderThickness;
  LContext.FormattedText := GetFormattedValue;
  LContext.RightToLeft := BiDiMode = bdRightToLeft;
  LContext.PPI := CurrentPPI;
  RenderCanvas.BeginRender(Canvas);
  try
    TThemedDatePickerRenderer.RenderPicker(RenderCanvas, LContext);
  finally
    RenderCanvas.EndRender;
  end;
end;


procedure TCustomThemedDatePicker.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited ChangeScale(M, D, isDpiChange);
  FBorderThickness := Max(1, ScaleValue(1));
  if FDroppedDown then SynchronizePopup;
end;

procedure TCustomThemedDatePicker.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if not FHovered then
  begin
    FHovered := True;
    Invalidate;
  end;
end;

procedure TCustomThemedDatePicker.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if FHovered then
  begin
    FHovered := False;
    Invalidate;
  end;
end;

procedure TCustomThemedDatePicker.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button <> mbLeft) or not Enabled then Exit;
  if CanFocus then SetFocus;
  if FDroppedDown then CloseDropDown else ShowDropDown;
end;

procedure TCustomThemedDatePicker.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if not Enabled then Exit;
  if (Key = VK_F4) or ((ssAlt in Shift) and (Key = VK_DOWN)) then
  begin
    if FDroppedDown then CloseDropDown else ShowDropDown;
    Key := 0;
    Exit;
  end;
  if FDroppedDown then
  begin
    if Key = VK_ESCAPE then
    begin
      CloseDropDown;
      Key := 0;
      Exit;
    end;
    if FPopup <> nil then FPopup.Calendar.ProcessKey(Key, Shift);
    Exit;
  end;
  if (Key = VK_RETURN) or (Key = VK_SPACE) then
  begin
    ShowDropDown;
    Key := 0;
  end;
end;

function TCustomThemedDatePicker.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
begin
  if FDroppedDown and (FPopup <> nil) then
  begin
    FPopup.Calendar.ScrollMonth(WheelDelta);
    Exit(True);
  end;
  Result := inherited DoMouseWheel(Shift, WheelDelta, MousePos);
end;

procedure TCustomThemedDatePicker.DoEnter;
begin
  inherited DoEnter;
  FFocused := True;
  Invalidate;
end;

procedure TCustomThemedDatePicker.DoExit;
begin
  inherited DoExit;
  FFocused := False;
  Invalidate;
  if FDroppedDown then CloseDropDown;
end;

procedure TCustomThemedDatePicker.DoValueChanged;
begin
  if Assigned(FOnValueChanged) then FOnValueChanged(Self);
end;

procedure TCustomThemedDatePicker.DoDateSelected;
begin
  if Assigned(FOnDateSelected) then FOnDateSelected(Self);
end;

procedure TCustomThemedDatePicker.DoDateConfirmed;
begin
  if Assigned(FOnDateConfirmed) then FOnDateConfirmed(Self);
end;

procedure TCustomThemedDatePicker.DoDropDownOpening(var ACancel: Boolean);
begin
  if Assigned(FOnDropDownOpening) then FOnDropDownOpening(Self, ACancel);
end;

procedure TCustomThemedDatePicker.DoDropDownOpened;
begin
  if Assigned(FOnDropDownOpened) then FOnDropDownOpened(Self);
end;

procedure TCustomThemedDatePicker.DoDropDownClosed;
begin
  if Assigned(FOnDropDownClosed) then FOnDropDownClosed(Self);
end;

procedure TCustomThemedDatePicker.BindAction(const AAction: TBasicAction);
begin
  Action := AAction;
end;

procedure TCustomThemedDatePicker.UnbindAction;
begin
  Action := nil;
end;

procedure TCustomThemedDatePicker.SyncAction;
begin
  InitiateAction;
end;

constructor TThemedDatePickerCalendar.CreateForPicker(AOwner: TComponent; APicker: TCustomThemedDatePicker);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csCaptureMouse, csClickEvents];
  FOwnerPicker := APicker;
  TabStop := False;
  Font.Name := 'Segoe UI';
  Font.Size := 9;
  FBoldFont := TFont.Create;
  UpdateBoldFont;
  FHoveredDayIndex := -1;
  FMinuteIncrement := 1;
  FShowTodayButton := True;
  FShowConfirmButton := True;
end;

destructor TThemedDatePickerCalendar.Destroy;
begin
  FBoldFont.Free;
  inherited Destroy;
end;

procedure TThemedDatePickerCalendar.UpdateBoldFont;
begin
  if FBoldFont = nil then Exit;
  FBoldFont.Assign(Font);
  FBoldFont.Style := FBoldFont.Style + [fsBold];
end;

procedure TThemedDatePickerCalendar.CMFontChanged(var Message: TMessage);
begin
  inherited;
  UpdateBoldFont;
  CalculateLayout;
end;

procedure TThemedDatePickerCalendar.CMBiDiModeChanged(var Message: TMessage);
begin
  inherited;
  CalculateLayout;
  Invalidate;
end;

procedure TThemedDatePickerCalendar.SetState(const ADate: TDateTime; const AShowTime: Boolean; const AMinDate, AMaxDate: TDateTime; const AFormatSettings: TFormatSettings; const AFirstDayOfWeek: TThemedDatePickerDayOfWeek; const AMinuteIncrement: Integer; const AShowTodayButton, AShowConfirmButton: Boolean);
var
  LSize: TSize;
begin
  FMinDate := AMinDate;
  FMaxDate := AMaxDate;
  FSelectedDate := Constrain(ADate);
  FViewMonth := EncodeDate(YearOf(FSelectedDate), MonthOf(FSelectedDate), 1);
  FShowTime := AShowTime;
  FFormatSettings := AFormatSettings;
  FFirstDayOfWeek := AFirstDayOfWeek;
  FMinuteIncrement := EnsureRange(AMinuteIncrement, 1, 59);
  FShowTodayButton := AShowTodayButton;
  FShowConfirmButton := AShowConfirmButton;
  ClearHover;
  LSize := PreferredPopupSize;
  SetBounds(Left, Top, LSize.cx, LSize.cy);
  CalculateLayout;
  Invalidate;
end;

function TThemedDatePickerCalendar.PreferredPopupSize: TSize;
var
  LHeight: Integer;
begin
  LHeight := 290;
  if FShowTime then Inc(LHeight, 48);
  if FShowTodayButton or FShowConfirmButton then Inc(LHeight, 40);
  Result.cx := ScaleValue(252);
  Result.cy := ScaleValue(LHeight);
end;

procedure TThemedDatePickerCalendar.CalculateLayout;
var
  LNavSize, LNavMargin, LStartY, LCellHeight, LOffset, I, LRow, LColumn, LBottomY: Integer;
  LFirstDay, LStartDate: TDateTime;
  LSelectorHeight, LArrowWidth, LArrowHeight, LArrowGap, LTimeY, LArrowsY, LCenterX: Integer;
  LButtonHeight, LMargin, LGap, LButtonY, LButtonWidth: Integer;
begin
  if (Width <= 0) or (Height <= 0) then Exit;
  LNavSize := ScaleValue(24);
  LNavMargin := ScaleValue(5);
  if BiDiMode = bdRightToLeft then
  begin
    FNextYearRect := Rect(LNavMargin, LNavMargin, LNavMargin + LNavSize, LNavMargin + LNavSize);
    FNextMonthRect := Rect(LNavMargin + LNavSize, LNavMargin, LNavMargin + LNavSize * 2, LNavMargin + LNavSize);
    FPrevMonthRect := Rect(Width - LNavMargin - LNavSize * 2, LNavMargin, Width - LNavMargin - LNavSize, LNavMargin + LNavSize);
    FPrevYearRect := Rect(Width - LNavMargin - LNavSize, LNavMargin, Width - LNavMargin, LNavMargin + LNavSize);
  end
  else
  begin
    FPrevYearRect := Rect(LNavMargin, LNavMargin, LNavMargin + LNavSize, LNavMargin + LNavSize);
    FPrevMonthRect := Rect(LNavMargin + LNavSize, LNavMargin, LNavMargin + LNavSize * 2, LNavMargin + LNavSize);
    FNextMonthRect := Rect(Width - LNavMargin - LNavSize * 2, LNavMargin, Width - LNavMargin - LNavSize, LNavMargin + LNavSize);
    FNextYearRect := Rect(Width - LNavMargin - LNavSize, LNavMargin, Width - LNavMargin, LNavMargin + LNavSize);
  end;
  LStartY := ScaleValue(65);
  LCellHeight := ScaleValue(36);
  LFirstDay := EncodeDate(YearOf(FViewMonth), MonthOf(FViewMonth), 1);
  LOffset := (7 + (DayOfWeek(LFirstDay) - 1) - DayOfWeekIndex(FFirstDayOfWeek)) mod 7;
  LStartDate := SafeIncDay(LFirstDay, -LOffset);
  for I := 0 to 41 do
  begin
    LRow := I div 7;
    if BiDiMode = bdRightToLeft then LColumn := 6 - (I mod 7) else LColumn := I mod 7;
    FDayRects[I] := GetColumnRect(LColumn, LStartY + LRow * LCellHeight, LCellHeight);
    FDayDates[I] := SafeIncDay(LStartDate, I);
  end;
  LBottomY := LStartY + LCellHeight * 6;
  FHourUpRect := Rect(0, 0, 0, 0);
  FHourDownRect := Rect(0, 0, 0, 0);
  FMinuteUpRect := Rect(0, 0, 0, 0);
  FMinuteDownRect := Rect(0, 0, 0, 0);
  if FShowTime then
  begin
    LSelectorHeight := ScaleValue(28);
    LArrowWidth := ScaleValue(14);
    LArrowHeight := ScaleValue(10);
    LArrowGap := ScaleValue(1);
    LTimeY := LBottomY + ScaleValue(10);
    LArrowsY := LTimeY + Max(0, (LSelectorHeight - LArrowHeight * 2 - LArrowGap) div 2);
    LCenterX := Width div 2;
    if BiDiMode = bdRightToLeft then
    begin
      FHourUpRect := Rect(LCenterX + ScaleValue(39), LArrowsY, LCenterX + ScaleValue(39) + LArrowWidth, LArrowsY + LArrowHeight);
      FHourDownRect := Rect(LCenterX + ScaleValue(39), LArrowsY + LArrowHeight + LArrowGap, LCenterX + ScaleValue(39) + LArrowWidth, LArrowsY + LArrowHeight * 2 + LArrowGap);
      FMinuteUpRect := Rect(LCenterX - ScaleValue(31), LArrowsY, LCenterX - ScaleValue(31) + LArrowWidth, LArrowsY + LArrowHeight);
      FMinuteDownRect := Rect(LCenterX - ScaleValue(31), LArrowsY + LArrowHeight + LArrowGap, LCenterX - ScaleValue(31) + LArrowWidth, LArrowsY + LArrowHeight * 2 + LArrowGap);
    end
    else
    begin
      FHourUpRect := Rect(LCenterX - ScaleValue(31), LArrowsY, LCenterX - ScaleValue(31) + LArrowWidth, LArrowsY + LArrowHeight);
      FHourDownRect := Rect(LCenterX - ScaleValue(31), LArrowsY + LArrowHeight + LArrowGap, LCenterX - ScaleValue(31) + LArrowWidth, LArrowsY + LArrowHeight * 2 + LArrowGap);
      FMinuteUpRect := Rect(LCenterX + ScaleValue(39), LArrowsY, LCenterX + ScaleValue(39) + LArrowWidth, LArrowsY + LArrowHeight);
      FMinuteDownRect := Rect(LCenterX + ScaleValue(39), LArrowsY + LArrowHeight + LArrowGap, LCenterX + ScaleValue(39) + LArrowWidth, LArrowsY + LArrowHeight * 2 + LArrowGap);
    end;
  end;
  FTodayRect := Rect(0, 0, 0, 0);
  FConfirmRect := Rect(0, 0, 0, 0);
  if FShowTodayButton or FShowConfirmButton then
  begin
    LButtonHeight := ScaleValue(26);
    LMargin := ScaleValue(10);
    LGap := ScaleValue(8);
    LButtonY := Height - LMargin - LButtonHeight;
    if FShowTodayButton and FShowConfirmButton then
    begin
      LButtonWidth := (Width - LMargin * 2 - LGap) div 2;
      if BiDiMode = bdRightToLeft then
      begin
        FConfirmRect := Rect(LMargin, LButtonY, LMargin + LButtonWidth, LButtonY + LButtonHeight);
        FTodayRect := Rect(LMargin + LButtonWidth + LGap, LButtonY, Width - LMargin, LButtonY + LButtonHeight);
      end
      else
      begin
        FTodayRect := Rect(LMargin, LButtonY, LMargin + LButtonWidth, LButtonY + LButtonHeight);
        FConfirmRect := Rect(LMargin + LButtonWidth + LGap, LButtonY, Width - LMargin, LButtonY + LButtonHeight);
      end;
    end
    else if FShowTodayButton then FTodayRect := Rect(LMargin, LButtonY, Width - LMargin, LButtonY + LButtonHeight)
    else FConfirmRect := Rect(LMargin, LButtonY, Width - LMargin, LButtonY + LButtonHeight);
  end;
end;

function TThemedDatePickerCalendar.GetColumnRect(const AColumn, AY, AHeight: Integer): TRect;
var
  LLeft, LRight: Integer;
begin
  LLeft := AColumn * Width div 7;
  LRight := (AColumn + 1) * Width div 7;
  Result := Rect(LLeft, AY, Max(LLeft + 1, LRight), AY + AHeight);
end;

function TThemedDatePickerCalendar.IsDateEnabled(const AValue: TDateTime): Boolean;
begin
  Result := (DateOf(AValue) >= DateOf(FMinDate)) and (DateOf(AValue) <= DateOf(FMaxDate));
end;

function TThemedDatePickerCalendar.HitTestDay(const APoint: TPoint): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to 41 do
    if PtInRect(FDayRects[I], APoint) and IsDateEnabled(FDayDates[I]) then
      Exit(I);
end;

function TThemedDatePickerCalendar.Constrain(const AValue: TDateTime): TDateTime;
begin
  if AValue < FMinDate then Result := FMinDate
  else if AValue > FMaxDate then Result := FMaxDate
  else Result := AValue;
end;

function TThemedDatePickerCalendar.CanChangeTime(const AMinutes: Integer): Boolean;
begin
  Result := not SameDateTime(FSelectedDate, Constrain(SafeIncMinute(FSelectedDate, AMinutes)));
end;

function TThemedDatePickerCalendar.CanChangeViewMonth(const AMonths: Integer): Boolean;
var
  LCandidate, LMinMonth, LMaxMonth: TDateTime;
begin
  LCandidate := SafeIncMonth(FViewMonth, AMonths);
  LMinMonth := EncodeDate(YearOf(FMinDate), MonthOf(FMinDate), 1);
  LMaxMonth := EncodeDate(YearOf(FMaxDate), MonthOf(FMaxDate), 1);
  if LCandidate < LMinMonth then LCandidate := LMinMonth;
  if LCandidate > LMaxMonth then LCandidate := LMaxMonth;
  Result := not SameDateTime(FViewMonth, LCandidate);
end;

function TThemedDatePickerCalendar.CanChangeViewYear(const AYears: Integer): Boolean;
var
  LCandidate, LMinMonth, LMaxMonth: TDateTime;
begin
  LCandidate := SafeIncYear(FViewMonth, AYears);
  LCandidate := EncodeDate(YearOf(LCandidate), MonthOf(LCandidate), 1);
  LMinMonth := EncodeDate(YearOf(FMinDate), MonthOf(FMinDate), 1);
  LMaxMonth := EncodeDate(YearOf(FMaxDate), MonthOf(FMaxDate), 1);
  if LCandidate < LMinMonth then LCandidate := LMinMonth;
  if LCandidate > LMaxMonth then LCandidate := LMaxMonth;
  Result := not SameDateTime(FViewMonth, LCandidate);
end;

function TThemedDatePickerCalendar.IsTodayEnabled: Boolean;
begin
  Result := IsDateEnabled(Date);
end;

procedure TThemedDatePickerCalendar.SetSelectedDate(const ADate: TDateTime; const ADateSelection: Boolean);
var
  LCombined: TDateTime;
begin
  LCombined := DateOf(ADate) + TimeOf(FSelectedDate);
  FSelectedDate := Constrain(LCombined);
  FViewMonth := EncodeDate(YearOf(FSelectedDate), MonthOf(FSelectedDate), 1);
  CalculateLayout;
  Invalidate;
  if FOwnerPicker <> nil then FOwnerPicker.InternalSetValue(FSelectedDate, ADateSelection);
end;

procedure TThemedDatePickerCalendar.ChangeTime(const AMinutes: Integer);
var
  LOldDate: TDateTime;
begin
  LOldDate := DateOf(FSelectedDate);
  FSelectedDate := Constrain(SafeIncMinute(FSelectedDate, AMinutes));
  if DateOf(FSelectedDate) <> LOldDate then
  begin
    FViewMonth := EncodeDate(YearOf(FSelectedDate), MonthOf(FSelectedDate), 1);
    CalculateLayout;
  end;
  Invalidate;
  if FOwnerPicker <> nil then FOwnerPicker.InternalSetValue(FSelectedDate, False);
end;

procedure TThemedDatePickerCalendar.ChangeViewMonth(const AMonths: Integer);
var
  LCandidate, LMinMonth, LMaxMonth: TDateTime;
begin
  if not CanChangeViewMonth(AMonths) then Exit;
  LCandidate := SafeIncMonth(FViewMonth, AMonths);
  LMinMonth := EncodeDate(YearOf(FMinDate), MonthOf(FMinDate), 1);
  LMaxMonth := EncodeDate(YearOf(FMaxDate), MonthOf(FMaxDate), 1);
  if LCandidate < LMinMonth then LCandidate := LMinMonth;
  if LCandidate > LMaxMonth then LCandidate := LMaxMonth;
  FViewMonth := LCandidate;
  CalculateLayout;
  Invalidate;
end;

procedure TThemedDatePickerCalendar.ChangeViewYear(const AYears: Integer);
var
  LCandidate, LMinMonth, LMaxMonth: TDateTime;
begin
  if not CanChangeViewYear(AYears) then Exit;
  LCandidate := SafeIncYear(FViewMonth, AYears);
  LCandidate := EncodeDate(YearOf(LCandidate), MonthOf(LCandidate), 1);
  LMinMonth := EncodeDate(YearOf(FMinDate), MonthOf(FMinDate), 1);
  LMaxMonth := EncodeDate(YearOf(FMaxDate), MonthOf(FMaxDate), 1);
  if LCandidate < LMinMonth then LCandidate := LMinMonth;
  if LCandidate > LMaxMonth then LCandidate := LMaxMonth;
  FViewMonth := LCandidate;
  CalculateLayout;
  Invalidate;
end;

procedure TThemedDatePickerCalendar.ClearHover;
begin
  FHoverPrevYear := False;
  FHoverPrevMonth := False;
  FHoverNextMonth := False;
  FHoverNextYear := False;
  FHourUpHover := False;
  FHourDownHover := False;
  FMinuteUpHover := False;
  FMinuteDownHover := False;
  FTodayHover := False;
  FConfirmHover := False;
  FHoveredDayIndex := -1;
end;

procedure TThemedDatePickerCalendar.Paint;
var
  LContext: TThemedDatePickerCalendarRenderContext;
  I, LDayIndex: Integer;
begin
  LContext.Bounds := ClientRect;
  LContext.Font := Font;
  LContext.BoldFont := FBoldFont;
  LContext.Palette := Palette;
  LContext.MonthTitle := FormatDateTime('mmmm yyyy', FViewMonth, FFormatSettings);
  for I := 0 to 6 do
  begin
    LDayIndex := (DayOfWeekIndex(FFirstDayOfWeek) + I) mod 7;
    LContext.DayNames[I] := FFormatSettings.ShortDayNames[LDayIndex + 1];
  end;
  LContext.DayRects := FDayRects;
  LContext.DayDates := FDayDates;
  LContext.SelectedDate := FSelectedDate;
  LContext.ViewMonth := FViewMonth;
  LContext.MinDate := FMinDate;
  LContext.MaxDate := FMaxDate;
  LContext.PrevYearRect := FPrevYearRect;
  LContext.PrevMonthRect := FPrevMonthRect;
  LContext.NextMonthRect := FNextMonthRect;
  LContext.NextYearRect := FNextYearRect;
  LContext.HourUpRect := FHourUpRect;
  LContext.HourDownRect := FHourDownRect;
  LContext.MinuteUpRect := FMinuteUpRect;
  LContext.MinuteDownRect := FMinuteDownRect;
  LContext.TodayRect := FTodayRect;
  LContext.ConfirmRect := FConfirmRect;
  LContext.HoveredDayIndex := FHoveredDayIndex;
  LContext.HoverPrevYear := FHoverPrevYear;
  LContext.HoverPrevMonth := FHoverPrevMonth;
  LContext.HoverNextMonth := FHoverNextMonth;
  LContext.HoverNextYear := FHoverNextYear;
  LContext.HourUpHover := FHourUpHover;
  LContext.HourDownHover := FHourDownHover;
  LContext.MinuteUpHover := FMinuteUpHover;
  LContext.MinuteDownHover := FMinuteDownHover;
  LContext.TodayHover := FTodayHover;
  LContext.ConfirmHover := FConfirmHover;
  LContext.PrevYearEnabled := CanChangeViewYear(-1);
  LContext.PrevMonthEnabled := CanChangeViewMonth(-1);
  LContext.NextMonthEnabled := CanChangeViewMonth(1);
  LContext.NextYearEnabled := CanChangeViewYear(1);
  LContext.HourUpEnabled := CanChangeTime(60);
  LContext.HourDownEnabled := CanChangeTime(-60);
  LContext.MinuteUpEnabled := CanChangeTime(FMinuteIncrement);
  LContext.MinuteDownEnabled := CanChangeTime(-FMinuteIncrement);
  LContext.TodayEnabled := IsTodayEnabled;
  LContext.RightToLeft := BiDiMode = bdRightToLeft;
  LContext.ShowTime := FShowTime;
  LContext.ShowTodayButton := FShowTodayButton;
  LContext.ShowConfirmButton := FShowConfirmButton;
  LContext.HourText := FormatDateTime('hh', FSelectedDate, FFormatSettings);
  LContext.MinuteText := FormatDateTime('nn', FSelectedDate, FFormatSettings);
  LContext.TodayText := SDatePickerToday;
  LContext.ConfirmText := SDatePickerConfirm;
  LContext.PPI := CurrentPPI;
  RenderCanvas.BeginRender(Canvas);
  try
    TThemedDatePickerRenderer.RenderCalendar(RenderCanvas, LContext);
  finally
    RenderCanvas.EndRender;
  end;
end;

procedure TThemedDatePickerCalendar.Resize;
begin
  inherited Resize;
  CalculateLayout;
end;

procedure TThemedDatePickerCalendar.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited ChangeScale(M, D, isDpiChange);
  CalculateLayout;
end;

procedure TThemedDatePickerCalendar.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LPoint: TPoint;
  LChanged: Boolean;
  LHovered: Integer;
  procedure UpdateFlag(var AField: Boolean; const AValue: Boolean);
  begin
    if AField <> AValue then
    begin
      AField := AValue;
      LChanged := True;
    end;
  end;
begin
  inherited MouseMove(Shift, X, Y);
  LPoint := Point(X, Y);
  LChanged := False;
  UpdateFlag(FHoverPrevYear, CanChangeViewYear(-1) and PtInRect(FPrevYearRect, LPoint));
  UpdateFlag(FHoverPrevMonth, CanChangeViewMonth(-1) and PtInRect(FPrevMonthRect, LPoint));
  UpdateFlag(FHoverNextMonth, CanChangeViewMonth(1) and PtInRect(FNextMonthRect, LPoint));
  UpdateFlag(FHoverNextYear, CanChangeViewYear(1) and PtInRect(FNextYearRect, LPoint));
  UpdateFlag(FHourUpHover, FShowTime and CanChangeTime(60) and PtInRect(FHourUpRect, LPoint));
  UpdateFlag(FHourDownHover, FShowTime and CanChangeTime(-60) and PtInRect(FHourDownRect, LPoint));
  UpdateFlag(FMinuteUpHover, FShowTime and CanChangeTime(FMinuteIncrement) and PtInRect(FMinuteUpRect, LPoint));
  UpdateFlag(FMinuteDownHover, FShowTime and CanChangeTime(-FMinuteIncrement) and PtInRect(FMinuteDownRect, LPoint));
  UpdateFlag(FTodayHover, FShowTodayButton and IsTodayEnabled and PtInRect(FTodayRect, LPoint));
  UpdateFlag(FConfirmHover, FShowConfirmButton and PtInRect(FConfirmRect, LPoint));
  LHovered := HitTestDay(LPoint);
  if FHoveredDayIndex <> LHovered then
  begin
    FHoveredDayIndex := LHovered;
    LChanged := True;
  end;
  if LChanged then Invalidate;
end;

procedure TThemedDatePickerCalendar.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  ClearHover;
  Invalidate;
end;

function TThemedDatePickerCalendar.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
begin
  ScrollMonth(WheelDelta);
  Result := WheelDelta <> 0;
end;

procedure TThemedDatePickerCalendar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LPoint: TPoint;
  LDayIndex: Integer;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if Button <> mbLeft then Exit;
  LPoint := Point(X, Y);
  LDayIndex := HitTestDay(LPoint);
  if CanChangeViewYear(-1) and PtInRect(FPrevYearRect, LPoint) then ChangeViewYear(-1)
  else if CanChangeViewMonth(-1) and PtInRect(FPrevMonthRect, LPoint) then ChangeViewMonth(-1)
  else if CanChangeViewMonth(1) and PtInRect(FNextMonthRect, LPoint) then ChangeViewMonth(1)
  else if CanChangeViewYear(1) and PtInRect(FNextYearRect, LPoint) then ChangeViewYear(1)
  else if LDayIndex >= 0 then SetSelectedDate(FDayDates[LDayIndex], True)
  else if FShowTime and CanChangeTime(60) and PtInRect(FHourUpRect, LPoint) then ChangeTime(60)
  else if FShowTime and CanChangeTime(-60) and PtInRect(FHourDownRect, LPoint) then ChangeTime(-60)
  else if FShowTime and CanChangeTime(FMinuteIncrement) and PtInRect(FMinuteUpRect, LPoint) then ChangeTime(FMinuteIncrement)
  else if FShowTime and CanChangeTime(-FMinuteIncrement) and PtInRect(FMinuteDownRect, LPoint) then ChangeTime(-FMinuteIncrement)
  else if FShowTodayButton and IsTodayEnabled and PtInRect(FTodayRect, LPoint) then SetSelectedDate(Date + TimeOf(FSelectedDate), True)
  else if FShowConfirmButton and PtInRect(FConfirmRect, LPoint) and (FOwnerPicker <> nil) then FOwnerPicker.InternalConfirmValue(FSelectedDate);
end;

procedure TThemedDatePickerCalendar.ProcessKey(var Key: Word; Shift: TShiftState);
var
  LCandidate: TDateTime;
  LOffset: Integer;
begin
  LCandidate := FSelectedDate;
  case Key of
    VK_LEFT: if BiDiMode = bdRightToLeft then LCandidate := SafeIncDay(LCandidate, 1) else LCandidate := SafeIncDay(LCandidate, -1);
    VK_RIGHT: if BiDiMode = bdRightToLeft then LCandidate := SafeIncDay(LCandidate, -1) else LCandidate := SafeIncDay(LCandidate, 1);
    VK_UP: LCandidate := SafeIncDay(LCandidate, -7);
    VK_DOWN: LCandidate := SafeIncDay(LCandidate, 7);
    VK_PRIOR:
      if ssCtrl in Shift then LCandidate := SafeIncYear(LCandidate, -1) else LCandidate := SafeIncMonth(LCandidate, -1);
    VK_NEXT:
      if ssCtrl in Shift then LCandidate := SafeIncYear(LCandidate, 1) else LCandidate := SafeIncMonth(LCandidate, 1);
    VK_HOME:
      begin
        LOffset := (7 + (DayOfWeek(LCandidate) - 1) - DayOfWeekIndex(FFirstDayOfWeek)) mod 7;
        LCandidate := SafeIncDay(LCandidate, -LOffset);
      end;
    VK_END:
      begin
        LOffset := (7 + (DayOfWeek(LCandidate) - 1) - DayOfWeekIndex(FFirstDayOfWeek)) mod 7;
        LCandidate := SafeIncDay(LCandidate, 6 - LOffset);
      end;
    VK_RETURN:
      begin
        if FOwnerPicker <> nil then FOwnerPicker.InternalConfirmValue(FSelectedDate);
        Key := 0;
        Exit;
      end;
    VK_ESCAPE:
      begin
        if FOwnerPicker <> nil then FOwnerPicker.CloseDropDown;
        Key := 0;
        Exit;
      end;
  else
    Exit;
  end;
  SetSelectedDate(LCandidate, False);
  Key := 0;
end;

procedure TThemedDatePickerCalendar.ScrollMonth(const AWheelDelta: Integer);
begin
  if AWheelDelta > 0 then ChangeViewMonth(-1)
  else if AWheelDelta < 0 then ChangeViewMonth(1);
end;

constructor TThemedDatePickerPopupForm.CreateForPicker(APicker: TCustomThemedDatePicker);
begin
  inherited CreateNew(APicker);
  BorderStyle := Vcl.Forms.bsNone;
  ShowInTaskbar := False;
  Position := poDesigned;
  AutoScroll := False;
  KeyPreview := False;
  FCalendar := TThemedDatePickerCalendar.CreateForPicker(Self, APicker);
  FCalendar.Parent := Self;
  FCalendar.Align := alClient;
  FCalendar.TabStop := False;
end;

procedure TThemedDatePickerPopupForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_NOACTIVATE or WS_EX_TOOLWINDOW;
  Params.Style := Params.Style and not WS_CAPTION;
  Params.WindowClass.style := Params.WindowClass.style or CS_DROPSHADOW;
end;

procedure TThemedDatePickerPopupForm.WMMouseActivate(var Message: TWMMouseActivate);
begin
  Message.Result := MA_NOACTIVATE;
end;

procedure TThemedDatePickerPopupForm.ApplyTheme(const APalette: TThemePalette);
begin
  if APalette = nil then Exit;
  Color := ThemeColorToColor(NimbusMenuBackColor(APalette));
  FCalendar.ApplyTheme(APalette);
end;

procedure TThemedDatePickerPopupForm.SyncSize;
var
  LSize: TSize;
begin
  LSize := FCalendar.PreferredPopupSize;
  ClientWidth := LSize.cx;
  ClientHeight := LSize.cy;
end;

procedure TThemedDatePickerPopupForm.ShowPopup(const ABounds: TRect);
begin
  SetBounds(ABounds.Left, ABounds.Top, ABounds.Width, ABounds.Height);
  if not Visible then Visible := True;
  if HandleAllocated then SetWindowPos(Handle, HWND_TOP, ABounds.Left, ABounds.Top, ABounds.Width, ABounds.Height, SWP_NOACTIVATE or SWP_SHOWWINDOW);
  FPopupVisible := True;
end;

procedure TThemedDatePickerPopupForm.ClosePopup;
begin
  FPopupVisible := False;
  if Visible then Visible := False;
end;

end.

{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.DateRange;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, System.SysUtils,
  System.Types, System.UITypes, System.DateUtils, System.Math,
  Vcl.Controls, Vcl.Forms, Vcl.Graphics,
  NimbusForms.Controls.Base, NimbusForms.Controls.Types, NimbusForms.Controls.DatePicker,
  NimbusForms.Controls.Button, NimbusForms.Controls.Panel,
  NimbusForms.Controls.ThemedLabel, NimbusForms.Rendering.DateRange;

type
  TDateRangePickerSelectionMode = (drsmRange, drsmSingleDate, drsmStartDateOnly, drsmEndDateOnly);
  TDateRangePickerDisplayMode = (drdmCompact, drdmDetailed);
  TDateRangePickerPreset = (drpToday, drpYesterday, drpThisWeek, drpLastWeek,
    drpThisMonth, drpLastMonth, drpLast7Days, drpLast14Days, drpLast30Days,
    drpThisYear, drpLastYear);
  TDateRangeChangingEvent = procedure(Sender: TObject; const AStartDate,
    AEndDate: TDateTime; var ACancel: Boolean) of object;
  TCustomThemedDateRangePicker = class;

  TThemedDateRangePopup = class(TForm)
  private
    FPicker: TCustomThemedDateRangePicker;
    FBackground: TThemedPanel;
    FStartLabel: TThemedLabel;
    FEndLabel: TThemedLabel;
    FStart: TThemedDatePicker;
    FEnd: TThemedDatePicker;
    FApply: TThemedButton;
    FCancel: TThemedButton;
    FToday: TThemedButton;
    FLast7: TThemedButton;
    FThisMonth: TThemedButton;
    procedure ApplyClick(Sender: TObject);
    procedure CancelClick(Sender: TObject);
    procedure PresetClick(Sender: TObject);
  public
    constructor CreateForPicker(APicker: TCustomThemedDateRangePicker);
    procedure Synchronize;
  end;

  TCustomThemedDateRangePicker = class(TCustomNimbusControl)
  private
    FStartDate: TDateTime;
    FEndDate: TDateTime;
    FMinDate: TDateTime;
    FMaxDate: TDateTime;
    FHasStartDate: Boolean;
    FHasEndDate: Boolean;
    FAllowEmptyRange: Boolean;
    FAllowSingleDateRange: Boolean;
    FSwapInvalidRange: Boolean;
    FShowClearButton: Boolean;
    FReadOnly: Boolean;
    FPlaceholderText: string;
    FDateFormat: string;
    FSeparatorText: string;
    FStartCaption: string;
    FEndCaption: string;
    FApplyCaption: string;
    FCancelCaption: string;
    FTodayCaption: string;
    FLast7DaysCaption: string;
    FThisMonthCaption: string;
    FSelectionMode: TDateRangePickerSelectionMode;
    FDisplayMode: TDateRangePickerDisplayMode;
    FCompactNormalHeight: Integer;
    FCompactAppliedHeight: Integer;
    FHot: Boolean;
    FPopup: TThemedDateRangePopup;
    FOnDateRangeChanged: TNotifyEvent;
    FOnDateRangeChanging: TDateRangeChangingEvent;
    FOnApplyClicked: TNotifyEvent;
    FOnCancelClicked: TNotifyEvent;
    FOnClearClicked: TNotifyEvent;
    procedure SetStartDate(const AValue: TDateTime);
    procedure SetEndDate(const AValue: TDateTime);
    procedure SetMinDate(const AValue: TDateTime);
    procedure SetMaxDate(const AValue: TDateTime);
    procedure SetPlaceholderText(const AValue: string);
    procedure SetDateFormat(const AValue: string);
    procedure SetSeparatorText(const AValue: string);
    procedure SetStartCaption(const AValue: string);
    procedure SetEndCaption(const AValue: string);
    procedure SetApplyCaption(const AValue: string);
    procedure SetCancelCaption(const AValue: string);
    procedure SetTodayCaption(const AValue: string);
    procedure SetLast7DaysCaption(const AValue: string);
    procedure SetThisMonthCaption(const AValue: string);
    procedure SetShowClearButton(const AValue: Boolean);
    function GetDisplayText: string;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMCancelMode(var Message: TCMCancelMode); message CM_CANCELMODE;
  protected
    procedure StyleModeChanged; override;
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DoExit; override;
    property StartDate: TDateTime read FStartDate write SetStartDate;
    property EndDate: TDateTime read FEndDate write SetEndDate;
    property MinDate: TDateTime read FMinDate write SetMinDate;
    property MaxDate: TDateTime read FMaxDate write SetMaxDate;
    property AllowEmptyRange: Boolean read FAllowEmptyRange write FAllowEmptyRange default True;
    property AllowSingleDateRange: Boolean read FAllowSingleDateRange write FAllowSingleDateRange default True;
    property SwapInvalidRange: Boolean read FSwapInvalidRange write FSwapInvalidRange default True;
    property ShowClearButton: Boolean read FShowClearButton write SetShowClearButton default True;
    property ReadOnly: Boolean read FReadOnly write FReadOnly default False;
    property PlaceholderText: string read FPlaceholderText write SetPlaceholderText;
    property DateFormat: string read FDateFormat write SetDateFormat;
    property RangeSeparatorText: string read FSeparatorText write SetSeparatorText;
    property StartCaption: string read FStartCaption write SetStartCaption;
    property EndCaption: string read FEndCaption write SetEndCaption;
    property ApplyCaption: string read FApplyCaption write SetApplyCaption;
    property CancelCaption: string read FCancelCaption write SetCancelCaption;
    property TodayCaption: string read FTodayCaption write SetTodayCaption;
    property Last7DaysCaption: string read FLast7DaysCaption write SetLast7DaysCaption;
    property ThisMonthCaption: string read FThisMonthCaption write SetThisMonthCaption;
    property SelectionMode: TDateRangePickerSelectionMode read FSelectionMode write FSelectionMode default drsmRange;
    property DisplayMode: TDateRangePickerDisplayMode read FDisplayMode write FDisplayMode default drdmCompact;
    property OnDateRangeChanged: TNotifyEvent read FOnDateRangeChanged write FOnDateRangeChanged;
    property OnDateRangeChanging: TDateRangeChangingEvent read FOnDateRangeChanging write FOnDateRangeChanging;
    property OnApplyClicked: TNotifyEvent read FOnApplyClicked write FOnApplyClicked;
    property OnCancelClicked: TNotifyEvent read FOnCancelClicked write FOnCancelClicked;
    property OnClearClicked: TNotifyEvent read FOnClearClicked write FOnClearClicked;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetRange(const AStart, AEnd: TDateTime);
    procedure Clear;
    procedure ApplyPreset(const APreset: TDateRangePickerPreset);
    procedure ShowDropDown;
    procedure CloseDropDown;
    property HasStartDate: Boolean read FHasStartDate;
    property HasEndDate: Boolean read FHasEndDate;
  end;

  TThemedDateRangePicker = class(TCustomThemedDateRangePicker)
  published
    property StyleMode;
    property Align;
    property Anchors;
    property Constraints;
    property Enabled;
    property Font;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property Hint;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property StartDate;
    property EndDate;
    property MinDate;
    property MaxDate;
    property AllowEmptyRange;
    property AllowSingleDateRange;
    property SwapInvalidRange;
    property ShowClearButton;
    property ReadOnly;
    property PlaceholderText;
    property DateFormat;
    property RangeSeparatorText;
    property StartCaption;
    property EndCaption;
    property ApplyCaption;
    property CancelCaption;
    property TodayCaption;
    property Last7DaysCaption;
    property ThisMonthCaption;
    property SelectionMode;
    property DisplayMode;
    property OnDateRangeChanged;
    property OnDateRangeChanging;
    property OnApplyClicked;
    property OnCancelClicked;
    property OnClearClicked;
    property OnClick;
    property OnEnter;
    property OnExit;
  end;

implementation

uses
  NimbusForms.Rendering.Types;

resourcestring
  SDateRangePlaceholder = 'Select date range';
  SDateRangeApply = 'Apply';
  SDateRangeCancel = 'Cancel';
  SDateRangeToday = 'Today';
  SDateRangeLastSeven = 'Last 7 days';
  SDateRangeThisMonth = 'This month';
  SDateRangeStart = 'Start date';
  SDateRangeEnd = 'End date';

constructor TCustomThemedDateRangePicker.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 260;
  Height := 32;
  TabStop := True;
  Font.Name := 'Segoe UI';
  Font.Size := 9;
  FAllowEmptyRange := True;
  FAllowSingleDateRange := True;
  FSwapInvalidRange := True;
  FShowClearButton := True;
  FPlaceholderText := SDateRangePlaceholder;
  FDateFormat := 'dd.MM.yyyy';
  FSeparatorText := ' - ';
  FStartCaption := SDateRangeStart;
  FEndCaption := SDateRangeEnd;
  FApplyCaption := SDateRangeApply;
  FCancelCaption := SDateRangeCancel;
  FTodayCaption := SDateRangeToday;
  FLast7DaysCaption := SDateRangeLastSeven;
  FThisMonthCaption := SDateRangeThisMonth;
  FMinDate := EncodeDate(1900, 1, 1);
  FMaxDate := EncodeDate(2100, 12, 31);
end;

procedure TCustomThemedDateRangePicker.StyleModeChanged;
begin
  inherited StyleModeChanged;
  if Align = alNone then
  begin
    if StyleMode = stCompact then
    begin
      FCompactNormalHeight := Height;
      FCompactAppliedHeight := Max(ScaleValue(23), (Height * 26 + 16) div 32);
      Height := FCompactAppliedHeight;
    end
    else if FCompactNormalHeight > 0 then
    begin
      if Height = FCompactAppliedHeight then Height := FCompactNormalHeight;
      FCompactNormalHeight := 0;
      FCompactAppliedHeight := 0;
    end;
  end;
  if FPopup <> nil then FPopup.Synchronize;
end;

destructor TCustomThemedDateRangePicker.Destroy;
begin
  FPopup.Free;
  inherited Destroy;
end;

procedure TCustomThemedDateRangePicker.SetRange(const AStart, AEnd: TDateTime);
var
  D1, D2: TDateTime;
  Cancel: Boolean;
begin
  D1 := Trunc(AStart);
  D2 := Trunc(AEnd);
  if D1 > D2 then
  begin
    if not FSwapInvalidRange then Exit;
    D1 := Trunc(AEnd);
    D2 := Trunc(AStart);
  end;
  if (D1 < FMinDate) or (D2 > FMaxDate) then Exit;
  if (not FAllowSingleDateRange) and (D1 = D2) then Exit;
  if FHasStartDate and FHasEndDate and (FStartDate = D1) and (FEndDate = D2) then Exit;
  Cancel := False;
  if Assigned(FOnDateRangeChanging) then FOnDateRangeChanging(Self, D1, D2, Cancel);
  if Cancel then Exit;
  FStartDate := D1;
  FEndDate := D2;
  FHasStartDate := True;
  FHasEndDate := True;
  Invalidate;
  if Assigned(FOnDateRangeChanged) then FOnDateRangeChanged(Self);
end;

procedure TCustomThemedDateRangePicker.SetStartDate(const AValue: TDateTime);
begin
  if FHasEndDate then SetRange(AValue, FEndDate)
  else SetRange(AValue, AValue);
end;

procedure TCustomThemedDateRangePicker.SetEndDate(const AValue: TDateTime);
begin
  if FHasStartDate then SetRange(FStartDate, AValue)
  else SetRange(AValue, AValue);
end;

procedure TCustomThemedDateRangePicker.SetMinDate(const AValue: TDateTime);
begin
  if Trunc(AValue) > FMaxDate then Exit;
  FMinDate := Trunc(AValue);
end;

procedure TCustomThemedDateRangePicker.SetMaxDate(const AValue: TDateTime);
begin
  if Trunc(AValue) < FMinDate then Exit;
  FMaxDate := Trunc(AValue);
end;

procedure TCustomThemedDateRangePicker.SetPlaceholderText(const AValue: string);
begin
  if FPlaceholderText = AValue then Exit;
  FPlaceholderText := AValue;
  Invalidate;
end;

procedure TCustomThemedDateRangePicker.SetDateFormat(const AValue: string);
begin
  if FDateFormat = AValue then Exit;
  FDateFormat := AValue;
  Invalidate;
end;

procedure TCustomThemedDateRangePicker.SetSeparatorText(const AValue: string);
begin
  if FSeparatorText = AValue then Exit;
  FSeparatorText := AValue;
  Invalidate;
end;

procedure TCustomThemedDateRangePicker.SetStartCaption(const AValue: string);
begin
  if FStartCaption = AValue then Exit;
  FStartCaption := AValue;
  if FPopup <> nil then FPopup.Synchronize;
end;

procedure TCustomThemedDateRangePicker.SetEndCaption(const AValue: string);
begin
  if FEndCaption = AValue then Exit;
  FEndCaption := AValue;
  if FPopup <> nil then FPopup.Synchronize;
end;

procedure TCustomThemedDateRangePicker.SetApplyCaption(const AValue: string);
begin
  if FApplyCaption = AValue then Exit;
  FApplyCaption := AValue;
  if FPopup <> nil then FPopup.Synchronize;
end;

procedure TCustomThemedDateRangePicker.SetCancelCaption(const AValue: string);
begin
  if FCancelCaption = AValue then Exit;
  FCancelCaption := AValue;
  if FPopup <> nil then FPopup.Synchronize;
end;

procedure TCustomThemedDateRangePicker.SetTodayCaption(const AValue: string);
begin
  if FTodayCaption = AValue then Exit;
  FTodayCaption := AValue;
  if FPopup <> nil then FPopup.Synchronize;
end;

procedure TCustomThemedDateRangePicker.SetLast7DaysCaption(const AValue: string);
begin
  if FLast7DaysCaption = AValue then Exit;
  FLast7DaysCaption := AValue;
  if FPopup <> nil then FPopup.Synchronize;
end;

procedure TCustomThemedDateRangePicker.SetThisMonthCaption(const AValue: string);
begin
  if FThisMonthCaption = AValue then Exit;
  FThisMonthCaption := AValue;
  if FPopup <> nil then FPopup.Synchronize;
end;

procedure TCustomThemedDateRangePicker.SetShowClearButton(const AValue: Boolean);
begin
  if FShowClearButton = AValue then Exit;
  FShowClearButton := AValue;
  Invalidate;
end;

function TCustomThemedDateRangePicker.GetDisplayText: string;
begin
  if not FHasStartDate then Exit(FPlaceholderText);
  if FSelectionMode = drsmStartDateOnly then Exit(FormatDateTime(FDateFormat, FStartDate));
  if FSelectionMode = drsmEndDateOnly then Exit(FormatDateTime(FDateFormat, FEndDate));
  if FSelectionMode = drsmSingleDate then Exit(FormatDateTime(FDateFormat, FStartDate));
  Result := FormatDateTime(FDateFormat, FStartDate) + FSeparatorText +
    FormatDateTime(FDateFormat, FEndDate);
end;

procedure TCustomThemedDateRangePicker.Clear;
var
  Cancel: Boolean;
begin
  if not FAllowEmptyRange or (not FHasStartDate and not FHasEndDate) then Exit;
  Cancel := False;
  if Assigned(FOnDateRangeChanging) then FOnDateRangeChanging(Self, 0, 0, Cancel);
  if Cancel then Exit;
  FHasStartDate := False;
  FHasEndDate := False;
  Invalidate;
  if Assigned(FOnClearClicked) then FOnClearClicked(Self);
  if Assigned(FOnDateRangeChanged) then FOnDateRangeChanged(Self);
end;

procedure TCustomThemedDateRangePicker.ApplyPreset(const APreset: TDateRangePickerPreset);
var
  D, First: TDateTime;
  Y, M, Day: Word;
begin
  D := Date;
  DecodeDate(D, Y, M, Day);
  case APreset of
    drpToday: SetRange(D, D);
    drpYesterday: SetRange(D - 1, D - 1);
    drpThisWeek: begin First := D - ((DayOfWeek(D) + 5) mod 7); SetRange(First, First + 6); end;
    drpLastWeek: begin First := D - ((DayOfWeek(D) + 5) mod 7) - 7; SetRange(First, First + 6); end;
    drpThisMonth: SetRange(EncodeDate(Y, M, 1), EndOfTheMonth(D));
    drpLastMonth: begin First := IncMonth(EncodeDate(Y, M, 1), -1); SetRange(First, EndOfTheMonth(First)); end;
    drpLast7Days: SetRange(D - 6, D);
    drpLast14Days: SetRange(D - 13, D);
    drpLast30Days: SetRange(D - 29, D);
    drpThisYear: SetRange(EncodeDate(Y, 1, 1), EncodeDate(Y, 12, 31));
    drpLastYear: SetRange(EncodeDate(Y - 1, 1, 1), EncodeDate(Y - 1, 12, 31));
  end;
end;

procedure TCustomThemedDateRangePicker.Paint;
begin
  RenderCanvas.BeginRender(Canvas);
  try
    TThemedDateRangeRenderer.Render(RenderCanvas, Font, Palette, ClientRect,
      GetDisplayText, Enabled, FHot, Focused, FHasStartDate,
      FShowClearButton, CurrentPPI, StyleMode = stCompact);
  finally
    RenderCanvas.EndRender;
  end;
end;

procedure TCustomThemedDateRangePicker.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  FHot := True;
  Invalidate;
end;

procedure TCustomThemedDateRangePicker.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  FHot := False;
  Invalidate;
end;

procedure TCustomThemedDateRangePicker.CMCancelMode(var Message: TCMCancelMode);
begin
  inherited;
  if (FPopup <> nil) and FPopup.Visible then CloseDropDown;
end;

procedure TCustomThemedDateRangePicker.DoExit;
begin
  inherited DoExit;
  Invalidate;
end;

procedure TCustomThemedDateRangePicker.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button <> mbLeft) or not Enabled or FReadOnly then Exit;
  if FShowClearButton and FHasStartDate and
    (X >= ClientWidth - ScaleValue(2 * (26 - Ord(StyleMode = stCompact) * 5))) and
    (X < ClientWidth - ScaleValue(26 - Ord(StyleMode = stCompact) * 5)) then
    Clear
  else
    ShowDropDown;
end;

procedure TCustomThemedDateRangePicker.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if not Enabled or FReadOnly then Exit;
  if Key in [VK_RETURN, VK_SPACE, VK_DOWN] then
  begin
    ShowDropDown;
    Key := 0;
  end
  else if Key = VK_ESCAPE then
  begin
    CloseDropDown;
    Key := 0;
  end;
end;

procedure TCustomThemedDateRangePicker.ShowDropDown;
var
  P: TPoint;
  W, H: Integer;
begin
  if not Enabled or FReadOnly or (csDesigning in ComponentState) then Exit;
  if FPopup = nil then FPopup := TThemedDateRangePopup.CreateForPicker(Self);
  FPopup.Synchronize;
  P := ClientToScreen(Point(0, Height));
  W := ScaleValue(340);
  H := ScaleValue(194);
  if P.X + W > Screen.WorkAreaRect.Right then P.X := Screen.WorkAreaRect.Right - W;
  if P.Y + H > Screen.WorkAreaRect.Bottom then
    P.Y := ClientToScreen(Point(0, 0)).Y - H;
  FPopup.SetBounds(P.X, P.Y, W, H);
  FPopup.Show;
end;

procedure TCustomThemedDateRangePicker.CloseDropDown;
begin
  if FPopup <> nil then FPopup.Hide;
end;

constructor TThemedDateRangePopup.CreateForPicker(APicker: TCustomThemedDateRangePicker);
begin
  inherited CreateNew(APicker);
  FPicker := APicker;
  BorderStyle := Vcl.Forms.bsNone;
  Position := poDesigned;
  ShowInTaskbar := False;
  AutoScroll := False;
  FBackground := TThemedPanel.Create(Self);
  FBackground.Parent := Self;
  FBackground.Align := alClient;
  FStartLabel := TThemedLabel.Create(Self);
  FStartLabel.Parent := FBackground;
  FStartLabel.Caption := APicker.FStartCaption;
  FStartLabel.SetBounds(NimbusScaleValue(12, APicker.CurrentPPI),
    NimbusScaleValue(8, APicker.CurrentPPI), NimbusScaleValue(150, APicker.CurrentPPI),
    NimbusScaleValue(20, APicker.CurrentPPI));
  FEndLabel := TThemedLabel.Create(Self);
  FEndLabel.Parent := FBackground;
  FEndLabel.Caption := APicker.FEndCaption;
  FEndLabel.SetBounds(NimbusScaleValue(176, APicker.CurrentPPI),
    NimbusScaleValue(8, APicker.CurrentPPI), NimbusScaleValue(150, APicker.CurrentPPI),
    NimbusScaleValue(20, APicker.CurrentPPI));
  FStart := TThemedDatePicker.Create(Self);
  FStart.Parent := FBackground;
  FStart.SetBounds(NimbusScaleValue(12, APicker.CurrentPPI), NimbusScaleValue(34, APicker.CurrentPPI), NimbusScaleValue(152, APicker.CurrentPPI), NimbusScaleValue(30, APicker.CurrentPPI));
  FStart.CloseOnDateSelected := True;
  FEnd := TThemedDatePicker.Create(Self);
  FEnd.Parent := FBackground;
  FEnd.SetBounds(NimbusScaleValue(176, APicker.CurrentPPI), NimbusScaleValue(34, APicker.CurrentPPI), NimbusScaleValue(152, APicker.CurrentPPI), NimbusScaleValue(30, APicker.CurrentPPI));
  FEnd.CloseOnDateSelected := True;
  FToday := TThemedButton.Create(Self);
  FToday.Parent := FBackground;
  FToday.Caption := APicker.FTodayCaption;
  FToday.SetBounds(NimbusScaleValue(12, APicker.CurrentPPI), NimbusScaleValue(90, APicker.CurrentPPI), NimbusScaleValue(100, APicker.CurrentPPI), NimbusScaleValue(28, APicker.CurrentPPI));
  FToday.OnClick := PresetClick;
  FLast7 := TThemedButton.Create(Self);
  FLast7.Parent := FBackground;
  FLast7.Caption := APicker.FLast7DaysCaption;
  FLast7.SetBounds(NimbusScaleValue(120, APicker.CurrentPPI), NimbusScaleValue(90, APicker.CurrentPPI), NimbusScaleValue(100, APicker.CurrentPPI), NimbusScaleValue(28, APicker.CurrentPPI));
  FLast7.OnClick := PresetClick;
  FThisMonth := TThemedButton.Create(Self);
  FThisMonth.Parent := FBackground;
  FThisMonth.Caption := APicker.FThisMonthCaption;
  FThisMonth.SetBounds(NimbusScaleValue(228, APicker.CurrentPPI), NimbusScaleValue(90, APicker.CurrentPPI), NimbusScaleValue(100, APicker.CurrentPPI), NimbusScaleValue(28, APicker.CurrentPPI));
  FThisMonth.OnClick := PresetClick;
  FApply := TThemedButton.Create(Self);
  FApply.Parent := FBackground;
  FApply.Caption := APicker.FApplyCaption;
  FApply.SetBounds(NimbusScaleValue(120, APicker.CurrentPPI), NimbusScaleValue(144, APicker.CurrentPPI), NimbusScaleValue(100, APicker.CurrentPPI), NimbusScaleValue(30, APicker.CurrentPPI));
  FApply.OnClick := ApplyClick;
  FCancel := TThemedButton.Create(Self);
  FCancel.Parent := FBackground;
  FCancel.Caption := APicker.FCancelCaption;
  FCancel.SetBounds(NimbusScaleValue(228, APicker.CurrentPPI), NimbusScaleValue(144, APicker.CurrentPPI), NimbusScaleValue(100, APicker.CurrentPPI), NimbusScaleValue(30, APicker.CurrentPPI));
  FCancel.OnClick := CancelClick;
end;

procedure TThemedDateRangePopup.Synchronize;
begin
  FStart.StyleMode := FPicker.StyleMode;
  FEnd.StyleMode := FPicker.StyleMode;
  FToday.StyleMode := FPicker.StyleMode;
  FLast7.StyleMode := FPicker.StyleMode;
  FThisMonth.StyleMode := FPicker.StyleMode;
  FApply.StyleMode := FPicker.StyleMode;
  FCancel.StyleMode := FPicker.StyleMode;
  FStartLabel.Caption := FPicker.FStartCaption;
  FEndLabel.Caption := FPicker.FEndCaption;
  FApply.Caption := FPicker.FApplyCaption;
  FCancel.Caption := FPicker.FCancelCaption;
  FToday.Caption := FPicker.FTodayCaption;
  FLast7.Caption := FPicker.FLast7DaysCaption;
  FThisMonth.Caption := FPicker.FThisMonthCaption;
  FStart.MinDate := FPicker.FMinDate;
  FStart.MaxDate := FPicker.FMaxDate;
  FEnd.MinDate := FPicker.FMinDate;
  FEnd.MaxDate := FPicker.FMaxDate;
  if FPicker.FHasStartDate then FStart.Value := FPicker.FStartDate else FStart.Value := Date;
  if FPicker.FHasEndDate then FEnd.Value := FPicker.FEndDate else FEnd.Value := Date;
end;

procedure TThemedDateRangePopup.ApplyClick(Sender: TObject);
begin
  FPicker.SetRange(FStart.Value, FEnd.Value);
  if Assigned(FPicker.FOnApplyClicked) then FPicker.FOnApplyClicked(FPicker);
  Hide;
end;

procedure TThemedDateRangePopup.CancelClick(Sender: TObject);
begin
  Hide;
  if Assigned(FPicker.FOnCancelClicked) then FPicker.FOnCancelClicked(FPicker);
end;

procedure TThemedDateRangePopup.PresetClick(Sender: TObject);
var
  D, First: TDateTime;
  Y, M, Day: Word;
begin
  D := Date;
  DecodeDate(D, Y, M, Day);
  if Sender = FToday then
  begin
    FStart.Value := D;
    FEnd.Value := D;
  end
  else if Sender = FLast7 then
  begin
    FStart.Value := D - 6;
    FEnd.Value := D;
  end
  else if Sender = FThisMonth then
  begin
    First := EncodeDate(Y, M, 1);
    FStart.Value := First;
    FEnd.Value := EndOfTheMonth(First);
  end;
end;

end.

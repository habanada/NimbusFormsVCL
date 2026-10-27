procedure TMainForm.IdeRangeValidationChanged(Sender: TObject);
var
  LPicker: TThemedIdeDateRangePicker;
begin
  if (FIdeRangeValidationStatus = nil) or
    not (Sender is TThemedIdeDateRangePicker) then Exit;
  LPicker := TThemedIdeDateRangePicker(Sender);
  if LPicker.IsValid then
    FIdeRangeValidationStatus.Caption := 'IsValid = True: valid date range'
  else
    FIdeRangeValidationStatus.Caption := 'IsValid = False: ' + LPicker.ValidationMessage;
end;

procedure TMainForm.IdeRangeHitChanged(Sender: TObject;
  const AHit: TIdeDateRangeHitInfo);

var
  LText: string;
begin
  case AHit.Kind of
    idrhkNone: LText := 'No calendar target';
    idrhkDay: LText := 'Day: ' + FormatDateTime('dd mmmm yyyy', AHit.Date);
    idrhkDisabledDay: LText := 'Disabled: ' + FormatDateTime('dd mmmm yyyy', AHit.Date);
    idrhkPreviousMonth: LText := 'Previous month';
    idrhkNextMonth: LText := 'Next month';
    idrhkPreviousYear: LText := 'Previous year';
    idrhkNextYear: LText := 'Next year';
    idrhkPreset: LText := 'Preset index: ' + IntToStr(AHit.Index);
    idrhkNamedPreset: LText := 'Named preset index: ' + IntToStr(AHit.Index);
    idrhkApply: LText := 'Apply';
    idrhkCancel: LText := 'Cancel';
    idrhkClear: LText := 'Reset';
  else
    LText := 'Calendar target';
  end;
  if FIdeRangeStatus <> nil then
    FIdeRangeStatus.Caption := 'OnHitTargetChanged: ' + LText;
end;

procedure TMainForm.IdeRangeHoverHint(Sender: TObject; const ADate: TDateTime;
  var AText: string; var AShow: Boolean);
begin
  AShow := True;
  AText := FormatDateTime('dddd, dd mmmm yyyy', ADate);
  if DayOfWeek(ADate) in [1, 7] then
    AText := AText + ' - Weekend';
  if FIdeRangeHoverStatus <> nil then
    FIdeRangeHoverStatus.Caption := 'OnDayHoverHint: ' + AText;
end;

procedure TMainForm.IdeRangeDaySelecting(Sender: TObject;
  const ADate: TDateTime; var AAllow: Boolean);
begin
  if FIdeRangeStatus <> nil then
    FIdeRangeStatus.Caption := 'OnDaySelecting: ' +
      FormatDateTime('dd mmm yyyy', ADate) + ' (allowed)';
end;

procedure TMainForm.IdeRangeDayContext(Sender: TObject;
  const ADate: TDateTime; const AScreenPoint: TPoint;
  var AHandled: Boolean);
begin
  if FIdeRangeStatus <> nil then
    FIdeRangeStatus.Caption := 'OnDayContextPopup: ' +
      FormatDateTime('dd mmm yyyy', ADate);
  AHandled := True;
end;

procedure TMainForm.IdeRangeApplied(Sender: TObject);
begin
  if FIdeRangeStatus <> nil then
    FIdeRangeStatus.Caption := 'OnRangeApplied: selection committed';
end;

procedure TMainForm.IdeRangeCanceled(Sender: TObject);
begin
  if FIdeRangeStatus <> nil then
    FIdeRangeStatus.Caption := 'OnRangeCanceled: no changes committed';
end;

procedure TMainForm.IdeRangeCleared(Sender: TObject);
begin
  if FIdeRangeStatus <> nil then
    FIdeRangeStatus.Caption := 'OnRangeCleared: selection cleared';
end;

procedure TMainForm.IdeRangeDayClick(Sender: TObject; const ADate: TDateTime);
begin
  if FIdeRangeStatus <> nil then
    FIdeRangeStatus.Caption := 'Selected calendar day: ' + FormatDateTime('dd mmmm yyyy', ADate);
end;

procedure TMainForm.IdeRangeDayEnter(Sender: TObject; const ADate: TDateTime);
begin
  if FIdeRangeHoverStatus <> nil then
    FIdeRangeHoverStatus.Caption := 'OnDayMouseEnter: ' + FormatDateTime('dd mmmm yyyy', ADate);
end;

procedure TMainForm.IdeRangeDayLeave(Sender: TObject; const ADate: TDateTime);
begin
  if FIdeRangeHoverStatus <> nil then
    FIdeRangeHoverStatus.Caption := 'OnDayMouseLeave: ' + FormatDateTime('dd mmmm yyyy', ADate);
end;

procedure TMainForm.IdeRangePreview(Sender: TObject; const AStart, AEnd: TDateTime);
begin
  if FIdeRangePreviewStatus <> nil then
    FIdeRangePreviewStatus.Caption := 'OnRangePreviewChanged: ' +
      FormatDateTime('dd.mm.yyyy', AStart) + ' - ' + FormatDateTime('dd.mm.yyyy', AEnd);
end;

procedure TMainForm.IdeRangePopupOpened(Sender: TObject);
begin
  if FIdeRangeStatus <> nil then FIdeRangeStatus.Caption := 'OnPopupOpened';
end;

procedure TMainForm.IdeRangePopupClosed(Sender: TObject);
begin
  if FIdeRangeStatus <> nil then FIdeRangeStatus.Caption := 'OnPopupClosed';
end;

procedure TMainForm.IdeRangeMonthChanged(Sender: TObject; const AFirstMonth: TDateTime);
begin
  if FIdeRangeStatus <> nil then
    FIdeRangeStatus.Caption := 'OnVisibleMonthChanged: ' + FormatDateTime('mmmm yyyy', AFirstMonth);
end;

procedure TMainForm.IdeRangeDayDecoration(Sender: TObject;
  const ADate: TDateTime; var ADisabled, AHighlighted: Boolean;
  var ABadgeText: string);
begin
  if DayOfTheMonth(ADate) = 15 then
  begin
    AHighlighted := True;
    ABadgeText := '*';
  end;
  if (DayOfTheMonth(ADate) = 20) then
    ADisabled := True;
end;

procedure TMainForm.IdeRangeDayRender(Sender: TObject;
  const AInfo: TIdeDateRangeDayRenderInfo; var AText: string;
  var ABackColor, ATextColor, ABorderColor: TThemeColor;
  var AUseBackground, AUseTextColor, AUseBorder: Boolean);
begin
  if (DayOfTheMonth(AInfo.Date) = 1) and not AInfo.IsDisabled and
    not AInfo.IsEndpoint then
  begin
    AText := '1*';
    AUseBorder := True;
    AUseTextColor := False;
  end;
end;


  LDatePage := TTabSheet.Create(FTabControl);
  LDatePage.PageControl := FTabControl;
  LDatePage.Caption := SDatePickerTab;

  LDateTitle := TThemedLabel.Create(LDatePage);
  LDateTitle.Parent := LDatePage;
  LDateTitle.SetBounds(P(16), P(12), P(130), P(20));
  LDateTitle.Caption := SDatePickerTitle;
  LDateTitle.Font.Style := [fsBold];

  FDatePicker := TThemedDatePicker.Create(LDatePage);
  FDatePicker.Parent := LDatePage;
  FDatePicker.SetBounds(P(150), P(8), P(180), P(28));
  FDatePicker.MinDate := Date - 90;
  FDatePicker.MaxDate := Date + 365;
  FDatePicker.Value := Date;
  FDatePicker.PopupMenu := FPopupMenu;
  FDatePicker.OnValueChanged := DatePickerChanged;
  FDatePicker.OnDateSelected := DatePickerSelected;
  FDatePicker.OnDropDownOpened := DatePickerDropDownOpened;
  FDatePicker.OnDropDownClosed := DatePickerDropDownClosed;

  LDateTimeTitle := TThemedLabel.Create(LDatePage);
  LDateTimeTitle.Parent := LDatePage;
  LDateTimeTitle.SetBounds(P(16), P(48), P(130), P(20));
  LDateTimeTitle.Caption := SDateTimePickerTitle;
  LDateTimeTitle.Font.Style := [fsBold];

  FDateTimePicker := TThemedDatePicker.Create(LDatePage);
  FDateTimePicker.Parent := LDatePage;
  FDateTimePicker.SetBounds(P(150), P(44), P(210), P(28));
  FDateTimePicker.ShowTime := True;
  FDateTimePicker.CloseOnDateSelected := False;
  FDateTimePicker.MinuteIncrement := 15;
  FDateTimePicker.Value := Now;
  FDateTimePicker.PopupMenu := FPopupMenu;
  FDateTimePicker.OnValueChanged := DatePickerChanged;
  FDateTimePicker.OnDateSelected := DatePickerSelected;
  FDateTimePicker.OnDropDownOpened := DatePickerDropDownOpened;
  FDateTimePicker.OnDropDownClosed := DatePickerDropDownClosed;

  LDateCultureTitle := TThemedLabel.Create(LDatePage);
  LDateCultureTitle.Parent := LDatePage;
  LDateCultureTitle.SetBounds(P(16), P(84), P(130), P(20));
  LDateCultureTitle.Caption := SDateCulturePickerTitle;
  LDateCultureTitle.Font.Style := [fsBold];

  FCultureDatePicker := TThemedDatePicker.Create(LDatePage);
  FCultureDatePicker.Parent := LDatePage;
  FCultureDatePicker.SetBounds(P(150), P(80), P(300), P(28));
  FCultureDatePicker.CultureName := 'en-US';
  FCultureDatePicker.CustomFormat := 'dddd, mmmm d, yyyy';
  FCultureDatePicker.MinDate := Date - 365;
  FCultureDatePicker.MaxDate := Date + 365;
  FCultureDatePicker.Value := Date;
  FCultureDatePicker.PopupMenu := FPopupMenu;
  FCultureDatePicker.OnValueChanged := DatePickerChanged;
  FCultureDatePicker.OnDateSelected := DatePickerSelected;
  FCultureDatePicker.OnDropDownOpened := DatePickerDropDownOpened;
  FCultureDatePicker.OnDropDownClosed := DatePickerDropDownClosed;

  LDateManualTitle := TThemedLabel.Create(LDatePage);
  LDateManualTitle.Parent := LDatePage;
  LDateManualTitle.SetBounds(P(16), P(120), P(130), P(20));
  LDateManualTitle.Caption := SDateManualPickerTitle;
  LDateManualTitle.Font.Style := [fsBold];

  FManualDatePicker := TThemedDatePicker.Create(LDatePage);
  FManualDatePicker.Parent := LDatePage;
  FManualDatePicker.SetBounds(P(150), P(116), P(240), P(28));
  FManualDatePicker.CultureName := 'de-DE';
  FManualDatePicker.UseCultureFirstDayOfWeek := False;
  FManualDatePicker.FirstDayOfWeek := dpdowSunday;
  FManualDatePicker.BiDiMode := bdRightToLeft;
  FManualDatePicker.CloseOnDateSelected := False;
  FManualDatePicker.ShowTodayButton := False;
  FManualDatePicker.ShowConfirmButton := False;
  FManualDatePicker.CustomFormat := 'ddd, dd.mm.yyyy';
  FManualDatePicker.Value := Date;
  FManualDatePicker.PopupMenu := FPopupMenu;
  FManualDatePicker.OnValueChanged := DatePickerChanged;
  FManualDatePicker.OnDateSelected := DatePickerSelected;
  FManualDatePicker.OnDropDownOpened := DatePickerDropDownOpened;
  FManualDatePicker.OnDropDownClosed := DatePickerDropDownClosed;

  LDateInfo := TThemedLabel.Create(LDatePage);
  LDateInfo.Parent := LDatePage;
  LDateInfo.SetBounds(P(16), P(152), P(520), P(50));
  LDateInfo.AutoSize := False;
  LDateInfo.WordWrap := True;
  LDateInfo.UseMutedForeColor := True;
  LDateInfo.Caption := SDatePickerInfo;
  FTabControl.SetTabClosable(LDatePage, False);


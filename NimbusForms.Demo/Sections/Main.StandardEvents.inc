procedure TMainForm.NextThemeClick(Sender: TObject);
var
  LName: string;
begin
  LName := TThemePresets.GetNextName(FThemeName);
  if LName <> '' then
    ApplyThemeName(LName);
end;

procedure TMainForm.LightThemeClick(Sender: TObject);
begin
  ApplyThemeName(SLightTheme);
end;

procedure TMainForm.DarkThemeClick(Sender: TObject);
begin
  ApplyThemeName(SDarkTheme);
end;

procedure TMainForm.ProgressClick(Sender: TObject);
begin
  if FProgressBar.Position >= FProgressBar.Maximum then
    FProgressBar.Position := FProgressBar.Minimum
  else
    FProgressBar.StepBy(10);
  FProgressButton.BadgeText := Format(SProgressBadgeFormat, [FProgressBar.Position]);
end;

procedure TMainForm.CheckChanged(Sender: TObject);
begin
  if FCheckBox.Checked then
    FStatusLabel.Caption := SStatusCheckOn
  else
    FStatusLabel.Caption := SStatusCheckOff;
end;

procedure TMainForm.ToggleChanged(Sender: TObject);
begin
  if FToggleBox.Checked then
    FStatusLabel.Caption := SStatusToggleOn
  else
    FStatusLabel.Caption := SStatusToggleOff;
end;

procedure TMainForm.RadioChanged(Sender: TObject);
begin
  if FRadioOne.Checked then
    FStatusLabel.Caption := SStatusRadioOne
  else if FRadioTwo.Checked then
    FStatusLabel.Caption := SStatusRadioTwo;
end;

procedure TMainForm.ListBoxChanged(Sender: TObject);
begin
  if FListBox.ItemIndex >= 0 then
    FStatusLabel.Caption := Format(SListStatusFormat, [FListBox.Items[FListBox.ItemIndex], FListBox.SelCount]);
end;


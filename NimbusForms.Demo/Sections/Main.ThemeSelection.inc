procedure TMainForm.ApplyThemeName(const AName: string);
begin
  if not ThemeManager.SetThemeByName(AName) then
    Exit;
  FThemeName := AName;
  FThemeLabel.Caption := Format(SThemeFormat, [FThemeName]);
end;


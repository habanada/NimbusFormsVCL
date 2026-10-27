procedure TMainForm.BuildIdeStatusBar;
var
  LItem: TThemedIdeStatusBarItem;
begin
  FIdeStatusBar := TThemedIdeStatusBar.Create(Self);
  FIdeStatusBar.Parent := Self;
  FIdeStatusBar.Align := alBottom;
  FIdeStatusBar.ItemHeight := 22;
  FIdeStatusBar.Height := P(25);
  FIdeStatusBar.OnItemClicked := IdeStatusItemClick;
  LItem := FIdeStatusBar.LeftItems.Add;
  LItem.Text := SIdeStatusReady;
  LItem.Kind := sikLabel;
  LItem.Width := 90;
  LItem := FIdeStatusBar.LeftItems.Add;
  LItem.Kind := sikSeparator;
  LItem := FIdeStatusBar.LeftItems.Add;
  LItem.Text := SIdeStatusNimbus;
  LItem.Kind := sikButton;
  LItem.Hint := SIdeStatusNimbus;
  LItem := FIdeStatusBar.CenterItems.Add;
  LItem.Kind := sikProgress;
  LItem.Width := 150;
  LItem.ProgressValue := 45;
  LItem := FIdeStatusBar.RightItems.Add;
  LItem.Kind := sikButton;
  LItem.Text := SIdeStatusLine;
  LItem := FIdeStatusBar.RightItems.Add;
  LItem.Kind := sikSeparator;
  LItem := FIdeStatusBar.RightItems.Add;
  LItem.Kind := sikToggleButton;
  LItem.Text := SIdeStatusSpaces;
  LItem.Checked := True;
  LItem := FIdeStatusBar.RightItems.Add;
  LItem.Kind := sikDropDown;
  LItem.Text := SIdeStatusEncoding;
  LItem.DropDownItems.Add(SIdeStatusEncoding);
  LItem.DropDownItems.Add('UTF-16');
  LItem := FIdeStatusBar.RightItems.Add;
  LItem.Kind := sikCheckBox;
  LItem.Text := SIdeStatusDebug;
  LItem.Checked := True;
end;

procedure TMainForm.IdeStatusItemClick(Sender: TObject; AItem: TThemedIdeStatusBarItem);
begin
  if FThemeLabel <> nil then FThemeLabel.Caption := Format(SIdeStatusMessage, [AItem.Text]);
end;


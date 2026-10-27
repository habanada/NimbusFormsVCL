  LHexPage := TTabSheet.Create(FTabControl);
  LHexPage.PageControl := FTabControl;
  LHexPage.Caption := SHexEditor;
  LHexPage.PopupMenu := FPopupMenu;

  FHexStatusLabel := TThemedLabel.Create(LHexPage);
  FHexStatusLabel.Parent := LHexPage;
  FHexStatusLabel.Align := alBottom;
  FHexStatusLabel.AutoSize := False;
  FHexStatusLabel.Height := P(30);
  FHexStatusLabel.Layout := tlCenter;
  FHexStatusLabel.UseMutedForeColor := True;
  FHexStatusLabel.Caption := Format(SCursorFormat, [IntToHex(0, 8)]);

  FHexEditor := TThemedHexEditor.Create(LHexPage);
  FHexEditor.Parent := LHexPage;
  FHexEditor.Align := alClient;
  FHexEditor.OnCursorChange := HexCursorChanged;
  FHexEditor.PopupMenu := FPopupMenu;
  FTabControl.SetTabClosable(LHexPage, False);


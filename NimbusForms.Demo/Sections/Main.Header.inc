procedure TMainForm.BuildHeader;
begin
  FHeader := TThemedPanel.Create(Self);
  FHeader.Parent := Self;
  FHeader.Align := alTop;
  FHeader.Height := P(70);
  FHeader.ShowBorder := False;
  FHeader.PopupMenu := FPopupMenu;

  FTitleLabel := TThemedLabel.Create(Self);
  FTitleLabel.Parent := FHeader;
  FTitleLabel.AutoSize := False;
  FTitleLabel.SetBounds(P(20), P(14), P(340), P(24));
  FTitleLabel.Caption := SAppTitle;
  FTitleLabel.Font.Size := 14;
  FTitleLabel.Font.Style := [fsBold];

  FThemeLabel := TThemedLabel.Create(Self);
  FThemeLabel.Parent := FHeader;
  FThemeLabel.AutoSize := False;
  FThemeLabel.SetBounds(P(20), P(40), P(340), P(20));
  FThemeLabel.UseMutedForeColor := True;

  FNextThemeButton := TThemedSplitButton.Create(Self);
  FNextThemeButton.Parent := FHeader;
  FNextThemeButton.SetBounds(P(760), P(18), P(150), P(34));
  FNextThemeButton.Anchors := [akTop, akRight];
  FNextThemeButton.Caption := SNextTheme;
  FNextThemeButton.SplitWidth := 24;
  FNextThemeButton.DropDownMenu := FPopupMenu;
  FNextThemeButton.OnClick := NextThemeClick;
  FNextThemeButton.PopupMenu := FPopupMenu;

  FLightButton := TThemedButton.Create(Self);
  FLightButton.Parent := FHeader;
  FLightButton.SetBounds(P(920), P(18), P(130), P(34));
  FLightButton.Anchors := [akTop, akRight];
  FLightButton.Caption := SLightTheme;
  FLightButton.ButtonKind := tbkNormal;
  FLightButton.ButtonStyle := tbstOutline;
  FLightButton.HighlightStyle := tbhsBorder;
  FLightButton.ButtonShape := tbsRounded;
  FLightButton.OnClick := LightThemeClick;
  FLightButton.PopupMenu := FPopupMenu;

  FDarkButton := TThemedButton.Create(Self);
  FDarkButton.Parent := FHeader;
  FDarkButton.SetBounds(P(1060), P(18), P(130), P(34));
  FDarkButton.Anchors := [akTop, akRight];
  FDarkButton.Caption := SDarkTheme;
  FDarkButton.ButtonKind := tbkGhost;
  FDarkButton.ButtonStyle := tbstGhost;
  FDarkButton.HighlightStyle := tbhsAccent;
  FDarkButton.ButtonShape := tbsRounded;
  FDarkButton.OnClick := DarkThemeClick;
  FDarkButton.PopupMenu := FPopupMenu;
  FCompactSwitch := TThemedCheckBox.Create(Self);
  FCompactSwitch.Parent := FHeader;
  FCompactSwitch.SetBounds(P(1220), P(23), P(190), P(24));
  FCompactSwitch.Anchors := [akTop, akRight];
  FCompactSwitch.Caption := SCompactMode;
  FCompactSwitch.Checked := False;
  FCompactSwitch.OnCheckedChanged := CompactModeChanged;
  FToolTip.SetToolTip(FCompactSwitch, SCompactMode, SCompactModeHint, ttiInfo);
  FToolTip.SetToolTip(FNextThemeButton, SToolTipThemeTitle, SToolTipThemeText, ttiInfo);
  FToolTip.SetToolTip(FLightButton, SToolTipLightTitle, SToolTipLightText, ttiSuccess);
  FToolTip.SetToolTip(FDarkButton, SToolTipDarkTitle, SToolTipDarkText, ttiInfo);
end;

procedure TMainForm.ApplyDemoStyleMode(const AMode: TThemedControlStyleMode);

  procedure ApplyChildren(const AParent: TWinControl);
  var
    I: Integer;
    LControl: TControl;
    LProperty: PPropInfo;
  begin
    for I := 0 to AParent.ControlCount - 1 do
    begin
      LControl := AParent.Controls[I];
      LProperty := GetPropInfo(LControl.ClassInfo, 'StyleMode');
      if LProperty <> nil then
        if LProperty.PropType^.Kind = tkEnumeration then
          SetOrdProp(LControl, LProperty, Ord(AMode));
      if LControl is TWinControl then ApplyChildren(TWinControl(LControl));
    end;
  end;

begin
  ApplyChildren(Self);
end;

procedure TMainForm.CompactModeChanged(Sender: TObject);
begin
  if FCompactSwitch = nil then Exit;
  if FCompactSwitch.Checked then
    ApplyDemoStyleMode(stCompact)
  else
    ApplyDemoStyleMode(stNormal);
  if FIdeStatusBar <> nil then
  begin
    if FCompactSwitch.Checked then
    begin
      if FIdeStatusBar.ItemHeight = 22 then FIdeStatusBar.ItemHeight := 18;
      if FIdeStatusBar.Height = P(25) then FIdeStatusBar.Height := P(21);
    end
    else
    begin
      if FIdeStatusBar.ItemHeight = 18 then FIdeStatusBar.ItemHeight := 22;
      if FIdeStatusBar.Height = P(21) then FIdeStatusBar.Height := P(25);
    end;
  end;
end;


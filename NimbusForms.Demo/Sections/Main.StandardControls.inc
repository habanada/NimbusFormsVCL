procedure TMainForm.BuildStandardControls;
begin
  FControlsPanel := TThemedPanel.Create(Self);
  FControlsPanel.Parent := Self;
  FControlsPanel.Align := alLeft;
  FControlsPanel.Width := P(450);
  FControlsPanel.CornerRadius := 8;
  FControlsPanel.PopupMenu := FPopupMenu;

  FControlsLabel := TThemedLabel.Create(Self);
  FControlsLabel.Parent := FControlsPanel;
  FControlsLabel.SetBounds(P(22), P(20), P(250), P(24));
  FControlsLabel.Caption := SStandardControls;
  FControlsLabel.Font.Size := 12;
  FControlsLabel.Font.Style := [fsBold];

  FCheckBox := TThemedCheckBox.Create(Self);
  FCheckBox.Parent := FControlsPanel;
  FCheckBox.SetBounds(P(22), P(62), P(250), P(26));
  FCheckBox.Caption := SCheckBox;
  FCheckBox.AllowGrayed := True;
  FCheckBox.OnCheckedChanged := CheckChanged;
  FCheckBox.PopupMenu := FPopupMenu;

  FToggleBox := TThemedToggleBox.Create(Self);
  FToggleBox.Parent := FControlsPanel;
  FToggleBox.SetBounds(P(22), P(102), P(280), P(28));
  FToggleBox.Caption := SToggleBox;
  FToggleBox.CheckedText := SOn;
  FToggleBox.UncheckedText := SOff;
  FToggleBox.ShowStateText := True;
  FToggleBox.Checked := True;
  FToggleBox.OnCheckedChanged := ToggleChanged;
  FToggleBox.PopupMenu := FPopupMenu;

  FRadioOne := TThemedRadioButton.Create(Self);
  FRadioOne.Parent := FControlsPanel;
  FRadioOne.SetBounds(P(22), P(148), P(250), P(26));
  FRadioOne.Caption := SRadioOne;
  FRadioOne.Checked := True;
  FRadioOne.OnCheckedChanged := RadioChanged;
  FRadioOne.PopupMenu := FPopupMenu;

  FRadioTwo := TThemedRadioButton.Create(Self);
  FRadioTwo.Parent := FControlsPanel;
  FRadioTwo.SetBounds(P(22), P(178), P(250), P(26));
  FRadioTwo.Caption := SRadioTwo;
  FRadioTwo.OnCheckedChanged := RadioChanged;
  FRadioTwo.PopupMenu := FPopupMenu;

  FProgressBar := TThemedProgressBar.Create(Self);
  FProgressBar.Parent := FControlsPanel;
  FProgressBar.SetBounds(P(22), P(226), P(350), P(26));
  FProgressBar.Position := 35;
  FProgressBar.ShowPercentage := True;
  FProgressBar.CornerRadius := 6;
  FProgressBar.PopupMenu := FPopupMenu;

  FProgressButton := TThemedButton.Create(Self);
  FProgressButton.Parent := FControlsPanel;
  FProgressButton.SetBounds(P(22), P(264), P(170), P(34));
  FProgressButton.Caption := SPrimaryButton;
  FProgressButton.ButtonKind := NimbusForms.Controls.Types.tbkSuccess;
  FProgressButton.ButtonStyle := tbstFilled;
  FProgressButton.HighlightStyle := tbhsFilled;
  FProgressButton.ButtonShape := NimbusForms.Controls.Types.tbsPill;
  FProgressButton.BadgeText := Format(SProgressBadgeFormat, [FProgressBar.Position]);
  FProgressButton.OnClick := ProgressClick;
  FProgressButton.PopupMenu := FPopupMenu;
  FToolTip.SetToolTip(FProgressButton, SToolTipProgressTitle, SToolTipProgressText, ttiSuccess);

  FStatusLabel := TThemedLabel.Create(Self);
  FStatusLabel.Parent := FControlsPanel;
  FStatusLabel.AutoSize := False;
  FStatusLabel.SetBounds(P(205), P(270), P(175), P(20));
  FStatusLabel.Caption := SStatusReady;
  FStatusLabel.UseMutedForeColor := True;

  FNextGroup := TThemedGroupBox.Create(Self);
  FNextGroup.Parent := FControlsPanel;
  FNextGroup.SetBounds(P(22), P(312), P(390), P(440));
  FNextGroup.Caption := SNextControls;
  FNextGroup.PopupMenu := FPopupMenu;

  FComboBox := TThemedComboBox.Create(Self);
  FComboBox.Parent := FNextGroup;
  FComboBox.SetBounds(P(16), P(30), P(350), P(28));
  FComboBox.Items.Add(SComboAlpha);
  FComboBox.Items.Add(SComboBeta);
  FComboBox.Items.Add(SComboGamma);
  FComboBox.ItemIndex := 0;
  FComboBox.PopupMenu := FPopupMenu;

  FListBoxLabel := TThemedLabel.Create(Self);
  FListBoxLabel.Parent := FNextGroup;
  FListBoxLabel.AutoSize := False;
  FListBoxLabel.SetBounds(P(16), P(64), P(350), P(18));
  FListBoxLabel.Caption := SListBoxTitle;
  FListBoxLabel.Font.Style := [fsBold];

  FListBox := TThemedListBox.Create(Self);
  FListBox.Parent := FNextGroup;
  FListBox.SetBounds(P(16), P(84), P(350), P(72));
  FListBox.BorderStyle := bsSingle;
  FListBox.IntegralHeight := False;
  FListBox.ItemHeight := 18;
  FListBox.Visible := True;
  FListBox.Items.Add(SListRenderer);
  FListBox.Items.Add(SListGdiPlus);
  FListBox.Items.Add(SListDpi);
  FListBox.Items.Add(SListTheme);
  FListBox.Items.Add(SListKeyboard);
  FListBox.Items.Add(SListLong);
  FListBox.MultiSelect := True;
  FListBox.ExtendedSelect := True;
  FListBox.ItemIndex := 0;
  FListBox.OnClick := ListBoxChanged;
  FListBox.PopupMenu := FPopupMenu;
  FListBox.BringToFront;

  FTrackBar := TThemedTrackBar.Create(Self);
  FTrackBar.Parent := FNextGroup;
  FTrackBar.SetBounds(P(16), P(166), P(350), P(28));
  FTrackBar.Value := 35;
  FTrackBar.OnValueChanged := TrackBarChanged;
  FTrackBar.PopupMenu := FPopupMenu;

  FSeparator := TThemedSeparator.Create(Self);
  FSeparator.Parent := FNextGroup;
  FSeparator.SetBounds(P(16), P(204), P(350), P(10));
  FSeparator.Thickness := 1;
  FSeparator.PopupMenu := FPopupMenu;

  FTextBox := TThemedTextBox.Create(Self);
  FTextBox.Parent := FNextGroup;
  FTextBox.SetBounds(P(16), P(224), P(350), P(32));
  FTextBox.Text := STextBoxValue;
  FTextBox.PrefixText := STextBoxPrefix;
  FTextBox.ShowClearButton := True;
  FTextBox.UseRoundedCorners := True;
  FTextBox.InputMode := timEmail;
  FTextBox.OnEnterPressed := TextBoxEnterPressed;
  FTextBox.OnClearClicked := TextBoxClearClicked;
  FTextBox.PopupMenu := FPopupMenu;
  FTextBox.Editor.PopupMenu := FPopupMenu;

  FNumericUpDown := TThemedNumericUpDown.Create(Self);
  FNumericUpDown.Parent := FNextGroup;
  FNumericUpDown.SetBounds(P(16), P(266), P(170), P(30));
  FNumericUpDown.Minimum := 0;
  FNumericUpDown.Maximum := 100;
  FNumericUpDown.Increment := 0.5;
  FNumericUpDown.DecimalPlaces := 1;
  FNumericUpDown.Value := 42.5;
  FNumericUpDown.PopupMenu := FPopupMenu;
  FNumericUpDown.Editor.PopupMenu := FPopupMenu;

  FRating := TThemedRatingControl.Create(Self);
  FRating.Parent := FNextGroup;
  FRating.SetBounds(P(198), P(266), P(168), P(30));
  FRating.ItemSize := 20;
  FRating.StarSpacing := 3;
  FRating.Precision := rpHalf;
  FRating.RatingValue := 3.5;
  FRating.ShowValueText := True;
  FRating.OnValueChanged := RatingChanged;
  FRating.PopupMenu := FPopupMenu;
  FToolTip.SetToolTip(FRating, SRatingToolTipTitle, SRatingToolTipText, ttiInfo);

  FRangeTrackBar := TThemedRangeTrackBar.Create(Self);
  FRangeTrackBar.Parent := FNextGroup;
  FRangeTrackBar.SetBounds(P(16), P(308), P(350), P(60));
  FRangeTrackBar.Minimum := 0;
  FRangeTrackBar.Maximum := 100;
  FRangeTrackBar.StartValue := 20;
  FRangeTrackBar.EndValue := 80;
  FRangeTrackBar.ShowValueLabels := True;
  FRangeTrackBar.PopupMenu := FPopupMenu;

  FHScrollBar := TThemedHScrollBar.Create(Self);
  FHScrollBar.Parent := FNextGroup;
  FHScrollBar.SetBounds(P(16), P(374), P(350), P(18));
  FHScrollBar.Minimum := 0;
  FHScrollBar.Maximum := 100;
  FHScrollBar.LargeChange := 20;
  FHScrollBar.SmallChange := 2;
  FHScrollBar.Value := 30;
  FHScrollBar.OnValueChanged := ScrollBarChanged;
  FHScrollBar.PopupMenu := FPopupMenu;

  FVScrollBar := TThemedVScrollBar.Create(Self);
  FVScrollBar.Parent := FNextGroup;
  FVScrollBar.SetBounds(P(368), P(30), P(18), P(338));
  FVScrollBar.Minimum := 0;
  FVScrollBar.Maximum := 100;
  FVScrollBar.LargeChange := 20;
  FVScrollBar.SmallChange := 2;
  FVScrollBar.Value := 60;
  FVScrollBar.OnValueChanged := ScrollBarChanged;
  FVScrollBar.PopupMenu := FPopupMenu;

  FDropdown := TThemedDropdown.Create(Self);
  FDropdown.Parent := FNextGroup;
  FDropdown.SetBounds(P(16), P(402), P(350), P(28));
  FDropdown.StyleMode := tdsIdeCompact;
  FDropdown.EmptyText := SDropdownEmpty;
  FDropdown.ClearButtonMode := tdcWhenSelected;
  FDropdown.AutoCompleteEnabled := True;
  FDropdown.AutoCompleteMinimumCharacters := 0;
  FDropdown.AddGroup(SDropdownGroupCore);
  FDropdown.AddItem(SDropdownButton, 'button');
  FDropdown.AddItem(SDropdownToggle, 'toggle');
  FDropdown.AddItem(SDropdownRadio, 'radio');
  FDropdown.AddSeparator;
  FDropdown.AddGroup(SDropdownGroupRender);
  FDropdown.AddItem(SDropdownGdiPlus, 'gdiplus');
  FDropdown.AddItem(SDropdownTheme, 'theme');
  FDropdown.SelectedIndex := 1;
  FDropdown.OnSelectedIndexChanged := DropdownChanged;
  FDropdown.PopupMenu := FPopupMenu;
  FDropdown.Editor.PopupMenu := FPopupMenu;

  FRichEditLabel := TThemedLabel.Create(Self);
  FRichEditLabel.Parent := FControlsPanel;
  FRichEditLabel.SetBounds(P(22), P(758), P(250), P(24));
  FRichEditLabel.Caption := SRichEditTitle;
  FRichEditLabel.Font.Style := [fsBold];

  FRichEdit := TThemedRichEdit.Create(Self);
  FRichEdit.Parent := FControlsPanel;
  FRichEdit.SetBounds(P(22), P(784), P(390), P(96));
  FRichEdit.Anchors := [akLeft, akTop, akRight];
  FRichEdit.CornerRadius := 6;
  FRichEdit.InnerPadding := 8;
  FRichEdit.TabStop := True;
  FRichEdit.PopupMenu := FPopupMenu;
  FRichEdit.Editor.PopupMenu := FPopupMenu;
  FRichEdit.Lines.BeginUpdate;
  try
    FRichEdit.Lines.Add(SRichEditLine1);
    FRichEdit.Lines.Add('');
    FRichEdit.Lines.Add(SRichEditLine2);
    FRichEdit.Lines.Add('');
    FRichEdit.Lines.Add(SRichEditLine3);
  finally
    FRichEdit.Lines.EndUpdate;
  end;

  FHintLabel := TThemedLabel.Create(Self);
  FHintLabel.Parent := FControlsPanel;
  FHintLabel.AutoSize := False;
  FHintLabel.SetBounds(P(22), P(888), P(390), P(34));
  FHintLabel.Caption := SRightClickHint;
  FHintLabel.WordWrap := True;
  FHintLabel.UseMutedForeColor := True;
end;


  LColorPage := TTabSheet.Create(FTabControl);
  LColorPage.PageControl := FTabControl;
  LColorPage.Caption := 'IDE ColorPicker';
  FTabControl.SetTabClosable(LColorPage, False);

  FIdeColorStatus := TThemedLabel.Create(LColorPage);
  FIdeColorStatus.Parent := LColorPage;
  FIdeColorStatus.SetBounds(P(18), P(70), P(650), P(40));
  FIdeColorStatus.AutoSize := False;
  FIdeColorStatus.Caption := 'Palette library: choose a category and palette. Standalone editor: separate tab.';

  LColorButton := TThemedIdeColorPickerButton.Create(LColorPage);
  LColorButton.Parent := LColorPage;
  LColorButton.SetBounds(P(18), P(14), P(145), P(26));
  LColorButton.ButtonText := 'Basic colors';
  LColorButton.PaletteMode := icpmBasic;
  LColorButton.CommitMode := iccmImmediate;
  LColorButton.OnSelectedColorChanged := IdeColorChanged;
  LColorButton.OnColorSelected := IdeColorSelected;

  LColorButton := TThemedIdeColorPickerButton.Create(LColorPage);
  LColorButton.Parent := LColorPage;
  LColorButton.SetBounds(P(175), P(14), P(145), P(26));
  LColorButton.ButtonText := 'Gradient picker';
  LColorButton.PaletteMode := icpmGradient;
  LColorButton.CommitMode := iccmOkCancel;
  LColorButton.OnSelectedColorChanged := IdeColorChanged;
  LColorButton.OnColorSelected := IdeColorSelected;

  LColorButton := TThemedIdeColorPickerButton.Create(LColorPage);
  LColorButton.Parent := LColorPage;
  LColorButton.SetBounds(P(332), P(14), P(145), P(26));
  LColorButton.ButtonText := 'Custom colors';
  LColorButton.PaletteMode := icpmCustom;
  LColorButton.CommitMode := iccmImmediate;
  LColorButton.OnSelectedColorChanged := IdeColorChanged;
  LColorButton.OnColorSelected := IdeColorSelected;
  LColorButton.Picker.AddCustomColor(clOlive);
  LColorButton.Picker.AddCustomColor(clFuchsia);

  LColorButton := TThemedIdeColorPickerButton.Create(LColorPage);
  LColorButton.Parent := LColorPage;
  LColorButton.SetBounds(P(489), P(14), P(165), P(26));
  LColorButton.ButtonText := 'Palette library';
  LColorButton.PaletteMode := icpmLibrary;
  LColorButton.CommitMode := iccmImmediate;
  LColorButton.OnSelectedColorChanged := IdeColorChanged;
  LColorButton.OnColorSelected := IdeColorSelected;

  LColorStandalonePage := TTabSheet.Create(FTabControl);
  LColorStandalonePage.PageControl := FTabControl;
  LColorStandalonePage.Caption := 'ColorPicker Standalone';
  FTabControl.SetTabClosable(LColorStandalonePage, False);
  with TThemedLabel.Create(LColorStandalonePage) do
  begin
    Parent := LColorStandalonePage;
    SetBounds(P(18), P(14), P(650), P(28));
    AutoSize := False;
    Caption := 'Standalone color editor (always visible). Compact size profile.';
  end;

  LColorPicker := TThemedIdeColorPicker.Create(LColorStandalonePage);
  LColorPicker.Parent := LColorStandalonePage;
  LColorPicker.SetBounds(P(18), P(50), P(340), P(344));
  LColorPicker.SizeMode := icsmCompact;
  LColorPicker.PaletteMode := icpmAll;
  LColorPicker.CommitMode := iccmOkCancel;
  LColorPicker.OnSelectedColorChanged := IdeColorChanged;
  LColorPicker.OnColorSelected := IdeColorSelected;
  LColorPicker.ShowAlpha := True;
  LColorPicker.ShowCopyButton := True;
  LColorPicker.AddCustomColor(clRed);
  LColorPicker.AddCustomColor(clLime);
  LColorPicker.AddCustomColor(clAqua);


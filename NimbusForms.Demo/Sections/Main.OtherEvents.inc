procedure TMainForm.TabChanged(Sender: TObject);
begin
  if (FTabControl.ActivePage <> nil) then FStatusLabel.Caption := Format(STabChangedFormat, [FTabControl.ActivePage.Caption]);
end;

procedure TMainForm.TabClosed(Sender: TObject; ATabIndex: Integer; ATabPage: TTabSheet; AReason: TThemedTabCloseReason);
begin
  if ATabPage <> nil then FStatusLabel.Caption := Format(STabClosedFormat, [ATabPage.Caption]);
end;

procedure TMainForm.TabReordered(Sender: TObject; ATabPage: TTabSheet; AOldIndex, ANewIndex: Integer);
begin
  if ATabPage <> nil then FStatusLabel.Caption := Format(STabReorderedFormat, [ATabPage.Caption, AOldIndex, ANewIndex]);
end;

procedure TMainForm.IdeColorChanged(Sender: TObject; AOldColor, ANewColor: TColor);
begin
  if FIdeColorStatus <> nil then
    FIdeColorStatus.Caption := Format('OnSelectedColorChanged: #%2.2x%2.2x%2.2x -> #%2.2x%2.2x%2.2x',
      [GetRValue(ColorToRGB(AOldColor)), GetGValue(ColorToRGB(AOldColor)), GetBValue(ColorToRGB(AOldColor)),
       GetRValue(ColorToRGB(ANewColor)), GetGValue(ColorToRGB(ANewColor)), GetBValue(ColorToRGB(ANewColor))]);
end;

procedure TMainForm.IdeColorSelected(Sender: TObject; AColor: TColor; const ASource: string);
begin
  if FIdeColorStatus <> nil then
    FIdeColorStatus.Caption := 'OnColorSelected ('+ASource+'): '+
      Format('#%2.2x%2.2x%2.2x',
        [GetRValue(ColorToRGB(AColor)), GetGValue(ColorToRGB(AColor)), GetBValue(ColorToRGB(AColor))]);
end;

procedure TMainForm.DatePickerChanged(Sender: TObject);
var
  LPicker: TThemedDatePicker;
  LSettings: TFormatSettings;
begin
  if not (Sender is TThemedDatePicker) then Exit;
  LPicker := TThemedDatePicker(Sender);
  if LPicker.CultureName = '' then LSettings := TFormatSettings.Create else LSettings := TFormatSettings.Create(LPicker.CultureName);
  FStatusLabel.Caption := Format(SDatePickerStatusFormat, [FormatDateTime(LPicker.CustomFormat, LPicker.Value, LSettings)]);
end;

procedure TMainForm.DatePickerSelected(Sender: TObject);
var
  LPicker: TThemedDatePicker;
  LSettings: TFormatSettings;
begin
  if not (Sender is TThemedDatePicker) then Exit;
  LPicker := TThemedDatePicker(Sender);
  if LPicker.CultureName = '' then LSettings := TFormatSettings.Create else LSettings := TFormatSettings.Create(LPicker.CultureName);
  FStatusLabel.Caption := Format(SDatePickerSelectedFormat, [FormatDateTime(LPicker.CustomFormat, LPicker.Value, LSettings)]);
end;

procedure TMainForm.DatePickerDropDownOpened(Sender: TObject);
begin
  FStatusLabel.Caption := SDatePickerOpened;
end;

procedure TMainForm.DatePickerDropDownClosed(Sender: TObject);
begin
  FStatusLabel.Caption := SDatePickerClosed;
end;

procedure TMainForm.TextBoxEnterPressed(Sender: TObject);
begin
  if FTextBox.ValidateText then
    FStatusLabel.Caption := SStatusTextBoxValid
  else
    FStatusLabel.Caption := SStatusTextBoxInvalid;
end;

procedure TMainForm.TextBoxClearClicked(Sender: TObject);
begin
  FTextBox.ValidateText;
  FStatusLabel.Caption := SStatusTextBoxCleared;
end;

procedure TMainForm.HexCursorChanged(Sender: TObject);
begin
  FHexStatusLabel.Caption := Format(SCursorFormat, [IntToHex(FHexEditor.CursorPosition, 8)]);
end;

procedure TMainForm.PopupItemClick(Sender: TObject);
begin
  if not (Sender is TMenuItem) then
    Exit;
  case TMenuItem(Sender).Tag of
    CMenuDark: ApplyThemeName(SDarkTheme);
    CMenuLight: ApplyThemeName(SLightTheme);
    CMenuNext: NextThemeClick(Sender);
    CMenuResetProgress:
      begin
        FProgressBar.Position := FProgressBar.Minimum;
        FProgressButton.BadgeText := Format(SProgressBadgeFormat, [FProgressBar.Position]);
      end;
    CMenuExit: Close;
  end;
end;

procedure TMainForm.TreePopupItemClick(Sender: TObject);
var
  LNode: TTreeNode;
  LThemedNode: TThemedTreeNode;
begin
  if not (Sender is TMenuItem) or (FTreeView = nil) then Exit;
  LNode := FTreeView.Selected;
  if LNode = nil then Exit;
  case TMenuItem(Sender).Tag of
    CTreeMenuRename:
      FTreeView.BeginRename(LNode);
    CTreeMenuExpand:
      if LNode.HasChildren then LNode.Expand(False);
    CTreeMenuCollapse:
      if LNode.HasChildren then LNode.Collapse(False);
    CTreeMenuFavorite:
      if LNode is TThemedTreeNode then
      begin
        LThemedNode := TThemedTreeNode(LNode);
        if not LThemedNode.Disabled and not LThemedNode.IsSeparator then
        begin
          LThemedNode.IsFavorite := not LThemedNode.IsFavorite;
          FTreeView.Invalidate;
        end;
      end;
  end;
end;


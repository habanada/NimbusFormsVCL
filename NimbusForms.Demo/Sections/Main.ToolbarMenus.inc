procedure TMainForm.ToolButtonClick(Sender: TObject);
begin
  if (FToolButtonStatus <> nil) and (Sender is TThemedToolButton) then FToolButtonStatus.Caption := Format(SToolButtonClickStatusFormat, [TThemedToolButton(Sender).Caption]);
end;

procedure TMainForm.ToolButtonCheckedChanged(Sender: TObject);
begin
  if (FToolButtonStatus <> nil) and (Sender is TThemedToolButton) then FToolButtonStatus.Caption := Format(SToolButtonCheckedStatusFormat, [TThemedToolButton(Sender).Caption, BoolToStr(TThemedToolButton(Sender).Checked, True)]);
end;

procedure TMainForm.ToolButtonDropDownClick(Sender: TObject; const APart: TThemedToolButtonPart);
begin
  if (FToolButtonStatus <> nil) and (Sender is TThemedToolButton) then FToolButtonStatus.Caption := Format(SToolButtonDropDownStatusFormat, [TThemedToolButton(Sender).Caption, Ord(APart)]);
end;

procedure TMainForm.ToolBarButtonClick(Sender: TObject);
begin
  if (FToolBarStatus <> nil) and (Sender is TThemedToolButton) then FToolBarStatus.Caption := Format(SToolBarClickStatusFormat, [TThemedToolButton(Sender).Caption]);
end;

procedure TMainForm.ToolBarEmbeddedChange(Sender: TObject);
begin
  if FToolBarStatus = nil then Exit;
  if Sender is TThemedComboBox then
    FToolBarStatus.Caption := Format(SToolBarEmbeddedStatusFormat, [SToolBarConfig, TThemedComboBox(Sender).Text])
  else if Sender is TThemedTextBox then
    FToolBarStatus.Caption := Format(SToolBarEmbeddedStatusFormat, [SToolBarSearch, TThemedTextBox(Sender).Text]);
end;

procedure TMainForm.AddMenuBarPopupItem(const AMenu: TThemedPopupMenu; const ACaption: string; const ATag: Integer);
var
  LItem: TMenuItem;
  LImageIndex: Integer;
begin
  LItem := TMenuItem.Create(AMenu);
  LItem.Caption := ACaption;
  LItem.Tag := ATag;
  if ACaption <> '-' then
  begin
    case ATag of
      201, 202, 203, 204: LImageIndex := 0;
      211, 212, 213, 214, 215: LImageIndex := 1;
      221, 222: LImageIndex := 2;
      231, 232, 233: LImageIndex := 3;
      241: LImageIndex := 5;
    else
      LImageIndex := -1;
    end;
    LItem.ImageIndex := MenuDemoImageIndex(AMenu.Images, LImageIndex);
    LItem.OnClick := MenuBarPopupItemClick;
  end;
  AMenu.Items.Add(LItem);
end;

procedure TMainForm.MenuBarItemClick(Sender: TObject; AItem: TThemedMenuBarItem);
var
  LCaption: string;
begin
  if (FMenuBarStatus = nil) or (AItem = nil) then Exit;
  LCaption := StringReplace(AItem.Caption, '&', '', [rfReplaceAll]);
  FMenuBarStatus.Caption := Format(SMenuBarItemStatusFormat, [LCaption]);
end;

procedure TMainForm.MenuBarMenuOpening(Sender: TObject; AItem: TThemedMenuBarItem);
var
  LCaption: string;
begin
  if (FMenuBarStatus = nil) or (AItem = nil) then Exit;
  LCaption := StringReplace(AItem.Caption, '&', '', [rfReplaceAll]);
  FMenuBarStatus.Caption := Format(SMenuBarOpeningStatusFormat, [LCaption]);
end;

procedure TMainForm.MenuBarTextChanged(Sender: TObject; AItem: TThemedMenuBarItem; const AOldText, ANewText: string);
begin
  if (FMenuBarStatus = nil) or (AItem = nil) then Exit;
  FMenuBarStatus.Caption := Format(SMenuBarTextStatusFormat, [ANewText]);
end;

procedure TMainForm.MenuBarSelectedIndexChanged(Sender: TObject; AItem: TThemedMenuBarItem; const ASelectedIndex: Integer);
begin
  if (FMenuBarStatus = nil) or (AItem = nil) then Exit;
  FMenuBarStatus.Caption := Format(SMenuBarSelectionStatusFormat, [AItem.Caption]);
end;

procedure TMainForm.MenuBarWidthChanged(Sender: TObject);
var
  LWidth: Integer;
begin
  if (FMenuBarDemoControl = nil) or (FMenuBarWidthSlider = nil) or (FMenuBarDemoPanel = nil) then Exit;
  LWidth := FMenuBarWidthSlider.Value;
  if LWidth > FMenuBarDemoPanel.ClientWidth then LWidth := FMenuBarDemoPanel.ClientWidth;
  if LWidth < 1 then LWidth := 1;
  FMenuBarDemoControl.Width := LWidth;
  if FMenuBarWidthLabel <> nil then FMenuBarWidthLabel.Caption := Format(SMenuBarOverflowWidthFormat, [LWidth]);
end;

procedure TMainForm.MenuBarDemoResized(Sender: TObject);
begin
  MenuBarWidthChanged(Sender);
end;

procedure TMainForm.MenuBarPopupItemClick(Sender: TObject);
begin
  if (FMenuBarStatus <> nil) and (Sender is TMenuItem) then
    FMenuBarStatus.Caption := Format(SMenuBarPopupStatusFormat, [StringReplace(TMenuItem(Sender).Caption, '&', '', [rfReplaceAll])]);
end;

procedure TMainForm.StyledLabelLinkClick(Sender: TObject; const ATarget: string);
begin
  if FStyledLabelStatus <> nil then FStyledLabelStatus.Caption := Format(SStyledLabelLinkStatusFormat, [ATarget]);
end;


  LStyledPage := TTabSheet.Create(FTabControl);
  LStyledPage.PageControl := FTabControl;
  LStyledPage.Caption := SStyledLabelTab;

  FStyledLabelStatus := TThemedLabel.Create(LStyledPage);
  FStyledLabelStatus.Parent := LStyledPage;
  FStyledLabelStatus.Align := alBottom;
  FStyledLabelStatus.AutoSize := False;
  FStyledLabelStatus.Height := P(28);
  FStyledLabelStatus.Layout := tlCenter;
  FStyledLabelStatus.UseMutedForeColor := True;
  FStyledLabelStatus.Caption := SStyledLabelStatus;

  LStyledLabel := TThemedStyledLabel.Create(LStyledPage);
  LStyledLabel.Parent := LStyledPage;
  LStyledLabel.Align := alClient;
  LStyledLabel.AutoSize := False;
  LStyledLabel.WordWrap := True;
  LStyledLabel.TextPadding.SetBounds(24, 20, 24, 20);
  LStyledLabel.Font.Size := 10;
  LStyledLabel.LineSpacing := 4;
  LStyledLabel.Caption := SStyledLabelMarkup;
  LStyledLabel.PopupMenu := FPopupMenu;
  LStyledLabel.OnLinkClick := StyledLabelLinkClick;
  FTabControl.SetTabClosable(LStyledPage, False);


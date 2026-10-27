  LToolPage := TTabSheet.Create(FTabControl);
  LToolPage.PageControl := FTabControl;
  LToolPage.Caption := SToolButtonTab;

  LToolButton := TThemedToolButton.Create(LToolPage);
  LToolButton.Parent := LToolPage;
  LToolButton.SetBounds(P(18), P(18), P(84), P(30));
  LToolButton.Caption := SToolButtonNew;
  LToolButton.Icon.Assign(Application.Icon);
  LToolButton.OnClick := ToolButtonClick;

  LToolButton := TThemedToolButton.Create(LToolPage);
  LToolButton.Parent := LToolPage;
  LToolButton.SetBounds(P(106), P(18), P(78), P(30));
  LToolButton.Caption := SToolButtonOpen;
  LToolButton.HighlightStyle := ttbhsVisualStudioToolButton;
  LToolButton.OnClick := ToolButtonClick;

  LToolButton := TThemedToolButton.Create(LToolPage);
  LToolButton.Parent := LToolPage;
  LToolButton.SetBounds(P(188), P(18), P(78), P(30));
  LToolButton.Caption := SToolButtonSave;
  LToolButton.ButtonStyle := ttbsFilled;
  LToolButton.UseThemeAccent := True;
  LToolButton.OnClick := ToolButtonClick;

  LToolButton := TThemedToolButton.Create(LToolPage);
  LToolButton.Parent := LToolPage;
  LToolButton.SetBounds(P(270), P(18), P(72), P(30));
  LToolButton.Caption := SToolButtonBold;
  LToolButton.ButtonStyle := ttbsGhost;
  LToolButton.Checkable := True;
  LToolButton.Checked := True;
  LToolButton.OnCheckedChanged := ToolButtonCheckedChanged;

  LToolButton := TThemedToolButton.Create(LToolPage);
  LToolButton.Parent := LToolPage;
  LToolButton.SetBounds(P(346), P(18), P(104), P(30));
  LToolButton.Caption := SToolButtonOptions;
  LToolButton.DropDownMode := ttbddArrow;
  LToolButton.DropDownMenu := FPopupMenu;
  LToolButton.OnDropDownClick := ToolButtonDropDownClick;

  LToolButton := TThemedToolButton.Create(LToolPage);
  LToolButton.Parent := LToolPage;
  LToolButton.SetBounds(P(454), P(18), P(98), P(30));
  LToolButton.Caption := SToolButtonSplit;
  LToolButton.ButtonStyle := ttbsOutline;
  LToolButton.DropDownMode := ttbddSplit;
  LToolButton.DropDownMenu := FPopupMenu;
  LToolButton.OnClick := ToolButtonClick;
  LToolButton.OnDropDownClick := ToolButtonDropDownClick;

  FToolButtonStatus := TThemedLabel.Create(LToolPage);
  FToolButtonStatus.Parent := LToolPage;
  FToolButtonStatus.SetBounds(P(18), P(64), P(620), P(28));
  FToolButtonStatus.AutoSize := False;
  FToolButtonStatus.Layout := tlCenter;
  FToolButtonStatus.UseMutedForeColor := True;
  FToolButtonStatus.Caption := SToolButtonStatusReady;
  FTabControl.SetTabClosable(LToolPage, False);


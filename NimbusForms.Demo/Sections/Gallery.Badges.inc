  LBadgePage := TTabSheet.Create(FTabControl);
  LBadgePage.PageControl := FTabControl;
  LBadgePage.Caption := 'BadgeLabel';
  LBadgeX := P(20);
  for LBadgeIndex := 0 to 5 do
  begin
    LBadge := TThemedBadgeLabel.Create(LBadgePage);
    LBadge.Parent := LBadgePage;
    LBadge.BadgeShape := NimbusForms.Rendering.BadgeLabel.tbsPill;
    case LBadgeIndex of
      0: begin LBadge.BadgeKind := NimbusForms.Rendering.BadgeLabel.tbkSuccess; LBadge.Caption := SBadgeSuccess; end;
      1: begin LBadge.BadgeKind := NimbusForms.Rendering.BadgeLabel.tbkWarning; LBadge.Caption := SBadgeWarning; end;
      2: begin LBadge.BadgeKind := NimbusForms.Rendering.BadgeLabel.tbkError; LBadge.Caption := SBadgeError; end;
      3: begin LBadge.BadgeKind := NimbusForms.Rendering.BadgeLabel.tbkInfo; LBadge.Caption := SBadgeInformation; end;
      4: begin LBadge.BadgeKind := NimbusForms.Rendering.BadgeLabel.tbkNeutral; LBadge.Caption := SBadgeBeta; end;
      5: begin LBadge.BadgeKind := NimbusForms.Rendering.BadgeLabel.tbkAccent; LBadge.Caption := SBadgeNew; end;
    end;
    LBadge.SetBounds(LBadgeX, P(26), LBadge.Width, LBadge.Height);
    Inc(LBadgeX, LBadge.Width + P(10));
  end;

  LBadge := TThemedBadgeLabel.Create(LBadgePage);
  LBadge.Parent := LBadgePage;
  LBadge.SetBounds(P(20), P(85), P(100), P(24));
  LBadge.Caption := SBadgeClosable;
  LBadge.BadgeKind := NimbusForms.Rendering.BadgeLabel.tbkInfo;
  LBadge.ShowCloseButton := True;
  LBadge.Clickable := True;
  LBadge.ShowBorder := True;

  LBadge := TThemedBadgeLabel.Create(LBadgePage);
  LBadge.Parent := LBadgePage;
  LBadge.SetBounds(P(145), P(85), P(65), P(24));
  LBadge.UseValueMode := True;
  LBadge.Value := 120;
  LBadge.MaxValue := 99;
  LBadge.BadgeKind := NimbusForms.Rendering.BadgeLabel.tbkError;

  LBadge := TThemedBadgeLabel.Create(LBadgePage);
  LBadge.Parent := LBadgePage;
  LBadge.SetBounds(P(235), P(85), P(85), P(24));
  LBadge.Caption := SBadgeRounded;
  LBadge.BadgeShape := NimbusForms.Rendering.BadgeLabel.tbsRoundedRectangle;
  LBadge.BadgeKind := NimbusForms.Rendering.BadgeLabel.tbkSuccess;
  FTabControl.SetTabClosable(LBadgePage, False);


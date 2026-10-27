  LTagPage := TTabSheet.Create(FTabControl);
  LTagPage.PageControl := FTabControl;
  LTagPage.Caption := STagInputTab;

  LTagTitle := TThemedLabel.Create(LTagPage);
  LTagTitle.Parent := LTagPage;
  LTagTitle.SetBounds(P(18), P(18), P(740), P(28));
  LTagTitle.AutoSize := False;
  LTagTitle.Caption := STagInputHint;

  LTagInput := TThemedTagInput.Create(LTagPage);
  LTagInput.Parent := LTagPage;
  LTagInput.SetBounds(P(18), P(56), P(560), P(36));
  LTagInput.TagColorMode := ttcmColorful;
  LTagInput.AddTag('NimbusForms');
  LTagInput.AddTag('Delphi');
  LTagInput.AddTag('GDI+');
  LTagInput.AddTag('VCL');
  LTagInput.AddTag('Tags');

  LTagTitle := TThemedLabel.Create(LTagPage);
  LTagTitle.Parent := LTagPage;
  LTagTitle.SetBounds(P(18), P(108), P(560), P(24));
  LTagTitle.Caption := 'Harmonized theme colors';

  LTagInput := TThemedTagInput.Create(LTagPage);
  LTagInput.Parent := LTagPage;
  LTagInput.SetBounds(P(18), P(140), P(560), P(36));
  LTagInput.TagColorMode := ttcmHarmonized;
  LTagInput.AddTag('NimbusForms');
  LTagInput.AddTag('Delphi');
  LTagInput.AddTag('GDI+');
  LTagInput.AddTag('VCL');
  LTagInput.AddTag('Tags');

  LTagTitle := TThemedLabel.Create(LTagPage);
  LTagTitle.Parent := LTagPage;
  LTagTitle.SetBounds(P(18), P(192), P(560), P(24));
  LTagTitle.Caption := 'Uniform theme color';

  LTagInput := TThemedTagInput.Create(LTagPage);
  LTagInput.Parent := LTagPage;
  LTagInput.SetBounds(P(18), P(224), P(560), P(36));
  LTagInput.TagColorMode := ttcmUniform;
  LTagInput.AddTag('NimbusForms');
  LTagInput.AddTag('Delphi');
  LTagInput.AddTag('GDI+');
  LTagInput.AddTag('VCL');
  LTagInput.AddTag('Tags');
  FTabControl.SetTabClosable(LTagPage, False);


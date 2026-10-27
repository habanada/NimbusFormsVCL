  LStepPage := TTabSheet.Create(FTabControl);
  LStepPage.PageControl := FTabControl;
  LStepPage.Caption := 'StepIndicator';

  LStepTitle := TThemedLabel.Create(LStepPage);
  LStepTitle.Parent := LStepPage;
  LStepTitle.SetBounds(P(18), P(12), P(680), P(22));
  LStepTitle.Caption := 'Normal: completed, active, warning and failed';

  LStep := TThemedStepIndicator.Create(LStepPage);
  LStep.Parent := LStepPage;
  LStep.SetBounds(P(18), P(42), P(740), P(80));
  LStep.Steps.Clear;
  LStep.Steps.Add.Caption := 'Start';
  LStep.Steps.Add.Caption := 'Validate';
  LStep.Steps.Add.Caption := 'Configure';
  LStep.Steps.Add.Caption := 'Deploy';
  LStep.Steps.Add.Caption := 'Finish';
  LStep.CurrentStep := 2;
  LStep.Steps[1].Status := tssCompleted;
  LStep.Steps[3].Status := tssWarning;
  LStep.Steps[4].Status := tssFailed;
  FStepDemo := LStep;
  FStepDemo.OnStepChanging := StepDemoChanging;
  FStepDemo.OnStepIndexChanged := StepDemoChanged;
  FStepDemo.OnStepClick := StepDemoClick;
  FStepDemo.OnStepStatusChanged := StepDemoStatusChanged;

  LStepTitle := TThemedLabel.Create(LStepPage);
  LStepTitle.Parent := LStepPage;
  LStepTitle.SetBounds(P(18), P(132), P(680), P(22));
  LStepTitle.Caption := 'Compact: click steps or use arrow keys';

  LStep := TThemedStepIndicator.Create(LStepPage);
  LStep.Parent := LStepPage;
  LStep.SetBounds(P(18), P(162), P(740), P(64));
  LStep.Density := tsdCompact;
  LStep.Steps.Clear;
  LStep.Steps.Add.Caption := 'Start';
  LStep.Steps.Add.Caption := 'Check';
  LStep.Steps.Add.Caption := 'Warning';
  LStep.Steps.Add.Caption := 'Finish';
  LStep.CurrentStep := 1;
  LStep.Steps[2].Status := tssWarning;

  LStepTitle := TThemedLabel.Create(LStepPage);
  LStepTitle.Parent := LStepPage;
  LStepTitle.SetBounds(P(18), P(236), P(680), P(22));
  LStepTitle.Caption := 'Ultra compact: antialiased symbols without numbers';

  LStep := TThemedStepIndicator.Create(LStepPage);
  LStep.Parent := LStepPage;
  LStep.SetBounds(P(18), P(268), P(740), P(40));
  LStep.Density := tsdUltraCompact;
  LStep.Steps.Clear;
  LStep.Steps.Add.Caption := 'Start';
  LStep.Steps.Add.Caption := 'Done';
  LStep.Steps.Add.Caption := 'Warning';
  LStep.Steps.Add.Caption := 'Failed';
  LStep.Steps.Add.Caption := 'Ready';
  LStep.CurrentStep := 1;
  LStep.Steps[2].Status := tssWarning;
  LStep.Steps[3].Status := tssFailed;

  FStepDemoInfo := TThemedLabel.Create(LStepPage);
  FStepDemoInfo.Parent := LStepPage;
  FStepDemoInfo.SetBounds(P(18), P(319), P(740), P(24));
  FStepDemoInfo.Caption := 'Step 3 selected - use the controls below';
  for LStepButtonIndex := 0 to 3 do
  begin
    LStepButton := TThemedButton.Create(LStepPage);
    LStepButton.Parent := LStepPage;
    LStepButton.Tag := LStepButtonIndex;
    LStepButton.SetBounds(P(18 + LStepButtonIndex * 164), P(351), P(154), P(32));
    case LStepButtonIndex of
      0: LStepButton.Caption := 'Previous';
      1: LStepButton.Caption := 'Next';
      2: LStepButton.Caption := 'ReadOnly: off';
      3: LStepButton.Caption := 'Toggle Warning';
    end;
    LStepButton.OnClick := StepDemoButtonClick;
  end;
  FStepDemo.AllowFutureNavigation := False;
  FTabControl.SetTabClosable(LStepPage, False);


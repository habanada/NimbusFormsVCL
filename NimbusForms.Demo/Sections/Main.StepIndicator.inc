procedure TMainForm.StepDemoButtonClick(Sender: TObject);
var LButton: TThemedButton;
begin
  if FStepDemo = nil then Exit;
  LButton := TThemedButton(Sender);
  case LButton.Tag of
    0: FStepDemo.PreviousStep;
    1: FStepDemo.NextStep;
    2: begin
      FStepDemo.ReadOnly := not FStepDemo.ReadOnly;
      if FStepDemo.ReadOnly then LButton.Caption := 'ReadOnly: on'
      else LButton.Caption := 'ReadOnly: off';
    end;
    3: begin
      if FStepDemo.Steps[3].Status = tssWarning then FStepDemo.SetStepStatus(3, tssFailed)
      else FStepDemo.SetStepStatus(3, tssWarning);
    end;
  end;
end;

procedure TMainForm.StepDemoChanging(Sender: TObject; AOldIndex, ANewIndex: Integer; var AAllow: Boolean);
begin
  AAllow := True;
end;

procedure TMainForm.StepDemoChanged(Sender: TObject; AOldIndex, ANewIndex: Integer);
begin
  if FStepDemoInfo <> nil then FStepDemoInfo.Caption := Format('Step changed: %d -> %d', [AOldIndex + 1, ANewIndex + 1]);
end;

procedure TMainForm.StepDemoClick(Sender: TObject; AIndex: Integer);
begin
  if FStepDemoInfo <> nil then FStepDemoInfo.Caption := Format('Step clicked: %d', [AIndex + 1]);
end;

procedure TMainForm.StepDemoStatusChanged(Sender: TObject; AIndex: Integer; AOldStatus, ANewStatus: TThemedStepStatus);
begin
  if FStepDemoInfo <> nil then FStepDemoInfo.Caption := Format('Status changed: step %d (%d -> %d)', [AIndex + 1, Ord(AOldStatus), Ord(ANewStatus)]);
end;


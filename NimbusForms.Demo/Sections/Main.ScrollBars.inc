procedure TMainForm.TrackBarChanged(Sender: TObject);
begin
  FStatusLabel.Caption := Format(STrackValueFormat, [FTrackBar.Value]);
end;

procedure TMainForm.BuildIDEScrollBarDemo;
var
  LPage: TTabSheet;
  LBar: TThemedIDEScrollBar;
  LLabel: TThemedLabel;
  I: Integer;

  procedure AddMarker(AFirst, ALast: Integer; AShape: TNimbusIDEMarkerShape; ALane: TNimbusIDEMarkerLane; ATone: TNimbusIDEMarkerTone; const AHint: string);
  var
    LMarker: TThemedIDEScrollBarMarker;
  begin
    LMarker := LBar.AddMarker(AFirst, ALast, AShape, ALane, ATone);
    LMarker.Hint := AHint;
  end;
begin
  LPage := TTabSheet.Create(FTabControl);
  LPage.PageControl := FTabControl;
  LPage.Caption := 'IDE Scrollbar';
  FTabControl.SetTabClosable(LPage, False);

  LLabel := TThemedLabel.Create(LPage);
  LLabel.Parent := LPage;
  LLabel.Caption := 'Clickable overview markers, independent left/right lanes, themed colors and shapes';
  LLabel.SetBounds(P(20), P(16), P(850), P(28));

  FIDEScrollStatus := TThemedLabel.Create(LPage);
  FIDEScrollStatus.Parent := LPage;
  FIDEScrollStatus.Caption := 'Click any marker to inspect its First / Last range';
  FIDEScrollStatus.SetBounds(P(20), P(58), P(900), P(28));
  for I := 0 to 2 do
  begin
    LLabel := TThemedLabel.Create(LPage);
    LLabel.Parent := LPage;
    case I of
      0: LLabel.Caption := 'Editor diagnostics';
      1: LLabel.Caption := 'Search and symbols';
    else
      LLabel.Caption := 'Mixed ranges';
    end;
    LLabel.SetBounds(P(26 + I * 220), P(106), P(200), P(25));
    LBar := TThemedIDEScrollBar.Create(LPage);
    LBar.Parent := LPage;
    LBar.SetBounds(P(80 + I * 220), P(143), P(40), P(420));
    LBar.Minimum := 0;
    LBar.Maximum := 1000;
    LBar.SmallChange := 10;
    LBar.LargeChange := 80;
    LBar.Value := 220 + I * 150;
    LBar.MarkerWidth := 7;
    LBar.ShowHint := True;
    LBar.OnMarkerClick := IDEScrollMarkerClick;
    LBar.OnMarkerEnter := IDEScrollMarkerEnter;
    LBar.OnValueChanged := IDEScrollValueChanged;
    case I of
      0:
      begin
        AddMarker(70, 120, imsBar, imlLeft, imtInfo, 'Search results: 70 - 120');
        AddMarker(260, 265, imsLine, imlRight, imtError, 'Error: 260');
        AddMarker(350, 460, imsBar, imlLeft, imtAccent, 'Selection: 350 - 460');
        AddMarker(720, 730, imsRectangle, imlRight, imtWarning, 'Warning: 720 - 730');
        AddMarker(890, 950, imsBar, imlLeft, imtSuccess, 'Passed checks: 890 - 950');
      end;
      1:
      begin
        AddMarker(110, 110, imsCircle, imlRight, imtSuccess, 'Bookmark: 110');
        AddMarker(185, 185, imsCircle, imlRight, imtInfo, 'Symbol: 185');
        AddMarker(380, 380, imsLine, imlLeft, imtAccent, 'Match: 380');
        AddMarker(540, 540, imsCircle, imlRight, imtWarning, 'Bookmark: 540');
        AddMarker(760, 760, imsRectangle, imlRight, imtError, 'Issue: 760');
      end;
    else
      begin
        AddMarker(100, 250, imsBar, imlLeft, imtAccent, 'Changed lines: 100 - 250');
        AddMarker(210, 210, imsCircle, imlRight, imtWarning, 'Review note: 210');
        AddMarker(430, 490, imsRectangle, imlRight, imtError, 'Errors: 430 - 490');
        AddMarker(600, 600, imsLine, imlLeft, imtInfo, 'Search match: 600');
        AddMarker(820, 930, imsBar, imlRight, imtSuccess, 'Verified block: 820 - 930');
      end;
    end;
  end;
end;

procedure TMainForm.IDEScrollMarkerClick(Sender: TObject; AMarker: TThemedIDEScrollBarMarker; AFirst, ALast: Integer);
begin
  FIDEScrollStatus.Caption := Format('Marker clicked: %d - %d | %s', [AFirst, ALast, AMarker.Hint]);
end;

procedure TMainForm.IDEScrollMarkerEnter(Sender: TObject; AMarker: TThemedIDEScrollBarMarker; AFirst, ALast: Integer);
begin
  if AMarker <> nil then FIDEScrollStatus.Caption := Format('Hover: %d - %d | %s', [AFirst, ALast, AMarker.Hint]);
end;

procedure TMainForm.IDEScrollValueChanged(Sender: TObject);
begin
  FIDEScrollStatus.Caption := Format('Scroll position: %d', [TThemedIDEScrollBar(Sender).Value]);
end;

procedure TMainForm.ScrollBarChanged(Sender: TObject);
begin
  FStatusLabel.Caption := Format(SScrollValueFormat, [FHScrollBar.Value, FVScrollBar.Value]);
end;

procedure TMainForm.DropdownChanged(Sender: TObject);
begin
  if FDropdown.SelectedItem <> nil then
    FStatusLabel.Caption := Format(SDropdownStatusFormat, [FDropdown.SelectedItem.Text]);
end;

procedure TMainForm.RatingChanged(Sender: TObject);
begin
  FStatusLabel.Caption := Format(SRatingStatusFormat, [FormatFloat('0.#', FRating.RatingValue), FRating.Maximum]);
end;


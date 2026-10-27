procedure TMainForm.BuildVirtualListItem(const AIndex: Integer; out AItem: TThemedVirtualListItemData);
begin
  AItem := Default(TThemedVirtualListItemData);
  AItem.ImageIndex := -1;
  AItem.Text := Format(SVirtualListItemFormat, [AIndex + 1]);
  AItem.Subtitle := SVirtualListSubtitle;
  AItem.DetailText := Format(SVirtualListDetailFormat, [AIndex + 1]);
  AItem.Enabled := (AIndex mod 29) <> 0;
  if (AIndex mod 11) = 0 then
  begin
    AItem.BadgeText := SVirtualListBadgeHot;
    AItem.AccentColor := clRed;
  end
  else if (AIndex mod 17) = 0 then
  begin
    AItem.BadgeText := SVirtualListBadgeSync;
    AItem.AccentColor := clAqua;
  end
  else
    case AIndex mod 4 of
      0: AItem.AccentColor := clLime;
      1: AItem.AccentColor := clAqua;
      2: AItem.AccentColor := clYellow;
    else
      AItem.AccentColor := clFuchsia;
    end;
  case AIndex mod 4 of
    0: AItem.StatusColor := clLime;
    1: AItem.StatusColor := clAqua;
    2: AItem.StatusColor := clYellow;
  else
    AItem.StatusColor := clNone;
  end;
  AItem.ShowProgress := (AIndex mod 7) = 0;
  AItem.ProgressValue := AIndex mod 101;
end;

function TMainForm.VirtualListSourceIndex(const ARowIndex: Integer): Integer;
begin
  if FVirtualListFilterText = '' then Exit(ARowIndex);
  if (ARowIndex < 0) or (ARowIndex >= Length(FVirtualListFilteredIndices)) then Exit(-1);
  Result := FVirtualListFilteredIndices[ARowIndex];
end;

procedure TMainForm.VirtualListGetItem(Sender: TObject; AIndex: Integer; var AItem: TThemedVirtualListItemData);
var
  LSourceIndex: Integer;
begin
  LSourceIndex := VirtualListSourceIndex(AIndex);
  if LSourceIndex >= 0 then BuildVirtualListItem(LSourceIndex, AItem);
end;

procedure TMainForm.VirtualListRequestItems(Sender: TObject; AStartIndex, ACount: Integer; var AItems: TThemedVirtualListItemDataArray; var ACancel: Boolean);
var
  I, LCount, LSourceIndex: Integer;
begin
  ACancel := False;
  LCount := ACount;
  if Length(AItems) < LCount then LCount := Length(AItems);
  for I := 0 to LCount - 1 do
  begin
    LSourceIndex := VirtualListSourceIndex(AStartIndex + I);
    if LSourceIndex >= 0 then BuildVirtualListItem(LSourceIndex, AItems[I]);
  end;
end;

procedure TMainForm.VirtualListGetCellText(Sender: TObject; ARowIndex: Integer; AColumn: TThemedVirtualListColumn; var AText: string);
var
  LSourceIndex: Integer;
begin
  LSourceIndex := VirtualListSourceIndex(ARowIndex);
  if LSourceIndex < 0 then Exit;
  case AColumn.Index of
    0: AText := Format(SVirtualListItemFormat, [LSourceIndex + 1]);
    1:
      if LSourceIndex = FVirtualListEditedRow then AText := FVirtualListEditedProvider else AText := SVirtualListSubtitle;
    2: AText := Format(SVirtualListDetailFormat, [LSourceIndex + 1]);
    3:
      if (LSourceIndex mod 11) = 0 then AText := SVirtualListBadgeHot
      else if (LSourceIndex mod 17) = 0 then AText := SVirtualListBadgeSync
      else AText := '';
    4: AText := Format(SVirtualListProgressFormat, [LSourceIndex mod 101]);
  end;
end;

procedure TMainForm.VirtualListSortRequested(Sender: TObject; AColumn: TThemedVirtualListColumn; ADirection: TThemedVirtualListSortDirection; AMultiColumn: Boolean);
begin
  FStatusLabel.Caption := Format(SVirtualListSortFormat, [AColumn.HeaderText, Ord(ADirection)]);
end;

procedure TMainForm.VirtualListFilterRequested(Sender: TObject; const AFilterText: string; var AItemCount: Integer);
var
  I, LCount: Integer;
  LFilter, LText, LProvider: string;
begin
  LFilter := LowerCase(Trim(AFilterText));
  FVirtualListFilterText := LFilter;
  if LFilter = '' then
  begin
    SetLength(FVirtualListFilteredIndices, 0);
    AItemCount := 100000;
  end
  else
  begin
    SetLength(FVirtualListFilteredIndices, 100000);
    LCount := 0;
    for I := 0 to 99999 do
    begin
      if I = FVirtualListEditedRow then LProvider := FVirtualListEditedProvider else LProvider := SVirtualListSubtitle;
      LText := LowerCase(Format(SVirtualListItemFormat, [I + 1]) + ' ' + LProvider + ' ' + Format(SVirtualListDetailFormat, [I + 1]) + ' ' + Format(SVirtualListProgressFormat, [I mod 101]));
      if (I mod 11) = 0 then LText := LText + ' ' + LowerCase(SVirtualListBadgeHot);
      if (I mod 17) = 0 then LText := LText + ' ' + LowerCase(SVirtualListBadgeSync);
      if Pos(LFilter, LText) > 0 then
      begin
        FVirtualListFilteredIndices[LCount] := I;
        Inc(LCount);
      end;
    end;
    SetLength(FVirtualListFilteredIndices, LCount);
    AItemCount := LCount;
  end;
  FStatusLabel.Caption := Format(SVirtualListFilterFormat, [AFilterText, AItemCount]);
end;

procedure TMainForm.VirtualListCellValidating(Sender: TObject; ARowIndex: Integer; AColumn: TThemedVirtualListColumn; const AOldValue: string; var ANewValue: string; var ACancel: Boolean);
begin
  ANewValue := Trim(ANewValue);
  ACancel := (AColumn = nil) or (AColumn.Index <> 1) or (ANewValue = '');
  if ACancel then FStatusLabel.Caption := SVirtualListEditRejected;
end;

procedure TMainForm.VirtualListCellEditCommitted(Sender: TObject; ARowIndex: Integer; AColumn: TThemedVirtualListColumn; const AOldValue, ANewValue: string);
var
  LSourceIndex: Integer;
begin
  LSourceIndex := VirtualListSourceIndex(ARowIndex);
  if (LSourceIndex < 0) or (AColumn = nil) then Exit;
  FVirtualListEditedRow := LSourceIndex;
  FVirtualListEditedProvider := ANewValue;
  FStatusLabel.Caption := Format(SVirtualListEditFormat, [LSourceIndex + 1, AColumn.HeaderText, ANewValue]);
end;

procedure TMainForm.VirtualListGetRowHeight(Sender: TObject; ARowIndex: Integer; const AItem: TThemedVirtualListItemData; var AHeight: Integer);
var
  LSourceIndex: Integer;
begin
  LSourceIndex := VirtualListSourceIndex(ARowIndex);
  if (LSourceIndex >= 0) and ((LSourceIndex mod 9) = 0) then AHeight := 34;
end;

procedure TMainForm.VirtualListGetRowKind(Sender: TObject; ARowIndex: Integer; const AItem: TThemedVirtualListItemData; var ARowKind: TThemedVirtualListRowKind);
var
  LSourceIndex: Integer;
begin
  LSourceIndex := VirtualListSourceIndex(ARowIndex);
  if (LSourceIndex > 0) and ((LSourceIndex mod 2500) = 0) then ARowKind := vlrkSeparator;
end;

procedure TMainForm.VirtualListGetGroupText(Sender: TObject; ARowIndex: Integer; const AItem: TThemedVirtualListItemData; var AText: string);
var
  LSourceIndex: Integer;
begin
  LSourceIndex := VirtualListSourceIndex(ARowIndex);
  if LSourceIndex >= 0 then AText := Format(SVirtualListGroupFormat, [LSourceIndex div 10000 + 1]);
end;

procedure TMainForm.VirtualListRowDetailsExpandedChanged(Sender: TObject; ARowIndex: Integer; AExpanded: Boolean);
var
  LState: string;
begin
  if AExpanded then LState := SVirtualListExpanded else LState := SVirtualListCollapsed;
  FStatusLabel.Caption := Format(SVirtualListDetailsFormat, [ARowIndex + 1, LState]);
end;

procedure TMainForm.VirtualListSelectionChanged(Sender: TObject);
begin
  if FVirtualList <> nil then FStatusLabel.Caption := Format(SVirtualListStatusFormat, [FVirtualList.SelectedCount, FVirtualList.SelectedIndex + 1]);
end;

procedure TMainForm.VirtualListItemActivate(Sender: TObject; AIndex: Integer);
begin
  FStatusLabel.Caption := Format(SVirtualListActivateFormat, [AIndex + 1]);
end;

procedure TMainForm.VirtualListCheckChanged(Sender: TObject; AIndex: Integer; AState: TThemedVirtualListCheckState);
begin
  FStatusLabel.Caption := Format(SVirtualListCheckFormat, [AIndex + 1, Ord(AState)]);
end;


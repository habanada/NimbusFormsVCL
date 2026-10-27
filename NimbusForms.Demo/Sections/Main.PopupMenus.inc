procedure TMainForm.BuildPopupMenu;
begin
  FPopupMenu := TThemedPopupMenu.Create(Self);
  AddPopupItem(SMenuDark, CMenuDark);
  AddPopupItem(SMenuLight, CMenuLight);
  AddPopupItem(SMenuNext, CMenuNext);
  AddPopupItem('-', 0);
  AddPopupItem(SMenuResetProgress, CMenuResetProgress);
  AddPopupItem('-', 0);
  AddPopupItem(SMenuExit, CMenuExit);
end;

procedure TMainForm.AddPopupItem(const ACaption: string; const ATag: Integer);
var
  LItem: TMenuItem;
begin
  LItem := TMenuItem.Create(FPopupMenu);
  LItem.Caption := ACaption;
  LItem.Tag := ATag;
  if ACaption <> '-' then
    LItem.OnClick := PopupItemClick;
  FPopupMenu.Items.Add(LItem);
end;

procedure TMainForm.BuildTreePopupMenu;
begin
  FTreePopupMenu := TThemedPopupMenu.Create(Self);
  AddTreePopupItem(STreeMenuRename, CTreeMenuRename);
  AddTreePopupItem('-', 0);
  AddTreePopupItem(STreeMenuExpand, CTreeMenuExpand);
  AddTreePopupItem(STreeMenuCollapse, CTreeMenuCollapse);
  AddTreePopupItem('-', 0);
  AddTreePopupItem(STreeMenuFavorite, CTreeMenuFavorite);
end;

procedure TMainForm.AddTreePopupItem(const ACaption: string; const ATag: Integer);
var
  LItem: TMenuItem;
begin
  LItem := TMenuItem.Create(FTreePopupMenu);
  LItem.Caption := ACaption;
  LItem.Tag := ATag;
  if ACaption <> '-' then LItem.OnClick := TreePopupItemClick;
  FTreePopupMenu.Items.Add(LItem);
end;


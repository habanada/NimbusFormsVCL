constructor TMainForm.CreateNew(AOwner: TComponent; Dummy: Integer);
begin
  inherited CreateNew(AOwner, Dummy);
  OnCloseQuery := HexWorkspaceCloseQuery;
  Caption := SAppTitle;
  Position := poScreenCenter;
  Scaled := True;
  DoubleBuffered := True;
  ClientWidth := P(1440);
  ClientHeight := P(960);
  Constraints.MinWidth := P(1180);
  Constraints.MinHeight := P(760);
  FVirtualListEditedRow := -1;
  BuildPopupMenu;

  FToolTip := TThemedToolTip.Create(Self);
  FToolTip.ShowTitleSeparator := True;
  FToolTip.MaxWidth := 420;
  BuildHeader;
  BuildStandardControls;
  BuildHexEditor;
  BuildIdeStatusBar;
  AddNimbusChartsDemo(FTabControl);
  AddRemainingNimbusChartsDemo(FTabControl);
  AddNimbusMiniGallery(FTabControl);
  AddNimbusMicroGallery(FTabControl);
  AddNimbusDashboardGallery(FTabControl);
  AddNimbusPerformanceGallery(FTabControl);
  AddNimbusPropertyGridGallery(FTabControl);
  AddNotificationBarDemo(FTabControl);
  AddLogViewerDemo(FTabControl);
  AddCodeEditorDemo(FTabControl);
  AddInteractiveNimbusGridDemo(FTabControl);
  AddAdvancedNimbusHexDemo(FTabControl);
  PopupMenu := FPopupMenu;
  LoadHexSample;
  ApplyThemeName(SDarkTheme);
end;

procedure TMainForm.HexWorkspaceCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  I, J: Integer;
begin
  CanClose := False;
  if FTabControl <> nil then
    for I := 0 to FTabControl.PageCount - 1 do
      for J := 0 to FTabControl.Pages[I].ComponentCount - 1 do
        if FTabControl.Pages[I].Components[J] is TAdvancedHexDemo then
          if not TAdvancedHexDemo(FTabControl.Pages[I].Components[J]).ConfirmChanges then Exit;
  CanClose := True;
end;


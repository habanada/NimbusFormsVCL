function TMainForm.AddTabPage(const ACaption, AText: string): TTabSheet;
var
  LLabel: TThemedLabel;
begin
  Result := TTabSheet.Create(FTabControl);
  Result.PageControl := FTabControl;
  Result.Caption := ACaption;

  LLabel := TThemedLabel.Create(Result);
  LLabel.Parent := Result;
  LLabel.Align := alClient;
  LLabel.AutoSize := False;
  LLabel.Alignment := taCenter;
  LLabel.Layout := tlCenter;
  LLabel.WordWrap := True;
  LLabel.UseMutedForeColor := True;
  LLabel.Caption := AText;
  LLabel.PopupMenu := FPopupMenu;
end;


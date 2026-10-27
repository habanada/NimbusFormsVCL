  LAvatarPage := TTabSheet.Create(FTabControl);
  LAvatarPage.PageControl := FTabControl;
  LAvatarPage.Caption := 'Avatar';

  LAvatarTitle := TThemedLabel.Create(LAvatarPage);
  LAvatarTitle.Parent := LAvatarPage;
  LAvatarTitle.SetBounds(P(18), P(12), P(750), P(26));
  LAvatarTitle.Caption := 'ImageList / ImageIndex, initials, status, counter, star and shapes';
  LAvatarCandidates[0] := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'avatars';
  LAvatarCandidates[1] := IncludeTrailingPathDelimiter(GetCurrentDir) + 'avatars';
  LAvatarCandidates[2] := ExpandFileName(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + '..\avatars');
  LAvatarCandidates[3] := ExpandFileName(IncludeTrailingPathDelimiter(GetCurrentDir) + '..\avatars');
  LAvatarDir := '';
  for LAvatarCandidateIndex := Low(LAvatarCandidates) to High(LAvatarCandidates) do
    if DirectoryExists(LAvatarCandidates[LAvatarCandidateIndex]) then
    begin
      LAvatarDir := LAvatarCandidates[LAvatarCandidateIndex];
      Break;
    end;
  LAvatarFiles := TStringList.Create;
  try
    if LAvatarDir <> '' then
    begin
      if FindFirst(IncludeTrailingPathDelimiter(LAvatarDir) + '*.jpg', faAnyFile, LAvatarSearch) = 0 then
      try
        repeat
          if (LAvatarSearch.Attr and faDirectory) = 0 then LAvatarFiles.Add(IncludeTrailingPathDelimiter(LAvatarDir) + LAvatarSearch.Name);
        until FindNext(LAvatarSearch) <> 0;
      finally
        FindClose(LAvatarSearch);
      end;
      if FindFirst(IncludeTrailingPathDelimiter(LAvatarDir) + '*.jpeg', faAnyFile, LAvatarSearch) = 0 then
      try
        repeat
          if (LAvatarSearch.Attr and faDirectory) = 0 then LAvatarFiles.Add(IncludeTrailingPathDelimiter(LAvatarDir) + LAvatarSearch.Name);
        until FindNext(LAvatarSearch) <> 0;
      finally
        FindClose(LAvatarSearch);
      end;
    end;
    LAvatarFiles.Sort;
  for LAvatarIndex := 0 to 8 do
  begin
    LAvatar := TThemedAvatar.Create(LAvatarPage);
    LAvatar.Parent := LAvatarPage;
    LAvatar.SetBounds(P(20 + (LAvatarIndex mod 5) * 138), P(60 + (LAvatarIndex div 5) * 122), P(72), P(72));
    LAvatar.Text := 'Nimbus Forms';
    LAvatar.ShowStatus := True;
    case LAvatarIndex mod 4 of
      0: LAvatar.Status := tavsOnline;
      1: LAvatar.Status := tavsAway;
      2: LAvatar.Status := tavsBusy;
      3: LAvatar.Status := tavsOffline;
    end;
    case LAvatarIndex mod 3 of
      0: LAvatar.Shape := tasCircle;
      1: LAvatar.Shape := tasRounded;
      2: LAvatar.Shape := tasSquare;
    end;
    LAvatar.ShowStar := LAvatarIndex in [2, 5, 8];
    LAvatar.ShowCounter := LAvatarIndex in [3, 6, 7];
    LAvatar.Counter := 3 + LAvatarIndex;
    if LAvatarFiles.Count > 0 then LAvatar.Picture.LoadFromFile(LAvatarFiles[LAvatarIndex mod LAvatarFiles.Count])
    else
    if LAvatarIndex in [0, 4] then
    begin
      LAvatar.Images := LMenuImages;
      LAvatar.ImageIndex := 0;
    end;
    if (LAvatarFiles.Count = 0) and (LAvatarIndex = 1) and (LMenuImages.Count > 0) then LMenuImages.GetBitmap(0, LAvatar.Picture.Bitmap);
    if LAvatarIndex = 8 then LAvatar.ShowInitials := False;
  end;
  finally
    LAvatarFiles.Free;
  end;
  FTabControl.SetTabClosable(LAvatarPage, False);


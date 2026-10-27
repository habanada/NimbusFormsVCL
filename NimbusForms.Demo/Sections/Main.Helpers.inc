function TMainForm.P(const AValue: Integer): Integer;
begin
  Result := MulDiv(AValue, CurrentPPI, 96);
end;

function TMainForm.LoadDemoIcons(const AImages: TImageList): Integer;
const
  CIconFiles: array[0..6] of string = ('infoCenter.ico', 'git-gui.ico', 'check.ico', 'wsl.ico', 'TrayLight.ico', 'onenotecapture.ico', 'caq.ico');

var
  LDirectories: array[0..3] of string;
  LDirectory: string;
  LFileName: string;
  LIcon: TIcon;
  I: Integer;
begin
  Result := 0;
  if AImages = nil then Exit;
  LDirectories[0] := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'ico';
  LDirectories[1] := IncludeTrailingPathDelimiter(GetCurrentDir) + 'ico';
  LDirectories[2] := ExpandFileName(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + '..\ico');
  LDirectories[3] := ExpandFileName(IncludeTrailingPathDelimiter(GetCurrentDir) + '..\ico');
  LDirectory := '';
  for I := Low(LDirectories) to High(LDirectories) do
    if DirectoryExists(LDirectories[I]) then
    begin
      LDirectory := LDirectories[I];
      Break;
    end;
  LIcon := TIcon.Create;
  try
    for I := Low(CIconFiles) to High(CIconFiles) do
    begin
      LFileName := '';
      if LDirectory <> '' then
        LFileName := IncludeTrailingPathDelimiter(LDirectory) + CIconFiles[I];
      if (LFileName <> '') and FileExists(LFileName) then
      begin
        LIcon.LoadFromFile(LFileName);
        AImages.AddIcon(LIcon);
        Continue;
      end;
      AImages.AddIcon(Application.Icon);
    end;
    Result := AImages.Count;
  finally
    LIcon.Free;
  end;
end;

function TMainForm.MenuDemoImageIndex(const AImages: TCustomImageList; const AIndex: Integer): Integer;
begin
  Result := -1;
  if (AImages <> nil) and (AIndex >= 0) and (AIndex < AImages.Count) then Result := AIndex;
end;


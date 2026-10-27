function TestProjectRoot: string;
var Directory, ParentDirectory: string;
begin
  Directory := ExcludeTrailingPathDelimiter(ExpandFileName(ExtractFilePath(ParamStr(0))));
  while Directory <> '' do
  begin
    if FileExists(TPath.Combine(Directory, 'LICENSE')) and DirectoryExists(TPath.Combine(Directory, 'NimbusForms.Controls\src')) then Exit(Directory);
    ParentDirectory := ExtractFileDir(Directory);
    if SameFileName(ParentDirectory, Directory) then Break;
    Directory := ParentDirectory;
  end;
  raise Exception.Create('Test executable must be located inside the repository');
end;

function TestFixtureRoot: string;
begin
  Result := TPath.GetFullPath(TPath.Combine(ExtractFilePath(ParamStr(0)), 'fixtures'));
  if not Result.StartsWith(IncludeTrailingPathDelimiter(TestProjectRoot), True) then raise Exception.Create('Test fixtures outside repository');
end;

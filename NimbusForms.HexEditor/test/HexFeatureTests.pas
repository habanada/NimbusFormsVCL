program HexFeatureTests;

{$APPTYPE CONSOLE}

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.IOUtils, System.Generics.Collections, Vcl.Forms, Vcl.Controls,
  NimbusForms.HexEditor.Control, NimbusForms.HexEditor.DataSource, NimbusForms.HexEditor.Document,
  NimbusForms.HexEditor.Session, NimbusForms.HexEditor.Search, NimbusForms.HexEditor.SearchProviders,
  NimbusForms.HexEditor.Encoding, NimbusForms.HexEditor.Undo, NimbusForms.HexEditor.Types,
  NimbusForms.HexEditor.Bookmarks, NimbusForms.Theming.Types;

type
  TTestHexEditor = class(TThemedHexEditor)
  public
    procedure SendKey(const AKey: Word; const AShift: TShiftState);
  end;

  TEventObserver = class
  public
    Requests: Integer;
    DataSource: THexDataSourceInfo;
    Selection: THexSelectionInfo;
    CursorOffset: THexCursorOffsetInfo;
    UndoRedoState: THexUndoRedoStateInfo;
    Search: THexSearchInfo;
    EditMode: THexEditModeInfo;
    Modified: THexModifiedInfo;
    procedure DataSourceChanged(Sender: TObject; const AInfo: THexDataSourceInfo);
    procedure SelectionChanged(Sender: TObject; const AInfo: THexSelectionInfo);
    procedure CursorOffsetChanged(Sender: TObject; const AInfo: THexCursorOffsetInfo);
    procedure UndoRedoStateChanged(Sender: TObject; const AInfo: THexUndoRedoStateInfo);
    procedure SearchChanged(Sender: TObject; const AInfo: THexSearchInfo);
    procedure EditModeChanged(Sender: TObject; const AInfo: THexEditModeInfo);
    procedure ModifiedChanged(Sender: TObject; const AInfo: THexModifiedInfo);
    procedure Request(Sender: TObject);
  end;

procedure TTestHexEditor.SendKey(const AKey: Word; const AShift: TShiftState);
var
  LKey: Word;
begin
  LKey := AKey;
  KeyDown(LKey, AShift);
end;

procedure TEventObserver.Request(Sender: TObject);
begin
  Inc(Requests);
end;

procedure TEventObserver.DataSourceChanged(Sender: TObject; const AInfo: THexDataSourceInfo);
begin
  DataSource := AInfo;
end;

procedure TEventObserver.SelectionChanged(Sender: TObject; const AInfo: THexSelectionInfo);
begin
  Selection := AInfo;
end;

procedure TEventObserver.CursorOffsetChanged(Sender: TObject; const AInfo: THexCursorOffsetInfo);
begin
  CursorOffset := AInfo;
end;

procedure TEventObserver.UndoRedoStateChanged(Sender: TObject; const AInfo: THexUndoRedoStateInfo);
begin
  UndoRedoState := AInfo;
end;

procedure TEventObserver.SearchChanged(Sender: TObject; const AInfo: THexSearchInfo);
begin
  Search := AInfo;
end;

procedure TEventObserver.EditModeChanged(Sender: TObject; const AInfo: THexEditModeInfo);
begin
  EditMode := AInfo;
end;

procedure TEventObserver.ModifiedChanged(Sender: TObject; const AInfo: THexModifiedInfo);
begin
  Modified := AInfo;
end;

procedure Check(const ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

function EqualBytes(const ALeft, ARight: TBytes): Boolean;
begin
  Result := Length(ALeft) = Length(ARight);
  if Result and (Length(ALeft) > 0) then Result := CompareMem(@ALeft[0], @ARight[0], Length(ALeft));
end;

procedure TestStreamingSearch;
var
  LBytes: TBytes;
  LProvider: IHexSearchProvider;
  LQuery: THexSearchQuery;
  LMatches: TObjectList<THexSearchMatch>;
begin
  SetLength(LBytes, 131080);
  LBytes[65534] := $DE;
  LBytes[65535] := $AD;
  LBytes[65536] := $BE;
  LBytes[65537] := $EF;
  LQuery := THexSearchQuery.Create;
  try
    LProvider := THexNativeSearchProvider.Create;
    LQuery.RawBytes := TBytes.Create($DE, $AD, $BE, $EF);
    LMatches := LProvider.Search(TBytesHexDataSource.Create(LBytes), LQuery);
    try Check((LMatches.Count = 1) and (LMatches[0].Offset = 65534), 'Search must match once across chunk boundaries'); finally LMatches.Free; end;
    LQuery.Mode := hsmApproximate;
    LQuery.RawBytes := TBytes.Create($DE, $AD, $BE, $EE);
    LQuery.MaxHammingDistance := 1;
    LMatches := LProvider.Search(TBytesHexDataSource.Create(LBytes), LQuery);
    try
      Check((LMatches.Count = 1) and (LMatches[0].HammingDistance = 1), 'Hamming match metadata');
    finally LMatches.Free; end;
    LQuery.StartOffset := 65535;
    LMatches := LProvider.Search(TBytesHexDataSource.Create(LBytes), LQuery);
    try Check(LMatches.Count = 0, 'Search start range'); finally LMatches.Free; end;
  finally LQuery.Free; end;
end;

procedure TestCodecs;
var
  LText, LName: string;
  LBytes: TBytes;
begin
  LText := 'Nimbus ' + Char($00E4) + Char($D83D) + Char($DE00);
  for LName in TArray<string>.Create('UTF-8', 'UTF-16LE', 'UTF-16BE', 'UTF-32LE', 'UTF-32BE') do
  begin
    LBytes := THexTextEncoding.Encode(LText, LName);
    Check(THexTextEncoding.Decode(LBytes, LName) = LText, 'Unicode encoding round trip: ' + LName);
  end;
  LBytes := THexTextEncoding.Encode(Char($00E4), 'ISO-8859-1');
  Check((Length(LBytes) = 1) and (LBytes[0] = $E4), 'ISO-8859-1 byte mapping');
end;

procedure TestSessionAndUndo;
var
  LEditor, LRestored: TThemedHexEditor;
  LSession: THexSessionData;
  LProject: THexProjectData;
  LJson: string;
  LOriginal, LExpected: TBytes;
begin
  LEditor := TThemedHexEditor.Create(nil);
  LRestored := TThemedHexEditor.Create(nil);
  try
    LOriginal := TBytes.Create(1, 2, 3, 4, 5);
    LEditor.LoadBytes(LOriginal);
    LEditor.InsertBytes(0, TBytes.Create(8));
    LEditor.InsertBytes(0, TBytes.Create(9));
    LEditor.Undo;
    LEditor.Undo;
    Check(EqualBytes(LEditor.ReadAllBytes, LOriginal), 'Undo bytes');
    Check(not LEditor.Modified, 'Undo to original must restore clean state');
    LJson := LEditor.CreateSessionJson;
    LRestored.RestoreSessionJson(LJson);
    Check(LRestored.CanRedo, 'Session must restore redo history');
    LRestored.Redo;
    Check(LRestored.CanRedo, 'Redo must preserve the remaining redo commands');
    LRestored.Redo;
    Check(EqualBytes(LRestored.ReadAllBytes, TBytes.Create(9, 8, 1, 2, 3, 4, 5)), 'Second redo after session restore');
    LRestored.AddBookmark(2, 'Bookmark', ThemeColor(255, 86, 156, 214));
    LRestored.EncodingName := 'UTF-32LE';
    LRestored.SelectRange(2, 3);
    LExpected := LRestored.ReadAllBytes;
    LJson := LRestored.CreateSessionJson;
    LEditor.RestoreSessionJson(LJson);
    Check(EqualBytes(LEditor.ReadAllBytes, LExpected), 'Session document round trip');
    Check((LEditor.Selection.Start = 2) and (LEditor.Selection.Length = 3), 'Session selection');
    Check((LEditor.Bookmarks.Count = 1) and (LEditor.EncodingName = 'UTF-32LE'), 'Session bookmarks and encoding');
    LSession := THexSessionSerializer.FromJson(LJson);
    try
      LSession.SelectionLength := High(Int64);
      try
        LEditor.RestoreSessionData(LSession);
        Check(False, 'Invalid session must be rejected');
      except on E: EConvertError do ; end;
      Check(EqualBytes(LEditor.ReadAllBytes, LExpected), 'Invalid restore must leave the existing document intact');
    finally LSession.Free; end;
    LProject := LEditor.CreateProjectData('Test project');
    try LJson := THexProjectSerializer.ToJson(LProject); finally LProject.Free; end;
    LProject := THexProjectSerializer.FromJson(LJson);
    try
      Check(LProject.ProjectName = 'Test project', 'Project metadata');
      LRestored.RestoreProjectData(LProject);
      Check(EqualBytes(LRestored.ReadAllBytes, LExpected), 'Project restore');
    finally LProject.Free; end;
  finally
    LRestored.Free;
    LEditor.Free;
  end;
end;

procedure TestReplace;
var
  LEditor: TThemedHexEditor;
  LOriginal, LFind, LReplacement: TBytes;
begin
  LEditor := TThemedHexEditor.Create(nil);
  try
    LOriginal := TEncoding.UTF8.GetBytes('aaaaa');
    LFind := TEncoding.UTF8.GetBytes('aa');
    LReplacement := TEncoding.UTF8.GetBytes('b');
    LEditor.LoadBytes(LOriginal);
    Check(LEditor.ReplaceAll(LFind, LReplacement) = 2, 'Replace all count');
    Check(TEncoding.UTF8.GetString(LEditor.ReadAllBytes) = 'bba', 'Replace all must choose non-overlapping matches from the left');
    LEditor.Undo;
    LEditor.Undo;
    Check(EqualBytes(LEditor.ReadAllBytes, LOriginal), 'Variable-length replacements must undo correctly');
    LEditor.Options.ReadOnly := True;
    LEditor.Redo;
    Check(EqualBytes(LEditor.ReadAllBytes, LOriginal), 'Read only must block redo');
  finally LEditor.Free; end;
end;

procedure TestEventsAndNavigation;
var
  LEditor: TTestHexEditor;
  LObserver: TEventObserver;
  LMatches, LSnapshot: TObjectList<THexSearchMatch>;
  LBookmark, LMoved: THexBookmark;
begin
  LEditor := TTestHexEditor.Create(nil);
  LObserver := TEventObserver.Create;
  try
    LEditor.UseIntegratedFindReplaceDialog := False;
    LEditor.OnRequestFind := LObserver.Request;
    LEditor.OnRequestReplace := LObserver.Request;
    LEditor.OnRequestFindNext := LObserver.Request;
    LEditor.OnRequestFindPrevious := LObserver.Request;
    LEditor.OnRequestGotoOffset := LObserver.Request;
    LEditor.SendKey(Ord('F'), [ssCtrl]);
    LEditor.SendKey(Ord('H'), [ssCtrl]);
    LEditor.SendKey(VK_F3, []);
    LEditor.SendKey(VK_F3, [ssShift]);
    LEditor.SendKey(Ord('G'), [ssCtrl]);
    Check((LObserver.Requests = 5) and not LEditor.HandleAllocated, 'Requests must work without data or a parent window');
    LEditor.OnDataSourceInfoChanged := LObserver.DataSourceChanged;
    LEditor.OnSelectionInfoChanged := LObserver.SelectionChanged;
    LEditor.OnCursorOffsetInfoChanged := LObserver.CursorOffsetChanged;
    LEditor.OnUndoRedoStateInfoChanged := LObserver.UndoRedoStateChanged;
    LEditor.OnSearchInfoChanged := LObserver.SearchChanged;
    LEditor.OnEditModeInfoChanged := LObserver.EditModeChanged;
    LEditor.OnModifiedInfoChanged := LObserver.ModifiedChanged;
    LEditor.LoadBytes(TBytes.Create($DE, $AD, $BE, $EF, $DE, $AD, $BE, $EF));
    Check(LObserver.DataSource.HasData and LObserver.DataSource.CanWrite and
      (LObserver.DataSource.DataLength = 8), 'Data source event state');
    LMatches := LEditor.SearchPattern('D? ?? BE EE', 0, -1, 1);
    try
      Check((LMatches.Count = 2) and (LMatches[0].HammingDistance = 1), 'Masked signature Hamming tolerance and metadata');
      LEditor.SetAdvancedSearchMatches(LMatches);
    finally LMatches.Free; end;
    Check(LEditor.SetActiveAdvancedSearchMatchIndex(1), 'Select advanced match by index');
    Check((LEditor.CursorPosition = 4) and (LObserver.Search.ActiveMatchIndex = 1) and
      (LObserver.Search.HammingDistance = 1), 'Search event and navigation state');
    Check((LObserver.Selection.SelectionStart = 4) and (LObserver.Selection.SelectionEnd = 7) and
      (LObserver.CursorOffset.CursorOffset = 4), 'Selection and cursor event state');
    Check(not LEditor.SetActiveAdvancedSearchMatchIndex(2), 'Reject invalid match index');
    Check(LEditor.ActiveAdvancedSearchMatchIndex = 1, 'Invalid match index must leave active match intact');
    LSnapshot := LEditor.GetAdvancedSearchMatches;
    try
      LEditor.ClearAdvancedSearchMatches;
      Check((LSnapshot.Count = 2) and (LSnapshot[1].Offset = 4), 'Search snapshot must survive clearing the editor results');
    finally LSnapshot.Free; end;
    LEditor.InsertMode := True;
    Check(LObserver.EditMode.InsertMode, 'Edit mode event state');
    LEditor.OverwriteBytes(0, TBytes.Create(1));
    Check(LObserver.Modified.Modified and LObserver.UndoRedoState.CanUndo, 'Modified and undo state events');
    LEditor.Undo;
    Check(not LObserver.Modified.Modified and LObserver.UndoRedoState.CanRedo, 'Undo restored event state');
    LBookmark := LEditor.AddBookmark(1, 'Original', ThemeColor(255, 80, 140, 200));
    LEditor.AddBookmark(2, 'Occupied', ThemeColor(255, 200, 80, 140));
    Check(not LEditor.MoveBookmark(1, 2), 'Occupied bookmark target must be rejected');
    Check(LEditor.UpdateBookmark(1, 'Moved', 6, ThemeColor(255, 120, 200, 80)), 'Move and update bookmark');
    Check(LEditor.TryGetBookmark(6, LMoved) and (LMoved = LBookmark) and
      (LMoved.Name = 'Moved') and not LEditor.Bookmarks.Contains(1), 'Bookmark identity and dictionary key');
    Check(not LEditor.MoveBookmark(6, 9), 'Bookmark outside document rejected');
    LEditor.ClearBookmarks;
    Check(LEditor.Bookmarks.Count = 0, 'Clear bookmarks');
  finally
    LEditor.Free;
    LObserver.Free;
  end;
end;

procedure TestSave;
var
  LEditor: TThemedHexEditor;
  LRoot, LPath: string;
  LGuid: TGUID;
begin
  LRoot := TPath.GetFullPath(TPath.Combine(ExtractFilePath(ParamStr(0)), 'fixtures'));
  if not LRoot.StartsWith('E:\Projects\NimbusForms\', True) then
    raise EInvalidOpException.Create('Test outputs must remain in the NimbusForms workspace');
  ForceDirectories(LRoot);
  CreateGUID(LGuid);
  LPath := TPath.Combine(LRoot, 'hex-feature-save-' + GUIDToString(LGuid) + '.bin');
  LEditor := TThemedHexEditor.Create(nil);
  try
    LEditor.LoadBytes(TBytes.Create(1, 2, 3));
    LEditor.SaveAs(LPath);
    LEditor.OverwriteBytes(1, TBytes.Create(9));
    LEditor.Save;
    Check(EqualBytes(TFile.ReadAllBytes(LPath), TBytes.Create(1, 9, 3)), 'Atomic save of an open file');
    Check(not LEditor.Modified, 'Save must clear modified state');
    Check(TFile.Exists(LPath + '.bak'), 'Save backup');
  finally LEditor.Free; end;
end;

begin
  try
    Application.Initialize;
    TestStreamingSearch;
    TestCodecs;
    TestSessionAndUndo;
    TestReplace;
    TestEventsAndNavigation;
    TestSave;
    Writeln('Hex feature tests passed');
  except
    on E: Exception do
    begin
      Writeln(E.ClassName + ': ' + E.Message);
      ExitCode := 1;
    end;
  end;
end.

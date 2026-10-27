unit NimbusHexEditor.DUnitX.EditorTests;

interface

uses System.SysUtils, Vcl.Forms, DUnitX.TestFramework, NimbusForms.HexEditor.Control,
  NimbusHexEditor.DUnitX.Support;

type
  [TestFixture]
  [Category('HexEditor.Editor')]
  THexEditorHistoryTests = class
  private
    FHost: TForm;
    FEditor: TThemedHexEditor;
    FSandbox: THexTestSandbox;
    FInitial: TBytes;
    procedure CheckState(const Expected: TBytes; Undo, Redo: Boolean; const Context: string);
    function ApplyOne(Kind: Integer): TBytes;
  public
    [Setup] procedure Setup;
    [TearDown] procedure TearDown;
    [Test] procedure EmptyDocumentInsertUndoRedo;
    [Test]
    [TestCase('Zero', '0')]
    [TestCase('One', '1')]
    [TestCase('OneChunk', '65536')]
    [TestCase('TwoChunks', '65537')]
    [TestCase('MultipleChunks', '131089')]
    procedure SelectedRangeReadsAcrossPiecesAndChunks(Count: Integer);
    [Test]
    [TestCase('Overwrite', '0')]
    [TestCase('Insert', '1')]
    [TestCase('Delete', '2')]
    procedure EditUndoRedoRoundTrip(Kind: Integer);
    [Test] procedure MixedEditsUndoAllRedoAll;
    [Test] procedure NewEditAfterUndoDiscardsRedo;
    [Test] procedure EmptyEditsDoNotCreateHistory;
    [Test] procedure InvalidRangesPreserveBytesAndHistory;
    [Test] procedure ReadOnlyBlocksEditsAndUndo;
    [Test] procedure LoadingBytesAndFilesResetsHistory;
    [Test]
    [TestCase('Overwrite', '0')]
    [TestCase('Insert', '1')]
    [TestCase('Delete', '2')]
    procedure UndoRedoAcrossSaveUsesSavedBaseline(Kind: Integer);
    [Test] procedure SessionPreservesBothHistoryStacks;
    [Test] procedure InvalidSessionLeavesCurrentDocumentIntact;
    [Test] procedure ProjectFilePreservesEditsAndHistory;
    [Test]
    [TestCase('Seed7', '7,2000')]
    [TestCase('Seed181', '181,2000')]
    [TestCase('Seed8191', '8191,2000')]
    procedure RandomHistoryMatchesByteArray(Seed, Steps: Integer);
  end;

implementation

uses System.Classes, System.IOUtils, System.Math, System.Generics.Collections;

procedure THexEditorHistoryTests.Setup;
begin
  FSandbox := THexTestSandbox.Create; FInitial := HexPattern(256);
  FHost := TForm.CreateNew(nil); FEditor := TThemedHexEditor.Create(FHost); FEditor.Parent := FHost;
  FEditor.SetBounds(0, 0, 640, 320); FEditor.LoadBytes(FInitial);
end;

procedure THexEditorHistoryTests.TearDown;
begin
  try FHost.Free; FHost := nil; FEditor := nil;
  finally FSandbox.Free; FSandbox := nil; FInitial := nil; end;
end;

procedure THexEditorHistoryTests.CheckState(const Expected: TBytes; Undo, Redo: Boolean; const Context: string);
begin
  CheckHexBytes(Expected, FEditor.ReadAllBytes, Context);
  Assert.IsTrue(FEditor.DataLength = Length(Expected), Context + ': data length');
  Assert.IsTrue(FEditor.CanUndo = Undo, Context + ': CanUndo'); Assert.IsTrue(FEditor.CanRedo = Redo, Context + ': CanRedo');
end;

function THexEditorHistoryTests.ApplyOne(Kind: Integer): TBytes;
var Data: TBytes;
begin
  Data := TBytes.Create(0, 255, 77, 128);
  case Kind of
    0: begin FEditor.OverwriteBytes(20, Data); Result := HexSplice(FInitial, 20, Length(Data), Data); end;
    1: begin FEditor.InsertBytes(20, Data); Result := HexSplice(FInitial, 20, 0, Data); end;
    2: begin FEditor.DeleteBytes(20, 4); Result := HexSplice(FInitial, 20, 4, nil); end;
  else raise EArgumentOutOfRangeException.Create('Kind');
  end;
end;

procedure THexEditorHistoryTests.SelectedRangeReadsAcrossPiecesAndChunks(Count: Integer);
var Expected, Actual, Inserted: TBytes; Offset: Integer;
begin
  Expected := HexPattern(Count + 32); FEditor.LoadBytes(Expected);
  Offset := 13 + Count div 2; Inserted := TBytes.Create(255, 0, 128, 77);
  FEditor.InsertBytes(Offset, Inserted); Expected := HexSplice(Expected, Offset, 0, Inserted);
  Assert.IsTrue(FEditor.TryReadBytes(13, Count, Actual), 'valid selected range must be readable');
  CheckHexBytes(Copy(Expected, 13, Count), Actual, 'read across pieces and 64 KiB boundary');
  FEditor.SelectRange(13, Count);
  CheckHexBytes(Copy(Expected, 13, Count), FEditor.SelectedBytes, 'SelectedBytes uses the same valid range');
end;

procedure THexEditorHistoryTests.EmptyDocumentInsertUndoRedo;
begin
  FEditor.LoadBytes(nil); CheckState(nil, False, False, 'empty initial state');
  FEditor.InsertBytes(0, TBytes.Create(0, 255)); CheckState(TBytes.Create(0, 255), True, False, 'empty insert');
  FEditor.Undo; CheckState(nil, False, True, 'undo empty insert'); Assert.IsFalse(FEditor.Modified);
  FEditor.Redo; CheckState(TBytes.Create(0, 255), True, False, 'redo empty insert'); Assert.IsTrue(FEditor.Modified);
end;

procedure THexEditorHistoryTests.EditUndoRedoRoundTrip(Kind: Integer);
var Expected: TBytes;
begin
  Expected := ApplyOne(Kind); CheckState(Expected, True, False, 'edit'); Assert.IsTrue(FEditor.Modified);
  FEditor.Undo; CheckState(FInitial, False, True, 'undo'); Assert.IsFalse(FEditor.Modified);
  FEditor.Redo; CheckState(Expected, True, False, 'redo'); Assert.IsTrue(FEditor.Modified);
  FEditor.Undo; FEditor.Undo; CheckState(FInitial, False, True, 'extra undo is safe');
  FEditor.Redo; FEditor.Redo; CheckState(Expected, True, False, 'extra redo is safe');
end;

procedure THexEditorHistoryTests.MixedEditsUndoAllRedoAll;
var States: TList<TBytes>; Expected, Find: TBytes; I: Integer;
begin
  States := TList<TBytes>.Create;
  try
    States.Add(Copy(FInitial)); Expected := ApplyOne(0); States.Add(Copy(Expected));
    FEditor.InsertBytes(18, TBytes.Create(9, 8)); Expected := HexSplice(Expected, 18, 0, TBytes.Create(9, 8)); States.Add(Copy(Expected));
    FEditor.DeleteBytes(16, 12); Expected := HexSplice(Expected, 16, 12, nil); States.Add(Copy(Expected));
    Find := Copy(Expected, 8, 5); FEditor.SelectRange(8, 5);
    Assert.IsTrue(FEditor.ReplaceSelection(Find, TBytes.Create(255, 0)), 'replace selected bytes');
    Expected := HexSplice(Expected, 8, 5, TBytes.Create(255, 0)); States.Add(Copy(Expected));
    for I := States.Count - 2 downto 0 do begin FEditor.Undo; CheckState(States[I], I > 0, True, 'mixed undo ' + IntToStr(I)); end;
    Assert.IsFalse(FEditor.Modified);
    for I := 1 to States.Count - 1 do begin FEditor.Redo; CheckState(States[I], True, I < States.Count - 1, 'mixed redo ' + IntToStr(I)); end;
  finally States.Free; end;
end;

procedure THexEditorHistoryTests.NewEditAfterUndoDiscardsRedo;
var Expected: TBytes;
begin
  ApplyOne(0); FEditor.Undo; Assert.IsTrue(FEditor.CanRedo);
  FEditor.InsertBytes(0, TBytes.Create(55)); Expected := HexSplice(FInitial, 0, 0, TBytes.Create(55));
  CheckState(Expected, True, False, 'new branch'); FEditor.Redo; CheckState(Expected, True, False, 'discarded redo is not replayed');
end;

procedure THexEditorHistoryTests.EmptyEditsDoNotCreateHistory;
begin
  FEditor.InsertBytes(0, nil); FEditor.OverwriteBytes(0, nil); FEditor.DeleteBytes(0, 0);
  CheckState(FInitial, False, False, 'no-op edits'); Assert.IsFalse(FEditor.Modified);
end;

procedure THexEditorHistoryTests.InvalidRangesPreserveBytesAndHistory;
begin
  CheckHexException(procedure begin FEditor.InsertBytes(-1, TBytes.Create(1)); end, EArgumentOutOfRangeException, 'negative editor insert');
  CheckHexException(procedure begin FEditor.InsertBytes(257, TBytes.Create(1)); end, EArgumentOutOfRangeException, 'editor insert beyond EOF');
  CheckHexException(procedure begin FEditor.OverwriteBytes(255, TBytes.Create(1, 2)); end, EArgumentOutOfRangeException, 'overwrite outside document');
  CheckHexException(procedure begin FEditor.DeleteBytes(255, 2); end, EArgumentOutOfRangeException, 'delete outside document');
  CheckState(FInitial, False, False, 'invalid edits'); Assert.IsFalse(FEditor.Modified);
end;

procedure THexEditorHistoryTests.ReadOnlyBlocksEditsAndUndo;
var Expected: TBytes;
begin
  Expected := ApplyOne(0); FEditor.Options.ReadOnly := True;
  CheckHexException(procedure begin FEditor.InsertBytes(0, TBytes.Create(1)); end, EInvalidOperation, 'read-only insert');
  CheckHexException(procedure begin FEditor.OverwriteBytes(0, TBytes.Create(1)); end, EInvalidOperation, 'read-only overwrite');
  CheckHexException(procedure begin FEditor.DeleteBytes(0, 1); end, EInvalidOperation, 'read-only delete');
  FEditor.Undo; CheckState(Expected, True, False, 'read-only undo leaves command on stack');
  FEditor.Options.ReadOnly := False; FEditor.Undo; CheckState(FInitial, False, True, 'undo after unlocking');
end;

procedure THexEditorHistoryTests.LoadingBytesAndFilesResetsHistory;
var Path: string; Data: TBytes;
begin
  ApplyOne(0); FEditor.Undo; Data := TBytes.Create(0, 255, 1); FEditor.LoadBytes(Data);
  CheckState(Data, False, False, 'load bytes resets undo and redo'); Assert.IsFalse(FEditor.Modified);
  FEditor.InsertBytes(0, TBytes.Create(9)); Path := FSandbox.FileName('load.bin'); TFile.WriteAllBytes(Path, FInitial);
  FEditor.LoadFile(Path); CheckState(FInitial, False, False, 'load file resets history'); Assert.IsFalse(FEditor.Modified); Assert.IsTrue(FEditor.CanSave);
end;

procedure THexEditorHistoryTests.UndoRedoAcrossSaveUsesSavedBaseline(Kind: Integer);
var Path: string; Expected: TBytes;
begin
  Expected := ApplyOne(Kind); Path := FSandbox.FileName('checkpoint.bin'); FEditor.SaveAs(Path);
  CheckHexBytes(Expected, TFile.ReadAllBytes(Path), 'saved checkpoint'); CheckState(Expected, True, False, 'save retains undo history'); Assert.IsFalse(FEditor.Modified);
  FEditor.Undo; CheckState(FInitial, False, True, 'undo across save'); Assert.IsTrue(FEditor.Modified, 'undo differs from saved checkpoint');
  FEditor.Redo; CheckState(Expected, True, False, 'redo returns to checkpoint'); Assert.IsFalse(FEditor.Modified, 'redo equals saved checkpoint');
  FEditor.InsertBytes(0, TBytes.Create(42)); Expected := HexSplice(Expected, 0, 0, TBytes.Create(42)); FEditor.Save;
  CheckHexBytes(Expected, TFile.ReadAllBytes(Path), 'second editor save'); Assert.IsFalse(FEditor.Modified);
end;

procedure THexEditorHistoryTests.SessionPreservesBothHistoryStacks;
var Path: string; Other: TThemedHexEditor; First, Second, Third: TBytes;
begin
  First := ApplyOne(0); FEditor.InsertBytes(5, TBytes.Create(90, 91)); Second := HexSplice(First, 5, 0, TBytes.Create(90, 91));
  FEditor.DeleteBytes(12, 7); Third := HexSplice(Second, 12, 7, nil); FEditor.Undo;
  Path := FSandbox.FileName('session.json'); FEditor.SaveSession(Path);
  Other := TThemedHexEditor.Create(FHost); Other.Parent := FHost;
  try
    Other.RestoreSessionFile(Path); CheckHexBytes(Second, Other.ReadAllBytes, 'restored session bytes'); Assert.IsTrue(Other.CanUndo and Other.CanRedo);
    Other.Redo; CheckHexBytes(Third, Other.ReadAllBytes, 'session redo');
    Other.Undo; Other.Undo; CheckHexBytes(First, Other.ReadAllBytes, 'session undo insertion');
    Other.Undo; CheckHexBytes(FInitial, Other.ReadAllBytes, 'session undo to original'); Assert.IsFalse(Other.CanUndo); Assert.IsFalse(Other.Modified);
    Other.Redo; Other.Redo; Other.Redo; CheckHexBytes(Third, Other.ReadAllBytes, 'session full redo'); Assert.IsFalse(Other.CanRedo);
    CheckHexBytes(Second, FEditor.ReadAllBytes, 'restored session is independent of source editor');
  finally Other.Free; end;
end;

procedure THexEditorHistoryTests.InvalidSessionLeavesCurrentDocumentIntact;
var Expected: TBytes;
begin
  Expected := ApplyOne(0);
  CheckHexException(procedure begin FEditor.RestoreSessionJson('{invalid'); end, Exception, 'invalid session JSON');
  CheckState(Expected, True, False, 'invalid session is atomic'); FEditor.Undo; CheckState(FInitial, False, True, 'old undo remains usable');
end;

procedure THexEditorHistoryTests.ProjectFilePreservesEditsAndHistory;
var Path: string; Other: TThemedHexEditor; Expected: TBytes;
begin
  Expected := ApplyOne(1); Path := FSandbox.FileName('workspace.json'); FEditor.SaveProject(Path, 'DUnitX workspace');
  Other := TThemedHexEditor.Create(FHost); Other.Parent := FHost;
  try
    Other.RestoreProjectFile(Path); CheckHexBytes(Expected, Other.ReadAllBytes, 'project bytes'); Assert.IsTrue(Other.CanUndo);
    Other.Undo; CheckHexBytes(FInitial, Other.ReadAllBytes, 'project undo'); Other.Redo; CheckHexBytes(Expected, Other.ReadAllBytes, 'project redo');
  finally Other.Free; end;
end;

procedure THexEditorHistoryTests.RandomHistoryMatchesByteArray(Seed, Steps: Integer);
var Random: THexTestRandom; Undo, Redo: TList<TBytes>; Expected, Data, Previous: TBytes;
  I, Kind, Offset, Count: Integer; Context: string;
begin
  Random.Init(Seed); Expected := Copy(FInitial); Undo := TList<TBytes>.Create; Redo := TList<TBytes>.Create;
  try
    for I := 1 to Steps do
    begin
      Kind := Random.Next(5); if (Length(Expected) = 0) and (Kind in [1, 2]) then Kind := 0;
      if (Length(Expected) > 4096) and (Kind = 0) then Kind := 2;
      Offset := 0; Count := 0;
      if Kind <= 2 then
      begin
        Previous := Copy(Expected); Offset := Random.Next(Length(Expected) + Ord(Kind = 0));
        Count := 1 + Random.Next(16); if Kind <> 0 then Count := Min(Count, Length(Expected) - Offset);
        Data := Random.Bytes(Count);
        case Kind of
          0: begin FEditor.InsertBytes(Offset, Data); Expected := HexSplice(Expected, Offset, 0, Data); end;
          1: begin FEditor.OverwriteBytes(Offset, Data); Expected := HexSplice(Expected, Offset, Count, Data); end;
          2: begin FEditor.DeleteBytes(Offset, Count); Expected := HexSplice(Expected, Offset, Count, nil); end;
        end;
        Undo.Add(Previous); Redo.Clear;
      end
      else if Kind = 3 then
      begin
        FEditor.Undo;
        if Undo.Count > 0 then begin Redo.Add(Copy(Expected)); Expected := Undo.Last; Undo.Delete(Undo.Count - 1); end;
      end
      else
      begin
        FEditor.Redo;
        if Redo.Count > 0 then begin Undo.Add(Copy(Expected)); Expected := Redo.Last; Redo.Delete(Redo.Count - 1); end;
      end;
      Context := Format('history seed=%d step=%d operation=%d offset=%d count=%d', [Seed, I, Kind, Offset, Count]);
      CheckState(Expected, Undo.Count > 0, Redo.Count > 0, Context);
    end;
    while Undo.Count > 0 do
    begin FEditor.Undo; Redo.Add(Copy(Expected)); Expected := Undo.Last; Undo.Delete(Undo.Count - 1); CheckState(Expected, Undo.Count > 0, True, 'undo entire generated history'); end;
    CheckHexBytes(FInitial, Expected, 'all generated edits undone'); Assert.IsFalse(FEditor.Modified);
    while Redo.Count > 0 do
    begin FEditor.Redo; Undo.Add(Copy(Expected)); Expected := Redo.Last; Redo.Delete(Redo.Count - 1); CheckState(Expected, True, Redo.Count > 0, 'redo entire generated history'); end;
  finally Redo.Free; Undo.Free; end;
end;

initialization
  TDUnitX.RegisterTestFixture(THexEditorHistoryTests);

end.

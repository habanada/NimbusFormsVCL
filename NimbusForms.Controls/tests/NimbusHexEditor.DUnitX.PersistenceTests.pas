unit NimbusHexEditor.DUnitX.PersistenceTests;

interface

uses DUnitX.TestFramework, NimbusHexEditor.DUnitX.Support;

type
  [TestFixture]
  [Category('HexEditor.Persistence')]
  THexDocumentPersistenceTests = class
  private
    FSandbox: THexTestSandbox;
  public
    [Setup] procedure Setup;
    [TearDown] procedure TearDown;
    [Test]
    [TestCase('Empty', '0')]
    [TestCase('SingleByte', '1')]
    [TestCase('Binary', '256')]
    [TestCase('BeforeChunkBoundary', '81919')]
    [TestCase('AtChunkBoundary', '81920')]
    [TestCase('AfterChunkBoundary', '81921')]
    [TestCase('MultipleChunks', '262177')]
    procedure EditedFileSaveAsAndReload(Size: Integer);
    [Test] procedure SaveReplacesOpenOriginalAndCreatesBackup;
    [Test] procedure BackupCanBeDisabled;
    [Test] procedure EmptyFileCanBeSaved;
    [Test] procedure FailedSavePreservesFileAndDirtyState;
    [Test] procedure SaveWithoutPathIsRejected;
  end;

implementation

uses System.SysUtils, System.IOUtils, System.Math, NimbusForms.HexEditor.Document,
  NimbusForms.HexEditor.DataSource;

procedure THexDocumentPersistenceTests.Setup;
begin FSandbox := THexTestSandbox.Create; end;

procedure THexDocumentPersistenceTests.TearDown;
begin FSandbox.Free; FSandbox := nil; end;

procedure THexDocumentPersistenceTests.EditedFileSaveAsAndReload(Size: Integer);
var Original, Expected, Data: TBytes; InputPath, OutputPath: string; Document, Reloaded: THexDocument;
  Keep, ReloadKeep: IHexDataSource; Offset, Removed: Integer;
begin
  InputPath := FSandbox.FileName('original.bin'); OutputPath := FSandbox.FileName('saved.bin');
  Original := HexPattern(Size); TFile.WriteAllBytes(InputPath, Original);
  Document := THexDocument.Create(InputPath); Keep := Document;
  try
    CheckHexDocument(Document, Original, 'loaded file'); Assert.IsFalse(Document.IsDirty);
    Expected := Original; Data := TBytes.Create(0, 255, 128, 1); Offset := Size div 2;
    Document.Insert(Offset, Data); Expected := HexSplice(Expected, Offset, 0, Data);
    Data := TBytes.Create(99, 88, 77); Document.Write(0, Data); Expected := HexSplice(Expected, 0, 3, Data);
    Offset := Length(Expected) div 3; Removed := Min(5, Length(Expected) - Offset);
    Document.Delete(Offset, Removed); Expected := HexSplice(Expected, Offset, Removed, nil);
    Document.SaveAs(OutputPath);
    CheckHexBytes(Expected, TFile.ReadAllBytes(OutputPath), 'SaveAs bytes');
    CheckHexBytes(Original, TFile.ReadAllBytes(InputPath), 'SaveAs leaves input file unchanged');
    Assert.IsFalse(Document.IsDirty); Assert.IsTrue(Document.FilePath = OutputPath);
    Assert.IsTrue(Length(Document.ExportMemoryBuffer) = 0, 'successful save rebases memory pieces');
    Reloaded := THexDocument.Create(OutputPath); ReloadKeep := Reloaded;
    try CheckHexDocument(Reloaded, Expected, 'reloaded file'); finally ReloadKeep := nil; end;
    CheckHexDocument(Document, Expected, 'document after SaveAs');
  finally Keep := nil; end;
end;

procedure THexDocumentPersistenceTests.SaveReplacesOpenOriginalAndCreatesBackup;
var Path: string; Document: THexDocument; Keep: IHexDataSource; Original, First, Second: TBytes;
begin
  Path := FSandbox.FileName('atomic.bin'); Original := HexPattern(300); TFile.WriteAllBytes(Path, Original);
  Document := THexDocument.Create(Path); Keep := Document;
  try
    Document.Write(10, TBytes.Create(255, 254)); First := HexSplice(Original, 10, 2, TBytes.Create(255, 254));
    Document.Save; CheckHexBytes(First, TFile.ReadAllBytes(Path), 'save open original');
    CheckHexBytes(Original, TFile.ReadAllBytes(Path + '.bak'), 'first backup'); Assert.IsFalse(Document.IsDirty);
    Document.Insert(0, TBytes.Create(33)); Second := HexSplice(First, 0, 0, TBytes.Create(33));
    Document.Save; CheckHexBytes(Second, TFile.ReadAllBytes(Path), 'second save');
    CheckHexBytes(First, TFile.ReadAllBytes(Path + '.bak'), 'backup advances to previous saved state');
    CheckHexDocument(Document, Second, 'rebased document after second save'); Assert.IsFalse(Document.IsDirty);
  finally Keep := nil; end;
end;

procedure THexDocumentPersistenceTests.BackupCanBeDisabled;
var Path: string; Document: THexDocument; Keep: IHexDataSource;
begin
  Path := FSandbox.FileName('no-backup.bin'); TFile.WriteAllBytes(Path, TBytes.Create(1, 2, 3));
  Document := THexDocument.Create(Path); Keep := Document;
  try
    Document.CreateBackup := False; Document.Write(1, TBytes.Create(9)); Document.Save;
    CheckHexBytes(TBytes.Create(1, 9, 3), TFile.ReadAllBytes(Path), 'save without backup'); Assert.IsFalse(TFile.Exists(Path + '.bak'));
  finally Keep := nil; end;
end;

procedure THexDocumentPersistenceTests.EmptyFileCanBeSaved;
var Path: string; Document: THexDocument; Keep: IHexDataSource;
begin
  Path := FSandbox.FileName('empty.bin'); Document := THexDocument.Create(TBytesHexDataSource.Create(TBytes.Create(1, 2)));
  Keep := Document;
  try
    Document.Delete(0, 2); Document.SaveAs(Path);
    Assert.IsTrue(TFile.Exists(Path)); CheckHexBytes(nil, TFile.ReadAllBytes(Path), 'zero-length saved file');
    CheckHexDocument(Document, nil, 'empty rebased document'); Assert.IsFalse(Document.IsDirty);
  finally Keep := nil; end;
end;

procedure THexDocumentPersistenceTests.FailedSavePreservesFileAndDirtyState;
var Path, Missing: string; Document: THexDocument; Keep: IHexDataSource; Original, Expected: TBytes;
begin
  Path := FSandbox.FileName('preserved.bin'); Missing := TPath.Combine(FSandbox.FileName('missing-directory'), 'failed.bin');
  Original := HexPattern(64); TFile.WriteAllBytes(Path, Original); Document := THexDocument.Create(Path); Keep := Document;
  try
    Document.Insert(10, TBytes.Create(99)); Expected := HexSplice(Original, 10, 0, TBytes.Create(99));
    CheckHexException(procedure begin Document.SaveAs(Missing); end, Exception, 'save to missing parent');
    CheckHexBytes(Original, TFile.ReadAllBytes(Path), 'failed save preserves original file');
    CheckHexDocument(Document, Expected, 'failed save retains edited piece table');
    Assert.IsTrue(Document.IsDirty and (Document.FilePath = Path)); Assert.IsFalse(TFile.Exists(Missing));
  finally Keep := nil; end;
end;

procedure THexDocumentPersistenceTests.SaveWithoutPathIsRejected;
var Document: THexDocument; Keep: IHexDataSource;
begin
  Document := THexDocument.Create(TBytesHexDataSource.Create(TBytes.Create(1, 2))); Keep := Document;
  try
    CheckHexException(procedure begin Document.Save; end, EInvalidOpException, 'Save requires a path');
    CheckHexException(procedure begin Document.SaveAs(''); end, EArgumentException, 'SaveAs requires a nonempty path');
    CheckHexDocument(Document, TBytes.Create(1, 2), 'failed save without path preserves document');
  finally Keep := nil; end;
end;

initialization
  TDUnitX.RegisterTestFixture(THexDocumentPersistenceTests);

end.

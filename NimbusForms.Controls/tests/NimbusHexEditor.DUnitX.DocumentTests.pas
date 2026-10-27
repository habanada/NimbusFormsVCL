unit NimbusHexEditor.DUnitX.DocumentTests;

interface

uses System.SysUtils, System.Classes, System.Generics.Collections, DUnitX.TestFramework,
  NimbusForms.HexEditor.DataSource, NimbusForms.HexEditor.Document, NimbusForms.HexEditor.Pieces;

type
  [TestFixture]
  [Category('HexEditor.PieceTable')]
  THexPieceTableTests = class
  private
    FDocument: THexDocument;
    FSource, FKeepAlive: IHexDataSource;
    FInitial: TBytes;
  public
    [Setup] procedure Setup;
    [TearDown] procedure TearDown;
    [Test] procedure InitialBytesAndEmptyDocument;
    [Test]
    [TestCase('Start', '0')]
    [TestCase('FirstSplit', '1')]
    [TestCase('Middle', '127')]
    [TestCase('LastByte', '255')]
    [TestCase('End', '256')]
    procedure InsertDeleteRoundTrip(Offset: Integer);
    [Test] procedure OverwriteAcrossOriginalAndMemoryPieces;
    [Test] procedure ReplacementChangesLengthAcrossPieces;
    [Test] procedure WriteExtendsAtEndAndClampsPastEnd;
    [Test] procedure DeleteClampsAndEmptyEditsDoNothing;
    [Test] procedure InvalidOffsetsLeaveBytesUnchanged;
    [Test] procedure ReadHonorsBufferCapacityAndEOF;
    [Test] procedure SnapshotAndMemoryRestoreAreIndependent;
    [Test] procedure InvalidRestoreDoesNotCorruptDocument;
    [Test] procedure PartialSnapshotRestoresDeletedSpan;
    [Test] procedure OverwriteOriginalBytesClearsDirty;
    [Test] procedure OffsetsAboveTwoGiBAreNotTruncated;
    [Test]
    [TestCase('Seed1', '1,4000')]
    [TestCase('Seed97', '97,4000')]
    [TestCase('Seed65537', '65537,4000')]
    [TestCase('Seed20261016', '20261016,4000')]
    procedure RandomEditsMatchByteArray(Seed, Steps: Integer);
  end;

implementation

uses System.Math, NimbusHexEditor.DUnitX.Support;

type
  TSparseHexSource = class(TInterfacedObject, IHexDataSource)
  private
    FLength: Int64;
    FOnLengthChanged: TNotifyEvent;
  public
    constructor Create(ALength: Int64);
    function GetLength: Int64;
    function GetCanWrite: Boolean;
    function Read(const Offset: Int64; var Buffer: TBytes; const Count: Integer): Integer;
    procedure Write(const Offset: Int64; const Data: TBytes);
    procedure Insert(const Offset: Int64; const Data: TBytes);
    procedure Delete(const Offset, Count: Int64);
    function GetOnLengthChanged: TNotifyEvent;
    procedure SetOnLengthChanged(const Value: TNotifyEvent);
  end;

constructor TSparseHexSource.Create(ALength: Int64);
begin inherited Create; FLength := ALength; end;

function TSparseHexSource.GetLength: Int64;
begin Result := FLength; end;

function TSparseHexSource.GetCanWrite: Boolean;
begin Result := False; end;

function TSparseHexSource.Read(const Offset: Int64; var Buffer: TBytes; const Count: Integer): Integer;
var I: Integer;
begin
  if (Offset < 0) or (Offset >= FLength) or (Count <= 0) then Exit(0);
  Result := Integer(Min(Int64(Count), FLength - Offset)); SetLength(Buffer, Result);
  for I := 0 to Result - 1 do Buffer[I] := Byte((Offset + I) and $FF);
end;

procedure TSparseHexSource.Write(const Offset: Int64; const Data: TBytes);
begin raise ENotSupportedException.Create('Read-only synthetic source'); end;

procedure TSparseHexSource.Insert(const Offset: Int64; const Data: TBytes);
begin raise ENotSupportedException.Create('Read-only synthetic source'); end;

procedure TSparseHexSource.Delete(const Offset, Count: Int64);
begin raise ENotSupportedException.Create('Read-only synthetic source'); end;

function TSparseHexSource.GetOnLengthChanged: TNotifyEvent;
begin Result := FOnLengthChanged; end;

procedure TSparseHexSource.SetOnLengthChanged(const Value: TNotifyEvent);
begin FOnLengthChanged := Value; end;

procedure THexPieceTableTests.Setup;
begin
  FInitial := HexPattern(256); FSource := TBytesHexDataSource.Create(FInitial);
  FDocument := THexDocument.Create(FSource); FKeepAlive := FDocument;
end;

procedure THexPieceTableTests.TearDown;
begin FDocument := nil; FKeepAlive := nil; FSource := nil; FInitial := nil; end;

procedure THexPieceTableTests.InitialBytesAndEmptyDocument;
var Empty: THexDocument; Keep: IHexDataSource;
begin
  CheckHexDocument(FDocument, FInitial, 'initial document'); Assert.IsFalse(FDocument.IsDirty);
  Empty := THexDocument.Create(TBytesHexDataSource.Create(nil)); Keep := Empty;
  try
    CheckHexDocument(Empty, nil, 'empty document');
    Empty.Insert(0, TBytes.Create(0, 255)); CheckHexDocument(Empty, TBytes.Create(0, 255), 'insert into empty');
    Empty.Delete(0, 2); CheckHexDocument(Empty, nil, 'delete to empty'); Assert.IsFalse(Empty.IsDirty);
  finally Keep := nil; end;
end;

procedure THexPieceTableTests.InsertDeleteRoundTrip(Offset: Integer);
var Data: TBytes; Pieces: TObjectList<THexPieceInfo>;
begin
  Data := TBytes.Create(0, 255, 0, 128, 17);
  FDocument.Insert(Offset, Data); CheckHexDocument(FDocument, HexSplice(FInitial, Offset, 0, Data), 'insert');
  Assert.IsTrue(FDocument.IsDirty); CheckHexBytes(FInitial, HexReadAll(FSource), 'original source unchanged');
  FDocument.Delete(Offset, Length(Data)); CheckHexDocument(FDocument, FInitial, 'delete inserted range');
  Assert.IsFalse(FDocument.IsDirty);
  Pieces := FDocument.ExportPieces;
  try Assert.IsTrue(Pieces.Count = 1, 'original pieces should merge after insert/delete'); finally Pieces.Free; end;
end;

procedure THexPieceTableTests.OverwriteAcrossOriginalAndMemoryPieces;
var Expected, Data: TBytes;
begin
  Expected := FInitial; Data := TBytes.Create(250, 0, 251, 255);
  FDocument.Insert(100, Data); Expected := HexSplice(Expected, 100, 0, Data);
  Data := HexPattern(24, 211); FDocument.Write(94, Data); Expected := HexSplice(Expected, 94, 24, Data);
  CheckHexDocument(FDocument, Expected, 'overwrite across three pieces');
  CheckHexBytes(FInitial, HexReadAll(FSource), 'overwrite must not mutate backing source');
end;

procedure THexPieceTableTests.ReplacementChangesLengthAcrossPieces;
var Expected: TBytes;
begin
  FDocument.Insert(30, TBytes.Create(1, 2, 3)); Expected := HexSplice(FInitial, 30, 0, TBytes.Create(1, 2, 3));
  FDocument.Insert(60, TBytes.Create(4, 5)); Expected := HexSplice(Expected, 60, 0, TBytes.Create(4, 5));
  FDocument.ReplaceBytes(28, 45, TBytes.Create(0, 255)); Expected := HexSplice(Expected, 28, 45, TBytes.Create(0, 255));
  CheckHexDocument(FDocument, Expected, 'replace mixed original and inserted pieces');
  FDocument.ReplaceBytes(0, FDocument.Length, nil); CheckHexDocument(FDocument, nil, 'replace all with empty');
end;

procedure THexPieceTableTests.WriteExtendsAtEndAndClampsPastEnd;
var Expected, Data: TBytes;
begin
  Data := TBytes.Create(10, 11, 12, 13, 14); FDocument.Write(254, Data); Expected := HexSplice(FInitial, 254, 2, Data);
  CheckHexDocument(FDocument, Expected, 'write extends EOF');
  FDocument.Write(1000, Data); Expected := HexSplice(Expected, Length(Expected), 0, Data);
  CheckHexDocument(FDocument, Expected, 'document write beyond EOF appends without zero gap');
end;

procedure THexPieceTableTests.DeleteClampsAndEmptyEditsDoNothing;
begin
  FDocument.Insert(10, nil); FDocument.Write(10, nil); FDocument.Delete(10, 0); FDocument.Delete(1000, 7);
  CheckHexDocument(FDocument, FInitial, 'no-op edits'); Assert.IsFalse(FDocument.IsDirty);
  FDocument.Delete(250, 1000); CheckHexDocument(FDocument, Copy(FInitial, 0, 250), 'delete clips EOF');
end;

procedure THexPieceTableTests.InvalidOffsetsLeaveBytesUnchanged;
begin
  CheckHexException(procedure begin FDocument.Insert(-1, TBytes.Create(1)); end, EArgumentOutOfRangeException, 'negative insert');
  CheckHexException(procedure begin FDocument.Write(-1, TBytes.Create(1)); end, EArgumentOutOfRangeException, 'negative write');
  CheckHexException(procedure begin FDocument.Delete(-1, 1); end, EArgumentOutOfRangeException, 'negative delete');
  CheckHexException(procedure begin FDocument.ReplaceBytes(257, 0, TBytes.Create(1)); end, EArgumentOutOfRangeException, 'invalid replace offset');
  CheckHexException(procedure begin FDocument.ReplaceBytes(0, -1, nil); end, EArgumentOutOfRangeException, 'negative replacement length');
  CheckHexDocument(FDocument, FInitial, 'rejected edits are atomic'); Assert.IsFalse(FDocument.IsDirty);
end;

procedure THexPieceTableTests.ReadHonorsBufferCapacityAndEOF;
var Buffer: TBytes; Count: Integer;
begin
  SetLength(Buffer, 3); Count := FDocument.Read(10, Buffer, 100);
  Assert.IsTrue(Count = 3); CheckHexBytes(TBytes.Create(10, 11, 12), Buffer, 'bounded read');
  SetLength(Buffer, 8); FillChar(Buffer[0], 8, $CC); Count := FDocument.Read(254, Buffer, 8);
  Assert.IsTrue((Count = 2) and (Buffer[0] = 254) and (Buffer[1] = 255) and (Buffer[2] = $CC), 'short read and untouched tail');
  Assert.IsTrue(FDocument.Read(256, Buffer, 8) = 0); Assert.IsTrue(FDocument.Read(0, Buffer, 0) = 0);
  CheckHexException(procedure begin FDocument.Read(-1, Buffer, 1); end, EArgumentOutOfRangeException, 'negative read');
end;

procedure THexPieceTableTests.SnapshotAndMemoryRestoreAreIndependent;
var Memory, Expected: TBytes; Pieces: TObjectList<THexPieceInfo>;
begin
  FDocument.Insert(20, TBytes.Create(0, 255)); Expected := HexSplice(FInitial, 20, 0, TBytes.Create(0, 255));
  Memory := FDocument.ExportMemoryBuffer; Pieces := FDocument.ExportPieces;
  try
    FDocument.Delete(0, 70); FDocument.Insert(0, HexPattern(50));
    FDocument.RestoreState(Memory, Pieces); CheckHexDocument(FDocument, Expected, 'restore complete piece snapshot');
    Pieces.Clear; if Length(Memory) > 0 then Memory[0] := Memory[0] xor $FF;
    CheckHexDocument(FDocument, Expected, 'restore must copy exported snapshot and memory');
  finally Pieces.Free; end;
end;

procedure THexPieceTableTests.InvalidRestoreDoesNotCorruptDocument;
var Pieces: TObjectList<THexPieceInfo>; Piece: THexPieceInfo;
begin
  Pieces := TObjectList<THexPieceInfo>.Create(True);
  try
    Piece := THexPieceInfo.Create; Pieces.Add(Piece); Piece.Source := hpsMemory; Piece.SourceOffset := 0; Piece.Length := 2;
    CheckHexException(procedure begin FDocument.RestoreState(TBytes.Create(1), Pieces); end, EArgumentException, 'out-of-range memory piece');
    Piece.Source := hpsOriginal; Piece.SourceOffset := -1; Piece.Length := 1;
    CheckHexException(procedure begin FDocument.RestoreState(nil, Pieces); end, EArgumentException, 'negative original source offset');
    CheckHexDocument(FDocument, FInitial, 'failed restore retains complete original state'); Assert.IsFalse(FDocument.IsDirty);
  finally Pieces.Free; end;
end;

procedure THexPieceTableTests.PartialSnapshotRestoresDeletedSpan;
var Expected: TBytes; Pieces: TObjectList<THexPieceInfo>;
begin
  FDocument.Insert(30, TBytes.Create(0, 255, 7)); Expected := HexSplice(FInitial, 30, 0, TBytes.Create(0, 255, 7));
  Pieces := FDocument.GetPiecesSnapshot(24, 20);
  try
    Assert.IsTrue(FDocument.GetRangeLength(Pieces) = 20, 'partial snapshot length');
    FDocument.Delete(24, 20); FDocument.ReplaceRange(24, 0, Pieces);
    CheckHexDocument(FDocument, Expected, 'restore deleted range from original and memory pieces');
    Pieces.Clear; CheckHexDocument(FDocument, Expected, 'partial snapshot owns no live pieces');
  finally Pieces.Free; end;
end;

procedure THexPieceTableTests.OverwriteOriginalBytesClearsDirty;
begin
  FDocument.Write(20, TBytes.Create(255, 254)); Assert.IsTrue(FDocument.IsDirty);
  FDocument.Write(20, Copy(FInitial, 20, 2)); CheckHexDocument(FDocument, FInitial, 'restore bytes by overwrite');
  Assert.IsFalse(FDocument.IsDirty, 'dirty state follows content, not mere history presence');
end;

procedure THexPieceTableTests.OffsetsAboveTwoGiBAreNotTruncated;
var Document: THexDocument; Keep: IHexDataSource; Start, Total: Int64; Expected, Actual, Data: TBytes;
begin
  Total := Int64(MaxInt) + 8192; Start := Int64(MaxInt) - 32;
  Document := THexDocument.Create(TSparseHexSource.Create(Total)); Keep := Document;
  try
    Expected := HexPattern(96, Start); Data := TBytes.Create(0, 255, 128, 1);
    Document.Insert(Start + 40, Data); Expected := HexSplice(Expected, 40, 0, Data);
    Document.Delete(Start + 6, 5); Expected := HexSplice(Expected, 6, 5, nil);
    Data := TBytes.Create(77, 88, 99); Document.Write(Start + 52, Data); Expected := HexSplice(Expected, 52, 3, Data);
    SetLength(Actual, Length(Expected)); Assert.IsTrue(Document.Read(Start, Actual, Length(Actual)) = Length(Actual));
    CheckHexBytes(Expected, Actual, '64-bit offset window'); Assert.IsTrue(Document.Length = Total - 1); CheckHexPieces(Document, '64-bit pieces');
  finally Keep := nil; end;
end;

procedure THexPieceTableTests.RandomEditsMatchByteArray(Seed, Steps: Integer);
var Random: THexTestRandom; Expected, Data: TBytes; I, Kind, Offset, Removed: Integer; Context: string;
begin
  Random.Init(Seed); Expected := Copy(FInitial);
  for I := 1 to Steps do
  begin
    Kind := Random.Next(4); Offset := Random.Next(Length(Expected) + 1); Data := Random.Bytes(Random.Next(17));
    Removed := Min(Random.Next(25), Length(Expected) - Offset);
    if Length(Expected) > 4096 then Kind := 2;
    case Kind of
      0: Removed := 0;
      1: Removed := Min(Length(Data), Length(Expected) - Offset);
      2: Data := nil;
    end;
    Context := Format('seed=%d step=%d operation=%d offset=%d remove=%d add=%d', [Seed, I, Kind, Offset, Removed, Length(Data)]);
    case Kind of
      0: begin FDocument.Insert(Offset, Data); Expected := HexSplice(Expected, Offset, 0, Data); end;
      1: begin Removed := Min(Length(Data), Length(Expected) - Offset); FDocument.Write(Offset, Data); Expected := HexSplice(Expected, Offset, Removed, Data); end;
      2: begin FDocument.Delete(Offset, Removed); Expected := HexSplice(Expected, Offset, Removed, nil); end;
      3: begin FDocument.ReplaceBytes(Offset, Removed, Data); Expected := HexSplice(Expected, Offset, Removed, Data); end;
    end;
    CheckHexDocument(FDocument, Expected, Context); CheckHexBytes(FInitial, HexReadAll(FSource), Context + ': immutable source');
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(THexPieceTableTests);

end.

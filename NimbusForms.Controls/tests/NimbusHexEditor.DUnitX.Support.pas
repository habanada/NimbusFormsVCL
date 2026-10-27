unit NimbusHexEditor.DUnitX.Support;

interface

uses System.SysUtils, System.Classes, NimbusForms.HexEditor.DataSource, NimbusForms.HexEditor.Document;

type
  THexTestRandom = record
  private
    FState: Cardinal;
  public
    procedure Init(Seed: Integer);
    function Next(Bound: Integer): Integer;
    function Bytes(Count: Integer): TBytes;
  end;

  THexTestSandbox = class
  private
    FDirectory: string;
  public
    constructor Create;
    destructor Destroy; override;
    function FileName(const Name: string): string;
    property Directory: string read FDirectory;
  end;

function HexPattern(Count: Integer; Start: Int64 = 0): TBytes;
function HexReadAll(const Source: IHexDataSource): TBytes;
function HexSplice(const Data: TBytes; Offset, Removed: Integer; const Added: TBytes): TBytes;
procedure CheckHexTestPath(const Path: string);
procedure CheckHexBytes(const Expected, Actual: TBytes; const Context: string);
procedure CheckHexException(const Action: TProc; Expected: ExceptClass; const Context: string);
procedure CheckHexPieces(Document: THexDocument; const Context: string);
procedure CheckHexDocument(Document: THexDocument; const Expected: TBytes; const Context: string);

implementation

uses Winapi.Windows, System.IOUtils, System.Math, System.Generics.Collections, DUnitX.TestFramework,
  NimbusForms.HexEditor.Pieces;

procedure THexTestRandom.Init(Seed: Integer);
begin FState := Cardinal(Seed); if FState = 0 then FState := 1; end;

function THexTestRandom.Next(Bound: Integer): Integer;
begin
  if Bound <= 0 then raise EArgumentOutOfRangeException.Create('Bound');
  FState := FState xor (FState shl 13); FState := FState xor (FState shr 17); FState := FState xor (FState shl 5);
  Result := Integer(FState mod Cardinal(Bound));
end;

function THexTestRandom.Bytes(Count: Integer): TBytes;
var I: Integer;
begin SetLength(Result, Count); for I := 0 to Count - 1 do Result[I] := Next(256); end;

procedure CheckHexTestPath(const Path: string);
const Root = 'E:\Projects\NimbusForms\NimbusForms.Controls\build\';
var Full, Probe: string; Attributes: DWORD;
begin
  Full := TPath.GetFullPath(Path);
  if not Full.StartsWith(Root, True) then raise EInvalidOperation.Create('Test files must remain under NimbusForms.Controls\build');
  Probe := Full;
  while Length(Probe) >= Length('E:\Projects\NimbusForms') do
  begin
    Attributes := GetFileAttributes(PChar(Probe));
    if (Attributes <> INVALID_FILE_ATTRIBUTES) and ((Attributes and FILE_ATTRIBUTE_REPARSE_POINT) <> 0) then
      raise EInvalidOperation.Create('Linked test path');
    Probe := ExtractFileDir(Probe);
  end;
end;

constructor THexTestSandbox.Create;
var ID: TGUID;
begin
  inherited;
  CreateGUID(ID);
  FDirectory := 'E:\Projects\NimbusForms\NimbusForms.Controls\build\hexeditor-dunitx\fixtures\' + GUIDToString(ID);
  CheckHexTestPath(FDirectory); TDirectory.CreateDirectory(FDirectory);
end;

destructor THexTestSandbox.Destroy;
var Path: string;
begin
  try
    if DirectoryExists(FDirectory) then
    begin
      CheckHexTestPath(FDirectory);
      for Path in TDirectory.GetFiles(FDirectory) do begin CheckHexTestPath(Path); TFile.Delete(Path); end;
      TDirectory.Delete(FDirectory, False);
    end;
  finally inherited; end;
end;

function THexTestSandbox.FileName(const Name: string): string;
begin
  if (Name = '') or (ExtractFileName(Name) <> Name) or (Name = '.') or (Name = '..') then
    raise EArgumentException.Create('A file name without a directory is required');
  Result := TPath.Combine(FDirectory, Name); CheckHexTestPath(Result);
end;

function HexPattern(Count: Integer; Start: Int64): TBytes;
var I: Integer;
begin SetLength(Result, Count); for I := 0 to Count - 1 do Result[I] := Byte((Start + I) and $FF); end;

function HexReadAll(const Source: IHexDataSource): TBytes;
var Count: Integer;
begin
  Assert.IsTrue((Source.Length >= 0) and (Source.Length <= MaxInt), 'ReadAll test allocation range');
  SetLength(Result, Integer(Source.Length));
  Count := Source.Read(0, Result, Length(Result));
  Assert.IsTrue(Count = Length(Result), 'ReadAll returned an incomplete byte sequence');
end;

function HexSplice(const Data: TBytes; Offset, Removed: Integer; const Added: TBytes): TBytes;
var I, Tail, AddedCount: Integer;
begin
  if (Offset < 0) or (Offset > Length(Data)) or (Removed < 0) or (Removed > Length(Data) - Offset) then
    raise EArgumentOutOfRangeException.Create('Reference splice');
  AddedCount := Length(Added); Tail := Length(Data) - Offset - Removed;
  SetLength(Result, Length(Data) - Removed + AddedCount);
  for I := 0 to Offset - 1 do Result[I] := Data[I];
  for I := 0 to AddedCount - 1 do Result[Offset + I] := Added[I];
  for I := 0 to Tail - 1 do Result[Offset + AddedCount + I] := Data[Offset + Removed + I];
end;

procedure CheckHexBytes(const Expected, Actual: TBytes; const Context: string);
var I: Integer;
begin
  Assert.IsTrue(Length(Expected) = Length(Actual), Format('%s: length expected=%d actual=%d', [Context, Length(Expected), Length(Actual)]));
  for I := 0 to High(Expected) do
    if Expected[I] <> Actual[I] then Assert.Fail(Format('%s: byte %d expected=%2.2x actual=%2.2x', [Context, I, Expected[I], Actual[I]]));
end;

procedure CheckHexException(const Action: TProc; Expected: ExceptClass; const Context: string);
var Raised: Boolean;
begin
  Raised := False;
  try Action();
  except on E: Exception do begin Raised := True; Assert.IsTrue(E.InheritsFrom(Expected), Context + ': ' + E.ClassName + ': ' + E.Message); end; end;
  Assert.IsTrue(Raised, Context + ': expected ' + Expected.ClassName);
end;

procedure CheckHexPieces(Document: THexDocument; const Context: string);
var Pieces: TObjectList<THexPieceInfo>; Piece: THexPieceInfo; Memory: TBytes; Total, Limit: Int64;
begin
  Pieces := Document.ExportPieces;
  try
    Memory := Document.ExportMemoryBuffer; Total := 0;
    for Piece in Pieces do
    begin
      if Piece.Source = hpsOriginal then Limit := Document.GetOriginalSource.Length else Limit := Length(Memory);
      Assert.IsTrue((Piece.SourceOffset >= 0) and (Piece.Length > 0) and (Piece.SourceOffset <= Limit) and
        (Piece.Length <= Limit - Piece.SourceOffset), Context + ': invalid piece source bounds');
      Assert.IsTrue(Piece.Length <= High(Int64) - Total, Context + ': piece length overflow'); Inc(Total, Piece.Length);
    end;
    Assert.IsTrue(Total = Document.Length, Context + ': piece lengths do not equal document length');
  finally Pieces.Free; end;
end;

procedure CheckHexDocument(Document: THexDocument; const Expected: TBytes; const Context: string);
var Pieces: TObjectList<THexPieceInfo>; Piece: THexPieceInfo; Memory, Rebuilt, Block, Partial: TBytes;
  Cursor, I, Offset, Count, Read: Integer;
begin
  Assert.IsTrue(Document.Length = Length(Expected), Context + ': document length');
  CheckHexBytes(Expected, HexReadAll(Document), Context); CheckHexPieces(Document, Context);
  Pieces := Document.ExportPieces;
  try
    Memory := Document.ExportMemoryBuffer; SetLength(Rebuilt, Length(Expected)); Cursor := 0;
    for Piece in Pieces do
    begin
      Count := Integer(Piece.Length);
      if Piece.Source = hpsOriginal then
      begin
        SetLength(Block, Count); Read := Document.GetOriginalSource.Read(Piece.SourceOffset, Block, Count);
        Assert.IsTrue(Read = Count, Context + ': incomplete original piece');
      end
      else Block := Copy(Memory, Integer(Piece.SourceOffset), Count);
      for I := 0 to Count - 1 do Rebuilt[Cursor + I] := Block[I];
      Inc(Cursor, Count);
    end;
    CheckHexBytes(Expected, Rebuilt, Context + ': exported piece reconstruction');
  finally Pieces.Free; end;
  Offset := 0;
  while Offset < Length(Expected) do
  begin
    Count := Min(37, Length(Expected) - Offset); SetLength(Partial, Count);
    Read := Document.Read(Offset, Partial, Count);
    Assert.IsTrue(Read = Count, Context + ': partial read count');
    CheckHexBytes(Copy(Expected, Offset, Count), Partial, Context + ': partial read'); Inc(Offset, Count);
  end;
end;

end.

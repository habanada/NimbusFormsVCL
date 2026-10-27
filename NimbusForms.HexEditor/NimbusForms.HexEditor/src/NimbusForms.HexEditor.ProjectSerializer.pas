unit NimbusForms.HexEditor.ProjectSerializer;

interface

uses
  System.SysUtils,
  NimbusForms.HexEditor.Session;

type
  THexProjectSerializer = class
  public
    class procedure Save(const AFilePath: string; const AProject: THexProjectData); static;
    class function Load(const AFilePath: string): THexProjectData; static;
    class function ToByteArray(const AProject: THexProjectData): TBytes; static;
    class function FromByteArray(const AData: TBytes): THexProjectData; static;
  end;

implementation

uses
  System.Classes,
  System.Generics.Collections,
  NimbusForms.HexEditor.Pieces;

const
  CMagic = Integer($4E485850);
  CVersion = 1;
  SSavePathRequired = 'filePath';
  SFilePathRequired = 'filePath';
  SProjectDataRequired = 'data';
  SInvalidProjectFile = 'Invalid project file.';
  SUnsupportedProjectVersion = 'Unsupported project version.';
  CMSecsPerDay = 86400000;

procedure WriteByteArray(const AWriter: TBinaryWriter; const AData: TBytes);
begin
  if AData = nil then
  begin
    AWriter.Write(Integer(-1));
    Exit;
  end;
  AWriter.Write(Integer(Length(AData)));
  if Length(AData) > 0 then
    AWriter.Write(AData);
end;

function ReadByteArray(const AReader: TBinaryReader): TBytes;
var
  LLength: Integer;
begin
  LLength := AReader.ReadInt32;
  if LLength < 0 then
    Exit(nil);
  if LLength = 0 then
    Exit(TBytes.Create());
  Result := AReader.ReadBytes(LLength);
end;

procedure WritePiece(const AWriter: TBinaryWriter; const APiece: THexPieceInfo);
begin
  if APiece <> nil then
  begin
    AWriter.Write(Integer(Ord(APiece.Source)));
    AWriter.Write(APiece.SourceOffset);
    AWriter.Write(APiece.Length);
  end
  else
  begin
    AWriter.Write(Integer(0));
    AWriter.Write(Int64(0));
    AWriter.Write(Int64(0));
  end;
end;

function ReadPiece(const AReader: TBinaryReader): THexPieceInfo;
begin
  Result := THexPieceInfo.Create;
  Result.Source := THexPieceSource(AReader.ReadInt32);
  Result.SourceOffset := AReader.ReadInt64;
  Result.Length := AReader.ReadInt64;
end;

procedure WritePieces(const AWriter: TBinaryWriter; const APieces: TObjectList<THexPieceInfo>);
var
  I: Integer;
begin
  if APieces = nil then
  begin
    AWriter.Write(Integer(0));
    Exit;
  end;
  AWriter.Write(Integer(APieces.Count));
  for I := 0 to APieces.Count - 1 do
    WritePiece(AWriter, APieces[I]);
end;

procedure ReadPiecesInto(const AReader: TBinaryReader; const ATarget: TObjectList<THexPieceInfo>);
var
  LCount, I: Integer;
begin
  LCount := AReader.ReadInt32;
  for I := 0 to LCount - 1 do
    ATarget.Add(ReadPiece(AReader));
end;

procedure WriteOperations(const AWriter: TBinaryWriter; const AOperations: TObjectList<THexEditOperation>);
var
  I: Integer;
  LOp: THexEditOperation;
begin
  if AOperations = nil then
  begin
    AWriter.Write(Integer(0));
    Exit;
  end;
  AWriter.Write(Integer(AOperations.Count));
  for I := 0 to AOperations.Count - 1 do
  begin
    LOp := AOperations[I];
    AWriter.Write(Integer(Ord(LOp.OperationType)));
    AWriter.Write(LOp.Offset);
    AWriter.Write(LOp.OldLength);
    AWriter.Write(LOp.NewLength);
    WritePieces(AWriter, LOp.OldPieces);
    WritePieces(AWriter, LOp.NewPieces);
  end;
end;

procedure ReadOperationsInto(const AReader: TBinaryReader; const ATarget: TObjectList<THexEditOperation>);
var
  LCount, I: Integer;
  LOp: THexEditOperation;
begin
  LCount := AReader.ReadInt32;
  for I := 0 to LCount - 1 do
  begin
    LOp := THexEditOperation.Create;
    LOp.OperationType := THexEditOperationType(AReader.ReadInt32);
    LOp.Offset := AReader.ReadInt64;
    LOp.OldLength := AReader.ReadInt64;
    LOp.NewLength := AReader.ReadInt64;
    ReadPiecesInto(AReader, LOp.OldPieces);
    ReadPiecesInto(AReader, LOp.NewPieces);
    ATarget.Add(LOp);
  end;
end;

procedure WriteBookmarks(const AWriter: TBinaryWriter; const ABookmarks: TObjectList<THexBookmarkData>);
var
  I: Integer;
  LBookmark: THexBookmarkData;
begin
  if ABookmarks = nil then
  begin
    AWriter.Write(Integer(0));
    Exit;
  end;
  AWriter.Write(Integer(ABookmarks.Count));
  for I := 0 to ABookmarks.Count - 1 do
  begin
    LBookmark := ABookmarks[I];
    AWriter.Write(LBookmark.Offset);
    AWriter.Write(Integer(LBookmark.Argb));
    AWriter.Write(LBookmark.Name);
  end;
end;

procedure ReadBookmarksInto(const AReader: TBinaryReader; const ATarget: TObjectList<THexBookmarkData>);
var
  LCount, I: Integer;
  LBookmark: THexBookmarkData;
begin
  LCount := AReader.ReadInt32;
  for I := 0 to LCount - 1 do
  begin
    LBookmark := THexBookmarkData.Create;
    LBookmark.Offset := AReader.ReadInt64;
    LBookmark.Argb := AReader.ReadInt32;
    LBookmark.Name := AReader.ReadString;
    ATarget.Add(LBookmark);
  end;
end;

procedure WriteSession(const AWriter: TBinaryWriter; const ASession: THexSessionData);
begin
  AWriter.Write(ASession.OriginalFilePath);
  AWriter.Write(ASession.CreateBackup);
  AWriter.Write(ASession.CursorOffset);
  AWriter.Write(ASession.SelectionStart);
  AWriter.Write(ASession.SelectionLength);
  WriteByteArray(AWriter, ASession.MemoryBuffer);
  WritePieces(AWriter, ASession.Pieces);
  WriteOperations(AWriter, ASession.UndoStack);
  WriteOperations(AWriter, ASession.RedoStack);
  WriteBookmarks(AWriter, ASession.Bookmarks);
end;

function ReadSession(const AReader: TBinaryReader): THexSessionData;
begin
  Result := THexSessionData.Create;
  Result.OriginalFilePath := AReader.ReadString;
  Result.CreateBackup := AReader.ReadBoolean;
  Result.CursorOffset := AReader.ReadInt64;
  Result.SelectionStart := AReader.ReadInt64;
  Result.SelectionLength := AReader.ReadInt64;
  Result.MemoryBuffer := ReadByteArray(AReader);
  ReadPiecesInto(AReader, Result.Pieces);
  ReadOperationsInto(AReader, Result.UndoStack);
  ReadOperationsInto(AReader, Result.RedoStack);
  ReadBookmarksInto(AReader, Result.Bookmarks);
end;

procedure WriteProject(const AWriter: TBinaryWriter; const AProject: THexProjectData);
begin
  AWriter.Write(AProject.ProjectName);
  AWriter.Write(AProject.ApplicationName);
  AWriter.Write(AProject.FormatName);
  AWriter.Write(Integer(AProject.FormatVersion));
  AWriter.Write(Int64(Round(AProject.CreatedUtc * CMSecsPerDay)));
  AWriter.Write(Int64(Round(AProject.SavedUtc * CMSecsPerDay)));
  WriteSession(AWriter, AProject.Session);
end;

function ReadProject(const AReader: TBinaryReader): THexProjectData;
begin
  Result := THexProjectData.Create;
  Result.ProjectName := AReader.ReadString;
  Result.ApplicationName := AReader.ReadString;
  Result.FormatName := AReader.ReadString;
  Result.FormatVersion := AReader.ReadInt32;
  Result.CreatedUtc := AReader.ReadInt64 / CMSecsPerDay;
  Result.SavedUtc := AReader.ReadInt64 / CMSecsPerDay;
  Result.Session := ReadSession(AReader);
end;

class procedure THexProjectSerializer.Save(const AFilePath: string; const AProject: THexProjectData);
var
  LStream: TFileStream;
  LWriter: TBinaryWriter;
begin
  if Trim(AFilePath) = '' then
    raise EArgumentException.Create(SSavePathRequired);
  if (AProject = nil) or (AProject.Session = nil) then
    raise EArgumentNilException.Create('project');
  AProject.FormatVersion := CVersion;
  AProject.SavedUtc := Now;
  LStream := TFileStream.Create(AFilePath, fmCreate);
  try
    LWriter := TBinaryWriter.Create(LStream, TEncoding.UTF8, False);
    try
      LWriter.Write(Integer(CMagic));
      LWriter.Write(Integer(CVersion));
      WriteProject(LWriter, AProject);
    finally
      LWriter.Free;
    end;
  finally
    LStream.Free;
  end;
end;

class function THexProjectSerializer.Load(const AFilePath: string): THexProjectData;
var
  LStream: TFileStream;
  LReader: TBinaryReader;
  LMagic, LVersion: Integer;
begin
  if Trim(AFilePath) = '' then
    raise EArgumentException.Create(SFilePathRequired);
  LStream := TFileStream.Create(AFilePath, fmOpenRead or fmShareDenyWrite);
  try
    LReader := TBinaryReader.Create(LStream, TEncoding.UTF8, False);
    try
      LMagic := LReader.ReadInt32;
      if LMagic <> CMagic then
        raise EReadError.Create(SInvalidProjectFile);
      LVersion := LReader.ReadInt32;
      if LVersion <> CVersion then
        raise EReadError.Create(SUnsupportedProjectVersion);
      Result := ReadProject(LReader);
    finally
      LReader.Free;
    end;
  finally
    LStream.Free;
  end;
end;

class function THexProjectSerializer.ToByteArray(const AProject: THexProjectData): TBytes;
var
  LStream: TMemoryStream;
  LWriter: TBinaryWriter;
begin
  if (AProject = nil) or (AProject.Session = nil) then
    raise EArgumentNilException.Create('project');
  AProject.FormatVersion := CVersion;
  AProject.SavedUtc := Now;
  LStream := TMemoryStream.Create;
  try
    LWriter := TBinaryWriter.Create(LStream, TEncoding.UTF8, False);
    try
      LWriter.Write(Integer(CMagic));
      LWriter.Write(Integer(CVersion));
      WriteProject(LWriter, AProject);
    finally
      LWriter.Free;
    end;
    SetLength(Result, LStream.Size);
    if LStream.Size > 0 then
      Move(LStream.Memory^, Result[0], LStream.Size);
  finally
    LStream.Free;
  end;
end;

class function THexProjectSerializer.FromByteArray(const AData: TBytes): THexProjectData;
var
  LStream: TBytesStream;
  LReader: TBinaryReader;
  LMagic, LVersion: Integer;
begin
  if Length(AData) = 0 then
    raise EArgumentException.Create(SProjectDataRequired);
  LStream := TBytesStream.Create(AData);
  try
    LReader := TBinaryReader.Create(LStream, TEncoding.UTF8, False);
    try
      LMagic := LReader.ReadInt32;
      if LMagic <> CMagic then
        raise EReadError.Create(SInvalidProjectFile);
      LVersion := LReader.ReadInt32;
      if LVersion <> CVersion then
        raise EReadError.Create(SUnsupportedProjectVersion);
      Result := ReadProject(LReader);
    finally
      LReader.Free;
    end;
  finally
    LStream.Free;
  end;
end;

end.

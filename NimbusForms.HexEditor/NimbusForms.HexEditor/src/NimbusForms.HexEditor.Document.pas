unit NimbusForms.HexEditor.Document;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  NimbusForms.HexEditor.DataSource,
  NimbusForms.HexEditor.Pieces,
  NimbusForms.HexEditor.Patch;

type
  THexDocument = class(TInterfacedObject, IHexDataSource)
  private
    type
      TPieceSource = (psOriginal, psMemory);
      TPiece = class
        Source: TPieceSource;
        SourceOffset: Int64;
        Length: Int64;
        constructor Create(const ASource: TPieceSource; const ASourceOffset, ALength: Int64);
      end;
      TPieceSnapshot = class
        Pieces: TObjectList<TPiece>;
        TotalLength: Int64;
        constructor Create;
        destructor Destroy; override;
      end;
  private
    FOriginal: IHexDataSource;
    FMemoryBuffer: TMemoryStream;
    FPieces: TObjectList<TPiece>;
    FLength: Int64;
    FIsDirty: Boolean;
    FFilePath: string;
    FCreateBackup: Boolean;
    FOnLengthChanged: TNotifyEvent;
    FOnDirtyStateChanged: TNotifyEvent;
    function GetPiecesBetweenSplitOffsets(const AOffset, ALength: Int64): TPieceSnapshot;
    function CreateMemoryPieces(const AData: TBytes): TObjectList<TPiece>;
    procedure SplitAt(const AOffset: Int64);
    function GetPieceIndexAtOffset(const AOffset: Int64; out APieceStartOffset: Int64): Integer;
    procedure MergeAdjacentPieces;
    function IsPristineState: Boolean;
    procedure UpdateDirtyFromCurrentState;
    procedure SetDirty(const AValue: Boolean);
    procedure DoDirtyStateChanged;
    procedure DoLengthChanged;
    function ToPieceInfo(const APiece: TPiece): THexPieceInfo;
  public
    constructor Create(const AOriginal: IHexDataSource); overload;
    constructor Create(const AFilePath: string); overload;
    destructor Destroy; override;
    function GetLength: Int64;
    function GetCanWrite: Boolean;
    function Read(const AOffset: Int64; var ABuffer: TBytes; const ACount: Integer): Integer;
    procedure Write(const AOffset: Int64; const AData: TBytes);
    procedure Insert(const AOffset: Int64; const AData: TBytes);
    procedure Delete(const AOffset, ALength: Int64);
    function GetOnLengthChanged: TNotifyEvent;
    procedure SetOnLengthChanged(const AValue: TNotifyEvent);
    procedure ReplaceRange(const AOffset, ALength: Int64; const ANewPieces: TList<THexPieceInfo>);
    function CreateMemoryPieceInfos(const AData: TBytes): TObjectList<THexPieceInfo>;
    function GetPiecesSnapshot(const AOffset, ALength: Int64): TObjectList<THexPieceInfo>;
    function GetRangeLength(const APieces: TList<THexPieceInfo>): Int64;
    procedure ReadOriginal(const AOffset: Int64; var ABuffer: TBytes; const ACount: Integer);
    function TryReadOriginalByte(const AOffset: Int64; out AValue: Byte): Boolean;
    function IsOffsetModified(const AOffset: Int64): Boolean;
    function ExportPieces: TObjectList<THexPieceInfo>;
    function ExportMemoryBuffer: TBytes;
    function CreatePatch: THexPatchFile;
    procedure SaveAs(const APath: string);
    procedure Save;
    function CreateSessionData(const AUndoStack, ARedoStack: TObjectList<THexEditOperation>;
      const ACursorOffset, ASelectionStart, ASelectionLength: Int64;
      const ABookmarks: TObjectList<THexBookmarkData>): THexSessionData;
    procedure RestoreSessionData(const ASession: THexSessionData);
    property IsDirty: Boolean read FIsDirty;
    property FilePath: string read FFilePath;
    property CreateBackup: Boolean read FCreateBackup write FCreateBackup;
    property Length: Int64 read FLength;
    property CanWrite: Boolean read GetCanWrite;
    property OnLengthChanged: TNotifyEvent read FOnLengthChanged write FOnLengthChanged;
    property OnDirtyStateChanged: TNotifyEvent read FOnDirtyStateChanged write FOnDirtyStateChanged;
  end;

implementation

uses
  System.Math,
  System.IOUtils,
  NimbusForms.HexEditor.Session,
  NimbusForms.HexEditor.FileDataSource;

const
  SSaveAsRequired = 'A file path is required before saving.';
  SSavePathRequired = 'path';

{ THexDocument.TPiece }

constructor THexDocument.TPiece.Create(const ASource: TPieceSource; const ASourceOffset, ALength: Int64);
begin
  inherited Create;
  Source := ASource;
  SourceOffset := ASourceOffset;
  Length := ALength;
end;

{ THexDocument.TPieceSnapshot }

constructor THexDocument.TPieceSnapshot.Create;
begin
  inherited Create;
  Pieces := TObjectList<TPiece>.Create(True);
end;

destructor THexDocument.TPieceSnapshot.Destroy;
begin
  Pieces.Free;
  inherited Destroy;
end;

{ THexDocument }

constructor THexDocument.Create(const AOriginal: IHexDataSource);
begin
  inherited Create;
  if AOriginal = nil then
    raise EArgumentNilException.Create('original');
  FOriginal := AOriginal;
  FMemoryBuffer := TMemoryStream.Create;
  FPieces := TObjectList<TPiece>.Create(True);
  FCreateBackup := True;
  if FOriginal.Length > 0 then
    FPieces.Add(TPiece.Create(psOriginal, 0, FOriginal.Length));
  FLength := FOriginal.Length;
end;

constructor THexDocument.Create(const AFilePath: string);
begin
  Create(TFileHexDataSource.Create(AFilePath) as IHexDataSource);
  FFilePath := AFilePath;
end;

destructor THexDocument.Destroy;
begin
  FPieces.Free;
  FMemoryBuffer.Free;
  FOriginal := nil;
  inherited Destroy;
end;

function THexDocument.GetLength: Int64;
begin
  Result := FLength;
end;

function THexDocument.GetCanWrite: Boolean;
begin
  Result := True;
end;

function THexDocument.GetOnLengthChanged: TNotifyEvent;
begin
  Result := FOnLengthChanged;
end;

procedure THexDocument.SetOnLengthChanged(const AValue: TNotifyEvent);
begin
  FOnLengthChanged := AValue;
end;

function THexDocument.ToPieceInfo(const APiece: TPiece): THexPieceInfo;
begin
  Result := THexPieceInfo.Create;
  if APiece.Source = psOriginal then
    Result.Source := hpsOriginal
  else
    Result.Source := hpsMemory;
  Result.SourceOffset := APiece.SourceOffset;
  Result.Length := APiece.Length;
end;

function THexDocument.Read(const AOffset: Int64; var ABuffer: TBytes; const ACount: Integer): Integer;
var
  LCount, LBytesToRead, LTotalRead, LReadLength, LRead: Integer;
  LCurrent, LPieceOffset: Int64;
  LPiece: TPiece;
  LTemp: TBytes;
  I: Integer;
begin
  if (ACount <= 0) or (AOffset >= FLength) then
    Exit(0);
  if AOffset < 0 then
    raise EArgumentOutOfRangeException.Create('offset');
  LCount := ACount;
  if LCount > System.Length(ABuffer) then
    LCount := System.Length(ABuffer);
  LBytesToRead := Integer(Min(Int64(LCount), FLength - AOffset));
  LTotalRead := 0;
  LCurrent := 0;

  for I := 0 to FPieces.Count - 1 do
  begin
    LPiece := FPieces[I];
    if LCurrent + LPiece.Length <= AOffset then
    begin
      Inc(LCurrent, LPiece.Length);
      Continue;
    end;
    LPieceOffset := Max(Int64(0), AOffset - LCurrent);
    LReadLength := Integer(Min(Int64(LBytesToRead - LTotalRead), LPiece.Length - LPieceOffset));
    if LReadLength <= 0 then
    begin
      Inc(LCurrent, LPiece.Length);
      Continue;
    end;
    if LPiece.Source = psOriginal then
    begin
      SetLength(LTemp, LReadLength);
      LRead := FOriginal.Read(LPiece.SourceOffset + LPieceOffset, LTemp, LReadLength);
      if LRead > 0 then
      begin
        Move(LTemp[0], ABuffer[LTotalRead], LRead);
        Inc(LTotalRead, LRead);
      end;
    end
    else
    begin
      FMemoryBuffer.Position := LPiece.SourceOffset + LPieceOffset;
      LRead := FMemoryBuffer.Read(ABuffer[LTotalRead], LReadLength);
      if LRead > 0 then
        Inc(LTotalRead, LRead);
    end;
    Inc(LCurrent, LPiece.Length);
    if LTotalRead >= LBytesToRead then
      Break;
  end;

  Result := LTotalRead;
end;

function THexDocument.CreateMemoryPieces(const AData: TBytes): TObjectList<TPiece>;
var
  LMemoryOffset: Int64;
begin
  Result := TObjectList<TPiece>.Create(True);
  if System.Length(AData) = 0 then
    Exit;
  LMemoryOffset := FMemoryBuffer.Size;
  FMemoryBuffer.Position := FMemoryBuffer.Size;
  FMemoryBuffer.WriteBuffer(AData[0], System.Length(AData));
  Result.Add(TPiece.Create(psMemory, LMemoryOffset, System.Length(AData)));
end;

function THexDocument.CreateMemoryPieceInfos(const AData: TBytes): TObjectList<THexPieceInfo>;
var
  LPieces: TObjectList<TPiece>;
  LPiece: TPiece;
begin
  Result := TObjectList<THexPieceInfo>.Create(True);
  LPieces := CreateMemoryPieces(AData);
  try
    for LPiece in LPieces do
      Result.Add(ToPieceInfo(LPiece));
  finally
    LPieces.Free;
  end;
end;

procedure THexDocument.Write(const AOffset: Int64; const AData: TBytes);
var
  LOffset, LOverwriteLength: Int64;
  LNewPieces: TObjectList<THexPieceInfo>;
begin
  if System.Length(AData) = 0 then
    Exit;
  if AOffset < 0 then
    raise EArgumentOutOfRangeException.Create('offset');
  LOffset := AOffset;
  if LOffset > FLength then
    LOffset := FLength;
  LOverwriteLength := Min(Int64(System.Length(AData)), FLength - LOffset);
  LNewPieces := CreateMemoryPieceInfos(AData);
  try
    ReplaceRange(LOffset, LOverwriteLength, LNewPieces);
  finally
    LNewPieces.Free;
  end;
end;

procedure THexDocument.Insert(const AOffset: Int64; const AData: TBytes);
var
  LOffset: Int64;
  LNewPieces: TObjectList<THexPieceInfo>;
begin
  if System.Length(AData) = 0 then
    Exit;
  if AOffset < 0 then
    raise EArgumentOutOfRangeException.Create('offset');
  LOffset := AOffset;
  if LOffset > FLength then
    LOffset := FLength;
  LNewPieces := CreateMemoryPieceInfos(AData);
  try
    ReplaceRange(LOffset, 0, LNewPieces);
  finally
    LNewPieces.Free;
  end;
end;

procedure THexDocument.Delete(const AOffset, ALength: Int64);
var
  LDeleteLength: Int64;
begin
  if AOffset < 0 then
    raise EArgumentOutOfRangeException.Create('offset');
  if (AOffset >= FLength) or (ALength <= 0) then
    Exit;
  LDeleteLength := Min(ALength, FLength - AOffset);
  ReplaceRange(AOffset, LDeleteLength, nil);
end;

procedure THexDocument.ReplaceRange(const AOffset, ALength: Int64; const ANewPieces: TList<THexPieceInfo>);
var
  LEnd, LStartPieceOffset, LEndPieceOffset, LInsertTotalLength: Int64;
  LStartIndex, LEndIndex, LRemoveCount, LInsertCount, I: Integer;
  LInfo: THexPieceInfo;
begin
  if AOffset < 0 then
    raise EArgumentOutOfRangeException.Create('offset');
  if ALength < 0 then
    raise EArgumentOutOfRangeException.Create('length');
  if AOffset > FLength then
    raise EArgumentOutOfRangeException.Create('offset');

  LEnd := Min(AOffset + ALength, FLength);

  SplitAt(AOffset);
  SplitAt(LEnd);

  LStartIndex := GetPieceIndexAtOffset(AOffset, LStartPieceOffset);
  LEndIndex := GetPieceIndexAtOffset(LEnd, LEndPieceOffset);

  LRemoveCount := LEndIndex - LStartIndex;
  if LRemoveCount > 0 then
    FPieces.DeleteRange(LStartIndex, LRemoveCount);

  LInsertCount := 0;
  LInsertTotalLength := 0;
  if ANewPieces <> nil then
  begin
    for I := 0 to ANewPieces.Count - 1 do
    begin
      LInfo := ANewPieces[I];
      if (LInfo = nil) or (LInfo.Length <= 0) then
        Continue;
      if LInfo.Source = hpsOriginal then
        FPieces.Insert(LStartIndex + LInsertCount, TPiece.Create(psOriginal, LInfo.SourceOffset, LInfo.Length))
      else
        FPieces.Insert(LStartIndex + LInsertCount, TPiece.Create(psMemory, LInfo.SourceOffset, LInfo.Length));
      Inc(LInsertCount);
      Inc(LInsertTotalLength, LInfo.Length);
    end;
  end;

  FLength := FLength - (LEnd - AOffset) + LInsertTotalLength;

  MergeAdjacentPieces;
  UpdateDirtyFromCurrentState;
  DoLengthChanged;
end;

function THexDocument.GetPiecesBetweenSplitOffsets(const AOffset, ALength: Int64): TPieceSnapshot;
var
  LEnd, LCurrent, LPieceStart, LPieceEnd: Int64;
  LPiece, LClone: TPiece;
  I: Integer;
begin
  if AOffset < 0 then
    raise EArgumentOutOfRangeException.Create('offset');
  if ALength < 0 then
    raise EArgumentOutOfRangeException.Create('length');
  if AOffset > FLength then
    raise EArgumentOutOfRangeException.Create('offset');

  LEnd := Min(AOffset + ALength, FLength);
  Result := TPieceSnapshot.Create;
  if LEnd <= AOffset then
    Exit;

  SplitAt(AOffset);
  SplitAt(LEnd);

  LCurrent := 0;
  for I := 0 to FPieces.Count - 1 do
  begin
    LPiece := FPieces[I];
    LPieceStart := LCurrent;
    LPieceEnd := LCurrent + LPiece.Length;
    if (LPieceStart >= AOffset) and (LPieceEnd <= LEnd) then
    begin
      LClone := TPiece.Create(LPiece.Source, LPiece.SourceOffset, LPiece.Length);
      Result.Pieces.Add(LClone);
      Inc(Result.TotalLength, LClone.Length);
    end;
    LCurrent := LPieceEnd;
  end;
end;

function THexDocument.GetPiecesSnapshot(const AOffset, ALength: Int64): TObjectList<THexPieceInfo>;
var
  LSnapshot: TPieceSnapshot;
  LPiece: TPiece;
begin
  Result := TObjectList<THexPieceInfo>.Create(True);
  LSnapshot := GetPiecesBetweenSplitOffsets(AOffset, ALength);
  try
    for LPiece in LSnapshot.Pieces do
      Result.Add(ToPieceInfo(LPiece));
  finally
    LSnapshot.Free;
  end;
end;

function THexDocument.GetRangeLength(const APieces: TList<THexPieceInfo>): Int64;
var
  LPiece: THexPieceInfo;
begin
  Result := 0;
  if APieces = nil then
    Exit;
  for LPiece in APieces do
    if LPiece <> nil then
      Inc(Result, LPiece.Length);
end;

procedure THexDocument.ReadOriginal(const AOffset: Int64; var ABuffer: TBytes; const ACount: Integer);
var
  LCount, LTotalRead, LReadLength, LRead: Integer;
  LCurrentOffset: Int64;
  LTemp: TBytes;
begin
  if AOffset < 0 then
    raise EArgumentOutOfRangeException.Create('offset');
  if (ACount <= 0) or (FOriginal = nil) or (AOffset >= FOriginal.Length) then
    Exit;
  LCount := ACount;
  if LCount > System.Length(ABuffer) then
    LCount := System.Length(ABuffer);
  LTotalRead := 0;
  while LTotalRead < LCount do
  begin
    LCurrentOffset := AOffset + LTotalRead;
    if LCurrentOffset >= FOriginal.Length then
      Break;
    LReadLength := Integer(Min(Int64(LCount - LTotalRead), FOriginal.Length - LCurrentOffset));
    SetLength(LTemp, LReadLength);
    LRead := FOriginal.Read(LCurrentOffset, LTemp, LReadLength);
    if LRead <= 0 then
      Break;
    Move(LTemp[0], ABuffer[LTotalRead], LRead);
    Inc(LTotalRead, LRead);
  end;
end;

function THexDocument.TryReadOriginalByte(const AOffset: Int64; out AValue: Byte): Boolean;
var
  LBuffer: TBytes;
begin
  AValue := 0;
  if (AOffset < 0) or (FOriginal = nil) or (AOffset >= FOriginal.Length) then
    Exit(False);
  SetLength(LBuffer, 1);
  if FOriginal.Read(AOffset, LBuffer, 1) <> 1 then
    Exit(False);
  AValue := LBuffer[0];
  Result := True;
end;

function THexDocument.IsOffsetModified(const AOffset: Int64): Boolean;
var
  LCurrent: TBytes;
  LOriginal: Byte;
begin
  if not FIsDirty then
    Exit(False);
  if (AOffset < 0) or (AOffset >= FLength) then
    Exit(False);
  SetLength(LCurrent, 1);
  if Read(AOffset, LCurrent, 1) <> 1 then
    Exit(False);
  if not TryReadOriginalByte(AOffset, LOriginal) then
    Exit(True);
  Result := LCurrent[0] <> LOriginal;
end;

procedure THexDocument.SplitAt(const AOffset: Int64);
var
  LCurrent, LPieceStart, LPieceEnd, LLeftLength, LRightLength: Int64;
  LPiece, LRight: TPiece;
  I: Integer;
begin
  if (AOffset <= 0) or (AOffset >= FLength) then
    Exit;
  LCurrent := 0;
  for I := 0 to FPieces.Count - 1 do
  begin
    LPiece := FPieces[I];
    LPieceStart := LCurrent;
    LPieceEnd := LCurrent + LPiece.Length;
    if (LPieceStart < AOffset) and (LPieceEnd > AOffset) then
    begin
      LLeftLength := AOffset - LPieceStart;
      LRightLength := LPiece.Length - LLeftLength;
      LRight := TPiece.Create(LPiece.Source, LPiece.SourceOffset + LLeftLength, LRightLength);
      LPiece.Length := LLeftLength;
      FPieces.Insert(I + 1, LRight);
      Exit;
    end;
    LCurrent := LPieceEnd;
  end;
end;

function THexDocument.GetPieceIndexAtOffset(const AOffset: Int64; out APieceStartOffset: Int64): Integer;
var
  LCurrent, LNext: Int64;
  I: Integer;
begin
  if (AOffset < 0) or (AOffset > FLength) then
    raise EArgumentOutOfRangeException.Create('offset');
  LCurrent := 0;
  for I := 0 to FPieces.Count - 1 do
  begin
    LNext := LCurrent + FPieces[I].Length;
    if AOffset = LCurrent then
    begin
      APieceStartOffset := LCurrent;
      Exit(I);
    end;
    if (AOffset > LCurrent) and (AOffset < LNext) then
    begin
      APieceStartOffset := LCurrent;
      Exit(I);
    end;
    LCurrent := LNext;
  end;
  APieceStartOffset := FLength;
  Result := FPieces.Count;
end;

procedure THexDocument.MergeAdjacentPieces;
var
  I: Integer;
  LCurrent, LNext: TPiece;
begin
  if FPieces.Count <= 1 then
    Exit;
  I := 0;
  while I < FPieces.Count - 1 do
  begin
    LCurrent := FPieces[I];
    LNext := FPieces[I + 1];
    if (LCurrent.Source = LNext.Source) and (LCurrent.SourceOffset + LCurrent.Length = LNext.SourceOffset) then
    begin
      LCurrent.Length := LCurrent.Length + LNext.Length;
      FPieces.Delete(I + 1);
      Continue;
    end;
    Inc(I);
  end;
end;

function THexDocument.IsPristineState: Boolean;
var
  LPiece: TPiece;
  LOriginalLength: Int64;
begin
  if FMemoryBuffer.Size <> 0 then
    Exit(False);
  if FOriginal <> nil then
    LOriginalLength := FOriginal.Length
  else
    LOriginalLength := 0;
  if FPieces.Count = 0 then
    Exit(LOriginalLength = 0);
  if FPieces.Count <> 1 then
    Exit(False);
  LPiece := FPieces[0];
  Result := (LPiece.Source = psOriginal) and (LPiece.SourceOffset = 0) and (LPiece.Length = LOriginalLength);
end;

procedure THexDocument.UpdateDirtyFromCurrentState;
begin
  SetDirty(not IsPristineState);
end;

procedure THexDocument.SetDirty(const AValue: Boolean);
begin
  if FIsDirty = AValue then
    Exit;
  FIsDirty := AValue;
  DoDirtyStateChanged;
end;

procedure THexDocument.DoDirtyStateChanged;
begin
  if Assigned(FOnDirtyStateChanged) then
    FOnDirtyStateChanged(Self);
end;

procedure THexDocument.DoLengthChanged;
begin
  if Assigned(FOnLengthChanged) then
    FOnLengthChanged(Self);
end;

function THexDocument.ExportPieces: TObjectList<THexPieceInfo>;
var
  LPiece: TPiece;
begin
  Result := TObjectList<THexPieceInfo>.Create(True);
  for LPiece in FPieces do
    Result.Add(ToPieceInfo(LPiece));
end;

function THexDocument.ExportMemoryBuffer: TBytes;
begin
  SetLength(Result, FMemoryBuffer.Size);
  if FMemoryBuffer.Size > 0 then
    Move(FMemoryBuffer.Memory^, Result[0], FMemoryBuffer.Size);
end;

function THexDocument.CreatePatch: THexPatchFile;
var
  LCurrentOutputOffset, LOriginalCursor, LOriginalLength: Int64;
  LPiece: TPiece;
  LOp: THexPatchOperation;
  LData: TBytes;
begin
  Result := THexPatchFile.Create;
  Result.OriginalFilePath := FFilePath;
  if FOriginal <> nil then
    LOriginalLength := FOriginal.Length
  else
    LOriginalLength := 0;
  Result.OriginalLength := LOriginalLength;

  LCurrentOutputOffset := 0;
  LOriginalCursor := 0;

  for LPiece in FPieces do
  begin
    if LPiece.Source = psOriginal then
    begin
      if LPiece.SourceOffset > LOriginalCursor then
      begin
        LOp := THexPatchOperation.Create;
        LOp.OperationType := hpoDelete;
        LOp.Offset := LCurrentOutputOffset;
        LOp.Length := LPiece.SourceOffset - LOriginalCursor;
        Result.Operations.Add(LOp);
      end;
      Inc(LCurrentOutputOffset, LPiece.Length);
      LOriginalCursor := LPiece.SourceOffset + LPiece.Length;
    end
    else
    begin
      SetLength(LData, LPiece.Length);
      FMemoryBuffer.Position := LPiece.SourceOffset;
      if LPiece.Length > 0 then
        FMemoryBuffer.ReadBuffer(LData[0], LPiece.Length);
      LOp := THexPatchOperation.Create;
      LOp.OperationType := hpoInsert;
      LOp.Offset := LCurrentOutputOffset;
      LOp.Data := LData;
      LOp.Length := System.Length(LData);
      Result.Operations.Add(LOp);
      Inc(LCurrentOutputOffset, LPiece.Length);
    end;
  end;

  if (FOriginal <> nil) and (LOriginalCursor < LOriginalLength) then
  begin
    LOp := THexPatchOperation.Create;
    LOp.OperationType := hpoDelete;
    LOp.Offset := LCurrentOutputOffset;
    LOp.Length := LOriginalLength - LOriginalCursor;
    Result.Operations.Add(LOp);
  end;
end;

procedure THexDocument.Save;
begin
  if FFilePath = '' then
    raise EInvalidOpException.Create(SSaveAsRequired);
  SaveAs(FFilePath);
end;

procedure THexDocument.SaveAs(const APath: string);
var
  LTempPath, LBackupPath: string;
  LStream: TFileStream;
  LBuffer: TBytes;
  LPosition: Int64;
  LRead: Integer;
begin
  if Trim(APath) = '' then
    raise EArgumentException.Create(SSavePathRequired);
  LTempPath := APath + '.tmp';
  try
    LStream := TFileStream.Create(LTempPath, fmCreate);
    try
      SetLength(LBuffer, 81920);
      LPosition := 0;
      while LPosition < FLength do
      begin
        LRead := Read(LPosition, LBuffer, System.Length(LBuffer));
        if LRead <= 0 then
          Break;
        LStream.WriteBuffer(LBuffer[0], LRead);
        Inc(LPosition, LRead);
      end;
    finally
      LStream.Free;
    end;

    if TFile.Exists(APath) then
    begin
      if FCreateBackup then
      begin
        LBackupPath := APath + '.bak';
        if TFile.Exists(LBackupPath) then
          TFile.Delete(LBackupPath);
        TFile.Move(APath, LBackupPath);
      end
      else
        TFile.Delete(APath);
    end;

    TFile.Move(LTempPath, APath);

    FOriginal := nil;
    FOriginal := TFileHexDataSource.Create(APath) as IHexDataSource;
    FFilePath := APath;

    FPieces.Clear;
    FMemoryBuffer.Clear;
    if FOriginal.Length > 0 then
      FPieces.Add(TPiece.Create(psOriginal, 0, FOriginal.Length));
    FLength := FOriginal.Length;
    SetDirty(False);
    DoLengthChanged;
  except
    if TFile.Exists(LTempPath) then
    begin
      try
        TFile.Delete(LTempPath);
      except
      end;
    end;
    raise;
  end;
end;

function THexDocument.CreateSessionData(const AUndoStack, ARedoStack: TObjectList<THexEditOperation>;
  const ACursorOffset, ASelectionStart, ASelectionLength: Int64;
  const ABookmarks: TObjectList<THexBookmarkData>): THexSessionData;
var
  LPiece: TPiece;
  LOp: THexEditOperation;
  LBookmark: THexBookmarkData;
begin
  Result := THexSessionData.Create;
  Result.OriginalFilePath := FFilePath;
  Result.CreateBackup := FCreateBackup;
  Result.MemoryBuffer := ExportMemoryBuffer;
  Result.CursorOffset := ACursorOffset;
  Result.SelectionStart := ASelectionStart;
  Result.SelectionLength := ASelectionLength;
  for LPiece in FPieces do
    Result.Pieces.Add(ToPieceInfo(LPiece));
  if AUndoStack <> nil then
    for LOp in AUndoStack do
      Result.UndoStack.Add(LOp.Clone);
  if ARedoStack <> nil then
    for LOp in ARedoStack do
      Result.RedoStack.Add(LOp.Clone);
  if ABookmarks <> nil then
    for LBookmark in ABookmarks do
      Result.Bookmarks.Add(LBookmark.Clone);
end;

procedure THexDocument.RestoreSessionData(const ASession: THexSessionData);
var
  LInfo: THexPieceInfo;
begin
  if ASession = nil then
    raise EArgumentNilException.Create('session');
  FOriginal := nil;
  FOriginal := TFileHexDataSource.Create(ASession.OriginalFilePath) as IHexDataSource;
  FFilePath := ASession.OriginalFilePath;
  FCreateBackup := ASession.CreateBackup;
  FPieces.Clear;
  FMemoryBuffer.Clear;
  if (ASession.MemoryBuffer <> nil) and (System.Length(ASession.MemoryBuffer) > 0) then
  begin
    FMemoryBuffer.WriteBuffer(ASession.MemoryBuffer[0], System.Length(ASession.MemoryBuffer));
    FMemoryBuffer.Position := 0;
  end;
  for LInfo in ASession.Pieces do
  begin
    if (LInfo = nil) or (LInfo.Length <= 0) then
      Continue;
    if LInfo.Source = hpsOriginal then
      FPieces.Add(TPiece.Create(psOriginal, LInfo.SourceOffset, LInfo.Length))
    else
      FPieces.Add(TPiece.Create(psMemory, LInfo.SourceOffset, LInfo.Length));
  end;
  FLength := 0;
  for var LPiece in FPieces do
    Inc(FLength, LPiece.Length);
  UpdateDirtyFromCurrentState;
  DoLengthChanged;
end;

end.
{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.CodeEditor.Document;

interface

uses System.Classes, System.SysUtils, System.Generics.Collections,
  NimbusForms.Controls.CodeEditor.Types, NimbusForms.Controls.LogViewer.Types,
  NimbusForms.Controls.CodeEditor.PieceTable, NimbusForms.Controls.CodeEditor.LineIndex;

type
  TCodeTextEncoding = TNimbusLogFileEncoding;
  TCodeDocumentChange = record
    Range: TCodeDocumentRange;
    Offset, Version: Integer;
    OldText, NewText: string;
    Reset: Boolean;
  end;
  TCodeDocumentChangeEvent = procedure(Sender: TObject; const Change: TCodeDocumentChange) of object;
  ICodeVirtualTextSource = interface
    ['{AFA13215-104C-40B5-A1F9-3CBDB43B6377}']
    function GetLineCount: Integer;
    function GetTextLength: Integer;
    function GetVersion: Integer;
    function GetLineText(const LineIndex: Integer): string;
    function GetLineLength(const LineIndex: Integer): Integer;
    function GetLineEndingKind(const LineIndex: Integer): TCodeEditorNewLineKind;
    function GetLineStartOffset(const LineIndex: Integer): Integer;
    function GetOffset(const Position: TCodeDocumentPosition): Integer;
    function GetPosition(const Offset: Integer): TCodeDocumentPosition;
    property LineCount: Integer read GetLineCount;
    property TextLength: Integer read GetTextLength;
    property Version: Integer read GetVersion;
  end;
  TCodeDocumentSnapshot = class(TInterfacedObject, ICodeVirtualTextSource)
  private
    FTable: TCodePieceTable;
    FVersion: Integer;
    FEndings: TArray<TCodeEditorNewLineKind>;
  public
    constructor Create(const Lines: TArray<string>; const Version: Integer;
      const Endings: TArray<TCodeEditorNewLineKind>); overload;
    constructor Create(Table: TCodePieceTable; const Version: Integer;
      const Endings: TArray<TCodeEditorNewLineKind>); overload;
    destructor Destroy; override;
    function GetLineCount: Integer;
    function GetTextLength: Integer;
    function GetVersion: Integer;
    function GetLineText(const LineIndex: Integer): string;
    function GetLineLength(const LineIndex: Integer): Integer;
    function GetLineEndingKind(const LineIndex: Integer): TCodeEditorNewLineKind;
    function GetLineStartOffset(const LineIndex: Integer): Integer;
    function GetOffset(const Position: TCodeDocumentPosition): Integer;
    function GetPosition(const Offset: Integer): TCodeDocumentPosition;
  end;
  TCodeDocument = class(TComponent, ICodeVirtualTextSource)
  private
    FTable: TCodePieceTable;
    FLineIndex: TCodeLineIndex;
    FLineTextCache: TCodeDocumentLineTextCache;
    FEndings: TList<TCodeEditorNewLineKind>;
    FVersion: Integer;
    FReadOnly, FModified, FHasBOM, FEncodingConfidenceHigh: Boolean;
    FFileName, FEncodingReason: string;
    FEncoding: TCodeTextEncoding;
    FNewLineMode: TCodeEditorNewLineMode;
    FNewLineKind: TCodeEditorNewLineKind;
    FLoadedByteLength: Int64;
    FIsLargeFile: Boolean;
    FOnChange: TCodeDocumentChangeEvent;
    FOnModifiedChanged: TNotifyEvent;
    function GetText: string;
    function GetPieceCount: Integer;
    procedure SetText(const Value: string);
    procedure SetModified(const Value: Boolean);
    procedure ReplaceAll(const Text: string; const Loading: Boolean; const Endings: TArray<TCodeEditorNewLineKind>);
    procedure RecalculateNewLineKind;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetLineCount: Integer;
    function GetTextLength: Integer;
    function GetVersion: Integer;
    function GetLineText(const LineIndex: Integer): string;
    function GetLineLength(const LineIndex: Integer): Integer;
    function GetLineEndingKind(const LineIndex: Integer): TCodeEditorNewLineKind;
    function GetLineStartOffset(const LineIndex: Integer): Integer;
    function GetOffset(const Position: TCodeDocumentPosition): Integer;
    function GetPosition(const Offset: Integer): TCodeDocumentPosition;
    function GetTextRange(const Range: TCodeDocumentRange): string;
    function GetSnapshot: ICodeVirtualTextSource;
    function GetViewSnapshot: ICodeVirtualTextSource;
    function GetEndingRange(const First, Count: Integer): TArray<TCodeEditorNewLineKind>;
    procedure RestoreEndingRange(const First: Integer; const Endings: TArray<TCodeEditorNewLineKind>);
    function Clamp(const Position: TCodeDocumentPosition): TCodeDocumentPosition;
    procedure Replace(const Range: TCodeDocumentRange; const Text: string);
    procedure Insert(const Position: TCodeDocumentPosition; const Text: string);
    function Delete(const Range: TCodeDocumentRange): string;
    procedure LoadFromFile(const Path: string; const Encoding: TCodeTextEncoding = nlfeAuto;
      const LargeFileThresholdBytes: Int64 = 5242880);
    procedure SaveToFile(const Path: string);
    procedure MarkSaved;
    procedure RestoreModified(const Value: Boolean);
    procedure ValidateStorage;
    property Text: string read GetText write SetText;
    property LineCount: Integer read GetLineCount;
    property TextLength: Integer read GetTextLength;
    property Version: Integer read FVersion;
    property StoragePieceCount: Integer read GetPieceCount;
    property ReadOnly: Boolean read FReadOnly write FReadOnly;
    property IsModified: Boolean read FModified;
    property FileName: string read FFileName;
    property Encoding: TCodeTextEncoding read FEncoding write FEncoding;
    property NewLineMode: TCodeEditorNewLineMode read FNewLineMode write FNewLineMode;
    property NewLineKind: TCodeEditorNewLineKind read FNewLineKind;
    property HasByteOrderMark: Boolean read FHasBOM write FHasBOM;
    property EncodingReason: string read FEncodingReason;
    property EncodingConfidenceHigh: Boolean read FEncodingConfidenceHigh;
    property LoadedByteLength: Int64 read FLoadedByteLength;
    property IsLargeFile: Boolean read FIsLargeFile;
    property OnChange: TCodeDocumentChangeEvent read FOnChange write FOnChange;
    property OnModifiedChanged: TNotifyEvent read FOnModifiedChanged write FOnModifiedChanged;
  end;
  TCodeUndoUnit = record
    Offset: Integer;
    OldText, NewText, Name: string;
    BeforeModified, AfterModified: Boolean;
    OldEndings, NewEndings: TArray<TCodeEditorNewLineKind>;
  end;
  TCodeEditorUndoManager = class
  private
    FUndo, FRedo: TList<TCodeUndoUnit>;
    FRestoring, FGroup: Boolean;
    FGroupBefore, FGroupName: string;
    FGroupModified: Boolean;
    FGroupEndings: TArray<TCodeEditorNewLineKind>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Push(const UnitValue: TCodeUndoUnit);
    procedure Clear;
    procedure BreakMerge;
    procedure MarkSaved;
    procedure BeginGroup(Document: TCodeDocument; const Name: string);
    procedure EndGroup(Document: TCodeDocument);
    function CanUndo: Boolean;
    function CanRedo: Boolean;
    function Undo(Document: TCodeDocument; out Position: TCodeDocumentPosition): Boolean;
    function Redo(Document: TCodeDocument; out Position: TCodeDocumentPosition): Boolean;
    property IsRestoring: Boolean read FRestoring;
  end;

implementation

uses Winapi.Windows, System.Math, System.IOUtils, NimbusForms.Controls.LogViewer.Encoding;

constructor TCodeDocumentSnapshot.Create(const Lines: TArray<string>; const Version: Integer;
  const Endings: TArray<TCodeEditorNewLineKind>);
begin
  inherited Create; FTable := TCodePieceTable.Create(#10); FTable.Text := string.Join(#10, Lines);
  FVersion := Version; FEndings := Copy(Endings);
end;
constructor TCodeDocumentSnapshot.Create(Table: TCodePieceTable; const Version: Integer;
  const Endings: TArray<TCodeEditorNewLineKind>);
begin
  inherited Create; if Table = nil then raise EArgumentNilException.Create('Table');
  FTable := Table.CreateSnapshot; FVersion := Version; FEndings := Copy(Endings);
end;
destructor TCodeDocumentSnapshot.Destroy;
begin FTable.Free; inherited; end;

function TCodeDocumentSnapshot.GetLineCount: Integer;
begin Result := FTable.LineCount; end;
function TCodeDocumentSnapshot.GetTextLength: Integer;
begin Result := FTable.Length; end;
function TCodeDocumentSnapshot.GetVersion: Integer;
begin Result := FVersion; end;
function TCodeDocumentSnapshot.GetLineText(const LineIndex: Integer): string;
begin Result := FTable.GetLineText(LineIndex); end;
function TCodeDocumentSnapshot.GetLineLength(const LineIndex: Integer): Integer;
begin Result := FTable.GetLineLength(LineIndex); end;
function TCodeDocumentSnapshot.GetLineEndingKind(const LineIndex: Integer): TCodeEditorNewLineKind;
begin if (LineIndex >= 0) and (LineIndex < Length(FEndings)) then Result := FEndings[LineIndex] else Result := cnkUnknown; end;
function TCodeDocumentSnapshot.GetLineStartOffset(const LineIndex: Integer): Integer;
begin Result := FTable.GetLineStartOffset(LineIndex); end;
function TCodeDocumentSnapshot.GetOffset(const Position: TCodeDocumentPosition): Integer;
begin Result := FTable.GetOffsetFromPosition(Position); end;
function TCodeDocumentSnapshot.GetPosition(const Offset: Integer): TCodeDocumentPosition;
begin Result := FTable.GetPositionFromOffset(Offset); end;

constructor TCodeDocument.Create(AOwner: TComponent);
begin
  inherited; FTable := TCodePieceTable.Create(#10); FLineIndex := TCodeLineIndex.Create(FTable);
  FLineTextCache := TCodeDocumentLineTextCache.Create;
  FEndings := TList<TCodeEditorNewLineKind>.Create; FEndings.Add(cnkUnknown);
  FEncoding := nlfeUTF8; FEncodingConfidenceHigh := True; FNewLineKind := cnkWindows;
end;
destructor TCodeDocument.Destroy;
begin FLineTextCache.Free; FLineIndex.Free; FTable.Free; FEndings.Free; inherited; end;
function TCodeDocument.GetLineCount: Integer;
begin Result := FTable.LineCount; end;
function TCodeDocument.GetTextLength: Integer;
begin Result := FTable.Length; end;
function TCodeDocument.GetVersion: Integer;
begin Result := FVersion; end;
function TCodeDocument.GetLineText(const LineIndex: Integer): string;
begin
  if (LineIndex < 0) or (LineIndex >= FTable.LineCount) then Exit('');
  if FLineTextCache.TryGet(LineIndex, Result) then Exit;
  Result := FTable.GetLineText(LineIndex); FLineTextCache.Put(LineIndex, Result);
end;
function TCodeDocument.GetLineLength(const LineIndex: Integer): Integer;
begin Result := FTable.GetLineLength(LineIndex); end;
function TCodeDocument.GetLineEndingKind(const LineIndex: Integer): TCodeEditorNewLineKind;
begin if (LineIndex >= 0) and (LineIndex < FEndings.Count) then Result := FEndings[LineIndex] else Result := cnkUnknown; end;
function TCodeDocument.GetText: string;
begin Result := FTable.Text; end;
function TCodeDocument.GetPieceCount: Integer;
begin Result := FTable.PieceCount; end;
procedure TCodeDocument.ValidateStorage;
begin
  FTable.ValidateStructure;
  if FEndings.Count <> FTable.LineCount then raise EInvalidOpException.Create('Document line endings do not match piece table');
end;

function TCodeDocument.Clamp(const Position: TCodeDocumentPosition): TCodeDocumentPosition;
begin
  Result.LineIndex := EnsureRange(Position.LineIndex, 0, FTable.LineCount - 1);
  Result.ColumnIndex := EnsureRange(Position.ColumnIndex, 0, FTable.GetLineLength(Result.LineIndex));
end;
function TCodeDocument.GetLineStartOffset(const LineIndex: Integer): Integer;
begin Result := FTable.GetLineStartOffset(LineIndex); end;
function TCodeDocument.GetOffset(const Position: TCodeDocumentPosition): Integer;
begin Result := FLineIndex.GetOffset(Position); end;
function TCodeDocument.GetPosition(const Offset: Integer): TCodeDocumentPosition;
begin Result := FLineIndex.GetPosition(Offset); end;
function TCodeDocument.GetSnapshot: ICodeVirtualTextSource;
begin Result := TCodeDocumentSnapshot.Create(FTable, FVersion, FEndings.ToArray); end;
function TCodeDocument.GetViewSnapshot: ICodeVirtualTextSource;
begin Result := Self; end;
function TCodeDocument.GetEndingRange(const First, Count: Integer): TArray<TCodeEditorNewLineKind>;
var I, Start, Size: Integer;
begin Start := EnsureRange(First, 0, FEndings.Count); Size := Min(Max(0, Count), FEndings.Count - Start); SetLength(Result, Size); for I := 0 to Size - 1 do Result[I] := FEndings[Start + I]; end;
procedure TCodeDocument.RecalculateNewLineKind;
var I: Integer;
begin
  FNewLineKind := cnkUnknown;
  for I := 0 to FEndings.Count - 1 do if FEndings[I] <> cnkUnknown then
    if FNewLineKind = cnkUnknown then FNewLineKind := FEndings[I] else if FNewLineKind <> FEndings[I] then FNewLineKind := cnkMixed;
end;
procedure TCodeDocument.RestoreEndingRange(const First: Integer; const Endings: TArray<TCodeEditorNewLineKind>);
var I: Integer;
begin
  for I := 0 to High(Endings) do if (First + I >= 0) and (First + I < FEndings.Count) then FEndings[First + I] := Endings[I];
  RecalculateNewLineKind;
end;

procedure TCodeDocument.SetModified(const Value: Boolean);
begin
  if FModified = Value then Exit; FModified := Value;
  if Assigned(FOnModifiedChanged) then FOnModifiedChanged(Self);
end;
procedure TCodeDocument.MarkSaved;
begin SetModified(False); end;
procedure TCodeDocument.RestoreModified(const Value: Boolean);
begin SetModified(Value); end;
procedure TCodeDocument.SetText(const Value: string);
var Endings: TList<TCodeEditorNewLineKind>; I: Integer;
begin
  Endings := TList<TCodeEditorNewLineKind>.Create;
  try
    I := 1;
    while I <= Length(Value) do
    begin
      if Value[I] = #13 then
      begin if (I < Length(Value)) and (Value[I + 1] = #10) then begin Endings.Add(cnkWindows); Inc(I); end else Endings.Add(cnkMacintosh); end
      else if Value[I] = #10 then Endings.Add(cnkUnix);
      Inc(I);
    end;
    Endings.Add(cnkUnknown); ReplaceAll(Value, False, Endings.ToArray);
  finally Endings.Free; end;
end;

procedure TCodeDocument.ReplaceAll(const Text: string; const Loading: Boolean; const Endings: TArray<TCodeEditorNewLineKind>);
var Change: TCodeDocumentChange;
begin
  FTable.Text := Text; FLineTextCache.Clear;
  FEndings.Clear; FEndings.AddRange(Endings); while FEndings.Count < FTable.LineCount do FEndings.Add(cnkUnknown);
  RecalculateNewLineKind;
  Inc(FVersion); SetModified(not Loading);
  Change := Default(TCodeDocumentChange); Change.Version := FVersion; Change.Reset := True;
  Change.Range := TCodeDocumentRange.Create(TCodeDocumentPosition.Create(0, 0), GetPosition(FTable.Length));
  if Assigned(FOnChange) then FOnChange(Self, Change);
end;

function TCodeDocument.GetTextRange(const Range: TCodeDocumentRange): string;
var R: TCodeDocumentRange; Start, Finish: Integer;
begin
  R := TCodeDocumentRange.Create(Clamp(Range.Start), Clamp(Range.Finish));
  Start := GetOffset(R.Start); Finish := GetOffset(R.Finish); Result := FTable.GetText(Start, Finish - Start);
end;

procedure TCodeDocument.Replace(const Range: TCodeDocumentRange; const Text: string);
var Change: TCodeDocumentChange; R: TCodeDocumentRange;
  LastEnding, NewEnding: TCodeEditorNewLineKind; NewEndings: TArray<TCodeEditorNewLineKind>; I, Breaks: Integer; C: Char;
begin
  if FReadOnly then raise EInvalidOpException.Create('Read only');
  R := TCodeDocumentRange.Create(Clamp(Range.Start), Clamp(Range.Finish));
  Change := Default(TCodeDocumentChange); Change.Offset := GetOffset(R.Start);
  Change.OldText := GetTextRange(R); Change.NewText := CodeNormalizeNewLines(Text);
  if Change.OldText = Change.NewText then Exit;
  Breaks := 0; for C in Change.NewText do if C = #10 then Inc(Breaks);
  SetLength(NewEndings, Breaks);
  LastEnding := FEndings[R.Finish.LineIndex]; NewEnding := cnkWindows;
  if (FNewLineMode = cnmUnix) or ((FNewLineMode = cnmAuto) and (FNewLineKind = cnkUnix)) then NewEnding := cnkUnix;
  if (FNewLineMode = cnmAuto) and (FNewLineKind = cnkMacintosh) then NewEnding := cnkMacintosh;
  FTable.Delete(Change.Offset, Length(Change.OldText)); FTable.Insert(Change.Offset, Change.NewText);
  FLineTextCache.InvalidateFromLine(R.Start.LineIndex);
  if R.Finish.LineIndex > R.Start.LineIndex then
  begin FEndings.DeleteRange(R.Start.LineIndex + 1, R.Finish.LineIndex - R.Start.LineIndex); end;
  if Breaks = 0 then FEndings[R.Start.LineIndex] := LastEnding
  else
  begin
    FEndings[R.Start.LineIndex] := NewEnding;
    for I := 0 to High(NewEndings) do NewEndings[I] := NewEnding; NewEndings[High(NewEndings)] := LastEnding;
    FEndings.InsertRange(R.Start.LineIndex + 1, NewEndings);
  end;
  if (Breaks > 0) or (R.Finish.LineIndex > R.Start.LineIndex) then
    RecalculateNewLineKind;
  Inc(FVersion); Change.Version := FVersion;
  Change.Range := TCodeDocumentRange.Create(R.Start, GetPosition(Change.Offset + Length(Change.NewText)));
  SetModified(True);
  if Assigned(FOnChange) then FOnChange(Self, Change);
end;
procedure TCodeDocument.Insert(const Position: TCodeDocumentPosition; const Text: string);
begin Replace(TCodeDocumentRange.Create(Position, Position), Text); end;
function TCodeDocument.Delete(const Range: TCodeDocumentRange): string;
begin Result := GetTextRange(Range); Replace(Range, ''); end;

procedure TCodeDocument.LoadFromFile(const Path: string; const Encoding: TCodeTextEncoding; const LargeFileThresholdBytes: Int64);
var Stream: TFileStream; Decoder: TNimbusLogLineDecoder; Buffer, Sample: TBytes;
  Lines: TList<string>; Part: string; Parts: TArray<string>; ReadCount, BOM, I, Size: Integer;
  Actual: TCodeTextEncoding; PrevCR, FinalBreak: Boolean; CRLF, LF, CR: Integer; C: Cardinal;
  Carry: TBytes; Scan: TBytes; ByteLength: Int64; Kind: TCodeEditorNewLineKind;
  Endings: TList<TCodeEditorNewLineKind>;
begin
  Lines := TList<string>.Create; Endings := TList<TCodeEditorNewLineKind>.Create;
  try
    Stream := TFileStream.Create(Path, fmOpenRead or fmShareDenyNone);
    try
      ByteLength := Stream.Size; SetLength(Buffer, 4096);
      ReadCount := Stream.Read(Buffer[0], Length(Buffer)); Sample := Copy(Buffer, 0, ReadCount);
      Actual := TNimbusLogTextCodec.Detect(Sample, Encoding, BOM); Stream.Position := BOM;
      Decoder := TNimbusLogLineDecoder.Create(Actual);
      try
        SetLength(Buffer, 65536); Size := TNimbusLogTextCodec.UnitSize(Actual);
        PrevCR := False; FinalBreak := False; CRLF := 0; LF := 0; CR := 0; Carry := nil;
        repeat
          ReadCount := Stream.Read(Buffer[0], Length(Buffer));
          SetLength(Scan, Length(Carry) + ReadCount);
          if Length(Carry) > 0 then Move(Carry[0], Scan[0], Length(Carry));
          if ReadCount > 0 then Move(Buffer[0], Scan[Length(Carry)], ReadCount);
          I := 0;
          while I + Size <= Length(Scan) do
          begin
            C := TNimbusLogTextCodec.ReadUnit(Scan, I, Actual); FinalBreak := (C = 10) or (C = 13);
            if C = 10 then if PrevCR then begin Dec(CR); Inc(CRLF); Endings[Endings.Count - 1] := cnkWindows; end else begin Inc(LF); Endings.Add(cnkUnix); end;
            if C = 13 then begin Inc(CR); Endings.Add(cnkMacintosh); end; PrevCR := C = 13; Inc(I, Size);
          end;
          Carry := Copy(Scan, I, Length(Scan) - I);
          Parts := Decoder.Feed(Buffer, ReadCount, ReadCount = 0);
          for Part in Parts do Lines.Add(Part);
        until ReadCount = 0;
        if FinalBreak then Lines.Add('');
        if Lines.Count = 0 then Lines.Add('');
      finally Decoder.Free; end;
    finally Stream.Free; end;
    Kind := cnkUnknown;
    if CRLF > 0 then Kind := cnkWindows;
    if LF > 0 then if Kind = cnkUnknown then Kind := cnkUnix else Kind := cnkMixed;
    if CR > 0 then if Kind = cnkUnknown then Kind := cnkMacintosh else Kind := cnkMixed;
    FEncoding := Actual; FHasBOM := BOM > 0; FLoadedByteLength := ByteLength; FIsLargeFile := ByteLength >= LargeFileThresholdBytes;
    FEncodingConfidenceHigh := FHasBOM or (Encoding <> nlfeAuto) or (Actual in [nlfeUTF16LE, nlfeUTF16BE, nlfeUTF32LE, nlfeUTF32BE]);
    if FHasBOM then FEncodingReason := 'Byte order mark'
    else if Encoding <> nlfeAuto then FEncodingReason := 'Explicit encoding'
    else FEncodingReason := 'Byte pattern detection';
    Endings.Add(cnkUnknown); FFileName := Path; FNewLineKind := Kind; ReplaceAll(string.Join(#10, Lines.ToArray), True, Endings.ToArray);
  finally Endings.Free; Lines.Free; end;
end;

procedure TCodeDocument.SaveToFile(const Path: string);
var Stream: TFileStream; Temp, EOL, Line: string; Bytes: TBytes; I: Integer; G: TGUID;
  Actual: TCodeTextEncoding; ByteLength: Int64; Kind, WrittenKind: TCodeEditorNewLineKind;
  WrittenEndings: TArray<TCodeEditorNewLineKind>;
begin
  Actual := FEncoding; if Actual = nlfeAuto then Actual := nlfeUTF8;
  CreateGUID(G); Temp := Path + '.' + GUIDToString(G) + '.tmp';
  SetLength(WrittenEndings, FTable.LineCount); WrittenKind := cnkUnknown;
  try
    Stream := TFileStream.Create(Temp, fmCreate);
    try
      if FHasBOM then begin Bytes := TNimbusLogTextCodec.Preamble(Actual); if Length(Bytes) > 0 then Stream.WriteBuffer(Bytes[0], Length(Bytes)); end;
      for I := 0 to FTable.LineCount - 1 do
      begin
        Line := GetLineText(I);
        if I < FTable.LineCount - 1 then
        begin
          Kind := cnkWindows;
          if FNewLineMode = cnmUnix then Kind := cnkUnix
          else if FNewLineMode = cnmAuto then Kind := FEndings[I];
          case Kind of cnkUnix: EOL := #10; cnkMacintosh: EOL := #13; else EOL := #13#10; Kind := cnkWindows; end;
          WrittenEndings[I] := Kind;
          if WrittenKind = cnkUnknown then WrittenKind := Kind else if WrittenKind <> Kind then WrittenKind := cnkMixed;
          Line := Line + EOL;
        end
        else WrittenEndings[I] := cnkUnknown;
        Bytes := TNimbusLogTextCodec.Encode(Line, Actual); if Length(Bytes) > 0 then Stream.WriteBuffer(Bytes[0], Length(Bytes));
      end;
      ByteLength := Stream.Size;
    finally Stream.Free; end;
    if TFile.Exists(Path) then
    begin if not ReplaceFile(PChar(Path), PChar(Temp), nil, REPLACEFILE_IGNORE_MERGE_ERRORS, nil, nil) then RaiseLastOSError; end
    else if not MoveFileEx(PChar(Temp), PChar(Path), MOVEFILE_WRITE_THROUGH) then RaiseLastOSError;
    FEncoding := Actual; FFileName := Path; FLoadedByteLength := ByteLength;
    FHasBOM := FHasBOM and (Length(TNimbusLogTextCodec.Preamble(Actual)) > 0);
    FNewLineKind := WrittenKind; FEndings.Clear; FEndings.AddRange(WrittenEndings);
    FEncodingConfidenceHigh := True; FEncodingReason := 'Saved encoding'; MarkSaved;
  finally if TFile.Exists(Temp) then TFile.Delete(Temp); end;
end;

constructor TCodeEditorUndoManager.Create;
begin inherited; FUndo := TList<TCodeUndoUnit>.Create; FRedo := TList<TCodeUndoUnit>.Create; end;
destructor TCodeEditorUndoManager.Destroy;
begin FUndo.Free; FRedo.Free; inherited; end;
function TCodeEditorUndoManager.CanUndo: Boolean;
begin Result := FUndo.Count > 0; end;
function TCodeEditorUndoManager.CanRedo: Boolean;
begin Result := FRedo.Count > 0; end;
procedure TCodeEditorUndoManager.Clear;
begin FUndo.Clear; FRedo.Clear; FGroup := False; end;
procedure TCodeEditorUndoManager.BreakMerge;
var U: TCodeUndoUnit;
begin if FUndo.Count = 0 then Exit; U := FUndo.Last; U.Name := ''; FUndo[FUndo.Count - 1] := U; end;
procedure TCodeEditorUndoManager.MarkSaved;
var I: Integer; U: TCodeUndoUnit;
begin
  for I := 0 to FUndo.Count - 1 do
  begin U := FUndo[I]; U.BeforeModified := True; U.AfterModified := I <> FUndo.Count - 1; FUndo[I] := U; end;
  for I := 0 to FRedo.Count - 1 do
  begin U := FRedo[I]; U.BeforeModified := I <> FRedo.Count - 1; U.AfterModified := True; FRedo[I] := U; end;
  BreakMerge;
end;
procedure TCodeEditorUndoManager.Push(const UnitValue: TCodeUndoUnit);
var U: TCodeUndoUnit;
begin
  if FRestoring or FGroup then Exit; FRedo.Clear;
  if (FUndo.Count > 0) and (UnitValue.Name = 'Typing') and (UnitValue.OldText = '') and (Pos(#10, UnitValue.NewText) = 0) then
  begin
    U := FUndo.Last;
    if (U.Name = 'Typing') and (U.OldText = '') and (U.Offset + Length(U.NewText) = UnitValue.Offset) then
    begin U.NewText := U.NewText + UnitValue.NewText; U.NewEndings := UnitValue.NewEndings; U.AfterModified := UnitValue.AfterModified; FUndo[FUndo.Count - 1] := U; Exit; end;
  end;
  FUndo.Add(UnitValue);
end;
procedure TCodeEditorUndoManager.BeginGroup(Document: TCodeDocument; const Name: string);
begin
  if FGroup then raise EInvalidOpException.Create('Undo group already active');
  FGroupBefore := Document.Text; FGroupEndings := Document.GetEndingRange(0, Document.LineCount); FGroupName := Name; FGroupModified := Document.IsModified; FGroup := True;
end;
procedure TCodeEditorUndoManager.EndGroup(Document: TCodeDocument);
var U: TCodeUndoUnit;
begin
  if not FGroup then raise EInvalidOpException.Create('No undo group'); FGroup := False;
  U := Default(TCodeUndoUnit); U.OldText := FGroupBefore; U.NewText := Document.Text;
  U.OldEndings := FGroupEndings; U.NewEndings := Document.GetEndingRange(0, Document.LineCount); FGroupEndings := nil;
  U.Name := FGroupName; U.BeforeModified := FGroupModified; U.AfterModified := Document.IsModified;
  FGroupBefore := ''; if U.OldText <> U.NewText then Push(U);
end;
function TCodeEditorUndoManager.Undo(Document: TCodeDocument; out Position: TCodeDocumentPosition): Boolean;
var U: TCodeUndoUnit; R: TCodeDocumentRange;
begin
  Result := CanUndo and not Document.ReadOnly; if not Result then Exit;
  U := FUndo.Last; R := TCodeDocumentRange.Create(Document.GetPosition(U.Offset), Document.GetPosition(U.Offset + Length(U.NewText)));
  FRestoring := True;
  try Document.Replace(R, U.OldText); Document.RestoreEndingRange(R.Start.LineIndex, U.OldEndings); Document.RestoreModified(U.BeforeModified); FRedo.Add(U); FUndo.Delete(FUndo.Count - 1); Position := Document.GetPosition(U.Offset + Length(U.OldText));
  finally FRestoring := False; end;
end;
function TCodeEditorUndoManager.Redo(Document: TCodeDocument; out Position: TCodeDocumentPosition): Boolean;
var U: TCodeUndoUnit; R: TCodeDocumentRange;
begin
  Result := CanRedo and not Document.ReadOnly; if not Result then Exit;
  U := FRedo.Last; R := TCodeDocumentRange.Create(Document.GetPosition(U.Offset), Document.GetPosition(U.Offset + Length(U.OldText)));
  FRestoring := True;
  try Document.Replace(R, U.NewText); Document.RestoreEndingRange(R.Start.LineIndex, U.NewEndings); Document.RestoreModified(U.AfterModified); FUndo.Add(U); FRedo.Delete(FRedo.Count - 1); Position := Document.GetPosition(U.Offset + Length(U.NewText));
  finally FRestoring := False; end;
end;

end.

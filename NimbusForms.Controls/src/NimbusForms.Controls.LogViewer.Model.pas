{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.LogViewer.Model;

interface

uses System.Classes, System.SysUtils, NimbusForms.Controls.LogViewer.Types,
  NimbusForms.Controls.LogViewer.Structured, NimbusForms.Controls.LogViewer.Links;

type
  TNimbusLogLine = class
  private
    FID: UInt64;
    FText: string;
    FLevel: TNimbusLogLevel;
    FLevelExplicit: Boolean;
    FLevelReady: Boolean;
    FTokensReady: Boolean;
    FStructuredReady: Boolean;
    FLinksReady: Boolean;
    FTokens: TNimbusLogTokens;
    FStructured: TNimbusStructuredLogEntry;
    FLinks: TNimbusLogInteractiveRuns;
    procedure EnsureTokens;
    procedure EnsureStructured;
    procedure EnsureLinks;
    function GetLevel: TNimbusLogLevel;
    function GetTokens: TNimbusLogTokens;
    function GetStructured: TNimbusStructuredLogEntry;
    function GetLinks: TNimbusLogInteractiveRuns;
  public
    constructor Create(const AID: UInt64; const AText: string; const ALevel: TNimbusLogLevel);
    destructor Destroy; override;
    property ID: UInt64 read FID;
    property Text: string read FText;
    property Level: TNimbusLogLevel read GetLevel;
    property Tokens: TNimbusLogTokens read GetTokens;
    property Structured: TNimbusStructuredLogEntry read GetStructured;
    property InteractiveRuns: TNimbusLogInteractiveRuns read GetLinks;
  end;

  TNimbusCustomLogSource = class(TPersistent)
  private
    FOnChange: TNotifyEvent;
  protected
    procedure NotifyChanged;
    function GetCount64: Int64; virtual; abstract;
    function GetLine64(const AIndex: Int64): TNimbusLogLine; virtual; abstract;
    function GetMaxTextLength: Int64; virtual;
  public
    constructor Create(const AOnChange: TNotifyEvent); virtual;
    function TryGetLine(const AIndex: Int64; out ALine: TNimbusLogLine): Boolean; virtual;
    procedure EnsureRange(const AFirstIndex: Int64; const ACount: Integer); virtual;
    property Count64: Int64 read GetCount64;
    property Lines64[const AIndex: Int64]: TNimbusLogLine read GetLine64;
    property MaxTextLength: Int64 read GetMaxTextLength;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TNimbusLogModel = class(TNimbusCustomLogSource)
  private
    FItems: TArray<TNimbusLogLine>;
    FHead, FCount, FMaxLines, FUpdateCount: Integer;
    FNextID, FDropped: UInt64;
    FInsertMode: TNimbusLogInsertMode;
    FChanged: Boolean;
    FLoadedEncoding: TNimbusLogFileEncoding;
    FMaxTextLength: Integer;
    FMaxLengthIDs: TArray<UInt64>;
    FMaxLengthValues: TArray<Integer>;
    FMaxLengthHead, FMaxLengthCount: Integer;
    function GetLine(const AIndex: Integer): TNimbusLogLine;
    procedure SetMaxLines(const AValue: Integer);
    procedure Changed;
    procedure ClearMaxTextLengthIndex;
    procedure EnsureMaxTextLengthCapacity;
    procedure AddMaxTextLength(const AID: UInt64; const ALength: Integer);
    procedure RemoveMaxTextLength(const AID: UInt64);
    procedure RecalculateMaxTextLength;
  protected
    function GetCount64: Int64; override;
    function GetLine64(const AIndex: Int64): TNimbusLogLine; override;
    function GetMaxTextLength: Int64; override;
  public
    constructor Create(const AOnChange: TNotifyEvent); override;
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure Clear;
    function AddLine(const AText: string; const ALevel: TNimbusLogLevel = nllUnknown): UInt64;
    procedure AddText(const AText: string; const ALevel: TNimbusLogLevel = nllUnknown);
    function FindID(const AID: UInt64): TNimbusLogLine;
    procedure AdoptEncoding(const AEncoding: TNimbusLogFileEncoding);
    procedure LoadFile(const APath: string; const AEncoding: TNimbusLogFileEncoding = nlfeAuto);
    procedure SaveFile(const APath: string; const AEncoding: TNimbusLogFileEncoding = nlfeUTF8; const AWriteBOM: Boolean = True);
    property Count: Integer read FCount;
    property Lines[const AIndex: Integer]: TNimbusLogLine read GetLine; default;
    property MaxLines: Integer read FMaxLines write SetMaxLines;
    property InsertMode: TNimbusLogInsertMode read FInsertMode write FInsertMode;
    property DroppedLines: UInt64 read FDropped;
    property LoadedEncoding: TNimbusLogFileEncoding read FLoadedEncoding;
  end;

function NimbusLogEncoding(const AEncoding: TNimbusLogFileEncoding): TEncoding;

implementation

uses Winapi.Windows, System.IOUtils, System.Math, NimbusForms.Controls.LogViewer.Encoding,
  NimbusForms.Controls.LogViewer.Parsers;

function NimbusLogEncoding(const AEncoding: TNimbusLogFileEncoding): TEncoding;
begin
  case AEncoding of
    nlfeUTF16LE: Result := TEncoding.Unicode;
    nlfeUTF16BE: Result := TEncoding.BigEndianUnicode;
    nlfeANSI: Result := TEncoding.Default;
    nlfeASCII: Result := TEncoding.ASCII;
    nlfeUTF32LE, nlfeUTF32BE, nlfeLatin1, nlfeWindows1252:
      raise EArgumentException.Create('Use TNimbusLogTextCodec for ' + TNimbusLogTextCodec.Name(AEncoding));
  else Result := TEncoding.UTF8;
  end;
end;

constructor TNimbusLogLine.Create(const AID: UInt64; const AText: string; const ALevel: TNimbusLogLevel);
begin
  inherited Create;
  FID := AID;
  FText := AText;
  FLevel := ALevel;
  FLevelExplicit := ALevel <> nllUnknown;
  FLevelReady := FLevelExplicit;
end;

destructor TNimbusLogLine.Destroy;
begin
  FLinks.Free;
  FStructured.Free;
  inherited;
end;

procedure TNimbusLogLine.EnsureTokens;
var ParsedLevel: TNimbusLogLevel;
begin
  if FTokensReady then Exit;
  FTokens := TNimbusLogLexer.Parse(FText, ParsedLevel);
  FTokensReady := True;
  if not FLevelExplicit and (ParsedLevel <> nllUnknown) then
  begin
    FLevel := ParsedLevel;
    FLevelReady := True;
  end;
end;

procedure TNimbusLogLine.EnsureStructured;
begin
  if FStructuredReady then Exit;
  FStructuredReady := True;
  if not NimbusParseStandardLogEntry(FText, FStructured) then FStructured := TNimbusStructuredLogEntry.Create;
  FStructured.Sequence := FID;
  if FStructured.OriginalText = '' then FStructured.OriginalText := FText;
  if FStructured.RenderedMessage = '' then FStructured.RenderedMessage := FText;
  if FLevelExplicit then FStructured.Level := FLevel
  else if FStructured.Level <> nllUnknown then begin FLevel := FStructured.Level; FLevelReady := True; end;
end;

procedure TNimbusLogLine.EnsureLinks;
begin
  if FLinksReady then Exit;
  FLinksReady := True;
  FLinks := TNimbusLogInteractiveRunDetector.Detect(FText);
end;

function TNimbusLogLine.GetLevel: TNimbusLogLevel;
begin
  if not FLevelReady then
  begin
    EnsureTokens;
    if not FLevelReady then
    begin
      EnsureStructured;
      if not FLevelReady then begin FLevel := nllUnknown; FLevelReady := True; end;
    end;
  end;
  Result := FLevel;
end;

function TNimbusLogLine.GetTokens: TNimbusLogTokens;
begin
  EnsureTokens;
  Result := FTokens;
end;

function TNimbusLogLine.GetStructured: TNimbusStructuredLogEntry;
begin
  EnsureStructured;
  Result := FStructured;
end;

function TNimbusLogLine.GetLinks: TNimbusLogInteractiveRuns;
begin
  EnsureLinks;
  Result := FLinks;
end;

constructor TNimbusCustomLogSource.Create(const AOnChange: TNotifyEvent);
begin
  inherited Create;
  FOnChange := AOnChange;
end;

procedure TNimbusCustomLogSource.NotifyChanged;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

function TNimbusCustomLogSource.TryGetLine(const AIndex: Int64; out ALine: TNimbusLogLine): Boolean;
begin
  Result := (AIndex >= 0) and (AIndex < Count64);
  if Result then ALine := GetLine64(AIndex) else ALine := nil;
end;

procedure TNimbusCustomLogSource.EnsureRange(const AFirstIndex: Int64; const ACount: Integer);
begin
end;

function TNimbusCustomLogSource.GetMaxTextLength: Int64;
begin
  Result := 0;
end;

constructor TNimbusLogModel.Create(const AOnChange: TNotifyEvent);
begin
  inherited Create(AOnChange);
  FMaxLines := 100000;
  FLoadedEncoding := nlfeUTF8;
  SetLength(FItems, FMaxLines);
end;

destructor TNimbusLogModel.Destroy;
var I: Integer;
begin
  for I := 0 to FCount - 1 do Lines[I].Free;
  inherited;
end;

function TNimbusLogModel.GetCount64: Int64;
begin
  Result := FCount;
end;

function TNimbusLogModel.GetLine64(const AIndex: Int64): TNimbusLogLine;
begin
  if (AIndex < 0) or (AIndex >= FCount) then raise EArgumentOutOfRangeException.Create('Line index');
  Result := GetLine(Integer(AIndex));
end;

function TNimbusLogModel.GetMaxTextLength: Int64;
begin
  Result := FMaxTextLength;
end;

function TNimbusLogModel.GetLine(const AIndex: Integer): TNimbusLogLine;
begin
  if (AIndex < 0) or (AIndex >= FCount) then raise EArgumentOutOfRangeException.Create('Line index');
  Result := FItems[(FHead + AIndex) mod Length(FItems)];
end;

procedure TNimbusLogModel.Changed;
begin
  FChanged := True;
  if FUpdateCount > 0 then Exit;
  FChanged := False;
  NotifyChanged;
end;

procedure TNimbusLogModel.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TNimbusLogModel.EndUpdate;
begin
  if FUpdateCount = 0 then raise EInvalidOpException.Create('Unbalanced log update');
  Dec(FUpdateCount);
  if (FUpdateCount = 0) and FChanged then Changed;
end;

procedure TNimbusLogModel.ClearMaxTextLengthIndex;
begin
  FMaxLengthHead := 0;
  FMaxLengthCount := 0;
  FMaxTextLength := 0;
end;

procedure TNimbusLogModel.EnsureMaxTextLengthCapacity;
var NewCapacity: Integer;
begin
  if FMaxLengthHead + FMaxLengthCount < Length(FMaxLengthIDs) then Exit;
  if (FMaxLengthHead > 0) and (FMaxLengthCount > 0) then
  begin
    Move(FMaxLengthIDs[FMaxLengthHead], FMaxLengthIDs[0], FMaxLengthCount * SizeOf(UInt64));
    Move(FMaxLengthValues[FMaxLengthHead], FMaxLengthValues[0], FMaxLengthCount * SizeOf(Integer));
    FMaxLengthHead := 0;
    if FMaxLengthCount < Length(FMaxLengthIDs) then Exit;
  end
  else if FMaxLengthCount = 0 then FMaxLengthHead := 0;
  NewCapacity := Length(FMaxLengthIDs) * 2;
  if NewCapacity < 64 then NewCapacity := 64;
  SetLength(FMaxLengthIDs, NewCapacity);
  SetLength(FMaxLengthValues, NewCapacity);
end;

procedure TNimbusLogModel.AddMaxTextLength(const AID: UInt64; const ALength: Integer);
var Index: Integer;
begin
  while (FMaxLengthCount > 0) and
    (FMaxLengthValues[FMaxLengthHead + FMaxLengthCount - 1] <= ALength) do Dec(FMaxLengthCount);
  if FMaxLengthCount = 0 then FMaxLengthHead := 0;
  EnsureMaxTextLengthCapacity;
  Index := FMaxLengthHead + FMaxLengthCount;
  FMaxLengthIDs[Index] := AID;
  FMaxLengthValues[Index] := ALength;
  Inc(FMaxLengthCount);
  FMaxTextLength := FMaxLengthValues[FMaxLengthHead];
end;

procedure TNimbusLogModel.RemoveMaxTextLength(const AID: UInt64);
begin
  if (FMaxLengthCount > 0) and (FMaxLengthIDs[FMaxLengthHead] = AID) then
  begin
    Inc(FMaxLengthHead);
    Dec(FMaxLengthCount);
  end;
  if FMaxLengthCount = 0 then
  begin
    FMaxLengthHead := 0;
    FMaxTextLength := 0;
  end
  else FMaxTextLength := FMaxLengthValues[FMaxLengthHead];
end;

procedure TNimbusLogModel.RecalculateMaxTextLength;
var I: Integer;
begin
  ClearMaxTextLengthIndex;
  if FInsertMode = nlimBottom then
    for I := 0 to FCount - 1 do AddMaxTextLength(Lines[I].ID, Length(Lines[I].Text))
  else
    for I := FCount - 1 downto 0 do AddMaxTextLength(Lines[I].ID, Length(Lines[I].Text));
end;

procedure TNimbusLogModel.Clear;
var I: Integer;
begin
  for I := 0 to FCount - 1 do
  begin
    Lines[I].Free;
    FItems[(FHead + I) mod Length(FItems)] := nil;
  end;
  FCount := 0;
  FHead := 0;
  FDropped := 0;
  ClearMaxTextLengthIndex;
  Changed;
end;

procedure TNimbusLogModel.SetMaxLines(const AValue: Integer);
var Items: TArray<TNimbusLogLine>; I, First, Keep: Integer;
begin
  if AValue < 1 then raise EArgumentOutOfRangeException.Create('MaxLines');
  if AValue = FMaxLines then Exit;
  SetLength(Items, AValue);
  Keep := FCount;
  if Keep > AValue then Keep := AValue;
  First := 0;
  if FInsertMode = nlimBottom then First := FCount - Keep;
  for I := 0 to FCount - 1 do
    if (I >= First) and (I < First + Keep) then Items[I - First] := Lines[I]
    else begin Lines[I].Free; Inc(FDropped); end;
  FItems := Items;
  FHead := 0;
  FCount := Keep;
  FMaxLines := AValue;
  RecalculateMaxTextLength;
  Changed;
end;

function TNimbusLogModel.AddLine(const AText: string; const ALevel: TNimbusLogLevel): UInt64;
var L, DroppedLine: TNimbusLogLine; Index: Integer;
begin
  if (Pos(#10, AText) > 0) or (Pos(#13, AText) > 0) then raise EArgumentException.Create('AddLine requires one line; use AddText for multiline records');
  if FNextID = High(UInt64) then raise ERangeError.Create('Log line ID overflow');
  L := TNimbusLogLine.Create(FNextID + 1, AText, ALevel);
  Inc(FNextID);
  Result := FNextID;
  if FCount = Length(FItems) then
  begin
    if FInsertMode = nlimBottom then
    begin
      DroppedLine := FItems[FHead];
      RemoveMaxTextLength(DroppedLine.ID);
      DroppedLine.Free;
      FItems[FHead] := nil;
      FHead := (FHead + 1) mod Length(FItems);
    end
    else
    begin
      Index := (FHead + FCount - 1) mod Length(FItems);
      DroppedLine := FItems[Index];
      RemoveMaxTextLength(DroppedLine.ID);
      DroppedLine.Free;
      FItems[Index] := nil;
    end;
    Dec(FCount);
    Inc(FDropped);
  end;
  if FInsertMode = nlimTop then
  begin
    FHead := (FHead + Length(FItems) - 1) mod Length(FItems);
    Index := FHead;
  end
  else Index := (FHead + FCount) mod Length(FItems);
  FItems[Index] := L;
  Inc(FCount);
  AddMaxTextLength(L.ID, Length(AText));
  Changed;
end;

procedure TNimbusLogModel.AddText(const AText: string; const ALevel: TNimbusLogLevel);
var S: string; Parts: TArray<string>; I, Last: Integer;
begin
  S := AText.Replace(#13#10, #10).Replace(#13, #10);
  Parts := S.Split([#10]);
  Last := High(Parts);
  if (Last > 0) and (Parts[Last] = '') then Dec(Last);
  BeginUpdate;
  try
    for I := 0 to Last do AddLine(Parts[I], ALevel);
  finally EndUpdate; end;
end;

function TNimbusLogModel.FindID(const AID: UInt64): TNimbusLogLine;
var I: Integer;
begin
  Result := nil;
  for I := 0 to FCount - 1 do if Lines[I].ID = AID then Exit(Lines[I]);
end;

procedure TNimbusLogModel.AdoptEncoding(const AEncoding: TNimbusLogFileEncoding);
begin
  if AEncoding <> nlfeAuto then FLoadedEncoding := AEncoding;
end;

procedure TNimbusLogModel.LoadFile(const APath: string; const AEncoding: TNimbusLogFileEncoding);
var Temporary: TNimbusLogModel; I, Index, ReadCount, BOMSize: Integer; Items: TArray<TNimbusLogLine>;
  Stream: TFileStream; Decoder: TNimbusLogLineDecoder; Buffer, Sample: TBytes; FileLines: TArray<string>;
  Line: string; Encoding: TNimbusLogFileEncoding;
begin
  Temporary := TNimbusLogModel.Create(nil);
  try
    Temporary.MaxLines := FMaxLines;
    Stream := TFileStream.Create(APath, fmOpenRead or fmShareDenyNone);
    try
      SetLength(Buffer, 4096);
      ReadCount := Stream.Read(Buffer[0], Length(Buffer));
      Sample := Copy(Buffer, 0, ReadCount);
      Encoding := TNimbusLogTextCodec.Detect(Sample, AEncoding, BOMSize);
      Stream.Position := BOMSize;
      Decoder := TNimbusLogLineDecoder.Create(Encoding);
      try
        SetLength(Buffer, 65536);
        repeat
          ReadCount := Stream.Read(Buffer[0], Length(Buffer));
          FileLines := Decoder.Feed(Buffer, ReadCount, ReadCount = 0);
          for Line in FileLines do Temporary.AddLine(Line);
        until ReadCount = 0;
      finally Decoder.Free; end;
    finally Stream.Free; end;
    SetLength(Items, FMaxLines);
    if UInt64(Temporary.Count) > High(UInt64) - FNextID then raise ERangeError.Create('Log line ID overflow');
    BeginUpdate;
    try
      Clear;
      for I := 0 to Temporary.Count - 1 do
      begin
        Index := (Temporary.FHead + I) mod Length(Temporary.FItems);
        Items[I] := Temporary.FItems[Index];
        Items[I].FID := FNextID + UInt64(I) + 1;
        Temporary.FItems[Index] := nil;
      end;
      FItems := Items;
      FHead := 0;
      FCount := Temporary.Count;
      RecalculateMaxTextLength;
      FLoadedEncoding := Encoding;
      Temporary.FCount := 0;
      Inc(FNextID, UInt64(FCount));
      FDropped := Temporary.DroppedLines;
      Changed;
    finally EndUpdate; end;
  finally Temporary.Free; end;
end;

procedure TNimbusLogModel.SaveFile(const APath: string; const AEncoding: TNimbusLogFileEncoding; const AWriteBOM: Boolean);
var Stream: TFileStream; I: Integer; TemporaryPath: string; G: TGUID; Bytes: TBytes; Encoding: TNimbusLogFileEncoding;
begin
  Encoding := AEncoding;
  if Encoding = nlfeAuto then Encoding := FLoadedEncoding;
  CreateGUID(G);
  TemporaryPath := APath + '.' + GUIDToString(G) + '.tmp';
  try
    Stream := TFileStream.Create(TemporaryPath, fmCreate);
    try
      if AWriteBOM then
      begin Bytes := TNimbusLogTextCodec.Preamble(Encoding); if Length(Bytes) > 0 then Stream.WriteBuffer(Bytes[0], Length(Bytes)); end;
      for I := 0 to FCount - 1 do
      begin
        Bytes := TNimbusLogTextCodec.Encode(Lines[I].Text + sLineBreak, Encoding);
        if Length(Bytes) > 0 then Stream.WriteBuffer(Bytes[0], Length(Bytes));
      end;
    finally Stream.Free; end;
    if TFile.Exists(APath) then
    begin
      if not ReplaceFile(PChar(APath), PChar(TemporaryPath), nil, REPLACEFILE_IGNORE_MERGE_ERRORS, nil, nil) then RaiseLastOSError;
    end
    else if not MoveFileEx(PChar(TemporaryPath), PChar(APath), MOVEFILE_WRITE_THROUGH) then RaiseLastOSError;
    FLoadedEncoding := Encoding;
  finally
    if TFile.Exists(TemporaryPath) then TFile.Delete(TemporaryPath);
  end;
end;

end.

unit NimbusForms.Controls.LogViewer.IndexedFile;

interface

uses System.SysUtils, System.Classes, System.SyncObjs, System.Generics.Collections,
  NimbusForms.Controls.LogViewer.Types, NimbusForms.Controls.LogViewer.Model;

type
  TNimbusLogFileSpan = packed record
    Offset: Int64;
    Length: Integer;
  end;

  TNimbusIndexedSearchHit = record
    SourceIndex: Int64;
    Column: Integer;
    Length: Integer;
    TextMatch: Boolean;
  end;
  TNimbusIndexedSearchHits = TArray<TNimbusIndexedSearchHit>;

  TNimbusLogFileOffsetIndex = class
  private type
    TSegment = class
      BaseOffset: Int64;
      RelativeOffsets: TArray<Cardinal>;
      WideOffsets: TArray<Int64>;
      Lengths: TArray<Cardinal>;
      ItemCount: Integer;
      constructor Create(const ASize: Integer);
      procedure Add(const AIndex: Integer; const AOffset: Int64; const ALength: Cardinal);
      function SpanAt(const AIndex: Integer): TNimbusLogFileSpan;
    end;
  private
    FLock: TCriticalSection;
    FSegments: TObjectList<TSegment>;
    FSegmentSize: Integer;
    FCount: Int64;
    function GetCount: Int64;
  public
    constructor Create(const ASegmentSize: Integer = 65536);
    destructor Destroy; override;
    procedure Clear;
    procedure Add(const AOffset, ALength: Int64);
    function TryGet(const AIndex: Int64; out ASpan: TNimbusLogFileSpan): Boolean;
    function CopyRange(const AFirstIndex: Int64; const ACount: Integer; var ATarget: TArray<TNimbusLogFileSpan>): Integer;
    property Count: Int64 read GetCount;
  end;

  TNimbusIndexedLogFile = class;

  TNimbusIndexedLogFileOptions = class(TPersistent)
  private
    FPageSize: Integer;
    FMaxCachedPages: Integer;
    FReadBufferSize: Integer;
    FIndexBatchSize: Integer;
    FIndexSegmentSize: Integer;
    FMaxSearchMatches: Integer;
    FPersistIndex: Boolean;
    FIndexCacheDirectory: string;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property PageSize: Integer read FPageSize write FPageSize default 256;
    property MaxCachedPages: Integer read FMaxCachedPages write FMaxCachedPages default 24;
    property ReadBufferSize: Integer read FReadBufferSize write FReadBufferSize default 131072;
    property IndexBatchSize: Integer read FIndexBatchSize write FIndexBatchSize default 4096;
    property IndexSegmentSize: Integer read FIndexSegmentSize write FIndexSegmentSize default 65536;
    property MaxSearchMatches: Integer read FMaxSearchMatches write FMaxSearchMatches default 100000;
    property PersistIndex: Boolean read FPersistIndex write FPersistIndex default True;
    property IndexCacheDirectory: string read FIndexCacheDirectory write FIndexCacheDirectory;
  end;

  TNimbusIndexedLogFile = class(TNimbusCustomLogSource)
  private type
    TPage = class
      FirstRow: Int64;
      Lines: TObjectList<TNimbusLogLine>;
      constructor Create;
      destructor Destroy; override;
    end;
    TIndexThread = class(TThread)
    private
      FOwner: TNimbusIndexedLogFile;
      FGeneration: Integer;
    protected
      procedure Execute; override;
    public
      constructor Create(AOwner: TNimbusIndexedLogFile; const AGeneration: Integer);
      function IsTerminated: Boolean;
    end;
    TSearchThread = class(TThread)
    private
      FOwner: TNimbusIndexedLogFile;
      FGeneration: Integer;
      FRequestID: Integer;
      FText: string;
      FStructuredQuery: string;
      FCaseSensitive: Boolean;
      FRegex: Boolean;
      FLevels: TNimbusLogLevels;
      FIncludeNonTextRows: Boolean;
    protected
      procedure Execute; override;
    public
      constructor Create(AOwner: TNimbusIndexedLogFile; const AGeneration, ARequestID: Integer;
        const AText, AStructuredQuery: string; const ACaseSensitive, ARegex, AIncludeNonTextRows: Boolean;
        const ALevels: TNimbusLogLevels);
      function IsTerminated: Boolean;
    end;
  private
    FLock: TCriticalSection;
    FCacheLock: TCriticalSection;
    FIndex: TNimbusLogFileOffsetIndex;
    FPages: TObjectDictionary<Int64, TPage>;
    FLru: TList<Int64>;
    FOptions: TNimbusIndexedLogFileOptions;
    FIndexThread: TIndexThread;
    FSearchThread: TSearchThread;
    FFileName: string;
    FEncoding: TNimbusLogFileEncoding;
    FRequestedEncoding: TNimbusLogFileEncoding;
    FFileLength: Int64;
    FIndexedBytes: Int64;
    FMaxTextLength: Int64;
    FIndexing: Boolean;
    FIndexComplete: Boolean;
    FGeneration: Integer;
    FVersion: Int64;
    FLastError: string;
    FSearchResults: TNimbusIndexedSearchHits;
    FSearchVersion: Int64;
    FSearching: Boolean;
    FSearchTruncated: Boolean;
    FSearchError: string;
    FSearchRequestID: Integer;
    function LoadPage(const APageIndex: Int64): TPage;
    function GetCachedPage(const APageIndex: Int64): TPage;
    procedure TouchPage(const APageIndex: Int64);
    procedure TrimPages;
    procedure ClearPages;
    procedure DropPage(const APageIndex: Int64);
    procedure StopIndexThread;
    procedure StopSearchThread;
    procedure BuildIndex(const AGeneration: Integer; AThread: TIndexThread);
    procedure RunSearch(const AGeneration, ARequestID: Integer; const AText, AStructuredQuery: string;
      const ACaseSensitive, ARegex, AIncludeNonTextRows: Boolean; const ALevels: TNimbusLogLevels; AThread: TSearchThread);
    function ReadSpanText(AStream: TFileStream; const ASpan: TNimbusLogFileSpan): string;
    function IndexCachePath: string;
    function LoadPersistentIndex(const AContentStart: Int64; const AEncoding: TNimbusLogFileEncoding): Boolean;
    procedure SavePersistentIndex(const AContentStart: Int64; const AEncoding: TNimbusLogFileEncoding);
    function SourceWriteTime: TDateTime;
    function SourcePathHash: UInt64;
    function GetEncoding: TNimbusLogFileEncoding;
    function GetFileLength: Int64;
    function GetIndexedBytes: Int64;
    function GetIndexing: Boolean;
    function GetIndexComplete: Boolean;
    function GetVersion: Int64;
    function GetLastError: string;
    function GetSearching: Boolean;
    function GetSearchVersion: Int64;
    function GetSearchTruncated: Boolean;
    function GetSearchError: string;
  protected
    function GetCount64: Int64; override;
    function GetLine64(const AIndex: Int64): TNimbusLogLine; override;
    function GetMaxTextLength: Int64; override;
  public
    constructor Create(const AOnChange: TNotifyEvent); override;
    destructor Destroy; override;
    procedure Open(const AFileName: string; const AEncoding: TNimbusLogFileEncoding = nlfeAuto);
    procedure Close;
    procedure Refresh;
    procedure EnsureRange(const AFirstIndex: Int64; const ACount: Integer); override;
    procedure BeginSearch(const AText, AStructuredQuery: string; const ACaseSensitive, ARegex: Boolean;
      const ALevels: TNimbusLogLevels; const AIncludeNonTextRows: Boolean = False);
    procedure CancelSearch;
    function SearchResults: TNimbusIndexedSearchHits;
    procedure SaveToFile(const APath: string; const AEncoding: TNimbusLogFileEncoding; const AWriteBOM: Boolean);
    property Options: TNimbusIndexedLogFileOptions read FOptions;
    property FileName: string read FFileName;
    property Encoding: TNimbusLogFileEncoding read GetEncoding;
    property FileLength: Int64 read GetFileLength;
    property IndexedBytes: Int64 read GetIndexedBytes;
    property Indexing: Boolean read GetIndexing;
    property IndexComplete: Boolean read GetIndexComplete;
    property Version: Int64 read GetVersion;
    property LastError: string read GetLastError;
    property Searching: Boolean read GetSearching;
    property SearchVersion: Int64 read GetSearchVersion;
    property SearchTruncated: Boolean read GetSearchTruncated;
    property SearchError: string read GetSearchError;
  end;

implementation

uses System.IOUtils, System.Math, System.RegularExpressions, System.DateUtils, System.StrUtils,
  NimbusForms.Controls.LogViewer.Encoding, NimbusForms.Controls.LogViewer.Query,
  NimbusForms.Controls.LogViewer.Structured;

const
  NimbusIndexMagic: UInt64 = $314458494C424D4E;
  NimbusIndexVersion: Cardinal = 2;

constructor TNimbusLogFileOffsetIndex.TSegment.Create(const ASize: Integer);
begin
  inherited Create;
  SetLength(RelativeOffsets, ASize);
  SetLength(Lengths, ASize);
end;

procedure TNimbusLogFileOffsetIndex.TSegment.Add(const AIndex: Integer; const AOffset: Int64;
  const ALength: Cardinal);
var I: Integer; Delta: UInt64;
begin
  if AIndex = 0 then BaseOffset := AOffset;
  if Length(WideOffsets) = 0 then
  begin
    if AOffset < BaseOffset then Delta := UInt64(High(Cardinal)) + 1
    else Delta := UInt64(AOffset - BaseOffset);
    if Delta <= High(Cardinal) then RelativeOffsets[AIndex] := Cardinal(Delta)
    else
    begin
      SetLength(WideOffsets, Length(RelativeOffsets));
      for I := 0 to ItemCount - 1 do WideOffsets[I] := BaseOffset + RelativeOffsets[I];
      WideOffsets[AIndex] := AOffset;
    end;
  end
  else WideOffsets[AIndex] := AOffset;
  Lengths[AIndex] := ALength;
  if AIndex >= ItemCount then ItemCount := AIndex + 1;
end;

function TNimbusLogFileOffsetIndex.TSegment.SpanAt(const AIndex: Integer): TNimbusLogFileSpan;
begin
  if Length(WideOffsets) > 0 then Result.Offset := WideOffsets[AIndex]
  else Result.Offset := BaseOffset + RelativeOffsets[AIndex];
  Result.Length := Integer(Lengths[AIndex]);
end;

constructor TNimbusLogFileOffsetIndex.Create(const ASegmentSize: Integer);
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FSegments := TObjectList<TSegment>.Create(True);
  FSegmentSize := Max(1024, ASegmentSize);
end;

destructor TNimbusLogFileOffsetIndex.Destroy;
begin
  FSegments.Free;
  FLock.Free;
  inherited;
end;

function TNimbusLogFileOffsetIndex.GetCount: Int64;
begin
  FLock.Acquire;
  try Result := FCount; finally FLock.Release; end;
end;

procedure TNimbusLogFileOffsetIndex.Clear;
begin
  FLock.Acquire;
  try FSegments.Clear; FCount := 0; finally FLock.Release; end;
end;

procedure TNimbusLogFileOffsetIndex.Add(const AOffset, ALength: Int64);
var SegmentIndex, ItemIndex: Integer; Segment: TSegment;
begin
  if (AOffset < 0) or (ALength < 0) then Exit;
  if ALength > High(Integer) then raise ERangeError.Create('A single log record exceeds 2 GB');
  FLock.Acquire;
  try
    if FCount div FSegmentSize > High(Integer) then raise ERangeError.Create('Log index segment limit exceeded');
    SegmentIndex := Integer(FCount div FSegmentSize);
    ItemIndex := Integer(FCount mod FSegmentSize);
    while FSegments.Count <= SegmentIndex do FSegments.Add(TSegment.Create(FSegmentSize));
    Segment := FSegments[SegmentIndex];
    Segment.Add(ItemIndex, AOffset, Cardinal(ALength));
    Inc(FCount);
  finally FLock.Release; end;
end;

function TNimbusLogFileOffsetIndex.TryGet(const AIndex: Int64; out ASpan: TNimbusLogFileSpan): Boolean;
var SegmentIndex, ItemIndex: Integer;
begin
  FLock.Acquire;
  try
    Result := (AIndex >= 0) and (AIndex < FCount);
    if not Result then begin ASpan := Default(TNimbusLogFileSpan); Exit; end;
    SegmentIndex := Integer(AIndex div FSegmentSize);
    ItemIndex := Integer(AIndex mod FSegmentSize);
    ASpan := FSegments[SegmentIndex].SpanAt(ItemIndex);
  finally FLock.Release; end;
end;

function TNimbusLogFileOffsetIndex.CopyRange(const AFirstIndex: Int64; const ACount: Integer;
  var ATarget: TArray<TNimbusLogFileSpan>): Integer;
var I, Requested, SegmentIndex, ItemIndex: Integer; Index: Int64;
begin
  Requested := Max(0, ACount);
  if Length(ATarget) < Requested then SetLength(ATarget, Requested);
  Result := 0;
  FLock.Acquire;
  try
    for I := 0 to Requested - 1 do
    begin
      Index := AFirstIndex + I;
      if (Index < 0) or (Index >= FCount) then Break;
      SegmentIndex := Integer(Index div FSegmentSize);
      ItemIndex := Integer(Index mod FSegmentSize);
      ATarget[I] := FSegments[SegmentIndex].SpanAt(ItemIndex);
      Inc(Result);
    end;
  finally FLock.Release; end;
end;

constructor TNimbusIndexedLogFileOptions.Create;
begin
  inherited Create;
  FPageSize := 256;
  FMaxCachedPages := 24;
  FReadBufferSize := 131072;
  FIndexBatchSize := 4096;
  FIndexSegmentSize := 65536;
  FMaxSearchMatches := 100000;
  FPersistIndex := True;
  FIndexCacheDirectory := TPath.Combine(TPath.GetTempPath, 'NimbusForms.LogViewer');
end;

procedure TNimbusIndexedLogFileOptions.Assign(Source: TPersistent);
var O: TNimbusIndexedLogFileOptions;
begin
  if not (Source is TNimbusIndexedLogFileOptions) then begin inherited; Exit; end;
  O := TNimbusIndexedLogFileOptions(Source);
  FPageSize := O.FPageSize;
  FMaxCachedPages := O.FMaxCachedPages;
  FReadBufferSize := O.FReadBufferSize;
  FIndexBatchSize := O.FIndexBatchSize;
  FIndexSegmentSize := O.FIndexSegmentSize;
  FMaxSearchMatches := O.FMaxSearchMatches;
  FPersistIndex := O.FPersistIndex;
  FIndexCacheDirectory := O.FIndexCacheDirectory;
end;

constructor TNimbusIndexedLogFile.TPage.Create;
begin
  inherited Create;
  Lines := TObjectList<TNimbusLogLine>.Create(True);
end;

destructor TNimbusIndexedLogFile.TPage.Destroy;
begin
  Lines.Free;
  inherited;
end;

constructor TNimbusIndexedLogFile.TIndexThread.Create(AOwner: TNimbusIndexedLogFile; const AGeneration: Integer);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  FOwner := AOwner;
  FGeneration := AGeneration;
end;

procedure TNimbusIndexedLogFile.TIndexThread.Execute;
begin
  FOwner.BuildIndex(FGeneration, Self);
end;

function TNimbusIndexedLogFile.TIndexThread.IsTerminated: Boolean;
begin
  Result := Terminated;
end;

constructor TNimbusIndexedLogFile.TSearchThread.Create(AOwner: TNimbusIndexedLogFile; const AGeneration,
  ARequestID: Integer; const AText, AStructuredQuery: string; const ACaseSensitive, ARegex,
  AIncludeNonTextRows: Boolean; const ALevels: TNimbusLogLevels);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  FOwner := AOwner;
  FGeneration := AGeneration;
  FRequestID := ARequestID;
  FText := AText;
  FStructuredQuery := AStructuredQuery;
  FCaseSensitive := ACaseSensitive;
  FRegex := ARegex;
  FIncludeNonTextRows := AIncludeNonTextRows;
  FLevels := ALevels;
end;

procedure TNimbusIndexedLogFile.TSearchThread.Execute;
begin
  FOwner.RunSearch(FGeneration, FRequestID, FText, FStructuredQuery, FCaseSensitive, FRegex, FIncludeNonTextRows, FLevels, Self);
end;

function TNimbusIndexedLogFile.TSearchThread.IsTerminated: Boolean;
begin
  Result := Terminated;
end;

constructor TNimbusIndexedLogFile.Create(const AOnChange: TNotifyEvent);
begin
  inherited Create(AOnChange);
  FLock := TCriticalSection.Create;
  FCacheLock := TCriticalSection.Create;
  FOptions := TNimbusIndexedLogFileOptions.Create;
  FIndex := TNimbusLogFileOffsetIndex.Create(FOptions.IndexSegmentSize);
  FPages := TObjectDictionary<Int64, TPage>.Create([doOwnsValues]);
  FLru := TList<Int64>.Create;
  FEncoding := nlfeUTF8;
  FRequestedEncoding := nlfeAuto;
end;

destructor TNimbusIndexedLogFile.Destroy;
begin
  StopSearchThread;
  StopIndexThread;
  FLru.Free;
  FPages.Free;
  FIndex.Free;
  FOptions.Free;
  FCacheLock.Free;
  FLock.Free;
  inherited;
end;

procedure TNimbusIndexedLogFile.StopIndexThread;
var Thread: TIndexThread;
begin
  Thread := FIndexThread;
  FIndexThread := nil;
  if Thread = nil then Exit;
  Thread.Terminate;
  Thread.WaitFor;
  Thread.Free;
end;

procedure TNimbusIndexedLogFile.StopSearchThread;
var Thread: TSearchThread;
begin
  Thread := FSearchThread;
  FSearchThread := nil;
  if Thread = nil then Exit;
  Thread.Terminate;
  Thread.WaitFor;
  Thread.Free;
end;

procedure TNimbusIndexedLogFile.ClearPages;
begin
  FCacheLock.Acquire;
  try FPages.Clear; FLru.Clear; finally FCacheLock.Release; end;
end;

procedure TNimbusIndexedLogFile.DropPage(const APageIndex: Int64);
begin
  FCacheLock.Acquire;
  try
    FPages.Remove(APageIndex);
    FLru.Remove(APageIndex);
  finally FCacheLock.Release; end;
end;

procedure TNimbusIndexedLogFile.Close;
begin
  StopSearchThread;
  StopIndexThread;
  FLock.Acquire;
  try
    Inc(FGeneration);
    FFileName := '';
    FFileLength := 0;
    FIndexedBytes := 0;
    FMaxTextLength := 0;
    FIndexing := False;
    FIndexComplete := False;
    FLastError := '';
    FSearching := False;
    FSearchError := '';
    FSearchResults := nil;
    Inc(FVersion);
    Inc(FSearchVersion);
  finally FLock.Release; end;
  FIndex.Clear;
  ClearPages;
  NotifyChanged;
end;

procedure TNimbusIndexedLogFile.Open(const AFileName: string; const AEncoding: TNimbusLogFileEncoding);
begin
  if AFileName = '' then raise EArgumentException.Create('FileName');
  StopSearchThread;
  StopIndexThread;
  FIndex.Free;
  FIndex := TNimbusLogFileOffsetIndex.Create(Max(1024, FOptions.IndexSegmentSize));
  ClearPages;
  FLock.Acquire;
  try
    Inc(FGeneration);
    FFileName := TPath.GetFullPath(AFileName);
    FRequestedEncoding := AEncoding;
    FFileLength := 0;
    FIndexedBytes := 0;
    FMaxTextLength := 0;
    FIndexing := True;
    FIndexComplete := False;
    FLastError := '';
    FSearchResults := nil;
    FSearchError := '';
    Inc(FVersion);
    Inc(FSearchVersion);
    FIndexThread := TIndexThread.Create(Self, FGeneration);
    FIndexThread.Start;
  finally FLock.Release; end;
  NotifyChanged;
end;

procedure TNimbusIndexedLogFile.Refresh;
begin
  if FFileName <> '' then Open(FFileName, FRequestedEncoding);
end;

function TNimbusIndexedLogFile.GetCount64: Int64;
begin
  Result := FIndex.Count;
end;

function TNimbusIndexedLogFile.GetMaxTextLength: Int64;
begin
  FLock.Acquire;
  try Result := FMaxTextLength; finally FLock.Release; end;
end;

procedure TNimbusIndexedLogFile.TouchPage(const APageIndex: Int64);
var P: Integer;
begin
  P := FLru.IndexOf(APageIndex);
  if P >= 0 then FLru.Delete(P);
  FLru.Insert(0, APageIndex);
end;

procedure TNimbusIndexedLogFile.TrimPages;
var Key: Int64;
begin
  while FLru.Count > Max(2, FOptions.MaxCachedPages) do
  begin
    Key := FLru[FLru.Count - 1];
    FLru.Delete(FLru.Count - 1);
    FPages.Remove(Key);
  end;
end;

function TNimbusIndexedLogFile.GetCachedPage(const APageIndex: Int64): TPage;
begin
  Result := nil;
  FCacheLock.Acquire;
  try
    if FPages.TryGetValue(APageIndex, Result) then TouchPage(APageIndex);
  finally FCacheLock.Release; end;
end;

function TNimbusIndexedLogFile.ReadSpanText(AStream: TFileStream; const ASpan: TNimbusLogFileSpan): string;
var Bytes: TBytes;
begin
  if ASpan.Length <= 0 then Exit('');
  SetLength(Bytes, ASpan.Length);
  AStream.Position := ASpan.Offset;
  AStream.ReadBuffer(Bytes[0], Length(Bytes));
  Result := TNimbusLogTextCodec.Decode(Bytes, FEncoding);
end;

function TNimbusIndexedLogFile.LoadPage(const APageIndex: Int64): TPage;
var Page: TPage; Stream: TFileStream; Spans: TArray<TNimbusLogFileSpan>; Count, I: Integer;
  FirstRow: Int64; Text: string;
begin
  Result := GetCachedPage(APageIndex);
  if Result <> nil then Exit;
  Page := TPage.Create;
  try
    FirstRow := APageIndex * Max(16, FOptions.PageSize);
    Page.FirstRow := FirstRow;
    Count := FIndex.CopyRange(FirstRow, Max(16, FOptions.PageSize), Spans);
    if Count = 0 then Exit(nil);
    Stream := TFileStream.Create(FFileName, fmOpenRead or fmShareDenyNone);
    try
      for I := 0 to Count - 1 do
      begin
        Text := ReadSpanText(Stream, Spans[I]);
        Page.Lines.Add(TNimbusLogLine.Create(UInt64(FirstRow + I + 1), Text, nllUnknown));
      end;
    finally Stream.Free; end;
    FCacheLock.Acquire;
    try
      Result := nil;
      if FPages.TryGetValue(APageIndex, Result) then
      begin
        TouchPage(APageIndex);
        Exit;
      end;
      FPages.Add(APageIndex, Page);
      TouchPage(APageIndex);
      TrimPages;
      Result := Page;
      Page := nil;
    finally FCacheLock.Release; end;
  finally Page.Free; end;
end;

function TNimbusIndexedLogFile.GetLine64(const AIndex: Int64): TNimbusLogLine;
var PageIndex: Int64; ItemIndex: Integer; Page: TPage;
begin
  if (AIndex < 0) or (AIndex >= Count64) then raise EArgumentOutOfRangeException.Create('Line index');
  PageIndex := AIndex div Max(16, FOptions.PageSize);
  ItemIndex := Integer(AIndex mod Max(16, FOptions.PageSize));
  Page := LoadPage(PageIndex);
  if (Page <> nil) and (ItemIndex >= Page.Lines.Count) and (AIndex < Count64) then
  begin
    DropPage(PageIndex);
    Page := LoadPage(PageIndex);
  end;
  if (Page = nil) or (ItemIndex >= Page.Lines.Count) then raise EInvalidOpException.Create('Indexed log page is unavailable');
  Result := Page.Lines[ItemIndex];
end;

procedure TNimbusIndexedLogFile.EnsureRange(const AFirstIndex: Int64; const ACount: Integer);
var FirstPage, LastPage, P: Int64; PageSize: Integer;
begin
  if (ACount <= 0) or (AFirstIndex < 0) then Exit;
  PageSize := Max(16, FOptions.PageSize);
  FirstPage := AFirstIndex div PageSize;
  LastPage := (AFirstIndex + ACount - 1) div PageSize;
  if FirstPage > 0 then LoadPage(FirstPage - 1);
  for P := FirstPage to LastPage do LoadPage(P);
  if (LastPage + 1) * PageSize < Count64 then LoadPage(LastPage + 1);
end;

function TNimbusIndexedLogFile.GetEncoding: TNimbusLogFileEncoding;
begin
  FLock.Acquire;
  try Result := FEncoding; finally FLock.Release; end;
end;

function TNimbusIndexedLogFile.GetFileLength: Int64;
begin
  FLock.Acquire;
  try Result := FFileLength; finally FLock.Release; end;
end;

function TNimbusIndexedLogFile.GetIndexedBytes: Int64;
begin
  FLock.Acquire;
  try Result := FIndexedBytes; finally FLock.Release; end;
end;

function TNimbusIndexedLogFile.GetIndexing: Boolean;
begin
  FLock.Acquire;
  try Result := FIndexing; finally FLock.Release; end;
end;

function TNimbusIndexedLogFile.GetIndexComplete: Boolean;
begin
  FLock.Acquire;
  try Result := FIndexComplete; finally FLock.Release; end;
end;

function TNimbusIndexedLogFile.GetVersion: Int64;
begin
  FLock.Acquire;
  try Result := FVersion; finally FLock.Release; end;
end;

function TNimbusIndexedLogFile.GetLastError: string;
begin
  FLock.Acquire;
  try Result := FLastError; finally FLock.Release; end;
end;

function TNimbusIndexedLogFile.GetSearching: Boolean;
begin
  FLock.Acquire;
  try Result := FSearching; finally FLock.Release; end;
end;

function TNimbusIndexedLogFile.GetSearchVersion: Int64;
begin
  FLock.Acquire;
  try Result := FSearchVersion; finally FLock.Release; end;
end;

function TNimbusIndexedLogFile.GetSearchTruncated: Boolean;
begin
  FLock.Acquire;
  try Result := FSearchTruncated; finally FLock.Release; end;
end;

function TNimbusIndexedLogFile.GetSearchError: string;
begin
  FLock.Acquire;
  try Result := FSearchError; finally FLock.Release; end;
end;

function TNimbusIndexedLogFile.SourceWriteTime: TDateTime;
begin
  Result := TFile.GetLastWriteTimeUtc(FFileName);
end;

function TNimbusIndexedLogFile.SourcePathHash: UInt64;
var C: Char;
begin
  Result := UInt64($CBF29CE484222325);
  for C in LowerCase(FFileName) do
  begin Result := Result xor Ord(C); Result := Result * UInt64($100000001B3); end;
end;

function TNimbusIndexedLogFile.IndexCachePath: string;
var Dir: string;
begin
  Dir := FOptions.IndexCacheDirectory;
  if Dir = '' then Dir := TPath.Combine(TPath.GetTempPath, 'NimbusForms.LogViewer');
  Result := TPath.Combine(Dir, IntToHex(SourcePathHash, 16) + '.nli');
end;

function TNimbusIndexedLogFile.LoadPersistentIndex(const AContentStart: Int64;
  const AEncoding: TNimbusLogFileEncoding): Boolean;
var Stream: TFileStream; Magic: UInt64; Version: Cardinal; FileSize, Count, I, StoredContentStart: Int64;
  WriteTime, CurrentWriteTime: TDateTime; Enc: Integer; MaxText: Int64; Span: TNimbusLogFileSpan; Path: string;
begin
  Result := False;
  if not FOptions.PersistIndex then Exit;
  Path := IndexCachePath;
  if not TFile.Exists(Path) then Exit;
  try
    Stream := TFileStream.Create(Path, fmOpenRead or fmShareDenyWrite);
    try
      Stream.ReadBuffer(Magic, SizeOf(Magic));
      Stream.ReadBuffer(Version, SizeOf(Version));
      Stream.ReadBuffer(FileSize, SizeOf(FileSize));
      Stream.ReadBuffer(WriteTime, SizeOf(WriteTime));
      Stream.ReadBuffer(StoredContentStart, SizeOf(StoredContentStart));
      Stream.ReadBuffer(Enc, SizeOf(Enc));
      Stream.ReadBuffer(MaxText, SizeOf(MaxText));
      Stream.ReadBuffer(Count, SizeOf(Count));
      CurrentWriteTime := SourceWriteTime;
      if (Magic <> NimbusIndexMagic) or (Version <> NimbusIndexVersion) or (FileSize <> FFileLength) or
        (Abs(WriteTime - CurrentWriteTime) > (1 / MSecsPerDay)) or (StoredContentStart <> AContentStart) or
        (Enc <> Ord(AEncoding)) or (Count < 0) then Exit;
      FIndex.Clear;
      for I := 0 to Count - 1 do
      begin
        Stream.ReadBuffer(Span, SizeOf(Span));
        FIndex.Add(Span.Offset, Span.Length);
      end;
      FMaxTextLength := MaxText;
      FIndexedBytes := FFileLength;
      Result := True;
    finally Stream.Free; end;
  except
    FIndex.Clear;
    Result := False;
  end;
end;

procedure TNimbusIndexedLogFile.SavePersistentIndex(const AContentStart: Int64;
  const AEncoding: TNimbusLogFileEncoding);
var Stream: TFileStream; Magic: UInt64; Version: Cardinal; FileSize, Count, I: Int64;
  WriteTime: TDateTime; Enc: Integer; MaxText: Int64; Span: TNimbusLogFileSpan; Path, Dir, Temp: string;
begin
  if not FOptions.PersistIndex then Exit;
  Path := IndexCachePath;
  Dir := TPath.GetDirectoryName(Path);
  if not TDirectory.Exists(Dir) then TDirectory.CreateDirectory(Dir);
  Temp := Path + '.tmp';
  Magic := NimbusIndexMagic;
  Version := NimbusIndexVersion;
  FileSize := FFileLength;
  WriteTime := SourceWriteTime;
  Enc := Ord(AEncoding);
  MaxText := FMaxTextLength;
  Count := FIndex.Count;
  Stream := TFileStream.Create(Temp, fmCreate);
  try
    Stream.WriteBuffer(Magic, SizeOf(Magic));
    Stream.WriteBuffer(Version, SizeOf(Version));
    Stream.WriteBuffer(FileSize, SizeOf(FileSize));
    Stream.WriteBuffer(WriteTime, SizeOf(WriteTime));
    Stream.WriteBuffer(AContentStart, SizeOf(AContentStart));
    Stream.WriteBuffer(Enc, SizeOf(Enc));
    Stream.WriteBuffer(MaxText, SizeOf(MaxText));
    Stream.WriteBuffer(Count, SizeOf(Count));
    for I := 0 to Count - 1 do if FIndex.TryGet(I, Span) then Stream.WriteBuffer(Span, SizeOf(Span));
  finally Stream.Free; end;
  if TFile.Exists(Path) then TFile.Delete(Path);
  TFile.Move(Temp, Path);
end;

procedure TNimbusIndexedLogFile.BuildIndex(const AGeneration: Integer; AThread: TIndexThread);
var Stream: TFileStream; Sample, Buffer: TBytes; ReadCount, BOMSize, UnitSize, I, Limit: Integer;
  ContentStart, RecordStart, UnitOffset, SnapshotLength, RecordLength: Int64; Code: Cardinal;
  Encoding: TNimbusLogFileEncoding; PendingCR: Boolean; Batch: Integer;
begin
  try
    if not TFile.Exists(FFileName) then raise EFileNotFoundException.Create('Indexed log file not found: ' + FFileName);
    Stream := TFileStream.Create(FFileName, fmOpenRead or fmShareDenyNone);
    try
      SnapshotLength := Stream.Size;
      SetLength(Sample, Integer(Min(Int64(4096), SnapshotLength)));
      ReadCount := 0;
      if Length(Sample) > 0 then ReadCount := Stream.Read(Sample[0], Length(Sample));
      if ReadCount <> Length(Sample) then SetLength(Sample, ReadCount);
      Encoding := TNimbusLogTextCodec.Detect(Sample, FRequestedEncoding, BOMSize);
      ContentStart := BOMSize;
      FLock.Acquire;
      try
        if AGeneration <> FGeneration then Exit;
        FEncoding := Encoding;
        FFileLength := SnapshotLength;
        FIndexedBytes := ContentStart;
        FIndexing := True;
        FIndexComplete := False;
        Inc(FVersion);
      finally FLock.Release; end;
      if LoadPersistentIndex(ContentStart, Encoding) then
      begin
        FLock.Acquire;
        try
          if AGeneration <> FGeneration then Exit;
          FIndexing := False;
          FIndexComplete := True;
          FLastError := '';
          Inc(FVersion);
        finally FLock.Release; end;
        Exit;
      end;
      Stream.Position := ContentStart;
      UnitSize := TNimbusLogTextCodec.UnitSize(Encoding);
      SetLength(Buffer, Max(UnitSize, (Max(4096, FOptions.ReadBufferSize) div UnitSize) * UnitSize));
      RecordStart := ContentStart;
      PendingCR := False;
      Batch := 0;
      while Stream.Position < SnapshotLength do
      begin
        if AThread.IsTerminated then Exit;
        ReadCount := Stream.Read(Buffer[0], Integer(Min(Int64(Length(Buffer)), SnapshotLength - Stream.Position)));
        if ReadCount <= 0 then Break;
        Limit := ReadCount - (ReadCount mod UnitSize);
        UnitOffset := Stream.Position - ReadCount;
        I := 0;
        while I < Limit do
        begin
          Code := TNimbusLogTextCodec.ReadUnit(Buffer, I, Encoding);
          if PendingCR then
          begin
            if Code = 10 then begin RecordStart := UnitOffset + I + UnitSize; PendingCR := False; Inc(I, UnitSize); Continue; end;
            PendingCR := False;
          end;
          if Code = 13 then
          begin
            RecordLength := UnitOffset + I - RecordStart;
            FIndex.Add(RecordStart, RecordLength);
            FMaxTextLength := Max(FMaxTextLength, RecordLength div UnitSize);
            RecordStart := UnitOffset + I + UnitSize;
            PendingCR := True;
            Inc(Batch);
          end
          else if Code = 10 then
          begin
            RecordLength := UnitOffset + I - RecordStart;
            FIndex.Add(RecordStart, RecordLength);
            FMaxTextLength := Max(FMaxTextLength, RecordLength div UnitSize);
            RecordStart := UnitOffset + I + UnitSize;
            Inc(Batch);
          end;
          Inc(I, UnitSize);
          if Batch >= Max(64, FOptions.IndexBatchSize) then
          begin
            Batch := 0;
            FLock.Acquire;
            try
              FIndexedBytes := UnitOffset + I;
              Inc(FVersion);
            finally FLock.Release; end;
            if AThread.IsTerminated then Exit;
          end;
        end;
      end;
      if not AThread.IsTerminated and (RecordStart < SnapshotLength) then
      begin
        RecordLength := SnapshotLength - RecordStart;
        FIndex.Add(RecordStart, RecordLength);
        FMaxTextLength := Max(FMaxTextLength, RecordLength div UnitSize);
      end;
      if AThread.IsTerminated then Exit;
      FIndexedBytes := SnapshotLength;
      SavePersistentIndex(ContentStart, Encoding);
    finally Stream.Free; end;
    FLock.Acquire;
    try
      if AGeneration <> FGeneration then Exit;
      FIndexedBytes := FFileLength;
      FIndexing := False;
      FIndexComplete := True;
      FLastError := '';
      Inc(FVersion);
    finally FLock.Release; end;
  except
    on E: Exception do
    begin
      FLock.Acquire;
      try
        if AGeneration = FGeneration then
        begin FIndexing := False; FIndexComplete := False; FLastError := E.Message; Inc(FVersion); end;
      finally FLock.Release; end;
    end;
  end;
end;

procedure TNimbusIndexedLogFile.BeginSearch(const AText, AStructuredQuery: string; const ACaseSensitive,
  ARegex: Boolean; const ALevels: TNimbusLogLevels; const AIncludeNonTextRows: Boolean);
var RequestID, Generation: Integer;
begin
  StopSearchThread;
  FLock.Acquire;
  try
    Inc(FSearchRequestID);
    RequestID := FSearchRequestID;
    Generation := FGeneration;
    FSearching := True;
    FSearchTruncated := False;
    FSearchError := '';
    FSearchResults := nil;
    Inc(FSearchVersion);
    FSearchThread := TSearchThread.Create(Self, Generation, RequestID, AText, AStructuredQuery, ACaseSensitive, ARegex, AIncludeNonTextRows, ALevels);
    FSearchThread.Start;
  finally FLock.Release; end;
end;

procedure TNimbusIndexedLogFile.CancelSearch;
begin
  StopSearchThread;
  FLock.Acquire;
  try FSearching := False; Inc(FSearchRequestID); Inc(FSearchVersion); finally FLock.Release; end;
end;

function TNimbusIndexedLogFile.SearchResults: TNimbusIndexedSearchHits;
begin
  FLock.Acquire;
  try Result := System.Copy(FSearchResults, 0, Length(FSearchResults)); finally FLock.Release; end;
end;

procedure TNimbusIndexedLogFile.RunSearch(const AGeneration, ARequestID: Integer; const AText,
  AStructuredQuery: string; const ACaseSensitive, ARegex, AIncludeNonTextRows: Boolean;
  const ALevels: TNimbusLogLevels; AThread: TSearchThread);
var Stream: TFileStream; Count, I: Int64; Span: TNimbusLogFileSpan; Text, CompareText, CompareQuery: string;
  Line: TNimbusLogLine; Entry: TNimbusStructuredLogEntry; Query: TNimbusLogQuery; Matches: TMatchCollection;
  Match: TMatch; Pattern: TRegEx; Options: TRegExOptions; List: TList<TNimbusIndexedSearchHit>;
  Hit: TNimbusIndexedSearchHit; HasTextMatch, HasStructuredMatch, Truncated, NeedParsed: Boolean;
begin
  Query := nil;
  List := TList<TNimbusIndexedSearchHit>.Create;
  try
    try
      if Trim(AStructuredQuery) <> '' then Query := TNimbusLogQuery.Parse(AStructuredQuery);
      NeedParsed := (Query <> nil) or (ALevels <> [Low(TNimbusLogLevel)..High(TNimbusLogLevel)]);
      Options := [];
      if not ACaseSensitive then Include(Options, roIgnoreCase);
      if ARegex and (AText <> '') then Pattern := TRegEx.Create(AText, Options);
      CompareQuery := AText;
      if not ACaseSensitive then CompareQuery := LowerCase(CompareQuery);
      Count := FIndex.Count;
      Stream := TFileStream.Create(FFileName, fmOpenRead or fmShareDenyNone);
      try
        Truncated := False;
        for I := 0 to Count - 1 do
        begin
          if AThread.IsTerminated then Exit;
          if not FIndex.TryGet(I, Span) then Break;
          Text := ReadSpanText(Stream, Span);
          Line := nil;
          try
            HasStructuredMatch := True;
            if NeedParsed then
            begin
              Line := TNimbusLogLine.Create(UInt64(I + 1), Text, nllUnknown);
              if not (Line.Level in ALevels) then Continue;
              if Query <> nil then
              begin
                Entry := Line.Structured;
                HasStructuredMatch := Query.Matches(Entry);
              end;
            end;
            if not HasStructuredMatch then Continue;
            HasTextMatch := AText = '';
            if AText <> '' then
            begin
              if ARegex then
              begin
                Matches := Pattern.Matches(Text);
                HasTextMatch := Matches.Count > 0;
                for Match in Matches do
                begin
                  Hit.SourceIndex := I; Hit.Column := Match.Index; Hit.Length := Match.Length; Hit.TextMatch := True; List.Add(Hit);
                  if List.Count >= Max(1, FOptions.MaxSearchMatches) then begin Truncated := True; Break; end;
                end;
              end
              else
              begin
                CompareText := Text;
                if not ACaseSensitive then CompareText := LowerCase(CompareText);
                Hit.Column := Pos(CompareQuery, CompareText) - 1;
                HasTextMatch := Hit.Column >= 0;
                while HasTextMatch and (Hit.Column >= 0) do
                begin
                  Hit.SourceIndex := I; Hit.Length := Length(AText); Hit.TextMatch := True; List.Add(Hit);
                  if List.Count >= Max(1, FOptions.MaxSearchMatches) then begin Truncated := True; Break; end;
                  Hit.Column := PosEx(CompareQuery, CompareText, Hit.Column + Max(1, Length(CompareQuery)) + 1) - 1;
                  if Hit.Column < 0 then Break;
                end;
              end;
            end;
            if (AText = '') and HasStructuredMatch then
            begin Hit.SourceIndex := I; Hit.Column := 0; Hit.Length := 0; Hit.TextMatch := False; List.Add(Hit); end
            else if AIncludeNonTextRows and HasStructuredMatch and not HasTextMatch then
            begin Hit.SourceIndex := I; Hit.Column := 0; Hit.Length := 0; Hit.TextMatch := False; List.Add(Hit); end;
            if Truncated then Break;
          finally Line.Free; end;
        end;
      finally Stream.Free; end;
      FLock.Acquire;
      try
        if (AGeneration = FGeneration) and (ARequestID = FSearchRequestID) and not AThread.IsTerminated then
        begin
          FSearchResults := List.ToArray;
          FSearchTruncated := Truncated;
          FSearching := False;
          FSearchError := '';
          Inc(FSearchVersion);
        end;
      finally FLock.Release; end;
    except
      on E: Exception do
      begin
        FLock.Acquire;
        try
          if (AGeneration = FGeneration) and (ARequestID = FSearchRequestID) then
          begin FSearching := False; FSearchError := E.Message; Inc(FSearchVersion); end;
        finally FLock.Release; end;
      end;
    end;
  finally Query.Free; List.Free; end;
end;

procedure TNimbusIndexedLogFile.SaveToFile(const APath: string; const AEncoding: TNimbusLogFileEncoding;
  const AWriteBOM: Boolean);
var Source: TFileStream; Target: TFileStream; Span: TNimbusLogFileSpan; I: Int64; Text: string;
  Bytes: TBytes; Encoding: TNimbusLogFileEncoding;
begin
  Encoding := AEncoding;
  if Encoding = nlfeAuto then Encoding := FEncoding;
  Source := TFileStream.Create(FFileName, fmOpenRead or fmShareDenyNone);
  try
    Target := TFileStream.Create(APath, fmCreate);
    try
      if AWriteBOM then
      begin Bytes := TNimbusLogTextCodec.Preamble(Encoding); if Length(Bytes) > 0 then Target.WriteBuffer(Bytes[0], Length(Bytes)); end;
      for I := 0 to FIndex.Count - 1 do
        if FIndex.TryGet(I, Span) then
        begin
          Text := ReadSpanText(Source, Span) + sLineBreak;
          Bytes := TNimbusLogTextCodec.Encode(Text, Encoding);
          if Length(Bytes) > 0 then Target.WriteBuffer(Bytes[0], Length(Bytes));
        end;
    finally Target.Free; end;
  finally Source.Free; end;
end;

end.

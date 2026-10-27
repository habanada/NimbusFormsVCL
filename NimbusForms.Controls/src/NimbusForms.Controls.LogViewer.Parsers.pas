unit NimbusForms.Controls.LogViewer.Parsers;

interface

uses System.SysUtils, System.Classes, System.JSON, System.RegularExpressions, System.Generics.Collections,
  NimbusForms.Controls.LogViewer.Types, NimbusForms.Controls.LogViewer.Structured;

type
  INimbusLogParser = interface
    ['{AD07B518-B6F7-46E6-A7C0-75AA5D71D391}']
    function TryParse(const AText: string; out AEntry: TNimbusStructuredLogEntry): Boolean;
  end;

  TNimbusPlainTextLogParser = class(TInterfacedObject, INimbusLogParser)
  public
    function TryParse(const AText: string; out AEntry: TNimbusStructuredLogEntry): Boolean;
  end;

  TNimbusJsonLogParser = class(TInterfacedObject, INimbusLogParser)
  private
    class function ValueText(const AValue: TJSONValue): string; static;
    class function FindValue(const AObject: TJSONObject; const ANames: array of string): TJSONValue; static;
    class function FindText(const AObject: TJSONObject; const ANames: array of string): string; static;
    class procedure FlattenValue(const APrefix: string; const AValue: TJSONValue; AEntry: TNimbusStructuredLogEntry); static;
    class function ParseException(const AValue: TJSONValue): TNimbusLogExceptionInfo; static;
  protected
    function AcceptObject(const AObject: TJSONObject): Boolean; virtual;
    procedure AfterParse(const AObject: TJSONObject; AEntry: TNimbusStructuredLogEntry); virtual;
  public
    function TryParse(const AText: string; out AEntry: TNimbusStructuredLogEntry): Boolean; virtual;
  end;

  TNimbusSerilogCompactJsonParser = class(TNimbusJsonLogParser)
  protected
    function AcceptObject(const AObject: TJSONObject): Boolean; override;
    procedure AfterParse(const AObject: TJSONObject; AEntry: TNimbusStructuredLogEntry); override;
  end;

  TNimbusAnsiLogParser = class(TInterfacedObject, INimbusLogParser)
  public
    class function StripAnsi(const AText: string): string; static;
    function TryParse(const AText: string; out AEntry: TNimbusStructuredLogEntry): Boolean;
  end;

  TNimbusBuildOutputLogParser = class(TInterfacedObject, INimbusLogParser)
  public
    function TryParse(const AText: string; out AEntry: TNimbusStructuredLogEntry): Boolean;
  end;

  TNimbusRegexLogParser = class(TInterfacedObject, INimbusLogParser)
  private
    FExpression: string;
    FRegex: TRegEx;
    FValid: Boolean;
    FTimestampGroup: string;
    FLevelGroup: string;
    FMessageGroup: string;
    FLoggerGroup: string;
    FSourceGroup: string;
    FThreadIDGroup: string;
    FProcessIDGroup: string;
    FTraceIDGroup: string;
    FSpanIDGroup: string;
    FCorrelationIDGroup: string;
    FExceptionGroup: string;
    procedure SetExpression(const AValue: string);
  public
    constructor Create(const AExpression: string = '');
    function TryParse(const AText: string; out AEntry: TNimbusStructuredLogEntry): Boolean;
    property Expression: string read FExpression write SetExpression;
    property TimestampGroup: string read FTimestampGroup write FTimestampGroup;
    property LevelGroup: string read FLevelGroup write FLevelGroup;
    property MessageGroup: string read FMessageGroup write FMessageGroup;
    property LoggerGroup: string read FLoggerGroup write FLoggerGroup;
    property SourceGroup: string read FSourceGroup write FSourceGroup;
    property ThreadIDGroup: string read FThreadIDGroup write FThreadIDGroup;
    property ProcessIDGroup: string read FProcessIDGroup write FProcessIDGroup;
    property TraceIDGroup: string read FTraceIDGroup write FTraceIDGroup;
    property SpanIDGroup: string read FSpanIDGroup write FSpanIDGroup;
    property CorrelationIDGroup: string read FCorrelationIDGroup write FCorrelationIDGroup;
    property ExceptionGroup: string read FExceptionGroup write FExceptionGroup;
  end;

  TNimbusLogParserChain = class
  private
    FParsers: TList<INimbusLogParser>;
    FFallback: INimbusLogParser;
  public
    constructor Create;
    destructor Destroy; override;
    class function CreateStandard: TNimbusLogParserChain; static;
    procedure Add(const AParser: INimbusLogParser);
    function TryParse(const AText: string; out AEntry: TNimbusStructuredLogEntry): Boolean;
  end;

  TNimbusLogMultilineAssembler = class
  private
    FLines: TStringList;
    FStartPattern: TRegEx;
    FHasPattern: Boolean;
    FMaxLines: Integer;
    FMaxChars: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Configure(const AStartExpression: string; const AMaxLines: Integer = 1000; const AMaxChars: Integer = 1048576);
    function AddLine(const ALine: string; out ACompletedRecord: string): Boolean;
    function Flush(out ACompletedRecord: string): Boolean;
  end;

function NimbusParseLogLevel(const AText: string): TNimbusLogLevel;
function NimbusParseExceptionText(const AText: string): TNimbusLogExceptionInfo;
function NimbusTryParseLogDateTime(const AText: string; out ALocal, AUtc: TDateTime): Boolean;
function NimbusParseStandardLogEntry(const AText: string; out AEntry: TNimbusStructuredLogEntry): Boolean;

implementation

uses System.DateUtils, System.StrUtils, System.Math;

var
  StandardParser: TNimbusLogParserChain;
  StandardParserLock: TObject;

function NimbusParseStandardLogEntry(const AText: string; out AEntry: TNimbusStructuredLogEntry): Boolean;
begin
  TMonitor.Enter(StandardParserLock);
  try Result := StandardParser.TryParse(AText, AEntry); finally TMonitor.Exit(StandardParserLock); end;
end;

function NimbusParseLogLevel(const AText: string): TNimbusLogLevel;
begin
  Result := TNimbusLogLexer.LevelOf(AText);
  if Result <> nllUnknown then Exit;
  if SameText(AText, 'INFORMATION') then Result := nllInfo
  else if SameText(AText, 'CRITICAL') then Result := nllFatal
  else if SameText(AText, 'VERBOSE') then Result := nllTrace;
end;

function NimbusTryParseLogDateTime(const AText: string; out ALocal, AUtc: TDateTime): Boolean;
var
  S: string;
  N, P, StartFraction: Integer;
  YearValue, MonthValue, DayValue: Word;
  HourValue, MinuteValue, SecondValue, MilliSecondValue: Word;
  V, DatePart, TimePart: TDateTime;
  OffsetHours, OffsetMinutes, OffsetTotal, OffsetSign: Integer;
  Fraction, Scale: Double;
  HasTimeZone, IsUtc: Boolean;

  function ParseFixedInt(const AStart, ACount: Integer; out AValue: Integer): Boolean;
  var
    I: Integer;
    C: Char;
  begin
    Result := False;
    AValue := 0;
    if (AStart < 1) or (ACount <= 0) or (AStart + ACount - 1 > N) then Exit;
    for I := AStart to AStart + ACount - 1 do
    begin
      C := S[I];
      if not CharInSet(C, ['0'..'9']) then Exit;
      AValue := (AValue * 10) + (Ord(C) - Ord('0'));
    end;
    Result := True;
  end;

var
  Temp: Integer;
begin
  Result := False;
  ALocal := 0;
  AUtc := 0;
  S := Trim(AText);
  N := Length(S);

  if N < 10 then Exit;
  if (S[5] <> '-') or (S[8] <> '-') then Exit;
  if not ParseFixedInt(1, 4, Temp) then Exit;
  YearValue := Temp;
  if not ParseFixedInt(6, 2, Temp) then Exit;
  MonthValue := Temp;
  if not ParseFixedInt(9, 2, Temp) then Exit;
  DayValue := Temp;
  if not TryEncodeDate(YearValue, MonthValue, DayValue, DatePart) then Exit;

  V := DatePart;
  HasTimeZone := False;
  IsUtc := False;
  OffsetTotal := 0;

  if N > 10 then
  begin
    if not CharInSet(S[11], ['T', 't', ' ']) then Exit;
    if N < 19 then Exit;
    if (S[14] <> ':') or (S[17] <> ':') then Exit;

    if not ParseFixedInt(12, 2, Temp) then Exit;
    HourValue := Temp;
    if not ParseFixedInt(15, 2, Temp) then Exit;
    MinuteValue := Temp;
    if not ParseFixedInt(18, 2, Temp) then Exit;
    SecondValue := Temp;
    MilliSecondValue := 0;
    if not TryEncodeTime(HourValue, MinuteValue, SecondValue, MilliSecondValue, TimePart) then Exit;
    V := V + TimePart;

    P := 20;
    if (P <= N) and CharInSet(S[P], ['.', ',']) then
    begin
      Inc(P);
      StartFraction := P;
      Fraction := 0.0;
      Scale := 0.1;
      while (P <= N) and CharInSet(S[P], ['0'..'9']) do
      begin
        Fraction := Fraction + ((Ord(S[P]) - Ord('0')) * Scale);
        Scale := Scale * 0.1;
        Inc(P);
      end;
      if P = StartFraction then Exit;
      V := V + (Fraction / 86400.0);
    end;

    if P <= N then
    begin
      if CharInSet(S[P], ['Z', 'z']) then
      begin
        if P <> N then Exit;
        HasTimeZone := True;
        IsUtc := True;
      end
      else if CharInSet(S[P], ['+', '-']) then
      begin
        HasTimeZone := True;
        if S[P] = '-' then OffsetSign := -1 else OffsetSign := 1;
        Inc(P);
        if not ParseFixedInt(P, 2, OffsetHours) then Exit;
        Inc(P, 2);
        if (P <= N) and (S[P] = ':') then Inc(P);
        if not ParseFixedInt(P, 2, OffsetMinutes) then Exit;
        Inc(P, 2);
        if P <= N then Exit;
        if (OffsetHours > 23) or (OffsetMinutes > 59) then Exit;
        OffsetTotal := OffsetSign * ((OffsetHours * 60) + OffsetMinutes);
      end
      else
        Exit;
    end;
  end;

  try
    if HasTimeZone then
    begin
      if IsUtc then
        AUtc := V
      else
        AUtc := V - (OffsetTotal / 1440.0);
      ALocal := TTimeZone.Local.ToLocalTime(AUtc);
    end
    else
    begin
      ALocal := V;
      AUtc := TTimeZone.Local.ToUniversalTime(ALocal);
    end;
  except
    ALocal := 0;
    AUtc := 0;
    Exit(False);
  end;

  Result := True;
end;

function NimbusParseExceptionText(const AText: string): TNimbusLogExceptionInfo;
var Lines: TStringList; First, S: string; P, I: Integer;
begin
  Result := nil;
  if Trim(AText) = '' then Exit;
  Result := TNimbusLogExceptionInfo.Create;
  Result.StackTrace := AText;
  Lines := TStringList.Create;
  try
    Lines.Text := AText.Replace(#13#10, #10).Replace(#13, #10);
    if Lines.Count > 0 then
    begin
      First := Trim(Lines[0]);
      P := Pos(':', First);
      if P > 1 then
      begin
        Result.TypeName := Trim(Copy(First, 1, P - 1));
        Result.Message := Trim(Copy(First, P + 1, MaxInt));
      end
      else if ContainsText(First, 'Exception') or ContainsText(First, 'Error') then Result.TypeName := First
      else Result.Message := First;
    end;
    for I := 1 to Lines.Count - 1 do
    begin
      S := Trim(Lines[I]);
      if S <> '' then Result.StackFrames.Add(S);
    end;
  finally Lines.Free; end;
end;

function TNimbusPlainTextLogParser.TryParse(const AText: string; out AEntry: TNimbusStructuredLogEntry): Boolean;
var Match: TMatch; LocalTime, UtcTime: TDateTime; LevelText: string; P: Integer;
begin
  AEntry := TNimbusStructuredLogEntry.Create;
  AEntry.OriginalText := AText;
  AEntry.RenderedMessage := AText;
  Match := TRegEx.Match(AText, '^\s*(?<time>\d{4}-\d{2}-\d{2}(?:[T\s]\d{2}:\d{2}:\d{2}(?:[.,]\d+)?(?:Z|[+-]\d{2}:?\d{2})?)?)');
  if Match.Success and NimbusTryParseLogDateTime(Match.Groups['time'].Value.Replace(',', '.'), LocalTime, UtcTime) then
  begin
    AEntry.Timestamp := LocalTime;
    AEntry.TimestampUtc := UtcTime;
    AEntry.HasTimestamp := True;
  end;
  Match := TRegEx.Match(AText, '(?:^|[\s\[\(<{])(?<level>TRACE|TRC|VERBOSE|DEBUG|DBG|INFO|INF|INFORMATION|SUCCESS|OK|WARN|WRN|WARNING|ERROR|ERR|FATAL|CRITICAL|CRT)(?:$|[\s\]\)>}:])', [roIgnoreCase]);
  if Match.Success then
  begin
    LevelText := Match.Groups['level'].Value;
    AEntry.OriginalLevel := LevelText;
    AEntry.Level := NimbusParseLogLevel(LevelText);
  end;
  Match := TRegEx.Match(AText, '\[(?<thread>\d+)\]');
  if Match.Success then
  begin
    P := StrToIntDef(Match.Groups['thread'].Value, -1);
    if P >= 0 then AEntry.SetThreadID(P);
  end;
  if ContainsText(AText, 'Exception:') or ContainsText(AText, 'Error:') then AEntry.ExceptionInfo := NimbusParseExceptionText(AText);
  Result := True;
end;

class function TNimbusJsonLogParser.ValueText(const AValue: TJSONValue): string;
begin
  if AValue = nil then Exit('');
  if AValue is TJSONString then Result := TJSONString(AValue).Value
  else if AValue is TJSONNull then Result := ''
  else Result := AValue.ToJSON;
end;

class function TNimbusJsonLogParser.FindValue(const AObject: TJSONObject; const ANames: array of string): TJSONValue;
var Name: string; Pair: TJSONPair;
begin
  Result := nil;
  if AObject = nil then Exit;
  for Name in ANames do
    for Pair in AObject do
      if SameText(Pair.JsonString.Value, Name) then Exit(Pair.JsonValue);
end;

class function TNimbusJsonLogParser.FindText(const AObject: TJSONObject; const ANames: array of string): string;
begin
  Result := ValueText(FindValue(AObject, ANames));
end;

class procedure TNimbusJsonLogParser.FlattenValue(const APrefix: string; const AValue: TJSONValue;
  AEntry: TNimbusStructuredLogEntry);
var Pair: TJSONPair; Name: string;
begin
  if (AValue = nil) or (AEntry = nil) then Exit;
  if AValue is TJSONObject then
  begin
    for Pair in TJSONObject(AValue) do
    begin
      if APrefix = '' then Name := Pair.JsonString.Value else Name := APrefix + '.' + Pair.JsonString.Value;
      FlattenValue(Name, Pair.JsonValue, AEntry);
    end;
    Exit;
  end;
  AEntry.AddProperty(APrefix, ValueText(AValue));
end;

class function TNimbusJsonLogParser.ParseException(const AValue: TJSONValue): TNimbusLogExceptionInfo;
var Obj: TJSONObject; Inner: TJSONValue; Lines: TStringList; I: Integer;
begin
  Result := nil;
  if (AValue = nil) or (AValue is TJSONNull) then Exit;
  if AValue is TJSONString then Exit(NimbusParseExceptionText(TJSONString(AValue).Value));
  if not (AValue is TJSONObject) then Exit(NimbusParseExceptionText(AValue.ToJSON));
  Obj := TJSONObject(AValue);
  Result := TNimbusLogExceptionInfo.Create;
  Result.TypeName := FindText(Obj, ['Type', 'type', 'ClassName', 'className', 'ExceptionType', 'exceptionType']);
  Result.Message := FindText(Obj, ['Message', 'message']);
  Result.StackTrace := FindText(Obj, ['StackTrace', 'stackTrace', 'Stack', 'stack']);
  Inner := FindValue(Obj, ['InnerException', 'innerException', 'Inner', 'inner']);
  if Inner <> nil then Result.InnerException := ParseException(Inner);
  if Result.StackTrace <> '' then
  begin
    Lines := TStringList.Create;
    try
      Lines.Text := Result.StackTrace.Replace(#13#10, #10).Replace(#13, #10);
      for I := 0 to Lines.Count - 1 do if Trim(Lines[I]) <> '' then Result.StackFrames.Add(Trim(Lines[I]));
    finally Lines.Free; end;
  end;
end;

function TNimbusJsonLogParser.AcceptObject(const AObject: TJSONObject): Boolean;
begin
  Result := True;
end;

procedure TNimbusJsonLogParser.AfterParse(const AObject: TJSONObject; AEntry: TNimbusStructuredLogEntry);
begin
end;

function TNimbusJsonLogParser.TryParse(const AText: string; out AEntry: TNimbusStructuredLogEntry): Boolean;
var Value, ExceptionValue, PropertiesValue: TJSONValue; Obj: TJSONObject; Pair: TJSONPair;
  TimeText, LevelText, S: string; LocalTime, UtcTime: TDateTime; N: Int64;
begin
  Result := False;
  AEntry := nil;
  S := Trim(AText);
  if (Length(S) < 2) or (S[1] <> '{') or (S[Length(S)] <> '}') then Exit;
  Value := TJSONObject.ParseJSONValue(S);
  if Value = nil then Exit;
  try
    if not (Value is TJSONObject) then Exit;
    Obj := TJSONObject(Value);
    if not AcceptObject(Obj) then Exit;
    AEntry := TNimbusStructuredLogEntry.Create;
    AEntry.OriginalText := AText;
    TimeText := FindText(Obj, ['Timestamp', 'timestamp', 'Time', 'time', 'Date', 'date', '@t']);
    if (TimeText <> '') and NimbusTryParseLogDateTime(TimeText, LocalTime, UtcTime) then
    begin AEntry.Timestamp := LocalTime; AEntry.TimestampUtc := UtcTime; AEntry.HasTimestamp := True; end;
    LevelText := FindText(Obj, ['Level', 'level', 'Severity', 'severity', 'LogLevel', 'logLevel', '@l']);
    AEntry.OriginalLevel := LevelText;
    AEntry.Level := NimbusParseLogLevel(LevelText);
    AEntry.RenderedMessage := FindText(Obj, ['RenderedMessage', 'renderedMessage', 'Message', 'message', 'msg', '@m']);
    AEntry.MessageTemplate := FindText(Obj, ['MessageTemplate', 'messageTemplate', 'Template', 'template', '@mt']);
    AEntry.LoggerName := FindText(Obj, ['LoggerName', 'loggerName', 'Logger', 'logger']);
    AEntry.SourceContext := FindText(Obj, ['SourceContext', 'sourceContext', 'Source', 'source']);
    AEntry.Category := FindText(Obj, ['Category', 'category']);
    AEntry.TraceID := FindText(Obj, ['TraceId', 'traceId', 'trace_id', '@tr']);
    AEntry.SpanID := FindText(Obj, ['SpanId', 'spanId', 'span_id', '@sp']);
    AEntry.CorrelationID := FindText(Obj, ['CorrelationId', 'correlationId', 'correlation_id', 'RequestId', 'requestId']);
    AEntry.ThreadName := FindText(Obj, ['ThreadName', 'threadName']);
    AEntry.ProcessName := FindText(Obj, ['ProcessName', 'processName']);
    if TryStrToInt64(FindText(Obj, ['ThreadId', 'threadId']), N) then AEntry.SetThreadID(N);
    if TryStrToInt64(FindText(Obj, ['ProcessId', 'processId']), N) then AEntry.SetProcessID(N);
    ExceptionValue := FindValue(Obj, ['Exception', 'exception', 'ExceptionDetail', 'exceptionDetail', '@x']);
    if ExceptionValue <> nil then AEntry.ExceptionInfo := ParseException(ExceptionValue);
    PropertiesValue := FindValue(Obj, ['Properties', 'properties']);
    if PropertiesValue is TJSONObject then FlattenValue('', PropertiesValue, AEntry);
    for Pair in Obj do
      if not SameText(Pair.JsonString.Value, 'Properties') and not SameText(Pair.JsonString.Value, 'properties') then
        FlattenValue(Pair.JsonString.Value, Pair.JsonValue, AEntry);
    if AEntry.RenderedMessage = '' then AEntry.RenderedMessage := AEntry.MessageTemplate;
    if AEntry.RenderedMessage = '' then AEntry.RenderedMessage := AText;
    AfterParse(Obj, AEntry);
    Result := True;
  finally
    if not Result then FreeAndNil(AEntry);
    Value.Free;
  end;
end;

function TNimbusSerilogCompactJsonParser.AcceptObject(const AObject: TJSONObject): Boolean;
begin
  Result := (FindValue(AObject, ['@t']) <> nil) or (FindValue(AObject, ['@mt']) <> nil) or
    (FindValue(AObject, ['@m']) <> nil) or (FindValue(AObject, ['@l']) <> nil);
end;

procedure TNimbusSerilogCompactJsonParser.AfterParse(const AObject: TJSONObject; AEntry: TNimbusStructuredLogEntry);
var V: TJSONValue;
begin
  AEntry.SourceName := 'Serilog Compact JSON';
  V := FindValue(AObject, ['@i']); if V <> nil then AEntry.AddProperty('EventId', ValueText(V));
  V := FindValue(AObject, ['@r']); if V <> nil then AEntry.AddProperty('Renderings', ValueText(V));
end;

class function TNimbusAnsiLogParser.StripAnsi(const AText: string): string;
var I, J, N: Integer; B: TStringBuilder;
begin
  B := TStringBuilder.Create(Length(AText));
  try
    I := 1; N := Length(AText);
    while I <= N do
    begin
      if (AText[I] = #27) and (I < N) and (AText[I + 1] = '[') then
      begin
        J := I + 2;
        while (J <= N) and (CharInSet(AText[J], ['0'..'9', ';', '?', ':']) or ((AText[J] >= #32) and (AText[J] <= #47))) do Inc(J);
        if (J <= N) and ((AText[J] >= #64) and (AText[J] <= #126)) then begin I := J + 1; Continue; end;
      end;
      B.Append(AText[I]); Inc(I);
    end;
    Result := B.ToString;
  finally B.Free; end;
end;

function TNimbusAnsiLogParser.TryParse(const AText: string; out AEntry: TNimbusStructuredLogEntry): Boolean;
var Plain: string; Parser: INimbusLogParser;
begin
  AEntry := nil;
  Result := Pos(#27, AText) > 0;
  if not Result then Exit;
  Plain := StripAnsi(AText);
  Parser := TNimbusPlainTextLogParser.Create;
  Result := Parser.TryParse(Plain, AEntry);
  if Result and (AEntry <> nil) then AEntry.OriginalText := AText;
end;

function TNimbusBuildOutputLogParser.TryParse(const AText: string; out AEntry: TNimbusStructuredLogEntry): Boolean;
var Lower: string; Parser: INimbusLogParser;
begin
  AEntry := nil;
  Lower := LowerCase(AText);
  Result := ContainsText(Lower, 'exception thrown:') or ContainsText(Lower, ' has exited with code ') or
    ContainsText(Lower, 'symbols loaded') or ContainsText(Lower, 'skipped loading symbols') or
    TRegEx.IsMatch(AText, '\.(pas|dpr|cpp|c|h|hpp|cs|fs|vb|java|kt|rs|py)\(\d+(?:,\d+)?\)\s*:\s*(fatal|error|warning|hint|note)', [roIgnoreCase]) or
    TRegEx.IsMatch(AText, '\.(cpp|c|h|hpp|rs|py|java|kt):\d+(?::\d+)?\s*:\s*(fatal|error|warning|note)', [roIgnoreCase]);
  if not Result then Exit;
  Parser := TNimbusPlainTextLogParser.Create;
  Parser.TryParse(AText, AEntry);
  AEntry.SourceName := 'Build Output';
  if ContainsText(Lower, 'fatal') or ContainsText(Lower, 'error') or ContainsText(Lower, 'exception') then AEntry.Level := nllError
  else if ContainsText(Lower, 'warning') then AEntry.Level := nllWarning
  else AEntry.Level := nllDebug;
end;

constructor TNimbusRegexLogParser.Create(const AExpression: string);
begin
  inherited Create;
  FTimestampGroup := 'timestamp'; FLevelGroup := 'level'; FMessageGroup := 'message';
  FLoggerGroup := 'logger'; FSourceGroup := 'source'; FThreadIDGroup := 'thread'; FProcessIDGroup := 'process';
  FTraceIDGroup := 'trace'; FSpanIDGroup := 'span'; FCorrelationIDGroup := 'correlation'; FExceptionGroup := 'exception';
  SetExpression(AExpression);
end;

procedure TNimbusRegexLogParser.SetExpression(const AValue: string);
begin
  FExpression := AValue;
  FValid := False;
  if FExpression = '' then Exit;
  FRegex := TRegEx.Create(FExpression, [roIgnoreCase]);
  FRegex.IsMatch('');
  FValid := True;
end;

function TNimbusRegexLogParser.TryParse(const AText: string; out AEntry: TNimbusStructuredLogEntry): Boolean;
var M: TMatch; G: TGroup; N: Int64; LocalTime, UtcTime: TDateTime;
begin
  AEntry := nil;
  if not FValid then Exit(False);
  M := FRegex.Match(AText);
  if not M.Success then Exit(False);
  AEntry := TNimbusStructuredLogEntry.Create;
  AEntry.OriginalText := AText;
  AEntry.RenderedMessage := AText;
  G := M.Groups[FTimestampGroup];
  if G.Success and NimbusTryParseLogDateTime(G.Value, LocalTime, UtcTime) then
  begin AEntry.Timestamp := LocalTime; AEntry.TimestampUtc := UtcTime; AEntry.HasTimestamp := True; end;
  G := M.Groups[FLevelGroup]; if G.Success then begin AEntry.OriginalLevel := G.Value; AEntry.Level := NimbusParseLogLevel(G.Value); end;
  G := M.Groups[FMessageGroup]; if G.Success then AEntry.RenderedMessage := G.Value;
  G := M.Groups[FLoggerGroup]; if G.Success then AEntry.LoggerName := G.Value;
  G := M.Groups[FSourceGroup]; if G.Success then AEntry.SourceContext := G.Value;
  G := M.Groups[FThreadIDGroup]; if G.Success and TryStrToInt64(G.Value, N) then AEntry.SetThreadID(N);
  G := M.Groups[FProcessIDGroup]; if G.Success and TryStrToInt64(G.Value, N) then AEntry.SetProcessID(N);
  G := M.Groups[FTraceIDGroup]; if G.Success then AEntry.TraceID := G.Value;
  G := M.Groups[FSpanIDGroup]; if G.Success then AEntry.SpanID := G.Value;
  G := M.Groups[FCorrelationIDGroup]; if G.Success then AEntry.CorrelationID := G.Value;
  G := M.Groups[FExceptionGroup]; if G.Success then AEntry.ExceptionInfo := NimbusParseExceptionText(G.Value);
  Result := True;
end;

constructor TNimbusLogParserChain.Create;
begin
  inherited Create;
  FParsers := TList<INimbusLogParser>.Create;
  FFallback := TNimbusPlainTextLogParser.Create;
end;

destructor TNimbusLogParserChain.Destroy;
begin
  FParsers.Free;
  FFallback := nil;
  inherited;
end;

class function TNimbusLogParserChain.CreateStandard: TNimbusLogParserChain;
begin
  Result := TNimbusLogParserChain.Create;
  Result.Add(TNimbusSerilogCompactJsonParser.Create);
  Result.Add(TNimbusJsonLogParser.Create);
  Result.Add(TNimbusAnsiLogParser.Create);
  Result.Add(TNimbusBuildOutputLogParser.Create);
end;

procedure TNimbusLogParserChain.Add(const AParser: INimbusLogParser);
begin
  if AParser <> nil then FParsers.Add(AParser);
end;

function TNimbusLogParserChain.TryParse(const AText: string; out AEntry: TNimbusStructuredLogEntry): Boolean;
var Parser: INimbusLogParser;
begin
  AEntry := nil;
  for Parser in FParsers do if Parser.TryParse(AText, AEntry) and (AEntry <> nil) then Exit(True);
  Result := (FFallback <> nil) and FFallback.TryParse(AText, AEntry) and (AEntry <> nil);
end;

constructor TNimbusLogMultilineAssembler.Create;
begin
  inherited Create;
  FLines := TStringList.Create;
  FMaxLines := 1000;
  FMaxChars := 1048576;
end;

destructor TNimbusLogMultilineAssembler.Destroy;
begin
  FLines.Free;
  inherited;
end;

procedure TNimbusLogMultilineAssembler.Configure(const AStartExpression: string; const AMaxLines, AMaxChars: Integer);
begin
  FHasPattern := AStartExpression <> '';
  if FHasPattern then
  begin
    FStartPattern := TRegEx.Create(AStartExpression);
    FStartPattern.IsMatch('');
  end;
  FMaxLines := Max(1, AMaxLines);
  FMaxChars := Max(1024, AMaxChars);
  FLines.Clear;
end;

function TNimbusLogMultilineAssembler.AddLine(const ALine: string; out ACompletedRecord: string): Boolean;
var StartsNew: Boolean;
begin
  ACompletedRecord := '';
  StartsNew := FHasPattern and FStartPattern.IsMatch(ALine);
  Result := StartsNew and (FLines.Count > 0);
  if Result then
  begin
    ACompletedRecord := FLines.Text.TrimRight([#13, #10]);
    FLines.Clear;
  end;
  if (FLines.Count >= FMaxLines) or (FLines.Text.Length + ALine.Length > FMaxChars) then
  begin
    if not Result then begin ACompletedRecord := FLines.Text.TrimRight([#13, #10]); Result := ACompletedRecord <> ''; end;
    FLines.Clear;
  end;
  FLines.Add(ALine);
end;

function TNimbusLogMultilineAssembler.Flush(out ACompletedRecord: string): Boolean;
begin
  ACompletedRecord := FLines.Text.TrimRight([#13, #10]);
  Result := ACompletedRecord <> '';
  FLines.Clear;
end;

initialization
  StandardParserLock := TObject.Create;
  StandardParser := TNimbusLogParserChain.CreateStandard;

finalization
  StandardParser.Free;
  StandardParserLock.Free;

end.

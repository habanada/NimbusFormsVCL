unit NimbusForms.Controls.LogViewer.Structured;

interface

uses System.SysUtils, System.Classes, System.Generics.Collections, System.Generics.Defaults,
  NimbusForms.Controls.LogViewer.Types;

type
  TNimbusLogExceptionInfo = class
  private
    FTypeName: string;
    FMessage: string;
    FStackTrace: string;
    FStackFrames: TStringList;
    FInnerException: TNimbusLogExceptionInfo;
  public
    constructor Create;
    destructor Destroy; override;
    property TypeName: string read FTypeName write FTypeName;
    property Message: string read FMessage write FMessage;
    property StackTrace: string read FStackTrace write FStackTrace;
    property StackFrames: TStringList read FStackFrames;
    property InnerException: TNimbusLogExceptionInfo read FInnerException write FInnerException;
  end;

  TNimbusStructuredLogEntry = class
  private
    FSequence: UInt64;
    FTimestamp: TDateTime;
    FTimestampUtc: TDateTime;
    FHasTimestamp: Boolean;
    FLevel: TNimbusLogLevel;
    FOriginalLevel: string;
    FMessageTemplate: string;
    FRenderedMessage: string;
    FOriginalText: string;
    FLoggerName: string;
    FSourceContext: string;
    FCategory: string;
    FThreadID: Int64;
    FHasThreadID: Boolean;
    FThreadName: string;
    FProcessID: Int64;
    FHasProcessID: Boolean;
    FProcessName: string;
    FTraceID: string;
    FSpanID: string;
    FCorrelationID: string;
    FProviderName: string;
    FSourceName: string;
    FFileName: string;
    FException: TNimbusLogExceptionInfo;
    FProperties: TDictionary<string, string>;
  public
    constructor Create;
    destructor Destroy; override;
    function DisplayText: string;
    function ResolveField(const AFieldPath: string; out AValue: string): Boolean;
    procedure SetThreadID(const AValue: Int64);
    procedure SetProcessID(const AValue: Int64);
    procedure AddProperty(const AName, AValue: string);
    property Sequence: UInt64 read FSequence write FSequence;
    property Timestamp: TDateTime read FTimestamp write FTimestamp;
    property TimestampUtc: TDateTime read FTimestampUtc write FTimestampUtc;
    property HasTimestamp: Boolean read FHasTimestamp write FHasTimestamp;
    property Level: TNimbusLogLevel read FLevel write FLevel;
    property OriginalLevel: string read FOriginalLevel write FOriginalLevel;
    property MessageTemplate: string read FMessageTemplate write FMessageTemplate;
    property RenderedMessage: string read FRenderedMessage write FRenderedMessage;
    property OriginalText: string read FOriginalText write FOriginalText;
    property LoggerName: string read FLoggerName write FLoggerName;
    property SourceContext: string read FSourceContext write FSourceContext;
    property Category: string read FCategory write FCategory;
    property ThreadID: Int64 read FThreadID;
    property HasThreadID: Boolean read FHasThreadID;
    property ThreadName: string read FThreadName write FThreadName;
    property ProcessID: Int64 read FProcessID;
    property HasProcessID: Boolean read FHasProcessID;
    property ProcessName: string read FProcessName write FProcessName;
    property TraceID: string read FTraceID write FTraceID;
    property SpanID: string read FSpanID write FSpanID;
    property CorrelationID: string read FCorrelationID write FCorrelationID;
    property ProviderName: string read FProviderName write FProviderName;
    property SourceName: string read FSourceName write FSourceName;
    property FileName: string read FFileName write FFileName;
    property ExceptionInfo: TNimbusLogExceptionInfo read FException write FException;
    property Properties: TDictionary<string, string> read FProperties;
  end;

function NimbusLogLevelText(const ALevel: TNimbusLogLevel): string;

implementation

uses System.DateUtils, System.StrUtils;

function NimbusLogLevelText(const ALevel: TNimbusLogLevel): string;
begin
  case ALevel of
    nllTrace: Result := 'Trace';
    nllDebug: Result := 'Debug';
    nllInfo: Result := 'Info';
    nllSuccess: Result := 'Success';
    nllWarning: Result := 'Warning';
    nllError: Result := 'Error';
    nllFatal: Result := 'Fatal';
  else Result := 'Unknown';
  end;
end;

constructor TNimbusLogExceptionInfo.Create;
begin
  inherited Create;
  FStackFrames := TStringList.Create;
end;

destructor TNimbusLogExceptionInfo.Destroy;
begin
  FInnerException.Free;
  FStackFrames.Free;
  inherited;
end;

constructor TNimbusStructuredLogEntry.Create;
begin
  inherited Create;
  FLevel := nllUnknown;
  FProperties := TDictionary<string, string>.Create(TIStringComparer.Ordinal);
end;

destructor TNimbusStructuredLogEntry.Destroy;
begin
  FException.Free;
  FProperties.Free;
  inherited;
end;

function TNimbusStructuredLogEntry.DisplayText: string;
begin
  Result := FRenderedMessage;
  if Result = '' then Result := FMessageTemplate;
  if Result = '' then Result := FOriginalText;
end;

procedure TNimbusStructuredLogEntry.SetThreadID(const AValue: Int64);
begin
  FThreadID := AValue;
  FHasThreadID := True;
end;

procedure TNimbusStructuredLogEntry.SetProcessID(const AValue: Int64);
begin
  FProcessID := AValue;
  FHasProcessID := True;
end;

procedure TNimbusStructuredLogEntry.AddProperty(const AName, AValue: string);
begin
  if AName = '' then Exit;
  FProperties.AddOrSetValue(AName, AValue);
end;

function TNimbusStructuredLogEntry.ResolveField(const AFieldPath: string; out AValue: string): Boolean;
var Name: string;
begin
  Result := True;
  Name := Trim(AFieldPath);
  if SameText(Name, 'Sequence') then AValue := UIntToStr(FSequence)
  else if SameText(Name, 'Timestamp') then begin if not FHasTimestamp then Exit(False); AValue := DateToISO8601(FTimestamp, False); end
  else if SameText(Name, 'TimestampUtc') then begin if not FHasTimestamp then Exit(False); AValue := DateToISO8601(FTimestampUtc, True); end
  else if SameText(Name, 'Level') then AValue := NimbusLogLevelText(FLevel)
  else if SameText(Name, 'OriginalLevel') then AValue := FOriginalLevel
  else if SameText(Name, 'Message') then AValue := DisplayText
  else if SameText(Name, 'MessageTemplate') then AValue := FMessageTemplate
  else if SameText(Name, 'Logger') or SameText(Name, 'LoggerName') then AValue := FLoggerName
  else if SameText(Name, 'Source') or SameText(Name, 'SourceContext') then AValue := FSourceContext
  else if SameText(Name, 'Category') then AValue := FCategory
  else if SameText(Name, 'ThreadId') then begin if not FHasThreadID then Exit(False); AValue := IntToStr(FThreadID); end
  else if SameText(Name, 'ThreadName') then AValue := FThreadName
  else if SameText(Name, 'ProcessId') then begin if not FHasProcessID then Exit(False); AValue := IntToStr(FProcessID); end
  else if SameText(Name, 'ProcessName') then AValue := FProcessName
  else if SameText(Name, 'TraceId') then AValue := FTraceID
  else if SameText(Name, 'SpanId') then AValue := FSpanID
  else if SameText(Name, 'CorrelationId') or SameText(Name, 'RequestId') then AValue := FCorrelationID
  else if SameText(Name, 'ProviderName') then AValue := FProviderName
  else if SameText(Name, 'SourceName') then AValue := FSourceName
  else if SameText(Name, 'FileName') then AValue := FFileName
  else if SameText(Name, 'Exception.Type') then begin if FException = nil then Exit(False); AValue := FException.TypeName; end
  else if SameText(Name, 'Exception.Message') then begin if FException = nil then Exit(False); AValue := FException.Message; end
  else if SameText(Name, 'Exception.StackTrace') then begin if FException = nil then Exit(False); AValue := FException.StackTrace; end
  else
  begin
    if StartsText('Properties.', Name) then Delete(Name, 1, Length('Properties.'));
    Result := FProperties.TryGetValue(Name, AValue);
  end;
  if Result and (AValue = '') then
    Result := not (SameText(Name, 'Exception.Type') or SameText(Name, 'Exception.Message') or SameText(Name, 'Exception.StackTrace'));
end;

end.

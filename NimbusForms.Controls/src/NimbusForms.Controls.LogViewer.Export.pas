unit NimbusForms.Controls.LogViewer.Export;

interface

uses System.SysUtils, System.Classes, NimbusForms.Controls.LogViewer.Model,
  NimbusForms.Controls.LogViewer.Structured;

type
  TNimbusLogExportFormat = (nlefText, nlefCSV, nlefJsonLines);

  TNimbusLogExportWriter = class
  private
    FStream: TFileStream;
    FFormat: TNimbusLogExportFormat;
    FFirst: Boolean;
    procedure WriteUTF8(const AText: string);
    class function Csv(const AText: string): string; static;
    class function JsonText(ALine: TNimbusLogLine): string; static;
  public
    constructor Create(const APath: string; const AFormat: TNimbusLogExportFormat);
    destructor Destroy; override;
    procedure WriteLine(ALine: TNimbusLogLine);
  end;

implementation

uses System.JSON, System.DateUtils, System.Generics.Collections,
  NimbusForms.Controls.LogViewer.Types;

constructor TNimbusLogExportWriter.Create(const APath: string; const AFormat: TNimbusLogExportFormat);
var BOM: TBytes;
begin
  inherited Create;
  FStream := TFileStream.Create(APath, fmCreate);
  FFormat := AFormat;
  FFirst := True;
  BOM := TEncoding.UTF8.GetPreamble;
  if Length(BOM) > 0 then FStream.WriteBuffer(BOM[0], Length(BOM));
end;

destructor TNimbusLogExportWriter.Destroy;
begin
  FStream.Free;
  inherited;
end;

procedure TNimbusLogExportWriter.WriteUTF8(const AText: string);
var Bytes: TBytes;
begin
  Bytes := TEncoding.UTF8.GetBytes(AText);
  if Length(Bytes) > 0 then FStream.WriteBuffer(Bytes[0], Length(Bytes));
end;

class function TNimbusLogExportWriter.Csv(const AText: string): string;
begin
  Result := '"' + AText.Replace('"', '""') + '"';
end;

class function TNimbusLogExportWriter.JsonText(ALine: TNimbusLogLine): string;
var E: TNimbusStructuredLogEntry; Obj, Props, Ex: TJSONObject; Pair: TPair<string, string>;
begin
  if ALine = nil then Exit('{}');
  E := ALine.Structured;
  Obj := TJSONObject.Create;
  try
    Obj.AddPair('sequence', UIntToStr(E.Sequence));
    if E.HasTimestamp then
    begin
      Obj.AddPair('timestamp', DateToISO8601(E.Timestamp, False));
      Obj.AddPair('timestampUtc', DateToISO8601(E.TimestampUtc, True));
    end;
    Obj.AddPair('level', NimbusLogLevelText(E.Level));
    if E.OriginalLevel <> '' then Obj.AddPair('originalLevel', E.OriginalLevel);
    if E.MessageTemplate <> '' then Obj.AddPair('messageTemplate', E.MessageTemplate);
    Obj.AddPair('message', E.DisplayText);
    if E.LoggerName <> '' then Obj.AddPair('logger', E.LoggerName);
    if E.SourceContext <> '' then Obj.AddPair('sourceContext', E.SourceContext);
    if E.Category <> '' then Obj.AddPair('category', E.Category);
    if E.HasThreadID then Obj.AddPair('threadId', IntToStr(E.ThreadID));
    if E.ThreadName <> '' then Obj.AddPair('threadName', E.ThreadName);
    if E.HasProcessID then Obj.AddPair('processId', IntToStr(E.ProcessID));
    if E.ProcessName <> '' then Obj.AddPair('processName', E.ProcessName);
    if E.TraceID <> '' then Obj.AddPair('traceId', E.TraceID);
    if E.SpanID <> '' then Obj.AddPair('spanId', E.SpanID);
    if E.CorrelationID <> '' then Obj.AddPair('correlationId', E.CorrelationID);
    if E.Properties.Count > 0 then
    begin
      Props := TJSONObject.Create;
      for Pair in E.Properties do Props.AddPair(Pair.Key, Pair.Value);
      Obj.AddPair('properties', Props);
    end;
    if E.ExceptionInfo <> nil then
    begin
      Ex := TJSONObject.Create;
      if E.ExceptionInfo.TypeName <> '' then Ex.AddPair('type', E.ExceptionInfo.TypeName);
      if E.ExceptionInfo.Message <> '' then Ex.AddPair('message', E.ExceptionInfo.Message);
      if E.ExceptionInfo.StackTrace <> '' then Ex.AddPair('stackTrace', E.ExceptionInfo.StackTrace);
      Obj.AddPair('exception', Ex);
    end;
    Obj.AddPair('raw', ALine.Text);
    Result := Obj.ToJSON;
  finally Obj.Free; end;
end;

procedure TNimbusLogExportWriter.WriteLine(ALine: TNimbusLogLine);
var E: TNimbusStructuredLogEntry; S, Timestamp, ThreadID, ProcessID: string;
begin
  if ALine = nil then Exit;
  case FFormat of
    nlefText:
      WriteUTF8(ALine.Text + sLineBreak);
    nlefCSV:
      begin
        if FFirst then
          WriteUTF8('Timestamp,Level,Logger,Source,ThreadId,ProcessId,TraceId,SpanId,CorrelationId,Message,Raw' + sLineBreak);
        E := ALine.Structured;
        Timestamp := '';
        if E.HasTimestamp then Timestamp := DateToISO8601(E.Timestamp, False);
        ThreadID := '';
        if E.HasThreadID then ThreadID := IntToStr(E.ThreadID);
        ProcessID := '';
        if E.HasProcessID then ProcessID := IntToStr(E.ProcessID);
        S := Csv(Timestamp) + ',' + Csv(NimbusLogLevelText(E.Level)) + ',' + Csv(E.LoggerName) + ',' +
          Csv(E.SourceContext) + ',' + Csv(ThreadID) + ',' + Csv(ProcessID) + ',' + Csv(E.TraceID) + ',' +
          Csv(E.SpanID) + ',' + Csv(E.CorrelationID) + ',' + Csv(E.DisplayText) + ',' + Csv(ALine.Text) + sLineBreak;
        WriteUTF8(S);
      end;
    nlefJsonLines:
      WriteUTF8(JsonText(ALine) + sLineBreak);
  end;
  FFirst := False;
end;

end.

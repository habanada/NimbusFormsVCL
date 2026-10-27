unit NimbusForms.Grid.ClipboardExporter;

interface

uses
  System.SysUtils,
  Winapi.Windows,
  Vcl.Clipbrd,
  NimbusForms.Grid.ExportData,
  NimbusForms.Grid.ExportOptions;

type
  TThemedGridClipboardPayload = record
    Tsv: string;
    Csv: string;
    HtmlClipboardFormat: string;
  end;

  TThemedGridClipboardExporter = class
  private
    class function CreateTsv(const AData: TThemedGridExportData;
      const AOptions: TThemedGridExportOptions): string; static;
    class procedure SetFormat(const AFormat: Word; const AText: string; const AEncoding: TEncoding); static;
  public
    class function CreateHtmlClipboardFragment(const AHtml: string): string; static;
    function CreatePayload(const AData: TThemedGridExportData;
      const AOptions: TThemedGridExportOptions): TThemedGridClipboardPayload;
    procedure CopyToClipboard(const AData: TThemedGridExportData; const AOptions: TThemedGridExportOptions);
  end;

implementation

uses
  NimbusForms.Grid.CsvExporter,
  NimbusForms.Grid.HtmlExporter;

class function TThemedGridClipboardExporter.CreateTsv(const AData: TThemedGridExportData;
  const AOptions: TThemedGridExportOptions): string;
var
  LOptions: TThemedGridExportOptions;
  LExporter: TThemedGridCsvExporter;
begin
  if AOptions <> nil then
    LOptions := AOptions.Clone
  else
    LOptions := TThemedGridExportOptions.Create;
  LExporter := TThemedGridCsvExporter.Create;
  try
    LOptions.CsvDelimiter := #9;
    Result := LExporter.Export(AData, LOptions);
  finally
    LExporter.Free;
    LOptions.Free;
  end;
end;

class function TThemedGridClipboardExporter.CreateHtmlClipboardFragment(const AHtml: string): string;
const
  CPrefix = 'Version:0.9'#13#10'StartHTML:0000000000'#13#10'EndHTML:0000000000'#13#10 +
    'StartFragment:0000000000'#13#10'EndFragment:0000000000'#13#10;
  CStartFragment = '<!--StartFragment-->';
  CEndFragment = '<!--EndFragment-->';
var
  LDocument, LFull: string;
  LStartHtml, LEndHtml, LStartFragment, LEndFragment: Integer;
begin
  LDocument := '<html><body>' + CStartFragment + AHtml + CEndFragment + '</body></html>';
  LFull := CPrefix + LDocument;

  LStartHtml := TEncoding.UTF8.GetByteCount(CPrefix);
  LEndHtml := TEncoding.UTF8.GetByteCount(LFull);
  LStartFragment := TEncoding.UTF8.GetByteCount(CPrefix + '<html><body>' + CStartFragment);
  LEndFragment := TEncoding.UTF8.GetByteCount(CPrefix + '<html><body>' + CStartFragment + AHtml);

  Result := 'Version:0.9'#13#10 +
    'StartHTML:' + Format('%.10d', [LStartHtml]) + #13#10 +
    'EndHTML:' + Format('%.10d', [LEndHtml]) + #13#10 +
    'StartFragment:' + Format('%.10d', [LStartFragment]) + #13#10 +
    'EndFragment:' + Format('%.10d', [LEndFragment]) + #13#10 +
    LDocument;
end;

function TThemedGridClipboardExporter.CreatePayload(const AData: TThemedGridExportData;
  const AOptions: TThemedGridExportOptions): TThemedGridClipboardPayload;
var
  LOptions: TThemedGridExportOptions;
  LCsv: TThemedGridCsvExporter;
  LHtml: TThemedGridHtmlExporter;
begin
  if AOptions <> nil then
    LOptions := AOptions.Clone
  else
    LOptions := TThemedGridExportOptions.Create;
  LCsv := TThemedGridCsvExporter.Create;
  LHtml := TThemedGridHtmlExporter.Create;
  try
    Result.Csv := LCsv.Export(AData, LOptions);
    Result.Tsv := CreateTsv(AData, LOptions);
    Result.HtmlClipboardFormat := CreateHtmlClipboardFragment(LHtml.Export(AData, LOptions));
  finally
    LHtml.Free;
    LCsv.Free;
    LOptions.Free;
  end;
end;

class procedure TThemedGridClipboardExporter.SetFormat(const AFormat: Word; const AText: string;
  const AEncoding: TEncoding);
var
  LBytes: TBytes;
  LLength: Integer;
  LHandle: THandle;
  LTarget: Pointer;
begin
  LBytes := AEncoding.GetBytes(AText);
  LLength := Length(LBytes);
  LHandle := GlobalAlloc(GMEM_MOVEABLE or GMEM_ZEROINIT, LLength + 2);
  if LHandle = 0 then
    RaiseLastOSError;
  LTarget := GlobalLock(LHandle);
  if LTarget = nil then
  begin
    GlobalFree(LHandle);
    RaiseLastOSError;
  end;
  try
    if LLength > 0 then
      Move(LBytes[0], LTarget^, LLength);
  finally
    GlobalUnlock(LHandle);
  end;
  if SetClipboardData(AFormat, LHandle) = 0 then
  begin
    GlobalFree(LHandle);
    RaiseLastOSError;
  end;
end;

procedure TThemedGridClipboardExporter.CopyToClipboard(const AData: TThemedGridExportData;
  const AOptions: TThemedGridExportOptions);
var
  LPayload: TThemedGridClipboardPayload;
begin
  LPayload := CreatePayload(AData, AOptions);
  Clipboard.Open;
  try
    Clipboard.AsText := LPayload.Tsv;
    SetFormat(RegisterClipboardFormat('Csv'), LPayload.Csv, TEncoding.Default);
    SetFormat(RegisterClipboardFormat('HTML Format'), LPayload.HtmlClipboardFormat, TEncoding.UTF8);
  finally
    Clipboard.Close;
  end;
end;

end.

unit NimbusForms.Grid.Export;

interface

uses
  NimbusForms.Grid.ExportData,
  NimbusForms.Grid.ExportOptions,
  NimbusForms.Grid.ClipboardExporter;

type
  TThemedGridExport = class
  public
    class function ToCsv(const AData: TThemedGridExportData;
      const AOptions: TThemedGridExportOptions = nil): string; static;
    class function ToJson(const AData: TThemedGridExportData;
      const AOptions: TThemedGridExportOptions = nil): string; static;
    class function ToHtml(const AData: TThemedGridExportData;
      const AOptions: TThemedGridExportOptions = nil): string; static;
    class function ToClipboardPayload(const AData: TThemedGridExportData;
      const AOptions: TThemedGridExportOptions = nil): TThemedGridClipboardPayload; static;
    class procedure CopyToClipboard(const AData: TThemedGridExportData;
      const AOptions: TThemedGridExportOptions = nil); static;
  end;

implementation

uses
  NimbusForms.Grid.ExportIntf,
  NimbusForms.Grid.CsvExporter,
  NimbusForms.Grid.JsonExporter,
  NimbusForms.Grid.HtmlExporter;

class function TThemedGridExport.ToCsv(const AData: TThemedGridExportData;
  const AOptions: TThemedGridExportOptions): string;
var
  LExporter: IThemedGridDataExporter;
begin
  LExporter := TThemedGridCsvExporter.Create;
  Result := LExporter.Export(AData, AOptions);
end;

class function TThemedGridExport.ToJson(const AData: TThemedGridExportData;
  const AOptions: TThemedGridExportOptions): string;
var
  LExporter: IThemedGridDataExporter;
begin
  LExporter := TThemedGridJsonExporter.Create;
  Result := LExporter.Export(AData, AOptions);
end;

class function TThemedGridExport.ToHtml(const AData: TThemedGridExportData;
  const AOptions: TThemedGridExportOptions): string;
var
  LExporter: IThemedGridDataExporter;
begin
  LExporter := TThemedGridHtmlExporter.Create;
  Result := LExporter.Export(AData, AOptions);
end;

class function TThemedGridExport.ToClipboardPayload(const AData: TThemedGridExportData;
  const AOptions: TThemedGridExportOptions): TThemedGridClipboardPayload;
var
  LExporter: TThemedGridClipboardExporter;
begin
  LExporter := TThemedGridClipboardExporter.Create;
  try
    Result := LExporter.CreatePayload(AData, AOptions);
  finally
    LExporter.Free;
  end;
end;

class procedure TThemedGridExport.CopyToClipboard(const AData: TThemedGridExportData;
  const AOptions: TThemedGridExportOptions);
var
  LExporter: TThemedGridClipboardExporter;
begin
  LExporter := TThemedGridClipboardExporter.Create;
  try
    LExporter.CopyToClipboard(AData, AOptions);
  finally
    LExporter.Free;
  end;
end;

end.

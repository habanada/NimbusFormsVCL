unit NimbusForms.Grid.ExportOptions;

interface

uses
  System.SysUtils;

type
  TThemedGridExportOptions = class
  private
    FIncludeHeaders: Boolean;
    FIncludeHiddenColumns: Boolean;
    FIncludeHiddenRows: Boolean;
    FIncludeRowIndex: Boolean;
    FIncludeGroupRows: Boolean;
    FIncludeDetailRows: Boolean;
    FIncludeTreeIndent: Boolean;
    FCsvDelimiter: string;
    FNewLine: string;
    FNullText: string;
    FTrueText: string;
    FFalseText: string;
    FHtmlTableCssClass: string;
    FHtmlIncludeDocument: Boolean;
    FHtmlEncodeValues: Boolean;
    FJsonIndented: Boolean;
    FEncoding: TEncoding;
  public
    constructor Create;
    function Clone: TThemedGridExportOptions;
    property IncludeHeaders: Boolean read FIncludeHeaders write FIncludeHeaders;
    property IncludeHiddenColumns: Boolean read FIncludeHiddenColumns write FIncludeHiddenColumns;
    property IncludeHiddenRows: Boolean read FIncludeHiddenRows write FIncludeHiddenRows;
    property IncludeRowIndex: Boolean read FIncludeRowIndex write FIncludeRowIndex;
    property IncludeGroupRows: Boolean read FIncludeGroupRows write FIncludeGroupRows;
    property IncludeDetailRows: Boolean read FIncludeDetailRows write FIncludeDetailRows;
    property IncludeTreeIndent: Boolean read FIncludeTreeIndent write FIncludeTreeIndent;
    property CsvDelimiter: string read FCsvDelimiter write FCsvDelimiter;
    property NewLine: string read FNewLine write FNewLine;
    property NullText: string read FNullText write FNullText;
    property TrueText: string read FTrueText write FTrueText;
    property FalseText: string read FFalseText write FFalseText;
    property HtmlTableCssClass: string read FHtmlTableCssClass write FHtmlTableCssClass;
    property HtmlIncludeDocument: Boolean read FHtmlIncludeDocument write FHtmlIncludeDocument;
    property HtmlEncodeValues: Boolean read FHtmlEncodeValues write FHtmlEncodeValues;
    property JsonIndented: Boolean read FJsonIndented write FJsonIndented;
    property Encoding: TEncoding read FEncoding write FEncoding;
  end;

implementation

constructor TThemedGridExportOptions.Create;
begin
  inherited Create;
  FIncludeHeaders := True;
  FIncludeGroupRows := True;
  FIncludeTreeIndent := True;
  FCsvDelimiter := ',';
  FNewLine := #13#10;
  FTrueText := 'true';
  FFalseText := 'false';
  FHtmlTableCssClass := 'nimbus-grid-export';
  FHtmlEncodeValues := True;
  FJsonIndented := True;
  FEncoding := TEncoding.UTF8;
end;

function TThemedGridExportOptions.Clone: TThemedGridExportOptions;
begin
  Result := TThemedGridExportOptions.Create;
  Result.FIncludeHeaders := FIncludeHeaders;
  Result.FIncludeHiddenColumns := FIncludeHiddenColumns;
  Result.FIncludeHiddenRows := FIncludeHiddenRows;
  Result.FIncludeRowIndex := FIncludeRowIndex;
  Result.FIncludeGroupRows := FIncludeGroupRows;
  Result.FIncludeDetailRows := FIncludeDetailRows;
  Result.FIncludeTreeIndent := FIncludeTreeIndent;
  Result.FCsvDelimiter := FCsvDelimiter;
  Result.FNewLine := FNewLine;
  Result.FNullText := FNullText;
  Result.FTrueText := FTrueText;
  Result.FFalseText := FFalseText;
  Result.FHtmlTableCssClass := FHtmlTableCssClass;
  Result.FHtmlIncludeDocument := FHtmlIncludeDocument;
  Result.FHtmlEncodeValues := FHtmlEncodeValues;
  Result.FJsonIndented := FJsonIndented;
  Result.FEncoding := FEncoding;
end;

end.

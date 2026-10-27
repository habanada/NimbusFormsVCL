unit NimbusForms.Grid.CsvExporter;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  NimbusForms.Grid.ExportData,
  NimbusForms.Grid.ExportOptions,
  NimbusForms.Grid.ExportIntf;

type
  TThemedGridCsvExporter = class(TInterfacedObject, IThemedGridDataExporter)
  private
    function GetName: string;
  public
    function Export(const AData: TThemedGridExportData; const AOptions: TThemedGridExportOptions): string;
    class function Escape(const AValue, ADelimiter: string): string; static;
  end;

implementation

uses
  NimbusForms.Grid.ExportSupport;

function TThemedGridCsvExporter.GetName: string;
begin
  Result := 'CSV';
end;

class function TThemedGridCsvExporter.Escape(const AValue, ADelimiter: string): string;
var
  LQuote: Boolean;
begin
  LQuote := (Pos('"', AValue) > 0) or (Pos(#13, AValue) > 0) or (Pos(#10, AValue) > 0) or
    ((ADelimiter <> '') and (Pos(ADelimiter, AValue) > 0));
  if not LQuote then
    Exit(AValue);
  Result := '"' + StringReplace(AValue, '"', '""', [rfReplaceAll]) + '"';
end;

function TThemedGridCsvExporter.Export(const AData: TThemedGridExportData;
  const AOptions: TThemedGridExportOptions): string;
var
  LOptions, LOwnOptions: TThemedGridExportOptions;
  LColumns: TList<TThemedGridExportColumn>;
  LBuilder: TStringBuilder;
  LDelimiter, LNewLine: string;
  I, C: Integer;
  LRow: TThemedGridExportRow;
begin
  if AData = nil then
    Exit('');

  LOwnOptions := nil;
  LOptions := AOptions;
  if LOptions = nil then
  begin
    LOwnOptions := TThemedGridExportOptions.Create;
    LOptions := LOwnOptions;
  end;
  LColumns := TThemedGridExportSupport.GetColumns(AData, LOptions);
  LBuilder := TStringBuilder.Create;
  try
    LDelimiter := LOptions.CsvDelimiter;
    if LDelimiter = '' then
      LDelimiter := ',';
    LNewLine := LOptions.NewLine;

    if LOptions.IncludeHeaders then
    begin
      if LOptions.IncludeRowIndex then
        LBuilder.Append(Escape('#', LDelimiter)).Append(LDelimiter);
      for C := 0 to LColumns.Count - 1 do
      begin
        LBuilder.Append(Escape(LColumns[C].HeaderText, LDelimiter));
        if C < LColumns.Count - 1 then
          LBuilder.Append(LDelimiter);
      end;
      LBuilder.Append(LNewLine);
    end;

    for I := 0 to AData.Rows.Count - 1 do
    begin
      LRow := AData.Rows[I];
      if (LRow = nil) or ((not LRow.Visible) and (not LOptions.IncludeHiddenRows)) then
        Continue;

      if LOptions.IncludeRowIndex then
      begin
        LBuilder.Append(Escape(IntToStr(LRow.Index), LDelimiter));
        if LColumns.Count > 0 then
          LBuilder.Append(LDelimiter);
      end;

      for C := 0 to LColumns.Count - 1 do
      begin
        LBuilder.Append(Escape(TThemedGridExportSupport.GetCellText(
          TThemedGridExportSupport.GetCell(LRow, LColumns[C], C), LOptions), LDelimiter));
        if C < LColumns.Count - 1 then
          LBuilder.Append(LDelimiter);
      end;
      LBuilder.Append(LNewLine);
    end;

    Result := LBuilder.ToString;
  finally
    LBuilder.Free;
    LColumns.Free;
    LOwnOptions.Free;
  end;
end;

end.

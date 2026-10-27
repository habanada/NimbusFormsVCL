unit NimbusForms.Grid.HtmlExporter;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  NimbusForms.Grid.ExportData,
  NimbusForms.Grid.ExportOptions,
  NimbusForms.Grid.ExportIntf;

type
  TThemedGridHtmlExporter = class(TInterfacedObject, IThemedGridDataExporter)
  private
    function GetName: string;
    class procedure AppendCell(const ABuilder: TStringBuilder; const ATag, AValue: string;
      const AOptions: TThemedGridExportOptions); static;
  public
    function Export(const AData: TThemedGridExportData; const AOptions: TThemedGridExportOptions): string;
    class function HtmlEncode(const AValue: string): string; static;
  end;

implementation

uses
  NimbusForms.Grid.ExportSupport;

function TThemedGridHtmlExporter.GetName: string;
begin
  Result := 'HTML';
end;

class function TThemedGridHtmlExporter.HtmlEncode(const AValue: string): string;
var
  LBuilder: TStringBuilder;
  I: Integer;
  LChar: Char;
begin
  if AValue = '' then
    Exit('');
  LBuilder := TStringBuilder.Create(Length(AValue));
  try
    for I := 1 to Length(AValue) do
    begin
      LChar := AValue[I];
      case LChar of
        '&': LBuilder.Append('&amp;');
        '<': LBuilder.Append('&lt;');
        '>': LBuilder.Append('&gt;');
        '"': LBuilder.Append('&quot;');
        '''': LBuilder.Append('&#39;');
      else
        LBuilder.Append(LChar);
      end;
    end;
    Result := LBuilder.ToString;
  finally
    LBuilder.Free;
  end;
end;

class procedure TThemedGridHtmlExporter.AppendCell(const ABuilder: TStringBuilder; const ATag, AValue: string;
  const AOptions: TThemedGridExportOptions);
begin
  ABuilder.Append('<').Append(ATag).Append('>');
  if AOptions.HtmlEncodeValues then
    ABuilder.Append(HtmlEncode(AValue))
  else
    ABuilder.Append(AValue);
  ABuilder.Append('</').Append(ATag).Append('>').Append(sLineBreak);
end;

function TThemedGridHtmlExporter.Export(const AData: TThemedGridExportData;
  const AOptions: TThemedGridExportOptions): string;
var
  LOptions, LOwnOptions: TThemedGridExportOptions;
  LColumns: TList<TThemedGridExportColumn>;
  LBuilder: TStringBuilder;
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
    if LOptions.HtmlIncludeDocument then
    begin
      LBuilder.AppendLine('<!DOCTYPE html>');
      LBuilder.AppendLine('<html>');
      LBuilder.AppendLine('<head>');
      LBuilder.AppendLine('<meta charset="utf-8" />');
      LBuilder.AppendLine('<style>');
      LBuilder.AppendLine('.nimbus-grid-export{border-collapse:collapse;font-family:Segoe UI,Arial,sans-serif;font-size:12px;}');
      LBuilder.AppendLine('.nimbus-grid-export th,.nimbus-grid-export td{border:1px solid #d0d0d0;padding:4px 8px;text-align:left;white-space:nowrap;}');
      LBuilder.AppendLine('.nimbus-grid-export th{background:#f2f2f2;font-weight:600;}');
      LBuilder.AppendLine('</style>');
      LBuilder.AppendLine('</head>');
      LBuilder.AppendLine('<body>');
    end;

    LBuilder.Append('<table');
    if LOptions.HtmlTableCssClass <> '' then
      LBuilder.Append(' class="').Append(HtmlEncode(LOptions.HtmlTableCssClass)).Append('"');
    LBuilder.AppendLine('>');

    if LOptions.IncludeHeaders then
    begin
      LBuilder.AppendLine('<thead>');
      LBuilder.AppendLine('<tr>');
      if LOptions.IncludeRowIndex then
        AppendCell(LBuilder, 'th', '#', LOptions);
      for C := 0 to LColumns.Count - 1 do
        AppendCell(LBuilder, 'th', LColumns[C].HeaderText, LOptions);
      LBuilder.AppendLine('</tr>');
      LBuilder.AppendLine('</thead>');
    end;

    LBuilder.AppendLine('<tbody>');
    for I := 0 to AData.Rows.Count - 1 do
    begin
      LRow := AData.Rows[I];
      if (LRow = nil) or ((not LRow.Visible) and (not LOptions.IncludeHiddenRows)) then
        Continue;
      LBuilder.AppendLine('<tr>');
      if LOptions.IncludeRowIndex then
        AppendCell(LBuilder, 'td', IntToStr(LRow.Index), LOptions);
      for C := 0 to LColumns.Count - 1 do
        AppendCell(LBuilder, 'td', TThemedGridExportSupport.GetCellText(
          TThemedGridExportSupport.GetCell(LRow, LColumns[C], C), LOptions), LOptions);
      LBuilder.AppendLine('</tr>');
    end;
    LBuilder.AppendLine('</tbody>');
    LBuilder.AppendLine('</table>');

    if LOptions.HtmlIncludeDocument then
    begin
      LBuilder.AppendLine('</body>');
      LBuilder.AppendLine('</html>');
    end;

    Result := LBuilder.ToString;
  finally
    LBuilder.Free;
    LColumns.Free;
    LOwnOptions.Free;
  end;
end;

end.

unit NimbusForms.Grid.JsonExporter;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  NimbusForms.Grid.ExportData,
  NimbusForms.Grid.ExportOptions,
  NimbusForms.Grid.ExportIntf;

type
  TThemedGridJsonExporter = class(TInterfacedObject, IThemedGridDataExporter)
  private
    function GetName: string;
    class function EscapeJson(const AValue: string): string; static;
    class procedure AppendProperty(const ABuilder: TStringBuilder; const AIndent, AName, AValue: string;
      var AFirstProperty: Boolean; const ANewLine, ASpace: string); static;
  public
    function Export(const AData: TThemedGridExportData; const AOptions: TThemedGridExportOptions): string;
  end;

implementation

uses
  NimbusForms.Grid.ExportSupport;

function TThemedGridJsonExporter.GetName: string;
begin
  Result := 'JSON';
end;

class function TThemedGridJsonExporter.EscapeJson(const AValue: string): string;
var
  LBuilder: TStringBuilder;
  I: Integer;
  LChar: Char;
begin
  if AValue = '' then
    Exit('');
  LBuilder := TStringBuilder.Create(Length(AValue) + 8);
  try
    for I := 1 to Length(AValue) do
    begin
      LChar := AValue[I];
      if LChar = '\' then
        LBuilder.Append('\\')
      else if LChar = '"' then
        LBuilder.Append('\"')
      else if LChar = #13 then
        LBuilder.Append('\r')
      else if LChar = #10 then
        LBuilder.Append('\n')
      else if LChar = #9 then
        LBuilder.Append('\t')
      else if Ord(LChar) < 32 then
        LBuilder.Append('\u').Append(IntToHex(Ord(LChar), 4))
      else
        LBuilder.Append(LChar);
    end;
    Result := LBuilder.ToString;
  finally
    LBuilder.Free;
  end;
end;

class procedure TThemedGridJsonExporter.AppendProperty(const ABuilder: TStringBuilder;
  const AIndent, AName, AValue: string; var AFirstProperty: Boolean; const ANewLine, ASpace: string);
begin
  if not AFirstProperty then
    ABuilder.Append(',').Append(ANewLine);
  AFirstProperty := False;
  ABuilder.Append(AIndent).Append('"').Append(EscapeJson(AName)).Append('":').Append(ASpace)
    .Append('"').Append(EscapeJson(AValue)).Append('"');
end;

function TThemedGridJsonExporter.Export(const AData: TThemedGridExportData;
  const AOptions: TThemedGridExportOptions): string;
var
  LOptions, LOwnOptions: TThemedGridExportOptions;
  LColumns: TList<TThemedGridExportColumn>;
  LBuilder: TStringBuilder;
  LIndent, LRowIndent, LNewLine, LSpace: string;
  LFirstRow, LFirstProperty: Boolean;
  I, C: Integer;
  LRow: TThemedGridExportRow;
begin
  if AData = nil then
    Exit('[]');

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
    if LOptions.JsonIndented then
    begin
      LIndent := '  ';
      LRowIndent := '    ';
      LNewLine := #13#10;
      LSpace := ' ';
    end
    else
    begin
      LIndent := '';
      LRowIndent := '';
      LNewLine := '';
      LSpace := '';
    end;

    LBuilder.Append('[').Append(LNewLine);
    LFirstRow := True;
    for I := 0 to AData.Rows.Count - 1 do
    begin
      LRow := AData.Rows[I];
      if (LRow = nil) or ((not LRow.Visible) and (not LOptions.IncludeHiddenRows)) then
        Continue;

      if not LFirstRow then
        LBuilder.Append(',').Append(LNewLine);
      LFirstRow := False;

      LBuilder.Append(LIndent).Append('{').Append(LNewLine);
      LFirstProperty := True;
      if LOptions.IncludeRowIndex then
        AppendProperty(LBuilder, LRowIndent, '#', IntToStr(LRow.Index), LFirstProperty, LNewLine, LSpace);
      for C := 0 to LColumns.Count - 1 do
        AppendProperty(LBuilder, LRowIndent, LColumns[C].HeaderText,
          TThemedGridExportSupport.GetCellText(TThemedGridExportSupport.GetCell(LRow, LColumns[C], C), LOptions),
          LFirstProperty, LNewLine, LSpace);
      LBuilder.Append(LNewLine).Append(LIndent).Append('}');
    end;
    LBuilder.Append(LNewLine).Append(']');
    Result := LBuilder.ToString;
  finally
    LBuilder.Free;
    LColumns.Free;
    LOwnOptions.Free;
  end;
end;

end.

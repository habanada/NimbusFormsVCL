program Phase3Test;

{$APPTYPE CONSOLE}

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  System.Rtti,
  System.Generics.Collections,
  Vcl.Graphics,
  NimbusForms.Theming.Types in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.Types.pas',
  NimbusForms.Theming.Palette in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.Palette.pas',
  NimbusForms.Theming.Strings in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.Strings.pas',
  NimbusForms.Theming.WinVersion in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.WinVersion.pas',
  NimbusForms.Theming.Win32 in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.Win32.pas',
  NimbusForms.Theming.PresetFactory in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.PresetFactory.pas',
  NimbusForms.Theming.Serializer in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.Serializer.pas',
  NimbusForms.Theming.Presets in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.Presets.pas',
  NimbusForms.Theming.Manager in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.Manager.pas',
  NimbusForms.Grid.Cell in '..\src\NimbusForms.Grid.Cell.pas',
  NimbusForms.Grid.CellMetadata in '..\src\NimbusForms.Grid.CellMetadata.pas',
  NimbusForms.Grid.CellRenderer in '..\src\NimbusForms.Grid.CellRenderer.pas',
  NimbusForms.Grid.CellRendererIntf in '..\src\NimbusForms.Grid.CellRendererIntf.pas',
  NimbusForms.Grid.CellRendererParts in '..\src\NimbusForms.Grid.CellRendererParts.pas',
  NimbusForms.Grid.CellRenderers in '..\src\NimbusForms.Grid.CellRenderers.pas',
  NimbusForms.Grid.CellRenderers.Content in '..\src\NimbusForms.Grid.CellRenderers.Content.pas',
  NimbusForms.Grid.CellRenderers.Input in '..\src\NimbusForms.Grid.CellRenderers.Input.pas',
  NimbusForms.Grid.CellRenderers.Visual in '..\src\NimbusForms.Grid.CellRenderers.Visual.pas',
  NimbusForms.Grid.ClipboardExporter in '..\src\NimbusForms.Grid.ClipboardExporter.pas',
  NimbusForms.Grid.ClipboardOptions in '..\src\NimbusForms.Grid.ClipboardOptions.pas',
  NimbusForms.Grid.ColorValue in '..\src\NimbusForms.Grid.ColorValue.pas',
  NimbusForms.Grid.Column in '..\src\NimbusForms.Grid.Column.pas',
  NimbusForms.Grid.ColumnBand in '..\src\NimbusForms.Grid.ColumnBand.pas',
  NimbusForms.Grid.ColumnBandCollection in '..\src\NimbusForms.Grid.ColumnBandCollection.pas',
  NimbusForms.Grid.ColumnCollection in '..\src\NimbusForms.Grid.ColumnCollection.pas',
  NimbusForms.Grid.CsvExporter in '..\src\NimbusForms.Grid.CsvExporter.pas',
  NimbusForms.Grid.DataControllerBase in '..\src\NimbusForms.Grid.DataControllerBase.pas',
  NimbusForms.Grid.DataControllerIntf in '..\src\NimbusForms.Grid.DataControllerIntf.pas',
  NimbusForms.Grid.DataSetController in '..\src\NimbusForms.Grid.DataSetController.pas',
  NimbusForms.Grid.DataSourceResolver in '..\src\NimbusForms.Grid.DataSourceResolver.pas',
  NimbusForms.Grid.DataStrings in '..\src\NimbusForms.Grid.DataStrings.pas',
  NimbusForms.Grid.DetailOptions in '..\src\NimbusForms.Grid.DetailOptions.pas',
  NimbusForms.Grid.DetailRelation in '..\src\NimbusForms.Grid.DetailRelation.pas',
  NimbusForms.Grid.DetailRelationCollection in '..\src\NimbusForms.Grid.DetailRelationCollection.pas',
  NimbusForms.Grid.DistinctValue in '..\src\NimbusForms.Grid.DistinctValue.pas',
  NimbusForms.Grid.DistinctValueProvider in '..\src\NimbusForms.Grid.DistinctValueProvider.pas',
  NimbusForms.Grid.EditOptions in '..\src\NimbusForms.Grid.EditOptions.pas',
  NimbusForms.Grid.EditorOptions in '..\src\NimbusForms.Grid.EditorOptions.pas',
  NimbusForms.Grid.Events in '..\src\NimbusForms.Grid.Events.pas',
  NimbusForms.Grid.Events.DragDrop in '..\src\NimbusForms.Grid.Events.DragDrop.pas',
  NimbusForms.Grid.Events.Paste in '..\src\NimbusForms.Grid.Events.Paste.pas',
  NimbusForms.Grid.Events.Rows in '..\src\NimbusForms.Grid.Events.Rows.pas',
  NimbusForms.Grid.Export in '..\src\NimbusForms.Grid.Export.pas',
  NimbusForms.Grid.ExportData in '..\src\NimbusForms.Grid.ExportData.pas',
  NimbusForms.Grid.ExportIntf in '..\src\NimbusForms.Grid.ExportIntf.pas',
  NimbusForms.Grid.ExportOptions in '..\src\NimbusForms.Grid.ExportOptions.pas',
  NimbusForms.Grid.ExportSupport in '..\src\NimbusForms.Grid.ExportSupport.pas',
  NimbusForms.Grid.FilterDescriptor in '..\src\NimbusForms.Grid.FilterDescriptor.pas',
  NimbusForms.Grid.FilterEvaluator in '..\src\NimbusForms.Grid.FilterEvaluator.pas',
  NimbusForms.Grid.FormatCondition in '..\src\NimbusForms.Grid.FormatCondition.pas',
  NimbusForms.Grid.FormatConditionCollection in '..\src\NimbusForms.Grid.FormatConditionCollection.pas',
  NimbusForms.Grid.FormatConditionContext in '..\src\NimbusForms.Grid.FormatConditionContext.pas',
  NimbusForms.Grid.FormatConditionEvaluator in '..\src\NimbusForms.Grid.FormatConditionEvaluator.pas',
  NimbusForms.Grid.FormatConditionEvents in '..\src\NimbusForms.Grid.FormatConditionEvents.pas',
  NimbusForms.Grid.FormatConditionModel in '..\src\NimbusForms.Grid.FormatConditionModel.pas',
  NimbusForms.Grid.FormatConditionSerializer in '..\src\NimbusForms.Grid.FormatConditionSerializer.pas',
  NimbusForms.Grid.FormatConditionSetModel in '..\src\NimbusForms.Grid.FormatConditionSetModel.pas',
  NimbusForms.Grid.FormatConditionStrings in '..\src\NimbusForms.Grid.FormatConditionStrings.pas',
  NimbusForms.Grid.FormatConditionTypes in '..\src\NimbusForms.Grid.FormatConditionTypes.pas',
  NimbusForms.Grid.FormatConditionValidation in '..\src\NimbusForms.Grid.FormatConditionValidation.pas',
  NimbusForms.Grid.FormatStyle in '..\src\NimbusForms.Grid.FormatStyle.pas',
  NimbusForms.Grid.FormatStyleModel in '..\src\NimbusForms.Grid.FormatStyleModel.pas',
  NimbusForms.Grid.GdiCache in '..\src\NimbusForms.Grid.GdiCache.pas',
  NimbusForms.Grid.GdiText in '..\src\NimbusForms.Grid.GdiText.pas',
  NimbusForms.Grid.GroupDescriptor in '..\src\NimbusForms.Grid.GroupDescriptor.pas',
  NimbusForms.Grid.GroupDescriptorCollection in '..\src\NimbusForms.Grid.GroupDescriptorCollection.pas',
  NimbusForms.Grid.GroupingOptions in '..\src\NimbusForms.Grid.GroupingOptions.pas',
  NimbusForms.Grid.HeaderRenderer in '..\src\NimbusForms.Grid.HeaderRenderer.pas',
  NimbusForms.Grid.HitInfo in '..\src\NimbusForms.Grid.HitInfo.pas',
  NimbusForms.Grid.HtmlExporter in '..\src\NimbusForms.Grid.HtmlExporter.pas',
  NimbusForms.Grid.InlineEditorGeometry in '..\src\NimbusForms.Grid.InlineEditorGeometry.pas',
  NimbusForms.Grid.JsonExporter in '..\src\NimbusForms.Grid.JsonExporter.pas',
  NimbusForms.Grid.ListDataController in '..\src\NimbusForms.Grid.ListDataController.pas',
  NimbusForms.Grid.MasterDetailStrings in '..\src\NimbusForms.Grid.MasterDetailStrings.pas',
  NimbusForms.Grid.NumericRange in '..\src\NimbusForms.Grid.NumericRange.pas',
  NimbusForms.Grid.Primitives in '..\src\NimbusForms.Grid.Primitives.pas',
  NimbusForms.Grid.RenderContext in '..\src\NimbusForms.Grid.RenderContext.pas',
  NimbusForms.Grid.Renderer in '..\src\NimbusForms.Grid.Renderer.pas',
  NimbusForms.Grid.RenderMetrics in '..\src\NimbusForms.Grid.RenderMetrics.pas',
  NimbusForms.Grid.Row in '..\src\NimbusForms.Grid.Row.pas',
  NimbusForms.Grid.RowList in '..\src\NimbusForms.Grid.RowList.pas',
  NimbusForms.Grid.RowView in '..\src\NimbusForms.Grid.RowView.pas',
  NimbusForms.Grid.RowViewBuilder in '..\src\NimbusForms.Grid.RowViewBuilder.pas',
  NimbusForms.Grid.SearchEngine in '..\src\NimbusForms.Grid.SearchEngine.pas',
  NimbusForms.Grid.SearchMatch in '..\src\NimbusForms.Grid.SearchMatch.pas',
  NimbusForms.Grid.SearchOptions in '..\src\NimbusForms.Grid.SearchOptions.pas',
  NimbusForms.Grid.SearchResult in '..\src\NimbusForms.Grid.SearchResult.pas',
  NimbusForms.Grid.SelectionModel in '..\src\NimbusForms.Grid.SelectionModel.pas',
  NimbusForms.Grid.SelectionOptions in '..\src\NimbusForms.Grid.SelectionOptions.pas',
  NimbusForms.Grid.SelectionRenderer in '..\src\NimbusForms.Grid.SelectionRenderer.pas',
  NimbusForms.Grid.SimpleView in '..\src\NimbusForms.Grid.SimpleView.pas',
  NimbusForms.Grid.StringSet in '..\src\NimbusForms.Grid.StringSet.pas',
  NimbusForms.Grid.Types in '..\src\NimbusForms.Grid.Types.pas',
  NimbusForms.Grid.ValueAccessor in '..\src\NimbusForms.Grid.ValueAccessor.pas',
  NimbusForms.Grid.ValueConverter in '..\src\NimbusForms.Grid.ValueConverter.pas',
  NimbusForms.Grid.ValueFormatter in '..\src\NimbusForms.Grid.ValueFormatter.pas',
  NimbusForms.Grid.ViewRow in '..\src\NimbusForms.Grid.ViewRow.pas';

type
  /// <summary>Minimaler Host: Zeilen x Spalten aus Strings.</summary>
  TMockHost = class(TInterfacedObject, IThemedGridSearchHost, IThemedGridValueSource)
  private
    FColumns: TObjectList<TThemedGridColumn>;
    FRows: TArray<TArray<string>>;
    function GetRowCount: Integer;
    function GetSearchColumns(const AIncludeHiddenColumns: Boolean): TArray<TThemedGridColumn>;
    function TryGetSearchText(const ARowIndex: Integer; const AColumn: TThemedGridColumn;
      out ADisplayText: string; out ADataSourceIndex: Integer): Boolean;
    function GetValue(const ARowIndex: Integer; const AColumnName: string): TValue;
    function GetCacheIdentity: NativeInt;
  public
    constructor Create;
    destructor Destroy; override;
  end;

var
  GFailed: Integer;
  GPassed: Integer;

procedure Check(const ACondition: Boolean; const AName: string);
begin
  if ACondition then
    Inc(GPassed)
  else
  begin
    Inc(GFailed);
    Writeln('FEHLER: ', AName);
  end;
end;

constructor TMockHost.Create;
begin
  inherited Create;
  FColumns := TObjectList<TThemedGridColumn>.Create(True);
  FColumns.Add(TThemedGridColumn.Create('Name', 'Name', 'Name'));
  FColumns.Add(TThemedGridColumn.Create('City', 'City', 'Stadt'));
  SetLength(FRows, 5);
  FRows[0] := TArray<string>.Create('Anna Schmidt', 'Berlin');
  FRows[1] := TArray<string>.Create('Bernd Meier', 'Hamburg');
  FRows[2] := TArray<string>.Create('anna Berg', 'Berlin');
  FRows[3] := TArray<string>.Create('Carl "C" Weiss', 'Koeln, Nord');
  FRows[4] := TArray<string>.Create('', 'Berlin');
end;

destructor TMockHost.Destroy;
begin
  FColumns.Free;
  inherited Destroy;
end;

function TMockHost.GetRowCount: Integer;
begin
  Result := Length(FRows);
end;

function TMockHost.GetSearchColumns(const AIncludeHiddenColumns: Boolean): TArray<TThemedGridColumn>;
var
  I: Integer;
begin
  SetLength(Result, FColumns.Count);
  for I := 0 to FColumns.Count - 1 do
    Result[I] := FColumns[I];
end;

function TMockHost.TryGetSearchText(const ARowIndex: Integer; const AColumn: TThemedGridColumn;
  out ADisplayText: string; out ADataSourceIndex: Integer): Boolean;
begin
  ADisplayText := FRows[ARowIndex][FColumns.IndexOf(AColumn)];
  ADataSourceIndex := ARowIndex;
  Result := True;
end;

function TMockHost.GetValue(const ARowIndex: Integer; const AColumnName: string): TValue;
begin
  if (ARowIndex < 0) or (ARowIndex >= Length(FRows)) then
    Exit(TValue.Empty);
  if SameText(AColumnName, 'City') then
    Result := TValue.From<string>(FRows[ARowIndex][1])
  else
    Result := TValue.From<string>(FRows[ARowIndex][0]);
end;

function TMockHost.GetCacheIdentity: NativeInt;
begin
  Result := NativeInt(Self);
end;

procedure TestSearch;
var
  LHost: TMockHost;
  LIntf: IThemedGridSearchHost;
  LEngine: TThemedGridSearchEngine;
  LOptions: TThemedGridSearchOptions;
  LResults: TObjectList<TThemedGridSearchResult>;
begin
  LHost := TMockHost.Create;
  LIntf := LHost;
  LEngine := TThemedGridSearchEngine.Create;
  LOptions := TThemedGridSearchOptions.Create;
  try
    LResults := LEngine.Search(LIntf, 'anna', LOptions);
    try
      Check(LResults.Count = 2, 'Contains ignoriert Gross/Klein: 2 Treffer');
      Check((LResults.Count = 2) and (LResults[0].RowIndex = 0) and (LResults[1].RowIndex = 2), 'Trefferzeilen 0 und 2');
    finally
      LResults.Free;
    end;

    LOptions.CaseSensitive := True;
    LResults := LEngine.Search(LIntf, 'anna', LOptions);
    try
      Check(LResults.Count = 1, 'CaseSensitive: 1 Treffer');
    finally
      LResults.Free;
    end;

    LOptions.CaseSensitive := False;
    LOptions.Mode := TThemedGridSearchMode.StartsWith;
    LResults := LEngine.Search(LIntf, 'ber', LOptions);
    try
      Check(LResults.Count = 4, 'StartsWith "ber": Bernd + 3x Berlin = 4');
    finally
      LResults.Free;
    end;

    LOptions.Mode := TThemedGridSearchMode.Exact;
    LResults := LEngine.Search(LIntf, 'BERLIN', LOptions);
    try
      Check(LResults.Count = 3, 'Exact BERLIN: 3 Treffer');
    finally
      LResults.Free;
    end;

    LOptions.Mode := TThemedGridSearchMode.TokenContains;
    LResults := LEngine.Search(LIntf, 'schmidt anna', LOptions);
    try
      Check((LResults.Count = 1) and (LResults[0].RowIndex = 0), 'TokenContains: beide Tokens in Zelle');
    finally
      LResults.Free;
    end;

    LOptions.Mode := TThemedGridSearchMode.Contains;
    LOptions.MaxResults := 100;
    LResults := LEngine.Search(LIntf, 'e', LOptions);
    try
      Check(LResults.Count > 0, 'Treffer fuer "e"');
    finally
      LResults.Free;
    end;

    LResults := LEngine.Search(LIntf, '', LOptions);
    try
      Check(LResults.Count = 0, 'leerer Text: keine Treffer');
    finally
      LResults.Free;
    end;

    LResults := LEngine.Search(nil, 'x', nil);
    try
      Check(LResults.Count = 0, 'Host nil: keine Treffer');
    finally
      LResults.Free;
    end;
  finally
    LOptions.Free;
    LEngine.Free;
  end;
end;

function BuildData: TThemedGridExportData;
var
  LRow: TThemedGridExportRow;
  LHidden: TThemedGridExportColumn;
begin
  Result := TThemedGridExportData.Create;
  Result.Title := 'Test';
  Result.AddColumn('name', 'Name');
  Result.AddColumn('note', 'Notiz');
  LHidden := Result.AddColumn('secret', 'Geheim');
  LHidden.Visible := False;
  Result.AddColumn('ok', 'Aktiv');

  LRow := Result.AddRow;
  LRow.AddCell(TValue.From<string>('Anna'), 'Anna').ColumnKey := 'name';
  LRow.AddCell(TValue.From<string>('a,b'), 'a,b').ColumnKey := 'note';
  LRow.AddCell(TValue.From<string>('x'), 'x').ColumnKey := 'secret';
  LRow.AddCell(TValue.From<Boolean>(True), '').ColumnKey := 'ok';

  LRow := Result.AddRow;
  LRow.AddCell(TValue.From<string>('Bob "B"'), 'Bob "B"').ColumnKey := 'name';
  LRow.AddCell(TValue.From<string>('zwei'#13#10'Zeilen'), 'zwei'#13#10'Zeilen').ColumnKey := 'note';
  LRow.AddCell(TValue.From<string>('y'), 'y').ColumnKey := 'secret';
  LRow.AddCell(TValue.From<Boolean>(False), '').ColumnKey := 'ok';

  LRow := Result.AddRow;
  LRow.Visible := False;
  LRow.AddCell(TValue.Empty, '');
end;

procedure TestExport;
var
  LData: TThemedGridExportData;
  LOptions: TThemedGridExportOptions;
  LText: string;
  LPayload: TThemedGridClipboardPayload;
begin
  LData := BuildData;
  try
    LText := TThemedGridExport.ToCsv(LData);
    Check(LText = 'Name,Notiz,Aktiv'#13#10'Anna,"a,b",true'#13#10'"Bob ""B""","zwei'#13#10'Zeilen",false'#13#10, 'CSV Standard');

    LOptions := TThemedGridExportOptions.Create;
    try
      LOptions.CsvDelimiter := ';';
      LOptions.IncludeRowIndex := True;
      LOptions.IncludeHiddenColumns := True;
      LOptions.IncludeHiddenRows := True;
      LText := TThemedGridExport.ToCsv(LData, LOptions);
      Check(Pos('#;Name;Notiz;Geheim;Aktiv', LText) = 1, 'CSV Kopfzeile mit Index/versteckter Spalte');
      Check(Pos('2;;;;', LText) > 0, 'CSV versteckte Zeile mit NullText');

      LOptions.IncludeHeaders := False;
      LOptions.IncludeHiddenColumns := False;
      LOptions.IncludeHiddenRows := False;
      LOptions.IncludeRowIndex := False;
      LOptions.TrueText := 'ja';
      LText := TThemedGridExport.ToCsv(LData, LOptions);
      Check(Pos('Anna;a,b;ja', LText) = 1, 'Hidden-Spalte nicht enthalten, TrueText greift');
    finally
      LOptions.Free;
    end;

    LText := TThemedGridExport.ToJson(LData);
    Check(Pos('"Name": "Anna"', LText) > 0, 'JSON Property');
    Check(Pos('"Notiz": "zwei
Zeilen"', LText) > 0, 'JSON Escape CRLF');
    Check(Pos('"Bob "B""', LText) > 0, 'JSON Escape Anfuehrungszeichen');

    LOptions := TThemedGridExportOptions.Create;
    try
      LOptions.JsonIndented := False;
      LText := TThemedGridExport.ToJson(LData, LOptions);
      Check(Pos('[{"Name":"Anna"', LText) = 1, 'JSON kompakt');
    finally
      LOptions.Free;
    end;

    LText := TThemedGridExport.ToHtml(LData);
    Check(Pos('<table class="nimbus-grid-export">', LText) = 1, 'HTML Tabelle');
    Check(Pos('<td>Bob &quot;B&quot;</td>', LText) > 0, 'HTML Encode');

    LPayload := TThemedGridExport.ToClipboardPayload(LData);
    Check(Pos('Name'#9'Notiz'#9'Aktiv', LPayload.Tsv) = 1, 'TSV Kopfzeile');
    Check(Pos('Version:0.9', LPayload.HtmlClipboardFormat) = 1, 'HTML Format Header');
    Check(Pos('<!--StartFragment-->', LPayload.HtmlClipboardFormat) > 0, 'HTML Format Fragment');

    try
      TThemedGridExport.CopyToClipboard(LData);
      Check(True, 'CopyToClipboard ohne Ausnahme');
    except
      on E: Exception do
        Check(False, 'CopyToClipboard: ' + E.Message);
    end;

    Check(TThemedGridExport.ToCsv(nil) = '', 'ToCsv(nil) leer');
    Check(TThemedGridExport.ToJson(nil) = '[]', 'ToJson(nil) = []');
  finally
    LData.Free;
  end;
end;

procedure TestDistinct;
var
  LHost: TMockHost;
  LIntf: IThemedGridValueSource;
  LColumn: TThemedGridColumn;
  LValues: TObjectList<TThemedGridDistinctValue>;
begin
  LHost := TMockHost.Create;
  LIntf := LHost;
  LColumn := TThemedGridColumn.Create('City', 'City', 'Stadt');
  try
    LValues := TThemedGridDistinctValueProvider.GetValues(LIntf, LColumn, 1, 0, 0);
    try
      Check(LValues.Count = 3, 'Distinct City: Berlin, Hamburg, Koeln');
      Check((LValues.Count = 3) and (LValues[0].DisplayText = 'Berlin') and (LValues[0].Count = 3), 'Berlin 3x, sortiert');
    finally
      LValues.Free;
    end;

    LValues := TThemedGridDistinctValueProvider.GetValues(LIntf, LColumn, 1, 0, 0);
    try
      Check(LValues.Count = 3, 'zweiter Aufruf aus dem Cache');
    finally
      LValues.Free;
    end;

    LValues := TThemedGridDistinctValueProvider.GetValues(LIntf, LColumn, 2, 2, 0);
    try
      Check(LValues.Count = 2, 'MaxScanRows=2: Berlin, Hamburg');
    finally
      LValues.Free;
    end;

    LValues := TThemedGridDistinctValueProvider.GetValues(LIntf, LColumn, 3, 0, 2);
    try
      Check(LValues.Count = 2, 'MaxDistinctCount=2');
    finally
      LValues.Free;
    end;
    TThemedGridDistinctValueProvider.ClearCache;
  finally
    LColumn.Free;
  end;
end;

begin
  try
    TestSearch;
    TestExport;
    TestDistinct;
    Writeln(Format('Phase3Test: %d ok, %d Fehler', [GPassed, GFailed]));
    if GFailed > 0 then
      ExitCode := 1;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      ExitCode := 2;
    end;
  end;
  Writeln('Enter zum Beenden');
  Readln;
end.

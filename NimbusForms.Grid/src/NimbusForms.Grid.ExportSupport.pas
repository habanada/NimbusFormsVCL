unit NimbusForms.Grid.ExportSupport;

{$SCOPEDENUMS ON}

interface

uses
  System.SysUtils,
  System.Rtti,
  System.TypInfo,
  System.Generics.Collections,
  System.Generics.Defaults,
  NimbusForms.Grid.ExportData,
  NimbusForms.Grid.ExportOptions;

type
  TThemedGridExportSupport = class
  public
    class function GetColumns(const AData: TThemedGridExportData;
      const AOptions: TThemedGridExportOptions): TList<TThemedGridExportColumn>; static;
    class function GetCell(const ARow: TThemedGridExportRow; const AColumn: TThemedGridExportColumn;
      const AVisibleColumnIndex: Integer): TThemedGridExportCell; static;
    class function GetCellText(const ACell: TThemedGridExportCell;
      const AOptions: TThemedGridExportOptions): string; static;
  end;

implementation

uses
  NimbusForms.Grid.ValueConverter,
  NimbusForms.Grid.ValueFormatter;

class function TThemedGridExportSupport.GetColumns(const AData: TThemedGridExportData;
  const AOptions: TThemedGridExportOptions): TList<TThemedGridExportColumn>;
var
  I: Integer;
  LColumn: TThemedGridExportColumn;
begin
  Result := TList<TThemedGridExportColumn>.Create;
  if AData = nil then
    Exit;
  for I := 0 to AData.Columns.Count - 1 do
  begin
    LColumn := AData.Columns[I];
    if LColumn = nil then
      Continue;
    if (not LColumn.Visible) and (not AOptions.IncludeHiddenColumns) then
      Continue;
    Result.Add(LColumn);
  end;
  Result.Sort(TComparer<TThemedGridExportColumn>.Construct(
    function(const ALeft, ARight: TThemedGridExportColumn): Integer
    begin
      Result := ALeft.DisplayIndex - ARight.DisplayIndex;
    end));
end;

class function TThemedGridExportSupport.GetCell(const ARow: TThemedGridExportRow;
  const AColumn: TThemedGridExportColumn; const AVisibleColumnIndex: Integer): TThemedGridExportCell;
var
  I: Integer;
  LCell: TThemedGridExportCell;
begin
  Result := nil;
  if (ARow = nil) or (AColumn = nil) then
    Exit;

  if (AVisibleColumnIndex >= 0) and (AVisibleColumnIndex < ARow.Cells.Count) then
  begin
    LCell := ARow.Cells[AVisibleColumnIndex];
    if (LCell <> nil) and ((LCell.ColumnKey = '') or SameText(LCell.ColumnKey, AColumn.Key)) then
      Exit(LCell);
  end;

  for I := 0 to ARow.Cells.Count - 1 do
  begin
    LCell := ARow.Cells[I];
    if (LCell <> nil) and (LCell.ColumnKey <> '') and SameText(LCell.ColumnKey, AColumn.Key) then
      Exit(LCell);
  end;
end;

class function TThemedGridExportSupport.GetCellText(const ACell: TThemedGridExportCell;
  const AOptions: TThemedGridExportOptions): string;
var
  LHandled: Boolean;
begin
  if ACell = nil then
    Exit(AOptions.NullText);
  if ACell.Text <> '' then
    Exit(ACell.Text);
  if TThemedGridValueConverter.IsNull(ACell.Value) then
    Exit(AOptions.NullText);
  if ACell.Value.TypeInfo = System.TypeInfo(Boolean) then
  begin
    if ACell.Value.AsBoolean then
      Exit(AOptions.TrueText)
    else
      Exit(AOptions.FalseText);
  end;
  if ACell.Format <> '' then
  begin
    Result := TThemedGridValueFormatter.FormatByString(ACell.Value, ACell.Format, FormatSettings, LHandled);
    if LHandled then
      Exit;
  end;
  Result := TThemedGridValueConverter.ToText(ACell.Value);
end;

end.

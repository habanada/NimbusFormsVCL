unit NimbusForms.Grid.ExportData;

interface

uses
  System.SysUtils,
  System.DateUtils,
  System.Rtti,
  System.Generics.Collections;

type
  TThemedGridExportColumn = class
  private
    FKey: string;
    FHeaderText: string;
    FVisible: Boolean;
    FDisplayIndex: Integer;
    FWidth: Integer;
    FFormat: string;
  public
    constructor Create;
    property Key: string read FKey write FKey;
    property HeaderText: string read FHeaderText write FHeaderText;
    property Visible: Boolean read FVisible write FVisible;
    property DisplayIndex: Integer read FDisplayIndex write FDisplayIndex;
    property Width: Integer read FWidth write FWidth;
    property Format: string read FFormat write FFormat;
  end;

  TThemedGridExportCell = class
  private
    FColumnKey: string;
    FValue: TValue;
    FText: string;
    FFormat: string;
  public
    constructor Create;
    property ColumnKey: string read FColumnKey write FColumnKey;
    property Value: TValue read FValue write FValue;
    property Text: string read FText write FText;
    property Format: string read FFormat write FFormat;
  end;

  TThemedGridExportRow = class
  private
    FKey: string;
    FIndex: Integer;
    FVisible: Boolean;
    FCells: TObjectList<TThemedGridExportCell>;
  public
    constructor Create;
    destructor Destroy; override;
    function AddCell(const AValue: TValue; const AText: string): TThemedGridExportCell;
    property Key: string read FKey write FKey;
    property Index: Integer read FIndex write FIndex;
    property Visible: Boolean read FVisible write FVisible;
    property Cells: TObjectList<TThemedGridExportCell> read FCells;
  end;

  TThemedGridExportData = class
  private
    FTitle: string;
    FSourceName: string;
    FCreatedUtc: TDateTime;
    FColumns: TObjectList<TThemedGridExportColumn>;
    FRows: TObjectList<TThemedGridExportRow>;
  public
    constructor Create;
    destructor Destroy; override;
    function AddColumn(const AKey, AHeaderText: string): TThemedGridExportColumn;
    function AddRow: TThemedGridExportRow;
    property Title: string read FTitle write FTitle;
    property SourceName: string read FSourceName write FSourceName;
    property CreatedUtc: TDateTime read FCreatedUtc write FCreatedUtc;
    property Columns: TObjectList<TThemedGridExportColumn> read FColumns;
    property Rows: TObjectList<TThemedGridExportRow> read FRows;
  end;

implementation

constructor TThemedGridExportColumn.Create;
begin
  inherited Create;
  FVisible := True;
  FWidth := 100;
end;

constructor TThemedGridExportCell.Create;
begin
  inherited Create;
  FValue := TValue.Empty;
end;

constructor TThemedGridExportRow.Create;
begin
  inherited Create;
  FVisible := True;
  FCells := TObjectList<TThemedGridExportCell>.Create(True);
end;

destructor TThemedGridExportRow.Destroy;
begin
  FCells.Free;
  inherited Destroy;
end;

function TThemedGridExportRow.AddCell(const AValue: TValue; const AText: string): TThemedGridExportCell;
begin
  Result := TThemedGridExportCell.Create;
  Result.Value := AValue;
  Result.Text := AText;
  FCells.Add(Result);
end;

constructor TThemedGridExportData.Create;
begin
  inherited Create;
  FColumns := TObjectList<TThemedGridExportColumn>.Create(True);
  FRows := TObjectList<TThemedGridExportRow>.Create(True);
  FCreatedUtc := TTimeZone.Local.ToUniversalTime(Now);
end;

destructor TThemedGridExportData.Destroy;
begin
  FRows.Free;
  FColumns.Free;
  inherited Destroy;
end;

function TThemedGridExportData.AddColumn(const AKey, AHeaderText: string): TThemedGridExportColumn;
begin
  Result := TThemedGridExportColumn.Create;
  Result.Key := AKey;
  Result.HeaderText := AHeaderText;
  Result.DisplayIndex := FColumns.Count;
  FColumns.Add(Result);
end;

function TThemedGridExportData.AddRow: TThemedGridExportRow;
begin
  Result := TThemedGridExportRow.Create;
  Result.Index := FRows.Count;
  FRows.Add(Result);
end;

end.

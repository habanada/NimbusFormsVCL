unit NimbusForms.Grid.HitInfo;

{$SCOPEDENUMS ON}

interface

uses
  System.Types,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.Row,
  NimbusForms.Grid.Cell;

type
  TThemedGridHitInfo = class
  private
    FHitArea: TThemedGridHitArea;
    FRowIndex: Integer;
    FColumnIndex: Integer;
    FDataSourceIndex: Integer;
    FColumn: TThemedGridColumn;
    FRow: TThemedGridRow;
    FCell: TThemedGridCell;
    FBounds: TRect;
    FLocation: TPoint;
    FOwnedRow: TThemedGridRow;
    FOwnedCell: TThemedGridCell;
    function GetIsCell: Boolean;
    function GetIsGroupRow: Boolean;
    function GetIsDetailRow: Boolean;
    function GetIsColumnHeader: Boolean;
    function GetIsFilterButton: Boolean;
    function GetIsRowHeader: Boolean;
    function GetIsScrollBar: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure OwnRow(const ARow: TThemedGridRow);
    procedure OwnCell(const ACell: TThemedGridCell);
    property HitArea: TThemedGridHitArea read FHitArea write FHitArea;
    property RowIndex: Integer read FRowIndex write FRowIndex;
    property ColumnIndex: Integer read FColumnIndex write FColumnIndex;
    property DataSourceIndex: Integer read FDataSourceIndex write FDataSourceIndex;
    property Column: TThemedGridColumn read FColumn write FColumn;
    property Row: TThemedGridRow read FRow write FRow;
    property Cell: TThemedGridCell read FCell write FCell;
    property Bounds: TRect read FBounds write FBounds;
    property Location: TPoint read FLocation write FLocation;
    property IsCell: Boolean read GetIsCell;
    property IsGroupRow: Boolean read GetIsGroupRow;
    property IsDetailRow: Boolean read GetIsDetailRow;
    property IsColumnHeader: Boolean read GetIsColumnHeader;
    property IsFilterButton: Boolean read GetIsFilterButton;
    property IsRowHeader: Boolean read GetIsRowHeader;
    property IsScrollBar: Boolean read GetIsScrollBar;
  end;

implementation

constructor TThemedGridHitInfo.Create;
begin
  inherited Create;
  FHitArea := TThemedGridHitArea.None;
  FRowIndex := -1;
  FColumnIndex := -1;
  FDataSourceIndex := -1;
  FBounds := TRect.Empty;
  FLocation := TPoint.Zero;
end;

destructor TThemedGridHitInfo.Destroy;
begin
  FOwnedCell.Free;
  FOwnedRow.Free;
  inherited Destroy;
end;

procedure TThemedGridHitInfo.OwnRow(const ARow: TThemedGridRow);
begin
  if FOwnedRow <> ARow then
    FOwnedRow.Free;
  FOwnedRow := ARow;
  FRow := ARow;
end;

procedure TThemedGridHitInfo.OwnCell(const ACell: TThemedGridCell);
begin
  if FOwnedCell <> ACell then
    FOwnedCell.Free;
  FOwnedCell := ACell;
  FCell := ACell;
end;

function TThemedGridHitInfo.GetIsCell: Boolean;
begin
  Result := (FHitArea = TThemedGridHitArea.Cell) and (FRowIndex >= 0) and (FColumnIndex >= 0);
end;

function TThemedGridHitInfo.GetIsGroupRow: Boolean;
begin
  Result := (FHitArea = TThemedGridHitArea.GroupRow) and (FRowIndex >= 0);
end;

function TThemedGridHitInfo.GetIsDetailRow: Boolean;
begin
  Result := (FHitArea = TThemedGridHitArea.DetailRow) and (FRowIndex >= 0);
end;

function TThemedGridHitInfo.GetIsColumnHeader: Boolean;
begin
  Result := (FHitArea = TThemedGridHitArea.ColumnHeader) and (FColumnIndex >= 0);
end;

function TThemedGridHitInfo.GetIsFilterButton: Boolean;
begin
  Result := (FHitArea = TThemedGridHitArea.FilterButton) and (FColumnIndex >= 0);
end;

function TThemedGridHitInfo.GetIsRowHeader: Boolean;
begin
  Result := (FHitArea = TThemedGridHitArea.RowHeader) and (FRowIndex >= 0);
end;

function TThemedGridHitInfo.GetIsScrollBar: Boolean;
begin
  Result := (FHitArea = TThemedGridHitArea.VerticalScrollBar) or
    (FHitArea = TThemedGridHitArea.HorizontalScrollBar) or
    (FHitArea = TThemedGridHitArea.ScrollCorner);
end;

end.

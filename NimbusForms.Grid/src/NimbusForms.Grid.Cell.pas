unit NimbusForms.Grid.Cell;

{$SCOPEDENUMS ON}

interface

uses
  System.Types,
  System.Rtti,
  System.Generics.Collections,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Primitives,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.Row,
  NimbusForms.Grid.CellMetadata,
  NimbusForms.Grid.SearchMatch;

type
  TThemedGridCell = class
  private
    FRowIndex: Integer;
    FColumnIndex: Integer;
    FDataSourceIndex: Integer;
    FColumn: TThemedGridColumn;
    FRow: TThemedGridRow;
    FRowObject: TValue;
    FValue: TValue;
    FDisplayValue: TValue;
    FDisplayText: string;
    FSearchMatches: TList<TThemedGridSearchMatch>;
    FTag: TValue;
    FBounds: TRect;
    FState: TThemedGridCellState;
    FMetadata: TThemedGridCellMetadata;
    FOwnedRow: TThemedGridRow;
    function GetIsValid: Boolean;
    function GetIsCurrent: Boolean;
    function GetIsSelected: Boolean;
    function GetIsHovered: Boolean;
    function GetIsReadOnly: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure OwnRow(const ARow: TThemedGridRow);
    function GetKey: TThemedGridCellKey;
    property RowIndex: Integer read FRowIndex write FRowIndex;
    property ColumnIndex: Integer read FColumnIndex write FColumnIndex;
    property DataSourceIndex: Integer read FDataSourceIndex write FDataSourceIndex;
    property Column: TThemedGridColumn read FColumn write FColumn;
    property Row: TThemedGridRow read FRow write FRow;
    property RowObject: TValue read FRowObject write FRowObject;
    property Value: TValue read FValue write FValue;
    property DisplayValue: TValue read FDisplayValue write FDisplayValue;
    property DisplayText: string read FDisplayText write FDisplayText;
    property SearchMatches: TList<TThemedGridSearchMatch> read FSearchMatches write FSearchMatches;
    property Tag: TValue read FTag write FTag;
    property Bounds: TRect read FBounds write FBounds;
    property State: TThemedGridCellState read FState write FState;
    property Metadata: TThemedGridCellMetadata read FMetadata write FMetadata;
    property IsValid: Boolean read GetIsValid;
    property IsCurrent: Boolean read GetIsCurrent;
    property IsSelected: Boolean read GetIsSelected;
    property IsHovered: Boolean read GetIsHovered;
    property IsReadOnly: Boolean read GetIsReadOnly;
  end;

implementation

constructor TThemedGridCell.Create;
begin
  inherited Create;
  FRowIndex := -1;
  FColumnIndex := -1;
  FDataSourceIndex := -1;
  FBounds := TRect.Empty;
end;

destructor TThemedGridCell.Destroy;
begin
  FOwnedRow.Free;
  inherited Destroy;
end;

procedure TThemedGridCell.OwnRow(const ARow: TThemedGridRow);
begin
  if FOwnedRow <> ARow then
    FOwnedRow.Free;
  FOwnedRow := ARow;
  FRow := ARow;
end;

function TThemedGridCell.GetIsValid: Boolean;
begin
  Result := (FRowIndex >= 0) and (FColumnIndex >= 0) and (FColumn <> nil);
end;

function TThemedGridCell.GetIsCurrent: Boolean;
begin
  Result := TThemedGridCellStateFlag.Current in FState;
end;

function TThemedGridCell.GetIsSelected: Boolean;
begin
  Result := TThemedGridCellStateFlag.Selected in FState;
end;

function TThemedGridCell.GetIsHovered: Boolean;
begin
  Result := TThemedGridCellStateFlag.Hovered in FState;
end;

function TThemedGridCell.GetIsReadOnly: Boolean;
begin
  Result := (TThemedGridCellStateFlag.ReadOnly in FState) or
    ((FColumn <> nil) and FColumn.ReadOnly);
end;

function TThemedGridCell.GetKey: TThemedGridCellKey;
var
  LColumnName: string;
begin
  if FColumn <> nil then
    LColumnName := FColumn.Name
  else
    LColumnName := '';
  Result := TThemedGridCellKey.Create(FDataSourceIndex, LColumnName);
end;

end.

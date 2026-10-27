unit NimbusForms.Grid.Row;

interface

uses
  System.Types,
  System.Rtti;

type
  TThemedGridRow = class
  private
    FRowIndex: Integer;
    FDataSourceIndex: Integer;
    FRowObject: TValue;
    FBounds: TRect;
    FHeight: Integer;
    FTag: TValue;
    FSelected: Boolean;
    FCurrent: Boolean;
    FHovered: Boolean;
    FVisible: Boolean;
    function GetIsValid: Boolean;
  public
    constructor Create;
    property RowIndex: Integer read FRowIndex write FRowIndex;
    property DataSourceIndex: Integer read FDataSourceIndex write FDataSourceIndex;
    property RowObject: TValue read FRowObject write FRowObject;
    property Bounds: TRect read FBounds write FBounds;
    property Height: Integer read FHeight write FHeight;
    property Tag: TValue read FTag write FTag;
    property Selected: Boolean read FSelected write FSelected;
    property Current: Boolean read FCurrent write FCurrent;
    property Hovered: Boolean read FHovered write FHovered;
    property Visible: Boolean read FVisible write FVisible;
    property IsValid: Boolean read GetIsValid;
  end;

implementation

constructor TThemedGridRow.Create;
begin
  inherited Create;
  FRowIndex := -1;
  FDataSourceIndex := -1;
  FBounds := TRect.Empty;
  FHeight := -1;
end;

function TThemedGridRow.GetIsValid: Boolean;
begin
  Result := (FRowIndex >= 0) and (FDataSourceIndex >= 0);
end;

end.

unit NimbusForms.Grid.ViewRow;

{$SCOPEDENUMS ON}

interface

uses
  System.Rtti,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Column;

type
  TThemedGridViewRow = class
  private
    FViewIndex: Integer;
    FDataSourceIndex: Integer;
    FParentDataSourceIndex: Integer;
    FKind: TThemedGridViewRowKind;
    FLevel: Integer;
    FHeight: Integer;
    FVisible: Boolean;
    FExpanded: Boolean;
    FRowObject: TValue;
    FParentRowObject: TValue;
    FKey: TValue;
    FGroupValue: TValue;
    FDisplayText: string;
    FGroupColumnName: string;
    FGroupColumn: TThemedGridColumn;
    FChildCount: Integer;
    FTag: TValue;
    function GetIsDataRow: Boolean;
    function GetIsGroupRow: Boolean;
    function GetIsDetailRow: Boolean;
    function GetCanRenderCells: Boolean;
    function GetCanEditCells: Boolean;
  public
    constructor Create;
    property ViewIndex: Integer read FViewIndex write FViewIndex;
    property DataSourceIndex: Integer read FDataSourceIndex write FDataSourceIndex;
    property ParentDataSourceIndex: Integer read FParentDataSourceIndex write FParentDataSourceIndex;
    property Kind: TThemedGridViewRowKind read FKind write FKind;
    property Level: Integer read FLevel write FLevel;
    property Height: Integer read FHeight write FHeight;
    property Visible: Boolean read FVisible write FVisible;
    property Expanded: Boolean read FExpanded write FExpanded;
    property RowObject: TValue read FRowObject write FRowObject;
    property ParentRowObject: TValue read FParentRowObject write FParentRowObject;
    property Key: TValue read FKey write FKey;
    property GroupValue: TValue read FGroupValue write FGroupValue;
    property DisplayText: string read FDisplayText write FDisplayText;
    property GroupColumnName: string read FGroupColumnName write FGroupColumnName;
    property GroupColumn: TThemedGridColumn read FGroupColumn write FGroupColumn;
    property ChildCount: Integer read FChildCount write FChildCount;
    property Tag: TValue read FTag write FTag;
    property IsDataRow: Boolean read GetIsDataRow;
    property IsGroupRow: Boolean read GetIsGroupRow;
    property IsDetailRow: Boolean read GetIsDetailRow;
    property CanRenderCells: Boolean read GetCanRenderCells;
    property CanEditCells: Boolean read GetCanEditCells;
  end;

implementation

constructor TThemedGridViewRow.Create;
begin
  inherited Create;
  FDataSourceIndex := -1;
  FParentDataSourceIndex := -1;
  FHeight := 24;
  FVisible := True;
  FExpanded := True;
  FDisplayText := '';
  FGroupColumnName := '';
end;

function TThemedGridViewRow.GetIsDataRow: Boolean;
begin
  Result := (FKind = TThemedGridViewRowKind.Data) or (FKind = TThemedGridViewRowKind.TreeNode);
end;

function TThemedGridViewRow.GetIsGroupRow: Boolean;
begin
  Result := (FKind = TThemedGridViewRowKind.GroupHeader) or (FKind = TThemedGridViewRowKind.GroupFooter);
end;

function TThemedGridViewRow.GetIsDetailRow: Boolean;
begin
  Result := FKind = TThemedGridViewRowKind.Detail;
end;

function TThemedGridViewRow.GetCanRenderCells: Boolean;
begin
  Result := GetIsDataRow;
end;

function TThemedGridViewRow.GetCanEditCells: Boolean;
begin
  Result := GetIsDataRow;
end;

end.

unit NimbusForms.Grid.MasterDetailData;

{$SCOPEDENUMS ON}

interface

uses
  System.Rtti,
  System.TypInfo,
  NimbusForms.Grid.DetailItemCollection,
  NimbusForms.Grid.DetailGridColumn,
  NimbusForms.Grid.DetailGridOptions;

type
  TThemedGridMasterDetailData = class
  private
    FRelationName: string;
    FGridDataSource: TValue;
    FEmptyText: string;
    FHandled: Boolean;
    FTag: TValue;
    FItems: TThemedGridDetailItemCollection;
    FGridColumns: TThemedGridDetailGridColumnCollection;
    FGridOptions: TThemedGridDetailGridOptions;
    FAutoColumns: TThemedGridDetailGridColumnCollection;
    FAutoColumnsResolved: Boolean;
    procedure SetRelationName(const AValue: string);
    function GetHasGridData: Boolean;
    function GetHasItems: Boolean;
    function GetHasColumns: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    property RelationName: string read FRelationName write SetRelationName;
    property Items: TThemedGridDetailItemCollection read FItems;
    property GridDataSource: TValue read FGridDataSource write FGridDataSource;
    property GridColumns: TThemedGridDetailGridColumnCollection read FGridColumns;
    property GridOptions: TThemedGridDetailGridOptions read FGridOptions;
    property EmptyText: string read FEmptyText write FEmptyText;
    property Handled: Boolean read FHandled write FHandled;
    property Tag: TValue read FTag write FTag;
    property HasGridData: Boolean read GetHasGridData;
    property HasItems: Boolean read GetHasItems;
    property HasColumns: Boolean read GetHasColumns;
    property AutoColumns: TThemedGridDetailGridColumnCollection read FAutoColumns;
    property AutoColumnsResolved: Boolean read FAutoColumnsResolved write FAutoColumnsResolved;
  end;

implementation

uses
  NimbusForms.Grid.MasterDetailStrings;

constructor TThemedGridMasterDetailData.Create;
begin
  inherited Create;
  FRelationName := ThemedGridMasterDetailStrings.DefaultRelationName;
  FEmptyText := '';
  FItems := TThemedGridDetailItemCollection.Create;
  FGridColumns := TThemedGridDetailGridColumnCollection.Create;
  FGridOptions := TThemedGridDetailGridOptions.Create;
  FAutoColumns := TThemedGridDetailGridColumnCollection.Create;
end;

destructor TThemedGridMasterDetailData.Destroy;
begin
  FAutoColumns.Free;
  FGridOptions.Free;
  FGridColumns.Free;
  FItems.Free;
  inherited Destroy;
end;

procedure TThemedGridMasterDetailData.SetRelationName(const AValue: string);
begin
  if AValue = '' then
    FRelationName := ThemedGridMasterDetailStrings.DefaultRelationName
  else
    FRelationName := AValue;
end;

function TThemedGridMasterDetailData.GetHasGridData: Boolean;
begin
  Result := FGridDataSource.TypeInfo <> nil;
end;

function TThemedGridMasterDetailData.GetHasItems: Boolean;
begin
  Result := FItems.Count > 0;
end;

function TThemedGridMasterDetailData.GetHasColumns: Boolean;
begin
  Result := FGridColumns.Count > 0;
end;

procedure TThemedGridMasterDetailData.Clear;
begin
  FItems.FreeAndClear;
  FGridColumns.Clear;
  FGridDataSource := TValue.Empty;
  FEmptyText := '';
  FHandled := False;
  FTag := TValue.Empty;
  FRelationName := ThemedGridMasterDetailStrings.DefaultRelationName;
  FGridOptions.Reset;
  FAutoColumns.Clear;
  FAutoColumnsResolved := False;
end;

end.

unit NimbusForms.Grid.Events.MasterDetail;

{$SCOPEDENUMS ON}

interface

uses
  System.Types,
  System.Rtti,
  NimbusForms.Grid.Events,
  NimbusForms.Grid.ViewRow,
  NimbusForms.Grid.DetailItem,
  NimbusForms.Grid.DetailItemCollection,
  NimbusForms.Grid.DetailGridColumn,
  NimbusForms.Grid.DetailGridOptions,
  NimbusForms.Grid.DetailGridRowVisual,
  NimbusForms.Grid.DetailGridHitInfo,
  NimbusForms.Grid.MasterDetailData;

type
  TThemedGridMasterDetailDataNeededEventArgs = class sealed(TThemedGridEventArgs)
  private
    FViewRow: TThemedGridViewRow;
    FViewRowIndex: Integer;
    FParentDataSourceIndex: Integer;
    FParentRowObject: TValue;
    FRelationIndex: Integer;
    FRelationName: string;
    FData: TThemedGridMasterDetailData;
    function GetDetailItems: TThemedGridDetailItemCollection;
    function GetDetailGridDataSource: TValue;
    procedure SetDetailGridDataSource(const AValue: TValue);
    function GetDetailGridColumns: TThemedGridDetailGridColumnCollection;
    function GetDetailGridOptions: TThemedGridDetailGridOptions;
    function GetEmptyText: string;
    procedure SetEmptyText(const AValue: string);
    function GetHandled: Boolean;
    procedure SetHandled(const AValue: Boolean);
    function GetTag: TValue;
    procedure SetTag(const AValue: TValue);
  public
    constructor Create(const AViewRow: TThemedGridViewRow; const AViewRowIndex, ARelationIndex: Integer;
      const ARelationName: string);
    destructor Destroy; override;
    function DetachData: TThemedGridMasterDetailData;
    property ViewRow: TThemedGridViewRow read FViewRow;
    property ViewRowIndex: Integer read FViewRowIndex;
    property ParentDataSourceIndex: Integer read FParentDataSourceIndex;
    property ParentRowObject: TValue read FParentRowObject;
    property RelationIndex: Integer read FRelationIndex;
    property RelationName: string read FRelationName;
    property Data: TThemedGridMasterDetailData read FData;
    property DetailItems: TThemedGridDetailItemCollection read GetDetailItems;
    property DetailGridDataSource: TValue read GetDetailGridDataSource write SetDetailGridDataSource;
    property DetailGridColumns: TThemedGridDetailGridColumnCollection read GetDetailGridColumns;
    property DetailGridOptions: TThemedGridDetailGridOptions read GetDetailGridOptions;
    property EmptyText: string read GetEmptyText write SetEmptyText;
    property Handled: Boolean read GetHandled write SetHandled;
    property Tag: TValue read GetTag write SetTag;
  end;

  TThemedGridDetailItemsNeededEventArgs = class sealed(TThemedGridEventArgs)
  private
    FViewRowIndex: Integer;
    FParentDataSourceIndex: Integer;
    FParentRowObject: TValue;
    FBounds: TRect;
    FContentBounds: TRect;
    FDetailText: string;
    FItems: TThemedGridDetailItemCollection;
  public
    constructor Create;
    destructor Destroy; override;
    property ViewRowIndex: Integer read FViewRowIndex write FViewRowIndex;
    property ParentDataSourceIndex: Integer read FParentDataSourceIndex write FParentDataSourceIndex;
    property ParentRowObject: TValue read FParentRowObject write FParentRowObject;
    property Bounds: TRect read FBounds write FBounds;
    property ContentBounds: TRect read FContentBounds write FContentBounds;
    property DetailText: string read FDetailText write FDetailText;
    property Items: TThemedGridDetailItemCollection read FItems;
  end;

  TThemedGridDetailItemEventArgs = class sealed(TThemedGridEventArgs)
  private
    FViewRowIndex: Integer;
    FParentDataSourceIndex: Integer;
    FParentRowObject: TValue;
    FItem: TThemedGridDetailItem;
    FItemKey: string;
    FValue: TValue;
    FNewValue: TValue;
    FHasNewValue: Boolean;
    FBounds: TRect;
    FButton: TThemedGridMouseButtons;
    FClicks: Integer;
    FLocation: TPoint;
    FDelta: Integer;
    FHandled: Boolean;
  public
    property ViewRowIndex: Integer read FViewRowIndex write FViewRowIndex;
    property ParentDataSourceIndex: Integer read FParentDataSourceIndex write FParentDataSourceIndex;
    property ParentRowObject: TValue read FParentRowObject write FParentRowObject;
    property Item: TThemedGridDetailItem read FItem write FItem;
    property ItemKey: string read FItemKey write FItemKey;
    property Value: TValue read FValue write FValue;
    property NewValue: TValue read FNewValue write FNewValue;
    property HasNewValue: Boolean read FHasNewValue write FHasNewValue;
    property Bounds: TRect read FBounds write FBounds;
    property Button: TThemedGridMouseButtons read FButton write FButton;
    property Clicks: Integer read FClicks write FClicks;
    property Location: TPoint read FLocation write FLocation;
    property Delta: Integer read FDelta write FDelta;
    property Handled: Boolean read FHandled write FHandled;
  end;

  TThemedGridDetailItemActionEventArgs = class sealed(TThemedGridEventArgs)
  private
    FViewRowIndex: Integer;
    FParentDataSourceIndex: Integer;
    FParentRowObject: TValue;
    FItem: TThemedGridDetailItem;
    FItemKey: string;
    FValue: TValue;
    FBounds: TRect;
    FButton: TThemedGridMouseButtons;
    FLocation: TPoint;
    FTag: TValue;
    FHandled: Boolean;
  public
    property ViewRowIndex: Integer read FViewRowIndex write FViewRowIndex;
    property ParentDataSourceIndex: Integer read FParentDataSourceIndex write FParentDataSourceIndex;
    property ParentRowObject: TValue read FParentRowObject write FParentRowObject;
    property Item: TThemedGridDetailItem read FItem write FItem;
    property ItemKey: string read FItemKey write FItemKey;
    property Value: TValue read FValue write FValue;
    property Bounds: TRect read FBounds write FBounds;
    property Button: TThemedGridMouseButtons read FButton write FButton;
    property Location: TPoint read FLocation write FLocation;
    property Tag: TValue read FTag write FTag;
    property Handled: Boolean read FHandled write FHandled;
  end;

  TThemedGridDetailItemValueChangingEventArgs = class sealed(TThemedGridEventArgs)
  private
    FViewRowIndex: Integer;
    FParentDataSourceIndex: Integer;
    FParentRowObject: TValue;
    FItem: TThemedGridDetailItem;
    FItemKey: string;
    FOldValue: TValue;
    FNewValue: TValue;
    FBounds: TRect;
    FCancel: Boolean;
  public
    property ViewRowIndex: Integer read FViewRowIndex write FViewRowIndex;
    property ParentDataSourceIndex: Integer read FParentDataSourceIndex write FParentDataSourceIndex;
    property ParentRowObject: TValue read FParentRowObject write FParentRowObject;
    property Item: TThemedGridDetailItem read FItem write FItem;
    property ItemKey: string read FItemKey write FItemKey;
    property OldValue: TValue read FOldValue write FOldValue;
    property NewValue: TValue read FNewValue write FNewValue;
    property Bounds: TRect read FBounds write FBounds;
    property Cancel: Boolean read FCancel write FCancel;
  end;

  TThemedGridDetailItemValueChangedEventArgs = class sealed(TThemedGridEventArgs)
  private
    FViewRowIndex: Integer;
    FParentDataSourceIndex: Integer;
    FParentRowObject: TValue;
    FItem: TThemedGridDetailItem;
    FItemKey: string;
    FOldValue: TValue;
    FNewValue: TValue;
    FBounds: TRect;
  public
    property ViewRowIndex: Integer read FViewRowIndex write FViewRowIndex;
    property ParentDataSourceIndex: Integer read FParentDataSourceIndex write FParentDataSourceIndex;
    property ParentRowObject: TValue read FParentRowObject write FParentRowObject;
    property Item: TThemedGridDetailItem read FItem write FItem;
    property ItemKey: string read FItemKey write FItemKey;
    property OldValue: TValue read FOldValue write FOldValue;
    property NewValue: TValue read FNewValue write FNewValue;
    property Bounds: TRect read FBounds write FBounds;
  end;

  TThemedGridDetailGridRowVisualNeededEventArgs = class sealed(TThemedGridEventArgs)
  private
    FViewRow: TThemedGridViewRow;
    FViewRowIndex: Integer;
    FParentDataSourceIndex: Integer;
    FParentRowObject: TValue;
    FRelationName: string;
    FRelationIndex: Integer;
    FDetailRowIndex: Integer;
    FDetailRowObject: TValue;
    FBounds: TRect;
    FVisual: TThemedGridDetailGridRowVisual;
    FHandled: Boolean;
  public
    constructor Create(const AViewRow: TThemedGridViewRow; const AViewRowIndex, AParentDataSourceIndex: Integer;
      const AParentRowObject: TValue; const ARelationName: string; const ARelationIndex, ADetailRowIndex: Integer;
      const ADetailRowObject: TValue; const ABounds: TRect; const AVisual: TThemedGridDetailGridRowVisual);
    property ViewRow: TThemedGridViewRow read FViewRow;
    property ViewRowIndex: Integer read FViewRowIndex;
    property ParentDataSourceIndex: Integer read FParentDataSourceIndex;
    property ParentRowObject: TValue read FParentRowObject;
    property RelationName: string read FRelationName;
    property RelationIndex: Integer read FRelationIndex;
    property DetailRowIndex: Integer read FDetailRowIndex;
    property DetailRowObject: TValue read FDetailRowObject;
    property Bounds: TRect read FBounds;
    property Visual: TThemedGridDetailGridRowVisual read FVisual;
    property Handled: Boolean read FHandled write FHandled;
  end;

  TThemedGridDetailGridCellMouseEventArgs = class sealed(TThemedGridEventArgs)
  private
    FButton: TThemedGridMouseButtons;
    FClicks: Integer;
    FX: Integer;
    FY: Integer;
    FDelta: Integer;
    FHitInfo: TThemedGridDetailGridHitInfo;
    function GetViewRow: TThemedGridViewRow;
    function GetViewRowIndex: Integer;
    function GetParentDataSourceIndex: Integer;
    function GetParentRowObject: TValue;
    function GetRelationName: string;
    function GetRelationIndex: Integer;
    function GetDetailRowIndex: Integer;
    function GetDetailColumnIndex: Integer;
    function GetDetailRowObject: TValue;
    function GetValue: TValue;
    function GetColumn: TThemedGridDetailGridColumn;
    function GetIsHeader: Boolean;
  public
    constructor Create(const AButton: TThemedGridMouseButtons; const AClicks, AX, AY, ADelta: Integer;
      const AHitInfo: TThemedGridDetailGridHitInfo);
    property Button: TThemedGridMouseButtons read FButton;
    property Clicks: Integer read FClicks;
    property X: Integer read FX;
    property Y: Integer read FY;
    property Delta: Integer read FDelta;
    property HitInfo: TThemedGridDetailGridHitInfo read FHitInfo;
    property ViewRow: TThemedGridViewRow read GetViewRow;
    property ViewRowIndex: Integer read GetViewRowIndex;
    property ParentDataSourceIndex: Integer read GetParentDataSourceIndex;
    property ParentRowObject: TValue read GetParentRowObject;
    property RelationName: string read GetRelationName;
    property RelationIndex: Integer read GetRelationIndex;
    property DetailRowIndex: Integer read GetDetailRowIndex;
    property DetailColumnIndex: Integer read GetDetailColumnIndex;
    property DetailRowObject: TValue read GetDetailRowObject;
    property Value: TValue read GetValue;
    property Column: TThemedGridDetailGridColumn read GetColumn;
    property IsHeader: Boolean read GetIsHeader;
  end;

  TThemedGridMasterDetailDataNeededEvent = procedure(ASender: TObject;
    const AArgs: TThemedGridMasterDetailDataNeededEventArgs) of object;
  TThemedGridDetailItemsNeededEvent = procedure(ASender: TObject;
    const AArgs: TThemedGridDetailItemsNeededEventArgs) of object;
  TThemedGridDetailItemEvent = procedure(ASender: TObject; const AArgs: TThemedGridDetailItemEventArgs) of object;
  TThemedGridDetailItemActionEvent = procedure(ASender: TObject;
    const AArgs: TThemedGridDetailItemActionEventArgs) of object;
  TThemedGridDetailItemValueChangingEvent = procedure(ASender: TObject;
    const AArgs: TThemedGridDetailItemValueChangingEventArgs) of object;
  TThemedGridDetailItemValueChangedEvent = procedure(ASender: TObject;
    const AArgs: TThemedGridDetailItemValueChangedEventArgs) of object;
  TThemedGridDetailGridRowVisualNeededEvent = procedure(ASender: TObject;
    const AArgs: TThemedGridDetailGridRowVisualNeededEventArgs) of object;
  TThemedGridDetailGridCellMouseEvent = procedure(ASender: TObject;
    const AArgs: TThemedGridDetailGridCellMouseEventArgs) of object;

implementation

uses
  NimbusForms.Grid.MasterDetailStrings;

constructor TThemedGridMasterDetailDataNeededEventArgs.Create(const AViewRow: TThemedGridViewRow;
  const AViewRowIndex, ARelationIndex: Integer; const ARelationName: string);
begin
  inherited Create;
  FViewRow := AViewRow;
  FViewRowIndex := AViewRowIndex;
  if AViewRow <> nil then
  begin
    FParentDataSourceIndex := AViewRow.ParentDataSourceIndex;
    FParentRowObject := AViewRow.ParentRowObject;
  end
  else
    FParentDataSourceIndex := -1;
  if ARelationIndex < 0 then
    FRelationIndex := 0
  else
    FRelationIndex := ARelationIndex;
  if ARelationName = '' then
    FRelationName := ThemedGridMasterDetailStrings.DefaultRelationName
  else
    FRelationName := ARelationName;
  FData := TThemedGridMasterDetailData.Create;
  FData.RelationName := FRelationName;
end;

destructor TThemedGridMasterDetailDataNeededEventArgs.Destroy;
begin
  FData.Free;
  inherited Destroy;
end;

function TThemedGridMasterDetailDataNeededEventArgs.DetachData: TThemedGridMasterDetailData;
begin
  Result := FData;
  FData := nil;
end;

function TThemedGridMasterDetailDataNeededEventArgs.GetDetailItems: TThemedGridDetailItemCollection;
begin
  Result := FData.Items;
end;

function TThemedGridMasterDetailDataNeededEventArgs.GetDetailGridDataSource: TValue;
begin
  Result := FData.GridDataSource;
end;

procedure TThemedGridMasterDetailDataNeededEventArgs.SetDetailGridDataSource(const AValue: TValue);
begin
  FData.GridDataSource := AValue;
end;

function TThemedGridMasterDetailDataNeededEventArgs.GetDetailGridColumns: TThemedGridDetailGridColumnCollection;
begin
  Result := FData.GridColumns;
end;

function TThemedGridMasterDetailDataNeededEventArgs.GetDetailGridOptions: TThemedGridDetailGridOptions;
begin
  Result := FData.GridOptions;
end;

function TThemedGridMasterDetailDataNeededEventArgs.GetEmptyText: string;
begin
  Result := FData.EmptyText;
end;

procedure TThemedGridMasterDetailDataNeededEventArgs.SetEmptyText(const AValue: string);
begin
  FData.EmptyText := AValue;
end;

function TThemedGridMasterDetailDataNeededEventArgs.GetHandled: Boolean;
begin
  Result := FData.Handled;
end;

procedure TThemedGridMasterDetailDataNeededEventArgs.SetHandled(const AValue: Boolean);
begin
  FData.Handled := AValue;
end;

function TThemedGridMasterDetailDataNeededEventArgs.GetTag: TValue;
begin
  Result := FData.Tag;
end;

procedure TThemedGridMasterDetailDataNeededEventArgs.SetTag(const AValue: TValue);
begin
  FData.Tag := AValue;
end;

constructor TThemedGridDetailItemsNeededEventArgs.Create;
begin
  inherited Create;
  FItems := TThemedGridDetailItemCollection.Create;
  FViewRowIndex := -1;
  FParentDataSourceIndex := -1;
end;

destructor TThemedGridDetailItemsNeededEventArgs.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

constructor TThemedGridDetailGridRowVisualNeededEventArgs.Create(const AViewRow: TThemedGridViewRow;
  const AViewRowIndex, AParentDataSourceIndex: Integer; const AParentRowObject: TValue; const ARelationName: string;
  const ARelationIndex, ADetailRowIndex: Integer; const ADetailRowObject: TValue; const ABounds: TRect;
  const AVisual: TThemedGridDetailGridRowVisual);
begin
  inherited Create;
  FViewRow := AViewRow;
  FViewRowIndex := AViewRowIndex;
  FParentDataSourceIndex := AParentDataSourceIndex;
  FParentRowObject := AParentRowObject;
  if ARelationName = '' then
    FRelationName := ThemedGridMasterDetailStrings.DefaultRelationName
  else
    FRelationName := ARelationName;
  FRelationIndex := ARelationIndex;
  FDetailRowIndex := ADetailRowIndex;
  FDetailRowObject := ADetailRowObject;
  FBounds := ABounds;
  FVisual := AVisual;
end;

constructor TThemedGridDetailGridCellMouseEventArgs.Create(const AButton: TThemedGridMouseButtons;
  const AClicks, AX, AY, ADelta: Integer; const AHitInfo: TThemedGridDetailGridHitInfo);
begin
  inherited Create;
  FButton := AButton;
  FClicks := AClicks;
  FX := AX;
  FY := AY;
  FDelta := ADelta;
  FHitInfo := AHitInfo;
end;

function TThemedGridDetailGridCellMouseEventArgs.GetViewRow: TThemedGridViewRow;
begin
  if FHitInfo <> nil then
    Result := FHitInfo.ViewRow
  else
    Result := nil;
end;

function TThemedGridDetailGridCellMouseEventArgs.GetViewRowIndex: Integer;
begin
  if FHitInfo <> nil then
    Result := FHitInfo.ViewRowIndex
  else
    Result := -1;
end;

function TThemedGridDetailGridCellMouseEventArgs.GetParentDataSourceIndex: Integer;
begin
  if FHitInfo <> nil then
    Result := FHitInfo.ParentDataSourceIndex
  else
    Result := -1;
end;

function TThemedGridDetailGridCellMouseEventArgs.GetParentRowObject: TValue;
begin
  if FHitInfo <> nil then
    Result := FHitInfo.ParentRowObject
  else
    Result := TValue.Empty;
end;

function TThemedGridDetailGridCellMouseEventArgs.GetRelationName: string;
begin
  if FHitInfo <> nil then
    Result := FHitInfo.RelationName
  else
    Result := ThemedGridMasterDetailStrings.DefaultRelationName;
end;

function TThemedGridDetailGridCellMouseEventArgs.GetRelationIndex: Integer;
begin
  if FHitInfo <> nil then
    Result := FHitInfo.RelationIndex
  else
    Result := 0;
end;

function TThemedGridDetailGridCellMouseEventArgs.GetDetailRowIndex: Integer;
begin
  if FHitInfo <> nil then
    Result := FHitInfo.DetailRowIndex
  else
    Result := -1;
end;

function TThemedGridDetailGridCellMouseEventArgs.GetDetailColumnIndex: Integer;
begin
  if FHitInfo <> nil then
    Result := FHitInfo.DetailColumnIndex
  else
    Result := -1;
end;

function TThemedGridDetailGridCellMouseEventArgs.GetDetailRowObject: TValue;
begin
  if FHitInfo <> nil then
    Result := FHitInfo.DetailRowObject
  else
    Result := TValue.Empty;
end;

function TThemedGridDetailGridCellMouseEventArgs.GetValue: TValue;
begin
  if FHitInfo <> nil then
    Result := FHitInfo.Value
  else
    Result := TValue.Empty;
end;

function TThemedGridDetailGridCellMouseEventArgs.GetColumn: TThemedGridDetailGridColumn;
begin
  if FHitInfo <> nil then
    Result := FHitInfo.Column
  else
    Result := nil;
end;

function TThemedGridDetailGridCellMouseEventArgs.GetIsHeader: Boolean;
begin
  Result := (FHitInfo <> nil) and FHitInfo.IsHeader;
end;

end.

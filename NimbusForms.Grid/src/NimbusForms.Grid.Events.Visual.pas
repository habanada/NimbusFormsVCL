unit NimbusForms.Grid.Events.Visual;

{$SCOPEDENUMS ON}

interface

uses
  System.Types,
  System.Rtti,
  Vcl.Controls,
  NimbusForms.Grid.Events,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.ViewRow,
  NimbusForms.Grid.DetailItem,
  NimbusForms.Grid.DetailGridColumn,
  NimbusForms.Grid.VisualImage,
  NimbusForms.Grid.VisualAction,
  NimbusForms.Grid.CellVisual;

type
  TThemedGridCellVisualNeededEventArgs = class(TThemedGridCellEventArgs)
  private
    FVisual: TThemedGridCellVisual;
    FHandled: Boolean;
    function GetItem: TValue;
  public
    property Item: TValue read GetItem;
    property Visual: TThemedGridCellVisual read FVisual write FVisual;
    property Handled: Boolean read FHandled write FHandled;
  end;

  TThemedGridGroupVisualNeededEventArgs = class sealed(TThemedGridEventArgs)
  private
    FRowIndex: Integer;
    FViewRow: TThemedGridViewRow;
    FLevel: Integer;
    FGroupColumnName: string;
    FGroupColumn: TThemedGridColumn;
    FGroupValue: TValue;
    FChildCount: Integer;
    FExpanded: Boolean;
    FKey: TValue;
    FDisplayText: string;
    FVisual: TThemedGridCellVisual;
    FHandled: Boolean;
  public
    constructor Create(const ARowIndex: Integer; const AViewRow: TThemedGridViewRow;
      const AVisual: TThemedGridCellVisual);
    property RowIndex: Integer read FRowIndex;
    property ViewRow: TThemedGridViewRow read FViewRow;
    property Level: Integer read FLevel;
    property GroupColumnName: string read FGroupColumnName;
    property GroupColumn: TThemedGridColumn read FGroupColumn;
    property GroupValue: TValue read FGroupValue;
    property ChildCount: Integer read FChildCount;
    property Expanded: Boolean read FExpanded;
    property Key: TValue read FKey;
    property DisplayText: string read FDisplayText;
    property Visual: TThemedGridCellVisual read FVisual;
    property Handled: Boolean read FHandled write FHandled;
  end;

  TThemedGridVisualMouseEventArgs = class sealed(TThemedGridEventArgs)
  private
    FHitInfo: TThemedGridVisualHitInfo;
    FButton: TMouseButton;
    FClicks: Integer;
    FLocation: TPoint;
    FHandled: Boolean;
    function GetRowIndex: Integer;
    function GetColumnIndex: Integer;
    function GetVisualIndex: Integer;
    function GetBounds: TRect;
    function GetImage: TThemedVisualImage;
    function GetVisual: TThemedGridCellVisual;
    function GetTag: TValue;
    function GetToolTip: string;
  public
    constructor Create(const AHitInfo: TThemedGridVisualHitInfo; const AButton: TMouseButton;
      const AClicks: Integer; const ALocation: TPoint);
    property HitInfo: TThemedGridVisualHitInfo read FHitInfo;
    property Button: TMouseButton read FButton;
    property Clicks: Integer read FClicks;
    property Location: TPoint read FLocation;
    property Handled: Boolean read FHandled write FHandled;
    property RowIndex: Integer read GetRowIndex;
    property ColumnIndex: Integer read GetColumnIndex;
    property VisualIndex: Integer read GetVisualIndex;
    property Bounds: TRect read GetBounds;
    property Image: TThemedVisualImage read GetImage;
    property Visual: TThemedGridCellVisual read GetVisual;
    property Tag: TValue read GetTag;
    property ToolTip: string read GetToolTip;
  end;

  TThemedGridVisualActionEventArgs = class sealed(TThemedGridEventArgs)
  private
    FHitInfo: TThemedGridVisualHitInfo;
    FButton: TMouseButton;
    FClicks: Integer;
    FLocation: TPoint;
    FHandled: Boolean;
    function GetAction: TThemedGridVisualAction;
    function GetActionKey: string;
    function GetTag: TValue;
    function GetRowIndex: Integer;
    function GetColumnIndex: Integer;
    function GetVisualIndex: Integer;
    function GetBounds: TRect;
    function GetIsGroupHeader: Boolean;
    function GetIsDetail: Boolean;
    function GetHasAction: Boolean;
  public
    constructor Create(const AHitInfo: TThemedGridVisualHitInfo; const AButton: TMouseButton;
      const AClicks: Integer; const ALocation: TPoint);
    property HitInfo: TThemedGridVisualHitInfo read FHitInfo;
    property Button: TMouseButton read FButton;
    property Clicks: Integer read FClicks;
    property Location: TPoint read FLocation;
    property Handled: Boolean read FHandled write FHandled;
    property Action: TThemedGridVisualAction read GetAction;
    property ActionKey: string read GetActionKey;
    property Tag: TValue read GetTag;
    property RowIndex: Integer read GetRowIndex;
    property ColumnIndex: Integer read GetColumnIndex;
    property VisualIndex: Integer read GetVisualIndex;
    property Bounds: TRect read GetBounds;
    property IsGroupHeader: Boolean read GetIsGroupHeader;
    property IsDetail: Boolean read GetIsDetail;
    property HasAction: Boolean read GetHasAction;
  end;

  TThemedGridDetailItemVisualNeededEventArgs = class sealed(TThemedGridEventArgs)
  private
    FViewRowIndex: Integer;
    FViewRow: TThemedGridViewRow;
    FParentDataSourceIndex: Integer;
    FParentRowObject: TValue;
    FItem: TThemedGridDetailItem;
    FItemIndex: Integer;
    FItemKey: string;
    FValue: TValue;
    FText: string;
    FBounds: TRect;
    FVisual: TThemedGridCellVisual;
    FHandled: Boolean;
  public
    constructor Create(const AViewRowIndex: Integer; const AViewRow: TThemedGridViewRow;
      const AItem: TThemedGridDetailItem; const AItemIndex: Integer; const AVisual: TThemedGridCellVisual);
    property ViewRowIndex: Integer read FViewRowIndex;
    property ViewRow: TThemedGridViewRow read FViewRow;
    property ParentDataSourceIndex: Integer read FParentDataSourceIndex;
    property ParentRowObject: TValue read FParentRowObject;
    property Item: TThemedGridDetailItem read FItem;
    property ItemIndex: Integer read FItemIndex;
    property ItemKey: string read FItemKey;
    property Value: TValue read FValue;
    property Text: string read FText;
    property Bounds: TRect read FBounds;
    property Visual: TThemedGridCellVisual read FVisual;
    property Handled: Boolean read FHandled write FHandled;
  end;

  TThemedGridDetailGridCellVisualNeededEventArgs = class sealed(TThemedGridEventArgs)
  private
    FViewRow: TThemedGridViewRow;
    FViewRowIndex: Integer;
    FParentDataSourceIndex: Integer;
    FParentRowObject: TValue;
    FRelationName: string;
    FRelationIndex: Integer;
    FDetailRowIndex: Integer;
    FDetailColumnIndex: Integer;
    FDetailRowObject: TValue;
    FValue: TValue;
    FColumn: TThemedGridDetailGridColumn;
    FBounds: TRect;
    FVisual: TThemedGridCellVisual;
    FHandled: Boolean;
    function GetColumnName: string;
    function GetDataPropertyName: string;
  public
    constructor Create(const AViewRow: TThemedGridViewRow; const AViewRowIndex, AParentDataSourceIndex: Integer;
      const AParentRowObject: TValue; const ARelationName: string; const ARelationIndex, ADetailRowIndex,
      ADetailColumnIndex: Integer; const ADetailRowObject, AValue: TValue;
      const AColumn: TThemedGridDetailGridColumn; const ABounds: TRect; const AVisual: TThemedGridCellVisual);
    property ViewRow: TThemedGridViewRow read FViewRow;
    property ViewRowIndex: Integer read FViewRowIndex;
    property ParentDataSourceIndex: Integer read FParentDataSourceIndex;
    property ParentRowObject: TValue read FParentRowObject;
    property RelationName: string read FRelationName;
    property RelationIndex: Integer read FRelationIndex;
    property DetailRowIndex: Integer read FDetailRowIndex;
    property DetailColumnIndex: Integer read FDetailColumnIndex;
    property DetailRowObject: TValue read FDetailRowObject;
    property Value: TValue read FValue;
    property Column: TThemedGridDetailGridColumn read FColumn;
    property ColumnName: string read GetColumnName;
    property DataPropertyName: string read GetDataPropertyName;
    property Bounds: TRect read FBounds;
    property Visual: TThemedGridCellVisual read FVisual;
    property Handled: Boolean read FHandled write FHandled;
  end;

  TThemedGridDetailGridHeaderVisualNeededEventArgs = class sealed(TThemedGridEventArgs)
  private
    FViewRow: TThemedGridViewRow;
    FViewRowIndex: Integer;
    FParentDataSourceIndex: Integer;
    FParentRowObject: TValue;
    FRelationName: string;
    FRelationIndex: Integer;
    FDetailColumnIndex: Integer;
    FColumn: TThemedGridDetailGridColumn;
    FBounds: TRect;
    FVisual: TThemedGridCellVisual;
    FHandled: Boolean;
    function GetColumnName: string;
    function GetDataPropertyName: string;
    function GetHeaderText: string;
  public
    constructor Create(const AViewRow: TThemedGridViewRow; const AViewRowIndex, AParentDataSourceIndex: Integer;
      const AParentRowObject: TValue; const ARelationName: string; const ARelationIndex,
      ADetailColumnIndex: Integer; const AColumn: TThemedGridDetailGridColumn; const ABounds: TRect;
      const AVisual: TThemedGridCellVisual);
    property ViewRow: TThemedGridViewRow read FViewRow;
    property ViewRowIndex: Integer read FViewRowIndex;
    property ParentDataSourceIndex: Integer read FParentDataSourceIndex;
    property ParentRowObject: TValue read FParentRowObject;
    property RelationName: string read FRelationName;
    property RelationIndex: Integer read FRelationIndex;
    property DetailColumnIndex: Integer read FDetailColumnIndex;
    property Column: TThemedGridDetailGridColumn read FColumn;
    property ColumnName: string read GetColumnName;
    property DataPropertyName: string read GetDataPropertyName;
    property HeaderText: string read GetHeaderText;
    property Bounds: TRect read FBounds;
    property Visual: TThemedGridCellVisual read FVisual;
    property Handled: Boolean read FHandled write FHandled;
  end;

  TThemedGridCellVisualNeededEvent = procedure(ASender: TObject;
    const AArgs: TThemedGridCellVisualNeededEventArgs) of object;
  TThemedGridGroupVisualNeededEvent = procedure(ASender: TObject;
    const AArgs: TThemedGridGroupVisualNeededEventArgs) of object;
  TThemedGridVisualMouseEvent = procedure(ASender: TObject;
    const AArgs: TThemedGridVisualMouseEventArgs) of object;
  TThemedGridVisualActionEvent = procedure(ASender: TObject;
    const AArgs: TThemedGridVisualActionEventArgs) of object;
  TThemedGridDetailItemVisualNeededEvent = procedure(ASender: TObject;
    const AArgs: TThemedGridDetailItemVisualNeededEventArgs) of object;
  TThemedGridDetailGridCellVisualNeededEvent = procedure(ASender: TObject;
    const AArgs: TThemedGridDetailGridCellVisualNeededEventArgs) of object;
  TThemedGridDetailGridHeaderVisualNeededEvent = procedure(ASender: TObject;
    const AArgs: TThemedGridDetailGridHeaderVisualNeededEventArgs) of object;

implementation

uses
  NimbusForms.Grid.MasterDetailStrings;

function TThemedGridCellVisualNeededEventArgs.GetItem: TValue;
begin
  Result := RowObject;
end;

constructor TThemedGridGroupVisualNeededEventArgs.Create(const ARowIndex: Integer;
  const AViewRow: TThemedGridViewRow; const AVisual: TThemedGridCellVisual);
begin
  inherited Create;
  FRowIndex := ARowIndex;
  FViewRow := AViewRow;
  FVisual := AVisual;
  FExpanded := True;
  if AViewRow <> nil then
  begin
    FLevel := AViewRow.Level;
    FGroupColumnName := AViewRow.GroupColumnName;
    FGroupColumn := AViewRow.GroupColumn;
    FGroupValue := AViewRow.GroupValue;
    FChildCount := AViewRow.ChildCount;
    FExpanded := AViewRow.Expanded;
    FKey := AViewRow.Key;
    FDisplayText := AViewRow.DisplayText;
  end;
end;

constructor TThemedGridVisualMouseEventArgs.Create(const AHitInfo: TThemedGridVisualHitInfo;
  const AButton: TMouseButton; const AClicks: Integer; const ALocation: TPoint);
begin
  inherited Create;
  FHitInfo := AHitInfo;
  FButton := AButton;
  FClicks := AClicks;
  FLocation := ALocation;
end;

function TThemedGridVisualMouseEventArgs.GetRowIndex: Integer;
begin
  if FHitInfo <> nil then
    Result := FHitInfo.RowIndex
  else
    Result := -1;
end;

function TThemedGridVisualMouseEventArgs.GetColumnIndex: Integer;
begin
  if FHitInfo <> nil then
    Result := FHitInfo.ColumnIndex
  else
    Result := -1;
end;

function TThemedGridVisualMouseEventArgs.GetVisualIndex: Integer;
begin
  if FHitInfo <> nil then
    Result := FHitInfo.VisualIndex
  else
    Result := -1;
end;

function TThemedGridVisualMouseEventArgs.GetBounds: TRect;
begin
  if FHitInfo <> nil then
    Result := FHitInfo.Bounds
  else
    Result := TRect.Empty;
end;

function TThemedGridVisualMouseEventArgs.GetImage: TThemedVisualImage;
begin
  if FHitInfo <> nil then
    Result := FHitInfo.Image
  else
    Result := nil;
end;

function TThemedGridVisualMouseEventArgs.GetVisual: TThemedGridCellVisual;
begin
  if FHitInfo <> nil then
    Result := FHitInfo.Visual
  else
    Result := nil;
end;

function TThemedGridVisualMouseEventArgs.GetTag: TValue;
begin
  if FHitInfo <> nil then
    Result := FHitInfo.Tag
  else
    Result := TValue.Empty;
end;

function TThemedGridVisualMouseEventArgs.GetToolTip: string;
begin
  if FHitInfo <> nil then
    Result := FHitInfo.ToolTip
  else
    Result := '';
end;

constructor TThemedGridVisualActionEventArgs.Create(const AHitInfo: TThemedGridVisualHitInfo;
  const AButton: TMouseButton; const AClicks: Integer; const ALocation: TPoint);
begin
  inherited Create;
  FHitInfo := AHitInfo;
  FButton := AButton;
  FClicks := AClicks;
  FLocation := ALocation;
end;

function TThemedGridVisualActionEventArgs.GetAction: TThemedGridVisualAction;
begin
  if FHitInfo <> nil then
    Result := FHitInfo.Action
  else
    Result := nil;
end;

function TThemedGridVisualActionEventArgs.GetActionKey: string;
begin
  if GetAction <> nil then
    Result := GetAction.Key
  else
    Result := '';
end;

function TThemedGridVisualActionEventArgs.GetTag: TValue;
begin
  if FHitInfo <> nil then
    Result := FHitInfo.Tag
  else
    Result := TValue.Empty;
end;

function TThemedGridVisualActionEventArgs.GetRowIndex: Integer;
begin
  if FHitInfo <> nil then
    Result := FHitInfo.RowIndex
  else
    Result := -1;
end;

function TThemedGridVisualActionEventArgs.GetColumnIndex: Integer;
begin
  if FHitInfo <> nil then
    Result := FHitInfo.ColumnIndex
  else
    Result := -1;
end;

function TThemedGridVisualActionEventArgs.GetVisualIndex: Integer;
begin
  if FHitInfo <> nil then
    Result := FHitInfo.VisualIndex
  else
    Result := -1;
end;

function TThemedGridVisualActionEventArgs.GetBounds: TRect;
begin
  if FHitInfo <> nil then
    Result := FHitInfo.Bounds
  else
    Result := TRect.Empty;
end;

function TThemedGridVisualActionEventArgs.GetIsGroupHeader: Boolean;
begin
  Result := (FHitInfo <> nil) and FHitInfo.IsGroupHeader;
end;

function TThemedGridVisualActionEventArgs.GetIsDetail: Boolean;
begin
  Result := (FHitInfo <> nil) and FHitInfo.IsDetail;
end;

function TThemedGridVisualActionEventArgs.GetHasAction: Boolean;
begin
  Result := GetAction <> nil;
end;

constructor TThemedGridDetailItemVisualNeededEventArgs.Create(const AViewRowIndex: Integer;
  const AViewRow: TThemedGridViewRow; const AItem: TThemedGridDetailItem; const AItemIndex: Integer;
  const AVisual: TThemedGridCellVisual);
begin
  inherited Create;
  FViewRowIndex := AViewRowIndex;
  FViewRow := AViewRow;
  FParentDataSourceIndex := -1;
  if AViewRow <> nil then
  begin
    FParentDataSourceIndex := AViewRow.ParentDataSourceIndex;
    FParentRowObject := AViewRow.ParentRowObject;
  end;
  FItem := AItem;
  FItemIndex := AItemIndex;
  if AItem <> nil then
  begin
    FItemKey := AItem.Key;
    FValue := AItem.Value;
    FText := AItem.Text;
    FBounds := AItem.Bounds;
  end;
  FVisual := AVisual;
end;

constructor TThemedGridDetailGridCellVisualNeededEventArgs.Create(const AViewRow: TThemedGridViewRow;
  const AViewRowIndex, AParentDataSourceIndex: Integer; const AParentRowObject: TValue;
  const ARelationName: string; const ARelationIndex, ADetailRowIndex, ADetailColumnIndex: Integer;
  const ADetailRowObject, AValue: TValue; const AColumn: TThemedGridDetailGridColumn; const ABounds: TRect;
  const AVisual: TThemedGridCellVisual);
begin
  inherited Create;
  FViewRow := AViewRow;
  FViewRowIndex := AViewRowIndex;
  FParentDataSourceIndex := AParentDataSourceIndex;
  FParentRowObject := AParentRowObject;
  if ARelationName <> '' then
    FRelationName := ARelationName
  else
    FRelationName := ThemedGridMasterDetailStrings.DefaultRelationName;
  FRelationIndex := ARelationIndex;
  FDetailRowIndex := ADetailRowIndex;
  FDetailColumnIndex := ADetailColumnIndex;
  FDetailRowObject := ADetailRowObject;
  FValue := AValue;
  FColumn := AColumn;
  FBounds := ABounds;
  FVisual := AVisual;
end;

function TThemedGridDetailGridCellVisualNeededEventArgs.GetColumnName: string;
begin
  if FColumn <> nil then
    Result := FColumn.Name
  else
    Result := '';
end;

function TThemedGridDetailGridCellVisualNeededEventArgs.GetDataPropertyName: string;
begin
  if FColumn <> nil then
    Result := FColumn.DataPropertyName
  else
    Result := '';
end;

constructor TThemedGridDetailGridHeaderVisualNeededEventArgs.Create(const AViewRow: TThemedGridViewRow;
  const AViewRowIndex, AParentDataSourceIndex: Integer; const AParentRowObject: TValue;
  const ARelationName: string; const ARelationIndex, ADetailColumnIndex: Integer;
  const AColumn: TThemedGridDetailGridColumn; const ABounds: TRect; const AVisual: TThemedGridCellVisual);
begin
  inherited Create;
  FViewRow := AViewRow;
  FViewRowIndex := AViewRowIndex;
  FParentDataSourceIndex := AParentDataSourceIndex;
  FParentRowObject := AParentRowObject;
  if ARelationName <> '' then
    FRelationName := ARelationName
  else
    FRelationName := ThemedGridMasterDetailStrings.DefaultRelationName;
  FRelationIndex := ARelationIndex;
  FDetailColumnIndex := ADetailColumnIndex;
  FColumn := AColumn;
  FBounds := ABounds;
  FVisual := AVisual;
end;

function TThemedGridDetailGridHeaderVisualNeededEventArgs.GetColumnName: string;
begin
  if FColumn <> nil then
    Result := FColumn.Name
  else
    Result := '';
end;

function TThemedGridDetailGridHeaderVisualNeededEventArgs.GetDataPropertyName: string;
begin
  if FColumn <> nil then
    Result := FColumn.DataPropertyName
  else
    Result := '';
end;

function TThemedGridDetailGridHeaderVisualNeededEventArgs.GetHeaderText: string;
begin
  if FColumn <> nil then
    Result := FColumn.HeaderText
  else
    Result := '';
end;

end.

unit NimbusForms.Grid.DetailItem;

{$SCOPEDENUMS ON}

interface

uses
  System.Types,
  System.Rtti,
  Vcl.Controls,
  NimbusForms.Grid.Types;

type
  TThemedGridDetailItem = class;

  TThemedGridDetailItemActionContext = class
  private
    FGrid: TControl;
    FViewRowIndex: Integer;
    FParentDataSourceIndex: Integer;
    FParentRowObject: TValue;
    FItem: TThemedGridDetailItem;
    FItemKey: string;
    FValue: TValue;
    FBounds: TRect;
    FButton: TMouseButton;
    FLocation: TPoint;
    FTag: TValue;
    FHandled: Boolean;
  public
    constructor Create;
    property Grid: TControl read FGrid write FGrid;
    property ViewRowIndex: Integer read FViewRowIndex write FViewRowIndex;
    property ParentDataSourceIndex: Integer read FParentDataSourceIndex write FParentDataSourceIndex;
    property ParentRowObject: TValue read FParentRowObject write FParentRowObject;
    property Item: TThemedGridDetailItem read FItem write FItem;
    property ItemKey: string read FItemKey write FItemKey;
    property Value: TValue read FValue write FValue;
    property Bounds: TRect read FBounds write FBounds;
    property Button: TMouseButton read FButton write FButton;
    property Location: TPoint read FLocation write FLocation;
    property Tag: TValue read FTag write FTag;
    property Handled: Boolean read FHandled write FHandled;
  end;

  TThemedGridDetailItemAction = reference to procedure(const AContext: TThemedGridDetailItemActionContext);

  TThemedGridDetailItem = class
  private
    FKey: string;
    FText: string;
    FToolTipText: string;
    FValue: TValue;
    FWidth: Integer;
    FHeight: Integer;
    FLeft: Integer;
    FTop: Integer;
    FRightMargin: Integer;
    FVisible: Boolean;
    FEnabled: Boolean;
    FToggleOnClick: Boolean;
    FAutoHandleAction: Boolean;
    FRenderKind: TThemedGridCellRenderKind;
    FTextAlignment: TThemedGridContentAlignment;
    FTag: TValue;
    FAction: TThemedGridDetailItemAction;
    FBounds: TRect;
    procedure SetWidth(const AValue: Integer);
    procedure SetHeight(const AValue: Integer);
    procedure SetLeft(const AValue: Integer);
    procedure SetTop(const AValue: Integer);
    procedure SetRightMargin(const AValue: Integer);
  public
    constructor Create;
    property Key: string read FKey write FKey;
    property Text: string read FText write FText;
    property ToolTipText: string read FToolTipText write FToolTipText;
    property Value: TValue read FValue write FValue;
    property Width: Integer read FWidth write SetWidth;
    property Height: Integer read FHeight write SetHeight;
    property Left: Integer read FLeft write SetLeft;
    property Top: Integer read FTop write SetTop;
    property RightMargin: Integer read FRightMargin write SetRightMargin;
    property Visible: Boolean read FVisible write FVisible;
    property Enabled: Boolean read FEnabled write FEnabled;
    property ToggleOnClick: Boolean read FToggleOnClick write FToggleOnClick;
    property AutoHandleAction: Boolean read FAutoHandleAction write FAutoHandleAction;
    property RenderKind: TThemedGridCellRenderKind read FRenderKind write FRenderKind;
    property TextAlignment: TThemedGridContentAlignment read FTextAlignment write FTextAlignment;
    property Tag: TValue read FTag write FTag;
    property Action: TThemedGridDetailItemAction read FAction write FAction;
    property Bounds: TRect read FBounds write FBounds;
  end;

const
  CThemedGridDetailItemMinimumSize = 16;
  CThemedGridDetailItemMaximumWidth = 2000;
  CThemedGridDetailItemMaximumHeight = 200;
  CThemedGridDetailItemDefaultWidth = 120;
  CThemedGridDetailItemDefaultHeight = 24;
  CThemedGridDetailItemDefaultRightMargin = 8;

implementation

constructor TThemedGridDetailItemActionContext.Create;
begin
  inherited Create;
  FViewRowIndex := -1;
  FParentDataSourceIndex := -1;
  FButton := mbLeft;
end;

constructor TThemedGridDetailItem.Create;
begin
  inherited Create;
  FKey := '';
  FText := '';
  FToolTipText := '';
  FWidth := CThemedGridDetailItemDefaultWidth;
  FHeight := CThemedGridDetailItemDefaultHeight;
  FLeft := 0;
  FTop := 0;
  FRightMargin := CThemedGridDetailItemDefaultRightMargin;
  FVisible := True;
  FEnabled := True;
  FToggleOnClick := True;
  FAutoHandleAction := True;
  FRenderKind := TThemedGridCellRenderKind.Text;
  FTextAlignment := TThemedGridContentAlignment.MiddleLeft;
  FBounds := TRect.Empty;
end;

procedure TThemedGridDetailItem.SetWidth(const AValue: Integer);
begin
  if AValue < CThemedGridDetailItemMinimumSize then
    FWidth := CThemedGridDetailItemMinimumSize
  else if AValue > CThemedGridDetailItemMaximumWidth then
    FWidth := CThemedGridDetailItemMaximumWidth
  else
    FWidth := AValue;
end;

procedure TThemedGridDetailItem.SetHeight(const AValue: Integer);
begin
  if AValue < CThemedGridDetailItemMinimumSize then
    FHeight := CThemedGridDetailItemMinimumSize
  else if AValue > CThemedGridDetailItemMaximumHeight then
    FHeight := CThemedGridDetailItemMaximumHeight
  else
    FHeight := AValue;
end;

procedure TThemedGridDetailItem.SetLeft(const AValue: Integer);
begin
  if AValue < 0 then
    FLeft := 0
  else
    FLeft := AValue;
end;

procedure TThemedGridDetailItem.SetTop(const AValue: Integer);
begin
  if AValue < 0 then
    FTop := 0
  else
    FTop := AValue;
end;

procedure TThemedGridDetailItem.SetRightMargin(const AValue: Integer);
begin
  if AValue < 0 then
    FRightMargin := 0
  else
    FRightMargin := AValue;
end;

end.

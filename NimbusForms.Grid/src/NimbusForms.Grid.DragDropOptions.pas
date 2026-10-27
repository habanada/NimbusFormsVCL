unit NimbusForms.Grid.DragDropOptions;

interface

uses
  System.Classes;

const
  CThemedGridDragDefaultAutoScrollMargin = 24;
  CThemedGridDragMinimumAutoScrollMargin = 8;
  CThemedGridDragMaximumAutoScrollMargin = 120;

type
  TThemedGridDragDropOptions = class
  private
    FAllowDrag: Boolean;
    FAllowDrop: Boolean;
    FAllowInternalMove: Boolean;
    FAllowExternalText: Boolean;
    FShowDropIndicator: Boolean;
    FAutoScroll: Boolean;
    FAutoScrollMargin: Integer;
    FOnChanged: TNotifyEvent;
    procedure SetAllowDrag(const AValue: Boolean);
    procedure SetAllowDrop(const AValue: Boolean);
    procedure SetAllowInternalMove(const AValue: Boolean);
    procedure SetAllowExternalText(const AValue: Boolean);
    procedure SetShowDropIndicator(const AValue: Boolean);
    procedure SetAutoScroll(const AValue: Boolean);
    procedure SetAutoScrollMargin(const AValue: Integer);
    procedure DoChanged;
  public
    constructor Create;
    property AllowDrag: Boolean read FAllowDrag write SetAllowDrag;
    property AllowDrop: Boolean read FAllowDrop write SetAllowDrop;
    property AllowInternalMove: Boolean read FAllowInternalMove write SetAllowInternalMove;
    property AllowExternalText: Boolean read FAllowExternalText write SetAllowExternalText;
    property ShowDropIndicator: Boolean read FShowDropIndicator write SetShowDropIndicator;
    property AutoScroll: Boolean read FAutoScroll write SetAutoScroll;
    property AutoScrollMargin: Integer read FAutoScrollMargin write SetAutoScrollMargin;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

implementation

constructor TThemedGridDragDropOptions.Create;
begin
  inherited Create;
  FAllowInternalMove := True;
  FAllowExternalText := True;
  FShowDropIndicator := True;
  FAutoScroll := True;
  FAutoScrollMargin := CThemedGridDragDefaultAutoScrollMargin;
end;

procedure TThemedGridDragDropOptions.DoChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TThemedGridDragDropOptions.SetAllowDrag(const AValue: Boolean);
begin
  if FAllowDrag = AValue then Exit;
  FAllowDrag := AValue; DoChanged;
end;

procedure TThemedGridDragDropOptions.SetAllowDrop(const AValue: Boolean);
begin
  if FAllowDrop = AValue then Exit;
  FAllowDrop := AValue; DoChanged;
end;

procedure TThemedGridDragDropOptions.SetAllowInternalMove(const AValue: Boolean);
begin
  if FAllowInternalMove = AValue then Exit;
  FAllowInternalMove := AValue; DoChanged;
end;

procedure TThemedGridDragDropOptions.SetAllowExternalText(const AValue: Boolean);
begin
  if FAllowExternalText = AValue then Exit;
  FAllowExternalText := AValue; DoChanged;
end;

procedure TThemedGridDragDropOptions.SetShowDropIndicator(const AValue: Boolean);
begin
  if FShowDropIndicator = AValue then Exit;
  FShowDropIndicator := AValue; DoChanged;
end;

procedure TThemedGridDragDropOptions.SetAutoScroll(const AValue: Boolean);
begin
  if FAutoScroll = AValue then Exit;
  FAutoScroll := AValue; DoChanged;
end;

procedure TThemedGridDragDropOptions.SetAutoScrollMargin(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < CThemedGridDragMinimumAutoScrollMargin then
    LValue := CThemedGridDragMinimumAutoScrollMargin;
  if LValue > CThemedGridDragMaximumAutoScrollMargin then
    LValue := CThemedGridDragMaximumAutoScrollMargin;
  if FAutoScrollMargin = LValue then Exit;
  FAutoScrollMargin := LValue; DoChanged;
end;

end.

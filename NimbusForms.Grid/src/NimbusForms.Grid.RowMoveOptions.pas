unit NimbusForms.Grid.RowMoveOptions;

interface

uses
  System.Classes;

const
  CThemedGridRowMoveDefaultInsertLineWidth = 2;
  CThemedGridRowMoveMinimumInsertLineWidth = 1;
  CThemedGridRowMoveMaximumInsertLineWidth = 6;

type
  TThemedGridRowMoveOptions = class
  private
    FAllowRowMove: Boolean;
    FRowHeaderOnly: Boolean;
    FShowInsertIndicator: Boolean;
    FAutoScroll: Boolean;
    FInsertLineWidth: Integer;
    FOnChanged: TNotifyEvent;
    procedure SetAllowRowMove(const AValue: Boolean);
    procedure SetRowHeaderOnly(const AValue: Boolean);
    procedure SetShowInsertIndicator(const AValue: Boolean);
    procedure SetAutoScroll(const AValue: Boolean);
    procedure SetInsertLineWidth(const AValue: Integer);
    procedure DoChanged;
  public
    constructor Create;
    property AllowRowMove: Boolean read FAllowRowMove write SetAllowRowMove;
    property RowHeaderOnly: Boolean read FRowHeaderOnly write SetRowHeaderOnly;
    property ShowInsertIndicator: Boolean read FShowInsertIndicator write SetShowInsertIndicator;
    property AutoScroll: Boolean read FAutoScroll write SetAutoScroll;
    property InsertLineWidth: Integer read FInsertLineWidth write SetInsertLineWidth;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

implementation

constructor TThemedGridRowMoveOptions.Create;
begin
  inherited Create;
  FRowHeaderOnly := True;
  FShowInsertIndicator := True;
  FAutoScroll := True;
  FInsertLineWidth := CThemedGridRowMoveDefaultInsertLineWidth;
end;

procedure TThemedGridRowMoveOptions.DoChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TThemedGridRowMoveOptions.SetAllowRowMove(const AValue: Boolean);
begin
  if FAllowRowMove = AValue then Exit;
  FAllowRowMove := AValue; DoChanged;
end;

procedure TThemedGridRowMoveOptions.SetRowHeaderOnly(const AValue: Boolean);
begin
  if FRowHeaderOnly = AValue then Exit;
  FRowHeaderOnly := AValue; DoChanged;
end;

procedure TThemedGridRowMoveOptions.SetShowInsertIndicator(const AValue: Boolean);
begin
  if FShowInsertIndicator = AValue then Exit;
  FShowInsertIndicator := AValue; DoChanged;
end;

procedure TThemedGridRowMoveOptions.SetAutoScroll(const AValue: Boolean);
begin
  if FAutoScroll = AValue then Exit;
  FAutoScroll := AValue; DoChanged;
end;

procedure TThemedGridRowMoveOptions.SetInsertLineWidth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < CThemedGridRowMoveMinimumInsertLineWidth then
    LValue := CThemedGridRowMoveMinimumInsertLineWidth;
  if LValue > CThemedGridRowMoveMaximumInsertLineWidth then
    LValue := CThemedGridRowMoveMaximumInsertLineWidth;
  if FInsertLineWidth = LValue then Exit;
  FInsertLineWidth := LValue; DoChanged;
end;

end.

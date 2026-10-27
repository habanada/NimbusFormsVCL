unit NimbusForms.Grid.UndoOptions;

interface

uses
  System.Classes;

const
  CThemedGridUndoDefaultMaxDepth = 100;
  CThemedGridUndoMinimumMaxDepth = 1;
  CThemedGridUndoMaximumMaxDepth = 10000;

type
  TThemedGridUndoOptions = class
  private
    FEnabled: Boolean;
    FMaxDepth: Integer;
    FOnChanged: TNotifyEvent;
    procedure SetEnabled(const AValue: Boolean);
    procedure SetMaxDepth(const AValue: Integer);
    procedure DoChanged;
  public
    constructor Create;
    property Enabled: Boolean read FEnabled write SetEnabled;
    property MaxDepth: Integer read FMaxDepth write SetMaxDepth;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

implementation

constructor TThemedGridUndoOptions.Create;
begin
  inherited Create;
  FEnabled := True;
  FMaxDepth := CThemedGridUndoDefaultMaxDepth;
end;

procedure TThemedGridUndoOptions.DoChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TThemedGridUndoOptions.SetEnabled(const AValue: Boolean);
begin
  if FEnabled = AValue then Exit;
  FEnabled := AValue; DoChanged;
end;

procedure TThemedGridUndoOptions.SetMaxDepth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < CThemedGridUndoMinimumMaxDepth then
    LValue := CThemedGridUndoMinimumMaxDepth;
  if LValue > CThemedGridUndoMaximumMaxDepth then
    LValue := CThemedGridUndoMaximumMaxDepth;
  if FMaxDepth = LValue then Exit;
  FMaxDepth := LValue; DoChanged;
end;

end.

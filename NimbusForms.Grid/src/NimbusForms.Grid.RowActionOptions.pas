unit NimbusForms.Grid.RowActionOptions;

interface

uses
  System.Classes;

type
  TThemedGridRowActionOptions = class
  private
    FAllowAddRows: Boolean;
    FAllowRemoveRows: Boolean;
    FInsertKeyAddsRow: Boolean;
    FDeleteKeyRemovesRow: Boolean;
    FConfirmRemove: Boolean;
    FSelectAddedRow: Boolean;
    FOnChanged: TNotifyEvent;
    procedure SetAllowAddRows(const AValue: Boolean);
    procedure SetAllowRemoveRows(const AValue: Boolean);
    procedure SetInsertKeyAddsRow(const AValue: Boolean);
    procedure SetDeleteKeyRemovesRow(const AValue: Boolean);
    procedure SetConfirmRemove(const AValue: Boolean);
    procedure SetSelectAddedRow(const AValue: Boolean);
    procedure DoChanged;
  public
    constructor Create;
    property AllowAddRows: Boolean read FAllowAddRows write SetAllowAddRows;
    property AllowRemoveRows: Boolean read FAllowRemoveRows write SetAllowRemoveRows;
    property InsertKeyAddsRow: Boolean read FInsertKeyAddsRow write SetInsertKeyAddsRow;
    property DeleteKeyRemovesRow: Boolean read FDeleteKeyRemovesRow write SetDeleteKeyRemovesRow;
    property ConfirmRemove: Boolean read FConfirmRemove write SetConfirmRemove;
    property SelectAddedRow: Boolean read FSelectAddedRow write SetSelectAddedRow;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

implementation

constructor TThemedGridRowActionOptions.Create;
begin
  inherited Create;
  FInsertKeyAddsRow := True;
  FDeleteKeyRemovesRow := True;
  FConfirmRemove := True;
  FSelectAddedRow := True;
end;

procedure TThemedGridRowActionOptions.DoChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TThemedGridRowActionOptions.SetAllowAddRows(const AValue: Boolean);
begin
  if FAllowAddRows = AValue then Exit;
  FAllowAddRows := AValue; DoChanged;
end;

procedure TThemedGridRowActionOptions.SetAllowRemoveRows(const AValue: Boolean);
begin
  if FAllowRemoveRows = AValue then Exit;
  FAllowRemoveRows := AValue; DoChanged;
end;

procedure TThemedGridRowActionOptions.SetInsertKeyAddsRow(const AValue: Boolean);
begin
  if FInsertKeyAddsRow = AValue then Exit;
  FInsertKeyAddsRow := AValue; DoChanged;
end;

procedure TThemedGridRowActionOptions.SetDeleteKeyRemovesRow(const AValue: Boolean);
begin
  if FDeleteKeyRemovesRow = AValue then Exit;
  FDeleteKeyRemovesRow := AValue; DoChanged;
end;

procedure TThemedGridRowActionOptions.SetConfirmRemove(const AValue: Boolean);
begin
  if FConfirmRemove = AValue then Exit;
  FConfirmRemove := AValue; DoChanged;
end;

procedure TThemedGridRowActionOptions.SetSelectAddedRow(const AValue: Boolean);
begin
  if FSelectAddedRow = AValue then Exit;
  FSelectAddedRow := AValue; DoChanged;
end;

end.

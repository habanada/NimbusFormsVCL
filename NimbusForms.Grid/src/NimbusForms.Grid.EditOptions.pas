unit NimbusForms.Grid.EditOptions;

interface

uses
  System.Classes;

type
  TThemedGridEditOptions = class
  private
    FAllowEdit: Boolean;
    FEditOnDoubleClick: Boolean;
    FEditOnSingleClick: Boolean;
    FUseRowTransactions: Boolean;
    FEditOnEnter: Boolean;
    FEditOnF2: Boolean;
    FCommitOnLeave: Boolean;
    FCommitOnScroll: Boolean;
    FOnChanged: TNotifyEvent;
    procedure SetAllowEdit(const AValue: Boolean);
    procedure SetEditOnDoubleClick(const AValue: Boolean);
    procedure SetEditOnSingleClick(const AValue: Boolean);
    procedure SetUseRowTransactions(const AValue: Boolean);
    procedure SetEditOnEnter(const AValue: Boolean);
    procedure SetEditOnF2(const AValue: Boolean);
    procedure SetCommitOnLeave(const AValue: Boolean);
    procedure SetCommitOnScroll(const AValue: Boolean);
    procedure DoChanged;
  public
    constructor Create;
    property AllowEdit: Boolean read FAllowEdit write SetAllowEdit;
    property EditOnDoubleClick: Boolean read FEditOnDoubleClick write SetEditOnDoubleClick;
    property EditOnSingleClick: Boolean read FEditOnSingleClick write SetEditOnSingleClick;
    property UseRowTransactions: Boolean read FUseRowTransactions write SetUseRowTransactions;
    property EditOnEnter: Boolean read FEditOnEnter write SetEditOnEnter;
    property EditOnF2: Boolean read FEditOnF2 write SetEditOnF2;
    property CommitOnLeave: Boolean read FCommitOnLeave write SetCommitOnLeave;
    property CommitOnScroll: Boolean read FCommitOnScroll write SetCommitOnScroll;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

implementation

constructor TThemedGridEditOptions.Create;
begin
  inherited Create;
  FAllowEdit := True;
  FEditOnDoubleClick := True;
  FEditOnEnter := True;
  FEditOnF2 := True;
  FCommitOnLeave := True;
  FCommitOnScroll := True;
end;

procedure TThemedGridEditOptions.DoChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TThemedGridEditOptions.SetAllowEdit(const AValue: Boolean);
begin
  if FAllowEdit = AValue then Exit;
  FAllowEdit := AValue; DoChanged;
end;

procedure TThemedGridEditOptions.SetEditOnDoubleClick(const AValue: Boolean);
begin
  if FEditOnDoubleClick = AValue then Exit;
  FEditOnDoubleClick := AValue; DoChanged;
end;

procedure TThemedGridEditOptions.SetEditOnSingleClick(const AValue: Boolean);
begin
  if FEditOnSingleClick = AValue then Exit;
  FEditOnSingleClick := AValue; DoChanged;
end;

procedure TThemedGridEditOptions.SetUseRowTransactions(const AValue: Boolean);
begin
  if FUseRowTransactions = AValue then Exit;
  FUseRowTransactions := AValue; DoChanged;
end;

procedure TThemedGridEditOptions.SetEditOnEnter(const AValue: Boolean);
begin
  if FEditOnEnter = AValue then Exit;
  FEditOnEnter := AValue; DoChanged;
end;

procedure TThemedGridEditOptions.SetEditOnF2(const AValue: Boolean);
begin
  if FEditOnF2 = AValue then Exit;
  FEditOnF2 := AValue; DoChanged;
end;

procedure TThemedGridEditOptions.SetCommitOnLeave(const AValue: Boolean);
begin
  if FCommitOnLeave = AValue then Exit;
  FCommitOnLeave := AValue; DoChanged;
end;

procedure TThemedGridEditOptions.SetCommitOnScroll(const AValue: Boolean);
begin
  if FCommitOnScroll = AValue then Exit;
  FCommitOnScroll := AValue; DoChanged;
end;

end.

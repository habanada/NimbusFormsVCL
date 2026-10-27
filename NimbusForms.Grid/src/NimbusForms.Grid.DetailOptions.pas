unit NimbusForms.Grid.DetailOptions;

{$SCOPEDENUMS ON}

interface

uses
  System.Classes,
  System.Rtti,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.DetailRelation,
  NimbusForms.Grid.DetailRelationCollection;

type
  TThemedGridDetailTextGetter = reference to function(const ARow: TValue): string;

  TThemedGridDetailOptions = class
  private
    FEnabled: Boolean;
    FAllowCollapse: Boolean;
    FShowOnDoubleClick: Boolean;
    FShowFocusedDetailBorder: Boolean;
    FShowFocusedDetailLine: Boolean;
    FFocusedDetailLineAlpha: Integer;
    FFocusedDetailBorderAlpha: Integer;
    FDetailRowHeight: Integer;
    FAutoRowHeight: Boolean;
    FEmptyText: string;
    FEmbeddedDetailGridRetentionMode: TThemedGridEmbeddedDetailGridRetentionMode;
    FDoubleClickPriority: TThemedGridDetailDoubleClickPriority;
    FExpandTrigger: TThemedGridDetailExpandTriggers;
    FRelations: TThemedGridDetailRelationCollection;
    FDetailTextGetter: TThemedGridDetailTextGetter;
    FOnChanged: TNotifyEvent;
    procedure SetEnabled(const AValue: Boolean);
    procedure SetAllowCollapse(const AValue: Boolean);
    procedure SetShowOnDoubleClick(const AValue: Boolean);
    procedure SetExpandTrigger(const AValue: TThemedGridDetailExpandTriggers);
    procedure SetDoubleClickPriority(const AValue: TThemedGridDetailDoubleClickPriority);
    procedure SetShowFocusedDetailBorder(const AValue: Boolean);
    procedure SetShowFocusedDetailLine(const AValue: Boolean);
    procedure SetFocusedDetailLineAlpha(const AValue: Integer);
    procedure SetFocusedDetailBorderAlpha(const AValue: Integer);
    procedure SetDetailRowHeight(const AValue: Integer);
    procedure SetAutoRowHeight(const AValue: Boolean);
    procedure SetEmptyText(const AValue: string);
    procedure SetEmbeddedDetailGridRetentionMode(const AValue: TThemedGridEmbeddedDetailGridRetentionMode);
    procedure DoChanged;
  public
    constructor Create;
    destructor Destroy; override;
    function HasExpandTrigger(const ATrigger: TThemedGridDetailExpandTrigger): Boolean;
    function GetEnabledRelationCount: Integer;
    function GetEnabledRelationByVisibleIndex(const AVisibleIndex: Integer): TThemedGridDetailRelation;
    property Enabled: Boolean read FEnabled write SetEnabled;
    property AllowCollapse: Boolean read FAllowCollapse write SetAllowCollapse;
    property ShowOnDoubleClick: Boolean read FShowOnDoubleClick write SetShowOnDoubleClick;
    property ExpandTrigger: TThemedGridDetailExpandTriggers read FExpandTrigger write SetExpandTrigger;
    property DoubleClickPriority: TThemedGridDetailDoubleClickPriority read FDoubleClickPriority write SetDoubleClickPriority;
    property ShowFocusedDetailBorder: Boolean read FShowFocusedDetailBorder write SetShowFocusedDetailBorder;
    property ShowFocusedDetailLine: Boolean read FShowFocusedDetailLine write SetShowFocusedDetailLine;
    property FocusedDetailLineAlpha: Integer read FFocusedDetailLineAlpha write SetFocusedDetailLineAlpha;
    property FocusedDetailBorderAlpha: Integer read FFocusedDetailBorderAlpha write SetFocusedDetailBorderAlpha;
    property DetailRowHeight: Integer read FDetailRowHeight write SetDetailRowHeight;
    property AutoRowHeight: Boolean read FAutoRowHeight write SetAutoRowHeight;
    property EmptyText: string read FEmptyText write SetEmptyText;
    property EmbeddedDetailGridRetentionMode: TThemedGridEmbeddedDetailGridRetentionMode
      read FEmbeddedDetailGridRetentionMode write SetEmbeddedDetailGridRetentionMode;
    property Relations: TThemedGridDetailRelationCollection read FRelations;
    property DetailTextGetter: TThemedGridDetailTextGetter read FDetailTextGetter write FDetailTextGetter;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

implementation

constructor TThemedGridDetailOptions.Create;
begin
  inherited Create;
  FEnabled := False;
  FAllowCollapse := True;
  FShowOnDoubleClick := True;
  FShowFocusedDetailBorder := False;
  FShowFocusedDetailLine := True;
  FFocusedDetailBorderAlpha := 48;
  FFocusedDetailLineAlpha := 120;
  FDetailRowHeight := 72;
  FAutoRowHeight := True;
  FEmptyText := '';
  FEmbeddedDetailGridRetentionMode := TThemedGridEmbeddedDetailGridRetentionMode.ParkOnCollapse;
  FDoubleClickPriority := TThemedGridDetailDoubleClickPriority.Editor;
  FExpandTrigger := ThemedGridDefaultDetailExpandTriggers;
  FRelations := TThemedGridDetailRelationCollection.Create(
    procedure
    begin
      DoChanged;
    end);
end;

destructor TThemedGridDetailOptions.Destroy;
begin
  FRelations.Free;
  inherited Destroy;
end;

procedure TThemedGridDetailOptions.DoChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TThemedGridDetailOptions.SetEnabled(const AValue: Boolean);
begin
  if FEnabled = AValue then
    Exit;
  FEnabled := AValue;
  DoChanged;
end;

procedure TThemedGridDetailOptions.SetAllowCollapse(const AValue: Boolean);
begin
  if FAllowCollapse = AValue then
    Exit;
  FAllowCollapse := AValue;
  DoChanged;
end;

procedure TThemedGridDetailOptions.SetShowOnDoubleClick(const AValue: Boolean);
begin
  if FShowOnDoubleClick = AValue then
    Exit;
  FShowOnDoubleClick := AValue;
  if AValue then
    Include(FExpandTrigger, TThemedGridDetailExpandTrigger.DoubleClick)
  else
    Exclude(FExpandTrigger, TThemedGridDetailExpandTrigger.DoubleClick);
  DoChanged;
end;

procedure TThemedGridDetailOptions.SetExpandTrigger(const AValue: TThemedGridDetailExpandTriggers);
begin
  if FExpandTrigger = AValue then
    Exit;
  FExpandTrigger := AValue;
  FShowOnDoubleClick := TThemedGridDetailExpandTrigger.DoubleClick in AValue;
  DoChanged;
end;

function TThemedGridDetailOptions.HasExpandTrigger(const ATrigger: TThemedGridDetailExpandTrigger): Boolean;
begin
  Result := ATrigger in FExpandTrigger;
end;

procedure TThemedGridDetailOptions.SetDoubleClickPriority(const AValue: TThemedGridDetailDoubleClickPriority);
begin
  if FDoubleClickPriority = AValue then
    Exit;
  FDoubleClickPriority := AValue;
  DoChanged;
end;

procedure TThemedGridDetailOptions.SetShowFocusedDetailBorder(const AValue: Boolean);
begin
  if FShowFocusedDetailBorder = AValue then
    Exit;
  FShowFocusedDetailBorder := AValue;
  DoChanged;
end;

procedure TThemedGridDetailOptions.SetShowFocusedDetailLine(const AValue: Boolean);
begin
  if FShowFocusedDetailLine = AValue then
    Exit;
  FShowFocusedDetailLine := AValue;
  DoChanged;
end;

procedure TThemedGridDetailOptions.SetFocusedDetailLineAlpha(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 0 then
    LValue := 0;
  if LValue > 255 then
    LValue := 255;
  if FFocusedDetailLineAlpha = LValue then
    Exit;
  FFocusedDetailLineAlpha := LValue;
  DoChanged;
end;

procedure TThemedGridDetailOptions.SetFocusedDetailBorderAlpha(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 0 then
    LValue := 0;
  if LValue > 255 then
    LValue := 255;
  if FFocusedDetailBorderAlpha = LValue then
    Exit;
  FFocusedDetailBorderAlpha := LValue;
  DoChanged;
end;

procedure TThemedGridDetailOptions.SetAutoRowHeight(const AValue: Boolean);
begin
  if FAutoRowHeight = AValue then
    Exit;
  FAutoRowHeight := AValue;
  DoChanged;
end;

procedure TThemedGridDetailOptions.SetDetailRowHeight(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 24 then
    LValue := 24;
  if LValue > 1200 then
    LValue := 1200;
  if FDetailRowHeight = LValue then
    Exit;
  FDetailRowHeight := LValue;
  DoChanged;
end;

procedure TThemedGridDetailOptions.SetEmptyText(const AValue: string);
begin
  if FEmptyText = AValue then
    Exit;
  FEmptyText := AValue;
  DoChanged;
end;

procedure TThemedGridDetailOptions.SetEmbeddedDetailGridRetentionMode(
  const AValue: TThemedGridEmbeddedDetailGridRetentionMode);
begin
  if FEmbeddedDetailGridRetentionMode = AValue then
    Exit;
  FEmbeddedDetailGridRetentionMode := AValue;
  DoChanged;
end;

function TThemedGridDetailOptions.GetEnabledRelationCount: Integer;
var
  I: Integer;
begin
  if FRelations.Count = 0 then
    Exit(1);
  Result := 0;
  for I := 0 to FRelations.Count - 1 do
    if (FRelations[I] <> nil) and FRelations[I].Enabled then
      Inc(Result);
  if Result = 0 then
    Result := 1;
end;

function TThemedGridDetailOptions.GetEnabledRelationByVisibleIndex(const AVisibleIndex: Integer): TThemedGridDetailRelation;
var
  I, LCurrent: Integer;
begin
  Result := nil;
  if FRelations.Count = 0 then
    Exit;
  LCurrent := 0;
  for I := 0 to FRelations.Count - 1 do
  begin
    if (FRelations[I] = nil) or (not FRelations[I].Enabled) then
      Continue;
    if LCurrent = AVisibleIndex then
      Exit(FRelations[I]);
    Inc(LCurrent);
  end;
end;

end.

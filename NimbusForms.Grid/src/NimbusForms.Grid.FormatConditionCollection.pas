unit NimbusForms.Grid.FormatConditionCollection;

{$SCOPEDENUMS ON}

interface

uses
  System.Classes,
  System.Rtti,
  System.Generics.Collections,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.FormatStyle,
  NimbusForms.Grid.FormatCondition,
  NimbusForms.Grid.FormatConditionContext,
  NimbusForms.Grid.FormatConditionEvents;

type
  TThemedGridFormatConditionCollection = class
  private
    FItems: TObjectList<TThemedGridFormatCondition>;
    FEnabled: Boolean;
    FUpdateLock: Integer;
    FPendingChanged: Boolean;
    FOnChanged: TThemedGridFormatConditionChangedEvent;
    function GetItem(const AIndex: Integer): TThemedGridFormatCondition;
    procedure SetItem(const AIndex: Integer; const AValue: TThemedGridFormatCondition);
    function GetCount: Integer;
    function GetIsUpdating: Boolean;
    function GetIsReadOnly: Boolean;
    function GetEnabledCount: Integer;
    procedure HookCondition(const ACondition: TThemedGridFormatCondition);
    procedure UnhookCondition(const ACondition: TThemedGridFormatCondition);
    procedure ConditionChanged(ASender: TObject);
    procedure DoChanged(const AAction: TThemedGridFormatConditionChangeAction;
      const ACondition: TThemedGridFormatCondition; const AIndex: Integer);
    procedure RaiseChanged(const AArgs: TThemedGridFormatConditionChangedEventArgs);
  public
    constructor Create;
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure Add(const AItem: TThemedGridFormatCondition); overload;
    function Add(const AColumnName: string; const AOperator: TThemedGridFormatConditionOperator;
      const AValue: TValue; const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition; overload;
    function AddRow(const AColumnName: string; const AOperator: TThemedGridFormatConditionOperator;
      const AValue: TValue; const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition;
    function AddBetween(const AColumnName: string; const AValue, AValue2: TValue;
      const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition;
    function AddIn(const AColumnName: string; const AValues: array of TValue;
      const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition;
    function AddNotIn(const AColumnName: string; const AValues: array of TValue;
      const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition;
    function AddCustom(const APredicate: TThemedGridFormatConditionPredicate;
      const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition;
    procedure AddRange(const AConditions: array of TThemedGridFormatCondition);
    procedure ReplaceAll(const AConditions: array of TThemedGridFormatCondition);
    procedure ReplaceAllFrom(const ASource: TThemedGridFormatConditionCollection);
    procedure Clear;
    function Contains(const AItem: TThemedGridFormatCondition): Boolean;
    procedure CopyTo(var AArray: TArray<TThemedGridFormatCondition>; const AArrayIndex: Integer);
    function GetEnumerator: TEnumerator<TThemedGridFormatCondition>;
    function IndexOf(const AItem: TThemedGridFormatCondition): Integer;
    procedure Insert(const AIndex: Integer; const AItem: TThemedGridFormatCondition);
    function Remove(const AItem: TThemedGridFormatCondition): Boolean;
    function Extract(const AItem: TThemedGridFormatCondition): TThemedGridFormatCondition;
    procedure RemoveAt(const AIndex: Integer);
    procedure SetEnabled(const AValue: Boolean);
    procedure EnableAll;
    procedure DisableAll;
    procedure SetAllConditionEnabled(const AValue: Boolean);
    property Items[const AIndex: Integer]: TThemedGridFormatCondition read GetItem write SetItem; default;
    property Count: Integer read GetCount;
    property Enabled: Boolean read FEnabled;
    property IsUpdating: Boolean read GetIsUpdating;
    property IsReadOnly: Boolean read GetIsReadOnly;
    property EnabledCount: Integer read GetEnabledCount;
    property OnChanged: TThemedGridFormatConditionChangedEvent read FOnChanged write FOnChanged;
  end;

implementation

constructor TThemedGridFormatConditionCollection.Create;
begin
  inherited Create;
  FItems := TObjectList<TThemedGridFormatCondition>.Create(True);
  FEnabled := True;
end;

destructor TThemedGridFormatConditionCollection.Destroy;
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
    UnhookCondition(FItems[I]);
  FItems.Free;
  inherited Destroy;
end;

function TThemedGridFormatConditionCollection.GetItem(const AIndex: Integer): TThemedGridFormatCondition;
begin
  Result := FItems[AIndex];
end;

procedure TThemedGridFormatConditionCollection.SetItem(const AIndex: Integer;
  const AValue: TThemedGridFormatCondition);
var
  LOldItem: TThemedGridFormatCondition;
begin
  LOldItem := FItems[AIndex];
  if LOldItem = AValue then
    Exit;
  if (AValue <> nil) and (FItems.IndexOf(AValue) >= 0) then
    Exit;
  UnhookCondition(LOldItem);
  FItems[AIndex] := AValue;
  HookCondition(AValue);
  DoChanged(TThemedGridFormatConditionChangeAction.Replace, AValue, AIndex);
end;

function TThemedGridFormatConditionCollection.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TThemedGridFormatConditionCollection.GetIsUpdating: Boolean;
begin
  Result := FUpdateLock > 0;
end;

function TThemedGridFormatConditionCollection.GetIsReadOnly: Boolean;
begin
  Result := False;
end;

function TThemedGridFormatConditionCollection.GetEnabledCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FItems.Count - 1 do
    if (FItems[I] <> nil) and FItems[I].Enabled then
      Inc(Result);
end;

procedure TThemedGridFormatConditionCollection.HookCondition(const ACondition: TThemedGridFormatCondition);
begin
  if ACondition <> nil then
    ACondition.OnChanged := ConditionChanged;
end;

procedure TThemedGridFormatConditionCollection.UnhookCondition(const ACondition: TThemedGridFormatCondition);
begin
  if ACondition <> nil then
    ACondition.OnChanged := nil;
end;

procedure TThemedGridFormatConditionCollection.ConditionChanged(ASender: TObject);
var
  LCondition: TThemedGridFormatCondition;
begin
  LCondition := ASender as TThemedGridFormatCondition;
  DoChanged(TThemedGridFormatConditionChangeAction.ConditionChanged, LCondition, IndexOf(LCondition));
end;

procedure TThemedGridFormatConditionCollection.DoChanged(const AAction: TThemedGridFormatConditionChangeAction;
  const ACondition: TThemedGridFormatCondition; const AIndex: Integer);
var
  LArgs: TThemedGridFormatConditionChangedEventArgs;
begin
  if FUpdateLock > 0 then
  begin
    FPendingChanged := True;
    Exit;
  end;
  LArgs := TThemedGridFormatConditionChangedEventArgs.Create(AAction, ACondition, AIndex, FEnabled,
    Count, GetEnabledCount);
  try
    RaiseChanged(LArgs);
  finally
    LArgs.Free;
  end;
end;

procedure TThemedGridFormatConditionCollection.RaiseChanged(const AArgs: TThemedGridFormatConditionChangedEventArgs);
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self, AArgs);
end;

procedure TThemedGridFormatConditionCollection.BeginUpdate;
begin
  Inc(FUpdateLock);
end;

procedure TThemedGridFormatConditionCollection.EndUpdate;
var
  LArgs: TThemedGridFormatConditionChangedEventArgs;
begin
  if FUpdateLock <= 0 then
    Exit;
  Dec(FUpdateLock);
  if (FUpdateLock = 0) and FPendingChanged then
  begin
    FPendingChanged := False;
    LArgs := TThemedGridFormatConditionChangedEventArgs.Create(TThemedGridFormatConditionChangeAction.EndUpdate,
      nil, -1, FEnabled, Count, GetEnabledCount);
    try
      RaiseChanged(LArgs);
    finally
      LArgs.Free;
    end;
  end;
end;

procedure TThemedGridFormatConditionCollection.Add(const AItem: TThemedGridFormatCondition);
begin
  if AItem = nil then
    Exit;
  if FItems.IndexOf(AItem) >= 0 then
    Exit;
  FItems.Add(AItem);
  HookCondition(AItem);
  DoChanged(TThemedGridFormatConditionChangeAction.Add, AItem, FItems.Count - 1);
end;

function TThemedGridFormatConditionCollection.Add(const AColumnName: string;
  const AOperator: TThemedGridFormatConditionOperator; const AValue: TValue;
  const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition;
begin
  Result := TThemedGridFormatCondition.New(AColumnName, AOperator, AValue, AStyle);
  Add(Result);
end;

function TThemedGridFormatConditionCollection.AddRow(const AColumnName: string;
  const AOperator: TThemedGridFormatConditionOperator; const AValue: TValue;
  const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition;
begin
  Result := TThemedGridFormatCondition.Row(AColumnName, AOperator, AValue, AStyle);
  Add(Result);
end;

function TThemedGridFormatConditionCollection.AddBetween(const AColumnName: string;
  const AValue, AValue2: TValue; const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition;
begin
  Result := TThemedGridFormatCondition.Between(AColumnName, AValue, AValue2, AStyle);
  Add(Result);
end;

function TThemedGridFormatConditionCollection.AddIn(const AColumnName: string;
  const AValues: array of TValue; const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition;
begin
  Result := TThemedGridFormatCondition.MakeIn(AColumnName, AValues, AStyle);
  Add(Result);
end;

function TThemedGridFormatConditionCollection.AddNotIn(const AColumnName: string;
  const AValues: array of TValue; const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition;
begin
  Result := TThemedGridFormatCondition.MakeNotIn(AColumnName, AValues, AStyle);
  Add(Result);
end;

function TThemedGridFormatConditionCollection.AddCustom(const APredicate: TThemedGridFormatConditionPredicate;
  const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition;
begin
  Result := TThemedGridFormatCondition.Custom(APredicate, AStyle);
  Add(Result);
end;

procedure TThemedGridFormatConditionCollection.AddRange(const AConditions: array of TThemedGridFormatCondition);
var
  I: Integer;
begin
  BeginUpdate;
  try
    for I := 0 to High(AConditions) do
      Add(AConditions[I]);
  finally
    EndUpdate;
  end;
end;

procedure TThemedGridFormatConditionCollection.ReplaceAll(const AConditions: array of TThemedGridFormatCondition);
var
  I: Integer;
begin
  BeginUpdate;
  try
    for I := 0 to High(AConditions) do
      if (AConditions[I] <> nil) and (FItems.IndexOf(AConditions[I]) >= 0) then
      begin
        UnhookCondition(AConditions[I]);
        FItems.Extract(AConditions[I]);
      end;
    Clear;
    for I := 0 to High(AConditions) do
      Add(AConditions[I]);
  finally
    EndUpdate;
  end;
  DoChanged(TThemedGridFormatConditionChangeAction.Reset, nil, -1);
end;

procedure TThemedGridFormatConditionCollection.ReplaceAllFrom(const ASource: TThemedGridFormatConditionCollection);
var
  LItems: TArray<TThemedGridFormatCondition>;
  I: Integer;
begin
  if (ASource = nil) or (ASource = Self) then
    Exit;
  SetLength(LItems, ASource.Count);
  for I := 0 to High(LItems) do
    LItems[I] := ASource[I];
  for I := 0 to High(LItems) do
    ASource.Extract(LItems[I]);
  ReplaceAll(LItems);
end;

procedure TThemedGridFormatConditionCollection.Clear;
var
  I: Integer;
begin
  if FItems.Count = 0 then
    Exit;
  for I := 0 to FItems.Count - 1 do
    UnhookCondition(FItems[I]);
  FItems.Clear;
  DoChanged(TThemedGridFormatConditionChangeAction.Clear, nil, -1);
end;

function TThemedGridFormatConditionCollection.Contains(const AItem: TThemedGridFormatCondition): Boolean;
begin
  Result := FItems.IndexOf(AItem) >= 0;
end;

procedure TThemedGridFormatConditionCollection.CopyTo(var AArray: TArray<TThemedGridFormatCondition>;
  const AArrayIndex: Integer);
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
    AArray[AArrayIndex + I] := FItems[I];
end;

function TThemedGridFormatConditionCollection.GetEnumerator: TEnumerator<TThemedGridFormatCondition>;
begin
  Result := FItems.GetEnumerator;
end;

function TThemedGridFormatConditionCollection.IndexOf(const AItem: TThemedGridFormatCondition): Integer;
begin
  Result := FItems.IndexOf(AItem);
end;

procedure TThemedGridFormatConditionCollection.Insert(const AIndex: Integer;
  const AItem: TThemedGridFormatCondition);
begin
  if AItem = nil then
    Exit;
  if FItems.IndexOf(AItem) >= 0 then
    Exit;
  FItems.Insert(AIndex, AItem);
  HookCondition(AItem);
  DoChanged(TThemedGridFormatConditionChangeAction.Insert, AItem, AIndex);
end;

function TThemedGridFormatConditionCollection.Extract(const AItem: TThemedGridFormatCondition): TThemedGridFormatCondition;
var
  LIndex: Integer;
begin
  LIndex := FItems.IndexOf(AItem);
  if LIndex < 0 then
    Exit(nil);
  UnhookCondition(AItem);
  Result := FItems.Extract(AItem);
  DoChanged(TThemedGridFormatConditionChangeAction.Remove, Result, LIndex);
end;

function TThemedGridFormatConditionCollection.Remove(const AItem: TThemedGridFormatCondition): Boolean;
var
  LIndex: Integer;
  LExtracted: TThemedGridFormatCondition;
begin
  LIndex := FItems.IndexOf(AItem);
  if LIndex < 0 then
    Exit(False);
  UnhookCondition(AItem);
  LExtracted := FItems.Extract(AItem);
  try
    DoChanged(TThemedGridFormatConditionChangeAction.Remove, LExtracted, LIndex);
  finally
    LExtracted.Free;
  end;
  Result := True;
end;

procedure TThemedGridFormatConditionCollection.RemoveAt(const AIndex: Integer);
var
  LCondition: TThemedGridFormatCondition;
begin
  LCondition := FItems[AIndex];
  UnhookCondition(LCondition);
  FItems.Extract(LCondition);
  try
    DoChanged(TThemedGridFormatConditionChangeAction.RemoveAt, LCondition, AIndex);
  finally
    LCondition.Free;
  end;
end;

procedure TThemedGridFormatConditionCollection.SetEnabled(const AValue: Boolean);
begin
  if FEnabled = AValue then
    Exit;
  FEnabled := AValue;
  DoChanged(TThemedGridFormatConditionChangeAction.EnabledChanged, nil, -1);
end;

procedure TThemedGridFormatConditionCollection.EnableAll;
begin
  SetAllConditionEnabled(True);
end;

procedure TThemedGridFormatConditionCollection.DisableAll;
begin
  SetAllConditionEnabled(False);
end;

procedure TThemedGridFormatConditionCollection.SetAllConditionEnabled(const AValue: Boolean);
var
  I: Integer;
begin
  BeginUpdate;
  try
    for I := 0 to FItems.Count - 1 do
      if FItems[I] <> nil then
        FItems[I].Enabled := AValue;
  finally
    EndUpdate;
  end;
  DoChanged(TThemedGridFormatConditionChangeAction.EnabledChanged, nil, -1);
end;

end.

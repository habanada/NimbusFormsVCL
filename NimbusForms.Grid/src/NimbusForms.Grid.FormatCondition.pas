unit NimbusForms.Grid.FormatCondition;

{$SCOPEDENUMS ON}

interface

uses
  System.TypInfo,
  System.Classes,
  System.Rtti,
  System.Generics.Collections,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.FormatStyle,
  NimbusForms.Grid.FormatConditionContext;

type
  TThemedGridFormatConditionPredicate = reference to function(const AContext: TThemedGridFormatConditionContext): Boolean;

  TThemedGridFormatCondition = class
  private
    FValues: TList<TValue>;
    FEnabled: Boolean;
    FColumnName: string;
    FTargetColumnName: string;
    FOperator: TThemedGridFormatConditionOperator;
    FValue: TValue;
    FValue2: TValue;
    FStyle: TThemedGridFormatStyle;
    FPredicate: TThemedGridFormatConditionPredicate;
    FTag: TValue;
    FOnChanged: TNotifyEvent;
    procedure SetEnabled(const AValue: Boolean);
    procedure SetColumnName(const AValue: string);
    procedure SetTargetColumnName(const AValue: string);
    procedure SetOperator(const AValue: TThemedGridFormatConditionOperator);
    procedure SetValue(const AValue: TValue);
    procedure SetValue2(const AValue: TValue);
    procedure SetStyle(const AValue: TThemedGridFormatStyle);
    procedure SetTag(const AValue: TValue);
    procedure DoChanged;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddValue(const AValue: TValue);
    procedure AddValues(const AValues: array of TValue);
    procedure ClearValues;
    function Clone: TThemedGridFormatCondition;
    class function New(const AColumnName: string; const AOperator: TThemedGridFormatConditionOperator; const AValue: TValue; const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition; static;
    class function Row(const AColumnName: string; const AOperator: TThemedGridFormatConditionOperator; const AValue: TValue; const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition; static;
    class function Between(const AColumnName: string; const AValue, AValue2: TValue; const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition; static;
    class function MakeIn(const AColumnName: string; const AValues: array of TValue; const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition; static;
    class function MakeNotIn(const AColumnName: string; const AValues: array of TValue; const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition; static;
    class function Custom(const APredicate: TThemedGridFormatConditionPredicate; const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition; static;
    property Enabled: Boolean read FEnabled write SetEnabled;
    property ColumnName: string read FColumnName write SetColumnName;
    property TargetColumnName: string read FTargetColumnName write SetTargetColumnName;
    property Operator: TThemedGridFormatConditionOperator read FOperator write SetOperator;
    property Value: TValue read FValue write SetValue;
    property Value2: TValue read FValue2 write SetValue2;
    property Values: TList<TValue> read FValues;
    property Style: TThemedGridFormatStyle read FStyle write SetStyle;
    property Predicate: TThemedGridFormatConditionPredicate read FPredicate write FPredicate;
    property Tag: TValue read FTag write SetTag;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

implementation

function ValuesEqual(const A, B: TValue): Boolean;
begin
  if (A.TypeInfo = nil) and (B.TypeInfo = nil) then
    Exit(True);
  if (A.TypeInfo = nil) <> (B.TypeInfo = nil) then
    Exit(False);
  if A.TypeInfo <> B.TypeInfo then
    Exit(False);
  Result := A.ToString = B.ToString;
end;

constructor TThemedGridFormatCondition.Create;
begin
  inherited Create;
  FValues := TList<TValue>.Create;
  FEnabled := True;
  FOperator := TThemedGridFormatConditionOperator.Equals;
end;

destructor TThemedGridFormatCondition.Destroy;
begin
  FStyle.Free;
  FValues.Free;
  inherited Destroy;
end;

procedure TThemedGridFormatCondition.DoChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TThemedGridFormatCondition.SetEnabled(const AValue: Boolean);
begin
  if FEnabled = AValue then Exit;
  FEnabled := AValue; DoChanged;
end;

procedure TThemedGridFormatCondition.SetColumnName(const AValue: string);
begin
  if FColumnName = AValue then Exit;
  FColumnName := AValue; DoChanged;
end;

procedure TThemedGridFormatCondition.SetTargetColumnName(const AValue: string);
begin
  if FTargetColumnName = AValue then Exit;
  FTargetColumnName := AValue; DoChanged;
end;

procedure TThemedGridFormatCondition.SetOperator(const AValue: TThemedGridFormatConditionOperator);
begin
  if FOperator = AValue then Exit;
  FOperator := AValue; DoChanged;
end;

procedure TThemedGridFormatCondition.SetValue(const AValue: TValue);
begin
  if ValuesEqual(FValue, AValue) then Exit;
  FValue := AValue; DoChanged;
end;

procedure TThemedGridFormatCondition.SetValue2(const AValue: TValue);
begin
  if ValuesEqual(FValue2, AValue) then Exit;
  FValue2 := AValue; DoChanged;
end;

procedure TThemedGridFormatCondition.SetStyle(const AValue: TThemedGridFormatStyle);
begin
  if FStyle = AValue then Exit;
  FStyle.Free;
  FStyle := AValue;
  DoChanged;
end;

procedure TThemedGridFormatCondition.SetTag(const AValue: TValue);
begin
  if ValuesEqual(FTag, AValue) then Exit;
  FTag := AValue; DoChanged;
end;

procedure TThemedGridFormatCondition.AddValue(const AValue: TValue);
begin
  FValues.Add(AValue);
  DoChanged;
end;

procedure TThemedGridFormatCondition.AddValues(const AValues: array of TValue);
var
  I: Integer;
  LChanged: Boolean;
begin
  LChanged := False;
  for I := 0 to High(AValues) do
  begin
    FValues.Add(AValues[I]);
    LChanged := True;
  end;
  if LChanged then
    DoChanged;
end;

procedure TThemedGridFormatCondition.ClearValues;
begin
  if FValues.Count = 0 then
    Exit;
  FValues.Clear;
  DoChanged;
end;

function TThemedGridFormatCondition.Clone: TThemedGridFormatCondition;
var
  I: Integer;
begin
  Result := TThemedGridFormatCondition.Create;
  Result.FEnabled := FEnabled;
  Result.FColumnName := FColumnName;
  Result.FTargetColumnName := FTargetColumnName;
  Result.FOperator := FOperator;
  Result.FValue := FValue;
  Result.FValue2 := FValue2;
  if FStyle <> nil then
    Result.FStyle := FStyle.Clone;
  Result.FPredicate := FPredicate;
  Result.FTag := FTag;
  for I := 0 to FValues.Count - 1 do
    Result.FValues.Add(FValues[I]);
end;

class function TThemedGridFormatCondition.New(const AColumnName: string; const AOperator: TThemedGridFormatConditionOperator; const AValue: TValue; const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition;
begin
  Result := TThemedGridFormatCondition.Create;
  Result.FColumnName := AColumnName;
  Result.FTargetColumnName := AColumnName;
  Result.FOperator := AOperator;
  Result.FValue := AValue;
  Result.FStyle := AStyle;
end;

class function TThemedGridFormatCondition.Row(const AColumnName: string; const AOperator: TThemedGridFormatConditionOperator; const AValue: TValue; const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition;
begin
  Result := TThemedGridFormatCondition.Create;
  Result.FColumnName := AColumnName;
  Result.FTargetColumnName := '';
  Result.FOperator := AOperator;
  Result.FValue := AValue;
  Result.FStyle := AStyle;
end;

class function TThemedGridFormatCondition.Between(const AColumnName: string; const AValue, AValue2: TValue; const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition;
begin
  Result := TThemedGridFormatCondition.Create;
  Result.FColumnName := AColumnName;
  Result.FTargetColumnName := AColumnName;
  Result.FOperator := TThemedGridFormatConditionOperator.Between;
  Result.FValue := AValue;
  Result.FValue2 := AValue2;
  Result.FStyle := AStyle;
end;

class function TThemedGridFormatCondition.MakeIn(const AColumnName: string; const AValues: array of TValue; const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition;
begin
  Result := TThemedGridFormatCondition.Create;
  Result.FColumnName := AColumnName;
  Result.FTargetColumnName := AColumnName;
  Result.FOperator := TThemedGridFormatConditionOperator.&In;
  Result.FStyle := AStyle;
  Result.AddValues(AValues);
end;

class function TThemedGridFormatCondition.MakeNotIn(const AColumnName: string; const AValues: array of TValue; const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition;
begin
  Result := TThemedGridFormatCondition.Create;
  Result.FColumnName := AColumnName;
  Result.FTargetColumnName := AColumnName;
  Result.FOperator := TThemedGridFormatConditionOperator.NotIn;
  Result.FStyle := AStyle;
  Result.AddValues(AValues);
end;

class function TThemedGridFormatCondition.Custom(const APredicate: TThemedGridFormatConditionPredicate; const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition;
begin
  Result := TThemedGridFormatCondition.Create;
  Result.FOperator := TThemedGridFormatConditionOperator.Custom;
  Result.FPredicate := APredicate;
  Result.FStyle := AStyle;
end;

end.

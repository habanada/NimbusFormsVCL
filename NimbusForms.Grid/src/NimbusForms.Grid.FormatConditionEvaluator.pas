unit NimbusForms.Grid.FormatConditionEvaluator;

{$SCOPEDENUMS ON}

interface

uses
  System.SysUtils,
  System.Rtti,
  System.Generics.Collections,
  NimbusForms.Grid.FormatCondition,
  NimbusForms.Grid.FormatConditionContext;

type
  TThemedGridFormatConditionEvaluator = class
  private
    class function IsNullValue(const AValue: TValue): Boolean; static;
    class function ToText(const AValue: TValue; const ASettings: TFormatSettings): string; static;
    class function TryDecimal(const AValue: TValue; out AResult: Extended): Boolean; static;
    class function TryDate(const AValue: TValue; out AResult: TDateTime): Boolean; static;
    class function ValuesEqual(const ALeft, ARight: TValue): Boolean; static;
    class function ContainsText(const AValue, AFilter: TValue): Boolean; static;
    class function StartsWithText(const AValue, AFilter: TValue): Boolean; static;
    class function EndsWithText(const AValue, AFilter: TValue): Boolean; static;
    class function Compare(const ALeft, ARight: TValue): Integer; static;
    class function InList(const AValue: TValue; const AValues: TList<TValue>): Boolean; static;
  public
    class function Matches(const ACondition: TThemedGridFormatCondition; const AContext: TThemedGridFormatConditionContext): Boolean; static;
  end;

implementation

uses
  System.StrUtils,
  System.TypInfo,
  System.Variants,
  System.DateUtils,
  NimbusForms.Grid.Types;

class function TThemedGridFormatConditionEvaluator.IsNullValue(const AValue: TValue): Boolean;
begin
  Result := AValue.TypeInfo = nil;
  if (not Result) and (AValue.Kind = tkVariant) then
    Result := VarIsClear(AValue.AsVariant) or VarIsNull(AValue.AsVariant);
end;

class function TThemedGridFormatConditionEvaluator.ToText(const AValue: TValue; const ASettings: TFormatSettings): string;
begin
  if IsNullValue(AValue) then
    Exit('');
  if (AValue.Kind = tkFloat) and (AValue.TypeInfo <> System.TypeInfo(TDateTime)) and
     (AValue.TypeInfo <> System.TypeInfo(TDate)) and (AValue.TypeInfo <> System.TypeInfo(TTime)) then
  begin
    if AValue.TypeInfo = System.TypeInfo(Currency) then
      Exit(CurrToStr(AValue.AsCurrency, ASettings));
    Exit(FloatToStrF(AValue.AsExtended, ffGeneral, 15, 0, ASettings));
  end;
  Result := AValue.ToString;
end;

class function TThemedGridFormatConditionEvaluator.TryDecimal(const AValue: TValue; out AResult: Extended): Boolean;
var
  LText: string;
begin
  AResult := 0;
  if IsNullValue(AValue) then
    Exit(False);
  if (AValue.TypeInfo = System.TypeInfo(TDateTime)) or (AValue.TypeInfo = System.TypeInfo(TDate)) or
     (AValue.TypeInfo = System.TypeInfo(TTime)) then
    Exit(False);
  case AValue.Kind of
    tkInteger:
      begin
        AResult := AValue.AsInteger;
        Exit(True);
      end;
    tkInt64:
      begin
        AResult := AValue.AsInt64;
        Exit(True);
      end;
    tkFloat:
      begin
        if AValue.TypeInfo = System.TypeInfo(Currency) then
          AResult := AValue.AsCurrency
        else
          AResult := AValue.AsExtended;
        Exit(True);
      end;
  end;
  if AValue.IsType<Boolean> then
  begin
    if AValue.AsBoolean then
      AResult := 1
    else
      AResult := 0;
    Exit(True);
  end;
  if not (AValue.Kind in [tkString, tkLString, tkWString, tkUString]) then
    Exit(False);
  LText := AValue.ToString;
  if TryStrToFloat(LText, AResult, FormatSettings) then
    Exit(True);
  Result := TryStrToFloat(LText, AResult, TFormatSettings.Invariant);
end;

class function TThemedGridFormatConditionEvaluator.TryDate(const AValue: TValue; out AResult: TDateTime): Boolean;
var
  LText: string;
begin
  AResult := 0;
  if (AValue.TypeInfo = System.TypeInfo(TDateTime)) or (AValue.TypeInfo = System.TypeInfo(TDate)) or
     (AValue.TypeInfo = System.TypeInfo(TTime)) then
  begin
    AResult := AValue.AsExtended;
    Exit(True);
  end;
  LText := AValue.ToString;
  if TryStrToDateTime(LText, AResult, FormatSettings) then
    Exit(True);
  Result := TryStrToDateTime(LText, AResult, TFormatSettings.Invariant);
end;

class function TThemedGridFormatConditionEvaluator.ValuesEqual(const ALeft, ARight: TValue): Boolean;
var
  LLeftNull, LRightNull: Boolean;
begin
  LLeftNull := IsNullValue(ALeft);
  LRightNull := IsNullValue(ARight);
  if LLeftNull and LRightNull then
    Exit(True);
  if LLeftNull or LRightNull then
    Exit(False);
  if (ALeft.TypeInfo = ARight.TypeInfo) and (ALeft.ToString = ARight.ToString) then
    Exit(True);
  Result := SameText(ToText(ALeft, TFormatSettings.Invariant), ToText(ARight, TFormatSettings.Invariant));
end;

class function TThemedGridFormatConditionEvaluator.ContainsText(const AValue, AFilter: TValue): Boolean;
begin
  if IsNullValue(AValue) or IsNullValue(AFilter) then
    Exit(False);
  Result := System.StrUtils.ContainsText(ToText(AValue, FormatSettings), ToText(AFilter, FormatSettings));
end;

class function TThemedGridFormatConditionEvaluator.StartsWithText(const AValue, AFilter: TValue): Boolean;
begin
  if IsNullValue(AValue) or IsNullValue(AFilter) then
    Exit(False);
  Result := System.StrUtils.StartsText(ToText(AFilter, FormatSettings), ToText(AValue, FormatSettings));
end;

class function TThemedGridFormatConditionEvaluator.EndsWithText(const AValue, AFilter: TValue): Boolean;
begin
  if IsNullValue(AValue) or IsNullValue(AFilter) then
    Exit(False);
  Result := System.StrUtils.EndsText(ToText(AFilter, FormatSettings), ToText(AValue, FormatSettings));
end;

class function TThemedGridFormatConditionEvaluator.Compare(const ALeft, ARight: TValue): Integer;
var
  LLeftNumber, LRightNumber: Extended;
  LLeftDate, LRightDate: TDateTime;
begin
  if IsNullValue(ALeft) or IsNullValue(ARight) then
    Exit(-1);
  if TryDecimal(ALeft, LLeftNumber) and TryDecimal(ARight, LRightNumber) then
  begin
    if LLeftNumber < LRightNumber then
      Exit(-1);
    if LLeftNumber > LRightNumber then
      Exit(1);
    Exit(0);
  end;
  if TryDate(ALeft, LLeftDate) and TryDate(ARight, LRightDate) then
    Exit(CompareDateTime(LLeftDate, LRightDate));
  Result := CompareText(ToText(ALeft, FormatSettings), ToText(ARight, FormatSettings));
end;

class function TThemedGridFormatConditionEvaluator.InList(const AValue: TValue; const AValues: TList<TValue>): Boolean;
var
  I: Integer;
begin
  if (AValues = nil) or (AValues.Count = 0) then
    Exit(False);
  for I := 0 to AValues.Count - 1 do
    if ValuesEqual(AValue, AValues[I]) then
      Exit(True);
  Result := False;
end;

class function TThemedGridFormatConditionEvaluator.Matches(const ACondition: TThemedGridFormatCondition;
  const AContext: TThemedGridFormatConditionContext): Boolean;
var
  LValue: TValue;
begin
  if (ACondition = nil) or (AContext = nil) then
    Exit(False);
  if not ACondition.Enabled then
    Exit(False);
  if Assigned(ACondition.Predicate) then
    Exit(ACondition.Predicate(AContext));

  LValue := AContext.ConditionValue;

  case ACondition.Operator of
    TThemedGridFormatConditionOperator.Equals:
      Result := ValuesEqual(LValue, ACondition.Value);
    TThemedGridFormatConditionOperator.NotEquals:
      Result := not ValuesEqual(LValue, ACondition.Value);
    TThemedGridFormatConditionOperator.Contains:
      Result := ContainsText(LValue, ACondition.Value);
    TThemedGridFormatConditionOperator.NotContains:
      Result := not ContainsText(LValue, ACondition.Value);
    TThemedGridFormatConditionOperator.StartsWith:
      Result := StartsWithText(LValue, ACondition.Value);
    TThemedGridFormatConditionOperator.EndsWith:
      Result := EndsWithText(LValue, ACondition.Value);
    TThemedGridFormatConditionOperator.GreaterThan:
      Result := Compare(LValue, ACondition.Value) > 0;
    TThemedGridFormatConditionOperator.GreaterOrEqual:
      Result := Compare(LValue, ACondition.Value) >= 0;
    TThemedGridFormatConditionOperator.LessThan:
      Result := Compare(LValue, ACondition.Value) < 0;
    TThemedGridFormatConditionOperator.LessOrEqual:
      Result := Compare(LValue, ACondition.Value) <= 0;
    TThemedGridFormatConditionOperator.Between:
      Result := (Compare(LValue, ACondition.Value) >= 0) and (Compare(LValue, ACondition.Value2) <= 0);
    TThemedGridFormatConditionOperator.IsNull:
      Result := IsNullValue(LValue);
    TThemedGridFormatConditionOperator.IsNotNull:
      Result := not IsNullValue(LValue);
    TThemedGridFormatConditionOperator.IsEmpty:
      Result := IsNullValue(LValue) or (ToText(LValue, FormatSettings) = '');
    TThemedGridFormatConditionOperator.IsNotEmpty:
      Result := (not IsNullValue(LValue)) and (ToText(LValue, FormatSettings) <> '');
    TThemedGridFormatConditionOperator.&In:
      Result := InList(LValue, ACondition.Values);
    TThemedGridFormatConditionOperator.NotIn:
      Result := not InList(LValue, ACondition.Values);
  else
    Result := False;
  end;
end;

end.

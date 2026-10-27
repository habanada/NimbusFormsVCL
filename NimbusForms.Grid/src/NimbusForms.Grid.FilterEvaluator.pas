unit NimbusForms.Grid.FilterEvaluator;

{$SCOPEDENUMS ON}

interface

uses
  System.Rtti,
  System.TypInfo,
  System.Generics.Collections,
  NimbusForms.Grid.FilterDescriptor;

type
  TThemedGridFilterEvaluator = class
  private
    class function TextContains(const AValue, AFilterValue: TValue; const ACaseSensitive: Boolean): Boolean; static;
    class function TextStartsWith(const AValue, AFilterValue: TValue; const ACaseSensitive: Boolean): Boolean; static;
    class function TextEndsWith(const AValue, AFilterValue: TValue; const ACaseSensitive: Boolean): Boolean; static;
    class function IsIn(const AValue: TValue; const AValues: TList<TValue>; const AValueType: PTypeInfo): Boolean; static;
    class function Compare(const ALeft, ARight: TValue; const AValueType: PTypeInfo): Integer; static;
    class function DateEquals(const AValue: TValue; const ADate: TDateTime): Boolean; static;
    class function DateInCurrentWeek(const AValue: TValue): Boolean; static;
    class function DateInCurrentMonth(const AValue: TValue): Boolean; static;
    class function DateInCurrentYear(const AValue: TValue): Boolean; static;
  public
    function Matches(const AValue: TValue; const AValueType: PTypeInfo;
      const AFilter: TThemedGridFilterDescriptor): Boolean;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  System.StrUtils,
  System.DateUtils,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.ValueConverter;

type
  TConv = TThemedGridValueConverter;

function Needle(const AFilterValue: TValue): string;
begin
  Result := TConv.ToText(AFilterValue);
end;

class function TThemedGridFilterEvaluator.TextContains(const AValue, AFilterValue: TValue;
  const ACaseSensitive: Boolean): Boolean;
var
  LLeft, LRight: string;
begin
  LLeft := TConv.ToText(AValue);
  LRight := Needle(AFilterValue);
  if LRight = '' then
    Exit(True);
  if ACaseSensitive then
    Result := ContainsStr(LLeft, LRight)
  else
    Result := ContainsText(LLeft, LRight);
end;

class function TThemedGridFilterEvaluator.TextStartsWith(const AValue, AFilterValue: TValue;
  const ACaseSensitive: Boolean): Boolean;
var
  LLeft, LRight: string;
begin
  LLeft := TConv.ToText(AValue);
  LRight := Needle(AFilterValue);
  if LRight = '' then
    Exit(True);
  if ACaseSensitive then
    Result := StartsStr(LRight, LLeft)
  else
    Result := StartsText(LRight, LLeft);
end;

class function TThemedGridFilterEvaluator.TextEndsWith(const AValue, AFilterValue: TValue;
  const ACaseSensitive: Boolean): Boolean;
var
  LLeft, LRight: string;
begin
  LLeft := TConv.ToText(AValue);
  LRight := Needle(AFilterValue);
  if LRight = '' then
    Exit(True);
  if ACaseSensitive then
    Result := EndsStr(LRight, LLeft)
  else
    Result := EndsText(LRight, LLeft);
end;

class function TThemedGridFilterEvaluator.Compare(const ALeft, ARight: TValue;
  const AValueType: PTypeInfo): Integer;
var
  LLeft, LRight, LConverted: TValue;
  LResult: Integer;
begin
  LLeft := ALeft;
  LRight := ARight;
  if TConv.IsNull(LLeft) then
    LLeft := TValue.Empty;
  if TConv.IsNull(LRight) then
    LRight := TValue.Empty;
  if (LLeft.TypeInfo = nil) and (LRight.TypeInfo = nil) then
    Exit(0);
  if LLeft.TypeInfo = nil then
    Exit(-1);
  if LRight.TypeInfo = nil then
    Exit(1);
  if TConv.TryConvert(LRight, AValueType, LConverted) then
    LRight := LConverted;
  if TConv.TryConvert(LLeft, AValueType, LConverted) then
    LLeft := LConverted;
  if TConv.TryCompare(LLeft, LRight, LResult) then
    Exit(LResult);
  Result := Sign(CompareText(TConv.ToText(LLeft), TConv.ToText(LRight), loUserLocale));
end;

class function TThemedGridFilterEvaluator.IsIn(const AValue: TValue; const AValues: TList<TValue>;
  const AValueType: PTypeInfo): Boolean;
var
  I: Integer;
begin
  if AValues = nil then
    Exit(False);
  for I := 0 to AValues.Count - 1 do
    if Compare(AValue, AValues[I], AValueType) = 0 then
      Exit(True);
  Result := False;
end;

class function TThemedGridFilterEvaluator.DateEquals(const AValue: TValue; const ADate: TDateTime): Boolean;
var
  LValueDate: TDateTime;
begin
  if not TConv.TryGetDate(AValue, LValueDate) then
    Exit(False);
  Result := DateOf(LValueDate) = DateOf(ADate);
end;

class function TThemedGridFilterEvaluator.DateInCurrentMonth(const AValue: TValue): Boolean;
var
  LValueDate, LToday: TDateTime;
begin
  if not TConv.TryGetDate(AValue, LValueDate) then
    Exit(False);
  LToday := Date;
  Result := (YearOf(LValueDate) = YearOf(LToday)) and (MonthOf(LValueDate) = MonthOf(LToday));
end;

class function TThemedGridFilterEvaluator.DateInCurrentYear(const AValue: TValue): Boolean;
var
  LValueDate: TDateTime;
begin
  if not TConv.TryGetDate(AValue, LValueDate) then
    Exit(False);
  Result := YearOf(LValueDate) = YearOf(Date);
end;

class function TThemedGridFilterEvaluator.DateInCurrentWeek(const AValue: TValue): Boolean;
var
  LValueDate, LToday, LStart, LEnd: TDateTime;
begin
  if not TConv.TryGetDate(AValue, LValueDate) then
    Exit(False);
  LToday := Date;
  LStart := IncDay(LToday, -(DayOfTheWeek(LToday) - 1));
  LEnd := IncDay(LStart, 7);
  LValueDate := DateOf(LValueDate);
  Result := (LValueDate >= LStart) and (LValueDate < LEnd);
end;

function TThemedGridFilterEvaluator.Matches(const AValue: TValue; const AValueType: PTypeInfo;
  const AFilter: TThemedGridFilterDescriptor): Boolean;
var
  LValue: TValue;
begin
  if (AFilter = nil) or (not AFilter.IsActive) then
    Exit(True);
  try
    LValue := AValue;
    if TConv.IsNull(LValue) then
      LValue := TValue.Empty;
    case AFilter.Operator of
      TThemedGridFilterOperator.IsNull:
        Exit(LValue.TypeInfo = nil);
      TThemedGridFilterOperator.IsNotNull:
        Exit(LValue.TypeInfo <> nil);
      TThemedGridFilterOperator.IsEmpty:
        Exit((LValue.TypeInfo = nil) or (Length(TConv.ToText(LValue)) = 0));
      TThemedGridFilterOperator.IsNotEmpty:
        Exit((LValue.TypeInfo <> nil) and (Length(TConv.ToText(LValue)) > 0));
      TThemedGridFilterOperator.Contains:
        Exit(TextContains(LValue, AFilter.Value, AFilter.CaseSensitive));
      TThemedGridFilterOperator.NotContains:
        Exit(not TextContains(LValue, AFilter.Value, AFilter.CaseSensitive));
      TThemedGridFilterOperator.StartsWith:
        Exit(TextStartsWith(LValue, AFilter.Value, AFilter.CaseSensitive));
      TThemedGridFilterOperator.EndsWith:
        Exit(TextEndsWith(LValue, AFilter.Value, AFilter.CaseSensitive));
      TThemedGridFilterOperator.Equals:
        Exit(Compare(LValue, AFilter.Value, AValueType) = 0);
      TThemedGridFilterOperator.NotEquals:
        Exit(Compare(LValue, AFilter.Value, AValueType) <> 0);
      TThemedGridFilterOperator.GreaterThan:
        Exit(Compare(LValue, AFilter.Value, AValueType) > 0);
      TThemedGridFilterOperator.GreaterOrEqual:
        Exit(Compare(LValue, AFilter.Value, AValueType) >= 0);
      TThemedGridFilterOperator.LessThan:
        Exit(Compare(LValue, AFilter.Value, AValueType) < 0);
      TThemedGridFilterOperator.LessOrEqual:
        Exit(Compare(LValue, AFilter.Value, AValueType) <= 0);
      TThemedGridFilterOperator.Between:
        Exit((Compare(LValue, AFilter.Value, AValueType) >= 0) and
          (Compare(LValue, AFilter.Value2, AValueType) <= 0));
      TThemedGridFilterOperator.&In:
        Exit(IsIn(LValue, AFilter.Values, AValueType));
      TThemedGridFilterOperator.NotIn:
        Exit(not IsIn(LValue, AFilter.Values, AValueType));
      TThemedGridFilterOperator.Today:
        Exit(DateEquals(LValue, Date));
      TThemedGridFilterOperator.Yesterday:
        Exit(DateEquals(LValue, IncDay(Date, -1)));
      TThemedGridFilterOperator.ThisWeek:
        Exit(DateInCurrentWeek(LValue));
      TThemedGridFilterOperator.ThisMonth:
        Exit(DateInCurrentMonth(LValue));
      TThemedGridFilterOperator.ThisYear:
        Exit(DateInCurrentYear(LValue));
    end;
  except
    on Exception do
      Exit(False);
  end;
  Result := True;
end;

end.

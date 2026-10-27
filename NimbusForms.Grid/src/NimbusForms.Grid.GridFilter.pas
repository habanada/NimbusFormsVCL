unit NimbusForms.Grid.GridFilter;

{$SCOPEDENUMS ON}

interface

uses
  System.Rtti,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.FilterDescriptor;

type
  TThemedGridFilter = class sealed
  public
    class function Make(const AColumnName: string; const AOperator: TThemedGridFilterOperator;
      const AValue: TValue): TThemedGridFilterDescriptor; static;
    class function Equals(const AColumnName: string; const AValue: TValue): TThemedGridFilterDescriptor; reintroduce; static;
    class function NotEquals(const AColumnName: string; const AValue: TValue): TThemedGridFilterDescriptor; static;
    class function Contains(const AColumnName: string; const AValue: TValue): TThemedGridFilterDescriptor; static;
    class function StartsWith(const AColumnName: string; const AValue: TValue): TThemedGridFilterDescriptor; static;
    class function EndsWith(const AColumnName: string; const AValue: TValue): TThemedGridFilterDescriptor; static;
    class function GreaterThan(const AColumnName: string; const AValue: TValue): TThemedGridFilterDescriptor; static;
    class function GreaterOrEqual(const AColumnName: string; const AValue: TValue): TThemedGridFilterDescriptor; static;
    class function LessThan(const AColumnName: string; const AValue: TValue): TThemedGridFilterDescriptor; static;
    class function LessOrEqual(const AColumnName: string; const AValue: TValue): TThemedGridFilterDescriptor; static;
    class function Between(const AColumnName: string; const AValue, AValue2: TValue): TThemedGridFilterDescriptor; static;
    class function IsNull(const AColumnName: string): TThemedGridFilterDescriptor; static;
    class function IsNotNull(const AColumnName: string): TThemedGridFilterDescriptor; static;
    class function IsEmpty(const AColumnName: string): TThemedGridFilterDescriptor; static;
    class function IsNotEmpty(const AColumnName: string): TThemedGridFilterDescriptor; static;
    class function &In(const AColumnName: string; const AValues: array of TValue): TThemedGridFilterDescriptor; static;
    class function NotIn(const AColumnName: string; const AValues: array of TValue): TThemedGridFilterDescriptor; static;
    class function Today(const AColumnName: string): TThemedGridFilterDescriptor; static;
    class function Yesterday(const AColumnName: string): TThemedGridFilterDescriptor; static;
    class function ThisWeek(const AColumnName: string): TThemedGridFilterDescriptor; static;
    class function ThisMonth(const AColumnName: string): TThemedGridFilterDescriptor; static;
    class function ThisYear(const AColumnName: string): TThemedGridFilterDescriptor; static;
  end;

implementation

class function TThemedGridFilter.Make(const AColumnName: string; const AOperator: TThemedGridFilterOperator;
  const AValue: TValue): TThemedGridFilterDescriptor;
begin
  Result := TThemedGridFilterDescriptor.Create;
  Result.ColumnName := AColumnName;
  Result.Operator := AOperator;
  Result.Value := AValue;
end;

class function TThemedGridFilter.Equals(const AColumnName: string; const AValue: TValue): TThemedGridFilterDescriptor;
begin
  Result := Make(AColumnName, TThemedGridFilterOperator.Equals, AValue);
end;

class function TThemedGridFilter.NotEquals(const AColumnName: string; const AValue: TValue): TThemedGridFilterDescriptor;
begin
  Result := Make(AColumnName, TThemedGridFilterOperator.NotEquals, AValue);
end;

class function TThemedGridFilter.Contains(const AColumnName: string; const AValue: TValue): TThemedGridFilterDescriptor;
begin
  Result := Make(AColumnName, TThemedGridFilterOperator.Contains, AValue);
end;

class function TThemedGridFilter.StartsWith(const AColumnName: string; const AValue: TValue): TThemedGridFilterDescriptor;
begin
  Result := Make(AColumnName, TThemedGridFilterOperator.StartsWith, AValue);
end;

class function TThemedGridFilter.EndsWith(const AColumnName: string; const AValue: TValue): TThemedGridFilterDescriptor;
begin
  Result := Make(AColumnName, TThemedGridFilterOperator.EndsWith, AValue);
end;

class function TThemedGridFilter.GreaterThan(const AColumnName: string; const AValue: TValue): TThemedGridFilterDescriptor;
begin
  Result := Make(AColumnName, TThemedGridFilterOperator.GreaterThan, AValue);
end;

class function TThemedGridFilter.GreaterOrEqual(const AColumnName: string; const AValue: TValue): TThemedGridFilterDescriptor;
begin
  Result := Make(AColumnName, TThemedGridFilterOperator.GreaterOrEqual, AValue);
end;

class function TThemedGridFilter.LessThan(const AColumnName: string; const AValue: TValue): TThemedGridFilterDescriptor;
begin
  Result := Make(AColumnName, TThemedGridFilterOperator.LessThan, AValue);
end;

class function TThemedGridFilter.LessOrEqual(const AColumnName: string; const AValue: TValue): TThemedGridFilterDescriptor;
begin
  Result := Make(AColumnName, TThemedGridFilterOperator.LessOrEqual, AValue);
end;

class function TThemedGridFilter.Between(const AColumnName: string; const AValue, AValue2: TValue): TThemedGridFilterDescriptor;
begin
  Result := Make(AColumnName, TThemedGridFilterOperator.Between, AValue);
  Result.Value2 := AValue2;
end;

class function TThemedGridFilter.IsNull(const AColumnName: string): TThemedGridFilterDescriptor;
begin
  Result := Make(AColumnName, TThemedGridFilterOperator.IsNull, TValue.Empty);
end;

class function TThemedGridFilter.IsNotNull(const AColumnName: string): TThemedGridFilterDescriptor;
begin
  Result := Make(AColumnName, TThemedGridFilterOperator.IsNotNull, TValue.Empty);
end;

class function TThemedGridFilter.IsEmpty(const AColumnName: string): TThemedGridFilterDescriptor;
begin
  Result := Make(AColumnName, TThemedGridFilterOperator.IsEmpty, TValue.Empty);
end;

class function TThemedGridFilter.IsNotEmpty(const AColumnName: string): TThemedGridFilterDescriptor;
begin
  Result := Make(AColumnName, TThemedGridFilterOperator.IsNotEmpty, TValue.Empty);
end;

class function TThemedGridFilter.&In(const AColumnName: string; const AValues: array of TValue): TThemedGridFilterDescriptor;
var
  I: Integer;
begin
  Result := Make(AColumnName, TThemedGridFilterOperator.&In, TValue.Empty);
  for I := 0 to High(AValues) do
    Result.Values.Add(AValues[I]);
end;

class function TThemedGridFilter.NotIn(const AColumnName: string; const AValues: array of TValue): TThemedGridFilterDescriptor;
begin
  Result := &In(AColumnName, AValues);
  Result.Operator := TThemedGridFilterOperator.NotIn;
end;

class function TThemedGridFilter.Today(const AColumnName: string): TThemedGridFilterDescriptor;
begin
  Result := Make(AColumnName, TThemedGridFilterOperator.Today, TValue.Empty);
end;

class function TThemedGridFilter.Yesterday(const AColumnName: string): TThemedGridFilterDescriptor;
begin
  Result := Make(AColumnName, TThemedGridFilterOperator.Yesterday, TValue.Empty);
end;

class function TThemedGridFilter.ThisWeek(const AColumnName: string): TThemedGridFilterDescriptor;
begin
  Result := Make(AColumnName, TThemedGridFilterOperator.ThisWeek, TValue.Empty);
end;

class function TThemedGridFilter.ThisMonth(const AColumnName: string): TThemedGridFilterDescriptor;
begin
  Result := Make(AColumnName, TThemedGridFilterOperator.ThisMonth, TValue.Empty);
end;

class function TThemedGridFilter.ThisYear(const AColumnName: string): TThemedGridFilterDescriptor;
begin
  Result := Make(AColumnName, TThemedGridFilterOperator.ThisYear, TValue.Empty);
end;

end.

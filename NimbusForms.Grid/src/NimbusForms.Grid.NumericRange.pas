unit NimbusForms.Grid.NumericRange;

{$SCOPEDENUMS ON}

interface

uses
  System.SysUtils,
  System.Math,
  System.Rtti,
  System.TypInfo,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.EditorOptions;

type
  TThemedGridNumericRange = record
  public
    const
      PercentValueScale = 100.0;
      PercentMinimum = 0.0;
      PercentMaximum = 100.0;
      MaximumDecimalPlaces = 6;
      DefaultDecimalPlaces = 2;
  private
    FMinimum: Extended;
    FMaximum: Extended;
    FIncrement: Extended;
    FValueScale: Extended;
    FDecimalPlaces: Integer;
    FStoredDecimalPlaces: Integer;
    FIsPercent: Boolean;
    FHasRange: Boolean;
    FIsIntegral: Boolean;
    FValueType: PTypeInfo;
    function GetIncrement: Extended;
    function GetValueScale: Extended;
  public
    class function Resolve(const AColumn: TThemedGridColumn; const AValueType: PTypeInfo): TThemedGridNumericRange; static;
    function ToDisplayValue(const AStoredValue: TValue): Extended;
    function ToStoredValue(const ADisplayValue: Extended): Extended;
    function ClampDisplayValue(const ADisplayValue: Extended): Extended;
    function RoundDisplayValue(const ADisplayValue: Extended): Extended;
    function GetNormalizedValue(const AStoredValue: TValue): Extended;
    function GetEffectiveMinimum: Extended;
    function GetEffectiveMaximum(const AReferenceStoredValue: TValue): Extended;
    function GetDisplayValueFromRatio(const ARatio: Extended): Extended; overload;
    function GetDisplayValueFromRatio(const ARatio: Extended; const AReferenceStoredValue: TValue): Extended; overload;
    function FormatDisplayValue(const ADisplayValue: Extended): string;
    function TryParseDisplayValue(const AText: string; out ADisplayValue: Extended): Boolean;
    function ConvertToValueType(const AStoredValue: Extended): TValue;
    class function IsPercentFormat(const AFormatString: string): Boolean; static;
    class function IsNumericType(const AValueType: PTypeInfo): Boolean; static;
    property Minimum: Extended read FMinimum;
    property Maximum: Extended read FMaximum;
    property Increment: Extended read GetIncrement;
    property ValueScale: Extended read GetValueScale;
    property DecimalPlaces: Integer read FDecimalPlaces;
    property IsPercent: Boolean read FIsPercent;
    property HasRange: Boolean read FHasRange;
    property IsIntegral: Boolean read FIsIntegral;
    property ValueType: PTypeInfo read FValueType;
  end;

implementation

uses
  System.Character,
  NimbusForms.Grid.ValueFormatter;

function RoundAwayFromZero(const AValue: Extended; const APlaces: Integer): Extended;
var
  LFactor, LScaled: Extended;
begin
  if (APlaces < 0) or (APlaces > 15) then
    Exit(AValue);
  LFactor := Power(10.0, APlaces);
  LScaled := AValue * LFactor;
  if LScaled >= 0 then
    Result := Int(LScaled + 0.5) / LFactor
  else
    Result := Int(LScaled - 0.5) / LFactor;
end;

function IsIntegralTypeInfo(const AValueType: PTypeInfo): Boolean;
begin
  Result := (AValueType <> nil) and (AValueType.Kind in [tkInteger, tkInt64]);
end;

function ResolveDecimalPlacesFor(const AFormatString: string; const AIsIntegral: Boolean): Integer;
var
  LSpecifier: Char;
  LDigits: string;
  LPlaces, LSeparatorIndex, LCount, I: Integer;
  C: Char;
begin
  if AIsIntegral then
    Exit(0);
  if AFormatString = '' then
    Exit(TThemedGridNumericRange.DefaultDecimalPlaces);
  LSpecifier := AFormatString[1];
  if CharInSet(LSpecifier, ['N', 'n', 'F', 'f', 'C', 'c', 'P', 'p', 'E', 'e']) then
  begin
    LDigits := Trim(Copy(AFormatString, 2, Length(AFormatString) - 1));
    if LDigits = '' then
      Exit(TThemedGridNumericRange.DefaultDecimalPlaces);
    if TryStrToInt(LDigits, LPlaces) then
      Exit(LPlaces);
    Exit(TThemedGridNumericRange.DefaultDecimalPlaces);
  end;
  LSeparatorIndex := Pos('.', AFormatString);
  if LSeparatorIndex <= 0 then
    Exit(TThemedGridNumericRange.DefaultDecimalPlaces);
  LCount := 0;
  for I := LSeparatorIndex + 1 to Length(AFormatString) do
  begin
    C := AFormatString[I];
    if (C <> '0') and (C <> '#') then
      Break;
    Inc(LCount);
  end;
  Result := LCount;
end;

function ResolveIncrementFor(const ADecimalPlaces: Integer): Extended;
var
  I: Integer;
begin
  if ADecimalPlaces <= 0 then
    Exit(1);
  Result := 1;
  for I := 0 to ADecimalPlaces - 1 do
    Result := Result / 10;
end;

function GetScaleDigits(const AValueScale: Extended): Integer;
var
  LScale: Extended;
  LDigits: Integer;
begin
  LScale := Abs(AValueScale);
  if LScale <= 1 then
    Exit(0);
  LDigits := 0;
  while (LScale >= 10) and (LDigits < 6) do
  begin
    LScale := LScale / 10;
    Inc(LDigits);
  end;
  if SameValue(LScale, 1) then
    Result := LDigits
  else
    Result := 0;
end;

function BuildEditFormat(const ADecimalPlaces: Integer): string;
begin
  if ADecimalPlaces <= 0 then
    Exit('0');
  Result := '0.' + StringOfChar('#', ADecimalPlaces);
end;

function CleanNumericText(const AText: string): string;
var
  LBuilder: TStringBuilder;
  I: Integer;
  C: Char;
begin
  LBuilder := TStringBuilder.Create;
  try
    for I := 1 to Length(AText) do
    begin
      C := AText[I];
      if C = '%' then
        Continue;
      if C.IsWhiteSpace then
        Continue;
      if C.IsDigit or (C = '-') or (C = '+') or (C = '.') or (C = ',') or (C = '(') or (C = ')') then
        LBuilder.Append(C);
    end;
    Result := LBuilder.ToString;
  finally
    LBuilder.Free;
  end;
end;


function TThemedGridNumericRange.GetIncrement: Extended;
begin
  if FIncrement = 0 then
    Result := 1
  else
    Result := FIncrement;
end;

function TThemedGridNumericRange.GetValueScale: Extended;
begin
  if FValueScale = 0 then
    Result := 1
  else
    Result := FValueScale;
end;

class function TThemedGridNumericRange.IsPercentFormat(const AFormatString: string): Boolean;
var
  I: Integer;
  C: Char;
begin
  if AFormatString = '' then
    Exit(False);
  if Pos('%', AFormatString) > 0 then
    Exit(True);
  for I := 1 to Length(AFormatString) do
  begin
    C := AFormatString[I];
    if C.IsWhiteSpace then
      Continue;
    Exit((C = 'P') or (C = 'p'));
  end;
  Result := False;
end;

class function TThemedGridNumericRange.IsNumericType(const AValueType: PTypeInfo): Boolean;
begin
  if AValueType = nil then
    Exit(False);
  Result := (AValueType.Kind in [tkInteger, tkInt64, tkFloat]);
end;

class function TThemedGridNumericRange.Resolve(const AColumn: TThemedGridColumn;
  const AValueType: PTypeInfo): TThemedGridNumericRange;
var
  LActualType: PTypeInfo;
  LIsIntegral, LIsPercent, LHasRange: Boolean;
  LFormatString: string;
  LOptions: TThemedGridEditorOptions;
  LValueScale, LMinimum, LMaximum, LIncrement: Extended;
  LDecimalPlaces, LStoredDecimalPlaces: Integer;
begin
  LActualType := AValueType;
  if (LActualType = nil) and (AColumn <> nil) then
    LActualType := AColumn.ValueType;
  LIsIntegral := IsIntegralTypeInfo(LActualType);

  if AColumn <> nil then
    LFormatString := AColumn.FormatString
  else
    LFormatString := '';
  if AColumn <> nil then
    LOptions := AColumn.EditorOptions
  else
    LOptions := nil;

  LIsPercent := (AColumn <> nil) and (AColumn.RenderKind = TThemedGridCellRenderKind.Percent);
  if (not LIsPercent) and IsPercentFormat(LFormatString) then
    LIsPercent := True;

  if (LOptions <> nil) and LOptions.HasValueScale then
    LValueScale := LOptions.ValueScale
  else if LIsPercent then
    LValueScale := PercentValueScale
  else
    LValueScale := 1;
  if LValueScale = 0 then
    LValueScale := 1;

  if (LOptions <> nil) and LOptions.HasRange then
  begin
    LHasRange := True;
    if LOptions.HasMinimum then
      LMinimum := LOptions.Minimum
    else if LIsPercent then
      LMinimum := PercentMinimum
    else
      LMinimum := -1.0E30;
    if LOptions.HasMaximum then
      LMaximum := LOptions.Maximum
    else if LIsPercent then
      LMaximum := PercentMaximum
    else
      LMaximum := 1.0E30;
  end
  else if LIsPercent then
  begin
    LHasRange := True;
    LMinimum := PercentMinimum;
    LMaximum := PercentMaximum;
  end
  else
  begin
    LHasRange := False;
    LMinimum := -1.0E30;
    LMaximum := 1.0E30;
  end;

  if LHasRange and (LMaximum < LMinimum) then
    LMaximum := LMinimum;

  if (LOptions <> nil) and LOptions.HasDecimalPlaces then
    LDecimalPlaces := LOptions.DecimalPlaces
  else
    LDecimalPlaces := ResolveDecimalPlacesFor(LFormatString, LIsIntegral);
  if LDecimalPlaces < 0 then
    LDecimalPlaces := 0;
  if LDecimalPlaces > MaximumDecimalPlaces then
    LDecimalPlaces := MaximumDecimalPlaces;
  if LIsIntegral then
    LDecimalPlaces := 0;

  if (LOptions <> nil) and LOptions.HasIncrement then
    LIncrement := LOptions.Increment
  else
    LIncrement := ResolveIncrementFor(LDecimalPlaces);
  if LIncrement <= 0 then
    LIncrement := 1;

  if LIsIntegral then
    LStoredDecimalPlaces := 0
  else
    LStoredDecimalPlaces := Min(MaximumDecimalPlaces + 3, LDecimalPlaces + GetScaleDigits(LValueScale));

  Result.FMinimum := LMinimum;
  Result.FMaximum := LMaximum;
  Result.FIncrement := LIncrement;
  Result.FValueScale := LValueScale;
  Result.FDecimalPlaces := LDecimalPlaces;
  Result.FStoredDecimalPlaces := LStoredDecimalPlaces;
  Result.FIsPercent := LIsPercent;
  Result.FHasRange := LHasRange;
  Result.FIsIntegral := LIsIntegral;
  Result.FValueType := LActualType;
end;

function TThemedGridNumericRange.ToDisplayValue(const AStoredValue: TValue): Extended;
begin
  Result := TThemedGridValueFormatter.ToDecimal(AStoredValue) * GetValueScale;
end;

function TThemedGridNumericRange.ToStoredValue(const ADisplayValue: Extended): Extended;
var
  LValue: Extended;
begin
  LValue := ADisplayValue / GetValueScale;
  if (FStoredDecimalPlaces >= 0) and (FStoredDecimalPlaces <= 15) then
    LValue := RoundAwayFromZero(LValue, FStoredDecimalPlaces);
  Result := LValue;
end;

function TThemedGridNumericRange.ClampDisplayValue(const ADisplayValue: Extended): Extended;
begin
  if not FHasRange then
    Exit(ADisplayValue);
  if ADisplayValue < FMinimum then
    Exit(FMinimum);
  if ADisplayValue > FMaximum then
    Exit(FMaximum);
  Result := ADisplayValue;
end;

function TThemedGridNumericRange.RoundDisplayValue(const ADisplayValue: Extended): Extended;
begin
  if (FDecimalPlaces < 0) or (FDecimalPlaces > 15) then
    Exit(ADisplayValue);
  Result := RoundAwayFromZero(ADisplayValue, FDecimalPlaces);
end;

function TThemedGridNumericRange.GetEffectiveMinimum: Extended;
begin
  if FHasRange then
    Result := FMinimum
  else
    Result := 0;
end;

function TThemedGridNumericRange.GetEffectiveMaximum(const AReferenceStoredValue: TValue): Extended;
begin
  if FHasRange then
    Exit(FMaximum);
  if ToDisplayValue(AReferenceStoredValue) > 1 then
    Result := 100
  else
    Result := 1;
end;

function TThemedGridNumericRange.GetNormalizedValue(const AStoredValue: TValue): Extended;
var
  LDisplayValue, LMinimum, LMaximum, LRatio: Extended;
begin
  LDisplayValue := ToDisplayValue(AStoredValue);
  LMinimum := GetEffectiveMinimum;
  LMaximum := GetEffectiveMaximum(AStoredValue);
  if LMaximum <= LMinimum then
    Exit(0);
  LRatio := (LDisplayValue - LMinimum) / (LMaximum - LMinimum);
  if LRatio < 0 then
    Exit(0);
  if LRatio > 1 then
    Exit(1);
  Result := LRatio;
end;

function TThemedGridNumericRange.GetDisplayValueFromRatio(const ARatio: Extended): Extended;
begin
  Result := GetDisplayValueFromRatio(ARatio, TValue.Empty);
end;

function TThemedGridNumericRange.GetDisplayValueFromRatio(const ARatio: Extended;
  const AReferenceStoredValue: TValue): Extended;
var
  LRatio, LMinimum, LMaximum, LValue, LIncrement: Extended;
begin
  LRatio := ARatio;
  if LRatio < 0 then
    LRatio := 0;
  if LRatio > 1 then
    LRatio := 1;
  LMinimum := GetEffectiveMinimum;
  LMaximum := GetEffectiveMaximum(AReferenceStoredValue);
  if LMaximum <= LMinimum then
    Exit(LMinimum);
  LValue := LMinimum + ((LMaximum - LMinimum) * LRatio);
  LIncrement := GetIncrement;
  if (LIncrement > 0) and (LIncrement * 2 <= LMaximum - LMinimum) then
    LValue := RoundAwayFromZero(LValue / LIncrement, 0) * LIncrement
  else
    LValue := RoundAwayFromZero(LValue, Min(6, FStoredDecimalPlaces + 2));
  if LValue < LMinimum then
    LValue := LMinimum;
  if LValue > LMaximum then
    LValue := LMaximum;
  Result := ClampDisplayValue(LValue);
end;

function TThemedGridNumericRange.FormatDisplayValue(const ADisplayValue: Extended): string;
var
  LRounded: Extended;
begin
  LRounded := RoundDisplayValue(ADisplayValue);
  Result := FormatFloat(BuildEditFormat(FDecimalPlaces), LRounded);
end;

function TThemedGridNumericRange.TryParseDisplayValue(const AText: string; out ADisplayValue: Extended): Boolean;
var
  LCleaned: string;
begin
  ADisplayValue := 0;
  if AText = '' then
    Exit(False);
  LCleaned := CleanNumericText(AText);
  if LCleaned = '' then
    Exit(False);
  if TryStrToFloat(LCleaned, ADisplayValue, FormatSettings) then
    Exit(True);
  if TryStrToFloat(LCleaned, ADisplayValue, TFormatSettings.Invariant) then
    Exit(True);
  Result := False;
end;

function TThemedGridNumericRange.ConvertToValueType(const AStoredValue: Extended): TValue;
begin
  if FValueType = nil then
    Exit(TValue.From<Extended>(AStoredValue));
  if FValueType = System.TypeInfo(Currency) then
    Exit(TValue.From<Currency>(AStoredValue));
  if FValueType = System.TypeInfo(Double) then
    Exit(TValue.From<Double>(AStoredValue));
  if FValueType = System.TypeInfo(Single) then
    Exit(TValue.From<Single>(AStoredValue));
  case FValueType.Kind of
    tkInteger:
      Exit(TValue.From<Integer>(Integer(Trunc(RoundAwayFromZero(AStoredValue, 0)))));
    tkInt64:
      Exit(TValue.From<Int64>(Trunc(RoundAwayFromZero(AStoredValue, 0))));
  end;
  if FValueType.Kind = tkUString then
    Exit(TValue.From<string>(FloatToStrF(AStoredValue, ffGeneral, 15, 0)));
  Result := TValue.From<Extended>(AStoredValue);
end;

end.

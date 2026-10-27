unit NimbusForms.Charts.Financial.Indicators;

interface

uses System.SysUtils, System.Math, System.Generics.Collections, NimbusForms.Charts.Financial.Types;

type
  TNimbusFinancialValues = TArray<Double>;
  TNimbusFinancialCandleArray = TArray<TNimbusFinancialDataPoint>;
  TNimbusFinancialMacdValues = record
    FastEma, SlowEma, Line, Signal, Histogram: TNimbusFinancialValues;
  end;
  TNimbusFinancialBollingerValues = record
    Middle, Upper, Lower, Deviation: TNimbusFinancialValues;
  end;
  TNimbusFinancialStochasticValues = record
    RawK, K, D: TNimbusFinancialValues;
  end;
  TNimbusFinancialRsiValues = record
    Rsi, AverageGain, AverageLoss: TNimbusFinancialValues;
  end;
  TNimbusFinancialAtrValues = record
    TrueRange, Atr: TNimbusFinancialValues;
  end;
  TNimbusFinancialIndicators = class sealed
  public
    class function NaNArray(const Count: Integer): TNimbusFinancialValues; static;
    class function NormalizePeriods(const Text: string): TArray<Integer>; static;
    class function OrderedCandles(Data: TNimbusFinancialDataPointCollection): TNimbusFinancialCandleArray; static;
    class function Closes(const Candles: TNimbusFinancialCandleArray): TNimbusFinancialValues; static;
    class function Sma(const Values: TNimbusFinancialValues; const Period: Integer): TNimbusFinancialValues; static;
    class function Ema(const Values: TNimbusFinancialValues; const Period: Integer): TNimbusFinancialValues; static;
    class function Bollinger(const Values: TNimbusFinancialValues; const Period: Integer; const Multiplier: Double): TNimbusFinancialBollingerValues; static;
    class function Macd(const Values: TNimbusFinancialValues; const FastPeriod, SlowPeriod, SignalPeriod: Integer): TNimbusFinancialMacdValues; static;
    class function Rsi(const Values: TNimbusFinancialValues; const Period: Integer): TNimbusFinancialRsiValues; static;
    class function Stochastic(const Candles: TNimbusFinancialCandleArray; const Period, SmoothKPeriod, DPeriod: Integer): TNimbusFinancialStochasticValues; static;
    class function Atr(const Candles: TNimbusFinancialCandleArray; const Period: Integer): TNimbusFinancialAtrValues; static;
    class function Vwap(const Candles: TNimbusFinancialCandleArray; const ResetBySession: Boolean): TNimbusFinancialValues; static;
  end;

implementation

uses System.Generics.Defaults, System.Classes;

function Finite(const Value: Double): Boolean;
begin Result := not IsNan(Value) and not IsInfinite(Value) end;

class function TNimbusFinancialIndicators.NaNArray(const Count: Integer): TNimbusFinancialValues;
var I: Integer;
begin SetLength(Result, Max(0, Count)); for I := 0 to High(Result) do Result[I] := NaN end;

class function TNimbusFinancialIndicators.NormalizePeriods(const Text: string): TArray<Integer>;
var Parts: TArray<string>; Part: string; Period: Integer; Values: TList<Integer>;
begin
  Values := TList<Integer>.Create;
  try
    Parts := Text.Split([',', ';', ' ']);
    for Part in Parts do if TryStrToInt(Trim(Part), Period) and (Period >= 2) and (Period <= 1000) then
      if not Values.Contains(Period) then Values.Add(Period);
    Values.Sort; Result := Values.ToArray;
  finally Values.Free end;
end;

class function TNimbusFinancialIndicators.OrderedCandles(Data: TNimbusFinancialDataPointCollection): TNimbusFinancialCandleArray;
var I, N: Integer;
begin
  if Data = nil then raise EArgumentNilException.Create('Data');
  SetLength(Result, Data.Count); N := 0;
  for I := 0 to Data.Count - 1 do if Data[I].Visible and Data[I].IsValid then begin Result[N] := Data[I]; Inc(N) end;
  SetLength(Result, N);
  TArray.Sort<TNimbusFinancialDataPoint>(Result, TComparer<TNimbusFinancialDataPoint>.Construct(
    function(const Left, Right: TNimbusFinancialDataPoint): Integer
    begin if Left.XValue < Right.XValue then Result := -1 else if Left.XValue > Right.XValue then Result := 1 else Result := Left.Index - Right.Index end));
end;

class function TNimbusFinancialIndicators.Closes(const Candles: TNimbusFinancialCandleArray): TNimbusFinancialValues;
var I: Integer;
begin SetLength(Result, Length(Candles)); for I := 0 to High(Candles) do Result[I] := Candles[I].Close end;

class function TNimbusFinancialIndicators.Sma(const Values: TNimbusFinancialValues; const Period: Integer): TNimbusFinancialValues;
var I, ValidCount: Integer; Sum: Double;
begin
  if Period < 1 then raise EArgumentOutOfRangeException.Create('Period');
  Result := NaNArray(Length(Values)); Sum := 0; ValidCount := 0;
  for I := 0 to High(Values) do
  begin
    if Finite(Values[I]) then begin Sum := Sum + Values[I]; Inc(ValidCount) end;
    if I >= Period then if Finite(Values[I - Period]) then begin Sum := Sum - Values[I - Period]; Dec(ValidCount) end;
    if (I >= Period - 1) and (ValidCount = Period) then Result[I] := Sum / Period;
  end;
end;

class function TNimbusFinancialIndicators.Ema(const Values: TNimbusFinancialValues; const Period: Integer): TNimbusFinancialValues;
var I, ValidCount: Integer; Sum, Average, Multiplier: Double;
begin
  if Period < 2 then raise EArgumentOutOfRangeException.Create('Period');
  Result := NaNArray(Length(Values)); Sum := 0; ValidCount := 0; Average := NaN; Multiplier := 2 / (Period + 1);
  for I := 0 to High(Values) do
  begin
    if not Finite(Values[I]) then Continue;
    if ValidCount < Period then
    begin
      Sum := Sum + Values[I]; Inc(ValidCount);
      if ValidCount = Period then begin Average := Sum / Period; Result[I] := Average end;
    end
    else begin Average := (Values[I] - Average) * Multiplier + Average; Result[I] := Average end;
  end;
end;

class function TNimbusFinancialIndicators.Bollinger(const Values: TNimbusFinancialValues; const Period: Integer; const Multiplier: Double): TNimbusFinancialBollingerValues;
var I, J: Integer; Sum, Delta: Double; Valid: Boolean;
begin
  if (Period < 2) or not Finite(Multiplier) or (Multiplier <= 0) then raise EArgumentOutOfRangeException.Create('Bollinger parameters');
  Result.Middle := Sma(Values, Period); Result.Upper := NaNArray(Length(Values));
  Result.Lower := NaNArray(Length(Values)); Result.Deviation := NaNArray(Length(Values));
  for I := Period - 1 to High(Values) do
  begin
    if not Finite(Result.Middle[I]) then Continue; Sum := 0; Valid := True;
    for J := I - Period + 1 to I do
      if not Finite(Values[J]) then begin Valid := False; Break end
      else begin Delta := Values[J] - Result.Middle[I]; Sum := Sum + Delta * Delta end;
    if not Valid then Continue;
    Result.Deviation[I] := Sqrt(Max(0.0, Sum / Period));
    Result.Upper[I] := Result.Middle[I] + Multiplier * Result.Deviation[I];
    Result.Lower[I] := Result.Middle[I] - Multiplier * Result.Deviation[I];
  end;
end;

class function TNimbusFinancialIndicators.Macd(const Values: TNimbusFinancialValues; const FastPeriod, SlowPeriod, SignalPeriod: Integer): TNimbusFinancialMacdValues;
var I: Integer;
begin
  if (FastPeriod < 2) or (SlowPeriod <= FastPeriod) or (SignalPeriod < 2) then raise EArgumentOutOfRangeException.Create('MACD parameters');
  Result.FastEma := Ema(Values, FastPeriod); Result.SlowEma := Ema(Values, SlowPeriod);
  Result.Line := NaNArray(Length(Values));
  for I := 0 to High(Values) do if Finite(Result.FastEma[I]) and Finite(Result.SlowEma[I]) then Result.Line[I] := Result.FastEma[I] - Result.SlowEma[I];
  Result.Signal := Ema(Result.Line, SignalPeriod); Result.Histogram := NaNArray(Length(Values));
  for I := 0 to High(Values) do if Finite(Result.Line[I]) and Finite(Result.Signal[I]) then Result.Histogram[I] := Result.Line[I] - Result.Signal[I];
end;

class function TNimbusFinancialIndicators.Rsi(const Values: TNimbusFinancialValues; const Period: Integer): TNimbusFinancialRsiValues;
var I, P: Integer; Gain, Loss, Change: Double;
  procedure Store(const Index: Integer);
  begin
    Result.AverageGain[Index] := Gain; Result.AverageLoss[Index] := Loss;
    if Loss <= 0 then begin if Gain <= 0 then Result.Rsi[Index] := 50 else Result.Rsi[Index] := 100 end
    else Result.Rsi[Index] := EnsureRange(100 - 100 / (1 + Gain / Loss), 0.0, 100.0);
  end;
begin
  P := EnsureRange(Period, 2, 500); Result.Rsi := NaNArray(Length(Values));
  Result.AverageGain := NaNArray(Length(Values)); Result.AverageLoss := NaNArray(Length(Values));
  if Length(Values) <= P then Exit; Gain := 0; Loss := 0;
  for I := 1 to P do begin Change := Values[I] - Values[I - 1]; if Change >= 0 then Gain := Gain + Change else Loss := Loss - Change end;
  Gain := Gain / P; Loss := Loss / P; Store(P);
  for I := P + 1 to High(Values) do
  begin
    Change := Values[I] - Values[I - 1]; Gain := (Gain * (P - 1) + Max(0.0, Change)) / P;
    Loss := (Loss * (P - 1) + Max(0.0, -Change)) / P; Store(I);
  end;
end;

class function TNimbusFinancialIndicators.Stochastic(const Candles: TNimbusFinancialCandleArray; const Period, SmoothKPeriod, DPeriod: Integer): TNimbusFinancialStochasticValues;
var I, J: Integer; Low, High, Span: Double;
begin
  if (Period < 2) or (SmoothKPeriod < 1) or (DPeriod < 1) then raise EArgumentOutOfRangeException.Create('Stochastic parameters');
  Result.RawK := NaNArray(Length(Candles));
  for I := Period - 1 to System.High(Candles) do
  begin
    Low := MaxDouble; High := -MaxDouble;
    for J := I - Period + 1 to I do begin Low := Min(Low, Candles[J].Low); High := Max(High, Candles[J].High) end;
    Span := High - Low; if Span <= 0 then Result.RawK[I] := 50 else Result.RawK[I] := (Candles[I].Close - Low) / Span * 100;
  end;
  Result.K := Sma(Result.RawK, SmoothKPeriod); Result.D := Sma(Result.K, DPeriod);
end;

class function TNimbusFinancialIndicators.Atr(const Candles: TNimbusFinancialCandleArray; const Period: Integer): TNimbusFinancialAtrValues;
var I: Integer; TR, Sum, Average: Double;
begin
  if Period < 2 then raise EArgumentOutOfRangeException.Create('ATR period');
  Result.TrueRange := NaNArray(Length(Candles)); Result.Atr := NaNArray(Length(Candles)); Sum := 0; Average := NaN;
  for I := 0 to High(Candles) do
  begin
    TR := Candles[I].High - Candles[I].Low;
    if I > 0 then TR := Max(TR, Max(Abs(Candles[I].High - Candles[I - 1].Close), Abs(Candles[I].Low - Candles[I - 1].Close)));
    Result.TrueRange[I] := TR;
    if I < Period then begin Sum := Sum + TR; if I = Period - 1 then Average := Sum / Period end
    else Average := (Average * (Period - 1) + TR) / Period;
    Result.Atr[I] := Average;
  end;
end;

class function TNimbusFinancialIndicators.Vwap(const Candles: TNimbusFinancialCandleArray; const ResetBySession: Boolean): TNimbusFinancialValues;
var I: Integer; PriceVolume, Volume: Double; PreviousDate, Date: Int64;
begin
  Result := NaNArray(Length(Candles)); PriceVolume := 0; Volume := 0; PreviousDate := Low(Int64);
  for I := 0 to High(Candles) do
  begin
    Date := Trunc(Candles[I].XValue);
    if ResetBySession and (Date <> PreviousDate) then begin PriceVolume := 0; Volume := 0 end;
    PriceVolume := PriceVolume + (Candles[I].High + Candles[I].Low + Candles[I].Close) / 3 * Candles[I].Volume;
    Volume := Volume + Candles[I].Volume; if Volume > 0 then Result[I] := PriceVolume / Volume;
    PreviousDate := Date;
  end;
end;

end.

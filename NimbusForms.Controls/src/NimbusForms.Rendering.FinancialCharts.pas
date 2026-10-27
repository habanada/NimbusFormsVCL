{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.FinancialCharts;

interface

uses System.Types, NimbusForms.Rendering.Charts, NimbusForms.Charts.Types;

type
  TNimbusFinancialChartRenderer = class(TNimbusChartRenderer)
  protected
    function Build(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>; override;
  public
    function CanRender(const AType: TNimbusChartType): Boolean; override;
    function Arrange(const C: TNimbusChartRenderContext): TNimbusChartLayout; override;
  end;

implementation

uses Winapi.Windows, System.SysUtils, System.Math, Vcl.Graphics, NimbusForms.Rendering.ChartPrimitives,
  NimbusForms.Charts.Financial.Types, NimbusForms.Charts.Sparkline.Types, NimbusForms.Rendering.Types, NimbusForms.Theming.Types;

function TNimbusFinancialChartRenderer.CanRender(const AType: TNimbusChartType): Boolean;
begin Result := AType in [nctCandlestick, nctOhlc] end;

function TNimbusFinancialChartRenderer.Arrange(const C: TNimbusChartRenderContext): TNimbusChartLayout;
var I: Integer; P: TNimbusFinancialDataPoint; MinX, MaxX, MinY, MaxY, Padding: Double;
begin
  Result := inherited Arrange(C); if C.Model = nil then Exit; MinX := MaxDouble; MaxX := -MaxDouble; MinY := MaxDouble; MaxY := -MaxDouble;
  for I := 0 to C.Model.FinancialData.Count - 1 do
  begin P := C.Model.FinancialData[I]; if not P.Visible or not P.IsValid then Continue; MinX := Min(MinX, P.XValue); MaxX := Max(MaxX, P.XValue) end;
  if MinX = MaxDouble then begin MinX := 0; MaxX := 1 end;
  Padding := Max(0.5, (MaxX - MinX) / Max(1, C.Model.FinancialData.Count) / 2); Result.XRange := TNimbusChartRange.Create(MinX - Padding, MaxX + Padding);
  if C.XView.IsValid then Result.XRange := C.XView;
  for I := 0 to C.Model.FinancialData.Count - 1 do
  begin P := C.Model.FinancialData[I]; if not P.Visible or not P.IsValid or (P.XValue < Result.XRange.Minimum) or (P.XValue > Result.XRange.Maximum) then Continue; MinY := Min(MinY, P.Low); MaxY := Max(MaxY, P.High) end;
  if MinY = MaxDouble then begin MinY := 0; MaxY := 1 end;
  Padding := Max(0.01, (MaxY - MinY) * 0.08); Result.YRange := TNimbusChartRange.Create(MinY - Padding, MaxY + Padding);
  if C.YView.IsValid then Result.YRange := C.YView;
  Inc(Result.PlotArea.Left, NimbusScaleValue(54, C.PPI)); Dec(Result.PlotArea.Bottom, NimbusScaleValue(24, C.PPI));
  Result.PlotArea.Right := Max(Result.PlotArea.Left, Result.PlotArea.Right); Result.PlotArea.Bottom := Max(Result.PlotArea.Top, Result.PlotArea.Bottom);
end;

function TNimbusFinancialChartRenderer.Build(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>;
var B: TNimbusChartPrimitiveBuilder; O: TNimbusFinancialChartOptions; Data: TNimbusFinancialDataPointCollection;
  Indices: TArray<Integer>; Closes, SMA, EMA, Bollinger, Deviations, Fast, Slow, MACD, Signal, RSI, StochK, StochD: TArray<Double>;
  I, J, K, N, Temp, PanelCount, PanelHeight, Cursor, VolumeHeight, Period: Integer; P: TNimbusFinancialDataPoint;
  Price, Volume, Panel: TRect; Hit: TNimbusChartHit; Col: TThemeColor; DPI, X, Y, Width, MaxVolume, Value, Sum, SumSq, AverageGain, AverageLoss, Change, Low, High, MinValue, MaxValue: Double;
  Prev: TPointF; HasPrev: Boolean; CaptionText: string; Flags: TNimbusTextFlags;
  function XPosition(const Index: Integer): Double;
  begin Result := Price.Left + (Data[Indices[Index]].XValue - L.XRange.Minimum) / Max(1E-100, L.XRange.Maximum - L.XRange.Minimum) * Price.Width end;
  function YPosition(const V: Double; const Bounds: TRect; const Minimum, Maximum: Double): Double;
  begin Result := Bounds.Bottom - (V - Minimum) / Max(1E-100, Maximum - Minimum) * Bounds.Height end;
  function Color(const Custom: TColor; const Default: TThemeColor): TThemeColor;
  begin if Custom = clNone then Result := Default else Result := ColorToThemeColor(Custom) end;
  function Exponential(const Values: TArray<Double>; const Period: Integer): TArray<Double>;
  var K: Integer; Alpha, Average: Double;
  begin
    SetLength(Result, Length(Values)); if Length(Values) = 0 then Exit; Alpha := 2 / (Max(2, Period) + 1); Average := Values[0];
    for K := 0 to System.High(Values) do begin Average := Average + Alpha * (Values[K] - Average); Result[K] := Average end;
  end;
  function MovingAverage(const Values: TArray<Double>; const Period: Integer): TArray<Double>;
  var K: Integer; Sum: Double;
  begin SetLength(Result, Length(Values)); Sum := 0; for K := 0 to System.High(Values) do
    begin Sum := Sum + Values[K]; if K >= Period then Sum := Sum - Values[K - Period]; if K + 1 >= Period then Result[K] := Sum / Period else Result[K] := NaN end end;
  procedure PlotLine(const Values: TArray<Double>; const Bounds: TRect; const Minimum, Maximum: Double; const Color: TThemeColor; const Offset: Double = 0);
  var K: Integer; Point: TPointF; Previous: TPointF; HasPrevious: Boolean;
  begin
    HasPrevious := False;
    for K := 0 to System.High(Values) do
    begin
      if not SparklineFinite(Values[K]) then begin HasPrevious := False; Continue end;
      Point := TPointF.Create(XPosition(K), YPosition(Values[K] + Offset, Bounds, Minimum, Maximum));
      if HasPrevious then B.Line([Previous, Point], Color, Max(1.0, 1.5 * DPI), TNimbusChartHit.None);
      Previous := Point; HasPrevious := True;
    end;
  end;
  procedure IndicatorPanel(const Name: string; const Values, Other: TArray<Double>; const Primary, Secondary: TThemeColor; const FixedRange: Boolean);
  var K: Integer; MinV, MaxV, Mid: Double;
  begin
    Panel := Rect(Price.Left, Cursor, Price.Right, Cursor + PanelHeight); Inc(Cursor, PanelHeight); B.ClipBounds := Panel;
    MinV := 0; MaxV := 100;
    if not FixedRange then
    begin MinV := 0; MaxV := 0; for K := 0 to System.High(Values) do if SparklineFinite(Values[K]) then begin MinV := Min(MinV, Values[K]); MaxV := Max(MaxV, Values[K]) end;
      for K := 0 to System.High(Other) do if SparklineFinite(Other[K]) then begin MinV := Min(MinV, Other[K]); MaxV := Max(MaxV, Other[K]) end; if MaxV = MinV then MaxV := MinV + 1 end;
    B.Box(Panel, ChartBorderColor(C), TNimbusChartHit.None, 0, True); B.Text(Name, Rect(Panel.Left + Round(4 * DPI), Panel.Top, Panel.Right, Panel.Top + Round(20 * DPI)), ChartForeColor(C), TNimbusChartHit.None, [ntfVCenter, ntfSingleLine, ntfNoPrefix]);
    PlotLine(Values, Panel, MinV, MaxV, Primary); PlotLine(Other, Panel, MinV, MaxV, Secondary);
    Mid := YPosition(0, Panel, MinV, MaxV); if FixedRange then Mid := YPosition(50, Panel, MinV, MaxV);
    B.Line([TPointF.Create(Panel.Left, Mid), TPointF.Create(Panel.Right, Mid)], NimbusColorWithAlpha(ChartBorderColor(C), 100), DPI, TNimbusChartHit.None);
  end;
begin
  Result := nil; if C.Model = nil then Exit; O := C.Model.FinancialOptions; Data := C.Model.FinancialData;
  B := TNimbusChartPrimitiveBuilder.Create(C, L);
  try
    DPI := Max(1, C.PPI) / 96; Flags := [ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix]; N := 0; SetLength(Indices, Data.Count);
    for I := 0 to Data.Count - 1 do if Data[I].Visible and Data[I].IsValid then begin Indices[N] := I; Inc(N) end; SetLength(Indices, N);
    for I := 1 to N - 1 do begin J := I; while (J > 0) and (Data[Indices[J]].XValue < Data[Indices[J - 1]].XValue) do begin Temp := Indices[J]; Indices[J] := Indices[J - 1]; Indices[J - 1] := Temp; Dec(J) end end;
    if (N = 0) or L.PlotArea.IsEmpty then begin Result := B.Finish; Exit end; SetLength(Closes, N); MaxVolume := 0;
    for I := 0 to N - 1 do begin Closes[I] := Data[Indices[I]].Close; if SparklineFinite(Data[Indices[I]].Volume) then MaxVolume := Max(MaxVolume, Data[Indices[I]].Volume) end;
    PanelCount := Ord(O.ShowMacdPanel) + Ord(O.ShowRsiPanel) + Ord(O.ShowStochasticPanel); PanelHeight := Round(L.PlotArea.Height * Min(O.IndicatorPanelRatio, 0.6 / Max(1, PanelCount)));
    VolumeHeight := 0; if O.ShowVolumePanel and (O.VolumeDisplayMode <> nfvNone) then VolumeHeight := Round(L.PlotArea.Height * O.VolumePanelRatio);
    Price := L.PlotArea; Dec(Price.Bottom, PanelCount * PanelHeight + VolumeHeight); Price.Bottom := Max(Price.Top + 1, Price.Bottom);
    Volume := Rect(Price.Left, Price.Bottom, Price.Right, Price.Bottom + VolumeHeight); Cursor := Volume.Bottom;
    for I := 0 to 4 do
    begin
      Value := L.YRange.Minimum + (L.YRange.Maximum - L.YRange.Minimum) * I / 4; Y := YPosition(Value, Price, L.YRange.Minimum, L.YRange.Maximum);
      if C.Model.Options.ShowGrid then B.Line([TPointF.Create(Price.Left, Y), TPointF.Create(Price.Right, Y)], NimbusColorWithAlpha(ChartBorderColor(C), 100), DPI, TNimbusChartHit.None);
      if C.Model.Options.ShowAxes then B.Text(SparklineFormatValue(Value, '0.##'), Rect(L.PlotArea.Left - Round(54 * DPI), Round(Y - 10 * DPI), L.PlotArea.Left - Round(4 * DPI), Round(Y + 10 * DPI)), ChartForeColor(C), TNimbusChartHit.None, Flags + [ntfRight]);
    end;
    Width := Max(DPI, Min(18 * DPI, Price.Width / Max(1, N) * 0.65)); B.ClipBounds := Price;
    for I := 0 to N - 1 do
    begin
      P := Data[Indices[I]]; X := XPosition(I); if (X < Price.Left - Width) or (X > Price.Right + Width) then Continue;
      Col := Color(O.NeutralColor, ChartForeColor(C)); if P.Close > P.Open then Col := Color(O.RisingColor, NimbusSuccessColor) else if P.Close < P.Open then Col := Color(O.FallingColor, NimbusDangerColor);
      Hit := TNimbusChartHit.None; Hit.Area := nchaPoint; Hit.SeriesIndex := 0; Hit.PointIndex := Indices[I]; Hit.ElementIndex := Indices[I]; Hit.XValue := P.XValue; Hit.YValue := P.Close;
      Hit.Text := P.ToolTipText; if Hit.Text = '' then Hit.Text := P.&Label + sLineBreak + 'Open: ' + FormatFloat('0.##', P.Open) + '  High: ' + FormatFloat('0.##', P.High) + sLineBreak + 'Low: ' + FormatFloat('0.##', P.Low) + '  Close: ' + FormatFloat('0.##', P.Close) + sLineBreak + 'Volume: ' + SparklineFormatValue(P.Volume, '0');
      B.Line([TPointF.Create(X, YPosition(P.Low, Price, L.YRange.Minimum, L.YRange.Maximum)), TPointF.Create(X, YPosition(P.High, Price, L.YRange.Minimum, L.YRange.Maximum))], Col, DPI, Hit);
      if (C.Model.ChartType = nctOhlc) or (O.PriceDisplayMode = nfpOhlc) then
      begin B.Line([TPointF.Create(X - Width / 2, YPosition(P.Open, Price, L.YRange.Minimum, L.YRange.Maximum)), TPointF.Create(X, YPosition(P.Open, Price, L.YRange.Minimum, L.YRange.Maximum))], Col, DPI, Hit);
        B.Line([TPointF.Create(X, YPosition(P.Close, Price, L.YRange.Minimum, L.YRange.Maximum)), TPointF.Create(X + Width / 2, YPosition(P.Close, Price, L.YRange.Minimum, L.YRange.Maximum))], Col, DPI, Hit) end
      else
      begin Low := YPosition(Max(P.Open, P.Close), Price, L.YRange.Minimum, L.YRange.Maximum); High := YPosition(Min(P.Open, P.Close), Price, L.YRange.Minimum, L.YRange.Maximum);
        B.Box(Rect(Round(X - Width / 2), Round(Low), Round(X + Width / 2), Max(Round(Low) + 1, Round(High))), Col, Hit) end;
      if O.ShowEventMarkers and (P.EventText <> '') then
      begin Y := YPosition(P.High, Price, L.YRange.Minimum, L.YRange.Maximum) - 8 * DPI; Hit.Text := P.EventText; Value := Max(2.0, P.EventSize * 3) * DPI;
        B.Ellipse(Rect(Round(X - Value), Round(Y - Value), Round(X + Value), Round(Y + Value)), Color(P.EventColor, ChartAccentColor(C)), Hit) end;
      if VolumeHeight > 0 then
      begin
        B.ClipBounds := Volume; Y := Volume.Bottom - Max(0.0, P.Volume) / Max(1.0, MaxVolume) * Max(0, Volume.Height - Round(4 * DPI));
        if O.VolumeDisplayMode = nfvBars then B.Box(Rect(Round(X - Width / 2), Round(Y), Round(X + Width / 2), Volume.Bottom), NimbusColorWithAlpha(Col, 145), Hit)
        else begin Value := Sqrt(Max(0.0, P.Volume) / Max(1.0, MaxVolume)) * Min(12 * DPI, Volume.Height / 2); B.Ellipse(Rect(Round(X - Value), Round(Volume.CenterPoint.Y - Value), Round(X + Value), Round(Volume.CenterPoint.Y + Value)), NimbusColorWithAlpha(Col, 130), Hit) end;
        B.ClipBounds := Price;
      end;
    end;
    if O.ShowSimpleMovingAverage then begin SMA := MovingAverage(Closes, O.SimpleMovingAveragePeriod); PlotLine(SMA, Price, L.YRange.Minimum, L.YRange.Maximum, Color(O.SimpleMovingAverageColor, ChartAccentColor(C))) end;
    if O.ShowExponentialMovingAverage then begin EMA := Exponential(Closes, O.ExponentialMovingAveragePeriod); PlotLine(EMA, Price, L.YRange.Minimum, L.YRange.Maximum, Color(O.ExponentialMovingAverageColor, ChartAccentColor(C))) end;
    if O.ShowBollingerBands then
    begin
      Period := Max(2, O.BollingerPeriod); Bollinger := MovingAverage(Closes, Period); SetLength(Deviations, N); Sum := 0; SumSq := 0;
      for I := 0 to N - 1 do begin Sum := Sum + Closes[I]; SumSq := SumSq + Sqr(Closes[I]); if I >= Period then begin Sum := Sum - Closes[I - Period]; SumSq := SumSq - Sqr(Closes[I - Period]) end;
        if I + 1 < Period then Deviations[I] := NaN else Deviations[I] := Sqrt(Max(0.0, SumSq / Period - Sqr(Sum / Period))) * O.BollingerDeviation end;
      SetLength(Fast, N); SetLength(Slow, N); for I := 0 to N - 1 do begin Fast[I] := Bollinger[I] + Deviations[I]; Slow[I] := Bollinger[I] - Deviations[I] end;
      PlotLine(Fast, Price, L.YRange.Minimum, L.YRange.Maximum, Color(O.BollingerBandColor, ChartBorderColor(C))); PlotLine(Slow, Price, L.YRange.Minimum, L.YRange.Maximum, Color(O.BollingerBandColor, ChartBorderColor(C)));
    end;
    if O.ShowLastPriceLine then begin Y := YPosition(Closes[N - 1], Price, L.YRange.Minimum, L.YRange.Maximum); B.Line([TPointF.Create(Price.Left, Y), TPointF.Create(Price.Right, Y)], NimbusColorWithAlpha(ChartAccentColor(C), 170), DPI, TNimbusChartHit.None) end;
    if O.ShowMacdPanel then
    begin Fast := Exponential(Closes, O.MacdFastPeriod); Slow := Exponential(Closes, Max(O.MacdFastPeriod + 1, O.MacdSlowPeriod)); SetLength(MACD, N);
      for I := 0 to N - 1 do MACD[I] := Fast[I] - Slow[I]; Signal := Exponential(MACD, O.MacdSignalPeriod); IndicatorPanel('MACD', MACD, Signal, Color(O.MacdColor, ChartAccentColor(C)), Color(O.MacdSignalColor, NimbusWarningColor), False) end;
    if O.ShowRsiPanel then
    begin
      SetLength(RSI, N); AverageGain := 0; AverageLoss := 0; RSI[0] := NaN; Period := Max(2, O.RsiPeriod);
      for I := 1 to N - 1 do begin Change := Closes[I] - Closes[I - 1]; if I <= Period then begin AverageGain := AverageGain + Max(0.0, Change) / Period; AverageLoss := AverageLoss + Max(0.0, -Change) / Period end
        else begin AverageGain := (AverageGain * (Period - 1) + Max(0.0, Change)) / Period; AverageLoss := (AverageLoss * (Period - 1) + Max(0.0, -Change)) / Period end;
        if I < Period then RSI[I] := NaN else if AverageLoss > 0 then RSI[I] := 100 - 100 / (1 + AverageGain / AverageLoss) else if AverageGain > 0 then RSI[I] := 100 else RSI[I] := 50 end;
      IndicatorPanel('RSI', RSI, nil, Color(O.RsiColor, ChartAccentColor(C)), ChartBorderColor(C), True);
    end;
    if O.ShowStochasticPanel then
    begin SetLength(StochK, N); Period := Max(2, O.StochasticPeriod);
      for I := 0 to N - 1 do begin Low := MaxDouble; High := -MaxDouble; for J := Max(0, I - Period + 1) to I do begin Low := Min(Low, Data[Indices[J]].Low); High := Max(High, Data[Indices[J]].High) end;
        if I + 1 < Period then StochK[I] := NaN else if High > Low then StochK[I] := (Closes[I] - Low) / (High - Low) * 100 else StochK[I] := 50 end;
      SetLength(StochD, N); for I := 0 to N - 1 do begin Sum := 0; K := 0; for J := Max(0, I - O.StochasticSignalPeriod + 1) to I do if SparklineFinite(StochK[J]) then begin Sum := Sum + StochK[J]; Inc(K) end; if K > 0 then StochD[I] := Sum / K else StochD[I] := NaN end;
      IndicatorPanel('Stochastic', StochK, StochD, Color(O.StochasticKColor, ChartAccentColor(C)), Color(O.StochasticDColor, NimbusDangerColor), True);
    end;
    B.ClipBounds := TRect.Empty;
    if O.ShowPriceChange then begin Change := Closes[N - 1] - Closes[0]; CaptionText := FormatFloat('0.##', Closes[N - 1]) + '  (' + FormatFloat('+0.##;-0.##;0', Change) + ')';
      B.Text(CaptionText, Rect(Price.Left, Price.Top, Price.Right, Price.Top + Round(22 * DPI)), ChartForeColor(C), TNimbusChartHit.None, Flags + [ntfRight]) end;
    if C.Model.Options.ShowAxes then for I := 0 to N - 1 do if (I mod Max(1, Ceil(N / 8)) = 0) or (I = N - 1) then
    begin X := XPosition(I); P := Data[Indices[I]]; CaptionText := P.&Label; if CaptionText = '' then CaptionText := SparklineFormatValue(P.XValue, '0.##');
      B.Text(CaptionText, Rect(Round(X - 35 * DPI), L.PlotArea.Bottom, Round(X + 35 * DPI), L.PlotArea.Bottom + Round(24 * DPI)), ChartForeColor(C), TNimbusChartHit.None, Flags + [ntfCenter]) end;
    Result := B.Finish;
  finally B.Free end;
end;

end.

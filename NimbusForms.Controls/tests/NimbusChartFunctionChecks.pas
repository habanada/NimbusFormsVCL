unit NimbusChartFunctionChecks;

interface

procedure RunNimbusChartFunctionChecks;

implementation

uses System.SysUtils, System.Math, System.Types, Vcl.Graphics, NimbusForms.Charts.Types,
  NimbusForms.Charts.Functions, NimbusForms.Controls.Chart;

type EChartCallbackFailure = class(Exception);

procedure Check(const Condition: Boolean; const Message: string);
begin if not Condition then raise Exception.Create('Function chart: ' + Message) end;

procedure CheckFactories;
var F: TNimbusChartFunction; Values: TArray<Double>; Raised: Boolean;
begin
  F := TNimbusChartFunctions.Sine(2, 3, Pi / 2, 4); Check(Abs(F(0) - 6) < 1E-12, 'sine parameters');
  F := TNimbusChartFunctions.Cosine(2, 3, 0, 4); Check(Abs(F(0) - 6) < 1E-12, 'cosine parameters');
  F := TNimbusChartFunctions.Tangent(2, 1, 0, 3); Check(Abs(F(Pi / 4) - 5) < 1E-10, 'tangent');
  F := TNimbusChartFunctions.Exponential(2, 0.5, 3); Check(Abs(F(2) - (3 + 2 * Exp(1))) < 1E-10, 'exponential');
  F := TNimbusChartFunctions.Logarithm(10, 2, 3); Check(Abs(F(102) - 5) < 1E-10, 'logarithm'); Check(IsNan(F(2)), 'logarithm domain');
  F := TNimbusChartFunctions.Power(2, 3, 1); Check(Abs(F(-2) + 15) < 1E-10, 'power');
  F := TNimbusChartFunctions.SquareRoot(2, 1, 3); Check(Abs(F(5) - 7) < 1E-12, 'square root'); Check(IsNan(F(0)), 'square root domain');
  Values := [1, 2, 3]; F := TNimbusChartFunctions.Polynomial(Values); Values[0] := 100;
  Check(Abs(F(2) - 17) < 1E-12, 'polynomial uses Horner order and a coefficient snapshot');
  F := TNimbusChartFunctions.Polynomial([]); Check(F(42) = 0, 'empty polynomial');
  F := TNimbusChartFunctions.Gaussian(2, 3, 1, 4); Check(Abs(F(3) - 6) < 1E-12, 'Gaussian');
  F := TNimbusChartFunctions.DampedOscillation(2, 0.5, 1, Pi / 2, 3); Check(Abs(F(0) - 5) < 1E-12, 'damped oscillation');
  Raised := False;
  try F := TNimbusChartFunctions.Logarithm(1, 0, 0) except on E: EArgumentOutOfRangeException do Raised := True end;
  Check(Raised, 'invalid logarithm base'); Raised := False;
  try F := TNimbusChartFunctions.Gaussian(1, 0, 0, 0) except on E: EArgumentOutOfRangeException do Raised := True end;
  Check(Raised, 'invalid Gaussian deviation');
end;

procedure CheckAnalysis;
var Model: TNimbusChartModel; Options: TNimbusChartFunctionOptions; R: TNimbusChartFunctionResult;
  I, UniformCount, AdaptiveCount: Integer; Points: TArray<TNimbusChartFunctionPoint>; Series: TArray<TNimbusChartSeries>;
begin
  Model := TNimbusChartModel.Create; Options := TNimbusChartFunctionOptions.Create;
  try
    Options.MinimumX := -4; Options.MaximumX := 4; Options.SampleCount := 221;
    Options.DetectRoots := True; Options.DetectExtrema := True; Options.AddRootAnnotations := True; Options.AddExtremaAnnotations := True;
    Options.YAxis := ncySecondary; Options.ShowMarkers := True; Options.LineWidth := 3;
    R := Model.AddFunctionSeries('Cubic', TNimbusChartFunctions.Polynomial([0, -3, 0, 1]), Options);
    try
      Check(Length(R.Roots) = 3, 'cubic root count'); Points := R.Roots;
      Check((Abs(Points[0].XValue + Sqrt(3)) < 0.002) and (Abs(Points[1].XValue) < 1E-8) and (Abs(Points[2].XValue - Sqrt(3)) < 0.002), 'cubic root positions');
      Check(Length(R.Extrema) = 2, 'cubic extrema count'); Points := R.Extrema;
      Check((Abs(Points[0].XValue + 1) < 0.02) and (Abs(Points[1].XValue - 1) < 0.02), 'cubic extrema positions');
      Check(Model.Annotations.Count = 5, 'root and extrema annotations');
      for I := 0 to Model.Annotations.Count - 1 do Check(Model.Annotations[I].YAxis = ncySecondary, 'annotation axis');
      Check((R.Series[0].YAxis = ncySecondary) and R.Series[0].ShowMarkers and (R.Series[0].LineWidth = 3), 'series options');
      Series := R.Series; Series[0] := nil; Check(R.Series[0] <> nil, 'result array is a snapshot');
    finally R.Free end;
    Check(Model.Series.Count > 0, 'freeing result freed model-owned series');
    Model.ClearSeries; Model.Annotations.Clear; Options.MinimumX := 0; Options.MaximumX := 1;
    Options.SampleCount := 101; Options.SamplingMode := ncfsmUniform; Options.YAxis := ncyPrimary;
    Options.AddDerivativeSeries := True; Options.AddIntegralSeries := True; Options.IntegralInitialValue := 7;
    R := Model.AddFunctionSeries('Square', TNimbusChartFunctions.Power(1, 2, 0), Options);
    try
      Check(R.DerivativeSeries <> nil, 'derivative series'); Check(R.IntegralSeries <> nil, 'integral series');
      for I := 0 to R.DerivativeSeries.Points.Count - 1 do
        Check(Abs(R.DerivativeSeries.Points[I].YValue - 2 * R.DerivativeSeries.Points[I].XValue) < 1E-10, 'central derivative of x squared');
      I := R.IntegralSeries.Points.Count - 1;
      Check(Abs(R.IntegralSeries.Points[I].YValue - (7 + 1 / 3)) < 0.00002, 'trapezoidal integral and initial value');
      Check(Model.ReferenceLines.Count = 2, 'reference axes duplicated');
    finally R.Free end;
    Model.ClearSeries; Options.AddDerivativeSeries := False; Options.AddIntegralSeries := False;
    Options.MinimumX := -2; Options.MaximumX := 2; Options.SampleCount := 9;
    R := Model.AddFunctionSeries('Uniform', TNimbusChartFunctions.Exponential(1, 1, 0), Options);
    try UniformCount := R.Series[0].Points.Count finally R.Free end;
    Model.ClearSeries; Options.SamplingMode := ncfsmAdaptive;
    R := Model.AddFunctionSeries('Adaptive', TNimbusChartFunctions.Exponential(1, 1, 0), Options);
    try AdaptiveCount := R.Series[0].Points.Count finally R.Free end;
    Check(AdaptiveCount > UniformCount, 'adaptive refinement');
    Model.ClearSeries; Options.MinimumX := 0; Options.MaximumX := 360; Options.SampleCount := 361;
    Options.AngleUnit := ncauDegrees; Options.SamplingMode := ncfsmUniform;
    Options.DerivativeStep := 0.01; Options.AddDerivativeSeries := True;
    R := Model.AddFunctionSeries('Degrees', TNimbusChartFunctions.Sine(1, 1, 0, 0), Options);
    try
      Check(Length(R.Roots) = 3, 'degree roots include both endpoints');
      for I := 0 to R.DerivativeSeries.Points.Count - 1 do
        Check(Abs(R.DerivativeSeries.Points[I].YValue - Pi / 180 * Cos(R.DerivativeSeries.Points[I].XValue * Pi / 180)) < 1E-8, 'degree derivative chain factor');
    finally R.Free end;
  finally Options.Free; Model.Free end;
end;

procedure CheckDiscontinuities;
var Model: TNimbusChartModel; Options: TNimbusChartFunctionOptions; R: TNimbusChartFunctionResult;
  I, J: Integer; Series: TNimbusChartSeries;
begin
  Model := TNimbusChartModel.Create; Options := TNimbusChartFunctionOptions.Create;
  try
    Options.MinimumX := -1; Options.MaximumX := 1; Options.SampleCount := 101; Options.SamplingMode := ncfsmUniform;
    Options.AddDerivativeSeries := True; Options.AddIntegralSeries := True; Options.DetectRoots := True;
    R := Model.AddFunctionSeries('Gap', function(X: Double): Double
      begin if Abs(X) < 0.2 then Result := NaN else Result := X end, Options);
    try
      Check(Length(R.Series) = 2, 'domain gap splits base series'); Check(Length(R.Roots) = 0, 'no root inside a domain gap');
      for I := 0 to Model.Series.Count - 1 do
      begin
        Series := Model.Series[I];
        for J := 1 to Series.Points.Count - 1 do
          Check(not ((Series.Points[J - 1].XValue < 0) and (Series.Points[J].XValue > 0)), 'analysis bridged a domain gap');
      end;
    finally R.Free end;
    Model.ClearSeries; Options.MinimumX := -2 * Pi; Options.MaximumX := 2 * Pi; Options.SampleCount := 320;
    Options.SamplingMode := ncfsmAdaptive; Options.MaximumAbsoluteY := 20; Options.DiscontinuityThreshold := 6;
    Options.AddDerivativeSeries := False; Options.AddIntegralSeries := False;
    R := Model.AddFunctionSeries('Tangent', TNimbusChartFunctions.Tangent(1, 1, 0, 0), Options);
    try
      Check(Length(R.Series) >= 5, 'tangent branches');
      for Series in R.Series do
        Check(Floor((Series.Points[0].XValue + Pi / 2) / Pi) = Floor((Series.Points[Series.Points.Count - 1].XValue + Pi / 2) / Pi), 'tangent crosses an asymptote');
    finally R.Free end;
  finally Options.Free; Model.Free end;
end;

procedure CheckParametricAndErrors;
var Chart: TThemedChart; Options: TNimbusChartParametricOptions; FunctionOptions: TNimbusChartFunctionOptions;
  R: TNimbusChartFunctionResult; Series: TNimbusChartSeries; Bitmap: TBitmap; I, InitialCount: Integer; Raised, Reversed: Boolean;
begin
  Chart := TThemedChart.Create(nil); Options := TNimbusChartParametricOptions.Create; FunctionOptions := TNimbusChartFunctionOptions.Create;
  try
    Options.SampleCount := 1400; Options.DownsamplingMode := ncdNone;
    R := Chart.Model.AddParametricSeries('Lissajous',
      function(T: Double): Double begin Result := Sin(3 * T + Pi / 2) end,
      function(T: Double): Double begin Result := Sin(2 * T) end, Options);
    try
      Check(Length(R.Series) = 1, 'Lissajous series count'); Series := R.Series[0];
      Check(Series.Points.Count = 1400, 'parametric sample count');
      Check((Abs(Series.Points[0].XValue - 1) < 1E-12) and (Abs(Series.Points[0].YValue) < 1E-12), 'Lissajous start');
      Check((Abs(Series.Points[1399].XValue - 1) < 1E-12) and (Abs(Series.Points[1399].YValue) < 1E-12), 'Lissajous closure');
      Reversed := False; for I := 1 to Series.Points.Count - 1 do if Series.Points[I].XValue < Series.Points[I - 1].XValue then Reversed := True;
      Check(Reversed, 'parametric traversal was sorted by x');
      Chart.ShowAnimation := False; Bitmap := Chart.RenderToBitmap(520, 300); Bitmap.Free;
      Check(Pos('<polyline', Chart.ExportSvg(520, 300)) > 0, 'function SVG export');
      Check(not Chart.HandleAllocated, 'function plotting or export created HWND');
    finally R.Free end;
    InitialCount := Chart.Model.Series.Count; FunctionOptions.MaximumX := FunctionOptions.MinimumX; Raised := False;
    try R := Chart.Model.AddFunctionSeries('Invalid', TNimbusChartFunctions.Sine(1, 1, 0, 0), FunctionOptions); R.Free
    except on E: EArgumentException do Raised := True end;
    Check(Raised and (Chart.Model.Series.Count = InitialCount), 'invalid range mutated model');
    FunctionOptions.MaximumX := 10; Raised := False;
    try R := Chart.Model.AddFunctionSeries('Nil', nil, FunctionOptions); R.Free except on E: EArgumentNilException do Raised := True end;
    Check(Raised, 'nil callback'); Raised := False;
    try
      R := Chart.Model.AddFunctionSeries('Bug', function(X: Double): Double begin raise EChartCallbackFailure.Create('callback failure') end, FunctionOptions); R.Free;
    except on E: EChartCallbackFailure do Raised := True end;
    Check(Raised and (Chart.Model.Series.Count = InitialCount), 'unexpected callback exception was hidden');
    FunctionOptions.SampleCount := 1048577; Raised := False;
    try R := Chart.Model.AddFunctionSeries('Too large', TNimbusChartFunctions.Sine(1, 1, 0, 0), FunctionOptions); R.Free
    except on E: EArgumentOutOfRangeException do Raised := True end;
    Check(Raised, 'sampling work limit');
  finally FunctionOptions.Free; Options.Free; Chart.Free end;
end;

procedure RunNimbusChartFunctionChecks;
begin CheckFactories; CheckAnalysis; CheckDiscontinuities; CheckParametricAndErrors end;

end.

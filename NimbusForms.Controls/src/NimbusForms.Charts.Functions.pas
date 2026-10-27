unit NimbusForms.Charts.Functions;

interface

uses System.SysUtils, System.Math, System.Generics.Collections, NimbusForms.Charts.Types;

type
  TNimbusChartAngleUnit = (ncauRadians, ncauDegrees);
  TNimbusChartFunctionSamplingMode = (ncfsmUniform, ncfsmAdaptive);
  TNimbusChartFunction = reference to function(X: Double): Double;
  TNimbusChartParametricFunction = TNimbusChartFunction;

  TNimbusChartFunctionOptions = class
  public
    MinimumX, MaximumX: Double;
    SampleCount: Integer;
    SamplingMode: TNimbusChartFunctionSamplingMode;
    AdaptiveTolerance: Double;
    MaximumAdaptiveDepth: Integer;
    MaximumAbsoluteY, DiscontinuityThreshold: Double;
    AngleUnit: TNimbusChartAngleUnit;
    ShowMarkers: Boolean;
    LineWidth: Single;
    DetectRoots, DetectExtrema, AddRootAnnotations, AddExtremaAnnotations: Boolean;
    AddReferenceAxes, AddDerivativeSeries, AddIntegralSeries: Boolean;
    DerivativeStep, IntegralInitialValue: Double;
    YAxis: TNimbusChartSeriesYAxis;
    DownsamplingMode: TNimbusChartDownsamplingMode;
    constructor Create;
  end;

  TNimbusChartParametricOptions = class
  public
    MinimumParameter, MaximumParameter: Double;
    SampleCount: Integer;
    MaximumAbsoluteValue, DiscontinuityThreshold: Double;
    ShowMarkers: Boolean;
    LineWidth: Single;
    YAxis: TNimbusChartSeriesYAxis;
    DownsamplingMode: TNimbusChartDownsamplingMode;
    constructor Create;
  end;

  TNimbusChartFunctionPoint = record
    XValue, YValue: Double;
    class function Create(const X, Y: Double): TNimbusChartFunctionPoint; static;
    function IsValid: Boolean;
  end;

  TNimbusChartFunctionResult = class
  private
    FSeries: TArray<TNimbusChartSeries>;
    FRoots, FExtrema: TArray<TNimbusChartFunctionPoint>;
    FDerivativeSeries, FIntegralSeries: TNimbusChartSeries;
    function GetSeries: TArray<TNimbusChartSeries>;
    function GetRoots: TArray<TNimbusChartFunctionPoint>;
    function GetExtrema: TArray<TNimbusChartFunctionPoint>;
  public
    property Series: TArray<TNimbusChartSeries> read GetSeries;
    property Roots: TArray<TNimbusChartFunctionPoint> read GetRoots;
    property Extrema: TArray<TNimbusChartFunctionPoint> read GetExtrema;
    property DerivativeSeries: TNimbusChartSeries read FDerivativeSeries;
    property IntegralSeries: TNimbusChartSeries read FIntegralSeries;
  end;

  TNimbusChartFunctions = class sealed
  public
    class function Sine(Amplitude, AngularFrequency, Phase, VerticalOffset: Double): TNimbusChartFunction; static;
    class function Cosine(Amplitude, AngularFrequency, Phase, VerticalOffset: Double): TNimbusChartFunction; static;
    class function Tangent(Amplitude, AngularFrequency, Phase, VerticalOffset: Double): TNimbusChartFunction; static;
    class function Exponential(Amplitude, Rate, VerticalOffset: Double): TNimbusChartFunction; static;
    class function Logarithm(LogarithmicBase, HorizontalOffset, VerticalOffset: Double): TNimbusChartFunction; static;
    class function Power(Coefficient, Exponent, VerticalOffset: Double): TNimbusChartFunction; static;
    class function SquareRoot(Coefficient, HorizontalOffset, VerticalOffset: Double): TNimbusChartFunction; static;
    class function Polynomial(const Coefficients: array of Double): TNimbusChartFunction; static;
    class function Gaussian(Amplitude, Mean, StandardDeviation, VerticalOffset: Double): TNimbusChartFunction; static;
    class function DampedOscillation(Amplitude, Damping, AngularFrequency, Phase, VerticalOffset: Double): TNimbusChartFunction; static;
  end;

  TNimbusChartFunctionPlotter = class sealed
  public
    class function AddFunctionSeries(Model: TNimbusChartModel; const Name: string; const Func: TNimbusChartFunction;
      Options: TNimbusChartFunctionOptions = nil): TNimbusChartFunctionResult; static;
    class function AddParametricSeries(Model: TNimbusChartModel; const Name: string; const XFunction, YFunction: TNimbusChartParametricFunction;
      Options: TNimbusChartParametricOptions = nil): TNimbusChartFunctionResult; static;
  end;

  TNimbusChartFunctionModelHelper = class helper for TNimbusChartModel
    function AddFunctionSeries(const Name: string; const Func: TNimbusChartFunction;
      Options: TNimbusChartFunctionOptions = nil): TNimbusChartFunctionResult;
    function AddParametricSeries(const Name: string; const XFunction, YFunction: TNimbusChartParametricFunction;
      Options: TNimbusChartParametricOptions = nil): TNimbusChartFunctionResult;
  end;

implementation

const MaximumFunctionSamples = 1048576;

function Finite(const Value: Double): Boolean;
begin Result := not IsNan(Value) and not IsInfinite(Value) end;

constructor TNimbusChartFunctionOptions.Create;
begin
  inherited Create;
  MinimumX := -10; MaximumX := 10; SampleCount := 512;
  SamplingMode := ncfsmAdaptive; AdaptiveTolerance := 0.0025; MaximumAdaptiveDepth := 12;
  MaximumAbsoluteY := 1000000; DiscontinuityThreshold := 40; AngleUnit := ncauRadians;
  LineWidth := 2; AddReferenceAxes := True; YAxis := ncyPrimary; DownsamplingMode := ncdAutomatic;
end;

constructor TNimbusChartParametricOptions.Create;
begin
  inherited Create;
  MaximumParameter := 2 * Pi; SampleCount := 1024; MaximumAbsoluteValue := 1000000;
  DiscontinuityThreshold := 40; LineWidth := 2; YAxis := ncyPrimary; DownsamplingMode := ncdAutomatic;
end;

class function TNimbusChartFunctionPoint.Create(const X, Y: Double): TNimbusChartFunctionPoint;
begin Result.XValue := X; Result.YValue := Y end;

function TNimbusChartFunctionPoint.IsValid: Boolean;
begin Result := Finite(XValue) and Finite(YValue) end;

function TNimbusChartFunctionResult.GetSeries: TArray<TNimbusChartSeries>;
begin Result := Copy(FSeries) end;

function TNimbusChartFunctionResult.GetRoots: TArray<TNimbusChartFunctionPoint>;
begin Result := Copy(FRoots) end;

function TNimbusChartFunctionResult.GetExtrema: TArray<TNimbusChartFunctionPoint>;
begin Result := Copy(FExtrema) end;

class function TNimbusChartFunctions.Sine(Amplitude, AngularFrequency, Phase, VerticalOffset: Double): TNimbusChartFunction;
begin Result := function(X: Double): Double begin Result := VerticalOffset + Amplitude * Sin(AngularFrequency * X + Phase) end; end;

class function TNimbusChartFunctions.Cosine(Amplitude, AngularFrequency, Phase, VerticalOffset: Double): TNimbusChartFunction;
begin Result := function(X: Double): Double begin Result := VerticalOffset + Amplitude * Cos(AngularFrequency * X + Phase) end; end;

class function TNimbusChartFunctions.Tangent(Amplitude, AngularFrequency, Phase, VerticalOffset: Double): TNimbusChartFunction;
begin Result := function(X: Double): Double begin Result := VerticalOffset + Amplitude * Tan(AngularFrequency * X + Phase) end; end;

class function TNimbusChartFunctions.Exponential(Amplitude, Rate, VerticalOffset: Double): TNimbusChartFunction;
begin Result := function(X: Double): Double begin Result := VerticalOffset + Amplitude * Exp(Rate * X) end; end;

class function TNimbusChartFunctions.Logarithm(LogarithmicBase, HorizontalOffset, VerticalOffset: Double): TNimbusChartFunction;
var Denominator: Double;
begin
  if not Finite(LogarithmicBase) or (LogarithmicBase <= 0) or (Abs(LogarithmicBase - 1) < 1E-12) then
    raise EArgumentOutOfRangeException.Create('LogarithmicBase must be positive and different from one');
  Denominator := Ln(LogarithmicBase);
  Result := function(X: Double): Double
    begin if X > HorizontalOffset then Result := VerticalOffset + Ln(X - HorizontalOffset) / Denominator else Result := NaN end;
end;

class function TNimbusChartFunctions.Power(Coefficient, Exponent, VerticalOffset: Double): TNimbusChartFunction;
begin Result := function(X: Double): Double begin Result := VerticalOffset + Coefficient * System.Math.Power(X, Exponent) end; end;

class function TNimbusChartFunctions.SquareRoot(Coefficient, HorizontalOffset, VerticalOffset: Double): TNimbusChartFunction;
begin Result := function(X: Double): Double
  begin if X >= HorizontalOffset then Result := VerticalOffset + Coefficient * Sqrt(X - HorizontalOffset) else Result := NaN end; end;

class function TNimbusChartFunctions.Polynomial(const Coefficients: array of Double): TNimbusChartFunction;
var Values: TArray<Double>; I: Integer;
begin
  SetLength(Values, Length(Coefficients)); for I := 0 to High(Values) do Values[I] := Coefficients[I];
  Result := function(X: Double): Double
    var J: Integer;
    begin Result := 0; for J := High(Values) downto 0 do Result := Result * X + Values[J] end;
end;

class function TNimbusChartFunctions.Gaussian(Amplitude, Mean, StandardDeviation, VerticalOffset: Double): TNimbusChartFunction;
var Divisor: Double;
begin
  if not Finite(StandardDeviation) or (StandardDeviation <= 0) then raise EArgumentOutOfRangeException.Create('StandardDeviation must be positive');
  Divisor := 2 * Sqr(StandardDeviation);
  Result := function(X: Double): Double begin Result := VerticalOffset + Amplitude * Exp(-Sqr(X - Mean) / Divisor) end;
end;

class function TNimbusChartFunctions.DampedOscillation(Amplitude, Damping, AngularFrequency, Phase, VerticalOffset: Double): TNimbusChartFunction;
begin Result := function(X: Double): Double
  begin Result := VerticalOffset + Amplitude * Exp(-Damping * X) * Sin(AngularFrequency * X + Phase) end; end;

function Evaluate(const Func: TNimbusChartFunction; const X: Double): Double;
begin
  try Result := Func(X) except on E: EMathError do Result := NaN end;
end;

function ValidatedPoint(const X, Y, Limit: Double): TNimbusChartFunctionPoint;
begin
  if not Finite(X) or not Finite(Y) or (Abs(X) > Limit) or (Abs(Y) > Limit) then
    Result := TNimbusChartFunctionPoint.Create(NaN, NaN)
  else Result := TNimbusChartFunctionPoint.Create(X, Y);
end;

function FunctionPoint(const Func: TNimbusChartFunction; const X: Double; Options: TNimbusChartFunctionOptions): TNimbusChartFunctionPoint;
var Input: Double;
begin
  Input := X; if Options.AngleUnit = ncauDegrees then Input := X * Pi / 180;
  Result := ValidatedPoint(X, Evaluate(Func, Input), Options.MaximumAbsoluteY);
end;

function SampleFunction(const Func: TNimbusChartFunction; Options: TNimbusChartFunctionOptions): TArray<TNimbusChartFunctionPoint>;
var Points: TList<TNimbusChartFunctionPoint>; I: Integer; Step, X: Double; Next: TNimbusChartFunctionPoint;
  procedure Append(const Point: TNimbusChartFunctionPoint);
  begin
    if Points.Count >= MaximumFunctionSamples then raise ERangeError.Create('Function sampling exceeds 1048576 points');
    Points.Add(Point);
  end;
  procedure Adaptive(const Left, Right: TNimbusChartFunctionPoint; const Depth: Integer);
  var Middle: TNimbusChartFunctionPoint; MiddleX, LinearY, Scale: Double;
  begin
    if (Depth >= Options.MaximumAdaptiveDepth) or not Left.IsValid or not Right.IsValid then begin Append(Right); Exit end;
    MiddleX := Left.XValue * 0.5 + Right.XValue * 0.5;
    if (MiddleX = Left.XValue) or (MiddleX = Right.XValue) then begin Append(Right); Exit end;
    Middle := FunctionPoint(Func, MiddleX, Options);
    if not Middle.IsValid then begin Append(Middle); Append(Right); Exit end;
    LinearY := Left.YValue * 0.5 + Right.YValue * 0.5; Scale := Max(1.0, Max(Abs(Left.YValue), Abs(Right.YValue)));
    if Abs(Middle.YValue - LinearY) / Scale <= Options.AdaptiveTolerance then begin Append(Right); Exit end;
    Adaptive(Left, Middle, Depth + 1); Adaptive(Middle, Right, Depth + 1);
  end;
begin
  Points := TList<TNimbusChartFunctionPoint>.Create;
  try
    Step := (Options.MaximumX - Options.MinimumX) / (Options.SampleCount - 1);
    Append(FunctionPoint(Func, Options.MinimumX, Options));
    for I := 1 to Options.SampleCount - 1 do
    begin
      X := Options.MaximumX; if I < Options.SampleCount - 1 then X := Options.MinimumX + Step * I;
      Next := FunctionPoint(Func, X, Options);
      if Options.SamplingMode = ncfsmAdaptive then Adaptive(Points.Last, Next, 0) else Append(Next);
    end;
    Result := Points.ToArray;
  finally Points.Free end;
end;

function SegmentedPoints(const Points: TArray<TNimbusChartFunctionPoint>; const Threshold: Double): TArray<TNimbusChartFunctionPoint>;
var I: Integer; Previous, Current: TNimbusChartFunctionPoint; Scale: Double;
begin
  Result := Copy(Points); Previous := TNimbusChartFunctionPoint.Create(NaN, NaN);
  for I := 0 to High(Result) do
  begin
    Current := Result[I];
    if Current.IsValid and Previous.IsValid and (Threshold > 0) then
    begin
      Scale := Max(1.0, Min(Abs(Current.YValue), Abs(Previous.YValue)));
      if (Abs(Current.XValue - Previous.XValue) > 0) and (Abs(Current.YValue - Previous.YValue) / Scale > Threshold) then
        Result[I] := TNimbusChartFunctionPoint.Create(NaN, NaN);
    end;
    Previous := Result[I];
  end;
end;

function AddSegments(Model: TNimbusChartModel; const Name: string; const Points: TArray<TNimbusChartFunctionPoint>;
  const ShowMarkers: Boolean; const LineWidth: Single; const YAxis: TNimbusChartSeriesYAxis;
  const Downsampling: TNimbusChartDownsamplingMode): TArray<TNimbusChartSeries>;
var I, First: Integer; Series: TNimbusChartSeries; List: TList<TNimbusChartSeries>;
  procedure Flush(const Last: Integer);
  var Title: string; J: Integer;
  begin
    if Last - First < 2 then Exit;
    Title := Name; if List.Count > 0 then Title := Name + ' ' + IntToStr(List.Count + 1);
    Series := Model.AddSeries(Title); Series.RenderKind := nsrkLine; Series.ShowMarkers := ShowMarkers;
    Series.LineWidth := LineWidth; Series.YAxis := YAxis; Series.DownsamplingMode := Downsampling;
    for J := First to Last - 1 do Series.Points.Add(Points[J].XValue, Points[J].YValue);
    List.Add(Series);
  end;
begin
  List := TList<TNimbusChartSeries>.Create;
  try
    First := 0;
    for I := 0 to High(Points) do if not Points[I].IsValid then
    begin Flush(I); First := I + 1 end;
    Flush(Length(Points)); Result := List.ToArray;
  finally List.Free end;
end;

procedure AddUnique(List: TList<TNimbusChartFunctionPoint>; const Point: TNimbusChartFunctionPoint);
begin if (List.Count = 0) or (Abs(List.Last.XValue - Point.XValue) > 1E-6) then List.Add(Point) end;

procedure Analyze(const Points: TArray<TNimbusChartFunctionPoint>; const Roots, Extrema: TList<TNimbusChartFunctionPoint>);
var I: Integer; Left, Current, Right: TNimbusChartFunctionPoint; Ratio, LeftSlope, RightSlope: Double;
begin
  for I := 0 to High(Points) do
  begin
    Current := Points[I]; if not Current.IsValid then Continue;
    if Assigned(Roots) then
    begin
      if Abs(Current.YValue) < 1E-8 then AddUnique(Roots, TNimbusChartFunctionPoint.Create(Current.XValue, 0));
      if I < High(Points) then
      begin
        Right := Points[I + 1];
        if Right.IsValid and (((Current.YValue < 0) and (Right.YValue > 0)) or ((Current.YValue > 0) and (Right.YValue < 0))) then
        begin Ratio := -Current.YValue / (Right.YValue - Current.YValue); AddUnique(Roots, TNimbusChartFunctionPoint.Create(Current.XValue + (Right.XValue - Current.XValue) * Ratio, 0)) end;
      end;
    end;
    if Assigned(Extrema) and (I > 0) and (I < High(Points)) then
    begin
      Left := Points[I - 1]; Right := Points[I + 1];
      if not Left.IsValid or not Right.IsValid then Continue;
      LeftSlope := Current.YValue - Left.YValue; RightSlope := Right.YValue - Current.YValue;
      if ((LeftSlope > 0) and (RightSlope < 0)) or ((LeftSlope < 0) and (RightSlope > 0)) then AddUnique(Extrema, Current);
    end;
  end;
end;

procedure AddAnnotations(Model: TNimbusChartModel; const Points: TArray<TNimbusChartFunctionPoint>; const Prefix: string; const YAxis: TNimbusChartSeriesYAxis);
var I: Integer; Annotation: TNimbusChartAnnotation;
begin
  for I := 0 to High(Points) do
  begin
    Annotation := Model.Annotations.Add; Annotation.XValue := Points[I].XValue; Annotation.YValue := Points[I].YValue;
    Annotation.Text := Prefix + ' ' + IntToStr(I + 1); Annotation.YAxis := YAxis; Annotation.Alignment := ncaaCenter;
  end;
end;

procedure AddReferenceAxes(Model: TNimbusChartModel);
var I: Integer; Horizontal, Vertical: Boolean; Line: TNimbusChartReferenceLine;
begin
  Horizontal := False; Vertical := False;
  for I := 0 to Model.ReferenceLines.Count - 1 do
  begin
    Line := Model.ReferenceLines[I]; if Abs(Line.Value) > 1E-12 then Continue;
    if Line.Orientation = ncroHorizontal then Horizontal := True else Vertical := True;
  end;
  if not Horizontal then begin Line := Model.ReferenceLines.Add; Line.Orientation := ncroHorizontal; Line.Value := 0 end;
  if not Vertical then begin Line := Model.ReferenceLines.Add; Line.Orientation := ncroVertical; Line.Value := 0 end;
end;

function DerivativePoints(const Func: TNimbusChartFunction; const Points: TArray<TNimbusChartFunctionPoint>;
  Options: TNimbusChartFunctionOptions): TArray<TNimbusChartFunctionPoint>;
var I: Integer; DX: Double; Left, Right, Current: TNimbusChartFunctionPoint;
begin
  SetLength(Result, Length(Points));
  for I := 0 to High(Points) do
  begin
    Result[I] := TNimbusChartFunctionPoint.Create(NaN, NaN);
    if (I = 0) or (I = High(Points)) then Continue;
    if not Points[I].IsValid or not Points[I - 1].IsValid or not Points[I + 1].IsValid then Continue;
    Current := Points[I]; Left := Points[I - 1]; Right := Points[I + 1];
    if Options.DerivativeStep > 0 then
    begin
      Left := FunctionPoint(Func, Current.XValue - Options.DerivativeStep, Options);
      Right := FunctionPoint(Func, Current.XValue + Options.DerivativeStep, Options);
    end;
    if not Left.IsValid or not Right.IsValid then Continue;
    DX := Right.XValue - Left.XValue; if Abs(DX) < 1E-12 then Continue;
    Result[I] := TNimbusChartFunctionPoint.Create(Current.XValue, (Right.YValue - Left.YValue) / DX);
  end;
end;

function IntegralPoints(const Points: TArray<TNimbusChartFunctionPoint>; const Initial: Double): TArray<TNimbusChartFunctionPoint>;
var I: Integer; Value: Double; Previous, Current: TNimbusChartFunctionPoint;
begin
  SetLength(Result, Length(Points)); Value := Initial; Previous := TNimbusChartFunctionPoint.Create(NaN, NaN);
  for I := 0 to High(Points) do
  begin
    Current := Points[I]; Result[I] := TNimbusChartFunctionPoint.Create(NaN, NaN);
    if Current.IsValid then
    begin
      if Previous.IsValid then Value := Value + (Current.XValue - Previous.XValue) * (Current.YValue * 0.5 + Previous.YValue * 0.5);
      Result[I] := TNimbusChartFunctionPoint.Create(Current.XValue, Value);
    end;
    Previous := Current;
  end;
end;

procedure ValidateOptions(Options: TNimbusChartFunctionOptions);
begin
  if not Finite(Options.MinimumX) or not Finite(Options.MaximumX) or (Options.MaximumX <= Options.MinimumX) or
    not Finite(Options.MaximumX - Options.MinimumX) then raise EArgumentException.Create('MaximumX must be finite and greater than MinimumX');
  Options.SampleCount := Max(2, Options.SampleCount);
  if Options.SampleCount > MaximumFunctionSamples then raise EArgumentOutOfRangeException.Create('SampleCount exceeds 1048576');
  Options.MaximumAdaptiveDepth := EnsureRange(Options.MaximumAdaptiveDepth, 0, 20);
  if not Finite(Options.AdaptiveTolerance) or (Options.AdaptiveTolerance <= 0) then Options.AdaptiveTolerance := 0.0025;
  if not Finite(Options.MaximumAbsoluteY) or (Options.MaximumAbsoluteY <= 0) then Options.MaximumAbsoluteY := 1000000;
  if not Finite(Options.DiscontinuityThreshold) or not Finite(Options.LineWidth) or (Options.LineWidth <= 0) or
    not Finite(Options.DerivativeStep) or (Options.DerivativeStep < 0) or not Finite(Options.IntegralInitialValue) then
    raise EArgumentException.Create('Function styling and analysis options must be finite and valid');
end;

class function TNimbusChartFunctionPlotter.AddFunctionSeries(Model: TNimbusChartModel; const Name: string; const Func: TNimbusChartFunction;
  Options: TNimbusChartFunctionOptions): TNimbusChartFunctionResult;
var Actual: TNimbusChartFunctionOptions; Owned: Boolean; Points, Derived, Integrated: TArray<TNimbusChartFunctionPoint>;
  Roots, Extrema: TList<TNimbusChartFunctionPoint>; RootTarget, ExtremaTarget: TList<TNimbusChartFunctionPoint>;
  Added: TArray<TNimbusChartSeries>;
begin
  if Model = nil then raise EArgumentNilException.Create('Model');
  if not Assigned(Func) then raise EArgumentNilException.Create('Function');
  Owned := Options = nil; Actual := Options; if Owned then Actual := TNimbusChartFunctionOptions.Create;
  try
    ValidateOptions(Actual); Points := SegmentedPoints(SampleFunction(Func, Actual), Actual.DiscontinuityThreshold);
    if Actual.AddDerivativeSeries then Derived := SegmentedPoints(DerivativePoints(Func, Points, Actual), Actual.DiscontinuityThreshold);
    if Actual.AddIntegralSeries then Integrated := SegmentedPoints(IntegralPoints(Points, Actual.IntegralInitialValue), Actual.DiscontinuityThreshold);
    Result := TNimbusChartFunctionResult.Create;
    try
      Roots := TList<TNimbusChartFunctionPoint>.Create;
      try
        Extrema := TList<TNimbusChartFunctionPoint>.Create;
        try
          RootTarget := nil; ExtremaTarget := nil;
          if Actual.DetectRoots or Actual.AddRootAnnotations then RootTarget := Roots;
          if Actual.DetectExtrema or Actual.AddExtremaAnnotations then ExtremaTarget := Extrema;
          Analyze(Points, RootTarget, ExtremaTarget); Result.FRoots := Roots.ToArray; Result.FExtrema := Extrema.ToArray;
        finally Extrema.Free end;
      finally Roots.Free end;
      Model.BeginUpdate;
      try
        Result.FSeries := AddSegments(Model, Name, Points, Actual.ShowMarkers, Actual.LineWidth, Actual.YAxis, Actual.DownsamplingMode);
        if Actual.AddRootAnnotations then AddAnnotations(Model, Result.FRoots, 'Root', Actual.YAxis);
        if Actual.AddExtremaAnnotations then AddAnnotations(Model, Result.FExtrema, 'Extremum', Actual.YAxis);
        if Actual.AddReferenceAxes then AddReferenceAxes(Model);
        if Actual.AddDerivativeSeries then
        begin
          Added := AddSegments(Model, Name + ' derivative', Derived, False, Max(Single(1), Actual.LineWidth - 0.5), Actual.YAxis, Actual.DownsamplingMode);
          if Length(Added) > 0 then Result.FDerivativeSeries := Added[0];
        end;
        if Actual.AddIntegralSeries then
        begin
          Added := AddSegments(Model, Name + ' integral', Integrated, False, Max(Single(1), Actual.LineWidth - 0.5), Actual.YAxis, Actual.DownsamplingMode);
          if Length(Added) > 0 then Result.FIntegralSeries := Added[0];
        end;
      finally Model.EndUpdate end;
    except Result.Free; raise end;
  finally if Owned then Actual.Free end;
end;

class function TNimbusChartFunctionPlotter.AddParametricSeries(Model: TNimbusChartModel; const Name: string;
  const XFunction, YFunction: TNimbusChartParametricFunction; Options: TNimbusChartParametricOptions): TNimbusChartFunctionResult;
var Actual: TNimbusChartParametricOptions; Owned: Boolean; Points: TArray<TNimbusChartFunctionPoint>; I, Count: Integer; Step, T: Double;
begin
  if Model = nil then raise EArgumentNilException.Create('Model');
  if not Assigned(XFunction) or not Assigned(YFunction) then raise EArgumentNilException.Create('Parametric function');
  Owned := Options = nil; Actual := Options; if Owned then Actual := TNimbusChartParametricOptions.Create;
  try
    if not Finite(Actual.MinimumParameter) or not Finite(Actual.MaximumParameter) or
      (Actual.MaximumParameter <= Actual.MinimumParameter) or not Finite(Actual.MaximumParameter - Actual.MinimumParameter) then
      raise EArgumentException.Create('MaximumParameter must be finite and greater than MinimumParameter');
    if not Finite(Actual.MaximumAbsoluteValue) or (Actual.MaximumAbsoluteValue <= 0) or
      not Finite(Actual.DiscontinuityThreshold) or not Finite(Actual.LineWidth) or (Actual.LineWidth <= 0) then
      raise EArgumentException.Create('Parametric options must be finite and valid');
    Count := Max(2, Actual.SampleCount);
    if Count > MaximumFunctionSamples then raise EArgumentOutOfRangeException.Create('SampleCount exceeds 1048576');
    SetLength(Points, Count); Step := (Actual.MaximumParameter - Actual.MinimumParameter) / (Count - 1);
    for I := 0 to Count - 1 do
    begin
      T := Actual.MaximumParameter; if I < Count - 1 then T := Actual.MinimumParameter + Step * I;
      Points[I] := ValidatedPoint(Evaluate(XFunction, T), Evaluate(YFunction, T), Actual.MaximumAbsoluteValue);
    end;
    Points := SegmentedPoints(Points, Actual.DiscontinuityThreshold);
    Result := TNimbusChartFunctionResult.Create;
    try
      Model.BeginUpdate;
      try Result.FSeries := AddSegments(Model, Name, Points, Actual.ShowMarkers, Actual.LineWidth, Actual.YAxis, Actual.DownsamplingMode)
      finally Model.EndUpdate end;
    except Result.Free; raise end;
  finally if Owned then Actual.Free end;
end;

function TNimbusChartFunctionModelHelper.AddFunctionSeries(const Name: string; const Func: TNimbusChartFunction;
  Options: TNimbusChartFunctionOptions): TNimbusChartFunctionResult;
begin Result := TNimbusChartFunctionPlotter.AddFunctionSeries(Self, Name, Func, Options) end;

function TNimbusChartFunctionModelHelper.AddParametricSeries(const Name: string; const XFunction, YFunction: TNimbusChartParametricFunction;
  Options: TNimbusChartParametricOptions): TNimbusChartFunctionResult;
begin Result := TNimbusChartFunctionPlotter.AddParametricSeries(Self, Name, XFunction, YFunction, Options) end;

end.

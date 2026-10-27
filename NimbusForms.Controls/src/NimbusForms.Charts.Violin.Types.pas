{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Charts.Violin.Types;

interface

uses System.Classes, System.SysUtils, System.Math, System.Generics.Collections, Vcl.Graphics, NimbusForms.Charts.Sparkline.Types;

type
  TNimbusViolinBandwidthMode = (nvbAutomatic, nvbScott, nvbSilverman, nvbFixed);
  TNimbusViolinShapeMode = (nvsFull, nvsLeftHalf, nvsRightHalf);
  TNimbusViolinPointDisplayMode = (nvpNone, nvpJitter, nvpBeeswarm);
  TNimbusViolinOrientation = (nvoVertical, nvoHorizontal);
  TNimbusViolinLayoutMode = (nvlSeparate, nvlSplitPairs);
  TNimbusViolinDensityNormalization = (nvnPerSeries, nvnGlobal, nvnSampleCount);
  TNimbusViolinTailMode = (nvtDataRange, nvtExtendedBandwidth);

  TNimbusViolinPlotOptions = class(TPersistent)
  private
    FBandwidthMode: TNimbusViolinBandwidthMode;
    FShapeMode: TNimbusViolinShapeMode;
    FPointDisplayMode: TNimbusViolinPointDisplayMode;
    FOrientation: TNimbusViolinOrientation;
    FLayoutMode: TNimbusViolinLayoutMode;
    FDensityNormalization: TNimbusViolinDensityNormalization;
    FTailMode: TNimbusViolinTailMode;
    FFixedBandwidth: Double;
    FDensitySampleCount: Integer;
    FMaximumRenderedPoints: Integer;
    FMaximumWidthRatio: Single;
    FFillOpacity: Single;
    FOutlineWidth: Single;
    FShowMedian: Boolean;
    FShowMean: Boolean;
    FShowQuartiles: Boolean;
    FShowInnerBox: Boolean;
    FShowWhiskers: Boolean;
    FShowOutliers: Boolean;
    FShowSampleCount: Boolean;
    FShowDensityScale: Boolean;
    FShowStandardDeviation: Boolean;
    FShowMeanConfidenceInterval: Boolean;
    FShowZeroReferenceLine: Boolean;
    FPointSize: Single;
    FPointOpacity: Single;
    FJitterRatio: Single;
    FConfidenceLevel: Single;
    FMedianColor: TColor;
    FMeanColor: TColor;
    FBoxColor: TColor;
    FPointColor: TColor;
    FConfidenceIntervalColor: TColor;
    FStandardDeviationColor: TColor;
    FOnChange: TNotifyEvent;
    procedure Changed;
    procedure SetBandwidthMode(const AValue: TNimbusViolinBandwidthMode);
    procedure SetShapeMode(const AValue: TNimbusViolinShapeMode);
    procedure SetPointDisplayMode(const AValue: TNimbusViolinPointDisplayMode);
    procedure SetOrientation(const AValue: TNimbusViolinOrientation);
    procedure SetLayoutMode(const AValue: TNimbusViolinLayoutMode);
    procedure SetDensityNormalization(const AValue: TNimbusViolinDensityNormalization);
    procedure SetTailMode(const AValue: TNimbusViolinTailMode);
    procedure SetFixedBandwidth(const AValue: Double);
    procedure SetDensitySampleCount(const AValue: Integer);
    procedure SetMaximumRenderedPoints(const AValue: Integer);
    procedure SetMaximumWidthRatio(const AValue: Single);
    procedure SetFillOpacity(const AValue: Single);
    procedure SetOutlineWidth(const AValue: Single);
    procedure SetShowMedian(const AValue: Boolean);
    procedure SetShowMean(const AValue: Boolean);
    procedure SetShowQuartiles(const AValue: Boolean);
    procedure SetShowInnerBox(const AValue: Boolean);
    procedure SetShowWhiskers(const AValue: Boolean);
    procedure SetShowOutliers(const AValue: Boolean);
    procedure SetShowSampleCount(const AValue: Boolean);
    procedure SetShowDensityScale(const AValue: Boolean);
    procedure SetShowStandardDeviation(const AValue: Boolean);
    procedure SetShowMeanConfidenceInterval(const AValue: Boolean);
    procedure SetShowZeroReferenceLine(const AValue: Boolean);
    procedure SetPointSize(const AValue: Single);
    procedure SetPointOpacity(const AValue: Single);
    procedure SetJitterRatio(const AValue: Single);
    procedure SetConfidenceLevel(const AValue: Single);
    procedure SetMedianColor(const AValue: TColor);
    procedure SetMeanColor(const AValue: TColor);
    procedure SetBoxColor(const AValue: TColor);
    procedure SetPointColor(const AValue: TColor);
    procedure SetConfidenceIntervalColor(const AValue: TColor);
    procedure SetStandardDeviationColor(const AValue: TColor);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property BandwidthMode: TNimbusViolinBandwidthMode read FBandwidthMode write SetBandwidthMode default nvbAutomatic;
    property ShapeMode: TNimbusViolinShapeMode read FShapeMode write SetShapeMode default nvsFull;
    property PointDisplayMode: TNimbusViolinPointDisplayMode read FPointDisplayMode write SetPointDisplayMode default nvpJitter;
    property Orientation: TNimbusViolinOrientation read FOrientation write SetOrientation default nvoVertical;
    property LayoutMode: TNimbusViolinLayoutMode read FLayoutMode write SetLayoutMode default nvlSeparate;
    property DensityNormalization: TNimbusViolinDensityNormalization read FDensityNormalization write SetDensityNormalization default nvnPerSeries;
    property TailMode: TNimbusViolinTailMode read FTailMode write SetTailMode default nvtExtendedBandwidth;
    property FixedBandwidth: Double read FFixedBandwidth write SetFixedBandwidth;
    property DensitySampleCount: Integer read FDensitySampleCount write SetDensitySampleCount default 160;
    property MaximumRenderedPoints: Integer read FMaximumRenderedPoints write SetMaximumRenderedPoints default 600;
    property MaximumWidthRatio: Single read FMaximumWidthRatio write SetMaximumWidthRatio;
    property FillOpacity: Single read FFillOpacity write SetFillOpacity;
    property OutlineWidth: Single read FOutlineWidth write SetOutlineWidth;
    property ShowMedian: Boolean read FShowMedian write SetShowMedian default True;
    property ShowMean: Boolean read FShowMean write SetShowMean default True;
    property ShowQuartiles: Boolean read FShowQuartiles write SetShowQuartiles default True;
    property ShowInnerBox: Boolean read FShowInnerBox write SetShowInnerBox default True;
    property ShowWhiskers: Boolean read FShowWhiskers write SetShowWhiskers default True;
    property ShowOutliers: Boolean read FShowOutliers write SetShowOutliers default True;
    property ShowSampleCount: Boolean read FShowSampleCount write SetShowSampleCount default True;
    property ShowDensityScale: Boolean read FShowDensityScale write SetShowDensityScale default False;
    property ShowStandardDeviation: Boolean read FShowStandardDeviation write SetShowStandardDeviation default False;
    property ShowMeanConfidenceInterval: Boolean read FShowMeanConfidenceInterval write SetShowMeanConfidenceInterval default False;
    property ShowZeroReferenceLine: Boolean read FShowZeroReferenceLine write SetShowZeroReferenceLine default False;
    property PointSize: Single read FPointSize write SetPointSize;
    property PointOpacity: Single read FPointOpacity write SetPointOpacity;
    property JitterRatio: Single read FJitterRatio write SetJitterRatio;
    property ConfidenceLevel: Single read FConfidenceLevel write SetConfidenceLevel;
    property MedianColor: TColor read FMedianColor write SetMedianColor default clNone;
    property MeanColor: TColor read FMeanColor write SetMeanColor default clNone;
    property BoxColor: TColor read FBoxColor write SetBoxColor default clNone;
    property PointColor: TColor read FPointColor write SetPointColor default clNone;
    property ConfidenceIntervalColor: TColor read FConfidenceIntervalColor write SetConfidenceIntervalColor default clNone;
    property StandardDeviationColor: TColor read FStandardDeviationColor write SetStandardDeviationColor default clNone;
  end;

  TNimbusViolinStatistics = record
    Values, DensityValues, Density: TSparklineValues;
    Minimum, Maximum, Mean, StandardDeviation, Median, Q1, Q3, LowerWhisker, UpperWhisker: Double;
    ConfidenceMinimum, ConfidenceMaximum, Bandwidth, MaximumDensity: Double;
  end;

function NimbusViolinBandwidth(const Values: TSparklineValues; Options: TNimbusViolinPlotOptions): Double;
function NimbusViolinStatistics(const Values: TSparklineValues; Options: TNimbusViolinPlotOptions; const RangeMinimum, RangeMaximum: Double): TNimbusViolinStatistics;

implementation

procedure TNimbusViolinPlotOptions.Changed;
begin if Assigned(FOnChange) then FOnChange(Self) end;

constructor TNimbusViolinPlotOptions.Create;
begin
  inherited Create;
  FBandwidthMode := nvbAutomatic;
  FShapeMode := nvsFull;
  FPointDisplayMode := nvpJitter;
  FOrientation := nvoVertical;
  FLayoutMode := nvlSeparate;
  FDensityNormalization := nvnPerSeries;
  FTailMode := nvtExtendedBandwidth;
  FFixedBandwidth := 1;
  FDensitySampleCount := 160;
  FMaximumRenderedPoints := 600;
  FMaximumWidthRatio := 0.82;
  FFillOpacity := 0.36;
  FOutlineWidth := 1.6;
  FShowMedian := True;
  FShowMean := True;
  FShowQuartiles := True;
  FShowInnerBox := True;
  FShowWhiskers := True;
  FShowOutliers := True;
  FShowSampleCount := True;
  FShowDensityScale := False;
  FShowStandardDeviation := False;
  FShowMeanConfidenceInterval := False;
  FShowZeroReferenceLine := False;
  FPointSize := 3.5;
  FPointOpacity := 0.42;
  FJitterRatio := 0.72;
  FConfidenceLevel := 0.95;
  FMedianColor := clNone;
  FMeanColor := clNone;
  FBoxColor := clNone;
  FPointColor := clNone;
  FConfidenceIntervalColor := clNone;
  FStandardDeviationColor := clNone;
end;

procedure TNimbusViolinPlotOptions.Assign(Source: TPersistent);
var S: TNimbusViolinPlotOptions;
begin
  if not (Source is TNimbusViolinPlotOptions) then begin inherited; Exit end;
  S := TNimbusViolinPlotOptions(Source);
  FBandwidthMode := S.FBandwidthMode;
  FShapeMode := S.FShapeMode;
  FPointDisplayMode := S.FPointDisplayMode;
  FOrientation := S.FOrientation;
  FLayoutMode := S.FLayoutMode;
  FDensityNormalization := S.FDensityNormalization;
  FTailMode := S.FTailMode;
  FFixedBandwidth := S.FFixedBandwidth;
  FDensitySampleCount := S.FDensitySampleCount;
  FMaximumRenderedPoints := S.FMaximumRenderedPoints;
  FMaximumWidthRatio := S.FMaximumWidthRatio;
  FFillOpacity := S.FFillOpacity;
  FOutlineWidth := S.FOutlineWidth;
  FShowMedian := S.FShowMedian;
  FShowMean := S.FShowMean;
  FShowQuartiles := S.FShowQuartiles;
  FShowInnerBox := S.FShowInnerBox;
  FShowWhiskers := S.FShowWhiskers;
  FShowOutliers := S.FShowOutliers;
  FShowSampleCount := S.FShowSampleCount;
  FShowDensityScale := S.FShowDensityScale;
  FShowStandardDeviation := S.FShowStandardDeviation;
  FShowMeanConfidenceInterval := S.FShowMeanConfidenceInterval;
  FShowZeroReferenceLine := S.FShowZeroReferenceLine;
  FPointSize := S.FPointSize;
  FPointOpacity := S.FPointOpacity;
  FJitterRatio := S.FJitterRatio;
  FConfidenceLevel := S.FConfidenceLevel;
  FMedianColor := S.FMedianColor;
  FMeanColor := S.FMeanColor;
  FBoxColor := S.FBoxColor;
  FPointColor := S.FPointColor;
  FConfidenceIntervalColor := S.FConfidenceIntervalColor;
  FStandardDeviationColor := S.FStandardDeviationColor;
  Changed;
end;

procedure TNimbusViolinPlotOptions.SetBandwidthMode(const AValue: TNimbusViolinBandwidthMode);
begin if FBandwidthMode = AValue then Exit; FBandwidthMode := AValue; Changed end;

procedure TNimbusViolinPlotOptions.SetShapeMode(const AValue: TNimbusViolinShapeMode);
begin if FShapeMode = AValue then Exit; FShapeMode := AValue; Changed end;

procedure TNimbusViolinPlotOptions.SetPointDisplayMode(const AValue: TNimbusViolinPointDisplayMode);
begin if FPointDisplayMode = AValue then Exit; FPointDisplayMode := AValue; Changed end;

procedure TNimbusViolinPlotOptions.SetOrientation(const AValue: TNimbusViolinOrientation);
begin if FOrientation = AValue then Exit; FOrientation := AValue; Changed end;

procedure TNimbusViolinPlotOptions.SetLayoutMode(const AValue: TNimbusViolinLayoutMode);
begin if FLayoutMode = AValue then Exit; FLayoutMode := AValue; Changed end;

procedure TNimbusViolinPlotOptions.SetDensityNormalization(const AValue: TNimbusViolinDensityNormalization);
begin if FDensityNormalization = AValue then Exit; FDensityNormalization := AValue; Changed end;

procedure TNimbusViolinPlotOptions.SetTailMode(const AValue: TNimbusViolinTailMode);
begin if FTailMode = AValue then Exit; FTailMode := AValue; Changed end;

procedure TNimbusViolinPlotOptions.SetFixedBandwidth(const AValue: Double);
var Value: Double;
begin
  if IsNan(AValue) or IsInfinite(AValue) then Exit; Value := Max(0.000001, AValue);
  if FFixedBandwidth = Value then Exit; FFixedBandwidth := Value; Changed;
end;

procedure TNimbusViolinPlotOptions.SetDensitySampleCount(const AValue: Integer);
begin if FDensitySampleCount = EnsureRange(AValue, 32, 512) then Exit; FDensitySampleCount := EnsureRange(AValue, 32, 512); Changed end;

procedure TNimbusViolinPlotOptions.SetMaximumRenderedPoints(const AValue: Integer);
begin if FMaximumRenderedPoints = Max(0, AValue) then Exit; FMaximumRenderedPoints := Max(0, AValue); Changed end;

procedure TNimbusViolinPlotOptions.SetMaximumWidthRatio(const AValue: Single);
var Value: Single;
begin
  if IsNan(AValue) or IsInfinite(AValue) then Exit; Value := EnsureRange(AValue, Single(0.1), Single(0.96));
  if FMaximumWidthRatio = Value then Exit; FMaximumWidthRatio := Value; Changed;
end;

procedure TNimbusViolinPlotOptions.SetFillOpacity(const AValue: Single);
var Value: Single;
begin
  if IsNan(AValue) or IsInfinite(AValue) then Exit; Value := EnsureRange(AValue, Single(0), Single(1));
  if FFillOpacity = Value then Exit; FFillOpacity := Value; Changed;
end;

procedure TNimbusViolinPlotOptions.SetOutlineWidth(const AValue: Single);
var Value: Single;
begin
  if IsNan(AValue) or IsInfinite(AValue) then Exit; Value := Max(Single(0.5), AValue);
  if FOutlineWidth = Value then Exit; FOutlineWidth := Value; Changed;
end;

procedure TNimbusViolinPlotOptions.SetShowMedian(const AValue: Boolean);
begin if FShowMedian = AValue then Exit; FShowMedian := AValue; Changed end;

procedure TNimbusViolinPlotOptions.SetShowMean(const AValue: Boolean);
begin if FShowMean = AValue then Exit; FShowMean := AValue; Changed end;

procedure TNimbusViolinPlotOptions.SetShowQuartiles(const AValue: Boolean);
begin if FShowQuartiles = AValue then Exit; FShowQuartiles := AValue; Changed end;

procedure TNimbusViolinPlotOptions.SetShowInnerBox(const AValue: Boolean);
begin if FShowInnerBox = AValue then Exit; FShowInnerBox := AValue; Changed end;

procedure TNimbusViolinPlotOptions.SetShowWhiskers(const AValue: Boolean);
begin if FShowWhiskers = AValue then Exit; FShowWhiskers := AValue; Changed end;

procedure TNimbusViolinPlotOptions.SetShowOutliers(const AValue: Boolean);
begin if FShowOutliers = AValue then Exit; FShowOutliers := AValue; Changed end;

procedure TNimbusViolinPlotOptions.SetShowSampleCount(const AValue: Boolean);
begin if FShowSampleCount = AValue then Exit; FShowSampleCount := AValue; Changed end;

procedure TNimbusViolinPlotOptions.SetShowDensityScale(const AValue: Boolean);
begin if FShowDensityScale = AValue then Exit; FShowDensityScale := AValue; Changed end;

procedure TNimbusViolinPlotOptions.SetShowStandardDeviation(const AValue: Boolean);
begin if FShowStandardDeviation = AValue then Exit; FShowStandardDeviation := AValue; Changed end;

procedure TNimbusViolinPlotOptions.SetShowMeanConfidenceInterval(const AValue: Boolean);
begin if FShowMeanConfidenceInterval = AValue then Exit; FShowMeanConfidenceInterval := AValue; Changed end;

procedure TNimbusViolinPlotOptions.SetShowZeroReferenceLine(const AValue: Boolean);
begin if FShowZeroReferenceLine = AValue then Exit; FShowZeroReferenceLine := AValue; Changed end;

procedure TNimbusViolinPlotOptions.SetPointSize(const AValue: Single);
var Value: Single;
begin
  if IsNan(AValue) or IsInfinite(AValue) then Exit; Value := Max(Single(0.1), AValue);
  if FPointSize = Value then Exit; FPointSize := Value; Changed;
end;

procedure TNimbusViolinPlotOptions.SetPointOpacity(const AValue: Single);
var Value: Single;
begin
  if IsNan(AValue) or IsInfinite(AValue) then Exit; Value := EnsureRange(AValue, Single(0), Single(1));
  if FPointOpacity = Value then Exit; FPointOpacity := Value; Changed;
end;

procedure TNimbusViolinPlotOptions.SetJitterRatio(const AValue: Single);
var Value: Single;
begin
  if IsNan(AValue) or IsInfinite(AValue) then Exit; Value := EnsureRange(AValue, Single(0), Single(1));
  if FJitterRatio = Value then Exit; FJitterRatio := Value; Changed;
end;

procedure TNimbusViolinPlotOptions.SetConfidenceLevel(const AValue: Single);
var Value: Single;
begin
  if IsNan(AValue) or IsInfinite(AValue) then Exit; Value := EnsureRange(AValue, Single(0.8), Single(0.999));
  if FConfidenceLevel = Value then Exit; FConfidenceLevel := Value; Changed;
end;

procedure TNimbusViolinPlotOptions.SetMedianColor(const AValue: TColor);
begin if FMedianColor = AValue then Exit; FMedianColor := AValue; Changed end;

procedure TNimbusViolinPlotOptions.SetMeanColor(const AValue: TColor);
begin if FMeanColor = AValue then Exit; FMeanColor := AValue; Changed end;

procedure TNimbusViolinPlotOptions.SetBoxColor(const AValue: TColor);
begin if FBoxColor = AValue then Exit; FBoxColor := AValue; Changed end;

procedure TNimbusViolinPlotOptions.SetPointColor(const AValue: TColor);
begin if FPointColor = AValue then Exit; FPointColor := AValue; Changed end;

procedure TNimbusViolinPlotOptions.SetConfidenceIntervalColor(const AValue: TColor);
begin if FConfidenceIntervalColor = AValue then Exit; FConfidenceIntervalColor := AValue; Changed end;

procedure TNimbusViolinPlotOptions.SetStandardDeviationColor(const AValue: TColor);
begin if FStandardDeviationColor = AValue then Exit; FStandardDeviationColor := AValue; Changed end;

function Percentile(const Values: TSparklineValues; const Ratio: Double): Double;
var Position, Fraction: Double; Index: Integer;
begin
  Result := 0; if Length(Values) = 0 then Exit;
  Position := EnsureRange(Ratio, 0.0, 1.0) * High(Values); Index := Floor(Position); Fraction := Position - Index;
  Result := Values[Index]; if Index < High(Values) then Result := Result + (Values[Index + 1] - Result) * Fraction;
end;

procedure Moments(const Values: TSparklineValues; out Mean, Deviation: Double);
var I: Integer; Delta, Sum: Double;
begin
  Mean := 0; Sum := 0; Deviation := 0;
  for I := 0 to High(Values) do begin Delta := Values[I] - Mean; Mean := Mean + Delta / (I + 1); Sum := Sum + Delta * (Values[I] - Mean) end;
  if Length(Values) > 1 then Deviation := Sqrt(Max(0.0, Sum / (Length(Values) - 1)));
end;

function NimbusViolinBandwidth(const Values: TSparklineValues; Options: TNimbusViolinPlotOptions): Double;
var Mean, Deviation, Sigma, Scott, Silverman, Factor: Double;
begin
  Result := 0.000001; if Length(Values) = 0 then Exit;
  if Options.BandwidthMode = nvbFixed then Exit(Options.FixedBandwidth);
  Moments(Values, Mean, Deviation); Factor := Power(Length(Values), -0.2); Scott := Deviation * Factor;
  Sigma := Min(Deviation, (Percentile(Values, 0.75) - Percentile(Values, 0.25)) / 1.34); if Sigma <= 0 then Sigma := Deviation;
  Silverman := 0.9 * Sigma * Factor;
  case Options.BandwidthMode of
    nvbScott: Result := Scott;
    nvbSilverman: Result := Silverman;
    else if Length(Values) < 30 then Result := Silverman else Result := (Silverman + Scott) / 2;
  end;
  if not SparklineFinite(Result) or (Result <= 0) then Result := Max(0.000001, (Values[High(Values)] - Values[0]) / 20);
end;

function NimbusViolinStatistics(const Values: TSparklineValues; Options: TNimbusViolinPlotOptions; const RangeMinimum, RangeMaximum: Double): TNimbusViolinStatistics;
var I, J, Count: Integer; Iqr, Fence, Z, Margin, LowValue, HighValue, Span, Value, Density, Factor: Double;
begin
  Result := Default(TNimbusViolinStatistics); Count := 0; SetLength(Result.Values, Length(Values));
  for Value in Values do if SparklineFinite(Value) then begin Result.Values[Count] := Value; Inc(Count) end;
  SetLength(Result.Values, Count); if Count = 0 then Exit; TArray.Sort<Double>(Result.Values);
  Result.Minimum := Result.Values[0]; Result.Maximum := Result.Values[Count - 1];
  Moments(Result.Values, Result.Mean, Result.StandardDeviation);
  Result.Q1 := Percentile(Result.Values, 0.25); Result.Median := Percentile(Result.Values, 0.5); Result.Q3 := Percentile(Result.Values, 0.75);
  Iqr := Result.Q3 - Result.Q1; Fence := Result.Q1 - 1.5 * Iqr; Result.LowerWhisker := Result.Minimum;
  for I := 0 to Count - 1 do if Result.Values[I] >= Fence then begin Result.LowerWhisker := Result.Values[I]; Break end;
  Fence := Result.Q3 + 1.5 * Iqr; Result.UpperWhisker := Result.Maximum;
  for I := Count - 1 downto 0 do if Result.Values[I] <= Fence then begin Result.UpperWhisker := Result.Values[I]; Break end;
  Result.Bandwidth := NimbusViolinBandwidth(Result.Values, Options);
  if Options.ConfidenceLevel >= Single(0.999) then Z := 3.291 else if Options.ConfidenceLevel >= Single(0.99) then Z := 2.576
  else if Options.ConfidenceLevel >= Single(0.98) then Z := 2.326 else if Options.ConfidenceLevel >= Single(0.95) then Z := 1.96
  else if Options.ConfidenceLevel >= Single(0.9) then Z := 1.645 else Z := 1.282;
  Margin := Z * Result.StandardDeviation / Sqrt(Count); Result.ConfidenceMinimum := Result.Mean - Margin; Result.ConfidenceMaximum := Result.Mean + Margin;
  LowValue := Result.Minimum; HighValue := Result.Maximum;
  if Options.TailMode = nvtExtendedBandwidth then begin LowValue := LowValue - 2.5 * Result.Bandwidth; HighValue := HighValue + 2.5 * Result.Bandwidth end;
  LowValue := Max(RangeMinimum, LowValue); HighValue := Min(RangeMaximum, HighValue); Span := HighValue - LowValue; if Span <= 0 then Span := 1;
  SetLength(Result.Density, Options.DensitySampleCount); SetLength(Result.DensityValues, Options.DensitySampleCount);
  Factor := 1 / (Count * Result.Bandwidth * Sqrt(2 * Pi));
  for I := 0 to High(Result.Density) do
  begin
    Value := LowValue + Span * I / High(Result.Density); Density := 0; Result.DensityValues[I] := Value;
    for J := 0 to Count - 1 do begin Z := (Value - Result.Values[J]) / Result.Bandwidth; if Abs(Z) <= 6 then Density := Density + Exp(-0.5 * Z * Z) end;
    Density := Density * Factor; Result.Density[I] := Density; Result.MaximumDensity := Max(Result.MaximumDensity, Density);
  end;
end;

end.

{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.PerformanceChart;

interface

uses System.Classes, System.Math, System.Types, Vcl.Graphics, NimbusForms.Rendering.Sparkline, NimbusForms.Controls.Sparkline, NimbusForms.Charts.Sparkline.Types;

type
  TPerformanceChartMode = (pcmCpu, pcmMemory, pcmNetwork, pcmLatency, pcmDisk, pcmFrames, pcmErrors, pcmThroughput, pcmTemperature, pcmQueue);

  TThemedPerformanceChart = class(TThemedSparkline)
  private
    FMode: TPerformanceChartMode;
    FGridDensity: TSparklineGridDensity;
    FGridColor: TColor;
    FGridHorizontal, FGridVertical: Boolean;
    FCapacity: Integer;
    FSamples: TArray<Double>;
    FCount: Integer;
    FNext: Integer;
    procedure SetGridDensity(const AValue: TSparklineGridDensity);
    procedure SetGridColor(const AValue: TColor);
    procedure SetGridHorizontal(const AValue: Boolean);
    procedure SetGridVertical(const AValue: Boolean);
    procedure SetMode(const AValue: TPerformanceChartMode);
    procedure SetCapacity(const AValue: Integer);
    procedure RefreshSamples;
    procedure ConfigureMode;
  protected
    function CreateRenderContext(const ABounds: TRect): TSparklineRenderContext; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure PushSample(const AValue: Double);
    procedure LoadSamples(const AValues: array of Double);
    procedure ClearSamples;
    property SampleCount: Integer read FCount;
  published
    property Mode: TPerformanceChartMode read FMode write SetMode default pcmCpu;
    property Capacity: Integer read FCapacity write SetCapacity default 120;
    property GridDensity: TSparklineGridDensity read FGridDensity write SetGridDensity default sgdMedium;
    property GridColor: TColor read FGridColor write SetGridColor default clNone;
    property GridHorizontal: Boolean read FGridHorizontal write SetGridHorizontal default True;
    property GridVertical: Boolean read FGridVertical write SetGridVertical default True;
  end;

implementation

constructor TThemedPerformanceChart.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCapacity := 120;
  FGridDensity := sgdMedium;
  FGridColor := clNone;
  FGridHorizontal := True;
  FGridVertical := True;
  SetLength(FSamples, FCapacity);
  Width := 180;
  Height := 48;
  ConfigureMode;
end;

procedure TThemedPerformanceChart.ConfigureMode;
begin
  BeginUpdate;
  try
    PaintBackground := False;
    ShowBorder := False;
    ShowToolTip := True;
    ShowHoverLine := True;
    AnimateValueChanges := False;
    UltraFastRendering := True;
    PerformanceMode := spmFast;
    SparklinePadding := 2;
    ShowLastPoint := False;
    ShowAverageLine := False;
    ShowTargetLine := False;
    ShowRangeBand := False;
    ColorizeNegativeSegments := False;
    RangeMode := srmAuto;
    case FMode of
      pcmCpu: begin Style := srsArea; UseGradientArea := True; RangeMode := srmFixed; FixedRange := TSparklineValueRange.Create(0, 100) end;
      pcmMemory: begin Style := srsArea; UseGradientArea := True; RangeMode := srmFixed; FixedRange := TSparklineValueRange.Create(0, 100) end;
      pcmNetwork: begin Style := srsLine; ShowLastPoint := True; RangeMode := srmZeroBased end;
      pcmLatency: begin Style := srsLine; ShowAverageLine := True; RangeMode := srmZeroBased end;
      pcmDisk: begin Style := srsBars; RangeMode := srmZeroBased; BarGap := 1 end;
      pcmFrames: begin Style := srsLine; ShowTargetLine := True; TargetValue := 60; RangeMode := srmZeroBased end;
      pcmErrors: begin Style := srsBars; RangeMode := srmZeroBased; BarGap := 1 end;
      pcmThroughput: begin Style := srsArea; UseGradientArea := True; RangeMode := srmZeroBased end;
      pcmTemperature: begin Style := srsLine; ShowRangeBand := True; BandMinimum := 70; BandMaximum := 90; RangeMode := srmZeroBased end;
      pcmQueue: begin Style := srsBars; RangeMode := srmZeroBased; BarGap := 1 end;
    end;
  finally
    EndUpdate;
  end;
end;

procedure TThemedPerformanceChart.SetMode(const AValue: TPerformanceChartMode);
begin
  if FMode = AValue then Exit;
  FMode := AValue;
  ConfigureMode;
end;

procedure TThemedPerformanceChart.SetCapacity(const AValue: Integer);
var
  Previous: TArray<Double>;
  I, Keep: Integer;
begin
  if FCapacity = EnsureRange(AValue, 2, 4096) then Exit;
  Previous := Values;
  FCapacity := EnsureRange(AValue, 2, 4096);
  SetLength(FSamples, FCapacity);
  Keep := Min(Length(Previous), FCapacity);
  for I := 0 to Keep - 1 do FSamples[I] := Previous[Length(Previous) - Keep + I];
  FCount := Keep;
  FNext := Keep mod FCapacity;
  RefreshSamples;
end;

procedure TThemedPerformanceChart.RefreshSamples;
var
  Current: TArray<Double>;
  I, First: Integer;
begin
  SetLength(Current, FCount);
  First := (FNext - FCount + FCapacity) mod FCapacity;
  for I := 0 to FCount - 1 do Current[I] := FSamples[(First + I) mod FCapacity];
  SetValues(Current);
end;

procedure TThemedPerformanceChart.PushSample(const AValue: Double);
begin
  if IsNan(AValue) or IsInfinite(AValue) then Exit;
  FSamples[FNext] := AValue;
  FNext := (FNext + 1) mod FCapacity;
  if FCount < FCapacity then Inc(FCount);
  RefreshSamples;
end;

procedure TThemedPerformanceChart.LoadSamples(const AValues: array of Double);
var
  I: Integer;
begin
  BeginUpdate;
  try
    FCount := 0;
    FNext := 0;
    for I := 0 to High(AValues) do
      if not IsNan(AValues[I]) and not IsInfinite(AValues[I]) then
      begin
        FSamples[FNext] := AValues[I];
        FNext := (FNext + 1) mod FCapacity;
        if FCount < FCapacity then Inc(FCount);
      end;
    RefreshSamples;
  finally
    EndUpdate;
  end;
end;

procedure TThemedPerformanceChart.ClearSamples;
begin
  FCount := 0;
  FNext := 0;
  RefreshSamples;
end;

function TThemedPerformanceChart.CreateRenderContext(const ABounds: TRect): TSparklineRenderContext;
begin
  Result := inherited CreateRenderContext(ABounds);
  Result.GridDensity := FGridDensity;
  Result.GridColor := FGridColor;
  Result.GridHorizontal := FGridHorizontal;
  Result.GridVertical := FGridVertical;
end;

procedure TThemedPerformanceChart.SetGridDensity(const AValue: TSparklineGridDensity);
begin
  if FGridDensity = AValue then Exit;
  FGridDensity := AValue;
  Invalidate;
end;

procedure TThemedPerformanceChart.SetGridColor(const AValue: TColor);
begin
  if FGridColor = AValue then Exit;
  FGridColor := AValue;
  Invalidate;
end;

procedure TThemedPerformanceChart.SetGridHorizontal(const AValue: Boolean);
begin
  if FGridHorizontal = AValue then Exit;
  FGridHorizontal := AValue;
  Invalidate;
end;

procedure TThemedPerformanceChart.SetGridVertical(const AValue: Boolean);
begin
  if FGridVertical = AValue then Exit;
  FGridVertical := AValue;
  Invalidate;
end;

initialization
  RegisterClass(TThemedPerformanceChart);

end.

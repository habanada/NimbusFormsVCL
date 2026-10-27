{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.Violin;

interface

uses System.Types, NimbusForms.Rendering.Charts, NimbusForms.Charts.Types;

type
  TNimbusViolinChartRenderer = class(TNimbusChartRenderer)
  protected
    function Build(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>; override;
  public
    function CanRender(const AType: TNimbusChartType): Boolean; override;
    function Arrange(const C: TNimbusChartRenderContext): TNimbusChartLayout; override;
  end;

implementation

uses System.SysUtils, System.Math, System.Generics.Collections, Vcl.Graphics, NimbusForms.Rendering.Types,
  NimbusForms.Theming.Types, NimbusForms.Charts.Sparkline.Types, NimbusForms.Charts.Violin.Types;

type
  TViolinItem = record
    SeriesIndex, CategoryIndex: Integer;
    Statistics: TNimbusViolinStatistics;
    Shape: TNimbusViolinShapeMode;
    WidthScale: Double;
    Bounds: TRect;
    Polygon: TArray<TPointF>;
  end;

function Samples(Series: TNimbusChartSeries): TSparklineValues;
var I, Count: Integer; Point: TNimbusChartPoint;
begin
  SetLength(Result, Series.Points.Count); Count := 0;
  for I := 0 to Series.Points.Count - 1 do
  begin Point := Series.Points[I]; if Point.Visible and SparklineFinite(Point.YValue) then begin Result[Count] := Point.YValue; Inc(Count) end end;
  SetLength(Result, Count); TArray.Sort<Double>(Result);
end;

function ValueRange(Model: TNimbusChartModel): TNimbusChartRange;
var I: Integer; Values: TSparklineValues; LowValue, HighValue, Extension, Padding: Double;
begin
  LowValue := MaxDouble; HighValue := -MaxDouble;
  for I := 0 to Model.Series.Count - 1 do
  begin
    if not Model.Series[I].Visible then Continue; Values := Samples(Model.Series[I]); if Length(Values) = 0 then Continue;
    Extension := 0; if Model.ViolinOptions.TailMode = nvtExtendedBandwidth then Extension := 2.5 * NimbusViolinBandwidth(Values, Model.ViolinOptions);
    LowValue := Min(LowValue, Values[0] - Extension); HighValue := Max(HighValue, Values[High(Values)] + Extension);
  end;
  if LowValue = MaxDouble then Exit(TNimbusChartRange.Create(0, 1));
  if not Model.YAxis.AutoRange then Exit(Model.YAxis.GetEffectiveRange(TNimbusChartRange.Create(Model.YAxis.Minimum, Model.YAxis.Maximum)));
  if LowValue = HighValue then Padding := Max(1.0, Abs(LowValue) * 0.1) else Padding := (HighValue - LowValue) * 0.04;
  Result := Model.YAxis.GetEffectiveRange(TNimbusChartRange.Create(LowValue - Padding, HighValue + Padding));
end;

function TNimbusViolinChartRenderer.CanRender(const AType: TNimbusChartType): Boolean;
begin Result := AType = nctViolinPlot end;

function TNimbusViolinChartRenderer.Arrange(const C: TNimbusChartRenderContext): TNimbusChartLayout;
var Range: TNimbusChartRange;
begin
  Result := inherited Arrange(C); if C.Model = nil then Exit; Range := ValueRange(C.Model);
  if C.Model.ViolinOptions.Orientation = nvoHorizontal then
  begin if C.XView.IsValid then Range := C.XView; Result.XRange := Range; Result.YRange := TNimbusChartRange.Create(0, Max(1, C.Model.Series.Count)) end
  else begin if C.YView.IsValid then Range := C.YView; Result.YRange := Range; Result.XRange := TNimbusChartRange.Create(0, Max(1, C.Model.Series.Count)) end;
end;

function TNimbusViolinChartRenderer.Build(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>;
var M: TNimbusChartModel; O: TNimbusViolinPlotOptions; Range: TNimbusChartRange; R: TRect;
  Items: TArray<TViolinItem>; Item: TViolinItem; A: TNimbusChartPrimitive; Hit: TNimbusChartHit;
  Series: TNimbusChartSeries; Values, Ticks: TSparklineValues; Placed, Polygon: TArray<TPointF>;
  I, J, K, Count, Categories, MaximumCount, RenderStep, SeedIndex: Integer;
  DPI, GlobalDensity, Slot, Center, HalfWidth, Position, Ratio, WidthScale, LowCross, HighCross, InnerWidth: Double;
  Q1, Q3, Median, Mean, Lower, Upper, Offset, UsableWidth, PointRadius, Distance, Candidate, StepSize, DX, DY: Double;
  MinX, MaxX, MinY, MaxY, MaximumOffset: Double; Seed: UInt64; Collision, Vertical, Selected, Clip: Boolean;
  Fore, Back, Muted, Border, SeriesColor, FillColor, OutlineColor, BoxColor, MedianColor, MeanColor, PointColor, CIColor, SDColor: TThemeColor;
  LabelText: string;
  function Map(const Value: Double): Double;
  var Normalized: Double;
  begin
    Normalized := M.YAxis.NormalizeWithinRange(Value, Range); if not SparklineFinite(Normalized) then Normalized := 0;
    if Vertical then Result := R.Bottom - Normalized * R.Height else Result := R.Left + Normalized * R.Width;
  end;
  function ResolveColor(const Color: TColor; const Fallback: TThemeColor): TThemeColor;
  begin
    Result := Fallback;
    if Color <> clNone then
    begin Result := ColorToThemeColor(Color); if C.ColorInfluence > 0 then Result := NimbusBlendColor(Result, Fallback, Round(EnsureRange(C.ColorInfluence, 0, 100) * 255 / 100)) end;
    if not C.Enabled then Result := NimbusBlendColor(Result, Back, 160);
  end;
  procedure Add;
  var N: Integer;
  begin N := Length(Result); SetLength(Result, N + 1); Result[N] := A end;
  procedure Primitive(const Kind: TNimbusChartPrimitiveKind; const Color: TThemeColor);
  begin
    A := Default(TNimbusChartPrimitive); A.Kind := Kind; A.Color := Color; A.Width := DPI;
    A.Hit := TNimbusChartHit.None; A.UseClip := Clip; A.ClipBounds := R; A.UseCornerRadius := True;
  end;
  function Bounds(const X1, Y1, X2, Y2: Double): TRect;
  begin Result := Rect(Floor(Min(X1, X2)), Floor(Min(Y1, Y2)), Ceil(Max(X1, X2)), Ceil(Max(Y1, Y2))) end;
  procedure Line(const X1, Y1, X2, Y2: Double; const Color: TThemeColor; const Width: Double);
  begin Primitive(ncpLine, Color); A.Points := [TPointF.Create(X1, Y1), TPointF.Create(X2, Y2)]; A.Width := Width; Add end;
  procedure Text(const Value: string; const B: TRect; const RightAligned: Boolean = False);
  begin
    if B.IsEmpty or (Value = '') then Exit; Primitive(ncpText, Muted); A.Bounds := B; A.Text := Value;
    A.TextFlags := [ntfCenter, ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix];
    if RightAligned then begin Exclude(A.TextFlags, ntfCenter); Include(A.TextFlags, ntfRight) end; Add;
  end;
  function CrossPoint(const Cross, ValuePosition: Double): TPointF;
  begin if Vertical then Result := TPointF.Create(Cross, ValuePosition) else Result := TPointF.Create(ValuePosition, Cross) end;
  procedure CrossLine(const ValuePosition, Width: Double; const Color: TThemeColor; const StrokeWidth: Double);
  begin
    if Vertical then Line(Center - Width / 2, ValuePosition, Center + Width / 2, ValuePosition, Color, StrokeWidth)
    else Line(ValuePosition, Center - Width / 2, ValuePosition, Center + Width / 2, Color, StrokeWidth);
  end;
  procedure Interval(const First, Second, Width: Double; const Color: TThemeColor);
  begin
    if Vertical then Line(Center, First, Center, Second, Color, 2 * DPI) else Line(First, Center, Second, Center, Color, 2 * DPI);
    CrossLine(First, Width * 0.7, Color, 1.5 * DPI); CrossLine(Second, Width * 0.7, Color, 1.5 * DPI);
  end;
  procedure Band(const First, Second, Width: Double; const Color: TThemeColor; const Outline: Boolean);
  begin
    Primitive(ncpRect, Color); if Outline then begin A.Kind := ncpOutlineRect; A.Width := 1.3 * DPI end;
    if Vertical then A.Bounds := Bounds(Center - Width / 2, First, Center + Width / 2, Second)
    else A.Bounds := Bounds(First, Center - Width / 2, Second, Center + Width / 2); Add;
  end;
  procedure Dot(const Cross, ValuePosition, Radius: Double; const Color: TThemeColor; const Outline: Boolean);
  var Point: TPointF;
  begin
    Point := CrossPoint(Cross, ValuePosition); Primitive(ncpEllipse, Color); if Outline then begin A.Kind := ncpOutlineEllipse; A.Width := 1.2 * DPI end;
    A.Bounds := Bounds(Point.X - Radius, Point.Y - Radius, Point.X + Radius, Point.Y + Radius); Add;
  end;
  function Tooltip(const Statistics: TNimbusViolinStatistics): string;
  var StatsRange: TNimbusChartRange;
    function Number(const V: Double): string;
    begin Result := M.YAxis.FormatValue(V, StatsRange) end;
  begin
    StatsRange := TNimbusChartRange.Create(Statistics.Minimum, Statistics.Maximum); Result := Series.Name; if Result = '' then Result := 'Distribution';
    Result := Result + sLineBreak + 'Samples: ' + IntToStr(Length(Statistics.Values)) + sLineBreak + 'Minimum: ' + Number(Statistics.Minimum)
      + sLineBreak + 'Q1: ' + Number(Statistics.Q1) + sLineBreak + 'Median: ' + Number(Statistics.Median) + sLineBreak + 'Mean: ' + Number(Statistics.Mean)
      + sLineBreak + 'Q3: ' + Number(Statistics.Q3) + sLineBreak + 'Maximum: ' + Number(Statistics.Maximum) + sLineBreak + 'Std. deviation: ' + Number(Statistics.StandardDeviation)
      + sLineBreak + IntToStr(Round(O.ConfidenceLevel * 100)) + '% mean CI: ' + Number(Statistics.ConfidenceMinimum) + ' - ' + Number(Statistics.ConfidenceMaximum)
      + sLineBreak + 'Bandwidth: ' + FormatFloat('0.###', Statistics.Bandwidth);
  end;
  function Beeswarm: Double;
  var P: TPointF; Ring, Limit, CandidateIndex: Integer;
  begin
    Result := 0; if UsableWidth <= 0 then Exit; StepSize := Max(1.5 * DPI, Distance * 0.75); Limit := Max(1, Ceil(UsableWidth / StepSize));
    for Ring := 0 to Limit do
      for CandidateIndex := 0 to 1 do
      begin
        Candidate := Ring * StepSize; if CandidateIndex = 1 then Candidate := -Candidate;
        if (Ring = 0) and (CandidateIndex = 1) then Continue; if Abs(Candidate) > UsableWidth then Continue; Collision := False;
        for P in Placed do begin DX := P.X - Candidate; DY := P.Y - Position; if Sqr(DX) + Sqr(DY) < Sqr(Distance) then begin Collision := True; Break end end;
        if not Collision then Exit(Candidate);
      end;
  end;
begin
  Result := inherited Build(C, L); M := C.Model; if (M = nil) or (C.Font = nil) or L.PlotArea.IsEmpty then Exit;
  O := M.ViolinOptions; R := L.PlotArea; Vertical := O.Orientation = nvoVertical; DPI := Max(1, C.PPI) / 96;
  if Vertical then Range := L.YRange else Range := L.XRange;
  Fore := ChartForeColor(C); Back := ChartBackColor(C); Border := ChartBorderColor(C); Muted := NimbusBlendColor(Fore, Back, 145);
  if C.ChartPalette <> nil then Muted := ColorToThemeColor(C.ChartPalette.MutedForeColor);
  GlobalDensity := 0; MaximumCount := 1; Items := nil;
  for I := 0 to M.Series.Count - 1 do
  begin
    if not M.Series[I].Visible then Continue; Values := Samples(M.Series[I]); if Length(Values) = 0 then Continue;
    Item := Default(TViolinItem); Item.SeriesIndex := I; Item.Statistics := NimbusViolinStatistics(Values, O, Range.Minimum, Range.Maximum);
    Count := Length(Items); Item.CategoryIndex := Count; Item.Shape := O.ShapeMode;
    if O.LayoutMode = nvlSplitPairs then begin Item.CategoryIndex := Count div 2; if Count mod 2 = 0 then Item.Shape := nvsLeftHalf else Item.Shape := nvsRightHalf end;
    SetLength(Items, Count + 1); Items[Count] := Item;
    GlobalDensity := Max(GlobalDensity, Item.Statistics.MaximumDensity); MaximumCount := Max(MaximumCount, Length(Item.Statistics.Values));
  end;
  Categories := Length(Items); if O.LayoutMode = nvlSplitPairs then Categories := (Categories + 1) div 2;
  if Vertical then Slot := R.Width / Max(1, Categories) else Slot := R.Height / Max(1, Categories);
  Clip := False; Ticks := M.YAxis.CreateTicks(Range);
  for Position in Ticks do
  begin
    Ratio := Map(Position);
    if M.Options.ShowGrid and M.YAxis.ShowGridLines then
      if Vertical then Line(R.Left, Ratio, R.Right, Ratio, NimbusColorWithAlpha(Border, 100), DPI) else Line(Ratio, R.Top, Ratio, R.Bottom, NimbusColorWithAlpha(Border, 100), DPI);
    if M.Options.ShowAxes and M.YAxis.ShowLabels then
      if Vertical then Text(M.YAxis.FormatValue(Position, Range), Bounds(L.YAxisBounds.Left, Ratio - 9 * DPI, L.YAxisBounds.Right - 5 * DPI, Ratio + 9 * DPI), True)
      else Text(M.YAxis.FormatValue(Position, Range), Bounds(Ratio - 42 * DPI, L.XAxisBounds.Top + 2 * DPI, Ratio + 42 * DPI, L.XAxisBounds.Top + 22 * DPI));
  end;
  if O.ShowZeroReferenceLine and (Range.Minimum <= 0) and (Range.Maximum >= 0) then
    if Vertical then Line(R.Left, Map(0), R.Right, Map(0), Muted, 1.4 * DPI) else Line(Map(0), R.Top, Map(0), R.Bottom, Muted, 1.4 * DPI);
  if M.Options.ShowAxes then
    for I := 0 to Categories - 1 do
    begin
      LabelText := ''; Count := 0;
      for Item in Items do
        if Item.CategoryIndex = I then
        begin
          Series := M.Series[Item.SeriesIndex]; if LabelText <> '' then LabelText := LabelText + ' / ';
          if Series.Name <> '' then LabelText := LabelText + Series.Name else LabelText := LabelText + 'Series ' + IntToStr(Item.SeriesIndex + 1);
          Inc(Count, Length(Item.Statistics.Values));
        end;
      if O.ShowSampleCount then LabelText := LabelText + '  n=' + IntToStr(Count);
      if Vertical then Text(LabelText, Bounds(R.Left + I * Slot, L.XAxisBounds.Top + 2 * DPI, R.Left + (I + 1) * Slot, L.XAxisBounds.Top + 26 * DPI))
      else Text(LabelText, Bounds(L.YAxisBounds.Left, R.Top + I * Slot, L.YAxisBounds.Right - 5 * DPI, R.Top + (I + 1) * Slot), True);
    end;
  Clip := True;
  for I := 0 to High(Items) do
  begin
    Item := Items[I]; Series := M.Series[Item.SeriesIndex]; HalfWidth := Slot * O.MaximumWidthRatio / 2;
    if Vertical then Center := R.Left + Slot * (Item.CategoryIndex + 0.5) else Center := R.Top + Slot * (Item.CategoryIndex + 0.5);
    WidthScale := 1;
    if (O.DensityNormalization = nvnGlobal) and (GlobalDensity > 0) then WidthScale := Item.Statistics.MaximumDensity / GlobalDensity
    else if O.DensityNormalization = nvnSampleCount then WidthScale := Sqrt(Length(Item.Statistics.Values) / MaximumCount);
    Count := Length(Item.Statistics.Density); SetLength(Polygon, Count * 2); MinX := MaxDouble; MinY := MaxDouble; MaxX := -MaxDouble; MaxY := -MaxDouble;
    for J := 0 to Count - 1 do
    begin
      Ratio := 0; if Item.Statistics.MaximumDensity > 0 then Ratio := Item.Statistics.Density[J] / Item.Statistics.MaximumDensity;
      Position := Map(Item.Statistics.DensityValues[J]); LowCross := Center - HalfWidth * Ratio * WidthScale; HighCross := Center + HalfWidth * Ratio * WidthScale;
      if Item.Shape = nvsRightHalf then LowCross := Center; if Item.Shape = nvsLeftHalf then HighCross := Center;
      Polygon[J] := CrossPoint(LowCross, Position); Polygon[High(Polygon) - J] := CrossPoint(HighCross, Position);
      MinX := Min(MinX, Min(Polygon[J].X, Polygon[High(Polygon) - J].X)); MaxX := Max(MaxX, Max(Polygon[J].X, Polygon[High(Polygon) - J].X));
      MinY := Min(MinY, Min(Polygon[J].Y, Polygon[High(Polygon) - J].Y)); MaxY := Max(MaxY, Max(Polygon[J].Y, Polygon[High(Polygon) - J].Y));
    end;
    Item.Bounds := Bounds(MinX, MinY, MaxX, MaxY);
    SeriesColor := ChartAccentColor(C); if C.ChartPalette <> nil then SeriesColor := ColorToThemeColor(C.ChartPalette.GetSeriesColor(Item.SeriesIndex)); SeriesColor := ResolveColor(Series.Color, SeriesColor);
    Selected := (C.Selected.Area = nchaSeries) and (C.Selected.SeriesIndex = Item.SeriesIndex);
    FillColor := NimbusColorWithAlpha(SeriesColor, Trunc(255 * O.FillOpacity)); OutlineColor := SeriesColor; if Selected then OutlineColor := Fore;
    Primitive(ncpPolygon, FillColor); A.Points := Copy(Polygon); Add;
    Primitive(ncpLine, OutlineColor); A.Points := Copy(Polygon); SetLength(A.Points, Length(Polygon) + 1); A.Points[High(A.Points)] := Polygon[0];
    A.Width := O.OutlineWidth * DPI; if Selected then A.Width := A.Width * 1.6; Add;
    if Vertical then begin Center := Item.Bounds.CenterPoint.X; MaximumOffset := Item.Bounds.Width end else begin Center := Item.Bounds.CenterPoint.Y; MaximumOffset := Item.Bounds.Height end;
    InnerWidth := Max(8 * DPI, Min(18 * DPI, MaximumOffset * 0.22));
    BoxColor := ResolveColor(O.BoxColor, Fore); MedianColor := ResolveColor(O.MedianColor, Fore); MeanColor := ResolveColor(O.MeanColor, SeriesColor);
    CIColor := ResolveColor(O.ConfidenceIntervalColor, NimbusColorWithAlpha(SeriesColor, 170)); SDColor := ResolveColor(O.StandardDeviationColor, NimbusColorWithAlpha(SeriesColor, 120));
    Q1 := Map(Item.Statistics.Q1); Q3 := Map(Item.Statistics.Q3); Median := Map(Item.Statistics.Median); Mean := Map(Item.Statistics.Mean);
    Lower := Map(Item.Statistics.LowerWhisker); Upper := Map(Item.Statistics.UpperWhisker);
    if O.ShowStandardDeviation then Band(Map(Item.Statistics.Mean - Item.Statistics.StandardDeviation), Map(Item.Statistics.Mean + Item.Statistics.StandardDeviation), InnerWidth * 1.7, SDColor, False);
    if O.ShowMeanConfidenceInterval then Interval(Map(Item.Statistics.ConfidenceMinimum), Map(Item.Statistics.ConfidenceMaximum), InnerWidth, CIColor);
    if O.ShowWhiskers then Interval(Lower, Upper, InnerWidth, BoxColor);
    if O.ShowInnerBox then begin Band(Q1, Q3, InnerWidth, NimbusColorWithAlpha(Back, 190), False); Band(Q1, Q3, InnerWidth, BoxColor, True) end
    else if O.ShowQuartiles then begin CrossLine(Q1, InnerWidth, BoxColor, 1.2 * DPI); CrossLine(Q3, InnerWidth, BoxColor, 1.2 * DPI) end;
    if O.ShowMedian then CrossLine(Median, InnerWidth * 1.24, MedianColor, 2.2 * DPI);
    if O.ShowMean then begin Dot(Center, Mean, 3.6 * DPI, MeanColor, False); Dot(Center, Mean, 3.6 * DPI, Back, True) end;
    if O.ShowOutliers then
      for Position in Item.Statistics.Values do
        if (Position < Item.Statistics.LowerWhisker) or (Position > Item.Statistics.UpperWhisker) then Dot(Center, Map(Position), 2.4 * DPI, SeriesColor, True);
    if O.PointDisplayMode <> nvpNone then
    begin
      RenderStep := 1; Count := Length(Item.Statistics.Values); if (O.MaximumRenderedPoints > 0) and (Count > O.MaximumRenderedPoints) then RenderStep := Ceil(Count / O.MaximumRenderedPoints);
      PointColor := NimbusColorWithAlpha(ResolveColor(O.PointColor, SeriesColor), Trunc(255 * O.PointOpacity));
      PointRadius := O.PointSize * DPI / 2; Distance := PointRadius * 2.2; UsableWidth := MaximumOffset * 0.5 * O.JitterRatio;
      Seed := UInt64(397 xor (Item.SeriesIndex * 7919) xor Count); Placed := nil; SeedIndex := 0;
      while SeedIndex < Count do
      begin
        Position := Map(Item.Statistics.Values[SeedIndex]);
        if O.PointDisplayMode = nvpBeeswarm then Offset := Beeswarm
        else begin Seed := (Seed * 1664525 + 1013904223) and $FFFFFFFF; Offset := (Seed / 4294967296 * 2 - 1) * UsableWidth end;
        Dot(Center + Offset, Position, PointRadius, PointColor, False); K := Length(Placed); SetLength(Placed, K + 1); Placed[K] := TPointF.Create(Offset, Position); Inc(SeedIndex, RenderStep);
      end;
    end;
    if O.ShowDensityScale and (Item.Statistics.MaximumDensity > 0) then
      if Vertical then Text('density ' + FormatFloat('0.###', Item.Statistics.MaximumDensity), Bounds(Item.Bounds.Left, Item.Bounds.Top - 18 * DPI, Item.Bounds.Right, Item.Bounds.Top - 2 * DPI))
      else Text('density ' + FormatFloat('0.###', Item.Statistics.MaximumDensity), Bounds(Item.Bounds.Right + 4 * DPI, Item.Bounds.Top, Item.Bounds.Right + 94 * DPI, Item.Bounds.Bottom));
    Hit := TNimbusChartHit.None; Hit.Area := nchaSeries; Hit.SeriesIndex := Item.SeriesIndex; Hit.XValue := Item.CategoryIndex;
    Hit.YValue := Item.Statistics.Median; Hit.Text := Tooltip(Item.Statistics);
    Primitive(ncpHitBounds, 0); A.Bounds := Item.Bounds; A.Hit := Hit; Add;
  end;
end;

end.

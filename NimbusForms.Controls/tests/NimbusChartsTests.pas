{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

program NimbusChartsTests;

{$APPTYPE CONSOLE}

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Types, System.UITypes, System.Math, NimbusMiniChartChecks, NimbusChartFunctionChecks, NimbusFinancialChecks,
  Vcl.Forms, Vcl.Graphics, Vcl.Controls, NimbusForms.Rendering.Maps, NimbusForms.Charts.Maps.Data,
  NimbusForms.Controls.Sparkline, NimbusForms.Rendering.Sparkline,
  NimbusForms.Charts.Sparkline.Types, NimbusForms.Theming.PresetFactory, NimbusForms.Theming.Palette,
  NimbusForms.Controls.Chart, NimbusForms.Charts.Types, NimbusForms.Rendering.Charts, NimbusForms.Rendering.BusinessCharts,
  NimbusForms.Rendering.Types, NimbusForms.Theming.Types, NimbusForms.Charts.Violin.Types, NimbusForms.Rendering.Violin, NimbusForms.Charts.Ridgeline.Types, NimbusForms.Rendering.Ridgeline, NimbusForms.Controls.Ridgeline, NimbusForms.Charts.StreamGraph.Types, NimbusForms.Rendering.StreamGraph, NimbusForms.Controls.StreamGraph, NimbusForms.Charts.Treemap.Types, NimbusForms.Rendering.Treemap, NimbusForms.Controls.Treemap, NimbusForms.Charts.Sunburst.Types, NimbusForms.Rendering.Sunburst, NimbusForms.Controls.Sunburst;

type
  TMapRendererProbe = class(TNimbusMapChartRenderer)
  public
    function Primitives(const C: TNimbusChartRenderContext): TArray<TNimbusChartPrimitive>;
  end;

  TKpiRendererProbe = class(TNimbusChartRenderer)
  public
    function Primitives(const C: TNimbusChartRenderContext): TArray<TNimbusChartPrimitive>;
  end;

  TRidgelineRendererProbe = class(TNimbusRidgelineChartRenderer)
  public
    function Primitives(const C: TNimbusChartRenderContext): TArray<TNimbusChartPrimitive>;
  end;

  TRidgelineKeyboardProbe = class(TThemedRidgelineChart)
  public
    procedure Press(const Code: Word);
  end;

  TViolinRendererProbe = class(TNimbusViolinChartRenderer)
  public
    function Primitives(const C: TNimbusChartRenderContext): TArray<TNimbusChartPrimitive>;
  end;

  TChartKeyboardProbe = class(TThemedChart)
  public
    procedure Press(const Code: Word);
  end;

  TBusinessRendererProbe = class(TNimbusBusinessChartRenderer)
  public
    function Primitives(const C: TNimbusChartRenderContext): TArray<TNimbusChartPrimitive>;
  end;

function TRidgelineRendererProbe.Primitives(const C: TNimbusChartRenderContext): TArray<TNimbusChartPrimitive>;
begin Result := Build(C, Arrange(C)) end;

procedure TRidgelineKeyboardProbe.Press(const Code: Word);
var Key: Word;
begin Key := Code; KeyDown(Key, []) end;

function TViolinRendererProbe.Primitives(const C: TNimbusChartRenderContext): TArray<TNimbusChartPrimitive>;
begin Result := Build(C, Arrange(C)) end;

procedure TChartKeyboardProbe.Press(const Code: Word);
var Key: Word;
begin Key := Code; KeyDown(Key, []) end;

function TMapRendererProbe.Primitives(const C: TNimbusChartRenderContext): TArray<TNimbusChartPrimitive>;
begin Result := Build(C, Arrange(C)) end;

function TKpiRendererProbe.Primitives(const C: TNimbusChartRenderContext): TArray<TNimbusChartPrimitive>;
begin Result := Build(C, Arrange(C)) end;

function TBusinessRendererProbe.Primitives(const C: TNimbusChartRenderContext): TArray<TNimbusChartPrimitive>;
begin Result := Build(C, Arrange(C)) end;

procedure Check(const Condition: Boolean; const Message: string);
begin
  if not Condition then raise Exception.Create(Message);
end;

procedure Run;
var
  S: TThemedSparkline; R: TSparklineRenderer; O: TSparklineOptions;
  C: TSparklineRenderContext; G: TSparklineGeometry; B: TBitmap;
  F: TForm; Stream: TMemoryStream; Loaded: TThemedSparkline;
  I, J: Integer; V: TSparklineValues; P: TThemePalette;
begin
  S := TThemedSparkline.Create(nil);
  try
    Check(not S.HandleAllocated, 'Constructor created HWND');
    S.SetValues([NaN, -5, 0, 10, Infinity]);
    Check(not S.HandleAllocated, 'Assigning data created HWND');
    S.Style := srsArea; S.ShowArea := True; S.ShowSelection := True;
    S.Markers.Add.PointIndex := 3;
    S.ReferenceLines.Add.Value := 3;
    S.ThresholdBands.Add.Maximum := 4;
    R := TSparklineRenderer.Create; O := TSparklineOptions.Create;
    try
      C := Default(TSparklineRenderContext);
      C.Options := O; C.Bounds := Rect(0, 0, 200, 80); C.Font := S.Font;
      C.PPI := 96; C.Enabled := True; C.Values := S.Values;
      G := R.BuildGeometry(C);
      Check(Length(G.Points) = 3, 'Invalid values were not filtered');
      Check(G.SourceIndices[0] = 1, 'Source index lost');
      Check(G.HitTest(Point(Round(G.Points[2].X), Round(G.Points[2].Y)), 8) = 3, 'Hit test source index mismatch');
      C.Values := [1, NaN, 2, NaN]; G := R.BuildGeometry(C); Check(G.SourceIndices[0] = 0, 'Initial cache mapping');
      C.Values := [NaN, 1, NaN, 2]; G := R.BuildGeometry(C); Check(G.SourceIndices[0] = 1, 'Cache reused incorrect source indices');
      C.Values := S.Values;
      O.RangeMode := srmSymmetric; G := R.BuildGeometry(C);
      Check((G.Range.Minimum = -10) and (G.Range.Maximum = 10), 'Symmetric range');
      O.RangeMode := srmFixed; O.FixedRange := TSparklineValueRange.Create(0, 0);
      G := R.BuildGeometry(C); Check(G.Range.Span > 0, 'Constant fixed range');
      SetLength(V, 10000);
      for I := 0 to High(V) do V[I] := Sin(I / 20);
      V[3333] := 100; C.Values := V; O.RangeMode := srmAuto;
      G := R.BuildGeometry(C);
      Check(Length(G.Points) <= 800, 'Downsampling exceeded bound');
      Check(G.Range.Maximum = 100, 'Downsampling lost range extreme');
      Check(G.HitTest(Point(-1, -1), 8) = -1, 'Outside hit test');
      O.Style := srsBars; O.BarGap := 2;
      for J := 0 to 3 do
      begin
        C.PPI := 96 + J * 32; C.Bounds := Rect(0, 0, 120 * C.PPI div 96, 50 * C.PPI div 96);
        G := R.BuildGeometry(C); Check(Length(G.Bars) < 100, 'Dense bars were not reduced');
        Check(G.SampleValues[G.MaximumIndex] = 100, 'Bar sampling lost peak');
        for I := 1 to High(G.Bars) do
          Check(G.Bars[I].Left - G.Bars[I - 1].Right >= NimbusScaleValue(2, C.PPI) - 0.01, 'Dense bars lost visible gap');
      end;
      C.PPI := 96; C.Bounds := Rect(0, 0, 200, 80); C.Values := [1, 2, 3, 4]; O.BarGap := 0;
      G := R.BuildGeometry(C); V := [G.Bars[0].Width]; O.BarGap := 4; G := R.BuildGeometry(C);
      Check(G.Bars[0].Width < V[0], 'Bar gap change reused stale geometry');

      for I := 0 to 4 do
      begin
        S.Style := TSparklineRenderStyle(I); S.UseGradientArea := True;
        S.SplitAreaByZero := True; S.ShowMinMaxPoints := True;
        B := S.RenderToBitmap(TSize.Create(200, 80));
        try Check((B.Width = 200) and (B.Height = 80), 'Bitmap dimensions') finally B.Free end;
      end;
    finally O.Free; R.Free end;
    F := TForm.CreateNew(nil);
    try
      S.Parent := F; S.Parent := nil;
      Stream := TMemoryStream.Create;
      try
        S.Name := 'SparklineTest'; S.Style := srsWinLoss; S.RangeMode := srmFixed; S.FixedRange := TSparklineValueRange.Create(-20, 20);
        S.ThemeMode := stmAdaptiveCustom; S.ThemeInfluence := 17; S.BarGap := 4;
        Stream.WriteComponent(S); Stream.Position := 0;
        Loaded := TThemedSparkline(Stream.ReadComponent(nil));
        try
          Check(Loaded.Style = srsWinLoss, 'Streaming style');
          Check((Loaded.ThemeMode = stmAdaptiveCustom) and (Loaded.ThemeInfluence = 17) and (Loaded.BarGap = 4), 'Sparkline custom color and gap streaming');
          Check((Loaded.FixedRange.Minimum = -20) and (Loaded.FixedRange.Maximum = 20), 'Streaming fixed range');
          Check(Loaded.Markers.Count = 1, 'Streaming marker collection');
          Check(Loaded.ReferenceLines.Count = 1, 'Streaming reference collection');
        finally Loaded.Free end;
      finally Stream.Free end;
    finally F.Free end;
    P := TThemePresetFactory.Dark;
    try S.ApplyTheme(P) finally P.Free end;
    B := S.RenderToBitmap(TSize.Create(1, 1)); B.Free;
    S.SetValues([]);
    B := S.RenderToBitmap(TSize.Create(96, 28)); B.Free;
  finally S.Free end;
end;

procedure RunChartTests;
const Types: array[0..30] of TNimbusChartType = (nctLine, nctArea, nctLineScatter, nctColumn, nctBar, nctPie, nctDonut, nctScatter, nctBubble, nctHeatmap, nctKpi, nctGauge, nctRadialBar, nctBullet, nctBoxPlot, nctBusinessRankedBar, nctBusinessTimelineRange, nctBusinessCalendarHeatmap, nctBusinessBullet, nctBusinessDivergingBar, nctBusinessFunnel, nctBusinessLollipopBar, nctBusinessRadialGoal, nctBusinessPortfolioArc, nctBusinessWaterfall, nctBusinessModernWaterfall, nctBusinessKpiTiles, nctBusinessPareto, nctBusinessStackedHorizontalBar, nctViolinPlot, nctRidgeline);
  PPIs: array[0..3] of Integer = (96, 120, 144, 192);
var Chart, Loaded: TThemedChart; Series: TNimbusChartSeries; PointData: TNimbusChartPoint;
  I, J, K, DPIIndex: Integer; Bitmap: TBitmap; Axis: TNimbusChartAxis; Scale: TNimbusChartAxisScale;
  Range: TNimbusChartRange; V, Ratio: Double; Svg: string; Stream: TMemoryStream;
  C: TNimbusChartRenderContext; Renderer: INimbusChartRenderer; L: TNimbusChartLayout; Hit: TNimbusChartHit; Theme: TThemePalette;
begin
  Axis := TNimbusChartAxis.Create;
  try
    for Scale := Low(TNimbusChartAxisScale) to High(TNimbusChartAxisScale) do
    begin
      Axis.Scale := Scale; Range := TNimbusChartRange.Create(1, 100); V := 25;
      if Scale in [ncasPower, ncasSymmetricLogarithmic] then begin Range := TNimbusChartRange.Create(-100, 100); V := -25 end;
      Ratio := Axis.NormalizeWithinRange(V, Range);
      Check(Abs(Axis.DenormalizeWithinRange(Ratio, Range) - V) < 1E-8, 'Axis transform inverse mismatch');
    end;
    Axis.Scale := ncasLogarithmic10; Axis.InvalidLogValueBehavior := ncilSkip;
    Check(IsNan(Axis.NormalizeValue(0, TNimbusChartRange.Create(1, 100))), 'Log axis did not skip zero');
  finally Axis.Free end;
  Chart := TThemedChart.Create(nil);
  try
    Check(not Chart.HandleAllocated, 'Chart constructor created HWND');
    Chart.BeginUpdate;
    try
      Chart.Title := 'Revenue <actual> & forecast'; Chart.ShowAnimation := False;
      for I := 0 to 2 do
      begin
        Series := Chart.Model.AddSeries('Series ' + IntToStr(I + 1));
        for J := 0 to 11 do begin PointData := Series.Points.Add(J, 5 + I * 4 + Sin(J * 0.6) * 3); PointData.SizeValue := J + 2 end;
      end;
      Chart.Model.Annotations.Add.Text := 'Annotation';
      Chart.Model.Annotations[0].XValue := 5; Chart.Model.Annotations[0].YValue := 10;
      Chart.Model.ReferenceLines.Add.Value := 10;
      Chart.Model.ReferenceRanges.Add.Maximum := 4;
    finally Chart.EndUpdate end;
    Check(not Chart.HandleAllocated, 'Chart data assignment created HWND');
    for I := Low(Types) to High(Types) do
    begin
      Chart.ChartType := Types[I]; Check(Chart.RendererFactory.CanRender(Types[I]), 'Renderer missing');
      Bitmap := Chart.RenderToBitmap(640, 360);
      try Check((Bitmap.Width = 640) and (Bitmap.Height = 360), 'Chart bitmap dimensions') finally Bitmap.Free end;
      Svg := Chart.ExportSvg(640, 360);
      Check(Pos('<svg ', Svg) = 1, 'SVG header missing');
      Check(Pos('Revenue &lt;actual&gt; &amp; forecast', Svg) > 0, 'SVG text was not XML escaped');
    end;
    Chart.ChartType := nctColumn;
    C := Default(TNimbusChartRenderContext); C.Model := Chart.Model; C.Font := Chart.Font; C.Enabled := True; C.AnimationProgress := 1;
    C.Hovered := TNimbusChartHit.None; C.Selected := TNimbusChartHit.None; C.XView := TNimbusChartRange.Empty; C.YView := TNimbusChartRange.Empty;
    Renderer := Chart.RendererFactory.GetRenderer(nctColumn);
    for DPIIndex := Low(PPIs) to High(PPIs) do
    begin
      C.PPI := PPIs[DPIIndex]; C.Bounds := Rect(0, 0, 640 * C.PPI div 96, 360 * C.PPI div 96);
      L := Renderer.Arrange(C); K := 0;
      for J := 0 to Max(0, L.PlotArea.Height div 8 - 1) do
      begin
        for I := 0 to Max(0, L.PlotArea.Width div 8 - 1) do
        begin
          Hit := Renderer.HitTest(C, TPointF.Create(L.PlotArea.Left + I * 8, L.PlotArea.Top + J * 8));
          if Hit.Area = nchaPoint then begin Inc(K); Break end;
        end;
        if K > 0 then Break;
      end;
      Check(K > 0, 'Column hit test missed rendered geometry at DPI');
    end;
    Stream := TMemoryStream.Create;
    try
      Chart.Name := 'ChartTest'; Chart.UseThemePaletteForChart := False; Chart.Model.Palette.Colors := [clRed, clBlue];
      Chart.Model.Series[0].Points[0].ShowValue := True; Chart.Model.Series[0].BoxPlot.Enabled := True; Chart.Model.Series[0].BoxPlot.Outliers := [100, 120];
      Chart.ColorMode := nccAdaptiveCustom; Chart.ThemeInfluence := 17;
      Stream.WriteComponent(Chart); Stream.Position := 0;
      Loaded := TThemedChart(Stream.ReadComponent(nil));
      try
        Check(Loaded.Model.Series.Count = 3, 'Chart series streaming');
        Check((Loaded.ColorMode = nccAdaptiveCustom) and (Loaded.ThemeInfluence = 17), 'Adaptive chart color streaming');
        Check(Loaded.Model.Series[0].Points.Count = 12, 'Chart point streaming');
        Check(Loaded.Model.Series[0].Points[0].ShowValue, 'Point value visibility streaming');
        Check(Loaded.Model.Annotations.Count = 1, 'Chart annotation streaming');
        Check(Length(Loaded.Model.Palette.Colors) = 2, 'Palette colors streaming');
        Check(Length(Loaded.Model.Series[0].BoxPlot.Outliers) = 2, 'Box plot outliers streaming');
      finally Loaded.Free end;
    finally Stream.Free end;
    for I := 0 to 1 do
    begin
      if I = 0 then Theme := TThemePresetFactory.Light else Theme := TThemePresetFactory.Dark;
      try Chart.UseThemePaletteForChart := True; Chart.ApplyTheme(Theme); Bitmap := Chart.RenderToBitmap(300, 180); Bitmap.Free finally Theme.Free end;
    end;
    Bitmap := Chart.RenderToBitmap(1, 1); Bitmap.Free;
  finally Chart.Free end;
end;

procedure RunBusinessTests;
const Types: array[0..6] of TNimbusChartType = (nctBusinessRankedBar, nctBusinessTimelineRange, nctBusinessCalendarHeatmap, nctBusinessBullet, nctBusinessDivergingBar, nctBusinessFunnel, nctBusinessLollipopBar);
  PPIs: array[0..3] of Integer = (96, 120, 144, 192);
var
  Probe: TBusinessRendererProbe; Renderer: INimbusChartRenderer; Chart: TThemedChart;
  C: TNimbusChartRenderContext; Items: TArray<TNimbusChartPrimitive>; A: TNimbusChartPrimitive;
  Series: TNimbusChartSeries; Hit: TNimbusChartHit; I, J, K, Count, Expected, Index: Integer;
  Svg: string; ExpectedArea: TNimbusChartHitArea; FirstWidth, SecondWidth: Single;
begin
  Chart := TThemedChart.Create(nil);
  try
    Chart.ShowAnimation := False; Chart.ShowLegend := False;
    Chart.BeginUpdate;
    try
      Series := Chart.Model.AddSeries('Business');
      Series.Points.Add(0, NaN, 'Invalid');
      Series.Points.Add(10, 20, 'First').ToolTipText := 'Custom detail';
      Series.Points.Add(12, 22, 'Hidden').Visible := False;
      Series.Points.Add(30, -15, 'Reversed range');
      Series.Points.Add(0, Infinity, 'Infinite');
      Series.Points.Add(NaN, 4, 'Y only');
    finally Chart.EndUpdate end;
    Probe := TBusinessRendererProbe.Create; Renderer := Probe;
    C := Default(TNimbusChartRenderContext); C.Model := Chart.Model; C.Font := Chart.Font; C.Enabled := True;
    C.AnimationProgress := 1; C.Hovered := TNimbusChartHit.None; C.Selected := TNimbusChartHit.None;
    C.XView := TNimbusChartRange.Empty; C.YView := TNimbusChartRange.Empty;
    for I := Low(Types) to High(Types) do
    begin
      Chart.ChartType := Types[I]; Expected := 3; if Types[I] = nctBusinessTimelineRange then Expected := 2;
      ExpectedArea := nchaPoint; if Types[I] = nctBusinessFunnel then ExpectedArea := nchaSegment;
      Check(Chart.RendererFactory.CanRender(Types[I]), 'Business renderer not registered');
      for J := Low(PPIs) to High(PPIs) do
      begin
        C.PPI := PPIs[J]; C.Bounds := Rect(0, 0, 900 * C.PPI div 96, 420 * C.PPI div 96);
        Items := Probe.Primitives(C); Count := 0;
        for A in Items do
          if A.Kind = ncpHitBounds then
          begin
            Index := 1; if Count = 1 then Index := 3 else if Count = 2 then Index := 5;
            Check(A.Hit.PointIndex = Index, 'Business source indices changed');
            Hit := Renderer.HitTest(C, TPointF.Create(A.Bounds.CenterPoint.X, A.Bounds.CenterPoint.Y));
            Check((Hit.Area = ExpectedArea) and (Hit.PointIndex = Index), 'Business rendered row or cell hit mismatch');
            if Index = 1 then Check(Hit.Text = 'Custom detail', 'Business custom tooltip was lost');
            if (Types[I] = nctBusinessTimelineRange) and (Index = 3) then
              Check((Pos('Start: -15', Hit.Text) > 0) and (Pos('End: 30', Hit.Text) > 0), 'Timeline reversed endpoints');
            if (Types[I] in [nctBusinessBullet, nctBusinessLollipopBar]) and (Index = 3) then
              Check((Pos('Target: 30', Hit.Text) > 0) and (Pos('Delta: -45', Hit.Text) > 0), 'Business target or delta incorrect');
            Inc(Count);
          end;
        Check(Count = Expected, 'Business invalid or hidden point filtering');
        C.Selected := Items[High(Items)].Hit;
        Svg := Renderer.ExportSvg(C); Check(Pos('<svg ', Svg) = 1, 'Business SVG failed');
        C.Selected := TNimbusChartHit.None;
      end;
    end;
    Chart.ChartType := nctBusinessFunnel;
    Chart.Model.ClearSeries; Series := Chart.Model.AddSeries('Conversion');
    Series.Points.Add(0, 100, 'Visits'); Series.Points.Add(1, 25, 'Checkout'); Series.Points.Add(2, 4, 'Purchases');
    C.PPI := 96; C.Bounds := Rect(0, 0, 900, 420); Items := Probe.Primitives(C); FirstWidth := 0; SecondWidth := 0;
    for A in Items do
      if A.Kind = ncpPolygon then
      begin
        if A.Hit.PointIndex = 0 then FirstWidth := A.Points[1].X - A.Points[0].X;
        if A.Hit.PointIndex = 1 then SecondWidth := A.Points[1].X - A.Points[0].X;
      end;
    Check((FirstWidth > 0) and (Abs(SecondWidth / FirstWidth - 0.5) < 0.001), 'Funnel square-root width scaling');
    for A in Items do
      if (A.Kind = ncpHitBounds) and (A.Hit.PointIndex = 1) then
      begin
        Hit := Renderer.HitTest(C, TPointF.Create(A.Bounds.CenterPoint.X, A.Bounds.CenterPoint.Y));
        Check((Hit.Area = nchaSegment) and (Pos('Share: ' + FormatFloat('0.#', 25 / 129 * 100) + '%', Hit.Text) > 0), 'Funnel segment tooltip total share');
      end;
    Chart.ChartType := nctBusinessCalendarHeatmap;
    Chart.BeginUpdate;
    try
      Chart.Model.ClearSeries; Series := Chart.Model.AddSeries('Activity');
      for K := 0 to 399 do Series.Points.Add(K, K mod 17, 'Day ' + IntToStr(K + 1));
    finally Chart.EndUpdate end;
    C.PPI := 96; C.Bounds := Rect(0, 0, 900, 420); Items := Probe.Primitives(C); Count := 0;
    for A in Items do if A.Kind = ncpHitBounds then Inc(Count);
    Check(Count = 364, 'Calendar 52-week capacity');
    Series.Points[183].Visible := False;
    Series.Points.BeginUpdate;
    try for K := 184 to 399 do Series.Points[K].Visible := False finally Series.Points.EndUpdate end;
    Items := Probe.Primitives(C); Count := 0;
    for A in Items do if A.Kind = ncpHitBounds then Inc(Count);
    Check(Count = 182, 'Calendar 26-week capacity');
    C.Bounds := Rect(0, 0, 1, 1); Items := Probe.Primitives(C);
    Check(Length(Items) = 0, 'Small business chart layout');
    Renderer := nil;
  finally Chart.Free end;
end;

procedure RunRadialGoalTests;
const PPIs: array[0..3] of Integer = (96, 120, 144, 192);
var Chart: TThemedChart; Probe: TBusinessRendererProbe; Renderer: INimbusChartRenderer;
  C: TNimbusChartRenderContext; Items: TArray<TNimbusChartPrimitive>; A: TNimbusChartPrimitive;
  Series: TNimbusChartSeries; Hit: TNimbusChartHit; I, Count: Integer; Angle, Radius: Double; Location: TPointF;
begin
  Chart := TThemedChart.Create(nil);
  try
    Chart.ChartType := nctBusinessRadialGoal; Chart.ShowLegend := True; Chart.ShowAnimation := False;
    Check(Chart.RendererFactory.CanRender(nctBusinessRadialGoal), 'Radial goal renderer missing');
    Series := Chart.Model.AddSeries('Goals'); Series.Points.Add(0, NaN, 'Invalid');
    Series.Points.Add(1, 0, 'Starting'); Series.Points.Add(2, 50, 'Half'); Series.Points.Add(3, 100, 'Complete');
    Chart.Model.GaugeCenterLabel := 'Goals'; Probe := TBusinessRendererProbe.Create; Renderer := Probe;
    C := Default(TNimbusChartRenderContext); C.Model := Chart.Model; C.Font := Chart.Font; C.Enabled := True;
    C.AnimationProgress := 1; C.Hovered := TNimbusChartHit.None; C.Selected := TNimbusChartHit.None;
    for I := Low(PPIs) to High(PPIs) do
    begin
      C.PPI := PPIs[I]; C.Bounds := Rect(0, 0, 640 * C.PPI div 96, 420 * C.PPI div 96);
      Items := Probe.Primitives(C); Count := 0;
      for A in Items do
        if A.Kind = ncpHitArc then
        begin
          Inc(Count); Angle := DegToRad(A.StartAngle + 6); Radius := A.Bounds.Width / 2;
          Location := TPointF.Create(A.Bounds.CenterPoint.X + Cos(Angle) * Radius, A.Bounds.CenterPoint.Y + Sin(Angle) * Radius);
          Hit := Renderer.HitTest(C, Location);
          Check((Hit.Area = nchaSegment) and (Hit.PointIndex = A.Hit.PointIndex), 'Radial goal shared arc hit geometry');
          Check(A.Hit.PointIndex >= 1, 'Radial invalid point filtering');
        end;
      Check(Count = 3, 'Radial goal visible ring count');
      Check(Pos('Goals', Renderer.ExportSvg(C)) > 0, 'Radial goal center text export');
    end;
    Renderer := nil;
  finally Chart.Free end;
end;

procedure RunPortfolioTests;
const PPIs: array[0..3] of Integer = (96, 120, 144, 192);
var Chart: TThemedChart; Probe: TBusinessRendererProbe; Renderer: INimbusChartRenderer;
  C: TNimbusChartRenderContext; Items: TArray<TNimbusChartPrimitive>; A: TNimbusChartPrimitive;
  Series: TNimbusChartSeries; Hit: TNimbusChartHit; I, J, Count: Integer; Angle, Radius, Margin: Double; Location: TPointF; Svg: string; Layout: TNimbusChartLayout;
begin
  Chart := TThemedChart.Create(nil);
  try
    Chart.ChartType := nctBusinessPortfolioArc; Chart.ShowLegend := True; Chart.ShowAnimation := False;
    Check(Chart.RendererFactory.CanRender(nctBusinessPortfolioArc), 'Portfolio renderer missing');
    Series := Chart.Model.AddSeries('Portfolio'); Series.Points.Add(0, NaN, 'Invalid');
    Series.Points.Add(1, 100, 'Leader'); Series.Points.Add(2, 60, 'Second'); Series.Points.Add(3, 25, 'Third');
    Series.Points.Add(4, 150, 'Hidden').Visible := False;
    Chart.Model.KpiValueText := '$125,000'; Probe := TBusinessRendererProbe.Create; Renderer := Probe;
    C := Default(TNimbusChartRenderContext); C.Model := Chart.Model; C.Font := Chart.Font; C.Enabled := True;
    C.AnimationProgress := 1; C.Hovered := TNimbusChartHit.None; C.Selected := TNimbusChartHit.None;
    for I := Low(PPIs) to High(PPIs) do
    begin
      C.PPI := PPIs[I]; C.Bounds := Rect(0, 0, 900 * C.PPI div 96, 420 * C.PPI div 96);
      Layout := Renderer.Arrange(C); Items := Probe.Primitives(C); Count := 0;
      for A in Items do
        if A.Kind = ncpArc then
          for J := 0 to Ceil(A.SweepAngle) do
          begin
            Angle := DegToRad(A.StartAngle + Min(J, A.SweepAngle)); Margin := A.Width / 2;
            Location := TPointF.Create(A.Bounds.CenterPoint.X + Cos(Angle) * A.Bounds.Width / 2, A.Bounds.CenterPoint.Y + Sin(Angle) * A.Bounds.Height / 2);
            Check((Location.X - Margin >= Layout.PlotArea.Left - 1) and (Location.X + Margin <= Layout.PlotArea.Right + 1), 'Portfolio arc horizontal fit');
            Check((Location.Y - Margin >= Layout.PlotArea.Top - 1) and (Location.Y + Margin <= Layout.PlotArea.Bottom - 34 * C.PPI / 96 + 1), 'Portfolio arc overlaps legend');
          end;
      for A in Items do
        if A.Kind = ncpHitArc then
        begin
          Inc(Count); Angle := DegToRad(A.StartAngle + 6);
          Radius := A.Bounds.Width / 2 - (A.Width - 8 * C.PPI / 96) * 0.4;
          Location := TPointF.Create(A.Bounds.CenterPoint.X + Cos(Angle) * Radius, A.Bounds.CenterPoint.Y + Sin(Angle) * Radius);
          Hit := Renderer.HitTest(C, Location);
          Check((Hit.Area = nchaSegment) and (Hit.PointIndex = A.Hit.PointIndex), 'Portfolio arc priority and shared hit geometry');
          if A.Hit.PointIndex = 1 then Check(Abs(A.SweepAngle - 136) < 0.001, 'Portfolio maximum sweep');
          if A.Hit.PointIndex = 3 then Check(Abs(A.SweepAngle - 68.5) < 0.001, 'Portfolio proportional sweep');
        end;
      Check(Count = 3, 'Portfolio hidden or invalid point filtering');
      Svg := Renderer.ExportSvg(C);
      Check((Pos('$125,000', Svg) > 0) and (Pos('Leader', Svg) > 0), 'Portfolio value or inline legend export');
    end;
    C.Selected := TNimbusChartHit.None; C.Selected.Area := nchaSegment; C.Selected.SeriesIndex := 0; C.Selected.PointIndex := 2;
    Check(Length(Probe.Primitives(C)) > Length(Items), 'Portfolio selected arc focus');
    Check(not Chart.HandleAllocated, 'Portfolio export created HWND'); Renderer := nil;
  finally Chart.Free end;
end;

procedure RunWaterfallTests;
const Types: array[0..1] of TNimbusChartType = (nctBusinessWaterfall, nctBusinessModernWaterfall);
  PPIs: array[0..3] of Integer = (96, 120, 144, 192);
var Chart: TThemedChart; Probe: TBusinessRendererProbe; Renderer: INimbusChartRenderer;
  C: TNimbusChartRenderContext; Items: TArray<TNimbusChartPrimitive>; A: TNimbusChartPrimitive;
  Series: TNimbusChartSeries; Hit: TNimbusChartHit; I, J, Count: Integer; First, Last: TRect; HasTotal: Boolean;
begin
  Chart := TThemedChart.Create(nil);
  try
    Chart.ShowLegend := False; Chart.ShowAnimation := False;
    Series := Chart.Model.AddSeries('Balance'); Series.Points.Add(0, NaN, 'Invalid'); Series.Points.Add(1, 80, 'Opening');
    Series.Points.Add(2, -20, 'Costs'); Series.Points.Add(3, 30, 'Sales'); Series.Points.Add(4, 0, 'Total');
    Probe := TBusinessRendererProbe.Create; Renderer := Probe;
    C := Default(TNimbusChartRenderContext); C.Model := Chart.Model; C.Font := Chart.Font; C.Enabled := True;
    C.AnimationProgress := 1; C.Hovered := TNimbusChartHit.None; C.Selected := TNimbusChartHit.None;
    for I := Low(Types) to High(Types) do
    begin
      Chart.ChartType := Types[I]; Check(Chart.RendererFactory.CanRender(Types[I]), 'Waterfall renderer missing');
      for J := Low(PPIs) to High(PPIs) do
      begin
        C.PPI := PPIs[J]; C.Bounds := Rect(0, 0, 900 * C.PPI div 96, 420 * C.PPI div 96);
        Items := Probe.Primitives(C); Count := 0; HasTotal := False; First := TRect.Empty; Last := TRect.Empty;
        for A in Items do
        begin
          if (A.Kind = ncpText) and (A.Text = '+90') then HasTotal := True;
          if A.Kind = ncpHitBounds then
          begin
            Inc(Count); Hit := Renderer.HitTest(C, TPointF.Create(A.Bounds.CenterPoint.X, A.Bounds.CenterPoint.Y));
            Check((Hit.Area = nchaPoint) and (Hit.PointIndex = A.Hit.PointIndex), 'Waterfall shared bar hit geometry');
            if A.Hit.PointIndex = 1 then First := A.Bounds;
            if A.Hit.PointIndex = 4 then Last := A.Bounds;
            if A.Hit.PointIndex = 2 then Check(Pos('Change: -20', Hit.Text) > 0, 'Waterfall signed tooltip');
          end;
        end;
        Check((Count = 4) and HasTotal, 'Waterfall total or invalid point filtering');
        Check((Last.Height > First.Height) and (Abs(First.Bottom - Last.Bottom) <= 1), 'Waterfall total must start at zero');
        Check(Pos('+90', Renderer.ExportSvg(C)) > 0, 'Waterfall total export');
      end;
    end;
    Renderer := nil;
  finally Chart.Free end;
end;

procedure RunKpiTileTests;
const Widths: array[0..2] of Integer = (500, 700, 900);
  PPIs: array[0..3] of Integer = (96, 120, 144, 192);
var Chart: TThemedChart; Probe: TBusinessRendererProbe; Renderer: INimbusChartRenderer;
  C: TNimbusChartRenderContext; Items: TArray<TNimbusChartPrimitive>; A: TNimbusChartPrimitive;
  Series: TNimbusChartSeries; Hit: TNimbusChartHit; I, J, K, Count, ExpectedColumns: Integer; First, Second: TRect;
begin
  Chart := TThemedChart.Create(nil);
  try
    Chart.ChartType := nctBusinessKpiTiles; Chart.ShowLegend := False; Chart.ShowAnimation := False;
    Check(Chart.RendererFactory.CanRender(nctBusinessKpiTiles), 'KPI tile renderer missing');
    Series := Chart.Model.AddSeries('Tiles'); Series.Points.Add(0, NaN, 'Invalid');
    for K := 1 to 12 do Series.Points.Add(K - 6, K * 100, 'Metric ' + IntToStr(K));
    Probe := TBusinessRendererProbe.Create; Renderer := Probe;
    C := Default(TNimbusChartRenderContext); C.Model := Chart.Model; C.Font := Chart.Font; C.Enabled := True;
    C.AnimationProgress := 1; C.Hovered := TNimbusChartHit.None; C.Selected := TNimbusChartHit.None;
    for I := Low(Widths) to High(Widths) do
      for J := Low(PPIs) to High(PPIs) do
      begin
        C.PPI := PPIs[J]; C.Bounds := Rect(0, 0, Widths[I] * C.PPI div 96, 600 * C.PPI div 96);
        Items := Probe.Primitives(C); Count := 0; First := TRect.Empty; Second := TRect.Empty;
        ExpectedColumns := I + 2;
        for A in Items do if A.Kind = ncpHitBounds then
        begin
          if Count = 0 then First := A.Bounds;
          if Count = ExpectedColumns then Second := A.Bounds;
          Inc(Count); Hit := Renderer.HitTest(C, TPointF.Create(A.Bounds.CenterPoint.X, A.Bounds.CenterPoint.Y));
          Check((Hit.Area = nchaPoint) and (Hit.PointIndex = A.Hit.PointIndex), 'KPI tile shared grid hit geometry');
        end;
        Check((Count = 12) and (First.Left = Second.Left) and (Second.Top > First.Bottom), 'KPI responsive columns and gaps');
        Check((Pos('Metric 1', Renderer.ExportSvg(C)) > 0) and (Pos('-5%', Renderer.ExportSvg(C)) > 0), 'KPI tile labels or delta export');
      end;
    Renderer := nil;
  finally Chart.Free end;
end;

procedure RunParetoTests;
const PPIs: array[0..3] of Integer = (96, 120, 144, 192);
var Chart: TThemedChart; Probe: TBusinessRendererProbe; Renderer: INimbusChartRenderer;
  C: TNimbusChartRenderContext; Items: TArray<TNimbusChartPrimitive>; A: TNimbusChartPrimitive;
  Series: TNimbusChartSeries; Hit: TNimbusChartHit; I, Count: Integer; Plot: TRect; HasCurve: Boolean;
begin
  Chart := TThemedChart.Create(nil);
  try
    Chart.ChartType := nctBusinessPareto; Chart.ShowLegend := False; Chart.ShowAnimation := False;
    Check(Chart.RendererFactory.CanRender(nctBusinessPareto), 'Pareto renderer missing');
    Series := Chart.Model.AddSeries('Issues'); Series.Points.Add(0, 60, 'First'); Series.Points.Add(1, 30, 'Second'); Series.Points.Add(2, 10, 'Third');
    Series.Points.Add(3, 50, 'Hidden').Visible := False; Series.Points.Add(4, NaN, 'Invalid');
    Probe := TBusinessRendererProbe.Create; Renderer := Probe;
    C := Default(TNimbusChartRenderContext); C.Model := Chart.Model; C.Font := Chart.Font; C.Enabled := True;
    C.AnimationProgress := 1; C.Hovered := TNimbusChartHit.None; C.Selected := TNimbusChartHit.None;
    for I := Low(PPIs) to High(PPIs) do
    begin
      C.PPI := PPIs[I]; C.Bounds := Rect(0, 0, 900 * C.PPI div 96, 420 * C.PPI div 96); Plot := Renderer.Arrange(C).PlotArea;
      Items := Probe.Primitives(C); Count := 0; HasCurve := False;
      for A in Items do
      begin
        if (A.Kind = ncpLine) and (Length(A.Points) = 3) then
        begin
          HasCurve := True; Check((A.Points[0].X < A.Points[1].X) and (A.Points[1].X < A.Points[2].X), 'Pareto cumulative percentages');
          Check(A.Points[2].X < Plot.Right, 'Pareto curve exceeded bar area');
        end;
        if A.Kind = ncpHitBounds then
        begin
          Inc(Count); Hit := Renderer.HitTest(C, TPointF.Create(A.Bounds.Left + 1, A.Bounds.CenterPoint.Y));
          Check((Hit.Area = nchaPoint) and (Hit.PointIndex = A.Hit.PointIndex), 'Pareto row hit geometry');
          if Hit.PointIndex = 0 then Check(Pos('Share: 60%', Hit.Text) > 0, 'Pareto tooltip share');
        end;
      end;
      Check((Count = 3) and HasCurve, 'Pareto data filtering or cumulative curve');
      Check(Pos('100%', Renderer.ExportSvg(C)) > 0, 'Pareto cumulative percent export');
    end;
    Renderer := nil;
  finally Chart.Free end;
end;

procedure RunStackTests;
const PPIs: array[0..3] of Integer = (96, 120, 144, 192);
var Chart: TThemedChart; Probe: TBusinessRendererProbe; Renderer: INimbusChartRenderer;
  C: TNimbusChartRenderContext; Items: TArray<TNimbusChartPrimitive>; A: TNimbusChartPrimitive;
  Series: TNimbusChartSeries; Hit: TNimbusChartHit; I, Count: Integer; HasPointColor: Boolean;
begin
  Chart := TThemedChart.Create(nil);
  try
    Chart.ChartType := nctBusinessStackedHorizontalBar; Chart.ShowLegend := True; Chart.ShowAnimation := False;
    Check(Chart.RendererFactory.CanRender(nctBusinessStackedHorizontalBar), 'Stacked renderer missing');
    Series := Chart.Model.AddSeries('First'); Series.Points.Add(0, 10, 'A').Color := clFuchsia;
    Series.Points.Add(1, -5, 'B'); Series.Points.Add(2, 0, 'C'); Series.Points.Add(3, 7, 'D').Visible := False;
    Series := Chart.Model.AddSeries('Second'); Series.Points.Add(0, 30, 'A'); Series.Points.Add(1, 20, 'B');
    Series.Points.Add(2, NaN, 'C'); Series.Points.Add(3, 9, 'D').ToolTipText := 'Raw row 3';
    Series := Chart.Model.AddSeries('Hidden'); Series.Visible := False; Series.Points.Add(0, 500, 'A');
    Probe := TBusinessRendererProbe.Create; Renderer := Probe;
    C := Default(TNimbusChartRenderContext); C.Model := Chart.Model; C.Font := Chart.Font; C.Enabled := True;
    C.AnimationProgress := 1; C.Hovered := TNimbusChartHit.None; C.Selected := TNimbusChartHit.None;
    for I := Low(PPIs) to High(PPIs) do
    begin
      C.PPI := PPIs[I]; C.Bounds := Rect(0, 0, 900 * C.PPI div 96, 420 * C.PPI div 96);
      Items := Probe.Primitives(C); Count := 0; HasPointColor := False;
      for A in Items do
      begin
        if (A.Kind = ncpRect) and (A.Color = ColorToThemeColor(clFuchsia)) then HasPointColor := True;
        if A.Kind = ncpHitBounds then
        begin
          Inc(Count); Hit := Renderer.HitTest(C, TPointF.Create(A.Bounds.CenterPoint.X, A.Bounds.CenterPoint.Y));
          Check((Hit.Area = nchaSegment) and (Hit.SeriesIndex = A.Hit.SeriesIndex) and (Hit.PointIndex = A.Hit.PointIndex), 'Stacked raw row and series hit geometry');
          Check(Hit.SeriesIndex < 2, 'Hidden stack series rendered');
          if Hit.PointIndex = 3 then Check(Hit.Text = 'Raw row 3', 'Stacked custom tooltip');
        end;
      end;
      Check((Count = 4) and HasPointColor, 'Stacked invalid, negative or hidden values and manual point color');
      Check(Pos('First', Renderer.ExportSvg(C)) > 0, 'Stacked inline series legend export');
    end;
    Renderer := nil;
  finally Chart.Free end;
end;

procedure RunColorTests;
var Theme: TThemePalette; Source, Adapted: TNimbusChartPalette; Chart: TThemedChart;
  Expected: TColor; Bitmap: TBitmap; I: Integer; Colors: TArray<TColor>;
begin
  Source := TNimbusChartPalette.Create; Adapted := TNimbusChartPalette.Create; Chart := TThemedChart.Create(nil);
  try
    Source.AccentColor := $00FFB020; Colors := [$00FFB020, clFuchsia]; Source.Colors := Colors;
    Colors[1] := clLime; Check(Source.Colors[1] = clFuchsia, 'Series palette retained mutable input');
    Colors := Source.Colors; Colors[1] := clBlue; Check(Source.Colors[1] = clFuchsia, 'Series palette exposed mutable storage');
    Chart.ShowAnimation := False; Chart.Model.Palette.Assign(Source); Chart.Model.AddSeries('Manual').Points.Add(0, 5);
    Chart.ColorMode := nccAdaptiveCustom; Chart.ThemeInfluence := 12;
    for I := 0 to 1 do
    begin
      if I = 0 then Theme := TThemePresetFactory.Light else Theme := TThemePresetFactory.Dark;
      try
        Adapted.Assign(Source); Adapted.ApplyThemeBlend(Theme, 0);
        Check(Adapted.AccentColor = Source.AccentColor, 'Zero theme influence changed custom color');
        Expected := ThemeColorToColor(NimbusBlendColor(ColorToThemeColor(Source.AccentColor), Theme.AccentColor, Round(12 * 255 / 100)));
        Adapted.ApplyThemeBlend(Theme, 12); Check(Adapted.AccentColor = Expected, 'Adaptive accent blend');
        Adapted.Assign(Source); Adapted.ApplyThemeBlend(Theme, 100);
        Check(Adapted.AccentColor = ThemeColorToColor(Theme.AccentColor), 'Full theme influence');
        Chart.ApplyTheme(Theme); Bitmap := Chart.RenderToBitmap(320, 180); Bitmap.Free;
        Check(Chart.Model.Palette.AccentColor = Source.AccentColor, 'Rendering mutated custom palette');
        Check(Chart.Model.Palette.Colors[1] = clFuchsia, 'Rendering mutated custom series colors');
      finally Theme.Free end;
    end;
    Chart.ThemeInfluence := 200; Check(Chart.ThemeInfluence = 100, 'Theme influence upper limit');
    Chart.ThemeInfluence := -5; Check(Chart.ThemeInfluence = 0, 'Theme influence lower limit');
    Check(not Chart.HandleAllocated, 'Adaptive export created HWND');
  finally Chart.Free; Adapted.Free; Source.Free end;
end;

procedure RunAppearanceTests;
const PPIs: array[0..3] of Integer = (96, 120, 144, 192);
var Chart: TThemedChart; Theme: TThemePalette; Bitmap: TBitmap; Renderer: INimbusChartRenderer;
  C: TNimbusChartRenderContext; L: TNimbusChartLayout; BeforeHit, AfterHit: TNimbusChartHit;
  Appearance: TNimbusChartAppearance; Back, Accent: TColor; PlainSvg, GlowSvg: string; I, J: Integer;
begin
  Chart := TThemedChart.Create(nil);
  try
    Chart.ShowAnimation := False; Chart.Model.AddSeries('Trend').Points.Add(0, 30);
    Chart.Model.Series[0].Points.Add(1, 65); Chart.Model.Series[0].Points.Add(2, 45);
    for Appearance := Low(TNimbusChartAppearance) to High(TNimbusChartAppearance) do
    begin
      Chart.ApplyAppearance(Appearance); Back := Chart.Model.Palette.BackColor; Accent := Chart.Model.Palette.GetSeriesColor(0);
      Check(Chart.ColorMode = nccCustom, 'Appearance must use the complete custom palette');
      Check(Chart.ShowGlow = (Appearance = ncaGlowing), 'Appearance glow default');
      for J := 0 to 1 do
      begin
        if J = 0 then Theme := TThemePresetFactory.Light else Theme := TThemePresetFactory.Dark;
        try
          Chart.ApplyTheme(Theme); Bitmap := Chart.RenderToBitmap(520, 300);
          try Check(ColorToRGB(Bitmap.Canvas.Pixels[2, 2]) = ColorToRGB(Back), 'App theme replaced custom background') finally Bitmap.Free end;
          Check(Chart.Model.Palette.GetSeriesColor(0) = Accent, 'App theme replaced preset series color');
          C := Default(TNimbusChartRenderContext); C.Model := Chart.Model; C.ChartPalette := Chart.Model.Palette; C.Palette := Theme;
          C.Font := Chart.Font; C.Enabled := True; C.AnimationProgress := 1;
          C.Hovered := TNimbusChartHit.None; C.Selected := TNimbusChartHit.None;
          Check(ChartIsDark(C) = (Appearance <> ncaVsIdeLight), 'Custom chart contrast follows app theme');
          Renderer := Chart.RendererFactory.GetRenderer(nctLine);
          for I := 0 to High(PPIs) do
          begin
            C.PPI := PPIs[I]; C.Bounds := Rect(0, 0, 520 * C.PPI div 96, 300 * C.PPI div 96);
            C.ShowGlow := False; L := Renderer.Arrange(C);
            BeforeHit := Renderer.HitTest(C, TPointF.Create(L.PlotArea.CenterPoint.X, L.PlotArea.CenterPoint.Y));
            PlainSvg := Renderer.ExportSvg(C); C.ShowGlow := True; GlowSvg := Renderer.ExportSvg(C);
            AfterHit := Renderer.HitTest(C, TPointF.Create(L.PlotArea.CenterPoint.X, L.PlotArea.CenterPoint.Y));
            Check(Length(GlowSvg) > Length(PlainSvg), 'Glow missing from SVG');
            Check(BeforeHit.SameElement(AfterHit), 'Glow changed hit geometry');
          end;
        finally Theme.Free end;
      end;
    end;
    Chart.ShowGlow := False; PlainSvg := Chart.ExportSvg(520, 300);
    Chart.ShowGlow := True; GlowSvg := Chart.ExportSvg(520, 300);
    Check(Length(GlowSvg) > Length(PlainSvg), 'Control glow missing from export context');
    Check(not Chart.HandleAllocated, 'Appearance or export created an HWND');
  finally Chart.Free end;
end;

procedure RunViolinTests;
const PPIs: array[0..3] of Integer = (96, 120, 144, 192);
var Chart: TChartKeyboardProbe; Loaded: TThemedChart; Options: TNimbusViolinPlotOptions; Stats: TNimbusViolinStatistics;
  Probe: TViolinRendererProbe; Renderer: INimbusChartRenderer; Navigator: INimbusChartSeriesNavigator;
  C: TNimbusChartRenderContext; Items: TArray<TNimbusChartPrimitive>; A: TNimbusChartPrimitive;
  Hit: TNimbusChartHit; Series: TNimbusChartSeries; Bitmap: TBitmap; Stream: TMemoryStream;
  I, Mode, Hits, Points: Integer; Svg: string; Bounds: array[0..1] of TRect;
begin
  RegisterClass(TChartKeyboardProbe); Options := TNimbusViolinPlotOptions.Create; Chart := TChartKeyboardProbe.Create(nil);
  try
    Check((Options.DensitySampleCount = 160) and (Options.MaximumRenderedPoints = 600), 'Violin sampling defaults');
    Check((Options.ShowMedian and Options.ShowMean and Options.ShowInnerBox and Options.ShowOutliers), 'Violin statistics defaults');
    Options.BandwidthMode := nvbFixed; Options.FixedBandwidth := 1; Options.DensitySampleCount := 32;
    Stats := NimbusViolinStatistics([1, 2, 3, 4, 100, NaN, Infinity], Options, -2, 105);
    Check((Length(Stats.Values) = 5) and (Stats.Minimum = 1) and (Stats.Maximum = 100), 'Violin finite sample filtering');
    Check((Stats.Q1 = 2) and (Stats.Median = 3) and (Stats.Q3 = 4) and (Stats.Mean = 22), 'Violin quartiles and mean');
    Check((Stats.LowerWhisker = 1) and (Stats.UpperWhisker = 4), 'Violin IQR outliers');
    Check(Abs(Stats.ConfidenceMaximum - Stats.Mean - 1.96 * Stats.StandardDeviation / Sqrt(5)) < 0.00001, 'Violin 95 percent confidence interval');
    Check((Length(Stats.Density) = 32) and (Stats.MaximumDensity > 0), 'Violin kernel density');
    Options.DensitySampleCount := 2; Check(Options.DensitySampleCount = 32, 'Violin minimum density samples');
    Options.DensitySampleCount := 999; Check(Options.DensitySampleCount = 512, 'Violin maximum density samples');
    Options.FixedBandwidth := 0; Check(Options.FixedBandwidth > 0, 'Violin fixed bandwidth lower bound');
    Options.FixedBandwidth := NaN; Check(SparklineFinite(Options.FixedBandwidth), 'Violin NaN bandwidth accepted');
    Chart.Name := 'ViolinTest'; Chart.ChartType := nctViolinPlot; Chart.ShowAnimation := False; Chart.ShowLegend := True;
    Check(Chart.RendererFactory.CanRender(nctViolinPlot), 'Violin renderer not registered');
    Series := Chart.Model.AddSeries('First'); Series.Points.Add(0, 1); Series.Points.Add(1, 2); Series.Points.Add(2, 3); Series.Points.Add(3, 4); Series.Points.Add(4, 100);
    Series.Points.Add(5, NaN); Series.Points.Add(6, 999).Visible := False;
    Chart.Model.AddSeries('Hidden').Visible := False;
    Chart.Model.AddSeries('Invalid').Points.Add(0, Infinity);
    Series := Chart.Model.AddSeries('Second'); for I := 0 to 29 do Series.Points.Add(I, 20 + Sin(I) * 5);
    Chart.Model.ViolinOptions.MaximumRenderedPoints := 5; Chart.Model.ViolinOptions.ShowMean := False; Chart.Model.ViolinOptions.ShowOutliers := False;
    Chart.Model.ViolinOptions.ShowMeanConfidenceInterval := True; Chart.Model.ViolinOptions.ShowStandardDeviation := True;
    Chart.ColorMode := nccCustom; Chart.Model.Palette.Colors := [clFuchsia, clGreen, clBlue, clAqua];
    Probe := TViolinRendererProbe.Create; Renderer := Probe;
    Check(Supports(Renderer, INimbusChartSeriesNavigator, Navigator), 'Violin keyboard navigation interface');
    C := Default(TNimbusChartRenderContext); C.Model := Chart.Model; C.Font := Chart.Font; C.ChartPalette := Chart.Model.Palette;
    C.Enabled := True; C.AnimationProgress := 1; C.Hovered := TNimbusChartHit.None; C.Selected := TNimbusChartHit.None;
    for I := Low(PPIs) to High(PPIs) do
      for Mode := 0 to 3 do
      begin
        C.PPI := PPIs[I]; C.Bounds := Rect(0, 0, 760 * C.PPI div 96, 420 * C.PPI div 96);
        Chart.Model.ViolinOptions.Orientation := nvoVertical; if Mode mod 2 = 1 then Chart.Model.ViolinOptions.Orientation := nvoHorizontal;
        Chart.Model.ViolinOptions.LayoutMode := nvlSeparate; if Mode >= 2 then Chart.Model.ViolinOptions.LayoutMode := nvlSplitPairs;
        Items := Probe.Primitives(C); Hits := 0; Points := 0;
        for A in Items do
        begin
          if A.Kind = ncpEllipse then Inc(Points);
          if (A.Kind = ncpHitBounds) and (A.Hit.Area = nchaSeries) then
          begin
            Check(Hits < 2, 'Violin unexpected visible series'); Bounds[Hits] := A.Bounds; Inc(Hits);
            Hit := Renderer.HitTest(C, TPointF.Create(A.Bounds.CenterPoint.X, A.Bounds.CenterPoint.Y));
            Check((Hit.Area = nchaSeries) and (Hit.SeriesIndex = A.Hit.SeriesIndex), 'Violin shared hit geometry');
            Check((Pos('Bandwidth:', Hit.Text) > 0) and (Pos('95% mean CI:', Hit.Text) > 0), 'Violin statistics tooltip');
            Check((Hit.SeriesIndex = 0) or (Hit.SeriesIndex = 3), 'Violin original series indices');
          end;
        end;
        Check((Hits = 2) and (Points <= 10), 'Violin series filtering or raw point limit');
        if Mode >= 2 then
          if Mode mod 2 = 0 then Check(Abs(Bounds[0].Right - Bounds[1].Left) <= 2, 'Violin vertical split alignment')
          else Check(Abs(Bounds[0].Bottom - Bounds[1].Top) <= 2, 'Violin horizontal split alignment');
        Hit := Navigator.FindSeriesHit(C, 0); Check((Hit.PointIndex = -1) and (Hit.YValue = 3), 'Violin median series selection');
        Hit := Navigator.FindSeriesHit(C, 1); Check(Hit.Area = nchaNone, 'Violin hidden keyboard series');
        Svg := Renderer.ExportSvg(C); Check((Pos('<polygon', Svg) > 0) and ((Pos('n=5', Svg) > 0) or (Pos('n=35', Svg) > 0)), 'Violin distribution SVG');
      end;
    Chart.Model.ViolinOptions.PointDisplayMode := nvpBeeswarm; Svg := Renderer.ExportSvg(C); Check(Svg = Renderer.ExportSvg(C), 'Violin deterministic point placement');
    Chart.Model.ViolinOptions.PointDisplayMode := nvpNone; Items := Probe.Primitives(C); Points := 0;
    for A in Items do if A.Kind = ncpEllipse then Inc(Points); Check(Points = 0, 'Violin points disabled');
    Chart.Press(VK_RIGHT); Check((Chart.SelectedResult.Area = nchaSeries) and (Chart.SelectedResult.SeriesIndex = 0), 'Violin initial keyboard selection');
    Chart.Press(VK_RIGHT); Check(Chart.SelectedResult.SeriesIndex = 3, 'Violin keyboard skips hidden and empty series');
    Chart.Press(VK_LEFT); Check(Chart.SelectedResult.SeriesIndex = 0, 'Violin previous keyboard series');
    Chart.Press(VK_ESCAPE); Check(Chart.SelectedResult.Area = nchaNone, 'Violin keyboard clears selection');
    Chart.Model.ViolinOptions.BandwidthMode := nvbFixed; Chart.Model.ViolinOptions.FixedBandwidth := 2.5;
    Chart.Model.ViolinOptions.MedianColor := clYellow; Chart.Model.ViolinOptions.ConfidenceLevel := 0.99;
    Stream := TMemoryStream.Create;
    try
      Stream.WriteComponent(Chart); Stream.Position := 0; Loaded := TThemedChart(Stream.ReadComponent(nil));
      try
        Check((Loaded.Model.ViolinOptions.Orientation = nvoHorizontal) and (Loaded.Model.ViolinOptions.LayoutMode = nvlSplitPairs), 'Violin orientation and layout streaming');
        Check((Loaded.Model.ViolinOptions.FixedBandwidth = 2.5) and (Loaded.Model.ViolinOptions.MedianColor = clYellow), 'Violin bandwidth and color streaming');
        Check(Loaded.Model.ViolinOptions.ShowMeanConfidenceInterval and Loaded.Model.ViolinOptions.ShowStandardDeviation, 'Violin overlays streaming');
      finally Loaded.Free end;
    finally Stream.Free end;
    Bitmap := Chart.RenderToBitmap(760, 420); Bitmap.Free;
    Check(not Chart.HandleAllocated, 'Violin export or keyboard forced HWND'); Navigator := nil; Renderer := nil;
  finally Chart.Free; Options.Free end;
end;

procedure RunRidgelineTests;
const PPIs: array[0..3] of Integer = (96, 120, 144, 192);
var Chart: TRidgelineKeyboardProbe; Loaded: TThemedRidgelineChart; Renderer: INimbusChartRenderer; Probe: TRidgelineRendererProbe;
  Options: TNimbusRidgelineOptions; C: TNimbusChartRenderContext; Layout: TNimbusChartLayout; Ridges: TArray<TNimbusRidgelineRidgeInfo>;
  Hit: TNimbusChartHit; Series: TNimbusChartSeries; I, Mode: Integer; Svg: string; Bitmap: TBitmap; Stream: TMemoryStream;
  Linear, Smooth, Step: TArray<TPointF>; Original: TArray<TPointF>;
begin
  RegisterClass(TRidgelineKeyboardProbe); Chart := TRidgelineKeyboardProbe.Create(nil); Options := TNimbusRidgelineOptions.Create;
  try
    Check((Options.Overlap > 0.57) and (Options.Overlap < 0.59) and Options.EnableSelection, 'Ridgeline defaults');
    Options.Overlap := 2; Check(Options.Overlap <= 0.921, 'Ridgeline overlap clamp'); Options.RidgeHeight := 0; Check(Options.RidgeHeight = 18, 'Ridgeline minimum height');
    Options.SetZoomRange(4, 1); Check((Options.ZoomStartIndex = 1) and (Options.ZoomEndIndex = 4), 'Ridgeline reversed option zoom');
    Options.ResetZoom; Check((Options.ZoomStartIndex = -1) and (Options.ZoomEndIndex = -1), 'Ridgeline zoom reset');
    Chart.Name := 'RidgelineTest'; Chart.ShowAnimation := False; Check(Chart.RendererFactory.CanRender(nctRidgeline), 'Ridgeline renderer registration');
    Series := Chart.Model.AddSeries('Beta'); Series.Points.Add(0, 1, 'One'); Series.Points.Add(1, 3, 'Two'); Series.Points.Add(2, 2, 'Three').ToolTipText := 'Custom ridge tooltip';
    Chart.Model.AddSeries('Hidden').Visible := False; Series := Chart.Model.AddSeries('Alpha'); Series.Points.Add(0, 0.25, 'One'); Series.Points.Add(1, 0.5, 'Two');
    Chart.Model.AddSeries('Empty'); Probe := TRidgelineRendererProbe.Create; Renderer := Probe;
    C := Default(TNimbusChartRenderContext); C.Model := Chart.Model; C.Font := Chart.Font; C.ChartPalette := Chart.Model.Palette;
    C.Enabled := True; C.AnimationProgress := 1; C.Hovered := TNimbusChartHit.None; C.Selected := TNimbusChartHit.None;
    for I := Low(PPIs) to High(PPIs) do
    begin
      C.PPI := PPIs[I]; C.Bounds := Rect(0, 0, 760 * C.PPI div 96, 420 * C.PPI div 96); Layout := Renderer.Arrange(C);
      for Mode := 0 to 6 do
      begin
        Chart.RidgelineOptions.SortMode := TNimbusRidgelineSortMode(Mode); Ridges := Probe.GetRidges(C, Layout.PlotArea);
        Check(Length(Ridges) = 2, 'Ridgeline hidden and empty series filtering');
        if Mode in [1, 3, 5] then Check(Ridges[0].SeriesIndex = 2, 'Ridgeline ascending sort keeps raw indices');
        if Mode in [0, 2, 4, 6] then Check(Ridges[0].SeriesIndex = 0, 'Ridgeline descending or original order');
      end;
      Chart.RidgelineOptions.SortMode := nroNone; Chart.RidgelineOptions.ScaleMode := nrsPerRidge;
      Ridges := Probe.GetRidges(C, Layout.PlotArea);
      Check((Ridges[0].Total = 6) and (Ridges[0].Peak = 3) and (Ridges[0].Median = 1), 'Ridgeline summary statistics');
      Check(Abs(Ridges[0].Mean - 7 / 6) < 0.00001, 'Ridgeline weighted mean');
      Check(Abs(Ridges[1].Points[1].NormalizedValue - 1) < 0.00001, 'Ridgeline fractional peak normalization');
      Hit := Renderer.HitTest(C, TPointF.Create(Ridges[0].Points[2].Location.X - 1, Ridges[0].Points[2].Location.Y));
      Check((Hit.SeriesIndex = 0) and (Hit.PointIndex = 2) and (Hit.Text = 'Custom ridge tooltip'), 'Ridgeline nearest raw point hit and custom tooltip');
      Chart.RidgelineOptions.ScaleMode := nrsPercent; Ridges := Probe.GetRidges(C, Layout.PlotArea);
      Check(Abs(Ridges[0].Points[1].NormalizedValue - 0.5) < 0.00001, 'Ridgeline percent scale');
      Svg := Renderer.ExportSvg(C); Check((Pos('<polygon', Svg) > 0) and (Pos('Beta', Svg) > 0), 'Ridgeline SVG labels and geometry');
    end;
    Original := [TPointF.Create(0, 0), TPointF.Create(10, 5), TPointF.Create(20, 1)];
    Linear := NimbusRidgelineCurve(Original, nrcLinear); Smooth := NimbusRidgelineCurve(Original, nrcSmooth); Step := NimbusRidgelineCurve(Original, nrcStep);
    Check((Length(Linear) = 3) and (Length(Smooth) > 3) and (Length(Step) = 7), 'Ridgeline smooth and step geometry');
    Check((Smooth[0].X = 0) and (Smooth[High(Smooth)].X = 20), 'Ridgeline curve endpoints');
    Chart.ZoomToRange(2, 1); Check((Chart.ZoomStartIndex = 1) and (Chart.ZoomEndIndex = 2), 'Ridgeline control reversed range');
    Layout := Renderer.Arrange(C); Ridges := Probe.GetRidges(C, Layout.PlotArea);
    Check((Ridges[0].Points[0].PointIndex = 1) and (Ridges[0].Points[1].PointIndex = 2) and (Ridges[0].Total = 5), 'Ridgeline zoom geometry preserves indices');
    Chart.ResetRidgelineZoom; Chart.SelectRidge(2, 1); Check((Chart.SelectedResult.SeriesIndex = 2) and (Chart.RidgelineOptions.SelectedPointIndex = 1), 'Ridgeline programmatic point selection');
    Chart.Press(VK_ESCAPE); Check((Chart.ZoomStartIndex = -1) and (Chart.SelectedResult.Area = nchaNone), 'Ridgeline escape clears zoom and selection');
    Chart.Press(VK_DOWN); Check(Chart.SelectedResult.SeriesIndex = 0, 'Ridgeline keyboard first ridge');
    Chart.Press(VK_DOWN); Check(Chart.SelectedResult.SeriesIndex = 2, 'Ridgeline keyboard skips hidden ridge');
    Chart.EnableRidgeSelection := False; Chart.SelectRidge(0); Check(Chart.SelectedResult.SeriesIndex = 2, 'Ridgeline disabled selection');
    Chart.EnableRidgeSelection := True; Chart.CurveMode := nrcStep; Chart.ZoomToRange(0, 1); Chart.RidgelineOptions.ShowMedianMarker := True;
    Stream := TMemoryStream.Create;
    try
      Stream.WriteComponent(Chart); Stream.Position := 0; Loaded := TThemedRidgelineChart(Stream.ReadComponent(nil));
      try
        Check((Loaded.ChartType = nctRidgeline) and (Loaded.CurveMode = nrcStep), 'Ridgeline type and curve streaming');
        Check((Loaded.ZoomStartIndex = 0) and (Loaded.ZoomEndIndex = 1) and Loaded.RidgelineOptions.ShowMedianMarker, 'Ridgeline options and zoom streaming');
      finally Loaded.Free end;
    finally Stream.Free end;
    Bitmap := Chart.RenderToBitmap(760, 420); Bitmap.Free; Check(not Chart.HandleAllocated, 'Ridgeline export or selection forced HWND'); Renderer := nil;
  finally Chart.Free; Options.Free end;
end;

procedure RunStreamGraphTests;
const PPIs: array[0..3] of Integer = (96, 120, 144, 192);
var Chart: TThemedStreamGraphChart; Loaded: TThemedStreamGraphChart; Probe: TNimbusStreamGraphChartRenderer;
  Renderer: INimbusChartRenderer; Options: TNimbusStreamGraphOptions; C: TNimbusChartRenderContext; L: TNimbusChartLayout;
  G: TNimbusStreamGeometry; S: TNimbusChartSeries; Hit: TNimbusChartHit; I, Mode, Curve: Integer; Stream: TMemoryStream; Bitmap: TBitmap;
begin
  Chart := TThemedStreamGraphChart.Create(nil); Options := TNimbusStreamGraphOptions.Create;
  try
    Check(not Chart.HandleAllocated, 'StreamGraph constructor forced HWND');
    Check((Options.BaselineMode = nsbSilhouette) and (Options.CurveMode = nscSmooth) and Options.EnableSelection, 'StreamGraph defaults');
    Options.MouseWheelZoomFactor := 0; Check(Options.MouseWheelZoomFactor >= 0.249, 'StreamGraph zoom factor clamp');
    Options.SetZoomRange(7, 2); Check((Options.ZoomStartIndex = 2) and (Options.ZoomEndIndex = 7), 'StreamGraph reversed option range'); Options.ResetZoom;
    S := Chart.Model.AddSeries('Hidden'); S.Visible := False; S.Points.Add(0, 999, '0');
    S := Chart.Model.AddSeries('First'); S.Points.Add(10, 2, '10'); S.Points.Add(2, 4, '2'); S.Points.Add(1, 3, '1'); S.Points.Add(20, -4, '20');
    S := Chart.Model.AddSeries('Second'); S.Points.Add(1, 6, '1'); S.Points.Add(10, 8, '10'); S.Points.Add(2, 6, '2'); S.Points.Add(20, NaN, '20');
    Probe := TNimbusStreamGraphChartRenderer.Create; Renderer := Probe; C := Default(TNimbusChartRenderContext);
    C.Model := Chart.Model; C.Font := Chart.Font; C.ChartPalette := Chart.Model.Palette; C.Enabled := True;
    C.Hovered := TNimbusChartHit.None; C.Selected := TNimbusChartHit.None;
    for I := Low(PPIs) to High(PPIs) do for Mode := Ord(Low(TNimbusStreamBaselineMode)) to Ord(High(TNimbusStreamBaselineMode)) do for Curve := Ord(Low(TNimbusStreamCurveMode)) to Ord(High(TNimbusStreamCurveMode)) do
    begin
      C.PPI := PPIs[I]; C.Bounds := Rect(0, 0, Round(820 * C.PPI / 96), Round(420 * C.PPI / 96));
      Chart.BaselineMode := TNimbusStreamBaselineMode(Mode); Chart.CurveMode := TNimbusStreamCurveMode(Curve); L := Renderer.Arrange(C); G := Probe.GetGeometry(C, L.PlotArea);
      Check((Length(G.Bands) = 2) and (Length(G.Categories) = 4), 'StreamGraph hidden series filter');
      Check((G.Categories[0] = '1') and (G.Categories[1] = '2') and (G.Categories[2] = '10'), 'StreamGraph numeric category ordering');
      Check((G.Bands[0].Samples[1].SeriesIndex = 1) and (G.Bands[0].Samples[1].PointIndex = 1), 'StreamGraph original source indices');
      Check((G.Bands[0].Samples[1].RawTotal = 10) and (Abs(G.Bands[0].Samples[1].Share - 0.4) < 0.00001), 'StreamGraph raw totals and share');
      if Mode = Ord(nsbExpand100) then Check(Abs(G.Bands[0].Samples[1].Value - 0.4) < 0.00001, 'StreamGraph normalized bands');
      if Mode = Ord(nsbZero) then Check(G.Baseline[0] = 0, 'StreamGraph zero baseline');
      if Mode = Ord(nsbSilhouette) then Check(G.Baseline[0] = -4.5, 'StreamGraph silhouette baseline');
      Hit := Renderer.HitTest(C, G.Bands[0].Samples[1].CenterPoint);
      Check((Hit.SeriesIndex = 1) and (Hit.PointIndex = 1) and (Hit.ElementIndex = 1) and (Hit.YValue = 4), 'StreamGraph shared band hit geometry');
      Check(Pos('<polygon', Chart.ExportSVG(820, 420)) > 0, 'StreamGraph SVG bands');
    end;
    Chart.BaselineMode := nsbSilhouette; Chart.ZoomToRange(2, 1); G := Probe.GetGeometry(C, L.PlotArea);
    Check((G.FirstIndex = 1) and (G.LastIndex = 2) and (G.Bands[0].Samples[1].PointIndex = 0), 'StreamGraph zoom preserves sorted category raw indices');
    Chart.SelectBand(1, 2); Check((Chart.SelectedResult.SeriesIndex = 1) and (Chart.SelectedBand.PointIndex = 0), 'StreamGraph programmatic selection');
    Chart.StreamGraphOptions.LineWidth := 2; Check(Chart.SelectedResult.SeriesIndex = 1, 'StreamGraph option change preserves selection');
    Chart.StreamGraphOptions.SelectionMode := nssNone; Chart.ClearStreamSelection; Chart.SelectBand(1, 1); Check(Chart.SelectedResult.Area = nchaNone, 'StreamGraph disabled selection');
    Chart.StreamGraphOptions.SelectionMode := nssTimeSlice; Chart.StreamGraphOptions.EnableTimeSliceSelection := False; Chart.SelectBand(1, 1); Check(Chart.SelectedResult.Area = nchaNone, 'StreamGraph disabled time-slice selection');
    Chart.StreamGraphOptions.EnableTimeSliceSelection := True; Chart.SelectBand(1, 1); Check(Chart.SelectedBand.RawValue = 4, 'StreamGraph time-slice raw value');
    Stream := TMemoryStream.Create;
    try
      Stream.WriteComponent(Chart); Stream.Position := 0; Loaded := TThemedStreamGraphChart(Stream.ReadComponent(nil));
      try Check((Loaded.StreamGraphOptions.ZoomStartIndex = 1) and (Loaded.StreamGraphOptions.SelectionMode = nssTimeSlice), 'StreamGraph option streaming') finally Loaded.Free end;
    finally Stream.Free end;
    Chart.ResetStreamZoom; Bitmap := Chart.RenderToBitmap(820, 420); Bitmap.Free;
    Check(not Chart.HandleAllocated, 'StreamGraph export forced HWND'); Renderer := nil;
  finally Options.Free; Chart.Free end;
end;

procedure RunTreemapTests;
const PPIs: array[0..3] of Integer = (96, 120, 144, 192);
var Chart: TThemedTreemapChart; Loaded: TThemedTreemapChart; Renderer: INimbusChartRenderer; Probe: TNimbusTreemapChartRenderer;
  C: TNimbusChartRenderContext; L: TNimbusChartLayout; Tiles: TArray<TNimbusTreemapTileInfo>; Tile: TNimbusTreemapTileInfo;
  S: TNimbusChartSeries; Hit: TNimbusChartHit; I, Mode, Leaves: Integer; Total: Double; Stream: TMemoryStream; Bitmap: TBitmap;
begin
  Chart := TThemedTreemapChart.Create(nil);
  try
    Check(not Chart.HandleAllocated, 'Treemap constructor forced HWND');
    Check((Chart.LayoutMode = ntlSquarified) and (Chart.MarkingMode = ntmBranch) and (Chart.TreemapOptions.MaximumDepth = 8), 'Treemap defaults');
    S := Chart.Model.AddSeries('Hidden'); S.Visible := False; S.Points.Add(0, 999, 'Hidden/Product');
    S := Chart.Model.AddSeries('Revenue'); S.Points.Add(0, 20, 'North/Cloud/A'); S.Points.Add(1, 10, 'North/Cloud/B');
    S.Points.Add(2, 40, 'South/Services/C'); S.Points.Add(3, 30, 'South/Services/D'); S.Points.Add(4, NaN, 'Invalid');
    S.Points.Add(5, -10, 'Negative'); S.Points.Add(6, 1000, 'Invisible').Visible := False;
    Probe := TNimbusTreemapChartRenderer.Create; Renderer := Probe; C := Default(TNimbusChartRenderContext);
    C.Model := Chart.Model; C.Font := Chart.Font; C.ChartPalette := Chart.Model.Palette; C.Enabled := True; C.Hovered := TNimbusChartHit.None; C.Selected := TNimbusChartHit.None;
    for I := Low(PPIs) to High(PPIs) do for Mode := Ord(Low(TNimbusTreemapLayoutMode)) to Ord(High(TNimbusTreemapLayoutMode)) do
    begin
      C.PPI := PPIs[I]; C.Bounds := Rect(0, 0, Round(960 * C.PPI / 96), Round(600 * C.PPI / 96)); Chart.LayoutMode := TNimbusTreemapLayoutMode(Mode);
      L := Renderer.Arrange(C); Tiles := Probe.GetTiles(C, L.PlotArea); Leaves := 0; Total := 0;
      for Tile in Tiles do if Tile.IsLeaf then
      begin
        Inc(Leaves); Total := Total + Tile.Value;
        Check((Tile.SeriesIndex = 1) and (Tile.PointIndex >= 0) and (Tile.PointIndex < 4), 'Treemap raw leaf indices');
        Hit := Renderer.HitTest(C, TPointF.Create(Tile.ContentBounds.CenterPoint.X, Tile.ContentBounds.CenterPoint.Y));
        Check((Hit.SeriesIndex = Tile.SeriesIndex) and (Hit.PointIndex = Tile.PointIndex) and (Hit.YValue = Tile.Value), 'Treemap leaf paint and hit geometry');
        Check((Tile.Bounds.Left >= L.PlotArea.Left) and (Tile.Bounds.Right <= L.PlotArea.Right) and (Tile.Bounds.Bottom <= L.PlotArea.Bottom), 'Treemap layout containment');
      end;
      Check((Leaves = 4) and (Total = 100), 'Treemap finite positive visible data filtering');
      Check(Pos('North', Chart.ExportSVG(960, 600)) > 0, 'Treemap SVG labels');
    end;
    Chart.ZoomToPath('North'); L := Renderer.Arrange(C); Tiles := Probe.GetTiles(C, L.PlotArea); Leaves := 0;
    for Tile in Tiles do if Tile.IsLeaf then begin Inc(Leaves); Check(Tile.RootTotal = 30, 'Treemap zoom recalculates root share') end;
    Check(Leaves = 2, 'Treemap drill-down branch filtering'); Chart.ZoomToParent; Check(Chart.ZoomPath = '', 'Treemap parent navigation');
    Chart.MarkPath('South'); Check(Chart.MarkedPath = 'South', 'Treemap branch marking'); Chart.ClearMarking; Check(Chart.MarkedPath = '', 'Treemap clear marking');
    Chart.TreemapOptions.EnableZoom := False; Chart.ZoomToPath('North'); Check(Chart.ZoomPath = '', 'Treemap disabled zoom'); Chart.TreemapOptions.EnableZoom := True;
    Chart.TreemapOptions.HoverDimOpacity := 1; Check(Chart.TreemapOptions.HoverDimOpacity < 0.851, 'Treemap hover dim clamp');
    Chart.ZoomToPath('South'); Chart.LayoutMode := ntlHorizontal; Stream := TMemoryStream.Create;
    try Stream.WriteComponent(Chart); Stream.Position := 0; Loaded := TThemedTreemapChart(Stream.ReadComponent(nil));
      try Check((Loaded.ZoomPath = 'South') and (Loaded.LayoutMode = ntlHorizontal), 'Treemap option streaming') finally Loaded.Free end;
    finally Stream.Free end;
    Chart.ResetTreemapZoom; Bitmap := Chart.RenderToBitmap(960, 600); Bitmap.Free; Check(not Chart.HandleAllocated, 'Treemap export forced HWND'); Renderer := nil;
  finally Chart.Free end;
end;

procedure RunSunburstTests;
const PPIs: array[0..3] of Integer = (96, 120, 144, 192);
var Chart: TThemedSunburstChart; Loaded: TThemedSunburstChart; Renderer: INimbusChartRenderer; Probe: TNimbusSunburstChartRenderer;
  C: TNimbusChartRenderContext; L: TNimbusChartLayout; G: TNimbusSunburstGeometry; Info: TNimbusSunburstSegmentInfo;
  S: TNimbusChartSeries; Hit: TNimbusChartHit; I, RootMode, Depth: Integer; Radius, Angle: Double; Location: TPointF; Stream: TMemoryStream; Bitmap: TBitmap;
begin
  Chart := TThemedSunburstChart.Create(nil);
  try
    Check(not Chart.HandleAllocated, 'Sunburst constructor forced HWND');
    Check((Chart.SunburstOptions.MaximumDepth = 6) and (Chart.MarkingMode = nsmBranch) and Chart.SunburstOptions.ShowPercentages, 'Sunburst defaults');
    S := Chart.Model.AddSeries('Hidden'); S.Visible := False; S.Points.Add(0, 999, 'Hidden/Leaf');
    S := Chart.Model.AddSeries('Revenue'); S.Points.Add(0, 20, 'North/Cloud').Tag := 321;
    S.Points.Add(1, 30, 'North/Services'); S.Points.Add(2, 50, 'South/Support'); S.Points.Add(3, NaN, 'Invalid'); S.Points.Add(4, -3, 'Negative');
    Probe := TNimbusSunburstChartRenderer.Create; Renderer := Probe; C := Default(TNimbusChartRenderContext);
    C.Model := Chart.Model; C.Font := Chart.Font; C.ChartPalette := Chart.Model.Palette; C.Enabled := True; C.Hovered := TNimbusChartHit.None; C.Selected := TNimbusChartHit.None;
    for I := Low(PPIs) to High(PPIs) do for RootMode := 0 to 1 do for Depth := 1 to 3 do
    begin
      C.PPI := PPIs[I]; C.Bounds := Rect(0, 0, Round(800 * C.PPI / 96), Round(540 * C.PPI / 96));
      Chart.SunburstOptions.ShowRootRing := RootMode = 1; Chart.SunburstOptions.MaximumDepth := Depth; L := Renderer.Arrange(C); G := Probe.GetGeometry(C, L.PlotArea);
      Check((G.RootValue = 100) and (G.VisibleValue = 100) and (Length(G.Segments) > 0), 'Sunburst filtered hierarchy total');
      for Info in G.Segments do
      begin
        Check((Info.Depth <= Depth) and (Info.OuterRadius <= G.OuterRadius + 0.01) and (Info.InnerRadius < Info.OuterRadius), 'Sunburst root ring and depth containment');
        Radius := (Info.InnerRadius + Info.OuterRadius) / 2; Angle := DegToRad(Info.StartAngle + Info.SweepAngle / 2);
        Location := TPointF.Create(Info.Center.X + Cos(Angle) * Radius, Info.Center.Y + Sin(Angle) * Radius); Hit := Renderer.HitTest(C, Location);
        Check((Hit.ElementIndex = Info.NodeIndex) and (Hit.YValue = Info.Value), 'Sunburst shared sector hit geometry');
        if Info.PointIndex = 0 then Check((Info.SeriesIndex = 1) and (Info.Tag = 321), 'Sunburst raw point index and Tag');
      end;
      Hit := Renderer.HitTest(C, G.Center); Check(Hit.Area <> nchaSegment, 'Sunburst center hole hit');
      Check(Pos('<polygon', Chart.ExportSVG(800, 540)) > 0, 'Sunburst SVG ring segments');
    end;
    Chart.SunburstOptions.ShowRootRing := False; Chart.SunburstOptions.MaximumDepth := 6; Chart.ZoomToPath('North');
    L := Renderer.Arrange(C); G := Probe.GetGeometry(C, L.PlotArea); Check((G.RootValue = 100) and (G.VisibleValue = 50) and (Length(G.Segments) = 2), 'Sunburst zoom root and total shares');
    Chart.ZoomToPath('North/Cloud'); G := Probe.GetGeometry(C, L.PlotArea); Check((Length(G.Segments) = 1) and (G.VisibleValue = 20), 'Sunburst leaf drill-down');
    Chart.ZoomToParent; Check(Chart.ZoomPath = 'North', 'Sunburst parent navigation'); Chart.MarkPath('South'); Check(Chart.MarkedPath = 'South', 'Sunburst branch marking');
    Chart.ClearMarking; Check(not Chart.SunburstOptions.HasMarkedPath, 'Sunburst clear marking');
    Chart.SunburstOptions.InnerRadiusRatio := 2; Check(Chart.SunburstOptions.InnerRadiusRatio <= 0.721, 'Sunburst center radius clamp');
    Chart.SunburstOptions.MaximumDepth := 99; Check(Chart.SunburstOptions.MaximumDepth = 12, 'Sunburst depth clamp');
    Chart.SunburstOptions.MarkedBorderWidth := 0; Check(Chart.SunburstOptions.MarkedBorderWidth = 1, 'Sunburst marked border clamp');
    Stream := TMemoryStream.Create;
    try Stream.WriteComponent(Chart); Stream.Position := 0; Loaded := TThemedSunburstChart(Stream.ReadComponent(nil));
      try Check((Loaded.ZoomPath = 'North') and (Loaded.SunburstOptions.MaximumDepth = 12), 'Sunburst option streaming') finally Loaded.Free end;
    finally Stream.Free end;
    Chart.ResetSunburstZoom; Bitmap := Chart.RenderToBitmap(800, 540); Bitmap.Free; Check(not Chart.HandleAllocated, 'Sunburst export forced HWND'); Renderer := nil;
  finally Chart.Free end;
end;

procedure RunKpiTests;
const PPIs: array[0..3] of Integer = (96, 120, 144, 192);
var
  Chart: TThemedChart; Probe: TKpiRendererProbe; Renderer: INimbusChartRenderer;
  C: TNimbusChartRenderContext; Items: TArray<TNimbusChartPrimitive>; A: TNimbusChartPrimitive;
  L: TNimbusChartLayout; Hit: TNimbusChartHit; Series: TNimbusChartSeries;
  I, TextCount: Integer; LargeValue, CardOutline, Accent: Boolean; Bitmap: TBitmap; Svg: string;
begin
  Chart := TThemedChart.Create(nil);
  try
    Chart.ChartType := nctKpi; Chart.ShowAnimation := False; Chart.UseThemePaletteForChart := False;
    Chart.Model.KpiTitle := 'Monthly revenue'; Chart.Model.KpiValue := 1250; Chart.Model.KpiChangeValue := -12.5;
    Chart.Model.KpiSubtitle := 'All regions'; Chart.Model.KpiState := nksError;
    Chart.Model.Palette.ErrorColor := clRed;
    Probe := TKpiRendererProbe.Create; Renderer := Probe;
    C := Default(TNimbusChartRenderContext); C.Model := Chart.Model; C.Font := Chart.Font; C.ChartPalette := Chart.Model.Palette;
    C.Enabled := True; C.AnimationProgress := 1; C.Hovered := TNimbusChartHit.None; C.Selected := TNimbusChartHit.None;
    C.XView := TNimbusChartRange.Empty; C.YView := TNimbusChartRange.Empty;
    for I := Low(PPIs) to High(PPIs) do
    begin
      C.PPI := PPIs[I]; C.Font.Height := -MulDiv(13, C.PPI, 96);
      C.Bounds := Rect(0, 0, MulDiv(520, C.PPI, 96), MulDiv(300, C.PPI, 96));
      L := Renderer.Arrange(C); Items := Probe.Primitives(C);
      Check(L.TitleBounds.IsEmpty and L.LegendBounds.IsEmpty and L.XAxisBounds.IsEmpty, 'KPI reserved chart axes or legend');
      TextCount := 0; LargeValue := False; CardOutline := False; Accent := False;
      for A in Items do
      begin
        if A.Kind = ncpText then
        begin
          Inc(TextCount); Check(A.UseClip and A.UseFont, 'KPI text omitted font or clipping');
          if A.Text = '1250' then LargeValue := (Abs(A.FontHeight) > Abs(C.Font.Height)) and (fsBold in A.FontStyle);
        end;
        if A.Kind = ncpOutlineRect then CardOutline := True;
        if A.Kind = ncpPolygon then Accent := A.Color = $FFFF0000;
      end;
      Check((TextCount = 4) and LargeValue and CardOutline and Accent, 'KPI card incomplete');
      Hit := Renderer.HitTest(C, TPointF.Create(L.PlotArea.CenterPoint.X, L.PlotArea.CenterPoint.Y));
      Check((Hit.Area = nchaPoint) and (Hit.YValue = 1250) and (Hit.SeriesIndex = -1), 'Model-only KPI hit');
      Check(Pos('Change: ' + FormatFloat('+0.##;-0.##;0', -12.5), Hit.Text) > 0, 'KPI numeric change fallback');
      C.Selected := Hit; Items := Probe.Primitives(C); CardOutline := False;
      for A in Items do if A.Kind = ncpOutlineRect then CardOutline := (A.Color = $FFFF0000) and (A.Width = 2);
      Check(CardOutline, 'Selected KPI state border'); C.Selected := TNimbusChartHit.None;
      Svg := Renderer.ExportSvg(C);
      Check((Pos('font-weight="bold"', Svg) > 0) and (Pos('clip-path="url(#item', Svg) > 0), 'KPI SVG lost typography or clipping');
    end;
    Chart.Font.Height := -13; Bitmap := Chart.RenderToBitmap(520, 300);
    try Check(Bitmap.Canvas.Pixels[17, 150] = clRed, 'KPI accent missing from bitmap') finally Bitmap.Free end;
    Chart.Model.KpiValueText := ''; Series := Chart.Model.AddSeries('Hidden'); Series.Visible := False; Series.Points.Add(0, 900);
    Series := Chart.Model.AddSeries('Visible'); Series.Points.Add(0, 999).Visible := False;
    Series.Points.Add(0, 42, 'Compared with last month').ToolTipText := 'Custom KPI';
    C.PPI := 96; C.Bounds := Rect(0, 0, 520, 300); L := Renderer.Arrange(C);
    Hit := Renderer.HitTest(C, TPointF.Create(L.PlotArea.CenterPoint.X, L.PlotArea.CenterPoint.Y));
    Check((Hit.SeriesIndex = 1) and (Hit.PointIndex = 1) and (Hit.YValue = 42) and (Hit.Text = 'Custom KPI'), 'KPI first visible point and custom tooltip');
    Check(not Chart.HandleAllocated, 'KPI export created control HWND');
    C.Bounds := Rect(0, 0, 1, 1); Check(Length(Probe.Primitives(C)) = 0, 'Small KPI layout');
    Renderer := nil;
  finally Chart.Free end;
end;


procedure RunMapHeatPaletteTests;
var Chart: TThemedChart; ModelCopy: TNimbusChartModel; C: TNimbusChartRenderContext; Map: TMapRendererProbe;
  Basic: TKpiRendererProbe; Business: TBusinessRendererProbe; Items: TArray<TNimbusChartPrimitive>; A: TNimbusChartPrimitive;
  S: TNimbusChartSeries; Shapes: TArray<TNimbusMapShape>; I, J, Colored, EmptyCount: Integer;
  Found: Boolean;
begin
  Chart := TThemedChart.Create(nil); Map := TMapRendererProbe.Create; Basic := TKpiRendererProbe.Create;
  Business := TBusinessRendererProbe.Create; ModelCopy := TNimbusChartModel.Create;
  try
    C := Default(TNimbusChartRenderContext); C.Model := Chart.Model; C.Font := Chart.Font;
    C.Bounds := Rect(0, 0, 1280, 720); C.PPI := 96; C.Enabled := True; C.ColorInfluence := 100; C.ChartPalette := Chart.Model.Palette;
    Chart.ShowAxes := False; Chart.ShowLegend := False; Chart.ShowGrid := False;
    for I := 0 to 1 do
    begin
      Chart.Model.Series.Clear;
      if I = 0 then begin Chart.ChartType := nctChoroplethMap; Shapes := NimbusWorldMapShapes end
      else begin Chart.ChartType := nctCountryMap; Chart.Model.Options.CountryMapIsoA3 := 'DEU'; Shapes := NimbusCountryMapShapes('DEU') end;
      S := Chart.Model.AddSeries('Regions');
      if I = 0 then begin S.Points.Add(0, 1, 'DEU').Color := clRed; S.Points.Add(1, 2, 'USA').Color := clBlue end
      else begin S.Points.Add(0, 1, Shapes[0].Code).Color := clRed; S.Points.Add(1, 2, Shapes[1].Code).Color := clBlue end;
      Chart.Model.Options.MapEmptyColor := RGB(220, 220, 220); Items := Map.Primitives(C); Colored := 0; EmptyCount := 0;
      for A in Items do if A.Kind = ncpPolygon then
      begin
        if A.Hit.PointIndex = 0 then begin Check(A.Color = $FFFF0000, 'Map flattened explicit red'); Inc(Colored) end
        else if A.Hit.PointIndex = 1 then begin Check(A.Color = $FF0000FF, 'Map flattened explicit blue'); Inc(Colored) end
        else begin Check(A.Color = $FFDCDCDC, 'Map no-data fill'); Inc(EmptyCount) end;
      end;
      Check((Colored >= 2) and (EmptyCount > 0), 'Map highlight and no-data coverage');
      Chart.Model.Options.MapColorMode := ncmCategorical; S.Points[0].Color := clNone;
      Items := Map.Primitives(C); Found := False;
      for A in Items do if (A.Kind = ncpPolygon) and (A.Hit.PointIndex = 0) then
      begin Check(A.Color = ColorToThemeColor(Chart.Model.Palette.GetSeriesColor(0)), 'Categorical map color'); Found := True end;
      Check(Found, 'Missing categorical region');
    end;
    Chart.Model.Series.Clear; Chart.ChartType := nctHeatmap; S := Chart.Model.AddSeries('Activity');
    for J := 0 to 4 do S.Points.Add(J, J);
    Chart.Model.HeatmapColorPreset := nhcpGitHubGreen;
    Check(ChartHeatmapColor(C, 0) = $FFEBEDF0, 'GitHub zero'); Check(ChartHeatmapColor(C, 0.25) = $FF9BE9A8, 'GitHub level one');
    Check(ChartHeatmapColor(C, 0.5) = $FF40C463, 'GitHub level two'); Check(ChartHeatmapColor(C, 0.75) = $FF30A14E, 'GitHub level three');
    Check(ChartHeatmapColor(C, 1) = $FF216E39, 'GitHub level four');
    Items := Basic.Primitives(C); Found := False;
    for A in Items do if (A.Kind = ncpRect) and (A.Hit.PointIndex = 2) then
    begin Check(A.Color = $FF40C463, 'Raster heatmap preset not applied'); Found := True end;
    Check(Found, 'Raster heatmap cell missing');
    Chart.ChartType := nctBusinessCalendarHeatmap; Items := Business.Primitives(C); Found := False;
    for A in Items do if (A.Kind = ncpRect) and (A.Hit.PointIndex = 2) then
    begin Check(A.Color = $FF40C463, 'Calendar heatmap preset not applied'); Found := True end;
    Check(Found, 'Calendar heatmap cell missing');
    Chart.Model.HeatmapColorPreset := nhcpReds; Check(ChartHeatmapColor(C, 1) = $FF67000D, 'Red heatmap endpoint');
    Chart.Model.HeatmapColorPreset := nhcpThermal; Check(ChartHeatmapColor(C, 1) = $FFFF0000, 'Thermal endpoint');
    Chart.Model.HeatmapColorPreset := nhcpCustom; Chart.Model.HeatmapLowColor := clBlue; Chart.Model.HeatmapHighColor := clRed;
    Check(ChartHeatmapColor(C, 0) = $FF0000FF, 'Custom low'); Check(ChartHeatmapColor(C, 1) = $FFFF0000, 'Custom high');
    ModelCopy.Assign(Chart.Model); Check(ModelCopy.HeatmapColorPreset = nhcpCustom, 'Heat preset cloning');
    Check((ModelCopy.Options.MapColorMode = ncmCategorical) and (ModelCopy.Options.MapEmptyColor = RGB(220, 220, 220)), 'Map options cloning');
    Check(not Chart.HandleAllocated, 'Map and heatmap primitives created HWND');
  finally ModelCopy.Free; Business.Free; Basic.Free; Map.Free; Chart.Free end;
end;

begin
  try
    Application.Initialize;
    Run; RunChartTests; RunBusinessTests; RunRadialGoalTests; RunPortfolioTests; RunWaterfallTests; RunKpiTileTests; RunParetoTests; RunStackTests; RunColorTests; RunKpiTests; RunViolinTests; RunRidgelineTests; RunStreamGraphTests; RunTreemapTests; RunSunburstTests;
    RunNimbusMiniChartChecks;
    RunAppearanceTests;
    RunNimbusChartFunctionChecks;
    RunNimbusFinancialChecks;
    RunMapHeatPaletteTests;
    Writeln('PASS: chart geometry, axis transformations, DPI hit testing, all implemented styles, export, lifecycle and streaming');
  except
    on E: Exception do begin Writeln(E.ClassName + ': ' + E.Message); Halt(1) end;
  end;
end.

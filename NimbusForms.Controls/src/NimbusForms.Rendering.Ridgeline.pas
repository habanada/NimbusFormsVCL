{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.Ridgeline;

interface

uses System.Types, NimbusForms.Rendering.Charts, NimbusForms.Charts.Types, NimbusForms.Charts.Ridgeline.Types;

type
  TNimbusRidgelineChartRenderer = class(TNimbusChartRenderer)
  protected
    function Build(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>; override;
  public
    function CanRender(const AType: TNimbusChartType): Boolean; override;
    function Arrange(const C: TNimbusChartRenderContext): TNimbusChartLayout; override;
    function HitTest(const C: TNimbusChartRenderContext; const Location: TPointF): TNimbusChartHit; override;
    function GetRidges(const C: TNimbusChartRenderContext; const Plot: TRect): TArray<TNimbusRidgelineRidgeInfo>;
    function MaximumPointIndex(Model: TNimbusChartModel): Integer;
    function HasZoom(Model: TNimbusChartModel): Boolean;
    function NearestPointIndex(const C: TNimbusChartRenderContext; const Location: TPointF): Integer;
  end;

implementation

uses System.SysUtils, System.Math, System.Generics.Collections, Vcl.Graphics, NimbusForms.Rendering.Types,
  NimbusForms.Theming.Types, NimbusForms.Charts.Sparkline.Types;

function TNimbusRidgelineChartRenderer.CanRender(const AType: TNimbusChartType): Boolean;
begin Result := AType = nctRidgeline end;

function TNimbusRidgelineChartRenderer.MaximumPointIndex(Model: TNimbusChartModel): Integer;
var I: Integer;
begin Result := -1; if Model = nil then Exit; for I := 0 to Model.Series.Count - 1 do Result := Max(Result, Model.Series[I].Points.Count - 1) end;

function TNimbusRidgelineChartRenderer.HasZoom(Model: TNimbusChartModel): Boolean;
var Maximum: Integer; Options: TNimbusRidgelineOptions;
begin
  Maximum := MaximumPointIndex(Model); Result := False; if Model = nil then Exit; Options := Model.RidgelineOptions;
  Result := (Maximum > 0) and (Options.ZoomStartIndex >= 0) and (Options.ZoomEndIndex > Options.ZoomStartIndex) and (Options.ZoomEndIndex <= Maximum);
end;

function TNimbusRidgelineChartRenderer.Arrange(const C: TNimbusChartRenderContext): TNimbusChartLayout;
var DPI, Top, Bottom: Double; O: TNimbusRidgelineOptions;
begin
  Result := Default(TNimbusChartLayout); Result.Bounds := C.Bounds; if C.Model = nil then Exit;
  DPI := Max(1, C.PPI) / 96; O := C.Model.RidgelineOptions; Top := 18 * DPI; Bottom := 20 * DPI;
  if C.Model.Options.ShowTitle and (C.Model.Title <> '') then
  begin Result.TitleBounds := Rect(C.Bounds.Left + Round(24 * DPI), C.Bounds.Top + Round(12 * DPI), C.Bounds.Right - Round(24 * DPI), C.Bounds.Top + Round(36 * DPI)); Top := Top + 28 * DPI end;
  if C.Model.Options.ShowSubtitle and (C.Model.Subtitle <> '') then
  begin Result.SubtitleBounds := Rect(C.Bounds.Left + Round(24 * DPI), C.Bounds.Top + Round(Top), C.Bounds.Right - Round(24 * DPI), C.Bounds.Top + Round(Top + 18 * DPI)); Top := Top + 18 * DPI end;
  if O.ShowXAxis then Bottom := Bottom + O.AxisHeight * DPI; if O.ShowZoomNavigator then Bottom := Bottom + 20 * DPI;
  Result.PlotArea := Rect(C.Bounds.Left + Round(92 * DPI), C.Bounds.Top + Round(Top), C.Bounds.Right - Round(26 * DPI), C.Bounds.Bottom - Round(Bottom));
  Result.PlotArea.Right := Max(Result.PlotArea.Left, Result.PlotArea.Right); Result.PlotArea.Bottom := Max(Result.PlotArea.Top, Result.PlotArea.Bottom);
  Result.XAxisBounds := Rect(Result.PlotArea.Left, Result.PlotArea.Bottom, Result.PlotArea.Right, Result.PlotArea.Bottom + Round(O.AxisHeight * DPI));
  Result.XRange := TNimbusChartRange.Create(0, Max(1, MaximumPointIndex(C.Model))); Result.YRange := TNimbusChartRange.Create(0, 1);
  if HasZoom(C.Model) then Result.XRange := TNimbusChartRange.Create(O.ZoomStartIndex, O.ZoomEndIndex);
end;

function TNimbusRidgelineChartRenderer.NearestPointIndex(const C: TNimbusChartRenderContext; const Location: TPointF): Integer;
var L: TNimbusChartLayout; Maximum, First, Last: Integer; Ratio: Double;
begin
  Result := -1; Maximum := MaximumPointIndex(C.Model); if Maximum < 0 then Exit;
  L := Arrange(C); if L.PlotArea.Width <= 1 then Exit; Ratio := EnsureRange((Location.X - L.PlotArea.Left) / L.PlotArea.Width, 0.0, 1.0);
  First := 0; Last := Maximum; if HasZoom(C.Model) then begin First := C.Model.RidgelineOptions.ZoomStartIndex; Last := C.Model.RidgelineOptions.ZoomEndIndex end;
  Result := EnsureRange(First + Round(Ratio * (Last - First)), 0, Maximum);
end;

function TNimbusRidgelineChartRenderer.GetRidges(const C: TNimbusChartRenderContext; const Plot: TRect): TArray<TNimbusRidgelineRidgeInfo>;
var M: TNimbusChartModel; O: TNimbusRidgelineOptions; Series: TNimbusChartSeries; Point: TNimbusChartPoint;
  Indices: TArray<Integer>; Data: TSparklineValues; Ridge: TNimbusRidgelineRidgeInfo; Info: TNimbusRidgelinePointInfo; Top: TArray<TPointF>;
  I, J, K, Index, First, Last, Count, Compare: Integer;
  GlobalMax, LocalMax, Total, Weighted, Value, DPI, Height, Step, Required, Baseline, Y, ScaleMax, Normalized: Double;
  Back: TThemeColor;
  function Summaries(const SI, Start, Finish: Integer; out Sum, Peak, Mean, Median: Double): Boolean;
  var P: TNimbusChartPoint; PI, N: Integer; V, Weight: Double; XValues: TSparklineValues;
  begin
    Sum := 0; Peak := 0; Mean := 0; Median := 0; Weight := 0; N := 0; XValues := nil;
    for PI := Start to Min(Finish, M.Series[SI].Points.Count - 1) do
    begin
      P := M.Series[SI].Points[PI]; if not P.Visible or not SparklineFinite(P.YValue) then Continue;
      V := Max(0.0, P.YValue); Sum := Sum + V; Peak := Max(Peak, V);
      if SparklineFinite(P.XValue) then begin Weight := Weight + V * P.XValue; SetLength(XValues, N + 1); XValues[N] := P.XValue; Inc(N) end;
    end;
    if Sum > 0 then Mean := Weight / Sum; if N > 0 then begin TArray.Sort<Double>(XValues); Median := XValues[N div 2] end; Result := N > 0;
  end;
  function CompareSeries(const A, B: Integer): Integer;
  var TA, TB, PA, PB, MA, MB, DA, DB: Double;
  begin
    Result := 0;
    if O.SortMode in [nroNameAscending, nroNameDescending] then Result := CompareText(M.Series[A].Name, M.Series[B].Name)
    else
    begin
      Summaries(A, 0, M.Series[A].Points.Count - 1, TA, PA, MA, DA); Summaries(B, 0, M.Series[B].Points.Count - 1, TB, PB, MB, DB);
      if O.SortMode in [nroPeakAscending, nroPeakDescending] then begin TA := PA; TB := PB end;
      if TA < TB then Result := -1 else if TA > TB then Result := 1;
    end;
    if O.SortMode in [nroNameDescending, nroPeakDescending, nroTotalDescending] then Result := -Result;
  end;
  function Color(const AColor: TColor; const Fallback: TThemeColor): TThemeColor;
  begin
    Result := Fallback; if AColor <> clNone then begin Result := ColorToThemeColor(AColor); if C.ColorInfluence > 0 then Result := NimbusBlendColor(Result, Fallback, Round(EnsureRange(C.ColorInfluence, 0, 100) * 255 / 100)) end;
    if not C.Enabled then Result := NimbusBlendColor(Result, Back, 160);
  end;
begin
  Result := nil; M := C.Model; if (M = nil) or Plot.IsEmpty then Exit; O := M.RidgelineOptions; Indices := nil; Back := ChartBackColor(C); DPI := Max(1, C.PPI) / 96;
  for I := 0 to M.Series.Count - 1 do
    if M.Series[I].Visible and (M.Series[I].Points.Count > 0) then begin Count := Length(Indices); SetLength(Indices, Count + 1); Indices[Count] := I end;
  if O.SortMode <> nroNone then
    for I := 1 to High(Indices) do
    begin Index := Indices[I]; J := I - 1; while J >= 0 do begin Compare := CompareSeries(Indices[J], Index); if Compare <= 0 then Break; Indices[J + 1] := Indices[J]; Dec(J) end; Indices[J + 1] := Index end;
  First := 0; Last := MaximumPointIndex(M); if HasZoom(M) then begin First := O.ZoomStartIndex; Last := O.ZoomEndIndex end;
  if Last < 0 then Exit; GlobalMax := 0;
  for I in Indices do begin Summaries(I, First, Last, Total, LocalMax, Weighted, Value); GlobalMax := Max(GlobalMax, LocalMax) end; if GlobalMax <= 0 then GlobalMax := 1;
  Height := O.RidgeHeight * DPI; Step := Height * (1 - O.Overlap); Required := Height + Max(0, Length(Indices) - 1) * Step;
  if Required > Plot.Height then begin Height := Height * Plot.Height / Max(1.0, Required); Step := Height * (1 - O.Overlap); Required := Plot.Height end;
  Y := Plot.Bottom - Max(0.0, (Plot.Height - Required) / 2); SetLength(Result, Length(Indices));
  for I := 0 to High(Indices) do
  begin
    Series := M.Series[Indices[I]]; Ridge := Default(TNimbusRidgelineRidgeInfo); Ridge.SeriesIndex := Indices[I]; Ridge.SeriesName := Series.Name;
    if Ridge.SeriesName = '' then Ridge.SeriesName := 'Series ' + IntToStr(Ridge.SeriesIndex + 1);
    Ridge.Bounds := Rect(Plot.Left, Round(Y - Height), Plot.Right, Round(Y)); Ridge.HitBounds := Ridge.Bounds; Ridge.HitBounds.Inflate(0, -Round(3 * DPI));
    Summaries(Ridge.SeriesIndex, First, Last, Ridge.Total, Ridge.Peak, Ridge.Mean, Ridge.Median);
    Ridge.Color := ChartAccentColor(C); if C.ChartPalette <> nil then Ridge.Color := ColorToThemeColor(C.ChartPalette.GetSeriesColor(Ridge.SeriesIndex)); Ridge.Color := Color(Series.Color, Ridge.Color);
    ScaleMax := GlobalMax; if O.ScaleMode = nrsPerRidge then ScaleMax := Ridge.Peak; if ScaleMax <= 0 then ScaleMax := 1; Baseline := Y - 3 * DPI;
    Count := Last - First + 1; SetLength(Ridge.Points, Count); SetLength(Top, Count);
    for J := 0 to Count - 1 do
    begin
      K := First + J; Point := nil; if K < Series.Points.Count then Point := Series.Points[K]; Value := 0;
      if (Point <> nil) and Point.Visible and SparklineFinite(Point.YValue) then Value := Max(0.0, Point.YValue);
      Normalized := Value / ScaleMax; if (O.ScaleMode = nrsPercent) and (Ridge.Total > 0) then Normalized := Value / Ridge.Total;
      Normalized := Max(0.0, Normalized); if O.ScaleMode <> nrsPercent then Normalized := Min(1.0, Normalized);
      Info := Default(TNimbusRidgelinePointInfo); Info.SeriesIndex := Ridge.SeriesIndex; Info.PointIndex := K; Info.SeriesName := Ridge.SeriesName;
      Info.XValue := K; Info.YValue := Value; Info.NormalizedValue := Normalized; Info.LabelText := IntToStr(K); Info.Color := Ridge.Color;
      if Point <> nil then begin if SparklineFinite(Point.XValue) then Info.XValue := Point.XValue; if Point.&Label <> '' then Info.LabelText := Point.&Label; Info.Color := Color(Point.Color, Ridge.Color); Info.ToolTipText := Point.ToolTipText end;
      Info.Location := TPointF.Create(Plot.Left + Plot.Width * J / Max(1, Count - 1), Baseline - Normalized * Max(0.0, Height - 10 * DPI));
      if Count = 1 then Info.Location.X := Plot.CenterPoint.X;
      Info.Bounds := Rect(Round(Info.Location.X - 12 * DPI), Round(Info.Location.Y - 16 * DPI), Round(Info.Location.X + 12 * DPI), Round(Baseline + 22 * DPI));
      Ridge.Points[J] := Info; Top[J] := Info.Location;
    end;
    Ridge.Outline := NimbusRidgelineCurve(Top, O.CurveMode); Ridge.Polygon := Copy(Ridge.Outline); SetLength(Ridge.Polygon, Length(Ridge.Outline) + 2);
    Ridge.Polygon[Length(Ridge.Outline)] := TPointF.Create(Top[High(Top)].X, Baseline); Ridge.Polygon[High(Ridge.Polygon)] := TPointF.Create(Top[0].X, Baseline);
    Result[I] := Ridge; Y := Y - Step;
  end;
end;

function TNimbusRidgelineChartRenderer.HitTest(const C: TNimbusChartRenderContext; const Location: TPointF): TNimbusChartHit;
var Ridges: TArray<TNimbusRidgelineRidgeInfo>; Ridge: TNimbusRidgelineRidgeInfo; PointInfo: TNimbusRidgelinePointInfo;
  BestRidge, BestPoint, I, J: Integer; Distance, BestDistance: Double; Options: TNimbusRidgelineOptions; Layout: TNimbusChartLayout;
begin
  Result := TNimbusChartHit.None; Result.Location := Location; if C.Model = nil then Exit; Options := C.Model.RidgelineOptions;
  Layout := Arrange(C); Ridges := GetRidges(C, Layout.PlotArea); BestRidge := -1; BestPoint := -1; BestDistance := MaxDouble;
  for I := 0 to High(Ridges) do
  begin
    if not Ridges[I].HitBounds.Contains(Point(Round(Location.X), Round(Location.Y))) then Continue;
    if BestRidge < 0 then BestRidge := I;
    for J := 0 to High(Ridges[I].Points) do
      if Ridges[I].Points[J].Bounds.Contains(Point(Round(Location.X), Round(Location.Y))) then
      begin
        Distance := Sqr(Ridges[I].Points[J].Location.X - Location.X) + Sqr(Ridges[I].Points[J].Location.Y - Location.Y);
        if Distance < BestDistance then begin BestDistance := Distance; BestRidge := I; BestPoint := J end;
      end;
  end;
  if BestRidge < 0 then Exit; Ridge := Ridges[BestRidge]; Result.Area := nchaSeries; Result.SeriesIndex := Ridge.SeriesIndex;
  Result.Text := Ridge.SeriesName + sLineBreak + 'Total: ' + SparklineFormatValue(Ridge.Total, Options.ValueFormat) + sLineBreak + 'Peak: ' + SparklineFormatValue(Ridge.Peak, Options.ValueFormat);
  if BestPoint >= 0 then
  begin
    PointInfo := Ridge.Points[BestPoint]; Result.Area := nchaPoint; Result.PointIndex := PointInfo.PointIndex; Result.XValue := PointInfo.XValue; Result.YValue := PointInfo.YValue;
    Result.Text := PointInfo.ToolTipText;
    if Result.Text = '' then Result.Text := Ridge.SeriesName + sLineBreak + PointInfo.LabelText + ': ' + SparklineFormatValue(PointInfo.YValue, Options.ValueFormat)
      + sLineBreak + 'Share: ' + SparklineFormatValue(PointInfo.NormalizedValue * 100, StringReplace(Options.PercentFormat, '%', '', [rfReplaceAll])) + '%';
  end;
end;

function TNimbusRidgelineChartRenderer.Build(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>;
var Ridges: TArray<TNimbusRidgelineRidgeInfo>; Ridge: TNimbusRidgelineRidgeInfo; Info, Peak: TNimbusRidgelinePointInfo;
  O: TNimbusRidgelineOptions; A: TNimbusChartPrimitive; Fore, Back, Color, LineColor: TThemeColor;
  I, J, First, Last, Maximum, LabelStep, N: Integer; DPI, X, Y, MarkerX, Baseline, Span: Double; Selected, Faded: Boolean;
  function B(const X1, Y1, X2, Y2: Double): TRect;
  begin Result := Rect(Round(X1), Round(Y1), Round(Max(X1, X2)), Round(Max(Y1, Y2))) end;
  procedure Primitive(const Kind: TNimbusChartPrimitiveKind; const Col: TThemeColor);
  begin A := Default(TNimbusChartPrimitive); A.Kind := Kind; A.Color := Col; A.Width := DPI; A.Hit := TNimbusChartHit.None; A.UseCornerRadius := True end;
  procedure Add;
  var Count: Integer;
  begin Count := Length(Result); SetLength(Result, Count + 1); Result[Count] := A end;
  procedure Text(const Value: string; const Bounds: TRect; const RightAligned: Boolean = False);
  begin
    Primitive(ncpText, NimbusColorWithAlpha(Fore, 200)); A.Text := Value; A.Bounds := Bounds;
    A.TextFlags := [ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix]; if RightAligned then Include(A.TextFlags, ntfRight); Add;
  end;
  procedure Line(const X1, Y1, X2, Y2: Double; const Col: TThemeColor);
  begin Primitive(ncpLine, Col); A.Points := [TPointF.Create(X1, Y1), TPointF.Create(X2, Y2)]; Add end;
  procedure Marker(const Value: Double; const Col: TThemeColor);
  var MinValue, MaxValue: Double;
  begin
    MinValue := Ridge.Points[0].XValue; MaxValue := Ridge.Points[High(Ridge.Points)].XValue;
    MarkerX := Ridge.Bounds.CenterPoint.X; if MaxValue > MinValue then MarkerX := Ridge.Bounds.Left + (Value - MinValue) / (MaxValue - MinValue) * Ridge.Bounds.Width;
    if (MarkerX >= Ridge.Bounds.Left) and (MarkerX <= Ridge.Bounds.Right) then Line(MarkerX, Ridge.Bounds.Bottom - 2 * DPI, MarkerX, Ridge.Bounds.Top + 8 * DPI, Col);
  end;
begin
  Result := nil; if (C.Model = nil) or (C.Font = nil) then Exit; O := C.Model.RidgelineOptions; DPI := Max(1, C.PPI) / 96; Fore := ChartForeColor(C); Back := ChartBackColor(C);
  if not L.TitleBounds.IsEmpty then Text(C.Model.Title, L.TitleBounds); if not L.SubtitleBounds.IsEmpty then Text(C.Model.Subtitle, L.SubtitleBounds);
  if L.PlotArea.IsEmpty then Exit; Ridges := GetRidges(C, L.PlotArea);
  if O.ShowGrid then for I := 0 to 5 do begin X := L.PlotArea.Left + L.PlotArea.Width * I / 5; Line(X, L.PlotArea.Top, X, L.PlotArea.Bottom, NimbusColorWithAlpha(Fore, 22)) end;
  for I := High(Ridges) downto 0 do
  begin
    Ridge := Ridges[I]; Selected := O.SelectedSeriesIndex = Ridge.SeriesIndex; Faded := (O.SelectedSeriesIndex >= 0) and not Selected;
    if C.Selected.SeriesIndex = Ridge.SeriesIndex then Selected := True;
    Color := Ridge.Color; if Faded then Color := NimbusBlendColor(Color, Back, 166);
    Primitive(ncpPolygon, NimbusColorWithAlpha(Color, Trunc(255 * O.FillOpacity))); if Faded then A.Color := NimbusColorWithAlpha(Color, 76);
    A.Points := Copy(Ridge.Polygon); Add; LineColor := NimbusColorWithAlpha(Color, 220); if Selected then LineColor := NimbusBlendColor(Color, $FFFFFFFF, 71);
    Primitive(ncpLine, LineColor); A.Points := Copy(Ridge.Polygon); SetLength(A.Points, Length(Ridge.Polygon) + 1); A.Points[High(A.Points)] := Ridge.Polygon[0]; A.Width := O.LineWidth * DPI; if Selected then A.Width := A.Width + 1.4 * DPI; Add;
    Primitive(ncpRect, $16FFFFFF); A.Bounds := B(Ridge.Bounds.Left, Ridge.Bounds.Top, Ridge.Bounds.Right, Ridge.Bounds.Top + Max(2 * DPI, Ridge.Bounds.Height * 0.32)); A.UseCornerRadius := True; A.CornerRadius := 6 * DPI; Add;
    if O.ShowMeanMarker then Marker(Ridge.Mean, NimbusColorWithAlpha(Fore, 120)); if O.ShowMedianMarker then Marker(Ridge.Median, NimbusColorWithAlpha(Fore, 150));
    Peak := Ridge.Points[0]; for Info in Ridge.Points do if Info.YValue > Peak.YValue then Peak := Info;
    if O.ShowPeakMarker then
    begin
      Primitive(ncpEllipse, NimbusBlendColor(Peak.Color, $FFFFFFFF, 46)); A.Bounds := B(Peak.Location.X - O.MarkerSize * DPI / 2, Peak.Location.Y - O.MarkerSize * DPI / 2, Peak.Location.X + O.MarkerSize * DPI / 2, Peak.Location.Y + O.MarkerSize * DPI / 2); Add;
      A.Kind := ncpOutlineEllipse; A.Color := $BEFFFFFF; Add;
    end;
    if O.ShowRidgeLabels then Text(Ridge.SeriesName, B(C.Bounds.Left + 8 * DPI, Ridge.Bounds.Bottom - 24 * DPI, L.PlotArea.Left - 6 * DPI, Ridge.Bounds.Bottom - 2 * DPI), True);
    if O.ShowEndLabels then begin Info := Ridge.Points[High(Ridge.Points)]; Text(SparklineFormatValue(Info.YValue, O.ValueFormat), B(L.PlotArea.Right + 5 * DPI, Info.Location.Y - 10 * DPI, C.Bounds.Right - 2 * DPI, Info.Location.Y + 10 * DPI)) end;
    Primitive(ncpHitBounds, 0); A.Bounds := Ridge.HitBounds; A.Hit.Area := nchaSeries; A.Hit.SeriesIndex := Ridge.SeriesIndex; A.Hit.Text := Ridge.SeriesName; Add;
  end;
  Maximum := MaximumPointIndex(C.Model); First := 0; Last := Maximum;
  if HasZoom(C.Model) then begin First := O.ZoomStartIndex; Last := O.ZoomEndIndex end;
  LabelStep := Max(1, Ceil((Last - First + 1) / 8));
  if O.ShowXAxis and (Maximum >= 0) then
  begin
    Line(L.PlotArea.Left, L.PlotArea.Bottom, L.PlotArea.Right, L.PlotArea.Bottom, NimbusColorWithAlpha(Fore, 70)); I := First;
    while I <= Last do
    begin
      X := L.PlotArea.CenterPoint.X; if Last > First then X := L.PlotArea.Left + L.PlotArea.Width * (I - First) / (Last - First);
      Line(X, L.PlotArea.Bottom, X, L.PlotArea.Bottom + 4 * DPI, NimbusColorWithAlpha(Fore, 70));
      for J := 0 to C.Model.Series.Count - 1 do if I < C.Model.Series[J].Points.Count then begin Text(C.Model.Series[J].Points[I].&Label, B(X - 34 * DPI, L.PlotArea.Bottom + 5 * DPI, X + 34 * DPI, L.PlotArea.Bottom + 23 * DPI)); Break end;
      Inc(I, LabelStep);
    end;
  end;
  if O.ShowZoomNavigator then
  begin
    Primitive(ncpRect, NimbusColorWithAlpha(Fore, 28)); A.Bounds := B(L.PlotArea.Left, L.PlotArea.Bottom + 28 * DPI, L.PlotArea.Right, L.PlotArea.Bottom + 37 * DPI); Add;
    if HasZoom(C.Model) then
    begin
      Primitive(ncpRect, NimbusColorWithAlpha(ChartAccentColor(C), 140)); A.Bounds := B(L.PlotArea.Left + L.PlotArea.Width * First / Maximum, L.PlotArea.Bottom + 26 * DPI, L.PlotArea.Left + L.PlotArea.Width * Last / Maximum, L.PlotArea.Bottom + 39 * DPI); Add;
    end;
  end;
  if O.ShowZoomBadge and HasZoom(C.Model) then Text('Zoom ' + IntToStr(First + 1) + '-' + IntToStr(Last + 1), B(L.PlotArea.Right - 116 * DPI, L.PlotArea.Top + 6 * DPI, L.PlotArea.Right - 8 * DPI, L.PlotArea.Top + 28 * DPI));
  if Length(Ridges) = 0 then Text('No ridgeline data', L.PlotArea);
end;

end.

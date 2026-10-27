{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.StreamGraph;

interface

uses System.Types, NimbusForms.Rendering.Charts, NimbusForms.Charts.Types, NimbusForms.Charts.StreamGraph.Types;

type
  TNimbusStreamGraphChartRenderer = class(TNimbusChartRenderer)
  private
    FRangePreview: Boolean;
    FPreviewLeft, FPreviewRight: Single;
  protected
    function Build(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>; override;
  public
    function CanRender(const AType: TNimbusChartType): Boolean; override;
    function Arrange(const C: TNimbusChartRenderContext): TNimbusChartLayout; override;
    function HitTest(const C: TNimbusChartRenderContext; const Location: TPointF): TNimbusChartHit; override;
    function Categories(Model: TNimbusChartModel): TArray<string>;
    function GetGeometry(const C: TNimbusChartRenderContext; const Plot: TRect): TNimbusStreamGeometry;
    function NearestCategory(const C: TNimbusChartRenderContext; const X: Single): Integer;
    procedure SetRangePreview(const Visible: Boolean; const Left, Right: Single);
  end;

implementation

uses System.SysUtils, System.Math, System.Generics.Collections, Vcl.Graphics, NimbusForms.Rendering.Types,
  NimbusForms.Theming.Types, NimbusForms.Charts.Sparkline.Types;

function CategoryName(Point: TNimbusChartPoint; Index: Integer): string;
begin Result := Point.&Label; if Result = '' then Result := IntToStr(Index) end;

function StreamCurve(const Points: TArray<TPointF>; const Mode: TNimbusStreamCurveMode; Tension: Single): TArray<TPointF>;
var I, J, N: Integer; P0, P1, P2, P3, A, B: TPointF; T, U, X: Double;
  procedure Add(const P: TPointF);
  var Count: Integer;
  begin Count := Length(Result); SetLength(Result, Count + 1); Result[Count] := P end;
begin
  Result := nil; N := Length(Points); if (Mode = nscLinear) or (N < 2) or ((Mode = nscSmooth) and (N < 3)) then Exit(Copy(Points)); Add(Points[0]);
  for I := 0 to N - 2 do
  begin
    P1 := Points[I]; P2 := Points[I + 1];
    if Mode = nscStep then
    begin X := (P1.X + P2.X) / 2; Add(TPointF.Create(X, P1.Y)); Add(TPointF.Create(X, P2.Y)); Add(P2) end
    else
    begin
      P0 := Points[Max(0, I - 1)]; P3 := Points[Min(N - 1, I + 2)];
      A := TPointF.Create(P1.X + (P2.X - P0.X) * Tension / 6, P1.Y + (P2.Y - P0.Y) * Tension / 6);
      B := TPointF.Create(P2.X - (P3.X - P1.X) * Tension / 6, P2.Y - (P3.Y - P1.Y) * Tension / 6);
      for J := 1 to 12 do
      begin T := J / 12; U := 1 - T; Add(TPointF.Create(U * U * U * P1.X + 3 * U * U * T * A.X + 3 * U * T * T * B.X + T * T * T * P2.X,
        U * U * U * P1.Y + 3 * U * U * T * A.Y + 3 * U * T * T * B.Y + T * T * T * P2.Y)) end;
    end;
  end;
end;

function ContainsPolygon(const Points: TArray<TPointF>; const P: TPointF): Boolean;
var I, J: Integer; A, B: TPointF;
begin
  Result := False; J := High(Points);
  for I := 0 to High(Points) do
  begin A := Points[I]; B := Points[J]; if (A.Y > P.Y) <> (B.Y > P.Y) then
    if P.X < (B.X - A.X) * (P.Y - A.Y) / (B.Y - A.Y) + A.X then Result := not Result; J := I end;
end;

function TNimbusStreamGraphChartRenderer.CanRender(const AType: TNimbusChartType): Boolean;
begin Result := AType = nctStreamGraph end;

procedure TNimbusStreamGraphChartRenderer.SetRangePreview(const Visible: Boolean; const Left, Right: Single);
begin FRangePreview := Visible; FPreviewLeft := Min(Left, Right); FPreviewRight := Max(Left, Right) end;

function TNimbusStreamGraphChartRenderer.Categories(Model: TNimbusChartModel): TArray<string>;
var Names: TList<string>; I, J, K: Integer; Name, V: string; X, Y: Double;
  function Compare(const A, B: string): Integer;
  begin
    if TryStrToFloat(A, X) and TryStrToFloat(B, Y) then begin if X < Y then Result := -1 else if X > Y then Result := 1 else Result := 0 end
    else Result := CompareText(A, B);
  end;
begin
  Result := nil; if Model = nil then Exit; Names := TList<string>.Create;
  try
    for I := 0 to Model.Series.Count - 1 do if Model.Series[I].Visible then
      for J := 0 to Model.Series[I].Points.Count - 1 do begin Name := CategoryName(Model.Series[I].Points[J], J); if not Names.Contains(Name) then Names.Add(Name) end;
    Result := Names.ToArray;
  finally Names.Free end;
  for I := 1 to High(Result) do begin V := Result[I]; K := I - 1; while K >= 0 do begin if Compare(Result[K], V) <= 0 then Break; Result[K + 1] := Result[K]; Dec(K) end; Result[K + 1] := V end;
end;

function TNimbusStreamGraphChartRenderer.Arrange(const C: TNimbusChartRenderContext): TNimbusChartLayout;
var O: TNimbusStreamGraphOptions; DPI: Double; Pad, Top, Bottom, Right, Width: Integer;
begin
  Result := Default(TNimbusChartLayout); Result.Bounds := C.Bounds; if C.Model = nil then Exit;
  O := C.Model.StreamGraphOptions; DPI := Max(1, C.PPI) / 96; Pad := Round(O.Padding * DPI); Top := C.Bounds.Top + Pad; Bottom := C.Bounds.Bottom - Pad; Right := C.Bounds.Right - Pad;
  if O.ShowTitle and C.Model.Options.ShowTitle and (C.Model.Title <> '') then begin Result.TitleBounds := Rect(C.Bounds.Left + Pad, Top, Right, Top + Round(28 * DPI)); Inc(Top, Round(32 * DPI)) end;
  if O.ShowSubtitle and C.Model.Options.ShowSubtitle and (C.Model.Subtitle <> '') then begin Result.SubtitleBounds := Rect(C.Bounds.Left + Pad, Top, Right, Top + Round(20 * DPI)); Inc(Top, Round(28 * DPI)) end;
  if O.ShowLegend and C.Model.Legend.Visible then begin Width := Round(Min(170 * DPI, Max(0, (Right - C.Bounds.Left - Pad) * 0.32))); Result.LegendBounds := Rect(Right - Width, Top, Right, Bottom); Dec(Right, Width + Round(14 * DPI)) end;
  if O.ShowAxes and O.ShowXLabels then Dec(Bottom, Round(30 * DPI));
  Result.PlotArea := Rect(C.Bounds.Left + Pad, Top, Max(C.Bounds.Left + Pad, Right), Max(Top, Bottom));
  Result.XAxisBounds := Rect(Result.PlotArea.Left, Bottom, Result.PlotArea.Right, Bottom + Round(30 * DPI));
  Result.XRange := TNimbusChartRange.Create(0, 1); Result.YRange := TNimbusChartRange.Create(0, 1);
end;

function TNimbusStreamGraphChartRenderer.GetGeometry(const C: TNimbusChartRenderContext; const Plot: TRect): TNimbusStreamGeometry;
var M: TNimbusChartModel; O: TNimbusStreamGraphOptions; S: TNimbusChartSeries; P: TNimbusChartPoint;
  Indices: TArray<Integer>; Raw, Values, Lower, Upper: TArray<TArray<Double>>; RawTotals: TArray<Double>;
  UpperPoints, LowerPoints, SheenLower: TArray<TPointF>; A, B: TArray<TPointF>; Band: TNimbusStreamBandGeometry; Info: TNimbusStreamBandInfo;
  I, J, K, SI, PI, Count, PointCount, CategoryIndex: Integer; Value, Running, Minimum, Maximum, DPI, X, Y1, Y2, Gap: Double;
  function FindPoint(Series: TNimbusChartSeries; const Category: string): Integer;
  var Index: Integer;
  begin Result := -1; for Index := 0 to Series.Points.Count - 1 do if SameText(CategoryName(Series.Points[Index], Index), Category) then Exit(Index) end;
  function MakePolygon(const Top, Bottom: TArray<TPointF>): TArray<TPointF>;
  var Index, N: Integer;
  begin N := Length(Top); SetLength(Result, N + Length(Bottom)); for Index := 0 to N - 1 do Result[Index] := Top[Index]; for Index := 0 to High(Bottom) do Result[N + Index] := Bottom[High(Bottom) - Index] end;
begin
  Result := Default(TNimbusStreamGeometry); M := C.Model; if (M = nil) or Plot.IsEmpty then Exit; O := M.StreamGraphOptions;
  Result.FullCategories := Categories(M); Count := Length(Result.FullCategories); if Count = 0 then Exit;
  Result.FirstIndex := 0; Result.LastIndex := Count - 1;
  if O.EnableRangeZoom and O.IsZoomed then begin Result.FirstIndex := EnsureRange(O.ZoomStartIndex, 0, Count - 1); Result.LastIndex := EnsureRange(O.ZoomEndIndex, Result.FirstIndex, Count - 1) end;
  PointCount := Result.LastIndex - Result.FirstIndex + 1; Result.Categories := Copy(Result.FullCategories, Result.FirstIndex, PointCount); Indices := nil;
  for I := 0 to M.Series.Count - 1 do if M.Series[I].Visible and (M.Series[I].Points.Count > 0) then begin J := Length(Indices); SetLength(Indices, J + 1); Indices[J] := I end;
  SetLength(Raw, Length(Indices)); SetLength(Values, Length(Indices)); SetLength(Lower, Length(Indices)); SetLength(Upper, Length(Indices));
  SetLength(RawTotals, PointCount); SetLength(Result.Totals, PointCount); SetLength(Result.Baseline, PointCount);
  for I := 0 to High(Indices) do
  begin
    SetLength(Raw[I], PointCount); SetLength(Values[I], PointCount); SetLength(Lower[I], PointCount); SetLength(Upper[I], PointCount); S := M.Series[Indices[I]];
    for J := 0 to PointCount - 1 do begin PI := FindPoint(S, Result.Categories[J]); Value := 0;
      if PI >= 0 then begin P := S.Points[PI]; if P.Visible and SparklineFinite(P.YValue) then Value := Max(0.0, P.YValue) end;
      Raw[I][J] := Value; Values[I][J] := Value; RawTotals[J] := RawTotals[J] + Value;
    end;
  end;
  for J := 0 to PointCount - 1 do
  begin
    Result.Totals[J] := RawTotals[J]; if O.NormalizeToPercent or (O.BaselineMode = nsbExpand100) then
    begin for I := 0 to High(Indices) do if RawTotals[J] > 0 then Values[I][J] := Values[I][J] / RawTotals[J]; if RawTotals[J] > 0 then Result.Totals[J] := 1 end;
    case O.BaselineMode of
      nsbZero: Result.Baseline[J] := 0;
      nsbWiggle: begin Result.Baseline[J] := -Result.Totals[J] / 2; if J > 0 then Result.Baseline[J] := Result.Baseline[J] + (Result.Totals[J - 1] - Result.Totals[J]) * 0.15 end;
    else Result.Baseline[J] := -Result.Totals[J] / 2 end;
  end;
  Minimum := Infinity; Maximum := NegInfinity;
  for J := 0 to PointCount - 1 do
  begin Running := Result.Baseline[J]; Minimum := Min(Minimum, Running);
    for I := 0 to High(Indices) do begin Lower[I][J] := Running; Running := Running + Values[I][J]; Upper[I][J] := Running; Maximum := Max(Maximum, Running) end;
  end;
  if not SparklineFinite(Minimum) or not SparklineFinite(Maximum) then Exit; if Maximum - Minimum < 0.0001 then Maximum := Minimum + 1;
  DPI := Max(1, C.PPI) / 96; Gap := O.BandGap * DPI; SetLength(Result.Bands, Length(Indices));
  for I := 0 to High(Indices) do
  begin
    SI := Indices[I]; S := M.Series[SI]; Band := Default(TNimbusStreamBandGeometry); Band.SeriesIndex := SI;
    Band.Color := ColorToThemeColor(M.Palette.GetSeriesColor(SI));
    if C.ChartPalette <> nil then Band.Color := ColorToThemeColor(C.ChartPalette.GetSeriesColor(SI));
    if S.Color <> clNone then begin Band.Color := ColorToThemeColor(S.Color); if (C.ColorInfluence > 0) and (C.ChartPalette <> nil) then Band.Color := NimbusBlendColor(Band.Color, ColorToThemeColor(C.ChartPalette.GetSeriesColor(SI)), Round(C.ColorInfluence * 255 / 100)) end;
    if not C.Enabled then Band.Color := NimbusBlendColor(Band.Color, ChartBackColor(C), 160);
    SetLength(Band.Samples, PointCount); SetLength(UpperPoints, PointCount); SetLength(LowerPoints, PointCount); SetLength(SheenLower, PointCount);
    for J := 0 to PointCount - 1 do
    begin
      CategoryIndex := Result.FirstIndex + J; PI := FindPoint(S, Result.Categories[J]);
      X := Plot.CenterPoint.X; if PointCount > 1 then X := Plot.Left + Plot.Width * J / (PointCount - 1);
      Y1 := Plot.Bottom - (Upper[I][J] - Minimum) / (Maximum - Minimum) * Plot.Height;
      Y2 := Plot.Bottom - (Lower[I][J] - Minimum) / (Maximum - Minimum) * Plot.Height;
      Value := Min(Gap / 2, Max(0.0, (Y2 - Y1) / 2 - 0.25 * DPI)); Y1 := Y1 + Value; Y2 := Y2 - Value;
      UpperPoints[J] := TPointF.Create(X, Y1); LowerPoints[J] := TPointF.Create(X, Y2); SheenLower[J] := TPointF.Create(X, Y1 + (Y2 - Y1) * 0.32);
      Info := Default(TNimbusStreamBandInfo); Info.SeriesIndex := SI; Info.PointIndex := PI; Info.CategoryIndex := CategoryIndex;
      Info.SeriesName := S.Name; Info.Category := Result.Categories[J]; Info.XValue := CategoryIndex; Info.Value := Values[I][J]; Info.RawValue := Raw[I][J];
      Info.Total := Result.Totals[J]; Info.RawTotal := RawTotals[J]; if Info.Total > 0 then Info.Share := Info.Value / Info.Total;
      Info.LowerValue := Lower[I][J]; Info.UpperValue := Upper[I][J]; Info.Color := Band.Color;
      Info.CenterPoint := TPointF.Create(X, (Y1 + Y2) / 2); Info.Bounds := Rect(Round(X - 14 * DPI), Floor(Y1), Round(X + 14 * DPI), Ceil(Y2));
      if PI >= 0 then begin P := S.Points[PI]; if SparklineFinite(P.XValue) then Info.XValue := P.XValue; Info.ToolTipText := P.ToolTipText; Info.Tag := P.Tag end;
      if Info.ToolTipText = '' then Info.ToolTipText := Info.Category + sLineBreak + S.Name + ': ' + SparklineFormatValue(Info.RawValue, O.ValueFormat)
        + sLineBreak + 'Share: ' + SparklineFormatValue(Info.Share * 100, StringReplace(O.PercentFormat, '%', '', [rfReplaceAll])) + '%'
        + sLineBreak + 'Total: ' + SparklineFormatValue(Info.RawTotal, O.ValueFormat);
      Band.Samples[J] := Info;
    end;
    if PointCount = 1 then
    begin
      Band.Polygon := [TPointF.Create(UpperPoints[0].X - 12 * DPI, UpperPoints[0].Y), TPointF.Create(UpperPoints[0].X + 12 * DPI, UpperPoints[0].Y),
        TPointF.Create(LowerPoints[0].X + 12 * DPI, LowerPoints[0].Y), TPointF.Create(LowerPoints[0].X - 12 * DPI, LowerPoints[0].Y)]; Band.Sheen := nil;
    end
    else begin A := StreamCurve(UpperPoints, O.CurveMode, O.SmoothTension); B := StreamCurve(LowerPoints, O.CurveMode, O.SmoothTension); Band.Polygon := MakePolygon(A, B);
      B := StreamCurve(SheenLower, O.CurveMode, O.SmoothTension); Band.Sheen := MakePolygon(A, B) end;
    Band.Outline := Copy(Band.Polygon); SetLength(Band.Outline, Length(Band.Polygon) + 1); Band.Outline[High(Band.Outline)] := Band.Polygon[0]; Result.Bands[I] := Band;
  end;
end;

function TNimbusStreamGraphChartRenderer.NearestCategory(const C: TNimbusChartRenderContext; const X: Single): Integer;
var Layout: TNimbusChartLayout; G: TNimbusStreamGeometry; Ratio: Double;
begin
  Layout := Arrange(C); G := GetGeometry(C, Layout.PlotArea); Result := -1; if Length(G.Categories) = 0 then Exit;
  Ratio := EnsureRange((X - Layout.PlotArea.Left) / Max(1, Layout.PlotArea.Width), 0.0, 1.0); Result := G.FirstIndex + Round(Ratio * (G.LastIndex - G.FirstIndex));
end;

function TNimbusStreamGraphChartRenderer.HitTest(const C: TNimbusChartRenderContext; const Location: TPointF): TNimbusChartHit;
var L: TNimbusChartLayout; G: TNimbusStreamGeometry; Info: TNimbusStreamBandInfo; I, J: Integer;
begin
  Result := TNimbusChartHit.None; Result.Location := Location; if C.Model = nil then Exit; L := Arrange(C);
  if not L.PlotArea.Contains(Point(Floor(Location.X), Floor(Location.Y))) then Exit(inherited HitTest(C, Location)); G := GetGeometry(C, L.PlotArea);
  for I := High(G.Bands) downto 0 do if ContainsPolygon(G.Bands[I].Polygon, Location) then
  begin
    J := 0; if Length(G.Categories) > 1 then J := EnsureRange(Round((Location.X - L.PlotArea.Left) / Max(1, L.PlotArea.Width) * (Length(G.Categories) - 1)), 0, High(G.Categories));
    Info := G.Bands[I].Samples[J]; Result.Area := nchaSegment; Result.SeriesIndex := Info.SeriesIndex; Result.PointIndex := Info.PointIndex;
    Result.ElementIndex := Info.CategoryIndex; Result.XValue := Info.XValue; Result.YValue := Info.RawValue; Result.Text := Info.ToolTipText; Exit;
  end;
  Result.Area := nchaPlotArea;
end;

function TNimbusStreamGraphChartRenderer.Build(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>;
var G: TNimbusStreamGeometry; Band: TNimbusStreamBandGeometry; Info: TNimbusStreamBandInfo; O: TNimbusStreamGraphOptions; A: TNimbusChartPrimitive;
  Fore, Color: TThemeColor; I, J, PeakIndex, Step, N: Integer; DPI, X, Y, Opacity, Maximum: Double; Hovered, Selected, Focused, Clip: Boolean;
  function B(const X1, Y1, X2, Y2: Double): TRect;
  begin Result := Rect(Round(X1), Round(Y1), Round(Max(X1, X2)), Round(Max(Y1, Y2))) end;
  procedure Init(const Kind: TNimbusChartPrimitiveKind; const Col: TThemeColor);
  begin A := Default(TNimbusChartPrimitive); A.Kind := Kind; A.Color := Col; A.Width := DPI; A.Hit := TNimbusChartHit.None; A.UseCornerRadius := True; A.UseClip := Clip; A.ClipBounds := L.PlotArea end;
  procedure Add;
  var Count: Integer;
  begin Count := Length(Result); SetLength(Result, Count + 1); Result[Count] := A end;
  procedure Text(const Value: string; const Bounds: TRect; const Col: TThemeColor);
  begin Init(ncpText, Col); A.Text := Value; A.Bounds := Bounds; A.TextFlags := [ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix]; Add end;
  procedure Line(const X1, Y1, X2, Y2: Double; const Col: TThemeColor);
  begin Init(ncpLine, Col); A.Points := [TPointF.Create(X1, Y1), TPointF.Create(X2, Y2)]; Add end;
  procedure DrawLegend;
  var Index: Integer; Top: Double; Col: TThemeColor; Row: TNimbusStreamBandGeometry;
  begin
    if L.LegendBounds.IsEmpty then Exit;
    for Index := 0 to C.Model.Series.Count - 1 do
    begin
      Top := L.LegendBounds.Top + Index * 22 * DPI; if Top + 22 * DPI > L.LegendBounds.Bottom then Break;
      Col := ChartAccentColor(C); if C.ChartPalette <> nil then Col := ColorToThemeColor(C.ChartPalette.GetSeriesColor(Index));
      for Row in G.Bands do if Row.SeriesIndex = Index then begin Col := Row.Color; Break end;
      if not C.Model.Series[Index].Visible then Col := NimbusColorWithAlpha(Fore, 70);
      Init(ncpRect, Col); A.Bounds := B(L.LegendBounds.Left, Top + 5 * DPI, L.LegendBounds.Left + 12 * DPI, Top + 17 * DPI); Add;
      Text(C.Model.Series[Index].Name, B(L.LegendBounds.Left + 18 * DPI, Top, L.LegendBounds.Right, Top + 22 * DPI), Fore);
      Init(ncpHitBounds, 0); A.Bounds := B(L.LegendBounds.Left, Top, L.LegendBounds.Right, Top + 22 * DPI); A.Hit.Area := nchaLegend; A.Hit.SeriesIndex := Index; A.Hit.Text := C.Model.Series[Index].Name; Add;
    end;
  end;
begin
  Result := nil; if (C.Model = nil) or (C.Font = nil) then Exit; O := C.Model.StreamGraphOptions; DPI := Max(1, C.PPI) / 96; Fore := ChartForeColor(C); Clip := False;
  Init(ncpRect, NimbusBlendColor(ChartBackColor(C), Fore, 5)); A.Bounds := L.PlotArea; Add; Init(ncpOutlineRect, NimbusColorWithAlpha(Fore, 35)); A.Bounds := L.PlotArea; Add;
  if not L.TitleBounds.IsEmpty then begin Text(C.Model.Title, L.TitleBounds, Fore); A.UseFont := True; A.FontHeight := Round(C.Font.Height * 1.25); A.FontStyle := [fsBold]; Result[High(Result)] := A end;
  if not L.SubtitleBounds.IsEmpty then Text(C.Model.Subtitle, L.SubtitleBounds, NimbusColorWithAlpha(Fore, 170));
  G := GetGeometry(C, L.PlotArea); if (Length(G.Bands) = 0) or (Length(G.Categories) = 0) then begin Text(O.EmptyText, L.PlotArea, Fore); DrawLegend; Exit end;
  Step := Max(1, Ceil(Length(G.Categories) / O.MaxAxisLabelCount));
  if O.ShowGrid then
  begin
    for I := 1 to 4 do begin Y := L.PlotArea.Top + L.PlotArea.Height * I / 5; Line(L.PlotArea.Left, Y, L.PlotArea.Right, Y, NimbusColorWithAlpha(Fore, 22)) end;
    J := 0; while J < Length(G.Categories) do begin X := G.Bands[0].Samples[J].CenterPoint.X; Line(X, L.PlotArea.Top, X, L.PlotArea.Bottom, NimbusColorWithAlpha(Fore, 12)); Inc(J, Step) end;
  end;
  Clip := O.ClipToPlot;
  for I := 0 to High(G.Bands) do
  begin
    Band := G.Bands[I]; Hovered := C.Hovered.SeriesIndex = Band.SeriesIndex; Selected := C.Selected.SeriesIndex = Band.SeriesIndex;
    Focused := ((C.Hovered.SeriesIndex >= 0) or (C.Selected.SeriesIndex >= 0)); Opacity := O.FillOpacity;
    if O.DimUnfocusedSeries and Focused and not Hovered and not Selected and (O.SelectionMode <> nssTimeSlice) then Opacity := O.UnfocusedOpacity;
    if Hovered or Selected then Opacity := Min(1.0, Opacity + O.HoverOpacityBoost); Color := Band.Color;
    if O.UseSoftHighlight and (Hovered or Selected) then Color := NimbusBlendColor(Color, Fore, 16);
    if Selected and O.ShowSelectionGlow then begin Init(ncpLine, $78FFFFFF); A.Points := Band.Outline; A.Width := 5 * DPI; Add; Init(ncpLine, NimbusColorWithAlpha(Color, 230)); A.Points := Band.Outline; A.Width := 3 * DPI; Add end
    else if Hovered and O.ShowFocusGlow then begin Init(ncpLine, $55FFFFFF); A.Points := Band.Outline; A.Width := 4 * DPI; Add end;
    Init(ncpPolygon, NimbusColorWithAlpha(Color, Round(Opacity * 255))); A.Points := Band.Polygon; Add;
    if O.UseGlassSheen and (Length(Band.Sheen) > 0) then begin Init(ncpPolygon, $16FFFFFF); A.Points := Band.Sheen; Add end;
    Init(ncpLine, NimbusColorWithAlpha(NimbusBlendColor(Color, $FF000000, 51), 140)); A.Points := Band.Outline; A.Width := O.LineWidth * DPI; if Hovered or Selected then A.Color := NimbusColorWithAlpha(A.Color, 242); Add;
    if Selected and (O.SelectionMode = nssBand) and (C.Selected.ElementIndex >= G.FirstIndex) and (C.Selected.ElementIndex <= G.LastIndex) then
    begin Info := Band.Samples[C.Selected.ElementIndex - G.FirstIndex]; Init(ncpOutlineRect, NimbusBlendColor(Color, Fore, 100)); A.Bounds := Info.Bounds; A.Width := 2 * DPI; Add end;
    PeakIndex := 0; for J := 1 to High(Band.Samples) do if Band.Samples[J].Value > Band.Samples[PeakIndex].Value then PeakIndex := J; Info := Band.Samples[PeakIndex];
    if O.ShowBandLabels and (Info.Bounds.Height >= O.MinimumLabelBandHeight * DPI) then
    begin
      if O.ShowValues then Text(Info.SeriesName + ' ' + SparklineFormatValue(Info.RawValue, O.ValueFormat), B(Info.CenterPoint.X - 70 * DPI, Info.CenterPoint.Y - 10 * DPI, Info.CenterPoint.X + 70 * DPI, Info.CenterPoint.Y + 10 * DPI), $F0FFFFFF)
      else Text(Info.SeriesName, B(Info.CenterPoint.X - 70 * DPI, Info.CenterPoint.Y - 10 * DPI, Info.CenterPoint.X + 70 * DPI, Info.CenterPoint.Y + 10 * DPI), $F0FFFFFF);
    end;
    Info := Band.Samples[High(Band.Samples)]; if O.ShowEndLabels and (Info.Bounds.Height >= O.MinimumLabelBandHeight * DPI) then Text(Info.SeriesName, B(L.PlotArea.Right - 95 * DPI, Info.CenterPoint.Y - 10 * DPI, L.PlotArea.Right - 5 * DPI, Info.CenterPoint.Y + 10 * DPI), Fore);
  end;
  if O.ShowHoverLine and (C.Hovered.ElementIndex >= G.FirstIndex) and (C.Hovered.ElementIndex <= G.LastIndex) and (C.Hovered.SeriesIndex >= 0) then
  begin X := G.Bands[0].Samples[C.Hovered.ElementIndex - G.FirstIndex].CenterPoint.X; Line(X, L.PlotArea.Top, X, L.PlotArea.Bottom, NimbusColorWithAlpha(Fore, 120)); Init(ncpEllipse, Fore); A.Bounds := B(X - 3 * DPI, L.PlotArea.Top - 3 * DPI, X + 3 * DPI, L.PlotArea.Top + 3 * DPI); Add end;
  if (O.SelectionMode = nssTimeSlice) and (C.Selected.ElementIndex >= G.FirstIndex) and (C.Selected.ElementIndex <= G.LastIndex) then
  begin X := G.Bands[0].Samples[C.Selected.ElementIndex - G.FirstIndex].CenterPoint.X; Init(ncpRect, NimbusColorWithAlpha(ChartAccentColor(C), 46)); A.Bounds := B(X - 8 * DPI, L.PlotArea.Top, X + 8 * DPI, L.PlotArea.Bottom); Add end;
  Clip := False;
  if O.ShowAxes then
  begin
    Line(L.PlotArea.Left, L.PlotArea.Bottom, L.PlotArea.Right, L.PlotArea.Bottom, NimbusColorWithAlpha(Fore, 70));
    if O.ShowXLabels then begin J := 0; while J < Length(G.Categories) do begin X := G.Bands[0].Samples[J].CenterPoint.X; Text(G.Categories[J], B(X - 42 * DPI, L.PlotArea.Bottom + 5 * DPI, X + 42 * DPI, L.PlotArea.Bottom + 25 * DPI), NimbusColorWithAlpha(Fore, 170)); Inc(J, Step) end end;
    if O.ShowYLabels then
    begin Maximum := 0; for Y in G.Totals do Maximum := Max(Maximum, Y); for J := 0 to 4 do
      begin Y := L.PlotArea.Bottom - L.PlotArea.Height * J / 4; if O.NormalizeToPercent or (O.BaselineMode = nsbExpand100) then Text(SparklineFormatValue(J * 25, StringReplace(O.PercentFormat, '%', '', [rfReplaceAll])) + '%', B(L.PlotArea.Left + 6 * DPI, Y - 10 * DPI, L.PlotArea.Left + 70 * DPI, Y + 10 * DPI), Fore)
      else Text(SparklineFormatValue(Maximum * J / 4, O.ValueFormat), B(L.PlotArea.Left + 6 * DPI, Y - 10 * DPI, L.PlotArea.Left + 70 * DPI, Y + 10 * DPI), Fore) end;
    end;
  end;
  DrawLegend;
  if O.ShowZoomNavigator and (Length(G.FullCategories) > 1) then
  begin
    Init(ncpRect, NimbusColorWithAlpha(Fore, 28)); A.Bounds := B(L.PlotArea.Left + 8 * DPI, L.PlotArea.Bottom - 18 * DPI, L.PlotArea.Right - 8 * DPI, L.PlotArea.Bottom - 13 * DPI); Add;
    X := A.Bounds.Left; Maximum := A.Bounds.Width / (Length(G.FullCategories) - 1); Init(ncpRect, NimbusColorWithAlpha(ChartAccentColor(C), 150));
    A.Bounds := B(X + G.FirstIndex * Maximum, L.PlotArea.Bottom - 20 * DPI, X + Max(G.FirstIndex * Maximum + 6 * DPI, G.LastIndex * Maximum), L.PlotArea.Bottom - 11 * DPI); A.CornerRadius := 4 * DPI; Add;
  end;
  if O.ShowZoomBadge and O.EnableRangeZoom and O.IsZoomed then Text('Zoom ' + IntToStr(G.FirstIndex + 1) + '-' + IntToStr(G.LastIndex + 1) + '/' + IntToStr(Length(G.FullCategories)), B(L.PlotArea.Right - 126 * DPI, L.PlotArea.Top + 8 * DPI, L.PlotArea.Right - 8 * DPI, L.PlotArea.Top + 32 * DPI), Fore);
  if FRangePreview then
  begin Clip := True; Init(ncpRect, NimbusColorWithAlpha(ChartAccentColor(C), 42)); A.Bounds := B(Max(L.PlotArea.Left, FPreviewLeft), L.PlotArea.Top, Min(L.PlotArea.Right, FPreviewRight), L.PlotArea.Bottom); Add; A.Kind := ncpOutlineRect; A.Color := NimbusColorWithAlpha(ChartAccentColor(C), 190); A.Width := 1.5 * DPI; Add end;
end;

end.

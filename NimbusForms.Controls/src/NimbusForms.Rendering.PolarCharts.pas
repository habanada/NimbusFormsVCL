{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.PolarCharts;

interface

uses System.Types, NimbusForms.Rendering.Charts, NimbusForms.Charts.Types;

type
  TNimbusPolarChartRenderer = class(TNimbusChartRenderer)
  protected
    function Build(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>; override;
  public
    function CanRender(const AType: TNimbusChartType): Boolean; override;
  end;

implementation

uses System.SysUtils, System.Math, Vcl.Graphics, NimbusForms.Rendering.ChartPrimitives,
  NimbusForms.Charts.Sparkline.Types, NimbusForms.Rendering.Types, NimbusForms.Theming.Types;

function TNimbusPolarChartRenderer.CanRender(const AType: TNimbusChartType): Boolean;
begin Result := AType in [nctRadar, nctNestedPie] end;

function TNimbusPolarChartRenderer.Build(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>;
var B: TNimbusChartPrimitiveBuilder; I, J, K, Count, SeriesCount, RingIndex, Steps: Integer;
  S: TNimbusChartSeries; P: TNimbusChartPoint; CX, CY, Radius, Maximum, Total, Value, Angle, Sweep, Inner, Outer, T: Double;
  LabelSizes: TArray<TSize>; Captions: TArray<string>; LabelFlags: TNimbusTextFlags; LabelWidth, LabelHeight: Integer;
  Points, Sector: TArray<TPointF>; Col: TThemeColor; Hit: TNimbusChartHit; Bounds: TRect; CaptionText: string;
begin
  Result := nil; if C.Model = nil then Exit; B := TNimbusChartPrimitiveBuilder.Create(C, L);
  try
    CX := L.PlotArea.CenterPoint.X; CY := L.PlotArea.CenterPoint.Y; Radius := Max(0.0, Min(L.PlotArea.Width, L.PlotArea.Height) / 2 - 32 * C.PPI / 96);
    Count := 0; SeriesCount := 0; Maximum := 0;
    for I := 0 to C.Model.Series.Count - 1 do if C.Model.Series[I].Visible then
    begin Inc(SeriesCount); Count := Max(Count, C.Model.Series[I].Points.Count);
      for J := 0 to C.Model.Series[I].Points.Count - 1 do begin P := C.Model.Series[I].Points[J]; if P.Visible and SparklineFinite(P.YValue) then Maximum := Max(Maximum, P.YValue) end end;
    if (Count = 0) or (SeriesCount = 0) or (Radius <= 0) then begin Result := B.Finish; Exit end;
    if C.Model.ChartType = nctRadar then
    begin
      SetLength(Captions, Count); SetLength(LabelSizes, Count); LabelWidth := 0; LabelHeight := 0;
      for J := 0 to Count - 1 do
      begin
        Captions[J] := IntToStr(J + 1);
        for I := 0 to C.Model.Series.Count - 1 do if C.Model.Series[I].Visible and (J < C.Model.Series[I].Points.Count) then begin Captions[J] := C.Model.Series[I].Points[J].&Label; Break end;
        LabelSizes[J] := NimbusChartMeasureLabel(C, Captions[J], Round(140 * C.PPI / 96)); LabelWidth := Max(LabelWidth, LabelSizes[J].cx); LabelHeight := Max(LabelHeight, LabelSizes[J].cy);
      end;
      Radius := Max(0.0, Min(L.PlotArea.Width / 2 - LabelWidth, L.PlotArea.Height / 2 - LabelHeight) - 12 * C.PPI / 96);
      Maximum := Max(1E-100, Maximum); SetLength(Points, Count + 1);
      if C.Model.Options.ShowGrid then for K := 1 to 4 do
      begin for J := 0 to Count do begin Angle := 2 * Pi * J / Count - Pi / 2; Points[J] := TPointF.Create(CX + Cos(Angle) * Radius * K / 4, CY + Sin(Angle) * Radius * K / 4) end;
        B.Line(Points, ChartBorderColor(C), C.PPI / 96, TNimbusChartHit.None) end;
      for J := 0 to Count - 1 do
      begin
        Angle := 2 * Pi * J / Count - Pi / 2;
        if C.Model.Options.ShowAxes then B.Line([TPointF.Create(CX, CY), TPointF.Create(CX + Cos(Angle) * Radius, CY + Sin(Angle) * Radius)], ChartBorderColor(C), C.PPI / 96, TNimbusChartHit.None);
        Bounds := NimbusChartRadialLabel(TPointF.Create(CX, CY), Radius, Angle, 10 * C.PPI / 96, LabelSizes[J], LabelFlags);
        B.Text(Captions[J], Bounds, ChartForeColor(C), TNimbusChartHit.None, LabelFlags);
      end;
      for I := 0 to C.Model.Series.Count - 1 do
      begin
        S := C.Model.Series[I]; if not S.Visible then Continue; SetLength(Points, Count + 1); Col := B.Color(I, S.Color);
        for J := 0 to Count - 1 do
        begin Value := 0; if J < S.Points.Count then if S.Points[J].Visible and SparklineFinite(S.Points[J].YValue) then Value := Max(0.0, S.Points[J].YValue);
          Angle := 2 * Pi * J / Count - Pi / 2; Points[J] := TPointF.Create(CX + Cos(Angle) * Radius * Value / Maximum * C.AnimationProgress, CY + Sin(Angle) * Radius * Value / Maximum * C.AnimationProgress) end;
        Points[Count] := Points[0]; Hit := TNimbusChartHit.None; Hit.Area := nchaSeries; Hit.SeriesIndex := I; Hit.Text := S.Name;
        B.Polygon(Points, NimbusColorWithAlpha(Col, Round(EnsureRange(S.FillOpacity, 0.0, 1.0) * 255)), Hit); B.Line(Points, Col, Max(1.0, S.LineWidth * C.PPI / 96), Hit);
        for J := 0 to S.Points.Count - 1 do
        begin
          P := S.Points[J]; if not P.Visible or not SparklineFinite(P.YValue) then Continue; Hit.Area := nchaPoint; Hit.PointIndex := J; Hit.XValue := P.XValue; Hit.YValue := P.YValue; Hit.Text := P.ToolTipText;
          if Hit.Text = '' then Hit.Text := S.Name + ' / ' + P.&Label + ': ' + SparklineFormatValue(P.YValue, S.ValueFormat);
          if S.ShowMarkers then B.Ellipse(Rect(Round(Points[J].X - S.MarkerSize * C.PPI / 192), Round(Points[J].Y - S.MarkerSize * C.PPI / 192), Round(Points[J].X + S.MarkerSize * C.PPI / 192), Round(Points[J].Y + S.MarkerSize * C.PPI / 192)), B.Color(I, P.Color), Hit);
          if C.Model.Options.ShowValues or S.ShowValues or P.ShowValue then B.Text(SparklineFormatValue(P.YValue, S.ValueFormat), Rect(Round(Points[J].X - 30 * C.PPI / 96), Round(Points[J].Y - 24 * C.PPI / 96), Round(Points[J].X + 30 * C.PPI / 96), Round(Points[J].Y - 4 * C.PPI / 96)), ChartForeColor(C), Hit, [ntfVCenter, ntfSingleLine, ntfCenter, ntfNoPrefix]);
        end;
      end;
    end
    else
    begin
      RingIndex := 0;
      for I := 0 to C.Model.Series.Count - 1 do
      begin
        S := C.Model.Series[I]; if not S.Visible then Continue; Total := 0;
        for J := 0 to S.Points.Count - 1 do begin P := S.Points[J]; if P.Visible and SparklineFinite(P.YValue) then Total := Total + Max(0.0, P.YValue) end;
        if Total <= 0 then Continue; Inner := Radius * (RingIndex + 0.6) / (SeriesCount + 0.6); Outer := Radius * (RingIndex + 1.5) / (SeriesCount + 0.6); Outer := Min(Radius, Outer); Angle := -90;
        for J := 0 to S.Points.Count - 1 do
        begin
          P := S.Points[J]; if not P.Visible or not SparklineFinite(P.YValue) or (P.YValue <= 0) then Continue;
          Sweep := P.YValue / Total * 360 * C.AnimationProgress; Steps := Max(2, Ceil(Sweep / 3)); SetLength(Sector, (Steps + 1) * 2);
          for K := 0 to Steps do begin T := DegToRad(Angle + Sweep * K / Steps); Sector[K] := TPointF.Create(CX + Cos(T) * Outer, CY + Sin(T) * Outer); T := DegToRad(Angle + Sweep * (Steps - K) / Steps); Sector[Steps + K + 1] := TPointF.Create(CX + Cos(T) * Inner, CY + Sin(T) * Inner) end;
          Hit := TNimbusChartHit.None; Hit.Area := nchaSegment; Hit.SeriesIndex := I; Hit.PointIndex := J; Hit.XValue := P.XValue; Hit.YValue := P.YValue; Hit.Text := P.ToolTipText;
          if Hit.Text = '' then Hit.Text := S.Name + ' / ' + P.&Label + ': ' + SparklineFormatValue(P.YValue, S.ValueFormat) + ' (' + SparklineFormatValue(P.YValue / Total * 100, '0.#') + '%)';
          Col := B.Color(J, P.Color); B.Polygon(Sector, Col, Hit);
          if C.Model.Options.ShowValues or S.ShowValues or P.ShowValue then
          begin T := DegToRad(Angle + Sweep / 2); Value := (Inner + Outer) / 2;
            B.Text(SparklineFormatValue(P.YValue, S.ValueFormat), Rect(Round(CX + Cos(T) * Value - 30 * C.PPI / 96), Round(CY + Sin(T) * Value - 10 * C.PPI / 96), Round(CX + Cos(T) * Value + 30 * C.PPI / 96), Round(CY + Sin(T) * Value + 10 * C.PPI / 96)), NimbusChartContrastColor(Col), Hit, [ntfVCenter, ntfSingleLine, ntfCenter, ntfNoPrefix]) end;
          Angle := Angle + Sweep;
        end;
        Inc(RingIndex);
      end;
    end;
    Result := B.Finish;
  finally B.Free end;
end;

end.

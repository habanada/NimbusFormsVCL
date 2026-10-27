{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.Marimekko;

interface

uses System.Types, NimbusForms.Rendering.Charts, NimbusForms.Charts.Types;

type
  TNimbusMarimekkoChartRenderer = class(TNimbusChartRenderer)
  protected
    function Build(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>; override;
  public
    function CanRender(const AType: TNimbusChartType): Boolean; override;
    function Arrange(const C: TNimbusChartRenderContext): TNimbusChartLayout; override;
  end;

implementation

uses System.Classes, System.SysUtils, System.Math, Vcl.Graphics, NimbusForms.Rendering.ChartPrimitives,
  NimbusForms.Charts.Marimekko.Types, NimbusForms.Charts.Sparkline.Types, NimbusForms.Rendering.Types, NimbusForms.Theming.Types;

function TNimbusMarimekkoChartRenderer.CanRender(const AType: TNimbusChartType): Boolean;
begin Result := AType = nctMarimekko end;

function TNimbusMarimekkoChartRenderer.Arrange(const C: TNimbusChartRenderContext): TNimbusChartLayout;
begin
  Result := inherited Arrange(C); if C.Model = nil then Exit;
  if C.Model.MarimekkoOptions.ShowPercentAxis then Inc(Result.PlotArea.Left, NimbusScaleValue(42, C.PPI));
  if C.Model.MarimekkoOptions.ShowCategoryAxis or C.Model.MarimekkoOptions.ShowGrandTotal then Dec(Result.PlotArea.Bottom, NimbusScaleValue(32, C.PPI));
  if C.Model.MarimekkoOptions.ShowCategoryTotals then Inc(Result.PlotArea.Top, NimbusScaleValue(24, C.PPI));
  Result.PlotArea.Right := Max(Result.PlotArea.Left, Result.PlotArea.Right); Result.PlotArea.Bottom := Max(Result.PlotArea.Top, Result.PlotArea.Bottom);
end;

function TNimbusMarimekkoChartRenderer.Build(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>;
var B: TNimbusChartPrimitiveBuilder; Categories: TStringList; O: TNimbusMarimekkoOptions; S: TNimbusChartSeries; P: TNimbusChartPoint;
  Totals: TArray<Double>; I, J, K, Index, VisibleSeries: Integer; Total, Largest, Value, Ratio, X, Y, W, H, Gap, SG, DPI: Double;
  Bounds: TRect; Hit: TNimbusChartHit; Col: TThemeColor; CaptionText, LabelText: string; Flags: TNimbusTextFlags;
  function Category(const Point: TNimbusChartPoint): string;
  begin Result := Point.&Label; if Result = '' then Result := FloatToStr(Point.XValue) end;
begin
  Result := nil; if C.Model = nil then Exit; O := C.Model.MarimekkoOptions; Categories := TStringList.Create; B := TNimbusChartPrimitiveBuilder.Create(C, L);
  try
    DPI := Max(1, C.PPI) / 96; Flags := [ntfVCenter, ntfSingleLine, ntfCenter, ntfEndEllipsis, ntfNoPrefix]; VisibleSeries := 0;
    for I := 0 to C.Model.Series.Count - 1 do if C.Model.Series[I].Visible then
    begin Inc(VisibleSeries); for J := 0 to C.Model.Series[I].Points.Count - 1 do
      begin P := C.Model.Series[I].Points[J]; if P.Visible and SparklineFinite(P.YValue) and (P.YValue > 0) and (Categories.IndexOf(Category(P)) < 0) then Categories.Add(Category(P)) end end;
    SetLength(Totals, Categories.Count); Total := 0; Largest := 0;
    for I := 0 to C.Model.Series.Count - 1 do if C.Model.Series[I].Visible then for J := 0 to C.Model.Series[I].Points.Count - 1 do
    begin P := C.Model.Series[I].Points[J]; if not P.Visible or not SparklineFinite(P.YValue) or (P.YValue <= 0) then Continue; Index := Categories.IndexOf(Category(P)); Totals[Index] := Totals[Index] + P.YValue; Total := Total + P.YValue end;
    for Value in Totals do Largest := Max(Largest, Value);
    if (Total <= 0) or L.PlotArea.IsEmpty then begin B.Text(O.EmptyText, L.PlotArea, ChartForeColor(C), TNimbusChartHit.None, Flags); Result := B.Finish; Exit end;
    Gap := Min(Max(0.0, O.ColumnGap * DPI), L.PlotArea.Width / Max(1, Categories.Count * 3)); SG := Min(Max(0.0, O.SegmentGap * DPI), L.PlotArea.Height / Max(1, VisibleSeries * 3));
    X := L.PlotArea.Left;
    for K := 0 to Categories.Count - 1 do
    begin
      W := (L.PlotArea.Width - Max(0, Categories.Count - 1) * Gap) * Totals[K] / Total; Y := L.PlotArea.Bottom;
      for I := 0 to C.Model.Series.Count - 1 do
      begin
        S := C.Model.Series[I]; if not S.Visible then Continue;
        for J := 0 to S.Points.Count - 1 do
        begin
          P := S.Points[J]; if not P.Visible or not SparklineFinite(P.YValue) or (P.YValue <= 0) or not SameText(Category(P), Categories[K]) then Continue;
          Ratio := P.YValue / Totals[K]; H := Ratio * L.PlotArea.Height; if not O.NormalizeColumns then H := P.YValue / Largest * L.PlotArea.Height;
          Hit := TNimbusChartHit.None; Hit.Area := nchaSegment; Hit.SeriesIndex := I; Hit.PointIndex := J; Hit.ElementIndex := K; Hit.XValue := K; Hit.YValue := P.YValue;
          Hit.Text := P.ToolTipText; if Hit.Text = '' then begin Hit.Text := S.Name + ' / ' + Categories[K] + ': ' + SparklineFormatValue(P.YValue, O.ValueFormat);
            if O.ShowToolTipDetails then Hit.Text := Hit.Text + sLineBreak + 'Category share: ' + SparklineFormatValue(Ratio * 100, '0.#') + '%' + sLineBreak + 'Category total: ' + SparklineFormatValue(Totals[K], O.ValueFormat) end;
          Col := B.Color(I, S.Color); if P.Color <> clNone then Col := B.Color(I, P.Color);
          if O.DimUnfocusedSegments and (C.Hovered.Area <> nchaNone) and not Hit.SameElement(C.Hovered) then Col := NimbusBlendColor(Col, ChartBackColor(C), 155);
          Bounds := Rect(Round(X), Round(Y - H + SG / 2), Round(X + W), Round(Y - SG / 2)); B.Box(Bounds, Col, Hit, O.SegmentCornerRadius * DPI);
          if (O.ShowHoverHighlight and Hit.SameElement(C.Hovered)) or (O.ShowSelectedHighlight and Hit.SameElement(C.Selected)) then B.Box(Bounds, ChartForeColor(C), Hit, O.SegmentCornerRadius * DPI, True);
          LabelText := ''; if O.ShowSegmentLabels then LabelText := S.Name;
          if O.ShowSegmentValues then LabelText := Trim(LabelText + ' ' + SparklineFormatValue(P.YValue, O.ValueFormat));
          if O.ShowSegmentPercent then LabelText := Trim(LabelText + ' ' + SparklineFormatValue(Ratio * 100, StringReplace(O.PercentFormat, '%', '', [rfReplaceAll])) + '%');
          if (Bounds.Width >= O.MinimumSegmentWidthForLabel * DPI) and (Bounds.Height >= O.MinimumSegmentHeightForLabel * DPI) then B.Text(LabelText, Bounds, NimbusChartContrastColor(Col), Hit, Flags);
          Y := Y - H;
        end;
      end;
      Hit := TNimbusChartHit.None;
      if O.ShowCategoryAxis then B.Text(Categories[K], Rect(Round(X), L.PlotArea.Bottom + Round(3 * DPI), Round(X + W), L.PlotArea.Bottom + Round(25 * DPI)), ChartForeColor(C), Hit, Flags);
      if O.ShowCategoryTotals then B.Text(SparklineFormatValue(Totals[K], O.ValueFormat), Rect(Round(X), L.PlotArea.Top - Round(24 * DPI), Round(X + W), L.PlotArea.Top), ChartForeColor(C), Hit, Flags);
      if O.ShowColumnSeparators then B.Line([TPointF.Create(X + W, L.PlotArea.Top), TPointF.Create(X + W, L.PlotArea.Bottom)], ChartBorderColor(C), DPI, Hit);
      X := X + W + Gap;
    end;
    if O.ShowPercentAxis then for I := 0 to 4 do
    begin Y := L.PlotArea.Bottom - L.PlotArea.Height * I / 4; B.Text(IntToStr(I * 25) + '%', Rect(L.PlotArea.Left - Round(42 * DPI), Round(Y - 10 * DPI), L.PlotArea.Left - Round(4 * DPI), Round(Y + 10 * DPI)), ChartForeColor(C), TNimbusChartHit.None, Flags) end;
    if O.ShowGrandTotal then B.Text('Total: ' + SparklineFormatValue(Total, O.ValueFormat), Rect(L.PlotArea.Left, L.PlotArea.Bottom + Round(25 * DPI), L.PlotArea.Right, L.Bounds.Bottom), ChartForeColor(C), TNimbusChartHit.None, Flags);
    Result := B.Finish;
  finally B.Free; Categories.Free end;
end;

end.

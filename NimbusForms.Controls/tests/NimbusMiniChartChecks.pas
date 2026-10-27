{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusMiniChartChecks;

interface

procedure RunNimbusMiniChartChecks;

implementation

uses System.Classes, System.SysUtils, System.Types, System.Math, Vcl.Graphics,
  NimbusForms.Controls.Chart, NimbusForms.Charts.Types, NimbusForms.Rendering.Charts,
  NimbusForms.Rendering.Sankey, NimbusForms.Charts.Sankey.Types, NimbusForms.Charts.Maps.Data,
  NimbusForms.Charts.ProgressRingGrid.Types, NimbusForms.Charts.EdgeBundling.Types, NimbusForms.Charts.Financial.Types;

type
  TPolylineProbe = class(TNimbusChartRenderer)
  protected
    function Build(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>; override;
  end;

function TPolylineProbe.Build(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>;
begin
  SetLength(Result, 1); Result[0] := Default(TNimbusChartPrimitive); Result[0].Kind := ncpLine;
  Result[0].Points := [TPointF.Create(10, 10), TPointF.Create(30, 10), TPointF.Create(30, 90)];
  Result[0].Width := 2; Result[0].Hit := TNimbusChartHit.None; Result[0].Hit.Area := nchaSegment; Result[0].Hit.ElementIndex := 7;
end;

procedure Require(const Condition: Boolean; const Text: string);
begin if not Condition then raise Exception.Create(Text) end;

procedure RunNimbusMiniChartChecks;
const NewTypes: array[0..9] of TNimbusChartType = (nctSankey, nctProgressRingGrid, nctHierarchicalEdgeBundling, nctMarimekko, nctRadar, nctNestedPie, nctChoroplethMap, nctCountryMap, nctCandlestick, nctOhlc);
  PPIs: array[0..3] of Integer = (96, 120, 144, 192);
var Chart, Loaded: TThemedChart; Model: TNimbusChartModel; Renderer: INimbusChartRenderer; Sankey: TNimbusSankeyChartRenderer;
  C: TNimbusChartRenderContext; Geometry: TNimbusSankeyGeometry; Link: TNimbusSankeyLinkGeometry; Node: TNimbusSankeyNodeGeometry;
  ChartType: TNimbusChartType; PPI, I, J: Integer; Hit: TNimbusChartHit; Point: TPointF; Series: TNimbusChartSeries;
  Item: TNimbusProgressRingItem; BundleNode: TNimbusHierarchicalEdgeBundlingNode; Stream: TMemoryStream; Bitmap: TBitmap;
  Shapes: TArray<TNimbusMapShape>; Cities: TArray<TNimbusMapCity>; Svg: string;
begin
  Chart := TThemedChart.Create(nil);
  try
    Model := Chart.Model; Chart.ShowLegend := False; Chart.ShowAxes := False; Chart.ShowAnimation := False;
    for ChartType := Low(TNimbusChartType) to High(TNimbusChartType) do Require(Chart.RendererFactory.CanRender(ChartType), 'Missing chart renderer: ' + IntToStr(Ord(ChartType)));
    C := Default(TNimbusChartRenderContext); C.Model := Model; C.Font := Chart.Font; C.ChartPalette := Model.Palette; C.Enabled := True; C.AnimationProgress := 1;
    C.Hovered := TNimbusChartHit.None; C.Selected := TNimbusChartHit.None; C.XView := TNimbusChartRange.Empty; C.YView := TNimbusChartRange.Empty;
    Model.Sankey.Nodes.Add('a', 'Source'); Model.Sankey.Nodes.Add('b', 'Split'); Model.Sankey.Nodes.Add('c', 'One'); Model.Sankey.Nodes.Add('d', 'Two');
    Model.Sankey.Links.Add('a', 'b', 100); Model.Sankey.Links.Add('b', 'c', 40); Model.Sankey.Links.Add('b', 'd', 60);
    Model.Sankey.Links.Add('a', 'invalid', NaN); Model.Sankey.Links.Add('a', 'negative', -1);
    Model.Sankey.Links[1].ToolTipText := 'Custom flow tooltip'; Model.Sankey.StageTitles.Add('Inputs');
    Chart.ChartType := nctSankey; Sankey := TNimbusSankeyChartRenderer.Create; Renderer := Sankey;
    for PPI in PPIs do
    begin
      C.PPI := PPI; C.Bounds := Rect(0, 0, Round(800 * PPI / 96), Round(500 * PPI / 96)); Geometry := Sankey.GetGeometry(C, Renderer.Arrange(C).PlotArea);
      Require((Length(Geometry.Nodes) = 4) and (Length(Geometry.Links) = 3) and (Geometry.LayerCount = 3), 'Sankey invalid flows or layers');
      for Node in Geometry.Nodes do
      begin
        Require(Node.Bounds.Width > 0, 'Sankey node has no width'); Require(Node.Bounds.Height > 0, 'Sankey node has no height');
        Hit := Renderer.HitTest(C, TPointF.Create((Node.Bounds.Left + Node.Bounds.Right) / 2, (Node.Bounds.Top + Node.Bounds.Bottom) / 2)); Require((Hit.Area = nchaPoint) and SameValue(Hit.YValue, Node.Value), 'Sankey node hit disagrees with layout');
      end;
      for Link in Geometry.Links do
      begin
        for Point in Link.Polygon do Require(not IsNan(Point.X) and not IsInfinite(Point.X) and not IsNan(Point.Y) and not IsInfinite(Point.Y), 'Sankey nonfinite polygon');
        Require(Link.Thickness > 0, 'Sankey zero link thickness');
      end;
      Link := Geometry.Links[1]; Point := TPointF.Create(Link.Polygon[16].X, Link.Polygon[16].Y + Link.Thickness / 2); Hit := Renderer.HitTest(C, Point);
      Require((Hit.Area = nchaSegment) and (Hit.Text = 'Custom flow tooltip'), 'Sankey flow hit or tooltip');
    end;
    Model.Sankey.Nodes[2].Visible := False; Geometry := Sankey.GetGeometry(C, Renderer.Arrange(C).PlotArea); Require(Length(Geometry.Links) = 2, 'Hidden Sankey node recreated');
    Model.Sankey.Nodes[2].Visible := True; Model.Sankey.Links.Add('d', 'b', 5); Geometry := Sankey.GetGeometry(C, Renderer.Arrange(C).PlotArea); Require(Length(Geometry.Links) = 4, 'Cyclic Sankey flow lost');
    Model.ProgressRingGrid.Items.Add.Value := 75; Item := Model.ProgressRingGrid.Items.Add; Item.Title := 'Layered'; Item.Layers.Add.Value := 55;
    Require(SameValue(Model.ProgressRingGrid.Items[0].Percent, 0.75), 'Ring default range');
    for I := 0 to 3 do begin BundleNode := Model.EdgeBundling.Nodes.Add; BundleNode.Id := 'node' + IntToStr(I); BundleNode.Caption := BundleNode.Id; BundleNode.GroupKey := 'Group ' + IntToStr(I div 2) end;
    with Model.EdgeBundling.Links.Add do begin SourceId := 'node0'; TargetId := 'node2'; Value := 10 end;
    for I := 0 to 2 do begin Series := Model.AddSeries('Series ' + IntToStr(I)); for J := 0 to 3 do Series.Points.Add(J, 10 + I + J, 'Category ' + IntToStr(J)) end;
    for I := 0 to 39 do Model.FinancialData.Add(I, 100 + I, 104 + I, 98 + I, 102 + I, I * 100);
    Require(Model.FinancialData[0].IsValid, 'Valid OHLC rejected'); Model.FinancialData[0].High := 90; Require(not Model.FinancialData[0].IsValid, 'Invalid OHLC accepted'); Model.FinancialData[0].High := 104;
    for ChartType in NewTypes do for PPI in PPIs do
    begin
      Chart.ChartType := ChartType; Bitmap := Chart.RenderToBitmap(Round(800 * PPI / 96), Round(500 * PPI / 96));
      try Require((Bitmap.Width > 0) and (Bitmap.Height > 0), 'New chart bitmap missing') finally Bitmap.Free end;
      Svg := Chart.ExportSvg(800, 500); Require(Pos('<svg', Svg) > 0, 'New chart SVG export missing');
    end;
    Require(not Chart.HandleAllocated, 'Chart render/export created HWND');
    Shapes := NimbusWorldMapShapes; Require(Length(Shapes) = 177, 'World map data incomplete');
    Shapes := NimbusCountryMapShapes('USA'); Require(Length(Shapes) > 40, 'Country region data incomplete');
    Cities := NimbusCountryMapCities('USA', 10, 250000); Require((Length(Cities) > 0) and (Length(Cities) <= 10), 'City data filter');
    C.PPI := 96; C.Bounds := Rect(0, 0, 200, 200); Chart.ChartType := nctLine; Model.Options.ClipToPlotArea := False; Renderer := TPolylineProbe.Create;
    Hit := Renderer.HitTest(C, TPointF.Create(30, 70)); Require((Hit.Area = nchaSegment) and (Hit.ElementIndex = 7), 'Polyline hit only checked its first segment');
    Stream := TMemoryStream.Create;
    try
      Stream.WriteComponent(Chart); Stream.Position := 0; Loaded := TThemedChart(Stream.ReadComponent(nil));
      try
        Require((Loaded.Model.Sankey.Nodes.Count = 4) and (Loaded.Model.Sankey.Links.Count = 6), 'Sankey streaming lost collections');
        Require((Loaded.Model.ProgressRingGrid.Items.Count = 2) and (Loaded.Model.ProgressRingGrid.Items[1].Layers.Count = 1), 'Ring streaming lost layers');
        Require((Loaded.Model.EdgeBundling.Nodes.Count = 4) and (Loaded.Model.EdgeBundling.Links.Count = 1), 'Edge bundling streaming lost data');
        Require(Loaded.Model.FinancialData.Count = 40, 'Financial streaming lost points');
      finally Loaded.Free end;
    finally Stream.Free end;
    Renderer := nil;
  finally Chart.Free end;
end;

end.

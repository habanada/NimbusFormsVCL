{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.Sunburst;

interface

uses System.Types, NimbusForms.Rendering.Charts, NimbusForms.Charts.Types, NimbusForms.Charts.Sunburst.Types;

type
  TNimbusSunburstChartRenderer = class(TNimbusChartRenderer)
  protected
    function Build(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>; override;
  public
    function CanRender(const AType: TNimbusChartType): Boolean; override;
    function Arrange(const C: TNimbusChartRenderContext): TNimbusChartLayout; override;
    function GetGeometry(const C: TNimbusChartRenderContext; const Plot: TRect): TNimbusSunburstGeometry;
    function HitTest(const C: TNimbusChartRenderContext; const Location: TPointF): TNimbusChartHit; override;
  end;

implementation

uses Winapi.Windows, System.SysUtils, System.StrUtils, System.Math, Vcl.Graphics, NimbusForms.Charts.Hierarchy,
  NimbusForms.Theming.Types, NimbusForms.Rendering.Types, NimbusForms.Charts.Sparkline.Types;

function Descendant(const Path, Branch: string): Boolean;
begin Result := (Branch = '') or SameText(Path, Branch) or StartsText(Branch + '/', Path) end;

function Dark(const C: TNimbusChartRenderContext): Boolean;
var Color: TThemeColor;
begin
  if C.Palette <> nil then Exit(C.Palette.IsDark); Color := ChartBackColor(C);
  Result := (((Color shr 16) and 255) * 299 + ((Color shr 8) and 255) * 587 + (Color and 255) * 114) < 128000;
end;

function Sector(const Segment: TNimbusSunburstSegmentInfo; const Inset: Double = 0): TArray<TPointF>;
var I, Steps: Integer; Angle, Inner, Outer: Double;
begin
  Inner := Max(0.0, Segment.InnerRadius + Inset); Outer := Max(Inner + 0.1, Segment.OuterRadius - Inset);
  Steps := Max(2, Ceil(Segment.SweepAngle / 2)); SetLength(Result, (Steps + 1) * 2);
  for I := 0 to Steps do
  begin
    Angle := DegToRad(Segment.StartAngle + Segment.SweepAngle * I / Steps);
    Result[I] := TPointF.Create(Segment.Center.X + Cos(Angle) * Outer, Segment.Center.Y + Sin(Angle) * Outer);
    Angle := DegToRad(Segment.StartAngle + Segment.SweepAngle * (Steps - I) / Steps);
    Result[Steps + 1 + I] := TPointF.Create(Segment.Center.X + Cos(Angle) * Inner, Segment.Center.Y + Sin(Angle) * Inner);
  end;
end;

function InPolygon(const Points: TArray<TPointF>; const P: TPointF): Boolean;
var I, J: Integer; A, B: TPointF;
begin
  Result := False; J := High(Points); for I := 0 to High(Points) do
  begin A := Points[I]; B := Points[J]; if (A.Y > P.Y) <> (B.Y > P.Y) then if P.X < (B.X - A.X) * (P.Y - A.Y) / (B.Y - A.Y) + A.X then Result := not Result; J := I end;
end;

function TNimbusSunburstChartRenderer.CanRender(const AType: TNimbusChartType): Boolean;
begin Result := AType = nctSunburst end;

function TNimbusSunburstChartRenderer.Arrange(const C: TNimbusChartRenderContext): TNimbusChartLayout;
var Pad: Integer;
begin
  Result := inherited Arrange(C); if C.Model = nil then Exit; Pad := Round(C.Model.SunburstOptions.OuterPadding * Max(1, C.PPI) / 96);
  InflateRect(Result.PlotArea, -Pad, -Pad); if C.Model.SunburstOptions.ShowBreadcrumb then Dec(Result.PlotArea.Bottom, Round(26 * Max(1, C.PPI) / 96));
  Result.PlotArea.Right := Max(Result.PlotArea.Left, Result.PlotArea.Right); Result.PlotArea.Bottom := Max(Result.PlotArea.Top, Result.PlotArea.Bottom);
end;

function TNimbusSunburstChartRenderer.GetGeometry(const C: TNimbusChartRenderContext; const Plot: TRect): TNimbusSunburstGeometry;
var Root, VisibleRoot: TNimbusHierarchyNode; O: TNimbusSunburstOptions; DPI, Gap, Thickness, Inner, Outer: Double;
  RingCount, VisibleSeries, I: Integer;
  function Percent(const V: Double): string;
  begin Result := SparklineFormatValue(V * 100, StringReplace(O.PercentageFormat, '%', '', [rfReplaceAll])) + '%' end;
  procedure Add(const Node: TNimbusHierarchyNode; const Depth: Integer; const ParentValue, Start, Sweep: Double);
  var Info: TNimbusSunburstSegmentInfo; Count: Integer; Blend: Double; Col: TThemeColor;
  begin
    if (Depth > RingCount) or (Sweep <= 0) then Exit; Info := Default(TNimbusSunburstSegmentInfo); Info.NodeIndex := Length(Result.Segments);
    Info.SeriesIndex := Node.SeriesIndex; Info.PointIndex := Node.PointIndex; Info.Depth := Depth; Info.Text := Node.Name; Info.Path := Node.Path; Info.Tag := Node.Tag;
    Info.Value := Node.Value; Info.ParentValue := ParentValue; Info.RootValue := Result.RootValue;
    if ParentValue > 0 then Info.ShareOfParent := Node.Value / ParentValue; if Result.RootValue > 0 then Info.ShareOfTotal := Node.Value / Result.RootValue;
    Info.StartAngle := Start + Min(O.SegmentGapAngle, Sweep * 0.5) / 2; Info.SweepAngle := Max(0.0, Sweep - Min(O.SegmentGapAngle, Sweep * 0.5));
    Info.InnerRadius := Inner + (Depth - 1) * (Thickness + Gap); Info.OuterRadius := Min(Outer, Info.InnerRadius + Thickness); Info.Center := Result.Center;
    Info.Bounds := Rect(Floor(Info.Center.X - Info.OuterRadius), Floor(Info.Center.Y - Info.OuterRadius), Ceil(Info.Center.X + Info.OuterRadius), Ceil(Info.Center.Y + Info.OuterRadius));
    Col := Node.Color; if Col = 0 then Col := ChartAccentColor(C);
    if O.EnableDepthGradient and not Node.ExplicitColor then
    begin Blend := Min(0.46, Max(0, Depth - 1) * 0.085); if Dark(C) then Col := NimbusBlendColor(Col, $FFFFFFFF, Round(Blend * 255)) else Col := NimbusBlendColor(Col, $FF000000, Round(Blend * 0.55 * 255)) end;
    Info.Color := Col; Info.Polygon := Sector(Info); Info.ToolTipText := Node.ToolTipText;
    if Info.ToolTipText = '' then
    begin
      Info.ToolTipText := Info.Path + sLineBreak + 'Value: ' + SparklineFormatValue(Info.Value, O.ValueFormat) + sLineBreak + 'Share of parent: ' + Percent(Info.ShareOfParent)
        + sLineBreak + 'Share of total: ' + Percent(Info.ShareOfTotal) + sLineBreak + 'Depth: ' + IntToStr(Depth);
      if O.EnableZoom then Info.ToolTipText := Info.ToolTipText + sLineBreak + 'Double click: zoom'; if O.EnableMarking then Info.ToolTipText := Info.ToolTipText + sLineBreak + 'Click: mark branch';
    end;
    Count := Length(Result.Segments); SetLength(Result.Segments, Count + 1); Result.Segments[Count] := Info;
  end;
  procedure Children(const Parent: TNimbusHierarchyNode; const Depth: Integer; const Start, Sweep: Double);
  var Node: TNimbusHierarchyNode; Total, Cursor, Amount: Double;
  begin
    if Depth > RingCount then Exit; Total := 0; for Node in Parent.Children do Total := Total + Node.Value; if Total <= 0 then Exit; Cursor := Start;
    for Node in Parent.Children do if Node.Value > 0 then
    begin Amount := Sweep * Node.Value / Total; Add(Node, Depth, Parent.Value, Cursor, Amount); if Node.Children.Count > 0 then Children(Node, Depth + 1, Cursor, Amount); Cursor := Cursor + Amount end;
  end;
begin
  Result := Default(TNimbusSunburstGeometry); if (C.Model = nil) or Plot.IsEmpty then Exit; O := C.Model.SunburstOptions; DPI := Max(1, C.PPI) / 96; VisibleSeries := 0;
  for I := 0 to C.Model.Series.Count - 1 do if C.Model.Series[I].Visible then Inc(VisibleSeries);
  Root := NimbusBuildHierarchy(C.Model, C.ChartPalette, O.PathSeparator, VisibleSeries > 1, False, True, nhsNone, C.ColorInfluence, C.Enabled, ChartAccentColor(C), ChartBackColor(C));
  try
    Result.RootValue := Root.Value; VisibleRoot := Root;
    if O.EnableZoom and O.IsZoomed then begin VisibleRoot := Root.Find(O.ZoomPath); if VisibleRoot = nil then VisibleRoot := Root end;
    Result.VisibleValue := VisibleRoot.Value; if VisibleRoot.Value <= 0 then Exit;
    RingCount := Max(1, VisibleRoot.MaximumDepth); if O.ShowRootRing and (VisibleRoot.Children.Count > 0) then Inc(RingCount); RingCount := Min(RingCount, O.MaximumDepth);
    Outer := Min(Plot.Width, Plot.Height) / 2; Inner := Outer * O.InnerRadiusRatio; Gap := Min(O.RingGap * DPI, Max(0.0, (Outer - Inner) / Max(1, RingCount) / 3));
    Thickness := (Outer - Inner - Gap * Max(0, RingCount - 1)) / RingCount; if Thickness <= 0 then Exit;
    Result.Center := TPointF.Create(Plot.Left + Plot.Width / 2, Plot.Top + Plot.Height / 2); Result.InnerRadius := Inner; Result.OuterRadius := Outer;
    if O.ShowRootRing or (VisibleRoot.Children.Count = 0) then Add(VisibleRoot, 1, VisibleRoot.Value, -90, 360);
    if O.ShowRootRing then Children(VisibleRoot, 2, -90, 360) else Children(VisibleRoot, 1, -90, 360);
  finally Root.Free end;
end;

function TNimbusSunburstChartRenderer.HitTest(const C: TNimbusChartRenderContext; const Location: TPointF): TNimbusChartHit;
var L: TNimbusChartLayout; G: TNimbusSunburstGeometry; Info: TNimbusSunburstSegmentInfo; I: Integer;
begin
  Result := TNimbusChartHit.None; Result.Location := Location; if C.Model = nil then Exit; L := Arrange(C); G := GetGeometry(C, L.PlotArea);
  for I := High(G.Segments) downto 0 do if InPolygon(G.Segments[I].Polygon, Location) then
  begin Info := G.Segments[I]; Result.Area := nchaSegment; Result.SeriesIndex := Info.SeriesIndex; Result.PointIndex := Info.PointIndex;
    Result.ElementIndex := Info.NodeIndex; Result.XValue := Info.ShareOfTotal; Result.YValue := Info.Value; Result.Text := Info.ToolTipText; Exit end;
  Result := inherited HitTest(C, Location);
end;

function TNimbusSunburstChartRenderer.Build(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>;
var G: TNimbusSunburstGeometry; Info, Sheen: TNimbusSunburstSegmentInfo; O: TNimbusSunburstOptions; A: TNimbusChartPrimitive;
  Fore, Back, Col, MarkColor, TextColor: TThemeColor; I, J: Integer; DPI, Radius, Angle, Width: Double; HoverPath, TextValue, MarkPath: string;
  Hovered, Selected, Marked, Related, MarkRelated, IsDark: Boolean; Bounds: TRect; Point: TPointF;
  procedure Init(const Kind: TNimbusChartPrimitiveKind; const Color: TThemeColor);
  begin A := Default(TNimbusChartPrimitive); A.Kind := Kind; A.Color := Color; A.Width := DPI; A.Hit := TNimbusChartHit.None; A.UseCornerRadius := True end;
  procedure Add;
  var Count: Integer;
  begin Count := Length(Result); SetLength(Result, Count + 1); Result[Count] := A end;
  procedure Text(const Value: string; const R: TRect; const Color: TThemeColor; Wrap: Boolean = False);
  begin Init(ncpText, Color); A.Text := Value; A.Bounds := R; A.TextFlags := [ntfCenter, ntfVCenter, ntfEndEllipsis, ntfNoPrefix]; if Wrap then Include(A.TextFlags, ntfWordWrap) else Include(A.TextFlags, ntfSingleLine); Add end;
  procedure Outline(const Segment: TNimbusSunburstSegmentInfo; const Inset, Thickness: Double; const Color: TThemeColor);
  begin Init(ncpLine, Color); A.Points := Sector(Segment, Inset); SetLength(A.Points, Length(A.Points) + 1); A.Points[High(A.Points)] := A.Points[0]; A.Width := Thickness; Add end;
  function Percent(const Value: Double): string;
  begin Result := SparklineFormatValue(Value * 100, StringReplace(O.PercentageFormat, '%', '', [rfReplaceAll])) + '%' end;
begin
  Result := inherited Build(C, L); if C.Model = nil then Exit; O := C.Model.SunburstOptions; DPI := Max(1, C.PPI) / 96; Fore := ChartForeColor(C); Back := ChartBackColor(C); IsDark := Dark(C);
  G := GetGeometry(C, L.PlotArea); HoverPath := ''; if (C.Hovered.Area = nchaSegment) and (C.Hovered.ElementIndex >= 0) and (C.Hovered.ElementIndex < Length(G.Segments)) then HoverPath := G.Segments[C.Hovered.ElementIndex].Path;
  MarkPath := O.MarkedPath; if O.EnableMarking and O.MarkHoveredBranch and (MarkPath = '') then MarkPath := HoverPath;
  MarkColor := ChartAccentColor(C); if O.MarkColor <> clNone then begin MarkColor := ColorToThemeColor(O.MarkColor); if C.ColorInfluence > 0 then MarkColor := NimbusBlendColor(MarkColor, ChartAccentColor(C), Round(C.ColorInfluence * 255 / 100)) end;
  if not C.Enabled then MarkColor := NimbusBlendColor(MarkColor, Back, 160);
  if O.EnableDropShadow then for Info in G.Segments do if Info.Depth = 1 then
  begin Init(ncpPolygon, $1C000000); if IsDark then A.Color := $50000000; A.Points := Sector(Info, -DPI); for J := 0 to High(A.Points) do A.Points[J].Y := A.Points[J].Y + 2.4 * DPI; Add end;
  for I := 0 to High(G.Segments) do
  begin
    Info := G.Segments[I]; Col := Info.Color; Hovered := (HoverPath <> '') and SameText(Info.Path, HoverPath);
    Selected := O.EnableSelection and (C.Selected.Area = nchaSegment) and (C.Selected.ElementIndex = I);
    Related := (HoverPath = '') or Descendant(Info.Path, HoverPath) or Descendant(HoverPath, Info.Path);
    Marked := O.EnableMarking and (O.MarkingMode <> nsmNone) and (MarkPath <> '') and (SameText(Info.Path, MarkPath) or ((O.MarkingMode = nsmBranch) and Descendant(Info.Path, MarkPath)));
    MarkRelated := (MarkPath = '') or Descendant(Info.Path, MarkPath) or Descendant(MarkPath, Info.Path);
    if O.EnableFocusDimming and not Related then Col := NimbusColorWithAlpha(Col, 82);
    if O.EnableMarking and O.HasMarkedPath and (O.MarkingMode = nsmBranch) and not MarkRelated then Col := NimbusColorWithAlpha(Col, 74);
    if Marked then Col := NimbusBlendColor(Col, $FFFFFFFF, 25); if Hovered then Col := NimbusBlendColor(Col, $FFFFFFFF, 40);
    Init(ncpPolygon, Col); A.Points := Copy(Info.Polygon); Add; Outline(Info, 0, DPI, NimbusColorWithAlpha(Back, 100));
    if O.EnableGloss and (Info.SweepAngle > 2.5) then
    begin Sheen := Info; Sheen.InnerRadius := Info.InnerRadius + (Info.OuterRadius - Info.InnerRadius) * 0.08; Sheen.OuterRadius := Info.InnerRadius + (Info.OuterRadius - Info.InnerRadius) * 0.42; Init(ncpPolygon, $24FFFFFF); if IsDark then A.Color := $12FFFFFF; A.Points := Sector(Sheen); Add end;
    if Marked then
    begin if O.ShowMarkedGlow then Outline(Info, -2.4 * DPI, (O.MarkedBorderWidth + 3.8) * DPI, NimbusColorWithAlpha(MarkColor, 92)); Outline(Info, -1.5 * DPI, O.MarkedBorderWidth * DPI, MarkColor) end;
    if Hovered then Outline(Info, -1.2 * DPI, 2.2 * DPI, $D2FFFFFF) else if Selected then Outline(Info, -1.2 * DPI, 2.2 * DPI, ChartAccentColor(C));
  end;
  if O.ShowLabels then for Info in G.Segments do
  begin
    if (Info.SweepAngle < O.MinimumSweepForLabel) or (Info.OuterRadius - Info.InnerRadius < 17 * DPI) then Continue;
    Radius := Info.InnerRadius + (Info.OuterRadius - Info.InnerRadius) * 0.52; Angle := DegToRad(Info.StartAngle + Info.SweepAngle / 2);
    Point := TPointF.Create(Info.Center.X + Cos(Angle) * Radius, Info.Center.Y + Sin(Angle) * Radius); Width := Min(118 * DPI, Max(28 * DPI, Info.SweepAngle * Radius * 0.0105));
    Bounds := Rect(Round(Point.X - Width / 2), Round(Point.Y - 10 * DPI), Round(Point.X + Width / 2), Round(Point.Y + 10 * DPI)); TextValue := Info.Text;
    if O.ShowValues then TextValue := TextValue + ' ' + SparklineFormatValue(Info.Value, O.ValueFormat) else if O.ShowPercentages then TextValue := TextValue + ' ' + Percent(Info.ShareOfParent);
    TextColor := $FFFFFFFF; if (((Info.Color shr 16) and 255) * 299 + ((Info.Color shr 8) and 255) * 587 + (Info.Color and 255) * 114) >= 142000 then TextColor := NimbusColorWithAlpha(Fore, 220); Text(TextValue, Bounds, TextColor);
  end;
  if (Length(G.Segments) > 0) and (O.ShowCenterLabel or O.ShowCenterValue) then
  begin
    Radius := Max(1.0, G.InnerRadius - 8 * DPI); Bounds := Rect(Round(G.Center.X - Radius), Round(G.Center.Y - Radius), Round(G.Center.X + Radius), Round(G.Center.Y + Radius));
    Init(ncpEllipse, NimbusColorWithAlpha(Back, 248)); A.Bounds := Bounds; Add; A.Kind := ncpOutlineEllipse; A.Color := NimbusColorWithAlpha(Fore, 44); Add;
    TextValue := ''; if O.ShowCenterLabel then begin TextValue := O.CenterTitle; if TextValue = '' then TextValue := C.Model.Title end;
    if O.ShowCenterValue then begin if TextValue <> '' then TextValue := TextValue + sLineBreak; TextValue := TextValue + SparklineFormatValue(G.VisibleValue, O.ValueFormat) end;
    Text(TextValue, Bounds, Fore, True);
  end;
  if O.ShowBreadcrumb then
  begin TextValue := 'All'; if O.IsZoomed then TextValue := TextValue + ' / ' + StringReplace(O.ZoomPath, '/', ' / ', [rfReplaceAll]); Text(TextValue, Rect(L.PlotArea.Left, L.PlotArea.Bottom + Round(6 * DPI), L.PlotArea.Right, L.PlotArea.Bottom + Round(26 * DPI)), NimbusColorWithAlpha(Fore, 175)) end;
  if O.ShowZoomBadge and O.IsZoomed then
  begin Bounds := Rect(L.PlotArea.Right - Round(180 * DPI), L.PlotArea.Top + Round(6 * DPI), L.PlotArea.Right - Round(6 * DPI), L.PlotArea.Top + Round(30 * DPI)); Init(ncpRect, NimbusColorWithAlpha(Back, 210)); A.Bounds := Bounds; A.CornerRadius := 12 * DPI; Add; Text('Zoom: ' + O.ZoomPath, Bounds, Fore) end;
  if Length(G.Segments) = 0 then Text(O.EmptyText, L.PlotArea, NimbusColorWithAlpha(Fore, 160));
end;

end.

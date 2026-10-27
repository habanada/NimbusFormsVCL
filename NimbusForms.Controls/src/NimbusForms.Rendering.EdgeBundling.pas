{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.EdgeBundling;

interface

uses System.Types, NimbusForms.Rendering.Charts, NimbusForms.Charts.Types;

type
  TNimbusHierarchicalEdgeBundlingRenderer = class(TNimbusChartRenderer)
  protected
    function Build(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>; override;
  public
    function CanRender(const AType: TNimbusChartType): Boolean; override;
  end;

implementation

uses System.Classes, System.SysUtils, System.Math, System.Generics.Collections, Vcl.Graphics,
  NimbusForms.Rendering.ChartPrimitives, NimbusForms.Charts.EdgeBundling.Types, NimbusForms.Charts.Sparkline.Types,
  NimbusForms.Rendering.Types, NimbusForms.Theming.Types;

function TNimbusHierarchicalEdgeBundlingRenderer.CanRender(const AType: TNimbusChartType): Boolean;
begin Result := AType = nctHierarchicalEdgeBundling end;

function TNimbusHierarchicalEdgeBundlingRenderer.Build(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>;
var D: TNimbusHierarchicalEdgeBundlingData; B: TNimbusChartPrimitiveBuilder; Map: TDictionary<string, Integer>; Groups, Parents, Categories: TStringList;
  Nodes, GroupIndex: TArray<Integer>; Positions: TArray<TPointF>; Angles: TArray<Double>; Path, Controls: TArray<TPointF>;
  SourceChain, TargetChain: TList<Integer>; I, J, K, N, A, Z, Source, Target, Group, Count, Common, Alpha, C0, C2, C3: Integer;
  DPI, Radius, CX, CY, Angle, Cursor, Sweep, Step, Gap, T, U, Strength, Width: Double;
  LabelSize: TSize; LabelWidth, LabelHeight: Integer; LabelFlags: TNimbusTextFlags;
  Node: TNimbusHierarchicalEdgeBundlingNode; Link: TNimbusHierarchicalEdgeBundlingLink; Hit: TNimbusChartHit;
  Col, SourceColor, TargetColor: TThemeColor; Plot, Bounds: TRect; TextValue, LinkKey: string; Active, HasActive: Boolean;
  function Key(const Value: string): string;
  begin Result := LowerCase(Trim(Value)) end;
  function Caption(const Index: Integer): string;
  begin Result := D.Nodes[Index].Caption; if Result = '' then Result := D.Nodes[Index].Id end;
  function NodeColor(const Index: Integer): TThemeColor;
  begin Result := B.Color(GroupIndex[Index], D.Nodes[Index].Color) end;
  function SelectedNode(const Index: Integer): Boolean;
  begin Result := ((C.Hovered.SeriesIndex = 0) and (C.Hovered.PointIndex = Index)) or ((C.Selected.SeriesIndex = 0) and (C.Selected.PointIndex = Index)) or (D.SelectedNodeIds.IndexOf(D.Nodes[Index].Id) >= 0) end;
  procedure Chain(const Index: Integer; const List: TList<Integer>);
  var Current, Parent: Integer;
  begin
    Current := Index; List.Clear;
    while (Current >= 0) and not List.Contains(Current) do
    begin List.Add(Current); if not Map.TryGetValue(Key(D.Nodes[Current].ParentId), Parent) then Break; Current := Parent end;
  end;
  function ControlPoint(const Index, Depth: Integer): TPointF;
  var R: Double;
  begin
    R := Radius * Power(0.55, Depth); if D.Nodes[Index].ParentId = '' then R := Radius * 0.2;
    Result := TPointF.Create(CX + Cos(Angles[Index]) * R, CY + Sin(Angles[Index]) * R);
  end;
begin
  Result := nil; if C.Model = nil then Exit; D := C.Model.EdgeBundling; B := TNimbusChartPrimitiveBuilder.Create(C, L);
  Map := TDictionary<string, Integer>.Create; Groups := TStringList.Create; Parents := TStringList.Create; Categories := TStringList.Create;
  SourceChain := TList<Integer>.Create; TargetChain := TList<Integer>.Create;
  try
    DPI := Max(1, C.PPI) / 96; Plot := L.PlotArea; if D.ShowLegend then Dec(Plot.Right, Round(125 * DPI));
    LabelWidth := 0; LabelHeight := 0;
    if D.ShowLabels then for I := 0 to D.Nodes.Count - 1 do if D.Nodes[I].Visible then
    begin LabelSize := NimbusChartMeasureLabel(C, Caption(I), Round(140 * DPI)); LabelWidth := Max(LabelWidth, LabelSize.cx); LabelHeight := Max(LabelHeight, LabelSize.cy) end;
    Radius := Max(0.0, Min(Plot.Width / 2 - LabelWidth, Plot.Height / 2 - LabelHeight) - 30 * DPI);
    if D.EnableZoom then Radius := Radius * D.ZoomScale; CX := Plot.CenterPoint.X; CY := Plot.CenterPoint.Y;
    N := D.Nodes.Count; SetLength(Nodes, N); SetLength(Positions, N); SetLength(Angles, N); SetLength(GroupIndex, N);
    for I := 0 to N - 1 do if D.Nodes[I].Visible then
    begin Map.AddOrSetValue(Key(D.Nodes[I].Id), I); if D.Nodes[I].ParentId <> '' then Parents.Add(Key(D.Nodes[I].ParentId)) end;
    for I := 0 to D.GroupOrder.Count - 1 do if Groups.IndexOf(D.GroupOrder[I]) < 0 then Groups.Add(D.GroupOrder[I]);
    Count := 0;
    for I := 0 to N - 1 do if D.Nodes[I].Visible and (Parents.IndexOf(Key(D.Nodes[I].Id)) < 0) then
    begin
      if Groups.IndexOf(D.Nodes[I].GroupKey) < 0 then Groups.Add(D.Nodes[I].GroupKey); GroupIndex[I] := Groups.IndexOf(D.Nodes[I].GroupKey); Nodes[Count] := I; Inc(Count);
    end;
    SetLength(Nodes, Count); if (Count = 0) or (Radius <= 0) then begin Result := B.Finish; Exit end;
    Gap := Min(Max(0.0, D.GroupGapDegrees), 180 / Max(1, Groups.Count)); Cursor := -90;
    for Group := 0 to Groups.Count - 1 do
    begin
      K := 0; for I in Nodes do if GroupIndex[I] = Group then Inc(K); if K = 0 then Continue;
      Sweep := (360 - Groups.Count * Gap) * K / Count; Step := Sweep / K; J := 0;
      for I in Nodes do if GroupIndex[I] = Group then
      begin Angles[I] := DegToRad(Cursor + Step * (J + 0.5)); Positions[I] := TPointF.Create(CX + Cos(Angles[I]) * Radius, CY + Sin(Angles[I]) * Radius); Inc(J) end;
      if D.ShowGroupRings then B.Arc(Rect(Round(CX - Radius - 12 * DPI), Round(CY - Radius - 12 * DPI), Round(CX + Radius + 12 * DPI), Round(CY + Radius + 12 * DPI)), B.Color(Group), Cursor, Sweep, 5 * DPI, TNimbusChartHit.None);
      if D.ShowLegend then B.Text(Groups[Group], Rect(Plot.Right + Round(10 * DPI), Plot.Top + Group * Round(26 * DPI), L.PlotArea.Right, Plot.Top + (Group + 1) * Round(26 * DPI)), B.Color(Group), TNimbusChartHit.None, [ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix]);
      Cursor := Cursor + Sweep + Gap;
    end;
    for I := 0 to N - 1 do if D.Nodes[I].Visible and (Parents.IndexOf(Key(D.Nodes[I].Id)) >= 0) then
    begin
      Angle := 0; K := 0; for J in Nodes do begin Chain(J, SourceChain); if SourceChain.Contains(I) then begin Angle := Angle + Angles[J]; Inc(K) end end;
      if K > 0 then Angles[I] := Angle / K else Angles[I] := 0; Positions[I] := ControlPoint(I, 1);
    end;
    HasActive := (C.Hovered.Area <> nchaNone) or (C.Selected.Area <> nchaNone) or (D.SelectedNodeIds.Count > 0) or (D.SelectedLinkKeys.Count > 0);
    for I := 0 to D.Links.Count - 1 do
    begin
      Link := D.Links[I]; if not Link.Visible or not SparklineFinite(Link.Value) then Continue;
      if not Map.TryGetValue(Key(Link.SourceId), Source) or not Map.TryGetValue(Key(Link.TargetId), Target) then Continue;
      if (Source = Target) or (Parents.IndexOf(Key(Link.SourceId)) >= 0) or (Parents.IndexOf(Key(Link.TargetId)) >= 0) then Continue;
      LinkKey := Link.SourceId + '->' + Link.TargetId;
      Active := ((C.Hovered.SeriesIndex = 1) and (C.Hovered.PointIndex = I)) or ((C.Selected.SeriesIndex = 1) and (C.Selected.PointIndex = I)) or (D.SelectedLinkKeys.IndexOf(LinkKey) >= 0);
      if D.HighlightConnectedNodes then Active := Active or SelectedNode(Source) or SelectedNode(Target);
      Alpha := Round(D.LinkOpacity * 255); if Active then Alpha := Round(D.SelectedLinkOpacity * 255) else if HasActive then Alpha := Round(Alpha * 0.2);
      Col := NodeColor(Source); if D.UseCategoryColors then begin Group := Categories.IndexOf(Link.Category); if Group < 0 then Group := Categories.Add(Link.Category); Col := B.Color(Group) end;
      if D.LinkColor <> clNone then Col := ColorToThemeColor(D.LinkColor); if Link.Color <> clNone then Col := ColorToThemeColor(Link.Color);
      if Active and (D.SelectedLinkColor <> clNone) then Col := ColorToThemeColor(D.SelectedLinkColor);
      Hit := TNimbusChartHit.None; Hit.Area := nchaSegment; Hit.SeriesIndex := 1; Hit.PointIndex := I; Hit.ElementIndex := I; Hit.XValue := Source; Hit.YValue := Link.Value;
      Hit.Text := Caption(Source) + ' -> ' + Caption(Target) + sLineBreak + 'Value: ' + SparklineFormatValue(Link.Value, '0.##'); if Link.Caption <> '' then Hit.Text := Link.Caption + sLineBreak + Hit.Text;
      Chain(Source, SourceChain); Chain(Target, TargetChain); Common := -1;
      for J := 0 to SourceChain.Count - 1 do if TargetChain.Contains(SourceChain[J]) then begin Common := SourceChain[J]; Break end;
      SetLength(Controls, 0); SetLength(Controls, 1); Controls[0] := Positions[Source];
      for J := 1 to SourceChain.Count - 1 do begin K := Length(Controls); SetLength(Controls, K + 1); Controls[K] := ControlPoint(SourceChain[J], J); if SourceChain[J] = Common then Break end;
      if Common < 0 then begin K := Length(Controls); SetLength(Controls, K + 1); Controls[K] := TPointF.Create(CX, CY) end;
      Z := TargetChain.Count - 1; if Common >= 0 then Z := TargetChain.IndexOf(Common) - 1;
      for J := Z downto 1 do begin K := Length(Controls); SetLength(Controls, K + 1); Controls[K] := ControlPoint(TargetChain[J], J) end;
      K := Length(Controls); SetLength(Controls, K + 1); Controls[K] := Positions[Target]; Strength := 0; if D.BundleLinks then Strength := D.BundleStrength;
      SetLength(Path, 65);
      for J := 0 to 64 do
      begin
        T := J / 64; U := T * (Length(Controls) - 1); A := Min(Length(Controls) - 2, Floor(U)); U := U - A;
        C0 := Max(0, A - 1); C2 := A + 1; C3 := Min(High(Controls), A + 2);
        Path[J] := TPointF.Create(0.5 * (2 * Controls[A].X + (-Controls[C0].X + Controls[C2].X) * U + (2 * Controls[C0].X - 5 * Controls[A].X + 4 * Controls[C2].X - Controls[C3].X) * Sqr(U) + (-Controls[C0].X + 3 * Controls[A].X - 3 * Controls[C2].X + Controls[C3].X) * U * U * U),
          0.5 * (2 * Controls[A].Y + (-Controls[C0].Y + Controls[C2].Y) * U + (2 * Controls[C0].Y - 5 * Controls[A].Y + 4 * Controls[C2].Y - Controls[C3].Y) * Sqr(U) + (-Controls[C0].Y + 3 * Controls[A].Y - 3 * Controls[C2].Y + Controls[C3].Y) * U * U * U));
        Path[J] := TPointF.Create(Path[J].X * Strength + (Positions[Source].X * (1 - T) + Positions[Target].X * T) * (1 - Strength), Path[J].Y * Strength + (Positions[Source].Y * (1 - T) + Positions[Target].Y * T) * (1 - Strength));
      end;
      Width := Max(DPI, Min(4 * DPI, Sqrt(Max(0.0, Link.Value)) * DPI * 0.3)); 
      SourceColor := Col; TargetColor := NodeColor(Target);
      if Active and not Hit.SameElement(C.Hovered) and not Hit.SameElement(C.Selected) then
      begin B.Line(Path, NimbusColorWithAlpha(Col, 16), Width + 4 * DPI, TNimbusChartHit.None); B.Line(Path, NimbusColorWithAlpha(Col, 30), Width + 2 * DPI, TNimbusChartHit.None) end;
      if D.UseDirectionalLinkGradient then for J := 1 to High(Path) do B.Line([Path[J - 1], Path[J]], NimbusColorWithAlpha(NimbusBlendColor(SourceColor, TargetColor, Round(J * 255 / High(Path))), Alpha), Width, Hit)
      else B.Line(Path, NimbusColorWithAlpha(Col, Alpha), Width, Hit);
      if D.ShowLinkDirection then
      begin Angle := ArcTan2(Path[64].Y - Path[61].Y, Path[64].X - Path[61].X); B.Polygon([Path[62], TPointF.Create(Path[62].X - Cos(Angle - 0.45) * 7 * DPI, Path[62].Y - Sin(Angle - 0.45) * 7 * DPI), TPointF.Create(Path[62].X - Cos(Angle + 0.45) * 7 * DPI, Path[62].Y - Sin(Angle + 0.45) * 7 * DPI)], NimbusColorWithAlpha(NimbusBlendColor(TargetColor, ChartForeColor(C), 70), Min(255, Alpha + 25)), Hit) end;
    end;
    for I in Nodes do
    begin
      Node := D.Nodes[I]; Hit := TNimbusChartHit.None; Hit.Area := nchaPoint; Hit.SeriesIndex := 0; Hit.PointIndex := I; Hit.ElementIndex := I; Hit.XValue := RadToDeg(Angles[I]); Hit.YValue := Node.Value; Hit.Text := Caption(I) + sLineBreak + 'Value: ' + SparklineFormatValue(Node.Value, '0.##');
      Col := NodeColor(I);
      if SelectedNode(I) and not Hit.SameElement(C.Hovered) and not Hit.SameElement(C.Selected) then
      begin
        Bounds := Rect(Round(Positions[I].X - (D.NodeRadius + 3) * DPI), Round(Positions[I].Y - (D.NodeRadius + 3) * DPI), Round(Positions[I].X + (D.NodeRadius + 3) * DPI), Round(Positions[I].Y + (D.NodeRadius + 3) * DPI));
        B.Ellipse(Bounds, NimbusColorWithAlpha(Col, 24), TNimbusChartHit.None); B.Ellipse(Bounds, NimbusColorWithAlpha(Col, 150), TNimbusChartHit.None, True);
      end;
      if D.ShowNodeDots then B.Ellipse(Rect(Round(Positions[I].X - D.NodeRadius * DPI), Round(Positions[I].Y - D.NodeRadius * DPI), Round(Positions[I].X + D.NodeRadius * DPI), Round(Positions[I].Y + D.NodeRadius * DPI)), Col, Hit);
      if D.ShowLabels then
      begin
        TextValue := Caption(I); if (D.MaxLabelLength > 0) and (Length(TextValue) > D.MaxLabelLength) then TextValue := Copy(TextValue, 1, D.MaxLabelLength) + '...';
        LabelSize := NimbusChartMeasureLabel(C, TextValue, Round(140 * DPI));
        Bounds := NimbusChartRadialLabel(TPointF.Create(CX, CY), Radius, Angles[I], 24 * DPI, LabelSize, LabelFlags);
        B.Text(TextValue, Bounds, ChartForeColor(C), Hit, LabelFlags);
      end;
    end;
    Result := B.Finish;
  finally TargetChain.Free; SourceChain.Free; Categories.Free; Parents.Free; Groups.Free; Map.Free; B.Free end;
end;

end.

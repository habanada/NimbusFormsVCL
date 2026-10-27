{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.Sankey;

interface

uses System.Types, NimbusForms.Charts.Types, NimbusForms.Rendering.Charts;

type
  TNimbusSankeyNodeGeometry = record
    Index, Layer: Integer;
    Id, Caption: string;
    Value: Double;
    Bounds: TRectF;
  end;
  TNimbusSankeyLinkGeometry = record
    Index, Source, Target: Integer;
    Value, Thickness: Double;
    Caption, ToolTipText: string;
    Polygon: TArray<TPointF>;
  end;
  TNimbusSankeyGeometry = record
    Nodes: TArray<TNimbusSankeyNodeGeometry>;
    Links: TArray<TNimbusSankeyLinkGeometry>;
    LayerCount: Integer;
  end;
  TNimbusSankeyChartRenderer = class(TNimbusChartRenderer)
  protected
    function Build(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>; override;
  public
    function CanRender(const AType: TNimbusChartType): Boolean; override;
    function Arrange(const C: TNimbusChartRenderContext): TNimbusChartLayout; override;
    function GetGeometry(const C: TNimbusChartRenderContext; const Plot: TRect): TNimbusSankeyGeometry;
  end;

implementation

uses System.SysUtils, System.Math, System.Generics.Collections, Vcl.Graphics,
  NimbusForms.Charts.Sankey.Types, NimbusForms.Charts.Sparkline.Types, NimbusForms.Rendering.Types, NimbusForms.Theming.Types;

function TNimbusSankeyChartRenderer.CanRender(const AType: TNimbusChartType): Boolean;
begin Result := AType = nctSankey end;

function TNimbusSankeyChartRenderer.Arrange(const C: TNimbusChartRenderContext): TNimbusChartLayout;
var Pad: Integer;
begin
  Result := inherited Arrange(C); if C.Model = nil then Exit; Pad := NimbusScaleValue(18, C.PPI);
  Result.PlotArea.Inflate(-Pad, -Pad);
  if C.Model.Sankey.ShowStageHeaders then Inc(Result.PlotArea.Top, Round((C.Model.Sankey.StageHeaderHeight + 8) * C.PPI / 96));
  Result.PlotArea.Right := Max(Result.PlotArea.Left, Result.PlotArea.Right); Result.PlotArea.Bottom := Max(Result.PlotArea.Top, Result.PlotArea.Bottom);
end;

function TNimbusSankeyChartRenderer.GetGeometry(const C: TNimbusChartRenderContext; const Plot: TRect): TNimbusSankeyGeometry;
var G: TNimbusSankeyGeometry; D: TNimbusSankeyData; Map: TDictionary<string, Integer>; Hidden: TDictionary<string, Boolean>;
  Incoming, Outgoing, SourceOffset, TargetOffset, Heights, Scores: TArray<Double>;
  Degrees, Queue, Order: TArray<Integer>; I, J, K, N, Layer, Head, Tail, Pass, Temp, Count: Integer;
  DPI, Scale, Padding, NodeWidth, Total, Y, X, H, T, U, SX, SY, TX, TY, BX, BY, Available: Double;
  Link: TNimbusSankeyLinkGeometry; Node: TNimbusSankeyNodeGeometry; S: TNimbusChartSeries; P: TNimbusChartPoint;
  function Key(const Id: string): string;
  begin Result := LowerCase(Trim(Id)) end;
  function AddNode(const Id, Caption: string; const Index: Integer; const AllowCreate: Boolean): Integer;
  var Name: string;
  begin
    Result := -1; Name := Key(Id); if (Name = '') or Hidden.ContainsKey(Name) then Exit;
    if Map.TryGetValue(Name, Result) then Exit; Result := -1; if not AllowCreate then Exit;
    Result := Length(G.Nodes); Node := Default(TNimbusSankeyNodeGeometry); Node.Id := Id; Node.Caption := Caption;
    if Node.Caption = '' then Node.Caption := Id; Node.Index := Index;
    SetLength(G.Nodes, Result + 1); G.Nodes[Result] := Node; Map.Add(Name, Result);
  end;
  procedure AddLink(const Source, Target, Caption, ToolTipText: string; const Value: Double; const Index: Integer);
  var A, B, LengthLinks: Integer;
  begin
    if IsNan(Value) or IsInfinite(Value) or (Value <= 0) then Exit;
    A := AddNode(Source, Source, -1, D.AutoCreateMissingNodes); B := AddNode(Target, Target, -1, D.AutoCreateMissingNodes);
    if (A < 0) or (B < 0) or (A = B) then Exit;
    Link := Default(TNimbusSankeyLinkGeometry); Link.Source := A; Link.Target := B; Link.Index := Index; Link.Value := Value;
    Link.Caption := Caption; Link.ToolTipText := ToolTipText; LengthLinks := Length(G.Links);
    SetLength(G.Links, LengthLinks + 1); G.Links[LengthLinks] := Link;
  end;
begin
  Result := Default(TNimbusSankeyGeometry); G := Result; if (C.Model = nil) or Plot.IsEmpty then Exit; D := C.Model.Sankey;
  Map := TDictionary<string, Integer>.Create; Hidden := TDictionary<string, Boolean>.Create;
  try
    for I := 0 to D.Nodes.Count - 1 do D.Nodes[I].UpdateLayout(TRectF.Empty, 0, 0);
    for I := 0 to D.Nodes.Count - 1 do if not D.Nodes[I].Visible then Hidden.AddOrSetValue(Key(D.Nodes[I].Id), True);
    for I := 0 to D.Nodes.Count - 1 do if D.Nodes[I].Visible then AddNode(D.Nodes[I].Id, D.Nodes[I].&Label, I, True);
    for I := 0 to D.Links.Count - 1 do if D.Links[I].Visible then AddLink(D.Links[I].SourceId, D.Links[I].TargetId, D.Links[I].&Label, D.Links[I].ToolTipText, D.Links[I].Value, I);
    if (D.Nodes.Count = 0) and (D.Links.Count = 0) and (C.Model.Series.Count > 0) then
    begin
      S := C.Model.Series[0]; if S.Visible then for I := 0 to S.Points.Count - 1 do
      begin P := S.Points[I]; if P.Visible then AddLink(S.Name, P.&Label, P.&Label, P.ToolTipText, P.YValue, I) end;
    end;
    N := Length(G.Nodes); if N = 0 then Exit;
    SetLength(Incoming, N); SetLength(Outgoing, N); SetLength(Degrees, N); SetLength(Queue, N); SetLength(Order, N);
    SetLength(SourceOffset, N); SetLength(TargetOffset, N); SetLength(Heights, N); SetLength(Scores, N);
    for Link in G.Links do begin Incoming[Link.Target] := Incoming[Link.Target] + Link.Value; Outgoing[Link.Source] := Outgoing[Link.Source] + Link.Value; Inc(Degrees[Link.Target]) end;
    Head := 0; Tail := 0;
    for I := 0 to N - 1 do begin G.Nodes[I].Value := Max(Incoming[I], Outgoing[I]); Order[I] := I; if Degrees[I] = 0 then begin Queue[Tail] := I; Inc(Tail) end end;
    while Head < Tail do
    begin
      I := Queue[Head]; Inc(Head);
      for Link in G.Links do if Link.Source = I then
      begin
        J := Link.Target; G.Nodes[J].Layer := Max(G.Nodes[J].Layer, G.Nodes[I].Layer + 1); Dec(Degrees[J]);
        if Degrees[J] = 0 then begin Queue[Tail] := J; Inc(Tail) end;
      end;
    end;
    for I := 0 to N - 1 do G.LayerCount := Max(G.LayerCount, G.Nodes[I].Layer + 1);
    for I := 0 to N - 1 do if Degrees[I] > 0 then begin G.Nodes[I].Layer := G.LayerCount; Inc(G.LayerCount) end;
    for I := 1 to N - 1 do begin J := I; while (J > 0) and (G.Nodes[Order[J]].Layer < G.Nodes[Order[J - 1]].Layer) do
      begin Temp := Order[J]; Order[J] := Order[J - 1]; Order[J - 1] := Temp; Dec(J) end end;
    for Pass := 0 to 5 do
    begin
      for I := 0 to N - 1 do
      begin
        Total := 0; Scores[I] := I;
        for Link in G.Links do
          if ((Pass mod 2 = 0) and (Link.Target = Order[I])) or ((Pass mod 2 = 1) and (Link.Source = Order[I])) then
          begin
            if Pass mod 2 = 0 then J := Link.Source else J := Link.Target;
            for K := 0 to N - 1 do if Order[K] = J then begin if Total = 0 then Scores[I] := 0; Scores[I] := Scores[I] + K * Link.Value; Total := Total + Link.Value; Break end;
          end;
        if Total > 0 then Scores[I] := Scores[I] / Total;
      end;
      for I := 1 to N - 1 do begin J := I; while (J > 0) and (G.Nodes[Order[J]].Layer = G.Nodes[Order[J - 1]].Layer) and (Scores[J] < Scores[J - 1]) do
        begin Temp := Order[J]; Order[J] := Order[J - 1]; Order[J - 1] := Temp; T := Scores[J]; Scores[J] := Scores[J - 1]; Scores[J - 1] := T; Dec(J) end end;
    end;
    DPI := Max(1, C.PPI) / 96; Padding := D.NodePadding * DPI; NodeWidth := Min(D.NodeWidth * DPI, Plot.Width / Max(1, G.LayerCount * 2)); Scale := MaxDouble;
    for Layer := 0 to G.LayerCount - 1 do
    begin
      Total := 0; Count := 0;
      for Node in G.Nodes do if Node.Layer = Layer then begin Total := Total + Node.Value; Inc(Count) end;
      if Count > 1 then Padding := Min(Padding, Plot.Height / (Count * 3));
      Available := Max(0.0, Plot.Height - Max(0, Count - 1) * Padding);
      if Total > 0 then Scale := Min(Scale, Available / Total);
    end;
    if Scale = MaxDouble then Scale := 0;
    for Layer := 0 to G.LayerCount - 1 do
    begin
      H := 0; Count := 0;
      for I := 0 to N - 1 do if G.Nodes[I].Layer = Layer then begin Heights[I] := Max(Min(14 * DPI, Plot.Height / N), G.Nodes[I].Value * Scale); H := H + Heights[I]; Inc(Count) end;
      H := H + Max(0, Count - 1) * Padding; if H > Plot.Height then for I := 0 to N - 1 do if G.Nodes[I].Layer = Layer then Heights[I] := Heights[I] * Max(0.0, Plot.Height - Max(0, Count - 1) * Padding) / Max(1.0, H - Max(0, Count - 1) * Padding);
      H := 0; for I := 0 to N - 1 do if G.Nodes[I].Layer = Layer then H := H + Heights[I]; H := H + Max(0, Count - 1) * Padding;
      Y := Plot.Top + Max(0.0, (Plot.Height - H) / 2); X := Plot.Left + (Plot.Width - NodeWidth) * Layer / Max(1, G.LayerCount - 1);
      if G.LayerCount = 1 then X := Plot.Left + (Plot.Width - NodeWidth) / 2;
      for K := 0 to N - 1 do begin I := Order[K]; if G.Nodes[I].Layer <> Layer then Continue;
        G.Nodes[I].Bounds := TRectF.Create(X, Y, X + NodeWidth, Y + Heights[I]); Y := Y + Heights[I] + Padding end;
    end;
    for Node in G.Nodes do if Node.Index >= 0 then D.Nodes[Node.Index].UpdateLayout(Node.Bounds, Node.Value, Node.Layer);
    for I := 0 to High(G.Links) do
    begin
      Link := G.Links[I]; J := Link.Source; K := Link.Target;
      H := Link.Value * Min(Heights[J] / Max(G.Nodes[J].Value, 1E-100), Heights[K] / Max(G.Nodes[K].Value, 1E-100));
      SX := G.Nodes[J].Bounds.Right; TX := G.Nodes[K].Bounds.Left;
      SY := G.Nodes[J].Bounds.Top + SourceOffset[J]; TY := G.Nodes[K].Bounds.Top + TargetOffset[K];
      SourceOffset[J] := SourceOffset[J] + H; TargetOffset[K] := TargetOffset[K] + H;
      SetLength(Link.Polygon, 66); Link.Thickness := H;
      for K := 0 to 32 do
      begin
        T := K / 32; U := 1 - T; BX := U * U * U * SX + 3 * U * U * T * (SX + (TX - SX) * 0.5) + 3 * U * T * T * (SX + (TX - SX) * 0.5) + T * T * T * TX;
        BY := SY + (TY - SY) * (3 * T * T - 2 * T * T * T);
        Link.Polygon[K] := TPointF.Create(BX, BY); Link.Polygon[65 - K] := TPointF.Create(BX, BY + H);
      end;
      G.Links[I] := Link;
    end;
  finally Result := G; Hidden.Free; Map.Free end;
end;

function TNimbusSankeyChartRenderer.Build(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>;
var G: TNimbusSankeyGeometry; D: TNimbusSankeyData; Items: TList<TNimbusChartPrimitive>; Labels: TList<TRect>;
  A: TNimbusChartPrimitive; Hit: TNimbusChartHit; I, J, K, Alpha, ActiveNode, ActiveLink, Height, HeaderHeight: Integer;
  Col, SourceColor, TargetColor, Back: TThemeColor; Node: TNimbusSankeyNodeGeometry; Link: TNimbusSankeyLinkGeometry;
  B: TRect; TextValue: string; Connected, HasActive, CanPlace: Boolean; DPI, T: Double;
  function NodeColor(const Index: Integer): TThemeColor;
  var ModelIndex: Integer;
  begin
    Result := ChartAccentColor(C); if C.ChartPalette <> nil then Result := ColorToThemeColor(C.ChartPalette.GetSeriesColor(Index));
    ModelIndex := G.Nodes[Index].Index;
    if (ModelIndex >= 0) and (D.Nodes[ModelIndex].Color <> clNone) then Result := ColorToThemeColor(D.Nodes[ModelIndex].Color);
    if not C.Enabled then Result := NimbusBlendColor(Result, Back, 160);
  end;
  function NodeHitIndex(const Index: Integer): Integer;
  begin Result := G.Nodes[Index].Index; if Result < 0 then Result := D.Nodes.Count + Index end;
  procedure Add(const Kind: TNimbusChartPrimitiveKind; const Color: TThemeColor; const Bounds: TRect);
  begin A := Default(TNimbusChartPrimitive); A.Kind := Kind; A.Color := Color; A.Bounds := Bounds; A.Hit := Hit; A.Width := 1 end;
  procedure Text(const Value: string; const Bounds: TRect; const Center, Backplate: Boolean; const Avoid: Boolean);
  var Reserved: TRect;
  begin
    if (Value = '') or Bounds.IsEmpty then Exit; B := Bounds; CanPlace := True;
    if Avoid then for Reserved in Labels do if TRect.Intersect(B, Reserved).IsEmpty = False then begin CanPlace := False; Break end;
    if not CanPlace then Exit; Labels.Add(B);
    if Backplate then begin Add(ncpRect, NimbusColorWithAlpha(Back, 225), B); A.UseCornerRadius := True; A.CornerRadius := 3 * DPI; Items.Add(A) end;
    Add(ncpText, ChartForeColor(C), B); A.Text := Value; A.TextFlags := [ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix];
    if Center then Include(A.TextFlags, ntfCenter); A.UseClip := True; A.ClipBounds := B; Items.Add(A);
  end;
begin
  Result := nil; if C.Model = nil then Exit; D := C.Model.Sankey; G := GetGeometry(C, L.PlotArea); if Length(G.Nodes) = 0 then Exit;
  Items := TList<TNimbusChartPrimitive>.Create; Labels := TList<TRect>.Create;
  try
    Back := ChartBackColor(C); DPI := Max(1, C.PPI) / 96; Height := Max(Round(18 * DPI), Abs(C.Font.Height) + Round(4 * DPI));
    HeaderHeight := Round(D.StageHeaderHeight * DPI); ActiveNode := -1; ActiveLink := -1;
    if C.Hovered.SeriesIndex = 1 then ActiveNode := C.Hovered.PointIndex else if C.Selected.SeriesIndex = 1 then ActiveNode := C.Selected.PointIndex;
    if C.Hovered.SeriesIndex = 0 then ActiveLink := C.Hovered.PointIndex else if C.Selected.SeriesIndex = 0 then ActiveLink := C.Selected.PointIndex;
    HasActive := (ActiveNode >= 0) or (ActiveLink >= 0);
    Hit := TNimbusChartHit.None;
    if C.Model.Options.ShowTitle then Text(C.Model.Title, L.TitleBounds, False, False, False);
    if C.Model.Options.ShowSubtitle then Text(C.Model.Subtitle, L.SubtitleBounds, False, False, False);
    if D.ShowStageHeaders then for I := 0 to G.LayerCount - 1 do
    begin
      Hit := TNimbusChartHit.None; TextValue := 'Stage ' + IntToStr(I + 1); if I < D.StageTitles.Count then TextValue := D.StageTitles[I];
      J := L.PlotArea.Left + Round(L.PlotArea.Width * I / Max(1, G.LayerCount)); K := L.PlotArea.Left + Round(L.PlotArea.Width * (I + 1) / Max(1, G.LayerCount));
      B := Rect(J, L.PlotArea.Top - HeaderHeight - Round(8 * DPI), K, L.PlotArea.Top - Round(8 * DPI));
      if D.CompactStageHeaders then B.Inflate(-Round(4 * DPI), 0);
      Text(TextValue, B, True, D.ShowStageHeaderBackplates, False);
    end;
    for Link in G.Links do
    begin
      Hit := TNimbusChartHit.None; Hit.Area := nchaSegment; Hit.SeriesIndex := 0; Hit.PointIndex := Link.Index; Hit.ElementIndex := Link.Index; Hit.YValue := Link.Value; Hit.XValue := Link.Value;
      Hit.Text := Link.ToolTipText; if Hit.Text = '' then Hit.Text := G.Nodes[Link.Source].Caption + ' -> ' + G.Nodes[Link.Target].Caption + sLineBreak + 'Value: ' + SparklineFormatValue(Link.Value, '0.##');
      Connected := (Link.Index = ActiveLink) or (NodeHitIndex(Link.Source) = ActiveNode) or (NodeHitIndex(Link.Target) = ActiveNode);
      Alpha := Round(255 * D.LinkOpacity); if HasActive then if Connected then Alpha := 215 else Alpha := 38;
      SourceColor := NodeColor(Link.Source); TargetColor := NodeColor(Link.Target); Col := SourceColor;
      if D.LinkColor <> clNone then Col := ColorToThemeColor(D.LinkColor);
      if (Link.Index < D.Links.Count) and (D.Links[Link.Index].Color <> clNone) then Col := ColorToThemeColor(D.Links[Link.Index].Color);
      if D.UseLinkGradient and (D.LinkColor = clNone) and ((Link.Index >= D.Links.Count) or (D.Links[Link.Index].Color = clNone)) then
        for J := 0 to 31 do begin Add(ncpPolygon, NimbusColorWithAlpha(NimbusBlendColor(SourceColor, TargetColor, Round(255 * J / 31)), Alpha), TRect.Empty);
          A.Points := [Link.Polygon[J], Link.Polygon[J + 1], Link.Polygon[64 - J], Link.Polygon[65 - J]]; A.SuppressHighlight := True; Items.Add(A) end
      else begin Add(ncpPolygon, NimbusColorWithAlpha(Col, Alpha), TRect.Empty); A.Points := Link.Polygon; Items.Add(A) end;
      if D.UseLinkGradient then begin Add(ncpPolygon, 0, TRect.Empty); A.Points := Link.Polygon; Items.Add(A) end;
    end;
    for I := 0 to High(G.Nodes) do
    begin
      Node := G.Nodes[I]; Hit := TNimbusChartHit.None; Hit.Area := nchaPoint; Hit.SeriesIndex := 1; Hit.PointIndex := Node.Index;
      if Hit.PointIndex < 0 then Hit.PointIndex := D.Nodes.Count + I;
      Hit.ElementIndex := I; Hit.XValue := Node.Layer; Hit.YValue := Node.Value; Hit.Text := Node.Caption + sLineBreak + 'Value: ' + SparklineFormatValue(Node.Value, '0.##');
      B := Rect(Floor(Node.Bounds.Left), Floor(Node.Bounds.Top), Ceil(Node.Bounds.Right), Ceil(Node.Bounds.Bottom));
      Add(ncpRect, NodeColor(I), B); A.UseCornerRadius := True; A.CornerRadius := 3 * DPI; Items.Add(A);
      if (Hit.PointIndex = ActiveNode) then begin Add(ncpOutlineRect, ChartForeColor(C), B); A.Width := Max(0.75, DPI); Items.Add(A) end;
      if D.ShowNodeLabels or D.ShowNodeValues then
      begin
        TextValue := ''; if D.ShowNodeLabels then TextValue := Node.Caption;
        if D.ShowNodeValues then begin if TextValue <> '' then TextValue := TextValue + '  '; TextValue := TextValue + SparklineFormatValue(Node.Value, '0.##') end;
        J := Round((Node.Bounds.Top + Node.Bounds.Bottom - Height) / 2);
        if (Node.Layer < G.LayerCount - 1) or not D.SmartNodeLabelPlacement then B := Rect(Ceil(Node.Bounds.Right + 5 * DPI), J, Min(L.PlotArea.Right, Ceil(Node.Bounds.Right + L.PlotArea.Width / Max(1, G.LayerCount))), J + Height)
        else B := Rect(Max(L.PlotArea.Left, Floor(Node.Bounds.Left - L.PlotArea.Width / Max(1, G.LayerCount))), J, Floor(Node.Bounds.Left - 5 * DPI), J + Height);
        Text(TextValue, B, False, D.ShowNodeLabelBackplates, D.AvoidNodeLabelCollisions);
      end;
    end;
    if D.ShowLinkLabels then for Link in G.Links do
    begin
      Hit := TNimbusChartHit.None; TextValue := Link.Caption; if TextValue = '' then TextValue := SparklineFormatValue(Link.Value, '0.##');
      T := Link.Polygon[16].X; J := Round(Link.Polygon[16].Y + (Link.Thickness - Height) / 2);
      Text(TextValue, Rect(Round(T - 45 * DPI), J, Round(T + 45 * DPI), J + Height), True, True, D.AvoidLabelCollisions);
    end;
    Result := Items.ToArray;
  finally Labels.Free; Items.Free end;
end;

end.

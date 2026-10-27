{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.ProgressRingGrid;

interface

uses System.Types, NimbusForms.Rendering.Charts, NimbusForms.Charts.Types;

type
  TNimbusProgressRingGridRenderer = class(TNimbusChartRenderer)
  protected
    function Build(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>; override;
  public
    function CanRender(const AType: TNimbusChartType): Boolean; override;
  end;

implementation

uses System.SysUtils, System.Math, Vcl.Graphics, NimbusForms.Rendering.ChartPrimitives,
  NimbusForms.Charts.ProgressRingGrid.Types, NimbusForms.Charts.Sparkline.Types, NimbusForms.Rendering.Types, NimbusForms.Theming.Types;

function TNimbusProgressRingGridRenderer.CanRender(const AType: TNimbusChartType): Boolean;
begin Result := AType = nctProgressRingGrid end;

function TNimbusProgressRingGridRenderer.Build(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>;
var B: TNimbusChartPrimitiveBuilder; D: TNimbusProgressRingGridData; Item: TNimbusProgressRingItem; Layer: TNimbusProgressRingLayer;
  Visible: TArray<Integer>; I, J, K, N, Columns, Rows, LayerCount, DetailCount, TextHeight: Integer;
  Plot, Detail, Tile, Ring, TextBounds: TRect; Hit: TNimbusChartHit; DPI, Gap, CellW, CellH, CX, CY, Radius, Average, DetailY: Double;
  Track, Progress, Fore: TThemeColor; Flags: TNimbusTextFlags;
  function InheritedNumber(const Value, Fallback: Double): Double;
  begin if IsNan(Value) or IsInfinite(Value) then Result := Fallback else Result := Value end;
  function Positive(const Value, Fallback: Double): Double;
  begin Result := InheritedNumber(Value, Fallback); if Result <= 0 then Result := Fallback end;
  function ResolveColor(const Custom: TColor; const Fallback: TThemeColor): TThemeColor;
  begin if Custom = clNone then Result := Fallback else Result := ColorToThemeColor(Custom) end;
  function ThresholdColor(const Thresholds: TNimbusProgressRingThresholdCollection; const Value: Double; const Fallback: TThemeColor): TThemeColor;
  var T: Integer;
  begin Result := Fallback; for T := 0 to Thresholds.Count - 1 do if (Value >= Thresholds[T].Minimum) and (Value <= Thresholds[T].Maximum) and (Thresholds[T].Color <> clNone) then Exit(ColorToThemeColor(Thresholds[T].Color)) end;
  procedure DrawRing(const Bounds: TRect; const Percent, Value, Start, Sweep, PT, TT, SegmentGap: Double; const SegmentCount: Integer;
    const Style: TNimbusProgressRingRenderStyle; const SegmentMode: TNimbusProgressRingSegmentMode; const TrackStyle: TNimbusProgressRingTrackStyle;
    const ColorMode: TNimbusProgressRingColorMode; const Segments: TNimbusProgressRingSegmentCollection; const Thresholds: TNimbusProgressRingThresholdCollection;
    const ProgressColor, TrackColor: TThemeColor; const Indeterminate: Boolean);
  var S, Count: Integer; Step, Active, SegmentSweep, Cursor, Sum, BorderWidth: Double; Col: TThemeColor; BorderBounds: TRect; EffectiveStyle: TNimbusProgressRingRenderStyle; EffectiveColor: TNimbusProgressRingColorMode; EffectiveTrack: TNimbusProgressRingTrackStyle; EffectiveSegment: TNimbusProgressRingSegmentMode;
  begin
    EffectiveStyle := Style; if EffectiveStyle = nprsContinuous then begin EffectiveStyle := Item.RenderStyle; if EffectiveStyle = nprsContinuous then EffectiveStyle := D.RenderStyle end;
    EffectiveColor := ColorMode; if EffectiveColor = nprcSingleColor then begin EffectiveColor := Item.ColorMode; if EffectiveColor = nprcSingleColor then EffectiveColor := D.ColorMode end;
    EffectiveTrack := TrackStyle; if EffectiveTrack = nprtSolid then begin EffectiveTrack := Item.TrackStyle; if EffectiveTrack = nprtSolid then EffectiveTrack := D.TrackStyle end;
    EffectiveSegment := SegmentMode; if EffectiveSegment = nprsmMasked then begin EffectiveSegment := Item.SegmentMode; if EffectiveSegment = nprsmMasked then EffectiveSegment := D.SegmentMode end;
    Count := EnsureRange(SegmentCount, 1, 512); Step := Sweep / Count; Active := EnsureRange(Percent, 0.0, 1.0) * Sweep;
    if D.ShowTrack and (EffectiveTrack <> nprtNone) then
      if EffectiveTrack = nprtSegmented then for S := 0 to Count - 1 do B.Arc(Bounds, TrackColor, Start + S * Step, Max(0.0, Step - SegmentGap), TT, Hit)
      else begin Col := TrackColor; if EffectiveTrack = nprtSubtle then Col := NimbusColorWithAlpha(Col, 50); B.Arc(Bounds, Col, Start, Sweep, TT, Hit) end;
    Col := ProgressColor;
    if (EffectiveStyle = nprsThreshold) or (EffectiveColor = nprcThresholdMapped) then Col := ThresholdColor(Thresholds, Value, ThresholdColor(D.Thresholds, Value, Col));
    if Indeterminate or (EffectiveStyle = nprsIndeterminate) then B.Arc(Bounds, Col, Start + C.AnimationProgress * 300, Min(90.0, Sweep), PT, Hit)
    else if (EffectiveStyle = nprsStacked) and (Segments.Count > 0) then
    begin
      Sum := 0; for S := 0 to Segments.Count - 1 do if SparklineFinite(Segments[S].Value) then Sum := Sum + Max(0.0, Segments[S].Value);
      Cursor := Start; if Sum > 0 then for S := 0 to Segments.Count - 1 do
      begin SegmentSweep := Max(0.0, Segments[S].Value) / Sum * Active; B.Arc(Bounds, B.Color(S, Segments[S].Color), Cursor, Max(0.0, SegmentSweep - SegmentGap), PT, Hit); Cursor := Cursor + SegmentSweep end;
    end
    else if EffectiveStyle = nprsSegmented then for S := 0 to Count - 1 do
    begin
      if EffectiveSegment = nprsmFixedStep then SegmentSweep := IfThen(S < Floor(Percent * Count), Step - SegmentGap, 0.0)
      else SegmentSweep := Min(Max(0.0, Step - SegmentGap), Max(0.0, Active - S * Step));
      if EffectiveColor = nprcPaletteBySegment then Col := B.Color(S);
      B.Arc(Bounds, Col, Start + S * Step, SegmentSweep, PT, Hit);
    end
    else B.Arc(Bounds, Col, Start, Active, PT, Hit);
    BorderWidth := Max(0.0, Item.RingBorderThickness); if BorderWidth = 0 then BorderWidth := Max(0.0, D.RingBorderThickness);
    if BorderWidth > 0 then begin BorderBounds := Bounds; BorderBounds.Inflate(Round(PT / 2 + BorderWidth * DPI), Round(PT / 2 + BorderWidth * DPI)); B.Arc(BorderBounds, ResolveColor(Item.RingBorderColor, ResolveColor(D.RingBorderColor, ChartBorderColor(C))), Start, Sweep, BorderWidth * DPI, TNimbusChartHit.None) end;
  end;
begin
  Result := nil; if C.Model = nil then Exit; D := C.Model.ProgressRingGrid; B := TNimbusChartPrimitiveBuilder.Create(C, L);
  try
    DPI := Max(1, C.PPI) / 96; Plot := L.PlotArea; Gap := Max(0.0, D.Gap * DPI); Flags := [ntfVCenter, ntfSingleLine, ntfCenter, ntfEndEllipsis, ntfNoPrefix]; Fore := ResolveColor(D.TextColor, ChartForeColor(C));
    TextHeight := Max(Round(22 * DPI), Abs(C.Font.Height) + Round(6 * DPI)); SetLength(Visible, D.Items.Count); N := 0; Average := 0;
    for I := 0 to D.Items.Count - 1 do if D.Items[I].Visible then begin Visible[N] := I; Inc(N); Average := Average + D.Items[I].Percent end;
    SetLength(Visible, N); if N = 0 then begin Result := B.Finish; Exit end; Average := Average / N;
    Detail := TRect.Empty;
    if D.ShowDetailPanel and (D.DetailPanelPosition <> nprdpNone) then
    begin
      Detail := Plot;
      if D.DetailPanelPosition = nprdpLeft then begin Detail.Right := Min(Plot.Right, Detail.Left + Round(Min(D.DetailPanelSize * DPI, Plot.Width * 0.38))); Plot.Left := Min(Plot.Right, Detail.Right + Round(Gap)) end
      else begin Detail.Bottom := Min(Plot.Bottom, Detail.Top + Round(Min(D.DetailPanelSize * DPI, Plot.Height * 0.38))); Plot.Top := Min(Plot.Bottom, Detail.Bottom + Round(Gap)) end;
      B.Box(Detail, ResolveColor(D.DetailPanelBackColor, ChartBackColor(C)), TNimbusChartHit.None, 6 * DPI);
      B.Box(Detail, ResolveColor(D.DetailPanelBorderColor, ChartBorderColor(C)), TNimbusChartHit.None, 6 * DPI, True);
      DetailY := Detail.Top + 8 * DPI; if D.ShowDetailHeader then begin B.Text(D.DetailTitle, Rect(Detail.Left + Round(8 * DPI), Round(DetailY), Detail.Right - Round(8 * DPI), Round(DetailY + TextHeight)), Fore, TNimbusChartHit.None, Flags); DetailY := DetailY + TextHeight + 8 * DPI end;
      DetailCount := 0;
      for I in Visible do if D.Items[I].ShowInDetailPanel then
      begin
        if (D.DetailPanelItemLimit > 0) and (DetailCount >= D.DetailPanelItemLimit) then Break;
        if DetailY + TextHeight > Detail.Bottom then Break; Hit := TNimbusChartHit.None; Hit.Area := nchaPoint; Hit.SeriesIndex := 0; Hit.PointIndex := I; Hit.ElementIndex := -1; Hit.YValue := D.Items[I].Value; Hit.XValue := D.Items[I].Percent; Hit.Text := D.Items[I].Title;
        TextBounds := Rect(Detail.Left + Round(8 * DPI), Round(DetailY), Detail.Right - Round(8 * DPI), Round(DetailY + TextHeight));
        if D.HighlightDetailPanelSelection and (C.Selected.PointIndex = I) then B.Box(TextBounds, NimbusColorWithAlpha(ChartAccentColor(C), 45), Hit, 3 * DPI);
        B.Text(D.Items[I].Title + '  ' + D.Items[I].GetDisplayValue, TextBounds, Fore, Hit, Flags); DetailY := DetailY + TextHeight + 3 * DPI; Inc(DetailCount);
      end;
    end;
    if Plot.IsEmpty then begin Result := B.Finish; Exit end;
    Columns := D.Columns; if D.AutoColumns or (Columns <= 0) then Columns := Max(1, Ceil(Sqrt(N * Plot.Width / Max(1, Plot.Height)))); Columns := EnsureRange(Columns, 1, N);
    Rows := D.Rows; if D.AutoRows or (Rows <= 0) then Rows := Ceil(N / Columns); Rows := Max(Rows, Ceil(N / Columns));
    CellW := Max(0.0, (Plot.Width - (Columns - 1) * Gap) / Columns); CellH := Max(0.0, (Plot.Height - (Rows - 1) * Gap) / Rows);
    Radius := 0;
    for J := 0 to N - 1 do
    begin
      I := Visible[J]; Item := D.Items[I]; Hit := TNimbusChartHit.None; Hit.Area := nchaPoint; Hit.SeriesIndex := 0; Hit.PointIndex := I; Hit.ElementIndex := -1; Hit.XValue := Item.Percent; Hit.YValue := Item.Value;
      Hit.Text := Item.ToolTipText; if Hit.Text = '' then Hit.Text := Item.Title + sLineBreak + Item.GetDisplayValue;
      if D.LayoutMode = nprlTileGrid then Tile := Rect(Round(Plot.Left + (J mod Columns) * (CellW + Gap)), Round(Plot.Top + (J div Columns) * (CellH + Gap)), Round(Plot.Left + (J mod Columns) * (CellW + Gap) + CellW), Round(Plot.Top + (J div Columns) * (CellH + Gap) + CellH))
      else Tile := Plot;
      CX := (Tile.Left + Tile.Right) / 2; CY := (Tile.Top + Tile.Bottom) / 2; Radius := Max(0.0, Min(Tile.Width, Tile.Height) / 2 - 12 * DPI);
      if D.LayoutMode = nprlConcentric then Radius := Radius * (N - J) / (N + 0.5)
      else if D.LayoutMode = nprlMasterSatellite then
      begin
        if J = 0 then Radius := Radius * 0.43 else
        begin CX := Plot.CenterPoint.X + Cos(2 * Pi * (J - 1) / Max(1, N - 1) - Pi / 2) * Radius * 0.7; CY := Plot.CenterPoint.Y + Sin(2 * Pi * (J - 1) / Max(1, N - 1) - Pi / 2) * Radius * 0.7; Radius := Radius * Min(0.22, 1 / Max(2, N / 2)) end;
      end
      else if (Item.TextPlacement = nprtpOutside) or ((Item.TextPlacement = nprtpInherit) and (D.TextPlacement = nprtpOutside)) then begin Radius := Max(0.0, Radius - TextHeight); CY := CY - TextHeight / 2 end;
      if Item.BackColor <> clNone then B.Box(Tile, ColorToThemeColor(Item.BackColor), TNimbusChartHit.None, 6 * DPI);
      LayerCount := 0; for K := 0 to Item.Layers.Count - 1 do if Item.Layers[K].Visible then Inc(LayerCount);
      if LayerCount = 0 then
      begin
        Ring := Rect(Round(CX - Radius), Round(CY - Radius), Round(CX + Radius), Round(CY + Radius));
        Track := ResolveColor(Item.TrackColor, ResolveColor(D.TrackColor, NimbusBlendColor(ChartBorderColor(C), ChartBackColor(C), 100)));
        Progress := ResolveColor(Item.ProgressColor, ResolveColor(D.ProgressColor, B.Color(I)));
        DrawRing(Ring, Item.Percent, Item.Value, InheritedNumber(Item.StartAngle, D.StartAngle), EnsureRange(InheritedNumber(Item.SweepAngle, D.SweepAngle), 0.0, 360.0),
          Positive(Item.ProgressThickness, D.ProgressThickness) * DPI, Positive(Item.TrackThickness, D.TrackThickness) * DPI, InheritedNumber(Item.SegmentGap, D.SegmentGap),
          Round(Positive(Item.SegmentCount, D.SegmentCount)), Item.RenderStyle, Item.SegmentMode, Item.TrackStyle, Item.ColorMode, Item.Segments, Item.Thresholds, Progress, Track, Item.IsIndeterminate);
      end
      else for K := 0 to Item.Layers.Count - 1 do
      begin
        Layer := Item.Layers[K]; if not Layer.Visible then Continue; Hit.ElementIndex := K; Hit.XValue := Layer.Percent; Hit.YValue := Layer.Value;
        Hit.Text := Layer.ToolTipText; if Hit.Text = '' then Hit.Text := Item.Title + ' / ' + Layer.Title + sLineBreak + Layer.GetDisplayValue;
        Ring := Rect(Round(CX - Radius), Round(CY - Radius), Round(CX + Radius), Round(CY + Radius));
        DrawRing(Ring, Layer.Percent, Layer.Value, InheritedNumber(Layer.StartAngle, InheritedNumber(Item.StartAngle, D.StartAngle)), EnsureRange(InheritedNumber(Layer.SweepAngle, InheritedNumber(Item.SweepAngle, D.SweepAngle)), 0.0, 360.0),
          Positive(Layer.ProgressThickness, Positive(Item.ProgressThickness, D.ProgressThickness)) * DPI, Positive(Layer.TrackThickness, D.TrackThickness) * DPI, InheritedNumber(Layer.SegmentGap, D.SegmentGap),
          Round(Positive(Layer.SegmentCount, D.SegmentCount)), Layer.RenderStyle, Layer.SegmentMode, Layer.TrackStyle, Layer.ColorMode, Layer.Segments, Layer.Thresholds,
          ResolveColor(Layer.ProgressColor, B.Color(K)), ResolveColor(Layer.TrackColor, NimbusBlendColor(ChartBorderColor(C), ChartBackColor(C), 100)), False);
        Radius := Max(0.0, Radius - (Positive(Layer.ProgressThickness, D.ProgressThickness) + Max(1.0, D.InnerGap)) * DPI);
      end;
      Hit.ElementIndex := -1; Hit.XValue := Item.Percent; Hit.YValue := Item.Value; Hit.Text := Item.Title + sLineBreak + Item.GetDisplayValue;
      if D.LayoutMode <> nprlConcentric then
      begin
        TextBounds := Rect(Round(CX - Radius * 0.75), Round(CY - TextHeight), Round(CX + Radius * 0.75), Round(CY + TextHeight));
        if D.ShowCenterText and (Item.TextMode <> nprtmNone) then
          case Item.TextMode of
            nprtmTitle: B.Text(Item.Title, TextBounds, ResolveColor(Item.TextColor, Fore), Hit, Flags);
            nprtmPercent: B.Text(SparklineFormatValue(Item.Percent * 100, '0.#') + '%', TextBounds, ResolveColor(Item.TextColor, Fore), Hit, Flags);
          else if D.ShowValues then B.Text(Item.GetDisplayValue, TextBounds, ResolveColor(Item.TextColor, Fore), Hit, Flags) end;
        if D.ShowLabels and (Item.TextMode in [nprtmTitle, nprtmTitleAndValue, nprtmTitleSubtitleValue]) then B.Text(Item.Title, Rect(Tile.Left, Round(CY + Radius + 8 * DPI), Tile.Right, Min(Tile.Bottom, Round(CY + Radius + 8 * DPI + TextHeight))), Fore, Hit, Flags);
        if Item.TextMode = nprtmTitleSubtitleValue then B.Text(Item.Subtitle, Rect(Tile.Left, Tile.Bottom - TextHeight, Tile.Right, Tile.Bottom), ResolveColor(D.MutedTextColor, Fore), Hit, Flags);
      end;
    end;
    if (D.LayoutMode = nprlConcentric) and D.ShowCenterAggregate then
    begin
      TextBounds := Rect(Plot.CenterPoint.X - Round(Radius), Plot.CenterPoint.Y - TextHeight * 2, Plot.CenterPoint.X + Round(Radius), Plot.CenterPoint.Y + TextHeight * 2);
      B.Text(D.CenterTitle + ' ' + SparklineFormatValue(Average * 100, '0.#') + '%' + ' ' + D.CenterSubtitle, TextBounds, Fore, TNimbusChartHit.None, Flags);
    end;
    Result := B.Finish;
  finally B.Free end;
end;

end.

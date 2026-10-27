{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.BusinessCharts;

interface

uses
  Winapi.Windows, System.Classes, System.Types, System.UITypes, System.SysUtils, System.Math,
  Vcl.Graphics, NimbusForms.Rendering.Types, NimbusForms.Theming.Types,
  NimbusForms.Charts.Types, NimbusForms.Charts.Sparkline.Types, NimbusForms.Rendering.Charts;

type
  TNimbusBusinessChartRenderer = class(TNimbusChartRenderer)
  protected
    function Build(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>; override;
  public
    function CanRender(const AType: TNimbusChartType): Boolean; override;
    function Arrange(const C: TNimbusChartRenderContext): TNimbusChartLayout; override;
  end;

implementation

uses NimbusForms.Rendering.Canvas;

type
  TNimbusBusinessPoint = record
    SeriesIndex, PointIndex: Integer;
    Point: TNimbusChartPoint;
  end;

function TNimbusBusinessChartRenderer.CanRender(const AType: TNimbusChartType): Boolean;
begin
  Result := AType in [nctBusinessRankedBar, nctBusinessTimelineRange, nctBusinessCalendarHeatmap, nctBusinessBullet, nctBusinessDivergingBar, nctBusinessFunnel, nctBusinessLollipopBar, nctBusinessRadialGoal, nctBusinessPortfolioArc, nctBusinessWaterfall, nctBusinessModernWaterfall, nctBusinessKpiTiles, nctBusinessPareto, nctBusinessStackedHorizontalBar];
end;

function TNimbusBusinessChartRenderer.Arrange(const C: TNimbusChartRenderContext): TNimbusChartLayout;
var P: Integer;
begin
  Result := inherited Arrange(C); P := NimbusScaleValue(4, C.PPI);
  if Result.PlotArea.Width > P * 2 then Result.PlotArea.Inflate(-P, 0);
  if Result.PlotArea.Height > P * 2 then Result.PlotArea.Inflate(0, -P);
end;

function TNimbusBusinessChartRenderer.Build(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>;
var
  Points: TArray<TNimbusBusinessPoint>; Items: TArray<TNimbusChartPrimitive>;
  A: TNimbusChartPrimitive; CurrentHit: TNimbusChartHit;
  M: TNimbusChartModel; S: TNimbusChartSeries; P: TNimbusChartPoint;
  Fore, Back, Muted, Track, Col, Empty, AxisColor: TThemeColor;
  R: TRect; I, J, K, Count, Capacity, PointCount, VisibleCount, Columns, Rows, CellCount: Integer;
  DPI, TopAxis, MinRowHeight, LabelWidth, ValueWidth, BarLeft, BarRight, BarTop, BarBottom: Double;
  RowHeight, RowTop, H, Y, W, X, X0, X1, Minimum, Maximum, Span, Value, Ratio, Gap, Cell: Double;
  GridLeft, GridTop, GridWidth, GridHeight, StartX, StartY, Footer, Swatch, SwatchX: Double;
  FunnelWidth, FunnelHeight, FunnelLeft, FunnelTop, LabelLeft, NameWidth, PercentWidth, TopWidth, BottomWidth, NextValue, Total: Double;
  Polygon, Outline: TArray<TPointF>;
  Active, Modern, TotalPoint: Boolean;
  BarBounds: TRect; Positive, Negative, MarkerColor, Shadow: TThemeColor;
  DotRadius, HalfMarker, ActualX, TargetX, CenterY, CenterX, Radius, Stroke, RingRadius, Sweep, Side: Double;
  CenterText: string;
  LegendHeight, RadiusStep, ItemWidth, Running, Finish, PreviousX, PreviousY, Slot, BarWidth, LabelHeight, ValueHeight, DesiredY: Double;
  ValueText: string; ValueBounds, TileBounds, InnerBounds: TRect;
  TileWidth, TileHeight, LabelLineHeight, ValueTop, ValueLineHeight, DeltaWidth: Double;
  CardColor, CardBorder, HeatColor: TThemeColor;
  function Bounds(const Left, Top, Right, Bottom: Double): TRect;
  begin Result := Rect(Round(Left), Round(Top), Round(Max(Left, Right)), Round(Max(Top, Bottom))) end;
  procedure Add;
  begin
    if Count = Capacity then begin Capacity := Max(32, Capacity * 2); SetLength(Items, Capacity) end;
    Items[Count] := A; Inc(Count);
  end;
  procedure NewPrimitive(const Kind: TNimbusChartPrimitiveKind; const Color: TThemeColor);
  begin
    A := Default(TNimbusChartPrimitive); A.Kind := Kind; A.Color := Color; A.Hit := TNimbusChartHit.None; A.Width := 1;
    if not C.Enabled then A.Color := NimbusBlendColor(A.Color, Back, 160);
  end;
  procedure Text(const Content: string; const B: TRect; const Color: TThemeColor; const RightAlign, CenterAlign: Boolean);
  begin
    if (Content = '') or B.IsEmpty then Exit;
    NewPrimitive(ncpText, Color); A.Text := Content; A.Bounds := B;
    A.TextFlags := [ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix];
    if RightAlign then Include(A.TextFlags, ntfRight);
    if CenterAlign then Include(A.TextFlags, ntfCenter); Add;
  end;
  function MeasureWidth(const Content: string; const MaximumWidth: Integer): Integer;
  var Canvas: INimbusRenderCanvas; Bitmap: TBitmap;
  begin
    Canvas := C.MeasureCanvas;
    if Canvas <> nil then Exit(Canvas.MeasureText(Content, C.Font, MaximumWidth, [ntfSingleLine, ntfNoPrefix]).cx);
    Bitmap := TBitmap.Create;
    try
      Bitmap.PixelFormat := pf32bit; Bitmap.SetSize(1, 1); Canvas := TNimbusRenderCanvas.Create; Canvas.BeginRender(Bitmap.Canvas);
      try Result := Canvas.MeasureText(Content, C.Font, MaximumWidth, [ntfSingleLine, ntfNoPrefix]).cx
      finally Canvas.EndRender end;
    finally Canvas := nil; Bitmap.Free end;
  end;
  procedure FittedText(const Content: string; const B: TRect; const Color: TThemeColor; const RightAlign, CenterAlign: Boolean; const MinimumPoints, ReducePoints: Double);
  var Previous: Integer;
  begin
    Previous := Count; Text(Content, B, Color, RightAlign, CenterAlign);
    if Count = Previous then Exit;
    Items[Count - 1].UseFont := True; Items[Count - 1].FontStyle := C.Font.Style;
    Items[Count - 1].FontHeight := -Max(Round(MinimumPoints * C.PPI / 72), Abs(C.Font.Height) - Round(ReducePoints * C.PPI / 72));
    Items[Count - 1].UseClip := True; Items[Count - 1].ClipBounds := B;
  end;
  procedure EllipseOutline(const X, Y, Radius: Double; const Color: TThemeColor; const Width: Single);
  begin NewPrimitive(ncpOutlineEllipse, Color); A.Bounds := Bounds(X - Radius, Y - Radius, X + Radius, Y + Radius); A.Width := Width; Add end;
  procedure Box(const B: TRect; const Color: TThemeColor; const Radius: Single; const Interactive: Boolean = False);
  begin
    if B.IsEmpty then Exit;
    NewPrimitive(ncpRect, Color); A.Bounds := B; A.UseCornerRadius := True; A.CornerRadius := Radius;
    if Interactive then A.Hit := CurrentHit; Add;
  end;
  procedure Dot(const X, Y, Radius: Double; const Color: TThemeColor);
  begin NewPrimitive(ncpEllipse, Color); A.Bounds := Bounds(X - Radius, Y - Radius, X + Radius, Y + Radius); A.Hit := CurrentHit; Add end;
  procedure Line(const X0, Y0, X1, Y1: Double; const Color: TThemeColor; const Width: Single = 1);
  begin NewPrimitive(ncpLine, Color); A.Points := [TPointF.Create(X0, Y0), TPointF.Create(X1, Y1)]; A.Width := Width; Add end;
  procedure HitRow(const B: TRect);
  begin NewPrimitive(ncpHitBounds, 0); A.Bounds := B; A.Hit := CurrentHit; Add end;
  procedure FitPortfolio;
  var Iteration, PointIndex, AngleIndex: Integer; LayerRadius, Angle, AngleSweep, PX, PY, Left, Top, Right, Bottom, Margin, Factor: Double;
  begin
    for Iteration := 0 to 7 do
    begin
      Stroke := Max(12 * DPI, Radius * 0.18); RadiusStep := Max(6 * DPI, Stroke * 0.58);
      Left := MaxDouble; Top := MaxDouble; Right := -MaxDouble; Bottom := -MaxDouble;
      for PointIndex := 0 to PointCount - 1 do
      begin
        LayerRadius := Radius - PointIndex * RadiusStep; if LayerRadius <= Stroke * 0.65 then Break;
        AngleSweep := 47.5 + 90 * EnsureRange(Points[PointIndex].Point.YValue / Maximum, 0.0, 1.0);
        for AngleIndex := 0 to Ceil(AngleSweep) do
        begin
          Angle := DegToRad(204 + Min(AngleIndex, AngleSweep)); PX := Cos(Angle) * LayerRadius; PY := Sin(Angle) * LayerRadius;
          Left := Min(Left, PX); Right := Max(Right, PX); Top := Min(Top, PY); Bottom := Max(Bottom, PY);
        end;
      end;
      if Left = MaxDouble then begin CenterX := R.Left + W / 2; CenterY := R.Top + H / 2; Exit end;
      Margin := Stroke / 2 + 3 * DPI; Left := Left - Margin; Right := Right + Margin; Top := Top - Margin; Bottom := Bottom + Margin;
      Factor := Min(1.0, Min(W / Max(1.0, Right - Left), H / Max(1.0, Bottom - Top)));
      CenterX := R.Left + 2 * DPI + (W - (Right - Left)) / 2 - Left;
      CenterY := R.Top + 2 * DPI + (H - (Bottom - Top)) / 2 - Top;
      if (Factor >= 0.999) or (Radius <= Stroke * 0.65) then Exit;
      if Iteration < 7 then Radius := Radius * Max(0.0, Factor * 0.995);
    end;
  end;
  function WaterfallY(const Value: Double): Double;
  begin Result := BarBottom - (Value - Minimum) / Span * (BarBottom - BarTop) end;
  function Number(const Value: Double): string;
  begin
    if Abs(Value) >= 1000 then Result := FormatFloat('0.#', Value / 1000) + 'k' else Result := FormatFloat('0', Value);
  end;
  function SignedNumber(const Value: Double): string;
  begin
    if Value > 0 then Result := '+' + Number(Value) else if Value < 0 then Result := '-' + Number(Abs(Value)) else Result := '0';
  end;
  function Target(const Point: TNimbusChartPoint): Double;
  begin Result := 0; if SparklineFinite(Point.XValue) and (Point.XValue > 0) then Result := Point.XValue end;
  function ResolvePointColor(const SeriesIndex, ColorIndex: Integer; const Point: TNimbusChartPoint): TThemeColor;
  const Colors: array[0..7] of Cardinal = ($FF007ACC, $FF50B469, $FFEBAB41, $FFD9617E, $FF9768C6, $FF3AB9BC, $FFC79352, $FF6480C0);
  var Series: TNimbusChartSeries; ThemeColor: TThemeColor; Custom: Boolean;
  begin
    if ColorIndex mod 8 = 0 then Result := ChartAccentColor(C) else Result := Colors[ColorIndex mod 8];
    if C.ChartPalette <> nil then Result := ColorToThemeColor(C.ChartPalette.GetSeriesColor(ColorIndex));
    Series := M.Series[SeriesIndex]; ThemeColor := Result; Custom := Series.Color <> clNone;
    if Custom then Result := ColorToThemeColor(Series.Color);
    if (Point <> nil) and (Point.Color <> clNone) then begin Result := ColorToThemeColor(Point.Color); Custom := True end;
    if Custom and (C.ColorInfluence > 0) then Result := NimbusBlendColor(Result, ThemeColor, Round(EnsureRange(C.ColorInfluence, 0, 100) * 255 / 100));
  end;
  function PointColor(const Index: Integer): TThemeColor;
  begin Result := ResolvePointColor(Points[Index].SeriesIndex, Index, Points[Index].Point) end;
  function StackRowTotal(const Row: Integer): Double;
  var Index: Integer; Series: TNimbusChartSeries; Point: TNimbusChartPoint;
  begin
    Result := 0;
    for Index := 0 to M.Series.Count - 1 do
    begin
      Series := M.Series[Index]; if not Series.Visible or (Row >= Series.Points.Count) then Continue;
      Point := Series.Points[Row]; if Point.Visible and SparklineFinite(Point.YValue) and (Point.YValue > 0) then Result := Result + Point.YValue;
    end;
  end;
  function StackRowLabel(const Row: Integer): string;
  var Index: Integer; Series: TNimbusChartSeries;
  begin
    for Index := 0 to M.Series.Count - 1 do
    begin
      Series := M.Series[Index];
      if (Row < Series.Points.Count) and (Series.Points[Row].&Label <> '') then Exit(Series.Points[Row].&Label);
    end;
    Result := 'Item ' + IntToStr(Row + 1);
  end;
  procedure SelectRawPoint(const SeriesIndex, PointIndex, ColorIndex: Integer);
  var Header: string; Start, Finish: Double;
  begin
    S := M.Series[SeriesIndex]; P := S.Points[PointIndex];
    CurrentHit := TNimbusChartHit.None; CurrentHit.Area := nchaPoint;
    CurrentHit.SeriesIndex := SeriesIndex; CurrentHit.PointIndex := PointIndex;
    CurrentHit.XValue := P.XValue; CurrentHit.YValue := P.YValue;
    Header := P.&Label; if Header = '' then Header := 'Item'; if S.Name <> '' then Header := S.Name + sLineBreak + Header;
    if P.ToolTipText <> '' then CurrentHit.Text := P.ToolTipText
    else if M.ChartType = nctBusinessTimelineRange then
    begin
      Start := Min(P.XValue, P.YValue); Finish := Max(P.XValue, P.YValue);
      CurrentHit.Text := Header + sLineBreak + 'Start: ' + Number(Start) + sLineBreak + 'End: ' + Number(Finish) + sLineBreak + 'Range: ' + Number(Finish - Start);
    end
    else if M.ChartType in [nctBusinessBullet, nctBusinessLollipopBar] then CurrentHit.Text := Header + sLineBreak + 'Actual: ' + Number(P.YValue) + sLineBreak + 'Target: ' + Number(Target(P)) + sLineBreak + 'Delta: ' + SignedNumber(P.YValue - Target(P))
    else if M.ChartType = nctBusinessKpiTiles then CurrentHit.Text := Header + sLineBreak + 'Value: ' + Number(P.YValue) + sLineBreak + 'Change: ' + SignedNumber(P.XValue)
    else if M.ChartType in [nctBusinessWaterfall, nctBusinessModernWaterfall] then CurrentHit.Text := Header + sLineBreak + 'Change: ' + SignedNumber(P.YValue)
    else if M.ChartType = nctBusinessDivergingBar then CurrentHit.Text := Header + sLineBreak + 'Value: ' + SignedNumber(P.YValue)
    else if M.ChartType = nctBusinessCalendarHeatmap then CurrentHit.Text := Header + sLineBreak + 'Activity: ' + Number(P.YValue)
    else if M.ChartType in [nctBusinessFunnel, nctBusinessRadialGoal, nctBusinessPortfolioArc, nctBusinessPareto, nctBusinessStackedHorizontalBar] then
    begin
      Ratio := 0; if Total > 0 then Ratio := P.YValue / Total * 100;
      CurrentHit.Text := Header + sLineBreak + 'Value: ' + Number(P.YValue) + sLineBreak + 'Share: ' + FormatFloat('0.#', Ratio) + '%';
    end
    else CurrentHit.Text := Header + sLineBreak + 'Value: ' + Number(P.YValue);
    if M.ChartType in [nctBusinessFunnel, nctBusinessRadialGoal, nctBusinessPortfolioArc, nctBusinessStackedHorizontalBar] then CurrentHit.Area := nchaSegment;
    Active := CurrentHit.SameElement(C.Hovered) or CurrentHit.SameElement(C.Selected); Col := ResolvePointColor(SeriesIndex, ColorIndex, P);
  end;
  procedure SelectPoint(const Index: Integer);
  begin SelectRawPoint(Points[Index].SeriesIndex, Points[Index].PointIndex, Index) end;
  procedure FocusBox(const B: TRect; const Radius: Single);
  var Glow: TRect;
  begin
    Glow := B; Glow.Inflate(Max(1, Round(DPI * 2)), Max(1, Round(DPI * 2)));
    Box(Glow, NimbusColorWithAlpha(Col, 90), Radius + DPI * 2);
    Glow := B; Glow.Inflate(Max(1, Round(DPI)), Max(1, Round(DPI)));
    Box(Glow, NimbusBlendColor($FFFFFFFF, Col, 70), Radius + DPI);
  end;
begin
  Result := nil; M := C.Model; R := L.PlotArea;
  if (M = nil) or (C.Font = nil) or R.IsEmpty then Exit;
  DPI := Max(1, C.PPI) / 96; Back := ChartBackColor(C); Fore := ChartForeColor(C);
  Muted := NimbusBlendColor(Fore, Back, 145);
  if C.ChartPalette <> nil then
  begin
    Muted := ColorToThemeColor(C.ChartPalette.MutedForeColor);
    if C.ChartPalette.PlotBackColor <> clNone then Back := ColorToThemeColor(C.ChartPalette.PlotBackColor);
  end;
  Count := 0; Capacity := 0;
  Text(M.Title, L.TitleBounds, Fore, False, False); Text(M.Subtitle, L.SubtitleBounds, Muted, False, False);
  PointCount := 0;
  for I := 0 to M.Series.Count - 1 do
  begin
    S := M.Series[I]; if not S.Visible then Continue;
    for J := 0 to S.Points.Count - 1 do
    begin
      P := S.Points[J]; if not P.Visible or not SparklineFinite(P.YValue) then Continue;
      if (M.ChartType = nctBusinessTimelineRange) and not SparklineFinite(P.XValue) then Continue;
      if PointCount = Length(Points) then SetLength(Points, Max(32, Length(Points) * 2));
      Points[PointCount].SeriesIndex := I; Points[PointCount].PointIndex := J; Points[PointCount].Point := P; Inc(PointCount);
    end;
  end;
  if PointCount > 0 then
  begin
    Maximum := 1; for I := 0 to PointCount - 1 do Maximum := Max(Maximum, Points[I].Point.YValue);
    case M.ChartType of
      nctBusinessStackedHorizontalBar:
        begin
          Rows := 0; Total := 0;
          for I := 0 to M.Series.Count - 1 do if M.Series[I].Visible then Rows := Max(Rows, M.Series[I].Points.Count);
          for I := 0 to PointCount - 1 do Total := Total + Max(0.0, Points[I].Point.YValue);
          LegendHeight := 0; if M.Legend.Visible then LegendHeight := 24 * DPI;
          LabelWidth := Min(Max(116 * DPI, R.Width * 0.25), R.Width * 0.34); ValueWidth := Min(Max(54 * DPI, R.Width * 0.09), 78 * DPI);
          BarLeft := R.Left + LabelWidth; BarRight := Max(BarLeft, R.Right - ValueWidth - 10 * DPI);
          BarTop := R.Top; BarBottom := BarTop + Max(0.0, R.Height - LegendHeight); RowHeight := (BarBottom - BarTop) / Max(1, Rows);
          Maximum := 1; for I := 0 to Rows - 1 do Maximum := Max(Maximum, StackRowTotal(I));
          Track := NimbusBlendColor(Muted, Back, 209);
          for I := 0 to Rows - 1 do
          begin
            RowTop := BarTop + I * RowHeight; H := Max(10 * DPI, Min(18 * DPI, RowHeight * 0.45)); Y := RowTop + (RowHeight - H) / 2;
            Value := StackRowTotal(I); X := BarLeft;
            if Odd(I) then Box(Bounds(R.Left, RowTop + DPI, R.Right, RowTop + RowHeight - DPI), NimbusBlendColor(Muted, Back, 235), 6 * DPI);
            FittedText(StackRowLabel(I), Bounds(R.Left, RowTop, BarLeft - 8 * DPI, RowTop + RowHeight), Fore, True, False, 8.25, 0.25);
            Box(Bounds(BarLeft, Y, BarRight, Y + H), Track, H / 2);
            for J := 0 to M.Series.Count - 1 do
            begin
              S := M.Series[J]; if not S.Visible or (I >= S.Points.Count) then Continue;
              P := S.Points[I]; if not P.Visible or not SparklineFinite(P.YValue) then Continue;
              W := (BarRight - BarLeft) * Max(0.0, P.YValue) / Maximum;
              if W > 0.5 then
              begin
                SelectRawPoint(J, I, J); BarBounds := Bounds(X, Y, X + W, Y + H);
                if Active then FocusBox(BarBounds, H * 0.45); Empty := Col; if Active then Empty := NimbusBlendColor($FFFFFFFF, Col, 31);
                Box(BarBounds, Empty, H * 0.45, True);
                if W > 34 * DPI then FittedText(FormatFloat('0', P.YValue), BarBounds, $FFFFFFFF, False, True, 8, 0.5);
                BarBounds.Inflate(Max(2, Round(2 * DPI)), Max(3, Round(3 * DPI))); HitRow(BarBounds);
              end;
              X := X + W;
            end;
            FittedText(FormatFloat('0', Value), Bounds(BarRight + 7 * DPI, RowTop, R.Right, RowTop + RowHeight), Muted, False, False, 8, 0.5);
          end;
          if LegendHeight > 0 then
          begin
            X := BarLeft;
            for I := 0 to M.Series.Count - 1 do
            begin
              S := M.Series[I]; if not S.Visible then Continue; CenterText := S.Name; if CenterText = '' then CenterText := 'Series ' + IntToStr(I + 1);
              ItemWidth := Min(150 * DPI, MeasureWidth(CenterText, Round(160 * DPI)) + 20 * DPI); if X + ItemWidth > BarRight then Break;
              Col := ResolvePointColor(I, I, nil); Y := BarBottom + (LegendHeight - 7 * DPI) / 2;
              Box(Bounds(X, Y, X + 7 * DPI, Y + 7 * DPI), Col, 3 * DPI);
              FittedText(CenterText, Bounds(X + 12 * DPI, BarBottom, X + ItemWidth, BarBottom + LegendHeight), Muted, False, False, 8, 0.5);
              X := X + ItemWidth + 8 * DPI;
            end;
          end;
        end;
      nctBusinessPareto:
        begin
          LabelWidth := Min(Max(132 * DPI, R.Width * 0.24), R.Width * 0.34);
          PercentWidth := Min(Max(52 * DPI, R.Width * 0.08), 76 * DPI); TopAxis := 24 * DPI; Footer := 18 * DPI;
          BarLeft := R.Left + LabelWidth; BarRight := Max(BarLeft, R.Right - PercentWidth - 14 * DPI);
          BarTop := R.Top + TopAxis; BarBottom := BarTop + Max(0.0, R.Height - TopAxis - Footer);
          VisibleCount := Min(PointCount, Max(1, Floor((BarBottom - BarTop) / Max(22 * DPI, 20.0))));
          Maximum := 1; Span := 1; Total := 0; Value := 0;
          for I := 0 to PointCount - 1 do
          begin
            Total := Total + Max(0.0, Points[I].Point.YValue);
            if I < VisibleCount then begin Maximum := Max(Maximum, Points[I].Point.YValue); Value := Value + Max(0.0, Points[I].Point.YValue) end;
          end;
          Span := Max(1.0, Value); RowHeight := (BarBottom - BarTop) / VisibleCount;
          Track := NimbusBlendColor(Muted, Back, 209); AxisColor := $FFFFB346;
          if C.ChartPalette <> nil then AxisColor := ColorToThemeColor(C.ChartPalette.WarningColor);
          SetLength(Polygon, VisibleCount);
          for I := 0 to 4 do
          begin
            X := BarLeft + (BarRight - BarLeft) * I / 4;
            Line(X, BarTop - 4 * DPI, X, BarBottom, NimbusBlendColor(Muted, Back, 199), Max(1.0, DPI));
            FittedText(Number(Maximum * I / 4), Bounds(X - 22 * DPI, R.Top, X + 22 * DPI, BarTop - 2 * DPI), Muted, False, True, 7.6, 0.9);
          end;
          Running := 0;
          for I := 0 to VisibleCount - 1 do
          begin
            SelectPoint(I); Value := Max(0.0, P.YValue); Running := Running + Value; RowTop := BarTop + I * RowHeight;
            H := Max(8 * DPI, Min(16 * DPI, RowHeight * 0.44)); Y := RowTop + (RowHeight - H) / 2;
            W := Max(2 * DPI, (BarRight - BarLeft) * Value / Maximum); X := BarLeft + (BarRight - BarLeft) * Min(1.0, Running / Span);
            Polygon[I] := TPointF.Create(X, RowTop + RowHeight / 2);
            if Odd(I) then Box(Bounds(R.Left, RowTop + DPI, R.Right, RowTop + RowHeight - DPI), NimbusBlendColor(Muted, Back, 237), 6 * DPI);
            FittedText(P.&Label, Bounds(R.Left, RowTop, BarLeft - 8 * DPI, RowTop + RowHeight), Fore, True, False, 7.8, 0.7);
            Box(Bounds(BarLeft, Y, BarRight, Y + H), Track, H / 2); BarBounds := Bounds(BarLeft, Y, BarLeft + W, Y + H);
            if Active then FocusBox(BarBounds, H / 2); Empty := Col; if Active then Empty := NimbusBlendColor($FFFFFFFF, Col, 26); Box(BarBounds, Empty, H / 2);
            if W > 38 * DPI then FittedText(Number(Value), BarBounds, $FFFFFFFF, False, True, 7.6, 0.9)
            else FittedText(Number(Value), Bounds(BarLeft + W + 4 * DPI, RowTop, BarLeft + W + 46 * DPI, RowTop + RowHeight), Fore, False, False, 7.6, 0.9);
            FittedText(FormatFloat('0', Running / Span * 100) + '%', Bounds(BarRight + 6 * DPI, RowTop, BarRight + 6 * DPI + PercentWidth, RowTop + RowHeight), AxisColor, False, False, 7.6, 0.9);
            HitRow(Bounds(R.Left, RowTop, R.Right, RowTop + RowHeight));
          end;
          if VisibleCount > 1 then begin NewPrimitive(ncpLine, AxisColor); A.Points := Polygon; A.Width := Max(2 * DPI, 2.0); Add end;
          for I := 0 to VisibleCount - 1 do
          begin
            SelectPoint(I); X := Polygon[I].X; Y := Polygon[I].Y; Dot(X, Y, 3.5 * DPI, AxisColor);
            if Active then EllipseOutline(X, Y, 6.5 * DPI, NimbusColorWithAlpha(AxisColor, 130), Max(4 * DPI, 3.0));
            EllipseOutline(X, Y, 3.5 * DPI, Back, Max(1.0, DPI));
          end;
        end;
      nctBusinessKpiTiles:
        begin
          Columns := 2; if R.Width > 760 * DPI then Columns := 4 else if R.Width > 560 * DPI then Columns := 3;
          Rows := Max(1, (PointCount + Columns - 1) div Columns); Gap := Max(12 * DPI, 10.0);
          TileWidth := (R.Width - Gap * (Columns - 1)) / Columns; TileHeight := (R.Height - Gap * (Rows - 1)) / Rows;
          if (TileHeight < 58 * DPI) and (Columns > 1) and (R.Width > 520 * DPI) then
          begin
            Dec(Columns); Rows := Max(1, (PointCount + Columns - 1) div Columns);
            TileWidth := (R.Width - Gap * (Columns - 1)) / Columns; TileHeight := (R.Height - Gap * (Rows - 1)) / Rows;
          end;
          CardColor := NimbusBlendColor(Back, Fore, 11); CardBorder := NimbusBlendColor(Muted, Back, 128); Track := NimbusBlendColor(Muted, Back, 209);
          if (TileWidth > 0) and (TileHeight > 0) then
            for I := 0 to PointCount - 1 do
            begin
              SelectPoint(I); X := R.Left + (I mod Columns) * (TileWidth + Gap); Y := R.Top + (I div Columns) * (TileHeight + Gap);
              TileBounds := Bounds(X, Y, X + TileWidth, Y + TileHeight); InnerBounds := TileBounds;
              InnerBounds.Inflate(-Round(12 * DPI), -Round(9 * DPI)); H := Max(5 * DPI, Min(7 * DPI, TileHeight * 0.095));
              BarTop := InnerBounds.Bottom - H;
              Positive := $FF55DC8F; Negative := $FFFF5C70;
              if C.ChartPalette <> nil then begin Positive := ColorToThemeColor(C.ChartPalette.SuccessColor); Negative := ColorToThemeColor(C.ChartPalette.ErrorColor) end;
              AxisColor := Positive; if P.XValue < 0 then AxisColor := Negative;
              if SparklineFinite(P.XValue) then ValueText := FormatFloat('+0.#;-0.#;0', P.XValue) + '%' else ValueText := 'N/A';
              LabelLineHeight := Max(13 * DPI, 12.0); ValueTop := InnerBounds.Top + LabelLineHeight + 3 * DPI;
              ValueLineHeight := Max(17 * DPI, 16.0); ValueWidth := Max(0.0, InnerBounds.Width * 0.58); DeltaWidth := Max(0.0, InnerBounds.Width - ValueWidth - 5 * DPI);
              Empty := CardColor; if Active then Empty := NimbusBlendColor(CardColor, Col, 26); Box(TileBounds, Empty, 10 * DPI);
              Empty := CardBorder; W := Max(1.0, DPI); if Active then begin Empty := NimbusBlendColor($FFFFFFFF, Col, 46); W := Max(1.6 * DPI, 1.5) end;
              NewPrimitive(ncpOutlineRect, Empty); A.Bounds := TileBounds; A.UseCornerRadius := True; A.CornerRadius := 10 * DPI; A.Width := W; Add;
              FittedText(P.&Label, Bounds(InnerBounds.Left, InnerBounds.Top, InnerBounds.Right, InnerBounds.Top + LabelLineHeight), Muted, False, False, 7.5, 1);
              FittedText(Number(P.YValue), Bounds(InnerBounds.Left, ValueTop, InnerBounds.Left + ValueWidth, ValueTop + ValueLineHeight), Fore, False, False, 10.5, -2.2);
              FittedText(ValueText, Bounds(InnerBounds.Right - DeltaWidth, ValueTop + 2 * DPI, InnerBounds.Right, ValueTop + 2 * DPI + ValueLineHeight), AxisColor, True, False, 7.5, 1.2);
              Box(Bounds(InnerBounds.Left, BarTop, InnerBounds.Right, BarTop + H), Track, H / 2);
              BarBounds := Bounds(InnerBounds.Left, BarTop, InnerBounds.Left + Max(2 * DPI, InnerBounds.Width * P.YValue / Maximum), BarTop + H);
              if Active then FocusBox(BarBounds, H / 2); Box(BarBounds, Col, H / 2);
              HitRow(TileBounds);
            end;
        end;
      nctBusinessWaterfall, nctBusinessModernWaterfall:
        begin
          Modern := M.ChartType = nctBusinessModernWaterfall; LabelHeight := 22 * DPI; ValueHeight := 18 * DPI; TopAxis := 4 * DPI;
          if Modern then begin ValueHeight := 22 * DPI; TopAxis := 24 * DPI end;
          BarLeft := R.Left + 4 * DPI; BarRight := Max(BarLeft, R.Right - 4 * DPI); BarTop := R.Top + TopAxis;
          BarBottom := BarTop + Max(0.0, R.Height - LabelHeight - ValueHeight - TopAxis - 8 * DPI);
          Running := 0; Minimum := 0; Maximum := 0;
          for I := 0 to PointCount - 1 do
          begin
            Value := Points[I].Point.YValue; TotalPoint := (I = PointCount - 1) and (Abs(Value) < 0.0001);
            X0 := Running; X1 := Running + Value; if TotalPoint then begin X0 := 0; X1 := Running end else Running := X1;
            Minimum := Min(Minimum, Min(X0, X1)); Maximum := Max(Maximum, Max(X0, X1));
          end;
          if Maximum <= Minimum then Maximum := Minimum + 1; Span := Maximum - Minimum;
          Slot := (BarRight - BarLeft) / PointCount; BarWidth := Max(12 * DPI, Min(42 * DPI, Slot * 0.58));
          Positive := $FF55DC8F; if Modern then Positive := $FF4DD0E1; Negative := $FFFF5C70; MarkerColor := $FF9276FF;
          if C.ChartPalette <> nil then
          begin
            Positive := ColorToThemeColor(C.ChartPalette.SuccessColor); if Modern then Positive := ColorToThemeColor(C.ChartPalette.InfoColor);
            Negative := ColorToThemeColor(C.ChartPalette.ErrorColor); MarkerColor := ColorToThemeColor(C.ChartPalette.AccentColor);
          end;
          AxisColor := NimbusBlendColor(Muted, Back, 107); Line(BarLeft, WaterfallY(0), BarRight, WaterfallY(0), NimbusBlendColor(Muted, Back, 140), Max(1.0, DPI));
          Running := 0; PreviousX := 0; PreviousY := WaterfallY(0);
          for I := 0 to PointCount - 1 do
          begin
            SelectPoint(I); TotalPoint := (I = PointCount - 1) and (Abs(P.YValue) < 0.0001);
            Value := Running; Finish := Running + P.YValue; if TotalPoint then begin Value := 0; Finish := Running end else Running := Finish;
            X := BarLeft + I * Slot + (Slot - BarWidth) / 2; X0 := WaterfallY(Value); X1 := WaterfallY(Finish);
            Y := Min(X0, X1); H := Max(2 * DPI, Abs(X1 - X0));
            Col := Positive; if P.YValue < 0 then Col := Negative; if I = PointCount - 1 then Col := MarkerColor;
            if (S.Color <> clNone) or (P.Color <> clNone) then Col := PointColor(I);
            if I > 0 then Line(PreviousX, PreviousY, X, PreviousY, AxisColor, Max(1.0, DPI));
            BarBounds := Bounds(X, Y, X + BarWidth, Y + H);
            if Modern then
            begin
              Box(Bounds(X + 1.5 * DPI, Y + 2 * DPI, X + BarWidth + 1.5 * DPI, Y + H + 2 * DPI), $26000000, 5 * DPI);
              Box(BarBounds, Col, 6 * DPI, True);
              Box(Bounds(X, Y, X + BarWidth, Y + Max(2 * DPI, H * 0.35)), NimbusBlendColor($FFFFFFFF, Col, 158), 6 * DPI);
            end else Box(BarBounds, Col, 4 * DPI, True);
            if Active then
            begin
              W := 4 * DPI; if Modern then W := 6 * DPI; FocusBox(BarBounds, W);
              Box(BarBounds, Col, W);
              Line(X + BarWidth / 2, BarTop, X + BarWidth / 2, BarBottom, NimbusColorWithAlpha(Col, 58), Max(1.0, DPI));
            end;
            Track := Muted; if Active then Track := Col;
            FittedText(P.&Label, Bounds(BarLeft + I * Slot, BarBottom + 2 * DPI, BarLeft + (I + 1) * Slot, BarBottom + 2 * DPI + LabelHeight), Track, False, True, 7.5, 1);
            Value := P.YValue; if TotalPoint then Value := Finish; ValueText := FormatFloat('+0;-0;0', Value);
            DesiredY := Max(R.Top, Y - ValueHeight - 2 * DPI);
            if Modern then
            begin
              DesiredY := Y - ValueHeight - 3 * DPI; if (P.YValue < 0) and not TotalPoint then DesiredY := Y + H + 3 * DPI;
              DesiredY := Max(R.Top, Min(BarBottom - ValueHeight, DesiredY));
            end;
            ValueBounds := Bounds(BarLeft + I * Slot, DesiredY, BarLeft + (I + 1) * Slot, DesiredY + ValueHeight);
            if Modern then
            begin
              BarBounds := ValueBounds; BarBounds.Inflate(-Max(2, Round(2 * DPI)), -Max(2, Round(2 * DPI)));
              Box(BarBounds, NimbusBlendColor(Back, Col, 36), 6 * DPI);
            end;
            FittedText(ValueText, ValueBounds, Col, False, True, 8, 0.5);
            BarBounds := Bounds(X, Y, X + BarWidth, Y + H); BarBounds.Inflate(Max(4, Round(4 * DPI)), Max(4, Round(4 * DPI))); HitRow(BarBounds);
            PreviousX := X + BarWidth; PreviousY := X1;
          end;
        end;
      nctBusinessPortfolioArc:
        begin
          LegendHeight := 0; if M.Legend.Visible then LegendHeight := 34 * DPI;
          ValueWidth := Min(128 * DPI, R.Width * 0.34); W := Max(0.0, R.Width - ValueWidth - 8 * DPI);
          H := Max(0.0, R.Height - LegendHeight - 4 * DPI); CenterX := R.Left + 2 * DPI + W * 0.52;
          CenterY := R.Top + 2 * DPI + H * 1.26; Radius := Min(W * 0.50, H * 1.02);
          FitPortfolio;
          Total := 0; for I := 0 to PointCount - 1 do Total := Total + Max(0.0, Points[I].Point.YValue);
          for I := 0 to PointCount - 1 do
          begin
            RingRadius := Radius - I * RadiusStep; if RingRadius <= Stroke * 0.65 then Break;
            SelectPoint(I); Sweep := 46 + 90 * EnsureRange(P.YValue / Maximum, 0.0, 1.0);
            BarBounds := Bounds(CenterX - RingRadius, CenterY - RingRadius, CenterX + RingRadius, CenterY + RingRadius);
            NewPrimitive(ncpArc, $2E000000); A.Bounds := BarBounds; A.StartAngle := 205.5; A.SweepAngle := Sweep; A.Width := Stroke + 2 * DPI; Add;
            NewPrimitive(ncpArc, Col); A.Bounds := BarBounds; A.StartAngle := 204; A.SweepAngle := Sweep; A.Width := Stroke; Add;
            NewPrimitive(ncpArc, NimbusColorWithAlpha(NimbusBlendColor($FFFFFFFF, Col, 87), 92));
            A.Bounds := BarBounds; A.StartAngle := 205.8; A.SweepAngle := Max(8.0, Sweep - 4); A.Width := Max(1.4 * DPI, Stroke * 0.18); Add;
            if Active then
            begin
              K := 92; if ChartIsDark(C) then K := 118;
              NewPrimitive(ncpArc, NimbusColorWithAlpha(Col, K)); A.Bounds := BarBounds; A.StartAngle := 204; A.SweepAngle := Sweep; A.Width := Stroke + 4 * DPI; Add;
              K := 87; if ChartIsDark(C) then K := 46;
              NewPrimitive(ncpArc, NimbusBlendColor($FFFFFFFF, Col, K)); A.Bounds := BarBounds; A.StartAngle := 204.3; A.SweepAngle := Sweep; A.Width := Max(1.6 * DPI, Stroke * 0.16); Add;
            end;
          end;
          if M.KpiValueText <> '' then
          begin
            FittedText(M.KpiValueText, Bounds(R.Right - ValueWidth, R.Top, R.Right, R.Top + 28 * DPI), Fore, True, False, 10, -3);
            if Count > 0 then Items[Count - 1].FontStyle := [];
          end;
          if M.Legend.Visible then
          begin
            X := R.Left; RowHeight := Max(16 * DPI, Abs(C.Font.Height) + 4 * DPI); Y := R.Bottom - LegendHeight;
            for I := 0 to PointCount - 1 do
            begin
              ItemWidth := Min(R.Width, MeasureWidth(Points[I].Point.&Label, Round(220 * DPI)) + 20 * DPI);
              if X + ItemWidth > R.Right then Break;
              Col := PointColor(I); RowTop := Y + (LegendHeight - 7 * DPI) / 2;
              Box(Bounds(X, RowTop, X + 7 * DPI, RowTop + 7 * DPI), Col, 3 * DPI);
              Text(Points[I].Point.&Label, Bounds(X + 12 * DPI, Y + (LegendHeight - RowHeight) / 2,
                X + ItemWidth, Y + (LegendHeight + RowHeight) / 2), Muted, False, False);
              X := X + ItemWidth + 6 * DPI;
            end;
          end;
          for I := PointCount - 1 downto 0 do
          begin
            RingRadius := Radius - I * RadiusStep; if RingRadius <= Stroke * 0.65 then Continue;
            SelectPoint(I); Sweep := 46 + 90 * EnsureRange(P.YValue / Maximum, 0.0, 1.0);
            NewPrimitive(ncpHitArc, 0); A.Bounds := Bounds(CenterX - RingRadius, CenterY - RingRadius, CenterX + RingRadius, CenterY + RingRadius);
            A.StartAngle := 204; A.SweepAngle := Sweep; A.Width := Stroke + 8 * DPI; A.Hit := CurrentHit; Add;
          end;
        end;
      nctBusinessRadialGoal:
        begin
          LabelWidth := Min(R.Width * 0.34, 116 * DPI); W := Max(0.0, R.Width - LabelWidth);
          Side := Min(W, R.Height) * 0.92; CenterX := R.Left + W / 2; CenterY := R.Top + R.Height / 2;
          Stroke := Max(6 * DPI, Side * 0.055); Gap := Max(5 * DPI, Stroke * 0.45); Radius := Side / 2 - Stroke;
          Track := NimbusBlendColor(Muted, Back, 194); Total := 0;
          for I := 0 to PointCount - 1 do Total := Total + Max(0.0, Points[I].Point.YValue);
          for I := PointCount - 1 downto 0 do
          begin
            RingRadius := Radius - I * (Stroke + Gap); if RingRadius <= Stroke then Continue;
            SelectPoint(I); Sweep := Max(0.8, 300 * EnsureRange(P.YValue / 100, 0.0, 1.0));
            BarBounds := Bounds(CenterX - RingRadius, CenterY - RingRadius, CenterX + RingRadius, CenterY + RingRadius);
            NewPrimitive(ncpArc, Track); A.Bounds := BarBounds; A.StartAngle := 120; A.SweepAngle := 300; A.Width := Stroke; Add;
            NewPrimitive(ncpArc, Col); A.Bounds := BarBounds; A.StartAngle := 120; A.SweepAngle := Sweep; A.Width := Stroke; Add;
            if Active then
            begin
              K := 92; if ChartIsDark(C) then K := 118;
              NewPrimitive(ncpArc, NimbusColorWithAlpha(Col, K)); A.Bounds := BarBounds; A.StartAngle := 120; A.SweepAngle := Sweep; A.Width := Stroke + 3.5 * DPI; Add;
              K := 87; if ChartIsDark(C) then K := 46;
              NewPrimitive(ncpArc, NimbusBlendColor($FFFFFFFF, Col, K)); A.Bounds := BarBounds; A.StartAngle := 120; A.SweepAngle := Sweep; A.Width := Max(1.4 * DPI, Stroke * 0.18); Add;
            end;
            NewPrimitive(ncpHitArc, 0); A.Bounds := BarBounds; A.StartAngle := 120; A.SweepAngle := Max(Sweep, 12.0); A.Width := Stroke + 8 * DPI; A.Hit := CurrentHit; Add;
          end;
          H := Max(34 * DPI, Radius * 0.68); if Radius > Stroke then
          begin
            NewPrimitive(ncpEllipse, NimbusBlendColor(Back, Fore, 15)); A.Bounds := Bounds(CenterX - H / 2, CenterY - H / 2, CenterX + H / 2, CenterY + H / 2); Add;
            EllipseOutline(CenterX, CenterY, H / 2, NimbusBlendColor(Muted, Back, 115), Max(1.0, DPI));
            CenterText := M.GaugeCenterLabel; if CenterText = '' then CenterText := M.KpiValueText;
            if CenterText = '' then
            begin
              Total := 0; for I := 0 to PointCount - 1 do Total := Total + Points[I].Point.YValue;
              CenterText := FormatFloat('0', Total / PointCount) + '%';
            end;
            FittedText(CenterText, Bounds(CenterX - H / 2, CenterY - H / 2, CenterX + H / 2, CenterY + H / 2), Fore, False, True, 10, -6);
            if Count > 0 then Items[Count - 1].FontStyle := [];
          end;
          if M.Legend.Visible then
          begin
            RowHeight := Max(16 * DPI, Abs(C.Font.Height) + 4 * DPI); X := R.Right - LabelWidth + 8 * DPI;
            for I := 0 to PointCount - 1 do
            begin
              RowTop := R.Top + 8 * DPI + I * RowHeight; if RowTop + RowHeight > R.Bottom - 8 * DPI then Break;
              Col := PointColor(I); Y := RowTop + (RowHeight - 8 * DPI) / 2;
              Box(Bounds(X, Y, X + 8 * DPI, Y + 8 * DPI), Col, 3 * DPI);
              Text(Points[I].Point.&Label, Bounds(X + 14 * DPI, RowTop, R.Right, RowTop + RowHeight), Muted, False, False);
            end;
          end;
        end;
      nctBusinessRankedBar:
        begin
          TopAxis := 0; if M.Options.ShowAxes then TopAxis := 20 * DPI;
          MinRowHeight := Max(14 * DPI, Abs(C.Font.Height) + 3 * DPI);
          VisibleCount := Min(PointCount, Max(1, Floor(Max(1.0, R.Height - TopAxis) / MinRowHeight)));
          LabelWidth := Min(Max(112 * DPI, R.Width * 0.43), R.Width * 0.52);
          BarLeft := R.Left + LabelWidth; BarRight := Max(BarLeft, R.Right - 8 * DPI);
          BarTop := R.Top + TopAxis; RowHeight := Max(0.0, R.Bottom - BarTop) / VisibleCount;
          Track := NimbusBlendColor(Muted, Back, 214); AxisColor := NimbusBlendColor(Muted, Back, 140);
          if TopAxis > 0 then
            for I := 0 to 4 do
            begin
              X := BarLeft + (BarRight - BarLeft) * I / 4;
              Line(X, BarTop - 5 * DPI, X, BarTop, AxisColor, Max(1.0, DPI));
              Text(FormatFloat('0', Maximum * I / 4), Bounds(X - 28 * DPI, R.Top, X + 28 * DPI, BarTop), AxisColor, False, True);
            end;
          for I := 0 to VisibleCount - 1 do
          begin
            SelectPoint(I); RowTop := BarTop + I * RowHeight;
            H := Max(4 * DPI, Min(9 * DPI, RowHeight * 0.54)); Y := RowTop + (RowHeight - H) / 2;
            W := Max(2 * DPI, (BarRight - BarLeft) * P.YValue / Maximum);
            Box(Bounds(BarLeft, Y, BarRight, Y + H), Track, H / 2);
            if Active then FocusBox(Bounds(BarLeft, Y, BarLeft + W, Y + H), H / 2);
            Box(Bounds(BarLeft, Y, BarLeft + W, Y + H), Col, H / 2, True);
            Text(P.&Label, Bounds(R.Left, RowTop, BarLeft - 8 * DPI, RowTop + RowHeight), Fore, True, False);
            if Active and (P.&Label <> '') then Items[Count - 1].Color := Col;
            if P.ShowValue or M.Options.ShowValues then Text(FormatFloat('0.##', P.YValue), Bounds(BarLeft + W + 5 * DPI, RowTop, BarRight, RowTop + RowHeight), Muted, False, False);
            HitRow(Bounds(R.Left, RowTop, R.Right, RowTop + RowHeight));
          end;
          if PointCount > VisibleCount then Text('+' + IntToStr(PointCount - VisibleCount) + ' more', Bounds(R.Left, Max(R.Top, R.Bottom - MinRowHeight), BarLeft - 8 * DPI, R.Bottom), NimbusBlendColor(Muted, Back, 66), True, False);
        end;
      nctBusinessLollipopBar:
        begin
          TopAxis := 0; if M.Options.ShowAxes then TopAxis := 26 * DPI;
          MinRowHeight := Max(22 * DPI, Abs(C.Font.Height) + 9 * DPI);
          VisibleCount := Min(PointCount, Max(1, Floor(Max(1.0, R.Height - TopAxis) / MinRowHeight)));
          LabelWidth := Min(Max(116 * DPI, R.Width * 0.26), R.Width * 0.34);
          ValueWidth := Min(Max(62 * DPI, R.Width * 0.11), 96 * DPI);
          BarLeft := R.Left + LabelWidth; BarRight := Max(BarLeft, R.Right - ValueWidth - 10 * DPI);
          BarTop := R.Top + TopAxis; RowHeight := Max(0.0, R.Bottom - BarTop) / VisibleCount;
          Maximum := 0; for I := 0 to PointCount - 1 do Maximum := Max(Maximum, Max(Points[I].Point.YValue, Target(Points[I].Point)));
          if Maximum <= 0 then Maximum := 1 else Maximum := Max(Maximum * 1.08, Ceil(Maximum * 1.08 / 100) * 100);
          Track := NimbusBlendColor(Muted, Back, 235); AxisColor := NimbusBlendColor(Muted, Back, 107);
          MarkerColor := $FFFF5361; if C.ChartPalette <> nil then MarkerColor := ColorToThemeColor(C.ChartPalette.ErrorColor);
          Shadow := $24000000;
          if TopAxis > 0 then
          begin
            Line(BarLeft, BarTop - 4 * DPI, BarRight, BarTop - 4 * DPI, NimbusBlendColor(Muted, Back, 112), Max(1.0, DPI));
            for I := 0 to 5 do
            begin
              X := BarLeft + (BarRight - BarLeft) * I / 5;
              Line(X, BarTop - 8 * DPI, X, BarTop - DPI, AxisColor, Max(1.0, DPI));
              FittedText(Number(Maximum * I / 5), Bounds(X - 30 * DPI, R.Top, X + 30 * DPI, BarTop - 5 * DPI), AxisColor, False, True, 7.5, 1);
            end;
          end;
          for I := 0 to VisibleCount - 1 do
          begin
            SelectPoint(I); RowTop := BarTop + I * RowHeight; CenterY := RowTop + RowHeight / 2;
            H := Max(8 * DPI, Min(16 * DPI, RowHeight * 0.46)); Y := CenterY - H / 2;
            ActualX := BarLeft + (BarRight - BarLeft) * Max(0.0, P.YValue) / Maximum;
            TargetX := BarLeft + (BarRight - BarLeft) * Target(P) / Maximum; W := Max(2 * DPI, ActualX - BarLeft);
            if Odd(I) then Box(Bounds(R.Left, RowTop + DPI, R.Right, RowTop + RowHeight - DPI), Track, 5 * DPI);
            FittedText(P.&Label, Bounds(R.Left, RowTop, BarLeft - 9 * DPI, RowTop + RowHeight), Fore, True, False, 8.25, 0.25);
            Line(BarLeft, CenterY, BarRight, CenterY, AxisColor, Max(1.0, DPI));
            Box(Bounds(BarLeft, Y + 1.5 * DPI, BarLeft + W, Y + H + 1.5 * DPI), Shadow, H / 2);
            K := 122; if Active then K := 77;
            Box(Bounds(BarLeft, Y, BarLeft + W, Y + H), NimbusBlendColor(Col, Back, K), H / 2, True);
            Box(Bounds(BarLeft, Y, BarLeft + W, Y + Max(2 * DPI, H * 0.42)), NimbusBlendColor($FFFFFFFF, Col, 168), H / 2);
            DotRadius := Max(12 * DPI, H * 1.28) / 2;
            Dot(ActualX + 1.2 * DPI, CenterY + 1.2 * DPI, DotRadius, Shadow);
            Dot(ActualX, CenterY, DotRadius, Col);
            EllipseOutline(ActualX, CenterY, DotRadius, NimbusBlendColor($FFFFFFFF, Col, 71), Max(1.0, DPI));
            if Active then
            begin
              EllipseOutline(ActualX, CenterY, DotRadius + 3 * DPI, NimbusColorWithAlpha(Col, 120), Max(4 * DPI, 3.0));
              EllipseOutline(ActualX, CenterY, DotRadius + 1.5 * DPI, NimbusBlendColor($FFFFFFFF, Col, 38), Max(1.4 * DPI, 1.0));
              Line(TargetX, RowTop + 3 * DPI, TargetX, RowTop + RowHeight - 3 * DPI, NimbusColorWithAlpha(MarkerColor, 130), Max(4 * DPI, 3.0));
            end;
            Positive := MarkerColor; if Active then Positive := NimbusBlendColor($FFFFFFFF, MarkerColor, 51);
            HalfMarker := Max(9 * DPI, RowHeight * 0.28);
            Line(TargetX, CenterY - HalfMarker, TargetX, CenterY + HalfMarker, Positive, Max(2 * DPI, DPI * 1.5));
            Line(TargetX - 4 * DPI, CenterY - HalfMarker, TargetX + 4 * DPI, CenterY - HalfMarker, Positive, Max(2 * DPI, DPI * 1.5));
            Line(TargetX - 4 * DPI, CenterY + HalfMarker, TargetX + 4 * DPI, CenterY + HalfMarker, Positive, Max(2 * DPI, DPI * 1.5));
            if Abs(TargetX - ActualX) >= 14 * DPI then
            begin
              Positive := AxisColor; if TargetX >= ActualX then Positive := MarkerColor;
              X0 := Min(TargetX, ActualX) + 8 * DPI; X1 := Max(TargetX, ActualX) - 8 * DPI;
              Line(X0, CenterY, X1, CenterY, Positive, Max(1.0, DPI));
              if TargetX >= ActualX then
              begin Line(X1, CenterY, X1 - 4 * DPI, CenterY - 4 * DPI, Positive, Max(1.0, DPI)); Line(X1, CenterY, X1 - 4 * DPI, CenterY + 4 * DPI, Positive, Max(1.0, DPI)) end
              else begin Line(X0, CenterY, X0 + 4 * DPI, CenterY - 4 * DPI, Positive, Max(1.0, DPI)); Line(X0, CenterY, X0 + 4 * DPI, CenterY + 4 * DPI, Positive, Max(1.0, DPI)) end;
            end;
            Positive := Fore; if W > 46 * DPI then Positive := $FFFFFFFF;
            FittedText(FormatFloat('0', P.YValue), Bounds(BarLeft + 6 * DPI, RowTop, BarLeft + W - 6 * DPI, RowTop + RowHeight), Positive, False, W > 46 * DPI, 8, 0.5);
            FittedText(FormatFloat('0', Target(P)), Bounds(BarRight + 8 * DPI, RowTop, R.Right, RowTop + RowHeight), MarkerColor, False, False, 8, 0.5);
            HitRow(Bounds(R.Left, RowTop, R.Right, RowTop + RowHeight));
          end;
        end;
      nctBusinessBullet:
        begin
          LabelWidth := Min(Max(118 * DPI, R.Width * 0.24), R.Width * 0.34);
          ValueWidth := Min(Max(70 * DPI, R.Width * 0.12), 104 * DPI);
          BarLeft := R.Left + LabelWidth; BarRight := Max(BarLeft, R.Right - ValueWidth - 12 * DPI);
          MinRowHeight := Max(24 * DPI, Abs(C.Font.Height) + 12 * DPI);
          VisibleCount := Min(PointCount, Max(1, Floor(R.Height / MinRowHeight))); RowHeight := R.Height / VisibleCount;
          Maximum := 0;
          for I := 0 to PointCount - 1 do Maximum := Max(Maximum, Max(Points[I].Point.YValue, Target(Points[I].Point)));
          if Maximum <= 0 then Maximum := 1 else Maximum := Max(Maximum * 1.08, Ceil(Maximum * 1.08 / 100) * 100);
          Track := NimbusBlendColor(Muted, Back, 204); AxisColor := NimbusDangerColor;
          if C.ChartPalette <> nil then AxisColor := ColorToThemeColor(C.ChartPalette.ErrorColor);
          for I := 0 to VisibleCount - 1 do
          begin
            SelectPoint(I); RowTop := R.Top + I * RowHeight;
            H := Max(10 * DPI, Min(18 * DPI, RowHeight * 0.42)); Y := RowTop + (RowHeight - H) / 2;
            W := Max(2 * DPI, (BarRight - BarLeft) * Max(0.0, P.YValue) / Maximum);
            X := BarLeft + (BarRight - BarLeft) * Target(P) / Maximum;
            if Odd(I) then Box(Bounds(R.Left, RowTop + DPI, R.Right, RowTop + RowHeight - DPI), NimbusBlendColor(Muted, Back, 235), 6 * DPI);
            Box(Bounds(BarLeft, Y, BarRight, Y + H), Track, H / 2);
            if Active then FocusBox(Bounds(BarLeft, Y, BarLeft + W, Y + H), H / 2);
            K := 46; if Active then K := 10;
            Box(Bounds(BarLeft, Y, BarLeft + W, Y + H), NimbusBlendColor(Col, Back, K), H / 2, True);
            Box(Bounds(BarLeft, Y, BarLeft + W, Y + Max(2 * DPI, H * 0.38)), NimbusBlendColor($FFFFFFFF, Col, 148), H / 2);
            if Active then Line(X, Y - 8 * DPI, X, Y + H + 8 * DPI, NimbusColorWithAlpha(AxisColor, 130), Max(5 * DPI, 4.0));
            Line(X, Y - 5 * DPI, X, Y + H + 5 * DPI, AxisColor, Max(2 * DPI, 1.5 * DPI));
            Text(P.&Label, Bounds(R.Left, RowTop, BarLeft - 8 * DPI, RowTop + RowHeight), Fore, True, False);
            Text(FormatFloat('0', P.YValue), Bounds(BarRight + 9 * DPI, RowTop, R.Right, RowTop + RowHeight), Fore, False, False);
            Text(FormatFloat('0', Target(P)), Bounds(X - 32 * DPI, RowTop, X + 32 * DPI, RowTop + RowHeight), AxisColor, True, False);
            HitRow(Bounds(R.Left, RowTop, R.Right, RowTop + RowHeight));
          end;
        end;
      nctBusinessDivergingBar:
        begin
          TopAxis := 0; if M.Options.ShowAxes then TopAxis := 20 * DPI;
          MinRowHeight := Max(22 * DPI, Abs(C.Font.Height) + 8 * DPI);
          VisibleCount := Min(PointCount, Max(1, Floor(Max(1.0, R.Height - TopAxis) / MinRowHeight)));
          LabelWidth := Min(Max(112 * DPI, R.Width * 0.25), R.Width * 0.34);
          ValueWidth := Min(Max(58 * DPI, R.Width * 0.10), 86 * DPI);
          BarLeft := R.Left + LabelWidth; BarRight := Max(BarLeft, R.Right - ValueWidth - 10 * DPI);
          BarTop := R.Top + TopAxis; X := (BarLeft + BarRight) / 2;
          RowHeight := Max(0.0, R.Bottom - BarTop) / VisibleCount;
          Maximum := 1; for I := 0 to PointCount - 1 do Maximum := Max(Maximum, Abs(Points[I].Point.YValue));
          Positive := NimbusSuccessColor; Negative := NimbusDangerColor;
          if C.ChartPalette <> nil then
          begin Positive := ColorToThemeColor(C.ChartPalette.SuccessColor); Negative := ColorToThemeColor(C.ChartPalette.ErrorColor) end;
          AxisColor := NimbusBlendColor(Muted, Back, 102); Line(X, BarTop, X, R.Bottom, AxisColor, Max(1.0, DPI));
          if TopAxis > 0 then
          begin
            Text('Loss', Bounds(BarLeft, R.Top, X - 5 * DPI, BarTop), Negative, True, False);
            Text('Gain', Bounds(X + 5 * DPI, R.Top, BarRight, BarTop), Positive, False, False);
          end;
          for I := 0 to VisibleCount - 1 do
          begin
            SelectPoint(I); RowTop := BarTop + I * RowHeight;
            H := Max(9 * DPI, Min(17 * DPI, RowHeight * 0.48)); Y := RowTop + (RowHeight - H) / 2;
            W := Max(2 * DPI, Abs(P.YValue) / Maximum * (BarRight - BarLeft) / 2);
            Col := Positive; BarBounds := Bounds(X, Y, X + W, Y + H);
            if P.YValue < 0 then begin Col := Negative; BarBounds := Bounds(X - W, Y, X, Y + H) end;
            if Odd(I) then Box(Bounds(R.Left, RowTop + DPI, R.Right, RowTop + RowHeight - DPI), NimbusBlendColor(Muted, Back, 235), 6 * DPI);
            Text(P.&Label, Bounds(R.Left, RowTop, BarLeft - 8 * DPI, RowTop + RowHeight), Fore, True, False);
            if Active then FocusBox(BarBounds, H / 2);
            Box(BarBounds, Col, H / 2, True);
            Box(Bounds(BarBounds.Left, BarBounds.Top, BarBounds.Right, BarBounds.Top + Max(2 * DPI, H * 0.38)), NimbusBlendColor($FFFFFFFF, Col, 158), H / 2);
            if Active then Line(BarBounds.Right, RowTop + 3 * DPI, BarBounds.Right, RowTop + RowHeight - 3 * DPI, NimbusColorWithAlpha(Col, 105), Max(2 * DPI, 2.0));
            Text(FormatFloat('+0;-0;0', P.YValue), Bounds(BarRight + 7 * DPI, RowTop, R.Right, RowTop + RowHeight), Col, False, False);
            if BarBounds.Width > 34 * DPI then Text(FormatFloat('+0;-0;0', P.YValue), BarBounds, $FFFFFFFF, False, True);
            HitRow(Bounds(R.Left, RowTop, R.Right, RowTop + RowHeight));
          end;
        end;
      nctBusinessTimelineRange:
        begin
          LabelWidth := Min(Max(130 * DPI, R.Width * 0.23), R.Width * 0.34);
          ValueWidth := Min(Max(82 * DPI, R.Width * 0.11), 110 * DPI); TopAxis := 26 * DPI;
          BarLeft := R.Left + LabelWidth; BarRight := Max(BarLeft, R.Right - ValueWidth - 10 * DPI);
          BarTop := R.Top + TopAxis; BarBottom := Max(BarTop, R.Bottom - 4 * DPI);
          VisibleCount := Min(PointCount, Max(1, Floor((BarBottom - BarTop) / Max(24 * DPI, 21.0))));
          Minimum := Infinity; Maximum := -Infinity;
          for I := 0 to VisibleCount - 1 do
          begin
            P := Points[I].Point; Minimum := Min(Minimum, Min(P.XValue, P.YValue)); Maximum := Max(Maximum, Max(P.XValue, P.YValue));
          end;
          if Maximum <= Minimum then begin Minimum := 0; Maximum := 1 end;
          Span := Maximum - Minimum; RowHeight := (BarBottom - BarTop) / VisibleCount;
          Track := NimbusBlendColor(Muted, Back, 237); AxisColor := NimbusBlendColor(Muted, Back, 194);
          for I := 0 to 4 do
          begin
            X := BarLeft + (BarRight - BarLeft) * I / 4;
            Line(X, BarTop - 4 * DPI, X, BarBottom, AxisColor, Max(1.0, DPI));
            Text(FormatFloat('0', Minimum + Span * I / 4), Bounds(X - 24 * DPI, R.Top, X + 24 * DPI, BarTop - 2 * DPI), Muted, False, True);
          end;
          for I := 0 to VisibleCount - 1 do
          begin
            SelectPoint(I); RowTop := BarTop + I * RowHeight;
            Value := Min(P.XValue, P.YValue); X0 := BarLeft + (Value - Minimum) / Span * (BarRight - BarLeft);
            Value := Max(P.XValue, P.YValue); X1 := BarLeft + (Value - Minimum) / Span * (BarRight - BarLeft);
            H := Max(9 * DPI, Min(17 * DPI, RowHeight * 0.46)); Y := RowTop + (RowHeight - H) / 2;
            if Odd(I) then Box(Bounds(R.Left, RowTop + DPI, R.Right, RowTop + RowHeight - DPI), Track, 6 * DPI);
            Text(P.&Label, Bounds(R.Left, RowTop, BarLeft - 8 * DPI, RowTop + RowHeight), Fore, True, False);
            Line(X0, Y + H / 2, X1, Y + H / 2, NimbusBlendColor(Col, Back, 89), Max(2 * DPI, 2.0));
            if Active then
            begin
              Line(X0, BarTop, X0, BarBottom, NimbusColorWithAlpha(Col, 70), Max(1.0, DPI));
              Line(X1, BarTop, X1, BarBottom, NimbusColorWithAlpha(Col, 70), Max(1.0, DPI));
              FocusBox(Bounds(X0, Y, X0 + Max(3 * DPI, X1 - X0), Y + H), H / 2);
            end;
            Box(Bounds(X0, Y, X0 + Max(3 * DPI, X1 - X0), Y + H), Col, H / 2, True);
            if Active then
            begin Dot(X0, Y + H / 2, 5.5 * DPI, NimbusBlendColor($FFFFFFFF, Col, 56)); Dot(X1, Y + H / 2, 5.5 * DPI, NimbusBlendColor($FFFFFFFF, Col, 56)) end;
            Dot(X0, Y + H / 2, 4 * DPI, Col); Dot(X1, Y + H / 2, 4 * DPI, Col);
            Text(FormatFloat('0', Min(P.XValue, P.YValue)) + ' - ' + FormatFloat('0', Max(P.XValue, P.YValue)), Bounds(BarRight + 8 * DPI, RowTop, R.Right, RowTop + RowHeight), Muted, False, False);
            HitRow(Bounds(R.Left, RowTop, R.Right, RowTop + RowHeight));
          end;
        end;
      nctBusinessFunnel:
        begin
          Gap := Max(2 * DPI, 2.0); FunnelLeft := R.Left + 10 * DPI;
          LabelWidth := Min(210 * DPI, R.Width * 0.34);
          FunnelWidth := Min(Min(R.Width * 0.56, 360 * DPI), Max(80 * DPI, R.Width - LabelWidth - 30 * DPI));
          RowHeight := Max(18 * DPI, Min(34 * DPI, (R.Height - 20 * DPI) / PointCount));
          FunnelHeight := RowHeight * PointCount; FunnelTop := R.Top + Max(10 * DPI, (R.Height - FunnelHeight) / 2);
          LabelLeft := FunnelLeft + FunnelWidth + 14 * DPI; LabelWidth := Max(0.0, R.Right - LabelLeft);
          NameWidth := Max(0.0, LabelWidth - 86 * DPI); ValueWidth := Min(46 * DPI, LabelWidth * 0.24);
          PercentWidth := Min(40 * DPI, LabelWidth * 0.22); Maximum := Max(1.0, Points[0].Point.YValue);
          Total := 0; for I := 0 to PointCount - 1 do Total := Total + Max(0.0, Points[I].Point.YValue);
          AxisColor := NimbusBlendColor(Back, $FF000000, 46);
          for I := 0 to PointCount - 1 do
          begin
            SelectPoint(I); Value := Max(0.0, P.YValue);
            if I < PointCount - 1 then NextValue := Max(0.0, Points[I + 1].Point.YValue)
            else NextValue := Max(Value * 0.72, Maximum * 0.08);
            TopWidth := FunnelWidth * Sqrt(Value / Maximum); BottomWidth := FunnelWidth * Sqrt(NextValue / Maximum);
            RowTop := FunnelTop + I * RowHeight; Y := RowTop + Gap / 2; H := RowHeight - Gap;
            Polygon := [TPointF.Create(FunnelLeft + (FunnelWidth - TopWidth) / 2, Y),
              TPointF.Create(FunnelLeft + (FunnelWidth + TopWidth) / 2, Y),
              TPointF.Create(FunnelLeft + (FunnelWidth + BottomWidth) / 2, Y + H),
              TPointF.Create(FunnelLeft + (FunnelWidth - BottomWidth) / 2, Y + H)];
            Outline := [Polygon[0], Polygon[1], Polygon[2], Polygon[3], Polygon[0]];
            NewPrimitive(ncpPolygon, Col); A.Points := Polygon; A.Hit := CurrentHit; Add;
            NewPrimitive(ncpLine, AxisColor); A.Points := Outline; A.Width := Max(1.0, DPI); Add;
            if Active then
            begin
              K := 82; if ChartIsDark(C) then K := 108;
              NewPrimitive(ncpLine, NimbusColorWithAlpha(Col, K)); A.Points := Outline; A.Width := Max(3 * DPI, 3.0); Add;
              K := 87; if ChartIsDark(C) then K := 46;
              NewPrimitive(ncpLine, NimbusBlendColor($FFFFFFFF, Col, K)); A.Points := Outline; A.Width := Max(1.3 * DPI, 1.0); Add;
            end;
            Text(P.&Label, Bounds(LabelLeft, RowTop, LabelLeft + NameWidth, RowTop + RowHeight), Fore, False, False);
            Text(FormatFloat('0.##', P.YValue), Bounds(LabelLeft + NameWidth, RowTop, LabelLeft + NameWidth + ValueWidth, RowTop + RowHeight), Fore, True, False);
            Text(FormatFloat('0', P.YValue / Maximum * 100) + '%', Bounds(LabelLeft + NameWidth + ValueWidth + 4 * DPI, RowTop,
              LabelLeft + NameWidth + ValueWidth + 4 * DPI + PercentWidth, RowTop + RowHeight), Muted, True, False);
            HitRow(Bounds(FunnelLeft, RowTop, R.Right, RowTop + RowHeight));
          end;
        end;
      nctBusinessCalendarHeatmap:
        begin
          Columns := 26; if PointCount > 190 then Columns := 52; Rows := 7; CellCount := Min(PointCount, Columns * Rows);
          Footer := 22 * DPI; Gap := Max(2 * DPI, 2.0);
          GridLeft := R.Left + 4 * DPI; GridTop := R.Top + 4 * DPI;
          GridWidth := Max(0.0, R.Width - 8 * DPI); GridHeight := Max(0.0, R.Height - Footer - 8 * DPI);
          Cell := Min((GridWidth - Gap * (Columns - 1)) / Columns, (GridHeight - Gap * (Rows - 1)) / Rows);
          if Cell > 1 then
          begin
            StartX := GridLeft + (GridWidth - Columns * Cell - (Columns - 1) * Gap) / 2;
            StartY := GridTop + (GridHeight - Rows * Cell - (Rows - 1) * Gap) / 2;
            Empty := NimbusBlendColor(Muted, Back, 230);
            if M.HeatmapEmptyColor <> clNone then Empty := ColorToThemeColor(M.HeatmapEmptyColor);
            if M.HeatmapColorPreset <> nhcpTheme then Empty := ChartHeatmapColor(C, 0, True);
            for I := 0 to CellCount - 1 do
            begin
              SelectPoint(I); Ratio := EnsureRange(P.YValue / Maximum, 0.0, 1.0);
              if Ratio <= 0.001 then Col := Empty else Col := NimbusBlendColor(Empty, Col, Round((0.35 + Ratio * 0.65) * 255));
              if M.HeatmapColorPreset <> nhcpTheme then Col := ChartHeatmapColor(C, Ratio, Ratio <= 0.001);
              if P.Color <> clNone then Col := ColorToThemeColor(P.Color);
              X := StartX + (I div Rows) * (Cell + Gap); Y := StartY + (I mod Rows) * (Cell + Gap);
              if Active then FocusBox(Bounds(X, Y, X + Cell, Y + Cell), Min(4 * DPI, Cell * 0.28));
              Box(Bounds(X, Y, X + Cell, Y + Cell), Col, Min(4 * DPI, Cell * 0.28), True);
              HitRow(Bounds(X - Max(1.0, DPI), Y - Max(1.0, DPI), X + Cell + Max(1.0, DPI), Y + Cell + Max(1.0, DPI)));
            end;
            Y := R.Bottom - Footer; Text('Low', Bounds(GridLeft, Y, GridLeft + 46 * DPI, R.Bottom), Muted, False, False);
            SwatchX := GridLeft + 34 * DPI; Swatch := Max(8 * DPI, Min(12 * DPI, Footer * 0.55));
            Col := ChartAccentColor(C);
            if C.ChartPalette <> nil then Col := ColorToThemeColor(C.ChartPalette.GetSeriesColor(0));
            if (M.Series.Count > 0) and (M.Series[0].Color <> clNone) then Col := ColorToThemeColor(M.Series[0].Color);
            for K := 0 to 4 do
            begin
              X := SwatchX + K * (Swatch + 4 * DPI);
              HeatColor := NimbusBlendColor(Empty, Col, Round((0.35 + K / 4 * 0.65) * 255));
              if M.HeatmapColorPreset <> nhcpTheme then HeatColor := ChartHeatmapColor(C, K / 4, K = 0);
              Box(Bounds(X, Y + (Footer - Swatch) / 2, X + Swatch, Y + (Footer + Swatch) / 2), HeatColor, 3 * DPI);
            end;
            Text('High', Bounds(SwatchX + 5 * (Swatch + 4 * DPI), Y, SwatchX + 5 * (Swatch + 4 * DPI) + 60 * DPI, R.Bottom), Muted, False, False);
            Text(IntToStr(CellCount) + ' days', Bounds(R.Right - 104 * DPI, Y, R.Right - 4 * DPI, R.Bottom), Muted, True, False);
          end;
        end;
    end;
  end;
  SetLength(Items, Count); Result := Items;
end;

end.

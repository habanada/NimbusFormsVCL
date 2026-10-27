{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.Sparkline;

interface

uses
  Winapi.Windows, System.Classes, System.Types, System.UITypes, System.SysUtils, System.Math, System.Generics.Collections,
  Vcl.Graphics, NimbusForms.Rendering.Canvas, NimbusForms.Rendering.Types,
  NimbusForms.Theming.Types, NimbusForms.Theming.Palette, NimbusForms.Charts.Sparkline.Types;

type
  TSparklineGeometryCache = class
  private
    FItems: TDictionary<string, TSparklineGeometry>;
    FOrder: TList<string>;
    FCapacity: Integer;
    procedure SetCapacity(const AValue: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function TryGet(const AKey: string; out AGeometry: TSparklineGeometry): Boolean;
    procedure Add(const AKey: string; const AGeometry: TSparklineGeometry);
    property Capacity: Integer read FCapacity write SetCapacity;
  end;

  TSparklineGridDensity = (sgdNone, sgdSmall, sgdMedium, sgdLarge);

  TSparklineRenderContext = record
    Bounds: TRect;
    Font: TFont;
    Palette: TThemePalette;
    Options: TSparklineOptions;
    Values: TSparklineValues;
    ReferenceLines: TSparklineReferenceLineCollection;
    ThresholdBands: TSparklineThresholdBandCollection;
    Markers: TSparklineMarkerCollection;
    PPI: Integer;
    HoveredIndex, SelectedIndex: Integer;
    Enabled: Boolean;
    GridDensity: TSparklineGridDensity;
    GridColor: TColor;
    GridHorizontal, GridVertical: Boolean;
  end;

  TSparklineRenderer = class
  private
    FCache: TSparklineGeometryCache;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ClearCache;
    function BuildGeometry(const C: TSparklineRenderContext): TSparklineGeometry;
    procedure Render(const Canvas: INimbusRenderCanvas; const C: TSparklineRenderContext);
    property GeometryCache: TSparklineGeometryCache read FCache;
  end;

implementation

constructor TSparklineGeometryCache.Create;
begin
  inherited Create;
  FItems := TDictionary<string, TSparklineGeometry>.Create;
  FOrder := TList<string>.Create;
  FCapacity := 1024;
end;

destructor TSparklineGeometryCache.Destroy;
begin
  FOrder.Free; FItems.Free;
  inherited;
end;

procedure TSparklineGeometryCache.Clear;
begin
  FOrder.Clear; FItems.Clear;
end;

procedure TSparklineGeometryCache.SetCapacity(const AValue: Integer);
begin
  FCapacity := Max(0, AValue);
  while FOrder.Count > FCapacity do begin FItems.Remove(FOrder[0]); FOrder.Delete(0) end;
end;

function TSparklineGeometryCache.TryGet(const AKey: string; out AGeometry: TSparklineGeometry): Boolean;
begin
  Result := FItems.TryGetValue(AKey, AGeometry);
  if Result then begin FOrder.Remove(AKey); FOrder.Add(AKey) end;
end;

procedure TSparklineGeometryCache.Add(const AKey: string; const AGeometry: TSparklineGeometry);
begin
  if FCapacity = 0 then Exit;
  if FItems.ContainsKey(AKey) then FOrder.Remove(AKey);
  FItems.AddOrSetValue(AKey, AGeometry); FOrder.Add(AKey);
  SetCapacity(FCapacity);
end;

constructor TSparklineRenderer.Create;
begin
  inherited Create;
  FCache := TSparklineGeometryCache.Create;
end;

destructor TSparklineRenderer.Destroy;
begin
  FCache.Free;
  inherited;
end;

procedure TSparklineRenderer.ClearCache;
begin
  FCache.Clear;
end;

function TSparklineRenderer.BuildGeometry(const C: TSparklineRenderContext): TSparklineGeometry;
var
  O: TSparklineOptions; I, N, B, First, Last, MinI, MaxI, Limit, P, LabelWidth: Integer;
  Values: TSparklineValues; Indices, Samples: TArray<Integer>; Low, High, V, Slot, Gap, Zero, Y, W: Double;
  Hash: Cardinal; Bits: UInt64; Key: string; R: TRect; Range: TSparklineValueRange;
  procedure AddSample(const Index: Integer);
  var K: Integer;
  begin
    K := Length(Samples); SetLength(Samples, K + 1); Samples[K] := Index;
  end;
  function MapY(const Value: Double): Single;
  begin
    Result := R.Top + (1 - EnsureRange((Value - Range.Minimum) / Range.Span, 0.0, 1.0)) * Max(0, R.Height - 1);
  end;
begin
  Result := Default(TSparklineGeometry);
  Result.MinimumIndex := -1; Result.MaximumIndex := -1;
  O := C.Options;
  if (O = nil) or C.Bounds.IsEmpty then Exit;
  P := NimbusScaleValue(O.SparklinePadding, C.PPI);
  R := C.Bounds; R.Inflate(-P, -P);
  LabelWidth := 0;
  if O.ShowEndValueLabel then LabelWidth := NimbusScaleValue(Max(20, O.ValueLabelWidth), C.PPI);
  R.Right := Max(R.Left, R.Right - LabelWidth);
  if R.IsEmpty then Exit;
  N := 0; Low := MaxDouble; High := -MaxDouble; Hash := 17;
  SetLength(Values, Length(C.Values)); SetLength(Indices, Length(C.Values));
  for I := 0 to System.High(C.Values) do
  begin
    V := C.Values[I];
    if not SparklineFinite(V) then Continue;
    Values[N] := V; Indices[N] := I; Inc(N);
    Low := Min(Low, V); High := Max(High, V);
    Move(V, Bits, SizeOf(Bits));
    Hash := Cardinal((UInt64(Hash) * 31 + Cardinal(Bits xor (Bits shr 32)) + Cardinal(I)) and $FFFFFFFF);
  end;
  if N = 0 then Exit;
  SetLength(Values, N); SetLength(Indices, N);
  Range := TSparklineValueRange.Resolve(Low, High);
  case O.RangeMode of
    srmFixed: if O.FixedRange.IsValid then Range := TSparklineValueRange.Resolve(O.FixedRange.Minimum, O.FixedRange.Maximum);
    srmZeroBased: Range := TSparklineValueRange.Resolve(Min(0.0, Low), Max(0.0, High));
    srmSymmetric: begin V := Max(Abs(Low), Abs(High)); Range := TSparklineValueRange.Resolve(-V, V) end;
  end;
  Key := IntToStr(Hash) + ':' + IntToStr(N) + ':' + IntToStr(Length(C.Values)) + ':' +
    IntToStr(R.Left) + ':' + IntToStr(R.Top) + ':' + IntToStr(R.Width) + ':' + IntToStr(R.Height) + ':' +
    IntToStr(O.BarGap) + ':' + IntToStr(C.PPI) + ':' + IntToStr(Ord(O.Style)) + ':' + IntToStr(Ord(O.PerformanceMode)) + ':' +
    FloatToStr(Range.Minimum) + ':' + FloatToStr(Range.Maximum);
  if not O.UltraFastRendering and FCache.TryGet(Key, Result) then Exit;
  Limit := Max(2, R.Width * 2);
  if O.Style in [srsBars, srsWinLoss] then Limit := Max(2, R.Width div (2 + NimbusScaleValue(O.BarGap, C.PPI)));
  if N <= Limit then for I := 0 to N - 1 do AddSample(I)
  else
  begin
    if O.Style in [srsBars, srsWinLoss] then Limit := Max(1, Limit div 2);
    for B := 0 to Limit - 1 do
    begin
      First := (Int64(B) * N) div Limit; Last := (Int64(B + 1) * N) div Limit - 1;
      MinI := First; MaxI := First;
      for I := First + 1 to Last do
      begin
        if Values[I] < Values[MinI] then MinI := I;
        if Values[I] > Values[MaxI] then MaxI := I;
      end;
      if MinI <= MaxI then begin AddSample(MinI); if MinI <> MaxI then AddSample(MaxI) end
      else begin AddSample(MaxI); AddSample(MinI) end;
    end;
  end;
  N := Length(Samples);
  SetLength(Result.Points, N); SetLength(Result.SampleValues, N); SetLength(Result.SourceIndices, N);
  if O.Style in [srsBars, srsWinLoss] then SetLength(Result.Bars, N);
  Result.Range := Range; Result.PlotBounds := R; Result.ZeroY := MapY(0);
  if O.Style = srsWinLoss then Result.ZeroY := R.Top + R.Height * 0.5;
  Low := MaxDouble; High := -MaxDouble;
  Slot := R.Width / Max(1, N);
  Gap := Min(NimbusScaleValue(O.BarGap, C.PPI), Max(0.0, Slot - 1));
  W := Max(1.0, Slot - Gap);
  for I := 0 to N - 1 do
  begin
    V := Values[Samples[I]];
    Result.SampleValues[I] := V; Result.SourceIndices[I] := Indices[Samples[I]];
    if V < Low then begin Low := V; Result.MinimumIndex := I end;
    if V > High then begin High := V; Result.MaximumIndex := I end;
    if Length(Result.Bars) <> 0 then
    begin
      Zero := Result.ZeroY; Y := MapY(V);
      if O.Style = srsWinLoss then
      begin
        if V >= 0 then begin Y := R.Top + R.Height * 0.08; Zero := Result.ZeroY end
        else begin Y := Result.ZeroY; Zero := R.Top + R.Height * 0.92 end;
      end;
      Result.Bars[I] := TRectF.Create(R.Left + I * Slot + (Slot - W) / 2, Min(Y, Zero),
        R.Left + I * Slot + (Slot + W) / 2, Min(R.Bottom, Min(Y, Zero) + Max(R.Height * 0.02, Abs(Zero - Y))));
      Result.Points[I] := TPointF.Create(Result.Bars[I].CenterPoint.X, Y);
    end
    else if N = 1 then Result.Points[I] := TPointF.Create(R.Left + R.Width * 0.5, MapY(V))
    else Result.Points[I] := TPointF.Create(R.Left + (R.Width - 1) * I / (N - 1), MapY(V));
  end;
  if not O.UltraFastRendering then FCache.Add(Key, Result);
end;

procedure TSparklineRenderer.Render(const Canvas: INimbusRenderCanvas; const C: TSparklineRenderContext);
var
  O: TSparklineOptions; G: TSparklineGeometry; I, K, Radius, Y, X: Integer;
  Accent, ThemeAccent, Back, Fore, Muted, Border, Line, Fill, Negative, Col: TThemeColor;
  R: TRect; Area: TArray<TPointF>; Pair: array[0..1] of TPointF; A, B, Cross: TPointF;
  V, Total: Double; Marker: TSparklineMarker; RefLine: TSparklineReferenceLine;
  function ColorValue(const Value: TColor; const Fallback: TThemeColor): TThemeColor;
  begin
    if Value = clNone then Result := Fallback else Result := ColorToThemeColor(Value);
    if (Value <> clNone) and (O.ThemeMode = stmAdaptiveCustom) then
      Result := NimbusBlendColor(Result, Fallback, Round(O.ThemeInfluence * 255 / 100));
    if not C.Enabled then Result := NimbusBlendColor(Result, Back, 150);
  end;
  function ContrastColor(const Color: TThemeColor): TThemeColor;
  begin
    if (((Color shr 16) and 255) * 299 + ((Color shr 8) and 255) * 587 + (Color and 255) * 114) > 128000 then Result := $FF101820 else Result := $FFFFFFFF;
  end;
  procedure SelectionRing(const P: TPointF; const UnderColor: TThemeColor);
  var B: TRect; Size: Integer; Color: TThemeColor;
  begin
    Size := NimbusScaleValue(5, C.PPI); B := Rect(Round(P.X) - Size, Round(P.Y) - Size, Round(P.X) + Size + 1, Round(P.Y) + Size + 1);
    Color := ColorValue(O.SelectionColor, ContrastColor(UnderColor));
    Canvas.DrawEllipse(Back, B, Max(3.0, 4.0 * C.PPI / 96));
    Canvas.DrawEllipse(Color, B, Max(1.5, 2.0 * C.PPI / 96));
  end;
  function ValueY(const Value: Double): Integer;
  begin
    Result := Round(G.PlotBounds.Top + (1 - EnsureRange((Value - G.Range.Minimum) / G.Range.Span, 0.0, 1.0)) * Max(0, G.PlotBounds.Height - 1));
  end;
  procedure Dot(const P: TPointF; const Color: TThemeColor; const Size: Integer);
  begin
    Canvas.FillEllipse(Color, Rect(Round(P.X) - Size, Round(P.Y) - Size, Round(P.X) + Size + 1, Round(P.Y) + Size + 1));
  end;
  procedure LabelAt(const P: TPointF; const Text: string; const Color: TThemeColor);
  var W, H, Left, Top: Integer; S: TSize;
  begin
    S := Canvas.MeasureText(Text, C.Font, C.Bounds.Width, [ntfSingleLine, ntfNoPrefix]);
    W := S.cx + 4; H := S.cy;
    Left := EnsureRange(Round(P.X) - W div 2, C.Bounds.Left, Max(C.Bounds.Left, C.Bounds.Right - W));
    Top := Round(P.Y) - H - Radius - 2;
    if Top < C.Bounds.Top then Top := Round(P.Y) + Radius + 2;
    Top := EnsureRange(Top, C.Bounds.Top, Max(C.Bounds.Top, C.Bounds.Bottom - H));
    Canvas.DrawText(Text, C.Font, Color, Rect(Left, Top, Left + W, Top + H), [ntfCenter, ntfSingleLine, ntfNoPrefix]);
  end;
  procedure Band(const Minimum, Maximum: Double; const Color: TThemeColor);
  var Top, Bottom: Integer;
  begin
    if not SparklineFinite(Minimum) or not SparklineFinite(Maximum) then Exit;
    Top := ValueY(Max(Minimum, Maximum)); Bottom := ValueY(Min(Minimum, Maximum));
    Canvas.FillRectangle(Color, Rect(G.PlotBounds.Left, Top, G.PlotBounds.Right, Max(Top + 1, Bottom)));
  end;
  procedure AreaFill(const Points: array of TPointF; const Color: TThemeColor);
  begin
    if O.UseGradientArea then Canvas.FillPolygonGradient(NimbusColorWithAlpha(Color, O.AreaGradientAlphaTop),
      NimbusColorWithAlpha(Color, O.AreaGradientAlphaBottom), Points, G.PlotBounds)
    else Canvas.FillPolygonF(NimbusColorWithAlpha(Color, O.AreaGradientAlphaTop), Points);
  end;
  procedure SegmentArea(const P1, P2: TPointF; const Color: TThemeColor);
  var Polygon: array[0..3] of TPointF;
  begin
    Polygon[0] := TPointF.Create(P1.X, G.ZeroY); Polygon[1] := P1;
    Polygon[2] := P2; Polygon[3] := TPointF.Create(P2.X, G.ZeroY);
    AreaFill(Polygon, Color);
  end;
begin
  O := C.Options;
  if (Canvas = nil) or (O = nil) or (C.Font = nil) or C.Bounds.IsEmpty then Exit;
  Back := NimbusControlBackColor(C.Palette); Fore := NimbusControlForeColor(C.Palette);
  Accent := NimbusAccentColor(C.Palette); Border := NimbusControlBorderColor(C.Palette);
  Muted := NimbusBlendColor(Fore, Back, 145);
  if O.ThemeMode = stmDark then begin Back := ThemeColor(255, 30, 30, 30); Fore := ThemeColor(255, 230, 230, 230); Muted := ThemeColor(255, 150, 150, 150); Border := ThemeColor(255, 65, 65, 65) end;
  if O.ThemeMode = stmLight then begin Back := ThemeColor(255, 255, 255, 255); Fore := ThemeColor(255, 35, 35, 35); Muted := ThemeColor(255, 125, 125, 125); Border := ThemeColor(255, 205, 205, 205) end;
  ThemeAccent := Accent; Accent := ColorValue(O.AccentColor, ThemeAccent); Fore := ColorValue(clNone, Fore);
  Muted := ColorValue(O.MutedColor, Muted); Border := ColorValue(O.BorderColor, Border);
  Line := Accent; Fill := Accent;
  if O.LineColor <> clNone then Line := ColorValue(O.LineColor, ThemeAccent);
  if O.FillColor <> clNone then Fill := ColorValue(O.FillColor, ThemeAccent);
  Negative := ColorValue(O.NegativeColor, ThemeColor(255, 225, 75, 80));
  if O.PaintBackground then Canvas.Clear(Back, C.Bounds);
  Canvas.PushClip(C.Bounds);
  try
    G := BuildGeometry(C); Radius := Max(2, NimbusScaleValue(3, C.PPI));
    if C.GridDensity <> sgdNone then
    begin
      R := C.Bounds; R.Inflate(-NimbusScaleValue(O.SparklinePadding, C.PPI), -NimbusScaleValue(O.SparklinePadding, C.PPI));
      if O.ShowEndValueLabel then R.Right := Max(R.Left, R.Right - NimbusScaleValue(Max(20, O.ValueLabelWidth), C.PPI));
      if not G.PlotBounds.IsEmpty then R := G.PlotBounds;
      if (R.Width > 1) and (R.Height > 1) then
      begin
        case C.GridDensity of
          sgdSmall: K := 16;
          sgdMedium: K := 8;
          sgdLarge: K := 4;
        else K := 0 end;
        Col := NimbusBlendColor(Fore, Back, 215);
        if C.GridColor <> clNone then Col := ColorValue(C.GridColor, Col);
        if C.GridVertical then for I := 1 to K - 1 do
        begin
          X := R.Left + (Int64(I) * (R.Width - 1)) div K;
          Canvas.DrawLine(Col, X, R.Top, X, R.Bottom - 1);
        end;
        if C.GridHorizontal then for I := 1 to K - 1 do
        begin
          Y := R.Top + (Int64(I) * (R.Height - 1)) div K;
          Canvas.DrawLine(Col, R.Left, Y, R.Right - 1, Y);
        end;
      end;
    end;
    if Length(G.Points) = 0 then
    begin
      if O.ShowEmptyState then
      begin
        if O.EmptyLineVisible then begin Y := C.Bounds.CenterPoint.Y; Canvas.DrawLine(Muted, C.Bounds.Left + 2, Y, C.Bounds.Right - 2, Y) end;
        if O.EmptyText <> '' then Canvas.DrawText(O.EmptyText, C.Font, Muted, C.Bounds, [ntfCenter, ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix]);
      end;
    end
    else
    begin
      if O.ShowRangeBand then Band(O.BandMinimum, O.BandMaximum, NimbusColorWithAlpha(ColorValue(O.RangeBandColor, Accent), 32));
      if C.ThresholdBands <> nil then
        for I := 0 to C.ThresholdBands.Count - 1 do
          if C.ThresholdBands[I].Visible then Band(C.ThresholdBands[I].Minimum, C.ThresholdBands[I].Maximum,
            NimbusColorWithAlpha(ColorValue(C.ThresholdBands[I].Color, Accent), C.ThresholdBands[I].Alpha));
      if O.ShowZeroLine and (G.Range.Minimum < 0) and (G.Range.Maximum > 0) then
        Canvas.DrawLine(ColorValue(O.ZeroLineColor, Border), G.PlotBounds.Left, Round(G.ZeroY), G.PlotBounds.Right, Round(G.ZeroY));
      if O.ShowTargetLine then begin Y := ValueY(O.TargetValue); Canvas.DrawDashedLine(ColorValue(O.TargetLineColor, Accent), G.PlotBounds.Left, Y, G.PlotBounds.Right, Y, 1, 1) end;
      if O.ShowAverageLine then
      begin
        Total := 0; K := 0;
        for V in C.Values do if SparklineFinite(V) then begin Total := Total + V; Inc(K) end;
        if K > 0 then begin Y := ValueY(Total / K); Canvas.DrawDashedLine(ColorValue(O.AverageLineColor, Muted), G.PlotBounds.Left, Y, G.PlotBounds.Right, Y, 1, 1) end;
      end;
      if C.ReferenceLines <> nil then for I := 0 to C.ReferenceLines.Count - 1 do
      begin
        RefLine := C.ReferenceLines[I];
        if not RefLine.Visible or not SparklineFinite(RefLine.Value) then Continue;
        Y := ValueY(RefLine.Value); Col := ColorValue(RefLine.Color, Muted);
        Canvas.DrawDashedLine(Col, G.PlotBounds.Left, Y, G.PlotBounds.Right, Y, RefLine.StrokeWidth * C.PPI / 96, Ord(RefLine.DashStyle));
        if RefLine.Text <> '' then Canvas.DrawText(RefLine.Text, C.Font, Col, Rect(G.PlotBounds.Left, Y - 18, G.PlotBounds.Right, Y), [ntfRight, ntfSingleLine, ntfNoPrefix]);
      end;
      Canvas.PushClip(G.PlotBounds);
      try
        if (O.Style = srsArea) or O.ShowArea then
        begin
          if O.SplitAreaByZero then
            for I := 1 to High(G.Points) do
            begin
              A := G.Points[I - 1]; B := G.Points[I];
              if (G.SampleValues[I - 1] < 0) <> (G.SampleValues[I] < 0) then
              begin
                V := -G.SampleValues[I - 1] / (G.SampleValues[I] - G.SampleValues[I - 1]);
                Cross := TPointF.Create(A.X + (B.X - A.X) * V, G.ZeroY);
                if G.SampleValues[I - 1] < 0 then SegmentArea(A, Cross, Negative) else SegmentArea(A, Cross, Fill);
                if G.SampleValues[I] < 0 then SegmentArea(Cross, B, Negative) else SegmentArea(Cross, B, Fill);
              end
              else if G.SampleValues[I] < 0 then SegmentArea(A, B, Negative) else SegmentArea(A, B, Fill);
            end
          else
          begin
            SetLength(Area, Length(G.Points) + 2);
            Area[0] := TPointF.Create(G.Points[0].X, G.ZeroY);
            for I := 0 to High(G.Points) do Area[I + 1] := G.Points[I];
            Area[High(Area)] := TPointF.Create(G.Points[High(G.Points)].X, G.ZeroY);
            AreaFill(Area, Fill);
          end;
        end;
        if O.Style in [srsBars, srsWinLoss] then
          for I := 0 to High(G.Bars) do
          begin
            Col := Line; if G.SampleValues[I] < 0 then Col := Negative;
            R := Rect(Round(G.Bars[I].Left), Round(G.Bars[I].Top), Round(G.Bars[I].Right), Round(G.Bars[I].Bottom));
            R.Right := Max(R.Left + 1, R.Right); R.Bottom := Max(R.Top + 1, R.Bottom);
            if O.UseRoundedBars and not O.UltraFastRendering then Canvas.FillRoundedRectangle(Col, R, NimbusScaleValue(O.BarCornerRadius, C.PPI)) else Canvas.FillRectangle(Col, R);
          end
        else if O.Style = srsDots then for I := 0 to High(G.Points) do Dot(G.Points[I], Line, Max(1, Radius - 1))
        else if Length(G.Points) = 1 then Dot(G.Points[0], Line, Radius)
        else if O.ColorizeNegativeSegments or O.ColorizeRisingFallingSegments then
          for I := 1 to High(G.Points) do
          begin
            Col := Line;
            if O.ColorizeRisingFallingSegments then
              if G.SampleValues[I] >= G.SampleValues[I - 1] then Col := ColorValue(O.RisingColor, ThemeColor(255, 50, 175, 110))
              else Col := ColorValue(O.FallingColor, Negative);
            Pair[0] := G.Points[I - 1]; Pair[1] := G.Points[I];
            if O.ColorizeNegativeSegments then
            begin
              if (G.SampleValues[I - 1] < 0) <> (G.SampleValues[I] < 0) then
              begin
                V := -G.SampleValues[I - 1] / (G.SampleValues[I] - G.SampleValues[I - 1]);
                Cross := TPointF.Create(Pair[0].X + (Pair[1].X - Pair[0].X) * V, G.ZeroY);
                Pair[1] := Cross;
                if G.SampleValues[I - 1] < 0 then Canvas.DrawPolyline(Negative, Pair, O.StrokeWidth * C.PPI / 96)
                else Canvas.DrawPolyline(Col, Pair, O.StrokeWidth * C.PPI / 96);
                Pair[0] := Cross; Pair[1] := G.Points[I];
              end;
              if G.SampleValues[I] < 0 then Col := Negative;
            end;
            Canvas.DrawPolyline(Col, Pair, O.StrokeWidth * C.PPI / 96);
          end
        else Canvas.DrawPolyline(Line, G.Points, O.StrokeWidth * C.PPI / 96);
      finally Canvas.PopClip end;
      if O.ShowStartPoint then Dot(G.Points[0], ColorValue(O.StartPointColor, Accent), Radius);
      if O.ShowLastPoint then Dot(G.Points[High(G.Points)], ColorValue(O.LastPointColor, Accent), Radius);
      if O.ShowMinMaxPoints then
      begin
        Dot(G.Points[G.MinimumIndex], ColorValue(O.MinPointColor, Negative), Radius);
        Dot(G.Points[G.MaximumIndex], ColorValue(O.MaxPointColor, ThemeColor(255, 50, 175, 110)), Radius);
      end;
      if O.ShowMinMaxValueLabels then
      begin
        LabelAt(G.Points[G.MinimumIndex], SparklineFormatValue(G.SampleValues[G.MinimumIndex], O.ValueFormat), Muted);
        LabelAt(G.Points[G.MaximumIndex], SparklineFormatValue(G.SampleValues[G.MaximumIndex], O.ValueFormat), Muted);
      end;
      if C.Markers <> nil then for I := 0 to C.Markers.Count - 1 do
      begin
        Marker := C.Markers[I]; if not Marker.Visible then Continue;
        K := -1;
        for X := 0 to High(G.SourceIndices) do if G.SourceIndices[X] = Marker.PointIndex then begin K := X; Break end;
        if K < 0 then Continue;
        A := G.Points[K]; X := Round(A.X); Y := Round(A.Y);
        Radius := Max(1, Round(Marker.Radius * C.PPI / 96)); Col := ColorValue(Marker.Color, ColorValue(O.MarkerColor, Accent));
        case Marker.Shape of
          smsCircle: Dot(A, Col, Radius);
          smsSquare: Canvas.FillRectangle(Col, Rect(X - Radius, Y - Radius, X + Radius + 1, Y + Radius + 1));
          smsDiamond: Canvas.FillPolygonF(Col, [TPointF.Create(X, Y - Radius), TPointF.Create(X + Radius, Y), TPointF.Create(X, Y + Radius), TPointF.Create(X - Radius, Y)]);
          smsTriangle: Canvas.FillTriangle(Col, Point(X, Y - Radius), Point(X + Radius, Y + Radius), Point(X - Radius, Y + Radius));
          smsCross: begin Canvas.DrawLine(Col, X - Radius, Y - Radius, X + Radius, Y + Radius); Canvas.DrawLine(Col, X - Radius, Y + Radius, X + Radius, Y - Radius) end;
        end;
        if Marker.Text <> '' then LabelAt(A, Marker.Text, Col);
      end;
      for I := 0 to High(G.Points) do
      begin
        if (G.SourceIndices[I] = C.HoveredIndex) and O.ShowHoverLine then
        begin
          X := Round(G.Points[I].X); Canvas.DrawLine(ColorValue(O.HoverLineColor, Muted), X, G.PlotBounds.Top, X, G.PlotBounds.Bottom);
          Dot(G.Points[I], Back, Max(3, NimbusScaleValue(5, C.PPI)));
          Col := Line; if G.SampleValues[I] < 0 then Col := Negative;
          Dot(G.Points[I], ContrastColor(Col), Max(2, NimbusScaleValue(3, C.PPI)));
        end;
        if (G.SourceIndices[I] = C.SelectedIndex) and O.ShowSelection then
        begin Col := Line; if G.SampleValues[I] < 0 then Col := Negative; SelectionRing(G.Points[I], Col) end;
      end;
      if O.ShowEndValueLabel then
        Canvas.DrawText(SparklineFormatValue(G.SampleValues[High(G.SampleValues)], O.ValueFormat), C.Font, Fore,
          Rect(G.PlotBounds.Right + 2, C.Bounds.Top, C.Bounds.Right, C.Bounds.Bottom), [ntfRight, ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix]);
    end;
    if O.ShowBorder then Canvas.DrawRectangle(Border, Rect(C.Bounds.Left, C.Bounds.Top, C.Bounds.Right - 1, C.Bounds.Bottom - 1));
  finally Canvas.PopClip end;
end;

end.

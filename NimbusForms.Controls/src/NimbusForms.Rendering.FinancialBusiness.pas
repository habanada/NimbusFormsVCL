unit NimbusForms.Rendering.FinancialBusiness;

interface

uses System.Types, System.Math, System.SysUtils, System.Classes, System.Generics.Collections,
  Vcl.Graphics, NimbusForms.Rendering.Charts, NimbusForms.Charts.Types, NimbusForms.Charts.Financial.Workspace,
  NimbusForms.Charts.Financial.Business.Types;

type
  TNimbusFinancialPanelLayout = record
    PanelIndex: Integer;
    Bounds, Header, HeaderText, Plot, Axis, Separator, CollapseButton, CloseButton, PinButton, SettingsButton: TRect;
    Minimum, Maximum, PercentBase: Double;
    CanResize: Boolean;
  end;
  TNimbusFinancialSidePanelLayout = record
    PanelIndex: Integer;
    Bounds, Header, Body, CollapseButton, PinButton, Splitter, HeightSplitter: TRect;
    ContentHeight: Integer;
  end;
  TNimbusFinancialScene = record
    Bounds, Header, Graph, TimeAxis, RangeSelector, PricePlot: TRect;
    Panels: TArray<TNimbusFinancialPanelLayout>;
    SidePanels: TArray<TNimbusFinancialSidePanelLayout>;
  end;
  TNimbusFinancialBusinessRenderer = class(TNimbusChartRenderer)
  protected
    function Build(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>; override;
  public
    function CanRender(const AType: TNimbusChartType): Boolean; override;
    function Arrange(const C: TNimbusChartRenderContext): TNimbusChartLayout; override;
    function HitTest(const C: TNimbusChartRenderContext; const Location: TPointF): TNimbusChartHit; override;
    class function Layout(const C: TNimbusChartRenderContext): TNimbusFinancialScene; static;
    class function CandleX(const W: TNimbusFinancialWorkspace; const Plot: TRect; const Index: Integer): Double; static;
    class function ValueY(const Panel: TNimbusFinancialPanel; const Layout: TNimbusFinancialPanelLayout; const Value: Double): Double; static;
    class function YValue(const Panel: TNimbusFinancialPanel; const Layout: TNimbusFinancialPanelLayout; const Y: Double): Double; static;
  end;

implementation

uses Winapi.Windows, NimbusForms.Charts.Financial.Types,
  NimbusForms.Charts.Financial.Palette, NimbusForms.Charts.Financial.Indicators,
  NimbusForms.Rendering.ChartPrimitives, NimbusForms.Rendering.Types, NimbusForms.Theming.Types;

function Finite(const Value: Double): Boolean;
begin Result := not IsNan(Value) and not IsInfinite(Value) end;

function FinancialBodyWidth(const W: TNimbusFinancialWorkspace; const Plot: TRect; const Limit: Double): Double;
var Slot, Spacing: Double;
begin
  Slot := Max(1.0, Plot.Width / Max(1, W.Viewport.VisibleCount)); Spacing := EnsureRange(Slot * 0.28, 1.0, 8.0);
  if Slot < 3 then Spacing := 0;
  Result := Max(1.0, Min(Slot - Spacing, Slot * Limit));
end;

function FinancialHit(const Area: TNimbusFinancialHitArea; const Panel, Point, Element: Integer; const Text: string = ''): TNimbusChartHit;
begin
  Result := TNimbusChartHit.None; Result.FinancialArea := Area; Result.SeriesIndex := Panel;
  Result.PointIndex := Point; Result.ElementIndex := Element; Result.Text := Text;
  if Area = nfhaCandle then Result.Area := nchaPoint
  else if Area = nfhaAnnotation then Result.Area := nchaAnnotation
  else if Area <> nfhaNone then Result.Area := nchaLegend;
end;

class function TNimbusFinancialBusinessRenderer.CandleX(const W: TNimbusFinancialWorkspace; const Plot: TRect; const Index: Integer): Double;
begin Result := Plot.Left + (Index - W.Viewport.FirstVisibleIndex + 0.5) * Plot.Width / Max(1, W.Viewport.VisibleCount) end;

class function TNimbusFinancialBusinessRenderer.ValueY(const Panel: TNimbusFinancialPanel; const Layout: TNimbusFinancialPanelLayout; const Value: Double): Double;
var Ratio, V, Minimum, Maximum: Double;
begin
  V := Value; Minimum := Layout.Minimum; Maximum := Layout.Maximum;
  if (Panel.ScaleMode = nfsmPercent) and (Abs(Layout.PercentBase) > 1E-12) then V := (Value / Layout.PercentBase - 1) * 100;
  if Panel.ScaleMode = nfsmLogarithmic then
  begin
    Minimum := Ln(Max(1E-7, Minimum)); Maximum := Ln(Max(1E-7, Maximum)); V := Ln(Max(1E-7, V));
  end;
  Ratio := (V - Minimum) / Max(1E-12, Maximum - Minimum);
  Result := Layout.Plot.Bottom - EnsureRange(Ratio, 0.0, 1.0) * Layout.Plot.Height;
end;

class function TNimbusFinancialBusinessRenderer.YValue(const Panel: TNimbusFinancialPanel; const Layout: TNimbusFinancialPanelLayout; const Y: Double): Double;
var Ratio: Double;
begin
  Ratio := (Layout.Plot.Bottom - Y) / Max(1, Layout.Plot.Height);
  if Panel.ScaleMode = nfsmLogarithmic then Result := Exp(Ln(Max(1E-7, Layout.Minimum)) + Ratio * (Ln(Max(1E-7, Layout.Maximum)) - Ln(Max(1E-7, Layout.Minimum))))
  else Result := Layout.Minimum + Ratio * (Layout.Maximum - Layout.Minimum);
  if Panel.ScaleMode = nfsmPercent then Result := Layout.PercentBase * (1 + Result / 100);
end;

class function TNimbusFinancialBusinessRenderer.Layout(const C: TNimbusChartRenderContext): TNimbusFinancialScene;
var W: TNimbusFinancialWorkspace; R, SideBounds: TRect; I, J, Count, Expanded, Cursor, Height, Available, LastExpanded: Integer;
  DPI, Weight, TotalWeight, LeftWidth, RightWidth, SideWeight: Double; P: TNimbusFinancialPanel;
  S: TNimbusFinancialSidePanel; PL: TNimbusFinancialPanelLayout; SL: TNimbusFinancialSidePanelLayout;
  PanelList: TList<TNimbusFinancialPanelLayout>; SideList: TList<TNimbusFinancialSidePanelLayout>;
  Snapshot: TNimbusFinancialIndicatorSnapshot; Low, High, Padding: Double;
  Heights: TArray<Integer>; MinimumTotal, PreferredTotal, AssignedHeight, MinimumHeight, PreferredHeight, PriceIndex: Integer;
  ButtonRight, ButtonSize, ButtonPadding, ButtonSpacing: Integer;
  procedure Include(const Value: Double);
  begin if Finite(Value) then begin Low := Min(Low, Value); High := Max(High, Value) end end;
  function HeaderButtonBounds(const Enabled: Boolean): TRect;
  begin
    Result := TRect.Empty;
    if not Enabled then Exit;
    if ButtonRight - ButtonSize >= PL.Header.Left + ButtonPadding then
      Result := Rect(ButtonRight - ButtonSize, PL.Header.Top + Max(0, (PL.Header.Height - ButtonSize) div 2), ButtonRight,
        PL.Header.Top + Max(0, (PL.Header.Height - ButtonSize) div 2) + ButtonSize);
    Dec(ButtonRight, ButtonSize + ButtonSpacing);
  end;
  procedure Side(const Position: TNimbusFinancialSidePanelPosition; const Width: Integer);
  var K, N, Y, H, Content, ColumnX, ColumnWidth, Collapsed, DesiredWidth: Integer; SidePanel: TNimbusFinancialSidePanel;
  begin
    if Width <= 0 then Exit; N := 0; SideWeight := 0; Collapsed := 0; DesiredWidth := 0;
    for K := 0 to W.SidePanels.Count - 1 do
    begin
      SidePanel := W.SidePanels[K];
      if SidePanel.Visible and (SidePanel.State <> nfspsHidden) and (SidePanel.Position = Position) then
      begin Inc(N); Inc(DesiredWidth, SidePanel.Width); if SidePanel.State = nfspsExpanded then SideWeight := SideWeight + SidePanel.PreferredHeight else Inc(Collapsed) end;
    end;
    if N = 0 then Exit; Y := R.Top; ColumnX := C.Bounds.Left + Round(8 * DPI);
    if Position = nfsppRight then ColumnX := R.Right + Round(6 * DPI);
    for K := 0 to W.SidePanels.Count - 1 do
    begin
      SidePanel := W.SidePanels[K];
      if not SidePanel.Visible or (SidePanel.State = nfspsHidden) or (SidePanel.Position <> Position) then Continue;
      SL := Default(TNimbusFinancialSidePanelLayout); SL.PanelIndex := K;
      if Position = nfsppLeft then SideBounds := Rect(C.Bounds.Left + Round(8 * DPI), Y, R.Left - Round(6 * DPI), R.Bottom)
      else SideBounds := Rect(R.Right + Round(6 * DPI), Y, C.Bounds.Right - Round(8 * DPI), R.Bottom);
      H := Round(30 * DPI);
      if SidePanel.State = nfspsExpanded then H := Max(Round(40 * DPI), Round((R.Height - N * 4 * DPI - Collapsed * 30 * DPI) * SidePanel.PreferredHeight / Max(1.0, SideWeight)));
      if W.Options.SidePanelLayoutMode = nfslColumns then
      begin
        ColumnWidth := Max(1, Round((Width - Round(6 * DPI)) * SidePanel.Width / Max(1, DesiredWidth)));
        SideBounds := Rect(ColumnX, R.Top, ColumnX + ColumnWidth - Round(4 * DPI), R.Bottom);
        Inc(ColumnX, ColumnWidth); H := R.Height;
      end
      else SideBounds.Bottom := Min(R.Bottom, Y + H);
      SL.Bounds := SideBounds;
      SL.Header := SideBounds; SL.Header.Bottom := Min(SL.Header.Bottom, SL.Header.Top + Round(28 * DPI));
      SL.Body := SideBounds; SL.Body.Top := SL.Header.Bottom;
      SL.CollapseButton := Rect(SL.Header.Right - Round(24 * DPI), SL.Header.Top, SL.Header.Right, SL.Header.Bottom);
      SL.PinButton := SL.CollapseButton; SL.PinButton.Offset(-Round(24 * DPI), 0);
      SL.Splitter := SideBounds;
      if Position = nfsppLeft then SL.Splitter := Rect(SideBounds.Right, SideBounds.Top, SideBounds.Right + Round(4 * DPI), SideBounds.Bottom)
      else SL.Splitter := Rect(SideBounds.Left - Round(4 * DPI), SideBounds.Top, SideBounds.Left, SideBounds.Bottom);
      if (W.Options.SidePanelLayoutMode = nfslStacked) and (SidePanel.State = nfspsExpanded) and (SideBounds.Bottom < R.Bottom) then
        SL.HeightSplitter := Rect(SideBounds.Left, SideBounds.Bottom, SideBounds.Right, Min(R.Bottom, SideBounds.Bottom + Round(4 * DPI)));
      Content := 0; for var ItemIndex := 0 to SidePanel.Items.Count - 1 do if SidePanel.Items[ItemIndex].Visible then Inc(Content, Round(SidePanel.Items[ItemIndex].Height * DPI));
      SL.ContentHeight := Content; SideList.Add(SL); Y := SideBounds.Bottom + Round(4 * DPI);
    end;
  end;
begin
  Result := Default(TNimbusFinancialScene); Result.Bounds := C.Bounds; W := C.Financial;
  if W = nil then Exit; DPI := Max(1, C.PPI) / 96; R := C.Bounds; R.Inflate(-Round(8 * DPI), -Round(8 * DPI));
  if R.IsEmpty then Exit;
  Result.Header := R; Result.Header.Bottom := Min(R.Bottom, R.Top + Round(42 * DPI)); R.Top := Result.Header.Bottom;
  Result.TimeAxis := R; Result.TimeAxis.Top := Max(R.Top, R.Bottom - Round(24 * DPI)); R.Bottom := Result.TimeAxis.Top;
  if W.RangeSelector.Visible then
  begin
    Result.RangeSelector := R; Result.RangeSelector.Top := Max(R.Top, R.Bottom - Round(30 * DPI)); R.Bottom := Result.RangeSelector.Top;
    if W.RangeSelector.Placement = nfrpHeaderRight then
    begin Result.RangeSelector := Result.Header; Result.RangeSelector.Left := Max(Result.Header.Left, Result.Header.Right - Round(450 * DPI)); R.Bottom := Result.TimeAxis.Top end;
  end;
  LeftWidth := 0; RightWidth := 0;
  if W.Options.ShowDashboardPanels then
  begin
    for I := 0 to W.SidePanels.Count - 1 do
    begin
      S := W.SidePanels[I]; if not S.Visible or (S.State = nfspsHidden) then Continue;
      if W.Options.SidePanelLayoutMode = nfslColumns then
      begin if S.Position = nfsppLeft then LeftWidth := LeftWidth + S.Width * DPI else RightWidth := RightWidth + S.Width * DPI end
      else if S.Position = nfsppLeft then LeftWidth := Max(LeftWidth, S.Width * DPI) else RightWidth := Max(RightWidth, S.Width * DPI);
    end;
    if W.Options.LeftSidePanelAreaWidth > 0 then LeftWidth := W.Options.LeftSidePanelAreaWidth * DPI;
    if W.Options.RightSidePanelAreaWidth > 0 then RightWidth := W.Options.RightSidePanelAreaWidth * DPI;
    Weight := Max(0.0, R.Width - 180 * DPI) / Max(1.0, LeftWidth + RightWidth);
    if Weight < 1 then begin LeftWidth := LeftWidth * Weight; RightWidth := RightWidth * Weight end;
    Inc(R.Left, Round(LeftWidth)); Dec(R.Right, Round(RightWidth));
  end;
  Result.Graph := R; Result.TimeAxis.Left := R.Left; Result.TimeAxis.Right := R.Right;
  PanelList := TList<TNimbusFinancialPanelLayout>.Create; SideList := TList<TNimbusFinancialSidePanelLayout>.Create;
  try
    Side(nfsppLeft, Round(LeftWidth)); Side(nfsppRight, Round(RightWidth));
    Expanded := 0; TotalWeight := 0; Count := 0; Available := R.Height; LastExpanded := -1;
    for I := 0 to W.Panels.Count - 1 do if W.PanelIsActive(W.Panels[I]) then
    begin
      Inc(Count); if W.Panels[I].State = nfpsCollapsed then Dec(Available, Round(30 * DPI))
      else begin Inc(Expanded); TotalWeight := TotalWeight + W.Panels[I].HeightWeight; LastExpanded := I end;
    end;
    Dec(Available, Max(0, Count - 1) * Round(4 * DPI)); Available := Max(0, Available); Cursor := R.Top;
    SetLength(Heights, W.Panels.Count); MinimumTotal := 0; PreferredTotal := 0;
    for I := 0 to W.Panels.Count - 1 do if W.PanelIsActive(W.Panels[I]) and (W.Panels[I].State = nfpsExpanded) then
    begin
      MinimumHeight := Round(Max(24, W.Panels[I].MinimumHeight) * DPI);
      Inc(MinimumTotal, MinimumHeight); Inc(PreferredTotal, Max(MinimumHeight, Round(W.Panels[I].PreferredHeight * DPI)));
    end;
    AssignedHeight := 0;
    for I := 0 to W.Panels.Count - 1 do if W.PanelIsActive(W.Panels[I]) and (W.Panels[I].State = nfpsExpanded) then
    begin
      MinimumHeight := Round(Max(24, W.Panels[I].MinimumHeight) * DPI); PreferredHeight := Max(MinimumHeight, Round(W.Panels[I].PreferredHeight * DPI));
      if I = LastExpanded then Height := Max(1, Available - AssignedHeight)
      else if MinimumTotal >= Available then Height := Max(1, Floor(Available * MinimumHeight / Max(1, MinimumTotal) + 0.5))
      else if PreferredTotal <= Available then Height := PreferredHeight + Floor((Available - PreferredTotal) * PreferredHeight / Max(1, PreferredTotal) + 0.5)
      else Height := Max(MinimumHeight, PreferredHeight - Floor((PreferredTotal - Available) * (PreferredHeight - MinimumHeight) / Max(1, PreferredTotal - MinimumTotal) + 0.5));
      Heights[I] := Height; Inc(AssignedHeight, Height);
    end;
    for I := 0 to W.Panels.Count - 1 do
    begin
      P := W.Panels[I]; if not W.PanelIsActive(P) then Continue;
      PL := Default(TNimbusFinancialPanelLayout); PL.PanelIndex := I;
      if P.State = nfpsCollapsed then Height := Round(30 * DPI)
      else Height := Heights[I];
      PL.Bounds := Rect(R.Left, Cursor, R.Right, Min(R.Bottom, Cursor + Height));
      PL.Header := PL.Bounds; PL.Header.Bottom := Min(PL.Header.Bottom, PL.Header.Top + Round(20 * DPI));
      PL.Plot := PL.Bounds; PL.Plot.Top := PL.Header.Bottom; PL.Axis := PL.Plot;
      if P.YAxisPosition <> nfyapHidden then
        if P.YAxisPosition = nfyapRight then begin Dec(PL.Plot.Right, Round(62 * DPI)); PL.Axis.Left := PL.Plot.Right end
        else begin Inc(PL.Plot.Left, Round(62 * DPI)); PL.Axis.Right := PL.Plot.Left end
      else PL.Axis := TRect.Empty;
      if PL.Plot.Right < PL.Plot.Left then PL.Plot.Right := PL.Plot.Left;
      ButtonSize := Round(18 * DPI); ButtonPadding := Round(5 * DPI); ButtonSpacing := Round(3 * DPI);
      ButtonRight := PL.Header.Right - ButtonPadding;
      if not PL.Axis.IsEmpty and (PL.Axis.Left > PL.Header.Left) then ButtonRight := Min(ButtonRight, PL.Axis.Left - ButtonPadding);
      PL.CloseButton := HeaderButtonBounds(P.AllowClose and not P.IsPinned);
      PL.CollapseButton := HeaderButtonBounds(P.AllowCollapse);
      PL.PinButton := HeaderButtonBounds(P.AllowPin); PL.SettingsButton := HeaderButtonBounds(P.AllowSettings);
      PL.HeaderText := PL.Header; Inc(PL.HeaderText.Left, ButtonPadding); PL.HeaderText.Right := Max(PL.HeaderText.Left, ButtonRight - ButtonPadding);
      PL.Separator := Rect(R.Left, PL.Bounds.Bottom, R.Right, Min(R.Bottom, PL.Bounds.Bottom + Round(4 * DPI)));
      Low := MaxDouble; High := -MaxDouble;
      if P.PanelType = nfptPrice then for J := W.Viewport.FirstVisibleIndex to W.Viewport.LastVisibleIndex do
      begin Include(W.Candles[J].Low); Include(W.Candles[J].High) end;
      for Snapshot in W.Snapshots do if SameText(Snapshot.PanelKey, P.Key) then
      begin
        for J := W.Viewport.FirstVisibleIndex to Min(W.Viewport.LastVisibleIndex, System.High(Snapshot.Values)) do Include(Snapshot.Values[J]);
        for J := W.Viewport.FirstVisibleIndex to Min(W.Viewport.LastVisibleIndex, System.High(Snapshot.Secondary)) do Include(Snapshot.Secondary[J]);
        for J := W.Viewport.FirstVisibleIndex to Min(W.Viewport.LastVisibleIndex, System.High(Snapshot.Tertiary)) do Include(Snapshot.Tertiary[J]);
      end;
      if Low = MaxDouble then begin Low := 0; High := 1 end;
      if P.PanelType = nfptVolume then Low := 0;
      PL.PercentBase := 1;
      if (Length(W.Candles) > 0) and (P.PanelType = nfptPrice) then PL.PercentBase := W.Candles[W.Viewport.FirstVisibleIndex].Close;
      if P.ScaleMode = nfsmPercent then
      begin
        if Abs(PL.PercentBase) < 1E-12 then PL.PercentBase := 1;
        Low := (Low / PL.PercentBase - 1) * 100; High := (High / PL.PercentBase - 1) * 100;
      end;
      Padding := Max(1E-7, (High - Low) * P.ScalePaddingRatio);
      if High <= Low then Padding := Max(0.01, Abs(Low) * 0.01);
      PL.Minimum := Low - Padding; PL.Maximum := High + Padding;
      if P.PanelType = nfptVolume then PL.Minimum := 0;
      if P.ScaleMode = nfsmManual then begin PL.Minimum := P.ManualMinimumValue; PL.Maximum := Max(PL.Minimum + 1E-7, P.ManualMaximumValue) end;
      if P.ScaleMode = nfsmFixed then begin PL.Minimum := P.FixedMinimumValue; PL.Maximum := Max(PL.Minimum + 1E-7, P.FixedMaximumValue) end;
      if P.ScaleMode = nfsmLogarithmic then begin PL.Minimum := Max(1E-7, PL.Minimum); PL.Maximum := Max(PL.Minimum * 1.01, PL.Maximum) end;
      if P.PanelType = nfptPrice then Result.PricePlot := PL.Plot;
      PanelList.Add(PL); Cursor := PL.Separator.Bottom;
    end;
    Result.Panels := PanelList.ToArray; Result.SidePanels := SideList.ToArray;
    for I := 0 to System.High(Result.Panels) do
      if W.Options.AllowPanelLayoutChanges and W.Panels[Result.Panels[I].PanelIndex].AllowResize and
        (W.Panels[Result.Panels[I].PanelIndex].State = nfpsExpanded) then
        for J := I + 1 to System.High(Result.Panels) do
          if W.Panels[Result.Panels[J].PanelIndex].AllowResize and (W.Panels[Result.Panels[J].PanelIndex].State = nfpsExpanded) then
          begin Result.Panels[I].CanResize := True; Break end;
    PriceIndex := -1;
    for I := 0 to System.High(Result.Panels) do if W.Panels[Result.Panels[I].PanelIndex].PanelType = nfptPrice then begin PriceIndex := I; Break end;
    if PriceIndex >= 0 then for I := 0 to System.High(Result.Panels) do if W.Panels[Result.Panels[I].PanelIndex].ScaleMode = nfsmSharedPriceScale then
    begin Result.Panels[I].Minimum := Result.Panels[PriceIndex].Minimum; Result.Panels[I].Maximum := Result.Panels[PriceIndex].Maximum end;
  finally SideList.Free; PanelList.Free end;
end;

function TNimbusFinancialBusinessRenderer.CanRender(const AType: TNimbusChartType): Boolean;
begin Result := AType in [nctCandlestick, nctOhlc] end;

function TNimbusFinancialBusinessRenderer.Arrange(const C: TNimbusChartRenderContext): TNimbusChartLayout;
var Scene: TNimbusFinancialScene; PL: TNimbusFinancialPanelLayout;
begin
  Result := Default(TNimbusChartLayout); Scene := Layout(C); Result.Bounds := C.Bounds; Result.PlotArea := Scene.Graph;
  Result.XRange := TNimbusChartRange.Create(0, 1); Result.YRange := TNimbusChartRange.Create(0, 1);
  if C.Financial = nil then Exit;
  Result.XRange := TNimbusChartRange.Create(C.Financial.Viewport.FirstVisibleIndex, C.Financial.Viewport.FirstVisibleIndex + Max(1, C.Financial.Viewport.VisibleCount));
  for PL in Scene.Panels do if C.Financial.Panels[PL.PanelIndex].PanelType = nfptPrice then begin Result.YRange := TNimbusChartRange.Create(PL.Minimum, PL.Maximum); Break end;
end;

function TNimbusFinancialBusinessRenderer.Build(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>;
var W: TNimbusFinancialWorkspace; Palette: TNimbusFinancialPalette; Scene: TNimbusFinancialScene; B: TNimbusChartPrimitiveBuilder;
  PL: TNimbusFinancialPanelLayout; SL: TNimbusFinancialSidePanelLayout; Panel: TNimbusFinancialPanel;
  SidePanel: TNimbusFinancialSidePanel; Item: TNimbusFinancialPanelItem; Snapshot: TNimbusFinancialIndicatorSnapshot;
  Candle: TNimbusFinancialDataPoint; Marker: TNimbusFinancialMarker; Annotation: TNimbusFinancialAnnotation;
  Hit, Empty: TNimbusChartHit; I, J, K, Index, Cursor, First, Last, Size, ButtonX, ButtonWidth: Integer;
  R, R2, Row: TRect; DPI, X, Y, X2, Y2, Width, V, Ratio, StartAngle, Sweep, Total: Double;
  Col, Secondary: TThemeColor; Flags: TNimbusTextFlags; Title: string; Points: TArray<TPointF>;
  function Resolve(const Color: TColor; const Fallback: TThemeColor): TThemeColor;
  begin if Color = clNone then Result := Fallback else Result := ColorToThemeColor(Color) end;
  procedure Line(const Values: TNimbusFinancialValues; const Color: TThemeColor; const LineWidth: Double);
  var N, BeginIndex, EndIndex: Integer; Previous, Current: TPointF; HasPrevious: Boolean;
  begin
    HasPrevious := False; BeginIndex := W.Viewport.FirstVisibleIndex; EndIndex := Min(W.Viewport.LastVisibleIndex, High(Values));
    for N := BeginIndex to EndIndex do
    begin
      if not Finite(Values[N]) then begin HasPrevious := False; Continue end;
      Current := TPointF.Create(CandleX(W, PL.Plot, N), ValueY(Panel, PL, Values[N]));
      if HasPrevious then B.Line([Previous, Current], Color, LineWidth * DPI, Empty);
      Previous := Current; HasPrevious := True;
    end;
  end;
  function IndicatorColor(const S: TNimbusFinancialIndicatorSnapshot; const Signal: Boolean): TThemeColor;
  var Ordinal: Integer; Other: TNimbusFinancialIndicatorSnapshot;
  begin
    Ordinal := 0;
    for Other in W.Snapshots do
    begin if Other.Key = S.Key then Break; if (Other.Kind = S.Kind) and SameText(Other.PanelKey, S.PanelKey) then Inc(Ordinal) end;
    Result := Palette.Accent;
    case S.Kind of
      nfikSma: begin Result := Palette.SmaLine; if Ordinal = 1 then Result := Palette.SmaLineSecondary else if Ordinal >= 2 then Result := Palette.SmaLineTertiary end;
      nfikEma: begin Result := Palette.EmaLine; if Ordinal > 0 then Result := Palette.EmaLineSecondary end;
      nfikBollinger: if Signal then Result := Palette.BollingerLine else Result := Palette.BollingerMiddleLine;
      nfikRsi: begin Result := Palette.RsiLine; if Ordinal > 0 then Result := Palette.RsiLineSecondary end;
      nfikMacd: if Signal then Result := Palette.MacdSignalLine else Result := Palette.MacdLine;
      nfikStochastic: if Signal then Result := Palette.StochasticDLine else Result := Palette.StochasticKLine;
      nfikAtr: begin Result := Palette.AtrLine; if Ordinal > 0 then Result := Palette.AtrLineSecondary end;
      nfikVwap: Result := Palette.VwapLine;
      nfikVolume: Result := Palette.SmaLine;
    end;
    if Signal then Result := Resolve(S.SecondaryColor, Result) else Result := Resolve(S.Color, Result);
  end;
  procedure HeaderButton(const Bounds: TRect; const Text: string; const Area: TNimbusFinancialHitArea; const Enabled: Boolean);
  begin
    if not Enabled or Bounds.IsEmpty then Exit;
    if Bounds.Contains(W.CrosshairLocation) then B.Box(Bounds, Palette.Hover, Empty, 3 * DPI);
    B.Text(Text, Bounds, Palette.AxisText, FinancialHit(Area, PL.PanelIndex, -1, -1, Panel.Title), Flags + [ntfCenter]);
  end;
  function AnnotationIndex(const Time: TDateTime; const Index: Integer): Integer;
  begin if Annotation.CoordinateMode = nfcmTime then Result := W.FindCandleByTime(Time) else Result := Index end;
  procedure AnnotationLine(const A, Z: TPointF);
  var Distance, Position, Segment, Gap, Fraction1, Fraction2: Double;
  begin
    if Annotation.DashStyle = psClear then Exit;
    if Annotation.DashStyle = psSolid then begin B.Line([A, Z], Col, Annotation.LineWidth * DPI, Hit); Exit end;
    Distance := Hypot(Z.X - A.X, Z.Y - A.Y); if Distance <= 0 then Exit;
    Segment := 6 * DPI; if Annotation.DashStyle = psDot then Segment := DPI;
    Gap := 3 * DPI; Position := 0;
    while Position < Distance do
    begin
      Fraction1 := Position / Distance; Fraction2 := Min(Distance, Position + Segment) / Distance;
      B.Line([TPointF.Create(A.X + (Z.X - A.X) * Fraction1, A.Y + (Z.Y - A.Y) * Fraction1),
        TPointF.Create(A.X + (Z.X - A.X) * Fraction2, A.Y + (Z.Y - A.Y) * Fraction2)], Col, Annotation.LineWidth * DPI, Hit);
      Position := Position + Segment + Gap;
      if Annotation.DashStyle in [psDashDot, psDashDotDot] then
        for var DotIndex := 1 to 1 + Ord(Annotation.DashStyle = psDashDotDot) do
        begin
          Fraction1 := Position / Distance; Fraction2 := Min(Distance, Position + DPI) / Distance;
          if Position < Distance then B.Line([TPointF.Create(A.X + (Z.X - A.X) * Fraction1, A.Y + (Z.Y - A.Y) * Fraction1),
            TPointF.Create(A.X + (Z.X - A.X) * Fraction2, A.Y + (Z.Y - A.Y) * Fraction2)], Col, Annotation.LineWidth * DPI, Hit);
          Position := Position + DPI + Gap;
        end;
    end;
  end;
  procedure MiniChart(const Values: TArray<Double>; const Bounds: TRect; const Kind: TNimbusFinancialPanelItemKind; const Hit: TNimbusChartHit);
  var N, Count: Integer; MinV, MaxV, Sum, Angle, Part: Double; P: TArray<TPointF>; Box: TRect;
  begin
    Count := Length(Values); if (Count = 0) or Bounds.IsEmpty then Exit;
    MinV := 0; MaxV := 0; Sum := 0;
    for N := 0 to Count - 1 do if Finite(Values[N]) then begin MinV := Min(MinV, Values[N]); MaxV := Max(MaxV, Values[N]); Sum := Sum + Max(0.0, Values[N]) end;
    if Kind in [nfpiMiniPie, nfpiMiniDonut] then
    begin
      if Sum <= 0 then Exit; Angle := -90; Box := Bounds; Box.Right := Box.Left + Min(Box.Width, Box.Height); Box.Bottom := Box.Top + Box.Width;
      for N := 0 to Count - 1 do if Finite(Values[N]) and (Values[N] > 0) then
      begin
        Part := Values[N] / Sum * 360; Col := Palette.Accent; if Odd(N) then Col := Palette.Accent2;
        if Kind = nfpiMiniDonut then B.Sector(Box, Col, Angle, Part, Box.Width * 0.28, Hit) else B.Sector(Box, Col, Angle, Part, 0, Hit);
        Angle := Angle + Part;
      end;
      Exit;
    end;
    SetLength(P, Count);
    for N := 0 to Count - 1 do
    begin
      V := Values[N]; if not Finite(V) then V := MinV;
      P[N] := TPointF.Create(Bounds.Left + (N + 0.5) * Bounds.Width / Count, Bounds.Bottom - (V - MinV) / Max(1E-7, MaxV - MinV) * Bounds.Height);
      if Kind in [nfpiMiniBar, nfpiVolumeBar] then
      begin
        Box := Rect(Round(P[N].X), Round(P[N].Y), Round(P[N].X + Max(1.0, Bounds.Width / Count - 1)), Bounds.Bottom);
        B.Box(Box, Palette.Accent, Hit);
      end;
    end;
    if not (Kind in [nfpiMiniBar, nfpiVolumeBar]) then
    begin
      if Kind = nfpiMiniArea then
      begin
        SetLength(P, Count + 2); P[Count] := TPointF.Create(P[Count - 1].X, Bounds.Bottom); P[Count + 1] := TPointF.Create(P[0].X, Bounds.Bottom);
        B.Polygon(P, NimbusColorWithAlpha(Palette.Accent, 50), Hit); SetLength(P, Count);
      end;
      B.Line(P, Palette.Accent, Max(1.0, DPI), Hit);
    end;
  end;
begin
  Result := nil; W := C.Financial; if W = nil then Exit; Palette := W.Palette; Scene := Layout(C);
  DPI := Max(1, C.PPI) / 96; Flags := [ntfSingleLine, ntfVCenter, ntfEndEllipsis, ntfNoPrefix]; Empty := TNimbusChartHit.None;
  B := TNimbusChartPrimitiveBuilder.Create(C, L);
  try
    B.Box(C.Bounds, Palette.Background, Empty);
    R := Scene.Header; R.Bottom := R.Top + Round(22 * DPI);
    Title := C.Model.Title; if Title = '' then Title := W.Options.Symbol + ' ' + W.Options.Exchange;
    B.Text(Title, R, Palette.TitleText, Empty, Flags); R.Top := R.Bottom; R.Bottom := Scene.Header.Bottom;
    Index := W.SelectedIndex; if Index < 0 then Index := W.HoveredIndex; if Index < 0 then Index := W.Viewport.LastVisibleIndex;
    Title := C.Model.Subtitle;
    if (Index >= 0) and (Index < Length(W.Candles)) then
    begin Candle := W.Candles[Index]; Title := Format('%s  O %.2f  H %.2f  L %.2f  C %.2f  V %.0f', [FormatDateTime('dd mmm yyyy', Candle.Time), Candle.Open, Candle.High, Candle.Low, Candle.Close, Candle.Volume]) end;
    B.Text(Title, R, Palette.SubtitleText, Empty, Flags);
    First := W.Viewport.FirstVisibleIndex; Last := W.Viewport.LastVisibleIndex;
    for PL in Scene.Panels do
    begin
      Panel := W.Panels[PL.PanelIndex]; B.ClipBounds := TRect.Empty;
      B.Box(PL.Bounds, Palette.PanelBackground, Empty); B.Box(PL.Header, NimbusBlendColor(Palette.PanelBackground, Palette.Border, 32), FinancialHit(nfhaPanelHeader, PL.PanelIndex, -1, -1, Panel.Title));
      R := PL.HeaderText;
      B.Text(Panel.Title, R, Palette.TitleText, FinancialHit(nfhaPanelHeader, PL.PanelIndex, -1, -1, Panel.Title), Flags);
      Title := '-'; if Panel.State = nfpsCollapsed then Title := '+';
      HeaderButton(PL.CollapseButton, Title, nfhaPanelCollapse, Panel.AllowCollapse); HeaderButton(PL.CloseButton, 'x', nfhaPanelClose, Panel.AllowClose);
      HeaderButton(PL.PinButton, 'P', nfhaPanelPin, Panel.AllowPin); HeaderButton(PL.SettingsButton, '...', nfhaPanelSettings, Panel.AllowSettings);
      Hit := Empty; if PL.CanResize then Hit := FinancialHit(nfhaPanelSeparator, PL.PanelIndex, -1, -1);
      B.Box(PL.Separator, Palette.Border, Hit);
      if (Panel.State = nfpsCollapsed) or PL.Plot.IsEmpty then Continue;
      B.ClipBounds := PL.Plot;
      for I := 0 to 4 do
      begin
        V := PL.Minimum + (PL.Maximum - PL.Minimum) * I / 4; Y := PL.Plot.Bottom - PL.Plot.Height * I / 4;
        if W.Options.ShowGrid and Panel.ShowGrid then B.Line([TPointF.Create(PL.Plot.Left, Y), TPointF.Create(PL.Plot.Right, Y)], Palette.GridMajor, DPI, Empty);
      end;
      for I := First to Last do
      begin
        X := CandleX(W, PL.Plot, I); Candle := W.Candles[I];
        if (W.SelectedIndex = I) or (W.HoveredIndex = I) or ((W.RangeStartIndex >= 0) and (I >= W.RangeStartIndex) and (I <= W.RangeEndIndex)) then
        begin
          Col := Palette.Hover; if (W.SelectedIndex = I) or (W.RangeStartIndex >= 0) then Col := Palette.Selection;
          Width := PL.Plot.Width / Max(1, W.Viewport.VisibleCount);
          B.Box(Rect(Round(X - Width / 2), PL.Plot.Top, Round(X + Width / 2), PL.Plot.Bottom), Col, Empty);
        end;
        if Panel.PanelType <> nfptPrice then Continue;
        Hit := FinancialHit(nfhaCandle, PL.PanelIndex, I, -1, FormatDateTime('yyyy-mm-dd hh:nn', Candle.Time) +
          Format('  O %.2f  H %.2f  L %.2f  C %.2f  V %.0f', [Candle.Open, Candle.High, Candle.Low, Candle.Close, Candle.Volume]));
        Hit.XValue := Candle.XValue; Hit.YValue := Candle.Close;
        Col := Palette.BullishCandle; if Candle.Close < Candle.Open then Col := Palette.BearishCandle else if Candle.Close = Candle.Open then Col := Palette.DojiCandle;
        Width := FinancialBodyWidth(W, PL.Plot, 0.82);
        if W.Options.PriceMode in [nfpmCandlestick, nfpmOhlc] then
        begin
          B.Line([TPointF.Create(X, ValueY(Panel, PL, Candle.High)), TPointF.Create(X, ValueY(Panel, PL, Candle.Low))], Col, DPI, Hit);
          Y := ValueY(Panel, PL, Candle.Open); Y2 := ValueY(Panel, PL, Candle.Close);
          if W.Options.PriceMode = nfpmCandlestick then B.Box(Rect(Round(X - Width / 2), Round(Min(Y, Y2)), Round(X + Width / 2), Round(Min(Y, Y2) + Max(Max(1.0, DPI), Abs(Y2 - Y)))), Col, Hit)
          else begin B.Line([TPointF.Create(X - Width / 2, Y), TPointF.Create(X, Y)], Col, DPI, Hit); B.Line([TPointF.Create(X, Y2), TPointF.Create(X + Width / 2, Y2)], Col, DPI, Hit) end;
        end
        else if I > First then
        begin
          X2 := CandleX(W, PL.Plot, I - 1); Y := ValueY(Panel, PL, W.Candles[I - 1].Close); Y2 := ValueY(Panel, PL, Candle.Close);
          if W.Options.PriceMode = nfpmArea then B.Polygon([TPointF.Create(X2, PL.Plot.Bottom), TPointF.Create(X2, Y), TPointF.Create(X, Y2), TPointF.Create(X, PL.Plot.Bottom)], NimbusColorWithAlpha(Palette.Accent, 45), Hit);
          B.Line([TPointF.Create(X2, Y), TPointF.Create(X, Y2)], Palette.Accent, 1.7 * DPI, Hit);
        end;
      end;
      for K := 0 to High(W.Snapshots) do
      begin
        Snapshot := W.Snapshots[K]; if not SameText(Snapshot.PanelKey, Panel.Key) then Continue;
        Col := IndicatorColor(Snapshot, False); Secondary := IndicatorColor(Snapshot, True);
        if Snapshot.Kind in [nfikRsi, nfikStochastic] then
        begin
          V := W.Options.RsiOversoldLevel; Ratio := W.Options.RsiOverboughtLevel;
          Col := Palette.RsiOversoldFill; Secondary := Palette.RsiOverboughtFill;
          if Snapshot.Kind = nfikStochastic then
          begin V := W.Options.StochasticOversoldLevel; Ratio := W.Options.StochasticOverboughtLevel; Col := Palette.StochasticOversoldFill; Secondary := Palette.StochasticOverboughtFill end;
          if Snapshot.DefinitionIndex >= 0 then
          begin V := W.Indicators[Snapshot.DefinitionIndex].OversoldLevel; Ratio := W.Indicators[Snapshot.DefinitionIndex].OverboughtLevel end;
          Y := ValueY(Panel, PL, V); Y2 := ValueY(Panel, PL, Ratio);
          B.Box(Rect(PL.Plot.Left, PL.Plot.Top, PL.Plot.Right, Round(Y2)), NimbusColorWithAlpha(Secondary, 28), Empty);
          B.Box(Rect(PL.Plot.Left, Round(Y), PL.Plot.Right, PL.Plot.Bottom), NimbusColorWithAlpha(Col, 28), Empty);
          Col := IndicatorColor(Snapshot, False); Secondary := IndicatorColor(Snapshot, True);
        end;
        if Snapshot.Kind in [nfikVolume, nfikMacd] then for I := First to Last do
        begin
          V := NaN;
          if (Snapshot.Kind = nfikVolume) and (I < Length(Snapshot.Values)) then V := Snapshot.Values[I]
          else if I < Length(Snapshot.Tertiary) then V := Snapshot.Tertiary[I];
          if not Finite(V) then Continue;
          X := CandleX(W, PL.Plot, I); Width := FinancialBodyWidth(W, PL.Plot, 0.78);
          Y := ValueY(Panel, PL, V); Y2 := ValueY(Panel, PL, 0);
          Col := Palette.VolumeBullish; if W.Candles[I].Close < W.Candles[I].Open then Col := Palette.VolumeBearish;
          if Snapshot.Kind = nfikMacd then begin Col := Palette.MacdHistogramPositive; if V < 0 then Col := Palette.MacdHistogramNegative end;
          B.Box(Rect(Round(X - Width / 2), Round(Min(Y, Y2)), Round(X + Width / 2), Round(Max(Y, Y2))), Col, FinancialHit(nfhaCandle, PL.PanelIndex, I, K));
        end;
        if Snapshot.Kind = nfikBollinger then
          for I := First + 1 to Min(Last, High(Snapshot.Secondary)) do
            if Finite(Snapshot.Secondary[I - 1]) and Finite(Snapshot.Secondary[I]) and Finite(Snapshot.Tertiary[I - 1]) and Finite(Snapshot.Tertiary[I]) then
              B.Polygon([TPointF.Create(CandleX(W, PL.Plot, I - 1), ValueY(Panel, PL, Snapshot.Secondary[I - 1])), TPointF.Create(CandleX(W, PL.Plot, I), ValueY(Panel, PL, Snapshot.Secondary[I])),
                TPointF.Create(CandleX(W, PL.Plot, I), ValueY(Panel, PL, Snapshot.Tertiary[I])), TPointF.Create(CandleX(W, PL.Plot, I - 1), ValueY(Panel, PL, Snapshot.Tertiary[I - 1]))], Palette.BollingerFill, Empty);
        if Snapshot.Kind <> nfikVolume then Line(Snapshot.Values, IndicatorColor(Snapshot, False), 1.4);
        Line(Snapshot.Secondary, Secondary, 1.2);
        if Snapshot.Kind = nfikBollinger then Line(Snapshot.Tertiary, Secondary, 1.2);
        if Snapshot.Kind in [nfikRsi, nfikStochastic] then
        begin
          V := W.Options.RsiOversoldLevel; Ratio := W.Options.RsiOverboughtLevel;
          if Snapshot.Kind = nfikStochastic then begin V := W.Options.StochasticOversoldLevel; Ratio := W.Options.StochasticOverboughtLevel end;
          Y := ValueY(Panel, PL, V); Y2 := ValueY(Panel, PL, Ratio);
          Col := Palette.RsiOversoldLine; Secondary := Palette.RsiOverboughtLine;
          if Snapshot.Kind = nfikStochastic then begin Col := Palette.StochasticOversoldLine; Secondary := Palette.StochasticOverboughtLine end;
          B.Line([TPointF.Create(PL.Plot.Left, Y), TPointF.Create(PL.Plot.Right, Y)], Col, DPI, Empty);
          B.Line([TPointF.Create(PL.Plot.Left, Y2), TPointF.Create(PL.Plot.Right, Y2)], Secondary, DPI, Empty);
          Y := ValueY(Panel, PL, 50);
          B.Line([TPointF.Create(PL.Plot.Left, Y), TPointF.Create(PL.Plot.Right, Y)], Palette.GridZero, DPI, Empty);
        end;
      end;
      if Panel.PanelType = nfptPrice then
      begin
        for I := 0 to W.Markers.Count - 1 do
        begin
          Marker := W.Markers[I]; if not Marker.Visible then Continue; Index := Marker.CandleIndex;
          if Index < 0 then Index := W.FindCandleByTime(Marker.Time);
          if (Index < First) or (Index > Last) then Continue;
          Candle := W.Candles[Index]; V := Candle.High;
          case Marker.Anchor of
            nfmaBelowCandle, nfmaOnLow: V := Candle.Low;
            nfmaCenterOnCandle: V := (Candle.Open + Candle.Close) / 2;
            nfmaAbsoluteValue: V := Marker.Value;
          end;
          if Marker.UseValue then V := Marker.Value;
          X := CandleX(W, PL.Plot, Index); Y := ValueY(Panel, PL, V);
          if Marker.Anchor = nfmaAboveCandle then Y := Y - 10 * DPI;
          if Marker.Anchor = nfmaBelowCandle then Y := Y + 10 * DPI;
          Hit := FinancialHit(nfhaMarker, PL.PanelIndex, Index, I, Marker.Text + ' ' + Marker.Description);
          Col := Resolve(Marker.Color, Palette.Accent2); Size := Round(5 * DPI); R := Rect(Round(X) - Size, Round(Y) - Size, Round(X) + Size, Round(Y) + Size);
          case Marker.Style of
            nfmsCircle: B.Ellipse(R, Col, Hit);
            nfmsDiamond: B.Polygon([TPointF.Create(X, Y - Size), TPointF.Create(X + Size, Y), TPointF.Create(X, Y + Size), TPointF.Create(X - Size, Y)], Col, Hit);
            nfmsTriangleUp: B.Polygon([TPointF.Create(X, Y - Size), TPointF.Create(X + Size, Y + Size), TPointF.Create(X - Size, Y + Size)], Col, Hit);
            nfmsTriangleDown: B.Polygon([TPointF.Create(X, Y + Size), TPointF.Create(X + Size, Y - Size), TPointF.Create(X - Size, Y - Size)], Col, Hit);
            nfmsVerticalLine: B.Line([TPointF.Create(X, PL.Plot.Top), TPointF.Create(X, PL.Plot.Bottom)], Col, DPI, Hit);
            nfmsFlag, nfmsLabel: begin R.Right := R.Left + Round(100 * DPI); B.Box(R, Col, Hit, 2 * DPI); B.Text(Marker.Text, R, Palette.TitleText, Hit, Flags) end;
          end;
        end;
        if W.Options.ShowAnnotations then for I := 0 to W.Annotations.Count - 1 do
        begin
          Annotation := W.Annotations[I]; if not Annotation.Visible then Continue;
          Index := AnnotationIndex(Annotation.StartTime, Annotation.StartIndex); J := AnnotationIndex(Annotation.EndTime, Annotation.EndIndex);
          X := CandleX(W, PL.Plot, Index); X2 := CandleX(W, PL.Plot, J);
          Y := ValueY(Panel, PL, Annotation.StartValue); Y2 := ValueY(Panel, PL, Annotation.EndValue);
          Hit := Empty; if Annotation.Selectable then Hit := FinancialHit(nfhaAnnotation, PL.PanelIndex, Index, I, Annotation.Text + ' ' + Annotation.Description);
          Col := Resolve(Annotation.LineColor, Palette.AnnotationLine); Secondary := Resolve(Annotation.FillColor, Palette.AnnotationFill);
          R := Rect(Round(Min(X, X2)), Round(Min(Y, Y2)), Round(Max(X, X2)), Round(Max(Y, Y2)));
          case Annotation.Kind of
            nfakHorizontalLine: AnnotationLine(TPointF.Create(PL.Plot.Left, Y), TPointF.Create(PL.Plot.Right, Y));
            nfakVerticalLine: AnnotationLine(TPointF.Create(X, PL.Plot.Top), TPointF.Create(X, PL.Plot.Bottom));
            nfakTrendLine, nfakArrow, nfakChannel:
              begin
                AnnotationLine(TPointF.Create(X, Y), TPointF.Create(X2, Y2));
                if Annotation.Kind = nfakArrow then
                begin
                  Ratio := ArcTan2(Y2 - Y, X2 - X);
                  B.Polygon([TPointF.Create(X2, Y2), TPointF.Create(X2 - Cos(Ratio) * 9 * DPI + Sin(Ratio) * 5 * DPI, Y2 - Sin(Ratio) * 9 * DPI - Cos(Ratio) * 5 * DPI),
                    TPointF.Create(X2 - Cos(Ratio) * 9 * DPI - Sin(Ratio) * 5 * DPI, Y2 - Sin(Ratio) * 9 * DPI + Cos(Ratio) * 5 * DPI)], Col, Hit);
                end;
                if Annotation.Kind = nfakChannel then
                begin
                  V := Max(18 * DPI, Abs(Y2 - Y) * 0.45);
                  B.Polygon([TPointF.Create(X, Y), TPointF.Create(X2, Y2), TPointF.Create(X2, Y2 + V), TPointF.Create(X, Y + V)], Secondary, Hit);
                  AnnotationLine(TPointF.Create(X, Y), TPointF.Create(X2, Y2));
                  AnnotationLine(TPointF.Create(X, Y + V), TPointF.Create(X2, Y2 + V));
                end;
              end;
            nfakRectangle, nfakPriceRange:
              begin
                if Annotation.Kind = nfakPriceRange then begin R.Left := PL.Plot.Left; R.Right := PL.Plot.Right; Secondary := Resolve(Annotation.FillColor, Palette.AnnotationPriceRangeFill) end;
                B.Box(R, Secondary, Hit); B.Box(R, Col, Hit, 0, True);
              end;
            nfakTextLabel: B.Text(Annotation.Text, Rect(Round(X), Round(Y), Round(X + 180 * DPI), Round(Y + 22 * DPI)), Resolve(Annotation.TextColor, Palette.AnnotationText), Hit, Flags);
          end;
          if (Annotation.Kind <> nfakTextLabel) and (Annotation.Text <> '') then
            B.Text(Annotation.Text, Rect(Round(Max(PL.Plot.Left + 4 * DPI, Min(X, X2))), Round(Min(Y, Y2) - 18 * DPI), PL.Plot.Right, Round(Min(Y, Y2))), Resolve(Annotation.TextColor, Palette.AnnotationText), Hit, Flags);
        end;
      end;
      if W.CrosshairVisible and W.Options.ShowCrosshair and (W.Options.ShowCrosshairWhileSelectionLocked or (W.SelectedIndex < 0)) then
      begin
        X := W.CrosshairLocation.X; Y := W.CrosshairLocation.Y;
        if W.HoveredIndex >= 0 then X := CandleX(W, PL.Plot, W.HoveredIndex);
        if (X >= PL.Plot.Left) and (X <= PL.Plot.Right) then B.Line([TPointF.Create(X, PL.Plot.Top), TPointF.Create(X, PL.Plot.Bottom)], NimbusColorWithAlpha(Palette.Crosshair, 150), DPI, Empty);
        if (Y >= PL.Plot.Top) and (Y <= PL.Plot.Bottom) then B.Line([TPointF.Create(PL.Plot.Left, Y), TPointF.Create(PL.Plot.Right, Y)], NimbusColorWithAlpha(Palette.Crosshair, 150), DPI, Empty);
      end;
      B.ClipBounds := TRect.Empty;
      if W.Options.ShowAxes and Panel.ShowYAxis and not PL.Axis.IsEmpty then for I := 0 to 4 do
      begin
        Y := PL.Plot.Bottom - PL.Plot.Height * I / 4; V := PL.Minimum + (PL.Maximum - PL.Minimum) * I / 4;
        if Panel.ScaleMode = nfsmLogarithmic then V := Exp(Ln(PL.Minimum) + (Ln(PL.Maximum) - Ln(PL.Minimum)) * I / 4);
        Title := FormatFloat(Panel.ValueFormat, V); if Panel.ScaleMode = nfsmPercent then Title := Title + '%';
        B.Text(Title, Rect(PL.Axis.Left + Round(4 * DPI), Round(Y - 9 * DPI), PL.Axis.Right - Round(2 * DPI), Round(Y + 9 * DPI)), Palette.AxisText, FinancialHit(nfhaPriceAxis, PL.PanelIndex, -1, -1), Flags + [ntfRight]);
      end;
      if W.CrosshairVisible and W.Options.ShowCrosshair and not PL.Axis.IsEmpty and
        (W.Options.ShowCrosshairWhileSelectionLocked or (W.SelectedIndex < 0)) and
        (W.CrosshairLocation.Y >= PL.Plot.Top) and (W.CrosshairLocation.Y <= PL.Plot.Bottom) then
      begin
        Y := W.CrosshairLocation.Y; R := Rect(PL.Axis.Left, Round(Y - 10 * DPI), PL.Axis.Right, Round(Y + 10 * DPI));
        B.Box(R, Palette.CrosshairLabelBackground, Empty);
        Title := FormatFloat(Panel.ValueFormat, YValue(Panel, PL, Y));
        B.Text(Title, R, Palette.CrosshairLabelText, Empty, Flags + [ntfCenter]);
      end;
      if W.Options.ShowLegend then
      begin
        ButtonX := PL.Header.Left + Round(85 * DPI);
        for K := 0 to High(W.Snapshots) do if SameText(W.Snapshots[K].PanelKey, Panel.Key) then
        begin
          Snapshot := W.Snapshots[K]; ButtonWidth := Round(98 * DPI);
          if ButtonX + ButtonWidth > PL.HeaderText.Right then Break;
          Title := Snapshot.Title; Index := W.SelectedIndex; if Index < 0 then Index := W.HoveredIndex; if Index < 0 then Index := Last;
          if (Index >= 0) and (Index < Length(Snapshot.Values)) and Finite(Snapshot.Values[Index]) then Title := Title + ' ' + FormatFloat('0.00', Snapshot.Values[Index]);
          R := Rect(ButtonX, PL.Header.Top, ButtonX + ButtonWidth, PL.Header.Bottom);
          B.Text(Title, R, IndicatorColor(Snapshot, False), FinancialHit(nfhaLegend, PL.PanelIndex, -1, K, Snapshot.Title), Flags); Inc(ButtonX, ButtonWidth);
        end;
      end;
    end;
    if W.Options.ShowAxes and not Scene.PricePlot.IsEmpty then
      for I := First to Last do if ((I - First) mod Max(1, Ceil(Max(1, W.Viewport.ActualVisibleCount) / 8)) = 0) or (I = Last) then
      begin
        X := CandleX(W, Scene.PricePlot, I); R := Rect(Round(X - 40 * DPI), Scene.TimeAxis.Top, Round(X + 40 * DPI), Scene.TimeAxis.Bottom);
        Title := 'dd mmm'; if W.Options.TimeFrame <= nftfHour4 then Title := 'hh:nn' else if W.Options.TimeFrame >= nftfWeek1 then Title := 'mmm yyyy';
        B.Text(FormatDateTime(Title, W.Candles[I].Time), R, Palette.AxisText, FinancialHit(nfhaTimeAxis, -1, I, -1), Flags + [ntfCenter]);
      end;
    if W.CrosshairVisible and W.Options.ShowCrosshair and (W.HoveredIndex >= First) and (W.HoveredIndex <= Last) and
      (W.Options.ShowCrosshairWhileSelectionLocked or (W.SelectedIndex < 0)) then
    begin
      X := CandleX(W, Scene.PricePlot, W.HoveredIndex);
      R := Rect(Round(X - 68 * DPI), Scene.TimeAxis.Top, Round(X + 68 * DPI), Scene.TimeAxis.Bottom);
      B.Box(R, Palette.CrosshairLabelBackground, Empty);
      B.Text(FormatDateTime('dd mmm yyyy hh:nn', W.Candles[W.HoveredIndex].Time), R, Palette.CrosshairLabelText, Empty, Flags + [ntfCenter]);
    end;
    if W.RangeSelector.Visible then
    begin
      ButtonX := Scene.RangeSelector.Left; ButtonWidth := Max(Round(W.RangeSelector.ButtonMinWidth * DPI), Scene.RangeSelector.Width div Max(1, W.RangeSelector.Items.Count));
      for I := 0 to W.RangeSelector.Items.Count - 1 do
      begin
        if not W.RangeSelector.Items[I].Visible then Continue;
        R := Rect(ButtonX, Scene.RangeSelector.Top + Round(3 * DPI), Min(Scene.RangeSelector.Right, ButtonX + ButtonWidth - Round(W.RangeSelector.ButtonSpacing * DPI)), Scene.RangeSelector.Bottom - Round(3 * DPI));
        Hit := FinancialHit(nfhaRangeButton, -1, -1, I, W.RangeSelector.Items[I].Text);
        Col := Palette.PanelBackground; if W.RangeSelector.Items[I].Selected then Col := NimbusBlendColor(Col, Palette.Accent, 90);
        B.Box(R, Col, Hit, 3 * DPI); B.Text(W.RangeSelector.Items[I].Text, R, Palette.AxisText, Hit, Flags + [ntfCenter]); Inc(ButtonX, ButtonWidth);
      end;
    end;
    if W.DragPanelIndex >= 0 then
    begin
      B.ClipBounds := Scene.Graph;
      for PL in Scene.Panels do
      begin
        if W.Options.ShowPanelDropZones and (PL.PanelIndex = W.DropPanelIndex) then
          B.Box(Rect(PL.Bounds.Left, PL.Bounds.Top, PL.Bounds.Right, PL.Bounds.Top + Round(4 * DPI)), Palette.Accent, Empty);
        if W.Options.ShowPanelDragAdorner and (PL.PanelIndex = W.DragPanelIndex) then
        begin
          R := PL.Header; R.Offset(0, W.DragOffsetY); R.Bottom := R.Top + Round(26 * DPI);
          B.Box(R, NimbusColorWithAlpha(Palette.CrosshairLabelBackground, 220), Empty, 3 * DPI);
          B.Text(W.Panels[PL.PanelIndex].Title, R, Palette.CrosshairLabelText, Empty, Flags);
        end;
      end;
    end;
    for SL in Scene.SidePanels do
    begin
      SidePanel := W.SidePanels[SL.PanelIndex]; B.ClipBounds := TRect.Empty;
      B.Box(SL.Bounds, Palette.PanelBackground, Empty); B.Box(SL.Header, NimbusBlendColor(Palette.PanelBackground, Palette.Border, 45), FinancialHit(nfhaSidePanelHeader, SL.PanelIndex, -1, -1));
      R := SL.Header; R.Right := SL.PinButton.Left; Inc(R.Left, Round(6 * DPI));
      B.Text(SidePanel.Title, R, Palette.TitleText, FinancialHit(nfhaSidePanelHeader, SL.PanelIndex, -1, -1), Flags);
      Title := '-'; if SidePanel.State <> nfspsExpanded then Title := '+';
      B.Text(Title, SL.CollapseButton, Palette.AxisText, FinancialHit(nfhaSidePanelCollapse, SL.PanelIndex, -1, -1), Flags + [ntfCenter]);
      B.Text('P', SL.PinButton, Palette.AxisText, FinancialHit(nfhaSidePanelPin, SL.PanelIndex, -1, -1), Flags + [ntfCenter]);
      if SidePanel.Resizable then
      begin
        B.Box(SL.Splitter, Palette.Border, FinancialHit(nfhaSidePanelSplitter, SL.PanelIndex, -1, -1));
        B.Box(SL.HeightSplitter, Palette.Border, FinancialHit(nfhaSidePanelSeparator, SL.PanelIndex, -1, -1));
      end;
      if (SidePanel.State <> nfspsExpanded) or SL.Body.IsEmpty then Continue;
      B.ClipBounds := SL.Body; Cursor := SL.Body.Top - Min(SidePanel.ScrollOffset, Max(0, SL.ContentHeight - SL.Body.Height));
      for I := 0 to SidePanel.Items.Count - 1 do
      begin
        Item := SidePanel.Items[I]; if not Item.Visible then Continue;
        Row := Rect(SL.Body.Left + Round(6 * DPI), Cursor, SL.Body.Right - Round(20 * DPI), Cursor + Round(Item.Height * DPI)); Cursor := Row.Bottom;
        if (Row.Bottom < SL.Body.Top) or (Row.Top > SL.Body.Bottom) then Continue;
        Hit := FinancialHit(nfhaSidePanelItem, SL.PanelIndex, I, -1, Item.Text + ' ' + Item.Value);
        if Item.Kind = nfpiSeparator then begin B.Line([TPointF.Create(Row.Left, Row.CenterPoint.Y), TPointF.Create(Row.Right, Row.CenterPoint.Y)], Palette.Border, DPI, Empty); Continue end;
        Col := Palette.PanelBackground; if Row.Contains(W.CrosshairLocation) and SL.Body.Contains(W.CrosshairLocation) then Col := Palette.Hover;
        B.Box(Row, Col, Hit);
        if (((W.FocusedSidePanelKey <> '') and SameText(W.FocusedSidePanelKey, SidePanel.Key)) or
          ((W.FocusedSidePanelKey = '') and (W.FocusedSidePanelIndex = SL.PanelIndex))) and
          (((W.FocusedRowKey <> '') and SameText(W.FocusedRowKey, Item.Key)) or ((W.FocusedRowKey = '') and (W.FocusedRowIndex = I))) then
          B.Box(Row, Palette.Accent, Hit, 2 * DPI, True);
        R := Row; R.Right := Row.Left + Row.Width div 2;
        B.Text(Item.Text, R, Palette.SubtitleText, Hit, Flags);
        R.Left := R.Right; R.Right := Row.Right; Col := Palette.TitleText;
        if Item.ChangeValue > 0 then Col := Palette.PositiveText else if Item.ChangeValue < 0 then Col := Palette.NegativeText;
        B.Text(Item.Value, R, Col, Hit, Flags + [ntfRight]);
        if Item.Kind in [nfpiSparkline, nfpiMiniLine, nfpiMiniArea, nfpiMiniBar, nfpiMiniPie, nfpiMiniDonut, nfpiVolumeBar] then
        begin
          R := Row; R.Top := R.Top + Round(18 * DPI); R.Inflate(-Round(2 * DPI), -Round(2 * DPI));
          if Item.Kind = nfpiVolumeBar then MiniChart([Item.NumericValue, Max(0.0, 1 - Item.NumericValue)], R, nfpiMiniBar, Hit)
          else MiniChart(Item.Values, R, Item.Kind, Hit);
        end;
      end;
    end;
    B.ClipBounds := TRect.Empty; Result := B.Finish;
    for I := 0 to High(Result) do Result[I].SuppressHighlight := True;
  finally B.Free end;
end;

function TNimbusFinancialBusinessRenderer.HitTest(const C: TNimbusChartRenderContext; const Location: TPointF): TNimbusChartHit;
var Scene: TNimbusFinancialScene; PL: TNimbusFinancialPanelLayout; SL: TNimbusFinancialSidePanelLayout;
  W: TNimbusFinancialWorkspace; Index, I, J: Integer; P: TPoint; Hit: TNimbusChartHit;
  function StructuralHit(const Area: TNimbusFinancialHitArea; const PanelIndex: Integer; const Bounds: TRect): Boolean;
  begin
    Result := not Bounds.IsEmpty and Bounds.Contains(P);
    if Result then begin Hit := FinancialHit(Area, PanelIndex, -1, -1); Hit.Location := Location end;
  end;
begin
  Result := TNimbusChartHit.None; W := C.Financial; if W = nil then Exit;
  Scene := Layout(C); P := Point(Round(Location.X), Round(Location.Y));
  for I := 0 to High(Scene.Panels) do
  begin
    PL := Scene.Panels[I];
    if W.Options.AllowPanelLayoutChanges and W.Panels[PL.PanelIndex].AllowResize and
      (W.Panels[PL.PanelIndex].State = nfpsExpanded) and PL.Separator.Contains(P) then
      for J := I + 1 to High(Scene.Panels) do
        if W.Panels[Scene.Panels[J].PanelIndex].AllowResize and (W.Panels[Scene.Panels[J].PanelIndex].State = nfpsExpanded) then
        begin StructuralHit(nfhaPanelSeparator, PL.PanelIndex, PL.Separator); Exit(Hit) end;
    if StructuralHit(nfhaPanelSettings, PL.PanelIndex, PL.SettingsButton) or StructuralHit(nfhaPanelPin, PL.PanelIndex, PL.PinButton) or
      StructuralHit(nfhaPanelCollapse, PL.PanelIndex, PL.CollapseButton) or StructuralHit(nfhaPanelClose, PL.PanelIndex, PL.CloseButton) then Exit(Hit);
  end;
  for SL in Scene.SidePanels do
  begin
    if W.SidePanels[SL.PanelIndex].Resizable and (StructuralHit(nfhaSidePanelSplitter, SL.PanelIndex, SL.Splitter) or
      StructuralHit(nfhaSidePanelSeparator, SL.PanelIndex, SL.HeightSplitter)) then Exit(Hit);
    if StructuralHit(nfhaSidePanelCollapse, SL.PanelIndex, SL.CollapseButton) or StructuralHit(nfhaSidePanelPin, SL.PanelIndex, SL.PinButton) then Exit(Hit);
  end;
  Result := inherited HitTest(C, Location);
  if Result.FinancialArea <> nfhaNone then Exit;
  for PL in Scene.Panels do if PL.Plot.Contains(Point(Round(Location.X), Round(Location.Y))) and (W.Viewport.ActualVisibleCount > 0) then
  begin
    Index := EnsureRange(W.Viewport.FirstVisibleIndex + Floor((Location.X - PL.Plot.Left) * W.Viewport.VisibleCount / Max(1, PL.Plot.Width)), W.Viewport.FirstVisibleIndex, W.Viewport.LastVisibleIndex);
    Result := FinancialHit(nfhaCandle, PL.PanelIndex, Index, -1, FormatDateTime('yyyy-mm-dd hh:nn', W.Candles[Index].Time) +
      Format(' O %.2f H %.2f L %.2f C %.2f V %.0f', [W.Candles[Index].Open, W.Candles[Index].High, W.Candles[Index].Low, W.Candles[Index].Close, W.Candles[Index].Volume]));
    Result.Location := Location; Result.XValue := W.Candles[Index].XValue; Result.YValue := W.Candles[Index].Close; Exit;
  end;
end;

end.

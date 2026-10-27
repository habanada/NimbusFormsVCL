{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.Charts;

interface

uses
  Winapi.Windows, System.Classes, System.Types, System.UITypes, System.SysUtils, System.Math, System.Generics.Collections,
  Vcl.Graphics, NimbusForms.Rendering.Canvas, NimbusForms.Rendering.Types,
  NimbusForms.Theming.Types, NimbusForms.Theming.Palette,
  NimbusForms.Charts.Types, NimbusForms.Charts.Sparkline.Types, NimbusForms.Charts.Financial.Workspace;

type
  TNimbusChartHitArea = (nchaNone, nchaPlotArea, nchaPoint, nchaSegment, nchaSeries, nchaLegend, nchaTitle, nchaReferenceLine, nchaReferenceRange, nchaAnnotation);
  TNimbusChartHit = record
    Area: TNimbusChartHitArea;
    FinancialArea: TNimbusFinancialHitArea;
    SeriesIndex, PointIndex, ElementIndex: Integer;
    Location: TPointF;
    XValue, YValue: Double;
    Text: string;
    class function None: TNimbusChartHit; static;
    function SameElement(const AOther: TNimbusChartHit): Boolean;
  end;

  TNimbusChartRenderContext = record
    Model: TNimbusChartModel;
    Financial: TNimbusFinancialWorkspace;
    Palette: TThemePalette;
    ChartPalette: TNimbusChartPalette;
    Font: TFont;
    Bounds: TRect;
    PPI: Integer;
    Enabled: Boolean;
    Hovered, Selected: TNimbusChartHit;
    XView, YView: TNimbusChartRange;
    AnimationProgress: Double;
    MeasureCanvas: INimbusRenderCanvas;
    ColorInfluence: Integer;
    ShowGlow: Boolean;
  end;

  TNimbusChartLayout = record
    Bounds, PlotArea, TitleBounds, SubtitleBounds, LegendBounds, XAxisBounds, YAxisBounds, SecondaryYAxisBounds: TRect;
    XRange, YRange, SecondaryYRange: TNimbusChartRange;
  end;

  TNimbusChartPrimitiveKind = (ncpLine, ncpRect, ncpEllipse, ncpSector, ncpPolygon, ncpText, ncpArc, ncpHitBounds, ncpOutlineRect, ncpOutlineEllipse, ncpHitArc);
  TNimbusChartPrimitive = record
    Kind: TNimbusChartPrimitiveKind;
    Bounds: TRect;
    Points: TArray<TPointF>;
    Color: TThemeColor;
    Width, StartAngle, SweepAngle, InnerRadius, CornerRadius: Single;
    UseCornerRadius, UseFont, UseClip, SuppressHighlight: Boolean;
    FontHeight: Integer;
    FontStyle: TFontStyles;
    ClipBounds: TRect;
    Hit: TNimbusChartHit;
    Text: string;
    TextFlags: TNimbusTextFlags;
  end;

  INimbusChartRenderer = interface
    ['{54997424-D54B-40DA-A551-9D6317282010}']
    function CanRender(const AType: TNimbusChartType): Boolean;
    function Arrange(const C: TNimbusChartRenderContext): TNimbusChartLayout;
    procedure Render(const Canvas: INimbusRenderCanvas; const C: TNimbusChartRenderContext);
    function HitTest(const C: TNimbusChartRenderContext; const Location: TPointF): TNimbusChartHit;
    function ExportSvg(const C: TNimbusChartRenderContext): string;
  end;

  INimbusChartSeriesNavigator = interface
    ['{25B618FD-348C-49F6-9C7A-1CC8AC6D82BC}']
    function FindSeriesHit(const C: TNimbusChartRenderContext; const SeriesIndex: Integer): TNimbusChartHit;
  end;

  INimbusChartElementNavigator = interface
    ['{C56E4A6B-1C8C-465B-9E87-C48BCC79AA69}']
    function FindAdjacentHit(const C: TNimbusChartRenderContext; const Current: TNimbusChartHit; const Direction: Integer): TNimbusChartHit;
  end;

  TNimbusChartRenderer = class(TInterfacedObject, INimbusChartRenderer, INimbusChartSeriesNavigator, INimbusChartElementNavigator)
  protected
    function BuildStyled(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>;
    function Build(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>; virtual;
    function BuildKpi(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>;
  public
    function CanRender(const AType: TNimbusChartType): Boolean; virtual;
    function FindSeriesHit(const C: TNimbusChartRenderContext; const SeriesIndex: Integer): TNimbusChartHit;
    function FindAdjacentHit(const C: TNimbusChartRenderContext; const Current: TNimbusChartHit; const Direction: Integer): TNimbusChartHit;
    function Arrange(const C: TNimbusChartRenderContext): TNimbusChartLayout; virtual;
    procedure Render(const Canvas: INimbusRenderCanvas; const C: TNimbusChartRenderContext);
    function HitTest(const C: TNimbusChartRenderContext; const Location: TPointF): TNimbusChartHit; virtual;
    function ExportSvg(const C: TNimbusChartRenderContext): string;
  end;

  TNimbusLineAreaChartRenderer = class(TNimbusChartRenderer)
  public
    function CanRender(const AType: TNimbusChartType): Boolean; override;
  end;

  TNimbusBarColumnChartRenderer = class(TNimbusChartRenderer)
  public
    function CanRender(const AType: TNimbusChartType): Boolean; override;
  end;

  TNimbusPieDonutChartRenderer = class(TNimbusChartRenderer)
  public
    function CanRender(const AType: TNimbusChartType): Boolean; override;
  end;

  TNimbusChartRendererFactory = class
  private
    FRenderers: TList<INimbusChartRenderer>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterDefaults;
    procedure RegisterRenderer(const ARenderer: INimbusChartRenderer);
    procedure RegisterFirst(const ARenderer: INimbusChartRenderer);
    function Unregister(const ARenderer: INimbusChartRenderer): Boolean;
    procedure Clear;
    function GetRenderer(const AType: TNimbusChartType): INimbusChartRenderer;
    function CanRender(const AType: TNimbusChartType): Boolean;
  end;

function ChartBackColor(const C: TNimbusChartRenderContext): TThemeColor;
function ChartForeColor(const C: TNimbusChartRenderContext): TThemeColor;
function ChartBorderColor(const C: TNimbusChartRenderContext): TThemeColor;
function ChartAccentColor(const C: TNimbusChartRenderContext): TThemeColor;
function ChartHeatmapColor(const C: TNimbusChartRenderContext; const Ratio: Double; const Empty: Boolean = False): TThemeColor;
function ChartIsDark(const C: TNimbusChartRenderContext): Boolean;

implementation

uses NimbusForms.Rendering.BusinessCharts, NimbusForms.Rendering.Violin, NimbusForms.Rendering.Ridgeline, NimbusForms.Rendering.StreamGraph, NimbusForms.Rendering.Treemap, NimbusForms.Rendering.Sunburst, NimbusForms.Rendering.Sankey,
  NimbusForms.Rendering.ProgressRingGrid, NimbusForms.Rendering.EdgeBundling, NimbusForms.Rendering.Marimekko,
  NimbusForms.Rendering.PolarCharts, NimbusForms.Rendering.Maps, NimbusForms.Rendering.FinancialCharts;

function ChartHeatmapColor(const C: TNimbusChartRenderContext; const Ratio: Double; const Empty: Boolean): TThemeColor;
type THeatColors = array[0..4] of TThemeColor;
const Green: THeatColors = ($FFEBEDF0, $FF9BE9A8, $FF40C463, $FF30A14E, $FF216E39);
  DarkGreen: THeatColors = ($FF161B22, $FF0E4429, $FF006D32, $FF26A641, $FF39D353);
  Reds: THeatColors = ($FFFFF5F0, $FFFCBBA1, $FFFB6A4A, $FFCB181D, $FF67000D);
  Thermal: THeatColors = ($FF0000FF, $FF00FFFF, $FFFFFF00, $FFFF8000, $FFFF0000);
var T: Double; Index: Integer; LowColor, HighColor: TThemeColor; Colors: THeatColors;
begin
  T := Ratio; if IsNan(T) or IsInfinite(T) then T := 0; T := EnsureRange(T, 0.0, 1.0);
  if Empty and (C.Model.HeatmapEmptyColor <> clNone) then Result := ColorToThemeColor(C.Model.HeatmapEmptyColor)
  else if C.Model.HeatmapColorPreset in [nhcpTheme, nhcpCustom] then
  begin
    LowColor := ChartBackColor(C); HighColor := ChartAccentColor(C);
    if C.Model.HeatmapLowColor <> clNone then LowColor := ColorToThemeColor(C.Model.HeatmapLowColor);
    if C.Model.HeatmapHighColor <> clNone then HighColor := ColorToThemeColor(C.Model.HeatmapHighColor);
    if Empty then Result := NimbusColorWithAlpha(ChartBorderColor(C), 70)
    else Result := NimbusBlendColor(LowColor, HighColor, Round(T * 255));
  end
  else
  begin
    case C.Model.HeatmapColorPreset of
      nhcpGitHubGreen: Colors := Green;
      nhcpGitHubDark: Colors := DarkGreen;
      nhcpReds: Colors := Reds;
    else Colors := Thermal end;
    if Empty then Result := Colors[0]
    else if C.Model.HeatmapColorPreset in [nhcpGitHubGreen, nhcpGitHubDark] then Result := Colors[EnsureRange(Ceil(T * 4), 0, 4)]
    else begin T := T * 4; Index := Min(3, Floor(T)); Result := NimbusBlendColor(Colors[Index], Colors[Index + 1], Round((T - Index) * 255)) end;
  end;
end;

function ChartIsDark(const C: TNimbusChartRenderContext): Boolean;
var Color: Cardinal;
begin
  if C.ChartPalette = nil then Exit((C.Palette <> nil) and C.Palette.IsDark);
  Color := Cardinal(ColorToThemeColor(C.ChartPalette.BackColor));
  Result := ((Color shr 16 and $FF) * 299 + (Color shr 8 and $FF) * 587 + (Color and $FF) * 114) < 128000;
end;

function ChartBackColor(const C: TNimbusChartRenderContext): TThemeColor;
begin if C.ChartPalette = nil then Result := NimbusControlBackColor(C.Palette) else Result := ColorToThemeColor(C.ChartPalette.BackColor) end;

function ChartForeColor(const C: TNimbusChartRenderContext): TThemeColor;
begin if C.ChartPalette = nil then Result := NimbusControlForeColor(C.Palette) else Result := ColorToThemeColor(C.ChartPalette.ForeColor) end;

function ChartBorderColor(const C: TNimbusChartRenderContext): TThemeColor;
begin if C.ChartPalette = nil then Result := NimbusControlBorderColor(C.Palette) else Result := ColorToThemeColor(C.ChartPalette.BorderColor) end;

function ChartAccentColor(const C: TNimbusChartRenderContext): TThemeColor;
begin if C.ChartPalette = nil then Result := NimbusAccentColor(C.Palette) else Result := ColorToThemeColor(C.ChartPalette.AccentColor) end;

class function TNimbusChartHit.None: TNimbusChartHit;
begin
  Result := Default(TNimbusChartHit); Result.SeriesIndex := -1; Result.PointIndex := -1; Result.ElementIndex := -1;
end;

function TNimbusChartHit.SameElement(const AOther: TNimbusChartHit): Boolean;
begin
  Result := (Area = AOther.Area) and (FinancialArea = AOther.FinancialArea) and (SeriesIndex = AOther.SeriesIndex) and (PointIndex = AOther.PointIndex) and (ElementIndex = AOther.ElementIndex);
end;

constructor TNimbusChartRendererFactory.Create;
begin
  inherited Create; FRenderers := TList<INimbusChartRenderer>.Create; RegisterDefaults;
end;

destructor TNimbusChartRendererFactory.Destroy;
begin
  FRenderers.Free; inherited;
end;

procedure TNimbusChartRendererFactory.RegisterDefaults;
begin
  if not CanRender(nctLine) then RegisterRenderer(TNimbusLineAreaChartRenderer.Create);
  if not CanRender(nctBar) then RegisterRenderer(TNimbusBarColumnChartRenderer.Create);
  if not CanRender(nctPie) then RegisterRenderer(TNimbusPieDonutChartRenderer.Create);
  if not CanRender(nctScatter) then RegisterRenderer(TNimbusChartRenderer.Create);
  if not CanRender(nctBusinessRankedBar) then RegisterRenderer(TNimbusBusinessChartRenderer.Create);
  if not CanRender(nctViolinPlot) then RegisterRenderer(TNimbusViolinChartRenderer.Create);
  if not CanRender(nctRidgeline) then RegisterRenderer(TNimbusRidgelineChartRenderer.Create);
  if not CanRender(nctStreamGraph) then RegisterRenderer(TNimbusStreamGraphChartRenderer.Create);
  if not CanRender(nctTreemap) then RegisterRenderer(TNimbusTreemapChartRenderer.Create);
  if not CanRender(nctSunburst) then RegisterRenderer(TNimbusSunburstChartRenderer.Create);
  if not CanRender(nctSankey) then RegisterRenderer(TNimbusSankeyChartRenderer.Create);
  if not CanRender(nctProgressRingGrid) then RegisterRenderer(TNimbusProgressRingGridRenderer.Create);
  if not CanRender(nctHierarchicalEdgeBundling) then RegisterRenderer(TNimbusHierarchicalEdgeBundlingRenderer.Create);
  if not CanRender(nctMarimekko) then RegisterRenderer(TNimbusMarimekkoChartRenderer.Create);
  if not CanRender(nctRadar) then RegisterRenderer(TNimbusPolarChartRenderer.Create);
  if not CanRender(nctChoroplethMap) then RegisterRenderer(TNimbusMapChartRenderer.Create);
  if not CanRender(nctCandlestick) then RegisterRenderer(TNimbusFinancialChartRenderer.Create);
end;

procedure TNimbusChartRendererFactory.RegisterRenderer(const ARenderer: INimbusChartRenderer);
begin
  if ARenderer = nil then raise EArgumentNilException.Create('Renderer');
  if not FRenderers.Contains(ARenderer) then FRenderers.Add(ARenderer);
end;

procedure TNimbusChartRendererFactory.RegisterFirst(const ARenderer: INimbusChartRenderer);
begin
  if ARenderer = nil then raise EArgumentNilException.Create('Renderer');
  if not FRenderers.Contains(ARenderer) then FRenderers.Insert(0, ARenderer);
end;

function TNimbusChartRendererFactory.Unregister(const ARenderer: INimbusChartRenderer): Boolean;
begin
  Result := FRenderers.Remove(ARenderer) >= 0;
end;

procedure TNimbusChartRendererFactory.Clear;
begin
  FRenderers.Clear;
end;

function TNimbusChartRendererFactory.GetRenderer(const AType: TNimbusChartType): INimbusChartRenderer;
var R: INimbusChartRenderer;
begin
  Result := nil;
  for R in FRenderers do if R.CanRender(AType) then Exit(R);
end;

function TNimbusChartRendererFactory.CanRender(const AType: TNimbusChartType): Boolean;
begin
  Result := GetRenderer(AType) <> nil;
end;

function TNimbusLineAreaChartRenderer.CanRender(const AType: TNimbusChartType): Boolean;
begin
  Result := AType in [nctLine, nctArea, nctLineScatter];
end;

function TNimbusBarColumnChartRenderer.CanRender(const AType: TNimbusChartType): Boolean;
begin
  Result := AType in [nctBar, nctColumn];
end;

function TNimbusPieDonutChartRenderer.CanRender(const AType: TNimbusChartType): Boolean;
begin
  Result := AType in [nctPie, nctDonut];
end;

function TNimbusChartRenderer.CanRender(const AType: TNimbusChartType): Boolean;
begin
  Result := AType in [nctLine, nctArea, nctLineScatter, nctBar, nctColumn, nctPie, nctDonut,
    nctScatter, nctBubble, nctHeatmap, nctKpi, nctGauge, nctRadialBar, nctBullet, nctBoxPlot];
end;

function TNimbusChartRenderer.Arrange(const C: TNimbusChartRenderContext): TNimbusChartLayout;
var M: TNimbusChartModel; R: TRect; P, H, W: Integer; Cartesian: Boolean;
begin
  Result := Default(TNimbusChartLayout); Result.Bounds := C.Bounds;
  M := C.Model; if (M = nil) or (C.Font = nil) then Exit;
  P := NimbusScaleValue(M.Options.Padding, C.PPI); R := C.Bounds; R.Inflate(-P, -P);
  if M.ChartType = nctKpi then
  begin
    P := P + NimbusScaleValue(2, C.PPI); R := C.Bounds;
    R.Left := Min(R.Right, R.Left + P); R.Top := Min(R.Bottom, R.Top + P);
    R.Right := Max(R.Left, R.Right - P); R.Bottom := Max(R.Top, R.Bottom - P); Result.PlotArea := R; Exit;
  end;
  if R.IsEmpty then Exit;
  H := NimbusScaleValue(Max(20, Abs(C.Font.Height) + 8), C.PPI);
  if M.Options.ShowTitle and (M.Title <> '') then begin Result.TitleBounds := Rect(R.Left, R.Top, R.Right, R.Top + H); Inc(R.Top, H) end;
  if M.Options.ShowSubtitle and (M.Subtitle <> '') then begin Result.SubtitleBounds := Rect(R.Left, R.Top, R.Right, R.Top + H); Inc(R.Top, H) end;
  if M.Legend.Visible and (M.Legend.Position <> nclpNone) then
  begin
    W := Min(NimbusScaleValue(150, C.PPI), R.Width div 3); H := Min(NimbusScaleValue(40, C.PPI), R.Height div 4);
    case M.Legend.Position of
      nclpTop: begin Result.LegendBounds := Rect(R.Left, R.Top, R.Right, R.Top + H); Inc(R.Top, H + P div 2) end;
      nclpBottom: begin Result.LegendBounds := Rect(R.Left, R.Bottom - H, R.Right, R.Bottom); Dec(R.Bottom, H + P div 2) end;
      nclpLeft: begin Result.LegendBounds := Rect(R.Left, R.Top, R.Left + W, R.Bottom); Inc(R.Left, W + P div 2) end;
      nclpRight: begin Result.LegendBounds := Rect(R.Right - W, R.Top, R.Right, R.Bottom); Dec(R.Right, W + P div 2) end;
    end;
  end;
  Cartesian := M.ChartType in [nctLine, nctArea, nctLineScatter, nctScatter, nctBubble, nctBar, nctColumn, nctBoxPlot, nctViolinPlot];
  if Cartesian and M.Options.ShowAxes then
  begin
    W := NimbusScaleValue(64, C.PPI); H := NimbusScaleValue(42, C.PPI);
    if M.YAxis.Visible then begin Result.YAxisBounds := Rect(R.Left, R.Top, R.Left + W, R.Bottom - H); Inc(R.Left, W) end;
    if M.SecondaryYAxis.Visible then begin Result.SecondaryYAxisBounds := Rect(R.Right - W, R.Top, R.Right, R.Bottom - H); Dec(R.Right, W) end;
    if M.XAxis.Visible then begin Result.XAxisBounds := Rect(R.Left, R.Bottom - H, R.Right, R.Bottom); Dec(R.Bottom, H) end;
  end;
  R.Right := Max(R.Left, R.Right); R.Bottom := Max(R.Top, R.Bottom); Result.PlotArea := R;
  Result.XRange := M.XAxis.GetEffectiveRange(M.GetXRange);
  Result.YRange := M.GetYRange;
  if (M.ChartType in [nctBar, nctColumn, nctArea]) and Result.YRange.IsValid and M.YAxis.AutoRange then
    Result.YRange := TNimbusChartRange.Create(Min(0.0, Result.YRange.Minimum), Max(0.0, Result.YRange.Maximum));
  Result.YRange := M.YAxis.GetEffectiveRange(Result.YRange);
  if M.ChartType = nctBoxPlot then
  begin
    Result.YRange := M.YAxis.GetEffectiveRange(M.GetBoxPlotRange);
    if M.YAxis.AutoRange and not (M.YAxis.GetEffectiveScale(Result.YRange) in [ncasLogarithmic10, ncasLogarithmic2, ncasNaturalLogarithmic, ncasCustomLogarithmic]) then
      Result.YRange := M.YAxis.GetEffectiveRange(TNimbusChartRange.Create(Result.YRange.Minimum - Result.YRange.Span * 0.1, Result.YRange.Maximum + Result.YRange.Span * 0.1));
  end;
  Result.SecondaryYRange := M.SecondaryYAxis.GetEffectiveRange(M.GetYRange(ncySecondary));
  if C.XView.IsValid then Result.XRange := C.XView;
  if C.YView.IsValid then Result.YRange := C.YView;
end;

function TNimbusChartRenderer.BuildKpi(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>;
var
  M: TNimbusChartModel; P: TNimbusChartPoint; R, Content, B: TRect; Hit: TNimbusChartHit;
  Back, Fore, Muted, Border, StateColor, FillColor: TThemeColor;
  A: TNimbusChartPrimitive; SI, PI, I, K, BaseHeight, ValueHeight, MinimumHeight, TitleHeight, ChangeHeight: Integer;
  TitleLine, ValueLine, DetailLine, SmallLine, ValueY, DetailY, SubtitleY: Integer;
  DPI, Radius, AccentWidth, Value, Angle, ArcRadius: Double;
  TitleText, ValueText, ChangeText, SubtitleText: string;
  Font: TFont; Bitmap: TBitmap; Measurer: INimbusRenderCanvas; Started, Dark: Boolean;
  procedure Add;
  var N: Integer;
  begin N := Length(Result); SetLength(Result, N + 1); Result[N] := A end;
  procedure Shape(const Kind: TNimbusChartPrimitiveKind; const Color: TThemeColor; const Bounds: TRect; const Width: Single = 1);
  begin
    A := Default(TNimbusChartPrimitive); A.Kind := Kind; A.Color := Color; A.Bounds := Bounds;
    A.Width := Width; A.CornerRadius := Radius; A.UseCornerRadius := True; A.Hit := TNimbusChartHit.None;
    if not C.Enabled then A.Color := NimbusBlendColor(Color, Back, 160); Add;
  end;
  function Measure(const Text: string; const Height: Integer; const Style: TFontStyles; const Width: Integer): TSize;
  begin
    Font.Assign(C.Font); Font.Height := -Max(1, Height); Font.Style := Style;
    Result := Measurer.MeasureText(Text, Font, Width, [ntfSingleLine, ntfNoPrefix]);
  end;
  procedure Text(const TextValue: string; const Bounds: TRect; const Color: TThemeColor; const Height: Integer; const Style: TFontStyles);
  begin
    if (TextValue = '') or Bounds.IsEmpty then Exit;
    A := Default(TNimbusChartPrimitive); A.Kind := ncpText; A.Text := TextValue; A.Bounds := Bounds; A.Color := Color;
    A.UseFont := True; A.FontHeight := -Max(1, Height); A.FontStyle := Style; A.UseClip := True; A.ClipBounds := Content;
    A.TextFlags := [ntfSingleLine, ntfEndEllipsis, ntfNoPrefix]; A.Hit := TNimbusChartHit.None;
    if not C.Enabled then A.Color := NimbusBlendColor(Color, Back, 160); Add;
  end;
begin
  Result := nil; M := C.Model; R := L.PlotArea;
  if (M = nil) or (C.Font = nil) or R.IsEmpty then Exit;
  DPI := Max(1, C.PPI) / 96; SI := -1; PI := -1; P := nil;
  for I := 0 to M.Series.Count - 1 do if M.Series[I].Visible then begin SI := I; Break end;
  if SI >= 0 then
    for I := 0 to M.Series[SI].Points.Count - 1 do
      if M.Series[SI].Points[I].Visible then begin PI := I; P := M.Series[SI].Points[I]; Break end;
  Value := M.KpiValue; if (P <> nil) and SparklineFinite(P.YValue) then Value := P.YValue;
  TitleText := M.KpiTitle; if TitleText = '' then TitleText := M.Title;
  ValueText := M.KpiValueText; if ValueText = '' then ValueText := SparklineFormatValue(Value, M.YAxis.LabelFormat);
  SubtitleText := M.KpiSubtitle; if SubtitleText = '' then SubtitleText := M.Subtitle;
  ChangeText := M.KpiChangeText;
  if (ChangeText = '') and (P <> nil) then ChangeText := P.&Label;
  if (ChangeText = '') and (Abs(M.KpiChangeValue) > 0) then ChangeText := FormatFloat('+0.##;-0.##;0', M.KpiChangeValue);
  Hit := TNimbusChartHit.None; Hit.Area := nchaPoint; Hit.SeriesIndex := SI; Hit.PointIndex := PI;
  Hit.XValue := 0; Hit.YValue := Value; Hit.Text := TitleText;
  if ValueText <> '' then Hit.Text := Hit.Text + sLineBreak + 'Value: ' + ValueText;
  if ChangeText <> '' then Hit.Text := Hit.Text + sLineBreak + 'Change: ' + ChangeText;
  if SubtitleText <> '' then Hit.Text := Hit.Text + sLineBreak + SubtitleText;
  Hit.Text := Trim(Hit.Text); if (P <> nil) and (P.ToolTipText <> '') then Hit.Text := P.ToolTipText;
  Back := ChartBackColor(C); Fore := ChartForeColor(C); Border := ChartBorderColor(C); Muted := NimbusBlendColor(Fore, Back, 145);
  if C.ChartPalette <> nil then Muted := ColorToThemeColor(C.ChartPalette.MutedForeColor);
  StateColor := ChartAccentColor(C);
  case M.KpiState of
    nksSuccess: if C.ChartPalette = nil then StateColor := NimbusSuccessColor else StateColor := ColorToThemeColor(C.ChartPalette.SuccessColor);
    nksWarning: if C.ChartPalette = nil then StateColor := NimbusWarningColor else StateColor := ColorToThemeColor(C.ChartPalette.WarningColor);
    nksError: if C.ChartPalette = nil then StateColor := NimbusDangerColor else StateColor := ColorToThemeColor(C.ChartPalette.ErrorColor);
    nksInfo: if C.ChartPalette <> nil then StateColor := ColorToThemeColor(C.ChartPalette.InfoColor);
  end;
  Dark := ChartIsDark(C);
  if Dark then FillColor := NimbusBlendColor(Back, Border, 51) else FillColor := NimbusBlendColor(Back, $FFFFFFFF, 89);
  if Hit.SameElement(C.Hovered) then
  begin K := 20; if Dark then K := 31; FillColor := NimbusBlendColor(FillColor, StateColor, K) end;
  Radius := Max(4.0, (M.Options.CornerRadius + 4) * DPI);
  Shape(ncpRect, FillColor, R);
  B := R; B.Right := Max(B.Left, B.Right - 1); B.Bottom := Max(B.Top, B.Bottom - 1);
  if Hit.SameElement(C.Selected) then Shape(ncpOutlineRect, StateColor, B, 2) else Shape(ncpOutlineRect, Border, B);
  AccentWidth := Min(R.Width, 6 * DPI); ArcRadius := Min(Min(AccentWidth, R.Height / 2), Radius);
  A := Default(TNimbusChartPrimitive); A.Kind := ncpPolygon; A.Color := StateColor; A.Hit := TNimbusChartHit.None;
  SetLength(A.Points, 20);
  for I := 0 to 8 do
  begin
    Angle := DegToRad(180 + I * 90 / 8);
    A.Points[I] := TPointF.Create(R.Left + ArcRadius + Cos(Angle) * ArcRadius, R.Top + ArcRadius + Sin(Angle) * ArcRadius);
  end;
  A.Points[9] := TPointF.Create(R.Left + AccentWidth, R.Top);
  A.Points[10] := TPointF.Create(R.Left + AccentWidth, R.Bottom);
  for I := 0 to 8 do
  begin
    Angle := DegToRad(90 + I * 90 / 8);
    A.Points[11 + I] := TPointF.Create(R.Left + ArcRadius + Cos(Angle) * ArcRadius, R.Bottom - ArcRadius + Sin(Angle) * ArcRadius);
  end;
  if not C.Enabled then A.Color := NimbusBlendColor(A.Color, Back, 160); Add;
  Content := Rect(R.Left + Round(AccentWidth + 24 * DPI), R.Top + Round(22 * DPI), R.Right - Round(24 * DPI), R.Bottom - Round(20 * DPI));
  if not Content.IsEmpty then
  begin
    Bitmap := nil; Started := False; Measurer := C.MeasureCanvas; Font := TFont.Create;
    try
      if Measurer = nil then
      begin
        Bitmap := TBitmap.Create; Bitmap.PixelFormat := pf32bit; Bitmap.SetSize(1, 1);
        Measurer := TNimbusRenderCanvas.Create; Measurer.BeginRender(Bitmap.Canvas); Started := True;
      end;
      BaseHeight := Max(1, Abs(C.Font.Height));
      ValueHeight := Max(BaseHeight + Round(10 * DPI * 96 / 72), Round(BaseHeight * 2.25));
      MinimumHeight := Max(BaseHeight + Round(5 * DPI * 96 / 72), Round(BaseHeight * 1.55));
      if Content.Height < 110 * DPI then ValueHeight := Max(MinimumHeight, Round(BaseHeight * 1.95));
      if (SubtitleText <> '') and (ChangeText <> '') and (Content.Height < 145 * DPI) then ValueHeight := Max(MinimumHeight, Round(BaseHeight * 1.8));
      while (ValueHeight > MinimumHeight) and (Measure(ValueText, ValueHeight, [fsBold], 0).cx > Content.Width) do
        ValueHeight := Max(MinimumHeight, ValueHeight - Max(1, Round(DPI * 96 / 72)));
      TitleHeight := BaseHeight + Round(0.25 * DPI * 96 / 72); ChangeHeight := BaseHeight + Round(0.5 * DPI * 96 / 72);
      TitleLine := Max(Round(18 * DPI), Measure(TitleText, TitleHeight, [], Content.Width).cy + Round(2 * DPI));
      ValueLine := Max(Round(34 * DPI), Measure(ValueText, ValueHeight, [fsBold], Content.Width).cy + Round(2 * DPI));
      DetailLine := Max(Round(18 * DPI), Measure(ChangeText, ChangeHeight, [fsBold], Content.Width).cy + Round(2 * DPI));
      SmallLine := Max(Round(16 * DPI), Measure(SubtitleText, BaseHeight, C.Font.Style, Content.Width).cy + Round(2 * DPI));
      ValueY := Content.Top + TitleLine + Round(8 * DPI); DetailY := ValueY + ValueLine + Round(10 * DPI);
      SubtitleY := DetailY + DetailLine + Round(2 * DPI);
      if (SubtitleText <> '') and (SubtitleY + SmallLine > Content.Bottom) then SubtitleY := Content.Bottom - SmallLine;
      K := Content.Bottom; if SubtitleText <> '' then K := SubtitleY - Round(2 * DPI);
      if (ChangeText <> '') and (DetailY + DetailLine > K) then
      begin
        K := 0; if SubtitleText <> '' then K := SmallLine + Round(4 * DPI);
        DetailY := Max(ValueY + ValueLine + Round(6 * DPI), Content.Bottom - DetailLine - K);
      end;
      Text(TitleText, Rect(Content.Left, Content.Top, Content.Right, Content.Top + TitleLine), Muted, TitleHeight, []);
      Text(ValueText, Rect(Content.Left, ValueY, Content.Right, ValueY + ValueLine), Fore, ValueHeight, [fsBold]);
      Text(ChangeText, Rect(Content.Left, DetailY, Content.Right, DetailY + DetailLine), StateColor, ChangeHeight, [fsBold]);
      Text(SubtitleText, Rect(Content.Left, SubtitleY, Content.Right, SubtitleY + SmallLine), Muted, BaseHeight, C.Font.Style);
    finally
      if Started then Measurer.EndRender; Measurer := nil; Bitmap.Free; Font.Free;
    end;
  end;
  A := Default(TNimbusChartPrimitive); A.Kind := ncpHitBounds; A.Bounds := R; A.Hit := Hit; Add;
end;

function TNimbusChartRenderer.Build(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>;
var
  M: TNimbusChartModel; R, Bounds: TRect; S: TNimbusChartSeries; P: TNimbusChartPoint;
  I, J, K, N, Count, VisibleCount, VisibleIndex, Radius, Columns, Rows, Row, Column, LegendSeries, LegendPoint: Integer;
  Indices: TArray<Integer>; Previous: TPointF; HavePrevious: Boolean;
  X, Y, Zero, Slot, BarWidth, Total, Start, Sweep, Mid, Ratio, Size, Low, MaxValue, V: Double;
  A: TNimbusChartPrimitive; Fore, Back, Muted, Border, Col: TThemeColor;
  Axis: TNimbusChartAxis; Range: TNimbusChartRange;
  RefLine: TNimbusChartReferenceLine; Band: TNimbusChartReferenceRange; Annotation: TNimbusChartAnnotation;
  Data: TSparklineValues; Box: TNimbusBoxPlotData; Bullet: TNimbusBulletData; BulletRange: TNimbusBulletRange;
  Minimum, Q1, Median, Q3, Maximum, Actual, Target: Double; Horizontal, CustomBullet: Boolean; BulletBounds: TRect;
  CaptionText, ActualText, TargetText: string;
  AnnotationOrder: TArray<Integer>; Placed: TArray<TRect>; AnchorPoint: TPointF; Overlap: Boolean;
  function ResolveColor(const AColor: TColor; const AFallback: TThemeColor): TThemeColor;
  begin
    if AColor = clNone then Result := AFallback else Result := ColorToThemeColor(AColor);
    if (AColor <> clNone) and (C.ColorInfluence > 0) then Result := NimbusBlendColor(Result, AFallback, Round(EnsureRange(C.ColorInfluence, 0, 100) * 255 / 100));
    if not C.Enabled then Result := NimbusBlendColor(Result, Back, 160);
  end;
  function SeriesColor(const Index: Integer): TThemeColor;
  const Colors: array[0..7] of Cardinal = ($FF007ACC, $FF50B469, $FFEBAB41, $FFD9617E, $FF9768C6, $FF3AB9BC, $FFC79352, $FF6480C0);
  begin
    if Index = 0 then Result := ChartAccentColor(C) else Result := TThemeColor(Colors[Index mod Length(Colors)]);
    if C.ChartPalette <> nil then Result := ColorToThemeColor(C.ChartPalette.GetSeriesColor(Index));
    Result := ResolveColor(M.Series[Index].Color, Result);
  end;
  procedure Add;
  begin
    N := Length(Result); SetLength(Result, N + 1); Result[N] := A;
  end;
  procedure NewPrimitive(const Kind: TNimbusChartPrimitiveKind; const Color: TThemeColor);
  begin
    A := Default(TNimbusChartPrimitive); A.Kind := Kind; A.Color := Color; A.Hit := TNimbusChartHit.None; A.Width := 1;
  end;
  procedure Text(const TextValue: string; const TextBounds: TRect; const Color: TThemeColor; const Flags: TNimbusTextFlags);
  begin
    if TextValue = '' then Exit;
    NewPrimitive(ncpText, Color); A.Text := TextValue; A.Bounds := TextBounds; A.TextFlags := Flags; Add;
  end;
  procedure Line(const X1, Y1, X2, Y2: Double; const Color: TThemeColor; const Width: Single = 1);
  begin
    NewPrimitive(ncpLine, Color); A.Points := [TPointF.Create(X1, Y1), TPointF.Create(X2, Y2)]; A.Width := Width; Add;
  end;
  procedure PointHit(const SI, PI: Integer; const Area: TNimbusChartHitArea);
  var Point: TNimbusChartPoint;
  begin
    A.Hit.Area := Area; A.Hit.SeriesIndex := SI; A.Hit.PointIndex := PI;
    if PI < 0 then Exit;
    Point := M.Series[SI].Points[PI]; A.Hit.XValue := Point.XValue; A.Hit.YValue := Point.YValue;
    if Point.ToolTipText <> '' then A.Hit.Text := Point.ToolTipText
    else A.Hit.Text := M.Series[SI].Name + ' ' + Point.&Label + ': ' + SparklineFormatValue(Point.YValue, '0.##');
  end;
  function MapX(const Value: Double): Double;
  begin
    Result := R.Left + M.XAxis.NormalizeWithinRange(Value, L.XRange) * R.Width;
  end;
  function MapY(const Value: Double; AAxis: TNimbusChartAxis; const ARange: TNimbusChartRange): Double;
  begin
    Result := R.Bottom - AAxis.NormalizeWithinRange(Value, ARange) * R.Height;
  end;
  procedure AxisLines(AAxis: TNimbusChartAxis; const ARange: TNimbusChartRange; const AxisBounds: TRect; const Horizontal, Secondary: Boolean);
  var Ticks: TArray<Double>; Tick: Double; Position: Double; TickBounds: TRect;
  begin
    if not AAxis.Visible then Exit;
    if M.Options.ShowGrid and AAxis.ShowMinorGridLines then
      for Tick in AAxis.CreateMinorTicks(ARange) do
      begin
        Position := AAxis.NormalizeWithinRange(Tick, ARange);
        if not SparklineFinite(Position) or (Position < 0) or (Position > 1) then Continue;
        if Horizontal then Line(R.Left + Position * R.Width, R.Top, R.Left + Position * R.Width, R.Bottom, NimbusColorWithAlpha(Border, 70))
        else Line(R.Left, R.Bottom - Position * R.Height, R.Right, R.Bottom - Position * R.Height, NimbusColorWithAlpha(Border, 70));
      end;
    Ticks := AAxis.CreateTicks(ARange);
    for Tick in Ticks do
    begin
      Position := AAxis.NormalizeWithinRange(Tick, ARange);
      if not SparklineFinite(Position) or (Position < -0.001) or (Position > 1.001) then Continue;
      if Horizontal then
      begin
        Position := R.Left + Position * R.Width;
        if M.Options.ShowGrid and AAxis.ShowGridLines then Line(Position, R.Top, Position, R.Bottom, NimbusColorWithAlpha(Border, 100));
        TickBounds := Rect(Round(Position) - 40, AxisBounds.Top + 2, Round(Position) + 40, AxisBounds.Top + NimbusScaleValue(20, C.PPI));
      end
      else
      begin
        Position := R.Bottom - Position * R.Height;
        if M.Options.ShowGrid and AAxis.ShowGridLines and not Secondary then Line(R.Left, Position, R.Right, Position, NimbusColorWithAlpha(Border, 100));
        TickBounds := Rect(AxisBounds.Left, Round(Position) - 10, AxisBounds.Right - 4, Round(Position) + 10);
      end;
      if M.Options.ShowAxes and AAxis.ShowLabels and not AxisBounds.IsEmpty then
        Text(AAxis.FormatValue(Tick, ARange), TickBounds, Muted, [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix]);
    end;
    if M.Options.ShowAxes and not AxisBounds.IsEmpty then
    begin
      if Horizontal then Line(R.Left, R.Bottom, R.Right, R.Bottom, Border)
      else if Secondary then Line(R.Right, R.Top, R.Right, R.Bottom, Border) else Line(R.Left, R.Top, R.Left, R.Bottom, Border);
      Text(AAxis.Title, Rect(AxisBounds.Left, AxisBounds.Bottom - 20, AxisBounds.Right, AxisBounds.Bottom), Fore, [ntfCenter, ntfSingleLine, ntfNoPrefix]);
    end;
  end;
begin
  Result := nil; M := C.Model; R := L.PlotArea;
  if (M <> nil) and (M.ChartType = nctKpi) then Exit(BuildKpi(C, L));
  if (M = nil) or R.IsEmpty then Exit;
  Back := ChartBackColor(C); Fore := ChartForeColor(C);
  Border := ChartBorderColor(C); Muted := NimbusBlendColor(Fore, Back, 145);
  if C.ChartPalette <> nil then Muted := ColorToThemeColor(C.ChartPalette.MutedForeColor);
  Text(M.Title, L.TitleBounds, Fore, [ntfSingleLine, ntfEndEllipsis, ntfNoPrefix]);
  Text(M.Subtitle, L.SubtitleBounds, Muted, [ntfSingleLine, ntfEndEllipsis, ntfNoPrefix]);
  for I := 0 to M.ReferenceRanges.Count - 1 do
  begin
    Band := M.ReferenceRanges[I]; if not Band.Visible then Continue;
    Axis := M.YAxis; Range := L.YRange;
    if Band.YAxis = ncySecondary then begin Axis := M.SecondaryYAxis; Range := L.SecondaryYRange end;
    if Band.Orientation = ncroVertical then
    begin X := MapX(Band.Minimum); Y := MapX(Band.Maximum); if not SparklineFinite(X) or not SparklineFinite(Y) then Continue;
      Bounds := Rect(Round(Min(X, Y)), R.Top, Round(Max(X, Y)), R.Bottom) end
    else
    begin X := MapY(Band.Minimum, Axis, Range); Y := MapY(Band.Maximum, Axis, Range); if not SparklineFinite(X) or not SparklineFinite(Y) then Continue;
      Bounds := Rect(R.Left, Round(Min(X, Y)), R.Right, Round(Max(X, Y))) end;
    NewPrimitive(ncpRect, NimbusColorWithAlpha(ResolveColor(Band.Color, ChartAccentColor(C)), Round(EnsureRange(Band.Opacity, Single(0), Single(1)) * 255)));
    Bounds := TRect.Intersect(Bounds, R); A.Bounds := Bounds; A.Hit.Area := nchaReferenceRange; A.Hit.ElementIndex := I; A.Hit.Text := Band.Text; Add;
    Text(Band.Text, Rect(Bounds.Left + 4, Bounds.Top + 2, Bounds.Right - 4, Min(Bounds.Bottom, Bounds.Top + 22)), Muted, [ntfSingleLine, ntfEndEllipsis, ntfNoPrefix]);
  end;
  if M.ChartType in [nctLine, nctArea, nctLineScatter, nctScatter, nctBubble, nctColumn, nctBar] then
  begin
    if (M.ChartType = nctBar) or ((M.ChartType = nctColumn) and (M.Options.Orientation = ncoHorizontal)) then
    begin
      AxisLines(M.YAxis, L.YRange, L.XAxisBounds, True, False);
      for I := 0 to M.Series.Count - 1 do if M.Series[I].Visible then
      begin
        S := M.Series[I]; Slot := R.Height / Max(1, S.Points.Count);
        for J := 0 to S.Points.Count - 1 do
        begin
          CaptionText := S.Points[J].&Label; if CaptionText = '' then CaptionText := M.XAxis.FormatValue(S.Points[J].XValue, L.XRange);
          if M.Options.ShowAxes and M.XAxis.ShowLabels then Text(CaptionText,
            Rect(L.YAxisBounds.Left, Round(R.Top + J * Slot), L.YAxisBounds.Right - 4, Round(R.Top + (J + 1) * Slot)), Muted, [ntfRight, ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix]);
        end;
        Break;
      end;
    end
    else
    begin
      AxisLines(M.XAxis, L.XRange, L.XAxisBounds, True, False);
      AxisLines(M.YAxis, L.YRange, L.YAxisBounds, False, False);
      AxisLines(M.SecondaryYAxis, L.SecondaryYRange, L.SecondaryYAxisBounds, False, True);
    end;
  end;
  VisibleCount := 0;
  for I := 0 to M.Series.Count - 1 do if M.Series[I].Visible then Inc(VisibleCount);
  VisibleIndex := -1;
  if M.ChartType in [nctLine, nctArea, nctLineScatter, nctScatter, nctBubble, nctColumn, nctBar] then
    for I := 0 to M.Series.Count - 1 do
    begin
      S := M.Series[I]; if not S.Visible then Continue; Inc(VisibleIndex); Col := SeriesColor(I);
      Axis := M.YAxis; Range := L.YRange;
      if S.YAxis = ncySecondary then begin Axis := M.SecondaryYAxis; Range := L.SecondaryYRange end;
      Zero := MapY(0, Axis, Range); if not SparklineFinite(Zero) then Zero := R.Bottom;
      Zero := EnsureRange(Zero, Double(R.Top), Double(R.Bottom)); HavePrevious := False;
      if M.ChartType in [nctLine, nctArea, nctLineScatter] then Indices := S.GetRenderPointIndices(R.Width)
      else begin SetLength(Indices, S.Points.Count); for J := 0 to High(Indices) do Indices[J] := J end;
      Slot := R.Width / Max(1, S.Points.Count); BarWidth := Max(1.0, Slot * 0.75 / Max(1, VisibleCount));
      for K := 0 to High(Indices) do
      begin
        J := Indices[K]; P := S.Points[J];
        if not P.Visible or not SparklineFinite(P.XValue) or not SparklineFinite(P.YValue) then begin HavePrevious := False; Continue end;
        X := MapX(P.XValue); Y := MapY(P.YValue, Axis, Range);
        if not SparklineFinite(X) or not SparklineFinite(Y) then begin HavePrevious := False; Continue end;
        Y := Zero + (Y - Zero) * EnsureRange(C.AnimationProgress, 0.0, 1.0);
        if M.ChartType in [nctColumn, nctBar] then
        begin
          if (M.ChartType = nctBar) or (M.Options.Orientation = ncoHorizontal) then
          begin
            Slot := R.Height / Max(1, S.Points.Count); BarWidth := Max(1.0, Slot * 0.75 / Max(1, VisibleCount));
            X := R.Left + Axis.NormalizeWithinRange(P.YValue, Range) * R.Width;
            Zero := R.Left + Axis.NormalizeWithinRange(0, Range) * R.Width;
            if not SparklineFinite(Zero) then Zero := R.Left;
            Zero := EnsureRange(Zero, Double(R.Left), Double(R.Right));
            X := Zero + (X - Zero) * C.AnimationProgress;
            Y := R.Top + J * Slot + Slot * 0.125 + VisibleIndex * BarWidth;
            Bounds := Rect(Round(Min(X, Zero)), Round(Y), Round(Max(X, Zero)), Round(Y + BarWidth));
          end
          else
          begin
            X := R.Left + J * Slot + Slot * 0.125 + VisibleIndex * BarWidth;
            Bounds := Rect(Round(X), Round(Min(Y, Zero)), Round(X + BarWidth), Round(Max(Y, Zero)));
          end;
          NewPrimitive(ncpRect, ResolveColor(P.Color, Col)); A.Bounds := Bounds; PointHit(I, J, nchaPoint); Add;
        end
        else
        begin
          if HavePrevious and not (M.ChartType in [nctScatter, nctBubble]) then
          begin
            if (M.ChartType = nctArea) or (S.RenderKind = nsrkArea) then
            begin
              NewPrimitive(ncpPolygon, NimbusColorWithAlpha(Col, Round(S.FillOpacity * 255)));
              A.Points := [TPointF.Create(Previous.X, Zero), Previous, TPointF.Create(X, Y), TPointF.Create(X, Zero)];
              PointHit(I, J, nchaSeries); Add;
            end;
            NewPrimitive(ncpLine, Col); A.Points := [Previous, TPointF.Create(X, Y)]; A.Width := S.LineWidth * C.PPI / 96;
            PointHit(I, J, nchaSeries); Add;
          end;
          if S.ShowMarkers or (M.ChartType in [nctScatter, nctBubble, nctLineScatter]) then
          begin
            Radius := Max(2, Round(S.MarkerSize * C.PPI / 192));
            if M.ChartType = nctBubble then Radius := Max(2, Round(Sqrt(Max(0.0, P.SizeValue)) * C.PPI / 48));
            NewPrimitive(ncpEllipse, ResolveColor(P.Color, Col)); A.Bounds := Rect(Round(X) - Radius, Round(Y) - Radius, Round(X) + Radius + 1, Round(Y) + Radius + 1);
            case S.MarkerShape of
              ncmsSquare: A.Kind := ncpRect;
              ncmsDiamond: begin A.Kind := ncpPolygon; A.Points := [TPointF.Create(X, Y - Radius), TPointF.Create(X + Radius, Y), TPointF.Create(X, Y + Radius), TPointF.Create(X - Radius, Y)] end;
              ncmsTriangle: begin A.Kind := ncpPolygon; A.Points := [TPointF.Create(X, Y - Radius), TPointF.Create(X + Radius, Y + Radius), TPointF.Create(X - Radius, Y + Radius)] end;
              ncmsNone: A.Color := NimbusColorWithAlpha(A.Color, 0);
            end;
            PointHit(I, J, nchaPoint); Add;
          end
          else
          begin
            NewPrimitive(ncpEllipse, NimbusColorWithAlpha(Col, 0)); A.Bounds := Rect(Round(X) - 5, Round(Y) - 5, Round(X) + 6, Round(Y) + 6);
            PointHit(I, J, nchaPoint); Add;
          end;
          Previous := TPointF.Create(X, Y); HavePrevious := True;
        end;
        if M.Options.ShowValues or S.ShowValues then
        begin
          if S.ValueFormat = '' then Text(SparklineFormatValue(P.YValue, '0.##'), Rect(Round(X) - 40, Round(Y) - 24, Round(X) + 40, Round(Y) - 2), Fore, [ntfCenter, ntfSingleLine, ntfNoPrefix])
          else Text(SparklineFormatValue(P.YValue, S.ValueFormat), Rect(Round(X) - 40, Round(Y) - 24, Round(X) + 40, Round(Y) - 2), Fore, [ntfCenter, ntfSingleLine, ntfNoPrefix]);
        end;
      end;
    end;
  if M.ChartType in [nctPie, nctDonut] then
  begin
    for I := 0 to M.Series.Count - 1 do if M.Series[I].Visible then
    begin
      S := M.Series[I]; Total := 0;
      for J := 0 to S.Points.Count - 1 do if S.Points[J].Visible and SparklineFinite(S.Points[J].YValue) then Total := Total + Abs(S.Points[J].YValue);
      if Total <= 0 then Continue;
      Size := Min(R.Width, R.Height); X := R.CenterPoint.X; Y := R.CenterPoint.Y;
      Bounds := Rect(Round(X - Size / 2), Round(Y - Size / 2), Round(X + Size / 2), Round(Y + Size / 2)); Start := -90;
      for J := 0 to S.Points.Count - 1 do
      begin
        P := S.Points[J]; if not P.Visible or not SparklineFinite(P.YValue) or (P.YValue = 0) then Continue;
        Sweep := Abs(P.YValue) / Total * 360 * C.AnimationProgress;
        NewPrimitive(ncpSector, ResolveColor(P.Color, NimbusBlendColor(SeriesColor(I), ThemeColor(255, 240, 160, 70), Byte((J * 47) mod 230))));
        A.Bounds := Bounds; A.StartAngle := Start; A.SweepAngle := Sweep;
        if M.ChartType = nctDonut then A.InnerRadius := Size * M.Options.InnerRadiusPercent / 200;
        PointHit(I, J, nchaSegment); Add;
        if M.Options.ShowValues then
        begin
          Mid := DegToRad(Start + Sweep / 2); Radius := Round(Size * 0.38);
          Text(SparklineFormatValue(P.YValue, '0.##'), Rect(Round(X + Cos(Mid) * Radius) - 30, Round(Y + Sin(Mid) * Radius) - 10,
            Round(X + Cos(Mid) * Radius) + 30, Round(Y + Sin(Mid) * Radius) + 10), Fore, [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix]);
        end;
        Start := Start + Sweep;
      end;
      Break;
    end;
  end;
  if M.ChartType = nctBullet then
  begin
    I := -1; CustomBullet := False;
    for J := 0 to M.Series.Count - 1 do if M.Series[J].Visible then
    begin if I < 0 then I := J; if M.Series[J].Bullet.Enabled then begin I := J; CustomBullet := True; Break end end;
    Minimum := 0; Maximum := 100; Actual := 0; Target := 0; Horizontal := True;
    ActualText := ''; TargetText := ''; Bullet := nil;
    if I >= 0 then
    begin
      S := M.Series[I];
      if CustomBullet then
      begin Bullet := S.Bullet; Minimum := Bullet.Minimum; Maximum := Bullet.Maximum; Actual := Bullet.ActualValue; Target := Bullet.TargetValue;
        Horizontal := Bullet.Orientation = ncoHorizontal; ActualText := Bullet.ActualText; TargetText := Bullet.TargetText end
      else if S.Points.Count > 0 then begin Actual := S.Points[0].YValue; Target := S.Points[0].SizeValue; Maximum := Max(100.0, Max(Actual, Target)) end;
    end;
    if not SparklineFinite(Actual) then Actual := Minimum; if not SparklineFinite(Target) then Target := Minimum;
    if not SparklineFinite(Minimum) then Minimum := 0; if not SparklineFinite(Maximum) or (Maximum <= Minimum) then Maximum := Minimum + 1;
    if Horizontal then BulletBounds := Rect(R.Left + R.Width div 12, R.Top + R.Height div 3, R.Right - R.Width div 12, R.Top + R.Height * 2 div 3)
    else BulletBounds := Rect(R.Left + R.Width div 3, R.Top + R.Height div 12, R.Left + R.Width * 2 div 3, R.Bottom - R.Height div 6);
    Count := 3; if CustomBullet then Count := Bullet.Ranges.Count;
    for J := 0 to Count - 1 do
    begin
      Col := NimbusBlendColor(ChartAccentColor(C), Back, Round(255 * (0.75 - J / Max(1, Count - 1) * 0.42)));
      if CustomBullet then begin BulletRange := Bullet.Ranges[J]; X := BulletRange.StartValue; Y := BulletRange.EndValue; Col := ResolveColor(BulletRange.Color, Col); CaptionText := BulletRange.&Label end
      else begin
        case J of 0: begin X := Minimum; Y := Minimum + (Maximum - Minimum) * 0.55 end;
          1: begin X := Minimum + (Maximum - Minimum) * 0.55; Y := Minimum + (Maximum - Minimum) * 0.8 end;
          else begin X := Minimum + (Maximum - Minimum) * 0.8; Y := Maximum end end; CaptionText := '';
      end;
      X := EnsureRange((X - Minimum) / (Maximum - Minimum), 0.0, 1.0); Y := EnsureRange((Y - Minimum) / (Maximum - Minimum), 0.0, 1.0);
      if Horizontal then Bounds := Rect(BulletBounds.Left + Round(Min(X, Y) * BulletBounds.Width), BulletBounds.Top, BulletBounds.Left + Round(Max(X, Y) * BulletBounds.Width), BulletBounds.Bottom)
      else Bounds := Rect(BulletBounds.Left, BulletBounds.Bottom - Round(Max(X, Y) * BulletBounds.Height), BulletBounds.Right, BulletBounds.Bottom - Round(Min(X, Y) * BulletBounds.Height));
      NewPrimitive(ncpRect, Col); A.Bounds := Bounds; A.Hit.Area := nchaSegment; A.Hit.SeriesIndex := I; A.Hit.ElementIndex := J; A.Hit.Text := CaptionText; Add;
    end;
    Ratio := EnsureRange((Actual - Minimum) / (Maximum - Minimum), 0.0, 1.0) * C.AnimationProgress; Bounds := BulletBounds;
    if Horizontal then begin Bounds.Inflate(0, -Round(Bounds.Height * 0.32)); Bounds.Right := Bounds.Left + Round(BulletBounds.Width * Ratio) end
    else begin Bounds.Inflate(-Round(Bounds.Width * 0.32), 0); Bounds.Top := Bounds.Bottom - Round(BulletBounds.Height * Ratio) end;
    NewPrimitive(ncpRect, ChartAccentColor(C)); A.Bounds := Bounds; A.Hit.Area := nchaSeries; A.Hit.SeriesIndex := I;
    A.Hit.Text := 'Actual: ' + SparklineFormatValue(Actual, '0.##') + #10 + 'Target: ' + SparklineFormatValue(Target, '0.##'); A.Hit.YValue := Actual; Add;
    Ratio := EnsureRange((Target - Minimum) / (Maximum - Minimum), 0.0, 1.0);
    NewPrimitive(ncpLine, Fore); A.Width := NimbusScaleValue(2, C.PPI);
    if Horizontal then begin X := BulletBounds.Left + BulletBounds.Width * Ratio; A.Points := [TPointF.Create(X, BulletBounds.Top - 5), TPointF.Create(X, BulletBounds.Bottom + 5)] end
    else begin Y := BulletBounds.Bottom - BulletBounds.Height * Ratio; A.Points := [TPointF.Create(BulletBounds.Left - 5, Y), TPointF.Create(BulletBounds.Right + 5, Y)] end;
    A.Hit.Area := nchaSeries; A.Hit.SeriesIndex := I; A.Hit.ElementIndex := 1; A.Hit.YValue := Target; A.Hit.Text := 'Target: ' + SparklineFormatValue(Target, '0.##'); Add;
    if ActualText = '' then ActualText := SparklineFormatValue(Actual, '0.##'); if TargetText = '' then TargetText := 'Target ' + SparklineFormatValue(Target, '0.##');
    Text(ActualText, Rect(R.Left, BulletBounds.Bottom + 8, R.Right, BulletBounds.Bottom + 30), Fore, [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix]);
    Text(SparklineFormatValue(Minimum, '0.##'), Rect(BulletBounds.Left, BulletBounds.Bottom + 8, BulletBounds.Right, BulletBounds.Bottom + 30), Muted, [ntfSingleLine, ntfNoPrefix]);
    Text(SparklineFormatValue(Maximum, '0.##'), Rect(BulletBounds.Left, BulletBounds.Bottom + 8, BulletBounds.Right, BulletBounds.Bottom + 30), Muted, [ntfRight, ntfSingleLine, ntfNoPrefix]);
    Text(TargetText, Rect(R.Left, BulletBounds.Top - 24, R.Right, BulletBounds.Top - 2), Muted, [ntfCenter, ntfSingleLine, ntfNoPrefix]);
  end;
  if M.ChartType = nctBoxPlot then
  begin
    Axis := M.YAxis; Range := L.YRange;
    AxisLines(Axis, Range, L.YAxisBounds, False, False); VisibleIndex := -1;
    Slot := R.Width / Max(1, VisibleCount); BarWidth := Min(NimbusScaleValue(46, C.PPI), Slot * 0.42);
    for I := 0 to M.Series.Count - 1 do
    begin
      S := M.Series[I]; if not S.Visible then Continue; Inc(VisibleIndex); Box := S.BoxPlot;
      if Box.Enabled then begin Minimum := Box.Minimum; Q1 := Box.Q1; Median := Box.Median; Q3 := Box.Q3; Maximum := Box.Maximum; CaptionText := Box.Category end
      else
      begin
        Data := nil;
        for J := 0 to S.Points.Count - 1 do if S.Points[J].Visible and SparklineFinite(S.Points[J].YValue) then
        begin SetLength(Data, Length(Data) + 1); Data[High(Data)] := S.Points[J].YValue end;
        if Length(Data) < 5 then Continue; TArray.Sort<Double>(Data);
        Minimum := Data[0]; Maximum := Data[High(Data)]; Q1 := NimbusChartPercentile(Data, 0.25); Median := NimbusChartPercentile(Data, 0.5); Q3 := NimbusChartPercentile(Data, 0.75); CaptionText := S.Name;
      end;
      if not Axis.IsValueValid(Minimum, Range) or not Axis.IsValueValid(Q1, Range) or not Axis.IsValueValid(Median, Range) or not Axis.IsValueValid(Q3, Range) or not Axis.IsValueValid(Maximum, Range) then Continue;
      X := R.Left + Slot * (VisibleIndex + 0.5); Col := SeriesColor(I);
      Y := MapY(Q3, Axis, Range); Zero := MapY(Q1, Axis, Range); Low := MapY(Minimum, Axis, Range); MaxValue := MapY(Maximum, Axis, Range);
      Bounds := Rect(Round(X - BarWidth / 2), Round(Min(Y, Zero)), Round(X + BarWidth / 2), Round(Max(Y, Zero)));
      if Bounds.Height < NimbusScaleValue(4, C.PPI) then Bounds.Bottom := Bounds.Top + NimbusScaleValue(4, C.PPI);
      NewPrimitive(ncpRect, NimbusColorWithAlpha(Col, 75)); A.Bounds := Bounds; A.Hit.Area := nchaSeries; A.Hit.SeriesIndex := I;
      A.Hit.Text := CaptionText + #10 + 'Min: ' + SparklineFormatValue(Minimum, '0.##') + #10 + 'Q1: ' + SparklineFormatValue(Q1, '0.##') + #10 + 'Median: ' + SparklineFormatValue(Median, '0.##') + #10 + 'Q3: ' + SparklineFormatValue(Q3, '0.##') + #10 + 'Max: ' + SparklineFormatValue(Maximum, '0.##'); Add;
      Line(X, MaxValue, X, Y, Col, 1.5); Line(X, Zero, X, Low, Col, 1.5);
      Line(X - BarWidth * 0.35, MaxValue, X + BarWidth * 0.35, MaxValue, Col, 1.5); Line(X - BarWidth * 0.35, Low, X + BarWidth * 0.35, Low, Col, 1.5);
      Y := MapY(Median, Axis, Range); Line(Bounds.Left, Y, Bounds.Right, Y, Fore, 1.8);
      Line(Bounds.Left, Bounds.Top, Bounds.Right, Bounds.Top, Col); Line(Bounds.Right, Bounds.Top, Bounds.Right, Bounds.Bottom, Col);
      Line(Bounds.Right, Bounds.Bottom, Bounds.Left, Bounds.Bottom, Col); Line(Bounds.Left, Bounds.Bottom, Bounds.Left, Bounds.Top, Col);
      if Box.Enabled then for V in Box.Outliers do if Axis.IsValueValid(V, Range) then
      begin Y := MapY(V, Axis, Range); NewPrimitive(ncpEllipse, NimbusColorWithAlpha(Col, 155)); Radius := NimbusScaleValue(3, C.PPI); A.Bounds := Rect(Round(X) - Radius, Round(Y) - Radius, Round(X) + Radius, Round(Y) + Radius); A.Hit.Area := nchaSeries; A.Hit.SeriesIndex := I; A.Hit.YValue := V; A.Hit.Text := CaptionText + ': ' + SparklineFormatValue(V, '0.##'); Add end;
      Text(CaptionText, Rect(Round(X - Slot / 2), R.Bottom + 4, Round(X + Slot / 2), R.Bottom + 24), Muted, [ntfCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix]);
    end;
  end;
  if M.ChartType in [nctGauge, nctRadialBar] then
  begin
    Sweep := M.GaugeSweepAngle; if M.ChartType = nctRadialBar then Sweep := 360;
    Size := Min(R.Width, R.Height * 1.35); if Sweep >= 350 then Size := Min(R.Width, R.Height);
    Size := Max(0, Size - NimbusScaleValue(16, C.PPI)); X := R.CenterPoint.X;
    if Sweep >= 350 then Y := R.CenterPoint.Y else Y := R.Top + Size / 2;
    Bounds := Rect(Round(X - Size / 2), Round(Y - Size / 2), Round(X + Size / 2), Round(Y + Size / 2));
    Minimum := M.GaugeMinimum; Maximum := M.GaugeMaximum;
    if Maximum <= Minimum then begin Minimum := 0; Maximum := 100 end; V := M.GaugeValue; I := -1;
    for J := 0 to M.Series.Count - 1 do if M.Series[J].Visible then
    begin I := J; if (M.Series[J].Points.Count > 0) and SparklineFinite(M.Series[J].Points[0].YValue) then V := M.Series[J].Points[0].YValue; Break end;
    Ratio := 0; if SparklineFinite(V) then Ratio := EnsureRange((V - Minimum) / (Maximum - Minimum), 0.0, 1.0);
    BarWidth := Max(NimbusScaleValue(8, C.PPI), Min(NimbusScaleValue(18, C.PPI), Size * 0.11));
    NewPrimitive(ncpArc, NimbusBlendColor(Border, Back, 115)); A.Bounds := Bounds; A.StartAngle := M.GaugeStartAngle; A.SweepAngle := Sweep; A.Width := BarWidth; Add;
    if M.GaugeShowThresholds then
    begin
      BulletBounds := Bounds; BulletBounds.Inflate(-Round(BarWidth * 0.38 * 1.85), -Round(BarWidth * 0.38 * 1.85));
      Start := M.GaugeStartAngle;
      for J := 0 to 2 do
      begin
        case J of 0: begin Col := NimbusColorWithAlpha(NimbusSuccessColor, 150); Total := Sweep * 0.6 end;
          1: begin Col := NimbusColorWithAlpha(NimbusWarningColor, 130); Total := Sweep * 0.25 end;
          else begin Col := NimbusColorWithAlpha(ChartAccentColor(C), 120); Total := Sweep * 0.15 end end;
        if C.ChartPalette <> nil then
          case J of 0: Col := NimbusColorWithAlpha(ColorToThemeColor(C.ChartPalette.SuccessColor), 150); 1: Col := NimbusColorWithAlpha(ColorToThemeColor(C.ChartPalette.WarningColor), 130) end;
        NewPrimitive(ncpArc, Col); A.Bounds := BulletBounds; A.StartAngle := Start; A.SweepAngle := Total; A.Width := BarWidth * 0.38; Add; Start := Start + Total;
      end;
    end;
    Col := ChartAccentColor(C); if Ratio < 0.65 then Col := NimbusSuccessColor else if Ratio < 0.88 then Col := NimbusWarningColor;
    if C.ChartPalette <> nil then begin if Ratio < 0.65 then Col := ColorToThemeColor(C.ChartPalette.SuccessColor) else if Ratio < 0.88 then Col := ColorToThemeColor(C.ChartPalette.WarningColor) end;
    NewPrimitive(ncpArc, Col); A.Bounds := Bounds; A.StartAngle := M.GaugeStartAngle; A.SweepAngle := Ratio * Sweep * C.AnimationProgress; A.Width := BarWidth;
    A.Hit.Area := nchaSeries; A.Hit.SeriesIndex := I; A.Hit.YValue := V; A.Hit.Text := M.Title + ': ' + SparklineFormatValue(V, '0.##'); Add;
    if M.GaugeShowNeedle and (M.ChartType = nctGauge) then
    begin Mid := DegToRad(M.GaugeStartAngle + Ratio * Sweep * C.AnimationProgress); Line(X, Y, X + Cos(Mid) * Size * 0.38, Y + Sin(Mid) * Size * 0.38, Col, NimbusScaleValue(2, C.PPI)) end;
    CaptionText := M.GaugeCenterLabel; if CaptionText = '' then CaptionText := SparklineFormatValue(V, '0.##') + M.GaugeValueSuffix;
    Text(CaptionText, Rect(R.Left, R.Top + R.Height * 4 div 5, R.Right, R.Bottom), Fore, [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix]);
    if M.ChartType = nctGauge then
    begin
      Text(SparklineFormatValue(Minimum, '0.##'), Rect(R.Left, R.Bottom - 24, R.Left + R.Width div 4, R.Bottom), Muted, [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix]);
      Text(SparklineFormatValue(Maximum, '0.##'), Rect(R.Right - R.Width div 4, R.Bottom - 24, R.Right, R.Bottom), Muted, [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix]);
    end;
  end;
  if M.ChartType = nctHeatmap then
  begin
    Columns := M.HeatmapColumnCount; Rows := M.HeatmapRowCount;
    if Rows <= 0 then Rows := M.Series.Count;
    if Columns <= 0 then for I := 0 to M.Series.Count - 1 do Columns := Max(Columns, M.Series[I].Points.Count);
    Low := M.HeatmapMinimum; MaxValue := M.HeatmapMaximum;
    if M.HeatmapAutoRange then
    begin
      Low := MaxDouble; MaxValue := -MaxDouble;
      for I := 0 to M.Series.Count - 1 do if M.Series[I].Visible then for J := 0 to M.Series[I].Points.Count - 1 do
        if M.Series[I].Points[J].Visible and SparklineFinite(M.Series[I].Points[J].YValue) then
        begin V := M.Series[I].Points[J].YValue; Low := Min(Low, V); MaxValue := Max(MaxValue, V) end;
    end;
    if (Columns > 0) and (Rows > 0) then for Row := 0 to Rows - 1 do for Column := 0 to Columns - 1 do
    begin
      Bounds := Rect(R.Left + R.Width * Column div Columns, R.Top + R.Height * Row div Rows,
        R.Left + R.Width * (Column + 1) div Columns, R.Top + R.Height * (Row + 1) div Rows);
      Bounds.Inflate(-NimbusScaleValue(M.HeatmapCellGap, C.PPI) div 2, -NimbusScaleValue(M.HeatmapCellGap, C.PPI) div 2);
      NewPrimitive(ncpRect, ResolveColor(M.HeatmapEmptyColor, NimbusColorWithAlpha(Border, 70))); A.Bounds := Bounds;
      if M.HeatmapColorPreset <> nhcpTheme then
      begin A.Color := ChartHeatmapColor(C, 0, True); if not C.Enabled then A.Color := NimbusBlendColor(A.Color, Back, 160) end;
      if (Row < M.Series.Count) and M.Series[Row].Visible and (Column < M.Series[Row].Points.Count) then
      begin
        P := M.Series[Row].Points[Column];
        if P.Visible and SparklineFinite(P.YValue) then
        begin
          Ratio := 0.5; if MaxValue > Low then Ratio := EnsureRange((P.YValue - Low) / (MaxValue - Low), 0.0, 1.0);
          A.Color := NimbusBlendColor(ResolveColor(M.HeatmapLowColor, Back), ResolveColor(M.HeatmapHighColor, ChartAccentColor(C)), Round(Ratio * 255));
          if M.HeatmapColorPreset <> nhcpTheme then A.Color := ChartHeatmapColor(C, Ratio);
          if P.Color <> clNone then A.Color := ColorToThemeColor(P.Color);
          if not C.Enabled and ((M.HeatmapColorPreset <> nhcpTheme) or (P.Color <> clNone)) then A.Color := NimbusBlendColor(A.Color, Back, 160);
          PointHit(Row, Column, nchaPoint);
        end;
      end;
      Add;
      if (M.HeatmapShowCellLabels or M.Options.ShowValues) and (A.Hit.PointIndex >= 0) then Text(SparklineFormatValue(A.Hit.YValue, '0.##'), Bounds, Fore, [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix]);
    end;
  end;
  for I := 0 to M.ReferenceLines.Count - 1 do
  begin
    RefLine := M.ReferenceLines[I]; if not RefLine.Visible then Continue;
    Axis := M.YAxis; Range := L.YRange;
    if RefLine.YAxis = ncySecondary then begin Axis := M.SecondaryYAxis; Range := L.SecondaryYRange end;
    Col := ResolveColor(RefLine.Color, ChartAccentColor(C));
    NewPrimitive(ncpLine, Col); A.Width := Max(0.1, RefLine.Width * C.PPI / 96);
    if RefLine.Orientation = ncroVertical then
    begin X := MapX(RefLine.Value); if not SparklineFinite(X) then Continue; A.Points := [TPointF.Create(X, R.Top), TPointF.Create(X, R.Bottom)]; Bounds := Rect(Round(X) + 4, R.Top + 2, R.Right, R.Top + 22) end
    else
    begin Y := MapY(RefLine.Value, Axis, Range); if not SparklineFinite(Y) then Continue; A.Points := [TPointF.Create(R.Left, Y), TPointF.Create(R.Right, Y)]; Bounds := Rect(R.Left + 4, Round(Y) - 22, R.Right - 4, Round(Y) - 2) end;
    A.Hit.Area := nchaReferenceLine; A.Hit.ElementIndex := I; A.Hit.Text := RefLine.Text; Add;
    Text(RefLine.Text, Bounds, Col, [ntfSingleLine, ntfEndEllipsis, ntfNoPrefix]);
  end;
  SetLength(AnnotationOrder, M.Annotations.Count); Placed := nil;
  for I := 0 to M.Annotations.Count - 1 do
  begin
    J := I; while (J > 0) and (M.Annotations[AnnotationOrder[J - 1]].ZIndex > M.Annotations[I].ZIndex) do
    begin AnnotationOrder[J] := AnnotationOrder[J - 1]; Dec(J) end; AnnotationOrder[J] := I;
  end;
  for K := 0 to High(AnnotationOrder) do
  begin
    I := AnnotationOrder[K]; Annotation := M.Annotations[I]; if not Annotation.Visible or (Annotation.Text = '') then Continue;
    Axis := M.YAxis; Range := L.YRange;
    if Annotation.YAxis = ncySecondary then begin Axis := M.SecondaryYAxis; Range := L.SecondaryYRange end;
    X := MapX(Annotation.XValue); Y := MapY(Annotation.YValue, Axis, Range);
    if not SparklineFinite(X) or not SparklineFinite(Y) then Continue; AnchorPoint := TPointF.Create(X, Y);
    X := X + Annotation.OffsetX * C.PPI / 96; Y := Y + Annotation.OffsetY * C.PPI / 96;
    Count := Min(R.Width, Max(40, Round(Length(Annotation.Text) * Abs(C.Font.Height) * 0.6) + 2 * NimbusScaleValue(Annotation.Padding, C.PPI)));
    Bounds := Rect(Round(X), Round(Y), Round(X) + Count, Round(Y) + Abs(C.Font.Height) + 2 * NimbusScaleValue(Annotation.Padding, C.PPI));
    case Annotation.Alignment of ncaaCenter: Bounds.Offset(-Count div 2, 0); ncaaFar: Bounds.Offset(-Count, 0) end;
    if Annotation.AutoArrange then
    begin
      if Bounds.Right > R.Right then Bounds.Offset(R.Right - Bounds.Right, 0);
      if Bounds.Left < R.Left then Bounds.Offset(R.Left - Bounds.Left, 0);
      for J := 0 to Length(Placed) do
      begin
        Overlap := False;
        for Row := 0 to High(Placed) do if not TRect.Intersect(Bounds, Placed[Row]).IsEmpty then begin Overlap := True; Bounds.Offset(0, Placed[Row].Bottom - Bounds.Top + 3) end;
        if not Overlap then Break;
      end;
      if Bounds.Bottom > R.Bottom then Bounds.Offset(0, R.Bottom - Bounds.Bottom);
      if Bounds.Top < R.Top then Bounds.Offset(0, R.Top - Bounds.Top);
    end;
    if Annotation.LeaderLineVisible then Line(AnchorPoint.X, AnchorPoint.Y, Bounds.CenterPoint.X, Bounds.CenterPoint.Y, ResolveColor(Annotation.BorderColor, Border));
    NewPrimitive(ncpRect, ResolveColor(Annotation.BackColor, Back)); A.Bounds := Bounds;
    if Annotation.Selectable then begin A.Hit.Area := nchaAnnotation; A.Hit.ElementIndex := I; A.Hit.Text := Annotation.ToolTipText; if A.Hit.Text = '' then A.Hit.Text := Annotation.Text end; Add;
    SetLength(Placed, Length(Placed) + 1); Placed[High(Placed)] := Bounds;
    Col := ResolveColor(Annotation.BorderColor, Border);
    Line(Bounds.Left, Bounds.Top, Bounds.Right, Bounds.Top, Col); Line(Bounds.Right, Bounds.Top, Bounds.Right, Bounds.Bottom, Col);
    Line(Bounds.Right, Bounds.Bottom, Bounds.Left, Bounds.Bottom, Col); Line(Bounds.Left, Bounds.Bottom, Bounds.Left, Bounds.Top, Col);
    Bounds.Inflate(-NimbusScaleValue(Annotation.Padding, C.PPI), -NimbusScaleValue(Annotation.Padding, C.PPI));
    Text(Annotation.Text, Bounds, ResolveColor(Annotation.ForeColor, Fore), [ntfCenter, ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix]);
  end;
  if not L.LegendBounds.IsEmpty then
  begin
    X := L.LegendBounds.Left + 4; Y := L.LegendBounds.Top + 4;
    LegendSeries := -1; Count := M.Series.Count;
    if M.ChartType in [nctPie, nctDonut] then
    begin
      for I := 0 to M.Series.Count - 1 do if M.Series[I].Visible then begin LegendSeries := I; Count := M.Series[I].Points.Count; Break end;
      if LegendSeries < 0 then Count := 0;
    end;
    for K := 0 to Count - 1 do
    begin
      I := K; LegendPoint := -1;
      if LegendSeries >= 0 then begin I := LegendSeries; LegendPoint := K end;
      S := M.Series[I]; Col := SeriesColor(I); CaptionText := S.Name;
      if LegendPoint >= 0 then
      begin
        P := S.Points[LegendPoint]; CaptionText := P.&Label; if CaptionText = '' then CaptionText := 'Slice ' + IntToStr(LegendPoint + 1);
        Col := ResolveColor(P.Color, NimbusBlendColor(SeriesColor(I), ThemeColor(255, 240, 160, 70), Byte((LegendPoint * 47) mod 230)));
        if not P.Visible then Col := Muted;
      end
      else if not S.Visible then Col := Muted;
      if M.Legend.Position in [nclpLeft, nclpRight] then Bounds := Rect(Round(X), Round(Y), L.LegendBounds.Right, Round(Y) + NimbusScaleValue(24, C.PPI))
      else Bounds := Rect(Round(X), Round(Y), Min(L.LegendBounds.Right, Round(X) + NimbusScaleValue(Max(60, M.Legend.MaximumItemWidth), C.PPI)), Round(Y) + NimbusScaleValue(24, C.PPI));
      if Bounds.Width < NimbusScaleValue(60, C.PPI) then
      begin X := L.LegendBounds.Left + 4; Y := Y + NimbusScaleValue(24, C.PPI); Bounds := Rect(Round(X), Round(Y), Min(L.LegendBounds.Right, Round(X) + NimbusScaleValue(Max(60, M.Legend.MaximumItemWidth), C.PPI)), Round(Y) + NimbusScaleValue(24, C.PPI)) end;
      if Bounds.Bottom > L.LegendBounds.Bottom then Break;
      if M.Legend.ShowSeriesMarkers then
      begin
        NewPrimitive(ncpRect, Col); A.Bounds := Rect(Bounds.Left, Bounds.Top + 6, Bounds.Left + 10, Bounds.Top + 16);
        A.Hit.Area := nchaLegend; A.Hit.SeriesIndex := I; A.Hit.PointIndex := LegendPoint; A.Hit.Text := CaptionText; Add;
      end;
      NewPrimitive(ncpText, Col); A.Bounds := Bounds; Inc(A.Bounds.Left, 16); A.Text := CaptionText; A.TextFlags := [ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix];
      A.Hit.Area := nchaLegend; A.Hit.SeriesIndex := I; A.Hit.PointIndex := LegendPoint; A.Hit.Text := CaptionText; Add;
      if M.Legend.Position in [nclpLeft, nclpRight] then Y := Bounds.Bottom else X := Bounds.Right;
    end;
  end;
end;

function TNimbusChartRenderer.BuildStyled(const C: TNimbusChartRenderContext; const L: TNimbusChartLayout): TArray<TNimbusChartPrimitive>;
var Items: TArray<TNimbusChartPrimitive>; List: TList<TNimbusChartPrimitive>; A, Glow: TNimbusChartPrimitive;
  I, J, Steps: Integer; DPI, Angle, Radius: Single; Center: TPoint; Colors: TArray<TColor>;
  function IsDataColor: Boolean;
  var Color: TColor;
  begin
    Result := A.Hit.Area in [nchaPoint, nchaSeries, nchaSegment];
    if Result or (C.ChartPalette = nil) then Exit;
    Color := ThemeColorToColor(A.Color);
    Result := (Color = C.ChartPalette.AccentColor) or (Color = C.ChartPalette.SuccessColor) or
      (Color = C.ChartPalette.WarningColor) or (Color = C.ChartPalette.ErrorColor);
    if not Result then for Color in Colors do if ColorToThemeColor(Color) = A.Color then Exit(True);
  end;
begin
  Items := Build(C, L);
  if not C.ShowGlow then Exit(Items);
  List := TList<TNimbusChartPrimitive>.Create;
  try
    DPI := Max(1, C.PPI) / 96;
    if C.ChartPalette <> nil then Colors := C.ChartPalette.Colors;
    for A in Items do
    begin
      if (A.Kind in [ncpLine, ncpArc, ncpRect, ncpEllipse, ncpOutlineRect, ncpOutlineEllipse, ncpPolygon, ncpSector]) and IsDataColor and
        ((Cardinal(A.Color) shr 24) >= 160) then
      begin
        Glow := A; Glow.SuppressHighlight := True;
        if Glow.Kind = ncpRect then Glow.Kind := ncpOutlineRect;
        if Glow.Kind = ncpEllipse then Glow.Kind := ncpOutlineEllipse;
        if Glow.Kind = ncpPolygon then
        begin
          Glow.Kind := ncpLine; Glow.Points := Copy(A.Points);
          SetLength(Glow.Points, Length(A.Points) + 1);
          if Length(A.Points) > 0 then Glow.Points[High(Glow.Points)] := A.Points[0];
        end;
        if Glow.Kind = ncpSector then
        begin
          Glow.Kind := ncpLine; Steps := Max(2, Ceil(Abs(A.SweepAngle) / 3));
          Center := A.Bounds.CenterPoint; Radius := A.Bounds.Width / 2;
          SetLength(Glow.Points, (Steps + 1) * 2 + 1);
          for J := 0 to Steps do
          begin
            Angle := DegToRad(A.StartAngle + A.SweepAngle * J / Steps);
            Glow.Points[J] := TPointF.Create(Center.X + Cos(Angle) * Radius, Center.Y + Sin(Angle) * Radius);
            Angle := DegToRad(A.StartAngle + A.SweepAngle * (Steps - J) / Steps);
            Glow.Points[Steps + 1 + J] := TPointF.Create(Center.X + Cos(Angle) * A.InnerRadius, Center.Y + Sin(Angle) * A.InnerRadius);
          end;
          Glow.Points[High(Glow.Points)] := Glow.Points[0];
        end;
        if C.Model.Options.ClipToPlotArea then
        begin
          if Glow.UseClip then IntersectRect(Glow.ClipBounds, Glow.ClipBounds, L.PlotArea) else Glow.ClipBounds := L.PlotArea;
          Glow.UseClip := True;
        end;
        Glow.Hit := TNimbusChartHit.None;
        for I := 3 downto 1 do
        begin
          Glow.Width := Max(DPI, A.Width) + I * 2.5 * DPI;
          Glow.Color := NimbusColorWithAlpha(A.Color, 12 + (3 - I) * 12);
          List.Add(Glow);
        end;
      end;
      List.Add(A);
    end;
    Result := List.ToArray;
  finally List.Free end;
end;

procedure TNimbusChartRenderer.Render(const Canvas: INimbusRenderCanvas; const C: TNimbusChartRenderContext);
var L: TNimbusChartLayout; Items: TArray<TNimbusChartPrimitive>; A: TNimbusChartPrimitive; Inner: TRect; Back, Col: TThemeColor; Corner: Single; Context: TNimbusChartRenderContext; TextFont: TFont;
  procedure Highlight;
  var Points: TArray<TPointF>; Glow: TThemeColor; DPI, BaseWidth, Angle, Radius, CX, CY: Double; I, Steps: Integer;
    procedure Contour(const Color: TThemeColor; const Width: Single);
    begin
      case A.Kind of
        ncpRect, ncpOutlineRect: Canvas.DrawRoundedRectangle(Color, A.Bounds, Max(0, Round(Corner)), Width);
        ncpEllipse, ncpOutlineEllipse: Canvas.DrawEllipse(Color, A.Bounds, Width);
        ncpLine: Canvas.DrawPolyline(Color, A.Points, Width);
        ncpArc: Canvas.DrawArc(Color, A.Bounds, A.StartAngle, A.SweepAngle, Width);
        ncpPolygon, ncpSector: Canvas.DrawPolyline(Color, Points, Width);
      end;
    end;
  begin
    if not C.Enabled or A.SuppressHighlight or not (A.Hit.Area in [nchaPoint, nchaSegment, nchaSeries, nchaLegend]) or
      not (A.Hit.SameElement(C.Hovered) or A.Hit.SameElement(C.Selected)) then Exit;
    if not (A.Kind in [ncpRect, ncpOutlineRect, ncpEllipse, ncpOutlineEllipse, ncpLine, ncpArc, ncpPolygon, ncpSector]) then Exit;
    DPI := Max(1, C.PPI) / 96; BaseWidth := 0; if A.Kind in [ncpLine, ncpArc] then BaseWidth := A.Width;
    if A.Kind = ncpPolygon then
    begin Points := Copy(A.Points); if Length(Points) < 3 then Exit; SetLength(Points, Length(Points) + 1); Points[High(Points)] := Points[0] end;
    if A.Kind = ncpSector then
    begin
      Steps := Max(2, Ceil(Abs(A.SweepAngle) / 3)); CX := A.Bounds.CenterPoint.X; CY := A.Bounds.CenterPoint.Y; Radius := A.Bounds.Width / 2;
      SetLength(Points, (Steps + 1) * 2 + 1);
      for I := 0 to Steps do
      begin
        Angle := DegToRad(A.StartAngle + A.SweepAngle * I / Steps); Points[I] := TPointF.Create(CX + Cos(Angle) * Radius, CY + Sin(Angle) * Radius);
        Angle := DegToRad(A.StartAngle + A.SweepAngle * (Steps - I) / Steps); Points[Steps + 1 + I] := TPointF.Create(CX + Cos(Angle) * A.InnerRadius, CY + Sin(Angle) * A.InnerRadius);
      end;
      Points[High(Points)] := Points[0];
    end;
    Glow := NimbusBlendColor(A.Color, ChartAccentColor(C), 120);
    Contour(NimbusColorWithAlpha(Glow, 12), BaseWidth + 6 * DPI);
    Contour(NimbusColorWithAlpha(Glow, 24), BaseWidth + 4 * DPI);
    Contour(NimbusColorWithAlpha(Glow, 42), BaseWidth + 2 * DPI);
    Contour(NimbusColorWithAlpha(NimbusBlendColor(Glow, ChartForeColor(C), 45), 200), Max(0.75, DPI));
  end;
begin
  if (Canvas = nil) or (C.Model = nil) or (C.Font = nil) or C.Bounds.IsEmpty then Exit;
  Context := C; Context.MeasureCanvas := Canvas; L := Arrange(Context); Items := BuildStyled(Context, L); Back := ChartBackColor(C);
  Canvas.Clear(Back, C.Bounds);
  if C.ChartPalette <> nil then Canvas.FillRectangle(ColorToThemeColor(C.ChartPalette.PlotBackColor), L.PlotArea);
  TextFont := TFont.Create;
  try
  Canvas.PushClip(C.Bounds);
  try
    for A in Items do
    begin
      if A.Kind in [ncpHitBounds, ncpHitArc] then Continue;
      Col := A.Color; Corner := NimbusScaleValue(C.Model.Options.CornerRadius, C.PPI);
      if A.UseCornerRadius then Corner := A.CornerRadius;

      if C.Model.Options.ClipToPlotArea and (A.Hit.Area in [nchaPoint, nchaSeries, nchaSegment, nchaReferenceLine, nchaReferenceRange]) then Canvas.PushClip(L.PlotArea);
      if A.UseClip then Canvas.PushClip(A.ClipBounds);
      try
      case A.Kind of
        ncpArc: Canvas.DrawArc(Col, A.Bounds, A.StartAngle, A.SweepAngle, A.Width);
        ncpLine: Canvas.DrawPolyline(Col, A.Points, A.Width);
        ncpRect: Canvas.FillRoundedRectangle(Col, A.Bounds, Max(0, Round(Corner)));
        ncpOutlineRect: Canvas.DrawRoundedRectangle(Col, A.Bounds, Max(0, Round(Corner)), A.Width);
        ncpEllipse: Canvas.FillEllipse(Col, A.Bounds);
        ncpOutlineEllipse: Canvas.DrawEllipse(Col, A.Bounds, A.Width);
        ncpPolygon: Canvas.FillPolygonF(Col, A.Points);
        ncpText:
          begin
            TextFont.Assign(C.Font);
            if A.UseFont then begin TextFont.Height := A.FontHeight; TextFont.Style := A.FontStyle end;
            Canvas.DrawText(A.Text, TextFont, Col, A.Bounds, A.TextFlags);
          end;
        ncpSector:
          begin
            Canvas.FillPie(Col, A.Bounds, A.StartAngle, A.SweepAngle);
            if A.InnerRadius > 0 then
            begin
              Inner := Rect(Round(A.Bounds.CenterPoint.X - A.InnerRadius), Round(A.Bounds.CenterPoint.Y - A.InnerRadius),
                Round(A.Bounds.CenterPoint.X + A.InnerRadius), Round(A.Bounds.CenterPoint.Y + A.InnerRadius));
              Canvas.FillEllipse(Back, Inner);
            end;
          end;
      end;
      Highlight;
      finally
        if A.UseClip then Canvas.PopClip;
        if C.Model.Options.ClipToPlotArea and (A.Hit.Area in [nchaPoint, nchaSeries, nchaSegment, nchaReferenceLine, nchaReferenceRange]) then Canvas.PopClip end;
    end;
    if C.Model.Options.ShowBorder then Canvas.DrawRectangle(ChartBorderColor(C), Rect(C.Bounds.Left, C.Bounds.Top, C.Bounds.Right - 1, C.Bounds.Bottom - 1));
    if C.Model.Options.ShowPlotBorder then Canvas.DrawRectangle(ChartBorderColor(C), L.PlotArea);
  finally Canvas.PopClip end;
  finally TextFont.Free end;
end;

function TNimbusChartRenderer.FindAdjacentHit(const C: TNimbusChartRenderContext; const Current: TNimbusChartHit; const Direction: Integer): TNimbusChartHit;
var Items: TArray<TNimbusChartPrimitive>; Hits: TList<TNimbusChartHit>; A: TNimbusChartPrimitive; H: TNimbusChartHit; I, Index: Integer; Duplicate: Boolean;
begin
  Result := TNimbusChartHit.None; if (C.Model = nil) or (C.Font = nil) then Exit;
  Hits := TList<TNimbusChartHit>.Create;
  try
    Items := Build(C, Arrange(C)); Index := -1;
    for A in Items do
    begin
      if not (A.Hit.Area in [nchaPoint, nchaSegment, nchaSeries]) then Continue; Duplicate := False;
      for H in Hits do if H.SameElement(A.Hit) then begin Duplicate := True; Break end;
      if Duplicate then Continue; H := A.Hit;
      if Length(A.Points) > 0 then H.Location := A.Points[Length(A.Points) div 2] else H.Location := TPointF.Create(A.Bounds.CenterPoint.X, A.Bounds.CenterPoint.Y);
      if H.SameElement(Current) then Index := Hits.Count; Hits.Add(H);
    end;
    if Hits.Count = 0 then Exit; I := Index + Direction;
    if Index < 0 then begin I := 0; if Direction < 0 then I := Hits.Count - 1 end;
    if (I >= 0) and (I < Hits.Count) then Result := Hits[I] else Result := Current;
  finally Hits.Free end;
end;

function TNimbusChartRenderer.FindSeriesHit(const C: TNimbusChartRenderContext; const SeriesIndex: Integer): TNimbusChartHit;
var Items: TArray<TNimbusChartPrimitive>; I: Integer;
begin
  Result := TNimbusChartHit.None; if (C.Model = nil) or (C.Font = nil) then Exit;
  Items := Build(C, Arrange(C));
  for I := High(Items) downto 0 do
    if (Items[I].Hit.Area = nchaSeries) and (Items[I].Hit.SeriesIndex = SeriesIndex) then
    begin Result := Items[I].Hit; Result.Location := TPointF.Create(Items[I].Bounds.CenterPoint.X, Items[I].Bounds.CenterPoint.Y); Exit end;
end;

function TNimbusChartRenderer.HitTest(const C: TNimbusChartRenderContext; const Location: TPointF): TNimbusChartHit;
var L: TNimbusChartLayout; Items: TArray<TNimbusChartPrimitive>; A: TNimbusChartPrimitive;
  I, J, K: Integer; Contains: Boolean; DX, DY, Radius, Angle, Delta, LengthSquared, T, Distance: Double;
begin
  Result := TNimbusChartHit.None; Result.Location := Location;
  if (C.Model = nil) or (C.Font = nil) then Exit;
  L := Arrange(C); Items := Build(C, L);
  for I := High(Items) downto 0 do
  begin
    A := Items[I]; if A.Hit.Area = nchaNone then Continue; Contains := False;
    if A.UseClip and not A.ClipBounds.Contains(Point(Round(Location.X), Round(Location.Y))) then Continue;
    if C.Model.Options.ClipToPlotArea and (A.Hit.Area in [nchaPoint, nchaSeries, nchaSegment, nchaReferenceLine, nchaReferenceRange]) and not L.PlotArea.Contains(Point(Round(Location.X), Round(Location.Y))) then Continue;
    case A.Kind of
      ncpRect, ncpText, ncpHitBounds, ncpOutlineRect: Contains := A.Bounds.Contains(Point(Round(Location.X), Round(Location.Y)));
      ncpEllipse, ncpOutlineEllipse:
        begin
          DX := Location.X - A.Bounds.CenterPoint.X; DY := Location.Y - A.Bounds.CenterPoint.Y;
          Contains := Sqr(DX) + Sqr(DY) <= Sqr(Max(8.0 * C.PPI / 96, A.Bounds.Width / 2));
        end;
      ncpLine:
        if Length(A.Points) >= 2 then
        begin
          for J := 1 to High(A.Points) do
          begin
            DX := A.Points[J].X - A.Points[J - 1].X; DY := A.Points[J].Y - A.Points[J - 1].Y;
            LengthSquared := Sqr(DX) + Sqr(DY); T := 0;
            if LengthSquared > 0 then T := EnsureRange(((Location.X - A.Points[J - 1].X) * DX + (Location.Y - A.Points[J - 1].Y) * DY) / LengthSquared, 0.0, 1.0);
            Distance := Sqr(Location.X - A.Points[J - 1].X - T * DX) + Sqr(Location.Y - A.Points[J - 1].Y - T * DY);
            Contains := Distance <= Sqr(Max(5.0 * C.PPI / 96, A.Width / 2));
            if Contains then Break;
          end;
        end;
      ncpPolygon:
        begin
          K := High(A.Points);
          for J := 0 to High(A.Points) do
          begin
            if ((A.Points[J].Y > Location.Y) <> (A.Points[K].Y > Location.Y)) and
              (Location.X < (A.Points[K].X - A.Points[J].X) * (Location.Y - A.Points[J].Y) / (A.Points[K].Y - A.Points[J].Y) + A.Points[J].X) then Contains := not Contains;
            K := J;
          end;
        end;
      ncpArc, ncpSector, ncpHitArc:
        begin
          DX := Location.X - A.Bounds.CenterPoint.X; DY := Location.Y - A.Bounds.CenterPoint.Y;
          Radius := Sqrt(Sqr(DX) + Sqr(DY)); Angle := RadToDeg(ArcTan2(DY, DX));
          Delta := Angle - A.StartAngle; while Delta < 0 do Delta := Delta + 360; while Delta >= 360 do Delta := Delta - 360;
          if A.Kind in [ncpArc, ncpHitArc] then Contains := (Abs(Radius - A.Bounds.Width / 2) <= Max(5, A.Width / 2)) and (Delta <= A.SweepAngle)
          else Contains := (Radius <= A.Bounds.Width / 2) and (Radius >= A.InnerRadius) and (Delta <= A.SweepAngle);
        end;
    end;
    if Contains then begin Result := A.Hit; Result.Location := Location; Exit end;
  end;
  if L.PlotArea.Contains(Point(Round(Location.X), Round(Location.Y))) then Result.Area := nchaPlotArea;
end;

function TNimbusChartRenderer.ExportSvg(const C: TNimbusChartRenderContext): string;
var L: TNimbusChartLayout; Items: TArray<TNimbusChartPrimitive>; A: TNimbusChartPrimitive;
  B: TStringBuilder; I, J: Integer; D, Points, Attributes, Anchor, Weight, Style: string;
  CX, CY, RX, RY, Angle, X, Y, TX, TY, Corner, FontHeight: Double; FontStyle: TFontStyles;
  function N(const V: Double): string;
  begin Result := FloatToStr(V, TFormatSettings.Invariant) end;
  function Escape(const V: string): string;
  begin
    Result := StringReplace(V, '&', '&amp;', [rfReplaceAll]);
    Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll]); Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll]);
    Result := StringReplace(Result, '"', '&quot;', [rfReplaceAll]); Result := StringReplace(Result, #39, '&apos;', [rfReplaceAll]);
  end;
  function Color(const V: TThemeColor; const Stroke: Boolean = False): string;
  var Key: string;
  begin
    Key := 'fill'; if Stroke then Key := 'stroke';
    Result := ' ' + Key + '="#' + IntToHex(Cardinal(V) and $FFFFFF, 6) + '" ' + Key + '-opacity="' + N((Cardinal(V) shr 24) / 255) + '"';
  end;
  function Rectangle(const R: TRect): string;
  begin Result := ' x="' + N(R.Left) + '" y="' + N(R.Top) + '" width="' + N(Max(0, R.Width)) + '" height="' + N(Max(0, R.Height)) + '"' end;
  procedure Arc(const RadiusX, RadiusY, Start, Sweep: Double; const Reverse: Boolean);
  var K, Count: Integer; Ang, PX, PY: Double; Flag: string;
  begin
    Count := Max(1, Ceil(Abs(Sweep) / 170)); Flag := '1'; if Reverse then Flag := '0';
    for K := 1 to Count do
    begin
      Ang := DegToRad(Start + Sweep * K / Count); PX := CX + Cos(Ang) * RadiusX; PY := CY + Sin(Ang) * RadiusY;
      D := D + ' A ' + N(RadiusX) + ' ' + N(RadiusY) + ' 0 0 ' + Flag + ' ' + N(PX) + ' ' + N(PY);
    end;
  end;
begin
  if (C.Model = nil) or (C.Font = nil) then raise EArgumentNilException.Create('Chart model and font are required');
  L := Arrange(C); Items := BuildStyled(C, L); B := TStringBuilder.Create;
  try
    B.Append('<svg xmlns="http://www.w3.org/2000/svg" width="').Append(C.Bounds.Width).Append('" height="').Append(C.Bounds.Height);
    B.Append('" viewBox="').Append(N(C.Bounds.Left)).Append(' ').Append(N(C.Bounds.Top)).Append(' ').Append(C.Bounds.Width).Append(' ').Append(C.Bounds.Height).Append('">');
    B.Append('<defs><clipPath id="chart"><rect').Append(Rectangle(C.Bounds)).Append('/></clipPath><clipPath id="plot"><rect').Append(Rectangle(L.PlotArea)).Append('/></clipPath></defs>');
    B.Append('<defs>');
    for I := 0 to High(Items) do
      if Items[I].UseClip then B.Append('<clipPath id="item').Append(I).Append('"><rect').Append(Rectangle(Items[I].ClipBounds)).Append('/></clipPath>');
    B.Append('</defs>');
    B.Append('<rect').Append(Rectangle(C.Bounds)).Append(Color(ChartBackColor(C))).Append('/><g clip-path="url(#chart)">');
    if C.ChartPalette <> nil then B.Append('<rect').Append(Rectangle(L.PlotArea)).Append(Color(ColorToThemeColor(C.ChartPalette.PlotBackColor))).Append('/>');
    for I := 0 to High(Items) do
    begin
      A := Items[I]; if A.Kind in [ncpHitBounds, ncpHitArc] then Continue;
      Corner := NimbusScaleValue(C.Model.Options.CornerRadius, C.PPI); if A.UseCornerRadius then Corner := A.CornerRadius;
      if (A.Kind = ncpSector) and (Abs(A.SweepAngle) <= 0) then Continue; Attributes := Color(A.Color);
      if C.Model.Options.ClipToPlotArea and (A.Hit.Area in [nchaPoint, nchaSeries, nchaSegment, nchaReferenceLine, nchaReferenceRange]) then B.Append('<g clip-path="url(#plot)">');
      if A.UseClip then B.Append('<g clip-path="url(#item').Append(I).Append(')">');
      case A.Kind of
        ncpOutlineRect: B.Append('<rect').Append(Rectangle(A.Bounds)).Append(' rx="').Append(N(Corner)).Append('" fill="none" stroke-width="').Append(N(A.Width)).Append('"').Append(Color(A.Color, True)).Append('/>');
        ncpRect: B.Append('<rect').Append(Rectangle(A.Bounds)).Append(' rx="').Append(N(Corner)).Append('"').Append(Attributes).Append('/>');
        ncpEllipse: B.Append('<ellipse cx="').Append(N(A.Bounds.CenterPoint.X)).Append('" cy="').Append(N(A.Bounds.CenterPoint.Y)).Append('" rx="').Append(N(A.Bounds.Width / 2)).Append('" ry="').Append(N(A.Bounds.Height / 2)).Append('"').Append(Attributes).Append('/>');
        ncpOutlineEllipse: B.Append('<ellipse cx="').Append(N(A.Bounds.CenterPoint.X)).Append('" cy="').Append(N(A.Bounds.CenterPoint.Y)).Append('" rx="').Append(N(A.Bounds.Width / 2)).Append('" ry="').Append(N(A.Bounds.Height / 2)).Append('" fill="none" stroke-width="').Append(N(A.Width)).Append('"').Append(Color(A.Color, True)).Append('/>');
        ncpPolygon, ncpLine:
          begin
            Points := ''; for J := 0 to High(A.Points) do Points := Points + N(A.Points[J].X) + ',' + N(A.Points[J].Y) + ' ';
            if A.Kind = ncpPolygon then B.Append('<polygon points="').Append(Points).Append('"').Append(Attributes).Append('/>')
            else B.Append('<polyline points="').Append(Points).Append('" fill="none" stroke-linecap="round" stroke-linejoin="round" stroke-width="').Append(N(A.Width)).Append('"').Append(Color(A.Color, True)).Append('/>');
          end;
        ncpArc:
          begin
            CX := A.Bounds.CenterPoint.X; CY := A.Bounds.CenterPoint.Y; RX := A.Bounds.Width / 2; RY := A.Bounds.Height / 2;
            Angle := DegToRad(A.StartAngle); D := 'M ' + N(CX + Cos(Angle) * RX) + ' ' + N(CY + Sin(Angle) * RY);
            Arc(RX, RY, A.StartAngle, A.SweepAngle, False);
            B.Append('<path d="').Append(D).Append('" fill="none" stroke-width="').Append(N(A.Width)).Append('"').Append(Color(A.Color, True)).Append('/>');
          end;
        ncpSector:
          begin
            if Abs(A.SweepAngle) <= 0 then Continue;
            CX := A.Bounds.CenterPoint.X; CY := A.Bounds.CenterPoint.Y; RX := A.Bounds.Width / 2; RY := A.Bounds.Height / 2;
            Angle := DegToRad(A.StartAngle); X := CX + Cos(Angle) * RX; Y := CY + Sin(Angle) * RY;
            D := 'M ' + N(X) + ' ' + N(Y); Arc(RX, RY, A.StartAngle, A.SweepAngle, False);
            if A.InnerRadius > 0 then
            begin
              Angle := DegToRad(A.StartAngle + A.SweepAngle); X := CX + Cos(Angle) * A.InnerRadius; Y := CY + Sin(Angle) * A.InnerRadius;
              D := D + ' L ' + N(X) + ' ' + N(Y); Arc(A.InnerRadius, A.InnerRadius, A.StartAngle + A.SweepAngle, -A.SweepAngle, True);
            end
            else D := D + ' L ' + N(CX) + ' ' + N(CY);
            B.Append('<path d="').Append(D).Append(' Z"').Append(Attributes).Append('/>');
          end;
        ncpText:
          begin
            Anchor := 'start'; TX := A.Bounds.Left;
            if ntfCenter in A.TextFlags then begin Anchor := 'middle'; TX := A.Bounds.CenterPoint.X end
            else if ntfRight in A.TextFlags then begin Anchor := 'end'; TX := A.Bounds.Right end;
            FontHeight := Abs(C.Font.Height); FontStyle := C.Font.Style;
            if A.UseFont then begin FontHeight := Abs(A.FontHeight); FontStyle := A.FontStyle end;
            TY := A.Bounds.Top + FontHeight; if ntfVCenter in A.TextFlags then TY := A.Bounds.CenterPoint.Y + FontHeight * 0.35;
            Weight := 'normal'; if fsBold in FontStyle then Weight := 'bold'; Style := 'normal'; if fsItalic in FontStyle then Style := 'italic';
            B.Append('<text x="').Append(N(TX)).Append('" y="').Append(N(TY)).Append('" text-anchor="').Append(Anchor);
            B.Append('" font-family="').Append(Escape(C.Font.Name)).Append('" font-size="').Append(N(FontHeight));
            B.Append('" font-weight="').Append(Weight).Append('" font-style="').Append(Style).Append('"').Append(Attributes).Append('>').Append(Escape(A.Text)).Append('</text>');
          end;
      end;
      if A.UseClip then B.Append('</g>');
      if C.Model.Options.ClipToPlotArea and (A.Hit.Area in [nchaPoint, nchaSeries, nchaSegment, nchaReferenceLine, nchaReferenceRange]) then B.Append('</g>');
    end;
    if C.Model.Options.ShowBorder then B.Append('<rect').Append(Rectangle(C.Bounds)).Append(' fill="none" stroke-width="1"').Append(Color(ChartBorderColor(C), True)).Append('/>');
    if C.Model.Options.ShowPlotBorder then B.Append('<rect').Append(Rectangle(L.PlotArea)).Append(' fill="none" stroke-width="1"').Append(Color(ChartBorderColor(C), True)).Append('/>');
    B.Append('</g></svg>'); Result := B.ToString;
  finally B.Free end;
end;

end.

unit NimbusFinancialChecks;

interface

procedure RunNimbusFinancialChecks;

implementation

uses Winapi.Windows, Winapi.Messages, System.Classes, System.SysUtils, System.Math, System.Types, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  NimbusForms.Charts.Financial.Types, NimbusForms.Charts.Financial.Indicators,
  NimbusForms.Charts.Financial.Data, NimbusForms.Charts.Financial.Viewport,
  NimbusForms.Charts.Financial.Workspace, NimbusForms.Charts.Financial.Business.Types,
  NimbusForms.Charts.Financial.Palette, NimbusForms.Charts.Financial.Profiles,
  NimbusForms.Controls.FinancialBusinessChart, NimbusForms.Rendering.FinancialBusiness,
  NimbusForms.Rendering.Charts, NimbusForms.Theming.Palette, NimbusForms.Theming.PresetFactory, NimbusForms.Controls.VScrollBar,
  NimbusForms.Rendering.Canvas;

type
  TFinancialRendererProbe = class(TNimbusFinancialBusinessRenderer)
  public
    function Primitives(const C: TNimbusChartRenderContext): TArray<TNimbusChartPrimitive>;
  end;
  TFinancialProbe = class(TThemedFinancialBusinessChart)
  protected
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    InjectCaptureLoss: Boolean;
    SettingsRequests: Integer;
    RowClicks, LocalRowClicks, RowDoubleClicks, RowHovers, RowContexts, LegacyRowClicks, GlobalActions, LocalActions: Integer;
    ClearRowsInLocal: Boolean;
    LastRow: TNimbusFinancialRowEventInfo;
    LastAction: TNimbusFinancialPanelActionInfo;
    function Context(const Width, Height: Integer): TNimbusChartRenderContext;
    procedure PressAt(const P: TPoint);
    procedure ReleaseAt(const P: TPoint);
    procedure HoverAt(const P: TPoint; const Dragging: Boolean = False);
    procedure SettingsRequested(Sender: TObject; Panel: TNimbusFinancialPanel);
    procedure RowEvent(Sender: TObject; const Info: TNimbusFinancialRowEventInfo);
    procedure LocalRowEvent(Sender: TObject; const Info: TNimbusFinancialRowEventInfo);
    procedure ActionEvent(Sender: TObject; const Info: TNimbusFinancialPanelActionInfo);
    procedure LocalActionEvent(Sender: TObject; const Info: TNimbusFinancialPanelActionInfo);
    procedure LegacyRowEvent(Sender: TObject; const Hit: TNimbusChartHit);
    procedure RightClickAt(const P: TPoint);
    procedure DoubleClickAt(const P: TPoint);
    procedure PressKey(const Code: Word; const Shift: TShiftState = []);
  end;
  TFinancialScrollWatch = class
  private
    FBar: TThemedVScrollBar;
    FPrevious: TWndMethod;
    procedure WindowProc(var Message: TMessage);
  public
    VisibilityChanges: Integer;
    constructor Create(Bar: TThemedVScrollBar);
    destructor Destroy; override;
  end;

function TFinancialProbe.Context(const Width, Height: Integer): TNimbusChartRenderContext;
begin Result := CreateRenderContext(Rect(0, 0, Width, Height)) end;
function TFinancialRendererProbe.Primitives(const C: TNimbusChartRenderContext): TArray<TNimbusChartPrimitive>;
begin Result := Build(C, Arrange(C)) end;

procedure TFinancialProbe.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if InjectCaptureLoss then Perform(WM_CAPTURECHANGED, 0, 0);
  inherited;
end;
procedure TFinancialProbe.PressAt(const P: TPoint);
begin Perform(WM_LBUTTONDOWN, MK_LBUTTON, LPARAM((P.X and $FFFF) or ((P.Y and $FFFF) shl 16))) end;
procedure TFinancialProbe.ReleaseAt(const P: TPoint);
begin Perform(WM_LBUTTONUP, 0, LPARAM((P.X and $FFFF) or ((P.Y and $FFFF) shl 16))) end;
procedure TFinancialProbe.HoverAt(const P: TPoint; const Dragging: Boolean);
begin if Dragging then MouseMove([ssLeft], P.X, P.Y) else MouseMove([], P.X, P.Y) end;
procedure TFinancialProbe.SettingsRequested(Sender: TObject; Panel: TNimbusFinancialPanel);
begin Inc(SettingsRequests) end;
procedure TFinancialProbe.RowEvent(Sender: TObject; const Info: TNimbusFinancialRowEventInfo);
begin
  LastRow := Info;
  case Info.Action of nfraClicked: Inc(RowClicks); nfraDoubleClicked: Inc(RowDoubleClicks);
    nfraHovered: Inc(RowHovers); nfraContextMenu: Inc(RowContexts) end;
end;
procedure TFinancialProbe.LocalRowEvent(Sender: TObject; const Info: TNimbusFinancialRowEventInfo);
begin Inc(LocalRowClicks); if ClearRowsInLocal then SidePanels.FindByKey(Info.PanelKey).Items.Clear end;
procedure TFinancialProbe.ActionEvent(Sender: TObject; const Info: TNimbusFinancialPanelActionInfo);
begin Inc(GlobalActions); LastAction := Info end;
procedure TFinancialProbe.LocalActionEvent(Sender: TObject; const Info: TNimbusFinancialPanelActionInfo);
begin Inc(LocalActions) end;
procedure TFinancialProbe.LegacyRowEvent(Sender: TObject; const Hit: TNimbusChartHit);
begin Inc(LegacyRowClicks) end;
procedure TFinancialProbe.RightClickAt(const P: TPoint);
begin
  Perform(WM_RBUTTONDOWN, MK_RBUTTON, LPARAM((P.X and $FFFF) or ((P.Y and $FFFF) shl 16)));
  Perform(WM_RBUTTONUP, 0, LPARAM((P.X and $FFFF) or ((P.Y and $FFFF) shl 16)));
end;
procedure TFinancialProbe.DoubleClickAt(const P: TPoint);
begin Perform(WM_LBUTTONDBLCLK, MK_LBUTTON, LPARAM((P.X and $FFFF) or ((P.Y and $FFFF) shl 16))); ReleaseAt(P) end;
procedure TFinancialProbe.PressKey(const Code: Word; const Shift: TShiftState);
var Key: Word;
begin Key := Code; KeyDown(Key, Shift) end;

constructor TFinancialScrollWatch.Create(Bar: TThemedVScrollBar);
begin inherited Create; FBar := Bar; FPrevious := Bar.WindowProc; Bar.WindowProc := WindowProc end;
destructor TFinancialScrollWatch.Destroy;
begin FBar.WindowProc := FPrevious; inherited end;
procedure TFinancialScrollWatch.WindowProc(var Message: TMessage);
begin if Message.Msg = CM_VISIBLECHANGED then Inc(VisibilityChanges); FPrevious(Message) end;

procedure Check(const Condition: Boolean; const Message: string);
begin if not Condition then raise Exception.Create('Financial chart: ' + Message) end;

procedure Near(const Actual, Expected: Double; const Message: string);
begin Check(not IsNan(Actual) and (Abs(Actual - Expected) < 1E-8), Message) end;

procedure Calculations;
var Values, Ema, Sma: TNimbusFinancialValues; Bands: TNimbusFinancialBollingerValues;
  Rsi: TNimbusFinancialRsiValues; Macd: TNimbusFinancialMacdValues;
  Data: TNimbusFinancialDataPointCollection; Candles: TNimbusFinancialCandleArray;
  Stoch: TNimbusFinancialStochasticValues; Atr: TNimbusFinancialAtrValues; Periods: TArray<Integer>;
begin
  Values := [1, 2, 3, 4, 5, 6, 7, 8]; Ema := TNimbusFinancialIndicators.Ema(Values, 3);
  Check(IsNan(Ema[0]) and IsNan(Ema[1]), 'EMA warmup'); Near(Ema[2], 2, 'EMA seed'); Near(Ema[7], 7, 'EMA recurrence');
  Sma := TNimbusFinancialIndicators.Sma([1, 2, NaN, 4, 5, 6], 3);
  Check(IsNan(Sma[4]), 'SMA requires a full valid window'); Near(Sma[5], 5, 'SMA recovers after missing data');
  Bands := TNimbusFinancialIndicators.Bollinger([1, 2, 3], 3, 2);
  Near(Bands.Middle[2], 2, 'Bollinger mean'); Near(Bands.Upper[2], 2 + 2 * Sqrt(2 / 3), 'Bollinger population deviation');
  Rsi := TNimbusFinancialIndicators.Rsi([10, 11, 12, 11, 13], 2);
  Check(IsNan(Rsi.Rsi[1]), 'RSI warmup'); Near(Rsi.Rsi[2], 100, 'RSI initial gain');
  Near(Rsi.Rsi[3], 50, 'RSI Wilder recurrence'); Near(Rsi.Rsi[4], 250 / 3, 'RSI second recurrence');
  Rsi := TNimbusFinancialIndicators.Rsi([5, 5, 5, 5], 2); Near(Rsi.Rsi[3], 50, 'RSI flat market');
  Macd := TNimbusFinancialIndicators.Macd(Values, 2, 3, 2);
  Check(IsNan(Macd.Signal[2]), 'MACD signal warmup'); Near(Macd.Line[3], 0.5, 'MACD line'); Near(Macd.Signal[3], 0.5, 'MACD signal SMA seed'); Near(Macd.Histogram[7], 0, 'MACD histogram');
  Periods := TNimbusFinancialIndicators.NormalizePeriods('50; 20,20 200 bad 1 1001');
  Check((Length(Periods) = 3) and (Periods[0] = 20) and (Periods[2] = 200), 'period normalization');
  Data := TNimbusFinancialDataPointCollection.Create(nil);
  try
    Data.Add(EncodeDate(2024, 1, 2) + 0.4, 10, 12, 8, 10, 2);
    Data.Add(EncodeDate(2024, 1, 2) + 0.5, 10, 14, 9, 13, 1);
    Data.Add(EncodeDate(2024, 1, 3) + 0.4, 13, 15, 12, 15, 3);
    Candles := TNimbusFinancialIndicators.OrderedCandles(Data);
    Values := TNimbusFinancialIndicators.Vwap(Candles, False); Near(Values[1], 32 / 3, 'VWAP volume weighting');
    Values := TNimbusFinancialIndicators.Vwap(Candles, True); Near(Values[2], 14, 'VWAP session reset');
    Atr := TNimbusFinancialIndicators.Atr(Candles, 2); Check(IsNan(Atr.Atr[0]), 'ATR warmup'); Near(Atr.Atr[1], 4.5, 'ATR seed'); Near(Atr.Atr[2], 3.75, 'ATR Wilder recurrence');
    Stoch := TNimbusFinancialIndicators.Stochastic(Candles, 2, 2, 1);
    Check(IsNan(Stoch.K[1]), 'stochastic smoothing warmup'); Near(Stoch.K[2], (500 / 6 + 100) / 2, 'stochastic smoothed K'); Near(Stoch.D[2], Stoch.K[2], 'stochastic D period one');
  finally Data.Free end;
end;

procedure Imports;
const Header = 'Date,Open,High,Low,Close,Volume';
var Options: TNimbusFinancialCsvImportOptions; R, RoundTrip: TNimbusFinancialDataImportResult; Raised: Boolean; Text: string;
begin
  Options := TNimbusFinancialCsvImportOptions.Create;
  try
    Text := Header + sLineBreak + '2024-01-03,10,12,9,11,20' + sLineBreak + '"2024-01-02",8,11,7,10,15';
    R := TNimbusFinancialDataAdapter.ImportCsvText(Text, Options);
    try
      Check((R.Candles.Count = 2) and (R.Candles[0].Close = 10), 'CSV quoted time and sorting');
      Text := TNimbusFinancialDataAdapter.ExportCsv(TNimbusFinancialIndicators.OrderedCandles(R.Candles), 0, 2);
      RoundTrip := TNimbusFinancialDataAdapter.ImportCsvText(Text, Options);
      try Near(RoundTrip.Candles[1].Volume, 20, 'invariant CSV round trip') finally RoundTrip.Free end;
    finally R.Free end;
    Raised := False;
    try R := TNimbusFinancialDataAdapter.ImportCsvText(Header + sLineBreak + '2024-01-02,10,8,9,11,20', Options); R.Free
    except on E: EConvertError do Raised := True end;
    Check(Raised, 'invalid OHLC rejected'); Options.ErrorHandling := nfceSkipInvalidRows;
    R := TNimbusFinancialDataAdapter.ImportCsvText(Header + sLineBreak + '2024-01-02,10,8,9,11,20', Options);
    try Check((R.Candles.Count = 0) and (R.SkippedRows = 1) and (R.Errors.Count = 1), 'skip errors reported') finally R.Free end;
    Options.ErrorHandling := nfceThrow; Options.Delimiter := ';'; Options.DecimalSeparator := ',';
    R := TNimbusFinancialDataAdapter.ImportCsvText('Date;Open;High;Low;Close;Volume' + sLineBreak + '2024-01-02;10,5;12;9;11,5;20', Options);
    try Near(R.Candles[0].Close, 11.5, 'CSV decimal culture') finally R.Free end;
  finally Options.Free end;
end;

procedure WorkspaceAndExport;
var Chart: TFinancialProbe; C: TNimbusChartRenderContext; Scene: TNimbusFinancialScene;
  Data: TNimbusFinancialDataPointCollection; I: Integer; Profile, Svg: string; Raised: Boolean;
  Bitmap: TBitmap; Panel: TNimbusFinancialPanel; Before: Double; Theme: TThemePalette; First, Index: Integer;
  Renderer: INimbusChartRenderer; Hit: TNimbusChartHit;
begin
  Chart := TFinancialProbe.Create(nil); Data := TNimbusFinancialDataPointCollection.Create(nil);
  try
    for I := 0 to 249 do Data.Add(EncodeDate(2024, 1, 1) + I, 100 + I, 103 + I, 99 + I, 102 + I, 1000 + I);
    Chart.ReplaceCandles(Data); Chart.ThemePreset := nftpTradingBlue; Chart.ShowDashboardPanels := True;
    Raised := False;
    try Chart.LoadCsvText('Date,Open,High,Low,Close' + sLineBreak + 'invalid,1,2,0,1')
    except on E: EConvertError do Raised := True end;
    Check(Raised and (Chart.Candles.Count = 250), 'failed import preserves existing data');
    Check(not Chart.HandleAllocated, 'construction and import created HWND');
    C := Chart.Context(1280, 900); Scene := TNimbusFinancialBusinessRenderer.Layout(C);
    Check((Length(Scene.Panels) = 6) and (Length(Scene.SidePanels) = 5), 'source default panel system');
    Check((Chart.SidePanels.FindByKey('watchlist').Items.Count = 7) and (Chart.SidePanels.FindByKey('transactions').Items.Count = 5), 'productive side panel contents');
    Before := Chart.Financial.Snapshots[0].Values[200]; Chart.Viewport.SetVisibleRange(20, 50); C := Chart.Context(1280, 900);
    Near(Chart.Financial.Snapshots[0].Values[200], Before, 'viewport must not change indicator history');
    Chart.Viewport.SetVisibleRange(100, 100); Chart.Viewport.Zoom(2, 0.5);
    Check((Chart.Viewport.FirstVisibleIndex = 125) and (Chart.Viewport.VisibleCount = 50), 'anchored zoom');
    Chart.Viewport.Pan(10000); Check(Chart.Viewport.LastVisibleIndex = 249, 'viewport clamp');
    First := Chart.Viewport.FirstVisibleIndex;
    Panel := Chart.Panels.FindByKey('rsi'); Panel.State := nfpsCollapsed; Profile := Chart.SavePanelUserProfile;
    Panel.State := nfpsExpanded; Chart.LoadPanelUserProfile(Profile);
    Check(Chart.Panels.FindByKey('rsi').State = nfpsCollapsed, 'profile round trip');
    Check(Chart.Viewport.FirstVisibleIndex = First, 'profile load preserves viewport');
    Profile := Chart.SavePanelUserProfile; Raised := False;
    try Chart.LoadPanelUserProfile('{"Version":1,"Panels":[]}') except on E: EConvertError do Raised := True end;
    Check(Raised and (Chart.SavePanelUserProfile = Profile), 'invalid profile is transactional');
    Chart.FinancialPalette.Background := $FF123456;
    Theme := TThemePresetFactory.Light; try Chart.ApplyTheme(Theme) finally Theme.Free end;
    Check(Chart.FinancialPalette.Background = $FF123456, 'application theme preserves custom financial palette');
    Svg := Chart.ExportSvg(1280, 900);
    Check(Pos('#123456', LowerCase(Svg)) > 0, 'SVG preserves custom financial background');
    Bitmap := Chart.RenderToBitmap(1280, 900);
    try Check(Bitmap.Canvas.Pixels[3, 3] = RGB(18, 52, 86), 'bitmap preserves custom financial background') finally Bitmap.Free end;
    Check(not Chart.HandleAllocated, 'export created HWND');
    Renderer := TNimbusFinancialBusinessRenderer.Create;
    for I in [96, 120, 144, 192] do
    begin
      C := Chart.Context(1280, 900); C.PPI := I; Scene := TNimbusFinancialBusinessRenderer.Layout(C);
      Check(not Scene.PricePlot.IsEmpty, 'DPI plot geometry'); Index := Chart.Viewport.FirstVisibleIndex + 3;
      Hit := Renderer.HitTest(C, TPointF.Create(TNimbusFinancialBusinessRenderer.CandleX(C.Financial, Scene.PricePlot, Index), Scene.PricePlot.CenterPoint.Y));
      Check((Hit.FinancialArea = nfhaCandle) and (Hit.PointIndex = Index), 'DPI hit testing shares candle geometry');
    end;
    Renderer := nil;
    C := Chart.Context(1, 1); Scene := TNimbusFinancialBusinessRenderer.Layout(C); Check(Length(Scene.Panels) = 0, 'tiny layout');
  finally Data.Free; Chart.Free end;
end;

procedure PanelInteractions;
var Host: TForm; Chart: TFinancialProbe; Data: TNimbusFinancialDataPointCollection;
  Renderer: INimbusChartRenderer; C: TNimbusChartRenderContext; Scene: TNimbusFinancialScene;
  PL, AfterPL: TNimbusFinancialPanelLayout; SL: TNimbusFinancialSidePanelLayout;
  Watch: TFinancialScrollWatch; Bar: TThemedVScrollBar; Panel: TNimbusFinancialPanel;
  P, Finish: TPoint; Hit: TNimbusChartHit; I, DPI, TopStart, FirstStart, ThirdStart, Delta, DetailHeight: Integer;
  SideKeys: TArray<string>; SideIndex, StartWidth: Integer; Mode: TNimbusFinancialSidePanelLayoutMode;
  Probe: TFinancialRendererProbe; Items: TArray<TNimbusChartPrimitive>; Primitive: TNimbusChartPrimitive;
  BeforeScroll, AfterScroll: TBitmap; X, Y: Integer; PartialRow: Boolean;
  function PanelLayout(const Key: string): TNimbusFinancialPanelLayout;
  var Item: TNimbusFinancialPanelLayout;
  begin
    C := Chart.Context(Chart.Width, Chart.Height); Scene := TNimbusFinancialBusinessRenderer.Layout(C);
    for Item in Scene.Panels do if SameText(Chart.Panels[Item.PanelIndex].Key, Key) then Exit(Item);
    raise Exception.Create('Missing financial test panel ' + Key);
  end;
  function SideLayout(const Key: string): TNimbusFinancialSidePanelLayout;
  var Item: TNimbusFinancialSidePanelLayout;
  begin
    C := Chart.Context(Chart.Width, Chart.Height); Scene := TNimbusFinancialBusinessRenderer.Layout(C);
    for Item in Scene.SidePanels do if SameText(Chart.SidePanels[Item.PanelIndex].Key, Key) then Exit(Item);
    raise Exception.Create('Missing financial test side panel ' + Key);
  end;
  procedure ClickBounds(const Bounds: TRect);
  begin Check(not Bounds.IsEmpty, 'Missing clickable financial button'); Chart.PressAt(Bounds.CenterPoint); Chart.ReleaseAt(Bounds.CenterPoint) end;
begin
  Host := TForm.CreateNew(nil); Chart := nil; Data := nil; Watch := nil;
  try
    Chart := TFinancialProbe.Create(nil); Chart.Parent := Host;
    C := Chart.Context(1, 1); DPI := C.PPI; Host.ClientWidth := MulDiv(1400, DPI, 96); Host.ClientHeight := MulDiv(1300, DPI, 96);
    Chart.Align := alClient; Chart.ShowDashboardPanels := True; Chart.ShowBuiltInIndicatorSettingsDialog := False;
    Chart.OnPanelSettingsRequested := Chart.SettingsRequested; Chart.InjectCaptureLoss := True;
    Data := TNimbusFinancialDataPointCollection.Create(nil);
    for I := 0 to 249 do Data.Add(EncodeDate(2024, 1, 1) + I, 100 + I, 103 + I, 99 + I, 102 + I, 1000 + I);
    Chart.ReplaceCandles(Data); Check(Chart.Handle <> 0, 'Financial interaction HWND');
    Probe := TFinancialRendererProbe.Create; Renderer := Probe;
    for I in [96, 120, 144, 192] do
    begin
      C := Chart.Context(Chart.Width, Chart.Height); C.PPI := I; Scene := TNimbusFinancialBusinessRenderer.Layout(C);
      for PL in Scene.Panels do
      begin
        if not PL.SettingsButton.IsEmpty then
        begin Hit := Renderer.HitTest(C, TPointF.Create(PL.SettingsButton.CenterPoint.X, PL.SettingsButton.CenterPoint.Y)); Check(Hit.FinancialArea = nfhaPanelSettings, 'Settings button hit priority') end;
        if not PL.CollapseButton.IsEmpty then
        begin Hit := Renderer.HitTest(C, TPointF.Create(PL.CollapseButton.CenterPoint.X, PL.CollapseButton.CenterPoint.Y)); Check(Hit.FinancialArea = nfhaPanelCollapse, 'Collapse button hit priority') end;
        if not PL.PinButton.IsEmpty then
        begin Hit := Renderer.HitTest(C, TPointF.Create(PL.PinButton.CenterPoint.X, PL.PinButton.CenterPoint.Y)); Check(Hit.FinancialArea = nfhaPanelPin, 'Pin button hit priority') end;
        if Chart.Panels[PL.PanelIndex].IsPinned then Check(PL.CloseButton.IsEmpty, 'Pinned panel must not offer close');
      end;
    end;
    PL := PanelLayout('volume'); ClickBounds(PL.SettingsButton); Check(Chart.SettingsRequests = 1, 'Settings click lost during mouse-up capture release');
    ClickBounds(PL.CollapseButton); Check(Chart.Panels.FindByKey('volume').State = nfpsCollapsed, 'Collapse click lost');
    PL := PanelLayout('volume'); ClickBounds(PL.CollapseButton); Check(Chart.Panels.FindByKey('volume').State = nfpsExpanded, 'Expand click lost');
    PL := PanelLayout('volume'); ClickBounds(PL.PinButton); PL := PanelLayout('volume');
    Check(Chart.Panels.FindByKey('volume').IsPinned and PL.CloseButton.IsEmpty, 'Pin must protect panel from closing');
    ClickBounds(PL.PinButton); PL := PanelLayout('volume'); ClickBounds(PL.CloseButton);
    Panel := Chart.Panels.FindByKey('volume'); Check(Panel.State = nfpsHidden, 'Close click lost'); Panel.State := nfpsExpanded;
    PL := PanelLayout('volume'); Chart.PressAt(PL.CollapseButton.CenterPoint); Chart.Perform(WM_CAPTURECHANGED, 0, 0); Chart.ReleaseAt(PL.CollapseButton.CenterPoint);
    Check(Panel.State = nfpsExpanded, 'Real capture loss must cancel pending click');
    Chart.AllowPanelLayoutChanges := False; PL := PanelLayout('volume'); ClickBounds(PL.CollapseButton);
    Check(Panel.State = nfpsExpanded, 'Layout permission ignored'); Chart.AllowPanelLayoutChanges := True;
    SL := SideLayout('details'); ClickBounds(SL.CollapseButton); Check(Chart.SidePanels.FindByKey('details').State = nfspsCollapsed, 'Side collapse click lost');
    SL := SideLayout('details'); ClickBounds(SL.CollapseButton); Check(Chart.SidePanels.FindByKey('details').State = nfspsExpanded, 'Side expand click lost');
    SL := SideLayout('details'); DetailHeight := SL.ContentHeight; Bar := nil;
    for I := 0 to Chart.ControlCount - 1 do
      if (Chart.Controls[I] is TThemedVScrollBar) and (Chart.Controls[I].Tag = SL.PanelIndex) then Bar := TThemedVScrollBar(Chart.Controls[I]);
    Check((Bar <> nil) and Bar.Visible, 'Expected overflowing details scrollbar'); Watch := TFinancialScrollWatch.Create(Bar);
    for I := 0 to 30 do
    begin
      Chart.Viewport.SetVisibleRange(0, 120); PL := PanelLayout('price');
      P := Point(Round(TNimbusFinancialBusinessRenderer.CandleX(Chart.Financial, PL.Plot, I)), PL.Plot.CenterPoint.Y); Chart.HoverAt(P);
      SL := SideLayout('details'); Check(SL.ContentHeight = DetailHeight, 'Indicator warmup changes detail row geometry');
    end;
    Check(Watch.VisibilityChanges = 0, 'Hover repeatedly hides and shows scrollbar');
    Check((GetWindowLong(Chart.Handle, GWL_STYLE) and WS_CLIPCHILDREN) <> 0, 'Parent window must clip child scrollbars');
    BeforeScroll := Chart.RenderToBitmap;
    try
      Bar.Value := 13; AfterScroll := Chart.RenderToBitmap;
      try
        SL := SideLayout('details');
        for Y := SL.Header.Top + 1 to SL.Header.Bottom - 1 do
          for X := SL.Header.Left + 1 to SL.Header.Right - 1 do
            Check(BeforeScroll.Canvas.Pixels[X, Y] = AfterScroll.Canvas.Pixels[X, Y], 'Scrolled row painted over sidebar caption');
      finally AfterScroll.Free end;
    finally BeforeScroll.Free end;
    C := Chart.Context(Chart.Width, Chart.Height); Items := Probe.Primitives(C); PartialRow := False;
    for Primitive in Items do if (Primitive.Kind = ncpText) and (Primitive.Hit.FinancialArea = nfhaSidePanelItem) and
      (Primitive.Hit.SeriesIndex = SL.PanelIndex) then
    begin
      Check(Primitive.UseClip and (Primitive.ClipBounds.Top >= SL.Body.Top) and (Primitive.ClipBounds.Bottom <= SL.Body.Bottom), 'Sidebar text lost parent clip');
      if Primitive.Bounds.Top < SL.Body.Top then PartialRow := True;
    end;
    Check(PartialRow, 'Expected partially scrolled row in clipping regression');
    Check(Watch.VisibilityChanges = 0, 'Scrolling toggles scrollbar visibility'); FreeAndNil(Watch);
    SetLength(SideKeys, Chart.SidePanels.Count);
    for I := 0 to High(SideKeys) do SideKeys[I] := Chart.SidePanels[I].Key;
    for Mode := Low(TNimbusFinancialSidePanelLayoutMode) to High(TNimbusFinancialSidePanelLayoutMode) do
    begin
      Chart.SidePanelLayoutMode := Mode; SL := SideLayout('details'); SideIndex := SL.PanelIndex;
      StartWidth := Chart.SidePanels[SideIndex].Width; P := SL.Splitter.CenterPoint;
      Chart.PressAt(P); Finish := Point(P.X - MulDiv(24, DPI, 96), P.Y);
      if Mode = nfslColumns then Finish := Point(P.X + MulDiv(StartWidth - 276, DPI, 96), P.Y);
      Chart.HoverAt(Finish, True); Chart.ReleaseAt(Finish);
      Check(Chart.SidePanels.Count = Length(SideKeys), 'Side resize changed panel collection count');
      for I := 0 to High(SideKeys) do Check(Chart.SidePanels[I].Key = SideKeys[I], 'Side resize changed collection item Index');
      if Mode = nfslColumns then Check(Abs(Chart.SidePanels[SideIndex].Width - 276) <= 1, 'Column resize must set Width to 276 without assigning Index')
      else Check(Chart.RightSidePanelAreaWidth > 0, 'Stacked resize did not change area width');
    end;
    Chart.SidePanelLayoutMode := nfslStacked; Chart.RightSidePanelAreaWidth := 0;
    PL := PanelLayout('price'); TopStart := PL.Bounds.Height; P := PL.Separator.CenterPoint;
    AfterPL := PanelLayout('volume'); FirstStart := AfterPL.Bounds.Height;
    Delta := Max(0, FirstStart - MulDiv(Chart.Panels.FindByKey('volume').MinimumHeight, DPI, 96)) + MulDiv(12, DPI, 96);
    AfterPL := PanelLayout('rsi'); ThirdStart := AfterPL.Bounds.Height;
    Chart.PressAt(P); Finish := Point(P.X, P.Y + Delta); Chart.HoverAt(Finish, True); Chart.ReleaseAt(Finish);
    PL := PanelLayout('price'); Check(PL.Bounds.Height > TopStart, 'Price separator did not resize');
    AfterPL := PanelLayout('rsi'); Check(AfterPL.Bounds.Height < ThirdStart, 'Resize must use lower panels beyond first neighbour');
    TopStart := PL.Bounds.Height; P := PL.Separator.CenterPoint;
    Chart.PressAt(P); Chart.Perform(WM_CAPTURECHANGED, 0, 0); Chart.HoverAt(Point(P.X, P.Y + 20), True); Chart.ReleaseAt(Point(P.X, P.Y + 20));
    PL := PanelLayout('price'); Check(Abs(PL.Bounds.Height - TopStart) <= 2, 'Capture loss continued resize');
  finally Watch.Free; Renderer := nil; Data.Free; Chart.Free; Host.Free end;
end;

procedure RowAndPanelEvents;
var Host: TForm; Chart: TFinancialProbe; Data: TNimbusFinancialDataPointCollection; Side: TNimbusFinancialSidePanel;
  Item: TNimbusFinancialPanelItem; C: TNimbusChartRenderContext; Scene: TNimbusFinancialScene; SL: TNimbusFinancialSidePanelLayout;
  Location: TPoint; I, Before, PPI: Integer; Profile: string;
begin
  Host := TForm.CreateNew(nil); Chart := nil; Data := nil;
  try
    Chart := TFinancialProbe.Create(nil); Chart.Parent := Host; Chart.Align := alClient;
    C := Chart.Context(1, 1); PPI := C.PPI; Host.ClientWidth := MulDiv(1100, PPI, 96); Host.ClientHeight := MulDiv(700, PPI, 96);
    Chart.AutoBuildProductiveSidePanels := False; Chart.SidePanels.Clear; Chart.ShowDashboardPanels := True;
    Chart.ShowBuiltInIndicatorSettingsDialog := False; Chart.InjectCaptureLoss := True;
    Chart.OnRowClicked := Chart.RowEvent; Chart.OnRowDoubleClicked := Chart.RowEvent;
    Chart.OnRowHovered := Chart.RowEvent; Chart.OnRowContextMenu := Chart.RowEvent;
    Chart.OnSidePanelItemClicked := Chart.LegacyRowEvent; Chart.OnPanelAction := Chart.ActionEvent;
    Data := TNimbusFinancialDataPointCollection.Create(nil);
    for I := 0 to 9 do Data.Add(EncodeDate(2024, 1, 1) + I, 100 + I, 103 + I, 99 + I, 102 + I, 1000 + I);
    Chart.ReplaceCandles(Data);
    Side := Chart.SidePanels.Add; Side.Key := 'events'; Side.Title := 'Event rows'; Side.Position := nfsppRight;
    Side.OnRowClicked := Chart.LocalRowEvent; Side.OnAction := Chart.LocalActionEvent;
    Item := Side.Items.Add; Item.Key := 'hidden'; Item.Visible := False;
    Item := Side.Items.Add; Item.Kind := nfpiSeparator;
    Item := Side.Items.Add; Item.Key := 'first'; Item.Text := 'First row'; Item.Value := '42'; Item.Tag := 716;
    Item.NumericValue := 42; Item.CandleIndex := 7; Item.Values := [1, 2, 3];
    Item := Side.Items.Add; Item.Key := 'second'; Item.Text := 'Second row'; Item.Value := '84';
    for I := 0 to 19 do begin Item := Side.Items.Add; Item.Key := 'more-' + IntToStr(I); Item.Text := Item.Key end;
    Chart.Panels.FindByKey('price').OnAction := Chart.LocalActionEvent;
    Chart.EditPanelSettings(Chart.Panels.FindByKey('price'));
    Check((Chart.LocalActions = 1) and (Chart.GlobalActions = 1) and not Chart.LastAction.IsSidePanel and
      (Chart.LastAction.Action = nfpaSettingsRequested), 'Per-chart-panel and global action event');
    Check(Chart.ActivateSidePanelItem('events', 'first'), 'Programmatic row activation');
    Check((Chart.LocalRowClicks = 1) and (Chart.RowClicks = 1) and (Chart.LegacyRowClicks = 1), 'Local/global/legacy row dispatch');
    Check((Chart.LastRow.PanelKey = 'events') and (Chart.LastRow.RowKey = 'first') and (Chart.LastRow.RowIndex = 2) and
      (Chart.LastRow.VisibleRowIndex = 0) and (Chart.LastRow.Tag = 716) and (Chart.LastRow.Origin = nfioProgrammatic), 'Typed row identity');
    Check(Chart.LastRow.HasCandle and (Chart.LastRow.CandleIndex = 7) and (Chart.LastRow.Close = 109), 'Row candle snapshot');
    Chart.PressKey(VK_DOWN); Chart.PressKey(VK_RETURN);
    Check((Chart.LastRow.RowKey = 'second') and (Chart.LastRow.Origin = nfioKeyboard), 'Keyboard row activation');
    Chart.PressKey(VK_F10, [ssShift]); Check((Chart.RowContexts = 1) and (Chart.LastRow.Origin = nfioKeyboard), 'Keyboard row context event');
    Chart.ActivateSidePanelItem('events', 'first');
    C := Chart.Context(Chart.Width, Chart.Height); Scene := TNimbusFinancialBusinessRenderer.Layout(C);
    SL := Scene.SidePanels[0]; Location := Point(SL.Body.Left + MulDiv(12, PPI, 96), SL.Body.Top + MulDiv(42, PPI, 96));
    Chart.HoverAt(Location); Chart.HoverAt(Location); Check(Chart.RowHovers = 1, 'Hover should fire once per row entry');
    Chart.RightClickAt(Location); Check((Chart.RowContexts = 2) and (Chart.LastRow.RowKey = 'first'), 'Mouse row context event');
    Chart.DoubleClickAt(Location); Check(Chart.RowDoubleClicks = 1, 'Row double click event');
    Profile := Chart.SavePanelUserProfile; Chart.LoadPanelUserProfile(Profile);
    Before := Chart.LocalRowClicks; Check(Chart.ActivateSidePanelItem('events', 'first') and (Chart.LocalRowClicks = Before + 1), 'Profile reload lost per-panel row handler');
    Before := Chart.LocalActions; Chart.EditPanelSettings(Chart.Panels.FindByKey('price')); Check(Chart.LocalActions = Before + 1, 'Profile reload lost chart-panel action handler');
    Chart.ClearRowsInLocal := True; Check(Chart.ActivateSidePanelItem('events', 'first'), 'Mutable row handler dispatch');
    Check((Chart.LastRow.Text = 'First row') and (Chart.LastRow.Value = '42') and (Length(Chart.LastRow.Values) = 3), 'Global event lost snapshot after local handler cleared rows');
    Check(not Chart.ActivateSidePanelItem('events', 'first'), 'Removed row should not activate');
  finally Data.Free; Chart.Free; Host.Free end;
end;

procedure CanvasChildExclusion;
var Bitmap: TBitmap; Canvas: INimbusRenderCanvas; Exclusion: INimbusRenderClipExclusion;
begin
  Bitmap := TBitmap.Create;
  try
    Bitmap.SetSize(50, 50); Canvas := TNimbusRenderCanvas.Create;
    Check(Supports(Canvas, INimbusRenderClipExclusion, Exclusion), 'Canvas missing child exclusion support');
    Canvas.BeginRender(Bitmap.Canvas);
    try
      Canvas.Clear($FF00FF00, Rect(0, 0, 50, 50)); Canvas.PushClip(Rect(10, 10, 40, 40));
      Exclusion.ExcludeClip(Rect(20, 20, 30, 30)); Canvas.Clear($FFFF0000, Rect(0, 0, 50, 50)); Canvas.PopClip;
      Canvas.Clear($FF0000FF, Rect(0, 0, 5, 5));
    finally Canvas.EndRender end;
    Check(Bitmap.Canvas.Pixels[15, 15] = clRed, 'Visible parent area not painted');
    Check(Bitmap.Canvas.Pixels[25, 25] = clLime, 'Parent paint overwrites excluded scrollbar rectangle');
    Check(Bitmap.Canvas.Pixels[7, 7] = clLime, 'Dirty-region clip ignored');
    Check(Bitmap.Canvas.Pixels[2, 2] = clBlue, 'Clip stack did not restore exclusion state');
  finally Exclusion := nil; Canvas := nil; Bitmap.Free end;
end;

procedure RunNimbusFinancialChecks;
begin Calculations; Imports; WorkspaceAndExport; CanvasChildExclusion; PanelInteractions; RowAndPanelEvents end;

end.

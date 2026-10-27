unit NimbusForms.Charts.Financial.Workspace;

interface

uses System.Classes, System.SysUtils, System.Types, System.Math, System.DateUtils,
  System.Generics.Collections, Vcl.Graphics, NimbusForms.Charts.Financial.Types,
  NimbusForms.Charts.Financial.Business.Types, NimbusForms.Charts.Financial.Indicators,
  NimbusForms.Charts.Financial.Palette, NimbusForms.Charts.Financial.Viewport;

type
  TNimbusFinancialHitArea = (nfhaNone, nfhaCandle, nfhaPlot, nfhaPriceAxis, nfhaTimeAxis, nfhaRangeButton,
    nfhaLegend, nfhaPanelHeader, nfhaPanelCollapse, nfhaPanelClose, nfhaPanelPin, nfhaPanelSettings,
    nfhaPanelSeparator, nfhaMarker, nfhaAnnotation, nfhaSidePanelHeader, nfhaSidePanelCollapse,
    nfhaSidePanelPin, nfhaSidePanelItem, nfhaSidePanelSplitter, nfhaSidePanelSeparator);
  TNimbusFinancialIndicatorSnapshot = record
    Key, Title, PanelKey: string;
    Kind: TNimbusFinancialIndicatorKind;
    Period: Integer;
    Values, Secondary, Tertiary: TNimbusFinancialValues;
    Color, SecondaryColor: TColor;
    DefinitionIndex: Integer;
  end;
  TNimbusFinancialWorkspace = class(TNimbusFinancialPersistent)
  private
    FOptions: TNimbusFinancialBusinessOptions;
    FPanels: TNimbusFinancialPanelCollection;
    FIndicators: TNimbusFinancialIndicatorCollection;
    FSidePanels: TNimbusFinancialSidePanelCollection;
    FMarkers: TNimbusFinancialMarkerCollection;
    FAnnotations: TNimbusFinancialAnnotationCollection;
    FRangeSelector: TNimbusFinancialRangeSelector;
    FInteraction: TNimbusFinancialInteractionOptions;
    FAccessibility: TNimbusFinancialAccessibilityOptions;
    FViewport: TNimbusFinancialViewport;
    FPalette: TNimbusFinancialPalette;
    FSelectedIndex, FRangeStartIndex, FRangeEndIndex: Integer;
    FCandles: TNimbusFinancialCandleArray;
    FSnapshots: TArray<TNimbusFinancialIndicatorSnapshot>;
    FCacheData: TNimbusFinancialDataPointCollection;
    FDataRevision, FOptionsRevision, FIndicatorsRevision: UInt64;
    FProductiveDataRevision, FProductiveOptionsRevision, FProductiveIndicatorsRevision: UInt64;
    FProductiveIndex, FProductiveSideCount: Integer;
    FCacheValid, FBuildingCache, FUpdatingSides: Boolean;
    procedure ChildChanged(Sender: TObject);
    procedure SetOptions(const Value: TNimbusFinancialBusinessOptions);
    procedure SetPanels(const Value: TNimbusFinancialPanelCollection);
    procedure SetIndicators(const Value: TNimbusFinancialIndicatorCollection);
    procedure SetSidePanels(const Value: TNimbusFinancialSidePanelCollection);
    procedure SetMarkers(const Value: TNimbusFinancialMarkerCollection);
    procedure SetAnnotations(const Value: TNimbusFinancialAnnotationCollection);
    procedure SetRangeSelector(const Value: TNimbusFinancialRangeSelector);
    procedure SetInteraction(const Value: TNimbusFinancialInteractionOptions);
    procedure SetAccessibility(const Value: TNimbusFinancialAccessibilityOptions);
    procedure SetViewport(const Value: TNimbusFinancialViewport);
    procedure SetPalette(const Value: TNimbusFinancialPalette);
  public
    HoveredIndex: Integer;
    DragPanelIndex, DropPanelIndex, DragOffsetY: Integer;
    CrosshairLocation: TPoint;
    CrosshairVisible: Boolean;
    FocusedSidePanelKey, FocusedRowKey: string;
    FocusedSidePanelIndex, FocusedRowIndex: Integer;
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure ResetPanels;
    procedure ResetRangeButtons;
    procedure EnsureCache(Data: TNimbusFinancialDataPointCollection);
    procedure InvalidateCache;
    function PanelIsActive(Panel: TNimbusFinancialPanel): Boolean;
    procedure SelectIndex(const Index: Integer);
    procedure SelectRange(const First, Last: Integer);
    procedure ClearSelection;
    procedure ApplyRange(Button: TNimbusFinancialRangeButton);
    function FindCandleByTime(const Time: TDateTime): Integer;
    function GetAccessibleSummary: string;
    procedure RefreshProductiveSidePanels;
    property Candles: TNimbusFinancialCandleArray read FCandles;
    property Snapshots: TArray<TNimbusFinancialIndicatorSnapshot> read FSnapshots;
    property SelectedIndex: Integer read FSelectedIndex;
    property RangeStartIndex: Integer read FRangeStartIndex;
    property RangeEndIndex: Integer read FRangeEndIndex;
  published
    property Options: TNimbusFinancialBusinessOptions read FOptions write SetOptions;
    property Panels: TNimbusFinancialPanelCollection read FPanels write SetPanels;
    property Indicators: TNimbusFinancialIndicatorCollection read FIndicators write SetIndicators;
    property SidePanels: TNimbusFinancialSidePanelCollection read FSidePanels write SetSidePanels;
    property Markers: TNimbusFinancialMarkerCollection read FMarkers write SetMarkers;
    property Annotations: TNimbusFinancialAnnotationCollection read FAnnotations write SetAnnotations;
    property RangeSelector: TNimbusFinancialRangeSelector read FRangeSelector write SetRangeSelector;
    property InteractionOptions: TNimbusFinancialInteractionOptions read FInteraction write SetInteraction;
    property AccessibilityOptions: TNimbusFinancialAccessibilityOptions read FAccessibility write SetAccessibility;
    property Viewport: TNimbusFinancialViewport read FViewport write SetViewport;
    property Palette: TNimbusFinancialPalette read FPalette write SetPalette;
  end;

implementation

constructor TNimbusFinancialWorkspace.Create;
begin
  inherited Create;
  FOptions := TNimbusFinancialBusinessOptions.Create; FPanels := TNimbusFinancialPanelCollection.Create(Self);
  FIndicators := TNimbusFinancialIndicatorCollection.Create(Self); FSidePanels := TNimbusFinancialSidePanelCollection.Create(Self);
  FMarkers := TNimbusFinancialMarkerCollection.Create(Self); FAnnotations := TNimbusFinancialAnnotationCollection.Create(Self);
  FRangeSelector := TNimbusFinancialRangeSelector.Create; FInteraction := TNimbusFinancialInteractionOptions.Create;
  FAccessibility := TNimbusFinancialAccessibilityOptions.Create; FViewport := TNimbusFinancialViewport.Create;
  FPalette := TNimbusFinancialPalette.Create; FSelectedIndex := -1; FRangeStartIndex := -1; FRangeEndIndex := -1; HoveredIndex := -1;
  DragPanelIndex := -1; DropPanelIndex := -1; FProductiveIndex := Low(Integer);
  FocusedSidePanelIndex := -1; FocusedRowIndex := -1; ResetPanels; ResetRangeButtons;
  FOptions.OnChange := ChildChanged; FPanels.OnChange := ChildChanged; FIndicators.OnChange := ChildChanged;
  FSidePanels.OnChange := ChildChanged; FMarkers.OnChange := ChildChanged; FAnnotations.OnChange := ChildChanged;
  FRangeSelector.OnChange := ChildChanged; FInteraction.OnChange := ChildChanged; FAccessibility.OnChange := ChildChanged;
  FViewport.OnChange := ChildChanged; FPalette.OnChange := ChildChanged;
end;

destructor TNimbusFinancialWorkspace.Destroy;
begin
  FOptions.OnChange := nil; FPanels.OnChange := nil; FIndicators.OnChange := nil; FSidePanels.OnChange := nil;
  FMarkers.OnChange := nil; FAnnotations.OnChange := nil; FRangeSelector.OnChange := nil;
  FInteraction.OnChange := nil; FAccessibility.OnChange := nil; FViewport.OnChange := nil; FPalette.OnChange := nil;
  FPalette.Free; FViewport.Free; FAccessibility.Free; FInteraction.Free; FRangeSelector.Free;
  FAnnotations.Free; FMarkers.Free; FSidePanels.Free; FIndicators.Free; FPanels.Free; FOptions.Free;
  inherited;
end;

procedure TNimbusFinancialWorkspace.ChildChanged(Sender: TObject);
begin if not FBuildingCache and not FUpdatingSides then Changed end;

procedure TNimbusFinancialWorkspace.Assign(Source: TPersistent);
var Other: TNimbusFinancialWorkspace;
begin
  if not (Source is TNimbusFinancialWorkspace) then begin inherited; Exit end; Other := TNimbusFinancialWorkspace(Source);
  FOptions.Assign(Other.FOptions); FPanels.Assign(Other.FPanels); FIndicators.Assign(Other.FIndicators);
  FSidePanels.Assign(Other.FSidePanels); FMarkers.Assign(Other.FMarkers); FAnnotations.Assign(Other.FAnnotations);
  FRangeSelector.Assign(Other.FRangeSelector); FInteraction.Assign(Other.FInteraction);
  FAccessibility.Assign(Other.FAccessibility); FViewport.Assign(Other.FViewport); FPalette.Assign(Other.FPalette);
  InvalidateCache; Changed;
end;

procedure TNimbusFinancialWorkspace.SetOptions(const Value: TNimbusFinancialBusinessOptions);
begin if Value <> nil then FOptions.Assign(Value) end;
procedure TNimbusFinancialWorkspace.SetPanels(const Value: TNimbusFinancialPanelCollection);
begin if Value <> nil then FPanels.Assign(Value) end;
procedure TNimbusFinancialWorkspace.SetIndicators(const Value: TNimbusFinancialIndicatorCollection);
begin if Value <> nil then FIndicators.Assign(Value) end;
procedure TNimbusFinancialWorkspace.SetSidePanels(const Value: TNimbusFinancialSidePanelCollection);
begin if Value <> nil then FSidePanels.Assign(Value) end;
procedure TNimbusFinancialWorkspace.SetMarkers(const Value: TNimbusFinancialMarkerCollection);
begin if Value <> nil then FMarkers.Assign(Value) end;
procedure TNimbusFinancialWorkspace.SetAnnotations(const Value: TNimbusFinancialAnnotationCollection);
begin if Value <> nil then FAnnotations.Assign(Value) end;
procedure TNimbusFinancialWorkspace.SetRangeSelector(const Value: TNimbusFinancialRangeSelector);
begin if Value <> nil then FRangeSelector.Assign(Value) end;
procedure TNimbusFinancialWorkspace.SetInteraction(const Value: TNimbusFinancialInteractionOptions);
begin if Value <> nil then FInteraction.Assign(Value) end;
procedure TNimbusFinancialWorkspace.SetAccessibility(const Value: TNimbusFinancialAccessibilityOptions);
begin if Value <> nil then FAccessibility.Assign(Value) end;
procedure TNimbusFinancialWorkspace.SetViewport(const Value: TNimbusFinancialViewport);
begin if Value <> nil then FViewport.Assign(Value) end;
procedure TNimbusFinancialWorkspace.SetPalette(const Value: TNimbusFinancialPalette);
begin if Value <> nil then FPalette.Assign(Value) end;

procedure TNimbusFinancialWorkspace.ResetPanels;
  procedure Add(const Key, Title: string; const Kind: TNimbusFinancialPanelType; const Weight: Double; const MinHeight, Preferred: Integer);
  var Panel: TNimbusFinancialPanel;
  begin
    Panel := FPanels.Add; Panel.Key := Key; Panel.Title := Title; Panel.PanelType := Kind;
    Panel.HeightWeight := Weight; Panel.MinimumHeight := MinHeight; Panel.PreferredHeight := Preferred;
    if Kind = nfptOscillator then begin Panel.ScaleMode := nfsmFixed; Panel.FixedMinimumValue := 0; Panel.FixedMaximumValue := 100; Panel.ScalePaddingRatio := 0; Panel.ValueFormat := '0.0' end;
    if Kind = nfptPrice then begin Panel.AllowClose := False; Panel.AllowCollapse := False; Panel.AllowMove := False; Panel.IsPinned := True; Panel.ScalePaddingRatio := 0.055 end;
  end;
begin
  FPanels.BeginUpdate;
  try
    FPanels.Clear;
    Add('price', 'Price', nfptPrice, 5, 180, 320); Add('volume', 'Volume', nfptVolume, 1.45, 72, 110);
    Add('rsi', 'RSI', nfptOscillator, 1.25, 72, 104); Add('macd', 'MACD', nfptIndicator, 1.45, 80, 120);
    Add('stochastic', 'Stochastic', nfptOscillator, 1.25, 72, 104); Add('atr', 'ATR', nfptIndicator, 1.15, 72, 100);
  finally FPanels.EndUpdate end;
end;

procedure TNimbusFinancialWorkspace.ResetRangeButtons;
const Keys: array[0..9] of string = ('1D', '5D', '1M', '3M', '6M', 'YTD', '1Y', '3Y', '5Y', 'ALL');
  Kinds: array[0..9] of TNimbusFinancialRangeKind = (nfrkDays, nfrkDays, nfrkMonths, nfrkMonths, nfrkMonths, nfrkYearToDate, nfrkYears, nfrkYears, nfrkYears, nfrkAll);
  Values: array[0..9] of Integer = (1, 5, 1, 3, 6, 0, 1, 3, 5, 0);
var I: Integer; Button: TNimbusFinancialRangeButton;
begin
  FRangeSelector.Items.BeginUpdate;
  try
    FRangeSelector.Items.Clear;
    for I := 0 to High(Keys) do begin Button := FRangeSelector.Items.Add; Button.Key := Keys[I]; Button.Text := Keys[I]; Button.RangeKind := Kinds[I]; Button.Value := Values[I] end;
  finally FRangeSelector.Items.EndUpdate end;
end;

procedure TNimbusFinancialWorkspace.InvalidateCache;
begin FCacheValid := False end;

procedure TNimbusFinancialWorkspace.EnsureCache(Data: TNimbusFinancialDataPointCollection);
var Closes, Volumes: TNimbusFinancialValues; Results: TList<TNimbusFinancialIndicatorSnapshot>;
  I: Integer; Item: TNimbusFinancialIndicator; Snapshot: TNimbusFinancialIndicatorSnapshot;
  procedure Add(const Key, Title, PanelKey, PeriodText: string; const Kind: TNimbusFinancialIndicatorKind;
    const Fast, Slow, Signal, Smooth: Integer; const Deviation: Double; const Session: Boolean; const Definition: Integer);
  var Periods: TArray<Integer>; P: Integer; S: TNimbusFinancialIndicatorSnapshot; Bands: TNimbusFinancialBollingerValues;
    Macd: TNimbusFinancialMacdValues; Stochastic: TNimbusFinancialStochasticValues; Rsi: TNimbusFinancialRsiValues; Atr: TNimbusFinancialAtrValues;
  begin
    Periods := TNimbusFinancialIndicators.NormalizePeriods(PeriodText);
    if Kind in [nfikVolume, nfikMacd, nfikStochastic, nfikVwap] then Periods := [0];
    for P in Periods do
    begin
      S := Default(TNimbusFinancialIndicatorSnapshot); S.Key := Key + '.' + IntToStr(P); S.Title := Title;
      if P > 0 then S.Title := S.Title + '(' + IntToStr(P) + ')'; S.Period := P; S.PanelKey := PanelKey;
      S.Kind := Kind; S.DefinitionIndex := Definition; S.Color := clNone; S.SecondaryColor := clNone;
      case Kind of
        nfikVolume: begin S.Values := Copy(Volumes); if FOptions.ShowVolumeMovingAverage then S.Secondary := TNimbusFinancialIndicators.Sma(Volumes, FOptions.VolumeMovingAveragePeriod) end;
        nfikSma: S.Values := TNimbusFinancialIndicators.Sma(Closes, P);
        nfikEma: S.Values := TNimbusFinancialIndicators.Ema(Closes, P);
        nfikBollinger: begin Bands := TNimbusFinancialIndicators.Bollinger(Closes, P, Deviation); S.Values := Bands.Middle; S.Secondary := Bands.Upper; S.Tertiary := Bands.Lower end;
        nfikRsi: begin Rsi := TNimbusFinancialIndicators.Rsi(Closes, P); S.Values := Rsi.Rsi end;
        nfikMacd: begin Macd := TNimbusFinancialIndicators.Macd(Closes, Fast, Max(Fast + 1, Slow), Signal); S.Values := Macd.Line; S.Secondary := Macd.Signal; S.Tertiary := Macd.Histogram end;
        nfikStochastic: begin Stochastic := TNimbusFinancialIndicators.Stochastic(FCandles, Max(2, StrToIntDef(PeriodText, 14)), Smooth, Signal); S.Values := Stochastic.K; S.Secondary := Stochastic.D end;
        nfikAtr: begin Atr := TNimbusFinancialIndicators.Atr(FCandles, P); S.Values := Atr.Atr end;
        nfikVwap: S.Values := TNimbusFinancialIndicators.Vwap(FCandles, Session);
      end;
      if Definition >= 0 then begin S.Color := FIndicators[Definition].Color; S.SecondaryColor := FIndicators[Definition].SecondaryColor end;
      Results.Add(S);
    end;
  end;
begin
  if Data = nil then raise EArgumentNilException.Create('Data');
  if FBuildingCache then Exit;
  if FCacheValid and (FCacheData = Data) and (FDataRevision = Data.Revision) and
    (FOptionsRevision = FOptions.Revision) and (FIndicatorsRevision = FIndicators.Revision) then Exit;
  FBuildingCache := True;
  try
    FCandles := TNimbusFinancialIndicators.OrderedCandles(Data); Closes := TNimbusFinancialIndicators.Closes(FCandles);
    SetLength(Volumes, Length(FCandles)); for I := 0 to High(FCandles) do Volumes[I] := Max(0.0, FCandles[I].Volume);
    Results := TList<TNimbusFinancialIndicatorSnapshot>.Create;
    try
      if FOptions.ShowVolume then Add('volume', 'Volume', 'volume', '', nfikVolume, 0, 0, 0, 0, 0, False, -1);
      if FOptions.ShowSimpleMovingAverage then Add('sma', 'SMA', 'price', FOptions.SimpleMovingAveragePeriods, nfikSma, 0, 0, 0, 0, 0, False, -1);
      if FOptions.ShowExponentialMovingAverage then Add('ema', 'EMA', 'price', FOptions.ExponentialMovingAveragePeriods, nfikEma, 0, 0, 0, 0, 0, False, -1);
      if FOptions.ShowBollingerBands then Add('bollinger', 'Bollinger', 'price', FOptions.BollingerBandPeriods, nfikBollinger, 0, 0, 0, 0, FOptions.BollingerBandStandardDeviation, False, -1);
      if FOptions.ShowRsi then Add('rsi', 'RSI', 'rsi', FOptions.RsiPeriods, nfikRsi, 0, 0, 0, 0, 0, False, -1);
      if FOptions.ShowMacd then Add('macd', 'MACD', 'macd', '', nfikMacd, FOptions.MacdFastPeriod, FOptions.MacdSlowPeriod, FOptions.MacdSignalPeriod, 0, 0, False, -1);
      if FOptions.ShowStochastic then Add('stochastic', 'Stochastic', 'stochastic', IntToStr(FOptions.StochasticPeriod), nfikStochastic, 0, 0, FOptions.StochasticDPeriod, FOptions.StochasticSmoothKPeriod, 0, False, -1);
      if FOptions.ShowAtr then Add('atr', 'ATR', 'atr', FOptions.AtrPeriods, nfikAtr, 0, 0, 0, 0, 0, False, -1);
      if FOptions.ShowVwap then Add('vwap', 'VWAP', 'price', '', nfikVwap, 0, 0, 0, 0, 0, FOptions.VwapResetBySession, -1);
      for I := 0 to FIndicators.Count - 1 do
      begin
        Item := FIndicators[I]; if not Item.Visible then Continue;
        if Item.Kind = nfikCustom then
        begin
          Snapshot := Default(TNimbusFinancialIndicatorSnapshot); Snapshot.Key := Item.Key; Snapshot.Title := Item.DisplayName;
          Snapshot.PanelKey := Item.PanelKey; Snapshot.Kind := nfikCustom; Snapshot.DefinitionIndex := I;
          Snapshot.Color := Item.Color; Snapshot.SecondaryColor := Item.SecondaryColor;
          Snapshot.Values := TNimbusFinancialIndicators.NaNArray(Length(FCandles));
          for var ValueIndex := 0 to Min(High(Snapshot.Values), High(Item.Values)) do Snapshot.Values[ValueIndex] := Item.Values[ValueIndex];
          Results.Add(Snapshot); Continue;
        end;
        Add(Item.Key, Item.DisplayName, Item.PanelKey, Item.Periods, Item.Kind, Item.FastPeriod, Item.SlowPeriod,
          Item.SignalPeriod, Item.SmoothKPeriod, Item.StandardDeviation, Item.ResetBySession, I);
      end;
      FSnapshots := Results.ToArray;
    finally Results.Free end;
    for Snapshot in FSnapshots do if FPanels.FindByKey(Snapshot.PanelKey) = nil then
    begin
      with FPanels.Add do begin Key := Snapshot.PanelKey; Title := Snapshot.Title; PanelType := nfptIndicator end;
    end;
    FViewport.SetDataCount(Length(FCandles));
    if FSelectedIndex >= Length(FCandles) then ClearSelection;
    if HoveredIndex >= Length(FCandles) then HoveredIndex := -1;
    FCacheData := Data; FDataRevision := Data.Revision; FOptionsRevision := FOptions.Revision;
    FIndicatorsRevision := FIndicators.Revision; FCacheValid := True; RefreshProductiveSidePanels;
  finally FBuildingCache := False end;
end;

function TNimbusFinancialWorkspace.PanelIsActive(Panel: TNimbusFinancialPanel): Boolean;
begin
  Result := (Panel <> nil) and Panel.Visible and (Panel.State <> nfpsHidden);
  if not Result then Exit;
  if SameText(Panel.Key, 'volume') then Result := FOptions.ShowVolume
  else if SameText(Panel.Key, 'rsi') then Result := FOptions.ShowRsi
  else if SameText(Panel.Key, 'macd') then Result := FOptions.ShowMacd
  else if SameText(Panel.Key, 'stochastic') then Result := FOptions.ShowStochastic
  else if SameText(Panel.Key, 'atr') then Result := FOptions.ShowAtr;
end;

procedure TNimbusFinancialWorkspace.SelectIndex(const Index: Integer);
var Effective: Integer;
begin
  Effective := Index; if (Effective < 0) or (Effective >= Length(FCandles)) then Effective := -1;
  if (FSelectedIndex = Effective) and (FRangeStartIndex = -1) then Exit;
  FSelectedIndex := Effective; FRangeStartIndex := -1; FRangeEndIndex := -1; Changed;
end;

procedure TNimbusFinancialWorkspace.SelectRange(const First, Last: Integer);
begin
  if (First < 0) or (Last < 0) or (Length(FCandles) = 0) then begin ClearSelection; Exit end;
  FRangeStartIndex := EnsureRange(Min(First, Last), 0, High(FCandles));
  FRangeEndIndex := EnsureRange(Max(First, Last), 0, High(FCandles)); FSelectedIndex := FRangeEndIndex; Changed;
end;

procedure TNimbusFinancialWorkspace.ClearSelection;
begin SelectIndex(-1) end;

procedure TNimbusFinancialWorkspace.ApplyRange(Button: TNimbusFinancialRangeButton);
var I: Integer; Finish, Start: TDateTime; Year, Month, Day: Word;
begin
  if (Button = nil) or not Button.Enabled or (Length(FCandles) = 0) then Exit;
  Finish := FCandles[High(FCandles)].XValue; Start := FCandles[0].XValue;
  case Button.RangeKind of
    nfrkDays: Start := IncDay(Finish, -Button.Value);
    nfrkMonths: Start := IncMonth(Finish, -Button.Value);
    nfrkYears: Start := IncYear(Finish, -Button.Value);
    nfrkYearToDate: begin DecodeDate(Finish, Year, Month, Day); Start := EncodeDate(Year, 1, 1) end;
    nfrkBars: begin FViewport.SetVisibleRange(Max(0, Length(FCandles) - Button.Value), Button.Value); Start := NaN end;
  end;
  if Button.RangeKind = nfrkAll then FViewport.ZoomToFit
  else if not IsNan(Start) then FViewport.SetVisibleTimeRange(Start, Finish, FCandles);
  FRangeSelector.Items.BeginUpdate;
  try for I := 0 to FRangeSelector.Items.Count - 1 do FRangeSelector.Items[I].Selected := FRangeSelector.Items[I] = Button
  finally FRangeSelector.Items.EndUpdate end;
end;

function TNimbusFinancialWorkspace.FindCandleByTime(const Time: TDateTime): Integer;
var I: Integer; Distance, Best: Double;
begin
  Result := -1; Best := MaxDouble;
  for I := 0 to High(FCandles) do begin Distance := Abs(FCandles[I].XValue - Time); if Distance < Best then begin Best := Distance; Result := I end end;
end;

function TNimbusFinancialWorkspace.GetAccessibleSummary: string;
var P: TNimbusFinancialDataPoint;
begin
  Result := FOptions.Symbol + ' ' + FOptions.Exchange + '. ' + IntToStr(Length(FCandles)) + ' candles.';
  if FAccessibility.IncludeVisibleRangeInSummary and (FViewport.LastVisibleIndex >= 0) then
    Result := Result + ' Visible ' + DateTimeToStr(FCandles[FViewport.FirstVisibleIndex].Time) + ' to ' + DateTimeToStr(FCandles[FViewport.LastVisibleIndex].Time) + '.';
  if FAccessibility.IncludeSelectionInSummary and (FSelectedIndex >= 0) and (FSelectedIndex < Length(FCandles)) then
  begin
    P := FCandles[FSelectedIndex]; Result := Result + ' Selected ' + DateTimeToStr(P.Time) +
      Format(' Open %.4f High %.4f Low %.4f Close %.4f Volume %.0f.', [P.Open, P.High, P.Low, P.Close, P.Volume]);
  end;
end;

procedure TNimbusFinancialWorkspace.RefreshProductiveSidePanels;
var Panel: TNimbusFinancialSidePanel; Item: TNimbusFinancialPanelItem; Candle: TNimbusFinancialDataPoint;
  Index, I, J, Up, Down, Added, Candidate: Integer; Snapshot: TNimbusFinancialIndicatorSnapshot;
  Previous, Change, Percent, Atr, Rsi, Macd, Vwap, Stop, Target, MaxVolume, MeanVolume: Double;
  Top: TArray<Integer>; Values: TArray<Double>; VolumeSpike: Boolean;
  function Side(const Key, Title: string; const Kind: TNimbusFinancialSidePanelKind;
    const Position: TNimbusFinancialSidePanelPosition; const Width, MinWidth, MaxWidth, Height: Integer): TNimbusFinancialSidePanel;
  begin
    Result := FSidePanels.FindByKey(Key);
    if Result <> nil then Exit;
    Result := FSidePanels.Add; Result.Key := Key; Result.Title := Title; Result.Kind := Kind;
    Result.Position := Position; Result.Width := Width; Result.MinimumWidth := MinWidth;
    Result.MaximumWidth := MaxWidth; Result.PreferredHeight := Height;
  end;
  function Indicator(const Kind: TNimbusFinancialIndicatorKind; const At: Integer): Double;
  var S: TNimbusFinancialIndicatorSnapshot;
  begin
    Result := NaN;
    for S in FSnapshots do if (S.Kind = Kind) and (At >= 0) and (At < Length(S.Values)) then Exit(S.Values[At]);
  end;
  procedure Metric(const Key, Text, Value: string);
  begin
    Item := Panel.Items.FindByKey(Key); if Item = nil then begin Item := Panel.Items.Add; Item.Key := Key; Item.Kind := nfpiMetric end;
    Item.Text := Text; Item.Value := Value; Item.CandleIndex := Index;
  end;
  procedure Mini(const Key, Text, Value: string; const Kind: TNimbusFinancialPanelItemKind;
    const Data: TArray<Double>; const Height: Integer);
  begin
    Metric(Key, Text, Value); Item.Kind := Kind; Item.Values := Data; Item.Height := Height;
  end;
  procedure Alert(const Key, Text: string; const Value, Direction: Double);
  begin Metric(Key, Text, FormatFloat('0.00', Value)); Item.ChangeValue := Direction; Inc(Added) end;
begin
  if not FOptions.AutoBuildProductiveSidePanels or FUpdatingSides then Exit;
  FUpdatingSides := True;
  try
  Index := FSelectedIndex; if Index < 0 then Index := HoveredIndex; if Index < 0 then Index := High(FCandles);
  if (FProductiveIndex = Index) and (FProductiveSideCount = FSidePanels.Count) and
    (FProductiveDataRevision = FDataRevision) and (FProductiveOptionsRevision = FOptions.Revision) and
    (FProductiveIndicatorsRevision = FIndicators.Revision) then Exit;
  Panel := Side('details', 'Details', nfspDetails, nfsppRight, 300, 220, 560, 330);
  Side('watchlist', 'Watchlist', nfspWatchList, nfsppLeft, 270, 210, 460, 355);
  Side('alerts', 'Alerts', nfspAlerts, nfsppRight, 286, 220, 520, 190);
  Side('top-volumes', 'Top volumes', nfspTopVolumes, nfsppRight, 300, 230, 560, 300);
  Side('transactions', 'Transactions', nfspTransactions, nfsppLeft, 286, 220, 520, 205);
  if (Index < 0) or (Index >= Length(FCandles)) then
  begin
    for I := 0 to FSidePanels.Count - 1 do
      if FSidePanels[I].Kind in [nfspDetails, nfspWatchList, nfspAlerts, nfspTopVolumes, nfspTransactions] then
      begin Panel := FSidePanels[I]; Panel.Items.BeginUpdate; try Panel.Items.Clear; Metric('empty', 'No data', '') finally Panel.Items.EndUpdate end end;
    Exit;
  end;
  Candle := FCandles[Index]; Panel.Items.BeginUpdate;
  try
    Panel.Items.Clear;
    Previous := Candle.Open; if Index > 0 then Previous := FCandles[Index - 1].Close;
    Change := Candle.Close - Previous; Percent := 0; if Abs(Previous) > 1E-7 then Percent := Change / Previous * 100;
    Metric('time', 'Time', DateTimeToStr(Candle.Time));
    Metric('open', 'Open', FormatFloat('0.00', Candle.Open)); Metric('high', 'High', FormatFloat('0.00', Candle.High));
    Metric('low', 'Low', FormatFloat('0.00', Candle.Low)); Metric('close', 'Close', FormatFloat('0.00', Candle.Close));
    Metric('change', 'Change', FormatFloat('+0.00;-0.00;0.00', Change)); Item.ChangeValue := Change;
    Metric('changePercent', 'Change %', FormatFloat('+0.00%;-0.00%;0.00%', Percent)); Item.ChangeValue := Change;
    Metric('range', 'Range', FormatFloat('0.00', Candle.High - Candle.Low));
    Metric('volume', 'Volume', FormatFloat('#,##0', Candle.Volume));
    for I := 0 to High(FSnapshots) do
    begin
      Snapshot := FSnapshots[I];
      if (Index < Length(Snapshot.Values)) and not IsNan(Snapshot.Values[Index]) and not IsInfinite(Snapshot.Values[Index]) then
        Metric(Snapshot.Key, Snapshot.Title, FormatFloat('0.00', Snapshot.Values[Index]))
      else Metric(Snapshot.Key, Snapshot.Title, '-');
    end;
    Mini('candle-shape', 'Candle shape', FormatFloat('0.00', Candle.High - Candle.Low), nfpiMiniDonut,
      [Max(0.01, Candle.High - Max(Candle.Open, Candle.Close)), Max(0.01, Abs(Candle.Close - Candle.Open)), Max(0.01, Min(Candle.Open, Candle.Close) - Candle.Low)], 112);
  finally Panel.Items.EndUpdate end;
  Atr := Indicator(nfikAtr, Index); Rsi := Indicator(nfikRsi, Index); Macd := Indicator(nfikMacd, Index); Vwap := Indicator(nfikVwap, Index);
  MeanVolume := 0; for I := Max(0, Index - 19) to Index do MeanVolume := MeanVolume + FCandles[I].Volume;
  MeanVolume := MeanVolume / Min(20, Index + 1); VolumeSpike := Candle.Volume > MeanVolume * 1.5;
  Panel := FSidePanels.FindByKey('watchlist'); Panel.Items.BeginUpdate;
  try
    Panel.Items.Clear; Up := 0; Down := 0;
    for I := Max(1, Length(FCandles) - 30) to High(FCandles) do
      if FCandles[I].Close >= FCandles[I - 1].Close then Inc(Up) else Inc(Down);
    Mini('watch-breadth', 'Market breadth', Format('%d / %d', [Up, Down]), nfpiMiniPie, [Max(1, Up), Max(1, Down)], 104);
    for I := Max(0, Length(FCandles) - 6) to High(FCandles) do
    begin
      SetLength(Values, Min(20, I + 1)); for J := 0 to High(Values) do Values[J] := FCandles[I - High(Values) + J].Close;
      Mini('watch-' + IntToStr(I), FormatDateTime('dd mmm', FCandles[I].Time), FormatFloat('0.00', FCandles[I].Close), nfpiSparkline, Values, 62);
      Previous := FCandles[I].Open; if I > 0 then Previous := FCandles[I - 1].Close;
      Item.ChangeValue := FCandles[I].Close - Previous; Item.Tag := I; Item.CandleIndex := I;
    end;
  finally Panel.Items.EndUpdate end;
  Panel := FSidePanels.FindByKey('alerts'); Panel.Items.BeginUpdate;
  try
    Panel.Items.Clear; Added := 0; Change := 35; if Candle.Close >= Candle.Open then Change := 55;
    Percent := Rsi; if IsNan(Percent) then Percent := 48;
    Previous := 38; if VolumeSpike then Previous := 82;
    Mini('risk-map', 'Signal mix', 'Live', nfpiMiniDonut, [Change, EnsureRange(Percent, 1.0, 100.0), Previous], 108);
    if not IsNan(Rsi) then
    begin
      if Rsi > FOptions.RsiOverboughtLevel then Alert('rsi-overbought', 'RSI overbought', Rsi, 1);
      if Rsi < FOptions.RsiOversoldLevel then Alert('rsi-oversold', 'RSI oversold', Rsi, -1);
    end;
    if not IsNan(Vwap) and (Candle.Close > Vwap) and (Candle.Open <= Vwap) then Alert('price-vwap', 'Price crossed VWAP', Vwap, 1);
    if VolumeSpike then Alert('volume-spike', 'Volume spike', Candle.Volume, 1);
    for Snapshot in FSnapshots do if (Snapshot.Kind = nfikMacd) and (Index > 0) and (Index < Length(Snapshot.Tertiary)) then
      if not IsNan(Snapshot.Tertiary[Index - 1]) and (Snapshot.Tertiary[Index] * Snapshot.Tertiary[Index - 1] < 0) then
        begin Alert('macd-cross', 'MACD cross', Macd, Sign(Macd)); Break end;
    if Added = 0 then Metric('empty', 'No active alerts', '');
  finally Panel.Items.EndUpdate end;
  Panel := FSidePanels.FindByKey('top-volumes'); Panel.Items.BeginUpdate;
  try
    Panel.Items.Clear; SetLength(Top, 0);
    for I := 0 to High(FCandles) do
    begin
      Candidate := Length(Top); for J := 0 to High(Top) do if FCandles[I].Volume > FCandles[Top[J]].Volume then begin Candidate := J; Break end;
      if Candidate >= 10 then Continue;
      SetLength(Top, Min(10, Length(Top) + 1)); for J := High(Top) downto Candidate + 1 do Top[J] := Top[J - 1]; Top[Candidate] := I;
    end;
    MaxVolume := Max(1.0, FCandles[Top[0]].Volume); SetLength(Values, Length(Top));
    for I := 0 to High(Top) do Values[I] := FCandles[Top[I]].Volume / MaxVolume * 100;
    Mini('volume-distribution', 'Volume distribution', 'Top ' + IntToStr(Length(Top)), nfpiMiniBar, Values, 78);
    for I in Top do
    begin Metric('volume-' + IntToStr(I), FormatDateTime('dd mmm yyyy', FCandles[I].Time), FormatFloat('#,##0', FCandles[I].Volume));
      Item.Kind := nfpiVolumeBar; Item.NumericValue := FCandles[I].Volume / MaxVolume; Item.Tag := I; Item.CandleIndex := I end;
  finally Panel.Items.EndUpdate end;
  Panel := FSidePanels.FindByKey('transactions'); Panel.Items.BeginUpdate;
  try
    Panel.Items.Clear; if IsNan(Atr) or (Atr <= 0) then Atr := Max(Candle.High - Candle.Low, Abs(Candle.Close - Candle.Open));
    Stop := Candle.Close - Atr * 1.5; Target := Candle.Close + Atr * 2;
    Metric('buy', 'Buy', FormatFloat('0.00', Candle.Close)); Item.ChangeValue := 1;
    Metric('sell', 'Sell', FormatFloat('0.00', Candle.Close)); Item.ChangeValue := -1;
    Metric('stop', 'Stop', FormatFloat('0.00', Stop)); Item.ChangeValue := -1;
    Metric('target', 'Target', FormatFloat('0.00', Target)); Item.ChangeValue := 1;
    Mini('reward-risk', 'Reward / Risk', FormatFloat('0.00', Max(0.01, Target - Candle.Close) / Max(0.01, Candle.Close - Stop)) + 'R',
      nfpiMiniDonut, [Max(0.01, Candle.Close - Stop), Max(0.01, Target - Candle.Close)], 102);
  finally Panel.Items.EndUpdate end;
  FProductiveIndex := Index; FProductiveSideCount := FSidePanels.Count;
  FProductiveDataRevision := FDataRevision; FProductiveOptionsRevision := FOptions.Revision;
  FProductiveIndicatorsRevision := FIndicators.Revision;
  finally FUpdatingSides := False end;
end;

end.

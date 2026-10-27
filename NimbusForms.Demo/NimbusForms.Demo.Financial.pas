unit NimbusForms.Demo.Financial;

interface

uses System.Classes, Vcl.Controls, NimbusForms.Controls.Panel, NimbusForms.Controls.TabControl,
  NimbusForms.Controls.FinancialBusinessChart, NimbusForms.Controls.ComboBox,
  NimbusForms.Controls.CheckBox, NimbusForms.Controls.ThemedLabel, NimbusForms.Controls.Button,
  NimbusForms.Rendering.Charts, NimbusForms.Charts.Financial.Types;

procedure AddNimbusFinancialDemo(Tabs: TThemedTabControl);

implementation

uses System.SysUtils, System.Math, System.DateUtils, Vcl.ComCtrls, Vcl.Dialogs,
  NimbusForms.Charts.Financial.Business.Types, NimbusForms.Charts.Financial.Palette,
  NimbusForms.Charts.Financial.Data;

resourcestring
  STab = 'Financial business';
  SThemes = 'Nimbus Dark|Nimbus Light|Trading Dark|Trading Blue|Terminal Black|Office Blue|Nord|Dracula|High Contrast';
  SPrices = 'Candlestick|OHLC|Line|Area';
  SLayouts = 'Default|Compact|Analytical|Trading desk|Minimal';
  SSides = 'Side panels';
  SColumns = 'Columns';
  SSettings = 'Settings';
  SFit = 'Fit all';
  SLoad = 'Load CSV';
  SExport = 'Export';
  SSaveProfile = 'Save profile';
  SLoadProfile = 'Load profile';
  SHint = 'Wheel: zoom; Shift+wheel: pan; drag: pan; Ctrl+drag: range; right-click: panel menu.';
  SSelected = '%s  O %.2f  H %.2f  L %.2f  C %.2f  V %.0f';
  SCsvFilter = 'CSV data (*.csv)|*.csv';
  SExportFilter = 'PNG image (*.png)|*.png|SVG image (*.svg)|*.svg|Visible candles (*.csv)|*.csv|Visible indicators (*.csv)|*.csv';
  SProfileFilter = 'Financial profile (*.json)|*.json';
  SExported = 'Export saved.';
  SRowEvent = '%s: %s / row %d [%s] / %s = %s / candle %d / watchlist clicks %d';
  SClick = 'Click';
  SDoubleClick = 'Double click';
  SHover = 'Hover';
  SContextMenu = 'Context menu';
  SPanelAction = '%s: %s';
  SHeaderClick = 'Header clicked';
  SCollapsed = 'Collapsed';
  SExpanded = 'Expanded';
  SClosed = 'Closed';
  SPinned = 'Pinned';
  SUnpinned = 'Unpinned';
  SResized = 'Resized';
  SMoved = 'Moved';
  SSettingsRequested = 'Settings requested';
  SScrolled = 'Scrolled';

type
  TNimbusFinancialDemo = class(TThemedPanel)
  private
    FChart: TThemedFinancialBusinessChart;
    FTop: TThemedPanel;
    FStatus: TThemedLabel;
    FThemes, FPrices, FLayouts: TThemedComboBox;
    FSides, FColumns: TThemedCheckBox;
    FButtons: array[0..6] of TThemedButton;
    FInitialized: Boolean;
    FWatchlistClicks: Integer;
    procedure BuildDemo;
    procedure LoadSample;
    procedure OptionsChanged(Sender: TObject);
    procedure Command(Sender: TObject);
    procedure CandleSelected(Sender: TObject; const Index: Integer; Candle: TNimbusFinancialDataPoint);
    procedure RowEvent(Sender: TObject; const Info: TNimbusFinancialRowEventInfo);
    procedure WatchlistRowClicked(Sender: TObject; const Info: TNimbusFinancialRowEventInfo);
    procedure PanelAction(Sender: TObject; const Info: TNimbusFinancialPanelActionInfo);
  protected
    procedure SetParent(AParent: TWinControl); override;
    procedure Resize; override;
  end;

procedure TNimbusFinancialDemo.SetParent(AParent: TWinControl);
begin
  inherited;
  if (AParent <> nil) and not FInitialized then
  begin FInitialized := True; BuildDemo end;
end;

procedure TNimbusFinancialDemo.BuildDemo;
var I: Integer; Captions: TArray<string>;
  function Combo(const Items: string): TThemedComboBox;
  begin
    Result := TThemedComboBox.Create(Self); Result.Parent := FTop;
    Result.Items.Delimiter := '|'; Result.Items.StrictDelimiter := True; Result.Items.DelimitedText := Items;
    Result.ItemIndex := 0; Result.OnChange := OptionsChanged;
  end;
begin
  Captions := [SSettings, SFit, SLoad, SExport, SSaveProfile, SLoadProfile, 'Copy image'];
  Align := alClient; ShowBorder := False;
  FTop := TThemedPanel.Create(Self); FTop.Parent := Self; FTop.Align := alTop; FTop.ShowBorder := False;
  FThemes := Combo(SThemes); FPrices := Combo(SPrices); FLayouts := Combo(SLayouts);
  FSides := TThemedCheckBox.Create(Self); FSides.Parent := FTop; FSides.Caption := SSides; FSides.Checked := True; FSides.OnClick := OptionsChanged;
  FColumns := TThemedCheckBox.Create(Self); FColumns.Parent := FTop; FColumns.Caption := SColumns; FColumns.OnClick := OptionsChanged;
  for I := 0 to High(FButtons) do
  begin FButtons[I] := TThemedButton.Create(Self); FButtons[I].Parent := FTop; FButtons[I].Caption := Captions[I]; FButtons[I].Tag := I; FButtons[I].OnClick := Command end;
  FStatus := TThemedLabel.Create(Self); FStatus.Parent := Self; FStatus.Align := alBottom;
  FStatus.Height := ScaleValue(28); FStatus.Caption := SHint;
  FChart := TThemedFinancialBusinessChart.Create(Self); FChart.Parent := Self; FChart.Align := alClient;
  FChart.Symbol := 'NIMBUS'; FChart.Exchange := 'DEMO'; FChart.Model.Title := 'NIMBUS / DEMO';
  FChart.Model.Subtitle := 'Daily OHLCV - technical analysis workspace'; FChart.ShowDashboardPanels := True;
  FChart.OnCandleClicked := CandleSelected; FChart.OnRowClicked := RowEvent; FChart.OnRowDoubleClicked := RowEvent;
  FChart.OnRowContextMenu := RowEvent; FChart.OnPanelAction := PanelAction;
  FThemes.ItemIndex := Ord(nftpTradingBlue); OptionsChanged(Self); LoadSample;
  FChart.SidePanels.FindByKey('watchlist').OnRowClicked := WatchlistRowClicked; Resize;
end;

procedure TNimbusFinancialDemo.Resize;
var X, Y, W: Integer;
  procedure Place(Control: TControl; const Width: Integer);
  begin
    W := ScaleValue(Width);
    if (X > ScaleValue(8)) and (X + W > ClientWidth - ScaleValue(8)) then begin X := ScaleValue(8); Inc(Y, ScaleValue(36)) end;
    Control.SetBounds(X, Y, W, ScaleValue(28)); Inc(X, W + ScaleValue(8));
  end;
begin
  inherited; if (FTop = nil) or (FChart = nil) then Exit;
  X := ScaleValue(8); Y := ScaleValue(6);
  Place(FThemes, 150); Place(FPrices, 116); Place(FLayouts, 124); Place(FSides, 110); Place(FColumns, 90);
  for var I := 0 to High(FButtons) do Place(FButtons[I], 100);
  FTop.Height := Y + ScaleValue(34);
end;

procedure TNimbusFinancialDemo.OptionsChanged(Sender: TObject);
begin
  if FChart = nil then Exit;
  FChart.BeginUpdate;
  try
    if (Sender = FThemes) or (Sender = Self) then FChart.ThemePreset := TNimbusFinancialThemePreset(FThemes.ItemIndex);
    FChart.PriceMode := TNimbusFinancialPriceMode(FPrices.ItemIndex);
    FChart.ShowDashboardPanels := FSides.Checked;
    if FColumns.Checked then FChart.SidePanelLayoutMode := nfslColumns else FChart.SidePanelLayoutMode := nfslStacked;
    if Sender = FLayouts then FChart.ApplyPanelLayoutPreset(TNimbusFinancialPanelLayoutPreset(FLayouts.ItemIndex));
  finally FChart.EndUpdate end;
end;

procedure TNimbusFinancialDemo.LoadSample;
var Data: TNimbusFinancialDataPointCollection; I: Integer; Time: TDateTime; Open, Close, High, Low, Volume: Double;
  Marker: TNimbusFinancialMarker; Annotation: TNimbusFinancialAnnotation;
begin
  Data := TNimbusFinancialDataPointCollection.Create(nil);
  try
    Time := EncodeDate(2023, 1, 2); Close := 142;
    Data.BeginUpdate;
    try
      for I := 0 to 719 do
      begin
        Open := Close + Sin(I * 1.31) * 0.8; Close := Open + 0.085 + Sin(I * 0.17) * 1.3 + Cos(I * 0.61) * 0.9;
        High := Max(Open, Close) + 0.35 + Abs(Sin(I * 0.77)) * 1.8;
        Low := Min(Open, Close) - 0.3 - Abs(Cos(I * 0.43)) * 1.6;
        Volume := 800000 + (1 + Sin(I * 0.31)) * 460000; if I mod 37 = 0 then Volume := Volume * 3.2;
        Data.Add(Time, Open, High, Low, Close, Volume); Time := IncDay(Time);
        while DayOfTheWeek(Time) > 5 do Time := IncDay(Time);
      end;
    finally Data.EndUpdate end;
    FChart.ReplaceCandles(Data);
    Marker := FChart.Markers.Add; Marker.Key := 'earnings'; Marker.CandleIndex := 650;
    Marker.Text := 'Earnings'; Marker.Kind := nfmkEarnings; Marker.Style := nfmsFlag; Marker.Anchor := nfmaAboveCandle;
    Annotation := FChart.Annotations.Add; Annotation.Key := 'support'; Annotation.Kind := nfakHorizontalLine;
    Annotation.Text := 'Support'; Annotation.StartValue := Data[650].Low; Annotation.EndValue := Annotation.StartValue;
    Annotation := FChart.Annotations.Add; Annotation.Key := 'trend'; Annotation.Kind := nfakTrendLine;
    Annotation.Text := 'Trend'; Annotation.StartIndex := 625; Annotation.EndIndex := 710;
    Annotation.StartValue := Data[625].Low; Annotation.EndValue := Data[710].Low;
  finally Data.Free end;
end;

procedure TNimbusFinancialDemo.CandleSelected(Sender: TObject; const Index: Integer; Candle: TNimbusFinancialDataPoint);
begin
  if Candle <> nil then FStatus.Caption := Format(SSelected, [DateTimeToStr(Candle.Time), Candle.Open, Candle.High, Candle.Low, Candle.Close, Candle.Volume]);
end;

procedure TNimbusFinancialDemo.RowEvent(Sender: TObject; const Info: TNimbusFinancialRowEventInfo);
var Action: string;
begin
  case Info.Action of nfraClicked: Action := SClick; nfraDoubleClicked: Action := SDoubleClick;
    nfraHovered: Action := SHover; else Action := SContextMenu end;
  FStatus.Caption := Format(SRowEvent, [Action, Info.PanelTitle, Info.VisibleRowIndex + 1, Info.RowKey, Info.Text, Info.Value, Info.CandleIndex, FWatchlistClicks]);
end;

procedure TNimbusFinancialDemo.WatchlistRowClicked(Sender: TObject; const Info: TNimbusFinancialRowEventInfo);
begin Inc(FWatchlistClicks) end;

procedure TNimbusFinancialDemo.PanelAction(Sender: TObject; const Info: TNimbusFinancialPanelActionInfo);
var Action: string;
begin
  case Info.Action of
    nfpaHeaderClicked: Action := SHeaderClick; nfpaCollapsed: Action := SCollapsed; nfpaExpanded: Action := SExpanded;
    nfpaClosed: Action := SClosed; nfpaPinned: Action := SPinned; nfpaUnpinned: Action := SUnpinned;
    nfpaResized: Action := SResized; nfpaMoved: Action := SMoved; nfpaSettingsRequested: Action := SSettingsRequested;
  else Action := SScrolled end;
  FStatus.Caption := Format(SPanelAction, [Info.Title, Action]);
end;

procedure TNimbusFinancialDemo.Command(Sender: TObject);
var OpenDialog: TOpenDialog; SaveDialog: TSaveDialog; Imported: TNimbusFinancialDataImportResult;
  Operation: Integer;
begin
  Operation := TThemedButton(Sender).Tag;
  try
    case Operation of
      0: FChart.EditPanelSettings(FChart.Panels.FindByKey('price'));
      1: FChart.ResetView;
      2, 5:
        begin
          OpenDialog := TOpenDialog.Create(Self);
          try
            if Operation = 2 then OpenDialog.Filter := SCsvFilter else OpenDialog.Filter := SProfileFilter;
            if not OpenDialog.Execute then Exit;
            if Operation = 2 then begin Imported := FChart.LoadCsv(OpenDialog.FileName); Imported.Free; FStatus.Caption := FChart.GetAccessibleSummary end
            else if not FChart.TryLoadPanelUserProfileFromFile(OpenDialog.FileName) then FStatus.Caption := FChart.LastError;
          finally OpenDialog.Free end;
        end;
      3, 4:
        begin
          SaveDialog := TSaveDialog.Create(Self);
          try
            SaveDialog.Options := SaveDialog.Options + [ofOverwritePrompt];
            if Operation = 3 then begin SaveDialog.Filter := SExportFilter; SaveDialog.DefaultExt := 'png' end
            else begin SaveDialog.Filter := SProfileFilter; SaveDialog.DefaultExt := 'json' end;
            if not SaveDialog.Execute then Exit;
            if Operation = 4 then FChart.SavePanelUserProfileToFile(SaveDialog.FileName)
            else case SaveDialog.FilterIndex of
              1: FChart.ExportPng(SaveDialog.FileName);
              2: FChart.ExportSvg(SaveDialog.FileName, FChart.Width, FChart.Height);
              3: FChart.SaveVisibleDataCsv(SaveDialog.FileName);
              4: FChart.SaveIndicatorsCsv(SaveDialog.FileName);
            end;
            FStatus.Caption := SExported;
          finally SaveDialog.Free end;
        end;
      6: FChart.CopyImageToClipboard;
    end;
  except on E: Exception do FStatus.Caption := E.Message end;
end;

procedure AddNimbusFinancialDemo(Tabs: TThemedTabControl);
var Page: TTabSheet;
begin
  if Tabs = nil then Exit; Page := TTabSheet.Create(Tabs.Owner); Page.PageControl := Tabs; Page.Caption := STab;
  with TNimbusFinancialDemo.Create(Page) do Parent := Page;
end;

end.

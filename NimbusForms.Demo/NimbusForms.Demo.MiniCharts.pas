{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Demo.MiniCharts;

interface

uses NimbusForms.Controls.TabControl;

procedure AddRemainingNimbusChartsDemo(const Tabs: TThemedTabControl);

implementation

uses System.Classes, System.SysUtils, System.StrUtils, System.Types, System.Math, Vcl.Controls, Vcl.ComCtrls, Vcl.Graphics, NimbusForms.Demo.Charts, NimbusForms.Controls.IdeColorPicker,
  NimbusForms.Controls.Panel, NimbusForms.Controls.ComboBox, NimbusForms.Controls.Button,
  NimbusForms.Controls.ThemedLabel, NimbusForms.Controls.Chart, NimbusForms.Controls.Sankey,
  NimbusForms.Controls.MiniCharts, NimbusForms.Charts.Types, NimbusForms.Rendering.Charts,
  NimbusForms.Charts.ProgressRingGrid.Types, NimbusForms.Charts.EdgeBundling.Types,
  NimbusForms.Charts.Financial.Types, NimbusForms.Charts.Maps.Data;

type
  TRemainingChartsDemo = class(TThemedPanel)
  private
    FChart: TThemedChart;
    FTypes, FVariants, FMapColors: TThemedComboBox;
    FStatus: TThemedLabel;
    FRevision: Integer;
    FInitialized, FBuilding, FUpdatingColors: Boolean;
    FColorModes, FColorSlots: TThemedComboBox;
    FColorPicker, FPalettePicker: TThemedIdeColorPickerButton;
    FPaletteColors: TArray<TColor>;
    procedure BuildDemo;
    procedure TypeChanged(Sender: TObject);
    procedure VariantChanged(Sender: TObject);
    procedure UpdateClick(Sender: TObject);
    procedure ResetClick(Sender: TObject);
    procedure Selected(Sender: TObject; const Hit: TNimbusChartHit);
    procedure LoadData;
    procedure ColorModeChanged(Sender: TObject);
    procedure ColorChanged(Sender: TObject; AOldColor, ANewColor: TColor);
    procedure ColorSlotChanged(Sender: TObject);
    procedure PaletteSelectionChanged(Sender: TObject);
    procedure PalettePicked(Sender: TObject; AColor: TColor; const ASource: string);
  protected
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

const ChartTypes: array[0..9] of TNimbusChartType = (nctSankey, nctProgressRingGrid, nctHierarchicalEdgeBundling, nctMarimekko, nctRadar, nctNestedPie, nctChoroplethMap, nctCountryMap, nctCandlestick, nctOhlc);
  ChartNames: array[0..9] of string = ('Sankey', 'Progress ring grid', 'Hierarchical edge bundling', 'Marimekko', 'Radar', 'Nested pie', 'Choropleth map', 'Country map', 'Candlestick', 'OHLC');

constructor TRemainingChartsDemo.Create(AOwner: TComponent);
begin inherited; Align := alClient end;

procedure TRemainingChartsDemo.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent); if (AParent = nil) or (csDestroying in ComponentState) or FInitialized then Exit;
  FInitialized := True; BuildDemo;
end;

procedure TRemainingChartsDemo.BuildDemo;
var Header, ColorPanel: TThemedPanel; Button: TThemedButton; LabelControl: TThemedLabel; I: Integer;
begin
  Header := TThemedPanel.Create(Self); Header.Parent := Self; Header.Align := alTop; Header.Height := 204;
  LabelControl := TThemedLabel.Create(Self); LabelControl.Parent := Header; LabelControl.SetBounds(12, 10, 90, 24); LabelControl.Caption := 'Chart type';
  FTypes := TThemedComboBox.Create(Self); FTypes.Parent := Header; FTypes.SetBounds(106, 8, 245, 30);
  for I := Low(ChartNames) to High(ChartNames) do FTypes.Items.Add(ChartNames[I]); FTypes.ItemIndex := 0; FTypes.OnChange := TypeChanged;
  LabelControl := TThemedLabel.Create(Self); LabelControl.Parent := Header; LabelControl.SetBounds(12, 52, 90, 24); LabelControl.Caption := 'Presentation';
  FVariants := TThemedComboBox.Create(Self); FVariants.Parent := Header; FVariants.SetBounds(106, 50, 245, 30); FVariants.OnChange := VariantChanged;
  Button := TThemedButton.Create(Self); Button.Parent := Header; Button.SetBounds(366, 8, 130, 30); Button.Caption := 'Update data'; Button.OnClick := UpdateClick;
  Button := TThemedButton.Create(Self); Button.Parent := Header; Button.SetBounds(508, 8, 130, 30); Button.Caption := 'Reset view'; Button.OnClick := ResetClick;
  LabelControl := TThemedLabel.Create(Self); LabelControl.Parent := Header; LabelControl.SetBounds(648, 49, 300, 34); LabelControl.Caption := 'Hover or click for details.';
  FMapColors := TThemedComboBox.Create(Self); FMapColors.Parent := Header; FMapColors.SetBounds(366, 50, 270, 30);
  FMapColors.Items.Add('8 highlighted regions'); FMapColors.Items.Add('All regions: distinct colors'); FMapColors.Items.Add('Themed value gradient');
  FMapColors.ItemIndex := 0; FMapColors.OnChange := VariantChanged; FMapColors.Visible := False;
  FStatus := TThemedLabel.Create(Self); FStatus.Parent := Self; FStatus.Align := alBottom; FStatus.Height := 38; FStatus.Caption := 'Select a diagram element';
  ColorPanel := TThemedPanel.Create(Self); ColorPanel.Parent := Header; ColorPanel.Align := alBottom; ColorPanel.Height := 128;
  CreateChartColorControls(Self, ColorPanel, FColorModes, FColorSlots, FColorPicker, FPalettePicker, ColorModeChanged, ColorChanged, PaletteSelectionChanged, PalettePicked, ColorSlotChanged);
  FColorModes.Items.Add('Single color');
  TypeChanged(Self);
end;

procedure TRemainingChartsDemo.TypeChanged(Sender: TObject);
begin
  if FBuilding or (FTypes.ItemIndex < 0) then Exit; FBuilding := True;
  try
    FreeAndNil(FChart); FVariants.Items.Clear;
    case ChartTypes[FTypes.ItemIndex] of
      nctSankey: begin FChart := TThemedSankeyChart.Create(Self); FVariants.Items.Add('Node labels and values'); FVariants.Items.Add('Link labels'); FVariants.Items.Add('Flat link colors'); FVariants.Items.Add('Automatic nodes'); FVariants.Items.Add('Cyclic flow') end;
      nctProgressRingGrid: begin FChart := TThemedProgressRingGrid.Create(Self); FVariants.Items.Add('Tile grid'); FVariants.Items.Add('Concentric'); FVariants.Items.Add('Master and satellites'); FVariants.Items.Add('Segmented rings'); FVariants.Items.Add('Layered rings'); FVariants.Items.Add('Stacked segments'); FVariants.Items.Add('Threshold colors'); FVariants.Items.Add('Indeterminate') end;
      nctHierarchicalEdgeBundling: begin FChart := TThemedHierarchicalEdgeBundlingChart.Create(Self); FVariants.Items.Add('Bundled hierarchy'); FVariants.Items.Add('Direct links'); FVariants.Items.Add('Strong bundling'); FVariants.Items.Add('Multi selection') end;
      nctMarimekko: begin FChart := TThemedMarimekkoChart.Create(Self); FVariants.Items.Add('Normalized columns'); FVariants.Items.Add('Absolute heights'); FVariants.Items.Add('Values and percentages') end;
      nctChoroplethMap: begin FChart := TThemedChart.Create(Self); FVariants.Items.Add('World'); FVariants.Items.Add('Europe'); FVariants.Items.Add('Africa'); FVariants.Items.Add('Americas'); FVariants.Items.Add('Asia'); FVariants.Items.Add('Oceania') end;
      nctCountryMap: begin FChart := TThemedChart.Create(Self); FVariants.Items.Add('United States'); FVariants.Items.Add('Germany'); FVariants.Items.Add('United Kingdom'); FVariants.Items.Add('France'); FVariants.Items.Add('Japan'); FVariants.Items.Add('Brazil') end;
      nctCandlestick, nctOhlc: begin FChart := TThemedFinancialChart.Create(Self); FVariants.Items.Add('Price and volume'); FVariants.Items.Add('Technical indicators'); FVariants.Items.Add('Volume bubbles'); FVariants.Items.Add('Price only') end;
    else FChart := TThemedChart.Create(Self); FVariants.Items.Add('Standard'); FVariants.Items.Add('Show values') end;
    FChart.Parent := Self; FChart.Align := alClient; FChart.ChartType := ChartTypes[FTypes.ItemIndex]; FChart.OnChartElementSelected := Selected;
    FMapColors.Visible := FChart.ChartType in [nctChoroplethMap, nctCountryMap];
    FChart.TabStop := True; FChart.ShowLegend := FChart.ChartType = nctMarimekko; FChart.ShowAnimation := False; FVariants.ItemIndex := 0;
  finally FBuilding := False end;
  LoadData;
end;

procedure TRemainingChartsDemo.VariantChanged(Sender: TObject);
begin if not FBuilding then LoadData end;

procedure TRemainingChartsDemo.LoadData;
const Countries: array[0..5] of string = ('USA', 'DEU', 'GBR', 'FRA', 'JPN', 'BRA');
var M: TNimbusChartModel; S: TNimbusChartSeries; I, J, Variant: Integer; Item: TNimbusProgressRingItem; Layer: TNimbusProgressRingLayer;
  Node: TNimbusHierarchicalEdgeBundlingNode; Link: TNimbusHierarchicalEdgeBundlingLink; Shapes: TArray<TNimbusMapShape>; P: TNimbusFinancialDataPoint;
  Open, Close, Value: Double; Threshold: TNimbusProgressRingThreshold; RegionPoint: TNimbusChartPoint; Added: Integer;
begin
  if FChart = nil then Exit; M := FChart.Model; Variant := Max(0, FVariants.ItemIndex); FChart.BeginUpdate;
  try
    FChart.ResetView; M.Series.Clear; M.FinancialData.Clear; M.Sankey.Nodes.Clear; M.Sankey.Links.Clear; M.Sankey.StageTitles.Clear;
    M.ProgressRingGrid.Items.Clear; M.ProgressRingGrid.Thresholds.Clear; M.EdgeBundling.Nodes.Clear; M.EdgeBundling.Links.Clear; M.EdgeBundling.SelectedNodeIds.Clear; M.EdgeBundling.SelectedLinkKeys.Clear;
    FChart.Title := ChartNames[FTypes.ItemIndex]; FChart.Subtitle := 'Theme-aware rendering, shared geometry and interactive selection';
    FChart.ShowAxes := FChart.ChartType in [nctRadar, nctCandlestick, nctOhlc]; FChart.ShowGrid := FChart.ShowAxes; FChart.ShowValues := Variant = 1;
    case FChart.ChartType of
      nctSankey:
      begin
        FChart.Subtitle := 'Energy network: generation, processing, distribution, demand and outcomes';
        M.Sankey.ShowNodeLabels := True; M.Sankey.ShowNodeValues := True; M.Sankey.ShowLinkLabels := Variant = 1; M.Sankey.UseLinkGradient := Variant <> 2;
        M.Sankey.StageTitles.Add('Generation'); M.Sankey.StageTitles.Add('Processing'); M.Sankey.StageTitles.Add('Distribution'); M.Sankey.StageTitles.Add('Demand'); M.Sankey.StageTitles.Add('Outcomes');
        if Variant <> 3 then
        begin
          M.Sankey.Nodes.Add('solar', 'Solar'); M.Sankey.Nodes.Add('wind', 'Wind'); M.Sankey.Nodes.Add('hydro', 'Hydro'); M.Sankey.Nodes.Add('gas', 'Natural gas');
          M.Sankey.Nodes.Add('inverter', 'Inverters'); M.Sankey.Nodes.Add('storage', 'Battery storage'); M.Sankey.Nodes.Add('turbine', 'Gas turbines'); M.Sankey.Nodes.Add('exchange', 'Energy exchange');
          M.Sankey.Nodes.Add('north', 'North grid'); M.Sankey.Nodes.Add('south', 'South grid'); M.Sankey.Nodes.Add('local', 'Local grids');
          M.Sankey.Nodes.Add('homes', 'Residential'); M.Sankey.Nodes.Add('industry', 'Industry'); M.Sankey.Nodes.Add('transport', 'Transport'); M.Sankey.Nodes.Add('services', 'Services');
          M.Sankey.Nodes.Add('heating', 'Heat'); M.Sankey.Nodes.Add('production', 'Production'); M.Sankey.Nodes.Add('mobility', 'Mobility');
        end;
        M.Sankey.Links.Add('solar', 'inverter', 38 + FRevision mod 9); M.Sankey.Links.Add('solar', 'storage', 12);
        M.Sankey.Links.Add('wind', 'inverter', 46); M.Sankey.Links.Add('wind', 'storage', 14); M.Sankey.Links.Add('wind', 'exchange', 10);
        M.Sankey.Links.Add('hydro', 'inverter', 24); M.Sankey.Links.Add('hydro', 'exchange', 12);
        M.Sankey.Links.Add('gas', 'turbine', 48); M.Sankey.Links.Add('gas', 'exchange', 9);
        M.Sankey.Links.Add('inverter', 'north', 62); M.Sankey.Links.Add('inverter', 'south', 36); M.Sankey.Links.Add('inverter', 'local', 10 + FRevision mod 9);
        M.Sankey.Links.Add('storage', 'north', 12); M.Sankey.Links.Add('storage', 'local', 14);
        M.Sankey.Links.Add('turbine', 'south', 34); M.Sankey.Links.Add('turbine', 'local', 14);
        M.Sankey.Links.Add('exchange', 'north', 14); M.Sankey.Links.Add('exchange', 'south', 17);
        M.Sankey.Links.Add('north', 'homes', 31); M.Sankey.Links.Add('north', 'industry', 39); M.Sankey.Links.Add('north', 'transport', 18);
        M.Sankey.Links.Add('south', 'homes', 27); M.Sankey.Links.Add('south', 'industry', 28); M.Sankey.Links.Add('south', 'services', 32);
        M.Sankey.Links.Add('local', 'homes', 15); M.Sankey.Links.Add('local', 'transport', 11); M.Sankey.Links.Add('local', 'services', 12);
        M.Sankey.Links.Add('homes', 'heating', 55); M.Sankey.Links.Add('homes', 'mobility', 18);
        M.Sankey.Links.Add('industry', 'production', 67); M.Sankey.Links.Add('transport', 'mobility', 29);
        M.Sankey.Links.Add('services', 'heating', 17); M.Sankey.Links.Add('services', 'production', 27);
        if Variant = 4 then M.Sankey.Links.Add('storage', 'solar', 8);
      end;
      nctProgressRingGrid:
      begin
        M.ProgressRingGrid.LayoutMode := nprlTileGrid; if Variant = 1 then M.ProgressRingGrid.LayoutMode := nprlConcentric else if Variant = 2 then M.ProgressRingGrid.LayoutMode := nprlMasterSatellite;
        M.ProgressRingGrid.CenterTitle := 'Average'; M.ProgressRingGrid.ShowDetailPanel := Variant in [0, 1, 2];
        for I := 0 to 5 do
        begin
          Item := M.ProgressRingGrid.Items.Add; Item.Title := 'Goal ' + IntToStr(I + 1); Item.Value := 25 + (I * 13 + FRevision * 7) mod 75;
          if Variant = 3 then Item.RenderStyle := nprsSegmented;
          if Variant = 4 then for J := 0 to 2 do begin Layer := Item.Layers.Add; Layer.Title := 'Layer ' + IntToStr(J + 1); Layer.Value := 20 + (I * 17 + J * 21) mod 80 end;
          if Variant = 5 then begin Item.RenderStyle := nprsStacked; for J := 0 to 2 do with Item.Segments.Add do begin &Label := 'Segment ' + IntToStr(J + 1); Value := J + 1 end end;
          if Variant = 6 then begin Item.RenderStyle := nprsThreshold; Threshold := Item.Thresholds.Add; Threshold.Minimum := 0; Threshold.Maximum := 49; Threshold.Color := $005053EF;
            Threshold := Item.Thresholds.Add; Threshold.Minimum := 50; Threshold.Maximum := 100; Threshold.Color := $009AA626 end;
          if Variant = 7 then Item.IsIndeterminate := True;
        end;
      end;
      nctHierarchicalEdgeBundling:
      begin
        M.EdgeBundling.BundleLinks := Variant <> 1; M.EdgeBundling.BundleStrength := 0.82; if Variant = 2 then M.EdgeBundling.BundleStrength := 1;
        for I := 0 to 3 do
        begin
          Node := M.EdgeBundling.Nodes.Add; Node.Id := 'group' + IntToStr(I); Node.Caption := 'Team ' + IntToStr(I + 1);
          for J := 0 to 5 do begin Node := M.EdgeBundling.Nodes.Add; Node.Id := 'node' + IntToStr(I * 6 + J); Node.Caption := 'Service ' + IntToStr(I * 6 + J + 1); Node.ParentId := 'group' + IntToStr(I); Node.GroupKey := 'Team ' + IntToStr(I + 1) end;
        end;
        for I := 0 to 23 do for J := 0 to 2 do
        begin Link := M.EdgeBundling.Links.Add; Link.SourceId := 'node' + IntToStr(I); Link.TargetId := 'node' + IntToStr((I + 6 + J * 5 + FRevision mod 3) mod 24);
          Link.Value := 8 + (I * 7 + J * 11) mod 35; Link.Category := 'Flow ' + IntToStr((I + J) mod 4 + 1) end;
        if Variant = 3 then begin M.EdgeBundling.SelectedNodeIds.Add('node0'); M.EdgeBundling.SelectedNodeIds.Add('node4') end;
      end;
      nctMarimekko, nctRadar, nctNestedPie:
      begin
        M.MarimekkoOptions.NormalizeColumns := Variant <> 1; M.MarimekkoOptions.ShowSegmentPercent := Variant = 2; M.MarimekkoOptions.ShowSegmentValues := Variant = 2;
        for I := 0 to 2 do begin S := M.AddSeries('Product ' + IntToStr(I + 1)); for J := 0 to 4 do S.Points.Add(J, 15 + (I * 17 + J * 11 + FRevision * 7) mod 70, 'Market ' + IntToStr(J + 1)) end;
      end;
      nctChoroplethMap, nctCountryMap:
      begin
        if FChart.ChartType = nctCountryMap then begin M.Options.CountryMapIsoA3 := Countries[EnsureRange(Variant, 0, 5)]; M.Options.CountryMapShowCities := True; M.Options.CountryMapShowCityLabels := True; Shapes := NimbusCountryMapShapes(M.Options.CountryMapIsoA3) end
        else begin case Variant of 1: M.Options.MapRegion := ncmrEurope; 2: M.Options.MapRegion := ncmrAfrica; 3: M.Options.MapRegion := ncmrAmericas; 4: M.Options.MapRegion := ncmrAsia; 5: M.Options.MapRegion := ncmrOceania else M.Options.MapRegion := ncmrWorld end; Shapes := NimbusWorldMapShapes end;
        M.Options.MapColorMode := ncmCategorical;
        if FMapColors.ItemIndex = 2 then M.Options.MapColorMode := ncmValueGradient;
        S := M.AddSeries('Activity'); Added := 0;
        for I := 0 to High(Shapes) do
        begin
          if (FMapColors.ItemIndex = 0) and (Added >= 8) then Break;
          if (FChart.ChartType = nctChoroplethMap) and (FMapColors.ItemIndex = 0) then
          begin
            if M.Options.MapRegion = ncmrWorld then
            begin if not MatchText(Shapes[I].Code, ['USA', 'CAN', 'BRA', 'DEU', 'FRA', 'IND', 'CHN', 'AUS']) then Continue end
            else if (Variant = 1) and not SameText(Shapes[I].Region, 'Europe') then Continue
            else if (Variant = 2) and not SameText(Shapes[I].Region, 'Africa') then Continue
            else if (Variant = 3) and not (SameText(Shapes[I].Region, 'North America') or SameText(Shapes[I].Region, 'South America')) then Continue
            else if (Variant = 4) and not SameText(Shapes[I].Region, 'Asia') then Continue
            else if (Variant = 5) and not SameText(Shapes[I].Region, 'Oceania') then Continue;
          end;
          RegionPoint := S.Points.Add(I, 10 + (I * 37 + FRevision * 17) mod 100, Shapes[I].Code);
          if FMapColors.ItemIndex = 0 then RegionPoint.Color := M.Palette.GetSeriesColor(Added);
          Inc(Added);
        end;
        FChart.Subtitle := 'Mouse wheel: zoom. Drag: pan. Click a region or city for details.';
      end;
      nctCandlestick, nctOhlc:
      begin
        M.FinancialOptions.ShowVolumePanel := Variant <> 3; M.FinancialOptions.ShowMacdPanel := Variant = 1; M.FinancialOptions.ShowRsiPanel := Variant = 1; M.FinancialOptions.ShowStochasticPanel := Variant = 1;
        M.FinancialOptions.VolumeDisplayMode := nfvBars; if Variant = 2 then M.FinancialOptions.VolumeDisplayMode := nfvBubbles; Close := 100;
        for I := 0 to 89 do begin Open := Close; Close := Open + Sin((I + FRevision) * 0.7) * 2 + 0.1;
          P := M.FinancialData.Add(I, Open, Max(Open, Close) + 1.5, Min(Open, Close) - 1.2, Close, 1000 + (I * 131) mod 4000); P.&Label := 'Day ' + IntToStr(I + 1); if I mod 20 = 0 then P.EventText := 'Results announcement' end;
        FChart.Subtitle := 'Mouse wheel: zoom. Shift/Ctrl constrain axes. Drag: pan. Home: reset.';
      end;
    end;
    ColorModeChanged(Self);
    FStatus.Caption := 'Select a diagram element';
  finally FChart.EndUpdate end;
end;

procedure TRemainingChartsDemo.ColorModeChanged(Sender: TObject);
var Colors: TArray<TColor>; I: Integer;
begin
  if FBuilding or (FChart = nil) or (FColorModes = nil) then Exit;
  if Length(FPaletteColors) = 0 then FPaletteColors := FChart.Model.Palette.Colors;
  if FColorModes.ItemIndex = 0 then begin FChart.ColorMode := nccTheme; Exit end;
  Colors := Copy(FPaletteColors); if FColorModes.ItemIndex = 3 then Colors := [FColorPicker.SelectedColor];
  FChart.BeginUpdate;
  try
    FChart.Model.Palette.ApplyTheme(Palette); FChart.Model.Palette.Colors := Colors;
    if (FChart.ChartType in [nctChoroplethMap, nctCountryMap]) and (FMapColors.ItemIndex = 0) and (FChart.Model.Series.Count > 0) then
      for I := 0 to FChart.Model.Series[0].Points.Count - 1 do FChart.Model.Series[0].Points[I].Color := FChart.Model.Palette.GetSeriesColor(I);
    if Length(Colors) > 0 then begin FChart.Model.Palette.AccentColor := Colors[0]; FChart.Model.Palette.InfoColor := Colors[0] end;
    FChart.ColorMode := nccCustom; if FColorModes.ItemIndex = 2 then FChart.ColorMode := nccAdaptiveCustom;
  finally FChart.EndUpdate end;
end;

procedure TRemainingChartsDemo.ColorChanged(Sender: TObject; AOldColor, ANewColor: TColor);
var Index: Integer;
begin
  if FUpdatingColors or FBuilding or (csDestroying in ComponentState) then Exit;
  Index := FColorSlots.ItemIndex; if (Index >= 0) and (Index < Length(FPaletteColors)) then FPaletteColors[Index] := ANewColor;
  if FColorModes.ItemIndex = 0 then FColorModes.ItemIndex := 2; ColorModeChanged(Sender);
end;

procedure TRemainingChartsDemo.ColorSlotChanged(Sender: TObject);
var Index: Integer;
begin
  if FUpdatingColors or (csDestroying in ComponentState) then Exit; Index := FColorSlots.ItemIndex;
  if (Index < 0) or (Index >= Length(FPaletteColors)) then Exit; FUpdatingColors := True;
  try FColorPicker.SelectedColor := FPaletteColors[Index] finally FUpdatingColors := False end;
end;

procedure TRemainingChartsDemo.PaletteSelectionChanged(Sender: TObject);
var I: Integer; Colors: TArray<TColor>;
begin
  if FUpdatingColors or FBuilding or (csDestroying in ComponentState) then Exit;
  Colors := SelectedChartPaletteColors(FPalettePicker.Picker); if Length(Colors) = 0 then Exit; FPaletteColors := Colors;
  FUpdatingColors := True; FColorSlots.Items.BeginUpdate;
  try
    FColorSlots.Items.Clear; for I := 0 to High(FPaletteColors) do FColorSlots.Items.Add('Color ' + IntToStr(I + 1));
    FColorSlots.ItemIndex := 0; FColorPicker.SelectedColor := FPaletteColors[0];
  finally FColorSlots.Items.EndUpdate; FUpdatingColors := False end;
  if FColorModes.ItemIndex in [0, 3] then FColorModes.ItemIndex := 2; ColorModeChanged(Sender);
end;

procedure TRemainingChartsDemo.PalettePicked(Sender: TObject; AColor: TColor; const ASource: string);
begin PaletteSelectionChanged(Sender) end;

procedure TRemainingChartsDemo.UpdateClick(Sender: TObject);
begin Inc(FRevision); LoadData end;

procedure TRemainingChartsDemo.ResetClick(Sender: TObject);
begin if FChart <> nil then begin FChart.ResetView; FChart.ClearSelection end end;

procedure TRemainingChartsDemo.Selected(Sender: TObject; const Hit: TNimbusChartHit);
begin if Hit.Area = nchaNone then FStatus.Caption := 'Selection cleared' else FStatus.Caption := StringReplace(Hit.Text, sLineBreak, '  ', [rfReplaceAll]) end;

procedure AddRemainingNimbusChartsDemo(const Tabs: TThemedTabControl);
var Page: TTabSheet; Demo: TRemainingChartsDemo;
begin
  if Tabs = nil then Exit; Page := TTabSheet.Create(Tabs.Owner); Page.PageControl := Tabs; Page.Caption := 'Advanced charts';
  Demo := TRemainingChartsDemo.Create(Page); Demo.Parent := Page;
end;

end.

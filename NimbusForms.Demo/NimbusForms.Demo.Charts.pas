{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Demo.Charts;

interface

uses
  System.Classes, System.Types, System.SysUtils, System.Math, Vcl.Graphics, Vcl.Controls, Vcl.ComCtrls, Vcl.ExtCtrls,
  NimbusForms.Controls.VScrollBar, NimbusForms.Controls.HScrollBar, NimbusForms.Charts.Functions,
  NimbusForms.Controls.TabControl, NimbusForms.Controls.Panel, NimbusForms.Controls.Button,
  NimbusForms.Controls.ThemedLabel, NimbusForms.Controls.CheckBox, NimbusForms.Controls.ComboBox,
  NimbusForms.Controls.Sparkline, NimbusForms.Charts.Sparkline.Types, NimbusForms.Controls.Chart,
  NimbusForms.Charts.Types, NimbusForms.Rendering.Charts, NimbusForms.Controls.IdeColorPicker, NimbusForms.ColorPalettes.Catalog, NimbusForms.Charts.Violin.Types, NimbusForms.Charts.Ridgeline.Types, NimbusForms.Controls.Ridgeline, NimbusForms.Controls.StreamGraph, NimbusForms.Charts.StreamGraph.Types, NimbusForms.Controls.Treemap, NimbusForms.Charts.Treemap.Types, NimbusForms.Charts.Sunburst.Types, NimbusForms.Controls.Sunburst;

type
  TNimbusChartsDemo = class(TThemedPanel)
  private
    FSparklines: array[0..4] of TThemedSparkline;
    FStatus: TThemedLabel;
    FTimer: TTimer;
    FTick: Integer;
    FInitialized: Boolean;
    FColorModes, FColorSlots: TThemedComboBox;
    FUpdatingColors: Boolean;
    FColorPicker, FPalettePicker: TThemedIdeColorPickerButton;
    FPaletteColors: TArray<TColor>;
    procedure BuildDemo;
    procedure UpdateClick(Sender: TObject);
    procedure AnimateClick(Sender: TObject);
    procedure PointClick(Sender: TObject; APointIndex: Integer; AValue: Double; const ALocation: TPoint);
    procedure TimerTick(Sender: TObject);
    procedure ColorModeChanged(Sender: TObject);
    procedure ColorChanged(Sender: TObject; AOldColor, ANewColor: TColor);
    procedure PaletteSelectionChanged(Sender: TObject);
    procedure PalettePicked(Sender: TObject; AColor: TColor; const ASource: string);
    procedure ColorSlotChanged(Sender: TObject);
  protected
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

type
  TNimbusGeneralChartsDemo = class(TThemedPanel)
  private
    FChart: TThemedChart;
    FBaseChart: TThemedRidgelineChart;
    FStreamChart: TThemedStreamGraphChart;
    FTreemapChart: TThemedTreemapChart;
    FSunburstChart: TThemedSunburstChart;
    FSunburstControls: TThemedPanel;
    FSunburstMarking, FSunburstHole: TThemedComboBox;
    FSunburstRoot, FSunburstValues: TThemedCheckBox;
    FTreemapControls: TThemedPanel;
    FTreemapLayout, FTreemapLabels, FTreemapMarking: TThemedComboBox;
    FStreamControls: TThemedPanel;
    FStreamBaseline, FStreamCurve, FStreamSelection: TThemedComboBox;
    FTypes: TThemedComboBox;
    FLooks, FHeatPreset: TThemedComboBox;
    FGlow: TThemedCheckBox;
    FBackPicker, FPlotPicker: TThemedIdeColorPickerButton;
    FStatus: TThemedLabel;
    FRevision: Integer;
    FKpiHost: TThemedPanel;
    FKpis: array[0..2] of TThemedChart;
    FLayoutBusy: Boolean;
    FColorModes, FColorSlots: TThemedComboBox;
    FUpdatingColors: Boolean;
    FColorPicker, FPalettePicker: TThemedIdeColorPickerButton;
    FPaletteColors: TArray<TColor>;
    FInitialized: Boolean;
    FViolinControls: TThemedPanel;
    FViolinPresentation, FViolinPoints, FViolinDensity, FViolinBandwidth: TThemedComboBox;
    FViolinStatistics: TThemedCheckBox;
    FRidgelineControls: TThemedPanel;
    FRidgelineScale, FRidgelineSort, FRidgelineCurve, FRidgelineOverlap: TThemedComboBox;
    procedure BuildDemo;
    procedure ViolinOptionsChanged(Sender: TObject);
    procedure RidgelineOptionsChanged(Sender: TObject);
    procedure StreamOptionsChanged(Sender: TObject);
    procedure TreemapOptionsChanged(Sender: TObject);
    procedure SunburstOptionsChanged(Sender: TObject);
    procedure TypeChanged(Sender: TObject);
    procedure HeatPresetChanged(Sender: TObject);
    procedure LookChanged(Sender: TObject);
    procedure GlowChanged(Sender: TObject);
    procedure SurfaceChanged(Sender: TObject; AOldColor, ANewColor: TColor);
    procedure UpdateClick(Sender: TObject);
    procedure ResetClick(Sender: TObject);
    procedure PointSelected(Sender: TObject; const AHit: TNimbusChartHit);
    procedure LoadData;
    procedure LayoutKpis(Sender: TObject);
    procedure UpdateKpis;
    procedure ColorModeChanged(Sender: TObject);
    procedure ColorChanged(Sender: TObject; AOldColor, ANewColor: TColor);
    procedure PaletteSelectionChanged(Sender: TObject);
    procedure PalettePicked(Sender: TObject; AColor: TColor; const ASource: string);
    procedure ColorSlotChanged(Sender: TObject);
  protected
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

function SelectedChartPaletteColors(Picker: TThemedIdeColorPicker): TArray<TColor>;
procedure CreateChartColorControls(AOwner: TComponent; AParent: TWinControl; out Modes, Slots: TThemedComboBox; out Picker, PalettePicker: TThemedIdeColorPickerButton; const OnMode: TNotifyEvent; const OnColor: TIdeColorChangedEvent; const OnPalette: TNotifyEvent; const OnPaletteColor: TIdeColorSelectedEvent; const OnSlot: TNotifyEvent);

procedure AddNimbusChartsDemo(ATabs: TThemedTabControl);

implementation

uses NimbusForms.Demo.Financial;


function SelectedChartPaletteColors(Picker: TThemedIdeColorPicker): TArray<TColor>;
var Catalog: TNimbusColorPaletteLibrary; Category: TNimbusColorPaletteCategory; Palette: TNimbusColorPalette;
  CategoryIndex, PaletteIndex, I, Count: Integer;
begin
  Result := nil; if Picker = nil then Exit; Catalog := Picker.PaletteLibrary; if Catalog = nil then Exit;
  CategoryIndex := Catalog.FindCategory(Picker.SelectedCategoryId); if CategoryIndex < 0 then Exit;
  Category := Catalog.CategoryAt(CategoryIndex); PaletteIndex := Catalog.FindPalette(CategoryIndex, Picker.SelectedPaletteId); if PaletteIndex < 0 then Exit;
  Palette := Category.PaletteAt(PaletteIndex); Count := Palette.ColorCount;
  if Count = 45 then
  begin SetLength(Result, 8); for I := 0 to High(Result) do Result[I] := Palette.ColorAt(I * 5 + 2) end
  else begin SetLength(Result, Count); for I := 0 to High(Result) do Result[I] := Palette.ColorAt(I) end;
end;

procedure CreateChartColorControls(AOwner: TComponent; AParent: TWinControl; out Modes, Slots: TThemedComboBox; out Picker, PalettePicker: TThemedIdeColorPickerButton; const OnMode: TNotifyEvent; const OnColor: TIdeColorChangedEvent; const OnPalette: TNotifyEvent; const OnPaletteColor: TIdeColorSelectedEvent; const OnSlot: TNotifyEvent);
var LabelControl: TThemedLabel; I: Integer;
begin
  LabelControl := TThemedLabel.Create(AOwner); LabelControl.Parent := AParent; LabelControl.SetBounds(12, 58, 80, 24); LabelControl.Caption := 'Colors';
  Modes := TThemedComboBox.Create(AOwner); Modes.Parent := AParent; Modes.SetBounds(92, 54, 210, 30);
  Modes.Items.Add('Theme'); Modes.Items.Add('Custom'); Modes.Items.Add('Adaptive custom'); Modes.ItemIndex := 0; Modes.OnChange := OnMode;
  Picker := TThemedIdeColorPickerButton.Create(AOwner); Picker.Parent := AParent; Picker.SetBounds(316, 90, 150, 30);
  Picker.SelectedColor := $00FFB020; Picker.ButtonText := 'Selected color'; Picker.OnSelectedColorChanged := OnColor;
  PalettePicker := TThemedIdeColorPickerButton.Create(AOwner); PalettePicker.Parent := AParent; PalettePicker.SetBounds(480, 54, 150, 30);
  PalettePicker.ButtonText := 'Series palette'; PalettePicker.PaletteMode := icpmLibrary; PalettePicker.CloseOnPaletteColorSelected := True;
  PalettePicker.Picker.PaletteLibrary := Picker.Picker.PaletteLibrary; PalettePicker.Picker.OnLibraryPaletteChanged := OnPalette; PalettePicker.OnColorSelected := OnPaletteColor;
  LabelControl := TThemedLabel.Create(AOwner); LabelControl.Parent := AParent; LabelControl.SetBounds(12, 94, 80, 24); LabelControl.Caption := 'Palette color';
  Slots := TThemedComboBox.Create(AOwner); Slots.Parent := AParent; Slots.SetBounds(92, 90, 210, 30); for I := 1 to 8 do Slots.Items.Add('Color ' + IntToStr(I)); Slots.ItemIndex := 0; Slots.OnChange := OnSlot;
  LabelControl := TThemedLabel.Create(AOwner); LabelControl.Parent := AParent; LabelControl.SetBounds(316, 58, 150, 24); LabelControl.Caption := 'Theme influence: 12%';
end;

constructor TNimbusChartsDemo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner); Align := alClient;
end;

procedure TNimbusChartsDemo.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  if (AParent = nil) or (csDestroying in ComponentState) or FInitialized then Exit;
  FInitialized := True; BuildDemo;
end;

procedure TNimbusChartsDemo.BuildDemo;
var
  Header, Row: TThemedPanel; LabelControl: TThemedLabel; Button: TThemedButton;
  I: Integer; Band: TSparklineThresholdBand; Marker: TSparklineMarker; Colors: TNimbusChartPalette;
const Names: array[0..4] of string = ('Line', 'Area', 'Bars', 'Win / loss', 'Dots');
begin
  Header := TThemedPanel.Create(Self); Header.Parent := Self; Header.Align := alTop; Header.Height := 132;
  Button := TThemedButton.Create(Self); Button.Parent := Header; Button.SetBounds(12, 12, 130, 32);
  Button.Caption := 'Update values'; Button.OnClick := UpdateClick;
  Button := TThemedButton.Create(Self); Button.Parent := Header; Button.SetBounds(154, 12, 150, 32);
  Button.Caption := 'Start / stop live'; Button.OnClick := AnimateClick;
  FStatus := TThemedLabel.Create(Self); FStatus.Parent := Header; FStatus.SetBounds(320, 16, 550, 24);
  FStatus.Caption := 'Hover a point for a tooltip. Click or use arrow keys to select.';
  for I := 4 downto 0 do
  begin
    Row := TThemedPanel.Create(Self); Row.Parent := Self; Row.Align := alTop; Row.Height := 86;
    LabelControl := TThemedLabel.Create(Self); LabelControl.Parent := Row; LabelControl.Align := alLeft;
    LabelControl.Width := 130; LabelControl.Caption := Names[I];
    FSparklines[I] := TThemedSparkline.Create(Self);
    with FSparklines[I] do
    begin
      Parent := Row; Align := alClient; AlignWithMargins := True;
      Margins.SetBounds(8, 8, 16, 8); Style := TSparklineRenderStyle(I);
      ShowToolTip := True; ShowSelection := True; ShowHoverLine := True;
      ShowLastPoint := True; ShowStartPoint := True; ShowMinMaxPoints := True;
      ShowEndValueLabel := True; ShowZeroLine := True; ShowBorder := True;
      ColorizeNegativeSegments := True; UseGradientArea := True; SplitAreaByZero := True;
      UseRoundedBars := True; StrokeWidth := 2; AnimateValueChanges := True;
      OnPointClicked := PointClick;
    end;
    Band := FSparklines[I].ThresholdBands.Add; Band.Minimum := -3; Band.Maximum := 3;
    FSparklines[I].ReferenceLines.Add.Value := 5;
    Marker := FSparklines[I].Markers.Add; Marker.PointIndex := 12; Marker.Shape := smsDiamond;
  end;
  CreateChartColorControls(Self, Header, FColorModes, FColorSlots, FColorPicker, FPalettePicker, ColorModeChanged, ColorChanged, PaletteSelectionChanged, PalettePicked, ColorSlotChanged);
  Colors := TNimbusChartPalette.Create;
  try Colors.ApplyTheme(Palette); FPaletteColors := Colors.Colors finally Colors.Free end;
  if Length(FPaletteColors) > 0 then FPaletteColors[0] := FColorPicker.SelectedColor;
  FTimer := TTimer.Create(Self); FTimer.Enabled := False; FTimer.Interval := 700; FTimer.OnTimer := TimerTick;
  UpdateClick(Self);
end;

procedure TNimbusChartsDemo.UpdateClick(Sender: TObject);
var I, J, Count: Integer; Values: TSparklineValues;
begin
  Inc(FTick);
  for I := 0 to High(FSparklines) do
  begin
    Count := 160; if I = 2 then Count := 32 else if I = 3 then Count := 24 else if I = 4 then Count := 64; SetLength(Values, Count);
    for J := 0 to Count - 1 do Values[J] := Sin(J * 0.13 + FTick * 0.32) * 8 + Cos(J * 0.37) * 2 + Sin(J * 0.91) * 0.7;
    FSparklines[I].Values := Values;
  end;
end;

procedure TNimbusChartsDemo.AnimateClick(Sender: TObject);
begin
  FTimer.Enabled := not FTimer.Enabled;
end;

procedure TNimbusChartsDemo.TimerTick(Sender: TObject);
begin
  UpdateClick(Sender);
end;

procedure TNimbusChartsDemo.PointClick(Sender: TObject; APointIndex: Integer; AValue: Double; const ALocation: TPoint);
begin
  FStatus.Caption := 'Selected point ' + IntToStr(APointIndex + 1) + ': ' + FormatFloat('0.##', AValue);
end;

procedure TNimbusChartsDemo.ColorModeChanged(Sender: TObject);
var I: Integer; Color: TColor;
begin
  if (FColorModes = nil) or (csDestroying in ComponentState) then Exit;
  for I := 0 to High(FSparklines) do
    if FSparklines[I] <> nil then
      with FSparklines[I] do
      begin
        ThemeInfluence := 12; BarGap := 2;
        if FColorModes.ItemIndex = 0 then
        begin ThemeMode := stmAuto; AccentColor := clNone; LineColor := clNone; FillColor := clNone; NegativeColor := clNone end
        else
        begin
          ThemeMode := stmCustom; if FColorModes.ItemIndex = 2 then ThemeMode := stmAdaptiveCustom;
          Color := FColorPicker.SelectedColor; if Length(FPaletteColors) > 0 then Color := FPaletteColors[I mod Length(FPaletteColors)];
          AccentColor := Color; LineColor := Color; FillColor := Color; NegativeColor := $00785AFF;
        end;
      end;
end;

procedure TNimbusChartsDemo.ColorChanged(Sender: TObject; AOldColor, ANewColor: TColor);
var Index: Integer;
begin
  if FUpdatingColors or (csDestroying in ComponentState) then Exit;
  Index := FColorSlots.ItemIndex; if Index < 0 then Exit;
  if Length(FPaletteColors) = 0 then FPaletteColors := [ANewColor];
  if Index < Length(FPaletteColors) then FPaletteColors[Index] := ANewColor;
  if FColorModes.ItemIndex = 0 then FColorModes.ItemIndex := 2; ColorModeChanged(Sender);
end;

procedure TNimbusChartsDemo.ColorSlotChanged(Sender: TObject);
var Index: Integer;
begin
  if FUpdatingColors or (csDestroying in ComponentState) then Exit;
  Index := FColorSlots.ItemIndex; if (Index < 0) or (Index >= Length(FPaletteColors)) then Exit;
  FUpdatingColors := True;
  try FColorPicker.SelectedColor := FPaletteColors[Index] finally FUpdatingColors := False end;
end;

procedure TNimbusChartsDemo.PaletteSelectionChanged(Sender: TObject);
var I: Integer;
begin
  if FUpdatingColors or (csDestroying in ComponentState) or (FPalettePicker = nil) or (FColorPicker = nil) or (FColorSlots = nil) then Exit;
  FPaletteColors := SelectedChartPaletteColors(FPalettePicker.Picker); if Length(FPaletteColors) = 0 then Exit;
  FUpdatingColors := True; FColorSlots.Items.BeginUpdate;
  try
    FColorSlots.Items.Clear; for I := 0 to High(FPaletteColors) do FColorSlots.Items.Add('Color ' + IntToStr(I + 1));
    FColorSlots.ItemIndex := 0; FColorPicker.SelectedColor := FPaletteColors[0];
  finally FColorSlots.Items.EndUpdate; FUpdatingColors := False end;
  if FColorModes.ItemIndex = 0 then FColorModes.ItemIndex := 2; ColorModeChanged(Sender);
end;

procedure TNimbusChartsDemo.PalettePicked(Sender: TObject; AColor: TColor; const ASource: string);
begin PaletteSelectionChanged(Sender) end;

constructor TNimbusGeneralChartsDemo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner); Align := alClient;
end;

procedure TNimbusGeneralChartsDemo.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  if (AParent = nil) or (csDestroying in ComponentState) or FInitialized then Exit;
  FInitialized := True; BuildDemo;
end;

procedure TNimbusGeneralChartsDemo.BuildDemo;
var Header: TThemedPanel; B: TThemedButton; I: Integer;
const Names: array[0..33] of string = ('Line', 'Area', 'Line and scatter', 'Column', 'Bar', 'Pie', 'Donut', 'Scatter', 'Bubble', 'Heatmap', 'KPI dashboard', 'Gauge', 'Radial bar', 'Bullet', 'Box plot', 'Ranked bar', 'Timeline range', 'Calendar heatmap', 'Business bullet', 'Diverging bar', 'Funnel', 'Lollipop bar', 'Radial goal', 'Portfolio arc', 'Waterfall', 'Modern waterfall', 'KPI tiles', 'Pareto', 'Stacked horizontal bar', 'Violin plot', 'Ridgeline', 'StreamGraph', 'Treemap', 'Sunburst');
begin
  Header := TThemedPanel.Create(Self); Header.Parent := Self; Header.Align := alTop; Header.Height := 172;
  FTypes := TThemedComboBox.Create(Self); FTypes.Parent := Header; FTypes.SetBounds(12, 12, 210, 30);
  for I := Low(Names) to High(Names) do FTypes.Items.Add(Names[I]);
  FTypes.ItemIndex := 0; FTypes.OnChange := TypeChanged;
  B := TThemedButton.Create(Self); B.Parent := Header; B.SetBounds(236, 12, 130, 30); B.Caption := 'Update data'; B.OnClick := UpdateClick;
  B := TThemedButton.Create(Self); B.Parent := Header; B.SetBounds(378, 12, 130, 30); B.Caption := 'Reset view'; B.OnClick := ResetClick;
  FLooks := TThemedComboBox.Create(Self); FLooks.Parent := Header; FLooks.SetBounds(92, 130, 210, 30);
  FLooks.Items.Add('Keep current custom look'); FLooks.Items.Add('C# VS IDE light'); FLooks.Items.Add('C# VS IDE dark'); FLooks.Items.Add('Glowing modern');
  FLooks.ItemIndex := 0; FLooks.OnChange := LookChanged;
  FHeatPreset := TThemedComboBox.Create(Self); FHeatPreset.Parent := Header; FHeatPreset.SetBounds(808, 130, 180, 30);
  FHeatPreset.Items.Add('Theme heatmap'); FHeatPreset.Items.Add('Custom heatmap'); FHeatPreset.Items.Add('GitHub green');
  FHeatPreset.Items.Add('GitHub dark green'); FHeatPreset.Items.Add('Red heatmap'); FHeatPreset.Items.Add('Thermal blue to red');
  FHeatPreset.ItemIndex := Ord(nhcpGitHubGreen); FHeatPreset.OnChange := HeatPresetChanged; FHeatPreset.Visible := False;
  FGlow := TThemedCheckBox.Create(Self); FGlow.Parent := Header; FGlow.SetBounds(316, 130, 150, 30);
  FGlow.Caption := 'Series glow'; FGlow.OnClick := GlowChanged;
  FBackPicker := TThemedIdeColorPickerButton.Create(Self); FBackPicker.Parent := Header; FBackPicker.SetBounds(480, 130, 150, 30);
  FBackPicker.ButtonText := 'Chart background'; FBackPicker.OnSelectedColorChanged := SurfaceChanged;
  FPlotPicker := TThemedIdeColorPickerButton.Create(Self); FPlotPicker.Parent := Header; FPlotPicker.SetBounds(644, 130, 150, 30);
  FPlotPicker.ButtonText := 'Plot background'; FPlotPicker.OnSelectedColorChanged := SurfaceChanged;
  CreateChartColorControls(Self, Header, FColorModes, FColorSlots, FColorPicker, FPalettePicker, ColorModeChanged, ColorChanged, PaletteSelectionChanged, PalettePicked, ColorSlotChanged);
  FViolinControls := TThemedPanel.Create(Self); FViolinControls.Parent := Self; FViolinControls.Align := alTop;
  FViolinControls.Top := Header.Height; FViolinControls.Height := 44; FViolinControls.Visible := False;
  FViolinPresentation := TThemedComboBox.Create(Self); FViolinPresentation.Parent := FViolinControls; FViolinPresentation.SetBounds(12, 6, 190, 30);
  FViolinPresentation.Items.Add('Vertical / full'); FViolinPresentation.Items.Add('Horizontal / full');
  FViolinPresentation.Items.Add('Vertical / split pairs'); FViolinPresentation.Items.Add('Horizontal / split pairs');
  FViolinPresentation.Items.Add('Vertical / left half'); FViolinPresentation.Items.Add('Vertical / right half');
  FViolinPresentation.ItemIndex := 0; FViolinPresentation.OnChange := ViolinOptionsChanged;
  FViolinPoints := TThemedComboBox.Create(Self); FViolinPoints.Parent := FViolinControls; FViolinPoints.SetBounds(214, 6, 130, 30);
  FViolinPoints.Items.Add('No points'); FViolinPoints.Items.Add('Jitter'); FViolinPoints.Items.Add('Beeswarm');
  FViolinPoints.ItemIndex := 1; FViolinPoints.OnChange := ViolinOptionsChanged;
  FViolinDensity := TThemedComboBox.Create(Self); FViolinDensity.Parent := FViolinControls; FViolinDensity.SetBounds(356, 6, 155, 30);
  FViolinDensity.Items.Add('Per series'); FViolinDensity.Items.Add('Global density'); FViolinDensity.Items.Add('Sample count');
  FViolinDensity.ItemIndex := 0; FViolinDensity.OnChange := ViolinOptionsChanged;
  FViolinBandwidth := TThemedComboBox.Create(Self); FViolinBandwidth.Parent := FViolinControls; FViolinBandwidth.SetBounds(523, 6, 130, 30);
  FViolinBandwidth.Items.Add('Automatic'); FViolinBandwidth.Items.Add('Scott'); FViolinBandwidth.Items.Add('Silverman'); FViolinBandwidth.Items.Add('Fixed');
  FViolinBandwidth.ItemIndex := 0; FViolinBandwidth.OnChange := ViolinOptionsChanged;
  FViolinStatistics := TThemedCheckBox.Create(Self); FViolinStatistics.Parent := FViolinControls; FViolinStatistics.SetBounds(665, 6, 190, 30);
  FViolinStatistics.Caption := 'More statistics'; FViolinStatistics.OnClick := ViolinOptionsChanged;
  FRidgelineControls := TThemedPanel.Create(Self); FRidgelineControls.Parent := Self; FRidgelineControls.Align := alTop;
  FRidgelineControls.Top := Header.Height; FRidgelineControls.Height := 44; FRidgelineControls.Visible := False;
  FRidgelineScale := TThemedComboBox.Create(Self); FRidgelineScale.Parent := FRidgelineControls; FRidgelineScale.SetBounds(12, 6, 150, 30);
  FRidgelineScale.Items.Add('Global scale'); FRidgelineScale.Items.Add('Per ridge'); FRidgelineScale.Items.Add('Percent');
  FRidgelineScale.ItemIndex := 0; FRidgelineScale.OnChange := RidgelineOptionsChanged;
  FRidgelineSort := TThemedComboBox.Create(Self); FRidgelineSort.Parent := FRidgelineControls; FRidgelineSort.SetBounds(174, 6, 175, 30);
  FRidgelineSort.Items.Add('Original order'); FRidgelineSort.Items.Add('Name ascending'); FRidgelineSort.Items.Add('Name descending');
  FRidgelineSort.Items.Add('Peak ascending'); FRidgelineSort.Items.Add('Peak descending'); FRidgelineSort.Items.Add('Total ascending'); FRidgelineSort.Items.Add('Total descending');
  FRidgelineSort.ItemIndex := 0; FRidgelineSort.OnChange := RidgelineOptionsChanged;
  FRidgelineCurve := TThemedComboBox.Create(Self); FRidgelineCurve.Parent := FRidgelineControls; FRidgelineCurve.SetBounds(361, 6, 130, 30);
  FRidgelineCurve.Items.Add('Smooth'); FRidgelineCurve.Items.Add('Linear'); FRidgelineCurve.Items.Add('Step');
  FRidgelineCurve.ItemIndex := 0; FRidgelineCurve.OnChange := RidgelineOptionsChanged;
  FRidgelineOverlap := TThemedComboBox.Create(Self); FRidgelineOverlap.Parent := FRidgelineControls; FRidgelineOverlap.SetBounds(503, 6, 150, 30);
  FRidgelineOverlap.Items.Add('Overlap 30%'); FRidgelineOverlap.Items.Add('Overlap 58%'); FRidgelineOverlap.Items.Add('Overlap 80%');
  FRidgelineOverlap.ItemIndex := 1; FRidgelineOverlap.OnChange := RidgelineOptionsChanged;
  B := TThemedButton.Create(Self); B.Parent := FRidgelineControls; B.SetBounds(665, 6, 190, 30); B.Caption := 'Reset range zoom'; B.OnClick := ResetClick;
  FKpiHost := TThemedPanel.Create(Self); FKpiHost.Parent := Self; FKpiHost.Align := alTop; FKpiHost.Top := Header.Height;
  FKpiHost.Height := ScaleValue(202); FKpiHost.ShowBorder := False; FKpiHost.Visible := False; FKpiHost.OnResize := LayoutKpis;
  for I := 0 to High(FKpis) do
  begin
    FKpis[I] := TThemedChart.Create(Self); FKpis[I].Parent := FKpiHost; FKpis[I].ChartType := nctKpi;
    FKpis[I].ShowBorder := False; FKpis[I].ShowSelectionPanel := False; FKpis[I].ShowAnimation := False;
  end;
  LayoutKpis(Self);
  FStatus := TThemedLabel.Create(Self); FStatus.Parent := Self; FStatus.Align := alBottom; FStatus.Height := 34;
  FStatus.Caption := 'Wheel: zoom. Shift + drag: pan. Click a legend item to toggle a series. Ctrl + arrows: pan.';
  FBaseChart := TThemedRidgelineChart.Create(Self); FChart := FBaseChart; FChart.Parent := Self; FChart.Align := alClient;
  FStreamControls := TThemedPanel.Create(Self); FStreamControls.Parent := Self; FStreamControls.Align := alTop; FStreamControls.Top := Header.Height; FStreamControls.Height := 44; FStreamControls.Visible := False;
  FStreamBaseline := TThemedComboBox.Create(Self); FStreamBaseline.Parent := FStreamControls; FStreamBaseline.SetBounds(12, 6, 175, 30);
  FStreamBaseline.Items.Add('Silhouette'); FStreamBaseline.Items.Add('Wiggle'); FStreamBaseline.Items.Add('Zero baseline'); FStreamBaseline.Items.Add('Expand 100%'); FStreamBaseline.ItemIndex := 0; FStreamBaseline.OnChange := StreamOptionsChanged;
  FStreamCurve := TThemedComboBox.Create(Self); FStreamCurve.Parent := FStreamControls; FStreamCurve.SetBounds(199, 6, 150, 30);
  FStreamCurve.Items.Add('Smooth'); FStreamCurve.Items.Add('Linear'); FStreamCurve.Items.Add('Step'); FStreamCurve.ItemIndex := 0; FStreamCurve.OnChange := StreamOptionsChanged;
  FStreamSelection := TThemedComboBox.Create(Self); FStreamSelection.Parent := FStreamControls; FStreamSelection.SetBounds(361, 6, 180, 30);
  FStreamSelection.Items.Add('No selection'); FStreamSelection.Items.Add('Band'); FStreamSelection.Items.Add('Series'); FStreamSelection.Items.Add('Time slice'); FStreamSelection.ItemIndex := 1; FStreamSelection.OnChange := StreamOptionsChanged;
  B := TThemedButton.Create(Self); B.Parent := FStreamControls; B.SetBounds(553, 6, 180, 30); B.Caption := 'Reset range zoom'; B.OnClick := ResetClick;
  FTreemapControls := TThemedPanel.Create(Self); FTreemapControls.Parent := Self; FTreemapControls.Align := alTop; FTreemapControls.Top := Header.Height; FTreemapControls.Height := 44; FTreemapControls.Visible := False;
  FTreemapLayout := TThemedComboBox.Create(Self); FTreemapLayout.Parent := FTreemapControls; FTreemapLayout.SetBounds(12, 6, 180, 30);
  FTreemapLayout.Items.Add('Squarified'); FTreemapLayout.Items.Add('Slice and dice'); FTreemapLayout.Items.Add('Horizontal'); FTreemapLayout.Items.Add('Vertical'); FTreemapLayout.ItemIndex := 0; FTreemapLayout.OnChange := TreemapOptionsChanged;
  FTreemapLabels := TThemedComboBox.Create(Self); FTreemapLabels.Parent := FTreemapControls; FTreemapLabels.SetBounds(204, 6, 200, 30);
  FTreemapLabels.Items.Add('Automatic labels'); FTreemapLabels.Items.Add('Name'); FTreemapLabels.Items.Add('Name and value'); FTreemapLabels.Items.Add('Name, value, share'); FTreemapLabels.ItemIndex := 0; FTreemapLabels.OnChange := TreemapOptionsChanged;
  FTreemapMarking := TThemedComboBox.Create(Self); FTreemapMarking.Parent := FTreemapControls; FTreemapMarking.SetBounds(416, 6, 165, 30);
  FTreemapMarking.Items.Add('No marking'); FTreemapMarking.Items.Add('Exact path'); FTreemapMarking.Items.Add('Branch'); FTreemapMarking.ItemIndex := 2; FTreemapMarking.OnChange := TreemapOptionsChanged;
  B := TThemedButton.Create(Self); B.Parent := FTreemapControls; B.SetBounds(593, 6, 140, 30); B.Caption := 'Reset drill-down'; B.OnClick := ResetClick;
  FSunburstControls := TThemedPanel.Create(Self); FSunburstControls.Parent := Self; FSunburstControls.Align := alTop; FSunburstControls.Top := Header.Height; FSunburstControls.Height := 44; FSunburstControls.Visible := False;
  FSunburstMarking := TThemedComboBox.Create(Self); FSunburstMarking.Parent := FSunburstControls; FSunburstMarking.SetBounds(12, 6, 165, 30);
  FSunburstMarking.Items.Add('No marking'); FSunburstMarking.Items.Add('Exact path'); FSunburstMarking.Items.Add('Branch'); FSunburstMarking.ItemIndex := 2; FSunburstMarking.OnChange := SunburstOptionsChanged;
  FSunburstHole := TThemedComboBox.Create(Self); FSunburstHole.Parent := FSunburstControls; FSunburstHole.SetBounds(189, 6, 150, 30);
  FSunburstHole.Items.Add('Center 10%'); FSunburstHole.Items.Add('Center 28%'); FSunburstHole.Items.Add('Center 45%'); FSunburstHole.ItemIndex := 1; FSunburstHole.OnChange := SunburstOptionsChanged;
  FSunburstRoot := TThemedCheckBox.Create(Self); FSunburstRoot.Parent := FSunburstControls; FSunburstRoot.SetBounds(351, 6, 135, 30); FSunburstRoot.Caption := 'Root ring'; FSunburstRoot.OnClick := SunburstOptionsChanged;
  FSunburstValues := TThemedCheckBox.Create(Self); FSunburstValues.Parent := FSunburstControls; FSunburstValues.SetBounds(498, 6, 130, 30); FSunburstValues.Caption := 'Show values'; FSunburstValues.OnClick := SunburstOptionsChanged;
  B := TThemedButton.Create(Self); B.Parent := FSunburstControls; B.SetBounds(640, 6, 150, 30); B.Caption := 'Reset drill-down'; B.OnClick := ResetClick;
  FSunburstChart := TThemedSunburstChart.Create(Self); FSunburstChart.Visible := False; FSunburstChart.Parent := Self; FSunburstChart.Align := alClient;
  FSunburstChart.AlignWithMargins := True; FSunburstChart.Margins.SetBounds(12, 6, 12, 6); FSunburstChart.OnSelectionChanged := PointSelected;
  FTreemapChart := TThemedTreemapChart.Create(Self); FTreemapChart.Visible := False; FTreemapChart.Parent := Self; FTreemapChart.Align := alClient;
  FTreemapChart.AlignWithMargins := True; FTreemapChart.Margins.SetBounds(12, 6, 12, 6); FTreemapChart.OnSelectionChanged := PointSelected;
  FTreemapChart.TreemapOptions.AllowParentTiles := True;
  FStreamChart := TThemedStreamGraphChart.Create(Self); FStreamChart.Visible := False; FStreamChart.Parent := Self; FStreamChart.Align := alClient;
  FStreamChart.AlignWithMargins := True; FStreamChart.Margins.SetBounds(12, 6, 12, 6); FStreamChart.OnSelectionChanged := PointSelected; FStreamChart.ShowAnimation := True;
  FChart.AlignWithMargins := True; FChart.Margins.SetBounds(12, 6, 12, 6);
  FChart.ShowCrosshair := True; FChart.ShowAnimation := True; FChart.OnSelectionChanged := PointSelected;
  FBaseChart.Model.Palette.ApplyTheme(Palette); FStreamChart.Model.Palette.ApplyTheme(Palette);
  FTreemapChart.Model.Palette.ApplyTheme(Palette); FSunburstChart.Model.Palette.ApplyTheme(Palette);
  for I := 0 to High(FKpis) do FKpis[I].Model.Palette.ApplyTheme(Palette);
  FPaletteColors := FChart.Model.Palette.Colors;
  FUpdatingColors := True;
  try FBackPicker.SelectedColor := FChart.Model.Palette.BackColor; FPlotPicker.SelectedColor := FChart.Model.Palette.PlotBackColor
  finally FUpdatingColors := False end;
  if Length(FPaletteColors) > 0 then FPaletteColors[0] := FColorPicker.SelectedColor;
  TypeChanged(Self);
end;

procedure TNimbusGeneralChartsDemo.TypeChanged(Sender: TObject);
const Types: array[0..33] of TNimbusChartType = (nctLine, nctArea, nctLineScatter, nctColumn, nctBar, nctPie, nctDonut, nctScatter, nctBubble, nctHeatmap, nctKpi, nctGauge, nctRadialBar, nctBullet, nctBoxPlot, nctBusinessRankedBar, nctBusinessTimelineRange, nctBusinessCalendarHeatmap, nctBusinessBullet, nctBusinessDivergingBar, nctBusinessFunnel, nctBusinessLollipopBar, nctBusinessRadialGoal, nctBusinessPortfolioArc, nctBusinessWaterfall, nctBusinessModernWaterfall, nctBusinessKpiTiles, nctBusinessPareto, nctBusinessStackedHorizontalBar, nctViolinPlot, nctRidgeline, nctStreamGraph, nctTreemap, nctSunburst);
begin
  if (FTypes.ItemIndex < 0) or (FTypes.ItemIndex > High(Types)) then Exit;
  FBaseChart.Visible := not (Types[FTypes.ItemIndex] in [nctStreamGraph, nctTreemap, nctSunburst]); FStreamChart.Visible := Types[FTypes.ItemIndex] = nctStreamGraph;
  FSunburstChart.Visible := Types[FTypes.ItemIndex] = nctSunburst; FSunburstControls.Visible := FSunburstChart.Visible;
  FTreemapChart.Visible := Types[FTypes.ItemIndex] = nctTreemap; FTreemapControls.Visible := FTreemapChart.Visible;
  if FStreamChart.Visible then FChart := FStreamChart else if FTreemapChart.Visible then FChart := FTreemapChart else if FSunburstChart.Visible then FChart := FSunburstChart else FChart := FBaseChart;
  FStreamControls.Visible := FStreamChart.Visible;
  FKpiHost.Visible := Types[FTypes.ItemIndex] = nctKpi;
  FViolinControls.Visible := Types[FTypes.ItemIndex] = nctViolinPlot;
  FRidgelineControls.Visible := Types[FTypes.ItemIndex] = nctRidgeline;
  FChart.BeginUpdate;
  try
    FChart.ChartType := Types[FTypes.ItemIndex]; FChart.Title := FTypes.Items[FTypes.ItemIndex];
    FHeatPreset.Visible := FChart.ChartType in [nctHeatmap, nctBusinessCalendarHeatmap];
    if FHeatPreset.Visible then FChart.Model.HeatmapColorPreset := TNimbusHeatmapColorPreset(FHeatPreset.ItemIndex);
    if FChart.ChartType = nctKpi then begin FChart.ChartType := nctLine; FChart.Title := 'Revenue trend' end;
    LoadData; UpdateKpis;
  finally FChart.EndUpdate end;
  ViolinOptionsChanged(Self); RidgelineOptionsChanged(Self); StreamOptionsChanged(Self); TreemapOptionsChanged(Self); SunburstOptionsChanged(Self); ColorModeChanged(Self);
  FChart.ResetView;
end;

procedure TNimbusGeneralChartsDemo.SunburstOptionsChanged(Sender: TObject);
const Holes: array[0..2] of Single = (0.1, 0.28, 0.45);
begin
  if (FSunburstChart = nil) or (FChart <> FSunburstChart) or (csDestroying in ComponentState) then Exit;
  FSunburstChart.BeginUpdate;
  try
    FSunburstChart.MarkingMode := TNimbusSunburstMarkingMode(FSunburstMarking.ItemIndex);
    FSunburstChart.SunburstOptions.InnerRadiusRatio := Holes[FSunburstHole.ItemIndex];
    FSunburstChart.SunburstOptions.ShowRootRing := FSunburstRoot.Checked; FSunburstChart.SunburstOptions.ShowValues := FSunburstValues.Checked;
  finally FSunburstChart.EndUpdate end;
  FStatus.Caption := 'Click: mark a branch. Double click / wheel: drill down. Wheel down: parent. Escape: reset. Arrows: select segments.';
end;

procedure TNimbusGeneralChartsDemo.TreemapOptionsChanged(Sender: TObject);
begin
  if (FTreemapChart = nil) or (FChart <> FTreemapChart) or (csDestroying in ComponentState) then Exit;
  FTreemapChart.BeginUpdate;
  try
    FTreemapChart.LayoutMode := TNimbusTreemapLayoutMode(FTreemapLayout.ItemIndex);
    FTreemapChart.TreemapOptions.LabelMode := TNimbusTreemapLabelMode(FTreemapLabels.ItemIndex);
    FTreemapChart.MarkingMode := TNimbusTreemapMarkingMode(FTreemapMarking.ItemIndex);
  finally FTreemapChart.EndUpdate end;
  FStatus.Caption := 'Click: mark a tile or branch. Double click / wheel: drill down. Wheel down: parent. Escape: reset. Arrows: select tiles.';
end;

procedure TNimbusGeneralChartsDemo.StreamOptionsChanged(Sender: TObject);
begin
  if (FStreamChart = nil) or (FChart <> FStreamChart) or (csDestroying in ComponentState) then Exit;
  FStreamChart.BeginUpdate;
  try
    FStreamChart.BaselineMode := TNimbusStreamBaselineMode(FStreamBaseline.ItemIndex);
    FStreamChart.CurveMode := TNimbusStreamCurveMode(FStreamCurve.ItemIndex);
    FStreamChart.StreamGraphOptions.SelectionMode := TNimbusStreamSelectionMode(FStreamSelection.ItemIndex);
  finally FStreamChart.EndUpdate end;
  FStatus.Caption := 'Drag: range zoom. Wheel: zoom. Right or middle drag: pan. Double click / Escape: reset. Arrows: select a band or time slice.';
end;

procedure TNimbusGeneralChartsDemo.ViolinOptionsChanged(Sender: TObject);
var Options: TNimbusViolinPlotOptions;
begin
  if (FChart = nil) or (FViolinPresentation = nil) or (FChart.ChartType <> nctViolinPlot) or (csDestroying in ComponentState) then Exit;
  FChart.BeginUpdate;
  try
    Options := FChart.Model.ViolinOptions; Options.Orientation := nvoVertical; Options.LayoutMode := nvlSeparate; Options.ShapeMode := nvsFull;
    if FViolinPresentation.ItemIndex in [1, 3] then Options.Orientation := nvoHorizontal;
    if FViolinPresentation.ItemIndex in [2, 3] then Options.LayoutMode := nvlSplitPairs;
    if FViolinPresentation.ItemIndex = 4 then Options.ShapeMode := nvsLeftHalf;
    if FViolinPresentation.ItemIndex = 5 then Options.ShapeMode := nvsRightHalf;
    if FViolinPoints.ItemIndex >= 0 then Options.PointDisplayMode := TNimbusViolinPointDisplayMode(FViolinPoints.ItemIndex);
    if FViolinDensity.ItemIndex >= 0 then Options.DensityNormalization := TNimbusViolinDensityNormalization(FViolinDensity.ItemIndex);
    if FViolinBandwidth.ItemIndex >= 0 then Options.BandwidthMode := TNimbusViolinBandwidthMode(FViolinBandwidth.ItemIndex);
    Options.FixedBandwidth := 2.5; Options.ShowMeanConfidenceInterval := FViolinStatistics.Checked;
    Options.ShowStandardDeviation := FViolinStatistics.Checked; Options.ShowZeroReferenceLine := FViolinStatistics.Checked;
  finally FChart.EndUpdate end;
  FChart.ResetView;
end;

procedure TNimbusGeneralChartsDemo.RidgelineOptionsChanged(Sender: TObject);
const Overlaps: array[0..2] of Single = (0.3, 0.58, 0.8);
var Options: TNimbusRidgelineOptions;
begin
  if (FChart = nil) or (FRidgelineScale = nil) or (FChart.ChartType <> nctRidgeline) or (csDestroying in ComponentState) then Exit;
  FChart.BeginUpdate;
  try
    Options := FChart.Model.RidgelineOptions;
    if FRidgelineScale.ItemIndex >= 0 then Options.ScaleMode := TNimbusRidgelineScaleMode(FRidgelineScale.ItemIndex);
    if FRidgelineSort.ItemIndex >= 0 then Options.SortMode := TNimbusRidgelineSortMode(FRidgelineSort.ItemIndex);
    if FRidgelineCurve.ItemIndex >= 0 then Options.CurveMode := TNimbusRidgelineCurveMode(FRidgelineCurve.ItemIndex);
    if FRidgelineOverlap.ItemIndex >= 0 then Options.Overlap := Overlaps[FRidgelineOverlap.ItemIndex];
    Options.ShowMedianMarker := True;
  finally FChart.EndUpdate end;
  FStatus.Caption := 'Drag a range to zoom. Wheel: zoom. Right / middle drag: pan. Double-click or Escape: reset.';
end;

procedure TNimbusGeneralChartsDemo.LoadData;
const WaterfallSteps: array[0..9] of string = ('Opening', 'Sales', 'Returns', 'Services', 'Payroll', 'Licenses', 'Hosting', 'Support', 'Other', 'Total');
  WaterfallValues: array[0..9] of Double = (120, 55, -18, 42, -36, 28, -12, 19, -8, 0);
  FunnelStages: array[0..6] of string = ('Visitors', 'Product views', 'Added to cart', 'Checkout', 'Payment', 'Purchase', 'Repeat purchase');
var
  I, J, SeriesCount, PointCount, Total: Integer; S: TNimbusChartSeries; P: TNimbusChartPoint;
  X, Y, Phase: Double; CaptionText: string; BulletRange: TNimbusBulletRange;
const
  Markets: array[0..9] of string = ('North America', 'Europe', 'Asia Pacific', 'Latin America', 'Middle East', 'Africa', 'Online', 'Partners', 'Retail', 'Enterprise');
  Departments: array[0..5] of string = ('Sales', 'Marketing', 'Engineering', 'Operations', 'Support', 'Finance');
begin
  FChart.Model.ClearSeries; FChart.Model.HeatmapRowLabels.Clear; FChart.Model.HeatmapColumnLabels.Clear;
  SeriesCount := 4; PointCount := 96; Phase := FRevision * 0.2;
  case FChart.ChartType of
    nctColumn: begin SeriesCount := 4; PointCount := 18 end;
    nctBar: begin SeriesCount := 3; PointCount := 16 end;
    nctPie, nctDonut: begin SeriesCount := 1; PointCount := 10 end;
    nctScatter: begin SeriesCount := 3; PointCount := 160 end;
    nctBubble: begin SeriesCount := 3; PointCount := 48 end;
    nctHeatmap: begin SeriesCount := 7; PointCount := 26 end;
    nctGauge, nctRadialBar, nctKpi: begin SeriesCount := 0; PointCount := 0 end;
    nctBullet: begin SeriesCount := 1; PointCount := 1 end;
    nctBoxPlot: begin SeriesCount := 6; PointCount := 40 end;
    nctViolinPlot: begin SeriesCount := 6; PointCount := 180 end;
    nctRidgeline: begin SeriesCount := 8; PointCount := 96 end;
    nctStreamGraph: begin SeriesCount := 6; PointCount := 120 end;
    nctTreemap: begin SeriesCount := 4; PointCount := 20 end;
    nctSunburst: begin SeriesCount := 5; PointCount := 16 end;
    nctBusinessRankedBar: begin SeriesCount := 2; PointCount := 12 end;
    nctBusinessTimelineRange: begin SeriesCount := 1; PointCount := 18 end;
    nctBusinessCalendarHeatmap: begin SeriesCount := 1; PointCount := 364 end;
    nctBusinessBullet, nctBusinessLollipopBar: begin SeriesCount := 1; PointCount := 14 end;
    nctBusinessDivergingBar: begin SeriesCount := 1; PointCount := 18 end;
    nctBusinessFunnel: begin SeriesCount := 1; PointCount := 7 end;
    nctBusinessRadialGoal: begin SeriesCount := 1; PointCount := 4 end;
    nctBusinessPortfolioArc: begin SeriesCount := 1; PointCount := 6 end;
    nctBusinessWaterfall, nctBusinessModernWaterfall: begin SeriesCount := 1; PointCount := 10 end;
    nctBusinessKpiTiles, nctBusinessPareto: begin SeriesCount := 1; PointCount := 12 end;
    nctBusinessStackedHorizontalBar: begin SeriesCount := 4; PointCount := 10 end;
  end;
  FChart.Model.XAxis.Title := 'Week'; FChart.Model.YAxis.Title := 'Value';
  FChart.ShowLegend := FChart.ChartType in [nctLine, nctArea, nctLineScatter, nctColumn, nctBar, nctPie, nctDonut, nctScatter, nctBubble, nctBoxPlot, nctViolinPlot, nctStreamGraph, nctBusinessRadialGoal, nctBusinessPortfolioArc, nctBusinessStackedHorizontalBar];
  FChart.ShowValues := FChart.ChartType in [nctPie, nctDonut, nctBusinessRankedBar];
  FChart.Model.GaugeMinimum := 0; FChart.Model.GaugeMaximum := 100; FChart.Model.GaugeValue := 62 + 20 * Sin(FRevision * 0.3);
  FChart.Model.GaugeCenterLabel := 'Capacity'; if FChart.ChartType = nctBusinessRadialGoal then FChart.Model.GaugeCenterLabel := ''; FChart.Model.GaugeValueSuffix := '%';
  FChart.Model.KpiTitle := 'Monthly revenue'; FChart.Model.KpiValue := 18500 + FRevision * 730;
  FChart.Model.KpiValueText := '$' + FormatFloat('#,##0', FChart.Model.KpiValue);
  if FChart.ChartType = nctBusinessRadialGoal then FChart.Model.KpiValueText := '';
  FChart.Model.KpiChangeText := '+12.5% vs previous month'; FChart.Model.KpiSubtitle := 'All regions combined'; FChart.Model.KpiState := nksSuccess;
  for I := 0 to SeriesCount - 1 do
  begin
    CaptionText := 'Region ' + IntToStr(I + 1);
    if FChart.ChartType in [nctBoxPlot, nctViolinPlot] then CaptionText := Departments[I];
    if FChart.ChartType = nctHeatmap then CaptionText := 'Day ' + IntToStr(I + 1);
    if FChart.ChartType = nctBusinessFunnel then CaptionText := 'Sales funnel';
    S := FChart.Model.AddSeries(CaptionText);
    S.ShowMarkers := FChart.ChartType in [nctLineScatter, nctScatter, nctBubble]; S.MarkerSize := 5;
    if FChart.ChartType = nctViolinPlot then PointCount := 100 + I * 30;
    for J := 0 to PointCount - 1 do
    begin
      X := J + 1; Y := 32 + I * 18 + Sin(J * 0.18 + I + Phase) * 12 + Cos(J * 0.47) * 4 + J * 0.12;
      CaptionText := 'Week ' + IntToStr(J + 1);
      case FChart.ChartType of
        nctSunburst: begin Y := 10 + (16 - J) * (I + 2) + Abs(Sin(J + I + Phase)) * 9; CaptionText := 'Category ' + IntToStr(J div 4 + 1) + '/Product ' + IntToStr(J mod 4 + 1) end;
        nctTreemap: begin Y := 12 + (20 - J) * (I + 2) + 8 * Abs(Sin(J + I + Phase)); CaptionText := 'Region ' + IntToStr(I + 1) + '/Category ' + IntToStr(J div 4 + 1) + '/Product ' + IntToStr(J mod 4 + 1) end;
        nctStreamGraph: begin Y := Max(0.0, 8 + 24 * Exp(-Sqr((J - 20 - I * 12) / (12.0 + I * 3))) + 15 * Exp(-Sqr((J - 85 + I * 6) / 22.0)) + 5 * Sin(J * 0.07 + I + Phase)); CaptionText := Format('Day %.3d', [J + 1]) end;
        nctBar: CaptionText := 'Product ' + IntToStr(J + 1);
        nctColumn: begin Y := 40 + I * 18 + Sin(J * 0.5 + I + Phase) * 12; CaptionText := 'Month ' + IntToStr(J + 1) end;
        nctPie, nctDonut: begin Y := 16 + (10 - J) * 9 + Sin(J + Phase) * 5; CaptionText := Markets[J] end;
        nctScatter, nctBubble:
          begin
            X := 25 + I * 22 + Cos(J * 2.399 + Phase) * (5 + (J mod 29) * 0.7);
            Y := 24 + I * 14 + Sin(J * 2.399 + Phase) * (4 + (J mod 23) * 0.65);
            CaptionText := 'Observation ' + IntToStr(J + 1);
          end;
        nctHeatmap: Y := Max(0.0, 35 + Sin(J * 0.34 + I * 0.82 + Phase) * 27 + Cos(J * 0.7 - I) * 10);
        nctBoxPlot:
          begin Y := 25 + I * 12 + Sin(J * 1.71 + I + Phase) * (6 + I * 2) + Cos(J * 0.53) * 4; CaptionText := 'Sample ' + IntToStr(J + 1) end;
        nctRidgeline:
          begin
            X := J; Y := 4 + (40 + I * 7) * Exp(-Sqr((J - 18 - I * 7 - Sin(Phase) * 3) / (8 + I * 1.3)))
              + 12 * Exp(-Sqr((J - 72 + I * 2) / 7)) + Sin(J * 0.45 + I + Phase) * 2; CaptionText := 'Day ' + IntToStr(J + 1);
          end;
        nctViolinPlot:
          begin
            Y := 24 + I * 10 + Sin(J * 1.73 + Phase) * (4 + I) + Cos(J * 0.59 + I) * (3 + I * 0.6);
            if I mod 2 = 1 then Y := Y + (J mod 2) * 14; if J mod 47 = 0 then Y := Y + 20; CaptionText := 'Sample ' + IntToStr(J + 1);
          end;
        nctBullet: begin Y := 142 + Sin(Phase) * 18; CaptionText := 'Quarterly revenue' end;
        nctBusinessRankedBar: begin Y := 240 - I * 84 - J * 6 + Sin(J + Phase) * 5; CaptionText := 'Product ' + IntToStr(I * PointCount + J + 1) end;
        nctBusinessBullet, nctBusinessLollipopBar: begin X := 100 + (J mod 5) * 30; Y := X * (0.68 + 0.5 * Abs(Sin(J + Phase))); CaptionText := 'Team ' + IntToStr(J + 1) end;
        nctBusinessDivergingBar: begin Y := Sin(J * 0.67 + Phase) * (25 + J * 3); CaptionText := 'Product ' + IntToStr(J + 1) end;
        nctBusinessStackedHorizontalBar: begin Y := 28 + I * 12 + Abs(Sin(J * 0.5 + I + Phase)) * 32; CaptionText := Markets[J] end;
        nctBusinessPareto: begin Y := 420 * Power(0.77, J) * (1 + Sin(Phase) * 0.06); CaptionText := 'Issue ' + IntToStr(J + 1) end;
        nctBusinessKpiTiles: begin X := Sin(J * 0.7 + Phase) * 12; Y := 1450 + J * 230 + Cos(J + Phase) * 170; CaptionText := Markets[J mod Length(Markets)] end;
        nctBusinessWaterfall, nctBusinessModernWaterfall: begin Y := WaterfallValues[J]; if J < High(WaterfallValues) then Y := Y * (1 + Sin(Phase) * 0.05); CaptionText := WaterfallSteps[J] end;
        nctBusinessPortfolioArc: begin Y := 150 - J * 19 + Sin(Phase + J) * 8; CaptionText := Departments[J] end;
        nctBusinessRadialGoal: begin Y := 92 - J * 16 + Sin(Phase + J) * 5; CaptionText := Departments[J] end;
        nctBusinessFunnel: begin Y := 18000 * Power(0.64, J) * (1 + Sin(Phase + J) * 0.035); CaptionText := FunnelStages[J] end;
        nctBusinessTimelineRange:
          begin X := J * 3 + (J mod 4); Y := X + 5 + (J mod 7) * 2 + Sin(Phase + J); CaptionText := 'Project ' + IntToStr(J + 1) end;
        nctBusinessCalendarHeatmap:
          begin Y := Max(0.0, 8 + Sin(J * 0.13 + Phase) * 6 + Cos(J * 0.47) * 4); if (J mod 7) in [5, 6] then Y := Y * 0.2; CaptionText := 'Day ' + IntToStr(J + 1) end;
      end;
      P := S.Points.Add(X, Y, CaptionText); P.SizeValue := 4 + (J * 7 + I * 3) mod 17;
      if FChart.ChartType in [nctSunburst, nctTreemap, nctStreamGraph, nctBusinessRankedBar, nctBusinessTimelineRange, nctBusinessCalendarHeatmap, nctBusinessBullet, nctBusinessDivergingBar, nctBusinessFunnel, nctBusinessLollipopBar, nctBusinessRadialGoal, nctBusinessPortfolioArc, nctBusinessWaterfall, nctBusinessModernWaterfall, nctBusinessKpiTiles, nctBusinessPareto, nctBusinessStackedHorizontalBar] then P.ToolTipText := ''
      else P.ToolTipText := S.Name + ', ' + CaptionText + ': ' + FormatFloat('0.##', Y);
    end;
    if FChart.ChartType = nctBullet then
    begin
      S.Bullet.Enabled := True; S.Bullet.Title := 'Quarterly revenue'; S.Bullet.Subtitle := 'Actual versus target';
      S.Bullet.Minimum := 0; S.Bullet.Maximum := 200; S.Bullet.ActualValue := S.Points[0].YValue; S.Bullet.TargetValue := 165;
      S.Bullet.ActualText := FormatFloat('0', S.Bullet.ActualValue); S.Bullet.TargetText := 'Target: 165';
      BulletRange := S.Bullet.Ranges.Add; BulletRange.StartValue := 0; BulletRange.EndValue := 110;
      BulletRange := S.Bullet.Ranges.Add; BulletRange.StartValue := 110; BulletRange.EndValue := 160;
      BulletRange := S.Bullet.Ranges.Add; BulletRange.StartValue := 160; BulletRange.EndValue := 200;
    end;
    if FChart.ChartType = nctHeatmap then FChart.Model.HeatmapRowLabels.Add(S.Name);
  end;
  if FChart.ChartType = nctHeatmap then
    for J := 0 to PointCount - 1 do FChart.Model.HeatmapColumnLabels.Add('W' + IntToStr(J + 1));
  FChart.Model.HeatmapShowCellLabels := False; Total := SeriesCount * PointCount;
  case FChart.ChartType of
    nctGauge, nctRadialBar: FChart.Subtitle := 'Current utilization';
    nctKpi: FChart.Subtitle := 'Revenue across all regions';
    nctBullet: FChart.Subtitle := 'Quarterly revenue against a target of 165';
    nctBusinessStackedHorizontalBar: FChart.Subtitle := 'Four channels across 10 markets with segment selection';
    nctBusinessPareto: FChart.Subtitle := '12 issue categories with cumulative percentage';
    nctBusinessKpiTiles: FChart.Subtitle := '12 compact indicators with percentage changes and progress bars';
    nctBusinessWaterfall, nctBusinessModernWaterfall: FChart.Subtitle := 'Opening balance, signed changes and closing total';
    nctBusinessPortfolioArc: FChart.Subtitle := 'Six departments compared against the strongest result';
    nctBusinessRadialGoal: FChart.Subtitle := 'Progress toward four departmental goals';
    nctBusinessFunnel: FChart.Subtitle := 'Seven stages from first visit to repeat purchase';
    nctBusinessTimelineRange: FChart.Subtitle := '18 projects with overlapping schedules';
    nctBusinessCalendarHeatmap: FChart.Subtitle := '52 weeks of daily activity';
    nctBusinessBullet, nctBusinessLollipopBar: FChart.Subtitle := 'Actual results and targets for 14 teams';
    nctBusinessDivergingBar: FChart.Subtitle := 'Gains and losses across 18 products';
  else FChart.Subtitle := IntToStr(SeriesCount) + ' series with ' + IntToStr(Total) + ' sample values';
  end;
end;

procedure TNimbusGeneralChartsDemo.LayoutKpis(Sender: TObject);
var I, Columns, Rows, Gap, W, H: Integer;
begin
  if FLayoutBusy or (csDestroying in ComponentState) or (FKpiHost = nil) or (FKpiHost.Parent = nil) then Exit;
  FLayoutBusy := True;
  try
    Columns := 3; if FKpiHost.Width < ScaleValue(720) then Columns := 2; if FKpiHost.Width < ScaleValue(480) then Columns := 1;
    Rows := (Length(FKpis) + Columns - 1) div Columns; Gap := ScaleValue(12); H := ScaleValue(190);
    FKpiHost.Height := Rows * H + (Rows + 1) * Gap; W := Max(1, (FKpiHost.Width - (Columns + 1) * Gap) div Columns);
    for I := 0 to High(FKpis) do if FKpis[I] <> nil then FKpis[I].SetBounds(Gap + (I mod Columns) * (W + Gap), Gap + (I div Columns) * (H + Gap), W, H);
  finally FLayoutBusy := False end;
end;

procedure TNimbusGeneralChartsDemo.UpdateKpis;
var I: Integer;
begin
  for I := 0 to High(FKpis) do
    if FKpis[I] <> nil then
      with FKpis[I].Model do
      begin
        BeginUpdate;
        try
          case I of
            0: begin KpiTitle := 'Monthly revenue'; KpiValue := 18500 + FRevision * 730; KpiValueText := '$' + FormatFloat('#,##0', KpiValue); KpiChangeText := '+12.5% vs last month'; KpiSubtitle := 'All regions combined'; KpiState := nksSuccess end;
            1: begin KpiTitle := 'Active customers'; KpiValue := 1248 + FRevision * 18; KpiValueText := FormatFloat('#,##0', KpiValue); KpiChangeText := '+7.2% vs last month'; KpiSubtitle := 'Across 10 markets'; KpiState := nksInfo end;
            2: begin KpiTitle := 'Conversion rate'; KpiValue := 4.8 + Sin(FRevision * 0.3) * 0.25; KpiValueText := FormatFloat('0.0', KpiValue) + '%'; KpiChangeText := '-0.3 percentage points'; KpiSubtitle := 'Target: 5.0%'; KpiState := nksWarning end;
          end;
        finally EndUpdate end;
      end;
end;

procedure TNimbusGeneralChartsDemo.HeatPresetChanged(Sender: TObject);
begin
  if (FChart <> nil) and (FHeatPreset.ItemIndex >= 0) then FChart.Model.HeatmapColorPreset := TNimbusHeatmapColorPreset(FHeatPreset.ItemIndex);
end;

procedure TNimbusGeneralChartsDemo.LookChanged(Sender: TObject);
var I: Integer;
  procedure Configure(Chart: TThemedChart);
  begin if Chart <> nil then Chart.ApplyAppearance(TNimbusChartAppearance(FLooks.ItemIndex - 1)) end;
begin
  if FUpdatingColors or (FLooks.ItemIndex <= 0) or (FChart = nil) then Exit;
  FUpdatingColors := True;
  try
    Configure(FBaseChart); Configure(FStreamChart); Configure(FTreemapChart); Configure(FSunburstChart);
    for I := 0 to High(FKpis) do Configure(FKpis[I]);
    FPaletteColors := FChart.Model.Palette.Colors;
    FColorSlots.Items.Clear;
    for I := 0 to High(FPaletteColors) do FColorSlots.Items.Add('Color ' + IntToStr(I + 1));
    FColorSlots.ItemIndex := 0; FColorPicker.SelectedColor := FPaletteColors[0];
    FColorModes.ItemIndex := 1; FGlow.Checked := FLooks.ItemIndex = 3;
    FBackPicker.SelectedColor := FChart.Model.Palette.BackColor; FPlotPicker.SelectedColor := FChart.Model.Palette.PlotBackColor;
  finally FUpdatingColors := False end;
  ColorModeChanged(Sender);
end;

procedure TNimbusGeneralChartsDemo.GlowChanged(Sender: TObject);
begin if not FUpdatingColors then ColorModeChanged(Sender) end;

procedure TNimbusGeneralChartsDemo.SurfaceChanged(Sender: TObject; AOldColor, ANewColor: TColor);
var I: Integer;
  procedure Configure(Chart: TThemedChart);
  begin
    if Chart = nil then Exit;
    if Sender = FBackPicker then Chart.Model.Palette.BackColor := ANewColor else Chart.Model.Palette.PlotBackColor := ANewColor;
  end;
begin
  if FUpdatingColors or (FChart = nil) or (csDestroying in ComponentState) then Exit;
  Configure(FBaseChart); Configure(FStreamChart); Configure(FTreemapChart); Configure(FSunburstChart);
  for I := 0 to High(FKpis) do Configure(FKpis[I]);
  FColorModes.ItemIndex := 1; FLooks.ItemIndex := 0; ColorModeChanged(Sender);
end;

procedure TNimbusGeneralChartsDemo.ColorModeChanged(Sender: TObject);
var I: Integer;
  procedure Configure(Chart: TThemedChart);
  var Colors: TArray<TColor>;
  begin
    if Chart = nil then Exit;
    Chart.ShowGlow := FGlow.Checked;
    Chart.ThemeInfluence := 12;
    if FColorModes.ItemIndex = 0 then begin Chart.ColorMode := nccTheme; Exit end;
    Chart.BeginUpdate;
    try
      Colors := Chart.Model.Palette.Colors; if Length(FPaletteColors) > 0 then Colors := Copy(FPaletteColors); if Length(Colors) = 0 then SetLength(Colors, 1);
      if Length(FPaletteColors) = 0 then Colors[0] := FColorPicker.SelectedColor;
      Chart.Model.Palette.AccentColor := Colors[0]; Chart.Model.Palette.InfoColor := Colors[0]; Chart.Model.Palette.Colors := Colors;
      Chart.ColorMode := nccCustom; if FColorModes.ItemIndex = 2 then Chart.ColorMode := nccAdaptiveCustom;
    finally Chart.EndUpdate end;
  end;
begin
  if FUpdatingColors or (FColorModes = nil) or (FColorPicker = nil) or (FGlow = nil) or (csDestroying in ComponentState) then Exit;
  Configure(FBaseChart); Configure(FStreamChart); Configure(FTreemapChart); Configure(FSunburstChart);
  for I := 0 to High(FKpis) do Configure(FKpis[I]);
end;

procedure TNimbusGeneralChartsDemo.ColorChanged(Sender: TObject; AOldColor, ANewColor: TColor);
var Index: Integer;
begin
  if FUpdatingColors or (csDestroying in ComponentState) then Exit;
  Index := FColorSlots.ItemIndex; if Index < 0 then Exit;
  if Length(FPaletteColors) = 0 then FPaletteColors := [ANewColor];
  if Index < Length(FPaletteColors) then FPaletteColors[Index] := ANewColor;
  if FColorModes.ItemIndex = 0 then FColorModes.ItemIndex := 2; ColorModeChanged(Sender);
end;

procedure TNimbusGeneralChartsDemo.ColorSlotChanged(Sender: TObject);
var Index: Integer;
begin
  if FUpdatingColors or (csDestroying in ComponentState) then Exit;
  Index := FColorSlots.ItemIndex; if (Index < 0) or (Index >= Length(FPaletteColors)) then Exit;
  FUpdatingColors := True;
  try FColorPicker.SelectedColor := FPaletteColors[Index] finally FUpdatingColors := False end;
end;

procedure TNimbusGeneralChartsDemo.PaletteSelectionChanged(Sender: TObject);
var I: Integer;
begin
  if FUpdatingColors or (csDestroying in ComponentState) or (FPalettePicker = nil) or (FColorPicker = nil) or (FColorSlots = nil) then Exit;
  FPaletteColors := SelectedChartPaletteColors(FPalettePicker.Picker); if Length(FPaletteColors) = 0 then Exit;
  FUpdatingColors := True; FColorSlots.Items.BeginUpdate;
  try
    FColorSlots.Items.Clear; for I := 0 to High(FPaletteColors) do FColorSlots.Items.Add('Color ' + IntToStr(I + 1));
    FColorSlots.ItemIndex := 0; FColorPicker.SelectedColor := FPaletteColors[0];
  finally FColorSlots.Items.EndUpdate; FUpdatingColors := False end;
  if FColorModes.ItemIndex = 0 then FColorModes.ItemIndex := 2; ColorModeChanged(Sender);
end;

procedure TNimbusGeneralChartsDemo.PalettePicked(Sender: TObject; AColor: TColor; const ASource: string);
begin PaletteSelectionChanged(Sender) end;

procedure TNimbusGeneralChartsDemo.UpdateClick(Sender: TObject);
begin Inc(FRevision); FChart.BeginUpdate; try LoadData; UpdateKpis finally FChart.EndUpdate end end;

procedure TNimbusGeneralChartsDemo.ResetClick(Sender: TObject);
begin FChart.ResetView; FChart.ClearSelection end;

procedure TNimbusGeneralChartsDemo.PointSelected(Sender: TObject; const AHit: TNimbusChartHit);
begin
  if AHit.Area = nchaNone then FStatus.Caption := 'Selection cleared' else FStatus.Caption := AHit.Text;
end;

type
  TNimbusChartLooksGallery = class(TThemedPanel)
  private
    FViewport, FContent: TThemedPanel;
    FVertical: TThemedVScrollBar;
    FHorizontal: TThemedHScrollBar;
    FLayoutBusy: Boolean;
    procedure ScrollChanged(Sender: TObject);
  protected
    procedure Resize; override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

procedure TNimbusChartLooksGallery.ScrollChanged(Sender: TObject);
begin
  if FLayoutBusy or (FContent = nil) or (csDestroying in ComponentState) then Exit;
  FContent.SetBounds(-FHorizontal.Value, -FVertical.Value, ScaleValue(1020), ScaleValue(858));
end;

procedure TNimbusChartLooksGallery.Resize;
var BarSize, W, H: Integer;
begin
  inherited;
  if FLayoutBusy or (FHorizontal = nil) or (FVertical = nil) or (FViewport = nil) or (csDestroying in ComponentState) then Exit;
  FLayoutBusy := True;
  try
    BarSize := ScaleValue(18); W := ClientWidth; H := ClientHeight;
    FVertical.Visible := ScaleValue(858) > H;
    if FVertical.Visible then Dec(W, BarSize);
    FHorizontal.Visible := ScaleValue(1020) > W;
    if FHorizontal.Visible then Dec(H, BarSize);
    FVertical.Visible := ScaleValue(858) > H;
    W := Max(0, ClientWidth - Ord(FVertical.Visible) * BarSize); H := Max(0, H);
    FViewport.SetBounds(0, 0, W, H);
    FVertical.SetBounds(W, 0, BarSize, H); FHorizontal.SetBounds(0, H, W, BarSize);
    FVertical.Maximum := ScaleValue(858) - 1; FVertical.LargeChange := Max(1, H);
    FHorizontal.Maximum := ScaleValue(1020) - 1; FHorizontal.LargeChange := Max(1, W);
    FVertical.SmallChange := ScaleValue(36); FHorizontal.SmallChange := ScaleValue(36);
  finally FLayoutBusy := False end;
  ScrollChanged(Self);
end;

function TNimbusChartLooksGallery.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
begin
  Result := False;
  if ssShift in Shift then
  begin
    if FHorizontal.Visible then begin FHorizontal.Value := FHorizontal.Value - Round(WheelDelta / 120 * FHorizontal.SmallChange * 3); Result := True end;
  end
  else if FVertical.Visible then begin FVertical.Value := FVertical.Value - Round(WheelDelta / 120 * FVertical.SmallChange * 3); Result := True end;
  if not Result then Result := inherited DoMouseWheel(Shift, WheelDelta, MousePos);
end;

constructor TNimbusChartLooksGallery.Create(AOwner: TComponent);
const Names: array[0..2] of string = ('C# VS IDE light', 'C# VS IDE dark', 'Glowing modern');
  Kinds: array[0..2] of TNimbusChartType = (nctLine, nctColumn, nctBusinessRadialGoal);
var Chart: TThemedChart; Series: TNimbusChartSeries; I, J, K, N: Integer;
begin
  inherited Create(AOwner); Align := alClient; ShowBorder := False;
  FViewport := TThemedPanel.Create(Self); FViewport.ShowBorder := False; FViewport.Parent := Self;
  FContent := TThemedPanel.Create(Self); FContent.ShowBorder := False; FContent.Parent := FViewport;
  FContent.SetBounds(0, 0, ScaleValue(1020), ScaleValue(858));
  FVertical := TThemedVScrollBar.Create(Self); FVertical.Parent := Self; FVertical.TabStop := True; FVertical.OnValueChanged := ScrollChanged;
  FHorizontal := TThemedHScrollBar.Create(Self); FHorizontal.Parent := Self; FHorizontal.TabStop := True; FHorizontal.OnValueChanged := ScrollChanged;
  for I := 0 to 2 do
    for J := 0 to 2 do
    begin
      Chart := TThemedChart.Create(Self); Chart.Parent := FContent;
      Chart.SetBounds(ScaleValue(12 + I * 336), ScaleValue(12 + J * 282), ScaleValue(324), ScaleValue(270));
      Chart.BeginUpdate;
      try
        Chart.ChartType := Kinds[J]; Chart.ApplyAppearance(TNimbusChartAppearance(I));
        Chart.Title := Names[I]; Chart.Subtitle := 'Fixed custom look - independent of the app theme';
        Chart.ShowAnimation := False; Chart.EnableZoom := False; Chart.EnablePan := False;
        if J = 2 then
        begin
          Series := Chart.Model.AddSeries('Utilization');
          Series.Points.Add(100, 72, 'CPU'); Series.Points.Add(100, 58, 'Memory'); Series.Points.Add(100, 86, 'Disk');
        end
        else
          for K := 0 to 2 do
          begin
            Series := Chart.Model.AddSeries('Series ' + IntToStr(K + 1));
            for N := 0 to 7 do Series.Points.Add(N, 35 + K * 15 + Sin(N * 0.8 + K) * 20, 'Item ' + IntToStr(N + 1));
          end;
      finally Chart.EndUpdate end;
    end;
end;

resourcestring
  SMathTab = 'Mathematical functions';
  SMathTrig = 'Sine, cosine and analysis';
  SMathTangent = 'Tangent with discontinuities';
  SMathTechnical = 'Gaussian and damped oscillation';
  SMathPolynomial = 'Polynomial with roots and extrema';
  SMathGrowth = 'Growth functions';
  SMathLissajous = 'Parametric Lissajous curve';
  SMathStatus = '%d plotted segments | %d roots | %d extrema. Wheel: zoom; drag: pan. Analysis is numerical.';
  SMathRoots = 'Roots / extrema';
  SMathDerivative = 'Derivative';
  SMathIntegral = 'Integral';
  SMathAdaptive = 'Adaptive sampling';
  SMathUniform = 'Uniform sampling';
  SMathReset = 'Reset view';
  SMathTheme = 'Application theme';
  SMathLight = 'C# VS IDE light';
  SMathDark = 'C# VS IDE dark';
  SMathGlow = 'Glowing modern';

type
  TNimbusFunctionChartsDemo = class(TThemedPanel)
  private
    FInitialized, FBuilding: Boolean;
    FChart: TThemedChart;
    FExamples, FLooks, FSampling: TThemedComboBox;
    FAnalysis, FDerivative, FIntegral: TThemedCheckBox;
    FStatus: TThemedLabel;
    procedure BuildDemo;
    procedure ExampleChanged(Sender: TObject);
    procedure Reload(Sender: TObject);
    procedure LookChanged(Sender: TObject);
    procedure ResetClick(Sender: TObject);
  protected
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

constructor TNimbusFunctionChartsDemo.Create(AOwner: TComponent);
begin inherited Create(AOwner); Align := alClient; ShowBorder := False end;

procedure TNimbusFunctionChartsDemo.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  if (AParent = nil) or FInitialized or (csDestroying in ComponentState) then Exit;
  FInitialized := True; BuildDemo;
end;

procedure TNimbusFunctionChartsDemo.BuildDemo;
var Header: TThemedPanel; Button: TThemedButton;
  procedure Place(Control: TControl; const X, Y, W, H: Integer);
  begin Control.SetBounds(ScaleValue(X), ScaleValue(Y), ScaleValue(W), ScaleValue(H)) end;
begin
  FBuilding := True;
  try
    Header := TThemedPanel.Create(Self); Header.Parent := Self; Header.Align := alTop; Header.Height := ScaleValue(94);
    FExamples := TThemedComboBox.Create(Self); FExamples.Parent := Header; Place(FExamples, 12, 10, 260, 30);
    FExamples.Items.Add(SMathTrig); FExamples.Items.Add(SMathTangent); FExamples.Items.Add(SMathTechnical);
    FExamples.Items.Add(SMathPolynomial); FExamples.Items.Add(SMathGrowth); FExamples.Items.Add(SMathLissajous);
    FExamples.ItemIndex := 0; FExamples.OnChange := ExampleChanged;
    FLooks := TThemedComboBox.Create(Self); FLooks.Parent := Header; Place(FLooks, 284, 10, 180, 30);
    FLooks.Items.Add(SMathTheme); FLooks.Items.Add(SMathLight); FLooks.Items.Add(SMathDark); FLooks.Items.Add(SMathGlow);
    FLooks.ItemIndex := 0; FLooks.OnChange := LookChanged;
    FSampling := TThemedComboBox.Create(Self); FSampling.Parent := Header; Place(FSampling, 476, 10, 180, 30);
    FSampling.Items.Add(SMathAdaptive); FSampling.Items.Add(SMathUniform); FSampling.ItemIndex := 0; FSampling.OnChange := Reload;
    Button := TThemedButton.Create(Self); Button.Parent := Header; Place(Button, 668, 10, 130, 30); Button.Caption := SMathReset; Button.OnClick := ResetClick;
    FAnalysis := TThemedCheckBox.Create(Self); FAnalysis.Parent := Header; Place(FAnalysis, 12, 52, 180, 30);
    FAnalysis.Caption := SMathRoots; FAnalysis.Checked := True; FAnalysis.OnClick := Reload;
    FDerivative := TThemedCheckBox.Create(Self); FDerivative.Parent := Header; Place(FDerivative, 204, 52, 150, 30);
    FDerivative.Caption := SMathDerivative; FDerivative.Checked := True; FDerivative.OnClick := Reload;
    FIntegral := TThemedCheckBox.Create(Self); FIntegral.Parent := Header; Place(FIntegral, 366, 52, 150, 30);
    FIntegral.Caption := SMathIntegral; FIntegral.Checked := True; FIntegral.OnClick := Reload;
    FStatus := TThemedLabel.Create(Self); FStatus.Parent := Self; FStatus.Align := alBottom; FStatus.Height := ScaleValue(34);
    FChart := TThemedChart.Create(Self); FChart.Parent := Self; FChart.Align := alClient;
    FChart.AlignWithMargins := True; FChart.Margins.SetBounds(ScaleValue(12), ScaleValue(8), ScaleValue(12), ScaleValue(8));
    FChart.ShowAnimation := False; FChart.ShowCrosshair := True;
  finally FBuilding := False end;
  Reload(Self);
end;

procedure TNimbusFunctionChartsDemo.LookChanged(Sender: TObject);
begin
  if FBuilding or (FChart = nil) then Exit;
  if FLooks.ItemIndex = 0 then begin FChart.ColorMode := nccTheme; FChart.ShowGlow := False end
  else FChart.ApplyAppearance(TNimbusChartAppearance(FLooks.ItemIndex - 1));
end;

procedure TNimbusFunctionChartsDemo.ExampleChanged(Sender: TObject);
begin
  if FBuilding or (FChart = nil) then Exit;
  FBuilding := True;
  try
    FDerivative.Checked := FExamples.ItemIndex = 0;
    FIntegral.Checked := FExamples.ItemIndex = 0;
    FAnalysis.Checked := FExamples.ItemIndex in [0, 2, 3];
  finally FBuilding := False end;
  Reload(Sender);
end;

procedure TNimbusFunctionChartsDemo.ResetClick(Sender: TObject);
begin if FChart <> nil then begin FChart.ResetView; FChart.ClearSelection end end;

procedure TNimbusFunctionChartsDemo.Reload(Sender: TObject);
var Options: TNimbusChartFunctionOptions; Parametric: TNimbusChartParametricOptions; FunctionResult: TNimbusChartFunctionResult;
  Segments, Roots, Extrema: Integer;
  procedure Add(const Name: string; const Func: TNimbusChartFunction; const Primary: Boolean = True);
  var R: TNimbusChartFunctionResult;
  begin
    Options.DetectRoots := Primary and FAnalysis.Checked; Options.DetectExtrema := Options.DetectRoots;
    Options.AddRootAnnotations := Options.DetectRoots; Options.AddExtremaAnnotations := Options.DetectExtrema;
    Options.AddDerivativeSeries := Primary and FDerivative.Checked; Options.AddIntegralSeries := Primary and FIntegral.Checked;
    Options.AddReferenceAxes := Primary;
    R := FChart.Model.AddFunctionSeries(Name, Func, Options);
    try Inc(Roots, Length(R.Roots)); Inc(Extrema, Length(R.Extrema)) finally R.Free end;
  end;
begin
  if FBuilding or (FChart = nil) or (csDestroying in ComponentState) then Exit;
  FBuilding := True;
  try
    Options := TNimbusChartFunctionOptions.Create;
    try
      if FSampling.ItemIndex = 1 then Options.SamplingMode := ncfsmUniform;
      Options.SampleCount := 220; Roots := 0; Extrema := 0;
      FChart.BeginUpdate;
      try
        FChart.ResetView; FChart.ClearSelection; FChart.Model.ClearSeries;
        FChart.Model.Annotations.Clear; FChart.Model.ReferenceLines.Clear;
        FChart.Model.XAxis.AutoRange := True; FChart.Model.YAxis.AutoRange := True;
        FChart.Model.XAxis.Title := 'x'; FChart.Model.YAxis.Title := 'f(x)';
        FChart.Title := FExamples.Items[FExamples.ItemIndex];
        FChart.Subtitle := 'C# function plotting port - shared chart rendering, selection and export';
        FSampling.Enabled := FExamples.ItemIndex <> 5; FAnalysis.Enabled := FSampling.Enabled;
        FDerivative.Enabled := FSampling.Enabled; FIntegral.Enabled := FSampling.Enabled;
        case FExamples.ItemIndex of
          0:
            begin
              Options.MinimumX := -2 * Pi; Options.MaximumX := 2 * Pi; Options.SampleCount := 160;
              Add('sin(x)', TNimbusChartFunctions.Sine(1, 1, 0, 0));
              Add('cos(x)', TNimbusChartFunctions.Cosine(1, 1, 0, 0), False);
            end;
          1:
            begin
              Options.MinimumX := -2 * Pi; Options.MaximumX := 2 * Pi; Options.SampleCount := 320;
              Options.MaximumAbsoluteY := 20; Options.DiscontinuityThreshold := 6;
              Options.AdaptiveTolerance := 0.001; Options.MaximumAdaptiveDepth := 14;
              Add('tan(x)', TNimbusChartFunctions.Tangent(1, 1, 0, 0));
            end;
          2:
            begin
              Options.MinimumX := -5; Options.MaximumX := 12; Options.SampleCount := 180;
              Add('Gaussian', TNimbusChartFunctions.Gaussian(1, 0, 1.2, 0));
              Options.MinimumX := 0; Options.SampleCount := 220;
              Add('Damped oscillation', TNimbusChartFunctions.DampedOscillation(1, 0.18, 5, 0, 0), False);
            end;
          3:
            begin
              Options.MinimumX := -4; Options.MaximumX := 4;
              Add('x^3 - 3x', TNimbusChartFunctions.Polynomial([0, -3, 0, 1]));
            end;
          4:
            begin
              Options.MinimumX := 0.05; Options.MaximumX := 6; Options.SampleCount := 180;
              Add('exp(0.5x)', TNimbusChartFunctions.Exponential(1, 0.5, 0));
              Add('log10(x)', TNimbusChartFunctions.Logarithm(10, 0, 0), False);
              Add('sqrt(x)', TNimbusChartFunctions.SquareRoot(1, 0, 0), False);
            end;
          5:
            begin
              Parametric := TNimbusChartParametricOptions.Create;
              try
                Parametric.SampleCount := 1400;
                FunctionResult := FChart.Model.AddParametricSeries('Lissajous 3:2',
                  function(T: Double): Double begin Result := Sin(3 * T + Pi / 2) end,
                  function(T: Double): Double begin Result := Sin(2 * T) end, Parametric);
                FunctionResult.Free;
              finally Parametric.Free end;
              FChart.Model.XAxis.Title := 'x(t)'; FChart.Model.YAxis.Title := 'y(t)';
            end;
        end;
        Segments := FChart.Model.Series.Count; FStatus.Caption := Format(SMathStatus, [Segments, Roots, Extrema]);
      finally FChart.EndUpdate end;
    finally Options.Free end;
  finally FBuilding := False end;
end;

procedure AddNimbusChartsDemo(ATabs: TThemedTabControl);
var Page: TTabSheet;
begin
  if ATabs = nil then Exit;
  Page := TTabSheet.Create(ATabs.Owner); Page.PageControl := ATabs; Page.Caption := 'MiniCharts';
  with TNimbusChartsDemo.Create(Page) do Parent := Page;
  Page := TTabSheet.Create(ATabs.Owner); Page.PageControl := ATabs; Page.Caption := 'Charts';
  with TNimbusGeneralChartsDemo.Create(Page) do Parent := Page;
  Page := TTabSheet.Create(ATabs.Owner); Page.PageControl := ATabs; Page.Caption := 'C# chart looks';
  with TNimbusChartLooksGallery.Create(Page) do Parent := Page;
  Page := TTabSheet.Create(ATabs.Owner); Page.PageControl := ATabs; Page.Caption := SMathTab;
  with TNimbusFunctionChartsDemo.Create(Page) do Parent := Page;
  AddNimbusFinancialDemo(ATabs);
end;

end.

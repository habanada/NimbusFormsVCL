{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.MiniCharts;

interface

uses System.Classes, System.Types, Vcl.Controls, NimbusForms.Controls.Chart, NimbusForms.Rendering.Charts,
  NimbusForms.Charts.ProgressRingGrid.Types, NimbusForms.Charts.EdgeBundling.Types, NimbusForms.Charts.Marimekko.Types,
  NimbusForms.Charts.Financial.Types;

type
  TThemedProgressRingGrid = class(TThemedChart)
  private
    function GetData: TNimbusProgressRingGridData;
    procedure SetData(const Value: TNimbusProgressRingGridData);
  protected
    procedure SetSelected(const AHit: TNimbusChartHit); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property GridData: TNimbusProgressRingGridData read GetData write SetData;
  end;
  TThemedHierarchicalEdgeBundlingChart = class(TThemedChart)
  private
    function GetData: TNimbusHierarchicalEdgeBundlingData;
    procedure SetData(const Value: TNimbusHierarchicalEdgeBundlingData);
  protected
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure ResetView; override;
  published
    property EdgeBundling: TNimbusHierarchicalEdgeBundlingData read GetData write SetData;
  end;
  TThemedMarimekkoChart = class(TThemedChart)
  private
    function GetOptions: TNimbusMarimekkoOptions;
    procedure SetOptions(const Value: TNimbusMarimekkoOptions);
  public
    constructor Create(AOwner: TComponent); override;
  published
    property MarimekkoOptions: TNimbusMarimekkoOptions read GetOptions write SetOptions;
  end;
  TThemedFinancialChart = class(TThemedChart)
  private
    function GetData: TNimbusFinancialDataPointCollection;
    function GetOptions: TNimbusFinancialChartOptions;
    procedure SetData(const Value: TNimbusFinancialDataPointCollection);
    procedure SetOptions(const Value: TNimbusFinancialChartOptions);
  public
    constructor Create(AOwner: TComponent); override;
  published
    property FinancialData: TNimbusFinancialDataPointCollection read GetData write SetData;
    property FinancialOptions: TNimbusFinancialChartOptions read GetOptions write SetOptions;
  end;

implementation

uses System.Math, NimbusForms.Charts.Types;

constructor TThemedProgressRingGrid.Create(AOwner: TComponent);
begin inherited; ChartType := nctProgressRingGrid; ShowLegend := False; ShowAxes := False; ShowGrid := False; TabStop := True end;

function TThemedProgressRingGrid.GetData: TNimbusProgressRingGridData;
begin Result := Model.ProgressRingGrid end;

procedure TThemedProgressRingGrid.SetData(const Value: TNimbusProgressRingGridData);
begin if Value <> nil then Model.ProgressRingGrid.Assign(Value) end;

procedure TThemedProgressRingGrid.SetSelected(const AHit: TNimbusChartHit);
var Hit: TNimbusChartHit;
begin
  if (AHit.Area <> nchaNone) and (GridData.SelectionMode = nprselNone) then Exit; Hit := AHit;
  if GridData.SelectionMode = nprselSingleItem then Hit.ElementIndex := -1;
  inherited SetSelected(Hit);
end;

constructor TThemedHierarchicalEdgeBundlingChart.Create(AOwner: TComponent);
begin inherited; ChartType := nctHierarchicalEdgeBundling; ShowLegend := False; ShowAxes := False; ShowGrid := False; TabStop := True end;

function TThemedHierarchicalEdgeBundlingChart.GetData: TNimbusHierarchicalEdgeBundlingData;
begin Result := Model.EdgeBundling end;

procedure TThemedHierarchicalEdgeBundlingChart.SetData(const Value: TNimbusHierarchicalEdgeBundlingData);
begin if Value <> nil then Model.EdgeBundling.Assign(Value) end;

function TThemedHierarchicalEdgeBundlingChart.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
begin
  Result := inherited; if not Enabled or not EdgeBundling.EnableZoom then Exit;
  EdgeBundling.ZoomScale := EdgeBundling.ZoomScale * Power(1.15, EnsureRange(WheelDelta / 120, -20.0, 20.0)); Result := True;
end;

procedure TThemedHierarchicalEdgeBundlingChart.ResetView;
begin inherited; EdgeBundling.ZoomScale := 1 end;

constructor TThemedMarimekkoChart.Create(AOwner: TComponent);
begin inherited; ChartType := nctMarimekko; ShowAxes := False; ShowGrid := False; Model.Legend.Position := nclpRight; TabStop := True end;

function TThemedMarimekkoChart.GetOptions: TNimbusMarimekkoOptions;
begin Result := Model.MarimekkoOptions end;

procedure TThemedMarimekkoChart.SetOptions(const Value: TNimbusMarimekkoOptions);
begin if Value <> nil then Model.MarimekkoOptions.Assign(Value) end;

constructor TThemedFinancialChart.Create(AOwner: TComponent);
begin inherited; ChartType := nctCandlestick; ShowLegend := False; ShowCrosshair := True; TabStop := True end;

function TThemedFinancialChart.GetData: TNimbusFinancialDataPointCollection;
begin Result := Model.FinancialData end;

function TThemedFinancialChart.GetOptions: TNimbusFinancialChartOptions;
begin Result := Model.FinancialOptions end;

procedure TThemedFinancialChart.SetData(const Value: TNimbusFinancialDataPointCollection);
begin if Value <> nil then Model.FinancialData.Assign(Value) end;

procedure TThemedFinancialChart.SetOptions(const Value: TNimbusFinancialChartOptions);
begin if Value <> nil then Model.FinancialOptions.Assign(Value) end;

initialization
  RegisterClass(TThemedProgressRingGrid);
  RegisterClass(TThemedHierarchicalEdgeBundlingChart);
  RegisterClass(TThemedMarimekkoChart);
  RegisterClass(TThemedFinancialChart);

end.

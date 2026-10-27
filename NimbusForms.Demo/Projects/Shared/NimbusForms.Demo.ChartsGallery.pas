{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Demo.ChartsGallery;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.IOUtils,
  System.DateUtils,
  System.Variants,
  System.TypInfo,
  System.Math,
  System.Classes,
  System.Rtti,
  System.Generics.Collections,
  System.Types,
  Vcl.Forms,
  Vcl.ActnList,
  Vcl.Dialogs,
  Vcl.Clipbrd,
  Vcl.ExtCtrls,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Graphics,
  Vcl.ComCtrls,
  Vcl.Menus,
  Vcl.ImgList,
  Vcl.Imaging.jpeg,
  System.UITypes,
  System.Actions,
  NimbusForms.Charts.Sparkline.Types,
  NimbusForms.Rendering.Sparkline,
  NimbusForms.Controls.Sparkline,
  NimbusForms.Controls.PerformanceChart,
  NimbusForms.Rendering.MicroChart,
  NimbusForms.Controls.MicroChart,
  NimbusForms.Controls.DashboardWidgets,
  NimbusForms.Controls.Panel,
  NimbusForms.Controls.ThemedLabel,
  NimbusForms.Controls.TabControl,
  NimbusForms.Controls.TreeView,
  NimbusForms.Demo.Strings;

procedure AddNimbusMiniGallery(const Tabs: TThemedTabControl);
procedure AddNimbusMicroGallery(const Tabs: TThemedTabControl);
procedure AddNimbusDashboardGallery(const Tabs: TThemedTabControl);
procedure AddNimbusPerformanceGallery(const Tabs: TThemedTabControl);

implementation

procedure AddNimbusMiniGallery(const Tabs: TThemedTabControl);
const
  Names: array[0..9] of string = ('Trend line', 'Gradient area', 'Compact columns', 'Win / loss', 'Dot sequence', 'Target tracking', 'Average comparison', 'Positive / negative', 'Range envelope', 'Rising / falling');
  Styles: array[0..9] of TSparklineRenderStyle = (srsLine, srsArea, srsBars, srsWinLoss, srsDots, srsLine, srsArea, srsBars, srsLine, srsLine);

var
  Page: TTabSheet;
  Scroll: TScrollBox;
  Card: TThemedPanel;
  CaptionLabel: TThemedLabel;
  Spark: TThemedSparkline;
  I, J, K: Integer;
  Values: TArray<Double>;
begin
  if Tabs = nil then Exit;

  Page := TTabSheet.Create(Tabs.Owner);
  Page.PageControl := Tabs;
  Page.Caption := 'Mini & micro charts';

  Scroll := TScrollBox.Create(Page);
  Scroll.Parent := Page;
  Scroll.Align := alClient;
  Scroll.BorderStyle := bsNone;
  Scroll.VertScrollBar.Tracking := True;
  for I := 0 to 9 do
  begin
    Card := TThemedPanel.Create(Page);
    Card.Parent := Scroll;
    Card.SetBounds(12 + (I mod 2) * 366, 12 + (I div 2) * 146, 352, 134);
    CaptionLabel := TThemedLabel.Create(Page);
    CaptionLabel.Parent := Card;
    CaptionLabel.SetBounds(12, 8, 310, 22);
    CaptionLabel.Caption := Names[I];
    SetLength(Values, 26);
    for K := 0 to High(Values) do
    begin
      Values[K] := 44 + Sin((K + I * 2) * 0.43) * (12 + I mod 4 * 5) + Cos(K * 0.19 + I * 0.8) * 15 + K * (I mod 3 - 1) * 0.8;
      if I in [3, 7] then Values[K] := Values[K] - 44;
    end;
    for J := 0 to 1 do
    begin
      Spark := TThemedSparkline.Create(Page);
      Spark.Parent := Card;
      if J = 0 then Spark.SetBounds(12, 37, 240, 82) else Spark.SetBounds(267, 57, 72, 24);
      Spark.BeginUpdate;
      try
        Spark.Style := Styles[I];
        Spark.PaintBackground := False;
        Spark.ShowBorder := False;
        Spark.ShowToolTip := True;
        Spark.ShowHoverLine := J = 0;
        Spark.ShowSelection := J = 0;
        Spark.ShowLastPoint := (I in [0, 5, 9]) and (J = 0);
        Spark.ShowMinMaxPoints := (I = 0) and (J = 0);
        Spark.ShowArea := I in [1, 6, 8];
        Spark.UseGradientArea := I in [1, 6];
        Spark.ShowTargetLine := I = 5;
        Spark.TargetValue := 48;
        Spark.ShowAverageLine := I = 6;
        Spark.ShowRangeBand := I = 8;
        Spark.BandMinimum := 32;
        Spark.BandMaximum := 63;
        Spark.ColorizeNegativeSegments := I in [3, 7];
        Spark.ColorizeRisingFallingSegments := I = 9;
        Spark.UseRoundedBars := I = 2;
        Spark.SparklinePadding := 3;
        Spark.SetValues(Values);
      finally
        Spark.EndUpdate;
      end;
    end;
  end;
end;

procedure AddNimbusMicroGallery(const Tabs: TThemedTabControl);
const
  Names: array[0..9] of string = ('Bullet chart', 'Donut chart', 'Heatstrip', 'Histogram', 'Waterfall', 'Candlestick', 'Funnel', 'Stacked bar', 'Gauge', 'Box plot');
  Kinds: array[0..9] of TMicroChartKind = (mckBullet, mckDonut, mckHeatstrip, mckHistogram, mckWaterfall, mckCandlestick, mckFunnel, mckStackedBar, mckGauge, mckBoxPlot);

var
  Page: TTabSheet;
  Scroll: TScrollBox;
  Card: TThemedPanel;
  TitleLabel: TThemedLabel;
  Chart: TThemedMicroChart;
  I, J: Integer;
begin
  if Tabs = nil then Exit;

  Page := TTabSheet.Create(Tabs.Owner);
  Page.PageControl := Tabs;
  Page.Caption := 'Micro chart types';

  Scroll := TScrollBox.Create(Page);
  Scroll.Parent := Page;
  Scroll.Align := alClient;
  Scroll.BorderStyle := bsNone;
  Scroll.VertScrollBar.Tracking := True;
  for I := 0 to 9 do
  begin
    Card := TThemedPanel.Create(Page);
    Card.Parent := Scroll;
    Card.SetBounds(12 + (I mod 2)*366, 12 + (I div 2)*146, 352, 134);
    TitleLabel := TThemedLabel.Create(Page);
    TitleLabel.Parent := Card;
    TitleLabel.SetBounds(12, 8, 310, 22);
    TitleLabel.Caption := Names[I];
    for J := 0 to 1 do
    begin
      Chart := TThemedMicroChart.Create(Page);
      Chart.Parent := Card;
      Chart.Kind := Kinds[I];
      Chart.Target := 100;
      if J = 0 then Chart.SetBounds(12, 37, 240, 82) else Chart.SetBounds(267, 57, 72, 24);
      case Kinds[I] of
        mckBullet: Chart.SetData([72, 60, 85, 90]);
        mckDonut: Chart.SetData([35, 25, 20, 12, 8]);
        mckHeatstrip: Chart.SetData([12, 25, 54, 30, 72, 85, 40, 66, 98, 44, 18, 62, 78, 90]);
        mckHistogram: Chart.SetData([2, 5, 9, 16, 23, 30, 20, 12, 7, 3]);
        mckWaterfall: Chart.SetData([28, -9, 14, -12, 24, -7, 10, -13]);
        mckCandlestick: Chart.SetData([48, 62, 44, 58, 58, 69, 51, 54, 54, 60, 39, 43, 43, 55, 37, 53, 53, 66, 48, 61]);
        mckFunnel: Chart.SetData([100, 81, 63, 38, 21]);
        mckStackedBar: Chart.SetData([24, 34, 19, 15, 8]);
        mckGauge: Chart.SetData([76]);
        mckBoxPlot: Chart.SetData([10, 18, 22, 28, 31, 35, 42, 48, 57, 70, 88]);
      end;
    end;
  end;
end;

procedure AddNimbusDashboardGallery(const Tabs: TThemedTabControl);
const
  Names: array[0..9] of string = ('KPI tile', 'Delta tile', 'Progress meter', 'Segment meter', 'Status matrix', 'Trend arrow', 'Comparison bars', 'Radial score', 'Activity dots', 'Capacity bars');

var
  Page: TTabSheet;
  Scroll: TScrollBox;
  Widget: TCustomThemedDashboardWidget;
  I: Integer;
begin
  if Tabs = nil then Exit;

  Page := TTabSheet.Create(Tabs.Owner);
  Page.PageControl := Tabs;
  Page.Caption := 'Dashboard widgets';

  Scroll := TScrollBox.Create(Page);
  Scroll.Parent := Page;
  Scroll.Align := alClient;
  Scroll.BorderStyle := bsNone;
  Scroll.VertScrollBar.Tracking := True;
  for I := 0 to 9 do
  begin
    case I of
      0: Widget := TThemedKpiTile.Create(Page);
      1: Widget := TThemedDeltaTile.Create(Page);
      2: Widget := TThemedProgressMeter.Create(Page);
      3: Widget := TThemedSegmentMeter.Create(Page);
      4: Widget := TThemedStatusMatrix.Create(Page);
      5: Widget := TThemedTrendArrow.Create(Page);
      6: Widget := TThemedComparisonBars.Create(Page);
      7: Widget := TThemedRadialScore.Create(Page);
      8: Widget := TThemedActivityDots.Create(Page);
    else Widget := TThemedCapacityBars.Create(Page)
    end;
    Widget.Parent := Scroll;
    Widget.SetBounds(16+(I mod 3)*252, 16+(I div 3)*152, 236, 136);
    Widget.Caption := Names[I];
    Widget.Target := 100;
    Widget.Detail := 'Last 30 days';
    case I of
      0: Widget.SetData([128430]);
      1: Widget.SetData([87.5, 71.2]);
      2: Widget.SetData([78]);
      3: Widget.SetData([64]);
      4: Widget.SetData([1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1]);
      5: Widget.SetData([24.8, 17.2]);
      6: Widget.SetData([92, 68, 84, 57]);
      7: Widget.SetData([83]);
      8: Widget.SetData([1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0]);
      9: Widget.SetData([42, 74, 56, 89, 67, 93]);
    end;
  end;
end;

procedure AddNimbusPerformanceGallery(const Tabs: TThemedTabControl);
const
  Names: array[0..9] of string = ('CPU utilization', 'Memory pressure', 'Network traffic', 'Latency', 'Disk I/O', 'Frame rate', 'Error rate', 'Throughput', 'Temperature', 'Queue depth');

var
  Page: TTabSheet;
  Scroll: TScrollBox;
  Card: TThemedPanel;
  TitleLabel: TThemedLabel;
  Chart: TThemedPerformanceChart;
  I, J, K: Integer;
  Value: Double;
begin
  if Tabs = nil then Exit;

  Page := TTabSheet.Create(Tabs.Owner);
  Page.PageControl := Tabs;
  Page.Caption := 'Performance monitoring';

  Scroll := TScrollBox.Create(Page);
  Scroll.Parent := Page;
  Scroll.Align := alClient;
  Scroll.BorderStyle := bsNone;
  Scroll.VertScrollBar.Tracking := True;
  for I := 0 to 9 do
  begin
    Card := TThemedPanel.Create(Page);
    Card.Parent := Scroll;
    Card.SetBounds(12 + (I mod 2) * 366, 12 + (I div 2) * 146, 352, 134);
    TitleLabel := TThemedLabel.Create(Page);
    TitleLabel.Parent := Card;
    TitleLabel.SetBounds(12, 8, 310, 22);
    TitleLabel.Caption := Names[I];
    for J := 0 to 1 do
    begin
      Chart := TThemedPerformanceChart.Create(Page);
      Chart.Parent := Card;
      Chart.Mode := TPerformanceChartMode(I);
      Chart.Capacity := 48;
      Chart.GridDensity := TSparklineGridDensity((I mod 3) + 1);
      if J = 0 then Chart.SetBounds(12, 37, 240, 82) else Chart.SetBounds(267, 57, 72, 24);
      Chart.BeginUpdate;
      try
        for K := 0 to 47 do
        begin
          Value := 42 + Sin(K * (0.17 + I * 0.02) + I) * 16 + Cos(K * 0.47 + I * 0.3) * 9;
          case I of
            1: Value := 67 + Sin(K * 0.08) * 5 + K * 0.12;
            2, 4, 7: Value := Max(0, Value + Sin(K * 1.7) * 24);
            3: Value := 12 + Abs(Sin(K * 0.34 + I)) * 18 + Abs(Cos(K * 1.8)) * 11;
            5: Value := 58 + Sin(K * 0.23) * 7 + Cos(K * 0.92) * 4;
            6: Value := IfThen(K mod 11 = 0, 12.0, IfThen(K mod 7 = 0, 4.0, 0.0));
            8: Value := 67 + Sin(K * 0.1) * 14;
            9: Value := Max(0, Round(8 + Sin(K * 0.41) * 5));
          end;
          Chart.PushSample(Value);
        end;
      finally
        Chart.EndUpdate;
      end;
    end;
  end;
end;


end.

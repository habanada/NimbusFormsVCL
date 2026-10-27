{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Charts.Types;

interface

uses
  Winapi.Windows, System.Classes, System.Types, System.UITypes, System.SysUtils, System.Math, System.Generics.Collections,
  Vcl.Graphics, NimbusForms.Theming.Palette, NimbusForms.Theming.Types,
  NimbusForms.Rendering.Types, NimbusForms.Charts.Sparkline.Types, NimbusForms.Charts.Violin.Types, NimbusForms.Charts.Ridgeline.Types, NimbusForms.Charts.StreamGraph.Types, NimbusForms.Charts.Treemap.Types, NimbusForms.Charts.Sunburst.Types, NimbusForms.Charts.Sankey.Types, NimbusForms.Charts.ProgressRingGrid.Types, NimbusForms.Charts.EdgeBundling.Types, NimbusForms.Charts.Marimekko.Types, NimbusForms.Charts.Financial.Types;

type
  TNimbusChartType = (nctLine, nctArea, nctBar, nctColumn, nctPie, nctDonut, nctKpi, nctGauge, nctBullet, nctScatter, nctBubble, nctHeatmap, nctRadar, nctRadialBar, nctTreemap, nctBoxPlot, nctNestedPie, nctLineScatter, nctBusinessRadialGoal, nctBusinessPortfolioArc, nctBusinessRankedBar, nctBusinessFunnel, nctBusinessLollipopBar, nctBusinessBullet, nctBusinessDivergingBar, nctBusinessWaterfall, nctBusinessStackedHorizontalBar, nctBusinessKpiTiles, nctBusinessModernWaterfall, nctBusinessPareto, nctBusinessTimelineRange, nctBusinessCalendarHeatmap, nctChoroplethMap, nctCountryMap, nctSankey, nctHierarchicalEdgeBundling, nctProgressRingGrid, nctMarimekko, nctSunburst, nctStreamGraph, nctRidgeline, nctCandlestick, nctOhlc, nctViolinPlot);
  TNimbusSeriesRenderKind = (nsrkDefault, nsrkLine, nsrkArea, nsrkBar, nsrkColumn, nsrkPie, nsrkDonut, nsrkKpi, nsrkGauge, nsrkBullet, nsrkScatter, nsrkBubble, nsrkHeatmap, nsrkRadar, nsrkRadialBar, nsrkTreemap, nsrkBoxPlot, nsrkNestedPie, nsrkLineScatter);
  TNimbusChartAxisScale = (ncasLinear, ncasAutomatic, ncasLogarithmic10, ncasLogarithmic2, ncasNaturalLogarithmic, ncasCustomLogarithmic, ncasSquareRoot, ncasPower, ncasSymmetricLogarithmic);
  TNimbusChartAxisPosition = (ncapLeft, ncapTop, ncapRight, ncapBottom);
  TNimbusChartLegendPosition = (nclpNone, nclpLeft, nclpTop, nclpRight, nclpBottom);
  TNimbusChartMarkerShape = (ncmsNone, ncmsCircle, ncmsSquare, ncmsDiamond, ncmsTriangle);
  TNimbusChartOrientation = (ncoVertical, ncoHorizontal);
  TNimbusChartSeriesYAxis = (ncyPrimary, ncySecondary);
  TNimbusChartAxisValueType = (ncavtNumeric, ncavtDateTimeOADate);
  TNimbusChartLogarithmicMinorTickMode = (nclmtNone, nclmtAutomatic, nclmtAll);
  TNimbusChartLogarithmicLabelMode = (ncllmPlainNumber, ncllmScientific, ncllmPowerNotation);
  TNimbusChartInvalidLogValueBehavior = (ncilSkip, ncilClamp, ncilThrow);
  TNimbusChartDownsamplingMode = (ncdNone, ncdAutomatic, ncdMinMax, ncdLargestTriangleThreeBuckets);
  TNimbusChartColorMode = (nccTheme, nccCustom, nccAdaptiveCustom);
  TNimbusChartMapColorMode = (ncmValueGradient, ncmCategorical);
  TNimbusHeatmapColorPreset = (nhcpTheme, nhcpCustom, nhcpGitHubGreen, nhcpGitHubDark, nhcpReds, nhcpThermal);
  TNimbusChartAppearance = (ncaVsIdeLight, ncaVsIdeDark, ncaGlowing);
  TNimbusKpiState = (nksNeutral, nksSuccess, nksWarning, nksError, nksInfo);
  TNimbusChartMapRegion = (ncmrWorld, ncmrEurope, ncmrAfrica, ncmrNorthAmerica, ncmrSouthAmerica, ncmrAmericas, ncmrAsia, ncmrOceania);
  TNimbusChartReferenceOrientation = (ncroHorizontal, ncroVertical);
  TNimbusChartAnnotationAlignment = (ncaaNear, ncaaCenter, ncaaFar);

  TNimbusChartRange = TSparklineValueRange;
  TNimbusChartAxisLabelFormatEvent = procedure(Sender: TObject; AValue: Double; var AText: string) of object;

  TNimbusChartPersistent = class(TPersistent)
  private
    FOnChange: TNotifyEvent;
  protected
    procedure Changed;
  public
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TNimbusChartPalette = class(TNimbusChartPersistent)
  private
    FColors: TArray<TColor>;
    FBackColor: TColor;
    FForeColor: TColor;
    FMutedForeColor: TColor;
    FBorderColor: TColor;
    FGridLineColor: TColor;
    FPlotBackColor: TColor;
    FAccentColor: TColor;
    FSuccessColor: TColor;
    FWarningColor: TColor;
    FErrorColor: TColor;
    FInfoColor: TColor;
    function GetColors: TArray<TColor>;
    procedure SetColors(const AValue: TArray<TColor>);
    procedure ReadColors(Reader: TReader);
    procedure WriteColors(Writer: TWriter);
    procedure SetBackColor(const AValue: TColor);
    procedure SetForeColor(const AValue: TColor);
    procedure SetMutedForeColor(const AValue: TColor);
    procedure SetBorderColor(const AValue: TColor);
    procedure SetGridLineColor(const AValue: TColor);
    procedure SetPlotBackColor(const AValue: TColor);
    procedure SetAccentColor(const AValue: TColor);
    procedure SetSuccessColor(const AValue: TColor);
    procedure SetWarningColor(const AValue: TColor);
    procedure SetErrorColor(const AValue: TColor);
    procedure SetInfoColor(const AValue: TColor);
  protected
    procedure DefineProperties(Filer: TFiler); override;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    procedure ApplyLightDefaults;
    procedure ApplyGlowingDefaults;
    procedure ApplyDarkDefaults;
    procedure ApplyTheme(const ATheme: TThemePalette);
    procedure ApplyThemeBlend(const ATheme: TThemePalette; const AInfluence: Integer);
    function GetSeriesColor(const AIndex: Integer): TColor;
    function Clone: TNimbusChartPalette;
    property Colors: TArray<TColor> read GetColors write SetColors;
  published
    property BackColor: TColor read FBackColor write SetBackColor;
    property ForeColor: TColor read FForeColor write SetForeColor;
    property MutedForeColor: TColor read FMutedForeColor write SetMutedForeColor;
    property BorderColor: TColor read FBorderColor write SetBorderColor;
    property GridLineColor: TColor read FGridLineColor write SetGridLineColor;
    property PlotBackColor: TColor read FPlotBackColor write SetPlotBackColor;
    property AccentColor: TColor read FAccentColor write SetAccentColor;
    property SuccessColor: TColor read FSuccessColor write SetSuccessColor;
    property WarningColor: TColor read FWarningColor write SetWarningColor;
    property ErrorColor: TColor read FErrorColor write SetErrorColor;
    property InfoColor: TColor read FInfoColor write SetInfoColor;
  end;

  TNimbusChartPoint = class;
  TNimbusChartSeries = class;
  TNimbusChartModel = class;

  TNimbusChartPointCollection = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    function GetItem(Index: Integer): TNimbusChartPoint;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TNimbusChartPoint; overload;
    function Add(const AX, AY: Double; const ALabel: string = ''): TNimbusChartPoint; overload;
    property Items[Index: Integer]: TNimbusChartPoint read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TNimbusChartSeriesCollection = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    function GetItem(Index: Integer): TNimbusChartSeries;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TNimbusChartSeries;
    property Items[Index: Integer]: TNimbusChartSeries read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TNimbusChartPoint = class(TCollectionItem)
  private
    FXValue: Double;
    FYValue: Double;
    FSizeValue: Double;
    FLabel: string;
    FToolTipText: string;
    FColor: TColor;
    FVisible: Boolean;
    FTag: NativeInt;
    FShowValue: Boolean;
    procedure SetXValue(const AValue: Double);
    procedure SetYValue(const AValue: Double);
    procedure SetSizeValue(const AValue: Double);
    procedure SetLabel(const AValue: string);
    procedure SetToolTipText(const AValue: string);
    procedure SetColor(const AValue: TColor);
    procedure SetVisible(const AValue: Boolean);
    procedure SetTag(const AValue: NativeInt);
    procedure SetShowValue(const AValue: Boolean);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property XValue: Double read FXValue write SetXValue;
    property YValue: Double read FYValue write SetYValue;
    property SizeValue: Double read FSizeValue write SetSizeValue;
    property &Label: string read FLabel write SetLabel;
    property ToolTipText: string read FToolTipText write SetToolTipText;
    property Color: TColor read FColor write SetColor;
    property Visible: Boolean read FVisible write SetVisible;
    property Tag: NativeInt read FTag write SetTag;
    property ShowValue: Boolean read FShowValue write SetShowValue default False;
  end;

  TNimbusBulletRange = class(TCollectionItem)
  private
    FStartValue: Double;
    FEndValue: Double;
    FLabel: string;
    FColor: TColor;
    procedure SetStartValue(const AValue: Double);
    procedure SetEndValue(const AValue: Double);
    procedure SetLabel(const AValue: string);
    procedure SetColor(const AValue: TColor);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property StartValue: Double read FStartValue write SetStartValue;
    property EndValue: Double read FEndValue write SetEndValue;
    property &Label: string read FLabel write SetLabel;
    property Color: TColor read FColor write SetColor;
  end;

  TNimbusBulletRangeCollection = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    function GetItem(Index: Integer): TNimbusBulletRange;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TNimbusBulletRange;
    property Items[Index: Integer]: TNimbusBulletRange read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TNimbusBulletData = class(TNimbusChartPersistent)
  private
    FEnabled: Boolean;
    FTitle: string;
    FSubtitle: string;
    FMinimum: Double;
    FMaximum: Double;
    FActualValue: Double;
    FTargetValue: Double;
    FActualText: string;
    FTargetText: string;
    FOrientation: TNimbusChartOrientation;
    FRanges: TNimbusBulletRangeCollection;
    procedure SetEnabled(const AValue: Boolean);
    procedure SetTitle(const AValue: string);
    procedure SetSubtitle(const AValue: string);
    procedure SetMinimum(const AValue: Double);
    procedure SetMaximum(const AValue: Double);
    procedure SetActualValue(const AValue: Double);
    procedure SetTargetValue(const AValue: Double);
    procedure SetActualText(const AValue: string);
    procedure SetTargetText(const AValue: string);
    procedure SetOrientation(const AValue: TNimbusChartOrientation);
    procedure RangesChanged(Sender: TObject);
    procedure SetRanges(const AValue: TNimbusBulletRangeCollection);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Enabled: Boolean read FEnabled write SetEnabled;
    property Title: string read FTitle write SetTitle;
    property Subtitle: string read FSubtitle write SetSubtitle;
    property Minimum: Double read FMinimum write SetMinimum;
    property Maximum: Double read FMaximum write SetMaximum;
    property ActualValue: Double read FActualValue write SetActualValue;
    property TargetValue: Double read FTargetValue write SetTargetValue;
    property ActualText: string read FActualText write SetActualText;
    property TargetText: string read FTargetText write SetTargetText;
    property Orientation: TNimbusChartOrientation read FOrientation write SetOrientation;
    property Ranges: TNimbusBulletRangeCollection read FRanges write SetRanges;
  end;

  TNimbusBoxPlotData = class(TNimbusChartPersistent)
  private
    FEnabled: Boolean;
    FCategory: string;
    FMinimum: Double;
    FQ1: Double;
    FMedian: Double;
    FQ3: Double;
    FMaximum: Double;
    FOutliers: TSparklineValues;
    procedure SetEnabled(const AValue: Boolean);
    procedure SetCategory(const AValue: string);
    procedure SetMinimum(const AValue: Double);
    procedure SetQ1(const AValue: Double);
    procedure SetMedian(const AValue: Double);
    procedure SetQ3(const AValue: Double);
    procedure SetMaximum(const AValue: Double);
    function GetOutliers: TSparklineValues;
    procedure SetOutliers(const AValue: TSparklineValues);
    procedure ReadOutliers(Reader: TReader);
    procedure WriteOutliers(Writer: TWriter);
  protected
    procedure DefineProperties(Filer: TFiler); override;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property Outliers: TSparklineValues read GetOutliers write SetOutliers;
  published
    property Enabled: Boolean read FEnabled write SetEnabled;
    property Category: string read FCategory write SetCategory;
    property Minimum: Double read FMinimum write SetMinimum;
    property Q1: Double read FQ1 write SetQ1;
    property Median: Double read FMedian write SetMedian;
    property Q3: Double read FQ3 write SetQ3;
    property Maximum: Double read FMaximum write SetMaximum;
  end;

  TNimbusChartSeries = class(TCollectionItem)
  private
    FName: string;
    FRenderKind: TNimbusSeriesRenderKind;
    FColor: TColor;
    FVisible: Boolean;
    FShowMarkers: Boolean;
    FShowValues: Boolean;
    FLineWidth: Single;
    FMarkerSize: Single;
    FFillOpacity: Single;
    FMarkerShape: TNimbusChartMarkerShape;
    FValueFormat: string;
    FYAxis: TNimbusChartSeriesYAxis;
    FDownsamplingMode: TNimbusChartDownsamplingMode;
    FDownsamplingThreshold: Integer;
    FTag: NativeInt;
    FBullet: TNimbusBulletData;
    FBoxPlot: TNimbusBoxPlotData;
    FPoints: TNimbusChartPointCollection;
    procedure SetName(const AValue: string);
    procedure SetRenderKind(const AValue: TNimbusSeriesRenderKind);
    procedure SetColor(const AValue: TColor);
    procedure SetVisible(const AValue: Boolean);
    procedure SetShowMarkers(const AValue: Boolean);
    procedure SetShowValues(const AValue: Boolean);
    procedure SetLineWidth(const AValue: Single);
    procedure SetMarkerSize(const AValue: Single);
    procedure SetFillOpacity(const AValue: Single);
    procedure SetMarkerShape(const AValue: TNimbusChartMarkerShape);
    procedure SetValueFormat(const AValue: string);
    procedure SetYAxis(const AValue: TNimbusChartSeriesYAxis);
    procedure SetDownsamplingMode(const AValue: TNimbusChartDownsamplingMode);
    procedure SetDownsamplingThreshold(const AValue: Integer);
    procedure SetTag(const AValue: NativeInt);
    procedure SetBullet(const AValue: TNimbusBulletData);
    procedure SetBoxPlot(const AValue: TNimbusBoxPlotData);
    procedure PointsChanged(Sender: TObject);
    procedure SetPoints(const AValue: TNimbusChartPointCollection);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    destructor Destroy; override;
    function GetXRange: TNimbusChartRange;
    function GetYRange: TNimbusChartRange;
    function GetRenderPointIndices(const APixelWidth: Integer): TArray<Integer>;
  published
    property Name: string read FName write SetName;
    property RenderKind: TNimbusSeriesRenderKind read FRenderKind write SetRenderKind;
    property Color: TColor read FColor write SetColor;
    property Visible: Boolean read FVisible write SetVisible;
    property ShowMarkers: Boolean read FShowMarkers write SetShowMarkers;
    property ShowValues: Boolean read FShowValues write SetShowValues;
    property LineWidth: Single read FLineWidth write SetLineWidth;
    property MarkerSize: Single read FMarkerSize write SetMarkerSize;
    property FillOpacity: Single read FFillOpacity write SetFillOpacity;
    property MarkerShape: TNimbusChartMarkerShape read FMarkerShape write SetMarkerShape;
    property ValueFormat: string read FValueFormat write SetValueFormat;
    property YAxis: TNimbusChartSeriesYAxis read FYAxis write SetYAxis;
    property DownsamplingMode: TNimbusChartDownsamplingMode read FDownsamplingMode write SetDownsamplingMode;
    property DownsamplingThreshold: Integer read FDownsamplingThreshold write SetDownsamplingThreshold;
    property Tag: NativeInt read FTag write SetTag;
    property Bullet: TNimbusBulletData read FBullet write SetBullet;
    property BoxPlot: TNimbusBoxPlotData read FBoxPlot write SetBoxPlot;
    property Points: TNimbusChartPointCollection read FPoints write SetPoints;
  end;

  TNimbusChartAxis = class(TNimbusChartPersistent)
  private
    FTitle: string;
    FPosition: TNimbusChartAxisPosition;
    FVisible: Boolean;
    FShowGridLines: Boolean;
    FShowMinorGridLines: Boolean;
    FShowLabels: Boolean;
    FAutoRange: Boolean;
    FMinimum: Double;
    FMaximum: Double;
    FLabelFormat: string;
    FScale: TNimbusChartAxisScale;
    FMinorTickMode: TNimbusChartLogarithmicMinorTickMode;
    FLogarithmicLabelMode: TNimbusChartLogarithmicLabelMode;
    FInvalidLogValueBehavior: TNimbusChartInvalidLogValueBehavior;
    FValueType: TNimbusChartAxisValueType;
    FDateTimeLabelFormat: string;
    FTickCount: Integer;
    FPowerExponent: Double;
    FSymmetricLogThreshold: Double;
    FLogarithmicBase: Double;
    FAutomaticLogarithmicThreshold: Double;
    FOnLabelFormatting: TNimbusChartAxisLabelFormatEvent;
    procedure SetTitle(const AValue: string);
    procedure SetPosition(const AValue: TNimbusChartAxisPosition);
    procedure SetVisible(const AValue: Boolean);
    procedure SetShowGridLines(const AValue: Boolean);
    procedure SetShowMinorGridLines(const AValue: Boolean);
    procedure SetShowLabels(const AValue: Boolean);
    procedure SetAutoRange(const AValue: Boolean);
    procedure SetMinimum(const AValue: Double);
    procedure SetMaximum(const AValue: Double);
    procedure SetLabelFormat(const AValue: string);
    procedure SetScale(const AValue: TNimbusChartAxisScale);
    procedure SetMinorTickMode(const AValue: TNimbusChartLogarithmicMinorTickMode);
    procedure SetLogarithmicLabelMode(const AValue: TNimbusChartLogarithmicLabelMode);
    procedure SetInvalidLogValueBehavior(const AValue: TNimbusChartInvalidLogValueBehavior);
    procedure SetValueType(const AValue: TNimbusChartAxisValueType);
    procedure SetDateTimeLabelFormat(const AValue: string);
    procedure SetTickCount(const AValue: Integer);
    procedure SetPowerExponent(const AValue: Double);
    procedure SetSymmetricLogThreshold(const AValue: Double);
    procedure SetLogarithmicBase(const AValue: Double);
    procedure SetAutomaticLogarithmicThreshold(const AValue: Double);
    function LogBase(const AScale: TNimbusChartAxisScale): Double;
    function Transform(const AValue: Double; const AScale: TNimbusChartAxisScale): Double;
    function InverseTransform(const AValue: Double; const AScale: TNimbusChartAxisScale): Double;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    function GetEffectiveScale(const ARange: TNimbusChartRange): TNimbusChartAxisScale;
    function GetEffectiveRange(const ADataRange: TNimbusChartRange): TNimbusChartRange;
    function IsValueValid(const AValue: Double; const ARange: TNimbusChartRange): Boolean;
    function NormalizeValue(const AValue: Double; const ARange: TNimbusChartRange): Double;
    function DenormalizeValue(const ARatio: Double; const ARange: TNimbusChartRange): Double;
    function NormalizeWithinRange(const AValue: Double; const ARange: TNimbusChartRange): Double;
    function DenormalizeWithinRange(const ARatio: Double; const ARange: TNimbusChartRange): Double;
    function CreateTicks(const ARange: TNimbusChartRange): TArray<Double>;
    function CreateMinorTicks(const ARange: TNimbusChartRange): TArray<Double>;
    function FormatValue(const AValue: Double; const ARange: TNimbusChartRange): string;
  published
    property Title: string read FTitle write SetTitle;
    property Position: TNimbusChartAxisPosition read FPosition write SetPosition;
    property Visible: Boolean read FVisible write SetVisible;
    property ShowGridLines: Boolean read FShowGridLines write SetShowGridLines;
    property ShowMinorGridLines: Boolean read FShowMinorGridLines write SetShowMinorGridLines;
    property ShowLabels: Boolean read FShowLabels write SetShowLabels;
    property AutoRange: Boolean read FAutoRange write SetAutoRange;
    property Minimum: Double read FMinimum write SetMinimum;
    property Maximum: Double read FMaximum write SetMaximum;
    property LabelFormat: string read FLabelFormat write SetLabelFormat;
    property Scale: TNimbusChartAxisScale read FScale write SetScale;
    property MinorTickMode: TNimbusChartLogarithmicMinorTickMode read FMinorTickMode write SetMinorTickMode;
    property LogarithmicLabelMode: TNimbusChartLogarithmicLabelMode read FLogarithmicLabelMode write SetLogarithmicLabelMode;
    property InvalidLogValueBehavior: TNimbusChartInvalidLogValueBehavior read FInvalidLogValueBehavior write SetInvalidLogValueBehavior;
    property ValueType: TNimbusChartAxisValueType read FValueType write SetValueType;
    property DateTimeLabelFormat: string read FDateTimeLabelFormat write SetDateTimeLabelFormat;
    property TickCount: Integer read FTickCount write SetTickCount;
    property PowerExponent: Double read FPowerExponent write SetPowerExponent;
    property SymmetricLogThreshold: Double read FSymmetricLogThreshold write SetSymmetricLogThreshold;
    property LogarithmicBase: Double read FLogarithmicBase write SetLogarithmicBase;
    property AutomaticLogarithmicThreshold: Double read FAutomaticLogarithmicThreshold write SetAutomaticLogarithmicThreshold;
    property OnLabelFormatting: TNimbusChartAxisLabelFormatEvent read FOnLabelFormatting write FOnLabelFormatting;
  end;

  TNimbusChartLegend = class(TNimbusChartPersistent)
  private
    FVisible: Boolean;
    FPosition: TNimbusChartLegendPosition;
    FShowSeriesMarkers: Boolean;
    FMaximumItemWidth: Integer;
    procedure SetVisible(const AValue: Boolean);
    procedure SetPosition(const AValue: TNimbusChartLegendPosition);
    procedure SetShowSeriesMarkers(const AValue: Boolean);
    procedure SetMaximumItemWidth(const AValue: Integer);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property Visible: Boolean read FVisible write SetVisible;
    property Position: TNimbusChartLegendPosition read FPosition write SetPosition;
    property ShowSeriesMarkers: Boolean read FShowSeriesMarkers write SetShowSeriesMarkers;
    property MaximumItemWidth: Integer read FMaximumItemWidth write SetMaximumItemWidth;
  end;

  TNimbusChartOptions = class(TNimbusChartPersistent)
  private
    FOrientation: TNimbusChartOrientation;
    FShowTitle: Boolean;
    FShowSubtitle: Boolean;
    FShowBorder: Boolean;
    FShowPlotBorder: Boolean;
    FShowAxes: Boolean;
    FShowGrid: Boolean;
    FShowValues: Boolean;
    FShowToolTips: Boolean;
    FShowAnimation: Boolean;
    FClipToPlotArea: Boolean;
    FInnerRadiusPercent: Integer;
    FCornerRadius: Integer;
    FPadding: Integer;
    FMapRegion: TNimbusChartMapRegion;
    FMapColorMode: TNimbusChartMapColorMode;
    FMapEmptyColor: TColor;
    FCountryMapIsoA3: string;
    FMapZoom: Single;
    FMapOffsetX: Single;
    FMapOffsetY: Single;
    FEnableMapZoom: Boolean;
    FEnableMapPan: Boolean;
    FCountryMapShowRegions: Boolean;
    FCountryMapShowRegionBorders: Boolean;
    FCountryMapShowRegionLabels: Boolean;
    FCountryMapShowCities: Boolean;
    FCountryMapShowCityLabels: Boolean;
    FCountryMapMaxCities: Integer;
    FCountryMapCityMinPopulation: Integer;
    procedure SetOrientation(const AValue: TNimbusChartOrientation);
    procedure SetShowTitle(const AValue: Boolean);
    procedure SetShowSubtitle(const AValue: Boolean);
    procedure SetShowBorder(const AValue: Boolean);
    procedure SetShowPlotBorder(const AValue: Boolean);
    procedure SetShowAxes(const AValue: Boolean);
    procedure SetShowGrid(const AValue: Boolean);
    procedure SetShowValues(const AValue: Boolean);
    procedure SetShowToolTips(const AValue: Boolean);
    procedure SetShowAnimation(const AValue: Boolean);
    procedure SetClipToPlotArea(const AValue: Boolean);
    procedure SetInnerRadiusPercent(const AValue: Integer);
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetPadding(const AValue: Integer);
    procedure SetMapColorMode(const AValue: TNimbusChartMapColorMode);
    procedure SetMapEmptyColor(const AValue: TColor);
    procedure SetMapRegion(const AValue: TNimbusChartMapRegion);
    procedure SetCountryMapIsoA3(const AValue: string);
    procedure SetMapZoom(const AValue: Single);
    procedure SetMapOffsetX(const AValue: Single);
    procedure SetMapOffsetY(const AValue: Single);
    procedure SetEnableMapZoom(const AValue: Boolean);
    procedure SetEnableMapPan(const AValue: Boolean);
    procedure SetCountryMapShowRegions(const AValue: Boolean);
    procedure SetCountryMapShowRegionBorders(const AValue: Boolean);
    procedure SetCountryMapShowRegionLabels(const AValue: Boolean);
    procedure SetCountryMapShowCities(const AValue: Boolean);
    procedure SetCountryMapShowCityLabels(const AValue: Boolean);
    procedure SetCountryMapMaxCities(const AValue: Integer);
    procedure SetCountryMapCityMinPopulation(const AValue: Integer);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property Orientation: TNimbusChartOrientation read FOrientation write SetOrientation;
    property ShowTitle: Boolean read FShowTitle write SetShowTitle;
    property ShowSubtitle: Boolean read FShowSubtitle write SetShowSubtitle;
    property ShowBorder: Boolean read FShowBorder write SetShowBorder;
    property ShowPlotBorder: Boolean read FShowPlotBorder write SetShowPlotBorder;
    property ShowAxes: Boolean read FShowAxes write SetShowAxes;
    property ShowGrid: Boolean read FShowGrid write SetShowGrid;
    property ShowValues: Boolean read FShowValues write SetShowValues;
    property ShowToolTips: Boolean read FShowToolTips write SetShowToolTips;
    property ShowAnimation: Boolean read FShowAnimation write SetShowAnimation;
    property ClipToPlotArea: Boolean read FClipToPlotArea write SetClipToPlotArea;
    property InnerRadiusPercent: Integer read FInnerRadiusPercent write SetInnerRadiusPercent;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius;
    property Padding: Integer read FPadding write SetPadding;
    property MapColorMode: TNimbusChartMapColorMode read FMapColorMode write SetMapColorMode default ncmValueGradient;
    property MapEmptyColor: TColor read FMapEmptyColor write SetMapEmptyColor default clNone;
    property MapRegion: TNimbusChartMapRegion read FMapRegion write SetMapRegion;
    property CountryMapIsoA3: string read FCountryMapIsoA3 write SetCountryMapIsoA3;
    property MapZoom: Single read FMapZoom write SetMapZoom;
    property MapOffsetX: Single read FMapOffsetX write SetMapOffsetX;
    property MapOffsetY: Single read FMapOffsetY write SetMapOffsetY;
    property EnableMapZoom: Boolean read FEnableMapZoom write SetEnableMapZoom;
    property EnableMapPan: Boolean read FEnableMapPan write SetEnableMapPan;
    property CountryMapShowRegions: Boolean read FCountryMapShowRegions write SetCountryMapShowRegions;
    property CountryMapShowRegionBorders: Boolean read FCountryMapShowRegionBorders write SetCountryMapShowRegionBorders;
    property CountryMapShowRegionLabels: Boolean read FCountryMapShowRegionLabels write SetCountryMapShowRegionLabels;
    property CountryMapShowCities: Boolean read FCountryMapShowCities write SetCountryMapShowCities;
    property CountryMapShowCityLabels: Boolean read FCountryMapShowCityLabels write SetCountryMapShowCityLabels;
    property CountryMapMaxCities: Integer read FCountryMapMaxCities write SetCountryMapMaxCities;
    property CountryMapCityMinPopulation: Integer read FCountryMapCityMinPopulation write SetCountryMapCityMinPopulation;
  end;

  TNimbusChartReferenceLine = class(TCollectionItem)
  private
    FOrientation: TNimbusChartReferenceOrientation;
    FValue: Double;
    FText: string;
    FColor: TColor;
    FWidth: Single;
    FVisible: Boolean;
    FYAxis: TNimbusChartSeriesYAxis;
    FTag: NativeInt;
    procedure SetOrientation(const AValue: TNimbusChartReferenceOrientation);
    procedure SetValue(const AValue: Double);
    procedure SetText(const AValue: string);
    procedure SetColor(const AValue: TColor);
    procedure SetWidth(const AValue: Single);
    procedure SetVisible(const AValue: Boolean);
    procedure SetYAxis(const AValue: TNimbusChartSeriesYAxis);
    procedure SetTag(const AValue: NativeInt);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Orientation: TNimbusChartReferenceOrientation read FOrientation write SetOrientation;
    property Value: Double read FValue write SetValue;
    property Text: string read FText write SetText;
    property Color: TColor read FColor write SetColor;
    property Width: Single read FWidth write SetWidth;
    property Visible: Boolean read FVisible write SetVisible;
    property YAxis: TNimbusChartSeriesYAxis read FYAxis write SetYAxis;
    property Tag: NativeInt read FTag write SetTag;
  end;

  TNimbusChartReferenceLineCollection = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    function GetItem(Index: Integer): TNimbusChartReferenceLine;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TNimbusChartReferenceLine;
    property Items[Index: Integer]: TNimbusChartReferenceLine read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TNimbusChartReferenceRange = class(TCollectionItem)
  private
    FOrientation: TNimbusChartReferenceOrientation;
    FMinimum: Double;
    FMaximum: Double;
    FText: string;
    FColor: TColor;
    FOpacity: Single;
    FVisible: Boolean;
    FYAxis: TNimbusChartSeriesYAxis;
    FTag: NativeInt;
    procedure SetOrientation(const AValue: TNimbusChartReferenceOrientation);
    procedure SetMinimum(const AValue: Double);
    procedure SetMaximum(const AValue: Double);
    procedure SetText(const AValue: string);
    procedure SetColor(const AValue: TColor);
    procedure SetOpacity(const AValue: Single);
    procedure SetVisible(const AValue: Boolean);
    procedure SetYAxis(const AValue: TNimbusChartSeriesYAxis);
    procedure SetTag(const AValue: NativeInt);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Orientation: TNimbusChartReferenceOrientation read FOrientation write SetOrientation;
    property Minimum: Double read FMinimum write SetMinimum;
    property Maximum: Double read FMaximum write SetMaximum;
    property Text: string read FText write SetText;
    property Color: TColor read FColor write SetColor;
    property Opacity: Single read FOpacity write SetOpacity;
    property Visible: Boolean read FVisible write SetVisible;
    property YAxis: TNimbusChartSeriesYAxis read FYAxis write SetYAxis;
    property Tag: NativeInt read FTag write SetTag;
  end;

  TNimbusChartReferenceRangeCollection = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    function GetItem(Index: Integer): TNimbusChartReferenceRange;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TNimbusChartReferenceRange;
    property Items[Index: Integer]: TNimbusChartReferenceRange read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TNimbusChartAnnotation = class(TCollectionItem)
  private
    FXValue: Double;
    FYValue: Double;
    FText: string;
    FForeColor: TColor;
    FBackColor: TColor;
    FBorderColor: TColor;
    FVisible: Boolean;
    FPadding: Integer;
    FAlignment: TNimbusChartAnnotationAlignment;
    FYAxis: TNimbusChartSeriesYAxis;
    FSelectable: Boolean;
    FToolTipText: string;
    FAutoArrange: Boolean;
    FLeaderLineVisible: Boolean;
    FZIndex: Integer;
    FOffsetX: Single;
    FOffsetY: Single;
    FTag: NativeInt;
    procedure SetXValue(const AValue: Double);
    procedure SetYValue(const AValue: Double);
    procedure SetText(const AValue: string);
    procedure SetForeColor(const AValue: TColor);
    procedure SetBackColor(const AValue: TColor);
    procedure SetBorderColor(const AValue: TColor);
    procedure SetVisible(const AValue: Boolean);
    procedure SetPadding(const AValue: Integer);
    procedure SetAlignment(const AValue: TNimbusChartAnnotationAlignment);
    procedure SetYAxis(const AValue: TNimbusChartSeriesYAxis);
    procedure SetSelectable(const AValue: Boolean);
    procedure SetToolTipText(const AValue: string);
    procedure SetAutoArrange(const AValue: Boolean);
    procedure SetLeaderLineVisible(const AValue: Boolean);
    procedure SetZIndex(const AValue: Integer);
    procedure SetOffsetX(const AValue: Single);
    procedure SetOffsetY(const AValue: Single);
    procedure SetTag(const AValue: NativeInt);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property XValue: Double read FXValue write SetXValue;
    property YValue: Double read FYValue write SetYValue;
    property Text: string read FText write SetText;
    property ForeColor: TColor read FForeColor write SetForeColor;
    property BackColor: TColor read FBackColor write SetBackColor;
    property BorderColor: TColor read FBorderColor write SetBorderColor;
    property Visible: Boolean read FVisible write SetVisible;
    property Padding: Integer read FPadding write SetPadding;
    property Alignment: TNimbusChartAnnotationAlignment read FAlignment write SetAlignment;
    property YAxis: TNimbusChartSeriesYAxis read FYAxis write SetYAxis;
    property Selectable: Boolean read FSelectable write SetSelectable;
    property ToolTipText: string read FToolTipText write SetToolTipText;
    property AutoArrange: Boolean read FAutoArrange write SetAutoArrange;
    property LeaderLineVisible: Boolean read FLeaderLineVisible write SetLeaderLineVisible;
    property ZIndex: Integer read FZIndex write SetZIndex;
    property OffsetX: Single read FOffsetX write SetOffsetX;
    property OffsetY: Single read FOffsetY write SetOffsetY;
    property Tag: NativeInt read FTag write SetTag;
  end;

  TNimbusChartAnnotationCollection = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    function GetItem(Index: Integer): TNimbusChartAnnotation;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TNimbusChartAnnotation;
    property Items[Index: Integer]: TNimbusChartAnnotation read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TNimbusChartModel = class(TNimbusChartPersistent)
  private
    FChartType: TNimbusChartType;
    FTitle: string;
    FSubtitle: string;
    FKpiTitle: string;
    FKpiValueText: string;
    FKpiSubtitle: string;
    FKpiChangeText: string;
    FKpiValue: Double;
    FKpiChangeValue: Double;
    FKpiState: TNimbusKpiState;
    FGaugeMinimum: Double;
    FGaugeMaximum: Double;
    FGaugeValue: Double;
    FGaugeCenterLabel: string;
    FGaugeShowNeedle: Boolean;
    FGaugeShowThresholds: Boolean;
    FGaugeStartAngle: Integer;
    FGaugeSweepAngle: Integer;
    FGaugeValueSuffix: string;
    FHeatmapColumnCount: Integer;
    FHeatmapRowCount: Integer;
    FHeatmapMinimum: Double;
    FHeatmapMaximum: Double;
    FHeatmapAutoRange: Boolean;
    FHeatmapSquareCells: Boolean;
    FHeatmapShowLegend: Boolean;
    FHeatmapShowCellLabels: Boolean;
    FHeatmapCellGap: Integer;
    FHeatmapCellCornerRadius: Integer;
    FHeatmapColorPreset: TNimbusHeatmapColorPreset;
    FHeatmapEmptyColor: TColor;
    FHeatmapLowColor: TColor;
    FHeatmapHighColor: TColor;
    FUpdateLevel: Integer;
    FChangedWhileUpdating: Boolean;
    FReferenceLines: TNimbusChartReferenceLineCollection;
    FReferenceRanges: TNimbusChartReferenceRangeCollection;
    FAnnotations: TNimbusChartAnnotationCollection;
    FPalette: TNimbusChartPalette;
    FSeries: TNimbusChartSeriesCollection;
    FXAxis: TNimbusChartAxis;
    FYAxis: TNimbusChartAxis;
    FSecondaryYAxis: TNimbusChartAxis;
    FLegend: TNimbusChartLegend;
    FOptions: TNimbusChartOptions;
    FViolinOptions: TNimbusViolinPlotOptions;
    FRidgelineOptions: TNimbusRidgelineOptions;
    FStreamGraphOptions: TNimbusStreamGraphOptions;
    FTreemapOptions: TNimbusTreemapOptions;
    FSunburstOptions: TNimbusSunburstOptions;
    FSankey: TNimbusSankeyData;
    FFinancialOptions: TNimbusFinancialChartOptions;
    FFinancialData: TNimbusFinancialDataPointCollection;
    FMarimekkoOptions: TNimbusMarimekkoOptions;
    FEdgeBundling: TNimbusHierarchicalEdgeBundlingData;
    FProgressRingGrid: TNimbusProgressRingGridData;
    FHeatmapColumnLabels: TStrings;
    FHeatmapRowLabels: TStrings;
    procedure SetChartType(const AValue: TNimbusChartType);
    procedure SetTitle(const AValue: string);
    procedure SetSubtitle(const AValue: string);
    procedure SetKpiTitle(const AValue: string);
    procedure SetKpiValueText(const AValue: string);
    procedure SetKpiSubtitle(const AValue: string);
    procedure SetKpiChangeText(const AValue: string);
    procedure SetKpiValue(const AValue: Double);
    procedure SetKpiChangeValue(const AValue: Double);
    procedure SetKpiState(const AValue: TNimbusKpiState);
    procedure SetGaugeMinimum(const AValue: Double);
    procedure SetGaugeMaximum(const AValue: Double);
    procedure SetGaugeValue(const AValue: Double);
    procedure SetGaugeCenterLabel(const AValue: string);
    procedure SetGaugeShowNeedle(const AValue: Boolean);
    procedure SetGaugeShowThresholds(const AValue: Boolean);
    procedure SetGaugeStartAngle(const AValue: Integer);
    procedure SetGaugeSweepAngle(const AValue: Integer);
    procedure SetGaugeValueSuffix(const AValue: string);
    procedure SetHeatmapColumnCount(const AValue: Integer);
    procedure SetHeatmapRowCount(const AValue: Integer);
    procedure SetHeatmapMinimum(const AValue: Double);
    procedure SetHeatmapMaximum(const AValue: Double);
    procedure SetHeatmapAutoRange(const AValue: Boolean);
    procedure SetHeatmapSquareCells(const AValue: Boolean);
    procedure SetHeatmapShowLegend(const AValue: Boolean);
    procedure SetHeatmapShowCellLabels(const AValue: Boolean);
    procedure SetHeatmapCellGap(const AValue: Integer);
    procedure SetHeatmapCellCornerRadius(const AValue: Integer);
    procedure SetHeatmapColorPreset(const AValue: TNimbusHeatmapColorPreset);
    procedure SetHeatmapEmptyColor(const AValue: TColor);
    procedure SetHeatmapLowColor(const AValue: TColor);
    procedure SetHeatmapHighColor(const AValue: TColor);
    procedure ChildChanged(Sender: TObject);
    procedure SetReferenceLines(const AValue: TNimbusChartReferenceLineCollection);
    procedure SetReferenceRanges(const AValue: TNimbusChartReferenceRangeCollection);
    procedure SetAnnotations(const AValue: TNimbusChartAnnotationCollection);
    procedure SetPalette(const AValue: TNimbusChartPalette);
    procedure SetSeries(const AValue: TNimbusChartSeriesCollection);
    procedure SetXAxis(const AValue: TNimbusChartAxis);
    procedure SetYAxis(const AValue: TNimbusChartAxis);
    procedure SetSecondaryYAxis(const AValue: TNimbusChartAxis);
    procedure SetLegend(const AValue: TNimbusChartLegend);
    procedure SetOptions(const AValue: TNimbusChartOptions);
    procedure SetViolinOptions(const AValue: TNimbusViolinPlotOptions);
    procedure SetRidgelineOptions(const AValue: TNimbusRidgelineOptions);
    procedure SetStreamGraphOptions(const AValue: TNimbusStreamGraphOptions);
    procedure SetTreemapOptions(const AValue: TNimbusTreemapOptions);
    procedure SetSunburstOptions(const AValue: TNimbusSunburstOptions);
    procedure SetSankey(const AValue: TNimbusSankeyData);
    procedure SetFinancialOptions(const AValue: TNimbusFinancialChartOptions);
    procedure SetFinancialData(const AValue: TNimbusFinancialDataPointCollection);
    procedure SetMarimekkoOptions(const AValue: TNimbusMarimekkoOptions);
    procedure SetEdgeBundling(const AValue: TNimbusHierarchicalEdgeBundlingData);
    procedure SetProgressRingGrid(const AValue: TNimbusProgressRingGridData);
    procedure SetHeatmapColumnLabels(const AValue: TStrings);
    procedure SetHeatmapRowLabels(const AValue: TStrings);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure NotifyChanged;
    function AddSeries(const AName: string): TNimbusChartSeries;
    procedure ClearSeries;
    function GetBoxPlotRange: TNimbusChartRange;
    function GetXRange: TNimbusChartRange;
    function GetYRange(const AAxis: TNimbusChartSeriesYAxis = ncyPrimary): TNimbusChartRange;
  published
    property ChartType: TNimbusChartType read FChartType write SetChartType;
    property Title: string read FTitle write SetTitle;
    property Subtitle: string read FSubtitle write SetSubtitle;
    property KpiTitle: string read FKpiTitle write SetKpiTitle;
    property KpiValueText: string read FKpiValueText write SetKpiValueText;
    property KpiSubtitle: string read FKpiSubtitle write SetKpiSubtitle;
    property KpiChangeText: string read FKpiChangeText write SetKpiChangeText;
    property KpiValue: Double read FKpiValue write SetKpiValue;
    property KpiChangeValue: Double read FKpiChangeValue write SetKpiChangeValue;
    property KpiState: TNimbusKpiState read FKpiState write SetKpiState;
    property GaugeMinimum: Double read FGaugeMinimum write SetGaugeMinimum;
    property GaugeMaximum: Double read FGaugeMaximum write SetGaugeMaximum;
    property GaugeValue: Double read FGaugeValue write SetGaugeValue;
    property GaugeCenterLabel: string read FGaugeCenterLabel write SetGaugeCenterLabel;
    property GaugeShowNeedle: Boolean read FGaugeShowNeedle write SetGaugeShowNeedle;
    property GaugeShowThresholds: Boolean read FGaugeShowThresholds write SetGaugeShowThresholds;
    property GaugeStartAngle: Integer read FGaugeStartAngle write SetGaugeStartAngle;
    property GaugeSweepAngle: Integer read FGaugeSweepAngle write SetGaugeSweepAngle;
    property GaugeValueSuffix: string read FGaugeValueSuffix write SetGaugeValueSuffix;
    property HeatmapColumnCount: Integer read FHeatmapColumnCount write SetHeatmapColumnCount;
    property HeatmapRowCount: Integer read FHeatmapRowCount write SetHeatmapRowCount;
    property HeatmapMinimum: Double read FHeatmapMinimum write SetHeatmapMinimum;
    property HeatmapMaximum: Double read FHeatmapMaximum write SetHeatmapMaximum;
    property HeatmapAutoRange: Boolean read FHeatmapAutoRange write SetHeatmapAutoRange;
    property HeatmapSquareCells: Boolean read FHeatmapSquareCells write SetHeatmapSquareCells;
    property HeatmapShowLegend: Boolean read FHeatmapShowLegend write SetHeatmapShowLegend;
    property HeatmapShowCellLabels: Boolean read FHeatmapShowCellLabels write SetHeatmapShowCellLabels;
    property HeatmapCellGap: Integer read FHeatmapCellGap write SetHeatmapCellGap;
    property HeatmapCellCornerRadius: Integer read FHeatmapCellCornerRadius write SetHeatmapCellCornerRadius;
    property HeatmapColorPreset: TNimbusHeatmapColorPreset read FHeatmapColorPreset write SetHeatmapColorPreset default nhcpTheme;
    property HeatmapEmptyColor: TColor read FHeatmapEmptyColor write SetHeatmapEmptyColor;
    property HeatmapLowColor: TColor read FHeatmapLowColor write SetHeatmapLowColor;
    property HeatmapHighColor: TColor read FHeatmapHighColor write SetHeatmapHighColor;
    property ReferenceLines: TNimbusChartReferenceLineCollection read FReferenceLines write SetReferenceLines;
    property ReferenceRanges: TNimbusChartReferenceRangeCollection read FReferenceRanges write SetReferenceRanges;
    property Annotations: TNimbusChartAnnotationCollection read FAnnotations write SetAnnotations;
    property Palette: TNimbusChartPalette read FPalette write SetPalette;
    property Series: TNimbusChartSeriesCollection read FSeries write SetSeries;
    property XAxis: TNimbusChartAxis read FXAxis write SetXAxis;
    property YAxis: TNimbusChartAxis read FYAxis write SetYAxis;
    property SecondaryYAxis: TNimbusChartAxis read FSecondaryYAxis write SetSecondaryYAxis;
    property Legend: TNimbusChartLegend read FLegend write SetLegend;
    property Options: TNimbusChartOptions read FOptions write SetOptions;
    property ViolinOptions: TNimbusViolinPlotOptions read FViolinOptions write SetViolinOptions;
    property RidgelineOptions: TNimbusRidgelineOptions read FRidgelineOptions write SetRidgelineOptions;
    property StreamGraphOptions: TNimbusStreamGraphOptions read FStreamGraphOptions write SetStreamGraphOptions;
    property TreemapOptions: TNimbusTreemapOptions read FTreemapOptions write SetTreemapOptions;
    property ProgressRingGrid: TNimbusProgressRingGridData read FProgressRingGrid write SetProgressRingGrid;
    property EdgeBundling: TNimbusHierarchicalEdgeBundlingData read FEdgeBundling write SetEdgeBundling;
    property MarimekkoOptions: TNimbusMarimekkoOptions read FMarimekkoOptions write SetMarimekkoOptions;
    property FinancialData: TNimbusFinancialDataPointCollection read FFinancialData write SetFinancialData;
    property FinancialOptions: TNimbusFinancialChartOptions read FFinancialOptions write SetFinancialOptions;
    property Sankey: TNimbusSankeyData read FSankey write SetSankey;
    property SunburstOptions: TNimbusSunburstOptions read FSunburstOptions write SetSunburstOptions;
    property HeatmapColumnLabels: TStrings read FHeatmapColumnLabels write SetHeatmapColumnLabels;
    property HeatmapRowLabels: TStrings read FHeatmapRowLabels write SetHeatmapRowLabels;
  end;

function NimbusChartPercentile(const AValues: TSparklineValues; const ARatio: Double): Double;

implementation

procedure TNimbusChartPersistent.Changed;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

constructor TNimbusChartPoint.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FXValue := 0;
  FYValue := 0;
  FSizeValue := 1;
  FLabel := '';
  FToolTipText := '';
  FColor := clNone;
  FVisible := True;
  FTag := 0;
end;

procedure TNimbusChartPoint.Assign(Source: TPersistent);
var S: TNimbusChartPoint;
begin
  if not (Source is TNimbusChartPoint) then begin inherited; Exit end;
  S := TNimbusChartPoint(Source);
  FXValue := S.FXValue;
  FYValue := S.FYValue;
  FSizeValue := S.FSizeValue;
  FLabel := S.FLabel;
  FToolTipText := S.FToolTipText;
  FColor := S.FColor;
  FVisible := S.FVisible;
  FTag := S.FTag;
  FShowValue := S.FShowValue;
  Changed(False);
end;

procedure TNimbusChartPoint.SetXValue(const AValue: Double);
begin
  if FXValue = AValue then Exit;
  FXValue := AValue; Changed(False);
end;

procedure TNimbusChartPoint.SetYValue(const AValue: Double);
begin
  if FYValue = AValue then Exit;
  FYValue := AValue; Changed(False);
end;

procedure TNimbusChartPoint.SetSizeValue(const AValue: Double);
begin
  if FSizeValue = AValue then Exit;
  FSizeValue := AValue; Changed(False);
end;

procedure TNimbusChartPoint.SetLabel(const AValue: string);
begin
  if FLabel = AValue then Exit;
  FLabel := AValue; Changed(False);
end;

procedure TNimbusChartPoint.SetToolTipText(const AValue: string);
begin
  if FToolTipText = AValue then Exit;
  FToolTipText := AValue; Changed(False);
end;

procedure TNimbusChartPoint.SetColor(const AValue: TColor);
begin
  if FColor = AValue then Exit;
  FColor := AValue; Changed(False);
end;

procedure TNimbusChartPoint.SetVisible(const AValue: Boolean);
begin
  if FVisible = AValue then Exit;
  FVisible := AValue; Changed(False);
end;

procedure TNimbusChartPoint.SetShowValue(const AValue: Boolean);
begin
  if FShowValue = AValue then Exit; FShowValue := AValue; Changed(False);
end;

procedure TNimbusChartPoint.SetTag(const AValue: NativeInt);
begin
  if FTag = AValue then Exit;
  FTag := AValue; Changed(False);
end;

constructor TNimbusChartSeries.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FName := '';
  FRenderKind := nsrkDefault;
  FColor := clNone;
  FVisible := True;
  FShowMarkers := True;
  FShowValues := False;
  FLineWidth := 2;
  FMarkerSize := 6;
  FFillOpacity := 0.22;
  FMarkerShape := ncmsCircle;
  FValueFormat := '';
  FYAxis := ncyPrimary;
  FDownsamplingMode := ncdAutomatic;
  FDownsamplingThreshold := 0;
  FTag := 0;
  FBullet := TNimbusBulletData.Create; FBullet.OnChange := PointsChanged;
  FBoxPlot := TNimbusBoxPlotData.Create; FBoxPlot.OnChange := PointsChanged;
  FPoints := TNimbusChartPointCollection.Create(Self); FPoints.OnChange := PointsChanged;
end;

procedure TNimbusChartSeries.Assign(Source: TPersistent);
var S: TNimbusChartSeries;
begin
  if not (Source is TNimbusChartSeries) then begin inherited; Exit end;
  S := TNimbusChartSeries(Source);
  FName := S.FName;
  FRenderKind := S.FRenderKind;
  FColor := S.FColor;
  FVisible := S.FVisible;
  FShowMarkers := S.FShowMarkers;
  FShowValues := S.FShowValues;
  FLineWidth := S.FLineWidth;
  FMarkerSize := S.FMarkerSize;
  FFillOpacity := S.FFillOpacity;
  FMarkerShape := S.FMarkerShape;
  FValueFormat := S.FValueFormat;
  FYAxis := S.FYAxis;
  FDownsamplingMode := S.FDownsamplingMode;
  FDownsamplingThreshold := S.FDownsamplingThreshold;
  FTag := S.FTag;
  FBullet.Assign(S.FBullet); FBoxPlot.Assign(S.FBoxPlot);
  FPoints.Assign(S.FPoints);
  Changed(False);
end;

procedure TNimbusChartSeries.SetName(const AValue: string);
begin
  if FName = AValue then Exit;
  FName := AValue; Changed(False);
end;

procedure TNimbusChartSeries.SetRenderKind(const AValue: TNimbusSeriesRenderKind);
begin
  if FRenderKind = AValue then Exit;
  FRenderKind := AValue; Changed(False);
end;

procedure TNimbusChartSeries.SetColor(const AValue: TColor);
begin
  if FColor = AValue then Exit;
  FColor := AValue; Changed(False);
end;

procedure TNimbusChartSeries.SetVisible(const AValue: Boolean);
begin
  if FVisible = AValue then Exit;
  FVisible := AValue; Changed(False);
end;

procedure TNimbusChartSeries.SetShowMarkers(const AValue: Boolean);
begin
  if FShowMarkers = AValue then Exit;
  FShowMarkers := AValue; Changed(False);
end;

procedure TNimbusChartSeries.SetShowValues(const AValue: Boolean);
begin
  if FShowValues = AValue then Exit;
  FShowValues := AValue; Changed(False);
end;

procedure TNimbusChartSeries.SetLineWidth(const AValue: Single);
begin
  if not SparklineFinite(AValue) or (AValue <= 0) then Exit;
  if FLineWidth = AValue then Exit;
  FLineWidth := AValue; Changed(False);
end;

procedure TNimbusChartSeries.SetMarkerSize(const AValue: Single);
begin
  if not SparklineFinite(AValue) or (AValue <= 0) then Exit;
  if FMarkerSize = AValue then Exit;
  FMarkerSize := AValue; Changed(False);
end;

procedure TNimbusChartSeries.SetFillOpacity(const AValue: Single);
begin
  if FFillOpacity = EnsureRange(AValue, Single(0), Single(1)) then Exit;
  FFillOpacity := EnsureRange(AValue, Single(0), Single(1)); Changed(False);
end;

procedure TNimbusChartSeries.SetMarkerShape(const AValue: TNimbusChartMarkerShape);
begin
  if FMarkerShape = AValue then Exit;
  FMarkerShape := AValue; Changed(False);
end;

procedure TNimbusChartSeries.SetValueFormat(const AValue: string);
begin
  if FValueFormat = AValue then Exit;
  FValueFormat := AValue; Changed(False);
end;

procedure TNimbusChartSeries.SetYAxis(const AValue: TNimbusChartSeriesYAxis);
begin
  if FYAxis = AValue then Exit;
  FYAxis := AValue; Changed(False);
end;

procedure TNimbusChartSeries.SetDownsamplingMode(const AValue: TNimbusChartDownsamplingMode);
begin
  if FDownsamplingMode = AValue then Exit;
  FDownsamplingMode := AValue; Changed(False);
end;

procedure TNimbusChartSeries.SetDownsamplingThreshold(const AValue: Integer);
begin
  if FDownsamplingThreshold = AValue then Exit;
  FDownsamplingThreshold := AValue; Changed(False);
end;

procedure TNimbusChartSeries.SetTag(const AValue: NativeInt);
begin
  if FTag = AValue then Exit;
  FTag := AValue; Changed(False);
end;

destructor TNimbusChartSeries.Destroy;
begin
  FBullet.Free; FBoxPlot.Free;
  FPoints.Free;
  inherited;
end;

procedure TNimbusChartSeries.PointsChanged(Sender: TObject);
begin
  Changed(False);
end;

procedure TNimbusChartSeries.SetPoints(const AValue: TNimbusChartPointCollection);
begin
  FPoints.Assign(AValue);
end;

constructor TNimbusChartAxis.Create;
begin
  inherited Create;
  FTitle := '';
  FPosition := ncapBottom;
  FVisible := True;
  FShowGridLines := True;
  FShowMinorGridLines := True;
  FShowLabels := True;
  FAutoRange := True;
  FMinimum := 0;
  FMaximum := 100;
  FLabelFormat := '';
  FScale := ncasLinear;
  FMinorTickMode := nclmtAutomatic;
  FLogarithmicLabelMode := ncllmPlainNumber;
  FInvalidLogValueBehavior := ncilSkip;
  FValueType := ncavtNumeric;
  FDateTimeLabelFormat := 'g';
  FTickCount := 5;
  FPowerExponent := 2;
  FSymmetricLogThreshold := 1;
  FLogarithmicBase := 10;
  FAutomaticLogarithmicThreshold := 1000;
end;

procedure TNimbusChartAxis.Assign(Source: TPersistent);
var S: TNimbusChartAxis;
begin
  if not (Source is TNimbusChartAxis) then begin inherited; Exit end;
  S := TNimbusChartAxis(Source);
  FTitle := S.FTitle;
  FPosition := S.FPosition;
  FVisible := S.FVisible;
  FShowGridLines := S.FShowGridLines;
  FShowMinorGridLines := S.FShowMinorGridLines;
  FShowLabels := S.FShowLabels;
  FAutoRange := S.FAutoRange;
  FMinimum := S.FMinimum;
  FMaximum := S.FMaximum;
  FLabelFormat := S.FLabelFormat;
  FScale := S.FScale;
  FMinorTickMode := S.FMinorTickMode;
  FLogarithmicLabelMode := S.FLogarithmicLabelMode;
  FInvalidLogValueBehavior := S.FInvalidLogValueBehavior;
  FValueType := S.FValueType;
  FDateTimeLabelFormat := S.FDateTimeLabelFormat;
  FTickCount := S.FTickCount;
  FPowerExponent := S.FPowerExponent;
  FSymmetricLogThreshold := S.FSymmetricLogThreshold;
  FLogarithmicBase := S.FLogarithmicBase;
  FAutomaticLogarithmicThreshold := S.FAutomaticLogarithmicThreshold;
  Changed;
end;

procedure TNimbusChartAxis.SetTitle(const AValue: string);
begin
  if FTitle = AValue then Exit;
  FTitle := AValue; Changed;
end;

procedure TNimbusChartAxis.SetPosition(const AValue: TNimbusChartAxisPosition);
begin
  if FPosition = AValue then Exit;
  FPosition := AValue; Changed;
end;

procedure TNimbusChartAxis.SetVisible(const AValue: Boolean);
begin
  if FVisible = AValue then Exit;
  FVisible := AValue; Changed;
end;

procedure TNimbusChartAxis.SetShowGridLines(const AValue: Boolean);
begin
  if FShowGridLines = AValue then Exit;
  FShowGridLines := AValue; Changed;
end;

procedure TNimbusChartAxis.SetShowMinorGridLines(const AValue: Boolean);
begin
  if FShowMinorGridLines = AValue then Exit;
  FShowMinorGridLines := AValue; Changed;
end;

procedure TNimbusChartAxis.SetShowLabels(const AValue: Boolean);
begin
  if FShowLabels = AValue then Exit;
  FShowLabels := AValue; Changed;
end;

procedure TNimbusChartAxis.SetAutoRange(const AValue: Boolean);
begin
  if FAutoRange = AValue then Exit;
  FAutoRange := AValue; Changed;
end;

procedure TNimbusChartAxis.SetMinimum(const AValue: Double);
begin
  if FMinimum = AValue then Exit;
  FMinimum := AValue; Changed;
end;

procedure TNimbusChartAxis.SetMaximum(const AValue: Double);
begin
  if FMaximum = AValue then Exit;
  FMaximum := AValue; Changed;
end;

procedure TNimbusChartAxis.SetLabelFormat(const AValue: string);
begin
  if FLabelFormat = AValue then Exit;
  FLabelFormat := AValue; Changed;
end;

procedure TNimbusChartAxis.SetScale(const AValue: TNimbusChartAxisScale);
begin
  if FScale = AValue then Exit;
  FScale := AValue; Changed;
end;

procedure TNimbusChartAxis.SetMinorTickMode(const AValue: TNimbusChartLogarithmicMinorTickMode);
begin
  if FMinorTickMode = AValue then Exit;
  FMinorTickMode := AValue; Changed;
end;

procedure TNimbusChartAxis.SetLogarithmicLabelMode(const AValue: TNimbusChartLogarithmicLabelMode);
begin
  if FLogarithmicLabelMode = AValue then Exit;
  FLogarithmicLabelMode := AValue; Changed;
end;

procedure TNimbusChartAxis.SetInvalidLogValueBehavior(const AValue: TNimbusChartInvalidLogValueBehavior);
begin
  if FInvalidLogValueBehavior = AValue then Exit;
  FInvalidLogValueBehavior := AValue; Changed;
end;

procedure TNimbusChartAxis.SetValueType(const AValue: TNimbusChartAxisValueType);
begin
  if FValueType = AValue then Exit;
  FValueType := AValue; Changed;
end;

procedure TNimbusChartAxis.SetDateTimeLabelFormat(const AValue: string);
begin
  if FDateTimeLabelFormat = AValue then Exit;
  FDateTimeLabelFormat := AValue; Changed;
end;

procedure TNimbusChartAxis.SetTickCount(const AValue: Integer);
begin
  if FTickCount = EnsureRange(AValue, 2, 1000) then Exit;
  FTickCount := EnsureRange(AValue, 2, 1000); Changed;
end;

procedure TNimbusChartAxis.SetPowerExponent(const AValue: Double);
begin
  if not SparklineFinite(AValue) or (AValue <= 0) then Exit;
  if FPowerExponent = AValue then Exit;
  FPowerExponent := AValue; Changed;
end;

procedure TNimbusChartAxis.SetSymmetricLogThreshold(const AValue: Double);
begin
  if not SparklineFinite(AValue) or (AValue <= 0) then Exit;
  if FSymmetricLogThreshold = AValue then Exit;
  FSymmetricLogThreshold := AValue; Changed;
end;

procedure TNimbusChartAxis.SetLogarithmicBase(const AValue: Double);
begin
  if not SparklineFinite(AValue) or (AValue <= 1) then Exit;
  if FLogarithmicBase = AValue then Exit;
  FLogarithmicBase := AValue; Changed;
end;

procedure TNimbusChartAxis.SetAutomaticLogarithmicThreshold(const AValue: Double);
begin
  if not SparklineFinite(AValue) or (AValue <= 0) then Exit;
  if FAutomaticLogarithmicThreshold = Max(10.0, AValue) then Exit;
  FAutomaticLogarithmicThreshold := Max(10.0, AValue); Changed;
end;

constructor TNimbusChartLegend.Create;
begin
  inherited Create;
  FVisible := True;
  FPosition := nclpRight;
  FShowSeriesMarkers := True;
  FMaximumItemWidth := 180;
end;

procedure TNimbusChartLegend.Assign(Source: TPersistent);
var S: TNimbusChartLegend;
begin
  if not (Source is TNimbusChartLegend) then begin inherited; Exit end;
  S := TNimbusChartLegend(Source);
  FVisible := S.FVisible;
  FPosition := S.FPosition;
  FShowSeriesMarkers := S.FShowSeriesMarkers;
  FMaximumItemWidth := S.FMaximumItemWidth;
  Changed;
end;

procedure TNimbusChartLegend.SetVisible(const AValue: Boolean);
begin
  if FVisible = AValue then Exit;
  FVisible := AValue; Changed;
end;

procedure TNimbusChartLegend.SetPosition(const AValue: TNimbusChartLegendPosition);
begin
  if FPosition = AValue then Exit;
  FPosition := AValue; Changed;
end;

procedure TNimbusChartLegend.SetShowSeriesMarkers(const AValue: Boolean);
begin
  if FShowSeriesMarkers = AValue then Exit;
  FShowSeriesMarkers := AValue; Changed;
end;

procedure TNimbusChartLegend.SetMaximumItemWidth(const AValue: Integer);
begin
  if FMaximumItemWidth = AValue then Exit;
  FMaximumItemWidth := AValue; Changed;
end;

constructor TNimbusChartOptions.Create;
begin
  inherited Create;
  FOrientation := ncoVertical;
  FShowTitle := True;
  FShowSubtitle := True;
  FShowBorder := True;
  FShowPlotBorder := False;
  FShowAxes := True;
  FShowGrid := True;
  FShowValues := False;
  FShowToolTips := True;
  FShowAnimation := False;
  FClipToPlotArea := True;
  FInnerRadiusPercent := 58;
  FCornerRadius := 4;
  FPadding := 12;
  FMapColorMode := ncmValueGradient; FMapEmptyColor := clNone;
  FMapRegion := ncmrWorld;
  FCountryMapIsoA3 := 'USA';
  FMapZoom := 1;
  FMapOffsetX := 0;
  FMapOffsetY := 0;
  FEnableMapZoom := True;
  FEnableMapPan := True;
  FCountryMapShowRegions := True;
  FCountryMapShowRegionBorders := True;
  FCountryMapShowRegionLabels := False;
  FCountryMapShowCities := False;
  FCountryMapShowCityLabels := False;
  FCountryMapMaxCities := 80;
  FCountryMapCityMinPopulation := 250000;
end;

procedure TNimbusChartOptions.Assign(Source: TPersistent);
var S: TNimbusChartOptions;
begin
  if not (Source is TNimbusChartOptions) then begin inherited; Exit end;
  S := TNimbusChartOptions(Source);
  FOrientation := S.FOrientation;
  FShowTitle := S.FShowTitle;
  FShowSubtitle := S.FShowSubtitle;
  FShowBorder := S.FShowBorder;
  FShowPlotBorder := S.FShowPlotBorder;
  FShowAxes := S.FShowAxes;
  FShowGrid := S.FShowGrid;
  FShowValues := S.FShowValues;
  FShowToolTips := S.FShowToolTips;
  FShowAnimation := S.FShowAnimation;
  FClipToPlotArea := S.FClipToPlotArea;
  FInnerRadiusPercent := S.FInnerRadiusPercent;
  FCornerRadius := S.FCornerRadius;
  FPadding := S.FPadding;
  FMapColorMode := S.FMapColorMode; FMapEmptyColor := S.FMapEmptyColor;
  FMapRegion := S.FMapRegion;
  FCountryMapIsoA3 := S.FCountryMapIsoA3;
  FMapZoom := S.FMapZoom;
  FMapOffsetX := S.FMapOffsetX;
  FMapOffsetY := S.FMapOffsetY;
  FEnableMapZoom := S.FEnableMapZoom;
  FEnableMapPan := S.FEnableMapPan;
  FCountryMapShowRegions := S.FCountryMapShowRegions;
  FCountryMapShowRegionBorders := S.FCountryMapShowRegionBorders;
  FCountryMapShowRegionLabels := S.FCountryMapShowRegionLabels;
  FCountryMapShowCities := S.FCountryMapShowCities;
  FCountryMapShowCityLabels := S.FCountryMapShowCityLabels;
  FCountryMapMaxCities := S.FCountryMapMaxCities;
  FCountryMapCityMinPopulation := S.FCountryMapCityMinPopulation;
  Changed;
end;

procedure TNimbusChartOptions.SetOrientation(const AValue: TNimbusChartOrientation);
begin
  if FOrientation = AValue then Exit;
  FOrientation := AValue; Changed;
end;

procedure TNimbusChartOptions.SetShowTitle(const AValue: Boolean);
begin
  if FShowTitle = AValue then Exit;
  FShowTitle := AValue; Changed;
end;

procedure TNimbusChartOptions.SetShowSubtitle(const AValue: Boolean);
begin
  if FShowSubtitle = AValue then Exit;
  FShowSubtitle := AValue; Changed;
end;

procedure TNimbusChartOptions.SetShowBorder(const AValue: Boolean);
begin
  if FShowBorder = AValue then Exit;
  FShowBorder := AValue; Changed;
end;

procedure TNimbusChartOptions.SetShowPlotBorder(const AValue: Boolean);
begin
  if FShowPlotBorder = AValue then Exit;
  FShowPlotBorder := AValue; Changed;
end;

procedure TNimbusChartOptions.SetShowAxes(const AValue: Boolean);
begin
  if FShowAxes = AValue then Exit;
  FShowAxes := AValue; Changed;
end;

procedure TNimbusChartOptions.SetShowGrid(const AValue: Boolean);
begin
  if FShowGrid = AValue then Exit;
  FShowGrid := AValue; Changed;
end;

procedure TNimbusChartOptions.SetShowValues(const AValue: Boolean);
begin
  if FShowValues = AValue then Exit;
  FShowValues := AValue; Changed;
end;

procedure TNimbusChartOptions.SetShowToolTips(const AValue: Boolean);
begin
  if FShowToolTips = AValue then Exit;
  FShowToolTips := AValue; Changed;
end;

procedure TNimbusChartOptions.SetShowAnimation(const AValue: Boolean);
begin
  if FShowAnimation = AValue then Exit;
  FShowAnimation := AValue; Changed;
end;

procedure TNimbusChartOptions.SetClipToPlotArea(const AValue: Boolean);
begin
  if FClipToPlotArea = AValue then Exit;
  FClipToPlotArea := AValue; Changed;
end;

procedure TNimbusChartOptions.SetInnerRadiusPercent(const AValue: Integer);
begin
  if FInnerRadiusPercent = EnsureRange(AValue, 0, 95) then Exit;
  FInnerRadiusPercent := EnsureRange(AValue, 0, 95); Changed;
end;

procedure TNimbusChartOptions.SetCornerRadius(const AValue: Integer);
begin
  if FCornerRadius = Max(0, AValue) then Exit;
  FCornerRadius := Max(0, AValue); Changed;
end;

procedure TNimbusChartOptions.SetPadding(const AValue: Integer);
begin
  if FPadding = Max(0, AValue) then Exit;
  FPadding := Max(0, AValue); Changed;
end;

procedure TNimbusChartOptions.SetMapRegion(const AValue: TNimbusChartMapRegion);
begin
  if FMapRegion = AValue then Exit;
  FMapRegion := AValue; Changed;
end;

procedure TNimbusChartOptions.SetCountryMapIsoA3(const AValue: string);
begin
  if FCountryMapIsoA3 = AValue then Exit;
  FCountryMapIsoA3 := AValue; Changed;
end;

procedure TNimbusChartOptions.SetMapZoom(const AValue: Single);
begin
  if FMapZoom = AValue then Exit;
  FMapZoom := AValue; Changed;
end;

procedure TNimbusChartOptions.SetMapOffsetX(const AValue: Single);
begin
  if FMapOffsetX = AValue then Exit;
  FMapOffsetX := AValue; Changed;
end;

procedure TNimbusChartOptions.SetMapOffsetY(const AValue: Single);
begin
  if FMapOffsetY = AValue then Exit;
  FMapOffsetY := AValue; Changed;
end;

procedure TNimbusChartOptions.SetEnableMapZoom(const AValue: Boolean);
begin
  if FEnableMapZoom = AValue then Exit;
  FEnableMapZoom := AValue; Changed;
end;

procedure TNimbusChartOptions.SetEnableMapPan(const AValue: Boolean);
begin
  if FEnableMapPan = AValue then Exit;
  FEnableMapPan := AValue; Changed;
end;

procedure TNimbusChartOptions.SetCountryMapShowRegions(const AValue: Boolean);
begin
  if FCountryMapShowRegions = AValue then Exit;
  FCountryMapShowRegions := AValue; Changed;
end;

procedure TNimbusChartOptions.SetCountryMapShowRegionBorders(const AValue: Boolean);
begin
  if FCountryMapShowRegionBorders = AValue then Exit;
  FCountryMapShowRegionBorders := AValue; Changed;
end;

procedure TNimbusChartOptions.SetCountryMapShowRegionLabels(const AValue: Boolean);
begin
  if FCountryMapShowRegionLabels = AValue then Exit;
  FCountryMapShowRegionLabels := AValue; Changed;
end;

procedure TNimbusChartOptions.SetCountryMapShowCities(const AValue: Boolean);
begin
  if FCountryMapShowCities = AValue then Exit;
  FCountryMapShowCities := AValue; Changed;
end;

procedure TNimbusChartOptions.SetCountryMapShowCityLabels(const AValue: Boolean);
begin
  if FCountryMapShowCityLabels = AValue then Exit;
  FCountryMapShowCityLabels := AValue; Changed;
end;

procedure TNimbusChartOptions.SetCountryMapMaxCities(const AValue: Integer);
begin
  if FCountryMapMaxCities = AValue then Exit;
  FCountryMapMaxCities := AValue; Changed;
end;

procedure TNimbusChartOptions.SetCountryMapCityMinPopulation(const AValue: Integer);
begin
  if FCountryMapCityMinPopulation = AValue then Exit;
  FCountryMapCityMinPopulation := AValue; Changed;
end;

constructor TNimbusChartModel.Create;
begin
  inherited Create;
  FChartType := nctLine;
  FTitle := '';
  FSubtitle := '';
  FKpiTitle := '';
  FKpiValueText := '';
  FKpiSubtitle := '';
  FKpiChangeText := '';
  FKpiValue := 0;
  FKpiChangeValue := 0;
  FKpiState := nksNeutral;
  FGaugeMinimum := 0;
  FGaugeMaximum := 100;
  FGaugeValue := 0;
  FGaugeCenterLabel := '';
  FGaugeShowNeedle := True;
  FGaugeShowThresholds := True;
  FGaugeStartAngle := 135;
  FGaugeSweepAngle := 270;
  FGaugeValueSuffix := '';
  FHeatmapColumnCount := 0;
  FHeatmapRowCount := 0;
  FHeatmapMinimum := 0;
  FHeatmapMaximum := 0;
  FHeatmapAutoRange := True;
  FHeatmapSquareCells := True;
  FHeatmapShowLegend := True;
  FHeatmapShowCellLabels := False;
  FHeatmapCellGap := 3;
  FHeatmapCellCornerRadius := 3;
  FHeatmapColorPreset := nhcpTheme;
  FHeatmapEmptyColor := clNone;
  FHeatmapLowColor := clNone;
  FHeatmapHighColor := clNone;
  FReferenceLines := TNimbusChartReferenceLineCollection.Create(Self); FReferenceLines.OnChange := ChildChanged;
  FReferenceRanges := TNimbusChartReferenceRangeCollection.Create(Self); FReferenceRanges.OnChange := ChildChanged;
  FAnnotations := TNimbusChartAnnotationCollection.Create(Self); FAnnotations.OnChange := ChildChanged;
  FPalette := TNimbusChartPalette.Create; FPalette.OnChange := ChildChanged;
  FSeries := TNimbusChartSeriesCollection.Create(Self);
  FSeries.OnChange := ChildChanged;
  FXAxis := TNimbusChartAxis.Create;
  FXAxis.OnChange := ChildChanged;
  FYAxis := TNimbusChartAxis.Create;
  FYAxis.OnChange := ChildChanged;
  FSecondaryYAxis := TNimbusChartAxis.Create;
  FSecondaryYAxis.OnChange := ChildChanged;
  FLegend := TNimbusChartLegend.Create;
  FLegend.OnChange := ChildChanged;
  FOptions := TNimbusChartOptions.Create;
  FOptions.OnChange := ChildChanged;
  FViolinOptions := TNimbusViolinPlotOptions.Create; FViolinOptions.OnChange := ChildChanged;
  FRidgelineOptions := TNimbusRidgelineOptions.Create; FRidgelineOptions.OnChange := ChildChanged;
  FStreamGraphOptions := TNimbusStreamGraphOptions.Create; FStreamGraphOptions.OnChange := ChildChanged;
  FTreemapOptions := TNimbusTreemapOptions.Create; FTreemapOptions.OnChange := ChildChanged;
  FProgressRingGrid := TNimbusProgressRingGridData.Create; FProgressRingGrid.OnChange := ChildChanged;
  FEdgeBundling := TNimbusHierarchicalEdgeBundlingData.Create; FEdgeBundling.OnChange := ChildChanged;
  FMarimekkoOptions := TNimbusMarimekkoOptions.Create; FMarimekkoOptions.OnChange := ChildChanged;
  FFinancialData := TNimbusFinancialDataPointCollection.Create(Self); FFinancialData.OnChange := ChildChanged;
  FFinancialOptions := TNimbusFinancialChartOptions.Create; FFinancialOptions.OnChange := ChildChanged;
  FSankey := TNimbusSankeyData.Create; FSankey.OnChange := ChildChanged;
  FSunburstOptions := TNimbusSunburstOptions.Create; FSunburstOptions.OnChange := ChildChanged;
  FHeatmapColumnLabels := TStringList.Create;
  TStringList(FHeatmapColumnLabels).OnChange := ChildChanged;
  FHeatmapRowLabels := TStringList.Create;
  TStringList(FHeatmapRowLabels).OnChange := ChildChanged;
  FYAxis.Position := ncapLeft; FSecondaryYAxis.Position := ncapRight; FSecondaryYAxis.Visible := False;
end;

procedure TNimbusChartModel.Assign(Source: TPersistent);
var S: TNimbusChartModel;
begin
  if not (Source is TNimbusChartModel) then begin inherited; Exit end;
  S := TNimbusChartModel(Source);
  FChartType := S.FChartType;
  FTitle := S.FTitle;
  FSubtitle := S.FSubtitle;
  FKpiTitle := S.FKpiTitle;
  FKpiValueText := S.FKpiValueText;
  FKpiSubtitle := S.FKpiSubtitle;
  FKpiChangeText := S.FKpiChangeText;
  FKpiValue := S.FKpiValue;
  FKpiChangeValue := S.FKpiChangeValue;
  FKpiState := S.FKpiState;
  FGaugeMinimum := S.FGaugeMinimum;
  FGaugeMaximum := S.FGaugeMaximum;
  FGaugeValue := S.FGaugeValue;
  FGaugeCenterLabel := S.FGaugeCenterLabel;
  FGaugeShowNeedle := S.FGaugeShowNeedle;
  FGaugeShowThresholds := S.FGaugeShowThresholds;
  FGaugeStartAngle := S.FGaugeStartAngle;
  FGaugeSweepAngle := S.FGaugeSweepAngle;
  FGaugeValueSuffix := S.FGaugeValueSuffix;
  FHeatmapColumnCount := S.FHeatmapColumnCount;
  FHeatmapRowCount := S.FHeatmapRowCount;
  FHeatmapMinimum := S.FHeatmapMinimum;
  FHeatmapMaximum := S.FHeatmapMaximum;
  FHeatmapAutoRange := S.FHeatmapAutoRange;
  FHeatmapSquareCells := S.FHeatmapSquareCells;
  FHeatmapShowLegend := S.FHeatmapShowLegend;
  FHeatmapShowCellLabels := S.FHeatmapShowCellLabels;
  FHeatmapCellGap := S.FHeatmapCellGap;
  FHeatmapCellCornerRadius := S.FHeatmapCellCornerRadius;
  FHeatmapColorPreset := S.FHeatmapColorPreset;
  FHeatmapEmptyColor := S.FHeatmapEmptyColor;
  FHeatmapLowColor := S.FHeatmapLowColor;
  FHeatmapHighColor := S.FHeatmapHighColor;
  FReferenceLines.Assign(S.FReferenceLines);
  FReferenceRanges.Assign(S.FReferenceRanges);
  FAnnotations.Assign(S.FAnnotations);
  FPalette.Assign(S.FPalette);
  FSeries.Assign(S.FSeries);
  FXAxis.Assign(S.FXAxis);
  FYAxis.Assign(S.FYAxis);
  FSecondaryYAxis.Assign(S.FSecondaryYAxis);
  FLegend.Assign(S.FLegend);
  FOptions.Assign(S.FOptions);
  FViolinOptions.Assign(S.FViolinOptions);
  FRidgelineOptions.Assign(S.FRidgelineOptions);
  FStreamGraphOptions.Assign(S.FStreamGraphOptions);
  FTreemapOptions.Assign(S.FTreemapOptions);
  FProgressRingGrid.Assign(S.FProgressRingGrid);
  FEdgeBundling.Assign(S.FEdgeBundling);
  FMarimekkoOptions.Assign(S.FMarimekkoOptions);
  FFinancialData.Assign(S.FFinancialData);
  FFinancialOptions.Assign(S.FFinancialOptions);
  FSankey.Assign(S.FSankey);
  FSunburstOptions.Assign(S.FSunburstOptions);
  FHeatmapColumnLabels.Assign(S.FHeatmapColumnLabels);
  FHeatmapRowLabels.Assign(S.FHeatmapRowLabels);
  NotifyChanged;
end;

procedure TNimbusChartModel.SetChartType(const AValue: TNimbusChartType);
begin
  if FChartType = AValue then Exit;
  FChartType := AValue; NotifyChanged;
end;

procedure TNimbusChartModel.SetTitle(const AValue: string);
begin
  if FTitle = AValue then Exit;
  FTitle := AValue; NotifyChanged;
end;

procedure TNimbusChartModel.SetSubtitle(const AValue: string);
begin
  if FSubtitle = AValue then Exit;
  FSubtitle := AValue; NotifyChanged;
end;

procedure TNimbusChartModel.SetKpiTitle(const AValue: string);
begin
  if FKpiTitle = AValue then Exit;
  FKpiTitle := AValue; NotifyChanged;
end;

procedure TNimbusChartModel.SetKpiValueText(const AValue: string);
begin
  if FKpiValueText = AValue then Exit;
  FKpiValueText := AValue; NotifyChanged;
end;

procedure TNimbusChartModel.SetKpiSubtitle(const AValue: string);
begin
  if FKpiSubtitle = AValue then Exit;
  FKpiSubtitle := AValue; NotifyChanged;
end;

procedure TNimbusChartModel.SetKpiChangeText(const AValue: string);
begin
  if FKpiChangeText = AValue then Exit;
  FKpiChangeText := AValue; NotifyChanged;
end;

procedure TNimbusChartModel.SetKpiValue(const AValue: Double);
begin
  if FKpiValue = AValue then Exit;
  FKpiValue := AValue; NotifyChanged;
end;

procedure TNimbusChartModel.SetKpiChangeValue(const AValue: Double);
begin
  if FKpiChangeValue = AValue then Exit;
  FKpiChangeValue := AValue; NotifyChanged;
end;

procedure TNimbusChartModel.SetKpiState(const AValue: TNimbusKpiState);
begin
  if FKpiState = AValue then Exit;
  FKpiState := AValue; NotifyChanged;
end;

procedure TNimbusChartModel.SetGaugeMinimum(const AValue: Double);
begin
  if FGaugeMinimum = AValue then Exit;
  FGaugeMinimum := AValue; NotifyChanged;
end;

procedure TNimbusChartModel.SetGaugeMaximum(const AValue: Double);
begin
  if FGaugeMaximum = AValue then Exit;
  FGaugeMaximum := AValue; NotifyChanged;
end;

procedure TNimbusChartModel.SetGaugeValue(const AValue: Double);
begin
  if FGaugeValue = AValue then Exit;
  FGaugeValue := AValue; NotifyChanged;
end;

procedure TNimbusChartModel.SetGaugeCenterLabel(const AValue: string);
begin
  if FGaugeCenterLabel = AValue then Exit;
  FGaugeCenterLabel := AValue; NotifyChanged;
end;

procedure TNimbusChartModel.SetGaugeShowNeedle(const AValue: Boolean);
begin
  if FGaugeShowNeedle = AValue then Exit;
  FGaugeShowNeedle := AValue; NotifyChanged;
end;

procedure TNimbusChartModel.SetGaugeShowThresholds(const AValue: Boolean);
begin
  if FGaugeShowThresholds = AValue then Exit;
  FGaugeShowThresholds := AValue; NotifyChanged;
end;

procedure TNimbusChartModel.SetGaugeStartAngle(const AValue: Integer);
begin
  if FGaugeStartAngle = AValue then Exit;
  FGaugeStartAngle := AValue; NotifyChanged;
end;

procedure TNimbusChartModel.SetGaugeSweepAngle(const AValue: Integer);
begin
  if FGaugeSweepAngle = AValue then Exit;
  FGaugeSweepAngle := AValue; NotifyChanged;
end;

procedure TNimbusChartModel.SetGaugeValueSuffix(const AValue: string);
begin
  if FGaugeValueSuffix = AValue then Exit;
  FGaugeValueSuffix := AValue; NotifyChanged;
end;

procedure TNimbusChartModel.SetHeatmapColumnCount(const AValue: Integer);
begin
  if FHeatmapColumnCount = AValue then Exit;
  FHeatmapColumnCount := AValue; NotifyChanged;
end;

procedure TNimbusChartModel.SetHeatmapRowCount(const AValue: Integer);
begin
  if FHeatmapRowCount = AValue then Exit;
  FHeatmapRowCount := AValue; NotifyChanged;
end;

procedure TNimbusChartModel.SetHeatmapMinimum(const AValue: Double);
begin
  if FHeatmapMinimum = AValue then Exit;
  FHeatmapMinimum := AValue; NotifyChanged;
end;

procedure TNimbusChartModel.SetHeatmapMaximum(const AValue: Double);
begin
  if FHeatmapMaximum = AValue then Exit;
  FHeatmapMaximum := AValue; NotifyChanged;
end;

procedure TNimbusChartModel.SetHeatmapAutoRange(const AValue: Boolean);
begin
  if FHeatmapAutoRange = AValue then Exit;
  FHeatmapAutoRange := AValue; NotifyChanged;
end;

procedure TNimbusChartModel.SetHeatmapSquareCells(const AValue: Boolean);
begin
  if FHeatmapSquareCells = AValue then Exit;
  FHeatmapSquareCells := AValue; NotifyChanged;
end;

procedure TNimbusChartModel.SetHeatmapShowLegend(const AValue: Boolean);
begin
  if FHeatmapShowLegend = AValue then Exit;
  FHeatmapShowLegend := AValue; NotifyChanged;
end;

procedure TNimbusChartModel.SetHeatmapShowCellLabels(const AValue: Boolean);
begin
  if FHeatmapShowCellLabels = AValue then Exit;
  FHeatmapShowCellLabels := AValue; NotifyChanged;
end;

procedure TNimbusChartModel.SetHeatmapCellGap(const AValue: Integer);
begin
  if FHeatmapCellGap = AValue then Exit;
  FHeatmapCellGap := AValue; NotifyChanged;
end;

procedure TNimbusChartModel.SetHeatmapCellCornerRadius(const AValue: Integer);
begin
  if FHeatmapCellCornerRadius = AValue then Exit;
  FHeatmapCellCornerRadius := AValue; NotifyChanged;
end;

procedure TNimbusChartModel.SetHeatmapEmptyColor(const AValue: TColor);
begin
  if FHeatmapEmptyColor = AValue then Exit;
  FHeatmapEmptyColor := AValue; NotifyChanged;
end;

procedure TNimbusChartModel.SetHeatmapLowColor(const AValue: TColor);
begin
  if FHeatmapLowColor = AValue then Exit;
  FHeatmapLowColor := AValue; NotifyChanged;
end;

procedure TNimbusChartModel.SetHeatmapHighColor(const AValue: TColor);
begin
  if FHeatmapHighColor = AValue then Exit;
  FHeatmapHighColor := AValue; NotifyChanged;
end;

destructor TNimbusChartModel.Destroy;
begin
  FPalette.Free;
  FAnnotations.Free;
  FReferenceRanges.Free;
  FReferenceLines.Free;
  FSeries.Free;
  FXAxis.Free;
  FYAxis.Free;
  FSecondaryYAxis.Free;
  FLegend.Free;
  FOptions.Free;
  FViolinOptions.Free;
  FRidgelineOptions.Free;
  FStreamGraphOptions.Free;
  FTreemapOptions.Free;
  FProgressRingGrid.Free;
  FEdgeBundling.Free;
  FMarimekkoOptions.Free;
  FFinancialData.Free;
  FFinancialOptions.Free;
  FSankey.Free;
  FSunburstOptions.Free;
  FHeatmapColumnLabels.Free;
  FHeatmapRowLabels.Free;
  inherited;
end;

procedure TNimbusChartModel.SetSeries(const AValue: TNimbusChartSeriesCollection);
begin
  if AValue <> nil then FSeries.Assign(AValue);
end;

procedure TNimbusChartModel.SetXAxis(const AValue: TNimbusChartAxis);
begin
  if AValue <> nil then FXAxis.Assign(AValue);
end;

procedure TNimbusChartModel.SetYAxis(const AValue: TNimbusChartAxis);
begin
  if AValue <> nil then FYAxis.Assign(AValue);
end;

procedure TNimbusChartModel.SetSecondaryYAxis(const AValue: TNimbusChartAxis);
begin
  if AValue <> nil then FSecondaryYAxis.Assign(AValue);
end;

procedure TNimbusChartModel.SetLegend(const AValue: TNimbusChartLegend);
begin
  if AValue <> nil then FLegend.Assign(AValue);
end;

procedure TNimbusChartModel.SetProgressRingGrid(const AValue: TNimbusProgressRingGridData);
begin if AValue <> nil then FProgressRingGrid.Assign(AValue) end;

procedure TNimbusChartModel.SetEdgeBundling(const AValue: TNimbusHierarchicalEdgeBundlingData);
begin if AValue <> nil then FEdgeBundling.Assign(AValue) end;

procedure TNimbusChartModel.SetMarimekkoOptions(const AValue: TNimbusMarimekkoOptions);
begin if AValue <> nil then FMarimekkoOptions.Assign(AValue) end;

procedure TNimbusChartModel.SetFinancialData(const AValue: TNimbusFinancialDataPointCollection);
begin if AValue <> nil then FFinancialData.Assign(AValue) end;

procedure TNimbusChartModel.SetFinancialOptions(const AValue: TNimbusFinancialChartOptions);
begin if AValue <> nil then FFinancialOptions.Assign(AValue) end;

procedure TNimbusChartModel.SetSankey(const AValue: TNimbusSankeyData);
begin if AValue <> nil then FSankey.Assign(AValue) end;

procedure TNimbusChartModel.SetSunburstOptions(const AValue: TNimbusSunburstOptions);
begin if AValue <> nil then FSunburstOptions.Assign(AValue) end;

procedure TNimbusChartModel.SetTreemapOptions(const AValue: TNimbusTreemapOptions);
begin if AValue <> nil then FTreemapOptions.Assign(AValue) end;

procedure TNimbusChartModel.SetStreamGraphOptions(const AValue: TNimbusStreamGraphOptions);
begin if AValue <> nil then FStreamGraphOptions.Assign(AValue) end;

procedure TNimbusChartModel.SetRidgelineOptions(const AValue: TNimbusRidgelineOptions);
begin if AValue <> nil then FRidgelineOptions.Assign(AValue) end;

procedure TNimbusChartModel.SetViolinOptions(const AValue: TNimbusViolinPlotOptions);
begin if AValue <> nil then FViolinOptions.Assign(AValue) end;

procedure TNimbusChartModel.SetOptions(const AValue: TNimbusChartOptions);
begin
  if AValue <> nil then FOptions.Assign(AValue);
end;

procedure TNimbusChartModel.SetHeatmapColumnLabels(const AValue: TStrings);
begin
  if AValue <> nil then FHeatmapColumnLabels.Assign(AValue);
end;

procedure TNimbusChartModel.SetHeatmapRowLabels(const AValue: TStrings);
begin
  if AValue <> nil then FHeatmapRowLabels.Assign(AValue);
end;

procedure TNimbusChartModel.BeginUpdate;
begin
  Inc(FUpdateLevel);
end;

procedure TNimbusChartModel.EndUpdate;
begin
  if FUpdateLevel > 0 then Dec(FUpdateLevel);
  if (FUpdateLevel = 0) and FChangedWhileUpdating then begin FChangedWhileUpdating := False; Changed end;
end;

procedure TNimbusChartModel.NotifyChanged;
begin
  if FUpdateLevel > 0 then FChangedWhileUpdating := True else Changed;
end;

procedure TNimbusChartModel.ChildChanged(Sender: TObject);
begin
  NotifyChanged;
end;

function TNimbusChartModel.AddSeries(const AName: string): TNimbusChartSeries;
begin
  BeginUpdate;
  try Result := FSeries.Add; Result.Name := AName finally EndUpdate end;
end;

procedure TNimbusChartModel.ClearSeries;
begin
  FSeries.Clear;
end;

constructor TNimbusChartPointCollection.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TNimbusChartPoint);
end;

function TNimbusChartPointCollection.Add: TNimbusChartPoint;
begin
  Result := TNimbusChartPoint(inherited Add);
end;

function TNimbusChartPointCollection.GetItem(Index: Integer): TNimbusChartPoint;
begin
  Result := TNimbusChartPoint(inherited Items[Index]);
end;

procedure TNimbusChartPointCollection.Update(Item: TCollectionItem);
begin
  inherited;
  if Assigned(FOnChange) then FOnChange(Self);
end;

constructor TNimbusChartSeriesCollection.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TNimbusChartSeries);
end;

function TNimbusChartSeriesCollection.Add: TNimbusChartSeries;
begin
  Result := TNimbusChartSeries(inherited Add);
end;

function TNimbusChartSeriesCollection.GetItem(Index: Integer): TNimbusChartSeries;
begin
  Result := TNimbusChartSeries(inherited Items[Index]);
end;

procedure TNimbusChartSeriesCollection.Update(Item: TCollectionItem);
begin
  inherited;
  if Assigned(FOnChange) then FOnChange(Self);
end;

function TNimbusChartPointCollection.Add(const AX, AY: Double; const ALabel: string): TNimbusChartPoint;
begin
  BeginUpdate;
  try Result := Add; Result.XValue := AX; Result.YValue := AY; Result.&Label := ALabel finally EndUpdate end;
end;

function TNimbusChartSeries.GetXRange: TNimbusChartRange;
var I: Integer; L, H, V: Double;
begin
  L := MaxDouble; H := -MaxDouble;
  for I := 0 to FPoints.Count - 1 do
    if FPoints[I].Visible and SparklineFinite(FPoints[I].XValue) then
    begin V := FPoints[I].XValue; L := Min(L, V); H := Max(H, V) end;
  if L = MaxDouble then Result := TNimbusChartRange.Empty else Result := TNimbusChartRange.Create(L, H);
end;

function TNimbusChartSeries.GetYRange: TNimbusChartRange;
var I: Integer; L, H, V: Double;
begin
  L := MaxDouble; H := -MaxDouble;
  for I := 0 to FPoints.Count - 1 do
    if FPoints[I].Visible and SparklineFinite(FPoints[I].YValue) then
    begin V := FPoints[I].YValue; L := Min(L, V); H := Max(H, V) end;
  if L = MaxDouble then Result := TNimbusChartRange.Empty else Result := TNimbusChartRange.Create(L, H);
end;

function TNimbusChartModel.GetXRange: TNimbusChartRange;
var I: Integer; R: TNimbusChartRange;
begin
  Result := TNimbusChartRange.Empty;
  for I := 0 to FSeries.Count - 1 do if FSeries[I].Visible then
  begin
    R := FSeries[I].GetXRange; if not R.IsValid then Continue;
    if not Result.IsValid then Result := R
    else Result := TNimbusChartRange.Create(Min(Result.Minimum, R.Minimum), Max(Result.Maximum, R.Maximum));
  end;
end;

function TNimbusChartModel.GetYRange(const AAxis: TNimbusChartSeriesYAxis): TNimbusChartRange;
var I: Integer; R: TNimbusChartRange;
begin
  Result := TNimbusChartRange.Empty;
  for I := 0 to FSeries.Count - 1 do if FSeries[I].Visible and (FSeries[I].YAxis = AAxis) then
  begin
    R := FSeries[I].GetYRange; if not R.IsValid then Continue;
    if not Result.IsValid then Result := R
    else Result := TNimbusChartRange.Create(Min(Result.Minimum, R.Minimum), Max(Result.Maximum, R.Maximum));
  end;
end;

function TNimbusChartSeries.GetRenderPointIndices(const APixelWidth: Integer): TArray<Integer>;
var I, N, Limit, Buckets, B, First, Last, MinI, MaxI, Selected, A, EndI, J, K: Integer;
  AverageX, AverageY, Area, BestArea, Size: Double;
  Valid: TArray<Integer>;
  procedure Add(const Index: Integer);
  var Count: Integer;
  begin
    Count := Length(Result); SetLength(Result, Count + 1); Result[Count] := Valid[Index];
  end;
begin
  Result := nil; N := 0; SetLength(Valid, FPoints.Count);
  for I := 0 to FPoints.Count - 1 do
    if FPoints[I].Visible and SparklineFinite(FPoints[I].XValue) and SparklineFinite(FPoints[I].YValue) then
    begin Valid[N] := I; Inc(N) end;
  SetLength(Valid, N);
  Limit := FDownsamplingThreshold;
  if Limit = 0 then Limit := Max(32, APixelWidth * 2);
  if (FDownsamplingMode = ncdNone) or (N <= Limit) or (Limit < 3) then
  begin SetLength(Result, FPoints.Count); for I := 0 to FPoints.Count - 1 do Result[I] := I; Exit end;
  if FDownsamplingMode <> ncdLargestTriangleThreeBuckets then
  begin
    Buckets := Max(1, Limit div 2);
    for B := 0 to Buckets - 1 do
    begin
      First := Int64(B) * N div Buckets; Last := Min(N - 1, Int64(B + 1) * N div Buckets - 1);
      MinI := First; MaxI := First;
      for I := First + 1 to Last do
      begin
        if FPoints[Valid[I]].YValue < FPoints[Valid[MinI]].YValue then MinI := I;
        if FPoints[Valid[I]].YValue > FPoints[Valid[MaxI]].YValue then MaxI := I;
      end;
      if MinI < MaxI then begin Add(MinI); Add(MaxI) end
      else begin Add(MaxI); if MinI <> MaxI then Add(MinI) end;
    end;
    Exit;
  end;
  Size := (N - 2) / (Limit - 2); A := 0; Add(0);
  for B := 0 to Limit - 3 do
  begin
    First := Min(N - 1, Floor((B + 1) * Size) + 1); Last := Min(N, Floor((B + 2) * Size) + 1);
    AverageX := 0; AverageY := 0; K := Max(1, Last - First);
    for I := First to Last - 1 do begin AverageX := AverageX + FPoints[Valid[I]].XValue; AverageY := AverageY + FPoints[Valid[I]].YValue end;
    AverageX := AverageX / K; AverageY := AverageY / K;
    J := Min(N - 1, Floor(B * Size) + 1); EndI := Min(N - 1, Floor((B + 1) * Size) + 1);
    BestArea := -1; Selected := J;
    for I := J to EndI - 1 do
    begin
      Area := Abs((FPoints[Valid[A]].XValue - AverageX) * (FPoints[Valid[I]].YValue - FPoints[Valid[A]].YValue) -
        (FPoints[Valid[A]].XValue - FPoints[Valid[I]].XValue) * (AverageY - FPoints[Valid[A]].YValue));
      if Area > BestArea then begin BestArea := Area; Selected := I end;
    end;
    Add(Selected); A := Selected;
  end;
  Add(N - 1);
end;

function IsStrictLog(const AScale: TNimbusChartAxisScale): Boolean;
begin
  Result := AScale in [ncasLogarithmic10, ncasLogarithmic2, ncasNaturalLogarithmic, ncasCustomLogarithmic];
end;

function TNimbusChartAxis.LogBase(const AScale: TNimbusChartAxisScale): Double;
begin
  case AScale of
    ncasLogarithmic2: Result := 2;
    ncasNaturalLogarithmic: Result := Exp(1);
    ncasCustomLogarithmic: Result := FLogarithmicBase;
    else Result := 10;
  end;
end;

function TNimbusChartAxis.GetEffectiveScale(const ARange: TNimbusChartRange): TNimbusChartAxisScale;
begin
  Result := FScale;
  if Result <> ncasAutomatic then Exit;
  Result := ncasLinear;
  if ARange.IsValid and (ARange.Minimum > 0) and (ARange.Maximum / ARange.Minimum >= FAutomaticLogarithmicThreshold) then Result := ncasLogarithmic10;
end;

function TNimbusChartAxis.Transform(const AValue: Double; const AScale: TNimbusChartAxisScale): Double;
begin
  if IsStrictLog(AScale) then Exit(Ln(AValue) / Ln(LogBase(AScale)));
  case AScale of
    ncasSquareRoot: Result := Sqrt(Max(0.0, AValue));
    ncasPower: Result := Sign(AValue) * Power(Abs(AValue), FPowerExponent);
    ncasSymmetricLogarithmic: Result := Sign(AValue) * Ln(1 + Abs(AValue) / FSymmetricLogThreshold);
    else Result := AValue;
  end;
end;

function TNimbusChartAxis.InverseTransform(const AValue: Double; const AScale: TNimbusChartAxisScale): Double;
begin
  if IsStrictLog(AScale) then Exit(Power(LogBase(AScale), AValue));
  case AScale of
    ncasSquareRoot: Result := Sqr(AValue);
    ncasPower: Result := Sign(AValue) * Power(Abs(AValue), 1 / FPowerExponent);
    ncasSymmetricLogarithmic: Result := Sign(AValue) * FSymmetricLogThreshold * (Exp(Abs(AValue)) - 1);
    else Result := AValue;
  end;
end;

function TNimbusChartAxis.GetEffectiveRange(const ADataRange: TNimbusChartRange): TNimbusChartRange;
var S: TNimbusChartAxisScale; L, H, B, P: Double;
begin
  if FAutoRange then Result := ADataRange else Result := TNimbusChartRange.Create(FMinimum, FMaximum);
  if not Result.IsValid then Result := TNimbusChartRange.Create(0, 1);
  S := GetEffectiveScale(Result); L := Result.Minimum; H := Result.Maximum;
  if IsStrictLog(S) then
  begin
    B := LogBase(S);
    if H <= 0 then Exit(TNimbusChartRange.Create(1, B));
    if L <= 0 then L := Max(H / Power(B, 3), 1E-300);
    if FAutoRange then begin L := Power(B, Floor(Ln(L) / Ln(B))); H := Power(B, Ceil(Ln(H) / Ln(B))) end;
    if Transform(L, S) = Transform(H, S) then Exit(TNimbusChartRange.Create(L / B, H * B));
  end
  else
  begin
    if S = ncasSquareRoot then begin L := Max(0.0, L); H := Max(L, H) end;
    if Transform(L, S) = Transform(H, S) then begin P := Max(1.0, Abs(L) * 0.1); L := L - P; H := H + P end;
    if S = ncasSquareRoot then L := Max(0.0, L);
  end;
  Result := TNimbusChartRange.Create(L, H);
end;

function TNimbusChartAxis.IsValueValid(const AValue: Double; const ARange: TNimbusChartRange): Boolean;
var S: TNimbusChartAxisScale;
begin
  Result := SparklineFinite(AValue); if not Result then Exit;
  S := GetEffectiveScale(ARange);
  if IsStrictLog(S) then Result := AValue > 0 else if S = ncasSquareRoot then Result := AValue >= 0;
end;

function TNimbusChartAxis.NormalizeValue(const AValue: Double; const ARange: TNimbusChartRange): Double;
begin Result := NormalizeWithinRange(AValue, GetEffectiveRange(ARange)) end;

function TNimbusChartAxis.DenormalizeValue(const ARatio: Double; const ARange: TNimbusChartRange): Double;
begin Result := DenormalizeWithinRange(ARatio, GetEffectiveRange(ARange)) end;

function TNimbusChartAxis.NormalizeWithinRange(const AValue: Double; const ARange: TNimbusChartRange): Double;
var R: TNimbusChartRange; S: TNimbusChartAxisScale; L, H, V: Double;
begin
  R := ARange; if not R.IsValid or (R.Span <= 0) then R := GetEffectiveRange(ARange); S := GetEffectiveScale(R); V := AValue;
  if not IsValueValid(V, R) then
  begin
    if FInvalidLogValueBehavior = ncilThrow then raise EArgumentOutOfRangeException.Create('Value is invalid for chart axis');
    if (FInvalidLogValueBehavior = ncilClamp) and IsStrictLog(S) then V := R.Minimum else Exit(NaN);
  end;
  L := Transform(R.Minimum, S); H := Transform(R.Maximum, S);
  if Abs(H - L) < 1E-12 then Exit(0.5);
  Result := (Transform(V, S) - L) / (H - L);
end;

function TNimbusChartAxis.DenormalizeWithinRange(const ARatio: Double; const ARange: TNimbusChartRange): Double;
var R: TNimbusChartRange; S: TNimbusChartAxisScale; L, H: Double;
begin
  R := ARange; if not R.IsValid or (R.Span <= 0) then R := GetEffectiveRange(ARange); S := GetEffectiveScale(R);
  L := Transform(R.Minimum, S); H := Transform(R.Maximum, S);
  Result := InverseTransform(L + ARatio * (H - L), S);
end;

function TNimbusChartAxis.CreateTicks(const ARange: TNimbusChartRange): TArray<Double>;
var R: TNimbusChartRange; S: TNimbusChartAxisScale; I, A, B, Step, N: Integer; Base, V: Double;
  procedure Add(const Value: Double);
  begin N := Length(Result); SetLength(Result, N + 1); Result[N] := Value end;
begin
  Result := nil; R := GetEffectiveRange(ARange); S := GetEffectiveScale(R);
  if not IsStrictLog(S) then
  begin
    SetLength(Result, FTickCount);
    for I := 0 to FTickCount - 1 do Result[I] := DenormalizeValue(I / (FTickCount - 1), R);
    Exit;
  end;
  Base := LogBase(S); A := Floor(Ln(R.Minimum) / Ln(Base)); B := Ceil(Ln(R.Maximum) / Ln(Base));
  Step := Max(1, Ceil((B - A) / Max(1, FTickCount - 1))); I := A;
  while I <= B do
  begin V := Power(Base, I); if (V >= R.Minimum) and (V <= R.Maximum) then Add(V); Inc(I, Step) end;
  V := Power(Base, B);
  if (Length(Result) = 0) or not SameValue(Result[High(Result)], V) then Add(V);
end;

function TNimbusChartAxis.CreateMinorTicks(const ARange: TNimbusChartRange): TArray<Double>;
var R: TNimbusChartRange; S: TNimbusChartAxisScale; A, B, I, J, K, N: Integer; Base, V: Double;
begin
  Result := nil; R := GetEffectiveRange(ARange); S := GetEffectiveScale(R);
  if not IsStrictLog(S) or (FMinorTickMode = nclmtNone) then Exit;
  Base := LogBase(S); A := Floor(Ln(R.Minimum) / Ln(Base)); B := Ceil(Ln(R.Maximum) / Ln(Base));
  if FMinorTickMode = nclmtAll then K := EnsureRange(Round(Base) - 1, 2, 99)
  else if SameValue(Base, 10) then K := 9 else if SameValue(Base, 2) then K := 1 else K := EnsureRange(Round(Base) - 1, 2, 9);
  for I := A to B - 1 do for J := 2 to K do
  begin
    V := Power(Base, I) * J;
    if (V > R.Minimum) and (V < R.Maximum) then begin N := Length(Result); SetLength(Result, N + 1); Result[N] := V end;
  end;
end;

function TNimbusChartAxis.FormatValue(const AValue: Double; const ARange: TNimbusChartRange): string;
var S: TNimbusChartAxisScale; Exponent: Double; F: string;
begin
  if FValueType = ncavtDateTimeOADate then
  begin
    F := FDateTimeLabelFormat;
    if (F = '') or (F = 'g') then F := 'ddddd t';
    if (AValue > -657434) and (AValue < 2958466) then Result := FormatDateTime(F, AValue)
    else Result := SparklineFormatValue(AValue, '0.##');
  end
  else if FLabelFormat <> '' then Result := SparklineFormatValue(AValue, FLabelFormat)
  else
  begin
    S := GetEffectiveScale(GetEffectiveRange(ARange));
    if IsStrictLog(S) and (FLogarithmicLabelMode <> ncllmPlainNumber) and (AValue > 0) then
    begin
      Exponent := Ln(AValue) / Ln(LogBase(S));
      if (FLogarithmicLabelMode = ncllmPowerNotation) and SameValue(Exponent, Round(Exponent)) then Result := FloatToStr(LogBase(S)) + '^' + IntToStr(Round(Exponent))
      else Result := FormatFloat('0.###E+0', AValue);
    end
    else Result := SparklineFormatValue(AValue, '0.##');
  end;
  if Assigned(FOnLabelFormatting) then FOnLabelFormatting(Self, AValue, Result);
end;

constructor TNimbusChartReferenceLine.Create(Collection: TCollection);
begin
  inherited;
  FOrientation := ncroHorizontal;
  FValue := 0;
  FText := '';
  FColor := clNone;
  FWidth := 1;
  FVisible := True;
  FYAxis := ncyPrimary;
  FTag := 0;
end;

procedure TNimbusChartReferenceLine.Assign(Source: TPersistent);
var S: TNimbusChartReferenceLine;
begin
  if not (Source is TNimbusChartReferenceLine) then begin inherited; Exit end; S := TNimbusChartReferenceLine(Source);
  FOrientation := S.FOrientation;
  FValue := S.FValue;
  FText := S.FText;
  FColor := S.FColor;
  FWidth := S.FWidth;
  FVisible := S.FVisible;
  FYAxis := S.FYAxis;
  FTag := S.FTag;
  Changed(False);
end;

procedure TNimbusChartReferenceLine.SetOrientation(const AValue: TNimbusChartReferenceOrientation);
begin
  if FOrientation = AValue then Exit; FOrientation := AValue;
  Changed(False);
end;

procedure TNimbusChartReferenceLine.SetValue(const AValue: Double);
begin
  if FValue = AValue then Exit; FValue := AValue;
  Changed(False);
end;

procedure TNimbusChartReferenceLine.SetText(const AValue: string);
begin
  if FText = AValue then Exit; FText := AValue;
  Changed(False);
end;

procedure TNimbusChartReferenceLine.SetColor(const AValue: TColor);
begin
  if FColor = AValue then Exit; FColor := AValue;
  Changed(False);
end;

procedure TNimbusChartReferenceLine.SetWidth(const AValue: Single);
begin
  if FWidth = AValue then Exit; FWidth := AValue;
  Changed(False);
end;

procedure TNimbusChartReferenceLine.SetVisible(const AValue: Boolean);
begin
  if FVisible = AValue then Exit; FVisible := AValue;
  Changed(False);
end;

procedure TNimbusChartReferenceLine.SetYAxis(const AValue: TNimbusChartSeriesYAxis);
begin
  if FYAxis = AValue then Exit; FYAxis := AValue;
  Changed(False);
end;

procedure TNimbusChartReferenceLine.SetTag(const AValue: NativeInt);
begin
  if FTag = AValue then Exit; FTag := AValue;
  Changed(False);
end;

constructor TNimbusChartReferenceLineCollection.Create(AOwner: TPersistent);
begin inherited Create(AOwner, TNimbusChartReferenceLine) end;

function TNimbusChartReferenceLineCollection.GetItem(Index: Integer): TNimbusChartReferenceLine;
begin Result := TNimbusChartReferenceLine(inherited Items[Index]) end;

function TNimbusChartReferenceLineCollection.Add: TNimbusChartReferenceLine;
begin Result := TNimbusChartReferenceLine(inherited Add) end;

procedure TNimbusChartReferenceLineCollection.Update(Item: TCollectionItem);
begin inherited; if Assigned(FOnChange) then FOnChange(Self) end;

constructor TNimbusChartReferenceRange.Create(Collection: TCollection);
begin
  inherited;
  FOrientation := ncroHorizontal;
  FMinimum := 0;
  FMaximum := 0;
  FText := '';
  FColor := clNone;
  FOpacity := 0.12;
  FVisible := True;
  FYAxis := ncyPrimary;
  FTag := 0;
end;

procedure TNimbusChartReferenceRange.Assign(Source: TPersistent);
var S: TNimbusChartReferenceRange;
begin
  if not (Source is TNimbusChartReferenceRange) then begin inherited; Exit end; S := TNimbusChartReferenceRange(Source);
  FOrientation := S.FOrientation;
  FMinimum := S.FMinimum;
  FMaximum := S.FMaximum;
  FText := S.FText;
  FColor := S.FColor;
  FOpacity := S.FOpacity;
  FVisible := S.FVisible;
  FYAxis := S.FYAxis;
  FTag := S.FTag;
  Changed(False);
end;

procedure TNimbusChartReferenceRange.SetOrientation(const AValue: TNimbusChartReferenceOrientation);
begin
  if FOrientation = AValue then Exit; FOrientation := AValue;
  Changed(False);
end;

procedure TNimbusChartReferenceRange.SetMinimum(const AValue: Double);
begin
  if FMinimum = AValue then Exit; FMinimum := AValue;
  Changed(False);
end;

procedure TNimbusChartReferenceRange.SetMaximum(const AValue: Double);
begin
  if FMaximum = AValue then Exit; FMaximum := AValue;
  Changed(False);
end;

procedure TNimbusChartReferenceRange.SetText(const AValue: string);
begin
  if FText = AValue then Exit; FText := AValue;
  Changed(False);
end;

procedure TNimbusChartReferenceRange.SetColor(const AValue: TColor);
begin
  if FColor = AValue then Exit; FColor := AValue;
  Changed(False);
end;

procedure TNimbusChartReferenceRange.SetOpacity(const AValue: Single);
begin
  if not SparklineFinite(AValue) then Exit;
  if FOpacity = EnsureRange(AValue, Single(0), Single(1)) then Exit;
  FOpacity := EnsureRange(AValue, Single(0), Single(1));
  Changed(False);
end;

procedure TNimbusChartReferenceRange.SetVisible(const AValue: Boolean);
begin
  if FVisible = AValue then Exit; FVisible := AValue;
  Changed(False);
end;

procedure TNimbusChartReferenceRange.SetYAxis(const AValue: TNimbusChartSeriesYAxis);
begin
  if FYAxis = AValue then Exit; FYAxis := AValue;
  Changed(False);
end;

procedure TNimbusChartReferenceRange.SetTag(const AValue: NativeInt);
begin
  if FTag = AValue then Exit; FTag := AValue;
  Changed(False);
end;

constructor TNimbusChartReferenceRangeCollection.Create(AOwner: TPersistent);
begin inherited Create(AOwner, TNimbusChartReferenceRange) end;

function TNimbusChartReferenceRangeCollection.GetItem(Index: Integer): TNimbusChartReferenceRange;
begin Result := TNimbusChartReferenceRange(inherited Items[Index]) end;

function TNimbusChartReferenceRangeCollection.Add: TNimbusChartReferenceRange;
begin Result := TNimbusChartReferenceRange(inherited Add) end;

procedure TNimbusChartReferenceRangeCollection.Update(Item: TCollectionItem);
begin inherited; if Assigned(FOnChange) then FOnChange(Self) end;

constructor TNimbusChartAnnotation.Create(Collection: TCollection);
begin
  inherited;
  FXValue := 0;
  FYValue := 0;
  FText := '';
  FForeColor := clNone;
  FBackColor := clNone;
  FBorderColor := clNone;
  FVisible := True;
  FPadding := 6;
  FAlignment := ncaaCenter;
  FYAxis := ncyPrimary;
  FSelectable := True;
  FToolTipText := '';
  FAutoArrange := True;
  FLeaderLineVisible := True;
  FZIndex := 0;
  FOffsetX := 0;
  FOffsetY := 0;
  FTag := 0;
end;

procedure TNimbusChartAnnotation.Assign(Source: TPersistent);
var S: TNimbusChartAnnotation;
begin
  if not (Source is TNimbusChartAnnotation) then begin inherited; Exit end; S := TNimbusChartAnnotation(Source);
  FXValue := S.FXValue;
  FYValue := S.FYValue;
  FText := S.FText;
  FForeColor := S.FForeColor;
  FBackColor := S.FBackColor;
  FBorderColor := S.FBorderColor;
  FVisible := S.FVisible;
  FPadding := S.FPadding;
  FAlignment := S.FAlignment;
  FYAxis := S.FYAxis;
  FSelectable := S.FSelectable;
  FToolTipText := S.FToolTipText;
  FAutoArrange := S.FAutoArrange;
  FLeaderLineVisible := S.FLeaderLineVisible;
  FZIndex := S.FZIndex;
  FOffsetX := S.FOffsetX;
  FOffsetY := S.FOffsetY;
  FTag := S.FTag;
  Changed(False);
end;

procedure TNimbusChartAnnotation.SetXValue(const AValue: Double);
begin
  if FXValue = AValue then Exit; FXValue := AValue;
  Changed(False);
end;

procedure TNimbusChartAnnotation.SetYValue(const AValue: Double);
begin
  if FYValue = AValue then Exit; FYValue := AValue;
  Changed(False);
end;

procedure TNimbusChartAnnotation.SetText(const AValue: string);
begin
  if FText = AValue then Exit; FText := AValue;
  Changed(False);
end;

procedure TNimbusChartAnnotation.SetForeColor(const AValue: TColor);
begin
  if FForeColor = AValue then Exit; FForeColor := AValue;
  Changed(False);
end;

procedure TNimbusChartAnnotation.SetBackColor(const AValue: TColor);
begin
  if FBackColor = AValue then Exit; FBackColor := AValue;
  Changed(False);
end;

procedure TNimbusChartAnnotation.SetBorderColor(const AValue: TColor);
begin
  if FBorderColor = AValue then Exit; FBorderColor := AValue;
  Changed(False);
end;

procedure TNimbusChartAnnotation.SetVisible(const AValue: Boolean);
begin
  if FVisible = AValue then Exit; FVisible := AValue;
  Changed(False);
end;

procedure TNimbusChartAnnotation.SetPadding(const AValue: Integer);
begin
  if FPadding = AValue then Exit; FPadding := AValue;
  Changed(False);
end;

procedure TNimbusChartAnnotation.SetAlignment(const AValue: TNimbusChartAnnotationAlignment);
begin
  if FAlignment = AValue then Exit; FAlignment := AValue;
  Changed(False);
end;

procedure TNimbusChartAnnotation.SetYAxis(const AValue: TNimbusChartSeriesYAxis);
begin
  if FYAxis = AValue then Exit; FYAxis := AValue;
  Changed(False);
end;

procedure TNimbusChartAnnotation.SetSelectable(const AValue: Boolean);
begin
  if FSelectable = AValue then Exit; FSelectable := AValue;
  Changed(False);
end;

procedure TNimbusChartAnnotation.SetToolTipText(const AValue: string);
begin
  if FToolTipText = AValue then Exit; FToolTipText := AValue;
  Changed(False);
end;

procedure TNimbusChartAnnotation.SetAutoArrange(const AValue: Boolean);
begin
  if FAutoArrange = AValue then Exit; FAutoArrange := AValue;
  Changed(False);
end;

procedure TNimbusChartAnnotation.SetLeaderLineVisible(const AValue: Boolean);
begin
  if FLeaderLineVisible = AValue then Exit; FLeaderLineVisible := AValue;
  Changed(False);
end;

procedure TNimbusChartAnnotation.SetZIndex(const AValue: Integer);
begin
  if FZIndex = AValue then Exit; FZIndex := AValue;
  Changed(False);
end;

procedure TNimbusChartAnnotation.SetOffsetX(const AValue: Single);
begin
  if FOffsetX = AValue then Exit; FOffsetX := AValue;
  Changed(False);
end;

procedure TNimbusChartAnnotation.SetOffsetY(const AValue: Single);
begin
  if FOffsetY = AValue then Exit; FOffsetY := AValue;
  Changed(False);
end;

procedure TNimbusChartAnnotation.SetTag(const AValue: NativeInt);
begin
  if FTag = AValue then Exit; FTag := AValue;
  Changed(False);
end;

constructor TNimbusChartAnnotationCollection.Create(AOwner: TPersistent);
begin inherited Create(AOwner, TNimbusChartAnnotation) end;

function TNimbusChartAnnotationCollection.GetItem(Index: Integer): TNimbusChartAnnotation;
begin Result := TNimbusChartAnnotation(inherited Items[Index]) end;

function TNimbusChartAnnotationCollection.Add: TNimbusChartAnnotation;
begin Result := TNimbusChartAnnotation(inherited Add) end;

procedure TNimbusChartAnnotationCollection.Update(Item: TCollectionItem);
begin inherited; if Assigned(FOnChange) then FOnChange(Self) end;

procedure TNimbusChartModel.SetReferenceLines(const AValue: TNimbusChartReferenceLineCollection);
begin if AValue <> nil then FReferenceLines.Assign(AValue) end;

procedure TNimbusChartModel.SetReferenceRanges(const AValue: TNimbusChartReferenceRangeCollection);
begin if AValue <> nil then FReferenceRanges.Assign(AValue) end;

procedure TNimbusChartModel.SetAnnotations(const AValue: TNimbusChartAnnotationCollection);
begin if AValue <> nil then FAnnotations.Assign(AValue) end;

constructor TNimbusChartPalette.Create;
begin inherited Create; ApplyLightDefaults end;

function TNimbusChartPalette.GetColors: TArray<TColor>;
begin Result := Copy(FColors) end;

procedure TNimbusChartPalette.SetColors(const AValue: TArray<TColor>);
begin FColors := Copy(AValue); Changed end;

function TNimbusChartPalette.GetSeriesColor(const AIndex: Integer): TColor;
begin if Length(FColors) = 0 then Result := FAccentColor else Result := FColors[Max(0, AIndex) mod Length(FColors)] end;

procedure TNimbusChartPalette.ReadColors(Reader: TReader);
var N: Integer;
begin
  FColors := nil; Reader.ReadListBegin;
  while not Reader.EndOfList do begin N := Length(FColors); SetLength(FColors, N + 1); FColors[N] := Reader.ReadInteger end;
  Reader.ReadListEnd; Changed;
end;

procedure TNimbusChartPalette.WriteColors(Writer: TWriter);
var I: Integer;
begin Writer.WriteListBegin; for I := 0 to High(FColors) do Writer.WriteInteger(FColors[I]); Writer.WriteListEnd end;

procedure TNimbusChartPalette.DefineProperties(Filer: TFiler);
begin inherited; Filer.DefineProperty('Colors', ReadColors, WriteColors, Length(FColors) > 0) end;

procedure TNimbusChartPalette.Assign(Source: TPersistent);
var S: TNimbusChartPalette;
begin
  if not (Source is TNimbusChartPalette) then begin inherited; Exit end;
  S := TNimbusChartPalette(Source); FColors := Copy(S.FColors);
  FBackColor := S.FBackColor;
  FForeColor := S.FForeColor;
  FMutedForeColor := S.FMutedForeColor;
  FBorderColor := S.FBorderColor;
  FGridLineColor := S.FGridLineColor;
  FPlotBackColor := S.FPlotBackColor;
  FAccentColor := S.FAccentColor;
  FSuccessColor := S.FSuccessColor;
  FWarningColor := S.FWarningColor;
  FErrorColor := S.FErrorColor;
  FInfoColor := S.FInfoColor;
  Changed;
end;

procedure TNimbusChartPalette.SetBackColor(const AValue: TColor);
begin if FBackColor <> AValue then begin FBackColor := AValue; Changed end end;

procedure TNimbusChartPalette.SetForeColor(const AValue: TColor);
begin if FForeColor <> AValue then begin FForeColor := AValue; Changed end end;

procedure TNimbusChartPalette.SetMutedForeColor(const AValue: TColor);
begin if FMutedForeColor <> AValue then begin FMutedForeColor := AValue; Changed end end;

procedure TNimbusChartPalette.SetBorderColor(const AValue: TColor);
begin if FBorderColor <> AValue then begin FBorderColor := AValue; Changed end end;

procedure TNimbusChartPalette.SetGridLineColor(const AValue: TColor);
begin if FGridLineColor <> AValue then begin FGridLineColor := AValue; Changed end end;

procedure TNimbusChartPalette.SetPlotBackColor(const AValue: TColor);
begin if FPlotBackColor <> AValue then begin FPlotBackColor := AValue; Changed end end;

procedure TNimbusChartPalette.SetAccentColor(const AValue: TColor);
begin if FAccentColor <> AValue then begin FAccentColor := AValue; Changed end end;

procedure TNimbusChartPalette.SetSuccessColor(const AValue: TColor);
begin if FSuccessColor <> AValue then begin FSuccessColor := AValue; Changed end end;

procedure TNimbusChartPalette.SetWarningColor(const AValue: TColor);
begin if FWarningColor <> AValue then begin FWarningColor := AValue; Changed end end;

procedure TNimbusChartPalette.SetErrorColor(const AValue: TColor);
begin if FErrorColor <> AValue then begin FErrorColor := AValue; Changed end end;

procedure TNimbusChartPalette.SetInfoColor(const AValue: TColor);
begin if FInfoColor <> AValue then begin FInfoColor := AValue; Changed end end;

procedure TNimbusChartPalette.ApplyLightDefaults;
begin
  FBackColor := ThemeColorToColor(ThemeColor(255, 255, 255, 255));
  FForeColor := ThemeColorToColor(ThemeColor(255, 32, 32, 32));
  FMutedForeColor := ThemeColorToColor(ThemeColor(255, 110, 110, 110));
  FBorderColor := ThemeColorToColor(ThemeColor(255, 210, 210, 210));
  FGridLineColor := ThemeColorToColor(ThemeColor(255, 232, 232, 232));
  FPlotBackColor := ThemeColorToColor(ThemeColor(255, 255, 255, 255));
  FAccentColor := ThemeColorToColor(ThemeColor(255, 0, 122, 204));
  FSuccessColor := ThemeColorToColor(ThemeColor(255, 65, 165, 90));
  FWarningColor := ThemeColorToColor(ThemeColor(255, 230, 155, 45));
  FErrorColor := ThemeColorToColor(ThemeColor(255, 220, 70, 70));
  FInfoColor := ThemeColorToColor(ThemeColor(255, 0, 122, 204));
  FColors := [ThemeColorToColor(ThemeColor(255, 0, 122, 204)), ThemeColorToColor(ThemeColor(255, 65, 165, 90)), ThemeColorToColor(ThemeColor(255, 230, 155, 45)), ThemeColorToColor(ThemeColor(255, 197, 89, 145)), ThemeColorToColor(ThemeColor(255, 112, 94, 173)), ThemeColorToColor(ThemeColor(255, 0, 153, 188)), ThemeColorToColor(ThemeColor(255, 216, 95, 2)), ThemeColorToColor(ThemeColor(255, 117, 112, 179))];
  Changed;
end;

procedure TNimbusChartPalette.ApplyDarkDefaults;
begin
  FBackColor := ThemeColorToColor(ThemeColor(255, 37, 37, 38));
  FForeColor := ThemeColorToColor(ThemeColor(255, 241, 241, 241));
  FMutedForeColor := ThemeColorToColor(ThemeColor(255, 165, 165, 165));
  FBorderColor := ThemeColorToColor(ThemeColor(255, 63, 63, 70));
  FGridLineColor := ThemeColorToColor(ThemeColor(255, 53, 53, 60));
  FPlotBackColor := ThemeColorToColor(ThemeColor(255, 37, 37, 38));
  FAccentColor := ThemeColorToColor(ThemeColor(255, 0, 122, 204));
  FSuccessColor := ThemeColorToColor(ThemeColor(255, 85, 180, 105));
  FWarningColor := ThemeColorToColor(ThemeColor(255, 235, 170, 65));
  FErrorColor := ThemeColorToColor(ThemeColor(255, 232, 92, 92));
  FInfoColor := ThemeColorToColor(ThemeColor(255, 0, 122, 204));
  FColors := [ThemeColorToColor(ThemeColor(255, 86, 156, 214)), ThemeColorToColor(ThemeColor(255, 78, 201, 176)), ThemeColorToColor(ThemeColor(255, 220, 220, 170)), ThemeColorToColor(ThemeColor(255, 197, 134, 192)), ThemeColorToColor(ThemeColor(255, 206, 145, 120)), ThemeColorToColor(ThemeColor(255, 181, 206, 168)), ThemeColorToColor(ThemeColor(255, 156, 220, 254)), ThemeColorToColor(ThemeColor(255, 215, 186, 125))];
  Changed;
end;

procedure TNimbusChartPalette.ApplyGlowingDefaults;
begin
  FBackColor := RGB(15, 19, 32);
  FPlotBackColor := RGB(19, 25, 42);
  FForeColor := RGB(235, 244, 255);
  FMutedForeColor := RGB(146, 165, 192);
  FBorderColor := RGB(49, 64, 91);
  FGridLineColor := RGB(34, 45, 65);
  FAccentColor := RGB(63, 220, 255);
  FSuccessColor := RGB(74, 242, 173);
  FWarningColor := RGB(255, 203, 92);
  FErrorColor := RGB(255, 101, 141);
  FInfoColor := FAccentColor;
  FColors := [FAccentColor, RGB(175, 123, 255), FSuccessColor, RGB(255, 114, 197), FWarningColor, RGB(99, 145, 255), RGB(255, 145, 102), RGB(147, 244, 232)];
  Changed;
end;

procedure TNimbusChartPalette.ApplyTheme(const ATheme: TThemePalette);
begin
  if ATheme = nil then Exit;
  if ATheme.IsDark then ApplyDarkDefaults else ApplyLightDefaults;
  FBackColor := ThemeColorToColor(ATheme.ControlBackColor); FPlotBackColor := FBackColor;
  FForeColor := ThemeColorToColor(ATheme.ControlForeColor); FMutedForeColor := ThemeColorToColor(ATheme.MutedForeColor);
  FBorderColor := ThemeColorToColor(ATheme.ControlBorderColor); FAccentColor := ThemeColorToColor(ATheme.AccentColor); FInfoColor := FAccentColor;
  FGridLineColor := ThemeColorToColor(NimbusBlendColor(ATheme.ControlBorderColor, ATheme.ControlBackColor, 140)); Changed;
end;

procedure TNimbusChartPalette.ApplyThemeBlend(const ATheme: TThemePalette; const AInfluence: Integer);
var Target: TNimbusChartPalette; Weight: Byte; I: Integer;
  function Blend(const Color, ThemeColor: TColor): TColor;
  begin
    if Color = clNone then Result := ThemeColor else Result := ThemeColorToColor(NimbusBlendColor(ColorToThemeColor(Color), ColorToThemeColor(ThemeColor), Weight));
  end;
begin
  if (ATheme = nil) or (AInfluence <= 0) then Exit;
  Weight := Round(EnsureRange(AInfluence, 0, 100) * 255 / 100); Target := TNimbusChartPalette.Create;
  try
    Target.ApplyTheme(ATheme);
    FBackColor := Blend(FBackColor, Target.BackColor); FForeColor := Blend(FForeColor, Target.ForeColor);
    FMutedForeColor := Blend(FMutedForeColor, Target.MutedForeColor); FBorderColor := Blend(FBorderColor, Target.BorderColor);
    FGridLineColor := Blend(FGridLineColor, Target.GridLineColor); FPlotBackColor := Blend(FPlotBackColor, Target.PlotBackColor);
    FAccentColor := Blend(FAccentColor, Target.AccentColor); FSuccessColor := Blend(FSuccessColor, Target.SuccessColor);
    FWarningColor := Blend(FWarningColor, Target.WarningColor); FErrorColor := Blend(FErrorColor, Target.ErrorColor); FInfoColor := Blend(FInfoColor, Target.InfoColor);
    for I := 0 to High(FColors) do FColors[I] := Blend(FColors[I], Target.GetSeriesColor(I));
    Changed;
  finally Target.Free end;
end;

function TNimbusChartPalette.Clone: TNimbusChartPalette;
begin Result := TNimbusChartPalette.Create; Result.Assign(Self) end;

procedure TNimbusChartModel.SetPalette(const AValue: TNimbusChartPalette);
begin if AValue <> nil then FPalette.Assign(AValue) end;

constructor TNimbusBulletRange.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FStartValue := 0;
  FEndValue := 0;
  FLabel := '';
  FColor := clNone;
end;

procedure TNimbusBulletRange.Assign(Source: TPersistent);
var S: TNimbusBulletRange;
begin
  if not (Source is TNimbusBulletRange) then begin inherited; Exit end; S := TNimbusBulletRange(Source);
  FStartValue := S.FStartValue;
  FEndValue := S.FEndValue;
  FLabel := S.FLabel;
  FColor := S.FColor;
  Changed(False);
end;

procedure TNimbusBulletRange.SetStartValue(const AValue: Double);
begin if FStartValue <> AValue then begin FStartValue := AValue; Changed(False) end end;

procedure TNimbusBulletRange.SetEndValue(const AValue: Double);
begin if FEndValue <> AValue then begin FEndValue := AValue; Changed(False) end end;

procedure TNimbusBulletRange.SetLabel(const AValue: string);
begin if FLabel <> AValue then begin FLabel := AValue; Changed(False) end end;

procedure TNimbusBulletRange.SetColor(const AValue: TColor);
begin if FColor <> AValue then begin FColor := AValue; Changed(False) end end;

constructor TNimbusBulletRangeCollection.Create(AOwner: TPersistent);
begin inherited Create(AOwner, TNimbusBulletRange) end;

function TNimbusBulletRangeCollection.GetItem(Index: Integer): TNimbusBulletRange;
begin Result := TNimbusBulletRange(inherited Items[Index]) end;

function TNimbusBulletRangeCollection.Add: TNimbusBulletRange;
begin Result := TNimbusBulletRange(inherited Add) end;

procedure TNimbusBulletRangeCollection.Update(Item: TCollectionItem);
begin inherited; if Assigned(FOnChange) then FOnChange(Self) end;

constructor TNimbusBulletData.Create;
begin
  inherited Create;
  FEnabled := False;
  FTitle := '';
  FSubtitle := '';
  FMinimum := 0;
  FMaximum := 100;
  FActualValue := 0;
  FTargetValue := 0;
  FActualText := '';
  FTargetText := '';
  FOrientation := ncoHorizontal;
  FRanges := TNimbusBulletRangeCollection.Create(Self); FRanges.OnChange := RangesChanged;
end;

procedure TNimbusBulletData.Assign(Source: TPersistent);
var S: TNimbusBulletData;
begin
  if not (Source is TNimbusBulletData) then begin inherited; Exit end; S := TNimbusBulletData(Source);
  FEnabled := S.FEnabled;
  FTitle := S.FTitle;
  FSubtitle := S.FSubtitle;
  FMinimum := S.FMinimum;
  FMaximum := S.FMaximum;
  FActualValue := S.FActualValue;
  FTargetValue := S.FTargetValue;
  FActualText := S.FActualText;
  FTargetText := S.FTargetText;
  FOrientation := S.FOrientation;
  FRanges.Assign(S.FRanges);
  Changed;
end;

procedure TNimbusBulletData.SetEnabled(const AValue: Boolean);
begin if FEnabled <> AValue then begin FEnabled := AValue; Changed end end;

procedure TNimbusBulletData.SetTitle(const AValue: string);
begin if FTitle <> AValue then begin FTitle := AValue; Changed end end;

procedure TNimbusBulletData.SetSubtitle(const AValue: string);
begin if FSubtitle <> AValue then begin FSubtitle := AValue; Changed end end;

procedure TNimbusBulletData.SetMinimum(const AValue: Double);
begin if FMinimum <> AValue then begin FMinimum := AValue; Changed end end;

procedure TNimbusBulletData.SetMaximum(const AValue: Double);
begin if FMaximum <> AValue then begin FMaximum := AValue; Changed end end;

procedure TNimbusBulletData.SetActualValue(const AValue: Double);
begin if FActualValue <> AValue then begin FActualValue := AValue; Changed end end;

procedure TNimbusBulletData.SetTargetValue(const AValue: Double);
begin if FTargetValue <> AValue then begin FTargetValue := AValue; Changed end end;

procedure TNimbusBulletData.SetActualText(const AValue: string);
begin if FActualText <> AValue then begin FActualText := AValue; Changed end end;

procedure TNimbusBulletData.SetTargetText(const AValue: string);
begin if FTargetText <> AValue then begin FTargetText := AValue; Changed end end;

procedure TNimbusBulletData.SetOrientation(const AValue: TNimbusChartOrientation);
begin if FOrientation <> AValue then begin FOrientation := AValue; Changed end end;

destructor TNimbusBulletData.Destroy;
begin FRanges.Free; inherited end;

procedure TNimbusBulletData.RangesChanged(Sender: TObject);
begin Changed end;

procedure TNimbusBulletData.SetRanges(const AValue: TNimbusBulletRangeCollection);
begin if AValue <> nil then FRanges.Assign(AValue) end;

constructor TNimbusBoxPlotData.Create;
begin
  inherited Create;
  FEnabled := False;
  FCategory := '';
  FMinimum := 0;
  FQ1 := 0;
  FMedian := 0;
  FQ3 := 0;
  FMaximum := 0;
end;

procedure TNimbusBoxPlotData.Assign(Source: TPersistent);
var S: TNimbusBoxPlotData;
begin
  if not (Source is TNimbusBoxPlotData) then begin inherited; Exit end; S := TNimbusBoxPlotData(Source);
  FEnabled := S.FEnabled;
  FCategory := S.FCategory;
  FMinimum := S.FMinimum;
  FQ1 := S.FQ1;
  FMedian := S.FMedian;
  FQ3 := S.FQ3;
  FMaximum := S.FMaximum;
  FOutliers := Copy(S.FOutliers);
  Changed;
end;

procedure TNimbusBoxPlotData.SetEnabled(const AValue: Boolean);
begin if FEnabled <> AValue then begin FEnabled := AValue; Changed end end;

procedure TNimbusBoxPlotData.SetCategory(const AValue: string);
begin if FCategory <> AValue then begin FCategory := AValue; Changed end end;

procedure TNimbusBoxPlotData.SetMinimum(const AValue: Double);
begin if FMinimum <> AValue then begin FMinimum := AValue; Changed end end;

procedure TNimbusBoxPlotData.SetQ1(const AValue: Double);
begin if FQ1 <> AValue then begin FQ1 := AValue; Changed end end;

procedure TNimbusBoxPlotData.SetMedian(const AValue: Double);
begin if FMedian <> AValue then begin FMedian := AValue; Changed end end;

procedure TNimbusBoxPlotData.SetQ3(const AValue: Double);
begin if FQ3 <> AValue then begin FQ3 := AValue; Changed end end;

procedure TNimbusBoxPlotData.SetMaximum(const AValue: Double);
begin if FMaximum <> AValue then begin FMaximum := AValue; Changed end end;

function TNimbusBoxPlotData.GetOutliers: TSparklineValues;
begin Result := Copy(FOutliers) end;

procedure TNimbusBoxPlotData.SetOutliers(const AValue: TSparklineValues);
begin FOutliers := Copy(AValue); Changed end;

procedure TNimbusBoxPlotData.ReadOutliers(Reader: TReader);
var N: Integer;
begin
  FOutliers := nil; Reader.ReadListBegin;
  while not Reader.EndOfList do begin N := Length(FOutliers); SetLength(FOutliers, N + 1); FOutliers[N] := Reader.ReadFloat end;
  Reader.ReadListEnd; Changed;
end;

procedure TNimbusBoxPlotData.WriteOutliers(Writer: TWriter);
var I: Integer;
begin Writer.WriteListBegin; for I := 0 to High(FOutliers) do Writer.WriteFloat(FOutliers[I]); Writer.WriteListEnd end;

procedure TNimbusBoxPlotData.DefineProperties(Filer: TFiler);
begin inherited; Filer.DefineProperty('Outliers', ReadOutliers, WriteOutliers, Length(FOutliers) > 0) end;

procedure TNimbusChartSeries.SetBullet(const AValue: TNimbusBulletData);
begin if AValue <> nil then FBullet.Assign(AValue) end;

procedure TNimbusChartSeries.SetBoxPlot(const AValue: TNimbusBoxPlotData);
begin if AValue <> nil then FBoxPlot.Assign(AValue) end;

function NimbusChartPercentile(const AValues: TSparklineValues; const ARatio: Double): Double;
var P: Double; L, H: Integer;
begin
  if Length(AValues) = 0 then Exit(NaN);
  P := High(AValues) * EnsureRange(ARatio, 0.0, 1.0); L := Floor(P); H := Ceil(P);
  Result := AValues[L] + (AValues[H] - AValues[L]) * (P - L);
end;

function TNimbusChartModel.GetBoxPlotRange: TNimbusChartRange;
var I: Integer; S: TNimbusChartSeries; R: TNimbusChartRange; V: Double;
  procedure Include(const Value: Double);
  begin
    if not SparklineFinite(Value) then Exit;
    if not Result.IsValid then Result := TNimbusChartRange.Create(Value, Value)
    else Result := TNimbusChartRange.Create(Min(Result.Minimum, Value), Max(Result.Maximum, Value));
  end;
begin
  Result := TNimbusChartRange.Empty;
  for I := 0 to FSeries.Count - 1 do
  begin
    S := FSeries[I]; if not S.Visible then Continue;
    if S.BoxPlot.Enabled then begin Include(S.BoxPlot.Minimum); Include(S.BoxPlot.Maximum); for V in S.BoxPlot.Outliers do Include(V) end
    else begin R := S.GetYRange; if R.IsValid then begin Include(R.Minimum); Include(R.Maximum) end end;
  end;
end;


procedure TNimbusChartOptions.SetMapColorMode(const AValue: TNimbusChartMapColorMode);
begin if FMapColorMode <> AValue then begin FMapColorMode := AValue; Changed end end;
procedure TNimbusChartOptions.SetMapEmptyColor(const AValue: TColor);
begin if FMapEmptyColor <> AValue then begin FMapEmptyColor := AValue; Changed end end;
procedure TNimbusChartModel.SetHeatmapColorPreset(const AValue: TNimbusHeatmapColorPreset);
begin if FHeatmapColorPreset <> AValue then begin FHeatmapColorPreset := AValue; NotifyChanged end end;

end.

{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Charts.Sparkline.Types;

interface

uses
  System.Classes, System.Types, System.SysUtils, System.Math, System.Generics.Collections, Vcl.Graphics;

type
  TSparklineValues = TArray<Double>;
  TSparklineRenderStyle = (srsLine, srsArea, srsBars, srsWinLoss, srsDots);
  TSparklineRangeMode = (srmAuto, srmFixed, srmZeroBased, srmSymmetric);
  TSparklinePerformanceMode = (spmQuality, spmBalanced, spmFast);
  TSparklineThemeMode = (stmAuto, stmDark, stmLight, stmCustom, stmAdaptiveCustom);
  TSparklineMarkerShape = (smsCircle, smsSquare, smsDiamond, smsTriangle, smsCross);
  TSparklineDashStyle = (sdsSolid, sdsDash, sdsDot, sdsDashDot, sdsDashDotDot);

  TSparklineValueRange = record
    Minimum, Maximum: Double;
    class function Create(const AMinimum, AMaximum: Double): TSparklineValueRange; static;
    class function Empty: TSparklineValueRange; static;
    class function Resolve(const AMinimum, AMaximum: Double): TSparklineValueRange; static;
    function IsValid: Boolean;
    function Span: Double;
  end;

  TSparklineSeries = class(TPersistent)
  private
    FValues: TSparklineValues;
    FRange: TSparklineValueRange;
    FRangeMode: TSparklineRangeMode;
    FVersion: UInt64;
    FOnChange: TNotifyEvent;
    procedure SetValues(const AValues: TSparklineValues);
    procedure SetRange(const AValue: TSparklineValueRange);
    procedure SetRangeMode(const AValue: TSparklineRangeMode);
    function GetValues: TSparklineValues;
    procedure Changed;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property Values: TSparklineValues read GetValues write SetValues;
    property Range: TSparklineValueRange read FRange write SetRange;
    property RangeMode: TSparklineRangeMode read FRangeMode write SetRangeMode;
    property Version: UInt64 read FVersion;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TSparklineOptions = class(TPersistent)
  private
    FOnChange: TNotifyEvent;
    FStyle: TSparklineRenderStyle;
    FRangeMode: TSparklineRangeMode;
    FPerformanceMode: TSparklinePerformanceMode;
    FFixedRange: TSparklineValueRange;
    FThemeMode: TSparklineThemeMode;
    FThemeInfluence, FBarGap: Integer;
    FAutoThemeFromParent: Boolean;
    FPaintBackground: Boolean;
    FShowBorder: Boolean;
    FShowArea: Boolean;
    FShowLastPoint: Boolean;
    FShowStartPoint: Boolean;
    FShowMinMaxPoints: Boolean;
    FShowMinMaxValueLabels: Boolean;
    FShowZeroLine: Boolean;
    FShowEmptyState: Boolean;
    FEmptyLineVisible: Boolean;
    FEmptyText: string;
    FShowTargetLine: Boolean;
    FTargetValue: Double;
    FShowAverageLine: Boolean;
    FShowRangeBand: Boolean;
    FBandMinimum: Double;
    FBandMaximum: Double;
    FColorizeRisingFallingSegments: Boolean;
    FColorizeNegativeSegments: Boolean;
    FShowEndValueLabel: Boolean;
    FValueLabelWidth: Integer;
    FShowHoverLine: Boolean;
    FShowSelection: Boolean;
    FUltraFastRendering: Boolean;
    FUseGradientArea: Boolean;
    FAreaGradientAlphaTop: Integer;
    FAreaGradientAlphaBottom: Integer;
    FSplitAreaByZero: Boolean;
    FUseRoundedBars: Boolean;
    FBarCornerRadius: Integer;
    FShowToolTip: Boolean;
    FValueFormat: string;
    FAnimateValueChanges: Boolean;
    FAnimationDuration: Integer;
    FSparklinePadding: Integer;
    FStrokeWidth: Single;
    FAccentColor: TColor;
    FMutedColor: TColor;
    FBorderColor: TColor;
    FLineColor: TColor;
    FFillColor: TColor;
    FNegativeColor: TColor;
    FZeroLineColor: TColor;
    FLastPointColor: TColor;
    FMinPointColor: TColor;
    FMaxPointColor: TColor;
    FTargetLineColor: TColor;
    FAverageLineColor: TColor;
    FRangeBandColor: TColor;
    FStartPointColor: TColor;
    FRisingColor: TColor;
    FFallingColor: TColor;
    FHoverLineColor: TColor;
    FSelectionColor: TColor;
    FMarkerColor: TColor;
    procedure SetStyle(const AValue: TSparklineRenderStyle);
    procedure SetRangeMode(const AValue: TSparklineRangeMode);
    procedure SetPerformanceMode(const AValue: TSparklinePerformanceMode);
    procedure SetFixedRange(const AValue: TSparklineValueRange);
    procedure SetThemeMode(const AValue: TSparklineThemeMode);
    procedure SetThemeInfluence(const AValue: Integer);
    procedure SetBarGap(const AValue: Integer);
    procedure SetAutoThemeFromParent(const AValue: Boolean);
    procedure SetPaintBackground(const AValue: Boolean);
    procedure SetShowBorder(const AValue: Boolean);
    procedure SetShowArea(const AValue: Boolean);
    procedure SetShowLastPoint(const AValue: Boolean);
    procedure SetShowStartPoint(const AValue: Boolean);
    procedure SetShowMinMaxPoints(const AValue: Boolean);
    procedure SetShowMinMaxValueLabels(const AValue: Boolean);
    procedure SetShowZeroLine(const AValue: Boolean);
    procedure SetShowEmptyState(const AValue: Boolean);
    procedure SetEmptyLineVisible(const AValue: Boolean);
    procedure SetEmptyText(const AValue: string);
    procedure SetShowTargetLine(const AValue: Boolean);
    procedure SetTargetValue(const AValue: Double);
    procedure SetShowAverageLine(const AValue: Boolean);
    procedure SetShowRangeBand(const AValue: Boolean);
    procedure SetBandMinimum(const AValue: Double);
    procedure SetBandMaximum(const AValue: Double);
    procedure SetColorizeRisingFallingSegments(const AValue: Boolean);
    procedure SetColorizeNegativeSegments(const AValue: Boolean);
    procedure SetShowEndValueLabel(const AValue: Boolean);
    procedure SetValueLabelWidth(const AValue: Integer);
    procedure SetShowHoverLine(const AValue: Boolean);
    procedure SetShowSelection(const AValue: Boolean);
    procedure SetUltraFastRendering(const AValue: Boolean);
    procedure SetUseGradientArea(const AValue: Boolean);
    procedure SetAreaGradientAlphaTop(const AValue: Integer);
    procedure SetAreaGradientAlphaBottom(const AValue: Integer);
    procedure SetSplitAreaByZero(const AValue: Boolean);
    procedure SetUseRoundedBars(const AValue: Boolean);
    procedure SetBarCornerRadius(const AValue: Integer);
    procedure SetShowToolTip(const AValue: Boolean);
    procedure SetValueFormat(const AValue: string);
    procedure SetAnimateValueChanges(const AValue: Boolean);
    procedure SetAnimationDuration(const AValue: Integer);
    procedure SetSparklinePadding(const AValue: Integer);
    procedure SetStrokeWidth(const AValue: Single);
    procedure SetAccentColor(const AValue: TColor);
    procedure SetMutedColor(const AValue: TColor);
    procedure SetBorderColor(const AValue: TColor);
    procedure SetLineColor(const AValue: TColor);
    procedure SetFillColor(const AValue: TColor);
    procedure SetNegativeColor(const AValue: TColor);
    procedure SetZeroLineColor(const AValue: TColor);
    procedure SetLastPointColor(const AValue: TColor);
    procedure SetMinPointColor(const AValue: TColor);
    procedure SetMaxPointColor(const AValue: TColor);
    procedure SetTargetLineColor(const AValue: TColor);
    procedure SetAverageLineColor(const AValue: TColor);
    procedure SetRangeBandColor(const AValue: TColor);
    procedure SetStartPointColor(const AValue: TColor);
    procedure SetRisingColor(const AValue: TColor);
    procedure SetFallingColor(const AValue: TColor);
    procedure SetHoverLineColor(const AValue: TColor);
    procedure SetSelectionColor(const AValue: TColor);
    procedure SetMarkerColor(const AValue: TColor);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property FixedRange: TSparklineValueRange read FFixedRange write SetFixedRange;
  published
    property Style: TSparklineRenderStyle read FStyle write SetStyle default srsLine;
    property RangeMode: TSparklineRangeMode read FRangeMode write SetRangeMode default srmAuto;
    property PerformanceMode: TSparklinePerformanceMode read FPerformanceMode write SetPerformanceMode default spmBalanced;
    property ThemeMode: TSparklineThemeMode read FThemeMode write SetThemeMode default stmAuto;
    property ThemeInfluence: Integer read FThemeInfluence write SetThemeInfluence default 12;
    property BarGap: Integer read FBarGap write SetBarGap default 2;
    property AutoThemeFromParent: Boolean read FAutoThemeFromParent write SetAutoThemeFromParent default True;
    property PaintBackground: Boolean read FPaintBackground write SetPaintBackground default True;
    property ShowBorder: Boolean read FShowBorder write SetShowBorder default False;
    property ShowArea: Boolean read FShowArea write SetShowArea default False;
    property ShowLastPoint: Boolean read FShowLastPoint write SetShowLastPoint default True;
    property ShowStartPoint: Boolean read FShowStartPoint write SetShowStartPoint default False;
    property ShowMinMaxPoints: Boolean read FShowMinMaxPoints write SetShowMinMaxPoints default False;
    property ShowMinMaxValueLabels: Boolean read FShowMinMaxValueLabels write SetShowMinMaxValueLabels default False;
    property ShowZeroLine: Boolean read FShowZeroLine write SetShowZeroLine default False;
    property ShowEmptyState: Boolean read FShowEmptyState write SetShowEmptyState default True;
    property EmptyLineVisible: Boolean read FEmptyLineVisible write SetEmptyLineVisible default True;
    property EmptyText: string read FEmptyText write SetEmptyText;
    property ShowTargetLine: Boolean read FShowTargetLine write SetShowTargetLine default False;
    property TargetValue: Double read FTargetValue write SetTargetValue;
    property ShowAverageLine: Boolean read FShowAverageLine write SetShowAverageLine default False;
    property ShowRangeBand: Boolean read FShowRangeBand write SetShowRangeBand default False;
    property BandMinimum: Double read FBandMinimum write SetBandMinimum;
    property BandMaximum: Double read FBandMaximum write SetBandMaximum;
    property ColorizeRisingFallingSegments: Boolean read FColorizeRisingFallingSegments write SetColorizeRisingFallingSegments default False;
    property ColorizeNegativeSegments: Boolean read FColorizeNegativeSegments write SetColorizeNegativeSegments default False;
    property ShowEndValueLabel: Boolean read FShowEndValueLabel write SetShowEndValueLabel default False;
    property ValueLabelWidth: Integer read FValueLabelWidth write SetValueLabelWidth default 56;
    property ShowHoverLine: Boolean read FShowHoverLine write SetShowHoverLine default False;
    property ShowSelection: Boolean read FShowSelection write SetShowSelection default False;
    property UltraFastRendering: Boolean read FUltraFastRendering write SetUltraFastRendering default False;
    property UseGradientArea: Boolean read FUseGradientArea write SetUseGradientArea default False;
    property AreaGradientAlphaTop: Integer read FAreaGradientAlphaTop write SetAreaGradientAlphaTop default 70;
    property AreaGradientAlphaBottom: Integer read FAreaGradientAlphaBottom write SetAreaGradientAlphaBottom default 6;
    property SplitAreaByZero: Boolean read FSplitAreaByZero write SetSplitAreaByZero default False;
    property UseRoundedBars: Boolean read FUseRoundedBars write SetUseRoundedBars default False;
    property BarCornerRadius: Integer read FBarCornerRadius write SetBarCornerRadius default 2;
    property ShowToolTip: Boolean read FShowToolTip write SetShowToolTip default False;
    property ValueFormat: string read FValueFormat write SetValueFormat;
    property AnimateValueChanges: Boolean read FAnimateValueChanges write SetAnimateValueChanges default False;
    property AnimationDuration: Integer read FAnimationDuration write SetAnimationDuration default 180;
    property SparklinePadding: Integer read FSparklinePadding write SetSparklinePadding default 2;
    property StrokeWidth: Single read FStrokeWidth write SetStrokeWidth;
    property AccentColor: TColor read FAccentColor write SetAccentColor default clNone;
    property MutedColor: TColor read FMutedColor write SetMutedColor default clNone;
    property BorderColor: TColor read FBorderColor write SetBorderColor default clNone;
    property LineColor: TColor read FLineColor write SetLineColor default clNone;
    property FillColor: TColor read FFillColor write SetFillColor default clNone;
    property NegativeColor: TColor read FNegativeColor write SetNegativeColor default clNone;
    property ZeroLineColor: TColor read FZeroLineColor write SetZeroLineColor default clNone;
    property LastPointColor: TColor read FLastPointColor write SetLastPointColor default clNone;
    property MinPointColor: TColor read FMinPointColor write SetMinPointColor default clNone;
    property MaxPointColor: TColor read FMaxPointColor write SetMaxPointColor default clNone;
    property TargetLineColor: TColor read FTargetLineColor write SetTargetLineColor default clNone;
    property AverageLineColor: TColor read FAverageLineColor write SetAverageLineColor default clNone;
    property RangeBandColor: TColor read FRangeBandColor write SetRangeBandColor default clNone;
    property StartPointColor: TColor read FStartPointColor write SetStartPointColor default clNone;
    property RisingColor: TColor read FRisingColor write SetRisingColor default clNone;
    property FallingColor: TColor read FFallingColor write SetFallingColor default clNone;
    property HoverLineColor: TColor read FHoverLineColor write SetHoverLineColor default clNone;
    property SelectionColor: TColor read FSelectionColor write SetSelectionColor default clNone;
    property MarkerColor: TColor read FMarkerColor write SetMarkerColor default clNone;
  end;

  TSparklineReferenceLine = class(TCollectionItem)
  private
    FVisible: Boolean;
    FValue: Double;
    FText: string;
    FColor: TColor;
    FDashStyle: TSparklineDashStyle;
    FStrokeWidth: Single;
    procedure SetVisible(const AValue: Boolean);
    procedure SetValue(const AValue: Double);
    procedure SetText(const AValue: string);
    procedure SetColor(const AValue: TColor);
    procedure SetDashStyle(const AValue: TSparklineDashStyle);
    procedure SetStrokeWidth(const AValue: Single);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Visible: Boolean read FVisible write SetVisible;
    property Value: Double read FValue write SetValue;
    property Text: string read FText write SetText;
    property Color: TColor read FColor write SetColor;
    property DashStyle: TSparklineDashStyle read FDashStyle write SetDashStyle;
    property StrokeWidth: Single read FStrokeWidth write SetStrokeWidth;
  end;

  TSparklineReferenceLineCollection = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    function GetItem(Index: Integer): TSparklineReferenceLine;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TSparklineReferenceLine;
    property Items[Index: Integer]: TSparklineReferenceLine read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TSparklineThresholdBand = class(TCollectionItem)
  private
    FVisible: Boolean;
    FMinimum: Double;
    FMaximum: Double;
    FColor: TColor;
    FAlpha: Integer;
    procedure SetVisible(const AValue: Boolean);
    procedure SetMinimum(const AValue: Double);
    procedure SetMaximum(const AValue: Double);
    procedure SetColor(const AValue: TColor);
    procedure SetAlpha(const AValue: Integer);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Visible: Boolean read FVisible write SetVisible;
    property Minimum: Double read FMinimum write SetMinimum;
    property Maximum: Double read FMaximum write SetMaximum;
    property Color: TColor read FColor write SetColor;
    property Alpha: Integer read FAlpha write SetAlpha;
  end;

  TSparklineThresholdBandCollection = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    function GetItem(Index: Integer): TSparklineThresholdBand;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TSparklineThresholdBand;
    property Items[Index: Integer]: TSparklineThresholdBand read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TSparklineMarker = class(TCollectionItem)
  private
    FVisible: Boolean;
    FPointIndex: Integer;
    FText: string;
    FColor: TColor;
    FShape: TSparklineMarkerShape;
    FRadius: Single;
    procedure SetVisible(const AValue: Boolean);
    procedure SetPointIndex(const AValue: Integer);
    procedure SetText(const AValue: string);
    procedure SetColor(const AValue: TColor);
    procedure SetShape(const AValue: TSparklineMarkerShape);
    procedure SetRadius(const AValue: Single);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Visible: Boolean read FVisible write SetVisible;
    property PointIndex: Integer read FPointIndex write SetPointIndex;
    property Text: string read FText write SetText;
    property Color: TColor read FColor write SetColor;
    property Shape: TSparklineMarkerShape read FShape write SetShape;
    property Radius: Single read FRadius write SetRadius;
  end;

  TSparklineMarkerCollection = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    function GetItem(Index: Integer): TSparklineMarker;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TSparklineMarker;
    property Items[Index: Integer]: TSparklineMarker read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TSparklineGeometry = record
    Points: TArray<TPointF>;
    Bars: TArray<TRectF>;
    SampleValues: TSparklineValues;
    SourceIndices: TArray<Integer>;
    Range: TSparklineValueRange;
    PlotBounds: TRect;
    MinimumIndex, MaximumIndex: Integer;
    ZeroY: Single;
    function HitTest(const ALocation: TPoint; const AMaxDistance: Single): Integer;
  end;

function SparklineFinite(const AValue: Double): Boolean;
function SparklineFormatValue(const AValue: Double; const AFormat: string): string;

implementation

function SparklineFinite(const AValue: Double): Boolean;
begin
  Result := not IsNan(AValue) and not IsInfinite(AValue);
end;

function SparklineFormatValue(const AValue: Double; const AFormat: string): string;
var F: string; P: Integer;
begin
  if not SparklineFinite(AValue) then Exit('');
  F := AFormat;
  if F.StartsWith('{0:') and F.EndsWith('}') then F := Copy(F, 4, Length(F) - 4)
  else if F = '{0}' then F := '0.##';
  P := Pos('%', F);
  if P > 0 then Result := FormatFloat(F, AValue * 100) else Result := FormatFloat(F, AValue);
end;

class function TSparklineValueRange.Create(const AMinimum, AMaximum: Double): TSparklineValueRange;
begin
  Result.Minimum := AMinimum; Result.Maximum := AMaximum;
end;

class function TSparklineValueRange.Empty: TSparklineValueRange;
begin
  Result := Create(NaN, NaN);
end;

function TSparklineValueRange.IsValid: Boolean;
begin
  Result := SparklineFinite(Minimum) and SparklineFinite(Maximum) and (Maximum >= Minimum);
end;

function TSparklineValueRange.Span: Double;
begin
  Result := Maximum - Minimum;
end;

class function TSparklineValueRange.Resolve(const AMinimum, AMaximum: Double): TSparklineValueRange;
var L, H: Double;
begin
  L := AMinimum; H := AMaximum;
  if not SparklineFinite(L) then L := 0;
  if not SparklineFinite(H) then H := 0;
  if Abs(H - L) < 1E-7 then begin L := L - 1; H := H + 1 end;
  Result := Create(Min(L, H), Max(L, H));
end;

constructor TSparklineSeries.Create;
begin
  inherited Create;
  FRange := TSparklineValueRange.Empty;
end;

procedure TSparklineSeries.Changed;
begin
  Inc(FVersion);
  if Assigned(FOnChange) then FOnChange(Self);
end;

function TSparklineSeries.GetValues: TSparklineValues;
begin
  Result := Copy(FValues);
end;

procedure TSparklineSeries.SetValues(const AValues: TSparklineValues);
begin
  FValues := Copy(AValues);
  Changed;
end;

procedure TSparklineSeries.SetRange(const AValue: TSparklineValueRange);
begin
  FRange := AValue; Changed;
end;

procedure TSparklineSeries.SetRangeMode(const AValue: TSparklineRangeMode);
begin
  if FRangeMode = AValue then Exit;
  FRangeMode := AValue; Changed;
end;

procedure TSparklineSeries.Assign(Source: TPersistent);
var S: TSparklineSeries;
begin
  if not (Source is TSparklineSeries) then begin inherited; Exit end;
  S := TSparklineSeries(Source);
  FValues := Copy(S.FValues); FRange := S.FRange; FRangeMode := S.FRangeMode;
  Changed;
end;

constructor TSparklineOptions.Create;
begin
  inherited Create;
  FStyle := srsLine;
  FRangeMode := srmAuto;
  FPerformanceMode := spmBalanced;
  FFixedRange := TSparklineValueRange.Empty;
  FThemeMode := stmAuto;
  FThemeInfluence := 12; FBarGap := 2;
  FAutoThemeFromParent := True;
  FPaintBackground := True;
  FShowBorder := False;
  FShowArea := False;
  FShowLastPoint := True;
  FShowStartPoint := False;
  FShowMinMaxPoints := False;
  FShowMinMaxValueLabels := False;
  FShowZeroLine := False;
  FShowEmptyState := True;
  FEmptyLineVisible := True;
  FEmptyText := 'No data';
  FShowTargetLine := False;
  FTargetValue := 0;
  FShowAverageLine := False;
  FShowRangeBand := False;
  FBandMinimum := 0;
  FBandMaximum := 0;
  FColorizeRisingFallingSegments := False;
  FColorizeNegativeSegments := False;
  FShowEndValueLabel := False;
  FValueLabelWidth := 56;
  FShowHoverLine := False;
  FShowSelection := False;
  FUltraFastRendering := False;
  FUseGradientArea := False;
  FAreaGradientAlphaTop := 70;
  FAreaGradientAlphaBottom := 6;
  FSplitAreaByZero := False;
  FUseRoundedBars := False;
  FBarCornerRadius := 2;
  FShowToolTip := False;
  FValueFormat := '0.##';
  FAnimateValueChanges := False;
  FAnimationDuration := 180;
  FSparklinePadding := 2;
  FStrokeWidth := 1;
  FAccentColor := clNone;
  FMutedColor := clNone;
  FBorderColor := clNone;
  FLineColor := clNone;
  FFillColor := clNone;
  FNegativeColor := clNone;
  FZeroLineColor := clNone;
  FLastPointColor := clNone;
  FMinPointColor := clNone;
  FMaxPointColor := clNone;
  FTargetLineColor := clNone;
  FAverageLineColor := clNone;
  FRangeBandColor := clNone;
  FStartPointColor := clNone;
  FRisingColor := clNone;
  FFallingColor := clNone;
  FHoverLineColor := clNone;
  FSelectionColor := clNone;
  FMarkerColor := clNone;
end;

procedure TSparklineOptions.Assign(Source: TPersistent);
var S: TSparklineOptions;
begin
  if not (Source is TSparklineOptions) then begin inherited; Exit end;
  S := TSparklineOptions(Source);
  FStyle := S.FStyle;
  FRangeMode := S.FRangeMode;
  FPerformanceMode := S.FPerformanceMode;
  FFixedRange := S.FFixedRange;
  FThemeMode := S.FThemeMode;
  FThemeInfluence := S.FThemeInfluence; FBarGap := S.FBarGap;
  FAutoThemeFromParent := S.FAutoThemeFromParent;
  FPaintBackground := S.FPaintBackground;
  FShowBorder := S.FShowBorder;
  FShowArea := S.FShowArea;
  FShowLastPoint := S.FShowLastPoint;
  FShowStartPoint := S.FShowStartPoint;
  FShowMinMaxPoints := S.FShowMinMaxPoints;
  FShowMinMaxValueLabels := S.FShowMinMaxValueLabels;
  FShowZeroLine := S.FShowZeroLine;
  FShowEmptyState := S.FShowEmptyState;
  FEmptyLineVisible := S.FEmptyLineVisible;
  FEmptyText := S.FEmptyText;
  FShowTargetLine := S.FShowTargetLine;
  FTargetValue := S.FTargetValue;
  FShowAverageLine := S.FShowAverageLine;
  FShowRangeBand := S.FShowRangeBand;
  FBandMinimum := S.FBandMinimum;
  FBandMaximum := S.FBandMaximum;
  FColorizeRisingFallingSegments := S.FColorizeRisingFallingSegments;
  FColorizeNegativeSegments := S.FColorizeNegativeSegments;
  FShowEndValueLabel := S.FShowEndValueLabel;
  FValueLabelWidth := S.FValueLabelWidth;
  FShowHoverLine := S.FShowHoverLine;
  FShowSelection := S.FShowSelection;
  FUltraFastRendering := S.FUltraFastRendering;
  FUseGradientArea := S.FUseGradientArea;
  FAreaGradientAlphaTop := S.FAreaGradientAlphaTop;
  FAreaGradientAlphaBottom := S.FAreaGradientAlphaBottom;
  FSplitAreaByZero := S.FSplitAreaByZero;
  FUseRoundedBars := S.FUseRoundedBars;
  FBarCornerRadius := S.FBarCornerRadius;
  FShowToolTip := S.FShowToolTip;
  FValueFormat := S.FValueFormat;
  FAnimateValueChanges := S.FAnimateValueChanges;
  FAnimationDuration := S.FAnimationDuration;
  FSparklinePadding := S.FSparklinePadding;
  FStrokeWidth := S.FStrokeWidth;
  FAccentColor := S.FAccentColor;
  FMutedColor := S.FMutedColor;
  FBorderColor := S.FBorderColor;
  FLineColor := S.FLineColor;
  FFillColor := S.FFillColor;
  FNegativeColor := S.FNegativeColor;
  FZeroLineColor := S.FZeroLineColor;
  FLastPointColor := S.FLastPointColor;
  FMinPointColor := S.FMinPointColor;
  FMaxPointColor := S.FMaxPointColor;
  FTargetLineColor := S.FTargetLineColor;
  FAverageLineColor := S.FAverageLineColor;
  FRangeBandColor := S.FRangeBandColor;
  FStartPointColor := S.FStartPointColor;
  FRisingColor := S.FRisingColor;
  FFallingColor := S.FFallingColor;
  FHoverLineColor := S.FHoverLineColor;
  FSelectionColor := S.FSelectionColor;
  FMarkerColor := S.FMarkerColor;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetStyle(const AValue: TSparklineRenderStyle);
begin
  if FStyle = AValue then Exit;
  FStyle := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetRangeMode(const AValue: TSparklineRangeMode);
begin
  if FRangeMode = AValue then Exit;
  FRangeMode := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetPerformanceMode(const AValue: TSparklinePerformanceMode);
begin
  if FPerformanceMode = AValue then Exit;
  FPerformanceMode := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetFixedRange(const AValue: TSparklineValueRange);
begin
  if (FFixedRange.Minimum = AValue.Minimum) and (FFixedRange.Maximum = AValue.Maximum) then Exit;
  FFixedRange := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetThemeInfluence(const AValue: Integer);
var V: Integer;
begin V := EnsureRange(AValue, 0, 100); if FThemeInfluence = V then Exit; FThemeInfluence := V; if Assigned(FOnChange) then FOnChange(Self) end;

procedure TSparklineOptions.SetBarGap(const AValue: Integer);
var V: Integer;
begin V := Max(0, AValue); if FBarGap = V then Exit; FBarGap := V; if Assigned(FOnChange) then FOnChange(Self) end;

procedure TSparklineOptions.SetThemeMode(const AValue: TSparklineThemeMode);
begin
  if FThemeMode = AValue then Exit;
  FThemeMode := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetAutoThemeFromParent(const AValue: Boolean);
begin
  if FAutoThemeFromParent = AValue then Exit;
  FAutoThemeFromParent := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetPaintBackground(const AValue: Boolean);
begin
  if FPaintBackground = AValue then Exit;
  FPaintBackground := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetShowBorder(const AValue: Boolean);
begin
  if FShowBorder = AValue then Exit;
  FShowBorder := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetShowArea(const AValue: Boolean);
begin
  if FShowArea = AValue then Exit;
  FShowArea := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetShowLastPoint(const AValue: Boolean);
begin
  if FShowLastPoint = AValue then Exit;
  FShowLastPoint := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetShowStartPoint(const AValue: Boolean);
begin
  if FShowStartPoint = AValue then Exit;
  FShowStartPoint := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetShowMinMaxPoints(const AValue: Boolean);
begin
  if FShowMinMaxPoints = AValue then Exit;
  FShowMinMaxPoints := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetShowMinMaxValueLabels(const AValue: Boolean);
begin
  if FShowMinMaxValueLabels = AValue then Exit;
  FShowMinMaxValueLabels := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetShowZeroLine(const AValue: Boolean);
begin
  if FShowZeroLine = AValue then Exit;
  FShowZeroLine := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetShowEmptyState(const AValue: Boolean);
begin
  if FShowEmptyState = AValue then Exit;
  FShowEmptyState := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetEmptyLineVisible(const AValue: Boolean);
begin
  if FEmptyLineVisible = AValue then Exit;
  FEmptyLineVisible := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetEmptyText(const AValue: string);
begin
  if FEmptyText = AValue then Exit;
  FEmptyText := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetShowTargetLine(const AValue: Boolean);
begin
  if FShowTargetLine = AValue then Exit;
  FShowTargetLine := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetTargetValue(const AValue: Double);
begin
  if not SparklineFinite(AValue) then Exit;
  if FTargetValue = AValue then Exit;
  FTargetValue := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetShowAverageLine(const AValue: Boolean);
begin
  if FShowAverageLine = AValue then Exit;
  FShowAverageLine := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetShowRangeBand(const AValue: Boolean);
begin
  if FShowRangeBand = AValue then Exit;
  FShowRangeBand := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetBandMinimum(const AValue: Double);
begin
  if not SparklineFinite(AValue) then Exit;
  if FBandMinimum = AValue then Exit;
  FBandMinimum := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetBandMaximum(const AValue: Double);
begin
  if not SparklineFinite(AValue) then Exit;
  if FBandMaximum = AValue then Exit;
  FBandMaximum := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetColorizeRisingFallingSegments(const AValue: Boolean);
begin
  if FColorizeRisingFallingSegments = AValue then Exit;
  FColorizeRisingFallingSegments := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetColorizeNegativeSegments(const AValue: Boolean);
begin
  if FColorizeNegativeSegments = AValue then Exit;
  FColorizeNegativeSegments := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetShowEndValueLabel(const AValue: Boolean);
begin
  if FShowEndValueLabel = AValue then Exit;
  FShowEndValueLabel := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetValueLabelWidth(const AValue: Integer);
begin
  if FValueLabelWidth = Max(0, AValue) then Exit;
  FValueLabelWidth := Max(0, AValue);
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetShowHoverLine(const AValue: Boolean);
begin
  if FShowHoverLine = AValue then Exit;
  FShowHoverLine := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetShowSelection(const AValue: Boolean);
begin
  if FShowSelection = AValue then Exit;
  FShowSelection := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetUltraFastRendering(const AValue: Boolean);
begin
  if FUltraFastRendering = AValue then Exit;
  FUltraFastRendering := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetUseGradientArea(const AValue: Boolean);
begin
  if FUseGradientArea = AValue then Exit;
  FUseGradientArea := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetAreaGradientAlphaTop(const AValue: Integer);
begin
  if FAreaGradientAlphaTop = EnsureRange(AValue, 0, 255) then Exit;
  FAreaGradientAlphaTop := EnsureRange(AValue, 0, 255);
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetAreaGradientAlphaBottom(const AValue: Integer);
begin
  if FAreaGradientAlphaBottom = EnsureRange(AValue, 0, 255) then Exit;
  FAreaGradientAlphaBottom := EnsureRange(AValue, 0, 255);
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetSplitAreaByZero(const AValue: Boolean);
begin
  if FSplitAreaByZero = AValue then Exit;
  FSplitAreaByZero := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetUseRoundedBars(const AValue: Boolean);
begin
  if FUseRoundedBars = AValue then Exit;
  FUseRoundedBars := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetBarCornerRadius(const AValue: Integer);
begin
  if FBarCornerRadius = Max(0, AValue) then Exit;
  FBarCornerRadius := Max(0, AValue);
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetShowToolTip(const AValue: Boolean);
begin
  if FShowToolTip = AValue then Exit;
  FShowToolTip := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetValueFormat(const AValue: string);
begin
  if FValueFormat = AValue then Exit;
  FValueFormat := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetAnimateValueChanges(const AValue: Boolean);
begin
  if FAnimateValueChanges = AValue then Exit;
  FAnimateValueChanges := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetAnimationDuration(const AValue: Integer);
begin
  if FAnimationDuration = Max(0, AValue) then Exit;
  FAnimationDuration := Max(0, AValue);
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetSparklinePadding(const AValue: Integer);
begin
  if FSparklinePadding = Max(0, AValue) then Exit;
  FSparklinePadding := Max(0, AValue);
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetStrokeWidth(const AValue: Single);
begin
  if not SparklineFinite(AValue) then Exit;
  if FStrokeWidth = Max(Single(0.1), AValue) then Exit;
  FStrokeWidth := Max(Single(0.1), AValue);
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetAccentColor(const AValue: TColor);
begin
  if FAccentColor = AValue then Exit;
  FAccentColor := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetMutedColor(const AValue: TColor);
begin
  if FMutedColor = AValue then Exit;
  FMutedColor := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetBorderColor(const AValue: TColor);
begin
  if FBorderColor = AValue then Exit;
  FBorderColor := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetLineColor(const AValue: TColor);
begin
  if FLineColor = AValue then Exit;
  FLineColor := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetFillColor(const AValue: TColor);
begin
  if FFillColor = AValue then Exit;
  FFillColor := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetNegativeColor(const AValue: TColor);
begin
  if FNegativeColor = AValue then Exit;
  FNegativeColor := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetZeroLineColor(const AValue: TColor);
begin
  if FZeroLineColor = AValue then Exit;
  FZeroLineColor := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetLastPointColor(const AValue: TColor);
begin
  if FLastPointColor = AValue then Exit;
  FLastPointColor := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetMinPointColor(const AValue: TColor);
begin
  if FMinPointColor = AValue then Exit;
  FMinPointColor := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetMaxPointColor(const AValue: TColor);
begin
  if FMaxPointColor = AValue then Exit;
  FMaxPointColor := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetTargetLineColor(const AValue: TColor);
begin
  if FTargetLineColor = AValue then Exit;
  FTargetLineColor := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetAverageLineColor(const AValue: TColor);
begin
  if FAverageLineColor = AValue then Exit;
  FAverageLineColor := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetRangeBandColor(const AValue: TColor);
begin
  if FRangeBandColor = AValue then Exit;
  FRangeBandColor := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetStartPointColor(const AValue: TColor);
begin
  if FStartPointColor = AValue then Exit;
  FStartPointColor := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetRisingColor(const AValue: TColor);
begin
  if FRisingColor = AValue then Exit;
  FRisingColor := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetFallingColor(const AValue: TColor);
begin
  if FFallingColor = AValue then Exit;
  FFallingColor := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetHoverLineColor(const AValue: TColor);
begin
  if FHoverLineColor = AValue then Exit;
  FHoverLineColor := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetSelectionColor(const AValue: TColor);
begin
  if FSelectionColor = AValue then Exit;
  FSelectionColor := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TSparklineOptions.SetMarkerColor(const AValue: TColor);
begin
  if FMarkerColor = AValue then Exit;
  FMarkerColor := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

constructor TSparklineReferenceLine.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FVisible := True;
  FValue := 0;
  FText := '';
  FColor := clNone;
  FDashStyle := sdsDash;
  FStrokeWidth := 1;
end;

procedure TSparklineReferenceLine.Assign(Source: TPersistent);
var S: TSparklineReferenceLine;
begin
  if not (Source is TSparklineReferenceLine) then begin inherited; Exit end;
  S := TSparklineReferenceLine(Source);
  FVisible := S.FVisible;
  FValue := S.FValue;
  FText := S.FText;
  FColor := S.FColor;
  FDashStyle := S.FDashStyle;
  FStrokeWidth := S.FStrokeWidth;
  Changed(False);
end;

procedure TSparklineReferenceLine.SetVisible(const AValue: Boolean);
begin
  if FVisible = AValue then Exit;
  FVisible := AValue; Changed(False);
end;

procedure TSparklineReferenceLine.SetValue(const AValue: Double);
begin
  if FValue = AValue then Exit;
  FValue := AValue; Changed(False);
end;

procedure TSparklineReferenceLine.SetText(const AValue: string);
begin
  if FText = AValue then Exit;
  FText := AValue; Changed(False);
end;

procedure TSparklineReferenceLine.SetColor(const AValue: TColor);
begin
  if FColor = AValue then Exit;
  FColor := AValue; Changed(False);
end;

procedure TSparklineReferenceLine.SetDashStyle(const AValue: TSparklineDashStyle);
begin
  if FDashStyle = AValue then Exit;
  FDashStyle := AValue; Changed(False);
end;

procedure TSparklineReferenceLine.SetStrokeWidth(const AValue: Single);
begin
  if FStrokeWidth = Max(Single(0.1), AValue) then Exit;
  FStrokeWidth := Max(Single(0.1), AValue); Changed(False);
end;

constructor TSparklineReferenceLineCollection.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TSparklineReferenceLine);
end;

function TSparklineReferenceLineCollection.Add: TSparklineReferenceLine;
begin
  Result := TSparklineReferenceLine(inherited Add);
end;

function TSparklineReferenceLineCollection.GetItem(Index: Integer): TSparklineReferenceLine;
begin
  Result := TSparklineReferenceLine(inherited Items[Index]);
end;

procedure TSparklineReferenceLineCollection.Update(Item: TCollectionItem);
begin
  inherited;
  if Assigned(FOnChange) then FOnChange(Self);
end;

constructor TSparklineThresholdBand.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FVisible := True;
  FMinimum := 0;
  FMaximum := 0;
  FColor := clNone;
  FAlpha := 32;
end;

procedure TSparklineThresholdBand.Assign(Source: TPersistent);
var S: TSparklineThresholdBand;
begin
  if not (Source is TSparklineThresholdBand) then begin inherited; Exit end;
  S := TSparklineThresholdBand(Source);
  FVisible := S.FVisible;
  FMinimum := S.FMinimum;
  FMaximum := S.FMaximum;
  FColor := S.FColor;
  FAlpha := S.FAlpha;
  Changed(False);
end;

procedure TSparklineThresholdBand.SetVisible(const AValue: Boolean);
begin
  if FVisible = AValue then Exit;
  FVisible := AValue; Changed(False);
end;

procedure TSparklineThresholdBand.SetMinimum(const AValue: Double);
begin
  if FMinimum = AValue then Exit;
  FMinimum := AValue; Changed(False);
end;

procedure TSparklineThresholdBand.SetMaximum(const AValue: Double);
begin
  if FMaximum = AValue then Exit;
  FMaximum := AValue; Changed(False);
end;

procedure TSparklineThresholdBand.SetColor(const AValue: TColor);
begin
  if FColor = AValue then Exit;
  FColor := AValue; Changed(False);
end;

procedure TSparklineThresholdBand.SetAlpha(const AValue: Integer);
begin
  if FAlpha = EnsureRange(AValue, 0, 255) then Exit;
  FAlpha := EnsureRange(AValue, 0, 255); Changed(False);
end;

constructor TSparklineThresholdBandCollection.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TSparklineThresholdBand);
end;

function TSparklineThresholdBandCollection.Add: TSparklineThresholdBand;
begin
  Result := TSparklineThresholdBand(inherited Add);
end;

function TSparklineThresholdBandCollection.GetItem(Index: Integer): TSparklineThresholdBand;
begin
  Result := TSparklineThresholdBand(inherited Items[Index]);
end;

procedure TSparklineThresholdBandCollection.Update(Item: TCollectionItem);
begin
  inherited;
  if Assigned(FOnChange) then FOnChange(Self);
end;

constructor TSparklineMarker.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FVisible := True;
  FPointIndex := -1;
  FText := '';
  FColor := clNone;
  FShape := smsCircle;
  FRadius := 3;
end;

procedure TSparklineMarker.Assign(Source: TPersistent);
var S: TSparklineMarker;
begin
  if not (Source is TSparklineMarker) then begin inherited; Exit end;
  S := TSparklineMarker(Source);
  FVisible := S.FVisible;
  FPointIndex := S.FPointIndex;
  FText := S.FText;
  FColor := S.FColor;
  FShape := S.FShape;
  FRadius := S.FRadius;
  Changed(False);
end;

procedure TSparklineMarker.SetVisible(const AValue: Boolean);
begin
  if FVisible = AValue then Exit;
  FVisible := AValue; Changed(False);
end;

procedure TSparklineMarker.SetPointIndex(const AValue: Integer);
begin
  if FPointIndex = AValue then Exit;
  FPointIndex := AValue; Changed(False);
end;

procedure TSparklineMarker.SetText(const AValue: string);
begin
  if FText = AValue then Exit;
  FText := AValue; Changed(False);
end;

procedure TSparklineMarker.SetColor(const AValue: TColor);
begin
  if FColor = AValue then Exit;
  FColor := AValue; Changed(False);
end;

procedure TSparklineMarker.SetShape(const AValue: TSparklineMarkerShape);
begin
  if FShape = AValue then Exit;
  FShape := AValue; Changed(False);
end;

procedure TSparklineMarker.SetRadius(const AValue: Single);
begin
  if FRadius = Max(Single(0.1), AValue) then Exit;
  FRadius := Max(Single(0.1), AValue); Changed(False);
end;

constructor TSparklineMarkerCollection.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TSparklineMarker);
end;

function TSparklineMarkerCollection.Add: TSparklineMarker;
begin
  Result := TSparklineMarker(inherited Add);
end;

function TSparklineMarkerCollection.GetItem(Index: Integer): TSparklineMarker;
begin
  Result := TSparklineMarker(inherited Items[Index]);
end;

procedure TSparklineMarkerCollection.Update(Item: TCollectionItem);
begin
  inherited;
  if Assigned(FOnChange) then FOnChange(Self);
end;

function TSparklineGeometry.HitTest(const ALocation: TPoint; const AMaxDistance: Single): Integer;
var I: Integer; D, Best: Double;
begin
  Result := -1;
  if not PlotBounds.Contains(ALocation) then Exit;
  Best := Sqr(AMaxDistance);
  for I := 0 to High(Points) do
  begin
    if (I < Length(Bars)) and Bars[I].Contains(TPointF.Create(ALocation.X, ALocation.Y)) then Exit(SourceIndices[I]);
    D := Sqr(Points[I].X - ALocation.X) + Sqr(Points[I].Y - ALocation.Y);
    if D <= Best then begin Best := D; Result := SourceIndices[I] end;
  end;
end;

end.

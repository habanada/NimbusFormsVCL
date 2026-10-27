{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Charts.StreamGraph.Types;

interface

uses System.Classes, System.SysUtils, System.Math, System.Types, NimbusForms.Theming.Types;

type
  TNimbusStreamBaselineMode = (nsbSilhouette, nsbWiggle, nsbZero, nsbExpand100);
  TNimbusStreamCurveMode = (nscSmooth, nscLinear, nscStep);
  TNimbusStreamSelectionMode = (nssNone, nssBand, nssSeries, nssTimeSlice);

  TNimbusStreamGraphOptions = class(TPersistent)
  private
    FBaselineMode: TNimbusStreamBaselineMode;
    FCurveMode: TNimbusStreamCurveMode;
    FSelectionMode: TNimbusStreamSelectionMode;
    FShowAxes: Boolean;
    FShowGrid: Boolean;
    FShowLegend: Boolean;
    FShowTitle: Boolean;
    FShowSubtitle: Boolean;
    FShowXLabels: Boolean;
    FShowYLabels: Boolean;
    FShowValues: Boolean;
    FShowBandLabels: Boolean;
    FShowHoverLine: Boolean;
    FShowFocusGlow: Boolean;
    FShowSelectionGlow: Boolean;
    FShowEndLabels: Boolean;
    FDimUnfocusedSeries: Boolean;
    FUseSoftHighlight: Boolean;
    FUseGlassSheen: Boolean;
    FClipToPlot: Boolean;
    FEnableSelection: Boolean;
    FEnableTimeSliceSelection: Boolean;
    FNormalizeToPercent: Boolean;
    FEnableRangeZoom: Boolean;
    FEnableDragRangeZoom: Boolean;
    FEnableMouseWheelZoom: Boolean;
    FEnablePan: Boolean;
    FShowZoomNavigator: Boolean;
    FShowZoomBadge: Boolean;
    FZoomStartIndex: Integer;
    FZoomEndIndex: Integer;
    FMouseWheelZoomFactor: Single;
    FFillOpacity: Single;
    FHoverOpacityBoost: Single;
    FUnfocusedOpacity: Single;
    FBandGap: Single;
    FLineWidth: Single;
    FSmoothTension: Single;
    FMinimumLabelBandHeight: Single;
    FMaxAxisLabelCount: Integer;
    FPadding: Integer;
    FValueFormat: string;
    FPercentFormat: string;
    FEmptyText: string;
    FOnChange: TNotifyEvent;
    procedure Changed;
    function GetIsZoomed: Boolean;
    procedure SetBaselineMode(const Value: TNimbusStreamBaselineMode);
    procedure SetCurveMode(const Value: TNimbusStreamCurveMode);
    procedure SetSelectionMode(const Value: TNimbusStreamSelectionMode);
    procedure SetShowAxes(const Value: Boolean);
    procedure SetShowGrid(const Value: Boolean);
    procedure SetShowLegend(const Value: Boolean);
    procedure SetShowTitle(const Value: Boolean);
    procedure SetShowSubtitle(const Value: Boolean);
    procedure SetShowXLabels(const Value: Boolean);
    procedure SetShowYLabels(const Value: Boolean);
    procedure SetShowValues(const Value: Boolean);
    procedure SetShowBandLabels(const Value: Boolean);
    procedure SetShowHoverLine(const Value: Boolean);
    procedure SetShowFocusGlow(const Value: Boolean);
    procedure SetShowSelectionGlow(const Value: Boolean);
    procedure SetShowEndLabels(const Value: Boolean);
    procedure SetDimUnfocusedSeries(const Value: Boolean);
    procedure SetUseSoftHighlight(const Value: Boolean);
    procedure SetUseGlassSheen(const Value: Boolean);
    procedure SetClipToPlot(const Value: Boolean);
    procedure SetEnableSelection(const Value: Boolean);
    procedure SetEnableTimeSliceSelection(const Value: Boolean);
    procedure SetNormalizeToPercent(const Value: Boolean);
    procedure SetEnableRangeZoom(const Value: Boolean);
    procedure SetEnableDragRangeZoom(const Value: Boolean);
    procedure SetEnableMouseWheelZoom(const Value: Boolean);
    procedure SetEnablePan(const Value: Boolean);
    procedure SetShowZoomNavigator(const Value: Boolean);
    procedure SetShowZoomBadge(const Value: Boolean);
    procedure SetZoomStartIndex(const Value: Integer);
    procedure SetZoomEndIndex(const Value: Integer);
    procedure SetMouseWheelZoomFactor(const Value: Single);
    procedure SetFillOpacity(const Value: Single);
    procedure SetHoverOpacityBoost(const Value: Single);
    procedure SetUnfocusedOpacity(const Value: Single);
    procedure SetBandGap(const Value: Single);
    procedure SetLineWidth(const Value: Single);
    procedure SetSmoothTension(const Value: Single);
    procedure SetMinimumLabelBandHeight(const Value: Single);
    procedure SetMaxAxisLabelCount(const Value: Integer);
    procedure SetPadding(const Value: Integer);
    procedure SetValueFormat(const Value: string);
    procedure SetPercentFormat(const Value: string);
    procedure SetEmptyText(const Value: string);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    procedure SetZoomRange(const StartIndex, EndIndex: Integer);
    procedure ResetZoom;
    property IsZoomed: Boolean read GetIsZoomed;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property BaselineMode: TNimbusStreamBaselineMode read FBaselineMode write SetBaselineMode default nsbSilhouette;
    property CurveMode: TNimbusStreamCurveMode read FCurveMode write SetCurveMode default nscSmooth;
    property SelectionMode: TNimbusStreamSelectionMode read FSelectionMode write SetSelectionMode default nssBand;
    property ShowAxes: Boolean read FShowAxes write SetShowAxes default True;
    property ShowGrid: Boolean read FShowGrid write SetShowGrid default True;
    property ShowLegend: Boolean read FShowLegend write SetShowLegend default True;
    property ShowTitle: Boolean read FShowTitle write SetShowTitle default True;
    property ShowSubtitle: Boolean read FShowSubtitle write SetShowSubtitle default True;
    property ShowXLabels: Boolean read FShowXLabels write SetShowXLabels default True;
    property ShowYLabels: Boolean read FShowYLabels write SetShowYLabels default False;
    property ShowValues: Boolean read FShowValues write SetShowValues default False;
    property ShowBandLabels: Boolean read FShowBandLabels write SetShowBandLabels default True;
    property ShowHoverLine: Boolean read FShowHoverLine write SetShowHoverLine default True;
    property ShowFocusGlow: Boolean read FShowFocusGlow write SetShowFocusGlow default True;
    property ShowSelectionGlow: Boolean read FShowSelectionGlow write SetShowSelectionGlow default True;
    property ShowEndLabels: Boolean read FShowEndLabels write SetShowEndLabels default True;
    property DimUnfocusedSeries: Boolean read FDimUnfocusedSeries write SetDimUnfocusedSeries default True;
    property UseSoftHighlight: Boolean read FUseSoftHighlight write SetUseSoftHighlight default True;
    property UseGlassSheen: Boolean read FUseGlassSheen write SetUseGlassSheen default True;
    property ClipToPlot: Boolean read FClipToPlot write SetClipToPlot default True;
    property EnableSelection: Boolean read FEnableSelection write SetEnableSelection default True;
    property EnableTimeSliceSelection: Boolean read FEnableTimeSliceSelection write SetEnableTimeSliceSelection default True;
    property NormalizeToPercent: Boolean read FNormalizeToPercent write SetNormalizeToPercent default False;
    property EnableRangeZoom: Boolean read FEnableRangeZoom write SetEnableRangeZoom default True;
    property EnableDragRangeZoom: Boolean read FEnableDragRangeZoom write SetEnableDragRangeZoom default True;
    property EnableMouseWheelZoom: Boolean read FEnableMouseWheelZoom write SetEnableMouseWheelZoom default True;
    property EnablePan: Boolean read FEnablePan write SetEnablePan default True;
    property ShowZoomNavigator: Boolean read FShowZoomNavigator write SetShowZoomNavigator default True;
    property ShowZoomBadge: Boolean read FShowZoomBadge write SetShowZoomBadge default True;
    property ZoomStartIndex: Integer read FZoomStartIndex write SetZoomStartIndex default -1;
    property ZoomEndIndex: Integer read FZoomEndIndex write SetZoomEndIndex default -1;
    property MouseWheelZoomFactor: Single read FMouseWheelZoomFactor write SetMouseWheelZoomFactor;
    property FillOpacity: Single read FFillOpacity write SetFillOpacity;
    property HoverOpacityBoost: Single read FHoverOpacityBoost write SetHoverOpacityBoost;
    property UnfocusedOpacity: Single read FUnfocusedOpacity write SetUnfocusedOpacity;
    property BandGap: Single read FBandGap write SetBandGap;
    property LineWidth: Single read FLineWidth write SetLineWidth;
    property SmoothTension: Single read FSmoothTension write SetSmoothTension;
    property MinimumLabelBandHeight: Single read FMinimumLabelBandHeight write SetMinimumLabelBandHeight;
    property MaxAxisLabelCount: Integer read FMaxAxisLabelCount write SetMaxAxisLabelCount default 9;
    property Padding: Integer read FPadding write SetPadding default 18;
    property ValueFormat: string read FValueFormat write SetValueFormat;
    property PercentFormat: string read FPercentFormat write SetPercentFormat;
    property EmptyText: string read FEmptyText write SetEmptyText;
  end;

  TNimbusStreamBandInfo = record
    SeriesIndex, PointIndex, CategoryIndex: Integer;
    Tag: NativeInt;
    SeriesName, Category, ToolTipText: string;
    XValue, Value, RawValue, Total, RawTotal, Share, LowerValue, UpperValue: Double;
    CenterPoint: TPointF;
    Bounds: TRect;
    Color: TThemeColor;
  end;

  TNimbusStreamBandGeometry = record
    SeriesIndex: Integer;
    Color: TThemeColor;
    Samples: TArray<TNimbusStreamBandInfo>;
    Outline, Polygon, Sheen: TArray<TPointF>;
  end;

  TNimbusStreamGeometry = record
    FullCategories, Categories: TArray<string>;
    FirstIndex, LastIndex: Integer;
    Totals, Baseline: TArray<Double>;
    Bands: TArray<TNimbusStreamBandGeometry>;
  end;

implementation

procedure TNimbusStreamGraphOptions.Changed;
begin if Assigned(FOnChange) then FOnChange(Self) end;

constructor TNimbusStreamGraphOptions.Create;
begin
  inherited Create;
  FBaselineMode := nsbSilhouette;
  FCurveMode := nscSmooth;
  FSelectionMode := nssBand;
  FShowAxes := True;
  FShowGrid := True;
  FShowLegend := True;
  FShowTitle := True;
  FShowSubtitle := True;
  FShowXLabels := True;
  FShowYLabels := False;
  FShowValues := False;
  FShowBandLabels := True;
  FShowHoverLine := True;
  FShowFocusGlow := True;
  FShowSelectionGlow := True;
  FShowEndLabels := True;
  FDimUnfocusedSeries := True;
  FUseSoftHighlight := True;
  FUseGlassSheen := True;
  FClipToPlot := True;
  FEnableSelection := True;
  FEnableTimeSliceSelection := True;
  FNormalizeToPercent := False;
  FEnableRangeZoom := True;
  FEnableDragRangeZoom := True;
  FEnableMouseWheelZoom := True;
  FEnablePan := True;
  FShowZoomNavigator := True;
  FShowZoomBadge := True;
  FZoomStartIndex := -1;
  FZoomEndIndex := -1;
  FMouseWheelZoomFactor := 0.72;
  FFillOpacity := 0.86;
  FHoverOpacityBoost := 0.12;
  FUnfocusedOpacity := 0.24;
  FBandGap := 1.2;
  FLineWidth := 1.0;
  FSmoothTension := 0.45;
  FMinimumLabelBandHeight := 18;
  FMaxAxisLabelCount := 9;
  FPadding := 18;
  FValueFormat := '0.##';
  FPercentFormat := '0.#%';
  FEmptyText := 'No streamgraph data.';
end;

procedure TNimbusStreamGraphOptions.Assign(Source: TPersistent);
var S: TNimbusStreamGraphOptions;
begin
  if not (Source is TNimbusStreamGraphOptions) then begin inherited; Exit end; S := TNimbusStreamGraphOptions(Source);
  FBaselineMode := S.FBaselineMode;
  FCurveMode := S.FCurveMode;
  FSelectionMode := S.FSelectionMode;
  FShowAxes := S.FShowAxes;
  FShowGrid := S.FShowGrid;
  FShowLegend := S.FShowLegend;
  FShowTitle := S.FShowTitle;
  FShowSubtitle := S.FShowSubtitle;
  FShowXLabels := S.FShowXLabels;
  FShowYLabels := S.FShowYLabels;
  FShowValues := S.FShowValues;
  FShowBandLabels := S.FShowBandLabels;
  FShowHoverLine := S.FShowHoverLine;
  FShowFocusGlow := S.FShowFocusGlow;
  FShowSelectionGlow := S.FShowSelectionGlow;
  FShowEndLabels := S.FShowEndLabels;
  FDimUnfocusedSeries := S.FDimUnfocusedSeries;
  FUseSoftHighlight := S.FUseSoftHighlight;
  FUseGlassSheen := S.FUseGlassSheen;
  FClipToPlot := S.FClipToPlot;
  FEnableSelection := S.FEnableSelection;
  FEnableTimeSliceSelection := S.FEnableTimeSliceSelection;
  FNormalizeToPercent := S.FNormalizeToPercent;
  FEnableRangeZoom := S.FEnableRangeZoom;
  FEnableDragRangeZoom := S.FEnableDragRangeZoom;
  FEnableMouseWheelZoom := S.FEnableMouseWheelZoom;
  FEnablePan := S.FEnablePan;
  FShowZoomNavigator := S.FShowZoomNavigator;
  FShowZoomBadge := S.FShowZoomBadge;
  FZoomStartIndex := S.FZoomStartIndex;
  FZoomEndIndex := S.FZoomEndIndex;
  FMouseWheelZoomFactor := S.FMouseWheelZoomFactor;
  FFillOpacity := S.FFillOpacity;
  FHoverOpacityBoost := S.FHoverOpacityBoost;
  FUnfocusedOpacity := S.FUnfocusedOpacity;
  FBandGap := S.FBandGap;
  FLineWidth := S.FLineWidth;
  FSmoothTension := S.FSmoothTension;
  FMinimumLabelBandHeight := S.FMinimumLabelBandHeight;
  FMaxAxisLabelCount := S.FMaxAxisLabelCount;
  FPadding := S.FPadding;
  FValueFormat := S.FValueFormat;
  FPercentFormat := S.FPercentFormat;
  FEmptyText := S.FEmptyText;
  Changed;
end;

function TNimbusStreamGraphOptions.GetIsZoomed: Boolean;
begin Result := (FZoomStartIndex >= 0) and (FZoomEndIndex >= FZoomStartIndex) end;

procedure TNimbusStreamGraphOptions.SetZoomRange(const StartIndex, EndIndex: Integer);
var First, Last: Integer;
begin
  First := Max(0, Min(StartIndex, EndIndex)); Last := Max(First, Max(StartIndex, EndIndex));
  if (FZoomStartIndex = First) and (FZoomEndIndex = Last) then Exit; FZoomStartIndex := First; FZoomEndIndex := Last; Changed;
end;

procedure TNimbusStreamGraphOptions.ResetZoom;
begin if (FZoomStartIndex = -1) and (FZoomEndIndex = -1) then Exit; FZoomStartIndex := -1; FZoomEndIndex := -1; Changed end;

procedure TNimbusStreamGraphOptions.SetBaselineMode(const Value: TNimbusStreamBaselineMode);
begin if FBaselineMode = Value then Exit; FBaselineMode := Value; Changed end;

procedure TNimbusStreamGraphOptions.SetCurveMode(const Value: TNimbusStreamCurveMode);
begin if FCurveMode = Value then Exit; FCurveMode := Value; Changed end;

procedure TNimbusStreamGraphOptions.SetSelectionMode(const Value: TNimbusStreamSelectionMode);
begin if FSelectionMode = Value then Exit; FSelectionMode := Value; Changed end;

procedure TNimbusStreamGraphOptions.SetShowAxes(const Value: Boolean);
begin if FShowAxes = Value then Exit; FShowAxes := Value; Changed end;

procedure TNimbusStreamGraphOptions.SetShowGrid(const Value: Boolean);
begin if FShowGrid = Value then Exit; FShowGrid := Value; Changed end;

procedure TNimbusStreamGraphOptions.SetShowLegend(const Value: Boolean);
begin if FShowLegend = Value then Exit; FShowLegend := Value; Changed end;

procedure TNimbusStreamGraphOptions.SetShowTitle(const Value: Boolean);
begin if FShowTitle = Value then Exit; FShowTitle := Value; Changed end;

procedure TNimbusStreamGraphOptions.SetShowSubtitle(const Value: Boolean);
begin if FShowSubtitle = Value then Exit; FShowSubtitle := Value; Changed end;

procedure TNimbusStreamGraphOptions.SetShowXLabels(const Value: Boolean);
begin if FShowXLabels = Value then Exit; FShowXLabels := Value; Changed end;

procedure TNimbusStreamGraphOptions.SetShowYLabels(const Value: Boolean);
begin if FShowYLabels = Value then Exit; FShowYLabels := Value; Changed end;

procedure TNimbusStreamGraphOptions.SetShowValues(const Value: Boolean);
begin if FShowValues = Value then Exit; FShowValues := Value; Changed end;

procedure TNimbusStreamGraphOptions.SetShowBandLabels(const Value: Boolean);
begin if FShowBandLabels = Value then Exit; FShowBandLabels := Value; Changed end;

procedure TNimbusStreamGraphOptions.SetShowHoverLine(const Value: Boolean);
begin if FShowHoverLine = Value then Exit; FShowHoverLine := Value; Changed end;

procedure TNimbusStreamGraphOptions.SetShowFocusGlow(const Value: Boolean);
begin if FShowFocusGlow = Value then Exit; FShowFocusGlow := Value; Changed end;

procedure TNimbusStreamGraphOptions.SetShowSelectionGlow(const Value: Boolean);
begin if FShowSelectionGlow = Value then Exit; FShowSelectionGlow := Value; Changed end;

procedure TNimbusStreamGraphOptions.SetShowEndLabels(const Value: Boolean);
begin if FShowEndLabels = Value then Exit; FShowEndLabels := Value; Changed end;

procedure TNimbusStreamGraphOptions.SetDimUnfocusedSeries(const Value: Boolean);
begin if FDimUnfocusedSeries = Value then Exit; FDimUnfocusedSeries := Value; Changed end;

procedure TNimbusStreamGraphOptions.SetUseSoftHighlight(const Value: Boolean);
begin if FUseSoftHighlight = Value then Exit; FUseSoftHighlight := Value; Changed end;

procedure TNimbusStreamGraphOptions.SetUseGlassSheen(const Value: Boolean);
begin if FUseGlassSheen = Value then Exit; FUseGlassSheen := Value; Changed end;

procedure TNimbusStreamGraphOptions.SetClipToPlot(const Value: Boolean);
begin if FClipToPlot = Value then Exit; FClipToPlot := Value; Changed end;

procedure TNimbusStreamGraphOptions.SetEnableSelection(const Value: Boolean);
begin if FEnableSelection = Value then Exit; FEnableSelection := Value; Changed end;

procedure TNimbusStreamGraphOptions.SetEnableTimeSliceSelection(const Value: Boolean);
begin if FEnableTimeSliceSelection = Value then Exit; FEnableTimeSliceSelection := Value; Changed end;

procedure TNimbusStreamGraphOptions.SetNormalizeToPercent(const Value: Boolean);
begin if FNormalizeToPercent = Value then Exit; FNormalizeToPercent := Value; Changed end;

procedure TNimbusStreamGraphOptions.SetEnableRangeZoom(const Value: Boolean);
begin if FEnableRangeZoom = Value then Exit; FEnableRangeZoom := Value; Changed end;

procedure TNimbusStreamGraphOptions.SetEnableDragRangeZoom(const Value: Boolean);
begin if FEnableDragRangeZoom = Value then Exit; FEnableDragRangeZoom := Value; Changed end;

procedure TNimbusStreamGraphOptions.SetEnableMouseWheelZoom(const Value: Boolean);
begin if FEnableMouseWheelZoom = Value then Exit; FEnableMouseWheelZoom := Value; Changed end;

procedure TNimbusStreamGraphOptions.SetEnablePan(const Value: Boolean);
begin if FEnablePan = Value then Exit; FEnablePan := Value; Changed end;

procedure TNimbusStreamGraphOptions.SetShowZoomNavigator(const Value: Boolean);
begin if FShowZoomNavigator = Value then Exit; FShowZoomNavigator := Value; Changed end;

procedure TNimbusStreamGraphOptions.SetShowZoomBadge(const Value: Boolean);
begin if FShowZoomBadge = Value then Exit; FShowZoomBadge := Value; Changed end;

procedure TNimbusStreamGraphOptions.SetZoomStartIndex(const Value: Integer);
var V: Integer;
begin
  V := Max(-1, Value); if FZoomStartIndex = V then Exit; FZoomStartIndex := V; Changed;
end;

procedure TNimbusStreamGraphOptions.SetZoomEndIndex(const Value: Integer);
var V: Integer;
begin
  V := Max(-1, Value); if FZoomEndIndex = V then Exit; FZoomEndIndex := V; Changed;
end;

procedure TNimbusStreamGraphOptions.SetMouseWheelZoomFactor(const Value: Single);
var V: Single;
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
  V := EnsureRange(Value, 0.25, 0.95); if FMouseWheelZoomFactor = V then Exit; FMouseWheelZoomFactor := V; Changed;
end;

procedure TNimbusStreamGraphOptions.SetFillOpacity(const Value: Single);
var V: Single;
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
  V := EnsureRange(Value, 0.05, 1.0); if FFillOpacity = V then Exit; FFillOpacity := V; Changed;
end;

procedure TNimbusStreamGraphOptions.SetHoverOpacityBoost(const Value: Single);
var V: Single;
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
  V := EnsureRange(Value, 0.0, 0.5); if FHoverOpacityBoost = V then Exit; FHoverOpacityBoost := V; Changed;
end;

procedure TNimbusStreamGraphOptions.SetUnfocusedOpacity(const Value: Single);
var V: Single;
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
  V := EnsureRange(Value, 0.05, 1.0); if FUnfocusedOpacity = V then Exit; FUnfocusedOpacity := V; Changed;
end;

procedure TNimbusStreamGraphOptions.SetBandGap(const Value: Single);
var V: Single;
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
  V := Max(0.0, Value); if FBandGap = V then Exit; FBandGap := V; Changed;
end;

procedure TNimbusStreamGraphOptions.SetLineWidth(const Value: Single);
var V: Single;
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
  V := Max(0.5, Value); if FLineWidth = V then Exit; FLineWidth := V; Changed;
end;

procedure TNimbusStreamGraphOptions.SetSmoothTension(const Value: Single);
var V: Single;
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
  V := EnsureRange(Value, 0.05, 1.0); if FSmoothTension = V then Exit; FSmoothTension := V; Changed;
end;

procedure TNimbusStreamGraphOptions.SetMinimumLabelBandHeight(const Value: Single);
var V: Single;
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
  V := Max(4.0, Value); if FMinimumLabelBandHeight = V then Exit; FMinimumLabelBandHeight := V; Changed;
end;

procedure TNimbusStreamGraphOptions.SetMaxAxisLabelCount(const Value: Integer);
var V: Integer;
begin
  V := Max(2, Value); if FMaxAxisLabelCount = V then Exit; FMaxAxisLabelCount := V; Changed;
end;

procedure TNimbusStreamGraphOptions.SetPadding(const Value: Integer);
var V: Integer;
begin
  V := Max(0, Value); if FPadding = V then Exit; FPadding := V; Changed;
end;

procedure TNimbusStreamGraphOptions.SetValueFormat(const Value: string);
begin if FValueFormat = Value then Exit; FValueFormat := Value; Changed end;

procedure TNimbusStreamGraphOptions.SetPercentFormat(const Value: string);
begin if FPercentFormat = Value then Exit; FPercentFormat := Value; Changed end;

procedure TNimbusStreamGraphOptions.SetEmptyText(const Value: string);
begin if FEmptyText = Value then Exit; FEmptyText := Value; Changed end;

end.

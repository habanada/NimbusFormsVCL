{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Charts.Ridgeline.Types;

interface

uses System.Classes, System.SysUtils, System.Types, System.Math, NimbusForms.Theming.Types;

type
  TNimbusRidgelineScaleMode = (nrsGlobal, nrsPerRidge, nrsPercent);
  TNimbusRidgelineSortMode = (nroNone, nroNameAscending, nroNameDescending, nroPeakAscending, nroPeakDescending, nroTotalAscending, nroTotalDescending);
  TNimbusRidgelineCurveMode = (nrcSmooth, nrcLinear, nrcStep);
  TNimbusRidgelineSelectionMode = (nrmRidge, nrmPoint, nrmRidgeAndPoint);

  TNimbusRidgelineOptions = class(TPersistent)
  private
    FScaleMode: TNimbusRidgelineScaleMode;
    FSortMode: TNimbusRidgelineSortMode;
    FCurveMode: TNimbusRidgelineCurveMode;
    FSelectionMode: TNimbusRidgelineSelectionMode;
    FShowGrid: Boolean;
    FShowXAxis: Boolean;
    FShowRidgeLabels: Boolean;
    FShowEndLabels: Boolean;
    FShowValues: Boolean;
    FShowMeanMarker: Boolean;
    FShowMedianMarker: Boolean;
    FShowPeakMarker: Boolean;
    FEnableSelection: Boolean;
    FEnableRangeZoom: Boolean;
    FEnableMouseWheelZoom: Boolean;
    FEnablePan: Boolean;
    FShowZoomBadge: Boolean;
    FShowZoomNavigator: Boolean;
    FOverlap: Single;
    FRidgeHeight: Single;
    FFillOpacity: Single;
    FLineWidth: Single;
    FMarkerSize: Single;
    FAxisHeight: Single;
    FZoomStartIndex: Integer;
    FZoomEndIndex: Integer;
    FSelectedSeriesIndex: Integer;
    FSelectedPointIndex: Integer;
    FValueFormat: string;
    FPercentFormat: string;
    FOnChange: TNotifyEvent;
    procedure Changed;
    procedure SetScaleMode(const AValue: TNimbusRidgelineScaleMode);
    procedure SetSortMode(const AValue: TNimbusRidgelineSortMode);
    procedure SetCurveMode(const AValue: TNimbusRidgelineCurveMode);
    procedure SetSelectionMode(const AValue: TNimbusRidgelineSelectionMode);
    procedure SetShowGrid(const AValue: Boolean);
    procedure SetShowXAxis(const AValue: Boolean);
    procedure SetShowRidgeLabels(const AValue: Boolean);
    procedure SetShowEndLabels(const AValue: Boolean);
    procedure SetShowValues(const AValue: Boolean);
    procedure SetShowMeanMarker(const AValue: Boolean);
    procedure SetShowMedianMarker(const AValue: Boolean);
    procedure SetShowPeakMarker(const AValue: Boolean);
    procedure SetEnableSelection(const AValue: Boolean);
    procedure SetEnableRangeZoom(const AValue: Boolean);
    procedure SetEnableMouseWheelZoom(const AValue: Boolean);
    procedure SetEnablePan(const AValue: Boolean);
    procedure SetShowZoomBadge(const AValue: Boolean);
    procedure SetShowZoomNavigator(const AValue: Boolean);
    procedure SetOverlap(const AValue: Single);
    procedure SetRidgeHeight(const AValue: Single);
    procedure SetFillOpacity(const AValue: Single);
    procedure SetLineWidth(const AValue: Single);
    procedure SetMarkerSize(const AValue: Single);
    procedure SetAxisHeight(const AValue: Single);
    procedure SetZoomStartIndex(const AValue: Integer);
    procedure SetZoomEndIndex(const AValue: Integer);
    procedure SetSelectedSeriesIndex(const AValue: Integer);
    procedure SetSelectedPointIndex(const AValue: Integer);
    procedure SetValueFormat(const AValue: string);
    procedure SetPercentFormat(const AValue: string);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    procedure SetZoomRange(const StartIndex, EndIndex: Integer);
    procedure ResetZoom;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property ScaleMode: TNimbusRidgelineScaleMode read FScaleMode write SetScaleMode default nrsGlobal;
    property SortMode: TNimbusRidgelineSortMode read FSortMode write SetSortMode default nroNone;
    property CurveMode: TNimbusRidgelineCurveMode read FCurveMode write SetCurveMode default nrcSmooth;
    property SelectionMode: TNimbusRidgelineSelectionMode read FSelectionMode write SetSelectionMode default nrmRidgeAndPoint;
    property ShowGrid: Boolean read FShowGrid write SetShowGrid default True;
    property ShowXAxis: Boolean read FShowXAxis write SetShowXAxis default True;
    property ShowRidgeLabels: Boolean read FShowRidgeLabels write SetShowRidgeLabels default True;
    property ShowEndLabels: Boolean read FShowEndLabels write SetShowEndLabels default True;
    property ShowValues: Boolean read FShowValues write SetShowValues default False;
    property ShowMeanMarker: Boolean read FShowMeanMarker write SetShowMeanMarker default True;
    property ShowMedianMarker: Boolean read FShowMedianMarker write SetShowMedianMarker default False;
    property ShowPeakMarker: Boolean read FShowPeakMarker write SetShowPeakMarker default True;
    property EnableSelection: Boolean read FEnableSelection write SetEnableSelection default True;
    property EnableRangeZoom: Boolean read FEnableRangeZoom write SetEnableRangeZoom default True;
    property EnableMouseWheelZoom: Boolean read FEnableMouseWheelZoom write SetEnableMouseWheelZoom default True;
    property EnablePan: Boolean read FEnablePan write SetEnablePan default True;
    property ShowZoomBadge: Boolean read FShowZoomBadge write SetShowZoomBadge default True;
    property ShowZoomNavigator: Boolean read FShowZoomNavigator write SetShowZoomNavigator default True;
    property Overlap: Single read FOverlap write SetOverlap;
    property RidgeHeight: Single read FRidgeHeight write SetRidgeHeight;
    property FillOpacity: Single read FFillOpacity write SetFillOpacity;
    property LineWidth: Single read FLineWidth write SetLineWidth;
    property MarkerSize: Single read FMarkerSize write SetMarkerSize;
    property AxisHeight: Single read FAxisHeight write SetAxisHeight;
    property ZoomStartIndex: Integer read FZoomStartIndex write SetZoomStartIndex default -1;
    property ZoomEndIndex: Integer read FZoomEndIndex write SetZoomEndIndex default -1;
    property SelectedSeriesIndex: Integer read FSelectedSeriesIndex write SetSelectedSeriesIndex default -1;
    property SelectedPointIndex: Integer read FSelectedPointIndex write SetSelectedPointIndex default -1;
    property ValueFormat: string read FValueFormat write SetValueFormat;
    property PercentFormat: string read FPercentFormat write SetPercentFormat;
  end;

  TNimbusRidgelinePointInfo = record
    SeriesIndex, PointIndex: Integer;
    SeriesName, LabelText, ToolTipText: string;
    XValue, YValue, NormalizedValue: Double;
    Bounds: TRect;
    Location: TPointF;
    Color: TThemeColor;
  end;

  TNimbusRidgelineRidgeInfo = record
    SeriesIndex: Integer;
    SeriesName: string;
    Bounds, HitBounds: TRect;
    Total, Peak, Mean, Median: Double;
    Color: TThemeColor;
    Points: TArray<TNimbusRidgelinePointInfo>;
    Outline, Polygon: TArray<TPointF>;
  end;

function NimbusRidgelineCurve(const Points: TArray<TPointF>; const Mode: TNimbusRidgelineCurveMode): TArray<TPointF>;

implementation

procedure TNimbusRidgelineOptions.Changed;
begin if Assigned(FOnChange) then FOnChange(Self) end;

constructor TNimbusRidgelineOptions.Create;
begin
  inherited Create;
  FScaleMode := nrsGlobal;
  FSortMode := nroNone;
  FCurveMode := nrcSmooth;
  FSelectionMode := nrmRidgeAndPoint;
  FShowGrid := True;
  FShowXAxis := True;
  FShowRidgeLabels := True;
  FShowEndLabels := True;
  FShowValues := False;
  FShowMeanMarker := True;
  FShowMedianMarker := False;
  FShowPeakMarker := True;
  FEnableSelection := True;
  FEnableRangeZoom := True;
  FEnableMouseWheelZoom := True;
  FEnablePan := True;
  FShowZoomBadge := True;
  FShowZoomNavigator := True;
  FOverlap := 0.58;
  FRidgeHeight := 74;
  FFillOpacity := 0.78;
  FLineWidth := 1.5;
  FMarkerSize := 5;
  FAxisHeight := 30;
  FZoomStartIndex := -1;
  FZoomEndIndex := -1;
  FSelectedSeriesIndex := -1;
  FSelectedPointIndex := -1;
  FValueFormat := '0.#';
  FPercentFormat := '0.#%';
end;

procedure TNimbusRidgelineOptions.Assign(Source: TPersistent);
var S: TNimbusRidgelineOptions;
begin
  if not (Source is TNimbusRidgelineOptions) then begin inherited; Exit end; S := TNimbusRidgelineOptions(Source);
  FScaleMode := S.FScaleMode;
  FSortMode := S.FSortMode;
  FCurveMode := S.FCurveMode;
  FSelectionMode := S.FSelectionMode;
  FShowGrid := S.FShowGrid;
  FShowXAxis := S.FShowXAxis;
  FShowRidgeLabels := S.FShowRidgeLabels;
  FShowEndLabels := S.FShowEndLabels;
  FShowValues := S.FShowValues;
  FShowMeanMarker := S.FShowMeanMarker;
  FShowMedianMarker := S.FShowMedianMarker;
  FShowPeakMarker := S.FShowPeakMarker;
  FEnableSelection := S.FEnableSelection;
  FEnableRangeZoom := S.FEnableRangeZoom;
  FEnableMouseWheelZoom := S.FEnableMouseWheelZoom;
  FEnablePan := S.FEnablePan;
  FShowZoomBadge := S.FShowZoomBadge;
  FShowZoomNavigator := S.FShowZoomNavigator;
  FOverlap := S.FOverlap;
  FRidgeHeight := S.FRidgeHeight;
  FFillOpacity := S.FFillOpacity;
  FLineWidth := S.FLineWidth;
  FMarkerSize := S.FMarkerSize;
  FAxisHeight := S.FAxisHeight;
  FZoomStartIndex := S.FZoomStartIndex;
  FZoomEndIndex := S.FZoomEndIndex;
  FSelectedSeriesIndex := S.FSelectedSeriesIndex;
  FSelectedPointIndex := S.FSelectedPointIndex;
  FValueFormat := S.FValueFormat;
  FPercentFormat := S.FPercentFormat;
  Changed;
end;

procedure TNimbusRidgelineOptions.SetScaleMode(const AValue: TNimbusRidgelineScaleMode);
begin if FScaleMode = AValue then Exit; FScaleMode := AValue; Changed end;

procedure TNimbusRidgelineOptions.SetSortMode(const AValue: TNimbusRidgelineSortMode);
begin if FSortMode = AValue then Exit; FSortMode := AValue; Changed end;

procedure TNimbusRidgelineOptions.SetCurveMode(const AValue: TNimbusRidgelineCurveMode);
begin if FCurveMode = AValue then Exit; FCurveMode := AValue; Changed end;

procedure TNimbusRidgelineOptions.SetSelectionMode(const AValue: TNimbusRidgelineSelectionMode);
begin if FSelectionMode = AValue then Exit; FSelectionMode := AValue; Changed end;

procedure TNimbusRidgelineOptions.SetShowGrid(const AValue: Boolean);
begin if FShowGrid = AValue then Exit; FShowGrid := AValue; Changed end;

procedure TNimbusRidgelineOptions.SetShowXAxis(const AValue: Boolean);
begin if FShowXAxis = AValue then Exit; FShowXAxis := AValue; Changed end;

procedure TNimbusRidgelineOptions.SetShowRidgeLabels(const AValue: Boolean);
begin if FShowRidgeLabels = AValue then Exit; FShowRidgeLabels := AValue; Changed end;

procedure TNimbusRidgelineOptions.SetShowEndLabels(const AValue: Boolean);
begin if FShowEndLabels = AValue then Exit; FShowEndLabels := AValue; Changed end;

procedure TNimbusRidgelineOptions.SetShowValues(const AValue: Boolean);
begin if FShowValues = AValue then Exit; FShowValues := AValue; Changed end;

procedure TNimbusRidgelineOptions.SetShowMeanMarker(const AValue: Boolean);
begin if FShowMeanMarker = AValue then Exit; FShowMeanMarker := AValue; Changed end;

procedure TNimbusRidgelineOptions.SetShowMedianMarker(const AValue: Boolean);
begin if FShowMedianMarker = AValue then Exit; FShowMedianMarker := AValue; Changed end;

procedure TNimbusRidgelineOptions.SetShowPeakMarker(const AValue: Boolean);
begin if FShowPeakMarker = AValue then Exit; FShowPeakMarker := AValue; Changed end;

procedure TNimbusRidgelineOptions.SetEnableSelection(const AValue: Boolean);
begin if FEnableSelection = AValue then Exit; FEnableSelection := AValue; Changed end;

procedure TNimbusRidgelineOptions.SetEnableRangeZoom(const AValue: Boolean);
begin if FEnableRangeZoom = AValue then Exit; FEnableRangeZoom := AValue; Changed end;

procedure TNimbusRidgelineOptions.SetEnableMouseWheelZoom(const AValue: Boolean);
begin if FEnableMouseWheelZoom = AValue then Exit; FEnableMouseWheelZoom := AValue; Changed end;

procedure TNimbusRidgelineOptions.SetEnablePan(const AValue: Boolean);
begin if FEnablePan = AValue then Exit; FEnablePan := AValue; Changed end;

procedure TNimbusRidgelineOptions.SetShowZoomBadge(const AValue: Boolean);
begin if FShowZoomBadge = AValue then Exit; FShowZoomBadge := AValue; Changed end;

procedure TNimbusRidgelineOptions.SetShowZoomNavigator(const AValue: Boolean);
begin if FShowZoomNavigator = AValue then Exit; FShowZoomNavigator := AValue; Changed end;

procedure TNimbusRidgelineOptions.SetOverlap(const AValue: Single);
var Value: Single;
begin if IsNan(AValue) or IsInfinite(AValue) then Exit; Value := EnsureRange(AValue, Single(0), Single(0.92)); if FOverlap = Value then Exit; FOverlap := Value; Changed end;

procedure TNimbusRidgelineOptions.SetRidgeHeight(const AValue: Single);
var Value: Single;
begin if IsNan(AValue) or IsInfinite(AValue) then Exit; Value := Max(Single(18), AValue); if FRidgeHeight = Value then Exit; FRidgeHeight := Value; Changed end;

procedure TNimbusRidgelineOptions.SetFillOpacity(const AValue: Single);
var Value: Single;
begin if IsNan(AValue) or IsInfinite(AValue) then Exit; Value := EnsureRange(AValue, Single(0.05), Single(1)); if FFillOpacity = Value then Exit; FFillOpacity := Value; Changed end;

procedure TNimbusRidgelineOptions.SetLineWidth(const AValue: Single);
var Value: Single;
begin if IsNan(AValue) or IsInfinite(AValue) then Exit; Value := Max(Single(1), AValue); if FLineWidth = Value then Exit; FLineWidth := Value; Changed end;

procedure TNimbusRidgelineOptions.SetMarkerSize(const AValue: Single);
var Value: Single;
begin if IsNan(AValue) or IsInfinite(AValue) then Exit; Value := Max(Single(2), AValue); if FMarkerSize = Value then Exit; FMarkerSize := Value; Changed end;

procedure TNimbusRidgelineOptions.SetAxisHeight(const AValue: Single);
var Value: Single;
begin if IsNan(AValue) or IsInfinite(AValue) then Exit; Value := Max(Single(0), AValue); if FAxisHeight = Value then Exit; FAxisHeight := Value; Changed end;

procedure TNimbusRidgelineOptions.SetZoomStartIndex(const AValue: Integer);
begin if FZoomStartIndex = AValue then Exit; FZoomStartIndex := AValue; Changed end;

procedure TNimbusRidgelineOptions.SetZoomEndIndex(const AValue: Integer);
begin if FZoomEndIndex = AValue then Exit; FZoomEndIndex := AValue; Changed end;

procedure TNimbusRidgelineOptions.SetSelectedSeriesIndex(const AValue: Integer);
begin if FSelectedSeriesIndex = AValue then Exit; FSelectedSeriesIndex := AValue; Changed end;

procedure TNimbusRidgelineOptions.SetSelectedPointIndex(const AValue: Integer);
begin if FSelectedPointIndex = AValue then Exit; FSelectedPointIndex := AValue; Changed end;

procedure TNimbusRidgelineOptions.SetValueFormat(const AValue: string);
begin if FValueFormat = AValue then Exit; FValueFormat := AValue; Changed end;

procedure TNimbusRidgelineOptions.SetPercentFormat(const AValue: string);
begin if FPercentFormat = AValue then Exit; FPercentFormat := AValue; Changed end;

procedure TNimbusRidgelineOptions.SetZoomRange(const StartIndex, EndIndex: Integer);
var First, Last: Integer;
begin
  First := Max(0, Min(StartIndex, EndIndex)); Last := Max(First, Max(StartIndex, EndIndex));
  if (FZoomStartIndex = First) and (FZoomEndIndex = Last) then Exit; FZoomStartIndex := First; FZoomEndIndex := Last; Changed;
end;

procedure TNimbusRidgelineOptions.ResetZoom;
begin if (FZoomStartIndex = -1) and (FZoomEndIndex = -1) then Exit; FZoomStartIndex := -1; FZoomEndIndex := -1; Changed end;

function NimbusRidgelineCurve(const Points: TArray<TPointF>; const Mode: TNimbusRidgelineCurveMode): TArray<TPointF>;
var I, J, N: Integer; P0, P1, P2, P3, C1, C2: TPointF; T, U, Mid: Double;
begin
  if (Mode = nrcLinear) or (Length(Points) < 3) then Exit(Copy(Points));
  if Mode = nrcStep then
  begin
    SetLength(Result, (Length(Points) - 1) * 3 + 1); Result[0] := Points[0]; N := 1;
    for I := 1 to High(Points) do
    begin
      Mid := (Points[I - 1].X + Points[I].X) / 2; Result[N] := TPointF.Create(Mid, Points[I - 1].Y);
      Result[N + 1] := TPointF.Create(Mid, Points[I].Y); Result[N + 2] := Points[I]; Inc(N, 3);
    end;
    Exit;
  end;
  SetLength(Result, (Length(Points) - 1) * 12 + 1); Result[0] := Points[0]; N := 1;
  for I := 0 to High(Points) - 1 do
  begin
    P0 := Points[Max(0, I - 1)]; P1 := Points[I]; P2 := Points[I + 1]; P3 := Points[Min(High(Points), I + 2)];
    C1 := TPointF.Create(P1.X + (P2.X - P0.X) / 6, P1.Y + (P2.Y - P0.Y) / 6);
    C2 := TPointF.Create(P2.X - (P3.X - P1.X) / 6, P2.Y - (P3.Y - P1.Y) / 6);
    for J := 1 to 12 do
    begin
      T := J / 12; U := 1 - T;
      Result[N] := TPointF.Create(U * U * U * P1.X + 3 * U * U * T * C1.X + 3 * U * T * T * C2.X + T * T * T * P2.X,
        U * U * U * P1.Y + 3 * U * U * T * C1.Y + 3 * U * T * T * C2.Y + T * T * T * P2.Y); Inc(N);
    end;
  end;
end;

end.

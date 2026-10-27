{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Charts.Sunburst.Types;

interface

uses System.Classes, System.Types, System.Math, Vcl.Graphics, NimbusForms.Theming.Types;

type
  TNimbusSunburstMarkingMode = (nsmNone, nsmExactPath, nsmBranch);

  TNimbusSunburstOptions = class(TPersistent)
  private
    FInnerRadiusRatio: Single;
    FOuterPadding: Single;
    FRingGap: Single;
    FSegmentGapAngle: Single;
    FMaximumDepth: Integer;
    FShowCenterLabel: Boolean;
    FShowCenterValue: Boolean;
    FShowLabels: Boolean;
    FShowValues: Boolean;
    FShowPercentages: Boolean;
    FShowBreadcrumb: Boolean;
    FShowRootRing: Boolean;
    FEnableFocusDimming: Boolean;
    FEnableSelection: Boolean;
    FEnableDepthGradient: Boolean;
    FEnableGloss: Boolean;
    FEnableDropShadow: Boolean;
    FEnableZoom: Boolean;
    FZoomOnDoubleClick: Boolean;
    FZoomWithMouseWheel: Boolean;
    FShowZoomBadge: Boolean;
    FEnableMarking: Boolean;
    FMarkHoveredBranch: Boolean;
    FShowMarkedGlow: Boolean;
    FMinimumSweepForLabel: Single;
    FMarkedBorderWidth: Single;
    FPathSeparator: string;
    FValueFormat: string;
    FPercentageFormat: string;
    FCenterTitle: string;
    FEmptyText: string;
    FZoomPath: string;
    FMarkedPath: string;
    FMarkingMode: TNimbusSunburstMarkingMode;
    FMarkColor: TColor;
    FOnChange: TNotifyEvent;
    procedure Changed;
    function GetIsZoomed: Boolean;
    function GetHasMarkedPath: Boolean;
    procedure SetInnerRadiusRatio(const Value: Single);
    procedure SetOuterPadding(const Value: Single);
    procedure SetRingGap(const Value: Single);
    procedure SetSegmentGapAngle(const Value: Single);
    procedure SetMaximumDepth(const Value: Integer);
    procedure SetShowCenterLabel(const Value: Boolean);
    procedure SetShowCenterValue(const Value: Boolean);
    procedure SetShowLabels(const Value: Boolean);
    procedure SetShowValues(const Value: Boolean);
    procedure SetShowPercentages(const Value: Boolean);
    procedure SetShowBreadcrumb(const Value: Boolean);
    procedure SetShowRootRing(const Value: Boolean);
    procedure SetEnableFocusDimming(const Value: Boolean);
    procedure SetEnableSelection(const Value: Boolean);
    procedure SetEnableDepthGradient(const Value: Boolean);
    procedure SetEnableGloss(const Value: Boolean);
    procedure SetEnableDropShadow(const Value: Boolean);
    procedure SetEnableZoom(const Value: Boolean);
    procedure SetZoomOnDoubleClick(const Value: Boolean);
    procedure SetZoomWithMouseWheel(const Value: Boolean);
    procedure SetShowZoomBadge(const Value: Boolean);
    procedure SetEnableMarking(const Value: Boolean);
    procedure SetMarkHoveredBranch(const Value: Boolean);
    procedure SetShowMarkedGlow(const Value: Boolean);
    procedure SetMinimumSweepForLabel(const Value: Single);
    procedure SetMarkedBorderWidth(const Value: Single);
    procedure SetPathSeparator(const Value: string);
    procedure SetValueFormat(const Value: string);
    procedure SetPercentageFormat(const Value: string);
    procedure SetCenterTitle(const Value: string);
    procedure SetEmptyText(const Value: string);
    procedure SetZoomPath(const Value: string);
    procedure SetMarkedPath(const Value: string);
    procedure SetMarkingMode(const Value: TNimbusSunburstMarkingMode);
    procedure SetMarkColor(const Value: TColor);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    procedure ResetZoom;
    procedure ClearMarking;
    property IsZoomed: Boolean read GetIsZoomed;
    property HasMarkedPath: Boolean read GetHasMarkedPath;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property InnerRadiusRatio: Single read FInnerRadiusRatio write SetInnerRadiusRatio;
    property OuterPadding: Single read FOuterPadding write SetOuterPadding;
    property RingGap: Single read FRingGap write SetRingGap;
    property SegmentGapAngle: Single read FSegmentGapAngle write SetSegmentGapAngle;
    property MaximumDepth: Integer read FMaximumDepth write SetMaximumDepth default 6;
    property ShowCenterLabel: Boolean read FShowCenterLabel write SetShowCenterLabel default True;
    property ShowCenterValue: Boolean read FShowCenterValue write SetShowCenterValue default True;
    property ShowLabels: Boolean read FShowLabels write SetShowLabels default True;
    property ShowValues: Boolean read FShowValues write SetShowValues default False;
    property ShowPercentages: Boolean read FShowPercentages write SetShowPercentages default True;
    property ShowBreadcrumb: Boolean read FShowBreadcrumb write SetShowBreadcrumb default True;
    property ShowRootRing: Boolean read FShowRootRing write SetShowRootRing default False;
    property EnableFocusDimming: Boolean read FEnableFocusDimming write SetEnableFocusDimming default True;
    property EnableSelection: Boolean read FEnableSelection write SetEnableSelection default True;
    property EnableDepthGradient: Boolean read FEnableDepthGradient write SetEnableDepthGradient default True;
    property EnableGloss: Boolean read FEnableGloss write SetEnableGloss default True;
    property EnableDropShadow: Boolean read FEnableDropShadow write SetEnableDropShadow default True;
    property EnableZoom: Boolean read FEnableZoom write SetEnableZoom default True;
    property ZoomOnDoubleClick: Boolean read FZoomOnDoubleClick write SetZoomOnDoubleClick default True;
    property ZoomWithMouseWheel: Boolean read FZoomWithMouseWheel write SetZoomWithMouseWheel default True;
    property ShowZoomBadge: Boolean read FShowZoomBadge write SetShowZoomBadge default True;
    property EnableMarking: Boolean read FEnableMarking write SetEnableMarking default True;
    property MarkHoveredBranch: Boolean read FMarkHoveredBranch write SetMarkHoveredBranch default True;
    property ShowMarkedGlow: Boolean read FShowMarkedGlow write SetShowMarkedGlow default True;
    property MinimumSweepForLabel: Single read FMinimumSweepForLabel write SetMinimumSweepForLabel;
    property MarkedBorderWidth: Single read FMarkedBorderWidth write SetMarkedBorderWidth;
    property PathSeparator: string read FPathSeparator write SetPathSeparator;
    property ValueFormat: string read FValueFormat write SetValueFormat;
    property PercentageFormat: string read FPercentageFormat write SetPercentageFormat;
    property CenterTitle: string read FCenterTitle write SetCenterTitle;
    property EmptyText: string read FEmptyText write SetEmptyText;
    property ZoomPath: string read FZoomPath write SetZoomPath;
    property MarkedPath: string read FMarkedPath write SetMarkedPath;
    property MarkingMode: TNimbusSunburstMarkingMode read FMarkingMode write SetMarkingMode default nsmBranch;
    property MarkColor: TColor read FMarkColor write SetMarkColor default $0000BFFF;
  end;

  TNimbusSunburstSegmentInfo = record
    NodeIndex, SeriesIndex, PointIndex, Depth: Integer;
    Text, Path, ToolTipText: string;
    Value, ParentValue, RootValue, ShareOfParent, ShareOfTotal: Double;
    StartAngle, SweepAngle, InnerRadius, OuterRadius: Single;
    Center: TPointF;
    Bounds: TRect;
    Color: TThemeColor;
    Tag: NativeInt;
    Polygon: TArray<TPointF>;
  end;

  TNimbusSunburstGeometry = record
    RootValue, VisibleValue: Double;
    Center: TPointF;
    InnerRadius, OuterRadius: Single;
    Segments: TArray<TNimbusSunburstSegmentInfo>;
  end;

implementation

procedure TNimbusSunburstOptions.Changed;
begin if Assigned(FOnChange) then FOnChange(Self) end;

constructor TNimbusSunburstOptions.Create;
begin
  inherited Create;
  FInnerRadiusRatio := 0.28;
  FOuterPadding := 18;
  FRingGap := 2.2;
  FSegmentGapAngle := 0.7;
  FMaximumDepth := 6;
  FShowCenterLabel := True;
  FShowCenterValue := True;
  FShowLabels := True;
  FShowValues := False;
  FShowPercentages := True;
  FShowBreadcrumb := True;
  FShowRootRing := False;
  FEnableFocusDimming := True;
  FEnableSelection := True;
  FEnableDepthGradient := True;
  FEnableGloss := True;
  FEnableDropShadow := True;
  FEnableZoom := True;
  FZoomOnDoubleClick := True;
  FZoomWithMouseWheel := True;
  FShowZoomBadge := True;
  FEnableMarking := True;
  FMarkHoveredBranch := True;
  FShowMarkedGlow := True;
  FMinimumSweepForLabel := 8;
  FMarkedBorderWidth := 3.2;
  FPathSeparator := '/';
  FValueFormat := '#,##0.##';
  FPercentageFormat := '0.#%';
  FCenterTitle := '';
  FEmptyText := 'No hierarchical data.';
  FZoomPath := '';
  FMarkedPath := '';
  FMarkingMode := nsmBranch;
  FMarkColor := $0000BFFF;
end;

procedure TNimbusSunburstOptions.Assign(Source: TPersistent);
var S: TNimbusSunburstOptions;
begin
  if not (Source is TNimbusSunburstOptions) then begin inherited; Exit end; S := TNimbusSunburstOptions(Source);
  FInnerRadiusRatio := S.FInnerRadiusRatio;
  FOuterPadding := S.FOuterPadding;
  FRingGap := S.FRingGap;
  FSegmentGapAngle := S.FSegmentGapAngle;
  FMaximumDepth := S.FMaximumDepth;
  FShowCenterLabel := S.FShowCenterLabel;
  FShowCenterValue := S.FShowCenterValue;
  FShowLabels := S.FShowLabels;
  FShowValues := S.FShowValues;
  FShowPercentages := S.FShowPercentages;
  FShowBreadcrumb := S.FShowBreadcrumb;
  FShowRootRing := S.FShowRootRing;
  FEnableFocusDimming := S.FEnableFocusDimming;
  FEnableSelection := S.FEnableSelection;
  FEnableDepthGradient := S.FEnableDepthGradient;
  FEnableGloss := S.FEnableGloss;
  FEnableDropShadow := S.FEnableDropShadow;
  FEnableZoom := S.FEnableZoom;
  FZoomOnDoubleClick := S.FZoomOnDoubleClick;
  FZoomWithMouseWheel := S.FZoomWithMouseWheel;
  FShowZoomBadge := S.FShowZoomBadge;
  FEnableMarking := S.FEnableMarking;
  FMarkHoveredBranch := S.FMarkHoveredBranch;
  FShowMarkedGlow := S.FShowMarkedGlow;
  FMinimumSweepForLabel := S.FMinimumSweepForLabel;
  FMarkedBorderWidth := S.FMarkedBorderWidth;
  FPathSeparator := S.FPathSeparator;
  FValueFormat := S.FValueFormat;
  FPercentageFormat := S.FPercentageFormat;
  FCenterTitle := S.FCenterTitle;
  FEmptyText := S.FEmptyText;
  FZoomPath := S.FZoomPath;
  FMarkedPath := S.FMarkedPath;
  FMarkingMode := S.FMarkingMode;
  FMarkColor := S.FMarkColor;
  Changed;
end;

function TNimbusSunburstOptions.GetIsZoomed: Boolean;
begin Result := FZoomPath <> '' end;

function TNimbusSunburstOptions.GetHasMarkedPath: Boolean;
begin Result := (FMarkedPath <> '') and (FMarkingMode <> nsmNone) end;

procedure TNimbusSunburstOptions.ResetZoom;
begin ZoomPath := '' end;

procedure TNimbusSunburstOptions.ClearMarking;
begin MarkedPath := '' end;

procedure TNimbusSunburstOptions.SetInnerRadiusRatio(const Value: Single);
var V: Single;
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
  V := EnsureRange(Value, 0.08, 0.72); if FInnerRadiusRatio = V then Exit; FInnerRadiusRatio := V; Changed;
end;

procedure TNimbusSunburstOptions.SetOuterPadding(const Value: Single);
var V: Single;
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
  V := Max(0.0, Value); if FOuterPadding = V then Exit; FOuterPadding := V; Changed;
end;

procedure TNimbusSunburstOptions.SetRingGap(const Value: Single);
var V: Single;
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
  V := EnsureRange(Value, 0.0, 10.0); if FRingGap = V then Exit; FRingGap := V; Changed;
end;

procedure TNimbusSunburstOptions.SetSegmentGapAngle(const Value: Single);
var V: Single;
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
  V := EnsureRange(Value, 0.0, 6.0); if FSegmentGapAngle = V then Exit; FSegmentGapAngle := V; Changed;
end;

procedure TNimbusSunburstOptions.SetMaximumDepth(const Value: Integer);
var V: Integer;
begin
  V := EnsureRange(Value, 1, 12); if FMaximumDepth = V then Exit; FMaximumDepth := V; Changed;
end;

procedure TNimbusSunburstOptions.SetShowCenterLabel(const Value: Boolean);
begin if FShowCenterLabel = Value then Exit; FShowCenterLabel := Value; Changed end;

procedure TNimbusSunburstOptions.SetShowCenterValue(const Value: Boolean);
begin if FShowCenterValue = Value then Exit; FShowCenterValue := Value; Changed end;

procedure TNimbusSunburstOptions.SetShowLabels(const Value: Boolean);
begin if FShowLabels = Value then Exit; FShowLabels := Value; Changed end;

procedure TNimbusSunburstOptions.SetShowValues(const Value: Boolean);
begin if FShowValues = Value then Exit; FShowValues := Value; Changed end;

procedure TNimbusSunburstOptions.SetShowPercentages(const Value: Boolean);
begin if FShowPercentages = Value then Exit; FShowPercentages := Value; Changed end;

procedure TNimbusSunburstOptions.SetShowBreadcrumb(const Value: Boolean);
begin if FShowBreadcrumb = Value then Exit; FShowBreadcrumb := Value; Changed end;

procedure TNimbusSunburstOptions.SetShowRootRing(const Value: Boolean);
begin if FShowRootRing = Value then Exit; FShowRootRing := Value; Changed end;

procedure TNimbusSunburstOptions.SetEnableFocusDimming(const Value: Boolean);
begin if FEnableFocusDimming = Value then Exit; FEnableFocusDimming := Value; Changed end;

procedure TNimbusSunburstOptions.SetEnableSelection(const Value: Boolean);
begin if FEnableSelection = Value then Exit; FEnableSelection := Value; Changed end;

procedure TNimbusSunburstOptions.SetEnableDepthGradient(const Value: Boolean);
begin if FEnableDepthGradient = Value then Exit; FEnableDepthGradient := Value; Changed end;

procedure TNimbusSunburstOptions.SetEnableGloss(const Value: Boolean);
begin if FEnableGloss = Value then Exit; FEnableGloss := Value; Changed end;

procedure TNimbusSunburstOptions.SetEnableDropShadow(const Value: Boolean);
begin if FEnableDropShadow = Value then Exit; FEnableDropShadow := Value; Changed end;

procedure TNimbusSunburstOptions.SetEnableZoom(const Value: Boolean);
begin if FEnableZoom = Value then Exit; FEnableZoom := Value; Changed end;

procedure TNimbusSunburstOptions.SetZoomOnDoubleClick(const Value: Boolean);
begin if FZoomOnDoubleClick = Value then Exit; FZoomOnDoubleClick := Value; Changed end;

procedure TNimbusSunburstOptions.SetZoomWithMouseWheel(const Value: Boolean);
begin if FZoomWithMouseWheel = Value then Exit; FZoomWithMouseWheel := Value; Changed end;

procedure TNimbusSunburstOptions.SetShowZoomBadge(const Value: Boolean);
begin if FShowZoomBadge = Value then Exit; FShowZoomBadge := Value; Changed end;

procedure TNimbusSunburstOptions.SetEnableMarking(const Value: Boolean);
begin if FEnableMarking = Value then Exit; FEnableMarking := Value; Changed end;

procedure TNimbusSunburstOptions.SetMarkHoveredBranch(const Value: Boolean);
begin if FMarkHoveredBranch = Value then Exit; FMarkHoveredBranch := Value; Changed end;

procedure TNimbusSunburstOptions.SetShowMarkedGlow(const Value: Boolean);
begin if FShowMarkedGlow = Value then Exit; FShowMarkedGlow := Value; Changed end;

procedure TNimbusSunburstOptions.SetMinimumSweepForLabel(const Value: Single);
var V: Single;
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
  V := EnsureRange(Value, 1.0, 45.0); if FMinimumSweepForLabel = V then Exit; FMinimumSweepForLabel := V; Changed;
end;

procedure TNimbusSunburstOptions.SetMarkedBorderWidth(const Value: Single);
var V: Single;
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
  V := EnsureRange(Value, 1.0, 12.0); if FMarkedBorderWidth = V then Exit; FMarkedBorderWidth := V; Changed;
end;

procedure TNimbusSunburstOptions.SetPathSeparator(const Value: string);
var V: string;
begin V := Value; if V = '' then V := '/'; if FPathSeparator = V then Exit; FPathSeparator := V; Changed end;

procedure TNimbusSunburstOptions.SetValueFormat(const Value: string);
begin if FValueFormat = Value then Exit; FValueFormat := Value; Changed end;

procedure TNimbusSunburstOptions.SetPercentageFormat(const Value: string);
begin if FPercentageFormat = Value then Exit; FPercentageFormat := Value; Changed end;

procedure TNimbusSunburstOptions.SetCenterTitle(const Value: string);
begin if FCenterTitle = Value then Exit; FCenterTitle := Value; Changed end;

procedure TNimbusSunburstOptions.SetEmptyText(const Value: string);
begin if FEmptyText = Value then Exit; FEmptyText := Value; Changed end;

procedure TNimbusSunburstOptions.SetZoomPath(const Value: string);
begin if FZoomPath = Value then Exit; FZoomPath := Value; Changed end;

procedure TNimbusSunburstOptions.SetMarkedPath(const Value: string);
begin if FMarkedPath = Value then Exit; FMarkedPath := Value; Changed end;

procedure TNimbusSunburstOptions.SetMarkingMode(const Value: TNimbusSunburstMarkingMode);
begin if FMarkingMode = Value then Exit; FMarkingMode := Value; Changed end;

procedure TNimbusSunburstOptions.SetMarkColor(const Value: TColor);
begin if FMarkColor = Value then Exit; FMarkColor := Value; Changed end;

end.

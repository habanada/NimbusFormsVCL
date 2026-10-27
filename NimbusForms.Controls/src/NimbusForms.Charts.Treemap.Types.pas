{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Charts.Treemap.Types;

interface

uses System.Classes, System.Types, System.Math, NimbusForms.Theming.Types;

type
  TNimbusTreemapLayoutMode = (ntlSquarified, ntlSliceAndDice, ntlHorizontal, ntlVertical);
  TNimbusTreemapLabelMode = (nttAuto, nttName, nttNameAndValue, nttNameValueAndPercent);
  TNimbusTreemapMarkingMode = (ntmNone, ntmExactPath, ntmBranch);

  TNimbusTreemapOptions = class(TPersistent)
  private
    FLayoutMode: TNimbusTreemapLayoutMode;
    FLabelMode: TNimbusTreemapLabelMode;
    FMarkingMode: TNimbusTreemapMarkingMode;
    FShowHeaders: Boolean;
    FShowLabels: Boolean;
    FShowValues: Boolean;
    FShowPercent: Boolean;
    FShowBreadcrumb: Boolean;
    FShowLegend: Boolean;
    FShowZoomBadge: Boolean;
    FShowEmptyState: Boolean;
    FShowGroupShading: Boolean;
    FShowTileSheen: Boolean;
    FEnableHoverFocus: Boolean;
    FEnableSelection: Boolean;
    FEnableMarking: Boolean;
    FEnableZoom: Boolean;
    FZoomOnDoubleClick: Boolean;
    FZoomWithMouseWheel: Boolean;
    FAllowParentTiles: Boolean;
    FSortDescending: Boolean;
    FPadding: Integer;
    FTileGap: Integer;
    FGroupGap: Integer;
    FHeaderHeight: Integer;
    FMinimumTileSize: Integer;
    FMinimumLabelWidth: Integer;
    FMinimumLabelHeight: Integer;
    FMaximumDepth: Integer;
    FCornerRadius: Single;
    FHoverDimOpacity: Single;
    FZoomPath: string;
    FMarkedPath: string;
    FPathSeparator: string;
    FValueFormat: string;
    FPercentFormat: string;
    FOnChange: TNotifyEvent;
    procedure Changed;
    procedure SetLayoutMode(const Value: TNimbusTreemapLayoutMode);
    procedure SetLabelMode(const Value: TNimbusTreemapLabelMode);
    procedure SetMarkingMode(const Value: TNimbusTreemapMarkingMode);
    procedure SetShowHeaders(const Value: Boolean);
    procedure SetShowLabels(const Value: Boolean);
    procedure SetShowValues(const Value: Boolean);
    procedure SetShowPercent(const Value: Boolean);
    procedure SetShowBreadcrumb(const Value: Boolean);
    procedure SetShowLegend(const Value: Boolean);
    procedure SetShowZoomBadge(const Value: Boolean);
    procedure SetShowEmptyState(const Value: Boolean);
    procedure SetShowGroupShading(const Value: Boolean);
    procedure SetShowTileSheen(const Value: Boolean);
    procedure SetEnableHoverFocus(const Value: Boolean);
    procedure SetEnableSelection(const Value: Boolean);
    procedure SetEnableMarking(const Value: Boolean);
    procedure SetEnableZoom(const Value: Boolean);
    procedure SetZoomOnDoubleClick(const Value: Boolean);
    procedure SetZoomWithMouseWheel(const Value: Boolean);
    procedure SetAllowParentTiles(const Value: Boolean);
    procedure SetSortDescending(const Value: Boolean);
    procedure SetPadding(const Value: Integer);
    procedure SetTileGap(const Value: Integer);
    procedure SetGroupGap(const Value: Integer);
    procedure SetHeaderHeight(const Value: Integer);
    procedure SetMinimumTileSize(const Value: Integer);
    procedure SetMinimumLabelWidth(const Value: Integer);
    procedure SetMinimumLabelHeight(const Value: Integer);
    procedure SetMaximumDepth(const Value: Integer);
    procedure SetCornerRadius(const Value: Single);
    procedure SetHoverDimOpacity(const Value: Single);
    procedure SetZoomPath(const Value: string);
    procedure SetMarkedPath(const Value: string);
    procedure SetPathSeparator(const Value: string);
    procedure SetValueFormat(const Value: string);
    procedure SetPercentFormat(const Value: string);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property LayoutMode: TNimbusTreemapLayoutMode read FLayoutMode write SetLayoutMode default ntlSquarified;
    property LabelMode: TNimbusTreemapLabelMode read FLabelMode write SetLabelMode default nttAuto;
    property MarkingMode: TNimbusTreemapMarkingMode read FMarkingMode write SetMarkingMode default ntmBranch;
    property ShowHeaders: Boolean read FShowHeaders write SetShowHeaders default True;
    property ShowLabels: Boolean read FShowLabels write SetShowLabels default True;
    property ShowValues: Boolean read FShowValues write SetShowValues default True;
    property ShowPercent: Boolean read FShowPercent write SetShowPercent default True;
    property ShowBreadcrumb: Boolean read FShowBreadcrumb write SetShowBreadcrumb default True;
    property ShowLegend: Boolean read FShowLegend write SetShowLegend default False;
    property ShowZoomBadge: Boolean read FShowZoomBadge write SetShowZoomBadge default True;
    property ShowEmptyState: Boolean read FShowEmptyState write SetShowEmptyState default True;
    property ShowGroupShading: Boolean read FShowGroupShading write SetShowGroupShading default True;
    property ShowTileSheen: Boolean read FShowTileSheen write SetShowTileSheen default True;
    property EnableHoverFocus: Boolean read FEnableHoverFocus write SetEnableHoverFocus default True;
    property EnableSelection: Boolean read FEnableSelection write SetEnableSelection default True;
    property EnableMarking: Boolean read FEnableMarking write SetEnableMarking default True;
    property EnableZoom: Boolean read FEnableZoom write SetEnableZoom default True;
    property ZoomOnDoubleClick: Boolean read FZoomOnDoubleClick write SetZoomOnDoubleClick default True;
    property ZoomWithMouseWheel: Boolean read FZoomWithMouseWheel write SetZoomWithMouseWheel default True;
    property AllowParentTiles: Boolean read FAllowParentTiles write SetAllowParentTiles default False;
    property SortDescending: Boolean read FSortDescending write SetSortDescending default True;
    property Padding: Integer read FPadding write SetPadding default 14;
    property TileGap: Integer read FTileGap write SetTileGap default 1;
    property GroupGap: Integer read FGroupGap write SetGroupGap default 2;
    property HeaderHeight: Integer read FHeaderHeight write SetHeaderHeight default 20;
    property MinimumTileSize: Integer read FMinimumTileSize write SetMinimumTileSize default 8;
    property MinimumLabelWidth: Integer read FMinimumLabelWidth write SetMinimumLabelWidth default 46;
    property MinimumLabelHeight: Integer read FMinimumLabelHeight write SetMinimumLabelHeight default 20;
    property MaximumDepth: Integer read FMaximumDepth write SetMaximumDepth default 8;
    property CornerRadius: Single read FCornerRadius write SetCornerRadius;
    property HoverDimOpacity: Single read FHoverDimOpacity write SetHoverDimOpacity;
    property ZoomPath: string read FZoomPath write SetZoomPath;
    property MarkedPath: string read FMarkedPath write SetMarkedPath;
    property PathSeparator: string read FPathSeparator write SetPathSeparator;
    property ValueFormat: string read FValueFormat write SetValueFormat;
    property PercentFormat: string read FPercentFormat write SetPercentFormat;
  end;

  TNimbusTreemapTileInfo = record
    Name, Path, ToolTipText: string;
    Depth, SeriesIndex, PointIndex: Integer;
    Tag: NativeInt;
    Value, RootTotal, ParentTotal: Double;
    Bounds, HeaderBounds, ContentBounds: TRect;
    IsLeaf: Boolean;
    Color: TThemeColor;
  end;

implementation

procedure TNimbusTreemapOptions.Changed;
begin if Assigned(FOnChange) then FOnChange(Self) end;

constructor TNimbusTreemapOptions.Create;
begin
  inherited Create;
  FLayoutMode := ntlSquarified;
  FLabelMode := nttAuto;
  FMarkingMode := ntmBranch;
  FShowHeaders := True;
  FShowLabels := True;
  FShowValues := True;
  FShowPercent := True;
  FShowBreadcrumb := True;
  FShowLegend := False;
  FShowZoomBadge := True;
  FShowEmptyState := True;
  FShowGroupShading := True;
  FShowTileSheen := True;
  FEnableHoverFocus := True;
  FEnableSelection := True;
  FEnableMarking := True;
  FEnableZoom := True;
  FZoomOnDoubleClick := True;
  FZoomWithMouseWheel := True;
  FAllowParentTiles := False;
  FSortDescending := True;
  FPadding := 14;
  FTileGap := 1;
  FGroupGap := 2;
  FHeaderHeight := 20;
  FMinimumTileSize := 8;
  FMinimumLabelWidth := 46;
  FMinimumLabelHeight := 20;
  FMaximumDepth := 8;
  FCornerRadius := 6;
  FHoverDimOpacity := 0.38;
  FZoomPath := '';
  FMarkedPath := '';
  FPathSeparator := '/';
  FValueFormat := '0,0.##';
  FPercentFormat := '0.#%';
end;

procedure TNimbusTreemapOptions.Assign(Source: TPersistent);
var S: TNimbusTreemapOptions;
begin
  if not (Source is TNimbusTreemapOptions) then begin inherited; Exit end; S := TNimbusTreemapOptions(Source);
  FLayoutMode := S.FLayoutMode;
  FLabelMode := S.FLabelMode;
  FMarkingMode := S.FMarkingMode;
  FShowHeaders := S.FShowHeaders;
  FShowLabels := S.FShowLabels;
  FShowValues := S.FShowValues;
  FShowPercent := S.FShowPercent;
  FShowBreadcrumb := S.FShowBreadcrumb;
  FShowLegend := S.FShowLegend;
  FShowZoomBadge := S.FShowZoomBadge;
  FShowEmptyState := S.FShowEmptyState;
  FShowGroupShading := S.FShowGroupShading;
  FShowTileSheen := S.FShowTileSheen;
  FEnableHoverFocus := S.FEnableHoverFocus;
  FEnableSelection := S.FEnableSelection;
  FEnableMarking := S.FEnableMarking;
  FEnableZoom := S.FEnableZoom;
  FZoomOnDoubleClick := S.FZoomOnDoubleClick;
  FZoomWithMouseWheel := S.FZoomWithMouseWheel;
  FAllowParentTiles := S.FAllowParentTiles;
  FSortDescending := S.FSortDescending;
  FPadding := S.FPadding;
  FTileGap := S.FTileGap;
  FGroupGap := S.FGroupGap;
  FHeaderHeight := S.FHeaderHeight;
  FMinimumTileSize := S.FMinimumTileSize;
  FMinimumLabelWidth := S.FMinimumLabelWidth;
  FMinimumLabelHeight := S.FMinimumLabelHeight;
  FMaximumDepth := S.FMaximumDepth;
  FCornerRadius := S.FCornerRadius;
  FHoverDimOpacity := S.FHoverDimOpacity;
  FZoomPath := S.FZoomPath;
  FMarkedPath := S.FMarkedPath;
  FPathSeparator := S.FPathSeparator;
  FValueFormat := S.FValueFormat;
  FPercentFormat := S.FPercentFormat;
  Changed;
end;

procedure TNimbusTreemapOptions.SetLayoutMode(const Value: TNimbusTreemapLayoutMode);
begin if FLayoutMode = Value then Exit; FLayoutMode := Value; Changed end;

procedure TNimbusTreemapOptions.SetLabelMode(const Value: TNimbusTreemapLabelMode);
begin if FLabelMode = Value then Exit; FLabelMode := Value; Changed end;

procedure TNimbusTreemapOptions.SetMarkingMode(const Value: TNimbusTreemapMarkingMode);
begin if FMarkingMode = Value then Exit; FMarkingMode := Value; Changed end;

procedure TNimbusTreemapOptions.SetShowHeaders(const Value: Boolean);
begin if FShowHeaders = Value then Exit; FShowHeaders := Value; Changed end;

procedure TNimbusTreemapOptions.SetShowLabels(const Value: Boolean);
begin if FShowLabels = Value then Exit; FShowLabels := Value; Changed end;

procedure TNimbusTreemapOptions.SetShowValues(const Value: Boolean);
begin if FShowValues = Value then Exit; FShowValues := Value; Changed end;

procedure TNimbusTreemapOptions.SetShowPercent(const Value: Boolean);
begin if FShowPercent = Value then Exit; FShowPercent := Value; Changed end;

procedure TNimbusTreemapOptions.SetShowBreadcrumb(const Value: Boolean);
begin if FShowBreadcrumb = Value then Exit; FShowBreadcrumb := Value; Changed end;

procedure TNimbusTreemapOptions.SetShowLegend(const Value: Boolean);
begin if FShowLegend = Value then Exit; FShowLegend := Value; Changed end;

procedure TNimbusTreemapOptions.SetShowZoomBadge(const Value: Boolean);
begin if FShowZoomBadge = Value then Exit; FShowZoomBadge := Value; Changed end;

procedure TNimbusTreemapOptions.SetShowEmptyState(const Value: Boolean);
begin if FShowEmptyState = Value then Exit; FShowEmptyState := Value; Changed end;

procedure TNimbusTreemapOptions.SetShowGroupShading(const Value: Boolean);
begin if FShowGroupShading = Value then Exit; FShowGroupShading := Value; Changed end;

procedure TNimbusTreemapOptions.SetShowTileSheen(const Value: Boolean);
begin if FShowTileSheen = Value then Exit; FShowTileSheen := Value; Changed end;

procedure TNimbusTreemapOptions.SetEnableHoverFocus(const Value: Boolean);
begin if FEnableHoverFocus = Value then Exit; FEnableHoverFocus := Value; Changed end;

procedure TNimbusTreemapOptions.SetEnableSelection(const Value: Boolean);
begin if FEnableSelection = Value then Exit; FEnableSelection := Value; Changed end;

procedure TNimbusTreemapOptions.SetEnableMarking(const Value: Boolean);
begin if FEnableMarking = Value then Exit; FEnableMarking := Value; Changed end;

procedure TNimbusTreemapOptions.SetEnableZoom(const Value: Boolean);
begin if FEnableZoom = Value then Exit; FEnableZoom := Value; Changed end;

procedure TNimbusTreemapOptions.SetZoomOnDoubleClick(const Value: Boolean);
begin if FZoomOnDoubleClick = Value then Exit; FZoomOnDoubleClick := Value; Changed end;

procedure TNimbusTreemapOptions.SetZoomWithMouseWheel(const Value: Boolean);
begin if FZoomWithMouseWheel = Value then Exit; FZoomWithMouseWheel := Value; Changed end;

procedure TNimbusTreemapOptions.SetAllowParentTiles(const Value: Boolean);
begin if FAllowParentTiles = Value then Exit; FAllowParentTiles := Value; Changed end;

procedure TNimbusTreemapOptions.SetSortDescending(const Value: Boolean);
begin if FSortDescending = Value then Exit; FSortDescending := Value; Changed end;

procedure TNimbusTreemapOptions.SetPadding(const Value: Integer);
var V: Integer;
begin
  V := Max(0, Value); if FPadding = V then Exit; FPadding := V; Changed;
end;

procedure TNimbusTreemapOptions.SetTileGap(const Value: Integer);
var V: Integer;
begin
  V := Max(0, Value); if FTileGap = V then Exit; FTileGap := V; Changed;
end;

procedure TNimbusTreemapOptions.SetGroupGap(const Value: Integer);
var V: Integer;
begin
  V := Max(0, Value); if FGroupGap = V then Exit; FGroupGap := V; Changed;
end;

procedure TNimbusTreemapOptions.SetHeaderHeight(const Value: Integer);
var V: Integer;
begin
  V := Max(0, Value); if FHeaderHeight = V then Exit; FHeaderHeight := V; Changed;
end;

procedure TNimbusTreemapOptions.SetMinimumTileSize(const Value: Integer);
var V: Integer;
begin
  V := Max(1, Value); if FMinimumTileSize = V then Exit; FMinimumTileSize := V; Changed;
end;

procedure TNimbusTreemapOptions.SetMinimumLabelWidth(const Value: Integer);
var V: Integer;
begin
  V := Max(1, Value); if FMinimumLabelWidth = V then Exit; FMinimumLabelWidth := V; Changed;
end;

procedure TNimbusTreemapOptions.SetMinimumLabelHeight(const Value: Integer);
var V: Integer;
begin
  V := Max(1, Value); if FMinimumLabelHeight = V then Exit; FMinimumLabelHeight := V; Changed;
end;

procedure TNimbusTreemapOptions.SetMaximumDepth(const Value: Integer);
var V: Integer;
begin
  V := Max(1, Value); if FMaximumDepth = V then Exit; FMaximumDepth := V; Changed;
end;

procedure TNimbusTreemapOptions.SetCornerRadius(const Value: Single);
var V: Single;
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
  V := Max(0, Value); if FCornerRadius = V then Exit; FCornerRadius := V; Changed;
end;

procedure TNimbusTreemapOptions.SetHoverDimOpacity(const Value: Single);
var V: Single;
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
  V := EnsureRange(Value, 0.0, 0.85); if FHoverDimOpacity = V then Exit; FHoverDimOpacity := V; Changed;
end;

procedure TNimbusTreemapOptions.SetZoomPath(const Value: string);
begin if FZoomPath = Value then Exit; FZoomPath := Value; Changed end;

procedure TNimbusTreemapOptions.SetMarkedPath(const Value: string);
begin if FMarkedPath = Value then Exit; FMarkedPath := Value; Changed end;

procedure TNimbusTreemapOptions.SetPathSeparator(const Value: string);
begin if FPathSeparator = Value then Exit; FPathSeparator := Value; Changed end;

procedure TNimbusTreemapOptions.SetValueFormat(const Value: string);
begin if FValueFormat = Value then Exit; FValueFormat := Value; Changed end;

procedure TNimbusTreemapOptions.SetPercentFormat(const Value: string);
begin if FPercentFormat = Value then Exit; FPercentFormat := Value; Changed end;

end.

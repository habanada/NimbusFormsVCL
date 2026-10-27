{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Charts.ProgressRingGrid.Types;

interface

uses System.Classes, System.SysUtils, System.Math, Vcl.Graphics;

type
  TNimbusProgressRingGridLayoutMode = (nprlTileGrid, nprlConcentric, nprlMasterSatellite);
  TNimbusProgressRingRenderStyle = (nprsContinuous, nprsSegmented, nprsThreshold, nprsStacked, nprsIndeterminate);
  TNimbusProgressRingSegmentMode = (nprsmMasked, nprsmFixedStep);
  TNimbusProgressRingTrackStyle = (nprtNone, nprtSolid, nprtSegmented, nprtSubtle);
  TNimbusProgressRingTextMode = (nprtmNone, nprtmValue, nprtmPercent, nprtmTitle, nprtmTitleAndValue, nprtmTitleSubtitleValue);
  TNimbusProgressRingDetailPanelPosition = (nprdpNone, nprdpLeft, nprdpTop);
  TNimbusProgressRingColorMode = (nprcSingleColor, nprcPaletteBySegment, nprcThresholdMapped);
  TNimbusProgressRingTextPlacement = (nprtpInherit, nprtpOutside, nprtpInside);
  TNimbusProgressRingSelectionMode = (nprselNone, nprselSingleItem, nprselSingleRing);
  TNimbusRingLineCap = (nrlcRound, nrlcFlat, nrlcSquare);

  TNimbusProgressRingThreshold = class(TCollectionItem)
  private
    FMinimum: Double;
    FMaximum: Double;
    FColor: TColor;
    FLabel: string;
    procedure SetMinimum(const Value: Double);
    procedure SetMaximum(const Value: Double);
    procedure SetColor(const Value: TColor);
    procedure SetLabel(const Value: string);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Minimum: Double read FMinimum write SetMinimum;
    property Maximum: Double read FMaximum write SetMaximum;
    property Color: TColor read FColor write SetColor;
    property &Label: string read FLabel write SetLabel;
  end;

  TNimbusProgressRingThresholdCollection = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    function GetItem(Index: Integer): TNimbusProgressRingThreshold;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TNimbusProgressRingThreshold;
    property Items[Index: Integer]: TNimbusProgressRingThreshold read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TNimbusProgressRingSegment = class(TCollectionItem)
  private
    FKey: string;
    FLabel: string;
    FValue: Double;
    FColor: TColor;
    FToolTipText: string;
    procedure SetKey(const Value: string);
    procedure SetLabel(const Value: string);
    procedure SetValue(const Value: Double);
    procedure SetColor(const Value: TColor);
    procedure SetToolTipText(const Value: string);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Key: string read FKey write SetKey;
    property &Label: string read FLabel write SetLabel;
    property Value: Double read FValue write SetValue;
    property Color: TColor read FColor write SetColor;
    property ToolTipText: string read FToolTipText write SetToolTipText;
  end;

  TNimbusProgressRingSegmentCollection = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    function GetItem(Index: Integer): TNimbusProgressRingSegment;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TNimbusProgressRingSegment;
    property Items[Index: Integer]: TNimbusProgressRingSegment read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TNimbusProgressRingLayer = class(TCollectionItem)
  private
    FKey: string;
    FTitle: string;
    FSubtitle: string;
    FUnitText: string;
    FValueText: string;
    FToolTipText: string;
    FMinimum: Double;
    FMaximum: Double;
    FValue: Double;
    FProgressColor: TColor;
    FTrackColor: TColor;
    FTextColor: TColor;
    FStartAngle: Single;
    FSweepAngle: Single;
    FTrackThickness: Single;
    FProgressThickness: Single;
    FSegmentCount: Integer;
    FSegmentGap: Single;
    FLineCap: TNimbusRingLineCap;
    FRenderStyle: TNimbusProgressRingRenderStyle;
    FSegmentMode: TNimbusProgressRingSegmentMode;
    FTrackStyle: TNimbusProgressRingTrackStyle;
    FColorMode: TNimbusProgressRingColorMode;
    FVisible: Boolean;
    FTag: NativeInt;
    FSegments: TNimbusProgressRingSegmentCollection;
    FThresholds: TNimbusProgressRingThresholdCollection;
    procedure SetKey(const Value: string);
    procedure SetTitle(const Value: string);
    procedure SetSubtitle(const Value: string);
    procedure SetUnitText(const Value: string);
    procedure SetValueText(const Value: string);
    procedure SetToolTipText(const Value: string);
    procedure SetMinimum(const Value: Double);
    procedure SetMaximum(const Value: Double);
    procedure SetValue(const Value: Double);
    procedure SetProgressColor(const Value: TColor);
    procedure SetTrackColor(const Value: TColor);
    procedure SetTextColor(const Value: TColor);
    procedure SetStartAngle(const Value: Single);
    procedure SetSweepAngle(const Value: Single);
    procedure SetTrackThickness(const Value: Single);
    procedure SetProgressThickness(const Value: Single);
    procedure SetSegmentCount(const Value: Integer);
    procedure SetSegmentGap(const Value: Single);
    procedure SetLineCap(const Value: TNimbusRingLineCap);
    procedure SetRenderStyle(const Value: TNimbusProgressRingRenderStyle);
    procedure SetSegmentMode(const Value: TNimbusProgressRingSegmentMode);
    procedure SetTrackStyle(const Value: TNimbusProgressRingTrackStyle);
    procedure SetColorMode(const Value: TNimbusProgressRingColorMode);
    procedure SetVisible(const Value: Boolean);
    procedure SetTag(const Value: NativeInt);
    procedure SetSegments(const Value: TNimbusProgressRingSegmentCollection);
    procedure SetThresholds(const Value: TNimbusProgressRingThresholdCollection);
    procedure ChildChanged(Sender: TObject);
    function GetPercent: Double;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    destructor Destroy; override;
    property Percent: Double read GetPercent;
    function GetDisplayValue: string;
  published
    property Key: string read FKey write SetKey;
    property Title: string read FTitle write SetTitle;
    property Subtitle: string read FSubtitle write SetSubtitle;
    property UnitText: string read FUnitText write SetUnitText;
    property ValueText: string read FValueText write SetValueText;
    property ToolTipText: string read FToolTipText write SetToolTipText;
    property Minimum: Double read FMinimum write SetMinimum;
    property Maximum: Double read FMaximum write SetMaximum;
    property Value: Double read FValue write SetValue;
    property ProgressColor: TColor read FProgressColor write SetProgressColor;
    property TrackColor: TColor read FTrackColor write SetTrackColor;
    property TextColor: TColor read FTextColor write SetTextColor;
    property StartAngle: Single read FStartAngle write SetStartAngle;
    property SweepAngle: Single read FSweepAngle write SetSweepAngle;
    property TrackThickness: Single read FTrackThickness write SetTrackThickness;
    property ProgressThickness: Single read FProgressThickness write SetProgressThickness;
    property SegmentCount: Integer read FSegmentCount write SetSegmentCount;
    property SegmentGap: Single read FSegmentGap write SetSegmentGap;
    property LineCap: TNimbusRingLineCap read FLineCap write SetLineCap;
    property RenderStyle: TNimbusProgressRingRenderStyle read FRenderStyle write SetRenderStyle;
    property SegmentMode: TNimbusProgressRingSegmentMode read FSegmentMode write SetSegmentMode;
    property TrackStyle: TNimbusProgressRingTrackStyle read FTrackStyle write SetTrackStyle;
    property ColorMode: TNimbusProgressRingColorMode read FColorMode write SetColorMode;
    property Visible: Boolean read FVisible write SetVisible;
    property Tag: NativeInt read FTag write SetTag;
    property Segments: TNimbusProgressRingSegmentCollection read FSegments write SetSegments;
    property Thresholds: TNimbusProgressRingThresholdCollection read FThresholds write SetThresholds;
  end;

  TNimbusProgressRingLayerCollection = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    function GetItem(Index: Integer): TNimbusProgressRingLayer;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TNimbusProgressRingLayer;
    property Items[Index: Integer]: TNimbusProgressRingLayer read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TNimbusProgressRingItem = class(TCollectionItem)
  private
    FKey: string;
    FTitle: string;
    FSubtitle: string;
    FUnitText: string;
    FValueText: string;
    FToolTipText: string;
    FMinimum: Double;
    FMaximum: Double;
    FValue: Double;
    FProgressColor: TColor;
    FTrackColor: TColor;
    FTextColor: TColor;
    FBackColor: TColor;
    FStartAngle: Single;
    FSweepAngle: Single;
    FTrackThickness: Single;
    FProgressThickness: Single;
    FRingBorderThickness: Single;
    FRingBorderColor: TColor;
    FSegmentCount: Integer;
    FSegmentGap: Single;
    FLineCap: TNimbusRingLineCap;
    FRenderStyle: TNimbusProgressRingRenderStyle;
    FSegmentMode: TNimbusProgressRingSegmentMode;
    FTrackStyle: TNimbusProgressRingTrackStyle;
    FTextMode: TNimbusProgressRingTextMode;
    FTextPlacement: TNimbusProgressRingTextPlacement;
    FColorMode: TNimbusProgressRingColorMode;
    FIsIndeterminate: Boolean;
    FVisible: Boolean;
    FShowInDetailPanel: Boolean;
    FTag: NativeInt;
    FSegments: TNimbusProgressRingSegmentCollection;
    FThresholds: TNimbusProgressRingThresholdCollection;
    FLayers: TNimbusProgressRingLayerCollection;
    procedure SetKey(const Value: string);
    procedure SetTitle(const Value: string);
    procedure SetSubtitle(const Value: string);
    procedure SetUnitText(const Value: string);
    procedure SetValueText(const Value: string);
    procedure SetToolTipText(const Value: string);
    procedure SetMinimum(const Value: Double);
    procedure SetMaximum(const Value: Double);
    procedure SetValue(const Value: Double);
    procedure SetProgressColor(const Value: TColor);
    procedure SetTrackColor(const Value: TColor);
    procedure SetTextColor(const Value: TColor);
    procedure SetBackColor(const Value: TColor);
    procedure SetStartAngle(const Value: Single);
    procedure SetSweepAngle(const Value: Single);
    procedure SetTrackThickness(const Value: Single);
    procedure SetProgressThickness(const Value: Single);
    procedure SetRingBorderThickness(const Value: Single);
    procedure SetRingBorderColor(const Value: TColor);
    procedure SetSegmentCount(const Value: Integer);
    procedure SetSegmentGap(const Value: Single);
    procedure SetLineCap(const Value: TNimbusRingLineCap);
    procedure SetRenderStyle(const Value: TNimbusProgressRingRenderStyle);
    procedure SetSegmentMode(const Value: TNimbusProgressRingSegmentMode);
    procedure SetTrackStyle(const Value: TNimbusProgressRingTrackStyle);
    procedure SetTextMode(const Value: TNimbusProgressRingTextMode);
    procedure SetTextPlacement(const Value: TNimbusProgressRingTextPlacement);
    procedure SetColorMode(const Value: TNimbusProgressRingColorMode);
    procedure SetIsIndeterminate(const Value: Boolean);
    procedure SetVisible(const Value: Boolean);
    procedure SetShowInDetailPanel(const Value: Boolean);
    procedure SetTag(const Value: NativeInt);
    procedure SetSegments(const Value: TNimbusProgressRingSegmentCollection);
    procedure SetThresholds(const Value: TNimbusProgressRingThresholdCollection);
    procedure SetLayers(const Value: TNimbusProgressRingLayerCollection);
    procedure ChildChanged(Sender: TObject);
    function GetPercent: Double;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    destructor Destroy; override;
    property Percent: Double read GetPercent;
    function GetDisplayValue: string;
  published
    property Key: string read FKey write SetKey;
    property Title: string read FTitle write SetTitle;
    property Subtitle: string read FSubtitle write SetSubtitle;
    property UnitText: string read FUnitText write SetUnitText;
    property ValueText: string read FValueText write SetValueText;
    property ToolTipText: string read FToolTipText write SetToolTipText;
    property Minimum: Double read FMinimum write SetMinimum;
    property Maximum: Double read FMaximum write SetMaximum;
    property Value: Double read FValue write SetValue;
    property ProgressColor: TColor read FProgressColor write SetProgressColor;
    property TrackColor: TColor read FTrackColor write SetTrackColor;
    property TextColor: TColor read FTextColor write SetTextColor;
    property BackColor: TColor read FBackColor write SetBackColor;
    property StartAngle: Single read FStartAngle write SetStartAngle;
    property SweepAngle: Single read FSweepAngle write SetSweepAngle;
    property TrackThickness: Single read FTrackThickness write SetTrackThickness;
    property ProgressThickness: Single read FProgressThickness write SetProgressThickness;
    property RingBorderThickness: Single read FRingBorderThickness write SetRingBorderThickness;
    property RingBorderColor: TColor read FRingBorderColor write SetRingBorderColor;
    property SegmentCount: Integer read FSegmentCount write SetSegmentCount;
    property SegmentGap: Single read FSegmentGap write SetSegmentGap;
    property LineCap: TNimbusRingLineCap read FLineCap write SetLineCap;
    property RenderStyle: TNimbusProgressRingRenderStyle read FRenderStyle write SetRenderStyle;
    property SegmentMode: TNimbusProgressRingSegmentMode read FSegmentMode write SetSegmentMode;
    property TrackStyle: TNimbusProgressRingTrackStyle read FTrackStyle write SetTrackStyle;
    property TextMode: TNimbusProgressRingTextMode read FTextMode write SetTextMode;
    property TextPlacement: TNimbusProgressRingTextPlacement read FTextPlacement write SetTextPlacement;
    property ColorMode: TNimbusProgressRingColorMode read FColorMode write SetColorMode;
    property IsIndeterminate: Boolean read FIsIndeterminate write SetIsIndeterminate;
    property Visible: Boolean read FVisible write SetVisible;
    property ShowInDetailPanel: Boolean read FShowInDetailPanel write SetShowInDetailPanel;
    property Tag: NativeInt read FTag write SetTag;
    property Segments: TNimbusProgressRingSegmentCollection read FSegments write SetSegments;
    property Thresholds: TNimbusProgressRingThresholdCollection read FThresholds write SetThresholds;
    property Layers: TNimbusProgressRingLayerCollection read FLayers write SetLayers;
  end;

  TNimbusProgressRingItemCollection = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    function GetItem(Index: Integer): TNimbusProgressRingItem;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TNimbusProgressRingItem;
    property Items[Index: Integer]: TNimbusProgressRingItem read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TNimbusProgressRingGridData = class(TPersistent)
  private
    FItems: TNimbusProgressRingItemCollection;
    FThresholds: TNimbusProgressRingThresholdCollection;
    FLayoutMode: TNimbusProgressRingGridLayoutMode;
    FRenderStyle: TNimbusProgressRingRenderStyle;
    FSegmentMode: TNimbusProgressRingSegmentMode;
    FTrackStyle: TNimbusProgressRingTrackStyle;
    FTextMode: TNimbusProgressRingTextMode;
    FTextPlacement: TNimbusProgressRingTextPlacement;
    FColorMode: TNimbusProgressRingColorMode;
    FSelectionMode: TNimbusProgressRingSelectionMode;
    FDetailPanelPosition: TNimbusProgressRingDetailPanelPosition;
    FColumns: Integer;
    FRows: Integer;
    FGap: Single;
    FInnerGap: Single;
    FDetailPanelSize: Single;
    FDetailPanelItemLimit: Integer;
    FShowDetailPanel: Boolean;
    FShowDetailHeader: Boolean;
    FShowTrack: Boolean;
    FShowLabels: Boolean;
    FShowValues: Boolean;
    FShowCenterText: Boolean;
    FShowCenterAggregate: Boolean;
    FShowHover: Boolean;
    FShowSelection: Boolean;
    FHighlightDetailPanelSelection: Boolean;
    FAutoColumns: Boolean;
    FAutoRows: Boolean;
    FStartAngle: Single;
    FSweepAngle: Single;
    FTrackThickness: Single;
    FProgressThickness: Single;
    FRingBorderThickness: Single;
    FHoverHaloThickness: Single;
    FSelectionHaloThickness: Single;
    FSegmentCount: Integer;
    FSegmentGap: Single;
    FLineCap: TNimbusRingLineCap;
    FTrackColor: TColor;
    FProgressColor: TColor;
    FRingBorderColor: TColor;
    FHoverColor: TColor;
    FSelectionColor: TColor;
    FDetailPanelBackColor: TColor;
    FDetailPanelBorderColor: TColor;
    FTextColor: TColor;
    FMutedTextColor: TColor;
    FCenterBackColor: TColor;
    FDetailTitle: string;
    FCenterTitle: string;
    FCenterSubtitle: string;
    FOnChange: TNotifyEvent;
    procedure SetItems(const Value: TNimbusProgressRingItemCollection);
    procedure SetThresholds(const Value: TNimbusProgressRingThresholdCollection);
    procedure SetLayoutMode(const Value: TNimbusProgressRingGridLayoutMode);
    procedure SetRenderStyle(const Value: TNimbusProgressRingRenderStyle);
    procedure SetSegmentMode(const Value: TNimbusProgressRingSegmentMode);
    procedure SetTrackStyle(const Value: TNimbusProgressRingTrackStyle);
    procedure SetTextMode(const Value: TNimbusProgressRingTextMode);
    procedure SetTextPlacement(const Value: TNimbusProgressRingTextPlacement);
    procedure SetColorMode(const Value: TNimbusProgressRingColorMode);
    procedure SetSelectionMode(const Value: TNimbusProgressRingSelectionMode);
    procedure SetDetailPanelPosition(const Value: TNimbusProgressRingDetailPanelPosition);
    procedure SetColumns(const Value: Integer);
    procedure SetRows(const Value: Integer);
    procedure SetGap(const Value: Single);
    procedure SetInnerGap(const Value: Single);
    procedure SetDetailPanelSize(const Value: Single);
    procedure SetDetailPanelItemLimit(const Value: Integer);
    procedure SetShowDetailPanel(const Value: Boolean);
    procedure SetShowDetailHeader(const Value: Boolean);
    procedure SetShowTrack(const Value: Boolean);
    procedure SetShowLabels(const Value: Boolean);
    procedure SetShowValues(const Value: Boolean);
    procedure SetShowCenterText(const Value: Boolean);
    procedure SetShowCenterAggregate(const Value: Boolean);
    procedure SetShowHover(const Value: Boolean);
    procedure SetShowSelection(const Value: Boolean);
    procedure SetHighlightDetailPanelSelection(const Value: Boolean);
    procedure SetAutoColumns(const Value: Boolean);
    procedure SetAutoRows(const Value: Boolean);
    procedure SetStartAngle(const Value: Single);
    procedure SetSweepAngle(const Value: Single);
    procedure SetTrackThickness(const Value: Single);
    procedure SetProgressThickness(const Value: Single);
    procedure SetRingBorderThickness(const Value: Single);
    procedure SetHoverHaloThickness(const Value: Single);
    procedure SetSelectionHaloThickness(const Value: Single);
    procedure SetSegmentCount(const Value: Integer);
    procedure SetSegmentGap(const Value: Single);
    procedure SetLineCap(const Value: TNimbusRingLineCap);
    procedure SetTrackColor(const Value: TColor);
    procedure SetProgressColor(const Value: TColor);
    procedure SetRingBorderColor(const Value: TColor);
    procedure SetHoverColor(const Value: TColor);
    procedure SetSelectionColor(const Value: TColor);
    procedure SetDetailPanelBackColor(const Value: TColor);
    procedure SetDetailPanelBorderColor(const Value: TColor);
    procedure SetTextColor(const Value: TColor);
    procedure SetMutedTextColor(const Value: TColor);
    procedure SetCenterBackColor(const Value: TColor);
    procedure SetDetailTitle(const Value: string);
    procedure SetCenterTitle(const Value: string);
    procedure SetCenterSubtitle(const Value: string);
    procedure Changed(Sender: TObject);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    destructor Destroy; override;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property Items: TNimbusProgressRingItemCollection read FItems write SetItems;
    property Thresholds: TNimbusProgressRingThresholdCollection read FThresholds write SetThresholds;
    property LayoutMode: TNimbusProgressRingGridLayoutMode read FLayoutMode write SetLayoutMode;
    property RenderStyle: TNimbusProgressRingRenderStyle read FRenderStyle write SetRenderStyle;
    property SegmentMode: TNimbusProgressRingSegmentMode read FSegmentMode write SetSegmentMode;
    property TrackStyle: TNimbusProgressRingTrackStyle read FTrackStyle write SetTrackStyle;
    property TextMode: TNimbusProgressRingTextMode read FTextMode write SetTextMode;
    property TextPlacement: TNimbusProgressRingTextPlacement read FTextPlacement write SetTextPlacement;
    property ColorMode: TNimbusProgressRingColorMode read FColorMode write SetColorMode;
    property SelectionMode: TNimbusProgressRingSelectionMode read FSelectionMode write SetSelectionMode;
    property DetailPanelPosition: TNimbusProgressRingDetailPanelPosition read FDetailPanelPosition write SetDetailPanelPosition;
    property Columns: Integer read FColumns write SetColumns;
    property Rows: Integer read FRows write SetRows;
    property Gap: Single read FGap write SetGap;
    property InnerGap: Single read FInnerGap write SetInnerGap;
    property DetailPanelSize: Single read FDetailPanelSize write SetDetailPanelSize;
    property DetailPanelItemLimit: Integer read FDetailPanelItemLimit write SetDetailPanelItemLimit;
    property ShowDetailPanel: Boolean read FShowDetailPanel write SetShowDetailPanel;
    property ShowDetailHeader: Boolean read FShowDetailHeader write SetShowDetailHeader;
    property ShowTrack: Boolean read FShowTrack write SetShowTrack;
    property ShowLabels: Boolean read FShowLabels write SetShowLabels;
    property ShowValues: Boolean read FShowValues write SetShowValues;
    property ShowCenterText: Boolean read FShowCenterText write SetShowCenterText;
    property ShowCenterAggregate: Boolean read FShowCenterAggregate write SetShowCenterAggregate;
    property ShowHover: Boolean read FShowHover write SetShowHover;
    property ShowSelection: Boolean read FShowSelection write SetShowSelection;
    property HighlightDetailPanelSelection: Boolean read FHighlightDetailPanelSelection write SetHighlightDetailPanelSelection;
    property AutoColumns: Boolean read FAutoColumns write SetAutoColumns;
    property AutoRows: Boolean read FAutoRows write SetAutoRows;
    property StartAngle: Single read FStartAngle write SetStartAngle;
    property SweepAngle: Single read FSweepAngle write SetSweepAngle;
    property TrackThickness: Single read FTrackThickness write SetTrackThickness;
    property ProgressThickness: Single read FProgressThickness write SetProgressThickness;
    property RingBorderThickness: Single read FRingBorderThickness write SetRingBorderThickness;
    property HoverHaloThickness: Single read FHoverHaloThickness write SetHoverHaloThickness;
    property SelectionHaloThickness: Single read FSelectionHaloThickness write SetSelectionHaloThickness;
    property SegmentCount: Integer read FSegmentCount write SetSegmentCount;
    property SegmentGap: Single read FSegmentGap write SetSegmentGap;
    property LineCap: TNimbusRingLineCap read FLineCap write SetLineCap;
    property TrackColor: TColor read FTrackColor write SetTrackColor;
    property ProgressColor: TColor read FProgressColor write SetProgressColor;
    property RingBorderColor: TColor read FRingBorderColor write SetRingBorderColor;
    property HoverColor: TColor read FHoverColor write SetHoverColor;
    property SelectionColor: TColor read FSelectionColor write SetSelectionColor;
    property DetailPanelBackColor: TColor read FDetailPanelBackColor write SetDetailPanelBackColor;
    property DetailPanelBorderColor: TColor read FDetailPanelBorderColor write SetDetailPanelBorderColor;
    property TextColor: TColor read FTextColor write SetTextColor;
    property MutedTextColor: TColor read FMutedTextColor write SetMutedTextColor;
    property CenterBackColor: TColor read FCenterBackColor write SetCenterBackColor;
    property DetailTitle: string read FDetailTitle write SetDetailTitle;
    property CenterTitle: string read FCenterTitle write SetCenterTitle;
    property CenterSubtitle: string read FCenterSubtitle write SetCenterSubtitle;
  end;

implementation

constructor TNimbusProgressRingThreshold.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FMinimum := 0;
  FMaximum := 100;
  FColor := clNone;
  FLabel := '';
end;

procedure TNimbusProgressRingThreshold.Assign(Source: TPersistent);
var S: TNimbusProgressRingThreshold;
begin
  if not (Source is TNimbusProgressRingThreshold) then begin inherited; Exit end; S := TNimbusProgressRingThreshold(Source);
  FMinimum := S.FMinimum;
  FMaximum := S.FMaximum;
  FColor := S.FColor;
  FLabel := S.FLabel;
  Changed(False);
end;

procedure TNimbusProgressRingThreshold.SetMinimum(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FMinimum = Value then Exit; FMinimum := Value; Changed(False)
end;

procedure TNimbusProgressRingThreshold.SetMaximum(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FMaximum = Value then Exit; FMaximum := Value; Changed(False)
end;

procedure TNimbusProgressRingThreshold.SetColor(const Value: TColor);
begin if FColor = Value then Exit; FColor := Value; Changed(False) end;

procedure TNimbusProgressRingThreshold.SetLabel(const Value: string);
begin if FLabel = Value then Exit; FLabel := Value; Changed(False) end;

constructor TNimbusProgressRingThresholdCollection.Create(AOwner: TPersistent);
begin inherited Create(AOwner, TNimbusProgressRingThreshold) end;

function TNimbusProgressRingThresholdCollection.GetItem(Index: Integer): TNimbusProgressRingThreshold;
begin Result := TNimbusProgressRingThreshold(inherited Items[Index]) end;

function TNimbusProgressRingThresholdCollection.Add: TNimbusProgressRingThreshold;
begin Result := TNimbusProgressRingThreshold(inherited Add) end;

procedure TNimbusProgressRingThresholdCollection.Update(Item: TCollectionItem);
begin inherited; if Assigned(FOnChange) then FOnChange(Self) end;

constructor TNimbusProgressRingSegment.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FKey := '';
  FLabel := '';
  FValue := 0;
  FColor := clNone;
  FToolTipText := '';
end;

procedure TNimbusProgressRingSegment.Assign(Source: TPersistent);
var S: TNimbusProgressRingSegment;
begin
  if not (Source is TNimbusProgressRingSegment) then begin inherited; Exit end; S := TNimbusProgressRingSegment(Source);
  FKey := S.FKey;
  FLabel := S.FLabel;
  FValue := S.FValue;
  FColor := S.FColor;
  FToolTipText := S.FToolTipText;
  Changed(False);
end;

procedure TNimbusProgressRingSegment.SetKey(const Value: string);
begin if FKey = Value then Exit; FKey := Value; Changed(False) end;

procedure TNimbusProgressRingSegment.SetLabel(const Value: string);
begin if FLabel = Value then Exit; FLabel := Value; Changed(False) end;

procedure TNimbusProgressRingSegment.SetValue(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FValue = Value then Exit; FValue := Value; Changed(False)
end;

procedure TNimbusProgressRingSegment.SetColor(const Value: TColor);
begin if FColor = Value then Exit; FColor := Value; Changed(False) end;

procedure TNimbusProgressRingSegment.SetToolTipText(const Value: string);
begin if FToolTipText = Value then Exit; FToolTipText := Value; Changed(False) end;

constructor TNimbusProgressRingSegmentCollection.Create(AOwner: TPersistent);
begin inherited Create(AOwner, TNimbusProgressRingSegment) end;

function TNimbusProgressRingSegmentCollection.GetItem(Index: Integer): TNimbusProgressRingSegment;
begin Result := TNimbusProgressRingSegment(inherited Items[Index]) end;

function TNimbusProgressRingSegmentCollection.Add: TNimbusProgressRingSegment;
begin Result := TNimbusProgressRingSegment(inherited Add) end;

procedure TNimbusProgressRingSegmentCollection.Update(Item: TCollectionItem);
begin inherited; if Assigned(FOnChange) then FOnChange(Self) end;

constructor TNimbusProgressRingLayer.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FKey := '';
  FTitle := '';
  FSubtitle := '';
  FUnitText := '%';
  FValueText := '';
  FToolTipText := '';
  FMinimum := 0;
  FMaximum := 100;
  FValue := 0;
  FProgressColor := clNone;
  FTrackColor := clNone;
  FTextColor := clNone;
  FStartAngle := NaN;
  FSweepAngle := NaN;
  FTrackThickness := 0;
  FProgressThickness := 0;
  FSegmentCount := 0;
  FSegmentGap := NaN;
  FLineCap := nrlcRound;
  FRenderStyle := nprsContinuous;
  FSegmentMode := nprsmMasked;
  FTrackStyle := nprtSolid;
  FColorMode := nprcSingleColor;
  FVisible := True;
  FTag := 0;
  FSegments := TNimbusProgressRingSegmentCollection.Create(Self); FSegments.OnChange := ChildChanged;
  FThresholds := TNimbusProgressRingThresholdCollection.Create(Self); FThresholds.OnChange := ChildChanged;
end;

procedure TNimbusProgressRingLayer.Assign(Source: TPersistent);
var S: TNimbusProgressRingLayer;
begin
  if not (Source is TNimbusProgressRingLayer) then begin inherited; Exit end; S := TNimbusProgressRingLayer(Source);
  FKey := S.FKey;
  FTitle := S.FTitle;
  FSubtitle := S.FSubtitle;
  FUnitText := S.FUnitText;
  FValueText := S.FValueText;
  FToolTipText := S.FToolTipText;
  FMinimum := S.FMinimum;
  FMaximum := S.FMaximum;
  FValue := S.FValue;
  FProgressColor := S.FProgressColor;
  FTrackColor := S.FTrackColor;
  FTextColor := S.FTextColor;
  FStartAngle := S.FStartAngle;
  FSweepAngle := S.FSweepAngle;
  FTrackThickness := S.FTrackThickness;
  FProgressThickness := S.FProgressThickness;
  FSegmentCount := S.FSegmentCount;
  FSegmentGap := S.FSegmentGap;
  FLineCap := S.FLineCap;
  FRenderStyle := S.FRenderStyle;
  FSegmentMode := S.FSegmentMode;
  FTrackStyle := S.FTrackStyle;
  FColorMode := S.FColorMode;
  FVisible := S.FVisible;
  FTag := S.FTag;
  FSegments.Assign(S.FSegments);
  FThresholds.Assign(S.FThresholds);
  Changed(False);
end;

procedure TNimbusProgressRingLayer.SetKey(const Value: string);
begin if FKey = Value then Exit; FKey := Value; Changed(False) end;

procedure TNimbusProgressRingLayer.SetTitle(const Value: string);
begin if FTitle = Value then Exit; FTitle := Value; Changed(False) end;

procedure TNimbusProgressRingLayer.SetSubtitle(const Value: string);
begin if FSubtitle = Value then Exit; FSubtitle := Value; Changed(False) end;

procedure TNimbusProgressRingLayer.SetUnitText(const Value: string);
begin if FUnitText = Value then Exit; FUnitText := Value; Changed(False) end;

procedure TNimbusProgressRingLayer.SetValueText(const Value: string);
begin if FValueText = Value then Exit; FValueText := Value; Changed(False) end;

procedure TNimbusProgressRingLayer.SetToolTipText(const Value: string);
begin if FToolTipText = Value then Exit; FToolTipText := Value; Changed(False) end;

procedure TNimbusProgressRingLayer.SetMinimum(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FMinimum = Value then Exit; FMinimum := Value; Changed(False)
end;

procedure TNimbusProgressRingLayer.SetMaximum(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FMaximum = Value then Exit; FMaximum := Value; Changed(False)
end;

procedure TNimbusProgressRingLayer.SetValue(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FValue = Value then Exit; FValue := Value; Changed(False)
end;

procedure TNimbusProgressRingLayer.SetProgressColor(const Value: TColor);
begin if FProgressColor = Value then Exit; FProgressColor := Value; Changed(False) end;

procedure TNimbusProgressRingLayer.SetTrackColor(const Value: TColor);
begin if FTrackColor = Value then Exit; FTrackColor := Value; Changed(False) end;

procedure TNimbusProgressRingLayer.SetTextColor(const Value: TColor);
begin if FTextColor = Value then Exit; FTextColor := Value; Changed(False) end;

procedure TNimbusProgressRingLayer.SetStartAngle(const Value: Single);
begin
  if IsInfinite(Value) then Exit;
if FStartAngle = Value then Exit; FStartAngle := Value; Changed(False)
end;

procedure TNimbusProgressRingLayer.SetSweepAngle(const Value: Single);
begin
  if IsInfinite(Value) then Exit;
if FSweepAngle = Value then Exit; FSweepAngle := Value; Changed(False)
end;

procedure TNimbusProgressRingLayer.SetTrackThickness(const Value: Single);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FTrackThickness = Value then Exit; FTrackThickness := Value; Changed(False)
end;

procedure TNimbusProgressRingLayer.SetProgressThickness(const Value: Single);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FProgressThickness = Value then Exit; FProgressThickness := Value; Changed(False)
end;

procedure TNimbusProgressRingLayer.SetSegmentCount(const Value: Integer);
begin if FSegmentCount = Value then Exit; FSegmentCount := Value; Changed(False) end;

procedure TNimbusProgressRingLayer.SetSegmentGap(const Value: Single);
begin
  if IsInfinite(Value) then Exit;
if FSegmentGap = Value then Exit; FSegmentGap := Value; Changed(False)
end;

procedure TNimbusProgressRingLayer.SetLineCap(const Value: TNimbusRingLineCap);
begin if FLineCap = Value then Exit; FLineCap := Value; Changed(False) end;

procedure TNimbusProgressRingLayer.SetRenderStyle(const Value: TNimbusProgressRingRenderStyle);
begin if FRenderStyle = Value then Exit; FRenderStyle := Value; Changed(False) end;

procedure TNimbusProgressRingLayer.SetSegmentMode(const Value: TNimbusProgressRingSegmentMode);
begin if FSegmentMode = Value then Exit; FSegmentMode := Value; Changed(False) end;

procedure TNimbusProgressRingLayer.SetTrackStyle(const Value: TNimbusProgressRingTrackStyle);
begin if FTrackStyle = Value then Exit; FTrackStyle := Value; Changed(False) end;

procedure TNimbusProgressRingLayer.SetColorMode(const Value: TNimbusProgressRingColorMode);
begin if FColorMode = Value then Exit; FColorMode := Value; Changed(False) end;

procedure TNimbusProgressRingLayer.SetVisible(const Value: Boolean);
begin if FVisible = Value then Exit; FVisible := Value; Changed(False) end;

procedure TNimbusProgressRingLayer.SetTag(const Value: NativeInt);
begin if FTag = Value then Exit; FTag := Value; Changed(False) end;

procedure TNimbusProgressRingLayer.SetSegments(const Value: TNimbusProgressRingSegmentCollection);
begin if Value <> nil then FSegments.Assign(Value) end;

procedure TNimbusProgressRingLayer.SetThresholds(const Value: TNimbusProgressRingThresholdCollection);
begin if Value <> nil then FThresholds.Assign(Value) end;

destructor TNimbusProgressRingLayer.Destroy;
begin FSegments.Free; FThresholds.Free; inherited end;

procedure TNimbusProgressRingLayer.ChildChanged(Sender: TObject);
begin Changed(False) end;

function TNimbusProgressRingLayer.GetPercent: Double;
begin Result := 0; if IsNan(FValue) or IsInfinite(FValue) or IsNan(FMaximum - FMinimum) or IsInfinite(FMaximum - FMinimum) or (FMaximum = FMinimum) then Exit; Result := EnsureRange((FValue - FMinimum) / (FMaximum - FMinimum), 0.0, 1.0) end;

function TNimbusProgressRingLayer.GetDisplayValue: string;
begin Result := FValueText; if Result <> '' then Exit; if (FMinimum = 0) and (FMaximum = 100) then Result := FormatFloat('0.#', FValue) + FUnitText else Result := FormatFloat('0.#', Percent * 100) + '%' end;

constructor TNimbusProgressRingLayerCollection.Create(AOwner: TPersistent);
begin inherited Create(AOwner, TNimbusProgressRingLayer) end;

function TNimbusProgressRingLayerCollection.GetItem(Index: Integer): TNimbusProgressRingLayer;
begin Result := TNimbusProgressRingLayer(inherited Items[Index]) end;

function TNimbusProgressRingLayerCollection.Add: TNimbusProgressRingLayer;
begin Result := TNimbusProgressRingLayer(inherited Add) end;

procedure TNimbusProgressRingLayerCollection.Update(Item: TCollectionItem);
begin inherited; if Assigned(FOnChange) then FOnChange(Self) end;

constructor TNimbusProgressRingItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FKey := '';
  FTitle := '';
  FSubtitle := '';
  FUnitText := '%';
  FValueText := '';
  FToolTipText := '';
  FMinimum := 0;
  FMaximum := 100;
  FValue := 0;
  FProgressColor := clNone;
  FTrackColor := clNone;
  FTextColor := clNone;
  FBackColor := clNone;
  FStartAngle := NaN;
  FSweepAngle := NaN;
  FTrackThickness := 0;
  FProgressThickness := 0;
  FRingBorderThickness := 0;
  FRingBorderColor := clNone;
  FSegmentCount := 0;
  FSegmentGap := NaN;
  FLineCap := nrlcRound;
  FRenderStyle := nprsContinuous;
  FSegmentMode := nprsmMasked;
  FTrackStyle := nprtSolid;
  FTextMode := nprtmTitleAndValue;
  FTextPlacement := nprtpInherit;
  FColorMode := nprcSingleColor;
  FIsIndeterminate := False;
  FVisible := True;
  FShowInDetailPanel := True;
  FTag := 0;
  FSegments := TNimbusProgressRingSegmentCollection.Create(Self); FSegments.OnChange := ChildChanged;
  FThresholds := TNimbusProgressRingThresholdCollection.Create(Self); FThresholds.OnChange := ChildChanged;
  FLayers := TNimbusProgressRingLayerCollection.Create(Self); FLayers.OnChange := ChildChanged;
end;

procedure TNimbusProgressRingItem.Assign(Source: TPersistent);
var S: TNimbusProgressRingItem;
begin
  if not (Source is TNimbusProgressRingItem) then begin inherited; Exit end; S := TNimbusProgressRingItem(Source);
  FKey := S.FKey;
  FTitle := S.FTitle;
  FSubtitle := S.FSubtitle;
  FUnitText := S.FUnitText;
  FValueText := S.FValueText;
  FToolTipText := S.FToolTipText;
  FMinimum := S.FMinimum;
  FMaximum := S.FMaximum;
  FValue := S.FValue;
  FProgressColor := S.FProgressColor;
  FTrackColor := S.FTrackColor;
  FTextColor := S.FTextColor;
  FBackColor := S.FBackColor;
  FStartAngle := S.FStartAngle;
  FSweepAngle := S.FSweepAngle;
  FTrackThickness := S.FTrackThickness;
  FProgressThickness := S.FProgressThickness;
  FRingBorderThickness := S.FRingBorderThickness;
  FRingBorderColor := S.FRingBorderColor;
  FSegmentCount := S.FSegmentCount;
  FSegmentGap := S.FSegmentGap;
  FLineCap := S.FLineCap;
  FRenderStyle := S.FRenderStyle;
  FSegmentMode := S.FSegmentMode;
  FTrackStyle := S.FTrackStyle;
  FTextMode := S.FTextMode;
  FTextPlacement := S.FTextPlacement;
  FColorMode := S.FColorMode;
  FIsIndeterminate := S.FIsIndeterminate;
  FVisible := S.FVisible;
  FShowInDetailPanel := S.FShowInDetailPanel;
  FTag := S.FTag;
  FSegments.Assign(S.FSegments);
  FThresholds.Assign(S.FThresholds);
  FLayers.Assign(S.FLayers);
  Changed(False);
end;

procedure TNimbusProgressRingItem.SetKey(const Value: string);
begin if FKey = Value then Exit; FKey := Value; Changed(False) end;

procedure TNimbusProgressRingItem.SetTitle(const Value: string);
begin if FTitle = Value then Exit; FTitle := Value; Changed(False) end;

procedure TNimbusProgressRingItem.SetSubtitle(const Value: string);
begin if FSubtitle = Value then Exit; FSubtitle := Value; Changed(False) end;

procedure TNimbusProgressRingItem.SetUnitText(const Value: string);
begin if FUnitText = Value then Exit; FUnitText := Value; Changed(False) end;

procedure TNimbusProgressRingItem.SetValueText(const Value: string);
begin if FValueText = Value then Exit; FValueText := Value; Changed(False) end;

procedure TNimbusProgressRingItem.SetToolTipText(const Value: string);
begin if FToolTipText = Value then Exit; FToolTipText := Value; Changed(False) end;

procedure TNimbusProgressRingItem.SetMinimum(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FMinimum = Value then Exit; FMinimum := Value; Changed(False)
end;

procedure TNimbusProgressRingItem.SetMaximum(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FMaximum = Value then Exit; FMaximum := Value; Changed(False)
end;

procedure TNimbusProgressRingItem.SetValue(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FValue = Value then Exit; FValue := Value; Changed(False)
end;

procedure TNimbusProgressRingItem.SetProgressColor(const Value: TColor);
begin if FProgressColor = Value then Exit; FProgressColor := Value; Changed(False) end;

procedure TNimbusProgressRingItem.SetTrackColor(const Value: TColor);
begin if FTrackColor = Value then Exit; FTrackColor := Value; Changed(False) end;

procedure TNimbusProgressRingItem.SetTextColor(const Value: TColor);
begin if FTextColor = Value then Exit; FTextColor := Value; Changed(False) end;

procedure TNimbusProgressRingItem.SetBackColor(const Value: TColor);
begin if FBackColor = Value then Exit; FBackColor := Value; Changed(False) end;

procedure TNimbusProgressRingItem.SetStartAngle(const Value: Single);
begin
  if IsInfinite(Value) then Exit;
if FStartAngle = Value then Exit; FStartAngle := Value; Changed(False)
end;

procedure TNimbusProgressRingItem.SetSweepAngle(const Value: Single);
begin
  if IsInfinite(Value) then Exit;
if FSweepAngle = Value then Exit; FSweepAngle := Value; Changed(False)
end;

procedure TNimbusProgressRingItem.SetTrackThickness(const Value: Single);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FTrackThickness = Value then Exit; FTrackThickness := Value; Changed(False)
end;

procedure TNimbusProgressRingItem.SetProgressThickness(const Value: Single);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FProgressThickness = Value then Exit; FProgressThickness := Value; Changed(False)
end;

procedure TNimbusProgressRingItem.SetRingBorderThickness(const Value: Single);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FRingBorderThickness = Value then Exit; FRingBorderThickness := Value; Changed(False)
end;

procedure TNimbusProgressRingItem.SetRingBorderColor(const Value: TColor);
begin if FRingBorderColor = Value then Exit; FRingBorderColor := Value; Changed(False) end;

procedure TNimbusProgressRingItem.SetSegmentCount(const Value: Integer);
begin if FSegmentCount = Value then Exit; FSegmentCount := Value; Changed(False) end;

procedure TNimbusProgressRingItem.SetSegmentGap(const Value: Single);
begin
  if IsInfinite(Value) then Exit;
if FSegmentGap = Value then Exit; FSegmentGap := Value; Changed(False)
end;

procedure TNimbusProgressRingItem.SetLineCap(const Value: TNimbusRingLineCap);
begin if FLineCap = Value then Exit; FLineCap := Value; Changed(False) end;

procedure TNimbusProgressRingItem.SetRenderStyle(const Value: TNimbusProgressRingRenderStyle);
begin if FRenderStyle = Value then Exit; FRenderStyle := Value; Changed(False) end;

procedure TNimbusProgressRingItem.SetSegmentMode(const Value: TNimbusProgressRingSegmentMode);
begin if FSegmentMode = Value then Exit; FSegmentMode := Value; Changed(False) end;

procedure TNimbusProgressRingItem.SetTrackStyle(const Value: TNimbusProgressRingTrackStyle);
begin if FTrackStyle = Value then Exit; FTrackStyle := Value; Changed(False) end;

procedure TNimbusProgressRingItem.SetTextMode(const Value: TNimbusProgressRingTextMode);
begin if FTextMode = Value then Exit; FTextMode := Value; Changed(False) end;

procedure TNimbusProgressRingItem.SetTextPlacement(const Value: TNimbusProgressRingTextPlacement);
begin if FTextPlacement = Value then Exit; FTextPlacement := Value; Changed(False) end;

procedure TNimbusProgressRingItem.SetColorMode(const Value: TNimbusProgressRingColorMode);
begin if FColorMode = Value then Exit; FColorMode := Value; Changed(False) end;

procedure TNimbusProgressRingItem.SetIsIndeterminate(const Value: Boolean);
begin if FIsIndeterminate = Value then Exit; FIsIndeterminate := Value; Changed(False) end;

procedure TNimbusProgressRingItem.SetVisible(const Value: Boolean);
begin if FVisible = Value then Exit; FVisible := Value; Changed(False) end;

procedure TNimbusProgressRingItem.SetShowInDetailPanel(const Value: Boolean);
begin if FShowInDetailPanel = Value then Exit; FShowInDetailPanel := Value; Changed(False) end;

procedure TNimbusProgressRingItem.SetTag(const Value: NativeInt);
begin if FTag = Value then Exit; FTag := Value; Changed(False) end;

procedure TNimbusProgressRingItem.SetSegments(const Value: TNimbusProgressRingSegmentCollection);
begin if Value <> nil then FSegments.Assign(Value) end;

procedure TNimbusProgressRingItem.SetThresholds(const Value: TNimbusProgressRingThresholdCollection);
begin if Value <> nil then FThresholds.Assign(Value) end;

procedure TNimbusProgressRingItem.SetLayers(const Value: TNimbusProgressRingLayerCollection);
begin if Value <> nil then FLayers.Assign(Value) end;

destructor TNimbusProgressRingItem.Destroy;
begin FSegments.Free; FThresholds.Free; FLayers.Free; inherited end;

procedure TNimbusProgressRingItem.ChildChanged(Sender: TObject);
begin Changed(False) end;

function TNimbusProgressRingItem.GetPercent: Double;
begin Result := 0; if IsNan(FValue) or IsInfinite(FValue) or IsNan(FMaximum - FMinimum) or IsInfinite(FMaximum - FMinimum) or (FMaximum = FMinimum) then Exit; Result := EnsureRange((FValue - FMinimum) / (FMaximum - FMinimum), 0.0, 1.0) end;

function TNimbusProgressRingItem.GetDisplayValue: string;
begin Result := FValueText; if Result <> '' then Exit; if (FMinimum = 0) and (FMaximum = 100) then Result := FormatFloat('0.#', FValue) + FUnitText else Result := FormatFloat('0.#', Percent * 100) + '%' end;

constructor TNimbusProgressRingItemCollection.Create(AOwner: TPersistent);
begin inherited Create(AOwner, TNimbusProgressRingItem) end;

function TNimbusProgressRingItemCollection.GetItem(Index: Integer): TNimbusProgressRingItem;
begin Result := TNimbusProgressRingItem(inherited Items[Index]) end;

function TNimbusProgressRingItemCollection.Add: TNimbusProgressRingItem;
begin Result := TNimbusProgressRingItem(inherited Add) end;

procedure TNimbusProgressRingItemCollection.Update(Item: TCollectionItem);
begin inherited; if Assigned(FOnChange) then FOnChange(Self) end;

constructor TNimbusProgressRingGridData.Create;
begin
  inherited Create;
  FItems := TNimbusProgressRingItemCollection.Create(Self); FItems.OnChange := Changed;
  FThresholds := TNimbusProgressRingThresholdCollection.Create(Self); FThresholds.OnChange := Changed;
  FLayoutMode := nprlTileGrid;
  FRenderStyle := nprsContinuous;
  FSegmentMode := nprsmMasked;
  FTrackStyle := nprtSolid;
  FTextMode := nprtmTitleAndValue;
  FTextPlacement := nprtpOutside;
  FColorMode := nprcSingleColor;
  FSelectionMode := nprselSingleRing;
  FDetailPanelPosition := nprdpLeft;
  FColumns := 0;
  FRows := 0;
  FGap := 18;
  FInnerGap := 10;
  FDetailPanelSize := 178;
  FDetailPanelItemLimit := 12;
  FShowDetailPanel := True;
  FShowDetailHeader := True;
  FShowTrack := True;
  FShowLabels := True;
  FShowValues := True;
  FShowCenterText := True;
  FShowCenterAggregate := True;
  FShowHover := True;
  FShowSelection := True;
  FHighlightDetailPanelSelection := True;
  FAutoColumns := True;
  FAutoRows := True;
  FStartAngle := -90;
  FSweepAngle := 360;
  FTrackThickness := 5;
  FProgressThickness := 7;
  FRingBorderThickness := 0;
  FHoverHaloThickness := 5;
  FSelectionHaloThickness := 7;
  FSegmentCount := 32;
  FSegmentGap := 2.4;
  FLineCap := nrlcRound;
  FTrackColor := clNone;
  FProgressColor := clNone;
  FRingBorderColor := clNone;
  FHoverColor := clNone;
  FSelectionColor := clNone;
  FDetailPanelBackColor := clNone;
  FDetailPanelBorderColor := clNone;
  FTextColor := clNone;
  FMutedTextColor := clNone;
  FCenterBackColor := clNone;
  FDetailTitle := 'Details';
  FCenterTitle := '';
  FCenterSubtitle := '';
end;

procedure TNimbusProgressRingGridData.Assign(Source: TPersistent);
var S: TNimbusProgressRingGridData;
begin
  if not (Source is TNimbusProgressRingGridData) then begin inherited; Exit end; S := TNimbusProgressRingGridData(Source);
  FItems.Assign(S.FItems);
  FThresholds.Assign(S.FThresholds);
  FLayoutMode := S.FLayoutMode;
  FRenderStyle := S.FRenderStyle;
  FSegmentMode := S.FSegmentMode;
  FTrackStyle := S.FTrackStyle;
  FTextMode := S.FTextMode;
  FTextPlacement := S.FTextPlacement;
  FColorMode := S.FColorMode;
  FSelectionMode := S.FSelectionMode;
  FDetailPanelPosition := S.FDetailPanelPosition;
  FColumns := S.FColumns;
  FRows := S.FRows;
  FGap := S.FGap;
  FInnerGap := S.FInnerGap;
  FDetailPanelSize := S.FDetailPanelSize;
  FDetailPanelItemLimit := S.FDetailPanelItemLimit;
  FShowDetailPanel := S.FShowDetailPanel;
  FShowDetailHeader := S.FShowDetailHeader;
  FShowTrack := S.FShowTrack;
  FShowLabels := S.FShowLabels;
  FShowValues := S.FShowValues;
  FShowCenterText := S.FShowCenterText;
  FShowCenterAggregate := S.FShowCenterAggregate;
  FShowHover := S.FShowHover;
  FShowSelection := S.FShowSelection;
  FHighlightDetailPanelSelection := S.FHighlightDetailPanelSelection;
  FAutoColumns := S.FAutoColumns;
  FAutoRows := S.FAutoRows;
  FStartAngle := S.FStartAngle;
  FSweepAngle := S.FSweepAngle;
  FTrackThickness := S.FTrackThickness;
  FProgressThickness := S.FProgressThickness;
  FRingBorderThickness := S.FRingBorderThickness;
  FHoverHaloThickness := S.FHoverHaloThickness;
  FSelectionHaloThickness := S.FSelectionHaloThickness;
  FSegmentCount := S.FSegmentCount;
  FSegmentGap := S.FSegmentGap;
  FLineCap := S.FLineCap;
  FTrackColor := S.FTrackColor;
  FProgressColor := S.FProgressColor;
  FRingBorderColor := S.FRingBorderColor;
  FHoverColor := S.FHoverColor;
  FSelectionColor := S.FSelectionColor;
  FDetailPanelBackColor := S.FDetailPanelBackColor;
  FDetailPanelBorderColor := S.FDetailPanelBorderColor;
  FTextColor := S.FTextColor;
  FMutedTextColor := S.FMutedTextColor;
  FCenterBackColor := S.FCenterBackColor;
  FDetailTitle := S.FDetailTitle;
  FCenterTitle := S.FCenterTitle;
  FCenterSubtitle := S.FCenterSubtitle;
  Changed(Self);
end;

procedure TNimbusProgressRingGridData.SetItems(const Value: TNimbusProgressRingItemCollection);
begin if Value <> nil then FItems.Assign(Value) end;

procedure TNimbusProgressRingGridData.SetThresholds(const Value: TNimbusProgressRingThresholdCollection);
begin if Value <> nil then FThresholds.Assign(Value) end;

procedure TNimbusProgressRingGridData.SetLayoutMode(const Value: TNimbusProgressRingGridLayoutMode);
begin if FLayoutMode = Value then Exit; FLayoutMode := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetRenderStyle(const Value: TNimbusProgressRingRenderStyle);
begin if FRenderStyle = Value then Exit; FRenderStyle := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetSegmentMode(const Value: TNimbusProgressRingSegmentMode);
begin if FSegmentMode = Value then Exit; FSegmentMode := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetTrackStyle(const Value: TNimbusProgressRingTrackStyle);
begin if FTrackStyle = Value then Exit; FTrackStyle := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetTextMode(const Value: TNimbusProgressRingTextMode);
begin if FTextMode = Value then Exit; FTextMode := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetTextPlacement(const Value: TNimbusProgressRingTextPlacement);
begin if FTextPlacement = Value then Exit; FTextPlacement := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetColorMode(const Value: TNimbusProgressRingColorMode);
begin if FColorMode = Value then Exit; FColorMode := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetSelectionMode(const Value: TNimbusProgressRingSelectionMode);
begin if FSelectionMode = Value then Exit; FSelectionMode := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetDetailPanelPosition(const Value: TNimbusProgressRingDetailPanelPosition);
begin if FDetailPanelPosition = Value then Exit; FDetailPanelPosition := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetColumns(const Value: Integer);
begin if FColumns = Value then Exit; FColumns := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetRows(const Value: Integer);
begin if FRows = Value then Exit; FRows := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetGap(const Value: Single);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FGap = Value then Exit; FGap := Value; Changed(Self)
end;

procedure TNimbusProgressRingGridData.SetInnerGap(const Value: Single);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FInnerGap = Value then Exit; FInnerGap := Value; Changed(Self)
end;

procedure TNimbusProgressRingGridData.SetDetailPanelSize(const Value: Single);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FDetailPanelSize = Value then Exit; FDetailPanelSize := Value; Changed(Self)
end;

procedure TNimbusProgressRingGridData.SetDetailPanelItemLimit(const Value: Integer);
begin if FDetailPanelItemLimit = Value then Exit; FDetailPanelItemLimit := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetShowDetailPanel(const Value: Boolean);
begin if FShowDetailPanel = Value then Exit; FShowDetailPanel := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetShowDetailHeader(const Value: Boolean);
begin if FShowDetailHeader = Value then Exit; FShowDetailHeader := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetShowTrack(const Value: Boolean);
begin if FShowTrack = Value then Exit; FShowTrack := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetShowLabels(const Value: Boolean);
begin if FShowLabels = Value then Exit; FShowLabels := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetShowValues(const Value: Boolean);
begin if FShowValues = Value then Exit; FShowValues := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetShowCenterText(const Value: Boolean);
begin if FShowCenterText = Value then Exit; FShowCenterText := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetShowCenterAggregate(const Value: Boolean);
begin if FShowCenterAggregate = Value then Exit; FShowCenterAggregate := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetShowHover(const Value: Boolean);
begin if FShowHover = Value then Exit; FShowHover := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetShowSelection(const Value: Boolean);
begin if FShowSelection = Value then Exit; FShowSelection := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetHighlightDetailPanelSelection(const Value: Boolean);
begin if FHighlightDetailPanelSelection = Value then Exit; FHighlightDetailPanelSelection := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetAutoColumns(const Value: Boolean);
begin if FAutoColumns = Value then Exit; FAutoColumns := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetAutoRows(const Value: Boolean);
begin if FAutoRows = Value then Exit; FAutoRows := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetStartAngle(const Value: Single);
begin
  if IsInfinite(Value) then Exit;
if FStartAngle = Value then Exit; FStartAngle := Value; Changed(Self)
end;

procedure TNimbusProgressRingGridData.SetSweepAngle(const Value: Single);
begin
  if IsInfinite(Value) then Exit;
if FSweepAngle = Value then Exit; FSweepAngle := Value; Changed(Self)
end;

procedure TNimbusProgressRingGridData.SetTrackThickness(const Value: Single);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FTrackThickness = Value then Exit; FTrackThickness := Value; Changed(Self)
end;

procedure TNimbusProgressRingGridData.SetProgressThickness(const Value: Single);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FProgressThickness = Value then Exit; FProgressThickness := Value; Changed(Self)
end;

procedure TNimbusProgressRingGridData.SetRingBorderThickness(const Value: Single);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FRingBorderThickness = Value then Exit; FRingBorderThickness := Value; Changed(Self)
end;

procedure TNimbusProgressRingGridData.SetHoverHaloThickness(const Value: Single);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FHoverHaloThickness = Value then Exit; FHoverHaloThickness := Value; Changed(Self)
end;

procedure TNimbusProgressRingGridData.SetSelectionHaloThickness(const Value: Single);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FSelectionHaloThickness = Value then Exit; FSelectionHaloThickness := Value; Changed(Self)
end;

procedure TNimbusProgressRingGridData.SetSegmentCount(const Value: Integer);
begin if FSegmentCount = Value then Exit; FSegmentCount := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetSegmentGap(const Value: Single);
begin
  if IsInfinite(Value) then Exit;
if FSegmentGap = Value then Exit; FSegmentGap := Value; Changed(Self)
end;

procedure TNimbusProgressRingGridData.SetLineCap(const Value: TNimbusRingLineCap);
begin if FLineCap = Value then Exit; FLineCap := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetTrackColor(const Value: TColor);
begin if FTrackColor = Value then Exit; FTrackColor := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetProgressColor(const Value: TColor);
begin if FProgressColor = Value then Exit; FProgressColor := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetRingBorderColor(const Value: TColor);
begin if FRingBorderColor = Value then Exit; FRingBorderColor := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetHoverColor(const Value: TColor);
begin if FHoverColor = Value then Exit; FHoverColor := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetSelectionColor(const Value: TColor);
begin if FSelectionColor = Value then Exit; FSelectionColor := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetDetailPanelBackColor(const Value: TColor);
begin if FDetailPanelBackColor = Value then Exit; FDetailPanelBackColor := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetDetailPanelBorderColor(const Value: TColor);
begin if FDetailPanelBorderColor = Value then Exit; FDetailPanelBorderColor := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetTextColor(const Value: TColor);
begin if FTextColor = Value then Exit; FTextColor := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetMutedTextColor(const Value: TColor);
begin if FMutedTextColor = Value then Exit; FMutedTextColor := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetCenterBackColor(const Value: TColor);
begin if FCenterBackColor = Value then Exit; FCenterBackColor := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetDetailTitle(const Value: string);
begin if FDetailTitle = Value then Exit; FDetailTitle := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetCenterTitle(const Value: string);
begin if FCenterTitle = Value then Exit; FCenterTitle := Value; Changed(Self) end;

procedure TNimbusProgressRingGridData.SetCenterSubtitle(const Value: string);
begin if FCenterSubtitle = Value then Exit; FCenterSubtitle := Value; Changed(Self) end;

destructor TNimbusProgressRingGridData.Destroy;
begin FItems.Free; FThresholds.Free; inherited end;

procedure TNimbusProgressRingGridData.Changed(Sender: TObject);
begin if Assigned(FOnChange) then FOnChange(Self) end;

end.

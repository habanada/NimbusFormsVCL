{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Charts.EdgeBundling.Types;

interface

uses System.Classes, System.SysUtils, System.Math, Vcl.Graphics;

type
  TNimbusHierarchicalEdgeBundlingNode = class(TCollectionItem)
  private
    FId: string;
    FParentId: string;
    FCaption: string;
    FGroupKey: string;
    FGroupCaption: string;
    FValue: Double;
    FColor: TColor;
    FVisible: Boolean;
    FTag: NativeInt;
    procedure SetId(const Value: string);
    procedure SetParentId(const Value: string);
    procedure SetCaption(const Value: string);
    procedure SetGroupKey(const Value: string);
    procedure SetGroupCaption(const Value: string);
    procedure SetValue(const Value: Double);
    procedure SetColor(const Value: TColor);
    procedure SetVisible(const Value: Boolean);
    procedure SetTag(const Value: NativeInt);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Id: string read FId write SetId;
    property ParentId: string read FParentId write SetParentId;
    property Caption: string read FCaption write SetCaption;
    property GroupKey: string read FGroupKey write SetGroupKey;
    property GroupCaption: string read FGroupCaption write SetGroupCaption;
    property Value: Double read FValue write SetValue;
    property Color: TColor read FColor write SetColor;
    property Visible: Boolean read FVisible write SetVisible;
    property Tag: NativeInt read FTag write SetTag;
  end;

  TNimbusHierarchicalEdgeBundlingNodeCollection = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    function GetItem(Index: Integer): TNimbusHierarchicalEdgeBundlingNode;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TNimbusHierarchicalEdgeBundlingNode;
    property Items[Index: Integer]: TNimbusHierarchicalEdgeBundlingNode read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TNimbusHierarchicalEdgeBundlingLink = class(TCollectionItem)
  private
    FSourceId: string;
    FTargetId: string;
    FCaption: string;
    FCategory: string;
    FValue: Double;
    FColor: TColor;
    FVisible: Boolean;
    FTag: NativeInt;
    procedure SetSourceId(const Value: string);
    procedure SetTargetId(const Value: string);
    procedure SetCaption(const Value: string);
    procedure SetCategory(const Value: string);
    procedure SetValue(const Value: Double);
    procedure SetColor(const Value: TColor);
    procedure SetVisible(const Value: Boolean);
    procedure SetTag(const Value: NativeInt);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property SourceId: string read FSourceId write SetSourceId;
    property TargetId: string read FTargetId write SetTargetId;
    property Caption: string read FCaption write SetCaption;
    property Category: string read FCategory write SetCategory;
    property Value: Double read FValue write SetValue;
    property Color: TColor read FColor write SetColor;
    property Visible: Boolean read FVisible write SetVisible;
    property Tag: NativeInt read FTag write SetTag;
  end;

  TNimbusHierarchicalEdgeBundlingLinkCollection = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    function GetItem(Index: Integer): TNimbusHierarchicalEdgeBundlingLink;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TNimbusHierarchicalEdgeBundlingLink;
    property Items[Index: Integer]: TNimbusHierarchicalEdgeBundlingLink read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TNimbusHierarchicalEdgeBundlingData = class(TPersistent)
  private
    FNodes: TNimbusHierarchicalEdgeBundlingNodeCollection;
    FLinks: TNimbusHierarchicalEdgeBundlingLinkCollection;
    FGroupOrder: TStrings;
    FSelectedNodeIds: TStrings;
    FSelectedLinkKeys: TStrings;
    FShowLabels: Boolean;
    FShowLegend: Boolean;
    FShowGroupRings: Boolean;
    FShowNodeDots: Boolean;
    FShowLinkDirection: Boolean;
    FUseDirectionalLinkGradient: Boolean;
    FHighlightConnectedNodes: Boolean;
    FEnableZoom: Boolean;
    FZoomScale: Single;
    FUseCategoryColors: Boolean;
    FBundleLinks: Boolean;
    FBundleStrength: Single;
    FLinkOpacity: Single;
    FSelectedLinkOpacity: Single;
    FGroupGapDegrees: Single;
    FNodeRadius: Single;
    FMaxLabelLength: Integer;
    FLinkColor: TColor;
    FSelectedLinkColor: TColor;
    FOnChange: TNotifyEvent;
    procedure SetNodes(const Value: TNimbusHierarchicalEdgeBundlingNodeCollection);
    procedure SetLinks(const Value: TNimbusHierarchicalEdgeBundlingLinkCollection);
    procedure SetGroupOrder(const Value: TStrings);
    procedure SetSelectedNodeIds(const Value: TStrings);
    procedure SetSelectedLinkKeys(const Value: TStrings);
    procedure SetShowLabels(const Value: Boolean);
    procedure SetShowLegend(const Value: Boolean);
    procedure SetShowGroupRings(const Value: Boolean);
    procedure SetShowNodeDots(const Value: Boolean);
    procedure SetShowLinkDirection(const Value: Boolean);
    procedure SetUseDirectionalLinkGradient(const Value: Boolean);
    procedure SetHighlightConnectedNodes(const Value: Boolean);
    procedure SetEnableZoom(const Value: Boolean);
    procedure SetZoomScale(const Value: Single);
    procedure SetUseCategoryColors(const Value: Boolean);
    procedure SetBundleLinks(const Value: Boolean);
    procedure SetBundleStrength(const Value: Single);
    procedure SetLinkOpacity(const Value: Single);
    procedure SetSelectedLinkOpacity(const Value: Single);
    procedure SetGroupGapDegrees(const Value: Single);
    procedure SetNodeRadius(const Value: Single);
    procedure SetMaxLabelLength(const Value: Integer);
    procedure SetLinkColor(const Value: TColor);
    procedure SetSelectedLinkColor(const Value: TColor);
    procedure Changed(Sender: TObject);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    destructor Destroy; override;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property Nodes: TNimbusHierarchicalEdgeBundlingNodeCollection read FNodes write SetNodes;
    property Links: TNimbusHierarchicalEdgeBundlingLinkCollection read FLinks write SetLinks;
    property GroupOrder: TStrings read FGroupOrder write SetGroupOrder;
    property SelectedNodeIds: TStrings read FSelectedNodeIds write SetSelectedNodeIds;
    property SelectedLinkKeys: TStrings read FSelectedLinkKeys write SetSelectedLinkKeys;
    property ShowLabels: Boolean read FShowLabels write SetShowLabels;
    property ShowLegend: Boolean read FShowLegend write SetShowLegend;
    property ShowGroupRings: Boolean read FShowGroupRings write SetShowGroupRings;
    property ShowNodeDots: Boolean read FShowNodeDots write SetShowNodeDots;
    property ShowLinkDirection: Boolean read FShowLinkDirection write SetShowLinkDirection;
    property UseDirectionalLinkGradient: Boolean read FUseDirectionalLinkGradient write SetUseDirectionalLinkGradient;
    property HighlightConnectedNodes: Boolean read FHighlightConnectedNodes write SetHighlightConnectedNodes;
    property EnableZoom: Boolean read FEnableZoom write SetEnableZoom;
    property ZoomScale: Single read FZoomScale write SetZoomScale;
    property UseCategoryColors: Boolean read FUseCategoryColors write SetUseCategoryColors;
    property BundleLinks: Boolean read FBundleLinks write SetBundleLinks;
    property BundleStrength: Single read FBundleStrength write SetBundleStrength;
    property LinkOpacity: Single read FLinkOpacity write SetLinkOpacity;
    property SelectedLinkOpacity: Single read FSelectedLinkOpacity write SetSelectedLinkOpacity;
    property GroupGapDegrees: Single read FGroupGapDegrees write SetGroupGapDegrees;
    property NodeRadius: Single read FNodeRadius write SetNodeRadius;
    property MaxLabelLength: Integer read FMaxLabelLength write SetMaxLabelLength;
    property LinkColor: TColor read FLinkColor write SetLinkColor;
    property SelectedLinkColor: TColor read FSelectedLinkColor write SetSelectedLinkColor;
  end;

implementation

constructor TNimbusHierarchicalEdgeBundlingNode.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FId := '';
  FParentId := '';
  FCaption := '';
  FGroupKey := '';
  FGroupCaption := '';
  FValue := 1;
  FColor := clNone;
  FVisible := True;
  FTag := 0;
end;

procedure TNimbusHierarchicalEdgeBundlingNode.Assign(Source: TPersistent);
var S: TNimbusHierarchicalEdgeBundlingNode;
begin
  if not (Source is TNimbusHierarchicalEdgeBundlingNode) then begin inherited; Exit end; S := TNimbusHierarchicalEdgeBundlingNode(Source);
  FId := S.FId;
  FParentId := S.FParentId;
  FCaption := S.FCaption;
  FGroupKey := S.FGroupKey;
  FGroupCaption := S.FGroupCaption;
  FValue := S.FValue;
  FColor := S.FColor;
  FVisible := S.FVisible;
  FTag := S.FTag;
  Changed(False);
end;

procedure TNimbusHierarchicalEdgeBundlingNode.SetId(const Value: string);
begin if FId = Value then Exit; FId := Value; Changed(False) end;

procedure TNimbusHierarchicalEdgeBundlingNode.SetParentId(const Value: string);
begin if FParentId = Value then Exit; FParentId := Value; Changed(False) end;

procedure TNimbusHierarchicalEdgeBundlingNode.SetCaption(const Value: string);
begin if FCaption = Value then Exit; FCaption := Value; Changed(False) end;

procedure TNimbusHierarchicalEdgeBundlingNode.SetGroupKey(const Value: string);
begin if FGroupKey = Value then Exit; FGroupKey := Value; Changed(False) end;

procedure TNimbusHierarchicalEdgeBundlingNode.SetGroupCaption(const Value: string);
begin if FGroupCaption = Value then Exit; FGroupCaption := Value; Changed(False) end;

procedure TNimbusHierarchicalEdgeBundlingNode.SetValue(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FValue = Value then Exit; FValue := Value; Changed(False)
end;

procedure TNimbusHierarchicalEdgeBundlingNode.SetColor(const Value: TColor);
begin if FColor = Value then Exit; FColor := Value; Changed(False) end;

procedure TNimbusHierarchicalEdgeBundlingNode.SetVisible(const Value: Boolean);
begin if FVisible = Value then Exit; FVisible := Value; Changed(False) end;

procedure TNimbusHierarchicalEdgeBundlingNode.SetTag(const Value: NativeInt);
begin if FTag = Value then Exit; FTag := Value; Changed(False) end;

constructor TNimbusHierarchicalEdgeBundlingNodeCollection.Create(AOwner: TPersistent);
begin inherited Create(AOwner, TNimbusHierarchicalEdgeBundlingNode) end;

function TNimbusHierarchicalEdgeBundlingNodeCollection.GetItem(Index: Integer): TNimbusHierarchicalEdgeBundlingNode;
begin Result := TNimbusHierarchicalEdgeBundlingNode(inherited Items[Index]) end;

function TNimbusHierarchicalEdgeBundlingNodeCollection.Add: TNimbusHierarchicalEdgeBundlingNode;
begin Result := TNimbusHierarchicalEdgeBundlingNode(inherited Add) end;

procedure TNimbusHierarchicalEdgeBundlingNodeCollection.Update(Item: TCollectionItem);
begin inherited; if Assigned(FOnChange) then FOnChange(Self) end;

constructor TNimbusHierarchicalEdgeBundlingLink.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FSourceId := '';
  FTargetId := '';
  FCaption := '';
  FCategory := '';
  FValue := 0;
  FColor := clNone;
  FVisible := True;
  FTag := 0;
end;

procedure TNimbusHierarchicalEdgeBundlingLink.Assign(Source: TPersistent);
var S: TNimbusHierarchicalEdgeBundlingLink;
begin
  if not (Source is TNimbusHierarchicalEdgeBundlingLink) then begin inherited; Exit end; S := TNimbusHierarchicalEdgeBundlingLink(Source);
  FSourceId := S.FSourceId;
  FTargetId := S.FTargetId;
  FCaption := S.FCaption;
  FCategory := S.FCategory;
  FValue := S.FValue;
  FColor := S.FColor;
  FVisible := S.FVisible;
  FTag := S.FTag;
  Changed(False);
end;

procedure TNimbusHierarchicalEdgeBundlingLink.SetSourceId(const Value: string);
begin if FSourceId = Value then Exit; FSourceId := Value; Changed(False) end;

procedure TNimbusHierarchicalEdgeBundlingLink.SetTargetId(const Value: string);
begin if FTargetId = Value then Exit; FTargetId := Value; Changed(False) end;

procedure TNimbusHierarchicalEdgeBundlingLink.SetCaption(const Value: string);
begin if FCaption = Value then Exit; FCaption := Value; Changed(False) end;

procedure TNimbusHierarchicalEdgeBundlingLink.SetCategory(const Value: string);
begin if FCategory = Value then Exit; FCategory := Value; Changed(False) end;

procedure TNimbusHierarchicalEdgeBundlingLink.SetValue(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FValue = Value then Exit; FValue := Value; Changed(False)
end;

procedure TNimbusHierarchicalEdgeBundlingLink.SetColor(const Value: TColor);
begin if FColor = Value then Exit; FColor := Value; Changed(False) end;

procedure TNimbusHierarchicalEdgeBundlingLink.SetVisible(const Value: Boolean);
begin if FVisible = Value then Exit; FVisible := Value; Changed(False) end;

procedure TNimbusHierarchicalEdgeBundlingLink.SetTag(const Value: NativeInt);
begin if FTag = Value then Exit; FTag := Value; Changed(False) end;

constructor TNimbusHierarchicalEdgeBundlingLinkCollection.Create(AOwner: TPersistent);
begin inherited Create(AOwner, TNimbusHierarchicalEdgeBundlingLink) end;

function TNimbusHierarchicalEdgeBundlingLinkCollection.GetItem(Index: Integer): TNimbusHierarchicalEdgeBundlingLink;
begin Result := TNimbusHierarchicalEdgeBundlingLink(inherited Items[Index]) end;

function TNimbusHierarchicalEdgeBundlingLinkCollection.Add: TNimbusHierarchicalEdgeBundlingLink;
begin Result := TNimbusHierarchicalEdgeBundlingLink(inherited Add) end;

procedure TNimbusHierarchicalEdgeBundlingLinkCollection.Update(Item: TCollectionItem);
begin inherited; if Assigned(FOnChange) then FOnChange(Self) end;

constructor TNimbusHierarchicalEdgeBundlingData.Create;
begin
  inherited Create;
  FNodes := TNimbusHierarchicalEdgeBundlingNodeCollection.Create(Self); FNodes.OnChange := Changed;
  FLinks := TNimbusHierarchicalEdgeBundlingLinkCollection.Create(Self); FLinks.OnChange := Changed;
  FGroupOrder := TStringList.Create; TStringList(FGroupOrder).OnChange := Changed;
  FSelectedNodeIds := TStringList.Create; TStringList(FSelectedNodeIds).OnChange := Changed;
  FSelectedLinkKeys := TStringList.Create; TStringList(FSelectedLinkKeys).OnChange := Changed;
  FShowLabels := True;
  FShowLegend := True;
  FShowGroupRings := True;
  FShowNodeDots := True;
  FShowLinkDirection := True;
  FUseDirectionalLinkGradient := True;
  FHighlightConnectedNodes := True;
  FEnableZoom := True;
  FZoomScale := 1;
  FUseCategoryColors := True;
  FBundleLinks := True;
  FBundleStrength := 0.82;
  FLinkOpacity := 0.28;
  FSelectedLinkOpacity := 0.88;
  FGroupGapDegrees := 6;
  FNodeRadius := 4.5;
  FMaxLabelLength := 24;
  FLinkColor := clNone;
  FSelectedLinkColor := clNone;
end;

procedure TNimbusHierarchicalEdgeBundlingData.Assign(Source: TPersistent);
var S: TNimbusHierarchicalEdgeBundlingData;
begin
  if not (Source is TNimbusHierarchicalEdgeBundlingData) then begin inherited; Exit end; S := TNimbusHierarchicalEdgeBundlingData(Source);
  FNodes.Assign(S.FNodes);
  FLinks.Assign(S.FLinks);
  FGroupOrder.Assign(S.FGroupOrder);
  FSelectedNodeIds.Assign(S.FSelectedNodeIds);
  FSelectedLinkKeys.Assign(S.FSelectedLinkKeys);
  FShowLabels := S.FShowLabels;
  FShowLegend := S.FShowLegend;
  FShowGroupRings := S.FShowGroupRings;
  FShowNodeDots := S.FShowNodeDots;
  FShowLinkDirection := S.FShowLinkDirection;
  FUseDirectionalLinkGradient := S.FUseDirectionalLinkGradient;
  FHighlightConnectedNodes := S.FHighlightConnectedNodes;
  FEnableZoom := S.FEnableZoom;
  FZoomScale := S.FZoomScale;
  FUseCategoryColors := S.FUseCategoryColors;
  FBundleLinks := S.FBundleLinks;
  FBundleStrength := S.FBundleStrength;
  FLinkOpacity := S.FLinkOpacity;
  FSelectedLinkOpacity := S.FSelectedLinkOpacity;
  FGroupGapDegrees := S.FGroupGapDegrees;
  FNodeRadius := S.FNodeRadius;
  FMaxLabelLength := S.FMaxLabelLength;
  FLinkColor := S.FLinkColor;
  FSelectedLinkColor := S.FSelectedLinkColor;
  Changed(Self);
end;

procedure TNimbusHierarchicalEdgeBundlingData.SetNodes(const Value: TNimbusHierarchicalEdgeBundlingNodeCollection);
begin if Value <> nil then FNodes.Assign(Value) end;

procedure TNimbusHierarchicalEdgeBundlingData.SetLinks(const Value: TNimbusHierarchicalEdgeBundlingLinkCollection);
begin if Value <> nil then FLinks.Assign(Value) end;

procedure TNimbusHierarchicalEdgeBundlingData.SetGroupOrder(const Value: TStrings);
begin if Value <> nil then FGroupOrder.Assign(Value) end;

procedure TNimbusHierarchicalEdgeBundlingData.SetSelectedNodeIds(const Value: TStrings);
begin if Value <> nil then FSelectedNodeIds.Assign(Value) end;

procedure TNimbusHierarchicalEdgeBundlingData.SetSelectedLinkKeys(const Value: TStrings);
begin if Value <> nil then FSelectedLinkKeys.Assign(Value) end;

procedure TNimbusHierarchicalEdgeBundlingData.SetShowLabels(const Value: Boolean);
begin if FShowLabels = Value then Exit; FShowLabels := Value; Changed(Self) end;

procedure TNimbusHierarchicalEdgeBundlingData.SetShowLegend(const Value: Boolean);
begin if FShowLegend = Value then Exit; FShowLegend := Value; Changed(Self) end;

procedure TNimbusHierarchicalEdgeBundlingData.SetShowGroupRings(const Value: Boolean);
begin if FShowGroupRings = Value then Exit; FShowGroupRings := Value; Changed(Self) end;

procedure TNimbusHierarchicalEdgeBundlingData.SetShowNodeDots(const Value: Boolean);
begin if FShowNodeDots = Value then Exit; FShowNodeDots := Value; Changed(Self) end;

procedure TNimbusHierarchicalEdgeBundlingData.SetShowLinkDirection(const Value: Boolean);
begin if FShowLinkDirection = Value then Exit; FShowLinkDirection := Value; Changed(Self) end;

procedure TNimbusHierarchicalEdgeBundlingData.SetUseDirectionalLinkGradient(const Value: Boolean);
begin if FUseDirectionalLinkGradient = Value then Exit; FUseDirectionalLinkGradient := Value; Changed(Self) end;

procedure TNimbusHierarchicalEdgeBundlingData.SetHighlightConnectedNodes(const Value: Boolean);
begin if FHighlightConnectedNodes = Value then Exit; FHighlightConnectedNodes := Value; Changed(Self) end;

procedure TNimbusHierarchicalEdgeBundlingData.SetEnableZoom(const Value: Boolean);
begin if FEnableZoom = Value then Exit; FEnableZoom := Value; Changed(Self) end;

procedure TNimbusHierarchicalEdgeBundlingData.SetZoomScale(const Value: Single);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FZoomScale = EnsureRange(Value, 0.25, 4.0) then Exit; FZoomScale := EnsureRange(Value, 0.25, 4.0); Changed(Self)
end;

procedure TNimbusHierarchicalEdgeBundlingData.SetUseCategoryColors(const Value: Boolean);
begin if FUseCategoryColors = Value then Exit; FUseCategoryColors := Value; Changed(Self) end;

procedure TNimbusHierarchicalEdgeBundlingData.SetBundleLinks(const Value: Boolean);
begin if FBundleLinks = Value then Exit; FBundleLinks := Value; Changed(Self) end;

procedure TNimbusHierarchicalEdgeBundlingData.SetBundleStrength(const Value: Single);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FBundleStrength = EnsureRange(Value, 0.0, 1.0) then Exit; FBundleStrength := EnsureRange(Value, 0.0, 1.0); Changed(Self)
end;

procedure TNimbusHierarchicalEdgeBundlingData.SetLinkOpacity(const Value: Single);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FLinkOpacity = EnsureRange(Value, 0.0, 1.0) then Exit; FLinkOpacity := EnsureRange(Value, 0.0, 1.0); Changed(Self)
end;

procedure TNimbusHierarchicalEdgeBundlingData.SetSelectedLinkOpacity(const Value: Single);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FSelectedLinkOpacity = EnsureRange(Value, 0.0, 1.0) then Exit; FSelectedLinkOpacity := EnsureRange(Value, 0.0, 1.0); Changed(Self)
end;

procedure TNimbusHierarchicalEdgeBundlingData.SetGroupGapDegrees(const Value: Single);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FGroupGapDegrees = Value then Exit; FGroupGapDegrees := Value; Changed(Self)
end;

procedure TNimbusHierarchicalEdgeBundlingData.SetNodeRadius(const Value: Single);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
if FNodeRadius = Value then Exit; FNodeRadius := Value; Changed(Self)
end;

procedure TNimbusHierarchicalEdgeBundlingData.SetMaxLabelLength(const Value: Integer);
begin if FMaxLabelLength = Value then Exit; FMaxLabelLength := Value; Changed(Self) end;

procedure TNimbusHierarchicalEdgeBundlingData.SetLinkColor(const Value: TColor);
begin if FLinkColor = Value then Exit; FLinkColor := Value; Changed(Self) end;

procedure TNimbusHierarchicalEdgeBundlingData.SetSelectedLinkColor(const Value: TColor);
begin if FSelectedLinkColor = Value then Exit; FSelectedLinkColor := Value; Changed(Self) end;

destructor TNimbusHierarchicalEdgeBundlingData.Destroy;
begin FNodes.Free; FLinks.Free; FGroupOrder.Free; FSelectedNodeIds.Free; FSelectedLinkKeys.Free; inherited end;

procedure TNimbusHierarchicalEdgeBundlingData.Changed(Sender: TObject);
begin if Assigned(FOnChange) then FOnChange(Self) end;

end.

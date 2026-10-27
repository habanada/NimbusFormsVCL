{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Charts.Sankey.Types;

interface

uses System.Classes, System.Types, System.SysUtils, System.Math, Vcl.Graphics;

type
  TNimbusSankeyNode = class(TCollectionItem)
  private
    FId: string;
    FLabel: string;
    FColor: TColor;
    FVisible: Boolean;
    FTag: NativeInt;
    FBounds: TRectF;
    FValue: Double;
    FLayer: Integer;
    procedure SetId(const Value: string);
    procedure SetLabel(const Value: string);
    procedure SetColor(const Value: TColor);
    procedure SetVisible(const Value: Boolean);
    procedure SetTag(const Value: NativeInt);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    procedure UpdateLayout(const Bounds: TRectF; const Value: Double; const Layer: Integer);
    property Bounds: TRectF read FBounds;
    property Value: Double read FValue;
    property Layer: Integer read FLayer;
  published
    property Id: string read FId write SetId;
    property &Label: string read FLabel write SetLabel;
    property Color: TColor read FColor write SetColor;
    property Visible: Boolean read FVisible write SetVisible;
    property Tag: NativeInt read FTag write SetTag;
  end;

  TNimbusSankeyNodeCollection = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    function GetItem(Index: Integer): TNimbusSankeyNode;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TNimbusSankeyNode; overload;
    function Add(const Id, LabelText: string): TNimbusSankeyNode; overload;
    property Items[Index: Integer]: TNimbusSankeyNode read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TNimbusSankeyLink = class(TCollectionItem)
  private
    FSourceId: string;
    FTargetId: string;
    FLabel: string;
    FToolTipText: string;
    FValue: Double;
    FColor: TColor;
    FVisible: Boolean;
    FTag: NativeInt;
    procedure SetSourceId(const Value: string);
    procedure SetTargetId(const Value: string);
    procedure SetLabel(const Value: string);
    procedure SetToolTipText(const Value: string);
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
    property &Label: string read FLabel write SetLabel;
    property ToolTipText: string read FToolTipText write SetToolTipText;
    property Value: Double read FValue write SetValue;
    property Color: TColor read FColor write SetColor;
    property Visible: Boolean read FVisible write SetVisible;
    property Tag: NativeInt read FTag write SetTag;
  end;

  TNimbusSankeyLinkCollection = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    function GetItem(Index: Integer): TNimbusSankeyLink;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TNimbusSankeyLink; overload;
    function Add(const SourceId, TargetId: string; const Value: Double): TNimbusSankeyLink; overload;
    property Items[Index: Integer]: TNimbusSankeyLink read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TNimbusSankeyData = class(TPersistent)
  private
    FNodeWidth: Single;
    FNodePadding: Single;
    FLinkOpacity: Single;
    FShowNodeLabels: Boolean;
    FShowLinkLabels: Boolean;
    FShowNodeValues: Boolean;
    FShowStageHeaders: Boolean;
    FAutoCreateMissingNodes: Boolean;
    FUseLinkGradient: Boolean;
    FAvoidLabelCollisions: Boolean;
    FSmartNodeLabelPlacement: Boolean;
    FAvoidNodeLabelCollisions: Boolean;
    FShowNodeLabelBackplates: Boolean;
    FCompactStageHeaders: Boolean;
    FShowStageHeaderBackplates: Boolean;
    FStageHeaderHeight: Single;
    FLinkColor: TColor;
    FNodes: TNimbusSankeyNodeCollection;
    FLinks: TNimbusSankeyLinkCollection;
    FStageTitles: TStrings;
    FOnChange: TNotifyEvent;
    procedure SetNodeWidth(const Value: Single);
    procedure SetNodePadding(const Value: Single);
    procedure SetLinkOpacity(const Value: Single);
    procedure SetShowNodeLabels(const Value: Boolean);
    procedure SetShowLinkLabels(const Value: Boolean);
    procedure SetShowNodeValues(const Value: Boolean);
    procedure SetShowStageHeaders(const Value: Boolean);
    procedure SetAutoCreateMissingNodes(const Value: Boolean);
    procedure SetUseLinkGradient(const Value: Boolean);
    procedure SetAvoidLabelCollisions(const Value: Boolean);
    procedure SetSmartNodeLabelPlacement(const Value: Boolean);
    procedure SetAvoidNodeLabelCollisions(const Value: Boolean);
    procedure SetShowNodeLabelBackplates(const Value: Boolean);
    procedure SetCompactStageHeaders(const Value: Boolean);
    procedure SetShowStageHeaderBackplates(const Value: Boolean);
    procedure SetStageHeaderHeight(const Value: Single);
    procedure SetLinkColor(const Value: TColor);
    procedure Changed(Sender: TObject);
    procedure SetNodes(const Value: TNimbusSankeyNodeCollection);
    procedure SetLinks(const Value: TNimbusSankeyLinkCollection);
    procedure SetStageTitles(const Value: TStrings);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    destructor Destroy; override;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property NodeWidth: Single read FNodeWidth write SetNodeWidth;
    property NodePadding: Single read FNodePadding write SetNodePadding;
    property LinkOpacity: Single read FLinkOpacity write SetLinkOpacity;
    property ShowNodeLabels: Boolean read FShowNodeLabels write SetShowNodeLabels;
    property ShowLinkLabels: Boolean read FShowLinkLabels write SetShowLinkLabels;
    property ShowNodeValues: Boolean read FShowNodeValues write SetShowNodeValues;
    property ShowStageHeaders: Boolean read FShowStageHeaders write SetShowStageHeaders;
    property AutoCreateMissingNodes: Boolean read FAutoCreateMissingNodes write SetAutoCreateMissingNodes;
    property UseLinkGradient: Boolean read FUseLinkGradient write SetUseLinkGradient;
    property AvoidLabelCollisions: Boolean read FAvoidLabelCollisions write SetAvoidLabelCollisions;
    property SmartNodeLabelPlacement: Boolean read FSmartNodeLabelPlacement write SetSmartNodeLabelPlacement;
    property AvoidNodeLabelCollisions: Boolean read FAvoidNodeLabelCollisions write SetAvoidNodeLabelCollisions;
    property ShowNodeLabelBackplates: Boolean read FShowNodeLabelBackplates write SetShowNodeLabelBackplates;
    property CompactStageHeaders: Boolean read FCompactStageHeaders write SetCompactStageHeaders;
    property ShowStageHeaderBackplates: Boolean read FShowStageHeaderBackplates write SetShowStageHeaderBackplates;
    property StageHeaderHeight: Single read FStageHeaderHeight write SetStageHeaderHeight;
    property LinkColor: TColor read FLinkColor write SetLinkColor;
    property Nodes: TNimbusSankeyNodeCollection read FNodes write SetNodes;
    property Links: TNimbusSankeyLinkCollection read FLinks write SetLinks;
    property StageTitles: TStrings read FStageTitles write SetStageTitles;
  end;

implementation

constructor TNimbusSankeyNode.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FId := '';
  FLabel := '';
  FColor := clNone;
  FVisible := True;
  FTag := 0;
end;

procedure TNimbusSankeyNode.Assign(Source: TPersistent);
var S: TNimbusSankeyNode;
begin
  if not (Source is TNimbusSankeyNode) then begin inherited; Exit end; S := TNimbusSankeyNode(Source);
  FId := S.FId;
  FLabel := S.FLabel;
  FColor := S.FColor;
  FVisible := S.FVisible;
  FTag := S.FTag;
  Changed(False);
end;

procedure TNimbusSankeyNode.SetId(const Value: string);
begin
  if FId = Value then Exit; FId := Value; Changed(False);
end;

procedure TNimbusSankeyNode.UpdateLayout(const Bounds: TRectF; const Value: Double; const Layer: Integer);
begin FBounds := Bounds; FValue := Value; FLayer := Layer end;

procedure TNimbusSankeyNode.SetLabel(const Value: string);
begin
  if FLabel = Value then Exit; FLabel := Value; Changed(False);
end;

procedure TNimbusSankeyNode.SetColor(const Value: TColor);
begin
  if FColor = Value then Exit; FColor := Value; Changed(False);
end;

procedure TNimbusSankeyNode.SetVisible(const Value: Boolean);
begin
  if FVisible = Value then Exit; FVisible := Value; Changed(False);
end;

procedure TNimbusSankeyNode.SetTag(const Value: NativeInt);
begin
  if FTag = Value then Exit; FTag := Value; Changed(False);
end;

constructor TNimbusSankeyNodeCollection.Create(AOwner: TPersistent);
begin inherited Create(AOwner, TNimbusSankeyNode) end;

function TNimbusSankeyNodeCollection.GetItem(Index: Integer): TNimbusSankeyNode;
begin Result := TNimbusSankeyNode(inherited Items[Index]) end;

function TNimbusSankeyNodeCollection.Add: TNimbusSankeyNode;
begin Result := TNimbusSankeyNode(inherited Add) end;

function TNimbusSankeyNodeCollection.Add(const Id, LabelText: string): TNimbusSankeyNode;
begin
  BeginUpdate; try Result := Add; Result.Id := Id; Result.&Label := LabelText; finally EndUpdate end;
end;

procedure TNimbusSankeyNodeCollection.Update(Item: TCollectionItem);
begin inherited; if Assigned(FOnChange) then FOnChange(Self) end;

constructor TNimbusSankeyLink.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FSourceId := '';
  FTargetId := '';
  FLabel := '';
  FToolTipText := '';
  FValue := 0;
  FColor := clNone;
  FVisible := True;
  FTag := 0;
end;

procedure TNimbusSankeyLink.Assign(Source: TPersistent);
var S: TNimbusSankeyLink;
begin
  if not (Source is TNimbusSankeyLink) then begin inherited; Exit end; S := TNimbusSankeyLink(Source);
  FSourceId := S.FSourceId;
  FTargetId := S.FTargetId;
  FLabel := S.FLabel;
  FToolTipText := S.FToolTipText;
  FValue := S.FValue;
  FColor := S.FColor;
  FVisible := S.FVisible;
  FTag := S.FTag;
  Changed(False);
end;

procedure TNimbusSankeyLink.SetSourceId(const Value: string);
begin
  if FSourceId = Value then Exit; FSourceId := Value; Changed(False);
end;

procedure TNimbusSankeyLink.SetTargetId(const Value: string);
begin
  if FTargetId = Value then Exit; FTargetId := Value; Changed(False);
end;

procedure TNimbusSankeyLink.SetLabel(const Value: string);
begin
  if FLabel = Value then Exit; FLabel := Value; Changed(False);
end;

procedure TNimbusSankeyLink.SetToolTipText(const Value: string);
begin
  if FToolTipText = Value then Exit; FToolTipText := Value; Changed(False);
end;

procedure TNimbusSankeyLink.SetValue(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then begin FValue := 0; Changed(False); Exit end;
  if FValue = Max(0.0, Value) then Exit; FValue := Max(0.0, Value); Changed(False);
end;

procedure TNimbusSankeyLink.SetColor(const Value: TColor);
begin
  if FColor = Value then Exit; FColor := Value; Changed(False);
end;

procedure TNimbusSankeyLink.SetVisible(const Value: Boolean);
begin
  if FVisible = Value then Exit; FVisible := Value; Changed(False);
end;

procedure TNimbusSankeyLink.SetTag(const Value: NativeInt);
begin
  if FTag = Value then Exit; FTag := Value; Changed(False);
end;

constructor TNimbusSankeyLinkCollection.Create(AOwner: TPersistent);
begin inherited Create(AOwner, TNimbusSankeyLink) end;

function TNimbusSankeyLinkCollection.GetItem(Index: Integer): TNimbusSankeyLink;
begin Result := TNimbusSankeyLink(inherited Items[Index]) end;

function TNimbusSankeyLinkCollection.Add: TNimbusSankeyLink;
begin Result := TNimbusSankeyLink(inherited Add) end;

function TNimbusSankeyLinkCollection.Add(const SourceId, TargetId: string; const Value: Double): TNimbusSankeyLink;
begin
  BeginUpdate; try Result := Add; Result.SourceId := SourceId; Result.TargetId := TargetId; Result.Value := Value; finally EndUpdate end;
end;

procedure TNimbusSankeyLinkCollection.Update(Item: TCollectionItem);
begin inherited; if Assigned(FOnChange) then FOnChange(Self) end;

constructor TNimbusSankeyData.Create;
begin
  inherited Create;
  FNodeWidth := 18;
  FNodePadding := 18;
  FLinkOpacity := 0.48;
  FShowNodeLabels := True;
  FShowLinkLabels := False;
  FShowNodeValues := True;
  FShowStageHeaders := True;
  FAutoCreateMissingNodes := True;
  FUseLinkGradient := True;
  FAvoidLabelCollisions := True;
  FSmartNodeLabelPlacement := True;
  FAvoidNodeLabelCollisions := True;
  FShowNodeLabelBackplates := False;
  FCompactStageHeaders := True;
  FShowStageHeaderBackplates := True;
  FStageHeaderHeight := 20;
  FLinkColor := clNone;
  FNodes := TNimbusSankeyNodeCollection.Create(Self); FNodes.OnChange := Changed;
  FLinks := TNimbusSankeyLinkCollection.Create(Self); FLinks.OnChange := Changed;
  FStageTitles := TStringList.Create; TStringList(FStageTitles).OnChange := Changed;
end;

procedure TNimbusSankeyData.Assign(Source: TPersistent);
var S: TNimbusSankeyData;
begin
  if not (Source is TNimbusSankeyData) then begin inherited; Exit end; S := TNimbusSankeyData(Source);
  FNodeWidth := S.FNodeWidth;
  FNodePadding := S.FNodePadding;
  FLinkOpacity := S.FLinkOpacity;
  FShowNodeLabels := S.FShowNodeLabels;
  FShowLinkLabels := S.FShowLinkLabels;
  FShowNodeValues := S.FShowNodeValues;
  FShowStageHeaders := S.FShowStageHeaders;
  FAutoCreateMissingNodes := S.FAutoCreateMissingNodes;
  FUseLinkGradient := S.FUseLinkGradient;
  FAvoidLabelCollisions := S.FAvoidLabelCollisions;
  FSmartNodeLabelPlacement := S.FSmartNodeLabelPlacement;
  FAvoidNodeLabelCollisions := S.FAvoidNodeLabelCollisions;
  FShowNodeLabelBackplates := S.FShowNodeLabelBackplates;
  FCompactStageHeaders := S.FCompactStageHeaders;
  FShowStageHeaderBackplates := S.FShowStageHeaderBackplates;
  FStageHeaderHeight := S.FStageHeaderHeight;
  FLinkColor := S.FLinkColor;
  FNodes.Assign(S.FNodes); FLinks.Assign(S.FLinks); FStageTitles.Assign(S.FStageTitles);
  Changed(Self);
end;

procedure TNimbusSankeyData.SetNodeWidth(const Value: Single);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
  if FNodeWidth = Max(4.0, Value) then Exit; FNodeWidth := Max(4.0, Value); Changed(Self);
end;

procedure TNimbusSankeyData.SetNodePadding(const Value: Single);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
  if FNodePadding = Max(2.0, Value) then Exit; FNodePadding := Max(2.0, Value); Changed(Self);
end;

procedure TNimbusSankeyData.SetLinkOpacity(const Value: Single);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
  if FLinkOpacity = EnsureRange(Value, 0.05, 1.0) then Exit; FLinkOpacity := EnsureRange(Value, 0.05, 1.0); Changed(Self);
end;

procedure TNimbusSankeyData.SetShowNodeLabels(const Value: Boolean);
begin
  if FShowNodeLabels = Value then Exit; FShowNodeLabels := Value; Changed(Self);
end;

procedure TNimbusSankeyData.SetShowLinkLabels(const Value: Boolean);
begin
  if FShowLinkLabels = Value then Exit; FShowLinkLabels := Value; Changed(Self);
end;

procedure TNimbusSankeyData.SetShowNodeValues(const Value: Boolean);
begin
  if FShowNodeValues = Value then Exit; FShowNodeValues := Value; Changed(Self);
end;

procedure TNimbusSankeyData.SetShowStageHeaders(const Value: Boolean);
begin
  if FShowStageHeaders = Value then Exit; FShowStageHeaders := Value; Changed(Self);
end;

procedure TNimbusSankeyData.SetAutoCreateMissingNodes(const Value: Boolean);
begin
  if FAutoCreateMissingNodes = Value then Exit; FAutoCreateMissingNodes := Value; Changed(Self);
end;

procedure TNimbusSankeyData.SetUseLinkGradient(const Value: Boolean);
begin
  if FUseLinkGradient = Value then Exit; FUseLinkGradient := Value; Changed(Self);
end;

procedure TNimbusSankeyData.SetAvoidLabelCollisions(const Value: Boolean);
begin
  if FAvoidLabelCollisions = Value then Exit; FAvoidLabelCollisions := Value; Changed(Self);
end;

procedure TNimbusSankeyData.SetSmartNodeLabelPlacement(const Value: Boolean);
begin
  if FSmartNodeLabelPlacement = Value then Exit; FSmartNodeLabelPlacement := Value; Changed(Self);
end;

procedure TNimbusSankeyData.SetAvoidNodeLabelCollisions(const Value: Boolean);
begin
  if FAvoidNodeLabelCollisions = Value then Exit; FAvoidNodeLabelCollisions := Value; Changed(Self);
end;

procedure TNimbusSankeyData.SetShowNodeLabelBackplates(const Value: Boolean);
begin
  if FShowNodeLabelBackplates = Value then Exit; FShowNodeLabelBackplates := Value; Changed(Self);
end;

procedure TNimbusSankeyData.SetCompactStageHeaders(const Value: Boolean);
begin
  if FCompactStageHeaders = Value then Exit; FCompactStageHeaders := Value; Changed(Self);
end;

procedure TNimbusSankeyData.SetShowStageHeaderBackplates(const Value: Boolean);
begin
  if FShowStageHeaderBackplates = Value then Exit; FShowStageHeaderBackplates := Value; Changed(Self);
end;

procedure TNimbusSankeyData.SetStageHeaderHeight(const Value: Single);
begin
  if IsNan(Value) or IsInfinite(Value) then Exit;
  if FStageHeaderHeight = Max(10.0, Value) then Exit; FStageHeaderHeight := Max(10.0, Value); Changed(Self);
end;

procedure TNimbusSankeyData.SetLinkColor(const Value: TColor);
begin
  if FLinkColor = Value then Exit; FLinkColor := Value; Changed(Self);
end;

destructor TNimbusSankeyData.Destroy;
begin FStageTitles.Free; FLinks.Free; FNodes.Free; inherited end;

procedure TNimbusSankeyData.Changed(Sender: TObject);
begin if Assigned(FOnChange) then FOnChange(Self) end;

procedure TNimbusSankeyData.SetNodes(const Value: TNimbusSankeyNodeCollection);
begin if Value <> nil then FNodes.Assign(Value) end;

procedure TNimbusSankeyData.SetLinks(const Value: TNimbusSankeyLinkCollection);
begin if Value <> nil then FLinks.Assign(Value) end;

procedure TNimbusSankeyData.SetStageTitles(const Value: TStrings);
begin if Value <> nil then FStageTitles.Assign(Value) end;

end.

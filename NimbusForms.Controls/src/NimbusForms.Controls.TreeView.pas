{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.TreeView;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  Winapi.CommCtrl,
  System.Classes,
  System.Types,
  System.UITypes,
  System.Generics.Collections,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.ComCtrls,
  Vcl.Menus,
  Vcl.ImgList,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  NimbusForms.Theming.Palette,
  NimbusForms.Controls.Types,
  NimbusForms.Rendering.Canvas,
  NimbusForms.Rendering.TreeView;

type
  TCustomThemedTreeView = class;

  TThemedTreeCheckState = (ttcsUnchecked, ttcsChecked, ttcsIndeterminate);
  TThemedTreeDropPosition = (ttdpNone, ttdpBefore, ttdpAfter, ttdpAsChild);
  TThemedTreeDragDropMode = (ttdmReorderOnly, ttdmReorderAndReparent, ttdmChildOnly);
  TThemedTreeViewDensity = (ttvdNormal, ttvdCompact);

  TThemedTreeNode = class(TTreeNode)
  private
    FRightImage: Vcl.Graphics.TBitmap;
    FBadgeText: string;
    FBadgeColor: TColor;
    FDisabled: Boolean;
    FSubtitle: string;
    FStatusColor: TColor;
    FIsSeparator: Boolean;
    FIsFavorite: Boolean;
    FProgressValue: Integer;
    FShowProgress: Boolean;
    FCheckState: TThemedTreeCheckState;
    FAllowDrag: Boolean;
    FAllowDrop: Boolean;
    FGlyphText: string;
    FGlyphFont: TFont;
    FGlyphColor: TColor;
    FUseThemeGlyphColor: Boolean;
    FRightGlyphText: string;
    FRightGlyphFont: TFont;
    FRightGlyphColor: TColor;
    FUseThemeRightGlyphColor: Boolean;
    FThemedContextMenu: TPopupMenu;
    procedure Changed;
    procedure ImageChanged(Sender: TObject);
    procedure GlyphFontChanged(Sender: TObject);
    procedure RightGlyphFontChanged(Sender: TObject);
    procedure SetRightImage(const AValue: Vcl.Graphics.TBitmap);
    procedure SetBadgeText(const AValue: string);
    procedure SetBadgeColor(const AValue: TColor);
    procedure SetSubtitle(const AValue: string);
    procedure SetStatusColor(const AValue: TColor);
    procedure SetDisabled(const AValue: Boolean);
    procedure SetIsSeparator(const AValue: Boolean);
    procedure SetIsFavorite(const AValue: Boolean);
    procedure SetProgressValue(const AValue: Integer);
    procedure SetShowProgress(const AValue: Boolean);
    procedure SetCheckState(const AValue: TThemedTreeCheckState);
    procedure SetAllowDrag(const AValue: Boolean);
    procedure SetAllowDrop(const AValue: Boolean);
    procedure SetGlyphText(const AValue: string);
    procedure SetGlyphFontFamily(const AValue: string);
    function GetGlyphFontFamily: string;
    procedure SetGlyphFontSize(const AValue: Integer);
    function GetGlyphFontSize: Integer;
    procedure SetGlyphColor(const AValue: TColor);
    procedure SetUseThemeGlyphColor(const AValue: Boolean);
    procedure SetRightGlyphText(const AValue: string);
    procedure SetRightGlyphFontFamily(const AValue: string);
    function GetRightGlyphFontFamily: string;
    procedure SetRightGlyphFontSize(const AValue: Integer);
    function GetRightGlyphFontSize: Integer;
    procedure SetRightGlyphColor(const AValue: TColor);
    procedure SetUseThemeRightGlyphColor(const AValue: Boolean);
    procedure SetThemedContextMenu(const AValue: TPopupMenu);
  public
    constructor Create(AOwner: TTreeNodes); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property RightImage: Vcl.Graphics.TBitmap read FRightImage write SetRightImage;
    property BadgeText: string read FBadgeText write SetBadgeText;
    property BadgeColor: TColor read FBadgeColor write SetBadgeColor default clNone;
    property Subtitle: string read FSubtitle write SetSubtitle;
    property StatusColor: TColor read FStatusColor write SetStatusColor default clNone;
    property Disabled: Boolean read FDisabled write SetDisabled default False;
    property IsSeparator: Boolean read FIsSeparator write SetIsSeparator default False;
    property IsFavorite: Boolean read FIsFavorite write SetIsFavorite default False;
    property ProgressValue: Integer read FProgressValue write SetProgressValue default 0;
    property ShowProgress: Boolean read FShowProgress write SetShowProgress default False;
    property ThemedCheckState: TThemedTreeCheckState read FCheckState write SetCheckState default ttcsUnchecked;
    property AllowDrag: Boolean read FAllowDrag write SetAllowDrag default True;
    property AllowDrop: Boolean read FAllowDrop write SetAllowDrop default True;
    property GlyphText: string read FGlyphText write SetGlyphText;
    property GlyphFontFamily: string read GetGlyphFontFamily write SetGlyphFontFamily;
    property GlyphFontSize: Integer read GetGlyphFontSize write SetGlyphFontSize default 14;
    property GlyphColor: TColor read FGlyphColor write SetGlyphColor default clNone;
    property UseThemeGlyphColor: Boolean read FUseThemeGlyphColor write SetUseThemeGlyphColor default True;
    property RightGlyphText: string read FRightGlyphText write SetRightGlyphText;
    property RightGlyphFontFamily: string read GetRightGlyphFontFamily write SetRightGlyphFontFamily;
    property RightGlyphFontSize: Integer read GetRightGlyphFontSize write SetRightGlyphFontSize default 14;
    property RightGlyphColor: TColor read FRightGlyphColor write SetRightGlyphColor default clNone;
    property UseThemeRightGlyphColor: Boolean read FUseThemeRightGlyphColor write SetUseThemeRightGlyphColor default True;
    property ThemedContextMenu: TPopupMenu read FThemedContextMenu write SetThemedContextMenu;
    property GlyphFont: TFont read FGlyphFont;
    property RightGlyphFont: TFont read FRightGlyphFont;
  end;

  TThemedTreeNodeMouseEvent = procedure(Sender: TObject; ANode: TTreeNode; const ALocation: TPoint; AButton: TMouseButton; AClicks: Integer) of object;
  TThemedTreeNodeCancelEvent = procedure(Sender: TObject; ANode: TTreeNode; var ACancel: Boolean) of object;
  TThemedTreeNodeCheckChangedEvent = procedure(Sender: TObject; ANode: TTreeNode; AOldState, ANewState: TThemedTreeCheckState) of object;
  TThemedTreeNodeLazyLoadEvent = procedure(Sender: TObject; ANode: TTreeNode) of object;
  TThemedTreeNodeRenameEvent = procedure(Sender: TObject; ANode: TTreeNode; const AOldText: string; var ANewText: string; var ACancel: Boolean) of object;
  TThemedTreeNodeContextMenuOpeningEvent = procedure(Sender: TObject; ANode: TTreeNode; const ALocation: TPoint; var AMenu: TPopupMenu; var ACancel: Boolean) of object;
  TThemedTreeNodeDragStartingEvent = procedure(Sender: TObject; ANode: TTreeNode; var ACancel: Boolean) of object;
  TThemedTreeNodeDragOverEvent = procedure(Sender: TObject; ASourceNode, ATargetNode: TTreeNode; ADropPosition: TThemedTreeDropPosition; var ACancel: Boolean) of object;
  TThemedTreeNodeDroppedEvent = procedure(Sender: TObject; ANode, ATargetNode, AOldParent, ANewParent: TTreeNode; AOldIndex, ANewIndex: Integer; ADropPosition: TThemedTreeDropPosition) of object;

  TCustomThemedTreeView = class(TCustomTreeView, IThemeAware)
  private
    FPalette: TThemePalette;
    FRenderCanvas: INimbusRenderCanvas;
    FThemeRegistered: Boolean;
    FHoveredNode: TTreeNode;
    FImageBuffer: Vcl.Graphics.TBitmap;
    FDensity: TThemedTreeViewDensity;
    FStyleMode: TThemedControlStyleMode;
    FShowThemedCheckBoxes: Boolean;
    FTriStateCheckBoxes: Boolean;
    FAutoCheckChildren: Boolean;
    FAutoCheckParents: Boolean;
    FShowSubtitles: Boolean;
    FShowStatusColor: Boolean;
    FShowFavorites: Boolean;
    FShowProgress: Boolean;
    FRoundedSelection: Boolean;
    FFilterText: string;
    FHighlightFilterMatches: Boolean;
    FNodeContextMenu: TPopupMenu;
    FNodeContextMenuNodes: TList<TThemedTreeNode>;
    FRenameEdit: TEdit;
    FRenameNode: TTreeNode;
    FDragCandidateNode: TTreeNode;
    FDragNode: TTreeNode;
    FDropNode: TTreeNode;
    FPendingDropNode: TTreeNode;
    FDragExpandNode: TTreeNode;
    FDropPosition: TThemedTreeDropPosition;
    FPendingDropPosition: TThemedTreeDropPosition;
    FDropCommitted: Boolean;
    FDragExpandTimer: TTimer;
    FAllowNodeDragDrop: Boolean;
    FAutoExpandOnDrag: Boolean;
    FAutoExpandDelay: Integer;
    FDragDropMode: TThemedTreeDragDropMode;
    FItemHeight: Integer;
    FLogicalItemHeight: Integer;
    FLogicalItemHeightWithSubtitle: Integer;
    FLogicalIndent: Integer;
    FLogicalLeftPadding: Integer;
    FLogicalSpacing: Integer;
    FLogicalChevronSize: Integer;
    FLogicalBadgeHeight: Integer;
    FLogicalBadgePadding: Integer;
    FLogicalRightPadding: Integer;
    FLogicalCheckSize: Integer;
    FLogicalStatusSize: Integer;
    FLogicalProgressHeight: Integer;
    FLogicalSelectionRadius: Integer;
    FLogicalDropIndicatorThickness: Integer;
    FLogicalGlyphSize: Integer;
    FLogicalChevronStroke: Single;
    FMetrics: TThemedTreeItemMetrics;
    FOnNodeClickedEx: TThemedTreeNodeMouseEvent;
    FOnNodeDoubleClickedEx: TThemedTreeNodeMouseEvent;
    FOnNodeRightClicked: TThemedTreeNodeMouseEvent;
    FOnNodeExpandingEx: TThemedTreeNodeCancelEvent;
    FOnNodeCollapsingEx: TThemedTreeNodeCancelEvent;
    FOnNodeCheckChanged: TThemedTreeNodeCheckChangedEvent;
    FOnNodeLazyLoad: TThemedTreeNodeLazyLoadEvent;
    FOnNodeRenamed: TThemedTreeNodeRenameEvent;
    FOnNodeContextMenuOpening: TThemedTreeNodeContextMenuOpeningEvent;
    FOnNodeDragStarting: TThemedTreeNodeDragStartingEvent;
    FOnNodeDragOverEx: TThemedTreeNodeDragOverEvent;
    FOnNodeDropped: TThemedTreeNodeDroppedEvent;
    procedure SetStyleMode(const AValue: TThemedControlStyleMode);
    procedure RegisterThemeAware;
    procedure ApplyMetrics;
    procedure SetItemHeight(const AValue: Integer);
    function GetCompactIdeMode: Boolean;
    procedure SetCompactIdeMode(const AValue: Boolean);
    procedure SetDensity(const AValue: TThemedTreeViewDensity);
    procedure SetShowThemedCheckBoxes(const AValue: Boolean);
    procedure SetTriStateCheckBoxes(const AValue: Boolean);
    procedure SetAutoCheckChildren(const AValue: Boolean);
    procedure SetAutoCheckParents(const AValue: Boolean);
    procedure SetShowSubtitles(const AValue: Boolean);
    procedure SetShowStatusColor(const AValue: Boolean);
    procedure SetShowFavorites(const AValue: Boolean);
    procedure SetShowProgress(const AValue: Boolean);
    procedure SetRoundedSelection(const AValue: Boolean);
    procedure SetFilterText(const AValue: string);
    procedure SetHighlightFilterMatches(const AValue: Boolean);
    procedure SetNodeContextMenu(const AValue: TPopupMenu);
    procedure SetAllowNodeDragDrop(const AValue: Boolean);
    procedure SetAutoExpandOnDrag(const AValue: Boolean);
    procedure SetAutoExpandDelay(const AValue: Integer);
    procedure SetDragDropMode(const AValue: TThemedTreeDragDropMode);
    procedure RenameEditExit(Sender: TObject);
    procedure RenameEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DragExpandTimerTick(Sender: TObject);
    function CanDragNode(ANode: TTreeNode): Boolean;
    function CanDropNode(ASourceNode, ATargetNode: TTreeNode; APosition: TThemedTreeDropPosition): Boolean;
    function IsChildOf(APossibleChild, APossibleParent: TTreeNode): Boolean;
    function GetDropPosition(ATargetNode: TTreeNode; const APoint: TPoint): TThemedTreeDropPosition;
    procedure SetDropState(ANode: TTreeNode; APosition: TThemedTreeDropPosition);
    procedure ClearDropTargetState;
    procedure ClearDropState;
    procedure HandleDragAutoExpand(ATargetNode: TTreeNode);
    procedure MoveNode(ASourceNode, ATargetNode: TTreeNode; APosition: TThemedTreeDropPosition);
    procedure EndRename(const AApply: Boolean);
    procedure ClearNodeContextMenuReference(AMenu: TPopupMenu);
    function ContainsNodeReference(ANode: TTreeNode): Boolean;
    procedure UpdateRenameBounds;
    function GetNodeAtPoint(const APoint: TPoint): TTreeNode;
    function BuildRenderContext(ANode: TTreeNode; const AState: TCustomDrawState): TThemedTreeItemRenderContext;
    function GetInteractionLayout(ANode: TTreeNode): TThemedTreeItemLayout;
    procedure InvalidateNode(ANode: TTreeNode);
    function GetNodeCheckState(ANode: TTreeNode): TThemedTreeCheckState;
    procedure SetNodeCheckState(ANode: TTreeNode; const AState: TThemedTreeCheckState; const ARaiseEvent: Boolean);
    procedure ToggleNodeCheck(ANode: TTreeNode);
    procedure SetChildrenCheckState(ANode: TTreeNode; const AState: TThemedTreeCheckState);
    procedure UpdateParentCheckState(ANode: TTreeNode);
    procedure FindNodesRecursive(ANode: TTreeNode; const AText: string; AList: TList<TTreeNode>);
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  protected
    function CreateNode: TTreeNode; override;
    function CanEdit(Node: TTreeNode): Boolean; override;
    function CanExpand(Node: TTreeNode): Boolean; override;
    function CanCollapse(Node: TTreeNode): Boolean; override;
    procedure Delete(Node: TTreeNode); override;
    function IsCustomDrawn(Target: TCustomDrawTarget; Stage: TCustomDrawStage): Boolean; override;
    function CustomDraw(const ARect: TRect; Stage: TCustomDrawStage): Boolean; override;
    function CustomDrawItem(Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage; var PaintImages: Boolean): Boolean; override;
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure WndProc(var Message: TMessage); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DblClick; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DoStartDrag(var DragObject: TDragObject); override;
    procedure DoEndDrag(Target: TObject; X, Y: Integer); override;
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean); override;
    procedure DoContextPopup(MousePos: TPoint; var Handled: Boolean); override;
    property ItemHeight: Integer read FItemHeight write SetItemHeight;
    property StyleMode: TThemedControlStyleMode read FStyleMode write SetStyleMode default stNormal;
    property Density: TThemedTreeViewDensity read FDensity write SetDensity default ttvdNormal;
    property CompactIdeMode: Boolean read GetCompactIdeMode write SetCompactIdeMode default False;
    property ShowThemedCheckBoxes: Boolean read FShowThemedCheckBoxes write SetShowThemedCheckBoxes default False;
    property TriStateCheckBoxes: Boolean read FTriStateCheckBoxes write SetTriStateCheckBoxes default True;
    property AutoCheckChildren: Boolean read FAutoCheckChildren write SetAutoCheckChildren default True;
    property AutoCheckParents: Boolean read FAutoCheckParents write SetAutoCheckParents default True;
    property ShowSubtitles: Boolean read FShowSubtitles write SetShowSubtitles default True;
    property ShowStatusColor: Boolean read FShowStatusColor write SetShowStatusColor default True;
    property ShowFavorites: Boolean read FShowFavorites write SetShowFavorites default True;
    property ShowProgress: Boolean read FShowProgress write SetShowProgress default True;
    property RoundedSelection: Boolean read FRoundedSelection write SetRoundedSelection default True;
    property FilterText: string read FFilterText write SetFilterText;
    property HighlightFilterMatches: Boolean read FHighlightFilterMatches write SetHighlightFilterMatches default True;
    property NodeContextMenu: TPopupMenu read FNodeContextMenu write SetNodeContextMenu;
    property AllowNodeDragDrop: Boolean read FAllowNodeDragDrop write SetAllowNodeDragDrop default False;
    property AutoExpandOnDrag: Boolean read FAutoExpandOnDrag write SetAutoExpandOnDrag default True;
    property AutoExpandDelay: Integer read FAutoExpandDelay write SetAutoExpandDelay default 700;
    property DragDropMode: TThemedTreeDragDropMode read FDragDropMode write SetDragDropMode default ttdmReorderAndReparent;
    property OnNodeClickedEx: TThemedTreeNodeMouseEvent read FOnNodeClickedEx write FOnNodeClickedEx;
    property OnNodeDoubleClickedEx: TThemedTreeNodeMouseEvent read FOnNodeDoubleClickedEx write FOnNodeDoubleClickedEx;
    property OnNodeRightClicked: TThemedTreeNodeMouseEvent read FOnNodeRightClicked write FOnNodeRightClicked;
    property OnNodeExpandingEx: TThemedTreeNodeCancelEvent read FOnNodeExpandingEx write FOnNodeExpandingEx;
    property OnNodeCollapsingEx: TThemedTreeNodeCancelEvent read FOnNodeCollapsingEx write FOnNodeCollapsingEx;
    property OnNodeCheckChanged: TThemedTreeNodeCheckChangedEvent read FOnNodeCheckChanged write FOnNodeCheckChanged;
    property OnNodeLazyLoad: TThemedTreeNodeLazyLoadEvent read FOnNodeLazyLoad write FOnNodeLazyLoad;
    property OnNodeRenamed: TThemedTreeNodeRenameEvent read FOnNodeRenamed write FOnNodeRenamed;
    property OnNodeContextMenuOpening: TThemedTreeNodeContextMenuOpeningEvent read FOnNodeContextMenuOpening write FOnNodeContextMenuOpening;
    property OnNodeDragStarting: TThemedTreeNodeDragStartingEvent read FOnNodeDragStarting write FOnNodeDragStarting;
    property OnNodeDragOverEx: TThemedTreeNodeDragOverEvent read FOnNodeDragOverEx write FOnNodeDragOverEx;
    property OnNodeDropped: TThemedTreeNodeDroppedEvent read FOnNodeDropped write FOnNodeDropped;
  public
    procedure DragDrop(Source: TObject; X, Y: Integer); override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette); virtual;
    procedure ApplyCompactIdeMetrics;
    procedure ApplyComfortableMetrics;
    procedure ExpandAllSafe;
    procedure CollapseAllSafe;
    procedure FindNodes(const AText: string; AList: TList<TTreeNode>);
    procedure SelectFirstMatch(const AText: string);
    procedure EnsureNodeVisibleEx(ANode: TTreeNode);
    procedure BeginRename(ANode: TTreeNode);
    procedure CancelRename;
    procedure BindAction(const AAction: TBasicAction);
    procedure UnbindAction;
    procedure SyncAction;
  end;

  TThemedTreeView = class(TCustomThemedTreeView)
  published
    property StyleMode;
    property Action;
    property Align;
    property Anchors;
    property AutoExpand;
    property AllowNodeDragDrop;
    property AutoExpandDelay;
    property AutoExpandOnDrag;
    property AutoCheckChildren;
    property AutoCheckParents;
    property BiDiMode;
    property BorderStyle default bsNone;
    property ChangeDelay;
    property Color;
    property CompactIdeMode;
    property Density;
    property DragDropMode;
    property Constraints;
    property Enabled;
    property FilterText;
    property Font;
    property HideSelection default False;
    property HighlightFilterMatches;
    property Images;
    property ItemHeight;
    property Items;
    property MultiSelect;
    property MultiSelectStyle;
    property NodeContextMenu;
    property ParentBiDiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property RightClickSelect;
    property RoundedSelection;
    property RowSelect default True;
    property ShowFavorites;
    property ShowHint;
    property ShowProgress;
    property ShowStatusColor;
    property ShowSubtitles;
    property ShowThemedCheckBoxes;
    property SortType;
    property TabOrder;
    property TabStop default True;
    property ToolTips;
    property TriStateCheckBoxes;
    property Visible;
    property OnAddition;
    property OnChange;
    property OnChanging;
    property OnClick;
    property OnCollapsed;
    property OnCollapsing;
    property OnContextPopup;
    property OnDblClick;
    property OnDeletion;
    property OnDragDrop;
    property OnDragOver;
    property OnEnter;
    property OnExit;
    property OnExpanded;
    property OnExpanding;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnNodeCheckChanged;
    property OnNodeClickedEx;
    property OnNodeCollapsingEx;
    property OnNodeDoubleClickedEx;
    property OnNodeExpandingEx;
    property OnNodeLazyLoad;
    property OnNodeRenamed;
    property OnNodeContextMenuOpening;
    property OnNodeDragStarting;
    property OnNodeDragOverEx;
    property OnNodeDropped;
    property OnNodeRightClicked;
    property OnStartDrag;
  end;

implementation

uses
  System.SysUtils,
  System.StrUtils,
  System.Math,
  NimbusForms.Theming.Manager,
  NimbusForms.Theming.Types,
  NimbusForms.Rendering.Types;

constructor TThemedTreeNode.Create(AOwner: TTreeNodes);
begin
  inherited Create(AOwner);
  FRightImage := Vcl.Graphics.TBitmap.Create;
  FRightImage.OnChange := ImageChanged;
  FGlyphFont := TFont.Create;
  FGlyphFont.Name := 'Segoe MDL2 Assets';
  FGlyphFont.Size := 14;
  FGlyphFont.OnChange := GlyphFontChanged;
  FRightGlyphFont := TFont.Create;
  FRightGlyphFont.Name := 'Segoe MDL2 Assets';
  FRightGlyphFont.Size := 14;
  FRightGlyphFont.OnChange := RightGlyphFontChanged;
  FBadgeColor := clNone;
  FStatusColor := clNone;
  FProgressValue := 0;
  FShowProgress := False;
  FCheckState := ttcsUnchecked;
  FAllowDrag := True;
  FAllowDrop := True;
  FGlyphColor := clNone;
  FUseThemeGlyphColor := True;
  FRightGlyphColor := clNone;
  FUseThemeRightGlyphColor := True;
end;

destructor TThemedTreeNode.Destroy;
begin
  SetThemedContextMenu(nil);
  FRightGlyphFont.Free;
  FGlyphFont.Free;
  FRightImage.Free;
  inherited Destroy;
end;

procedure TThemedTreeNode.Assign(Source: TPersistent);
var
  LSource: TThemedTreeNode;
begin
  inherited Assign(Source);
  if Source is TThemedTreeNode then
  begin
    LSource := TThemedTreeNode(Source);
    FRightImage.Assign(LSource.FRightImage);
    FBadgeText := LSource.FBadgeText;
    FBadgeColor := LSource.FBadgeColor;
    FSubtitle := LSource.FSubtitle;
    FStatusColor := LSource.FStatusColor;
    FDisabled := LSource.FDisabled;
    FIsSeparator := LSource.FIsSeparator;
    FIsFavorite := LSource.FIsFavorite;
    FProgressValue := LSource.FProgressValue;
    FShowProgress := LSource.FShowProgress;
    FCheckState := LSource.FCheckState;
    FAllowDrag := LSource.FAllowDrag;
    FAllowDrop := LSource.FAllowDrop;
    FGlyphText := LSource.FGlyphText;
    FGlyphFont.Assign(LSource.FGlyphFont);
    FGlyphColor := LSource.FGlyphColor;
    FUseThemeGlyphColor := LSource.FUseThemeGlyphColor;
    FRightGlyphText := LSource.FRightGlyphText;
    FRightGlyphFont.Assign(LSource.FRightGlyphFont);
    FRightGlyphColor := LSource.FRightGlyphColor;
    FUseThemeRightGlyphColor := LSource.FUseThemeRightGlyphColor;
    SetThemedContextMenu(LSource.FThemedContextMenu);
    Changed;
  end;
end;

procedure TThemedTreeNode.Changed;
begin
  if TreeView is TCustomThemedTreeView then TCustomThemedTreeView(TreeView).InvalidateNode(Self) else if TreeView <> nil then TreeView.Invalidate;
end;

procedure TThemedTreeNode.ImageChanged(Sender: TObject); begin Changed; end;
procedure TThemedTreeNode.GlyphFontChanged(Sender: TObject); begin Changed; end;
procedure TThemedTreeNode.RightGlyphFontChanged(Sender: TObject); begin Changed; end;
procedure TThemedTreeNode.SetRightImage(const AValue: Vcl.Graphics.TBitmap); begin FRightImage.Assign(AValue); end;
procedure TThemedTreeNode.SetBadgeText(const AValue: string); begin if FBadgeText <> AValue then begin FBadgeText := AValue; Changed; end; end;
procedure TThemedTreeNode.SetBadgeColor(const AValue: TColor); begin if FBadgeColor <> AValue then begin FBadgeColor := AValue; Changed; end; end;
procedure TThemedTreeNode.SetSubtitle(const AValue: string); begin if FSubtitle <> AValue then begin FSubtitle := AValue; Changed; end; end;
procedure TThemedTreeNode.SetStatusColor(const AValue: TColor); begin if FStatusColor <> AValue then begin FStatusColor := AValue; Changed; end; end;
procedure TThemedTreeNode.SetDisabled(const AValue: Boolean); begin if FDisabled <> AValue then begin FDisabled := AValue; Changed; end; end;
procedure TThemedTreeNode.SetIsSeparator(const AValue: Boolean); begin if FIsSeparator <> AValue then begin FIsSeparator := AValue; Changed; end; end;
procedure TThemedTreeNode.SetIsFavorite(const AValue: Boolean); begin if FIsFavorite <> AValue then begin FIsFavorite := AValue; Changed; end; end;
procedure TThemedTreeNode.SetShowProgress(const AValue: Boolean); begin if FShowProgress <> AValue then begin FShowProgress := AValue; Changed; end; end;
procedure TThemedTreeNode.SetCheckState(const AValue: TThemedTreeCheckState); begin if FCheckState <> AValue then begin FCheckState := AValue; Changed; end; end;
procedure TThemedTreeNode.SetAllowDrag(const AValue: Boolean); begin FAllowDrag := AValue; end;
procedure TThemedTreeNode.SetAllowDrop(const AValue: Boolean); begin FAllowDrop := AValue; end;
procedure TThemedTreeNode.SetGlyphText(const AValue: string); begin if FGlyphText <> AValue then begin FGlyphText := AValue; Changed; end; end;
procedure TThemedTreeNode.SetGlyphColor(const AValue: TColor); begin if FGlyphColor <> AValue then begin FGlyphColor := AValue; Changed; end; end;
procedure TThemedTreeNode.SetUseThemeGlyphColor(const AValue: Boolean); begin if FUseThemeGlyphColor <> AValue then begin FUseThemeGlyphColor := AValue; Changed; end; end;
procedure TThemedTreeNode.SetRightGlyphText(const AValue: string); begin if FRightGlyphText <> AValue then begin FRightGlyphText := AValue; Changed; end; end;
procedure TThemedTreeNode.SetRightGlyphColor(const AValue: TColor); begin if FRightGlyphColor <> AValue then begin FRightGlyphColor := AValue; Changed; end; end;
procedure TThemedTreeNode.SetUseThemeRightGlyphColor(const AValue: Boolean); begin if FUseThemeRightGlyphColor <> AValue then begin FUseThemeRightGlyphColor := AValue; Changed; end; end;

procedure TThemedTreeNode.SetThemedContextMenu(const AValue: TPopupMenu);
var LTree: TCustomThemedTreeView;
begin
  if FThemedContextMenu = AValue then Exit;
  FThemedContextMenu := AValue;
  if TreeView is TCustomThemedTreeView then
  begin
    LTree := TCustomThemedTreeView(TreeView);
    if FThemedContextMenu <> nil then
    begin
      if LTree.FNodeContextMenuNodes = nil then LTree.FNodeContextMenuNodes := TList<TThemedTreeNode>.Create;
      if LTree.FNodeContextMenuNodes.IndexOf(Self) < 0 then LTree.FNodeContextMenuNodes.Add(Self);
      FThemedContextMenu.FreeNotification(LTree);
    end
    else if LTree.FNodeContextMenuNodes <> nil then LTree.FNodeContextMenuNodes.Remove(Self);
  end
  else if (FThemedContextMenu <> nil) and (TreeView <> nil) then FThemedContextMenu.FreeNotification(TreeView);
end;

procedure TThemedTreeNode.SetProgressValue(const AValue: Integer);
var LValue: Integer;
begin
  LValue := EnsureRange(AValue, 0, 100);
  if FProgressValue <> LValue then begin FProgressValue := LValue; Changed; end;
end;

procedure TThemedTreeNode.SetGlyphFontFamily(const AValue: string); begin if FGlyphFont.Name <> AValue then FGlyphFont.Name := AValue; end;
function TThemedTreeNode.GetGlyphFontFamily: string; begin Result := FGlyphFont.Name; end;
procedure TThemedTreeNode.SetGlyphFontSize(const AValue: Integer); begin if FGlyphFont.Size <> Max(1, AValue) then FGlyphFont.Size := Max(1, AValue); end;
function TThemedTreeNode.GetGlyphFontSize: Integer; begin Result := FGlyphFont.Size; end;
procedure TThemedTreeNode.SetRightGlyphFontFamily(const AValue: string); begin if FRightGlyphFont.Name <> AValue then FRightGlyphFont.Name := AValue; end;
function TThemedTreeNode.GetRightGlyphFontFamily: string; begin Result := FRightGlyphFont.Name; end;
procedure TThemedTreeNode.SetRightGlyphFontSize(const AValue: Integer); begin if FRightGlyphFont.Size <> Max(1, AValue) then FRightGlyphFont.Size := Max(1, AValue); end;
function TThemedTreeNode.GetRightGlyphFontSize: Integer; begin Result := FRightGlyphFont.Size; end;

constructor TCustomThemedTreeView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ParentColor := False;
  DoubleBuffered := True;
  BorderStyle := bsNone;
  HideSelection := False;
  RowSelect := True;
  ShowButtons := False;
  ShowLines := False;
  ShowRoot := False;
  HotTrack := False;
  CheckBoxes := False;
  TabStop := True;
  FRenderCanvas := TNimbusRenderCanvas.Create;
  FImageBuffer := Vcl.Graphics.TBitmap.Create;
  FDensity := ttvdNormal;
  FShowThemedCheckBoxes := False;
  FTriStateCheckBoxes := True;
  FAutoCheckChildren := True;
  FAutoCheckParents := True;
  FShowSubtitles := True;
  FShowStatusColor := True;
  FShowFavorites := True;
  FShowProgress := True;
  FRoundedSelection := True;
  FHighlightFilterMatches := True;
  FAllowNodeDragDrop := False;
  FAutoExpandOnDrag := True;
  FAutoExpandDelay := 700;
  FDragDropMode := ttdmReorderAndReparent;
  FDropPosition := ttdpNone;
  FPendingDropPosition := ttdpNone;
  FDropCommitted := False;
  FDragExpandTimer := TTimer.Create(Self);
  FDragExpandTimer.Enabled := False;
  FDragExpandTimer.Interval := FAutoExpandDelay;
  FDragExpandTimer.OnTimer := DragExpandTimerTick;
  DragKind := dkDrag;
  DragMode := dmManual;
  ApplyComfortableMetrics;
  ApplyMetrics;
end;

destructor TCustomThemedTreeView.Destroy;
begin
  if FDragExpandTimer <> nil then begin FDragExpandTimer.Enabled := False; FDragExpandTimer.OnTimer := nil; end;
  if FRenameEdit <> nil then begin FRenameEdit.OnExit := nil; FRenameEdit.OnKeyDown := nil; end;
  if FThemeRegistered then begin ThemeManager.UnregisterAware(Self); FThemeRegistered := False; end;
  if FNodeContextMenu <> nil then FNodeContextMenu.RemoveFreeNotification(Self);
  FreeAndNil(FNodeContextMenuNodes);
  FImageBuffer.Free;
  FPalette.Free;
  FRenderCanvas := nil;
  inherited Destroy;
end;

procedure TCustomThemedTreeView.RegisterThemeAware;
begin
  if FThemeRegistered or (csLoading in ComponentState) or (csReading in ComponentState) or (csDestroying in ComponentState) then Exit;
  ThemeManager.RegisterAware(Self);
  FThemeRegistered := True;
end;

procedure TCustomThemedTreeView.CreateWnd;
begin
  inherited CreateWnd;
  Perform(TVM_SETITEMHEIGHT, FItemHeight, 0);
  Indent := FMetrics.Indent;
end;

procedure TCustomThemedTreeView.Loaded;
begin
  inherited Loaded;
  ApplyMetrics;
  RegisterThemeAware;
end;

procedure TCustomThemedTreeView.WndProc(var Message: TMessage);
begin
  inherited WndProc(Message);
  if csDestroying in ComponentState then Exit;
  case Message.Msg of
    CM_SHOWINGCHANGED:
      if Showing then RegisterThemeAware;
    CM_ENABLEDCHANGED:
      begin
        if not Enabled and (FRenameNode <> nil) then EndRename(False);
        Invalidate;
      end;
    CM_FONTCHANGED, CM_COLORCHANGED:
      begin
        UpdateRenameBounds;
        Invalidate;
      end;
    WM_SIZE, WM_VSCROLL, WM_HSCROLL, WM_MOUSEWHEEL:
      UpdateRenameBounds;
  end;
end;

procedure TCustomThemedTreeView.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation <> opRemove then Exit;
  if AComponent = FNodeContextMenu then FNodeContextMenu := nil;
  if AComponent is TPopupMenu then ClearNodeContextMenuReference(TPopupMenu(AComponent));
end;

procedure TCustomThemedTreeView.ClearNodeContextMenuReference(AMenu: TPopupMenu);
var
  LNode: TThemedTreeNode;
  I: Integer;
begin
  if (AMenu = nil) or (FNodeContextMenuNodes = nil) then Exit;
  for I := FNodeContextMenuNodes.Count - 1 downto 0 do
  begin
    LNode := FNodeContextMenuNodes[I];
    if LNode.FThemedContextMenu = AMenu then
    begin LNode.FThemedContextMenu := nil; FNodeContextMenuNodes.Delete(I); end;
  end;
end;

function TCustomThemedTreeView.ContainsNodeReference(ANode: TTreeNode): Boolean;
var
  LNode: TTreeNode;
begin
  Result := False;
  if ANode = nil then Exit;
  LNode := Items.GetFirstNode;
  while LNode <> nil do
  begin
    if LNode = ANode then Exit(True);
    LNode := LNode.GetNext;
  end;
end;

procedure TCustomThemedTreeView.UpdateRenameBounds;
var
  LLayout: TThemedTreeItemLayout;
  LRect: TRect;
begin
  if (FRenameEdit = nil) or not FRenameEdit.Visible or (FRenameNode = nil) then Exit;
  if not ContainsNodeReference(FRenameNode) then
  begin
    FRenameNode := nil;
    FRenameEdit.Visible := False;
    Exit;
  end;
  LLayout := GetInteractionLayout(FRenameNode);
  LRect := LLayout.TextRect;
  if IsRectEmpty(LRect) or (LRect.Bottom <= 0) or (LRect.Top >= ClientHeight) then
  begin
    EndRename(True);
    Exit;
  end;
  FRenameEdit.SetBounds(LRect.Left, LRect.Top, Max(32, LRect.Width), Max(NimbusScaleValue(18, CurrentPPI), LRect.Height));
end;

function TCustomThemedTreeView.CreateNode: TTreeNode;
begin
  Result := TThemedTreeNode.Create(Items);
end;

procedure TCustomThemedTreeView.ApplyTheme(const APalette: TThemePalette);
begin
  if APalette = nil then Exit;
  if FPalette = nil then FPalette := APalette.Clone else FPalette.Assign(APalette);
  Color := ThemeColorToColor(FPalette.MenuBackColor);
  Font.Color := ThemeColorToColor(FPalette.MenuForeColor);
  if FRenameEdit <> nil then
  begin
    FRenameEdit.Color := ThemeColorToColor(FPalette.InputBackColor);
    FRenameEdit.Font.Color := ThemeColorToColor(FPalette.InputForeColor);
  end;
  if not (csDestroying in ComponentState) then Invalidate;
end;

procedure TCustomThemedTreeView.ApplyCompactIdeMetrics;
begin
  FLogicalItemHeight := 19;
  FLogicalItemHeightWithSubtitle := 29;
  FLogicalIndent := 12;
  FLogicalLeftPadding := 4;
  FLogicalSpacing := 3;
  FLogicalChevronSize := 11;
  FLogicalBadgeHeight := 14;
  FLogicalBadgePadding := 8;
  FLogicalRightPadding := 5;
  FLogicalCheckSize := 13;
  FLogicalStatusSize := 6;
  FLogicalProgressHeight := 2;
  FLogicalSelectionRadius := 3;
  FLogicalDropIndicatorThickness := 2;
  FLogicalGlyphSize := 13;
  FLogicalChevronStroke := 1.2;
end;

procedure TCustomThemedTreeView.ApplyComfortableMetrics;
begin
  FLogicalItemHeight := 28;
  FLogicalItemHeightWithSubtitle := 42;
  FLogicalIndent := 16;
  FLogicalLeftPadding := 8;
  FLogicalSpacing := 6;
  FLogicalChevronSize := 16;
  FLogicalBadgeHeight := 18;
  FLogicalBadgePadding := 12;
  FLogicalRightPadding := 8;
  FLogicalCheckSize := 16;
  FLogicalStatusSize := 8;
  FLogicalProgressHeight := 4;
  FLogicalSelectionRadius := 5;
  FLogicalDropIndicatorThickness := 2;
  FLogicalGlyphSize := 14;
  FLogicalChevronStroke := 1.5;
end;

procedure TCustomThemedTreeView.ApplyMetrics;
begin
  FMetrics.Indent := NimbusScaleValue(FLogicalIndent, CurrentPPI);
  FMetrics.LeftPadding := NimbusScaleValue(FLogicalLeftPadding, CurrentPPI);
  FMetrics.Spacing := NimbusScaleValue(FLogicalSpacing, CurrentPPI);
  FMetrics.ChevronSize := NimbusScaleValue(FLogicalChevronSize, CurrentPPI);
  FMetrics.BadgeHeight := NimbusScaleValue(FLogicalBadgeHeight, CurrentPPI);
  FMetrics.BadgePadding := NimbusScaleValue(FLogicalBadgePadding, CurrentPPI);
  FMetrics.RightPadding := NimbusScaleValue(FLogicalRightPadding, CurrentPPI);
  FMetrics.CheckSize := NimbusScaleValue(FLogicalCheckSize, CurrentPPI);
  FMetrics.StatusSize := NimbusScaleValue(FLogicalStatusSize, CurrentPPI);
  FMetrics.ProgressHeight := Max(2, NimbusScaleValue(FLogicalProgressHeight, CurrentPPI));
  FMetrics.SelectionRadius := NimbusScaleValue(FLogicalSelectionRadius, CurrentPPI);
  FMetrics.DropIndicatorThickness := Max(1, NimbusScaleValue(FLogicalDropIndicatorThickness, CurrentPPI));
  FMetrics.GlyphSize := NimbusScaleValue(FLogicalGlyphSize, CurrentPPI);
  FMetrics.ChevronStroke := FLogicalChevronStroke * CurrentPPI / 96.0;
  if FShowSubtitles then FItemHeight := NimbusScaleValue(FLogicalItemHeightWithSubtitle, CurrentPPI) else FItemHeight := NimbusScaleValue(FLogicalItemHeight, CurrentPPI);
  if HandleAllocated then
  begin
    Perform(TVM_SETITEMHEIGHT, FItemHeight, 0);
    Indent := FMetrics.Indent;
    UpdateRenameBounds;
    Invalidate;
  end;
end;

procedure TCustomThemedTreeView.SetItemHeight(const AValue: Integer);
var LValue: Integer;
begin
  LValue := Max(1, AValue);
  if FItemHeight = LValue then Exit;
  FItemHeight := LValue;
  if HandleAllocated then
  begin
    Perform(TVM_SETITEMHEIGHT, FItemHeight, 0);
    UpdateRenameBounds;
    Invalidate;
  end;
end;

procedure TCustomThemedTreeView.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited ChangeScale(M, D, isDpiChange);
  ApplyMetrics;
  UpdateRenameBounds;
end;

function TCustomThemedTreeView.GetCompactIdeMode: Boolean;
begin
  Result := FDensity = ttvdCompact;
end;

procedure TCustomThemedTreeView.SetCompactIdeMode(const AValue: Boolean);
begin
  if AValue then Density := ttvdCompact else Density := ttvdNormal;
end;

procedure TCustomThemedTreeView.SetStyleMode(const AValue: TThemedControlStyleMode);
begin
  if FStyleMode = AValue then Exit;
  FStyleMode := AValue;
  if (FStyleMode = stCompact) or (FDensity = ttvdCompact) then ApplyCompactIdeMetrics else ApplyComfortableMetrics;
  ApplyMetrics;
end;

procedure TCustomThemedTreeView.SetDensity(const AValue: TThemedTreeViewDensity);
begin
  if FDensity = AValue then Exit;
  FDensity := AValue;
  if (FStyleMode = stCompact) or (FDensity = ttvdCompact) then ApplyCompactIdeMetrics else ApplyComfortableMetrics;
  ApplyMetrics;
end;

procedure TCustomThemedTreeView.SetShowThemedCheckBoxes(const AValue: Boolean); begin if FShowThemedCheckBoxes <> AValue then begin FShowThemedCheckBoxes := AValue; Invalidate; end; end;
procedure TCustomThemedTreeView.SetTriStateCheckBoxes(const AValue: Boolean); begin if FTriStateCheckBoxes <> AValue then FTriStateCheckBoxes := AValue; end;
procedure TCustomThemedTreeView.SetAutoCheckChildren(const AValue: Boolean); begin if FAutoCheckChildren <> AValue then FAutoCheckChildren := AValue; end;
procedure TCustomThemedTreeView.SetAutoCheckParents(const AValue: Boolean); begin if FAutoCheckParents <> AValue then FAutoCheckParents := AValue; end;
procedure TCustomThemedTreeView.SetShowStatusColor(const AValue: Boolean); begin if FShowStatusColor <> AValue then begin FShowStatusColor := AValue; Invalidate; end; end;
procedure TCustomThemedTreeView.SetShowFavorites(const AValue: Boolean); begin if FShowFavorites <> AValue then begin FShowFavorites := AValue; Invalidate; end; end;
procedure TCustomThemedTreeView.SetShowProgress(const AValue: Boolean); begin if FShowProgress <> AValue then begin FShowProgress := AValue; Invalidate; end; end;
procedure TCustomThemedTreeView.SetRoundedSelection(const AValue: Boolean); begin if FRoundedSelection <> AValue then begin FRoundedSelection := AValue; Invalidate; end; end;
procedure TCustomThemedTreeView.SetHighlightFilterMatches(const AValue: Boolean); begin if FHighlightFilterMatches <> AValue then begin FHighlightFilterMatches := AValue; Invalidate; end; end;

procedure TCustomThemedTreeView.SetShowSubtitles(const AValue: Boolean);
begin
  if FShowSubtitles = AValue then Exit;
  FShowSubtitles := AValue;
  ApplyMetrics;
end;

procedure TCustomThemedTreeView.SetFilterText(const AValue: string);
begin
  if FFilterText = AValue then Exit;
  FFilterText := AValue;
  Invalidate;
end;

procedure TCustomThemedTreeView.SetNodeContextMenu(const AValue: TPopupMenu);
begin
  if FNodeContextMenu = AValue then Exit;
  if FNodeContextMenu <> nil then FNodeContextMenu.RemoveFreeNotification(Self);
  FNodeContextMenu := AValue;
  if FNodeContextMenu <> nil then FNodeContextMenu.FreeNotification(Self);
end;

procedure TCustomThemedTreeView.SetAllowNodeDragDrop(const AValue: Boolean);
begin
  if FAllowNodeDragDrop = AValue then Exit;
  if not AValue and Dragging then CancelDrag;
  FAllowNodeDragDrop := AValue;
  if AValue then DragMode := dmAutomatic else DragMode := dmManual;
  ClearDropState;
end;

procedure TCustomThemedTreeView.SetAutoExpandOnDrag(const AValue: Boolean);
begin
  if FAutoExpandOnDrag = AValue then Exit;
  FAutoExpandOnDrag := AValue;
  if not AValue then
  begin
    FDragExpandTimer.Enabled := False;
    FDragExpandNode := nil;
  end;
end;

procedure TCustomThemedTreeView.SetAutoExpandDelay(const AValue: Integer);
var LValue: Integer;
begin
  LValue := Max(100, AValue);
  if FAutoExpandDelay = LValue then Exit;
  FAutoExpandDelay := LValue;
  FDragExpandTimer.Interval := LValue;
end;

procedure TCustomThemedTreeView.SetDragDropMode(const AValue: TThemedTreeDragDropMode);
begin
  if FDragDropMode = AValue then Exit;
  FDragDropMode := AValue;
  ClearDropState;
end;

function TCustomThemedTreeView.CanEdit(Node: TTreeNode): Boolean;
begin
  Result := False;
end;

function TCustomThemedTreeView.CanExpand(Node: TTreeNode): Boolean;
var LCancel: Boolean;
begin
  Result := inherited CanExpand(Node);
  if not Result then Exit;
  LCancel := False;
  if Assigned(FOnNodeExpandingEx) then FOnNodeExpandingEx(Self, Node, LCancel);
  Result := not LCancel;
  if Result and Assigned(FOnNodeLazyLoad) then FOnNodeLazyLoad(Self, Node);
end;

function TCustomThemedTreeView.CanCollapse(Node: TTreeNode): Boolean;
var LCancel: Boolean;
begin
  Result := inherited CanCollapse(Node);
  if not Result then Exit;
  LCancel := False;
  if Assigned(FOnNodeCollapsingEx) then FOnNodeCollapsingEx(Self, Node, LCancel);
  Result := not LCancel;
end;

procedure TCustomThemedTreeView.Delete(Node: TTreeNode);
var
  LCancelRename, LClearHover, LClearDrag: Boolean;
begin
  LCancelRename := (Node <> nil) and ((FRenameNode = Node) or IsChildOf(FRenameNode, Node));
  LClearHover := (Node <> nil) and ((FHoveredNode = Node) or IsChildOf(FHoveredNode, Node));
  LClearDrag := (Node <> nil) and ((FDragCandidateNode = Node) or IsChildOf(FDragCandidateNode, Node) or (FDragNode = Node) or IsChildOf(FDragNode, Node) or (FDropNode = Node) or IsChildOf(FDropNode, Node) or (FPendingDropNode = Node) or IsChildOf(FPendingDropNode, Node) or (FDragExpandNode = Node) or IsChildOf(FDragExpandNode, Node));
  if LCancelRename then EndRename(False);
  if LClearHover then FHoveredNode := nil;
  if LClearDrag then ClearDropState;
  inherited Delete(Node);
end;

function TCustomThemedTreeView.IsCustomDrawn(Target: TCustomDrawTarget; Stage: TCustomDrawStage): Boolean;
begin
  Result := inherited IsCustomDrawn(Target, Stage) or ((Stage = cdPrePaint) and (Target in [dtControl, dtItem]));
end;

function TCustomThemedTreeView.CustomDraw(const ARect: TRect; Stage: TCustomDrawStage): Boolean;
var LBack: TThemeColor;
begin
  Result := True;
  if Stage <> cdPrePaint then Exit;
  if FPalette <> nil then LBack := FPalette.MenuBackColor else LBack := ColorToThemeColor(Color);
  FRenderCanvas.BeginRender(Canvas);
  try
    FRenderCanvas.FillRectangle(LBack, ARect);
  finally
    FRenderCanvas.EndRender;
  end;
end;

function TCustomThemedTreeView.BuildRenderContext(ANode: TTreeNode; const AState: TCustomDrawState): TThemedTreeItemRenderContext;
var
  LNode: TThemedTreeNode;
  LIndex: Integer;
begin
  Result := Default(TThemedTreeItemRenderContext);
  Result.Bounds := ANode.DisplayRect(False);
  Result.Bounds.Left := 0;
  Result.Bounds.Right := ClientWidth;
  Result.ClientWidth := ClientWidth;
  Result.Level := ANode.Level;
  Result.Text := ANode.Text;
  Result.Font := Font;
  Result.Palette := FPalette;
  Result.BackColor := Color;
  Result.ForeColor := Font.Color;
  Result.Metrics := FMetrics;
  Result.Selected := cdsSelected in AState;
  Result.Hovered := ANode = FHoveredNode;
  Result.HasChildren := ANode.HasChildren or (ANode.Count > 0);
  Result.Expanded := ANode.Expanded;
  Result.ShowCheckBox := FShowThemedCheckBoxes;
  Result.ShowSubtitle := FShowSubtitles;
  Result.ShowStatus := FShowStatusColor;
  Result.RoundedSelection := FRoundedSelection;
  Result.HighlightFilterMatches := FHighlightFilterMatches;
  Result.FilterText := FFilterText;
  Result.RightToLeft := UseRightToLeftReading;
  LNode := nil;
  if ANode is TThemedTreeNode then LNode := TThemedTreeNode(ANode);
  if LNode <> nil then
  begin
    Result.Subtitle := LNode.Subtitle;
    Result.BadgeText := LNode.BadgeText;
    Result.BadgeColor := LNode.BadgeColor;
    Result.StatusColor := LNode.StatusColor;
    Result.Disabled := LNode.Disabled;
    Result.Separator := LNode.IsSeparator;
    Result.ShowFavorite := FShowFavorites and LNode.IsFavorite;
    Result.ShowProgress := FShowProgress and LNode.ShowProgress;
    Result.ProgressValue := LNode.ProgressValue;
    case LNode.ThemedCheckState of
      ttcsChecked: Result.CheckState := 1;
      ttcsIndeterminate: Result.CheckState := 2;
    else
      Result.CheckState := 0;
    end;
    Result.GlyphText := LNode.GlyphText;
    Result.GlyphFont := LNode.GlyphFont;
    Result.GlyphColor := LNode.GlyphColor;
    Result.UseThemeGlyphColor := LNode.UseThemeGlyphColor;
    Result.RightGlyphText := LNode.RightGlyphText;
    Result.RightGlyphFont := LNode.RightGlyphFont;
    Result.RightGlyphColor := LNode.RightGlyphColor;
    Result.UseThemeRightGlyphColor := LNode.UseThemeRightGlyphColor;
    if not LNode.RightImage.Empty then Result.RightImage := LNode.RightImage;
  end;
  if (Result.GlyphText = '') and (Images <> nil) then
  begin
    if Result.Selected then
    begin
      LIndex := ANode.SelectedIndex;
      if LIndex < 0 then LIndex := ANode.ImageIndex;
    end
    else
      LIndex := ANode.ImageIndex;
    if (LIndex >= 0) and (LIndex < Images.Count) then
    begin
      Images.GetBitmap(LIndex, FImageBuffer);
      if not FImageBuffer.Empty then Result.Image := FImageBuffer;
    end;
  end;
end;

function TCustomThemedTreeView.CustomDrawItem(Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage; var PaintImages: Boolean): Boolean;
var
  LContext: TThemedTreeItemRenderContext;
  LLayout: TThemedTreeItemLayout;
begin
  PaintImages := False;
  if Stage <> cdPrePaint then
  begin
    Result := False;
    Exit;
  end;
  LContext := BuildRenderContext(Node, State);
  if NimbusRectIsEmpty(LContext.Bounds) then
  begin
    Result := False;
    Exit;
  end;
  FRenderCanvas.BeginRender(Canvas);
  try
    TThemedTreeViewRenderer.RenderItem(FRenderCanvas, LContext, LLayout);
    if Node = FDropNode then TThemedTreeViewRenderer.RenderDropIndicator(FRenderCanvas, LContext, LLayout.RowRect, Ord(FDropPosition));
  finally
    FRenderCanvas.EndRender;
  end;
  Result := False;
end;

procedure TCustomThemedTreeView.InvalidateNode(ANode: TTreeNode);
var LRect: TRect;
begin
  if (ANode = nil) or not HandleAllocated then Exit;
  LRect := ANode.DisplayRect(False);
  if IsRectEmpty(LRect) then Exit;
  LRect.Left := 0;
  LRect.Right := ClientWidth;
  InvalidateRect(Handle, @LRect, False);
end;

function TCustomThemedTreeView.GetNodeAtPoint(const APoint: TPoint): TTreeNode;
var
  LNode: TTreeNode;
  LRect: TRect;
begin
  Result := GetNodeAt(APoint.X, APoint.Y);
  if Result <> nil then Exit;
  LNode := TopItem;
  while LNode <> nil do
  begin
    LRect := LNode.DisplayRect(False);
    if (APoint.Y >= LRect.Top) and (APoint.Y < LRect.Bottom) then Exit(LNode);
    if LRect.Top > ClientHeight then Break;
    LNode := LNode.GetNextVisible;
  end;
end;

function TCustomThemedTreeView.GetInteractionLayout(ANode: TTreeNode): TThemedTreeItemLayout;
var
  LContext: TThemedTreeItemRenderContext;
  LState: TCustomDrawState;
begin
  LState := [];
  if ANode = Selected then Include(LState, cdsSelected);
  LContext := BuildRenderContext(ANode, LState);
  Result := TThemedTreeViewRenderer.CalculateLayout(LContext, 0);
end;

procedure TCustomThemedTreeView.MouseMove(Shift: TShiftState; X, Y: Integer);
var LNode, LOld: TTreeNode;
begin
  inherited MouseMove(Shift, X, Y);
  LNode := GetNodeAtPoint(Point(X, Y));
  if LNode = FHoveredNode then Exit;
  LOld := FHoveredNode;
  FHoveredNode := LNode;
  InvalidateNode(LOld);
  InvalidateNode(FHoveredNode);
end;

procedure TCustomThemedTreeView.CMMouseLeave(var Message: TMessage);
var LOld: TTreeNode;
begin
  inherited;
  LOld := FHoveredNode;
  FHoveredNode := nil;
  InvalidateNode(LOld);
end;

procedure TCustomThemedTreeView.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LNode: TTreeNode;
  LThemed: TThemedTreeNode;
  LLayout: TThemedTreeItemLayout;
  LPoint: TPoint;
begin
  LPoint := Point(X, Y);
  LNode := GetNodeAtPoint(LPoint);
  FDragCandidateNode := nil;
  if (LNode is TThemedTreeNode) and TThemedTreeNode(LNode).Disabled then Exit;
  if Button = mbLeft then FDragCandidateNode := LNode;
  inherited MouseDown(Button, Shift, X, Y);
  if LNode = nil then Exit;
  LThemed := nil;
  if LNode is TThemedTreeNode then LThemed := TThemedTreeNode(LNode);
  if Button = mbLeft then
  begin
    LLayout := GetInteractionLayout(LNode);
    if FShowThemedCheckBoxes and PtInRect(LLayout.CheckRect, LPoint) then
    begin
      ToggleNodeCheck(LNode);
      Exit;
    end;
    if LNode.HasChildren and PtInRect(LLayout.ChevronRect, LPoint) then
    begin
      if LNode.Expanded then LNode.Collapse(False) else LNode.Expand(False);
      Exit;
    end;
    if Assigned(FOnNodeClickedEx) then FOnNodeClickedEx(Self, LNode, LPoint, Button, 1);
  end
  else if Button = mbRight then
  begin
    Selected := LNode;
    if Assigned(FOnNodeRightClicked) then FOnNodeRightClicked(Self, LNode, LPoint, Button, 1);
  end;
  if (LThemed <> nil) and LThemed.IsSeparator then Selected := nil;
end;

procedure TCustomThemedTreeView.DoContextPopup(MousePos: TPoint; var Handled: Boolean);
var
  LNode: TTreeNode;
  LThemed: TThemedTreeNode;
  LMenu: TPopupMenu;
  LPoint, LScreenPoint: TPoint;
  LRect: TRect;
  LCancel: Boolean;
begin
  inherited DoContextPopup(MousePos, Handled);
  if Handled then Exit;
  LPoint := MousePos;
  if (LPoint.X < 0) and (LPoint.Y < 0) then
  begin
    LNode := Selected;
    if LNode = nil then Exit;
    LRect := LNode.DisplayRect(False);
    if IsRectEmpty(LRect) then Exit;
    LPoint := Point(Max(0, LRect.Left), (LRect.Top + LRect.Bottom) div 2);
  end
  else
    LNode := GetNodeAtPoint(LPoint);
  if LNode = nil then Exit;
  if (LNode is TThemedTreeNode) and TThemedTreeNode(LNode).Disabled then
  begin
    Handled := True;
    Exit;
  end;
  if Selected <> LNode then Selected := LNode;
  LThemed := nil;
  if LNode is TThemedTreeNode then LThemed := TThemedTreeNode(LNode);
  LMenu := nil;
  if LThemed <> nil then LMenu := LThemed.ThemedContextMenu;
  if LMenu = nil then LMenu := FNodeContextMenu;
  LCancel := False;
  if Assigned(FOnNodeContextMenuOpening) then FOnNodeContextMenuOpening(Self, LNode, LPoint, LMenu, LCancel);
  if LCancel then
  begin
    Handled := True;
    Exit;
  end;
  if LMenu = nil then Exit;
  LScreenPoint := ClientToScreen(LPoint);
  LMenu.PopupComponent := Self;
  LMenu.Popup(LScreenPoint.X, LScreenPoint.Y);
  Handled := True;
end;

procedure TCustomThemedTreeView.DblClick;
var
  LPoint: TPoint;
  LNode: TTreeNode;
begin
  LPoint := ScreenToClient(Mouse.CursorPos);
  LNode := GetNodeAtPoint(LPoint);
  if (LNode is TThemedTreeNode) and TThemedTreeNode(LNode).Disabled then Exit;
  if (LNode <> nil) and Assigned(FOnNodeDoubleClickedEx) then FOnNodeDoubleClickedEx(Self, LNode, LPoint, mbLeft, 2);
  inherited DblClick;
end;

procedure TCustomThemedTreeView.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if Selected = nil then Exit;
  if (Selected is TThemedTreeNode) and TThemedTreeNode(Selected).Disabled then Exit;
  if Key = VK_F2 then
  begin
    BeginRename(Selected);
    Key := 0;
  end
  else if (Key = VK_SPACE) and FShowThemedCheckBoxes then
  begin
    ToggleNodeCheck(Selected);
    Key := 0;
  end
  else if Key = VK_RETURN then
  begin
    if Selected.HasChildren then
    begin
      if Selected.Expanded then Selected.Collapse(False) else Selected.Expand(False);
      Key := 0;
    end;
  end;
end;

procedure TCustomThemedTreeView.BeginRename(ANode: TTreeNode);
var
  LLayout: TThemedTreeItemLayout;
  LRect: TRect;
begin
  if ReadOnly or not Enabled or (ANode = nil) or (ANode.TreeView <> Self) then Exit;
  if (ANode is TThemedTreeNode) and (TThemedTreeNode(ANode).Disabled or TThemedTreeNode(ANode).IsSeparator) then Exit;
  EnsureNodeVisibleEx(ANode);
  LLayout := GetInteractionLayout(ANode);
  LRect := LLayout.TextRect;
  if IsRectEmpty(LRect) then Exit;
  if FRenameEdit = nil then
  begin
    FRenameEdit := TEdit.Create(Self);
    FRenameEdit.Parent := Self;
    FRenameEdit.BorderStyle := bsSingle;
    FRenameEdit.OnExit := RenameEditExit;
    FRenameEdit.OnKeyDown := RenameEditKeyDown;
  end;
  FRenameNode := ANode;
  FRenameEdit.SetBounds(LRect.Left, LRect.Top, Max(32, LRect.Width), Max(NimbusScaleValue(18, CurrentPPI), LRect.Height));
  FRenameEdit.Text := ANode.Text;
  FRenameEdit.Font.Assign(Font);
  if FPalette <> nil then
  begin
    FRenameEdit.Color := ThemeColorToColor(FPalette.InputBackColor);
    FRenameEdit.Font.Color := ThemeColorToColor(FPalette.InputForeColor);
  end
  else
  begin
    FRenameEdit.Color := clWindow;
    FRenameEdit.Font.Color := clWindowText;
  end;
  FRenameEdit.Visible := True;
  FRenameEdit.BringToFront;
  FRenameEdit.SetFocus;
  FRenameEdit.SelectAll;
end;

procedure TCustomThemedTreeView.CancelRename;
begin
  EndRename(False);
end;

procedure TCustomThemedTreeView.RenameEditExit(Sender: TObject);
begin
  EndRename(True);
end;

procedure TCustomThemedTreeView.RenameEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    EndRename(True);
    Key := 0;
  end
  else if Key = VK_ESCAPE then
  begin
    EndRename(False);
    Key := 0;
  end;
end;

procedure TCustomThemedTreeView.EndRename(const AApply: Boolean);
var
  LNode: TTreeNode;
  LOldText, LNewText: string;
  LCancel: Boolean;
begin
  if (FRenameEdit = nil) or (FRenameNode = nil) then Exit;
  LNode := FRenameNode;
  LOldText := LNode.Text;
  LNewText := FRenameEdit.Text;
  FRenameNode := nil;
  FRenameEdit.Visible := False;
  if AApply and (LOldText <> LNewText) then
  begin
    LCancel := False;
    if Assigned(FOnNodeRenamed) then FOnNodeRenamed(Self, LNode, LOldText, LNewText, LCancel);
    if not LCancel and ContainsNodeReference(LNode) then LNode.Text := LNewText;
  end;
  if ContainsNodeReference(LNode) then InvalidateNode(LNode);
end;

function TCustomThemedTreeView.CanDragNode(ANode: TTreeNode): Boolean;
begin
  Result := FAllowNodeDragDrop and (ANode <> nil) and (ANode.TreeView = Self);
  if Result and (ANode is TThemedTreeNode) then
    Result := not TThemedTreeNode(ANode).Disabled and not TThemedTreeNode(ANode).IsSeparator and TThemedTreeNode(ANode).AllowDrag;
end;

function TCustomThemedTreeView.IsChildOf(APossibleChild, APossibleParent: TTreeNode): Boolean;
var LParent: TTreeNode;
begin
  Result := False;
  if (APossibleChild = nil) or (APossibleParent = nil) then Exit;
  LParent := APossibleChild.Parent;
  while LParent <> nil do
  begin
    if LParent = APossibleParent then Exit(True);
    LParent := LParent.Parent;
  end;
end;

function TCustomThemedTreeView.CanDropNode(ASourceNode, ATargetNode: TTreeNode; APosition: TThemedTreeDropPosition): Boolean;
begin
  Result := FAllowNodeDragDrop and (ASourceNode <> nil) and (ATargetNode <> nil) and (APosition <> ttdpNone);
  if not Result then Exit;
  if (ASourceNode.TreeView <> Self) or (ATargetNode.TreeView <> Self) or (ASourceNode = ATargetNode) or IsChildOf(ATargetNode, ASourceNode) then Exit(False);
  if ATargetNode is TThemedTreeNode then
    if TThemedTreeNode(ATargetNode).Disabled or TThemedTreeNode(ATargetNode).IsSeparator or not TThemedTreeNode(ATargetNode).AllowDrop then Exit(False);
  case FDragDropMode of
    ttdmChildOnly: Result := APosition = ttdpAsChild;
    ttdmReorderOnly:
      Result := (APosition in [ttdpBefore, ttdpAfter]) and (ASourceNode.Parent = ATargetNode.Parent);
  end;
end;

function TCustomThemedTreeView.GetDropPosition(ATargetNode: TTreeNode; const APoint: TPoint): TThemedTreeDropPosition;
var
  LRect: TRect;
  LTopZone, LBottomZone: Integer;
begin
  Result := ttdpNone;
  if ATargetNode = nil then Exit;
  if FDragDropMode = ttdmChildOnly then Exit(ttdpAsChild);
  LRect := ATargetNode.DisplayRect(False);
  if IsRectEmpty(LRect) then Exit;
  LTopZone := LRect.Top + LRect.Height div 3;
  LBottomZone := LRect.Bottom - LRect.Height div 3;
  if APoint.Y < LTopZone then Exit(ttdpBefore);
  if APoint.Y > LBottomZone then Exit(ttdpAfter);
  if FDragDropMode = ttdmReorderOnly then Exit(ttdpAfter);
  Result := ttdpAsChild;
end;

procedure TCustomThemedTreeView.SetDropState(ANode: TTreeNode; APosition: TThemedTreeDropPosition);
var LOld: TTreeNode;
begin
  if (FDropNode = ANode) and (FDropPosition = APosition) then Exit;
  LOld := FDropNode;
  FDropNode := ANode;
  FDropPosition := APosition;
  if (FDropNode = nil) or (FDropPosition = ttdpNone) then
  begin
    FDragExpandNode := nil;
    if FDragExpandTimer <> nil then FDragExpandTimer.Enabled := False;
  end;
  InvalidateNode(LOld);
  InvalidateNode(FDropNode);
end;

procedure TCustomThemedTreeView.ClearDropTargetState;
var LOld: TTreeNode;
begin
  LOld := FDropNode;
  FDropNode := nil;
  FDropPosition := ttdpNone;
  FDragExpandNode := nil;
  if FDragExpandTimer <> nil then FDragExpandTimer.Enabled := False;
  InvalidateNode(LOld);
end;

procedure TCustomThemedTreeView.ClearDropState;
begin
  ClearDropTargetState;
  FPendingDropNode := nil;
  FPendingDropPosition := ttdpNone;
  FDragCandidateNode := nil;
  FDragNode := nil;
  FDropCommitted := False;
end;

procedure TCustomThemedTreeView.HandleDragAutoExpand(ATargetNode: TTreeNode);
begin
  if not FAutoExpandOnDrag or (FDropPosition <> ttdpAsChild) or (ATargetNode = nil) or (ATargetNode.Count = 0) or ATargetNode.Expanded then
  begin
    FDragExpandNode := nil;
    FDragExpandTimer.Enabled := False;
    Exit;
  end;
  if FDragExpandNode = ATargetNode then Exit;
  FDragExpandNode := ATargetNode;
  FDragExpandTimer.Enabled := False;
  FDragExpandTimer.Interval := FAutoExpandDelay;
  FDragExpandTimer.Enabled := True;
end;

procedure TCustomThemedTreeView.DragExpandTimerTick(Sender: TObject);
var LNode: TTreeNode;
begin
  FDragExpandTimer.Enabled := False;
  LNode := FDragExpandNode;
  FDragExpandNode := nil;
  if (LNode <> nil) and (LNode.TreeView = Self) and not LNode.Expanded and (LNode.Count > 0) then LNode.Expand(False);
end;

procedure TCustomThemedTreeView.DoStartDrag(var DragObject: TDragObject);
var
  LPoint: TPoint;
  LNode: TTreeNode;
  LCancel: Boolean;
begin
  LNode := FDragCandidateNode;
  FDragCandidateNode := nil;
  if not ContainsNodeReference(LNode) then
  begin
    LPoint := ScreenToClient(Mouse.CursorPos);
    LNode := GetNodeAtPoint(LPoint);
  end;
  if not CanDragNode(LNode) then
  begin
    CancelDrag;
    Exit;
  end;
  LCancel := False;
  if Assigned(FOnNodeDragStarting) then FOnNodeDragStarting(Self, LNode, LCancel);
  if LCancel then
  begin
    CancelDrag;
    Exit;
  end;
  ClearDropState;
  FDragNode := LNode;
  inherited DoStartDrag(DragObject);
end;

procedure TCustomThemedTreeView.DoEndDrag(Target: TObject; X, Y: Integer);
var
  LSource, LTarget: TTreeNode;
  LPosition: TThemedTreeDropPosition;
begin
  LSource := FDragNode;
  LTarget := FDropNode;
  LPosition := FDropPosition;
  if not CanDropNode(LSource, LTarget, LPosition) then
  begin
    LTarget := FPendingDropNode;
    LPosition := FPendingDropPosition;
  end;
  if not FDropCommitted and (Target = Self) and CanDropNode(LSource, LTarget, LPosition) then
  begin
    MoveNode(LSource, LTarget, LPosition);
    FDropCommitted := True;
  end;
  inherited DoEndDrag(Target, X, Y);
  ClearDropState;
end;

procedure TCustomThemedTreeView.DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  LTarget: TTreeNode;
  LPosition: TThemedTreeDropPosition;
  LCancel, LUserAccept: Boolean;
begin
  Accept := False;
  if State = dsDragLeave then
  begin
    Accept := CanDropNode(FDragNode, FDropNode, FDropPosition);
    if Accept then
    begin
      FPendingDropNode := FDropNode;
      FPendingDropPosition := FDropPosition;
    end
    else
    begin
      FPendingDropNode := nil;
      FPendingDropPosition := ttdpNone;
    end;
    ClearDropTargetState;
    Exit;
  end;
  FPendingDropNode := nil;
  FPendingDropPosition := ttdpNone;
  if not FAllowNodeDragDrop or (FDragNode = nil) then
  begin
    ClearDropTargetState;
    Exit;
  end;
  LTarget := GetNodeAtPoint(Point(X, Y));
  LPosition := GetDropPosition(LTarget, Point(X, Y));
  if not CanDropNode(FDragNode, LTarget, LPosition) then
  begin
    SetDropState(nil, ttdpNone);
    Exit;
  end;
  LCancel := False;
  if Assigned(FOnNodeDragOverEx) then FOnNodeDragOverEx(Self, FDragNode, LTarget, LPosition, LCancel);
  if LCancel then
  begin
    SetDropState(nil, ttdpNone);
    Exit;
  end;
  if Assigned(OnDragOver) then
  begin
    LUserAccept := True;
    inherited DragOver(Source, X, Y, State, LUserAccept);
    if not LUserAccept then
    begin
      SetDropState(nil, ttdpNone);
      Exit;
    end;
  end;
  Accept := True;
  SetDropState(LTarget, LPosition);
  HandleDragAutoExpand(LTarget);
end;

procedure TCustomThemedTreeView.DragDrop(Source: TObject; X, Y: Integer);
var
  LSource, LTarget: TTreeNode;
  LPosition: TThemedTreeDropPosition;
begin
  LSource := FDragNode;
  LTarget := FDropNode;
  LPosition := FDropPosition;
  if not CanDropNode(LSource, LTarget, LPosition) then
  begin
    LTarget := FPendingDropNode;
    LPosition := FPendingDropPosition;
  end;
  if CanDropNode(LSource, LTarget, LPosition) then
  begin
    MoveNode(LSource, LTarget, LPosition);
    FDropCommitted := True;
  end;
  inherited DragDrop(Source, X, Y);
  FPendingDropNode := nil;
  FPendingDropPosition := ttdpNone;
  ClearDropTargetState;
end;

procedure TCustomThemedTreeView.MoveNode(ASourceNode, ATargetNode: TTreeNode; APosition: TThemedTreeDropPosition);
var
  LOldParent, LNewParent, LNext: TTreeNode;
  LOldIndex, LNewIndex: Integer;
begin
  if not CanDropNode(ASourceNode, ATargetNode, APosition) then Exit;
  if (APosition = ttdpBefore) and (ASourceNode.Parent = ATargetNode.Parent) and (ASourceNode.GetNextSibling = ATargetNode) then Exit;
  if (APosition = ttdpAfter) and (ASourceNode.Parent = ATargetNode.Parent) and (ASourceNode.GetPrevSibling = ATargetNode) then Exit;
  LOldParent := ASourceNode.Parent;
  LOldIndex := ASourceNode.Index;
  Items.BeginUpdate;
  try
    case APosition of
      ttdpAsChild:
        begin
          ASourceNode.MoveTo(ATargetNode, naAddChild);
          ATargetNode.Expand(False);
        end;
      ttdpBefore:
        ASourceNode.MoveTo(ATargetNode, naInsert);
      ttdpAfter:
        begin
          LNext := ATargetNode.GetNextSibling;
          if LNext = ASourceNode then LNext := ASourceNode.GetNextSibling;
          if LNext <> nil then ASourceNode.MoveTo(LNext, naInsert)
          else if ATargetNode.Parent <> nil then ASourceNode.MoveTo(ATargetNode.Parent, naAddChild)
          else ASourceNode.MoveTo(nil, naAdd);
        end;
    end;
    Selected := ASourceNode;
    ASourceNode.MakeVisible;
  finally
    Items.EndUpdate;
  end;
  LNewParent := ASourceNode.Parent;
  LNewIndex := ASourceNode.Index;
  if Assigned(FOnNodeDropped) then FOnNodeDropped(Self, ASourceNode, ATargetNode, LOldParent, LNewParent, LOldIndex, LNewIndex, APosition);
end;

function TCustomThemedTreeView.GetNodeCheckState(ANode: TTreeNode): TThemedTreeCheckState;
begin
  if ANode is TThemedTreeNode then Result := TThemedTreeNode(ANode).ThemedCheckState else Result := ttcsUnchecked;
end;

procedure TCustomThemedTreeView.SetNodeCheckState(ANode: TTreeNode; const AState: TThemedTreeCheckState; const ARaiseEvent: Boolean);
var LOld: TThemedTreeCheckState;
begin
  if not (ANode is TThemedTreeNode) then Exit;
  LOld := TThemedTreeNode(ANode).ThemedCheckState;
  if LOld = AState then Exit;
  TThemedTreeNode(ANode).ThemedCheckState := AState;
  if ARaiseEvent and Assigned(FOnNodeCheckChanged) then FOnNodeCheckChanged(Self, ANode, LOld, AState);
end;

procedure TCustomThemedTreeView.ToggleNodeCheck(ANode: TTreeNode);
var LState: TThemedTreeCheckState;
begin
  LState := GetNodeCheckState(ANode);
  if FTriStateCheckBoxes then
    case LState of
      ttcsUnchecked: LState := ttcsChecked;
      ttcsChecked: LState := ttcsIndeterminate;
    else
      LState := ttcsUnchecked;
    end
  else if LState = ttcsChecked then LState := ttcsUnchecked else LState := ttcsChecked;
  SetNodeCheckState(ANode, LState, True);
  if FAutoCheckChildren then SetChildrenCheckState(ANode, LState);
  if FAutoCheckParents and (ANode.Parent <> nil) then UpdateParentCheckState(ANode.Parent);
end;

procedure TCustomThemedTreeView.SetChildrenCheckState(ANode: TTreeNode; const AState: TThemedTreeCheckState);
var LChild: TTreeNode;
begin
  if ANode = nil then Exit;
  LChild := ANode.getFirstChild;
  while LChild <> nil do
  begin
    SetNodeCheckState(LChild, AState, True);
    SetChildrenCheckState(LChild, AState);
    LChild := LChild.getNextSibling;
  end;
end;

procedure TCustomThemedTreeView.UpdateParentCheckState(ANode: TTreeNode);
var
  LChild: TTreeNode;
  LChecked, LUnchecked, LCount: Integer;
  LState: TThemedTreeCheckState;
begin
  if (ANode = nil) or (ANode.Count = 0) then Exit;
  LChecked := 0;
  LUnchecked := 0;
  LCount := 0;
  LChild := ANode.getFirstChild;
  while LChild <> nil do
  begin
    Inc(LCount);
    case GetNodeCheckState(LChild) of
      ttcsChecked: Inc(LChecked);
      ttcsUnchecked: Inc(LUnchecked);
    end;
    LChild := LChild.getNextSibling;
  end;
  if LChecked = LCount then LState := ttcsChecked else if LUnchecked = LCount then LState := ttcsUnchecked else LState := ttcsIndeterminate;
  SetNodeCheckState(ANode, LState, True);
  if ANode.Parent <> nil then UpdateParentCheckState(ANode.Parent);
end;

procedure TCustomThemedTreeView.ExpandAllSafe;
begin
  Items.BeginUpdate;
  try
    FullExpand;
  finally
    Items.EndUpdate;
  end;
end;

procedure TCustomThemedTreeView.CollapseAllSafe;
begin
  Items.BeginUpdate;
  try
    FullCollapse;
  finally
    Items.EndUpdate;
  end;
end;

procedure TCustomThemedTreeView.FindNodesRecursive(ANode: TTreeNode; const AText: string; AList: TList<TTreeNode>);
var LChild: TTreeNode;
begin
  if (ANode = nil) or (AList = nil) then Exit;
  if ContainsText(ANode.Text, AText) then AList.Add(ANode);
  LChild := ANode.getFirstChild;
  while LChild <> nil do
  begin
    FindNodesRecursive(LChild, AText, AList);
    LChild := LChild.getNextSibling;
  end;
end;

procedure TCustomThemedTreeView.FindNodes(const AText: string; AList: TList<TTreeNode>);
var LNode: TTreeNode;
begin
  if AList = nil then Exit;
  AList.Clear;
  if AText = '' then Exit;
  LNode := Items.GetFirstNode;
  while LNode <> nil do
  begin
    if LNode.Parent = nil then FindNodesRecursive(LNode, AText, AList);
    LNode := LNode.getNextSibling;
  end;
end;

procedure TCustomThemedTreeView.SelectFirstMatch(const AText: string);
var LList: TList<TTreeNode>;
begin
  LList := TList<TTreeNode>.Create;
  try
    FindNodes(AText, LList);
    if LList.Count > 0 then EnsureNodeVisibleEx(LList[0]);
  finally
    LList.Free;
  end;
end;

procedure TCustomThemedTreeView.EnsureNodeVisibleEx(ANode: TTreeNode);
begin
  if (ANode = nil) or (ANode.TreeView <> Self) then Exit;
  ANode.MakeVisible;
  Selected := ANode;
end;

procedure TCustomThemedTreeView.BindAction(const AAction: TBasicAction); begin Action := AAction; end;
procedure TCustomThemedTreeView.UnbindAction; begin Action := nil; end;
procedure TCustomThemedTreeView.SyncAction; begin InitiateAction; end;

initialization
  RegisterClass(TThemedTreeNode);

finalization
  UnRegisterClass(TThemedTreeNode);

end.

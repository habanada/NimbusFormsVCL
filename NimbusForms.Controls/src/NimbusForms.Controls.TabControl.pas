{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.TabControl;

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
  Vcl.Graphics,
  Vcl.ComCtrls,
  Vcl.ImgList,
  Vcl.Menus,
  Vcl.ExtCtrls,
  NimbusForms.Theming.Palette,
  NimbusForms.Controls.Types,
  NimbusForms.Rendering.Canvas,
  NimbusForms.Rendering.Types,
  NimbusForms.Rendering.TabControl,
  NimbusForms.Menus.PopupMenu;

type
  TThemedTabOverflowMode = (tomNone, tomScrollButtons, tomDropDownMenu, tomScrollAndMenu);
  TThemedTabTextMode = (tttmFullText, tttmShortText);
  TThemedTabTextTrimming = (tttNone, tttEllipsis);
  TThemedTabCloseButtonMode = (tcbmNone, tcbmActiveOnly, tcbmActiveAndHovered, tcbmAll);
  TThemedTabCloseReason = (tcrCloseButton, tcrMiddleClick, tcrCode);

  TThemedTabSelectingEvent = procedure(Sender: TObject; ATabIndex: Integer; ATabPage: TTabSheet; var ACancel: Boolean) of object;
  TThemedTabClosingEvent = procedure(Sender: TObject; ATabIndex: Integer; ATabPage: TTabSheet; AReason: TThemedTabCloseReason; var ACancel: Boolean) of object;
  TThemedTabClosedEvent = procedure(Sender: TObject; ATabIndex: Integer; ATabPage: TTabSheet; AReason: TThemedTabCloseReason) of object;
  TThemedTabReorderedEvent = procedure(Sender: TObject; ATabPage: TTabSheet; AOldIndex, ANewIndex: Integer) of object;
  TThemedTabMouseEvent = procedure(Sender: TObject; ATabIndex: Integer; ATabPage: TTabSheet; const ALocation: TPoint) of object;
  TThemedTabContextMenuOpeningEvent = procedure(Sender: TObject; ATabIndex: Integer; ATabPage: TTabSheet; const ALocation: TPoint; var APopupMenu: TPopupMenu; var ACancel: Boolean) of object;

  TThemedTabPageState = record
    Closable: Boolean;
    Pinned: Boolean;
    Unsaved: Boolean;
    BadgeText: string;
  end;

  TThemedTabRects = array of TRect;

  TCustomThemedTabControl = class(TPageControl, IThemeAware)
  private
    FPalette: TThemePalette;
    FRenderCanvas: INimbusRenderCanvas;
    FRenderer: TThemedTabRenderer;
    FThemeRegistered: Boolean;
    FStyleMode: TThemedControlStyleMode;
    FStates: TDictionary<TTabSheet, TThemedTabPageState>;
    FTabRects: TThemedTabRects;
    FRenderItems: TThemedTabRenderItems;
    FImageChangeLink: TChangeLink;
    FObservedImages: TCustomImageList;
    FImageIcons: TObjectList<TIcon>;
    FBorderThickness: Integer;
    FLogicalBorderThickness: Integer;
    FTextPaddingLeft: Integer;
    FLogicalTextPaddingLeft: Integer;
    FTextPaddingTop: Integer;
    FLogicalTextPaddingTop: Integer;
    FTextPaddingHorizontal: Integer;
    FLogicalTextPaddingHorizontal: Integer;
    FTextPaddingVertical: Integer;
    FLogicalTextPaddingVertical: Integer;
    FCloseButtonSize: Integer;
    FLogicalCloseButtonSize: Integer;
    FCloseButtonAreaWidth: Integer;
    FLogicalCloseButtonAreaWidth: Integer;
    FIconSize: Integer;
    FLogicalIconSize: Integer;
    FBadgeHorizontalPadding: Integer;
    FLogicalBadgeHorizontalPadding: Integer;
    FBadgeHeight: Integer;
    FLogicalBadgeHeight: Integer;
    FActiveIndicatorHeight: Integer;
    FLogicalActiveIndicatorHeight: Integer;
    FMinimumTabWidth: Integer;
    FMaximumTabWidth: Integer;
    FLogicalMinimumTabWidth: Integer;
    FLogicalMaximumTabWidth: Integer;
    FTabHeaderHorizontalPadding: Integer;
    FTabHeaderVerticalPadding: Integer;
    FLogicalTabHeaderHorizontalPadding: Integer;
    FLogicalTabHeaderVerticalPadding: Integer;
    FTabHeaderHeight: Integer;
    FLogicalTabHeaderHeight: Integer;
    FFirstVisibleTabIndex: Integer;
    FHoveredIndex: Integer;
    FHoveredCloseIndex: Integer;
    FPressedCloseIndex: Integer;
    FDragSourceIndex: Integer;
    FDragStartPoint: TPoint;
    FDragging: Boolean;
    FShowActiveIndicator: Boolean;
    FAllowTabReorder: Boolean;
    FCloseOnMiddleClick: Boolean;
    FCloseButtonMode: TThemedTabCloseButtonMode;
    FTabContextMenu: TPopupMenu;
    FTabListMenu: TThemedPopupMenu;
    FMultiLineTabs: Boolean;
    FTabRows: Integer;
    FUpdatingRows: Boolean;
    FTabTextMode: TThemedTabTextMode;
    FTabTextTrimming: TThemedTabTextTrimming;
    FVariableTabWidth: Boolean;
    FApplyingNativeMetrics: Boolean;
    FLayoutValid: Boolean;
    FPendingSelectionIndex: Integer;
    FHeaderInput: TGraphicControl;
    FOverflowMode: TThemedTabOverflowMode;
    FOverflowVisible: Boolean;
    FOverflowHover: Integer;
    FOverflowPressed: Integer;
    FOverflowRepeatTimer: TTimer;
    FOverflowRepeatActive: Boolean;
    FAutoScrollActiveTab: Boolean;
    FScrollTabsWithMouseWheel: Boolean;
    FOnTabClosing: TThemedTabClosingEvent;
    FOnTabClosed: TThemedTabClosedEvent;
    FOnTabSelectingEx: TThemedTabSelectingEvent;
    FOnTabReordered: TThemedTabReorderedEvent;
    FOnTabRightClicked: TThemedTabMouseEvent;
    FOnTabContextMenuOpening: TThemedTabContextMenuOpeningEvent;
    procedure SetStyleMode(const AValue: TThemedControlStyleMode);
    procedure RegisterThemeAware;
    procedure SetOverflowMode(const AValue: TThemedTabOverflowMode);
    procedure SetMultiLineTabs(const AValue: Boolean);
    procedure InvalidateHeader;
    procedure StopOverflowRepeat;
    procedure OverflowRepeatTick(Sender: TObject);
    procedure StepOverflow(const AButton: Integer);
    function OverflowButtonRect(const AButton: Integer): TRect;
    function HitTestOverflowButton(const APoint: TPoint): Integer;
    procedure DrawOverflowButtons;
    procedure ShowTabList;
    procedure TabListItemClick(Sender: TObject);
    procedure EnsureActiveTabVisible;
    procedure SetRenderer(const AValue: TThemedTabRenderer);
    procedure SetShowActiveIndicator(const AValue: Boolean);
    procedure SetAllowTabReorder(const AValue: Boolean);
    procedure SetCloseOnMiddleClick(const AValue: Boolean);
    procedure SetCloseButtonMode(const AValue: TThemedTabCloseButtonMode);
    procedure SetTabContextMenu(const AValue: TPopupMenu);
    procedure SetTabTextMode(const AValue: TThemedTabTextMode);
    procedure SetTabTextTrimming(const AValue: TThemedTabTextTrimming);
    procedure SetMinimumTabWidth(const AValue: Integer);
    procedure SetMaximumTabWidth(const AValue: Integer);
    procedure SetVariableTabWidth(const AValue: Boolean);
    procedure SetTabHeaderHorizontalPadding(const AValue: Integer);
    procedure SetTabHeaderVerticalPadding(const AValue: Integer);
    procedure SetTabHeaderHeight(const AValue: Integer);
    function DefaultTabState: TThemedTabPageState;
    function GetState(const APage: TTabSheet): TThemedTabPageState;
    procedure SetState(const APage: TTabSheet; const AState: TThemedTabPageState);
    procedure ApplyDpiScaling;
    procedure ApplyNativeTabMetrics;
    procedure UpdateHeaderInputBounds;
    procedure InvalidateTabLayout;
    procedure HideNativeTabScroller;
    procedure SyncImageList;
    procedure RebuildImageCache;
    procedure ImageListChanged(Sender: TObject);
    function GetImageIcon(const APage: TTabSheet): HICON;
    procedure ApplyThemeToPage(const APage: TTabSheet);
    procedure EnsureTabRects;
    procedure RebuildTabRects(const ACanvas: INimbusRenderCanvas);
    function MeasureTabWidth(const ACanvas: INimbusRenderCanvas; const ATabIndex: Integer): Integer;
    function HitTestTab(const APoint: TPoint): Integer;
    function HitTestCloseButton(const APoint: TPoint): Integer;
    function GetCloseButtonRect(const ATabRect: TRect): TRect;
    function ShouldShowCloseButton(const AIndex: Integer): Boolean;
    function ShouldReserveCloseButtonSpace(const AIndex: Integer): Boolean;
    function FindPreviousVisiblePageIndex(const AIndex: Integer): Integer;
    function FindNextVisiblePageIndex(const AIndex: Integer): Integer;
    function NativeTabIndexToPageIndex(const ATabIndex: Integer): Integer;
    function SelectPageIndex(const APageIndex: Integer): Boolean;
    function IsPointInHeader(const APoint: TPoint): Boolean;
    procedure AcquireMouseFocus;
    procedure RenderControl(const ADC: HDC);
    procedure RenderControlBuffered(const ADC: HDC; const AUpdateRect: TRect);
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMShowingChanged(var Message: TMessage); message CM_SHOWINGCHANGED;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMControlChange(var Message: TCMControlChange); message CM_CONTROLCHANGE;
    procedure CMDialogKey(var Message: TCMDialogKey); message CM_DIALOGKEY;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure WMPrintClient(var Message: TMessage); message WM_PRINTCLIENT;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMMouseLeave(var Message: TMessage); message WM_MOUSELEAVE;
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MOUSEMOVE;
    procedure WMMouseWheel(var Message: TWMMouseWheel); message WM_MOUSEWHEEL;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    procedure WMMButtonDown(var Message: TWMMButtonDown); message WM_MBUTTONDOWN;
    procedure WMMButtonUp(var Message: TWMMButtonUp); message WM_MBUTTONUP;
    procedure WMMButtonDblClk(var Message: TWMMButtonDblClk); message WM_MBUTTONDBLCLK;
    procedure WMRButtonDown(var Message: TWMRButtonDown); message WM_RBUTTONDOWN;
    procedure WMRButtonUp(var Message: TWMRButtonUp); message WM_RBUTTONUP;
    procedure WMRButtonDblClk(var Message: TWMRButtonDblClk); message WM_RBUTTONDBLCLK;
    procedure WMCaptureChanged(var Message: TMessage); message WM_CAPTURECHANGED;
    procedure WMCancelMode(var Message: TWMCancelMode); message WM_CANCELMODE;
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    procedure TCMSetItemSize(var Message: TMessage); message TCM_SETITEMSIZE;
    procedure TCMSetImageList(var Message: TMessage); message TCM_SETIMAGELIST;
  protected
    procedure Loaded; override;
    procedure Change; override;
    procedure AdjustClientRect(var Rect: TRect); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure Resize; override;
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    function CanChange: Boolean; override;
    function GetEffectiveHeaderHeight: Integer; virtual;
    function GetReservedHeaderRightWidth: Integer; virtual;
    function GetDrawableTabRect(const ATabIndex: Integer): TRect; virtual;
    function GetTabDisplayText(const APage: TTabSheet; const ATabIndex: Integer): string; virtual;
    function GetTabShortText(const APage: TTabSheet; const ATabIndex: Integer): string; virtual;
    function GetEffectiveTabText(const APage: TTabSheet; const ATabIndex: Integer): string; virtual;
    function GetTabTextFlags(const APage: TTabSheet; const ATabIndex: Integer): TNimbusTextFlags; virtual;
    procedure DoTabSelecting(const ATabIndex: Integer; const ATabPage: TTabSheet; var ACancel: Boolean); virtual;
    procedure DoTabClosing(const ATabIndex: Integer; const ATabPage: TTabSheet; const AReason: TThemedTabCloseReason; var ACancel: Boolean); virtual;
    procedure DoTabClosed(const ATabIndex: Integer; const ATabPage: TTabSheet; const AReason: TThemedTabCloseReason); virtual;
    procedure DoTabReordered(const ATabPage: TTabSheet; const AOldIndex, ANewIndex: Integer); virtual;
    procedure DoTabRightClicked(const ATabIndex: Integer; const ATabPage: TTabSheet; const ALocation: TPoint); virtual;
    procedure DoTabContextMenuOpening(const ATabIndex: Integer; const ATabPage: TTabSheet; const ALocation: TPoint; var APopupMenu: TPopupMenu; var ACancel: Boolean); virtual;
    function CloseTabCore(const AIndex: Integer; const AReason: TThemedTabCloseReason): Boolean; virtual;
    function CanReorderTab(const AOldIndex, ANewIndex: Integer): Boolean; virtual;
    procedure ReorderTabCore(const AOldIndex, ANewIndex: Integer); virtual;
    procedure ScrollHeaderToPreviousTab;
    procedure ScrollHeaderToNextTab;
    procedure ScrollHeaderToTab(const ATabIndex: Integer);
    function CanScrollHeaderToPreviousTab: Boolean;
    function CanScrollHeaderToNextTab: Boolean;
    property StyleMode: TThemedControlStyleMode read FStyleMode write SetStyleMode default stNormal;
    property Palette: TThemePalette read FPalette;
    property RenderCanvas: INimbusRenderCanvas read FRenderCanvas;
    property TabOverflowMode: TThemedTabOverflowMode read FOverflowMode write SetOverflowMode default tomScrollAndMenu;
    property MultiLineTabs: Boolean read FMultiLineTabs write SetMultiLineTabs default False;
    property AutoScrollActiveTab: Boolean read FAutoScrollActiveTab write FAutoScrollActiveTab default True;
    property ScrollTabsWithMouseWheel: Boolean read FScrollTabsWithMouseWheel write FScrollTabsWithMouseWheel default True;
    property ShowActiveIndicator: Boolean read FShowActiveIndicator write SetShowActiveIndicator default True;
    property AllowTabReorder: Boolean read FAllowTabReorder write SetAllowTabReorder default True;
    property CloseOnMiddleClick: Boolean read FCloseOnMiddleClick write SetCloseOnMiddleClick default True;
    property CloseButtonMode: TThemedTabCloseButtonMode read FCloseButtonMode write SetCloseButtonMode default tcbmActiveAndHovered;
    property TabContextMenu: TPopupMenu read FTabContextMenu write SetTabContextMenu;
    property TabTextMode: TThemedTabTextMode read FTabTextMode write SetTabTextMode default tttmFullText;
    property TabTextTrimming: TThemedTabTextTrimming read FTabTextTrimming write SetTabTextTrimming default tttNone;
    property MinimumTabWidth: Integer read FLogicalMinimumTabWidth write SetMinimumTabWidth default 48;
    property MaximumTabWidth: Integer read FLogicalMaximumTabWidth write SetMaximumTabWidth default 220;
    property VariableTabWidth: Boolean read FVariableTabWidth write SetVariableTabWidth default True;
    property TabHeaderHorizontalPadding: Integer read FLogicalTabHeaderHorizontalPadding write SetTabHeaderHorizontalPadding default 16;
    property TabHeaderVerticalPadding: Integer read FLogicalTabHeaderVerticalPadding write SetTabHeaderVerticalPadding default 2;
    property TabHeaderHeight: Integer read FLogicalTabHeaderHeight write SetTabHeaderHeight default 0;
    property OnTabClosing: TThemedTabClosingEvent read FOnTabClosing write FOnTabClosing;
    property OnTabClosed: TThemedTabClosedEvent read FOnTabClosed write FOnTabClosed;
    property OnTabSelectingEx: TThemedTabSelectingEvent read FOnTabSelectingEx write FOnTabSelectingEx;
    property OnTabReordered: TThemedTabReorderedEvent read FOnTabReordered write FOnTabReordered;
    property OnTabRightClicked: TThemedTabMouseEvent read FOnTabRightClicked write FOnTabRightClicked;
    property OnTabContextMenuOpening: TThemedTabContextMenuOpeningEvent read FOnTabContextMenuOpening write FOnTabContextMenuOpening;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette); virtual;
    function GetTabClosable(const APage: TTabSheet): Boolean;
    procedure SetTabClosable(const APage: TTabSheet; const AClosable: Boolean);
    function GetTabPinned(const APage: TTabSheet): Boolean;
    procedure SetTabPinned(const APage: TTabSheet; const APinned: Boolean);
    function GetTabUnsaved(const APage: TTabSheet): Boolean;
    procedure SetTabUnsaved(const APage: TTabSheet; const AUnsaved: Boolean);
    function GetTabBadgeText(const APage: TTabSheet): string;
    procedure SetTabBadgeText(const APage: TTabSheet; const ABadgeText: string);
    property Renderer: TThemedTabRenderer read FRenderer write SetRenderer;
  end;

  TThemedTabControl = class(TCustomThemedTabControl)
  published
    property StyleMode;
    property Align;
    property Anchors;
    property BiDiMode;
    property Constraints;
    property DoubleBuffered;
    property Enabled;
    property Font;
    property Color;
    property Images;
    property ParentBiDiMode;
    property ParentDoubleBuffered;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property ShowActiveIndicator;
    property TabOverflowMode;
    property MultiLineTabs;
    property AutoScrollActiveTab;
    property ScrollTabsWithMouseWheel;
    property AllowTabReorder;
    property CloseOnMiddleClick;
    property CloseButtonMode;
    property TabContextMenu;
    property TabTextMode;
    property TabTextTrimming;
    property MinimumTabWidth;
    property MaximumTabWidth;
    property VariableTabWidth;
    property TabHeaderHorizontalPadding;
    property TabHeaderVerticalPadding;
    property TabHeaderHeight;
    property OnChange;
    property OnChanging;
    property OnContextPopup;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnTabClosing;
    property OnTabClosed;
    property OnTabSelectingEx;
    property OnTabReordered;
    property OnTabRightClicked;
    property OnTabContextMenuOpening;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Vcl.Forms,
  NimbusForms.Theming.Manager,
  NimbusForms.Theming.Types;

type
  TTabSheetAccess = class(TTabSheet);
  TThemedTabHeaderInput = class(TGraphicControl)
  private
    FOwnerControl: TCustomThemedTabControl;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MOUSEMOVE;
    procedure WMMouseWheel(var Message: TWMMouseWheel); message WM_MOUSEWHEEL;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    procedure WMMButtonDown(var Message: TWMMButtonDown); message WM_MBUTTONDOWN;
    procedure WMMButtonUp(var Message: TWMMButtonUp); message WM_MBUTTONUP;
    procedure WMMButtonDblClk(var Message: TWMMButtonDblClk); message WM_MBUTTONDBLCLK;
    procedure WMRButtonDown(var Message: TWMRButtonDown); message WM_RBUTTONDOWN;
    procedure WMRButtonUp(var Message: TWMRButtonUp); message WM_RBUTTONUP;
    procedure WMRButtonDblClk(var Message: TWMRButtonDblClk); message WM_RBUTTONDBLCLK;
  protected
    procedure Paint; override;
  public
    constructor Create(AOwnerControl: TCustomThemedTabControl); reintroduce;
  end;

constructor TThemedTabHeaderInput.Create(AOwnerControl: TCustomThemedTabControl);
begin
  inherited Create(AOwnerControl);
  FOwnerControl := AOwnerControl;
  ControlStyle := ControlStyle - [csCaptureMouse];
  Parent := AOwnerControl;
end;

procedure TThemedTabHeaderInput.Paint;
begin
end;

procedure TThemedTabHeaderInput.CMMouseLeave(var Message: TMessage);
begin
  if FOwnerControl <> nil then FOwnerControl.CMMouseLeave(Message);
  Message.Result := 1;
end;

procedure TThemedTabHeaderInput.WMMouseMove(var Message: TWMMouseMove);
begin
  if FOwnerControl <> nil then FOwnerControl.WMMouseMove(Message);
  Message.Result := 1;
end;

procedure TThemedTabHeaderInput.WMMouseWheel(var Message: TWMMouseWheel);
begin
  if FOwnerControl <> nil then FOwnerControl.WMMouseWheel(Message);
  Message.Result := 1;
end;

procedure TThemedTabHeaderInput.WMLButtonDown(var Message: TWMLButtonDown);
begin
  if FOwnerControl <> nil then FOwnerControl.WMLButtonDown(Message);
  Message.Result := 1;
end;

procedure TThemedTabHeaderInput.WMLButtonUp(var Message: TWMLButtonUp);
begin
  if FOwnerControl <> nil then FOwnerControl.WMLButtonUp(Message);
  Message.Result := 1;
end;

procedure TThemedTabHeaderInput.WMLButtonDblClk(var Message: TWMLButtonDblClk);
begin
  if FOwnerControl <> nil then FOwnerControl.WMLButtonDblClk(Message);
  Message.Result := 1;
end;

procedure TThemedTabHeaderInput.WMMButtonDown(var Message: TWMMButtonDown);
begin
  if FOwnerControl <> nil then FOwnerControl.WMMButtonDown(Message);
  Message.Result := 1;
end;

procedure TThemedTabHeaderInput.WMMButtonUp(var Message: TWMMButtonUp);
begin
  if FOwnerControl <> nil then FOwnerControl.WMMButtonUp(Message);
  Message.Result := 1;
end;

procedure TThemedTabHeaderInput.WMMButtonDblClk(var Message: TWMMButtonDblClk);
begin
  if FOwnerControl <> nil then FOwnerControl.WMMButtonDblClk(Message);
  Message.Result := 1;
end;

procedure TThemedTabHeaderInput.WMRButtonDown(var Message: TWMRButtonDown);
begin
  if FOwnerControl <> nil then FOwnerControl.WMRButtonDown(Message);
  Message.Result := 1;
end;

procedure TThemedTabHeaderInput.WMRButtonUp(var Message: TWMRButtonUp);
begin
  if FOwnerControl <> nil then FOwnerControl.WMRButtonUp(Message);
  Message.Result := 1;
end;

procedure TThemedTabHeaderInput.WMRButtonDblClk(var Message: TWMRButtonDblClk);
begin
  if FOwnerControl <> nil then FOwnerControl.WMRButtonDblClk(Message);
  Message.Result := 1;
end;

constructor TCustomThemedTabControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  TabStop := True;
  DoubleBuffered := True;
  ParentBackground := False;
  StyleElements := [];
  FRenderCanvas := TNimbusRenderCanvas.Create;
  FRenderer := TThemedTabRenderer.Create;
  FStates := TDictionary<TTabSheet, TThemedTabPageState>.Create;
  FImageChangeLink := TChangeLink.Create;
  FImageChangeLink.OnChange := ImageListChanged;
  FImageIcons := TObjectList<TIcon>.Create(True);
  FLogicalBorderThickness := 1;
  FLogicalTextPaddingLeft := 6;
  FLogicalTextPaddingTop := 1;
  FLogicalTextPaddingHorizontal := 12;
  FLogicalTextPaddingVertical := 2;
  FLogicalCloseButtonSize := 12;
  FLogicalCloseButtonAreaWidth := 18;
  FLogicalIconSize := 14;
  FLogicalBadgeHorizontalPadding := 6;
  FLogicalBadgeHeight := 16;
  FLogicalActiveIndicatorHeight := 3;
  FLogicalMinimumTabWidth := 48;
  FLogicalMaximumTabWidth := 220;
  FLogicalTabHeaderHorizontalPadding := 16;
  FLogicalTabHeaderVerticalPadding := 2;
  FLogicalTabHeaderHeight := 0;
  FHoveredIndex := -1;
  FHoveredCloseIndex := -1;
  FPressedCloseIndex := -1;
  FDragSourceIndex := -1;
  FLayoutValid := False;
  FPendingSelectionIndex := -1;
  FOverflowMode := tomScrollAndMenu;
  FTabRows := 1;
  FTabListMenu := TThemedPopupMenu.Create(Self);
  FOverflowHover := -1;
  FOverflowPressed := -1;
  FOverflowRepeatTimer := TTimer.Create(Self);
  FOverflowRepeatTimer.Enabled := False;
  FOverflowRepeatTimer.Interval := 340;
  FOverflowRepeatTimer.OnTimer := OverflowRepeatTick;
  FAutoScrollActiveTab := True;
  FScrollTabsWithMouseWheel := True;
  FShowActiveIndicator := True;
  FAllowTabReorder := True;
  FCloseOnMiddleClick := True;
  FCloseButtonMode := tcbmActiveAndHovered;
  FTabTextMode := tttmFullText;
  FTabTextTrimming := tttNone;
  FVariableTabWidth := True;
  ApplyDpiScaling;
  FHeaderInput := TThemedTabHeaderInput.Create(Self);
  FHeaderInput.SetBounds(0, 0, Width, GetEffectiveHeaderHeight);
  FHeaderInput.BringToFront;
end;

destructor TCustomThemedTabControl.Destroy;
begin
  StopOverflowRepeat;
  FTabListMenu.Free;
  FTabListMenu := nil;
  if FHeaderInput is TThemedTabHeaderInput then TThemedTabHeaderInput(FHeaderInput).FOwnerControl := nil;
  if FThemeRegistered then
  begin
    ThemeManager.UnregisterAware(Self);
    FThemeRegistered := False;
  end;
  if FObservedImages <> nil then FObservedImages.UnRegisterChanges(FImageChangeLink);
  if FTabContextMenu <> nil then FTabContextMenu.RemoveFreeNotification(Self);
  inherited Destroy;
  FImageIcons.Free;
  FImageChangeLink.Free;
  FStates.Free;
  FRenderer.Free;
  FPalette.Free;
  FRenderCanvas := nil;
end;

procedure TCustomThemedTabControl.RegisterThemeAware;
begin
  if FThemeRegistered or (csLoading in ComponentState) or (csReading in ComponentState) or (csDestroying in ComponentState) then Exit;
  ThemeManager.RegisterAware(Self);
  FThemeRegistered := True;
end;

procedure TCustomThemedTabControl.Loaded;
var
  I: Integer;
begin
  inherited Loaded;
  RegisterThemeAware;
  SyncImageList;
  ApplyDpiScaling;
  for I := 0 to PageCount - 1 do ApplyThemeToPage(Pages[I]);
end;

procedure TCustomThemedTabControl.AdjustClientRect(var Rect: TRect);
begin
  Rect := ClientRect;
  Inc(Rect.Left, Padding.Left);
  Inc(Rect.Top, GetEffectiveHeaderHeight + Padding.Top);
  Dec(Rect.Right, Padding.Right);
  Dec(Rect.Bottom, Padding.Bottom);
  if Rect.Right < Rect.Left then Rect.Right := Rect.Left;
  if Rect.Bottom < Rect.Top then Rect.Bottom := Rect.Top;
end;

procedure TCustomThemedTabControl.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := (Params.Style or WS_TABSTOP or WS_CLIPCHILDREN or TCS_MULTILINE or TCS_FIXEDWIDTH) and not (TCS_HOTTRACK or TCS_FOCUSNEVER);
end;

procedure TCustomThemedTabControl.CreateWnd;
begin
  inherited CreateWnd;
  FLayoutValid := False;
  ApplyDpiScaling;
  HideNativeTabScroller;
end;

procedure TCustomThemedTabControl.Resize;
begin
  inherited Resize;
  UpdateHeaderInputBounds;
  if FFirstVisibleTabIndex < 0 then FFirstVisibleTabIndex := 0;
  if FFirstVisibleTabIndex >= PageCount then FFirstVisibleTabIndex := Max(0, PageCount - 1);
  FLayoutValid := False;
  HideNativeTabScroller;
  Invalidate;
end;

procedure TCustomThemedTabControl.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited ChangeScale(M, D, isDpiChange);
  ApplyDpiScaling;
end;

procedure TCustomThemedTabControl.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation <> opRemove) or (csDestroying in ComponentState) then Exit;
  if AComponent = FTabContextMenu then FTabContextMenu := nil;
  if AComponent = FObservedImages then
  begin
    FObservedImages := nil;
    FImageIcons.Clear;
  end;
  if AComponent is TTabSheet then FStates.Remove(TTabSheet(AComponent));
end;

procedure TCustomThemedTabControl.SetMultiLineTabs(const AValue: Boolean);
begin
  if FMultiLineTabs = AValue then Exit;
  FMultiLineTabs := AValue;
  FTabRows := 1;
  FFirstVisibleTabIndex := 0;
  FLayoutValid := False;
  ApplyNativeTabMetrics;
  UpdateHeaderInputBounds;
  Realign;
  Invalidate;
end;

procedure TCustomThemedTabControl.InvalidateHeader;
var
  LRect: TRect;
begin
  if not HandleAllocated then Exit;
  LRect := Rect(0, 0, ClientWidth, GetEffectiveHeaderHeight);
  InvalidateRect(Handle, @LRect, False);
end;

procedure TCustomThemedTabControl.SetRenderer(const AValue: TThemedTabRenderer);
begin
  if FRenderer = AValue then Exit;
  FRenderer.Free;
  if AValue <> nil then FRenderer := AValue else FRenderer := TThemedTabRenderer.Create;
  Invalidate;
end;

procedure TCustomThemedTabControl.SetShowActiveIndicator(const AValue: Boolean);
begin
  if FShowActiveIndicator = AValue then Exit;
  FShowActiveIndicator := AValue;
  Invalidate;
end;

procedure TCustomThemedTabControl.SetAllowTabReorder(const AValue: Boolean);
begin
  if FAllowTabReorder = AValue then Exit;
  FAllowTabReorder := AValue;
  if not FAllowTabReorder then
  begin
    FDragSourceIndex := -1;
    FDragging := False;
    if (FPressedCloseIndex < 0) and MouseCapture then MouseCapture := False;
  end;
end;

procedure TCustomThemedTabControl.SetCloseOnMiddleClick(const AValue: Boolean);
begin
  if FCloseOnMiddleClick = AValue then Exit;
  FCloseOnMiddleClick := AValue;
end;

procedure TCustomThemedTabControl.SetCloseButtonMode(const AValue: TThemedTabCloseButtonMode);
begin
  if FCloseButtonMode = AValue then Exit;
  FCloseButtonMode := AValue;
  if FCloseButtonMode = tcbmNone then
  begin
    FHoveredCloseIndex := -1;
    FPressedCloseIndex := -1;
    if not FDragging and MouseCapture then MouseCapture := False;
  end;
  InvalidateTabLayout;
end;

procedure TCustomThemedTabControl.SetTabContextMenu(const AValue: TPopupMenu);
begin
  if FTabContextMenu = AValue then Exit;
  if FTabContextMenu <> nil then FTabContextMenu.RemoveFreeNotification(Self);
  FTabContextMenu := AValue;
  if FTabContextMenu <> nil then FTabContextMenu.FreeNotification(Self);
end;

procedure TCustomThemedTabControl.SetTabTextMode(const AValue: TThemedTabTextMode);
begin
  if FTabTextMode = AValue then Exit;
  FTabTextMode := AValue;
  InvalidateTabLayout;
end;

procedure TCustomThemedTabControl.SetTabTextTrimming(const AValue: TThemedTabTextTrimming);
begin
  if FTabTextTrimming = AValue then Exit;
  FTabTextTrimming := AValue;
  Invalidate;
end;

procedure TCustomThemedTabControl.SetMinimumTabWidth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(20, AValue);
  if FLogicalMinimumTabWidth = LValue then Exit;
  FLogicalMinimumTabWidth := LValue;
  ApplyDpiScaling;
end;

procedure TCustomThemedTabControl.SetMaximumTabWidth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(40, AValue);
  if FLogicalMaximumTabWidth = LValue then Exit;
  FLogicalMaximumTabWidth := LValue;
  ApplyDpiScaling;
end;

procedure TCustomThemedTabControl.SetVariableTabWidth(const AValue: Boolean);
begin
  if FVariableTabWidth = AValue then Exit;
  FVariableTabWidth := AValue;
  InvalidateTabLayout;
end;

procedure TCustomThemedTabControl.SetTabHeaderHorizontalPadding(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(0, AValue);
  if FLogicalTabHeaderHorizontalPadding = LValue then Exit;
  FLogicalTabHeaderHorizontalPadding := LValue;
  ApplyDpiScaling;
end;

procedure TCustomThemedTabControl.SetTabHeaderVerticalPadding(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(0, AValue);
  if FLogicalTabHeaderVerticalPadding = LValue then Exit;
  FLogicalTabHeaderVerticalPadding := LValue;
  ApplyDpiScaling;
end;

procedure TCustomThemedTabControl.SetTabHeaderHeight(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(0, AValue);
  if FLogicalTabHeaderHeight = LValue then Exit;
  FLogicalTabHeaderHeight := LValue;
  ApplyDpiScaling;
end;

function TCustomThemedTabControl.DefaultTabState: TThemedTabPageState;
begin
  Result.Closable := True;
  Result.Pinned := False;
  Result.Unsaved := False;
  Result.BadgeText := '';
end;

function TCustomThemedTabControl.GetState(const APage: TTabSheet): TThemedTabPageState;
begin
  Result := DefaultTabState;
  if APage = nil then Exit;
  if not FStates.TryGetValue(APage, Result) then
  begin
    Result := DefaultTabState;
    FStates.Add(APage, Result);
  end;
end;

procedure TCustomThemedTabControl.SetState(const APage: TTabSheet; const AState: TThemedTabPageState);
begin
  if APage = nil then Exit;
  FStates.AddOrSetValue(APage, AState);
end;

function TCustomThemedTabControl.GetTabClosable(const APage: TTabSheet): Boolean;
begin
  Result := GetState(APage).Closable;
end;

procedure TCustomThemedTabControl.SetTabClosable(const APage: TTabSheet; const AClosable: Boolean);
var
  LState: TThemedTabPageState;
begin
  if APage = nil then Exit;
  LState := GetState(APage);
  if LState.Closable = AClosable then Exit;
  LState.Closable := AClosable;
  SetState(APage, LState);
  InvalidateTabLayout;
end;

function TCustomThemedTabControl.GetTabPinned(const APage: TTabSheet): Boolean;
begin
  Result := GetState(APage).Pinned;
end;

procedure TCustomThemedTabControl.SetTabPinned(const APage: TTabSheet; const APinned: Boolean);
var
  LState: TThemedTabPageState;
begin
  if APage = nil then Exit;
  LState := GetState(APage);
  if (LState.Pinned = APinned) and (not APinned or not LState.Closable) then Exit;
  LState.Pinned := APinned;
  if APinned then LState.Closable := False;
  SetState(APage, LState);
  InvalidateTabLayout;
end;

function TCustomThemedTabControl.GetTabUnsaved(const APage: TTabSheet): Boolean;
begin
  Result := GetState(APage).Unsaved;
end;

procedure TCustomThemedTabControl.SetTabUnsaved(const APage: TTabSheet; const AUnsaved: Boolean);
var
  LState: TThemedTabPageState;
begin
  if APage = nil then Exit;
  LState := GetState(APage);
  if LState.Unsaved = AUnsaved then Exit;
  LState.Unsaved := AUnsaved;
  SetState(APage, LState);
  InvalidateTabLayout;
end;

function TCustomThemedTabControl.GetTabBadgeText(const APage: TTabSheet): string;
begin
  Result := GetState(APage).BadgeText;
end;

procedure TCustomThemedTabControl.SetTabBadgeText(const APage: TTabSheet; const ABadgeText: string);
var
  LState: TThemedTabPageState;
begin
  if APage = nil then Exit;
  LState := GetState(APage);
  if LState.BadgeText = ABadgeText then Exit;
  LState.BadgeText := ABadgeText;
  SetState(APage, LState);
  InvalidateTabLayout;
end;

procedure TCustomThemedTabControl.ApplyTheme(const APalette: TThemePalette);
var
  I: Integer;
begin
  if APalette = nil then Exit;
  if FPalette = nil then FPalette := APalette.Clone else FPalette.Assign(APalette);
  Color := ThemeColorToColor(FPalette.PanelBackColor);
  Font.Color := ThemeColorToColor(FPalette.TabForeColor);
  for I := 0 to PageCount - 1 do ApplyThemeToPage(Pages[I]);
  if not (csDestroying in ComponentState) then Invalidate;
end;

procedure TCustomThemedTabControl.ApplyThemeToPage(const APage: TTabSheet);
begin
  if (APage = nil) or (FPalette = nil) then Exit;
  TTabSheetAccess(APage).Color := ThemeColorToColor(FPalette.PanelBackColor);
  APage.Font.Color := ThemeColorToColor(FPalette.ForeColor);
  APage.Invalidate;
end;

procedure TCustomThemedTabControl.SetStyleMode(const AValue: TThemedControlStyleMode);
begin
  if FStyleMode = AValue then Exit;
  FStyleMode := AValue;
  ApplyDpiScaling;
end;

procedure TCustomThemedTabControl.ApplyDpiScaling;
var
  LPPI: Integer;
begin
  LPPI := CurrentPPI;
  if LPPI <= 0 then LPPI := 96;
  FBorderThickness := Max(1, NimbusScaleValue(FLogicalBorderThickness, LPPI));
  FTextPaddingLeft := NimbusScaleValue(FLogicalTextPaddingLeft - Ord(FStyleMode = stCompact) * Min(2, Max(0, FLogicalTextPaddingLeft)), LPPI);
  FTextPaddingTop := NimbusScaleValue(FLogicalTextPaddingTop - Ord(FStyleMode = stCompact) * Min(1, Max(0, FLogicalTextPaddingTop)), LPPI);
  FTextPaddingHorizontal := NimbusScaleValue(FLogicalTextPaddingHorizontal - Ord(FStyleMode = stCompact) * Min(4, Max(0, FLogicalTextPaddingHorizontal)), LPPI);
  FTextPaddingVertical := NimbusScaleValue(FLogicalTextPaddingVertical - Ord(FStyleMode = stCompact) * Min(1, Max(0, FLogicalTextPaddingVertical)), LPPI);
  FCloseButtonSize := NimbusScaleValue(FLogicalCloseButtonSize - Ord(FStyleMode = stCompact) * Min(2, Max(0, FLogicalCloseButtonSize - 8)), LPPI);
  FCloseButtonAreaWidth := NimbusScaleValue(FLogicalCloseButtonAreaWidth - Ord(FStyleMode = stCompact) * Min(4, Max(0, FLogicalCloseButtonAreaWidth - 12)), LPPI);
  FIconSize := NimbusScaleValue(FLogicalIconSize - Ord(FStyleMode = stCompact) * Min(2, Max(0, FLogicalIconSize - 10)), LPPI);
  FBadgeHorizontalPadding := NimbusScaleValue(FLogicalBadgeHorizontalPadding - Ord(FStyleMode = stCompact) * Min(2, Max(0, FLogicalBadgeHorizontalPadding - 2)), LPPI);
  FBadgeHeight := NimbusScaleValue(FLogicalBadgeHeight - Ord(FStyleMode = stCompact) * Min(3, Max(0, FLogicalBadgeHeight - 12)), LPPI);
  FActiveIndicatorHeight := Max(1, NimbusScaleValue(FLogicalActiveIndicatorHeight - Ord((FStyleMode = stCompact) and (FLogicalActiveIndicatorHeight = 3)), LPPI));
  FMinimumTabWidth := Max(20, NimbusScaleValue(FLogicalMinimumTabWidth - Ord((FStyleMode = stCompact) and (FLogicalMinimumTabWidth = 48)) * 8, LPPI));
  FMaximumTabWidth := Max(FMinimumTabWidth, NimbusScaleValue(FLogicalMaximumTabWidth, LPPI));
  FTabHeaderHorizontalPadding := NimbusScaleValue(FLogicalTabHeaderHorizontalPadding - Ord((FStyleMode = stCompact) and (FLogicalTabHeaderHorizontalPadding = 16)) * 6, LPPI);
  FTabHeaderVerticalPadding := NimbusScaleValue(FLogicalTabHeaderVerticalPadding - Ord((FStyleMode = stCompact) and (FLogicalTabHeaderVerticalPadding = 2)), LPPI);
  if FLogicalTabHeaderHeight > 0 then
  begin
    if FStyleMode = stCompact then
      FTabHeaderHeight := Max(NimbusScaleValue(18, LPPI), NimbusScaleValue(FLogicalTabHeaderHeight - 8, LPPI))
    else
      FTabHeaderHeight := Max(18, NimbusScaleValue(FLogicalTabHeaderHeight, LPPI));
  end
  else FTabHeaderHeight := 0;
  ApplyNativeTabMetrics;
  UpdateHeaderInputBounds;
  InvalidateTabLayout;
end;

function TCustomThemedTabControl.GetEffectiveHeaderHeight: Integer;
var
  LFontHeight: Integer;
begin
  if FTabHeaderHeight > 0 then Exit(FTabHeaderHeight * Max(1, FTabRows));
  LFontHeight := Abs(Font.Height);
  if LFontHeight = 0 then LFontHeight := NimbusScaleValue(15, CurrentPPI);
  Result := Max(NimbusScaleValue(20 - Ord(FStyleMode = stCompact) * 2, CurrentPPI), LFontHeight + (FTabHeaderVerticalPadding * 2)) * Max(1, FTabRows);
end;

procedure TCustomThemedTabControl.ApplyNativeTabMetrics;
var
  LHeight: Integer;
begin
  if not HandleAllocated or FApplyingNativeMetrics then Exit;
  FApplyingNativeMetrics := True;
  try
    LHeight := GetEffectiveHeaderHeight div Max(1, FTabRows);
    SendMessage(Handle, TCM_SETITEMSIZE, 0, MakeLParam(1, LHeight));
    SendMessage(Handle, TCM_SETPADDING, 0, MakeLParam(0, 0));
    Perform(WM_SIZE, SIZE_RESTORED, MakeLParam(ClientWidth, ClientHeight));
    Realign;
    HideNativeTabScroller;
  finally
    FApplyingNativeMetrics := False;
  end;
end;

procedure TCustomThemedTabControl.UpdateHeaderInputBounds;
begin
  if FHeaderInput = nil then Exit;
  FHeaderInput.SetBounds(0, 0, ClientWidth, GetEffectiveHeaderHeight);
  FHeaderInput.BringToFront;
end;

procedure TCustomThemedTabControl.InvalidateTabLayout;
begin
  FLayoutValid := False;
  InvalidateHeader;
end;

procedure TCustomThemedTabControl.HideNativeTabScroller;
var
  LHandle: HWND;
begin
  if not HandleAllocated then Exit;
  LHandle := FindWindowEx(Handle, 0, 'msctls_updown32', nil);
  if LHandle <> 0 then ShowWindow(LHandle, SW_HIDE);
end;

procedure TCustomThemedTabControl.SyncImageList;
begin
  if FObservedImages = Images then Exit;
  if FObservedImages <> nil then FObservedImages.UnRegisterChanges(FImageChangeLink);
  FObservedImages := Images;
  if FObservedImages <> nil then FObservedImages.RegisterChanges(FImageChangeLink);
  RebuildImageCache;
  FLayoutValid := False;
end;

procedure TCustomThemedTabControl.RebuildImageCache;
var
  I: Integer;
  LIcon: TIcon;
begin
  FImageIcons.Clear;
  if FObservedImages = nil then Exit;
  for I := 0 to FObservedImages.Count - 1 do
  begin
    LIcon := TIcon.Create;
    FObservedImages.GetIcon(I, LIcon);
    FImageIcons.Add(LIcon);
  end;
end;

procedure TCustomThemedTabControl.ImageListChanged(Sender: TObject);
begin
  RebuildImageCache;
  InvalidateTabLayout;
end;

function TCustomThemedTabControl.GetImageIcon(const APage: TTabSheet): HICON;
var
  LIndex: Integer;
begin
  Result := 0;
  if (APage = nil) or (FObservedImages = nil) then Exit;
  LIndex := APage.ImageIndex;
  if (LIndex < 0) or (LIndex >= FImageIcons.Count) then Exit;
  Result := FImageIcons[LIndex].Handle;
end;

function TCustomThemedTabControl.GetTabDisplayText(const APage: TTabSheet; const ATabIndex: Integer): string;
begin
  if APage <> nil then Result := APage.Caption else Result := '';
  if (APage <> nil) and GetTabUnsaved(APage) then Result := Result + ' *';
end;

function TCustomThemedTabControl.GetTabShortText(const APage: TTabSheet; const ATabIndex: Integer): string;
var
  LIndex: Integer;
begin
  if APage <> nil then Result := APage.Caption else Result := '';
  if Result = '' then Exit;
  LIndex := LastDelimiter('\/', Result);
  if (LIndex > 0) and (LIndex < Length(Result)) then Delete(Result, 1, LIndex);
end;

function TCustomThemedTabControl.GetEffectiveTabText(const APage: TTabSheet; const ATabIndex: Integer): string;
begin
  if FTabTextMode = tttmShortText then Result := GetTabShortText(APage, ATabIndex) else Result := GetTabDisplayText(APage, ATabIndex);
end;

function TCustomThemedTabControl.GetTabTextFlags(const APage: TTabSheet; const ATabIndex: Integer): TNimbusTextFlags;
begin
  Result := [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix];
  if FTabTextTrimming = tttEllipsis then Include(Result, ntfEndEllipsis);
  if UseRightToLeftReading then Include(Result, ntfRightToLeft);
end;

function TCustomThemedTabControl.GetReservedHeaderRightWidth: Integer;
begin
  Result := 0;
  if FOverflowVisible then
  begin
    if FOverflowMode in [tomScrollButtons, tomScrollAndMenu] then Inc(Result, NimbusScaleValue(48, CurrentPPI));
    if FOverflowMode in [tomDropDownMenu, tomScrollAndMenu] then Inc(Result, NimbusScaleValue(24, CurrentPPI));
  end;
end;

function TCustomThemedTabControl.GetDrawableTabRect(const ATabIndex: Integer): TRect;
begin
  Result := TRect.Empty;
  if (ATabIndex < 0) or (ATabIndex >= PageCount) then Exit;
  EnsureTabRects;
  if ATabIndex < Length(FTabRects) then Result := FTabRects[ATabIndex];
end;

procedure TCustomThemedTabControl.EnsureTabRects;
var
  LDC: HDC;
begin
  if not HandleAllocated or (FRenderCanvas = nil) then Exit;
  SyncImageList;
  if FLayoutValid then Exit;
  LDC := GetDC(Handle);
  if LDC = 0 then Exit;
  Canvas.Lock;
  try
    Canvas.Handle := LDC;
    try
      FRenderCanvas.BeginRender(Canvas);
      try
        RebuildTabRects(FRenderCanvas);
      finally
        FRenderCanvas.EndRender;
      end;
    finally
      Canvas.Handle := 0;
    end;
  finally
    Canvas.Unlock;
    ReleaseDC(Handle, LDC);
  end;
end;

procedure TCustomThemedTabControl.RebuildTabRects(const ACanvas: INimbusRenderCanvas);
var
  I, LCurrentX, LWidth, LMaxRight, LReservedRight, LHeaderHeight, LTotalWidth, LRow, LRows, LOldRows: Integer;
begin
  SetLength(FTabRects, PageCount);
  for I := 0 to High(FTabRects) do FTabRects[I] := TRect.Empty;
  if PageCount = 0 then
  begin
    FOverflowVisible := False;
    FTabRows := 1;
    FFirstVisibleTabIndex := 0;
    FLayoutValid := True;
    Exit;
  end;
  FFirstVisibleTabIndex := EnsureRange(FFirstVisibleTabIndex, 0, PageCount - 1);
  if not Pages[FFirstVisibleTabIndex].TabVisible then
  begin
    I := FindNextVisiblePageIndex(FFirstVisibleTabIndex - 1);
    if I < 0 then I := FindPreviousVisiblePageIndex(FFirstVisibleTabIndex + 1);
    if I >= 0 then FFirstVisibleTabIndex := I;
  end;
  LHeaderHeight := GetEffectiveHeaderHeight;
  LTotalWidth := 0;
  for I := 0 to PageCount - 1 do
    if Pages[I].TabVisible then Inc(LTotalWidth, MeasureTabWidth(ACanvas, I));
  if FMultiLineTabs then
  begin
    LOldRows := FTabRows;
    LRows := 1;
    LCurrentX := 0;
    for I := 0 to PageCount - 1 do
      if Pages[I].TabVisible then
      begin
        LWidth := Min(MeasureTabWidth(ACanvas, I), Max(1, ClientWidth));
        if (LCurrentX > 0) and (LCurrentX + LWidth > ClientWidth) then
        begin
          Inc(LRows);
          LCurrentX := 0;
        end;
        Inc(LCurrentX, LWidth);
      end;
    FTabRows := LRows;
    FOverflowVisible := False;
    FFirstVisibleTabIndex := 0;
    LHeaderHeight := GetEffectiveHeaderHeight div FTabRows;
    LCurrentX := 0;
    LRow := 0;
    for I := 0 to PageCount - 1 do
      if Pages[I].TabVisible then
      begin
        LWidth := Min(MeasureTabWidth(ACanvas, I), Max(1, ClientWidth));
        if (LCurrentX > 0) and (LCurrentX + LWidth > ClientWidth) then
        begin
          Inc(LRow);
          LCurrentX := 0;
        end;
        FTabRects[I] := Rect(LCurrentX, LRow * LHeaderHeight, LCurrentX + LWidth, (LRow + 1) * LHeaderHeight);
        Inc(LCurrentX, LWidth);
      end;
    FLayoutValid := True;
    if (LOldRows <> FTabRows) and HandleAllocated and not FUpdatingRows then
    begin
      FUpdatingRows := True;
      try
        UpdateHeaderInputBounds;
        PostMessage(Handle, WM_SIZE, SIZE_RESTORED, MakeLParam(ClientWidth, ClientHeight));
      finally
        FUpdatingRows := False;
      end;
    end;
    Exit;
  end;
  FTabRows := 1;
  FOverflowVisible := (FOverflowMode <> tomNone) and (LTotalWidth > ClientWidth);
  if not FOverflowVisible then FFirstVisibleTabIndex := 0;
  LCurrentX := 0;
  LReservedRight := Max(0, GetReservedHeaderRightWidth);
  LMaxRight := Max(0, ClientWidth - LReservedRight);
  for I := FFirstVisibleTabIndex to PageCount - 1 do
  begin
    if not Pages[I].TabVisible then Continue;
    LWidth := MeasureTabWidth(ACanvas, I);
    if LCurrentX >= LMaxRight then Break;
    if LCurrentX + LWidth > LMaxRight then LWidth := LMaxRight - LCurrentX;
    if LWidth < 1 then Break;
    FTabRects[I] := Rect(LCurrentX, 0, LCurrentX + LWidth, LHeaderHeight);
    Inc(LCurrentX, LWidth);
  end;
  FLayoutValid := True;
end;

function TCustomThemedTabControl.MeasureTabWidth(const ACanvas: INimbusRenderCanvas; const ATabIndex: Integer): Integer;
var
  LPage: TTabSheet;
  LState: TThemedTabPageState;
  LTextSize, LBadgeSize: TSize;
  LText: string;
begin
  Result := FMinimumTabWidth;
  if (ATabIndex < 0) or (ATabIndex >= PageCount) or (ACanvas = nil) then Exit;
  LPage := Pages[ATabIndex];
  LState := GetState(LPage);
  LText := GetEffectiveTabText(LPage, ATabIndex);
  LTextSize := ACanvas.MeasureText(LText, Font, 0, [ntfSingleLine, ntfNoPrefix]);
  Result := LTextSize.cx + FTabHeaderHorizontalPadding;
  if LState.Pinned then Inc(Result, FIconSize);
  if GetImageIcon(LPage) <> 0 then Inc(Result, FIconSize + NimbusScaleValue(5, CurrentPPI));
  if LState.BadgeText <> '' then
  begin
    LBadgeSize := ACanvas.MeasureText(LState.BadgeText, Font, 0, [ntfSingleLine, ntfNoPrefix]);
    Inc(Result, LBadgeSize.cx + (FBadgeHorizontalPadding * 2) + NimbusScaleValue(5, CurrentPPI));
  end;
  if ShouldReserveCloseButtonSpace(ATabIndex) then Inc(Result, FCloseButtonAreaWidth);
  Result := EnsureRange(Result, FMinimumTabWidth, FMaximumTabWidth);
end;

function TCustomThemedTabControl.HitTestTab(const APoint: TPoint): Integer;
var
  I, LReservedRight: Integer;
  LRect: TRect;
begin
  Result := -1;
  LReservedRight := GetReservedHeaderRightWidth;
  if (LReservedRight > 0) and (APoint.X >= ClientWidth - LReservedRight) then Exit;
  EnsureTabRects;
  for I := 0 to High(FTabRects) do
  begin
    LRect := FTabRects[I];
    if LRect.IsEmpty then Continue;
    Inc(LRect.Right);
    Inc(LRect.Bottom);
    if LRect.Contains(APoint) then Exit(I);
  end;
end;

function TCustomThemedTabControl.HitTestCloseButton(const APoint: TPoint): Integer;
var
  I, LReservedRight: Integer;
  LTabRect, LCloseRect: TRect;
begin
  Result := -1;
  LReservedRight := GetReservedHeaderRightWidth;
  if (LReservedRight > 0) and (APoint.X >= ClientWidth - LReservedRight) then Exit;
  EnsureTabRects;
  for I := 0 to PageCount - 1 do
  begin
    if not ShouldReserveCloseButtonSpace(I) then Continue;
    LTabRect := FTabRects[I];
    if LTabRect.IsEmpty then Continue;
    LCloseRect := GetCloseButtonRect(LTabRect);
    if LCloseRect.Contains(APoint) then Exit(I);
  end;
end;

function TCustomThemedTabControl.GetCloseButtonRect(const ATabRect: TRect): TRect;
var
  LX, LY: Integer;
begin
  LX := ATabRect.Right - FCloseButtonAreaWidth + (FCloseButtonAreaWidth - FCloseButtonSize) div 2;
  LY := ATabRect.Top + (ATabRect.Height - FCloseButtonSize) div 2;
  Result := Rect(LX, LY, LX + FCloseButtonSize, LY + FCloseButtonSize);
end;

function TCustomThemedTabControl.ShouldShowCloseButton(const AIndex: Integer): Boolean;
var
  LState: TThemedTabPageState;
begin
  Result := False;
  if (AIndex < 0) or (AIndex >= PageCount) then Exit;
  LState := GetState(Pages[AIndex]);
  if not LState.Closable or LState.Pinned or (FCloseButtonMode = tcbmNone) then Exit;
  case FCloseButtonMode of
    tcbmAll: Result := True;
    tcbmActiveOnly: Result := ActivePage = Pages[AIndex];
    tcbmActiveAndHovered: Result := (ActivePage = Pages[AIndex]) or (FHoveredIndex = AIndex);
  end;
end;

function TCustomThemedTabControl.ShouldReserveCloseButtonSpace(const AIndex: Integer): Boolean;
var
  LState: TThemedTabPageState;
begin
  Result := False;
  if (AIndex < 0) or (AIndex >= PageCount) then Exit;
  LState := GetState(Pages[AIndex]);
  Result := LState.Closable and not LState.Pinned and (FCloseButtonMode <> tcbmNone);
end;

function TCustomThemedTabControl.FindPreviousVisiblePageIndex(const AIndex: Integer): Integer;
var
  I: Integer;
begin
  for I := Min(AIndex - 1, PageCount - 1) downto 0 do if Pages[I].TabVisible then Exit(I);
  Result := -1;
end;

function TCustomThemedTabControl.FindNextVisiblePageIndex(const AIndex: Integer): Integer;
var
  I: Integer;
begin
  for I := Max(0, AIndex + 1) to PageCount - 1 do if Pages[I].TabVisible then Exit(I);
  Result := -1;
end;

function TCustomThemedTabControl.NativeTabIndexToPageIndex(const ATabIndex: Integer): Integer;
var
  I, LVisibleIndex: Integer;
begin
  Result := -1;
  if ATabIndex < 0 then Exit;
  LVisibleIndex := -1;
  for I := 0 to PageCount - 1 do
    if Pages[I].TabVisible then
    begin
      Inc(LVisibleIndex);
      if LVisibleIndex = ATabIndex then Exit(I);
    end;
end;

function TCustomThemedTabControl.SelectPageIndex(const APageIndex: Integer): Boolean;
var
  LCancel: Boolean;
  LOldPage: TTabSheet;
begin
  Result := False;
  if (APageIndex < 0) or (APageIndex >= PageCount) or not Pages[APageIndex].TabVisible or not Pages[APageIndex].Enabled then Exit;
  if ActivePage = Pages[APageIndex] then Exit(True);
  LCancel := False;
  DoTabSelecting(APageIndex, Pages[APageIndex], LCancel);
  if LCancel then Exit;
  FPendingSelectionIndex := APageIndex;
  try
    if not inherited CanChange then Exit;
    LOldPage := ActivePage;
    TPageControl(Self).ActivePage := Pages[APageIndex];
    Result := ActivePage = Pages[APageIndex];
    if Result and (LOldPage <> ActivePage) then
    begin
      if FHeaderInput <> nil then FHeaderInput.BringToFront;
      InvalidateHeader;
    end;
  finally
    FPendingSelectionIndex := -1;
  end;
end;

function TCustomThemedTabControl.IsPointInHeader(const APoint: TPoint): Boolean;
begin
  Result := (APoint.X >= 0) and (APoint.X < ClientWidth) and (APoint.Y >= 0) and (APoint.Y < GetEffectiveHeaderHeight);
end;

procedure TCustomThemedTabControl.AcquireMouseFocus;
begin
  if CanFocus and not Focused then SetFocus;
end;

function TCustomThemedTabControl.CanChange: Boolean;
var
  LCancel: Boolean;
  LPageIndex: Integer;
begin
  Result := inherited CanChange;
  if not Result then Exit;
  if FPendingSelectionIndex >= 0 then Exit;
  if not HandleAllocated then Exit;
  LPageIndex := NativeTabIndexToPageIndex(SendMessage(Handle, TCM_GETCURFOCUS, 0, 0));
  if (LPageIndex < 0) or (LPageIndex >= PageCount) or (ActivePage = Pages[LPageIndex]) then Exit;
  LCancel := False;
  DoTabSelecting(LPageIndex, Pages[LPageIndex], LCancel);
  Result := not LCancel;
end;

procedure TCustomThemedTabControl.DoTabSelecting(const ATabIndex: Integer; const ATabPage: TTabSheet; var ACancel: Boolean);
begin
  if Assigned(FOnTabSelectingEx) then FOnTabSelectingEx(Self, ATabIndex, ATabPage, ACancel);
end;

procedure TCustomThemedTabControl.DoTabClosing(const ATabIndex: Integer; const ATabPage: TTabSheet; const AReason: TThemedTabCloseReason; var ACancel: Boolean);
begin
  if Assigned(FOnTabClosing) then FOnTabClosing(Self, ATabIndex, ATabPage, AReason, ACancel);
end;

procedure TCustomThemedTabControl.DoTabClosed(const ATabIndex: Integer; const ATabPage: TTabSheet; const AReason: TThemedTabCloseReason);
begin
  if Assigned(FOnTabClosed) then FOnTabClosed(Self, ATabIndex, ATabPage, AReason);
end;

procedure TCustomThemedTabControl.DoTabReordered(const ATabPage: TTabSheet; const AOldIndex, ANewIndex: Integer);
begin
  if Assigned(FOnTabReordered) then FOnTabReordered(Self, ATabPage, AOldIndex, ANewIndex);
end;

procedure TCustomThemedTabControl.DoTabRightClicked(const ATabIndex: Integer; const ATabPage: TTabSheet; const ALocation: TPoint);
begin
  if Assigned(FOnTabRightClicked) then FOnTabRightClicked(Self, ATabIndex, ATabPage, ALocation);
end;

procedure TCustomThemedTabControl.DoTabContextMenuOpening(const ATabIndex: Integer; const ATabPage: TTabSheet; const ALocation: TPoint; var APopupMenu: TPopupMenu; var ACancel: Boolean);
begin
  if Assigned(FOnTabContextMenuOpening) then FOnTabContextMenuOpening(Self, ATabIndex, ATabPage, ALocation, APopupMenu, ACancel);
end;

function TCustomThemedTabControl.CloseTabCore(const AIndex: Integer; const AReason: TThemedTabCloseReason): Boolean;
var
  LPage: TTabSheet;
  LState: TThemedTabPageState;
  LCancel: Boolean;
begin
  Result := False;
  if (AIndex < 0) or (AIndex >= PageCount) then Exit;
  LPage := Pages[AIndex];
  LState := GetState(LPage);
  if not LState.Closable or LState.Pinned then Exit;
  LCancel := False;
  DoTabClosing(AIndex, LPage, AReason, LCancel);
  if LCancel or (csDestroying in ComponentState) then Exit;
  if (LPage.PageControl <> Self) or (LPage.PageIndex <> AIndex) then Exit;
  LPage.PageControl := nil;
  FStates.Remove(LPage);
  DoTabClosed(AIndex, LPage, AReason);
  InvalidateTabLayout;
  Result := True;
end;

function TCustomThemedTabControl.CanReorderTab(const AOldIndex, ANewIndex: Integer): Boolean;
begin
  Result := True;
end;

procedure TCustomThemedTabControl.ReorderTabCore(const AOldIndex, ANewIndex: Integer);
var
  LPage: TTabSheet;
  LTargetIndex, LNewIndex: Integer;
begin
  if (AOldIndex < 0) or (AOldIndex >= PageCount) or (ANewIndex < 0) or (ANewIndex >= PageCount) or (AOldIndex = ANewIndex) then Exit;
  if not CanReorderTab(AOldIndex, ANewIndex) then Exit;
  LPage := Pages[AOldIndex];
  if LPage = nil then Exit;
  LTargetIndex := EnsureRange(ANewIndex, 0, PageCount - 1);
  LPage.PageIndex := LTargetIndex;
  LNewIndex := LPage.PageIndex;
  TPageControl(Self).ActivePage := LPage;
  FDragSourceIndex := LNewIndex;
  InvalidateTabLayout;
  DoTabReordered(LPage, AOldIndex, LNewIndex);
end;

procedure TCustomThemedTabControl.ScrollHeaderToPreviousTab;
var
  LIndex: Integer;
begin
  LIndex := FindPreviousVisiblePageIndex(FFirstVisibleTabIndex);
  if LIndex < 0 then Exit;
  FFirstVisibleTabIndex := LIndex;
  InvalidateTabLayout;
end;

procedure TCustomThemedTabControl.ScrollHeaderToNextTab;
var
  LIndex: Integer;
begin
  LIndex := FindNextVisiblePageIndex(FFirstVisibleTabIndex);
  if LIndex < 0 then Exit;
  FFirstVisibleTabIndex := LIndex;
  InvalidateTabLayout;
end;

procedure TCustomThemedTabControl.ScrollHeaderToTab(const ATabIndex: Integer);
begin
  if (ATabIndex < 0) or (ATabIndex >= PageCount) or not Pages[ATabIndex].TabVisible then Exit;
  FFirstVisibleTabIndex := ATabIndex;
  InvalidateTabLayout;
end;

function TCustomThemedTabControl.CanScrollHeaderToPreviousTab: Boolean;
begin
  Result := FindPreviousVisiblePageIndex(FFirstVisibleTabIndex) >= 0;
end;

function TCustomThemedTabControl.CanScrollHeaderToNextTab: Boolean;
var
  I, LLastVisibleDrawn: Integer;
begin
  EnsureTabRects;
  LLastVisibleDrawn := -1;
  for I := 0 to High(FTabRects) do if not FTabRects[I].IsEmpty then LLastVisibleDrawn := I;
  Result := (LLastVisibleDrawn >= 0) and (FindNextVisiblePageIndex(LLastVisibleDrawn) >= 0);
end;

procedure TCustomThemedTabControl.StopOverflowRepeat;
begin
  if FOverflowRepeatTimer <> nil then FOverflowRepeatTimer.Enabled := False;
  FOverflowRepeatActive := False;
end;

procedure TCustomThemedTabControl.StepOverflow(const AButton: Integer);
begin
  case AButton of
    0: if CanScrollHeaderToPreviousTab then ScrollHeaderToPreviousTab;
    1: if CanScrollHeaderToNextTab then ScrollHeaderToNextTab;
  end;
end;

procedure TCustomThemedTabControl.OverflowRepeatTick(Sender: TObject);
var
  LPoint: TPoint;
begin
  if (csDestroying in ComponentState) or not Enabled or not MouseCapture or
     (FOverflowPressed < 0) or (FOverflowPressed > 1) or
     (GetAsyncKeyState(VK_LBUTTON) >= 0) then
  begin
    StopOverflowRepeat;
    Exit;
  end;
  LPoint := ScreenToClient(Mouse.CursorPos);
  if HitTestOverflowButton(LPoint) <> FOverflowPressed then
  begin
    StopOverflowRepeat;
    Exit;
  end;
  if not FOverflowRepeatActive then
  begin
    FOverflowRepeatActive := True;
    FOverflowRepeatTimer.Interval := 65;
  end;
  StepOverflow(FOverflowPressed);
  if ((FOverflowPressed = 0) and not CanScrollHeaderToPreviousTab) or
     ((FOverflowPressed = 1) and not CanScrollHeaderToNextTab) then
    StopOverflowRepeat;
end;

procedure TCustomThemedTabControl.SetOverflowMode(const AValue: TThemedTabOverflowMode);
begin
  if FOverflowMode = AValue then Exit;
  StopOverflowRepeat;
  FOverflowMode := AValue;
  FOverflowHover := -1;
  FOverflowPressed := -1;
  InvalidateTabLayout;
end;

function TCustomThemedTabControl.OverflowButtonRect(const AButton: Integer): TRect;
var
  LSize, LStart, LIndex: Integer;
begin
  Result := TRect.Empty;
  if not FOverflowVisible then Exit;
  LSize := NimbusScaleValue(24, CurrentPPI);
  LStart := ClientWidth - GetReservedHeaderRightWidth;
  LIndex := -1;
  if FOverflowMode in [tomScrollButtons, tomScrollAndMenu] then
  begin
    if AButton = 0 then LIndex := 0;
    if AButton = 1 then LIndex := 1;
  end;
  if (AButton = 2) and (FOverflowMode in [tomDropDownMenu, tomScrollAndMenu]) then
  begin
    if FOverflowMode = tomScrollAndMenu then LIndex := 2 else LIndex := 0;
  end;
  if LIndex >= 0 then Result := Rect(LStart + LIndex * LSize, 0, LStart + (LIndex + 1) * LSize, GetEffectiveHeaderHeight);
end;

function TCustomThemedTabControl.HitTestOverflowButton(const APoint: TPoint): Integer;
var
  I: Integer;
begin
  Result := -1;
  if not Enabled then Exit;
  for I := 0 to 2 do
    if OverflowButtonRect(I).Contains(APoint) then Exit(I);
end;

procedure TCustomThemedTabControl.DrawOverflowButtons;
var
  I, LX, LY, LStep: Integer;
  LRect: TRect;
  LFore, LBack, LBorder: TThemeColor;
  LEnabled: Boolean;
begin
  if not FOverflowVisible or (FRenderCanvas = nil) then Exit;
  LStep := Max(2, NimbusScaleValue(4, CurrentPPI));
  for I := 0 to 2 do
  begin
    LRect := OverflowButtonRect(I);
    if LRect.IsEmpty then Continue;
    LEnabled := (I = 2) or ((I = 0) and CanScrollHeaderToPreviousTab) or ((I = 1) and CanScrollHeaderToNextTab);
    if FPalette <> nil then
    begin
      LFore := FPalette.TabForeColor;
      LBack := FPalette.HoverBackColor;
      LBorder := FPalette.ControlBorderColor;
      if not LEnabled then LFore := FPalette.MutedForeColor;
    end
    else
    begin
      LFore := ColorToThemeColor(clWindowText);
      LBack := ColorToThemeColor(clBtnHighlight);
      LBorder := ColorToThemeColor(clBtnShadow);
      if not LEnabled then LFore := ColorToThemeColor(clGrayText);
    end;
    if LEnabled and ((I = FOverflowHover) or (I = FOverflowPressed)) then
    begin
      FRenderCanvas.FillRoundedRectangle(LBack, Rect(LRect.Left + 2, LRect.Top + 3, LRect.Right - 2, LRect.Bottom - 3), NimbusScaleValue(4, CurrentPPI));
      FRenderCanvas.DrawRoundedRectangle(LBorder, Rect(LRect.Left + 2, LRect.Top + 3, LRect.Right - 2, LRect.Bottom - 3), NimbusScaleValue(4, CurrentPPI), 0.75);
      if I = FOverflowPressed then
        FRenderCanvas.DrawRoundedRectangle(LFore, Rect(LRect.Left + 3, LRect.Top + 4, LRect.Right - 3, LRect.Bottom - 4), NimbusScaleValue(3, CurrentPPI), 0.5);
    end;
    LX := (LRect.Left + LRect.Right) div 2;
    LY := (LRect.Top + LRect.Bottom) div 2;
    if I = 0 then
    begin
      FRenderCanvas.DrawLine(LFore, LX + LStep div 2, LY - LStep, LX - LStep div 2, LY);
      FRenderCanvas.DrawLine(LFore, LX - LStep div 2, LY, LX + LStep div 2, LY + LStep);
    end
    else if I = 1 then
    begin
      FRenderCanvas.DrawLine(LFore, LX - LStep div 2, LY - LStep, LX + LStep div 2, LY);
      FRenderCanvas.DrawLine(LFore, LX + LStep div 2, LY, LX - LStep div 2, LY + LStep);
    end
    else
    begin
      FRenderCanvas.DrawLine(LFore, LX - LStep, LY - LStep div 2, LX, LY + LStep div 2);
      FRenderCanvas.DrawLine(LFore, LX, LY + LStep div 2, LX + LStep, LY - LStep div 2);
    end;
  end;
end;

procedure TCustomThemedTabControl.TabListItemClick(Sender: TObject);
begin
  if Sender is TMenuItem then SelectPageIndex(TMenuItem(Sender).Tag);
end;

procedure TCustomThemedTabControl.ShowTabList;
var
  LMenu: TThemedPopupMenu;
  LItem: TMenuItem;
  I: Integer;
  LPos: TPoint;
  LRect: TRect;
begin
  LMenu := FTabListMenu;
  if LMenu = nil then Exit;
  LMenu.Items.Clear;
  LMenu.ApplyTheme(FPalette);
  LMenu.AutoHotkeys := maManual;
  for I := 0 to PageCount - 1 do
      if Pages[I].TabVisible then
      begin
        LItem := TMenuItem.Create(LMenu);
        LItem.Caption := StringReplace(Pages[I].Caption, '&', '&&', [rfReplaceAll]);
        LItem.Tag := I;
        LItem.Checked := ActivePage = Pages[I];
        LItem.Enabled := Pages[I].Enabled;
        LItem.OnClick := TabListItemClick;
        LMenu.Items.Add(LItem);
      end;
    LRect := OverflowButtonRect(2);
    LPos := ClientToScreen(Point(LRect.Left, LRect.Bottom));
    LMenu.Popup(LPos.X, LPos.Y);
end;

procedure TCustomThemedTabControl.EnsureActiveTabVisible;
var
  LIndex: Integer;
begin
  if FMultiLineTabs or not FAutoScrollActiveTab or (ActivePage = nil) or not FOverflowVisible then Exit;
  LIndex := ActivePage.PageIndex;
  if LIndex < 0 then Exit;
  EnsureTabRects;
  if (LIndex < Length(FTabRects)) and not FTabRects[LIndex].IsEmpty then Exit;
  FFirstVisibleTabIndex := LIndex;
  InvalidateTabLayout;
end;

procedure TCustomThemedTabControl.RenderControl(const ADC: HDC);
var
  I, LHeaderHeight, LItemCount: Integer;
  LContext: TThemedTabRenderContext;
  LItem: TThemedTabRenderItem;
  LState: TThemedTabPageState;
  LTabRect: TRect;
begin
  if (ADC = 0) or not HandleAllocated or (FRenderer = nil) or (FRenderCanvas = nil) then Exit;
  SyncImageList;
  Canvas.Lock;
  try
    Canvas.Handle := ADC;
    try
      FRenderCanvas.BeginRender(Canvas);
      try
        if not FLayoutValid then RebuildTabRects(FRenderCanvas);
        if Length(FRenderItems) <> PageCount then SetLength(FRenderItems, PageCount);
        LItemCount := 0;
        for I := 0 to PageCount - 1 do
        begin
          LTabRect := FTabRects[I];
          if LTabRect.IsEmpty then Continue;
          LState := GetState(Pages[I]);
          LItem := Default(TThemedTabRenderItem);
          LItem.Index := I;
          LItem.TabRect := LTabRect;
          LItem.Selected := ActivePage = Pages[I];
          LItem.Hovered := FHoveredIndex = I;
          LItem.Pinned := LState.Pinned;
          LItem.ReserveCloseButtonSpace := ShouldReserveCloseButtonSpace(I);
          if LItem.ReserveCloseButtonSpace then LItem.CloseRect := GetCloseButtonRect(LTabRect);
          LItem.ShowCloseButton := ShouldShowCloseButton(I);
          LItem.CloseHovered := FHoveredCloseIndex = I;
          LItem.ClosePressed := FPressedCloseIndex = I;
          LItem.Text := GetEffectiveTabText(Pages[I], I);
          LItem.BadgeText := LState.BadgeText;
          LItem.ImageIcon := GetImageIcon(Pages[I]);
          LItem.TextFlags := GetTabTextFlags(Pages[I], I);
          FRenderItems[LItemCount] := LItem;
          Inc(LItemCount);
        end;
        for I := LItemCount to High(FRenderItems) do FRenderItems[I] := Default(TThemedTabRenderItem);
        LHeaderHeight := GetEffectiveHeaderHeight;
        LContext.Bounds := ClientRect;
        LContext.PageBounds := Rect(0, LHeaderHeight, ClientWidth, ClientHeight);
        LContext.BorderBounds := Rect(0, LHeaderHeight, Max(0, ClientWidth - 1), Max(LHeaderHeight, ClientHeight - 1));
        LContext.Font := Font;
        LContext.Items := FRenderItems;
        LContext.HeaderBottom := LHeaderHeight;
        LContext.BorderThickness := FBorderThickness;
        LContext.TextPaddingLeft := FTextPaddingLeft;
        LContext.TextPaddingTop := FTextPaddingTop;
        LContext.TextPaddingHorizontal := FTextPaddingHorizontal;
        LContext.TextPaddingVertical := FTextPaddingVertical;
        LContext.CloseButtonAreaWidth := FCloseButtonAreaWidth;
        LContext.IconSize := FIconSize;
        LContext.BadgeHorizontalPadding := FBadgeHorizontalPadding;
        LContext.BadgeHeight := FBadgeHeight;
        LContext.ActiveIndicatorHeight := FActiveIndicatorHeight;
        LContext.ImageSpacing := NimbusScaleValue(5, CurrentPPI);
        LContext.ShowActiveIndicator := FShowActiveIndicator;
        LContext.DpiScale := CurrentPPI / 96.0;
        if FPalette <> nil then
        begin
          LContext.PanelBackColor := FPalette.PanelBackColor;
          LContext.TabBackColor := FPalette.TabBackColor;
          LContext.TabForeColor := FPalette.TabForeColor;
          LContext.ActiveTabBackColor := FPalette.ActiveTabBackColor;
          LContext.ActiveTabForeColor := FPalette.ActiveTabForeColor;
          LContext.BorderColor := FPalette.ControlBorderColor;
          LContext.HoverBackColor := FPalette.HoverBackColor;
          LContext.PressedBackColor := FPalette.PressedBackColor;
          LContext.AccentColor := FPalette.AccentColor;
          LContext.MutedForeColor := FPalette.MutedForeColor;
        end
        else
        begin
          LContext.PanelBackColor := ColorToThemeColor(Color);
          LContext.TabBackColor := ColorToThemeColor(clBtnFace);
          LContext.TabForeColor := ColorToThemeColor(Font.Color);
          LContext.ActiveTabBackColor := ColorToThemeColor(clWindow);
          LContext.ActiveTabForeColor := ColorToThemeColor(Font.Color);
          LContext.BorderColor := ColorToThemeColor(clBtnShadow);
          LContext.HoverBackColor := ColorToThemeColor(clBtnHighlight);
          LContext.PressedBackColor := ColorToThemeColor(clBtnShadow);
          LContext.AccentColor := ColorToThemeColor(clHighlight);
          LContext.MutedForeColor := ColorToThemeColor(clGrayText);
        end;
        FRenderer.Render(FRenderCanvas, LContext);
        DrawOverflowButtons;
      finally
        FRenderCanvas.EndRender;
      end;
    finally
      Canvas.Handle := 0;
    end;
  finally
    Canvas.Unlock;
  end;
end;

procedure TCustomThemedTabControl.RenderControlBuffered(const ADC: HDC; const AUpdateRect: TRect);
var
  LMemoryDC: HDC;
  LBitmap, LOldBitmap: HGDIOBJ;
  LWidth, LHeight: Integer;
begin
  if (ADC = 0) or (ClientWidth <= 0) or (ClientHeight <= 0) then Exit;
  LWidth := ClientWidth;
  LHeight := ClientHeight;
  LMemoryDC := CreateCompatibleDC(ADC);
  if LMemoryDC = 0 then
  begin
    RenderControl(ADC);
    Exit;
  end;
  try
    LBitmap := CreateCompatibleBitmap(ADC, LWidth, LHeight);
    if LBitmap = 0 then
    begin
      RenderControl(ADC);
      Exit;
    end;
    try
      LOldBitmap := SelectObject(LMemoryDC, LBitmap);
      try
        RenderControl(LMemoryDC);
        if (AUpdateRect.Right > AUpdateRect.Left) and (AUpdateRect.Bottom > AUpdateRect.Top) then
          BitBlt(ADC, AUpdateRect.Left, AUpdateRect.Top, AUpdateRect.Right - AUpdateRect.Left, AUpdateRect.Bottom - AUpdateRect.Top, LMemoryDC, AUpdateRect.Left, AUpdateRect.Top, SRCCOPY);
      finally
        SelectObject(LMemoryDC, LOldBitmap);
      end;
    finally
      DeleteObject(LBitmap);
    end;
  finally
    DeleteDC(LMemoryDC);
  end;
end;

procedure TCustomThemedTabControl.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  FHoveredIndex := -1;
  FHoveredCloseIndex := -1;
  FOverflowHover := -1;
  if not MouseCapture then FPressedCloseIndex := -1;
  InvalidateHeader;
end;

procedure TCustomThemedTabControl.Change;
begin
  inherited Change;
  EnsureActiveTabVisible;
end;

procedure TCustomThemedTabControl.CMShowingChanged(var Message: TMessage);
begin
  inherited;
  if Showing then RegisterThemeAware;
end;

procedure TCustomThemedTabControl.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  if not Enabled then
  begin
    FHoveredIndex := -1;
    FHoveredCloseIndex := -1;
    FPressedCloseIndex := -1;
    FDragSourceIndex := -1;
    FDragging := False;
    if MouseCapture then MouseCapture := False;
  end;
  Invalidate;
end;

procedure TCustomThemedTabControl.CMFontChanged(var Message: TMessage);
begin
  inherited;
  ApplyDpiScaling;
end;

procedure TCustomThemedTabControl.CMControlChange(var Message: TCMControlChange);
var
  LPage: TTabSheet;
begin
  inherited;
  if not (Message.Control is TTabSheet) then Exit;
  LPage := TTabSheet(Message.Control);
  if Message.Inserting then
  begin
    GetState(LPage);
    ApplyThemeToPage(LPage);
  end
  else
    FStates.Remove(LPage);
  if FFirstVisibleTabIndex < 0 then FFirstVisibleTabIndex := 0;
  if FFirstVisibleTabIndex >= PageCount then FFirstVisibleTabIndex := Max(0, PageCount - 1);
  HideNativeTabScroller;
  UpdateHeaderInputBounds;
  if FHeaderInput <> nil then FHeaderInput.BringToFront;
  InvalidateTabLayout;
end;

procedure TCustomThemedTabControl.CMDialogKey(var Message: TCMDialogKey);
var
  LIndex: Integer;
begin
  if (Focused or IsChild(Handle, GetFocus)) and (Message.CharCode = VK_TAB) and (GetKeyState(VK_CONTROL) < 0) then
  begin
    if ActivePage <> nil then LIndex := ActivePage.PageIndex else LIndex := -1;
    if GetKeyState(VK_SHIFT) >= 0 then LIndex := FindNextVisiblePageIndex(LIndex) else LIndex := FindPreviousVisiblePageIndex(LIndex);
    if LIndex < 0 then
    begin
      if GetKeyState(VK_SHIFT) >= 0 then LIndex := FindNextVisiblePageIndex(-1) else LIndex := FindPreviousVisiblePageIndex(PageCount);
    end;
    if LIndex >= 0 then SelectPageIndex(LIndex);
    Message.Result := 1;
    Exit;
  end;
  inherited;
end;

procedure TCustomThemedTabControl.WMPaint(var Message: TWMPaint);
var
  LPaintStruct: TPaintStruct;
  LDC: HDC;
begin
  if csDestroying in ComponentState then
  begin
    Message.Result := 0;
    Exit;
  end;
  if Message.DC <> 0 then
  begin
    RenderControlBuffered(Message.DC, ClientRect);
    Message.Result := 0;
    Exit;
  end;
  LDC := BeginPaint(Handle, LPaintStruct);
  try
    if LDC <> 0 then RenderControlBuffered(LDC, LPaintStruct.rcPaint);
  finally
    EndPaint(Handle, LPaintStruct);
  end;
  Message.Result := 0;
end;

procedure TCustomThemedTabControl.WMPrintClient(var Message: TMessage);
begin
  if not (csDestroying in ComponentState) and (Message.WParam <> 0) then RenderControl(HDC(Message.WParam));
  Message.Result := 0;
end;

procedure TCustomThemedTabControl.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TCustomThemedTabControl.WMMouseLeave(var Message: TMessage);
begin
  Message.Result := 0;
end;

procedure TCustomThemedTabControl.WMMouseMove(var Message: TWMMouseMove);
var
  LPoint: TPoint;
  LNewHoveredIndex, LNewHoveredCloseIndex, LTargetIndex: Integer;
  LDragRect: TRect;
  LDraggingNow: Boolean;
  LOverflowHit: Integer;
begin
  LPoint := Point(Message.XPos, Message.YPos);
  LOverflowHit := HitTestOverflowButton(LPoint);
  if (FOverflowPressed >= 0) and (LOverflowHit <> FOverflowPressed) then StopOverflowRepeat;
  if FOverflowHover <> LOverflowHit then
  begin
    FOverflowHover := LOverflowHit;
    InvalidateHeader;
  end;
  if IsPointInHeader(LPoint) or MouseCapture or (FDragSourceIndex >= 0) or (FPressedCloseIndex >= 0) then
  begin
    LNewHoveredIndex := HitTestTab(LPoint);
    LNewHoveredCloseIndex := HitTestCloseButton(LPoint);
  end
  else
  begin
    LNewHoveredIndex := -1;
    LNewHoveredCloseIndex := -1;
  end;
  if (Message.Keys and MK_LBUTTON) = 0 then
  begin
    FDragSourceIndex := -1;
    FDragging := False;
  end;
  if FAllowTabReorder and ((Message.Keys and MK_LBUTTON) <> 0) and (FDragSourceIndex >= 0) and not FDragging then
  begin
    LDragRect := Rect(FDragStartPoint.X - GetSystemMetrics(SM_CXDRAG) div 2, FDragStartPoint.Y - GetSystemMetrics(SM_CYDRAG) div 2, FDragStartPoint.X + GetSystemMetrics(SM_CXDRAG) div 2 + 1, FDragStartPoint.Y + GetSystemMetrics(SM_CYDRAG) div 2 + 1);
    if not LDragRect.Contains(LPoint) then FDragging := True;
  end;
  LDraggingNow := FAllowTabReorder and ((Message.Keys and MK_LBUTTON) <> 0) and FDragging and (FDragSourceIndex >= 0);
  if LDraggingNow then
  begin
    LTargetIndex := HitTestTab(LPoint);
    if (LTargetIndex >= 0) and (LTargetIndex <> FDragSourceIndex) then ReorderTabCore(FDragSourceIndex, LTargetIndex);
  end;
  if (FHoveredIndex <> LNewHoveredIndex) or (FHoveredCloseIndex <> LNewHoveredCloseIndex) then
  begin
    FHoveredIndex := LNewHoveredIndex;
    FHoveredCloseIndex := LNewHoveredCloseIndex;
    InvalidateHeader;
  end;
  MouseMove(KeysToShiftState(Message.Keys), LPoint.X, LPoint.Y);
  Message.Result := 0;
end;

procedure TCustomThemedTabControl.WMMouseWheel(var Message: TWMMouseWheel);
begin
  if FOverflowVisible and FScrollTabsWithMouseWheel and (GetKeyState(VK_CONTROL) >= 0) then
  begin
    if Message.WheelDelta > 0 then ScrollHeaderToPreviousTab
    else ScrollHeaderToNextTab;
    Message.Result := 1;
    Exit;
  end;
  TCMMouseWheel(Message).ShiftState := KeysToShiftState(Message.Keys);
  MouseWheelHandler(TMessage(Message));
end;

procedure TCustomThemedTabControl.WMLButtonDown(var Message: TWMLButtonDown);
var
  LPoint: TPoint;
  LTabIndex, LCloseIndex: Integer;
begin
  LPoint := Point(Message.XPos, Message.YPos);
  if not IsPointInHeader(LPoint) then
  begin
    SendCancelMode(Self);
    MouseDown(mbLeft, KeysToShiftState(Message.Keys), LPoint.X, LPoint.Y);
    Message.Result := 0;
    Exit;
  end;
  if HitTestOverflowButton(LPoint) >= 0 then
  begin
    FOverflowPressed := HitTestOverflowButton(LPoint);
    if (FOverflowPressed = 0) and not CanScrollHeaderToPreviousTab then FOverflowPressed := -1;
    if (FOverflowPressed = 1) and not CanScrollHeaderToNextTab then FOverflowPressed := -1;
    if FOverflowPressed >= 0 then
    begin
      AcquireMouseFocus;
      MouseCapture := True;
      if FOverflowPressed < 2 then
      begin
        StepOverflow(FOverflowPressed);
        FOverflowRepeatActive := False;
        FOverflowRepeatTimer.Interval := 340;
        FOverflowRepeatTimer.Enabled := True;
      end;
    end;
    InvalidateHeader;
    Message.Result := 0;
    Exit;
  end;
  SendCancelMode(Self);
  AcquireMouseFocus;
  LTabIndex := HitTestTab(LPoint);
  LCloseIndex := HitTestCloseButton(LPoint);
  if LCloseIndex >= 0 then
  begin
    FPressedCloseIndex := LCloseIndex;
    FDragSourceIndex := -1;
    FDragging := False;
    MouseCapture := True;
    InvalidateHeader;
  end
  else if LTabIndex >= 0 then
  begin
    SelectPageIndex(LTabIndex);
    if FAllowTabReorder then
    begin
      FDragSourceIndex := LTabIndex;
      FDragStartPoint := LPoint;
      FDragging := False;
      MouseCapture := True;
    end;
    InvalidateHeader;
  end;
  MouseDown(mbLeft, KeysToShiftState(Message.Keys), LPoint.X, LPoint.Y);
  Message.Result := 0;
end;

procedure TCustomThemedTabControl.WMLButtonUp(var Message: TWMLButtonUp);
var
  LPoint: TPoint;
  LPressedCloseIndex, LCloseIndex: Integer;
  LHandled: Boolean;
begin
  LPoint := Point(Message.XPos, Message.YPos);
  LHandled := MouseCapture or (FPressedCloseIndex >= 0) or (FDragSourceIndex >= 0) or FDragging or IsPointInHeader(LPoint);
  if not LHandled then
  begin
    MouseUp(mbLeft, KeysToShiftState(Message.Keys), LPoint.X, LPoint.Y);
    Message.Result := 0;
    Exit;
  end;
  if FOverflowPressed >= 0 then
  begin
    LPressedCloseIndex := FOverflowPressed;
    StopOverflowRepeat;
    FOverflowPressed := -1;
    if MouseCapture then MouseCapture := False;
    if (LPressedCloseIndex = 2) and (LPressedCloseIndex = HitTestOverflowButton(LPoint)) then ShowTabList;
    InvalidateHeader;
    Message.Result := 0;
    Exit;
  end;
  LPressedCloseIndex := FPressedCloseIndex;
  LCloseIndex := HitTestCloseButton(LPoint);
  FPressedCloseIndex := -1;
  FDragSourceIndex := -1;
  FDragging := False;
  if MouseCapture then MouseCapture := False;
  InvalidateHeader;
  if LPressedCloseIndex >= 0 then
  begin
    if LPressedCloseIndex = LCloseIndex then CloseTabCore(LPressedCloseIndex, tcrCloseButton);
    Message.Result := 0;
    Exit;
  end;
  MouseUp(mbLeft, KeysToShiftState(Message.Keys), LPoint.X, LPoint.Y);
  Message.Result := 0;
end;

procedure TCustomThemedTabControl.WMLButtonDblClk(var Message: TWMLButtonDblClk);
var
  LPoint: TPoint;
  LTabIndex: Integer;
begin
  LPoint := Point(Message.XPos, Message.YPos);
  if not IsPointInHeader(LPoint) then
  begin
    SendCancelMode(Self);
    DblClick;
    MouseDown(mbLeft, KeysToShiftState(Message.Keys) + [ssDouble], LPoint.X, LPoint.Y);
    Message.Result := 0;
    Exit;
  end;
  SendCancelMode(Self);
  AcquireMouseFocus;
  LTabIndex := HitTestTab(LPoint);
  if LTabIndex >= 0 then SelectPageIndex(LTabIndex);
  DblClick;
  MouseDown(mbLeft, KeysToShiftState(Message.Keys) + [ssDouble], LPoint.X, LPoint.Y);
  Message.Result := 0;
end;

procedure TCustomThemedTabControl.WMMButtonDown(var Message: TWMMButtonDown);
var
  LPoint: TPoint;
  LTabIndex: Integer;
begin
  LPoint := Point(Message.XPos, Message.YPos);
  if not IsPointInHeader(LPoint) then
  begin
    MouseDown(mbMiddle, KeysToShiftState(Message.Keys), LPoint.X, LPoint.Y);
    Message.Result := 0;
    Exit;
  end;
  AcquireMouseFocus;
  LTabIndex := HitTestTab(LPoint);
  if FCloseOnMiddleClick and (LTabIndex >= 0) then
  begin
    CloseTabCore(LTabIndex, tcrMiddleClick);
    Message.Result := 0;
    Exit;
  end;
  MouseDown(mbMiddle, KeysToShiftState(Message.Keys), LPoint.X, LPoint.Y);
  Message.Result := 0;
end;

procedure TCustomThemedTabControl.WMMButtonUp(var Message: TWMMButtonUp);
var
  LPoint: TPoint;
begin
  LPoint := Point(Message.XPos, Message.YPos);
  if not IsPointInHeader(LPoint) then
  begin
    MouseUp(mbMiddle, KeysToShiftState(Message.Keys), LPoint.X, LPoint.Y);
    Message.Result := 0;
    Exit;
  end;
  MouseUp(mbMiddle, KeysToShiftState(Message.Keys), LPoint.X, LPoint.Y);
  Message.Result := 0;
end;

procedure TCustomThemedTabControl.WMMButtonDblClk(var Message: TWMMButtonDblClk);
begin
  MouseDown(mbMiddle, KeysToShiftState(Message.Keys) + [ssDouble], Message.XPos, Message.YPos);
  Message.Result := 0;
end;

procedure TCustomThemedTabControl.WMRButtonDown(var Message: TWMRButtonDown);
var
  LTabIndex: Integer;
  LPoint, LScreenPoint: TPoint;
  LMenu: TPopupMenu;
  LCancel: Boolean;
begin
  LPoint := Point(Message.XPos, Message.YPos);
  if not IsPointInHeader(LPoint) then
  begin
    MouseDown(mbRight, KeysToShiftState(Message.Keys), LPoint.X, LPoint.Y);
    Message.Result := 0;
    Exit;
  end;
  LTabIndex := HitTestTab(LPoint);
  if LTabIndex >= 0 then
  begin
    AcquireMouseFocus;
    SelectPageIndex(LTabIndex);
    DoTabRightClicked(LTabIndex, Pages[LTabIndex], LPoint);
    LMenu := FTabContextMenu;
    LCancel := False;
    DoTabContextMenuOpening(LTabIndex, Pages[LTabIndex], LPoint, LMenu, LCancel);
    if not LCancel and (LMenu <> nil) then
    begin
      LScreenPoint := ClientToScreen(LPoint);
      LMenu.Popup(LScreenPoint.X, LScreenPoint.Y);
    end;
    Message.Result := 0;
    Exit;
  end;
  MouseDown(mbRight, KeysToShiftState(Message.Keys), LPoint.X, LPoint.Y);
  Message.Result := 0;
end;

procedure TCustomThemedTabControl.WMRButtonUp(var Message: TWMRButtonUp);
var
  LPoint: TPoint;
begin
  LPoint := Point(Message.XPos, Message.YPos);
  if not IsPointInHeader(LPoint) then
  begin
    MouseUp(mbRight, KeysToShiftState(Message.Keys), LPoint.X, LPoint.Y);
    Message.Result := 0;
    Exit;
  end;
  MouseUp(mbRight, KeysToShiftState(Message.Keys), LPoint.X, LPoint.Y);
  Message.Result := 0;
end;

procedure TCustomThemedTabControl.WMRButtonDblClk(var Message: TWMRButtonDblClk);
begin
  MouseDown(mbRight, KeysToShiftState(Message.Keys) + [ssDouble], Message.XPos, Message.YPos);
  Message.Result := 0;
end;

procedure TCustomThemedTabControl.WMCaptureChanged(var Message: TMessage);
begin
  StopOverflowRepeat;
  if HWND(Message.LParam) = Handle then
  begin
    Message.Result := 0;
    Exit;
  end;
  if (FPressedCloseIndex <> -1) or (FOverflowPressed <> -1) or (FDragSourceIndex <> -1) or FDragging then
  begin
    FOverflowPressed := -1;
    FPressedCloseIndex := -1;
    FDragSourceIndex := -1;
    FDragging := False;
    InvalidateHeader;
  end;
  Message.Result := 0;
end;

procedure TCustomThemedTabControl.WMCancelMode(var Message: TWMCancelMode);
begin
  StopOverflowRepeat;
  FPressedCloseIndex := -1;
  FOverflowPressed := -1;
  FDragSourceIndex := -1;
  FDragging := False;
  if MouseCapture then MouseCapture := False;
  InvalidateHeader;
  Message.Result := 0;
end;

procedure TCustomThemedTabControl.WMKeyDown(var Message: TWMKeyDown);
var
  LIndex: Integer;
begin
  if Focused and (Message.CharCode in [VK_LEFT, VK_RIGHT, VK_HOME, VK_END]) then
  begin
    if ActivePage <> nil then LIndex := ActivePage.PageIndex else LIndex := -1;
    case Message.CharCode of
      VK_LEFT: LIndex := FindPreviousVisiblePageIndex(LIndex);
      VK_RIGHT: LIndex := FindNextVisiblePageIndex(LIndex);
      VK_HOME: LIndex := FindNextVisiblePageIndex(-1);
      VK_END: LIndex := FindPreviousVisiblePageIndex(PageCount);
    end;
    if LIndex >= 0 then SelectPageIndex(LIndex);
    Message.Result := 0;
    Exit;
  end;
  inherited;
end;

procedure TCustomThemedTabControl.TCMSetItemSize(var Message: TMessage);
begin
  if not FApplyingNativeMetrics then Message.LParam := MakeLParam(1, GetEffectiveHeaderHeight);
  inherited;
end;

procedure TCustomThemedTabControl.TCMSetImageList(var Message: TMessage);
begin
  inherited;
  SyncImageList;
  if HandleAllocated and not FApplyingNativeMetrics then ApplyNativeTabMetrics;
  InvalidateTabLayout;
end;

end.

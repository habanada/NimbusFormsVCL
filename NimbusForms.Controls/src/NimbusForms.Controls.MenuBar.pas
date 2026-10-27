{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.MenuBar;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.Generics.Collections,
  System.Types,
  System.UITypes,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Menus,
  Vcl.ImgList,
  Vcl.Forms,
  NimbusForms.Theming.Palette,
  NimbusForms.Controls.Base,
  NimbusForms.Controls.Types,
  NimbusForms.Menus.PopupMenu,
  NimbusForms.Rendering.Canvas;

type
  TCustomThemedMenuBar = class;
  TThemedMenuBarItem = class;

  TThemedMenuBarItemKind = (tmbikMenuItem, tmbikButton, tmbikToggleButton, tmbikDropDown, tmbikLabel, tmbikSeparator, tmbikSpring, tmbikTextBox, tmbikSearchBox, tmbikComboBox);
  TThemedMenuBarItemAlignment = (tmbiaLeft, tmbiaCenter, tmbiaRight);
  TThemedMenuBarDisplayStyle = (tmbdsText, tmbdsImage, tmbdsImageAndText);
  TThemedMenuBarItemAppearance = (tmbiaStandard, tmbiaAccentPill);
  TThemedMenuBarItemEvent = procedure(Sender: TObject; AItem: TThemedMenuBarItem) of object;
  TThemedMenuBarTextChangedEvent = procedure(Sender: TObject; AItem: TThemedMenuBarItem; const AOldText, ANewText: string) of object;
  TThemedMenuBarSelectedIndexChangedEvent = procedure(Sender: TObject; AItem: TThemedMenuBarItem; const ASelectedIndex: Integer) of object;

  TThemedMenuBarItems = class(TOwnedCollection)
  private
    FAlignment: TThemedMenuBarItemAlignment;
    function GetItem(AIndex: Integer): TThemedMenuBarItem;
    function GetMenuBar: TCustomThemedMenuBar;
    procedure SetItem(AIndex: Integer; const AValue: TThemedMenuBarItem);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TCustomThemedMenuBar; const AAlignment: TThemedMenuBarItemAlignment);
    function Add: TThemedMenuBarItem;
    property Alignment: TThemedMenuBarItemAlignment read FAlignment;
    property Items[AIndex: Integer]: TThemedMenuBarItem read GetItem write SetItem; default;
    property MenuBar: TCustomThemedMenuBar read GetMenuBar;
  end;

  TThemedMenuBarItem = class(TCollectionItem)
  private
    FCaption: string;
    FKind: TThemedMenuBarItemKind;
    FEnabled: Boolean;
    FVisible: Boolean;
    FCheckable: Boolean;
    FChecked: Boolean;
    FWidth: Integer;
    FMinimumWidth: Integer;
    FMaximumWidth: Integer;
    FDropDownMenu: TThemedPopupMenu;
    FHint: string;
    FPlaceholderText: string;
    FReadOnly: Boolean;
    FDisplayStyle: TThemedMenuBarDisplayStyle;
    FAppearance: TThemedMenuBarItemAppearance;
    FIcon: TIcon;
    FImageListIcon: TIcon;
    FImageIndex: System.UITypes.TImageIndex;
    FComboItems: TStringList;
    FSelectedIndex: Integer;
    FHostedControl: TWinControl;
    FTag: NativeInt;
    FBounds: TRect;
    FOnClick: TNotifyEvent;
    FOnCheckedChanged: TNotifyEvent;
    FOnTextChanged: TNotifyEvent;
    FOnSelectedIndexChanged: TNotifyEvent;
    procedure SetCaption(const AValue: string);
    procedure SetKind(const AValue: TThemedMenuBarItemKind);
    procedure SetEnabled(const AValue: Boolean);
    procedure SetVisible(const AValue: Boolean);
    procedure SetCheckable(const AValue: Boolean);
    procedure SetChecked(const AValue: Boolean);
    procedure SetWidth(const AValue: Integer);
    procedure SetMinimumWidth(const AValue: Integer);
    procedure SetMaximumWidth(const AValue: Integer);
    procedure SetDropDownMenu(const AValue: TThemedPopupMenu);
    procedure SetHint(const AValue: string);
    procedure SetPlaceholderText(const AValue: string);
    procedure SetReadOnly(const AValue: Boolean);
    procedure SetDisplayStyle(const AValue: TThemedMenuBarDisplayStyle);
    procedure SetAppearance(const AValue: TThemedMenuBarItemAppearance);
    procedure SetIcon(const AValue: TIcon);
    procedure IconChanged(Sender: TObject);
    procedure SetImageIndex(const AValue: System.UITypes.TImageIndex);
    function GetComboItems: TStrings;
    procedure SetComboItems(const AValue: TStrings);
    procedure ComboItemsChanged(Sender: TObject);
    procedure SetSelectedIndex(const AValue: Integer);
    function GetMenuBar: TCustomThemedMenuBar;
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function HasDropDown: Boolean;
    function IsInteractive: Boolean;
    function IsInput: Boolean;
    function IsFocusable: Boolean;
    function CurrentIconHandle: HICON;
    procedure Click;
    property Bounds: TRect read FBounds;
    property MenuBar: TCustomThemedMenuBar read GetMenuBar;
  published
    property Caption: string read FCaption write SetCaption;
    property Kind: TThemedMenuBarItemKind read FKind write SetKind default tmbikMenuItem;
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property Visible: Boolean read FVisible write SetVisible default True;
    property Checkable: Boolean read FCheckable write SetCheckable default False;
    property Checked: Boolean read FChecked write SetChecked default False;
    property Width: Integer read FWidth write SetWidth default 0;
    property MinimumWidth: Integer read FMinimumWidth write SetMinimumWidth default 0;
    property MaximumWidth: Integer read FMaximumWidth write SetMaximumWidth default 0;
    property DropDownMenu: TThemedPopupMenu read FDropDownMenu write SetDropDownMenu;
    property Hint: string read FHint write SetHint;
    property PlaceholderText: string read FPlaceholderText write SetPlaceholderText;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default False;
    property DisplayStyle: TThemedMenuBarDisplayStyle read FDisplayStyle write SetDisplayStyle default tmbdsImageAndText;
    property Appearance: TThemedMenuBarItemAppearance read FAppearance write SetAppearance default tmbiaStandard;
    property Icon: TIcon read FIcon write SetIcon;
    property ImageIndex: System.UITypes.TImageIndex read FImageIndex write SetImageIndex default -1;
    property ComboItems: TStrings read GetComboItems write SetComboItems;
    property SelectedIndex: Integer read FSelectedIndex write SetSelectedIndex default -1;
    property Tag: NativeInt read FTag write FTag default 0;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnCheckedChanged: TNotifyEvent read FOnCheckedChanged write FOnCheckedChanged;
    property OnTextChanged: TNotifyEvent read FOnTextChanged write FOnTextChanged;
    property OnSelectedIndexChanged: TNotifyEvent read FOnSelectedIndexChanged write FOnSelectedIndexChanged;
  end;

  TCustomThemedMenuBar = class(TCustomNimbusControl)
  private
    FLeftItems: TThemedMenuBarItems;
    FCenterItems: TThemedMenuBarItems;
    FRightItems: TThemedMenuBarItems;
    FMeasureCanvas: INimbusRenderCanvas;
    FMeasureBitmap: Vcl.Graphics.TBitmap;
    FImages: TCustomImageList;
    FImageChangeLink: TChangeLink;
    FItemPadding: TPadding;
    FItemHeight: Integer;
    FDefaultItemWidth: Integer;
    FSeparatorWidth: Integer;
    FItemSpacing: Integer;
    FArrowWidth: Integer;
    FImageSize: Integer;
    FImageTextSpacing: Integer;
    FCornerRadius: Integer;
    FShowBottomBorder: Boolean;
    FWrapKeyboardNavigation: Boolean;
    FHotItem: TThemedMenuBarItem;
    FPressedItem: TThemedMenuBarItem;
    FFocusedItem: TThemedMenuBarItem;
    FOpenItem: TThemedMenuBarItem;
    FPendingOpenItem: TThemedMenuBarItem;
    FShowOverflow: Boolean;
    FOverflowButtonWidth: Integer;
    FOverflowItems: TList<TThemedMenuBarItem>;
    FOverflowMenu: TThemedPopupMenu;
    FOverflowSearchForm: Vcl.Forms.TForm;
    FOverflowSearchEditor: TWinControl;
    FOverflowSearchItem: TThemedMenuBarItem;
    FOverflowBounds: TRect;
    FOverflowHot: Boolean;
    FOverflowPressed: Boolean;
    FLayouting: Boolean;
    FSyncingHostedControl: Boolean;
    FInitialized: Boolean;
    FCompactOverrides: Byte;
    FOnItemClick: TThemedMenuBarItemEvent;
    FOnItemCheckedChanged: TThemedMenuBarItemEvent;
    FOnMenuOpening: TThemedMenuBarItemEvent;
    FOnMenuClosed: TThemedMenuBarItemEvent;
    FOnItemTextChanged: TThemedMenuBarTextChangedEvent;
    FOnItemSelectedIndexChanged: TThemedMenuBarSelectedIndexChangedEvent;
    FOnOverflowOpening: TNotifyEvent;
    FOnOverflowClosed: TNotifyEvent;
    procedure SetLeftItems(const AValue: TThemedMenuBarItems);
    procedure SetCenterItems(const AValue: TThemedMenuBarItems);
    procedure SetRightItems(const AValue: TThemedMenuBarItems);
    procedure SetImages(const AValue: TCustomImageList);
    procedure ImageListChanged(Sender: TObject);
    procedure SetItemPadding(const AValue: TPadding);
    procedure SetItemHeight(const AValue: Integer);
    procedure SetDefaultItemWidth(const AValue: Integer);
    procedure SetSeparatorWidth(const AValue: Integer);
    procedure SetItemSpacing(const AValue: Integer);
    procedure SetArrowWidth(const AValue: Integer);
    procedure SetImageSize(const AValue: Integer);
    procedure SetImageTextSpacing(const AValue: Integer);
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetShowBottomBorder(const AValue: Boolean);
    procedure SetWrapKeyboardNavigation(const AValue: Boolean);
    procedure SetShowOverflow(const AValue: Boolean);
    procedure SetOverflowButtonWidth(const AValue: Integer);
    procedure ItemPaddingChanged(Sender: TObject);
    procedure MenuItemsChanged;
    procedure ItemRemoving(const AItem: TThemedMenuBarItem);
    procedure ItemCheckedChanged(const AItem: TThemedMenuBarItem);
    procedure ItemTextChanged(const AItem: TThemedMenuBarItem; const AOldText, ANewText: string);
    procedure ItemSelectedIndexChanged(const AItem: TThemedMenuBarItem);
    function DropDownMenuReferenced(const AMenu: TThemedPopupMenu; const AExclude: TThemedMenuBarItem): Boolean;
    procedure DropDownMenuChanged(const AItem: TThemedMenuBarItem; const AOldMenu, ANewMenu: TThemedPopupMenu);
    procedure RefreshItemImage(const AItem: TThemedMenuBarItem);
    procedure RefreshAllImages;
    procedure SyncHostedControl(const AItem: TThemedMenuBarItem);
    procedure SyncHostedControls;
    procedure DestroyHostedControl(const AItem: TThemedMenuBarItem);
    procedure LayoutHostedControl(const AItem: TThemedMenuBarItem);
    function FindHostedItem(const AControl: TControl): TThemedMenuBarItem;
    procedure HostedTextBoxChange(Sender: TObject);
    procedure HostedComboBoxChange(Sender: TObject);
    procedure HostedControlEnter(Sender: TObject);
    procedure HostedControlExit(Sender: TObject);
    function GetItemWidth(const AItem: TThemedMenuBarItem): Integer;
    function GetCollectionWidth(const AItems: TThemedMenuBarItems; const ASpringWidth: Integer): Integer;
    function GetCollectionSpringCount(const AItems: TThemedMenuBarItems): Integer;
    function CollectionHasVisibleItems(const AItems: TThemedMenuBarItems): Boolean;
    procedure LayoutEdgeItems(const AItems: TThemedMenuBarItems; const AFromRight, AForwardOrder: Boolean; var AEdge: Integer; const AY, ASpringWidth: Integer);
    procedure LayoutCenterItems(const ALeftLimit, ARightLimit, AY, ASpringWidth: Integer);
    procedure LayoutItems;
    function IsOverflowed(const AItem: TThemedMenuBarItem): Boolean;
    function GetOverflowCount: Integer;
    procedure BuildOverflowMenu;
    procedure AddOverflowItem(const AItem: TThemedMenuBarItem);
    procedure CloneOverflowMenuItems(const ATarget, ASource: TMenuItem);
    procedure OverflowItemClick(Sender: TObject);
    procedure OverflowSearchClick(Sender: TObject);
    procedure OverflowSearchChanged(Sender: TObject);
    procedure OverflowSearchDeactivate(Sender: TObject);
    procedure OverflowSearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ShowOverflowSearch(const AItem: TThemedMenuBarItem);
    procedure OverflowComboItemClick(Sender: TObject);
    procedure OverflowSourceItemClick(Sender: TObject);
    function HitTestCollection(const AItems: TThemedMenuBarItems; const APoint: TPoint): TThemedMenuBarItem;
    function HitTest(const APoint: TPoint): TThemedMenuBarItem;
    function FindFocusableEdge(const ALeftmost: Boolean): TThemedMenuBarItem;
    function FindRelativeFocusable(const ACurrent: TThemedMenuBarItem; const ADirection: Integer): TThemedMenuBarItem;
    procedure SetFocusedItem(const AItem: TThemedMenuBarItem);
    procedure MoveFocus(const ADirection: Integer);
    procedure ExecuteItem(const AItem: TThemedMenuBarItem);
    procedure ShowItemMenu(const AItem: TThemedMenuBarItem);
    function HandleMenuKey(const AKey: Word): Boolean;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure CMDialogKey(var Message: TCMDialogKey); message CM_DIALOGKEY;
    procedure CMBiDiModeChanged(var Message: TMessage); message CM_BIDIMODECHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMCancelMode(var Message: TCMCancelMode); message CM_CANCELMODE;
    procedure WMTimer(var Message: TMessage); message WM_TIMER;
  protected
    function CanAutoSize(var NewWidth, NewHeight: Integer): Boolean; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Loaded; override;
    procedure Paint; override;
    procedure Resize; override;
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
    procedure StyleModeChanged; override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    property Images: TCustomImageList read FImages write SetImages;
    property LeftItems: TThemedMenuBarItems read FLeftItems write SetLeftItems;
    property CenterItems: TThemedMenuBarItems read FCenterItems write SetCenterItems;
    property RightItems: TThemedMenuBarItems read FRightItems write SetRightItems;
    property ItemPadding: TPadding read FItemPadding write SetItemPadding;
    property ItemHeight: Integer read FItemHeight write SetItemHeight default 23;
    property DefaultItemWidth: Integer read FDefaultItemWidth write SetDefaultItemWidth default 34;
    property SeparatorWidth: Integer read FSeparatorWidth write SetSeparatorWidth default 8;
    property ItemSpacing: Integer read FItemSpacing write SetItemSpacing default 0;
    property ArrowWidth: Integer read FArrowWidth write SetArrowWidth default 14;
    property ImageSize: Integer read FImageSize write SetImageSize default 14;
    property ImageTextSpacing: Integer read FImageTextSpacing write SetImageTextSpacing default 3;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 3;
    property ShowBottomBorder: Boolean read FShowBottomBorder write SetShowBottomBorder default True;
    property WrapKeyboardNavigation: Boolean read FWrapKeyboardNavigation write SetWrapKeyboardNavigation default True;
    property ShowOverflow: Boolean read FShowOverflow write SetShowOverflow default True;
    property OverflowButtonWidth: Integer read FOverflowButtonWidth write SetOverflowButtonWidth default 22;
    property OnItemClick: TThemedMenuBarItemEvent read FOnItemClick write FOnItemClick;
    property OnItemCheckedChanged: TThemedMenuBarItemEvent read FOnItemCheckedChanged write FOnItemCheckedChanged;
    property OnMenuOpening: TThemedMenuBarItemEvent read FOnMenuOpening write FOnMenuOpening;
    property OnMenuClosed: TThemedMenuBarItemEvent read FOnMenuClosed write FOnMenuClosed;
    property OnItemTextChanged: TThemedMenuBarTextChangedEvent read FOnItemTextChanged write FOnItemTextChanged;
    property OnItemSelectedIndexChanged: TThemedMenuBarSelectedIndexChangedEvent read FOnItemSelectedIndexChanged write FOnItemSelectedIndexChanged;
    property OnOverflowOpening: TNotifyEvent read FOnOverflowOpening write FOnOverflowOpening;
    property OnOverflowClosed: TNotifyEvent read FOnOverflowClosed write FOnOverflowClosed;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette); override;
    procedure RealignItems;
    procedure FocusFirstItem;
    procedure FocusLastItem;
    procedure ShowOverflowMenu;
    property HotItem: TThemedMenuBarItem read FHotItem;
    property FocusedItem: TThemedMenuBarItem read FFocusedItem;
    property OpenItem: TThemedMenuBarItem read FOpenItem;
    property OverflowBounds: TRect read FOverflowBounds;
    property OverflowCount: Integer read GetOverflowCount;
  end;

  TThemedMenuBar = class(TCustomThemedMenuBar)
  published
    property Align;
    property Anchors;
    property AutoSize default True;
    property BiDiMode;
    property Constraints;
    property Enabled;
    property Font;
    property Hint;
    property Images;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property LeftItems;
    property CenterItems;
    property RightItems;
    property ItemPadding;
    property StyleMode;
    property ItemHeight;
    property DefaultItemWidth;
    property SeparatorWidth;
    property ItemSpacing;
    property ArrowWidth;
    property ImageSize;
    property ImageTextSpacing;
    property CornerRadius;
    property ShowBottomBorder;
    property WrapKeyboardNavigation;
    property ShowOverflow;
    property OverflowButtonWidth;
    property OnClick;
    property OnEnter;
    property OnExit;
    property OnItemClick;
    property OnItemCheckedChanged;
    property OnMenuOpening;
    property OnMenuClosed;
    property OnItemTextChanged;
    property OnItemSelectedIndexChanged;
    property OnOverflowOpening;
    property OnOverflowClosed;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

implementation

uses
  System.Math,
  NimbusForms.Controls.TextBox,
  NimbusForms.Controls.ComboBox,
  NimbusForms.Rendering.Types,
  NimbusForms.Rendering.MenuBar;

const
  CMenuSwitchTimerId = $4E4D;
  CMenuSwitchTimerInterval = 70;

constructor TThemedMenuBarItems.Create(AOwner: TCustomThemedMenuBar; const AAlignment: TThemedMenuBarItemAlignment);
begin
  inherited Create(AOwner, TThemedMenuBarItem);
  FAlignment := AAlignment;
end;

function TThemedMenuBarItems.Add: TThemedMenuBarItem;
begin
  Result := TThemedMenuBarItem(inherited Add);
end;

function TThemedMenuBarItems.GetItem(AIndex: Integer): TThemedMenuBarItem;
begin
  Result := TThemedMenuBarItem(inherited GetItem(AIndex));
end;

procedure TThemedMenuBarItems.SetItem(AIndex: Integer; const AValue: TThemedMenuBarItem);
begin
  inherited SetItem(AIndex, AValue);
end;

function TThemedMenuBarItems.GetMenuBar: TCustomThemedMenuBar;
begin
  Result := TCustomThemedMenuBar(GetOwner);
end;

procedure TThemedMenuBarItems.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  if MenuBar <> nil then MenuBar.MenuItemsChanged;
end;

constructor TThemedMenuBarItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FKind := tmbikMenuItem;
  FEnabled := True;
  FVisible := True;
  FDisplayStyle := tmbdsImageAndText;
  FAppearance := tmbiaStandard;
  FImageIndex := -1;
  FSelectedIndex := -1;
  FIcon := TIcon.Create;
  FIcon.OnChange := IconChanged;
  FImageListIcon := TIcon.Create;
  FComboItems := TStringList.Create;
  FComboItems.OnChange := ComboItemsChanged;
end;

destructor TThemedMenuBarItem.Destroy;
var
  LBar: TCustomThemedMenuBar;
begin
  LBar := MenuBar;
  if LBar <> nil then LBar.ItemRemoving(Self);
  FComboItems.Free;
  FImageListIcon.Free;
  FIcon.Free;
  inherited Destroy;
end;

procedure TThemedMenuBarItem.Assign(Source: TPersistent);
var
  LSource: TThemedMenuBarItem;
begin
  if Source is TThemedMenuBarItem then
  begin
    LSource := TThemedMenuBarItem(Source);
    Caption := LSource.Caption;
    Kind := LSource.Kind;
    Enabled := LSource.Enabled;
    Visible := LSource.Visible;
    Checkable := LSource.Checkable;
    Checked := LSource.Checked;
    Width := LSource.Width;
    MinimumWidth := LSource.MinimumWidth;
    MaximumWidth := LSource.MaximumWidth;
    DropDownMenu := LSource.DropDownMenu;
    Hint := LSource.Hint;
    PlaceholderText := LSource.PlaceholderText;
    ReadOnly := LSource.ReadOnly;
    DisplayStyle := LSource.DisplayStyle;
    Appearance := LSource.Appearance;
    Icon := LSource.Icon;
    ImageIndex := LSource.ImageIndex;
    ComboItems := LSource.ComboItems;
    SelectedIndex := LSource.SelectedIndex;
    FTag := LSource.FTag;
    FOnClick := LSource.FOnClick;
    FOnCheckedChanged := LSource.FOnCheckedChanged;
    FOnTextChanged := LSource.FOnTextChanged;
    FOnSelectedIndexChanged := LSource.FOnSelectedIndexChanged;
  end
  else
    inherited Assign(Source);
end;

function TThemedMenuBarItem.GetMenuBar: TCustomThemedMenuBar;
begin
  if Collection is TThemedMenuBarItems then Result := TThemedMenuBarItems(Collection).MenuBar else Result := nil;
end;

function TThemedMenuBarItem.GetDisplayName: string;
begin
  if FCaption <> '' then Result := FCaption else Result := inherited GetDisplayName;
end;

procedure TThemedMenuBarItem.SetCaption(const AValue: string);
var
  LOld: string;
  LBar: TCustomThemedMenuBar;
begin
  if FCaption = AValue then Exit;
  LOld := FCaption;
  FCaption := AValue;
  if Assigned(FOnTextChanged) then FOnTextChanged(Self);
  LBar := MenuBar;
  if LBar <> nil then LBar.ItemTextChanged(Self, LOld, AValue);
  Changed(False);
end;

procedure TThemedMenuBarItem.SetKind(const AValue: TThemedMenuBarItemKind);
begin
  if FKind = AValue then Exit;
  FKind := AValue;
  if FKind = tmbikToggleButton then FCheckable := True;
  Changed(False);
end;

procedure TThemedMenuBarItem.SetEnabled(const AValue: Boolean);
begin
  if FEnabled = AValue then Exit;
  FEnabled := AValue;
  Changed(False);
end;

procedure TThemedMenuBarItem.SetVisible(const AValue: Boolean);
begin
  if FVisible = AValue then Exit;
  FVisible := AValue;
  Changed(False);
end;

procedure TThemedMenuBarItem.SetCheckable(const AValue: Boolean);
begin
  if FCheckable = AValue then Exit;
  FCheckable := AValue;
  Changed(False);
end;

procedure TThemedMenuBarItem.SetChecked(const AValue: Boolean);
var
  LBar: TCustomThemedMenuBar;
begin
  if FChecked = AValue then Exit;
  FChecked := AValue;
  if Assigned(FOnCheckedChanged) then FOnCheckedChanged(Self);
  LBar := MenuBar;
  if LBar <> nil then LBar.ItemCheckedChanged(Self);
  Changed(False);
end;

procedure TThemedMenuBarItem.SetWidth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(0, AValue);
  if FWidth = LValue then Exit;
  FWidth := LValue;
  Changed(False);
end;

procedure TThemedMenuBarItem.SetMinimumWidth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(0, AValue);
  if FMinimumWidth = LValue then Exit;
  FMinimumWidth := LValue;
  Changed(False);
end;

procedure TThemedMenuBarItem.SetMaximumWidth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(0, AValue);
  if FMaximumWidth = LValue then Exit;
  FMaximumWidth := LValue;
  Changed(False);
end;

procedure TThemedMenuBarItem.SetDropDownMenu(const AValue: TThemedPopupMenu);
var
  LBar: TCustomThemedMenuBar;
  LOld: TThemedPopupMenu;
begin
  if FDropDownMenu = AValue then Exit;
  LOld := FDropDownMenu;
  FDropDownMenu := AValue;
  LBar := MenuBar;
  if LBar <> nil then LBar.DropDownMenuChanged(Self, LOld, AValue);
  Changed(False);
end;

procedure TThemedMenuBarItem.SetHint(const AValue: string);
begin
  if FHint = AValue then Exit;
  FHint := AValue;
  Changed(False);
end;

procedure TThemedMenuBarItem.SetPlaceholderText(const AValue: string);
var
  LBar: TCustomThemedMenuBar;
begin
  if FPlaceholderText = AValue then Exit;
  FPlaceholderText := AValue;
  LBar := MenuBar;
  if LBar <> nil then LBar.SyncHostedControl(Self);
  Changed(False);
end;

procedure TThemedMenuBarItem.SetReadOnly(const AValue: Boolean);
var
  LBar: TCustomThemedMenuBar;
begin
  if FReadOnly = AValue then Exit;
  FReadOnly := AValue;
  LBar := MenuBar;
  if LBar <> nil then LBar.SyncHostedControl(Self);
  Changed(False);
end;

procedure TThemedMenuBarItem.SetDisplayStyle(const AValue: TThemedMenuBarDisplayStyle);
begin
  if FDisplayStyle = AValue then Exit;
  FDisplayStyle := AValue;
  Changed(False);
end;

procedure TThemedMenuBarItem.SetAppearance(const AValue: TThemedMenuBarItemAppearance);
begin
  if FAppearance = AValue then Exit;
  FAppearance := AValue;
  Changed(False);
end;

procedure TThemedMenuBarItem.SetIcon(const AValue: TIcon);
begin
  if AValue = nil then FIcon.Handle := 0 else FIcon.Assign(AValue);
end;

procedure TThemedMenuBarItem.IconChanged(Sender: TObject);
begin
  Changed(False);
end;

procedure TThemedMenuBarItem.SetImageIndex(const AValue: System.UITypes.TImageIndex);
var
  LBar: TCustomThemedMenuBar;
begin
  if FImageIndex = AValue then Exit;
  FImageIndex := AValue;
  LBar := MenuBar;
  if LBar <> nil then LBar.RefreshItemImage(Self) else FImageListIcon.Handle := 0;
  Changed(False);
end;

function TThemedMenuBarItem.GetComboItems: TStrings;
begin
  Result := FComboItems;
end;

procedure TThemedMenuBarItem.SetComboItems(const AValue: TStrings);
begin
  if AValue = nil then FComboItems.Clear else FComboItems.Assign(AValue);
end;

procedure TThemedMenuBarItem.ComboItemsChanged(Sender: TObject);
var
  LBar: TCustomThemedMenuBar;
begin
  if FSelectedIndex >= FComboItems.Count then
  begin
    SetSelectedIndex(FComboItems.Count - 1);
    Exit;
  end;
  if (FSelectedIndex >= 0) and (FSelectedIndex < FComboItems.Count) and (FCaption <> FComboItems[FSelectedIndex]) then
    SetCaption(FComboItems[FSelectedIndex]);
  LBar := MenuBar;
  if LBar <> nil then LBar.SyncHostedControl(Self);
  Changed(False);
end;

procedure TThemedMenuBarItem.SetSelectedIndex(const AValue: Integer);
var
  LValue: Integer;
  LBar: TCustomThemedMenuBar;
begin
  LValue := AValue;
  if LValue < -1 then LValue := -1;
  if LValue >= FComboItems.Count then LValue := FComboItems.Count - 1;
  if FSelectedIndex = LValue then Exit;
  FSelectedIndex := LValue;
  if (FSelectedIndex >= 0) and (FSelectedIndex < FComboItems.Count) then SetCaption(FComboItems[FSelectedIndex]);
  if Assigned(FOnSelectedIndexChanged) then FOnSelectedIndexChanged(Self);
  LBar := MenuBar;
  if LBar <> nil then LBar.ItemSelectedIndexChanged(Self);
  Changed(False);
end;

function TThemedMenuBarItem.HasDropDown: Boolean;
begin
  Result := FDropDownMenu <> nil;
end;

function TThemedMenuBarItem.IsInteractive: Boolean;
begin
  Result := FKind in [tmbikMenuItem, tmbikButton, tmbikToggleButton, tmbikDropDown, tmbikComboBox];
end;

function TThemedMenuBarItem.IsInput: Boolean;
begin
  Result := FKind in [tmbikTextBox, tmbikSearchBox, tmbikComboBox];
end;

function TThemedMenuBarItem.IsFocusable: Boolean;
begin
  Result := IsInteractive or IsInput;
end;

function TThemedMenuBarItem.CurrentIconHandle: HICON;
begin
  if (FImageIndex >= 0) and (FImageListIcon <> nil) and not FImageListIcon.Empty then Result := FImageListIcon.Handle
  else if (FIcon <> nil) and not FIcon.Empty then Result := FIcon.Handle
  else Result := 0;
end;

procedure TThemedMenuBarItem.Click;
begin
  if Assigned(FOnClick) then FOnClick(Self);
end;

constructor TCustomThemedMenuBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMeasureCanvas := TNimbusRenderCanvas.Create;
  FMeasureBitmap := Vcl.Graphics.TBitmap.Create;
  FMeasureBitmap.PixelFormat := pf32bit;
  FMeasureBitmap.SetSize(1, 1);
  FLeftItems := TThemedMenuBarItems.Create(Self, tmbiaLeft);
  FCenterItems := TThemedMenuBarItems.Create(Self, tmbiaCenter);
  FRightItems := TThemedMenuBarItems.Create(Self, tmbiaRight);
  FImageChangeLink := TChangeLink.Create;
  FImageChangeLink.OnChange := ImageListChanged;
  FItemPadding := TPadding.Create(Self);
  FItemPadding.SetBounds(7, 2, 7, 2);
  FItemPadding.OnChange := ItemPaddingChanged;
  FItemHeight := 23;
  FDefaultItemWidth := 34;
  FSeparatorWidth := 8;
  FItemSpacing := 0;
  FArrowWidth := 14;
  FImageSize := 14;
  FImageTextSpacing := 3;
  FCornerRadius := 3;
  FShowBottomBorder := True;
  FWrapKeyboardNavigation := True;
  FShowOverflow := True;
  FOverflowButtonWidth := 22;
  FOverflowItems := TList<TThemedMenuBarItem>.Create;
  FOverflowMenu := TThemedPopupMenu.Create(Self);
  FInitialized := True;
  ControlStyle := ControlStyle + [csClickEvents, csCaptureMouse] - [csAcceptsControls];
  TabStop := True;
  Align := alTop;
  AutoSize := True;
  Height := ScaleValue(25);
end;

procedure TCustomThemedMenuBar.StyleModeChanged;
begin
  inherited StyleModeChanged;
  if StyleMode = stCompact then
  begin
    FCompactOverrides := 0;
    if FItemHeight = 23 then begin ItemHeight := 20; FCompactOverrides := FCompactOverrides or 1; end;
    if (FItemPadding.Left = 7) and (FItemPadding.Right = 7) then
    begin
      FItemPadding.SetBounds(5, FItemPadding.Top, 5, FItemPadding.Bottom);
      FCompactOverrides := FCompactOverrides or 2;
    end;
    if FOverflowButtonWidth = 22 then
    begin
      OverflowButtonWidth := 19;
      FCompactOverrides := FCompactOverrides or 4;
    end;
  end
  else
  begin
    if ((FCompactOverrides and 1) <> 0) and (FItemHeight = 20) then ItemHeight := 23;
    if ((FCompactOverrides and 2) <> 0) and (FItemPadding.Left = 5) and (FItemPadding.Right = 5) then
      FItemPadding.SetBounds(7, FItemPadding.Top, 7, FItemPadding.Bottom);
    if ((FCompactOverrides and 4) <> 0) and (FOverflowButtonWidth = 19) then OverflowButtonWidth := 22;
    FCompactOverrides := 0;
  end;
  RealignItems;
end;

destructor TCustomThemedMenuBar.Destroy;
begin
  FInitialized := False;
  if HandleAllocated then KillTimer(Handle, CMenuSwitchTimerId);
  if FImages <> nil then
  begin
    FImages.UnRegisterChanges(FImageChangeLink);
    FImages.RemoveFreeNotification(Self);
  end;
  FOverflowSearchItem := nil;
  FOverflowSearchForm.Free;
  FOverflowSearchForm := nil;
  FOverflowSearchEditor := nil;
  FOverflowMenu.Free;
  FOverflowMenu := nil;
  FItemPadding.Free;
  FItemPadding := nil;
  FRightItems.Free;
  FRightItems := nil;
  FCenterItems.Free;
  FCenterItems := nil;
  FLeftItems.Free;
  FLeftItems := nil;
  FOverflowItems.Free;
  FOverflowItems := nil;
  FImageChangeLink.Free;
  FImageChangeLink := nil;
  FMeasureBitmap.Free;
  FMeasureBitmap := nil;
  FMeasureCanvas := nil;
  inherited Destroy;
end;

procedure TCustomThemedMenuBar.ApplyTheme(const APalette: TThemePalette);
  procedure ApplyItems(const AItems: TThemedMenuBarItems);
  var
    I: Integer;
  begin
    if AItems = nil then Exit;
    for I := 0 to AItems.Count - 1 do
      if AItems[I].FHostedControl is TThemedTextBox then
        TThemedTextBox(AItems[I].FHostedControl).ApplyTheme(APalette)
      else if AItems[I].FHostedControl is TThemedComboBox then
        TThemedComboBox(AItems[I].FHostedControl).ApplyTheme(APalette);
  end;
begin
  inherited ApplyTheme(APalette);
  if FOverflowMenu <> nil then FOverflowMenu.ApplyTheme(APalette);
  if (FOverflowSearchEditor <> nil) and (APalette <> nil) then TThemedTextBox(FOverflowSearchEditor).ApplyTheme(APalette);
  ApplyItems(FLeftItems);
  ApplyItems(FCenterItems);
  ApplyItems(FRightItems);
end;

procedure TCustomThemedMenuBar.SetLeftItems(const AValue: TThemedMenuBarItems);
begin
  FLeftItems.Assign(AValue);
end;

procedure TCustomThemedMenuBar.SetCenterItems(const AValue: TThemedMenuBarItems);
begin
  FCenterItems.Assign(AValue);
end;

procedure TCustomThemedMenuBar.SetRightItems(const AValue: TThemedMenuBarItems);
begin
  FRightItems.Assign(AValue);
end;

procedure TCustomThemedMenuBar.SetImages(const AValue: TCustomImageList);
begin
  if FImages = AValue then Exit;
  if FImages <> nil then
  begin
    FImages.UnRegisterChanges(FImageChangeLink);
    FImages.RemoveFreeNotification(Self);
  end;
  FImages := AValue;
  FOverflowMenu.Images := FImages;
  if FImages <> nil then
  begin
    FImages.RegisterChanges(FImageChangeLink);
    FImages.FreeNotification(Self);
  end;
  RefreshAllImages;
end;

procedure TCustomThemedMenuBar.ImageListChanged(Sender: TObject);
begin
  RefreshAllImages;
end;

procedure TCustomThemedMenuBar.SetItemPadding(const AValue: TPadding);
begin
  FItemPadding.Assign(AValue);
end;

procedure TCustomThemedMenuBar.SetItemHeight(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(18, AValue);
  if FItemHeight = LValue then Exit;
  FItemHeight := LValue;
  if AutoSize then AdjustSize;
  LayoutItems;
  Invalidate;
end;

procedure TCustomThemedMenuBar.SetDefaultItemWidth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(18, AValue);
  if FDefaultItemWidth = LValue then Exit;
  FDefaultItemWidth := LValue;
  LayoutItems;
  Invalidate;
end;

procedure TCustomThemedMenuBar.SetSeparatorWidth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(2, AValue);
  if FSeparatorWidth = LValue then Exit;
  FSeparatorWidth := LValue;
  LayoutItems;
  Invalidate;
end;

procedure TCustomThemedMenuBar.SetItemSpacing(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(0, AValue);
  if FItemSpacing = LValue then Exit;
  FItemSpacing := LValue;
  LayoutItems;
  Invalidate;
end;

procedure TCustomThemedMenuBar.SetArrowWidth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(8, AValue);
  if FArrowWidth = LValue then Exit;
  FArrowWidth := LValue;
  LayoutItems;
  Invalidate;
end;

procedure TCustomThemedMenuBar.SetImageSize(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(8, AValue);
  if FImageSize = LValue then Exit;
  FImageSize := LValue;
  LayoutItems;
  Invalidate;
end;

procedure TCustomThemedMenuBar.SetImageTextSpacing(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(0, AValue);
  if FImageTextSpacing = LValue then Exit;
  FImageTextSpacing := LValue;
  LayoutItems;
  Invalidate;
end;

procedure TCustomThemedMenuBar.SetCornerRadius(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(0, AValue);
  if FCornerRadius = LValue then Exit;
  FCornerRadius := LValue;
  Invalidate;
end;

procedure TCustomThemedMenuBar.SetShowBottomBorder(const AValue: Boolean);
begin
  if FShowBottomBorder = AValue then Exit;
  FShowBottomBorder := AValue;
  Invalidate;
end;

procedure TCustomThemedMenuBar.SetWrapKeyboardNavigation(const AValue: Boolean);
begin
  if FWrapKeyboardNavigation = AValue then Exit;
  FWrapKeyboardNavigation := AValue;
end;

procedure TCustomThemedMenuBar.SetShowOverflow(const AValue: Boolean);
begin
  if FShowOverflow = AValue then Exit;
  FShowOverflow := AValue;
  LayoutItems;
  Invalidate;
end;

procedure TCustomThemedMenuBar.SetOverflowButtonWidth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(16, AValue);
  if FOverflowButtonWidth = LValue then Exit;
  FOverflowButtonWidth := LValue;
  LayoutItems;
  Invalidate;
end;

procedure TCustomThemedMenuBar.ItemPaddingChanged(Sender: TObject);
begin
  LayoutItems;
  Invalidate;
end;

procedure TCustomThemedMenuBar.MenuItemsChanged;
begin
  if not FInitialized or (csDestroying in ComponentState) then Exit;
  if FSyncingHostedControl then
  begin
    Invalidate;
    Exit;
  end;
  SyncHostedControls;
  LayoutItems;
  Invalidate;
end;

procedure TCustomThemedMenuBar.ItemRemoving(const AItem: TThemedMenuBarItem);
begin
  if AItem = nil then Exit;
  if FOverflowSearchItem = AItem then
  begin
    FOverflowSearchItem := nil;
    if FOverflowSearchForm <> nil then FOverflowSearchForm.Hide;
  end;
  DestroyHostedControl(AItem);
  if FInitialized and (AItem.FDropDownMenu <> nil) and not DropDownMenuReferenced(AItem.FDropDownMenu, AItem) then
    AItem.FDropDownMenu.RemoveFreeNotification(Self);
  if FHotItem = AItem then FHotItem := nil;
  if FPressedItem = AItem then FPressedItem := nil;
  if FFocusedItem = AItem then FFocusedItem := nil;
  if FOpenItem = AItem then FOpenItem := nil;
  if FPendingOpenItem = AItem then FPendingOpenItem := nil;
  if FOverflowItems <> nil then FOverflowItems.Remove(AItem);
end;

procedure TCustomThemedMenuBar.ItemCheckedChanged(const AItem: TThemedMenuBarItem);
begin
  if Assigned(FOnItemCheckedChanged) then FOnItemCheckedChanged(Self, AItem);
  Invalidate;
end;

procedure TCustomThemedMenuBar.ItemTextChanged(const AItem: TThemedMenuBarItem; const AOldText, ANewText: string);
begin
  if not FSyncingHostedControl then SyncHostedControl(AItem);
  if Assigned(FOnItemTextChanged) then FOnItemTextChanged(Self, AItem, AOldText, ANewText);
  if (AItem <> nil) and not AItem.IsInput and (AItem.Width = 0) then LayoutItems;
  Invalidate;
end;

procedure TCustomThemedMenuBar.ItemSelectedIndexChanged(const AItem: TThemedMenuBarItem);
begin
  if not FSyncingHostedControl then SyncHostedControl(AItem);
  if Assigned(FOnItemSelectedIndexChanged) then FOnItemSelectedIndexChanged(Self, AItem, AItem.SelectedIndex);
  Invalidate;
end;

function TCustomThemedMenuBar.DropDownMenuReferenced(const AMenu: TThemedPopupMenu; const AExclude: TThemedMenuBarItem): Boolean;
  function Scan(const AItems: TThemedMenuBarItems): Boolean;
  var
    I: Integer;
  begin
    if AItems = nil then Exit(False);
    for I := 0 to AItems.Count - 1 do
      if (AItems[I] <> AExclude) and (AItems[I].FDropDownMenu = AMenu) then Exit(True);
    Result := False;
  end;
begin
  Result := (AMenu <> nil) and (Scan(FLeftItems) or Scan(FCenterItems) or Scan(FRightItems));
end;

procedure TCustomThemedMenuBar.DropDownMenuChanged(const AItem: TThemedMenuBarItem; const AOldMenu, ANewMenu: TThemedPopupMenu);
begin
  if (AOldMenu <> nil) and not DropDownMenuReferenced(AOldMenu, AItem) then AOldMenu.RemoveFreeNotification(Self);
  if (ANewMenu <> nil) and not DropDownMenuReferenced(ANewMenu, AItem) then ANewMenu.FreeNotification(Self);
end;

procedure TCustomThemedMenuBar.RefreshItemImage(const AItem: TThemedMenuBarItem);
begin
  if AItem = nil then Exit;
  AItem.FImageListIcon.Handle := 0;
  if (FImages <> nil) and (AItem.ImageIndex >= 0) and (AItem.ImageIndex < FImages.Count) then
    FImages.GetIcon(AItem.ImageIndex, AItem.FImageListIcon);
end;

procedure TCustomThemedMenuBar.RefreshAllImages;
  procedure Scan(const AItems: TThemedMenuBarItems);
  var
    I: Integer;
  begin
    if AItems = nil then Exit;
    for I := 0 to AItems.Count - 1 do RefreshItemImage(AItems[I]);
  end;
begin
  Scan(FLeftItems);
  Scan(FCenterItems);
  Scan(FRightItems);
  LayoutItems;
  Invalidate;
end;

procedure TCustomThemedMenuBar.DestroyHostedControl(const AItem: TThemedMenuBarItem);
begin
  if (AItem = nil) or (AItem.FHostedControl = nil) then Exit;
  AItem.FHostedControl.Free;
  AItem.FHostedControl := nil;
end;

procedure TCustomThemedMenuBar.SyncHostedControl(const AItem: TThemedMenuBarItem);
var
  LTextBox: TThemedTextBox;
  LComboBox: TThemedComboBox;
begin
  if (AItem = nil) or (csDestroying in ComponentState) then Exit;
  if AItem.Kind in [tmbikTextBox, tmbikSearchBox] then
  begin
    if not (AItem.FHostedControl is TThemedTextBox) then
    begin
      DestroyHostedControl(AItem);
      LTextBox := TThemedTextBox.Create(Self);
      LTextBox.Parent := Self;
      LTextBox.ParentFont := True;
      LTextBox.ParentBiDiMode := True;
      LTextBox.TabStop := True;
      LTextBox.UseRoundedCorners := False;
      LTextBox.OnChange := HostedTextBoxChange;
      LTextBox.OnEnter := HostedControlEnter;
      LTextBox.OnExit := HostedControlExit;
      AItem.FHostedControl := LTextBox;
    end;
    LTextBox := TThemedTextBox(AItem.FHostedControl);
    FSyncingHostedControl := True;
    try
      LTextBox.Text := AItem.Caption;
      LTextBox.PlaceholderText := AItem.PlaceholderText;
      LTextBox.ReadOnly := AItem.ReadOnly;
      LTextBox.ShowClearButton := AItem.Kind = tmbikSearchBox;
      LTextBox.Enabled := Enabled and AItem.Enabled;
      LTextBox.Visible := AItem.Visible and not AItem.FBounds.IsEmpty;
      if Palette <> nil then LTextBox.ApplyTheme(Palette);
    finally
      FSyncingHostedControl := False;
    end;
    LayoutHostedControl(AItem);
    Exit;
  end;
  if AItem.Kind = tmbikComboBox then
  begin
    if not (AItem.FHostedControl is TThemedComboBox) then
    begin
      DestroyHostedControl(AItem);
      LComboBox := TThemedComboBox.Create(Self);
      LComboBox.Parent := Self;
      LComboBox.ParentFont := True;
      LComboBox.ParentBiDiMode := True;
      LComboBox.TabStop := True;
      LComboBox.OnChange := HostedComboBoxChange;
      LComboBox.OnSelect := HostedComboBoxChange;
      LComboBox.OnEnter := HostedControlEnter;
      LComboBox.OnExit := HostedControlExit;
      AItem.FHostedControl := LComboBox;
    end;
    LComboBox := TThemedComboBox(AItem.FHostedControl);
    FSyncingHostedControl := True;
    try
      LComboBox.Items.Assign(AItem.ComboItems);
      LComboBox.ItemIndex := AItem.SelectedIndex;
      if LComboBox.ItemIndex < 0 then LComboBox.Text := AItem.Caption;
      LComboBox.TextHint := AItem.PlaceholderText;
      LComboBox.Enabled := Enabled and AItem.Enabled;
      LComboBox.Visible := AItem.Visible and not AItem.FBounds.IsEmpty;
      if Palette <> nil then LComboBox.ApplyTheme(Palette);
    finally
      FSyncingHostedControl := False;
    end;
    LayoutHostedControl(AItem);
    Exit;
  end;
  DestroyHostedControl(AItem);
end;

procedure TCustomThemedMenuBar.SyncHostedControls;
  procedure Scan(const AItems: TThemedMenuBarItems);
  var
    I: Integer;
  begin
    if AItems = nil then Exit;
    for I := 0 to AItems.Count - 1 do SyncHostedControl(AItems[I]);
  end;
begin
  if not FInitialized or (csDestroying in ComponentState) then Exit;
  Scan(FLeftItems);
  Scan(FCenterItems);
  Scan(FRightItems);
end;

procedure TCustomThemedMenuBar.LayoutHostedControl(const AItem: TThemedMenuBarItem);
var
  LBounds: TRect;
  LComboBox: TThemedComboBox;
  LY: Integer;
begin
  if (AItem = nil) or (AItem.FHostedControl = nil) then Exit;
  if not AItem.Visible or AItem.FBounds.IsEmpty then
  begin
    AItem.FHostedControl.Visible := False;
    Exit;
  end;
  LBounds := AItem.FBounds;
  if AItem.FHostedControl is TThemedComboBox then
  begin
    LComboBox := TThemedComboBox(AItem.FHostedControl);
    LComboBox.SetBounds(LBounds.Left, LBounds.Top, LBounds.Width, LBounds.Height);
    LY := LBounds.Top + Max(0, (LBounds.Height - LComboBox.Height) div 2);
    if LComboBox.Top <> LY then LComboBox.Top := LY;
  end
  else
    AItem.FHostedControl.SetBounds(LBounds.Left, LBounds.Top, LBounds.Width, LBounds.Height);
  AItem.FHostedControl.Enabled := Enabled and AItem.Enabled;
  AItem.FHostedControl.Visible := True;
  AItem.FHostedControl.BringToFront;
end;

function TCustomThemedMenuBar.FindHostedItem(const AControl: TControl): TThemedMenuBarItem;
  function Scan(const AItems: TThemedMenuBarItems): TThemedMenuBarItem;
  var
    I: Integer;
  begin
    Result := nil;
    if AItems = nil then Exit;
    for I := 0 to AItems.Count - 1 do
      if AItems[I].FHostedControl = AControl then Exit(AItems[I]);
  end;
begin
  Result := Scan(FLeftItems);
  if Result <> nil then Exit;
  Result := Scan(FCenterItems);
  if Result <> nil then Exit;
  Result := Scan(FRightItems);
end;

procedure TCustomThemedMenuBar.HostedTextBoxChange(Sender: TObject);
var
  LItem: TThemedMenuBarItem;
begin
  if FSyncingHostedControl or not (Sender is TThemedTextBox) then Exit;
  LItem := FindHostedItem(TControl(Sender));
  if LItem = nil then Exit;
  FSyncingHostedControl := True;
  try
    LItem.Caption := TThemedTextBox(Sender).Text;
  finally
    FSyncingHostedControl := False;
  end;
end;

procedure TCustomThemedMenuBar.HostedComboBoxChange(Sender: TObject);
var
  LItem: TThemedMenuBarItem;
  LComboBox: TThemedComboBox;
begin
  if FSyncingHostedControl or not (Sender is TThemedComboBox) then Exit;
  LComboBox := TThemedComboBox(Sender);
  LItem := FindHostedItem(LComboBox);
  if LItem = nil then Exit;
  FSyncingHostedControl := True;
  try
    LItem.SelectedIndex := LComboBox.ItemIndex;
    if LComboBox.ItemIndex < 0 then LItem.Caption := LComboBox.Text;
  finally
    FSyncingHostedControl := False;
  end;
end;

procedure TCustomThemedMenuBar.HostedControlEnter(Sender: TObject);
var
  LItem: TThemedMenuBarItem;
begin
  if not (Sender is TControl) then Exit;
  LItem := FindHostedItem(TControl(Sender));
  if LItem <> nil then
  begin
    FFocusedItem := LItem;
    Invalidate;
  end;
end;

procedure TCustomThemedMenuBar.HostedControlExit(Sender: TObject);
begin
  Invalidate;
end;

function TCustomThemedMenuBar.GetItemWidth(const AItem: TThemedMenuBarItem): Integer;
var
  LSize: TSize;
  LWidth: Integer;
  LHasImage, LHasText: Boolean;
begin
  if AItem = nil then Exit(0);
  if AItem.Width > 0 then Exit(ScaleValue(AItem.Width));
  case AItem.Kind of
    tmbikSeparator: Exit(ScaleValue(FSeparatorWidth));
    tmbikSpring: Exit(0);
    tmbikTextBox: LWidth := ScaleValue(120);
    tmbikSearchBox: LWidth := ScaleValue(180);
    tmbikComboBox: LWidth := ScaleValue(110);
  else
    begin
      LWidth := ScaleValue(FItemPadding.Left + FItemPadding.Right);
      LHasImage := (AItem.CurrentIconHandle <> 0) and (AItem.DisplayStyle <> tmbdsText);
      LHasText := (AItem.Caption <> '') and (AItem.DisplayStyle <> tmbdsImage);
      if LHasImage then Inc(LWidth, ScaleValue(FImageSize));
      if LHasImage and LHasText then Inc(LWidth, ScaleValue(FImageTextSpacing));
      if LHasText then
      begin
        LSize := FMeasureCanvas.MeasureText(AItem.Caption, Font, 10000, [ntfSingleLine]);
        Inc(LWidth, LSize.cx);
      end;
      if AItem.Kind = tmbikDropDown then Inc(LWidth, ScaleValue(FArrowWidth));
      LWidth := Max(ScaleValue(FDefaultItemWidth), LWidth);
    end;
  end;
  if AItem.MinimumWidth > 0 then LWidth := Max(LWidth, ScaleValue(AItem.MinimumWidth));
  if AItem.MaximumWidth > 0 then
  begin
    if AItem.MinimumWidth > 0 then
      LWidth := Max(ScaleValue(AItem.MinimumWidth), Min(LWidth, ScaleValue(AItem.MaximumWidth)))
    else
      LWidth := Min(LWidth, ScaleValue(AItem.MaximumWidth));
  end;
  Result := LWidth;
end;

function TCustomThemedMenuBar.GetCollectionWidth(const AItems: TThemedMenuBarItems; const ASpringWidth: Integer): Integer;
var
  I, LVisible, LWidth: Integer;
begin
  Result := 0;
  LVisible := 0;
  if AItems = nil then Exit;
  for I := 0 to AItems.Count - 1 do
    if AItems[I].Visible and not IsOverflowed(AItems[I]) then
    begin
      if AItems[I].Kind = tmbikSpring then LWidth := ASpringWidth else LWidth := GetItemWidth(AItems[I]);
      Inc(Result, LWidth);
      Inc(LVisible);
    end;
  if LVisible > 1 then Inc(Result, ScaleValue(FItemSpacing) * (LVisible - 1));
end;

function TCustomThemedMenuBar.GetCollectionSpringCount(const AItems: TThemedMenuBarItems): Integer;
var
  I: Integer;
begin
  Result := 0;
  if AItems = nil then Exit;
  for I := 0 to AItems.Count - 1 do
    if AItems[I].Visible and not IsOverflowed(AItems[I]) and (AItems[I].Kind = tmbikSpring) then Inc(Result);
end;

function TCustomThemedMenuBar.CollectionHasVisibleItems(const AItems: TThemedMenuBarItems): Boolean;
var
  I: Integer;
begin
  Result := False;
  if AItems = nil then Exit;
  for I := 0 to AItems.Count - 1 do
    if AItems[I].Visible and not IsOverflowed(AItems[I]) then Exit(True);
end;

procedure TCustomThemedMenuBar.LayoutEdgeItems(const AItems: TThemedMenuBarItems; const AFromRight, AForwardOrder: Boolean; var AEdge: Integer; const AY, ASpringWidth: Integer);
var
  I, LStart, LFinish, LStep, LWidth, LSpacing, LPlaced: Integer;
  LItem: TThemedMenuBarItem;
begin
  LSpacing := ScaleValue(FItemSpacing);
  LPlaced := 0;
  if AForwardOrder then
  begin
    LStart := 0;
    LFinish := AItems.Count - 1;
    LStep := 1;
  end
  else
  begin
    LStart := AItems.Count - 1;
    LFinish := 0;
    LStep := -1;
  end;
  I := LStart;
  while ((LStep > 0) and (I <= LFinish)) or ((LStep < 0) and (I >= LFinish)) do
  begin
    LItem := AItems[I];
    if not LItem.Visible or IsOverflowed(LItem) then
      LItem.FBounds := TRect.Empty
    else
    begin
      if LPlaced > 0 then
      begin
        if AFromRight then Dec(AEdge, LSpacing) else Inc(AEdge, LSpacing);
      end;
      if LItem.Kind = tmbikSpring then LWidth := ASpringWidth else LWidth := GetItemWidth(LItem);
      if AFromRight then
      begin
        Dec(AEdge, LWidth);
        LItem.FBounds := Rect(AEdge, AY, AEdge + LWidth, AY + ScaleValue(FItemHeight));
      end
      else
      begin
        LItem.FBounds := Rect(AEdge, AY, AEdge + LWidth, AY + ScaleValue(FItemHeight));
        Inc(AEdge, LWidth);
      end;
      Inc(LPlaced);
    end;
    Inc(I, LStep);
  end;
end;

procedure TCustomThemedMenuBar.LayoutCenterItems(const ALeftLimit, ARightLimit, AY, ASpringWidth: Integer);
var
  I, LX, LWidth, LTotal, LSpacing, LAvailableLeft, LAvailableRight, LPlaced: Integer;
  LItem: TThemedMenuBarItem;
begin
  LSpacing := ScaleValue(FItemSpacing);
  LAvailableLeft := ALeftLimit + ScaleValue(8);
  LAvailableRight := ARightLimit - ScaleValue(8);
  LTotal := GetCollectionWidth(FCenterItems, ASpringWidth);
  if (LAvailableRight <= LAvailableLeft) or (LTotal > LAvailableRight - LAvailableLeft) then
  begin
    for I := 0 to FCenterItems.Count - 1 do
    begin
      FCenterItems[I].FBounds := TRect.Empty;
      LayoutHostedControl(FCenterItems[I]);
    end;
    Exit;
  end;
  LPlaced := 0;
  if BiDiMode = bdRightToLeft then
  begin
    LX := LAvailableLeft + (LAvailableRight - LAvailableLeft + LTotal) div 2;
    for I := 0 to FCenterItems.Count - 1 do
    begin
      LItem := FCenterItems[I];
      if not LItem.Visible or IsOverflowed(LItem) then
      begin
        LItem.FBounds := TRect.Empty;
        Continue;
      end;
      if LPlaced > 0 then Dec(LX, LSpacing);
      if LItem.Kind = tmbikSpring then LWidth := ASpringWidth else LWidth := GetItemWidth(LItem);
      Dec(LX, LWidth);
      LItem.FBounds := Rect(LX, AY, LX + LWidth, AY + ScaleValue(FItemHeight));
      Inc(LPlaced);
    end;
  end
  else
  begin
    LX := LAvailableLeft + (LAvailableRight - LAvailableLeft - LTotal) div 2;
    for I := 0 to FCenterItems.Count - 1 do
    begin
      LItem := FCenterItems[I];
      if not LItem.Visible or IsOverflowed(LItem) then
      begin
        LItem.FBounds := TRect.Empty;
        Continue;
      end;
      if LPlaced > 0 then Inc(LX, LSpacing);
      if LItem.Kind = tmbikSpring then LWidth := ASpringWidth else LWidth := GetItemWidth(LItem);
      LItem.FBounds := Rect(LX, AY, LX + LWidth, AY + ScaleValue(FItemHeight));
      Inc(LX, LWidth);
      Inc(LPlaced);
    end;
  end;
end;

function TCustomThemedMenuBar.IsOverflowed(const AItem: TThemedMenuBarItem): Boolean;
begin
  Result := (AItem <> nil) and (FOverflowItems <> nil) and (FOverflowItems.IndexOf(AItem) >= 0);
end;

function TCustomThemedMenuBar.GetOverflowCount: Integer;
begin
  if FOverflowItems = nil then Result := 0 else Result := FOverflowItems.Count;
end;

procedure TCustomThemedMenuBar.LayoutItems;
var
  LLeftEdge, LRightEdge, LY, LSpringCount, LSpringWidth, LFreeWidth, LFixedWidth: Integer;
  LCenterGap, LAvailableWidth, LOverflowWidth, LOverflowGap, LTargetWidth: Integer;
  LCandidate: TThemedMenuBarItem;

  procedure LayoutHosted(const AItems: TThemedMenuBarItems);
  var
    I: Integer;
  begin
    for I := 0 to AItems.Count - 1 do LayoutHostedControl(AItems[I]);
  end;

  function RequiredWidth: Integer;
  begin
    Result := GetCollectionWidth(FLeftItems, 0) + GetCollectionWidth(FCenterItems, 0) + GetCollectionWidth(FRightItems, 0);
    if CollectionHasVisibleItems(FCenterItems) then Inc(Result, ScaleValue(16));
  end;

  function FindInputCandidate(const AItems: TThemedMenuBarItems): TThemedMenuBarItem;
  var
    I: Integer;
  begin
    Result := nil;
    for I := AItems.Count - 1 downto 0 do
      if AItems[I].Visible and not IsOverflowed(AItems[I]) and
        (AItems[I].Kind in [tmbikTextBox, tmbikSearchBox, tmbikComboBox]) then
        Exit(AItems[I]);
  end;

  function FindCollectionCandidate(const AItems: TThemedMenuBarItems): TThemedMenuBarItem;
  var
    I: Integer;
  begin
    Result := nil;
    for I := AItems.Count - 1 downto 0 do
      if AItems[I].Visible and not IsOverflowed(AItems[I]) and (AItems[I].Kind <> tmbikSpring) then
        Exit(AItems[I]);
  end;

  function FindOverflowCandidate: TThemedMenuBarItem;
  begin
    Result := FindInputCandidate(FLeftItems);
    if Result <> nil then Exit;
    Result := FindInputCandidate(FCenterItems);
    if Result <> nil then Exit;
    Result := FindInputCandidate(FRightItems);
    if Result <> nil then Exit;
    Result := FindCollectionCandidate(FCenterItems);
    if Result <> nil then Exit;
    Result := FindCollectionCandidate(FRightItems);
    if Result <> nil then Exit;
    Result := FindCollectionCandidate(FLeftItems);
  end;

  procedure AddOverflowCandidate(const AItem: TThemedMenuBarItem);
  var
    LItems: TThemedMenuBarItems;
    LLabel: TThemedMenuBarItem;
  begin
    if (AItem = nil) or IsOverflowed(AItem) then Exit;
    if AItem.IsInput and (AItem.Collection is TThemedMenuBarItems) and (AItem.Index > 0) then
    begin
      LItems := TThemedMenuBarItems(AItem.Collection);
      LLabel := LItems[AItem.Index - 1];
      if LLabel.Visible and not IsOverflowed(LLabel) and (LLabel.Kind = tmbikLabel) then
        FOverflowItems.Add(LLabel);
    end;
    FOverflowItems.Add(AItem);
  end;

begin
  if not FInitialized or FLayouting or (csDestroying in ComponentState) then Exit;
  FLayouting := True;
  try
    FOverflowItems.Clear;
    FOverflowBounds := TRect.Empty;
    FMeasureCanvas.BeginRender(FMeasureBitmap.Canvas);
    try
      LY := Max(0, (ClientHeight - ScaleValue(FItemHeight)) div 2);
      LLeftEdge := ScaleValue(2);
      LRightEdge := ClientWidth - ScaleValue(2);
      LAvailableWidth := Max(0, LRightEdge - LLeftEdge);
      LOverflowWidth := Min(ScaleValue(FOverflowButtonWidth), LAvailableWidth);
      LOverflowGap := ScaleValue(FItemSpacing);
      if FShowOverflow and not (csDesigning in ComponentState) and (RequiredWidth > LAvailableWidth) then
      begin
        LTargetWidth := Max(0, LAvailableWidth - LOverflowWidth - LOverflowGap);
        while RequiredWidth > LTargetWidth do
        begin
          LCandidate := FindOverflowCandidate;
          if LCandidate = nil then Break;
          AddOverflowCandidate(LCandidate);
        end;
        if FOverflowItems.Count > 0 then
        begin
          if BiDiMode = bdRightToLeft then
          begin
            FOverflowBounds := Rect(LLeftEdge, LY, LLeftEdge + LOverflowWidth, LY + ScaleValue(FItemHeight));
            Inc(LLeftEdge, LOverflowWidth + LOverflowGap);
          end
          else
          begin
            FOverflowBounds := Rect(LRightEdge - LOverflowWidth, LY, LRightEdge, LY + ScaleValue(FItemHeight));
            Dec(LRightEdge, LOverflowWidth + LOverflowGap);
          end;
        end;
      end;
      LSpringCount := GetCollectionSpringCount(FLeftItems) + GetCollectionSpringCount(FCenterItems) + GetCollectionSpringCount(FRightItems);
      LFixedWidth := GetCollectionWidth(FLeftItems, 0) + GetCollectionWidth(FCenterItems, 0) + GetCollectionWidth(FRightItems, 0);
      if CollectionHasVisibleItems(FCenterItems) then LCenterGap := ScaleValue(16) else LCenterGap := 0;
      LFreeWidth := Max(0, LRightEdge - LLeftEdge - LFixedWidth - LCenterGap);
      if LSpringCount > 0 then LSpringWidth := LFreeWidth div LSpringCount else LSpringWidth := 0;
      if BiDiMode = bdRightToLeft then
      begin
        LayoutEdgeItems(FLeftItems, True, True, LRightEdge, LY, LSpringWidth);
        LayoutEdgeItems(FRightItems, False, False, LLeftEdge, LY, LSpringWidth);
      end
      else
      begin
        LayoutEdgeItems(FLeftItems, False, True, LLeftEdge, LY, LSpringWidth);
        LayoutEdgeItems(FRightItems, True, False, LRightEdge, LY, LSpringWidth);
      end;
      LayoutCenterItems(LLeftEdge, LRightEdge, LY, LSpringWidth);
    finally
      FMeasureCanvas.EndRender;
    end;
    LayoutHosted(FLeftItems);
    LayoutHosted(FCenterItems);
    LayoutHosted(FRightItems);
    if FOverflowItems.Count = 0 then
    begin
      FOverflowHot := False;
      FOverflowPressed := False;
    end;
    if (FHotItem <> nil) and (not FHotItem.Visible or not FHotItem.Enabled or not FHotItem.IsInteractive or FHotItem.FBounds.IsEmpty) then FHotItem := nil;
    if (FPressedItem <> nil) and (not FPressedItem.Visible or not FPressedItem.Enabled or not FPressedItem.IsInteractive or FPressedItem.FBounds.IsEmpty) then FPressedItem := nil;
    if (FFocusedItem <> nil) and (not FFocusedItem.Visible or not FFocusedItem.Enabled or not FFocusedItem.IsFocusable or FFocusedItem.FBounds.IsEmpty) then FFocusedItem := FindFocusableEdge(True);
  finally
    FLayouting := False;
  end;
end;

procedure TCustomThemedMenuBar.CloneOverflowMenuItems(const ATarget, ASource: TMenuItem);
var
  I: Integer;
  LSource, LItem: TMenuItem;
begin
  if (ATarget = nil) or (ASource = nil) then Exit;
  for I := 0 to ASource.Count - 1 do
  begin
    LSource := ASource[I];
    if not LSource.Visible then Continue;
    LItem := TMenuItem.Create(FOverflowMenu);
    LItem.Caption := LSource.Caption;
    LItem.Enabled := LSource.Enabled;
    LItem.Checked := LSource.Checked;
    LItem.AutoCheck := LSource.AutoCheck;
    LItem.Default := LSource.Default;
    LItem.RadioItem := LSource.RadioItem;
    LItem.GroupIndex := LSource.GroupIndex;
    LItem.ShortCut := LSource.ShortCut;
    LItem.Hint := LSource.Hint;
    LItem.HelpContext := LSource.HelpContext;
    if not LSource.Bitmap.Empty then LItem.Bitmap.Assign(LSource.Bitmap);
    if (LSource.GetImageList <> nil) and (LSource.ImageIndex >= 0) and
      (LSource.ImageIndex < LSource.GetImageList.Count) then
      LSource.GetImageList.GetBitmap(LSource.ImageIndex, LItem.Bitmap);
    if LSource.Caption <> '-' then
    begin
      LItem.Tag := NativeInt(LSource);
      if LSource.Count = 0 then LItem.OnClick := OverflowSourceItemClick;
    end;
    ATarget.Add(LItem);
    if LSource.Count > 0 then CloneOverflowMenuItems(LItem, LSource);
  end;
end;

procedure TCustomThemedMenuBar.AddOverflowItem(const AItem: TThemedMenuBarItem);
var
  LRoot, LChild: TMenuItem;
  LCaption: string;
  I: Integer;
begin
  if (AItem = nil) or not AItem.Visible or (AItem.Kind = tmbikSpring) then Exit;
  if AItem.Kind = tmbikSeparator then
  begin
    LRoot := TMenuItem.Create(FOverflowMenu);
    LRoot.Caption := '-';
    FOverflowMenu.Items.Add(LRoot);
    Exit;
  end;
  LCaption := AItem.Caption;
  if LCaption = '' then LCaption := AItem.PlaceholderText;
  if LCaption = '' then LCaption := AItem.ClassName;
  LRoot := TMenuItem.Create(FOverflowMenu);
  LRoot.Caption := LCaption;
  LRoot.Enabled := Enabled and AItem.Enabled;
  LRoot.Checked := AItem.Checked;
  LRoot.AutoCheck := AItem.Checkable or (AItem.Kind = tmbikToggleButton);
  LRoot.Hint := AItem.Hint;
  if (FImages <> nil) and (AItem.ImageIndex >= 0) and (AItem.ImageIndex < FImages.Count) then
    LRoot.ImageIndex := AItem.ImageIndex
  else if (AItem.FIcon <> nil) and not AItem.FIcon.Empty then
    LRoot.Bitmap.Assign(AItem.FIcon);
  if AItem.Kind in [tmbikLabel, tmbikTextBox] then
  begin
    LRoot.Enabled := False;
    FOverflowMenu.Items.Add(LRoot);
    Exit;
  end;
  if AItem.Kind = tmbikSearchBox then
  begin
    LRoot.Tag := NativeInt(AItem);
    LRoot.OnClick := OverflowSearchClick;
    FOverflowMenu.Items.Add(LRoot);
    Exit;
  end;
  LRoot.Tag := NativeInt(AItem);
  FOverflowMenu.Items.Add(LRoot);
  if AItem.Kind = tmbikComboBox then
  begin
    LRoot.Enabled := Enabled and AItem.Enabled and (AItem.ComboItems.Count > 0);
    for I := 0 to AItem.ComboItems.Count - 1 do
    begin
      LChild := TMenuItem.Create(FOverflowMenu);
      LChild.Caption := AItem.ComboItems[I];
      LChild.Enabled := LRoot.Enabled;
      LChild.Checked := I = AItem.SelectedIndex;
      LChild.RadioItem := True;
      LChild.Tag := I + 1;
      LChild.OnClick := OverflowComboItemClick;
      LRoot.Add(LChild);
    end;
    Exit;
  end;
  if (AItem.DropDownMenu <> nil) and (AItem.DropDownMenu.Items.Count > 0) then
    CloneOverflowMenuItems(LRoot, AItem.DropDownMenu.Items)
  else
    LRoot.OnClick := OverflowItemClick;
end;

procedure TCustomThemedMenuBar.BuildOverflowMenu;
var
  LLastSeparator: Boolean;

  procedure AppendCollection(const AItems: TThemedMenuBarItems);
  var
    I: Integer;
    LBefore: Integer;
  begin
    for I := 0 to AItems.Count - 1 do
    begin
      if not IsOverflowed(AItems[I]) or (AItems[I].Kind = tmbikSpring) then Continue;
      if AItems[I].Kind = tmbikSeparator then
      begin
        if LLastSeparator then Continue;
        AddOverflowItem(AItems[I]);
        LLastSeparator := True;
      end
      else
      begin
        LBefore := FOverflowMenu.Items.Count;
        AddOverflowItem(AItems[I]);
        if FOverflowMenu.Items.Count > LBefore then LLastSeparator := False;
      end;
    end;
  end;

begin
  FOverflowMenu.Items.Clear;
  FOverflowMenu.Images := FImages;
  LLastSeparator := True;
  AppendCollection(FLeftItems);
  AppendCollection(FCenterItems);
  AppendCollection(FRightItems);
  if (FOverflowMenu.Items.Count > 0) and (FOverflowMenu.Items[FOverflowMenu.Items.Count - 1].Caption = '-') then
    FOverflowMenu.Items.Delete(FOverflowMenu.Items.Count - 1);
end;

procedure TCustomThemedMenuBar.OverflowSearchDeactivate(Sender: TObject);
begin
  if FOverflowSearchForm <> nil then FOverflowSearchForm.Hide;
end;

procedure TCustomThemedMenuBar.OverflowSearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Key := 0;
    if FOverflowSearchForm <> nil then FOverflowSearchForm.Hide;
    if CanFocus then SetFocus;
  end;
end;

procedure TCustomThemedMenuBar.OverflowSearchChanged(Sender: TObject);
begin
  if FSyncingHostedControl or (FOverflowSearchItem = nil) or not (Sender is TThemedTextBox) then Exit;
  if FOverflowSearchItem.MenuBar <> Self then Exit;
  FOverflowSearchItem.Caption := TThemedTextBox(Sender).Text;
end;

procedure TCustomThemedMenuBar.ShowOverflowSearch(const AItem: TThemedMenuBarItem);
var
  LEditor: TThemedTextBox;
  LPoint: TPoint;
  LWorkArea: TRect;
  LWidth, LHeight: Integer;
begin
  if (AItem = nil) or (AItem.MenuBar <> Self) or not AItem.Enabled or
    not AItem.Visible or (AItem.Kind <> tmbikSearchBox) or (csDestroying in ComponentState) then Exit;
  if FOverflowSearchForm = nil then
  begin
    FOverflowSearchForm := TForm.CreateNew(Self);
    FOverflowSearchForm.BorderStyle := bsNone;
    FOverflowSearchForm.BorderIcons := [];
    FOverflowSearchForm.Position := poDesigned;
    FOverflowSearchForm.AutoSize := False;
    FOverflowSearchForm.KeyPreview := True;
    FOverflowSearchForm.OnKeyDown := OverflowSearchKeyDown;
    FOverflowSearchForm.OnDeactivate := OverflowSearchDeactivate;
    LEditor := TThemedTextBox.Create(FOverflowSearchForm);
    LEditor.Parent := FOverflowSearchForm;
    LEditor.ParentFont := False;
    LEditor.TabStop := True;
    LEditor.ShowClearButton := True;
    LEditor.UseRoundedCorners := False;
    LEditor.OnChange := OverflowSearchChanged;
    FOverflowSearchEditor := LEditor;
  end;
  LEditor := TThemedTextBox(FOverflowSearchEditor);
  FOverflowSearchItem := AItem;
  FSyncingHostedControl := True;
  try
    LEditor.Font.Assign(Font);
    LEditor.Text := AItem.Caption;
    LEditor.PlaceholderText := AItem.PlaceholderText;
    LEditor.ReadOnly := AItem.ReadOnly;
    LEditor.Enabled := Enabled and AItem.Enabled;
    LEditor.BiDiMode := BiDiMode;
    if Palette <> nil then LEditor.ApplyTheme(Palette);
  finally
    FSyncingHostedControl := False;
  end;
  LWidth := ScaleValue(Max(180, AItem.Width));
  LHeight := ScaleValue(34);
  LPoint := ClientToScreen(Point(FOverflowBounds.Left, FOverflowBounds.Bottom));
  LWorkArea := Screen.MonitorFromPoint(LPoint).WorkareaRect;
  if LPoint.X + LWidth > LWorkArea.Right then LPoint.X := LWorkArea.Right - LWidth;
  if LPoint.X < LWorkArea.Left then LPoint.X := LWorkArea.Left;
  if LPoint.Y + LHeight > LWorkArea.Bottom then LPoint.Y := ClientToScreen(Point(FOverflowBounds.Left, FOverflowBounds.Top)).Y - LHeight;
  FOverflowSearchForm.SetBounds(LPoint.X, LPoint.Y, LWidth, LHeight);
  LEditor.SetBounds(ScaleValue(3), ScaleValue(3), LWidth - ScaleValue(6), LHeight - ScaleValue(6));
  FOverflowSearchForm.Show;
  LEditor.SetFocus;
end;

procedure TCustomThemedMenuBar.OverflowSearchClick(Sender: TObject);
var
  LItem: TThemedMenuBarItem;
begin
  if not (Sender is TMenuItem) or (TMenuItem(Sender).Tag = 0) then Exit;
  LItem := TThemedMenuBarItem(Pointer(TMenuItem(Sender).Tag));
  ShowOverflowSearch(LItem);
end;

procedure TCustomThemedMenuBar.OverflowItemClick(Sender: TObject);
var
  LItem: TThemedMenuBarItem;
begin
  if not (Sender is TMenuItem) or (TMenuItem(Sender).Tag = 0) then Exit;
  LItem := TThemedMenuBarItem(Pointer(TMenuItem(Sender).Tag));
  if (LItem = nil) or (LItem.MenuBar <> Self) or not LItem.Enabled then Exit;
  ExecuteItem(LItem);
end;

procedure TCustomThemedMenuBar.OverflowComboItemClick(Sender: TObject);
var
  LMenuItem, LRoot: TMenuItem;
  LItem: TThemedMenuBarItem;
  LIndex: Integer;
begin
  if not (Sender is TMenuItem) then Exit;
  LMenuItem := TMenuItem(Sender);
  LRoot := LMenuItem.Parent;
  if (LRoot = nil) or (LRoot.Tag = 0) or (LMenuItem.Tag <= 0) then Exit;
  LItem := TThemedMenuBarItem(Pointer(LRoot.Tag));
  LIndex := LMenuItem.Tag - 1;
  if (LItem = nil) or (LItem.MenuBar <> Self) or not LItem.Enabled or
    (LIndex < 0) or (LIndex >= LItem.ComboItems.Count) then Exit;
  LItem.SelectedIndex := LIndex;
end;

procedure TCustomThemedMenuBar.OverflowSourceItemClick(Sender: TObject);
var
  LSource: TMenuItem;
begin
  if not (Sender is TMenuItem) or (TMenuItem(Sender).Tag = 0) then Exit;
  LSource := TMenuItem(Pointer(TMenuItem(Sender).Tag));
  if LSource <> nil then LSource.Click;
end;

procedure TCustomThemedMenuBar.ShowOverflowMenu;
var
  LPoint: TPoint;
begin
  if not Enabled or (FOverflowItems = nil) or (FOverflowItems.Count = 0) or FOverflowBounds.IsEmpty then Exit;
  if Assigned(FOnOverflowOpening) then FOnOverflowOpening(Self);
  BuildOverflowMenu;
  if FOverflowMenu.Items.Count = 0 then
  begin
    if Assigned(FOnOverflowClosed) then FOnOverflowClosed(Self);
    Exit;
  end;
  FOverflowMenu.BiDiMode := BiDiMode;
  if Palette <> nil then FOverflowMenu.ApplyTheme(Palette);
  FOverflowPressed := True;
  Invalidate;
  if BiDiMode = bdRightToLeft then LPoint := ClientToScreen(Point(FOverflowBounds.Right, FOverflowBounds.Bottom))
  else LPoint := ClientToScreen(Point(FOverflowBounds.Left, FOverflowBounds.Bottom));
  try
    FOverflowMenu.Popup(LPoint.X, LPoint.Y);
  finally
    FOverflowPressed := False;
    FOverflowHot := False;
    Invalidate;
    if Assigned(FOnOverflowClosed) then FOnOverflowClosed(Self);
  end;
end;

function TCustomThemedMenuBar.HitTestCollection(const AItems: TThemedMenuBarItems; const APoint: TPoint): TThemedMenuBarItem;
var
  I: Integer;
begin
  for I := 0 to AItems.Count - 1 do
    if AItems[I].Visible and not AItems[I].FBounds.IsEmpty and PtInRect(AItems[I].FBounds, APoint) then Exit(AItems[I]);
  Result := nil;
end;

function TCustomThemedMenuBar.HitTest(const APoint: TPoint): TThemedMenuBarItem;
begin
  Result := HitTestCollection(FLeftItems, APoint);
  if Result <> nil then Exit;
  Result := HitTestCollection(FCenterItems, APoint);
  if Result <> nil then Exit;
  Result := HitTestCollection(FRightItems, APoint);
end;

function TCustomThemedMenuBar.FindFocusableEdge(const ALeftmost: Boolean): TThemedMenuBarItem;
var
  LBestX: Integer;
  procedure Scan(const AItems: TThemedMenuBarItems);
  var
    I, LX: Integer;
    LItem: TThemedMenuBarItem;
  begin
    for I := 0 to AItems.Count - 1 do
    begin
      LItem := AItems[I];
      if not LItem.Visible or not LItem.Enabled or not LItem.IsFocusable or LItem.FBounds.IsEmpty then Continue;
      LX := LItem.FBounds.Left;
      if (Result = nil) or (ALeftmost and (LX < LBestX)) or (not ALeftmost and (LX > LBestX)) then
      begin
        Result := LItem;
        LBestX := LX;
      end;
    end;
  end;
begin
  Result := nil;
  LBestX := 0;
  Scan(FLeftItems);
  Scan(FCenterItems);
  Scan(FRightItems);
end;

function TCustomThemedMenuBar.FindRelativeFocusable(const ACurrent: TThemedMenuBarItem; const ADirection: Integer): TThemedMenuBarItem;
var
  LCurrentX, LBestDistance, LDistance: Integer;
  procedure Scan(const AItems: TThemedMenuBarItems);
  var
    I, LX: Integer;
    LItem: TThemedMenuBarItem;
  begin
    for I := 0 to AItems.Count - 1 do
    begin
      LItem := AItems[I];
      if (LItem = ACurrent) or not LItem.Visible or not LItem.Enabled or not LItem.IsFocusable or LItem.FBounds.IsEmpty then Continue;
      LX := LItem.FBounds.Left;
      if ((ADirection < 0) and (LX < LCurrentX)) or ((ADirection > 0) and (LX > LCurrentX)) then
      begin
        LDistance := Abs(LX - LCurrentX);
        if (Result = nil) or (LDistance < LBestDistance) then
        begin
          Result := LItem;
          LBestDistance := LDistance;
        end;
      end;
    end;
  end;
begin
  if ACurrent = nil then
  begin
    Result := FindFocusableEdge(ADirection > 0);
    Exit;
  end;
  Result := nil;
  LCurrentX := ACurrent.FBounds.Left;
  LBestDistance := MaxInt;
  Scan(FLeftItems);
  Scan(FCenterItems);
  Scan(FRightItems);
  if (Result = nil) and FWrapKeyboardNavigation then Result := FindFocusableEdge(ADirection > 0);
end;

procedure TCustomThemedMenuBar.SetFocusedItem(const AItem: TThemedMenuBarItem);
begin
  if FFocusedItem <> AItem then
  begin
    FFocusedItem := AItem;
    Invalidate;
  end;
  if (AItem <> nil) and AItem.IsInput and (AItem.FHostedControl <> nil) and AItem.FHostedControl.CanFocus and not AItem.FHostedControl.Focused then
    AItem.FHostedControl.SetFocus;
end;

procedure TCustomThemedMenuBar.MoveFocus(const ADirection: Integer);
begin
  SetFocusedItem(FindRelativeFocusable(FFocusedItem, ADirection));
end;

procedure TCustomThemedMenuBar.ShowItemMenu(const AItem: TThemedMenuBarItem);
var
  LPoint: TPoint;
  LItem, LClosedItem: TThemedMenuBarItem;
begin
  if (AItem = nil) or not AItem.Enabled or (AItem.DropDownMenu = nil) then Exit;
  LItem := AItem;
  while LItem <> nil do
  begin
    FPendingOpenItem := nil;
    FOpenItem := LItem;
    FPressedItem := nil;
    SetFocusedItem(LItem);
    if Assigned(FOnMenuOpening) then FOnMenuOpening(Self, LItem);
    if FOpenItem <> LItem then
    begin
      LItem := nil;
      Continue;
    end;
    if LItem.DropDownMenu = nil then
    begin
      FOpenItem := nil;
      Break;
    end;
    Invalidate;
    Update;
    if IsOverflowed(LItem) and not FOverflowBounds.IsEmpty then
    begin
      if BiDiMode = bdRightToLeft then LPoint := ClientToScreen(Point(FOverflowBounds.Right, FOverflowBounds.Bottom))
      else LPoint := ClientToScreen(Point(FOverflowBounds.Left, FOverflowBounds.Bottom));
    end
    else if BiDiMode = bdRightToLeft then
      LPoint := ClientToScreen(Point(LItem.FBounds.Right, LItem.FBounds.Bottom))
    else
      LPoint := ClientToScreen(Point(LItem.FBounds.Left, LItem.FBounds.Bottom));
    SetTimer(Handle, CMenuSwitchTimerId, CMenuSwitchTimerInterval, nil);
    LClosedItem := LItem;
    try
      LItem.DropDownMenu.Popup(LPoint.X, LPoint.Y);
    finally
      KillTimer(Handle, CMenuSwitchTimerId);
      if FOpenItem <> LClosedItem then LClosedItem := nil;
      FOpenItem := nil;
      if Assigned(FOnMenuClosed) then FOnMenuClosed(Self, LClosedItem);
      Invalidate;
    end;
    LItem := FPendingOpenItem;
  end;
  FPendingOpenItem := nil;
end;

procedure TCustomThemedMenuBar.ExecuteItem(const AItem: TThemedMenuBarItem);
begin
  if (AItem = nil) or not Enabled or not AItem.Enabled or not AItem.Visible or not AItem.IsInteractive then Exit;
  SetFocusedItem(AItem);
  if AItem.Checkable or (AItem.Kind = tmbikToggleButton) then AItem.Checked := not AItem.Checked;
  AItem.Click;
  if Assigned(FOnItemClick) then FOnItemClick(Self, AItem);
  if AItem.HasDropDown then ShowItemMenu(AItem);
end;

function TCustomThemedMenuBar.HandleMenuKey(const AKey: Word): Boolean;
begin
  Result := True;
  case AKey of
    VK_LEFT: MoveFocus(-1);
    VK_RIGHT: MoveFocus(1);
    VK_HOME: FocusFirstItem;
    VK_END: FocusLastItem;
    VK_DOWN, VK_RETURN, VK_SPACE:
      begin
        if FFocusedItem = nil then FocusFirstItem;
        if (FFocusedItem = nil) and (FOverflowItems.Count > 0) then ShowOverflowMenu
        else ExecuteItem(FFocusedItem);
      end;
    VK_ESCAPE:
      begin
        FPressedItem := nil;
        FHotItem := nil;
        Invalidate;
      end;
  else
    Result := False;
  end;
end;

procedure TCustomThemedMenuBar.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if MouseCapture or (FOpenItem <> nil) then Exit;
  if (FHotItem <> nil) or FOverflowHot then
  begin
    FHotItem := nil;
    FOverflowHot := False;
    Invalidate;
  end;
end;

procedure TCustomThemedMenuBar.CMDialogChar(var Message: TCMDialogChar);
var
  LItem: TThemedMenuBarItem;
  function FindAccel(const AItems: TThemedMenuBarItems): TThemedMenuBarItem;
  var
    J: Integer;
  begin
    Result := nil;
    for J := 0 to AItems.Count - 1 do
      if AItems[J].Visible and AItems[J].Enabled and AItems[J].IsInteractive and Vcl.Forms.IsAccel(Message.CharCode, AItems[J].Caption) then Exit(AItems[J]);
  end;
begin
  if Enabled then
  begin
    LItem := FindAccel(FLeftItems);
    if LItem = nil then LItem := FindAccel(FCenterItems);
    if LItem = nil then LItem := FindAccel(FRightItems);
    if LItem <> nil then
    begin
      if CanFocus then SetFocus;
      ExecuteItem(LItem);
      Message.Result := 1;
      Exit;
    end;
  end;
  inherited;
end;

procedure TCustomThemedMenuBar.CMDialogKey(var Message: TCMDialogKey);
begin
  if Enabled and Focused and HandleMenuKey(Message.CharCode) then
  begin
    Message.Result := 1;
    Exit;
  end;
  inherited;
end;

procedure TCustomThemedMenuBar.CMBiDiModeChanged(var Message: TMessage);
begin
  inherited;
  LayoutItems;
  Invalidate;
end;

procedure TCustomThemedMenuBar.CMFontChanged(var Message: TMessage);
begin
  inherited;
  if FInitialized then
  begin
    LayoutItems;
    if AutoSize then AdjustSize;
  end;
end;

procedure TCustomThemedMenuBar.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  SyncHostedControls;
  if not Enabled then
  begin
    FHotItem := nil;
    FPressedItem := nil;
    FOverflowHot := False;
    FOverflowPressed := False;
    FOpenItem := nil;
    FPendingOpenItem := nil;
    if HandleAllocated then KillTimer(Handle, CMenuSwitchTimerId);
  end;
  Invalidate;
end;

procedure TCustomThemedMenuBar.CMCancelMode(var Message: TCMCancelMode);
begin
  inherited;
  if Message.Sender = Self then Exit;
  if (FPressedItem <> nil) or FOverflowPressed then
  begin
    FPressedItem := nil;
    FOverflowPressed := False;
    Invalidate;
  end;
end;

procedure TCustomThemedMenuBar.WMTimer(var Message: TMessage);
var
  LScreenPoint, LClientPoint: TPoint;
  LItem: TThemedMenuBarItem;
begin
  if Message.WParam <> CMenuSwitchTimerId then
  begin
    DefaultHandler(Message);
    Exit;
  end;
  if (FOpenItem = nil) or (FPendingOpenItem <> nil) then Exit;
  if not GetCursorPos(LScreenPoint) then Exit;
  LClientPoint := ScreenToClient(LScreenPoint);
  if not PtInRect(ClientRect, LClientPoint) then Exit;
  LItem := HitTest(LClientPoint);
  if (LItem = nil) or (LItem = FOpenItem) or not LItem.Enabled or not LItem.IsInteractive or not LItem.HasDropDown then Exit;
  FPendingOpenItem := LItem;
  FHotItem := LItem;
  FFocusedItem := LItem;
  Invalidate;
  if FOpenItem.DropDownMenu <> nil then FOpenItem.DropDownMenu.CloseMenu;
end;

function TCustomThemedMenuBar.CanAutoSize(var NewWidth, NewHeight: Integer): Boolean;
begin
  if not FInitialized then
  begin
    Result := inherited CanAutoSize(NewWidth, NewHeight);
    Exit;
  end;
  Result := True;
  NewHeight := ScaleValue(FItemHeight + 2);
end;

procedure TCustomThemedMenuBar.Notification(AComponent: TComponent; Operation: TOperation);
  procedure Scan(const AItems: TThemedMenuBarItems);
  var
    J: Integer;
  begin
    if AItems = nil then Exit;
    for J := 0 to AItems.Count - 1 do
      if AItems[J].FDropDownMenu = AComponent then
      begin
        AItems[J].FDropDownMenu := nil;
        AItems[J].Changed(False);
      end;
  end;
begin
  inherited Notification(AComponent, Operation);
  if Operation <> opRemove then Exit;
  if AComponent = FImages then SetImages(nil);
  Scan(FLeftItems);
  Scan(FCenterItems);
  Scan(FRightItems);
end;

procedure TCustomThemedMenuBar.Loaded;
begin
  inherited Loaded;
  RefreshAllImages;
  SyncHostedControls;
  LayoutItems;
  if AutoSize then AdjustSize;
end;

procedure TCustomThemedMenuBar.Paint;
var
  LBarContext: TThemedMenuBarRenderContext;
  procedure DrawItems(const AItems: TThemedMenuBarItems);
  var
    I: Integer;
    LItem: TThemedMenuBarItem;
    LContext: TThemedMenuBarItemRenderContext;
  begin
    for I := 0 to AItems.Count - 1 do
    begin
      LItem := AItems[I];
      if not LItem.Visible or LItem.FBounds.IsEmpty then Continue;
      LContext := System.Default(TThemedMenuBarItemRenderContext);
      LContext.Bounds := LItem.FBounds;
      LContext.Caption := LItem.Caption;
      LContext.Font := Font;
      LContext.Palette := Palette;
      LContext.Kind := LItem.Kind;
      LContext.DisplayStyle := LItem.DisplayStyle;
      LContext.Appearance := LItem.Appearance;
      LContext.IconHandle := LItem.CurrentIconHandle;
      LContext.ImageSize := FImageSize;
      LContext.ImageTextSpacing := FImageTextSpacing;
      LContext.Enabled := Enabled and LItem.Enabled;
      LContext.Hot := LItem = FHotItem;
      LContext.Pressed := LItem = FPressedItem;
      LContext.Focused := Focused and (LItem = FFocusedItem);
      LContext.Opened := LItem = FOpenItem;
      LContext.Checked := LItem.Checked;
      LContext.ShowArrow := LItem.Kind = tmbikDropDown;
      LContext.RightToLeft := BiDiMode = bdRightToLeft;
      LContext.PaddingLeft := FItemPadding.Left;
      LContext.PaddingTop := FItemPadding.Top;
      LContext.PaddingRight := FItemPadding.Right;
      LContext.PaddingBottom := FItemPadding.Bottom;
      LContext.ArrowWidth := FArrowWidth;
      LContext.CornerRadius := FCornerRadius;
      LContext.PPI := CurrentPPI;
      TThemedMenuBarRenderer.RenderItem(RenderCanvas, LContext);
    end;
  end;
begin
  RenderCanvas.BeginRender(Canvas);
  try
    LBarContext := System.Default(TThemedMenuBarRenderContext);
    LBarContext.Bounds := ClientRect;
    LBarContext.OverflowBounds := FOverflowBounds;
    LBarContext.Palette := Palette;
    LBarContext.ShowBottomBorder := FShowBottomBorder;
    LBarContext.ShowOverflowButton := FOverflowItems.Count > 0;
    LBarContext.OverflowHot := FOverflowHot;
    LBarContext.OverflowPressed := FOverflowPressed;
    LBarContext.RightToLeft := BiDiMode = bdRightToLeft;
    LBarContext.Enabled := Enabled;
    LBarContext.CornerRadius := FCornerRadius;
    LBarContext.PPI := CurrentPPI;
    TThemedMenuBarRenderer.RenderBackground(RenderCanvas, LBarContext);
    DrawItems(FLeftItems);
    DrawItems(FCenterItems);
    DrawItems(FRightItems);
  finally
    RenderCanvas.EndRender;
  end;
end;

procedure TCustomThemedMenuBar.Resize;
begin
  inherited Resize;
  LayoutItems;
end;

procedure TCustomThemedMenuBar.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited ChangeScale(M, D, isDpiChange);
  LayoutItems;
  if AutoSize then AdjustSize;
end;

procedure TCustomThemedMenuBar.DoEnter;
begin
  inherited DoEnter;
  if FFocusedItem = nil then FocusFirstItem else Invalidate;
end;

procedure TCustomThemedMenuBar.DoExit;
begin
  inherited DoExit;
  FPressedItem := nil;
  FOverflowPressed := False;
  Invalidate;
end;

procedure TCustomThemedMenuBar.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LItem: TThemedMenuBarItem;
  LOverflowHot: Boolean;
begin
  inherited MouseMove(Shift, X, Y);
  LOverflowHot := Enabled and (FOverflowItems.Count > 0) and PtInRect(FOverflowBounds, Point(X, Y));
  if FOverflowHot <> LOverflowHot then
  begin
    FOverflowHot := LOverflowHot;
    Invalidate;
  end;
  if LOverflowHot then LItem := nil else LItem := HitTest(Point(X, Y));
  if (LItem <> nil) and (not LItem.Enabled or not LItem.IsInteractive) then LItem := nil;
  if FHotItem <> LItem then
  begin
    FHotItem := LItem;
    if Focused and (LItem <> nil) then FFocusedItem := LItem;
    Invalidate;
  end;
end;

procedure TCustomThemedMenuBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LItem: TThemedMenuBarItem;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button <> mbLeft) or not Enabled then Exit;
  if (FOverflowItems.Count > 0) and PtInRect(FOverflowBounds, Point(X, Y)) then
  begin
    if CanFocus then SetFocus;
    FPressedItem := nil;
    FOverflowPressed := True;
    Invalidate;
    Exit;
  end;
  LItem := HitTest(Point(X, Y));
  if (LItem = nil) or not LItem.Enabled or not LItem.IsInteractive then Exit;
  if CanFocus then SetFocus;
  FOverflowPressed := False;
  FPressedItem := LItem;
  FFocusedItem := LItem;
  Invalidate;
end;

procedure TCustomThemedMenuBar.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LPressed, LItem: TThemedMenuBarItem;
  LOverflowPressed, LOverflowInside: Boolean;
begin
  inherited MouseUp(Button, Shift, X, Y);
  if Button <> mbLeft then Exit;
  LPressed := FPressedItem;
  LOverflowPressed := FOverflowPressed;
  LOverflowInside := (FOverflowItems.Count > 0) and PtInRect(FOverflowBounds, Point(X, Y));
  if LOverflowInside then LItem := nil else LItem := HitTest(Point(X, Y));
  FPressedItem := nil;
  FOverflowPressed := False;
  Invalidate;
  if LOverflowPressed and LOverflowInside then
    ShowOverflowMenu
  else if (LPressed <> nil) and (LPressed = LItem) then
    ExecuteItem(LPressed);
end;

procedure TCustomThemedMenuBar.RealignItems;
begin
  LayoutItems;
  Invalidate;
end;

procedure TCustomThemedMenuBar.FocusFirstItem;
begin
  SetFocusedItem(FindFocusableEdge(True));
end;

procedure TCustomThemedMenuBar.FocusLastItem;
begin
  SetFocusedItem(FindFocusableEdge(False));
end;

end.

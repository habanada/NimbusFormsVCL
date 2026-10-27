{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.PropertyGrid;

interface

uses
  Winapi.Messages,
  System.Classes,
  System.SysUtils,
  System.Types,
  System.TypInfo,
  System.Variants,
  System.Generics.Collections,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Graphics,
  Vcl.ImgList,
  Vcl.Dialogs,
  Vcl.FileCtrl,
  Vcl.Forms,
  Vcl.Clipbrd,
  Vcl.ActnList,
  Vcl.ExtDlgs,
  Vcl.Menus,
  NimbusForms.Controls.Base,
  NimbusForms.Controls.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.Controls.VScrollBar,
  NimbusForms.Controls.ComboBox,
  NimbusForms.Controls.NumericUpDown,
  NimbusForms.Controls.ToolButton,
  NimbusForms.Controls.IdeColorPicker,
  NimbusForms.Controls.DatePicker,
  NimbusForms.Controls.PropertyGrid.Dialogs,
  NimbusForms.Controls.ToolTip,
  NimbusForms.Controls.PropertyGrid.Types,
  NimbusForms.Controls.PropertyGrid.Adapters,
  NimbusForms.Menus.PopupMenu,
  NimbusForms.Rendering.PropertyGrid;

type
  TThemedPropertyGridEditorEvent = procedure(Sender: TObject; AItem: TThemedPropertyGridItem; var AHandled: Boolean) of object;
  TThemedPropertyGridItemEvent = procedure(Sender: TObject; AItem: TThemedPropertyGridItem) of object;
  TThemedPropertyGridEditFinishedEvent = procedure(Sender: TObject; AItem: TThemedPropertyGridItem; ACommitted: Boolean) of object;
  TThemedPropertyGridExpandEvent = procedure(Sender: TObject; AItem: TThemedPropertyGridItem; AExpanded: Boolean) of object;
  TThemedPropertyGridCategoryExpandEvent = procedure(Sender: TObject; const ACategory: string; AExpanded: Boolean) of object;

  TCustomThemedPropertyGrid = class(TCustomNimbusControl)
  private
    FTargets: TArray<TPersistent>;
    FItems: TObjectList<TThemedPropertyGridItem>;
    FRows: TObjectList<TThemedPropertyGridRow>;
    FVirtualProperties: TObjectList<TThemedPropertyGridVirtualProperty>;
    FOriginalValues: TDictionary<string, TArray<Variant>>;
    FOriginalExpressions: TDictionary<string, string>;
    FFavorites: TDictionary<string, Boolean>;
    FExpanded: TDictionary<string, Boolean>;
    FExpressions: TDictionary<string, string>;
    FEditorsByPath: TDictionary<string, TThemedPropertyGridEditorEvent>;
    FEditorsByType: TDictionary<string, TThemedPropertyGridEditorEvent>;
    FEditorsByKind: TDictionary<Integer, TThemedPropertyGridEditorEvent>;
    FMetadataByPath, FMetadataByType: TObjectDictionary<string, TThemedPropertyGridMetadata>;
    FUndoStack: TObjectList<TThemedPropertyGridChange>;
    FRedoStack: TObjectList<TThemedPropertyGridChange>;
    FSearch: TEdit;
    FViewCategory, FViewAlphabetical, FViewFavorites, FViewModified: TThemedToolButton;
    FViewImages: TImageList;
    FEditor: TEdit;
    FEnumEditor: TThemedComboBox;
    FNumericEditor: TThemedNumericUpDown;
    FScrollBar: TThemedVScrollBar;
    FMenu: TThemedPopupMenu;
    FActions: TActionList;
    FResetAction, FCopyAction, FPasteAction, FFavoriteAction, FExpressionAction, FClearExpressionAction, FUndoAction, FRedoAction, FAcceptAction, FClearImageAction: TAction;
    FAddIndexedAction, FRemoveIndexedAction, FMoveIndexedUpAction, FMoveIndexedDownAction: TAction;
    FColorEditor: TThemedIdeColorPickerButton;
    FColorEditingItem: TThemedPropertyGridItem;
    FDateEditor: TThemedDatePicker;
    FDateEditingItem: TThemedPropertyGridItem;
    FOpenDialog: TOpenDialog;
    FPictureDialog: TOpenPictureDialog;
    FHeaderFont: TFont;
    FToolTip: TThemedToolTip;
    FSelected: TThemedPropertyGridItem;
    FSelectedCategory: string;
    FCategorySelected: Boolean;
    FEditingItem: TThemedPropertyGridItem;
    FEditOriginalValues: TArray<Variant>;
    FEditOriginalExpressionMode, FEditWasPreviewed: Boolean;
    FEditOriginalExpressionText: string;
    FSortMode: TThemedPropertyGridSortMode;
    FDescriptionMode: TThemedPropertyGridDescriptionMode;
    FFilterText: string;
    FShowSearch, FShowDescription, FShowFavoritesFirst, FShowViewToolbar, FShowFavoritesOnly, FShowModifiedOnly, FLivePreview, FShowNestedObjects, FExpressionModeEnabled: Boolean;
    FMaxNestedDepth, FMaxIndexedItems, FRowHeight, FCategoryHeight, FNameColumnWidth: Integer;
    FShowIndexedItems: Boolean;
    FHoveredRow: Integer;
    FResizingColumn: Boolean;
    FUpdatingEditors: Boolean;
    FOnPropertyValueChanged, FOnSelectedPropertyChanged: TNotifyEvent;
    FOnPropertyMetadata: TThemedPropertyGridMetadataEvent;
    FOnValidateValue: TThemedPropertyGridValidateEvent;
    FOnEditRequested: TThemedPropertyGridEditorEvent;
    FOnPropertyActivated, FOnEditStarted: TThemedPropertyGridItemEvent;
    FOnEditFinished: TThemedPropertyGridEditFinishedEvent;
    FOnPropertyExpandedChanged: TThemedPropertyGridExpandEvent;
    FOnCategoryExpandedChanged: TThemedPropertyGridCategoryExpandEvent;
    FOnNameColumnWidthChanged: TNotifyEvent;
    function InvokeCustomEditor(AItem: TThemedPropertyGridItem): Boolean;
    function ValidateCandidateValue(AItem: TThemedPropertyGridItem; const AValue: Variant; out AError: string): Boolean;
    function ValidateNumericInput(AItem: TThemedPropertyGridItem; const AValue: Variant; out AError: string): Boolean;
    function NumericBounds(AItem: TThemedPropertyGridItem; out AMinimum, AMaximum: Extended): Boolean;
    function NumericEditorEligible(AItem: TThemedPropertyGridItem): Boolean;
    procedure SetSelectedObject(const AValue: TPersistent);
    function GetSelectedObject: TPersistent;
    function GetSelectedObjects: TArray<TPersistent>;
    procedure SetSelectedObjectsArray(const AObjects: TArray<TPersistent>);
    procedure SetSortMode(const AValue: TThemedPropertyGridSortMode);
    procedure SetDescriptionMode(const AValue: TThemedPropertyGridDescriptionMode);
    procedure SetFilterText(const AValue: string);
    procedure SetShowSearch(const AValue: Boolean);
    procedure SetShowDescription(const AValue: Boolean);
    procedure SetShowFavoritesFirst(const AValue: Boolean);
    procedure SetShowViewToolbar(const AValue: Boolean);
    procedure SetShowFavoritesOnly(const AValue: Boolean);
    procedure SetShowModifiedOnly(const AValue: Boolean);
    procedure ViewButtonClick(Sender: TObject);
    procedure SyncViewButtons;
    procedure RefreshViewIcons;
    function ItemVisibleInView(AItem: TThemedPropertyGridItem): Boolean;
    procedure SetShowNestedObjects(const AValue: Boolean);
    procedure SetMaxNestedDepth(const AValue: Integer);
    procedure SetShowIndexedItems(const AValue: Boolean);
    procedure SetMaxIndexedItems(const AValue: Integer);
    function IndexedPathParent(const APath: string): string;
    function IndexedSource(AItem: TThemedPropertyGridItem; out ASource: TObject; out AKind: TThemedPropertyGridIndexedKind): Boolean;
    function SelectedIndexedSource(out AParent: TThemedPropertyGridItem; out ASource: TObject; out AKind: TThemedPropertyGridIndexedKind; out AIndex: Integer): Boolean;
    procedure ChangeIndexedStructure(AOperation: Integer);
    function ItemHasChildren(AItem: TThemedPropertyGridItem): Boolean;
    function ItemBranchVisible(AItem: TThemedPropertyGridItem): Boolean;
    function ItemIsExpanded(AItem: TThemedPropertyGridItem): Boolean;
    procedure AppendItemBranch(AItem: TThemedPropertyGridItem);
    procedure SetRowHeight(const AValue: Integer);
    procedure SetCategoryHeight(const AValue: Integer);
    procedure SetNameColumnWidth(const AValue: Integer);
    procedure SetupActions;
    function MakeAction(const ACaption: string; AShortcut: TShortCut): TAction;
    procedure HandleMenuAction(Sender: TObject);
    procedure UpdateMenuAction(Sender: TObject);
    procedure AddMenuItem(AAction: TAction);
    procedure AddMenuSeparator;
    procedure SearchChanged(Sender: TObject);
    procedure ScrollChanged(Sender: TObject);
    procedure EditChanged(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EnumChanged(Sender: TObject);
    procedure EnumClosed(Sender: TObject);
    procedure NumericChanged(Sender: TObject);
    procedure ColorPickerAccepted(Sender: TObject);
    procedure ColorPickerCancelled(Sender: TObject);
    procedure DatePickerConfirmed(Sender: TObject);
    procedure DatePickerClosed(Sender: TObject);
    procedure DismissDateEditor;
    procedure SelectDateEditor;
    procedure SelectColorEditor;
    procedure SelectImageEditor(const AClear: Boolean);
    function IsImageProperty: Boolean;
    procedure BuildProperties(const AObject: TPersistent; const APath: string; const ALevel: Integer);
    function PathSupportedByAll(const APath: string; const AInfo: PPropInfo): Boolean;
    function ResolveTargetObject(ATarget: TPersistent; const APath: string): TObject;
    function PropertyMatches(const AItem: TThemedPropertyGridItem): Boolean;
    procedure AddItem(const APath: string; AInfo: PPropInfo; AVirtual: TThemedPropertyGridVirtualProperty = nil; AIndexedKind: TThemedPropertyGridIndexedKind = pgikNone);
    procedure BuildRows;
    procedure LayoutChildren;
    procedure UpdateScrollRange;
    function RowsArea: TRect;
    function ViewToolbarArea: TRect;
    function DescriptionArea: TRect;
    function SearchArea: TRect;
    function RowBounds(const AIndex: Integer): TRect;
    function RowLayout(const AIndex: Integer): TThemedPropertyGridRowLayout;
    function HitRow(const X, Y: Integer): Integer;
    function GetSelectedProperty: TThemedPropertyGridItem;
    procedure SelectItem(AItem: TThemedPropertyGridItem);
    procedure SelectCategory(const ACategory: string);
    procedure SelectRow(const AIndex: Integer);
    function SelectedRowIndex: Integer;
    procedure EnsureRowVisible(const AIndex: Integer);
    procedure MoveSelection(const ADelta: Integer);
    procedure SelectEdge(AFirst: Boolean);
    procedure NavigateBranch(AExpand: Boolean);
    procedure WMGetDlgCode(var Message: TMessage); message WM_GETDLGCODE;
    procedure EnsureVisible(AItem: TThemedPropertyGridItem);
    procedure StopEditing(const ACommit: Boolean);
    procedure StartEditing;
    function IsBooleanEditorItem(AItem: TThemedPropertyGridItem; const AValues: TArray<Variant>): Boolean;
    function EditValuesEqual(const ALeft, ARight: TArray<Variant>): Boolean;
    function PreviewEditValue(AItem: TThemedPropertyGridItem; const AValue: Variant; AMarkPreview: Boolean = True): Boolean;
    procedure RestoreEditState(AItem: TThemedPropertyGridItem; const AValues: TArray<Variant>; AExpressionMode: Boolean; const AExpressionText: string);
    function ApplyValue(AItem: TThemedPropertyGridItem; const AValue: Variant): Boolean;
    procedure PushChange(AItem: TThemedPropertyGridItem; const AOld: TArray<Variant>; AOldExpressionMode: Boolean = False; const AOldExpressionText: string = '');
    procedure RefreshItem(AItem: TThemedPropertyGridItem);
    procedure DoPropertyValueChanged;
    procedure SetExpression(const AExpression: string);
    function SelectedObjectValue: TObject;
    procedure SelectObjectEditor;
    procedure EditTextCollection(AStrings: TStrings);
    procedure EditObjectCollection(ACollection: TCollection);
    procedure EditFlags;
    procedure SelectFileEditor;
    procedure SelectFolderEditor;
    function IsFileProperty: Boolean;
    function IsFolderProperty: Boolean;
    function ValidatePathInput(AItem: TThemedPropertyGridItem; const AValue: Variant; out AError: string): Boolean;
    function IsColorProperty: Boolean;
    function IsDateProperty: Boolean;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMCaptureChanged(var Message: TMessage); message WM_CAPTURECHANGED;
  protected
    procedure Paint; override;
    procedure CreateWnd; override;
    procedure Resize; override;
    procedure Loaded; override;
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: NimbusForms.Theming.Palette.TThemePalette); override;
    procedure SetSelectedObjects(const AObjects: array of TPersistent);
    procedure Rebuild;
    function AddVirtualProperty(const AName: string; AGetter: TThemedPropertyGridGetVirtualEvent; ASetter: TThemedPropertyGridSetVirtualEvent): TThemedPropertyGridVirtualProperty;
    function RemoveVirtualProperty(const AName: string): Boolean;
    procedure ClearVirtualProperties;
    procedure ResetSelectedProperty;
    function CanResetSelectedProperty: Boolean;
    function ValidateSelectedPropertyValue(const AValue: Variant; out AError: string): Boolean;
    procedure CopySelectedValue;
    procedure PasteSelectedValue;
    procedure Undo;
    procedure Redo;
    procedure AcceptChanges;
    procedure RegisterPropertyEditor(const APath: string; AHandler: TThemedPropertyGridEditorEvent);
    procedure RegisterTypeEditor(const ATypeName: string; AHandler: TThemedPropertyGridEditorEvent);
    procedure UnregisterPropertyEditor(const APath: string);
    procedure UnregisterTypeEditor(const ATypeName: string);
    procedure ClearRegisteredEditors;
    procedure RegisterKindEditor(AKind: TTypeKind; AHandler: TThemedPropertyGridEditorEvent);
    procedure UnregisterKindEditor(AKind: TTypeKind);
    function ConfigureProperty(const APath: string): TThemedPropertyGridMetadata;
    function ConfigureType(const ATypeName: string): TThemedPropertyGridMetadata;
    procedure ClearMetadata;
    function SetSelectedPropertyValue(const AValue: Variant): Boolean;
    function ExportJson: string;
    function ExportXml: string;
    property SelectedProperty: TThemedPropertyGridItem read GetSelectedProperty;
    property SelectedCategory: string read FSelectedCategory;
    property CategorySelected: Boolean read FCategorySelected;
    property SelectedObject: TPersistent read GetSelectedObject write SetSelectedObject;
    property SelectedObjects: TArray<TPersistent> read GetSelectedObjects write SetSelectedObjectsArray;
    property FilterText: string read FFilterText write SetFilterText;
    property VirtualProperties: TObjectList<TThemedPropertyGridVirtualProperty> read FVirtualProperties;
    property ContextMenu: TThemedPopupMenu read FMenu;
  published
    property SortMode: TThemedPropertyGridSortMode read FSortMode write SetSortMode default pgsCategory;
    property DescriptionMode: TThemedPropertyGridDescriptionMode read FDescriptionMode write SetDescriptionMode default pgdBottom;
    property ShowSearch: Boolean read FShowSearch write SetShowSearch default True;
    property ShowViewToolbar: Boolean read FShowViewToolbar write SetShowViewToolbar default True;
    property ShowFavoritesOnly: Boolean read FShowFavoritesOnly write SetShowFavoritesOnly default False;
    property ShowModifiedOnly: Boolean read FShowModifiedOnly write SetShowModifiedOnly default False;
    property ShowDescription: Boolean read FShowDescription write SetShowDescription default True;
    property ShowFavoritesFirst: Boolean read FShowFavoritesFirst write SetShowFavoritesFirst default True;
    property LivePreview: Boolean read FLivePreview write FLivePreview default True;
    property ShowNestedObjects: Boolean read FShowNestedObjects write SetShowNestedObjects default True;
    property ExpressionModeEnabled: Boolean read FExpressionModeEnabled write FExpressionModeEnabled default True;
    property MaxNestedDepth: Integer read FMaxNestedDepth write SetMaxNestedDepth default 2;
    property ShowIndexedItems: Boolean read FShowIndexedItems write SetShowIndexedItems default True;
    property MaxIndexedItems: Integer read FMaxIndexedItems write SetMaxIndexedItems default 256;
    property RowHeight: Integer read FRowHeight write SetRowHeight default 21;
    property CategoryHeight: Integer read FCategoryHeight write SetCategoryHeight default 21;
    property NameColumnWidth: Integer read FNameColumnWidth write SetNameColumnWidth default 160;
    property OnPropertyValueChanged: TNotifyEvent read FOnPropertyValueChanged write FOnPropertyValueChanged;
    property OnSelectedPropertyChanged: TNotifyEvent read FOnSelectedPropertyChanged write FOnSelectedPropertyChanged;
    property OnPropertyMetadata: TThemedPropertyGridMetadataEvent read FOnPropertyMetadata write FOnPropertyMetadata;
    property OnValidateValue: TThemedPropertyGridValidateEvent read FOnValidateValue write FOnValidateValue;
    property OnEditRequested: TThemedPropertyGridEditorEvent read FOnEditRequested write FOnEditRequested;
    property OnPropertyActivated: TThemedPropertyGridItemEvent read FOnPropertyActivated write FOnPropertyActivated;
    property OnEditStarted: TThemedPropertyGridItemEvent read FOnEditStarted write FOnEditStarted;
    property OnEditFinished: TThemedPropertyGridEditFinishedEvent read FOnEditFinished write FOnEditFinished;
    property OnPropertyExpandedChanged: TThemedPropertyGridExpandEvent read FOnPropertyExpandedChanged write FOnPropertyExpandedChanged;
    property OnCategoryExpandedChanged: TThemedPropertyGridCategoryExpandEvent read FOnCategoryExpandedChanged write FOnCategoryExpandedChanged;
    property OnNameColumnWidthChanged: TNotifyEvent read FOnNameColumnWidthChanged write FOnNameColumnWidthChanged;
    property Align;
    property Anchors;
    property BiDiMode;
    property Color;
    property Enabled;
    property Font;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

  TThemedPropertyGrid = class(TCustomThemedPropertyGrid);

implementation

uses
  Winapi.Windows,
  System.Math,
  System.StrUtils,
  System.DateUtils,
  System.JSON,
  System.UITypes,
  Vcl.ExtCtrls,
  Vcl.Imaging.pngimage,
  Vcl.Imaging.jpeg,
  Vcl.Imaging.GIFImg,
  NimbusForms.Theming.Types,
  NimbusForms.Rendering.Types,
  NimbusForms.Controls.KeyboardEdit;

constructor TCustomThemedPropertyGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 420;
  Height := 520;
  Font.Name := 'Segoe UI';
  Font.Size := 9;
  TabStop := True;
  FItems := TObjectList<TThemedPropertyGridItem>.Create(True);
  FRows := TObjectList<TThemedPropertyGridRow>.Create(True);
  FVirtualProperties := TObjectList<TThemedPropertyGridVirtualProperty>.Create(True);
  FOriginalValues := TDictionary<string, TArray<Variant>>.Create;
  FOriginalExpressions := TDictionary<string, string>.Create;
  FFavorites := TDictionary<string, Boolean>.Create;
  FExpanded := TDictionary<string, Boolean>.Create;
  FExpressions := TDictionary<string, string>.Create;
  FEditorsByPath := TDictionary<string, TThemedPropertyGridEditorEvent>.Create;
  FEditorsByType := TDictionary<string, TThemedPropertyGridEditorEvent>.Create;
  FEditorsByKind := TDictionary<Integer, TThemedPropertyGridEditorEvent>.Create;
  FMetadataByPath := TObjectDictionary<string, TThemedPropertyGridMetadata>.Create([doOwnsValues]);
  FMetadataByType := TObjectDictionary<string, TThemedPropertyGridMetadata>.Create([doOwnsValues]);
  FUndoStack := TObjectList<TThemedPropertyGridChange>.Create(True);
  FRedoStack := TObjectList<TThemedPropertyGridChange>.Create(True);
  FHeaderFont := TFont.Create;
  FHeaderFont.Assign(Font);
  FHeaderFont.Style := FHeaderFont.Style + [fsBold];
  FSortMode := pgsCategory;
  FDescriptionMode := pgdBottom;
  FShowSearch := True;
  FShowViewToolbar := True;
  FShowDescription := True;
  FShowFavoritesFirst := True;
  FLivePreview := True;
  FShowNestedObjects := True;
  FExpressionModeEnabled := True;
  FMaxNestedDepth := 2;
  FShowIndexedItems := True;
  FMaxIndexedItems := 256;
  FRowHeight := 21;
  FCategoryHeight := 21;
  FNameColumnWidth := 160;
  FHoveredRow := -1;
  FViewCategory := TThemedToolButton.Create(Self);
  FViewCategory.Parent := Self;
  FViewCategory.Caption := '';
  FViewCategory.Checkable := True;
  FViewCategory.ButtonStyle := ttbsGhost;
  FViewCategory.OnClick := ViewButtonClick;
  FViewAlphabetical := TThemedToolButton.Create(Self);
  FViewAlphabetical.Parent := Self;
  FViewAlphabetical.Caption := '';
  FViewAlphabetical.Checkable := True;
  FViewAlphabetical.ButtonStyle := ttbsGhost;
  FViewAlphabetical.OnClick := ViewButtonClick;
  FViewFavorites := TThemedToolButton.Create(Self);
  FViewFavorites.Parent := Self;
  FViewFavorites.Caption := '';
  FViewFavorites.Checkable := True;
  FViewFavorites.ButtonStyle := ttbsGhost;
  FViewFavorites.OnClick := ViewButtonClick;
  FViewModified := TThemedToolButton.Create(Self);
  FViewModified.Parent := Self;
  FViewModified.Caption := '';
  FViewModified.Checkable := True;
  FViewModified.ButtonStyle := ttbsGhost;
  FViewModified.OnClick := ViewButtonClick;
  FViewImages := TImageList.Create(Self);
  FViewImages.Width := 16;
  FViewImages.Height := 16;
  FViewImages.ColorDepth := cd24Bit;
  FViewImages.Masked := True;
  FViewCategory.Images := FViewImages;
  FViewAlphabetical.Images := FViewImages;
  FViewFavorites.Images := FViewImages;
  FViewModified.Images := FViewImages;
  FViewCategory.ImageIndex := 0;
  FViewAlphabetical.ImageIndex := 1;
  FViewFavorites.ImageIndex := 2;
  FViewModified.ImageIndex := 3;
  FViewCategory.ImageSize := 16;
  FViewAlphabetical.ImageSize := 16;
  FViewFavorites.ImageSize := 16;
  FViewModified.ImageSize := 16;
  FViewCategory.ContentPadding.SetBounds(0, 0, 0, 0);
  FViewAlphabetical.ContentPadding.SetBounds(0, 0, 0, 0);
  FViewFavorites.ContentPadding.SetBounds(0, 0, 0, 0);
  FViewModified.ContentPadding.SetBounds(0, 0, 0, 0);
  FViewCategory.CornerRadius := 2;
  FViewAlphabetical.CornerRadius := 2;
  FViewFavorites.CornerRadius := 2;
  FViewModified.CornerRadius := 2;
  RefreshViewIcons;
  SyncViewButtons;
  FSearch := TEdit.Create(Self);
  FSearch.Parent := Self;
  FSearch.BorderStyle := bsNone;
  FSearch.TextHint := 'Filter';
  FSearch.Font.Size := 8;
  FSearch.OnChange := SearchChanged;
  FSearch.OnKeyDown := SearchKeyDown;
  FEditor := TNimbusKeyboardEdit.Create(Self);
  FEditor.Parent := Self;
  FEditor.Visible := False;
  FEditor.OnChange := EditChanged;
  FEditor.OnKeyDown := EditKeyDown;
  FEditor.OnExit := EditExit;
  FEnumEditor := TThemedComboBox.Create(Self);
  FEnumEditor.Parent := Self;
  FEnumEditor.Visible := False;
  FEnumEditor.OnChange := EnumChanged;
  FEnumEditor.OnKeyDown := EditKeyDown;
  FEnumEditor.OnCloseUp := EnumClosed;
  FEnumEditor.OnExit := EditExit;
  FNumericEditor := TThemedNumericUpDown.Create(Self);
  FNumericEditor.Parent := Self;
  FNumericEditor.Visible := False;
  FNumericEditor.OnValueChanged := NumericChanged;
  FNumericEditor.NormalizeTextOnExit := False;
  FNumericEditor.OnKeyDown := EditKeyDown;
  FNumericEditor.OnExit := EditExit;
  FNumericEditor.Minimum := -1000000000000;
  FNumericEditor.Maximum := 1000000000000;
  FColorEditor := TThemedIdeColorPickerButton.Create(Self);
  FColorEditor.Parent := Self;
  FColorEditor.Visible := False;
  FColorEditor.ButtonText := 'Select color';
  FColorEditor.CommitMode := iccmOkCancel;
  FColorEditor.PaletteMode := icpmAll;
  FColorEditor.OnColorAccepted := ColorPickerAccepted;
  FColorEditor.OnColorCancelled := ColorPickerCancelled;
  FDateEditor := TThemedDatePicker.Create(Self);
  FDateEditor.Parent := Self;
  FDateEditor.Visible := False;
  FDateEditor.OnDateConfirmed := DatePickerConfirmed;
  FDateEditor.OnDropDownClosed := DatePickerClosed;
  FScrollBar := TThemedVScrollBar.Create(Self);
  FScrollBar.Parent := Self;
  FScrollBar.Visible := False;
  FScrollBar.OnValueChanged := ScrollChanged;
  FOpenDialog := TOpenDialog.Create(Self);
  FPictureDialog := TOpenPictureDialog.Create(Self);
  FToolTip := TThemedToolTip.Create(Self);
  FToolTip.SetToolTip(FViewCategory, 'Categorized', 'Group properties by category', ttiInfo);
  FToolTip.SetToolTip(FViewAlphabetical, 'Alphabetical', 'Sort properties alphabetically', ttiInfo);
  FToolTip.SetToolTip(FViewFavorites, 'Favorites', 'Show only pinned properties', ttiInfo);
  FToolTip.SetToolTip(FViewModified, 'Modified', 'Show only changed properties', ttiInfo);
  FMenu := TThemedPopupMenu.Create(Self);
  PopupMenu := FMenu;
  SetupActions;
end;

destructor TCustomThemedPropertyGrid.Destroy;
var
  LTarget: TPersistent;
begin
  FEditor.OnExit := nil;
  FEnumEditor.OnExit := nil;
  FNumericEditor.OnExit := nil;
  if FColorEditor <> nil then
  begin
    FColorEditor.OnColorAccepted := nil;
    FColorEditor.OnColorCancelled := nil;
    FColorEditor.CloseDropDown;
  end;
  if FDateEditor <> nil then
  begin
    FDateEditor.OnDateConfirmed := nil;
    FDateEditor.OnDropDownClosed := nil;
    FDateEditingItem := nil;
    FDateEditor.CloseDropDown;
  end;
  for LTarget in FTargets do
    if (LTarget is TComponent) and not (csDestroying in TComponent(LTarget).ComponentState) then TComponent(LTarget).RemoveFreeNotification(Self);
  FUndoStack.Free;
  FRedoStack.Free;
  FRows.Free;
  FItems.Free;
  FVirtualProperties.Free;
  FOriginalValues.Free;
  FOriginalExpressions.Free;
  FFavorites.Free;
  FExpanded.Free;
  FExpressions.Free;
  FEditorsByPath.Free;
  FEditorsByType.Free;
  FEditorsByKind.Free;
  FMetadataByPath.Free;
  FMetadataByType.Free;
  FHeaderFont.Free;
  inherited Destroy;
end;

procedure TCustomThemedPropertyGrid.ApplyTheme(const APalette: NimbusForms.Theming.Palette.TThemePalette);
begin
  inherited ApplyTheme(APalette);
  if FSearch <> nil then
  begin
    FSearch.Color := ThemeColorToColor(NimbusInputBackColor(Palette));
    FSearch.Font.Color := ThemeColorToColor(NimbusInputForeColor(Palette));
    FEditor.Color := ThemeColorToColor(NimbusInputBackColor(Palette));
    FEditor.Font.Color := ThemeColorToColor(NimbusInputForeColor(Palette));
    FEnumEditor.ApplyTheme(Palette);
    FNumericEditor.ApplyTheme(Palette);
    FToolTip.ApplyTheme(Palette);
    FMenu.ApplyTheme(Palette);
    FScrollBar.ApplyTheme(Palette);
    FColorEditor.ApplyTheme(Palette);
    FDateEditor.ApplyTheme(Palette);
    FViewCategory.ApplyTheme(Palette);
    FViewAlphabetical.ApplyTheme(Palette);
    FViewFavorites.ApplyTheme(Palette);
    FViewModified.ApplyTheme(Palette);
    RefreshViewIcons;
  end;
end;

procedure TCustomThemedPropertyGrid.Loaded;
begin
  inherited Loaded;
  UpdateScrollRange;
end;

procedure TCustomThemedPropertyGrid.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited ChangeScale(M, D, isDpiChange);
  if (FScrollBar <> nil) and not (csDestroying in ComponentState) then UpdateScrollRange;
end;

procedure TCustomThemedPropertyGrid.Notification(AComponent: TComponent; Operation: TOperation);
var
  I: Integer;
begin
  inherited Notification(AComponent, Operation);
  if (Operation <> opRemove) or (csDestroying in ComponentState) then Exit;
  for I := 0 to High(FTargets) do
    if FTargets[I] = AComponent then
    begin
      DismissDateEditor;
      FUpdatingEditors := True;
      try
        FEditor.Visible := False;
        FEnumEditor.Visible := False;
        FNumericEditor.Visible := False;
        FEditingItem := nil;
        FEditOriginalValues := nil;
        FEditWasPreviewed := False;
      finally
        FUpdatingEditors := False;
      end;
      SetSelectedObjects([]);
      Break;
    end;
end;

procedure TCustomThemedPropertyGrid.SetSelectedObject(const AValue: TPersistent);
begin
  if AValue = nil then SetSelectedObjects([]) else SetSelectedObjects([AValue]);
end;

function TCustomThemedPropertyGrid.GetSelectedObject: TPersistent;
begin
  if Length(FTargets) = 0 then Exit(nil);
  Result := FTargets[0];
end;

function TCustomThemedPropertyGrid.GetSelectedObjects: TArray<TPersistent>;
begin
  Result := Copy(FTargets);
end;

procedure TCustomThemedPropertyGrid.SetSelectedObjectsArray(const AObjects: TArray<TPersistent>);
begin
  SetSelectedObjects(AObjects);
end;

procedure TCustomThemedPropertyGrid.SetSelectedObjects(const AObjects: array of TPersistent);
var
  I: Integer;
  LTarget: TPersistent;
begin
  StopEditing(True);
  for LTarget in FTargets do
    if (LTarget is TComponent) and not (csDestroying in TComponent(LTarget).ComponentState) then TComponent(LTarget).RemoveFreeNotification(Self);
  SetLength(FTargets, 0);
  for I := 0 to High(AObjects) do
    if AObjects[I] <> nil then
    begin
      SetLength(FTargets, Length(FTargets) + 1);
      FTargets[High(FTargets)] := AObjects[I];
      if AObjects[I] is TComponent then TComponent(AObjects[I]).FreeNotification(Self);
    end;
  FOriginalValues.Clear;
  FOriginalExpressions.Clear;
  FExpressions.Clear;
  FUndoStack.Clear;
  FRedoStack.Clear;
  FSelected := nil;
  FSelectedCategory := '';
  FCategorySelected := False;
  FScrollBar.Value := 0;
  Rebuild;
end;

procedure TCustomThemedPropertyGrid.SetSortMode(const AValue: TThemedPropertyGridSortMode);
begin
  if FSortMode = AValue then Exit;
  FSortMode := AValue;
  SyncViewButtons;
  Rebuild;
end;

procedure TCustomThemedPropertyGrid.SetDescriptionMode(const AValue: TThemedPropertyGridDescriptionMode);
begin
  if FDescriptionMode = AValue then Exit;
  FDescriptionMode := AValue;
  UpdateScrollRange;
end;

procedure TCustomThemedPropertyGrid.SetFilterText(const AValue: string);
begin
  if FFilterText = AValue then Exit;
  FFilterText := AValue;
  if (FSearch <> nil) and (FSearch.Text <> AValue) then FSearch.Text := AValue;
  Rebuild;
end;

procedure TCustomThemedPropertyGrid.SetShowSearch(const AValue: Boolean);
begin
  if FShowSearch = AValue then Exit;
  FShowSearch := AValue;
  UpdateScrollRange;
end;

procedure TCustomThemedPropertyGrid.SetShowDescription(const AValue: Boolean);
begin
  if FShowDescription = AValue then Exit;
  FShowDescription := AValue;
  UpdateScrollRange;
end;

procedure TCustomThemedPropertyGrid.SetShowFavoritesFirst(const AValue: Boolean);
begin
  if FShowFavoritesFirst = AValue then Exit;
  FShowFavoritesFirst := AValue;
  BuildRows;
end;

procedure TCustomThemedPropertyGrid.SetShowViewToolbar(const AValue: Boolean);
begin
  if FShowViewToolbar = AValue then Exit;
  FShowViewToolbar := AValue;
  UpdateScrollRange;
end;

procedure TCustomThemedPropertyGrid.SetShowFavoritesOnly(const AValue: Boolean);
begin
  if FShowFavoritesOnly = AValue then Exit;
  StopEditing(True);
  FShowFavoritesOnly := AValue;
  SyncViewButtons;
  BuildRows;
end;

procedure TCustomThemedPropertyGrid.SetShowModifiedOnly(const AValue: Boolean);
begin
  if FShowModifiedOnly = AValue then Exit;
  StopEditing(True);
  FShowModifiedOnly := AValue;
  SyncViewButtons;
  BuildRows;
end;

procedure TCustomThemedPropertyGrid.ViewButtonClick(Sender: TObject);
begin
  if Sender = FViewCategory then SortMode := pgsCategory
  else if Sender = FViewAlphabetical then SortMode := pgsAlphabetical
  else if Sender = FViewFavorites then ShowFavoritesOnly := not FShowFavoritesOnly
  else if Sender = FViewModified then ShowModifiedOnly := not FShowModifiedOnly;
  SyncViewButtons;
end;

procedure TCustomThemedPropertyGrid.SyncViewButtons;
begin
  if FViewCategory = nil then Exit;
  FViewCategory.Checked := FSortMode = pgsCategory;
  FViewAlphabetical.Checked := FSortMode = pgsAlphabetical;
  FViewFavorites.Checked := FShowFavoritesOnly;
  FViewModified.Checked := FShowModifiedOnly;
end;

procedure TCustomThemedPropertyGrid.RefreshViewIcons;
var
  LBitmap: Vcl.Graphics.TBitmap;
  LFore: TColor;
  I: Integer;
begin
  if FViewImages = nil then Exit;
  LFore := ThemeColorToColor(NimbusControlForeColor(Palette));
  LBitmap := Vcl.Graphics.TBitmap.Create;
  try
    LBitmap.PixelFormat := pf24bit;
    LBitmap.SetSize(16, 16);
    FViewImages.Clear;
    for I := 0 to 3 do
    begin
      LBitmap.Canvas.Brush.Style := bsSolid;
      LBitmap.Canvas.Brush.Color := clFuchsia;
      LBitmap.Canvas.FillRect(Rect(0, 0, 16, 16));
      LBitmap.Canvas.Pen.Color := LFore;
      LBitmap.Canvas.Pen.Width := 1;
      LBitmap.Canvas.Brush.Style := bsClear;
      case I of
        0:
        begin
          LBitmap.Canvas.Rectangle(1, 2, 6, 7);
          LBitmap.Canvas.Rectangle(1, 9, 6, 14);
          LBitmap.Canvas.MoveTo(2, 4);
          LBitmap.Canvas.LineTo(5, 4);
          LBitmap.Canvas.MoveTo(2, 11);
          LBitmap.Canvas.LineTo(5, 11);
          LBitmap.Canvas.MoveTo(3, 10);
          LBitmap.Canvas.LineTo(3, 13);
          LBitmap.Canvas.MoveTo(8, 3);
          LBitmap.Canvas.LineTo(15, 3);
          LBitmap.Canvas.MoveTo(8, 5);
          LBitmap.Canvas.LineTo(14, 5);
          LBitmap.Canvas.MoveTo(8, 10);
          LBitmap.Canvas.LineTo(15, 10);
          LBitmap.Canvas.MoveTo(8, 12);
          LBitmap.Canvas.LineTo(14, 12);
        end;
        1:
        begin
          LBitmap.Canvas.MoveTo(1, 8);
          LBitmap.Canvas.LineTo(3, 2);
          LBitmap.Canvas.LineTo(5, 8);
          LBitmap.Canvas.MoveTo(2, 6);
          LBitmap.Canvas.LineTo(5, 6);
          LBitmap.Canvas.MoveTo(1, 10);
          LBitmap.Canvas.LineTo(6, 10);
          LBitmap.Canvas.LineTo(1, 14);
          LBitmap.Canvas.LineTo(6, 14);
          LBitmap.Canvas.MoveTo(12, 2);
          LBitmap.Canvas.LineTo(12, 13);
          LBitmap.Canvas.MoveTo(9, 10);
          LBitmap.Canvas.LineTo(12, 13);
          LBitmap.Canvas.LineTo(15, 10);
        end;
        2:
        begin
          LBitmap.Canvas.Polygon([Point(8, 1), Point(10, 6), Point(15, 6), Point(11, 9), Point(13, 14), Point(8, 11), Point(3, 14), Point(5, 9), Point(1, 6), Point(6, 6)]);
        end;
        3:
        begin
          LBitmap.Canvas.Rectangle(2, 1, 11, 14);
          LBitmap.Canvas.MoveTo(4, 4);
          LBitmap.Canvas.LineTo(9, 4);
          LBitmap.Canvas.MoveTo(4, 7);
          LBitmap.Canvas.LineTo(8, 7);
          LBitmap.Canvas.MoveTo(4, 10);
          LBitmap.Canvas.LineTo(6, 10);
          LBitmap.Canvas.MoveTo(11, 9);
          LBitmap.Canvas.LineTo(15, 5);
          LBitmap.Canvas.MoveTo(10, 11);
          LBitmap.Canvas.LineTo(14, 7);
        end;
      end;
      FViewImages.AddMasked(LBitmap, clFuchsia);
    end;
  finally
    LBitmap.Free;
  end;
end;


function TCustomThemedPropertyGrid.ItemVisibleInView(AItem: TThemedPropertyGridItem): Boolean;
begin
  Result := (AItem <> nil) and (not FShowFavoritesOnly or AItem.Favorite) and (not FShowModifiedOnly or AItem.Dirty or AItem.ExpressionMode);
end;

procedure TCustomThemedPropertyGrid.SetShowNestedObjects(const AValue: Boolean);
begin
  if FShowNestedObjects = AValue then Exit;
  FShowNestedObjects := AValue;
  Rebuild;
end;

procedure TCustomThemedPropertyGrid.SetMaxNestedDepth(const AValue: Integer);
begin
  if FMaxNestedDepth = EnsureRange(AValue, 0, 12) then Exit;
  FMaxNestedDepth := EnsureRange(AValue, 0, 12);
  Rebuild;
end;

procedure TCustomThemedPropertyGrid.SetShowIndexedItems(const AValue: Boolean);
begin
  if FShowIndexedItems = AValue then Exit;
  FShowIndexedItems := AValue;
  Rebuild;
end;

procedure TCustomThemedPropertyGrid.SetMaxIndexedItems(const AValue: Integer);
begin
  if FMaxIndexedItems = EnsureRange(AValue, 1, 4096) then Exit;
  FMaxIndexedItems := EnsureRange(AValue, 1, 4096);
  Rebuild;
end;

procedure TCustomThemedPropertyGrid.SetRowHeight(const AValue: Integer);
begin
  if FRowHeight = EnsureRange(AValue, 18, 64) then Exit;
  FRowHeight := EnsureRange(AValue, 18, 64);
  BuildRows;
end;

procedure TCustomThemedPropertyGrid.SetCategoryHeight(const AValue: Integer);
begin
  if FCategoryHeight = EnsureRange(AValue, 18, 64) then Exit;
  FCategoryHeight := EnsureRange(AValue, 18, 64);
  BuildRows;
end;

procedure TCustomThemedPropertyGrid.SetNameColumnWidth(const AValue: Integer);
begin
  if FNameColumnWidth = Max(80, AValue) then Exit;
  FNameColumnWidth := Max(80, AValue);
  LayoutChildren;
  if Assigned(FOnNameColumnWidthChanged) then FOnNameColumnWidthChanged(Self);
end;

procedure TCustomThemedPropertyGrid.SearchChanged(Sender: TObject);
begin
  SetFilterText(FSearch.Text);
end;

procedure TCustomThemedPropertyGrid.ScrollChanged(Sender: TObject);
begin
  StopEditing(True);
  Invalidate;
end;

procedure TCustomThemedPropertyGrid.CMFontChanged(var Message: TMessage);
begin
  inherited;
  if FHeaderFont <> nil then
  begin
    FHeaderFont.Assign(Font);
    FHeaderFont.Style := FHeaderFont.Style + [fsBold];
    if FSearch <> nil then
    begin
      FSearch.Font.Assign(Font);
      FSearch.Font.Size := Max(7, Font.Size - 1);
      FEditor.Font.Assign(Font);
      FEnumEditor.Font.Assign(Font);
      FNumericEditor.Font.Assign(Font);
      FDateEditor.Font.Assign(Font);
    end;
    LayoutChildren;
  end;
end;

procedure TCustomThemedPropertyGrid.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  FHoveredRow := -1;
  if not FResizingColumn then Cursor := crDefault;
  Invalidate;
end;

procedure TCustomThemedPropertyGrid.WMCaptureChanged(var Message: TMessage);
begin
  inherited;
  FResizingColumn := False;
end;

function TCustomThemedPropertyGrid.ResolveTargetObject(ATarget: TPersistent; const APath: string): TObject;
var
  LName, LPart, LProperty: string;
  LPosition, LBracket, LIndex: Integer;
  LInfo: PPropInfo;
begin
  Result := ATarget;
  LName := APath;
  while LName <> '' do
  begin
    LPosition := Pos('.', LName);
    if LPosition = 0 then Break;
    if Result = nil then Exit(nil);
    LPart := Copy(LName, 1, LPosition - 1);
    LBracket := Pos('[', LPart);
    if LBracket > 0 then LProperty := Copy(LPart, 1, LBracket - 1) else LProperty := LPart;
    LInfo := GetPropInfo(Result.ClassInfo, LProperty);
    if (LInfo = nil) or (LInfo.PropType^.Kind <> tkClass) then Exit(nil);
    Result := GetObjectProp(Result, LInfo);
    if LBracket > 0 then
    begin
      if (LPart[Length(LPart)] <> ']') or not TryStrToInt(Copy(LPart, LBracket + 1, Length(LPart) - LBracket - 1), LIndex) then Exit(nil);
      if Result is TCollection then
      begin
        if (LIndex < 0) or (LIndex >= TCollection(Result).Count) then Exit(nil);
        Result := TCollection(Result).Items[LIndex];
      end
      else
      begin
        var LAdapter := NimbusFindPropertyGridAdapter(Result);
        if (LAdapter = nil) or (LAdapter.Kind(Result) <> tkClass) or (LIndex < 0) or (LIndex >= LAdapter.Count(Result)) then Exit(nil);
        Result := LAdapter.ObjectAt(Result, LIndex);
      end;
    end;
    Delete(LName, 1, LPosition);
  end;
end;

function TCustomThemedPropertyGrid.PathSupportedByAll(const APath: string; const AInfo: PPropInfo): Boolean;
var
  I: Integer;
  LOwner: TObject;
  LInfo: PPropInfo;
  LName: string;
begin
  Result := False;
  LName := APath;
  I := LastDelimiter('.', LName);
  if I > 0 then Delete(LName, 1, I);
  for I := 0 to High(FTargets) do
  begin
    LOwner := ResolveTargetObject(FTargets[I], APath);
    if LOwner = nil then Exit;
    LInfo := GetPropInfo(LOwner.ClassInfo, LName);
    if (LInfo = nil) or (LInfo.PropType^.Kind <> AInfo.PropType^.Kind) or not SameText(string(LInfo.PropType^.Name), string(AInfo.PropType^.Name)) then Exit;
  end;
  Result := True;
end;

function TCustomThemedPropertyGrid.PropertyMatches(const AItem: TThemedPropertyGridItem): Boolean;
var
  LFilter: string;
begin
  LFilter := Trim(FFilterText);
  Result := (LFilter = '') or ContainsText(AItem.Path, LFilter) or ContainsText(AItem.DisplayName, LFilter) or ContainsText(AItem.Category, LFilter) or ContainsText(AItem.Description, LFilter);
end;

procedure TCustomThemedPropertyGrid.AddItem(const APath: string; AInfo: PPropInfo; AVirtual: TThemedPropertyGridVirtualProperty; AIndexedKind: TThemedPropertyGridIndexedKind);
var
  LItem: TThemedPropertyGridItem;
  LOriginal: TArray<Variant>;
  LExpression: string;
  LFlag, LVisible: Boolean;
  LName, LCategory, LDescription, LTypeName: string;
  LMeta: TThemedPropertyGridMetadata;
  LParentItem: TThemedPropertyGridItem;
  LAncestorPath: string;
begin
  LItem := TThemedPropertyGridItem.Create(FTargets, APath, AInfo, AVirtual, AIndexedKind);
  try
    LTypeName := '';
    if (AInfo <> nil) and (AInfo.PropType <> nil) then LTypeName := UpperCase(string(AInfo.PropType^.Name));
    if (LTypeName <> '') and FMetadataByType.TryGetValue(LTypeName, LMeta) then LMeta.ApplyTo(LItem);
    if FMetadataByPath.TryGetValue(UpperCase(APath), LMeta) then LMeta.ApplyTo(LItem);
    LAncestorPath := IndexedPathParent(APath);
    while LAncestorPath <> '' do
    begin
      for LParentItem in FItems do
        if (LParentItem.Path = LAncestorPath) and LParentItem.MetadataReadOnly then
        begin
          LItem.MetadataReadOnly := True;
          Break;
        end;
      LAncestorPath := IndexedPathParent(LAncestorPath);
    end;
    LName := LItem.DisplayName;
    LCategory := LItem.Category;
    LDescription := LItem.Description;
    LVisible := (AVirtual = nil) or AVirtual.IsBrowsable;
    if (LTypeName <> '') and FMetadataByType.TryGetValue(LTypeName, LMeta) and LMeta.HasBrowsable then LVisible := LMeta.Browsable;
    if FMetadataByPath.TryGetValue(UpperCase(APath), LMeta) and LMeta.HasBrowsable then LVisible := LMeta.Browsable;
    if Assigned(FOnPropertyMetadata) then FOnPropertyMetadata(Self, APath, LName, LCategory, LDescription, LVisible);
    if not LVisible then Exit;
    LItem.DisplayName := LName;
    LItem.Category := LCategory;
    LItem.Description := LDescription;
    if FOriginalValues.TryGetValue(APath, LOriginal) then
    begin
      LItem.OriginalValues := Copy(LOriginal);
      LItem.UpdateState;
    end
    else FOriginalValues.AddOrSetValue(APath, Copy(LItem.OriginalValues));
    if FFavorites.TryGetValue(APath, LFlag) then LItem.Favorite := LFlag;
    if FExpressions.TryGetValue(APath, LExpression) then
    begin
      LItem.ExpressionMode := True;
      LItem.ExpressionText := LExpression;
    end;
    if FOriginalExpressions.TryGetValue(APath, LExpression) then
    begin
      LItem.OriginalExpressionMode := True;
      LItem.OriginalExpressionText := LExpression;
    end;
    LItem.UpdateState;
    FItems.Add(LItem);
    LItem := nil;
  finally
    LItem.Free;
  end;
end;

procedure TCustomThemedPropertyGrid.BuildProperties(const AObject: TPersistent; const APath: string; const ALevel: Integer);
var
  LCount, I, J, K, LVisibleCount: Integer;
  LList: PPropList;
  LInfo, LOtherInfo: PPropInfo;
  LPath, LIndexPath: string;
  LChild, LOtherOwner, LOtherChild: TObject;
  LIndexedKind: TThemedPropertyGridIndexedKind;
  LVariant: Variant;
  LFirstIndex, LLastIndex: Integer;
begin
  if AObject = nil then Exit;
  LCount := GetPropList(AObject.ClassInfo, tkAny, nil);
  if LCount = 0 then Exit;
  GetMem(LList, LCount * SizeOf(Pointer));
  try
    GetPropList(AObject.ClassInfo, tkAny, LList);
    for I := 0 to LCount - 1 do
    begin
      LInfo := LList^[I];
      if not (LInfo.PropType^.Kind in [tkInteger, tkInt64, tkEnumeration, tkSet, tkFloat, tkString, tkLString, tkWString, tkUString, tkChar, tkWChar, tkClass, tkVariant]) then Continue;
      LPath := string(LInfo.Name);
      if APath <> '' then LPath := APath + '.' + LPath;
      if not PathSupportedByAll(LPath, LInfo) then Continue;
      AddItem(LPath, LInfo);
      if (FItems.Count = 0) or (FItems[FItems.Count - 1].Path <> LPath) then Continue;
      if not FShowNestedObjects or (ALevel >= FMaxNestedDepth) then Continue;
      if (LInfo.PropType^.Kind = tkVariant) and FShowIndexedItems then
      begin
        LVariant := GetVariantProp(AObject, LInfo);
        if not VarIsArray(LVariant) or (VarArrayDimCount(LVariant) <> 1) then Continue;
        LFirstIndex := VarArrayLowBound(LVariant, 1);
        LLastIndex := VarArrayHighBound(LVariant, 1);
        for J := 1 to High(FTargets) do
        begin
          LOtherOwner := ResolveTargetObject(FTargets[J], LPath);
          if LOtherOwner = nil then begin LLastIndex := LFirstIndex - 1; Break; end;
          LOtherInfo := GetPropInfo(LOtherOwner.ClassInfo, string(LInfo.Name));
          if (LOtherInfo = nil) or (LOtherInfo.PropType^.Kind <> tkVariant) then begin LLastIndex := LFirstIndex - 1; Break; end;
          LVariant := GetVariantProp(LOtherOwner, LOtherInfo);
          if not VarIsArray(LVariant) or (VarArrayDimCount(LVariant) <> 1) then begin LLastIndex := LFirstIndex - 1; Break; end;
          LFirstIndex := Max(LFirstIndex, VarArrayLowBound(LVariant, 1));
          LLastIndex := Min(LLastIndex, VarArrayHighBound(LVariant, 1));
        end;
        for K := LFirstIndex to Min(LLastIndex, LFirstIndex + FMaxIndexedItems - 1) do
          AddItem(LPath + '[' + IntToStr(K) + ']', nil, nil, pgikVariant);
        Continue;
      end;
      if LInfo.PropType^.Kind <> tkClass then Continue;
      LChild := GetObjectProp(AObject, LInfo);
      LIndexedKind := pgikNone;
      if LChild is TStrings then LIndexedKind := pgikString
      else if LChild is TCollection then LIndexedKind := pgikCollection
      else LIndexedKind := NimbusPropertyGridListKind(LChild);
      if (LIndexedKind = pgikNone) and (NimbusFindPropertyGridAdapter(LChild) <> nil) then LIndexedKind := pgikAdapter;
      if (LIndexedKind <> pgikNone) and FShowIndexedItems then
      begin
        LVisibleCount := NimbusPropertyGridIndexedCount(LChild, LIndexedKind);
        for J := 1 to High(FTargets) do
        begin
          LOtherOwner := ResolveTargetObject(FTargets[J], LPath);
          if LOtherOwner = nil then begin LVisibleCount := 0; Break; end;
          LOtherInfo := GetPropInfo(LOtherOwner.ClassInfo, string(LInfo.Name));
          if (LOtherInfo = nil) or (LOtherInfo.PropType^.Kind <> tkClass) then begin LVisibleCount := 0; Break; end;
          LOtherChild := GetObjectProp(LOtherOwner, LOtherInfo);
          if ((LIndexedKind in [pgikString, pgikCollection]) and (NimbusPropertyGridIndexedCount(LOtherChild, LIndexedKind) < 0)) or
            ((LIndexedKind in [pgikListText, pgikListInteger, pgikListInt64, pgikListFloat, pgikListBoolean]) and
            (NimbusPropertyGridListKind(LOtherChild) <> LIndexedKind)) or
            ((LIndexedKind = pgikAdapter) and ((NimbusFindPropertyGridAdapter(LOtherChild) = nil) or
            (NimbusFindPropertyGridAdapter(LOtherChild).ClassType <> NimbusFindPropertyGridAdapter(LChild).ClassType))) then begin LVisibleCount := 0; Break; end;
          LVisibleCount := Min(LVisibleCount, NimbusPropertyGridIndexedCount(LOtherChild, LIndexedKind));
        end;
        for K := 0 to Min(LVisibleCount, FMaxIndexedItems) - 1 do
        begin
          LIndexPath := LPath + '[' + IntToStr(K) + ']';
          AddItem(LIndexPath, nil, nil, LIndexedKind);
          if (ALevel + 1 < FMaxNestedDepth) then
          begin
            if LIndexedKind = pgikCollection then BuildProperties(TCollection(LChild).Items[K], LIndexPath, ALevel + 2)
            else if LIndexedKind = pgikAdapter then
            begin
              var LAdapter := NimbusFindPropertyGridAdapter(LChild);
              if (LAdapter <> nil) and (LAdapter.Kind(LChild) = tkClass) then
              begin
                var LElement := LAdapter.ObjectAt(LChild, K);
                if LElement <> nil then BuildProperties(LElement, LIndexPath, ALevel + 2);
              end;
            end;
          end;
        end;
      end
      else if (LChild is TPersistent) and not (LChild is TStrings) and not (LChild is TCollection) and not (LChild is TPicture) then
        BuildProperties(TPersistent(LChild), LPath, ALevel + 1);
    end;
  finally
    FreeMem(LList);
  end;
end;

procedure TCustomThemedPropertyGrid.Rebuild;
var
  LSelectedPath: string;
  LVirtual: TThemedPropertyGridVirtualProperty;
  LItem: TThemedPropertyGridItem;
begin
  if csDestroying in ComponentState then Exit;
  LSelectedPath := '';
  if FSelected <> nil then LSelectedPath := FSelected.Path;
  StopEditing(True);
  FSelected := nil;
  FRows.Clear;
  FItems.Clear;
  if Length(FTargets) > 0 then BuildProperties(FTargets[0], '', 0);
  for LVirtual in FVirtualProperties do AddItem(LVirtual.Name, nil, LVirtual);
  for LItem in FItems do if LItem.Path = LSelectedPath then FSelected := LItem;
  BuildRows;
  Invalidate;
end;

function TCustomThemedPropertyGrid.IndexedPathParent(const APath: string): string;
var
  LDot, LIndex: Integer;
begin
  LDot := LastDelimiter('.', APath);
  LIndex := LastDelimiter('[', APath);
  if (LIndex > LDot) and (APath[Length(APath)] = ']') then Result := Copy(APath, 1, LIndex - 1)
  else if LDot > 0 then Result := Copy(APath, 1, LDot - 1)
  else Result := '';
end;

function TCustomThemedPropertyGrid.IndexedSource(AItem: TThemedPropertyGridItem; out ASource: TObject; out AKind: TThemedPropertyGridIndexedKind): Boolean;
var
  LOwner: TObject;
begin
  ASource := nil;
  AKind := pgikNone;
  if (AItem = nil) or (AItem.PropInfo = nil) or (AItem.PropInfo.PropType^.Kind <> tkClass) or (Length(FTargets) <> 1) then Exit(False);
  LOwner := ResolveTargetObject(FTargets[0], AItem.Path);
  if LOwner = nil then Exit(False);
  ASource := GetObjectProp(LOwner, AItem.PropInfo);
  if ASource is TStrings then AKind := pgikString
  else if ASource is TCollection then AKind := pgikCollection
  else AKind := NimbusPropertyGridListKind(ASource);
  if (AKind = pgikNone) and (NimbusFindPropertyGridAdapter(ASource) <> nil) then AKind := pgikAdapter;
  Result := (AKind <> pgikNone) and (NimbusPropertyGridIndexedCanRestructure(ASource, AKind) or NimbusPropertyGridIndexedCanReorder(ASource, AKind));
end;

function TCustomThemedPropertyGrid.SelectedIndexedSource(out AParent: TThemedPropertyGridItem; out ASource: TObject; out AKind: TThemedPropertyGridIndexedKind; out AIndex: Integer): Boolean;
var
  LParentPath: string;
  LItem: TThemedPropertyGridItem;
begin
  AParent := nil;
  ASource := nil;
  AKind := pgikNone;
  AIndex := -1;
  if (FSelected = nil) or FSelected.MetadataReadOnly then Exit(False);
  if FSelected.IndexedKind = pgikNone then LParentPath := FSelected.Path
  else
  begin
    LParentPath := IndexedPathParent(FSelected.Path);
    AIndex := StrToIntDef(Copy(FSelected.Name, 2, Length(FSelected.Name) - 2), -1);
  end;
  for LItem in FItems do
    if LItem.Path = LParentPath then
    begin
      AParent := LItem;
      Break;
    end;
  Result := (AParent <> nil) and not AParent.MetadataReadOnly and IndexedSource(AParent, ASource, AKind);
  if not Result then AIndex := -1;
end;

procedure TCustomThemedPropertyGrid.ChangeIndexedStructure(AOperation: Integer);
var
  LParent: TThemedPropertyGridItem;
  LSource: TObject;
  LKind: TThemedPropertyGridIndexedKind;
  LIndex, LCount, LNewIndex: Integer;
  LChange: TThemedPropertyGridChange;
  LParentPath: string;
  LObjectOrder: Boolean;
begin
  StopEditing(False);
  if not SelectedIndexedSource(LParent, LSource, LKind, LIndex) then Exit;
  if (AOperation in [0, 1]) and not NimbusPropertyGridIndexedCanRestructure(LSource, LKind) then Exit;
  if (AOperation in [2, 3]) and not NimbusPropertyGridIndexedCanReorder(LSource, LKind) then Exit;
  LObjectOrder := False;
  if LKind = pgikAdapter then
  begin
    var LAdapter := NimbusFindPropertyGridAdapter(LSource);
    if LAdapter <> nil then LObjectOrder := LAdapter.Kind(LSource) = tkClass;
  end;
  LCount := NimbusPropertyGridIndexedCount(LSource, LKind);
  if (AOperation <> 0) and ((LIndex < 0) or (LIndex >= LCount)) then Exit;
  if ((AOperation = 2) and (LIndex = 0)) or ((AOperation = 3) and (LIndex >= LCount - 1)) then Exit;
  LParentPath := LParent.Path;
  LChange := TThemedPropertyGridChange.Create;
  try
    LChange.Path := LParentPath;
    LChange.IndexedKind := LKind;
    LChange.OldValues := LParent.ReadValues;
    if LKind = pgikCollection then LChange.OldCollections := LParent.CaptureCollections
    else if LObjectOrder then
    begin
      LChange.ObjectOrderChange := True;
      LChange.OldObjectOrder := NimbusPropertyGridIndexedObjectOrder(LSource, LKind);
    end
    else
    begin
      LChange.IndexedChange := True;
      LChange.OldIndexed := NimbusPropertyGridIndexedSnapshot(LSource, LKind);
    end;
    try
      case AOperation of
        0: NimbusPropertyGridIndexedAdd(LSource, LKind);
        1: NimbusPropertyGridIndexedDelete(LSource, LKind, LIndex);
        2: NimbusPropertyGridIndexedMove(LSource, LKind, LIndex, LIndex - 1);
        3: NimbusPropertyGridIndexedMove(LSource, LKind, LIndex, LIndex + 1);
      end;
      var LExpectedCount := LCount;
      if AOperation = 0 then Inc(LExpectedCount)
      else if AOperation = 1 then Dec(LExpectedCount);
      if NimbusPropertyGridIndexedCount(LSource, LKind) <> LExpectedCount then
        raise EPropertyError.Create('Indexed operation changed an unexpected number of items');
      if LKind = pgikCollection then LChange.NewCollections := LParent.CaptureCollections
      else if LObjectOrder then LChange.NewObjectOrder := NimbusPropertyGridIndexedObjectOrder(LSource, LKind)
      else LChange.NewIndexed := NimbusPropertyGridIndexedSnapshot(LSource, LKind);
      LChange.NewValues := LParent.ReadValues;
    except
      if LKind = pgikCollection then LParent.RestoreCollections(LChange.OldCollections)
      else if LObjectOrder then NimbusPropertyGridIndexedRestoreObjectOrder(LSource, LKind, LChange.OldObjectOrder)
      else NimbusPropertyGridIndexedRestore(LSource, LKind, LChange.OldIndexed);
      raise;
    end;
    FUndoStack.Add(LChange);
    LChange := nil;
    FRedoStack.Clear;
    case AOperation of
      0: LNewIndex := LCount;
      1: LNewIndex := LIndex;
      2: LNewIndex := LIndex - 1;
    else
      LNewIndex := LIndex + 1;
    end;
    FExpanded.AddOrSetValue('property:' + LParentPath, True);
    Rebuild;
    if NimbusPropertyGridIndexedCount(LSource, LKind) > 0 then
      for var LItem in FItems do
        if LItem.Path = LParentPath + '[' + IntToStr(Min(LNewIndex, NimbusPropertyGridIndexedCount(LSource, LKind) - 1)) + ']' then
        begin
          SelectItem(LItem);
          EnsureVisible(LItem);
          Break;
        end;
    DoPropertyValueChanged;
  finally
    LChange.Free;
  end;
end;

function TCustomThemedPropertyGrid.ItemHasChildren(AItem: TThemedPropertyGridItem): Boolean;
var
  LChild: TThemedPropertyGridItem;
begin
  Result := False;
  for LChild in FItems do
    if IndexedPathParent(LChild.Path) = AItem.Path then Exit(True);
end;

function TCustomThemedPropertyGrid.ItemBranchVisible(AItem: TThemedPropertyGridItem): Boolean;
var
  LOther: TThemedPropertyGridItem;
  LPrefix: string;
begin
  Result := ItemVisibleInView(AItem) and PropertyMatches(AItem);
  if Result then Exit;
  LPrefix := AItem.Path;
  for LOther in FItems do
    if (LOther <> AItem) and ((Copy(LOther.Path, 1, Length(LPrefix) + 1) = LPrefix + '.') or
      (Copy(LOther.Path, 1, Length(LPrefix) + 1) = LPrefix + '[')) and
      ItemVisibleInView(LOther) and PropertyMatches(LOther) then Exit(True);
end;

function TCustomThemedPropertyGrid.ItemIsExpanded(AItem: TThemedPropertyGridItem): Boolean;
var
  LChild: TThemedPropertyGridItem;
  LDefault: Boolean;
begin
  LDefault := True;
  for LChild in FItems do
    if IndexedPathParent(LChild.Path) = AItem.Path then
    begin
      if LChild.IndexedKind <> pgikNone then LDefault := False;
      Break;
    end;
  Result := LDefault;
  FExpanded.TryGetValue('property:' + AItem.Path, Result);
end;

procedure TCustomThemedPropertyGrid.AppendItemBranch(AItem: TThemedPropertyGridItem);
var
  LRow: TThemedPropertyGridRow;
  LChild: TThemedPropertyGridItem;
begin
  if not ItemBranchVisible(AItem) then Exit;
  LRow := TThemedPropertyGridRow.Create;
  LRow.Item := AItem;
  LRow.Expandable := ItemHasChildren(AItem);
  LRow.Expanded := ItemIsExpanded(AItem);
  FRows.Add(LRow);
  if not LRow.Expandable or not LRow.Expanded then Exit;
  for LChild in FItems do
    if IndexedPathParent(LChild.Path) = AItem.Path then AppendItemBranch(LChild);
end;

procedure TCustomThemedPropertyGrid.BuildRows;
var
  LCategories: TStringList;
  LRoots: TList<TThemedPropertyGridItem>;
  LItem: TThemedPropertyGridItem;
  LRow: TThemedPropertyGridRow;
  LCategory: string;
  LExpanded, LFound: Boolean;
  I, J: Integer;
begin
  FRows.Clear;
  LCategories := TStringList.Create;
  LRoots := TList<TThemedPropertyGridItem>.Create;
  try
    LCategories.Sorted := True;
    LCategories.Duplicates := dupIgnore;
    for LItem in FItems do
      if (IndexedPathParent(LItem.Path) = '') and ItemBranchVisible(LItem) then
      begin
        LRoots.Add(LItem);
        LCategories.Add(LItem.Category);
      end;
    if FSortMode = pgsAlphabetical then
    begin
      for I := 0 to LRoots.Count - 1 do
        for J := I + 1 to LRoots.Count - 1 do
          if CompareText(LRoots[I].DisplayName, LRoots[J].DisplayName) > 0 then LRoots.Exchange(I, J);
      if FShowFavoritesFirst then
        for I := 0 to LRoots.Count - 1 do
        begin
          if LRoots[I].Favorite then Continue;
          LFound := False;
          for J := I + 1 to LRoots.Count - 1 do
            if LRoots[J].Favorite then begin LRoots.Exchange(I, J); LFound := True; Break; end;
          if not LFound then Break;
        end;
      for LItem in LRoots do AppendItemBranch(LItem);
    end
    else
    begin
      if FShowFavoritesFirst and not FShowFavoritesOnly then
        for LItem in LRoots do if LItem.Favorite then AppendItemBranch(LItem);
      for I := 0 to LCategories.Count - 1 do
      begin
        LCategory := LCategories[I];
        LRow := TThemedPropertyGridRow.Create;
        LRow.Category := LCategory;
        LExpanded := True;
        FExpanded.TryGetValue(LCategory, LExpanded);
        LRow.Expanded := LExpanded;
        FRows.Add(LRow);
        if not LExpanded then Continue;
        for LItem in LRoots do
          if LItem.Category = LCategory then AppendItemBranch(LItem);
      end;
    end;
  finally
    LRoots.Free;
    LCategories.Free;
  end;
  if FCategorySelected then
  begin
    LFound := False;
    for LRow in FRows do
      if LRow.IsCategory and (LRow.Category = FSelectedCategory) then begin LFound := True; Break; end;
    if not LFound then SelectItem(nil);
  end
  else if FSelected <> nil then
  begin
    LFound := False;
    for LRow in FRows do
      if LRow.Item = FSelected then begin LFound := True; Break; end;
    if not LFound then SelectItem(nil);
  end;
  UpdateScrollRange;
  Invalidate;
end;

function TCustomThemedPropertyGrid.ViewToolbarArea: TRect;
begin
  if FShowViewToolbar then Result := Rect(0, 0, ClientWidth, ScaleValue(29))
  else Result := Rect(0, 0, ClientWidth, 0);
end;

function TCustomThemedPropertyGrid.SearchArea: TRect;
var
  LToolbarBottom: Integer;
begin
  LToolbarBottom := ViewToolbarArea.Bottom;
  if not FShowSearch then Result := Rect(0, LToolbarBottom, ClientWidth, LToolbarBottom)
  else if FShowViewToolbar and (ClientWidth >= ScaleValue(196)) then
    Result := Rect(Max(ScaleValue(116), ClientWidth - ScaleValue(158)), ScaleValue(4), ClientWidth - ScaleValue(6), ScaleValue(25))
  else
    Result := Rect(ScaleValue(6), LToolbarBottom + ScaleValue(3), Max(ScaleValue(7), ClientWidth - ScaleValue(6)), LToolbarBottom + ScaleValue(25));
end;

function TCustomThemedPropertyGrid.DescriptionArea: TRect;
begin
  if FShowDescription and (FDescriptionMode = pgdBottom) then Result := Rect(0, Max(0, ClientHeight - ScaleValue(66)), ClientWidth, ClientHeight)
  else Result := Rect(0, ClientHeight, 0, ClientHeight);
end;

function TCustomThemedPropertyGrid.RowsArea: TRect;
var
  LTop: Integer;
begin
  LTop := Max(ViewToolbarArea.Bottom, SearchArea.Bottom);
  if FShowSearch and (SearchArea.Top >= ViewToolbarArea.Bottom) then Inc(LTop, ScaleValue(3));
  Result := Rect(0, LTop, ClientWidth, Max(LTop, DescriptionArea.Top));
  if FScrollBar.Visible then Result.Right := Max(0, Result.Right - FScrollBar.Width);
end;

procedure TCustomThemedPropertyGrid.UpdateScrollRange;
var
  LTotal, LView: Integer;
  LRow: TThemedPropertyGridRow;
begin
  if (FRows = nil) or (FScrollBar = nil) or (csDestroying in ComponentState) then Exit;
  LTotal := 0;
  for LRow in FRows do
  begin
    if LRow.IsCategory then LRow.Height := ScaleValue(FCategoryHeight)
    else if LRow.Item.Kind = tkSet then LRow.Height := Max(ScaleValue(FRowHeight), ScaleValue(30))
    else if LRow.Item.PreviewGraphic <> nil then LRow.Height := Max(ScaleValue(FRowHeight), ScaleValue(46))
    else if LRow.Item.Kind = tkClass then LRow.Height := Max(ScaleValue(FRowHeight), ScaleValue(28))
    else LRow.Height := ScaleValue(FRowHeight);
    LRow.Top := LTotal;
    Inc(LTotal, LRow.Height);
  end;
  if ((Parent = nil) and (ParentWindow = 0)) or not HandleAllocated then Exit;
  LView := Max(1, RowsArea.Height);
  FScrollBar.Visible := LTotal > LView;
  FScrollBar.Minimum := 0;
  FScrollBar.LargeChange := LView;
  FScrollBar.Maximum := Max(0, LTotal - 1);
  FScrollBar.SmallChange := ScaleValue(FRowHeight);
  LayoutChildren;
end;

procedure TCustomThemedPropertyGrid.LayoutChildren;
var
  LRows, LSearch: TRect;
  LLayout: TThemedPropertyGridRowLayout;
  LButtonWidth, LButtonGap, LButtonLeft: Integer;
  I: Integer;
begin
  if ((Parent = nil) and (ParentWindow = 0)) or not HandleAllocated or (csDestroying in ComponentState) or (FSearch = nil) or (FScrollBar = nil) then Exit;
  FViewCategory.Visible := FShowViewToolbar;
  FViewAlphabetical.Visible := FShowViewToolbar;
  FViewFavorites.Visible := FShowViewToolbar;
  FViewModified.Visible := FShowViewToolbar;
  if FShowViewToolbar then
  begin
    LButtonGap := ScaleValue(2);
    LButtonWidth := ScaleValue(25);
    LButtonLeft := ScaleValue(4);
    FViewCategory.SetBounds(LButtonLeft, ScaleValue(3), LButtonWidth, ScaleValue(23));
    Inc(LButtonLeft, LButtonWidth + LButtonGap);
    FViewAlphabetical.SetBounds(LButtonLeft, ScaleValue(3), LButtonWidth, ScaleValue(23));
    Inc(LButtonLeft, LButtonWidth + LButtonGap);
    FViewFavorites.SetBounds(LButtonLeft, ScaleValue(3), LButtonWidth, ScaleValue(23));
    Inc(LButtonLeft, LButtonWidth + LButtonGap);
    FViewModified.SetBounds(LButtonLeft, ScaleValue(3), LButtonWidth, ScaleValue(23));
  end;
  FSearch.Visible := FShowSearch;
  if FShowSearch then
  begin
    LSearch := SearchArea;
    FSearch.SetBounds(LSearch.Left + ScaleValue(18), LSearch.Top + ScaleValue(2), Max(1, LSearch.Width - ScaleValue(22)), Max(1, LSearch.Height - ScaleValue(4)));
  end;
  LRows := RowsArea;
  FScrollBar.SetBounds(ClientWidth - ScaleValue(15), LRows.Top, ScaleValue(15), Max(1, LRows.Height));
  if (FEditingItem <> nil) or (FColorEditingItem <> nil) or (FDateEditingItem <> nil) then
  begin
    for I := 0 to FRows.Count - 1 do
      if (FRows[I].Item = FEditingItem) or (FRows[I].Item = FColorEditingItem) or (FRows[I].Item = FDateEditingItem) then
      begin
        LLayout := RowLayout(I);
        FEditor.SetBounds(LLayout.ValueRect.Left, LLayout.ValueRect.Top, Max(1, LLayout.ValueRect.Width), Max(1, LLayout.ValueRect.Height));
        FEnumEditor.SetBounds(LLayout.ValueRect.Left, LLayout.ValueRect.Top, Max(1, LLayout.ValueRect.Width), Max(1, LLayout.ValueRect.Height));
        FNumericEditor.SetBounds(LLayout.ValueRect.Left, LLayout.ValueRect.Top, Max(1, LLayout.ValueRect.Width), Max(1, LLayout.ValueRect.Height));
        FColorEditor.SetBounds(LLayout.ValueRect.Left, LLayout.ValueRect.Top, Max(1, LLayout.ValueRect.Width), Max(1, LLayout.ValueRect.Height));
        FDateEditor.SetBounds(LLayout.ValueRect.Left, LLayout.ValueRect.Top, Max(1, LLayout.ValueRect.Width), Max(1, LLayout.ValueRect.Height));
        Break;
      end;
  end;
  Invalidate;
end;

function TCustomThemedPropertyGrid.RowBounds(const AIndex: Integer): TRect;
begin
  Result := Rect(0, RowsArea.Top + FRows[AIndex].Top - FScrollBar.Value, RowsArea.Right, RowsArea.Top + FRows[AIndex].Top + FRows[AIndex].Height - FScrollBar.Value);
end;

function TCustomThemedPropertyGrid.RowLayout(const AIndex: Integer): TThemedPropertyGridRowLayout;
var
  LIndent: Integer;
begin
  LIndent := 0;
  if not FRows[AIndex].IsCategory then LIndent := FRows[AIndex].Item.IndentLevel;
  Result := TThemedPropertyGridRenderer.RowLayout(RowBounds(AIndex), ScaleValue(FNameColumnWidth), LIndent, FRows[AIndex].IsCategory);
end;

function TCustomThemedPropertyGrid.HitRow(const X, Y: Integer): Integer;
var
  I: Integer;
  LArea: TRect;
begin
  Result := -1;
  LArea := RowsArea;
  if not PtInRect(LArea, Point(X, Y)) then Exit;
  for I := 0 to FRows.Count - 1 do if PtInRect(RowBounds(I), Point(X, Y)) then Exit(I);
end;

procedure TCustomThemedPropertyGrid.Paint;
var
  I: Integer;
  LRow: TThemedPropertyGridRow;
  LVisual: TThemedPropertyGridRowVisual;
  LArea: TRect;
  LDescription: string;
begin
  RenderCanvas.BeginRender(Canvas);
  try
    TThemedPropertyGridRenderer.DrawSurface(RenderCanvas, Palette, ClientRect, ViewToolbarArea, SearchArea, DescriptionArea, FShowViewToolbar, FShowSearch, FShowDescription and (FDescriptionMode = pgdBottom), FSearch.Focused);
    LArea := RowsArea;
    RenderCanvas.PushClip(LArea);
    try
      for I := 0 to FRows.Count - 1 do
      begin
        LRow := FRows[I];
        if (RowBounds(I).Bottom <= LArea.Top) or (RowBounds(I).Top >= LArea.Bottom) then Continue;
        LVisual := Default(TThemedPropertyGridRowVisual);
        LVisual.Layout := RowLayout(I);
        LVisual.Category := LRow.IsCategory;
        if LRow.IsCategory then
        begin
          LVisual.Name := LRow.Category;
          LVisual.Expanded := LRow.Expanded;
          LVisual.Selected := FCategorySelected and (LRow.Category = FSelectedCategory);
          LVisual.Focused := Focused;
          LVisual.Hovered := I = FHoveredRow;
        end
        else
        begin
          LVisual.Name := LRow.Item.DisplayName;
          if (LRow.Item <> FEditingItem) and (LRow.Item <> FDateEditingItem) and (LRow.Item <> FColorEditingItem) then LVisual.Value := LRow.Item.ValueText;
          LVisual.Indent := LRow.Item.IndentLevel;
          LVisual.Expandable := LRow.Expandable;
          LVisual.Expanded := LRow.Expanded;
          LVisual.Selected := LRow.Item = FSelected;
          LVisual.Focused := Focused;
          LVisual.Hovered := I = FHoveredRow;
          LVisual.ReadOnly := LRow.Item.IsReadOnly;
          LVisual.EditorButton := LVisual.Selected and (not LVisual.ReadOnly) and
            ((LRow.Item.EditorKind in [pgeBoolean, pgeColor, pgeDateTime, pgeFile, pgeFolder, pgeImage, pgeIcon]) or
            (LRow.Item.Kind in [tkEnumeration, tkSet, tkClass]));
          LVisual.Dirty := LRow.Item.Dirty;
          LVisual.Favorite := LRow.Item.Favorite;
          LVisual.MultipleValues := LRow.Item.MultipleValues;
          LVisual.Expression := LRow.Item.ExpressionMode;
          LVisual.VirtualProperty := LRow.Item.VirtualProperty <> nil;
          LVisual.Invalid := LRow.Item.ValidationError <> '';
          LVisual.Graphic := LRow.Item.PreviewGraphic;
        end;
        TThemedPropertyGridRenderer.DrawRow(RenderCanvas, Palette, Font, FHeaderFont, LVisual);
      end;
    finally
      RenderCanvas.PopClip;
    end;
    if FShowDescription and (FDescriptionMode = pgdBottom) and (FSelected <> nil) then
    begin
      LDescription := FSelected.Description;
      if FSelected.ValidationError <> '' then LDescription := FSelected.ValidationError;
      TThemedPropertyGridRenderer.DrawDescription(RenderCanvas, Palette, Font, FHeaderFont, DescriptionArea, FSelected.DisplayName, LDescription);
    end;
  finally
    RenderCanvas.EndRender;
  end;
end;

procedure TCustomThemedPropertyGrid.CreateWnd;
begin
  inherited CreateWnd;
  if (FScrollBar <> nil) and not (csDestroying in ComponentState) then UpdateScrollRange;
end;

procedure TCustomThemedPropertyGrid.Resize;
begin
  inherited Resize;
  if FScrollBar <> nil then UpdateScrollRange;
end;

procedure TCustomThemedPropertyGrid.SelectItem(AItem: TThemedPropertyGridItem);
begin
  if not FCategorySelected and (FSelected = AItem) then Exit;
  StopEditing(True);
  FCategorySelected := False;
  FSelectedCategory := '';
  FSelected := AItem;
  if FSelected = nil then FToolTip.ClearInfo(Self)
  else if FSelected.ValidationError <> '' then FToolTip.SetToolTip(Self, FSelected.ValidationError)
  else if FSelected.Description <> '' then FToolTip.SetToolTip(Self, FSelected.Description)
  else FToolTip.ClearInfo(Self);
  if Assigned(FOnSelectedPropertyChanged) then FOnSelectedPropertyChanged(Self);
  Invalidate;
end;

procedure TCustomThemedPropertyGrid.SelectCategory(const ACategory: string);
begin
  if FCategorySelected and (FSelectedCategory = ACategory) then Exit;
  StopEditing(True);
  FSelected := nil;
  FSelectedCategory := ACategory;
  FCategorySelected := True;
  FToolTip.ClearInfo(Self);
  if Assigned(FOnSelectedPropertyChanged) then FOnSelectedPropertyChanged(Self);
  Invalidate;
end;

procedure TCustomThemedPropertyGrid.SelectRow(const AIndex: Integer);
begin
  if (AIndex < 0) or (AIndex >= FRows.Count) then Exit;
  if FRows[AIndex].IsCategory then SelectCategory(FRows[AIndex].Category)
  else SelectItem(FRows[AIndex].Item);
end;

function TCustomThemedPropertyGrid.SelectedRowIndex: Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FRows.Count - 1 do
    if (FCategorySelected and FRows[I].IsCategory and (FRows[I].Category = FSelectedCategory)) or
      (not FCategorySelected and (FSelected <> nil) and (FRows[I].Item = FSelected)) then Exit(I);
end;

function TCustomThemedPropertyGrid.GetSelectedProperty: TThemedPropertyGridItem;
begin
  Result := FSelected;
end;

procedure TCustomThemedPropertyGrid.EnsureRowVisible(const AIndex: Integer);
var
  LTop, LBottom: Integer;
begin
  if (AIndex < 0) or (AIndex >= FRows.Count) or (FScrollBar = nil) then Exit;
  LTop := FRows[AIndex].Top;
  LBottom := LTop + FRows[AIndex].Height;
  if LTop < FScrollBar.Value then FScrollBar.Value := LTop
  else if LBottom > FScrollBar.Value + RowsArea.Height then FScrollBar.Value := LBottom - RowsArea.Height;
end;

procedure TCustomThemedPropertyGrid.EnsureVisible(AItem: TThemedPropertyGridItem);
var
  I: Integer;
begin
  if AItem = nil then Exit;
  for I := 0 to FRows.Count - 1 do
    if FRows[I].Item = AItem then
    begin
      EnsureRowVisible(I);
      Exit;
    end;
end;

procedure TCustomThemedPropertyGrid.MoveSelection(const ADelta: Integer);
var
  LIndex: Integer;
begin
  if (FRows.Count = 0) or (ADelta = 0) then Exit;
  LIndex := SelectedRowIndex;
  if LIndex < 0 then
  begin
    if ADelta > 0 then LIndex := -1 else LIndex := FRows.Count;
  end;
  LIndex := EnsureRange(LIndex + ADelta, 0, FRows.Count - 1);
  SelectRow(LIndex);
  EnsureRowVisible(SelectedRowIndex);
end;

procedure TCustomThemedPropertyGrid.SelectEdge(AFirst: Boolean);
var
  LIndex: Integer;
begin
  if FRows.Count = 0 then Exit;
  if AFirst then LIndex := 0 else LIndex := FRows.Count - 1;
  SelectRow(LIndex);
  EnsureRowVisible(SelectedRowIndex);
end;

procedure TCustomThemedPropertyGrid.NavigateBranch(AExpand: Boolean);
var
  I, LIndex, LParentLevel: Integer;
  LRow: TThemedPropertyGridRow;
  LCategory: string;
begin
  LIndex := SelectedRowIndex;
  if LIndex < 0 then Exit;
  LRow := FRows[LIndex];
  if LRow.IsCategory then
  begin
    if LRow.Expanded <> AExpand then
    begin
      LCategory := LRow.Category;
      FExpanded.AddOrSetValue(LCategory, AExpand);
      BuildRows;
      EnsureRowVisible(SelectedRowIndex);
      if Assigned(FOnCategoryExpandedChanged) then FOnCategoryExpandedChanged(Self, LCategory, AExpand);
      Exit;
    end;
    if AExpand and LRow.Expanded and (LIndex + 1 < FRows.Count) and not FRows[LIndex + 1].IsCategory then
    begin
      SelectRow(LIndex + 1);
      EnsureRowVisible(SelectedRowIndex);
    end;
    Exit;
  end;
  if LRow.Expandable and (LRow.Expanded <> AExpand) then
  begin
    FExpanded.AddOrSetValue('property:' + FSelected.Path, AExpand);
    if Assigned(FOnPropertyExpandedChanged) then FOnPropertyExpandedChanged(Self, FSelected, AExpand);
    BuildRows;
    EnsureVisible(FSelected);
    Exit;
  end;
  if AExpand and LRow.Expandable and LRow.Expanded then
  begin
    if (LIndex + 1 < FRows.Count) and not FRows[LIndex + 1].IsCategory and
      (FRows[LIndex + 1].Item.IndentLevel > FSelected.IndentLevel) then
    begin
      SelectRow(LIndex + 1);
      EnsureRowVisible(SelectedRowIndex);
    end;
  end
  else if not AExpand then
  begin
    LParentLevel := FSelected.IndentLevel;
    for I := LIndex - 1 downto 0 do
      if not FRows[I].IsCategory and (FRows[I].Item.IndentLevel < LParentLevel) then
      begin
        SelectRow(I);
        EnsureRowVisible(I);
        Exit;
      end;
    if FSortMode = pgsCategory then
      for I := 0 to FRows.Count - 1 do
        if FRows[I].IsCategory and (FRows[I].Category = FSelected.Category) then
        begin
          SelectRow(I);
          EnsureRowVisible(I);
          Exit;
        end;
  end;
end;

procedure TCustomThemedPropertyGrid.WMGetDlgCode(var Message: TMessage);
begin
  inherited;
  Message.Result := Message.Result or DLGC_WANTARROWS or DLGC_WANTCHARS;
end;

procedure TCustomThemedPropertyGrid.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LIndex: Integer;
  LLayout: TThemedPropertyGridRowLayout;
  LRow: TThemedPropertyGridRow;
  LCategory: string;
  LExpanded: Boolean;
  LItem: TThemedPropertyGridItem;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button = mbLeft) and CanFocus then SetFocus;
  LIndex := HitRow(X, Y);
  if LIndex < 0 then Exit;
  LLayout := RowLayout(LIndex);
  LRow := FRows[LIndex];
  if (Button = mbLeft) and not LRow.IsCategory and (Abs(X - (LLayout.ValueRect.Left - ScaleValue(7))) <= ScaleValue(4)) then
  begin
    FResizingColumn := True;
    Cursor := crSizeWE;
    MouseCapture := True;
    Exit;
  end;
  if LRow.IsCategory then
  begin
    LCategory := LRow.Category;
    LExpanded := LRow.Expanded;
    SelectCategory(LCategory);
    if (Button = mbLeft) and (PtInRect(LLayout.ExpanderRect, Point(X, Y)) or (ssDouble in Shift)) then
      NavigateBranch(not LExpanded);
    Exit;
  end;
  LItem := LRow.Item;
  LExpanded := LRow.Expanded;
  if (Button = mbLeft) and LRow.Expandable and PtInRect(LLayout.ExpanderRect, Point(X, Y)) then
  begin
    SelectItem(LItem);
    if (SelectedRowIndex >= 0) then NavigateBranch(not LExpanded);
    Exit;
  end;
  SelectItem(LItem);
  if (Button = mbLeft) and (FSelected = LItem) and
    (PtInRect(LLayout.ValueRect, Point(X, Y)) or (ssDouble in Shift)) then StartEditing;
end;

procedure TCustomThemedPropertyGrid.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LIndex: Integer;
  LLayout: TThemedPropertyGridRowLayout;
begin
  inherited MouseMove(Shift, X, Y);
  if FResizingColumn then
  begin
    NameColumnWidth := EnsureRange(MulDiv(X, 96, CurrentPPI), 80, Max(80, MulDiv(RowsArea.Right - ScaleValue(56), 96, CurrentPPI)));
    Exit;
  end;
  LIndex := HitRow(X, Y);
  if (LIndex >= 0) and not FRows[LIndex].IsCategory then
  begin
    LLayout := RowLayout(LIndex);
    if Abs(X - (LLayout.ValueRect.Left - ScaleValue(7))) <= ScaleValue(4) then Cursor := crSizeWE
    else Cursor := crDefault;
  end
  else Cursor := crDefault;
  if LIndex <> FHoveredRow then
  begin
    FHoveredRow := LIndex;
    Invalidate;
  end;
end;

procedure TCustomThemedPropertyGrid.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if FResizingColumn then
  begin
    FResizingColumn := False;
    MouseCapture := False;
    Cursor := crDefault;
  end;
end;

function TCustomThemedPropertyGrid.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
begin
  Result := inherited DoMouseWheel(Shift, WheelDelta, MousePos);
  if FScrollBar.Visible then
  begin
    FScrollBar.Value := FScrollBar.Value - MulDiv(WheelDelta, ScaleValue(FRowHeight) * 3, WHEEL_DELTA);
    Result := True;
  end;
end;

procedure TCustomThemedPropertyGrid.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if Key = 0 then Exit;
  if (ssCtrl in Shift) and (Key in [VK_INSERT, VK_DELETE]) then
  begin
    if Key = VK_INSERT then ChangeIndexedStructure(0) else ChangeIndexedStructure(1);
    Key := 0;
    Exit;
  end;
  if (ssAlt in Shift) and (Key in [VK_UP, VK_DOWN]) then
  begin
    if Key = VK_UP then ChangeIndexedStructure(2) else ChangeIndexedStructure(3);
    Key := 0;
    Exit;
  end;
  if ssCtrl in Shift then
  begin
    case Key of
      Ord('Z'): Undo;
      Ord('Y'): Redo;
      Ord('C'): CopySelectedValue;
      Ord('V'): PasteSelectedValue;
      Ord('F'): if FShowSearch then begin FSearch.SetFocus; FSearch.SelectAll; end;
    else Exit;
    end;
    Key := 0;
    Exit;
  end;
  case Key of
    VK_UP: MoveSelection(-1);
    VK_DOWN: MoveSelection(1);
    VK_PRIOR: MoveSelection(Max(1, RowsArea.Height div Max(1, ScaleValue(FRowHeight))) * -1);
    VK_NEXT: MoveSelection(Max(1, RowsArea.Height div Max(1, ScaleValue(FRowHeight))));
    VK_HOME: SelectEdge(True);
    VK_END: SelectEdge(False);
    VK_F2, VK_F4: StartEditing;
    VK_RETURN, VK_SPACE:
      if FCategorySelected then
      begin
        if SelectedRowIndex >= 0 then NavigateBranch(not FRows[SelectedRowIndex].Expanded);
      end
      else StartEditing;
    VK_DELETE: ResetSelectedProperty;
    VK_ESCAPE: StopEditing(False);
    VK_LEFT: NavigateBranch(False);
    VK_RIGHT: NavigateBranch(True);
  else Exit;
  end;
  Key := 0;
end;

procedure TCustomThemedPropertyGrid.SearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then begin FSearch.Clear; SetFocus; Key := 0; end
  else if Key = VK_DOWN then begin SetFocus; MoveSelection(1); Key := 0; end;
end;

procedure TCustomThemedPropertyGrid.EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    StopEditing(True);
    if CanFocus then SetFocus;
    Key := 0;
  end
  else if Key = VK_ESCAPE then
  begin
    StopEditing(False);
    if CanFocus then SetFocus;
    Key := 0;
  end;
end;

procedure TCustomThemedPropertyGrid.EnumClosed(Sender: TObject);
begin
  if not FUpdatingEditors and (FEditingItem <> nil) and FEnumEditor.Visible then StopEditing(True);
end;

procedure TCustomThemedPropertyGrid.EditExit(Sender: TObject);
begin
  if not FUpdatingEditors then StopEditing(True);
end;

procedure TCustomThemedPropertyGrid.EditChanged(Sender: TObject);
var
  LExpression: string;
begin
  if not FLivePreview or FUpdatingEditors or (FEditingItem = nil) then Exit;
  if FEditingItem.ExpressionMode then
  begin
    LExpression := FEditor.Text;
    if Copy(LExpression, 1, 1) = '=' then Delete(LExpression, 1, 1);
    if LExpression <> FEditingItem.ExpressionText then
    begin
      FEditingItem.ExpressionText := LExpression;
      FEditingItem.Dirty := True;
      FExpressions.AddOrSetValue(FEditingItem.Path, LExpression);
      FEditWasPreviewed := True;
      Invalidate;
    end;
  end
  else PreviewEditValue(FEditingItem, FEditor.Text);
end;

procedure TCustomThemedPropertyGrid.EnumChanged(Sender: TObject);
var
  LValue: Variant;
begin
  if not FLivePreview or FUpdatingEditors or (FEditingItem = nil) or (FEnumEditor.ItemIndex < 0) then Exit;
  if IsBooleanEditorItem(FEditingItem, FEditOriginalValues) then LValue := FEnumEditor.ItemIndex = 1
  else LValue := FEnumEditor.Text;
  PreviewEditValue(FEditingItem, LValue);
end;

procedure TCustomThemedPropertyGrid.NumericChanged(Sender: TObject);
begin
  if FLivePreview and not FUpdatingEditors and (FEditingItem <> nil) then PreviewEditValue(FEditingItem, FNumericEditor.Editor.Text);
end;

procedure TCustomThemedPropertyGrid.RegisterPropertyEditor(const APath: string; AHandler: TThemedPropertyGridEditorEvent);
begin
  if Trim(APath) = '' then raise EArgumentException.Create('Property path is required');
  if Assigned(AHandler) then FEditorsByPath.AddOrSetValue(UpperCase(Trim(APath)), AHandler)
  else FEditorsByPath.Remove(UpperCase(Trim(APath)));
end;

procedure TCustomThemedPropertyGrid.RegisterTypeEditor(const ATypeName: string; AHandler: TThemedPropertyGridEditorEvent);
begin
  if Trim(ATypeName) = '' then raise EArgumentException.Create('Property type is required');
  if Assigned(AHandler) then FEditorsByType.AddOrSetValue(UpperCase(Trim(ATypeName)), AHandler)
  else FEditorsByType.Remove(UpperCase(Trim(ATypeName)));
end;

procedure TCustomThemedPropertyGrid.UnregisterPropertyEditor(const APath: string);
begin
  FEditorsByPath.Remove(UpperCase(Trim(APath)));
end;

procedure TCustomThemedPropertyGrid.UnregisterTypeEditor(const ATypeName: string);
begin
  FEditorsByType.Remove(UpperCase(Trim(ATypeName)));
end;

procedure TCustomThemedPropertyGrid.ClearRegisteredEditors;
begin
  FEditorsByPath.Clear;
  FEditorsByType.Clear;
  FEditorsByKind.Clear;
end;

procedure TCustomThemedPropertyGrid.RegisterKindEditor(AKind: TTypeKind; AHandler: TThemedPropertyGridEditorEvent);
begin
  if Assigned(AHandler) then FEditorsByKind.AddOrSetValue(Ord(AKind), AHandler)
  else FEditorsByKind.Remove(Ord(AKind));
end;

procedure TCustomThemedPropertyGrid.UnregisterKindEditor(AKind: TTypeKind);
begin
  FEditorsByKind.Remove(Ord(AKind));
end;

function TCustomThemedPropertyGrid.ConfigureProperty(const APath: string): TThemedPropertyGridMetadata;
var
  LKey: string;
begin
  LKey := UpperCase(Trim(APath));
  if LKey = '' then raise EArgumentException.Create('Property path is required');
  if not FMetadataByPath.TryGetValue(LKey, Result) then
  begin
    Result := TThemedPropertyGridMetadata.Create;
    FMetadataByPath.Add(LKey, Result);
  end;
end;

function TCustomThemedPropertyGrid.ConfigureType(const ATypeName: string): TThemedPropertyGridMetadata;
var
  LKey: string;
begin
  LKey := UpperCase(Trim(ATypeName));
  if LKey = '' then raise EArgumentException.Create('Property type is required');
  if not FMetadataByType.TryGetValue(LKey, Result) then
  begin
    Result := TThemedPropertyGridMetadata.Create;
    FMetadataByType.Add(LKey, Result);
  end;
end;

procedure TCustomThemedPropertyGrid.ClearMetadata;
begin
  FMetadataByPath.Clear;
  FMetadataByType.Clear;
  Rebuild;
end;

function TCustomThemedPropertyGrid.SetSelectedPropertyValue(const AValue: Variant): Boolean;
begin
  Result := ApplyValue(FSelected, AValue);
end;

function TCustomThemedPropertyGrid.InvokeCustomEditor(AItem: TThemedPropertyGridItem): Boolean;
var
  LHandler: TThemedPropertyGridEditorEvent;
begin
  Result := False;
  if AItem = nil then Exit;
  if FEditorsByPath.TryGetValue(UpperCase(AItem.Path), LHandler) and Assigned(LHandler) then
  begin
    LHandler(Self, AItem, Result);
    if Result then Exit;
  end;
  if (AItem.PropInfo <> nil) and FEditorsByType.TryGetValue(UpperCase(string(AItem.PropInfo.PropType^.Name)), LHandler) and Assigned(LHandler) then
  begin
    LHandler(Self, AItem, Result);
    if Result then Exit;
  end;
  if FEditorsByKind.TryGetValue(Ord(AItem.Kind), LHandler) and Assigned(LHandler) then
  begin
    LHandler(Self, AItem, Result);
    if Result then Exit;
  end;
  if Assigned(FOnEditRequested) then FOnEditRequested(Self, AItem, Result);
end;

function TCustomThemedPropertyGrid.NumericEditorEligible(AItem: TThemedPropertyGridItem): Boolean;
begin
  Result := (AItem <> nil) and (AItem.Kind in [tkInteger, tkFloat]) and
    (AItem.IndexedKind <> pgikListInt64) and
    ((AItem.PropInfo = nil) or not (SameText(string(AItem.PropInfo.PropType^.Name), 'TColor') or
    SameText(string(AItem.PropInfo.PropType^.Name), 'TDateTime') or
    SameText(string(AItem.PropInfo.PropType^.Name), 'TDate') or
    SameText(string(AItem.PropInfo.PropType^.Name), 'TTime')));
end;

function TCustomThemedPropertyGrid.NumericBounds(AItem: TThemedPropertyGridItem; out AMinimum, AMaximum: Extended): Boolean;
var
  LData: PTypeData;
begin
  Result := False;
  AMinimum := -1.0E+15;
  AMaximum := 1.0E+15;
  if AItem = nil then Exit;
  if (AItem.Kind = tkInteger) and (AItem.PropInfo <> nil) then
  begin
    LData := GetTypeData(AItem.PropInfo.PropType^);
    if LData <> nil then
    begin
      AMinimum := LData.MinValue;
      if LData.OrdType = otULong then AMaximum := Cardinal(LData.MaxValue)
      else AMaximum := LData.MaxValue;
    end;
  end;
  if AItem.NumericHasMinimum then AMinimum := Max(AMinimum, AItem.NumericMinimum);
  if AItem.NumericHasMaximum then AMaximum := Min(AMaximum, AItem.NumericMaximum);
  Result := AMinimum <= AMaximum;
end;

function TCustomThemedPropertyGrid.ValidateNumericInput(AItem: TThemedPropertyGridItem; const AValue: Variant; out AError: string): Boolean;
var
  LValue: Extended;
  LInteger, LMinInteger, LMaxInteger: Int64;
  LData: PTypeData;
  LText: string;
begin
  AError := '';
  Result := True;
  if (AItem = nil) or not (AItem.Kind in [tkInteger, tkInt64, tkFloat]) then Exit;
  if (AItem.PropInfo <> nil) and
    (SameText(string(AItem.PropInfo.PropType^.Name), 'TColor') or
    SameText(string(AItem.PropInfo.PropType^.Name), 'TDateTime') or
    SameText(string(AItem.PropInfo.PropType^.Name), 'TDate') or
    SameText(string(AItem.PropInfo.PropType^.Name), 'TTime')) then Exit;
  if VarIsNull(AValue) or VarIsEmpty(AValue) then
  begin
    AError := 'A numeric value is required';
    Exit(False);
  end;
  LText := Trim(VarToStr(AValue));
  if AItem.Kind in [tkInteger, tkInt64] then
  begin
    if not TryStrToInt64(LText, LInteger) then
    begin
      AError := 'Enter a valid whole number';
      Exit(False);
    end;
    if (AItem.Kind = tkInteger) and (AItem.PropInfo <> nil) then
    begin
      LData := GetTypeData(AItem.PropInfo.PropType^);
      LMinInteger := LData.MinValue;
      if LData.OrdType = otULong then LMaxInteger := Cardinal(LData.MaxValue)
      else LMaxInteger := LData.MaxValue;
      if (LInteger < LMinInteger) or (LInteger > LMaxInteger) then
      begin
        AError := Format('Value must be between %s and %s', [IntToStr(LMinInteger), IntToStr(LMaxInteger)]);
        Exit(False);
      end;
    end;
    LValue := LInteger;
    if (AItem.IndexedKind = pgikListInteger) and ((LInteger < Low(Integer)) or (LInteger > High(Integer))) then
    begin
      AError := 'Value is outside the 32-bit integer range';
      Exit(False);
    end;
  end
  else if not TryStrToFloat(LText, LValue) then
  begin
    AError := 'Enter a valid number';
    Exit(False);
  end;
  if (AItem.Kind = tkFloat) and (AItem.PropInfo <> nil) and
    (GetTypeData(AItem.PropInfo.PropType^).FloatType = ftSingle) and (Abs(LValue) > 3.402823466E38) then
  begin
    AError := 'Value exceeds the Single floating-point range';
    Exit(False);
  end;
  if AItem.NumericHasMinimum and AItem.NumericHasMaximum and (AItem.NumericMinimum > AItem.NumericMaximum) then AError := 'The configured minimum exceeds the maximum'
  else if AItem.NumericHasMinimum and (LValue < AItem.NumericMinimum) then AError := 'Value is below the configured minimum'
  else if AItem.NumericHasMaximum and (LValue > AItem.NumericMaximum) then AError := 'Value exceeds the configured maximum';
  Result := AError = '';
end;

procedure TCustomThemedPropertyGrid.StartEditing;
var
  I, LMin, LMax: Integer;
  LMinNumeric, LMaxNumeric: Extended;
  LType: PTypeInfo;
  LItem: TThemedPropertyGridItem;
  LBounds: TThemedPropertyGridRowLayout;
  LIsEnum, LIsBoolean: Boolean;
begin
  if (FSelected = nil) or FSelected.IsReadOnly then Exit;
  StopEditing(True);
  LItem := FSelected;
  if Assigned(FOnPropertyActivated) then FOnPropertyActivated(Self, LItem);
  if FSelected <> LItem then Exit;
  if InvokeCustomEditor(LItem) then Exit;
  if FSelected <> LItem then Exit;
  if (LItem.EditorKind <> pgeText) and (LItem.Kind = tkSet) then
  begin
    EditFlags;
    Exit;
  end;
  if (LItem.EditorKind <> pgeText) and (LItem.Kind = tkClass) then
  begin
    SelectObjectEditor;
    Exit;
  end;
  if (LItem.EditorKind = pgeColor) or ((LItem.EditorKind = pgeAuto) and IsColorProperty) then
  begin
    SelectColorEditor;
    Exit;
  end;
  if LItem.Kind in [tkString, tkLString, tkWString, tkUString] then
  begin
    if (LItem.EditorKind = pgeFolder) or ((LItem.EditorKind = pgeAuto) and IsFolderProperty) then
    begin
      SelectFolderEditor;
      Exit;
    end;
    if (LItem.EditorKind = pgeFile) or ((LItem.EditorKind = pgeAuto) and IsFileProperty) then
    begin
      SelectFileEditor;
      Exit;
    end;
  end;
  if (LItem.EditorKind in [pgeAuto, pgeDateTime]) and IsDateProperty then
  begin
    SelectDateEditor;
    Exit;
  end;
  for I := 0 to FRows.Count - 1 do if FRows[I].Item = LItem then Break;
  if I >= FRows.Count then Exit;
  LBounds := RowLayout(I);
  FUpdatingEditors := True;
  try
    FEditOriginalValues := LItem.ReadValues;
    FEditOriginalExpressionMode := LItem.ExpressionMode;
    FEditOriginalExpressionText := LItem.ExpressionText;
    FEditWasPreviewed := False;
    FEditingItem := LItem;
    LIsBoolean := IsBooleanEditorItem(LItem, FEditOriginalValues);
    LIsEnum := (LItem.EditorKind <> pgeText) and (((LItem.Kind = tkEnumeration) and (LItem.PropInfo <> nil)) or LIsBoolean);
    if LIsEnum then
    begin
      FEnumEditor.Items.BeginUpdate;
      try
        FEnumEditor.Items.Clear;
        if LIsBoolean then
        begin
          FEnumEditor.Items.Add('False');
          FEnumEditor.Items.Add('True');
        end
        else
        begin
          LType := LItem.PropInfo.PropType^;
          LMin := GetTypeData(LType).MinValue;
          LMax := GetTypeData(LType).MaxValue;
          for var J := LMin to LMax do FEnumEditor.Items.Add(GetEnumName(LType, J));
        end;
        if LIsBoolean then
        begin
          if LItem.MultipleValues then FEnumEditor.ItemIndex := -1
          else if Boolean(FEditOriginalValues[0]) then FEnumEditor.ItemIndex := 1
          else FEnumEditor.ItemIndex := 0;
        end
        else FEnumEditor.ItemIndex := FEnumEditor.Items.IndexOf(LItem.ValueText);
      finally
        FEnumEditor.Items.EndUpdate;
      end;
      FEnumEditor.SetBounds(LBounds.ValueRect.Left, LBounds.ValueRect.Top, Max(40, LBounds.ValueRect.Width), Max(20, LBounds.ValueRect.Height));
      FEnumEditor.Visible := True;
      FEnumEditor.BringToFront;
      FEnumEditor.SetFocus;
      FEnumEditor.DroppedDown := True;
    end
    else if (LItem.EditorKind <> pgeText) and NumericEditorEligible(LItem) and not LItem.MultipleValues and
      NumericBounds(LItem, LMinNumeric, LMaxNumeric) and
      (Extended(LItem.ReadValue) >= LMinNumeric) and (Extended(LItem.ReadValue) <= LMaxNumeric) then
    begin
      FNumericEditor.Minimum := LMinNumeric;
      FNumericEditor.Maximum := LMaxNumeric;
      if LItem.NumericIncrement > 0 then FNumericEditor.Increment := LItem.NumericIncrement
      else if LItem.Kind = tkFloat then FNumericEditor.Increment := 0.1
      else FNumericEditor.Increment := 1;
      if LItem.NumericDecimalPlaces >= 0 then FNumericEditor.DecimalPlaces := EnsureRange(LItem.NumericDecimalPlaces, 0, 15)
      else if LItem.Kind = tkFloat then FNumericEditor.DecimalPlaces := 4
      else FNumericEditor.DecimalPlaces := 0;
      FNumericEditor.Value := LItem.ReadValue;
      FNumericEditor.ResetEditorText;
      FNumericEditor.SetBounds(LBounds.ValueRect.Left, LBounds.ValueRect.Top, Max(40, LBounds.ValueRect.Width), Max(24, LBounds.ValueRect.Height));
      FNumericEditor.Visible := True;
      FNumericEditor.BringToFront;
      FNumericEditor.SetFocus;
    end
    else
    begin
      FEditor.Text := LItem.ValueText;
      FEditor.SetBounds(LBounds.ValueRect.Left, LBounds.ValueRect.Top, Max(40, LBounds.ValueRect.Width), Max(20, LBounds.ValueRect.Height));
      FEditor.Visible := True;
      FEditor.BringToFront;
      FEditor.SetFocus;
      FEditor.SelectAll;
    end;
  finally
    FUpdatingEditors := False;
  end;
  if (FEditingItem = LItem) and Assigned(FOnEditStarted) then FOnEditStarted(Self, LItem);
end;

function TCustomThemedPropertyGrid.IsBooleanEditorItem(AItem: TThemedPropertyGridItem; const AValues: TArray<Variant>): Boolean;
var
  LValue: Variant;
begin
  Result := False;
  if AItem = nil then Exit;
  if AItem.IndexedKind = pgikListBoolean then Exit(True);
  if (AItem.IndexedKind <> pgikAdapter) and (AItem.Kind <> tkVariant) then Exit;
  if (AItem.IndexedKind = pgikAdapter) and (AItem.Kind <> tkEnumeration) and (AItem.Kind <> tkVariant) then Exit;
  if Length(AValues) = 0 then Exit;
  for LValue in AValues do
    if VarType(LValue) <> varBoolean then Exit;
  Result := True;
end;

function TCustomThemedPropertyGrid.EditValuesEqual(const ALeft, ARight: TArray<Variant>): Boolean;
var
  I: Integer;
begin
  Result := Length(ALeft) = Length(ARight);
  if not Result then Exit;
  for I := 0 to High(ALeft) do
    if not VarSameValue(ALeft[I], ARight[I]) then Exit(False);
end;

function TCustomThemedPropertyGrid.ValidateCandidateValue(AItem: TThemedPropertyGridItem; const AValue: Variant; out AError: string): Boolean;
begin
  AError := '';
  if AItem = nil then AError := 'No property is selected'
  else if AItem.IsReadOnly then AError := 'The property is read-only'
  else if not ValidateNumericInput(AItem, AValue, AError) then Exit(False)
  else if not ValidatePathInput(AItem, AValue, AError) then Exit(False)
  else if Assigned(FOnValidateValue) then FOnValidateValue(Self, AItem.Path, AValue, AError);
  Result := AError = '';
end;

function TCustomThemedPropertyGrid.ValidateSelectedPropertyValue(const AValue: Variant; out AError: string): Boolean;
begin
  Result := ValidateCandidateValue(FSelected, AValue, AError);
end;

function TCustomThemedPropertyGrid.PreviewEditValue(AItem: TThemedPropertyGridItem; const AValue: Variant; AMarkPreview: Boolean): Boolean;
var
  LBefore: TArray<Variant>;
  LError: string;
begin
  Result := False;
  if AItem = nil then Exit;
  if not ValidateCandidateValue(AItem, AValue, LError) then
  begin
    AItem.ValidationError := LError;
    Invalidate;
    Exit;
  end;
  try
    LBefore := AItem.ReadValues;
    AItem.WriteValue(AValue);
    AItem.ValidationError := '';
    if not EditValuesEqual(LBefore, AItem.ReadValues) then
    begin
      if AMarkPreview then FEditWasPreviewed := True;
      RefreshItem(AItem);
      DoPropertyValueChanged;
    end
    else Invalidate;
    Result := True;
  except
    on E: Exception do
    begin
      AItem.ValidationError := E.Message;
      Invalidate;
    end;
  end;
end;

procedure TCustomThemedPropertyGrid.RestoreEditState(AItem: TThemedPropertyGridItem; const AValues: TArray<Variant>; AExpressionMode: Boolean; const AExpressionText: string);
var
  LBefore: TArray<Variant>;
begin
  if AItem = nil then Exit;
  try
    LBefore := AItem.ReadValues;
    if not EditValuesEqual(LBefore, AValues) then AItem.WriteValues(AValues);
    AItem.ExpressionMode := AExpressionMode;
    AItem.ExpressionText := AExpressionText;
    if AExpressionMode then FExpressions.AddOrSetValue(AItem.Path, AExpressionText)
    else FExpressions.Remove(AItem.Path);
    AItem.ValidationError := '';
    RefreshItem(AItem);
    if not EditValuesEqual(LBefore, AValues) then DoPropertyValueChanged;
  except
    on E: Exception do
    begin
      AItem.ValidationError := E.Message;
      Invalidate;
    end;
  end;
end;

procedure TCustomThemedPropertyGrid.StopEditing(const ACommit: Boolean);
var
  LItem: TThemedPropertyGridItem;
  LText, LExpression: string;
  LOriginal: TArray<Variant>;
  LValue: Variant;
  LOriginalExpression: string;
  LOriginalMode, LWasPreviewed, LSuccess, LNoBooleanSelection: Boolean;
begin
  if FUpdatingEditors then Exit;
  DismissDateEditor;
  if FColorEditingItem <> nil then
  begin
    FColorEditingItem := nil;
    FColorEditor.CloseDropDown;
    FColorEditor.Visible := False;
  end;
  if FEditingItem = nil then Exit;
  LItem := FEditingItem;
  LOriginal := Copy(FEditOriginalValues);
  LOriginalMode := FEditOriginalExpressionMode;
  LOriginalExpression := FEditOriginalExpressionText;
  LWasPreviewed := FEditWasPreviewed;
  FUpdatingEditors := True;
  try
    LText := FEditor.Text;
    if FEnumEditor.Visible then LText := FEnumEditor.Text;
    if FNumericEditor.Visible then LText := FNumericEditor.Editor.Text;
    LNoBooleanSelection := FEnumEditor.Visible and IsBooleanEditorItem(LItem, LOriginal) and (FEnumEditor.ItemIndex < 0);
    if FEnumEditor.Visible and IsBooleanEditorItem(LItem, LOriginal) and not LNoBooleanSelection then LValue := FEnumEditor.ItemIndex = 1
    else LValue := LText;
    FEditor.Visible := False;
    FEnumEditor.Visible := False;
    FNumericEditor.Visible := False;
    FEditingItem := nil;
    FEditOriginalValues := nil;
    FEditWasPreviewed := False;
  finally
    FUpdatingEditors := False;
  end;
  if not ACommit or LNoBooleanSelection then
  begin
    RestoreEditState(LItem, LOriginal, LOriginalMode, LOriginalExpression);
    if Assigned(FOnEditFinished) then FOnEditFinished(Self, LItem, False);
    Invalidate;
    Exit;
  end;
  LSuccess := True;
  if LItem.ExpressionMode then
  begin
    LExpression := LText;
    if Copy(LExpression, 1, 1) = '=' then Delete(LExpression, 1, 1);
    FSelected := LItem;
    SetExpression(LExpression);
  end
  else if LWasPreviewed then
  begin
    LSuccess := PreviewEditValue(LItem, LValue, False);
    if LSuccess then
    begin
      LItem.ExpressionMode := False;
      LItem.ExpressionText := '';
      FExpressions.Remove(LItem.Path);
      PushChange(LItem, LOriginal, LOriginalMode, LOriginalExpression);
      RefreshItem(LItem);
    end
    else
    begin
      LExpression := LItem.ValidationError;
      RestoreEditState(LItem, LOriginal, LOriginalMode, LOriginalExpression);
      LItem.ValidationError := LExpression;
    end;
  end
  else LSuccess := ApplyValue(LItem, LValue);
  if Assigned(FOnEditFinished) and (FItems.IndexOf(LItem) >= 0) then FOnEditFinished(Self, LItem, LSuccess);
  Invalidate;
end;

function TCustomThemedPropertyGrid.ApplyValue(AItem: TThemedPropertyGridItem; const AValue: Variant): Boolean;
var
  LBefore: TArray<Variant>;
  LError, LOldExpressionText: string;
  LOldExpressionMode: Boolean;
begin
  Result := False;
  if AItem = nil then Exit;
  if not ValidateCandidateValue(AItem, AValue, LError) then
  begin
    AItem.ValidationError := LError;
    Invalidate;
    Exit;
  end;
  LBefore := AItem.ReadValues;
  LOldExpressionMode := AItem.ExpressionMode;
  LOldExpressionText := AItem.ExpressionText;
  try
    AItem.WriteValue(AValue);
    AItem.ValidationError := '';
    AItem.ExpressionMode := False;
    AItem.ExpressionText := '';
    FExpressions.Remove(AItem.Path);
    PushChange(AItem, LBefore, LOldExpressionMode, LOldExpressionText);
    if AItem.Kind = tkClass then Rebuild else RefreshItem(AItem);
    Result := True;
  except
    on E: Exception do
    begin
      AItem.ValidationError := E.Message;
      Invalidate;
    end;
  end;
end;

procedure TCustomThemedPropertyGrid.PushChange(AItem: TThemedPropertyGridItem; const AOld: TArray<Variant>; AOldExpressionMode: Boolean; const AOldExpressionText: string);
var
  LNow: TArray<Variant>;
  LChange: TThemedPropertyGridChange;
begin
  LNow := AItem.ReadValues;
  if EditValuesEqual(AOld, LNow) and (AOldExpressionMode = AItem.ExpressionMode) and
    (not AOldExpressionMode or (AOldExpressionText = AItem.ExpressionText)) then Exit;
  LChange := TThemedPropertyGridChange.Create;
  LChange.Path := AItem.Path;
  LChange.OldValues := Copy(AOld);
  LChange.NewValues := Copy(LNow);
  LChange.ExpressionTracked := True;
  LChange.OldExpressionMode := AOldExpressionMode;
  LChange.OldExpressionText := AOldExpressionText;
  LChange.NewExpressionMode := AItem.ExpressionMode;
  LChange.NewExpressionText := AItem.ExpressionText;
  FUndoStack.Add(LChange);
  FRedoStack.Clear;
  DoPropertyValueChanged;
end;

procedure TCustomThemedPropertyGrid.RefreshItem(AItem: TThemedPropertyGridItem);
begin
  AItem.UpdateState;
  for var LItem in FItems do
    if LItem <> AItem then LItem.UpdateState;
  if (FShowModifiedOnly or FShowFavoritesOnly or (FFilterText <> '')) and (FEditingItem = nil) then BuildRows else Invalidate;
end;

procedure TCustomThemedPropertyGrid.DoPropertyValueChanged;
begin
  if Assigned(FOnPropertyValueChanged) then FOnPropertyValueChanged(Self);
end;

function TCustomThemedPropertyGrid.CanResetSelectedProperty: Boolean;
var
  LValue: Variant;
begin
  Result := False;
  if (FSelected = nil) or FSelected.IsReadOnly or not FSelected.HasDefaultValue then Exit;
  if (FSelected.Kind = tkClass) and not ((SelectedObjectValue is TStrings) or (SelectedObjectValue is TFont)) then Exit;
  if FSelected.ExpressionMode then Exit(True);
  for LValue in FSelected.ReadValues do
    if not VarSameValue(LValue, FSelected.DefaultValue) then Exit(True);
end;

procedure TCustomThemedPropertyGrid.ResetSelectedProperty;
var
  LItem: TThemedPropertyGridItem;
begin
  StopEditing(False);
  if not CanResetSelectedProperty then Exit;
  LItem := FSelected;
  ApplyValue(LItem, LItem.DefaultValue);
end;

procedure TCustomThemedPropertyGrid.CopySelectedValue;
begin
  if FSelected = nil then Exit;
  Clipboard.AsText := FSelected.ValueText;
end;

procedure TCustomThemedPropertyGrid.PasteSelectedValue;
begin
  if (FSelected = nil) or FSelected.IsReadOnly or not Clipboard.HasFormat(CF_UNICODETEXT) then Exit;
  ApplyValue(FSelected, Clipboard.AsText);
end;

procedure TCustomThemedPropertyGrid.Undo;
var
  LChange: TThemedPropertyGridChange;
  LItem: TThemedPropertyGridItem;
begin
  StopEditing(False);
  if FUndoStack.Count = 0 then Exit;
  LChange := FUndoStack[FUndoStack.Count - 1];
  LItem := nil;
  for var AItem in FItems do if AItem.Path = LChange.Path then begin LItem := AItem; Break; end;
  if LItem = nil then Exit;
  try
    if LChange.ObjectOrderChange then
    begin
      var LIndexedSource: TObject;
      var LIndexedKind: TThemedPropertyGridIndexedKind;
      if not IndexedSource(LItem, LIndexedSource, LIndexedKind) or (LIndexedKind <> LChange.IndexedKind) then
        raise EPropertyError.Create('Object list undo source is unavailable');
      NimbusPropertyGridIndexedRestoreObjectOrder(LIndexedSource, LIndexedKind, LChange.OldObjectOrder);
    end
    else if LChange.IndexedChange then
    begin
      var LIndexedSource: TObject;
      var LIndexedKind: TThemedPropertyGridIndexedKind;
      if not IndexedSource(LItem, LIndexedSource, LIndexedKind) or (LIndexedKind <> LChange.IndexedKind) then
        raise EPropertyError.Create('Indexed undo source is unavailable');
      NimbusPropertyGridIndexedRestore(LIndexedSource, LIndexedKind, LChange.OldIndexed);
    end
    else if LChange.OldPictures <> nil then LItem.RestorePictures(LChange.OldPictures)
    else if LChange.OldCollections <> nil then LItem.RestoreCollections(LChange.OldCollections)
    else if not EditValuesEqual(LItem.ReadValues, LChange.OldValues) then LItem.WriteValues(LChange.OldValues);
    if LChange.ExpressionTracked then
    begin
      LItem.ExpressionMode := LChange.OldExpressionMode;
      LItem.ExpressionText := LChange.OldExpressionText;
      if LItem.ExpressionMode then FExpressions.AddOrSetValue(LItem.Path, LItem.ExpressionText) else FExpressions.Remove(LItem.Path);
    end;
    FUndoStack.Extract(LChange);
    FRedoStack.Add(LChange);
    if LChange.ObjectOrderChange or LChange.IndexedChange or (LChange.OldCollections <> nil) or (LItem.Kind = tkClass) then Rebuild else RefreshItem(LItem);
    DoPropertyValueChanged;
  except
    on E: Exception do begin LItem.ValidationError := E.Message; Invalidate; end;
  end;
end;

procedure TCustomThemedPropertyGrid.Redo;
var
  LChange: TThemedPropertyGridChange;
  LItem: TThemedPropertyGridItem;
begin
  StopEditing(False);
  if FRedoStack.Count = 0 then Exit;
  LChange := FRedoStack[FRedoStack.Count - 1];
  LItem := nil;
  for var AItem in FItems do if AItem.Path = LChange.Path then begin LItem := AItem; Break; end;
  if LItem = nil then Exit;
  try
    if LChange.ObjectOrderChange then
    begin
      var LIndexedSource: TObject;
      var LIndexedKind: TThemedPropertyGridIndexedKind;
      if not IndexedSource(LItem, LIndexedSource, LIndexedKind) or (LIndexedKind <> LChange.IndexedKind) then
        raise EPropertyError.Create('Object list redo source is unavailable');
      NimbusPropertyGridIndexedRestoreObjectOrder(LIndexedSource, LIndexedKind, LChange.NewObjectOrder);
    end
    else if LChange.IndexedChange then
    begin
      var LIndexedSource: TObject;
      var LIndexedKind: TThemedPropertyGridIndexedKind;
      if not IndexedSource(LItem, LIndexedSource, LIndexedKind) or (LIndexedKind <> LChange.IndexedKind) then
        raise EPropertyError.Create('Indexed redo source is unavailable');
      NimbusPropertyGridIndexedRestore(LIndexedSource, LIndexedKind, LChange.NewIndexed);
    end
    else if LChange.NewPictures <> nil then LItem.RestorePictures(LChange.NewPictures)
    else if LChange.NewCollections <> nil then LItem.RestoreCollections(LChange.NewCollections)
    else if not EditValuesEqual(LItem.ReadValues, LChange.NewValues) then LItem.WriteValues(LChange.NewValues);
    if LChange.ExpressionTracked then
    begin
      LItem.ExpressionMode := LChange.NewExpressionMode;
      LItem.ExpressionText := LChange.NewExpressionText;
      if LItem.ExpressionMode then FExpressions.AddOrSetValue(LItem.Path, LItem.ExpressionText) else FExpressions.Remove(LItem.Path);
    end;
    FRedoStack.Extract(LChange);
    FUndoStack.Add(LChange);
    if LChange.ObjectOrderChange or LChange.IndexedChange or (LChange.NewCollections <> nil) or (LItem.Kind = tkClass) then Rebuild else RefreshItem(LItem);
    DoPropertyValueChanged;
  except
    on E: Exception do begin LItem.ValidationError := E.Message; Invalidate; end;
  end;
end;

procedure TCustomThemedPropertyGrid.AcceptChanges;
var
  LItem: TThemedPropertyGridItem;
begin
  StopEditing(True);
  for LItem in FItems do
  begin
    LItem.AcceptChanges;
    FOriginalValues.AddOrSetValue(LItem.Path, Copy(LItem.OriginalValues));
    if LItem.OriginalExpressionMode then FOriginalExpressions.AddOrSetValue(LItem.Path, LItem.OriginalExpressionText)
    else FOriginalExpressions.Remove(LItem.Path);
  end;
  FUndoStack.Clear;
  FRedoStack.Clear;
  if FShowModifiedOnly then BuildRows else Invalidate;
end;

procedure TCustomThemedPropertyGrid.SetExpression(const AExpression: string);
var
  LBefore: TArray<Variant>;
  LOldExpressionText: string;
  LOldExpressionMode: Boolean;
begin
  if (FSelected = nil) or FSelected.IsReadOnly or not FExpressionModeEnabled then Exit;
  LBefore := FSelected.ReadValues;
  LOldExpressionMode := FSelected.ExpressionMode;
  LOldExpressionText := FSelected.ExpressionText;
  FSelected.ExpressionMode := True;
  FSelected.ExpressionText := AExpression;
  FExpressions.AddOrSetValue(FSelected.Path, AExpression);
  PushChange(FSelected, LBefore, LOldExpressionMode, LOldExpressionText);
  RefreshItem(FSelected);
end;

function TCustomThemedPropertyGrid.ExportJson: string;
var
  LJson: TJSONObject;
  LItem: TThemedPropertyGridItem;
begin
  StopEditing(True);
  LJson := TJSONObject.Create;
  try
    for LItem in FItems do LJson.AddPair(LItem.Path, LItem.ValueText);
    Result := LJson.ToJSON;
  finally
    LJson.Free;
  end;
end;

function TCustomThemedPropertyGrid.ExportXml: string;
var
  LItem: TThemedPropertyGridItem;
  LName, LValue: string;
begin
  StopEditing(True);
  Result := '<Properties>';
  for LItem in FItems do
  begin
    LName := StringReplace(StringReplace(StringReplace(LItem.Path, '&', '&amp;', [rfReplaceAll]), '"', '&quot;', [rfReplaceAll]), '<', '&lt;', [rfReplaceAll]);
    LValue := StringReplace(StringReplace(StringReplace(StringReplace(LItem.ValueText, '&', '&amp;', [rfReplaceAll]), '"', '&quot;', [rfReplaceAll]), '<', '&lt;', [rfReplaceAll]), '>', '&gt;', [rfReplaceAll]);
    Result := Result + '<Property Name="' + LName + '" Value="' + LValue + '" />';
  end;
  Result := Result + '</Properties>';
end;

function TCustomThemedPropertyGrid.AddVirtualProperty(const AName: string; AGetter: TThemedPropertyGridGetVirtualEvent; ASetter: TThemedPropertyGridSetVirtualEvent): TThemedPropertyGridVirtualProperty;
begin
  Result := TThemedPropertyGridVirtualProperty.Create(AName, AGetter, ASetter);
  FVirtualProperties.Add(Result);
  Rebuild;
end;

function TCustomThemedPropertyGrid.RemoveVirtualProperty(const AName: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := FVirtualProperties.Count - 1 downto 0 do
    if FVirtualProperties[I].Name = AName then
    begin
      FVirtualProperties.Delete(I);
      FOriginalValues.Remove(AName);
      FOriginalExpressions.Remove(AName);
      FExpressions.Remove(AName);
      Rebuild;
      Exit(True);
    end;
end;

procedure TCustomThemedPropertyGrid.ClearVirtualProperties;
begin
  FVirtualProperties.Clear;
  Rebuild;
end;

function TCustomThemedPropertyGrid.SelectedObjectValue: TObject;
var
  LOwner: TObject;
begin
  Result := nil;
  if (FSelected = nil) or (FSelected.PropInfo = nil) or (Length(FTargets) = 0) then Exit;
  LOwner := ResolveTargetObject(FTargets[0], FSelected.Path);
  if LOwner <> nil then Result := GetObjectProp(LOwner, FSelected.PropInfo);
end;

function TCustomThemedPropertyGrid.IsFileProperty: Boolean;
begin
  Result := (FSelected <> nil) and (FSelected.Kind in [tkString, tkLString, tkWString, tkUString]) and
    (ContainsText(FSelected.Name, 'FileName') or SameText(FSelected.Name, 'FilePath') or SameText(FSelected.Name, 'ImagePath'));
end;

function TCustomThemedPropertyGrid.IsFolderProperty: Boolean;
begin
  Result := (FSelected <> nil) and (FSelected.Kind in [tkString, tkLString, tkWString, tkUString]) and
    (ContainsText(FSelected.Name, 'Folder') or ContainsText(FSelected.Name, 'Directory'));
end;

function TCustomThemedPropertyGrid.ValidatePathInput(AItem: TThemedPropertyGridItem; const AValue: Variant; out AError: string): Boolean;
var
  LPath: string;
  LFolder: Boolean;
begin
  AError := '';
  Result := True;
  if (AItem = nil) or not AItem.PathCheckExists or (not (AItem.Kind in [tkString, tkLString, tkWString, tkUString])) then Exit;
  LPath := Trim(VarToStr(AValue));
  if LPath = '' then Exit;
  LFolder := (AItem.EditorKind = pgeFolder) or ((AItem.EditorKind = pgeAuto) and
    (ContainsText(AItem.Name, 'Folder') or ContainsText(AItem.Name, 'Directory')));
  if LFolder and not System.SysUtils.DirectoryExists(LPath) then AError := 'The selected directory does not exist'
  else if not LFolder and not FileExists(LPath) then AError := 'The selected file does not exist';
  Result := AError = '';
end;

function TCustomThemedPropertyGrid.IsColorProperty: Boolean;
begin
  Result := (FSelected <> nil) and (FSelected.PropInfo <> nil) and SameText(string(FSelected.PropInfo.PropType^.Name), 'TColor');
end;

function TCustomThemedPropertyGrid.IsImageProperty: Boolean;
var
  LObject: TObject;
begin
  LObject := SelectedObjectValue;
  Result := (LObject is TPicture) or (LObject is TGraphic);
end;

procedure TCustomThemedPropertyGrid.SelectImageEditor(const AClear: Boolean);
var
  LNew, LOne: TPicture;
  LBefore, LAfter, LCopies: TObjectList<TPicture>;
  LChange: TThemedPropertyGridChange;
  LError, LSourceFile: string;
  LIconOnly: Boolean;
  LValuesBefore: TArray<Variant>;
  I: Integer;
begin
  if (FSelected = nil) or FSelected.IsReadOnly or not IsImageProperty then Exit;
  LNew := nil;
  LBefore := nil;
  LAfter := nil;
  LCopies := nil;
  try
    try
      LBefore := FSelected.CapturePictures;
      if LBefore.Count = 0 then Exit;
      LValuesBefore := FSelected.ReadValues;
      LNew := TPicture.Create;
      LSourceFile := '';
      if not AClear then
      begin
        LIconOnly := (FSelected.EditorKind = pgeIcon) or (SelectedObjectValue is TIcon);
        if not NimbusEditPropertyImage(Self, 'Edit image - ' + FSelected.DisplayName, LBefore[0], LIconOnly, LOne, LSourceFile) then Exit;
        LNew.Free;
        LNew := LOne;
      end;
      if not ValidateCandidateValue(FSelected, LSourceFile, LError) then
      begin
        FSelected.ValidationError := LError;
        Invalidate;
        Exit;
      end;
      LCopies := TObjectList<TPicture>.Create(True);
      for I := 0 to LBefore.Count - 1 do
      begin
        LOne := TPicture.Create;
        try
          LOne.Assign(LNew);
          LCopies.Add(LOne);
          LOne := nil;
        finally
          LOne.Free;
        end;
      end;
      FSelected.RestorePictures(LCopies);
      if EditValuesEqual(LValuesBefore, FSelected.ReadValues) then Exit;
      LAfter := FSelected.CapturePictures;
      LChange := TThemedPropertyGridChange.Create;
      try
        LChange.Path := FSelected.Path;
        LChange.OldPictures := LBefore;
        LChange.NewPictures := LAfter;
        LBefore := nil;
        LAfter := nil;
        FUndoStack.Add(LChange);
        LChange := nil;
      finally
        LChange.Free;
      end;
      FRedoStack.Clear;
      FSelected.ValidationError := '';
      DoPropertyValueChanged;
      RefreshItem(FSelected);
      UpdateScrollRange;
    except
      on E: Exception do
      begin
        if LBefore <> nil then
          try
            FSelected.RestorePictures(LBefore);
          except
            on ERollback: Exception do FSelected.ValidationError := E.Message + '; restore failed: ' + ERollback.Message;
          end;
        if FSelected.ValidationError = '' then FSelected.ValidationError := E.Message;
        Invalidate;
      end;
    end;
  finally
    LNew.Free;
    LBefore.Free;
    LAfter.Free;
    LCopies.Free;
  end;
end;

function TCustomThemedPropertyGrid.IsDateProperty: Boolean;
begin
  Result := (FSelected <> nil) and (FSelected.PropInfo <> nil) and
    (SameText(string(FSelected.PropInfo.PropType^.Name), 'TDateTime') or SameText(string(FSelected.PropInfo.PropType^.Name), 'TDate') or SameText(string(FSelected.PropInfo.PropType^.Name), 'TTime'));
end;

procedure TCustomThemedPropertyGrid.DismissDateEditor;
begin
  if FDateEditingItem = nil then Exit;
  FDateEditingItem := nil;
  FDateEditor.CloseDropDown;
  FDateEditor.Visible := False;
  Invalidate;
end;

procedure TCustomThemedPropertyGrid.DatePickerClosed(Sender: TObject);
begin
  DismissDateEditor;
end;

procedure TCustomThemedPropertyGrid.DatePickerConfirmed(Sender: TObject);
var
  LItem: TThemedPropertyGridItem;
  LValue: TDateTime;
begin
  LItem := FDateEditingItem;
  if LItem = nil then Exit;
  LValue := FDateEditor.Value;
  if SameText(string(LItem.PropInfo.PropType^.Name), 'TTime') then LValue := TimeOf(LValue)
  else if SameText(string(LItem.PropInfo.PropType^.Name), 'TDate') then LValue := DateOf(LValue);
  DismissDateEditor;
  ApplyValue(LItem, Double(LValue));
end;

procedure TCustomThemedPropertyGrid.SelectDateEditor;
var
  I: Integer;
  LValue: TDateTime;
  LTypeName: string;
  LLayout: TThemedPropertyGridRowLayout;
begin
  if (FSelected = nil) or FSelected.IsReadOnly or not IsDateProperty then Exit;
  for I := 0 to FRows.Count - 1 do
    if FRows[I].Item = FSelected then
    begin
      LTypeName := string(FSelected.PropInfo.PropType^.Name);
      LValue := FSelected.ReadValue;
      if SameText(LTypeName, 'TTime') then LValue := Date + TimeOf(LValue);
      FDateEditor.ShowTime := not SameText(LTypeName, 'TDate');
      FDateEditor.CloseOnDateSelected := SameText(LTypeName, 'TDate');
      FDateEditor.ShowConfirmButton := not SameText(LTypeName, 'TDate');
      if SameText(LTypeName, 'TTime') then FDateEditor.CustomFormat := 'hh:nn:ss'
      else if SameText(LTypeName, 'TDate') then FDateEditor.CustomFormat := 'dd.mm.yyyy'
      else FDateEditor.CustomFormat := 'dd.mm.yyyy hh:nn:ss';
      FDateEditor.Value := LValue;
      LLayout := RowLayout(I);
      FDateEditingItem := FSelected;
      FDateEditor.SetBounds(LLayout.ValueRect.Left, LLayout.ValueRect.Top, Max(80, LLayout.ValueRect.Width), Max(26, LLayout.ValueRect.Height));
      FDateEditor.Visible := True;
      FDateEditor.BringToFront;
      FDateEditor.SetFocus;
      FDateEditor.ShowDropDown;
      Exit;
    end;
end;

procedure TCustomThemedPropertyGrid.ColorPickerAccepted(Sender: TObject);
var
  LItem: TThemedPropertyGridItem;
  LColor: TColor;
begin
  LItem := FColorEditingItem;
  if LItem = nil then Exit;
  LColor := FColorEditor.SelectedColor;
  FColorEditingItem := nil;
  FColorEditor.CloseDropDown;
  FColorEditor.Visible := False;
  ApplyValue(LItem, ColorToString(LColor));
end;

procedure TCustomThemedPropertyGrid.ColorPickerCancelled(Sender: TObject);
begin
  FColorEditingItem := nil;
  FColorEditor.CloseDropDown;
  FColorEditor.Visible := False;
  Invalidate;
end;

procedure TCustomThemedPropertyGrid.SelectColorEditor;
var
  I: Integer;
  LLayout: TThemedPropertyGridRowLayout;
begin
  if (FSelected = nil) or FSelected.IsReadOnly or not IsColorProperty then Exit;
  for I := 0 to FRows.Count - 1 do
    if FRows[I].Item = FSelected then
    begin
      LLayout := RowLayout(I);
      FColorEditingItem := FSelected;
      FColorEditor.SelectedColor := TColor(Integer(FSelected.ReadValue));
      FColorEditor.SetBounds(LLayout.ValueRect.Left, LLayout.ValueRect.Top, Max(80, LLayout.ValueRect.Width), Max(26, LLayout.ValueRect.Height));
      FColorEditor.Visible := True;
      FColorEditor.BringToFront;
      FColorEditor.OpenDropDown;
      Exit;
    end;
end;

procedure TCustomThemedPropertyGrid.SelectFileEditor;
var
  LOptions: TOpenOptions;
begin
  if (FSelected = nil) or FSelected.IsReadOnly or (not (FSelected.Kind in [tkString, tkLString, tkWString, tkUString])) then Exit;
  LOptions := FOpenDialog.Options;
  try
    FOpenDialog.Filter := FSelected.PathFilter;
    if FOpenDialog.Filter = '' then FOpenDialog.Filter := 'All files (*.*)|*.*';
    FOpenDialog.Options := LOptions - [ofFileMustExist];
    if FSelected.PathCheckExists then FOpenDialog.Options := FOpenDialog.Options + [ofFileMustExist];
    FOpenDialog.FileName := FSelected.ValueText;
    if FOpenDialog.Execute(Handle) then ApplyValue(FSelected, FOpenDialog.FileName);
  finally
    FOpenDialog.Options := LOptions;
  end;
end;

procedure TCustomThemedPropertyGrid.SelectFolderEditor;
var
  LPath: string;
begin
  if (FSelected = nil) or FSelected.IsReadOnly or (not (FSelected.Kind in [tkString, tkLString, tkWString, tkUString])) then Exit;
  LPath := FSelected.ValueText;
  if SelectDirectory('Select folder', '', LPath, [sdNewUI, sdNewFolder], Self) then ApplyValue(FSelected, LPath);
end;

procedure TCustomThemedPropertyGrid.EditFlags;
var
  LType: PTypeInfo;
  LText: string;
begin
  if (FSelected = nil) or (FSelected.Kind <> tkSet) or (FSelected.PropInfo = nil) then Exit;
  LType := GetTypeData(FSelected.PropInfo.PropType^).CompType^;
  if NimbusEditPropertyFlags(Self, 'Edit flags - ' + FSelected.DisplayName, LType, FSelected.ValueText, LText) then ApplyValue(FSelected, LText);
end;

procedure TCustomThemedPropertyGrid.EditTextCollection(AStrings: TStrings);
var
  LText: string;
begin
  if (AStrings <> nil) and NimbusEditPropertyText(Self, FSelected.DisplayName, AStrings.Text, LText) then ApplyValue(FSelected, LText);
end;

procedure TCustomThemedPropertyGrid.EditObjectCollection(ACollection: TCollection);
var
  LEdited: TCollection;
  LBefore, LAfter, LCopies: TObjectList<TCollection>;
  LChange: TThemedPropertyGridChange;
  LCopy: TCollection;
  LError: string;
  I: Integer;
begin
  if (ACollection = nil) or (FSelected = nil) or FSelected.IsReadOnly then Exit;
  LEdited := nil;
  LBefore := nil;
  LAfter := nil;
  LCopies := nil;
  try
    try
      if not NimbusEditPropertyCollection(Self, 'Edit collection - ' + FSelected.DisplayName, ACollection, LEdited) then Exit;
      LBefore := FSelected.CaptureCollections;
      if NimbusPropertyGridCollectionFingerprint(LEdited) = NimbusPropertyGridCollectionFingerprint(LBefore[0]) then Exit;
      if not ValidateCandidateValue(FSelected, NimbusPropertyGridCollectionFingerprint(LEdited), LError) then
      begin
        FSelected.ValidationError := LError;
        Invalidate;
        Exit;
      end;
      LCopies := TObjectList<TCollection>.Create(True);
      for I := 0 to LBefore.Count - 1 do
      begin
        LCopy := TCollection.Create(LBefore[I].ItemClass);
        try
          LCopy.Assign(LEdited);
          LCopies.Add(LCopy);
          LCopy := nil;
        finally
          LCopy.Free;
        end;
      end;
      FSelected.RestoreCollections(LCopies);
      LAfter := FSelected.CaptureCollections;
      LChange := TThemedPropertyGridChange.Create;
      try
        LChange.Path := FSelected.Path;
        LChange.OldCollections := LBefore;
        LChange.NewCollections := LAfter;
        LBefore := nil;
        LAfter := nil;
        FUndoStack.Add(LChange);
        LChange := nil;
      finally
        LChange.Free;
      end;
      FRedoStack.Clear;
      FSelected.ValidationError := '';
      Rebuild;
      DoPropertyValueChanged;
    except
      on E: Exception do
      begin
        FSelected.ValidationError := E.Message;
        Invalidate;
      end;
    end;
  finally
    LEdited.Free;
    LBefore.Free;
    LAfter.Free;
    LCopies.Free;
  end;
end;

procedure TCustomThemedPropertyGrid.SelectObjectEditor;
var
  LObject: TObject;
  LFontValue: string;
begin
  LObject := SelectedObjectValue;
  if LObject = nil then Exit;
  if LObject is TFont then
  begin
    if NimbusEditPropertyFont(Self, 'Edit font - ' + FSelected.DisplayName, TFont(LObject), LFontValue) then ApplyValue(FSelected, LFontValue);
  end
  else if LObject is TStrings then EditTextCollection(TStrings(LObject))
  else if LObject is TCollection then EditObjectCollection(TCollection(LObject))
  else if (LObject is TPicture) or (LObject is TGraphic) then SelectImageEditor(False);
end;

function TCustomThemedPropertyGrid.MakeAction(const ACaption: string; AShortcut: TShortCut): TAction;
begin
  Result := TAction.Create(FActions);
  Result.ActionList := FActions;
  Result.Caption := ACaption;
  Result.ShortCut := AShortcut;
  Result.OnExecute := HandleMenuAction;
  Result.OnUpdate := UpdateMenuAction;
end;

procedure TCustomThemedPropertyGrid.AddMenuItem(AAction: TAction);
var
  LItem: TMenuItem;
begin
  LItem := TMenuItem.Create(FMenu);
  LItem.Action := AAction;
  FMenu.Items.Add(LItem);
end;

procedure TCustomThemedPropertyGrid.AddMenuSeparator;
var
  LItem: TMenuItem;
begin
  LItem := TMenuItem.Create(FMenu);
  LItem.Caption := '-';
  FMenu.Items.Add(LItem);
end;

procedure TCustomThemedPropertyGrid.SetupActions;
begin
  FActions := TActionList.Create(Self);
  FResetAction := MakeAction('Reset', 0);
  FCopyAction := MakeAction('Copy Value', TextToShortCut('Ctrl+C'));
  FPasteAction := MakeAction('Paste Value', TextToShortCut('Ctrl+V'));
  FFavoriteAction := MakeAction('Pin Favorite', 0);
  FExpressionAction := MakeAction('Use Expression', 0);
  FClearExpressionAction := MakeAction('Clear Expression', 0);
  FUndoAction := MakeAction('Undo', TextToShortCut('Ctrl+Z'));
  FRedoAction := MakeAction('Redo', TextToShortCut('Ctrl+Y'));
  FAcceptAction := MakeAction('Accept Changes', 0);
  FClearImageAction := MakeAction('Clear Image', 0);
  FAddIndexedAction := MakeAction('Add Item', 0);
  FRemoveIndexedAction := MakeAction('Remove Item', 0);
  FMoveIndexedUpAction := MakeAction('Move Item Up', 0);
  FMoveIndexedDownAction := MakeAction('Move Item Down', 0);
  AddMenuItem(FResetAction);
  AddMenuItem(FClearImageAction);
  AddMenuSeparator;
  AddMenuItem(FCopyAction);
  AddMenuItem(FPasteAction);
  AddMenuSeparator;
  AddMenuItem(FFavoriteAction);
  AddMenuSeparator;
  AddMenuItem(FAddIndexedAction);
  AddMenuItem(FRemoveIndexedAction);
  AddMenuItem(FMoveIndexedUpAction);
  AddMenuItem(FMoveIndexedDownAction);
  AddMenuSeparator;
  AddMenuItem(FExpressionAction);
  AddMenuItem(FClearExpressionAction);
  AddMenuSeparator;
  AddMenuItem(FUndoAction);
  AddMenuItem(FRedoAction);
  AddMenuItem(FAcceptAction);
end;

procedure TCustomThemedPropertyGrid.UpdateMenuAction(Sender: TObject);
var
  LAction: TAction;
  LParent: TThemedPropertyGridItem;
  LSource: TObject;
  LKind: TThemedPropertyGridIndexedKind;
  LIndex, LCount: Integer;
begin
  if not (Sender is TAction) then Exit;
  LAction := TAction(Sender);
  if LAction = FAddIndexedAction then LAction.Enabled := SelectedIndexedSource(LParent, LSource, LKind, LIndex) and NimbusPropertyGridIndexedCanRestructure(LSource, LKind)
  else if ((LAction = FRemoveIndexedAction) or (LAction = FMoveIndexedUpAction) or (LAction = FMoveIndexedDownAction)) then
  begin
    LAction.Enabled := SelectedIndexedSource(LParent, LSource, LKind, LIndex);
    if LAction.Enabled then
    begin
      LCount := NimbusPropertyGridIndexedCount(LSource, LKind);
      if LAction = FRemoveIndexedAction then LAction.Enabled := NimbusPropertyGridIndexedCanRestructure(LSource, LKind) and (LIndex >= 0) and (LIndex < LCount)
      else if LAction = FMoveIndexedUpAction then LAction.Enabled := NimbusPropertyGridIndexedCanReorder(LSource, LKind) and (LIndex > 0) and (LIndex < LCount)
      else LAction.Enabled := NimbusPropertyGridIndexedCanReorder(LSource, LKind) and (LIndex >= 0) and (LIndex < LCount - 1);
    end;
  end
  else if LAction = FResetAction then LAction.Enabled := CanResetSelectedProperty
  else if LAction = FCopyAction then LAction.Enabled := FSelected <> nil
  else if LAction = FPasteAction then LAction.Enabled := (FSelected <> nil) and not FSelected.IsReadOnly
  else if LAction = FFavoriteAction then
  begin
    LAction.Enabled := FSelected <> nil;
    if (FSelected <> nil) and FSelected.Favorite then LAction.Caption := 'Unpin Favorite' else LAction.Caption := 'Pin Favorite';
  end
  else if LAction = FExpressionAction then LAction.Enabled := FExpressionModeEnabled and (FSelected <> nil) and not FSelected.IsReadOnly and not FSelected.ExpressionMode
  else if LAction = FClearExpressionAction then LAction.Enabled := FExpressionModeEnabled and (FSelected <> nil) and not FSelected.IsReadOnly and FSelected.ExpressionMode
  else if LAction = FUndoAction then LAction.Enabled := FUndoStack.Count > 0
  else if LAction = FRedoAction then LAction.Enabled := FRedoStack.Count > 0
  else if LAction = FClearImageAction then LAction.Enabled := (FSelected <> nil) and not FSelected.IsReadOnly and IsImageProperty;
end;

procedure TCustomThemedPropertyGrid.HandleMenuAction(Sender: TObject);
begin
  if Sender = FAddIndexedAction then ChangeIndexedStructure(0)
  else if Sender = FRemoveIndexedAction then ChangeIndexedStructure(1)
  else if Sender = FMoveIndexedUpAction then ChangeIndexedStructure(2)
  else if Sender = FMoveIndexedDownAction then ChangeIndexedStructure(3)
  else if Sender = FResetAction then ResetSelectedProperty
  else if Sender = FClearImageAction then SelectImageEditor(True)
  else if Sender = FCopyAction then CopySelectedValue
  else if Sender = FPasteAction then PasteSelectedValue
  else if Sender = FFavoriteAction then
  begin
    if FSelected = nil then Exit;
    FSelected.Favorite := not FSelected.Favorite;
    FFavorites.AddOrSetValue(FSelected.Path, FSelected.Favorite);
    BuildRows;
  end
  else if Sender = FExpressionAction then SetExpression(FSelected.ValueText)
  else if Sender = FClearExpressionAction then
  begin
    if (FSelected = nil) or FSelected.IsReadOnly or not FSelected.ExpressionMode then Exit;
    var LBefore := FSelected.ReadValues;
    var LOldExpression := FSelected.ExpressionText;
    FSelected.ExpressionMode := False;
    FSelected.ExpressionText := '';
    FExpressions.Remove(FSelected.Path);
    PushChange(FSelected, LBefore, True, LOldExpression);
    RefreshItem(FSelected);
  end
  else if Sender = FUndoAction then Undo
  else if Sender = FRedoAction then Redo
  else if Sender = FAcceptAction then AcceptChanges;
end;

end.

{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.VirtualList;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.Types,
  System.UITypes,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.ImgList,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  NimbusForms.Theming.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.Controls.Base, NimbusForms.Controls.Types,
  NimbusForms.Controls.VScrollBar,
  NimbusForms.Controls.HScrollBar,
  NimbusForms.Rendering.Canvas,
  NimbusForms.Rendering.VirtualList;

type
  TThemedVirtualListCheckState = (vlcsUnchecked, vlcsChecked, vlcsIndeterminate);
  TThemedVirtualListScrollBarMode = (vlsbAuto, vlsbAlways, vlsbNever);
  TThemedVirtualListSelectionMode = (vlsmSingle, vlsmMulti, vlsmRange);
  TThemedVirtualListSortDirection = (vlsdNone, vlsdAscending, vlsdDescending);
  TThemedVirtualListAutoSizeMode = (vlasmNone, vlasmHeader, vlasmContent, vlasmAll);
  TThemedVirtualListFilterMode = (vlfmNone, vlfmGlobal, vlfmPerColumn);
  TThemedVirtualListRowKind = (vlrkNormal, vlrkGroupHeader, vlrkSeparator, vlrkDetails, vlrkPlaceholder);
  TThemedVirtualListColumnEditorType = (vlcetNone, vlcetTextBox, vlcetComboBox, vlcetCheckBox, vlcetDateTime, vlcetNumeric);
  TThemedVirtualListImageFitMode = (vlifStretch, vlifContain, vlifCover, vlifCenter);
  TThemedVirtualListBadgeKind = (vlbkText, vlbkCount, vlbkDot, vlbkImage);
  TThemedVirtualListBadgeColor = (vlbcDefault, vlbcInfo, vlbcSuccess, vlbcWarning, vlbcError, vlbcAccent, vlbcGray, vlbcGold, vlbcPink, vlbcPurple, vlbcOrange, vlbcCustom);

const
  WM_NIMBUS_VIRTUALLIST_REQUEST = WM_APP + $371;

type

  TThemedVirtualListColumn = class;

  TThemedVirtualListItemData = record
    Text: string;
    Subtitle: string;
    DetailText: string;
    BadgeText: string;
    ImageIndex: Integer;
    StatusColor: TColor;
    AccentColor: TColor;
    ProgressValue: Integer;
    ShowProgress: Boolean;
    Enabled: Boolean;
  end;

  TThemedVirtualListItemDataArray = array of TThemedVirtualListItemData;
  TThemedVirtualListIndexArray = array of Integer;

  TThemedVirtualListCellRenderState = record
    Selected: Boolean;
    Hovered: Boolean;
    Focused: Boolean;
    Checked: Boolean;
    Enabled: Boolean;
    Placeholder: Boolean;
  end;

  TThemedVirtualListBadgeData = record
    Key: string;
    Kind: TThemedVirtualListBadgeKind;
    Count: Integer;
    Text: string;
    Image: Vcl.Graphics.TBitmap;
    ColorRole: TThemedVirtualListBadgeColor;
    Color: TColor;
    Visible: Boolean;
    Scale: Single;
    Alpha: Single;
  end;

  TThemedVirtualCellRenderer = class sealed
  private
    class function ResolveTextColor(const AFont: TFont; const AState: TThemedVirtualListCellRenderState): TColor; static;
    class function ResolveAccentColor(const AColor: TColor; const AState: TThemedVirtualListCellRenderState): TColor; static;
    class function ResolveProgressTextColor(const AAccent: TThemeColor; const AValue: Integer; const AFont: TFont; const AState: TThemedVirtualListCellRenderState): TThemeColor; static;
    class function CalculateImageBounds(const ABounds: TRect; const AImageSize: TSize; const AFitMode: TThemedVirtualListImageFitMode): TRect; static;
    class function CalculateCoverSourceRect(const ABounds: TRect; const AImageSize: TSize): TRect; static;
    class procedure BuildStarPoints(const ABounds: TRect; var APoints: TNimbusPointBuffer; out ACount: Integer); static;
  public
    class procedure RenderText(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AText: string; const AFont: TFont; const AState: TThemedVirtualListCellRenderState; const AAlignment: TAlignment = taLeftJustify; const ARightToLeft: Boolean = False); static;
    class procedure RenderImage(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const ABitmap: Vcl.Graphics.TBitmap; const AFitMode: TThemedVirtualListImageFitMode = vlifContain); static;
    class procedure RenderCheckBox(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const ACheckState: TThemedVirtualListCheckState; const AState: TThemedVirtualListCellRenderState; const AAccentColor: TColor = clHighlight); static;
    class procedure RenderProgressBar(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AValue: Integer; const AFont: TFont; const AState: TThemedVirtualListCellRenderState; const AAccentColor: TColor = clHighlight; const AShowText: Boolean = True); static;
    class procedure RenderBadge(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AText: string; const AFont: TFont; const AState: TThemedVirtualListCellRenderState; const AColor: TColor = clHighlight; const ARightToLeft: Boolean = False); static;
    class procedure RenderColorSwatch(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AColor: TColor; const AFont: TFont; const AState: TThemedVirtualListCellRenderState; const AShowText: Boolean = True; const ARightToLeft: Boolean = False); static;
    class procedure RenderRating(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AValue: Integer; const AState: TThemedVirtualListCellRenderState; const AAccentColor: TColor = clHighlight; const AMaximum: Integer = 5); static;
    class procedure RenderLink(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AText: string; const AFont: TFont; const AState: TThemedVirtualListCellRenderState; const ALinkColor: TColor = clHighlight; const ARightToLeft: Boolean = False); static;
  end;

  TThemedVirtualListColumnGetTextEvent = procedure(Sender: TObject; ARowIndex: Integer; const AItem: TThemedVirtualListItemData; var AText: string) of object;
  TThemedVirtualListColumnSetTextEvent = procedure(Sender: TObject; ARowIndex: Integer; const AItem: TThemedVirtualListItemData; const AText: string; var AAccepted: Boolean) of object;
  TThemedVirtualListColumnRenderCellEvent = procedure(Sender: TObject; const ACanvas: INimbusRenderCanvas; const ABounds: TRect; ARowIndex: Integer; const AItem: TThemedVirtualListItemData; const AState: TThemedVirtualListCellRenderState; var AHandled: Boolean) of object;

  TThemedVirtualListColumn = class(TCollectionItem)
  private
    FHeaderText: string;
    FWidth: Integer;
    FMinWidth: Integer;
    FMaxWidth: Integer;
    FVisible: Boolean;
    FResizable: Boolean;
    FSortable: Boolean;
    FFrozen: Boolean;
    FEditable: Boolean;
    FEditorType: TThemedVirtualListColumnEditorType;
    FAlignment: TAlignment;
    FHeaderAlignment: TAlignment;
    FSortDirection: TThemedVirtualListSortDirection;
    FAutoSizeMode: TThemedVirtualListAutoSizeMode;
    FTag: NativeInt;
    FOnGetText: TThemedVirtualListColumnGetTextEvent;
    FOnSetText: TThemedVirtualListColumnSetTextEvent;
    FOnRenderCell: TThemedVirtualListColumnRenderCellEvent;
    procedure SetHeaderText(const AValue: string);
    procedure SetWidth(const AValue: Integer);
    procedure SetMinWidth(const AValue: Integer);
    procedure SetMaxWidth(const AValue: Integer);
    procedure SetVisible(const AValue: Boolean);
    procedure SetResizable(const AValue: Boolean);
    procedure SetSortable(const AValue: Boolean);
    procedure SetFrozen(const AValue: Boolean);
    procedure SetEditable(const AValue: Boolean);
    procedure SetEditorType(const AValue: TThemedVirtualListColumnEditorType);
    procedure SetAlignment(const AValue: TAlignment);
    procedure SetHeaderAlignment(const AValue: TAlignment);
    procedure SetSortDirection(const AValue: TThemedVirtualListSortDirection);
    procedure SetAutoSizeMode(const AValue: TThemedVirtualListAutoSizeMode);
    procedure SetTag(const AValue: NativeInt);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    function GetText(const ARowIndex: Integer; const AItem: TThemedVirtualListItemData; const ADefaultText: string): string;
    function TrySetText(const ARowIndex: Integer; const AItem: TThemedVirtualListItemData; const AText: string): Boolean;
  published
    property HeaderText: string read FHeaderText write SetHeaderText;
    property Width: Integer read FWidth write SetWidth default 120;
    property MinWidth: Integer read FMinWidth write SetMinWidth default 40;
    property MaxWidth: Integer read FMaxWidth write SetMaxWidth default 1200;
    property Visible: Boolean read FVisible write SetVisible default True;
    property Resizable: Boolean read FResizable write SetResizable default True;
    property Sortable: Boolean read FSortable write SetSortable default True;
    property Frozen: Boolean read FFrozen write SetFrozen default False;
    property Editable: Boolean read FEditable write SetEditable default False;
    property EditorType: TThemedVirtualListColumnEditorType read FEditorType write SetEditorType default vlcetNone;
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property HeaderAlignment: TAlignment read FHeaderAlignment write SetHeaderAlignment default taLeftJustify;
    property SortDirection: TThemedVirtualListSortDirection read FSortDirection write SetSortDirection default vlsdNone;
    property AutoSizeMode: TThemedVirtualListAutoSizeMode read FAutoSizeMode write SetAutoSizeMode default vlasmNone;
    property Tag: NativeInt read FTag write SetTag default 0;
    property OnGetText: TThemedVirtualListColumnGetTextEvent read FOnGetText write FOnGetText;
    property OnSetText: TThemedVirtualListColumnSetTextEvent read FOnSetText write FOnSetText;
    property OnRenderCell: TThemedVirtualListColumnRenderCellEvent read FOnRenderCell write FOnRenderCell;
  end;

  TThemedVirtualListColumnsChangedEvent = procedure(Sender: TObject; AColumn: TThemedVirtualListColumn) of object;

  TThemedVirtualListColumns = class(TOwnedCollection)
  private
    FOnChange: TThemedVirtualListColumnsChangedEvent;
    function GetItem(Index: Integer): TThemedVirtualListColumn;
    procedure SetItem(Index: Integer; const AValue: TThemedVirtualListColumn);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TThemedVirtualListColumn;
    procedure Move(const AOldIndex, ANewIndex: Integer);
    property Items[Index: Integer]: TThemedVirtualListColumn read GetItem write SetItem; default;
    property OnChange: TThemedVirtualListColumnsChangedEvent read FOnChange write FOnChange;
  end;

  TThemedVirtualListGetItemEvent = procedure(Sender: TObject; AIndex: Integer; var AItem: TThemedVirtualListItemData) of object;
  TThemedVirtualListRequestItemsEvent = procedure(Sender: TObject; AStartIndex, ACount: Integer; var AItems: TThemedVirtualListItemDataArray; var ACancel: Boolean) of object;
  TThemedVirtualListRequestItemsAsyncEvent = procedure(Sender: TObject; AStartIndex, ACount: Integer; ARequestToken: Cardinal) of object;
  TThemedVirtualListRequestCancelledEvent = procedure(Sender: TObject; ARequestToken: Cardinal) of object;
  TThemedVirtualListGetCellTextEvent = procedure(Sender: TObject; ARowIndex: Integer; AColumn: TThemedVirtualListColumn; var AText: string) of object;
  TThemedVirtualListItemEvent = procedure(Sender: TObject; AIndex: Integer) of object;
  TThemedVirtualListCheckChangedEvent = procedure(Sender: TObject; AIndex: Integer; AState: TThemedVirtualListCheckState) of object;
  TThemedVirtualListSortRequestedEvent = procedure(Sender: TObject; AColumn: TThemedVirtualListColumn; ADirection: TThemedVirtualListSortDirection; AMultiColumn: Boolean) of object;
  TThemedVirtualListFilterRequestedEvent = procedure(Sender: TObject; const AFilterText: string; var AItemCount: Integer) of object;
  TThemedVirtualListCellValidatingEvent = procedure(Sender: TObject; ARowIndex: Integer; AColumn: TThemedVirtualListColumn; const AOldValue: string; var ANewValue: string; var ACancel: Boolean) of object;
  TThemedVirtualListCellEditCommittedEvent = procedure(Sender: TObject; ARowIndex: Integer; AColumn: TThemedVirtualListColumn; const AOldValue, ANewValue: string) of object;
  TThemedVirtualListGetRowHeightEvent = procedure(Sender: TObject; ARowIndex: Integer; const AItem: TThemedVirtualListItemData; var AHeight: Integer) of object;
  TThemedVirtualListGetRowKindEvent = procedure(Sender: TObject; ARowIndex: Integer; const AItem: TThemedVirtualListItemData; var ARowKind: TThemedVirtualListRowKind) of object;
  TThemedVirtualListGetGroupTextEvent = procedure(Sender: TObject; ARowIndex: Integer; const AItem: TThemedVirtualListItemData; var AText: string) of object;
  TThemedVirtualListRowDetailsExpandedChangedEvent = procedure(Sender: TObject; ARowIndex: Integer; AExpanded: Boolean) of object;

  TThemedVirtualListRenderRowEvent = procedure(Sender: TObject; const ACanvas: INimbusRenderCanvas; const ABounds: TRect; ARowIndex: Integer; const AItem: TThemedVirtualListItemData; const AState: TThemedVirtualListCellRenderState; var AHandled: Boolean) of object;
  TThemedVirtualListRenderCellEvent = procedure(Sender: TObject; const ACanvas: INimbusRenderCanvas; const ABounds: TRect; ARowIndex: Integer; AColumn: TThemedVirtualListColumn; const AItem: TThemedVirtualListItemData; const AState: TThemedVirtualListCellRenderState; var AHandled: Boolean) of object;
  TThemedVirtualListRenderRowDetailsEvent = procedure(Sender: TObject; const ACanvas: INimbusRenderCanvas; const ABounds: TRect; ARowIndex: Integer; const AItem: TThemedVirtualListItemData; const AState: TThemedVirtualListCellRenderState; var AHandled: Boolean) of object;
  TThemedVirtualListGetRowBadgeEvent = procedure(Sender: TObject; ARowIndex: Integer; const AItem: TThemedVirtualListItemData; var ABadge: TThemedVirtualListBadgeData) of object;
  TThemedVirtualListGetCellBadgeEvent = procedure(Sender: TObject; ARowIndex: Integer; AColumn: TThemedVirtualListColumn; const AItem: TThemedVirtualListItemData; var ABadge: TThemedVirtualListBadgeData) of object;

  TCustomThemedVirtualList = class(TCustomNimbusControl)
  private
    FCompactRowApplied: Boolean;
    FCompactHeaderApplied: Boolean;
    FCompactFilterApplied: Boolean;
    FCompactGroupApplied: Boolean;
    FStyleMetricsApplying: Boolean;
    FItemCount: Integer;
    FItemHeight: Integer;
    FScrollOffset: Integer;
    FScrollBarWidth: Integer;
    FWheelScrollItems: Integer;
    FCurrentIndex: Integer;
    FAnchorIndex: Integer;
    FHoverIndex: Integer;
    FPressedIndex: Integer;
    FPressedCheck: Boolean;
    FSelectedCount: Integer;
    FCheckedStateCount: Integer;
    FMultiSelect: Boolean;
    FCheckBoxes: Boolean;
    FTriStateCheckBoxes: Boolean;
    FShowSubtitles: Boolean;
    FShowDetails: Boolean;
    FShowProgress: Boolean;
    FRoundedSelection: Boolean;
    FAlternatingRows: Boolean;
    FHotTrack: Boolean;
    FScrollBarMode: TThemedVirtualListScrollBarMode;
    FEmptyText: string;
    FImages: TCustomImageList;
    FImageChangeLink: TChangeLink;
    FImageBuffer: Vcl.Graphics.TBitmap;
    FScrollBar: TThemedVScrollBar;
    FHorizontalScrollBar: TThemedHScrollBar;
    FUpdatingScrollBar: Boolean;
    FUpdatingHorizontalScrollBar: Boolean;
    FHorizontalOffset: Integer;
    FColumns: TThemedVirtualListColumns;
    FSelectionMode: TThemedVirtualListSelectionMode;
    FShowHeader: Boolean;
    FHeaderHeight: Integer;
    FFilterHeight: Integer;
    FShowFilterRow: Boolean;
    FShowGlobalSearch: Boolean;
    FShowRowDetails: Boolean;
    FShowGroupHeaders: Boolean;
    FShowSeparators: Boolean;
    FDetailsHeight: Integer;
    FGroupHeaderHeight: Integer;
    FGlobalFilterBox: TEdit;
    FGlobalFilterPlaceholderActive: Boolean;
    FUpdatingGlobalFilterBox: Boolean;
    FFilterDebounceTimer: TTimer;
    FActiveEditor: TEdit;
    FEditingRowIndex: Integer;
    FEditingColumn: TThemedVirtualListColumn;
    FEditingOldValue: string;
    FEndingEdit: Boolean;
    FAllowColumnReorder: Boolean;
    FHeaderHoverColumn: Integer;
    FResizeColumn: Integer;
    FResizeStartX: Integer;
    FResizeStartWidth: Integer;
    FReorderColumn: Integer;
    FReorderTarget: Integer;
    FReorderStartX: Integer;
    FReorderDragging: Boolean;
    FUpdateCount: Integer;
    FPageSize: Integer;
    FMaxCachedPages: Integer;
    FLoadingPlaceholders: Boolean;
    FShowRowBadges: Boolean;
    FShowCellBadges: Boolean;
    FRowBadgeOptions: TThemedVirtualListBadgeRenderOptions;
    FCellBadgeOptions: TThemedVirtualListBadgeRenderOptions;
    FAutoSizePending: Boolean;
    FAutoSizeReset: Boolean;
    FAutoSizingColumns: Boolean;
    FRequestPending: Boolean;
    FCacheTouch: UInt64;
    FCacheGeneration: Cardinal;
    FCachePages: TList;
    FPendingRequests: TList;
    FNextRequestToken: Cardinal;
    FSelected: array of Byte;
    FCheckStates: array of Byte;
    FExpandedDetails: array of Byte;
    FMetrics: TThemedVirtualListItemMetrics;
    FOnGetItem: TThemedVirtualListGetItemEvent;
    FOnRequestItems: TThemedVirtualListRequestItemsEvent;
    FOnRequestItemsAsync: TThemedVirtualListRequestItemsAsyncEvent;
    FOnRequestItemsCancelled: TThemedVirtualListRequestCancelledEvent;
    FOnGetCellText: TThemedVirtualListGetCellTextEvent;
    FOnSortRequested: TThemedVirtualListSortRequestedEvent;
    FOnFilterRequested: TThemedVirtualListFilterRequestedEvent;
    FOnCellValidating: TThemedVirtualListCellValidatingEvent;
    FOnCellEditCommitted: TThemedVirtualListCellEditCommittedEvent;
    FOnGetRowHeight: TThemedVirtualListGetRowHeightEvent;
    FOnGetRowKind: TThemedVirtualListGetRowKindEvent;
    FOnGetGroupText: TThemedVirtualListGetGroupTextEvent;
    FOnRowDetailsExpandedChanged: TThemedVirtualListRowDetailsExpandedChangedEvent;
    FOnRenderRow: TThemedVirtualListRenderRowEvent;
    FOnRenderCell: TThemedVirtualListRenderCellEvent;
    FOnRenderRowDetails: TThemedVirtualListRenderRowDetailsEvent;
    FOnGetRowBadge: TThemedVirtualListGetRowBadgeEvent;
    FOnGetCellBadge: TThemedVirtualListGetCellBadgeEvent;
    FOnSelectionChanged: TNotifyEvent;
    FOnItemClick: TThemedVirtualListItemEvent;
    FOnItemDoubleClick: TThemedVirtualListItemEvent;
    FOnItemActivate: TThemedVirtualListItemEvent;
    FOnCheckStateChanged: TThemedVirtualListCheckChangedEvent;
    FOnScroll: TNotifyEvent;
    procedure ColumnsChanged(Sender: TObject; AColumn: TThemedVirtualListColumn);
    procedure SetColumns(const AValue: TThemedVirtualListColumns);
    procedure SetSelectionMode(const AValue: TThemedVirtualListSelectionMode);
    procedure SetShowHeader(const AValue: Boolean);
    procedure SetHeaderHeight(const AValue: Integer);
    procedure SetFilterHeight(const AValue: Integer);
    procedure SetShowFilterRow(const AValue: Boolean);
    procedure SetShowGlobalSearch(const AValue: Boolean);
    procedure SetShowRowDetails(const AValue: Boolean);
    procedure SetShowGroupHeaders(const AValue: Boolean);
    procedure SetShowSeparators(const AValue: Boolean);
    procedure SetDetailsHeight(const AValue: Integer);
    procedure SetGroupHeaderHeight(const AValue: Integer);
    procedure GlobalFilterBoxChanged(Sender: TObject);
    procedure GlobalFilterBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GlobalFilterBoxFocusChanged(Sender: TObject);
    procedure UpdateGlobalFilterPlaceholder;
    function GetGlobalFilterText: string;
    procedure FilterDebounceTimerTimer(Sender: TObject);
    procedure ActiveEditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ActiveEditorExit(Sender: TObject);
    procedure BeginEditFocusedCell;
    procedure BeginCellEdit(const ARowIndex: Integer; AColumn: TThemedVirtualListColumn);
    procedure EndCellEdit(const ACommit: Boolean);
    procedure UpdateActiveEditorBounds;
    procedure UpdateFilterEditorBounds;
    procedure UpdateFilterEditorTheme;
    procedure SetAllowColumnReorder(const AValue: Boolean);
    procedure SetHorizontalOffset(const AValue: Integer);
    procedure SetPageSize(const AValue: Integer);
    procedure SetMaxCachedPages(const AValue: Integer);
    procedure SetLoadingPlaceholders(const AValue: Boolean);
    procedure SetShowRowBadges(const AValue: Boolean);
    procedure SetShowCellBadges(const AValue: Boolean);
    procedure SetRowBadgeOptions(const AValue: TThemedVirtualListBadgeRenderOptions);
    procedure SetCellBadgeOptions(const AValue: TThemedVirtualListBadgeRenderOptions);
    procedure BadgeOptionsChanged(Sender: TObject);
    procedure SetOnRequestItems(const AValue: TThemedVirtualListRequestItemsEvent);
    procedure SetOnRequestItemsAsync(const AValue: TThemedVirtualListRequestItemsAsyncEvent);
    procedure HorizontalScrollBarChanged(Sender: TObject);
    function GetControlClientRect: TRect;
    function GetHeaderHeightPixels: Integer;
    function GetFilterHeightPixels: Integer;
    function GetTopOffsetPixels: Integer;
    function GetGlobalSearchRect: TRect;
    function GetHeaderRect: TRect;
    function GetFilterRect: TRect;
    function GetCheckColumnWidth: Integer;
    function GetDetailsColumnWidth: Integer;
    function GetDetailsHeightPixels: Integer;
    function GetGroupHeaderHeightPixels: Integer;
    function GetFrozenColumnsWidth: Integer;
    function GetScrollableColumnsWidth: Integer;
    function GetMaxHorizontalOffset: Integer;
    function IsTableMode: Boolean;
    function GetColumnRect(const AColumnIndex: Integer; const ATop, ABottom: Integer): TRect;
    function HitTestColumn(const AX, AY: Integer): Integer;
    function HitTestColumnResize(const AX, AY: Integer): Integer;
    function HitTestColumnInsertion(const AX: Integer): Integer;
    function GetColumnInsertionX(const AIndex: Integer): Integer;
    function GetCellText(const ARowIndex: Integer; AColumn: TThemedVirtualListColumn): string;
    function ResolveCellText(const ARowIndex: Integer; AColumn: TThemedVirtualListColumn; const AItem: TThemedVirtualListItemData): string;
    function HasAutoSizeColumns: Boolean;
    procedure QueueAutoSizeColumns(const AReset: Boolean = False);
    function MeasureAutoSizeColumn(AColumn: TThemedVirtualListColumn): Integer;
    procedure ApplyAutoSizeColumns;
    function GetTableCellRect(const ARowIndex, AColumnIndex: Integer): TRect;
    function GetTableCheckRect(const AIndex: Integer): TRect;
    function GetVisibleRowRect(const AIndex: Integer): TRect;
    function GetDetailsGlyphRect(const AIndex: Integer): TRect;
    function GetDetailsGlyphRectFromRow(const ARow: TRect): TRect;
    function ResolveRowHeight(const AIndex: Integer; const AItem: TThemedVirtualListItemData): Integer;
    function ResolveRowKind(const AIndex: Integer; const AItem: TThemedVirtualListItemData): TThemedVirtualListRowKind;
    function ResolveGroupText(const AIndex: Integer; const AItem: TThemedVirtualListItemData): string;
    function BuildCellRenderState(const AIndex: Integer; const AItem: TThemedVirtualListItemData; const AHasItem: Boolean): TThemedVirtualListCellRenderState;
    function ResolveBadgeColor(const ABadge: TThemedVirtualListBadgeData; const AFallback: TColor): TColor;
    procedure RenderBadgeData(const ABounds: TRect; const ABadge: TThemedVirtualListBadgeData; const ASelected, AEnabled: Boolean; const AOptions: TThemedVirtualListBadgeRenderOptions);
    procedure RenderRowBadge(const AIndex: Integer; const ABounds: TRect; const AItem: TThemedVirtualListItemData);
    procedure RenderCellBadge(const AIndex: Integer; AColumn: TThemedVirtualListColumn; const ABounds: TRect; const AItem: TThemedVirtualListItemData; const ASelected, AEnabled: Boolean);
    function GetDetailsExpanded(AIndex: Integer): Boolean;
    procedure ToggleSort(const AColumnIndex: Integer; const AMultiColumn: Boolean);
    procedure CopySelectionToClipboard;
    procedure InitializeItemData(out AItem: TThemedVirtualListItemData);
    procedure NormalizeItemData(var AItem: TThemedVirtualListItemData);
    procedure ClearItemCache;
    procedure CancelPendingRequests(const ANotify: Boolean);
    function HasDataProvider: Boolean;
    procedure ClearCachedPageForIndex(const AIndex: Integer);
    procedure TrimItemCache;
    function TryGetCachedItem(const AIndex: Integer; out AItem: TThemedVirtualListItemData): Boolean;
    procedure SetCachedPage(const APageIndex: Integer; const AItems: TThemedVirtualListItemDataArray);
    function IsPageCachedOrLoading(const APageIndex: Integer): Boolean;
    procedure RequestPage(const APageIndex: Integer);
    procedure RequestVisiblePages;
    procedure ScheduleRequest;
    procedure RenderGlobalSearch;
    procedure RenderFilterRow;
    procedure RenderTable(const AArea: TRect);
    procedure RenderTableHeader(const AHeader: TRect);
    procedure RenderTableRow(const AIndex: Integer; const ABounds: TRect; const AItem: TThemedVirtualListItemData; const AHasItem: Boolean);
    procedure RenderRowDetails(const AIndex: Integer; const ABounds: TRect; const AItem: TThemedVirtualListItemData; const AHasItem: Boolean);
    procedure SetItemCount(const AValue: Integer);
    procedure SetItemHeight(const AValue: Integer);
    procedure SetScrollBarWidth(const AValue: Integer);
    procedure SetWheelScrollItems(const AValue: Integer);
    procedure SetSelectedIndex(const AValue: Integer);
    procedure SetMultiSelect(const AValue: Boolean);
    procedure SetCheckBoxes(const AValue: Boolean);
    procedure SetTriStateCheckBoxes(const AValue: Boolean);
    procedure SetShowSubtitles(const AValue: Boolean);
    procedure SetShowDetails(const AValue: Boolean);
    procedure SetShowProgress(const AValue: Boolean);
    procedure SetRoundedSelection(const AValue: Boolean);
    procedure SetAlternatingRows(const AValue: Boolean);
    procedure SetHotTrack(const AValue: Boolean);
    procedure SetScrollBarMode(const AValue: TThemedVirtualListScrollBarMode);
    procedure SetEmptyText(const AValue: string);
    procedure SetImages(const AValue: TCustomImageList);
    procedure ImageListChanged(Sender: TObject);
    procedure ScrollBarChanged(Sender: TObject);
    procedure SetScrollOffset(const AValue: Integer);
    function GetItemHeightPixels: Integer;
    function GetItemArea: TRect;
    function GetMaxScrollOffset: Integer;
    function GetTopIndex: Integer;
    procedure SetTopIndex(const AValue: Integer);
    function GetSelected(AIndex: Integer): Boolean;
    function GetSelectedIndices: TThemedVirtualListIndexArray;
    function GetSelectedItems: TThemedVirtualListItemDataArray;
    function GetCheckedIndices: TThemedVirtualListIndexArray;
    function GetCheckedCount: Integer;
    function GetSelectedCheckedIndices: TThemedVirtualListIndexArray;
    function GetSelectedCheckedCount: Integer;
    function CollectCheckedIndices(const ASelectedOnly: Boolean): TThemedVirtualListIndexArray;
    procedure ChangeChecks(const ASelectedOnly, AInvert, AValue: Boolean);
    procedure SetSelected(AIndex: Integer; const AValue: Boolean);
    function GetCheckState(AIndex: Integer): TThemedVirtualListCheckState;
    procedure SetCheckState(AIndex: Integer; const AValue: TThemedVirtualListCheckState);
    procedure UpdateMetrics;
    procedure UpdateScrollBar;
    procedure UpdateHover(const AX, AY: Integer);
    procedure ClearSelectionInternal;
    procedure SetOnlySelected(const AIndex: Integer);
    procedure ToggleSelected(const AIndex: Integer);
    procedure SelectRange(const AFirst, ALast: Integer; const AClearFirst: Boolean);
    procedure DoSelectionChanged;
    procedure DoItemClick(const AIndex: Integer);
    procedure DoItemDoubleClick(const AIndex: Integer);
    procedure DoItemActivate(const AIndex: Integer);
    procedure DoCheckStateChanged(const AIndex: Integer);
    function TryGetItemData(const AIndex: Integer; out AItem: TThemedVirtualListItemData): Boolean;
    procedure GetItemData(const AIndex: Integer; out AItem: TThemedVirtualListItemData);
    function IsItemEnabled(const AIndex: Integer): Boolean;
    function FindEnabledIndex(const AStart, ADirection: Integer): Integer;
    function HitTestItem(const AX, AY: Integer): Integer;
    function HitTestCheck(const AIndex, AX, AY: Integer): Boolean;
    function BuildRenderContext(const AIndex: Integer; const ABounds: TRect): TThemedVirtualListItemRenderContext;
    procedure InvalidateItem(const AIndex: Integer);
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;
    procedure CMBiDiModeChanged(var Message: TMessage); message CM_BIDIMODECHANGED;
    procedure CMEnter(var Message: TCMEnter); message CM_ENTER;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMCaptureChanged(var Message: TMessage); message WM_CAPTURECHANGED;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMRequestItems(var Message: TMessage); message WM_NIMBUS_VIRTUALLIST_REQUEST;
  protected
    procedure StyleModeChanged; override;
    procedure Paint; override;
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure Resize; override;
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DblClick; override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    property Columns: TThemedVirtualListColumns read FColumns write SetColumns;
    property SelectionMode: TThemedVirtualListSelectionMode read FSelectionMode write SetSelectionMode default vlsmMulti;
    property ShowHeader: Boolean read FShowHeader write SetShowHeader default True;
    property HeaderHeight: Integer read FHeaderHeight write SetHeaderHeight default 26;
    property FilterHeight: Integer read FFilterHeight write SetFilterHeight default 26;
    property ShowFilterRow: Boolean read FShowFilterRow write SetShowFilterRow default False;
    property ShowGlobalSearch: Boolean read FShowGlobalSearch write SetShowGlobalSearch default False;
    property ShowRowDetails: Boolean read FShowRowDetails write SetShowRowDetails default False;
    property ShowGroupHeaders: Boolean read FShowGroupHeaders write SetShowGroupHeaders default False;
    property ShowSeparators: Boolean read FShowSeparators write SetShowSeparators default False;
    property DetailsHeight: Integer read FDetailsHeight write SetDetailsHeight default 70;
    property GroupHeaderHeight: Integer read FGroupHeaderHeight write SetGroupHeaderHeight default 24;
    property AllowColumnReorder: Boolean read FAllowColumnReorder write SetAllowColumnReorder default True;
    property HorizontalOffset: Integer read FHorizontalOffset write SetHorizontalOffset default 0;
    property PageSize: Integer read FPageSize write SetPageSize default 50;
    property MaxCachedPages: Integer read FMaxCachedPages write SetMaxCachedPages default 32;
    property LoadingPlaceholders: Boolean read FLoadingPlaceholders write SetLoadingPlaceholders default True;
    property ShowRowBadges: Boolean read FShowRowBadges write SetShowRowBadges default True;
    property ShowCellBadges: Boolean read FShowCellBadges write SetShowCellBadges default True;
    property RowBadgeOptions: TThemedVirtualListBadgeRenderOptions read FRowBadgeOptions write SetRowBadgeOptions;
    property CellBadgeOptions: TThemedVirtualListBadgeRenderOptions read FCellBadgeOptions write SetCellBadgeOptions;
    property ShowCheckBoxColumn: Boolean read FCheckBoxes write SetCheckBoxes default False;
    property AlternateRowColor: Boolean read FAlternatingRows write SetAlternatingRows default True;
    property HoverHighlight: Boolean read FHotTrack write SetHotTrack default True;
    property RowHeight: Integer read FItemHeight write SetItemHeight default 24;
    property ScrollBarSize: Integer read FScrollBarWidth write SetScrollBarWidth default 10;
    property ItemCount: Integer read FItemCount write SetItemCount default 0;
    property ItemHeight: Integer read FItemHeight write SetItemHeight default 24;
    property ScrollBarWidth: Integer read FScrollBarWidth write SetScrollBarWidth default 10;
    property WheelScrollItems: Integer read FWheelScrollItems write SetWheelScrollItems default 3;
    property SelectedIndex: Integer read FCurrentIndex write SetSelectedIndex default -1;
    property MultiSelect: Boolean read FMultiSelect write SetMultiSelect default True;
    property CheckBoxes: Boolean read FCheckBoxes write SetCheckBoxes default False;
    property TriStateCheckBoxes: Boolean read FTriStateCheckBoxes write SetTriStateCheckBoxes default False;
    property ShowSubtitles: Boolean read FShowSubtitles write SetShowSubtitles default True;
    property ShowDetails: Boolean read FShowDetails write SetShowDetails default True;
    property ShowProgress: Boolean read FShowProgress write SetShowProgress default True;
    property RoundedSelection: Boolean read FRoundedSelection write SetRoundedSelection default True;
    property AlternatingRows: Boolean read FAlternatingRows write SetAlternatingRows default True;
    property HotTrack: Boolean read FHotTrack write SetHotTrack default True;
    property ScrollBarMode: TThemedVirtualListScrollBarMode read FScrollBarMode write SetScrollBarMode default vlsbAuto;
    property EmptyText: string read FEmptyText write SetEmptyText;
    property Images: TCustomImageList read FImages write SetImages;
    property OnGetItem: TThemedVirtualListGetItemEvent read FOnGetItem write FOnGetItem;
    property OnRequestItems: TThemedVirtualListRequestItemsEvent read FOnRequestItems write SetOnRequestItems;
    property OnRequestItemsAsync: TThemedVirtualListRequestItemsAsyncEvent read FOnRequestItemsAsync write SetOnRequestItemsAsync;
    property OnRequestItemsCancelled: TThemedVirtualListRequestCancelledEvent read FOnRequestItemsCancelled write FOnRequestItemsCancelled;
    property OnGetCellText: TThemedVirtualListGetCellTextEvent read FOnGetCellText write FOnGetCellText;
    property OnSortRequested: TThemedVirtualListSortRequestedEvent read FOnSortRequested write FOnSortRequested;
    property OnFilterRequested: TThemedVirtualListFilterRequestedEvent read FOnFilterRequested write FOnFilterRequested;
    property OnCellValidating: TThemedVirtualListCellValidatingEvent read FOnCellValidating write FOnCellValidating;
    property OnCellEditCommitted: TThemedVirtualListCellEditCommittedEvent read FOnCellEditCommitted write FOnCellEditCommitted;
    property OnGetRowHeight: TThemedVirtualListGetRowHeightEvent read FOnGetRowHeight write FOnGetRowHeight;
    property OnGetRowKind: TThemedVirtualListGetRowKindEvent read FOnGetRowKind write FOnGetRowKind;
    property OnGetGroupText: TThemedVirtualListGetGroupTextEvent read FOnGetGroupText write FOnGetGroupText;
    property OnRowDetailsExpandedChanged: TThemedVirtualListRowDetailsExpandedChangedEvent read FOnRowDetailsExpandedChanged write FOnRowDetailsExpandedChanged;
    property OnRenderRow: TThemedVirtualListRenderRowEvent read FOnRenderRow write FOnRenderRow;
    property OnRenderCell: TThemedVirtualListRenderCellEvent read FOnRenderCell write FOnRenderCell;
    property OnRenderRowDetails: TThemedVirtualListRenderRowDetailsEvent read FOnRenderRowDetails write FOnRenderRowDetails;
    property OnGetRowBadge: TThemedVirtualListGetRowBadgeEvent read FOnGetRowBadge write FOnGetRowBadge;
    property OnGetCellBadge: TThemedVirtualListGetCellBadgeEvent read FOnGetCellBadge write FOnGetCellBadge;
    property OnSelectionChanged: TNotifyEvent read FOnSelectionChanged write FOnSelectionChanged;
    property OnItemClick: TThemedVirtualListItemEvent read FOnItemClick write FOnItemClick;
    property OnItemDoubleClick: TThemedVirtualListItemEvent read FOnItemDoubleClick write FOnItemDoubleClick;
    property OnItemActivate: TThemedVirtualListItemEvent read FOnItemActivate write FOnItemActivate;
    property OnCheckStateChanged: TThemedVirtualListCheckChangedEvent read FOnCheckStateChanged write FOnCheckStateChanged;
    property OnScroll: TNotifyEvent read FOnScroll write FOnScroll;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette); override;
    procedure RefreshData;
    procedure CompleteRequest(const ARequestToken: Cardinal; const AItems: TThemedVirtualListItemDataArray; const ACancelled: Boolean = False);
    procedure AutoSizeColumns;
    procedure RefreshItems;
    procedure RefreshItem(const AIndex: Integer);
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure ScrollToIndex(const AIndex: Integer);
    procedure ClearSelection;
    procedure SelectAll;
    procedure InvertSelection;
    procedure CheckAll;
    procedure UncheckAll;
    procedure InvertChecked;
    procedure CheckSelected;
    procedure UncheckSelected;
    function IsSelected(AIndex: Integer): Boolean;
    function IsChecked(AIndex: Integer): Boolean;
    function GetAllChecked: TThemedVirtualListIndexArray;
    procedure MakeVisible(const AIndex: Integer);
    procedure ScrollTo(const AIndex: Integer);
    procedure BeginEdit;
    procedure CancelEdit;
    procedure ToggleDetails(const AIndex: Integer);
    procedure CollapseAllDetails;
    function GetChecked(AIndex: Integer): Boolean;
    procedure SetChecked(AIndex: Integer; const AValue: Boolean);
    function ItemAtPos(const APoint: TPoint): Integer;
    property Selected[AIndex: Integer]: Boolean read GetSelected write SetSelected;
    property CheckState[AIndex: Integer]: TThemedVirtualListCheckState read GetCheckState write SetCheckState;
    property Checked[AIndex: Integer]: Boolean read GetChecked write SetChecked;
    property DetailsExpanded[AIndex: Integer]: Boolean read GetDetailsExpanded;
    property SelectedCount: Integer read FSelectedCount;
    property SelectedIndices: TThemedVirtualListIndexArray read GetSelectedIndices;
    property SelectedItems: TThemedVirtualListItemDataArray read GetSelectedItems;
    property CheckedIndices: TThemedVirtualListIndexArray read GetCheckedIndices;
    property CheckedCount: Integer read GetCheckedCount;
    property SelectedCheckedIndices: TThemedVirtualListIndexArray read GetSelectedCheckedIndices;
    property SelectedCheckedCount: Integer read GetSelectedCheckedCount;
    property TopIndex: Integer read GetTopIndex write SetTopIndex;
    property ScrollOffset: Integer read FScrollOffset write SetScrollOffset;
    property ScrollBar: TThemedVScrollBar read FScrollBar;
    property HorizontalScrollBar: TThemedHScrollBar read FHorizontalScrollBar;
  end;

  TThemedVirtualList = class(TCustomThemedVirtualList)
  published
    property StyleMode;
    property Align;
    property Anchors;
    property BiDiMode;
    property Color;
    property Constraints;
    property Enabled;
    property Font;
    property ParentBiDiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property Columns;
    property SelectionMode;
    property ShowHeader;
    property HeaderHeight;
    property FilterHeight;
    property ShowFilterRow;
    property ShowGlobalSearch;
    property ShowRowDetails;
    property ShowGroupHeaders;
    property ShowSeparators;
    property DetailsHeight;
    property GroupHeaderHeight;
    property AllowColumnReorder;
    property ShowCheckBoxColumn;
    property AlternateRowColor;
    property HoverHighlight;
    property RowHeight;
    property ScrollBarSize;
    property PageSize;
    property MaxCachedPages;
    property LoadingPlaceholders;
    property ShowRowBadges;
    property ShowCellBadges;
    property RowBadgeOptions;
    property CellBadgeOptions;
    property ItemCount;
    property ItemHeight;
    property ScrollBarWidth;
    property WheelScrollItems;
    property SelectedIndex;
    property MultiSelect;
    property CheckBoxes;
    property TriStateCheckBoxes;
    property ShowSubtitles;
    property ShowDetails;
    property ShowProgress;
    property RoundedSelection;
    property AlternatingRows;
    property HotTrack;
    property ScrollBarMode;
    property EmptyText;
    property Images;
    property OnGetItem;
    property OnRequestItems;
    property OnRequestItemsAsync;
    property OnRequestItemsCancelled;
    property OnGetCellText;
    property OnSortRequested;
    property OnFilterRequested;
    property OnCellValidating;
    property OnCellEditCommitted;
    property OnGetRowHeight;
    property OnGetRowKind;
    property OnGetGroupText;
    property OnRowDetailsExpandedChanged;
    property OnRenderRow;
    property OnRenderCell;
    property OnRenderRowDetails;
    property OnGetRowBadge;
    property OnGetCellBadge;
    property OnSelectionChanged;
    property OnItemClick;
    property OnItemDoubleClick;
    property OnItemActivate;
    property OnCheckStateChanged;
    property OnScroll;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
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
    property OnMouseWheel;
  end;

implementation

uses
  System.SysUtils,
  System.Math,
  Vcl.Clipbrd,
  Vcl.Forms,
  NimbusForms.Rendering.Types;

resourcestring
  SVirtualListSearchPlaceholder = 'Search...';
  SVirtualListDefaultGroup = 'Group';

type
  TThemedVirtualListPendingRequest = class
  public
    Token: Cardinal;
    PageIndex: Integer;
    Generation: Cardinal;
    StartIndex: Integer;
    Count: Integer;
  end;

  TThemedVirtualListCachePage = class
  public
    PageIndex: Integer;
    Items: TThemedVirtualListItemDataArray;
    Touch: UInt64;
    Loading: Boolean;
    Loaded: Boolean;
  end;

class function TThemedVirtualCellRenderer.ResolveTextColor(const AFont: TFont; const AState: TThemedVirtualListCellRenderState): TColor;
begin
  if not AState.Enabled then Exit(clGrayText);
  if AState.Selected then Exit(clHighlightText);
  if AFont <> nil then Exit(AFont.Color);
  Result := clWindowText;
end;

class function TThemedVirtualCellRenderer.ResolveAccentColor(const AColor: TColor; const AState: TThemedVirtualListCellRenderState): TColor;
begin
  if not AState.Enabled then Exit(clGrayText);
  if AState.Selected then Exit(clHighlightText);
  if AColor = clNone then Exit(clHighlight);
  Result := AColor;
end;

class function TThemedVirtualCellRenderer.ResolveProgressTextColor(const AAccent: TThemeColor; const AValue: Integer; const AFont: TFont; const AState: TThemedVirtualListCellRenderState): TThemeColor;
var
  LLuminance, LWeight: Integer;
  LLight, LDark: TThemeColor;
begin
  if AValue < 50 then Exit(ColorToThemeColor(ResolveTextColor(AFont, AState)));
  LLuminance := (ThemeColorRed(AAccent) * 299 + ThemeColorGreen(AAccent) * 587 + ThemeColorBlue(AAccent) * 114) div 1000;
  LWeight := EnsureRange(MulDiv(LLuminance - 105, 255, 50), 0, 255);
  LLight := ThemeColor(255, 248, 250, 252);
  LDark := ThemeColor(255, 20, 24, 30);
  Result := NimbusBlendColor(LLight, LDark, Byte(LWeight));
end;

class function TThemedVirtualCellRenderer.CalculateImageBounds(const ABounds: TRect; const AImageSize: TSize; const AFitMode: TThemedVirtualListImageFitMode): TRect;
var
  LScale: Double;
  LWidth, LHeight: Integer;
begin
  Result := ABounds;
  if NimbusRectIsEmpty(ABounds) or (AImageSize.cx <= 0) or (AImageSize.cy <= 0) then Exit;
  case AFitMode of
    vlifStretch, vlifCover: Exit;
    vlifCenter:
      begin
        LWidth := Min(AImageSize.cx, ABounds.Width);
        LHeight := Min(AImageSize.cy, ABounds.Height);
      end;
  else
    LScale := Min(ABounds.Width / AImageSize.cx, ABounds.Height / AImageSize.cy);
    LWidth := Max(1, Round(AImageSize.cx * LScale));
    LHeight := Max(1, Round(AImageSize.cy * LScale));
  end;
  Result := Rect(ABounds.Left + (ABounds.Width - LWidth) div 2, ABounds.Top + (ABounds.Height - LHeight) div 2, ABounds.Left + (ABounds.Width - LWidth) div 2 + LWidth, ABounds.Top + (ABounds.Height - LHeight) div 2 + LHeight);
end;

class function TThemedVirtualCellRenderer.CalculateCoverSourceRect(const ABounds: TRect; const AImageSize: TSize): TRect;
var
  LTargetRatio, LImageRatio: Double;
  LWidth, LHeight: Integer;
begin
  Result := Rect(0, 0, AImageSize.cx, AImageSize.cy);
  if NimbusRectIsEmpty(ABounds) or (AImageSize.cx <= 0) or (AImageSize.cy <= 0) then Exit;
  LTargetRatio := ABounds.Width / ABounds.Height;
  LImageRatio := AImageSize.cx / AImageSize.cy;
  if LImageRatio > LTargetRatio then
  begin
    LWidth := Max(1, Round(AImageSize.cy * LTargetRatio));
    Result.Left := (AImageSize.cx - LWidth) div 2;
    Result.Right := Result.Left + LWidth;
  end
  else if LImageRatio < LTargetRatio then
  begin
    LHeight := Max(1, Round(AImageSize.cx / LTargetRatio));
    Result.Top := (AImageSize.cy - LHeight) div 2;
    Result.Bottom := Result.Top + LHeight;
  end;
end;

class procedure TThemedVirtualCellRenderer.BuildStarPoints(const ABounds: TRect; var APoints: TNimbusPointBuffer; out ACount: Integer);
var
  I: Integer;
  LCenterX, LCenterY, LOuterRadius, LInnerRadius, LAngle, LRadius: Double;
begin
  ACount := 0;
  if NimbusRectIsEmpty(ABounds) then Exit;
  LCenterX := (ABounds.Left + ABounds.Right - 1) / 2;
  LCenterY := (ABounds.Top + ABounds.Bottom - 1) / 2;
  LOuterRadius := Max(1.0, Min(ABounds.Width, ABounds.Height) / 2 - 1);
  LInnerRadius := LOuterRadius * 0.46;
  for I := 0 to 9 do
  begin
    if Odd(I) then LRadius := LInnerRadius else LRadius := LOuterRadius;
    LAngle := -Pi / 2 + I * Pi / 5;
    APoints[I] := Point(Round(LCenterX + Cos(LAngle) * LRadius), Round(LCenterY + Sin(LAngle) * LRadius));
  end;
  ACount := 10;
end;

class procedure TThemedVirtualCellRenderer.RenderText(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AText: string; const AFont: TFont; const AState: TThemedVirtualListCellRenderState; const AAlignment: TAlignment; const ARightToLeft: Boolean);
var
  LFlags: TNimbusTextFlags;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(ABounds) or (AFont = nil) then Exit;
  LFlags := [ntfSingleLine, ntfVCenter, ntfEndEllipsis, ntfNoPrefix];
  case AAlignment of
    taRightJustify: Include(LFlags, ntfRight);
    taCenter: Include(LFlags, ntfCenter);
  end;
  if ARightToLeft then Include(LFlags, ntfRightToLeft);
  ACanvas.DrawText(AText, AFont, ColorToThemeColor(ResolveTextColor(AFont, AState)), ABounds, LFlags);
end;

class procedure TThemedVirtualCellRenderer.RenderImage(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const ABitmap: Vcl.Graphics.TBitmap; const AFitMode: TThemedVirtualListImageFitMode);
var
  LDest, LSource: TRect;
  LWidth, LHeight: Integer;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(ABounds) or (ABitmap = nil) or ABitmap.Empty then Exit;
  if AFitMode = vlifCover then
  begin
    LSource := CalculateCoverSourceRect(ABounds, TSize.Create(ABitmap.Width, ABitmap.Height));
    if not NimbusRectIsEmpty(LSource) then ACanvas.DrawBitmapPart(ABitmap, ABounds, LSource);
    Exit;
  end;
  if AFitMode = vlifCenter then
  begin
    LWidth := Min(ABitmap.Width, ABounds.Width);
    LHeight := Min(ABitmap.Height, ABounds.Height);
    LDest := Rect(ABounds.Left + (ABounds.Width - LWidth) div 2, ABounds.Top + (ABounds.Height - LHeight) div 2, ABounds.Left + (ABounds.Width - LWidth) div 2 + LWidth, ABounds.Top + (ABounds.Height - LHeight) div 2 + LHeight);
    LSource := Rect((ABitmap.Width - LWidth) div 2, (ABitmap.Height - LHeight) div 2, (ABitmap.Width - LWidth) div 2 + LWidth, (ABitmap.Height - LHeight) div 2 + LHeight);
    if not NimbusRectIsEmpty(LDest) and not NimbusRectIsEmpty(LSource) then ACanvas.DrawBitmapPart(ABitmap, LDest, LSource);
    Exit;
  end;
  LDest := CalculateImageBounds(ABounds, TSize.Create(ABitmap.Width, ABitmap.Height), AFitMode);
  if not NimbusRectIsEmpty(LDest) then ACanvas.DrawBitmap(ABitmap, LDest);
end;

class procedure TThemedVirtualCellRenderer.RenderCheckBox(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const ACheckState: TThemedVirtualListCheckState; const AState: TThemedVirtualListCellRenderState; const AAccentColor: TColor);
var
  LBox: TRect;
  LSize, LRadius, LPad: Integer;
  LBorder, LFill, LMark: TThemeColor;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(ABounds) then Exit;
  LSize := EnsureRange(MulDiv(ABounds.Height, 14, 24), 12, 22);
  LPad := Max(2, MulDiv(ABounds.Height, 5, 24));
  LBox := Rect(ABounds.Left + LPad, ABounds.Top + (ABounds.Height - LSize) div 2, ABounds.Left + LPad + LSize, ABounds.Top + (ABounds.Height - LSize) div 2 + LSize);
  LRadius := Max(2, LSize div 5);
  LBorder := ColorToThemeColor(ResolveAccentColor(AAccentColor, AState));
  LFill := NimbusColorWithAlpha(LBorder, 52);
  LMark := LBorder;
  if ACheckState <> vlcsUnchecked then ACanvas.FillRoundedRectangle(LFill, LBox, LRadius);
  ACanvas.DrawRoundedRectangle(LBorder, LBox, LRadius, 1.25);
  if ACheckState = vlcsChecked then
  begin
    ACanvas.DrawLine(LMark, LBox.Left + LSize div 4, LBox.Top + LSize div 2, LBox.Left + LSize * 2 div 5, LBox.Bottom - LSize div 4, 1.8);
    ACanvas.DrawLine(LMark, LBox.Left + LSize * 2 div 5, LBox.Bottom - LSize div 4, LBox.Right - LSize div 5, LBox.Top + LSize div 4, 1.8);
  end
  else if ACheckState = vlcsIndeterminate then
    ACanvas.FillRoundedRectangle(LMark, Rect(LBox.Left + LSize div 4, LBox.Top + LSize div 2 - 1, LBox.Right - LSize div 4, LBox.Top + LSize div 2 + 2), 1);
end;

class procedure TThemedVirtualCellRenderer.RenderProgressBar(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AValue: Integer; const AFont: TFont; const AState: TThemedVirtualListCellRenderState; const AAccentColor: TColor; const AShowText: Boolean);
var
  LTrack, LFill: TRect;
  LValue, LPadX, LTrackHeight, LWidth: Integer;
  LAccentColor: TColor;
  LAccent, LTrackColor, LTextColor: TThemeColor;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(ABounds) then Exit;
  LValue := EnsureRange(AValue, 0, 100);
  LPadX := Max(2, ABounds.Height div 8);
  LTrackHeight := EnsureRange(ABounds.Height div 3, 6, 12);
  LTrack := Rect(ABounds.Left + LPadX, ABounds.Top + (ABounds.Height - LTrackHeight) div 2, ABounds.Right - LPadX, ABounds.Top + (ABounds.Height - LTrackHeight) div 2 + LTrackHeight);
  if NimbusRectIsEmpty(LTrack) then Exit;
  if not AState.Enabled then LAccentColor := clGrayText else if AAccentColor = clNone then LAccentColor := clHighlight else LAccentColor := AAccentColor;
  LAccent := ColorToThemeColor(LAccentColor);
  LTrackColor := NimbusColorWithAlpha(LAccent, 52);
  ACanvas.FillRoundedRectangle(LTrackColor, LTrack, Max(1, LTrack.Height div 2));
  LWidth := MulDiv(LTrack.Width, LValue, 100);
  if LWidth > 0 then
  begin
    LFill := LTrack;
    LFill.Right := LFill.Left + LWidth;
    ACanvas.FillRoundedRectangle(LAccent, LFill, Max(1, LFill.Height div 2));
  end;
  if AShowText and (AFont <> nil) then
  begin
    LTextColor := ResolveProgressTextColor(LAccent, LValue, AFont, AState);
    ACanvas.DrawText(IntToStr(LValue) + '%', AFont, LTextColor, ABounds, [ntfSingleLine, ntfCenter, ntfVCenter, ntfNoPrefix]);
  end;
end;

class procedure TThemedVirtualCellRenderer.RenderBadge(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AText: string; const AFont: TFont; const AState: TThemedVirtualListCellRenderState; const AColor: TColor; const ARightToLeft: Boolean);
var
  LSize: TSize;
  LBadge: TRect;
  LHeight, LWidth, LPad: Integer;
  LAccent, LBack: TThemeColor;
  LFlags: TNimbusTextFlags;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(ABounds) or (AFont = nil) or (AText = '') then Exit;
  LHeight := EnsureRange(ABounds.Height - Max(4, ABounds.Height div 4), 16, 24);
  LPad := Max(6, LHeight div 2);
  LSize := ACanvas.MeasureText(AText, AFont, Max(1, ABounds.Width), [ntfSingleLine, ntfNoPrefix]);
  LWidth := Min(Max(1, ABounds.Width - 8), LSize.cx + LPad * 2);
  if ARightToLeft then LBadge := Rect(ABounds.Right - 4 - LWidth, ABounds.Top + (ABounds.Height - LHeight) div 2, ABounds.Right - 4, ABounds.Top + (ABounds.Height - LHeight) div 2 + LHeight)
  else LBadge := Rect(ABounds.Left + 4, ABounds.Top + (ABounds.Height - LHeight) div 2, ABounds.Left + 4 + LWidth, ABounds.Top + (ABounds.Height - LHeight) div 2 + LHeight);
  LAccent := ColorToThemeColor(ResolveAccentColor(AColor, AState));
  LBack := NimbusColorWithAlpha(LAccent, 70);
  ACanvas.FillRoundedRectangle(LBack, LBadge, LBadge.Height div 2);
  ACanvas.DrawRoundedRectangle(LAccent, LBadge, LBadge.Height div 2, 1.0);
  LFlags := [ntfSingleLine, ntfCenter, ntfVCenter, ntfEndEllipsis, ntfNoPrefix];
  if ARightToLeft then Include(LFlags, ntfRightToLeft);
  ACanvas.DrawText(AText, AFont, LAccent, LBadge, LFlags);
end;

class procedure TThemedVirtualCellRenderer.RenderColorSwatch(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AColor: TColor; const AFont: TFont; const AState: TThemedVirtualListCellRenderState; const AShowText: Boolean; const ARightToLeft: Boolean);
var
  LBox, LTextRect: TRect;
  LSize, LGap: Integer;
  LRGB: COLORREF;
  LText: string;
  LBorder: TThemeColor;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(ABounds) then Exit;
  LSize := EnsureRange(ABounds.Height - Max(6, ABounds.Height div 3), 12, 20);
  LGap := Max(4, ABounds.Height div 5);
  if ARightToLeft then LBox := Rect(ABounds.Right - LGap - LSize * 2, ABounds.Top + (ABounds.Height - LSize) div 2, ABounds.Right - LGap, ABounds.Top + (ABounds.Height - LSize) div 2 + LSize)
  else LBox := Rect(ABounds.Left + LGap, ABounds.Top + (ABounds.Height - LSize) div 2, ABounds.Left + LGap + LSize * 2, ABounds.Top + (ABounds.Height - LSize) div 2 + LSize);
  ACanvas.FillRectangle(ColorToThemeColor(AColor), LBox);
  if not AState.Enabled then LBorder := ColorToThemeColor(clGrayText) else LBorder := ColorToThemeColor(clBtnShadow);
  ACanvas.DrawRectangle(LBorder, LBox, 1.0);
  if not AShowText or (AFont = nil) then Exit;
  LRGB := ColorToRGB(AColor);
  LText := '#' + IntToHex(GetRValue(LRGB), 2) + IntToHex(GetGValue(LRGB), 2) + IntToHex(GetBValue(LRGB), 2);
  if ARightToLeft then LTextRect := Rect(ABounds.Left, ABounds.Top, LBox.Left - LGap, ABounds.Bottom) else LTextRect := Rect(LBox.Right + LGap, ABounds.Top, ABounds.Right, ABounds.Bottom);
  RenderText(ACanvas, LTextRect, LText, AFont, AState, taLeftJustify, ARightToLeft);
end;

class procedure TThemedVirtualCellRenderer.RenderRating(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AValue: Integer; const AState: TThemedVirtualListCellRenderState; const AAccentColor: TColor; const AMaximum: Integer);
var
  I, LCount, LValue, LMaximum, LStarSize, LSpacing, LTotalWidth, LX: Integer;
  LStarRect: TRect;
  LPoints: TNimbusPointBuffer;
  LAccent, LInactive: TThemeColor;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(ABounds) then Exit;
  LMaximum := EnsureRange(AMaximum, 1, 10);
  LValue := EnsureRange(AValue, 0, LMaximum);
  LStarSize := EnsureRange(ABounds.Height - Max(4, ABounds.Height div 5), 10, 20);
  LSpacing := Max(1, LStarSize div 6);
  LTotalWidth := LMaximum * LStarSize + (LMaximum - 1) * LSpacing;
  if LTotalWidth > ABounds.Width then
  begin
    LStarSize := Max(6, (ABounds.Width - (LMaximum - 1) * LSpacing) div LMaximum);
    LTotalWidth := LMaximum * LStarSize + (LMaximum - 1) * LSpacing;
  end;
  LX := ABounds.Left + Max(0, (ABounds.Width - LTotalWidth) div 2);
  LAccent := ColorToThemeColor(ResolveAccentColor(AAccentColor, AState));
  LInactive := NimbusColorWithAlpha(ColorToThemeColor(clGrayText), 160);
  for I := 0 to LMaximum - 1 do
  begin
    LStarRect := Rect(LX + I * (LStarSize + LSpacing), ABounds.Top + (ABounds.Height - LStarSize) div 2, LX + I * (LStarSize + LSpacing) + LStarSize, ABounds.Top + (ABounds.Height - LStarSize) div 2 + LStarSize);
    BuildStarPoints(LStarRect, LPoints, LCount);
    if LCount = 0 then Continue;
    if I < LValue then
    begin
      ACanvas.FillPolygon(LAccent, @LPoints, LCount);
      ACanvas.DrawPolygon(LAccent, @LPoints, LCount, 1.0);
    end
    else
      ACanvas.DrawPolygon(LInactive, @LPoints, LCount, 1.0);
  end;
end;

class procedure TThemedVirtualCellRenderer.RenderLink(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AText: string; const AFont: TFont; const AState: TThemedVirtualListCellRenderState; const ALinkColor: TColor; const ARightToLeft: Boolean);
var
  LFlags: TNimbusTextFlags;
  LSize: TSize;
  LColor: TThemeColor;
  LX1, LX2, LY: Integer;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(ABounds) or (AFont = nil) or (AText = '') then Exit;
  LFlags := [ntfSingleLine, ntfVCenter, ntfEndEllipsis, ntfNoPrefix];
  if ARightToLeft then
  begin
    Include(LFlags, ntfRight);
    Include(LFlags, ntfRightToLeft);
  end;
  LColor := ColorToThemeColor(ResolveAccentColor(ALinkColor, AState));
  ACanvas.DrawText(AText, AFont, LColor, ABounds, LFlags);
  LSize := ACanvas.MeasureText(AText, AFont, Max(1, ABounds.Width), [ntfSingleLine, ntfNoPrefix]);
  if ARightToLeft then
  begin
    LX2 := ABounds.Right;
    LX1 := Max(ABounds.Left, LX2 - Min(ABounds.Width, LSize.cx));
  end
  else
  begin
    LX1 := ABounds.Left;
    LX2 := Min(ABounds.Right, LX1 + Min(ABounds.Width, LSize.cx));
  end;
  LY := ABounds.Top + (ABounds.Height + Max(1, LSize.cy)) div 2;
  if LY >= ABounds.Bottom then LY := ABounds.Bottom - 1;
  if LX2 > LX1 then ACanvas.DrawLine(LColor, LX1, LY, LX2, LY, 1.0);
end;

constructor TThemedVirtualListColumn.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FWidth := 120;
  FMinWidth := 40;
  FMaxWidth := 1200;
  FVisible := True;
  FResizable := True;
  FSortable := True;
  FFrozen := False;
  FEditable := False;
  FEditorType := vlcetNone;
  FAlignment := taLeftJustify;
  FHeaderAlignment := taLeftJustify;
  FSortDirection := vlsdNone;
  FAutoSizeMode := vlasmNone;
end;

procedure TThemedVirtualListColumn.Assign(Source: TPersistent);
var
  LSource: TThemedVirtualListColumn;
begin
  if Source is TThemedVirtualListColumn then
  begin
    LSource := TThemedVirtualListColumn(Source);
    FHeaderText := LSource.FHeaderText;
    FWidth := LSource.FWidth;
    FMinWidth := LSource.FMinWidth;
    FMaxWidth := LSource.FMaxWidth;
    FVisible := LSource.FVisible;
    FResizable := LSource.FResizable;
    FSortable := LSource.FSortable;
    FFrozen := LSource.FFrozen;
    FEditable := LSource.FEditable;
    FEditorType := LSource.FEditorType;
    FAlignment := LSource.FAlignment;
    FHeaderAlignment := LSource.FHeaderAlignment;
    FSortDirection := LSource.FSortDirection;
    FAutoSizeMode := LSource.FAutoSizeMode;
    FTag := LSource.FTag;
    Changed(False);
    Exit;
  end;
  inherited Assign(Source);
end;

function TThemedVirtualListColumn.GetText(const ARowIndex: Integer; const AItem: TThemedVirtualListItemData; const ADefaultText: string): string;
begin
  Result := ADefaultText;
  if Assigned(FOnGetText) then FOnGetText(Self, ARowIndex, AItem, Result);
end;

function TThemedVirtualListColumn.TrySetText(const ARowIndex: Integer; const AItem: TThemedVirtualListItemData; const AText: string): Boolean;
begin
  Result := Assigned(FOnSetText);
  if Result then FOnSetText(Self, ARowIndex, AItem, AText, Result);
end;

procedure TThemedVirtualListColumn.SetHeaderText(const AValue: string);
begin
  if FHeaderText = AValue then Exit;
  FHeaderText := AValue;
  Changed(False);
end;

procedure TThemedVirtualListColumn.SetWidth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := EnsureRange(AValue, FMinWidth, FMaxWidth);
  if FWidth = LValue then Exit;
  FWidth := LValue;
  Changed(False);
end;

procedure TThemedVirtualListColumn.SetMinWidth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(20, AValue);
  if FMinWidth = LValue then Exit;
  FMinWidth := LValue;
  if FMaxWidth < FMinWidth then FMaxWidth := FMinWidth;
  if FWidth < FMinWidth then FWidth := FMinWidth;
  Changed(False);
end;

procedure TThemedVirtualListColumn.SetMaxWidth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(FMinWidth, AValue);
  if FMaxWidth = LValue then Exit;
  FMaxWidth := LValue;
  if FWidth > FMaxWidth then FWidth := FMaxWidth;
  Changed(False);
end;

procedure TThemedVirtualListColumn.SetVisible(const AValue: Boolean);
begin
  if FVisible = AValue then Exit;
  FVisible := AValue;
  Changed(False);
end;

procedure TThemedVirtualListColumn.SetResizable(const AValue: Boolean);
begin
  if FResizable = AValue then Exit;
  FResizable := AValue;
  Changed(False);
end;

procedure TThemedVirtualListColumn.SetSortable(const AValue: Boolean);
begin
  if FSortable = AValue then Exit;
  FSortable := AValue;
  Changed(False);
end;

procedure TThemedVirtualListColumn.SetFrozen(const AValue: Boolean);
begin
  if FFrozen = AValue then Exit;
  FFrozen := AValue;
  Changed(False);
end;

procedure TThemedVirtualListColumn.SetEditable(const AValue: Boolean);
begin
  if FEditable = AValue then Exit;
  FEditable := AValue;
  Changed(False);
end;

procedure TThemedVirtualListColumn.SetEditorType(const AValue: TThemedVirtualListColumnEditorType);
begin
  if FEditorType = AValue then Exit;
  FEditorType := AValue;
  Changed(False);
end;

procedure TThemedVirtualListColumn.SetAlignment(const AValue: TAlignment);
begin
  if FAlignment = AValue then Exit;
  FAlignment := AValue;
  Changed(False);
end;

procedure TThemedVirtualListColumn.SetHeaderAlignment(const AValue: TAlignment);
begin
  if FHeaderAlignment = AValue then Exit;
  FHeaderAlignment := AValue;
  Changed(False);
end;

procedure TThemedVirtualListColumn.SetSortDirection(const AValue: TThemedVirtualListSortDirection);
begin
  if FSortDirection = AValue then Exit;
  FSortDirection := AValue;
  Changed(False);
end;

procedure TThemedVirtualListColumn.SetAutoSizeMode(const AValue: TThemedVirtualListAutoSizeMode);
begin
  if FAutoSizeMode = AValue then Exit;
  FAutoSizeMode := AValue;
  Changed(False);
end;

procedure TThemedVirtualListColumn.SetTag(const AValue: NativeInt);
begin
  if FTag = AValue then Exit;
  FTag := AValue;
end;

constructor TThemedVirtualListColumns.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TThemedVirtualListColumn);
end;

function TThemedVirtualListColumns.Add: TThemedVirtualListColumn;
begin
  Result := TThemedVirtualListColumn(inherited Add);
end;

function TThemedVirtualListColumns.GetItem(Index: Integer): TThemedVirtualListColumn;
begin
  Result := TThemedVirtualListColumn(inherited GetItem(Index));
end;

procedure TThemedVirtualListColumns.SetItem(Index: Integer; const AValue: TThemedVirtualListColumn);
begin
  inherited SetItem(Index, AValue);
end;

procedure TThemedVirtualListColumns.Move(const AOldIndex, ANewIndex: Integer);
var
  LItem: TThemedVirtualListColumn;
begin
  if (AOldIndex < 0) or (AOldIndex >= Count) or (ANewIndex < 0) or (ANewIndex >= Count) or (AOldIndex = ANewIndex) then Exit;
  LItem := Items[AOldIndex];
  LItem.Index := ANewIndex;
end;

procedure TThemedVirtualListColumns.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  if Assigned(FOnChange) then FOnChange(Self, TThemedVirtualListColumn(Item));
end;

constructor TCustomThemedVirtualList.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ParentColor := False;
  ControlStyle := ControlStyle - [csCaptureMouse, csClickEvents];
  TabStop := True;
  Width := 320;
  Height := 240;
  FItemCount := 0;
  FItemHeight := 24;
  FScrollBarWidth := 10;
  FWheelScrollItems := 3;
  FCurrentIndex := -1;
  FAnchorIndex := -1;
  FHoverIndex := -1;
  FPressedIndex := -1;
  FSelectionMode := vlsmMulti;
  FMultiSelect := True;
  FCheckBoxes := False;
  FTriStateCheckBoxes := False;
  FShowSubtitles := True;
  FShowDetails := True;
  FShowProgress := True;
  FRoundedSelection := True;
  FAlternatingRows := True;
  FHotTrack := True;
  FScrollBarMode := vlsbAuto;
  FShowHeader := True;
  FHeaderHeight := 26;
  FFilterHeight := 26;
  FShowFilterRow := False;
  FShowGlobalSearch := False;
  FShowRowDetails := False;
  FShowGroupHeaders := False;
  FShowSeparators := False;
  FDetailsHeight := 70;
  FGroupHeaderHeight := 24;
  FGlobalFilterPlaceholderActive := False;
  FUpdatingGlobalFilterBox := False;
  FActiveEditor := nil;
  FEditingRowIndex := -1;
  FEditingColumn := nil;
  FEditingOldValue := '';
  FEndingEdit := False;
  FAllowColumnReorder := True;
  FHeaderHoverColumn := -1;
  FResizeColumn := -1;
  FReorderColumn := -1;
  FReorderTarget := -1;
  FPageSize := 50;
  FMaxCachedPages := 32;
  FLoadingPlaceholders := True;
  FShowRowBadges := True;
  FShowCellBadges := True;
  FRowBadgeOptions := TThemedVirtualListBadgeRenderOptions.Create;
  FRowBadgeOptions.SetRowDefaults;
  FRowBadgeOptions.OnChange := BadgeOptionsChanged;
  FCellBadgeOptions := TThemedVirtualListBadgeRenderOptions.Create;
  FCellBadgeOptions.SetCellDefaults;
  FCellBadgeOptions.OnChange := BadgeOptionsChanged;
  FCachePages := TList.Create;
  FPendingRequests := TList.Create;
  FNextRequestToken := 0;
  FColumns := TThemedVirtualListColumns.Create(Self);
  FColumns.OnChange := ColumnsChanged;
  FImageChangeLink := TChangeLink.Create;
  FImageChangeLink.OnChange := ImageListChanged;
  FImageBuffer := Vcl.Graphics.TBitmap.Create;
  FScrollBar := TThemedVScrollBar.Create(Self);
  FScrollBar.Parent := Self;
  FScrollBar.TabStop := False;
  FScrollBar.OnValueChanged := ScrollBarChanged;
  FHorizontalScrollBar := TThemedHScrollBar.Create(Self);
  FHorizontalScrollBar.Parent := Self;
  FHorizontalScrollBar.TabStop := False;
  FHorizontalScrollBar.Visible := False;
  FHorizontalScrollBar.OnValueChanged := HorizontalScrollBarChanged;
  FGlobalFilterBox := TEdit.Create(Self);
  FGlobalFilterBox.Parent := Self;
  FGlobalFilterBox.BorderStyle := bsNone;
  FGlobalFilterBox.AutoSize := False;
  FGlobalFilterBox.ParentFont := True;
  FGlobalFilterBox.ParentBiDiMode := True;
  FGlobalFilterBox.TabStop := True;
  FGlobalFilterBox.Visible := False;
  FGlobalFilterBox.TextHint := '';
  FGlobalFilterBox.OnChange := GlobalFilterBoxChanged;
  FGlobalFilterBox.OnKeyDown := GlobalFilterBoxKeyDown;
  FGlobalFilterBox.OnEnter := GlobalFilterBoxFocusChanged;
  FGlobalFilterBox.OnExit := GlobalFilterBoxFocusChanged;
  UpdateGlobalFilterPlaceholder;
  UpdateMetrics;
  UpdateFilterEditorTheme;
  UpdateFilterEditorBounds;
end;

destructor TCustomThemedVirtualList.Destroy;
begin
  EndCellEdit(False);
  if FImages <> nil then
  begin
    FImages.UnRegisterChanges(FImageChangeLink);
    FImages.RemoveFreeNotification(Self);
  end;
  if FScrollBar <> nil then FScrollBar.OnValueChanged := nil;
  if FHorizontalScrollBar <> nil then FHorizontalScrollBar.OnValueChanged := nil;
  if FGlobalFilterBox <> nil then
  begin
    FGlobalFilterBox.OnChange := nil;
    FGlobalFilterBox.OnKeyDown := nil;
    FGlobalFilterBox.OnEnter := nil;
    FGlobalFilterBox.OnExit := nil;
  end;
  if FFilterDebounceTimer <> nil then
  begin
    FFilterDebounceTimer.Enabled := False;
    FFilterDebounceTimer.OnTimer := nil;
    FFilterDebounceTimer.Free;
    FFilterDebounceTimer := nil;
  end;
  FColumns.OnChange := nil;
  FOnRequestItemsCancelled := nil;
  if FRowBadgeOptions <> nil then FRowBadgeOptions.OnChange := nil;
  if FCellBadgeOptions <> nil then FCellBadgeOptions.OnChange := nil;
  ClearItemCache;
  FPendingRequests.Free;
  FCachePages.Free;
  FRowBadgeOptions.Free;
  FCellBadgeOptions.Free;
  FColumns.Free;
  FImageBuffer.Free;
  FImageChangeLink.Free;
  inherited Destroy;
end;

procedure TCustomThemedVirtualList.ApplyTheme(const APalette: TThemePalette);
begin
  inherited ApplyTheme(APalette);
  if FScrollBar <> nil then FScrollBar.ApplyTheme(APalette);
  if FHorizontalScrollBar <> nil then FHorizontalScrollBar.ApplyTheme(APalette);
  UpdateFilterEditorTheme;
  if FActiveEditor <> nil then
  begin
    FActiveEditor.Font.Assign(Font);
    if Palette <> nil then
    begin
      FActiveEditor.Color := ThemeColorToColor(Palette.InputBackColor);
      FActiveEditor.Font.Color := ThemeColorToColor(Palette.InputForeColor);
    end
    else
    begin
      FActiveEditor.Color := Color;
      FActiveEditor.Font.Color := Font.Color;
    end;
  end;
end;

procedure TCustomThemedVirtualList.ColumnsChanged(Sender: TObject; AColumn: TThemedVirtualListColumn);
begin
  if FAutoSizingColumns then Exit;
  QueueAutoSizeColumns(False);
  if (FEditingColumn <> nil) and ((FEditingColumn.Index < 0) or (FEditingColumn.Index >= FColumns.Count) or (FColumns[FEditingColumn.Index] <> FEditingColumn) or not FEditingColumn.Editable or not FEditingColumn.Visible) then EndCellEdit(False);
  if FHeaderHoverColumn >= FColumns.Count then FHeaderHoverColumn := -1;
  if FResizeColumn >= FColumns.Count then FResizeColumn := -1;
  if FReorderColumn >= FColumns.Count then
  begin
    FReorderColumn := -1;
    FReorderTarget := -1;
    FReorderDragging := False;
    if (FResizeColumn < 0) and MouseCapture then MouseCapture := False;
  end;
  if FUpdateCount > 0 then Exit;
  UpdateScrollBar;
  Invalidate;
end;

procedure TCustomThemedVirtualList.SetColumns(const AValue: TThemedVirtualListColumns);
begin
  if (AValue <> nil) and (AValue <> FColumns) then FColumns.Assign(AValue);
end;

procedure TCustomThemedVirtualList.SetSelectionMode(const AValue: TThemedVirtualListSelectionMode);
begin
  if FSelectionMode = AValue then Exit;
  FSelectionMode := AValue;
  FMultiSelect := FSelectionMode <> vlsmSingle;
  ClearSelection;
end;

procedure TCustomThemedVirtualList.SetShowHeader(const AValue: Boolean);
begin
  if FShowHeader = AValue then Exit;
  FShowHeader := AValue;
  if not FShowHeader then
  begin
    FHeaderHoverColumn := -1;
    FResizeColumn := -1;
    FReorderColumn := -1;
    FReorderTarget := -1;
    FReorderDragging := False;
    Cursor := crDefault;
    if MouseCapture then MouseCapture := False;
  end;
  UpdateScrollBar;
  Invalidate;
end;

procedure TCustomThemedVirtualList.StyleModeChanged;
begin
  inherited StyleModeChanged;
  FStyleMetricsApplying := True;
  try
    if StyleMode = stCompact then
    begin
      if FItemHeight = 24 then begin SetItemHeight(20); FCompactRowApplied := True; end;
      if FHeaderHeight = 26 then begin SetHeaderHeight(22); FCompactHeaderApplied := True; end;
      if FFilterHeight = 26 then begin SetFilterHeight(22); FCompactFilterApplied := True; end;
      if FGroupHeaderHeight = 24 then begin SetGroupHeaderHeight(20); FCompactGroupApplied := True; end;
    end
    else
    begin
      if FCompactRowApplied and (FItemHeight = 20) then SetItemHeight(24);
      if FCompactHeaderApplied and (FHeaderHeight = 22) then SetHeaderHeight(26);
      if FCompactFilterApplied and (FFilterHeight = 22) then SetFilterHeight(26);
      if FCompactGroupApplied and (FGroupHeaderHeight = 20) then SetGroupHeaderHeight(24);
      FCompactRowApplied := False;
      FCompactHeaderApplied := False;
      FCompactFilterApplied := False;
      FCompactGroupApplied := False;
    end;
  finally
    FStyleMetricsApplying := False;
  end;
  UpdateActiveEditorBounds;
  UpdateFilterEditorBounds;
end;

procedure TCustomThemedVirtualList.SetHeaderHeight(const AValue: Integer);
var
  LValue: Integer;
begin
  if not FStyleMetricsApplying then FCompactHeaderApplied := False;
  LValue := EnsureRange(AValue, 20, 80);
  if FHeaderHeight = LValue then Exit;
  FHeaderHeight := LValue;
  UpdateScrollBar;
  Invalidate;
end;

procedure TCustomThemedVirtualList.SetFilterHeight(const AValue: Integer);
var
  LValue: Integer;
begin
  if not FStyleMetricsApplying then FCompactFilterApplied := False;
  LValue := EnsureRange(AValue, 20, 80);
  if FFilterHeight = LValue then Exit;
  FFilterHeight := LValue;
  UpdateScrollBar;
  UpdateFilterEditorBounds;
  Invalidate;
end;

procedure TCustomThemedVirtualList.SetShowFilterRow(const AValue: Boolean);
begin
  if FShowFilterRow = AValue then Exit;
  FShowFilterRow := AValue;
  UpdateScrollBar;
  UpdateFilterEditorBounds;
  Invalidate;
end;

procedure TCustomThemedVirtualList.SetShowGlobalSearch(const AValue: Boolean);
begin
  if FShowGlobalSearch = AValue then Exit;
  FShowGlobalSearch := AValue;
  if FGlobalFilterBox <> nil then
  begin
    if not FShowGlobalSearch and FGlobalFilterBox.Focused and TabStop and CanFocus then SetFocus;
    FGlobalFilterBox.Visible := FShowGlobalSearch;
    if FShowGlobalSearch then UpdateGlobalFilterPlaceholder;
  end;
  UpdateScrollBar;
  UpdateFilterEditorBounds;
  Invalidate;
end;

procedure TCustomThemedVirtualList.SetShowRowDetails(const AValue: Boolean);
begin
  if FShowRowDetails = AValue then Exit;
  FShowRowDetails := AValue;
  if not FShowRowDetails then CollapseAllDetails;
  UpdateScrollBar;
  UpdateActiveEditorBounds;
  Invalidate;
end;

procedure TCustomThemedVirtualList.SetShowGroupHeaders(const AValue: Boolean);
begin
  if FShowGroupHeaders = AValue then Exit;
  FShowGroupHeaders := AValue;
  UpdateScrollBar;
  UpdateActiveEditorBounds;
  Invalidate;
end;

procedure TCustomThemedVirtualList.SetShowSeparators(const AValue: Boolean);
begin
  if FShowSeparators = AValue then Exit;
  FShowSeparators := AValue;
  UpdateActiveEditorBounds;
  Invalidate;
end;

procedure TCustomThemedVirtualList.SetDetailsHeight(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := EnsureRange(AValue, 20, 500);
  if FDetailsHeight = LValue then Exit;
  FDetailsHeight := LValue;
  UpdateScrollBar;
  UpdateActiveEditorBounds;
  Invalidate;
end;

procedure TCustomThemedVirtualList.SetGroupHeaderHeight(const AValue: Integer);
var
  LValue: Integer;
begin
  if not FStyleMetricsApplying then FCompactGroupApplied := False;
  LValue := EnsureRange(AValue, 16, 80);
  if FGroupHeaderHeight = LValue then Exit;
  FGroupHeaderHeight := LValue;
  UpdateScrollBar;
  UpdateActiveEditorBounds;
  Invalidate;
end;

procedure TCustomThemedVirtualList.GlobalFilterBoxChanged(Sender: TObject);
begin
  if FUpdatingGlobalFilterBox or FGlobalFilterPlaceholderActive then Exit;
  if (FFilterDebounceTimer = nil) or (csLoading in ComponentState) or (csDestroying in ComponentState) then Exit;
  FFilterDebounceTimer.Enabled := False;
  FFilterDebounceTimer.Enabled := True;
  Invalidate;
end;

procedure TCustomThemedVirtualList.GlobalFilterBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key <> VK_ESCAPE then Exit;
  if FGlobalFilterBox.Text <> '' then FGlobalFilterBox.Clear;
  if TabStop and CanFocus then SetFocus;
  Key := 0;
end;

procedure TCustomThemedVirtualList.GlobalFilterBoxFocusChanged(Sender: TObject);
begin
  UpdateGlobalFilterPlaceholder;
  UpdateFilterEditorTheme;
  Invalidate;
end;

procedure TCustomThemedVirtualList.UpdateGlobalFilterPlaceholder;
begin
  if FGlobalFilterBox = nil then Exit;
  if FGlobalFilterBox.Focused then
  begin
    if FGlobalFilterPlaceholderActive then
    begin
      FUpdatingGlobalFilterBox := True;
      try
        FGlobalFilterBox.Text := '';
        FGlobalFilterPlaceholderActive := False;
      finally
        FUpdatingGlobalFilterBox := False;
      end;
    end;
    Exit;
  end;
  if FGlobalFilterPlaceholderActive or (FGlobalFilterBox.Text <> '') then Exit;
  FUpdatingGlobalFilterBox := True;
  try
    FGlobalFilterBox.Text := SVirtualListSearchPlaceholder;
    FGlobalFilterPlaceholderActive := True;
  finally
    FUpdatingGlobalFilterBox := False;
  end;
end;

function TCustomThemedVirtualList.GetGlobalFilterText: string;
begin
  if FGlobalFilterPlaceholderActive or (FGlobalFilterBox = nil) then Result := '' else Result := FGlobalFilterBox.Text;
end;

procedure TCustomThemedVirtualList.FilterDebounceTimerTimer(Sender: TObject);
var
  LItemCount: Integer;
begin
  FFilterDebounceTimer.Enabled := False;
  if (csDestroying in ComponentState) or not Assigned(FOnFilterRequested) then Exit;
  LItemCount := -1;
  FOnFilterRequested(Self, GetGlobalFilterText, LItemCount);
  if csDestroying in ComponentState then Exit;
  if LItemCount >= 0 then
  begin
    if LItemCount = FItemCount then RefreshItems else ItemCount := LItemCount;
  end
  else
    RefreshItems;
end;

procedure TCustomThemedVirtualList.UpdateFilterEditorBounds;
var
  LRect: TRect;
  LX, LY, LWidth, LHeight: Integer;
begin
  if FGlobalFilterBox = nil then Exit;
  LRect := GetGlobalSearchRect;
  LX := ScaleValue(9);
  LY := ScaleValue(7);
  LWidth := Max(1, LRect.Width - ScaleValue(28));
  LHeight := Min(Max(1, ScaleValue(18)), Max(1, LRect.Height - LY));
  FGlobalFilterBox.SetBounds(LRect.Left + LX, LRect.Top + LY, LWidth, LHeight);
end;

procedure TCustomThemedVirtualList.UpdateFilterEditorTheme;
begin
  if FGlobalFilterBox = nil then Exit;
  FGlobalFilterBox.Font.Assign(Font);
  if Palette <> nil then
  begin
    FGlobalFilterBox.Color := ThemeColorToColor(Palette.InputBackColor);
    if FGlobalFilterPlaceholderActive then FGlobalFilterBox.Font.Color := ThemeColorToColor(Palette.MutedForeColor) else FGlobalFilterBox.Font.Color := ThemeColorToColor(Palette.InputForeColor);
  end
  else
  begin
    FGlobalFilterBox.Color := Color;
    if FGlobalFilterPlaceholderActive then FGlobalFilterBox.Font.Color := clGrayText else FGlobalFilterBox.Font.Color := Font.Color;
  end;
end;

procedure TCustomThemedVirtualList.ActiveEditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_RETURN:
      begin
        EndCellEdit(True);
        Key := 0;
      end;
    VK_ESCAPE:
      begin
        EndCellEdit(False);
        if TabStop and CanFocus then SetFocus;
        Key := 0;
      end;
  end;
end;

procedure TCustomThemedVirtualList.ActiveEditorExit(Sender: TObject);
begin
  if not FEndingEdit then EndCellEdit(True);
end;

procedure TCustomThemedVirtualList.BeginEditFocusedCell;
var
  I: Integer;
begin
  if not Enabled or not IsTableMode or (FCurrentIndex < 0) or (FCurrentIndex >= FItemCount) or not IsItemEnabled(FCurrentIndex) then Exit;
  for I := 0 to FColumns.Count - 1 do
    if FColumns[I].Visible and FColumns[I].Editable then
    begin
      BeginCellEdit(FCurrentIndex, FColumns[I]);
      Exit;
    end;
end;

procedure TCustomThemedVirtualList.BeginCellEdit(const ARowIndex: Integer; AColumn: TThemedVirtualListColumn);
var
  LRect: TRect;
  LItem: TThemedVirtualListItemData;
begin
  EndCellEdit(False);
  if not HandleAllocated or (AColumn = nil) or not AColumn.Editable or not AColumn.Visible or (ARowIndex < 0) or (ARowIndex >= FItemCount) or not IsItemEnabled(ARowIndex) then Exit;
  if IsTableMode and FShowSeparators then
  begin
    GetItemData(ARowIndex, LItem);
    if ResolveRowKind(ARowIndex, LItem) = vlrkSeparator then Exit;
  end;
  MakeVisible(ARowIndex);
  LRect := GetTableCellRect(ARowIndex, AColumn.Index);
  if NimbusRectIsEmpty(LRect) then Exit;
  InflateRect(LRect, -1, -1);
  if NimbusRectIsEmpty(LRect) then Exit;
  FEditingRowIndex := ARowIndex;
  FEditingColumn := AColumn;
  FEditingOldValue := GetCellText(ARowIndex, AColumn);
  FActiveEditor := TEdit.Create(Self);
  FActiveEditor.Parent := Self;
  FActiveEditor.ParentFont := True;
  FActiveEditor.ParentBiDiMode := True;
  FActiveEditor.BorderStyle := bsSingle;
  FActiveEditor.Font.Assign(Font);
  if Palette <> nil then
  begin
    FActiveEditor.Color := ThemeColorToColor(Palette.InputBackColor);
    FActiveEditor.Font.Color := ThemeColorToColor(Palette.InputForeColor);
  end
  else
  begin
    FActiveEditor.Color := Color;
    FActiveEditor.Font.Color := Font.Color;
  end;
  FActiveEditor.Text := FEditingOldValue;
  FActiveEditor.SetBounds(LRect.Left, LRect.Top, LRect.Width, LRect.Height);
  FActiveEditor.OnKeyDown := ActiveEditorKeyDown;
  FActiveEditor.OnExit := ActiveEditorExit;
  FActiveEditor.BringToFront;
  if not FActiveEditor.CanFocus then
  begin
    EndCellEdit(False);
    Exit;
  end;
  FActiveEditor.SetFocus;
  FActiveEditor.SelectAll;
end;

procedure TCustomThemedVirtualList.EndCellEdit(const ACommit: Boolean);
var
  LEditor: TEdit;
  LColumn: TThemedVirtualListColumn;
  LRowIndex: Integer;
  LOldValue, LNewValue: string;
  LItem: TThemedVirtualListItemData;
  LCancel: Boolean;
begin
  if (FActiveEditor = nil) or FEndingEdit then Exit;
  FEndingEdit := True;
  try
    LEditor := FActiveEditor;
    LColumn := FEditingColumn;
    LRowIndex := FEditingRowIndex;
    LOldValue := FEditingOldValue;
    LNewValue := LEditor.Text;
    LCancel := False;
    if ACommit and (LColumn <> nil) and (LRowIndex >= 0) and (LRowIndex < FItemCount) then
    begin
      if Assigned(FOnCellValidating) then FOnCellValidating(Self, LRowIndex, LColumn, LOldValue, LNewValue, LCancel);
      if not LCancel then
      begin
        if TryGetItemData(LRowIndex, LItem) then LColumn.TrySetText(LRowIndex, LItem, LNewValue);
        if Assigned(FOnCellEditCommitted) then FOnCellEditCommitted(Self, LRowIndex, LColumn, LOldValue, LNewValue);
      end;
    end;
    FActiveEditor := nil;
    FEditingColumn := nil;
    FEditingRowIndex := -1;
    FEditingOldValue := '';
    LEditor.OnKeyDown := nil;
    LEditor.OnExit := nil;
    LEditor.Free;
    if not (csDestroying in ComponentState) then
    begin
      if ACommit and not LCancel then RefreshItem(LRowIndex) else Invalidate;
    end;
  finally
    FEndingEdit := False;
  end;
end;

procedure TCustomThemedVirtualList.UpdateActiveEditorBounds;
var
  LRect: TRect;
begin
  if (FActiveEditor = nil) or (FEditingColumn = nil) then Exit;
  LRect := GetTableCellRect(FEditingRowIndex, FEditingColumn.Index);
  if NimbusRectIsEmpty(LRect) then
  begin
    EndCellEdit(True);
    Exit;
  end;
  InflateRect(LRect, -1, -1);
  if NimbusRectIsEmpty(LRect) then
  begin
    EndCellEdit(True);
    Exit;
  end;
  FActiveEditor.SetBounds(LRect.Left, LRect.Top, LRect.Width, LRect.Height);
  FActiveEditor.BringToFront;
end;

procedure TCustomThemedVirtualList.SetAllowColumnReorder(const AValue: Boolean);
var
  LHadReorder: Boolean;
begin
  if FAllowColumnReorder = AValue then Exit;
  FAllowColumnReorder := AValue;
  if not FAllowColumnReorder then
  begin
    LHadReorder := FReorderColumn >= 0;
    FReorderColumn := -1;
    FReorderTarget := -1;
    FReorderDragging := False;
    if LHadReorder and (FResizeColumn < 0) and MouseCapture then MouseCapture := False;
    Invalidate;
  end;
end;

function TCustomThemedVirtualList.GetControlClientRect: TRect;
begin
  if HandleAllocated then Result := ClientRect else Result := Rect(0, 0, Width, Height);
end;

function TCustomThemedVirtualList.GetHeaderHeightPixels: Integer;
begin
  if IsTableMode and FShowHeader then Result := ScaleValue(FHeaderHeight) else Result := 0;
end;

function TCustomThemedVirtualList.GetFilterHeightPixels: Integer;
begin
  Result := ScaleValue(FFilterHeight);
end;

function TCustomThemedVirtualList.GetTopOffsetPixels: Integer;
begin
  Result := 0;
  if FShowGlobalSearch then Inc(Result, GetFilterHeightPixels);
  Inc(Result, GetHeaderHeightPixels);
  if FShowFilterRow then Inc(Result, GetFilterHeightPixels);
end;

function TCustomThemedVirtualList.GetGlobalSearchRect: TRect;
var
  LWidth: Integer;
begin
  Result := GetControlClientRect;
  Result.Bottom := Min(Result.Bottom, Result.Top + Ord(FShowGlobalSearch) * GetFilterHeightPixels);
  if (FScrollBar <> nil) and FScrollBar.Visible then
  begin
    LWidth := FScrollBar.Width;
    if UseRightToLeftScrollBar then Inc(Result.Left, LWidth) else Dec(Result.Right, LWidth);
  end;
  if Result.Right < Result.Left then Result.Right := Result.Left;
end;

function TCustomThemedVirtualList.GetHeaderRect: TRect;
var
  LWidth, LTop: Integer;
begin
  Result := GetControlClientRect;
  LTop := Result.Top;
  if FShowGlobalSearch then Inc(LTop, GetFilterHeightPixels);
  Result.Top := Min(Result.Bottom, LTop);
  Result.Bottom := Min(Result.Bottom, Result.Top + GetHeaderHeightPixels);
  if (FScrollBar <> nil) and FScrollBar.Visible then
  begin
    LWidth := FScrollBar.Width;
    if UseRightToLeftScrollBar then Inc(Result.Left, LWidth) else Dec(Result.Right, LWidth);
  end;
  if Result.Right < Result.Left then Result.Right := Result.Left;
end;

function TCustomThemedVirtualList.GetFilterRect: TRect;
var
  LWidth, LTop: Integer;
begin
  Result := GetControlClientRect;
  LTop := Result.Top;
  if FShowGlobalSearch then Inc(LTop, GetFilterHeightPixels);
  Inc(LTop, GetHeaderHeightPixels);
  Result.Top := Min(Result.Bottom, LTop);
  Result.Bottom := Min(Result.Bottom, Result.Top + Ord(FShowFilterRow) * GetFilterHeightPixels);
  if (FScrollBar <> nil) and FScrollBar.Visible then
  begin
    LWidth := FScrollBar.Width;
    if UseRightToLeftScrollBar then Inc(Result.Left, LWidth) else Dec(Result.Right, LWidth);
  end;
  if Result.Right < Result.Left then Result.Right := Result.Left;
end;

function TCustomThemedVirtualList.GetCheckColumnWidth: Integer;
begin
  if IsTableMode and FCheckBoxes then Result := ScaleValue(32) else Result := 0;
end;

function TCustomThemedVirtualList.GetDetailsColumnWidth: Integer;
begin
  if IsTableMode and FShowRowDetails then Result := ScaleValue(22) else Result := 0;
end;

function TCustomThemedVirtualList.GetDetailsHeightPixels: Integer;
begin
  Result := Max(1, ScaleValue(FDetailsHeight));
end;

function TCustomThemedVirtualList.GetGroupHeaderHeightPixels: Integer;
begin
  Result := Max(1, ScaleValue(FGroupHeaderHeight));
end;

function TCustomThemedVirtualList.GetFrozenColumnsWidth: Integer;
var
  I: Integer;
begin
  Result := 0;
  if FColumns = nil then Exit;
  for I := 0 to FColumns.Count - 1 do
    if FColumns[I].Visible and FColumns[I].Frozen then Inc(Result, ScaleValue(FColumns[I].Width));
end;

function TCustomThemedVirtualList.GetScrollableColumnsWidth: Integer;
var
  I: Integer;
begin
  Result := 0;
  if FColumns = nil then Exit;
  for I := 0 to FColumns.Count - 1 do
    if FColumns[I].Visible and not FColumns[I].Frozen then Inc(Result, ScaleValue(FColumns[I].Width));
end;

function TCustomThemedVirtualList.GetMaxHorizontalOffset: Integer;
var
  LArea: TRect;
  LViewport: Integer;
begin
  if not IsTableMode then Exit(0);
  LArea := GetItemArea;
  LViewport := Max(1, LArea.Width - GetCheckColumnWidth - GetDetailsColumnWidth - GetFrozenColumnsWidth);
  Result := Max(0, GetScrollableColumnsWidth - LViewport);
end;

function TCustomThemedVirtualList.IsTableMode: Boolean;
begin
  Result := (FColumns <> nil) and (FColumns.Count > 0);
end;

function TCustomThemedVirtualList.GetColumnRect(const AColumnIndex: Integer; const ATop, ABottom: Integer): TRect;
var
  I, LX, LWidth, LLeft, LRight: Integer;
  LColumn: TThemedVirtualListColumn;
  LArea: TRect;
begin
  Result := Rect(0, 0, 0, 0);
  if (AColumnIndex < 0) or (AColumnIndex >= FColumns.Count) then Exit;
  LColumn := FColumns[AColumnIndex];
  if not LColumn.Visible then Exit;
  LArea := GetItemArea;
  LX := LArea.Left + GetCheckColumnWidth + GetDetailsColumnWidth;
  if LColumn.Frozen then
  begin
    for I := 0 to AColumnIndex - 1 do
      if FColumns[I].Visible and FColumns[I].Frozen then Inc(LX, ScaleValue(FColumns[I].Width));
  end
  else
  begin
    Inc(LX, GetFrozenColumnsWidth - FHorizontalOffset);
    for I := 0 to AColumnIndex - 1 do
      if FColumns[I].Visible and not FColumns[I].Frozen then Inc(LX, ScaleValue(FColumns[I].Width));
  end;
  LWidth := ScaleValue(LColumn.Width);
  Result := Rect(LX, ATop, LX + LWidth, ABottom);
  if UseRightToLeftReading then
  begin
    LLeft := LArea.Left + LArea.Right - Result.Right;
    LRight := LArea.Left + LArea.Right - Result.Left;
    Result.Left := LLeft;
    Result.Right := LRight;
  end;
end;

function TCustomThemedVirtualList.HitTestColumn(const AX, AY: Integer): Integer;
var
  I: Integer;
  LRect, LHeader, LArea: TRect;
begin
  Result := -1;
  if not IsTableMode then Exit;
  LHeader := GetHeaderRect;
  if FShowHeader and not PtInRect(LHeader, Point(AX, AY)) then Exit;
  LArea := GetItemArea;
  for I := 0 to FColumns.Count - 1 do
  begin
    LRect := GetColumnRect(I, LHeader.Top, LHeader.Bottom);
    if not FColumns[I].Frozen then
    begin
      if UseRightToLeftReading then LRect.Right := Min(LRect.Right, LArea.Right - GetCheckColumnWidth - GetDetailsColumnWidth - GetFrozenColumnsWidth)
      else LRect.Left := Max(LRect.Left, LArea.Left + GetCheckColumnWidth + GetDetailsColumnWidth + GetFrozenColumnsWidth);
    end;
    if PtInRect(LRect, Point(AX, AY)) then Exit(I);
  end;
end;

function TCustomThemedVirtualList.HitTestColumnResize(const AX, AY: Integer): Integer;
var
  I, LGrip, LEdge: Integer;
  LRect, LHeader: TRect;
begin
  Result := -1;
  if not IsTableMode or not FShowHeader then Exit;
  LHeader := GetHeaderRect;
  if not PtInRect(LHeader, Point(AX, AY)) then Exit;
  LGrip := Max(3, ScaleValue(4));
  for I := 0 to FColumns.Count - 1 do
  begin
    if not FColumns[I].Visible or not FColumns[I].Resizable then Continue;
    LRect := GetColumnRect(I, LHeader.Top, LHeader.Bottom);
    if UseRightToLeftReading then LEdge := LRect.Left else LEdge := LRect.Right;
    if Abs(AX - LEdge) <= LGrip then Exit(I);
  end;
end;

function TCustomThemedVirtualList.HitTestColumnInsertion(const AX: Integer): Integer;
var
  I, LX, LDistance, LBestDistance: Integer;
begin
  Result := -1;
  if not IsTableMode then Exit;
  LBestDistance := High(Integer);
  for I := 0 to FColumns.Count - 1 do
  begin
    LX := GetColumnInsertionX(I);
    LDistance := Abs(AX - LX);
    if LDistance < LBestDistance then
    begin
      LBestDistance := LDistance;
      Result := I;
    end;
  end;
end;

function TCustomThemedVirtualList.GetColumnInsertionX(const AIndex: Integer): Integer;
var
  I, LX: Integer;
  LArea: TRect;
begin
  LArea := GetItemArea;
  LX := LArea.Left + GetCheckColumnWidth + GetDetailsColumnWidth;
  for I := 0 to FColumns.Count - 1 do
  begin
    if I = AIndex then
    begin
      if UseRightToLeftReading then Result := LArea.Left + LArea.Right - LX else Result := LX;
      Exit;
    end;
    if FColumns[I].Visible and FColumns[I].Frozen then Inc(LX, ScaleValue(FColumns[I].Width));
  end;
  LX := LArea.Left + GetCheckColumnWidth + GetDetailsColumnWidth + GetFrozenColumnsWidth - FHorizontalOffset;
  for I := 0 to FColumns.Count - 1 do
  begin
    if I = AIndex then
    begin
      if UseRightToLeftReading then Result := LArea.Left + LArea.Right - LX else Result := LX;
      Exit;
    end;
    if FColumns[I].Visible and not FColumns[I].Frozen then Inc(LX, ScaleValue(FColumns[I].Width));
  end;
  if UseRightToLeftReading then Result := LArea.Left + LArea.Right - LX else Result := LX;
end;

function TCustomThemedVirtualList.GetCellText(const ARowIndex: Integer; AColumn: TThemedVirtualListColumn): string;
var
  LItem: TThemedVirtualListItemData;
begin
  Result := '';
  if (AColumn = nil) or (ARowIndex < 0) or (ARowIndex >= FItemCount) then Exit;
  GetItemData(ARowIndex, LItem);
  Result := ResolveCellText(ARowIndex, AColumn, LItem);
end;

function TCustomThemedVirtualList.ResolveCellText(const ARowIndex: Integer; AColumn: TThemedVirtualListColumn; const AItem: TThemedVirtualListItemData): string;
begin
  Result := '';
  if AColumn = nil then Exit;
  case AColumn.Index of
    0: Result := AItem.Text;
    1: Result := AItem.Subtitle;
    2: Result := AItem.DetailText;
    3: Result := AItem.BadgeText;
  end;
  Result := AColumn.GetText(ARowIndex, AItem, Result);
  if Assigned(FOnGetCellText) then FOnGetCellText(Self, ARowIndex, AColumn, Result);
end;

function TCustomThemedVirtualList.HasAutoSizeColumns: Boolean;
var
  I: Integer;
begin
  Result := False;
  if FColumns = nil then Exit;
  for I := 0 to FColumns.Count - 1 do
    if FColumns[I].AutoSizeMode <> vlasmNone then Exit(True);
end;

procedure TCustomThemedVirtualList.QueueAutoSizeColumns(const AReset: Boolean);
begin
  if FAutoSizingColumns then Exit;
  if not HasAutoSizeColumns then
  begin
    FAutoSizePending := False;
    FAutoSizeReset := False;
    Exit;
  end;
  FAutoSizePending := True;
  if AReset then FAutoSizeReset := True;
  if not (csDestroying in ComponentState) then Invalidate;
end;

function TCustomThemedVirtualList.MeasureAutoSizeColumn(AColumn: TThemedVirtualListColumn): Integer;
var
  I, J, LRowIndex, LFirst, LLast, LContentWidth, LHeaderWidth, LPixelWidth, LVisibleCount: Integer;
  LPage: TThemedVirtualListCachePage;
  LItem: TThemedVirtualListItemData;
  LSize: TSize;
  LText: string;
  LMeasureHeader, LMeasureContent, LContentAvailable: Boolean;
begin
  Result := 0;
  if (AColumn = nil) or (AColumn.AutoSizeMode = vlasmNone) then Exit;
  LMeasureHeader := AColumn.AutoSizeMode in [vlasmHeader, vlasmAll];
  LMeasureContent := AColumn.AutoSizeMode in [vlasmContent, vlasmAll];
  LHeaderWidth := 0;
  LContentWidth := 0;
  LContentAvailable := not LMeasureContent or (FItemCount = 0);
  if LMeasureHeader then
  begin
    LSize := RenderCanvas.MeasureText(AColumn.HeaderText, Font, MaxInt div 4, [ntfSingleLine, ntfNoPrefix]);
    LHeaderWidth := LSize.cx + ScaleValue(16);
    if AColumn.SortDirection <> vlsdNone then Inc(LHeaderWidth, ScaleValue(18));
  end;
  if LMeasureContent and (FItemCount > 0) then
  begin
    if HasDataProvider then
    begin
      for I := 0 to FCachePages.Count - 1 do
      begin
        LPage := TThemedVirtualListCachePage(FCachePages[I]);
        if not LPage.Loaded then Continue;
        if Length(LPage.Items) > 0 then LContentAvailable := True;
        for J := 0 to Length(LPage.Items) - 1 do
        begin
          LRowIndex := LPage.PageIndex * FPageSize + J;
          if (LRowIndex < 0) or (LRowIndex >= FItemCount) then Continue;
          LText := ResolveCellText(LRowIndex, AColumn, LPage.Items[J]);
          if LText = '' then Continue;
          LSize := RenderCanvas.MeasureText(LText, Font, MaxInt div 4, [ntfSingleLine, ntfNoPrefix]);
          LContentWidth := Max(LContentWidth, LSize.cx + ScaleValue(16));
        end;
      end;
    end
    else if Assigned(FOnGetItem) then
    begin
      LContentAvailable := True;
      LVisibleCount := Max(16, GetItemArea.Height div Max(1, GetItemHeightPixels) + 4);
      LFirst := Max(0, GetTopIndex - 2);
      LLast := Min(FItemCount - 1, LFirst + LVisibleCount - 1);
      for I := LFirst to LLast do
      begin
        GetItemData(I, LItem);
        LText := ResolveCellText(I, AColumn, LItem);
        if LText = '' then Continue;
        LSize := RenderCanvas.MeasureText(LText, Font, MaxInt div 4, [ntfSingleLine, ntfNoPrefix]);
        LContentWidth := Max(LContentWidth, LSize.cx + ScaleValue(16));
      end;
    end;
  end;
  if LMeasureContent and not LContentAvailable then Exit(0);
  LPixelWidth := Max(LHeaderWidth, LContentWidth);
  if LPixelWidth <= 0 then Exit(AColumn.MinWidth);
  if CurrentPPI > 0 then Result := MulDiv(LPixelWidth, 96, CurrentPPI) else Result := LPixelWidth;
  Result := EnsureRange(Result, AColumn.MinWidth, AColumn.MaxWidth);
  if not FAutoSizeReset and (AColumn.AutoSizeMode in [vlasmContent, vlasmAll]) then Result := Max(Result, AColumn.Width);
end;

procedure TCustomThemedVirtualList.ApplyAutoSizeColumns;
var
  I, LWidth: Integer;
  LChanged, LPendingData: Boolean;
begin
  if FAutoSizingColumns then Exit;
  if not HasAutoSizeColumns then
  begin
    FAutoSizePending := False;
    FAutoSizeReset := False;
    Exit;
  end;
  if not FAutoSizePending then Exit;
  FAutoSizePending := False;
  FAutoSizingColumns := True;
  LChanged := False;
  LPendingData := False;
  FColumns.BeginUpdate;
  try
    for I := 0 to FColumns.Count - 1 do
      if FColumns[I].AutoSizeMode <> vlasmNone then
      begin
        LWidth := MeasureAutoSizeColumn(FColumns[I]);
        if LWidth = 0 then LPendingData := True;
        if (LWidth > 0) and (FColumns[I].Width <> LWidth) then
        begin
          FColumns[I].Width := LWidth;
          LChanged := True;
        end;
      end;
  finally
    FColumns.EndUpdate;
    FAutoSizingColumns := False;
    if LPendingData then FAutoSizePending := True else FAutoSizeReset := False;
  end;
  if LChanged then
  begin
    UpdateScrollBar;
    UpdateActiveEditorBounds;
  end;
end;

function TCustomThemedVirtualList.GetTableCellRect(const ARowIndex, AColumnIndex: Integer): TRect;
var
  LArea, LRow: TRect;
begin
  Result := Rect(0, 0, 0, 0);
  if not IsTableMode or (ARowIndex < 0) or (ARowIndex >= FItemCount) or (AColumnIndex < 0) or (AColumnIndex >= FColumns.Count) or not FColumns[AColumnIndex].Visible then Exit;
  LArea := GetItemArea;
  LRow := GetVisibleRowRect(ARowIndex);
  if NimbusRectIsEmpty(LRow) then Exit;
  Result := GetColumnRect(AColumnIndex, LRow.Top, LRow.Bottom);
  if not FColumns[AColumnIndex].Frozen then
  begin
    if UseRightToLeftReading then Result.Right := Min(Result.Right, LArea.Right - GetCheckColumnWidth - GetDetailsColumnWidth - GetFrozenColumnsWidth)
    else Result.Left := Max(Result.Left, LArea.Left + GetCheckColumnWidth + GetDetailsColumnWidth + GetFrozenColumnsWidth);
  end;
  Result.Left := Max(Result.Left, LArea.Left);
  Result.Top := Max(Result.Top, LArea.Top);
  Result.Right := Min(Result.Right, LArea.Right);
  Result.Bottom := Min(Result.Bottom, LArea.Bottom);
  if NimbusRectIsEmpty(Result) then Result := Rect(0, 0, 0, 0);
end;

function TCustomThemedVirtualList.GetTableCheckRect(const AIndex: Integer): TRect;
var
  LArea, LRow: TRect;
  LSize, LX: Integer;
begin
  Result := Rect(0, 0, 0, 0);
  if not IsTableMode or not FCheckBoxes or (AIndex < 0) or (AIndex >= FItemCount) then Exit;
  LArea := GetItemArea;
  LRow := GetVisibleRowRect(AIndex);
  if NimbusRectIsEmpty(LRow) then Exit;
  LSize := ScaleValue(14);
  LX := LArea.Left + (GetCheckColumnWidth - LSize) div 2;
  if UseRightToLeftReading then LX := LArea.Right - GetCheckColumnWidth + (GetCheckColumnWidth - LSize) div 2;
  Result := Rect(LX, LRow.Top + (LRow.Height - LSize) div 2, LX + LSize, LRow.Top + (LRow.Height + LSize) div 2);
end;

function TCustomThemedVirtualList.ResolveRowHeight(const AIndex: Integer; const AItem: TThemedVirtualListItemData): Integer;
var
  LHeight: Integer;
begin
  LHeight := FItemHeight;
  if Assigned(FOnGetRowHeight) then FOnGetRowHeight(Self, AIndex, AItem, LHeight);
  Result := ScaleValue(EnsureRange(LHeight, 16, 300));
end;

function TCustomThemedVirtualList.ResolveRowKind(const AIndex: Integer; const AItem: TThemedVirtualListItemData): TThemedVirtualListRowKind;
begin
  Result := vlrkNormal;
  if Assigned(FOnGetRowKind) then FOnGetRowKind(Self, AIndex, AItem, Result);
end;

function TCustomThemedVirtualList.ResolveGroupText(const AIndex: Integer; const AItem: TThemedVirtualListItemData): string;
begin
  Result := SVirtualListDefaultGroup;
  if Assigned(FOnGetGroupText) then FOnGetGroupText(Self, AIndex, AItem, Result);
  if Result = '' then Result := SVirtualListDefaultGroup;
end;

function TCustomThemedVirtualList.BuildCellRenderState(const AIndex: Integer; const AItem: TThemedVirtualListItemData; const AHasItem: Boolean): TThemedVirtualListCellRenderState;
begin
  Result.Selected := GetSelected(AIndex);
  Result.Hovered := FHotTrack and (AIndex = FHoverIndex);
  Result.Focused := Focused and (AIndex = FCurrentIndex);
  Result.Checked := GetCheckState(AIndex) = vlcsChecked;
  Result.Enabled := Enabled and AItem.Enabled and AHasItem;
  Result.Placeholder := not AHasItem;
end;

function TCustomThemedVirtualList.ResolveBadgeColor(const ABadge: TThemedVirtualListBadgeData; const AFallback: TColor): TColor;
begin
  case ABadge.ColorRole of
    vlbcInfo: Result := TColor(RGB(0, 120, 215));
    vlbcSuccess: Result := TColor(RGB(16, 124, 16));
    vlbcWarning: Result := TColor(RGB(202, 134, 0));
    vlbcError: Result := TColor(RGB(196, 43, 28));
    vlbcAccent: if Palette <> nil then Result := ThemeColorToColor(Palette.AccentColor) else Result := clHighlight;
    vlbcGray: Result := TColor(RGB(117, 117, 117));
    vlbcGold: Result := TColor(RGB(196, 151, 0));
    vlbcPink: Result := TColor(RGB(220, 80, 145));
    vlbcPurple: Result := TColor(RGB(135, 100, 184));
    vlbcOrange: Result := TColor(RGB(218, 89, 0));
    vlbcCustom: if ABadge.Color <> clNone then Result := ABadge.Color else Result := AFallback;
  else
    if ABadge.Color <> clNone then Result := ABadge.Color else Result := AFallback;
  end;
  if Result = clNone then
  begin
    if Palette <> nil then Result := ThemeColorToColor(Palette.AccentColor) else Result := clHighlight;
  end;
end;

procedure TCustomThemedVirtualList.RenderBadgeData(const ABounds: TRect; const ABadge: TThemedVirtualListBadgeData; const ASelected, AEnabled: Boolean; const AOptions: TThemedVirtualListBadgeRenderOptions);
var
  LText: string;
  LColor: TColor;
begin
  if NimbusRectIsEmpty(ABounds) or not ABadge.Visible or (ABadge.Alpha <= 0) or (ABadge.Scale <= 0) then Exit;
  LColor := ResolveBadgeColor(ABadge, clHighlight);
  case ABadge.Kind of
    vlbkCount:
      begin
        if ABadge.Count < 0 then LText := '0' else if ABadge.Count > 99 then LText := '99+' else LText := IntToStr(ABadge.Count);
        TThemedVirtualListRenderer.RenderInlineBadge(RenderCanvas, ABounds, LText, Font, Palette, LColor, ASelected, AEnabled, UseRightToLeftReading, AOptions, ABadge.Scale, ABadge.Alpha);
      end;
    vlbkDot: TThemedVirtualListRenderer.RenderInlineDotBadge(RenderCanvas, ABounds, Palette, LColor, ASelected, AEnabled, UseRightToLeftReading, AOptions, ABadge.Scale, ABadge.Alpha);
    vlbkImage:
      if (ABadge.Image <> nil) and not ABadge.Image.Empty then TThemedVirtualListRenderer.RenderInlineImageBadge(RenderCanvas, ABounds, ABadge.Image, Palette, LColor, ASelected, AEnabled, UseRightToLeftReading, AOptions, ABadge.Scale, ABadge.Alpha);
  else
    begin
      LText := ABadge.Text;
      if LText = '' then LText := ABadge.Key;
      if LText = '' then Exit;
      TThemedVirtualListRenderer.RenderInlineBadge(RenderCanvas, ABounds, LText, Font, Palette, LColor, ASelected, AEnabled, UseRightToLeftReading, AOptions, ABadge.Scale, ABadge.Alpha);
    end;
  end;
end;

procedure TCustomThemedVirtualList.RenderRowBadge(const AIndex: Integer; const ABounds: TRect; const AItem: TThemedVirtualListItemData);
var
  LBadge: TThemedVirtualListBadgeData;
begin
  if not FShowRowBadges or not Assigned(FOnGetRowBadge) or NimbusRectIsEmpty(ABounds) then Exit;
  LBadge := Default(TThemedVirtualListBadgeData);
  LBadge.Kind := vlbkText;
  LBadge.ColorRole := vlbcDefault;
  LBadge.Color := AItem.AccentColor;
  LBadge.Visible := True;
  LBadge.Scale := 1.0;
  LBadge.Alpha := 1.0;
  FOnGetRowBadge(Self, AIndex, AItem, LBadge);
  RenderBadgeData(ABounds, LBadge, GetSelected(AIndex), Enabled and AItem.Enabled, FRowBadgeOptions);
end;

procedure TCustomThemedVirtualList.RenderCellBadge(const AIndex: Integer; AColumn: TThemedVirtualListColumn; const ABounds: TRect; const AItem: TThemedVirtualListItemData; const ASelected, AEnabled: Boolean);
var
  LBadge: TThemedVirtualListBadgeData;
begin
  if not FShowCellBadges or not Assigned(FOnGetCellBadge) or (AColumn = nil) or NimbusRectIsEmpty(ABounds) then Exit;
  LBadge := Default(TThemedVirtualListBadgeData);
  LBadge.Kind := vlbkText;
  LBadge.ColorRole := vlbcDefault;
  LBadge.Color := AItem.AccentColor;
  LBadge.Visible := True;
  LBadge.Scale := 1.0;
  LBadge.Alpha := 1.0;
  FOnGetCellBadge(Self, AIndex, AColumn, AItem, LBadge);
  RenderBadgeData(ABounds, LBadge, ASelected, AEnabled, FCellBadgeOptions);
end;

function TCustomThemedVirtualList.GetDetailsExpanded(AIndex: Integer): Boolean;
begin
  Result := (AIndex >= 0) and (AIndex < Length(FExpandedDetails)) and (FExpandedDetails[AIndex] <> 0);
end;

function TCustomThemedVirtualList.GetVisibleRowRect(const AIndex: Integer): TRect;
var
  LArea: TRect;
  LItem: TThemedVirtualListItemData;
  LIndex, LTop, LHeight, LBaseHeight: Integer;
  LTop64: Int64;
  LLastGroup, LGroup: string;
  LRowKind: TThemedVirtualListRowKind;
begin
  Result := Rect(0, 0, 0, 0);
  if (AIndex < 0) or (AIndex >= FItemCount) then Exit;
  LArea := GetItemArea;
  LBaseHeight := GetItemHeightPixels;
  if not IsTableMode then
  begin
    LTop64 := Int64(LArea.Top) + Int64(AIndex) * LBaseHeight - FScrollOffset;
    if (LTop64 >= LArea.Bottom) or (LTop64 + LBaseHeight <= LArea.Top) then Exit;
    Result := Rect(LArea.Left, Integer(Max(Int64(LArea.Top), LTop64)), LArea.Right, Integer(Min(Int64(LArea.Bottom), LTop64 + LBaseHeight)));
    Exit;
  end;
  LIndex := EnsureRange(FScrollOffset div LBaseHeight, 0, Max(0, FItemCount - 1));
  LTop := LArea.Top - (FScrollOffset mod LBaseHeight);
  LLastGroup := '';
  while (LIndex < FItemCount) and (LTop < LArea.Bottom) do
  begin
    TryGetItemData(LIndex, LItem);
    if FShowGroupHeaders then
    begin
      LGroup := ResolveGroupText(LIndex, LItem);
      if LGroup <> LLastGroup then
      begin
        Inc(LTop, GetGroupHeaderHeightPixels);
        LLastGroup := LGroup;
      end;
    end;
    LRowKind := ResolveRowKind(LIndex, LItem);
    if FShowSeparators and (LRowKind = vlrkSeparator) then LHeight := LBaseHeight else LHeight := ResolveRowHeight(LIndex, LItem);
    if LIndex = AIndex then
    begin
      Result := Rect(LArea.Left, LTop, LArea.Right, Min(LArea.Bottom, LTop + LHeight));
      if Result.Bottom <= Result.Top then Result := Rect(0, 0, 0, 0);
      Exit;
    end;
    Inc(LTop, LHeight);
    if FShowRowDetails and GetDetailsExpanded(LIndex) then Inc(LTop, GetDetailsHeightPixels);
    Inc(LIndex);
  end;
end;

function TCustomThemedVirtualList.GetDetailsGlyphRectFromRow(const ARow: TRect): TRect;
var
  LArea: TRect;
  LX, LWidth: Integer;
begin
  Result := Rect(0, 0, 0, 0);
  if not IsTableMode or not FShowRowDetails or NimbusRectIsEmpty(ARow) then Exit;
  LArea := GetItemArea;
  LWidth := GetDetailsColumnWidth;
  LX := LArea.Left + GetCheckColumnWidth;
  if UseRightToLeftReading then LX := LArea.Right - GetCheckColumnWidth - LWidth;
  Result := Rect(LX, ARow.Top, LX + LWidth, ARow.Bottom);
end;

function TCustomThemedVirtualList.GetDetailsGlyphRect(const AIndex: Integer): TRect;
begin
  Result := GetDetailsGlyphRectFromRow(GetVisibleRowRect(AIndex));
end;

procedure TCustomThemedVirtualList.SetHorizontalOffset(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := EnsureRange(AValue, 0, GetMaxHorizontalOffset);
  if FHorizontalOffset = LValue then Exit;
  FHorizontalOffset := LValue;
  if (FHorizontalScrollBar <> nil) and FHorizontalScrollBar.Visible and not FUpdatingHorizontalScrollBar then
  begin
    FUpdatingHorizontalScrollBar := True;
    try
      FHorizontalScrollBar.Value := FHorizontalOffset;
    finally
      FUpdatingHorizontalScrollBar := False;
    end;
  end;
  UpdateActiveEditorBounds;
  Invalidate;
  if Assigned(FOnScroll) then FOnScroll(Self);
end;

procedure TCustomThemedVirtualList.HorizontalScrollBarChanged(Sender: TObject);
begin
  if FUpdatingHorizontalScrollBar then Exit;
  SetHorizontalOffset(FHorizontalScrollBar.Value);
end;

procedure TCustomThemedVirtualList.ToggleSort(const AColumnIndex: Integer; const AMultiColumn: Boolean);
var
  I: Integer;
  LColumn: TThemedVirtualListColumn;
begin
  if (AColumnIndex < 0) or (AColumnIndex >= FColumns.Count) then Exit;
  LColumn := FColumns[AColumnIndex];
  if not LColumn.Sortable then Exit;
  FColumns.BeginUpdate;
  try
    if not AMultiColumn then
      for I := 0 to FColumns.Count - 1 do
        if I <> AColumnIndex then FColumns[I].SortDirection := vlsdNone;
    case LColumn.SortDirection of
      vlsdNone: LColumn.SortDirection := vlsdAscending;
      vlsdAscending: LColumn.SortDirection := vlsdDescending;
    else
      LColumn.SortDirection := vlsdNone;
    end;
  finally
    FColumns.EndUpdate;
  end;
  if Assigned(FOnSortRequested) then FOnSortRequested(Self, LColumn, LColumn.SortDirection, AMultiColumn);
  RefreshItems;
end;

procedure TCustomThemedVirtualList.CopySelectionToClipboard;
var
  I, C: Integer;
  LText, LRowText: string;
  LItem: TThemedVirtualListItemData;
begin
  if FSelectedCount = 0 then Exit;
  LText := '';
  for I := 0 to FItemCount - 1 do
  begin
    if not GetSelected(I) then Continue;
    LRowText := '';
    if IsTableMode then
    begin
      for C := 0 to FColumns.Count - 1 do
      begin
        if not FColumns[C].Visible then Continue;
        if LRowText <> '' then LRowText := LRowText + #9;
        LRowText := LRowText + GetCellText(I, FColumns[C]);
      end;
    end
    else
    begin
      GetItemData(I, LItem);
      LRowText := LItem.Text;
    end;
    LText := LText + LRowText + #13#10;
  end;
  if LText <> '' then Clipboard.AsText := LText;
end;

procedure TCustomThemedVirtualList.RenderTableHeader(const AHeader: TRect);
var
  I, LCheckSize, LCheckState, LX: Integer;
  LRect, LArea, LCheckRect: TRect;
  LHot, LDragging: Boolean;
begin
  if not FShowHeader or NimbusRectIsEmpty(AHeader) then Exit;
  TThemedVirtualListRenderer.RenderHeaderBackground(RenderCanvas, AHeader, Palette, Color);
  if FCheckBoxes then
  begin
    LCheckSize := ScaleValue(14);
    if UseRightToLeftReading then LX := AHeader.Right - GetCheckColumnWidth + (GetCheckColumnWidth - LCheckSize) div 2
    else LX := AHeader.Left + (GetCheckColumnWidth - LCheckSize) div 2;
    LCheckRect := Rect(LX, AHeader.Top + (AHeader.Height - LCheckSize) div 2, LX + LCheckSize, AHeader.Top + (AHeader.Height + LCheckSize) div 2);
    if FCheckedStateCount = 0 then LCheckState := Ord(vlcsUnchecked)
    else if (FItemCount > 0) and (FCheckedStateCount >= FItemCount) then LCheckState := Ord(vlcsChecked)
    else LCheckState := Ord(vlcsIndeterminate);
    TThemedVirtualListRenderer.RenderCheckBox(RenderCanvas, LCheckRect, LCheckState, Enabled, Palette, clNone);
  end;
  LArea := GetItemArea;
  for I := 0 to FColumns.Count - 1 do
  begin
    if not FColumns[I].Visible then Continue;
    LRect := GetColumnRect(I, AHeader.Top, AHeader.Bottom);
    if not FColumns[I].Frozen then
    begin
      if UseRightToLeftReading then LRect.Right := Min(LRect.Right, LArea.Right - GetCheckColumnWidth - GetDetailsColumnWidth - GetFrozenColumnsWidth)
      else LRect.Left := Max(LRect.Left, LArea.Left + GetCheckColumnWidth + GetDetailsColumnWidth + GetFrozenColumnsWidth);
    end;
    if NimbusRectIsEmpty(LRect) or (LRect.Right <= AHeader.Left) or (LRect.Left >= AHeader.Right) then Continue;
    LRect.Left := Max(LRect.Left, AHeader.Left);
    LRect.Right := Min(LRect.Right, AHeader.Right);
    LHot := I = FHeaderHoverColumn;
    LDragging := FReorderDragging and (I = FReorderColumn);
    TThemedVirtualListRenderer.RenderHeaderCell(RenderCanvas, LRect, FColumns[I].HeaderText, Font, Palette, FColumns[I].HeaderAlignment, Ord(FColumns[I].SortDirection), LHot, LDragging, UseRightToLeftReading);
  end;
  if FReorderDragging and (FReorderTarget >= 0) then TThemedVirtualListRenderer.RenderDropIndicator(RenderCanvas, GetColumnInsertionX(FReorderTarget), AHeader.Top, ClientHeight, Palette);
end;

procedure TCustomThemedVirtualList.RenderTableRow(const AIndex: Integer; const ABounds: TRect; const AItem: TThemedVirtualListItemData; const AHasItem: Boolean);
var
  I, LFirstVisible, LStatusSize, LProgressHeight, LCheckSize, LCheckX: Integer;
  LRect, LTextRect, LArea, LCheckRect, LStatusRect, LBadgeRect, LProgressRect: TRect;
  LSelected, LEnabled, LHandled: Boolean;
  LText: string;
  LState: TThemedVirtualListCellRenderState;
begin
  if not AHasItem and FLoadingPlaceholders then
  begin
    TThemedVirtualListRenderer.RenderPlaceholderRow(RenderCanvas, ABounds, Palette, Color);
    Exit;
  end;
  LSelected := GetSelected(AIndex);
  LEnabled := Enabled and AItem.Enabled and AHasItem;
  TThemedVirtualListRenderer.RenderTableRowBackground(RenderCanvas, ABounds, Palette, Color, LSelected, FHotTrack and (AIndex = FHoverIndex), AIndex = FPressedIndex, FAlternatingRows and Odd(AIndex), Focused and (AIndex = FCurrentIndex), not LEnabled);
  LState := BuildCellRenderState(AIndex, AItem, AHasItem);
  LHandled := False;
  if AHasItem and Assigned(FOnRenderRow) then FOnRenderRow(Self, RenderCanvas, ABounds, AIndex, AItem, LState, LHandled);
  if LHandled then
  begin
    RenderRowBadge(AIndex, ABounds, AItem);
    TThemedVirtualListRenderer.RenderTableRowBorder(RenderCanvas, ABounds, Palette);
    Exit;
  end;
  if FCheckBoxes then
  begin
    LCheckSize := ScaleValue(14);
    LCheckX := ABounds.Left + (GetCheckColumnWidth - LCheckSize) div 2;
    if UseRightToLeftReading then LCheckX := ABounds.Right - GetCheckColumnWidth + (GetCheckColumnWidth - LCheckSize) div 2;
    LCheckRect := Rect(LCheckX, ABounds.Top + (ABounds.Height - LCheckSize) div 2, LCheckX + LCheckSize, ABounds.Top + (ABounds.Height + LCheckSize) div 2);
    TThemedVirtualListRenderer.RenderCheckBox(RenderCanvas, LCheckRect, Ord(GetCheckState(AIndex)), LEnabled, Palette, AItem.AccentColor);
  end;
  LArea := GetItemArea;
  LFirstVisible := -1;
  for I := 0 to FColumns.Count - 1 do
    if FColumns[I].Visible then
    begin
      LFirstVisible := I;
      Break;
    end;
  for I := 0 to FColumns.Count - 1 do
  begin
    if not FColumns[I].Visible then Continue;
    LRect := GetColumnRect(I, ABounds.Top, ABounds.Bottom);
    if not FColumns[I].Frozen then
    begin
      if UseRightToLeftReading then LRect.Right := Min(LRect.Right, LArea.Right - GetCheckColumnWidth - GetDetailsColumnWidth - GetFrozenColumnsWidth)
      else LRect.Left := Max(LRect.Left, LArea.Left + GetCheckColumnWidth + GetDetailsColumnWidth + GetFrozenColumnsWidth);
    end;
    if NimbusRectIsEmpty(LRect) or (LRect.Right <= LArea.Left) or (LRect.Left >= LArea.Right) then Continue;
    LRect.Left := Max(LRect.Left, LArea.Left);
    LRect.Right := Min(LRect.Right, LArea.Right);
    LTextRect := Rect(LRect.Left + ScaleValue(7), LRect.Top, Max(LRect.Left + ScaleValue(8), LRect.Right - ScaleValue(7)), LRect.Bottom);
    if (I = LFirstVisible) and (AItem.StatusColor <> clNone) then
    begin
      LStatusSize := Max(6, ScaleValue(8));
      if UseRightToLeftReading then
      begin
        LStatusRect := Rect(LTextRect.Right - LStatusSize, LRect.Top + (LRect.Height - LStatusSize) div 2, LTextRect.Right, LRect.Top + (LRect.Height + LStatusSize) div 2);
        LTextRect.Right := Max(LTextRect.Left + 1, LStatusRect.Left - ScaleValue(6));
      end
      else
      begin
        LStatusRect := Rect(LTextRect.Left, LRect.Top + (LRect.Height - LStatusSize) div 2, LTextRect.Left + LStatusSize, LRect.Top + (LRect.Height + LStatusSize) div 2);
        LTextRect.Left := Min(LTextRect.Right - 1, LStatusRect.Right + ScaleValue(6));
      end;
      TThemedVirtualListRenderer.RenderStatusIndicator(RenderCanvas, LStatusRect, AItem.StatusColor, LEnabled, Palette);
    end;
    LHandled := False;
    if AHasItem and Assigned(FColumns[I].FOnRenderCell) then FColumns[I].FOnRenderCell(Self, RenderCanvas, LTextRect, AIndex, AItem, LState, LHandled);
    if AHasItem and not LHandled and Assigned(FOnRenderCell) then FOnRenderCell(Self, RenderCanvas, LTextRect, AIndex, FColumns[I], AItem, LState, LHandled);
    if not LHandled then
    begin
      LText := GetCellText(AIndex, FColumns[I]);
      if (I = 3) and (AItem.BadgeText <> '') then
      begin
        LBadgeRect := LTextRect;
        InflateRect(LBadgeRect, -ScaleValue(4), -ScaleValue(4));
        if LBadgeRect.Width > ScaleValue(90) then
        begin
          if FColumns[I].Alignment = taRightJustify then LBadgeRect.Left := LBadgeRect.Right - ScaleValue(90)
          else if FColumns[I].Alignment = taCenter then
          begin
            LBadgeRect.Left := (LBadgeRect.Left + LBadgeRect.Right - ScaleValue(90)) div 2;
            LBadgeRect.Right := LBadgeRect.Left + ScaleValue(90);
          end
          else LBadgeRect.Right := LBadgeRect.Left + ScaleValue(90);
        end;
        TThemedVirtualListRenderer.RenderBadge(RenderCanvas, LBadgeRect, AItem.BadgeText, Font, Palette, AItem.AccentColor, LSelected, LEnabled);
      end
      else
      begin
        TThemedVirtualListRenderer.RenderCellText(RenderCanvas, LTextRect, LText, Font, Palette, Font.Color, FColumns[I].Alignment, LSelected, LEnabled, UseRightToLeftReading);
        if (I = 4) and FShowProgress and AItem.ShowProgress then
        begin
          LProgressHeight := Max(2, ScaleValue(3));
          LProgressRect := Rect(LTextRect.Left, LRect.Bottom - LProgressHeight - ScaleValue(3), LTextRect.Right, LRect.Bottom - ScaleValue(3));
          TThemedVirtualListRenderer.RenderProgress(RenderCanvas, LProgressRect, AItem.ProgressValue, Palette, AItem.AccentColor, LEnabled, UseRightToLeftReading);
        end;
      end;
    end;
    if AHasItem then RenderCellBadge(AIndex, FColumns[I], LRect, AItem, LSelected, LEnabled);
    TThemedVirtualListRenderer.RenderColumnSeparator(RenderCanvas, LRect, Palette);
  end;
  if AHasItem then RenderRowBadge(AIndex, ABounds, AItem);
  TThemedVirtualListRenderer.RenderTableRowBorder(RenderCanvas, ABounds, Palette);
end;

procedure TCustomThemedVirtualList.RenderGlobalSearch;
var
  LRect: TRect;
begin
  if not FShowGlobalSearch then Exit;
  LRect := GetGlobalSearchRect;
  if NimbusRectIsEmpty(LRect) then Exit;
  TThemedVirtualListRenderer.RenderSearchBox(RenderCanvas, LRect, Palette, Color, FGlobalFilterBox.Focused);
end;

procedure TCustomThemedVirtualList.RenderFilterRow;
var
  I: Integer;
  LBounds, LRect, LArea: TRect;
begin
  if not FShowFilterRow then Exit;
  LBounds := GetFilterRect;
  if NimbusRectIsEmpty(LBounds) then Exit;
  TThemedVirtualListRenderer.RenderFilterBackground(RenderCanvas, LBounds, Palette, Color);
  if not IsTableMode then Exit;
  LArea := GetItemArea;
  for I := 0 to FColumns.Count - 1 do
  begin
    if not FColumns[I].Visible then Continue;
    LRect := GetColumnRect(I, LBounds.Top, LBounds.Bottom);
    if not FColumns[I].Frozen then
    begin
      if UseRightToLeftReading then LRect.Right := Min(LRect.Right, LArea.Right - GetCheckColumnWidth - GetDetailsColumnWidth - GetFrozenColumnsWidth)
      else LRect.Left := Max(LRect.Left, LArea.Left + GetCheckColumnWidth + GetDetailsColumnWidth + GetFrozenColumnsWidth);
    end;
    if NimbusRectIsEmpty(LRect) or (LRect.Right <= LBounds.Left) or (LRect.Left >= LBounds.Right) then Continue;
    LRect.Left := Max(LRect.Left, LBounds.Left) + ScaleValue(4);
    LRect.Right := Min(LRect.Right, LBounds.Right) - ScaleValue(4);
    LRect.Top := LRect.Top + ScaleValue(4);
    LRect.Bottom := LRect.Bottom - ScaleValue(4);
    if not NimbusRectIsEmpty(LRect) then TThemedVirtualListRenderer.RenderFilterCell(RenderCanvas, LRect, Palette);
  end;
end;

procedure TCustomThemedVirtualList.RenderRowDetails(const AIndex: Integer; const ABounds: TRect; const AItem: TThemedVirtualListItemData; const AHasItem: Boolean);
var
  LTextRect: TRect;
  LText: string;
  LHandled: Boolean;
  LState: TThemedVirtualListCellRenderState;
begin
  TThemedVirtualListRenderer.RenderDetailsBackground(RenderCanvas, ABounds, Palette, Color);
  if not AHasItem then Exit;
  LState := BuildCellRenderState(AIndex, AItem, AHasItem);
  LHandled := False;
  if Assigned(FOnRenderRowDetails) then FOnRenderRowDetails(Self, RenderCanvas, ABounds, AIndex, AItem, LState, LHandled);
  if LHandled then Exit;
  LText := AItem.DetailText;
  if LText = '' then LText := AItem.Subtitle;
  LTextRect := ABounds;
  InflateRect(LTextRect, -ScaleValue(10), -ScaleValue(6));
  if NimbusRectIsEmpty(LTextRect) then Exit;
  TThemedVirtualListRenderer.RenderCellText(RenderCanvas, LTextRect, LText, Font, Palette, Font.Color, taLeftJustify, False, AItem.Enabled and Enabled, UseRightToLeftReading);
end;

procedure TCustomThemedVirtualList.RenderTable(const AArea: TRect);
var
  LIndex, LTop, LHeight, LBaseHeight: Integer;
  LBounds, LDetailsBounds: TRect;
  LItem: TThemedVirtualListItemData;
  LHasItem: Boolean;
  LLastGroup, LGroup: string;
  LRowKind: TThemedVirtualListRowKind;
begin
  RenderTableHeader(GetHeaderRect);
  if FItemCount = 0 then
  begin
    TThemedVirtualListRenderer.RenderEmpty(RenderCanvas, AArea, FEmptyText, Font, Palette, Color, Font.Color, UseRightToLeftReading);
    Exit;
  end;
  LBaseHeight := GetItemHeightPixels;
  LIndex := EnsureRange(FScrollOffset div LBaseHeight, 0, FItemCount - 1);
  LTop := AArea.Top - (FScrollOffset mod LBaseHeight);
  LLastGroup := '';
  while (LIndex < FItemCount) and (LTop < AArea.Bottom) do
  begin
    LHasItem := TryGetItemData(LIndex, LItem);
    if FShowGroupHeaders then
    begin
      LGroup := ResolveGroupText(LIndex, LItem);
      if LGroup <> LLastGroup then
      begin
        LBounds := Rect(AArea.Left, LTop, AArea.Right, Min(AArea.Bottom, LTop + GetGroupHeaderHeightPixels));
        TThemedVirtualListRenderer.RenderGroupHeader(RenderCanvas, LBounds, LGroup, Font, Palette, Color, UseRightToLeftReading);
        Inc(LTop, GetGroupHeaderHeightPixels);
        LLastGroup := LGroup;
        if LTop >= AArea.Bottom then Break;
      end;
    end;
    LRowKind := ResolveRowKind(LIndex, LItem);
    if FShowSeparators and (LRowKind = vlrkSeparator) then
    begin
      LBounds := Rect(AArea.Left, LTop, AArea.Right, Min(AArea.Bottom, LTop + LBaseHeight));
      TThemedVirtualListRenderer.RenderSeparator(RenderCanvas, LBounds, Palette);
      Inc(LTop, LBaseHeight);
      Inc(LIndex);
      Continue;
    end;
    LHeight := ResolveRowHeight(LIndex, LItem);
    LBounds := Rect(AArea.Left, LTop, AArea.Right, Min(AArea.Bottom, LTop + LHeight));
    RenderTableRow(LIndex, LBounds, LItem, LHasItem);
    if FShowRowDetails and LHasItem then TThemedVirtualListRenderer.RenderDetailsGlyph(RenderCanvas, GetDetailsGlyphRectFromRow(LBounds), GetDetailsExpanded(LIndex), Palette, Font.Color, UseRightToLeftReading);
    Inc(LTop, LHeight);
    if FShowRowDetails and GetDetailsExpanded(LIndex) and (LTop < AArea.Bottom) then
    begin
      LDetailsBounds := Rect(AArea.Left + GetCheckColumnWidth + ScaleValue(8), LTop, AArea.Right - ScaleValue(8), Min(AArea.Bottom, LTop + GetDetailsHeightPixels));
      if UseRightToLeftReading then LDetailsBounds := Rect(AArea.Left + ScaleValue(8), LTop, AArea.Right - GetCheckColumnWidth - ScaleValue(8), Min(AArea.Bottom, LTop + GetDetailsHeightPixels));
      RenderRowDetails(LIndex, LDetailsBounds, LItem, LHasItem);
      Inc(LTop, GetDetailsHeightPixels);
    end;
    Inc(LIndex);
  end;
end;

procedure TCustomThemedVirtualList.UpdateMetrics;
begin
  FMetrics.HorizontalPadding := ScaleValue(10);
  FMetrics.VerticalPadding := ScaleValue(5);
  FMetrics.Spacing := ScaleValue(8);
  FMetrics.ImageSize := ScaleValue(28);
  FMetrics.CheckSize := ScaleValue(16);
  FMetrics.StatusSize := ScaleValue(8);
  FMetrics.BadgeHeight := ScaleValue(20);
  FMetrics.BadgePadding := ScaleValue(7);
  FMetrics.ProgressHeight := Max(2, ScaleValue(3));
  FMetrics.SelectionRadius := ScaleValue(6);
  FMetrics.BorderInset := Max(1, ScaleValue(2));
end;

function TCustomThemedVirtualList.GetItemHeightPixels: Integer;
begin
  Result := Max(1, ScaleValue(FItemHeight));
end;

function TCustomThemedVirtualList.GetItemArea: TRect;
begin
  Result := GetControlClientRect;
  Inc(Result.Top, GetTopOffsetPixels);
  if (FScrollBar <> nil) and FScrollBar.Visible then
  begin
    if UseRightToLeftScrollBar then Result.Left := Min(Result.Right, FScrollBar.Left + FScrollBar.Width) else Result.Right := Max(Result.Left, FScrollBar.Left);
  end;
  if (FHorizontalScrollBar <> nil) and FHorizontalScrollBar.Visible then Result.Bottom := Max(Result.Top, FHorizontalScrollBar.Top);
end;

function TCustomThemedVirtualList.GetMaxScrollOffset: Integer;
var
  LTotal: Int64;
  LArea: TRect;
begin
  LArea := GetItemArea;
  LTotal := Int64(FItemCount) * GetItemHeightPixels - LArea.Height;
  if LTotal <= 0 then Exit(0);
  if LTotal > High(Integer) then Result := High(Integer) else Result := Integer(LTotal);
end;

procedure TCustomThemedVirtualList.SetScrollOffset(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := EnsureRange(AValue, 0, GetMaxScrollOffset);
  if FScrollOffset = LValue then Exit;
  FScrollOffset := LValue;
  if (FScrollBar <> nil) and FScrollBar.Visible and not FUpdatingScrollBar then
  begin
    FUpdatingScrollBar := True;
    try
      FScrollBar.Value := FScrollOffset;
    finally
      FUpdatingScrollBar := False;
    end;
  end;
  UpdateActiveEditorBounds;
  if not HasDataProvider then QueueAutoSizeColumns(False);
  Invalidate;
  ScheduleRequest;
  if Assigned(FOnScroll) then FOnScroll(Self);
end;

procedure TCustomThemedVirtualList.SetPageSize(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := EnsureRange(AValue, 10, 5000);
  if FPageSize = LValue then Exit;
  FPageSize := LValue;
  ClearItemCache;
  QueueAutoSizeColumns(True);
  ScheduleRequest;
  Invalidate;
end;

procedure TCustomThemedVirtualList.SetMaxCachedPages(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := EnsureRange(AValue, 1, 512);
  if FMaxCachedPages = LValue then Exit;
  FMaxCachedPages := LValue;
  TrimItemCache;
end;

procedure TCustomThemedVirtualList.SetLoadingPlaceholders(const AValue: Boolean);
begin
  if FLoadingPlaceholders = AValue then Exit;
  FLoadingPlaceholders := AValue;
  Invalidate;
end;

procedure TCustomThemedVirtualList.SetShowRowBadges(const AValue: Boolean);
begin
  if FShowRowBadges = AValue then Exit;
  FShowRowBadges := AValue;
  Invalidate;
end;

procedure TCustomThemedVirtualList.SetShowCellBadges(const AValue: Boolean);
begin
  if FShowCellBadges = AValue then Exit;
  FShowCellBadges := AValue;
  Invalidate;
end;


procedure TCustomThemedVirtualList.SetRowBadgeOptions(const AValue: TThemedVirtualListBadgeRenderOptions);
begin
  if AValue = nil then FRowBadgeOptions.SetRowDefaults else FRowBadgeOptions.Assign(AValue);
  Invalidate;
end;

procedure TCustomThemedVirtualList.SetCellBadgeOptions(const AValue: TThemedVirtualListBadgeRenderOptions);
begin
  if AValue = nil then FCellBadgeOptions.SetCellDefaults else FCellBadgeOptions.Assign(AValue);
  Invalidate;
end;

procedure TCustomThemedVirtualList.BadgeOptionsChanged(Sender: TObject);
begin
  if FUpdateCount = 0 then Invalidate;
end;

procedure TCustomThemedVirtualList.SetOnRequestItems(const AValue: TThemedVirtualListRequestItemsEvent);
begin
  if (TMethod(FOnRequestItems).Code = TMethod(AValue).Code) and (TMethod(FOnRequestItems).Data = TMethod(AValue).Data) then Exit;
  FOnRequestItems := AValue;
  ClearItemCache;
  QueueAutoSizeColumns(True);
  ScheduleRequest;
  Invalidate;
end;

procedure TCustomThemedVirtualList.SetOnRequestItemsAsync(const AValue: TThemedVirtualListRequestItemsAsyncEvent);
begin
  if (TMethod(FOnRequestItemsAsync).Code = TMethod(AValue).Code) and (TMethod(FOnRequestItemsAsync).Data = TMethod(AValue).Data) then Exit;
  FOnRequestItemsAsync := AValue;
  ClearItemCache;
  QueueAutoSizeColumns(True);
  ScheduleRequest;
  Invalidate;
end;

procedure TCustomThemedVirtualList.UpdateScrollBar;
var
  LBarSize, LTopOffset, LAvailableWidth, LAvailableHeight, LMaximum, LHorizontalMaximum, LHorizontalViewport: Integer;
  LTotalHeight: Int64;
  LNeedVertical, LNeedHorizontal, LNewVertical, LNewHorizontal: Boolean;
  LClientRect: TRect;
  I: Integer;
begin
  if (FScrollBar = nil) or (FHorizontalScrollBar = nil) or (FUpdateCount > 0) then Exit;
  LClientRect := GetControlClientRect;
  LBarSize := EnsureRange(ScaleValue(FScrollBarWidth), ScaleValue(6), ScaleValue(18));
  LTopOffset := GetTopOffsetPixels;
  LTotalHeight := Int64(FItemCount) * GetItemHeightPixels;
  LNeedVertical := FScrollBarMode = vlsbAlways;
  LNeedHorizontal := False;
  for I := 0 to 2 do
  begin
    LAvailableWidth := Max(1, LClientRect.Width - Ord(LNeedVertical) * LBarSize);
    LAvailableHeight := Max(1, LClientRect.Height - LTopOffset - Ord(LNeedHorizontal) * LBarSize);
    case FScrollBarMode of
      vlsbAlways: LNewVertical := True;
      vlsbNever: LNewVertical := False;
    else
      LNewVertical := LTotalHeight > LAvailableHeight;
    end;
    if IsTableMode then
      LNewHorizontal := GetScrollableColumnsWidth > Max(1, LAvailableWidth - GetCheckColumnWidth - GetDetailsColumnWidth - GetFrozenColumnsWidth)
    else
      LNewHorizontal := False;
    if (LNewVertical = LNeedVertical) and (LNewHorizontal = LNeedHorizontal) then Break;
    LNeedVertical := LNewVertical;
    LNeedHorizontal := LNewHorizontal;
  end;
  FScrollBar.Visible := LNeedVertical;
  FHorizontalScrollBar.Visible := LNeedHorizontal;
  if LNeedVertical then
  begin
    if UseRightToLeftScrollBar then
      FScrollBar.SetBounds(0, LTopOffset, LBarSize, Max(1, LClientRect.Height - LTopOffset - Ord(LNeedHorizontal) * LBarSize))
    else
      FScrollBar.SetBounds(Max(0, LClientRect.Width - LBarSize), LTopOffset, LBarSize, Max(1, LClientRect.Height - LTopOffset - Ord(LNeedHorizontal) * LBarSize));
  end;
  if LNeedHorizontal then
  begin
    if UseRightToLeftScrollBar and LNeedVertical then
      FHorizontalScrollBar.SetBounds(LBarSize, Max(0, LClientRect.Height - LBarSize), Max(1, LClientRect.Width - LBarSize), LBarSize)
    else
      FHorizontalScrollBar.SetBounds(0, Max(0, LClientRect.Height - LBarSize), Max(1, LClientRect.Width - Ord(LNeedVertical) * LBarSize), LBarSize);
  end;
  if LTotalHeight <= 0 then LMaximum := 0 else if LTotalHeight - 1 > High(Integer) then LMaximum := High(Integer) else LMaximum := Integer(LTotalHeight - 1);
  FUpdatingScrollBar := True;
  try
    FScrollBar.Minimum := 0;
    FScrollBar.Maximum := LMaximum;
    FScrollBar.LargeChange := Max(1, GetItemArea.Height);
    FScrollBar.SmallChange := GetItemHeightPixels;
    FScrollOffset := EnsureRange(FScrollOffset, 0, GetMaxScrollOffset);
    FScrollBar.Value := FScrollOffset;
  finally
    FUpdatingScrollBar := False;
  end;
  LHorizontalViewport := Max(1, GetItemArea.Width - GetCheckColumnWidth - GetDetailsColumnWidth - GetFrozenColumnsWidth);
  LHorizontalMaximum := Max(0, GetScrollableColumnsWidth - 1);
  FUpdatingHorizontalScrollBar := True;
  try
    FHorizontalScrollBar.Minimum := 0;
    FHorizontalScrollBar.Maximum := LHorizontalMaximum;
    FHorizontalScrollBar.LargeChange := LHorizontalViewport;
    FHorizontalScrollBar.SmallChange := Max(1, ScaleValue(24));
    FHorizontalOffset := EnsureRange(FHorizontalOffset, 0, GetMaxHorizontalOffset);
    FHorizontalScrollBar.Value := FHorizontalOffset;
  finally
    FUpdatingHorizontalScrollBar := False;
  end;
  UpdateFilterEditorBounds;
  UpdateActiveEditorBounds;
end;

procedure TCustomThemedVirtualList.ScrollBarChanged(Sender: TObject);
begin
  if FUpdatingScrollBar then Exit;
  SetScrollOffset(FScrollBar.Value);
end;

procedure TCustomThemedVirtualList.SetItemCount(const AValue: Integer);
var
  LValue, I, LOldSelectedCount, LOldCurrentIndex: Integer;
  LReleaseCapture: Boolean;
begin
  LValue := Max(0, AValue);
  if FItemCount = LValue then Exit;
  LOldSelectedCount := FSelectedCount;
  LOldCurrentIndex := FCurrentIndex;
  FItemCount := LValue;
  if FEditingRowIndex >= FItemCount then EndCellEdit(False);
  ClearItemCache;
  SetLength(FSelected, FItemCount);
  SetLength(FCheckStates, FItemCount);
  SetLength(FExpandedDetails, FItemCount);
  FSelectedCount := 0;
  FCheckedStateCount := 0;
  for I := 0 to FItemCount - 1 do
  begin
    if FSelected[I] <> 0 then Inc(FSelectedCount);
    if FCheckStates[I] <> Byte(Ord(vlcsUnchecked)) then Inc(FCheckedStateCount);
  end;
  if FCurrentIndex >= FItemCount then
  begin
    FCurrentIndex := -1;
    for I := FItemCount - 1 downto 0 do
      if FSelected[I] <> 0 then
      begin
        FCurrentIndex := I;
        Break;
      end;
  end;
  if FAnchorIndex >= FItemCount then FAnchorIndex := FCurrentIndex;
  if FHoverIndex >= FItemCount then FHoverIndex := -1;
  LReleaseCapture := FPressedIndex >= FItemCount;
  if LReleaseCapture then
  begin
    FPressedIndex := -1;
    FPressedCheck := False;
  end;
  UpdateScrollBar;
  QueueAutoSizeColumns(True);
  ScheduleRequest;
  Invalidate;
  if LReleaseCapture and HandleAllocated then
    if MouseCapture then MouseCapture := False;
  if (LOldSelectedCount <> FSelectedCount) or (LOldCurrentIndex <> FCurrentIndex) then DoSelectionChanged;
end;

procedure TCustomThemedVirtualList.SetItemHeight(const AValue: Integer);
var
  LValue: Integer;
begin
  if not FStyleMetricsApplying then FCompactRowApplied := False;
  LValue := EnsureRange(AValue, 16, 120);
  if FItemHeight = LValue then Exit;
  FItemHeight := LValue;
  UpdateMetrics;
  UpdateScrollBar;
  ScheduleRequest;
  Invalidate;
end;

procedure TCustomThemedVirtualList.SetScrollBarWidth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := EnsureRange(AValue, 6, 18);
  if FScrollBarWidth = LValue then Exit;
  FScrollBarWidth := LValue;
  UpdateScrollBar;
  Invalidate;
end;

procedure TCustomThemedVirtualList.SetWheelScrollItems(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(1, AValue);
  if FWheelScrollItems = LValue then Exit;
  FWheelScrollItems := LValue;
end;

procedure TCustomThemedVirtualList.SetSelectedIndex(const AValue: Integer);
var
  LValue: Integer;
begin
  if FItemCount = 0 then LValue := -1 else LValue := EnsureRange(AValue, -1, FItemCount - 1);
  if LValue = -1 then
  begin
    ClearSelection;
    Exit;
  end;
  if not IsItemEnabled(LValue) then Exit;
  if (FCurrentIndex = LValue) and GetSelected(LValue) and (FSelectedCount = 1) then Exit;
  FAnchorIndex := LValue;
  MakeVisible(LValue);
  SetOnlySelected(LValue);
end;

procedure TCustomThemedVirtualList.SetMultiSelect(const AValue: Boolean);
var
  I, LKeepIndex: Integer;
begin
  if FMultiSelect = AValue then
  begin
    if AValue and (FSelectionMode = vlsmSingle) then FSelectionMode := vlsmMulti;
    if not AValue and (FSelectionMode <> vlsmSingle) then FSelectionMode := vlsmSingle;
    Exit;
  end;
  FMultiSelect := AValue;
  if FMultiSelect then
  begin
    if FSelectionMode = vlsmSingle then FSelectionMode := vlsmMulti;
    Exit;
  end;
  FSelectionMode := vlsmSingle;
  LKeepIndex := -1;
  if (FCurrentIndex >= 0) and GetSelected(FCurrentIndex) and IsItemEnabled(FCurrentIndex) then
    LKeepIndex := FCurrentIndex
  else
    for I := 0 to FItemCount - 1 do
      if GetSelected(I) and IsItemEnabled(I) then
      begin
        LKeepIndex := I;
        Break;
      end;
  if LKeepIndex >= 0 then
  begin
    FAnchorIndex := LKeepIndex;
    SetOnlySelected(LKeepIndex);
  end
  else if (FSelectedCount <> 0) or (FCurrentIndex <> -1) then
    ClearSelection;
end;

procedure TCustomThemedVirtualList.SetCheckBoxes(const AValue: Boolean);
begin
  if FCheckBoxes = AValue then Exit;
  FCheckBoxes := AValue;
  UpdateScrollBar;
  Invalidate;
end;

procedure TCustomThemedVirtualList.SetTriStateCheckBoxes(const AValue: Boolean);
var
  I: Integer;
begin
  if FTriStateCheckBoxes = AValue then Exit;
  FTriStateCheckBoxes := AValue;
  if not FTriStateCheckBoxes then
    for I := 0 to FItemCount - 1 do
      if Integer(FCheckStates[I]) = Ord(vlcsIndeterminate) then
      begin
        FCheckStates[I] := Ord(vlcsUnchecked);
        Dec(FCheckedStateCount);
      end;
  Invalidate;
end;

procedure TCustomThemedVirtualList.SetShowSubtitles(const AValue: Boolean);
begin
  if FShowSubtitles = AValue then Exit;
  FShowSubtitles := AValue;
  Invalidate;
end;

procedure TCustomThemedVirtualList.SetShowDetails(const AValue: Boolean);
begin
  if FShowDetails = AValue then Exit;
  FShowDetails := AValue;
  Invalidate;
end;

procedure TCustomThemedVirtualList.SetShowProgress(const AValue: Boolean);
begin
  if FShowProgress = AValue then Exit;
  FShowProgress := AValue;
  Invalidate;
end;

procedure TCustomThemedVirtualList.SetRoundedSelection(const AValue: Boolean);
begin
  if FRoundedSelection = AValue then Exit;
  FRoundedSelection := AValue;
  Invalidate;
end;

procedure TCustomThemedVirtualList.SetAlternatingRows(const AValue: Boolean);
begin
  if FAlternatingRows = AValue then Exit;
  FAlternatingRows := AValue;
  Invalidate;
end;

procedure TCustomThemedVirtualList.SetHotTrack(const AValue: Boolean);
begin
  if FHotTrack = AValue then Exit;
  FHotTrack := AValue;
  if not FHotTrack then FHoverIndex := -1;
  Invalidate;
end;

procedure TCustomThemedVirtualList.SetScrollBarMode(const AValue: TThemedVirtualListScrollBarMode);
begin
  if FScrollBarMode = AValue then Exit;
  FScrollBarMode := AValue;
  UpdateScrollBar;
  Invalidate;
end;

procedure TCustomThemedVirtualList.SetEmptyText(const AValue: string);
begin
  if FEmptyText = AValue then Exit;
  FEmptyText := AValue;
  if FItemCount = 0 then Invalidate;
end;

procedure TCustomThemedVirtualList.SetImages(const AValue: TCustomImageList);
begin
  if FImages = AValue then Exit;
  if FImages <> nil then
  begin
    FImages.UnRegisterChanges(FImageChangeLink);
    FImages.RemoveFreeNotification(Self);
  end;
  FImages := AValue;
  if FImages <> nil then
  begin
    FImages.RegisterChanges(FImageChangeLink);
    FImages.FreeNotification(Self);
  end;
  Invalidate;
end;

procedure TCustomThemedVirtualList.ImageListChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TCustomThemedVirtualList.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FImages) then FImages := nil;
end;

procedure TCustomThemedVirtualList.Loaded;
begin
  inherited Loaded;
  UpdateMetrics;
  UpdateScrollBar;
  UpdateGlobalFilterPlaceholder;
  UpdateFilterEditorTheme;
  UpdateFilterEditorBounds;
  QueueAutoSizeColumns(True);
  ScheduleRequest;
end;

procedure TCustomThemedVirtualList.Resize;
begin
  inherited Resize;
  UpdateScrollBar;
  UpdateFilterEditorBounds;
  UpdateActiveEditorBounds;
  ScheduleRequest;
end;

procedure TCustomThemedVirtualList.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited ChangeScale(M, D, isDpiChange);
  if D <> 0 then
  begin
    FScrollOffset := MulDiv(FScrollOffset, M, D);
    FHorizontalOffset := MulDiv(FHorizontalOffset, M, D);
  end;
  UpdateMetrics;
  UpdateScrollBar;
  UpdateFilterEditorBounds;
  UpdateActiveEditorBounds;
  QueueAutoSizeColumns(True);
  ScheduleRequest;
  Invalidate;
end;

procedure TCustomThemedVirtualList.CMEnabledChanged(var Message: TMessage);
begin
  if not Enabled and not (csDestroying in ComponentState) then
  begin
    EndCellEdit(False);
    FPressedIndex := -1;
    FPressedCheck := False;
    FHoverIndex := -1;
    FHeaderHoverColumn := -1;
    FResizeColumn := -1;
    FReorderColumn := -1;
    FReorderTarget := -1;
    FReorderDragging := False;
    Cursor := crDefault;
    if MouseCapture then MouseCapture := False;
  end;
  inherited;
  if FGlobalFilterBox <> nil then FGlobalFilterBox.Enabled := Enabled;
  Invalidate;
end;

procedure TCustomThemedVirtualList.CMFontChanged(var Message: TMessage);
begin
  inherited;
  UpdateFilterEditorTheme;
  if FActiveEditor <> nil then FActiveEditor.Font.Assign(Font);
  QueueAutoSizeColumns(True);
  Invalidate;
end;

procedure TCustomThemedVirtualList.CMColorChanged(var Message: TMessage);
begin
  inherited;
  UpdateFilterEditorTheme;
  if (FActiveEditor <> nil) and (Palette = nil) then FActiveEditor.Color := Color;
  Invalidate;
end;

procedure TCustomThemedVirtualList.CMBiDiModeChanged(var Message: TMessage);
begin
  if not (csDestroying in ComponentState) then
  begin
    UpdateScrollBar;
    UpdateFilterEditorBounds;
  end;
  inherited;
end;

procedure TCustomThemedVirtualList.CMEnter(var Message: TCMEnter);
begin
  InvalidateItem(FCurrentIndex);
  inherited;
end;

procedure TCustomThemedVirtualList.CMExit(var Message: TCMExit);
begin
  InvalidateItem(FCurrentIndex);
  inherited;
end;

procedure TCustomThemedVirtualList.InitializeItemData(out AItem: TThemedVirtualListItemData);
begin
  AItem := Default(TThemedVirtualListItemData);
  AItem.ImageIndex := -1;
  AItem.StatusColor := clNone;
  AItem.AccentColor := clNone;
  AItem.Enabled := True;
end;

procedure TCustomThemedVirtualList.NormalizeItemData(var AItem: TThemedVirtualListItemData);
begin
  AItem.ProgressValue := EnsureRange(AItem.ProgressValue, 0, 100);
end;

procedure TCustomThemedVirtualList.CancelPendingRequests(const ANotify: Boolean);
var
  LRequest: TThemedVirtualListPendingRequest;
begin
  if FPendingRequests = nil then Exit;
  while FPendingRequests.Count > 0 do
  begin
    LRequest := TThemedVirtualListPendingRequest(FPendingRequests[FPendingRequests.Count - 1]);
    FPendingRequests.Delete(FPendingRequests.Count - 1);
    if ANotify and Assigned(FOnRequestItemsCancelled) then FOnRequestItemsCancelled(Self, LRequest.Token);
    LRequest.Free;
  end;
end;

function TCustomThemedVirtualList.HasDataProvider: Boolean;
begin
  Result := Assigned(FOnRequestItemsAsync) or Assigned(FOnRequestItems);
end;

procedure TCustomThemedVirtualList.ClearItemCache;
var
  I: Integer;
begin
  CancelPendingRequests(not (csDestroying in ComponentState));
  if FCachePages = nil then Exit;
  for I := FCachePages.Count - 1 downto 0 do TObject(FCachePages[I]).Free;
  FCachePages.Clear;
  FCacheTouch := 0;
  Inc(FCacheGeneration);
end;

procedure TCustomThemedVirtualList.ClearCachedPageForIndex(const AIndex: Integer);
var
  I, LPageIndex: Integer;
begin
  if (FCachePages = nil) or (FPageSize <= 0) or (AIndex < 0) then Exit;
  LPageIndex := AIndex div FPageSize;
  Inc(FCacheGeneration);
  CancelPendingRequests(True);
  for I := 0 to FCachePages.Count - 1 do TThemedVirtualListCachePage(FCachePages[I]).Loading := False;
  for I := FCachePages.Count - 1 downto 0 do
    if TThemedVirtualListCachePage(FCachePages[I]).PageIndex = LPageIndex then
    begin
      TObject(FCachePages[I]).Free;
      FCachePages.Delete(I);
      Break;
    end;
end;

procedure TCustomThemedVirtualList.TrimItemCache;
var
  I, LRemoveIndex: Integer;
  LPage: TThemedVirtualListCachePage;
  LTouch: UInt64;
begin
  if FCachePages = nil then Exit;
  while FCachePages.Count > FMaxCachedPages do
  begin
    LRemoveIndex := -1;
    LTouch := High(UInt64);
    for I := 0 to FCachePages.Count - 1 do
    begin
      LPage := TThemedVirtualListCachePage(FCachePages[I]);
      if LPage.Loading then Continue;
      if LPage.Touch < LTouch then
      begin
        LTouch := LPage.Touch;
        LRemoveIndex := I;
      end;
    end;
    if LRemoveIndex < 0 then Exit;
    TObject(FCachePages[LRemoveIndex]).Free;
    FCachePages.Delete(LRemoveIndex);
  end;
end;

function TCustomThemedVirtualList.TryGetCachedItem(const AIndex: Integer; out AItem: TThemedVirtualListItemData): Boolean;
var
  I, LPageIndex, LOffset: Integer;
  LPage: TThemedVirtualListCachePage;
begin
  Result := False;
  if (AIndex < 0) or (AIndex >= FItemCount) or (FPageSize <= 0) or (FCachePages = nil) then Exit;
  LPageIndex := AIndex div FPageSize;
  LOffset := AIndex mod FPageSize;
  for I := 0 to FCachePages.Count - 1 do
  begin
    LPage := TThemedVirtualListCachePage(FCachePages[I]);
    if LPage.PageIndex <> LPageIndex then Continue;
    if (LOffset < 0) or (LOffset >= Length(LPage.Items)) then Exit;
    Inc(FCacheTouch);
    LPage.Touch := FCacheTouch;
    AItem := LPage.Items[LOffset];
    NormalizeItemData(AItem);
    Exit(True);
  end;
end;

procedure TCustomThemedVirtualList.SetCachedPage(const APageIndex: Integer; const AItems: TThemedVirtualListItemDataArray);
var
  I: Integer;
  LPage: TThemedVirtualListCachePage;
begin
  LPage := nil;
  for I := 0 to FCachePages.Count - 1 do
    if TThemedVirtualListCachePage(FCachePages[I]).PageIndex = APageIndex then
    begin
      LPage := TThemedVirtualListCachePage(FCachePages[I]);
      Break;
    end;
  if LPage = nil then
  begin
    LPage := TThemedVirtualListCachePage.Create;
    LPage.PageIndex := APageIndex;
    FCachePages.Add(LPage);
  end;
  LPage.Items := Copy(AItems, 0, Length(AItems));
  LPage.Loading := False;
  LPage.Loaded := True;
  Inc(FCacheTouch);
  LPage.Touch := FCacheTouch;
  TrimItemCache;
  QueueAutoSizeColumns(False);
end;

function TCustomThemedVirtualList.IsPageCachedOrLoading(const APageIndex: Integer): Boolean;
var
  I: Integer;
  LPage: TThemedVirtualListCachePage;
begin
  Result := False;
  if FCachePages = nil then Exit;
  for I := 0 to FCachePages.Count - 1 do
  begin
    LPage := TThemedVirtualListCachePage(FCachePages[I]);
    if LPage.PageIndex = APageIndex then Exit(LPage.Loading or LPage.Loaded);
  end;
end;

procedure TCustomThemedVirtualList.RequestPage(const APageIndex: Integer);
var
  I, LStart, LCount: Integer;
  LGeneration, LToken: Cardinal;
  LPage: TThemedVirtualListCachePage;
  LItems: TThemedVirtualListItemDataArray;
  LCancel: Boolean;
  LRequest: TThemedVirtualListPendingRequest;
begin
  if not HasDataProvider or (FItemCount <= 0) or (FPageSize <= 0) then Exit;
  LStart := APageIndex * FPageSize;
  if (LStart < 0) or (LStart >= FItemCount) then Exit;
  LCount := Min(FPageSize, FItemCount - LStart);
  if LCount <= 0 then Exit;
  LPage := nil;
  for I := 0 to FCachePages.Count - 1 do
    if TThemedVirtualListCachePage(FCachePages[I]).PageIndex = APageIndex then
    begin
      LPage := TThemedVirtualListCachePage(FCachePages[I]);
      Break;
    end;
  if LPage = nil then
  begin
    LPage := TThemedVirtualListCachePage.Create;
    LPage.PageIndex := APageIndex;
    FCachePages.Add(LPage);
  end;
  if LPage.Loading or LPage.Loaded then Exit;
  LPage.Loading := True;
  Inc(FCacheTouch);
  LPage.Touch := FCacheTouch;
  if Assigned(FOnRequestItemsAsync) then
  begin
    Inc(FNextRequestToken);
    if FNextRequestToken = 0 then Inc(FNextRequestToken);
    LToken := FNextRequestToken;
    LGeneration := FCacheGeneration;
    LRequest := TThemedVirtualListPendingRequest.Create;
    LRequest.Token := LToken;
    LRequest.PageIndex := APageIndex;
    LRequest.Generation := LGeneration;
    LRequest.StartIndex := LStart;
    LRequest.Count := LCount;
    FPendingRequests.Add(LRequest);
    try
      FOnRequestItemsAsync(Self, LStart, LCount, LToken);
    except
      for I := FPendingRequests.Count - 1 downto 0 do
        if TThemedVirtualListPendingRequest(FPendingRequests[I]).Token = LToken then
        begin
          TThemedVirtualListPendingRequest(FPendingRequests[I]).Free;
          FPendingRequests.Delete(I);
          Break;
        end;
      if LGeneration = FCacheGeneration then
        for I := 0 to FCachePages.Count - 1 do
          if TThemedVirtualListCachePage(FCachePages[I]).PageIndex = APageIndex then
          begin
            TThemedVirtualListCachePage(FCachePages[I]).Loading := False;
            Break;
          end;
      raise;
    end;
    Exit;
  end;
  SetLength(LItems, LCount);
  for I := 0 to LCount - 1 do InitializeItemData(LItems[I]);
  LCancel := False;
  LGeneration := FCacheGeneration;
  try
    FOnRequestItems(Self, LStart, LCount, LItems, LCancel);
  finally
    if LGeneration = FCacheGeneration then LPage.Loading := False;
  end;
  if LGeneration <> FCacheGeneration then Exit;
  if LCancel then
  begin
    LPage.Loaded := False;
    Exit;
  end;
  for I := 0 to Length(LItems) - 1 do NormalizeItemData(LItems[I]);
  SetCachedPage(APageIndex, LItems);
end;

procedure TCustomThemedVirtualList.CompleteRequest(const ARequestToken: Cardinal; const AItems: TThemedVirtualListItemDataArray; const ACancelled: Boolean);
var
  I, J: Integer;
  LRequest: TThemedVirtualListPendingRequest;
  LPage: TThemedVirtualListCachePage;
  LItems: TThemedVirtualListItemDataArray;
begin
  if (ARequestToken = 0) or (FPendingRequests = nil) then Exit;
  LRequest := nil;
  for I := 0 to FPendingRequests.Count - 1 do
    if TThemedVirtualListPendingRequest(FPendingRequests[I]).Token = ARequestToken then
    begin
      LRequest := TThemedVirtualListPendingRequest(FPendingRequests[I]);
      FPendingRequests.Delete(I);
      Break;
    end;
  if LRequest = nil then Exit;
  try
    if (LRequest.Generation <> FCacheGeneration) or (csDestroying in ComponentState) then Exit;
    LPage := nil;
    for I := 0 to FCachePages.Count - 1 do
      if TThemedVirtualListCachePage(FCachePages[I]).PageIndex = LRequest.PageIndex then
      begin
        LPage := TThemedVirtualListCachePage(FCachePages[I]);
        Break;
      end;
    if LPage = nil then Exit;
    LPage.Loading := False;
    if ACancelled then
    begin
      LPage.Loaded := False;
      Exit;
    end;
    SetLength(LItems, Min(Length(AItems), LRequest.Count));
    for J := 0 to Length(LItems) - 1 do
    begin
      LItems[J] := AItems[J];
      NormalizeItemData(LItems[J]);
    end;
    SetCachedPage(LRequest.PageIndex, LItems);
    Invalidate;
  finally
    LRequest.Free;
  end;
end;

procedure TCustomThemedVirtualList.RequestVisiblePages;
var
  LArea: TRect;
  LStartIndex, LEndIndex, LFirstPage, LLastPage, I: Integer;
  LEndIndex64: Int64;
begin
  FRequestPending := False;
  if not HasDataProvider or (FItemCount <= 0) or (FPageSize <= 0) then Exit;
  LArea := GetItemArea;
  LStartIndex := EnsureRange(FScrollOffset div GetItemHeightPixels, 0, FItemCount - 1);
  LEndIndex64 := Int64(LStartIndex) + Max(1, LArea.Height div GetItemHeightPixels) + 4;
  if LEndIndex64 > FItemCount - 1 then LEndIndex := FItemCount - 1 else LEndIndex := Integer(LEndIndex64);
  LFirstPage := LStartIndex div FPageSize;
  LLastPage := LEndIndex div FPageSize;
  for I := LFirstPage to LLastPage do
    if not IsPageCachedOrLoading(I) then RequestPage(I);
  Invalidate;
end;

procedure TCustomThemedVirtualList.ScheduleRequest;
begin
  if not HasDataProvider or FRequestPending or (csDestroying in ComponentState) or (csLoading in ComponentState) or not HandleAllocated then Exit;
  FRequestPending := True;
  if not PostMessage(Handle, WM_NIMBUS_VIRTUALLIST_REQUEST, 0, 0) then FRequestPending := False;
end;

function TCustomThemedVirtualList.TryGetItemData(const AIndex: Integer; out AItem: TThemedVirtualListItemData): Boolean;
begin
  InitializeItemData(AItem);
  Result := (AIndex >= 0) and (AIndex < FItemCount);
  if not Result then Exit;
  if HasDataProvider then
  begin
    Result := TryGetCachedItem(AIndex, AItem);
    if not Result then ScheduleRequest;
  end
  else if Assigned(FOnGetItem) then
    FOnGetItem(Self, AIndex, AItem);
  NormalizeItemData(AItem);
end;

procedure TCustomThemedVirtualList.GetItemData(const AIndex: Integer; out AItem: TThemedVirtualListItemData);
begin
  TryGetItemData(AIndex, AItem);
end;

function TCustomThemedVirtualList.IsItemEnabled(const AIndex: Integer): Boolean;
var
  LItem: TThemedVirtualListItemData;
begin
  if (AIndex < 0) or (AIndex >= FItemCount) then Exit(False);
  if HasDataProvider then
  begin
    if TryGetCachedItem(AIndex, LItem) then Exit(LItem.Enabled);
    ScheduleRequest;
    Exit(True);
  end;
  GetItemData(AIndex, LItem);
  Result := LItem.Enabled;
end;

function TCustomThemedVirtualList.FindEnabledIndex(const AStart, ADirection: Integer): Integer;
var
  I, LDirection: Integer;
begin
  Result := -1;
  if FItemCount = 0 then Exit;
  if ADirection < 0 then LDirection := -1 else LDirection := 1;
  I := EnsureRange(AStart, 0, FItemCount - 1);
  while (I >= 0) and (I < FItemCount) do
  begin
    if IsItemEnabled(I) then Exit(I);
    Inc(I, LDirection);
  end;
end;

function TCustomThemedVirtualList.GetSelected(AIndex: Integer): Boolean;
begin
  Result := (AIndex >= 0) and (AIndex < FItemCount) and (FSelected[AIndex] <> 0);
end;

function TCustomThemedVirtualList.GetSelectedIndices: TThemedVirtualListIndexArray;
var
  I, LIndex: Integer;
begin
  if FSelectedCount <= 0 then Exit;
  SetLength(Result, FSelectedCount);
  LIndex := 0;
  for I := 0 to FItemCount - 1 do
    if FSelected[I] <> 0 then
    begin
      Result[LIndex] := I;
      Inc(LIndex);
      if LIndex >= Length(Result) then Break;
    end;
  if LIndex <> Length(Result) then SetLength(Result, LIndex);
end;

function TCustomThemedVirtualList.GetSelectedItems: TThemedVirtualListItemDataArray;
var
  I, LIndex: Integer;
  LItem: TThemedVirtualListItemData;
begin
  if FSelectedCount <= 0 then Exit;
  SetLength(Result, FSelectedCount);
  LIndex := 0;
  for I := 0 to FItemCount - 1 do
    if (FSelected[I] <> 0) and TryGetItemData(I, LItem) then
    begin
      Result[LIndex] := LItem;
      Inc(LIndex);
      if LIndex >= Length(Result) then Break;
    end;
  if LIndex <> Length(Result) then SetLength(Result, LIndex);
end;

function TCustomThemedVirtualList.CollectCheckedIndices(const ASelectedOnly: Boolean): TThemedVirtualListIndexArray;
var
  I, LCount: Integer;
begin
  Result := nil;
  if FCheckedStateCount = 0 then Exit;
  LCount := FCheckedStateCount;
  if ASelectedOnly then LCount := Min(LCount, FSelectedCount);
  SetLength(Result, LCount);
  LCount := 0;
  for I := 0 to FItemCount - 1 do
    if GetChecked(I) and (not ASelectedOnly or GetSelected(I)) then
    begin
      Result[LCount] := I;
      Inc(LCount);
    end;
  SetLength(Result, LCount);
end;

function TCustomThemedVirtualList.GetCheckedIndices: TThemedVirtualListIndexArray;
begin
  Result := CollectCheckedIndices(False);
end;

function TCustomThemedVirtualList.GetSelectedCheckedIndices: TThemedVirtualListIndexArray;
begin
  Result := CollectCheckedIndices(True);
end;

function TCustomThemedVirtualList.GetCheckedCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  if FCheckedStateCount = 0 then Exit;
  for I := 0 to FItemCount - 1 do
    if GetChecked(I) then Inc(Result);
end;

function TCustomThemedVirtualList.GetSelectedCheckedCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  if (FCheckedStateCount = 0) or (FSelectedCount = 0) then Exit;
  for I := 0 to FItemCount - 1 do
    if GetChecked(I) and GetSelected(I) then Inc(Result);
end;

function TCustomThemedVirtualList.IsSelected(AIndex: Integer): Boolean;
begin
  Result := GetSelected(AIndex);
end;

function TCustomThemedVirtualList.IsChecked(AIndex: Integer): Boolean;
begin
  Result := GetChecked(AIndex);
end;

function TCustomThemedVirtualList.GetAllChecked: TThemedVirtualListIndexArray;
begin
  Result := GetCheckedIndices;
end;

procedure TCustomThemedVirtualList.ChangeChecks(const ASelectedOnly, AInvert, AValue: Boolean);
var
  I, LCount: Integer;
  LIndices: TThemedVirtualListIndexArray;
begin
  if ASelectedOnly then
  begin
    LIndices := GetSelectedIndices;
    LCount := Length(LIndices);
  end
  else LCount := FItemCount;
  if LCount = 0 then Exit;
  BeginUpdate;
  try
    for I := 0 to LCount - 1 do
      if ASelectedOnly then
        SetChecked(LIndices[I], AValue)
      else if AInvert then
        SetChecked(I, not GetChecked(I))
      else
        SetChecked(I, AValue);
  finally
    EndUpdate;
  end;
end;

procedure TCustomThemedVirtualList.CheckAll;
begin
  ChangeChecks(False, False, True);
end;

procedure TCustomThemedVirtualList.UncheckAll;
begin
  ChangeChecks(False, False, False);
end;

procedure TCustomThemedVirtualList.InvertChecked;
begin
  ChangeChecks(False, True, False);
end;

procedure TCustomThemedVirtualList.CheckSelected;
begin
  ChangeChecks(True, False, True);
end;

procedure TCustomThemedVirtualList.UncheckSelected;
begin
  ChangeChecks(True, False, False);
end;

procedure TCustomThemedVirtualList.SetSelected(AIndex: Integer; const AValue: Boolean);
begin
  if (AIndex < 0) or (AIndex >= FItemCount) then Exit;
  if AValue and not IsItemEnabled(AIndex) then Exit;
  if AValue and not FMultiSelect then
  begin
    SetOnlySelected(AIndex);
    Exit;
  end;
  if GetSelected(AIndex) = AValue then Exit;
  FSelected[AIndex] := Ord(AValue);
  if AValue then Inc(FSelectedCount) else Dec(FSelectedCount);
  if AValue then FCurrentIndex := AIndex else if FCurrentIndex = AIndex then FCurrentIndex := -1;
  InvalidateItem(AIndex);
  DoSelectionChanged;
end;

function TCustomThemedVirtualList.GetCheckState(AIndex: Integer): TThemedVirtualListCheckState;
begin
  if (AIndex < 0) or (AIndex >= FItemCount) then Exit(vlcsUnchecked);
  Result := TThemedVirtualListCheckState(EnsureRange(Integer(FCheckStates[AIndex]), Ord(Low(TThemedVirtualListCheckState)), Ord(High(TThemedVirtualListCheckState))));
end;

procedure TCustomThemedVirtualList.SetCheckState(AIndex: Integer; const AValue: TThemedVirtualListCheckState);
var
  LOldState: TThemedVirtualListCheckState;
begin
  if (AIndex < 0) or (AIndex >= FItemCount) or not IsItemEnabled(AIndex) then Exit;
  if (AValue = vlcsIndeterminate) and not FTriStateCheckBoxes then Exit;
  LOldState := TThemedVirtualListCheckState(FCheckStates[AIndex]);
  if LOldState = AValue then Exit;
  if LOldState = vlcsUnchecked then Inc(FCheckedStateCount);
  if AValue = vlcsUnchecked then Dec(FCheckedStateCount);
  FCheckStates[AIndex] := Ord(AValue);
  InvalidateItem(AIndex);
  if IsTableMode and FShowHeader then Invalidate;
  DoCheckStateChanged(AIndex);
end;

function TCustomThemedVirtualList.GetChecked(AIndex: Integer): Boolean;
begin
  Result := GetCheckState(AIndex) = vlcsChecked;
end;

procedure TCustomThemedVirtualList.SetChecked(AIndex: Integer; const AValue: Boolean);
begin
  if AValue then SetCheckState(AIndex, vlcsChecked) else SetCheckState(AIndex, vlcsUnchecked);
end;

procedure TCustomThemedVirtualList.ClearSelectionInternal;
var
  I: Integer;
begin
  if FSelectedCount = 0 then Exit;
  for I := 0 to FItemCount - 1 do FSelected[I] := 0;
  FSelectedCount := 0;
end;

procedure TCustomThemedVirtualList.SetOnlySelected(const AIndex: Integer);
var
  LChanged: Boolean;
begin
  if (AIndex < 0) or (AIndex >= FItemCount) then Exit;
  LChanged := (FSelectedCount <> 1) or not GetSelected(AIndex) or (FCurrentIndex <> AIndex);
  if not LChanged then Exit;
  ClearSelectionInternal;
  FSelected[AIndex] := 1;
  FSelectedCount := 1;
  FCurrentIndex := AIndex;
  Invalidate;
  DoSelectionChanged;
end;

procedure TCustomThemedVirtualList.ToggleSelected(const AIndex: Integer);
begin
  if (AIndex < 0) or (AIndex >= FItemCount) or not IsItemEnabled(AIndex) then Exit;
  if GetSelected(AIndex) then
  begin
    FSelected[AIndex] := 0;
    Dec(FSelectedCount);
  end
  else
  begin
    if not FMultiSelect then ClearSelectionInternal;
    FSelected[AIndex] := 1;
    Inc(FSelectedCount);
  end;
  FCurrentIndex := AIndex;
  InvalidateItem(AIndex);
  DoSelectionChanged;
end;

procedure TCustomThemedVirtualList.SelectRange(const AFirst, ALast: Integer; const AClearFirst: Boolean);
var
  I, LFirst, LLast, LCurrent: Integer;
  LChanged: Boolean;
begin
  if FItemCount = 0 then Exit;
  LFirst := EnsureRange(Min(AFirst, ALast), 0, FItemCount - 1);
  LLast := EnsureRange(Max(AFirst, ALast), 0, FItemCount - 1);
  LChanged := AClearFirst and (FSelectedCount <> 0);
  if AClearFirst then ClearSelectionInternal;
  for I := LFirst to LLast do
  begin
    if IsItemEnabled(I) and (FSelected[I] = 0) then
    begin
      FSelected[I] := 1;
      Inc(FSelectedCount);
      LChanged := True;
    end;
  end;
  LCurrent := EnsureRange(ALast, 0, FItemCount - 1);
  if not GetSelected(LCurrent) then
  begin
    LCurrent := -1;
    if ALast >= AFirst then
    begin
      for I := LLast downto LFirst do
        if GetSelected(I) then
        begin
          LCurrent := I;
          Break;
        end;
    end
    else
    begin
      for I := LFirst to LLast do
        if GetSelected(I) then
        begin
          LCurrent := I;
          Break;
        end;
    end;
  end;
  if FCurrentIndex <> LCurrent then
  begin
    FCurrentIndex := LCurrent;
    LChanged := True;
  end;
  if not LChanged then Exit;
  Invalidate;
  DoSelectionChanged;
end;

procedure TCustomThemedVirtualList.ClearSelection;
begin
  if (FSelectedCount = 0) and (FCurrentIndex = -1) then Exit;
  ClearSelectionInternal;
  FCurrentIndex := -1;
  FAnchorIndex := -1;
  Invalidate;
  DoSelectionChanged;
end;

procedure TCustomThemedVirtualList.SelectAll;
var
  I, LCurrent: Integer;
  LChanged: Boolean;
begin
  if not FMultiSelect or (FItemCount = 0) then Exit;
  LChanged := False;
  FSelectedCount := 0;
  for I := 0 to FItemCount - 1 do
  begin
    if IsItemEnabled(I) then
    begin
      if FSelected[I] = 0 then LChanged := True;
      FSelected[I] := 1;
      Inc(FSelectedCount);
    end
    else
    begin
      if FSelected[I] <> 0 then LChanged := True;
      FSelected[I] := 0;
    end;
  end;
  LCurrent := FCurrentIndex;
  if (LCurrent < 0) or not IsItemEnabled(LCurrent) then LCurrent := FindEnabledIndex(0, 1);
  if FCurrentIndex <> LCurrent then
  begin
    FCurrentIndex := LCurrent;
    LChanged := True;
  end;
  if (FAnchorIndex < 0) or not IsItemEnabled(FAnchorIndex) then FAnchorIndex := FCurrentIndex;
  if not LChanged then Exit;
  Invalidate;
  DoSelectionChanged;
end;

procedure TCustomThemedVirtualList.InvertSelection;
var
  I, LCurrent: Integer;
begin
  if not FMultiSelect or (FItemCount = 0) then Exit;
  LCurrent := FCurrentIndex;
  FSelectedCount := 0;
  for I := 0 to FItemCount - 1 do
  begin
    if IsItemEnabled(I) then FSelected[I] := 1 - FSelected[I]
    else FSelected[I] := 0;
    if FSelected[I] <> 0 then Inc(FSelectedCount);
  end;
  if not GetSelected(LCurrent) then
  begin
    LCurrent := -1;
    for I := 0 to FItemCount - 1 do
      if GetSelected(I) then
      begin
        LCurrent := I;
        Break;
      end;
  end;
  FCurrentIndex := LCurrent;
  FAnchorIndex := LCurrent;
  Invalidate;
  DoSelectionChanged;
end;

procedure TCustomThemedVirtualList.DoSelectionChanged;
begin
  if Assigned(FOnSelectionChanged) then FOnSelectionChanged(Self);
end;

procedure TCustomThemedVirtualList.DoItemClick(const AIndex: Integer);
begin
  Click;
  if Assigned(FOnItemClick) then FOnItemClick(Self, AIndex);
end;

procedure TCustomThemedVirtualList.DoItemDoubleClick(const AIndex: Integer);
begin
  if Assigned(FOnItemDoubleClick) then FOnItemDoubleClick(Self, AIndex);
end;

procedure TCustomThemedVirtualList.DoItemActivate(const AIndex: Integer);
begin
  if Assigned(FOnItemActivate) then FOnItemActivate(Self, AIndex);
end;

procedure TCustomThemedVirtualList.DoCheckStateChanged(const AIndex: Integer);
begin
  if Assigned(FOnCheckStateChanged) then FOnCheckStateChanged(Self, AIndex, GetCheckState(AIndex));
end;

function TCustomThemedVirtualList.HitTestItem(const AX, AY: Integer): Integer;
var
  LArea, LRect: TRect;
  LItem: TThemedVirtualListItemData;
  LIndex, LTop, LHeight, LBaseHeight: Integer;
  LPosition: Int64;
  LLastGroup, LGroup: string;
  LRowKind: TThemedVirtualListRowKind;
begin
  Result := -1;
  LArea := GetItemArea;
  if not PtInRect(LArea, Point(AX, AY)) or (FItemCount <= 0) then Exit;
  LBaseHeight := GetItemHeightPixels;
  if not IsTableMode then
  begin
    LPosition := Int64(FScrollOffset) + AY - LArea.Top;
    if (LPosition < 0) or (LPosition div LBaseHeight >= FItemCount) then Exit;
    Result := Integer(LPosition div LBaseHeight);
    Exit;
  end;
  LIndex := EnsureRange(FScrollOffset div LBaseHeight, 0, FItemCount - 1);
  LTop := LArea.Top - (FScrollOffset mod LBaseHeight);
  LLastGroup := '';
  while (LIndex < FItemCount) and (LTop < LArea.Bottom) do
  begin
    TryGetItemData(LIndex, LItem);
    if FShowGroupHeaders then
    begin
      LGroup := ResolveGroupText(LIndex, LItem);
      if LGroup <> LLastGroup then
      begin
        LRect := Rect(LArea.Left, LTop, LArea.Right, LTop + GetGroupHeaderHeightPixels);
        if PtInRect(LRect, Point(AX, AY)) then Exit;
        Inc(LTop, GetGroupHeaderHeightPixels);
        LLastGroup := LGroup;
      end;
    end;
    LRowKind := ResolveRowKind(LIndex, LItem);
    if FShowSeparators and (LRowKind = vlrkSeparator) then
    begin
      LRect := Rect(LArea.Left, LTop, LArea.Right, LTop + LBaseHeight);
      if PtInRect(LRect, Point(AX, AY)) then Exit;
      Inc(LTop, LBaseHeight);
      Inc(LIndex);
      Continue;
    end;
    LHeight := ResolveRowHeight(LIndex, LItem);
    LRect := Rect(LArea.Left, LTop, LArea.Right, LTop + LHeight);
    if PtInRect(LRect, Point(AX, AY)) then Exit(LIndex);
    Inc(LTop, LHeight);
    if FShowRowDetails and GetDetailsExpanded(LIndex) then
    begin
      LRect := Rect(LArea.Left, LTop, LArea.Right, LTop + GetDetailsHeightPixels);
      if PtInRect(LRect, Point(AX, AY)) then Exit;
      Inc(LTop, GetDetailsHeightPixels);
    end;
    Inc(LIndex);
  end;
end;

function TCustomThemedVirtualList.BuildRenderContext(const AIndex: Integer; const ABounds: TRect): TThemedVirtualListItemRenderContext;
var
  LItem: TThemedVirtualListItemData;
begin
  Result := Default(TThemedVirtualListItemRenderContext);
  Result.Placeholder := not TryGetItemData(AIndex, LItem);
  Result.Bounds := ABounds;
  Result.ClientWidth := GetItemArea.Width;
  Result.Text := LItem.Text;
  Result.Subtitle := LItem.Subtitle;
  Result.DetailText := LItem.DetailText;
  Result.BadgeText := LItem.BadgeText;
  Result.Font := Font;
  Result.Palette := Palette;
  Result.BackColor := Color;
  Result.ForeColor := Font.Color;
  Result.AccentColor := LItem.AccentColor;
  Result.StatusColor := LItem.StatusColor;
  Result.ProgressValue := LItem.ProgressValue;
  Result.CheckState := Ord(GetCheckState(AIndex));
  Result.Metrics := FMetrics;
  Result.Selected := GetSelected(AIndex);
  Result.Hovered := FHotTrack and (AIndex = FHoverIndex);
  Result.Disabled := not Enabled or not LItem.Enabled;
  Result.Focused := Focused and (AIndex = FCurrentIndex) and not Result.Disabled;
  Result.Pressed := (AIndex = FPressedIndex) and not Result.Disabled;
  Result.ShowCheckBox := FCheckBoxes;
  Result.ShowSubtitle := FShowSubtitles;
  Result.ShowDetail := FShowDetails;
  Result.ShowProgress := FShowProgress and LItem.ShowProgress;
  Result.RoundedSelection := FRoundedSelection;
  Result.AlternatingRow := FAlternatingRows and Odd(AIndex);
  Result.RightToLeft := UseRightToLeftReading;
  if (FImages <> nil) and (LItem.ImageIndex >= 0) and (LItem.ImageIndex < FImages.Count) then
  begin
    FImages.GetBitmap(LItem.ImageIndex, FImageBuffer);
    if not FImageBuffer.Empty then Result.Image := FImageBuffer;
  end;
end;

function TCustomThemedVirtualList.HitTestCheck(const AIndex, AX, AY: Integer): Boolean;
var
  LBounds, LCheckRect: TRect;
  LItem: TThemedVirtualListItemData;
begin
  Result := False;
  if not FCheckBoxes or (AIndex < 0) or (AIndex >= FItemCount) then Exit;
  if IsTableMode then
  begin
    LCheckRect := GetTableCheckRect(AIndex);
    Exit(PtInRect(LCheckRect, Point(AX, AY)));
  end;
  LBounds := GetVisibleRowRect(AIndex);
  if NimbusRectIsEmpty(LBounds) then Exit;
  GetItemData(AIndex, LItem);
  LCheckRect := TThemedVirtualListRenderer.CalculateCheckRect(LBounds, FMetrics, LItem.StatusColor <> clNone, UseRightToLeftReading);
  Result := PtInRect(LCheckRect, Point(AX, AY));
end;

procedure TCustomThemedVirtualList.CreateWnd;
begin
  inherited CreateWnd;
  if FFilterDebounceTimer = nil then
  begin
    FFilterDebounceTimer := TTimer.Create(nil);
    FFilterDebounceTimer.Enabled := False;
    FFilterDebounceTimer.Interval := 250;
    FFilterDebounceTimer.OnTimer := FilterDebounceTimerTimer;
  end;
  FRequestPending := False;
  UpdateFilterEditorTheme;
  UpdateFilterEditorBounds;
  ScheduleRequest;
end;

procedure TCustomThemedVirtualList.DestroyWnd;
begin
  EndCellEdit(False);
  FRequestPending := False;
  if FFilterDebounceTimer <> nil then
  begin
    FFilterDebounceTimer.Enabled := False;
    FFilterDebounceTimer.OnTimer := nil;
    FFilterDebounceTimer.Free;
    FFilterDebounceTimer := nil;
  end;
  inherited DestroyWnd;
end;

procedure TCustomThemedVirtualList.WMRequestItems(var Message: TMessage);
begin
  RequestVisiblePages;
  Message.Result := 0;
end;

procedure TCustomThemedVirtualList.Paint;
var
  LArea, LBounds, LBorder: TRect;
  LIndex, LItemHeight, LTop: Integer;
  LContext: TThemedVirtualListItemRenderContext;
  LLayout: TThemedVirtualListItemLayout;
  LBack, LBorderColor: TThemeColor;
begin
  RenderCanvas.BeginRender(Canvas);
  try
    ApplyAutoSizeColumns;
    LArea := GetItemArea;
    if Palette <> nil then LBack := Palette.InputBackColor else LBack := ColorToThemeColor(Color);
    RenderCanvas.FillRectangle(LBack, ClientRect);
    RenderGlobalSearch;
    RenderFilterRow;
    if IsTableMode then
      RenderTable(LArea)
    else if FItemCount = 0 then
      TThemedVirtualListRenderer.RenderEmpty(RenderCanvas, LArea, FEmptyText, Font, Palette, Color, Font.Color, UseRightToLeftReading)
    else
    begin
      LItemHeight := GetItemHeightPixels;
      LIndex := FScrollOffset div LItemHeight;
      LTop := LArea.Top - (FScrollOffset mod LItemHeight);
      while (LIndex < FItemCount) and (LTop < LArea.Bottom) do
      begin
        LBounds := Rect(LArea.Left, LTop, LArea.Right, LTop + LItemHeight);
        LContext := BuildRenderContext(LIndex, LBounds);
        TThemedVirtualListRenderer.RenderItem(RenderCanvas, LContext, LLayout);
        Inc(LIndex);
        Inc(LTop, LItemHeight);
      end;
    end;
    if IsTableMode then LBorder := ClientRect else LBorder := LArea;
    if Palette <> nil then LBorderColor := Palette.InputBorderColor else LBorderColor := ColorToThemeColor(clBtnShadow);
    if (LBorder.Width > 0) and (LBorder.Height > 0) then RenderCanvas.DrawRectangle(LBorderColor, Rect(LBorder.Left, LBorder.Top, LBorder.Right - 1, LBorder.Bottom - 1), 1.0);
  finally
    RenderCanvas.EndRender;
  end;
end;

procedure TCustomThemedVirtualList.UpdateHover(const AX, AY: Integer);
var
  LIndex, LHeaderColumn: Integer;
begin
  LHeaderColumn := -1;
  if Enabled and IsTableMode and FShowHeader and PtInRect(GetHeaderRect, Point(AX, AY)) then LHeaderColumn := HitTestColumn(AX, AY);
  if FHeaderHoverColumn <> LHeaderColumn then
  begin
    FHeaderHoverColumn := LHeaderColumn;
    if IsTableMode and FShowHeader then Invalidate;
  end;
  if not FHotTrack or not Enabled then LIndex := -1 else LIndex := HitTestItem(AX, AY);
  if FHoverIndex = LIndex then Exit;
  if FHoverIndex >= 0 then InvalidateItem(FHoverIndex);
  FHoverIndex := LIndex;
  if FHoverIndex >= 0 then InvalidateItem(FHoverIndex);
end;

procedure TCustomThemedVirtualList.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LDelta, LLogicalDelta, LTarget, LResize: Integer;
begin
  inherited MouseMove(Shift, X, Y);
  if FResizeColumn >= 0 then
  begin
    LDelta := X - FResizeStartX;
    if UseRightToLeftReading then LDelta := -LDelta;
    LLogicalDelta := MulDiv(LDelta, 96, Max(1, CurrentPPI));
    FColumns[FResizeColumn].Width := FResizeStartWidth + LLogicalDelta;
    Cursor := crHSplit;
    Exit;
  end;
  if FReorderColumn >= 0 then
  begin
    if not FReorderDragging and (Abs(X - FReorderStartX) > ScaleValue(8)) then FReorderDragging := True;
    if FReorderDragging then
    begin
      LTarget := HitTestColumnInsertion(X);
      if FReorderTarget <> LTarget then
      begin
        FReorderTarget := LTarget;
        Invalidate;
      end;
      Exit;
    end;
  end;
  UpdateHover(X, Y);
  LResize := HitTestColumnResize(X, Y);
  if LResize >= 0 then Cursor := crHSplit else Cursor := crDefault;
end;

procedure TCustomThemedVirtualList.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LIndex, LColumn: Integer;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if not Enabled then Exit;
  if (Button = mbLeft) and FShowGlobalSearch and PtInRect(GetGlobalSearchRect, Point(X, Y)) then
  begin
    if (FGlobalFilterBox <> nil) and FGlobalFilterBox.CanFocus then FGlobalFilterBox.SetFocus;
    Exit;
  end;
  if TabStop and CanFocus then SetFocus;
  if (Button = mbLeft) and IsTableMode and FShowHeader and PtInRect(GetHeaderRect, Point(X, Y)) then
  begin
    LColumn := HitTestColumnResize(X, Y);
    if LColumn >= 0 then
    begin
      FResizeColumn := LColumn;
      FResizeStartX := X;
      FResizeStartWidth := FColumns[LColumn].Width;
      MouseCapture := True;
      Exit;
    end;
    LColumn := HitTestColumn(X, Y);
    if LColumn >= 0 then
    begin
      if FAllowColumnReorder then
      begin
        FReorderColumn := LColumn;
        FReorderTarget := LColumn;
        FReorderStartX := X;
        FReorderDragging := False;
        MouseCapture := True;
      end
      else
        ToggleSort(LColumn, ssShift in Shift);
    end;
    Exit;
  end;
  LIndex := HitTestItem(X, Y);
  if Button = mbRight then
  begin
    if (LIndex >= 0) and IsItemEnabled(LIndex) and not GetSelected(LIndex) then
    begin
      FAnchorIndex := LIndex;
      SetOnlySelected(LIndex);
    end;
    Exit;
  end;
  if Button <> mbLeft then Exit;
  FPressedIndex := -1;
  FPressedCheck := False;
  if LIndex < 0 then
  begin
    if not (ssCtrl in Shift) and not (ssShift in Shift) then ClearSelection;
    Exit;
  end;
  if not IsItemEnabled(LIndex) then Exit;
  if FShowRowDetails and PtInRect(GetDetailsGlyphRect(LIndex), Point(X, Y)) then
  begin
    ToggleDetails(LIndex);
    Exit;
  end;
  FPressedIndex := LIndex;
  FPressedCheck := HitTestCheck(LIndex, X, Y);
  MouseCapture := True;
  InvalidateItem(LIndex);
  if FMultiSelect and (ssShift in Shift) then
  begin
    if FAnchorIndex < 0 then FAnchorIndex := LIndex;
    SelectRange(FAnchorIndex, LIndex, not (ssCtrl in Shift));
    Exit;
  end;
  if FMultiSelect and (ssCtrl in Shift) then
  begin
    FAnchorIndex := LIndex;
    ToggleSelected(LIndex);
    Exit;
  end;
  FAnchorIndex := LIndex;
  SetOnlySelected(LIndex);
end;

procedure TCustomThemedVirtualList.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LIndex, LPressed, LReorderColumn, LReorderTarget: Integer;
  LPressedCheck, LReorderDragging: Boolean;
begin
  inherited MouseUp(Button, Shift, X, Y);
  if Button <> mbLeft then Exit;
  if (FResizeColumn >= 0) or (FReorderColumn >= 0) then
  begin
    LReorderColumn := FReorderColumn;
    LReorderTarget := FReorderTarget;
    LReorderDragging := FReorderDragging;
    FResizeColumn := -1;
    FReorderColumn := -1;
    FReorderTarget := -1;
    FReorderDragging := False;
    if MouseCapture then MouseCapture := False;
    if LReorderColumn >= 0 then
    begin
      if LReorderDragging and (LReorderTarget >= 0) and (LReorderTarget < FColumns.Count) then FColumns.Move(LReorderColumn, LReorderTarget)
      else ToggleSort(LReorderColumn, ssShift in Shift);
    end;
    Invalidate;
    Exit;
  end;
  LPressed := FPressedIndex;
  LPressedCheck := FPressedCheck;
  LIndex := HitTestItem(X, Y);
  FPressedIndex := -1;
  FPressedCheck := False;
  InvalidateItem(LPressed);
  if MouseCapture then MouseCapture := False;
  if (LPressed < 0) or (LPressed <> LIndex) or not IsItemEnabled(LIndex) then Exit;
  if LPressedCheck and HitTestCheck(LIndex, X, Y) then
  begin
    case GetCheckState(LIndex) of
      vlcsUnchecked: SetCheckState(LIndex, vlcsChecked);
      vlcsChecked: if FTriStateCheckBoxes then SetCheckState(LIndex, vlcsIndeterminate) else SetCheckState(LIndex, vlcsUnchecked);
      vlcsIndeterminate: SetCheckState(LIndex, vlcsUnchecked);
    end;
    Exit;
  end;
  DoItemClick(LIndex);
end;

procedure TCustomThemedVirtualList.DblClick;
var
  LPoint: TPoint;
  LIndex: Integer;
begin
  inherited DblClick;
  LPoint := ScreenToClient(Mouse.CursorPos);
  LIndex := HitTestItem(LPoint.X, LPoint.Y);
  if (LIndex >= 0) and IsItemEnabled(LIndex) then
  begin
    DoItemDoubleClick(LIndex);
    DoItemActivate(LIndex);
    if (FCurrentIndex = LIndex) and not (csDestroying in ComponentState) then BeginEditFocusedCell;
  end;
end;

procedure TCustomThemedVirtualList.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if FHoverIndex >= 0 then
  begin
    InvalidateItem(FHoverIndex);
    FHoverIndex := -1;
  end;
  if FHeaderHoverColumn >= 0 then
  begin
    FHeaderHoverColumn := -1;
    Invalidate;
  end;
  if (FResizeColumn < 0) and (FReorderColumn < 0) then Cursor := crDefault;
end;

procedure TCustomThemedVirtualList.WMCaptureChanged(var Message: TMessage);
var
  LPressed: Integer;
begin
  LPressed := FPressedIndex;
  inherited;
  FPressedIndex := -1;
  FPressedCheck := False;
  FResizeColumn := -1;
  FReorderColumn := -1;
  FReorderTarget := -1;
  FReorderDragging := False;
  Cursor := crDefault;
  InvalidateItem(LPressed);
  if IsTableMode then Invalidate;
end;

procedure TCustomThemedVirtualList.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  Message.Result := Message.Result or DLGC_WANTARROWS or DLGC_WANTCHARS;
end;

function TCustomThemedVirtualList.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
var
  LSteps: Integer;
  LOffset: Int64;
begin
  LSteps := WheelDelta div WHEEL_DELTA;
  if (LSteps = 0) and (WheelDelta > 0) then LSteps := 1
  else if (LSteps = 0) and (WheelDelta < 0) then LSteps := -1;
  LOffset := Int64(FScrollOffset) - Int64(LSteps) * FWheelScrollItems * GetItemHeightPixels;
  if LOffset < 0 then LOffset := 0 else if LOffset > High(Integer) then LOffset := High(Integer);
  SetScrollOffset(Integer(LOffset));
  Result := True;
end;

procedure TCustomThemedVirtualList.KeyDown(var Key: Word; Shift: TShiftState);
var
  LTarget, LPage: Integer;
  LCtrl, LShift: Boolean;
begin
  inherited KeyDown(Key, Shift);
  if not Enabled or (FItemCount = 0) then Exit;
  LCtrl := ssCtrl in Shift;
  LShift := ssShift in Shift;
  LTarget := FCurrentIndex;
  LPage := Max(1, GetItemArea.Height div GetItemHeightPixels);
  case Key of
    VK_UP:
      if LTarget < 0 then LTarget := FindEnabledIndex(FItemCount - 1, -1) else LTarget := FindEnabledIndex(Max(0, LTarget - 1), -1);
    VK_DOWN:
      if LTarget < 0 then LTarget := FindEnabledIndex(0, 1) else LTarget := FindEnabledIndex(Min(FItemCount - 1, LTarget + 1), 1);
    VK_HOME: LTarget := FindEnabledIndex(0, 1);
    VK_END: LTarget := FindEnabledIndex(FItemCount - 1, -1);
    VK_PRIOR:
      if LTarget < 0 then LTarget := FindEnabledIndex(0, 1) else LTarget := FindEnabledIndex(Max(0, LTarget - LPage), -1);
    VK_NEXT:
      if LTarget < 0 then LTarget := FindEnabledIndex(0, 1) else LTarget := FindEnabledIndex(Min(FItemCount - 1, LTarget + LPage), 1);
    VK_SPACE:
      begin
        if FCurrentIndex >= 0 then
        begin
          if FCheckBoxes then
          begin
            case GetCheckState(FCurrentIndex) of
              vlcsUnchecked: SetCheckState(FCurrentIndex, vlcsChecked);
              vlcsChecked: if FTriStateCheckBoxes then SetCheckState(FCurrentIndex, vlcsIndeterminate) else SetCheckState(FCurrentIndex, vlcsUnchecked);
              vlcsIndeterminate: SetCheckState(FCurrentIndex, vlcsUnchecked);
            end;
          end
          else if FMultiSelect and LCtrl then ToggleSelected(FCurrentIndex);
        end;
        Key := 0;
        Exit;
      end;
    VK_RETURN:
      begin
        if (FCurrentIndex >= 0) and IsItemEnabled(FCurrentIndex) then DoItemActivate(FCurrentIndex);
        Key := 0;
        Exit;
      end;
    VK_F2:
      begin
        BeginEditFocusedCell;
        Key := 0;
        Exit;
      end;
    Ord('A'):
      if LCtrl and FMultiSelect then
      begin
        SelectAll;
        Key := 0;
        Exit;
      end
      else Exit;
    Ord('C'):
      if LCtrl then
      begin
        CopySelectionToClipboard;
        Key := 0;
        Exit;
      end
      else Exit;
  else
    Exit;
  end;
  if LTarget < 0 then Exit;
  MakeVisible(LTarget);
  Key := 0;
  if FMultiSelect and LShift then
  begin
    if FAnchorIndex < 0 then FAnchorIndex := FCurrentIndex;
    if FAnchorIndex < 0 then FAnchorIndex := LTarget;
    SelectRange(FAnchorIndex, LTarget, not LCtrl);
    Exit;
  end;
  if FMultiSelect and LCtrl then
  begin
    FCurrentIndex := LTarget;
    Invalidate;
    Exit;
  end;
  FAnchorIndex := LTarget;
  SetOnlySelected(LTarget);
end;

procedure TCustomThemedVirtualList.MakeVisible(const AIndex: Integer);
var
  LArea: TRect;
  LTop, LBottom, LHeight: Int64;
begin
  if (AIndex < 0) or (AIndex >= FItemCount) then Exit;
  LArea := GetItemArea;
  LHeight := GetItemHeightPixels;
  LTop := Int64(AIndex) * LHeight;
  LBottom := LTop + LHeight;
  if LTop < FScrollOffset then SetScrollOffset(Integer(Min(LTop, High(Integer))))
  else if LBottom > Int64(FScrollOffset) + LArea.Height then SetScrollOffset(Integer(Min(LBottom - LArea.Height, High(Integer))));
end;

procedure TCustomThemedVirtualList.ScrollTo(const AIndex: Integer);
var
  LOffset: Int64;
begin
  if (AIndex < 0) or (AIndex >= FItemCount) then Exit;
  LOffset := Int64(AIndex) * GetItemHeightPixels;
  SetScrollOffset(Integer(Min(LOffset, High(Integer))));
end;

function TCustomThemedVirtualList.GetTopIndex: Integer;
begin
  if FItemCount = 0 then Exit(-1);
  Result := Min(FItemCount - 1, FScrollOffset div GetItemHeightPixels);
end;

procedure TCustomThemedVirtualList.SetTopIndex(const AValue: Integer);
begin
  if FItemCount = 0 then Exit;
  ScrollTo(EnsureRange(AValue, 0, FItemCount - 1));
end;

procedure TCustomThemedVirtualList.BeginEdit;
begin
  BeginEditFocusedCell;
end;

procedure TCustomThemedVirtualList.CancelEdit;
begin
  EndCellEdit(False);
end;

procedure TCustomThemedVirtualList.ToggleDetails(const AIndex: Integer);
var
  LExpanded: Boolean;
begin
  if not FShowRowDetails or (AIndex < 0) or (AIndex >= FItemCount) then Exit;
  LExpanded := not GetDetailsExpanded(AIndex);
  FExpandedDetails[AIndex] := Ord(LExpanded);
  EndCellEdit(False);
  UpdateScrollBar;
  UpdateActiveEditorBounds;
  Invalidate;
  if Assigned(FOnRowDetailsExpandedChanged) then FOnRowDetailsExpandedChanged(Self, AIndex, LExpanded);
end;

procedure TCustomThemedVirtualList.CollapseAllDetails;
var
  I: Integer;
  LChanged: Boolean;
begin
  LChanged := False;
  for I := 0 to Length(FExpandedDetails) - 1 do
    if FExpandedDetails[I] <> 0 then
    begin
      FExpandedDetails[I] := 0;
      LChanged := True;
    end;
  if not LChanged then Exit;
  EndCellEdit(False);
  UpdateScrollBar;
  Invalidate;
end;

function TCustomThemedVirtualList.ItemAtPos(const APoint: TPoint): Integer;
begin
  Result := HitTestItem(APoint.X, APoint.Y);
end;

procedure TCustomThemedVirtualList.InvalidateItem(const AIndex: Integer);
var
  LArea, LRect: TRect;
  LTop: Int64;
begin
  if (AIndex < 0) or (AIndex >= FItemCount) or not HandleAllocated then Exit;
  if IsTableMode and (FShowGroupHeaders or FShowRowDetails or FShowSeparators or Assigned(FOnGetRowHeight)) then
  begin
    Invalidate;
    Exit;
  end;
  LArea := GetItemArea;
  LTop := Int64(AIndex) * GetItemHeightPixels - FScrollOffset + LArea.Top;
  if (LTop >= LArea.Bottom) or (LTop + GetItemHeightPixels <= LArea.Top) then Exit;
  LRect := Rect(LArea.Left, Integer(Max(Int64(LArea.Top), LTop)), LArea.Right, Integer(Min(Int64(LArea.Bottom), LTop + GetItemHeightPixels)));
  InvalidateRect(Handle, @LRect, False);
end;

procedure TCustomThemedVirtualList.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TCustomThemedVirtualList.EndUpdate;
begin
  if FUpdateCount = 0 then Exit;
  Dec(FUpdateCount);
  if FUpdateCount = 0 then
  begin
    UpdateScrollBar;
    ScheduleRequest;
    Invalidate;
  end;
end;

procedure TCustomThemedVirtualList.ScrollToIndex(const AIndex: Integer);
var
  LIndex: Integer;
begin
  if FItemCount <= 0 then Exit;
  LIndex := EnsureRange(AIndex, 0, FItemCount - 1);
  ScrollTo(LIndex);
end;

procedure TCustomThemedVirtualList.RefreshData;
begin
  RefreshItems;
end;

procedure TCustomThemedVirtualList.AutoSizeColumns;
begin
  QueueAutoSizeColumns(True);
end;

procedure TCustomThemedVirtualList.RefreshItems;
begin
  ClearItemCache;
  QueueAutoSizeColumns(True);
  if FUpdateCount > 0 then Exit;
  UpdateScrollBar;
  ScheduleRequest;
  Invalidate;
end;

procedure TCustomThemedVirtualList.RefreshItem(const AIndex: Integer);
begin
  if HasDataProvider then
  begin
    ClearCachedPageForIndex(AIndex);
    ScheduleRequest;
  end;
  QueueAutoSizeColumns(False);
  InvalidateItem(AIndex);
end;

end.

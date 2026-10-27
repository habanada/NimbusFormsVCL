type
  THexDemoMarkerProvider = class(TInterfacedObject, IHexSearchProvider)
  public
    function GetName: string;
    function Search(const ASource: IHexDataSource; const AQuery: THexSearchQuery): TObjectList<THexSearchMatch>;
  end;

  TCodeEditorDemoDiagnostics = class(TInterfacedObject, ICodeDiagnosticProvider)
  public
    function GetDiagnostics(const Source: ICodeVirtualTextSource): TArray<TCodeDiagnostic>;
  end;

  TCodeEditorDemo = class(TThemedPanel)
  private
    FEditor: TThemedCodeEditor;
    FStatus: TThemedIdeStatusBar;
    FEvent: TThemedLabel;
    FSearch, FReplace: TThemedTextBox;
    FLanguage, FEncoding: TThemedComboBox;
    FActions: TActionList;
    FOpen: TOpenDialog;
    FSave: TSaveDialog;
    FBuilding: Boolean;
    FSearchCase, FSearchRegex, FSearchWord: Boolean;
    FWhitespaceBoxes: array[0..3] of TThemedCheckBox;
    FSyncWhitespace: Boolean;
    procedure Build;
    procedure Command(Sender: TObject);
    procedure Changed(Sender: TObject);
    procedure LanguageChanged(Sender: TObject);
    procedure EncodingChanged(Sender: TObject);
    procedure SearchChanged(Sender: TObject);
    procedure EditorKey(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Error(Sender: TObject; const MessageText: string);
    procedure Completion(Sender: TObject; const Position: TCodeDocumentPosition; var Items: TArray<TCodeCompletionItem>);
    procedure Navigate(Sender: TObject; const Word: TCodeEditorWordHitInfo; var Result: TCodeEditorNavigationResult; var Handled: Boolean);
    procedure QuickInfo(Sender: TObject; const Word: TCodeEditorWordHitInfo; var Info: TCodeEditorQuickInfo; var Handled: Boolean);
    procedure Sample(const Delphi: Boolean);
    procedure SampleCurrentLanguage;
    procedure MarkerExamples;
    procedure WhitespaceChanged(Sender: TObject);
    procedure BreakpointChanged(Sender: TObject; const Breakpoint: TCodeBreakpoint; const Change: TCodeBreakpointChange);
    function SearchOptions: TCodeSearchOptions;
  protected
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TLogViewerDemo = class(TThemedPanel)
  private
    FViewer: TThemedLogViewer;
    FTimer: TTimer;
    FStatus: TThemedLabel;
    FBuilding, FFileMode, FCustomColors, FCustomDraw: Boolean;
    FTick: Integer;
    FMonitorPath: string;
    procedure Build;
    procedure AddSamples;
    procedure LogMarkerClick(Sender: TObject; ALine: TNimbusLogLine; const ASourceIndex, AVisibleIndex: Integer);
    procedure Command(Sender: TObject);
    procedure Tick(Sender: TObject);
    procedure Changed(Sender: TObject);
    procedure Error(Sender: TObject; const AMessage: string);
    procedure RowColors(Sender: TObject; const AInfo: TNimbusLogRowInfo; var ABackColor, AForeColor: TThemeColor);
    procedure DrawRow(Sender: TObject; const ACanvas: INimbusRenderCanvas; const AInfo: TNimbusLogRowInfo; var AHandled: Boolean);
  protected
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TNotificationBarDemo = class(TThemedPanel)
  private
    FBar: TThemedIdeNotificationBar;
    FStatus: TThemedLabel;
    FEventLog: TThemedRichEdit;
    FRetry: TAction;
    FBuilding: Boolean;
    procedure Build;
    procedure Populate;
    procedure Command(Sender: TObject);
    procedure Retry(Sender: TObject);
    procedure Dismissed(Sender: TObject; const AID: string; const AReason: TNimbusNotificationDismissReason);
    procedure ActionClicked(Sender: TObject; AMessage: TThemedIdeNotificationMessage; AAction: TThemedIdeNotificationAction);
    procedure LinkClicked(Sender: TObject; const AID, AURL: string);
    procedure Navigation(Sender: TObject; const AID: string; const AIndex, ACount: Integer);
    procedure Closing(Sender: TObject; AMessage: TThemedIdeNotificationMessage;
      const AReason: TNimbusNotificationDismissReason; var AAllow: Boolean);
    procedure Expired(Sender: TObject; const AID: string; const AReason: TNimbusNotificationDismissReason);
    procedure LogEvent(const AText: string);
  protected
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TAdvancedHexDemo = class(TThemedPanel)
  private
    FEditor: TThemedHexEditor;
    FInspector: TThemedHexInspector;
    FBookmarks: TThemedHexBookmarkList;
    FActions: TActionList;
    FQuery: TThemedTextBox;
    FSearchMode: TThemedComboBox;
    FEncoding: TThemedComboBox;
    FProviders: TThemedComboBox;
    FStatus: TThemedLabel;
    FFileLabel: TThemedLabel;
    FResults: TThemedLabel;
    FFileName: string;
    FBuilding: Boolean;
    FSaveDialog: TSaveDialog;
    FOpenDialog: TOpenDialog;
    function NewAction(const ACaption: string; const ACommand: Integer; const AShortcut: TShortCut = 0): TAction;
    function Prompt(const ACaption: string; var AValue: string): Boolean;
    function ChooseSave(const AFilter: string; out APath: string): Boolean;
    function ChooseOpen(const AFilter: string; out APath: string): Boolean;
    procedure BuildControls;
    procedure NewSample;
    procedure CommandExecute(Sender: TObject);
    procedure CommandUpdate(Sender: TObject);
    procedure EditorChanged(Sender: TObject);
    procedure BookmarksChanged(Sender: TObject);
    procedure QueryEnter(Sender: TObject);
    procedure EncodingChanged(Sender: TObject);
    procedure WorkspaceKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure RequestGoto(Sender: TObject);
    procedure RequestSearch(Sender: TObject);
    procedure RequestReplace(Sender: TObject);
    procedure RequestNext(Sender: TObject);
    procedure RequestPrevious(Sender: TObject);
    procedure BookmarkActivate(Sender: TObject; const AOffset: Int64);
    procedure BookmarkRemove(Sender: TObject; const AOffset: Int64);
    procedure SaveDocument;
  protected
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
    function ConfirmChanges: Boolean;
  end;

  TAdvancedHexForm = class(TForm, IThemeAware)
  private
    FWorkspace: TAdvancedHexDemo;
    procedure WorkspaceCloseQuery(Sender: TObject; var CanClose: Boolean);
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette);
  end;

  TInteractiveGridDemoRow = class
  public
    PersonName: string;
    Approved: Boolean;
    Active: Boolean;
    Rating: Double;
    Status: string;
    Deadline: TDateTime;
  end;

  TInteractiveGridDemo = class(TThemedPanel)
  private
    FGrid: TThemedGridView;
    FRows: TObjectList<TInteractiveGridDemoRow>;
    FChoices: TStringList;
    FEditors: TList<TNimbusGridControlEditor>;
    FStatus: TThemedLabel;
    FReadOnly: TThemedCheckBox;
    FRatingReadOnly: TThemedCheckBox;
    function FindEditor(Sender: TObject): TNimbusGridControlEditor;
    procedure ConfigureEditor(Sender: TObject; const AControl: TWinControl; const AContext: TThemedGridCellEditContext);
    procedure NativeChanged(Sender: TObject);
    procedure NativeAction(Sender: TObject);
    procedure ComboClosed(Sender: TObject);
    procedure ReadOnlyChanged(Sender: TObject);
    procedure RatingReadOnlyChanged(Sender: TObject);
    procedure UndoClick(Sender: TObject);
    procedure RedoClick(Sender: TObject);
    procedure CellChanged(Sender: TObject; const AArgs: TThemedGridCellValueChangedEventArgs);
    procedure ValidateCell(Sender: TObject; const AArgs: TThemedGridCellValidatingEventArgs);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TMainForm = class(TForm)
  private
    FThemeName: string;
    FHeader: TThemedPanel;
    FControlsPanel: TThemedPanel;
    FHexPanel: TThemedPanel;
    FTitleLabel: TThemedLabel;
    FThemeLabel: TThemedLabel;
    FCompactSwitch: TThemedCheckBox;
    FControlsLabel: TThemedLabel;
    FRichEditLabel: TThemedLabel;
    FStatusLabel: TThemedLabel;
    FIdeRangeStatus: TThemedLabel;
    FIdeRangeValidationStatus: TThemedLabel;
    FIdeRangeHoverStatus: TThemedLabel;
    FIdeRangePreviewStatus: TThemedLabel;
    FIdeColorStatus: TThemedLabel;
    FHexStatusLabel: TThemedLabel;
    FStyledLabelStatus: TThemedLabel;
    FHintLabel: TThemedLabel;
    FNextThemeButton: TThemedSplitButton;
    FLightButton: TThemedButton;
    FDarkButton: TThemedButton;
    FProgressButton: TThemedButton;
    FToolButtonStatus: TThemedLabel;
    FToolBarStatus: TThemedLabel;
    FMenuBarStatus: TThemedLabel;
    FIdeStatusBar: TThemedIdeStatusBar;
    FStepDemo: TThemedStepIndicator;
    FStepDemoInfo: TThemedLabel;
    FMenuBarDemoPanel: TThemedPanel;
    FMenuBarDemoControl: TThemedMenuBar;
    FMenuBarWidthSlider: TThemedTrackBar;
    FMenuBarWidthLabel: TThemedLabel;
    FCheckBox: TThemedCheckBox;
    FToggleBox: TThemedToggleBox;
    FRadioOne: TThemedRadioButton;
    FRadioTwo: TThemedRadioButton;
    FProgressBar: TThemedProgressBar;
    FNextGroup: TThemedGroupBox;
    FComboBox: TThemedComboBox;
    FListBoxLabel: TThemedLabel;
    FListBox: TThemedListBox;
    FTrackBar: TThemedTrackBar;
    FSeparator: TThemedSeparator;
    FTextBox: TThemedTextBox;
    FNumericUpDown: TThemedNumericUpDown;
    FRangeTrackBar: TThemedRangeTrackBar;
    FHScrollBar: TThemedHScrollBar;
    FVScrollBar: TThemedVScrollBar;
    FDropdown: TThemedDropdown;
    FRating: TThemedRatingControl;
    FTabLabel: TThemedLabel;
    FTabControl: TThemedTabControl;
    FIDEScrollStatus: TThemedLabel;
    FTreeFilter: TThemedTextBox;
    FTreeView: TThemedTreeView;
    FVirtualList: TThemedVirtualList;
    FVirtualListFilterText: string;
    FVirtualListFilteredIndices: array of Integer;
    FVirtualListEditedRow: Integer;
    FVirtualListEditedProvider: string;
    FDatePicker: TThemedDatePicker;
    FDateTimePicker: TThemedDatePicker;
    FCultureDatePicker: TThemedDatePicker;
    FManualDatePicker: TThemedDatePicker;
    FTreePopupMenu: TThemedPopupMenu;
    FTreeLazyNode: TTreeNode;
    FTreeLazyLoaded: Boolean;
    FRichEdit: TThemedRichEdit;
    FPopupMenu: TThemedPopupMenu;
    FToolTip: TThemedToolTip;
    FHexEditor: TThemedHexEditor;
    procedure HexWorkspaceCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure IdeRangeValidationChanged(Sender: TObject);
    procedure IdeRangeHitChanged(Sender: TObject;
      const AHit: TIdeDateRangeHitInfo);
    procedure IdeRangeHoverHint(Sender: TObject; const ADate: TDateTime;
      var AText: string; var AShow: Boolean);
    procedure IdeRangeDaySelecting(Sender: TObject; const ADate: TDateTime;
      var AAllow: Boolean);
    procedure IdeRangeDayContext(Sender: TObject; const ADate: TDateTime;
      const AScreenPoint: TPoint; var AHandled: Boolean);
    procedure IdeRangeApplied(Sender: TObject);
    procedure IdeRangeCanceled(Sender: TObject);
    procedure IdeRangeCleared(Sender: TObject);
    procedure IdeRangeDayClick(Sender: TObject; const ADate: TDateTime);
    procedure IdeRangeDayEnter(Sender: TObject; const ADate: TDateTime);
    procedure IdeRangeDayLeave(Sender: TObject; const ADate: TDateTime);
    procedure IdeRangePreview(Sender: TObject; const AStart, AEnd: TDateTime);
    procedure IdeRangePopupOpened(Sender: TObject);
    procedure IdeRangePopupClosed(Sender: TObject);
    procedure IdeRangeMonthChanged(Sender: TObject; const AFirstMonth: TDateTime);
    procedure IdeRangeDayDecoration(Sender: TObject; const ADate: TDateTime;
      var ADisabled, AHighlighted: Boolean; var ABadgeText: string);
    procedure IdeRangeDayRender(Sender: TObject;
      const AInfo: TIdeDateRangeDayRenderInfo; var AText: string;
      var ABackColor, ATextColor, ABorderColor: TThemeColor;
      var AUseBackground, AUseTextColor, AUseBorder: Boolean);
    function P(const AValue: Integer): Integer;
    function LoadDemoIcons(const AImages: TImageList): Integer;
    function MenuDemoImageIndex(const AImages: TCustomImageList; const AIndex: Integer): Integer;
    procedure AddPopupItem(const ACaption: string; const ATag: Integer);
    procedure AddTreePopupItem(const ACaption: string; const ATag: Integer);
    procedure AddMenuBarPopupItem(const AMenu: TThemedPopupMenu; const ACaption: string; const ATag: Integer);
    procedure BuildPopupMenu;
    procedure BuildTreePopupMenu;
    procedure BuildHeader;
    procedure CompactModeChanged(Sender: TObject);
    procedure ApplyDemoStyleMode(const AMode: TThemedControlStyleMode);
    procedure BuildStandardControls;
    procedure BuildHexEditor;
    procedure BuildIdeStatusBar;
    procedure IdeStatusItemClick(Sender: TObject; AItem: TThemedIdeStatusBarItem);
    procedure StepDemoButtonClick(Sender: TObject);
    procedure StepDemoChanging(Sender: TObject; AOldIndex, ANewIndex: Integer; var AAllow: Boolean);
    procedure StepDemoChanged(Sender: TObject; AOldIndex, ANewIndex: Integer);
    procedure StepDemoClick(Sender: TObject; AIndex: Integer);
    procedure StepDemoStatusChanged(Sender: TObject; AIndex: Integer; AOldStatus, ANewStatus: TThemedStepStatus);
    function AddTabPage(const ACaption, AText: string): TTabSheet;
    procedure LoadHexSample;
    procedure ApplyThemeName(const AName: string);
    procedure NextThemeClick(Sender: TObject);
    procedure LightThemeClick(Sender: TObject);
    procedure DarkThemeClick(Sender: TObject);
    procedure ProgressClick(Sender: TObject);
    procedure CheckChanged(Sender: TObject);
    procedure ToggleChanged(Sender: TObject);
    procedure RadioChanged(Sender: TObject);
    procedure ListBoxChanged(Sender: TObject);
    procedure StyledLabelLinkClick(Sender: TObject; const ATarget: string);
    procedure ToolButtonClick(Sender: TObject);
    procedure ToolButtonCheckedChanged(Sender: TObject);
    procedure ToolButtonDropDownClick(Sender: TObject; const APart: TThemedToolButtonPart);
    procedure ToolBarButtonClick(Sender: TObject);
    procedure ToolBarEmbeddedChange(Sender: TObject);
    procedure MenuBarItemClick(Sender: TObject; AItem: TThemedMenuBarItem);
    procedure MenuBarMenuOpening(Sender: TObject; AItem: TThemedMenuBarItem);
    procedure MenuBarTextChanged(Sender: TObject; AItem: TThemedMenuBarItem; const AOldText, ANewText: string);
    procedure MenuBarSelectedIndexChanged(Sender: TObject; AItem: TThemedMenuBarItem; const ASelectedIndex: Integer);
    procedure MenuBarPopupItemClick(Sender: TObject);
    procedure MenuBarWidthChanged(Sender: TObject);
    procedure MenuBarDemoResized(Sender: TObject);
    procedure BuildVirtualListItem(const AIndex: Integer; out AItem: TThemedVirtualListItemData);
    function VirtualListSourceIndex(const ARowIndex: Integer): Integer;
    procedure VirtualListGetItem(Sender: TObject; AIndex: Integer; var AItem: TThemedVirtualListItemData);
    procedure VirtualListRequestItems(Sender: TObject; AStartIndex, ACount: Integer; var AItems: TThemedVirtualListItemDataArray; var ACancel: Boolean);
    procedure VirtualListGetCellText(Sender: TObject; ARowIndex: Integer; AColumn: TThemedVirtualListColumn; var AText: string);
    procedure VirtualListSortRequested(Sender: TObject; AColumn: TThemedVirtualListColumn; ADirection: TThemedVirtualListSortDirection; AMultiColumn: Boolean);
    procedure VirtualListFilterRequested(Sender: TObject; const AFilterText: string; var AItemCount: Integer);
    procedure VirtualListCellValidating(Sender: TObject; ARowIndex: Integer; AColumn: TThemedVirtualListColumn; const AOldValue: string; var ANewValue: string; var ACancel: Boolean);
    procedure VirtualListCellEditCommitted(Sender: TObject; ARowIndex: Integer; AColumn: TThemedVirtualListColumn; const AOldValue, ANewValue: string);
    procedure VirtualListGetRowHeight(Sender: TObject; ARowIndex: Integer; const AItem: TThemedVirtualListItemData; var AHeight: Integer);
    procedure VirtualListGetRowKind(Sender: TObject; ARowIndex: Integer; const AItem: TThemedVirtualListItemData; var ARowKind: TThemedVirtualListRowKind);
    procedure VirtualListGetGroupText(Sender: TObject; ARowIndex: Integer; const AItem: TThemedVirtualListItemData; var AText: string);
    procedure VirtualListRowDetailsExpandedChanged(Sender: TObject; ARowIndex: Integer; AExpanded: Boolean);
    procedure VirtualListSelectionChanged(Sender: TObject);
    procedure VirtualListItemActivate(Sender: TObject; AIndex: Integer);
    procedure VirtualListCheckChanged(Sender: TObject; AIndex: Integer; AState: TThemedVirtualListCheckState);
    procedure TrackBarChanged(Sender: TObject);
    procedure ScrollBarChanged(Sender: TObject);
    procedure BuildIDEScrollBarDemo;
    procedure IDEScrollMarkerClick(Sender: TObject; AMarker: TThemedIDEScrollBarMarker; AFirst, ALast: Integer);
    procedure IDEScrollMarkerEnter(Sender: TObject; AMarker: TThemedIDEScrollBarMarker; AFirst, ALast: Integer);
    procedure IDEScrollValueChanged(Sender: TObject);
    procedure DropdownChanged(Sender: TObject);
    procedure RatingChanged(Sender: TObject);
    procedure TabChanged(Sender: TObject);
    procedure TabClosed(Sender: TObject; ATabIndex: Integer; ATabPage: TTabSheet; AReason: TThemedTabCloseReason);
    procedure TabReordered(Sender: TObject; ATabPage: TTabSheet; AOldIndex, ANewIndex: Integer);
    procedure TreeFilterChanged(Sender: TObject);
    procedure TreeNodeClicked(Sender: TObject; ANode: TTreeNode; const ALocation: TPoint; AButton: TMouseButton; AClicks: Integer);
    procedure TreeNodeCheckChanged(Sender: TObject; ANode: TTreeNode; AOldState, ANewState: TThemedTreeCheckState);
    procedure TreeNodeRenamed(Sender: TObject; ANode: TTreeNode; const AOldText: string; var ANewText: string; var ACancel: Boolean);
    procedure TreeNodeDropped(Sender: TObject; ANode, ATargetNode, AOldParent, ANewParent: TTreeNode; AOldIndex, ANewIndex: Integer; ADropPosition: TThemedTreeDropPosition);
    procedure TreeNodeLazyLoad(Sender: TObject; ANode: TTreeNode);
    procedure IdeColorChanged(Sender: TObject; AOldColor, ANewColor: TColor);
    procedure IdeColorSelected(Sender: TObject; AColor: TColor; const ASource: string);
    procedure DatePickerChanged(Sender: TObject);
    procedure DatePickerSelected(Sender: TObject);
    procedure DatePickerDropDownOpened(Sender: TObject);
    procedure DatePickerDropDownClosed(Sender: TObject);
    procedure TextBoxEnterPressed(Sender: TObject);
    procedure TextBoxClearClicked(Sender: TObject);
    procedure HexCursorChanged(Sender: TObject);
    procedure PopupItemClick(Sender: TObject);
    procedure TreePopupItemClick(Sender: TObject);
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
  end;


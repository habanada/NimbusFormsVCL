unit NimbusForms.Controls.FinancialBusinessChart;

interface

uses Winapi.Windows, Winapi.Messages, System.Classes, System.SysUtils, System.Types, System.Math, System.UITypes,
  System.Generics.Collections, Data.DB, Vcl.Controls, Vcl.Graphics, Vcl.Menus,
  NimbusForms.Controls.MiniCharts, NimbusForms.Controls.Chart, NimbusForms.Controls.VScrollBar,
  NimbusForms.Controls.ToolTip, NimbusForms.Menus.PopupMenu, NimbusForms.Rendering.Charts,
  NimbusForms.Charts.Financial.Types, NimbusForms.Charts.Financial.Business.Types,
  NimbusForms.Charts.Financial.Workspace, NimbusForms.Charts.Financial.Palette,
  NimbusForms.Charts.Financial.Data, NimbusForms.Charts.Financial.Viewport,
  NimbusForms.Theming.Palette, NimbusForms.Rendering.FinancialBusiness;

type
  TNimbusFinancialCandleEvent = procedure(Sender: TObject; const Index: Integer; Candle: TNimbusFinancialDataPoint) of object;
  TNimbusFinancialPanelEvent = procedure(Sender: TObject; Panel: TNimbusFinancialPanel) of object;
  TNimbusFinancialHitEvent = procedure(Sender: TObject; const Hit: TNimbusChartHit) of object;
  TNimbusFinancialDataEvent = procedure(Sender: TObject; Result: TNimbusFinancialDataImportResult) of object;
  TNimbusFinancialErrorEvent = procedure(Sender: TObject; const Message: string) of object;
  TNimbusFinancialDragMode = (nfdmNone, nfdmPan, nfdmPanelResize, nfdmPanelMove, nfdmSideResize, nfdmSideHeight, nfdmAnnotation, nfdmRange);
  TNimbusFinancialPanelResizeState = record
    PanelIndex, Height: Integer;
    Key: string;
  end;
  TThemedFinancialBusinessChart = class(TThemedFinancialChart)
  private
    FFinancial: TNimbusFinancialWorkspace;
    FCsvOptions: TNimbusFinancialCsvImportOptions;
    FDataLink: TDataLink;
    FThemeMode: TNimbusFinancialThemeMode;
    FThemePreset: TNimbusFinancialThemePreset;
    FToolTip: TThemedToolTip;
    FPanelMenu: TThemedPopupMenu;
    FScrollBars: TObjectList<TThemedVScrollBar>;
    FLoading, FUpdating, FClosing, FSyncingBars, FRefreshing: Boolean;
    FLastLoadedFileName, FProfilePath, FLastError: string;
    FUpdateCount: Integer;
    FLayoutPreset: TNimbusFinancialPanelLayoutPreset;
    FAutoRestore, FAutoSave, FProfileRestored, FHighContrastActive: Boolean;
    FPressedHit: TNimbusChartHit;
    FDragMode: TNimbusFinancialDragMode;
    FMouseOrigin: TPoint;
    FStartFirst, FStartWidth, FNextPanel, FMoveTarget, FRangeAnchor: Integer;
    FStartWeight, FNextWeight, FStartHeight, FNextHeight: Double;
    FAnnotationStart, FAnnotationEnd: Double;
    FAnnotationFirst, FAnnotationLast: Integer;
    FDragMoved: Boolean;
    FHandlingMouseUp: Boolean;
    FResizePanels: TArray<TNimbusFinancialPanelResizeState>;
    FContextPanel: Integer;
    FOnCandleHovered, FOnCandleClicked: TNimbusFinancialCandleEvent;
    FOnViewportChanged, FOnRangeChanged, FOnCrosshairChanged, FOnSelectionCleared: TNotifyEvent;
    FOnPanelCollapsed, FOnPanelExpanded, FOnPanelClosed, FOnPanelResized, FOnPanelMoved, FOnPanelPinned, FOnPanelUnpinned, FOnPanelSettingsRequested: TNimbusFinancialPanelEvent;
    FOnMarkerClicked, FOnAnnotationClicked, FOnIndicatorClicked, FOnSidePanelItemClicked: TNimbusFinancialHitEvent;
    FOnDataLoaded: TNimbusFinancialDataEvent;
    FOnDataLoadFailed, FOnProfileLoadFailed: TNimbusFinancialErrorEvent;
    FOnRowClicked, FOnRowDoubleClicked, FOnRowHovered, FOnRowContextMenu: TNimbusFinancialRowEvent;
    FOnPanelAction: TNimbusFinancialPanelActionEvent;
    FRowFocusPanel, FRowFocusKey, FHoverRowPanel, FHoverRowKey: string;
    FRowFocusPanelIndex, FRowFocusIndex, FHoverRowPanelIndex, FHoverRowIndex: Integer;
    FPointerLocation: TPoint;
    FPointerShift: TShiftState;
    function GetFinancialTitle: string;
    procedure SetFinancialTitle(const Value: string);
    function GetFinancialSubtitle: string;
    procedure SetFinancialSubtitle(const Value: string);
    function GetShowRangeSelector: Boolean;
    procedure SetShowRangeSelector(const Value: Boolean);
    function GetThemePresetDisplayName: string;
    function GetPanelLayout: TNimbusFinancialScene;
    function GetIsUpdating: Boolean;
    procedure FinancialChanged(Sender: TObject);
    procedure SyncPalette;
    procedure SyncScrollBars;
    procedure ScrollBarChanged(Sender: TObject);
    procedure ScrollSidePanel(const PanelIndex, Offset: Integer);
    function DispatchRowEvent(const Hit: TNimbusChartHit; const Action: TNimbusFinancialRowAction;
      const Origin: TNimbusFinancialInputOrigin; const Button: TMouseButton; const Shift: TShiftState): Boolean;
    procedure NotifyPanelAction(const Action: TNimbusFinancialPanelAction; const PanelIndex: Integer; const IsSidePanel: Boolean);
    procedure FocusSideRow(Panel: TNimbusFinancialSidePanel; Item: TNimbusFinancialPanelItem);
    function NavigateSideRow(var Key: Word; const Shift: TShiftState): Boolean;
    procedure ReloadDataSource;
    function GetDataSource: TDataSource;
    function GetCandles: TNimbusFinancialDataPointCollection;
    procedure SetDataSource(const Value: TDataSource);
    procedure SetFinancial(const Value: TNimbusFinancialWorkspace);
    procedure SetCsvOptions(const Value: TNimbusFinancialCsvImportOptions);
    procedure SetThemeMode(const Value: TNimbusFinancialThemeMode);
    procedure SetThemePreset(const Value: TNimbusFinancialThemePreset);
    procedure CancelFinancialDrag;
    function BeginPanelResize(const Scene: TNimbusFinancialScene; const PanelIndex: Integer): Boolean;
    procedure ResizePanels(const Delta: Integer);
    procedure UpdateAccessibility;
    procedure InvokeHit(const Hit: TNimbusChartHit; const Shift: TShiftState);
    procedure ContextCommand(Sender: TObject);
    procedure ShowPanelMenu(const Hit: TNimbusChartHit; const Location: TPoint);
    procedure RestoreProfile;
    procedure SetProfilePath(const Value: string);
    procedure SetAutoRestore(const Value: Boolean);
    function GetProfilePath: string;
    procedure WMCaptureChanged(var Message: TMessage); message WM_CAPTURECHANGED;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    function GetFinancialSymbol: string;
    procedure SetFinancialSymbol(const Value: string);
    function GetFinancialExchange: string;
    procedure SetFinancialExchange(const Value: string);
    function GetFinancialTimeFrame: TNimbusFinancialTimeFrame;
    procedure SetFinancialTimeFrame(const Value: TNimbusFinancialTimeFrame);
    function GetFinancialPriceMode: TNimbusFinancialPriceMode;
    procedure SetFinancialPriceMode(const Value: TNimbusFinancialPriceMode);
    function GetFinancialShowVolume: Boolean;
    procedure SetFinancialShowVolume(const Value: Boolean);
    function GetFinancialShowVolumeMovingAverage: Boolean;
    procedure SetFinancialShowVolumeMovingAverage(const Value: Boolean);
    function GetFinancialVolumeMovingAveragePeriod: Integer;
    procedure SetFinancialVolumeMovingAveragePeriod(const Value: Integer);
    function GetFinancialShowSimpleMovingAverage: Boolean;
    procedure SetFinancialShowSimpleMovingAverage(const Value: Boolean);
    function GetFinancialShowExponentialMovingAverage: Boolean;
    procedure SetFinancialShowExponentialMovingAverage(const Value: Boolean);
    function GetFinancialSimpleMovingAveragePeriods: string;
    procedure SetFinancialSimpleMovingAveragePeriods(const Value: string);
    function GetFinancialExponentialMovingAveragePeriods: string;
    procedure SetFinancialExponentialMovingAveragePeriods(const Value: string);
    function GetFinancialShowBollingerBands: Boolean;
    procedure SetFinancialShowBollingerBands(const Value: Boolean);
    function GetFinancialBollingerBandPeriods: string;
    procedure SetFinancialBollingerBandPeriods(const Value: string);
    function GetFinancialBollingerBandStandardDeviation: Double;
    procedure SetFinancialBollingerBandStandardDeviation(const Value: Double);
    function GetFinancialShowRsi: Boolean;
    procedure SetFinancialShowRsi(const Value: Boolean);
    function GetFinancialRsiPeriods: string;
    procedure SetFinancialRsiPeriods(const Value: string);
    function GetFinancialRsiOversoldLevel: Double;
    procedure SetFinancialRsiOversoldLevel(const Value: Double);
    function GetFinancialRsiOverboughtLevel: Double;
    procedure SetFinancialRsiOverboughtLevel(const Value: Double);
    function GetFinancialShowMacd: Boolean;
    procedure SetFinancialShowMacd(const Value: Boolean);
    function GetFinancialMacdFastPeriod: Integer;
    procedure SetFinancialMacdFastPeriod(const Value: Integer);
    function GetFinancialMacdSlowPeriod: Integer;
    procedure SetFinancialMacdSlowPeriod(const Value: Integer);
    function GetFinancialMacdSignalPeriod: Integer;
    procedure SetFinancialMacdSignalPeriod(const Value: Integer);
    function GetFinancialShowStochastic: Boolean;
    procedure SetFinancialShowStochastic(const Value: Boolean);
    function GetFinancialStochasticPeriod: Integer;
    procedure SetFinancialStochasticPeriod(const Value: Integer);
    function GetFinancialStochasticSmoothKPeriod: Integer;
    procedure SetFinancialStochasticSmoothKPeriod(const Value: Integer);
    function GetFinancialStochasticDPeriod: Integer;
    procedure SetFinancialStochasticDPeriod(const Value: Integer);
    function GetFinancialStochasticOversoldLevel: Double;
    procedure SetFinancialStochasticOversoldLevel(const Value: Double);
    function GetFinancialStochasticOverboughtLevel: Double;
    procedure SetFinancialStochasticOverboughtLevel(const Value: Double);
    function GetFinancialShowAtr: Boolean;
    procedure SetFinancialShowAtr(const Value: Boolean);
    function GetFinancialAtrPeriods: string;
    procedure SetFinancialAtrPeriods(const Value: string);
    function GetFinancialShowVwap: Boolean;
    procedure SetFinancialShowVwap(const Value: Boolean);
    function GetFinancialVwapResetBySession: Boolean;
    procedure SetFinancialVwapResetBySession(const Value: Boolean);
    function GetFinancialShowCrosshair: Boolean;
    procedure SetFinancialShowCrosshair(const Value: Boolean);
    function GetFinancialShowLegend: Boolean;
    procedure SetFinancialShowLegend(const Value: Boolean);
    function GetFinancialShowGrid: Boolean;
    procedure SetFinancialShowGrid(const Value: Boolean);
    function GetFinancialShowAxes: Boolean;
    procedure SetFinancialShowAxes(const Value: Boolean);
    function GetFinancialShowAnnotations: Boolean;
    procedure SetFinancialShowAnnotations(const Value: Boolean);
    function GetFinancialShowToolTips: Boolean;
    procedure SetFinancialShowToolTips(const Value: Boolean);
    function GetFinancialLockDetailsOnSelection: Boolean;
    procedure SetFinancialLockDetailsOnSelection(const Value: Boolean);
    function GetFinancialClearSelectionOnEmptyPlotClick: Boolean;
    procedure SetFinancialClearSelectionOnEmptyPlotClick(const Value: Boolean);
    function GetFinancialClearSelectionOnEscape: Boolean;
    procedure SetFinancialClearSelectionOnEscape(const Value: Boolean);
    function GetFinancialShowCrosshairWhileSelectionLocked: Boolean;
    procedure SetFinancialShowCrosshairWhileSelectionLocked(const Value: Boolean);
    function GetFinancialShowDashboardPanels: Boolean;
    procedure SetFinancialShowDashboardPanels(const Value: Boolean);
    function GetFinancialAutoBuildProductiveSidePanels: Boolean;
    procedure SetFinancialAutoBuildProductiveSidePanels(const Value: Boolean);
    function GetFinancialSidePanelLayoutMode: TNimbusFinancialSidePanelLayoutMode;
    procedure SetFinancialSidePanelLayoutMode(const Value: TNimbusFinancialSidePanelLayoutMode);
    function GetFinancialLeftSidePanelAreaWidth: Integer;
    procedure SetFinancialLeftSidePanelAreaWidth(const Value: Integer);
    function GetFinancialRightSidePanelAreaWidth: Integer;
    procedure SetFinancialRightSidePanelAreaWidth(const Value: Integer);
    function GetFinancialAllowPanelLayoutChanges: Boolean;
    procedure SetFinancialAllowPanelLayoutChanges(const Value: Boolean);
    function GetFinancialAllowVolumePanelReorder: Boolean;
    procedure SetFinancialAllowVolumePanelReorder(const Value: Boolean);
    function GetFinancialShowPanelDragAdorner: Boolean;
    procedure SetFinancialShowPanelDragAdorner(const Value: Boolean);
    function GetFinancialShowPanelDropZones: Boolean;
    procedure SetFinancialShowPanelDropZones(const Value: Boolean);
    function GetFinancialShowPanelContextMenu: Boolean;
    procedure SetFinancialShowPanelContextMenu(const Value: Boolean);
    function GetFinancialShowBuiltInIndicatorSettingsDialog: Boolean;
    procedure SetFinancialShowBuiltInIndicatorSettingsDialog(const Value: Boolean);
    function GetBusinessPanels: TNimbusFinancialPanelCollection;
    procedure SetBusinessPanels(const Value: TNimbusFinancialPanelCollection);
    function GetBusinessIndicators: TNimbusFinancialIndicatorCollection;
    procedure SetBusinessIndicators(const Value: TNimbusFinancialIndicatorCollection);
    function GetBusinessSidePanels: TNimbusFinancialSidePanelCollection;
    procedure SetBusinessSidePanels(const Value: TNimbusFinancialSidePanelCollection);
    function GetBusinessMarkers: TNimbusFinancialMarkerCollection;
    procedure SetBusinessMarkers(const Value: TNimbusFinancialMarkerCollection);
    function GetBusinessAnnotations: TNimbusFinancialAnnotationCollection;
    procedure SetBusinessAnnotations(const Value: TNimbusFinancialAnnotationCollection);
    function GetBusinessRangeSelector: TNimbusFinancialRangeSelector;
    procedure SetBusinessRangeSelector(const Value: TNimbusFinancialRangeSelector);
    function GetBusinessViewport: TNimbusFinancialViewport;
    procedure SetBusinessViewport(const Value: TNimbusFinancialViewport);
    function GetBusinessInteractionOptions: TNimbusFinancialInteractionOptions;
    procedure SetBusinessInteractionOptions(const Value: TNimbusFinancialInteractionOptions);
    function GetBusinessAccessibilityOptions: TNimbusFinancialAccessibilityOptions;
    procedure SetBusinessAccessibilityOptions(const Value: TNimbusFinancialAccessibilityOptions);
    function GetBusinessFinancialPalette: TNimbusFinancialPalette;
    procedure SetBusinessFinancialPalette(const Value: TNimbusFinancialPalette);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Paint; override;
    procedure WndProc(var Message: TMessage); override;
    procedure Click; override;
    procedure DblClick; override;
    function CreateRenderContext(const ABounds: TRect): TNimbusChartRenderContext; override;
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure DestroyWnd; override;
    procedure Resize; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette); override;
    procedure BeginUpdate; reintroduce;
    procedure EndUpdate; reintroduce;
    procedure RefreshProductiveSidePanels;
    function ActivateSidePanelItem(const PanelKey, RowKey: string): Boolean;
    procedure LoadPanelUserProfileFromFile(const FileName: string);
    procedure SavePanelUserProfileToDefaultPath;
    function TryLoadPanelUserProfileFromDefaultPath: Boolean;
    function GetAccessibleCandleDescription(const Index: Integer): string;
    function GetAccessibleSelectedCandleDescription: string;
    property PanelLayout: TNimbusFinancialScene read GetPanelLayout;
    property ThemePresetDisplayName: string read GetThemePresetDisplayName;
    property IsUpdating: Boolean read GetIsUpdating;
    procedure ResetView; override;
    procedure ClearSelection; override;
    function LoadCsvText(const Text: string): TNimbusFinancialDataImportResult;
    function LoadCsv(const FileName: string): TNimbusFinancialDataImportResult;
    function LoadDataSource(DataSet: TDataSet): TNimbusFinancialDataImportResult;
    procedure ReplaceCandles(Data: TNimbusFinancialDataPointCollection);
    procedure ClearData;
    function ExportVisibleDataCsv: string;
    function ExportIndicatorsCsv: string;
    procedure SaveVisibleDataCsv(const FileName: string);
    procedure SaveIndicatorsCsv(const FileName: string);
    procedure CopyImageToClipboard;
    function GetAccessibleSummary: string;
    procedure SelectCandleForAccessibility(const Index: Integer);
    function SavePanelLayout: string;
    procedure LoadPanelLayout(const Text: string);
    function SavePanelUserProfile: string;
    procedure LoadPanelUserProfile(const Text: string);
    procedure SavePanelUserProfileToFile(const FileName: string);
    function TryLoadPanelUserProfileFromFile(const FileName: string): Boolean;
    procedure ResetPanelLayout;
    procedure ApplyPanelLayoutPreset(const Preset: TNimbusFinancialPanelLayoutPreset);
    function MovePanel(const Key: string; const TargetIndex: Integer): Boolean;
    procedure EditPanelSettings(Panel: TNimbusFinancialPanel);
    property LastLoadedFileName: string read FLastLoadedFileName;
    property LastError: string read FLastError;
    property Candles: TNimbusFinancialDataPointCollection read GetCandles;
  published
    property Title: string read GetFinancialTitle write SetFinancialTitle;
    property Subtitle: string read GetFinancialSubtitle write SetFinancialSubtitle;
    property ShowRangeSelector: Boolean read GetShowRangeSelector write SetShowRangeSelector default True;
    property PanelLayoutPreset: TNimbusFinancialPanelLayoutPreset read FLayoutPreset write ApplyPanelLayoutPreset default nfplDefault;
    property Symbol: string read GetFinancialSymbol write SetFinancialSymbol;
    property Exchange: string read GetFinancialExchange write SetFinancialExchange;
    property TimeFrame: TNimbusFinancialTimeFrame read GetFinancialTimeFrame write SetFinancialTimeFrame;
    property PriceMode: TNimbusFinancialPriceMode read GetFinancialPriceMode write SetFinancialPriceMode;
    property ShowVolume: Boolean read GetFinancialShowVolume write SetFinancialShowVolume;
    property ShowVolumeMovingAverage: Boolean read GetFinancialShowVolumeMovingAverage write SetFinancialShowVolumeMovingAverage;
    property VolumeMovingAveragePeriod: Integer read GetFinancialVolumeMovingAveragePeriod write SetFinancialVolumeMovingAveragePeriod;
    property ShowSimpleMovingAverage: Boolean read GetFinancialShowSimpleMovingAverage write SetFinancialShowSimpleMovingAverage;
    property ShowExponentialMovingAverage: Boolean read GetFinancialShowExponentialMovingAverage write SetFinancialShowExponentialMovingAverage;
    property SimpleMovingAveragePeriods: string read GetFinancialSimpleMovingAveragePeriods write SetFinancialSimpleMovingAveragePeriods;
    property ExponentialMovingAveragePeriods: string read GetFinancialExponentialMovingAveragePeriods write SetFinancialExponentialMovingAveragePeriods;
    property ShowBollingerBands: Boolean read GetFinancialShowBollingerBands write SetFinancialShowBollingerBands;
    property BollingerBandPeriods: string read GetFinancialBollingerBandPeriods write SetFinancialBollingerBandPeriods;
    property BollingerBandStandardDeviation: Double read GetFinancialBollingerBandStandardDeviation write SetFinancialBollingerBandStandardDeviation;
    property ShowRsi: Boolean read GetFinancialShowRsi write SetFinancialShowRsi;
    property RsiPeriods: string read GetFinancialRsiPeriods write SetFinancialRsiPeriods;
    property RsiOversoldLevel: Double read GetFinancialRsiOversoldLevel write SetFinancialRsiOversoldLevel;
    property RsiOverboughtLevel: Double read GetFinancialRsiOverboughtLevel write SetFinancialRsiOverboughtLevel;
    property ShowMacd: Boolean read GetFinancialShowMacd write SetFinancialShowMacd;
    property MacdFastPeriod: Integer read GetFinancialMacdFastPeriod write SetFinancialMacdFastPeriod;
    property MacdSlowPeriod: Integer read GetFinancialMacdSlowPeriod write SetFinancialMacdSlowPeriod;
    property MacdSignalPeriod: Integer read GetFinancialMacdSignalPeriod write SetFinancialMacdSignalPeriod;
    property ShowStochastic: Boolean read GetFinancialShowStochastic write SetFinancialShowStochastic;
    property StochasticPeriod: Integer read GetFinancialStochasticPeriod write SetFinancialStochasticPeriod;
    property StochasticSmoothKPeriod: Integer read GetFinancialStochasticSmoothKPeriod write SetFinancialStochasticSmoothKPeriod;
    property StochasticDPeriod: Integer read GetFinancialStochasticDPeriod write SetFinancialStochasticDPeriod;
    property StochasticOversoldLevel: Double read GetFinancialStochasticOversoldLevel write SetFinancialStochasticOversoldLevel;
    property StochasticOverboughtLevel: Double read GetFinancialStochasticOverboughtLevel write SetFinancialStochasticOverboughtLevel;
    property ShowAtr: Boolean read GetFinancialShowAtr write SetFinancialShowAtr;
    property AtrPeriods: string read GetFinancialAtrPeriods write SetFinancialAtrPeriods;
    property ShowVwap: Boolean read GetFinancialShowVwap write SetFinancialShowVwap;
    property VwapResetBySession: Boolean read GetFinancialVwapResetBySession write SetFinancialVwapResetBySession;
    property ShowCrosshair: Boolean read GetFinancialShowCrosshair write SetFinancialShowCrosshair;
    property ShowLegend: Boolean read GetFinancialShowLegend write SetFinancialShowLegend;
    property ShowGrid: Boolean read GetFinancialShowGrid write SetFinancialShowGrid;
    property ShowAxes: Boolean read GetFinancialShowAxes write SetFinancialShowAxes;
    property ShowAnnotations: Boolean read GetFinancialShowAnnotations write SetFinancialShowAnnotations;
    property ShowToolTips: Boolean read GetFinancialShowToolTips write SetFinancialShowToolTips;
    property LockDetailsOnSelection: Boolean read GetFinancialLockDetailsOnSelection write SetFinancialLockDetailsOnSelection;
    property ClearSelectionOnEmptyPlotClick: Boolean read GetFinancialClearSelectionOnEmptyPlotClick write SetFinancialClearSelectionOnEmptyPlotClick;
    property ClearSelectionOnEscape: Boolean read GetFinancialClearSelectionOnEscape write SetFinancialClearSelectionOnEscape;
    property ShowCrosshairWhileSelectionLocked: Boolean read GetFinancialShowCrosshairWhileSelectionLocked write SetFinancialShowCrosshairWhileSelectionLocked;
    property ShowDashboardPanels: Boolean read GetFinancialShowDashboardPanels write SetFinancialShowDashboardPanels;
    property AutoBuildProductiveSidePanels: Boolean read GetFinancialAutoBuildProductiveSidePanels write SetFinancialAutoBuildProductiveSidePanels;
    property SidePanelLayoutMode: TNimbusFinancialSidePanelLayoutMode read GetFinancialSidePanelLayoutMode write SetFinancialSidePanelLayoutMode;
    property LeftSidePanelAreaWidth: Integer read GetFinancialLeftSidePanelAreaWidth write SetFinancialLeftSidePanelAreaWidth;
    property RightSidePanelAreaWidth: Integer read GetFinancialRightSidePanelAreaWidth write SetFinancialRightSidePanelAreaWidth;
    property AllowPanelLayoutChanges: Boolean read GetFinancialAllowPanelLayoutChanges write SetFinancialAllowPanelLayoutChanges;
    property AllowVolumePanelReorder: Boolean read GetFinancialAllowVolumePanelReorder write SetFinancialAllowVolumePanelReorder;
    property ShowPanelDragAdorner: Boolean read GetFinancialShowPanelDragAdorner write SetFinancialShowPanelDragAdorner;
    property ShowPanelDropZones: Boolean read GetFinancialShowPanelDropZones write SetFinancialShowPanelDropZones;
    property ShowPanelContextMenu: Boolean read GetFinancialShowPanelContextMenu write SetFinancialShowPanelContextMenu;
    property ShowBuiltInIndicatorSettingsDialog: Boolean read GetFinancialShowBuiltInIndicatorSettingsDialog write SetFinancialShowBuiltInIndicatorSettingsDialog;
    property Panels: TNimbusFinancialPanelCollection read GetBusinessPanels write SetBusinessPanels;
    property Indicators: TNimbusFinancialIndicatorCollection read GetBusinessIndicators write SetBusinessIndicators;
    property SidePanels: TNimbusFinancialSidePanelCollection read GetBusinessSidePanels write SetBusinessSidePanels;
    property Markers: TNimbusFinancialMarkerCollection read GetBusinessMarkers write SetBusinessMarkers;
    property Annotations: TNimbusFinancialAnnotationCollection read GetBusinessAnnotations write SetBusinessAnnotations;
    property RangeSelector: TNimbusFinancialRangeSelector read GetBusinessRangeSelector write SetBusinessRangeSelector;
    property Viewport: TNimbusFinancialViewport read GetBusinessViewport write SetBusinessViewport;
    property InteractionOptions: TNimbusFinancialInteractionOptions read GetBusinessInteractionOptions write SetBusinessInteractionOptions;
    property AccessibilityOptions: TNimbusFinancialAccessibilityOptions read GetBusinessAccessibilityOptions write SetBusinessAccessibilityOptions;
    property FinancialPalette: TNimbusFinancialPalette read GetBusinessFinancialPalette write SetBusinessFinancialPalette;
    property Financial: TNimbusFinancialWorkspace read FFinancial write SetFinancial stored False;
    property CsvImportOptions: TNimbusFinancialCsvImportOptions read FCsvOptions write SetCsvOptions;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property ThemeMode: TNimbusFinancialThemeMode read FThemeMode write SetThemeMode default nftmAuto;
    property ThemePreset: TNimbusFinancialThemePreset read FThemePreset write SetThemePreset default nftpNimbusDark;
    property PanelLayoutProfilePath: string read FProfilePath write SetProfilePath;
    property AutoRestorePanelLayout: Boolean read FAutoRestore write SetAutoRestore default False;
    property AutoSavePanelLayout: Boolean read FAutoSave write FAutoSave default False;
    property OnCandleHovered: TNimbusFinancialCandleEvent read FOnCandleHovered write FOnCandleHovered;
    property OnCandleClicked: TNimbusFinancialCandleEvent read FOnCandleClicked write FOnCandleClicked;
    property OnViewportChanged: TNotifyEvent read FOnViewportChanged write FOnViewportChanged;
    property OnRangeChanged: TNotifyEvent read FOnRangeChanged write FOnRangeChanged;
    property OnCrosshairChanged: TNotifyEvent read FOnCrosshairChanged write FOnCrosshairChanged;
    property OnSelectionCleared: TNotifyEvent read FOnSelectionCleared write FOnSelectionCleared;
    property OnPanelCollapsed: TNimbusFinancialPanelEvent read FOnPanelCollapsed write FOnPanelCollapsed;
    property OnPanelExpanded: TNimbusFinancialPanelEvent read FOnPanelExpanded write FOnPanelExpanded;
    property OnPanelClosed: TNimbusFinancialPanelEvent read FOnPanelClosed write FOnPanelClosed;
    property OnPanelResized: TNimbusFinancialPanelEvent read FOnPanelResized write FOnPanelResized;
    property OnPanelMoved: TNimbusFinancialPanelEvent read FOnPanelMoved write FOnPanelMoved;
    property OnPanelPinned: TNimbusFinancialPanelEvent read FOnPanelPinned write FOnPanelPinned;
    property OnPanelUnpinned: TNimbusFinancialPanelEvent read FOnPanelUnpinned write FOnPanelUnpinned;
    property OnPanelSettingsRequested: TNimbusFinancialPanelEvent read FOnPanelSettingsRequested write FOnPanelSettingsRequested;
    property OnMarkerClicked: TNimbusFinancialHitEvent read FOnMarkerClicked write FOnMarkerClicked;
    property OnAnnotationClicked: TNimbusFinancialHitEvent read FOnAnnotationClicked write FOnAnnotationClicked;
    property OnIndicatorClicked: TNimbusFinancialHitEvent read FOnIndicatorClicked write FOnIndicatorClicked;
    property OnSidePanelItemClicked: TNimbusFinancialHitEvent read FOnSidePanelItemClicked write FOnSidePanelItemClicked;
    property OnRowClicked: TNimbusFinancialRowEvent read FOnRowClicked write FOnRowClicked;
    property OnRowDoubleClicked: TNimbusFinancialRowEvent read FOnRowDoubleClicked write FOnRowDoubleClicked;
    property OnRowHovered: TNimbusFinancialRowEvent read FOnRowHovered write FOnRowHovered;
    property OnRowContextMenu: TNimbusFinancialRowEvent read FOnRowContextMenu write FOnRowContextMenu;
    property OnPanelAction: TNimbusFinancialPanelActionEvent read FOnPanelAction write FOnPanelAction;
    property OnDataLoaded: TNimbusFinancialDataEvent read FOnDataLoaded write FOnDataLoaded;
    property OnDataLoadFailed: TNimbusFinancialErrorEvent read FOnDataLoadFailed write FOnDataLoadFailed;
    property OnPanelProfileLoadFailed: TNimbusFinancialErrorEvent read FOnProfileLoadFailed write FOnProfileLoadFailed;
  end;

implementation

uses System.IOUtils, Vcl.Clipbrd, NimbusForms.Charts.Types, NimbusForms.Rendering.Types, NimbusForms.Rendering.Canvas,
  NimbusForms.Charts.Financial.Indicators, NimbusForms.Charts.Financial.Profiles,
  NimbusForms.Controls.FinancialSettings, NimbusForms.Theming.Types;

type
  TNimbusFinancialDataLink = class(TDataLink)
  private
    FChart: TThemedFinancialBusinessChart;
  protected
    procedure ActiveChanged; override;
    procedure DataSetChanged; override;
  public
    constructor Create(Chart: TThemedFinancialBusinessChart);
  end;

constructor TNimbusFinancialDataLink.Create(Chart: TThemedFinancialBusinessChart);
begin inherited Create; FChart := Chart end;
procedure TNimbusFinancialDataLink.ActiveChanged;
begin if FChart <> nil then FChart.ReloadDataSource end;
procedure TNimbusFinancialDataLink.DataSetChanged;
begin if FChart <> nil then FChart.ReloadDataSource end;

constructor TThemedFinancialBusinessChart.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFinancial := TNimbusFinancialWorkspace.Create; FCsvOptions := TNimbusFinancialCsvImportOptions.Create;
  FDataLink := TNimbusFinancialDataLink.Create(Self); FToolTip := TThemedToolTip.Create(Self);
  FPanelMenu := TThemedPopupMenu.Create(Self); FScrollBars := TObjectList<TThemedVScrollBar>.Create(True);
  FFinancial.OnChange := FinancialChanged; FThemeMode := nftmAuto; FThemePreset := nftpNimbusDark;
  RendererFactory.RegisterFirst(TNimbusFinancialBusinessRenderer.Create);
  FPressedHit := TNimbusChartHit.None; FContextPanel := -1; FMoveTarget := -1;
  FRowFocusPanelIndex := -1; FRowFocusIndex := -1; FHoverRowPanelIndex := -1; FHoverRowIndex := -1;
  TThemedChart(Self).ShowCrosshair := False; ShowSelectionPanel := False; ShowAnimation := False;
  EnableZoom := False; EnablePan := False; EnableDragPan := False; TabStop := True;
  ControlStyle := ControlStyle + [csDoubleClicks];
  Width := 900; Height := 520; Model.Title := 'Financial Chart'; Model.Subtitle := 'Price, volume and technical analysis';
  SyncPalette;
end;

destructor TThemedFinancialBusinessChart.Destroy;
begin
  FClosing := True; CancelFinancialDrag;
  if FFinancial <> nil then FFinancial.OnChange := nil; if FDataLink <> nil then FDataLink.DataSource := nil; FreeAndNil(FDataLink); FreeAndNil(FScrollBars);
  FreeAndNil(FFinancial); FreeAndNil(FCsvOptions); inherited;
end;

procedure TThemedFinancialBusinessChart.ApplyTheme(const APalette: TThemePalette);
begin
  inherited;
  if FFinancial = nil then Exit;
  if FToolTip <> nil then FToolTip.ApplyTheme(APalette); if FPanelMenu <> nil then FPanelMenu.ApplyTheme(APalette);
  if FThemeMode = nftmAuto then
  begin FHighContrastActive := False; FUpdating := True; try FFinancial.Palette.ApplyTheme(APalette) finally FUpdating := False end; SyncPalette end;
end;

procedure TThemedFinancialBusinessChart.SyncPalette;
var P: TNimbusFinancialPalette;
begin
  if (FFinancial = nil) or FUpdating or FClosing then Exit;
  FUpdating := True;
  try
    P := FFinancial.Palette; Model.BeginUpdate;
    try
      Model.Palette.BackColor := ThemeColorToColor(P.Background); Model.Palette.PlotBackColor := ThemeColorToColor(P.PanelBackground);
      Model.Palette.ForeColor := ThemeColorToColor(P.TitleText); Model.Palette.MutedForeColor := ThemeColorToColor(P.AxisText);
      Model.Palette.BorderColor := ThemeColorToColor(P.Border); Model.Palette.GridLineColor := ThemeColorToColor(P.GridMajor);
      Model.Palette.AccentColor := ThemeColorToColor(P.Accent); ColorMode := nccCustom;
    finally Model.EndUpdate end;
  finally FUpdating := False end;
end;

procedure TThemedFinancialBusinessChart.FinancialChanged(Sender: TObject);
begin
  if FUpdating or FClosing or (FUpdateCount > 0) then Exit;
  SyncPalette; Invalidate;
  if not FRefreshing then
  begin
    FRefreshing := True;
    try
      FFinancial.EnsureCache(FinancialData); FFinancial.RefreshProductiveSidePanels;
      if HandleAllocated then begin SyncScrollBars; UpdateAccessibility end;
    finally FRefreshing := False end;
  end;
end;

procedure TThemedFinancialBusinessChart.SetFinancial(const Value: TNimbusFinancialWorkspace);
begin if Value <> nil then begin FUpdating := True; try FFinancial.Assign(Value) finally FUpdating := False end; FinancialChanged(Self) end end;
procedure TThemedFinancialBusinessChart.SetCsvOptions(const Value: TNimbusFinancialCsvImportOptions);
begin if Value <> nil then FCsvOptions.Assign(Value) end;
procedure TThemedFinancialBusinessChart.SetThemeMode(const Value: TNimbusFinancialThemeMode);
begin
  if FThemeMode = Value then Exit; FThemeMode := Value; FHighContrastActive := False; FUpdating := True;
  try
    case Value of
      nftmAuto: FFinancial.Palette.ApplyTheme(Palette);
      nftmLight: FFinancial.Palette.ApplyPreset(nftpNimbusLight);
      nftmDark: FFinancial.Palette.ApplyPreset(nftpNimbusDark);
    end;
  finally FUpdating := False end;
  SyncPalette;
end;
procedure TThemedFinancialBusinessChart.SetThemePreset(const Value: TNimbusFinancialThemePreset);
begin
  FThemePreset := Value; FThemeMode := nftmCustom; FUpdating := True;
  try FFinancial.Palette.ApplyPreset(Value) finally FUpdating := False end; SyncPalette;
end;

function TThemedFinancialBusinessChart.CreateRenderContext(const ABounds: TRect): TNimbusChartRenderContext;
var Contrast: THighContrast; Active: Boolean;
begin
  if FFinancial <> nil then
  begin
    Contrast := Default(THighContrast); Contrast.cbSize := SizeOf(Contrast);
    Active := (FThemeMode <> nftmCustom) and FFinancial.AccessibilityOptions.AutoApplyHighContrast and
      SystemParametersInfo(SPI_GETHIGHCONTRAST, SizeOf(Contrast), @Contrast, 0) and ((Contrast.dwFlags and HCF_HIGHCONTRASTON) <> 0);
    if Active <> FHighContrastActive then
    begin
      FHighContrastActive := Active; FUpdating := True;
      try
        if Active then FFinancial.Palette.ApplyPreset(nftpHighContrast)
        else case FThemeMode of
          nftmAuto: FFinancial.Palette.ApplyTheme(Palette);
          nftmLight: FFinancial.Palette.ApplyPreset(nftpNimbusLight);
          nftmDark: FFinancial.Palette.ApplyPreset(nftpNimbusDark);
        end;
      finally FUpdating := False end;
      SyncPalette;
    end;
  end;
  Result := inherited CreateRenderContext(ABounds);
  if FFinancial = nil then Exit;
  FFinancial.EnsureCache(FinancialData); Result.Financial := FFinancial; Result.ShowGlow := False;
end;

procedure TThemedFinancialBusinessChart.SyncScrollBars;
var Scene: TNimbusFinancialScene; SL: TNimbusFinancialSidePanelLayout; Bar: TThemedVScrollBar; I, Desired: Integer;
  VisibleBars: TArray<Boolean>; Bounds: TRect;
begin
  if FClosing or FSyncingBars or (FFinancial = nil) or (FScrollBars = nil) or not HandleAllocated then Exit;
  FSyncingBars := True;
  try
    Scene := TNimbusFinancialBusinessRenderer.Layout(CreateRenderContext(ClientRect)); Desired := FFinancial.SidePanels.Count;
    while FScrollBars.Count < Desired do
    begin
      Bar := TThemedVScrollBar.Create(Self); Bar.Visible := False; Bar.Parent := Self; Bar.OnValueChanged := ScrollBarChanged;
      Bar.TabStop := True; FScrollBars.Add(Bar);
    end;
    SetLength(VisibleBars, FScrollBars.Count);
    for SL in Scene.SidePanels do
    begin
      Bar := FScrollBars[SL.PanelIndex]; Bar.Tag := SL.PanelIndex;
      VisibleBars[SL.PanelIndex] := (FFinancial.SidePanels[SL.PanelIndex].State = nfspsExpanded) and (SL.ContentHeight > SL.Body.Height) and (SL.Body.Height > 0);
      if not VisibleBars[SL.PanelIndex] then Continue;
      Bounds := Rect(SL.Body.Right - ScaleValue(18), SL.Body.Top, SL.Body.Right, SL.Body.Bottom);
      if not EqualRect(Bar.BoundsRect, Bounds) then Bar.SetBounds(Bounds.Left, Bounds.Top, Bounds.Width, Bounds.Height);
      Bar.Minimum := 0; Bar.Maximum := Max(0, SL.ContentHeight - 1); Bar.LargeChange := Max(1, SL.Body.Height);
      Bar.SmallChange := ScaleValue(24); Bar.Value := FFinancial.SidePanels[SL.PanelIndex].ScrollOffset;
    end;
    for I := 0 to FScrollBars.Count - 1 do
      if FScrollBars[I].Visible <> VisibleBars[I] then
      begin FScrollBars[I].Visible := VisibleBars[I]; if VisibleBars[I] then FScrollBars[I].BringToFront end;
  finally FSyncingBars := False end;
end;

procedure TThemedFinancialBusinessChart.ScrollBarChanged(Sender: TObject);
var Bar: TThemedVScrollBar;
begin
  if FSyncingBars or FClosing then Exit; Bar := TThemedVScrollBar(Sender);
  ScrollSidePanel(Bar.Tag, Bar.Value);
end;

procedure TThemedFinancialBusinessChart.ScrollSidePanel(const PanelIndex, Offset: Integer);
var Scene: TNimbusFinancialScene; SL: TNimbusFinancialSidePanelLayout; Bounds: TRect;
  Value: Integer; PreviousUpdating, PreviousSyncing: Boolean;
begin
  if FClosing or (FFinancial = nil) or (PanelIndex < 0) or (PanelIndex >= FFinancial.SidePanels.Count) then Exit;
  Scene := TNimbusFinancialBusinessRenderer.Layout(CreateRenderContext(Rect(0, 0, Width, Height)));
  for SL in Scene.SidePanels do if SL.PanelIndex = PanelIndex then
  begin
    Value := EnsureRange(Offset, 0, Max(0, SL.ContentHeight - SL.Body.Height));
    if FFinancial.SidePanels[PanelIndex].ScrollOffset = Value then Exit;
    PreviousUpdating := FUpdating; FUpdating := True;
    try FFinancial.SidePanels[PanelIndex].ScrollOffset := Value finally FUpdating := PreviousUpdating end;
    Bounds := SL.Body;
    if (FScrollBars <> nil) and (PanelIndex < FScrollBars.Count) then
    begin
      PreviousSyncing := FSyncingBars; FSyncingBars := True;
      try FScrollBars[PanelIndex].Value := Value finally FSyncingBars := PreviousSyncing end;
      if FScrollBars[PanelIndex].Visible then Bounds.Right := Min(Bounds.Right, FScrollBars[PanelIndex].Left);
    end;
    if HandleAllocated and not Bounds.IsEmpty then InvalidateRect(Handle, @Bounds, False) else Invalidate;
    NotifyPanelAction(nfpaScrolled, PanelIndex, True); Exit;
  end;
end;

procedure TThemedFinancialBusinessChart.CreateParams(var Params: TCreateParams);
begin inherited; Params.Style := Params.Style or WS_CLIPCHILDREN end;

procedure TThemedFinancialBusinessChart.Paint;
var Exclusion: INimbusRenderClipExclusion; Bar: TThemedVScrollBar;
begin
  RenderCanvas.BeginRender(Canvas);
  try
    RenderCanvas.PushClip(Canvas.ClipRect);
    try
      if Supports(RenderCanvas, INimbusRenderClipExclusion, Exclusion) and (FScrollBars <> nil) then
        for Bar in FScrollBars do if Bar.Visible then Exclusion.ExcludeClip(Bar.BoundsRect);
      RenderChart(RenderCanvas, Rect(0, 0, Width, Height));
    finally RenderCanvas.PopClip end;
  finally Exclusion := nil; RenderCanvas.EndRender end;
end;

procedure TThemedFinancialBusinessChart.CreateWnd;
begin inherited; RestoreProfile; SyncScrollBars end;
procedure TThemedFinancialBusinessChart.Loaded;
begin inherited; RestoreProfile; FinancialChanged(Self) end;
procedure TThemedFinancialBusinessChart.DestroyWnd;
begin CancelFinancialDrag; if FToolTip <> nil then FToolTip.ClearInfo(Self); inherited end;
procedure TThemedFinancialBusinessChart.Resize;
begin
  inherited;
  if (FFinancial <> nil) and not FClosing then
  begin if FDragMode <> nfdmNone then CancelFinancialDrag; if HandleAllocated then SyncScrollBars end;
end;
procedure TThemedFinancialBusinessChart.Notification(AComponent: TComponent; Operation: TOperation);
begin inherited; if (Operation = opRemove) and (FDataLink <> nil) and (AComponent = FDataLink.DataSource) then FDataLink.DataSource := nil end;

function TThemedFinancialBusinessChart.GetDataSource: TDataSource;
begin Result := FDataLink.DataSource end;
function TThemedFinancialBusinessChart.GetCandles: TNimbusFinancialDataPointCollection;
begin Result := FinancialData end;
procedure TThemedFinancialBusinessChart.SetDataSource(const Value: TDataSource);
begin
  if FDataLink.DataSource = Value then Exit;
  if FDataLink.DataSource <> nil then FDataLink.DataSource.RemoveFreeNotification(Self);
  FDataLink.DataSource := Value; if Value <> nil then Value.FreeNotification(Self); ReloadDataSource;
end;
procedure TThemedFinancialBusinessChart.ReloadDataSource;
var R: TNimbusFinancialDataImportResult;
begin
  if FLoading or FClosing or (FDataLink = nil) or (FDataLink.DataSet = nil) or not FDataLink.DataSet.Active then Exit;
  R := LoadDataSource(FDataLink.DataSet); R.Free;
end;
function TThemedFinancialBusinessChart.LoadDataSource(DataSet: TDataSet): TNimbusFinancialDataImportResult;
begin
  Result := nil; FLoading := True;
  try
    try Result := TNimbusFinancialDataAdapter.ImportDataSet(DataSet, FCsvOptions); ReplaceCandles(Result.Candles);
      if Assigned(FOnDataLoaded) then FOnDataLoaded(Self, Result)
    except on E: Exception do begin FreeAndNil(Result); FLastError := E.Message; if Assigned(FOnDataLoadFailed) then FOnDataLoadFailed(Self, E.Message); raise end end;
  finally FLoading := False end;
end;
function TThemedFinancialBusinessChart.LoadCsvText(const Text: string): TNimbusFinancialDataImportResult;
begin
  Result := nil;
  try Result := TNimbusFinancialDataAdapter.ImportCsvText(Text, FCsvOptions); ReplaceCandles(Result.Candles);
    if Assigned(FOnDataLoaded) then FOnDataLoaded(Self, Result)
  except on E: Exception do begin FreeAndNil(Result); FLastError := E.Message; if Assigned(FOnDataLoadFailed) then FOnDataLoadFailed(Self, E.Message); raise end end;
end;
function TThemedFinancialBusinessChart.LoadCsv(const FileName: string): TNimbusFinancialDataImportResult;
var Text: string;
begin
  try Text := TFile.ReadAllText(FileName, TEncoding.UTF8)
  except on E: Exception do begin FLastError := E.Message; if Assigned(FOnDataLoadFailed) then FOnDataLoadFailed(Self, E.Message); raise end end;
  Result := LoadCsvText(Text); FLastLoadedFileName := FileName;
end;
procedure TThemedFinancialBusinessChart.ReplaceCandles(Data: TNimbusFinancialDataPointCollection);
var I: Integer;
begin
  if Data = nil then raise EArgumentNilException.Create('Candles');
  for I := 0 to Data.Count - 1 do TNimbusFinancialDataAdapter.ValidateCandle(Data[I].Time, Data[I].Open, Data[I].High, Data[I].Low, Data[I].Close, Data[I].Volume);
  CancelFinancialDrag; BeginUpdate;
  try
    FFinancial.ClearSelection; FinancialData.Assign(Data); FFinancial.InvalidateCache;
    FFinancial.EnsureCache(FinancialData); FFinancial.Viewport.ScrollToEnd;
    FFinancial.RefreshProductiveSidePanels;
  finally EndUpdate end;
  SyncScrollBars; UpdateAccessibility;
end;
procedure TThemedFinancialBusinessChart.ClearData;
begin CancelFinancialDrag; FinancialData.Clear; FFinancial.InvalidateCache; FFinancial.EnsureCache(FinancialData); ClearSelection end;

function TThemedFinancialBusinessChart.ExportVisibleDataCsv: string;
begin FFinancial.EnsureCache(FinancialData); Result := TNimbusFinancialDataAdapter.ExportCsv(FFinancial.Candles, FFinancial.Viewport.FirstVisibleIndex, FFinancial.Viewport.ActualVisibleCount) end;
function TThemedFinancialBusinessChart.ExportIndicatorsCsv: string;
var Builder: TStringBuilder; I: Integer; S: TNimbusFinancialIndicatorSnapshot; Fmt: TFormatSettings;
  procedure Number(const Values: TNimbusFinancialValues; const Index: Integer);
  begin Builder.Append(','); if (Index < Length(Values)) and not IsNan(Values[Index]) and not IsInfinite(Values[Index]) then Builder.Append(FloatToStr(Values[Index], Fmt)) end;
begin
  FFinancial.EnsureCache(FinancialData); Fmt := TFormatSettings.Invariant; Builder := TStringBuilder.Create;
  try
    Builder.Append('Date');
    for S in FFinancial.Snapshots do
    begin Builder.Append(',').Append(S.Key); if Length(S.Secondary) > 0 then Builder.Append(',').Append(S.Key).Append('.secondary'); if Length(S.Tertiary) > 0 then Builder.Append(',').Append(S.Key).Append('.tertiary') end;
    Builder.AppendLine;
    for I := FFinancial.Viewport.FirstVisibleIndex to FFinancial.Viewport.LastVisibleIndex do
    begin
      Builder.Append(FormatDateTime('yyyy-mm-dd hh:nn:ss', FFinancial.Candles[I].Time, Fmt));
      for S in FFinancial.Snapshots do begin Number(S.Values, I); if Length(S.Secondary) > 0 then Number(S.Secondary, I); if Length(S.Tertiary) > 0 then Number(S.Tertiary, I) end;
      Builder.AppendLine;
    end;
    Result := Builder.ToString;
  finally Builder.Free end;
end;
procedure TThemedFinancialBusinessChart.SaveVisibleDataCsv(const FileName: string);
begin TFile.WriteAllText(FileName, ExportVisibleDataCsv, TEncoding.UTF8) end;
procedure TThemedFinancialBusinessChart.SaveIndicatorsCsv(const FileName: string);
begin TFile.WriteAllText(FileName, ExportIndicatorsCsv, TEncoding.UTF8) end;
procedure TThemedFinancialBusinessChart.CopyImageToClipboard;
var Bitmap: TBitmap;
begin Bitmap := RenderToBitmap; try Clipboard.Assign(Bitmap) finally Bitmap.Free end end;

procedure TThemedFinancialBusinessChart.CancelFinancialDrag;
begin
  FDragMode := nfdmNone; FPressedHit := TNimbusChartHit.None; FDragMoved := False;
  FResizePanels := nil;
  if FFinancial <> nil then begin FFinancial.DragPanelIndex := -1; FFinancial.DropPanelIndex := -1 end;
  if HandleAllocated and MouseCapture then MouseCapture := False;
  if not FClosing then Cursor := crDefault;
end;
procedure TThemedFinancialBusinessChart.WMCaptureChanged(var Message: TMessage);
begin inherited; if not FHandlingMouseUp then CancelFinancialDrag end;

procedure TThemedFinancialBusinessChart.WndProc(var Message: TMessage);
var ReleaseMessage, Previous: Boolean;
begin
  ReleaseMessage := (Message.Msg = WM_LBUTTONUP) or (Message.Msg = WM_MBUTTONUP) or (Message.Msg = WM_RBUTTONUP);
  if Message.Msg = WM_LBUTTONDBLCLK then
  begin
    FPointerLocation := Point(TWMMouse(Message).XPos, TWMMouse(Message).YPos); FPointerShift := [];
    if (Message.WParam and MK_SHIFT) <> 0 then Include(FPointerShift, ssShift);
    if (Message.WParam and MK_CONTROL) <> 0 then Include(FPointerShift, ssCtrl);
    if GetKeyState(VK_MENU) < 0 then Include(FPointerShift, ssAlt);
  end;
  Previous := FHandlingMouseUp; if ReleaseMessage then FHandlingMouseUp := True;
  try inherited WndProc(Message)
  finally FHandlingMouseUp := Previous end;
  if (Message.Msg = WM_CANCELMODE) or ((Message.Msg = CM_ENABLEDCHANGED) and not Enabled) then CancelFinancialDrag;
end;

function TThemedFinancialBusinessChart.BeginPanelResize(const Scene: TNimbusFinancialScene; const PanelIndex: Integer): Boolean;
var PL: TNimbusFinancialPanelLayout; Panel: TNimbusFinancialPanel; N: Integer;
begin
  Result := False; FResizePanels := nil;
  for PL in Scene.Panels do
  begin
    Panel := FFinancial.Panels[PL.PanelIndex];
    if (PL.PanelIndex < PanelIndex) or (Panel.State <> nfpsExpanded) or not Panel.AllowResize or (PL.Bounds.Height <= 0) then Continue;
    N := Length(FResizePanels); SetLength(FResizePanels, N + 1);
    FResizePanels[N].PanelIndex := PL.PanelIndex; FResizePanels[N].Key := Panel.Key; FResizePanels[N].Height := PL.Bounds.Height;
  end;
  if (Length(FResizePanels) < 2) or (FResizePanels[0].PanelIndex <> PanelIndex) then begin FResizePanels := nil; Exit end;
  FFinancial.Panels.BeginUpdate;
  try
    for PL in Scene.Panels do if FFinancial.Panels[PL.PanelIndex].State = nfpsExpanded then
      FFinancial.Panels[PL.PanelIndex].PreferredHeight := Max(0, Floor(PL.Bounds.Height * 96 / Max(1, CurrentPPI) + 0.5));
  finally FFinancial.Panels.EndUpdate end;
  FDragMode := nfdmPanelResize; Result := True;
end;

procedure TThemedFinancialBusinessChart.ResizePanels(const Delta: Integer);
var I, TopMinimum, BottomCapacity, ActualDelta, Remaining, Change, Height, Minimum: Integer;
  Panel: TNimbusFinancialPanel;
begin
  if Length(FResizePanels) < 2 then Exit;
  for I := 0 to High(FResizePanels) do
    if (FResizePanels[I].PanelIndex >= FFinancial.Panels.Count) or
      (FFinancial.Panels[FResizePanels[I].PanelIndex].Key <> FResizePanels[I].Key) or
      not FFinancial.Panels[FResizePanels[I].PanelIndex].AllowResize or
      not FFinancial.PanelIsActive(FFinancial.Panels[FResizePanels[I].PanelIndex]) or
      (FFinancial.Panels[FResizePanels[I].PanelIndex].State <> nfpsExpanded) then begin CancelFinancialDrag; Exit end;
  TopMinimum := ScaleValue(FFinancial.Panels[FResizePanels[0].PanelIndex].MinimumHeight); BottomCapacity := 0;
  for I := 1 to High(FResizePanels) do
    Inc(BottomCapacity, Max(0, FResizePanels[I].Height - ScaleValue(FFinancial.Panels[FResizePanels[I].PanelIndex].MinimumHeight)));
  ActualDelta := EnsureRange(Delta, -Max(0, FResizePanels[0].Height - TopMinimum), BottomCapacity); Remaining := Max(0, ActualDelta);
  FFinancial.Panels.BeginUpdate;
  try
    for I := 0 to High(FResizePanels) do
    begin
      Panel := FFinancial.Panels[FResizePanels[I].PanelIndex]; Height := FResizePanels[I].Height;
      if I = 0 then Height := Height + ActualDelta
      else if ActualDelta > 0 then
      begin
        Minimum := ScaleValue(Panel.MinimumHeight); Change := Min(Remaining, Max(0, Height - Minimum)); Dec(Height, Change); Dec(Remaining, Change);
      end
      else if I = 1 then Height := Height - ActualDelta;
      Panel.PreferredHeight := Max(0, Floor(Height * 96 / Max(1, CurrentPPI) + 0.5));
    end;
  finally FFinancial.Panels.EndUpdate end;
end;
procedure TThemedFinancialBusinessChart.CMMouseLeave(var Message: TMessage);
begin
  inherited; if FFinancial = nil then Exit; FHoverRowPanel := ''; FHoverRowKey := ''; FHoverRowPanelIndex := -1; FHoverRowIndex := -1;
  if FDragMode = nfdmNone then begin FFinancial.CrosshairVisible := False; FFinancial.HoveredIndex := -1; FToolTip.ClearInfo(Self); Invalidate end;
end;

procedure TThemedFinancialBusinessChart.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var Scene: TNimbusFinancialScene; SL: TNimbusFinancialSidePanelLayout; I: Integer; Panel: TNimbusFinancialPanel;
begin
  if not Enabled then Exit; if CanFocus then SetFocus; FPointerLocation := Point(X, Y);
  FPressedHit := HitTestChart(Point(X, Y)); FMouseOrigin := Point(X, Y); FDragMoved := False; FMoveTarget := -1;
  if FPressedHit.FinancialArea <> nfhaSidePanelItem then
  begin
    FRowFocusPanel := ''; FRowFocusKey := ''; FFinancial.FocusedSidePanelKey := ''; FFinancial.FocusedRowKey := '';
    FRowFocusPanelIndex := -1; FRowFocusIndex := -1; FFinancial.FocusedSidePanelIndex := -1; FFinancial.FocusedRowIndex := -1; Invalidate;
  end;
  Scene := TNimbusFinancialBusinessRenderer.Layout(CreateRenderContext(ClientRect)); FDragMode := nfdmNone;
  if (Button = mbLeft) and (FPressedHit.FinancialArea = nfhaPanelSeparator) and FFinancial.Options.AllowPanelLayoutChanges then
    BeginPanelResize(Scene, FPressedHit.SeriesIndex)
  else if (Button = mbLeft) and (FPressedHit.FinancialArea = nfhaPanelHeader) and FFinancial.Options.AllowPanelLayoutChanges then
  begin
    Panel := FFinancial.Panels[FPressedHit.SeriesIndex]; if Panel.AllowMove and not Panel.IsPinned then FDragMode := nfdmPanelMove;
  end
  else if (Button = mbLeft) and (FPressedHit.FinancialArea = nfhaSidePanelSeparator) then
  begin
    I := FPressedHit.SeriesIndex; FNextPanel := -1;
    for SL in Scene.SidePanels do
    begin
      if SL.PanelIndex = I then FStartHeight := SL.Bounds.Height
      else if (SL.PanelIndex > I) and (FFinancial.SidePanels[SL.PanelIndex].Position = FFinancial.SidePanels[I].Position) and
        (FFinancial.SidePanels[SL.PanelIndex].State = nfspsExpanded) then
      begin FNextPanel := SL.PanelIndex; FNextHeight := SL.Bounds.Height; Break end;
    end;
    if FNextPanel >= 0 then
    begin FStartWeight := FFinancial.SidePanels[I].PreferredHeight; FNextWeight := FFinancial.SidePanels[FNextPanel].PreferredHeight; FDragMode := nfdmSideHeight end;
  end
  else if (Button = mbLeft) and (FPressedHit.FinancialArea = nfhaSidePanelSplitter) then
  begin
    FDragMode := nfdmSideResize; FStartWidth := FFinancial.SidePanels[FPressedHit.SeriesIndex].Width;
    if FFinancial.Options.SidePanelLayoutMode = nfslStacked then
      for SL in Scene.SidePanels do if SL.PanelIndex = FPressedHit.SeriesIndex then FStartWidth := Round(SL.Bounds.Width * 96 / Max(1, CurrentPPI));
  end
  else if (Button = mbLeft) and (FPressedHit.FinancialArea = nfhaAnnotation) and not FFinancial.Annotations[FPressedHit.ElementIndex].Locked then
  begin
    FDragMode := nfdmAnnotation; with FFinancial.Annotations[FPressedHit.ElementIndex] do
    begin FAnnotationStart := StartValue; FAnnotationEnd := EndValue; FAnnotationFirst := StartIndex; FAnnotationLast := EndIndex;
      if CoordinateMode = nfcmTime then begin FAnnotationFirst := FFinancial.FindCandleByTime(StartTime); FAnnotationLast := FFinancial.FindCandleByTime(EndTime) end;
    end;
  end
  else if (Button = mbLeft) and (ssCtrl in Shift) and (FPressedHit.FinancialArea = nfhaCandle) then
  begin FDragMode := nfdmRange; FRangeAnchor := FPressedHit.PointIndex end
  else if (FPressedHit.FinancialArea = nfhaCandle) and FFinancial.InteractionOptions.EnableDragPan and
    ((Button in FFinancial.InteractionOptions.PanMouseButtons) or ((Button = mbLeft) and FFinancial.InteractionOptions.EnableLeftButtonDragPan)) then
  begin FDragMode := nfdmPan; FStartFirst := FFinancial.Viewport.FirstVisibleIndex end;
  if FPressedHit.FinancialArea <> nfhaNone then MouseCapture := True;
  if FDragMode in [nfdmPanelResize, nfdmSideHeight] then Cursor := crVSplit else if FDragMode = nfdmSideResize then Cursor := crHSplit;
  if Assigned(OnMouseDown) then OnMouseDown(Self, Button, Shift, X, Y);
end;

procedure TThemedFinancialBusinessChart.MouseMove(Shift: TShiftState; X, Y: Integer);
var Hit: TNimbusChartHit; Scene: TNimbusFinancialScene; PL: TNimbusFinancialPanelLayout;
  DX, DY, Delta, OldHover, Index, NewWidth: Integer; Change, NewHeight, Total: Double; Annotation: TNimbusFinancialAnnotation;
  SidePanel: TNimbusFinancialSidePanel;
begin
  if not Enabled then Exit;
  FPointerLocation := Point(X, Y);
  DX := X - FMouseOrigin.X; DY := Y - FMouseOrigin.Y;
  if (FDragMode <> nfdmNone) and not FDragMoved then FDragMoved := Abs(DX) + Abs(DY) >= ScaleValue(FFinancial.InteractionOptions.DragPanThreshold);
  if (FDragMode <> nfdmNone) and FDragMoved then
  begin
    Scene := TNimbusFinancialBusinessRenderer.Layout(CreateRenderContext(ClientRect));
    case FDragMode of
      nfdmPan:
        begin FFinancial.Viewport.SetVisibleRange(FStartFirst - Round(DX * FFinancial.Viewport.VisibleCount / Max(1, Scene.PricePlot.Width)), FFinancial.Viewport.VisibleCount); if Assigned(FOnViewportChanged) then FOnViewportChanged(Self) end;
      nfdmPanelResize:
        ResizePanels(DY);
      nfdmPanelMove:
        begin Hit := HitTestChart(Point(X, Y)); if (Hit.FinancialArea in [nfhaPanelHeader, nfhaPanelCollapse, nfhaPanelClose, nfhaPanelPin, nfhaPanelSettings, nfhaCandle, nfhaPlot]) and (Hit.SeriesIndex >= 0) and (Hit.SeriesIndex < FFinancial.Panels.Count) and not FFinancial.Panels[Hit.SeriesIndex].IsPinned then FMoveTarget := Hit.SeriesIndex end;
      nfdmSideResize:
        begin
          SidePanel := FFinancial.SidePanels[FPressedHit.SeriesIndex]; Delta := DX;
          if SidePanel.Position = nfsppRight then Delta := -Delta;
          NewWidth := EnsureRange(FStartWidth + Round(Delta * 96 / Max(1, CurrentPPI)), SidePanel.MinimumWidth, SidePanel.MaximumWidth);
          if FFinancial.Options.SidePanelLayoutMode = nfslColumns then SidePanel.Width := NewWidth
          else if SidePanel.Position = nfsppLeft then FFinancial.Options.LeftSidePanelAreaWidth := NewWidth
          else FFinancial.Options.RightSidePanelAreaWidth := NewWidth;
        end;
      nfdmSideHeight:
        begin
          Total := FStartHeight + FNextHeight; NewHeight := EnsureRange(FStartHeight + DY, Double(ScaleValue(40)), Max(Double(ScaleValue(40)), Total - ScaleValue(40)));
          FFinancial.SidePanels.BeginUpdate;
          try
            FFinancial.SidePanels[FPressedHit.SeriesIndex].PreferredHeight := Round((FStartWeight + FNextWeight) * NewHeight / Max(1.0, Total));
            FFinancial.SidePanels[FNextPanel].PreferredHeight := Round((FStartWeight + FNextWeight) * (Total - NewHeight) / Max(1.0, Total));
          finally FFinancial.SidePanels.EndUpdate end;
        end;
      nfdmAnnotation:
        begin
          Annotation := FFinancial.Annotations[FPressedHit.ElementIndex];
          for PL in Scene.Panels do if PL.PanelIndex = FPressedHit.SeriesIndex then
          begin
            Delta := Round(DX * FFinancial.Viewport.VisibleCount / Max(1, PL.Plot.Width));
            Change := TNimbusFinancialBusinessRenderer.YValue(FFinancial.Panels[PL.PanelIndex], PL, Y) - TNimbusFinancialBusinessRenderer.YValue(FFinancial.Panels[PL.PanelIndex], PL, FMouseOrigin.Y);
            Annotation.StartValue := FAnnotationStart + Change; Annotation.EndValue := FAnnotationEnd + Change;
            if Annotation.CoordinateMode = nfcmIndex then begin Annotation.StartIndex := Max(0, FAnnotationFirst + Delta); Annotation.EndIndex := Max(0, FAnnotationLast + Delta) end
            else if Length(FFinancial.Candles) > 0 then begin Annotation.StartTime := FFinancial.Candles[EnsureRange(FAnnotationFirst + Delta, 0, High(FFinancial.Candles))].Time; Annotation.EndTime := FFinancial.Candles[EnsureRange(FAnnotationLast + Delta, 0, High(FFinancial.Candles))].Time end;
            Break;
          end;
        end;
      nfdmRange: begin Hit := HitTestChart(Point(X, Y)); if Hit.FinancialArea = nfhaCandle then FFinancial.SelectRange(FRangeAnchor, Hit.PointIndex) end;
    end;
    if FDragMode = nfdmPanelMove then
    begin FFinancial.DragPanelIndex := FPressedHit.SeriesIndex; FFinancial.DropPanelIndex := FMoveTarget; FFinancial.DragOffsetY := DY end;
    Invalidate; Exit;
  end;
  Hit := HitTestChart(Point(X, Y));
  if Hit.FinancialArea = nfhaSidePanelItem then DispatchRowEvent(Hit, nfraHovered, nfioMouse, mbLeft, Shift)
  else begin FHoverRowPanel := ''; FHoverRowKey := ''; FHoverRowPanelIndex := -1; FHoverRowIndex := -1 end;
  case Hit.FinancialArea of
    nfhaPanelSeparator, nfhaSidePanelSeparator: Cursor := crVSplit;
    nfhaSidePanelSplitter: Cursor := crHSplit;
  else Cursor := crDefault end;
  OldHover := FFinancial.HoveredIndex; FFinancial.HoveredIndex := -1;
  if Hit.FinancialArea in [nfhaCandle, nfhaMarker] then FFinancial.HoveredIndex := Hit.PointIndex;
  FFinancial.CrosshairLocation := Point(X, Y); FFinancial.CrosshairVisible := Hit.FinancialArea = nfhaCandle;
  if (OldHover <> FFinancial.HoveredIndex) and (FFinancial.HoveredIndex >= 0) then
  begin
    Index := FFinancial.HoveredIndex; if Assigned(FOnCandleHovered) then FOnCandleHovered(Self, Index, FFinancial.Candles[Index]);
    if not FFinancial.Options.LockDetailsOnSelection or (FFinancial.SelectedIndex < 0) then FFinancial.RefreshProductiveSidePanels;
    SyncScrollBars;
  end;
  if FFinancial.Options.ShowToolTips and (Hit.Text <> '') then FToolTip.SetToolTip(Self, Hit.Text) else FToolTip.ClearInfo(Self);
  if Assigned(FOnCrosshairChanged) then FOnCrosshairChanged(Self);
  Invalidate; if Assigned(OnMouseMove) then OnMouseMove(Self, Shift, X, Y);
end;

procedure TThemedFinancialBusinessChart.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var Hit, Pressed: TNimbusChartHit; Mode: TNimbusFinancialDragMode; Moved: Boolean;
begin
  if not Enabled then begin CancelFinancialDrag; Exit end;
  Hit := HitTestChart(Point(X, Y)); Pressed := FPressedHit; Mode := FDragMode; Moved := FDragMoved;
  CancelFinancialDrag;
  if Moved then
  begin
    if (Mode = nfdmPanelMove) and (FMoveTarget >= 0) then MovePanel(FFinancial.Panels[Pressed.SeriesIndex].Key, FMoveTarget);
    if Mode = nfdmPanelResize then NotifyPanelAction(nfpaResized, Pressed.SeriesIndex, False);
    if Mode in [nfdmSideResize, nfdmSideHeight] then NotifyPanelAction(nfpaResized, Pressed.SeriesIndex, True);
    if FAutoSave and (Mode in [nfdmPanelMove, nfdmPanelResize, nfdmSideResize, nfdmSideHeight]) then SavePanelUserProfileToFile(GetProfilePath);
  end
  else if Button = mbRight then
  begin if not DispatchRowEvent(Hit, nfraContextMenu, nfioMouse, mbRight, Shift) then ShowPanelMenu(Hit, ClientToScreen(Point(X, Y))) end
  else if (Button = mbLeft) and Pressed.SameElement(Hit) then InvokeHit(Hit, Shift);
  if Assigned(OnMouseUp) then OnMouseUp(Self, Button, Shift, X, Y);
end;

procedure TThemedFinancialBusinessChart.Click;
begin if not FDragMoved then inherited end;
procedure TThemedFinancialBusinessChart.DblClick;
var Hit: TNimbusChartHit;
begin
  Hit := HitTestChart(FPointerLocation); DispatchRowEvent(Hit, nfraDoubleClicked, nfioMouse, mbLeft, FPointerShift); inherited;
end;

function TThemedFinancialBusinessChart.DispatchRowEvent(const Hit: TNimbusChartHit; const Action: TNimbusFinancialRowAction;
  const Origin: TNimbusFinancialInputOrigin; const Button: TMouseButton; const Shift: TShiftState): Boolean;
var Panel: TNimbusFinancialSidePanel; Item: TNimbusFinancialPanelItem; Info: TNimbusFinancialRowEventInfo;
  LocalHandler, GlobalHandler: TNimbusFinancialRowEvent; Legacy: TNimbusFinancialHitEvent; I: Integer;
begin
  Result := False;
  if (Hit.FinancialArea <> nfhaSidePanelItem) or (Hit.SeriesIndex < 0) or (Hit.SeriesIndex >= FFinancial.SidePanels.Count) then Exit;
  Panel := FFinancial.SidePanels[Hit.SeriesIndex];
  if not Panel.Visible or (Panel.State <> nfspsExpanded) or (Hit.PointIndex < 0) or (Hit.PointIndex >= Panel.Items.Count) then Exit;
  Item := Panel.Items[Hit.PointIndex]; if not Item.Visible or (Item.Kind = nfpiSeparator) then Exit;
  Info := Default(TNimbusFinancialRowEventInfo); Info.Action := Action; Info.Origin := Origin;
  Info.PanelIndex := Panel.Index; Info.PanelKey := Panel.Key; Info.PanelTitle := Panel.Title; Info.PanelKind := Panel.Kind;
  Info.Symbol := FFinancial.Options.Symbol; Info.Exchange := FFinancial.Options.Exchange;
  Info.RowIndex := Item.Index; Info.RowKey := Item.Key; Info.RowKind := Item.Kind; Info.Text := Item.Text; Info.Value := Item.Value;
  Info.SecondaryValue := Item.SecondaryValue; Info.NumericValue := Item.NumericValue; Info.ChangeValue := Item.ChangeValue;
  Info.ChangePercent := Item.ChangePercent; Info.Tag := Item.Tag; Info.Values := Copy(Item.Values); Info.CandleIndex := Item.CandleIndex;
  Info.Button := Button; Info.Shift := Shift; Info.Location := Point(Round(Hit.Location.X), Round(Hit.Location.Y));
  if Origin <> nfioMouse then Info.Location := Point(-1, -1);
  for I := 0 to Item.Index - 1 do if Panel.Items[I].Visible and (Panel.Items[I].Kind <> nfpiSeparator) then Inc(Info.VisibleRowIndex);
  Info.HasCandle := (Info.CandleIndex >= 0) and (Info.CandleIndex < Length(FFinancial.Candles));
  if Info.HasCandle then
  begin
    Info.CandleTime := FFinancial.Candles[Info.CandleIndex].Time; Info.Open := FFinancial.Candles[Info.CandleIndex].Open;
    Info.High := FFinancial.Candles[Info.CandleIndex].High; Info.Low := FFinancial.Candles[Info.CandleIndex].Low;
    Info.Close := FFinancial.Candles[Info.CandleIndex].Close; Info.Volume := FFinancial.Candles[Info.CandleIndex].Volume;
  end;
  case Action of
    nfraClicked: begin LocalHandler := Panel.OnRowClicked; GlobalHandler := FOnRowClicked end;
    nfraDoubleClicked: begin LocalHandler := Panel.OnRowDoubleClicked; GlobalHandler := FOnRowDoubleClicked end;
    nfraHovered: begin LocalHandler := Panel.OnRowHovered; GlobalHandler := FOnRowHovered end;
  else LocalHandler := Panel.OnRowContextMenu; GlobalHandler := FOnRowContextMenu end;
  Legacy := nil; if Action = nfraClicked then Legacy := FOnSidePanelItemClicked;
  if Action = nfraHovered then
  begin
    if (FHoverRowPanel = Info.PanelKey) and (FHoverRowKey = Info.RowKey) and (FHoverRowPanelIndex = Info.PanelIndex) and (FHoverRowIndex = Info.RowIndex) then Exit(True);
    FHoverRowPanel := Info.PanelKey; FHoverRowKey := Info.RowKey; FHoverRowPanelIndex := Info.PanelIndex; FHoverRowIndex := Info.RowIndex;
  end
  else FocusSideRow(Panel, Item);
  Result := True;
  if Assigned(LocalHandler) then LocalHandler(Self, Info);
  if Assigned(GlobalHandler) then GlobalHandler(Self, Info);
  if Assigned(Legacy) then Legacy(Self, Hit);
end;

procedure TThemedFinancialBusinessChart.NotifyPanelAction(const Action: TNimbusFinancialPanelAction; const PanelIndex: Integer; const IsSidePanel: Boolean);
var Info: TNimbusFinancialPanelActionInfo; Panel: TNimbusFinancialPanel; Side: TNimbusFinancialSidePanel;
  LocalHandler, GlobalHandler: TNimbusFinancialPanelActionEvent; Legacy: TNimbusFinancialPanelEvent;
begin
  Info := Default(TNimbusFinancialPanelActionInfo); Info.Action := Action; Info.IsSidePanel := IsSidePanel;
  Info.PanelIndex := PanelIndex; Legacy := nil; Panel := nil;
  if IsSidePanel then
  begin
    if (PanelIndex < 0) or (PanelIndex >= FFinancial.SidePanels.Count) then Exit;
    Side := FFinancial.SidePanels[PanelIndex]; LocalHandler := Side.OnAction; Info.PanelKey := Side.Key; Info.Title := Side.Title;
    Info.Tag := Side.Tag; Info.Pinned := Side.Pinned; Info.ScrollOffset := Side.ScrollOffset; Info.Width := Side.Width; Info.PreferredHeight := Side.PreferredHeight;
    if FFinancial.Options.SidePanelLayoutMode = nfslStacked then
      if (Side.Position = nfsppLeft) and (FFinancial.Options.LeftSidePanelAreaWidth > 0) then Info.Width := FFinancial.Options.LeftSidePanelAreaWidth
      else if (Side.Position = nfsppRight) and (FFinancial.Options.RightSidePanelAreaWidth > 0) then Info.Width := FFinancial.Options.RightSidePanelAreaWidth;
  end
  else
  begin
    if (PanelIndex < 0) or (PanelIndex >= FFinancial.Panels.Count) then Exit;
    Panel := FFinancial.Panels[PanelIndex]; LocalHandler := Panel.OnAction; Info.PanelKey := Panel.Key; Info.Title := Panel.Title;
    Info.Tag := Panel.Tag; Info.Pinned := Panel.IsPinned; Info.PreferredHeight := Panel.PreferredHeight;
    case Action of
      nfpaCollapsed: Legacy := FOnPanelCollapsed; nfpaExpanded: Legacy := FOnPanelExpanded; nfpaClosed: Legacy := FOnPanelClosed;
      nfpaPinned: Legacy := FOnPanelPinned; nfpaUnpinned: Legacy := FOnPanelUnpinned; nfpaResized: Legacy := FOnPanelResized;
      nfpaMoved: Legacy := FOnPanelMoved; nfpaSettingsRequested: Legacy := FOnPanelSettingsRequested;
    end;
  end;
  GlobalHandler := FOnPanelAction;
  if Assigned(Legacy) then Legacy(Self, Panel);
  if Assigned(LocalHandler) then LocalHandler(Self, Info);
  if Assigned(GlobalHandler) then GlobalHandler(Self, Info);
end;

procedure TThemedFinancialBusinessChart.FocusSideRow(Panel: TNimbusFinancialSidePanel; Item: TNimbusFinancialPanelItem);
var Scene: TNimbusFinancialScene; SL: TNimbusFinancialSidePanelLayout; I, Top, Height, Offset: Integer;
begin
  FRowFocusPanel := Panel.Key; FRowFocusKey := Item.Key; FFinancial.FocusedSidePanelKey := Panel.Key; FFinancial.FocusedRowKey := Item.Key;
  FRowFocusPanelIndex := Panel.Index; FRowFocusIndex := Item.Index; FFinancial.FocusedSidePanelIndex := Panel.Index; FFinancial.FocusedRowIndex := Item.Index;
  Top := 0; for I := 0 to Item.Index - 1 do if Panel.Items[I].Visible then Inc(Top, ScaleValue(Panel.Items[I].Height));
  Height := ScaleValue(Item.Height); Offset := Panel.ScrollOffset;
  Scene := TNimbusFinancialBusinessRenderer.Layout(CreateRenderContext(Rect(0, 0, Width, Self.Height)));
  for SL in Scene.SidePanels do if SL.PanelIndex = Panel.Index then
  begin
    if Top < Offset then Offset := Top else if Top + Height > Offset + SL.Body.Height then Offset := Top + Height - SL.Body.Height;
    ScrollSidePanel(Panel.Index, Offset); Break;
  end;
  Invalidate;
end;

function TThemedFinancialBusinessChart.ActivateSidePanelItem(const PanelKey, RowKey: string): Boolean;
var Panel: TNimbusFinancialSidePanel; Item: TNimbusFinancialPanelItem; Hit: TNimbusChartHit;
begin
  Result := False; FFinancial.EnsureCache(FinancialData);
  Panel := FFinancial.SidePanels.FindByKey(PanelKey); if Panel = nil then Exit;
  Item := Panel.Items.FindByKey(RowKey); if Item = nil then Exit;
  Hit := TNimbusChartHit.None; Hit.FinancialArea := nfhaSidePanelItem; Hit.Area := nchaLegend; Hit.SeriesIndex := Panel.Index; Hit.PointIndex := Item.Index;
  Result := DispatchRowEvent(Hit, nfraClicked, nfioProgrammatic, mbLeft, []);
end;

function TThemedFinancialBusinessChart.NavigateSideRow(var Key: Word; const Shift: TShiftState): Boolean;
var Panel: TNimbusFinancialSidePanel; Item: TNimbusFinancialPanelItem; I, Step: Integer; Hit: TNimbusChartHit;
begin
  Result := False; if FRowFocusPanelIndex < 0 then Exit;
  Panel := nil;
  if FRowFocusPanel <> '' then Panel := FFinancial.SidePanels.FindByKey(FRowFocusPanel)
  else if FRowFocusPanelIndex < FFinancial.SidePanels.Count then Panel := FFinancial.SidePanels[FRowFocusPanelIndex];
  if (Panel = nil) or not Panel.Visible or (Panel.State <> nfspsExpanded) then Exit;
  Item := nil;
  if FRowFocusKey <> '' then Item := Panel.Items.FindByKey(FRowFocusKey)
  else if (FRowFocusIndex >= 0) and (FRowFocusIndex < Panel.Items.Count) then Item := Panel.Items[FRowFocusIndex];
  if Item = nil then Exit;
  if (Key = VK_RETURN) or (Key = VK_SPACE) or (Key = VK_APPS) or ((Key = VK_F10) and (ssShift in Shift)) then
  begin
    Hit := TNimbusChartHit.None; Hit.FinancialArea := nfhaSidePanelItem; Hit.Area := nchaLegend; Hit.SeriesIndex := Panel.Index; Hit.PointIndex := Item.Index;
    if (Key = VK_APPS) or (Key = VK_F10) then Result := DispatchRowEvent(Hit, nfraContextMenu, nfioKeyboard, mbRight, Shift)
    else Result := DispatchRowEvent(Hit, nfraClicked, nfioKeyboard, mbLeft, Shift);
    if Result then Key := 0; Exit;
  end;
  if not (Key in [VK_UP, VK_DOWN, VK_HOME, VK_END]) then Exit;
  Step := 1; if Key in [VK_UP, VK_END] then Step := -1;
  I := Item.Index + Step; if Key = VK_HOME then I := 0 else if Key = VK_END then I := Panel.Items.Count - 1;
  while (I >= 0) and (I < Panel.Items.Count) do
  begin
    Item := Panel.Items[I]; if Item.Visible and (Item.Kind <> nfpiSeparator) then begin FocusSideRow(Panel, Item); Break end;
    Inc(I, Step);
  end;
  Key := 0; Result := True;
end;

procedure TThemedFinancialBusinessChart.InvokeHit(const Hit: TNimbusChartHit; const Shift: TShiftState);
var Panel: TNimbusFinancialPanel; Side: TNimbusFinancialSidePanel; S: TNimbusFinancialIndicatorSnapshot;
begin
  Panel := nil; if (Hit.SeriesIndex >= 0) and (Hit.SeriesIndex < FFinancial.Panels.Count) then Panel := FFinancial.Panels[Hit.SeriesIndex];
  case Hit.FinancialArea of
    nfhaCandle:
      begin
        if (ssShift in Shift) and (FFinancial.SelectedIndex >= 0) then FFinancial.SelectRange(FFinancial.SelectedIndex, Hit.PointIndex)
        else FFinancial.SelectIndex(Hit.PointIndex);
        inherited SetSelected(Hit); FFinancial.RefreshProductiveSidePanels; UpdateAccessibility;
        if Assigned(FOnCandleClicked) then FOnCandleClicked(Self, Hit.PointIndex, FFinancial.Candles[Hit.PointIndex]);
      end;
    nfhaRangeButton: begin FFinancial.ApplyRange(FFinancial.RangeSelector.Items[Hit.ElementIndex]); if Assigned(FOnRangeChanged) then FOnRangeChanged(Self); if Assigned(FOnViewportChanged) then FOnViewportChanged(Self) end;
    nfhaPanelHeader: NotifyPanelAction(nfpaHeaderClicked, Hit.SeriesIndex, False);
    nfhaPanelCollapse: if (Panel <> nil) and Panel.AllowCollapse and FFinancial.Options.AllowPanelLayoutChanges then
      if Panel.State = nfpsCollapsed then begin Panel.State := nfpsExpanded; NotifyPanelAction(nfpaExpanded, Panel.Index, False) end
      else begin Panel.State := nfpsCollapsed; NotifyPanelAction(nfpaCollapsed, Panel.Index, False) end;
    nfhaPanelClose: if (Panel <> nil) and Panel.AllowClose and not Panel.IsPinned and FFinancial.Options.AllowPanelLayoutChanges then
      begin Panel.State := nfpsHidden; NotifyPanelAction(nfpaClosed, Panel.Index, False) end;
    nfhaPanelPin: if (Panel <> nil) and Panel.AllowPin and FFinancial.Options.AllowPanelLayoutChanges then
      begin Panel.IsPinned := not Panel.IsPinned; if Panel.IsPinned then begin NotifyPanelAction(nfpaPinned, Panel.Index, False) end else NotifyPanelAction(nfpaUnpinned, Panel.Index, False) end;
    nfhaPanelSettings: if Panel <> nil then EditPanelSettings(Panel);
    nfhaMarker: if Assigned(FOnMarkerClicked) then FOnMarkerClicked(Self, Hit);
    nfhaAnnotation: begin inherited SetSelected(Hit); if Assigned(FOnAnnotationClicked) then FOnAnnotationClicked(Self, Hit) end;
    nfhaLegend:
      begin
        if (Hit.ElementIndex < 0) or (Hit.ElementIndex >= Length(FFinancial.Snapshots)) then Exit;
        S := FFinancial.Snapshots[Hit.ElementIndex];
        if Assigned(FOnIndicatorClicked) then FOnIndicatorClicked(Self, Hit);
        if S.DefinitionIndex >= 0 then FFinancial.Indicators[S.DefinitionIndex].Visible := False
        else case S.Kind of
          nfikSma: FFinancial.Options.ShowSimpleMovingAverage := False;
          nfikEma: FFinancial.Options.ShowExponentialMovingAverage := False;
          nfikBollinger: FFinancial.Options.ShowBollingerBands := False;
          nfikVwap: FFinancial.Options.ShowVwap := False;
          nfikRsi: FFinancial.Options.ShowRsi := False;
          nfikMacd: FFinancial.Options.ShowMacd := False;
          nfikStochastic: FFinancial.Options.ShowStochastic := False;
          nfikAtr: FFinancial.Options.ShowAtr := False;
        end;
      end;
    nfhaSidePanelHeader: NotifyPanelAction(nfpaHeaderClicked, Hit.SeriesIndex, True);
    nfhaSidePanelCollapse, nfhaSidePanelPin:
      begin
        Side := FFinancial.SidePanels[Hit.SeriesIndex];
        if Hit.FinancialArea = nfhaSidePanelPin then begin Side.Pinned := not Side.Pinned; if not Side.Pinned then Side.State := nfspsAutoHidden else Side.State := nfspsExpanded end
        else if Side.State = nfspsExpanded then Side.State := nfspsCollapsed else Side.State := nfspsExpanded;
        if Hit.FinancialArea = nfhaSidePanelPin then
        begin if Side.Pinned then NotifyPanelAction(nfpaPinned, Side.Index, True) else NotifyPanelAction(nfpaUnpinned, Side.Index, True) end
        else if Side.State = nfspsExpanded then NotifyPanelAction(nfpaExpanded, Side.Index, True) else NotifyPanelAction(nfpaCollapsed, Side.Index, True);
      end;
    nfhaSidePanelItem: DispatchRowEvent(Hit, nfraClicked, nfioMouse, mbLeft, Shift);
  else if (Hit.FinancialArea in [nfhaNone, nfhaPlot]) and FFinancial.Options.ClearSelectionOnEmptyPlotClick then ClearSelection;
  end;
  if FAutoSave and (Hit.FinancialArea in [nfhaPanelCollapse, nfhaPanelClose, nfhaPanelPin, nfhaSidePanelCollapse, nfhaSidePanelPin]) then SavePanelUserProfileToFile(GetProfilePath);
  SyncScrollBars;
end;

function TThemedFinancialBusinessChart.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
var Point: TPoint; Scene: TNimbusFinancialScene; SL: TNimbusFinancialSidePanelLayout; Steps: Integer;
begin
  Result := False; if not Enabled then Exit; Point := ScreenToClient(MousePos); Scene := TNimbusFinancialBusinessRenderer.Layout(CreateRenderContext(ClientRect));
  for SL in Scene.SidePanels do if SL.Body.Contains(Point) then
  begin ScrollSidePanel(SL.PanelIndex, FFinancial.SidePanels[SL.PanelIndex].ScrollOffset - Round(WheelDelta / 120 * ScaleValue(72))); Exit(True) end;
  if not Scene.Graph.Contains(Point) then Exit; Steps := EnsureRange(Round(WheelDelta / 120), -20, 20);
  if (ssShift in Shift) and FFinancial.InteractionOptions.EnableShiftMouseWheelPan then FFinancial.Viewport.Pan(-Steps * FFinancial.InteractionOptions.MouseWheelPanCandles)
  else if (not (ssCtrl in Shift) and FFinancial.InteractionOptions.EnableMouseWheelZoom) or ((ssCtrl in Shift) and FFinancial.InteractionOptions.EnableCtrlMouseWheelZoom) then
    FFinancial.Viewport.Zoom(Power(1.18, Steps), (Point.X - Scene.PricePlot.Left) / Max(1, Scene.PricePlot.Width))
  else Exit;
  if Assigned(FOnViewportChanged) then FOnViewportChanged(Self); Result := True;
end;

procedure TThemedFinancialBusinessChart.KeyDown(var Key: Word; Shift: TShiftState);
var Index: Integer; Hit: TNimbusChartHit;
begin
  if Assigned(OnKeyDown) then OnKeyDown(Self, Key, Shift);
  if not FFinancial.InteractionOptions.EnableKeyboardNavigation then Exit;
  if NavigateSideRow(Key, Shift) then Exit;
  FFinancial.EnsureCache(FinancialData); Index := FFinancial.SelectedIndex;
  case Key of
    VK_ESCAPE: if FFinancial.Options.ClearSelectionOnEscape then ClearSelection;
    VK_HOME: begin FFinancial.Viewport.ScrollToStart; SelectCandleForAccessibility(0) end;
    VK_END: begin FFinancial.Viewport.ScrollToEnd; SelectCandleForAccessibility(High(FFinancial.Candles)) end;
    VK_LEFT, VK_RIGHT:
      begin if Index < 0 then Index := FFinancial.Viewport.FirstVisibleIndex; if Key = VK_LEFT then Dec(Index) else Inc(Index); SelectCandleForAccessibility(EnsureRange(Index, 0, Max(0, High(FFinancial.Candles)))) end;
    VK_PRIOR: FFinancial.Viewport.Pan(-Max(1, Round(FFinancial.Viewport.VisibleCount * FFinancial.InteractionOptions.PagePanRatio)));
    VK_NEXT: FFinancial.Viewport.Pan(Max(1, Round(FFinancial.Viewport.VisibleCount * FFinancial.InteractionOptions.PagePanRatio)));
    VK_ADD, VK_OEM_PLUS: FFinancial.Viewport.Zoom(FFinancial.InteractionOptions.KeyboardZoomFactor, 0.5);
    VK_SUBTRACT, VK_OEM_MINUS: FFinancial.Viewport.Zoom(1 / FFinancial.InteractionOptions.KeyboardZoomFactor, 0.5);
    VK_DELETE:
      begin Hit := SelectedResult; if (Hit.FinancialArea = nfhaAnnotation) and (Hit.ElementIndex >= 0) and (Hit.ElementIndex < FFinancial.Annotations.Count) and not FFinancial.Annotations[Hit.ElementIndex].Locked then begin FFinancial.Annotations.Delete(Hit.ElementIndex); ClearSelection end end;
  else Exit;
  end;
  Key := 0; if Assigned(FOnViewportChanged) then FOnViewportChanged(Self);
end;

procedure TThemedFinancialBusinessChart.BeginUpdate;
begin Inc(FUpdateCount); inherited BeginUpdate end;
procedure TThemedFinancialBusinessChart.EndUpdate;
begin
  if FUpdateCount = 0 then raise EInvalidOperation.Create('Unbalanced financial EndUpdate');
  Dec(FUpdateCount); inherited EndUpdate; if FUpdateCount = 0 then FinancialChanged(Self);
end;
function TThemedFinancialBusinessChart.GetIsUpdating: Boolean;
begin Result := FUpdateCount > 0 end;
procedure TThemedFinancialBusinessChart.RefreshProductiveSidePanels;
begin FFinancial.EnsureCache(FinancialData); FFinancial.RefreshProductiveSidePanels; SyncScrollBars; Invalidate end;
procedure TThemedFinancialBusinessChart.LoadPanelUserProfileFromFile(const FileName: string);
begin LoadPanelUserProfile(TFile.ReadAllText(FileName, TEncoding.UTF8)) end;
procedure TThemedFinancialBusinessChart.SavePanelUserProfileToDefaultPath;
begin SavePanelUserProfileToFile(GetProfilePath) end;
function TThemedFinancialBusinessChart.TryLoadPanelUserProfileFromDefaultPath: Boolean;
begin Result := TFile.Exists(GetProfilePath) and TryLoadPanelUserProfileFromFile(GetProfilePath) end;
function TThemedFinancialBusinessChart.GetAccessibleCandleDescription(const Index: Integer): string;
var P: TNimbusFinancialDataPoint;
begin
  FFinancial.EnsureCache(FinancialData); Result := '';
  if (Index < 0) or (Index >= Length(FFinancial.Candles)) then Exit;
  P := FFinancial.Candles[Index];
  Result := DateTimeToStr(P.Time) + Format(' Open %.4f High %.4f Low %.4f Close %.4f Volume %.0f.', [P.Open, P.High, P.Low, P.Close, P.Volume]);
end;
function TThemedFinancialBusinessChart.GetAccessibleSelectedCandleDescription: string;
begin Result := GetAccessibleCandleDescription(FFinancial.SelectedIndex) end;
function TThemedFinancialBusinessChart.GetFinancialTitle: string;
begin Result := Model.Title end;
procedure TThemedFinancialBusinessChart.SetFinancialTitle(const Value: string);
begin Model.Title := Value end;
function TThemedFinancialBusinessChart.GetFinancialSubtitle: string;
begin Result := Model.Subtitle end;
procedure TThemedFinancialBusinessChart.SetFinancialSubtitle(const Value: string);
begin Model.Subtitle := Value end;
function TThemedFinancialBusinessChart.GetShowRangeSelector: Boolean;
begin Result := FFinancial.RangeSelector.Visible end;
procedure TThemedFinancialBusinessChart.SetShowRangeSelector(const Value: Boolean);
begin FFinancial.RangeSelector.Visible := Value end;
function TThemedFinancialBusinessChart.GetPanelLayout: TNimbusFinancialScene;
begin Result := TNimbusFinancialBusinessRenderer.Layout(CreateRenderContext(Rect(0, 0, Width, Height))) end;
function TThemedFinancialBusinessChart.GetThemePresetDisplayName: string;
const Names: array[TNimbusFinancialThemePreset] of string = ('Nimbus Dark', 'Nimbus Light', 'Trading Dark', 'Trading Blue', 'Terminal Black', 'Office Blue', 'Nord', 'Dracula', 'High Contrast');
begin Result := Names[FThemePreset] end;

procedure TThemedFinancialBusinessChart.ResetView;
begin inherited; if FFinancial <> nil then begin FFinancial.EnsureCache(FinancialData); FFinancial.Viewport.ZoomToFit; if Assigned(FOnViewportChanged) then FOnViewportChanged(Self) end end;
procedure TThemedFinancialBusinessChart.ClearSelection;
begin
  inherited; FRowFocusPanel := ''; FRowFocusKey := ''; FRowFocusPanelIndex := -1; FRowFocusIndex := -1;
  if FFinancial <> nil then
  begin
    FFinancial.FocusedSidePanelKey := ''; FFinancial.FocusedRowKey := ''; FFinancial.FocusedSidePanelIndex := -1; FFinancial.FocusedRowIndex := -1;
    FFinancial.ClearSelection; if Assigned(FOnSelectionCleared) then FOnSelectionCleared(Self); UpdateAccessibility; Invalidate;
  end;
end;
procedure TThemedFinancialBusinessChart.SelectCandleForAccessibility(const Index: Integer);
var Hit: TNimbusChartHit;
begin
  FFinancial.EnsureCache(FinancialData);
  if not FFinancial.AccessibilityOptions.EnableKeyboardCandleSelection or (Index < 0) or (Index >= Length(FFinancial.Candles)) then Exit;
  FFinancial.SelectIndex(Index); if (Index < FFinancial.Viewport.FirstVisibleIndex) or (Index > FFinancial.Viewport.LastVisibleIndex) then FFinancial.Viewport.CenterOnIndex(Index);
  Hit := TNimbusChartHit.None; Hit.Area := nchaPoint; Hit.FinancialArea := nfhaCandle; Hit.PointIndex := Index; inherited SetSelected(Hit);
  FFinancial.RefreshProductiveSidePanels; UpdateAccessibility;
end;
function TThemedFinancialBusinessChart.GetAccessibleSummary: string;
begin FFinancial.EnsureCache(FinancialData); Result := FFinancial.GetAccessibleSummary end;
procedure TThemedFinancialBusinessChart.UpdateAccessibility;
var Summary: string;
begin
  if FClosing or (FFinancial = nil) or not FFinancial.AccessibilityOptions.EnableScreenReaderSummary or not HandleAllocated then Exit;
  Summary := GetAccessibleSummary; SetWindowText(Handle, PChar(Summary)); NotifyWinEvent(EVENT_OBJECT_NAMECHANGE, Handle, OBJID_CLIENT, 0);
end;

procedure TThemedFinancialBusinessChart.ShowPanelMenu(const Hit: TNimbusChartHit; const Location: TPoint);
const Captions: array[0..6] of string = ('Settings...', 'Collapse / expand', 'Pin / unpin', 'Close panel', 'Move up', 'Move down', 'Reset layout');
var I: Integer; Item: TMenuItem;
begin
  if not FFinancial.Options.ShowPanelContextMenu or (Hit.SeriesIndex < 0) or (Hit.SeriesIndex >= FFinancial.Panels.Count) or
    not (Hit.FinancialArea in [nfhaCandle, nfhaPanelHeader, nfhaPanelSeparator, nfhaPriceAxis, nfhaLegend]) then Exit;
  FContextPanel := Hit.SeriesIndex; FPanelMenu.Items.Clear;
  for I := 0 to High(Captions) do begin Item := TMenuItem.Create(FPanelMenu); Item.Caption := Captions[I]; Item.Tag := I; Item.OnClick := ContextCommand; FPanelMenu.Items.Add(Item) end;
  FPanelMenu.Popup(Location.X, Location.Y);
end;
procedure TThemedFinancialBusinessChart.ContextCommand(Sender: TObject);
var Panel: TNimbusFinancialPanel; Hit: TNimbusChartHit;
begin
  if (FContextPanel < 0) or (FContextPanel >= FFinancial.Panels.Count) then Exit; Panel := FFinancial.Panels[FContextPanel];
  Hit := TNimbusChartHit.None; Hit.SeriesIndex := FContextPanel;
  case TMenuItem(Sender).Tag of
    0: EditPanelSettings(Panel);
    1: if Panel.AllowCollapse then begin Hit.FinancialArea := nfhaPanelCollapse; InvokeHit(Hit, []) end;
    2: if Panel.AllowPin then begin Hit.FinancialArea := nfhaPanelPin; InvokeHit(Hit, []) end;
    3: if Panel.AllowClose then begin Hit.FinancialArea := nfhaPanelClose; InvokeHit(Hit, []) end;
    4: MovePanel(Panel.Key, Panel.Index - 1);
    5: MovePanel(Panel.Key, Panel.Index + 1);
    6: ResetPanelLayout;
  end;
end;

function TThemedFinancialBusinessChart.MovePanel(const Key: string; const TargetIndex: Integer): Boolean;
var Panel: TNimbusFinancialPanel;
begin
  Result := False; Panel := FFinancial.Panels.FindByKey(Key);
  if (Panel = nil) or not FFinancial.Options.AllowPanelLayoutChanges or not Panel.AllowMove or Panel.IsPinned or (TargetIndex < 0) or (TargetIndex >= FFinancial.Panels.Count) then Exit;
  if FFinancial.Panels[TargetIndex].IsPinned or ((Panel.PanelType = nfptVolume) and not FFinancial.Options.AllowVolumePanelReorder) then Exit;
  Panel.Index := TargetIndex; Result := True; NotifyPanelAction(nfpaMoved, Panel.Index, False);
  if FAutoSave then SavePanelUserProfileToFile(GetProfilePath);
end;
procedure TThemedFinancialBusinessChart.EditPanelSettings(Panel: TNimbusFinancialPanel);
var Key: string;
begin
  if (Panel = nil) or not Panel.AllowSettings then Exit; Key := Panel.Key; NotifyPanelAction(nfpaSettingsRequested, Panel.Index, False);
  Panel := FFinancial.Panels.FindByKey(Key); if Panel = nil then Exit;
  if FFinancial.Options.ShowBuiltInIndicatorSettingsDialog then
    if EditNimbusFinancialPanel(Self, Panel, FFinancial.Options, Palette) and FAutoSave then SavePanelUserProfileToFile(GetProfilePath);
end;
procedure TThemedFinancialBusinessChart.ResetPanelLayout;
begin ApplyPanelLayoutPreset(nfplDefault) end;
procedure TThemedFinancialBusinessChart.ApplyPanelLayoutPreset(const Preset: TNimbusFinancialPanelLayoutPreset);
const Heights: array[TNimbusFinancialPanelLayoutPreset, 0..3] of Integer =
  ((360, 120, 150, 140), (320, 84, 96, 96), (420, 140, 180, 170), (460, 150, 160, 150), (420, 80, 80, 80));
var P: TNimbusFinancialPanel; Column: Integer; Keys: TArray<string>;
begin
  if not FFinancial.Options.AllowPanelLayoutChanges then Exit;
  FLayoutPreset := Preset; CancelFinancialDrag; FFinancial.Panels.BeginUpdate;
  try
    for var I := 0 to FFinancial.Panels.Count - 1 do
    begin
      P := FFinancial.Panels[I]; P.State := nfpsExpanded; P.IsPinned := P.PanelType = nfptPrice;
      P.AllowMove := not P.IsPinned; P.AllowClose := not P.IsPinned; P.AllowCollapse := not P.IsPinned; P.AllowResize := True;
      Column := 3; if P.PanelType = nfptPrice then Column := 0 else if P.PanelType = nfptVolume then Column := 1 else if P.PanelType = nfptOscillator then Column := 2;
      P.PreferredHeight := Heights[Preset, Column]; if (Preset = nfplMinimal) and not P.IsPinned then P.State := nfpsCollapsed;
    end;
    Keys := ['price', 'volume', 'macd', 'rsi', 'stochastic', 'atr'];
    if Preset = nfplTradingDesk then Keys := ['price', 'volume', 'rsi', 'macd', 'stochastic', 'atr'];
    for var I := 0 to High(Keys) do begin P := FFinancial.Panels.FindByKey(Keys[I]); if P <> nil then P.Index := Min(I, FFinancial.Panels.Count - 1) end;
  finally FFinancial.Panels.EndUpdate end;
  SyncScrollBars; if FAutoSave then SavePanelUserProfileToFile(GetProfilePath);
end;
function TThemedFinancialBusinessChart.SavePanelLayout: string;
begin Result := TNimbusFinancialProfiles.Save(FFinancial, True) end;
procedure TThemedFinancialBusinessChart.LoadPanelLayout(const Text: string);
begin
  CancelFinancialDrag; FUpdating := True;
  try TNimbusFinancialProfiles.Load(FFinancial, Text, True) finally FUpdating := False end;
  FinancialChanged(Self);
end;
function TThemedFinancialBusinessChart.SavePanelUserProfile: string;
begin Result := TNimbusFinancialProfiles.Save(FFinancial, False) end;
procedure TThemedFinancialBusinessChart.LoadPanelUserProfile(const Text: string);
begin
  CancelFinancialDrag; FUpdating := True;
  try TNimbusFinancialProfiles.Load(FFinancial, Text, False) finally FUpdating := False end;
  FThemeMode := nftmCustom; FinancialChanged(Self);
end;
procedure TThemedFinancialBusinessChart.SavePanelUserProfileToFile(const FileName: string);
var Directory: string;
begin Directory := ExtractFilePath(FileName); if Directory <> '' then TDirectory.CreateDirectory(Directory); TFile.WriteAllText(FileName, SavePanelUserProfile, TEncoding.UTF8) end;
function TThemedFinancialBusinessChart.TryLoadPanelUserProfileFromFile(const FileName: string): Boolean;
begin
  Result := False;
  try LoadPanelUserProfile(TFile.ReadAllText(FileName, TEncoding.UTF8)); Result := True
  except on E: Exception do begin FLastError := E.Message; if Assigned(FOnProfileLoadFailed) then FOnProfileLoadFailed(Self, E.Message) end end;
end;
function TThemedFinancialBusinessChart.GetProfilePath: string;
var Root: string;
begin
  if FProfilePath <> '' then Exit(FProfilePath); Root := GetEnvironmentVariable('LOCALAPPDATA'); if Root = '' then Root := TPath.GetHomePath;
  Result := TPath.Combine(Root, 'NimbusForms\FinancialChart.layout.json');
end;
procedure TThemedFinancialBusinessChart.RestoreProfile;
begin
  if FProfileRestored or not FAutoRestore or (csDesigning in ComponentState) or (csLoading in ComponentState) then Exit;
  FProfileRestored := True; if TFile.Exists(GetProfilePath) then TryLoadPanelUserProfileFromFile(GetProfilePath);
end;
procedure TThemedFinancialBusinessChart.SetProfilePath(const Value: string);
begin FProfilePath := Value; FProfileRestored := False; if HandleAllocated then RestoreProfile end;
procedure TThemedFinancialBusinessChart.SetAutoRestore(const Value: Boolean);
begin FAutoRestore := Value; if HandleAllocated then RestoreProfile end;

function TThemedFinancialBusinessChart.GetFinancialSymbol: string;
begin Result := FFinancial.Options.Symbol end;
procedure TThemedFinancialBusinessChart.SetFinancialSymbol(const Value: string);
begin FFinancial.Options.Symbol := Value end;

function TThemedFinancialBusinessChart.GetFinancialExchange: string;
begin Result := FFinancial.Options.Exchange end;
procedure TThemedFinancialBusinessChart.SetFinancialExchange(const Value: string);
begin FFinancial.Options.Exchange := Value end;

function TThemedFinancialBusinessChart.GetFinancialTimeFrame: TNimbusFinancialTimeFrame;
begin Result := FFinancial.Options.TimeFrame end;
procedure TThemedFinancialBusinessChart.SetFinancialTimeFrame(const Value: TNimbusFinancialTimeFrame);
begin FFinancial.Options.TimeFrame := Value end;

function TThemedFinancialBusinessChart.GetFinancialPriceMode: TNimbusFinancialPriceMode;
begin Result := FFinancial.Options.PriceMode end;
procedure TThemedFinancialBusinessChart.SetFinancialPriceMode(const Value: TNimbusFinancialPriceMode);
begin FFinancial.Options.PriceMode := Value end;

function TThemedFinancialBusinessChart.GetFinancialShowVolume: Boolean;
begin Result := FFinancial.Options.ShowVolume end;
procedure TThemedFinancialBusinessChart.SetFinancialShowVolume(const Value: Boolean);
begin FFinancial.Options.ShowVolume := Value end;

function TThemedFinancialBusinessChart.GetFinancialShowVolumeMovingAverage: Boolean;
begin Result := FFinancial.Options.ShowVolumeMovingAverage end;
procedure TThemedFinancialBusinessChart.SetFinancialShowVolumeMovingAverage(const Value: Boolean);
begin FFinancial.Options.ShowVolumeMovingAverage := Value end;

function TThemedFinancialBusinessChart.GetFinancialVolumeMovingAveragePeriod: Integer;
begin Result := FFinancial.Options.VolumeMovingAveragePeriod end;
procedure TThemedFinancialBusinessChart.SetFinancialVolumeMovingAveragePeriod(const Value: Integer);
begin FFinancial.Options.VolumeMovingAveragePeriod := Value end;

function TThemedFinancialBusinessChart.GetFinancialShowSimpleMovingAverage: Boolean;
begin Result := FFinancial.Options.ShowSimpleMovingAverage end;
procedure TThemedFinancialBusinessChart.SetFinancialShowSimpleMovingAverage(const Value: Boolean);
begin FFinancial.Options.ShowSimpleMovingAverage := Value end;

function TThemedFinancialBusinessChart.GetFinancialShowExponentialMovingAverage: Boolean;
begin Result := FFinancial.Options.ShowExponentialMovingAverage end;
procedure TThemedFinancialBusinessChart.SetFinancialShowExponentialMovingAverage(const Value: Boolean);
begin FFinancial.Options.ShowExponentialMovingAverage := Value end;

function TThemedFinancialBusinessChart.GetFinancialSimpleMovingAveragePeriods: string;
begin Result := FFinancial.Options.SimpleMovingAveragePeriods end;
procedure TThemedFinancialBusinessChart.SetFinancialSimpleMovingAveragePeriods(const Value: string);
begin FFinancial.Options.SimpleMovingAveragePeriods := Value end;

function TThemedFinancialBusinessChart.GetFinancialExponentialMovingAveragePeriods: string;
begin Result := FFinancial.Options.ExponentialMovingAveragePeriods end;
procedure TThemedFinancialBusinessChart.SetFinancialExponentialMovingAveragePeriods(const Value: string);
begin FFinancial.Options.ExponentialMovingAveragePeriods := Value end;

function TThemedFinancialBusinessChart.GetFinancialShowBollingerBands: Boolean;
begin Result := FFinancial.Options.ShowBollingerBands end;
procedure TThemedFinancialBusinessChart.SetFinancialShowBollingerBands(const Value: Boolean);
begin FFinancial.Options.ShowBollingerBands := Value end;

function TThemedFinancialBusinessChart.GetFinancialBollingerBandPeriods: string;
begin Result := FFinancial.Options.BollingerBandPeriods end;
procedure TThemedFinancialBusinessChart.SetFinancialBollingerBandPeriods(const Value: string);
begin FFinancial.Options.BollingerBandPeriods := Value end;

function TThemedFinancialBusinessChart.GetFinancialBollingerBandStandardDeviation: Double;
begin Result := FFinancial.Options.BollingerBandStandardDeviation end;
procedure TThemedFinancialBusinessChart.SetFinancialBollingerBandStandardDeviation(const Value: Double);
begin FFinancial.Options.BollingerBandStandardDeviation := Value end;

function TThemedFinancialBusinessChart.GetFinancialShowRsi: Boolean;
begin Result := FFinancial.Options.ShowRsi end;
procedure TThemedFinancialBusinessChart.SetFinancialShowRsi(const Value: Boolean);
begin FFinancial.Options.ShowRsi := Value end;

function TThemedFinancialBusinessChart.GetFinancialRsiPeriods: string;
begin Result := FFinancial.Options.RsiPeriods end;
procedure TThemedFinancialBusinessChart.SetFinancialRsiPeriods(const Value: string);
begin FFinancial.Options.RsiPeriods := Value end;

function TThemedFinancialBusinessChart.GetFinancialRsiOversoldLevel: Double;
begin Result := FFinancial.Options.RsiOversoldLevel end;
procedure TThemedFinancialBusinessChart.SetFinancialRsiOversoldLevel(const Value: Double);
begin FFinancial.Options.RsiOversoldLevel := Value end;

function TThemedFinancialBusinessChart.GetFinancialRsiOverboughtLevel: Double;
begin Result := FFinancial.Options.RsiOverboughtLevel end;
procedure TThemedFinancialBusinessChart.SetFinancialRsiOverboughtLevel(const Value: Double);
begin FFinancial.Options.RsiOverboughtLevel := Value end;

function TThemedFinancialBusinessChart.GetFinancialShowMacd: Boolean;
begin Result := FFinancial.Options.ShowMacd end;
procedure TThemedFinancialBusinessChart.SetFinancialShowMacd(const Value: Boolean);
begin FFinancial.Options.ShowMacd := Value end;

function TThemedFinancialBusinessChart.GetFinancialMacdFastPeriod: Integer;
begin Result := FFinancial.Options.MacdFastPeriod end;
procedure TThemedFinancialBusinessChart.SetFinancialMacdFastPeriod(const Value: Integer);
begin FFinancial.Options.MacdFastPeriod := Value end;

function TThemedFinancialBusinessChart.GetFinancialMacdSlowPeriod: Integer;
begin Result := FFinancial.Options.MacdSlowPeriod end;
procedure TThemedFinancialBusinessChart.SetFinancialMacdSlowPeriod(const Value: Integer);
begin FFinancial.Options.MacdSlowPeriod := Value end;

function TThemedFinancialBusinessChart.GetFinancialMacdSignalPeriod: Integer;
begin Result := FFinancial.Options.MacdSignalPeriod end;
procedure TThemedFinancialBusinessChart.SetFinancialMacdSignalPeriod(const Value: Integer);
begin FFinancial.Options.MacdSignalPeriod := Value end;

function TThemedFinancialBusinessChart.GetFinancialShowStochastic: Boolean;
begin Result := FFinancial.Options.ShowStochastic end;
procedure TThemedFinancialBusinessChart.SetFinancialShowStochastic(const Value: Boolean);
begin FFinancial.Options.ShowStochastic := Value end;

function TThemedFinancialBusinessChart.GetFinancialStochasticPeriod: Integer;
begin Result := FFinancial.Options.StochasticPeriod end;
procedure TThemedFinancialBusinessChart.SetFinancialStochasticPeriod(const Value: Integer);
begin FFinancial.Options.StochasticPeriod := Value end;

function TThemedFinancialBusinessChart.GetFinancialStochasticSmoothKPeriod: Integer;
begin Result := FFinancial.Options.StochasticSmoothKPeriod end;
procedure TThemedFinancialBusinessChart.SetFinancialStochasticSmoothKPeriod(const Value: Integer);
begin FFinancial.Options.StochasticSmoothKPeriod := Value end;

function TThemedFinancialBusinessChart.GetFinancialStochasticDPeriod: Integer;
begin Result := FFinancial.Options.StochasticDPeriod end;
procedure TThemedFinancialBusinessChart.SetFinancialStochasticDPeriod(const Value: Integer);
begin FFinancial.Options.StochasticDPeriod := Value end;

function TThemedFinancialBusinessChart.GetFinancialStochasticOversoldLevel: Double;
begin Result := FFinancial.Options.StochasticOversoldLevel end;
procedure TThemedFinancialBusinessChart.SetFinancialStochasticOversoldLevel(const Value: Double);
begin FFinancial.Options.StochasticOversoldLevel := Value end;

function TThemedFinancialBusinessChart.GetFinancialStochasticOverboughtLevel: Double;
begin Result := FFinancial.Options.StochasticOverboughtLevel end;
procedure TThemedFinancialBusinessChart.SetFinancialStochasticOverboughtLevel(const Value: Double);
begin FFinancial.Options.StochasticOverboughtLevel := Value end;

function TThemedFinancialBusinessChart.GetFinancialShowAtr: Boolean;
begin Result := FFinancial.Options.ShowAtr end;
procedure TThemedFinancialBusinessChart.SetFinancialShowAtr(const Value: Boolean);
begin FFinancial.Options.ShowAtr := Value end;

function TThemedFinancialBusinessChart.GetFinancialAtrPeriods: string;
begin Result := FFinancial.Options.AtrPeriods end;
procedure TThemedFinancialBusinessChart.SetFinancialAtrPeriods(const Value: string);
begin FFinancial.Options.AtrPeriods := Value end;

function TThemedFinancialBusinessChart.GetFinancialShowVwap: Boolean;
begin Result := FFinancial.Options.ShowVwap end;
procedure TThemedFinancialBusinessChart.SetFinancialShowVwap(const Value: Boolean);
begin FFinancial.Options.ShowVwap := Value end;

function TThemedFinancialBusinessChart.GetFinancialVwapResetBySession: Boolean;
begin Result := FFinancial.Options.VwapResetBySession end;
procedure TThemedFinancialBusinessChart.SetFinancialVwapResetBySession(const Value: Boolean);
begin FFinancial.Options.VwapResetBySession := Value end;

function TThemedFinancialBusinessChart.GetFinancialShowCrosshair: Boolean;
begin Result := FFinancial.Options.ShowCrosshair end;
procedure TThemedFinancialBusinessChart.SetFinancialShowCrosshair(const Value: Boolean);
begin FFinancial.Options.ShowCrosshair := Value end;

function TThemedFinancialBusinessChart.GetFinancialShowLegend: Boolean;
begin Result := FFinancial.Options.ShowLegend end;
procedure TThemedFinancialBusinessChart.SetFinancialShowLegend(const Value: Boolean);
begin FFinancial.Options.ShowLegend := Value end;

function TThemedFinancialBusinessChart.GetFinancialShowGrid: Boolean;
begin Result := FFinancial.Options.ShowGrid end;
procedure TThemedFinancialBusinessChart.SetFinancialShowGrid(const Value: Boolean);
begin FFinancial.Options.ShowGrid := Value end;

function TThemedFinancialBusinessChart.GetFinancialShowAxes: Boolean;
begin Result := FFinancial.Options.ShowAxes end;
procedure TThemedFinancialBusinessChart.SetFinancialShowAxes(const Value: Boolean);
begin FFinancial.Options.ShowAxes := Value end;

function TThemedFinancialBusinessChart.GetFinancialShowAnnotations: Boolean;
begin Result := FFinancial.Options.ShowAnnotations end;
procedure TThemedFinancialBusinessChart.SetFinancialShowAnnotations(const Value: Boolean);
begin FFinancial.Options.ShowAnnotations := Value end;

function TThemedFinancialBusinessChart.GetFinancialShowToolTips: Boolean;
begin Result := FFinancial.Options.ShowToolTips end;
procedure TThemedFinancialBusinessChart.SetFinancialShowToolTips(const Value: Boolean);
begin FFinancial.Options.ShowToolTips := Value end;

function TThemedFinancialBusinessChart.GetFinancialLockDetailsOnSelection: Boolean;
begin Result := FFinancial.Options.LockDetailsOnSelection end;
procedure TThemedFinancialBusinessChart.SetFinancialLockDetailsOnSelection(const Value: Boolean);
begin FFinancial.Options.LockDetailsOnSelection := Value end;

function TThemedFinancialBusinessChart.GetFinancialClearSelectionOnEmptyPlotClick: Boolean;
begin Result := FFinancial.Options.ClearSelectionOnEmptyPlotClick end;
procedure TThemedFinancialBusinessChart.SetFinancialClearSelectionOnEmptyPlotClick(const Value: Boolean);
begin FFinancial.Options.ClearSelectionOnEmptyPlotClick := Value end;

function TThemedFinancialBusinessChart.GetFinancialClearSelectionOnEscape: Boolean;
begin Result := FFinancial.Options.ClearSelectionOnEscape end;
procedure TThemedFinancialBusinessChart.SetFinancialClearSelectionOnEscape(const Value: Boolean);
begin FFinancial.Options.ClearSelectionOnEscape := Value end;

function TThemedFinancialBusinessChart.GetFinancialShowCrosshairWhileSelectionLocked: Boolean;
begin Result := FFinancial.Options.ShowCrosshairWhileSelectionLocked end;
procedure TThemedFinancialBusinessChart.SetFinancialShowCrosshairWhileSelectionLocked(const Value: Boolean);
begin FFinancial.Options.ShowCrosshairWhileSelectionLocked := Value end;

function TThemedFinancialBusinessChart.GetFinancialShowDashboardPanels: Boolean;
begin Result := FFinancial.Options.ShowDashboardPanels end;
procedure TThemedFinancialBusinessChart.SetFinancialShowDashboardPanels(const Value: Boolean);
begin FFinancial.Options.ShowDashboardPanels := Value end;

function TThemedFinancialBusinessChart.GetFinancialAutoBuildProductiveSidePanels: Boolean;
begin Result := FFinancial.Options.AutoBuildProductiveSidePanels end;
procedure TThemedFinancialBusinessChart.SetFinancialAutoBuildProductiveSidePanels(const Value: Boolean);
begin FFinancial.Options.AutoBuildProductiveSidePanels := Value end;

function TThemedFinancialBusinessChart.GetFinancialSidePanelLayoutMode: TNimbusFinancialSidePanelLayoutMode;
begin Result := FFinancial.Options.SidePanelLayoutMode end;
procedure TThemedFinancialBusinessChart.SetFinancialSidePanelLayoutMode(const Value: TNimbusFinancialSidePanelLayoutMode);
begin FFinancial.Options.SidePanelLayoutMode := Value end;

function TThemedFinancialBusinessChart.GetFinancialLeftSidePanelAreaWidth: Integer;
begin Result := FFinancial.Options.LeftSidePanelAreaWidth end;
procedure TThemedFinancialBusinessChart.SetFinancialLeftSidePanelAreaWidth(const Value: Integer);
begin FFinancial.Options.LeftSidePanelAreaWidth := Value end;

function TThemedFinancialBusinessChart.GetFinancialRightSidePanelAreaWidth: Integer;
begin Result := FFinancial.Options.RightSidePanelAreaWidth end;
procedure TThemedFinancialBusinessChart.SetFinancialRightSidePanelAreaWidth(const Value: Integer);
begin FFinancial.Options.RightSidePanelAreaWidth := Value end;

function TThemedFinancialBusinessChart.GetFinancialAllowPanelLayoutChanges: Boolean;
begin Result := FFinancial.Options.AllowPanelLayoutChanges end;
procedure TThemedFinancialBusinessChart.SetFinancialAllowPanelLayoutChanges(const Value: Boolean);
begin FFinancial.Options.AllowPanelLayoutChanges := Value end;

function TThemedFinancialBusinessChart.GetFinancialAllowVolumePanelReorder: Boolean;
begin Result := FFinancial.Options.AllowVolumePanelReorder end;
procedure TThemedFinancialBusinessChart.SetFinancialAllowVolumePanelReorder(const Value: Boolean);
begin FFinancial.Options.AllowVolumePanelReorder := Value end;

function TThemedFinancialBusinessChart.GetFinancialShowPanelDragAdorner: Boolean;
begin Result := FFinancial.Options.ShowPanelDragAdorner end;
procedure TThemedFinancialBusinessChart.SetFinancialShowPanelDragAdorner(const Value: Boolean);
begin FFinancial.Options.ShowPanelDragAdorner := Value end;

function TThemedFinancialBusinessChart.GetFinancialShowPanelDropZones: Boolean;
begin Result := FFinancial.Options.ShowPanelDropZones end;
procedure TThemedFinancialBusinessChart.SetFinancialShowPanelDropZones(const Value: Boolean);
begin FFinancial.Options.ShowPanelDropZones := Value end;

function TThemedFinancialBusinessChart.GetFinancialShowPanelContextMenu: Boolean;
begin Result := FFinancial.Options.ShowPanelContextMenu end;
procedure TThemedFinancialBusinessChart.SetFinancialShowPanelContextMenu(const Value: Boolean);
begin FFinancial.Options.ShowPanelContextMenu := Value end;

function TThemedFinancialBusinessChart.GetFinancialShowBuiltInIndicatorSettingsDialog: Boolean;
begin Result := FFinancial.Options.ShowBuiltInIndicatorSettingsDialog end;
procedure TThemedFinancialBusinessChart.SetFinancialShowBuiltInIndicatorSettingsDialog(const Value: Boolean);
begin FFinancial.Options.ShowBuiltInIndicatorSettingsDialog := Value end;

function TThemedFinancialBusinessChart.GetBusinessPanels: TNimbusFinancialPanelCollection;
begin Result := FFinancial.Panels end;
procedure TThemedFinancialBusinessChart.SetBusinessPanels(const Value: TNimbusFinancialPanelCollection);
begin if Value <> nil then FFinancial.Panels.Assign(Value) end;

function TThemedFinancialBusinessChart.GetBusinessIndicators: TNimbusFinancialIndicatorCollection;
begin Result := FFinancial.Indicators end;
procedure TThemedFinancialBusinessChart.SetBusinessIndicators(const Value: TNimbusFinancialIndicatorCollection);
begin if Value <> nil then FFinancial.Indicators.Assign(Value) end;

function TThemedFinancialBusinessChart.GetBusinessSidePanels: TNimbusFinancialSidePanelCollection;
begin Result := FFinancial.SidePanels end;
procedure TThemedFinancialBusinessChart.SetBusinessSidePanels(const Value: TNimbusFinancialSidePanelCollection);
begin if Value <> nil then FFinancial.SidePanels.Assign(Value) end;

function TThemedFinancialBusinessChart.GetBusinessMarkers: TNimbusFinancialMarkerCollection;
begin Result := FFinancial.Markers end;
procedure TThemedFinancialBusinessChart.SetBusinessMarkers(const Value: TNimbusFinancialMarkerCollection);
begin if Value <> nil then FFinancial.Markers.Assign(Value) end;

function TThemedFinancialBusinessChart.GetBusinessAnnotations: TNimbusFinancialAnnotationCollection;
begin Result := FFinancial.Annotations end;
procedure TThemedFinancialBusinessChart.SetBusinessAnnotations(const Value: TNimbusFinancialAnnotationCollection);
begin if Value <> nil then FFinancial.Annotations.Assign(Value) end;

function TThemedFinancialBusinessChart.GetBusinessRangeSelector: TNimbusFinancialRangeSelector;
begin Result := FFinancial.RangeSelector end;
procedure TThemedFinancialBusinessChart.SetBusinessRangeSelector(const Value: TNimbusFinancialRangeSelector);
begin if Value <> nil then FFinancial.RangeSelector.Assign(Value) end;

function TThemedFinancialBusinessChart.GetBusinessViewport: TNimbusFinancialViewport;
begin Result := FFinancial.Viewport end;
procedure TThemedFinancialBusinessChart.SetBusinessViewport(const Value: TNimbusFinancialViewport);
begin if Value <> nil then FFinancial.Viewport.Assign(Value) end;

function TThemedFinancialBusinessChart.GetBusinessInteractionOptions: TNimbusFinancialInteractionOptions;
begin Result := FFinancial.InteractionOptions end;
procedure TThemedFinancialBusinessChart.SetBusinessInteractionOptions(const Value: TNimbusFinancialInteractionOptions);
begin if Value <> nil then FFinancial.InteractionOptions.Assign(Value) end;

function TThemedFinancialBusinessChart.GetBusinessAccessibilityOptions: TNimbusFinancialAccessibilityOptions;
begin Result := FFinancial.AccessibilityOptions end;
procedure TThemedFinancialBusinessChart.SetBusinessAccessibilityOptions(const Value: TNimbusFinancialAccessibilityOptions);
begin if Value <> nil then FFinancial.AccessibilityOptions.Assign(Value) end;

function TThemedFinancialBusinessChart.GetBusinessFinancialPalette: TNimbusFinancialPalette;
begin Result := FFinancial.Palette end;
procedure TThemedFinancialBusinessChart.SetBusinessFinancialPalette(const Value: TNimbusFinancialPalette);
begin if Value <> nil then FFinancial.Palette.Assign(Value) end;

initialization
  RegisterClass(TThemedFinancialBusinessChart);

end.

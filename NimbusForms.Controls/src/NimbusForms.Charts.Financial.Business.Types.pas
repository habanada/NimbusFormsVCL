unit NimbusForms.Charts.Financial.Business.Types;

interface

uses System.Classes, System.SysUtils, System.Types, System.Math, Vcl.Graphics, Vcl.Controls;

type
  TNimbusFinancialPanelType = (nfptPrice, nfptVolume, nfptIndicator, nfptOscillator, nfptCustom);
  TNimbusFinancialPanelState = (nfpsExpanded, nfpsCollapsed, nfpsHidden);
  TNimbusFinancialYAxisPosition = (nfyapLeft, nfyapRight, nfyapHidden);
  TNimbusFinancialScaleMode = (nfsmAuto, nfsmManual, nfsmFixed, nfsmPercent, nfsmLogarithmic, nfsmSharedPriceScale);
  TNimbusFinancialPanelLayoutPreset = (nfplDefault, nfplCompact, nfplAnalytical, nfplTradingDesk, nfplMinimal);
  TNimbusFinancialIndicatorKind = (nfikVolume, nfikSma, nfikEma, nfikBollinger, nfikVwap, nfikRsi, nfikStochastic, nfikMacd, nfikAtr, nfikCustom);
  TNimbusFinancialPanelItemKind = (nfpiText, nfpiMetric, nfpiSeparator, nfpiSparkline, nfpiMiniLine, nfpiMiniArea, nfpiMiniBar, nfpiMiniPie, nfpiMiniDonut, nfpiVolumeBar, nfpiPriceChangeBadge, nfpiCustom);
  TNimbusFinancialSidePanelKind = (nfspDetails, nfspWatchList, nfspTopVolumes, nfspTransactions, nfspNews, nfspAlerts, nfspCustom);
  TNimbusFinancialSidePanelPosition = (nfsppLeft, nfsppRight);
  TNimbusFinancialSidePanelLayoutMode = (nfslColumns, nfslStacked);
  TNimbusFinancialSidePanelState = (nfspsExpanded, nfspsCollapsed, nfspsAutoHidden, nfspsHidden);
  TNimbusFinancialMarkerKind = (nfmkCustom, nfmkMarkerUp, nfmkMarkerDown, nfmkEvent, nfmkEarnings, nfmkDividend, nfmkAlert, nfmkBuy, nfmkSell);
  TNimbusFinancialMarkerStyle = (nfmsCircle, nfmsDiamond, nfmsTriangleUp, nfmsTriangleDown, nfmsFlag, nfmsVerticalLine, nfmsLabel);
  TNimbusFinancialMarkerAnchor = (nfmaAboveCandle, nfmaBelowCandle, nfmaCenterOnCandle, nfmaOnHigh, nfmaOnLow, nfmaAbsoluteValue);
  TNimbusFinancialAnnotationKind = (nfakHorizontalLine, nfakVerticalLine, nfakTrendLine, nfakRectangle, nfakPriceRange, nfakTextLabel, nfakArrow, nfakChannel);
  TNimbusFinancialCoordinateMode = (nfcmIndex, nfcmTime);
  TNimbusFinancialRangeKind = (nfrkDays, nfrkMonths, nfrkYears, nfrkYearToDate, nfrkAll, nfrkBars);
  TNimbusFinancialRangePlacement = (nfrpAuto, nfrpHeaderRight, nfrpTimeAxisRight, nfrpBottomRight);
  TNimbusFinancialTimeFrame = (nftfMinute1, nftfMinute5, nftfMinute15, nftfMinute30, nftfHour1, nftfHour4, nftfDay1, nftfWeek1, nftfMonth1);
  TNimbusFinancialPriceMode = (nfpmCandlestick, nfpmOhlc, nfpmLine, nfpmArea);

  TNimbusFinancialPanMouseButtons = set of TMouseButton;

  TNimbusFinancialRowAction = (nfraClicked, nfraDoubleClicked, nfraHovered, nfraContextMenu);
  TNimbusFinancialInputOrigin = (nfioMouse, nfioKeyboard, nfioProgrammatic);
  TNimbusFinancialPanelAction = (nfpaHeaderClicked, nfpaCollapsed, nfpaExpanded, nfpaClosed, nfpaPinned, nfpaUnpinned, nfpaResized, nfpaMoved, nfpaSettingsRequested, nfpaScrolled);
  TNimbusFinancialRowEventInfo = record
    Action: TNimbusFinancialRowAction;
    Origin: TNimbusFinancialInputOrigin;
    PanelKey, PanelTitle, RowKey, Text, Value, SecondaryValue: string;
    Symbol, Exchange: string;
    PanelIndex, RowIndex, VisibleRowIndex, CandleIndex: Integer;
    PanelKind: TNimbusFinancialSidePanelKind;
    RowKind: TNimbusFinancialPanelItemKind;
    NumericValue, ChangeValue, ChangePercent: Double;
    Tag: NativeInt;
    Values: TArray<Double>;
    HasCandle: Boolean;
    CandleTime: TDateTime;
    Open, High, Low, Close, Volume: Double;
    Button: TMouseButton;
    Shift: TShiftState;
    Location: TPoint;
  end;
  TNimbusFinancialPanelActionInfo = record
    Action: TNimbusFinancialPanelAction;
    IsSidePanel: Boolean;
    PanelIndex: Integer;
    PanelKey, Title: string;
    Tag: NativeInt;
    Pinned: Boolean;
    ScrollOffset, Width, PreferredHeight: Integer;
  end;
  TNimbusFinancialRowEvent = procedure(Sender: TObject; const Info: TNimbusFinancialRowEventInfo) of object;
  TNimbusFinancialPanelActionEvent = procedure(Sender: TObject; const Info: TNimbusFinancialPanelActionInfo) of object;

  TNimbusFinancialPersistent = class(TPersistent)
  private
    FOnChange: TNotifyEvent;
    FRevision: UInt64;
  protected
    procedure Changed;
  public
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Revision: UInt64 read FRevision;
  end;

  TNimbusFinancialPanel = class(TCollectionItem)
  private
    FOnAction: TNimbusFinancialPanelActionEvent;
    FKey: string;
    FTitle: string;
    FSubtitle: string;
    FPanelType: TNimbusFinancialPanelType;
    FState: TNimbusFinancialPanelState;
    FHeightWeight: Double;
    FMinimumHeight: Integer;
    FPreferredHeight: Integer;
    FVisible: Boolean;
    FShowGrid: Boolean;
    FShowYAxis: Boolean;
    FShowXAxis: Boolean;
    FAllowSettings: Boolean;
    FAllowClose: Boolean;
    FAllowCollapse: Boolean;
    FAllowResize: Boolean;
    FAllowMove: Boolean;
    FAllowPin: Boolean;
    FIsPinned: Boolean;
    FYAxisPosition: TNimbusFinancialYAxisPosition;
    FScaleMode: TNimbusFinancialScaleMode;
    FManualMinimumValue: Double;
    FManualMaximumValue: Double;
    FFixedMinimumValue: Double;
    FFixedMaximumValue: Double;
    FScalePaddingRatio: Double;
    FValueFormat: string;
    FTag: NativeInt;
    procedure SetKey(const Value: string);
    procedure SetTitle(const Value: string);
    procedure SetSubtitle(const Value: string);
    procedure SetPanelType(const Value: TNimbusFinancialPanelType);
    procedure SetState(const Value: TNimbusFinancialPanelState);
    procedure SetHeightWeight(const Value: Double);
    procedure SetMinimumHeight(const Value: Integer);
    procedure SetPreferredHeight(const Value: Integer);
    procedure SetVisible(const Value: Boolean);
    procedure SetShowGrid(const Value: Boolean);
    procedure SetShowYAxis(const Value: Boolean);
    procedure SetShowXAxis(const Value: Boolean);
    procedure SetAllowSettings(const Value: Boolean);
    procedure SetAllowClose(const Value: Boolean);
    procedure SetAllowCollapse(const Value: Boolean);
    procedure SetAllowResize(const Value: Boolean);
    procedure SetAllowMove(const Value: Boolean);
    procedure SetAllowPin(const Value: Boolean);
    procedure SetIsPinned(const Value: Boolean);
    procedure SetYAxisPosition(const Value: TNimbusFinancialYAxisPosition);
    procedure SetScaleMode(const Value: TNimbusFinancialScaleMode);
    procedure SetManualMinimumValue(const Value: Double);
    procedure SetManualMaximumValue(const Value: Double);
    procedure SetFixedMinimumValue(const Value: Double);
    procedure SetFixedMaximumValue(const Value: Double);
    procedure SetScalePaddingRatio(const Value: Double);
    procedure SetValueFormat(const Value: string);
    procedure SetTag(const Value: NativeInt);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property OnAction: TNimbusFinancialPanelActionEvent read FOnAction write FOnAction;
    property Key: string read FKey write SetKey;
    property Title: string read FTitle write SetTitle;
    property Subtitle: string read FSubtitle write SetSubtitle;
    property PanelType: TNimbusFinancialPanelType read FPanelType write SetPanelType;
    property State: TNimbusFinancialPanelState read FState write SetState;
    property HeightWeight: Double read FHeightWeight write SetHeightWeight;
    property MinimumHeight: Integer read FMinimumHeight write SetMinimumHeight;
    property PreferredHeight: Integer read FPreferredHeight write SetPreferredHeight;
    property Visible: Boolean read FVisible write SetVisible;
    property ShowGrid: Boolean read FShowGrid write SetShowGrid;
    property ShowYAxis: Boolean read FShowYAxis write SetShowYAxis;
    property ShowXAxis: Boolean read FShowXAxis write SetShowXAxis;
    property AllowSettings: Boolean read FAllowSettings write SetAllowSettings;
    property AllowClose: Boolean read FAllowClose write SetAllowClose;
    property AllowCollapse: Boolean read FAllowCollapse write SetAllowCollapse;
    property AllowResize: Boolean read FAllowResize write SetAllowResize;
    property AllowMove: Boolean read FAllowMove write SetAllowMove;
    property AllowPin: Boolean read FAllowPin write SetAllowPin;
    property IsPinned: Boolean read FIsPinned write SetIsPinned;
    property YAxisPosition: TNimbusFinancialYAxisPosition read FYAxisPosition write SetYAxisPosition;
    property ScaleMode: TNimbusFinancialScaleMode read FScaleMode write SetScaleMode;
    property ManualMinimumValue: Double read FManualMinimumValue write SetManualMinimumValue;
    property ManualMaximumValue: Double read FManualMaximumValue write SetManualMaximumValue;
    property FixedMinimumValue: Double read FFixedMinimumValue write SetFixedMinimumValue;
    property FixedMaximumValue: Double read FFixedMaximumValue write SetFixedMaximumValue;
    property ScalePaddingRatio: Double read FScalePaddingRatio write SetScalePaddingRatio;
    property ValueFormat: string read FValueFormat write SetValueFormat;
    property Tag: NativeInt read FTag write SetTag;
  end;

  TNimbusFinancialPanelCollection = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    FRevision: UInt64;
    function GetItem(Index: Integer): TNimbusFinancialPanel;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    procedure Assign(Source: TPersistent); override;
    constructor Create(AOwner: TPersistent);
    function Add: TNimbusFinancialPanel;
    function FindByKey(const Key: string): TNimbusFinancialPanel;
    property Items[Index: Integer]: TNimbusFinancialPanel read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Revision: UInt64 read FRevision;
  end;

  TNimbusFinancialIndicator = class(TCollectionItem)
  private
    FValues: TArray<Double>;
    FKey: string;
    FDisplayName: string;
    FPanelKey: string;
    FKind: TNimbusFinancialIndicatorKind;
    FVisible: Boolean;
    FPeriods: string;
    FFastPeriod: Integer;
    FSlowPeriod: Integer;
    FSignalPeriod: Integer;
    FSmoothKPeriod: Integer;
    FStandardDeviation: Double;
    FOversoldLevel: Double;
    FOverboughtLevel: Double;
    FResetBySession: Boolean;
    FColor: TColor;
    FSecondaryColor: TColor;
    FTag: NativeInt;
    procedure SetKey(const Value: string);
    procedure SetDisplayName(const Value: string);
    procedure SetPanelKey(const Value: string);
    procedure SetKind(const Value: TNimbusFinancialIndicatorKind);
    procedure SetVisible(const Value: Boolean);
    procedure SetPeriods(const Value: string);
    procedure SetFastPeriod(const Value: Integer);
    procedure SetSlowPeriod(const Value: Integer);
    procedure SetSignalPeriod(const Value: Integer);
    procedure SetSmoothKPeriod(const Value: Integer);
    procedure SetStandardDeviation(const Value: Double);
    procedure SetOversoldLevel(const Value: Double);
    procedure SetOverboughtLevel(const Value: Double);
    procedure SetResetBySession(const Value: Boolean);
    procedure SetColor(const Value: TColor);
    procedure SetSecondaryColor(const Value: TColor);
    procedure SetTag(const Value: NativeInt);
    procedure SetValues(const Value: TArray<Double>);
  public
    property Values: TArray<Double> read FValues write SetValues;
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Key: string read FKey write SetKey;
    property DisplayName: string read FDisplayName write SetDisplayName;
    property PanelKey: string read FPanelKey write SetPanelKey;
    property Kind: TNimbusFinancialIndicatorKind read FKind write SetKind;
    property Visible: Boolean read FVisible write SetVisible;
    property Periods: string read FPeriods write SetPeriods;
    property FastPeriod: Integer read FFastPeriod write SetFastPeriod;
    property SlowPeriod: Integer read FSlowPeriod write SetSlowPeriod;
    property SignalPeriod: Integer read FSignalPeriod write SetSignalPeriod;
    property SmoothKPeriod: Integer read FSmoothKPeriod write SetSmoothKPeriod;
    property StandardDeviation: Double read FStandardDeviation write SetStandardDeviation;
    property OversoldLevel: Double read FOversoldLevel write SetOversoldLevel;
    property OverboughtLevel: Double read FOverboughtLevel write SetOverboughtLevel;
    property ResetBySession: Boolean read FResetBySession write SetResetBySession;
    property Color: TColor read FColor write SetColor;
    property SecondaryColor: TColor read FSecondaryColor write SetSecondaryColor;
    property Tag: NativeInt read FTag write SetTag;
  end;

  TNimbusFinancialIndicatorCollection = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    FRevision: UInt64;
    function GetItem(Index: Integer): TNimbusFinancialIndicator;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TNimbusFinancialIndicator;
    function FindByKey(const Key: string): TNimbusFinancialIndicator;
    property Items[Index: Integer]: TNimbusFinancialIndicator read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Revision: UInt64 read FRevision;
  end;

  TNimbusFinancialPanelItem = class(TCollectionItem)
  private
    FCandleIndex: Integer;
    FKey: string;
    FKind: TNimbusFinancialPanelItemKind;
    FText: string;
    FValue: string;
    FSecondaryValue: string;
    FNumericValue: Double;
    FChangeValue: Double;
    FChangePercent: Double;
    FHeight: Integer;
    FVisible: Boolean;
    FTag: NativeInt;
    FValues: TArray<Double>;
    procedure SetCandleIndex(const Value: Integer);
    procedure SetKey(const Value: string);
    procedure SetKind(const Value: TNimbusFinancialPanelItemKind);
    procedure SetText(const Value: string);
    procedure SetValue(const Value: string);
    procedure SetSecondaryValue(const Value: string);
    procedure SetNumericValue(const Value: Double);
    procedure SetChangeValue(const Value: Double);
    procedure SetChangePercent(const Value: Double);
    procedure SetHeight(const Value: Integer);
    procedure SetVisible(const Value: Boolean);
    procedure SetTag(const Value: NativeInt);
    procedure SetValues(const Value: TArray<Double>);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    property Values: TArray<Double> read FValues write SetValues;
  published
    property CandleIndex: Integer read FCandleIndex write SetCandleIndex;
    property Key: string read FKey write SetKey;
    property Kind: TNimbusFinancialPanelItemKind read FKind write SetKind;
    property Text: string read FText write SetText;
    property Value: string read FValue write SetValue;
    property SecondaryValue: string read FSecondaryValue write SetSecondaryValue;
    property NumericValue: Double read FNumericValue write SetNumericValue;
    property ChangeValue: Double read FChangeValue write SetChangeValue;
    property ChangePercent: Double read FChangePercent write SetChangePercent;
    property Height: Integer read FHeight write SetHeight;
    property Visible: Boolean read FVisible write SetVisible;
    property Tag: NativeInt read FTag write SetTag;
  end;

  TNimbusFinancialPanelItemCollection = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    FRevision: UInt64;
    function GetItem(Index: Integer): TNimbusFinancialPanelItem;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TNimbusFinancialPanelItem;
    function FindByKey(const Key: string): TNimbusFinancialPanelItem;
    property Items[Index: Integer]: TNimbusFinancialPanelItem read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Revision: UInt64 read FRevision;
  end;

  TNimbusFinancialSidePanel = class(TCollectionItem)
  private
    FOnAction: TNimbusFinancialPanelActionEvent;
    FOnRowClicked: TNimbusFinancialRowEvent;
    FOnRowDoubleClicked: TNimbusFinancialRowEvent;
    FOnRowHovered: TNimbusFinancialRowEvent;
    FOnRowContextMenu: TNimbusFinancialRowEvent;
    FKey: string;
    FTitle: string;
    FKind: TNimbusFinancialSidePanelKind;
    FPosition: TNimbusFinancialSidePanelPosition;
    FState: TNimbusFinancialSidePanelState;
    FVisible: Boolean;
    FResizable: Boolean;
    FPinned: Boolean;
    FWidth: Integer;
    FMinimumWidth: Integer;
    FMaximumWidth: Integer;
    FCollapsedWidth: Integer;
    FPreferredHeight: Integer;
    FMinimumHeight: Integer;
    FMaximumHeight: Integer;
    FScrollOffset: Integer;
    FTag: NativeInt;
    FItems: TNimbusFinancialPanelItemCollection;
    procedure SetKey(const Value: string);
    procedure SetTitle(const Value: string);
    procedure SetKind(const Value: TNimbusFinancialSidePanelKind);
    procedure SetPosition(const Value: TNimbusFinancialSidePanelPosition);
    procedure SetState(const Value: TNimbusFinancialSidePanelState);
    procedure SetVisible(const Value: Boolean);
    procedure SetResizable(const Value: Boolean);
    procedure SetPinned(const Value: Boolean);
    procedure SetWidth(const Value: Integer);
    procedure SetMinimumWidth(const Value: Integer);
    procedure SetMaximumWidth(const Value: Integer);
    procedure SetCollapsedWidth(const Value: Integer);
    procedure SetPreferredHeight(const Value: Integer);
    procedure SetMinimumHeight(const Value: Integer);
    procedure SetMaximumHeight(const Value: Integer);
    procedure SetScrollOffset(const Value: Integer);
    procedure SetTag(const Value: NativeInt);
    procedure SetItems(const Value: TNimbusFinancialPanelItemCollection);
    procedure ItemsChanged(Sender: TObject);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property OnAction: TNimbusFinancialPanelActionEvent read FOnAction write FOnAction;
    property OnRowClicked: TNimbusFinancialRowEvent read FOnRowClicked write FOnRowClicked;
    property OnRowDoubleClicked: TNimbusFinancialRowEvent read FOnRowDoubleClicked write FOnRowDoubleClicked;
    property OnRowHovered: TNimbusFinancialRowEvent read FOnRowHovered write FOnRowHovered;
    property OnRowContextMenu: TNimbusFinancialRowEvent read FOnRowContextMenu write FOnRowContextMenu;
    property Key: string read FKey write SetKey;
    property Title: string read FTitle write SetTitle;
    property Kind: TNimbusFinancialSidePanelKind read FKind write SetKind;
    property Position: TNimbusFinancialSidePanelPosition read FPosition write SetPosition;
    property State: TNimbusFinancialSidePanelState read FState write SetState;
    property Visible: Boolean read FVisible write SetVisible;
    property Resizable: Boolean read FResizable write SetResizable;
    property Pinned: Boolean read FPinned write SetPinned;
    property Width: Integer read FWidth write SetWidth;
    property MinimumWidth: Integer read FMinimumWidth write SetMinimumWidth;
    property MaximumWidth: Integer read FMaximumWidth write SetMaximumWidth;
    property CollapsedWidth: Integer read FCollapsedWidth write SetCollapsedWidth;
    property PreferredHeight: Integer read FPreferredHeight write SetPreferredHeight;
    property MinimumHeight: Integer read FMinimumHeight write SetMinimumHeight;
    property MaximumHeight: Integer read FMaximumHeight write SetMaximumHeight;
    property ScrollOffset: Integer read FScrollOffset write SetScrollOffset;
    property Tag: NativeInt read FTag write SetTag;
    property Items: TNimbusFinancialPanelItemCollection read FItems write SetItems;
  end;

  TNimbusFinancialSidePanelCollection = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    FRevision: UInt64;
    function GetItem(Index: Integer): TNimbusFinancialSidePanel;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    procedure Assign(Source: TPersistent); override;
    constructor Create(AOwner: TPersistent);
    function Add: TNimbusFinancialSidePanel;
    function FindByKey(const Key: string): TNimbusFinancialSidePanel;
    property Items[Index: Integer]: TNimbusFinancialSidePanel read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Revision: UInt64 read FRevision;
  end;

  TNimbusFinancialMarker = class(TCollectionItem)
  private
    FKey: string;
    FText: string;
    FDescription: string;
    FTime: TDateTime;
    FCandleIndex: Integer;
    FValue: Double;
    FUseValue: Boolean;
    FVisible: Boolean;
    FKind: TNimbusFinancialMarkerKind;
    FStyle: TNimbusFinancialMarkerStyle;
    FAnchor: TNimbusFinancialMarkerAnchor;
    FColor: TColor;
    FBorderColor: TColor;
    FTag: NativeInt;
    procedure SetKey(const Value: string);
    procedure SetText(const Value: string);
    procedure SetDescription(const Value: string);
    procedure SetTime(const Value: TDateTime);
    procedure SetCandleIndex(const Value: Integer);
    procedure SetValue(const Value: Double);
    procedure SetUseValue(const Value: Boolean);
    procedure SetVisible(const Value: Boolean);
    procedure SetKind(const Value: TNimbusFinancialMarkerKind);
    procedure SetStyle(const Value: TNimbusFinancialMarkerStyle);
    procedure SetAnchor(const Value: TNimbusFinancialMarkerAnchor);
    procedure SetColor(const Value: TColor);
    procedure SetBorderColor(const Value: TColor);
    procedure SetTag(const Value: NativeInt);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Key: string read FKey write SetKey;
    property Text: string read FText write SetText;
    property Description: string read FDescription write SetDescription;
    property Time: TDateTime read FTime write SetTime;
    property CandleIndex: Integer read FCandleIndex write SetCandleIndex;
    property Value: Double read FValue write SetValue;
    property UseValue: Boolean read FUseValue write SetUseValue;
    property Visible: Boolean read FVisible write SetVisible;
    property Kind: TNimbusFinancialMarkerKind read FKind write SetKind;
    property Style: TNimbusFinancialMarkerStyle read FStyle write SetStyle;
    property Anchor: TNimbusFinancialMarkerAnchor read FAnchor write SetAnchor;
    property Color: TColor read FColor write SetColor;
    property BorderColor: TColor read FBorderColor write SetBorderColor;
    property Tag: NativeInt read FTag write SetTag;
  end;

  TNimbusFinancialMarkerCollection = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    FRevision: UInt64;
    function GetItem(Index: Integer): TNimbusFinancialMarker;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TNimbusFinancialMarker;
    function FindByKey(const Key: string): TNimbusFinancialMarker;
    property Items[Index: Integer]: TNimbusFinancialMarker read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Revision: UInt64 read FRevision;
  end;

  TNimbusFinancialAnnotation = class(TCollectionItem)
  private
    FKey: string;
    FText: string;
    FDescription: string;
    FVisible: Boolean;
    FKind: TNimbusFinancialAnnotationKind;
    FCoordinateMode: TNimbusFinancialCoordinateMode;
    FStartTime: TDateTime;
    FEndTime: TDateTime;
    FStartIndex: Integer;
    FEndIndex: Integer;
    FStartValue: Double;
    FEndValue: Double;
    FLineColor: TColor;
    FFillColor: TColor;
    FTextColor: TColor;
    FDashStyle: TPenStyle;
    FLineWidth: Double;
    FSelectable: Boolean;
    FLocked: Boolean;
    FTag: NativeInt;
    procedure SetKey(const Value: string);
    procedure SetText(const Value: string);
    procedure SetDescription(const Value: string);
    procedure SetVisible(const Value: Boolean);
    procedure SetKind(const Value: TNimbusFinancialAnnotationKind);
    procedure SetCoordinateMode(const Value: TNimbusFinancialCoordinateMode);
    procedure SetStartTime(const Value: TDateTime);
    procedure SetEndTime(const Value: TDateTime);
    procedure SetStartIndex(const Value: Integer);
    procedure SetEndIndex(const Value: Integer);
    procedure SetStartValue(const Value: Double);
    procedure SetEndValue(const Value: Double);
    procedure SetLineColor(const Value: TColor);
    procedure SetFillColor(const Value: TColor);
    procedure SetTextColor(const Value: TColor);
    procedure SetDashStyle(const Value: TPenStyle);
    procedure SetLineWidth(const Value: Double);
    procedure SetSelectable(const Value: Boolean);
    procedure SetLocked(const Value: Boolean);
    procedure SetTag(const Value: NativeInt);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Key: string read FKey write SetKey;
    property Text: string read FText write SetText;
    property Description: string read FDescription write SetDescription;
    property Visible: Boolean read FVisible write SetVisible;
    property Kind: TNimbusFinancialAnnotationKind read FKind write SetKind;
    property CoordinateMode: TNimbusFinancialCoordinateMode read FCoordinateMode write SetCoordinateMode;
    property StartTime: TDateTime read FStartTime write SetStartTime;
    property EndTime: TDateTime read FEndTime write SetEndTime;
    property StartIndex: Integer read FStartIndex write SetStartIndex;
    property EndIndex: Integer read FEndIndex write SetEndIndex;
    property StartValue: Double read FStartValue write SetStartValue;
    property EndValue: Double read FEndValue write SetEndValue;
    property LineColor: TColor read FLineColor write SetLineColor;
    property FillColor: TColor read FFillColor write SetFillColor;
    property TextColor: TColor read FTextColor write SetTextColor;
    property DashStyle: TPenStyle read FDashStyle write SetDashStyle;
    property LineWidth: Double read FLineWidth write SetLineWidth;
    property Selectable: Boolean read FSelectable write SetSelectable;
    property Locked: Boolean read FLocked write SetLocked;
    property Tag: NativeInt read FTag write SetTag;
  end;

  TNimbusFinancialAnnotationCollection = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    FRevision: UInt64;
    function GetItem(Index: Integer): TNimbusFinancialAnnotation;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TNimbusFinancialAnnotation;
    function FindByKey(const Key: string): TNimbusFinancialAnnotation;
    property Items[Index: Integer]: TNimbusFinancialAnnotation read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Revision: UInt64 read FRevision;
  end;

  TNimbusFinancialRangeButton = class(TCollectionItem)
  private
    FKey: string;
    FText: string;
    FRangeKind: TNimbusFinancialRangeKind;
    FValue: Integer;
    FVisible: Boolean;
    FEnabled: Boolean;
    FSelected: Boolean;
    procedure SetKey(const Value: string);
    procedure SetText(const Value: string);
    procedure SetRangeKind(const Value: TNimbusFinancialRangeKind);
    procedure SetValue(const Value: Integer);
    procedure SetVisible(const Value: Boolean);
    procedure SetEnabled(const Value: Boolean);
    procedure SetSelected(const Value: Boolean);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Key: string read FKey write SetKey;
    property Text: string read FText write SetText;
    property RangeKind: TNimbusFinancialRangeKind read FRangeKind write SetRangeKind;
    property Value: Integer read FValue write SetValue;
    property Visible: Boolean read FVisible write SetVisible;
    property Enabled: Boolean read FEnabled write SetEnabled;
    property Selected: Boolean read FSelected write SetSelected;
  end;

  TNimbusFinancialRangeButtonCollection = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    FRevision: UInt64;
    function GetItem(Index: Integer): TNimbusFinancialRangeButton;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TNimbusFinancialRangeButton;
    function FindByKey(const Key: string): TNimbusFinancialRangeButton;
    property Items[Index: Integer]: TNimbusFinancialRangeButton read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Revision: UInt64 read FRevision;
  end;

  TNimbusFinancialInteractionOptions = class(TNimbusFinancialPersistent)
  private
    FPanMouseButtons: TNimbusFinancialPanMouseButtons;
    FEnableMouseWheelZoom: Boolean;
    FEnableCtrlMouseWheelZoom: Boolean;
    FEnableShiftMouseWheelPan: Boolean;
    FEnableDragPan: Boolean;
    FEnableLeftButtonDragPan: Boolean;
    FEnableKeyboardNavigation: Boolean;
    FDragPanThreshold: Integer;
    FMouseWheelPanCandles: Integer;
    FPagePanRatio: Double;
    FKeyboardZoomFactor: Double;
    procedure SetPanMouseButtons(const Value: TNimbusFinancialPanMouseButtons);
    procedure SetEnableMouseWheelZoom(const Value: Boolean);
    procedure SetEnableCtrlMouseWheelZoom(const Value: Boolean);
    procedure SetEnableShiftMouseWheelPan(const Value: Boolean);
    procedure SetEnableDragPan(const Value: Boolean);
    procedure SetEnableLeftButtonDragPan(const Value: Boolean);
    procedure SetEnableKeyboardNavigation(const Value: Boolean);
    procedure SetDragPanThreshold(const Value: Integer);
    procedure SetMouseWheelPanCandles(const Value: Integer);
    procedure SetPagePanRatio(const Value: Double);
    procedure SetKeyboardZoomFactor(const Value: Double);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property PanMouseButtons: TNimbusFinancialPanMouseButtons read FPanMouseButtons write SetPanMouseButtons;
    property EnableMouseWheelZoom: Boolean read FEnableMouseWheelZoom write SetEnableMouseWheelZoom;
    property EnableCtrlMouseWheelZoom: Boolean read FEnableCtrlMouseWheelZoom write SetEnableCtrlMouseWheelZoom;
    property EnableShiftMouseWheelPan: Boolean read FEnableShiftMouseWheelPan write SetEnableShiftMouseWheelPan;
    property EnableDragPan: Boolean read FEnableDragPan write SetEnableDragPan;
    property EnableLeftButtonDragPan: Boolean read FEnableLeftButtonDragPan write SetEnableLeftButtonDragPan;
    property EnableKeyboardNavigation: Boolean read FEnableKeyboardNavigation write SetEnableKeyboardNavigation;
    property DragPanThreshold: Integer read FDragPanThreshold write SetDragPanThreshold;
    property MouseWheelPanCandles: Integer read FMouseWheelPanCandles write SetMouseWheelPanCandles;
    property PagePanRatio: Double read FPagePanRatio write SetPagePanRatio;
    property KeyboardZoomFactor: Double read FKeyboardZoomFactor write SetKeyboardZoomFactor;
  end;

  TNimbusFinancialAccessibilityOptions = class(TNimbusFinancialPersistent)
  private
    FEnableScreenReaderSummary: Boolean;
    FEnableKeyboardCandleSelection: Boolean;
    FAutoApplyHighContrast: Boolean;
    FIncludeVisibleRangeInSummary: Boolean;
    FIncludeSelectionInSummary: Boolean;
    procedure SetEnableScreenReaderSummary(const Value: Boolean);
    procedure SetEnableKeyboardCandleSelection(const Value: Boolean);
    procedure SetAutoApplyHighContrast(const Value: Boolean);
    procedure SetIncludeVisibleRangeInSummary(const Value: Boolean);
    procedure SetIncludeSelectionInSummary(const Value: Boolean);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property EnableScreenReaderSummary: Boolean read FEnableScreenReaderSummary write SetEnableScreenReaderSummary;
    property EnableKeyboardCandleSelection: Boolean read FEnableKeyboardCandleSelection write SetEnableKeyboardCandleSelection;
    property AutoApplyHighContrast: Boolean read FAutoApplyHighContrast write SetAutoApplyHighContrast;
    property IncludeVisibleRangeInSummary: Boolean read FIncludeVisibleRangeInSummary write SetIncludeVisibleRangeInSummary;
    property IncludeSelectionInSummary: Boolean read FIncludeSelectionInSummary write SetIncludeSelectionInSummary;
  end;

  TNimbusFinancialRangeSelector = class(TNimbusFinancialPersistent)
  private
    FVisible: Boolean;
    FButtonMinWidth: Integer;
    FButtonHeight: Integer;
    FButtonSpacing: Integer;
    FPlacement: TNimbusFinancialRangePlacement;
    FItems: TNimbusFinancialRangeButtonCollection;
    procedure SetVisible(const Value: Boolean);
    procedure SetButtonMinWidth(const Value: Integer);
    procedure SetButtonHeight(const Value: Integer);
    procedure SetButtonSpacing(const Value: Integer);
    procedure SetPlacement(const Value: TNimbusFinancialRangePlacement);
    procedure SetItems(const Value: TNimbusFinancialRangeButtonCollection);
    procedure ItemsChanged(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Visible: Boolean read FVisible write SetVisible;
    property ButtonMinWidth: Integer read FButtonMinWidth write SetButtonMinWidth;
    property ButtonHeight: Integer read FButtonHeight write SetButtonHeight;
    property ButtonSpacing: Integer read FButtonSpacing write SetButtonSpacing;
    property Placement: TNimbusFinancialRangePlacement read FPlacement write SetPlacement;
    property Items: TNimbusFinancialRangeButtonCollection read FItems write SetItems;
  end;

  TNimbusFinancialBusinessOptions = class(TNimbusFinancialPersistent)
  private
    FSymbol: string;
    FExchange: string;
    FTimeFrame: TNimbusFinancialTimeFrame;
    FPriceMode: TNimbusFinancialPriceMode;
    FShowVolume: Boolean;
    FShowVolumeMovingAverage: Boolean;
    FVolumeMovingAveragePeriod: Integer;
    FShowSimpleMovingAverage: Boolean;
    FShowExponentialMovingAverage: Boolean;
    FSimpleMovingAveragePeriods: string;
    FExponentialMovingAveragePeriods: string;
    FShowBollingerBands: Boolean;
    FBollingerBandPeriods: string;
    FBollingerBandStandardDeviation: Double;
    FShowRsi: Boolean;
    FRsiPeriods: string;
    FRsiOversoldLevel: Double;
    FRsiOverboughtLevel: Double;
    FShowMacd: Boolean;
    FMacdFastPeriod: Integer;
    FMacdSlowPeriod: Integer;
    FMacdSignalPeriod: Integer;
    FShowStochastic: Boolean;
    FStochasticPeriod: Integer;
    FStochasticSmoothKPeriod: Integer;
    FStochasticDPeriod: Integer;
    FStochasticOversoldLevel: Double;
    FStochasticOverboughtLevel: Double;
    FShowAtr: Boolean;
    FAtrPeriods: string;
    FShowVwap: Boolean;
    FVwapResetBySession: Boolean;
    FShowCrosshair: Boolean;
    FShowLegend: Boolean;
    FShowGrid: Boolean;
    FShowAxes: Boolean;
    FShowAnnotations: Boolean;
    FShowToolTips: Boolean;
    FLockDetailsOnSelection: Boolean;
    FClearSelectionOnEmptyPlotClick: Boolean;
    FClearSelectionOnEscape: Boolean;
    FShowCrosshairWhileSelectionLocked: Boolean;
    FShowDashboardPanels: Boolean;
    FAutoBuildProductiveSidePanels: Boolean;
    FSidePanelLayoutMode: TNimbusFinancialSidePanelLayoutMode;
    FLeftSidePanelAreaWidth: Integer;
    FRightSidePanelAreaWidth: Integer;
    FAllowPanelLayoutChanges: Boolean;
    FAllowVolumePanelReorder: Boolean;
    FShowPanelDragAdorner: Boolean;
    FShowPanelDropZones: Boolean;
    FShowPanelContextMenu: Boolean;
    FShowBuiltInIndicatorSettingsDialog: Boolean;
    procedure SetSymbol(const Value: string);
    procedure SetExchange(const Value: string);
    procedure SetTimeFrame(const Value: TNimbusFinancialTimeFrame);
    procedure SetPriceMode(const Value: TNimbusFinancialPriceMode);
    procedure SetShowVolume(const Value: Boolean);
    procedure SetShowVolumeMovingAverage(const Value: Boolean);
    procedure SetVolumeMovingAveragePeriod(const Value: Integer);
    procedure SetShowSimpleMovingAverage(const Value: Boolean);
    procedure SetShowExponentialMovingAverage(const Value: Boolean);
    procedure SetSimpleMovingAveragePeriods(const Value: string);
    procedure SetExponentialMovingAveragePeriods(const Value: string);
    procedure SetShowBollingerBands(const Value: Boolean);
    procedure SetBollingerBandPeriods(const Value: string);
    procedure SetBollingerBandStandardDeviation(const Value: Double);
    procedure SetShowRsi(const Value: Boolean);
    procedure SetRsiPeriods(const Value: string);
    procedure SetRsiOversoldLevel(const Value: Double);
    procedure SetRsiOverboughtLevel(const Value: Double);
    procedure SetShowMacd(const Value: Boolean);
    procedure SetMacdFastPeriod(const Value: Integer);
    procedure SetMacdSlowPeriod(const Value: Integer);
    procedure SetMacdSignalPeriod(const Value: Integer);
    procedure SetShowStochastic(const Value: Boolean);
    procedure SetStochasticPeriod(const Value: Integer);
    procedure SetStochasticSmoothKPeriod(const Value: Integer);
    procedure SetStochasticDPeriod(const Value: Integer);
    procedure SetStochasticOversoldLevel(const Value: Double);
    procedure SetStochasticOverboughtLevel(const Value: Double);
    procedure SetShowAtr(const Value: Boolean);
    procedure SetAtrPeriods(const Value: string);
    procedure SetShowVwap(const Value: Boolean);
    procedure SetVwapResetBySession(const Value: Boolean);
    procedure SetShowCrosshair(const Value: Boolean);
    procedure SetShowLegend(const Value: Boolean);
    procedure SetShowGrid(const Value: Boolean);
    procedure SetShowAxes(const Value: Boolean);
    procedure SetShowAnnotations(const Value: Boolean);
    procedure SetShowToolTips(const Value: Boolean);
    procedure SetLockDetailsOnSelection(const Value: Boolean);
    procedure SetClearSelectionOnEmptyPlotClick(const Value: Boolean);
    procedure SetClearSelectionOnEscape(const Value: Boolean);
    procedure SetShowCrosshairWhileSelectionLocked(const Value: Boolean);
    procedure SetShowDashboardPanels(const Value: Boolean);
    procedure SetAutoBuildProductiveSidePanels(const Value: Boolean);
    procedure SetSidePanelLayoutMode(const Value: TNimbusFinancialSidePanelLayoutMode);
    procedure SetLeftSidePanelAreaWidth(const Value: Integer);
    procedure SetRightSidePanelAreaWidth(const Value: Integer);
    procedure SetAllowPanelLayoutChanges(const Value: Boolean);
    procedure SetAllowVolumePanelReorder(const Value: Boolean);
    procedure SetShowPanelDragAdorner(const Value: Boolean);
    procedure SetShowPanelDropZones(const Value: Boolean);
    procedure SetShowPanelContextMenu(const Value: Boolean);
    procedure SetShowBuiltInIndicatorSettingsDialog(const Value: Boolean);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property Symbol: string read FSymbol write SetSymbol;
    property Exchange: string read FExchange write SetExchange;
    property TimeFrame: TNimbusFinancialTimeFrame read FTimeFrame write SetTimeFrame;
    property PriceMode: TNimbusFinancialPriceMode read FPriceMode write SetPriceMode;
    property ShowVolume: Boolean read FShowVolume write SetShowVolume;
    property ShowVolumeMovingAverage: Boolean read FShowVolumeMovingAverage write SetShowVolumeMovingAverage;
    property VolumeMovingAveragePeriod: Integer read FVolumeMovingAveragePeriod write SetVolumeMovingAveragePeriod;
    property ShowSimpleMovingAverage: Boolean read FShowSimpleMovingAverage write SetShowSimpleMovingAverage;
    property ShowExponentialMovingAverage: Boolean read FShowExponentialMovingAverage write SetShowExponentialMovingAverage;
    property SimpleMovingAveragePeriods: string read FSimpleMovingAveragePeriods write SetSimpleMovingAveragePeriods;
    property ExponentialMovingAveragePeriods: string read FExponentialMovingAveragePeriods write SetExponentialMovingAveragePeriods;
    property ShowBollingerBands: Boolean read FShowBollingerBands write SetShowBollingerBands;
    property BollingerBandPeriods: string read FBollingerBandPeriods write SetBollingerBandPeriods;
    property BollingerBandStandardDeviation: Double read FBollingerBandStandardDeviation write SetBollingerBandStandardDeviation;
    property ShowRsi: Boolean read FShowRsi write SetShowRsi;
    property RsiPeriods: string read FRsiPeriods write SetRsiPeriods;
    property RsiOversoldLevel: Double read FRsiOversoldLevel write SetRsiOversoldLevel;
    property RsiOverboughtLevel: Double read FRsiOverboughtLevel write SetRsiOverboughtLevel;
    property ShowMacd: Boolean read FShowMacd write SetShowMacd;
    property MacdFastPeriod: Integer read FMacdFastPeriod write SetMacdFastPeriod;
    property MacdSlowPeriod: Integer read FMacdSlowPeriod write SetMacdSlowPeriod;
    property MacdSignalPeriod: Integer read FMacdSignalPeriod write SetMacdSignalPeriod;
    property ShowStochastic: Boolean read FShowStochastic write SetShowStochastic;
    property StochasticPeriod: Integer read FStochasticPeriod write SetStochasticPeriod;
    property StochasticSmoothKPeriod: Integer read FStochasticSmoothKPeriod write SetStochasticSmoothKPeriod;
    property StochasticDPeriod: Integer read FStochasticDPeriod write SetStochasticDPeriod;
    property StochasticOversoldLevel: Double read FStochasticOversoldLevel write SetStochasticOversoldLevel;
    property StochasticOverboughtLevel: Double read FStochasticOverboughtLevel write SetStochasticOverboughtLevel;
    property ShowAtr: Boolean read FShowAtr write SetShowAtr;
    property AtrPeriods: string read FAtrPeriods write SetAtrPeriods;
    property ShowVwap: Boolean read FShowVwap write SetShowVwap;
    property VwapResetBySession: Boolean read FVwapResetBySession write SetVwapResetBySession;
    property ShowCrosshair: Boolean read FShowCrosshair write SetShowCrosshair;
    property ShowLegend: Boolean read FShowLegend write SetShowLegend;
    property ShowGrid: Boolean read FShowGrid write SetShowGrid;
    property ShowAxes: Boolean read FShowAxes write SetShowAxes;
    property ShowAnnotations: Boolean read FShowAnnotations write SetShowAnnotations;
    property ShowToolTips: Boolean read FShowToolTips write SetShowToolTips;
    property LockDetailsOnSelection: Boolean read FLockDetailsOnSelection write SetLockDetailsOnSelection;
    property ClearSelectionOnEmptyPlotClick: Boolean read FClearSelectionOnEmptyPlotClick write SetClearSelectionOnEmptyPlotClick;
    property ClearSelectionOnEscape: Boolean read FClearSelectionOnEscape write SetClearSelectionOnEscape;
    property ShowCrosshairWhileSelectionLocked: Boolean read FShowCrosshairWhileSelectionLocked write SetShowCrosshairWhileSelectionLocked;
    property ShowDashboardPanels: Boolean read FShowDashboardPanels write SetShowDashboardPanels;
    property AutoBuildProductiveSidePanels: Boolean read FAutoBuildProductiveSidePanels write SetAutoBuildProductiveSidePanels;
    property SidePanelLayoutMode: TNimbusFinancialSidePanelLayoutMode read FSidePanelLayoutMode write SetSidePanelLayoutMode;
    property LeftSidePanelAreaWidth: Integer read FLeftSidePanelAreaWidth write SetLeftSidePanelAreaWidth;
    property RightSidePanelAreaWidth: Integer read FRightSidePanelAreaWidth write SetRightSidePanelAreaWidth;
    property AllowPanelLayoutChanges: Boolean read FAllowPanelLayoutChanges write SetAllowPanelLayoutChanges;
    property AllowVolumePanelReorder: Boolean read FAllowVolumePanelReorder write SetAllowVolumePanelReorder;
    property ShowPanelDragAdorner: Boolean read FShowPanelDragAdorner write SetShowPanelDragAdorner;
    property ShowPanelDropZones: Boolean read FShowPanelDropZones write SetShowPanelDropZones;
    property ShowPanelContextMenu: Boolean read FShowPanelContextMenu write SetShowPanelContextMenu;
    property ShowBuiltInIndicatorSettingsDialog: Boolean read FShowBuiltInIndicatorSettingsDialog write SetShowBuiltInIndicatorSettingsDialog;
  end;

implementation

procedure TNimbusFinancialPersistent.Changed;
begin Inc(FRevision); if Assigned(FOnChange) then FOnChange(Self) end;

constructor TNimbusFinancialPanelCollection.Create(AOwner: TPersistent);
begin inherited Create(AOwner, TNimbusFinancialPanel) end;

function TNimbusFinancialPanelCollection.GetItem(Index: Integer): TNimbusFinancialPanel;
begin Result := TNimbusFinancialPanel(inherited Items[Index]) end;

function TNimbusFinancialPanelCollection.Add: TNimbusFinancialPanel;
begin Result := TNimbusFinancialPanel(inherited Add) end;

function TNimbusFinancialPanelCollection.FindByKey(const Key: string): TNimbusFinancialPanel;
var I: Integer;
begin Result := nil; for I := 0 to Count - 1 do if SameText(Items[I].Key, Key) then Exit(Items[I]) end;

procedure TNimbusFinancialPanelCollection.Update(Item: TCollectionItem);
begin inherited; Inc(FRevision); if Assigned(FOnChange) then FOnChange(Self) end;

constructor TNimbusFinancialPanel.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FKey := '';
  FTitle := '';
  FSubtitle := '';
  FPanelType := nfptCustom;
  FState := nfpsExpanded;
  FHeightWeight := 1;
  FMinimumHeight := 48;
  FPreferredHeight := 120;
  FVisible := True;
  FShowGrid := True;
  FShowYAxis := True;
  FShowXAxis := False;
  FAllowSettings := True;
  FAllowClose := True;
  FAllowCollapse := True;
  FAllowResize := True;
  FAllowMove := True;
  FAllowPin := True;
  FIsPinned := False;
  FYAxisPosition := nfyapRight;
  FScaleMode := nfsmAuto;
  FManualMinimumValue := 0;
  FManualMaximumValue := 1;
  FFixedMinimumValue := 0;
  FFixedMaximumValue := 100;
  FScalePaddingRatio := 0.08;
  FValueFormat := '0.00';
  FTag := 0;
end;

procedure TNimbusFinancialPanel.Assign(Source: TPersistent);
var Other: TNimbusFinancialPanel;
begin
  if not (Source is TNimbusFinancialPanel) then begin inherited; Exit end; Other := TNimbusFinancialPanel(Source);
  FOnAction := Other.FOnAction;
  FKey := Other.FKey;
  FTitle := Other.FTitle;
  FSubtitle := Other.FSubtitle;
  FPanelType := Other.FPanelType;
  FState := Other.FState;
  FHeightWeight := Other.FHeightWeight;
  FMinimumHeight := Other.FMinimumHeight;
  FPreferredHeight := Other.FPreferredHeight;
  FVisible := Other.FVisible;
  FShowGrid := Other.FShowGrid;
  FShowYAxis := Other.FShowYAxis;
  FShowXAxis := Other.FShowXAxis;
  FAllowSettings := Other.FAllowSettings;
  FAllowClose := Other.FAllowClose;
  FAllowCollapse := Other.FAllowCollapse;
  FAllowResize := Other.FAllowResize;
  FAllowMove := Other.FAllowMove;
  FAllowPin := Other.FAllowPin;
  FIsPinned := Other.FIsPinned;
  FYAxisPosition := Other.FYAxisPosition;
  FScaleMode := Other.FScaleMode;
  FManualMinimumValue := Other.FManualMinimumValue;
  FManualMaximumValue := Other.FManualMaximumValue;
  FFixedMinimumValue := Other.FFixedMinimumValue;
  FFixedMaximumValue := Other.FFixedMaximumValue;
  FScalePaddingRatio := Other.FScalePaddingRatio;
  FValueFormat := Other.FValueFormat;
  FTag := Other.FTag;
  Changed(False);
end;

procedure TNimbusFinancialPanel.SetKey(const Value: string);
begin
  if FKey = Value then Exit; FKey := Value; Changed(False);
end;

procedure TNimbusFinancialPanel.SetTitle(const Value: string);
begin
  if FTitle = Value then Exit; FTitle := Value; Changed(False);
end;

procedure TNimbusFinancialPanel.SetSubtitle(const Value: string);
begin
  if FSubtitle = Value then Exit; FSubtitle := Value; Changed(False);
end;

procedure TNimbusFinancialPanel.SetPanelType(const Value: TNimbusFinancialPanelType);
begin
  if FPanelType = Value then Exit; FPanelType := Value; Changed(False);
end;

procedure TNimbusFinancialPanel.SetState(const Value: TNimbusFinancialPanelState);
begin
  if FState = Value then Exit; FState := Value; Changed(False);
end;

procedure TNimbusFinancialPanel.SetHeightWeight(const Value: Double);
var Effective: Double;
begin
  if IsNan(Value) or IsInfinite(Value) then raise EArgumentOutOfRangeException.Create('HeightWeight must be finite');
  Effective := Max(0.01, Value); if FHeightWeight = Effective then Exit; FHeightWeight := Effective; Changed(False);
end;

procedure TNimbusFinancialPanel.SetMinimumHeight(const Value: Integer);
var Effective: Integer;
begin
  Effective := Max(20, Value); if FMinimumHeight = Effective then Exit; FMinimumHeight := Effective; Changed(False);
end;

procedure TNimbusFinancialPanel.SetPreferredHeight(const Value: Integer);
var Effective: Integer;
begin
  Effective := Max(0, Value); if FPreferredHeight = Effective then Exit; FPreferredHeight := Effective; Changed(False);
end;

procedure TNimbusFinancialPanel.SetVisible(const Value: Boolean);
begin
  if FVisible = Value then Exit; FVisible := Value; Changed(False);
end;

procedure TNimbusFinancialPanel.SetShowGrid(const Value: Boolean);
begin
  if FShowGrid = Value then Exit; FShowGrid := Value; Changed(False);
end;

procedure TNimbusFinancialPanel.SetShowYAxis(const Value: Boolean);
begin
  if FShowYAxis = Value then Exit; FShowYAxis := Value; Changed(False);
end;

procedure TNimbusFinancialPanel.SetShowXAxis(const Value: Boolean);
begin
  if FShowXAxis = Value then Exit; FShowXAxis := Value; Changed(False);
end;

procedure TNimbusFinancialPanel.SetAllowSettings(const Value: Boolean);
begin
  if FAllowSettings = Value then Exit; FAllowSettings := Value; Changed(False);
end;

procedure TNimbusFinancialPanel.SetAllowClose(const Value: Boolean);
begin
  if FAllowClose = Value then Exit; FAllowClose := Value; Changed(False);
end;

procedure TNimbusFinancialPanel.SetAllowCollapse(const Value: Boolean);
begin
  if FAllowCollapse = Value then Exit; FAllowCollapse := Value; Changed(False);
end;

procedure TNimbusFinancialPanel.SetAllowResize(const Value: Boolean);
begin
  if FAllowResize = Value then Exit; FAllowResize := Value; Changed(False);
end;

procedure TNimbusFinancialPanel.SetAllowMove(const Value: Boolean);
begin
  if FAllowMove = Value then Exit; FAllowMove := Value; Changed(False);
end;

procedure TNimbusFinancialPanel.SetAllowPin(const Value: Boolean);
begin
  if FAllowPin = Value then Exit; FAllowPin := Value; Changed(False);
end;

procedure TNimbusFinancialPanel.SetIsPinned(const Value: Boolean);
begin
  if FIsPinned = Value then Exit; FIsPinned := Value; Changed(False);
end;

procedure TNimbusFinancialPanel.SetYAxisPosition(const Value: TNimbusFinancialYAxisPosition);
begin
  if FYAxisPosition = Value then Exit; FYAxisPosition := Value; Changed(False);
end;

procedure TNimbusFinancialPanel.SetScaleMode(const Value: TNimbusFinancialScaleMode);
begin
  if FScaleMode = Value then Exit; FScaleMode := Value; Changed(False);
end;

procedure TNimbusFinancialPanel.SetManualMinimumValue(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then raise EArgumentOutOfRangeException.Create('ManualMinimumValue must be finite');
  if FManualMinimumValue = Value then Exit; FManualMinimumValue := Value; Changed(False);
end;

procedure TNimbusFinancialPanel.SetManualMaximumValue(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then raise EArgumentOutOfRangeException.Create('ManualMaximumValue must be finite');
  if FManualMaximumValue = Value then Exit; FManualMaximumValue := Value; Changed(False);
end;

procedure TNimbusFinancialPanel.SetFixedMinimumValue(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then raise EArgumentOutOfRangeException.Create('FixedMinimumValue must be finite');
  if FFixedMinimumValue = Value then Exit; FFixedMinimumValue := Value; Changed(False);
end;

procedure TNimbusFinancialPanel.SetFixedMaximumValue(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then raise EArgumentOutOfRangeException.Create('FixedMaximumValue must be finite');
  if FFixedMaximumValue = Value then Exit; FFixedMaximumValue := Value; Changed(False);
end;

procedure TNimbusFinancialPanel.SetScalePaddingRatio(const Value: Double);
var Effective: Double;
begin
  if IsNan(Value) or IsInfinite(Value) then raise EArgumentOutOfRangeException.Create('ScalePaddingRatio must be finite');
  Effective := EnsureRange(Value, 0.0, 1.0); if FScalePaddingRatio = Effective then Exit; FScalePaddingRatio := Effective; Changed(False);
end;

procedure TNimbusFinancialPanel.SetValueFormat(const Value: string);
begin
  if FValueFormat = Value then Exit; FValueFormat := Value; Changed(False);
end;

procedure TNimbusFinancialPanel.SetTag(const Value: NativeInt);
begin
  if FTag = Value then Exit; FTag := Value; Changed(False);
end;

constructor TNimbusFinancialIndicatorCollection.Create(AOwner: TPersistent);
begin inherited Create(AOwner, TNimbusFinancialIndicator) end;

function TNimbusFinancialIndicatorCollection.GetItem(Index: Integer): TNimbusFinancialIndicator;
begin Result := TNimbusFinancialIndicator(inherited Items[Index]) end;

function TNimbusFinancialIndicatorCollection.Add: TNimbusFinancialIndicator;
begin Result := TNimbusFinancialIndicator(inherited Add) end;

function TNimbusFinancialIndicatorCollection.FindByKey(const Key: string): TNimbusFinancialIndicator;
var I: Integer;
begin Result := nil; for I := 0 to Count - 1 do if SameText(Items[I].Key, Key) then Exit(Items[I]) end;

procedure TNimbusFinancialIndicatorCollection.Update(Item: TCollectionItem);
begin inherited; Inc(FRevision); if Assigned(FOnChange) then FOnChange(Self) end;

constructor TNimbusFinancialIndicator.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FKey := '';
  FDisplayName := '';
  FPanelKey := 'price';
  FKind := nfikCustom;
  FVisible := True;
  FPeriods := '';
  FFastPeriod := 12;
  FSlowPeriod := 26;
  FSignalPeriod := 9;
  FSmoothKPeriod := 3;
  FStandardDeviation := 2;
  FOversoldLevel := 30;
  FOverboughtLevel := 70;
  FResetBySession := False;
  FColor := clNone;
  FSecondaryColor := clNone;
  FTag := 0;
end;

procedure TNimbusFinancialIndicator.Assign(Source: TPersistent);
var Other: TNimbusFinancialIndicator;
begin
  if not (Source is TNimbusFinancialIndicator) then begin inherited; Exit end; Other := TNimbusFinancialIndicator(Source);
  FKey := Other.FKey;
  FDisplayName := Other.FDisplayName;
  FPanelKey := Other.FPanelKey;
  FKind := Other.FKind;
  FVisible := Other.FVisible;
  FPeriods := Other.FPeriods;
  FFastPeriod := Other.FFastPeriod;
  FSlowPeriod := Other.FSlowPeriod;
  FSignalPeriod := Other.FSignalPeriod;
  FSmoothKPeriod := Other.FSmoothKPeriod;
  FStandardDeviation := Other.FStandardDeviation;
  FOversoldLevel := Other.FOversoldLevel;
  FOverboughtLevel := Other.FOverboughtLevel;
  FResetBySession := Other.FResetBySession;
  FColor := Other.FColor;
  FSecondaryColor := Other.FSecondaryColor;
  FTag := Other.FTag; FValues := Copy(Other.FValues);
  Changed(False);
end;

procedure TNimbusFinancialIndicator.SetValues(const Value: TArray<Double>);
begin FValues := Copy(Value); Changed(False) end;

procedure TNimbusFinancialIndicator.SetKey(const Value: string);
begin
  if FKey = Value then Exit; FKey := Value; Changed(False);
end;

procedure TNimbusFinancialIndicator.SetDisplayName(const Value: string);
begin
  if FDisplayName = Value then Exit; FDisplayName := Value; Changed(False);
end;

procedure TNimbusFinancialIndicator.SetPanelKey(const Value: string);
begin
  if FPanelKey = Value then Exit; FPanelKey := Value; Changed(False);
end;

procedure TNimbusFinancialIndicator.SetKind(const Value: TNimbusFinancialIndicatorKind);
begin
  if FKind = Value then Exit; FKind := Value; Changed(False);
end;

procedure TNimbusFinancialIndicator.SetVisible(const Value: Boolean);
begin
  if FVisible = Value then Exit; FVisible := Value; Changed(False);
end;

procedure TNimbusFinancialIndicator.SetPeriods(const Value: string);
begin
  if FPeriods = Value then Exit; FPeriods := Value; Changed(False);
end;

procedure TNimbusFinancialIndicator.SetFastPeriod(const Value: Integer);
var Effective: Integer;
begin
  Effective := EnsureRange(Value, 2, 1000); if FFastPeriod = Effective then Exit; FFastPeriod := Effective; Changed(False);
end;

procedure TNimbusFinancialIndicator.SetSlowPeriod(const Value: Integer);
var Effective: Integer;
begin
  Effective := EnsureRange(Value, 2, 1000); if FSlowPeriod = Effective then Exit; FSlowPeriod := Effective; Changed(False);
end;

procedure TNimbusFinancialIndicator.SetSignalPeriod(const Value: Integer);
var Effective: Integer;
begin
  Effective := EnsureRange(Value, 2, 1000); if FSignalPeriod = Effective then Exit; FSignalPeriod := Effective; Changed(False);
end;

procedure TNimbusFinancialIndicator.SetSmoothKPeriod(const Value: Integer);
var Effective: Integer;
begin
  Effective := EnsureRange(Value, 1, 1000); if FSmoothKPeriod = Effective then Exit; FSmoothKPeriod := Effective; Changed(False);
end;

procedure TNimbusFinancialIndicator.SetStandardDeviation(const Value: Double);
var Effective: Double;
begin
  if IsNan(Value) or IsInfinite(Value) then raise EArgumentOutOfRangeException.Create('StandardDeviation must be finite');
  Effective := Max(0.01, Value); if FStandardDeviation = Effective then Exit; FStandardDeviation := Effective; Changed(False);
end;

procedure TNimbusFinancialIndicator.SetOversoldLevel(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then raise EArgumentOutOfRangeException.Create('OversoldLevel must be finite');
  if FOversoldLevel = Value then Exit; FOversoldLevel := Value; Changed(False);
end;

procedure TNimbusFinancialIndicator.SetOverboughtLevel(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then raise EArgumentOutOfRangeException.Create('OverboughtLevel must be finite');
  if FOverboughtLevel = Value then Exit; FOverboughtLevel := Value; Changed(False);
end;

procedure TNimbusFinancialIndicator.SetResetBySession(const Value: Boolean);
begin
  if FResetBySession = Value then Exit; FResetBySession := Value; Changed(False);
end;

procedure TNimbusFinancialIndicator.SetColor(const Value: TColor);
begin
  if FColor = Value then Exit; FColor := Value; Changed(False);
end;

procedure TNimbusFinancialIndicator.SetSecondaryColor(const Value: TColor);
begin
  if FSecondaryColor = Value then Exit; FSecondaryColor := Value; Changed(False);
end;

procedure TNimbusFinancialIndicator.SetTag(const Value: NativeInt);
begin
  if FTag = Value then Exit; FTag := Value; Changed(False);
end;

constructor TNimbusFinancialPanelItemCollection.Create(AOwner: TPersistent);
begin inherited Create(AOwner, TNimbusFinancialPanelItem) end;

function TNimbusFinancialPanelItemCollection.GetItem(Index: Integer): TNimbusFinancialPanelItem;
begin Result := TNimbusFinancialPanelItem(inherited Items[Index]) end;

function TNimbusFinancialPanelItemCollection.Add: TNimbusFinancialPanelItem;
begin Result := TNimbusFinancialPanelItem(inherited Add) end;

function TNimbusFinancialPanelItemCollection.FindByKey(const Key: string): TNimbusFinancialPanelItem;
var I: Integer;
begin Result := nil; for I := 0 to Count - 1 do if SameText(Items[I].Key, Key) then Exit(Items[I]) end;

procedure TNimbusFinancialPanelItemCollection.Update(Item: TCollectionItem);
begin inherited; Inc(FRevision); if Assigned(FOnChange) then FOnChange(Self) end;

constructor TNimbusFinancialPanelItem.Create(Collection: TCollection);
begin
  inherited Create(Collection); FCandleIndex := -1;
  FKey := '';
  FKind := nfpiText;
  FText := '';
  FValue := '';
  FSecondaryValue := '';
  FNumericValue := 0;
  FChangeValue := 0;
  FChangePercent := 0;
  FHeight := 32;
  FVisible := True;
  FTag := 0;
end;

procedure TNimbusFinancialPanelItem.Assign(Source: TPersistent);
var Other: TNimbusFinancialPanelItem;
begin
  if not (Source is TNimbusFinancialPanelItem) then begin inherited; Exit end; Other := TNimbusFinancialPanelItem(Source);
  FCandleIndex := Other.FCandleIndex;
  FKey := Other.FKey;
  FKind := Other.FKind;
  FText := Other.FText;
  FValue := Other.FValue;
  FSecondaryValue := Other.FSecondaryValue;
  FNumericValue := Other.FNumericValue;
  FChangeValue := Other.FChangeValue;
  FChangePercent := Other.FChangePercent;
  FHeight := Other.FHeight;
  FVisible := Other.FVisible;
  FTag := Other.FTag;
  FValues := Copy(Other.FValues);
  Changed(False);
end;

procedure TNimbusFinancialPanelItem.SetKey(const Value: string);
begin
  if FKey = Value then Exit; FKey := Value; Changed(False);
end;

procedure TNimbusFinancialPanelItem.SetKind(const Value: TNimbusFinancialPanelItemKind);
begin
  if FKind = Value then Exit; FKind := Value; Changed(False);
end;

procedure TNimbusFinancialPanelItem.SetText(const Value: string);
begin
  if FText = Value then Exit; FText := Value; Changed(False);
end;

procedure TNimbusFinancialPanelItem.SetValue(const Value: string);
begin
  if FValue = Value then Exit; FValue := Value; Changed(False);
end;

procedure TNimbusFinancialPanelItem.SetSecondaryValue(const Value: string);
begin
  if FSecondaryValue = Value then Exit; FSecondaryValue := Value; Changed(False);
end;

procedure TNimbusFinancialPanelItem.SetNumericValue(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then raise EArgumentOutOfRangeException.Create('NumericValue must be finite');
  if FNumericValue = Value then Exit; FNumericValue := Value; Changed(False);
end;

procedure TNimbusFinancialPanelItem.SetChangeValue(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then raise EArgumentOutOfRangeException.Create('ChangeValue must be finite');
  if FChangeValue = Value then Exit; FChangeValue := Value; Changed(False);
end;

procedure TNimbusFinancialPanelItem.SetChangePercent(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then raise EArgumentOutOfRangeException.Create('ChangePercent must be finite');
  if FChangePercent = Value then Exit; FChangePercent := Value; Changed(False);
end;

procedure TNimbusFinancialPanelItem.SetHeight(const Value: Integer);
var Effective: Integer;
begin
  Effective := Max(8, Value); if FHeight = Effective then Exit; FHeight := Effective; Changed(False);
end;

procedure TNimbusFinancialPanelItem.SetVisible(const Value: Boolean);
begin
  if FVisible = Value then Exit; FVisible := Value; Changed(False);
end;

procedure TNimbusFinancialPanelItem.SetTag(const Value: NativeInt);
begin
  if FTag = Value then Exit; FTag := Value; Changed(False);
end;

procedure TNimbusFinancialPanelItem.SetValues(const Value: TArray<Double>);
begin FValues := Copy(Value); Changed(False) end;

constructor TNimbusFinancialSidePanelCollection.Create(AOwner: TPersistent);
begin inherited Create(AOwner, TNimbusFinancialSidePanel) end;

function TNimbusFinancialSidePanelCollection.GetItem(Index: Integer): TNimbusFinancialSidePanel;
begin Result := TNimbusFinancialSidePanel(inherited Items[Index]) end;

function TNimbusFinancialSidePanelCollection.Add: TNimbusFinancialSidePanel;
begin Result := TNimbusFinancialSidePanel(inherited Add) end;

function TNimbusFinancialSidePanelCollection.FindByKey(const Key: string): TNimbusFinancialSidePanel;
var I: Integer;
begin Result := nil; for I := 0 to Count - 1 do if SameText(Items[I].Key, Key) then Exit(Items[I]) end;

procedure TNimbusFinancialSidePanelCollection.Update(Item: TCollectionItem);
begin inherited; Inc(FRevision); if Assigned(FOnChange) then FOnChange(Self) end;

constructor TNimbusFinancialSidePanel.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FKey := '';
  FTitle := '';
  FKind := nfspDetails;
  FPosition := nfsppRight;
  FState := nfspsExpanded;
  FVisible := True;
  FResizable := True;
  FPinned := True;
  FWidth := 260;
  FMinimumWidth := 160;
  FMaximumWidth := 520;
  FCollapsedWidth := 34;
  FPreferredHeight := 240;
  FMinimumHeight := 110;
  FMaximumHeight := 900;
  FScrollOffset := 0;
  FTag := 0;
  FItems := TNimbusFinancialPanelItemCollection.Create(Self); FItems.OnChange := ItemsChanged;
end;

procedure TNimbusFinancialSidePanel.Assign(Source: TPersistent);
var Other: TNimbusFinancialSidePanel;
begin
  if not (Source is TNimbusFinancialSidePanel) then begin inherited; Exit end; Other := TNimbusFinancialSidePanel(Source);
  FOnAction := Other.FOnAction;
  FOnRowClicked := Other.FOnRowClicked;
  FOnRowDoubleClicked := Other.FOnRowDoubleClicked;
  FOnRowHovered := Other.FOnRowHovered;
  FOnRowContextMenu := Other.FOnRowContextMenu;
  FKey := Other.FKey;
  FTitle := Other.FTitle;
  FKind := Other.FKind;
  FPosition := Other.FPosition;
  FState := Other.FState;
  FVisible := Other.FVisible;
  FResizable := Other.FResizable;
  FPinned := Other.FPinned;
  FWidth := Other.FWidth;
  FMinimumWidth := Other.FMinimumWidth;
  FMaximumWidth := Other.FMaximumWidth;
  FCollapsedWidth := Other.FCollapsedWidth;
  FPreferredHeight := Other.FPreferredHeight;
  FMinimumHeight := Other.FMinimumHeight;
  FMaximumHeight := Other.FMaximumHeight;
  FScrollOffset := Other.FScrollOffset;
  FTag := Other.FTag;
  FItems.Assign(Other.FItems);
  Changed(False);
end;

procedure TNimbusFinancialSidePanel.SetKey(const Value: string);
begin
  if FKey = Value then Exit; FKey := Value; Changed(False);
end;

procedure TNimbusFinancialSidePanel.SetTitle(const Value: string);
begin
  if FTitle = Value then Exit; FTitle := Value; Changed(False);
end;

procedure TNimbusFinancialSidePanel.SetKind(const Value: TNimbusFinancialSidePanelKind);
begin
  if FKind = Value then Exit; FKind := Value; Changed(False);
end;

procedure TNimbusFinancialSidePanel.SetPosition(const Value: TNimbusFinancialSidePanelPosition);
begin
  if FPosition = Value then Exit; FPosition := Value; Changed(False);
end;

procedure TNimbusFinancialSidePanel.SetState(const Value: TNimbusFinancialSidePanelState);
begin
  if FState = Value then Exit; FState := Value; Changed(False);
end;

procedure TNimbusFinancialSidePanel.SetVisible(const Value: Boolean);
begin
  if FVisible = Value then Exit; FVisible := Value; Changed(False);
end;

procedure TNimbusFinancialSidePanel.SetResizable(const Value: Boolean);
begin
  if FResizable = Value then Exit; FResizable := Value; Changed(False);
end;

procedure TNimbusFinancialSidePanel.SetPinned(const Value: Boolean);
begin
  if FPinned = Value then Exit; FPinned := Value; Changed(False);
end;

procedure TNimbusFinancialSidePanel.SetWidth(const Value: Integer);
var Effective: Integer;
begin
  Effective := EnsureRange(Value, 34, 1200); if FWidth = Effective then Exit; FWidth := Effective; Changed(False);
end;

procedure TNimbusFinancialSidePanel.SetMinimumWidth(const Value: Integer);
var Effective: Integer;
begin
  Effective := Max(34, Value); if FMinimumWidth = Effective then Exit; FMinimumWidth := Effective; Changed(False);
end;

procedure TNimbusFinancialSidePanel.SetMaximumWidth(const Value: Integer);
var Effective: Integer;
begin
  Effective := Max(34, Value); if FMaximumWidth = Effective then Exit; FMaximumWidth := Effective; Changed(False);
end;

procedure TNimbusFinancialSidePanel.SetCollapsedWidth(const Value: Integer);
var Effective: Integer;
begin
  Effective := Max(20, Value); if FCollapsedWidth = Effective then Exit; FCollapsedWidth := Effective; Changed(False);
end;

procedure TNimbusFinancialSidePanel.SetPreferredHeight(const Value: Integer);
var Effective: Integer;
begin
  Effective := Max(30, Value); if FPreferredHeight = Effective then Exit; FPreferredHeight := Effective; Changed(False);
end;

procedure TNimbusFinancialSidePanel.SetMinimumHeight(const Value: Integer);
var Effective: Integer;
begin
  Effective := Max(30, Value); if FMinimumHeight = Effective then Exit; FMinimumHeight := Effective; Changed(False);
end;

procedure TNimbusFinancialSidePanel.SetMaximumHeight(const Value: Integer);
var Effective: Integer;
begin
  Effective := Max(30, Value); if FMaximumHeight = Effective then Exit; FMaximumHeight := Effective; Changed(False);
end;

procedure TNimbusFinancialSidePanel.SetScrollOffset(const Value: Integer);
var Effective: Integer;
begin
  Effective := Max(0, Value); if FScrollOffset = Effective then Exit; FScrollOffset := Effective; Changed(False);
end;

procedure TNimbusFinancialSidePanel.SetTag(const Value: NativeInt);
begin
  if FTag = Value then Exit; FTag := Value; Changed(False);
end;

destructor TNimbusFinancialSidePanel.Destroy;
begin FItems.OnChange := nil; FItems.Free; inherited end;

procedure TNimbusFinancialSidePanel.SetItems(const Value: TNimbusFinancialPanelItemCollection);
begin if Value <> nil then FItems.Assign(Value) end;

procedure TNimbusFinancialSidePanel.ItemsChanged(Sender: TObject);
begin Changed(False) end;

constructor TNimbusFinancialMarkerCollection.Create(AOwner: TPersistent);
begin inherited Create(AOwner, TNimbusFinancialMarker) end;

function TNimbusFinancialMarkerCollection.GetItem(Index: Integer): TNimbusFinancialMarker;
begin Result := TNimbusFinancialMarker(inherited Items[Index]) end;

function TNimbusFinancialMarkerCollection.Add: TNimbusFinancialMarker;
begin Result := TNimbusFinancialMarker(inherited Add) end;

function TNimbusFinancialMarkerCollection.FindByKey(const Key: string): TNimbusFinancialMarker;
var I: Integer;
begin Result := nil; for I := 0 to Count - 1 do if SameText(Items[I].Key, Key) then Exit(Items[I]) end;

procedure TNimbusFinancialMarkerCollection.Update(Item: TCollectionItem);
begin inherited; Inc(FRevision); if Assigned(FOnChange) then FOnChange(Self) end;

constructor TNimbusFinancialMarker.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FKey := '';
  FText := '';
  FDescription := '';
  FTime := 0;
  FCandleIndex := -1;
  FValue := 0;
  FUseValue := False;
  FVisible := True;
  FKind := nfmkCustom;
  FStyle := nfmsCircle;
  FAnchor := nfmaAboveCandle;
  FColor := clNone;
  FBorderColor := clNone;
  FTag := 0;
end;

procedure TNimbusFinancialMarker.Assign(Source: TPersistent);
var Other: TNimbusFinancialMarker;
begin
  if not (Source is TNimbusFinancialMarker) then begin inherited; Exit end; Other := TNimbusFinancialMarker(Source);
  FKey := Other.FKey;
  FText := Other.FText;
  FDescription := Other.FDescription;
  FTime := Other.FTime;
  FCandleIndex := Other.FCandleIndex;
  FValue := Other.FValue;
  FUseValue := Other.FUseValue;
  FVisible := Other.FVisible;
  FKind := Other.FKind;
  FStyle := Other.FStyle;
  FAnchor := Other.FAnchor;
  FColor := Other.FColor;
  FBorderColor := Other.FBorderColor;
  FTag := Other.FTag;
  Changed(False);
end;

procedure TNimbusFinancialMarker.SetKey(const Value: string);
begin
  if FKey = Value then Exit; FKey := Value; Changed(False);
end;

procedure TNimbusFinancialMarker.SetText(const Value: string);
begin
  if FText = Value then Exit; FText := Value; Changed(False);
end;

procedure TNimbusFinancialMarker.SetDescription(const Value: string);
begin
  if FDescription = Value then Exit; FDescription := Value; Changed(False);
end;

procedure TNimbusFinancialMarker.SetTime(const Value: TDateTime);
begin
  if IsNan(Value) or IsInfinite(Value) then raise EArgumentOutOfRangeException.Create('Time must be finite');
  if FTime = Value then Exit; FTime := Value; Changed(False);
end;

procedure TNimbusFinancialMarker.SetCandleIndex(const Value: Integer);
begin
  if FCandleIndex = Value then Exit; FCandleIndex := Value; Changed(False);
end;

procedure TNimbusFinancialMarker.SetValue(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then raise EArgumentOutOfRangeException.Create('Value must be finite');
  if FValue = Value then Exit; FValue := Value; Changed(False);
end;

procedure TNimbusFinancialMarker.SetUseValue(const Value: Boolean);
begin
  if FUseValue = Value then Exit; FUseValue := Value; Changed(False);
end;

procedure TNimbusFinancialMarker.SetVisible(const Value: Boolean);
begin
  if FVisible = Value then Exit; FVisible := Value; Changed(False);
end;

procedure TNimbusFinancialMarker.SetKind(const Value: TNimbusFinancialMarkerKind);
begin
  if FKind = Value then Exit; FKind := Value; Changed(False);
end;

procedure TNimbusFinancialMarker.SetStyle(const Value: TNimbusFinancialMarkerStyle);
begin
  if FStyle = Value then Exit; FStyle := Value; Changed(False);
end;

procedure TNimbusFinancialMarker.SetAnchor(const Value: TNimbusFinancialMarkerAnchor);
begin
  if FAnchor = Value then Exit; FAnchor := Value; Changed(False);
end;

procedure TNimbusFinancialMarker.SetColor(const Value: TColor);
begin
  if FColor = Value then Exit; FColor := Value; Changed(False);
end;

procedure TNimbusFinancialMarker.SetBorderColor(const Value: TColor);
begin
  if FBorderColor = Value then Exit; FBorderColor := Value; Changed(False);
end;

procedure TNimbusFinancialMarker.SetTag(const Value: NativeInt);
begin
  if FTag = Value then Exit; FTag := Value; Changed(False);
end;

constructor TNimbusFinancialAnnotationCollection.Create(AOwner: TPersistent);
begin inherited Create(AOwner, TNimbusFinancialAnnotation) end;

function TNimbusFinancialAnnotationCollection.GetItem(Index: Integer): TNimbusFinancialAnnotation;
begin Result := TNimbusFinancialAnnotation(inherited Items[Index]) end;

function TNimbusFinancialAnnotationCollection.Add: TNimbusFinancialAnnotation;
begin Result := TNimbusFinancialAnnotation(inherited Add) end;

function TNimbusFinancialAnnotationCollection.FindByKey(const Key: string): TNimbusFinancialAnnotation;
var I: Integer;
begin Result := nil; for I := 0 to Count - 1 do if SameText(Items[I].Key, Key) then Exit(Items[I]) end;

procedure TNimbusFinancialAnnotationCollection.Update(Item: TCollectionItem);
begin inherited; Inc(FRevision); if Assigned(FOnChange) then FOnChange(Self) end;

constructor TNimbusFinancialAnnotation.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FKey := '';
  FText := '';
  FDescription := '';
  FVisible := True;
  FKind := nfakHorizontalLine;
  FCoordinateMode := nfcmIndex;
  FStartTime := 0;
  FEndTime := 0;
  FStartIndex := 0;
  FEndIndex := 0;
  FStartValue := 0;
  FEndValue := 0;
  FLineColor := clNone;
  FFillColor := clNone;
  FTextColor := clNone;
  FLineWidth := 1.5;
  FSelectable := True;
  FLocked := False;
  FTag := 0;
end;

procedure TNimbusFinancialAnnotation.Assign(Source: TPersistent);
var Other: TNimbusFinancialAnnotation;
begin
  if not (Source is TNimbusFinancialAnnotation) then begin inherited; Exit end; Other := TNimbusFinancialAnnotation(Source);
  FKey := Other.FKey;
  FText := Other.FText;
  FDescription := Other.FDescription;
  FVisible := Other.FVisible;
  FKind := Other.FKind;
  FCoordinateMode := Other.FCoordinateMode;
  FStartTime := Other.FStartTime;
  FEndTime := Other.FEndTime;
  FStartIndex := Other.FStartIndex;
  FEndIndex := Other.FEndIndex;
  FStartValue := Other.FStartValue;
  FEndValue := Other.FEndValue;
  FLineColor := Other.FLineColor;
  FFillColor := Other.FFillColor;
  FTextColor := Other.FTextColor;
  FDashStyle := Other.FDashStyle;
  FLineWidth := Other.FLineWidth;
  FSelectable := Other.FSelectable;
  FLocked := Other.FLocked;
  FTag := Other.FTag;
  Changed(False);
end;

procedure TNimbusFinancialAnnotation.SetKey(const Value: string);
begin
  if FKey = Value then Exit; FKey := Value; Changed(False);
end;

procedure TNimbusFinancialAnnotation.SetText(const Value: string);
begin
  if FText = Value then Exit; FText := Value; Changed(False);
end;

procedure TNimbusFinancialAnnotation.SetDescription(const Value: string);
begin
  if FDescription = Value then Exit; FDescription := Value; Changed(False);
end;

procedure TNimbusFinancialAnnotation.SetVisible(const Value: Boolean);
begin
  if FVisible = Value then Exit; FVisible := Value; Changed(False);
end;

procedure TNimbusFinancialAnnotation.SetKind(const Value: TNimbusFinancialAnnotationKind);
begin
  if FKind = Value then Exit; FKind := Value; Changed(False);
end;

procedure TNimbusFinancialAnnotation.SetCoordinateMode(const Value: TNimbusFinancialCoordinateMode);
begin
  if FCoordinateMode = Value then Exit; FCoordinateMode := Value; Changed(False);
end;

procedure TNimbusFinancialAnnotation.SetStartTime(const Value: TDateTime);
begin
  if IsNan(Value) or IsInfinite(Value) then raise EArgumentOutOfRangeException.Create('StartTime must be finite');
  if FStartTime = Value then Exit; FStartTime := Value; Changed(False);
end;

procedure TNimbusFinancialAnnotation.SetEndTime(const Value: TDateTime);
begin
  if IsNan(Value) or IsInfinite(Value) then raise EArgumentOutOfRangeException.Create('EndTime must be finite');
  if FEndTime = Value then Exit; FEndTime := Value; Changed(False);
end;

procedure TNimbusFinancialAnnotation.SetStartIndex(const Value: Integer);
begin
  if FStartIndex = Value then Exit; FStartIndex := Value; Changed(False);
end;

procedure TNimbusFinancialAnnotation.SetEndIndex(const Value: Integer);
begin
  if FEndIndex = Value then Exit; FEndIndex := Value; Changed(False);
end;

procedure TNimbusFinancialAnnotation.SetStartValue(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then raise EArgumentOutOfRangeException.Create('StartValue must be finite');
  if FStartValue = Value then Exit; FStartValue := Value; Changed(False);
end;

procedure TNimbusFinancialAnnotation.SetEndValue(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then raise EArgumentOutOfRangeException.Create('EndValue must be finite');
  if FEndValue = Value then Exit; FEndValue := Value; Changed(False);
end;

procedure TNimbusFinancialAnnotation.SetLineColor(const Value: TColor);
begin
  if FLineColor = Value then Exit; FLineColor := Value; Changed(False);
end;

procedure TNimbusFinancialAnnotation.SetFillColor(const Value: TColor);
begin
  if FFillColor = Value then Exit; FFillColor := Value; Changed(False);
end;

procedure TNimbusFinancialAnnotation.SetTextColor(const Value: TColor);
begin
  if FTextColor = Value then Exit; FTextColor := Value; Changed(False);
end;

procedure TNimbusFinancialAnnotation.SetDashStyle(const Value: TPenStyle);
begin if FDashStyle <> Value then begin FDashStyle := Value; Changed(False) end end;

procedure TNimbusFinancialAnnotation.SetLineWidth(const Value: Double);
var Effective: Double;
begin
  if IsNan(Value) or IsInfinite(Value) then raise EArgumentOutOfRangeException.Create('LineWidth must be finite');
  Effective := EnsureRange(Value, 0.1, 20.0); if FLineWidth = Effective then Exit; FLineWidth := Effective; Changed(False);
end;

procedure TNimbusFinancialAnnotation.SetSelectable(const Value: Boolean);
begin
  if FSelectable = Value then Exit; FSelectable := Value; Changed(False);
end;

procedure TNimbusFinancialAnnotation.SetLocked(const Value: Boolean);
begin
  if FLocked = Value then Exit; FLocked := Value; Changed(False);
end;

procedure TNimbusFinancialAnnotation.SetTag(const Value: NativeInt);
begin
  if FTag = Value then Exit; FTag := Value; Changed(False);
end;

constructor TNimbusFinancialRangeButtonCollection.Create(AOwner: TPersistent);
begin inherited Create(AOwner, TNimbusFinancialRangeButton) end;

function TNimbusFinancialRangeButtonCollection.GetItem(Index: Integer): TNimbusFinancialRangeButton;
begin Result := TNimbusFinancialRangeButton(inherited Items[Index]) end;

function TNimbusFinancialRangeButtonCollection.Add: TNimbusFinancialRangeButton;
begin Result := TNimbusFinancialRangeButton(inherited Add) end;

function TNimbusFinancialRangeButtonCollection.FindByKey(const Key: string): TNimbusFinancialRangeButton;
var I: Integer;
begin Result := nil; for I := 0 to Count - 1 do if SameText(Items[I].Key, Key) then Exit(Items[I]) end;

procedure TNimbusFinancialRangeButtonCollection.Update(Item: TCollectionItem);
begin inherited; Inc(FRevision); if Assigned(FOnChange) then FOnChange(Self) end;

constructor TNimbusFinancialRangeButton.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FKey := '';
  FText := '';
  FRangeKind := nfrkAll;
  FValue := 0;
  FVisible := True;
  FEnabled := True;
  FSelected := False;
end;

procedure TNimbusFinancialRangeButton.Assign(Source: TPersistent);
var Other: TNimbusFinancialRangeButton;
begin
  if not (Source is TNimbusFinancialRangeButton) then begin inherited; Exit end; Other := TNimbusFinancialRangeButton(Source);
  FKey := Other.FKey;
  FText := Other.FText;
  FRangeKind := Other.FRangeKind;
  FValue := Other.FValue;
  FVisible := Other.FVisible;
  FEnabled := Other.FEnabled;
  FSelected := Other.FSelected;
  Changed(False);
end;

procedure TNimbusFinancialRangeButton.SetKey(const Value: string);
begin
  if FKey = Value then Exit; FKey := Value; Changed(False);
end;

procedure TNimbusFinancialRangeButton.SetText(const Value: string);
begin
  if FText = Value then Exit; FText := Value; Changed(False);
end;

procedure TNimbusFinancialRangeButton.SetRangeKind(const Value: TNimbusFinancialRangeKind);
begin
  if FRangeKind = Value then Exit; FRangeKind := Value; Changed(False);
end;

procedure TNimbusFinancialRangeButton.SetValue(const Value: Integer);
var Effective: Integer;
begin
  Effective := Max(0, Value); if FValue = Effective then Exit; FValue := Effective; Changed(False);
end;

procedure TNimbusFinancialRangeButton.SetVisible(const Value: Boolean);
begin
  if FVisible = Value then Exit; FVisible := Value; Changed(False);
end;

procedure TNimbusFinancialRangeButton.SetEnabled(const Value: Boolean);
begin
  if FEnabled = Value then Exit; FEnabled := Value; Changed(False);
end;

procedure TNimbusFinancialRangeButton.SetSelected(const Value: Boolean);
begin
  if FSelected = Value then Exit; FSelected := Value; Changed(False);
end;

constructor TNimbusFinancialInteractionOptions.Create;
begin
  inherited Create;
  FPanMouseButtons := [mbMiddle, mbRight];
  FEnableMouseWheelZoom := True;
  FEnableCtrlMouseWheelZoom := True;
  FEnableShiftMouseWheelPan := True;
  FEnableDragPan := True;
  FEnableLeftButtonDragPan := True;
  FEnableKeyboardNavigation := True;
  FDragPanThreshold := 4;
  FMouseWheelPanCandles := 8;
  FPagePanRatio := 0.8;
  FKeyboardZoomFactor := 1.18;
end;

procedure TNimbusFinancialInteractionOptions.Assign(Source: TPersistent);
var Other: TNimbusFinancialInteractionOptions;
begin
  if not (Source is TNimbusFinancialInteractionOptions) then begin inherited; Exit end; Other := TNimbusFinancialInteractionOptions(Source);
  FPanMouseButtons := Other.FPanMouseButtons;
  FEnableMouseWheelZoom := Other.FEnableMouseWheelZoom;
  FEnableCtrlMouseWheelZoom := Other.FEnableCtrlMouseWheelZoom;
  FEnableShiftMouseWheelPan := Other.FEnableShiftMouseWheelPan;
  FEnableDragPan := Other.FEnableDragPan;
  FEnableLeftButtonDragPan := Other.FEnableLeftButtonDragPan;
  FEnableKeyboardNavigation := Other.FEnableKeyboardNavigation;
  FDragPanThreshold := Other.FDragPanThreshold;
  FMouseWheelPanCandles := Other.FMouseWheelPanCandles;
  FPagePanRatio := Other.FPagePanRatio;
  FKeyboardZoomFactor := Other.FKeyboardZoomFactor;
  Changed;
end;

procedure TNimbusFinancialInteractionOptions.SetPanMouseButtons(const Value: TNimbusFinancialPanMouseButtons);
begin if FPanMouseButtons <> Value then begin FPanMouseButtons := Value; Changed end end;

procedure TNimbusFinancialInteractionOptions.SetEnableMouseWheelZoom(const Value: Boolean);
begin
  if FEnableMouseWheelZoom = Value then Exit; FEnableMouseWheelZoom := Value; Changed;
end;

procedure TNimbusFinancialInteractionOptions.SetEnableCtrlMouseWheelZoom(const Value: Boolean);
begin
  if FEnableCtrlMouseWheelZoom = Value then Exit; FEnableCtrlMouseWheelZoom := Value; Changed;
end;

procedure TNimbusFinancialInteractionOptions.SetEnableShiftMouseWheelPan(const Value: Boolean);
begin
  if FEnableShiftMouseWheelPan = Value then Exit; FEnableShiftMouseWheelPan := Value; Changed;
end;

procedure TNimbusFinancialInteractionOptions.SetEnableDragPan(const Value: Boolean);
begin
  if FEnableDragPan = Value then Exit; FEnableDragPan := Value; Changed;
end;

procedure TNimbusFinancialInteractionOptions.SetEnableLeftButtonDragPan(const Value: Boolean);
begin
  if FEnableLeftButtonDragPan = Value then Exit; FEnableLeftButtonDragPan := Value; Changed;
end;

procedure TNimbusFinancialInteractionOptions.SetEnableKeyboardNavigation(const Value: Boolean);
begin
  if FEnableKeyboardNavigation = Value then Exit; FEnableKeyboardNavigation := Value; Changed;
end;

procedure TNimbusFinancialInteractionOptions.SetDragPanThreshold(const Value: Integer);
var Effective: Integer;
begin
  Effective := Max(0, Value); if FDragPanThreshold = Effective then Exit; FDragPanThreshold := Effective; Changed;
end;

procedure TNimbusFinancialInteractionOptions.SetMouseWheelPanCandles(const Value: Integer);
var Effective: Integer;
begin
  Effective := Max(1, Value); if FMouseWheelPanCandles = Effective then Exit; FMouseWheelPanCandles := Effective; Changed;
end;

procedure TNimbusFinancialInteractionOptions.SetPagePanRatio(const Value: Double);
var Effective: Double;
begin
  if IsNan(Value) or IsInfinite(Value) then raise EArgumentOutOfRangeException.Create('PagePanRatio must be finite');
  Effective := EnsureRange(Value, 0.01, 1.0); if FPagePanRatio = Effective then Exit; FPagePanRatio := Effective; Changed;
end;

procedure TNimbusFinancialInteractionOptions.SetKeyboardZoomFactor(const Value: Double);
var Effective: Double;
begin
  if IsNan(Value) or IsInfinite(Value) then raise EArgumentOutOfRangeException.Create('KeyboardZoomFactor must be finite');
  Effective := EnsureRange(Value, 1.01, 4.0); if FKeyboardZoomFactor = Effective then Exit; FKeyboardZoomFactor := Effective; Changed;
end;

constructor TNimbusFinancialAccessibilityOptions.Create;
begin
  inherited Create;
  FEnableScreenReaderSummary := True;
  FEnableKeyboardCandleSelection := True;
  FAutoApplyHighContrast := True;
  FIncludeVisibleRangeInSummary := True;
  FIncludeSelectionInSummary := True;
end;

procedure TNimbusFinancialAccessibilityOptions.Assign(Source: TPersistent);
var Other: TNimbusFinancialAccessibilityOptions;
begin
  if not (Source is TNimbusFinancialAccessibilityOptions) then begin inherited; Exit end; Other := TNimbusFinancialAccessibilityOptions(Source);
  FEnableScreenReaderSummary := Other.FEnableScreenReaderSummary;
  FEnableKeyboardCandleSelection := Other.FEnableKeyboardCandleSelection;
  FAutoApplyHighContrast := Other.FAutoApplyHighContrast;
  FIncludeVisibleRangeInSummary := Other.FIncludeVisibleRangeInSummary;
  FIncludeSelectionInSummary := Other.FIncludeSelectionInSummary;
  Changed;
end;

procedure TNimbusFinancialAccessibilityOptions.SetEnableScreenReaderSummary(const Value: Boolean);
begin
  if FEnableScreenReaderSummary = Value then Exit; FEnableScreenReaderSummary := Value; Changed;
end;

procedure TNimbusFinancialAccessibilityOptions.SetEnableKeyboardCandleSelection(const Value: Boolean);
begin
  if FEnableKeyboardCandleSelection = Value then Exit; FEnableKeyboardCandleSelection := Value; Changed;
end;

procedure TNimbusFinancialAccessibilityOptions.SetAutoApplyHighContrast(const Value: Boolean);
begin
  if FAutoApplyHighContrast = Value then Exit; FAutoApplyHighContrast := Value; Changed;
end;

procedure TNimbusFinancialAccessibilityOptions.SetIncludeVisibleRangeInSummary(const Value: Boolean);
begin
  if FIncludeVisibleRangeInSummary = Value then Exit; FIncludeVisibleRangeInSummary := Value; Changed;
end;

procedure TNimbusFinancialAccessibilityOptions.SetIncludeSelectionInSummary(const Value: Boolean);
begin
  if FIncludeSelectionInSummary = Value then Exit; FIncludeSelectionInSummary := Value; Changed;
end;

constructor TNimbusFinancialRangeSelector.Create;
begin
  inherited Create;
  FVisible := True;
  FButtonMinWidth := 34;
  FButtonHeight := 22;
  FButtonSpacing := 4;
  FPlacement := nfrpTimeAxisRight;
  FItems := TNimbusFinancialRangeButtonCollection.Create(Self); FItems.OnChange := ItemsChanged;
end;

procedure TNimbusFinancialRangeSelector.Assign(Source: TPersistent);
var Other: TNimbusFinancialRangeSelector;
begin
  if not (Source is TNimbusFinancialRangeSelector) then begin inherited; Exit end; Other := TNimbusFinancialRangeSelector(Source);
  FVisible := Other.FVisible;
  FButtonMinWidth := Other.FButtonMinWidth;
  FButtonHeight := Other.FButtonHeight;
  FButtonSpacing := Other.FButtonSpacing;
  FPlacement := Other.FPlacement;
  FItems.Assign(Other.FItems);
  Changed;
end;

procedure TNimbusFinancialRangeSelector.SetVisible(const Value: Boolean);
begin
  if FVisible = Value then Exit; FVisible := Value; Changed;
end;

procedure TNimbusFinancialRangeSelector.SetButtonMinWidth(const Value: Integer);
var Effective: Integer;
begin
  Effective := Max(18, Value); if FButtonMinWidth = Effective then Exit; FButtonMinWidth := Effective; Changed;
end;

procedure TNimbusFinancialRangeSelector.SetButtonHeight(const Value: Integer);
var Effective: Integer;
begin
  Effective := Max(16, Value); if FButtonHeight = Effective then Exit; FButtonHeight := Effective; Changed;
end;

procedure TNimbusFinancialRangeSelector.SetButtonSpacing(const Value: Integer);
var Effective: Integer;
begin
  Effective := Max(0, Value); if FButtonSpacing = Effective then Exit; FButtonSpacing := Effective; Changed;
end;

procedure TNimbusFinancialRangeSelector.SetPlacement(const Value: TNimbusFinancialRangePlacement);
begin
  if FPlacement = Value then Exit; FPlacement := Value; Changed;
end;

destructor TNimbusFinancialRangeSelector.Destroy;
begin FItems.OnChange := nil; FItems.Free; inherited end;

procedure TNimbusFinancialRangeSelector.SetItems(const Value: TNimbusFinancialRangeButtonCollection);
begin if Value <> nil then FItems.Assign(Value) end;

procedure TNimbusFinancialRangeSelector.ItemsChanged(Sender: TObject);
begin Changed end;

constructor TNimbusFinancialBusinessOptions.Create;
begin
  inherited Create;
  FSymbol := '';
  FExchange := '';
  FTimeFrame := nftfDay1;
  FPriceMode := nfpmCandlestick;
  FShowVolume := True;
  FShowVolumeMovingAverage := True;
  FVolumeMovingAveragePeriod := 20;
  FShowSimpleMovingAverage := True;
  FShowExponentialMovingAverage := True;
  FSimpleMovingAveragePeriods := '20,50,200';
  FExponentialMovingAveragePeriods := '20,50';
  FShowBollingerBands := True;
  FBollingerBandPeriods := '20';
  FBollingerBandStandardDeviation := 2;
  FShowRsi := True;
  FRsiPeriods := '14';
  FRsiOversoldLevel := 30;
  FRsiOverboughtLevel := 70;
  FShowMacd := True;
  FMacdFastPeriod := 12;
  FMacdSlowPeriod := 26;
  FMacdSignalPeriod := 9;
  FShowStochastic := True;
  FStochasticPeriod := 14;
  FStochasticSmoothKPeriod := 3;
  FStochasticDPeriod := 3;
  FStochasticOversoldLevel := 20;
  FStochasticOverboughtLevel := 80;
  FShowAtr := True;
  FAtrPeriods := '14';
  FShowVwap := True;
  FVwapResetBySession := False;
  FShowCrosshair := True;
  FShowLegend := True;
  FShowGrid := True;
  FShowAxes := True;
  FShowAnnotations := True;
  FShowToolTips := True;
  FLockDetailsOnSelection := True;
  FClearSelectionOnEmptyPlotClick := True;
  FClearSelectionOnEscape := True;
  FShowCrosshairWhileSelectionLocked := True;
  FShowDashboardPanels := False;
  FAutoBuildProductiveSidePanels := True;
  FSidePanelLayoutMode := nfslStacked;
  FLeftSidePanelAreaWidth := 0;
  FRightSidePanelAreaWidth := 0;
  FAllowPanelLayoutChanges := True;
  FAllowVolumePanelReorder := True;
  FShowPanelDragAdorner := True;
  FShowPanelDropZones := True;
  FShowPanelContextMenu := True;
  FShowBuiltInIndicatorSettingsDialog := True;
end;

procedure TNimbusFinancialBusinessOptions.Assign(Source: TPersistent);
var Other: TNimbusFinancialBusinessOptions;
begin
  if not (Source is TNimbusFinancialBusinessOptions) then begin inherited; Exit end; Other := TNimbusFinancialBusinessOptions(Source);
  FSymbol := Other.FSymbol;
  FExchange := Other.FExchange;
  FTimeFrame := Other.FTimeFrame;
  FPriceMode := Other.FPriceMode;
  FShowVolume := Other.FShowVolume;
  FShowVolumeMovingAverage := Other.FShowVolumeMovingAverage;
  FVolumeMovingAveragePeriod := Other.FVolumeMovingAveragePeriod;
  FShowSimpleMovingAverage := Other.FShowSimpleMovingAverage;
  FShowExponentialMovingAverage := Other.FShowExponentialMovingAverage;
  FSimpleMovingAveragePeriods := Other.FSimpleMovingAveragePeriods;
  FExponentialMovingAveragePeriods := Other.FExponentialMovingAveragePeriods;
  FShowBollingerBands := Other.FShowBollingerBands;
  FBollingerBandPeriods := Other.FBollingerBandPeriods;
  FBollingerBandStandardDeviation := Other.FBollingerBandStandardDeviation;
  FShowRsi := Other.FShowRsi;
  FRsiPeriods := Other.FRsiPeriods;
  FRsiOversoldLevel := Other.FRsiOversoldLevel;
  FRsiOverboughtLevel := Other.FRsiOverboughtLevel;
  FShowMacd := Other.FShowMacd;
  FMacdFastPeriod := Other.FMacdFastPeriod;
  FMacdSlowPeriod := Other.FMacdSlowPeriod;
  FMacdSignalPeriod := Other.FMacdSignalPeriod;
  FShowStochastic := Other.FShowStochastic;
  FStochasticPeriod := Other.FStochasticPeriod;
  FStochasticSmoothKPeriod := Other.FStochasticSmoothKPeriod;
  FStochasticDPeriod := Other.FStochasticDPeriod;
  FStochasticOversoldLevel := Other.FStochasticOversoldLevel;
  FStochasticOverboughtLevel := Other.FStochasticOverboughtLevel;
  FShowAtr := Other.FShowAtr;
  FAtrPeriods := Other.FAtrPeriods;
  FShowVwap := Other.FShowVwap;
  FVwapResetBySession := Other.FVwapResetBySession;
  FShowCrosshair := Other.FShowCrosshair;
  FShowLegend := Other.FShowLegend;
  FShowGrid := Other.FShowGrid;
  FShowAxes := Other.FShowAxes;
  FShowAnnotations := Other.FShowAnnotations;
  FShowToolTips := Other.FShowToolTips;
  FLockDetailsOnSelection := Other.FLockDetailsOnSelection;
  FClearSelectionOnEmptyPlotClick := Other.FClearSelectionOnEmptyPlotClick;
  FClearSelectionOnEscape := Other.FClearSelectionOnEscape;
  FShowCrosshairWhileSelectionLocked := Other.FShowCrosshairWhileSelectionLocked;
  FShowDashboardPanels := Other.FShowDashboardPanels;
  FAutoBuildProductiveSidePanels := Other.FAutoBuildProductiveSidePanels;
  FSidePanelLayoutMode := Other.FSidePanelLayoutMode;
  FLeftSidePanelAreaWidth := Other.FLeftSidePanelAreaWidth;
  FRightSidePanelAreaWidth := Other.FRightSidePanelAreaWidth;
  FAllowPanelLayoutChanges := Other.FAllowPanelLayoutChanges;
  FAllowVolumePanelReorder := Other.FAllowVolumePanelReorder;
  FShowPanelDragAdorner := Other.FShowPanelDragAdorner;
  FShowPanelDropZones := Other.FShowPanelDropZones;
  FShowPanelContextMenu := Other.FShowPanelContextMenu;
  FShowBuiltInIndicatorSettingsDialog := Other.FShowBuiltInIndicatorSettingsDialog;
  Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetSymbol(const Value: string);
begin
  if FSymbol = Value then Exit; FSymbol := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetExchange(const Value: string);
begin
  if FExchange = Value then Exit; FExchange := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetTimeFrame(const Value: TNimbusFinancialTimeFrame);
begin
  if FTimeFrame = Value then Exit; FTimeFrame := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetPriceMode(const Value: TNimbusFinancialPriceMode);
begin
  if FPriceMode = Value then Exit; FPriceMode := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetShowVolume(const Value: Boolean);
begin
  if FShowVolume = Value then Exit; FShowVolume := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetShowVolumeMovingAverage(const Value: Boolean);
begin
  if FShowVolumeMovingAverage = Value then Exit; FShowVolumeMovingAverage := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetVolumeMovingAveragePeriod(const Value: Integer);
var Effective: Integer;
begin
  Effective := EnsureRange(Value, 2, 1000); if FVolumeMovingAveragePeriod = Effective then Exit; FVolumeMovingAveragePeriod := Effective; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetShowSimpleMovingAverage(const Value: Boolean);
begin
  if FShowSimpleMovingAverage = Value then Exit; FShowSimpleMovingAverage := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetShowExponentialMovingAverage(const Value: Boolean);
begin
  if FShowExponentialMovingAverage = Value then Exit; FShowExponentialMovingAverage := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetSimpleMovingAveragePeriods(const Value: string);
begin
  if FSimpleMovingAveragePeriods = Value then Exit; FSimpleMovingAveragePeriods := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetExponentialMovingAveragePeriods(const Value: string);
begin
  if FExponentialMovingAveragePeriods = Value then Exit; FExponentialMovingAveragePeriods := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetShowBollingerBands(const Value: Boolean);
begin
  if FShowBollingerBands = Value then Exit; FShowBollingerBands := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetBollingerBandPeriods(const Value: string);
begin
  if FBollingerBandPeriods = Value then Exit; FBollingerBandPeriods := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetBollingerBandStandardDeviation(const Value: Double);
var Effective: Double;
begin
  if IsNan(Value) or IsInfinite(Value) then raise EArgumentOutOfRangeException.Create('BollingerBandStandardDeviation must be finite');
  Effective := Max(0.01, Value); if FBollingerBandStandardDeviation = Effective then Exit; FBollingerBandStandardDeviation := Effective; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetShowRsi(const Value: Boolean);
begin
  if FShowRsi = Value then Exit; FShowRsi := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetRsiPeriods(const Value: string);
begin
  if FRsiPeriods = Value then Exit; FRsiPeriods := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetRsiOversoldLevel(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then raise EArgumentOutOfRangeException.Create('RsiOversoldLevel must be finite');
  if FRsiOversoldLevel = Value then Exit; FRsiOversoldLevel := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetRsiOverboughtLevel(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then raise EArgumentOutOfRangeException.Create('RsiOverboughtLevel must be finite');
  if FRsiOverboughtLevel = Value then Exit; FRsiOverboughtLevel := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetShowMacd(const Value: Boolean);
begin
  if FShowMacd = Value then Exit; FShowMacd := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetMacdFastPeriod(const Value: Integer);
var Effective: Integer;
begin
  Effective := EnsureRange(Value, 2, 1000); if FMacdFastPeriod = Effective then Exit; FMacdFastPeriod := Effective; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetMacdSlowPeriod(const Value: Integer);
var Effective: Integer;
begin
  Effective := EnsureRange(Value, 2, 1000); if FMacdSlowPeriod = Effective then Exit; FMacdSlowPeriod := Effective; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetMacdSignalPeriod(const Value: Integer);
var Effective: Integer;
begin
  Effective := EnsureRange(Value, 2, 1000); if FMacdSignalPeriod = Effective then Exit; FMacdSignalPeriod := Effective; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetShowStochastic(const Value: Boolean);
begin
  if FShowStochastic = Value then Exit; FShowStochastic := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetStochasticPeriod(const Value: Integer);
var Effective: Integer;
begin
  Effective := EnsureRange(Value, 2, 1000); if FStochasticPeriod = Effective then Exit; FStochasticPeriod := Effective; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetStochasticSmoothKPeriod(const Value: Integer);
var Effective: Integer;
begin
  Effective := EnsureRange(Value, 1, 1000); if FStochasticSmoothKPeriod = Effective then Exit; FStochasticSmoothKPeriod := Effective; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetStochasticDPeriod(const Value: Integer);
var Effective: Integer;
begin
  Effective := EnsureRange(Value, 1, 1000); if FStochasticDPeriod = Effective then Exit; FStochasticDPeriod := Effective; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetStochasticOversoldLevel(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then raise EArgumentOutOfRangeException.Create('StochasticOversoldLevel must be finite');
  if FStochasticOversoldLevel = Value then Exit; FStochasticOversoldLevel := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetStochasticOverboughtLevel(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then raise EArgumentOutOfRangeException.Create('StochasticOverboughtLevel must be finite');
  if FStochasticOverboughtLevel = Value then Exit; FStochasticOverboughtLevel := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetShowAtr(const Value: Boolean);
begin
  if FShowAtr = Value then Exit; FShowAtr := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetAtrPeriods(const Value: string);
begin
  if FAtrPeriods = Value then Exit; FAtrPeriods := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetShowVwap(const Value: Boolean);
begin
  if FShowVwap = Value then Exit; FShowVwap := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetVwapResetBySession(const Value: Boolean);
begin
  if FVwapResetBySession = Value then Exit; FVwapResetBySession := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetShowCrosshair(const Value: Boolean);
begin
  if FShowCrosshair = Value then Exit; FShowCrosshair := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetShowLegend(const Value: Boolean);
begin
  if FShowLegend = Value then Exit; FShowLegend := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetShowGrid(const Value: Boolean);
begin
  if FShowGrid = Value then Exit; FShowGrid := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetShowAxes(const Value: Boolean);
begin
  if FShowAxes = Value then Exit; FShowAxes := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetShowAnnotations(const Value: Boolean);
begin
  if FShowAnnotations = Value then Exit; FShowAnnotations := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetShowToolTips(const Value: Boolean);
begin
  if FShowToolTips = Value then Exit; FShowToolTips := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetLockDetailsOnSelection(const Value: Boolean);
begin
  if FLockDetailsOnSelection = Value then Exit; FLockDetailsOnSelection := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetClearSelectionOnEmptyPlotClick(const Value: Boolean);
begin
  if FClearSelectionOnEmptyPlotClick = Value then Exit; FClearSelectionOnEmptyPlotClick := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetClearSelectionOnEscape(const Value: Boolean);
begin
  if FClearSelectionOnEscape = Value then Exit; FClearSelectionOnEscape := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetShowCrosshairWhileSelectionLocked(const Value: Boolean);
begin
  if FShowCrosshairWhileSelectionLocked = Value then Exit; FShowCrosshairWhileSelectionLocked := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetShowDashboardPanels(const Value: Boolean);
begin
  if FShowDashboardPanels = Value then Exit; FShowDashboardPanels := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetAutoBuildProductiveSidePanels(const Value: Boolean);
begin
  if FAutoBuildProductiveSidePanels = Value then Exit; FAutoBuildProductiveSidePanels := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetSidePanelLayoutMode(const Value: TNimbusFinancialSidePanelLayoutMode);
begin if FSidePanelLayoutMode <> Value then begin FSidePanelLayoutMode := Value; Changed end end;

procedure TNimbusFinancialBusinessOptions.SetLeftSidePanelAreaWidth(const Value: Integer);
var Effective: Integer;
begin
  Effective := Max(0, Value); if FLeftSidePanelAreaWidth = Effective then Exit; FLeftSidePanelAreaWidth := Effective; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetRightSidePanelAreaWidth(const Value: Integer);
var Effective: Integer;
begin
  Effective := Max(0, Value); if FRightSidePanelAreaWidth = Effective then Exit; FRightSidePanelAreaWidth := Effective; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetAllowPanelLayoutChanges(const Value: Boolean);
begin
  if FAllowPanelLayoutChanges = Value then Exit; FAllowPanelLayoutChanges := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetAllowVolumePanelReorder(const Value: Boolean);
begin
  if FAllowVolumePanelReorder = Value then Exit; FAllowVolumePanelReorder := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetShowPanelDragAdorner(const Value: Boolean);
begin
  if FShowPanelDragAdorner = Value then Exit; FShowPanelDragAdorner := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetShowPanelDropZones(const Value: Boolean);
begin
  if FShowPanelDropZones = Value then Exit; FShowPanelDropZones := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetShowPanelContextMenu(const Value: Boolean);
begin
  if FShowPanelContextMenu = Value then Exit; FShowPanelContextMenu := Value; Changed;
end;

procedure TNimbusFinancialBusinessOptions.SetShowBuiltInIndicatorSettingsDialog(const Value: Boolean);
begin
  if FShowBuiltInIndicatorSettingsDialog = Value then Exit; FShowBuiltInIndicatorSettingsDialog := Value; Changed;
end;

procedure TNimbusFinancialPanelItem.SetCandleIndex(const Value: Integer);
begin if FCandleIndex <> Value then begin FCandleIndex := Value; Changed(False) end end;

procedure TNimbusFinancialPanelCollection.Assign(Source: TPersistent);
type TBinding = record Key: string; Action: TNimbusFinancialPanelActionEvent;  end;
var Bindings: TArray<TBinding>; I, J: Integer; Item: TNimbusFinancialPanel;
begin
  if Source = Self then Exit;
  SetLength(Bindings, Count);
  for I := 0 to Count - 1 do
  begin Bindings[I].Key := Items[I].Key; Bindings[I].Action := Items[I].FOnAction;  end;
  BeginUpdate;
  try
    inherited Assign(Source);
    for I := 0 to Count - 1 do
    begin
      Item := Items[I];
      for J := 0 to High(Bindings) do if SameText(Bindings[J].Key, Item.Key) then
      begin
        if not Assigned(Item.FOnAction) then Item.FOnAction := Bindings[J].Action;
        
        Break;
      end;
    end;
  finally EndUpdate end;
end;

procedure TNimbusFinancialSidePanelCollection.Assign(Source: TPersistent);
type TBinding = record Key: string; Action: TNimbusFinancialPanelActionEvent; RowClicked: TNimbusFinancialRowEvent; RowDoubleClicked: TNimbusFinancialRowEvent; RowHovered: TNimbusFinancialRowEvent; RowContextMenu: TNimbusFinancialRowEvent; end;
var Bindings: TArray<TBinding>; I, J: Integer; Item: TNimbusFinancialSidePanel;
begin
  if Source = Self then Exit;
  SetLength(Bindings, Count);
  for I := 0 to Count - 1 do
  begin Bindings[I].Key := Items[I].Key; Bindings[I].Action := Items[I].FOnAction; Bindings[I].RowClicked := Items[I].FOnRowClicked; Bindings[I].RowDoubleClicked := Items[I].FOnRowDoubleClicked; Bindings[I].RowHovered := Items[I].FOnRowHovered; Bindings[I].RowContextMenu := Items[I].FOnRowContextMenu; end;
  BeginUpdate;
  try
    inherited Assign(Source);
    for I := 0 to Count - 1 do
    begin
      Item := Items[I];
      for J := 0 to High(Bindings) do if SameText(Bindings[J].Key, Item.Key) then
      begin
        if not Assigned(Item.FOnAction) then Item.FOnAction := Bindings[J].Action;
        if not Assigned(Item.FOnRowClicked) then Item.FOnRowClicked := Bindings[J].RowClicked;
        if not Assigned(Item.FOnRowDoubleClicked) then Item.FOnRowDoubleClicked := Bindings[J].RowDoubleClicked;
        if not Assigned(Item.FOnRowHovered) then Item.FOnRowHovered := Bindings[J].RowHovered;
        if not Assigned(Item.FOnRowContextMenu) then Item.FOnRowContextMenu := Bindings[J].RowContextMenu;
        Break;
      end;
    end;
  finally EndUpdate end;
end;

end.


{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.IdeDateRange;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, System.SysUtils,
  System.Types, System.UITypes, System.DateUtils, System.Math,
  Vcl.Controls, Vcl.Forms, Vcl.Graphics,
  NimbusForms.Controls.Base, NimbusForms.Controls.Types, NimbusForms.Theming.Types;

type
  TIdeDateRangeLayoutMetrics = record
    FooterSidePadding: Integer;
    HeaderTop: Integer;
    OuterPadding: Integer;
    PresetWidth: Integer;
    PresetTop: Integer;
    PresetButtonHeight: Integer;
    PresetRowHeight: Integer;
    FooterButtonHeight: Integer;
    NarrowMonthWidth: Integer;
    TwoMonthGap: Integer;
    MonthWidth: Integer;
    DayHeight: Integer;
    NextYearOffset: Integer;
    DayWidth: Integer;
    NextMonthInnerOffset: Integer;
    FooterHeight: Integer;
    PreviousYearRight: Integer;
    HeaderBottom: Integer;
    PreviousMonthLeft: Integer;
    WeekHeaderTop: Integer;
    ThreeMonthGap: Integer;
    NextMonthOuterOffset: Integer;
    FooterButtonWidth: Integer;
    FooterButtonGap: Integer;
    PreviousMonthRight: Integer;
    DayGridTop: Integer;
    NavigationHitTop: Integer;
  end;
  TIdeDateRangeDisplayMode = (idrmdCompact, idrmdDetailed);
  TIdeDateRangeSizeMode = (idrsmNormal, idrsmCompact);
  TIdeDateRangeMonthMode = (idrmOneMonth, idrmTwoMonths, idrmThreeMonths);
  TIdeDateRangeSelectionMode = (idrsmRange, idrsmSingleDate, idrsmStartOnly, idrsmEndOnly);
  TIdeDateRangePreset = (idrpToday, idrpYesterday, idrpThisWeek, idrpLastWeek,
    idrpThisMonth, idrpLastMonth, idrpLast7Days, idrpLast14Days,
    idrpLast30Days, idrpThisYear, idrpLastYear, idrpCustom);
  TIdeDateRangeVisiblePresets = set of TIdeDateRangePreset;
  TIdeDateRangeHitKind = (idrhkNone, idrhkDay, idrhkDisabledDay,
    idrhkPreviousMonth, idrhkNextMonth, idrhkPreviousYear, idrhkNextYear,
    idrhkPreset, idrhkNamedPreset, idrhkApply, idrhkCancel, idrhkClear);
  TIdeDateRangeHitInfo = record
    Kind: TIdeDateRangeHitKind;
    Date: TDateTime;
    Index: Integer;
    MonthIndex: Integer;
    Bounds: TRect;
  end;
  TIdeDateRangeHitChangedEvent = procedure(Sender: TObject;
    const AHit: TIdeDateRangeHitInfo) of object;
  TIdeDateRangeChangingEvent = procedure(Sender: TObject; const AStart, AEnd: TDateTime;
    var Allow: Boolean) of object;
  TIdeDateRangeCanSelectDateEvent = procedure(Sender: TObject;
    const ADate: TDateTime; var ACanSelect: Boolean) of object;
  TIdeDateRangeDayTextEvent = procedure(Sender: TObject;
    const ADate: TDateTime; var AText: string) of object;
  TIdeDateRangeDayStyleEvent = procedure(Sender: TObject;
    const ADate: TDateTime; var ABackColor, ATextColor, ABorderColor: TThemeColor;
    var AUseBackground, AUseTextColor, AUseBorder: Boolean) of object;
  TIdeDateRangeDayRenderInfo = record
    Date: TDateTime;
    Bounds: TRect;
    MonthIndex: Integer;
    InRange: Boolean;
    IsEndpoint: Boolean;
    IsToday: Boolean;
    IsDisabled: Boolean;
    IsHovered: Boolean;
  end;
  TIdeDateRangeDayRenderEvent = procedure(Sender: TObject;
    const AInfo: TIdeDateRangeDayRenderInfo; var AText: string;
    var ABackColor, ATextColor, ABorderColor: TThemeColor;
    var AUseBackground, AUseTextColor, AUseBorder: Boolean) of object;
  TIdeDateRangeDayDecorationEvent = procedure(Sender: TObject;
    const ADate: TDateTime; var ADisabled, AHighlighted: Boolean;
    var ABadgeText: string) of object;
  TIdeDateRangeDayEvent = procedure(Sender: TObject; const ADate: TDateTime) of object;
  TIdeDateRangeDaySelectingEvent = procedure(Sender: TObject;
    const ADate: TDateTime; var AAllow: Boolean) of object;
  TIdeDateRangeDayContextEvent = procedure(Sender: TObject;
    const ADate: TDateTime; const AScreenPoint: TPoint;
    var AHandled: Boolean) of object;
  TIdeDateRangeDayHintEvent = procedure(Sender: TObject; const ADate: TDateTime;
    var AText: string; var AShow: Boolean) of object;
  TIdeDateRangeMonthChangedEvent = procedure(Sender: TObject; const AFirstMonth: TDateTime) of object;
  TIdeDateRangePreviewEvent = procedure(Sender: TObject; const AStart, AEnd: TDateTime) of object;
  TIdeDateRangePopupOpeningEvent = procedure(Sender: TObject; var AAllow: Boolean) of object;
  TIdeDateRangePresetChangingEvent = procedure(Sender: TObject;
    const APreset: TIdeDateRangePreset; const AStart, AEnd: TDateTime;
    var AAllow: Boolean) of object;
  TIdeDateRangePresetAppliedEvent = procedure(Sender: TObject;
    const APreset: TIdeDateRangePreset; const AStart, AEnd: TDateTime) of object;
  TIdeDateRangeNamedPreset = record
    Caption: string;
    StartDate: TDateTime;
    EndDate: TDateTime;
  end;
  TIdeDateRangeNamedPresetChangingEvent = procedure(Sender: TObject;
    const AIndex: Integer; const ACaption: string; const AStart, AEnd: TDateTime;
    var AAllow: Boolean) of object;
  TIdeDateRangeNamedPresetAppliedEvent = procedure(Sender: TObject;
    const AIndex: Integer; const ACaption: string; const AStart, AEnd: TDateTime) of object;
  TIdeDateRangeApplyingEvent = procedure(Sender: TObject;
    const AStart, AEnd: TDateTime; const AHasStart, AHasEnd: Boolean;
    var AAllow: Boolean) of object;
  TCustomThemedIdeDateRangePicker = class;

  TIdeDateRangeCalendar = class(TCustomNimbusControl)
  private
    FPicker: TCustomThemedIdeDateRangePicker;
    FMonth: TDateTime;
    FFrom, FTo: TDateTime;
    FHasFrom, FHasTo: Boolean;
    FSelectingEnd: Boolean;
    FHoverDay: TDateTime;
    FFocusDay: TDateTime;
    FHit: Integer;
    FLastHitKind: TIdeDateRangeHitKind;
    FLastHitIndex: Integer;
    FLastHitDate: TDateTime;
    FFirstDayOfWeek: Integer;
    FMonthMode: TIdeDateRangeMonthMode;
    FSelectionMode: TIdeDateRangeSelectionMode;
    FMinDate, FMaxDate: TDateTime;
    FDisableWeekends: Boolean;
    FShowWeekNumbers: Boolean;
    FShowPresets: Boolean;
    FShowFooter: Boolean;
    FShowCustomPreset: Boolean;
    FOnAccept: TNotifyEvent;
    FOnCancel: TNotifyEvent;
    FOnClear: TNotifyEvent;
    FOnPreset: TNotifyEvent;
    FLastPreset: TIdeDateRangePreset;
    procedure SetHoverDay(const ADate: TDateTime);
    function LayoutMetrics: TIdeDateRangeLayoutMetrics;
    function MonthCount: Integer;
    function DayAt(const X, Y: Integer): TDateTime;
    function HitAt(const X, Y: Integer): Integer;
    function HitTestAt(const X, Y: Integer): TIdeDateRangeHitInfo;
    procedure NotifyHit(const AHit: TIdeDateRangeHitInfo);
    procedure Navigate(const Delta: Integer);
    procedure MoveFocus(const ATarget: TDateTime; const AStep: Integer);
    procedure ChooseDate(const D: TDateTime);
    procedure ChoosePreset(const Index: Integer);
    procedure ChooseNamedPreset(const Index: Integer);
    function Permitted(const D: TDateTime): Boolean;
    function MonthLeft(const Index: Integer): Integer;
    function MonthWidth: Integer;
    function MonthSpacing: Integer;
    function CalendarTop: Integer;
    function CalendarBottom: Integer;
    function FooterTop: Integer;
    function PresetRow(const APreset: TIdeDateRangePreset): Integer;
    function VisiblePresetCount: Integer;
  protected
    procedure Paint; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure CMMouseLeaveCalendar(var M: TMessage); message CM_MOUSELEAVE;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DblClick; override;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Setup(APicker: TCustomThemedIdeDateRangePicker);
    procedure SyncFromPicker;
    function HitTest(const AClientPoint: TPoint): TIdeDateRangeHitInfo;
    property FromDate: TDateTime read FFrom;
    property ToDate: TDateTime read FTo;
    property HasFrom: Boolean read FHasFrom;
    property HasTo: Boolean read FHasTo;
    property LastPreset: TIdeDateRangePreset read FLastPreset;
    property OnAccept: TNotifyEvent read FOnAccept write FOnAccept;
    property OnCancel: TNotifyEvent read FOnCancel write FOnCancel;
    property OnClear: TNotifyEvent read FOnClear write FOnClear;
    property OnPreset: TNotifyEvent read FOnPreset write FOnPreset;
  end;

  TIdeDateRangePopup = class(TForm)
  private
    FPicker: TCustomThemedIdeDateRangePicker;
    FCalendar: TIdeDateRangeCalendar;
    FClosingNotified: Boolean;
    procedure NotifyClosed;
    procedure AcceptClick(Sender: TObject);
    procedure CancelClick(Sender: TObject);
    procedure ClearClick(Sender: TObject);
    procedure PresetClick(Sender: TObject);
  protected
    procedure Deactivate; override;
    procedure DoHide; override;
  public
    constructor CreateForPicker(APicker: TCustomThemedIdeDateRangePicker);
    procedure Synchronize;
  end;

  TCustomThemedIdeDateRangePicker = class(TCustomNimbusControl)
  private
    FStartDate, FEndDate, FMinDate, FMaxDate: TDateTime;
    FHasStart, FHasEnd: Boolean;
    FMonthMode: TIdeDateRangeMonthMode;
    FSelectionMode: TIdeDateRangeSelectionMode;
    FAllowEmpty, FAllowSingle, FDisableWeekends, FShowWeekNumbers: Boolean;
    FShowPresets, FShowFooter, FShowClear, FReadOnly: Boolean;
    FShowCalendarIcon: Boolean;
    FVisiblePresets: TIdeDateRangeVisiblePresets;
    FCultureName: string;
    FSwapInvalidRange, FCloseOnRangeSelected, FShowCustomPreset: Boolean;
    FCustomPresetStartDate, FCustomPresetEndDate: TDateTime;
    FDisplayMode: TIdeDateRangeDisplayMode;
    FSizeMode: TIdeDateRangeSizeMode;
    FCompactNormalHeight: Integer;
    FCompactAppliedHeight: Integer;
    FInvalidEmptyText, FInvalidOrderText, FInvalidSingleText: string;
    FInvalidMinText, FInvalidMaxText, FInvalidWeekendText: string;
    FPlaceholder, FDateFormat, FSeparator: string;
    FApplyText, FCancelText, FResetText, FTodayText: string;
    FPresets: array[TIdeDateRangePreset] of string;
    FNamedPresets: array of TIdeDateRangeNamedPreset;
    FFirstDayOfWeek: Integer;
    FHot: Boolean;
    FDropDownWidth, FDropDownHeight, FDropDownCornerRadius: Integer;
    FPopup: TIdeDateRangePopup;
    FOnChanged, FOnApply, FOnCancel, FOnClear, FOnPreset: TNotifyEvent;
    FOnChanging: TIdeDateRangeChangingEvent;
    FOnCanSelectDate: TIdeDateRangeCanSelectDateEvent;
    FOnDayText: TIdeDateRangeDayTextEvent;
    FOnDayStyle: TIdeDateRangeDayStyleEvent;
    FOnDayRender: TIdeDateRangeDayRenderEvent;
    FOnDayDecoration: TIdeDateRangeDayDecorationEvent;
    FOnDayMouseEnter, FOnDayMouseLeave, FOnDayClick, FOnDayDoubleClick: TIdeDateRangeDayEvent;
    FOnDayHoverHint: TIdeDateRangeDayHintEvent;
    FOnDaySelecting: TIdeDateRangeDaySelectingEvent;
    FOnDayContextPopup: TIdeDateRangeDayContextEvent;
    FOnRangeApplied, FOnRangeCanceled, FOnRangeCleared: TNotifyEvent;
    FOnHitTargetChanged: TIdeDateRangeHitChangedEvent;
    FOnRangePreviewChanged: TIdeDateRangePreviewEvent;
    FOnVisibleMonthChanged: TIdeDateRangeMonthChangedEvent;
    FOnPopupOpening: TIdeDateRangePopupOpeningEvent;
    FOnPopupOpened, FOnPopupClosed: TNotifyEvent;
    FOnPresetApplying: TIdeDateRangePresetChangingEvent;
    FOnPresetApplied: TIdeDateRangePresetAppliedEvent;
    FOnApplying: TIdeDateRangeApplyingEvent;
    FOnNamedPresetApplying: TIdeDateRangeNamedPresetChangingEvent;
    FOnNamedPresetApplied: TIdeDateRangeNamedPresetAppliedEvent;
    procedure SetVisiblePresets(const V: TIdeDateRangeVisiblePresets);
    procedure SetCultureName(const V: string);
    function CultureSettings: TFormatSettings;
    procedure SetDropDownWidth(const V: Integer);
    procedure SetDropDownHeight(const V: Integer);
    procedure SetDropDownCornerRadius(const V: Integer);
    procedure SetMonthMode(const V: TIdeDateRangeMonthMode);
    procedure SetDisplayMode(const V: TIdeDateRangeDisplayMode);
    procedure SetSizeMode(const V: TIdeDateRangeSizeMode);
    procedure SetStartDate(const V: TDateTime);
    procedure SetEndDate(const V: TDateTime);
    procedure SetMinDate(const V: TDateTime);
    procedure SetMaxDate(const V: TDateTime);
    procedure SetPlaceholder(const V: string);
    procedure SetDateFormat(const V: string);
    procedure SetSeparator(const V: string);
    procedure SetShowPresets(const V: Boolean);
    procedure SetShowFooter(const V: Boolean);
    procedure SetShowWeekNumbers(const V: Boolean);
    procedure SetDisableWeekends(const V: Boolean);
    procedure SetSelectionMode(const V: TIdeDateRangeSelectionMode);
    procedure SetFirstDayOfWeek(const V: Integer);
    function PermitPreset(const APreset: TIdeDateRangePreset;
      const AStart, AEnd: TDateTime): Boolean;
    procedure NotifyPresetApplied(const APreset: TIdeDateRangePreset;
      const AStart, AEnd: TDateTime);
    function GetPresetCaption(const P: TIdeDateRangePreset): string;
    function GetPresetText(Index: Integer): string;
    procedure SetPresetText(Index: Integer; const Value: string);
    function GetValidationMessage: string;
    function GetIsValid: Boolean;
    function GetDisplayText: string;
    function CanSelectDate(const ADate: TDateTime): Boolean;
    procedure DayDecoration(const ADate: TDateTime;
      var ADisabled, AHighlighted: Boolean; var ABadgeText: string);
    function DayText(const ADate: TDateTime): string;
    procedure DayStyle(const ADate: TDateTime;
      var ABackColor, ATextColor, ABorderColor: TThemeColor;
      var AUseBackground, AUseTextColor, AUseBorder: Boolean);
    procedure CMMouseEnter(var M: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var M: TMessage); message CM_MOUSELEAVE;
    procedure CMCancelMode(var M: TCMCancelMode); message CM_CANCELMODE;
  protected
    procedure StyleModeChanged; override;
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    property DropDownWidth: Integer read FDropDownWidth write SetDropDownWidth default 0;
    property DropDownHeight: Integer read FDropDownHeight write SetDropDownHeight default 0;
    property DropDownCornerRadius: Integer read FDropDownCornerRadius write SetDropDownCornerRadius default 7;
    property StartDate: TDateTime read FStartDate write SetStartDate;
    property EndDate: TDateTime read FEndDate write SetEndDate;
    property MinDate: TDateTime read FMinDate write SetMinDate;
    property MaxDate: TDateTime read FMaxDate write SetMaxDate;
    property MonthMode: TIdeDateRangeMonthMode read FMonthMode write SetMonthMode default idrmTwoMonths;
    property DisplayMode: TIdeDateRangeDisplayMode read FDisplayMode write SetDisplayMode default idrmdCompact;
    property SizeMode: TIdeDateRangeSizeMode read FSizeMode write SetSizeMode default idrsmNormal;
    property SwapInvalidRange: Boolean read FSwapInvalidRange write FSwapInvalidRange default True;
    property CloseOnRangeSelected: Boolean read FCloseOnRangeSelected write FCloseOnRangeSelected default False;
    property ShowCustomPreset: Boolean read FShowCustomPreset write FShowCustomPreset default False;
    property CustomPresetStartDate: TDateTime read FCustomPresetStartDate write FCustomPresetStartDate;
    property CustomPresetEndDate: TDateTime read FCustomPresetEndDate write FCustomPresetEndDate;
    property SelectionMode: TIdeDateRangeSelectionMode read FSelectionMode write SetSelectionMode default idrsmRange;
    property IsValid: Boolean read GetIsValid;
    property ValidationMessage: string read GetValidationMessage;
    property InvalidEmptyRangeText: string read FInvalidEmptyText write FInvalidEmptyText;
    property InvalidDateOrderText: string read FInvalidOrderText write FInvalidOrderText;
    property InvalidSingleDateText: string read FInvalidSingleText write FInvalidSingleText;
    property InvalidMinDateText: string read FInvalidMinText write FInvalidMinText;
    property InvalidMaxDateText: string read FInvalidMaxText write FInvalidMaxText;
    property InvalidWeekendText: string read FInvalidWeekendText write FInvalidWeekendText;
    property AllowEmptyRange: Boolean read FAllowEmpty write FAllowEmpty default True;
    property AllowSingleDateRange: Boolean read FAllowSingle write FAllowSingle default True;
    property DisableWeekends: Boolean read FDisableWeekends write SetDisableWeekends default False;
    property ShowWeekNumbers: Boolean read FShowWeekNumbers write SetShowWeekNumbers default False;
    property ShowPresets: Boolean read FShowPresets write SetShowPresets default True;
    property ShowFooterButtons: Boolean read FShowFooter write SetShowFooter default True;
    property ShowClearButton: Boolean read FShowClear write FShowClear default True;
    property ShowCalendarIcon: Boolean read FShowCalendarIcon write FShowCalendarIcon default False;
    property VisiblePresets: TIdeDateRangeVisiblePresets read FVisiblePresets write SetVisiblePresets;
    property CultureName: string read FCultureName write SetCultureName;
    property ReadOnly: Boolean read FReadOnly write FReadOnly default False;
    property FirstDayOfWeek: Integer read FFirstDayOfWeek write SetFirstDayOfWeek default 2;
    property PlaceholderText: string read FPlaceholder write SetPlaceholder;
    property DateFormat: string read FDateFormat write SetDateFormat;
    property RangeSeparatorText: string read FSeparator write SetSeparator;
    property ApplyCaption: string read FApplyText write FApplyText;
    property CancelCaption: string read FCancelText write FCancelText;
    property ResetCaption: string read FResetText write FResetText;
    property TodayCaption: string read FTodayText write FTodayText;
    property TodayPresetCaption: string index 0 read GetPresetText write SetPresetText;
    property YesterdayPresetCaption: string index 1 read GetPresetText write SetPresetText;
    property ThisWeekPresetCaption: string index 2 read GetPresetText write SetPresetText;
    property LastWeekPresetCaption: string index 3 read GetPresetText write SetPresetText;
    property ThisMonthPresetCaption: string index 4 read GetPresetText write SetPresetText;
    property LastMonthPresetCaption: string index 5 read GetPresetText write SetPresetText;
    property Last7DaysPresetCaption: string index 6 read GetPresetText write SetPresetText;
    property Last14DaysPresetCaption: string index 7 read GetPresetText write SetPresetText;
    property Last30DaysPresetCaption: string index 8 read GetPresetText write SetPresetText;
    property ThisYearPresetCaption: string index 9 read GetPresetText write SetPresetText;
    property LastYearPresetCaption: string index 10 read GetPresetText write SetPresetText;
    property CustomPresetCaption: string index 11 read GetPresetText write SetPresetText;
    property OnDateRangeChanged: TNotifyEvent read FOnChanged write FOnChanged;
    property OnDateRangeChanging: TIdeDateRangeChangingEvent read FOnChanging write FOnChanging;
    property OnCanSelectDate: TIdeDateRangeCanSelectDateEvent read FOnCanSelectDate write FOnCanSelectDate;
    property OnDayText: TIdeDateRangeDayTextEvent read FOnDayText write FOnDayText;
    property OnDayStyle: TIdeDateRangeDayStyleEvent read FOnDayStyle write FOnDayStyle;
    property OnDayRender: TIdeDateRangeDayRenderEvent read FOnDayRender write FOnDayRender;
    property OnDayDecoration: TIdeDateRangeDayDecorationEvent read FOnDayDecoration write FOnDayDecoration;
    property OnDayMouseEnter: TIdeDateRangeDayEvent read FOnDayMouseEnter write FOnDayMouseEnter;
    property OnDayMouseLeave: TIdeDateRangeDayEvent read FOnDayMouseLeave write FOnDayMouseLeave;
    property OnDaySelecting: TIdeDateRangeDaySelectingEvent read FOnDaySelecting write FOnDaySelecting;
    property OnDayContextPopup: TIdeDateRangeDayContextEvent read FOnDayContextPopup write FOnDayContextPopup;
    property OnRangeApplied: TNotifyEvent read FOnRangeApplied write FOnRangeApplied;
    property OnRangeCanceled: TNotifyEvent read FOnRangeCanceled write FOnRangeCanceled;
    property OnRangeCleared: TNotifyEvent read FOnRangeCleared write FOnRangeCleared;
    property OnDayClick: TIdeDateRangeDayEvent read FOnDayClick write FOnDayClick;
    property OnDayDoubleClick: TIdeDateRangeDayEvent read FOnDayDoubleClick write FOnDayDoubleClick;
    property OnDayHoverHint: TIdeDateRangeDayHintEvent read FOnDayHoverHint write FOnDayHoverHint;
    property OnHitTargetChanged: TIdeDateRangeHitChangedEvent read FOnHitTargetChanged write FOnHitTargetChanged;
    property OnRangePreviewChanged: TIdeDateRangePreviewEvent read FOnRangePreviewChanged write FOnRangePreviewChanged;
    property OnVisibleMonthChanged: TIdeDateRangeMonthChangedEvent read FOnVisibleMonthChanged write FOnVisibleMonthChanged;
    property OnPopupOpening: TIdeDateRangePopupOpeningEvent read FOnPopupOpening write FOnPopupOpening;
    property OnPopupOpened: TNotifyEvent read FOnPopupOpened write FOnPopupOpened;
    property OnPopupClosed: TNotifyEvent read FOnPopupClosed write FOnPopupClosed;
    property OnApplyClicked: TNotifyEvent read FOnApply write FOnApply;
    property OnCancelClicked: TNotifyEvent read FOnCancel write FOnCancel;
    property OnClearClicked: TNotifyEvent read FOnClear write FOnClear;
    property OnPresetClicked: TNotifyEvent read FOnPreset write FOnPreset;
    property OnPresetApplying: TIdeDateRangePresetChangingEvent read FOnPresetApplying write FOnPresetApplying;
    property OnPresetApplied: TIdeDateRangePresetAppliedEvent read FOnPresetApplied write FOnPresetApplied;
    property OnApplying: TIdeDateRangeApplyingEvent read FOnApplying write FOnApplying;
    property OnNamedPresetApplying: TIdeDateRangeNamedPresetChangingEvent read FOnNamedPresetApplying write FOnNamedPresetApplying;
    property OnNamedPresetApplied: TIdeDateRangeNamedPresetAppliedEvent read FOnNamedPresetApplied write FOnNamedPresetApplied;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetRange(const AStart, AEnd: TDateTime);
    procedure ClearRange;
    procedure ApplyPreset(const APreset: TIdeDateRangePreset);
    function AddNamedPreset(const ACaption: string; const AStart, AEnd: TDateTime): Integer;
    procedure ClearNamedPresets;
    procedure UpdateNamedPreset(const AIndex: Integer; const ACaption: string; const AStart, AEnd: TDateTime);
    procedure RemoveNamedPreset(const AIndex: Integer);
    function NamedPresetCount: Integer;
    function NamedPreset(const AIndex: Integer): TIdeDateRangeNamedPreset;
    procedure ShowDropDown;
    procedure CloseDropDown;
    function HitTestPopup(const AScreenPoint: TPoint): TIdeDateRangeHitInfo;
    property HasStartDate: Boolean read FHasStart;
    property HasEndDate: Boolean read FHasEnd;
    procedure SetPresetCaption(const APreset: TIdeDateRangePreset; const Value: string);
    property PresetCaptions[const APreset: TIdeDateRangePreset]: string read GetPresetCaption write SetPresetCaption;
  end;

  TThemedIdeDateRangePicker = class(TCustomThemedIdeDateRangePicker)
  published
    property StyleMode;
    property Align;
    property Anchors;
    property Constraints;
    property Enabled;
    property Font;
    property ParentFont;
    property Hint;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property Action;
    property DropDownWidth;
    property DropDownHeight;
    property DropDownCornerRadius;
    property IsValid;
    property ValidationMessage;
    property InvalidEmptyRangeText;
    property InvalidDateOrderText;
    property InvalidSingleDateText;
    property InvalidMinDateText;
    property InvalidMaxDateText;
    property InvalidWeekendText;
    property StartDate;
    property EndDate;
    property MinDate;
    property MaxDate;
    property MonthMode;
    property DisplayMode;
    property SizeMode;
    property SwapInvalidRange;
    property CloseOnRangeSelected;
    property ShowCustomPreset;
    property CustomPresetStartDate;
    property CustomPresetEndDate;
    property SelectionMode;
    property AllowEmptyRange;
    property AllowSingleDateRange;
    property DisableWeekends;
    property ShowWeekNumbers;
    property ShowPresets;
    property ShowFooterButtons;
    property ShowClearButton;
    property ShowCalendarIcon;
    property VisiblePresets;
    property CultureName;
    property ReadOnly;
    property FirstDayOfWeek;
    property PlaceholderText;
    property DateFormat;
    property RangeSeparatorText;
    property ApplyCaption;
    property CancelCaption;
    property ResetCaption;
    property TodayCaption;
    property TodayPresetCaption;
    property YesterdayPresetCaption;
    property ThisWeekPresetCaption;
    property LastWeekPresetCaption;
    property ThisMonthPresetCaption;
    property LastMonthPresetCaption;
    property Last7DaysPresetCaption;
    property Last14DaysPresetCaption;
    property Last30DaysPresetCaption;
    property ThisYearPresetCaption;
    property LastYearPresetCaption;
    property CustomPresetCaption;
    property OnDateRangeChanged;
    property OnDateRangeChanging;
    property OnCanSelectDate;
    property OnDayText;
    property OnDayStyle;
    property OnDayRender;
    property OnDayDecoration;
    property OnDayMouseEnter;
    property OnDayMouseLeave;
    property OnDaySelecting;
    property OnDayContextPopup;
    property OnRangeApplied;
    property OnRangeCanceled;
    property OnRangeCleared;
    property OnDayClick;
    property OnDayDoubleClick;
    property OnDayHoverHint;
    property OnHitTargetChanged;
    property OnRangePreviewChanged;
    property OnVisibleMonthChanged;
    property OnPopupOpening;
    property OnPopupOpened;
    property OnPopupClosed;
    property OnApplyClicked;
    property OnCancelClicked;
    property OnClearClicked;
    property OnPresetClicked;
    property OnPresetApplying;
    property OnPresetApplied;
    property OnApplying;
    property OnNamedPresetApplying;
    property OnNamedPresetApplied;
    property OnClick;
    property OnEnter;
    property OnExit;
  end;

implementation

uses
  NimbusForms.Rendering.IdeDateRange, NimbusForms.Rendering.Types,
  NimbusForms.Theming.Palette, NimbusForms.Rendering.Canvas;

resourcestring
  SIdeRangePlaceholder = 'Select date range';
  SIdeRangeApply = 'Apply';
  SIdeRangeCancel = 'Cancel';
  SIdeRangeReset = 'Reset';
  SIdeRangeToday = 'Today';
  SIdeRangeYesterday = 'Yesterday';
  SIdeRangeThisWeek = 'This week';
  SIdeRangeLastWeek = 'Last week';
  SIdeRangeThisMonth = 'This month';
  SIdeRangeLastMonth = 'Last month';
  SIdeRangeLast7Days = 'Last 7 days';
  SIdeRangeLast14Days = 'Last 14 days';
  SIdeRangeLast30Days = 'Last 30 days';
  SIdeRangeThisYear = 'This year';
  SIdeRangeLastYear = 'Last year';
  SIdeRangeCustom = 'Custom';
  SIdeRangeFrom = 'From';
  SIdeRangeTo = 'To';

const
  DayCellW = 34;
  DayCellH = 32;
  MonthW = 272;
  MonthGap = 14;
  PresetW = 142;
  MonthStartX = 14;
  MonthHeaderY = 14;
  WeekHeaderY = 49;
  DayStartY = 78;
  FooterH = 36;
  PresetRowH = 22;
  PresetTopY = 18;
  PresetButtonH = 20;
  FooterButtonH = 23;
  FooterButtonW = 68;
  FooterGap = 7;
  FooterPadding = 12;

function BeginningOfWeek(const D: TDateTime; const FirstDay: Integer): TDateTime;
var
  Offset: Integer;
begin
  Offset := (DayOfWeek(D) - FirstDay + 7) mod 7;
  Result := Trunc(D) - Offset;
end;

function MonthDate(const D: TDateTime): TDateTime;
begin
  Result := EncodeDate(YearOf(D), MonthOf(D), 1);
end;

constructor TIdeDateRangeCalendar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  TabStop := True;
  Font.Name := 'Segoe UI';
  Font.Size := 9;
  FMonth := MonthDate(Date);
  FMonthMode := idrmTwoMonths;
  FMinDate := EncodeDate(1900, 1, 1);
  FMaxDate := EncodeDate(2100, 12, 31);
  FFirstDayOfWeek := 2;
  FShowPresets := True;
  FShowFooter := True;
end;

function TIdeDateRangeCalendar.LayoutMetrics: TIdeDateRangeLayoutMetrics;
const
  NormalMetrics: TIdeDateRangeLayoutMetrics = (
    FooterSidePadding: 12;
    HeaderTop: 14;
    OuterPadding: 14;
    PresetWidth: 142;
    PresetTop: 18;
    PresetButtonHeight: 20;
    PresetRowHeight: 22;
    FooterButtonHeight: 23;
    NarrowMonthWidth: 248;
    TwoMonthGap: 26;
    MonthWidth: 260;
    DayHeight: 32;
    NextYearOffset: 32;
    DayWidth: 34;
    NextMonthInnerOffset: 36;
    FooterHeight: 36;
    PreviousYearRight: 44;
    HeaderBottom: 44;
    PreviousMonthLeft: 45;
    WeekHeaderTop: 49;
    ThreeMonthGap: 5;
    NextMonthOuterOffset: 66;
    FooterButtonWidth: 68;
    FooterButtonGap: 7;
    PreviousMonthRight: 75;
    DayGridTop: 78;
    NavigationHitTop: 8);
  CompactMetrics: TIdeDateRangeLayoutMetrics = (
    FooterSidePadding: 9;
    HeaderTop: 8;
    OuterPadding: 9;
    PresetWidth: 120;
    PresetTop: 12;
    PresetButtonHeight: 17;
    PresetRowHeight: 19;
    FooterButtonHeight: 20;
    NarrowMonthWidth: 226;
    TwoMonthGap: 41;
    MonthWidth: 226;
    DayHeight: 26;
    NextYearOffset: 28;
    DayWidth: 29;
    NextMonthInnerOffset: 30;
    FooterHeight: 32;
    PreviousYearRight: 33;
    HeaderBottom: 35;
    PreviousMonthLeft: 34;
    WeekHeaderTop: 38;
    ThreeMonthGap: 7;
    NextMonthOuterOffset: 55;
    FooterButtonWidth: 60;
    FooterButtonGap: 5;
    PreviousMonthRight: 58;
    DayGridTop: 60;
    NavigationHitTop: 8);
begin
  if (FPicker <> nil) and ((FPicker.FSizeMode = idrsmCompact) or (FPicker.StyleMode = stCompact)) then
    Result := CompactMetrics
  else
    Result := NormalMetrics;
end;

function TIdeDateRangeCalendar.MonthCount: Integer;
begin
  Result := Ord(FMonthMode) + 1;
end;

function TIdeDateRangeCalendar.MonthWidth: Integer;
begin
  Result := LayoutMetrics.MonthWidth;
  if (MonthCount = 3) and not FShowWeekNumbers then
    Result := LayoutMetrics.NarrowMonthWidth;
end;

function TIdeDateRangeCalendar.MonthSpacing: Integer;
begin
  case MonthCount of
    2: Result := LayoutMetrics.TwoMonthGap;
    3: Result := LayoutMetrics.ThreeMonthGap;
  else
    Result := 0;
  end;
end;

function TIdeDateRangeCalendar.MonthLeft(const Index: Integer): Integer;
begin
  Result := ScaleValue(LayoutMetrics.OuterPadding + Index * (MonthWidth + MonthSpacing));
end;

function TIdeDateRangeCalendar.CalendarTop: Integer;
begin
  Result := ScaleValue(LayoutMetrics.DayGridTop);
end;

function TIdeDateRangeCalendar.CalendarBottom: Integer;
begin
  Result := ScaleValue(LayoutMetrics.DayGridTop + 6 * LayoutMetrics.DayHeight);
end;

function TIdeDateRangeCalendar.PresetRow(const APreset: TIdeDateRangePreset): Integer;
var
  P: TIdeDateRangePreset;
begin
  Result := 0;
  if FPicker = nil then Exit;
  for P := Low(TIdeDateRangePreset) to High(TIdeDateRangePreset) do
  begin
    if P = APreset then Exit;
    if (P in FPicker.FVisiblePresets) and
      ((P <> idrpCustom) or FShowCustomPreset) then
      Inc(Result);
  end;
end;

function TIdeDateRangeCalendar.VisiblePresetCount: Integer;
var
  P: TIdeDateRangePreset;
begin
  Result := 0;
  if FPicker = nil then Exit;
  for P := Low(TIdeDateRangePreset) to High(TIdeDateRangePreset) do
    if (P in FPicker.FVisiblePresets) and
      ((P <> idrpCustom) or FShowCustomPreset) then
      Inc(Result);
end;

function TIdeDateRangeCalendar.FooterTop: Integer;
begin
  Result := CalendarBottom + ScaleValue(8);
  if FShowPresets then
    Result := Max(Result, ScaleValue(LayoutMetrics.PresetTop +
      (VisiblePresetCount + FPicker.NamedPresetCount) * LayoutMetrics.PresetRowHeight + 8));
end;

procedure TIdeDateRangeCalendar.Setup(APicker: TCustomThemedIdeDateRangePicker);
begin
  FPicker := APicker;
  SyncFromPicker;
end;

procedure TIdeDateRangeCalendar.SyncFromPicker;
var
  StartMonth: TDateTime;
begin
  if FPicker = nil then Exit;
  FMonthMode := FPicker.FMonthMode;
  FSelectionMode := FPicker.FSelectionMode;
  FMinDate := FPicker.FMinDate;
  FMaxDate := FPicker.FMaxDate;
  FDisableWeekends := FPicker.FDisableWeekends;
  FShowWeekNumbers := FPicker.FShowWeekNumbers;
  FShowPresets := FPicker.FShowPresets;
  FShowCustomPreset := FPicker.FShowCustomPreset;
  FShowFooter := FPicker.FShowFooter;
  FFirstDayOfWeek := FPicker.FFirstDayOfWeek;
  FHasFrom := FPicker.FHasStart;
  FHasTo := FPicker.FHasEnd;
  FFrom := FPicker.FStartDate;
  FTo := FPicker.FEndDate;
  FSelectingEnd := False;
  StartMonth := Date;
  if FHasFrom then StartMonth := FFrom;
  FMonth := MonthDate(StartMonth);
  FFocusDay := Trunc(StartMonth);
  if not Permitted(FFocusDay) then FFocusDay := 0;
  Width := ScaleValue(LayoutMetrics.OuterPadding * 2 + MonthCount * MonthWidth + (MonthCount - 1) * MonthSpacing +
    IfThen(FShowPresets, LayoutMetrics.PresetWidth, 0));
  Height := FooterTop + ScaleValue(IfThen(FShowFooter, LayoutMetrics.FooterHeight, 10));
  Invalidate;
end;

function TIdeDateRangeCalendar.Permitted(const D: TDateTime): Boolean;
begin
  Result := (D >= FMinDate) and (D <= FMaxDate) and
    (not FDisableWeekends or not (DayOfWeek(D) in [1, 7]));
  if Result and (FPicker <> nil) then
    Result := FPicker.CanSelectDate(D);
end;

function TIdeDateRangeCalendar.DayAt(const X, Y: Integer): TDateTime;
var
  I, Col, Row, DX, DY, FirstOffset: Integer;
  M: TDateTime;
begin
  Result := 0;
  DY := Y - CalendarTop;
  if (DY < 0) or (DY >= ScaleValue(6 * LayoutMetrics.DayHeight)) then Exit;
  Row := DY div ScaleValue(LayoutMetrics.DayHeight);
  for I := 0 to MonthCount - 1 do
  begin
    DX := X - MonthLeft(I) - ScaleValue(IfThen(FShowWeekNumbers, 20, 0));
    if (DX < 0) or (DX >= ScaleValue(7 * LayoutMetrics.DayWidth)) then Continue;
    Col := DX div ScaleValue(LayoutMetrics.DayWidth);
    M := IncMonth(FMonth, I);
    FirstOffset := (DayOfWeek(M) - FFirstDayOfWeek + 7) mod 7;
    Result := M - FirstOffset + Row * 7 + Col;
    if MonthOf(Result) <> MonthOf(M) then Result := 0;
    Exit;
  end;
end;

function TIdeDateRangeCalendar.HitAt(const X, Y: Integer): Integer;
var
  D: TDateTime;
  I, B, RightEdge, ExtraTop: Integer;
begin
  Result := 0;
  D := DayAt(X, Y);
  if D > 0 then
  begin
    if Permitted(D) then Result := 100;
    Exit;
  end;
  if (Y >= ScaleValue(LayoutMetrics.NavigationHitTop)) and (Y < ScaleValue(LayoutMetrics.HeaderBottom)) then
  begin
    if (X >= ScaleValue(LayoutMetrics.OuterPadding)) and (X < ScaleValue(LayoutMetrics.PreviousYearRight)) then Exit(7);
    if (X >= ScaleValue(LayoutMetrics.PreviousMonthLeft)) and (X < ScaleValue(LayoutMetrics.PreviousMonthRight)) then Exit(1);
    RightEdge := MonthLeft(MonthCount - 1) + ScaleValue(MonthWidth);
    if (X >= RightEdge - ScaleValue(LayoutMetrics.NextMonthOuterOffset)) and (X < RightEdge - ScaleValue(LayoutMetrics.NextMonthInnerOffset)) then Exit(2);
    if (X >= RightEdge - ScaleValue(LayoutMetrics.NextYearOffset)) and (X < RightEdge - ScaleValue(2)) then Exit(8);
  end;
  B := MonthLeft(MonthCount - 1) + ScaleValue(MonthWidth + 15);
  if FShowPresets and (X >= B) and (X < B + ScaleValue(LayoutMetrics.PresetWidth - 10)) then
    for I := 0 to Ord(High(TIdeDateRangePreset)) do
      if (TIdeDateRangePreset(I) in FPicker.FVisiblePresets) and
        ((I <> Ord(idrpCustom)) or FShowCustomPreset) and
        (Y >= ScaleValue(LayoutMetrics.PresetTop + PresetRow(TIdeDateRangePreset(I)) * LayoutMetrics.PresetRowHeight)) and
        (Y < ScaleValue(LayoutMetrics.PresetTop + PresetRow(TIdeDateRangePreset(I)) * LayoutMetrics.PresetRowHeight + LayoutMetrics.PresetButtonHeight)) then
        Exit(200 + I);
  if FShowPresets and (FPicker <> nil) then
  begin
    ExtraTop := VisiblePresetCount;
    for I := 0 to FPicker.NamedPresetCount - 1 do
      if (Y >= ScaleValue(LayoutMetrics.PresetTop + (ExtraTop + I) * LayoutMetrics.PresetRowHeight)) and
        (Y < ScaleValue(LayoutMetrics.PresetTop + (ExtraTop + I) * LayoutMetrics.PresetRowHeight + LayoutMetrics.PresetButtonHeight)) then
        Exit(300 + I);
  end;
  if FShowFooter and (Y >= FooterTop + ScaleValue(6)) and
    (Y < FooterTop + ScaleValue(6 + LayoutMetrics.FooterButtonHeight)) then
  begin
    if (X >= Width - ScaleValue(LayoutMetrics.FooterSidePadding + LayoutMetrics.FooterButtonWidth)) and
      (X < Width - ScaleValue(LayoutMetrics.FooterSidePadding)) then Exit(4);
    if (X >= Width - ScaleValue(LayoutMetrics.FooterSidePadding + LayoutMetrics.FooterButtonWidth * 2 + LayoutMetrics.FooterButtonGap)) and
      (X < Width - ScaleValue(LayoutMetrics.FooterSidePadding + LayoutMetrics.FooterButtonWidth + LayoutMetrics.FooterButtonGap)) then Exit(5);
    if (X >= ScaleValue(LayoutMetrics.FooterSidePadding)) and
      (X < ScaleValue(LayoutMetrics.FooterSidePadding + LayoutMetrics.FooterButtonWidth)) then Exit(6);
  end;
end;

function TIdeDateRangeCalendar.HitTestAt(const X, Y: Integer): TIdeDateRangeHitInfo;
var
  H, I, Col, Row, DX, DY, FirstOffset: Integer;
  D, M: TDateTime;
begin
  Result.Kind := idrhkNone;
  Result.Date := 0;
  Result.Index := -1;
  Result.MonthIndex := -1;
  Result.Bounds := Rect(0, 0, 0, 0);
  if (X < 0) or (Y < 0) or (X >= Width) or (Y >= Height) then Exit;
  D := DayAt(X, Y);
  if D > 0 then
  begin
    Result.Date := D;
    if Permitted(D) then Result.Kind := idrhkDay
    else Result.Kind := idrhkDisabledDay;
    DY := Y - CalendarTop;
    Row := DY div ScaleValue(LayoutMetrics.DayHeight);
    for I := 0 to MonthCount - 1 do
    begin
      DX := X - MonthLeft(I) - ScaleValue(IfThen(FShowWeekNumbers, 20, 0));
      if (DX < 0) or (DX >= ScaleValue(7 * LayoutMetrics.DayWidth)) then Continue;
      Col := DX div ScaleValue(LayoutMetrics.DayWidth);
      M := IncMonth(FMonth, I);
      FirstOffset := (DayOfWeek(M) - FFirstDayOfWeek + 7) mod 7;
      if Trunc(D) = Trunc(M - FirstOffset + Row * 7 + Col) then
      begin
        Result.MonthIndex := I;
        Result.Bounds := Rect(
          MonthLeft(I) + ScaleValue(IfThen(FShowWeekNumbers, 20, 0) + Col * LayoutMetrics.DayWidth),
          CalendarTop + ScaleValue(Row * LayoutMetrics.DayHeight),
          MonthLeft(I) + ScaleValue(IfThen(FShowWeekNumbers, 20, 0) + (Col + 1) * LayoutMetrics.DayWidth),
          CalendarTop + ScaleValue((Row + 1) * LayoutMetrics.DayHeight));
      end;
      Break;
    end;
    Exit;
  end;
  H := HitAt(X, Y);
  case H of
    1: Result.Kind := idrhkPreviousMonth;
    2: Result.Kind := idrhkNextMonth;
    7: Result.Kind := idrhkPreviousYear;
    8: Result.Kind := idrhkNextYear;
    4: Result.Kind := idrhkApply;
    5: Result.Kind := idrhkCancel;
    6: Result.Kind := idrhkClear;
  else
    if (H >= 200) and (H < 200 + Ord(High(TIdeDateRangePreset)) + 1) then
    begin
      Result.Kind := idrhkPreset;
      Result.Index := H - 200;
    end
    else if H >= 300 then
    begin
      Result.Kind := idrhkNamedPreset;
      Result.Index := H - 300;
    end;
  end;
end;

function TIdeDateRangeCalendar.HitTest(const AClientPoint: TPoint): TIdeDateRangeHitInfo;
begin
  Result := HitTestAt(AClientPoint.X, AClientPoint.Y);
end;

procedure TIdeDateRangeCalendar.NotifyHit(const AHit: TIdeDateRangeHitInfo);
begin
  if (AHit.Kind = FLastHitKind) and (AHit.Index = FLastHitIndex) then
  begin
    if not (AHit.Kind in [idrhkDay, idrhkDisabledDay]) or
      (Trunc(AHit.Date) = Trunc(FLastHitDate)) then Exit;
  end;
  FLastHitKind := AHit.Kind;
  FLastHitIndex := AHit.Index;
  FLastHitDate := AHit.Date;
  if (FPicker <> nil) and Assigned(FPicker.FOnHitTargetChanged) then
    FPicker.FOnHitTargetChanged(FPicker, AHit);
end;

procedure TIdeDateRangeCalendar.Paint;
var
  C: INimbusRenderCanvas;
  I, J, K, X, Y, Offset, N, WeekIndex: Integer;
  M, D, PreviewEnd: TDateTime;
  R: TRect;
  S: string;
  InRange, Endpoint, IsToday, Disabled, Hovered: Boolean;
  Days: TFormatSettings;
  DayBack, DayFore, DayBorder: TThemeColor;
  UseDayBack, UseDayFore, UseDayBorder: Boolean;
  RenderInfo: TIdeDateRangeDayRenderInfo;
  DayCaption, BadgeCaption: string;
  DecorDisabled, DecorHighlighted: Boolean;
  BadgeRect: TRect;
begin
  C := RenderCanvas;
  if C = nil then Exit;
  C.BeginRender(Canvas);
  try
    C.FillRectangle(NimbusPanelBackColor(Palette), ClientRect);
    TThemedIdeDateRangeRenderer.Surface(C, Palette, ClientRect,
      ScaleValue(FPicker.FDropDownCornerRadius));
    Days := FPicker.CultureSettings;
    PreviewEnd := FTo;
    if FSelectingEnd then
    begin
      PreviewEnd := FFrom;
      if FHoverDay > 0 then PreviewEnd := FHoverDay;
    end;
    for I := 0 to MonthCount - 1 do
    begin
      X := MonthLeft(I);
      M := IncMonth(FMonth, I);
      R := Rect(X, ScaleValue(LayoutMetrics.HeaderTop), X + ScaleValue(MonthWidth), ScaleValue(LayoutMetrics.HeaderBottom));
      C.DrawText(FormatDateTime('mmmm yyyy', M, Days), Font, NimbusInputForeColor(Palette),
        R, [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix]);
      for J := 0 to 6 do
      begin
        K := ((FFirstDayOfWeek - 1 + J) mod 7) + 1;
        R := Rect(X + ScaleValue(IfThen(FShowWeekNumbers, 20, 0) + J * LayoutMetrics.DayWidth),
          ScaleValue(LayoutMetrics.WeekHeaderTop), X + ScaleValue(IfThen(FShowWeekNumbers, 20, 0) + (J + 1) * LayoutMetrics.DayWidth), CalendarTop);
        S := Days.ShortDayNames[K];
        C.DrawText(S, Font, NimbusMutedForeColor(Palette), R,
          [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix]);
      end;
      Offset := (DayOfWeek(M) - FFirstDayOfWeek + 7) mod 7;
      for N := 0 to 41 do
      begin
        D := M + N - Offset;
        if MonthOf(D) <> MonthOf(M) then Continue;
        J := N mod 7;
        K := N div 7;
        X := MonthLeft(I) + ScaleValue(IfThen(FShowWeekNumbers, 20, 0) + J * LayoutMetrics.DayWidth);
        Y := CalendarTop + ScaleValue(K * LayoutMetrics.DayHeight);
        R := Rect(X, Y, X + ScaleValue(LayoutMetrics.DayWidth), Y + ScaleValue(LayoutMetrics.DayHeight));
        InRange := FHasFrom and (FHasTo or FSelectingEnd) and
          (D >= Min(FFrom, PreviewEnd)) and (D <= Max(FFrom, PreviewEnd));
        Endpoint := (FHasFrom and (D = FFrom)) or (FHasTo and (D = FTo));
        IsToday := D = Trunc(Date);
        Disabled := not Permitted(D);
        DecorDisabled := Disabled;
        DecorHighlighted := False;
        BadgeCaption := '';
        FPicker.DayDecoration(D, DecorDisabled, DecorHighlighted, BadgeCaption);
        Disabled := DecorDisabled;
        Hovered := (D = FHoverDay) or ((D = FFocusDay) and Focused);
        DayBack := NimbusPanelBackColor(Palette);
        DayFore := NimbusInputForeColor(Palette);
        DayBorder := NimbusInputBorderColor(Palette);
        UseDayBack := False;
        UseDayFore := False;
        UseDayBorder := False;
        if (not Endpoint) and (not Disabled) then
          FPicker.DayStyle(D, DayBack, DayFore, DayBorder,
            UseDayBack, UseDayFore, UseDayBorder);
        if DecorHighlighted and not Endpoint and not Disabled then
        begin
          UseDayBack := True;
          DayBack := NimbusBlendColor(NimbusPanelBackColor(Palette), NimbusAccentColor(Palette), 16);
        end;
        DayCaption := FPicker.DayText(D);
        if Assigned(FPicker.FOnDayRender) then
        begin
          RenderInfo.Date := D;
          RenderInfo.Bounds := R;
          RenderInfo.MonthIndex := I;
          RenderInfo.InRange := InRange;
          RenderInfo.IsEndpoint := Endpoint;
          RenderInfo.IsToday := IsToday;
          RenderInfo.IsDisabled := Disabled;
          RenderInfo.IsHovered := Hovered;
          FPicker.FOnDayRender(FPicker, RenderInfo, DayCaption,
            DayBack, DayFore, DayBorder, UseDayBack, UseDayFore, UseDayBorder);
        end;
        TThemedIdeDateRangeRenderer.Cell(C, Font, Palette, R, DayCaption,
          InRange, Endpoint, IsToday, Disabled, Hovered,
          DayBack, DayFore, DayBorder, UseDayBack, UseDayFore, UseDayBorder);
        if BadgeCaption <> '' then
        begin
          BadgeRect := Rect(R.Right - ScaleValue(13), R.Top + ScaleValue(1),
            R.Right - ScaleValue(1), R.Top + ScaleValue(12));
          C.DrawText(BadgeCaption, Font, NimbusAccentColor(Palette), BadgeRect,
            [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix]);
        end;
      end;
      if FShowWeekNumbers then
        for WeekIndex := 0 to 5 do
        begin
          D := M - Offset + WeekIndex * 7;
          R := Rect(MonthLeft(I), CalendarTop + ScaleValue(WeekIndex * LayoutMetrics.DayHeight),
            MonthLeft(I) + ScaleValue(20), CalendarTop + ScaleValue((WeekIndex + 1) * LayoutMetrics.DayHeight));
          C.DrawText(IntToStr(WeekOfTheYear(D)), Font, NimbusMutedForeColor(Palette), R,
            [ntfCenter, ntfVCenter, ntfSingleLine]);
        end;
    end;
    TThemedIdeDateRangeRenderer.Command(C, Font, Palette,
      Rect(ScaleValue(LayoutMetrics.OuterPadding), ScaleValue(LayoutMetrics.HeaderTop), ScaleValue(LayoutMetrics.PreviousYearRight), ScaleValue(LayoutMetrics.HeaderBottom)),
      '<<', FHit = 7, False);
    TThemedIdeDateRangeRenderer.Command(C, Font, Palette,
      Rect(ScaleValue(LayoutMetrics.PreviousMonthLeft), ScaleValue(LayoutMetrics.HeaderTop), ScaleValue(LayoutMetrics.PreviousMonthRight), ScaleValue(LayoutMetrics.HeaderBottom)),
      '<', FHit = 1, False);
    X := MonthLeft(MonthCount - 1) + ScaleValue(MonthWidth);
    TThemedIdeDateRangeRenderer.Command(C, Font, Palette,
      Rect(X - ScaleValue(LayoutMetrics.NextMonthOuterOffset), ScaleValue(LayoutMetrics.HeaderTop), X - ScaleValue(LayoutMetrics.NextMonthInnerOffset), ScaleValue(LayoutMetrics.HeaderBottom)),
      '>', FHit = 2, False);
    TThemedIdeDateRangeRenderer.Command(C, Font, Palette,
      Rect(X - ScaleValue(LayoutMetrics.NextYearOffset), ScaleValue(LayoutMetrics.HeaderTop), X - ScaleValue(2), ScaleValue(LayoutMetrics.HeaderBottom)),
      '>>', FHit = 8, False);
    if FShowPresets then
    begin
      X := MonthLeft(MonthCount - 1) + ScaleValue(MonthWidth + 15);
      for I := 0 to Ord(High(TIdeDateRangePreset)) do
      begin
        if not (TIdeDateRangePreset(I) in FPicker.FVisiblePresets) then Continue;
        if (I = Ord(idrpCustom)) and not FShowCustomPreset then Continue;
        R := Rect(X, ScaleValue(LayoutMetrics.PresetTop + PresetRow(TIdeDateRangePreset(I)) * LayoutMetrics.PresetRowHeight),
          X + ScaleValue(LayoutMetrics.PresetWidth - 10),
          ScaleValue(LayoutMetrics.PresetTop + PresetRow(TIdeDateRangePreset(I)) * LayoutMetrics.PresetRowHeight + LayoutMetrics.PresetButtonHeight));
        TThemedIdeDateRangeRenderer.Command(C, Font, Palette, R,
          FPicker.GetPresetCaption(TIdeDateRangePreset(I)), FHit = 200 + I, False);
      end;
      X := VisiblePresetCount;
      for I := 0 to FPicker.NamedPresetCount - 1 do
      begin
        R := Rect(MonthLeft(MonthCount - 1) + ScaleValue(MonthWidth + 15),
          ScaleValue(LayoutMetrics.PresetTop + (X + I) * LayoutMetrics.PresetRowHeight),
          MonthLeft(MonthCount - 1) + ScaleValue(MonthWidth + 15 + LayoutMetrics.PresetWidth - 10),
          ScaleValue(LayoutMetrics.PresetTop + (X + I) * LayoutMetrics.PresetRowHeight + LayoutMetrics.PresetButtonHeight));
        TThemedIdeDateRangeRenderer.Command(C, Font, Palette, R,
          FPicker.FNamedPresets[I].Caption, FHit = 300 + I, False);
      end;
    end;
    if FShowFooter then
    begin
      Y := FooterTop;
      C.DrawLine(NimbusInputBorderColor(Palette), ScaleValue(12), Y, Width - ScaleValue(12), Y);
      TThemedIdeDateRangeRenderer.Command(C, Font, Palette,
        Rect(ScaleValue(LayoutMetrics.FooterSidePadding), Y + ScaleValue(6),
          ScaleValue(LayoutMetrics.FooterSidePadding + LayoutMetrics.FooterButtonWidth), Y + ScaleValue(6 + LayoutMetrics.FooterButtonHeight)),
        FPicker.FResetText, FHit = 6, False);
      TThemedIdeDateRangeRenderer.Command(C, Font, Palette,
        Rect(Width - ScaleValue(LayoutMetrics.FooterSidePadding + LayoutMetrics.FooterButtonWidth * 2 + LayoutMetrics.FooterButtonGap),
          Y + ScaleValue(6), Width - ScaleValue(LayoutMetrics.FooterSidePadding + LayoutMetrics.FooterButtonWidth + LayoutMetrics.FooterButtonGap),
          Y + ScaleValue(6 + LayoutMetrics.FooterButtonHeight)),
        FPicker.FCancelText, FHit = 5, False);
      TThemedIdeDateRangeRenderer.Command(C, Font, Palette,
        Rect(Width - ScaleValue(LayoutMetrics.FooterSidePadding + LayoutMetrics.FooterButtonWidth), Y + ScaleValue(6),
          Width - ScaleValue(LayoutMetrics.FooterSidePadding), Y + ScaleValue(6 + LayoutMetrics.FooterButtonHeight)),
        FPicker.FApplyText, FHit = 4, True);
    end;
  finally
    C.EndRender;
  end;
end;

procedure TIdeDateRangeCalendar.SetHoverDay(const ADate: TDateTime);
var
  OldDay: TDateTime;
  NewText: string;
  CanShow: Boolean;
begin
  if FHoverDay = ADate then Exit;
  OldDay := FHoverDay;
  FHoverDay := ADate;
  if FPicker <> nil then
  begin
    if (OldDay > 0) and Assigned(FPicker.FOnDayMouseLeave) then
      FPicker.FOnDayMouseLeave(FPicker, OldDay);
    if (ADate > 0) and Assigned(FPicker.FOnDayMouseEnter) then
      FPicker.FOnDayMouseEnter(FPicker, ADate);
    if FSelectingEnd and FHasFrom and Assigned(FPicker.FOnRangePreviewChanged) then
      FPicker.FOnRangePreviewChanged(FPicker, Min(FFrom, IfThen(ADate > 0, ADate, FFrom)),
        Max(FFrom, IfThen(ADate > 0, ADate, FFrom)));
    NewText := '';
    CanShow := ADate > 0;
    if CanShow and Assigned(FPicker.FOnDayHoverHint) then
      FPicker.FOnDayHoverHint(FPicker, ADate, NewText, CanShow);
  end;
  Invalidate;
end;

procedure TIdeDateRangeCalendar.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  D: TDateTime;
  H: Integer;
begin
  inherited;
  D := DayAt(X, Y);
  H := HitAt(X, Y);
  if (D <> FHoverDay) or (H <> FHit) then
  begin
    SetHoverDay(D);
    FHit := H;
    NotifyHit(HitTestAt(X, Y));
    Invalidate;
  end;
  if H <> 0 then Cursor := crHandPoint else Cursor := crDefault;
end;

procedure TIdeDateRangeCalendar.CMMouseLeaveCalendar(var M: TMessage);
begin
  inherited;
  FHit := 0;
  SetHoverDay(0);
  NotifyHit(HitTestAt(-1, -1));
  Invalidate;
end;

procedure TIdeDateRangeCalendar.Navigate(const Delta: Integer);
begin
  FMonth := IncMonth(FMonth, Delta);
  if (FPicker <> nil) and Assigned(FPicker.FOnVisibleMonthChanged) then
    FPicker.FOnVisibleMonthChanged(FPicker, FMonth);
  Invalidate;
end;

procedure TIdeDateRangeCalendar.ChooseDate(const D: TDateTime);
var
  LAllow: Boolean;
begin
  if not Permitted(D) then Exit;
  LAllow := True;
  if (FPicker <> nil) and Assigned(FPicker.FOnDaySelecting) then
    FPicker.FOnDaySelecting(FPicker, D, LAllow);
  if not LAllow then Exit;
  FFocusDay := D;
  case FSelectionMode of
    idrsmSingleDate:
      begin FFrom := D; FTo := D; FHasFrom := True; FHasTo := True; FSelectingEnd := False; end;
    idrsmStartOnly:
      begin FFrom := D; FHasFrom := True; FHasTo := False; FSelectingEnd := False; end;
    idrsmEndOnly:
      begin FTo := D; FHasTo := True; FHasFrom := False; FSelectingEnd := False; end;
    idrsmRange:
      begin
        if not FSelectingEnd then
        begin
          FFrom := D;
          FHasFrom := True;
          FHasTo := False;
          FSelectingEnd := True;
        end
        else
        begin
          FTo := D;
          if FTo < FFrom then
          begin
            FTo := FFrom;
            FFrom := D;
          end;
          FHasTo := True;
          FSelectingEnd := False;
        end;
      end;
  end;
  Invalidate;
end;

procedure TIdeDateRangeCalendar.ChoosePreset(const Index: Integer);
var
  D, S, E: TDateTime;
begin
  D := Trunc(Date);
  S := D;
  E := D;
  FLastPreset := TIdeDateRangePreset(Index);
  case FLastPreset of
    idrpYesterday: begin S := D - 1; E := S; end;
    idrpThisWeek: S := BeginningOfWeek(D, FFirstDayOfWeek);
    idrpLastWeek: begin E := BeginningOfWeek(D, FFirstDayOfWeek) - 1; S := E - 6; end;
    idrpThisMonth: S := StartOfTheMonth(D);
    idrpLastMonth: begin E := StartOfTheMonth(D) - 1; S := StartOfTheMonth(E); end;
    idrpLast7Days: S := D - 6;
    idrpLast14Days: S := D - 13;
    idrpLast30Days: S := D - 29;
    idrpThisYear: S := EncodeDate(YearOf(D), 1, 1);
    idrpLastYear: begin S := EncodeDate(YearOf(D) - 1, 1, 1); E := EncodeDate(YearOf(D) - 1, 12, 31); end;
  end;
  if FLastPreset = idrpThisWeek then E := S + 6;
  if FLastPreset = idrpThisMonth then E := EndOfTheMonth(D);
  if FLastPreset = idrpThisYear then E := EncodeDate(YearOf(D), 12, 31);
  if S < FMinDate then S := FMinDate;
  if E > FMaxDate then E := FMaxDate;
  if S > E then Exit;
  if FLastPreset = idrpCustom then
  begin
    S := Trunc(FPicker.FCustomPresetStartDate);
    E := Trunc(FPicker.FCustomPresetEndDate);
    if E < S then
    begin
      if not FPicker.FSwapInvalidRange then Exit;
      D := S;
      S := E;
      E := D;
    end;
  end;
  if (S < FMinDate) or (E > FMaxDate) or (S > E) then Exit;
  if (FPicker <> nil) and not FPicker.PermitPreset(FLastPreset, S, E) then Exit;
  FFrom := S;
  FTo := E;
  FHasFrom := True;
  FHasTo := True;
  FSelectingEnd := False;
  FMonth := MonthDate(S);
  Invalidate;
  if (FPicker <> nil) then
    FPicker.NotifyPresetApplied(FLastPreset, S, E);
  if Assigned(FOnPreset) then FOnPreset(Self);
end;

procedure TIdeDateRangeCalendar.ChooseNamedPreset(const Index: Integer);
var
  S, E, D: TDateTime;
  Allow: Boolean;
begin
  if (FPicker = nil) or (Index < 0) or (Index >= FPicker.NamedPresetCount) then Exit;
  S := Trunc(FPicker.FNamedPresets[Index].StartDate);
  E := Trunc(FPicker.FNamedPresets[Index].EndDate);
  if E < S then
  begin
    if not FPicker.FSwapInvalidRange then Exit;
    D := S;
    S := E;
    E := D;
  end;
  if (S < FMinDate) or (E > FMaxDate) or
    (not FPicker.FAllowSingle and (S = E)) or
    not Permitted(S) or not Permitted(E) then Exit;
  Allow := True;
  if Assigned(FPicker.FOnNamedPresetApplying) then
    FPicker.FOnNamedPresetApplying(FPicker, Index,
      FPicker.FNamedPresets[Index].Caption, S, E, Allow);
  if not Allow then Exit;
  FFrom := S;
  FTo := E;
  FHasFrom := True;
  FHasTo := True;
  FSelectingEnd := False;
  FMonth := MonthDate(S);
  Invalidate;
  if Assigned(FPicker.FOnNamedPresetApplied) then
    FPicker.FOnNamedPresetApplied(FPicker, Index,
      FPicker.FNamedPresets[Index].Caption, S, E);
  if Assigned(FOnPreset) then FOnPreset(Self);
end;

procedure TIdeDateRangeCalendar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  H: Integer;
  D: TDateTime;
  LHandled: Boolean;
begin
  inherited;
  if Button = mbRight then
  begin
    D := DayAt(X, Y);
    if (D > 0) and (FPicker <> nil) and Assigned(FPicker.FOnDayContextPopup) then
    begin
      LHandled := False;
      FPicker.FOnDayContextPopup(FPicker, D, ClientToScreen(Point(X, Y)), LHandled);
    end;
    Exit;
  end;
  if Button <> mbLeft then Exit;
  SetFocus;
  H := HitAt(X, Y);
  case H of
    1: Navigate(-1);
    2: Navigate(1);
    7: Navigate(-12);
    8: Navigate(12);
    4: if Assigned(FOnAccept) then FOnAccept(Self);
    5: if Assigned(FOnCancel) then FOnCancel(Self);
    6: begin
         FHasFrom := False;
         FHasTo := False;
         FSelectingEnd := False;
         Invalidate;
         if Assigned(FOnClear) then FOnClear(Self);
       end;
    100: begin
           D := DayAt(X, Y);
           if D > 0 then
           begin
             if (FPicker <> nil) and Assigned(FPicker.FOnDayClick) then
               FPicker.FOnDayClick(FPicker, D);
             ChooseDate(D);
             if (FPicker <> nil) and FPicker.FCloseOnRangeSelected and
               FHasFrom and FHasTo and not FSelectingEnd and Assigned(FOnAccept) then
               FOnAccept(Self);
           end;
         end;
  else
    if (H >= 200) and (H < 200 + Ord(High(TIdeDateRangePreset)) + 1) then
      ChoosePreset(H - 200)
    else if H >= 300 then ChooseNamedPreset(H - 300);
  end;
end;

procedure TIdeDateRangeCalendar.DblClick;
var
  P: TPoint;
  D: TDateTime;
begin
  inherited;
  P := ScreenToClient(Mouse.CursorPos);
  D := DayAt(P.X, P.Y);
  if (D > 0) and Permitted(D) and (FPicker <> nil) and
    Assigned(FPicker.FOnDayDoubleClick) then
    FPicker.FOnDayDoubleClick(FPicker, D);
end;

procedure TIdeDateRangeCalendar.MoveFocus(const ATarget: TDateTime; const AStep: Integer);
var
  D: TDateTime;
  I: Integer;
begin
  D := Trunc(ATarget);
  for I := 0 to 366 do
  begin
    if (D < FMinDate) or (D > FMaxDate) then Exit;
    if Permitted(D) then
    begin
      FFocusDay := D;
      if D < FMonth then FMonth := MonthDate(D)
      else if D >= IncMonth(FMonth, MonthCount) then
        FMonth := IncMonth(MonthDate(D), 1 - MonthCount);
      Invalidate;
      Exit;
    end;
    D := D + AStep;
  end;
end;

procedure TIdeDateRangeCalendar.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  Message.Result := Message.Result or DLGC_WANTARROWS or DLGC_WANTALLKEYS;
end;

procedure TIdeDateRangeCalendar.KeyDown(var Key: Word; Shift: TShiftState);
var
  D: TDateTime;
  Delta: Integer;
begin
  inherited;
  D := FFocusDay;
  if D = 0 then D := Trunc(Date);
  Delta := 0;
  case Key of
    VK_ESCAPE: begin if Assigned(FOnCancel) then FOnCancel(Self); Key := 0; end;
    VK_RETURN: begin if Assigned(FOnAccept) then FOnAccept(Self); Key := 0; end;
    VK_SPACE: begin if Permitted(D) then ChooseDate(D); Key := 0; end;
    VK_LEFT: Delta := -1;
    VK_RIGHT: Delta := 1;
    VK_UP: Delta := -7;
    VK_DOWN: Delta := 7;
    VK_HOME: begin
      MoveFocus(BeginningOfWeek(D, FFirstDayOfWeek), 1);
      Key := 0;
    end;
    VK_END: begin
      MoveFocus(BeginningOfWeek(D, FFirstDayOfWeek) + 6, -1);
      Key := 0;
    end;
    VK_PRIOR: begin
      if ssCtrl in Shift then MoveFocus(IncMonth(D, -12), -1)
      else MoveFocus(IncMonth(D, -1), -1);
      Key := 0;
    end;
    VK_NEXT: begin
      if ssCtrl in Shift then MoveFocus(IncMonth(D, 12), 1)
      else MoveFocus(IncMonth(D, 1), 1);
      Key := 0;
    end;
  end;
  if Delta <> 0 then
  begin
    MoveFocus(D + Delta, IfThen(Delta < 0, -1, 1));
    Key := 0;
  end;
end;

constructor TIdeDateRangePopup.CreateForPicker(APicker: TCustomThemedIdeDateRangePicker);
begin
  inherited CreateNew(nil);
  FPicker := APicker;
  BorderStyle := bsNone;
  Position := poDesigned;
  FormStyle := fsStayOnTop;
  KeyPreview := True;
  FCalendar := TIdeDateRangeCalendar.Create(Self);
  FCalendar.Parent := Self;
  FCalendar.Align := alNone;
  FCalendar.Setup(APicker);
  FCalendar.OnAccept := AcceptClick;
  FCalendar.OnCancel := CancelClick;
  FCalendar.OnClear := ClearClick;
  FCalendar.OnPreset := PresetClick;

  Synchronize;
end;

procedure TIdeDateRangePopup.Synchronize;
var
  LRadius: Integer;
begin
  FCalendar.SyncFromPicker;
  ClientWidth := Max(FCalendar.Width, FPicker.FDropDownWidth);
  ClientHeight := Max(FCalendar.Height, FPicker.FDropDownHeight);
  FCalendar.SetBounds(0, 0, ClientWidth, ClientHeight);
  LRadius := FPicker.FDropDownCornerRadius * 2;
  if LRadius > 0 then
    SetWindowRgn(Handle, CreateRoundRectRgn(0, 0, ClientWidth,
      ClientHeight, LRadius, LRadius), True)
  else
    SetWindowRgn(Handle, 0, True);
end;

procedure TIdeDateRangePopup.AcceptClick;
var
  Allow: Boolean;
begin
  Allow := True;
  if Assigned(FPicker.FOnApplying) then
    FPicker.FOnApplying(FPicker, FCalendar.FromDate, FCalendar.ToDate,
      FCalendar.HasFrom, FCalendar.HasTo, Allow);
  if not Allow then Exit;
  if not (FCalendar.HasFrom or FCalendar.HasTo) and not FPicker.FAllowEmpty then Exit;
  if FCalendar.HasFrom and FCalendar.HasTo and
    (not FPicker.FAllowSingle) and (FCalendar.FromDate = FCalendar.ToDate) then Exit;
  if FCalendar.HasFrom and FCalendar.HasTo then
    FPicker.SetRange(FCalendar.FromDate, FCalendar.ToDate)
  else if FCalendar.HasFrom then
    FPicker.SetStartDate(FCalendar.FromDate)
  else if FCalendar.HasTo then
    FPicker.SetEndDate(FCalendar.ToDate)
  else if FPicker.FAllowEmpty then FPicker.ClearRange;
  if FCalendar.HasFrom and FCalendar.HasTo and
    ((not FPicker.FHasStart) or (not FPicker.FHasEnd) or
     (FPicker.FStartDate <> Min(FCalendar.FromDate, FCalendar.ToDate)) or
     (FPicker.FEndDate <> Max(FCalendar.FromDate, FCalendar.ToDate))) then Exit;
  if Assigned(FPicker.FOnApply) then FPicker.FOnApply(FPicker);
  if Assigned(FPicker.FOnRangeApplied) then FPicker.FOnRangeApplied(FPicker);
  Hide;
end;

procedure TIdeDateRangePopup.CancelClick(Sender: TObject);
begin
  Hide;
  if Assigned(FPicker.FOnCancel) then FPicker.FOnCancel(FPicker);
  if Assigned(FPicker.FOnRangeCanceled) then FPicker.FOnRangeCanceled(FPicker);
end;

procedure TIdeDateRangePopup.ClearClick(Sender: TObject);
begin
  FPicker.ClearRange;
end;

procedure TIdeDateRangePopup.PresetClick(Sender: TObject);
begin
  if Assigned(FPicker.FOnPreset) then FPicker.FOnPreset(FPicker);
end;

procedure TIdeDateRangePopup.NotifyClosed;
begin
  if FClosingNotified then Exit;
  FClosingNotified := True;
  if (FPicker <> nil) and Assigned(FPicker.FOnPopupClosed) then
    FPicker.FOnPopupClosed(FPicker);
end;

procedure TIdeDateRangePopup.DoHide;
begin
  inherited;
  NotifyClosed;
end;

procedure TIdeDateRangePopup.Deactivate;
begin
  inherited;
  Hide;
end;

constructor TCustomThemedIdeDateRangePicker.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 294;
  Height := 34;
  TabStop := True;
  Font.Name := 'Segoe UI';
  Font.Size := 9;
  FMonthMode := idrmTwoMonths;
  FSelectionMode := idrsmRange;
  FAllowEmpty := True;
  FAllowSingle := True;
  FShowPresets := True;
  FShowFooter := True;
  FShowClear := True;
  FShowCalendarIcon := False;
  FVisiblePresets := [idrpToday..idrpCustom];
  FFirstDayOfWeek := 2;
  FMinDate := EncodeDate(1900, 1, 1);
  FMaxDate := EncodeDate(2100, 12, 31);
  FInvalidEmptyText := 'A date range is required';
  FInvalidOrderText := 'Start date must not be after end date';
  FInvalidSingleText := 'Start and end must be different';
  FInvalidMinText := 'Date is before the allowed minimum';
  FInvalidMaxText := 'Date is after the allowed maximum';
  FInvalidWeekendText := 'Weekend dates are not allowed';
  FPlaceholder := SIdeRangePlaceholder;
  FDateFormat := 'dd.MM.yyyy';
  FSeparator := ' - ';
  FApplyText := SIdeRangeApply;
  FCancelText := SIdeRangeCancel;
  FResetText := SIdeRangeReset;
  FTodayText := SIdeRangeToday;
  FPresets[idrpToday] := SIdeRangeToday;
  FPresets[idrpYesterday] := SIdeRangeYesterday;
  FPresets[idrpThisWeek] := SIdeRangeThisWeek;
  FPresets[idrpLastWeek] := SIdeRangeLastWeek;
  FPresets[idrpThisMonth] := SIdeRangeThisMonth;
  FPresets[idrpLastMonth] := SIdeRangeLastMonth;
  FPresets[idrpLast7Days] := SIdeRangeLast7Days;
  FPresets[idrpLast14Days] := SIdeRangeLast14Days;
  FPresets[idrpLast30Days] := SIdeRangeLast30Days;
  FPresets[idrpThisYear] := SIdeRangeThisYear;
  FPresets[idrpLastYear] := SIdeRangeLastYear;
  FPresets[idrpCustom] := SIdeRangeCustom;
  FSwapInvalidRange := True;
  FDisplayMode := idrmdCompact;
  FDropDownCornerRadius := 7;
end;

procedure TCustomThemedIdeDateRangePicker.StyleModeChanged;
var
  LNormal, LCompact: Integer;
begin
  inherited StyleModeChanged;
  if Align = alNone then
  begin
    if StyleMode = stCompact then
    begin
      FCompactNormalHeight := Height;
      if FDisplayMode = idrmdDetailed then
      begin
        LNormal := 49;
        LCompact := 40;
      end
      else
      begin
        LNormal := 34;
        LCompact := 28;
      end;
      FCompactAppliedHeight := Max(ScaleValue(23), (Height * LCompact + LNormal div 2) div LNormal);
      Height := FCompactAppliedHeight;
    end
    else if FCompactNormalHeight > 0 then
    begin
      if Height = FCompactAppliedHeight then Height := FCompactNormalHeight;
      FCompactNormalHeight := 0;
      FCompactAppliedHeight := 0;
    end;
  end;
  if FPopup <> nil then FPopup.Synchronize;
end;

destructor TCustomThemedIdeDateRangePicker.Destroy;
begin
  FreeAndNil(FPopup);
  inherited;
end;

function TCustomThemedIdeDateRangePicker.AddNamedPreset(
  const ACaption: string; const AStart, AEnd: TDateTime): Integer;
begin
  Result := Length(FNamedPresets);
  SetLength(FNamedPresets, Result + 1);
  FNamedPresets[Result].Caption := ACaption;
  FNamedPresets[Result].StartDate := Trunc(AStart);
  FNamedPresets[Result].EndDate := Trunc(AEnd);
  if FPopup <> nil then FPopup.Synchronize;
end;

procedure TCustomThemedIdeDateRangePicker.ClearNamedPresets;
begin
  SetLength(FNamedPresets, 0);
  if FPopup <> nil then FPopup.Synchronize;
end;

procedure TCustomThemedIdeDateRangePicker.UpdateNamedPreset(const AIndex: Integer;
  const ACaption: string; const AStart, AEnd: TDateTime);
begin
  if (AIndex < 0) or (AIndex >= Length(FNamedPresets)) then
    raise EArgumentOutOfRangeException.Create('Named preset index out of range');
  FNamedPresets[AIndex].Caption := ACaption;
  FNamedPresets[AIndex].StartDate := Trunc(AStart);
  FNamedPresets[AIndex].EndDate := Trunc(AEnd);
  if FPopup <> nil then FPopup.Synchronize;
end;

procedure TCustomThemedIdeDateRangePicker.RemoveNamedPreset(const AIndex: Integer);
var
  I: Integer;
begin
  if (AIndex < 0) or (AIndex >= Length(FNamedPresets)) then
    raise EArgumentOutOfRangeException.Create('Named preset index out of range');
  for I := AIndex to High(FNamedPresets) - 1 do
    FNamedPresets[I] := FNamedPresets[I + 1];
  SetLength(FNamedPresets, Length(FNamedPresets) - 1);
  if FPopup <> nil then FPopup.Synchronize;
end;

function TCustomThemedIdeDateRangePicker.NamedPresetCount: Integer;
begin
  Result := Length(FNamedPresets);
end;

function TCustomThemedIdeDateRangePicker.NamedPreset(
  const AIndex: Integer): TIdeDateRangeNamedPreset;
begin
  if (AIndex < 0) or (AIndex >= Length(FNamedPresets)) then
    raise EArgumentOutOfRangeException.Create('Named preset index out of range');
  Result := FNamedPresets[AIndex];
end;

procedure TCustomThemedIdeDateRangePicker.SetPresetCaption(const APreset: TIdeDateRangePreset; const Value: string);
begin
  FPresets[APreset] := Value;
  if FPopup <> nil then FPopup.FCalendar.Invalidate;
end;

function TCustomThemedIdeDateRangePicker.GetPresetText(Index: Integer): string;
begin
  Result := FPresets[TIdeDateRangePreset(Index)];
end;

procedure TCustomThemedIdeDateRangePicker.SetPresetText(Index: Integer; const Value: string);
begin
  SetPresetCaption(TIdeDateRangePreset(Index), Value);
end;

function TCustomThemedIdeDateRangePicker.GetPresetCaption(const P: TIdeDateRangePreset): string;
begin
  Result := FPresets[P];
end;

function TCustomThemedIdeDateRangePicker.CanSelectDate(const ADate: TDateTime): Boolean;
var
  Highlighted: Boolean;
  Badge: string;
begin
  Result := True;
  if Assigned(FOnCanSelectDate) then
    FOnCanSelectDate(Self, Trunc(ADate), Result);
  if Result and Assigned(FOnDayDecoration) then
  begin
    Result := False;
    Highlighted := False;
    Badge := '';
    DayDecoration(ADate, Result, Highlighted, Badge);
    Result := not Result;
  end;
end;

procedure TCustomThemedIdeDateRangePicker.DayDecoration(const ADate: TDateTime;
  var ADisabled, AHighlighted: Boolean; var ABadgeText: string);
begin
  if Assigned(FOnDayDecoration) then
    FOnDayDecoration(Self, Trunc(ADate), ADisabled, AHighlighted, ABadgeText);
end;

function TCustomThemedIdeDateRangePicker.DayText(const ADate: TDateTime): string;
begin
  Result := IntToStr(DayOfTheMonth(ADate));
  if Assigned(FOnDayText) then
    FOnDayText(Self, Trunc(ADate), Result);
end;

procedure TCustomThemedIdeDateRangePicker.DayStyle(const ADate: TDateTime;
  var ABackColor, ATextColor, ABorderColor: TThemeColor;
  var AUseBackground, AUseTextColor, AUseBorder: Boolean);
begin
  if Assigned(FOnDayStyle) then
    FOnDayStyle(Self, Trunc(ADate), ABackColor, ATextColor, ABorderColor,
      AUseBackground, AUseTextColor, AUseBorder);
end;

function TCustomThemedIdeDateRangePicker.GetValidationMessage: string;
begin
  Result := '';
  if not FAllowEmpty and not FHasStart and not FHasEnd then
    Exit(FInvalidEmptyText);
  if FHasStart and FHasEnd then
  begin
    if FStartDate > FEndDate then Exit(FInvalidOrderText);
    if not FAllowSingle and (FStartDate = FEndDate) then
      Exit(FInvalidSingleText);
  end;
  if (FHasStart and (FStartDate < FMinDate)) or
     (FHasEnd and (FEndDate < FMinDate)) then
    Exit(FInvalidMinText);
  if (FHasStart and (FStartDate > FMaxDate)) or
     (FHasEnd and (FEndDate > FMaxDate)) then
    Exit(FInvalidMaxText);
  if FDisableWeekends then
  begin
    if (FHasStart and (DayOfTheWeek(FStartDate) >= 6)) or
       (FHasEnd and (DayOfTheWeek(FEndDate) >= 6)) then
      Exit(FInvalidWeekendText);
  end;
end;

function TCustomThemedIdeDateRangePicker.GetIsValid: Boolean;
begin
  Result := GetValidationMessage = '';
end;

function TCustomThemedIdeDateRangePicker.CultureSettings: TFormatSettings;
begin
  Result := FormatSettings;
  if FCultureName <> '' then
    Result := TFormatSettings.Create(FCultureName);
end;

procedure TCustomThemedIdeDateRangePicker.SetCultureName(const V: string);
begin
  if FCultureName = V then Exit;
  if V <> '' then TFormatSettings.Create(V);
  FCultureName := V;
  Invalidate;
  if FPopup <> nil then FPopup.FCalendar.Invalidate;
end;

procedure TCustomThemedIdeDateRangePicker.SetVisiblePresets(const V: TIdeDateRangeVisiblePresets);
begin
  if FVisiblePresets = V then Exit;
  FVisiblePresets := V;
  if FPopup <> nil then FPopup.Synchronize;
end;

function TCustomThemedIdeDateRangePicker.GetDisplayText: string;
begin
  Result := FPlaceholder;
  if FHasStart and FHasEnd then
    Result := FormatDateTime(FDateFormat, FStartDate, CultureSettings) + FSeparator + FormatDateTime(FDateFormat, FEndDate, CultureSettings)
  else if FHasStart then Result := FormatDateTime(FDateFormat, FStartDate, CultureSettings)
  else if FHasEnd then Result := FormatDateTime(FDateFormat, FEndDate, CultureSettings);
end;

procedure TCustomThemedIdeDateRangePicker.Paint;
var
  C: INimbusRenderCanvas;
  DateRangeDetailStart, DateRangeDetailEnd: string;
begin
  DateRangeDetailStart := '-';
  DateRangeDetailEnd := '-';
  if FHasStart then DateRangeDetailStart := FormatDateTime(FDateFormat, FStartDate, CultureSettings);
  if FHasEnd then DateRangeDetailEnd := FormatDateTime(FDateFormat, FEndDate, CultureSettings);
  C := RenderCanvas;
  if C = nil then Exit;
  C.BeginRender(Canvas);
  try
    TThemedIdeDateRangeRenderer.RenderField(C, Font, Palette, ClientRect, GetDisplayText,
      FHot, Focused, FHasStart or FHasEnd, FShowClear, FShowCalendarIcon,
      FDisplayMode = idrmdDetailed, ScaleValue(IfThen((FSizeMode = idrsmCompact) or (StyleMode = stCompact), 5, 6)));
    if FDisplayMode = idrmdDetailed then
    begin
      if FHasStart or FHasEnd then
        C.DrawText(SIdeRangeFrom + ': ' + DateRangeDetailStart + '    ' +
          SIdeRangeTo + ': ' + DateRangeDetailEnd,
          Font, NimbusMutedForeColor(Palette),
          Rect(ScaleValue(12), Height div 2 + ScaleValue(1),
            Width - ScaleValue(IfThen(FShowCalendarIcon, 90, 59)), Height - ScaleValue(2)),
          [ntfVCenter, ntfSingleLine, ntfEndEllipsis, ntfNoPrefix]);
    end;
  finally
    C.EndRender;
  end;
end;

procedure TCustomThemedIdeDateRangePicker.CMMouseEnter(var M: TMessage);
begin
  inherited;
  FHot := True;
  Invalidate;
end;

procedure TCustomThemedIdeDateRangePicker.CMMouseLeave(var M: TMessage);
begin
  inherited;
  FHot := False;
  Invalidate;
end;

procedure TCustomThemedIdeDateRangePicker.CMCancelMode(var M: TCMCancelMode);
begin
  inherited;
end;

procedure TCustomThemedIdeDateRangePicker.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if (Button <> mbLeft) or not Enabled or FReadOnly then Exit;
  SetFocus;
  if FShowClear and (FHasStart or FHasEnd) and (X >= Width - ScaleValue(53))
    and (X < Width - ScaleValue(32)) then ClearRange
  else ShowDropDown;
end;

procedure TCustomThemedIdeDateRangePicker.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if Key in [VK_RETURN, VK_SPACE, VK_DOWN] then
  begin
    ShowDropDown;
    Key := 0;
  end
  else if Key = VK_ESCAPE then
  begin
    CloseDropDown;
    Key := 0;
  end;
end;

procedure TCustomThemedIdeDateRangePicker.SetRange(const AStart, AEnd: TDateTime);
var
  S, E: TDateTime;
  Allow: Boolean;
begin
  S := Trunc(AStart);
  E := Trunc(AEnd);
  if E < S then
  begin
    if not FSwapInvalidRange then Exit;
    S := Trunc(AEnd);
    E := Trunc(AStart);
  end;
  if (S < FMinDate) or (E > FMaxDate) then Exit;
  if not FAllowSingle and (S = E) then Exit;
  if FDisableWeekends and ((DayOfWeek(S) in [1, 7]) or
    (DayOfWeek(E) in [1, 7])) then Exit;
  if not CanSelectDate(S) or not CanSelectDate(E) then Exit;
  Allow := True;
  if Assigned(FOnChanging) then FOnChanging(Self, S, E, Allow);
  if not Allow then Exit;
  if FHasStart and FHasEnd and (FStartDate = S) and (FEndDate = E) then Exit;
  FStartDate := S;
  FEndDate := E;
  FHasStart := True;
  FHasEnd := True;
  Invalidate;
  if Assigned(FOnChanged) then FOnChanged(Self);
end;

procedure TCustomThemedIdeDateRangePicker.SetStartDate(const V: TDateTime);
begin
  if FHasEnd then SetRange(V, FEndDate)
  else if (V >= FMinDate) and (V <= FMaxDate) then
  begin
    FStartDate := Trunc(V);
    FHasStart := True;
    Invalidate;
    if Assigned(FOnChanged) then FOnChanged(Self);
  end;
end;

procedure TCustomThemedIdeDateRangePicker.SetEndDate(const V: TDateTime);
begin
  if FHasStart then SetRange(FStartDate, V)
  else if (V >= FMinDate) and (V <= FMaxDate) then
  begin
    FEndDate := Trunc(V);
    FHasEnd := True;
    Invalidate;
    if Assigned(FOnChanged) then FOnChanged(Self);
  end;
end;

procedure TCustomThemedIdeDateRangePicker.ClearRange;
begin
  if not FAllowEmpty then Exit;
  if not FHasStart and not FHasEnd then Exit;
  FHasStart := False;
  FHasEnd := False;
  Invalidate;
  if Assigned(FOnClear) then FOnClear(Self);
  if Assigned(FOnRangeCleared) then FOnRangeCleared(Self);
  if Assigned(FOnChanged) then FOnChanged(Self);
end;

function TCustomThemedIdeDateRangePicker.PermitPreset(
  const APreset: TIdeDateRangePreset; const AStart, AEnd: TDateTime): Boolean;
begin
  Result := True;
  if Assigned(FOnPresetApplying) then
    FOnPresetApplying(Self, APreset, AStart, AEnd, Result);
end;

procedure TCustomThemedIdeDateRangePicker.NotifyPresetApplied(
  const APreset: TIdeDateRangePreset; const AStart, AEnd: TDateTime);
begin
  if Assigned(FOnPresetApplied) then
    FOnPresetApplied(Self, APreset, AStart, AEnd);
end;

procedure TCustomThemedIdeDateRangePicker.ApplyPreset(const APreset: TIdeDateRangePreset);
var
  D, S, E: TDateTime;
begin
  D := Trunc(Date);
  S := D;
  E := D;
  case APreset of
    idrpYesterday: begin S := D - 1; E := S; end;
    idrpThisWeek: begin S := BeginningOfWeek(D, FFirstDayOfWeek); E := S + 6; end;
    idrpLastWeek: begin E := BeginningOfWeek(D, FFirstDayOfWeek) - 1; S := E - 6; end;
    idrpThisMonth: begin S := StartOfTheMonth(D); E := EndOfTheMonth(D); end;
    idrpLastMonth: begin E := StartOfTheMonth(D) - 1; S := StartOfTheMonth(E); end;
    idrpLast7Days: S := D - 6;
    idrpLast14Days: S := D - 13;
    idrpLast30Days: S := D - 29;
    idrpThisYear: begin S := EncodeDate(YearOf(D), 1, 1); E := EncodeDate(YearOf(D), 12, 31); end;
    idrpLastYear: begin S := EncodeDate(YearOf(D) - 1, 1, 1); E := EncodeDate(YearOf(D) - 1, 12, 31); end;
    idrpCustom: begin
      S := Trunc(FCustomPresetStartDate);
      E := Trunc(FCustomPresetEndDate);
      if E < S then
      begin
        if not FSwapInvalidRange then Exit;
        D := S;
        S := E;
        E := D;
      end;
    end;
  end;
  if (S < FMinDate) or (E > FMaxDate) or
    (not FAllowSingle and (S = E)) then Exit;
  if not PermitPreset(APreset, S, E) then Exit;
  SetRange(S, E);
  if not (FHasStart and FHasEnd) or (FStartDate <> S) or (FEndDate <> E) then Exit;
  NotifyPresetApplied(APreset, S, E);
  if Assigned(FOnPreset) then FOnPreset(Self);
end;

procedure TCustomThemedIdeDateRangePicker.ShowDropDown;
var
  P: TPoint;
  R: TRect;
  LAllow: Boolean;
begin
  if not Enabled or FReadOnly or (Parent = nil) then Exit;
  LAllow := True;
  if Assigned(FOnPopupOpening) then FOnPopupOpening(Self, LAllow);
  if not LAllow then Exit;
  if FPopup = nil then FPopup := TIdeDateRangePopup.CreateForPicker(Self);
  FPopup.Synchronize;
  P := ClientToScreen(Point(0, Height));
  R := Screen.MonitorFromPoint(P).WorkareaRect;
  if P.X + FPopup.Width > R.Right then P.X := R.Right - FPopup.Width;
  if P.X < R.Left then P.X := R.Left;
  if P.Y + FPopup.Height > R.Bottom then P.Y := ClientToScreen(Point(0, 0)).Y - FPopup.Height;
  if P.Y < R.Top then P.Y := R.Top;
  FPopup.SetBounds(P.X, P.Y, FPopup.Width, FPopup.Height);
  FPopup.FClosingNotified := False;
  FPopup.Show;
  FPopup.BringToFront;
  if Assigned(FOnPopupOpened) then FOnPopupOpened(Self);
  if FPopup.Visible and FPopup.FCalendar.CanFocus then
    FPopup.FCalendar.SetFocus;
end;

function TCustomThemedIdeDateRangePicker.HitTestPopup(
  const AScreenPoint: TPoint): TIdeDateRangeHitInfo;
begin
  Result.Kind := idrhkNone;
  Result.Date := 0;
  Result.Index := -1;
  Result.MonthIndex := -1;
  Result.Bounds := Rect(0, 0, 0, 0);
  if (FPopup <> nil) and FPopup.Visible and (FPopup.FCalendar <> nil) then
    Result := FPopup.FCalendar.HitTest(
      FPopup.FCalendar.ScreenToClient(AScreenPoint));
end;

procedure TCustomThemedIdeDateRangePicker.CloseDropDown;
begin
  if FPopup <> nil then FPopup.Hide;
end;

procedure TCustomThemedIdeDateRangePicker.SetDropDownWidth(const V: Integer);
begin
  if FDropDownWidth = Max(0, V) then Exit;
  FDropDownWidth := Max(0, V);
  if FPopup <> nil then FPopup.Synchronize;
end;

procedure TCustomThemedIdeDateRangePicker.SetDropDownHeight(const V: Integer);
begin
  if FDropDownHeight = Max(0, V) then Exit;
  FDropDownHeight := Max(0, V);
  if FPopup <> nil then FPopup.Synchronize;
end;

procedure TCustomThemedIdeDateRangePicker.SetDropDownCornerRadius(const V: Integer);
begin
  if FDropDownCornerRadius = EnsureRange(V, 0, 24) then Exit;
  FDropDownCornerRadius := EnsureRange(V, 0, 24);
  if FPopup <> nil then FPopup.Synchronize;
end;

procedure TCustomThemedIdeDateRangePicker.SetSizeMode(const V: TIdeDateRangeSizeMode);
begin
  if FSizeMode = V then Exit;
  FSizeMode := V;
  if V = idrsmCompact then
  begin
    Width := ScaleValue(260);
    if FDisplayMode = idrmdDetailed then Height := ScaleValue(40)
    else Height := ScaleValue(28);
  end
  else
  begin
    Width := ScaleValue(294);
    if FDisplayMode = idrmdDetailed then Height := ScaleValue(49)
    else Height := ScaleValue(34);
  end;
  if FPopup <> nil then FPopup.Synchronize;
  Invalidate;
end;

procedure TCustomThemedIdeDateRangePicker.SetDisplayMode(const V: TIdeDateRangeDisplayMode);
begin
  if FDisplayMode = V then Exit;
  FDisplayMode := V;
  if V = idrmdDetailed then
    Height := ScaleValue(IfThen(FSizeMode = idrsmCompact, 40, 49))
  else
    Height := ScaleValue(IfThen(FSizeMode = idrsmCompact, 28, 34));
  Invalidate;
end;

procedure TCustomThemedIdeDateRangePicker.SetMonthMode(const V: TIdeDateRangeMonthMode);
begin
  FMonthMode := V;
  if FPopup <> nil then FPopup.Synchronize;
end;

procedure TCustomThemedIdeDateRangePicker.SetSelectionMode(const V: TIdeDateRangeSelectionMode);
begin
  FSelectionMode := V;
  if FPopup <> nil then FPopup.Synchronize;
end;

procedure TCustomThemedIdeDateRangePicker.SetMinDate(const V: TDateTime);
begin
  if V <= FMaxDate then FMinDate := Trunc(V);
end;

procedure TCustomThemedIdeDateRangePicker.SetMaxDate(const V: TDateTime);
begin
  if V >= FMinDate then FMaxDate := Trunc(V);
end;

procedure TCustomThemedIdeDateRangePicker.SetPlaceholder(const V: string);
begin
  FPlaceholder := V;
  Invalidate;
end;

procedure TCustomThemedIdeDateRangePicker.SetDateFormat(const V: string);
begin
  FDateFormat := V;
  Invalidate;
end;

procedure TCustomThemedIdeDateRangePicker.SetSeparator(const V: string);
begin
  FSeparator := V;
  Invalidate;
end;

procedure TCustomThemedIdeDateRangePicker.SetShowPresets(const V: Boolean);
begin
  FShowPresets := V;
  if FPopup <> nil then FPopup.Synchronize;
end;

procedure TCustomThemedIdeDateRangePicker.SetShowFooter(const V: Boolean);
begin
  FShowFooter := V;
  if FPopup <> nil then FPopup.Synchronize;
end;

procedure TCustomThemedIdeDateRangePicker.SetShowWeekNumbers(const V: Boolean);
begin
  FShowWeekNumbers := V;
  if FPopup <> nil then FPopup.Synchronize;
end;

procedure TCustomThemedIdeDateRangePicker.SetDisableWeekends(const V: Boolean);
begin
  FDisableWeekends := V;
  if FPopup <> nil then FPopup.Synchronize;
end;

procedure TCustomThemedIdeDateRangePicker.SetFirstDayOfWeek(const V: Integer);
begin
  if (V < 1) or (V > 7) then Exit;
  FFirstDayOfWeek := V;
  if FPopup <> nil then FPopup.Synchronize;
end;

end.

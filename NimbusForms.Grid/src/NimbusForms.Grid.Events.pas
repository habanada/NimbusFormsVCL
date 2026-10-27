unit NimbusForms.Grid.Events;

{$SCOPEDENUMS ON}

interface

uses
  System.Rtti,
  System.SysUtils,
  System.Types,
  System.UITypes,
  Winapi.GDIPOBJ,
  NimbusForms.Grid.Cell,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.ColumnBand,
  NimbusForms.Grid.FilterDescriptor,
  NimbusForms.Grid.FormatStyle,
  NimbusForms.Grid.HitInfo,
  NimbusForms.Grid.RenderContext,
  NimbusForms.Grid.Row,
  NimbusForms.Grid.Types,
  NimbusForms.Theming.Types;

type
  TThemedGridMouseButtons = set of TMouseButton;

  TThemedGridEventArgs = class
  end;

  TThemedGridCellEventArgs = class(TThemedGridEventArgs)
  private
    FRowIndex: Integer;
    FColumnIndex: Integer;
    FDataSourceIndex: Integer;
    FColumn: TThemedGridColumn;
    FRow: TThemedGridRow;
    FCell: TThemedGridCell;
    FRowObject: TValue;
    FValue: TValue;
    FCellTag: TValue;
    FBounds: TRect;
  public
    property RowIndex: Integer read FRowIndex write FRowIndex;
    property ColumnIndex: Integer read FColumnIndex write FColumnIndex;
    property DataSourceIndex: Integer read FDataSourceIndex write FDataSourceIndex;
    property Column: TThemedGridColumn read FColumn write FColumn;
    property Row: TThemedGridRow read FRow write FRow;
    property Cell: TThemedGridCell read FCell write FCell;
    property RowObject: TValue read FRowObject write FRowObject;
    property Value: TValue read FValue write FValue;
    property CellTag: TValue read FCellTag write FCellTag;
    property Bounds: TRect read FBounds write FBounds;
  end;

  TThemedGridCellMouseEventArgs = class sealed(TThemedGridCellEventArgs)
  private
    FButton: TThemedGridMouseButtons;
    FClicks: Integer;
    FLocation: TPoint;
    FDelta: Integer;
    FHitInfo: TThemedGridHitInfo;
  public
    property Button: TThemedGridMouseButtons read FButton write FButton;
    property Clicks: Integer read FClicks write FClicks;
    property Location: TPoint read FLocation write FLocation;
    property Delta: Integer read FDelta write FDelta;
    property HitInfo: TThemedGridHitInfo read FHitInfo write FHitInfo;
  end;

  TThemedGridCellFormattingEventArgs = class sealed(TThemedGridCellEventArgs)
  private
    FDisplayText: string;
    FDisplayValue: TValue;
    FFormatString: string;
    FFormatProvider: TFormatSettings;
    FHasFormatProvider: Boolean;
    FHandled: Boolean;
    procedure SetFormatProvider(const AValue: TFormatSettings);
  public
    property DisplayText: string read FDisplayText write FDisplayText;
    property DisplayValue: TValue read FDisplayValue write FDisplayValue;
    property FormatString: string read FFormatString write FFormatString;
    property FormatProvider: TFormatSettings read FFormatProvider write SetFormatProvider;
    property HasFormatProvider: Boolean read FHasFormatProvider;
    property Handled: Boolean read FHandled write FHandled;
  end;

  TThemedGridCellPaintingEventArgs = class sealed(TThemedGridCellEventArgs)
  private
    FGraphics: TGPGraphics;
    FState: TThemedGridCellState;
    FHandled: Boolean;
  public
    property Graphics: TGPGraphics read FGraphics write FGraphics;
    property State: TThemedGridCellState read FState write FState;
    property Handled: Boolean read FHandled write FHandled;
  end;

  TThemedGridCellStyleEventArgs = class sealed(TThemedGridCellEventArgs)
  private
    FCurrentBackColor: TThemeColor;
    FCurrentForeColor: TThemeColor;
    FStyle: TThemedGridFormatStyle;
    FOwnedStyle: TThemedGridFormatStyle;
    procedure SetStyle(const AValue: TThemedGridFormatStyle);
    function GetHasStyle: Boolean;
  public
    destructor Destroy; override;
    procedure EnsureStyle;
    function DetachStyle: TThemedGridFormatStyle;
    property CurrentBackColor: TThemeColor read FCurrentBackColor write FCurrentBackColor;
    property CurrentForeColor: TThemeColor read FCurrentForeColor write FCurrentForeColor;
    property Style: TThemedGridFormatStyle read FStyle write SetStyle;
    property HasStyle: Boolean read GetHasStyle;
  end;

  TThemedGridRowStyleEventArgs = class sealed(TThemedGridEventArgs)
  private
    FRowIndex: Integer;
    FDataSourceIndex: Integer;
    FRow: TThemedGridRow;
    FRowObject: TValue;
    FBounds: TRect;
    FCurrentBackColor: TThemeColor;
    FCurrentForeColor: TThemeColor;
    FStyle: TThemedGridFormatStyle;
    FOwnedStyle: TThemedGridFormatStyle;
    procedure SetStyle(const AValue: TThemedGridFormatStyle);
    function GetHasStyle: Boolean;
  public
    destructor Destroy; override;
    procedure EnsureStyle;
    function DetachStyle: TThemedGridFormatStyle;
    property RowIndex: Integer read FRowIndex write FRowIndex;
    property DataSourceIndex: Integer read FDataSourceIndex write FDataSourceIndex;
    property Row: TThemedGridRow read FRow write FRow;
    property RowObject: TValue read FRowObject write FRowObject;
    property Bounds: TRect read FBounds write FBounds;
    property CurrentBackColor: TThemeColor read FCurrentBackColor write FCurrentBackColor;
    property CurrentForeColor: TThemeColor read FCurrentForeColor write FCurrentForeColor;
    property Style: TThemedGridFormatStyle read FStyle write SetStyle;
    property HasStyle: Boolean read GetHasStyle;
  end;

  TThemedGridSelectionStyleEventArgs = class sealed(TThemedGridCellEventArgs)
  private
    FCurrentBackColor: TThemeColor;
    FCurrentForeColor: TThemeColor;
    FSelectionBackColor: TThemeColor;
    FSelectionForeColor: TThemeColor;
    FHoverBackColor: TThemeColor;
    FHoverForeColor: TThemeColor;
    FCurrentBorderColor: TThemeColor;
    FSelected: Boolean;
    FHovered: Boolean;
    FCurrent: Boolean;
    FStyle: TThemedGridFormatStyle;
    FOwnedStyle: TThemedGridFormatStyle;
    procedure SetStyle(const AValue: TThemedGridFormatStyle);
    function GetHasStyle: Boolean;
  public
    destructor Destroy; override;
    procedure EnsureStyle;
    function DetachStyle: TThemedGridFormatStyle;
    procedure Apply;
    property CurrentBackColor: TThemeColor read FCurrentBackColor write FCurrentBackColor;
    property CurrentForeColor: TThemeColor read FCurrentForeColor write FCurrentForeColor;
    property SelectionBackColor: TThemeColor read FSelectionBackColor write FSelectionBackColor;
    property SelectionForeColor: TThemeColor read FSelectionForeColor write FSelectionForeColor;
    property HoverBackColor: TThemeColor read FHoverBackColor write FHoverBackColor;
    property HoverForeColor: TThemeColor read FHoverForeColor write FHoverForeColor;
    property CurrentBorderColor: TThemeColor read FCurrentBorderColor write FCurrentBorderColor;
    property Selected: Boolean read FSelected write FSelected;
    property Hovered: Boolean read FHovered write FHovered;
    property Current: Boolean read FCurrent write FCurrent;
    property Style: TThemedGridFormatStyle read FStyle write SetStyle;
    property HasStyle: Boolean read GetHasStyle;
  end;

  TThemedGridCurrentCellChangedEventArgs = class sealed(TThemedGridEventArgs)
  private
    FOldCell: TThemedGridCell;
    FNewCell: TThemedGridCell;
  public
    constructor Create(const AOldCell: TThemedGridCell; const ANewCell: TThemedGridCell);
    property OldCell: TThemedGridCell read FOldCell;
    property NewCell: TThemedGridCell read FNewCell;
  end;

  TThemedGridColumnEventArgs = class(TThemedGridEventArgs)
  private
    FColumn: TThemedGridColumn;
    FColumnIndex: Integer;
  public
    constructor Create(const AColumn: TThemedGridColumn; const AColumnIndex: Integer);
    property Column: TThemedGridColumn read FColumn;
    property ColumnIndex: Integer read FColumnIndex;
  end;

  TThemedGridColumnWidthChangedEventArgs = class sealed(TThemedGridColumnEventArgs)
  private
    FOldWidth: Integer;
    FNewWidth: Integer;
  public
    constructor Create(const AColumn: TThemedGridColumn; const AColumnIndex: Integer; const AOldWidth: Integer; const ANewWidth: Integer);
    property OldWidth: Integer read FOldWidth;
    property NewWidth: Integer read FNewWidth;
  end;

  TThemedGridColumnDisplayIndexChangedEventArgs = class sealed(TThemedGridColumnEventArgs)
  private
    FOldDisplayIndex: Integer;
    FNewDisplayIndex: Integer;
  public
    constructor Create(const AColumn: TThemedGridColumn; const AColumnIndex: Integer; const AOldDisplayIndex: Integer; const ANewDisplayIndex: Integer);
    property OldDisplayIndex: Integer read FOldDisplayIndex;
    property NewDisplayIndex: Integer read FNewDisplayIndex;
  end;

  TThemedGridColumnVisibleChangedEventArgs = class sealed(TThemedGridColumnEventArgs)
  private
    FVisible: Boolean;
  public
    constructor Create(const AColumn: TThemedGridColumn; const AColumnIndex: Integer; const AVisible: Boolean);
    property Visible: Boolean read FVisible;
  end;

  TThemedGridColumnBandEventArgs = class sealed(TThemedGridEventArgs)
  private
    FBand: TThemedGridColumnBand;
    FBandName: string;
    FBounds: TRect;
  public
    constructor Create(const ABand: TThemedGridColumnBand; const ABandName: string; const ABounds: TRect);
    property Band: TThemedGridColumnBand read FBand;
    property BandName: string read FBandName;
    property Bounds: TRect read FBounds;
  end;

  TThemedGridColumnSortRequestedEventArgs = class sealed(TThemedGridColumnEventArgs)
  private
    FDirection: TThemedGridSortDirection;
  public
    constructor Create(const AColumn: TThemedGridColumn; const AColumnIndex: Integer; const ADirection: TThemedGridSortDirection);
    property Direction: TThemedGridSortDirection read FDirection;
  end;

  TThemedGridColumnFilterEventArgs = class sealed(TThemedGridColumnEventArgs)
  private
    FFilter: TThemedGridFilterDescriptor;
    FCancel: Boolean;
  public
    constructor Create(const AColumn: TThemedGridColumn; const AColumnIndex: Integer; const AFilter: TThemedGridFilterDescriptor);
    property Filter: TThemedGridFilterDescriptor read FFilter write FFilter;
    property Cancel: Boolean read FCancel write FCancel;
  end;

  TThemedGridFilterChangedEventArgs = class sealed(TThemedGridEventArgs)
  private
    FFilterCount: Integer;
    FRowCount: Integer;
  public
    constructor Create(const AFilterCount: Integer; const ARowCount: Integer);
    property FilterCount: Integer read FFilterCount;
    property RowCount: Integer read FRowCount;
  end;

  TThemedGridDetailRowEventArgs = class sealed(TThemedGridEventArgs)
  private
    FViewRowIndex: Integer;
    FParentViewRowIndex: Integer;
    FParentDataSourceIndex: Integer;
    FParentRowObject: TValue;
    FBounds: TRect;
    FDetailText: string;
    FButton: TThemedGridMouseButtons;
    FClicks: Integer;
    FLocation: TPoint;
    FDelta: Integer;
    FHitInfo: TThemedGridHitInfo;
    FHandled: Boolean;
  public
    property ViewRowIndex: Integer read FViewRowIndex write FViewRowIndex;
    property ParentViewRowIndex: Integer read FParentViewRowIndex write FParentViewRowIndex;
    property ParentDataSourceIndex: Integer read FParentDataSourceIndex write FParentDataSourceIndex;
    property ParentRowObject: TValue read FParentRowObject write FParentRowObject;
    property Bounds: TRect read FBounds write FBounds;
    property DetailText: string read FDetailText write FDetailText;
    property Button: TThemedGridMouseButtons read FButton write FButton;
    property Clicks: Integer read FClicks write FClicks;
    property Location: TPoint read FLocation write FLocation;
    property Delta: Integer read FDelta write FDelta;
    property HitInfo: TThemedGridHitInfo read FHitInfo write FHitInfo;
    property Handled: Boolean read FHandled write FHandled;
  end;

  TThemedGridDetailRowHeightNeededEventArgs = class sealed(TThemedGridEventArgs)
  private
    FViewRowIndex: Integer;
    FParentDataSourceIndex: Integer;
    FParentRowObject: TValue;
    FHeight: Integer;
    FMinimumHeight: Integer;
    FMaximumHeight: Integer;
  public
    property ViewRowIndex: Integer read FViewRowIndex write FViewRowIndex;
    property ParentDataSourceIndex: Integer read FParentDataSourceIndex write FParentDataSourceIndex;
    property ParentRowObject: TValue read FParentRowObject write FParentRowObject;
    property Height: Integer read FHeight write FHeight;
    property MinimumHeight: Integer read FMinimumHeight write FMinimumHeight;
    property MaximumHeight: Integer read FMaximumHeight write FMaximumHeight;
  end;

  TThemedGridDetailRowTextNeededEventArgs = class sealed(TThemedGridEventArgs)
  private
    FViewRowIndex: Integer;
    FParentDataSourceIndex: Integer;
    FParentRowObject: TValue;
    FDetailText: string;
  public
    property ViewRowIndex: Integer read FViewRowIndex write FViewRowIndex;
    property ParentDataSourceIndex: Integer read FParentDataSourceIndex write FParentDataSourceIndex;
    property ParentRowObject: TValue read FParentRowObject write FParentRowObject;
    property DetailText: string read FDetailText write FDetailText;
  end;

  TThemedGridDetailRowPaintEventArgs = class sealed(TThemedGridEventArgs)
  private
    FGraphics: TGPGraphics;
    FRenderContext: TThemedGridRenderContext;
    FViewRowIndex: Integer;
    FParentDataSourceIndex: Integer;
    FParentRowObject: TValue;
    FBounds: TRect;
    FContentBounds: TRect;
    FDetailText: string;
    FFocused: Boolean;
    FHandled: Boolean;
  public
    property Graphics: TGPGraphics read FGraphics write FGraphics;
    property RenderContext: TThemedGridRenderContext read FRenderContext write FRenderContext;
    property ViewRowIndex: Integer read FViewRowIndex write FViewRowIndex;
    property ParentDataSourceIndex: Integer read FParentDataSourceIndex write FParentDataSourceIndex;
    property ParentRowObject: TValue read FParentRowObject write FParentRowObject;
    property Bounds: TRect read FBounds write FBounds;
    property ContentBounds: TRect read FContentBounds write FContentBounds;
    property DetailText: string read FDetailText write FDetailText;
    property Focused: Boolean read FFocused write FFocused;
    property Handled: Boolean read FHandled write FHandled;
  end;

  TThemedGridSummaryCustomEventArgs = class sealed(TThemedGridEventArgs)
  private
    FColumn: TThemedGridColumn;
    FSummaryType: TThemedGridSummaryType;
    FValue: TValue;
    FDisplayText: string;
    FHandled: Boolean;
  public
    property Column: TThemedGridColumn read FColumn write FColumn;
    property SummaryType: TThemedGridSummaryType read FSummaryType write FSummaryType;
    property Value: TValue read FValue write FValue;
    property DisplayText: string read FDisplayText write FDisplayText;
    property Handled: Boolean read FHandled write FHandled;
  end;

  TThemedGridSummaryCellEventArgs = class sealed(TThemedGridEventArgs)
  private
    FColumnIndex: Integer;
    FColumn: TThemedGridColumn;
    FBounds: TRect;
    FText: string;
  public
    property ColumnIndex: Integer read FColumnIndex write FColumnIndex;
    property Column: TThemedGridColumn read FColumn write FColumn;
    property Bounds: TRect read FBounds write FBounds;
    property Text: string read FText write FText;
  end;

  TThemedGridDataSourceChangingEventArgs = class sealed(TThemedGridEventArgs)
  private
    FOldDataSource: TValue;
    FNewDataSource: TValue;
    FCancel: Boolean;
  public
    constructor Create(const AOldDataSource: TValue; const ANewDataSource: TValue);
    property OldDataSource: TValue read FOldDataSource;
    property NewDataSource: TValue read FNewDataSource;
    property Cancel: Boolean read FCancel write FCancel;
  end;

  TThemedGridDataSourceChangedEventArgs = class sealed(TThemedGridEventArgs)
  private
    FOldDataSource: TValue;
    FNewDataSource: TValue;
  public
    constructor Create(const AOldDataSource: TValue; const ANewDataSource: TValue);
    property OldDataSource: TValue read FOldDataSource;
    property NewDataSource: TValue read FNewDataSource;
  end;

  TThemedGridRowsChangedEventArgs = class sealed(TThemedGridEventArgs)
  private
    FRowCount: Integer;
    FDataVersion: Integer;
  public
    constructor Create(const ARowCount: Integer; const ADataVersion: Integer);
    property RowCount: Integer read FRowCount;
    property DataVersion: Integer read FDataVersion;
  end;

  TThemedGridSearchTextChangedEventArgs = class sealed(TThemedGridEventArgs)
  private
    FOldText: string;
    FNewText: string;
  public
    constructor Create(const AOldText: string; const ANewText: string);
    property OldText: string read FOldText;
    property NewText: string read FNewText;
  end;

  TThemedGridSearchCompletedEventArgs = class sealed(TThemedGridEventArgs)
  private
    FText: string;
    FResultCount: Integer;
  public
    constructor Create(const AText: string; const AResultCount: Integer);
    property Text: string read FText;
    property ResultCount: Integer read FResultCount;
  end;

  TThemedGridCellContentClickEventArgs = class sealed(TThemedGridCellEventArgs)
  private
    FLocation: TPoint;
    FHitInfo: TThemedGridHitInfo;
  public
    property Location: TPoint read FLocation write FLocation;
    property HitInfo: TThemedGridHitInfo read FHitInfo write FHitInfo;
  end;

  TThemedGridCellValidatingEventArgs = class sealed(TThemedGridCellEventArgs)
  private
    FNewValue: TValue;
    FErrorText: string;
    FCancel: Boolean;
  public
    property NewValue: TValue read FNewValue write FNewValue;
    property ErrorText: string read FErrorText write FErrorText;
    property Cancel: Boolean read FCancel write FCancel;
  end;

  TThemedGridCellValueChangingEventArgs = class sealed(TThemedGridCellEventArgs)
  private
    FOldValue: TValue;
    FNewValue: TValue;
    FChangeReason: string;
    FErrorText: string;
    FCancel: Boolean;
  public
    property OldValue: TValue read FOldValue write FOldValue;
    property NewValue: TValue read FNewValue write FNewValue;
    property ChangeReason: string read FChangeReason write FChangeReason;
    property ErrorText: string read FErrorText write FErrorText;
    property Cancel: Boolean read FCancel write FCancel;
  end;

  TThemedGridCellValueChangedEventArgs = class sealed(TThemedGridCellEventArgs)
  private
    FOldValue: TValue;
    FNewValue: TValue;
    FChangeReason: string;
  public
    property OldValue: TValue read FOldValue write FOldValue;
    property NewValue: TValue read FNewValue write FNewValue;
    property ChangeReason: string read FChangeReason write FChangeReason;
  end;

  TThemedGridCellToolTipNeededEventArgs = class sealed(TThemedGridCellEventArgs)
  private
    FToolTipText: string;
    FIsMarkup: Boolean;
  public
    property ToolTipText: string read FToolTipText write FToolTipText;
    property IsMarkup: Boolean read FIsMarkup write FIsMarkup;
  end;

  TThemedGridCellEditEventArgs = class sealed(TThemedGridCellEventArgs)
  private
    FOldValue: TValue;
    FNewValue: TValue;
  public
    property OldValue: TValue read FOldValue write FOldValue;
    property NewValue: TValue read FNewValue write FNewValue;
  end;

  TThemedGridCellEvent = procedure(ASender: TObject; const AArgs: TThemedGridCellEventArgs) of object;
  TThemedGridCellMouseEvent = procedure(ASender: TObject; const AArgs: TThemedGridCellMouseEventArgs) of object;
  TThemedGridCellFormattingEvent = procedure(ASender: TObject; const AArgs: TThemedGridCellFormattingEventArgs) of object;
  TThemedGridCellPaintingEvent = procedure(ASender: TObject; const AArgs: TThemedGridCellPaintingEventArgs) of object;
  TThemedGridCellStyleEvent = procedure(ASender: TObject; const AArgs: TThemedGridCellStyleEventArgs) of object;
  TThemedGridRowStyleEvent = procedure(ASender: TObject; const AArgs: TThemedGridRowStyleEventArgs) of object;
  TThemedGridSelectionStyleEvent = procedure(ASender: TObject; const AArgs: TThemedGridSelectionStyleEventArgs) of object;
  TThemedGridCurrentCellChangedEvent = procedure(ASender: TObject; const AArgs: TThemedGridCurrentCellChangedEventArgs) of object;
  TThemedGridColumnEvent = procedure(ASender: TObject; const AArgs: TThemedGridColumnEventArgs) of object;
  TThemedGridColumnWidthChangedEvent = procedure(ASender: TObject; const AArgs: TThemedGridColumnWidthChangedEventArgs) of object;
  TThemedGridColumnDisplayIndexChangedEvent = procedure(ASender: TObject; const AArgs: TThemedGridColumnDisplayIndexChangedEventArgs) of object;
  TThemedGridColumnVisibleChangedEvent = procedure(ASender: TObject; const AArgs: TThemedGridColumnVisibleChangedEventArgs) of object;
  TThemedGridColumnBandEvent = procedure(ASender: TObject; const AArgs: TThemedGridColumnBandEventArgs) of object;
  TThemedGridColumnSortRequestedEvent = procedure(ASender: TObject; const AArgs: TThemedGridColumnSortRequestedEventArgs) of object;
  TThemedGridColumnFilterEvent = procedure(ASender: TObject; const AArgs: TThemedGridColumnFilterEventArgs) of object;
  TThemedGridFilterChangedEvent = procedure(ASender: TObject; const AArgs: TThemedGridFilterChangedEventArgs) of object;
  TThemedGridDetailRowEvent = procedure(ASender: TObject; const AArgs: TThemedGridDetailRowEventArgs) of object;
  TThemedGridDetailRowHeightNeededEvent = procedure(ASender: TObject; const AArgs: TThemedGridDetailRowHeightNeededEventArgs) of object;
  TThemedGridDetailRowTextNeededEvent = procedure(ASender: TObject; const AArgs: TThemedGridDetailRowTextNeededEventArgs) of object;
  TThemedGridDetailRowPaintEvent = procedure(ASender: TObject; const AArgs: TThemedGridDetailRowPaintEventArgs) of object;
  TThemedGridSummaryCustomEvent = procedure(ASender: TObject; const AArgs: TThemedGridSummaryCustomEventArgs) of object;
  TThemedGridSummaryCellEvent = procedure(ASender: TObject; const AArgs: TThemedGridSummaryCellEventArgs) of object;
  TThemedGridDataSourceChangingEvent = procedure(ASender: TObject; const AArgs: TThemedGridDataSourceChangingEventArgs) of object;
  TThemedGridDataSourceChangedEvent = procedure(ASender: TObject; const AArgs: TThemedGridDataSourceChangedEventArgs) of object;
  TThemedGridRowsChangedEvent = procedure(ASender: TObject; const AArgs: TThemedGridRowsChangedEventArgs) of object;
  TThemedGridSearchTextChangedEvent = procedure(ASender: TObject; const AArgs: TThemedGridSearchTextChangedEventArgs) of object;
  TThemedGridSearchCompletedEvent = procedure(ASender: TObject; const AArgs: TThemedGridSearchCompletedEventArgs) of object;
  TThemedGridCellContentClickEvent = procedure(ASender: TObject; const AArgs: TThemedGridCellContentClickEventArgs) of object;
  TThemedGridCellValidatingEvent = procedure(ASender: TObject; const AArgs: TThemedGridCellValidatingEventArgs) of object;
  TThemedGridCellValueChangingEvent = procedure(ASender: TObject; const AArgs: TThemedGridCellValueChangingEventArgs) of object;
  TThemedGridCellValueChangedEvent = procedure(ASender: TObject; const AArgs: TThemedGridCellValueChangedEventArgs) of object;
  TThemedGridCellToolTipNeededEvent = procedure(ASender: TObject; const AArgs: TThemedGridCellToolTipNeededEventArgs) of object;
  TThemedGridCellEditEvent = procedure(ASender: TObject; const AArgs: TThemedGridCellEditEventArgs) of object;

implementation

procedure TThemedGridCellFormattingEventArgs.SetFormatProvider(const AValue: TFormatSettings);
begin
  FFormatProvider := AValue;
  FHasFormatProvider := True;
end;

destructor TThemedGridCellStyleEventArgs.Destroy;
begin
  FOwnedStyle.Free;
  inherited Destroy;
end;

procedure TThemedGridCellStyleEventArgs.SetStyle(const AValue: TThemedGridFormatStyle);
begin
  if FStyle = AValue then
    Exit;
  if (FOwnedStyle <> nil) and (FOwnedStyle <> AValue) then
  begin
    FOwnedStyle.Free;
    FOwnedStyle := nil;
  end;
  FStyle := AValue;
end;

function TThemedGridCellStyleEventArgs.GetHasStyle: Boolean;
begin
  Result := FStyle <> nil;
end;

procedure TThemedGridCellStyleEventArgs.EnsureStyle;
begin
  if FStyle = nil then
  begin
    FOwnedStyle := TThemedGridFormatStyle.Create;
    FStyle := FOwnedStyle;
  end;
end;

function TThemedGridCellStyleEventArgs.DetachStyle: TThemedGridFormatStyle;
begin
  Result := FOwnedStyle;
  FOwnedStyle := nil;
end;

destructor TThemedGridRowStyleEventArgs.Destroy;
begin
  FOwnedStyle.Free;
  inherited Destroy;
end;

procedure TThemedGridRowStyleEventArgs.SetStyle(const AValue: TThemedGridFormatStyle);
begin
  if FStyle = AValue then
    Exit;
  if (FOwnedStyle <> nil) and (FOwnedStyle <> AValue) then
  begin
    FOwnedStyle.Free;
    FOwnedStyle := nil;
  end;
  FStyle := AValue;
end;

function TThemedGridRowStyleEventArgs.GetHasStyle: Boolean;
begin
  Result := FStyle <> nil;
end;

procedure TThemedGridRowStyleEventArgs.EnsureStyle;
begin
  if FStyle = nil then
  begin
    FOwnedStyle := TThemedGridFormatStyle.Create;
    FStyle := FOwnedStyle;
  end;
end;

function TThemedGridRowStyleEventArgs.DetachStyle: TThemedGridFormatStyle;
begin
  Result := FOwnedStyle;
  FOwnedStyle := nil;
end;

destructor TThemedGridSelectionStyleEventArgs.Destroy;
begin
  FOwnedStyle.Free;
  inherited Destroy;
end;

procedure TThemedGridSelectionStyleEventArgs.SetStyle(const AValue: TThemedGridFormatStyle);
begin
  if FStyle = AValue then
    Exit;
  if (FOwnedStyle <> nil) and (FOwnedStyle <> AValue) then
  begin
    FOwnedStyle.Free;
    FOwnedStyle := nil;
  end;
  FStyle := AValue;
end;

function TThemedGridSelectionStyleEventArgs.GetHasStyle: Boolean;
begin
  Result := FStyle <> nil;
end;

procedure TThemedGridSelectionStyleEventArgs.EnsureStyle;
begin
  if FStyle = nil then
  begin
    FOwnedStyle := TThemedGridFormatStyle.Create;
    FStyle := FOwnedStyle;
  end;
end;

function TThemedGridSelectionStyleEventArgs.DetachStyle: TThemedGridFormatStyle;
begin
  Result := FOwnedStyle;
  FOwnedStyle := nil;
end;

procedure TThemedGridSelectionStyleEventArgs.Apply;
begin
  EnsureStyle;
  if FSelected then
  begin
    FStyle.SelectionBackColor := FSelectionBackColor;
    FStyle.SelectionForeColor := FSelectionForeColor;
  end;
  if FHovered then
  begin
    FStyle.HoverBackColor := FHoverBackColor;
    FStyle.HoverForeColor := FHoverForeColor;
  end;
  if FCurrent then
    FStyle.CurrentBorderColor := FCurrentBorderColor;
end;

constructor TThemedGridCurrentCellChangedEventArgs.Create(const AOldCell: TThemedGridCell; const ANewCell: TThemedGridCell);
begin
  inherited Create;
  FOldCell := AOldCell;
  FNewCell := ANewCell;
end;

constructor TThemedGridColumnEventArgs.Create(const AColumn: TThemedGridColumn; const AColumnIndex: Integer);
begin
  inherited Create;
  FColumn := AColumn;
  FColumnIndex := AColumnIndex;
end;

constructor TThemedGridColumnWidthChangedEventArgs.Create(const AColumn: TThemedGridColumn; const AColumnIndex: Integer; const AOldWidth: Integer; const ANewWidth: Integer);
begin
  inherited Create(AColumn, AColumnIndex);
  FOldWidth := AOldWidth;
  FNewWidth := ANewWidth;
end;

constructor TThemedGridColumnDisplayIndexChangedEventArgs.Create(const AColumn: TThemedGridColumn; const AColumnIndex: Integer; const AOldDisplayIndex: Integer; const ANewDisplayIndex: Integer);
begin
  inherited Create(AColumn, AColumnIndex);
  FOldDisplayIndex := AOldDisplayIndex;
  FNewDisplayIndex := ANewDisplayIndex;
end;

constructor TThemedGridColumnVisibleChangedEventArgs.Create(const AColumn: TThemedGridColumn; const AColumnIndex: Integer; const AVisible: Boolean);
begin
  inherited Create(AColumn, AColumnIndex);
  FVisible := AVisible;
end;

constructor TThemedGridColumnBandEventArgs.Create(const ABand: TThemedGridColumnBand; const ABandName: string; const ABounds: TRect);
begin
  inherited Create;
  FBand := ABand;
  FBandName := ABandName;
  FBounds := ABounds;
end;

constructor TThemedGridColumnSortRequestedEventArgs.Create(const AColumn: TThemedGridColumn; const AColumnIndex: Integer; const ADirection: TThemedGridSortDirection);
begin
  inherited Create(AColumn, AColumnIndex);
  FDirection := ADirection;
end;

constructor TThemedGridColumnFilterEventArgs.Create(const AColumn: TThemedGridColumn; const AColumnIndex: Integer; const AFilter: TThemedGridFilterDescriptor);
begin
  inherited Create(AColumn, AColumnIndex);
  FFilter := AFilter;
end;

constructor TThemedGridFilterChangedEventArgs.Create(const AFilterCount: Integer; const ARowCount: Integer);
begin
  inherited Create;
  FFilterCount := AFilterCount;
  FRowCount := ARowCount;
end;

constructor TThemedGridDataSourceChangingEventArgs.Create(const AOldDataSource: TValue; const ANewDataSource: TValue);
begin
  inherited Create;
  FOldDataSource := AOldDataSource;
  FNewDataSource := ANewDataSource;
end;

constructor TThemedGridDataSourceChangedEventArgs.Create(const AOldDataSource: TValue; const ANewDataSource: TValue);
begin
  inherited Create;
  FOldDataSource := AOldDataSource;
  FNewDataSource := ANewDataSource;
end;

constructor TThemedGridRowsChangedEventArgs.Create(const ARowCount: Integer; const ADataVersion: Integer);
begin
  inherited Create;
  FRowCount := ARowCount;
  FDataVersion := ADataVersion;
end;

constructor TThemedGridSearchTextChangedEventArgs.Create(const AOldText: string; const ANewText: string);
begin
  inherited Create;
  FOldText := AOldText;
  FNewText := ANewText;
end;

constructor TThemedGridSearchCompletedEventArgs.Create(const AText: string; const AResultCount: Integer);
begin
  inherited Create;
  FText := AText;
  FResultCount := AResultCount;
end;

end.

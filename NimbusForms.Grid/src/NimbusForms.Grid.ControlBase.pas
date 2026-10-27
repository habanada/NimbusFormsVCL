unit NimbusForms.Grid.ControlBase;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.SysUtils,
  System.Types,
  System.Rtti,
  System.TypInfo,
  System.Generics.Collections,
  System.Generics.Defaults,
  Vcl.Controls,
  Vcl.Graphics,
  NimbusForms.Theming.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Primitives,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.ColumnCollection,
  NimbusForms.Grid.ColumnBandCollection,
  NimbusForms.Grid.CellMetadata,
  NimbusForms.Grid.RenderMetrics,
  NimbusForms.Grid.Renderer,
  NimbusForms.Grid.ViewRow,
  NimbusForms.Grid.RowView,
  NimbusForms.Grid.RowList,
  NimbusForms.Grid.StringSet,
  NimbusForms.Grid.GroupDescriptor,
  NimbusForms.Grid.GroupDescriptorCollection,
  NimbusForms.Grid.GroupingOptions,
  NimbusForms.Grid.DetailOptions,
  NimbusForms.Grid.SelectionModel,
  NimbusForms.Grid.SelectionOptions,
  NimbusForms.Grid.ClipboardOptions,
  NimbusForms.Grid.EditOptions,
  NimbusForms.Grid.SearchOptions,
  NimbusForms.Grid.FormatStyle,
  NimbusForms.Grid.FormatCondition,
  NimbusForms.Grid.FormatConditionCollection,
  NimbusForms.Grid.FormatConditionEvents,
  NimbusForms.Grid.DataControllerIntf,
  NimbusForms.Grid.Events;

type
  TThemedGridControlBase = class(TCustomControl, IThemeAware)
  private
    FColumns: TThemedGridColumnCollection;
    FColumnBands: TThemedGridColumnBandCollection;
    FVisibleColumns: TList<TThemedGridColumn>;
    FVisibleColumnsDirty: Boolean;
    FCellMetadata: TObjectDictionary<TThemedGridCellKey, TThemedGridCellMetadata>;
    FRenderer: TThemedGridRenderer;
    FMetrics: TThemedGridRenderMetrics;
    FRowView: TThemedGridRowView;
    FGroups: TThemedGridGroupDescriptorCollection;
    FGroupingOptions: TThemedGridGroupingOptions;
    FCollapsedGroupKeys: TThemedGridStringSet;
    FDetailOptions: TThemedGridDetailOptions;
    FExpandedDetailKeys: TThemedGridStringSet;
    FSelectionModel: TThemedGridSelectionModel;
    FClipboardOptions: TThemedGridClipboardOptions;
    FEditOptions: TThemedGridEditOptions;
    FSelectionOptions: TThemedGridSelectionOptions;
    FSearchOptions: TThemedGridSearchOptions;
    FFormatConditions: TThemedGridFormatConditionCollection;
    FColumnWidthCache: TDictionary<TThemedGridColumn, Integer>;
    FPalette: TThemePalette;
    FDataController: IThemedGridDataController;
    FDataSource: TValue;
    FDataVersion: Integer;
    FRowViewDataVersion: Integer;
    FRowViewDataRowCount: Integer;
    FAutoGenerateColumns: Boolean;
    FShowColumnHeaders: Boolean;
    FShowColumnBandHeaders: Boolean;
    FColumnBandHeaderHeight: Integer;
    FShowRowHeaders: Boolean;
    FShowVerticalScrollBar: Boolean;
    FShowHorizontalScrollBar: Boolean;
    FAllowColumnResize: Boolean;
    FAllowColumnReorder: Boolean;
    FAllowColumnSort: Boolean;
    FShowSummaryFooter: Boolean;
    FSummaryFooterHeight: Integer;
    FSelectionMode: TThemedGridSelectionMode;
    FFirstVisibleRowIndex: Integer;
    FHorizontalOffset: Integer;
    FCurrentRowIndex: Integer;
    FCurrentColumnIndex: Integer;
    FHoverRowIndex: Integer;
    FHoverColumnIndex: Integer;
    FPressedRowIndex: Integer;
    FPressedColumnIndex: Integer;
    FPressedContent: Boolean;
    FAutoSizePending: Boolean;
    FUpdatingAutoSize: Boolean;
    FHeaderBounds: TRect;
    FRowHeaderBounds: TRect;
    FDataBounds: TRect;
    FVerticalScrollBarBounds: TRect;
    FHorizontalScrollBarBounds: TRect;
    FScrollCornerBounds: TRect;
    FSummaryFooterBounds: TRect;
    FVerticalScrollThumbBounds: TRect;
    FHorizontalScrollThumbBounds: TRect;
    FVerticalScrollVisible: Boolean;
    FHorizontalScrollVisible: Boolean;
    FRowTopCacheVersion: Integer;
    FRowTopCacheRowCount: Integer;
    FRowTopCacheBaseHeight: Integer;
    FRowTopCacheTotalHeight: Integer;
    FOnCellFormatting: TThemedGridCellFormattingEvent;
    FOnCellPainting: TThemedGridCellPaintingEvent;
    FOnRowStyleNeeded: TThemedGridRowStyleEvent;
    FOnCellStyleNeeded: TThemedGridCellStyleEvent;
    FOnSelectionStyleNeeded: TThemedGridSelectionStyleEvent;
    FOnDataSourceChanging: TThemedGridDataSourceChangingEvent;
    FOnDataSourceChanged: TThemedGridDataSourceChangedEvent;
    FOnRowsChanged: TThemedGridRowsChangedEvent;
    FOnColumnWidthChanged: TThemedGridColumnWidthChangedEvent;
    FOnConditionalFormattingChanged: TThemedGridFormatConditionChangedEvent;
    procedure SetAutoGenerateColumns(const AValue: Boolean);
    procedure SetDataSource(const AValue: TValue);
    function GetDataVersion: Integer;
    function GetRowCount: Integer;
    function GetRowHeight: Integer;
    procedure SetRowHeight(const AValue: Integer);
    function GetHeaderHeight: Integer;
    procedure SetHeaderHeight(const AValue: Integer);
    function GetRowHeaderWidth: Integer;
    procedure SetRowHeaderWidth(const AValue: Integer);
    procedure SetShowColumnHeaders(const AValue: Boolean);
    procedure SetShowColumnBandHeaders(const AValue: Boolean);
    procedure SetColumnBandHeaderHeight(const AValue: Integer);
    procedure SetShowRowHeaders(const AValue: Boolean);
    procedure SetShowVerticalScrollBar(const AValue: Boolean);
    procedure SetShowHorizontalScrollBar(const AValue: Boolean);
    procedure SetAllowColumnResize(const AValue: Boolean);
    procedure SetAllowColumnReorder(const AValue: Boolean);
    procedure SetAllowColumnSort(const AValue: Boolean);
    procedure SetShowSummaryFooter(const AValue: Boolean);
    procedure SetSummaryFooterHeight(const AValue: Integer);
    procedure SetSelectionMode(const AValue: TThemedGridSelectionMode);
    function GetIsGrouped: Boolean;
    function GetHasFormatConditions: Boolean;
    function GetHasEnabledFormatConditions: Boolean;
    function GetFormatConditionsEnabled: Boolean;
    procedure SetFormatConditionsEnabled(const AValue: Boolean);
    procedure ColumnsChanged(ASender: TObject);
    procedure ColumnBandsChanged(ASender: TObject);
    procedure SelectionModelChanged(ASender: TObject);
    procedure OptionsChanged(ASender: TObject);
    procedure GroupsChanged(ASender: TObject);
    procedure GroupingOptionsChanged(ASender: TObject);
    procedure FormatConditionsChanged(ASender: TObject; const AArgs: TThemedGridFormatConditionChangedEventArgs);
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure RebuildVisibleColumns;
  protected
    procedure ApplyTheme(const APalette: TThemePalette); virtual;
    procedure DoDataSourceChanging(const AArgs: TThemedGridDataSourceChangingEventArgs); virtual;
    procedure DoDataSourceChanged(const AOld, ANew: TValue); virtual;
    procedure DoRowsChanged; virtual;
    procedure DoCellFormatting(const AArgs: TThemedGridCellFormattingEventArgs); virtual;
    procedure DoCellPainting(const AArgs: TThemedGridCellPaintingEventArgs); virtual;
    procedure DoRowStyleNeeded(const AArgs: TThemedGridRowStyleEventArgs); virtual;
    procedure DoCellStyleNeeded(const AArgs: TThemedGridCellStyleEventArgs); virtual;
    procedure DoSelectionStyleNeeded(const AArgs: TThemedGridSelectionStyleEventArgs); virtual;
    procedure DoColumnWidthChanged(const AColumn: TThemedGridColumn; const AColumnIndex, AOldWidth, ANewWidth: Integer); virtual;
    procedure DoConditionalFormattingChanged(const AArgs: TThemedGridFormatConditionChangedEventArgs); virtual;
    procedure ColumnsStructureChanged; virtual;
    procedure DataSourceReset; virtual;
    procedure ViewStructureChanged; virtual;
    procedure DetailOptionsChanged(ASender: TObject); virtual;
    procedure NormalizeScrollValues; virtual; abstract;
    procedure ApplyAutoSizeModes; virtual; abstract;
    procedure RowsChangedByVersion; virtual;
    procedure EnsureRowView;
    procedure InvalidateRowView;
    procedure ResolveGroupColumns;
    procedure EnsureRowTopCache;
    function GetViewRow(const ARowIndex: Integer): TThemedGridViewRow;
    function GetViewRowDataSourceIndex(const ARowIndex: Integer): Integer;
    function GetViewRowObject(const AViewRow: TThemedGridViewRow): TValue;
    function IsDataViewRow(const ARowIndex: Integer): Boolean;
    function IsGroupViewRow(const ARowIndex: Integer): Boolean;
    function GetMetadata(const ADataSourceIndex: Integer; const AColumnName: string;
      const ACreate: Boolean): TThemedGridCellMetadata;
    function FormatDisplayText(const AValue: TValue; const AColumn: TThemedGridColumn;
      const AMetadata: TThemedGridCellMetadata): string;
    function ScaleInt(const AValue: Integer): Integer;
    procedure RebuildAutoColumns;
    procedure SyncColumnWidthCache;
    procedure CheckColumnWidthChanges;
    procedure CheckRowsChanged;
    procedure ClearColumnFilterStates;
    function GetVisibleColumns: TList<TThemedGridColumn>;
    property Renderer: TThemedGridRenderer read FRenderer;
    property CellMetadata: TObjectDictionary<TThemedGridCellKey, TThemedGridCellMetadata> read FCellMetadata;
    property Metrics: TThemedGridRenderMetrics read FMetrics;
    property RowView: TThemedGridRowView read FRowView;
    property DataController: IThemedGridDataController read FDataController;
    property Palette: TThemePalette read FPalette;
    property CollapsedGroupKeys: TThemedGridStringSet read FCollapsedGroupKeys;
    property ExpandedDetailKeys: TThemedGridStringSet read FExpandedDetailKeys;
    property FirstVisibleRowIndex: Integer read FFirstVisibleRowIndex write FFirstVisibleRowIndex;
    property HorizontalOffset: Integer read FHorizontalOffset write FHorizontalOffset;
    property CurrentRowIndex: Integer read FCurrentRowIndex write FCurrentRowIndex;
    property CurrentColumnIndex: Integer read FCurrentColumnIndex write FCurrentColumnIndex;
    property HoverRowIndex: Integer read FHoverRowIndex write FHoverRowIndex;
    property HoverColumnIndex: Integer read FHoverColumnIndex write FHoverColumnIndex;
    property PressedRowIndex: Integer read FPressedRowIndex write FPressedRowIndex;
    property PressedColumnIndex: Integer read FPressedColumnIndex write FPressedColumnIndex;
    property PressedContent: Boolean read FPressedContent write FPressedContent;
    property AutoSizePending: Boolean read FAutoSizePending write FAutoSizePending;
    property UpdatingAutoSize: Boolean read FUpdatingAutoSize write FUpdatingAutoSize;
    property HeaderBounds: TRect read FHeaderBounds write FHeaderBounds;
    property RowHeaderBounds: TRect read FRowHeaderBounds write FRowHeaderBounds;
    property DataBounds: TRect read FDataBounds write FDataBounds;
    property VerticalScrollBarBounds: TRect read FVerticalScrollBarBounds write FVerticalScrollBarBounds;
    property HorizontalScrollBarBounds: TRect read FHorizontalScrollBarBounds write FHorizontalScrollBarBounds;
    property ScrollCornerBounds: TRect read FScrollCornerBounds write FScrollCornerBounds;
    property SummaryFooterBounds: TRect read FSummaryFooterBounds write FSummaryFooterBounds;
    property VerticalScrollThumbBounds: TRect read FVerticalScrollThumbBounds write FVerticalScrollThumbBounds;
    property HorizontalScrollThumbBounds: TRect read FHorizontalScrollThumbBounds write FHorizontalScrollThumbBounds;
    property VerticalScrollVisible: Boolean read FVerticalScrollVisible write FVerticalScrollVisible;
    property HorizontalScrollVisible: Boolean read FHorizontalScrollVisible write FHorizontalScrollVisible;
    property RowTopCacheVersion: Integer read FRowTopCacheVersion write FRowTopCacheVersion;
    property RowTopCacheRowCount: Integer read FRowTopCacheRowCount write FRowTopCacheRowCount;
    property RowTopCacheBaseHeight: Integer read FRowTopCacheBaseHeight write FRowTopCacheBaseHeight;
    property RowTopCacheTotalHeight: Integer read FRowTopCacheTotalHeight write FRowTopCacheTotalHeight;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyThemePalette(const APalette: TThemePalette);
    procedure IThemeAware.ApplyTheme = ApplyThemePalette;
    function GetColumn(const AColumnIndex: Integer): TThemedGridColumn; overload;
    function GetColumn(const AColumnName: string): TThemedGridColumn; overload;
    function GetColumnVisibleIndex(const AColumnName: string): Integer;
    function GetColumnIndex(const AColumn: TThemedGridColumn): Integer;
    procedure BindList<T>(const AList: TList<T>);
    procedure SetRows(const ARows: IThemedGridRowList);
    procedure SetDataController(const AController: IThemedGridDataController);
    procedure Reload;
    function AddFormatCondition(const AColumnName: string; const AOperator: TThemedGridFormatConditionOperator;
      const AValue: TValue; const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition;
    procedure ClearFormatConditions;
    property Columns: TThemedGridColumnCollection read FColumns;
    property ColumnBands: TThemedGridColumnBandCollection read FColumnBands;
    property AutoGenerateColumns: Boolean read FAutoGenerateColumns write SetAutoGenerateColumns default True;
    property DataSource: TValue read FDataSource write SetDataSource;
    property DataVersion: Integer read GetDataVersion;
    property RowCount: Integer read GetRowCount;
    property ShowColumnHeaders: Boolean read FShowColumnHeaders write SetShowColumnHeaders default True;
    property ShowColumnBandHeaders: Boolean read FShowColumnBandHeaders write SetShowColumnBandHeaders default False;
    property ColumnBandHeaderHeight: Integer read FColumnBandHeaderHeight write SetColumnBandHeaderHeight default 26;
    property ShowRowHeaders: Boolean read FShowRowHeaders write SetShowRowHeaders default True;
    property ShowVerticalScrollBar: Boolean read FShowVerticalScrollBar write SetShowVerticalScrollBar default True;
    property ShowHorizontalScrollBar: Boolean read FShowHorizontalScrollBar write SetShowHorizontalScrollBar default True;
    property AllowColumnResize: Boolean read FAllowColumnResize write SetAllowColumnResize default True;
    property AllowColumnReorder: Boolean read FAllowColumnReorder write SetAllowColumnReorder default False;
    property AllowColumnSort: Boolean read FAllowColumnSort write SetAllowColumnSort default True;
    property RowHeight: Integer read GetRowHeight write SetRowHeight default 24;
    property HeaderHeight: Integer read GetHeaderHeight write SetHeaderHeight default 26;
    property RowHeaderWidth: Integer read GetRowHeaderWidth write SetRowHeaderWidth default 34;
    property ShowSummaryFooter: Boolean read FShowSummaryFooter write SetShowSummaryFooter default False;
    property SummaryFooterHeight: Integer read FSummaryFooterHeight write SetSummaryFooterHeight default 26;
    property SelectionMode: TThemedGridSelectionMode read FSelectionMode write SetSelectionMode default TThemedGridSelectionMode.Cell;
    property SelectionModel: TThemedGridSelectionModel read FSelectionModel;
    property ClipboardOptions: TThemedGridClipboardOptions read FClipboardOptions;
    property EditOptions: TThemedGridEditOptions read FEditOptions;
    property SelectionOptions: TThemedGridSelectionOptions read FSelectionOptions;
    property SearchOptions: TThemedGridSearchOptions read FSearchOptions;
    property FormatConditions: TThemedGridFormatConditionCollection read FFormatConditions;
    property Groups: TThemedGridGroupDescriptorCollection read FGroups;
    property GroupingOptions: TThemedGridGroupingOptions read FGroupingOptions;
    property DetailOptions: TThemedGridDetailOptions read FDetailOptions;
    property IsGrouped: Boolean read GetIsGrouped;
    property HasFormatConditions: Boolean read GetHasFormatConditions;
    property HasEnabledFormatConditions: Boolean read GetHasEnabledFormatConditions;
    property FormatConditionsEnabled: Boolean read GetFormatConditionsEnabled write SetFormatConditionsEnabled default True;
    property OnCellFormatting: TThemedGridCellFormattingEvent read FOnCellFormatting write FOnCellFormatting;
    property OnCellPainting: TThemedGridCellPaintingEvent read FOnCellPainting write FOnCellPainting;
    property OnRowStyleNeeded: TThemedGridRowStyleEvent read FOnRowStyleNeeded write FOnRowStyleNeeded;
    property OnCellStyleNeeded: TThemedGridCellStyleEvent read FOnCellStyleNeeded write FOnCellStyleNeeded;
    property OnSelectionStyleNeeded: TThemedGridSelectionStyleEvent read FOnSelectionStyleNeeded write FOnSelectionStyleNeeded;
    property OnDataSourceChanging: TThemedGridDataSourceChangingEvent read FOnDataSourceChanging write FOnDataSourceChanging;
    property OnDataSourceChanged: TThemedGridDataSourceChangedEvent read FOnDataSourceChanged write FOnDataSourceChanged;
    property OnRowsChanged: TThemedGridRowsChangedEvent read FOnRowsChanged write FOnRowsChanged;
    property OnColumnWidthChanged: TThemedGridColumnWidthChangedEvent read FOnColumnWidthChanged write FOnColumnWidthChanged;
    property OnConditionalFormattingChanged: TThemedGridFormatConditionChangedEvent
      read FOnConditionalFormattingChanged write FOnConditionalFormattingChanged;
  end;

implementation

uses
  NimbusForms.Theming.Manager,
  NimbusForms.Grid.GdiCache,
  NimbusForms.Grid.ValueConverter,
  NimbusForms.Grid.ValueFormatter,
  NimbusForms.Grid.DataSourceResolver,
  NimbusForms.Grid.DistinctValueProvider,
  NimbusForms.Grid.RowViewBuilder;

function SameDataSource(const ALeft, ARight: TValue): Boolean;
begin
  if (ALeft.TypeInfo = nil) and (ARight.TypeInfo = nil) then
    Exit(True);
  if (ALeft.TypeInfo = nil) or (ARight.TypeInfo = nil) then
    Exit(False);
  if (ALeft.Kind = tkClass) and (ARight.Kind = tkClass) then
    Exit(ALeft.AsObject = ARight.AsObject);
  if (ALeft.Kind = tkInterface) and (ARight.Kind = tkInterface) then
    Exit(ALeft.AsInterface = ARight.AsInterface);
  Result := False;
end;

constructor TThemedGridControlBase.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csCaptureMouse, csClickEvents, csDoubleClicks];
  TabStop := True;
  Width := 480;
  Height := 320;
  DoubleBuffered := True;
  Font.Name := 'Segoe UI';
  Font.Size := 9;

  FColumns := TThemedGridColumnCollection.Create;
  FColumns.OnChanged := ColumnsChanged;
  FColumnBands := TThemedGridColumnBandCollection.Create;
  FColumnBands.OnChanged := ColumnBandsChanged;
  FVisibleColumns := TList<TThemedGridColumn>.Create;
  FVisibleColumnsDirty := True;
  FCellMetadata := TObjectDictionary<TThemedGridCellKey, TThemedGridCellMetadata>.Create([doOwnsValues],
    TEqualityComparer<TThemedGridCellKey>.Construct(
      function(const ALeft, ARight: TThemedGridCellKey): Boolean
      begin
        Result := ALeft.Equals(ARight);
      end,
      function(const AValue: TThemedGridCellKey): Integer
      begin
        Result := AValue.GetHashCode;
      end));
  FRenderer := TThemedGridRenderer.Create;
  FMetrics := TThemedGridRenderMetrics.Create;
  FRowView := TThemedGridRowView.Create;
  FGroups := TThemedGridGroupDescriptorCollection.Create;
  FGroups.OnChanged := GroupsChanged;
  FGroupingOptions := TThemedGridGroupingOptions.Create;
  FGroupingOptions.OnChanged := GroupingOptionsChanged;
  FCollapsedGroupKeys := TThemedGridStringSet.Create;
  FDetailOptions := TThemedGridDetailOptions.Create;
  FDetailOptions.OnChanged := DetailOptionsChanged;
  FExpandedDetailKeys := TThemedGridStringSet.Create;
  FSelectionModel := TThemedGridSelectionModel.Create;
  FSelectionModel.OnChanged := SelectionModelChanged;
  FClipboardOptions := TThemedGridClipboardOptions.Create;
  FClipboardOptions.OnChanged := OptionsChanged;
  FEditOptions := TThemedGridEditOptions.Create;
  FEditOptions.OnChanged := OptionsChanged;
  FSelectionOptions := TThemedGridSelectionOptions.Create;
  FSelectionOptions.OnChanged := OptionsChanged;
  FSearchOptions := TThemedGridSearchOptions.Create;
  FSearchOptions.OnChanged := OptionsChanged;
  FFormatConditions := TThemedGridFormatConditionCollection.Create;
  FFormatConditions.OnChanged := FormatConditionsChanged;
  FColumnWidthCache := TDictionary<TThemedGridColumn, Integer>.Create;

  FDataSource := TValue.Empty;
  FDataController := TThemedGridDataSourceResolver.Resolve(TValue.Empty);
  FDataVersion := -1;
  FRowViewDataVersion := -1;
  FRowViewDataRowCount := -1;
  FAutoGenerateColumns := True;
  FShowColumnHeaders := True;
  FColumnBandHeaderHeight := 26;
  FShowRowHeaders := True;
  FShowVerticalScrollBar := True;
  FShowHorizontalScrollBar := True;
  FAllowColumnResize := True;
  FAllowColumnSort := True;
  FSummaryFooterHeight := 26;
  FSelectionMode := TThemedGridSelectionMode.Cell;
  FCurrentRowIndex := -1;
  FCurrentColumnIndex := -1;
  FHoverRowIndex := -1;
  FHoverColumnIndex := -1;
  FPressedRowIndex := -1;
  FPressedColumnIndex := -1;
  FRowTopCacheVersion := -1;
  FRowTopCacheRowCount := -1;

  if ThemeManager.CurrentTheme <> nil then
    ApplyThemePalette(ThemeManager.CurrentTheme);
  ThemeManager.RegisterAware(Self);
end;

destructor TThemedGridControlBase.Destroy;
begin
  ThemeManager.UnregisterAware(Self);
  FDataController := nil;
  FColumnWidthCache.Free;
  FFormatConditions.Free;
  FSearchOptions.Free;
  FSelectionOptions.Free;
  FEditOptions.Free;
  FClipboardOptions.Free;
  FSelectionModel.Free;
  FExpandedDetailKeys.Free;
  FDetailOptions.Free;
  FCollapsedGroupKeys.Free;
  FGroupingOptions.Free;
  FGroups.Free;
  FRowView.Free;
  FMetrics.Free;
  FRenderer.Free;
  FCellMetadata.Free;
  FVisibleColumns.Free;
  FColumnBands.Free;
  FColumns.Free;
  FPalette.Free;
  inherited Destroy;
end;

procedure TThemedGridControlBase.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

procedure TThemedGridControlBase.ApplyThemePalette(const APalette: TThemePalette);
var
  LClone: TThemePalette;
begin
  if APalette = nil then
    LClone := nil
  else
    LClone := APalette.Clone;
  FPalette.Free;
  FPalette := LClone;
  ApplyTheme(FPalette);
end;

procedure TThemedGridControlBase.ApplyTheme(const APalette: TThemePalette);
begin
  TThemedGridGdiCache.Clear;
  Invalidate;
end;

function TThemedGridControlBase.ScaleInt(const AValue: Integer): Integer;
begin
  Result := MulDiv(AValue, CurrentPPI, 96);
end;

procedure TThemedGridControlBase.RebuildVisibleColumns;
var
  LFresh: TList<TThemedGridColumn>;
begin
  LFresh := FColumns.GetVisibleColumns;
  try
    FVisibleColumns.Clear;
    FVisibleColumns.AddRange(LFresh);
  finally
    LFresh.Free;
  end;
  FVisibleColumnsDirty := False;
end;

function TThemedGridControlBase.GetVisibleColumns: TList<TThemedGridColumn>;
begin
  if FVisibleColumnsDirty then
    RebuildVisibleColumns;
  Result := FVisibleColumns;
end;

function TThemedGridControlBase.GetColumn(const AColumnIndex: Integer): TThemedGridColumn;
var
  LColumns: TList<TThemedGridColumn>;
begin
  LColumns := GetVisibleColumns;
  if (AColumnIndex < 0) or (AColumnIndex >= LColumns.Count) then
    Exit(nil);
  Result := LColumns[AColumnIndex];
end;

function TThemedGridControlBase.GetColumn(const AColumnName: string): TThemedGridColumn;
begin
  Result := FColumns.FindByName(AColumnName);
end;

function TThemedGridControlBase.GetColumnVisibleIndex(const AColumnName: string): Integer;
var
  LColumns: TList<TThemedGridColumn>;
  I: Integer;
begin
  LColumns := GetVisibleColumns;
  for I := 0 to LColumns.Count - 1 do
    if SameText(LColumns[I].Name, AColumnName) then
      Exit(I);
  Result := -1;
end;

function TThemedGridControlBase.GetColumnIndex(const AColumn: TThemedGridColumn): Integer;
var
  LColumns: TList<TThemedGridColumn>;
  I: Integer;
begin
  LColumns := GetVisibleColumns;
  for I := 0 to LColumns.Count - 1 do
    if LColumns[I] = AColumn then
      Exit(I);
  Result := -1;
end;

function TThemedGridControlBase.GetMetadata(const ADataSourceIndex: Integer; const AColumnName: string;
  const ACreate: Boolean): TThemedGridCellMetadata;
var
  LKey: TThemedGridCellKey;
begin
  LKey := TThemedGridCellKey.Create(ADataSourceIndex, AColumnName);
  if FCellMetadata.TryGetValue(LKey, Result) then
    Exit;
  if not ACreate then
    Exit(nil);
  Result := TThemedGridCellMetadata.Create;
  FCellMetadata.Add(LKey, Result);
end;

function TThemedGridControlBase.FormatDisplayText(const AValue: TValue; const AColumn: TThemedGridColumn;
  const AMetadata: TThemedGridCellMetadata): string;
begin
  Result := TThemedGridValueFormatter.Format(AValue, AColumn, AMetadata);
end;

function TThemedGridControlBase.GetDataVersion: Integer;
begin
  if FDataController <> nil then
    Result := FDataController.Version
  else
    Result := -1;
end;

function TThemedGridControlBase.GetRowCount: Integer;
begin
  EnsureRowView;
  Result := FRowView.Count;
end;

procedure TThemedGridControlBase.EnsureRowView;
var
  LVersion, LRowCount: Integer;
begin
  if FDataController = nil then
  begin
    if FRowView.Count > 0 then
      FRowView.Clear;
    FRowViewDataVersion := -1;
    FRowViewDataRowCount := -1;
    FRowTopCacheVersion := -1;
    Exit;
  end;
  LVersion := FDataController.Version;
  LRowCount := FDataController.RowCount;
  if (FRowViewDataVersion = LVersion) and (FRowViewDataRowCount = LRowCount) then
    Exit;
  ResolveGroupColumns;
  TThemedGridRowViewBuilder.Build(FDataController, FRowView, FMetrics.RowHeight, FGroups,
    FCollapsedGroupKeys, FGroupingOptions, FExpandedDetailKeys, FDetailOptions);
  FRowViewDataVersion := LVersion;
  FRowViewDataRowCount := LRowCount;
  FRowTopCacheVersion := -1;
  FRowTopCacheRowCount := -1;
end;

procedure TThemedGridControlBase.InvalidateRowView;
begin
  FRowViewDataVersion := -1;
  FRowViewDataRowCount := -1;
  FRowTopCacheVersion := -1;
  FRowTopCacheRowCount := -1;
  FRowTopCacheBaseHeight := 0;
  FRowTopCacheTotalHeight := 0;
end;

procedure TThemedGridControlBase.EnsureRowTopCache;
var
  LCount, LVersion: Integer;
begin
  EnsureRowView;
  LCount := FRowView.Count;
  LVersion := FRowView.Version;
  if (FRowTopCacheVersion = LVersion) and (FRowTopCacheRowCount = LCount) then
    Exit;
  FRowTopCacheRowCount := LCount;
  FRowTopCacheBaseHeight := FMetrics.RowHeight;
  if FRowTopCacheBaseHeight < 12 then
    FRowTopCacheBaseHeight := 12;
  FRowTopCacheTotalHeight := FRowView.GetRowsTotalHeight(FRowTopCacheBaseHeight);
  FRowTopCacheVersion := LVersion;
end;

procedure TThemedGridControlBase.ResolveGroupColumns;
var
  I: Integer;
  LGroup: TThemedGridGroupDescriptor;
begin
  for I := 0 to FGroups.Count - 1 do
  begin
    LGroup := FGroups[I];
    if (LGroup = nil) or (LGroup.Column <> nil) or (LGroup.ColumnName = '') then
      Continue;
    LGroup.Column := GetColumn(LGroup.ColumnName);
  end;
end;

function TThemedGridControlBase.GetViewRow(const ARowIndex: Integer): TThemedGridViewRow;
begin
  EnsureRowView;
  Result := FRowView.GetRow(ARowIndex);
end;

function TThemedGridControlBase.GetViewRowDataSourceIndex(const ARowIndex: Integer): Integer;
var
  LViewRow: TThemedGridViewRow;
begin
  LViewRow := GetViewRow(ARowIndex);
  if (LViewRow = nil) or (not LViewRow.IsDataRow) then
    Exit(-1);
  Result := LViewRow.DataSourceIndex;
end;

function TThemedGridControlBase.GetViewRowObject(const AViewRow: TThemedGridViewRow): TValue;
begin
  Result := TValue.Empty;
  if (AViewRow = nil) or (FDataController = nil) then
    Exit;
  if AViewRow.IsDataRow then
  begin
    if AViewRow.RowObject.TypeInfo <> nil then
      Exit(AViewRow.RowObject);
    if AViewRow.DataSourceIndex < 0 then
      Exit;
    Exit(FDataController.GetRowObject(AViewRow.DataSourceIndex));
  end;
  if AViewRow.IsDetailRow then
  begin
    if AViewRow.ParentRowObject.TypeInfo <> nil then
      Exit(AViewRow.ParentRowObject);
    if AViewRow.ParentDataSourceIndex < 0 then
      Exit;
    Result := FDataController.GetRowObject(AViewRow.ParentDataSourceIndex);
    AViewRow.ParentRowObject := Result;
    Exit;
  end;
  Result := AViewRow.RowObject;
end;

function TThemedGridControlBase.IsDataViewRow(const ARowIndex: Integer): Boolean;
var
  LViewRow: TThemedGridViewRow;
begin
  LViewRow := GetViewRow(ARowIndex);
  Result := (LViewRow <> nil) and LViewRow.IsDataRow;
end;

function TThemedGridControlBase.IsGroupViewRow(const ARowIndex: Integer): Boolean;
var
  LViewRow: TThemedGridViewRow;
begin
  LViewRow := GetViewRow(ARowIndex);
  Result := (LViewRow <> nil) and (LViewRow.Kind = TThemedGridViewRowKind.GroupHeader);
end;

procedure TThemedGridControlBase.ClearColumnFilterStates;
var
  I: Integer;
begin
  for I := 0 to FColumns.Count - 1 do
    if FColumns[I] <> nil then
    begin
      FColumns[I].Filter := nil;
      FColumns[I].IsFiltered := False;
    end;
end;

procedure TThemedGridControlBase.RebuildAutoColumns;
var
  LGenerated: TList<TThemedGridColumn>;
  I: Integer;
begin
  if not FAutoGenerateColumns then
    Exit;
  FColumns.OnChanged := nil;
  try
    FColumns.Clear;
    LGenerated := TThemedGridDataSourceResolver.CreateColumns(FDataSource);
    try
      for I := 0 to LGenerated.Count - 1 do
        FColumns.Add(LGenerated[I]);
    finally
      LGenerated.Free;
    end;
  finally
    FColumns.OnChanged := ColumnsChanged;
  end;
  FVisibleColumnsDirty := True;
end;

procedure TThemedGridControlBase.SyncColumnWidthCache;
var
  I: Integer;
begin
  FColumnWidthCache.Clear;
  for I := 0 to FColumns.Count - 1 do
    if (FColumns[I] <> nil) and (not FColumnWidthCache.ContainsKey(FColumns[I])) then
      FColumnWidthCache.Add(FColumns[I], FColumns[I].Width);
end;

procedure TThemedGridControlBase.CheckColumnWidthChanges;
var
  LRemove: TList<TThemedGridColumn>;
  LPair: TPair<TThemedGridColumn, Integer>;
  I, LOldWidth: Integer;
  LColumn: TThemedGridColumn;
begin
  LRemove := TList<TThemedGridColumn>.Create;
  try
    for LPair in FColumnWidthCache do
      if FColumns.IndexOf(LPair.Key) < 0 then
        LRemove.Add(LPair.Key);
    for I := 0 to LRemove.Count - 1 do
      FColumnWidthCache.Remove(LRemove[I]);
  finally
    LRemove.Free;
  end;
  for I := 0 to FColumns.Count - 1 do
  begin
    LColumn := FColumns[I];
    if LColumn = nil then
      Continue;
    if not FColumnWidthCache.TryGetValue(LColumn, LOldWidth) then
    begin
      FColumnWidthCache.AddOrSetValue(LColumn, LColumn.Width);
      Continue;
    end;
    if LOldWidth = LColumn.Width then
      Continue;
    FColumnWidthCache.AddOrSetValue(LColumn, LColumn.Width);
    DoColumnWidthChanged(LColumn, I, LOldWidth, LColumn.Width);
  end;
end;

procedure TThemedGridControlBase.CheckRowsChanged;
begin
  if FDataController = nil then
    Exit;
  if FDataVersion = FDataController.Version then
    Exit;
  FDataVersion := FDataController.Version;
  InvalidateRowView;
  RowsChangedByVersion;
  NormalizeScrollValues;
  DoRowsChanged;
end;

procedure TThemedGridControlBase.RowsChangedByVersion;
begin
end;

procedure TThemedGridControlBase.ColumnsStructureChanged;
begin
end;

procedure TThemedGridControlBase.DataSourceReset;
begin
end;

procedure TThemedGridControlBase.ViewStructureChanged;
begin
end;

procedure TThemedGridControlBase.DoDataSourceChanging(const AArgs: TThemedGridDataSourceChangingEventArgs);
begin
  if Assigned(FOnDataSourceChanging) then
    FOnDataSourceChanging(Self, AArgs);
end;

procedure TThemedGridControlBase.DoDataSourceChanged(const AOld, ANew: TValue);
var
  LArgs: TThemedGridDataSourceChangedEventArgs;
begin
  if not Assigned(FOnDataSourceChanged) then
    Exit;
  LArgs := TThemedGridDataSourceChangedEventArgs.Create(AOld, ANew);
  try
    FOnDataSourceChanged(Self, LArgs);
  finally
    LArgs.Free;
  end;
end;

procedure TThemedGridControlBase.DoRowsChanged;
var
  LArgs: TThemedGridRowsChangedEventArgs;
begin
  if not Assigned(FOnRowsChanged) then
    Exit;
  LArgs := TThemedGridRowsChangedEventArgs.Create(RowCount, GetDataVersion);
  try
    FOnRowsChanged(Self, LArgs);
  finally
    LArgs.Free;
  end;
end;

procedure TThemedGridControlBase.DoCellFormatting(const AArgs: TThemedGridCellFormattingEventArgs);
begin
  if Assigned(FOnCellFormatting) then
    FOnCellFormatting(Self, AArgs);
end;

procedure TThemedGridControlBase.DoCellPainting(const AArgs: TThemedGridCellPaintingEventArgs);
begin
  if Assigned(FOnCellPainting) then
    FOnCellPainting(Self, AArgs);
end;

procedure TThemedGridControlBase.DoRowStyleNeeded(const AArgs: TThemedGridRowStyleEventArgs);
begin
  if Assigned(FOnRowStyleNeeded) then
    FOnRowStyleNeeded(Self, AArgs);
end;

procedure TThemedGridControlBase.DoCellStyleNeeded(const AArgs: TThemedGridCellStyleEventArgs);
begin
  if Assigned(FOnCellStyleNeeded) then
    FOnCellStyleNeeded(Self, AArgs);
end;

procedure TThemedGridControlBase.DoSelectionStyleNeeded(const AArgs: TThemedGridSelectionStyleEventArgs);
begin
  if Assigned(FOnSelectionStyleNeeded) then
    FOnSelectionStyleNeeded(Self, AArgs);
end;

procedure TThemedGridControlBase.DoColumnWidthChanged(const AColumn: TThemedGridColumn;
  const AColumnIndex, AOldWidth, ANewWidth: Integer);
var
  LArgs: TThemedGridColumnWidthChangedEventArgs;
begin
  if not Assigned(FOnColumnWidthChanged) then
    Exit;
  LArgs := TThemedGridColumnWidthChangedEventArgs.Create(AColumn, AColumnIndex, AOldWidth, ANewWidth);
  try
    FOnColumnWidthChanged(Self, LArgs);
  finally
    LArgs.Free;
  end;
end;

procedure TThemedGridControlBase.DoConditionalFormattingChanged(const AArgs: TThemedGridFormatConditionChangedEventArgs);
begin
  if Assigned(FOnConditionalFormattingChanged) then
    FOnConditionalFormattingChanged(Self, AArgs);
end;

procedure TThemedGridControlBase.ColumnsChanged(ASender: TObject);
begin
  FVisibleColumnsDirty := True;
  CheckColumnWidthChanges;
  if not FUpdatingAutoSize then
    FAutoSizePending := True;
  ColumnsStructureChanged;
  NormalizeScrollValues;
  Invalidate;
end;

procedure TThemedGridControlBase.ColumnBandsChanged(ASender: TObject);
begin
  NormalizeScrollValues;
  Invalidate;
end;

procedure TThemedGridControlBase.SelectionModelChanged(ASender: TObject);
begin
  Invalidate;
end;

procedure TThemedGridControlBase.OptionsChanged(ASender: TObject);
begin
  Invalidate;
end;

procedure TThemedGridControlBase.GroupsChanged(ASender: TObject);
begin
  ResolveGroupColumns;
  FCollapsedGroupKeys.Clear;
  InvalidateRowView;
  ViewStructureChanged;
  NormalizeScrollValues;
  DoRowsChanged;
  Invalidate;
end;

procedure TThemedGridControlBase.GroupingOptionsChanged(ASender: TObject);
begin
  InvalidateRowView;
  ViewStructureChanged;
  NormalizeScrollValues;
  DoRowsChanged;
  Invalidate;
end;

procedure TThemedGridControlBase.DetailOptionsChanged(ASender: TObject);
begin
  if not FDetailOptions.Enabled then
    FExpandedDetailKeys.Clear;
  InvalidateRowView;
  ViewStructureChanged;
  NormalizeScrollValues;
  DoRowsChanged;
  Invalidate;
end;

procedure TThemedGridControlBase.FormatConditionsChanged(ASender: TObject;
  const AArgs: TThemedGridFormatConditionChangedEventArgs);
begin
  DoConditionalFormattingChanged(AArgs);
  Invalidate;
end;

procedure TThemedGridControlBase.SetAutoGenerateColumns(const AValue: Boolean);
begin
  if FAutoGenerateColumns = AValue then
    Exit;
  FAutoGenerateColumns := AValue;
  RebuildAutoColumns;
  SyncColumnWidthCache;
  Invalidate;
end;

procedure TThemedGridControlBase.SetDataSource(const AValue: TValue);
var
  LOld: TValue;
  LChanging: TThemedGridDataSourceChangingEventArgs;
  LCancel: Boolean;
  LController: IThemedGridDataController;
begin
  if SameDataSource(FDataSource, AValue) then
    Exit;
  LOld := FDataSource;
  LChanging := TThemedGridDataSourceChangingEventArgs.Create(LOld, AValue);
  try
    DoDataSourceChanging(LChanging);
    LCancel := LChanging.Cancel;
  finally
    LChanging.Free;
  end;
  if LCancel then
    Exit;

  LController := TThemedGridDataSourceResolver.Resolve(AValue);
  FDataSource := AValue;
  FDataController := LController;
  FDataVersion := FDataController.Version;
  FRowView.Clear;
  FRowViewDataVersion := -1;
  FRowViewDataRowCount := -1;
  FRowTopCacheVersion := -1;
  TThemedGridDistinctValueProvider.ClearCache;
  TThemedGridRowViewBuilder.ClearGroupCache;
  FCellMetadata.Clear;
  FFirstVisibleRowIndex := 0;
  FHorizontalOffset := 0;
  FCurrentRowIndex := -1;
  FCurrentColumnIndex := -1;
  FHoverRowIndex := -1;
  FHoverColumnIndex := -1;
  FPressedRowIndex := -1;
  FPressedColumnIndex := -1;
  FPressedContent := False;
  FSelectionModel.Clear;
  DataSourceReset;
  ClearColumnFilterStates;
  RebuildAutoColumns;
  SyncColumnWidthCache;
  DoDataSourceChanged(LOld, AValue);
  DoRowsChanged;
  FAutoSizePending := True;
  NormalizeScrollValues;
  Invalidate;
end;

procedure TThemedGridControlBase.BindList<T>(const AList: TList<T>);
begin
  SetDataSource(TValue.From<IThemedGridRowList>(TThemedGridListAdapter<T>.Create(AList)));
end;

procedure TThemedGridControlBase.SetRows(const ARows: IThemedGridRowList);
begin
  SetDataSource(TValue.From<IThemedGridRowList>(ARows));
end;

procedure TThemedGridControlBase.SetDataController(const AController: IThemedGridDataController);
begin
  SetDataSource(TValue.From<IThemedGridDataController>(AController));
end;

procedure TThemedGridControlBase.Reload;
begin
  InvalidateRowView;
  FFirstVisibleRowIndex := 0;
  FCurrentRowIndex := -1;
  FCurrentColumnIndex := -1;
  FHoverRowIndex := -1;
  FHoverColumnIndex := -1;
  NormalizeScrollValues;
  Invalidate;
end;

function TThemedGridControlBase.AddFormatCondition(const AColumnName: string;
  const AOperator: TThemedGridFormatConditionOperator; const AValue: TValue;
  const AStyle: TThemedGridFormatStyle): TThemedGridFormatCondition;
begin
  Result := FFormatConditions.Add(AColumnName, AOperator, AValue, AStyle);
end;

procedure TThemedGridControlBase.ClearFormatConditions;
begin
  FFormatConditions.Clear;
end;

function TThemedGridControlBase.GetRowHeight: Integer;
begin
  Result := FMetrics.RowHeight;
end;

procedure TThemedGridControlBase.SetRowHeight(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 12 then
    LValue := 12;
  if FMetrics.RowHeight = LValue then
    Exit;
  FMetrics.RowHeight := LValue;
  InvalidateRowView;
  FAutoSizePending := True;
  NormalizeScrollValues;
  Invalidate;
end;

function TThemedGridControlBase.GetHeaderHeight: Integer;
begin
  Result := FMetrics.HeaderHeight;
end;

procedure TThemedGridControlBase.SetHeaderHeight(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 16 then
    LValue := 16;
  if FMetrics.HeaderHeight = LValue then
    Exit;
  FMetrics.HeaderHeight := LValue;
  NormalizeScrollValues;
  Invalidate;
end;

function TThemedGridControlBase.GetRowHeaderWidth: Integer;
begin
  Result := FMetrics.RowHeaderWidth;
end;

procedure TThemedGridControlBase.SetRowHeaderWidth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 0 then
    LValue := 0;
  if FMetrics.RowHeaderWidth = LValue then
    Exit;
  FMetrics.RowHeaderWidth := LValue;
  NormalizeScrollValues;
  Invalidate;
end;

procedure TThemedGridControlBase.SetShowColumnHeaders(const AValue: Boolean);
begin
  if FShowColumnHeaders = AValue then
    Exit;
  FShowColumnHeaders := AValue;
  Invalidate;
end;

procedure TThemedGridControlBase.SetShowColumnBandHeaders(const AValue: Boolean);
begin
  if FShowColumnBandHeaders = AValue then
    Exit;
  FShowColumnBandHeaders := AValue;
  NormalizeScrollValues;
  Invalidate;
end;

procedure TThemedGridControlBase.SetColumnBandHeaderHeight(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 16 then
    LValue := 16;
  if LValue > 80 then
    LValue := 80;
  if FColumnBandHeaderHeight = LValue then
    Exit;
  FColumnBandHeaderHeight := LValue;
  NormalizeScrollValues;
  Invalidate;
end;

procedure TThemedGridControlBase.SetShowRowHeaders(const AValue: Boolean);
begin
  if FShowRowHeaders = AValue then
    Exit;
  FShowRowHeaders := AValue;
  Invalidate;
end;

procedure TThemedGridControlBase.SetShowVerticalScrollBar(const AValue: Boolean);
begin
  if FShowVerticalScrollBar = AValue then
    Exit;
  FShowVerticalScrollBar := AValue;
  Invalidate;
end;

procedure TThemedGridControlBase.SetShowHorizontalScrollBar(const AValue: Boolean);
begin
  if FShowHorizontalScrollBar = AValue then
    Exit;
  FShowHorizontalScrollBar := AValue;
  Invalidate;
end;

procedure TThemedGridControlBase.SetAllowColumnResize(const AValue: Boolean);
begin
  if FAllowColumnResize = AValue then
    Exit;
  FAllowColumnResize := AValue;
  Invalidate;
end;

procedure TThemedGridControlBase.SetAllowColumnReorder(const AValue: Boolean);
begin
  if FAllowColumnReorder = AValue then
    Exit;
  FAllowColumnReorder := AValue;
  Invalidate;
end;

procedure TThemedGridControlBase.SetAllowColumnSort(const AValue: Boolean);
begin
  if FAllowColumnSort = AValue then
    Exit;
  FAllowColumnSort := AValue;
  Invalidate;
end;

procedure TThemedGridControlBase.SetShowSummaryFooter(const AValue: Boolean);
begin
  if FShowSummaryFooter = AValue then
    Exit;
  FShowSummaryFooter := AValue;
  NormalizeScrollValues;
  Invalidate;
end;

procedure TThemedGridControlBase.SetSummaryFooterHeight(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 18 then
    LValue := 18;
  if LValue > 80 then
    LValue := 80;
  if FSummaryFooterHeight = LValue then
    Exit;
  FSummaryFooterHeight := LValue;
  NormalizeScrollValues;
  Invalidate;
end;

procedure TThemedGridControlBase.SetSelectionMode(const AValue: TThemedGridSelectionMode);
begin
  if FSelectionMode = AValue then
    Exit;
  FSelectionMode := AValue;
  FSelectionOptions.Mode := AValue;
  Invalidate;
end;

function TThemedGridControlBase.GetIsGrouped: Boolean;
begin
  Result := FGroupingOptions.Enabled and (FGroups.Count > 0);
end;

function TThemedGridControlBase.GetHasFormatConditions: Boolean;
begin
  Result := FFormatConditions.Count > 0;
end;

function TThemedGridControlBase.GetHasEnabledFormatConditions: Boolean;
begin
  Result := FFormatConditions.Enabled and (FFormatConditions.EnabledCount > 0);
end;

function TThemedGridControlBase.GetFormatConditionsEnabled: Boolean;
begin
  Result := FFormatConditions.Enabled;
end;

procedure TThemedGridControlBase.SetFormatConditionsEnabled(const AValue: Boolean);
begin
  if FFormatConditions.Enabled = AValue then
    Exit;
  FFormatConditions.SetEnabled(AValue);
end;

end.

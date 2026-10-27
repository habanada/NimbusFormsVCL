unit NimbusForms.Grid.ControlMasterDetail;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  System.Types,
  System.Rtti,
  System.TypInfo,
  System.Math,
  System.Generics.Collections,
  Vcl.Controls,
  Vcl.Graphics,
  Winapi.GDIPOBJ,
  Winapi.GDIPAPI,
  NimbusForms.Theming.Types,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.Cell,
  NimbusForms.Grid.ViewRow,
  NimbusForms.Grid.HitInfo,
  NimbusForms.Grid.RenderContext,
  NimbusForms.Grid.Events,
  NimbusForms.Grid.Events.MasterDetail,
  NimbusForms.Grid.DetailItem,
  NimbusForms.Grid.DetailItemCollection,
  NimbusForms.Grid.CellVisual,
  NimbusForms.Grid.Events.Visual,
  NimbusForms.Grid.DetailGridColumn,
  NimbusForms.Grid.DetailGridOptions,
  NimbusForms.Grid.DetailGridRowVisual,
  NimbusForms.Grid.DetailGridHitInfo,
  NimbusForms.Grid.MasterDetailData,
  NimbusForms.Grid.MasterDetailCache,
  NimbusForms.Grid.ControlApi;

type
  TThemedGridControlMasterDetail = class;
  TThemedGridControlMasterDetailClass = class of TThemedGridControlMasterDetail;

  TThemedGridControlMasterDetail = class(TThemedGridControlApi)
  private
    type
      TEmbeddedContext = class
      public
        Key: string;
        ViewRowIndex: Integer;
        ParentDataSourceIndex: Integer;
        ParentRowObject: TValue;
        RelationName: string;
        RelationIndex: Integer;
        DataVersion: Integer;
      end;

      TDetailRowCacheEntry = record
        DataVersion: Integer;
        DetailText: string;
        Height: Integer;
      end;
  private
    FMasterDetailCache: TThemedGridMasterDetailCache;
    FDetailRowCache: TDictionary<string, TDetailRowCacheEntry>;
    FDetailItemValueStore: TDictionary<string, TValue>;
    FEmbeddedGrids: TDictionary<string, TThemedGridControlMasterDetail>;
    FEmbeddedContexts: TObjectDictionary<TThemedGridControlMasterDetail, TEmbeddedContext>;
    FVisibleEmbeddedKeys: THashSet<string>;
    FGridPool: TList<TThemedGridControlMasterDetail>;
    FCleanedPool: THashSet<TThemedGridControlMasterDetail>;
    FPoolCleanPending: Boolean;
    FPoolDisposePending: Boolean;
    FScratchColumn: TThemedGridColumn;
    FScratchCell: TThemedGridCell;
    FHoverDetailItemRowIndex: Integer;
    FHoverDetailItemKey: string;
    FPressedDetailItemRowIndex: Integer;
    FPressedDetailItemKey: string;
    FOnMasterDetailDataNeeded: TThemedGridMasterDetailDataNeededEvent;
    FOnDetailItemsNeeded: TThemedGridDetailItemsNeededEvent;
    FOnDetailItemClick: TThemedGridDetailItemEvent;
    FOnDetailItemDoubleClick: TThemedGridDetailItemEvent;
    FOnDetailItemAction: TThemedGridDetailItemActionEvent;
    FOnDetailItemValueChanging: TThemedGridDetailItemValueChangingEvent;
    FOnDetailItemValueChanged: TThemedGridDetailItemValueChangedEvent;
    FOnDetailGridRowVisualNeeded: TThemedGridDetailGridRowVisualNeededEvent;
    FOnDetailGridCellClick: TThemedGridDetailGridCellMouseEvent;
    FOnDetailGridCellDoubleClick: TThemedGridDetailGridCellMouseEvent;
    FOnDetailRowHeightNeeded: TThemedGridDetailRowHeightNeededEvent;
    FOnDetailRowTextNeeded: TThemedGridDetailRowTextNeededEvent;
    FOnDetailRowPaint: TThemedGridDetailRowPaintEvent;
    FOnDetailItemVisualNeeded: TThemedGridDetailItemVisualNeededEvent;
    FOnDetailGridCellVisualNeeded: TThemedGridDetailGridCellVisualNeededEvent;
    FOnDetailGridHeaderVisualNeeded: TThemedGridDetailGridHeaderVisualNeededEvent;
    function CreateDetailRowCustomizationCacheKey(const AViewRow: TThemedGridViewRow;
      const ADataVersion: Integer): string;
    procedure AddDetailRowCustomizationCacheEntry(const ACacheKey, ADetailText: string; const AHeight,
      ADataVersion: Integer);
    procedure TrimDetailRowCustomizationCache(const ACurrentDataVersion: Integer);
    procedure ClearDetailRowCustomizationCache;
    procedure ClearMasterDetailDataCacheCore;
    procedure InvalidateRowTops;
    function ResolveParentRowObject(const AViewRow: TThemedGridViewRow): TValue;
    function GetMasterDetailRelationCount: Integer;
    function GetMasterDetailRelationName(const AVisibleRelationIndex: Integer): string;
    function GetOrCreateMasterDetailData(const AViewRow: TThemedGridViewRow; const ARowIndex: Integer): TThemedGridMasterDetailData; overload;
    function GetOrCreateMasterDetailData(const AViewRow: TThemedGridViewRow; const ARowIndex, ARelationIndex: Integer;
      const ARelationName: string): TThemedGridMasterDetailData; overload;
    function CreateDetailItemsNeededEventArgs(const AViewRow: TThemedGridViewRow; const ARowIndex: Integer;
      const ABounds, AContentBounds: TRect; const ADetailText: string): TThemedGridDetailItemsNeededEventArgs;
    function BuildDetailItemsArgs(const AViewRow: TThemedGridViewRow; const ARowIndex: Integer;
      const ABounds, AContentBounds: TRect; const ADetailText: string;
      out ADefaultData: TThemedGridMasterDetailData): TThemedGridDetailItemsNeededEventArgs;
    procedure MergeMasterDetailItems(const ATarget: TThemedGridDetailItemsNeededEventArgs;
      const AData: TThemedGridMasterDetailData);
    procedure ApplyStoredDetailItemValues(const AArgs: TThemedGridDetailItemsNeededEventArgs);
    procedure ArrangeDetailItems(const AArgs: TThemedGridDetailItemsNeededEventArgs);
    function GetDetailItemsBottom(const AArgs: TThemedGridDetailItemsNeededEventArgs): Integer;
    function ComputeAutoDetailRowHeight(const AViewRow: TThemedGridViewRow; const ARowIndex: Integer;
      out AHeight: Integer): Boolean;
    procedure DrawDetailItems(const AContext: TThemedGridRenderContext; const AViewRow: TThemedGridViewRow;
      const ARowIndex: Integer; const AArgs: TThemedGridDetailItemsNeededEventArgs);
    procedure DrawDetailItem(const AContext: TThemedGridRenderContext; const AViewRow: TThemedGridViewRow;
      const ARowIndex: Integer; const AItem: TThemedGridDetailItem; const ABounds: TRect; const AItemIndex: Integer);
    function TryGetDetailItemAt(const ADetailRowIndex: Integer; const ALocation: TPoint;
      out AArgs: TThemedGridDetailItemsNeededEventArgs; out AItem: TThemedGridDetailItem): Boolean;
    procedure ClearDetailItemPressedState;
    procedure UpdateDetailItemToolTip(const ARowIndex: Integer; const AItem: TThemedGridDetailItem;
      const ALocation: TPoint);
    function CreateDetailItemEventArgs(const ADetailRowIndex: Integer; const AItem: TThemedGridDetailItem;
      const AButton: TMouseButton; const AClicks: Integer; const ALocation: TPoint): TThemedGridDetailItemEventArgs;
    procedure ApplyDetailItemNewValue(const AItemArgs: TThemedGridDetailItemEventArgs);
    function IsDetailItemAction(const AItem: TThemedGridDetailItem): Boolean;
    procedure InvokeDetailItemAction(const AItemArgs: TThemedGridDetailItemEventArgs);
    function GetMasterDetailRelationIndexForEmbedded(const AKey: string): Integer;
    function CreateEmbeddedDetailGridKey(const AParentDataSourceIndex, ARelationIndex: Integer;
      const ARelationName: string): string;
    function GetDetailGridColumns(const AData: TThemedGridMasterDetailData): TThemedGridDetailGridColumnCollection;
    procedure BuildAutoDetailGridColumns(const AData: TThemedGridMasterDetailData);
    function GetDetailGridRowCount(const AData: TThemedGridMasterDetailData; const AKey: string): Integer;
    function ComputeEmbeddedGridBounds(const AData: TThemedGridMasterDetailData; const ARowCount: Integer;
      const AAvailable: TRect; out ABounds: TRect): Boolean;
    function EnsureEmbeddedMasterDetailGrid(const AViewRow: TThemedGridViewRow; const ARowIndex, ARelationIndex: Integer;
      const ARelationName: string; const AData: TThemedGridMasterDetailData; const AAvailable: TRect): Integer;
    function RentEmbeddedDetailGrid: TThemedGridControlMasterDetail;
    function CreateEmbeddedDetailGrid: TThemedGridControlMasterDetail;
    procedure ConfigureEmbeddedDetailGrid(const AGrid: TThemedGridControlMasterDetail;
      const AData: TThemedGridMasterDetailData; const AColumns: TThemedGridDetailGridColumnCollection);
    procedure RemoveEmbeddedDetailGridByKey(const AKey: string; const AForceDispose: Boolean);
    procedure ParkEmbeddedDetailGrid(const AGrid: TThemedGridControlMasterDetail);
    procedure FlushEmbeddedGridPool;
    procedure DetachEmbeddedGridHandlers(const AGrid: TThemedGridControlMasterDetail);
    procedure HideEmbeddedMasterDetailGrid(const AViewRow: TThemedGridViewRow);
    function ResolveContextViewRow(const AContext: TEmbeddedContext): TThemedGridViewRow;
    procedure EmbeddedDetailGridCellClick(ASender: TObject; const AArgs: TThemedGridCellMouseEventArgs);
    procedure EmbeddedDetailGridCellDoubleClick(ASender: TObject; const AArgs: TThemedGridCellMouseEventArgs);
    procedure EmbeddedDetailGridRowStyleNeeded(ASender: TObject; const AArgs: TThemedGridRowStyleEventArgs);
    procedure RaiseEmbeddedDetailGridCellMouseEvent(const AGrid: TThemedGridControlMasterDetail;
      const AArgs: TThemedGridCellMouseEventArgs; const ADoubleClick: Boolean);
    procedure SetHoverDetailItem(const ARowIndex: Integer; const AKey: string);
    function TryDrawDetailItemVisual(const AContext: TThemedGridRenderContext; const AViewRow: TThemedGridViewRow;
      const ARowIndex: Integer; const AItem: TThemedGridDetailItem; const ABounds: TRect;
      const AItemIndex: Integer): Boolean;
    procedure EmbeddedDetailGridCellVisualNeeded(ASender: TObject;
      const AArgs: TThemedGridCellVisualNeededEventArgs);
  protected
    procedure DataSourceReset; override;
    procedure DetailOptionsChanged(ASender: TObject); override;
    procedure EnsureDetailRowCustomized(const ARowIndex: Integer; const AViewRow: TThemedGridViewRow); override;
    function DrawDetailContent(const AContext: TThemedGridRenderContext; const AViewRow: TThemedGridViewRow;
      const ARowIndex: Integer; const ABounds, AContentBounds: TRect; const AFocused: Boolean): Boolean; override;
    procedure DrawDetailBody(const AContext: TThemedGridRenderContext; const AViewRow: TThemedGridViewRow;
      const ARowIndex: Integer; const ABounds, AContentBounds: TRect; const ADetailText: string); override;
    procedure BeginDetailLayout; override;
    procedure EndDetailLayout; override;
    function HasEmbeddedDetailGrids: Boolean; override;
    procedure RemoveEmbeddedDetailGridByDataSourceIndex(const ADataSourceIndex: Integer); override;
    procedure ClearEmbeddedDetailGrids; override;
    function DetailRowMouseDown(const AHit: TThemedGridHitInfo; const AButton: TMouseButton;
      const ALocation: TPoint): Boolean; override;
    function DetailRowMouseUp(const AHit: TThemedGridHitInfo; const AButton: TMouseButton;
      const ALocation: TPoint): Boolean; override;
    function DetailRowMouseMove(const AHit: TThemedGridHitInfo; const ALocation: TPoint): Boolean; override;
    function DetailRowDoubleClick(const AHit: TThemedGridHitInfo; const ALocation: TPoint): Boolean; override;
    procedure DetailRowMouseLeave; override;
    procedure DoMasterDetailDataNeeded(const AArgs: TThemedGridMasterDetailDataNeededEventArgs); virtual;
    procedure DoDetailItemsNeeded(const AArgs: TThemedGridDetailItemsNeededEventArgs); virtual;
    procedure DoDetailItemClick(const AArgs: TThemedGridDetailItemEventArgs); virtual;
    procedure DoDetailItemDoubleClick(const AArgs: TThemedGridDetailItemEventArgs); virtual;
    procedure DoDetailItemAction(const AArgs: TThemedGridDetailItemActionEventArgs); virtual;
    procedure DoDetailItemValueChanging(const AArgs: TThemedGridDetailItemValueChangingEventArgs); virtual;
    procedure DoDetailItemValueChanged(const AArgs: TThemedGridDetailItemValueChangedEventArgs); virtual;
    procedure DoDetailGridRowVisualNeeded(const AArgs: TThemedGridDetailGridRowVisualNeededEventArgs); virtual;
    procedure DoDetailGridCellClick(const AArgs: TThemedGridDetailGridCellMouseEventArgs); virtual;
    procedure DoDetailGridCellDoubleClick(const AArgs: TThemedGridDetailGridCellMouseEventArgs); virtual;
    procedure DoDetailRowHeightNeeded(const AArgs: TThemedGridDetailRowHeightNeededEventArgs); virtual;
    procedure DoDetailRowTextNeeded(const AArgs: TThemedGridDetailRowTextNeededEventArgs); virtual;
    procedure DoDetailRowPaint(const AArgs: TThemedGridDetailRowPaintEventArgs); virtual;
    procedure DoDetailItemVisualNeeded(const AArgs: TThemedGridDetailItemVisualNeededEventArgs); virtual;
    procedure DoDetailGridCellVisualNeeded(const AArgs: TThemedGridDetailGridCellVisualNeededEventArgs); virtual;
    procedure DoDetailGridHeaderVisualNeeded(const AArgs: TThemedGridDetailGridHeaderVisualNeededEventArgs); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetDetailItemValue(const AParentDataSourceIndex: Integer; const AItemKey: string;
      const ADefaultValue: TValue): TValue;
    procedure SetDetailItemValue(const AParentDataSourceIndex: Integer; const AItemKey: string; const AValue: TValue);
    procedure ClearDetailItemValues; overload;
    procedure ClearDetailItemValues(const AParentDataSourceIndex: Integer); overload;
    procedure ClearMasterDetailDataCache;
    procedure RefreshMasterDetailData(const AParentDataSourceIndex: Integer);
    property OnMasterDetailDataNeeded: TThemedGridMasterDetailDataNeededEvent
      read FOnMasterDetailDataNeeded write FOnMasterDetailDataNeeded;
    property OnDetailItemsNeeded: TThemedGridDetailItemsNeededEvent
      read FOnDetailItemsNeeded write FOnDetailItemsNeeded;
    property OnDetailItemClick: TThemedGridDetailItemEvent read FOnDetailItemClick write FOnDetailItemClick;
    property OnDetailItemDoubleClick: TThemedGridDetailItemEvent
      read FOnDetailItemDoubleClick write FOnDetailItemDoubleClick;
    property OnDetailItemAction: TThemedGridDetailItemActionEvent
      read FOnDetailItemAction write FOnDetailItemAction;
    property OnDetailItemValueChanging: TThemedGridDetailItemValueChangingEvent
      read FOnDetailItemValueChanging write FOnDetailItemValueChanging;
    property OnDetailItemValueChanged: TThemedGridDetailItemValueChangedEvent
      read FOnDetailItemValueChanged write FOnDetailItemValueChanged;
    property OnDetailGridRowVisualNeeded: TThemedGridDetailGridRowVisualNeededEvent
      read FOnDetailGridRowVisualNeeded write FOnDetailGridRowVisualNeeded;
    property OnDetailGridCellClick: TThemedGridDetailGridCellMouseEvent
      read FOnDetailGridCellClick write FOnDetailGridCellClick;
    property OnDetailGridCellDoubleClick: TThemedGridDetailGridCellMouseEvent
      read FOnDetailGridCellDoubleClick write FOnDetailGridCellDoubleClick;
    property OnDetailRowHeightNeeded: TThemedGridDetailRowHeightNeededEvent
      read FOnDetailRowHeightNeeded write FOnDetailRowHeightNeeded;
    property OnDetailRowTextNeeded: TThemedGridDetailRowTextNeededEvent
      read FOnDetailRowTextNeeded write FOnDetailRowTextNeeded;
    property OnDetailRowPaint: TThemedGridDetailRowPaintEvent read FOnDetailRowPaint write FOnDetailRowPaint;
    property OnDetailItemVisualNeeded: TThemedGridDetailItemVisualNeededEvent
      read FOnDetailItemVisualNeeded write FOnDetailItemVisualNeeded;
    property OnDetailGridCellVisualNeeded: TThemedGridDetailGridCellVisualNeededEvent
      read FOnDetailGridCellVisualNeeded write FOnDetailGridCellVisualNeeded;
    property OnDetailGridHeaderVisualNeeded: TThemedGridDetailGridHeaderVisualNeededEvent
      read FOnDetailGridHeaderVisualNeeded write FOnDetailGridHeaderVisualNeeded;
  end;

implementation

uses
  NimbusForms.Grid.Primitives,
  NimbusForms.Grid.GdiCache,
  NimbusForms.Grid.GdiText,
  NimbusForms.Grid.RowViewBuilder,
  NimbusForms.Grid.DataSourceResolver,
  NimbusForms.Grid.DataControllerIntf,
  NimbusForms.Grid.ValueFormatter,
  NimbusForms.Grid.CellRendererIntf,
  NimbusForms.Grid.CellRendererParts,
  NimbusForms.Grid.DetailRelation,
  NimbusForms.Grid.MasterDetailStrings;

const
  CDetailRowMinimumHeight = 24;
  CDetailRowMaximumHeight = 800;
  CDetailRowCacheLimit = 2048;
  CDetailItemSpacing = 6;
  CDetailGridMinimumWidth = 80;
  CDetailGridMinimumHeight = 24;
  CDetailGridBottomSpacing = 6;
  CDetailGridMinimumRemaining = 24;
  CDetailDisabledAlpha = 128;
  CFallbackMuted = TThemeColor($FF808080);
  CFallbackBack = TThemeColor($FFF0F0F0);

function WithAlpha(const AColor: TThemeColor; const AAlpha: Byte): TThemeColor;
begin
  Result := ThemeColor(AAlpha, ThemeColorRed(AColor), ThemeColorGreen(AColor), ThemeColorBlue(AColor));
end;

function CreateDetailItemValueStoreKey(const AParentDataSourceIndex: Integer; const AItemKey: string): string;
begin
  Result := IntToStr(AParentDataSourceIndex) + '|' + AItemKey;
end;

function MouseButtonSet(const AButton: TMouseButton): TThemedGridMouseButtons;
begin
  Result := [AButton];
end;

constructor TThemedGridControlMasterDetail.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMasterDetailCache := TThemedGridMasterDetailCache.Create;
  FDetailRowCache := TDictionary<string, TDetailRowCacheEntry>.Create;
  FDetailItemValueStore := TDictionary<string, TValue>.Create;
  FEmbeddedGrids := TDictionary<string, TThemedGridControlMasterDetail>.Create;
  FEmbeddedContexts := TObjectDictionary<TThemedGridControlMasterDetail, TEmbeddedContext>.Create([doOwnsValues]);
  FVisibleEmbeddedKeys := THashSet<string>.Create;
  FGridPool := TList<TThemedGridControlMasterDetail>.Create;
  FCleanedPool := THashSet<TThemedGridControlMasterDetail>.Create;
  FScratchColumn := TThemedGridColumn.Create;
  FScratchCell := TThemedGridCell.Create;
  FHoverDetailItemRowIndex := -1;
  FPressedDetailItemRowIndex := -1;
end;

destructor TThemedGridControlMasterDetail.Destroy;
var
  LGrid: TThemedGridControlMasterDetail;
begin
  for LGrid in FEmbeddedGrids.Values do
  begin
    DetachEmbeddedGridHandlers(LGrid);
    LGrid.DataSource := TValue.Empty;
  end;
  for LGrid in FGridPool do
  begin
    DetachEmbeddedGridHandlers(LGrid);
    LGrid.DataSource := TValue.Empty;
  end;
  FScratchCell.Free;
  FScratchColumn.Free;
  FCleanedPool.Free;
  FGridPool.Free;
  FVisibleEmbeddedKeys.Free;
  FEmbeddedContexts.Free;
  FEmbeddedGrids.Free;
  FDetailItemValueStore.Free;
  FDetailRowCache.Free;
  FMasterDetailCache.Free;
  inherited Destroy;
end;

procedure TThemedGridControlMasterDetail.DataSourceReset;
begin
  ClearMasterDetailDataCacheCore;
  ClearDetailRowCustomizationCache;
  inherited DataSourceReset;
end;

procedure TThemedGridControlMasterDetail.DetailOptionsChanged(ASender: TObject);
begin
  ClearMasterDetailDataCacheCore;
  inherited DetailOptionsChanged(ASender);
end;

procedure TThemedGridControlMasterDetail.ClearMasterDetailDataCacheCore;
begin
  ClearEmbeddedDetailGrids;
  FMasterDetailCache.Clear;
end;

procedure TThemedGridControlMasterDetail.InvalidateRowTops;
begin
  RowTopCacheVersion := -1;
  RowTopCacheRowCount := -1;
end;

function TThemedGridControlMasterDetail.ResolveParentRowObject(const AViewRow: TThemedGridViewRow): TValue;
begin
  Result := AViewRow.ParentRowObject;
  if (Result.TypeInfo = nil) and (DataController <> nil) and (AViewRow.ParentDataSourceIndex >= 0) then
    Result := DataController.GetRowObject(AViewRow.ParentDataSourceIndex);
end;

function TThemedGridControlMasterDetail.CreateDetailRowCustomizationCacheKey(const AViewRow: TThemedGridViewRow;
  const ADataVersion: Integer): string;
var
  LKey: string;
begin
  if AViewRow = nil then
    Exit('');
  LKey := '';
  if AViewRow.Key.TypeInfo <> nil then
    LKey := AViewRow.Key.ToString;
  if LKey = '' then
    LKey := TThemedGridRowViewBuilder.CreateDetailKey(AViewRow.ParentDataSourceIndex);
  Result := IntToStr(ADataVersion) + '|' + IntToStr(AViewRow.ParentDataSourceIndex) + '|' + LKey;
end;

procedure TThemedGridControlMasterDetail.AddDetailRowCustomizationCacheEntry(const ACacheKey, ADetailText: string;
  const AHeight, ADataVersion: Integer);
var
  LEntry: TDetailRowCacheEntry;
begin
  if ACacheKey = '' then
    Exit;
  if FDetailRowCache.Count >= CDetailRowCacheLimit then
    TrimDetailRowCustomizationCache(ADataVersion);
  LEntry.DataVersion := ADataVersion;
  LEntry.DetailText := ADetailText;
  LEntry.Height := AHeight;
  FDetailRowCache.AddOrSetValue(ACacheKey, LEntry);
end;

procedure TThemedGridControlMasterDetail.TrimDetailRowCustomizationCache(const ACurrentDataVersion: Integer);
var
  LKeys: TList<string>;
  LPair: TPair<string, TDetailRowCacheEntry>;
  I: Integer;
begin
  if FDetailRowCache.Count = 0 then
    Exit;
  LKeys := TList<string>.Create;
  try
    for LPair in FDetailRowCache do
      if LPair.Value.DataVersion <> ACurrentDataVersion then
        LKeys.Add(LPair.Key);
    for I := 0 to LKeys.Count - 1 do
      FDetailRowCache.Remove(LKeys[I]);
  finally
    LKeys.Free;
  end;
  if FDetailRowCache.Count >= CDetailRowCacheLimit then
    FDetailRowCache.Clear;
end;

procedure TThemedGridControlMasterDetail.ClearDetailRowCustomizationCache;
begin
  if FDetailRowCache.Count > 0 then
    FDetailRowCache.Clear;
end;

procedure TThemedGridControlMasterDetail.EnsureDetailRowCustomized(const ARowIndex: Integer;
  const AViewRow: TThemedGridViewRow);
var
  LDataVersion, LCurrentHeight, LNewHeight, LAutoHeight: Integer;
  LCacheKey, LDetailText, LGetterText: string;
  LEntry: TDetailRowCacheEntry;
  LParentRowObject: TValue;
  LTextArgs: TThemedGridDetailRowTextNeededEventArgs;
  LHeightArgs: TThemedGridDetailRowHeightNeededEventArgs;
  LChanged: Boolean;
begin
  if (AViewRow = nil) or not AViewRow.IsDetailRow then
    Exit;
  if DataController = nil then
    Exit;
  LDataVersion := DataController.Version;
  LCacheKey := CreateDetailRowCustomizationCacheKey(AViewRow, LDataVersion);
  if FDetailRowCache.TryGetValue(LCacheKey, LEntry) then
  begin
    LChanged := False;
    if AViewRow.DisplayText <> LEntry.DetailText then
    begin
      AViewRow.DisplayText := LEntry.DetailText;
      LChanged := True;
    end;
    if AViewRow.Height <> LEntry.Height then
    begin
      AViewRow.Height := LEntry.Height;
      LChanged := True;
    end;
    if RowView.DetailHeights.SetHeight(AViewRow.ParentDataSourceIndex, LEntry.Height) then
      LChanged := True;
    if LChanged then
    begin
      InvalidateRowTops;
      Invalidate;
    end;
    Exit;
  end;

  LParentRowObject := ResolveParentRowObject(AViewRow);
  LDetailText := AViewRow.DisplayText;
  if Assigned(DetailOptions.DetailTextGetter) then
  begin
    LGetterText := DetailOptions.DetailTextGetter(LParentRowObject);
    if LGetterText <> '' then
      LDetailText := LGetterText;
  end;

  LTextArgs := TThemedGridDetailRowTextNeededEventArgs.Create;
  try
    LTextArgs.ViewRowIndex := ARowIndex;
    LTextArgs.ParentDataSourceIndex := AViewRow.ParentDataSourceIndex;
    LTextArgs.ParentRowObject := LParentRowObject;
    LTextArgs.DetailText := LDetailText;
    DoDetailRowTextNeeded(LTextArgs);
    LDetailText := LTextArgs.DetailText;
  finally
    LTextArgs.Free;
  end;

  if AViewRow.Height > 0 then
    LCurrentHeight := AViewRow.Height
  else
    LCurrentHeight := DetailOptions.DetailRowHeight;

  LHeightArgs := TThemedGridDetailRowHeightNeededEventArgs.Create;
  try
    LHeightArgs.ViewRowIndex := ARowIndex;
    LHeightArgs.ParentDataSourceIndex := AViewRow.ParentDataSourceIndex;
    LHeightArgs.ParentRowObject := LParentRowObject;
    LHeightArgs.MinimumHeight := CDetailRowMinimumHeight;
    LHeightArgs.MaximumHeight := CDetailRowMaximumHeight;
    LHeightArgs.Height := LCurrentHeight;
    DoDetailRowHeightNeeded(LHeightArgs);
    LNewHeight := LHeightArgs.Height;
    if (LNewHeight = LCurrentHeight) and DetailOptions.AutoRowHeight and
      ComputeAutoDetailRowHeight(AViewRow, ARowIndex, LAutoHeight) then
      LNewHeight := Max(LAutoHeight, DetailOptions.DetailRowHeight);
  finally
    LHeightArgs.Free;
  end;
  if LNewHeight < CDetailRowMinimumHeight then
    LNewHeight := CDetailRowMinimumHeight;
  if LNewHeight > CDetailRowMaximumHeight then
    LNewHeight := CDetailRowMaximumHeight;

  LChanged := False;
  if AViewRow.DisplayText <> LDetailText then
  begin
    AViewRow.DisplayText := LDetailText;
    LChanged := True;
  end;
  if AViewRow.Height <> LNewHeight then
  begin
    AViewRow.Height := LNewHeight;
    LChanged := True;
  end;
  AViewRow.ParentRowObject := LParentRowObject;
  if RowView.DetailHeights.SetHeight(AViewRow.ParentDataSourceIndex, LNewHeight) then
    LChanged := True;
  AddDetailRowCustomizationCacheEntry(LCacheKey, LDetailText, LNewHeight, LDataVersion);
  if LChanged then
  begin
    InvalidateRowTops;
    Invalidate;
  end;
end;

function TThemedGridControlMasterDetail.DrawDetailContent(const AContext: TThemedGridRenderContext;
  const AViewRow: TThemedGridViewRow; const ARowIndex: Integer; const ABounds, AContentBounds: TRect;
  const AFocused: Boolean): Boolean;
var
  LArgs: TThemedGridDetailRowPaintEventArgs;
begin
  DetailPaintText := '';
  if AViewRow <> nil then
    DetailPaintText := AViewRow.DisplayText;
  if not Assigned(FOnDetailRowPaint) then
    Exit(False);
  LArgs := TThemedGridDetailRowPaintEventArgs.Create;
  try
    LArgs.Graphics := AContext.Graphics;
    LArgs.RenderContext := AContext;
    LArgs.ViewRowIndex := ARowIndex;
    LArgs.ParentDataSourceIndex := AViewRow.ParentDataSourceIndex;
    LArgs.ParentRowObject := ResolveParentRowObject(AViewRow);
    LArgs.Bounds := ABounds;
    LArgs.ContentBounds := AContentBounds;
    LArgs.DetailText := DetailPaintText;
    LArgs.Focused := AFocused;
    LArgs.Handled := False;
    DoDetailRowPaint(LArgs);
    DetailPaintText := LArgs.DetailText;
    Result := LArgs.Handled;
  finally
    LArgs.Free;
  end;
end;

function TThemedGridControlMasterDetail.GetMasterDetailRelationCount: Integer;
begin
  if DetailOptions = nil then
    Exit(1);
  Result := DetailOptions.GetEnabledRelationCount;
end;

function TThemedGridControlMasterDetail.GetMasterDetailRelationName(const AVisibleRelationIndex: Integer): string;
var
  LRelation: TThemedGridDetailRelation;
begin
  if DetailOptions = nil then
    Exit(ThemedGridMasterDetailStrings.DefaultRelationName);
  LRelation := DetailOptions.GetEnabledRelationByVisibleIndex(AVisibleRelationIndex);
  if (LRelation = nil) or (LRelation.Name = '') then
    Result := ThemedGridMasterDetailStrings.DefaultRelationName
  else
    Result := LRelation.Name;
end;

function TThemedGridControlMasterDetail.GetOrCreateMasterDetailData(const AViewRow: TThemedGridViewRow;
  const ARowIndex: Integer): TThemedGridMasterDetailData;
begin
  Result := GetOrCreateMasterDetailData(AViewRow, ARowIndex, 0, ThemedGridMasterDetailStrings.DefaultRelationName);
end;

function TThemedGridControlMasterDetail.GetOrCreateMasterDetailData(const AViewRow: TThemedGridViewRow;
  const ARowIndex, ARelationIndex: Integer; const ARelationName: string): TThemedGridMasterDetailData;
var
  LName: string;
  LRelationIndex, LDataVersion: Integer;
  LKey: TThemedGridMasterDetailCacheKey;
  LArgs: TThemedGridMasterDetailDataNeededEventArgs;
  LData: TThemedGridMasterDetailData;
begin
  Result := nil;
  if (AViewRow = nil) or not AViewRow.IsDetailRow or (AViewRow.ParentDataSourceIndex < 0) then
    Exit;
  if ARelationName = '' then
    LName := ThemedGridMasterDetailStrings.DefaultRelationName
  else
    LName := ARelationName;
  if ARelationIndex < 0 then
    LRelationIndex := 0
  else
    LRelationIndex := ARelationIndex;
  if DataController <> nil then
    LDataVersion := DataController.Version
  else
    LDataVersion := -1;
  LKey := TThemedGridMasterDetailCacheKey.Create(AViewRow.ParentDataSourceIndex, LRelationIndex, LName, LDataVersion);
  if FMasterDetailCache.TryGet(LKey, Result) then
    Exit;
  if not Assigned(FOnMasterDetailDataNeeded) then
    Exit(nil);
  AViewRow.ParentRowObject := ResolveParentRowObject(AViewRow);
  LArgs := TThemedGridMasterDetailDataNeededEventArgs.Create(AViewRow, ARowIndex, LRelationIndex, LName);
  try
    DoMasterDetailDataNeeded(LArgs);
    if not LArgs.Handled then
      Exit(nil);
    LData := LArgs.DetachData;
  finally
    LArgs.Free;
  end;
  LData.Handled := True;
  LData.RelationName := LName;
  FMasterDetailCache.Store(LKey, LData);
  Result := LData;
end;

function TThemedGridControlMasterDetail.CreateDetailItemsNeededEventArgs(const AViewRow: TThemedGridViewRow;
  const ARowIndex: Integer; const ABounds, AContentBounds: TRect;
  const ADetailText: string): TThemedGridDetailItemsNeededEventArgs;
begin
  Result := TThemedGridDetailItemsNeededEventArgs.Create;
  Result.ViewRowIndex := ARowIndex;
  if AViewRow <> nil then
  begin
    Result.ParentDataSourceIndex := AViewRow.ParentDataSourceIndex;
    Result.ParentRowObject := ResolveParentRowObject(AViewRow);
  end
  else
    Result.ParentDataSourceIndex := -1;
  Result.Bounds := ABounds;
  Result.ContentBounds := AContentBounds;
  Result.DetailText := ADetailText;
end;

procedure TThemedGridControlMasterDetail.MergeMasterDetailItems(const ATarget: TThemedGridDetailItemsNeededEventArgs;
  const AData: TThemedGridMasterDetailData);
var
  I: Integer;
begin
  if (ATarget = nil) or (AData = nil) or (AData.Items.Count = 0) then
    Exit;
  for I := 0 to AData.Items.Count - 1 do
    if AData.Items[I] <> nil then
      ATarget.Items.AddBorrowed(AData.Items[I]);
end;

function TThemedGridControlMasterDetail.BuildDetailItemsArgs(const AViewRow: TThemedGridViewRow;
  const ARowIndex: Integer; const ABounds, AContentBounds: TRect; const ADetailText: string;
  out ADefaultData: TThemedGridMasterDetailData): TThemedGridDetailItemsNeededEventArgs;
begin
  ADefaultData := GetOrCreateMasterDetailData(AViewRow, ARowIndex);
  Result := CreateDetailItemsNeededEventArgs(AViewRow, ARowIndex, ABounds, AContentBounds, ADetailText);
  try
    DoDetailItemsNeeded(Result);
    MergeMasterDetailItems(Result, ADefaultData);
  except
    Result.Free;
    raise;
  end;
end;

procedure TThemedGridControlMasterDetail.ApplyStoredDetailItemValues(const AArgs: TThemedGridDetailItemsNeededEventArgs);
var
  I: Integer;
  LItem: TThemedGridDetailItem;
  LValue: TValue;
begin
  if (AArgs = nil) or (AArgs.ParentDataSourceIndex < 0) then
    Exit;
  for I := 0 to AArgs.Items.Count - 1 do
  begin
    LItem := AArgs.Items[I];
    if (LItem = nil) or (LItem.Key = '') then
      Continue;
    if FDetailItemValueStore.TryGetValue(CreateDetailItemValueStoreKey(AArgs.ParentDataSourceIndex, LItem.Key),
      LValue) then
      LItem.Value := LValue;
  end;
end;

procedure TThemedGridControlMasterDetail.ArrangeDetailItems(const AArgs: TThemedGridDetailItemsNeededEventArgs);
var
  I, LX, LY, LRowBottom, LItemLeft, LItemTop, LItemWidth, LItemHeight: Integer;
  LItem: TThemedGridDetailItem;
begin
  if (AArgs = nil) or AArgs.ContentBounds.IsEmpty then
    Exit;
  LX := AArgs.ContentBounds.Left;
  LY := AArgs.ContentBounds.Top;
  LRowBottom := AArgs.ContentBounds.Bottom;
  for I := 0 to AArgs.Items.Count - 1 do
  begin
    LItem := AArgs.Items[I];
    if LItem = nil then
      Continue;
    LItem.Bounds := TRect.Empty;
    if not LItem.Visible then
      Continue;
    LItemLeft := AArgs.ContentBounds.Left + LItem.Left;
    if LItem.Left <= 0 then
      LItemLeft := LX;
    LItemTop := AArgs.ContentBounds.Top + LItem.Top;
    if LItem.Top <= 0 then
      LItemTop := LY;
    LItemWidth := LItem.Width;
    LItemHeight := LItem.Height;
    if LItemLeft + LItemWidth > AArgs.ContentBounds.Right then
    begin
      LItemLeft := AArgs.ContentBounds.Left;
      LItemTop := LY + LItemHeight + ScaleInt(CDetailItemSpacing);
      LY := LItemTop;
    end;
    if LItemTop + LItemHeight > LRowBottom then
      Break;
    LItem.Bounds := Rect(LItemLeft, LItemTop, LItemLeft + Max(1, LItemWidth), LItemTop + Max(1, LItemHeight));
    LX := LItem.Bounds.Right + LItem.RightMargin;
  end;
end;

function TThemedGridControlMasterDetail.GetDetailItemsBottom(const AArgs: TThemedGridDetailItemsNeededEventArgs): Integer;
var
  I: Integer;
  LItem: TThemedGridDetailItem;
begin
  if AArgs = nil then
    Exit(0);
  Result := AArgs.ContentBounds.Top;
  for I := 0 to AArgs.Items.Count - 1 do
  begin
    LItem := AArgs.Items[I];
    if (LItem = nil) or not LItem.Visible or LItem.Bounds.IsEmpty then
      Continue;
    if LItem.Bounds.Bottom > Result then
      Result := LItem.Bounds.Bottom;
  end;
end;

function TThemedGridControlMasterDetail.ComputeAutoDetailRowHeight(const AViewRow: TThemedGridViewRow;
  const ARowIndex: Integer; out AHeight: Integer): Boolean;
var
  LBounds, LContentBounds: TRect;
  LDefaultData, LRelationData: TThemedGridMasterDetailData;
  LItemsArgs: TThemedGridDetailItemsNeededEventArgs;
  LContentBottom, LRelationIndex, LRelationCount, LRows, LHeaderHeight: Integer;
  LRelationName: string;
  LOptions: TThemedGridDetailGridOptions;
  LHasGrid: Boolean;
begin
  AHeight := 0;
  Result := False;
  LBounds := Rect(0, 0, Max(ScaleInt(240), ClientWidth), ScaleInt(CDetailRowMaximumHeight));
  LContentBounds := GetDetailContentBounds(LBounds);
  if LContentBounds.IsEmpty then
    Exit;
  LItemsArgs := BuildDetailItemsArgs(AViewRow, ARowIndex, LBounds, LContentBounds, AViewRow.DisplayText, LDefaultData);
  try
    ApplyStoredDetailItemValues(LItemsArgs);
    ArrangeDetailItems(LItemsArgs);
    LContentBottom := LContentBounds.Top;
    LHasGrid := False;
    if LItemsArgs.Items.Count > 0 then
    begin
      LContentBottom := GetDetailItemsBottom(LItemsArgs);
      if LContentBottom > LContentBounds.Top then
        Inc(LContentBottom, ScaleInt(CDetailItemSpacing));
    end;
    LRelationCount := GetMasterDetailRelationCount;
    for LRelationIndex := 0 to LRelationCount - 1 do
    begin
      LRelationName := GetMasterDetailRelationName(LRelationIndex);
      if (LRelationIndex = 0) and (LDefaultData <> nil) and (LDefaultData.RelationName = LRelationName) then
        LRelationData := LDefaultData
      else
        LRelationData := GetOrCreateMasterDetailData(AViewRow, ARowIndex, LRelationIndex, LRelationName);
      if (LRelationData = nil) or not LRelationData.HasGridData or not LRelationData.GridOptions.Enabled then
        Continue;
      LOptions := LRelationData.GridOptions;
      LRows := GetDetailGridRowCount(LRelationData, CreateEmbeddedDetailGridKey(AViewRow.ParentDataSourceIndex,
        LRelationIndex, LRelationName));
      LRows := Max(1, Min(LRows, Max(1, LOptions.MaxVisibleRows)));
      if LOptions.HeaderVisible then
        LHeaderHeight := ScaleInt(LOptions.HeaderHeight)
      else
        LHeaderHeight := 0;
      Inc(LContentBottom, LHeaderHeight + LRows * ScaleInt(LOptions.RowHeight) + ScaleInt(LOptions.SpacingAfter) +
        ScaleInt(CDetailGridBottomSpacing));
      LHasGrid := True;
    end;
    if (LItemsArgs.Items.Count = 0) and not LHasGrid then
      Exit;
    AHeight := LContentBottom - LBounds.Top + (LBounds.Bottom - LContentBounds.Bottom);
    Result := True;
  finally
    LItemsArgs.Free;
  end;
end;

procedure TThemedGridControlMasterDetail.DrawDetailItems(const AContext: TThemedGridRenderContext;
  const AViewRow: TThemedGridViewRow; const ARowIndex: Integer; const AArgs: TThemedGridDetailItemsNeededEventArgs);
var
  I: Integer;
  LItem: TThemedGridDetailItem;
begin
  if (AContext = nil) or (AArgs = nil) or AArgs.ContentBounds.IsEmpty then
    Exit;
  ApplyStoredDetailItemValues(AArgs);
  ArrangeDetailItems(AArgs);
  for I := 0 to AArgs.Items.Count - 1 do
  begin
    LItem := AArgs.Items[I];
    if (LItem = nil) or not LItem.Visible or LItem.Bounds.IsEmpty then
      Continue;
    DrawDetailItem(AContext, AViewRow, ARowIndex, LItem, LItem.Bounds, I);
  end;
end;

procedure TThemedGridControlMasterDetail.DrawDetailItem(const AContext: TThemedGridRenderContext;
  const AViewRow: TThemedGridViewRow; const ARowIndex: Integer; const AItem: TThemedGridDetailItem;
  const ABounds: TRect; const AItemIndex: Integer);
var
  LState: TThemedGridCellState;
  LRenderer: IThemedGridCellRenderer;
  LBackColor: TThemeColor;
begin
  if (AContext = nil) or (AItem = nil) or (ABounds.Width <= 0) or (ABounds.Height <= 0) then
    Exit;
  FScratchColumn.Name := AItem.Key;
  FScratchColumn.FieldName := AItem.Key;
  FScratchColumn.HeaderText := AItem.Key;
  FScratchColumn.Width := ABounds.Width;
  FScratchColumn.RenderKind := AItem.RenderKind;
  FScratchColumn.TextAlignment := AItem.TextAlignment;
  FScratchColumn.ReadOnly := True;

  LState := [TThemedGridCellStateFlag.ReadOnly];
  if AItem.Enabled and (ARowIndex = FHoverDetailItemRowIndex) and (AItem.Key = FHoverDetailItemKey) then
    Include(LState, TThemedGridCellStateFlag.Hovered);
  if AItem.Enabled and (ARowIndex = FPressedDetailItemRowIndex) and (AItem.Key = FPressedDetailItemKey) then
    Include(LState, TThemedGridCellStateFlag.Pressed);
  if Focused then
    Include(LState, TThemedGridCellStateFlag.Focused);

  FScratchCell.RowIndex := ARowIndex;
  FScratchCell.ColumnIndex := AItemIndex;
  if AViewRow <> nil then
  begin
    FScratchCell.DataSourceIndex := AViewRow.ParentDataSourceIndex;
    FScratchCell.RowObject := AViewRow.ParentRowObject;
  end
  else
  begin
    FScratchCell.DataSourceIndex := -1;
    FScratchCell.RowObject := TValue.Empty;
  end;
  FScratchCell.Column := FScratchColumn;
  FScratchCell.Value := AItem.Value;
  FScratchCell.DisplayValue := AItem.Value;
  FScratchCell.DisplayText := AItem.Text;
  FScratchCell.Bounds := ABounds;
  FScratchCell.State := LState;
  FScratchCell.Tag := TValue.From<TObject>(AItem);

  if TryDrawDetailItemVisual(AContext, AViewRow, ARowIndex, AItem, ABounds, AItemIndex) then
    LRenderer := nil
  else
  begin
    LRenderer := Renderer.ResolveCellRenderer(FScratchCell);
    if LRenderer <> nil then
      LRenderer.Draw(AContext, FScratchCell);
  end;

  if not AItem.Enabled then
  begin
    if Palette <> nil then
      LBackColor := Palette.ControlBackColor
    else
      LBackColor := CFallbackBack;
    AContext.Graphics.FillRectangle(TThemedGridGdiCache.Brush(WithAlpha(LBackColor, CDetailDisabledAlpha)),
      ABounds.Left, ABounds.Top, ABounds.Width, ABounds.Height);
  end;
end;

function TThemedGridControlMasterDetail.TryDrawDetailItemVisual(const AContext: TThemedGridRenderContext;
  const AViewRow: TThemedGridViewRow; const ARowIndex: Integer; const AItem: TThemedGridDetailItem;
  const ABounds: TRect; const AItemIndex: Integer): Boolean;
var
  LArgs: TThemedGridDetailItemVisualNeededEventArgs;
  LRenderer: IThemedGridCellRenderer;
  LForeColor: TThemeColor;
  LStart, I: Integer;
begin
  Result := False;
  if not Assigned(FOnDetailItemVisualNeeded) then
    Exit;
  ResetRenderVisual(AItem.Text, Max(1, Min(ScaleInt(24), Max(1, ABounds.Height - ScaleInt(8)))), ScaleInt(4),
    AItem.Enabled);
  RenderVisual.ToolTip := AItem.ToolTipText;
  LArgs := TThemedGridDetailItemVisualNeededEventArgs.Create(ARowIndex, AViewRow, AItem, AItemIndex, RenderVisual);
  try
    DoDetailItemVisualNeeded(LArgs);
    if not LArgs.Handled then
      Exit;
  finally
    LArgs.Free;
  end;
  FScratchColumn.RenderKind := TThemedGridCellRenderKind.Text;
  FScratchCell.DisplayText := '';
  FScratchCell.DisplayValue := TValue.Empty;
  FScratchCell.Value := TValue.Empty;
  LRenderer := Renderer.ResolveCellRenderer(FScratchCell);
  if LRenderer <> nil then
    LRenderer.Draw(AContext, FScratchCell);
  if AItem.Enabled then
    LForeColor := TThemedGridCellRendererParts.GetCellForeColor(AContext, FScratchCell)
  else if Palette <> nil then
    LForeColor := Palette.MutedForeColor
  else
    LForeColor := CFallbackMuted;
  LStart := VisualHitInfos.Count;
  DrawRenderVisual(AContext, ABounds, LForeColor, AItem.Enabled, ARowIndex, AItemIndex, False, True);
  for I := LStart to VisualHitInfos.Count - 1 do
    if VisualHitInfos[I].Tag.TypeInfo = nil then
      VisualHitInfos[I].Tag := AItem.Tag;
  Result := True;
end;

procedure TThemedGridControlMasterDetail.EmbeddedDetailGridCellVisualNeeded(ASender: TObject;
  const AArgs: TThemedGridCellVisualNeededEventArgs);
var
  LGrid: TThemedGridControlMasterDetail;
  LContext: TEmbeddedContext;
  LColumn: TThemedGridDetailGridColumn;
  LBounds: TRect;
  LVisualArgs: TThemedGridDetailGridCellVisualNeededEventArgs;
begin
  if not Assigned(FOnDetailGridCellVisualNeeded) or (AArgs = nil) or (AArgs.Visual = nil) then
    Exit;
  LGrid := ASender as TThemedGridControlMasterDetail;
  if not FEmbeddedContexts.TryGetValue(LGrid, LContext) then
    Exit;
  if (AArgs.Column = nil) or (AArgs.Column.Tag.TypeInfo = nil) or not AArgs.Column.Tag.IsObject then
    Exit;
  if not (AArgs.Column.Tag.AsObject is TThemedGridDetailGridColumn) then
    Exit;
  LColumn := TThemedGridDetailGridColumn(AArgs.Column.Tag.AsObject);
  LBounds := Rect(LGrid.Left + AArgs.Bounds.Left, LGrid.Top + AArgs.Bounds.Top, LGrid.Left + AArgs.Bounds.Right,
    LGrid.Top + AArgs.Bounds.Bottom);
  LVisualArgs := TThemedGridDetailGridCellVisualNeededEventArgs.Create(ResolveContextViewRow(LContext),
    LContext.ViewRowIndex, LContext.ParentDataSourceIndex, LContext.ParentRowObject, LContext.RelationName,
    LContext.RelationIndex, AArgs.DataSourceIndex, AArgs.ColumnIndex, AArgs.RowObject, AArgs.Value, LColumn,
    LBounds, AArgs.Visual);
  try
    DoDetailGridCellVisualNeeded(LVisualArgs);
    if LVisualArgs.Handled then
      AArgs.Handled := True;
  finally
    LVisualArgs.Free;
  end;
end;

procedure TThemedGridControlMasterDetail.DoDetailItemVisualNeeded(
  const AArgs: TThemedGridDetailItemVisualNeededEventArgs);
begin
  if Assigned(FOnDetailItemVisualNeeded) then
    FOnDetailItemVisualNeeded(Self, AArgs);
end;

procedure TThemedGridControlMasterDetail.DoDetailGridCellVisualNeeded(
  const AArgs: TThemedGridDetailGridCellVisualNeededEventArgs);
begin
  if Assigned(FOnDetailGridCellVisualNeeded) then
    FOnDetailGridCellVisualNeeded(Self, AArgs);
end;

procedure TThemedGridControlMasterDetail.DoDetailGridHeaderVisualNeeded(
  const AArgs: TThemedGridDetailGridHeaderVisualNeededEventArgs);
begin
  if Assigned(FOnDetailGridHeaderVisualNeeded) then
    FOnDetailGridHeaderVisualNeeded(Self, AArgs);
end;

procedure TThemedGridControlMasterDetail.DrawDetailBody(const AContext: TThemedGridRenderContext;
  const AViewRow: TThemedGridViewRow; const ARowIndex: Integer; const ABounds, AContentBounds: TRect;
  const ADetailText: string);
var
  LDefaultData, LRelationData: TThemedGridMasterDetailData;
  LItemsArgs: TThemedGridDetailItemsNeededEventArgs;
  LText: string;
  LForeColor: TThemeColor;
  LDetailGridTop, LRelationTop, LRelationCount, LRelationIndex: Integer;
  LRelationName: string;
  LHasAnyDetailGrid: Boolean;
begin
  if (AContext = nil) or (AViewRow = nil) then
    Exit;
  LItemsArgs := BuildDetailItemsArgs(AViewRow, ARowIndex, ABounds, AContentBounds, ADetailText, LDefaultData);
  try
    LDetailGridTop := AContentBounds.Top;
    if LItemsArgs.Items.Count > 0 then
    begin
      DrawDetailItems(AContext, AViewRow, ARowIndex, LItemsArgs);
      LDetailGridTop := GetDetailItemsBottom(LItemsArgs) + ScaleInt(CDetailItemSpacing);
    end
    else
    begin
      LText := ADetailText;
      if (LText = '') and (LDefaultData <> nil) then
        LText := LDefaultData.EmptyText;
      if (LText <> '') and ((LDefaultData = nil) or not LDefaultData.HasGridData) then
      begin
        if Palette <> nil then
          LForeColor := Palette.MutedForeColor
        else
          LForeColor := CFallbackMuted;
        TThemedGridGdiText.DrawText(AContext, LText, Font, AContentBounds, LForeColor,
          TThemedGridContentAlignment.TopLeft, True);
      end;
    end;

    LHasAnyDetailGrid := False;
    LRelationTop := LDetailGridTop;
    LRelationCount := GetMasterDetailRelationCount;
    for LRelationIndex := 0 to LRelationCount - 1 do
    begin
      LRelationName := GetMasterDetailRelationName(LRelationIndex);
      if (LRelationIndex = 0) and (LDefaultData <> nil) and (LDefaultData.RelationName = LRelationName) then
        LRelationData := LDefaultData
      else
        LRelationData := GetOrCreateMasterDetailData(AViewRow, ARowIndex, LRelationIndex, LRelationName);
      if (LRelationData = nil) or not LRelationData.HasGridData then
        Continue;
      LHasAnyDetailGrid := True;
      LRelationTop := EnsureEmbeddedMasterDetailGrid(AViewRow, ARowIndex, LRelationIndex, LRelationName,
        LRelationData, Rect(AContentBounds.Left, LRelationTop, AContentBounds.Right, AContentBounds.Bottom));
      if LRelationTop >= AContentBounds.Bottom - ScaleInt(CDetailGridMinimumRemaining) then
        Break;
    end;
    if not LHasAnyDetailGrid then
      HideEmbeddedMasterDetailGrid(AViewRow);
  finally
    LItemsArgs.Free;
  end;
end;

function TThemedGridControlMasterDetail.TryGetDetailItemAt(const ADetailRowIndex: Integer; const ALocation: TPoint;
  out AArgs: TThemedGridDetailItemsNeededEventArgs; out AItem: TThemedGridDetailItem): Boolean;
var
  LViewRow: TThemedGridViewRow;
  LBounds, LContentBounds: TRect;
  LData: TThemedGridMasterDetailData;
  I: Integer;
  LCandidate: TThemedGridDetailItem;
begin
  AArgs := nil;
  AItem := nil;
  Result := False;
  LViewRow := GetViewRow(ADetailRowIndex);
  if (LViewRow = nil) or not LViewRow.IsDetailRow then
    Exit;
  LBounds := GetRowBounds(ADetailRowIndex);
  if LBounds.IsEmpty or not LBounds.Contains(ALocation) then
    Exit;
  LContentBounds := GetDetailContentBounds(LBounds);
  AArgs := BuildDetailItemsArgs(LViewRow, ADetailRowIndex, LBounds, LContentBounds, LViewRow.DisplayText, LData);
  if AArgs.Items.Count = 0 then
  begin
    FreeAndNil(AArgs);
    Exit;
  end;
  ApplyStoredDetailItemValues(AArgs);
  ArrangeDetailItems(AArgs);
  for I := 0 to AArgs.Items.Count - 1 do
  begin
    LCandidate := AArgs.Items[I];
    if (LCandidate = nil) or not LCandidate.Visible or LCandidate.Bounds.IsEmpty then
      Continue;
    if LCandidate.Bounds.Contains(ALocation) then
    begin
      AItem := LCandidate;
      Exit(True);
    end;
  end;
  FreeAndNil(AArgs);
end;

procedure TThemedGridControlMasterDetail.ClearDetailItemPressedState;
var
  LOldRow: Integer;
begin
  LOldRow := FPressedDetailItemRowIndex;
  FPressedDetailItemRowIndex := -1;
  FPressedDetailItemKey := '';
  if LOldRow >= 0 then
    InvalidateRow(LOldRow);
  if MouseCapture and not DragSelecting and not DraggingColumnHeader and not DraggingVerticalScrollThumb and
    not DraggingHorizontalScrollThumb then
    MouseCapture := False;
end;

procedure TThemedGridControlMasterDetail.UpdateDetailItemToolTip(const ARowIndex: Integer;
  const AItem: TThemedGridDetailItem; const ALocation: TPoint);
begin
  if (AItem = nil) or (AItem.ToolTipText = '') then
  begin
    HideCellToolTip;
    Exit;
  end;
  ShowToolTipFor(ARowIndex, -1, AItem.Key, AItem.ToolTipText, ALocation);
end;

procedure TThemedGridControlMasterDetail.SetHoverDetailItem(const ARowIndex: Integer; const AKey: string);
var
  LOldRow: Integer;
  LOldKey: string;
begin
  LOldRow := FHoverDetailItemRowIndex;
  LOldKey := FHoverDetailItemKey;
  FHoverDetailItemRowIndex := ARowIndex;
  FHoverDetailItemKey := AKey;
  if (LOldRow <> ARowIndex) or (LOldKey <> AKey) then
  begin
    if LOldRow >= 0 then
      InvalidateRow(LOldRow);
    if (ARowIndex >= 0) and (ARowIndex <> LOldRow) then
      InvalidateRow(ARowIndex);
  end;
end;

function TThemedGridControlMasterDetail.CreateDetailItemEventArgs(const ADetailRowIndex: Integer;
  const AItem: TThemedGridDetailItem; const AButton: TMouseButton; const AClicks: Integer;
  const ALocation: TPoint): TThemedGridDetailItemEventArgs;
var
  LViewRow: TThemedGridViewRow;
  LBoolean: Boolean;
begin
  Result := TThemedGridDetailItemEventArgs.Create;
  LViewRow := GetViewRow(ADetailRowIndex);
  Result.ViewRowIndex := ADetailRowIndex;
  if LViewRow <> nil then
  begin
    Result.ParentDataSourceIndex := LViewRow.ParentDataSourceIndex;
    Result.ParentRowObject := ResolveParentRowObject(LViewRow);
  end
  else
    Result.ParentDataSourceIndex := -1;
  Result.Item := AItem;
  if AItem <> nil then
  begin
    Result.ItemKey := AItem.Key;
    Result.Value := AItem.Value;
    Result.Bounds := AItem.Bounds;
  end;
  Result.Button := MouseButtonSet(AButton);
  Result.Clicks := AClicks;
  Result.Location := ALocation;
  Result.Delta := 0;
  if (AItem <> nil) and AItem.ToggleOnClick and
    ((AItem.RenderKind = TThemedGridCellRenderKind.CheckBox) or
     (AItem.RenderKind = TThemedGridCellRenderKind.Toggle)) then
  begin
    if not TThemedGridValueFormatter.TryGetBoolean(AItem.Value, LBoolean) then
      LBoolean := False;
    Result.NewValue := TValue.From<Boolean>(not LBoolean);
    Result.HasNewValue := True;
  end;
end;

procedure TThemedGridControlMasterDetail.ApplyDetailItemNewValue(const AItemArgs: TThemedGridDetailItemEventArgs);
var
  LChanging: TThemedGridDetailItemValueChangingEventArgs;
  LChanged: TThemedGridDetailItemValueChangedEventArgs;
  LOldValue, LFinalValue: TValue;
begin
  if (AItemArgs = nil) or not AItemArgs.HasNewValue or (AItemArgs.Item = nil) then
    Exit;
  LOldValue := AItemArgs.Value;
  LChanging := TThemedGridDetailItemValueChangingEventArgs.Create;
  try
    LChanging.ViewRowIndex := AItemArgs.ViewRowIndex;
    LChanging.ParentDataSourceIndex := AItemArgs.ParentDataSourceIndex;
    LChanging.ParentRowObject := AItemArgs.ParentRowObject;
    LChanging.Item := AItemArgs.Item;
    LChanging.ItemKey := AItemArgs.ItemKey;
    LChanging.OldValue := LOldValue;
    LChanging.NewValue := AItemArgs.NewValue;
    LChanging.Bounds := AItemArgs.Bounds;
    LChanging.Cancel := False;
    DoDetailItemValueChanging(LChanging);
    if LChanging.Cancel then
      Exit;
    LFinalValue := LChanging.NewValue;
  finally
    LChanging.Free;
  end;
  SetDetailItemValue(AItemArgs.ParentDataSourceIndex, AItemArgs.ItemKey, LFinalValue);
  LChanged := TThemedGridDetailItemValueChangedEventArgs.Create;
  try
    LChanged.ViewRowIndex := AItemArgs.ViewRowIndex;
    LChanged.ParentDataSourceIndex := AItemArgs.ParentDataSourceIndex;
    LChanged.ParentRowObject := AItemArgs.ParentRowObject;
    LChanged.Item := AItemArgs.Item;
    LChanged.ItemKey := AItemArgs.ItemKey;
    LChanged.OldValue := LOldValue;
    LChanged.NewValue := LFinalValue;
    LChanged.Bounds := AItemArgs.Bounds;
    DoDetailItemValueChanged(LChanged);
  finally
    LChanged.Free;
  end;
end;

function TThemedGridControlMasterDetail.IsDetailItemAction(const AItem: TThemedGridDetailItem): Boolean;
begin
  if (AItem = nil) or not AItem.Enabled then
    Exit(False);
  Result := Assigned(AItem.Action) or (AItem.RenderKind = TThemedGridCellRenderKind.Button);
end;

procedure TThemedGridControlMasterDetail.InvokeDetailItemAction(const AItemArgs: TThemedGridDetailItemEventArgs);
var
  LActionArgs: TThemedGridDetailItemActionEventArgs;
  LContext: TThemedGridDetailItemActionContext;
  LHandled: Boolean;
begin
  if (AItemArgs = nil) or (AItemArgs.Item = nil) then
    Exit;
  LActionArgs := TThemedGridDetailItemActionEventArgs.Create;
  try
    LActionArgs.ViewRowIndex := AItemArgs.ViewRowIndex;
    LActionArgs.ParentDataSourceIndex := AItemArgs.ParentDataSourceIndex;
    LActionArgs.ParentRowObject := AItemArgs.ParentRowObject;
    LActionArgs.Item := AItemArgs.Item;
    LActionArgs.ItemKey := AItemArgs.ItemKey;
    LActionArgs.Value := AItemArgs.Value;
    LActionArgs.Bounds := AItemArgs.Bounds;
    LActionArgs.Button := AItemArgs.Button;
    LActionArgs.Location := AItemArgs.Location;
    LActionArgs.Tag := AItemArgs.Item.Tag;
    LActionArgs.Handled := False;
    DoDetailItemAction(LActionArgs);
    LHandled := LActionArgs.Handled;
  finally
    LActionArgs.Free;
  end;
  if LHandled then
  begin
    AItemArgs.Handled := True;
    Exit;
  end;
  if Assigned(AItemArgs.Item.Action) then
  begin
    LContext := TThemedGridDetailItemActionContext.Create;
    try
      LContext.Grid := Self;
      LContext.ViewRowIndex := AItemArgs.ViewRowIndex;
      LContext.ParentDataSourceIndex := AItemArgs.ParentDataSourceIndex;
      LContext.ParentRowObject := AItemArgs.ParentRowObject;
      LContext.Item := AItemArgs.Item;
      LContext.ItemKey := AItemArgs.ItemKey;
      LContext.Value := AItemArgs.Value;
      LContext.Bounds := AItemArgs.Bounds;
      if mbLeft in AItemArgs.Button then
        LContext.Button := mbLeft
      else if mbRight in AItemArgs.Button then
        LContext.Button := mbRight
      else
        LContext.Button := mbMiddle;
      LContext.Location := AItemArgs.Location;
      LContext.Tag := AItemArgs.Item.Tag;
      LContext.Handled := False;
      AItemArgs.Item.Action(LContext);
      if LContext.Handled or AItemArgs.Item.AutoHandleAction then
        AItemArgs.Handled := True;
    finally
      LContext.Free;
    end;
  end;
end;

function TThemedGridControlMasterDetail.DetailRowMouseDown(const AHit: TThemedGridHitInfo; const AButton: TMouseButton;
  const ALocation: TPoint): Boolean;
var
  LArgs: TThemedGridDetailItemsNeededEventArgs;
  LItem: TThemedGridDetailItem;
begin
  Result := False;
  if (AButton <> mbLeft) or (AHit = nil) or (AHit.RowIndex < 0) then
    Exit;
  if not TryGetDetailItemAt(AHit.RowIndex, ALocation, LArgs, LItem) then
    Exit;
  try
    if not LItem.Enabled then
      Exit;
    FPressedDetailItemRowIndex := AHit.RowIndex;
    FPressedDetailItemKey := LItem.Key;
    MouseCapture := True;
    InvalidateRow(AHit.RowIndex);
    Result := True;
  finally
    LArgs.Free;
  end;
end;

function TThemedGridControlMasterDetail.DetailRowMouseUp(const AHit: TThemedGridHitInfo; const AButton: TMouseButton;
  const ALocation: TPoint): Boolean;
var
  LPressedRow: Integer;
  LPressedKey: string;
  LArgs: TThemedGridDetailItemsNeededEventArgs;
  LItem: TThemedGridDetailItem;
  LItemArgs: TThemedGridDetailItemEventArgs;
begin
  if FPressedDetailItemRowIndex < 0 then
    Exit(False);
  Result := True;
  LPressedRow := FPressedDetailItemRowIndex;
  LPressedKey := FPressedDetailItemKey;
  ClearDetailItemPressedState;
  if (AHit <> nil) and AHit.IsDetailRow and (AHit.RowIndex = LPressedRow) and
    TryGetDetailItemAt(AHit.RowIndex, ALocation, LArgs, LItem) then
  begin
    try
      if LItem.Enabled and (LItem.Key = LPressedKey) then
      begin
        LItemArgs := CreateDetailItemEventArgs(AHit.RowIndex, LItem, AButton, 1, ALocation);
        try
          DoDetailItemClick(LItemArgs);
          if LItemArgs.HasNewValue then
            ApplyDetailItemNewValue(LItemArgs);
          if not LItemArgs.Handled and IsDetailItemAction(LItem) then
            InvokeDetailItemAction(LItemArgs);
        finally
          LItemArgs.Free;
        end;
        InvalidateRow(AHit.RowIndex);
        Exit;
      end;
    finally
      LArgs.Free;
    end;
  end;
  InvalidateRow(LPressedRow);
end;

function TThemedGridControlMasterDetail.DetailRowMouseMove(const AHit: TThemedGridHitInfo;
  const ALocation: TPoint): Boolean;
var
  LArgs: TThemedGridDetailItemsNeededEventArgs;
  LItem: TThemedGridDetailItem;
  LCursor: TCursor;
begin
  Result := False;
  if (AHit = nil) or (AHit.RowIndex < 0) then
  begin
    SetHoverDetailItem(-1, '');
    Exit;
  end;
  if TryGetDetailItemAt(AHit.RowIndex, ALocation, LArgs, LItem) then
  begin
    try
      SetHoverDetailItem(AHit.RowIndex, LItem.Key);
      if LItem.Enabled then
        LCursor := crHandPoint
      else
        LCursor := crDefault;
      if Cursor <> LCursor then
        Cursor := LCursor;
      UpdateDetailItemToolTip(AHit.RowIndex, LItem, ALocation);
      Result := True;
    finally
      LArgs.Free;
    end;
  end
  else
    SetHoverDetailItem(-1, '');
end;

function TThemedGridControlMasterDetail.DetailRowDoubleClick(const AHit: TThemedGridHitInfo;
  const ALocation: TPoint): Boolean;
var
  LArgs: TThemedGridDetailItemsNeededEventArgs;
  LItem: TThemedGridDetailItem;
  LItemArgs: TThemedGridDetailItemEventArgs;
begin
  Result := False;
  if (AHit = nil) or (AHit.RowIndex < 0) then
    Exit;
  if not TryGetDetailItemAt(AHit.RowIndex, ALocation, LArgs, LItem) then
    Exit;
  try
    if not LItem.Enabled then
      Exit;
    LItemArgs := CreateDetailItemEventArgs(AHit.RowIndex, LItem, mbLeft, 2, ALocation);
    try
      DoDetailItemDoubleClick(LItemArgs);
      if LItemArgs.Handled then
      begin
        Invalidate;
        Result := True;
      end;
    finally
      LItemArgs.Free;
    end;
  finally
    LArgs.Free;
  end;
end;

procedure TThemedGridControlMasterDetail.DetailRowMouseLeave;
var
  LHoverRow, LPressedRow: Integer;
begin
  LHoverRow := FHoverDetailItemRowIndex;
  LPressedRow := FPressedDetailItemRowIndex;
  FHoverDetailItemRowIndex := -1;
  FHoverDetailItemKey := '';
  FPressedDetailItemRowIndex := -1;
  FPressedDetailItemKey := '';
  if LHoverRow >= 0 then
    InvalidateRow(LHoverRow);
  if (LPressedRow >= 0) and (LPressedRow <> LHoverRow) then
    InvalidateRow(LPressedRow);
end;

function TThemedGridControlMasterDetail.GetDetailItemValue(const AParentDataSourceIndex: Integer;
  const AItemKey: string; const ADefaultValue: TValue): TValue;
begin
  if not FDetailItemValueStore.TryGetValue(CreateDetailItemValueStoreKey(AParentDataSourceIndex, AItemKey),
    Result) then
    Result := ADefaultValue;
end;

procedure TThemedGridControlMasterDetail.SetDetailItemValue(const AParentDataSourceIndex: Integer;
  const AItemKey: string; const AValue: TValue);
begin
  FDetailItemValueStore.AddOrSetValue(CreateDetailItemValueStoreKey(AParentDataSourceIndex, AItemKey), AValue);
  InvalidateRowView;
  Invalidate;
end;

procedure TThemedGridControlMasterDetail.ClearDetailItemValues;
begin
  if FDetailItemValueStore.Count = 0 then
    Exit;
  FDetailItemValueStore.Clear;
  InvalidateRowView;
  Invalidate;
end;

procedure TThemedGridControlMasterDetail.ClearDetailItemValues(const AParentDataSourceIndex: Integer);
var
  LPrefix: string;
  LKeys: TList<string>;
  LKey: string;
  I: Integer;
begin
  if (AParentDataSourceIndex < 0) or (FDetailItemValueStore.Count = 0) then
    Exit;
  LPrefix := IntToStr(AParentDataSourceIndex) + '|';
  LKeys := TList<string>.Create;
  try
    for LKey in FDetailItemValueStore.Keys do
      if LKey.StartsWith(LPrefix, False) then
        LKeys.Add(LKey);
    for I := 0 to LKeys.Count - 1 do
      FDetailItemValueStore.Remove(LKeys[I]);
    if LKeys.Count > 0 then
    begin
      InvalidateRowView;
      Invalidate;
    end;
  finally
    LKeys.Free;
  end;
end;

procedure TThemedGridControlMasterDetail.ClearMasterDetailDataCache;
begin
  ClearMasterDetailDataCacheCore;
  InvalidateRowView;
  ClearSummaryCache;
  NormalizeScrollValues;
  DoRowsChanged;
  Invalidate;
end;

procedure TThemedGridControlMasterDetail.RefreshMasterDetailData(const AParentDataSourceIndex: Integer);
begin
  if AParentDataSourceIndex < 0 then
    Exit;
  RemoveEmbeddedDetailGridByDataSourceIndex(AParentDataSourceIndex);
  FMasterDetailCache.ClearForParentDataSourceIndex(AParentDataSourceIndex);
  InvalidateRowView;
  ClearSummaryCache;
  NormalizeScrollValues;
  DoRowsChanged;
  Invalidate;
end;

function TThemedGridControlMasterDetail.GetMasterDetailRelationIndexForEmbedded(const AKey: string): Integer;
var
  LContext: TEmbeddedContext;
  LGrid: TThemedGridControlMasterDetail;
begin
  Result := 0;
  if FEmbeddedGrids.TryGetValue(AKey, LGrid) and FEmbeddedContexts.TryGetValue(LGrid, LContext) then
    Result := LContext.RelationIndex;
end;

function TThemedGridControlMasterDetail.CreateEmbeddedDetailGridKey(const AParentDataSourceIndex,
  ARelationIndex: Integer; const ARelationName: string): string;
var
  LName: string;
  LDataVersion: Integer;
begin
  if ARelationName = '' then
    LName := ThemedGridMasterDetailStrings.DefaultRelationName
  else
    LName := ARelationName;
  if DataController <> nil then
    LDataVersion := DataController.Version
  else
    LDataVersion := -1;
  Result := IntToStr(LDataVersion) + '|' + IntToStr(AParentDataSourceIndex) + '|' + IntToStr(ARelationIndex) +
    '|' + LName;
end;

procedure TThemedGridControlMasterDetail.BuildAutoDetailGridColumns(const AData: TThemedGridMasterDetailData);
var
  LGenerated: TList<TThemedGridColumn>;
  LSource: TThemedGridColumn;
  LColumn: TThemedGridDetailGridColumn;
  I: Integer;
begin
  LGenerated := TThemedGridDataSourceResolver.CreateColumns(AData.GridDataSource);
  try
    for I := 0 to LGenerated.Count - 1 do
    begin
      LSource := LGenerated[I];
      LColumn := AData.AutoColumns.Add(LSource.Name, LSource.HeaderText, LSource.FieldName);
      LColumn.Width := CThemedGridDetailGridColumnDefaultWidth;
      LColumn.AutoWidth := I = LGenerated.Count - 1;
      LColumn.RenderKind := LSource.RenderKind;
    end;
    AData.AutoColumnsResolved := AData.AutoColumns.Count > 0;
  finally
    for I := 0 to LGenerated.Count - 1 do
      LGenerated[I].Free;
    LGenerated.Free;
  end;
end;

function TThemedGridControlMasterDetail.GetDetailGridColumns(
  const AData: TThemedGridMasterDetailData): TThemedGridDetailGridColumnCollection;
begin
  if AData = nil then
    Exit(nil);
  if AData.GridColumns.Count > 0 then
    Exit(AData.GridColumns);
  if not AData.GridOptions.AutoGenerateColumns then
    Exit(nil);
  if not AData.AutoColumnsResolved then
    BuildAutoDetailGridColumns(AData);
  Result := AData.AutoColumns;
end;

function TThemedGridControlMasterDetail.GetDetailGridRowCount(const AData: TThemedGridMasterDetailData;
  const AKey: string): Integer;
var
  LGrid: TThemedGridControlMasterDetail;
  LController: IThemedGridDataController;
begin
  if FEmbeddedGrids.TryGetValue(AKey, LGrid) then
    Exit(LGrid.RowCount);
  LController := TThemedGridDataSourceResolver.Resolve(AData.GridDataSource);
  if LController = nil then
    Result := 0
  else
    Result := LController.RowCount;
end;

function TThemedGridControlMasterDetail.ComputeEmbeddedGridBounds(const AData: TThemedGridMasterDetailData;
  const ARowCount: Integer; const AAvailable: TRect; out ABounds: TRect): Boolean;
var
  LOptions: TThemedGridDetailGridOptions;
  LLeft, LRight, LRowHeight, LHeaderHeight, LVisibleRows, LHeight, LColumnsWidth, LDesiredRight, I: Integer;
  LColumns: TThemedGridDetailGridColumnCollection;
begin
  Result := False;
  ABounds := TRect.Empty;
  LOptions := AData.GridOptions;
  LLeft := AAvailable.Left + ScaleInt(LOptions.Indent);
  LRight := AAvailable.Right;
  if LRight <= LLeft + ScaleInt(CDetailGridMinimumWidth) then
    Exit;
  LRowHeight := ScaleInt(LOptions.RowHeight);
  if LOptions.HeaderVisible then
    LHeaderHeight := ScaleInt(LOptions.HeaderHeight)
  else
    LHeaderHeight := 0;
  LVisibleRows := Min(ARowCount, Max(1, LOptions.MaxVisibleRows));
  LColumns := GetDetailGridColumns(AData);
  if LColumns <> nil then
  begin
    LColumnsWidth := 0;
    for I := 0 to LColumns.Count - 1 do
      if (LColumns[I] <> nil) and LColumns[I].Visible then
        Inc(LColumnsWidth, ScaleInt(LColumns[I].Width));
    if ARowCount > Max(1, LOptions.MaxVisibleRows) then
      Inc(LColumnsWidth, Metrics.ScrollBarSize);
    LDesiredRight := LLeft + LColumnsWidth + ScaleInt(2);
    if (LColumnsWidth > 0) and (LDesiredRight < LRight) then
      LRight := Max(LDesiredRight, LLeft + ScaleInt(CDetailGridMinimumWidth) + 1);
  end;
  LHeight := LHeaderHeight + Max(1, LVisibleRows) * LRowHeight;
  if ARowCount = 0 then
    LHeight := LHeaderHeight + LRowHeight;
  Inc(LHeight, ScaleInt(LOptions.SpacingAfter));
  if LHeight > AAvailable.Height then
    LHeight := AAvailable.Height;
  if LHeight <= ScaleInt(CDetailGridMinimumHeight) then
    Exit;
  ABounds := Rect(LLeft, AAvailable.Top, LRight, AAvailable.Top + LHeight);
  Result := True;
end;

function TThemedGridControlMasterDetail.EnsureEmbeddedMasterDetailGrid(const AViewRow: TThemedGridViewRow;
  const ARowIndex, ARelationIndex: Integer; const ARelationName: string; const AData: TThemedGridMasterDetailData;
  const AAvailable: TRect): Integer;
var
  LColumns: TThemedGridDetailGridColumnCollection;
  LName, LKey: string;
  LBounds: TRect;
  LGrid: TThemedGridControlMasterDetail;
  LContext: TEmbeddedContext;
  LIsNew: Boolean;
begin
  Result := AAvailable.Top;
  if (AViewRow = nil) or (AData = nil) or not AData.HasGridData or not AData.GridOptions.Enabled or
    AAvailable.IsEmpty then
    Exit;
  LColumns := GetDetailGridColumns(AData);
  if (LColumns = nil) or (LColumns.Count = 0) then
    Exit;
  if ARelationName = '' then
    LName := ThemedGridMasterDetailStrings.DefaultRelationName
  else
    LName := ARelationName;
  LKey := CreateEmbeddedDetailGridKey(AViewRow.ParentDataSourceIndex, ARelationIndex, LName);
  if not ComputeEmbeddedGridBounds(AData, GetDetailGridRowCount(AData, LKey), AAvailable, LBounds) then
    Exit;
  FVisibleEmbeddedKeys.Add(LKey);

  LIsNew := False;
  if not FEmbeddedGrids.TryGetValue(LKey, LGrid) then
  begin
    LGrid := RentEmbeddedDetailGrid;
    FEmbeddedGrids.Add(LKey, LGrid);
    LIsNew := True;
  end;
  if LGrid.Parent <> Self then
    LGrid.Parent := Self;

  if not FEmbeddedContexts.TryGetValue(LGrid, LContext) then
  begin
    LContext := TEmbeddedContext.Create;
    FEmbeddedContexts.Add(LGrid, LContext);
  end;
  LContext.Key := LKey;
  LContext.ViewRowIndex := ARowIndex;
  LContext.ParentDataSourceIndex := AViewRow.ParentDataSourceIndex;
  LContext.ParentRowObject := AViewRow.ParentRowObject;
  LContext.RelationName := LName;
  LContext.RelationIndex := ARelationIndex;
  if DataController <> nil then
    LContext.DataVersion := DataController.Version
  else
    LContext.DataVersion := -1;

  if LIsNew then
    ConfigureEmbeddedDetailGrid(LGrid, AData, LColumns);
  if (LGrid.Left <> LBounds.Left) or (LGrid.Top <> LBounds.Top) or (LGrid.Width <> LBounds.Width) or
    (LGrid.Height <> LBounds.Height) then
    LGrid.SetBounds(LBounds.Left, LBounds.Top, LBounds.Width, LBounds.Height);
  if not LGrid.Visible then
    LGrid.Visible := True;
  Result := LBounds.Bottom + ScaleInt(CDetailGridBottomSpacing);
end;

function TThemedGridControlMasterDetail.CreateEmbeddedDetailGrid: TThemedGridControlMasterDetail;
begin
  Result := TThemedGridControlMasterDetailClass(ClassType).Create(Self);
  Result.AutoGenerateColumns := False;
  Result.ShowRowHeaders := False;
  Result.ShowColumnBandHeaders := False;
  Result.ShowVerticalScrollBar := True;
  Result.ShowHorizontalScrollBar := True;
  Result.DetailOptions.Enabled := False;
  Result.TabStop := False;
  Result.Visible := False;
  Result.OnCellClick := EmbeddedDetailGridCellClick;
  Result.OnCellDoubleClick := EmbeddedDetailGridCellDoubleClick;
  Result.OnRowStyleNeeded := EmbeddedDetailGridRowStyleNeeded;
  Result.OnCellVisualNeeded := EmbeddedDetailGridCellVisualNeeded;
end;

function TThemedGridControlMasterDetail.RentEmbeddedDetailGrid: TThemedGridControlMasterDetail;
var
  LIndex: Integer;
begin
  while FGridPool.Count > 0 do
  begin
    LIndex := FGridPool.Count - 1;
    Result := FGridPool[LIndex];
    FGridPool.Delete(LIndex);
    FCleanedPool.Remove(Result);
    Result.Visible := False;
    Exit;
  end;
  Result := CreateEmbeddedDetailGrid;
end;

procedure TThemedGridControlMasterDetail.ConfigureEmbeddedDetailGrid(const AGrid: TThemedGridControlMasterDetail;
  const AData: TThemedGridMasterDetailData; const AColumns: TThemedGridDetailGridColumnCollection);
var
  LOptions: TThemedGridDetailGridOptions;
  LSource: TThemedGridDetailGridColumn;
  LTarget: TThemedGridColumn;
  I: Integer;
begin
  LOptions := AData.GridOptions;
  AGrid.ShowColumnHeaders := LOptions.HeaderVisible;
  AGrid.RowHeight := ScaleInt(LOptions.RowHeight);
  AGrid.HeaderHeight := ScaleInt(LOptions.HeaderHeight);
  AGrid.Columns.Clear;
  for I := 0 to AColumns.Count - 1 do
  begin
    LSource := AColumns[I];
    if (LSource = nil) or not LSource.Visible then
      Continue;
    LTarget := AGrid.Columns.AddText(LSource.Name, LSource.DataPropertyName, LSource.HeaderText);
    LTarget.Width := ScaleInt(LSource.Width);
    LTarget.MinWidth := ScaleInt(LSource.MinimumWidth);
    LTarget.ReadOnly := LSource.ReadOnly;
    LTarget.Visible := LSource.Visible;
    LTarget.FormatString := LSource.FormatString;
    LTarget.TextAlignment := LSource.TextAlignment;
    LTarget.RenderKind := LSource.RenderKind;
    LTarget.Tag := TValue.From<TObject>(LSource);
  end;
  AGrid.DataSource := AData.GridDataSource;
end;

procedure TThemedGridControlMasterDetail.DetachEmbeddedGridHandlers(const AGrid: TThemedGridControlMasterDetail);
begin
  AGrid.OnCellClick := nil;
  AGrid.OnCellDoubleClick := nil;
  AGrid.OnRowStyleNeeded := nil;
  AGrid.OnCellVisualNeeded := nil;
end;

procedure TThemedGridControlMasterDetail.ParkEmbeddedDetailGrid(const AGrid: TThemedGridControlMasterDetail);
begin
  if AGrid = nil then
    Exit;
  AGrid.Visible := False;
  FEmbeddedContexts.Remove(AGrid);
  FGridPool.Add(AGrid);
  FPoolCleanPending := True;
  Invalidate;
end;

procedure TThemedGridControlMasterDetail.FlushEmbeddedGridPool;
var
  I: Integer;
  LGrid: TThemedGridControlMasterDetail;
begin
  if FPoolCleanPending then
  begin
    for I := 0 to FGridPool.Count - 1 do
    begin
      LGrid := FGridPool[I];
      if FCleanedPool.Contains(LGrid) then
        Continue;
      LGrid.DataSource := TValue.Empty;
      LGrid.Columns.Clear;
      FCleanedPool.Add(LGrid);
    end;
    FPoolCleanPending := False;
  end;
  if FPoolDisposePending then
  begin
    for I := FGridPool.Count - 1 downto 0 do
    begin
      LGrid := FGridPool[I];
      DetachEmbeddedGridHandlers(LGrid);
      FCleanedPool.Remove(LGrid);
      LGrid.Free;
    end;
    FGridPool.Clear;
    FPoolDisposePending := False;
  end;
end;

procedure TThemedGridControlMasterDetail.RemoveEmbeddedDetailGridByKey(const AKey: string;
  const AForceDispose: Boolean);
var
  LGrid: TThemedGridControlMasterDetail;
begin
  if AKey = '' then
    Exit;
  if not FEmbeddedGrids.TryGetValue(AKey, LGrid) then
    Exit;
  FEmbeddedGrids.Remove(AKey);
  FVisibleEmbeddedKeys.Remove(AKey);
  ParkEmbeddedDetailGrid(LGrid);
  if AForceDispose then
    FPoolDisposePending := True;
end;

function TThemedGridControlMasterDetail.HasEmbeddedDetailGrids: Boolean;
begin
  Result := FEmbeddedGrids.Count > 0;
end;

procedure TThemedGridControlMasterDetail.RemoveEmbeddedDetailGridByDataSourceIndex(const ADataSourceIndex: Integer);
var
  LKeys: TList<string>;
  LPair: TPair<string, TThemedGridControlMasterDetail>;
  LContext: TEmbeddedContext;
  LForceDispose: Boolean;
  I: Integer;
begin
  if ADataSourceIndex < 0 then
    Exit;
  LKeys := TList<string>.Create;
  try
    for LPair in FEmbeddedGrids do
      if FEmbeddedContexts.TryGetValue(LPair.Value, LContext) and
        (LContext.ParentDataSourceIndex = ADataSourceIndex) then
        LKeys.Add(LPair.Key);
    LForceDispose := (DetailOptions <> nil) and
      (DetailOptions.EmbeddedDetailGridRetentionMode = TThemedGridEmbeddedDetailGridRetentionMode.DisposeOnCollapse);
    for I := 0 to LKeys.Count - 1 do
      RemoveEmbeddedDetailGridByKey(LKeys[I], LForceDispose);
  finally
    LKeys.Free;
  end;
end;

procedure TThemedGridControlMasterDetail.ClearEmbeddedDetailGrids;
var
  LKeys: TList<string>;
  LKey: string;
  I: Integer;
begin
  LKeys := TList<string>.Create;
  try
    for LKey in FEmbeddedGrids.Keys do
      LKeys.Add(LKey);
    for I := 0 to LKeys.Count - 1 do
      RemoveEmbeddedDetailGridByKey(LKeys[I], True);
  finally
    LKeys.Free;
  end;
  FVisibleEmbeddedKeys.Clear;
  FPoolDisposePending := True;
  FPoolCleanPending := True;
end;

procedure TThemedGridControlMasterDetail.HideEmbeddedMasterDetailGrid(const AViewRow: TThemedGridViewRow);
begin
  if (AViewRow = nil) or (AViewRow.ParentDataSourceIndex < 0) then
    Exit;
  RemoveEmbeddedDetailGridByDataSourceIndex(AViewRow.ParentDataSourceIndex);
end;

procedure TThemedGridControlMasterDetail.BeginDetailLayout;
begin
  inherited BeginDetailLayout;
  FVisibleEmbeddedKeys.Clear;
end;

procedure TThemedGridControlMasterDetail.EndDetailLayout;
var
  LPair: TPair<string, TThemedGridControlMasterDetail>;
  LContext: TEmbeddedContext;
  LStale: TList<string>;
  I: Integer;
  LVisible: Boolean;
begin
  LStale := TList<string>.Create;
  try
    for LPair in FEmbeddedGrids do
    begin
      LVisible := FVisibleEmbeddedKeys.Contains(LPair.Key);
      if LPair.Value.Visible <> LVisible then
        LPair.Value.Visible := LVisible;
      if not LVisible and FEmbeddedContexts.TryGetValue(LPair.Value, LContext) and
        (DataController <> nil) and (LContext.DataVersion <> DataController.Version) then
        LStale.Add(LPair.Key);
    end;
    for I := 0 to LStale.Count - 1 do
      RemoveEmbeddedDetailGridByKey(LStale[I], False);
  finally
    LStale.Free;
  end;
  FlushEmbeddedGridPool;
  inherited EndDetailLayout;
end;

function TThemedGridControlMasterDetail.ResolveContextViewRow(const AContext: TEmbeddedContext): TThemedGridViewRow;
begin
  Result := GetViewRow(AContext.ViewRowIndex);
  if (Result <> nil) and (not Result.IsDetailRow or (Result.ParentDataSourceIndex <> AContext.ParentDataSourceIndex)) then
    Result := nil;
end;

procedure TThemedGridControlMasterDetail.EmbeddedDetailGridCellClick(ASender: TObject;
  const AArgs: TThemedGridCellMouseEventArgs);
begin
  RaiseEmbeddedDetailGridCellMouseEvent(ASender as TThemedGridControlMasterDetail, AArgs, False);
end;

procedure TThemedGridControlMasterDetail.EmbeddedDetailGridCellDoubleClick(ASender: TObject;
  const AArgs: TThemedGridCellMouseEventArgs);
begin
  RaiseEmbeddedDetailGridCellMouseEvent(ASender as TThemedGridControlMasterDetail, AArgs, True);
end;

procedure TThemedGridControlMasterDetail.RaiseEmbeddedDetailGridCellMouseEvent(
  const AGrid: TThemedGridControlMasterDetail; const AArgs: TThemedGridCellMouseEventArgs;
  const ADoubleClick: Boolean);
var
  LContext: TEmbeddedContext;
  LDetailColumn: TThemedGridDetailGridColumn;
  LCellBounds, LRowBounds: TRect;
  LHitInfo: TThemedGridDetailGridHitInfo;
  LMousePoint: TPoint;
  LMouseArgs: TThemedGridDetailGridCellMouseEventArgs;
begin
  if (AGrid = nil) or (AArgs = nil) then
    Exit;
  if not FEmbeddedContexts.TryGetValue(AGrid, LContext) then
    Exit;
  if (AArgs.Column = nil) or (AArgs.Column.Tag.TypeInfo = nil) or not AArgs.Column.Tag.IsObject then
    Exit;
  if not (AArgs.Column.Tag.AsObject is TThemedGridDetailGridColumn) then
    Exit;
  LDetailColumn := TThemedGridDetailGridColumn(AArgs.Column.Tag.AsObject);
  LCellBounds := Rect(AGrid.Left + AArgs.Bounds.Left, AGrid.Top + AArgs.Bounds.Top,
    AGrid.Left + AArgs.Bounds.Right, AGrid.Top + AArgs.Bounds.Bottom);
  LRowBounds := Rect(AGrid.Left, LCellBounds.Top, AGrid.Left + AGrid.Width, LCellBounds.Bottom);
  LHitInfo := TThemedGridDetailGridHitInfo.Create;
  try
    LHitInfo.SetCell(ResolveContextViewRow(LContext), LContext.ViewRowIndex, LContext.ParentDataSourceIndex,
      LContext.ParentRowObject, LContext.RelationName, LContext.RelationIndex, AArgs.DataSourceIndex,
      AArgs.ColumnIndex, AArgs.RowObject, AArgs.Value, LDetailColumn, AGrid.BoundsRect, LRowBounds, LCellBounds);
    LMousePoint := ScreenToClient(AGrid.ClientToScreen(AArgs.Location));
    LMouseArgs := TThemedGridDetailGridCellMouseEventArgs.Create(AArgs.Button, AArgs.Clicks, LMousePoint.X,
      LMousePoint.Y, AArgs.Delta, LHitInfo);
    try
      if ADoubleClick then
        DoDetailGridCellDoubleClick(LMouseArgs)
      else
        DoDetailGridCellClick(LMouseArgs);
    finally
      LMouseArgs.Free;
    end;
  finally
    LHitInfo.Free;
  end;
end;

procedure TThemedGridControlMasterDetail.EmbeddedDetailGridRowStyleNeeded(ASender: TObject;
  const AArgs: TThemedGridRowStyleEventArgs);
var
  LGrid: TThemedGridControlMasterDetail;
  LContext: TEmbeddedContext;
  LVisual: TThemedGridDetailGridRowVisual;
  LVisualArgs: TThemedGridDetailGridRowVisualNeededEventArgs;
  LBounds: TRect;
begin
  if not Assigned(FOnDetailGridRowVisualNeeded) or (AArgs = nil) then
    Exit;
  LGrid := ASender as TThemedGridControlMasterDetail;
  if not FEmbeddedContexts.TryGetValue(LGrid, LContext) then
    Exit;
  LVisual := TThemedGridDetailGridRowVisual.Create;
  try
    LBounds := Rect(LGrid.Left, AArgs.Bounds.Top + LGrid.Top, LGrid.Left + LGrid.Width,
      AArgs.Bounds.Top + LGrid.Top + AArgs.Bounds.Height);
    LVisualArgs := TThemedGridDetailGridRowVisualNeededEventArgs.Create(ResolveContextViewRow(LContext),
      LContext.ViewRowIndex, LContext.ParentDataSourceIndex, LContext.ParentRowObject, LContext.RelationName,
      LContext.RelationIndex, AArgs.DataSourceIndex, AArgs.RowObject, LBounds, LVisual);
    try
      DoDetailGridRowVisualNeeded(LVisualArgs);
      if not LVisualArgs.Handled then
        Exit;
    finally
      LVisualArgs.Free;
    end;
    AArgs.EnsureStyle;
    if LVisual.HasBackColor then
      AArgs.Style.BackColor := LVisual.BackColor;
    if LVisual.HasForeColor then
      AArgs.Style.ForeColor := LVisual.ForeColor;
    if LVisual.HasBorderColor then
      AArgs.Style.BorderColor := LVisual.BorderColor;
    AArgs.Style.Bold := LVisual.Bold;
    AArgs.Style.Italic := LVisual.Italic;
    AArgs.Style.Tag := LVisual.Tag;
  finally
    LVisual.Free;
  end;
end;

procedure TThemedGridControlMasterDetail.DoMasterDetailDataNeeded(const AArgs: TThemedGridMasterDetailDataNeededEventArgs);
begin
  if Assigned(FOnMasterDetailDataNeeded) then
    FOnMasterDetailDataNeeded(Self, AArgs);
end;

procedure TThemedGridControlMasterDetail.DoDetailItemsNeeded(const AArgs: TThemedGridDetailItemsNeededEventArgs);
begin
  if Assigned(FOnDetailItemsNeeded) then
    FOnDetailItemsNeeded(Self, AArgs);
end;

procedure TThemedGridControlMasterDetail.DoDetailItemClick(const AArgs: TThemedGridDetailItemEventArgs);
begin
  if Assigned(FOnDetailItemClick) then
    FOnDetailItemClick(Self, AArgs);
end;

procedure TThemedGridControlMasterDetail.DoDetailItemDoubleClick(const AArgs: TThemedGridDetailItemEventArgs);
begin
  if Assigned(FOnDetailItemDoubleClick) then
    FOnDetailItemDoubleClick(Self, AArgs);
end;

procedure TThemedGridControlMasterDetail.DoDetailItemAction(const AArgs: TThemedGridDetailItemActionEventArgs);
begin
  if Assigned(FOnDetailItemAction) then
    FOnDetailItemAction(Self, AArgs);
end;

procedure TThemedGridControlMasterDetail.DoDetailItemValueChanging(
  const AArgs: TThemedGridDetailItemValueChangingEventArgs);
begin
  if Assigned(FOnDetailItemValueChanging) then
    FOnDetailItemValueChanging(Self, AArgs);
end;

procedure TThemedGridControlMasterDetail.DoDetailItemValueChanged(
  const AArgs: TThemedGridDetailItemValueChangedEventArgs);
begin
  if Assigned(FOnDetailItemValueChanged) then
    FOnDetailItemValueChanged(Self, AArgs);
end;

procedure TThemedGridControlMasterDetail.DoDetailGridRowVisualNeeded(
  const AArgs: TThemedGridDetailGridRowVisualNeededEventArgs);
begin
  if Assigned(FOnDetailGridRowVisualNeeded) then
    FOnDetailGridRowVisualNeeded(Self, AArgs);
end;

procedure TThemedGridControlMasterDetail.DoDetailGridCellClick(const AArgs: TThemedGridDetailGridCellMouseEventArgs);
begin
  if Assigned(FOnDetailGridCellClick) then
    FOnDetailGridCellClick(Self, AArgs);
end;

procedure TThemedGridControlMasterDetail.DoDetailGridCellDoubleClick(
  const AArgs: TThemedGridDetailGridCellMouseEventArgs);
begin
  if Assigned(FOnDetailGridCellDoubleClick) then
    FOnDetailGridCellDoubleClick(Self, AArgs);
end;

procedure TThemedGridControlMasterDetail.DoDetailRowHeightNeeded(const AArgs: TThemedGridDetailRowHeightNeededEventArgs);
begin
  if Assigned(FOnDetailRowHeightNeeded) then
    FOnDetailRowHeightNeeded(Self, AArgs);
end;

procedure TThemedGridControlMasterDetail.DoDetailRowTextNeeded(const AArgs: TThemedGridDetailRowTextNeededEventArgs);
begin
  if Assigned(FOnDetailRowTextNeeded) then
    FOnDetailRowTextNeeded(Self, AArgs);
end;

procedure TThemedGridControlMasterDetail.DoDetailRowPaint(const AArgs: TThemedGridDetailRowPaintEventArgs);
begin
  if Assigned(FOnDetailRowPaint) then
    FOnDetailRowPaint(Self, AArgs);
end;

end.

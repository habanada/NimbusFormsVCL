unit NimbusForms.Grid.RowViewBuilder;

{$SCOPEDENUMS ON}

interface

uses
  System.SysUtils,
  System.Rtti,
  System.Generics.Collections,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.DataControllerIntf,
  NimbusForms.Grid.RowView,
  NimbusForms.Grid.GroupDescriptorCollection,
  NimbusForms.Grid.GroupingOptions,
  NimbusForms.Grid.DetailOptions,
  NimbusForms.Grid.StringSet;

type
  TThemedGridRowViewBuilder = class
  public
    class procedure Build(const ADataController: IThemedGridDataController; const ARowView: TThemedGridRowView;
      const ADefaultRowHeight: Integer); overload; static;
    class procedure Build(const ADataController: IThemedGridDataController; const ARowView: TThemedGridRowView;
      const ADefaultRowHeight: Integer; const AGroups: TThemedGridGroupDescriptorCollection;
      const ACollapsedGroupKeys: TThemedGridStringSet; const AGroupingOptions: TThemedGridGroupingOptions); overload; static;
    class procedure Build(const ADataController: IThemedGridDataController; const ARowView: TThemedGridRowView;
      const ADefaultRowHeight: Integer; const AGroups: TThemedGridGroupDescriptorCollection;
      const ACollapsedGroupKeys: TThemedGridStringSet; const AGroupingOptions: TThemedGridGroupingOptions;
      const AExpandedDetailKeys: TThemedGridStringSet; const ADetailOptions: TThemedGridDetailOptions); overload; static;
    class procedure ClearGroupCache; static;
    class function CreateDetailKey(const ADataSourceIndex: Integer): string; static;
  end;

implementation

uses
  System.Math,
  System.TypInfo,
  System.SyncObjs,
  System.Generics.Defaults,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.ViewRow,
  NimbusForms.Grid.GroupDescriptor,
  NimbusForms.Grid.RowList,
  NimbusForms.Grid.ValueConverter,
  NimbusForms.Grid.ValueFormatter;

const
  MaximumGroupCacheEntries = 32;
  DefaultDetailHeight = 72;
  DetailKeyPrefix = 'D|';

type
  TGroupNode = class
  public
    Key: string;
    Level: Integer;
    DefaultExpanded: Boolean;
    Value: TValue;
    DisplayText: string;
    GroupColumn: TThemedGridColumn;
    GroupColumnName: string;
    ChildCount: Integer;
    DataIndexes: TList<Integer>;
    Children: TObjectList<TGroupNode>;
    constructor Create;
    destructor Destroy; override;
  end;

  IGroupCacheEntry = interface
    ['{8A1D4E27-6B93-4C58-A0F2-1E5D7C3B9A46}']
    function GetRootNodes: TObjectList<TGroupNode>;
    property RootNodes: TObjectList<TGroupNode> read GetRootNodes;
  end;

  TGroupCacheEntry = class(TInterfacedObject, IGroupCacheEntry)
  private
    FCacheKey: string;
    FDataVersion: Integer;
    FController: IThemedGridDataController;
    FRootNodes: TObjectList<TGroupNode>;
    function GetRootNodes: TObjectList<TGroupNode>;
  public
    constructor Create(const ACacheKey: string; const AController: IThemedGridDataController;
      const ARootNodes: TObjectList<TGroupNode>);
    destructor Destroy; override;
  end;

  TGroupNodeState = class
  public
    Node: TGroupNode;
    Expanded: Boolean;
    VisibleCount: Integer;
    DataRowCount: Integer;
    TotalHeight: Integer;
    Children: TObjectList<TGroupNodeState>;
    DetailVirtualIndexes: TArray<Integer>;
    DetailDataIndexes: TArray<Integer>;
    DetailPrefix: TArray<Integer>;
    PrefixVersion: Integer;
    Extra: Integer;
    ExtraVersion: Integer;
    ExtraValid: Boolean;
    destructor Destroy; override;
  end;

  TGroupBucket = class
  public
    Value: TValue;
    DisplayText: string;
    DataIndexes: TList<Integer>;
    destructor Destroy; override;
  end;

  TDetailIndex = record
    DataSourceIndex: Integer;
    VisibleIndex: Integer;
  end;

var
  GGroupCache: TDictionary<string, IGroupCacheEntry>;
  GGroupCacheOrder: TQueue<string>;
  GGroupCacheLock: TCriticalSection;

{ TGroupNode }

constructor TGroupNode.Create;
begin
  inherited Create;
  Children := TObjectList<TGroupNode>.Create(True);
end;

destructor TGroupNode.Destroy;
begin
  Children.Free;
  DataIndexes.Free;
  inherited Destroy;
end;

{ TGroupCacheEntry }

constructor TGroupCacheEntry.Create(const ACacheKey: string; const AController: IThemedGridDataController;
  const ARootNodes: TObjectList<TGroupNode>);
begin
  inherited Create;
  FCacheKey := ACacheKey;
  FController := AController;
  FDataVersion := AController.Version;
  FRootNodes := ARootNodes;
end;

destructor TGroupCacheEntry.Destroy;
begin
  FRootNodes.Free;
  FController := nil;
  inherited Destroy;
end;

function TGroupCacheEntry.GetRootNodes: TObjectList<TGroupNode>;
begin
  Result := FRootNodes;
end;

{ TGroupNodeState }

destructor TGroupNodeState.Destroy;
begin
  Children.Free;
  inherited Destroy;
end;

{ TGroupBucket }

destructor TGroupBucket.Destroy;
begin
  DataIndexes.Free;
  inherited Destroy;
end;

{ helpers }

function ClampToInt(const AValue: Int64): Integer;
begin
  if AValue > High(Integer) then
    Exit(High(Integer));
  if AValue < Low(Integer) then
    Exit(Low(Integer));
  Result := Integer(AValue);
end;

function BinarySearchIndex(const AValues: TArray<Integer>; const AValue: Integer): Integer;
var
  LLow, LHigh, LMid: Integer;
begin
  LLow := 0;
  LHigh := Length(AValues) - 1;
  while LLow <= LHigh do
  begin
    LMid := LLow + (LHigh - LLow) div 2;
    if AValues[LMid] = AValue then
      Exit(LMid);
    if AValues[LMid] < AValue then
      LLow := LMid + 1
    else
      LHigh := LMid - 1;
  end;
  Result := -1;
end;

function CountLessThan(const AValues: TArray<Integer>; const AValue: Integer): Integer;
var
  LLow, LHigh, LMid: Integer;
begin
  if Length(AValues) = 0 then
    Exit(0);
  LLow := 0;
  LHigh := Length(AValues);
  while LLow < LHigh do
  begin
    LMid := LLow + (LHigh - LLow) div 2;
    if AValues[LMid] < AValue then
      LLow := LMid + 1
    else
      LHigh := LMid;
  end;
  Result := LLow;
end;

function ParseDetailDataSourceIndex(const AKey: string): Integer;
var
  LValue: Integer;
begin
  if AKey = '' then
    Exit(-1);
  if Copy(AKey, 1, Length(DetailKeyPrefix)) <> DetailKeyPrefix then
    Exit(-1);
  if not TryStrToInt(Copy(AKey, Length(DetailKeyPrefix) + 1, MaxInt), LValue) then
    Exit(-1);
  Result := LValue;
end;

function CreateDataRow(const ADataSourceIndex, ADefaultRowHeight: Integer): TThemedGridViewRow;
begin
  Result := TThemedGridViewRow.Create;
  Result.Kind := TThemedGridViewRowKind.Data;
  Result.DataSourceIndex := ADataSourceIndex;
  Result.Height := ADefaultRowHeight;
  Result.Level := 0;
  Result.Visible := True;
  Result.Expanded := True;
end;

function CreateDetailRow(const ADataSourceIndex: Integer; const ADetailKey: string;
  const ADetailHeight: Integer; const AEmptyText: string): TThemedGridViewRow;
begin
  Result := TThemedGridViewRow.Create;
  Result.Kind := TThemedGridViewRowKind.Detail;
  Result.DataSourceIndex := -1;
  Result.ParentDataSourceIndex := ADataSourceIndex;
  Result.Height := ADetailHeight;
  Result.Level := 0;
  Result.Visible := True;
  Result.Expanded := True;
  Result.Key := TValue.From<string>(ADetailKey);
  Result.DisplayText := AEmptyText;
end;

function RowIndexAtVirtualY(const AProvider: IThemedGridRowViewProvider; const ACount, ATotalHeight,
  AVirtualY: Integer): Integer;
var
  LLow, LHigh, LMid, LTop, LBottom: Integer;
begin
  if ACount <= 0 then
    Exit(-1);
  if AVirtualY <= 0 then
    Exit(0);
  if AVirtualY >= ATotalHeight then
    Exit(ACount - 1);
  LLow := 0;
  LHigh := ACount - 1;
  while LLow <= LHigh do
  begin
    LMid := LLow + (LHigh - LLow) div 2;
    LTop := AProvider.GetRowTop(LMid);
    LBottom := LTop + AProvider.GetEstimatedRowHeight(LMid);
    if AVirtualY < LTop then
    begin
      LHigh := LMid - 1;
      Continue;
    end;
    if AVirtualY >= LBottom then
    begin
      LLow := LMid + 1;
      Continue;
    end;
    Exit(LMid);
  end;
  if LLow < 0 then
    Exit(0);
  if LLow >= ACount then
    Exit(ACount - 1);
  Result := LLow;
end;

{ TFlatRowViewProvider }

type
  TFlatRowViewProvider = class(TInterfacedObject, IThemedGridRowViewProvider)
  private
    FDataController: IThemedGridDataController;
    FDefaultRowHeight: Integer;
    FDetailHeight: Integer;
    FEmptyDetailText: string;
    FDetailDataSourceIndexes: TArray<Integer>;
    FDetailVirtualIndexes: TArray<Integer>;
    FHeights: TThemedGridDetailHeightMap;
    FPrefix: TArray<Integer>;
    FPrefixVersion: Integer;
    FCount: Integer;
    FTotalHeight: Integer;
    procedure EnsurePrefix;
    function DetailHeightFor(const ADataSourceIndex: Integer): Integer;
    class function BuildDetails(const ADataController: IThemedGridDataController;
      const AExpandedDetailKeys: TThemedGridStringSet;
      const ADetailOptions: TThemedGridDetailOptions): TList<TDetailIndex>; static;
  public
    constructor Create(const ADataController: IThemedGridDataController; const ADefaultRowHeight: Integer;
      const AExpandedDetailKeys: TThemedGridStringSet; const ADetailOptions: TThemedGridDetailOptions;
      const AHeights: TThemedGridDetailHeightMap);
    function GetCount: Integer;
    function GetVersion: Integer;
    function GetDataRowCount: Integer;
    function GetTotalHeight: Integer;
    function GetRow(const AIndex: Integer): TThemedGridViewRow;
    function GetEstimatedRowHeight(const AIndex: Integer): Integer;
    function GetRowTop(const AIndex: Integer): Integer;
    function GetRowIndexAtVirtualY(const AVirtualY: Integer): Integer;
  end;

constructor TFlatRowViewProvider.Create(const ADataController: IThemedGridDataController;
  const ADefaultRowHeight: Integer; const AExpandedDetailKeys: TThemedGridStringSet;
  const ADetailOptions: TThemedGridDetailOptions; const AHeights: TThemedGridDetailHeightMap);
var
  LDetails: TList<TDetailIndex>;
  I, LDataCount: Integer;
begin
  inherited Create;
  FDataController := ADataController;
  FHeights := AHeights;
  FDefaultRowHeight := Max(1, ADefaultRowHeight);
  if ADetailOptions <> nil then
    FDetailHeight := Max(1, ADetailOptions.DetailRowHeight)
  else
    FDetailHeight := DefaultDetailHeight;
  if ADetailOptions <> nil then
    FEmptyDetailText := ADetailOptions.EmptyText
  else
    FEmptyDetailText := '';
  LDetails := BuildDetails(ADataController, AExpandedDetailKeys, ADetailOptions);
  try
    SetLength(FDetailDataSourceIndexes, LDetails.Count);
    SetLength(FDetailVirtualIndexes, LDetails.Count);
    for I := 0 to LDetails.Count - 1 do
    begin
      FDetailDataSourceIndexes[I] := LDetails[I].DataSourceIndex;
      FDetailVirtualIndexes[I] := LDetails[I].VisibleIndex + I + 1;
    end;
    if ADataController <> nil then
      LDataCount := ADataController.RowCount
    else
      LDataCount := 0;
    FCount := LDataCount + LDetails.Count;
    FTotalHeight := ClampToInt(Int64(LDataCount) * FDefaultRowHeight + Int64(LDetails.Count) * FDetailHeight);
  finally
    LDetails.Free;
  end;
end;

class function TFlatRowViewProvider.BuildDetails(const ADataController: IThemedGridDataController;
  const AExpandedDetailKeys: TThemedGridStringSet; const ADetailOptions: TThemedGridDetailOptions): TList<TDetailIndex>;
var
  LKey: string;
  LDetail: TDetailIndex;
  LDataSourceIndex, LVisibleIndex: Integer;
begin
  Result := TList<TDetailIndex>.Create;
  if (ADataController = nil) or (ADetailOptions = nil) or (not ADetailOptions.Enabled) or
     (AExpandedDetailKeys = nil) or (AExpandedDetailKeys.Count = 0) then
    Exit;
  for LKey in AExpandedDetailKeys.ToArray do
  begin
    LDataSourceIndex := ParseDetailDataSourceIndex(LKey);
    if LDataSourceIndex < 0 then
      Continue;
    LVisibleIndex := ADataController.GetVisibleRowIndex(LDataSourceIndex);
    if LVisibleIndex < 0 then
      Continue;
    LDetail.DataSourceIndex := LDataSourceIndex;
    LDetail.VisibleIndex := LVisibleIndex;
    Result.Add(LDetail);
  end;
  Result.Sort(TComparer<TDetailIndex>.Construct(
    function(const ALeft, ARight: TDetailIndex): Integer
    begin
      if ALeft.VisibleIndex <> ARight.VisibleIndex then
        Exit(CompareValue(ALeft.VisibleIndex, ARight.VisibleIndex));
      Result := CompareValue(ALeft.DataSourceIndex, ARight.DataSourceIndex);
    end));
end;

procedure TFlatRowViewProvider.EnsurePrefix;
var
  I: Integer;
  LSum: Int64;
begin
  if (Length(FPrefix) = Length(FDetailDataSourceIndexes) + 1) and
    ((FHeights = nil) or (FPrefixVersion = FHeights.Version)) then
    Exit;
  SetLength(FPrefix, Length(FDetailDataSourceIndexes) + 1);
  FPrefix[0] := 0;
  LSum := 0;
  for I := 0 to High(FDetailDataSourceIndexes) do
  begin
    Inc(LSum, DetailHeightFor(FDetailDataSourceIndexes[I]) - FDetailHeight);
    FPrefix[I + 1] := ClampToInt(LSum);
  end;
  if FHeights <> nil then
    FPrefixVersion := FHeights.Version;
end;

function TFlatRowViewProvider.DetailHeightFor(const ADataSourceIndex: Integer): Integer;
begin
  if FHeights <> nil then
    Result := FHeights.GetHeight(ADataSourceIndex, FDetailHeight)
  else
    Result := FDetailHeight;
end;

function TFlatRowViewProvider.GetCount: Integer;
begin
  Result := FCount;
end;

function TFlatRowViewProvider.GetVersion: Integer;
begin
  if FDataController <> nil then
    Result := FDataController.Version
  else
    Result := -1;
end;

function TFlatRowViewProvider.GetDataRowCount: Integer;
begin
  if FDataController <> nil then
    Result := FDataController.RowCount
  else
    Result := 0;
end;

function TFlatRowViewProvider.GetTotalHeight: Integer;
begin
  EnsurePrefix;
  Result := ClampToInt(Int64(FTotalHeight) + FPrefix[High(FPrefix)]);
end;

function TFlatRowViewProvider.GetRow(const AIndex: Integer): TThemedGridViewRow;
var
  LDetailPosition, LDataSourceIndex, LDetailsBefore, LVisibleIndex, LDataIndex: Integer;
begin
  if (FDataController = nil) or (AIndex < 0) or (AIndex >= FCount) then
    Exit(nil);
  LDetailPosition := BinarySearchIndex(FDetailVirtualIndexes, AIndex);
  if LDetailPosition >= 0 then
  begin
    LDataSourceIndex := FDetailDataSourceIndexes[LDetailPosition];
    Exit(CreateDetailRow(LDataSourceIndex, TThemedGridRowViewBuilder.CreateDetailKey(LDataSourceIndex),
      DetailHeightFor(LDataSourceIndex), FEmptyDetailText));
  end;
  LDetailsBefore := CountLessThan(FDetailVirtualIndexes, AIndex);
  LVisibleIndex := AIndex - LDetailsBefore;
  LDataIndex := FDataController.GetDataSourceIndex(LVisibleIndex);
  if LDataIndex < 0 then
    Exit(nil);
  Result := CreateDataRow(LDataIndex, FDefaultRowHeight);
end;

function TFlatRowViewProvider.GetEstimatedRowHeight(const AIndex: Integer): Integer;
var
  LPosition: Integer;
begin
  if (AIndex < 0) or (AIndex >= FCount) then
    Exit(FDefaultRowHeight);
  LPosition := BinarySearchIndex(FDetailVirtualIndexes, AIndex);
  if LPosition >= 0 then
    Result := DetailHeightFor(FDetailDataSourceIndexes[LPosition])
  else
    Result := FDefaultRowHeight;
end;

function TFlatRowViewProvider.GetRowTop(const AIndex: Integer): Integer;
var
  LDetailsBefore, LNormalBefore: Integer;
begin
  if AIndex <= 0 then
    Exit(0);
  if AIndex >= FCount then
    Exit(GetTotalHeight);
  EnsurePrefix;
  LDetailsBefore := CountLessThan(FDetailVirtualIndexes, AIndex);
  LNormalBefore := AIndex - LDetailsBefore;
  Result := ClampToInt(Int64(LNormalBefore) * FDefaultRowHeight + Int64(LDetailsBefore) * FDetailHeight +
    FPrefix[LDetailsBefore]);
end;

function TFlatRowViewProvider.GetRowIndexAtVirtualY(const AVirtualY: Integer): Integer;
begin
  Result := RowIndexAtVirtualY(Self, FCount, GetTotalHeight, AVirtualY);
end;

{ TGroupedRowViewProvider }

type
  TGroupedRowViewProvider = class(TInterfacedObject, IThemedGridRowViewProvider)
  private
    FDataController: IThemedGridDataController;
    FEntry: IGroupCacheEntry;
    FRootStates: TObjectList<TGroupNodeState>;
    FHeights: TThemedGridDetailHeightMap;
    FDefaultRowHeight: Integer;
    FDetailHeight: Integer;
    FEmptyDetailText: string;
    FCount: Integer;
    FDataRowCount: Integer;
    FTotalHeight: Integer;
    function DetailHeightFor(const ADataSourceIndex: Integer): Integer;
    function HeightsVersion: Integer;
    procedure EnsureLeafPrefix(const AState: TGroupNodeState);
    function StateExtra(const AState: TGroupNodeState): Integer;
    function CreateState(const ANode: TGroupNode; const ACollapsedGroupKeys, AExpandedDetailKeys: TThemedGridStringSet;
      const ADetailOptions: TThemedGridDetailOptions): TGroupNodeState;
    class procedure BuildLeafDetailIndexes(const AState: TGroupNodeState;
      const AExpandedDetailKeys: TThemedGridStringSet; const ADetailOptions: TThemedGridDetailOptions); static;
    function GetRowFromState(const AState: TGroupNodeState; const AIndex: Integer): TThemedGridViewRow;
    function GetEstimatedHeightFromState(const AState: TGroupNodeState; const AIndex: Integer): Integer;
    function GetRowTopFromState(const AState: TGroupNodeState; const AIndex: Integer): Integer;
    function GetLeafRow(const AState: TGroupNodeState; const AIndex: Integer): TThemedGridViewRow;
    function CreateGroupRow(const AState: TGroupNodeState): TThemedGridViewRow;
  public
    constructor Create(const ADataController: IThemedGridDataController; const AEntry: IGroupCacheEntry;
      const ADefaultRowHeight: Integer; const ACollapsedGroupKeys, AExpandedDetailKeys: TThemedGridStringSet;
      const ADetailOptions: TThemedGridDetailOptions; const AHeights: TThemedGridDetailHeightMap);
    destructor Destroy; override;
    function GetCount: Integer;
    function GetVersion: Integer;
    function GetDataRowCount: Integer;
    function GetTotalHeight: Integer;
    function GetRow(const AIndex: Integer): TThemedGridViewRow;
    function GetEstimatedRowHeight(const AIndex: Integer): Integer;
    function GetRowTop(const AIndex: Integer): Integer;
    function GetRowIndexAtVirtualY(const AVirtualY: Integer): Integer;
  end;

constructor TGroupedRowViewProvider.Create(const ADataController: IThemedGridDataController;
  const AEntry: IGroupCacheEntry; const ADefaultRowHeight: Integer;
  const ACollapsedGroupKeys, AExpandedDetailKeys: TThemedGridStringSet;
  const ADetailOptions: TThemedGridDetailOptions; const AHeights: TThemedGridDetailHeightMap);
var
  I: Integer;
  LState: TGroupNodeState;
begin
  inherited Create;
  FHeights := AHeights;
  FDataController := ADataController;
  FEntry := AEntry;
  FDefaultRowHeight := Max(1, ADefaultRowHeight);
  if ADetailOptions <> nil then
    FDetailHeight := Max(1, ADetailOptions.DetailRowHeight)
  else
    FDetailHeight := DefaultDetailHeight;
  if ADetailOptions <> nil then
    FEmptyDetailText := ADetailOptions.EmptyText
  else
    FEmptyDetailText := '';
  FRootStates := TObjectList<TGroupNodeState>.Create(True);
  if (AEntry <> nil) and (AEntry.RootNodes <> nil) then
    for I := 0 to AEntry.RootNodes.Count - 1 do
    begin
      LState := CreateState(AEntry.RootNodes[I], ACollapsedGroupKeys, AExpandedDetailKeys, ADetailOptions);
      FRootStates.Add(LState);
      Inc(FCount, LState.VisibleCount);
      Inc(FDataRowCount, LState.DataRowCount);
      FTotalHeight := ClampToInt(Int64(FTotalHeight) + LState.TotalHeight);
    end;
end;

destructor TGroupedRowViewProvider.Destroy;
begin
  FRootStates.Free;
  FEntry := nil;
  FDataController := nil;
  inherited Destroy;
end;

function TGroupedRowViewProvider.DetailHeightFor(const ADataSourceIndex: Integer): Integer;
begin
  if FHeights <> nil then
    Result := FHeights.GetHeight(ADataSourceIndex, FDetailHeight)
  else
    Result := FDetailHeight;
end;

function TGroupedRowViewProvider.HeightsVersion: Integer;
begin
  if FHeights <> nil then
    Result := FHeights.Version
  else
    Result := 0;
end;

procedure TGroupedRowViewProvider.EnsureLeafPrefix(const AState: TGroupNodeState);
var
  I: Integer;
  LSum: Int64;
begin
  if (Length(AState.DetailPrefix) = Length(AState.DetailDataIndexes) + 1) and
    (AState.PrefixVersion = HeightsVersion) then
    Exit;
  SetLength(AState.DetailPrefix, Length(AState.DetailDataIndexes) + 1);
  AState.DetailPrefix[0] := 0;
  LSum := 0;
  for I := 0 to High(AState.DetailDataIndexes) do
  begin
    Inc(LSum, DetailHeightFor(AState.DetailDataIndexes[I]) - FDetailHeight);
    AState.DetailPrefix[I + 1] := ClampToInt(LSum);
  end;
  AState.PrefixVersion := HeightsVersion;
end;

function TGroupedRowViewProvider.StateExtra(const AState: TGroupNodeState): Integer;
var
  I: Integer;
  LSum: Int64;
begin
  if (AState = nil) or (not AState.Expanded) then
    Exit(0);
  if AState.ExtraValid and (AState.ExtraVersion = HeightsVersion) then
    Exit(AState.Extra);
  if (AState.Children <> nil) and (AState.Children.Count > 0) then
  begin
    LSum := 0;
    for I := 0 to AState.Children.Count - 1 do
      Inc(LSum, StateExtra(AState.Children[I]));
    Result := ClampToInt(LSum);
  end
  else
  begin
    EnsureLeafPrefix(AState);
    Result := AState.DetailPrefix[High(AState.DetailPrefix)];
  end;
  AState.Extra := Result;
  AState.ExtraVersion := HeightsVersion;
  AState.ExtraValid := True;
end;

function TGroupedRowViewProvider.CreateState(const ANode: TGroupNode; const ACollapsedGroupKeys,
  AExpandedDetailKeys: TThemedGridStringSet; const ADetailOptions: TThemedGridDetailOptions): TGroupNodeState;
var
  I, LCount, LDataRowCount, LTotalHeight, LLeafDataCount, LDetailCount: Integer;
  LChild: TGroupNodeState;
begin
  Result := TGroupNodeState.Create;
  Result.Node := ANode;
  Result.Expanded := (ANode <> nil) and ANode.DefaultExpanded;
  Result.VisibleCount := 1;
  Result.TotalHeight := FDefaultRowHeight;
  if (ANode <> nil) and (ACollapsedGroupKeys <> nil) and ACollapsedGroupKeys.Contains(ANode.Key) then
    Result.Expanded := False;
  if (ANode = nil) or (not Result.Expanded) then
    Exit;

  if (ANode.Children <> nil) and (ANode.Children.Count > 0) then
  begin
    Result.Children := TObjectList<TGroupNodeState>.Create(True);
    LCount := 1;
    LDataRowCount := 0;
    LTotalHeight := FDefaultRowHeight;
    for I := 0 to ANode.Children.Count - 1 do
    begin
      LChild := CreateState(ANode.Children[I], ACollapsedGroupKeys, AExpandedDetailKeys, ADetailOptions);
      Result.Children.Add(LChild);
      Inc(LCount, LChild.VisibleCount);
      Inc(LDataRowCount, LChild.DataRowCount);
      LTotalHeight := ClampToInt(Int64(LTotalHeight) + LChild.TotalHeight);
    end;
    Result.VisibleCount := LCount;
    Result.DataRowCount := LDataRowCount;
    Result.TotalHeight := LTotalHeight;
    Exit;
  end;

  BuildLeafDetailIndexes(Result, AExpandedDetailKeys, ADetailOptions);
  if ANode.DataIndexes <> nil then
    LLeafDataCount := ANode.DataIndexes.Count
  else
    LLeafDataCount := 0;
  LDetailCount := Length(Result.DetailDataIndexes);
  Result.VisibleCount := 1 + LLeafDataCount + LDetailCount;
  Result.DataRowCount := LLeafDataCount;
  Result.TotalHeight := ClampToInt(Int64(FDefaultRowHeight) + Int64(LLeafDataCount) * FDefaultRowHeight +
    Int64(LDetailCount) * FDetailHeight);
end;

class procedure TGroupedRowViewProvider.BuildLeafDetailIndexes(const AState: TGroupNodeState;
  const AExpandedDetailKeys: TThemedGridStringSet; const ADetailOptions: TThemedGridDetailOptions);
var
  LPositions, LDataIndexes: TList<Integer>;
  I, LDataSourceIndex: Integer;
begin
  if (AState = nil) or (AState.Node = nil) or (AState.Node.DataIndexes = nil) then
    Exit;
  if (ADetailOptions = nil) or (not ADetailOptions.Enabled) or (AExpandedDetailKeys = nil) or
     (AExpandedDetailKeys.Count = 0) then
    Exit;
  LPositions := nil;
  LDataIndexes := nil;
  try
    for I := 0 to AState.Node.DataIndexes.Count - 1 do
    begin
      LDataSourceIndex := AState.Node.DataIndexes[I];
      if not AExpandedDetailKeys.Contains(TThemedGridRowViewBuilder.CreateDetailKey(LDataSourceIndex)) then
        Continue;
      if LPositions = nil then
      begin
        LPositions := TList<Integer>.Create;
        LDataIndexes := TList<Integer>.Create;
      end;
      LPositions.Add(I);
      LDataIndexes.Add(LDataSourceIndex);
    end;
    if LPositions = nil then
      Exit;
    AState.DetailDataIndexes := LDataIndexes.ToArray;
    SetLength(AState.DetailVirtualIndexes, LPositions.Count);
    for I := 0 to LPositions.Count - 1 do
      AState.DetailVirtualIndexes[I] := LPositions[I] + I + 1;
  finally
    LPositions.Free;
    LDataIndexes.Free;
  end;
end;

function TGroupedRowViewProvider.GetCount: Integer;
begin
  Result := FCount;
end;

function TGroupedRowViewProvider.GetVersion: Integer;
begin
  if FDataController <> nil then
    Result := FDataController.Version
  else
    Result := -1;
end;

function TGroupedRowViewProvider.GetDataRowCount: Integer;
begin
  Result := FDataRowCount;
end;

function TGroupedRowViewProvider.GetTotalHeight: Integer;
var
  I: Integer;
  LSum: Int64;
begin
  LSum := FTotalHeight;
  for I := 0 to FRootStates.Count - 1 do
    Inc(LSum, StateExtra(FRootStates[I]));
  Result := ClampToInt(LSum);
end;

function TGroupedRowViewProvider.GetRow(const AIndex: Integer): TThemedGridViewRow;
var
  I, LCurrent: Integer;
  LState: TGroupNodeState;
begin
  if (AIndex < 0) or (AIndex >= FCount) then
    Exit(nil);
  LCurrent := AIndex;
  for I := 0 to FRootStates.Count - 1 do
  begin
    LState := FRootStates[I];
    if LCurrent >= LState.VisibleCount then
    begin
      Dec(LCurrent, LState.VisibleCount);
      Continue;
    end;
    Exit(GetRowFromState(LState, LCurrent));
  end;
  Result := nil;
end;

function TGroupedRowViewProvider.GetEstimatedRowHeight(const AIndex: Integer): Integer;
var
  I, LCurrent: Integer;
  LState: TGroupNodeState;
begin
  if (AIndex < 0) or (AIndex >= FCount) then
    Exit(FDefaultRowHeight);
  LCurrent := AIndex;
  for I := 0 to FRootStates.Count - 1 do
  begin
    LState := FRootStates[I];
    if LCurrent >= LState.VisibleCount then
    begin
      Dec(LCurrent, LState.VisibleCount);
      Continue;
    end;
    Exit(GetEstimatedHeightFromState(LState, LCurrent));
  end;
  Result := FDefaultRowHeight;
end;

function TGroupedRowViewProvider.GetRowTop(const AIndex: Integer): Integer;
var
  I, LCurrent, LTop: Integer;
  LState: TGroupNodeState;
begin
  if AIndex <= 0 then
    Exit(0);
  if AIndex >= FCount then
    Exit(GetTotalHeight);
  LCurrent := AIndex;
  LTop := 0;
  for I := 0 to FRootStates.Count - 1 do
  begin
    LState := FRootStates[I];
    if LCurrent >= LState.VisibleCount then
    begin
      Dec(LCurrent, LState.VisibleCount);
      LTop := ClampToInt(Int64(LTop) + LState.TotalHeight + StateExtra(LState));
      Continue;
    end;
    Exit(ClampToInt(Int64(LTop) + GetRowTopFromState(LState, LCurrent)));
  end;
  Result := LTop;
end;

function TGroupedRowViewProvider.GetRowIndexAtVirtualY(const AVirtualY: Integer): Integer;
begin
  Result := RowIndexAtVirtualY(Self, FCount, GetTotalHeight, AVirtualY);
end;

function TGroupedRowViewProvider.GetRowFromState(const AState: TGroupNodeState; const AIndex: Integer): TThemedGridViewRow;
var
  I, LIndex: Integer;
  LChild: TGroupNodeState;
begin
  if (AState = nil) or (AState.Node = nil) then
    Exit(nil);
  if AIndex = 0 then
    Exit(CreateGroupRow(AState));
  if not AState.Expanded then
    Exit(nil);
  LIndex := AIndex - 1;
  if (AState.Children <> nil) and (AState.Children.Count > 0) then
  begin
    for I := 0 to AState.Children.Count - 1 do
    begin
      LChild := AState.Children[I];
      if LIndex >= LChild.VisibleCount then
      begin
        Dec(LIndex, LChild.VisibleCount);
        Continue;
      end;
      Exit(GetRowFromState(LChild, LIndex));
    end;
    Exit(nil);
  end;
  Result := GetLeafRow(AState, LIndex);
end;

function TGroupedRowViewProvider.GetEstimatedHeightFromState(const AState: TGroupNodeState; const AIndex: Integer): Integer;
var
  I, LIndex, LPosition: Integer;
  LChild: TGroupNodeState;
begin
  if (AState = nil) or (AState.Node = nil) then
    Exit(FDefaultRowHeight);
  if AIndex = 0 then
    Exit(FDefaultRowHeight);
  if not AState.Expanded then
    Exit(FDefaultRowHeight);
  LIndex := AIndex - 1;
  if (AState.Children <> nil) and (AState.Children.Count > 0) then
  begin
    for I := 0 to AState.Children.Count - 1 do
    begin
      LChild := AState.Children[I];
      if LIndex >= LChild.VisibleCount then
      begin
        Dec(LIndex, LChild.VisibleCount);
        Continue;
      end;
      Exit(GetEstimatedHeightFromState(LChild, LIndex));
    end;
    Exit(FDefaultRowHeight);
  end;
  if Length(AState.DetailVirtualIndexes) > 0 then
    LPosition := BinarySearchIndex(AState.DetailVirtualIndexes, LIndex)
  else
    LPosition := -1;
  if LPosition >= 0 then
    Result := DetailHeightFor(AState.DetailDataIndexes[LPosition])
  else
    Result := FDefaultRowHeight;
end;

function TGroupedRowViewProvider.GetRowTopFromState(const AState: TGroupNodeState; const AIndex: Integer): Integer;
var
  I, LIndex, LTop, LDetailsBefore, LNormalBefore: Integer;
  LChild: TGroupNodeState;
begin
  if (AState = nil) or (AState.Node = nil) or (AIndex <= 0) then
    Exit(0);
  if not AState.Expanded then
    Exit(0);
  LTop := FDefaultRowHeight;
  LIndex := AIndex - 1;
  if (AState.Children <> nil) and (AState.Children.Count > 0) then
  begin
    for I := 0 to AState.Children.Count - 1 do
    begin
      LChild := AState.Children[I];
      if LIndex >= LChild.VisibleCount then
      begin
        Dec(LIndex, LChild.VisibleCount);
        LTop := ClampToInt(Int64(LTop) + LChild.TotalHeight + StateExtra(LChild));
        Continue;
      end;
      Exit(ClampToInt(Int64(LTop) + GetRowTopFromState(LChild, LIndex)));
    end;
    Exit(LTop);
  end;
  LDetailsBefore := CountLessThan(AState.DetailVirtualIndexes, LIndex);
  LNormalBefore := LIndex - LDetailsBefore;
  EnsureLeafPrefix(AState);
  Result := ClampToInt(Int64(LTop) + Int64(LNormalBefore) * FDefaultRowHeight + Int64(LDetailsBefore) * FDetailHeight +
    AState.DetailPrefix[LDetailsBefore]);
end;

function TGroupedRowViewProvider.GetLeafRow(const AState: TGroupNodeState; const AIndex: Integer): TThemedGridViewRow;
var
  LDetailPosition, LDataSourceIndex, LDetailsBefore, LDataPosition: Integer;
begin
  if (AState = nil) or (AState.Node = nil) or (AState.Node.DataIndexes = nil) then
    Exit(nil);
  if Length(AState.DetailVirtualIndexes) > 0 then
    LDetailPosition := BinarySearchIndex(AState.DetailVirtualIndexes, AIndex)
  else
    LDetailPosition := -1;
  if LDetailPosition >= 0 then
  begin
    LDataSourceIndex := AState.DetailDataIndexes[LDetailPosition];
    Exit(CreateDetailRow(LDataSourceIndex, TThemedGridRowViewBuilder.CreateDetailKey(LDataSourceIndex),
      DetailHeightFor(LDataSourceIndex), FEmptyDetailText));
  end;
  LDetailsBefore := CountLessThan(AState.DetailVirtualIndexes, AIndex);
  LDataPosition := AIndex - LDetailsBefore;
  if (LDataPosition < 0) or (LDataPosition >= AState.Node.DataIndexes.Count) then
    Exit(nil);
  Result := CreateDataRow(AState.Node.DataIndexes[LDataPosition], FDefaultRowHeight);
end;

function TGroupedRowViewProvider.CreateGroupRow(const AState: TGroupNodeState): TThemedGridViewRow;
var
  LNode: TGroupNode;
begin
  LNode := AState.Node;
  Result := TThemedGridViewRow.Create;
  Result.Kind := TThemedGridViewRowKind.GroupHeader;
  Result.DataSourceIndex := -1;
  Result.Level := LNode.Level;
  Result.Height := FDefaultRowHeight;
  Result.Visible := True;
  Result.Expanded := AState.Expanded;
  Result.Key := TValue.From<string>(LNode.Key);
  Result.GroupValue := LNode.Value;
  Result.GroupColumn := LNode.GroupColumn;
  Result.GroupColumnName := LNode.GroupColumnName;
  Result.ChildCount := LNode.ChildCount;
  Result.DisplayText := LNode.DisplayText;
end;

{ group building }

function FormatGroupValue(const AValue: TValue; const AColumn: TThemedGridColumn;
  const AOptions: TThemedGridGroupingOptions): string;
begin
  if TThemedGridValueConverter.IsNull(AValue) then
  begin
    if AOptions <> nil then
      Exit(AOptions.NullText);
    Exit('');
  end;
  Result := '';
  if (AColumn <> nil) and (AColumn.FormatString <> '') then
  begin
    try
      Result := TThemedGridValueFormatter.Format(AValue, AColumn, nil);
    except
      on Exception do
        Result := '';
    end;
  end;
  if Result = '' then
    Result := TThemedGridValueConverter.ToText(AValue);
  if Result = '' then
  begin
    if AOptions <> nil then
      Exit(AOptions.EmptyText);
    Exit('');
  end;
end;

function CreateValueKey(const AValue: TValue; const ADisplayText: string): string;
var
  LType: PTypeInfo;
  LTypeName: string;
begin
  if TThemedGridValueConverter.IsNull(AValue) then
    Exit('<null>');
  LType := ThemedGridRuntimeTypeOf(AValue);
  if LType <> nil then
    LTypeName := GetTypeName(LType)
  else
    LTypeName := '';
  Result := LTypeName + '|' + TThemedGridValueConverter.ToTextInvariant(AValue) + '|' + ADisplayText;
end;

function CreateGroupKey(const AParentKey: string; const ADescriptor: TThemedGridGroupDescriptor;
  const AValue: TValue; const ADisplayText: string): string;
var
  LColumnName, LLocalKey: string;
begin
  LColumnName := '';
  if ADescriptor <> nil then
  begin
    if ADescriptor.Column <> nil then
      LColumnName := ADescriptor.Column.Name
    else
      LColumnName := ADescriptor.ColumnName;
  end;
  LLocalKey := LColumnName + '=' + CreateValueKey(AValue, ADisplayText);
  if AParentKey = '' then
    Result := LLocalKey
  else
    Result := AParentKey + '/' + LLocalKey;
end;

function CreateGroupText(const ADescriptor: TThemedGridGroupDescriptor; const ABucket: TGroupBucket;
  const AOptions: TThemedGridGroupingOptions): string;
var
  LCaption: string;
begin
  LCaption := '';
  if (ADescriptor <> nil) and (ADescriptor.Column <> nil) then
    LCaption := ADescriptor.Column.HeaderText;
  if (LCaption = '') and (ADescriptor <> nil) then
    LCaption := ADescriptor.ColumnName;
  Result := LCaption + ': ';
  if ABucket <> nil then
    Result := Result + ABucket.DisplayText;
  if (AOptions <> nil) and AOptions.ShowGroupCount and (ABucket <> nil) then
    Result := Result + ' (' + IntToStr(ABucket.DataIndexes.Count) + ')';
end;

function CreateBuckets(const ADataController: IThemedGridDataController; const ADataIndexes: TList<Integer>;
  const ADescriptor: TThemedGridGroupDescriptor; const AOptions: TThemedGridGroupingOptions): TObjectList<TGroupBucket>;
var
  LMap: TDictionary<string, TGroupBucket>;
  I, LDataSourceIndex: Integer;
  LValue: TValue;
  LDisplayText, LKey: string;
  LBucket: TGroupBucket;
begin
  Result := TObjectList<TGroupBucket>.Create(True);
  LMap := TDictionary<string, TGroupBucket>.Create;
  try
    if ADataIndexes <> nil then
      for I := 0 to ADataIndexes.Count - 1 do
      begin
        LDataSourceIndex := ADataIndexes[I];
        LValue := ADataController.GetValue(LDataSourceIndex, ADescriptor.Column);
        if TThemedGridValueConverter.IsNull(LValue) then
          LValue := TValue.Empty;
        LDisplayText := FormatGroupValue(LValue, ADescriptor.Column, AOptions);
        LKey := CreateValueKey(LValue, LDisplayText);
        if not LMap.TryGetValue(LKey, LBucket) then
        begin
          LBucket := TGroupBucket.Create;
          LBucket.Value := LValue;
          LBucket.DisplayText := LDisplayText;
          LBucket.DataIndexes := TList<Integer>.Create;
          LMap.Add(LKey, LBucket);
          Result.Add(LBucket);
        end;
        LBucket.DataIndexes.Add(LDataSourceIndex);
      end;
  finally
    LMap.Free;
  end;
end;

procedure SortBuckets(const ABuckets: TObjectList<TGroupBucket>; const ADirection: TThemedGridSortDirection);
begin
  if ADirection = TThemedGridSortDirection.None then
    Exit;
  ABuckets.Sort(TComparer<TGroupBucket>.Construct(
    function(const ALeft, ARight: TGroupBucket): Integer
    var
      LLeft, LRight: string;
    begin
      if ALeft <> nil then
        LLeft := ALeft.DisplayText
      else
        LLeft := '';
      if ARight <> nil then
        LRight := ARight.DisplayText
      else
        LRight := '';
      Result := Sign(CompareText(LLeft, LRight, loUserLocale));
    end));
  if ADirection = TThemedGridSortDirection.Descending then
    ABuckets.Reverse;
end;

function BuildGroupNodes(const ADataController: IThemedGridDataController; const ADataIndexes: TList<Integer>;
  const AGroups: TList<TThemedGridGroupDescriptor>; const AGroupLevel: Integer; const AParentKey: string;
  const AOptions: TThemedGridGroupingOptions): TObjectList<TGroupNode>;
var
  LDescriptor: TThemedGridGroupDescriptor;
  LBuckets: TObjectList<TGroupBucket>;
  LBucket: TGroupBucket;
  LNode: TGroupNode;
  I: Integer;
  LKey: string;
begin
  Result := TObjectList<TGroupNode>.Create(True);
  if (AGroupLevel < 0) or (AGroupLevel >= AGroups.Count) then
    Exit;
  LDescriptor := AGroups[AGroupLevel];
  LBuckets := CreateBuckets(ADataController, ADataIndexes, LDescriptor, AOptions);
  try
    SortBuckets(LBuckets, LDescriptor.SortDirection);
    for I := 0 to LBuckets.Count - 1 do
    begin
      LBucket := LBuckets[I];
      LKey := CreateGroupKey(AParentKey, LDescriptor, LBucket.Value, LBucket.DisplayText);
      LNode := TGroupNode.Create;
      LNode.Key := LKey;
      LNode.Level := AGroupLevel;
      LNode.DefaultExpanded := LDescriptor.Expanded;
      LNode.Value := LBucket.Value;
      LNode.DisplayText := CreateGroupText(LDescriptor, LBucket, AOptions);
      LNode.GroupColumn := LDescriptor.Column;
      if LDescriptor.Column <> nil then
        LNode.GroupColumnName := LDescriptor.Column.Name
      else
        LNode.GroupColumnName := LDescriptor.ColumnName;
      LNode.ChildCount := LBucket.DataIndexes.Count;
      if AGroupLevel + 1 < AGroups.Count then
      begin
        LNode.Children.Free;
        LNode.Children := BuildGroupNodes(ADataController, LBucket.DataIndexes, AGroups, AGroupLevel + 1,
          LKey, AOptions);
      end;
      LNode.DataIndexes := LBucket.DataIndexes;
      LBucket.DataIndexes := nil;
      Result.Add(LNode);
    end;
  finally
    LBuckets.Free;
  end;
end;

function CreateGroupCacheKey(const ADataController: IThemedGridDataController;
  const AActiveGroups: TList<TThemedGridGroupDescriptor>; const AOptions: TThemedGridGroupingOptions): string;
var
  LBuilder: TStringBuilder;
  I: Integer;
  LGroup: TThemedGridGroupDescriptor;
  LColumn: TThemedGridColumn;
begin
  LBuilder := TStringBuilder.Create(256);
  try
    LBuilder.Append(IntToHex(NativeUInt(Pointer(ADataController)), SizeOf(NativeUInt) * 2));
    LBuilder.Append('|V=').Append(ADataController.Version);
    LBuilder.Append('|R=').Append(ADataController.RowCount);
    LBuilder.Append('|O=');
    if (AOptions <> nil) and AOptions.ShowGroupCount then
      LBuilder.Append('1')
    else
      LBuilder.Append('0');
    LBuilder.Append('|N=');
    if AOptions <> nil then
      LBuilder.Append(AOptions.NullText);
    LBuilder.Append('|E=');
    if AOptions <> nil then
      LBuilder.Append(AOptions.EmptyText);
    for I := 0 to AActiveGroups.Count - 1 do
    begin
      LGroup := AActiveGroups[I];
      if LGroup <> nil then
        LColumn := LGroup.Column
      else
        LColumn := nil;
      LBuilder.Append('|G').Append(I).Append('=');
      if LColumn <> nil then
      begin
        LBuilder.Append(LColumn.Name).Append(',').Append(LColumn.HeaderText).Append(',');
        LBuilder.Append(LColumn.FieldName).Append(',').Append(LColumn.FormatString);
      end
      else if LGroup <> nil then
        LBuilder.Append(LGroup.ColumnName);
      LBuilder.Append(',');
      if LGroup <> nil then
        LBuilder.Append(GetEnumName(System.TypeInfo(TThemedGridSortDirection), Ord(LGroup.SortDirection)));
      LBuilder.Append(',');
      if (LGroup <> nil) and LGroup.Expanded then
        LBuilder.Append('1')
      else
        LBuilder.Append('0');
    end;
    Result := LBuilder.ToString;
  finally
    LBuilder.Free;
  end;
end;

function BuildGroupCacheEntry(const ADataController: IThemedGridDataController;
  const AActiveGroups: TList<TThemedGridGroupDescriptor>; const AOptions: TThemedGridGroupingOptions;
  const ACacheKey: string): IGroupCacheEntry;
var
  LDataIndexes: TList<Integer>;
  LRowCount, LRowIndex, LDataSourceIndex: Integer;
begin
  LDataIndexes := TList<Integer>.Create;
  try
    LRowCount := ADataController.RowCount;
    if LRowCount > 0 then
      LDataIndexes.Capacity := LRowCount;
    for LRowIndex := 0 to LRowCount - 1 do
    begin
      LDataSourceIndex := ADataController.GetDataSourceIndex(LRowIndex);
      if LDataSourceIndex >= 0 then
        LDataIndexes.Add(LDataSourceIndex);
    end;
    Result := TGroupCacheEntry.Create(ACacheKey, ADataController,
      BuildGroupNodes(ADataController, LDataIndexes, AActiveGroups, 0, '', AOptions));
  finally
    LDataIndexes.Free;
  end;
end;

function GetOrCreateGroupCacheEntry(const ADataController: IThemedGridDataController;
  const AActiveGroups: TList<TThemedGridGroupDescriptor>; const AOptions: TThemedGridGroupingOptions): IGroupCacheEntry;
var
  LKey, LOldKey: string;
  LCached, LCreated: IGroupCacheEntry;
begin
  LKey := CreateGroupCacheKey(ADataController, AActiveGroups, AOptions);
  GGroupCacheLock.Enter;
  try
    if GGroupCache.TryGetValue(LKey, LCached) then
      Exit(LCached);
  finally
    GGroupCacheLock.Leave;
  end;
  LCreated := BuildGroupCacheEntry(ADataController, AActiveGroups, AOptions, LKey);
  GGroupCacheLock.Enter;
  try
    if GGroupCache.TryGetValue(LKey, LCached) then
      Exit(LCached);
    GGroupCache.AddOrSetValue(LKey, LCreated);
    GGroupCacheOrder.Enqueue(LKey);
    while (GGroupCache.Count > MaximumGroupCacheEntries) and (GGroupCacheOrder.Count > 0) do
    begin
      LOldKey := GGroupCacheOrder.Dequeue;
      GGroupCache.Remove(LOldKey);
    end;
    Result := LCreated;
  finally
    GGroupCacheLock.Leave;
  end;
end;

function GetActiveGroups(const AGroups: TThemedGridGroupDescriptorCollection): TList<TThemedGridGroupDescriptor>;
var
  I: Integer;
  LGroup: TThemedGridGroupDescriptor;
begin
  Result := TList<TThemedGridGroupDescriptor>.Create;
  for I := 0 to AGroups.Count - 1 do
  begin
    LGroup := AGroups[I];
    if (LGroup = nil) or (not LGroup.IsValid) then
      Continue;
    if LGroup.Column = nil then
      Continue;
    Result.Add(LGroup);
  end;
end;

{ TThemedGridRowViewBuilder }

class procedure TThemedGridRowViewBuilder.Build(const ADataController: IThemedGridDataController;
  const ARowView: TThemedGridRowView; const ADefaultRowHeight: Integer);
begin
  Build(ADataController, ARowView, ADefaultRowHeight, nil, nil, nil, nil, nil);
end;

class procedure TThemedGridRowViewBuilder.Build(const ADataController: IThemedGridDataController;
  const ARowView: TThemedGridRowView; const ADefaultRowHeight: Integer;
  const AGroups: TThemedGridGroupDescriptorCollection; const ACollapsedGroupKeys: TThemedGridStringSet;
  const AGroupingOptions: TThemedGridGroupingOptions);
begin
  Build(ADataController, ARowView, ADefaultRowHeight, AGroups, ACollapsedGroupKeys, AGroupingOptions, nil, nil);
end;

class procedure TThemedGridRowViewBuilder.Build(const ADataController: IThemedGridDataController;
  const ARowView: TThemedGridRowView; const ADefaultRowHeight: Integer;
  const AGroups: TThemedGridGroupDescriptorCollection; const ACollapsedGroupKeys: TThemedGridStringSet;
  const AGroupingOptions: TThemedGridGroupingOptions; const AExpandedDetailKeys: TThemedGridStringSet;
  const ADetailOptions: TThemedGridDetailOptions);
var
  LHeight: Integer;
  LActive: TList<TThemedGridGroupDescriptor>;
  LEntry: IGroupCacheEntry;
begin
  if ARowView = nil then
    Exit;
  ARowView.Clear;
  if ADataController = nil then
    Exit;
  LHeight := ADefaultRowHeight;
  if LHeight < 1 then
    LHeight := 1;
  if (AGroups = nil) or (AGroups.Count = 0) or (AGroupingOptions = nil) or (not AGroupingOptions.Enabled) then
  begin
    ARowView.SetProvider(TFlatRowViewProvider.Create(ADataController, LHeight, AExpandedDetailKeys, ADetailOptions,
      ARowView.DetailHeights));
    Exit;
  end;
  LActive := GetActiveGroups(AGroups);
  try
    if LActive.Count = 0 then
    begin
      ARowView.SetProvider(TFlatRowViewProvider.Create(ADataController, LHeight, AExpandedDetailKeys, ADetailOptions,
      ARowView.DetailHeights));
      Exit;
    end;
    LEntry := GetOrCreateGroupCacheEntry(ADataController, LActive, AGroupingOptions);
  finally
    LActive.Free;
  end;
  ARowView.SetProvider(TGroupedRowViewProvider.Create(ADataController, LEntry, LHeight, ACollapsedGroupKeys,
    AExpandedDetailKeys, ADetailOptions, ARowView.DetailHeights));
end;

class procedure TThemedGridRowViewBuilder.ClearGroupCache;
begin
  GGroupCacheLock.Enter;
  try
    GGroupCache.Clear;
    GGroupCacheOrder.Clear;
  finally
    GGroupCacheLock.Leave;
  end;
end;

class function TThemedGridRowViewBuilder.CreateDetailKey(const ADataSourceIndex: Integer): string;
begin
  Result := DetailKeyPrefix + IntToStr(ADataSourceIndex);
end;

initialization
  GGroupCache := TDictionary<string, IGroupCacheEntry>.Create;
  GGroupCacheOrder := TQueue<string>.Create;
  GGroupCacheLock := TCriticalSection.Create;

finalization
  GGroupCache.Free;
  GGroupCacheOrder.Free;
  GGroupCacheLock.Free;

end.

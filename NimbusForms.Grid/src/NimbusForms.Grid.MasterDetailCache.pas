unit NimbusForms.Grid.MasterDetailCache;

{$SCOPEDENUMS ON}

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.Generics.Defaults,
  NimbusForms.Grid.MasterDetailData;

type
  TThemedGridMasterDetailCacheKey = record
  private
    FParentDataSourceIndex: Integer;
    FRelationIndex: Integer;
    FRelationName: string;
    FDataVersion: Integer;
  public
    constructor Create(const AParentDataSourceIndex, ARelationIndex: Integer; const ARelationName: string;
      const ADataVersion: Integer);
    function Equals(const AOther: TThemedGridMasterDetailCacheKey): Boolean;
    function GetHashCode: Integer;
    property ParentDataSourceIndex: Integer read FParentDataSourceIndex;
    property RelationIndex: Integer read FRelationIndex;
    property RelationName: string read FRelationName;
    property DataVersion: Integer read FDataVersion;
  end;

  TThemedGridMasterDetailCache = class
  private
    FItems: TObjectDictionary<TThemedGridMasterDetailCacheKey, TThemedGridMasterDetailData>;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function TryGet(const AKey: TThemedGridMasterDetailCacheKey; out AData: TThemedGridMasterDetailData): Boolean;
    procedure Store(const AKey: TThemedGridMasterDetailCacheKey; const AData: TThemedGridMasterDetailData);
    procedure Remove(const AKey: TThemedGridMasterDetailCacheKey);
    procedure Clear;
    procedure ClearForParentDataSourceIndex(const AParentDataSourceIndex: Integer);
    procedure ClearOtherVersions(const ADataVersion: Integer);
    property Count: Integer read GetCount;
  end;

const
  CThemedGridMasterDetailCacheLimit = 512;

implementation

type
  TKeyComparer = class(TEqualityComparer<TThemedGridMasterDetailCacheKey>)
  public
    function Equals(const ALeft, ARight: TThemedGridMasterDetailCacheKey): Boolean; override;
    function GetHashCode(const AValue: TThemedGridMasterDetailCacheKey): Integer; override;
  end;

constructor TThemedGridMasterDetailCacheKey.Create(const AParentDataSourceIndex, ARelationIndex: Integer;
  const ARelationName: string; const ADataVersion: Integer);
begin
  FParentDataSourceIndex := AParentDataSourceIndex;
  FRelationIndex := ARelationIndex;
  FRelationName := ARelationName;
  FDataVersion := ADataVersion;
end;

function TThemedGridMasterDetailCacheKey.Equals(const AOther: TThemedGridMasterDetailCacheKey): Boolean;
begin
  Result := (FParentDataSourceIndex = AOther.FParentDataSourceIndex) and
    (FRelationIndex = AOther.FRelationIndex) and (FDataVersion = AOther.FDataVersion) and
    (FRelationName = AOther.FRelationName);
end;

function TThemedGridMasterDetailCacheKey.GetHashCode: Integer;
begin
  Result := 17;
  Result := Result * 31 + FParentDataSourceIndex;
  Result := Result * 31 + FRelationIndex;
  Result := Result * 31 + FDataVersion;
  Result := Result * 31 + FRelationName.GetHashCode;
end;

function TKeyComparer.Equals(const ALeft, ARight: TThemedGridMasterDetailCacheKey): Boolean;
begin
  Result := ALeft.Equals(ARight);
end;

function TKeyComparer.GetHashCode(const AValue: TThemedGridMasterDetailCacheKey): Integer;
begin
  Result := AValue.GetHashCode;
end;

constructor TThemedGridMasterDetailCache.Create;
begin
  inherited Create;
  FItems := TObjectDictionary<TThemedGridMasterDetailCacheKey, TThemedGridMasterDetailData>.Create(
    [doOwnsValues], TKeyComparer.Create);
end;

destructor TThemedGridMasterDetailCache.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function TThemedGridMasterDetailCache.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TThemedGridMasterDetailCache.TryGet(const AKey: TThemedGridMasterDetailCacheKey;
  out AData: TThemedGridMasterDetailData): Boolean;
begin
  Result := FItems.TryGetValue(AKey, AData);
end;

procedure TThemedGridMasterDetailCache.Store(const AKey: TThemedGridMasterDetailCacheKey;
  const AData: TThemedGridMasterDetailData);
begin
  if AData = nil then
  begin
    FItems.Remove(AKey);
    Exit;
  end;
  if (FItems.Count >= CThemedGridMasterDetailCacheLimit) and not FItems.ContainsKey(AKey) then
    ClearOtherVersions(AKey.DataVersion);
  FItems.AddOrSetValue(AKey, AData);
end;

procedure TThemedGridMasterDetailCache.Remove(const AKey: TThemedGridMasterDetailCacheKey);
begin
  FItems.Remove(AKey);
end;

procedure TThemedGridMasterDetailCache.Clear;
begin
  FItems.Clear;
end;

procedure TThemedGridMasterDetailCache.ClearForParentDataSourceIndex(const AParentDataSourceIndex: Integer);
var
  LKeys: TList<TThemedGridMasterDetailCacheKey>;
  LPair: TPair<TThemedGridMasterDetailCacheKey, TThemedGridMasterDetailData>;
  I: Integer;
begin
  LKeys := TList<TThemedGridMasterDetailCacheKey>.Create;
  try
    for LPair in FItems do
      if LPair.Key.ParentDataSourceIndex = AParentDataSourceIndex then
        LKeys.Add(LPair.Key);
    for I := 0 to LKeys.Count - 1 do
      FItems.Remove(LKeys[I]);
  finally
    LKeys.Free;
  end;
end;

procedure TThemedGridMasterDetailCache.ClearOtherVersions(const ADataVersion: Integer);
var
  LKeys: TList<TThemedGridMasterDetailCacheKey>;
  LPair: TPair<TThemedGridMasterDetailCacheKey, TThemedGridMasterDetailData>;
  I: Integer;
begin
  LKeys := TList<TThemedGridMasterDetailCacheKey>.Create;
  try
    for LPair in FItems do
      if LPair.Key.DataVersion <> ADataVersion then
        LKeys.Add(LPair.Key);
    for I := 0 to LKeys.Count - 1 do
      FItems.Remove(LKeys[I]);
  finally
    LKeys.Free;
  end;
end;

end.

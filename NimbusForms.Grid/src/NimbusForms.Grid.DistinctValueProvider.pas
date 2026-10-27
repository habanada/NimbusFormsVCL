unit NimbusForms.Grid.DistinctValueProvider;

interface

uses
  System.SysUtils,
  System.Rtti,
  System.Generics.Collections,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.DistinctValue;

type
  IThemedGridValueSource = interface
    ['{A4F29D61-0C7E-4B83-95D1-7E3B8A5C6F20}']
    function GetRowCount: Integer;
    function GetValue(const ARowIndex: Integer; const AColumnName: string): TValue;
    function GetCacheIdentity: NativeInt;
    property RowCount: Integer read GetRowCount;
  end;

  TThemedGridDistinctValueProvider = class
  public
    const
      NullDisplayText = '(Null)';
      EmptyDisplayText = '(Leer)';
      MaxCacheEntries = 128;
    class function GetValues(const ASource: IThemedGridValueSource; const AColumn: TThemedGridColumn;
      const ADataVersion, AMaxScanRows, AMaxDistinctCount: Integer): TObjectList<TThemedGridDistinctValue>; static;
    class procedure ClearCache; static;
  end;

implementation

uses
  System.TypInfo,
  System.Generics.Defaults,
  System.SyncObjs,
  NimbusForms.Grid.ValueConverter,
  NimbusForms.Grid.ValueFormatter;

type
  TCacheEntry = class
  public
    Values: TObjectList<TThemedGridDistinctValue>;
    constructor Create(const AValues: TObjectList<TThemedGridDistinctValue>);
    destructor Destroy; override;
  end;

var
  GCache: TObjectDictionary<string, TCacheEntry>;
  GCacheLock: TCriticalSection;

constructor TCacheEntry.Create(const AValues: TObjectList<TThemedGridDistinctValue>);
begin
  inherited Create;
  Values := AValues;
end;

destructor TCacheEntry.Destroy;
begin
  Values.Free;
  inherited Destroy;
end;

function CloneValues(const ASource: TObjectList<TThemedGridDistinctValue>): TObjectList<TThemedGridDistinctValue>;
var
  I: Integer;
begin
  Result := TObjectList<TThemedGridDistinctValue>.Create(True);
  if ASource = nil then
    Exit;
  for I := 0 to ASource.Count - 1 do
    if ASource[I] <> nil then
      Result.Add(ASource[I].Clone);
end;

function FormatDistinctValue(const AValue: TValue; const AColumn: TThemedGridColumn): string;
var
  LHandled: Boolean;
begin
  if TThemedGridValueConverter.IsNull(AValue) then
    Exit(TThemedGridDistinctValueProvider.NullDisplayText);

  if (AColumn <> nil) and (AColumn.FormatString <> '') then
  begin
    try
      if AColumn.HasFormatProvider then
        Result := TThemedGridValueFormatter.FormatByString(AValue, AColumn.FormatString,
          AColumn.FormatProvider, LHandled)
      else
        Result := TThemedGridValueFormatter.FormatByString(AValue, AColumn.FormatString,
          FormatSettings, LHandled);
      if LHandled then
        Exit;
    except
    end;
  end;

  Result := TThemedGridValueConverter.ToText(AValue);
  if Result = '' then
    Result := TThemedGridDistinctValueProvider.EmptyDisplayText;
end;

function CreateValueKey(const AValue: TValue; const ADisplayText: string): string;
begin
  if TThemedGridValueConverter.IsNull(AValue) then
    Exit('<null>');
  Result := GetTypeName(AValue.TypeInfo) + '|' + TThemedGridValueConverter.ToTextInvariant(AValue) + '|' + ADisplayText;
end;

function BuildValues(const ASource: IThemedGridValueSource; const AColumn: TThemedGridColumn;
  const AMaxScanRows, AMaxDistinctCount: Integer): TObjectList<TThemedGridDistinctValue>;
var
  LMap: TDictionary<string, TThemedGridDistinctValue>;
  LRowCount, LRowIndex: Integer;
  LValue: TValue;
  LDisplayText, LKey: string;
  LDistinct: TThemedGridDistinctValue;
begin
  Result := TObjectList<TThemedGridDistinctValue>.Create(True);
  LMap := TDictionary<string, TThemedGridDistinctValue>.Create(TIStringComparer.Ordinal);
  try
    LRowCount := ASource.RowCount;
    if (AMaxScanRows > 0) and (LRowCount > AMaxScanRows) then
      LRowCount := AMaxScanRows;

    for LRowIndex := 0 to LRowCount - 1 do
    begin
      LValue := ASource.GetValue(LRowIndex, AColumn.Name);
      if TThemedGridValueConverter.IsNull(LValue) then
        LValue := TValue.Empty;

      LDisplayText := FormatDistinctValue(LValue, AColumn);
      LKey := CreateValueKey(LValue, LDisplayText);

      if LMap.TryGetValue(LKey, LDistinct) then
      begin
        LDistinct.Count := LDistinct.Count + 1;
        Continue;
      end;

      if (AMaxDistinctCount > 0) and (Result.Count >= AMaxDistinctCount) then
        Break;

      LDistinct := TThemedGridDistinctValue.Create;
      LDistinct.Value := LValue;
      LDistinct.DisplayText := LDisplayText;
      LDistinct.Count := 1;
      LMap.Add(LKey, LDistinct);
      Result.Add(LDistinct);
    end;
  finally
    LMap.Free;
  end;

  Result.Sort(TComparer<TThemedGridDistinctValue>.Construct(
    function(const ALeft, ARight: TThemedGridDistinctValue): Integer
    begin
      Result := AnsiCompareText(ALeft.DisplayText, ARight.DisplayText);
    end));
end;

class function TThemedGridDistinctValueProvider.GetValues(const ASource: IThemedGridValueSource;
  const AColumn: TThemedGridColumn; const ADataVersion, AMaxScanRows,
  AMaxDistinctCount: Integer): TObjectList<TThemedGridDistinctValue>;
var
  LKey: string;
  LEntry: TCacheEntry;
begin
  if (ASource = nil) or (AColumn = nil) then
    Exit(TObjectList<TThemedGridDistinctValue>.Create(True));

  LKey := IntToStr(ASource.GetCacheIdentity) + '|' + AColumn.Name + '|' + IntToStr(ADataVersion) + '|' +
    IntToStr(AMaxScanRows) + '|' + IntToStr(AMaxDistinctCount);

  GCacheLock.Enter;
  try
    if GCache.TryGetValue(LKey, LEntry) then
      Exit(CloneValues(LEntry.Values));
  finally
    GCacheLock.Leave;
  end;

  Result := BuildValues(ASource, AColumn, AMaxScanRows, AMaxDistinctCount);

  LEntry := TCacheEntry.Create(CloneValues(Result));
  GCacheLock.Enter;
  try
    GCache.AddOrSetValue(LKey, LEntry);
    if GCache.Count > MaxCacheEntries then
      GCache.Clear;
  finally
    GCacheLock.Leave;
  end;
end;

class procedure TThemedGridDistinctValueProvider.ClearCache;
begin
  GCacheLock.Enter;
  try
    GCache.Clear;
  finally
    GCacheLock.Leave;
  end;
end;

initialization
  GCacheLock := TCriticalSection.Create;
  GCache := TObjectDictionary<string, TCacheEntry>.Create([doOwnsValues]);

finalization
  GCache.Free;
  GCacheLock.Free;

end.

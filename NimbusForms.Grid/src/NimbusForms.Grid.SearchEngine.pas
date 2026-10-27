unit NimbusForms.Grid.SearchEngine;

{$SCOPEDENUMS ON}

interface

uses
  System.SysUtils,
  System.StrUtils,
  System.Generics.Collections,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.SearchOptions,
  NimbusForms.Grid.SearchMatch,
  NimbusForms.Grid.SearchResult;

type
  IThemedGridSearchHost = interface
    ['{5B1D7C42-3E8A-4F60-9A2B-D14C8E6F0A37}']
    function GetRowCount: Integer;
    function GetSearchColumns(const AIncludeHiddenColumns: Boolean): TArray<TThemedGridColumn>;
    function TryGetSearchText(const ARowIndex: Integer; const AColumn: TThemedGridColumn;
      out ADisplayText: string; out ADataSourceIndex: Integer): Boolean;
    property RowCount: Integer read GetRowCount;
  end;

  TThemedGridSearchEngine = class
  private
    class function IndexOfText(const AHaystack, ANeedle: string; const ACaseSensitive: Boolean): Integer; static;
    class function FindTokenMatch(const ADisplayText, AText: string; const ACaseSensitive: Boolean): Integer; static;
    class function FindMatch(const ADisplayText, AText: string; const AMode: TThemedGridSearchMode;
      const ACaseSensitive: Boolean): Integer; static;
  public
    function Search(const AHost: IThemedGridSearchHost; const AText: string;
      const AOptions: TThemedGridSearchOptions): TObjectList<TThemedGridSearchResult>;
  end;

implementation

class function TThemedGridSearchEngine.IndexOfText(const AHaystack, ANeedle: string;
  const ACaseSensitive: Boolean): Integer;
begin
  if ANeedle = '' then
    Exit(0);
  if ACaseSensitive then
    Result := Pos(ANeedle, AHaystack) - 1
  else
    Result := Pos(AnsiLowerCase(ANeedle), AnsiLowerCase(AHaystack)) - 1;
end;

class function TThemedGridSearchEngine.FindTokenMatch(const ADisplayText, AText: string;
  const ACaseSensitive: Boolean): Integer;
var
  LTokens: TArray<string>;
  I, LIndex: Integer;
begin
  LTokens := AText.Split([' '], TStringSplitOptions.ExcludeEmpty);
  if Length(LTokens) = 0 then
    Exit(-1);
  Result := -1;
  for I := 0 to High(LTokens) do
  begin
    LIndex := IndexOfText(ADisplayText, LTokens[I], ACaseSensitive);
    if LIndex < 0 then
      Exit(-1);
    if (Result < 0) or (LIndex < Result) then
      Result := LIndex;
  end;
end;

class function TThemedGridSearchEngine.FindMatch(const ADisplayText, AText: string;
  const AMode: TThemedGridSearchMode; const ACaseSensitive: Boolean): Integer;
var
  LMatched: Boolean;
begin
  case AMode of
    TThemedGridSearchMode.Exact:
      begin
        if ACaseSensitive then
          LMatched := SameStr(ADisplayText, AText)
        else
          LMatched := AnsiSameText(ADisplayText, AText);
        if LMatched then
          Result := 0
        else
          Result := -1;
      end;
    TThemedGridSearchMode.StartsWith:
      begin
        if ACaseSensitive then
          LMatched := AnsiStartsStr(AText, ADisplayText)
        else
          LMatched := AnsiStartsText(AText, ADisplayText);
        if LMatched then
          Result := 0
        else
          Result := -1;
      end;
    TThemedGridSearchMode.TokenContains:
      Result := FindTokenMatch(ADisplayText, AText, ACaseSensitive);
  else
    Result := IndexOfText(ADisplayText, AText, ACaseSensitive);
  end;
end;

function TThemedGridSearchEngine.Search(const AHost: IThemedGridSearchHost; const AText: string;
  const AOptions: TThemedGridSearchOptions): TObjectList<TThemedGridSearchResult>;
var
  LOptions, LOwnOptions: TThemedGridSearchOptions;
  LColumns: TArray<TThemedGridColumn>;
  LColumn: TThemedGridColumn;
  LResult: TThemedGridSearchResult;
  LMatch: TThemedGridSearchMatch;
  LDisplayText: string;
  LDataSourceIndex, LMatchIndex, LRowIndex, LColumnIndex, LRowCount: Integer;
begin
  Result := TObjectList<TThemedGridSearchResult>.Create(True);
  if (AHost = nil) or (AText = '') then
    Exit;

  LOwnOptions := nil;
  LOptions := AOptions;
  if LOptions = nil then
  begin
    LOwnOptions := TThemedGridSearchOptions.Create;
    LOptions := LOwnOptions;
  end;
  try
    if Length(AText) < LOptions.MinimumSearchLength then
      Exit;

    LColumns := AHost.GetSearchColumns(LOptions.IncludeHiddenColumns);
    if Length(LColumns) = 0 then
      Exit;

    LRowCount := AHost.RowCount;
    for LRowIndex := 0 to LRowCount - 1 do
      for LColumnIndex := 0 to High(LColumns) do
      begin
        LColumn := LColumns[LColumnIndex];
        if LColumn = nil then
          Continue;
        if not AHost.TryGetSearchText(LRowIndex, LColumn, LDisplayText, LDataSourceIndex) then
          Continue;
        if LDisplayText = '' then
          Continue;

        LMatchIndex := FindMatch(LDisplayText, AText, LOptions.Mode, LOptions.CaseSensitive);
        if LMatchIndex < 0 then
          Continue;

        LResult := TThemedGridSearchResult.Create;
        LResult.RowIndex := LRowIndex;
        LResult.ColumnIndex := LColumnIndex;
        LResult.DataSourceIndex := LDataSourceIndex;
        LResult.Score := 100;

        LMatch := TThemedGridSearchMatch.Create;
        LMatch.StartIndex := LMatchIndex;
        LMatch.Length := Length(AText);
        LResult.Matches.Add(LMatch);
        Result.Add(LResult);

        if Result.Count >= LOptions.MaxResults then
          Exit;
      end;
  finally
    LOwnOptions.Free;
  end;
end;

end.

unit NimbusForms.HexEditor.SearchProviders;

interface

uses
  System.SysUtils, System.Generics.Collections, NimbusForms.HexEditor.DataSource,
  NimbusForms.HexEditor.Search;

type
  THexSearchMode = (hsmText, hsmHex, hsmPattern, hsmApproximate, hsmProvider);

  THexSearchQuery = class
  public
    Text: string;
    RawBytes: TBytes;
    Patterns: TArray<TBytes>;
    StartOffset: Int64;
    EndOffset: Int64;
    CaseSensitive: Boolean;
    Mode: THexSearchMode;
    ProviderOptions: TObject;
    MaxResults: Integer;
    MaxHammingDistance: Integer;
    Encoding: TEncoding;
    EncodingName: string;
    constructor Create;
    function Clone: THexSearchQuery;
  end;

  IHexSearchProvider = interface
    ['{27B06DDA-5DAB-428C-9A49-9A63E244305C}']
    function GetName: string;
    function Search(const ASource: IHexDataSource; const AQuery: THexSearchQuery): TObjectList<THexSearchMatch>;
    property Name: string read GetName;
  end;

  THexSearchProviderCollection = class
  private
    FProviders: TList<IHexSearchProvider>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const AProvider: IHexSearchProvider);
    function Remove(const AName: string): Boolean;
    function Find(const AName: string): IHexSearchProvider;
    function Names: TArray<string>;
  end;

  THexNativeSearchProvider = class(TInterfacedObject, IHexSearchProvider)
  public
    function GetName: string;
    function Search(const ASource: IHexDataSource; const AQuery: THexSearchQuery): TObjectList<THexSearchMatch>;
  end;

implementation

uses
  System.Classes, System.Math, NimbusForms.HexEditor.SearchService, NimbusForms.HexEditor.Pattern,
  NativePattern, NativePattern.Core,
  NimbusForms.HexEditor.Encoding,
  NimbusForms.HexEditor.PatternParser, NimbusForms.HexEditor.PatternSearch;

constructor THexSearchQuery.Create;
begin
  inherited Create;
  EndOffset := -1;
  CaseSensitive := True;
  MaxResults := 256;
  Encoding := TEncoding.UTF8;
end;

function THexSearchQuery.Clone: THexSearchQuery;
var
  I: Integer;
begin
  Result := THexSearchQuery.Create;
  Result.Text := Text;
  Result.RawBytes := Copy(RawBytes);
  SetLength(Result.Patterns, Length(Patterns));
  for I := 0 to High(Patterns) do Result.Patterns[I] := Copy(Patterns[I]);
  Result.StartOffset := StartOffset;
  Result.EndOffset := EndOffset;
  Result.CaseSensitive := CaseSensitive;
  Result.Mode := Mode;
  Result.ProviderOptions := ProviderOptions;
  Result.MaxResults := MaxResults;
  Result.MaxHammingDistance := MaxHammingDistance;
  Result.Encoding := Encoding;
  Result.EncodingName := EncodingName;
end;

constructor THexSearchProviderCollection.Create;
begin
  inherited Create;
  FProviders := TList<IHexSearchProvider>.Create;
  Add(THexNativeSearchProvider.Create);
end;

destructor THexSearchProviderCollection.Destroy;
begin
  FProviders.Free;
  inherited Destroy;
end;

procedure THexSearchProviderCollection.Add(const AProvider: IHexSearchProvider);
begin
  if AProvider = nil then raise EArgumentNilException.Create('AProvider');
  if Trim(AProvider.Name) = '' then raise EArgumentException.Create('A provider name is required');
  if Find(AProvider.Name) <> nil then raise EArgumentException.Create('A provider with this name already exists');
  FProviders.Add(AProvider);
end;

function THexSearchProviderCollection.Find(const AName: string): IHexSearchProvider;
var
  LProvider: IHexSearchProvider;
begin
  Result := nil;
  for LProvider in FProviders do if SameText(LProvider.Name, AName) then Exit(LProvider);
end;

function THexSearchProviderCollection.Remove(const AName: string): Boolean;
var
  LProvider: IHexSearchProvider;
begin
  LProvider := Find(AName);
  Result := LProvider <> nil;
  if Result then FProviders.Remove(LProvider);
end;

function THexSearchProviderCollection.Names: TArray<string>;
var
  I: Integer;
begin
  SetLength(Result, FProviders.Count);
  for I := 0 to FProviders.Count - 1 do Result[I] := FProviders[I].Name;
end;

function THexNativeSearchProvider.GetName: string;
begin
  Result := 'Native';
end;

function FoldByte(const AValue: Byte; const ACaseSensitive: Boolean): Byte;
begin
  Result := AValue;
  if not ACaseSensitive and (Result >= Ord('A')) and (Result <= Ord('Z')) then Inc(Result, 32);
end;

function THexNativeSearchProvider.Search(const ASource: IHexDataSource;
  const AQuery: THexSearchQuery): TObjectList<THexSearchMatch>;
const
  ChunkSize = 65536;
var
  LPatterns: TArray<TBytes>;
  LPattern: THexSearchPattern;
  LBuffer, LChunk: TBytes;
  LStart, LEnd, LPosition: Int64;
  LMaxLength, LReadSize, LRead, LOwned, I, J, K, LMismatches, LAllowed: Integer;
  LMatch: THexSearchMatch;
  LEncoding: TEncoding;
  LCandidate: string;
  LNativeMatches: TPatternMatches;
  LNativeMatch: TPatternMatch;
begin
  if AQuery = nil then raise EArgumentNilException.Create('AQuery');
  if AQuery.StartOffset < 0 then raise EArgumentOutOfRangeException.Create('StartOffset');
  if AQuery.MaxHammingDistance < 0 then raise EArgumentOutOfRangeException.Create('MaxHammingDistance');
  if AQuery.Mode = hsmPattern then
  begin
    LPattern := THexPatternParser.Parse(AQuery.Text);
    try
      if AQuery.MaxHammingDistance > 0 then LPattern.MaxHammingDistance := AQuery.MaxHammingDistance;
      Exit(THexPatternSearch.Search(ASource, LPattern, AQuery.StartOffset, AQuery.EndOffset, AQuery.MaxResults));
    finally
      LPattern.Free;
    end;
  end;
  Result := TObjectList<THexSearchMatch>.Create(True);
  try
    if (ASource = nil) or (ASource.Length = 0) then Exit;
    LPatterns := AQuery.Patterns;
    if Length(LPatterns) = 0 then
    begin
      SetLength(LPatterns, 1);
      if Length(AQuery.RawBytes) > 0 then LPatterns[0] := AQuery.RawBytes
      else if AQuery.Mode = hsmHex then
      begin
        if not THexSearchService.TryParseHexBytes(AQuery.Text, LPatterns[0]) then
          raise EArgumentException.Create('Invalid hexadecimal search bytes');
      end
      else
      begin
        LEncoding := AQuery.Encoding;
        if LEncoding = nil then LEncoding := TEncoding.UTF8;
        if AQuery.EncodingName <> '' then LPatterns[0] := THexTextEncoding.Encode(AQuery.Text, AQuery.EncodingName)
        else LPatterns[0] := LEncoding.GetBytes(AQuery.Text);
      end;
    end;
    LMaxLength := 0;
    for I := 0 to High(LPatterns) do
    begin
      if Length(LPatterns[I]) = 0 then raise EArgumentException.Create('Search patterns must not be empty');
      LMaxLength := Max(LMaxLength, Length(LPatterns[I]));
    end;
    if LMaxLength > MaxInt - ChunkSize then raise EArgumentOutOfRangeException.Create('Pattern length');
    LStart := Min(AQuery.StartOffset, ASource.Length);
    LEnd := ASource.Length;
    if AQuery.EndOffset >= 0 then LEnd := Min(LEnd, AQuery.EndOffset);
    LPosition := LStart;
    LAllowed := 0;
    if AQuery.Mode = hsmApproximate then LAllowed := AQuery.MaxHammingDistance;
    while LPosition < LEnd do
    begin
      LOwned := Integer(Min(Int64(ChunkSize), LEnd - LPosition));
      LReadSize := Integer(Min(Int64(LOwned) + LMaxLength - 1, LEnd - LPosition));
      SetLength(LBuffer, LReadSize);
      LRead := 0;
      while LRead < LReadSize do
      begin
        J := ASource.Read(LPosition + LRead, LChunk, LReadSize - LRead);
        if J <= 0 then raise EReadError.Create('The search data source returned an incomplete block');
        if (J > LReadSize - LRead) or (Length(LChunk) < J) then raise EReadError.Create('Invalid source block');
        Move(LChunk[0], LBuffer[LRead], J);
        Inc(LRead, J);
      end;
      if (Length(LPatterns) = 1) and AQuery.CaseSensitive and (LAllowed = 0) then
      begin
        LNativeMatches := TPatternSearch.FindAll(LBuffer, LPatterns[0]);
        for LNativeMatch in LNativeMatches do
          if LNativeMatch.Offset < LOwned then
          begin
            Result.Add(THexSearchMatch.Create(LPosition + LNativeMatch.Offset, Length(LPatterns[0])));
            if (AQuery.MaxResults > 0) and (Result.Count >= AQuery.MaxResults) then Exit;
          end;
      end
      else for I := 0 to LOwned - 1 do
        for J := 0 to High(LPatterns) do
          if Length(LPatterns[J]) <= LRead - I then
          begin
            LMismatches := 0;
            for K := 0 to High(LPatterns[J]) do
            begin
              if FoldByte(LBuffer[I + K], AQuery.CaseSensitive) <> FoldByte(LPatterns[J][K], AQuery.CaseSensitive) then
              begin
                Inc(LMismatches);
                if LMismatches > LAllowed then Break;
              end;
            end;
            if not AQuery.CaseSensitive and (AQuery.Mode = hsmText) and
              (Length(AQuery.RawBytes) = 0) and (Length(AQuery.Patterns) = 0) then
            begin
              if AQuery.EncodingName <> '' then
                LCandidate := THexTextEncoding.Decode(Copy(LBuffer, I, Length(LPatterns[J])), AQuery.EncodingName)
              else LCandidate := LEncoding.GetString(Copy(LBuffer, I, Length(LPatterns[J])));
              if SameText(LCandidate, AQuery.Text) then LMismatches := 0 else LMismatches := LAllowed + 1;
            end;
            if LMismatches <= LAllowed then
            begin
              LMatch := THexSearchMatch.Create(LPosition + I, Length(LPatterns[J]));
              LMatch.PatternIndex := J;
              LMatch.HammingDistance := LMismatches;
              Result.Add(LMatch);
              if (AQuery.MaxResults > 0) and (Result.Count >= AQuery.MaxResults) then Exit;
            end;
          end;
      Inc(LPosition, LOwned);
    end;
  except
    Result.Free;
    raise;
  end;
end;

end.

unit NimbusForms.HexEditor.RuleEngine;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  NimbusForms.HexEditor.DataSource,
  NimbusForms.HexEditor.Search,
  NimbusForms.HexEditor.Pattern;

type
  THexSearchRuleLogic = (srlAnd, srlOr);

  THexSearchRulePattern = class
  private
    FName: string;
    FPatternText: string;
    FPattern: THexSearchPattern;
    FIsRequired: Boolean;
    FIsNegative: Boolean;
    FAnchorOffset: Int64;
    FRelativeToPatternName: string;
    FMinRelativeOffset: Int64;
    FMaxRelativeOffset: Int64;
    FMaxHammingDistance: Integer;
    FMaxResults: Integer;
    function GetHasAnchor: Boolean;
    function GetHasRelativeConstraint: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function ResolvePattern: THexSearchPattern;
    function IsRelativeOffsetAllowed(const ABaseOffset, ACandidateOffset: Int64): Boolean;
    function Clone: THexSearchRulePattern;
    property Name: string read FName write FName;
    property PatternText: string read FPatternText write FPatternText;
    property Pattern: THexSearchPattern read FPattern write FPattern;
    property IsRequired: Boolean read FIsRequired write FIsRequired;
    property IsNegative: Boolean read FIsNegative write FIsNegative;
    property AnchorOffset: Int64 read FAnchorOffset write FAnchorOffset;
    property RelativeToPatternName: string read FRelativeToPatternName write FRelativeToPatternName;
    property MinRelativeOffset: Int64 read FMinRelativeOffset write FMinRelativeOffset;
    property MaxRelativeOffset: Int64 read FMaxRelativeOffset write FMaxRelativeOffset;
    property MaxHammingDistance: Integer read FMaxHammingDistance write FMaxHammingDistance;
    property MaxResults: Integer read FMaxResults write FMaxResults;
    property HasAnchor: Boolean read GetHasAnchor;
    property HasRelativeConstraint: Boolean read GetHasRelativeConstraint;
  end;

  THexSearchRule = class
  private
    FPatterns: TObjectList<THexSearchRulePattern>;
    FName: string;
    FLogic: THexSearchRuleLogic;
    FStartOffset: Int64;
    FEndOffset: Int64;
    FMaxResults: Integer;
    FStopAfterFirstMatch: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function AddPattern(const AName, APatternText: string): THexSearchRulePattern;
    function AddNegativePattern(const AName, APatternText: string): THexSearchRulePattern;
    function FindPattern(const AName: string): THexSearchRulePattern;
    function Clone: THexSearchRule;
    property Patterns: TObjectList<THexSearchRulePattern> read FPatterns;
    property Name: string read FName write FName;
    property Logic: THexSearchRuleLogic read FLogic write FLogic;
    property StartOffset: Int64 read FStartOffset write FStartOffset;
    property EndOffset: Int64 read FEndOffset write FEndOffset;
    property MaxResults: Integer read FMaxResults write FMaxResults;
    property StopAfterFirstMatch: Boolean read FStopAfterFirstMatch write FStopAfterFirstMatch;
  end;

  THexSearchRulePatternMatch = class
  private
    FPatternName: string;
    FOffset: Int64;
    FLength: Integer;
    FHammingDistance: Integer;
    FIsNegative: Boolean;
    FMatchedBytes: TBytes;
    FGroupIndex: Integer;
  public
    constructor Create(const APatternName: string; const AOffset: Int64; const ALength, AHammingDistance: Integer;
      const ANegative: Boolean; const AMatchedBytes: TBytes; const AGroupIndex: Integer);
    function Contains(const AOffset: Int64): Boolean;
    function ToSearchMatch: THexSearchMatch;
    function Clone: THexSearchRulePatternMatch;
    property PatternName: string read FPatternName;
    property Offset: Int64 read FOffset;
    property Length: Integer read FLength;
    property HammingDistance: Integer read FHammingDistance;
    property IsNegative: Boolean read FIsNegative;
    property MatchedBytes: TBytes read FMatchedBytes;
    property GroupIndex: Integer read FGroupIndex;
  end;

  THexSearchRuleMatch = class
  private
    FRuleName: string;
    FOffset: Int64;
    FLength: Integer;
    FPatternMatches: TObjectList<THexSearchRulePatternMatch>;
    function GetEndOffset: Int64;
    function GetTotalHammingDistance: Integer;
  public
    constructor Create(const ARuleName: string; const AOffset: Int64; const ALength: Integer);
    destructor Destroy; override;
    function Contains(const AOffset: Int64): Boolean;
    procedure AddPatternMatch(const AMatch: THexSearchRulePatternMatch);
    function ToSearchMatch: THexSearchMatch;
    property RuleName: string read FRuleName;
    property Offset: Int64 read FOffset;
    property Length: Integer read FLength;
    property PatternMatches: TObjectList<THexSearchRulePatternMatch> read FPatternMatches;
    property EndOffset: Int64 read GetEndOffset;
    property TotalHammingDistance: Integer read GetTotalHammingDistance;
  end;

  TPatternMatchMap = TObjectDictionary<THexSearchRulePattern, TObjectList<THexSearchRulePatternMatch>>;

  THexSearchRuleEngine = class
  private
    function BuildMatchMap(const ADataSource: IHexDataSource; const ARule: THexSearchRule): TPatternMatchMap;
    procedure SearchAnd(const ARule: THexSearchRule; const AMap: TPatternMatchMap;
      const AResults: TObjectList<THexSearchRuleMatch>; const AMaxResults: Integer);
    procedure SearchOr(const ARule: THexSearchRule; const AMap: TPatternMatchMap;
      const AResults: TObjectList<THexSearchRuleMatch>; const AMaxResults: Integer);
    procedure BuildAndCombinations(const ARule: THexSearchRule; const AMap: TPatternMatchMap;
      const APositive: TList<THexSearchRulePattern>; const APatternIndex: Integer;
      const ACurrent: TList<THexSearchRulePatternMatch>;
      const AResults: TObjectList<THexSearchRuleMatch>; const AMaxResults: Integer);
  public
    function Search(const ADataSource: IHexDataSource; const ARule: THexSearchRule): TObjectList<THexSearchRuleMatch>;
  end;

implementation

uses
  System.Math,
  System.Generics.Defaults,
  NimbusForms.HexEditor.PatternParser,
  NimbusForms.HexEditor.PatternSearch;

{ THexSearchRulePattern }

constructor THexSearchRulePattern.Create;
begin
  inherited Create;
  FName := '';
  FPatternText := '';
  FRelativeToPatternName := '';
  FIsRequired := True;
  FIsNegative := False;
  FAnchorOffset := -1;
  FMinRelativeOffset := Low(Int64);
  FMaxRelativeOffset := High(Int64);
  FMaxHammingDistance := 0;
  FMaxResults := 4096;
end;

destructor THexSearchRulePattern.Destroy;
begin
  FPattern.Free;
  inherited Destroy;
end;

function THexSearchRulePattern.GetHasAnchor: Boolean;
begin
  Result := FAnchorOffset >= 0;
end;

function THexSearchRulePattern.GetHasRelativeConstraint: Boolean;
begin
  Result := FRelativeToPatternName <> '';
end;

function THexSearchRulePattern.ResolvePattern: THexSearchPattern;
begin
  if FPattern <> nil then
    Result := FPattern.Clone
  else if not THexPatternParser.TryParse(FPatternText, Result) then
    Exit(nil);
  if HasAnchor then
    Result.AnchorOffset := FAnchorOffset;
  if FMaxHammingDistance > 0 then
    Result.MaxHammingDistance := FMaxHammingDistance;
  if Trim(Result.Name) = '' then
    Result.Name := FName;
end;

function THexSearchRulePattern.IsRelativeOffsetAllowed(const ABaseOffset, ACandidateOffset: Int64): Boolean;
var
  LDelta: Int64;
begin
  if not HasRelativeConstraint then
    Exit(True);
  LDelta := ACandidateOffset - ABaseOffset;
  if LDelta < FMinRelativeOffset then
    Exit(False);
  if LDelta > FMaxRelativeOffset then
    Exit(False);
  Result := True;
end;

function THexSearchRulePattern.Clone: THexSearchRulePattern;
begin
  Result := THexSearchRulePattern.Create;
  Result.FName := FName;
  Result.FPatternText := FPatternText;
  if FPattern <> nil then
    Result.FPattern := FPattern.Clone;
  Result.FIsRequired := FIsRequired;
  Result.FIsNegative := FIsNegative;
  Result.FAnchorOffset := FAnchorOffset;
  Result.FRelativeToPatternName := FRelativeToPatternName;
  Result.FMinRelativeOffset := FMinRelativeOffset;
  Result.FMaxRelativeOffset := FMaxRelativeOffset;
  Result.FMaxHammingDistance := FMaxHammingDistance;
  Result.FMaxResults := FMaxResults;
end;

{ THexSearchRule }

constructor THexSearchRule.Create;
begin
  inherited Create;
  FPatterns := TObjectList<THexSearchRulePattern>.Create(True);
  FName := '';
  FLogic := srlAnd;
  FStartOffset := 0;
  FEndOffset := -1;
  FMaxResults := 256;
  FStopAfterFirstMatch := False;
end;

destructor THexSearchRule.Destroy;
begin
  FPatterns.Free;
  inherited Destroy;
end;

function THexSearchRule.AddPattern(const AName, APatternText: string): THexSearchRulePattern;
begin
  Result := THexSearchRulePattern.Create;
  Result.Name := AName;
  Result.PatternText := APatternText;
  FPatterns.Add(Result);
end;

function THexSearchRule.AddNegativePattern(const AName, APatternText: string): THexSearchRulePattern;
begin
  Result := AddPattern(AName, APatternText);
  Result.IsNegative := True;
  Result.IsRequired := False;
end;

function THexSearchRule.FindPattern(const AName: string): THexSearchRulePattern;
var
  I: Integer;
begin
  if AName = '' then
    Exit(nil);
  for I := 0 to FPatterns.Count - 1 do
    if SameText(FPatterns[I].Name, AName) then
      Exit(FPatterns[I]);
  Result := nil;
end;

function THexSearchRule.Clone: THexSearchRule;
var
  I: Integer;
begin
  Result := THexSearchRule.Create;
  Result.FName := FName;
  Result.FLogic := FLogic;
  Result.FStartOffset := FStartOffset;
  Result.FEndOffset := FEndOffset;
  Result.FMaxResults := FMaxResults;
  Result.FStopAfterFirstMatch := FStopAfterFirstMatch;
  for I := 0 to FPatterns.Count - 1 do
    Result.FPatterns.Add(FPatterns[I].Clone);
end;

{ THexSearchRulePatternMatch }

constructor THexSearchRulePatternMatch.Create(const APatternName: string; const AOffset: Int64;
  const ALength, AHammingDistance: Integer; const ANegative: Boolean; const AMatchedBytes: TBytes;
  const AGroupIndex: Integer);
begin
  inherited Create;
  FPatternName := APatternName;
  FOffset := AOffset;
  FLength := ALength;
  FHammingDistance := AHammingDistance;
  FIsNegative := ANegative;
  FMatchedBytes := Copy(AMatchedBytes, 0, System.Length(AMatchedBytes));
  FGroupIndex := AGroupIndex;
end;

function THexSearchRulePatternMatch.Contains(const AOffset: Int64): Boolean;
begin
  Result := (AOffset >= FOffset) and (AOffset < FOffset + FLength);
end;

function THexSearchRulePatternMatch.ToSearchMatch: THexSearchMatch;
begin
  Result := THexSearchMatch.Create(FOffset, FLength);
end;

function THexSearchRulePatternMatch.Clone: THexSearchRulePatternMatch;
begin
  Result := THexSearchRulePatternMatch.Create(FPatternName, FOffset, FLength, FHammingDistance,
    FIsNegative, FMatchedBytes, FGroupIndex);
end;

{ THexSearchRuleMatch }

constructor THexSearchRuleMatch.Create(const ARuleName: string; const AOffset: Int64; const ALength: Integer);
begin
  inherited Create;
  FRuleName := ARuleName;
  FOffset := AOffset;
  FLength := ALength;
  FPatternMatches := TObjectList<THexSearchRulePatternMatch>.Create(True);
end;

destructor THexSearchRuleMatch.Destroy;
begin
  FPatternMatches.Free;
  inherited Destroy;
end;

function THexSearchRuleMatch.GetEndOffset: Int64;
begin
  Result := FOffset + FLength;
end;

function THexSearchRuleMatch.GetTotalHammingDistance: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FPatternMatches.Count - 1 do
    Inc(Result, FPatternMatches[I].HammingDistance);
end;

function THexSearchRuleMatch.Contains(const AOffset: Int64): Boolean;
begin
  Result := (AOffset >= FOffset) and (AOffset < FOffset + FLength);
end;

procedure THexSearchRuleMatch.AddPatternMatch(const AMatch: THexSearchRulePatternMatch);
var
  LClone: THexSearchRulePatternMatch;
  LStart, LEnd, LCurrentEnd: Int64;
begin
  if AMatch = nil then
    Exit;
  LClone := AMatch.Clone;
  FPatternMatches.Add(LClone);
  LStart := LClone.Offset;
  LEnd := LClone.Offset + LClone.Length;
  if FPatternMatches.Count = 1 then
  begin
    FOffset := LStart;
    FLength := LClone.Length;
    Exit;
  end;
  LCurrentEnd := FOffset + FLength;
  if LStart < FOffset then
    FOffset := LStart;
  if LEnd > LCurrentEnd then
    LCurrentEnd := LEnd;
  FLength := Integer(LCurrentEnd - FOffset);
end;

function THexSearchRuleMatch.ToSearchMatch: THexSearchMatch;
begin
  Result := THexSearchMatch.Create(FOffset, FLength);
end;

{ THexSearchRuleEngine }

function GetRuleName(const ARule: THexSearchRule): string;
begin
  if (ARule = nil) or (Trim(ARule.Name) = '') then
    Result := 'Rule'
  else
    Result := ARule.Name;
end;

function GetPatternName(const APattern: THexSearchRulePattern): string;
begin
  if (APattern = nil) or (Trim(APattern.Name) = '') then
    Result := 'Pattern'
  else
    Result := APattern.Name;
end;

function THexSearchRuleEngine.BuildMatchMap(const ADataSource: IHexDataSource;
  const ARule: THexSearchRule): TPatternMatchMap;
var
  I, M, LMaxResults: Integer;
  LRulePattern: THexSearchRulePattern;
  LPattern: THexSearchPattern;
  LMatches: TObjectList<THexPatternMatchInfo>;
  LRuleMatches: TObjectList<THexSearchRulePatternMatch>;
  LMatch: THexPatternMatchInfo;
begin
  Result := TPatternMatchMap.Create([doOwnsValues]);
  for I := 0 to ARule.Patterns.Count - 1 do
  begin
    LRulePattern := ARule.Patterns[I];
    LPattern := LRulePattern.ResolvePattern;
    LRuleMatches := TObjectList<THexSearchRulePatternMatch>.Create(True);
    try
      if (LPattern <> nil) and (LPattern.MinLength > 0) then
      begin
        if LRulePattern.MaxResults <= 0 then
          LMaxResults := 4096
        else
          LMaxResults := LRulePattern.MaxResults;
        LMatches := THexPatternSearch.SearchRich(ADataSource, LPattern,
          Max(Int64(0), ARule.StartOffset), ARule.EndOffset, LMaxResults);
        try
          for M := 0 to LMatches.Count - 1 do
          begin
            LMatch := LMatches[M];
            LRuleMatches.Add(THexSearchRulePatternMatch.Create(GetPatternName(LRulePattern),
              LMatch.Offset, LMatch.Length, LMatch.HammingDistance, LRulePattern.IsNegative,
              LMatch.MatchedBytes, M));
          end;
        finally
          LMatches.Free;
        end;
      end;
    finally
      LPattern.Free;
    end;
    Result.Add(LRulePattern, LRuleMatches);
  end;
end;

function TryResolveBaseOffset(const ACurrent: TList<THexSearchRulePatternMatch>;
  const APatternName: string; out AOffset: Int64): Boolean;
var
  I: Integer;
begin
  AOffset := 0;
  if (ACurrent = nil) or (APatternName = '') then
    Exit(False);
  for I := 0 to ACurrent.Count - 1 do
    if SameText(ACurrent[I].PatternName, APatternName) then
    begin
      AOffset := ACurrent[I].Offset;
      Exit(True);
    end;
  Result := False;
end;

function IsRelativeMatchAllowed(const APattern: THexSearchRulePattern;
  const ACurrent: TList<THexSearchRulePatternMatch>; const ACandidate: THexSearchRulePatternMatch): Boolean;
var
  LBaseOffset: Int64;
begin
  if (APattern = nil) or (ACandidate = nil) then
    Exit(False);
  if not APattern.HasRelativeConstraint then
    Exit(True);
  if not TryResolveBaseOffset(ACurrent, APattern.RelativeToPatternName, LBaseOffset) then
    Exit(False);
  Result := APattern.IsRelativeOffsetAllowed(LBaseOffset, ACandidate.Offset);
end;

function GetPositivePatterns(const ARule: THexSearchRule; const ARequiredOnly: Boolean): TList<THexSearchRulePattern>;
var
  I: Integer;
  LPattern: THexSearchRulePattern;
begin
  Result := TList<THexSearchRulePattern>.Create;
  for I := 0 to ARule.Patterns.Count - 1 do
  begin
    LPattern := ARule.Patterns[I];
    if LPattern.IsNegative then
      Continue;
    if ARequiredOnly and not LPattern.IsRequired then
      Continue;
    Result.Add(LPattern);
  end;
end;

function ContainsEquivalent(const AMatches: TObjectList<THexSearchRuleMatch>; const ACandidate: THexSearchRuleMatch): Boolean;
var
  I: Integer;
  LItem: THexSearchRuleMatch;
begin
  if ACandidate = nil then
    Exit(True);
  for I := 0 to AMatches.Count - 1 do
  begin
    LItem := AMatches[I];
    if (LItem.Offset = ACandidate.Offset) and (LItem.Length = ACandidate.Length) and
       SameText(LItem.RuleName, ACandidate.RuleName) then
      Exit(True);
  end;
  Result := False;
end;

function BuildRuleMatch(const ARule: THexSearchRule; const APatternMatches: TList<THexSearchRulePatternMatch>): THexSearchRuleMatch;
var
  I: Integer;
begin
  if (APatternMatches = nil) or (APatternMatches.Count = 0) then
    Exit(nil);
  Result := THexSearchRuleMatch.Create(GetRuleName(ARule), APatternMatches[0].Offset, APatternMatches[0].Length);
  for I := 0 to APatternMatches.Count - 1 do
    Result.AddPatternMatch(APatternMatches[I]);
end;

function IsRejectedByNegativePatterns(const ARule: THexSearchRule; const AMap: TPatternMatchMap;
  const ACandidate: THexSearchRuleMatch): Boolean;
var
  I, M: Integer;
  LNegative: THexSearchRulePattern;
  LNegativeMatches: TObjectList<THexSearchRulePatternMatch>;
  LCurrent: TList<THexSearchRulePatternMatch>;
begin
  LCurrent := TList<THexSearchRulePatternMatch>.Create;
  try
    LCurrent.AddRange(ACandidate.PatternMatches);
    for I := 0 to ARule.Patterns.Count - 1 do
    begin
      LNegative := ARule.Patterns[I];
      if not LNegative.IsNegative then
        Continue;
      if not AMap.TryGetValue(LNegative, LNegativeMatches) then
        Continue;
      if (LNegativeMatches = nil) or (LNegativeMatches.Count = 0) then
        Continue;
      for M := 0 to LNegativeMatches.Count - 1 do
        if IsRelativeMatchAllowed(LNegative, LCurrent, LNegativeMatches[M]) then
          Exit(True);
    end;
  finally
    LCurrent.Free;
  end;
  Result := False;
end;

procedure THexSearchRuleEngine.BuildAndCombinations(const ARule: THexSearchRule;
  const AMap: TPatternMatchMap; const APositive: TList<THexSearchRulePattern>;
  const APatternIndex: Integer; const ACurrent: TList<THexSearchRulePatternMatch>;
  const AResults: TObjectList<THexSearchRuleMatch>; const AMaxResults: Integer);
var
  LPattern: THexSearchRulePattern;
  LMatches: TObjectList<THexSearchRulePatternMatch>;
  LCandidate: THexSearchRuleMatch;
  I: Integer;
begin
  if AResults.Count >= AMaxResults then
    Exit;

  if APatternIndex >= APositive.Count then
  begin
    LCandidate := BuildRuleMatch(ARule, ACurrent);
    if LCandidate = nil then
      Exit;
    if IsRejectedByNegativePatterns(ARule, AMap, LCandidate) then
    begin
      LCandidate.Free;
      Exit;
    end;
    if not ContainsEquivalent(AResults, LCandidate) then
      AResults.Add(LCandidate)
    else
      LCandidate.Free;
    Exit;
  end;

  LPattern := APositive[APatternIndex];
  if not AMap.TryGetValue(LPattern, LMatches) then
    LMatches := nil;

  if ((LMatches = nil) or (LMatches.Count = 0)) and LPattern.IsRequired then
    Exit;

  if ((LMatches = nil) or (LMatches.Count = 0)) and not LPattern.IsRequired then
  begin
    BuildAndCombinations(ARule, AMap, APositive, APatternIndex + 1, ACurrent, AResults, AMaxResults);
    Exit;
  end;

  I := 0;
  while (I < LMatches.Count) and (AResults.Count < AMaxResults) do
  begin
    if IsRelativeMatchAllowed(LPattern, ACurrent, LMatches[I]) then
    begin
      ACurrent.Add(LMatches[I]);
      BuildAndCombinations(ARule, AMap, APositive, APatternIndex + 1, ACurrent, AResults, AMaxResults);
      ACurrent.Delete(ACurrent.Count - 1);
      if ARule.StopAfterFirstMatch and (AResults.Count > 0) then
        Exit;
    end;
    Inc(I);
  end;

  if not LPattern.IsRequired then
    BuildAndCombinations(ARule, AMap, APositive, APatternIndex + 1, ACurrent, AResults, AMaxResults);
end;

procedure THexSearchRuleEngine.SearchAnd(const ARule: THexSearchRule; const AMap: TPatternMatchMap;
  const AResults: TObjectList<THexSearchRuleMatch>; const AMaxResults: Integer);
var
  LPositive: TList<THexSearchRulePattern>;
  LCurrent: TList<THexSearchRulePatternMatch>;
begin
  LPositive := GetPositivePatterns(ARule, True);
  try
    if LPositive.Count = 0 then
    begin
      LPositive.Free;
      LPositive := GetPositivePatterns(ARule, False);
    end;
    if LPositive.Count = 0 then
      Exit;
    LPositive.Sort(TComparer<THexSearchRulePattern>.Construct(
      function(const L, R: THexSearchRulePattern): Integer
      var
        LL, LR: TObjectList<THexSearchRulePatternMatch>;
        LCountL, LCountR: Integer;
      begin
        if AMap.TryGetValue(L, LL) then LCountL := LL.Count else LCountL := 0;
        if AMap.TryGetValue(R, LR) then LCountR := LR.Count else LCountR := 0;
        Result := LCountL - LCountR;
      end));
    LCurrent := TList<THexSearchRulePatternMatch>.Create;
    try
      BuildAndCombinations(ARule, AMap, LPositive, 0, LCurrent, AResults, AMaxResults);
    finally
      LCurrent.Free;
    end;
  finally
    LPositive.Free;
  end;
end;

procedure THexSearchRuleEngine.SearchOr(const ARule: THexSearchRule; const AMap: TPatternMatchMap;
  const AResults: TObjectList<THexSearchRuleMatch>; const AMaxResults: Integer);
var
  I, J: Integer;
  LRulePattern: THexSearchRulePattern;
  LMatches: TObjectList<THexSearchRulePatternMatch>;
  LSingle: TList<THexSearchRulePatternMatch>;
  LCandidate: THexSearchRuleMatch;
begin
  I := 0;
  while (I < ARule.Patterns.Count) and (AResults.Count < AMaxResults) do
  begin
    LRulePattern := ARule.Patterns[I];
    if LRulePattern.IsNegative or not AMap.TryGetValue(LRulePattern, LMatches) then
    begin
      Inc(I);
      Continue;
    end;
    J := 0;
    while (J < LMatches.Count) and (AResults.Count < AMaxResults) do
    begin
      LSingle := TList<THexSearchRulePatternMatch>.Create;
      try
        LSingle.Add(LMatches[J]);
        LCandidate := BuildRuleMatch(ARule, LSingle);
      finally
        LSingle.Free;
      end;
      if LCandidate <> nil then
      begin
        if IsRejectedByNegativePatterns(ARule, AMap, LCandidate) or ContainsEquivalent(AResults, LCandidate) then
          LCandidate.Free
        else
        begin
          AResults.Add(LCandidate);
          if ARule.StopAfterFirstMatch then
            Exit;
        end;
      end;
      Inc(J);
    end;
    Inc(I);
  end;
end;

function THexSearchRuleEngine.Search(const ADataSource: IHexDataSource;
  const ARule: THexSearchRule): TObjectList<THexSearchRuleMatch>;
var
  LMap: TPatternMatchMap;
  LMaxResults: Integer;
begin
  Result := TObjectList<THexSearchRuleMatch>.Create(True);
  if (ADataSource = nil) or (ADataSource.Length <= 0) or (ARule = nil) or (ARule.Patterns.Count = 0) then
    Exit;
  LMap := BuildMatchMap(ADataSource, ARule);
  try
    if ARule.MaxResults <= 0 then
      LMaxResults := MaxInt
    else
      LMaxResults := ARule.MaxResults;
    if ARule.Logic = srlOr then
      SearchOr(ARule, LMap, Result, LMaxResults)
    else
      SearchAnd(ARule, LMap, Result, LMaxResults);
  finally
    LMap.Free;
  end;
  Result.Sort(TComparer<THexSearchRuleMatch>.Construct(
    function(const L, R: THexSearchRuleMatch): Integer
    begin
      if L.Offset < R.Offset then
        Result := -1
      else if L.Offset > R.Offset then
        Result := 1
      else
        Result := L.Length - R.Length;
    end));
end;

end.

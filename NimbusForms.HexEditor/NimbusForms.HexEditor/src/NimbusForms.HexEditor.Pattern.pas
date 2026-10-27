unit NimbusForms.HexEditor.Pattern;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  NimbusForms.HexEditor.Search;

type
  THexPatternTokenKind = (ptkExact, ptkWildcard, ptkHighNibble, ptkLowNibble, ptkBitMask);

  THexPatternToken = class
  private
    FKind: THexPatternTokenKind;
    FValue: Byte;
    FMask: Byte;
  public
    constructor Create(const AKind: THexPatternTokenKind; const AValue: Byte; const AMask: Byte = 0);
    function Matches(const AValue: Byte): Boolean;
    function IsWildcard: Boolean;
    function Clone: THexPatternToken;
    property Kind: THexPatternTokenKind read FKind;
    property Value: Byte read FValue;
    property Mask: Byte read FMask;
    class function Exact(const AValue: Byte): THexPatternToken; static;
    class function Wildcard: THexPatternToken; static;
    class function HighNibble(const AValue: Byte): THexPatternToken; static;
    class function LowNibble(const AValue: Byte): THexPatternToken; static;
    class function BitMask(const AValue, AMask: Byte): THexPatternToken; static;
  end;

  THexPatternNodeKind = (pnkToken, pnkGap, pnkAlternative);

  THexPatternNode = class
  private
    FKind: THexPatternNodeKind;
    FToken: THexPatternToken;
    FMinGap: Integer;
    FMaxGap: Integer;
    FAlternatives: TObjectList<TObjectList<THexPatternNode>>;
    function GetMinLength: Integer;
    function GetMaxLength: Integer;
  public
    constructor Create(const AKind: THexPatternNodeKind);
    destructor Destroy; override;
    function Clone: THexPatternNode;
    property Kind: THexPatternNodeKind read FKind;
    property Token: THexPatternToken read FToken;
    property MinGap: Integer read FMinGap;
    property MaxGap: Integer read FMaxGap;
    property Alternatives: TObjectList<TObjectList<THexPatternNode>> read FAlternatives;
    property MinLength: Integer read GetMinLength;
    property MaxLength: Integer read GetMaxLength;
    class function FromToken(const AToken: THexPatternToken): THexPatternNode; static;
    class function Gap(const AMin, AMax: Integer): THexPatternNode; static;
    class function Alternative(const ASequences: TObjectList<TObjectList<THexPatternNode>>): THexPatternNode; static;
    class function CloneSequence(const ANodes: TList<THexPatternNode>): TObjectList<THexPatternNode>; static;
    class function GetSequenceMinLength(const ANodes: TList<THexPatternNode>): Integer; static;
    class function GetSequenceMaxLength(const ANodes: TList<THexPatternNode>): Integer; static;
  end;

  THexPatternMatchInfo = class
  private
    FOffset: Int64;
    FLength: Integer;
    FHammingDistance: Integer;
    FMatchedBytes: TBytes;
  public
    constructor Create(const AOffset: Int64; const ALength, AHammingDistance: Integer; const AMatchedBytes: TBytes);
    function ToSearchMatch: THexSearchMatch;
    function WithOffset(const AOffset: Int64): THexPatternMatchInfo;
    function Clone: THexPatternMatchInfo;
    property Offset: Int64 read FOffset;
    property Length: Integer read FLength;
    property HammingDistance: Integer read FHammingDistance;
    property MatchedBytes: TBytes read FMatchedBytes;
  end;

  THexSearchPattern = class
  private
    FNodes: TObjectList<THexPatternNode>;
    FName: string;
    FAnchorOffset: Int64;
    FMaxHammingDistance: Integer;
    function GetHasAnchor: Boolean;
    function GetMinLength: Integer;
    function GetMaxLength: Integer;
    function MatchNodes(const ANodes: TList<THexPatternNode>; const ANodeIndex: Integer;
      const ABuffer: TBytes; const ABufferIndex, ADistance: Integer;
      out AEndIndex, AFinalDistance: Integer): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddToken(const AToken: THexPatternToken);
    procedure AddNode(const ANode: THexPatternNode);
    function TryMatch(const ABuffer: TBytes; const AIndex: Integer; out AMatch: THexPatternMatchInfo): Boolean;
    function Clone: THexSearchPattern;
    property Nodes: TObjectList<THexPatternNode> read FNodes;
    property Name: string read FName write FName;
    property AnchorOffset: Int64 read FAnchorOffset write FAnchorOffset;
    property MaxHammingDistance: Integer read FMaxHammingDistance write FMaxHammingDistance;
    property HasAnchor: Boolean read GetHasAnchor;
    property MinLength: Integer read GetMinLength;
    property MaxLength: Integer read GetMaxLength;
  end;

implementation

{ THexPatternToken }

constructor THexPatternToken.Create(const AKind: THexPatternTokenKind; const AValue, AMask: Byte);
begin
  inherited Create;
  FKind := AKind;
  FValue := AValue;
  FMask := AMask;
end;

function THexPatternToken.IsWildcard: Boolean;
begin
  Result := FKind = ptkWildcard;
end;

function THexPatternToken.Matches(const AValue: Byte): Boolean;
begin
  case FKind of
    ptkWildcard: Result := True;
    ptkExact: Result := AValue = FValue;
    ptkHighNibble: Result := (AValue and $F0) = (FValue and $F0);
    ptkLowNibble: Result := (AValue and $0F) = (FValue and $0F);
    ptkBitMask: Result := (AValue and FMask) = (FValue and FMask);
  else
    Result := False;
  end;
end;

function THexPatternToken.Clone: THexPatternToken;
begin
  Result := THexPatternToken.Create(FKind, FValue, FMask);
end;

class function THexPatternToken.Exact(const AValue: Byte): THexPatternToken;
begin
  Result := THexPatternToken.Create(ptkExact, AValue);
end;

class function THexPatternToken.Wildcard: THexPatternToken;
begin
  Result := THexPatternToken.Create(ptkWildcard, 0);
end;

class function THexPatternToken.HighNibble(const AValue: Byte): THexPatternToken;
begin
  Result := THexPatternToken.Create(ptkHighNibble, AValue);
end;

class function THexPatternToken.LowNibble(const AValue: Byte): THexPatternToken;
begin
  Result := THexPatternToken.Create(ptkLowNibble, AValue);
end;

class function THexPatternToken.BitMask(const AValue, AMask: Byte): THexPatternToken;
begin
  Result := THexPatternToken.Create(ptkBitMask, AValue, AMask);
end;

{ THexPatternNode }

constructor THexPatternNode.Create(const AKind: THexPatternNodeKind);
begin
  inherited Create;
  FKind := AKind;
  FAlternatives := TObjectList<TObjectList<THexPatternNode>>.Create(True);
end;

destructor THexPatternNode.Destroy;
begin
  FToken.Free;
  FAlternatives.Free;
  inherited Destroy;
end;

function THexPatternNode.GetMinLength: Integer;
var
  I, LLength, LMin: Integer;
begin
  if FKind = pnkToken then
    Exit(1);
  if FKind = pnkGap then
    Exit(FMinGap);
  LMin := MaxInt;
  for I := 0 to FAlternatives.Count - 1 do
  begin
    LLength := GetSequenceMinLength(FAlternatives[I]);
    if LLength < LMin then
      LMin := LLength;
  end;
  if LMin = MaxInt then
    Result := 0
  else
    Result := LMin;
end;

function THexPatternNode.GetMaxLength: Integer;
var
  I, LLength, LMax: Integer;
begin
  if FKind = pnkToken then
    Exit(1);
  if FKind = pnkGap then
    Exit(FMaxGap);
  LMax := 0;
  for I := 0 to FAlternatives.Count - 1 do
  begin
    LLength := GetSequenceMaxLength(FAlternatives[I]);
    if LLength > LMax then
      LMax := LLength;
  end;
  Result := LMax;
end;

class function THexPatternNode.FromToken(const AToken: THexPatternToken): THexPatternNode;
begin
  if AToken = nil then
    raise EArgumentNilException.Create('token');
  Result := THexPatternNode.Create(pnkToken);
  Result.FToken := AToken;
end;

class function THexPatternNode.Gap(const AMin, AMax: Integer): THexPatternNode;
begin
  if (AMin < 0) or (AMax < AMin) then
    raise EArgumentOutOfRangeException.Create('gap');
  Result := THexPatternNode.Create(pnkGap);
  Result.FMinGap := AMin;
  Result.FMaxGap := AMax;
end;

class function THexPatternNode.Alternative(const ASequences: TObjectList<TObjectList<THexPatternNode>>): THexPatternNode;
var
  I: Integer;
begin
  if ASequences = nil then
    raise EArgumentNilException.Create('alternatives');
  Result := THexPatternNode.Create(pnkAlternative);
  for I := 0 to ASequences.Count - 1 do
    if (ASequences[I] <> nil) and (ASequences[I].Count > 0) then
      Result.FAlternatives.Add(CloneSequence(ASequences[I]));
  if Result.FAlternatives.Count = 0 then
  begin
    Result.Free;
    raise EArgumentException.Create('alternatives');
  end;
end;

function THexPatternNode.Clone: THexPatternNode;
begin
  if FKind = pnkToken then
    Result := FromToken(FToken.Clone)
  else if FKind = pnkGap then
    Result := Gap(FMinGap, FMaxGap)
  else
    Result := Alternative(FAlternatives);
end;

class function THexPatternNode.CloneSequence(const ANodes: TList<THexPatternNode>): TObjectList<THexPatternNode>;
var
  I: Integer;
begin
  Result := TObjectList<THexPatternNode>.Create(True);
  if ANodes = nil then
    Exit;
  for I := 0 to ANodes.Count - 1 do
    if ANodes[I] <> nil then
      Result.Add(ANodes[I].Clone);
end;

class function THexPatternNode.GetSequenceMinLength(const ANodes: TList<THexPatternNode>): Integer;
var
  I: Integer;
begin
  Result := 0;
  if (ANodes = nil) or (ANodes.Count = 0) then
    Exit;
  for I := 0 to ANodes.Count - 1 do
    Inc(Result, ANodes[I].MinLength);
end;

class function THexPatternNode.GetSequenceMaxLength(const ANodes: TList<THexPatternNode>): Integer;
var
  I: Integer;
begin
  Result := 0;
  if (ANodes = nil) or (ANodes.Count = 0) then
    Exit;
  for I := 0 to ANodes.Count - 1 do
    Inc(Result, ANodes[I].MaxLength);
end;

{ THexPatternMatchInfo }

constructor THexPatternMatchInfo.Create(const AOffset: Int64; const ALength, AHammingDistance: Integer;
  const AMatchedBytes: TBytes);
begin
  inherited Create;
  FOffset := AOffset;
  FLength := ALength;
  FHammingDistance := AHammingDistance;
  FMatchedBytes := Copy(AMatchedBytes, 0, System.Length(AMatchedBytes));
end;

function THexPatternMatchInfo.ToSearchMatch: THexSearchMatch;
begin
  Result := THexSearchMatch.Create(FOffset, FLength);
end;

function THexPatternMatchInfo.WithOffset(const AOffset: Int64): THexPatternMatchInfo;
begin
  Result := THexPatternMatchInfo.Create(AOffset, FLength, FHammingDistance, FMatchedBytes);
end;

function THexPatternMatchInfo.Clone: THexPatternMatchInfo;
begin
  Result := THexPatternMatchInfo.Create(FOffset, FLength, FHammingDistance, FMatchedBytes);
end;

{ THexSearchPattern }

constructor THexSearchPattern.Create;
begin
  inherited Create;
  FNodes := TObjectList<THexPatternNode>.Create(True);
  FName := '';
  FAnchorOffset := -1;
  FMaxHammingDistance := 0;
end;

destructor THexSearchPattern.Destroy;
begin
  FNodes.Free;
  inherited Destroy;
end;

function THexSearchPattern.GetHasAnchor: Boolean;
begin
  Result := FAnchorOffset >= 0;
end;

function THexSearchPattern.GetMinLength: Integer;
begin
  Result := THexPatternNode.GetSequenceMinLength(FNodes);
end;

function THexSearchPattern.GetMaxLength: Integer;
begin
  Result := THexPatternNode.GetSequenceMaxLength(FNodes);
end;

procedure THexSearchPattern.AddToken(const AToken: THexPatternToken);
begin
  if AToken = nil then
    raise EArgumentNilException.Create('token');
  FNodes.Add(THexPatternNode.FromToken(AToken));
end;

procedure THexSearchPattern.AddNode(const ANode: THexPatternNode);
begin
  if ANode = nil then
    raise EArgumentNilException.Create('node');
  FNodes.Add(ANode);
end;

function THexSearchPattern.Clone: THexSearchPattern;
var
  I: Integer;
begin
  Result := THexSearchPattern.Create;
  Result.FName := FName;
  Result.FAnchorOffset := FAnchorOffset;
  Result.FMaxHammingDistance := FMaxHammingDistance;
  for I := 0 to FNodes.Count - 1 do
    Result.FNodes.Add(FNodes[I].Clone);
end;

function THexSearchPattern.MatchNodes(const ANodes: TList<THexPatternNode>;
  const ANodeIndex: Integer; const ABuffer: TBytes; const ABufferIndex, ADistance: Integer;
  out AEndIndex, AFinalDistance: Integer): Boolean;
var
  LNode: THexPatternNode;
  LNextDistance, LGapLength, LNextIndex, I, R: Integer;
  LCombined: TList<THexPatternNode>;
begin
  AEndIndex := ABufferIndex;
  AFinalDistance := ADistance;

  if ADistance > FMaxHammingDistance then
    Exit(False);

  if ANodeIndex >= ANodes.Count then
  begin
    AEndIndex := ABufferIndex;
    AFinalDistance := ADistance;
    Exit(True);
  end;

  if ABufferIndex > System.Length(ABuffer) then
    Exit(False);

  LNode := ANodes[ANodeIndex];

  case LNode.Kind of
    pnkToken:
      begin
        if ABufferIndex >= System.Length(ABuffer) then
          Exit(False);
        LNextDistance := ADistance;
        if not LNode.Token.Matches(ABuffer[ABufferIndex]) then
        begin
          if not LNode.Token.IsWildcard then
            Inc(LNextDistance);
        end;
        if LNextDistance > FMaxHammingDistance then
          Exit(False);
        Result := MatchNodes(ANodes, ANodeIndex + 1, ABuffer, ABufferIndex + 1, LNextDistance,
          AEndIndex, AFinalDistance);
      end;

    pnkGap:
      begin
        for LGapLength := LNode.MinGap to LNode.MaxGap do
        begin
          LNextIndex := ABufferIndex + LGapLength;
          if LNextIndex > System.Length(ABuffer) then
            Break;
          if MatchNodes(ANodes, ANodeIndex + 1, ABuffer, LNextIndex, ADistance, AEndIndex, AFinalDistance) then
            Exit(True);
        end;
        Result := False;
      end;

    pnkAlternative:
      begin
        Result := False;
        for I := 0 to LNode.Alternatives.Count - 1 do
        begin
          LCombined := TList<THexPatternNode>.Create;
          try
            LCombined.AddRange(LNode.Alternatives[I]);
            for R := ANodeIndex + 1 to ANodes.Count - 1 do
              LCombined.Add(ANodes[R]);
            if MatchNodes(LCombined, 0, ABuffer, ABufferIndex, ADistance, AEndIndex, AFinalDistance) then
              Exit(True);
          finally
            LCombined.Free;
          end;
        end;
      end;
  else
    Result := False;
  end;
end;

function THexSearchPattern.TryMatch(const ABuffer: TBytes; const AIndex: Integer;
  out AMatch: THexPatternMatchInfo): Boolean;
var
  LEndIndex, LDistance, LLength: Integer;
  LMatched: TBytes;
begin
  AMatch := nil;
  if (System.Length(ABuffer) = 0) or (AIndex < 0) or (AIndex >= System.Length(ABuffer)) or (FNodes.Count = 0) then
    Exit(False);
  if not MatchNodes(FNodes, 0, ABuffer, AIndex, 0, LEndIndex, LDistance) then
    Exit(False);
  LLength := LEndIndex - AIndex;
  if (LLength <= 0) or (AIndex + LLength > System.Length(ABuffer)) then
    Exit(False);
  SetLength(LMatched, LLength);
  Move(ABuffer[AIndex], LMatched[0], LLength);
  AMatch := THexPatternMatchInfo.Create(0, LLength, LDistance, LMatched);
  Result := True;
end;

end.

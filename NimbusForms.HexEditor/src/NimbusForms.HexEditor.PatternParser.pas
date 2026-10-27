unit NimbusForms.HexEditor.PatternParser;

interface

uses
  System.SysUtils,
  System.Character,
  System.Generics.Collections,
  NimbusForms.HexEditor.Pattern;

type
  THexPatternParseResult = class
  private
    FSuccess: Boolean;
    FPattern: THexSearchPattern;
    FErrorMessage: string;
    FErrorIndex: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function DetachPattern: THexSearchPattern;
    property Success: Boolean read FSuccess write FSuccess;
    property Pattern: THexSearchPattern read FPattern write FPattern;
    property ErrorMessage: string read FErrorMessage write FErrorMessage;
    property ErrorIndex: Integer read FErrorIndex write FErrorIndex;
  end;

  THexPatternParser = class
  public
    class function Parse(const APatternText: string): THexSearchPattern; static;
    class function TryParse(const APatternText: string; out APattern: THexSearchPattern): Boolean; static;
    class function ParseDetailed(const APatternText: string): THexPatternParseResult; static;
    class function TryParseToken(const AText: string; out AToken: THexPatternToken): Boolean; static;
  end;

implementation

type
  TPatternPart = record
    Text: string;
    Index: Integer;
  end;

const
  SPatternEmpty = 'Pattern is empty.';
  SPatternInvalidToken = 'Invalid pattern token.';
  SPatternInvalidGap = 'Invalid gap specification.';
  SPatternAlternativeEmpty = 'Alternative group is empty.';
  SPatternAlternativeInvalid = 'Alternative group must contain at least two options.';
  SPatternUnbalancedGroup = 'Unbalanced group in pattern.';
  SPatternInvalid = 'Invalid pattern.';
  CMaxGapLength = 1048576;

{ THexPatternParseResult }

constructor THexPatternParseResult.Create;
begin
  inherited Create;
  FErrorMessage := '';
  FErrorIndex := -1;
end;

destructor THexPatternParseResult.Destroy;
begin
  FPattern.Free;
  inherited Destroy;
end;

function THexPatternParseResult.DetachPattern: THexSearchPattern;
begin
  Result := FPattern;
  FPattern := nil;
end;

{ helpers }

function IsHexChar(const C: Char): Boolean;
begin
  Result := CharInSet(C, ['0'..'9', 'a'..'f', 'A'..'F']);
end;

function TryParseNibble(const C: Char; out AValue: Byte): Boolean;
begin
  AValue := 0;
  if CharInSet(C, ['0'..'9']) then
    AValue := Byte(Ord(C) - Ord('0'))
  else if CharInSet(C, ['a'..'f']) then
    AValue := Byte(10 + Ord(C) - Ord('a'))
  else if CharInSet(C, ['A'..'F']) then
    AValue := Byte(10 + Ord(C) - Ord('A'))
  else
    Exit(False);
  Result := True;
end;

function TryParseByteText(const AText: string; out AValue: Byte): Boolean;
var
  LNorm: string;
  LHigh, LLow: Byte;
begin
  AValue := 0;
  LNorm := Trim(AText);
  if LNorm = '' then
    Exit(False);
  if (System.Length(LNorm) > 2) and (LNorm[1] = '0') and (CharInSet(LNorm[2], ['x', 'X'])) then
    LNorm := Copy(LNorm, 3, System.Length(LNorm) - 2);
  if System.Length(LNorm) <> 2 then
    Exit(False);
  if not TryParseNibble(LNorm[1], LHigh) or not TryParseNibble(LNorm[2], LLow) then
    Exit(False);
  AValue := Byte((LHigh shl 4) or LLow);
  Result := True;
end;

function Fail(const AResult: THexPatternParseResult; const AMessage: string; const AIndex: Integer): Boolean;
begin
  AResult.Success := False;
  AResult.Pattern.Free;
  AResult.Pattern := nil;
  if AMessage <> '' then
    AResult.ErrorMessage := AMessage
  else
    AResult.ErrorMessage := SPatternInvalid;
  AResult.ErrorIndex := AIndex;
  Result := False;
end;

function TryTokenize(const AText: string; const AParts: TList<TPatternPart>;
  const AResult: THexPatternParseResult): Boolean;
var
  I, LStart, LParen, LBracket: Integer;
  C: Char;
  LPart: TPatternPart;
  LSplit: Boolean;
begin
  AParts.Clear;
  if AText = '' then
    Exit(True);
  LStart := -1;
  LParen := 0;
  LBracket := 0;
  for I := 0 to System.Length(AText) - 1 do
  begin
    C := AText[I + 1];
    if (LStart < 0) and (not C.IsWhiteSpace) then
      LStart := I;
    if C = '(' then Inc(LParen);
    if C = ')' then Dec(LParen);
    if C = '[' then Inc(LBracket);
    if C = ']' then Dec(LBracket);
    if (LParen < 0) or (LBracket < 0) then
      Exit(Fail(AResult, SPatternUnbalancedGroup, I));
    LSplit := C.IsWhiteSpace and (LParen = 0) and (LBracket = 0);
    if LSplit and (LStart >= 0) then
    begin
      LPart.Text := Copy(AText, LStart + 1, I - LStart);
      LPart.Index := LStart;
      AParts.Add(LPart);
      LStart := -1;
    end;
  end;
  if (LParen <> 0) or (LBracket <> 0) then
    Exit(Fail(AResult, SPatternUnbalancedGroup, System.Length(AText) - 1));
  if LStart >= 0 then
  begin
    LPart.Text := Copy(AText, LStart + 1, System.Length(AText) - LStart);
    LPart.Index := LStart;
    AParts.Add(LPart);
  end;
  Result := True;
end;

function SplitTopLevel(const AText: string; const ASeparator: Char): TArray<string>;
var
  LList: TList<string>;
  I, LStart, LParen, LBracket: Integer;
  C: Char;
begin
  LList := TList<string>.Create;
  try
    LStart := 0;
    LParen := 0;
    LBracket := 0;
    for I := 0 to System.Length(AText) - 1 do
    begin
      C := AText[I + 1];
      if C = '(' then Inc(LParen);
      if C = ')' then Dec(LParen);
      if C = '[' then Inc(LBracket);
      if C = ']' then Dec(LBracket);
      if (C = ASeparator) and (LParen = 0) and (LBracket = 0) then
      begin
        LList.Add(Trim(Copy(AText, LStart + 1, I - LStart)));
        LStart := I + 1;
      end;
    end;
    LList.Add(Trim(Copy(AText, LStart + 1, System.Length(AText) - LStart)));
    Result := LList.ToArray;
  finally
    LList.Free;
  end;
end;

class function THexPatternParser.TryParseToken(const AText: string; out AToken: THexPatternToken): Boolean;
var
  LValue, LByteText, LMaskText: string;
  LMaskIndex: Integer;
  LByteValue, LMaskValue, LNibble: Byte;
begin
  AToken := nil;
  if Trim(AText) = '' then
    Exit(False);
  LValue := Trim(AText);

  if (LValue = '??') or (LValue = '?') then
  begin
    AToken := THexPatternToken.Wildcard;
    Exit(True);
  end;

  LMaskIndex := Pos('&', LValue);
  if LMaskIndex > 1 then
  begin
    LByteText := Copy(LValue, 1, LMaskIndex - 1);
    LMaskText := Copy(LValue, LMaskIndex + 1, System.Length(LValue) - LMaskIndex);
    if not TryParseByteText(LByteText, LByteValue) or not TryParseByteText(LMaskText, LMaskValue) then
      Exit(False);
    AToken := THexPatternToken.BitMask(LByteValue, LMaskValue);
    Exit(True);
  end;

  if (System.Length(LValue) = 2) and (LValue[1] = '?') and IsHexChar(LValue[2]) then
  begin
    if not TryParseNibble(LValue[2], LNibble) then
      Exit(False);
    AToken := THexPatternToken.LowNibble(LNibble);
    Exit(True);
  end;

  if (System.Length(LValue) = 2) and IsHexChar(LValue[1]) and (LValue[2] = '?') then
  begin
    if not TryParseNibble(LValue[1], LNibble) then
      Exit(False);
    AToken := THexPatternToken.HighNibble(Byte(LNibble shl 4));
    Exit(True);
  end;

  if TryParseByteText(LValue, LByteValue) then
  begin
    AToken := THexPatternToken.Exact(LByteValue);
    Exit(True);
  end;

  Result := False;
end;

function TryParseNodeFwd(const AText: string; out ANode: THexPatternNode;
  const AResult: THexPatternParseResult; const AIndex: Integer): Boolean; forward;

function TryParseGap(const AText: string; out ANode: THexPatternNode;
  const AResult: THexPatternParseResult; const AIndex: Integer): Boolean;
var
  LInner, LLeft, LRight: string;
  LMin, LMax, LDash, LDots: Integer;
begin
  ANode := nil;
  LInner := Trim(Copy(AText, 2, System.Length(AText) - 2));
  if LInner = '' then
    Exit(Fail(AResult, SPatternInvalidGap, AIndex));
  LDash := Pos('-', LInner);
  LDots := Pos('..', LInner);
  if LDash > 0 then
  begin
    LLeft := Trim(Copy(LInner, 1, LDash - 1));
    LRight := Trim(Copy(LInner, LDash + 1, System.Length(LInner) - LDash));
    if not TryStrToInt(LLeft, LMin) or not TryStrToInt(LRight, LMax) then
      Exit(Fail(AResult, SPatternInvalidGap, AIndex));
  end
  else if LDots > 0 then
  begin
    LLeft := Trim(Copy(LInner, 1, LDots - 1));
    LRight := Trim(Copy(LInner, LDots + 2, System.Length(LInner) - LDots - 1));
    if not TryStrToInt(LLeft, LMin) or not TryStrToInt(LRight, LMax) then
      Exit(Fail(AResult, SPatternInvalidGap, AIndex));
  end
  else
  begin
    if not TryStrToInt(LInner, LMin) then
      Exit(Fail(AResult, SPatternInvalidGap, AIndex));
    LMax := LMin;
  end;
  if (LMin < 0) or (LMax < LMin) or (LMax > CMaxGapLength) then
    Exit(Fail(AResult, SPatternInvalidGap, AIndex));
  ANode := THexPatternNode.Gap(LMin, LMax);
  Result := True;
end;

function TryParseAlternative(const AText: string; out ANode: THexPatternNode;
  const AResult: THexPatternParseResult; const AIndex: Integer): Boolean;
var
  LInner: string;
  LAlternatives: TArray<string>;
  LSequences: TObjectList<TObjectList<THexPatternNode>>;
  LParts: TList<TPatternPart>;
  LSequence: TObjectList<THexPatternNode>;
  LParsed: THexPatternNode;
  I, P: Integer;
  LOk: Boolean;
begin
  ANode := nil;
  LInner := Trim(Copy(AText, 2, System.Length(AText) - 2));
  if LInner = '' then
    Exit(Fail(AResult, SPatternAlternativeEmpty, AIndex));
  LAlternatives := SplitTopLevel(LInner, '|');
  if System.Length(LAlternatives) < 2 then
    Exit(Fail(AResult, SPatternAlternativeInvalid, AIndex));

  LSequences := TObjectList<TObjectList<THexPatternNode>>.Create(True);
  LParts := TList<TPatternPart>.Create;
  try
    for I := 0 to High(LAlternatives) do
    begin
      if not TryTokenize(LAlternatives[I], LParts, AResult) then
        Exit(False);
      LSequence := TObjectList<THexPatternNode>.Create(True);
      LSequences.Add(LSequence);
      for P := 0 to LParts.Count - 1 do
      begin
        LOk := TryParseNodeFwd(LParts[P].Text, LParsed, AResult, AIndex + LParts[P].Index + 1);
        if not LOk then
          Exit(False);
        LSequence.Add(LParsed);
      end;
      if LSequence.Count = 0 then
        Exit(Fail(AResult, SPatternAlternativeEmpty, AIndex));
    end;
    ANode := THexPatternNode.Alternative(LSequences);
    Result := True;
  finally
    LParts.Free;
    LSequences.Free;
  end;
end;

function TryParseNodeFwd(const AText: string; out ANode: THexPatternNode;
  const AResult: THexPatternParseResult; const AIndex: Integer): Boolean;
var
  LValue: string;
  LToken: THexPatternToken;
begin
  ANode := nil;
  if Trim(AText) = '' then
    Exit(Fail(AResult, SPatternInvalidToken, AIndex));
  LValue := Trim(AText);
  if LValue.StartsWith('[') and LValue.EndsWith(']') then
    Exit(TryParseGap(LValue, ANode, AResult, AIndex));
  if LValue.StartsWith('(') and LValue.EndsWith(')') then
    Exit(TryParseAlternative(LValue, ANode, AResult, AIndex));
  if not THexPatternParser.TryParseToken(LValue, LToken) then
    Exit(Fail(AResult, SPatternInvalidToken, AIndex));
  ANode := THexPatternNode.FromToken(LToken);
  Result := True;
end;

class function THexPatternParser.ParseDetailed(const APatternText: string): THexPatternParseResult;
var
  LParts: TList<TPatternPart>;
  LNode: THexPatternNode;
  I: Integer;
begin
  Result := THexPatternParseResult.Create;
  Result.Pattern := THexSearchPattern.Create;
  if Trim(APatternText) = '' then
  begin
    Fail(Result, SPatternEmpty, 0);
    Exit;
  end;
  LParts := TList<TPatternPart>.Create;
  try
    if not TryTokenize(APatternText, LParts, Result) then
      Exit;
    for I := 0 to LParts.Count - 1 do
    begin
      if not TryParseNodeFwd(LParts[I].Text, LNode, Result, LParts[I].Index) then
        Exit;
      Result.Pattern.AddNode(LNode);
    end;
    if Result.Pattern.Nodes.Count = 0 then
    begin
      Fail(Result, SPatternEmpty, 0);
      Exit;
    end;
    Result.Success := True;
  finally
    LParts.Free;
  end;
end;

class function THexPatternParser.Parse(const APatternText: string): THexSearchPattern;
var
  LResult: THexPatternParseResult;
begin
  LResult := ParseDetailed(APatternText);
  try
    if not LResult.Success then
      raise EConvertError.Create(LResult.ErrorMessage);
    Result := LResult.DetachPattern;
  finally
    LResult.Free;
  end;
end;

class function THexPatternParser.TryParse(const APatternText: string; out APattern: THexSearchPattern): Boolean;
var
  LResult: THexPatternParseResult;
begin
  LResult := ParseDetailed(APatternText);
  try
    Result := LResult.Success;
    if Result then
      APattern := LResult.DetachPattern
    else
      APattern := nil;
  finally
    LResult.Free;
  end;
end;

end.

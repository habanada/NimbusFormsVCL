unit NimbusForms.Controls.LogViewer.Query;

interface

uses System.SysUtils, System.Classes, System.RegularExpressions,
  NimbusForms.Controls.LogViewer.Types, NimbusForms.Controls.LogViewer.Structured;

type
  TNimbusLogQueryOperator = (nlqoEquals, nlqoNotEquals, nlqoContains, nlqoNotContains,
    nlqoStartsWith, nlqoEndsWith, nlqoGreater, nlqoGreaterOrEqual, nlqoLess, nlqoLessOrEqual,
    nlqoExists, nlqoNotExists, nlqoRegex);

  TNimbusLogQueryNode = class
  public
    function Matches(const AEntry: TNimbusStructuredLogEntry): Boolean; virtual; abstract;
  end;

  TNimbusLogQueryCondition = class(TNimbusLogQueryNode)
  private
    FFieldPath: string;
    FOperator: TNimbusLogQueryOperator;
    FValue: string;
    FIgnoreCase: Boolean;
  public
    constructor Create(const AFieldPath: string; const AOperator: TNimbusLogQueryOperator;
      const AValue: string; const AIgnoreCase: Boolean = True);
    function Matches(const AEntry: TNimbusStructuredLogEntry): Boolean; override;
    property FieldPath: string read FFieldPath;
    property OperatorKind: TNimbusLogQueryOperator read FOperator;
    property Value: string read FValue;
    property IgnoreCase: Boolean read FIgnoreCase;
  end;

  TNimbusLogQueryLogic = (nlqlAnd, nlqlOr);

  TNimbusLogQueryGroup = class(TNimbusLogQueryNode)
  private
    FLogic: TNimbusLogQueryLogic;
    FLeft: TNimbusLogQueryNode;
    FRight: TNimbusLogQueryNode;
  public
    constructor Create(const ALogic: TNimbusLogQueryLogic; ALeft, ARight: TNimbusLogQueryNode);
    destructor Destroy; override;
    function Matches(const AEntry: TNimbusStructuredLogEntry): Boolean; override;
  end;

  TNimbusLogQueryNot = class(TNimbusLogQueryNode)
  private
    FChild: TNimbusLogQueryNode;
  public
    constructor Create(AChild: TNimbusLogQueryNode);
    destructor Destroy; override;
    function Matches(const AEntry: TNimbusStructuredLogEntry): Boolean; override;
  end;

  TNimbusLogQuery = class
  private
    FRoot: TNimbusLogQueryNode;
    FText: string;
  public
    destructor Destroy; override;
    class function Parse(const AText: string): TNimbusLogQuery; static;
    function Matches(const AEntry: TNimbusStructuredLogEntry): Boolean;
    property Text: string read FText;
  end;

implementation

uses System.DateUtils, System.StrUtils, System.Math, NimbusForms.Controls.LogViewer.Parsers;

type
  TNimbusQueryTokenKind = (nqtkEOF, nqtkWord, nqtkString, nqtkLParen, nqtkRParen, nqtkOperator, nqtkAnd, nqtkOr, nqtkNot);
  TNimbusQueryToken = record
    Kind: TNimbusQueryTokenKind;
    Text: string;
  end;

  TNimbusQueryParser = class
  private
    FText: string;
    FPosition: Integer;
    FToken: TNimbusQueryToken;
    procedure Next;
    function ParseOr: TNimbusLogQueryNode;
    function ParseAnd: TNimbusLogQueryNode;
    function ParseUnary: TNimbusLogQueryNode;
    function ParsePrimary: TNimbusLogQueryNode;
    function ParseCondition: TNimbusLogQueryNode;
    function ParseValue: string;
    function MapOperator(const AText: string; const AField: string): TNimbusLogQueryOperator;
    procedure Expect(const AKind: TNimbusQueryTokenKind);
  public
    constructor Create(const AText: string);
    function Parse: TNimbusLogQueryNode;
  end;

constructor TNimbusLogQueryCondition.Create(const AFieldPath: string; const AOperator: TNimbusLogQueryOperator;
  const AValue: string; const AIgnoreCase: Boolean);
begin
  inherited Create;
  FFieldPath := AFieldPath;
  FOperator := AOperator;
  FValue := AValue;
  FIgnoreCase := AIgnoreCase;
end;

function TNimbusLogQueryCondition.Matches(const AEntry: TNimbusStructuredLogEntry): Boolean;
var Actual, Expected, LActual, LExpected: string; ADouble, EDouble: Double; ADate, EDate: TDateTime;
  ALevel, ELevel: TNimbusLogLevel; Options: TRegExOptions;
begin
  if AEntry = nil then Exit(False);
  if FOperator = nlqoExists then begin Result := AEntry.ResolveField(FFieldPath, Actual); Exit; end;
  if FOperator = nlqoNotExists then begin Result := not AEntry.ResolveField(FFieldPath, Actual); Exit; end;
  if not AEntry.ResolveField(FFieldPath, Actual) then Exit(False);
  Expected := FValue;
  if FIgnoreCase then begin LActual := LowerCase(Actual); LExpected := LowerCase(Expected); end
  else begin LActual := Actual; LExpected := Expected; end;
  case FOperator of
    nlqoEquals: Result := LActual = LExpected;
    nlqoNotEquals: Result := LActual <> LExpected;
    nlqoContains: Result := Pos(LExpected, LActual) > 0;
    nlqoNotContains: Result := Pos(LExpected, LActual) = 0;
    nlqoStartsWith: Result := StartsStr(LExpected, LActual);
    nlqoEndsWith: Result := EndsStr(LExpected, LActual);
    nlqoRegex:
      begin
        Options := [];
        if FIgnoreCase then Include(Options, roIgnoreCase);
        Result := TRegEx.IsMatch(Actual, Expected, Options);
      end;
    nlqoGreater, nlqoGreaterOrEqual, nlqoLess, nlqoLessOrEqual:
      begin
        if SameText(FFieldPath, 'Level') then
        begin
          ALevel := NimbusParseLogLevel(Actual);
          ELevel := NimbusParseLogLevel(Expected);
          if (ALevel = nllUnknown) and not SameText(Actual, 'Unknown') then Exit(False);
          if (ELevel = nllUnknown) and not SameText(Expected, 'Unknown') then Exit(False);
          case FOperator of
            nlqoGreater: Result := Ord(ALevel) > Ord(ELevel);
            nlqoGreaterOrEqual: Result := Ord(ALevel) >= Ord(ELevel);
            nlqoLess: Result := Ord(ALevel) < Ord(ELevel);
          else Result := Ord(ALevel) <= Ord(ELevel);
          end;
        end
        else if TryStrToFloat(Actual, ADouble, TFormatSettings.Invariant) and TryStrToFloat(Expected, EDouble, TFormatSettings.Invariant) then
          case FOperator of
            nlqoGreater: Result := ADouble > EDouble;
            nlqoGreaterOrEqual: Result := ADouble >= EDouble;
            nlqoLess: Result := ADouble < EDouble;
          else Result := ADouble <= EDouble;
          end
        else if TryISO8601ToDate(Actual, ADate, False) and TryISO8601ToDate(Expected, EDate, False) then
          case FOperator of
            nlqoGreater: Result := ADate > EDate;
            nlqoGreaterOrEqual: Result := ADate >= EDate;
            nlqoLess: Result := ADate < EDate;
          else Result := ADate <= EDate;
          end
        else
          case FOperator of
            nlqoGreater: Result := CompareStr(LActual, LExpected) > 0;
            nlqoGreaterOrEqual: Result := CompareStr(LActual, LExpected) >= 0;
            nlqoLess: Result := CompareStr(LActual, LExpected) < 0;
          else Result := CompareStr(LActual, LExpected) <= 0;
          end;
      end;
  else Result := False;
  end;
end;

constructor TNimbusLogQueryGroup.Create(const ALogic: TNimbusLogQueryLogic; ALeft, ARight: TNimbusLogQueryNode);
begin
  inherited Create;
  FLogic := ALogic;
  FLeft := ALeft;
  FRight := ARight;
end;

destructor TNimbusLogQueryGroup.Destroy;
begin
  FRight.Free;
  FLeft.Free;
  inherited;
end;

function TNimbusLogQueryGroup.Matches(const AEntry: TNimbusStructuredLogEntry): Boolean;
begin
  if FLogic = nlqlAnd then Result := FLeft.Matches(AEntry) and FRight.Matches(AEntry)
  else Result := FLeft.Matches(AEntry) or FRight.Matches(AEntry);
end;

constructor TNimbusLogQueryNot.Create(AChild: TNimbusLogQueryNode);
begin
  inherited Create;
  FChild := AChild;
end;

destructor TNimbusLogQueryNot.Destroy;
begin
  FChild.Free;
  inherited;
end;

function TNimbusLogQueryNot.Matches(const AEntry: TNimbusStructuredLogEntry): Boolean;
begin
  Result := not FChild.Matches(AEntry);
end;

destructor TNimbusLogQuery.Destroy;
begin
  FRoot.Free;
  inherited;
end;

class function TNimbusLogQuery.Parse(const AText: string): TNimbusLogQuery;
var Parser: TNimbusQueryParser;
begin
  Result := TNimbusLogQuery.Create;
  Result.FText := AText;
  if Trim(AText) = '' then Exit;
  Parser := TNimbusQueryParser.Create(AText);
  try
    try Result.FRoot := Parser.Parse; except Result.Free; raise; end;
  finally Parser.Free; end;
end;

function TNimbusLogQuery.Matches(const AEntry: TNimbusStructuredLogEntry): Boolean;
begin
  Result := (FRoot = nil) or FRoot.Matches(AEntry);
end;

constructor TNimbusQueryParser.Create(const AText: string);
begin
  inherited Create;
  FText := AText;
  FPosition := 1;
  Next;
end;

procedure TNimbusQueryParser.Next;
var Start: Integer; Quote: Char; S: string;
begin
  while (FPosition <= Length(FText)) and CharInSet(FText[FPosition], [#1..#32]) do Inc(FPosition);
  if FPosition > Length(FText) then begin FToken.Kind := nqtkEOF; FToken.Text := ''; Exit; end;
  case FText[FPosition] of
    '(' : begin FToken.Kind := nqtkLParen; FToken.Text := '('; Inc(FPosition); Exit; end;
    ')' : begin FToken.Kind := nqtkRParen; FToken.Text := ')'; Inc(FPosition); Exit; end;
    '"', #39:
      begin
        Quote := FText[FPosition]; Inc(FPosition); Start := FPosition;
        while (FPosition <= Length(FText)) and (FText[FPosition] <> Quote) do
        begin if (FText[FPosition] = '\') and (FPosition < Length(FText)) then Inc(FPosition); Inc(FPosition); end;
        FToken.Kind := nqtkString; FToken.Text := Copy(FText, Start, FPosition - Start);
        if FPosition <= Length(FText) then Inc(FPosition);
        Exit;
      end;
  end;
  if CharInSet(FText[FPosition], ['=', '!', '>', '<', ':', '~']) then
  begin
    Start := FPosition; Inc(FPosition);
    if (FPosition <= Length(FText)) and CharInSet(FText[FPosition], ['=', '~']) then Inc(FPosition);
    FToken.Kind := nqtkOperator; FToken.Text := Copy(FText, Start, FPosition - Start); Exit;
  end;
  Start := FPosition;
  while (FPosition <= Length(FText)) and not CharInSet(FText[FPosition], [#1..#32, '(', ')', '=', '!', '>', '<', ':', '~', '"', #39]) do Inc(FPosition);
  S := Copy(FText, Start, FPosition - Start);
  if SameText(S, 'AND') then FToken.Kind := nqtkAnd
  else if SameText(S, 'OR') then FToken.Kind := nqtkOr
  else if SameText(S, 'NOT') then FToken.Kind := nqtkNot
  else if SameText(S, 'CONTAINS') or SameText(S, 'NOTCONTAINS') or SameText(S, 'STARTSWITH') or
    SameText(S, 'ENDSWITH') or SameText(S, 'REGEX') then FToken.Kind := nqtkOperator
  else FToken.Kind := nqtkWord;
  FToken.Text := S;
end;

procedure TNimbusQueryParser.Expect(const AKind: TNimbusQueryTokenKind);
begin
  if FToken.Kind <> AKind then raise EConvertError.CreateFmt('Invalid log query near "%s"', [FToken.Text]);
end;

function TNimbusQueryParser.Parse: TNimbusLogQueryNode;
begin
  Result := ParseOr;
  if FToken.Kind <> nqtkEOF then begin Result.Free; raise EConvertError.CreateFmt('Unexpected log query token "%s"', [FToken.Text]); end;
end;

function TNimbusQueryParser.ParseOr: TNimbusLogQueryNode;
var Right: TNimbusLogQueryNode;
begin
  Result := ParseAnd;
  while FToken.Kind = nqtkOr do
  begin Next; Right := ParseAnd; Result := TNimbusLogQueryGroup.Create(nlqlOr, Result, Right); end;
end;

function TNimbusQueryParser.ParseAnd: TNimbusLogQueryNode;
var Right: TNimbusLogQueryNode;
begin
  Result := ParseUnary;
  while FToken.Kind = nqtkAnd do
  begin Next; Right := ParseUnary; Result := TNimbusLogQueryGroup.Create(nlqlAnd, Result, Right); end;
end;

function TNimbusQueryParser.ParseUnary: TNimbusLogQueryNode;
begin
  if FToken.Kind = nqtkNot then begin Next; Result := TNimbusLogQueryNot.Create(ParseUnary); end
  else Result := ParsePrimary;
end;

function TNimbusQueryParser.ParsePrimary: TNimbusLogQueryNode;
begin
  if FToken.Kind = nqtkLParen then
  begin
    Next;
    Result := ParseOr;
    try Expect(nqtkRParen); Next; except Result.Free; raise; end;
  end
  else Result := ParseCondition;
end;

function TNimbusQueryParser.ParseValue: string;
begin
  if not (FToken.Kind in [nqtkWord, nqtkString]) then raise EConvertError.CreateFmt('Expected log query value near "%s"', [FToken.Text]);
  Result := FToken.Text;
  Next;
end;

function TNimbusQueryParser.MapOperator(const AText, AField: string): TNimbusLogQueryOperator;
begin
  if (AText = '=') or SameText(AText, 'EQ') then Result := nlqoEquals
  else if AText = '!=' then Result := nlqoNotEquals
  else if AText = '>' then Result := nlqoGreater
  else if AText = '>=' then Result := nlqoGreaterOrEqual
  else if AText = '<' then Result := nlqoLess
  else if AText = '<=' then Result := nlqoLessOrEqual
  else if (AText = '~=') or SameText(AText, 'REGEX') then Result := nlqoRegex
  else if SameText(AText, 'CONTAINS') then Result := nlqoContains
  else if SameText(AText, 'NOTCONTAINS') then Result := nlqoNotContains
  else if SameText(AText, 'STARTSWITH') then Result := nlqoStartsWith
  else if SameText(AText, 'ENDSWITH') then Result := nlqoEndsWith
  else if AText = ':' then
  begin
    if SameText(AField, 'Level') or SameText(AField, 'TraceId') or SameText(AField, 'SpanId') or SameText(AField, 'CorrelationId') or SameText(AField, 'RequestId') then Result := nlqoEquals
    else Result := nlqoContains;
  end
  else raise EConvertError.CreateFmt('Unsupported log query operator "%s"', [AText]);
end;

function TNimbusQueryParser.ParseCondition: TNimbusLogQueryNode;
var Field, OperatorText, Value: string; Op: TNimbusLogQueryOperator;
begin
  Expect(nqtkWord);
  Field := FToken.Text;
  Next;
  if SameText(Field, 'exists') or SameText(Field, 'notexists') then
  begin
    Expect(nqtkLParen); Next; Expect(nqtkWord); Value := FToken.Text; Next; Expect(nqtkRParen); Next;
    if SameText(Field, 'exists') then Op := nlqoExists else Op := nlqoNotExists;
    Exit(TNimbusLogQueryCondition.Create(Value, Op, ''));
  end;
  Expect(nqtkOperator);
  OperatorText := FToken.Text;
  Next;
  Value := ParseValue;
  Result := TNimbusLogQueryCondition.Create(Field, MapOperator(OperatorText, Field), Value);
end;

end.

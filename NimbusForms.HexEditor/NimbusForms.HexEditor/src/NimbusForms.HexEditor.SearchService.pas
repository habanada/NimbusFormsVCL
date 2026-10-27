unit NimbusForms.HexEditor.SearchService;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  NimbusForms.HexEditor.DataSource,
  NimbusForms.HexEditor.Search;

type
  THexSearchKind = (hskHexBytes, hskSignature, hskText, hskPattern);

  THexSearchService = class
  public
    class function ReadAll(const ADataSource: IHexDataSource): TBytes; static;
    class function TryParseHexBytes(const AText: string; out ABytes: TBytes): Boolean; static;
    class function IsSignature(const AText: string): Boolean; static;
    class function IsPattern(const AText: string): Boolean; static;
    class procedure Find(const ADataSource: IHexDataSource; const AText: string;
      const AKind: THexSearchKind; const AResults: TObjectList<THexSearchMatch>); static;
    class procedure FindPattern(const ADataSource: IHexDataSource; const AText: string;
      const AResults: TObjectList<THexSearchMatch>); static;
  end;

implementation

uses
  NativePattern,
  NativePattern.Core,
  NimbusForms.HexEditor.Pattern,
  NimbusForms.HexEditor.PatternParser,
  NimbusForms.HexEditor.PatternSearch;

class function THexSearchService.ReadAll(const ADataSource: IHexDataSource): TBytes;
var
  LLength, LPos: Int64;
  LChunk, LRead: Integer;
  LBuffer: TBytes;
begin
  SetLength(Result, 0);
  if ADataSource = nil then
    Exit;
  LLength := ADataSource.Length;
  if LLength <= 0 then
    Exit;
  SetLength(Result, LLength);
  LPos := 0;
  SetLength(LBuffer, 65536);
  while LPos < LLength do
  begin
    if LLength - LPos < 65536 then
      LChunk := Integer(LLength - LPos)
    else
      LChunk := 65536;
    LRead := ADataSource.Read(LPos, LBuffer, LChunk);
    if LRead <= 0 then
      Break;
    Move(LBuffer[0], Result[LPos], LRead);
    Inc(LPos, LRead);
  end;
end;

class function THexSearchService.TryParseHexBytes(const AText: string;
  out ABytes: TBytes): Boolean;
var
  LClean: string;
  LChar: Char;
  I, LCount: Integer;
  LHigh: Integer;

  function HexValue(const AChar: Char; out AValue: Integer): Boolean;
  begin
    case AChar of
      '0'..'9': AValue := Ord(AChar) - Ord('0');
      'a'..'f': AValue := Ord(AChar) - Ord('a') + 10;
      'A'..'F': AValue := Ord(AChar) - Ord('A') + 10;
    else
      Exit(False);
    end;
    Result := True;
  end;

var
  LValue: Integer;
begin
  SetLength(ABytes, 0);
  LClean := '';
  for LChar in AText do
    if (LChar <> ' ') and (LChar <> #9) and (LChar <> ',') then
      LClean := LClean + LChar;
  if (LClean = '') or (Length(LClean) mod 2 <> 0) then
    Exit(False);
  LCount := Length(LClean) div 2;
  SetLength(ABytes, LCount);
  LHigh := 0;
  I := 1;
  while I <= Length(LClean) do
  begin
    if not HexValue(LClean[I], LValue) then
    begin
      SetLength(ABytes, 0);
      Exit(False);
    end;
    LHigh := LValue shl 4;
    if not HexValue(LClean[I + 1], LValue) then
    begin
      SetLength(ABytes, 0);
      Exit(False);
    end;
    ABytes[(I - 1) div 2] := Byte(LHigh or LValue);
    Inc(I, 2);
  end;
  Result := True;
end;

class function THexSearchService.IsSignature(const AText: string): Boolean;
begin
  Result := Pos('?', AText) > 0;
end;

class function THexSearchService.IsPattern(const AText: string): Boolean;
begin
  Result := (Pos('[', AText) > 0) or (Pos('(', AText) > 0) or
    (Pos('|', AText) > 0) or (Pos('&', AText) > 0);
end;

class procedure THexSearchService.FindPattern(const ADataSource: IHexDataSource;
  const AText: string; const AResults: TObjectList<THexSearchMatch>);
var
  LPat: THexSearchPattern;
  LMatches: TObjectList<THexSearchMatch>;
  I: Integer;
begin
  if AResults = nil then
    Exit;
  AResults.Clear;
  if (ADataSource = nil) or (Trim(AText) = '') then
    Exit;
  if not THexPatternParser.TryParse(AText, LPat) then
    Exit;
  try
    LMatches := THexPatternSearch.Search(ADataSource, LPat, 0, -1, 4096);
    try
      for I := 0 to LMatches.Count - 1 do
        AResults.Add(THexSearchMatch.Create(LMatches[I].Offset, LMatches[I].Length));
    finally
      LMatches.Free;
    end;
  finally
    LPat.Free;
  end;
end;

class procedure THexSearchService.Find(const ADataSource: IHexDataSource;
  const AText: string; const AKind: THexSearchKind;
  const AResults: TObjectList<THexSearchMatch>);
var
  LData, LPattern: TBytes;
  LSignature: TBytePattern;
  LMatches: TPatternMatches;
  LMatch: TPatternMatch;
begin
  if AResults = nil then
    Exit;
  AResults.Clear;
  if (ADataSource = nil) or (Trim(AText) = '') then
    Exit;
  LData := ReadAll(ADataSource);
  if Length(LData) = 0 then
    Exit;

  case AKind of
    hskSignature:
      begin
        LSignature := TBytePattern.Parse(AText);
        LMatches := TPatternSearch.FindAll(LData, LSignature);
      end;
    hskText:
      begin
        LPattern := TEncoding.ANSI.GetBytes(AText);
        if Length(LPattern) = 0 then
          Exit;
        LMatches := TPatternSearch.FindAll(LData, LPattern);
      end;
    hskPattern:
      begin
        FindPattern(ADataSource, AText, AResults);
        Exit;
      end;
  else
    begin
      if not TryParseHexBytes(AText, LPattern) then
        Exit;
      LMatches := TPatternSearch.FindAll(LData, LPattern);
    end;
  end;

  for LMatch in LMatches do
    AResults.Add(THexSearchMatch.Create(LMatch.Offset, Integer(LMatch.MatchLength)));
end;

end.

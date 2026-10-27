{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.LogViewer.Types;

interface

uses System.Classes, System.SysUtils, NimbusForms.Theming.Types, NimbusForms.Theming.Palette;

type
  TNimbusLogLevel = (nllUnknown, nllTrace, nllDebug, nllInfo, nllSuccess, nllWarning, nllError, nllFatal);
  TNimbusLogLevels = set of TNimbusLogLevel;
  TNimbusLogInsertMode = (nlimBottom, nlimTop);
  TNimbusLogFileEncoding = (nlfeAuto, nlfeUTF8, nlfeUTF16LE, nlfeUTF16BE, nlfeANSI,
    nlfeASCII, nlfeUTF32LE, nlfeUTF32BE, nlfeLatin1, nlfeWindows1252);
  TNimbusLogTokenKind = (nltkText, nltkDateTime, nltkLevel, nltkNumber, nltkString,
    nltkParenthesis, nltkBracket, nltkBrace);
  TNimbusLogHighlightKinds = set of TNimbusLogTokenKind;
  TNimbusLogToken = record
    Start, Length: Integer;
    Kind: TNimbusLogTokenKind;
    Level: TNimbusLogLevel;
  end;
  TNimbusLogTokens = TArray<TNimbusLogToken>;
  TNimbusLogSearchHit = record
    LineID: UInt64;
    SourceIndex64: Int64;
    VisibleIndex64: Int64;
    Column, Length, VisibleIndex: Integer;
    IsTextMatch: Boolean;
  end;

  TNimbusLogLexer = class
  public
    class function LevelOf(const AWord: string): TNimbusLogLevel; static;
    class function Parse(const AText: string; out ALevel: TNimbusLogLevel): TNimbusLogTokens; static;
  end;

  TNimbusLogHighlightOptions = class(TPersistent)
  private
    FKinds: TNimbusLogHighlightKinds;
    FColorizeMessageText: Boolean;
    FColors: array[TNimbusLogTokenKind] of TThemeColor;
    FLevelColors: array[TNimbusLogLevel] of TThemeColor;
    FOnChange: TNotifyEvent;
    procedure SetKinds(const AValue: TNimbusLogHighlightKinds);
    procedure SetColorizeMessageText(const AValue: Boolean);
    function GetColor(const AIndex: Integer): TThemeColor;
    procedure SetColor(const AIndex: Integer; const AValue: TThemeColor);
  public
    constructor Create(const AOnChange: TNotifyEvent);
    procedure Assign(Source: TPersistent); override;
    function LevelColor(const ALevel: TNimbusLogLevel; const APalette: TThemePalette): TThemeColor;
    function TokenColor(const AKind: TNimbusLogTokenKind; const ALevel: TNimbusLogLevel;
      const APalette: TThemePalette; const ABaseColor: TThemeColor): TThemeColor;
  published
    property Kinds: TNimbusLogHighlightKinds read FKinds write SetKinds default [nltkDateTime, nltkLevel, nltkNumber, nltkString, nltkParenthesis, nltkBracket, nltkBrace];
    property ColorizeMessageText: Boolean read FColorizeMessageText write SetColorizeMessageText default False;
    property DateTimeColor: TThemeColor index 1 read GetColor write SetColor default 0;
    property NumberColor: TThemeColor index 3 read GetColor write SetColor default 0;
    property StringColor: TThemeColor index 4 read GetColor write SetColor default 0;
    property ParenthesisColor: TThemeColor index 5 read GetColor write SetColor default 0;
    property BracketColor: TThemeColor index 6 read GetColor write SetColor default 0;
    property BraceColor: TThemeColor index 7 read GetColor write SetColor default 0;
    property TraceColor: TThemeColor index 8 read GetColor write SetColor default 0;
    property DebugColor: TThemeColor index 9 read GetColor write SetColor default 0;
    property InfoColor: TThemeColor index 10 read GetColor write SetColor default 0;
    property SuccessColor: TThemeColor index 11 read GetColor write SetColor default 0;
    property WarningColor: TThemeColor index 12 read GetColor write SetColor default 0;
    property ErrorColor: TThemeColor index 13 read GetColor write SetColor default 0;
    property FatalColor: TThemeColor index 14 read GetColor write SetColor default 0;
  end;

implementation

uses System.Generics.Collections, System.RegularExpressions, NimbusForms.Rendering.Types;

var LogDatePattern: TRegEx;

class function TNimbusLogLexer.LevelOf(const AWord: string): TNimbusLogLevel;
var S: string;
begin
  Result := nllUnknown;
  if (Length(AWord) < 2) or (Length(AWord) > 13) then Exit;
  S := UpperCase(AWord);
  if (S = 'ERR') or (S = 'ERROR') then Result := nllError
  else if (S = 'WARN') or (S = 'WARNING') or (S = 'WRN') then Result := nllWarning
  else if (S = 'INFO') or (S = 'INFORMATION') or (S = 'INFORMATIONAL') or (S = 'INF') then Result := nllInfo
  else if (S = 'DEBUG') or (S = 'DBG') then Result := nllDebug
  else if (S = 'TRACE') or (S = 'TRC') or (S = 'VERBOSE') then Result := nllTrace
  else if (S = 'SUCCESS') or (S = 'OK') then Result := nllSuccess
  else if (S = 'FATAL') or (S = 'CRITICAL') or (S = 'CRT') then Result := nllFatal;
end;

class function TNimbusLogLexer.Parse(const AText: string; out ALevel: TNimbusLogLevel): TNimbusLogTokens;
var
  Tokens: TList<TNimbusLogToken>;
  Dates: TMatchCollection;
  I, J, DateIndex, DateCount, N, Start: Integer;
  Quote: Char;
  Kind: TNimbusLogTokenKind;
  Level: TNimbusLogLevel;
  Token: TNimbusLogToken;

  function IsWord(const C: Char): Boolean;
  begin Result := CharInSet(C, ['A'..'Z', 'a'..'z', '0'..'9', '_']); end;

  procedure Add(const P, Count: Integer; const K: TNimbusLogTokenKind);
  var Previous: TNimbusLogToken;
  begin
    if Count <= 0 then Exit;
    if Tokens.Count > 0 then
    begin
      Previous := Tokens[Tokens.Count - 1];
      if (K <> nltkLevel) and (Previous.Kind = K) and (Previous.Start + Previous.Length = P) then
      begin Inc(Previous.Length, Count); Tokens[Tokens.Count - 1] := Previous; Exit; end;
    end;
    Token.Start := P; Token.Length := Count; Token.Kind := K;
    Token.Level := nllUnknown;
    if K = nltkLevel then Token.Level := LevelOf(Copy(AText, P + 1, Count));
    Tokens.Add(Token);
  end;

begin
  ALevel := nllUnknown;
  Tokens := TList<TNimbusLogToken>.Create;
  try
    Dates := LogDatePattern.Matches(AText);
    DateCount := Dates.Count;
    I := 1; N := Length(AText); DateIndex := 0;
    while I <= N do
    begin
      while (DateIndex < DateCount) and (Dates[DateIndex].Index < I - 1) do Inc(DateIndex);
      if (DateIndex < DateCount) and (Dates[DateIndex].Index = I - 1) then
      begin Add(I - 1, Dates[DateIndex].Length, nltkDateTime); Inc(I, Dates[DateIndex].Length); Continue; end;
      Start := I;
      Kind := nltkText;
      if CharInSet(AText[I], ['"', #39]) then
      begin
        Quote := AText[I]; Inc(I);
        while I <= N do
        begin
          if AText[I] = '\' then begin Inc(I); if I <= N then Inc(I); Continue; end;
          if AText[I] = Quote then
          begin
            Inc(I);
            if (I <= N) and (AText[I] = Quote) then begin Inc(I); Continue; end;
            Break;
          end;
          Inc(I);
        end;
        Kind := nltkString;
      end
      else if CharInSet(AText[I], ['0'..'9']) or
        (CharInSet(AText[I], ['+', '-', '.']) and (I < N) and CharInSet(AText[I + 1], ['0'..'9'])) then
      begin
        if CharInSet(AText[I], ['+', '-']) then Inc(I);
        if (I < N) and (AText[I] = '0') and CharInSet(AText[I + 1], ['x', 'X']) then
        begin Inc(I, 2); while (I <= N) and CharInSet(AText[I], ['0'..'9', 'A'..'F', 'a'..'f']) do Inc(I); end
        else
        begin
          while (I <= N) and CharInSet(AText[I], ['0'..'9']) do Inc(I);
          if (I <= N) and CharInSet(AText[I], ['.', ',']) then
          begin Inc(I); while (I <= N) and CharInSet(AText[I], ['0'..'9']) do Inc(I); end;
          if (I <= N) and CharInSet(AText[I], ['e', 'E']) then
          begin
            J := I + 1;
            if (J <= N) and CharInSet(AText[J], ['+', '-']) then Inc(J);
            if (J <= N) and CharInSet(AText[J], ['0'..'9']) then
            begin I := J; while (I <= N) and CharInSet(AText[I], ['0'..'9']) do Inc(I); end;
          end;
        end;
        Kind := nltkNumber;
      end
      else if IsWord(AText[I]) then
      begin
        while (I <= N) and IsWord(AText[I]) do Inc(I);
        Level := LevelOf(Copy(AText, Start, I - Start));
        if Level <> nllUnknown then
        begin
          Kind := nltkLevel;
          if ALevel = nllUnknown then ALevel := Level;
        end;
      end
      else
      begin
        case AText[I] of
          '(', ')': Kind := nltkParenthesis;
          '[', ']': Kind := nltkBracket;
          '{', '}': Kind := nltkBrace;
        end;
        Inc(I);
      end;
      Add(Start - 1, I - Start, Kind);
    end;
    Result := Tokens.ToArray;
  finally Tokens.Free; end;
end;

constructor TNimbusLogHighlightOptions.Create(const AOnChange: TNotifyEvent);
begin
  inherited Create;
  FOnChange := AOnChange;
  FKinds := [nltkDateTime, nltkLevel, nltkNumber, nltkString, nltkParenthesis, nltkBracket, nltkBrace];
end;

procedure TNimbusLogHighlightOptions.Assign(Source: TPersistent);
var O: TNimbusLogHighlightOptions;
begin
  if not (Source is TNimbusLogHighlightOptions) then begin inherited; Exit; end;
  O := TNimbusLogHighlightOptions(Source);
  FKinds := O.FKinds; FColors := O.FColors; FLevelColors := O.FLevelColors;
  FColorizeMessageText := O.FColorizeMessageText;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusLogHighlightOptions.SetKinds(const AValue: TNimbusLogHighlightKinds);
begin
  if FKinds = AValue then Exit;
  FKinds := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNimbusLogHighlightOptions.SetColorizeMessageText(const AValue: Boolean);
begin
  if FColorizeMessageText = AValue then Exit;
  FColorizeMessageText := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

function TNimbusLogHighlightOptions.GetColor(const AIndex: Integer): TThemeColor;
begin
  if AIndex < 8 then Result := FColors[TNimbusLogTokenKind(AIndex)]
  else Result := FLevelColors[TNimbusLogLevel(AIndex - 7)];
end;

procedure TNimbusLogHighlightOptions.SetColor(const AIndex: Integer; const AValue: TThemeColor);
begin
  if GetColor(AIndex) = AValue then Exit;
  if AIndex < 8 then FColors[TNimbusLogTokenKind(AIndex)] := AValue
  else FLevelColors[TNimbusLogLevel(AIndex - 7)] := AValue;
  if Assigned(FOnChange) then FOnChange(Self);
end;

function TNimbusLogHighlightOptions.LevelColor(const ALevel: TNimbusLogLevel; const APalette: TThemePalette): TThemeColor;
begin
  Result := FLevelColors[ALevel];
  if Result <> 0 then Exit;
  case ALevel of
    nllTrace: Result := NimbusMutedForeColor(APalette);
    nllDebug: Result := ThemeColor(255, 165, 120, 210);
    nllInfo: Result := NimbusAccentColor(APalette);
    nllSuccess: Result := NimbusSuccessColor;
    nllWarning: Result := NimbusWarningColor;
    nllError, nllFatal: Result := NimbusDangerColor;
  else Result := NimbusControlForeColor(APalette);
  end;
end;

function TNimbusLogHighlightOptions.TokenColor(const AKind: TNimbusLogTokenKind; const ALevel: TNimbusLogLevel;
  const APalette: TThemePalette; const ABaseColor: TThemeColor): TThemeColor;
begin
  Result := ABaseColor;
  if not (AKind in FKinds) then Exit;
  if AKind = nltkLevel then Exit(LevelColor(ALevel, APalette));
  if FColors[AKind] <> 0 then Exit(FColors[AKind]);
  case AKind of
    nltkDateTime: Result := NimbusMutedForeColor(APalette);
    nltkNumber: Result := ThemeColor(255, 110, 175, 155);
    nltkString: Result := ThemeColor(255, 205, 145, 105);
    nltkParenthesis: Result := NimbusMutedForeColor(APalette);
    nltkBracket: Result := NimbusAccentColor(APalette);
    nltkBrace: Result := ThemeColor(255, 165, 120, 210);
  end;
end;

initialization
  LogDatePattern := TRegEx.Create('\b(?:\d{4}[-/]\d{2}[-/]\d{2}(?:[ T]\d{2}:\d{2}:\d{2}(?:[.,]\d+)?(?:Z|[+-]\d{2}:?\d{2})?)?|\d{2}[./]\d{2}[./]\d{4}(?:\s+\d{2}:\d{2}:\d{2}(?:[.,]\d+)?)?|\d{2}:\d{2}:\d{2}(?:[.,]\d+)?)\b');

end.

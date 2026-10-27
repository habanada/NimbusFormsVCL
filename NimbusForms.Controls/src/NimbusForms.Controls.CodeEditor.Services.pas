{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.CodeEditor.Services;

interface

uses System.Classes, System.SysUtils, System.Types, System.Generics.Collections, System.RegularExpressions, System.SyncObjs,
  NimbusForms.Controls.CodeEditor.Types, NimbusForms.Controls.CodeEditor.Document, NimbusForms.Controls.CodeEditor.Syntax;

type
  ICodeFoldProvider = interface
    ['{4A777CB5-6A83-4D4F-AE38-42DF3CA34009}']
    function GetFoldRegions(const Source: ICodeVirtualTextSource): TArray<TCodeFoldRegion>;
  end;
  ICodeDiagnosticProvider = interface
    ['{5210D7BB-F285-4A66-A58B-1221B11AD7A3}']
    function GetDiagnostics(const Source: ICodeVirtualTextSource): TArray<TCodeDiagnostic>;
  end;
  ICodeCompletionProvider = interface
    ['{A9797C88-CA60-49E2-85AB-DA5E1CBF2EAD}']
    function GetCompletions(const Source: ICodeVirtualTextSource; const Position: TCodeDocumentPosition;
      const Trigger: TCodeEditorCompletionTrigger): TArray<TCodeCompletionItem>;
  end;
  ICodeEditorSymbolProvider = interface
    ['{E1288215-D953-454E-BD29-18786A688AC6}']
    function GetSymbols(const Source: ICodeVirtualTextSource; const LanguageName: string): TArray<TCodeEditorSymbolInfo>;
  end;
  ICodeEditorNavigationProvider = interface
    ['{56F877D1-7C72-4A0B-8EE1-442B3BD8DF15}']
    function TryNavigate(const Source: ICodeVirtualTextSource; const Word: TCodeEditorWordHitInfo;
      out Navigation: TCodeEditorNavigationResult): Boolean;
  end;
  ICodeEditorQuickInfoProvider = interface
    ['{8DCF5B38-13A3-4CCF-8851-64369E064C90}']
    function TryGetQuickInfo(const Source: ICodeVirtualTextSource; const Word: TCodeEditorWordHitInfo;
      out Info: TCodeEditorQuickInfo): Boolean;
  end;
  TCodeBookmarkEvent = procedure(Sender: TObject; const Bookmark: TCodeBookmark) of object;
  TCodeBookmarkManager = class
  private
    FItems: TList<TCodeBookmark>;
    FOnChange: TNotifyEvent;
    FOnAdded, FOnRemoved: TCodeBookmarkEvent;
    procedure Changed;
  public
    constructor Create(const OnChange: TNotifyEvent);
    destructor Destroy; override;
    function FindAtLine(const Line: Integer): Integer;
    procedure Toggle(const Position: TCodeDocumentPosition);
    procedure Add(const Bookmark: TCodeBookmark);
    procedure Remove(const Index: Integer);
    procedure Clear;
    function Next(const Line: Integer; const Forward: Boolean; out Bookmark: TCodeBookmark): Boolean;
    procedure ApplyChange(const Change: TCodeDocumentChange; const Source: ICodeVirtualTextSource);
    property Items: TList<TCodeBookmark> read FItems;
    property OnAdded: TCodeBookmarkEvent read FOnAdded write FOnAdded;
    property OnRemoved: TCodeBookmarkEvent read FOnRemoved write FOnRemoved;
  end;
  TCodeFoldManager = class
  private
    FRegions: TList<TCodeFoldRegion>;
    FOnChange: TNotifyEvent;
  public
    constructor Create(const OnChange: TNotifyEvent);
    destructor Destroy; override;
    procedure SetRegions(const Regions: TArray<TCodeFoldRegion>);
    function FindHeader(const Line: Integer): Integer;
    procedure Toggle(const Index: Integer);
    procedure SetAllCollapsed(const Value: Boolean);
    procedure Reveal(const Position: TCodeDocumentPosition);
    function IsHidden(const Line: Integer): Boolean;
    procedure ApplyChange(const Change: TCodeDocumentChange; const Source: ICodeVirtualTextSource);
    property Regions: TList<TCodeFoldRegion> read FRegions;
  end;
  TCodeSymbolBodyMode = (csbDeclarationLine, csbBraceBlock, csbIndentationBlock, csbPascalBlock, csbSqlBlock, csbXmlElementBlock);
  TCodeEditorSymbolPattern = record
    LanguageName, Name, RegexPattern, NameGroup: string;
    Kind: TCodeEditorSymbolKind;
    BodyMode: TCodeSymbolBodyMode;
    Options: TRegExOptions;
    Priority: Integer;
    Enabled, TrimQualifiedName: Boolean;
    Expression: TRegEx;
  end;
  TCodeEditorSymbolPatternRegistry = class
  private
    FPatterns: TList<TCodeEditorSymbolPattern>;
    FLock: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const Language, Name, Expression: string; const Kind: TCodeEditorSymbolKind;
      const BodyMode: TCodeSymbolBodyMode; const Options: TRegExOptions; const Priority: Integer);
    procedure Clear(const Language: string);
    function GetPatterns(const Language: string): TArray<TCodeEditorSymbolPattern>;
  end;
  TCodeEditorSymbolIndex = class
  private
    FItems: TList<TCodeEditorSymbolInfo>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure SetSymbols(const Symbols: TArray<TCodeEditorSymbolInfo>);
    function Find(const Name: string; out Symbol: TCodeEditorSymbolInfo): Boolean;
    function GetContaining(const Position: TCodeDocumentPosition; out Symbol: TCodeEditorSymbolInfo): Boolean;
    property Items: TList<TCodeEditorSymbolInfo> read FItems;
  end;
  TCodeEditorAnalyzer = class
  private
    FSource: ICodeVirtualTextSource;
    FHighlighter: ICodeSyntaxHighlighter;
    FState: TCodeHighlightState;
    FLine, FVersion: Integer;
    FStack: TList<TCodeBracketPair>;
    FPairs: TList<TCodeBracketPair>;
    FFolds: TList<TCodeFoldRegion>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Start(const Source: ICodeVirtualTextSource; const Highlighter: ICodeSyntaxHighlighter);
    procedure Cancel;
    function Advance(const MaxLines, MaxMilliseconds: Integer): Boolean;
    function Complete: Boolean;
    property Version: Integer read FVersion;
    property Pairs: TList<TCodeBracketPair> read FPairs;
    property Folds: TList<TCodeFoldRegion> read FFolds;
  end;
  TLocalCodeSymbolProvider = class(TInterfacedObject, ICodeEditorSymbolProvider)
  private
    FRegistry: TCodeEditorSymbolPatternRegistry;
    function ResolveBody(const Source: ICodeVirtualTextSource; const Line: Integer;
      const Mode: TCodeSymbolBodyMode; const Name: string): TCodeDocumentRange;
  public
    constructor Create(const Registry: TCodeEditorSymbolPatternRegistry);
    function GetSymbols(const Source: ICodeVirtualTextSource; const LanguageName: string): TArray<TCodeEditorSymbolInfo>;
  end;
  TKeywordCompletionProvider = class(TInterfacedObject, ICodeCompletionProvider)
  private
    FLanguage: ICodeLanguageDefinition;
  public
    constructor Create(const Language: ICodeLanguageDefinition);
    function GetCompletions(const Source: ICodeVirtualTextSource; const Position: TCodeDocumentPosition;
      const Trigger: TCodeEditorCompletionTrigger): TArray<TCodeCompletionItem>;
  end;
  TCodeSearchEngine = class
  public
    class function Search(const Source: ICodeVirtualTextSource; const Options: TCodeSearchOptions): TArray<TCodeSearchMatch>; static;
  end;

function CodeWordAt(const Source: ICodeVirtualTextSource; const Position: TCodeDocumentPosition; const PreferPrevious: Boolean = False): TCodeEditorWordHitInfo;
function CodeLeadingColumns(const Text: string; const TabSize: Integer): Integer;
function CodeFindEnclosingBlock(const Source: ICodeVirtualTextSource; const Highlighter: ICodeSyntaxHighlighter;
  const LanguageName: string; const Selection: TCodeDocumentRange; out Block: TCodeDocumentRange): Boolean;
procedure CodeBuildSymbolHierarchy(var Symbols: TArray<TCodeEditorSymbolInfo>);

implementation

uses Winapi.Windows, System.Math, System.Character, NimbusForms.Controls.CodeEditor.SymbolPatterns, NimbusForms.Controls.CodeEditor.Structure;

function CodeFindEnclosingBlock(const Source: ICodeVirtualTextSource; const Highlighter: ICodeSyntaxHighlighter;
  const LanguageName: string; const Selection: TCodeDocumentRange; out Block: TCodeDocumentRange): Boolean;
begin Result := CodeFindEnclosingStructure(Source, Highlighter, LanguageName, Selection, Block); end;
function CodeLeadingColumns(const Text: string; const TabSize: Integer): Integer;
var C: Char;
begin Result := 0; for C in Text do if C = #9 then Inc(Result, TabSize - Result mod TabSize) else if C = ' ' then Inc(Result) else Break; end;
function CodeWordAt(const Source: ICodeVirtualTextSource; const Position: TCodeDocumentPosition; const PreferPrevious: Boolean): TCodeEditorWordHitInfo;
var Text: string; L, R: Integer;
  function WordChar(const C: Char): Boolean;
  begin Result := C.IsLetterOrDigit or CharInSet(C, ['_', '$']) or
    (C.GetUnicodeCategory in [TUnicodeCategory.ucNonSpacingMark, TUnicodeCategory.ucCombiningMark, TUnicodeCategory.ucEnclosingMark]); end;
begin
  Result := Default(TCodeEditorWordHitInfo); Result.Position := Position;
  Text := Source.GetLineText(Position.LineIndex); L := EnsureRange(Position.ColumnIndex, 0, Length(Text)); R := L;
  if (L < Length(Text)) and not WordChar(Text[L + 1]) and not (PreferPrevious and (L > 0) and WordChar(Text[L])) then
  begin Result.Range := TCodeDocumentRange.Create(Position, Position); Exit; end;
  while (L > 0) and WordChar(Text[L]) do Dec(L);
  while (R < Length(Text)) and WordChar(Text[R + 1]) do Inc(R);
  Result.Word := Copy(Text, L + 1, R - L);
  Result.Range := TCodeDocumentRange.Create(TCodeDocumentPosition.Create(Position.LineIndex, L), TCodeDocumentPosition.Create(Position.LineIndex, R));
  if Result.Word <> '' then Result.Position.ColumnIndex := Min(Result.Position.ColumnIndex, R - 1);
end;

procedure CodeBuildSymbolHierarchy(var Symbols: TArray<TCodeEditorSymbolInfo>);
var I, J, Best, Size, BestSize, Count: Integer;
begin
  for I := 0 to High(Symbols) do begin Symbols[I].ParentIndex := -1; Symbols[I].Children := nil; end;
  for I := 0 to High(Symbols) do
  begin
    Best := -1; BestSize := MaxInt;
    for J := 0 to High(Symbols) do
      if (J <> I) and Symbols[J].BodyRange.Contains(Symbols[I].NameRange.Start) and
        (Symbols[J].BodyRange.Start.Compare(Symbols[I].BodyRange.Start) < 0) then
      begin
        Size := Symbols[J].BodyRange.Finish.LineIndex - Symbols[J].BodyRange.Start.LineIndex;
        if Size < BestSize then begin Best := J; BestSize := Size; end;
      end;
    Symbols[I].ParentIndex := Best;
    if Best >= 0 then begin Count := Length(Symbols[Best].Children); SetLength(Symbols[Best].Children, Count + 1); Symbols[Best].Children[Count] := I; end;
  end;
end;

constructor TCodeBookmarkManager.Create(const OnChange: TNotifyEvent);
begin inherited Create; FItems := TList<TCodeBookmark>.Create; FOnChange := OnChange; end;
destructor TCodeBookmarkManager.Destroy;
begin FItems.Free; inherited; end;
procedure TCodeBookmarkManager.Changed;
begin if Assigned(FOnChange) then FOnChange(Self); end;
function TCodeBookmarkManager.FindAtLine(const Line: Integer): Integer;
var I: Integer;
begin Result := -1; for I := 0 to FItems.Count - 1 do if FItems[I].LineIndex = Line then Exit(I); end;
procedure TCodeBookmarkManager.Add(const Bookmark: TCodeBookmark);
begin if FindAtLine(Bookmark.LineIndex) >= 0 then Exit; FItems.Add(Bookmark); if Assigned(FOnAdded) then FOnAdded(Self, Bookmark); Changed; end;
procedure TCodeBookmarkManager.Remove(const Index: Integer);
var Item: TCodeBookmark;
begin Item := FItems[Index]; FItems.Delete(Index); if Assigned(FOnRemoved) then FOnRemoved(Self, Item); Changed; end;
procedure TCodeBookmarkManager.Clear;
begin while FItems.Count > 0 do Remove(FItems.Count - 1); end;
procedure TCodeBookmarkManager.Toggle(const Position: TCodeDocumentPosition);
var I: Integer; Item: TCodeBookmark;
begin I := FindAtLine(Position.LineIndex); if I >= 0 then Remove(I) else begin Item.LineIndex := Position.LineIndex; Item.Name := ''; Add(Item); end; end;
function TCodeBookmarkManager.Next(const Line: Integer; const Forward: Boolean; out Bookmark: TCodeBookmark): Boolean;
var I, Best, Wrap: Integer;
begin
  Result := FItems.Count > 0; if not Result then Exit; Best := -1; Wrap := 0;
  for I := 0 to FItems.Count - 1 do
  begin
    if Forward then
    begin
      if FItems[I].LineIndex < FItems[Wrap].LineIndex then Wrap := I;
      if (FItems[I].LineIndex > Line) and ((Best < 0) or (FItems[I].LineIndex < FItems[Best].LineIndex)) then Best := I;
    end
    else
    begin
      if FItems[I].LineIndex > FItems[Wrap].LineIndex then Wrap := I;
      if (FItems[I].LineIndex < Line) and ((Best < 0) or (FItems[I].LineIndex > FItems[Best].LineIndex)) then Best := I;
    end;
  end;
  if Best < 0 then Best := Wrap; Bookmark := FItems[Best];
end;
procedure TCodeBookmarkManager.ApplyChange(const Change: TCodeDocumentChange; const Source: ICodeVirtualTextSource);
var Delta, I, LastRemoved: Integer; C: Char; Item: TCodeBookmark;
begin
  if Change.Reset then begin Clear; Exit; end;
  Delta := 0; LastRemoved := Change.Range.Start.LineIndex;
  for C in Change.NewText do if C = #10 then Inc(Delta);
  for C in Change.OldText do if C = #10 then begin Dec(Delta); Inc(LastRemoved); end;
  for I := FItems.Count - 1 downto 0 do
  begin
    Item := FItems[I];
    if (Item.LineIndex > Change.Range.Start.LineIndex) and (Item.LineIndex <= LastRemoved) then begin Remove(I); Continue; end;
    if Item.LineIndex > LastRemoved then begin Item.LineIndex := EnsureRange(Item.LineIndex + Delta, 0, Source.LineCount - 1); FItems[I] := Item; end;
  end;
  Changed;
end;

constructor TCodeFoldManager.Create(const OnChange: TNotifyEvent);
begin inherited Create; FRegions := TList<TCodeFoldRegion>.Create; FOnChange := OnChange; end;
destructor TCodeFoldManager.Destroy;
begin FRegions.Free; inherited; end;
procedure TCodeFoldManager.SetRegions(const Regions: TArray<TCodeFoldRegion>);
var Next: TArray<TCodeFoldRegion>; I, J: Integer;
begin
  Next := Copy(Regions);
  for I := 0 to High(Next) do
    for J := 0 to FRegions.Count - 1 do
      if Next[I].Range.Start.Compare(FRegions[J].Range.Start) = 0 then begin Next[I].IsCollapsed := FRegions[J].IsCollapsed; Break; end;
  FRegions.Clear; FRegions.AddRange(Next); if Assigned(FOnChange) then FOnChange(Self);
end;
function TCodeFoldManager.FindHeader(const Line: Integer): Integer;
var I: Integer;
begin Result := -1; for I := 0 to FRegions.Count - 1 do if FRegions[I].Range.Start.LineIndex = Line then Exit(I); end;
procedure TCodeFoldManager.Toggle(const Index: Integer);
var R: TCodeFoldRegion;
begin if (Index < 0) or (Index >= FRegions.Count) then Exit; R := FRegions[Index]; R.IsCollapsed := not R.IsCollapsed; FRegions[Index] := R; if Assigned(FOnChange) then FOnChange(Self); end;
procedure TCodeFoldManager.SetAllCollapsed(const Value: Boolean);
var I: Integer; R: TCodeFoldRegion;
begin for I := 0 to FRegions.Count - 1 do begin R := FRegions[I]; R.IsCollapsed := Value; FRegions[I] := R; end; if Assigned(FOnChange) then FOnChange(Self); end;
procedure TCodeFoldManager.Reveal(const Position: TCodeDocumentPosition);
var I: Integer; R: TCodeFoldRegion; Changed: Boolean;
begin
  Changed := False;
  for I := 0 to FRegions.Count - 1 do
  begin
    R := FRegions[I];
    if R.IsCollapsed and (Position.LineIndex > R.Range.Start.LineIndex) and (Position.LineIndex <= R.Range.Finish.LineIndex) then
    begin R.IsCollapsed := False; FRegions[I] := R; Changed := True; end;
  end;
  if Changed and Assigned(FOnChange) then FOnChange(Self);
end;
function TCodeFoldManager.IsHidden(const Line: Integer): Boolean;
var R: TCodeFoldRegion;
begin Result := False; for R in FRegions do if R.IsCollapsed and (Line > R.Range.Start.LineIndex) and (Line <= R.Range.Finish.LineIndex) then Exit(True); end;
procedure TCodeFoldManager.ApplyChange(const Change: TCodeDocumentChange; const Source: ICodeVirtualTextSource);
var I, Delta, LastOld: Integer; C: Char; R: TCodeFoldRegion;
begin
  if Change.Reset then begin SetRegions(nil); Exit; end;
  Delta := 0; LastOld := Change.Range.Start.LineIndex;
  for C in Change.NewText do if C = #10 then Inc(Delta);
  for C in Change.OldText do if C = #10 then begin Dec(Delta); Inc(LastOld); end;
  for I := FRegions.Count - 1 downto 0 do
  begin
    R := FRegions[I];
    if (R.Range.Start.LineIndex >= Change.Range.Start.LineIndex) and (R.Range.Finish.LineIndex <= LastOld) and (LastOld > Change.Range.Start.LineIndex) then begin FRegions.Delete(I); Continue; end;
    if R.Range.Start.LineIndex > LastOld then Inc(R.Range.Start.LineIndex, Delta);
    if R.Range.Finish.LineIndex >= LastOld then Inc(R.Range.Finish.LineIndex, Delta);
    R.Range.Start.LineIndex := EnsureRange(R.Range.Start.LineIndex, 0, Source.LineCount - 1);
    R.Range.Finish.LineIndex := EnsureRange(R.Range.Finish.LineIndex, R.Range.Start.LineIndex, Source.LineCount - 1);
    FRegions[I] := R;
  end;
  if Assigned(FOnChange) then FOnChange(Self);
end;

constructor TCodeEditorSymbolPatternRegistry.Create;
begin inherited Create; FLock := TCriticalSection.Create; FPatterns := TList<TCodeEditorSymbolPattern>.Create; RegisterCodeSymbolPatterns(Self); end;
destructor TCodeEditorSymbolPatternRegistry.Destroy;
begin FPatterns.Free; FLock.Free; inherited; end;
procedure TCodeEditorSymbolPatternRegistry.Add(const Language, Name, Expression: string; const Kind: TCodeEditorSymbolKind;
  const BodyMode: TCodeSymbolBodyMode; const Options: TRegExOptions; const Priority: Integer);
var P: TCodeEditorSymbolPattern;
begin
  P := Default(TCodeEditorSymbolPattern); P.LanguageName := LowerCase(Language); P.Name := Name;
  P.RegexPattern := Expression; P.NameGroup := 'name'; P.Kind := Kind; P.BodyMode := BodyMode;
  P.Options := Options; P.Priority := Priority; P.Enabled := True; P.TrimQualifiedName := True;
  P.Expression := TRegEx.Create(Expression, Options); FLock.Acquire;
  try FPatterns.Add(P); finally FLock.Release; end;
end;
procedure TCodeEditorSymbolPatternRegistry.Clear(const Language: string);
var I: Integer;
begin FLock.Acquire; try for I := FPatterns.Count - 1 downto 0 do if SameText(FPatterns[I].LanguageName, Language) then FPatterns.Delete(I); finally FLock.Release; end; end;
function TCodeEditorSymbolPatternRegistry.GetPatterns(const Language: string): TArray<TCodeEditorSymbolPattern>;
var P: TCodeEditorSymbolPattern; L: TList<TCodeEditorSymbolPattern>; Name: string; I, J: Integer; Patterns: TArray<TCodeEditorSymbolPattern>;
begin
  Name := LowerCase(Language).Replace('#', 'sharp').Replace('+', 'p');
  if (Name = 'pascal') then Name := 'delphi'; if (Name = 'cs') then Name := 'csharp';
  if (Name = 'visualbasic') or (Name = 'basic') then Name := 'vb';
  if (Name = 'c') or (Name = 'cxx') or (Name = 'cplusplus') then Name := 'cpp';
  if Name = 'ps1' then Name := 'powershell'; if Name = 'js' then Name := 'javascript'; if Name = 'ts' then Name := 'typescript';
  if Name = 'scss' then Name := 'css';
  L := TList<TCodeEditorSymbolPattern>.Create;
  try
    FLock.Acquire; try Patterns := FPatterns.ToArray; finally FLock.Release; end;
    for I := 0 to High(Patterns) do
    begin
      P := Patterns[I];
      if P.Enabled and ((P.LanguageName = Name) or (P.LanguageName = 'common')) then
      begin P.Expression := TRegEx.Create(P.RegexPattern, P.Options); L.Add(P); end;
    end;
    for I := 1 to L.Count - 1 do
    begin P := L[I]; J := I - 1; while (J >= 0) and (L[J].Priority < P.Priority) do begin L[J + 1] := L[J]; Dec(J); end; L[J + 1] := P; end;
    Result := L.ToArray;
  finally L.Free; end;
end;

constructor TCodeEditorSymbolIndex.Create;
begin inherited Create; FItems := TList<TCodeEditorSymbolInfo>.Create; end;
destructor TCodeEditorSymbolIndex.Destroy;
begin FItems.Free; inherited; end;
procedure TCodeEditorSymbolIndex.Clear;
begin FItems.Clear; end;
procedure TCodeEditorSymbolIndex.SetSymbols(const Symbols: TArray<TCodeEditorSymbolInfo>);
begin FItems.Clear; FItems.AddRange(Symbols); end;
function TCodeEditorSymbolIndex.Find(const Name: string; out Symbol: TCodeEditorSymbolInfo): Boolean;
var S: TCodeEditorSymbolInfo;
begin Result := False; for S in FItems do if SameText(S.Name, Name) then begin Symbol := S; Exit(True); end; end;
function TCodeEditorSymbolIndex.GetContaining(const Position: TCodeDocumentPosition; out Symbol: TCodeEditorSymbolInfo): Boolean;
var S: TCodeEditorSymbolInfo; Best, Span: Integer;
begin Result := False; Best := MaxInt; for S in FItems do if S.BodyRange.Contains(Position) then begin Span := S.BodyRange.Finish.LineIndex - S.BodyRange.Start.LineIndex; if Span < Best then begin Best := Span; Symbol := S; Result := True; end; end; end;

constructor TCodeEditorAnalyzer.Create;
begin inherited; FStack := TList<TCodeBracketPair>.Create; FPairs := TList<TCodeBracketPair>.Create; FFolds := TList<TCodeFoldRegion>.Create; end;
destructor TCodeEditorAnalyzer.Destroy;
begin Cancel; FStack.Free; FPairs.Free; FFolds.Free; inherited; end;
procedure TCodeEditorAnalyzer.Cancel;
begin FSource := nil; FHighlighter := nil; FStack.Clear; FPairs.Clear; FFolds.Clear; FLine := 0; end;
procedure TCodeEditorAnalyzer.Start(const Source: ICodeVirtualTextSource; const Highlighter: ICodeSyntaxHighlighter);
begin Cancel; FSource := Source; FHighlighter := Highlighter; FState := Default(TCodeHighlightState); if Source <> nil then FVersion := Source.Version; end;
function TCodeEditorAnalyzer.Complete: Boolean;
begin Result := (FSource <> nil) and (FLine >= FSource.LineCount); end;
function TCodeEditorAnalyzer.Advance(const MaxLines, MaxMilliseconds: Integer): Boolean;
var Started: UInt64; Last, J, I, Header, K: Integer; Text: string; Span: TCodeHighlightSpan;
  ResultLine: TCodeHighlightResult; Pair: TCodeBracketPair; Fold: TCodeFoldRegion; Close: Char;
begin
  Result := False; if FSource = nil then Exit;
  Started := GetTickCount64; Last := Min(FSource.LineCount, FLine + MaxLines);
  while FLine < Last do
  begin
    Text := FSource.GetLineText(FLine);
    if FHighlighter = nil then
    begin
      Inc(FLine); Result := True;
      if GetTickCount64 - Started >= UInt64(Max(1, MaxMilliseconds)) then Break;
      Continue;
    end;
    ResultLine := FHighlighter.HighlightLine(FSource, FLine, FState); FState := ResultLine.State;
    for Span in ResultLine.Spans do
      if Span.Kind in [chtParenthesis, chtBracket, chtBrace] then
        for J := Span.Start to Span.Start + Span.Length - 1 do
        begin
          Close := Text[J + 1];
          if CharInSet(Close, ['(', '[', '{']) then
          begin
            Pair := Default(TCodeBracketPair); Pair.OpenChar := Close;
            case Close of '(': Pair.CloseChar := ')'; '[': Pair.CloseChar := ']'; '{': Pair.CloseChar := '}'; end;
            Pair.OpenPosition := TCodeDocumentPosition.Create(FLine, J); Pair.Depth := FStack.Count + 1; Pair.ColorIndex := (Pair.Depth - 1) mod 4; FStack.Add(Pair);
          end
          else
          begin
            I := FStack.Count - 1;
            while (I >= 0) and (FStack[I].CloseChar <> Close) do Dec(I);
            if I < 0 then Continue;
            Pair := FStack[I]; FStack.DeleteRange(I, FStack.Count - I);
            Pair.ClosePosition := TCodeDocumentPosition.Create(FLine, J); FPairs.Add(Pair);
            if (Pair.OpenChar = '{') and (FLine > Pair.OpenPosition.LineIndex) then
            begin
              Header := Pair.OpenPosition.LineIndex;
              if Trim(FSource.GetLineText(Header)) = '{' then
                while Header > 0 do begin Dec(Header); if Trim(FSource.GetLineText(Header)) <> '' then Break; end;
              Fold := Default(TCodeFoldRegion);
              Fold.Range := TCodeDocumentRange.Create(TCodeDocumentPosition.Create(Header, 0), TCodeDocumentPosition.Create(FLine, J + 1));
              Fold.Text := '...'; Fold.PreviewText := '';
              for K := Header to Min(FLine, Header + 30) do begin if K > Header then Fold.PreviewText := Fold.PreviewText + sLineBreak; Fold.PreviewText := Fold.PreviewText + FSource.GetLineText(K); end;
              if FLine > Header + 30 then Fold.PreviewText := Fold.PreviewText + sLineBreak + '...'; FFolds.Add(Fold);
            end;
          end;
        end;
    Inc(FLine); Result := True;
    if GetTickCount64 - Started >= UInt64(Max(1, MaxMilliseconds)) then Break;
  end;
end;

constructor TLocalCodeSymbolProvider.Create(const Registry: TCodeEditorSymbolPatternRegistry);
begin inherited Create; FRegistry := Registry; end;
function TLocalCodeSymbolProvider.ResolveBody(const Source: ICodeVirtualTextSource; const Line: Integer;
  const Mode: TCodeSymbolBodyMode; const Name: string): TCodeDocumentRange;
var I, J, Depth, BaseIndent: Integer; Text, Trimmed: string; Started: Boolean; Quote: Char;
begin
  Result := TCodeDocumentRange.Create(TCodeDocumentPosition.Create(Line, 0), TCodeDocumentPosition.Create(Line, Source.GetLineLength(Line)));
  if Mode = csbDeclarationLine then Exit;
  Depth := 0; Started := False; BaseIndent := CodeLeadingColumns(Source.GetLineText(Line), 4);
  for I := Line to Source.LineCount - 1 do
  begin
    Text := Source.GetLineText(I); Trimmed := LowerCase(Trim(Text));
    if Mode = csbIndentationBlock then
    begin
      if (I > Line) and (Trimmed <> '') and (CodeLeadingColumns(Text, 4) <= BaseIndent) then begin Result.Finish := TCodeDocumentPosition.Create(I - 1, Source.GetLineLength(I - 1)); Exit; end;
    end
    else if Mode in [csbPascalBlock, csbSqlBlock] then
    begin
      if Trimmed.StartsWith('begin') then begin Inc(Depth); Started := True; end;
      if (Trimmed.StartsWith('end') or Trimmed.StartsWith('endfunc') or Trimmed.StartsWith('endregion')) and ((Depth <= 1) or not Started) and (I > Line) then begin Result.Finish := TCodeDocumentPosition.Create(I, Length(Text)); Exit; end;
      if Trimmed.StartsWith('end') then Dec(Depth);
    end
    else if Mode = csbXmlElementBlock then
    begin if (I >= Line) and (Pos('</' + LowerCase(Name), Trimmed) > 0) then begin Result.Finish := TCodeDocumentPosition.Create(I, Length(Text)); Exit; end; end
    else
    begin
      Quote := #0; J := 1;
      while J <= Length(Text) do
      begin
        if Quote <> #0 then
        begin if Text[J] = '\' then Inc(J) else if Text[J] = Quote then Quote := #0; end
        else if CharInSet(Text[J], ['"', #39]) then Quote := Text[J]
        else if (Text[J] = '/') and (J < Length(Text)) and (Text[J + 1] = '/') then Break
        else if Text[J] = '{' then begin Inc(Depth); Started := True; end
        else if (Text[J] = '}') and Started then
        begin Dec(Depth); if Depth <= 0 then begin Result.Finish := TCodeDocumentPosition.Create(I, Length(Text)); Exit; end; end;
        Inc(J);
      end;
    end;
  end;
  Result.Finish := TCodeDocumentPosition.Create(Source.LineCount - 1, Source.GetLineLength(Source.LineCount - 1));
end;
function TLocalCodeSymbolProvider.GetSymbols(const Source: ICodeVirtualTextSource; const LanguageName: string): TArray<TCodeEditorSymbolInfo>;
var Patterns: TArray<TCodeEditorSymbolPattern>; P: TCodeEditorSymbolPattern; I, LastDot, J: Integer;
  Text, Name: string; Match: TMatch; Group: TGroup; Symbol: TCodeEditorSymbolInfo; Items: TList<TCodeEditorSymbolInfo>;
begin
  Items := TList<TCodeEditorSymbolInfo>.Create;
  try
    Patterns := FRegistry.GetPatterns(LanguageName);
    for I := 0 to Source.LineCount - 1 do
    begin
      Text := Source.GetLineText(I); if Trim(Text) = '' then Continue;
      for P in Patterns do
      begin
        Match := P.Expression.Match(Text); if not Match.Success then Continue;
        Group := Match.Groups[P.NameGroup]; if not Group.Success then Continue;
        Name := Group.Value; LastDot := 0;
        if P.TrimQualifiedName then for J := 1 to Length(Name) do if CharInSet(Name[J], ['.', ':']) then LastDot := J;
        Symbol := Default(TCodeEditorSymbolInfo); Symbol.Name := Copy(Name, LastDot + 1, MaxInt); Symbol.Kind := P.Kind;
        Symbol.NameRange := TCodeDocumentRange.Create(TCodeDocumentPosition.Create(I, Group.Index + LastDot), TCodeDocumentPosition.Create(I, Group.Index + Group.Length));
        Symbol.DeclarationRange := TCodeDocumentRange.Create(TCodeDocumentPosition.Create(I, 0), TCodeDocumentPosition.Create(I, Length(Text)));
        Symbol.BodyRange := ResolveBody(Source, I, P.BodyMode, Name); Symbol.SignatureText := Trim(Text); Symbol.FullText := Text; Symbol.LanguageName := LanguageName;
        Items.Add(Symbol); Break;
      end;
    end;
    Result := Items.ToArray;
  finally Items.Free; end;
end;

constructor TKeywordCompletionProvider.Create(const Language: ICodeLanguageDefinition);
begin inherited Create; FLanguage := Language; end;
function TKeywordCompletionProvider.GetCompletions(const Source: ICodeVirtualTextSource; const Position: TCodeDocumentPosition;
  const Trigger: TCodeEditorCompletionTrigger): TArray<TCodeCompletionItem>;
var Words: TArray<string>; I: Integer;
begin
  Result := nil; if FLanguage = nil then Exit; Words := FLanguage.GetKeywords; SetLength(Result, Length(Words));
  for I := 0 to High(Words) do begin Result[I].DisplayText := Words[I]; Result[I].InsertText := Words[I]; Result[I].FilterText := Words[I]; Result[I].SortText := Words[I]; Result[I].Kind := cciKeyword; end;
end;

class function TCodeSearchEngine.Search(const Source: ICodeVirtualTextSource; const Options: TCodeSearchOptions): TArray<TCodeSearchMatch>;
var Items: TList<TCodeSearchMatch>; Hit: TCodeSearchMatch; Expression: TRegEx; RegexOptions: TRegExOptions;
  Matches: TMatchCollection; Match: TMatch; Pattern, Text, CompareText: string;
  Skip: TDictionary<Char, Integer>; I, J, P, Step, N: Integer;
  function WordChar(const C: Char): Boolean;
  begin Result := C.IsLetterOrDigit or (C = '_'); end;
  function Whole(const Index, Count: Integer): Boolean;
  begin Result := not Options.WholeWord or (((Index = 0) or not WordChar(Text[Index])) and ((Index + Count >= Length(Text)) or not WordChar(Text[Index + Count + 1]))); end;
  procedure Add(const Index, Count: Integer);
  begin Hit.Range := TCodeDocumentRange.Create(TCodeDocumentPosition.Create(I, Index), TCodeDocumentPosition.Create(I, Index + Count)); Hit.Text := Copy(Text, Index + 1, Count); Items.Add(Hit); end;
begin
  Result := nil; if (Source = nil) or (Options.Pattern = '') then Exit;
  Items := TList<TCodeSearchMatch>.Create; Skip := TDictionary<Char, Integer>.Create;
  try
    Pattern := Options.Pattern; RegexOptions := []; if not Options.MatchCase then Include(RegexOptions, roIgnoreCase);
    if Options.UseRegex then Expression := TRegEx.Create(Pattern, RegexOptions)
    else
    begin
      if not Options.MatchCase then for J := 1 to Length(Pattern) do Pattern[J] := Pattern[J].ToUpper;
      for J := 1 to Length(Pattern) - 1 do Skip.AddOrSetValue(Pattern[J], Length(Pattern) - J);
    end;
    N := Length(Pattern);
    for I := 0 to Source.LineCount - 1 do
    begin
      Text := Source.GetLineText(I);
      if Options.UseRegex then
      begin
        Matches := Expression.Matches(Text);
        for Match in Matches do
          if (Match.Length > 0) and Whole(Match.Index, Match.Length) then
          begin Add(Match.Index, Match.Length); if (Options.MaxResults > 0) and (Items.Count >= Options.MaxResults) then Exit(Items.ToArray); end;
      end
      else
      begin
        CompareText := Text;
        if not Options.MatchCase then for J := 1 to Length(CompareText) do CompareText[J] := CompareText[J].ToUpper;
        P := 1;
        while P + N - 1 <= Length(Text) do
        begin
          J := N; while (J > 0) and (CompareText[P + J - 1] = Pattern[J]) do Dec(J);
          if (J = 0) and Whole(P - 1, N) then
          begin Add(P - 1, N); if (Options.MaxResults > 0) and (Items.Count >= Options.MaxResults) then Exit(Items.ToArray); end;
          if not Skip.TryGetValue(CompareText[P + N - 1], Step) then Step := N; Inc(P, Max(1, Step));
        end;
      end;
    end;
    Result := Items.ToArray;
  finally Skip.Free; Items.Free; end;
end;

end.

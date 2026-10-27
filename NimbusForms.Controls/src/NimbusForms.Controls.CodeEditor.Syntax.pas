{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.CodeEditor.Syntax;

interface

uses System.Classes, System.SysUtils, System.Generics.Collections,
  NimbusForms.Controls.CodeEditor.Types, NimbusForms.Controls.CodeEditor.Document;

type
  ICodeLanguageDefinition = interface
    ['{1D80EB39-5795-457C-AC6A-15C6CD0BF7E7}']
    function GetName: string;
    function GetDisplayName: string;
    function GetExtensions: TArray<string>;
    function GetLineComment: string;
    function GetBlockStart: string;
    function GetBlockEnd: string;
    function GetDocumentationComment: string;
    function GetPreprocessorPrefix: string;
    function GetStringDelimiters: string;
    function GetCharacterDelimiters: string;
    function GetCaseSensitive: Boolean;
    function Classify(const Word: string): TCodeEditorHighlightTokenKind;
    function DeclarationKind(const Word: string): TCodeEditorHighlightTokenKind;
    function GetKeywords: TArray<string>;
    property Name: string read GetName;
    property DisplayName: string read GetDisplayName;
    property Extensions: TArray<string> read GetExtensions;
    property LineComment: string read GetLineComment;
    property BlockCommentStart: string read GetBlockStart;
    property BlockCommentEnd: string read GetBlockEnd;
    property DocumentationLineComment: string read GetDocumentationComment;
    property PreprocessorPrefix: string read GetPreprocessorPrefix;
    property StringDelimiters: string read GetStringDelimiters;
    property CharacterDelimiters: string read GetCharacterDelimiters;
    property CaseSensitive: Boolean read GetCaseSensitive;
  end;
  TCodeLanguageDefinition = class(TInterfacedObject, ICodeLanguageDefinition)
  private
    FKeywords, FDeclarations: TDictionary<string, TCodeEditorHighlightTokenKind>;
    function Normalize(const Word: string): string;
  public
    Name, DisplayName, LineComment, BlockCommentStart, BlockCommentEnd,
      DocumentationLineComment, PreprocessorPrefix, StringDelimiters, CharacterDelimiters: string;
    FileExtensions: TArray<string>;
    CaseSensitive: Boolean;
    constructor Create;
    destructor Destroy; override;
    procedure AddKeywords(const Kind: TCodeEditorHighlightTokenKind; const Words: TArray<string>);
    procedure AddDeclaration(const Word: string; const KeywordKind, NameKind: TCodeEditorHighlightTokenKind);
    function GetName: string;
    function GetDisplayName: string;
    function GetExtensions: TArray<string>;
    function GetLineComment: string;
    function GetBlockStart: string;
    function GetBlockEnd: string;
    function GetDocumentationComment: string;
    function GetPreprocessorPrefix: string;
    function GetStringDelimiters: string;
    function GetCharacterDelimiters: string;
    function GetCaseSensitive: Boolean;
    function Classify(const Word: string): TCodeEditorHighlightTokenKind;
    function DeclarationKind(const Word: string): TCodeEditorHighlightTokenKind;
    function GetKeywords: TArray<string>;
  end;
  TCodeLanguageRegistry = class
  private
    FLanguages: TList<ICodeLanguageDefinition>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterLanguage(const Language: ICodeLanguageDefinition);
    function FindByName(const Name: string): ICodeLanguageDefinition;
    function FindByExtension(const Extension: string): ICodeLanguageDefinition;
    function RegisterFromFile(const Path: string): Boolean;
    function RegisterFromDirectory(const Path: string): Integer;
    property Languages: TList<ICodeLanguageDefinition> read FLanguages;
  end;
  TCodeHighlightResult = record
    Spans: TArray<TCodeHighlightSpan>;
    State: TCodeHighlightState;
  end;
  ICodeSyntaxHighlighter = interface
    ['{C3FD8E26-3830-420F-B46C-2B0ED3E9A6B7}']
    function HighlightLine(const Source: ICodeVirtualTextSource; const LineIndex: Integer;
      const State: TCodeHighlightState): TCodeHighlightResult;
  end;
  TLanguageBasedCodeSyntaxHighlighter = class(TInterfacedObject, ICodeSyntaxHighlighter)
  private
    FLanguage: ICodeLanguageDefinition;
  public
    constructor Create(const Language: ICodeLanguageDefinition);
    function HighlightLine(const Source: ICodeVirtualTextSource; const LineIndex: Integer;
      const State: TCodeHighlightState): TCodeHighlightResult;
  end;
  TCodeHighlightCache = class
  private
    FEntries: TList<TCodeHighlightResult>;
    FSource: ICodeVirtualTextSource;
    FHighlighter: ICodeSyntaxHighlighter;
    FVisibleOnly: Boolean;
    FCachedLines: TList<Integer>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Attach(const Source: ICodeVirtualTextSource; const Highlighter: ICodeSyntaxHighlighter);
    procedure InvalidateFromLine(const Line: Integer);
    procedure SetVisibleOnly(const Value: Boolean);
    function Advance(const Count: Integer): Boolean;
    function GetLine(const Line: Integer): TCodeHighlightResult;
    function ReadyCount: Integer;
  end;

implementation

uses System.Math, System.Character, System.IOUtils, NimbusForms.Controls.CodeEditor.Languages,
  NimbusForms.Controls.CodeEditor.Semantics, NimbusForms.Controls.CodeEditor.LanguageExtensions;

constructor TCodeLanguageDefinition.Create;
begin
  inherited; FKeywords := TDictionary<string, TCodeEditorHighlightTokenKind>.Create;
  FDeclarations := TDictionary<string, TCodeEditorHighlightTokenKind>.Create;
  StringDelimiters := '"'; CharacterDelimiters := #39;
end;
destructor TCodeLanguageDefinition.Destroy;
begin FKeywords.Free; FDeclarations.Free; inherited; end;
function TCodeLanguageDefinition.Normalize(const Word: string): string;
begin if CaseSensitive then Result := Word else Result := LowerCase(Word); end;
procedure TCodeLanguageDefinition.AddKeywords(const Kind: TCodeEditorHighlightTokenKind; const Words: TArray<string>);
var Word: string;
begin for Word in Words do FKeywords.AddOrSetValue(Normalize(Word), Kind); end;
procedure TCodeLanguageDefinition.AddDeclaration(const Word: string; const KeywordKind, NameKind: TCodeEditorHighlightTokenKind);
begin FKeywords.AddOrSetValue(Normalize(Word), KeywordKind); FDeclarations.AddOrSetValue(Normalize(Word), NameKind); end;
function TCodeLanguageDefinition.Classify(const Word: string): TCodeEditorHighlightTokenKind;
begin if not FKeywords.TryGetValue(Normalize(Word), Result) then Result := chtIdentifier; end;
function TCodeLanguageDefinition.DeclarationKind(const Word: string): TCodeEditorHighlightTokenKind;
begin if not FDeclarations.TryGetValue(Normalize(Word), Result) then Result := chtIdentifier; end;
function TCodeLanguageDefinition.GetKeywords: TArray<string>;
begin Result := FKeywords.Keys.ToArray; end;
function TCodeLanguageDefinition.GetName: string;
begin Result := Name; end;
function TCodeLanguageDefinition.GetDisplayName: string;
begin Result := DisplayName; end;
function TCodeLanguageDefinition.GetExtensions: TArray<string>;
begin Result := FileExtensions; end;
function TCodeLanguageDefinition.GetLineComment: string;
begin Result := LineComment; end;
function TCodeLanguageDefinition.GetBlockStart: string;
begin Result := BlockCommentStart; end;
function TCodeLanguageDefinition.GetBlockEnd: string;
begin Result := BlockCommentEnd; end;
function TCodeLanguageDefinition.GetDocumentationComment: string;
begin Result := DocumentationLineComment; end;
function TCodeLanguageDefinition.GetPreprocessorPrefix: string;
begin Result := PreprocessorPrefix; end;
function TCodeLanguageDefinition.GetStringDelimiters: string;
begin Result := StringDelimiters; end;
function TCodeLanguageDefinition.GetCharacterDelimiters: string;
begin Result := CharacterDelimiters; end;
function TCodeLanguageDefinition.GetCaseSensitive: Boolean;
begin Result := CaseSensitive; end;

constructor TCodeLanguageRegistry.Create;
begin inherited; FLanguages := TList<ICodeLanguageDefinition>.Create; RegisterCodeEditorLanguages(Self); end;
destructor TCodeLanguageRegistry.Destroy;
begin FLanguages.Free; inherited; end;
procedure TCodeLanguageRegistry.RegisterLanguage(const Language: ICodeLanguageDefinition);
var I: Integer;
begin
  if Language = nil then Exit;
  for I := 0 to FLanguages.Count - 1 do if SameText(FLanguages[I].Name, Language.Name) then begin FLanguages[I] := Language; Exit; end;
  FLanguages.Add(Language);
end;
function TCodeLanguageRegistry.FindByName(const Name: string): ICodeLanguageDefinition;
var Language: ICodeLanguageDefinition;
begin
  Result := nil;
  for Language in FLanguages do if SameText(Language.Name, Name) or SameText(Language.DisplayName, Name) then Exit(Language);
end;
function TCodeLanguageRegistry.FindByExtension(const Extension: string): ICodeLanguageDefinition;
var Ext, Candidate: string; Language: ICodeLanguageDefinition;
begin
  Result := nil; Ext := Extension; if Ext = '' then Exit; if Ext[1] <> '.' then Ext := '.' + Ext;
  for Language in FLanguages do for Candidate in Language.Extensions do if SameText(Ext, Candidate) then Exit(Language);
end;

function DecodeAddonValue(const Value: string): string;
begin
  Result := Trim(Value);
  if (Length(Result) >= 2) and ((Result[1] = '"') or (Result[1] = #39)) and (Result[Length(Result)] = Result[1]) then Result := Copy(Result, 2, Length(Result) - 2);
  Result := Result.Replace('\t', #9).Replace('\r', #13).Replace('\n', #10).Replace('\"', '"').Replace('\' + #39, #39);
end;

function TCodeLanguageRegistry.RegisterFromFile(const Path: string): Boolean;
const Keys: array[0..8] of string = ('keywords', 'controlKeywords', 'accessKeywords', 'modifierKeywords', 'typeKeywords', 'accessorKeywords', 'constants', 'booleans', 'nulls');
  Kinds: array[0..8] of TCodeEditorHighlightTokenKind = (chtKeyword, chtControlKeyword, chtAccessKeyword, chtModifierKeyword, chtTypeKeyword, chtAccessorKeyword, chtConstantName, chtBoolean, chtNull);
  DeclarationKeys: array[0..7] of string = ('classKeywords', 'structKeywords', 'interfaceKeywords', 'enumKeywords', 'functionKeywords', 'procedureKeywords', 'methodKeywords', 'namespaceKeywords');
  DeclarationKinds: array[0..7] of TCodeEditorHighlightTokenKind = (chtClassName, chtStructName, chtInterfaceName, chtEnumName, chtFunctionName, chtProcedureName, chtMethodName, chtNamespaceName);
var Values: TStringList; Text, LineText, Key, Value, Word: string; Lines: TArray<string>; P, I: Integer;
  Definition: TCodeLanguageDefinition; Language: ICodeLanguageDefinition;
begin
  Values := TStringList.Create;
  try
    Values.CaseSensitive := False; Values.NameValueSeparator := '=';
    Lines := TFile.ReadAllLines(Path);
    for LineText in Lines do
    begin
      Text := Trim(LineText); if Text.StartsWith('#') or Text.StartsWith('//') then Continue;
      P := Pos('=', Text); if P = 0 then Continue;
      Key := Trim(Copy(Text, 1, P - 1)); Value := Trim(Copy(Text, P + 1, MaxInt)); Values.Values[Key] := Value;
    end;
    Definition := TCodeLanguageDefinition.Create; Language := Definition;
    Definition.Name := DecodeAddonValue(Values.Values['name']); if Definition.Name = '' then Definition.Name := TPath.GetFileNameWithoutExtension(Path);
    Definition.DisplayName := DecodeAddonValue(Values.Values['displayName']); if Definition.DisplayName = '' then Definition.DisplayName := Definition.Name;
    Definition.FileExtensions := Values.Values['extensions'].Split([',', ';'], TStringSplitOptions.ExcludeEmpty);
    for I := 0 to High(Definition.FileExtensions) do Definition.FileExtensions[I] := DecodeAddonValue(Definition.FileExtensions[I]);
    Definition.CaseSensitive := SameText(Values.Values['caseSensitive'], 'true') or (Values.Values['caseSensitive'] = '1') or SameText(Values.Values['caseSensitive'], 'yes');
    Definition.LineComment := DecodeAddonValue(Values.Values['lineComment']);
    Definition.BlockCommentStart := DecodeAddonValue(Values.Values['blockCommentStart']);
    Definition.BlockCommentEnd := DecodeAddonValue(Values.Values['blockCommentEnd']);
    Definition.DocumentationLineComment := DecodeAddonValue(Values.Values['documentationLineComment']);
    Definition.PreprocessorPrefix := DecodeAddonValue(Values.Values['preprocessorPrefix']);
    if Values.IndexOfName('stringDelimiters') >= 0 then Definition.StringDelimiters := DecodeAddonValue(Values.Values['stringDelimiters']).Replace(',', '').Replace(';', '');
    if Values.IndexOfName('characterDelimiters') >= 0 then Definition.CharacterDelimiters := DecodeAddonValue(Values.Values['characterDelimiters']).Replace(',', '').Replace(';', '');
    for I := 0 to High(Keys) do
      for Word in Values.Values[Keys[I]].Split([',', ';'], TStringSplitOptions.ExcludeEmpty) do Definition.AddKeywords(Kinds[I], TArray<string>.Create(DecodeAddonValue(Word)));
    for I := 0 to High(DeclarationKeys) do
      for Word in Values.Values[DeclarationKeys[I]].Split([',', ';'], TStringSplitOptions.ExcludeEmpty) do Definition.AddDeclaration(DecodeAddonValue(Word), chtDeclarationKeyword, DeclarationKinds[I]);
    ConfigureCodeEditorLanguage(Definition); RegisterLanguage(Language); Result := True;
  finally Values.Free; end;
end;
function TCodeLanguageRegistry.RegisterFromDirectory(const Path: string): Integer;
var FileName: string;
  begin Result := 0; if not TDirectory.Exists(Path) then Exit; for FileName in TDirectory.GetFiles(Path, '*.nclang') do if RegisterFromFile(FileName) then Inc(Result); end;

constructor TLanguageBasedCodeSyntaxHighlighter.Create(const Language: ICodeLanguageDefinition);
begin inherited Create; FLanguage := Language; end;

function TLanguageBasedCodeSyntaxHighlighter.HighlightLine(const Source: ICodeVirtualTextSource;
  const LineIndex: Integer; const State: TCodeHighlightState): TCodeHighlightResult;
var Text, Word, PreviousWord, Ending: string; I, J, Start, N: Integer;
  Kind, PreviousKind: TCodeEditorHighlightTokenKind; Quote, NextChar, PreviousChar: Char; Verbatim, Interpolated, Closed: Boolean;
  Spans: TList<TCodeHighlightSpan>; Span: TCodeHighlightSpan;
  function At(const Index: Integer; const Value: string): Boolean;
  begin Result := (Value <> '') and (Copy(Text, Index, Length(Value)) = Value); end;
  procedure Add(const First, Count: Integer; const TokenKind: TCodeEditorHighlightTokenKind);
  var Previous: TCodeHighlightSpan;
  begin
    if Count <= 0 then Exit;
    if (TokenKind = chtText) and (Spans.Count > 0) then
    begin
      Previous := Spans[Spans.Count - 1];
      if (Previous.Kind = chtText) and (Previous.Start + Previous.Length = First - 1) then
      begin Inc(Previous.Length, Count); Spans[Spans.Count - 1] := Previous; Exit; end;
    end;
    Span.Start := First - 1; Span.Length := Count; Span.Kind := TokenKind; Spans.Add(Span);
  end;
begin
  Result := Default(TCodeHighlightResult); Result.State := State;
  if (Source = nil) or (FLanguage = nil) then Exit;
  Text := Source.GetLineText(LineIndex); N := Length(Text); I := 1; PreviousKind := chtText; PreviousWord := '';
  if TryCodeSpecialHighlight(FLanguage.Name, Text, State, Result.Spans, Result.State) then Exit;
  Spans := TList<TCodeHighlightSpan>.Create;
  try
    while I <= N do
    begin
      Start := I;
      Interpolated := False;
      if Result.State.RawStringEnd <> '' then
      begin
        J := Pos(Result.State.RawStringEnd, Text, I);
        if J = 0 then begin Add(I, N - I + 1, chtString); Break; end;
        I := J + Length(Result.State.RawStringEnd); Add(Start, I - Start, chtString); Result.State.RawStringEnd := ''; Continue;
      end;
      if Result.State.BlockEnd <> '' then
      begin
        if SameText(FLanguage.Name, 'rust') then
        begin
          Kind := chtComment; if Result.State.DocumentationBlock then Kind := chtDocumentationComment;
          while I <= N do
            if At(I, '/*') then begin Inc(Result.State.BlockDepth); Inc(I, 2); end
            else if At(I, '*/') then
            begin Dec(Result.State.BlockDepth); Inc(I, 2); if Result.State.BlockDepth = 0 then begin Result.State.BlockEnd := ''; Result.State.DocumentationBlock := False; Break; end; end
            else Inc(I);
          Add(Start, I - Start, Kind); if Result.State.BlockEnd <> '' then Break; Continue;
        end;
        Ending := Result.State.BlockEnd; J := Pos(Ending, Text, I);
        Kind := chtComment; if Result.State.DocumentationBlock then Kind := chtDocumentationComment;
        if J = 0 then begin Add(I, N - I + 1, Kind); Break; end;
        I := J + Length(Ending); Add(Start, I - Start, Kind); Result.State.BlockEnd := ''; Result.State.DocumentationBlock := False; Continue;
      end;
      if Result.State.StringQuote <> #0 then
      begin Quote := Result.State.StringQuote; Verbatim := Result.State.Verbatim; end
      else
      begin
        if Text[I].IsWhiteSpace then
        begin while (I <= N) and Text[I].IsWhiteSpace do Inc(I); Add(Start, I - Start, chtWhitespace); Continue; end;
        if SameText(FLanguage.Name, 'rust') and (Text[I] = 'r') then
        begin
          J := I + 1; while (J <= N) and (Text[J] = '#') do Inc(J);
          if (J <= N) and (Text[J] = '"') then
          begin
            Ending := '"' + Copy(Text, I + 1, J - I - 1); J := Pos(Ending, Text, J + 1);
            if J = 0 then begin Result.State.RawStringEnd := Ending; Add(I, N - I + 1, chtString); Break; end;
            J := J + Length(Ending); Add(I, J - I, chtString); I := J; Continue;
          end;
        end;
        if SameText(FLanguage.Name, 'cpp') and At(I, '#include') and ((I + 8 > N) or not CodeIsWord(Text[I + 8])) then
        begin Add(I, 8, chtImportKeyword); Add(I + 8, N - I - 7, chtImportName); Break; end;
        if SameText(FLanguage.Name, 'batch') and CharInSet(Text[I], ['%', '!']) then
        begin
          J := Pos(Text[I], Text, I + 1);
          if J > 0 then begin Inc(J); Add(I, J - I, chtVariableName); I := J; Continue; end;
          if Text[I] = '%' then
          begin J := I + 1; while (J <= N) and (CodeIsWord(Text[J]) or CharInSet(Text[J], ['~', ':'])) do Inc(J); Add(I, J - I, chtVariableName); I := J; Continue; end;
        end;
        if SameText(FLanguage.Name, 'batch') and (Text[I] = ':') and (Trim(Copy(Text, 1, I - 1)) = '') then
        begin Add(I, N - I + 1, chtLabelName); Break; end;
        if SameText(FLanguage.Name, 'delphi') and (At(I, '{$') or At(I, '(*$')) then
        begin
          Ending := '}'; if At(I, '(*$') then Ending := '*)';
          J := Pos(Ending, Text, I + 2); if J = 0 then J := N + 1 else Inc(J, Length(Ending));
          Add(I, J - I, chtPreprocessor); I := J; Continue;
        end;
        if At(I, FLanguage.PreprocessorPrefix) and (Trim(Copy(Text, 1, I - 1)) = '') then begin Add(I, N - I + 1, chtPreprocessor); Break; end;
        if At(I, FLanguage.DocumentationLineComment) then
        begin
          if (FLanguage.BlockCommentStart <> '') and (FLanguage.BlockCommentEnd <> '') and FLanguage.DocumentationLineComment.StartsWith(FLanguage.BlockCommentStart) then
          begin Result.State.BlockEnd := FLanguage.BlockCommentEnd; Result.State.DocumentationBlock := True; Continue; end;
          Add(I, N - I + 1, chtDocumentationComment); Break;
        end;
        if At(I, FLanguage.LineComment) then begin Add(I, N - I + 1, chtComment); Break; end;
        if At(I, FLanguage.BlockCommentStart) then
        begin Result.State.BlockEnd := FLanguage.BlockCommentEnd; if Result.State.BlockEnd = '' then begin Add(Start, N - Start + 1, chtComment); Break; end; Continue; end;
        Quote := #0; Verbatim := False; Interpolated := False;
        if CharInSet(Text[I], ['@', '$']) and (I < N) then
        begin
          J := I; while (J <= N) and CharInSet(Text[J], ['@', '$']) do Inc(J);
          if (J <= N) and (Pos(Text[J], FLanguage.StringDelimiters) > 0) then
          begin Verbatim := Pos('@', Copy(Text, I, J - I)) > 0; Interpolated := Pos('$', Copy(Text, I, J - I)) > 0; I := J; end;
        end;
        if (Pos(Text[I], FLanguage.StringDelimiters) > 0) or (Pos(Text[I], FLanguage.CharacterDelimiters) > 0) then Quote := Text[I];
        if SameText(FLanguage.Name, 'rust') and (Quote = #39) and
          ((I + 1 > N) or (Text[I + 1] <> '\')) and
          ((I + 2 > N) or (Text[I + 2] <> #39)) and ((I + 3 > N) or (Text[I + 3] <> #39)) then Quote := #0;
        if SameText(FLanguage.Name, 'javascript') and (Quote = '`') then Verbatim := True;
        if Quote <> #0 then Inc(I);
      end;
      if Quote <> #0 then
      begin
        Kind := chtString;
        if Pos(Quote, FLanguage.CharacterDelimiters) > 0 then Kind := chtCharacter;
        if Verbatim then Kind := chtVerbatimString;
        if Interpolated then Kind := chtInterpolatedString;
        Result.State.StringQuote := #0; Closed := False;
        while I <= N do
        begin
          if (Text[I] = '\') and (not Verbatim or SameText(FLanguage.Name, 'javascript')) and not SameText(FLanguage.Name, 'delphi') then begin Inc(I, 2); Continue; end;
          if Text[I] = Quote then
          begin
            Inc(I);
            if (I <= N) and (Text[I] = Quote) and (SameText(FLanguage.Name, 'delphi') or SameText(FLanguage.Name, 'vb') or
              (Verbatim and not SameText(FLanguage.Name, 'javascript'))) then begin Inc(I); Continue; end;
            Closed := True; Break;
          end;
          Inc(I);
        end;
        if not Closed and Verbatim then begin Result.State.StringQuote := Quote; Result.State.Verbatim := True; end;
        I := Min(I, N + 1); Add(Start, I - Start, Kind); PreviousWord := ''; PreviousKind := Kind; Continue;
      end;
      if Text[I].IsDigit then
      begin
        if At(I, '0x') or At(I, '0X') then
        begin Inc(I, 2); while (I <= N) and CharInSet(Text[I], ['0'..'9', 'a'..'f', 'A'..'F', '_']) do Inc(I); end
        else if At(I, '0b') or At(I, '0B') then
        begin Inc(I, 2); while (I <= N) and CharInSet(Text[I], ['0', '1', '_']) do Inc(I); end
        else
        begin
          Inc(I); while (I <= N) and (Text[I].IsDigit or (Text[I] = '_')) do Inc(I);
          if (I < N) and (Text[I] = '.') and Text[I + 1].IsDigit then
          begin Inc(I); while (I <= N) and (Text[I].IsDigit or (Text[I] = '_')) do Inc(I); end;
          if (I < N) and CharInSet(Text[I], ['e', 'E']) then
          begin
            J := I + 1; if (J <= N) and CharInSet(Text[J], ['+', '-']) then Inc(J);
            if (J <= N) and Text[J].IsDigit then begin I := J + 1; while (I <= N) and (Text[I].IsDigit or (Text[I] = '_')) do Inc(I); end;
          end;
        end;
        while (I <= N) and CharInSet(Text[I], ['u', 'U', 'l', 'L', 'f', 'F', 'd', 'D', 'm', 'M', 'n', 'N']) do Inc(I);
        if SameText(FLanguage.Name, 'rust') and (I <= N) and CharInSet(Text[I], ['i', 'u']) then
        begin Inc(I); while (I <= N) and Text[I].IsDigit do Inc(I); end;
        Add(Start, I - Start, chtNumber); PreviousWord := ''; PreviousKind := chtNumber; Continue;
      end;
      if CodeIsWord(Text[I]) then
      begin
        Inc(I); while (I <= N) and CodeIsWord(Text[I]) do Inc(I); Word := Copy(Text, Start, I - Start);
        Kind := FLanguage.Classify(Word);
        if Kind = chtIdentifier then
        begin
          if PreviousKind = chtDeclarationKeyword then Kind := FLanguage.DeclarationKind(PreviousWord)
          else
          begin
            J := I; while (J <= N) and Text[J].IsWhiteSpace do Inc(J);
            NextChar := #0; if J <= N then NextChar := Text[J];
            J := Start - 1; while (J > 0) and Text[J].IsWhiteSpace do Dec(J);
            PreviousChar := #0; if J > 0 then PreviousChar := Text[J];
            if NextChar = '(' then Kind := chtMethodName
            else if PreviousChar = '.' then Kind := chtPropertyName
            else if (Length(Word) > 1) and (Pos('_', Word) > 0) and (Word = UpperCase(Word)) and (Word <> LowerCase(Word)) then Kind := chtConstantName
            else if (Length(Word) > 1) and Word.StartsWith('_') then Kind := chtFieldName
            else if CharInSet(NextChar, [',', ')']) or CharInSet(PreviousChar, [',', '(']) then Kind := chtParameterName
            else if NextChar = '{' then Kind := chtPropertyName
            else if Word[1].IsUpper then Kind := chtTypeName;
          end;
        end;
        Add(Start, I - Start, Kind); PreviousWord := Word; PreviousKind := Kind; Continue;
      end;
      Kind := chtPunctuation;
      case Text[I] of
        '(', ')': Kind := chtParenthesis;
        '[', ']': Kind := chtBracket;
        '{', '}': Kind := chtBrace;
        ',', ';', '.': Kind := chtDelimiter;
        '+', '-', '*', '/', '%', '=', '!', '<', '>', '|', '&', '^', '~', '?', ':': Kind := chtOperator;
      end;
      if (Ord(Text[I]) = $200D) or (Ord(Text[I]) = $FE0E) or (Ord(Text[I]) = $FE0F) then Kind := chtText;
      Inc(I);
      if (Ord(Text[Start]) >= $D800) and (Ord(Text[Start]) <= $DBFF) and (I <= N) and
        (Ord(Text[I]) >= $DC00) and (Ord(Text[I]) <= $DFFF) then begin Inc(I); Kind := chtText; end;
      Add(Start, I - Start, Kind); PreviousKind := Kind; PreviousWord := '';
    end;
    Result.Spans := Spans.ToArray;
    ApplyCodeSemanticTokens(FLanguage, Text, Result);
  finally Spans.Free; end;
end;

constructor TCodeHighlightCache.Create;
begin inherited; FEntries := TList<TCodeHighlightResult>.Create; FCachedLines := TList<Integer>.Create; FVisibleOnly := True; end;
destructor TCodeHighlightCache.Destroy;
begin FEntries.Free; FCachedLines.Free; FSource := nil; FHighlighter := nil; inherited; end;
procedure TCodeHighlightCache.Attach(const Source: ICodeVirtualTextSource; const Highlighter: ICodeSyntaxHighlighter);
begin FSource := Source; FHighlighter := Highlighter; FEntries.Clear; FCachedLines.Clear; end;
procedure TCodeHighlightCache.InvalidateFromLine(const Line: Integer);
var First, I: Integer;
begin First := EnsureRange(Line, 0, FEntries.Count); FEntries.DeleteRange(First, FEntries.Count - First); for I := FCachedLines.Count - 1 downto 0 do if FCachedLines[I] >= First then FCachedLines.Delete(I); end;
procedure TCodeHighlightCache.SetVisibleOnly(const Value: Boolean);
begin if FVisibleOnly = Value then Exit; FVisibleOnly := Value; FEntries.Clear; FCachedLines.Clear; end;
function TCodeHighlightCache.Advance(const Count: Integer): Boolean;
var State: TCodeHighlightState; I, Last: Integer; Entry: TCodeHighlightResult;
begin
  Result := False; if (FSource = nil) or (FHighlighter = nil) then Exit;
  Last := Min(FSource.LineCount, FEntries.Count + Max(0, Count));
  for I := FEntries.Count to Last - 1 do
  begin
    State := Default(TCodeHighlightState); if FEntries.Count > 0 then State := FEntries.Last.State;
    Entry := FHighlighter.HighlightLine(FSource, I, State); if FVisibleOnly then Entry.Spans := nil;
    FEntries.Add(Entry); Result := True;
  end;
end;
function TCodeHighlightCache.GetLine(const Line: Integer): TCodeHighlightResult;
var State: TCodeHighlightState; Entry: TCodeHighlightResult; Old: Integer;
begin
  Result := Default(TCodeHighlightResult);
  if (Line < 0) or (FSource = nil) or (Line >= FSource.LineCount) then Exit;
  if FSource.GetLineLength(Line) = 0 then Exit;
  State := Default(TCodeHighlightState);
  if Line < FEntries.Count then
  begin Result := FEntries[Line]; if Length(Result.Spans) > 0 then Exit; if Line > 0 then State := FEntries[Line - 1].State; end;
  if FHighlighter <> nil then Result := FHighlighter.HighlightLine(FSource, Line, State);
  if Line < FEntries.Count then
  begin
    FEntries[Line] := Result; FCachedLines.Add(Line);
    while FVisibleOnly and (FCachedLines.Count > 1024) do
    begin Old := FCachedLines[0]; FCachedLines.Delete(0); Entry := FEntries[Old]; Entry.Spans := nil; FEntries[Old] := Entry; end;
  end;
end;
function TCodeHighlightCache.ReadyCount: Integer;
begin Result := FEntries.Count; end;

end.

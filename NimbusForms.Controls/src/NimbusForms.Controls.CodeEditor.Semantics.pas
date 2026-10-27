{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.CodeEditor.Semantics;

interface

uses System.SysUtils, System.Generics.Collections, NimbusForms.Controls.CodeEditor.Types,
  NimbusForms.Controls.CodeEditor.Syntax;

function TryCodeSpecialHighlight(const Language, Text: string; const State: TCodeHighlightState;
  out Spans: TArray<TCodeHighlightSpan>; out NextState: TCodeHighlightState): Boolean;
procedure ApplyCodeSemanticTokens(const Language: ICodeLanguageDefinition; const Text: string; var Highlight: TCodeHighlightResult);

implementation

function TryCodeSpecialHighlight(const Language, Text: string; const State: TCodeHighlightState;
  out Spans: TArray<TCodeHighlightSpan>; out NextState: TCodeHighlightState): Boolean;
var Items: TList<TCodeHighlightSpan>; Span: TCodeHighlightSpan; I, J, K, First, Count: Integer;
  Trimmed, Marker: string; Kind: TCodeEditorHighlightTokenKind;
  procedure Add(const Start, Length: Integer; const Token: TCodeEditorHighlightTokenKind);
  begin if Length <= 0 then Exit; Span.Start := Start - 1; Span.Length := Length; Span.Kind := Token; Items.Add(Span); end;
begin
  Result := False; Spans := nil; NextState := State; Trimmed := Text.TrimLeft;
  if SameText(Language, 'batch') and (SameText(Trimmed, 'rem') or SameText(Copy(Trimmed, 1, 4), 'rem ') or Trimmed.StartsWith('::')) then
  begin Span.Start := 0; Span.Length := Length(Text); Span.Kind := chtComment; Spans := TArray<TCodeHighlightSpan>.Create(Span); Exit(True); end;
  if not SameText(Language, 'markdown') then Exit;
  Result := True; Items := TList<TCodeHighlightSpan>.Create;
  try
    if NextState.MarkdownFence <> '' then
    begin
      Add(1, Length(Text), chtMarkdownCode);
      if Trimmed.StartsWith(NextState.MarkdownFence) then NextState.MarkdownFence := '';
    end
    else if Trimmed.StartsWith('```') or Trimmed.StartsWith('~~~') then
    begin
      Count := 1; while (Count <= Length(Trimmed)) and (Trimmed[Count] = Trimmed[1]) do Inc(Count);
      NextState.MarkdownFence := Copy(Trimmed, 1, Count - 1); Add(1, Length(Text), chtMarkdownCode);
    end
    else if Text.StartsWith('    ') or Text.StartsWith(#9) then Add(1, Length(Text), chtMarkdownCode)
    else
    begin
      I := 1;
      if Trimmed.StartsWith('#') then
      begin
        J := 1; while (J <= Length(Trimmed)) and (Trimmed[J] = '#') do Inc(J);
        if (J <= 7) and (J <= Length(Trimmed)) and (Trimmed[J] = ' ') then
        begin Add(1, Length(Text), chtMarkdownHeading); I := Length(Text) + 1; end;
      end;
      while I <= Length(Text) do
      begin
        First := I; Kind := chtText; J := I;
        if Text[I] = '`' then
        begin
          K := I; while (K <= Length(Text)) and (Text[K] = '`') do Inc(K);
          Marker := Copy(Text, I, K - I); J := Pos(Marker, Text, K);
          if J > 0 then begin J := J + Length(Marker) - 1; Kind := chtMarkdownCode; end else J := I;
        end
        else if CharInSet(Text[I], ['*', '_']) then
        begin
          Marker := Text[I]; if (I < Length(Text)) and (Text[I + 1] = Text[I]) then Marker := Marker + Text[I];
          J := Pos(Marker, Text, I + Length(Marker));
          if J > 0 then begin J := J + Length(Marker) - 1; Kind := chtMarkdownEmphasis; end else J := I;
        end
        else if Text[I] = '[' then
        begin
          K := Pos('](', Text, I + 1);
          if K > 0 then begin J := Pos(')', Text, K + 2); if J > 0 then Kind := chtMarkdownLink else J := I; end;
        end;
        if J < I then J := I;
        if Kind = chtText then
        begin J := I; while (J < Length(Text)) and not CharInSet(Text[J + 1], ['`', '*', '_', '[']) do Inc(J); end;
        Add(First, J - First + 1, Kind); I := J + 1;
      end;
    end;
    Spans := Items.ToArray;
  finally Items.Free; end;
end;

procedure ApplyCodeSemanticTokens(const Language: ICodeLanguageDefinition; const Text: string; var Highlight: TCodeHighlightResult);
var Items: TList<TCodeHighlightSpan>; Span, Previous: TCodeHighlightSpan;
  I, J, NextIndex: Integer; Word, Lower, PreviousWord, NextWord, Name: string;
  Delphi, VB, TypedName, NameToken, RoutineName, ConstantPending, Definition: Boolean;
  BoundKind: TCodeEditorHighlightTokenKind;
  function BoundToken(const Value: string): TCodeEditorHighlightTokenKind;
  var K: Integer; Key: string;
  begin
    Result := chtIdentifier; Key := Value; if not Language.CaseSensitive then Key := LowerCase(Key);
    for K := High(Highlight.State.Bindings) downto 0 do
      if Highlight.State.Bindings[K].Name = Key then Exit(Highlight.State.Bindings[K].Kind);
  end;
  procedure Remember(const Value: string; const Kind: TCodeEditorHighlightTokenKind);
  var Bindings: TArray<TCodeHighlightBinding>; Key: string; K, Index: Integer;
  begin
    Key := Value; if not Language.CaseSensitive then Key := LowerCase(Key);
    Index := -1;
    for K := 0 to High(Highlight.State.Bindings) do if Highlight.State.Bindings[K].Name = Key then begin Index := K; Break; end;
    if (Index >= 0) and (Highlight.State.Bindings[Index].Kind = Kind) then Exit;
    if (Index < 0) and (Length(Highlight.State.Bindings) >= 128) then Bindings := Copy(Highlight.State.Bindings, 1, 127)
    else Bindings := Copy(Highlight.State.Bindings);
    if Index < 0 then begin Index := Length(Bindings); SetLength(Bindings, Index + 1); end;
    Bindings[Index].Name := Key; Bindings[Index].Kind := Kind; Highlight.State.Bindings := Bindings;
  end;
  procedure Add(const First, Count: Integer; const Kind: TCodeEditorHighlightTokenKind);
  var S: TCodeHighlightSpan;
  begin if Count <= 0 then Exit; S.Start := First - 1; S.Length := Count; S.Kind := Kind; Items.Add(S); end;
  procedure Documentation(const SourceSpan: TCodeHighlightSpan);
  var P, Q, Limit, TagState: Integer; Quote: Char;
  begin
    P := SourceSpan.Start + 1; Limit := P + SourceSpan.Length; TagState := 0;
    while P < Limit do
    begin
      Q := P + 1;
      if Text[P] = '<' then
      begin
        if (Q < Limit) and (Text[Q] = '/') then Inc(Q);
        while (Q < Limit) and (CodeIsWord(Text[Q]) or (Text[Q] = '-')) do Inc(Q);
        Add(P, Q - P, chtXmlDocTag); TagState := 1;
      end
      else if (TagState > 0) and (Text[P] = '>') then begin Add(P, 1, chtXmlDocTag); TagState := 0; end
      else if (TagState > 0) and (Text[P] = '/') then begin Add(P, 1, chtXmlDocTag); end
      else if (TagState > 0) and CharInSet(Text[P], ['"', #39]) then
      begin
        Quote := Text[P]; while (Q < Limit) and (Text[Q] <> Quote) do Inc(Q); if Q < Limit then Inc(Q);
        Add(P, Q - P, chtXmlDocValue);
      end
      else if (TagState > 0) and CodeIsWord(Text[P]) then
      begin while (Q < Limit) and (CodeIsWord(Text[Q]) or (Text[Q] = '-')) do Inc(Q); Add(P, Q - P, chtXmlDocAttribute); end
      else
      begin
        while (Q < Limit) and (Text[Q] <> '<') and ((TagState = 0) or not (CodeIsWord(Text[Q]) or CharInSet(Text[Q], ['>', '/', '"', #39]))) do Inc(Q);
        Add(P, Q - P, SourceSpan.Kind);
      end;
      P := Q;
    end;
  end;
begin
  Delphi := SameText(Language.Name, 'delphi'); VB := SameText(Language.Name, 'vb');
  Name := LowerCase(Language.Name); Previous := Default(TCodeHighlightSpan); Previous.Kind := chtText; PreviousWord := '';
  ConstantPending := False;
  Items := TList<TCodeHighlightSpan>.Create;
  try
    for I := 0 to High(Highlight.Spans) do
    begin
      Span := Highlight.Spans[I]; Word := Copy(Text, Span.Start + 1, Span.Length); Lower := LowerCase(Word);
      if Span.Kind in [chtDocumentationComment, chtXmlDocComment] then begin Documentation(Span); Continue; end;
      if Span.Kind in [chtComment, chtString, chtVerbatimString, chtInterpolatedString, chtCharacter, chtPreprocessor, chtWhitespace] then begin Items.Add(Span); Continue; end;
      NextIndex := I + 1; while (NextIndex <= High(Highlight.Spans)) and (Highlight.Spans[NextIndex].Kind = chtWhitespace) do Inc(NextIndex);
      NextWord := ''; if NextIndex <= High(Highlight.Spans) then NextWord := Copy(Text, Highlight.Spans[NextIndex].Start + 1, Highlight.Spans[NextIndex].Length);
      if Span.Kind = chtImportKeyword then Highlight.State.Section := 'imports';
      if (Lower = 'const') or (Lower = 'constexpr') or (Lower = 'consteval') then ConstantPending := True;
      if Delphi and (Highlight.State.ParameterDepth = 0) then
      begin
        if (Lower = 'var') or (Lower = 'threadvar') then Highlight.State.Section := 'variables'
        else if Lower = 'const' then Highlight.State.Section := 'constants'
        else if Lower = 'type' then Highlight.State.Section := 'types'
        else if (Lower = 'begin') or (Lower = 'implementation') then Highlight.State.Section := '';
      end;
      if (Lower = 'procedure') or (Lower = 'function') or (Lower = 'constructor') or (Lower = 'destructor') or
        (VB and ((Lower = 'sub') or (Lower = 'function'))) or ((Name = 'rust') and (Lower = 'fn')) then Highlight.State.InRoutine := True;
      NameToken := Span.Kind in [chtIdentifier, chtNamespaceName, chtModuleName, chtClassName, chtStructName, chtInterfaceName,
        chtEnumName, chtTypeName, chtMethodName, chtFunctionName, chtProcedureName, chtConstructorName, chtPropertyName,
        chtFieldName, chtVariableName, chtLocalVariableName, chtParameterName, chtConstantName, chtEventName];
      if NameToken then
      begin
        TypedName := False; BoundKind := BoundToken(Word);
        if Delphi or (Name = 'rust') then
        begin
          J := NextIndex;
          while J <= High(Highlight.Spans) do
          begin
            NextWord := Copy(Text, Highlight.Spans[J].Start + 1, Highlight.Spans[J].Length);
            if NextWord = ':' then begin TypedName := True; Break; end;
            if (Highlight.Spans[J].Kind <> chtWhitespace) and (NextWord <> ',') and not (Highlight.Spans[J].Kind in [chtIdentifier, chtVariableName, chtTypeName, chtParameterName, chtClassName, chtFieldName, chtConstantName]) then Break;
            Inc(J);
          end;
          NextWord := ''; if NextIndex <= High(Highlight.Spans) then NextWord := Copy(Text, Highlight.Spans[NextIndex].Start + 1, Highlight.Spans[NextIndex].Length);
        end;
        RoutineName := Span.Kind in [chtFunctionName, chtProcedureName, chtConstructorName];
        Definition := (Previous.Kind = chtDeclarationKeyword) or TypedName or
          (Delphi and (NextWord = '=') and (Highlight.State.Section = 'types')) or
          (ConstantPending and ((NextWord = '=') or (NextWord = ':'))) or
          (Delphi and (Highlight.State.Section = 'constants') and (NextWord = '=')) or
          (Previous.Kind in [chtTypeKeyword, chtTypeName, chtClassName]) or
          ((PreviousWord = 'let') or (PreviousWord = 'var') or (PreviousWord = 'mut') or SameText(PreviousWord, 'Dim'));
        if (Previous.Kind = chtDeclarationKeyword) and (Language.DeclarationKind(PreviousWord) <> chtIdentifier) then Span.Kind := Language.DeclarationKind(PreviousWord)
        else if Highlight.State.Section = 'imports' then Span.Kind := chtImportName
        else if Delphi and (PreviousWord = '=') and (Highlight.State.Section = 'types') then Span.Kind := chtClassName
        else if Delphi and (NextWord = '=') and (Highlight.State.Section = 'types') then Span.Kind := chtClassName
        else if (PreviousWord = ':') or (VB and SameText(PreviousWord, 'As')) or (PreviousWord = 'new') or (PreviousWord = 'extends') or (PreviousWord = 'Inherits') then Span.Kind := chtClassName
        else if TypedName then
          if Highlight.State.ParameterDepth > 0 then Span.Kind := chtParameterName
          else if ConstantPending or (Highlight.State.Section = 'constants') then Span.Kind := chtConstantName
          else Span.Kind := chtVariableName
        else if ConstantPending and (Highlight.State.ParameterDepth = 0) then Span.Kind := chtConstantName
        else if not Definition and (BoundKind <> chtIdentifier) then Span.Kind := BoundKind
        else if Delphi and (Highlight.State.Section = 'constants') and not RoutineName then Span.Kind := chtConstantName
        else if (PreviousWord = 'const') or (PreviousWord = 'Const') or (PreviousWord = 'constexpr') or (PreviousWord = 'static') then Span.Kind := chtConstantName
        else if (NextWord = '(') and not (Span.Kind in [chtClassName, chtStructName, chtInterfaceName, chtEnumName]) then
        begin
          Span.Kind := chtMethodName;
          if Previous.Kind in [chtTypeKeyword, chtTypeName, chtClassName] then Highlight.State.InRoutine := True;
        end
        else if (Previous.Kind in [chtTypeKeyword, chtClassName, chtTypeName]) and (PreviousWord <> '.') then
          if Highlight.State.ParameterDepth > 0 then Span.Kind := chtParameterName else Span.Kind := chtVariableName
        else if VB and ((PreviousWord = 'Dim') or (PreviousWord = 'dim') or SameText(NextWord, 'As')) then
          if Highlight.State.ParameterDepth > 0 then Span.Kind := chtParameterName else Span.Kind := chtVariableName
        else if Delphi and (Length(Word) > 1) and (Word[1] = 'T') and CharInSet(Word[2], ['A'..'Z']) then Span.Kind := chtClassName
        else if (PreviousWord = 'let') or (PreviousWord = 'var') or (PreviousWord = 'mut') or (Word.StartsWith('$') and not (Span.Kind in [chtBoolean, chtNull])) then Span.Kind := chtVariableName
        else if Span.Kind = chtIdentifier then
          if Highlight.State.ParameterDepth > 0 then Span.Kind := chtParameterName else Span.Kind := chtVariableName
        else if (Span.Kind = chtParameterName) and (Highlight.State.ParameterDepth = 0) then Span.Kind := chtVariableName;
        if Definition then Remember(Word, Span.Kind);
      end;
      if (Word = '(') and Highlight.State.InRoutine then Inc(Highlight.State.ParameterDepth);
      if (Word = ')') and (Highlight.State.ParameterDepth > 0) then Dec(Highlight.State.ParameterDepth);
      if (Word = '{') or (Lower = 'begin') then Highlight.State.InRoutine := False;
      if (Name = 'rust') and (Word = '{') then Highlight.State.Section := '';
      if (Word = ';') and (Highlight.State.ParameterDepth = 0) then
      begin
        ConstantPending := False;
        Highlight.State.InRoutine := False;
        if (Highlight.State.Section = 'imports') or not Delphi then Highlight.State.Section := '';
      end;
      Items.Add(Span); Previous := Span; PreviousWord := Word;
    end;
    Highlight.Spans := Items.ToArray;
    if (VB or (Name = 'powershell')) and (Highlight.State.Section = 'imports') then Highlight.State.Section := '';
  finally Items.Free; end;
end;

end.

unit NimbusForms.Controls.CodeEditor.Structure;

interface

uses NimbusForms.Controls.CodeEditor.Types, NimbusForms.Controls.CodeEditor.Document,
  NimbusForms.Controls.CodeEditor.Syntax;

function CodeFindEnclosingStructure(const Source: ICodeVirtualTextSource; const Highlighter: ICodeSyntaxHighlighter;
  const LanguageName: string; const Selection: TCodeDocumentRange; out Selected: TCodeDocumentRange): Boolean;

implementation

uses Winapi.Windows, System.SysUtils, System.Math, System.Character, System.Generics.Collections;

type
  TStructureToken = record
    Text: string;
    Offset, Finish: Integer;
  end;
  TStructureSelection = class
  private
    FSource: ICodeVirtualTextSource;
    FTokens: TList<TStructureToken>;
    FStarted: UInt64;
    FIsPascal, FAborted, FInterfaceSection: Boolean;
    FDepth, FStart, FFinish, FBestStart, FBestFinish: Integer;
    function Alive: Boolean;
    function WordAt(const Index: Integer): string;
    procedure Offer(const First, After: Integer);
    procedure Group(var Index: Integer; const Owner: Integer = -1);
    procedure BraceBody(var Index: Integer);
    procedure BraceStatement(var Index: Integer; const EmitBlock: Boolean);
    procedure PascalBody(var Index: Integer; const EmitBlock: Boolean);
    procedure PascalStatement(var Index: Integer; const EmitBlock, InType: Boolean);
    procedure PascalRoutine(var Index: Integer; const InType: Boolean);
    procedure PascalType(var Index: Integer; const First: Integer);
    procedure ScanTo(var Index: Integer; const Stop: string);
    function Tokenize(const Highlighter: ICodeSyntaxHighlighter): Boolean;
  public
    constructor Create(const Source: ICodeVirtualTextSource; const LanguageName: string; const Selection: TCodeDocumentRange);
    destructor Destroy; override;
    function Find(const Highlighter: ICodeSyntaxHighlighter; out Selected: TCodeDocumentRange): Boolean;
  end;

constructor TStructureSelection.Create(const Source: ICodeVirtualTextSource; const LanguageName: string;
  const Selection: TCodeDocumentRange);
begin
  inherited Create; FSource := Source; FTokens := TList<TStructureToken>.Create; FStarted := GetTickCount64;
  FIsPascal := SameText(LanguageName, 'delphi') or SameText(LanguageName, 'pascal');
  FStart := Source.GetOffset(Selection.Start); FFinish := Source.GetOffset(Selection.Finish);
  FBestStart := -1; FBestFinish := MaxInt;
end;

destructor TStructureSelection.Destroy;
begin FTokens.Free; inherited; end;

function TStructureSelection.Alive: Boolean;
begin
  if (FDepth > 256) or (GetTickCount64 - FStarted > 100) then FAborted := True;
  Result := not FAborted;
end;

function TStructureSelection.WordAt(const Index: Integer): string;
begin
  if (Index < 0) or (Index >= FTokens.Count) then Exit('');
  Result := FTokens[Index].Text;
end;

procedure TStructureSelection.Offer(const First, After: Integer);
var Start, Finish: Integer;
begin
  if (First < 0) or (After <= First) or (After > FTokens.Count) then Exit;
  Start := FTokens[First].Offset; Finish := FTokens[After - 1].Finish;
  if (Start > FStart) or (Finish < FFinish) or ((Start = FStart) and (Finish = FFinish)) then Exit;
  if (FBestStart < 0) or (Finish - Start < FBestFinish - FBestStart) then
  begin FBestStart := Start; FBestFinish := Finish; end;
end;

function TStructureSelection.Tokenize(const Highlighter: ICodeSyntaxHighlighter): Boolean;
var State: TCodeHighlightState; Highlight: TCodeHighlightResult; Span: TCodeHighlightSpan;
  Token: TStructureToken; Text: string; Line, I, J, Limit, Base: Integer;
begin
  Result := False; State := Default(TCodeHighlightState);
  for Line := 0 to FSource.LineCount - 1 do
  begin
    if not Alive then Exit;
    Text := FSource.GetLineText(Line); Base := FSource.GetLineStartOffset(Line);
    Highlight := Highlighter.HighlightLine(FSource, Line, State); State := Highlight.State;
    for Span in Highlight.Spans do
    begin
      if Span.Kind in [chtComment, chtDocumentationComment, chtXmlDocComment, chtPreprocessor] then Continue;
      I := Max(0, Span.Start); Limit := Min(Length(Text), Span.Start + Span.Length);
      if Span.Kind in [chtString, chtVerbatimString, chtInterpolatedString, chtCharacter] then
      begin
        Token.Text := #0; Token.Offset := Base + I; Token.Finish := Base + Limit;
        FTokens.Add(Token); Continue;
      end;
      while I < Limit do
      begin
        if not Alive then Exit;
        if Text[I + 1].IsWhiteSpace then begin Inc(I); Continue; end;
        J := I + 1;
        if CodeIsWord(Text[I + 1]) then
          while (J < Limit) and CodeIsWord(Text[J + 1]) do Inc(J);
        Token.Text := Copy(Text, I + 1, J - I);
        if FIsPascal then Token.Text := LowerCase(Token.Text);
        Token.Offset := Base + I; Token.Finish := Base + J; FTokens.Add(Token); I := J;
      end;
    end;
  end;
  Result := True;
end;

procedure TStructureSelection.Group(var Index: Integer; const Owner: Integer);
var First, NestedOwner: Integer; Opening, Closing: string; HasComma: Boolean;
begin
  Inc(FDepth);
  try
    if not Alive then Exit;
    First := Index; Opening := WordAt(Index); Closing := ')'; HasComma := False; NestedOwner := -1;
    if Opening = '[' then Closing := ']' else if Opening = '{' then Closing := '}';
    Inc(Index);
    while (Index < FTokens.Count) and (WordAt(Index) <> Closing) and Alive do
    begin
      if WordAt(Index) = ',' then begin HasComma := True; NestedOwner := -1; end;
      if WordAt(Index) = 'new' then NestedOwner := Index;
      if WordAt(Index) = '{' then begin Group(Index, NestedOwner); NestedOwner := -1; end
      else if (WordAt(Index) = '(') or (WordAt(Index) = '[') then Group(Index)
      else Inc(Index);
    end;
    if not Alive then Exit;
    if WordAt(Index) <> Closing then begin FAborted := True; Exit; end;
    Inc(Index);
    if ((Opening = '[') and (Index > First + 2)) or (Opening = '{') or
      (FIsPascal and HasComma and ((WordAt(First - 1) = '=') or (WordAt(First - 1) = '(') or (WordAt(First - 1) = ','))) then
    begin
      if Owner >= 0 then Offer(Owner, Index) else Offer(First, Index);
    end;
  finally Dec(FDepth); end;
end;

procedure TStructureSelection.BraceBody(var Index: Integer);
var Before: Integer;
begin
  if WordAt(Index) <> '{' then Exit;
  Inc(Index);
  while (Index < FTokens.Count) and (WordAt(Index) <> '}') and Alive do
  begin
    Before := Index; BraceStatement(Index, True);
    if Before = Index then Inc(Index);
  end;
  if WordAt(Index) = '}' then Inc(Index) else FAborted := True;
end;

procedure TStructureSelection.BraceStatement(var Index: Integer; const EmitBlock: Boolean);
var First, NewAt: Integer; Token: string; Initializer, HasArray: Boolean;
begin
  Inc(FDepth);
  try
    if not Alive then Exit;
    First := Index; Token := WordAt(Index);
    if (Token = '') or (Token = '}') then begin FAborted := True; Exit; end;
    if Token = '{' then
    begin BraceBody(Index); if EmitBlock then Offer(First, Index); Exit; end;
    if (Token = 'for') or (Token = 'foreach') or (Token = 'while') or (Token = 'if') or
      (Token = 'switch') or (Token = 'lock') or (Token = 'using') or (Token = 'fixed') then
    begin
      Inc(Index);
      if WordAt(Index) <> '(' then begin Index := First; end
      else
      begin
        Group(Index); BraceStatement(Index, False);
        if (Token = 'if') and (WordAt(Index) = 'else') then begin Inc(Index); BraceStatement(Index, False); end;
        Offer(First, Index); Exit;
      end;
    end;
    if Token = 'do' then
    begin
      Inc(Index); BraceStatement(Index, False);
      if WordAt(Index) = 'while' then
      begin Inc(Index); if WordAt(Index) = '(' then Group(Index); if WordAt(Index) = ';' then Inc(Index); end;
      Offer(First, Index); Exit;
    end;
    if Token = 'try' then
    begin
      Inc(Index); BraceStatement(Index, False);
      while ((WordAt(Index) = 'catch') or (WordAt(Index) = 'finally')) and Alive do
      begin Inc(Index); if WordAt(Index) = '(' then Group(Index); BraceStatement(Index, False); end;
      Offer(First, Index); Exit;
    end;
    if (Token = 'case') or (Token = 'default') then
    begin ScanTo(Index, ':'); if WordAt(Index) = ':' then Inc(Index); Exit; end;
    Initializer := False; HasArray := False; NewAt := -1;
    while (Index < FTokens.Count) and Alive do
    begin
      Token := WordAt(Index);
      if Token = '}' then Exit;
      if Token = ';' then begin Inc(Index); if HasArray then Offer(First, Index); Exit; end;
      if Token = '=' then Initializer := True;
      if Token = 'new' then begin Initializer := True; NewAt := Index; end;
      if (Token = '(') or (Token = '[') then
      begin
        if (Token = '[') and (WordAt(Index + 1) <> ']') then HasArray := True;
        Group(Index);
      end
      else if Token = '{' then
      begin
        if Initializer then begin Group(Index, NewAt); HasArray := True; end
        else begin BraceBody(Index); Offer(First, Index); Exit; end;
      end
      else Inc(Index);
    end;
  finally Dec(FDepth); end;
end;

procedure TStructureSelection.ScanTo(var Index: Integer; const Stop: string);
begin
  while (Index < FTokens.Count) and (WordAt(Index) <> Stop) and Alive do
    if (WordAt(Index) = '(') or (WordAt(Index) = '[') then Group(Index) else Inc(Index);
end;

procedure TStructureSelection.PascalBody(var Index: Integer; const EmitBlock: Boolean);
var First, Before: Integer; Token: string;
begin
  First := Index; Token := WordAt(Index); Inc(Index);
  while (Index < FTokens.Count) and (WordAt(Index) <> 'end') and (WordAt(Index) <> 'until') and Alive do
  begin
    if (WordAt(Index) = 'except') or (WordAt(Index) = 'finally') then Inc(Index)
    else
    begin Before := Index; PascalStatement(Index, True, False); if Before = Index then Inc(Index); end;
  end;
  if (Token = 'repeat') and (WordAt(Index) = 'until') then
  begin Inc(Index); PascalStatement(Index, False, False); end
  else if (Token <> 'repeat') and (WordAt(Index) = 'end') then Inc(Index)
  else begin FAborted := True; Exit; end;
  if WordAt(Index) = ';' then Inc(Index);
  if EmitBlock then Offer(First, Index);
end;

procedure TStructureSelection.PascalType(var Index: Integer; const First: Integer);
var Before: Integer;
begin
  Inc(Index);
  if (WordAt(Index) = ';') or (WordAt(Index) = 'of') then Exit;
  while (Index < FTokens.Count) and (WordAt(Index) <> 'end') and Alive do
  begin Before := Index; PascalStatement(Index, True, True); if Before = Index then Inc(Index); end;
  if WordAt(Index) <> 'end' then begin FAborted := True; Exit; end;
  Inc(Index); if WordAt(Index) = ';' then Inc(Index); Offer(First, Index);
end;

procedure TStructureSelection.PascalRoutine(var Index: Integer; const InType: Boolean);
var First, Before: Integer; Token: string;
begin
  First := Index; ScanTo(Index, ';'); if WordAt(Index) <> ';' then Exit; Inc(Index);
  if InType or FInterfaceSection then Exit;
  while Alive do
  begin
    Token := WordAt(Index);
    if (Token = 'forward') or (Token = 'external') or (Token = 'abstract') then
    begin ScanTo(Index, ';'); if WordAt(Index) = ';' then Inc(Index); Exit; end;
    if (Token = 'overload') or (Token = 'override') or (Token = 'virtual') or (Token = 'inline') or
      (Token = 'reintroduce') or (Token = 'cdecl') or (Token = 'stdcall') or (Token = 'safecall') then
    begin ScanTo(Index, ';'); if WordAt(Index) = ';' then Inc(Index); end
    else Break;
  end;
  while (Index < FTokens.Count) and Alive do
  begin
    Token := WordAt(Index);
    if (Token = 'begin') or (Token = 'asm') then
    begin PascalBody(Index, False); Offer(First, Index); Exit; end;
    Before := Index; PascalStatement(Index, True, False); if Before = Index then Inc(Index);
  end;
end;

procedure TStructureSelection.PascalStatement(var Index: Integer; const EmitBlock, InType: Boolean);
var First, Before: Integer; Token: string; ElseBranch: Boolean;
begin
  Inc(FDepth);
  try
    if not Alive then Exit;
    First := Index; Token := WordAt(Index);
    if (Token = 'interface') or (Token = 'implementation') then
    begin FInterfaceSection := Token = 'interface'; Inc(Index); Exit; end;
    if (Token = 'type') or (Token = 'var') or (Token = 'const') or (Token = 'private') or (Token = 'public') or
      (Token = 'protected') or (Token = 'published') or (Token = 'strict') then begin Inc(Index); Exit; end;
    if (Token = 'procedure') or (Token = 'function') or (Token = 'constructor') or (Token = 'destructor') or
      ((Token = 'class') and ((WordAt(Index + 1) = 'procedure') or (WordAt(Index + 1) = 'function'))) then
    begin PascalRoutine(Index, InType); Exit; end;
    if (Token = 'begin') or (Token = 'try') or (Token = 'asm') or (Token = 'repeat') then
    begin PascalBody(Index, EmitBlock or (Token <> 'begin')); Exit; end;
    if (Token = 'for') or (Token = 'while') or (Token = 'with') or (Token = 'on') or (Token = 'if') then
    begin
      Inc(Index); if Token = 'if' then ScanTo(Index, 'then') else ScanTo(Index, 'do');
      if Index >= FTokens.Count then Exit;
      Inc(Index); Before := Index; PascalStatement(Index, False, False);
      if Before = Index then begin FAborted := True; Exit; end;
      if (Token = 'if') and (WordAt(Index) = 'else') then begin Inc(Index); PascalStatement(Index, False, False); end;
      Offer(First, Index); Exit;
    end;
    if (Token = 'case') and not InType then
    begin
      Inc(Index); ScanTo(Index, 'of'); if Index >= FTokens.Count then Exit; Inc(Index);
      ElseBranch := False;
      while (Index < FTokens.Count) and (WordAt(Index) <> 'end') and Alive do
      begin
        if WordAt(Index) = 'else' then begin Inc(Index); ElseBranch := True; end
        else if not ElseBranch then begin ScanTo(Index, ':'); if WordAt(Index) = ':' then Inc(Index); end;
        Before := Index; PascalStatement(Index, True, False); if Before = Index then Inc(Index);
      end;
      if WordAt(Index) <> 'end' then begin FAborted := True; Exit; end;
      Inc(Index); if WordAt(Index) = ';' then Inc(Index); Offer(First, Index); Exit;
    end;
    while (Index < FTokens.Count) and Alive do
    begin
      Token := WordAt(Index);
      if (Token = 'end') or (Token = 'until') or (Token = 'else') or (Token = 'except') or (Token = 'finally') then Exit;
      if Token = ';' then begin Inc(Index); Exit; end;
      if ((Token = 'class') or (Token = 'record') or (Token = 'interface') or (Token = 'object')) and
        ((WordAt(Index - 1) = '=') or (WordAt(Index - 1) = 'packed')) then
      begin PascalType(Index, First); Exit; end;
      if (Token = '(') or (Token = '[') then Group(Index)
      else if (Token = 'begin') or (Token = 'try') or (Token = 'repeat') then
      begin PascalStatement(Index, True, False); Exit; end
      else Inc(Index);
    end;
  finally Dec(FDepth); end;
end;

function TStructureSelection.Find(const Highlighter: ICodeSyntaxHighlighter; out Selected: TCodeDocumentRange): Boolean;
var Index, Before: Integer;
begin
  Result := False; Selected := Default(TCodeDocumentRange);
  if not Tokenize(Highlighter) then Exit;
  Index := 0;
  while (Index < FTokens.Count) and Alive do
  begin
    Before := Index;
    if FIsPascal then PascalStatement(Index, True, False) else BraceStatement(Index, True);
    if Before = Index then Inc(Index);
  end;
  if not Alive or (FBestStart < 0) then Exit;
  Selected := TCodeDocumentRange.Create(FSource.GetPosition(FBestStart), FSource.GetPosition(FBestFinish)); Result := True;
end;

function CodeFindEnclosingStructure(const Source: ICodeVirtualTextSource; const Highlighter: ICodeSyntaxHighlighter;
  const LanguageName: string; const Selection: TCodeDocumentRange; out Selected: TCodeDocumentRange): Boolean;
var Parser: TStructureSelection;
begin
  Result := False; Selected := Selection;
  if (Source = nil) or (Highlighter = nil) then Exit;
  Parser := TStructureSelection.Create(Source, LanguageName, Selection);
  try
    Result := Parser.Find(Highlighter, Selected);
    if not Result then Selected := Selection;
  finally Parser.Free; end;
end;

end.

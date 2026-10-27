unit NimbusCodeStructureChecks;

interface

procedure RunCodeStructureChecks;

implementation

uses System.SysUtils, NimbusForms.Controls.CodeEditor.Types, NimbusForms.Controls.CodeEditor.Document,
  NimbusForms.Controls.CodeEditor.Syntax, NimbusForms.Controls.CodeEditor.Services;

procedure RunCodeStructureChecks;
var Document: TCodeDocument; Registry: TCodeLanguageRegistry; Highlighter: ICodeSyntaxHighlighter;
  Selected, Block: TCodeDocumentRange; Language: string;
  function Range(const SL, SC, EL, EC: Integer): TCodeDocumentRange;
  begin Result := TCodeDocumentRange.Create(TCodeDocumentPosition.Create(SL, SC), TCodeDocumentPosition.Create(EL, EC)); end;
  procedure Check(const Condition: Boolean; const Name: string);
  begin if not Condition then raise EInvalidOpException.Create(Name); end;
  procedure ExpectBlock(const Needle, Expected: string);
  var Offset: Integer;
  begin
    Offset := Pos(Needle, Document.Text) - 1; Check(Offset >= 0, 'block test selection exists');
    Selected := TCodeDocumentRange.Create(Document.GetPosition(Offset), Document.GetPosition(Offset + Length(Needle)));
    Check(CodeFindEnclosingBlock(Document.GetSnapshot, Highlighter, Language, Selected, Block), 'enclosing structure found: ' + Language + ' / ' + Needle);
    Check(CodeNormalizeNewLines(Document.GetTextRange(Block)) = CodeNormalizeNewLines(Expected), 'nearest enclosing structure text: ' + Language + ' / ' + Needle);
  end;
begin
  Document := TCodeDocument.Create(nil); Registry := TCodeLanguageRegistry.Create;
  try
    Language := 'csharp'; Highlighter := TLanguageBasedCodeSyntaxHighlighter.Create(Registry.FindByName(Language));
    Document.Text := '{ { call("}"); /* { */ beta; } tail; }';
    ExpectBlock('beta', '{ call("}"); /* { */ beta; }');
    Selected := Block;
    Check(CodeFindEnclosingBlock(Document.GetSnapshot, Highlighter, Language, Selected, Block), 'selection grows to parent block');
    Check(Document.GetTextRange(Block) = Document.Text, 'parent brace block');
    Selected := Block;
    Check(not CodeFindEnclosingBlock(Document.GetSnapshot, Highlighter, Language, Selected, Block), 'outer block has no larger block');
    Document.Text := '"{ beta }"'; Selected := Range(0, 3, 0, 7);
    Check(not CodeFindEnclosingBlock(Document.GetSnapshot, Highlighter, Language, Selected, Block), 'string braces do not create blocks');
    Document.Text := '{ beta'; Selected := Range(0, 2, 0, 6);
    Check(not CodeFindEnclosingBlock(Document.GetSnapshot, Highlighter, Language, Selected, Block), 'unclosed block is not selected');
    Document.Text := 'for (int i=0; i<3; i++)'; Selected := Range(0, 5, 0, 8);
    Check(not CodeFindEnclosingBlock(Document.GetSnapshot, Highlighter, Language, Selected, Block), 'loop without body is not a complete structure');
    Language := 'delphi'; Highlighter := TLanguageBasedCodeSyntaxHighlighter.Create(Registry.FindByName(Language));
    Document.Text := 'begin'#10'  try'#10'    begin'#10'      s := ''end''; { begin } value;'#10'    end;'#10'  except'#10'  end;'#10'end';
    ExpectBlock('value', 'begin'#10'      s := ''end''; { begin } value;'#10'    end;');
    Selected := Block;
    Check(CodeFindEnclosingBlock(Document.GetSnapshot, Highlighter, Language, Selected, Block), 'Pascal selection grows to try block');
    Check((Block.Start.LineIndex = 1) and (Block.Finish.LineIndex = 6), 'try except end boundaries');
    Document.Text := 'case value of 1: begin beta; end; end';
    ExpectBlock('beta', 'begin beta; end;');
    ExpectBlock('value', 'case value of 1: begin beta; end; end');
    Document.Text := 'procedure Run; var I: Integer; begin for I := 0 to 4 do begin Work(I); end; end;';
    ExpectBlock('Work', 'for I := 0 to 4 do begin Work(I); end;');
    ExpectBlock('for', 'for I := 0 to 4 do begin Work(I); end;');
    Selected := Block;
    Check(CodeFindEnclosingBlock(Document.GetSnapshot, Highlighter, Language, Selected, Block), 'Delphi loop expands to routine');
    Check(Document.GetTextRange(Block) = Document.Text, 'Delphi routine includes signature and local declarations');
    Document.Text := 'begin while Ready do Work; end;';
    ExpectBlock('Work', 'while Ready do Work;');
    Document.Text := 'begin for I := 0 to 2 do while Ready do Work; end;';
    ExpectBlock('Work', 'while Ready do Work;');
    ExpectBlock('while Ready do Work;', 'for I := 0 to 2 do while Ready do Work;');
    Document.Text := 'begin repeat Work; until Done; end;';
    ExpectBlock('Work', 'repeat Work; until Done;');
    Document.Text := 'type TExample = class private FValue: Integer; public procedure Run; end;';
    ExpectBlock('FValue', 'TExample = class private FValue: Integer; public procedure Run; end;');
    Document.Text := 'const Values: array[0..2] of Integer = (11, 22, 33);';
    ExpectBlock('22', '(11, 22, 33)');
    Document.Text := 'procedure Run; begin Work; end;';
    ExpectBlock('Work', 'procedure Run; begin Work; end;');
    Document.Text := 'procedure Outer; procedure Inner; begin Work; end; begin Inner; end;';
    ExpectBlock('Work', 'procedure Inner; begin Work; end;');
    Document.Text := 'begin if Ready then Work else Wait; end;';
    ExpectBlock('Work', 'if Ready then Work else Wait;');
    Document.Text := 'begin case Kind of 1: Work; else Wait; Finish; end; end;';
    ExpectBlock('Finish', 'case Kind of 1: Work; else Wait; Finish; end;');
    Document.Text := 'begin for I := 0 to 3 do end;'; Selected := Range(0, 6, 0, 9);
    Check(not CodeFindEnclosingBlock(Document.GetSnapshot, Highlighter, Language, Selected, Block), 'Delphi loop without body is not selected');
    Language := 'csharp'; Highlighter := TLanguageBasedCodeSyntaxHighlighter.Create(Registry.FindByName(Language));
    Document.Text := 'public class Example { public void Run() { for (int i = 0; i < 3; i++) { Work(i); } } }';
    ExpectBlock('Work', 'for (int i = 0; i < 3; i++) { Work(i); }');
    ExpectBlock('for', 'for (int i = 0; i < 3; i++) { Work(i); }');
    ExpectBlock('for (int i = 0; i < 3; i++) { Work(i); }', 'public void Run() { for (int i = 0; i < 3; i++) { Work(i); } }');
    Selected := Block;
    Check(CodeFindEnclosingBlock(Document.GetSnapshot, Highlighter, Language, Selected, Block), 'C# method expands to class');
    Check(Document.GetTextRange(Block) = Document.Text, 'C# class includes declaration');
    Document.Text := 'class C { void Run() { while (Ready) Work(); } }';
    ExpectBlock('Work', 'while (Ready) Work();');
    Document.Text := 'class C { void Run() { for (int i = 0; i < 3; i++) while (Ready) Work(); } }';
    ExpectBlock('Work', 'while (Ready) Work();');
    ExpectBlock('while (Ready) Work();', 'for (int i = 0; i < 3; i++) while (Ready) Work();');
    Document.Text := 'class C { void Run() { foreach (var item in items) { Work(item); } } }';
    ExpectBlock('Work', 'foreach (var item in items) { Work(item); }');
    Document.Text := 'class C { void Run() { do { Work(); } while (Ready); } }';
    ExpectBlock('Work', 'do { Work(); } while (Ready);');
    Document.Text := 'class C { void Run() { if (Ready) Work(); else Wait(); } }';
    ExpectBlock('Work', 'if (Ready) Work(); else Wait();');
    Document.Text := 'class C { void Run() { var a = new[] { 11, 22, 33 }; } }';
    ExpectBlock('22', 'new[] { 11, 22, 33 }');
    Document.Text := 'class C { void Run() { int[] a = [11, 22, 33]; } }';
    ExpectBlock('22', '[11, 22, 33]');
    Document.Text := 'class C { void Run() { var a = new[] { new[] { 11, 22 }, new[] { 33 } }; } }';
    ExpectBlock('22', 'new[] { 11, 22 }');
    ExpectBlock('new[] { 11, 22 }', 'new[] { new[] { 11, 22 }, new[] { 33 } }');
    Document.Text := 'class C { void Run() { for (int i=0; i<3; i++) { var a = new[] { 11, 22 }; } } }';
    ExpectBlock('22', 'new[] { 11, 22 }');
    ExpectBlock('var a = new[] { 11, 22 };', 'for (int i=0; i<3; i++) { var a = new[] { 11, 22 }; }');
    Document.Text := 'class C { void Run() { for ('#10'int i = 0;'#10'i < 3;'#10'i++)'#10'{ Work(); } } }';
    ExpectBlock('Work', 'for ('#10'int i = 0;'#10'i < 3;'#10'i++)'#10'{ Work(); }');
    Document.Text := 'class C { void Run() { Work(); } }';
    ExpectBlock('Work', 'void Run() { Work(); }');
    Document.Text := 'class C { int value; void Run() { } }';
    ExpectBlock('value', 'class C { int value; void Run() { } }');
    Document.Text := 'class C { void Run() { try { Work(); } catch (Exception e) { Wait(); } finally { Finish(); } } }';
    ExpectBlock('Wait', 'try { Work(); } catch (Exception e) { Wait(); } finally { Finish(); }');
  finally Document.Free; Registry.Free; end;
end;

end.

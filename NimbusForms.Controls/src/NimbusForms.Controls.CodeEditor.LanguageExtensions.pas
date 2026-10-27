{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.CodeEditor.LanguageExtensions;

interface

uses NimbusForms.Controls.CodeEditor.Syntax;

procedure ConfigureCodeEditorLanguage(Definition: TCodeLanguageDefinition);
procedure RegisterAdditionalCodeEditorLanguages(Registry: TCodeLanguageRegistry);

implementation

uses System.SysUtils, NimbusForms.Controls.CodeEditor.Types;

procedure ConfigureCodeEditorLanguage(Definition: TCodeLanguageDefinition);
begin
  if SameText(Definition.Name, 'vb') then Definition.AddKeywords(chtLoopKeyword, TArray<string>.Create('For', 'Each', 'Next', 'While', 'Do', 'Loop', 'Until'))
  else if SameText(Definition.Name, 'delphi') then Definition.AddKeywords(chtLoopKeyword, TArray<string>.Create('for', 'while', 'do', 'repeat', 'until'))
  else if SameText(Definition.Name, 'rust') then Definition.AddKeywords(chtLoopKeyword, TArray<string>.Create('for', 'while', 'loop'))
  else if SameText(Definition.Name, 'powershell') or SameText(Definition.Name, 'perl') then Definition.AddKeywords(chtLoopKeyword, TArray<string>.Create('for', 'foreach', 'while', 'do', 'until'))
  else if SameText(Definition.Name, 'autoit') then Definition.AddKeywords(chtLoopKeyword, TArray<string>.Create('For', 'Next', 'While', 'WEnd', 'Do', 'Until'))
  else if SameText(Definition.Name, 'csharp') then Definition.AddKeywords(chtLoopKeyword, TArray<string>.Create('for', 'foreach', 'while', 'do'))
  else if SameText(Definition.Name, 'cpp') or SameText(Definition.Name, 'java') or SameText(Definition.Name, 'javascript') then
    Definition.AddKeywords(chtLoopKeyword, TArray<string>.Create('for', 'while', 'do'));
  if SameText(Definition.Name, 'delphi') then
  begin
    Definition.AddKeywords(chtImportKeyword, TArray<string>.Create('uses', 'contains', 'requires'));
    Definition.AddKeywords(chtBlockKeyword, TArray<string>.Create('begin', 'end'));
    Definition.AddKeywords(chtResultName, TArray<string>.Create('Result', 'Self'));
    Definition.AddKeywords(chtTypeKeyword, TArray<string>.Create('Int64', 'UInt64', 'NativeInt', 'NativeUInt', 'WideChar', 'UnicodeString', 'AnsiString', 'WideString', 'TDateTime', 'Real', 'SmallInt', 'ShortInt', 'LongWord'));
    Definition.AddDeclaration('constructor', chtDeclarationKeyword, chtConstructorName);
    Definition.AddDeclaration('destructor', chtDeclarationKeyword, chtProcedureName);
  end
  else if SameText(Definition.Name, 'vb') then
  begin
    Definition.AddKeywords(chtImportKeyword, TArray<string>.Create('Imports'));
    Definition.AddKeywords(chtBlockKeyword, TArray<string>.Create('End'));
    Definition.AddKeywords(chtResultName, TArray<string>.Create('Me', 'MyBase', 'MyClass'));
    Definition.AddKeywords(chtModifierKeyword, TArray<string>.Create('Dim'));
  end
  else if SameText(Definition.Name, 'powershell') then
  begin
    Definition.AddKeywords(chtImportKeyword, TArray<string>.Create('using', 'Import-Module', 'using-module', 'requires'));
    Definition.AddKeywords(chtBlockKeyword, TArray<string>.Create('begin', 'process', 'end'));
  end
  else if SameText(Definition.Name, 'cpp') then Definition.AddKeywords(chtImportKeyword, TArray<string>.Create('using', 'import'))
  else if SameText(Definition.Name, 'java') then Definition.AddKeywords(chtImportKeyword, TArray<string>.Create('import', 'package'))
  else if SameText(Definition.Name, 'perl') then Definition.AddKeywords(chtImportKeyword, TArray<string>.Create('use', 'require'))
  else if SameText(Definition.Name, 'csharp') then
  begin
    Definition.AddKeywords(chtImportKeyword, TArray<string>.Create('using'));
    Definition.AddKeywords(chtResultName, TArray<string>.Create('this', 'base'));
  end;
end;

procedure RegisterAdditionalCodeEditorLanguages(Registry: TCodeLanguageRegistry);
var Definition: TCodeLanguageDefinition; Language: ICodeLanguageDefinition;
begin
  Definition := TCodeLanguageDefinition.Create; Language := Definition;
  Definition.Name := 'rust'; Definition.DisplayName := 'Rust'; Definition.CaseSensitive := True;
  Definition.FileExtensions := TArray<string>.Create('.rs'); Definition.LineComment := '//';
  Definition.BlockCommentStart := '/*'; Definition.BlockCommentEnd := '*/'; Definition.DocumentationLineComment := '///';
  Definition.AddKeywords(chtKeyword, TArray<string>.Create('as', 'in', 'ref', 'self', 'Self', 'move', 'where', 'dyn', 'macro_rules'));
  Definition.AddKeywords(chtControlKeyword, TArray<string>.Create('if', 'else', 'match', 'break', 'continue', 'return', 'yield', 'await'));
  Definition.AddKeywords(chtModifierKeyword, TArray<string>.Create('let', 'mut', 'pub', 'unsafe', 'async', 'extern', 'const', 'static'));
  Definition.AddKeywords(chtTypeKeyword, TArray<string>.Create('bool', 'char', 'str', 'String', 'i8', 'i16', 'i32', 'i64', 'i128', 'isize', 'u8', 'u16', 'u32', 'u64', 'u128', 'usize', 'f32', 'f64'));
  Definition.AddKeywords(chtBoolean, TArray<string>.Create('true', 'false'));
  Definition.AddKeywords(chtImportKeyword, TArray<string>.Create('use', 'mod', 'crate', 'super'));
  Definition.AddDeclaration('fn', chtDeclarationKeyword, chtFunctionName);
  Definition.AddDeclaration('struct', chtDeclarationKeyword, chtStructName);
  Definition.AddDeclaration('enum', chtDeclarationKeyword, chtEnumName);
  Definition.AddDeclaration('trait', chtDeclarationKeyword, chtInterfaceName);
  Definition.AddDeclaration('impl', chtDeclarationKeyword, chtClassName);
  Definition.AddDeclaration('type', chtDeclarationKeyword, chtTypeName);
  ConfigureCodeEditorLanguage(Definition); Registry.RegisterLanguage(Language);
  Definition := TCodeLanguageDefinition.Create; Language := Definition;
  Definition.Name := 'javascript'; Definition.DisplayName := 'JavaScript'; Definition.CaseSensitive := True;
  Definition.FileExtensions := TArray<string>.Create('.js', '.mjs', '.cjs', '.jsx');
  Definition.LineComment := '//'; Definition.BlockCommentStart := '/*'; Definition.BlockCommentEnd := '*/';
  Definition.DocumentationLineComment := '/**'; Definition.StringDelimiters := '"' + #39 + '`'; Definition.CharacterDelimiters := '';
  Definition.AddKeywords(chtKeyword, TArray<string>.Create('new', 'this', 'super', 'typeof', 'instanceof', 'delete', 'void', 'in', 'of', 'extends', 'debugger', 'with'));
  Definition.AddKeywords(chtControlKeyword, TArray<string>.Create('if', 'else', 'switch', 'case', 'default', 'break', 'continue', 'return', 'throw', 'try', 'catch', 'finally', 'yield', 'await'));
  Definition.AddKeywords(chtModifierKeyword, TArray<string>.Create('var', 'let', 'const', 'async', 'static'));
  Definition.AddKeywords(chtAccessorKeyword, TArray<string>.Create('get', 'set'));
  Definition.AddKeywords(chtTypeKeyword, TArray<string>.Create('String', 'Number', 'Boolean', 'BigInt', 'Symbol', 'Object', 'Array', 'Map', 'Set', 'Promise', 'Date', 'RegExp'));
  Definition.AddKeywords(chtBoolean, TArray<string>.Create('true', 'false'));
  Definition.AddKeywords(chtNull, TArray<string>.Create('null', 'undefined'));
  Definition.AddKeywords(chtImportKeyword, TArray<string>.Create('import', 'export', 'from', 'require'));
  Definition.AddDeclaration('function', chtDeclarationKeyword, chtFunctionName);
  Definition.AddDeclaration('class', chtDeclarationKeyword, chtClassName);
  ConfigureCodeEditorLanguage(Definition); Registry.RegisterLanguage(Language);
  Definition := TCodeLanguageDefinition.Create; Language := Definition;
  Definition.Name := 'markdown'; Definition.DisplayName := 'Markdown'; Definition.CaseSensitive := True;
  Definition.FileExtensions := TArray<string>.Create('.md', '.markdown', '.mdown'); Definition.StringDelimiters := ''; Definition.CharacterDelimiters := '';
  Registry.RegisterLanguage(Language);
  Definition := TCodeLanguageDefinition.Create; Language := Definition;
  Definition.Name := 'batch'; Definition.DisplayName := 'Batch'; Definition.CaseSensitive := False;
  Definition.FileExtensions := TArray<string>.Create('.bat', '.cmd'); Definition.StringDelimiters := '"'; Definition.CharacterDelimiters := '';
  Definition.AddKeywords(chtKeyword, TArray<string>.Create('echo', 'set', 'setlocal', 'endlocal', 'call', 'goto', 'exit', 'shift', 'start', 'pause', 'title', 'cd', 'pushd', 'popd', 'copy', 'move', 'del', 'mkdir', 'rmdir', 'type', 'find', 'findstr', 'where'));
  Definition.AddKeywords(chtControlKeyword, TArray<string>.Create('if', 'else', 'exist', 'defined', 'errorlevel', 'not', 'in'));
  Definition.AddKeywords(chtLoopKeyword, TArray<string>.Create('for', 'do'));
  Registry.RegisterLanguage(Language);
end;

end.

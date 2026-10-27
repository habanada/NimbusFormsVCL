const fs = require('fs');
const path = require('path');
const root = fs.realpathSync(path.resolve(__dirname, '../..'));
if (!fs.existsSync(path.join(root, 'NimbusForms.Controls', 'src')) || !fs.existsSync(path.join(root, 'LICENSE'))) throw Error('Repository root not found');
const reference = path.join(root, 'NimbusFormsC#', 'Controls', 'VsIDE', 'CodeEditor');
const target = path.join(root, 'NimbusForms.Controls', 'src');
function read(relative) {
  const file = fs.realpathSync(path.join(reference, relative));
  if (!file.startsWith(reference + path.sep)) throw Error('Invalid reference path');
  return fs.readFileSync(file, 'utf8');
}
function write(name, text) {
  const dir = fs.realpathSync(target);
  if (!dir.startsWith(root + path.sep)) throw Error('Invalid target');
  fs.writeFileSync(path.join(dir, name), text.replace(/\r\n|\r|\n/g, '\r\n'), 'utf8');
}
const enumPrefixes = {CodeEditorNewLineMode:'cnm',CodeEditorNewLineKind:'cnk',CodeEditorInvisibleCharacters:'cic',CodeEditorDocumentIssueFlags:'cdi',CodeEditorTextCleanupOptions:'ctc',CodeEditorHitArea:'cha',CodeEditorTextRenderBackend:'crb',CodeEditorCaretStyle:'ccs',CodeEditorSelectionMode:'csm',CodeEditorCompletionItemKind:'cci',CodeEditorCompletionTrigger:'cct',CodeEditorHighlightTokenKind:'cht',CodeEditorDiagnosticSeverity:'cds'};
let types = 'unit NimbusForms.Controls.CodeEditor.Types;\n\ninterface\n\nuses System.Classes, System.SysUtils, System.Types, Vcl.Graphics;\n\ntype\n';
const enums = read('ThemedCodeEditorTypes.cs');
for (const m of enums.matchAll(/public enum (\w+)\s*\{([^}]+)\}/g)) {
  const members = m[2].split(',').map(s=>s.trim().split(/\s*=/)[0]).filter(Boolean);
  const flags = m[1].match(/InvisibleCharacters|IssueFlags|CleanupOptions/);
  const values = (flags ? members.filter(s=>s!=='None'&&s!=='All') : members).map(s=>enumPrefixes[m[1]]+s);
  if(m[1]==='CodeEditorHighlightTokenKind') values.push(...['ImportKeyword','ImportName','LoopKeyword','BlockKeyword','ResultName','XmlDocTag','XmlDocAttribute','XmlDocValue','MarkdownHeading','MarkdownEmphasis','MarkdownLink','MarkdownCode'].map(s=>'cht'+s));
  if(m[1]==='CodeEditorHitArea') values.push('chaBreakpointGutter');
  types += `  T${m[1]}${flags?'Item':''} = (${values.join(', ')});\n`;
  if (flags) types += `  T${m[1]} = set of T${m[1]}Item;\n`;
}
types += `
  TCodeDocumentPosition = record
    LineIndex, ColumnIndex: Integer;
    class function Create(const ALine, AColumn: Integer): TCodeDocumentPosition; static;
    function Compare(const Other: TCodeDocumentPosition): Integer;
  end;
  TCodeDocumentRange = record
    Start, Finish: TCodeDocumentPosition;
    class function Create(const AStart, AFinish: TCodeDocumentPosition): TCodeDocumentRange; static;
    function IsEmpty: Boolean;
    function Contains(const Position: TCodeDocumentPosition): Boolean;
  end;
  TCodeHighlightSpan = record
    Start, Length: Integer;
    Kind: TCodeEditorHighlightTokenKind;
  end;
  TCodeHighlightBinding = record
    Name: string;
    Kind: TCodeEditorHighlightTokenKind;
  end;
  TCodeHighlightState = record
    BlockEnd: string;
    BlockDepth: Integer;
    RawStringEnd: string;
    StringQuote: Char;
    Verbatim: Boolean;
    DocumentationBlock: Boolean;
    Section: string;
    InRoutine: Boolean;
    ParameterDepth: Integer;
    MarkdownFence: string;
    Bindings: TArray<TCodeHighlightBinding>;
  end;
  TCodeSearchOptions = record
    Pattern: string;
    MatchCase, WholeWord, UseRegex: Boolean;
    MaxResults: Integer;
    class function Create(const APattern: string): TCodeSearchOptions; static;
  end;
  TCodeSearchMatch = record
    Range: TCodeDocumentRange;
    Text: string;
  end;
  TCodeCompletionItem = record
    DisplayText, InsertText, Description, FilterText, SortText: string;
    Kind: TCodeEditorCompletionItemKind;
    Priority: Integer;
    Image: Vcl.Graphics.TBitmap;
  end;
  TCodeDiagnostic = record
    Range: TCodeDocumentRange;
    Severity: TCodeEditorDiagnosticSeverity;
    MessageText, Code, Source: string;
  end;
  TCodeBracketPair = record
    OpenPosition, ClosePosition: TCodeDocumentPosition;
    OpenChar, CloseChar: Char;
    Depth, ColorIndex: Integer;
  end;
  TCodeFoldRegion = record
    Range: TCodeDocumentRange;
    Text, PreviewText: string;
    IsCollapsed: Boolean;
  end;
  TCodeBookmark = record
    LineIndex: Integer;
    Name: string;
  end;
  TCodeEditorSymbolKind = (cskUnknown, cskNamespace, cskModule, cskClass, cskStruct, cskInterface,
    cskEnum, cskDelegate, cskConstructor, cskMethod, cskFunction, cskProcedure, cskProperty,
    cskField, cskEvent, cskVariable, cskConstant, cskParameter, cskLabel, cskRegion);
  TCodeEditorSymbolInfo = record
    Name, SignatureText, FullText, LanguageName: string;
    Kind: TCodeEditorSymbolKind;
    NameRange, DeclarationRange, BodyRange: TCodeDocumentRange;
    ParentIndex: Integer;
    Children: TArray<Integer>;
  end;
  TCodeEditorWordHitInfo = record
    Word: string;
    Range: TCodeDocumentRange;
    Position: TCodeDocumentPosition;
  end;
  TCodeEditorQuickInfo = record
    Title, Caption, Description, SignatureText, Footer: string;
    Tag: TObject;
    Range: TCodeDocumentRange;
  end;
  TCodeEditorNavigationResult = record
    Found, Success: Boolean;
    FileName: string;
    Range: TCodeDocumentRange;
    Symbol: TCodeEditorSymbolInfo;
  end;
  TCodeEditorHitInfo = record
    Area: TCodeEditorHitArea;
    Position: TCodeDocumentPosition;
    VisualIndex: Integer;
  end;
  TCodeEditorStatusInfo = record
    Line, Column, SelectionLength, SelectionLineCount, LineCount, TextLength: Integer;
    LanguageName, EncodingName, EncodingReason, FileName: string;
    HasByteOrderMark, EncodingConfidenceHigh, HasMixedNewLines, IsModified, IsReadOnly, IsLargeFile: Boolean;
    LoadedByteLength: Int64;
    NewLineKind: TCodeEditorNewLineKind;
    Issues: TCodeEditorDocumentIssueFlags;
  end;
  TCodePositionEvent = procedure(Sender: TObject; const Position: TCodeDocumentPosition) of object;
  TCodeWordEvent = procedure(Sender: TObject; const Word: TCodeEditorWordHitInfo) of object;
  TCodeNavigationEvent = procedure(Sender: TObject; const Word: TCodeEditorWordHitInfo;
    var Result: TCodeEditorNavigationResult; var Handled: Boolean) of object;
  TCodeQuickInfoEvent = procedure(Sender: TObject; const Word: TCodeEditorWordHitInfo;
    var Info: TCodeEditorQuickInfo; var Handled: Boolean) of object;
  TCodeCompletionEvent = procedure(Sender: TObject; const Position: TCodeDocumentPosition;
    var Items: TArray<TCodeCompletionItem>) of object;

function CodeIsWord(const C: Char): Boolean;
function CodeNormalizeNewLines(const Text: string): string;

implementation

uses System.Character;

class function TCodeDocumentPosition.Create(const ALine, AColumn: Integer): TCodeDocumentPosition;
begin Result.LineIndex := ALine; Result.ColumnIndex := AColumn; end;

function TCodeDocumentPosition.Compare(const Other: TCodeDocumentPosition): Integer;
begin
  if LineIndex < Other.LineIndex then Exit(-1);
  if LineIndex > Other.LineIndex then Exit(1);
  if ColumnIndex < Other.ColumnIndex then Exit(-1);
  if ColumnIndex > Other.ColumnIndex then Exit(1);
  Result := 0;
end;

class function TCodeDocumentRange.Create(const AStart, AFinish: TCodeDocumentPosition): TCodeDocumentRange;
begin
  if AStart.Compare(AFinish) <= 0 then begin Result.Start := AStart; Result.Finish := AFinish; end
  else begin Result.Start := AFinish; Result.Finish := AStart; end;
end;

function TCodeDocumentRange.IsEmpty: Boolean;
begin Result := Start.Compare(Finish) = 0; end;

function TCodeDocumentRange.Contains(const Position: TCodeDocumentPosition): Boolean;
begin Result := (Start.Compare(Position) <= 0) and (Finish.Compare(Position) > 0); end;

class function TCodeSearchOptions.Create(const APattern: string): TCodeSearchOptions;
begin Result := Default(TCodeSearchOptions); Result.Pattern := APattern; end;

function CodeIsWord(const C: Char): Boolean;
begin Result := C.IsLetterOrDigit or CharInSet(C, ['_', '$', '@']); end;

function CodeNormalizeNewLines(const Text: string): string;
begin Result := Text.Replace(#13#10, #10).Replace(#13, #10); end;

end.
`;
const originalSymbolKinds=read('LanguageServices/CodeEditorSymbolKind.cs').match(/public enum CodeEditorSymbolKind\s*\{([^}]+)\}/)[1].split(',').map(s=>s.trim()).filter(Boolean);
types=types.replace(/TCodeEditorSymbolKind = \([^;]+;/, 'TCodeEditorSymbolKind = ('+originalSymbolKinds.map(s=>'csk'+s).join(', ')+');');
write('NimbusForms.Controls.CodeEditor.Types.pas', types);
const options = read('ThemedCodeEditorOptions.cs');
const fields = [...options.matchAll(/private (int|long|bool) _(\w+);/g)].map(m=>({kind:m[1]==='bool'?'Boolean':m[1]==='long'?'Int64':'Integer',name:m[2][0].toUpperCase()+m[2].slice(1),key:m[2]}));
fields.push({kind:'Boolean',name:'ShowBreakpoints',key:'showBreakpoints',defaultValue:'true'});
let opt = 'unit NimbusForms.Controls.CodeEditor.Options;\n\ninterface\n\nuses System.Classes, System.SysUtils, NimbusForms.Controls.CodeEditor.Types;\n\ntype\n  TThemedCodeEditorOptions = class(TPersistent)\n  private\n';
for(const f of fields) opt+=`    F${f.name}: ${f.kind};\n`;
opt+='    FInvisibleCharacters: TCodeEditorInvisibleCharacters;\n    FOnChange: TNotifyEvent;\n';
for(const f of fields) opt+=`    procedure Set${f.name}(const Value: ${f.kind});\n`;
opt+='    procedure SetInvisibleCharacters(const Value: TCodeEditorInvisibleCharacters);\n    function GetInvisible(const Index: Integer): Boolean;\n    procedure SetInvisible(const Index: Integer; const Value: Boolean);\n  public\n    constructor Create(const OnChange: TNotifyEvent);\n    procedure Assign(Source: TPersistent); override;\n  published\n';
for(const f of fields) {
  const m=options.split('[DefaultValue')[0].match(new RegExp('_'+f.key+' = ([^;]+);'));
  const v=m?m[1]:f.defaultValue || (f.kind==='Boolean'?'false':'0');
  f.default=v.replace(/L/g,'').replace(/true/g,'True').replace(/false/g,'False');
  opt+=`    property ${f.name}: ${f.kind} read F${f.name} write Set${f.name} default ${f.default};\n`;
}
opt+='    property InvisibleCharacters: TCodeEditorInvisibleCharacters read FInvisibleCharacters write SetInvisibleCharacters default [];\n';
for(const [name,index]of [['ShowSpaces',0],['ShowTabs',1],['ShowEndOfLine',2],['ShowTrailingSpaces',3],['ShowWhitespace',4]]) opt+=`    property ${name}: Boolean index ${index} read GetInvisible write SetInvisible default False;\n`;
opt+='  end;\n\nimplementation\n\nuses System.Math;\n\nconstructor TThemedCodeEditorOptions.Create(const OnChange: TNotifyEvent);\nbegin\n  inherited Create; FOnChange := OnChange;\n';
for(const f of fields) opt+=`  F${f.name} := ${f.default};\n`;
opt+='end;\n\nprocedure TThemedCodeEditorOptions.Assign(Source: TPersistent);\nvar Other: TThemedCodeEditorOptions;\nbegin\n  if not (Source is TThemedCodeEditorOptions) then begin inherited; Exit; end;\n  Other := TThemedCodeEditorOptions(Source);\n';
for(const f of fields) opt+=`  F${f.name} := Other.F${f.name};\n`;
opt+='  FInvisibleCharacters := Other.FInvisibleCharacters;\n  if Assigned(FOnChange) then FOnChange(Self);\nend;\n';
for(const f of fields) {
  let clamp='Value';
  if(f.kind!=='Boolean') clamp=`Max(${f.name==='CompletionItemHeight'?16:['TabSize','IndentSize'].includes(f.name)?1:0}, Value)`;
  opt+=`\nprocedure TThemedCodeEditorOptions.Set${f.name}(const Value: ${f.kind});\nvar Next: ${f.kind};\nbegin\n  Next := ${clamp};\n  if F${f.name} = Next then Exit;\n  F${f.name} := Next;\n  if Assigned(FOnChange) then FOnChange(Self);\nend;\n`;
}
opt+=`\nprocedure TThemedCodeEditorOptions.SetInvisibleCharacters(const Value: TCodeEditorInvisibleCharacters);
begin
  if FInvisibleCharacters = Value then Exit;
  FInvisibleCharacters := Value;
  if Assigned(FOnChange) then FOnChange(Self);
end;

function TThemedCodeEditorOptions.GetInvisible(const Index: Integer): Boolean;
begin
  if Index = 4 then Result := FInvisibleCharacters * [cicSpaces, cicTabs] <> []
  else Result := TCodeEditorInvisibleCharactersItem(Index) in FInvisibleCharacters;
end;

procedure TThemedCodeEditorOptions.SetInvisible(const Index: Integer; const Value: Boolean);
var Next, Mask: TCodeEditorInvisibleCharacters;
begin
  Next := FInvisibleCharacters;
  if Index = 4 then Mask := [cicSpaces, cicTabs] else Mask := [TCodeEditorInvisibleCharactersItem(Index)];
  if Value then Next := Next + Mask else Next := Next - Mask;
  SetInvisibleCharacters(Next);
end;

end.
`;
write('NimbusForms.Controls.CodeEditor.Options.pas',opt);
const theme = read('ThemedCodeEditorTheme.cs');
const colors=[...theme.matchAll(/public Color (\w+) \{/g)].map(m=>m[1]);
const extraColors={ImportKeywordColor:0xC586C0,ImportNameColor:0xD7BA7D,LoopKeywordColor:0xD7BA7D,BlockKeywordColor:0xC586C0,ResultColor:0xCE9178,XmlDocTagColor:0x569CD6,XmlDocAttributeColor:0x9CDCFE,XmlDocValueColor:0xCE9178,MarkdownHeadingColor:0x569CD6,MarkdownEmphasisColor:0xC586C0,MarkdownLinkColor:0x4EC9B0,MarkdownCodeColor:0xCE9178,BreakpointColor:0xE35B66,DisabledBreakpointColor:0x9B9B9B,ExecutionLineColor:0xFFD700};
extraColors.InfoColor=0x3F9AD8;
colors.push(...Object.keys(extraColors));
let th='unit NimbusForms.Controls.CodeEditor.Theme;\n\ninterface\n\nuses System.Classes, NimbusForms.Theming.Types, NimbusForms.Theming.Palette, NimbusForms.Controls.CodeEditor.Types;\n\ntype\n  TThemedCodeEditorTheme = class(TPersistent)\n  private\n    FColors: array[0..'+(colors.length-1)+'] of TThemeColor;\n    FOnChange: TNotifyEvent;\n    function GetColor(const Index: Integer): TThemeColor;\n    procedure SetColor(const Index: Integer; const Value: TThemeColor);\n  public\n    constructor Create(const OnChange: TNotifyEvent);\n    procedure Assign(Source: TPersistent); override;\n    function TokenColor(const Kind: TCodeEditorHighlightTokenKind; const Palette: TThemePalette): TThemeColor;\n    function Resolve(const Custom, DefaultColor: TThemeColor): TThemeColor;\n  published\n';
colors.forEach((c,i)=>th+=`    property ${c}: TThemeColor index ${i} read GetColor write SetColor default 0;\n`);
th+='  end;\n\nimplementation\n\nuses NimbusForms.Rendering.Types;\n\nconstructor TThemedCodeEditorTheme.Create(const OnChange: TNotifyEvent);\nbegin inherited Create; FOnChange := OnChange; end;\n\nprocedure TThemedCodeEditorTheme.Assign(Source: TPersistent);\nbegin\n  if not (Source is TThemedCodeEditorTheme) then begin inherited; Exit; end;\n  FColors := TThemedCodeEditorTheme(Source).FColors;\n  if Assigned(FOnChange) then FOnChange(Self);\nend;\n\nfunction TThemedCodeEditorTheme.GetColor(const Index: Integer): TThemeColor;\nbegin Result := FColors[Index]; end;\n\nprocedure TThemedCodeEditorTheme.SetColor(const Index: Integer; const Value: TThemeColor);\nbegin\n  if FColors[Index] = Value then Exit;\n  FColors[Index] := Value;\n  if Assigned(FOnChange) then FOnChange(Self);\nend;\n\nfunction TThemedCodeEditorTheme.Resolve(const Custom, DefaultColor: TThemeColor): TThemeColor;\nbegin if Custom <> 0 then Result := Custom else Result := DefaultColor; end;\n\nfunction TThemedCodeEditorTheme.TokenColor(const Kind: TCodeEditorHighlightTokenKind; const Palette: TThemePalette): TThemeColor;\nbegin\n  Result := Resolve(ForeColor, NimbusControlForeColor(Palette));\n  case Kind of\n';
const tokenNames=[...enums.matchAll(/public enum CodeEditorHighlightTokenKind\s*\{([^}]+)\}/g)][0][1].split(',').map(s=>s.trim());
for(const token of tokenNames) {
  let name=token.replace(/Name$/,'')+'Color';
  if(token==='XmlDocComment') name='XmlDocColor';
  if(!colors.includes(name)) continue;
  const m=theme.match(new RegExp(name+' = Color.FromArgb\\(([^)]+)\\)'));
  if(!m) continue;
  let rgb=m[1].split(',').map(s=>s.trim());
  if(token==='TypeKeyword') rgb=[79,193,255];
  if(token==='ParameterName') rgb=[255,201,163];
  if(token==='ConstantName') rgb=[220,220,170];
  th+=`    cht${token}: Result := Resolve(${name}, ThemeColor(255, ${rgb.join(', ')}));\n`;
}
for(const token of ['ImportKeyword','ImportName','LoopKeyword','BlockKeyword','ResultName','XmlDocTag','XmlDocAttribute','XmlDocValue','MarkdownHeading','MarkdownEmphasis','MarkdownLink','MarkdownCode']) {
  const prop=(token==='ResultName'?'Result':token)+'Color',c=extraColors[prop];
  th+=`    cht${token}: Result := Resolve(${prop}, $FF${c.toString(16).toUpperCase().padStart(6,'0')});\n`;
}
th+='  end;\nend;\n\nend.\n';
write('NimbusForms.Controls.CodeEditor.Theme.pas',th);
console.log('Generated types, all C# option defaults and all theme properties');
function pas(value) { return "'"+value.replace(/'/g,"''")+"'"; }
function strings(value) { return [...value.matchAll(/"(?:\\.|[^"\\])*"/g)].map(m=>JSON.parse(m[0])); }
let builtins='unit NimbusForms.Controls.CodeEditor.Languages;\n\ninterface\n\nuses NimbusForms.Controls.CodeEditor.Syntax;\n\nprocedure RegisterCodeEditorLanguages(Registry: TCodeLanguageRegistry);\n\nimplementation\n\nuses System.SysUtils, NimbusForms.Controls.CodeEditor.Types, NimbusForms.Controls.CodeEditor.LanguageExtensions;\n\nprocedure RegisterCodeEditorLanguages(Registry: TCodeLanguageRegistry);\nvar Definition: TCodeLanguageDefinition; Language: ICodeLanguageDefinition;\nbegin\n';
for(const file of ['CSharp','Delphi','VisualBasic','PowerShell','Cpp','Java','Perl','AutoIt']) {
  const code=read('Highlighting/'+file+'LanguageDefinition.cs');
  builtins+='  Definition := TCodeLanguageDefinition.Create; Language := Definition;\n';
  for(const prop of ['Name','DisplayName']) {
    const m=code.match(new RegExp('string '+prop+' \\{ get \\{ return ("[^"\\n]+")'));
    if(!m) throw Error('Missing '+prop+': '+file);
    builtins+=`  Definition.${prop} := ${pas(JSON.parse(m[1]))};\n`;
  }
  const ext=code.match(/FileExtensions[^\n]+new string\[\] \{([^}]+)\}/);
  if(!ext) throw Error('Missing extensions '+file);
  builtins+=`  Definition.FileExtensions := TArray<string>.Create(${strings(ext[1]).map(pas).join(', ')});\n`;
  for(const prop of ['LineComment','BlockCommentStart','BlockCommentEnd','DocumentationLineComment','PreprocessorPrefix']) {
    const m=code.match(new RegExp(prop+' = ("(?:\\\\.|[^"\\\\])*");'));
    if(m) builtins+=`  Definition.${prop} := ${pas(JSON.parse(m[1]))};\n`;
  }
  const sensitive=code.match(/CaseSensitive[^\n]+return (true|false)/);
  if(sensitive) builtins+=`  Definition.CaseSensitive := ${sensitive[1]==='true'?'True':'False'};\n`;
  for(const prop of ['StringDelimiters','CharacterDelimiters']) {
    const m=code.match(new RegExp(prop+' = new char\\[\\] \\{([^}]+)\\}'));
    if(m) {
      const chars=[...m[1].matchAll(/'((?:\\.|[^'])*)'/g)].map(c=>c[1].replace(/\\'/g,"'").replace(/\\"/g,'"').replace(/\\\\/g,'\\')).join('');
      builtins+=`  Definition.${prop} := ${pas(chars)};\n`;
    } else if(code.includes(prop+' = new char[0]')) builtins+=`  Definition.${prop} := '';\n`;
  }
  for(const m of code.matchAll(/AddKeywords\(CodeEditorHighlightTokenKind\.(\w+),([^;]+)\);/g)) builtins+=`  Definition.AddKeywords(cht${m[1]}, TArray<string>.Create(${strings(m[2]).map(pas).join(', ')}));\n`;
  for(const m of code.matchAll(/AddDeclaration\(("[^"\n]+"), CodeEditorHighlightTokenKind\.(\w+), CodeEditorHighlightTokenKind\.(\w+)\)/g)) builtins+=`  Definition.AddDeclaration(${pas(JSON.parse(m[1]))}, cht${m[2]}, cht${m[3]});\n`;
  builtins+='  ConfigureCodeEditorLanguage(Definition);\n  Registry.RegisterLanguage(Language);\n';
}
builtins+='  RegisterAdditionalCodeEditorLanguages(Registry);\nend;\n\nend.\n';
write('NimbusForms.Controls.CodeEditor.Languages.pas',builtins);
console.log('Imported eight original C# language definitions with complete keyword sets');
const symbolCode=read('LanguageServices/CodeEditorSymbolPatternRegistry.cs');
let symbols='unit NimbusForms.Controls.CodeEditor.SymbolPatterns;\n\ninterface\n\nuses NimbusForms.Controls.CodeEditor.Services;\n\nprocedure RegisterCodeSymbolPatterns(Registry: TCodeEditorSymbolPatternRegistry);\n\nimplementation\n\nuses System.RegularExpressions, NimbusForms.Controls.CodeEditor.Types;\n\nprocedure RegisterCodeSymbolPatterns(Registry: TCodeEditorSymbolPatternRegistry);\nbegin\n';
let count=0;
for(const m of symbolCode.matchAll(/P\("(\w+)", "([^"\n]+)", @"((?:""|[^"\n])*)", CodeEditorSymbolKind\.(\w+), CodeEditorSymbolPatternBodyMode\.(\w+), ([oi]), (\d+)\)/g)) {
  const block=symbolCode.slice(0,m.index).split('private void ').pop();
  const ignore=block.includes('RegexOptions.IgnoreCase');
  symbols+=`  Registry.Add(${pas(m[1])}, ${pas(m[2])}, ${pas(m[3].replace(/""/g,'"'))}, csk${m[4]}, csb${m[5]}, ${ignore?'[roIgnoreCase]':'[]'}, ${m[7]});\n`;
  count++;
}
symbols+='end;\n\nend.\n';
write('NimbusForms.Controls.CodeEditor.SymbolPatterns.pas',symbols);
console.log('Imported '+count+' original symbol patterns');

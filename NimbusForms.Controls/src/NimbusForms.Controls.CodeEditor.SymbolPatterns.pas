{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.CodeEditor.SymbolPatterns;

interface

uses NimbusForms.Controls.CodeEditor.Services;

procedure RegisterCodeSymbolPatterns(Registry: TCodeEditorSymbolPatternRegistry);

implementation

uses System.RegularExpressions, NimbusForms.Controls.CodeEditor.Types;

procedure RegisterCodeSymbolPatterns(Registry: TCodeEditorSymbolPatternRegistry);
begin
  Registry.Add('csharp', 'namespace', '^\s*namespace\s+(?<name>[A-Za-z_][A-Za-z0-9_\.]*)', cskNamespace, csbBraceBlock, [], 100);
  Registry.Add('csharp', 'class', '^\s*(?:\[[^\]]+\]\s*)*(?:public|private|protected|internal|sealed|abstract|static|partial|unsafe|\s)*\s*class\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskClass, csbBraceBlock, [], 98);
  Registry.Add('csharp', 'struct', '^\s*(?:\[[^\]]+\]\s*)*(?:public|private|protected|internal|readonly|ref|partial|\s)*\s*struct\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskStruct, csbBraceBlock, [], 97);
  Registry.Add('csharp', 'interface', '^\s*(?:\[[^\]]+\]\s*)*(?:public|private|protected|internal|partial|\s)*\s*interface\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskInterface, csbBraceBlock, [], 96);
  Registry.Add('csharp', 'enum', '^\s*(?:\[[^\]]+\]\s*)*(?:public|private|protected|internal|\s)*\s*enum\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskEnum, csbBraceBlock, [], 95);
  Registry.Add('csharp', 'delegate', '^\s*(?:public|private|protected|internal|\s)*\s*delegate\s+[A-Za-z_][A-Za-z0-9_<>,\[\]\.?]*\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)\s*\(', cskDelegate, csbDeclarationLine, [], 94);
  Registry.Add('csharp', 'event', '^\s*(?:public|private|protected|internal|static|virtual|override|abstract|sealed|\s)+event\s+[A-Za-z_][A-Za-z0-9_<>,\[\]\.?]*\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskEvent, csbDeclarationLine, [], 85);
  Registry.Add('csharp', 'property', '^\s*(?:\[[^\]]+\]\s*)*(?:public|private|protected|internal|static|virtual|override|abstract|sealed|readonly|unsafe|new|\s)+[A-Za-z_][A-Za-z0-9_<>,\[\]\.?]*\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)\s*\{\s*(?:get|set|init)\b', cskProperty, csbBraceBlock, [], 82);
  Registry.Add('csharp', 'method', '^\s*(?:\[[^\]]+\]\s*)*(?:public|private|protected|internal|static|virtual|override|abstract|sealed|async|extern|unsafe|partial|new|\s)+[A-Za-z_][A-Za-z0-9_<>,\[\]\.?]*\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)\s*(?:<[^>]+>)?\s*\([^;]*\)\s*(?:where\b.*)?(?:\{|$)', cskMethod, csbBraceBlock, [], 80);
  Registry.Add('csharp', 'constructor', '^\s*(?:public|private|protected|internal|static|\s)+(?<name>[A-Za-z_][A-Za-z0-9_]*)\s*\([^;]*\)\s*(?::\s*(?:base|this)\s*\([^)]*\))?\s*(?:\{|$)', cskConstructor, csbBraceBlock, [], 79);
  Registry.Add('csharp', 'constant', '^\s*(?:public|private|protected|internal|static|\s)*const\s+[A-Za-z_][A-Za-z0-9_<>,\[\]\.?]*\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)\s*(?:=|;)', cskConstant, csbDeclarationLine, [], 70);
  Registry.Add('csharp', 'field', '^\s*(?:public|private|protected|internal|static|readonly|volatile|unsafe|new|\s)+[A-Za-z_][A-Za-z0-9_<>,\[\]\.?]*\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)\s*(?:=|;)', cskField, csbDeclarationLine, [], 60);
  Registry.Add('cpp', 'namespace', '^\s*namespace\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskNamespace, csbBraceBlock, [], 100);
  Registry.Add('cpp', 'class', '^\s*(?:template\s*<[^>]+>\s*)?(?:class)\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskClass, csbBraceBlock, [], 98);
  Registry.Add('cpp', 'struct', '^\s*(?:template\s*<[^>]+>\s*)?(?:struct)\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskStruct, csbBraceBlock, [], 97);
  Registry.Add('cpp', 'union', '^\s*(?:union)\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskStruct, csbBraceBlock, [], 96);
  Registry.Add('cpp', 'enum', '^\s*enum\s+(?:class\s+)?(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskEnum, csbBraceBlock, [], 95);
  Registry.Add('cpp', 'function', '^\s*(?:template\s*<[^>]+>\s*)?(?:inline|static|virtual|extern|constexpr|consteval|friend|explicit|\s)*[A-Za-z_~][A-Za-z0-9_:<>,\*\&\s]*\s+(?<name>[A-Za-z_~][A-Za-z0-9_:~]*)\s*\([^;]*\)\s*(?:const\s*)?(?:noexcept\s*)?(?:override\s*)?(?:final\s*)?(?:\{|$)', cskFunction, csbBraceBlock, [], 80);
  Registry.Add('cpp', 'field', '^\s*(?:static|const|constexpr|mutable|volatile|\s)*[A-Za-z_][A-Za-z0-9_:<>,\*\&\s]+\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)\s*(?:=|;)', cskField, csbDeclarationLine, [], 50);
  Registry.Add('java', 'package', '^\s*package\s+(?<name>[A-Za-z_][A-Za-z0-9_\.]*)\s*;', cskNamespace, csbDeclarationLine, [], 100);
  Registry.Add('java', 'class', '^\s*(?:public|private|protected|abstract|final|sealed|non-sealed|static|\s)*class\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskClass, csbBraceBlock, [], 98);
  Registry.Add('java', 'record', '^\s*(?:public|private|protected|static|final|\s)*record\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskClass, csbBraceBlock, [], 97);
  Registry.Add('java', 'interface', '^\s*(?:public|private|protected|abstract|static|\s)*interface\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskInterface, csbBraceBlock, [], 96);
  Registry.Add('java', 'enum', '^\s*(?:public|private|protected|static|\s)*enum\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskEnum, csbBraceBlock, [], 95);
  Registry.Add('java', 'method', '^\s*(?:public|private|protected|static|final|abstract|synchronized|native|strictfp|\s)+[A-Za-z_][A-Za-z0-9_<>,\[\]\.?]*\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)\s*\([^;]*\)\s*(?:throws\s+[^{]+)?(?:\{|$)', cskMethod, csbBraceBlock, [], 80);
  Registry.Add('java', 'field', '^\s*(?:public|private|protected|static|final|volatile|transient|\s)+[A-Za-z_][A-Za-z0-9_<>,\[\]\.?]*\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)\s*(?:=|;)', cskField, csbDeclarationLine, [], 50);
  Registry.Add('javascript', 'class', '^\s*(?:export\s+default\s+|export\s+)?class\s+(?<name>[A-Za-z_$][A-Za-z0-9_$]*)', cskClass, csbBraceBlock, [], 100);
  Registry.Add('javascript', 'function', '^\s*(?:export\s+default\s+|export\s+|async\s+)*function\s+(?<name>[A-Za-z_$][A-Za-z0-9_$]*)\s*\(', cskFunction, csbBraceBlock, [], 95);
  Registry.Add('javascript', 'arrow', '^\s*(?:export\s+)?(?:const|let|var)\s+(?<name>[A-Za-z_$][A-Za-z0-9_$]*)\s*=\s*(?:async\s*)?(?:\([^)]*\)|[A-Za-z_$][A-Za-z0-9_$]*)\s*=>', cskFunction, csbBraceBlock, [], 92);
  Registry.Add('javascript', 'method', '^\s*(?:async\s+|static\s+|get\s+|set\s+)*(?<name>[A-Za-z_$][A-Za-z0-9_$]*)\s*\([^)]*\)\s*\{', cskMethod, csbBraceBlock, [], 70);
  Registry.Add('javascript', 'variable', '^\s*(?:export\s+)?(?:const|let|var)\s+(?<name>[A-Za-z_$][A-Za-z0-9_$]*)\s*(?:=|;)', cskVariable, csbDeclarationLine, [], 50);
  Registry.Add('typescript', 'namespace', '^\s*(?:export\s+)?namespace\s+(?<name>[A-Za-z_$][A-Za-z0-9_$]*)', cskNamespace, csbBraceBlock, [], 100);
  Registry.Add('typescript', 'interface', '^\s*(?:export\s+)?interface\s+(?<name>[A-Za-z_$][A-Za-z0-9_$]*)', cskInterface, csbBraceBlock, [], 98);
  Registry.Add('typescript', 'class', '^\s*(?:export\s+default\s+|export\s+)?(?:abstract\s+)?class\s+(?<name>[A-Za-z_$][A-Za-z0-9_$]*)', cskClass, csbBraceBlock, [], 97);
  Registry.Add('typescript', 'enum', '^\s*(?:export\s+)?enum\s+(?<name>[A-Za-z_$][A-Za-z0-9_$]*)', cskEnum, csbBraceBlock, [], 96);
  Registry.Add('typescript', 'function', '^\s*(?:export\s+default\s+|export\s+|async\s+)*function\s+(?<name>[A-Za-z_$][A-Za-z0-9_$]*)\s*(?:<[^>]+>)?\s*\(', cskFunction, csbBraceBlock, [], 95);
  Registry.Add('typescript', 'arrow', '^\s*(?:export\s+)?(?:const|let|var)\s+(?<name>[A-Za-z_$][A-Za-z0-9_$]*)\s*(?::[^=]+)?=\s*(?:async\s*)?(?:\([^)]*\)|[A-Za-z_$][A-Za-z0-9_$]*)\s*=>', cskFunction, csbBraceBlock, [], 92);
  Registry.Add('typescript', 'method', '^\s*(?:public|private|protected|static|async|abstract|override|readonly|get|set|\s)*(?<name>[A-Za-z_$][A-Za-z0-9_$]*)\s*(?:<[^>]+>)?\s*\([^)]*\)\s*(?::[^{]+)?\{', cskMethod, csbBraceBlock, [], 70);
  Registry.Add('typescript', 'property', '^\s*(?:public|private|protected|static|readonly|\s)*(?<name>[A-Za-z_$][A-Za-z0-9_$]*)\s*[?:!]*\s*:\s*[^;]+;?', cskProperty, csbDeclarationLine, [], 50);
  Registry.Add('python', 'class', '^\s*class\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskClass, csbIndentationBlock, [], 100);
  Registry.Add('python', 'function', '^\s*(?:async\s+)?def\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)\s*\(', cskFunction, csbIndentationBlock, [], 95);
  Registry.Add('python', 'variable', '^\s*(?<name>[A-Za-z_][A-Za-z0-9_]*)\s*=', cskVariable, csbDeclarationLine, [], 30);
  Registry.Add('delphi', 'unit', '^\s*unit\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskModule, csbPascalBlock, [roIgnoreCase], 100);
  Registry.Add('delphi', 'class', '^\s*(?<name>[A-Za-z_][A-Za-z0-9_]*)\s*=\s*class\b', cskClass, csbPascalBlock, [roIgnoreCase], 98);
  Registry.Add('delphi', 'record', '^\s*(?<name>[A-Za-z_][A-Za-z0-9_]*)\s*=\s*(?:packed\s+)?record\b', cskStruct, csbPascalBlock, [roIgnoreCase], 97);
  Registry.Add('delphi', 'interface', '^\s*(?<name>[A-Za-z_][A-Za-z0-9_]*)\s*=\s*interface\b', cskInterface, csbPascalBlock, [roIgnoreCase], 96);
  Registry.Add('delphi', 'procedure', '^\s*(?:class\s+)?procedure\s+(?<name>[A-Za-z_][A-Za-z0-9_\.]*)', cskProcedure, csbPascalBlock, [roIgnoreCase], 95);
  Registry.Add('delphi', 'function', '^\s*(?:class\s+)?function\s+(?<name>[A-Za-z_][A-Za-z0-9_\.]*)', cskFunction, csbPascalBlock, [roIgnoreCase], 94);
  Registry.Add('delphi', 'constructor', '^\s*constructor\s+(?<name>[A-Za-z_][A-Za-z0-9_\.]*)', cskConstructor, csbPascalBlock, [roIgnoreCase], 93);
  Registry.Add('delphi', 'destructor', '^\s*destructor\s+(?<name>[A-Za-z_][A-Za-z0-9_\.]*)', cskProcedure, csbPascalBlock, [roIgnoreCase], 92);
  Registry.Add('delphi', 'property', '^\s*property\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskProperty, csbDeclarationLine, [roIgnoreCase], 60);
  Registry.Add('vb', 'namespace', '^\s*Namespace\s+(?<name>[A-Za-z_][A-Za-z0-9_\.]*)', cskNamespace, csbPascalBlock, [roIgnoreCase], 100);
  Registry.Add('vb', 'module', '^\s*(?:Public|Private|Friend|\s)*Module\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskModule, csbPascalBlock, [roIgnoreCase], 98);
  Registry.Add('vb', 'class', '^\s*(?:Public|Private|Friend|Protected|Partial|MustInherit|NotInheritable|\s)*Class\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskClass, csbPascalBlock, [roIgnoreCase], 97);
  Registry.Add('vb', 'structure', '^\s*(?:Public|Private|Friend|Protected|Partial|\s)*Structure\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskStruct, csbPascalBlock, [roIgnoreCase], 96);
  Registry.Add('vb', 'interface', '^\s*(?:Public|Private|Friend|Protected|Partial|\s)*Interface\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskInterface, csbPascalBlock, [roIgnoreCase], 95);
  Registry.Add('vb', 'enum', '^\s*(?:Public|Private|Friend|Protected|\s)*Enum\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskEnum, csbPascalBlock, [roIgnoreCase], 94);
  Registry.Add('vb', 'sub', '^\s*(?:Public|Private|Friend|Protected|Shared|Overrides|Overridable|MustOverride|Async|Iterator|\s)*Sub\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskProcedure, csbPascalBlock, [roIgnoreCase], 90);
  Registry.Add('vb', 'function', '^\s*(?:Public|Private|Friend|Protected|Shared|Overrides|Overridable|MustOverride|Async|Iterator|\s)*Function\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskFunction, csbPascalBlock, [roIgnoreCase], 89);
  Registry.Add('vb', 'property', '^\s*(?:Public|Private|Friend|Protected|Shared|Overrides|Overridable|ReadOnly|WriteOnly|\s)*Property\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskProperty, csbPascalBlock, [roIgnoreCase], 80);
  Registry.Add('vb', 'event', '^\s*(?:Public|Private|Friend|Protected|Shared|\s)*Event\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskEvent, csbDeclarationLine, [roIgnoreCase], 70);
  Registry.Add('sql', 'procedure', '^\s*(?:CREATE|ALTER)\s+(?:OR\s+ALTER\s+)?(?:PROCEDURE|PROC)\s+(?<name>[A-Za-z0-9_\.\[\]"`]+)', cskProcedure, csbSqlBlock, [roIgnoreCase], 100);
  Registry.Add('sql', 'function', '^\s*(?:CREATE|ALTER)\s+(?:OR\s+ALTER\s+)?FUNCTION\s+(?<name>[A-Za-z0-9_\.\[\]"`]+)', cskFunction, csbSqlBlock, [roIgnoreCase], 98);
  Registry.Add('sql', 'view', '^\s*(?:CREATE|ALTER)\s+(?:OR\s+ALTER\s+)?VIEW\s+(?<name>[A-Za-z0-9_\.\[\]"`]+)', cskModule, csbSqlBlock, [roIgnoreCase], 96);
  Registry.Add('sql', 'trigger', '^\s*(?:CREATE|ALTER)\s+(?:OR\s+ALTER\s+)?TRIGGER\s+(?<name>[A-Za-z0-9_\.\[\]"`]+)', cskEvent, csbSqlBlock, [roIgnoreCase], 94);
  Registry.Add('sql', 'table', '^\s*(?:CREATE|ALTER)\s+TABLE\s+(?<name>[A-Za-z0-9_\.\[\]"`]+)', cskStruct, csbSqlBlock, [roIgnoreCase], 90);
  Registry.Add('sql', 'cte', '^\s*(?:WITH|,)\s*(?<name>[A-Za-z_][A-Za-z0-9_]*)\s+AS\s*\(', cskVariable, csbBraceBlock, [roIgnoreCase], 50);
  Registry.Add('powershell', 'class', '^\s*class\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskClass, csbBraceBlock, [roIgnoreCase], 100);
  Registry.Add('powershell', 'enum', '^\s*enum\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskEnum, csbBraceBlock, [roIgnoreCase], 95);
  Registry.Add('powershell', 'function', '^\s*function\s+(?:global:|script:|local:)?(?<name>[A-Za-z_][A-Za-z0-9_\-]*)', cskFunction, csbBraceBlock, [roIgnoreCase], 90);
  Registry.Add('powershell', 'filter', '^\s*filter\s+(?<name>[A-Za-z_][A-Za-z0-9_\-]*)', cskFunction, csbBraceBlock, [roIgnoreCase], 88);
  Registry.Add('powershell', 'configuration', '^\s*configuration\s+(?<name>[A-Za-z_][A-Za-z0-9_\-]*)', cskModule, csbBraceBlock, [roIgnoreCase], 80);
  Registry.Add('perl', 'package', '^\s*package\s+(?<name>[A-Za-z_][A-Za-z0-9_:]*)', cskNamespace, csbDeclarationLine, [], 100);
  Registry.Add('perl', 'sub', '^\s*sub\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskFunction, csbBraceBlock, [], 90);
  Registry.Add('php', 'namespace', '^\s*namespace\s+(?<name>[A-Za-z_][A-Za-z0-9_\\]*)', cskNamespace, csbDeclarationLine, [roIgnoreCase], 100);
  Registry.Add('php', 'class', '^\s*(?:abstract\s+|final\s+)?class\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskClass, csbBraceBlock, [roIgnoreCase], 98);
  Registry.Add('php', 'trait', '^\s*trait\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskClass, csbBraceBlock, [roIgnoreCase], 97);
  Registry.Add('php', 'interface', '^\s*interface\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskInterface, csbBraceBlock, [roIgnoreCase], 96);
  Registry.Add('php', 'enum', '^\s*enum\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskEnum, csbBraceBlock, [roIgnoreCase], 95);
  Registry.Add('php', 'function', '^\s*(?:public|private|protected|static|abstract|final|\s)*function\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)\s*\(', cskFunction, csbBraceBlock, [roIgnoreCase], 90);
  Registry.Add('php', 'property', '^\s*(?:public|private|protected|static|readonly|\s)+\$(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskProperty, csbDeclarationLine, [roIgnoreCase], 70);
  Registry.Add('ruby', 'module', '^\s*module\s+(?<name>[A-Za-z_][A-Za-z0-9_:]*)', cskModule, csbPascalBlock, [], 100);
  Registry.Add('ruby', 'class', '^\s*class\s+(?<name>[A-Za-z_][A-Za-z0-9_:]*)', cskClass, csbPascalBlock, [], 98);
  Registry.Add('ruby', 'method', '^\s*def\s+(?<name>[A-Za-z_][A-Za-z0-9_!?=]*)', cskMethod, csbPascalBlock, [], 90);
  Registry.Add('go', 'package', '^\s*package\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskNamespace, csbDeclarationLine, [], 100);
  Registry.Add('go', 'type', '^\s*type\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)\s+(?:struct|interface)', cskStruct, csbBraceBlock, [], 95);
  Registry.Add('go', 'function', '^\s*func\s+(?:\([^)]+\)\s*)?(?<name>[A-Za-z_][A-Za-z0-9_]*)\s*\(', cskFunction, csbBraceBlock, [], 90);
  Registry.Add('go', 'variable', '^\s*(?:var|const)\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskVariable, csbDeclarationLine, [], 50);
  Registry.Add('rust', 'mod', '^\s*(?:pub\s+)?mod\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskModule, csbBraceBlock, [], 100);
  Registry.Add('rust', 'struct', '^\s*(?:pub\s+)?struct\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskStruct, csbBraceBlock, [], 98);
  Registry.Add('rust', 'enum', '^\s*(?:pub\s+)?enum\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskEnum, csbBraceBlock, [], 97);
  Registry.Add('rust', 'trait', '^\s*(?:pub\s+)?trait\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskInterface, csbBraceBlock, [], 96);
  Registry.Add('rust', 'impl', '^\s*impl(?:\s*<[^>]+>)?\s+(?<name>[A-Za-z_][A-Za-z0-9_:<>,\s]*)', cskModule, csbBraceBlock, [], 95);
  Registry.Add('rust', 'function', '^\s*(?:pub\s+)?(?:async\s+)?fn\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskFunction, csbBraceBlock, [], 90);
  Registry.Add('rust', 'constant', '^\s*(?:pub\s+)?(?:const|static)\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskConstant, csbDeclarationLine, [], 50);
  Registry.Add('autoit', 'function', '^\s*Func\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskFunction, csbPascalBlock, [roIgnoreCase], 90);
  Registry.Add('autoit', 'region', '^\s*#Region\s+["'']?(?<name>[^"'']+)["'']?', cskRegion, csbPascalBlock, [roIgnoreCase], 70);
  Registry.Add('xml', 'element', '^\s*<(?<name>[A-Za-z_][A-Za-z0-9_\-:\.]*)\b[^>/]*>', cskModule, csbXmlElementBlock, [roIgnoreCase], 50);
  Registry.Add('css', 'selector', '^\s*(?<name>[#\.]?[A-Za-z_][A-Za-z0-9_\-\s\.\#:\[\]=,"'']*)\s*\{', cskModule, csbBraceBlock, [], 40);
  Registry.Add('common', 'class', '^\s*(?:class)\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskClass, csbBraceBlock, [roIgnoreCase], 20);
  Registry.Add('common', 'interface', '^\s*(?:interface)\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskInterface, csbBraceBlock, [roIgnoreCase], 19);
  Registry.Add('common', 'enum', '^\s*(?:enum)\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskEnum, csbBraceBlock, [roIgnoreCase], 18);
  Registry.Add('common', 'function', '^\s*(?:function|func|def)\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskFunction, csbBraceBlock, [roIgnoreCase], 17);
  Registry.Add('common', 'procedure', '^\s*(?:procedure|proc|sub)\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)', cskProcedure, csbPascalBlock, [roIgnoreCase], 16);
end;

end.

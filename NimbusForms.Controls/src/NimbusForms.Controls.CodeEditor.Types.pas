{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.CodeEditor.Types;

interface

uses System.Classes, System.SysUtils, System.Types, Vcl.Graphics;

type
  TCodeEditorNewLineMode = (cnmAuto, cnmWindows, cnmUnix);
  TCodeEditorNewLineKind = (cnkUnknown, cnkWindows, cnkUnix, cnkMacintosh, cnkMixed);
  TCodeEditorInvisibleCharactersItem = (cicSpaces, cicTabs, cicEndOfLine, cicTrailingSpaces);
  TCodeEditorInvisibleCharacters = set of TCodeEditorInvisibleCharactersItem;
  TCodeEditorDocumentIssueFlagsItem = (cdiHasBom, cdiEncodingLowConfidence, cdiMixedLineEndings, cdiMixedIndentation, cdiTrailingWhitespace, cdiMissingFinalNewLine, cdiLargeFileMode, cdiReadOnly, cdiModified);
  TCodeEditorDocumentIssueFlags = set of TCodeEditorDocumentIssueFlagsItem;
  TCodeEditorTextCleanupOptionsItem = (ctcTrimTrailingWhitespace, ctcConvertTabsToSpaces, ctcConvertSpacesToTabs, ctcEnsureFinalNewLine);
  TCodeEditorTextCleanupOptions = set of TCodeEditorTextCleanupOptionsItem;
  TCodeEditorHitArea = (chaNone, chaText, chaLineNumber, chaBookmarkGutter, chaFoldingGutter, chaSelectionMargin, chaVerticalScrollBar, chaHorizontalScrollBar, chaBreakpointGutter);
  TCodeEditorTextRenderBackend = (crbClassicGdi, crbDirectWrite);
  TCodeEditorCaretStyle = (ccsLine, ccsBlock, ccsUnderline);
  TCodeEditorSelectionMode = (csmNormal, csmLine, csmColumn);
  TCodeEditorCompletionItemKind = (cciText, cciKeyword, cciSnippet, cciClass, cciStruct, cciInterface, cciEnum, cciMethod, cciProperty, cciField, cciEvent, cciVariable, cciParameter, cciNamespace, cciFile, cciFolder);
  TCodeEditorCompletionTrigger = (cctNone, cctDot, cctTyping, cctBackspace, cctExplicitCommand);
  TCodeEditorHighlightTokenKind = (chtText, chtKeyword, chtControlKeyword, chtAccessKeyword, chtModifierKeyword, chtTypeKeyword, chtDeclarationKeyword, chtAccessorKeyword, chtIdentifier, chtNamespaceName, chtModuleName, chtClassName, chtStructName, chtInterfaceName, chtEnumName, chtDelegateName, chtTypeName, chtTypeParameterName, chtMethodName, chtFunctionName, chtProcedureName, chtConstructorName, chtPropertyName, chtFieldName, chtVariableName, chtLocalVariableName, chtParameterName, chtConstantName, chtEnumMemberName, chtEventName, chtAttributeName, chtLabelName, chtString, chtVerbatimString, chtInterpolatedString, chtCharacter, chtNumber, chtBoolean, chtNull, chtComment, chtDocumentationComment, chtXmlDocComment, chtPreprocessor, chtOperator, chtPunctuation, chtBracket, chtBrace, chtParenthesis, chtDelimiter, chtWhitespace, chtError, chtWarning, chtSearchMatch, chtSelection, chtImportKeyword, chtImportName, chtLoopKeyword, chtBlockKeyword, chtResultName, chtXmlDocTag, chtXmlDocAttribute, chtXmlDocValue, chtMarkdownHeading, chtMarkdownEmphasis, chtMarkdownLink, chtMarkdownCode);
  TCodeEditorDiagnosticSeverity = (cdsHidden, cdsInfo, cdsHint, cdsWarning, cdsError);

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
  TCodeEditorSymbolKind = (cskUnknown, cskNamespace, cskModule, cskClass, cskStruct, cskInterface, cskEnum, cskDelegate, cskMethod, cskFunction, cskProcedure, cskConstructor, cskProperty, cskField, cskConstant, cskVariable, cskParameter, cskEvent, cskLabel, cskRegion);
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

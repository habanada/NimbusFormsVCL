{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.CodeEditor.Options;

interface

uses System.Classes, System.SysUtils, NimbusForms.Controls.CodeEditor.Types;

type
  TThemedCodeEditorOptions = class(TPersistent)
  private
    FTabSize: Integer;
    FIndentSize: Integer;
    FUseTabs: Boolean;
    FShowLineNumbers: Boolean;
    FShowBookmarks: Boolean;
    FShowFoldingMargin: Boolean;
    FShowIndentGuides: Boolean;
    FShowScopeGuides: Boolean;
    FHighlightCurrentLine: Boolean;
    FHighlightMatchingBrackets: Boolean;
    FShowSearchMatches: Boolean;
    FAutoIndent: Boolean;
    FSmartIndent: Boolean;
    FAutoShowCompletion: Boolean;
    FFilterCompletionWhileTyping: Boolean;
    FWordWrap: Boolean;
    FShowScrollBars: Boolean;
    FUseThemedScrollBars: Boolean;
    FEnableFolding: Boolean;
    FShowOverviewRuler: Boolean;
    FShowBracketPairColorization: Boolean;
    FCompletionDelay: Integer;
    FCompletionItemHeight: Integer;
    FEnableLargeFileMode: Boolean;
    FLargeFileThresholdBytes: Int64;
    FHighlightOnlyVisibleLines: Boolean;
    FDisableFullBracketColorizationInLargeFiles: Boolean;
    FDisableLiveFoldingInLargeFiles: Boolean;
    FDisableLiveSymbolIndexInLargeFiles: Boolean;
    FMaximumFullAnalysisBytes: Integer;
    FMaximumSearchResults: Integer;
    FMaximumSearchResultsInLargeFiles: Integer;
    FShowCommentAdornments: Boolean;
    FShowBreakpoints: Boolean;
    FInvisibleCharacters: TCodeEditorInvisibleCharacters;
    FOnChange: TNotifyEvent;
    procedure SetTabSize(const Value: Integer);
    procedure SetIndentSize(const Value: Integer);
    procedure SetUseTabs(const Value: Boolean);
    procedure SetShowLineNumbers(const Value: Boolean);
    procedure SetShowBookmarks(const Value: Boolean);
    procedure SetShowFoldingMargin(const Value: Boolean);
    procedure SetShowIndentGuides(const Value: Boolean);
    procedure SetShowScopeGuides(const Value: Boolean);
    procedure SetHighlightCurrentLine(const Value: Boolean);
    procedure SetHighlightMatchingBrackets(const Value: Boolean);
    procedure SetShowSearchMatches(const Value: Boolean);
    procedure SetAutoIndent(const Value: Boolean);
    procedure SetSmartIndent(const Value: Boolean);
    procedure SetAutoShowCompletion(const Value: Boolean);
    procedure SetFilterCompletionWhileTyping(const Value: Boolean);
    procedure SetWordWrap(const Value: Boolean);
    procedure SetShowScrollBars(const Value: Boolean);
    procedure SetUseThemedScrollBars(const Value: Boolean);
    procedure SetEnableFolding(const Value: Boolean);
    procedure SetShowOverviewRuler(const Value: Boolean);
    procedure SetShowBracketPairColorization(const Value: Boolean);
    procedure SetCompletionDelay(const Value: Integer);
    procedure SetCompletionItemHeight(const Value: Integer);
    procedure SetEnableLargeFileMode(const Value: Boolean);
    procedure SetLargeFileThresholdBytes(const Value: Int64);
    procedure SetHighlightOnlyVisibleLines(const Value: Boolean);
    procedure SetDisableFullBracketColorizationInLargeFiles(const Value: Boolean);
    procedure SetDisableLiveFoldingInLargeFiles(const Value: Boolean);
    procedure SetDisableLiveSymbolIndexInLargeFiles(const Value: Boolean);
    procedure SetMaximumFullAnalysisBytes(const Value: Integer);
    procedure SetMaximumSearchResults(const Value: Integer);
    procedure SetMaximumSearchResultsInLargeFiles(const Value: Integer);
    procedure SetShowCommentAdornments(const Value: Boolean);
    procedure SetShowBreakpoints(const Value: Boolean);
    procedure SetInvisibleCharacters(const Value: TCodeEditorInvisibleCharacters);
    function GetInvisible(const Index: Integer): Boolean;
    procedure SetInvisible(const Index: Integer; const Value: Boolean);
  public
    constructor Create(const OnChange: TNotifyEvent);
    procedure Assign(Source: TPersistent); override;
  published
    property TabSize: Integer read FTabSize write SetTabSize default 4;
    property IndentSize: Integer read FIndentSize write SetIndentSize default 4;
    property UseTabs: Boolean read FUseTabs write SetUseTabs default False;
    property ShowLineNumbers: Boolean read FShowLineNumbers write SetShowLineNumbers default True;
    property ShowBookmarks: Boolean read FShowBookmarks write SetShowBookmarks default True;
    property ShowFoldingMargin: Boolean read FShowFoldingMargin write SetShowFoldingMargin default True;
    property ShowIndentGuides: Boolean read FShowIndentGuides write SetShowIndentGuides default False;
    property ShowScopeGuides: Boolean read FShowScopeGuides write SetShowScopeGuides default True;
    property HighlightCurrentLine: Boolean read FHighlightCurrentLine write SetHighlightCurrentLine default True;
    property HighlightMatchingBrackets: Boolean read FHighlightMatchingBrackets write SetHighlightMatchingBrackets default True;
    property ShowSearchMatches: Boolean read FShowSearchMatches write SetShowSearchMatches default True;
    property AutoIndent: Boolean read FAutoIndent write SetAutoIndent default True;
    property SmartIndent: Boolean read FSmartIndent write SetSmartIndent default True;
    property AutoShowCompletion: Boolean read FAutoShowCompletion write SetAutoShowCompletion default True;
    property FilterCompletionWhileTyping: Boolean read FFilterCompletionWhileTyping write SetFilterCompletionWhileTyping default True;
    property WordWrap: Boolean read FWordWrap write SetWordWrap default False;
    property ShowScrollBars: Boolean read FShowScrollBars write SetShowScrollBars default True;
    property UseThemedScrollBars: Boolean read FUseThemedScrollBars write SetUseThemedScrollBars default True;
    property EnableFolding: Boolean read FEnableFolding write SetEnableFolding default True;
    property ShowOverviewRuler: Boolean read FShowOverviewRuler write SetShowOverviewRuler default True;
    property ShowBracketPairColorization: Boolean read FShowBracketPairColorization write SetShowBracketPairColorization default True;
    property CompletionDelay: Integer read FCompletionDelay write SetCompletionDelay default 150;
    property CompletionItemHeight: Integer read FCompletionItemHeight write SetCompletionItemHeight default 22;
    property EnableLargeFileMode: Boolean read FEnableLargeFileMode write SetEnableLargeFileMode default True;
    property LargeFileThresholdBytes: Int64 read FLargeFileThresholdBytes write SetLargeFileThresholdBytes default 1 * 1024 * 1024;
    property HighlightOnlyVisibleLines: Boolean read FHighlightOnlyVisibleLines write SetHighlightOnlyVisibleLines default True;
    property DisableFullBracketColorizationInLargeFiles: Boolean read FDisableFullBracketColorizationInLargeFiles write SetDisableFullBracketColorizationInLargeFiles default True;
    property DisableLiveFoldingInLargeFiles: Boolean read FDisableLiveFoldingInLargeFiles write SetDisableLiveFoldingInLargeFiles default True;
    property DisableLiveSymbolIndexInLargeFiles: Boolean read FDisableLiveSymbolIndexInLargeFiles write SetDisableLiveSymbolIndexInLargeFiles default True;
    property MaximumFullAnalysisBytes: Integer read FMaximumFullAnalysisBytes write SetMaximumFullAnalysisBytes default 512 * 1024;
    property MaximumSearchResults: Integer read FMaximumSearchResults write SetMaximumSearchResults default 10000;
    property MaximumSearchResultsInLargeFiles: Integer read FMaximumSearchResultsInLargeFiles write SetMaximumSearchResultsInLargeFiles default 20000;
    property ShowCommentAdornments: Boolean read FShowCommentAdornments write SetShowCommentAdornments default True;
    property ShowBreakpoints: Boolean read FShowBreakpoints write SetShowBreakpoints default True;
    property InvisibleCharacters: TCodeEditorInvisibleCharacters read FInvisibleCharacters write SetInvisibleCharacters default [];
    property ShowSpaces: Boolean index 0 read GetInvisible write SetInvisible default False;
    property ShowTabs: Boolean index 1 read GetInvisible write SetInvisible default False;
    property ShowEndOfLine: Boolean index 2 read GetInvisible write SetInvisible default False;
    property ShowTrailingSpaces: Boolean index 3 read GetInvisible write SetInvisible default False;
    property ShowWhitespace: Boolean index 4 read GetInvisible write SetInvisible default False;
  end;

implementation

uses System.Math;

constructor TThemedCodeEditorOptions.Create(const OnChange: TNotifyEvent);
begin
  inherited Create; FOnChange := OnChange;
  FTabSize := 4;
  FIndentSize := 4;
  FUseTabs := False;
  FShowLineNumbers := True;
  FShowBookmarks := True;
  FShowFoldingMargin := True;
  FShowIndentGuides := False;
  FShowScopeGuides := True;
  FHighlightCurrentLine := True;
  FHighlightMatchingBrackets := True;
  FShowSearchMatches := True;
  FAutoIndent := True;
  FSmartIndent := True;
  FAutoShowCompletion := True;
  FFilterCompletionWhileTyping := True;
  FWordWrap := False;
  FShowScrollBars := True;
  FUseThemedScrollBars := True;
  FEnableFolding := True;
  FShowOverviewRuler := True;
  FShowBracketPairColorization := True;
  FCompletionDelay := 150;
  FCompletionItemHeight := 22;
  FEnableLargeFileMode := True;
  FLargeFileThresholdBytes := 1 * 1024 * 1024;
  FHighlightOnlyVisibleLines := True;
  FDisableFullBracketColorizationInLargeFiles := True;
  FDisableLiveFoldingInLargeFiles := True;
  FDisableLiveSymbolIndexInLargeFiles := True;
  FMaximumFullAnalysisBytes := 512 * 1024;
  FMaximumSearchResults := 10000;
  FMaximumSearchResultsInLargeFiles := 20000;
  FShowCommentAdornments := True;
  FShowBreakpoints := True;
end;

procedure TThemedCodeEditorOptions.Assign(Source: TPersistent);
var Other: TThemedCodeEditorOptions;
begin
  if not (Source is TThemedCodeEditorOptions) then begin inherited; Exit; end;
  Other := TThemedCodeEditorOptions(Source);
  FTabSize := Other.FTabSize;
  FIndentSize := Other.FIndentSize;
  FUseTabs := Other.FUseTabs;
  FShowLineNumbers := Other.FShowLineNumbers;
  FShowBookmarks := Other.FShowBookmarks;
  FShowFoldingMargin := Other.FShowFoldingMargin;
  FShowIndentGuides := Other.FShowIndentGuides;
  FShowScopeGuides := Other.FShowScopeGuides;
  FHighlightCurrentLine := Other.FHighlightCurrentLine;
  FHighlightMatchingBrackets := Other.FHighlightMatchingBrackets;
  FShowSearchMatches := Other.FShowSearchMatches;
  FAutoIndent := Other.FAutoIndent;
  FSmartIndent := Other.FSmartIndent;
  FAutoShowCompletion := Other.FAutoShowCompletion;
  FFilterCompletionWhileTyping := Other.FFilterCompletionWhileTyping;
  FWordWrap := Other.FWordWrap;
  FShowScrollBars := Other.FShowScrollBars;
  FUseThemedScrollBars := Other.FUseThemedScrollBars;
  FEnableFolding := Other.FEnableFolding;
  FShowOverviewRuler := Other.FShowOverviewRuler;
  FShowBracketPairColorization := Other.FShowBracketPairColorization;
  FCompletionDelay := Other.FCompletionDelay;
  FCompletionItemHeight := Other.FCompletionItemHeight;
  FEnableLargeFileMode := Other.FEnableLargeFileMode;
  FLargeFileThresholdBytes := Other.FLargeFileThresholdBytes;
  FHighlightOnlyVisibleLines := Other.FHighlightOnlyVisibleLines;
  FDisableFullBracketColorizationInLargeFiles := Other.FDisableFullBracketColorizationInLargeFiles;
  FDisableLiveFoldingInLargeFiles := Other.FDisableLiveFoldingInLargeFiles;
  FDisableLiveSymbolIndexInLargeFiles := Other.FDisableLiveSymbolIndexInLargeFiles;
  FMaximumFullAnalysisBytes := Other.FMaximumFullAnalysisBytes;
  FMaximumSearchResults := Other.FMaximumSearchResults;
  FMaximumSearchResultsInLargeFiles := Other.FMaximumSearchResultsInLargeFiles;
  FShowCommentAdornments := Other.FShowCommentAdornments;
  FShowBreakpoints := Other.FShowBreakpoints;
  FInvisibleCharacters := Other.FInvisibleCharacters;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetTabSize(const Value: Integer);
var Next: Integer;
begin
  Next := Max(1, Value);
  if FTabSize = Next then Exit;
  FTabSize := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetIndentSize(const Value: Integer);
var Next: Integer;
begin
  Next := Max(1, Value);
  if FIndentSize = Next then Exit;
  FIndentSize := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetUseTabs(const Value: Boolean);
var Next: Boolean;
begin
  Next := Value;
  if FUseTabs = Next then Exit;
  FUseTabs := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetShowLineNumbers(const Value: Boolean);
var Next: Boolean;
begin
  Next := Value;
  if FShowLineNumbers = Next then Exit;
  FShowLineNumbers := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetShowBookmarks(const Value: Boolean);
var Next: Boolean;
begin
  Next := Value;
  if FShowBookmarks = Next then Exit;
  FShowBookmarks := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetShowFoldingMargin(const Value: Boolean);
var Next: Boolean;
begin
  Next := Value;
  if FShowFoldingMargin = Next then Exit;
  FShowFoldingMargin := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetShowIndentGuides(const Value: Boolean);
var Next: Boolean;
begin
  Next := Value;
  if FShowIndentGuides = Next then Exit;
  FShowIndentGuides := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetShowScopeGuides(const Value: Boolean);
var Next: Boolean;
begin
  Next := Value;
  if FShowScopeGuides = Next then Exit;
  FShowScopeGuides := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetHighlightCurrentLine(const Value: Boolean);
var Next: Boolean;
begin
  Next := Value;
  if FHighlightCurrentLine = Next then Exit;
  FHighlightCurrentLine := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetHighlightMatchingBrackets(const Value: Boolean);
var Next: Boolean;
begin
  Next := Value;
  if FHighlightMatchingBrackets = Next then Exit;
  FHighlightMatchingBrackets := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetShowSearchMatches(const Value: Boolean);
var Next: Boolean;
begin
  Next := Value;
  if FShowSearchMatches = Next then Exit;
  FShowSearchMatches := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetAutoIndent(const Value: Boolean);
var Next: Boolean;
begin
  Next := Value;
  if FAutoIndent = Next then Exit;
  FAutoIndent := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetSmartIndent(const Value: Boolean);
var Next: Boolean;
begin
  Next := Value;
  if FSmartIndent = Next then Exit;
  FSmartIndent := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetAutoShowCompletion(const Value: Boolean);
var Next: Boolean;
begin
  Next := Value;
  if FAutoShowCompletion = Next then Exit;
  FAutoShowCompletion := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetFilterCompletionWhileTyping(const Value: Boolean);
var Next: Boolean;
begin
  Next := Value;
  if FFilterCompletionWhileTyping = Next then Exit;
  FFilterCompletionWhileTyping := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetWordWrap(const Value: Boolean);
var Next: Boolean;
begin
  Next := Value;
  if FWordWrap = Next then Exit;
  FWordWrap := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetShowScrollBars(const Value: Boolean);
var Next: Boolean;
begin
  Next := Value;
  if FShowScrollBars = Next then Exit;
  FShowScrollBars := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetUseThemedScrollBars(const Value: Boolean);
var Next: Boolean;
begin
  Next := Value;
  if FUseThemedScrollBars = Next then Exit;
  FUseThemedScrollBars := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetEnableFolding(const Value: Boolean);
var Next: Boolean;
begin
  Next := Value;
  if FEnableFolding = Next then Exit;
  FEnableFolding := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetShowOverviewRuler(const Value: Boolean);
var Next: Boolean;
begin
  Next := Value;
  if FShowOverviewRuler = Next then Exit;
  FShowOverviewRuler := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetShowBracketPairColorization(const Value: Boolean);
var Next: Boolean;
begin
  Next := Value;
  if FShowBracketPairColorization = Next then Exit;
  FShowBracketPairColorization := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetCompletionDelay(const Value: Integer);
var Next: Integer;
begin
  Next := Max(0, Value);
  if FCompletionDelay = Next then Exit;
  FCompletionDelay := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetCompletionItemHeight(const Value: Integer);
var Next: Integer;
begin
  Next := Max(16, Value);
  if FCompletionItemHeight = Next then Exit;
  FCompletionItemHeight := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetEnableLargeFileMode(const Value: Boolean);
var Next: Boolean;
begin
  Next := Value;
  if FEnableLargeFileMode = Next then Exit;
  FEnableLargeFileMode := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetLargeFileThresholdBytes(const Value: Int64);
var Next: Int64;
begin
  Next := Max(0, Value);
  if FLargeFileThresholdBytes = Next then Exit;
  FLargeFileThresholdBytes := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetHighlightOnlyVisibleLines(const Value: Boolean);
var Next: Boolean;
begin
  Next := Value;
  if FHighlightOnlyVisibleLines = Next then Exit;
  FHighlightOnlyVisibleLines := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetDisableFullBracketColorizationInLargeFiles(const Value: Boolean);
var Next: Boolean;
begin
  Next := Value;
  if FDisableFullBracketColorizationInLargeFiles = Next then Exit;
  FDisableFullBracketColorizationInLargeFiles := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetDisableLiveFoldingInLargeFiles(const Value: Boolean);
var Next: Boolean;
begin
  Next := Value;
  if FDisableLiveFoldingInLargeFiles = Next then Exit;
  FDisableLiveFoldingInLargeFiles := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetDisableLiveSymbolIndexInLargeFiles(const Value: Boolean);
var Next: Boolean;
begin
  Next := Value;
  if FDisableLiveSymbolIndexInLargeFiles = Next then Exit;
  FDisableLiveSymbolIndexInLargeFiles := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetMaximumFullAnalysisBytes(const Value: Integer);
var Next: Integer;
begin
  Next := Max(0, Value);
  if FMaximumFullAnalysisBytes = Next then Exit;
  FMaximumFullAnalysisBytes := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetMaximumSearchResults(const Value: Integer);
var Next: Integer;
begin
  Next := Max(0, Value);
  if FMaximumSearchResults = Next then Exit;
  FMaximumSearchResults := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetMaximumSearchResultsInLargeFiles(const Value: Integer);
var Next: Integer;
begin
  Next := Max(0, Value);
  if FMaximumSearchResultsInLargeFiles = Next then Exit;
  FMaximumSearchResultsInLargeFiles := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetShowCommentAdornments(const Value: Boolean);
var Next: Boolean;
begin
  Next := Value;
  if FShowCommentAdornments = Next then Exit;
  FShowCommentAdornments := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetShowBreakpoints(const Value: Boolean);
var Next: Boolean;
begin
  Next := Value;
  if FShowBreakpoints = Next then Exit;
  FShowBreakpoints := Next;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TThemedCodeEditorOptions.SetInvisibleCharacters(const Value: TCodeEditorInvisibleCharacters);
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

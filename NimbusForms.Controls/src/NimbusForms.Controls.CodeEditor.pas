{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.CodeEditor;

interface

uses Winapi.Windows, Winapi.Messages, System.Classes, System.SysUtils, System.Types,
  System.Generics.Collections, Vcl.Controls, Vcl.Graphics, Vcl.ExtCtrls, Vcl.AppEvnts, NimbusForms.Controls.Base,
  NimbusForms.Controls.Types, NimbusForms.Controls.IDEScrollBar, NimbusForms.Controls.HScrollBar,
  NimbusForms.Controls.DropdownPopup, NimbusForms.Controls.Dropdown.Types, NimbusForms.Controls.ToolTip,
  NimbusForms.Theming.Palette, NimbusForms.Controls.CodeEditor.Types, NimbusForms.Controls.CodeEditor.Options,
  NimbusForms.Controls.LogViewer.Types,
  NimbusForms.Controls.CodeEditor.Theme, NimbusForms.Controls.CodeEditor.Document,
  NimbusForms.Controls.CodeEditor.Syntax, NimbusForms.Controls.CodeEditor.Services,
  NimbusForms.Controls.CodeEditor.Editing, NimbusForms.Controls.CodeEditor.Layout,
  NimbusForms.Controls.CodeEditor.Analysis, NimbusForms.Controls.CodeEditor.Breakpoints, NimbusForms.Rendering.CodeEditor;

type
  TCodeEditorErrorEvent = procedure(Sender: TObject; const MessageText: string) of object;
  TCustomThemedCodeEditor = class(TCustomNimbusControl)
  private
    FDocument: TCodeDocument;
    FOptions: TThemedCodeEditorOptions;
    FTheme: TThemedCodeEditorTheme;
    FCommentStyles: TCodeCommentStyles;
    FCaret: TCodeEditorCaret;
    FSelection: TCodeEditorSelection;
    FUndo: TCodeEditorUndoManager;
    FBookmarks: TCodeBookmarkManager;
    FBreakpoints: TCodeBreakpointManager;
    FExecutionLine: Integer;
    FOnBreakpointChanged: TCodeBreakpointEvent;
    FFolds: TCodeFoldManager;
    FRegistry: TCodeLanguageRegistry;
    FSymbolPatterns: TCodeEditorSymbolPatternRegistry;
    FSymbolIndex: TCodeEditorSymbolIndex;
    FLanguage: ICodeLanguageDefinition;
    FHighlighter: ICodeSyntaxHighlighter;
    FHighlights: TCodeHighlightCache;
    FMap: TCodeEditorVisualLineMap;
    FRenderer: ICodeEditorRenderer;
    FBackend: ICodeEditorRenderBackend;
    FDefaultBackend, FDirectWriteBridge: ICodeEditorRenderBackend;
    FTextRenderBackend: TCodeEditorTextRenderBackend;
    FJob: TCodeEditorAnalysisJob;
    FOldJobs: TObjectList<TCodeEditorAnalysisJob>;
    FPairs: TArray<TCodeBracketPair>;
    FPairColors: TDictionary<Int64, Integer>;
    FSearchMatches: TArray<TCodeSearchMatch>;
    FDiagnostics: TArray<TCodeDiagnostic>;
    FCompletionProviders: TList<ICodeCompletionProvider>;
    FFoldProviders: TList<ICodeFoldProvider>;
    FSymbolProviders: TList<ICodeEditorSymbolProvider>;
    FNavigationProviders: TList<ICodeEditorNavigationProvider>;
    FQuickInfoProviders: TList<ICodeEditorQuickInfoProvider>;
    FDiagnosticProviders: TList<ICodeDiagnosticProvider>;
    FTimer: TTimer;
    FV: TThemedIDEScrollBar;
    FH: TThemedHScrollBar;
    FPopup: TThemedDropdownPopupForm;
    FApplicationEvents: TApplicationEvents;
    FCompletionTrigger: TCodeEditorCompletionTrigger;
    FCompletionCollection: TThemedDropdownItems;
    FCompletionRows: TList<TThemedDropdownItem>;
    FCompletions: TArray<TCodeCompletionItem>;
    FCompletionStart: TCodeDocumentPosition;
    FToolTip: TThemedToolTip;
    FMetrics: TCodeEditorRenderMetrics;
    FFirstVisibleLine, FHorizontalOffset, FLayoutVersion, FStatusVersion, FActiveSearch: Integer;
    FSelectionMode: TCodeEditorSelectionMode;
    FCaretStyle: TCodeEditorCaretStyle;
    FAnchor: TCodeDocumentPosition;
    FUpdating, FSyncing, FDragging, FLayoutDirty, FAnalysisPending: Boolean;
    FLastEditTick, FBlinkTick, FCompletionTick, FHoverTick: UInt64;
    FCaretVisible: Boolean;
    FNavigationWord: TCodeEditorWordHitInfo;
    FHasNavigationHover: Boolean;
    FMousePoint: TPoint;
    FMouseShift: TShiftState;
    FDoubleClickRange: TCodeDocumentRange;
    FDoubleClickPoint: TPoint;
    FDoubleClickTick: UInt64;
    FDoubleClickVersion: Integer;
    FHoverText, FComposition: string;
    FPendingSurrogate: Char;
    FRenderActive: Boolean;
    FTextWidths: TDictionary<string, Single>;
    FDisplayFont: TFont;
    FZoom, FWheelRemainder: Integer;
    FWheelShift: TShiftState;
    FPendingTextDrag, FStartingTextDrag: Boolean;
    FTextDragStart: TPoint;
    FTextDragText: string;
    FTextDragVersion: Integer;
    FStatusIssues: TCodeEditorDocumentIssueFlags;
    FOnChange, FOnSelectionChanged, FOnStatusChanged, FOnAnalysisCompleted: TNotifyEvent;
    FOnCaretChanged: TCodePositionEvent;
    FOnCompletion: TCodeCompletionEvent;
    FOnNavigate: TCodeNavigationEvent;
    FOnQuickInfo: TCodeQuickInfoEvent;
    FOnSymbolHover: TCodeWordEvent;
    FOnError: TCodeEditorErrorEvent;
    procedure BuildChildren;
    procedure OptionsChanged(Sender: TObject);
    procedure ThemeChanged(Sender: TObject);
    procedure DocumentChanged(Sender: TObject; const Change: TCodeDocumentChange);
    procedure ModifiedChanged(Sender: TObject);
    procedure CaretChanged(Sender: TObject);
    procedure SelectionChanged(Sender: TObject);
    procedure BookmarksChanged(Sender: TObject);
    procedure FoldsChanged(Sender: TObject);
    procedure TimerTick(Sender: TObject);
    procedure UpdateLayout;
    procedure UpdateDisplayFont;
    procedure SetZoom(const Value: Integer);
    procedure SyncScrollBars;
    procedure ScrollChanged(Sender: TObject);
    procedure RebuildMarkers;
    procedure MarkerClicked(Sender: TObject; Marker: TThemedIDEScrollBarMarker; First, Last: Integer);
    procedure ScheduleAnalysis;
    procedure StartAnalysis;
    procedure ApplyAnalysis;
    procedure CancelAnalysis;
    procedure StateChanged;
    procedure InvalidateContent;
    function MeasureLineText(const Text: string; const TabSize: Integer; const CharWidth: Single): TArray<Single>;
    procedure ScrollCaretIntoView;
    procedure SetCaretPosition(const Position: TCodeDocumentPosition; const Extend: Boolean);
    function ClampCaret(const Position: TCodeDocumentPosition; const Forward: Boolean = False): TCodeDocumentPosition;
    procedure ReplaceRange(const Range: TCodeDocumentRange; const Text, Name: string);
    procedure DeleteKey(const Backward, Word: Boolean);
    procedure MoveHorizontal(const Direction: Integer; const Extend, ByWord: Boolean);
    procedure MoveVertical(const Direction: Integer; const Extend: Boolean);
    procedure Indent(const Unindent: Boolean);
    function IndentUnit: string;
    function NewLineText: string;
    procedure UpdateCompletionFilter;
    procedure CompletionInvoked(Sender: TObject; Item: TThemedDropdownItem);
    procedure PopupMessage(var Message: TMsg; var Handled: Boolean);
    procedure ApplicationDeactivated(Sender: TObject);
    procedure UpdateHover;
    function GetText: string;
    procedure SetText(const Value: string);
    function GetReadOnly: Boolean;
    procedure SetReadOnly(const Value: Boolean);
    function GetLanguageName: string;
    procedure SetLanguageName(const Value: string);
    procedure SetSyntaxHighlighter(const Value: ICodeSyntaxHighlighter);
    procedure SetRenderer(const Value: ICodeEditorRenderer);
    procedure SetRenderBackend(const Value: ICodeEditorRenderBackend);
    procedure SetTextRenderBackend(const Value: TCodeEditorTextRenderBackend);
    procedure SetDirectWriteBridge(const Value: ICodeEditorRenderBackend);
    procedure SetOptions(const Value: TThemedCodeEditorOptions);
    procedure SetTheme(const Value: TThemedCodeEditorTheme);
    procedure SetCommentStyles(const Value: TCodeCommentStyles);
    procedure SetFirstVisibleLine(const Value: Integer);
    procedure SetHorizontalOffset(const Value: Integer);
    procedure SetSelectionMode(const Value: TCodeEditorSelectionMode);
    procedure SetCaretStyle(const Value: TCodeEditorCaretStyle);
    procedure SetExecutionLine(const Value: Integer);
    procedure BreakpointChanged(Sender: TObject; const Breakpoint: TCodeBreakpoint; const Change: TCodeBreakpointChange);
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMCaptureChanged(var Message: TMessage); message WM_CAPTURECHANGED;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMIMEComposition(var Message: TMessage); message WM_IME_COMPOSITION;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
  protected
    procedure SetParent(AParent: TWinControl); override;
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure Paint; override;
    procedure Resize; override;
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DblClick; override;
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean); override;
    procedure DoEndDrag(Target: TObject; X, Y: Integer); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DragDrop(Source: TObject; X, Y: Integer); override;
    procedure ApplyTheme(const APalette: TThemePalette); override;
    function SetLanguage(const Name: string): Boolean;
    function SetLanguageByExtension(const Extension: string): Boolean;
    function RegisterLanguageDefinitionFile(const Path: string): Boolean;
    function RegisterLanguageDefinitionDirectory(const Path: string): Integer;
    procedure LoadFromFile(const Path: string; const Encoding: TCodeTextEncoding = nlfeAuto);
    procedure SaveToFile(const Path: string);
    function FindAll(const Pattern: string; const MatchCase: Boolean = False): TArray<TCodeSearchMatch>; overload;
    function FindAll(const Options: TCodeSearchOptions): TArray<TCodeSearchMatch>; overload;
    procedure SetSearchMatches(const Matches: TArray<TCodeSearchMatch>);
    procedure ClearSearchMatches;
    function FindNext(const Forward: Boolean = True): Boolean;
    procedure ReplaceSelection(const Text: string);
    function DropSelectedText(const Position: TCodeDocumentPosition; const CopyText: Boolean = False): Boolean;
    function ReplaceAll(const Options: TCodeSearchOptions; const Replacement: string): Integer;
    procedure ToggleFold;
    procedure CollapseAllFolds;
    procedure ExpandAllFolds;
    procedure RebuildSymbolIndex;
    function GetWordHitInfoAt(const Position: TCodeDocumentPosition): TCodeEditorWordHitInfo;
    function GetContainingSymbol(const Position: TCodeDocumentPosition; out Symbol: TCodeEditorSymbolInfo): Boolean;
    function GetTextRange(const Range: TCodeDocumentRange): string;
    procedure GoToRange(const Range: TCodeDocumentRange);
    procedure GoToLine(const LineIndex: Integer);
    procedure ToggleBookmark;
    procedure ToggleBreakpoint;
    procedure NextBookmark;
    procedure PreviousBookmark;
    procedure Undo;
    procedure Redo;
    procedure Copy;
    procedure Cut;
    procedure Paste;
    procedure SelectAll;
    procedure ZoomIn;
    procedure ZoomOut;
    procedure ResetZoom;
    function SelectionText: string;
    procedure InsertText(const Text: string; const Name: string = 'Typing');
    procedure TriggerCompletion(const Trigger: TCodeEditorCompletionTrigger = cctExplicitCommand);
    procedure HideCompletion;
    procedure SetDiagnostics(const Diagnostics: TArray<TCodeDiagnostic>);
    function TryNavigateFromPosition(const Position: TCodeDocumentPosition): Boolean;
    function GetStatusInfo: TCodeEditorStatusInfo;
    procedure CleanupText(const Options: TCodeEditorTextCleanupOptions);
    procedure TrimTrailingWhitespace;
    procedure ConvertTabsToSpaces;
    procedure ConvertSpacesToTabs;
    procedure EnsureFinalNewLine;
    function HitTest(const Point: TPoint): TCodeEditorHitInfo;
    function IsLargeFileMode: Boolean;
    property Document: TCodeDocument read FDocument;
    property Caret: TCodeEditorCaret read FCaret;
    property Selection: TCodeEditorSelection read FSelection;
    property UndoManager: TCodeEditorUndoManager read FUndo;
    property Bookmarks: TCodeBookmarkManager read FBookmarks;
    property Breakpoints: TCodeBreakpointManager read FBreakpoints;
    property ExecutionLine: Integer read FExecutionLine write SetExecutionLine default -1;
    property OnBreakpointChanged: TCodeBreakpointEvent read FOnBreakpointChanged write FOnBreakpointChanged;
    property FoldManager: TCodeFoldManager read FFolds;
    property SymbolIndex: TCodeEditorSymbolIndex read FSymbolIndex;
    property SymbolPatterns: TCodeEditorSymbolPatternRegistry read FSymbolPatterns;
    property LanguageRegistry: TCodeLanguageRegistry read FRegistry;
    property Language: ICodeLanguageDefinition read FLanguage;
    property SyntaxHighlighter: ICodeSyntaxHighlighter read FHighlighter write SetSyntaxHighlighter;
    property CompletionProviders: TList<ICodeCompletionProvider> read FCompletionProviders;
    property FoldProviders: TList<ICodeFoldProvider> read FFoldProviders;
    property SymbolProviders: TList<ICodeEditorSymbolProvider> read FSymbolProviders;
    property NavigationProviders: TList<ICodeEditorNavigationProvider> read FNavigationProviders;
    property QuickInfoProviders: TList<ICodeEditorQuickInfoProvider> read FQuickInfoProviders;
    property DiagnosticProviders: TList<ICodeDiagnosticProvider> read FDiagnosticProviders;
    property SearchMatches: TArray<TCodeSearchMatch> read FSearchMatches;
    property BracketPairs: TArray<TCodeBracketPair> read FPairs;
    property Diagnostics: TArray<TCodeDiagnostic> read FDiagnostics;
    property Renderer: ICodeEditorRenderer read FRenderer write SetRenderer;
    property RenderBackend: ICodeEditorRenderBackend read FBackend write SetRenderBackend;
    property DirectWriteBridge: ICodeEditorRenderBackend read FDirectWriteBridge write SetDirectWriteBridge;
    property TextRenderBackend: TCodeEditorTextRenderBackend read FTextRenderBackend write SetTextRenderBackend default crbClassicGdi;
    property Text: string read GetText write SetText;
    property Zoom: Integer read FZoom write SetZoom default 100;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
    property Options: TThemedCodeEditorOptions read FOptions write SetOptions;
    property EditorTheme: TThemedCodeEditorTheme read FTheme write SetTheme;
    property Theme: TThemedCodeEditorTheme read FTheme write SetTheme;
    property CommentStyles: TCodeCommentStyles read FCommentStyles write SetCommentStyles;
    property LanguageName: string read GetLanguageName write SetLanguageName;
    property FirstVisibleLine: Integer read FFirstVisibleLine write SetFirstVisibleLine default 0;
    property HorizontalOffset: Integer read FHorizontalOffset write SetHorizontalOffset default 0;
    property SelectionMode: TCodeEditorSelectionMode read FSelectionMode write SetSelectionMode default csmNormal;
    property CaretStyle: TCodeEditorCaretStyle read FCaretStyle write SetCaretStyle default ccsLine;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnSelectionChanged: TNotifyEvent read FOnSelectionChanged write FOnSelectionChanged;
    property OnStatusChanged: TNotifyEvent read FOnStatusChanged write FOnStatusChanged;
    property OnCaretChanged: TCodePositionEvent read FOnCaretChanged write FOnCaretChanged;
    property OnCompletionRequested: TCodeCompletionEvent read FOnCompletion write FOnCompletion;
    property OnNavigateToDefinitionRequested: TCodeNavigationEvent read FOnNavigate write FOnNavigate;
    property OnQuickInfoRequested: TCodeQuickInfoEvent read FOnQuickInfo write FOnQuickInfo;
    property OnSymbolHover: TCodeWordEvent read FOnSymbolHover write FOnSymbolHover;
    property OnAnalysisCompleted: TNotifyEvent read FOnAnalysisCompleted write FOnAnalysisCompleted;
    property OnError: TCodeEditorErrorEvent read FOnError write FOnError;
  end;
  TThemedCodeEditor = class(TCustomThemedCodeEditor)
  published
    property Align;
    property Anchors;
    property Constraints;
    property Font;
    property ParentFont;
    property Enabled;
    property Visible;
    property TabOrder;
    property TabStop default True;
    property PopupMenu;
    property Text;
    property Zoom;
    property ReadOnly;
    property Options;
    property Theme;
    property TextRenderBackend;
    property CommentStyles;
    property LanguageName;
    property FirstVisibleLine;
    property HorizontalOffset;
    property SelectionMode;
    property CaretStyle;
    property OnChange;
    property OnSelectionChanged;
    property OnStatusChanged;
    property OnCaretChanged;
    property OnCompletionRequested;
    property OnNavigateToDefinitionRequested;
    property OnQuickInfoRequested;
    property OnSymbolHover;
    property OnAnalysisCompleted;
    property OnError;
    property ExecutionLine;
    property OnBreakpointChanged;
    property OnKeyDown;
    property OnKeyPress;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnDragOver;
    property OnDragDrop;
    property OnEndDrag;
  end;

implementation

uses Winapi.Imm, System.Math, System.Character, System.IOUtils, Vcl.Clipbrd, Vcl.Forms,
  NimbusForms.Controls.DropdownList,
  NimbusForms.Rendering.Types, NimbusForms.Rendering.IDEScrollBar,
  NimbusForms.Controls.LogViewer.Encoding, NimbusForms.Controls.CodeEditor.Unicode;

type TCodeDropdownListAccess = class(TThemedDropdownList);

constructor TCustomThemedCodeEditor.Create(AOwner: TComponent);
begin
  inherited; ControlStyle := ControlStyle + [csDoubleClicks] - [csCaptureMouse, csClickEvents];
  FZoom := 100; FDisplayFont := TFont.Create;
  TabStop := True; Cursor := crIBeam; Font.Name := 'Consolas'; Font.Size := 10; Width := 720; Height := 400;
  FDocument := TCodeDocument.Create(Self); FDocument.OnChange := DocumentChanged; FDocument.OnModifiedChanged := ModifiedChanged;
  FOptions := TThemedCodeEditorOptions.Create(OptionsChanged); FTheme := TThemedCodeEditorTheme.Create(ThemeChanged);
  FCommentStyles := TCodeCommentStyles.Create(Self); FCaret := TCodeEditorCaret.Create(CaretChanged);
  FSelection := TCodeEditorSelection.Create(SelectionChanged); FUndo := TCodeEditorUndoManager.Create;
  FBookmarks := TCodeBookmarkManager.Create(BookmarksChanged); FFolds := TCodeFoldManager.Create(FoldsChanged);
  FBreakpoints := TCodeBreakpointManager.Create(BreakpointChanged); FExecutionLine := -1;
  FRegistry := TCodeLanguageRegistry.Create; FSymbolPatterns := TCodeEditorSymbolPatternRegistry.Create;
  FTextWidths := TDictionary<string, Single>.Create;
  FSymbolIndex := TCodeEditorSymbolIndex.Create; FHighlights := TCodeHighlightCache.Create; FMap := TCodeEditorVisualLineMap.Create;
  FMap.MeasureLine := MeasureLineText;
  FOldJobs := TObjectList<TCodeEditorAnalysisJob>.Create(True);
  FPairColors := TDictionary<Int64, Integer>.Create;
  FCompletionProviders := TList<ICodeCompletionProvider>.Create; FFoldProviders := TList<ICodeFoldProvider>.Create;
  FSymbolProviders := TList<ICodeEditorSymbolProvider>.Create; FSymbolProviders.Add(TLocalCodeSymbolProvider.Create(FSymbolPatterns));
  FNavigationProviders := TList<ICodeEditorNavigationProvider>.Create; FQuickInfoProviders := TList<ICodeEditorQuickInfoProvider>.Create;
  FDiagnosticProviders := TList<ICodeDiagnosticProvider>.Create;
  FCompletionCollection := TThemedDropdownItems.Create(Self); FCompletionRows := TList<TThemedDropdownItem>.Create;
  FDefaultBackend := TCodeEditorGDIPlusBackend.Create(RenderCanvas); FBackend := FDefaultBackend; FRenderer := TThemedCodeEditorRenderer.Create;
  FTimer := TTimer.Create(Self); FTimer.Enabled := False; FTimer.Interval := 25; FTimer.OnTimer := TimerTick;
  FLayoutVersion := -1; FStatusVersion := -1; FActiveSearch := -1; FLayoutDirty := True; FCaretVisible := True;
  FMetrics.CharWidth := 8; FMetrics.LineHeight := 20; FMetrics.VisibleRows := 20;
  UpdateDisplayFont; SetLanguage('csharp');
end;

destructor TCustomThemedCodeEditor.Destroy;
var Job: TCodeEditorAnalysisJob;
begin
  FTimer.Enabled := False; FTimer.OnTimer := nil;
  CancelAnalysis;
  for Job in FOldJobs do begin Job.Terminate; Job.WaitFor; end;
  FOldJobs.Free; FreeAndNil(FApplicationEvents); FreeAndNil(FPopup); FreeAndNil(FToolTip);
  FHighlights.Free; FMap.Free; FTextWidths.Free; FPairColors.Free; FCompletionRows.Free; FCompletionCollection.Free;
  FCompletionProviders.Free; FFoldProviders.Free; FSymbolProviders.Free;
  FNavigationProviders.Free; FQuickInfoProviders.Free; FDiagnosticProviders.Free;
  FRegistry.Free; FSymbolIndex.Free; FSymbolPatterns.Free; FBookmarks.Free; FBreakpoints.Free; FFolds.Free;
  FCaret.Free; FSelection.Free; FUndo.Free; FOptions.Free; FTheme.Free; FCommentStyles.Free;
  FDisplayFont.Free;
  FRenderer := nil; FBackend := nil; FDefaultBackend := nil; FDirectWriteBridge := nil; inherited;
end;
procedure TCustomThemedCodeEditor.SetParent(AParent: TWinControl);
begin
  if AParent = nil then begin HideCompletion; if FTimer <> nil then FTimer.Enabled := False; end;
  inherited;
  if (AParent <> nil) and (FV = nil) and not (csDestroying in ComponentState) then BuildChildren;
  if (AParent <> nil) and HandleAllocated and not (csDesigning in ComponentState) then FTimer.Enabled := True;
end;
procedure TCustomThemedCodeEditor.BuildChildren;
begin
  FV := TThemedIDEScrollBar.Create(Self); FV.Parent := Self; FV.TabStop := False;
  FV.OnValueChanged := ScrollChanged; FV.OnMarkerClick := MarkerClicked;
  FH := TThemedHScrollBar.Create(Self); FH.Parent := Self; FH.TabStop := False; FH.OnValueChanged := ScrollChanged;
  RebuildMarkers; SyncScrollBars;
end;
procedure TCustomThemedCodeEditor.CreateWnd;
begin inherited; if not (csDesigning in ComponentState) then FTimer.Enabled := True; FLayoutDirty := True; end;
procedure TCustomThemedCodeEditor.DestroyWnd;
begin FTimer.Enabled := False; HideCompletion; FComposition := ''; inherited; end;
procedure TCustomThemedCodeEditor.ApplyTheme(const APalette: TThemePalette);
begin inherited; if FPopup <> nil then FPopup.ApplyTheme(APalette); if FToolTip <> nil then FToolTip.ApplyTheme(APalette); end;

procedure TCustomThemedCodeEditor.OptionsChanged(Sender: TObject);
begin
  FLayoutDirty := True;
  FHighlights.SetVisibleOnly(FOptions.HighlightOnlyVisibleLines);
  if FOptions.WordWrap then FHorizontalOffset := 0;
  ScheduleAnalysis; Invalidate;
end;
procedure TCustomThemedCodeEditor.ThemeChanged(Sender: TObject);
begin Invalidate; end;
procedure TCustomThemedCodeEditor.SetOptions(const Value: TThemedCodeEditorOptions);
begin if Value <> nil then FOptions.Assign(Value); end;
procedure TCustomThemedCodeEditor.SetTheme(const Value: TThemedCodeEditorTheme);
begin if Value <> nil then FTheme.Assign(Value); end;
procedure TCustomThemedCodeEditor.SetCommentStyles(const Value: TCodeCommentStyles);
begin if Value <> nil then FCommentStyles.Assign(Value); Invalidate; end;
function TCustomThemedCodeEditor.GetText: string;
begin Result := FDocument.Text; end;
procedure TCustomThemedCodeEditor.SetText(const Value: string);
begin FDocument.Text := Value; end;
function TCustomThemedCodeEditor.GetReadOnly: Boolean;
begin Result := FDocument.ReadOnly; end;
procedure TCustomThemedCodeEditor.SetReadOnly(const Value: Boolean);
begin FDocument.ReadOnly := Value; if Value then HideCompletion; StateChanged; end;
function TCustomThemedCodeEditor.GetLanguageName: string;
begin if FLanguage <> nil then Result := FLanguage.Name else Result := ''; end;
procedure TCustomThemedCodeEditor.SetLanguageName(const Value: string);
begin if not SetLanguage(Value) then raise EArgumentException.Create('Unknown editor language: ' + Value); end;
function TCustomThemedCodeEditor.SetLanguage(const Name: string): Boolean;
var Language: ICodeLanguageDefinition;
begin
  Language := FRegistry.FindByName(Name); Result := Language <> nil; if not Result then Exit;
  FLanguage := Language; SetSyntaxHighlighter(TLanguageBasedCodeSyntaxHighlighter.Create(Language));
end;
function TCustomThemedCodeEditor.SetLanguageByExtension(const Extension: string): Boolean;
var Language: ICodeLanguageDefinition;
begin Language := FRegistry.FindByExtension(Extension); Result := Language <> nil; if Result then SetLanguage(Language.Name); end;
function TCustomThemedCodeEditor.RegisterLanguageDefinitionFile(const Path: string): Boolean;
begin Result := FRegistry.RegisterFromFile(Path); end;
function TCustomThemedCodeEditor.RegisterLanguageDefinitionDirectory(const Path: string): Integer;
begin Result := FRegistry.RegisterFromDirectory(Path); end;
procedure TCustomThemedCodeEditor.SetSyntaxHighlighter(const Value: ICodeSyntaxHighlighter);
begin FHighlighter := Value; FHighlights.Attach(FDocument, Value); ScheduleAnalysis; Invalidate; end;
procedure TCustomThemedCodeEditor.SetRenderer(const Value: ICodeEditorRenderer);
begin if Value = nil then raise EArgumentNilException.Create('Renderer'); FRenderer := Value; FLayoutDirty := True; Invalidate; end;
procedure TCustomThemedCodeEditor.SetRenderBackend(const Value: ICodeEditorRenderBackend);
begin if Value = nil then raise EArgumentNilException.Create('RenderBackend'); FBackend := Value; FTextWidths.Clear; FLayoutDirty := True; Invalidate; end;
procedure TCustomThemedCodeEditor.SetTextRenderBackend(const Value: TCodeEditorTextRenderBackend);
begin
  FTextRenderBackend := Value;
  if (Value = crbDirectWrite) and (FDirectWriteBridge <> nil) then SetRenderBackend(FDirectWriteBridge)
  else SetRenderBackend(FDefaultBackend);
end;
procedure TCustomThemedCodeEditor.SetDirectWriteBridge(const Value: ICodeEditorRenderBackend);
begin FDirectWriteBridge := Value; if FTextRenderBackend = crbDirectWrite then SetTextRenderBackend(FTextRenderBackend); end;
procedure TCustomThemedCodeEditor.SetCaretStyle(const Value: TCodeEditorCaretStyle);
begin FCaretStyle := Value; Invalidate; end;
procedure TCustomThemedCodeEditor.SetExecutionLine(const Value: Integer);
begin
  if Value < 0 then FExecutionLine := -1 else FExecutionLine := Min(Value, FDocument.LineCount - 1);
  if FExecutionLine >= 0 then begin FFolds.Reveal(TCodeDocumentPosition.Create(FExecutionLine, 0)); FLayoutDirty := True; end;
  RebuildMarkers; StateChanged;
end;
procedure TCustomThemedCodeEditor.BreakpointChanged(Sender: TObject; const Breakpoint: TCodeBreakpoint; const Change: TCodeBreakpointChange);
begin
  RebuildMarkers; Invalidate;
  if Assigned(FOnBreakpointChanged) and not (csDestroying in ComponentState) then FOnBreakpointChanged(Self, Breakpoint, Change);
end;
procedure TCustomThemedCodeEditor.ToggleBreakpoint;
begin FBreakpoints.Toggle(FCaret.Position.LineIndex); end;
procedure TCustomThemedCodeEditor.SetSelectionMode(const Value: TCodeEditorSelectionMode);
begin FSelectionMode := Value; StateChanged; end;

procedure TCustomThemedCodeEditor.DocumentChanged(Sender: TObject; const Change: TCodeDocumentChange);
var C: Char; Delta, LastOld: Integer;
begin
  if csDestroying in ComponentState then Exit;
  if Change.Reset then
  begin
    FPendingSurrogate := #0;
    FUndo.Clear; FSelection.Clear(TCodeDocumentPosition.Create(0, 0)); FCaret.Position := TCodeDocumentPosition.Create(0, 0);
    FFirstVisibleLine := 0; FHorizontalOffset := 0; FFolds.SetRegions(nil); FHighlights.InvalidateFromLine(0);
  end
  else FHighlights.InvalidateFromLine(Change.Range.Start.LineIndex);
  FPairs := nil; FPairColors.Clear; FSymbolIndex.Clear; FDiagnostics := nil; FHasNavigationHover := False;
  if not Change.Reset then FFolds.ApplyChange(Change, FDocument);
  FBookmarks.ApplyChange(Change, FDocument); FLayoutDirty := True;
  if Change.Reset then FExecutionLine := -1
  else if FExecutionLine >= 0 then
  begin
    Delta := 0; LastOld := Change.Range.Start.LineIndex;
    for C in Change.NewText do if C = #10 then Inc(Delta);
    for C in Change.OldText do if C = #10 then begin Dec(Delta); Inc(LastOld); end;
    if (FExecutionLine > Change.Range.Start.LineIndex) and (FExecutionLine <= LastOld) then FExecutionLine := -1
    else if FExecutionLine > LastOld then FExecutionLine := Min(FDocument.LineCount - 1, FExecutionLine + Delta);
  end;
  FBreakpoints.ApplyChange(FDocument, Change);
  FSearchMatches := nil; FActiveSearch := -1; FStatusVersion := -1;
  ScheduleAnalysis; if Assigned(FOnChange) then FOnChange(Self); StateChanged;
end;
procedure TCustomThemedCodeEditor.ModifiedChanged(Sender: TObject);
begin
  if (FUndo <> nil) and not FUndo.IsRestoring and not FDocument.IsModified then FUndo.MarkSaved;
  if not (csDestroying in ComponentState) then StateChanged;
end;
procedure TCustomThemedCodeEditor.StateChanged;
begin
  InvalidateContent;
  if Assigned(FOnStatusChanged) and not (csDestroying in ComponentState) then FOnStatusChanged(Self);
end;
procedure TCustomThemedCodeEditor.InvalidateContent;
begin
  if not HandleAllocated then Exit;
  if FLayoutDirty or (FLayoutVersion <> FDocument.Version) then Invalidate
  else InvalidateRect(Handle, @FMetrics.Bounds, False);
end;
function TCustomThemedCodeEditor.MeasureLineText(const Text: string; const TabSize: Integer; const CharWidth: Single): TArray<Single>;
var I, Last, J, Display, Advance, Copies: Integer; Element, Repeated: string; Width, X: Single; Size: TSize; Started: Boolean;
begin
  SetLength(Result, Length(Text) + 1); I := 0; Display := 0; X := 0;
  Started := not FRenderActive;
  if Started then begin FBackend.BeginFrame(Canvas, FMetrics.Bounds, CurrentPPI); FRenderActive := True; end;
  try
    while I < Length(Text) do
    begin
      Last := CodeTextElementEnd(Text, I); Advance := Last - I;
      if Text[I + 1] = #9 then begin Advance := TabSize - Display mod TabSize; Width := Advance * CharWidth; end
      else if (Last = I + 1) and (Ord(Text[I + 1]) < 128) then Width := CharWidth
      else
      begin
        Element := System.Copy(Text, I + 1, Last - I);
        if not FTextWidths.TryGetValue(Element, Width) then
        begin
          Copies := Min(128, Max(1, 4096 div Length(Element))); Repeated := ''; for J := 1 to Copies do Repeated := Repeated + Element;
          Size := FBackend.Measure(Repeated, FDisplayFont); Width := Max(0, Size.cx / Copies);
          if FTextWidths.Count >= 4096 then FTextWidths.Clear; FTextWidths.Add(Element, Width);
        end;
      end;
      for J := I + 1 to Last do Result[J] := X + Width * (J - I) / (Last - I);
      X := X + Width; Inc(Display, Advance); I := Last;
    end;
  finally if Started then begin FRenderActive := False; FBackend.EndFrame; end; end;
end;
procedure TCustomThemedCodeEditor.CaretChanged(Sender: TObject);
begin
  if FUpdating then Exit; FUpdating := True;
  try FCaret.Position := ClampCaret(FCaret.Position); finally FUpdating := False; end;
  FCaretVisible := True; FBlinkTick := GetTickCount64;
  ScrollCaretIntoView; RebuildMarkers; StateChanged;
  if Assigned(FOnCaretChanged) then FOnCaretChanged(Self, FCaret.Position);
end;
procedure TCustomThemedCodeEditor.SelectionChanged(Sender: TObject);
begin StateChanged; if Assigned(FOnSelectionChanged) then FOnSelectionChanged(Self); end;
procedure TCustomThemedCodeEditor.BookmarksChanged(Sender: TObject);
begin RebuildMarkers; Invalidate; end;
procedure TCustomThemedCodeEditor.FoldsChanged(Sender: TObject);
begin FLayoutDirty := True; Invalidate; end;

procedure TCustomThemedCodeEditor.ScheduleAnalysis;
begin CancelAnalysis; FLastEditTick := GetTickCount64; FAnalysisPending := True; end;
procedure TCustomThemedCodeEditor.CancelAnalysis;
begin if FJob <> nil then begin FJob.Terminate; FOldJobs.Add(FJob); FJob := nil; end; end;
function TCustomThemedCodeEditor.IsLargeFileMode: Boolean;
begin Result := FOptions.EnableLargeFileMode and ((FDocument.LoadedByteLength >= FOptions.LargeFileThresholdBytes) or (FDocument.TextLength >= FOptions.MaximumFullAnalysisBytes)); end;
procedure TCustomThemedCodeEditor.StartAnalysis;
var Large: Boolean;
begin
  CancelAnalysis; FAnalysisPending := False; Large := IsLargeFileMode;
  if Large then
  begin
    if FOptions.DisableLiveFoldingInLargeFiles then FFolds.SetRegions(nil);
    if FOptions.DisableFullBracketColorizationInLargeFiles then FPairs := nil;
    if FOptions.DisableLiveSymbolIndexInLargeFiles then FSymbolIndex.Clear;
  end;
  if Large and FOptions.DisableLiveFoldingInLargeFiles and FOptions.DisableFullBracketColorizationInLargeFiles and
    FOptions.DisableLiveSymbolIndexInLargeFiles and (FDiagnosticProviders.Count = 0) then Exit;
  FJob := TCodeEditorAnalysisJob.Create(FDocument.GetSnapshot, FHighlighter, GetLanguageName,
    FFoldProviders.ToArray, FSymbolProviders.ToArray, FDiagnosticProviders.ToArray,
    not Large or not FOptions.DisableFullBracketColorizationInLargeFiles,
    FOptions.EnableFolding and (not Large or not FOptions.DisableLiveFoldingInLargeFiles),
    not Large or not FOptions.DisableLiveSymbolIndexInLargeFiles);
  FJob.Start;
end;
procedure TCustomThemedCodeEditor.ApplyAnalysis;
var Result: TCodeEditorAnalysisResult; Pair: TCodeBracketPair;
begin
  if (FJob = nil) or not FJob.Done then Exit;
  Result := FJob.TakeResult; FreeAndNil(FJob);
  if Result.Version <> FDocument.Version then Exit;
  if Result.ErrorText <> '' then
  begin if Assigned(FOnError) then FOnError(Self, Result.ErrorText); Exit; end;
  FPairs := Result.Pairs; FPairColors.Clear;
  for Pair in FPairs do
  begin FPairColors.AddOrSetValue((Int64(Pair.OpenPosition.LineIndex) shl 32) or Cardinal(Pair.OpenPosition.ColumnIndex), Pair.ColorIndex);
    FPairColors.AddOrSetValue((Int64(Pair.ClosePosition.LineIndex) shl 32) or Cardinal(Pair.ClosePosition.ColumnIndex), Pair.ColorIndex); end;
  FFolds.SetRegions(Result.Folds); FSymbolIndex.SetSymbols(Result.Symbols);
  FDiagnostics := Result.Diagnostics; RebuildMarkers; FLayoutDirty := True; Invalidate;
  if Assigned(FOnAnalysisCompleted) then FOnAnalysisCompleted(Self);
end;
procedure TCustomThemedCodeEditor.TimerTick(Sender: TObject);
var Tick: UInt64; I: Integer;
begin
  Tick := GetTickCount64;
  for I := FOldJobs.Count - 1 downto 0 do if FOldJobs[I].Done then FOldJobs.Delete(I);
  if FAnalysisPending and (Tick - FLastEditTick >= 100) then StartAnalysis;
  ApplyAnalysis;
  if FHighlights.Advance(64) then InvalidateContent;
  if Focused and (Tick - FBlinkTick >= 500) then begin FCaretVisible := not FCaretVisible; FBlinkTick := Tick; InvalidateContent; end;
  if (FCompletionTick <> 0) and (Tick >= FCompletionTick) then begin FCompletionTick := 0; TriggerCompletion(FCompletionTrigger); end;
  if (FHoverTick <> 0) and (Tick >= FHoverTick) then begin FHoverTick := 0; UpdateHover; end;
end;

procedure TCustomThemedCodeEditor.UpdateLayout;
var Bounds: TRect; Bar, WrapColumns, PreviousWrapColumns, Pass: Integer; V, H: Boolean;
begin
  if not HandleAllocated or (FV = nil) or FSyncing or (ClientWidth <= 0) or (ClientHeight <= 0) then Exit;
  if not FLayoutDirty and (FLayoutVersion = FDocument.Version) then Exit;
  Bar := ScaleValue(18); Bounds := ClientRect; V := False; H := False; PreviousWrapColumns := -1;
  for Pass := 0 to 2 do
  begin
    Bounds := Rect(0, 0, Max(0, ClientWidth - Ord(V) * Bar), Max(0, ClientHeight - Ord(H) * Bar));
    FBackend.BeginFrame(Canvas, Bounds, CurrentPPI);
    try FMetrics := FRenderer.Measure(FBackend, FDisplayFont, Bounds, CurrentPPI, FDocument.LineCount, FOptions);
    finally FBackend.EndFrame; end;
    WrapColumns := Max(1, Floor((FMetrics.TextBounds.Width - FMetrics.TextInset) / FMetrics.CharWidth));
    if (Pass = 0) or (FOptions.WordWrap and (WrapColumns <> PreviousWrapColumns)) then
      FMap.Rebuild(FDocument, FFolds, FOptions.EnableFolding, FOptions.WordWrap, WrapColumns, FOptions.TabSize);
    PreviousWrapColumns := WrapColumns;
    V := FOptions.ShowScrollBars and ((FMap.Count > FMetrics.VisibleRows) or (FOptions.ShowOverviewRuler and (FDocument.LineCount > 1)));
    H := FOptions.ShowScrollBars and not FOptions.WordWrap and
      ((FMap.MaxColumns + Ord(FOptions.ShowEndOfLine) * 6) * FMetrics.CharWidth + FMetrics.TextInset > FMetrics.TextBounds.Width);
  end;
  FLayoutDirty := False; FLayoutVersion := FDocument.Version; SyncScrollBars; RebuildMarkers;
end;
procedure TCustomThemedCodeEditor.SyncScrollBars;
var Bar, MaxX, Columns: Integer;
begin
  if (FV = nil) or (FH = nil) or FSyncing or not HandleAllocated then Exit;
  FSyncing := True;
  try
    Bar := ScaleValue(18); FFirstVisibleLine := EnsureRange(FFirstVisibleLine, 0, Max(0, FMap.Count - FMetrics.VisibleRows));
    Columns := FMap.MaxColumns + Ord(FOptions.ShowEndOfLine) * 6;
    MaxX := Max(0, Ceil(Columns * FMetrics.CharWidth) + FMetrics.TextInset - FMetrics.TextBounds.Width);
    if FOptions.WordWrap then MaxX := 0;
    FHorizontalOffset := EnsureRange(FHorizontalOffset, 0, MaxX);
    FV.SetBounds(ClientWidth - Bar, 0, Bar, FMetrics.Bounds.Height); FV.Visible := FOptions.ShowScrollBars and (FMetrics.Bounds.Right < ClientWidth);
    FH.SetBounds(0, ClientHeight - Bar, FMetrics.Bounds.Width, Bar); FH.Visible := FOptions.ShowScrollBars and (FMetrics.Bounds.Bottom < ClientHeight);
    FV.Maximum := Max(0, FMap.Count - 1); FV.LargeChange := FMetrics.VisibleRows; FV.Value := FFirstVisibleLine;
    FH.Maximum := Max(0, Ceil(Columns * FMetrics.CharWidth) + FMetrics.TextInset - 1); FH.LargeChange := Max(1, FMetrics.TextBounds.Width); FH.Value := FHorizontalOffset;
  finally FSyncing := False; end;
end;
procedure TCustomThemedCodeEditor.ScrollChanged(Sender: TObject);
begin if FSyncing then Exit; if Sender = FV then FFirstVisibleLine := FV.Value else FHorizontalOffset := FH.Value; HideCompletion; StateChanged; end;
procedure TCustomThemedCodeEditor.SetFirstVisibleLine(const Value: Integer);
begin FFirstVisibleLine := Max(0, Value); UpdateLayout; SyncScrollBars; HideCompletion; StateChanged; end;
procedure TCustomThemedCodeEditor.SetHorizontalOffset(const Value: Integer);
begin FHorizontalOffset := Max(0, Value); UpdateLayout; SyncScrollBars; StateChanged; end;
procedure TCustomThemedCodeEditor.RebuildMarkers;
var B: TCodeBookmark; H: TCodeSearchMatch; D: TCodeDiagnostic; M: TThemedIDEScrollBarMarker; BP: TCodeBreakpoint;
  Line, Row, Bucket: Integer; Seen: array[0..511, 0..6] of Boolean;
  procedure Add(const Position: TCodeDocumentPosition; const Lane: TNimbusIDEMarkerLane;
    const Tone: TNimbusIDEMarkerTone; const Kind: Integer);
  begin
    if FMap.Count = 0 then Exit;
    Row := FMap.GetVisualLine(Position); Bucket := Integer(Int64(Row) * 512 div Max(1, FMap.Count));
    if Seen[Bucket, Kind] then Exit; Seen[Bucket, Kind] := True;
    M := FV.Markers.Add; M.First := Row; M.Last := Row; M.Tag := FDocument.GetOffset(Position); M.Lane := Lane; M.Tone := Tone;
  end;
begin
  if (FV = nil) or FSyncing then Exit;
  FillChar(Seen, SizeOf(Seen), 0); FV.Markers.BeginUpdate;
  try
    FV.Markers.Clear; if not FOptions.ShowOverviewRuler then Exit;
    for B in FBookmarks.Items do Add(TCodeDocumentPosition.Create(B.LineIndex, 0), imlRight, imtAccent, 0);
    for H in FSearchMatches do Add(H.Range.Start, imlRight, imtWarning, 1);
    for D in FDiagnostics do if D.Severity <> cdsHidden then
      if D.Severity = cdsError then Add(D.Range.Start, imlLeft, imtError, 3)
      else if D.Severity = cdsWarning then Add(D.Range.Start, imlLeft, imtWarning, 2)
      else Add(D.Range.Start, imlLeft, imtInfo, 4);
    for BP in FBreakpoints.Items do
      if BP.Enabled then Add(TCodeDocumentPosition.Create(BP.LineIndex, 0), imlLeft, imtError, 5)
      else Add(TCodeDocumentPosition.Create(BP.LineIndex, 0), imlLeft, imtMuted, 5);
    if FExecutionLine >= 0 then Add(TCodeDocumentPosition.Create(FExecutionLine, 0), imlRight, imtWarning, 6);
    Line := FDocument.Clamp(FCaret.Position).LineIndex;
    M := FV.Markers.Add; M.First := FMap.GetVisualLine(TCodeDocumentPosition.Create(Line, 0)); M.Last := M.First;
    M.Tag := FDocument.GetOffset(FCaret.Position); M.Lane := imlRight; M.Tone := imtMuted; M.Shape := imsLine;
  finally FV.Markers.EndUpdate; end;
end;
procedure TCustomThemedCodeEditor.MarkerClicked(Sender: TObject; Marker: TThemedIDEScrollBarMarker; First, Last: Integer);
var Position: TCodeDocumentPosition;
begin Position := FDocument.GetPosition(Integer(Marker.Tag)); SetCaretPosition(Position, False); if CanFocus then SetFocus; end;

procedure TCustomThemedCodeEditor.Paint;
var Context: TCodeEditorRenderContext;
begin
  UpdateLayout; Context := Default(TCodeEditorRenderContext);
  Context.Source := FDocument; Context.Font := FDisplayFont; Context.Palette := Palette;
  Context.Options := FOptions; Context.Theme := FTheme; Context.Metrics := FMetrics;
  Context.Map := FMap; Context.Highlights := FHighlights; Context.Bookmarks := FBookmarks;
  Context.Folds := FFolds; Context.Pairs := FPairs; Context.PairColors := FPairColors; Context.SearchMatches := FSearchMatches;
  Context.Diagnostics := FDiagnostics; Context.CommentStyles := FCommentStyles;
  Context.Breakpoints := FBreakpoints; Context.ExecutionLine := FExecutionLine; Context.HasExecutionLine := FExecutionLine >= 0;
  Context.Caret := FCaret.Position; Context.Selection := FSelection.Range;
  Context.SelectionMode := FSelectionMode; Context.CaretStyle := FCaretStyle;
  Context.FirstVisibleLine := FFirstVisibleLine; Context.HorizontalOffset := FHorizontalOffset;
  Context.HasNavigationHover := FHasNavigationHover; Context.NavigationRange := FNavigationWord.Range;
  Context.Focused := Focused; Context.Enabled := Enabled; Context.CaretVisible := FCaretVisible;
  FBackend.BeginFrame(Canvas, ClientRect, CurrentPPI); FRenderActive := True;
  try
    FBackend.FillRect(ClientRect, FTheme.Resolve(FTheme.BackColor, NimbusInputBackColor(Palette)));
    FRenderer.Render(FBackend, Context);
  finally FRenderActive := False; FBackend.EndFrame; end;
end;
procedure TCustomThemedCodeEditor.Resize;
begin inherited; FLayoutDirty := True; Invalidate; end;
procedure TCustomThemedCodeEditor.CMFontChanged(var Message: TMessage);
begin inherited; UpdateDisplayFont; end;
procedure TCustomThemedCodeEditor.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin inherited; UpdateDisplayFont; end;
procedure TCustomThemedCodeEditor.UpdateDisplayFont;
begin
  if (FDisplayFont = nil) or (csDestroying in ComponentState) then Exit;
  FDisplayFont.Assign(Font); FDisplayFont.Height := MulDiv(Font.Height, FZoom, 100);
  if FDisplayFont.Height = 0 then FDisplayFont.Height := -1;
  FLayoutDirty := True;
  if FTextWidths <> nil then FTextWidths.Clear;
  FCompletionTick := 0; FHoverTick := 0; HideCompletion;
  if FToolTip <> nil then FToolTip.HideHint;
  if FPopup <> nil then TCodeDropdownListAccess(FPopup.ListControl).Font.Assign(Font);
  Invalidate;
end;
procedure TCustomThemedCodeEditor.SetZoom(const Value: Integer);
var Next: Integer;
begin
  Next := EnsureRange(Value, 25, 400); if FZoom = Next then Exit;
  FZoom := Next; UpdateDisplayFont;
  if FCaret <> nil then ScrollCaretIntoView;
  StateChanged;
end;
procedure TCustomThemedCodeEditor.ZoomIn;
begin Zoom := FZoom + 10; end;
procedure TCustomThemedCodeEditor.ZoomOut;
begin Zoom := FZoom - 10; end;
procedure TCustomThemedCodeEditor.ResetZoom;
begin Zoom := 100; end;
procedure TCustomThemedCodeEditor.CMEnabledChanged(var Message: TMessage);
begin inherited; if FV <> nil then FV.Enabled := Enabled; if FH <> nil then FH.Enabled := Enabled; if not Enabled then HideCompletion; end;
function TCustomThemedCodeEditor.HitTest(const Point: TPoint): TCodeEditorHitInfo;
begin UpdateLayout; Result := CodeHitTest(Point, FMetrics, FMap, FDocument, FFirstVisibleLine, FHorizontalOffset, FOptions.TabSize); end;
procedure TCustomThemedCodeEditor.ScrollCaretIntoView;
var Row: Integer; P: TPoint;
begin
  if FUpdating then Exit;
  FFolds.Reveal(FCaret.Position); if not HandleAllocated then Exit;
  UpdateLayout; if FMap.Count = 0 then Exit;
  Row := FMap.GetVisualLine(FCaret.Position);
  if Row < FFirstVisibleLine then FFirstVisibleLine := Row
  else if Row >= FFirstVisibleLine + FMetrics.VisibleRows then FFirstVisibleLine := Row - FMetrics.VisibleRows + 1;
  P := CodePositionPoint(FCaret.Position, FMetrics, FMap, FDocument, FFirstVisibleLine, FHorizontalOffset, FOptions.TabSize);
  if P.X < FMetrics.TextBounds.Left then FHorizontalOffset := Max(0, FHorizontalOffset + P.X - FMetrics.TextBounds.Left - 8)
  else if P.X + Ceil(FMetrics.CharWidth) > FMetrics.TextBounds.Right then Inc(FHorizontalOffset, P.X + Ceil(FMetrics.CharWidth) - FMetrics.TextBounds.Right + 8);
  SyncScrollBars;
end;
procedure TCustomThemedCodeEditor.SetCaretPosition(const Position: TCodeDocumentPosition; const Extend: Boolean);
var Next: TCodeDocumentPosition;
begin
  Next := ClampCaret(Position); FUndo.BreakMerge;
  if Extend then begin if FSelection.IsEmpty then FAnchor := FCaret.Position; FSelection.SetSelection(FAnchor, Next); end
  else begin FAnchor := Next; FSelection.Clear(Next); end;
  FCaret.Position := Next; ScrollCaretIntoView; StateChanged;
end;
function TCustomThemedCodeEditor.ClampCaret(const Position: TCodeDocumentPosition; const Forward: Boolean): TCodeDocumentPosition;
begin
  Result := FDocument.Clamp(Position);
  Result.ColumnIndex := CodeClampTextElement(FDocument.GetLineText(Result.LineIndex), Result.ColumnIndex, Forward);
end;
procedure TCustomThemedCodeEditor.ReplaceRange(const Range: TCodeDocumentRange; const Text, Name: string);
var U: TCodeUndoUnit; Version, Count: Integer; R: TCodeDocumentRange; C: Char;
begin
  if ReadOnly then Exit;
  R := TCodeDocumentRange.Create(ClampCaret(Range.Start), ClampCaret(Range.Finish, not Range.IsEmpty));
  U := Default(TCodeUndoUnit); U.Offset := FDocument.GetOffset(R.Start); U.OldText := FDocument.GetTextRange(R);
  U.OldEndings := FDocument.GetEndingRange(R.Start.LineIndex, R.Finish.LineIndex - R.Start.LineIndex + 1);
  U.NewText := CodeNormalizeNewLines(Text); U.Name := Name; U.BeforeModified := FDocument.IsModified;
  Version := FDocument.Version; FDocument.Replace(R, U.NewText); if Version = FDocument.Version then Exit;
  Count := 1; for C in U.NewText do if C = #10 then Inc(Count);
  U.NewEndings := FDocument.GetEndingRange(R.Start.LineIndex, Count);
  U.AfterModified := FDocument.IsModified; FUndo.Push(U);
  FCaret.Position := ClampCaret(FDocument.GetPosition(U.Offset + Length(U.NewText)), True); FSelection.Clear(FCaret.Position);
  FCaret.PreferredColumn := -1; ScrollCaretIntoView;
end;
procedure TCustomThemedCodeEditor.InsertText(const Text: string; const Name: string);
var R: TCodeDocumentRange; I, FirstCol, LastCol: Integer; P: TCodeDocumentPosition;
begin
  if ReadOnly then Exit;
  if (FSelectionMode = csmColumn) and not FSelection.IsEmpty then
  begin
    R := FSelection.Range; FirstCol := Min(R.Start.ColumnIndex, R.Finish.ColumnIndex); LastCol := Max(R.Start.ColumnIndex, R.Finish.ColumnIndex);
    FUndo.BeginGroup(FDocument, Name);
    try
      for I := R.Finish.LineIndex downto R.Start.LineIndex do
      begin P := TCodeDocumentPosition.Create(I, FirstCol); ReplaceRange(TCodeDocumentRange.Create(P, TCodeDocumentPosition.Create(I, LastCol)), Text, Name); end;
    finally FUndo.EndGroup(FDocument); end;
  end
  else
  begin
    R := FSelection.Range; if R.IsEmpty then R := TCodeDocumentRange.Create(FCaret.Position, FCaret.Position);
    ReplaceRange(R, Text, Name);
  end;
  StateChanged;
end;
procedure TCustomThemedCodeEditor.ReplaceSelection(const Text: string);
begin InsertText(Text, 'Replace'); end;
procedure TCustomThemedCodeEditor.DeleteKey(const Backward, Word: Boolean);
var Offset, Other: Integer; P: TCodeDocumentPosition; Text: string;
begin
  if ReadOnly then Exit; HideCompletion;
  if not FSelection.IsEmpty then begin InsertText('', 'Delete Selection'); Exit; end;
  P := ClampCaret(FCaret.Position); Text := FDocument.GetLineText(P.LineIndex);
  Offset := FDocument.GetOffset(P); Other := Offset;
  if Backward then
  begin
    if Offset = 0 then Exit;
    if P.ColumnIndex > 0 then Other := Offset - P.ColumnIndex + CodePreviousTextElement(Text, P.ColumnIndex) else Dec(Other);
  end
  else
  begin
    if Offset = FDocument.TextLength then Exit;
    if P.ColumnIndex < Length(Text) then Other := Offset - P.ColumnIndex + CodeNextTextElement(Text, P.ColumnIndex) else Inc(Other);
  end;
  if Word then
  begin
    P := FDocument.GetPosition(Other); Text := FDocument.GetLineText(P.LineIndex);
    if Backward then while (P.ColumnIndex > 0) and CodeIsWord(Text[P.ColumnIndex]) do begin Dec(P.ColumnIndex); Other := FDocument.GetOffset(P); end
    else while (P.ColumnIndex < Length(Text)) and CodeIsWord(Text[P.ColumnIndex + 1]) do begin Inc(P.ColumnIndex); Other := FDocument.GetOffset(P); end;
  end;
  ReplaceRange(TCodeDocumentRange.Create(FDocument.GetPosition(Min(Offset, Other)), FDocument.GetPosition(Max(Offset, Other))), '', 'Delete');
end;
procedure TCustomThemedCodeEditor.MoveHorizontal(const Direction: Integer; const Extend, ByWord: Boolean);
var Offset: Integer; P: TCodeDocumentPosition; Text: string;
begin
  HideCompletion; P := ClampCaret(FCaret.Position); Text := FDocument.GetLineText(P.LineIndex); Offset := FDocument.GetOffset(P);
  if (Direction < 0) and (P.ColumnIndex > 0) then Offset := Offset - P.ColumnIndex + CodePreviousTextElement(Text, P.ColumnIndex)
  else if (Direction > 0) and (P.ColumnIndex < Length(Text)) then Offset := Offset - P.ColumnIndex + CodeNextTextElement(Text, P.ColumnIndex)
  else Offset := EnsureRange(Offset + Direction, 0, FDocument.TextLength);
  if ByWord then
  begin
    P := FDocument.GetPosition(Offset); Text := FDocument.GetLineText(P.LineIndex);
    if Direction < 0 then while (P.ColumnIndex > 0) and CodeIsWord(Text[P.ColumnIndex]) do Dec(P.ColumnIndex)
    else while (P.ColumnIndex < Length(Text)) and CodeIsWord(Text[P.ColumnIndex + 1]) do Inc(P.ColumnIndex);
    Offset := FDocument.GetOffset(P);
  end;
  FCaret.PreferredColumn := -1; SetCaretPosition(FDocument.GetPosition(Offset), Extend);
end;
procedure TCustomThemedCodeEditor.MoveVertical(const Direction: Integer; const Extend: Boolean);
var RowIndex, Column: Integer; Row: TCodeVisualLine; P: TCodeDocumentPosition;
begin
  HideCompletion; UpdateLayout;
  if FMap.Count = 0 then begin P := FCaret.Position; Inc(P.LineIndex, Direction); SetCaretPosition(P, Extend); Exit; end;
  RowIndex := FMap.GetVisualLine(FCaret.Position); Row := FMap.GetRow(RowIndex);
  if FCaret.PreferredColumn < 0 then FCaret.PreferredColumn := Round((FMap.TextX(FDocument.GetLineText(FCaret.Position.LineIndex), FCaret.Position.LineIndex, FCaret.Position.ColumnIndex, FOptions.TabSize, FMetrics.CharWidth) -
    FMap.TextX(FDocument.GetLineText(FCaret.Position.LineIndex), FCaret.Position.LineIndex, Row.StartColumn, FOptions.TabSize, FMetrics.CharWidth)) / FMetrics.CharWidth);
  RowIndex := EnsureRange(RowIndex + Direction, 0, FMap.Count - 1); Row := FMap.GetRow(RowIndex);
  Column := FMap.TextColumn(FDocument.GetLineText(Row.DocumentLine), Row.DocumentLine, FOptions.TabSize,
    FMap.TextX(FDocument.GetLineText(Row.DocumentLine), Row.DocumentLine, Row.StartColumn, FOptions.TabSize, FMetrics.CharWidth) + FCaret.PreferredColumn * FMetrics.CharWidth, FMetrics.CharWidth);
  SetCaretPosition(TCodeDocumentPosition.Create(Row.DocumentLine, EnsureRange(Column, Row.StartColumn, Row.EndColumn)), Extend);
end;
function TCustomThemedCodeEditor.IndentUnit: string;
begin if FOptions.UseTabs then Result := #9 else Result := StringOfChar(' ', FOptions.IndentSize); end;
function TCustomThemedCodeEditor.NewLineText: string;
var Text, Before, Indentation: string; I: Integer;
begin
  Result := #10; if not FOptions.AutoIndent then Exit; Text := FDocument.GetLineText(FCaret.Position.LineIndex);
  I := 1; while (I <= Length(Text)) and CharInSet(Text[I], [' ', #9]) do Inc(I); Indentation := System.Copy(Text, 1, I - 1);
  Before := LowerCase(TrimRight(System.Copy(Text, 1, FCaret.Position.ColumnIndex)));
  if FOptions.SmartIndent and (Before.EndsWith('{') or Before.EndsWith('(') or Before.EndsWith('[') or Before.EndsWith(':') or Before.EndsWith('begin') or Before.EndsWith('then') or Before.EndsWith('do')) then Indentation := Indentation + IndentUnit;
  Result := Result + Indentation;
end;
procedure TCustomThemedCodeEditor.Indent(const Unindent: Boolean);
var R: TCodeDocumentRange; First, Last, I, Count: Integer; Text: string; P: TCodeDocumentPosition;
begin
  if ReadOnly then Exit;
  if not Unindent and FSelection.IsEmpty then
  begin
    if FOptions.UseTabs then Text := #9
    else Text := StringOfChar(' ', FOptions.TabSize - CodeDisplayColumn(FDocument.GetLineText(FCaret.Position.LineIndex), FCaret.Position.ColumnIndex, FOptions.TabSize) mod FOptions.TabSize);
    InsertText(Text, 'Indent'); Exit;
  end;
  R := FSelection.Range; First := R.Start.LineIndex; Last := R.Finish.LineIndex;
  if FSelection.IsEmpty then begin First := FCaret.Position.LineIndex; Last := First; end
  else if (R.Finish.ColumnIndex = 0) and (Last > First) then Dec(Last);
  FUndo.BeginGroup(FDocument, 'Indent');
  try
    for I := Last downto First do
    begin
      P := TCodeDocumentPosition.Create(I, 0);
      if Unindent then
      begin
        Text := FDocument.GetLineText(I); Count := 0;
        if Text.StartsWith(#9) then Count := 1 else while (Count < FOptions.IndentSize) and (Count < Length(Text)) and (Text[Count + 1] = ' ') do Inc(Count);
        if Count > 0 then ReplaceRange(TCodeDocumentRange.Create(P, TCodeDocumentPosition.Create(I, Count)), '', 'Unindent');
      end
      else ReplaceRange(TCodeDocumentRange.Create(P, P), IndentUnit, 'Indent');
    end;
  finally FUndo.EndGroup(FDocument); end;
  FSelection.SetSelection(TCodeDocumentPosition.Create(First, 0), TCodeDocumentPosition.Create(Last, FDocument.GetLineLength(Last)));
end;

procedure TCustomThemedCodeEditor.KeyDown(var Key: Word; Shift: TShiftState);
var P: TCodeDocumentPosition; Ctrl, Extend, CompletionOpen: Boolean;
begin
  inherited; if (Key = 0) or not Enabled then Exit; Ctrl := ssCtrl in Shift; Extend := ssShift in Shift;
  if Ctrl and not (ssAlt in Shift) then
    case Key of
      VK_ADD, VK_OEM_PLUS: begin ZoomIn; Key := 0; Exit; end;
      VK_SUBTRACT, VK_OEM_MINUS: begin ZoomOut; Key := 0; Exit; end;
      Ord('0'), VK_NUMPAD0: begin ResetZoom; Key := 0; Exit; end;
    end;
  CompletionOpen := (FPopup <> nil) and FPopup.PopupVisible;
  if (FPopup <> nil) and FPopup.PopupVisible then
    case Key of
      VK_UP: begin FPopup.ListControl.MoveSelection(-1); Key := 0; Exit; end;
      VK_DOWN: begin FPopup.ListControl.MoveSelection(1); Key := 0; Exit; end;
      VK_RETURN, VK_TAB: begin FPopup.ListControl.InvokeSelectedItem; Key := 0; Exit; end;
      VK_ESCAPE: begin HideCompletion; Key := 0; Exit; end;
    end;
  if Ctrl then
    case Key of
      Ord('Z'): begin if Extend then Redo else Undo; Key := 0; Exit; end;
      Ord('Y'): begin Redo; Key := 0; Exit; end;
      Ord('C'): begin Copy; Key := 0; Exit; end;
      Ord('X'): begin Cut; Key := 0; Exit; end;
      Ord('V'): begin Paste; Key := 0; Exit; end;
      Ord('A'): begin SelectAll; Key := 0; Exit; end;
      VK_SPACE: begin TriggerCompletion; Key := 0; Exit; end;
      VK_F2: begin ToggleBookmark; Key := 0; Exit; end;
    end;
  case Key of
    VK_LEFT: MoveHorizontal(-1, Extend, Ctrl);
    VK_RIGHT: MoveHorizontal(1, Extend, Ctrl);
    VK_UP: MoveVertical(-1, Extend);
    VK_DOWN: MoveVertical(1, Extend);
    VK_PRIOR: MoveVertical(-FMetrics.VisibleRows, Extend);
    VK_NEXT: MoveVertical(FMetrics.VisibleRows, Extend);
    VK_HOME: begin FCaret.PreferredColumn := -1; P := FCaret.Position; P.ColumnIndex := 0; if Ctrl then P.LineIndex := 0; SetCaretPosition(P, Extend); end;
    VK_END: begin FCaret.PreferredColumn := -1; P := FCaret.Position; if Ctrl then P.LineIndex := FDocument.LineCount - 1; P.ColumnIndex := FDocument.GetLineLength(P.LineIndex); SetCaretPosition(P, Extend); end;
    VK_BACK: begin DeleteKey(True, Ctrl); if CompletionOpen and (FCaret.Position.Compare(FCompletionStart) >= 0) and not Ctrl then UpdateCompletionFilter; end;
    VK_DELETE: DeleteKey(False, Ctrl);
    VK_TAB: Indent(Extend);
    VK_RETURN: InsertText(NewLineText, 'New Line');
    VK_F2: if Extend then PreviousBookmark else NextBookmark;
    VK_F3: FindNext(not Extend);
    VK_F9: ToggleBreakpoint;
    VK_F12: TryNavigateFromPosition(FCaret.Position);
    VK_ESCAPE: begin HideCompletion; FSelection.Clear(FCaret.Position); end;
  else Exit;
  end;
  Key := 0;
end;
procedure TCustomThemedCodeEditor.KeyPress(var Key: Char);
var Input: string;
begin
  inherited; if not Enabled or ReadOnly or (Key = #0) or Key.IsControl then Exit;
  if GetKeyState(VK_CONTROL) < 0 then begin Key := #0; Exit; end;
  if (Ord(Key) >= $D800) and (Ord(Key) <= $DBFF) then begin FPendingSurrogate := Key; Key := #0; Exit; end;
  Input := Key;
  if (Ord(Key) >= $DC00) and (Ord(Key) <= $DFFF) then
  begin
    if FPendingSurrogate = #0 then begin Key := #0; Exit; end;
    Input := FPendingSurrogate + Input;
  end;
  FPendingSurrogate := #0; InsertText(Input, 'Typing');
  if (FPopup <> nil) and FPopup.PopupVisible and FOptions.FilterCompletionWhileTyping then UpdateCompletionFilter
  else if FOptions.AutoShowCompletion and ((Key = '.') or CodeIsWord(Key)) then
  begin if Key = '.' then FCompletionTrigger := cctDot else FCompletionTrigger := cctTyping; FCompletionTick := GetTickCount64 + UInt64(FOptions.CompletionDelay); end;
  Key := #0;
end;
procedure TCustomThemedCodeEditor.WMGetDlgCode(var Message: TWMGetDlgCode);
begin inherited; Message.Result := Message.Result or DLGC_WANTARROWS or DLGC_WANTCHARS or DLGC_WANTTAB; end;
procedure TCustomThemedCodeEditor.WMCaptureChanged(var Message: TMessage);
begin inherited; FDragging := False; FPendingTextDrag := False; end;
procedure TCustomThemedCodeEditor.WMSetFocus(var Message: TWMSetFocus);
begin inherited; FCaretVisible := True; FBlinkTick := GetTickCount64; Invalidate; end;
procedure TCustomThemedCodeEditor.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  if (FPopup = nil) or not FPopup.HandleAllocated or
    ((Message.FocusedWnd <> FPopup.Handle) and not IsChild(FPopup.Handle, Message.FocusedWnd)) then HideCompletion;
  FDragging := False; MouseCapture := False; FComposition := ''; FPendingSurrogate := #0; Invalidate;
end;
procedure TCustomThemedCodeEditor.WMIMEComposition(var Message: TMessage);
var Context: HIMC; Count: Longint; Text: string; Form: TCompositionForm; P: TPoint;
begin
  if ReadOnly then begin Message.Result := 0; Exit; end;
  Context := ImmGetContext(Handle);
  if Context = 0 then begin inherited; Exit; end;
  try
    UpdateLayout; if FMap.Count = 0 then begin inherited; Exit; end;
    P := CodePositionPoint(FCaret.Position, FMetrics, FMap, FDocument, FFirstVisibleLine, FHorizontalOffset, FOptions.TabSize);
    Form := Default(TCompositionForm); Form.dwStyle := CFS_POINT; Form.ptCurrentPos := P; ImmSetCompositionWindow(Context, @Form);
    if Message.LParam and GCS_RESULTSTR <> 0 then
    begin
      Count := ImmGetCompositionStringW(Context, GCS_RESULTSTR, nil, 0); SetLength(Text, Max(0, Count div 2));
      if Count > 0 then ImmGetCompositionStringW(Context, GCS_RESULTSTR, PWideChar(Text), Count);
      FComposition := ''; InsertText(Text, 'IME'); Message.Result := 0; Exit;
    end;
  finally ImmReleaseContext(Handle, Context); end;
  inherited;
end;

procedure TCustomThemedCodeEditor.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var Hit: TCodeEditorHitInfo; Last: Integer; Breakpoint: TCodeBreakpoint;
begin
  inherited; if not Enabled or (Button <> mbLeft) then Exit; FMousePoint := Point(X, Y); FMouseShift := Shift; if CanFocus then SetFocus;
  if ssDouble in Shift then begin DblClick; Exit; end;
  FDoubleClickTick := 0;
  HideCompletion; Hit := HitTest(Point(X, Y));
  case Hit.Area of
    chaBreakpointGutter:
      begin
        if ssShift in Shift then
        begin
          if FBreakpoints.TryGet(Hit.Position.LineIndex, Breakpoint) then FBreakpoints.SetEnabled(Hit.Position.LineIndex, not Breakpoint.Enabled);
        end
        else FBreakpoints.Toggle(Hit.Position.LineIndex);
        Exit;
      end;
    chaBookmarkGutter: begin FBookmarks.Toggle(Hit.Position); Exit; end;
    chaFoldingGutter: begin FFolds.Toggle(FFolds.FindHeader(Hit.Position.LineIndex)); Exit; end;
    chaLineNumber, chaSelectionMargin:
      begin
        FAnchor := TCodeDocumentPosition.Create(Hit.Position.LineIndex, 0); Last := Min(FDocument.LineCount - 1, Hit.Position.LineIndex + 1);
        SetCaretPosition(FAnchor, False); FSelection.SetSelection(FAnchor, TCodeDocumentPosition.Create(Last, IfThen(Last = Hit.Position.LineIndex, FDocument.GetLineLength(Last), 0)));
      end;
    chaText:
      begin
        if (FSelectionMode = csmNormal) and not FSelection.IsEmpty and FSelection.Range.Contains(Hit.Position) and
          not (ssShift in Shift) and not (ssAlt in Shift) then
        begin
          FDoubleClickRange := FSelection.Range; FDoubleClickPoint := Point(X, Y);
          FDoubleClickTick := GetTickCount64; FDoubleClickVersion := FDocument.Version;
          FPendingTextDrag := True; FTextDragStart := Point(X, Y); FTextDragText := FDocument.GetTextRange(FSelection.Range);
          FTextDragVersion := FDocument.Version; MouseCapture := True; Exit;
        end;
        if (ssCtrl in Shift) and TryNavigateFromPosition(Hit.Position) then Exit;
        if ssAlt in Shift then FSelectionMode := csmColumn;
        SetCaretPosition(Hit.Position, ssShift in Shift); if not (ssShift in Shift) then FAnchor := Hit.Position;
      end;
  else Exit;
  end;
  FDragging := True; MouseCapture := True;
end;
procedure TCustomThemedCodeEditor.MouseMove(Shift: TShiftState; X, Y: Integer);
var Hit: TCodeEditorHitInfo; PreviousHover: Boolean; PreviousRange: TCodeDocumentRange;
begin
  inherited;
  if (FToolTip <> nil) and ((FMousePoint.X <> X) or (FMousePoint.Y <> Y)) then FToolTip.HideHint;
  FMousePoint := Point(X, Y);
  if FPendingTextDrag then
  begin
    if (Abs(X - FTextDragStart.X) >= GetSystemMetrics(SM_CXDRAG)) or (Abs(Y - FTextDragStart.Y) >= GetSystemMetrics(SM_CYDRAG)) then
    begin
      FPendingTextDrag := False; FDoubleClickTick := 0; FStartingTextDrag := True;
      try MouseCapture := False; BeginDrag(True);
      finally FStartingTextDrag := False; if not Dragging then FTextDragText := ''; end;
    end;
    Exit;
  end;
  if FDragging then
  begin
    if Y < 0 then SetFirstVisibleLine(FFirstVisibleLine - 1) else if Y >= FMetrics.Bounds.Bottom then SetFirstVisibleLine(FFirstVisibleLine + 1);
    Hit := HitTest(Point(EnsureRange(X, FMetrics.TextBounds.Left, FMetrics.TextBounds.Right - 1), EnsureRange(Y, 0, Max(0, FMetrics.Bounds.Bottom - 1))));
    FCaret.Position := Hit.Position; FSelection.SetSelection(FAnchor, Hit.Position);
  end
  else
  begin
    PreviousHover := FHasNavigationHover; PreviousRange := FNavigationWord.Range;
    FHoverTick := GetTickCount64 + 400;
    Hit := HitTest(Point(X, Y)); FHasNavigationHover := (ssCtrl in Shift) and (Hit.Area = chaText);
    if FHasNavigationHover then begin FNavigationWord := GetWordHitInfoAt(Hit.Position); FHasNavigationHover := FNavigationWord.Word <> ''; end;
    if FHasNavigationHover then Cursor := crHandPoint else Cursor := crIBeam;
    if (PreviousHover <> FHasNavigationHover) or (FHasNavigationHover and
      ((PreviousRange.Start.LineIndex <> FNavigationWord.Range.Start.LineIndex) or
       (PreviousRange.Start.ColumnIndex <> FNavigationWord.Range.Start.ColumnIndex) or
       (PreviousRange.Finish.LineIndex <> FNavigationWord.Range.Finish.LineIndex) or
       (PreviousRange.Finish.ColumnIndex <> FNavigationWord.Range.Finish.ColumnIndex))) then InvalidateContent;
  end;
end;
procedure TCustomThemedCodeEditor.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if Button = mbLeft then
  begin
    if FPendingTextDrag then begin FPendingTextDrag := False; SetCaretPosition(HitTest(Point(X, Y)).Position, False); end;
    FDragging := False; MouseCapture := False;
    if not FStartingTextDrag and not Dragging then FTextDragText := '';
  end;
end;
procedure TCustomThemedCodeEditor.DblClick;
var Hit: TCodeEditorHitInfo; Word: TCodeEditorWordHitInfo; Text: string; First, Last: Integer;
  Selected, Block: TCodeDocumentRange;
begin
  inherited; FPendingTextDrag := False; FDragging := False; MouseCapture := False; HideCompletion;
  Hit := HitTest(FMousePoint); if Hit.Area <> chaText then Exit;
  Selected := FSelection.Range;
  if Selected.IsEmpty and (FDoubleClickTick <> 0) and (FDoubleClickVersion = FDocument.Version) and
    (GetTickCount64 - FDoubleClickTick <= GetDoubleClickTime) and
    (Abs(FMousePoint.X - FDoubleClickPoint.X) <= GetSystemMetrics(SM_CXDOUBLECLK)) and
    (Abs(FMousePoint.Y - FDoubleClickPoint.Y) <= GetSystemMetrics(SM_CYDOUBLECLK)) then Selected := FDoubleClickRange;
  FDoubleClickTick := 0;
  FSelectionMode := csmNormal;
  if ssShift in FMouseShift then
  begin
    First := Hit.Position.LineIndex; Last := Min(FDocument.LineCount - 1, First + 1);
    GoToRange(TCodeDocumentRange.Create(TCodeDocumentPosition.Create(First, 0),
      TCodeDocumentPosition.Create(Last, IfThen(Last = First, FDocument.GetLineLength(Last), 0)))); Exit;
  end;
  if not Selected.IsEmpty and Selected.Contains(Hit.Position) then
  begin
    if not IsLargeFileMode and CodeFindEnclosingBlock(FDocument.GetSnapshot, FHighlighter, GetLanguageName, Selected, Block) then
      GoToRange(Block)
    else GoToRange(Selected);
    Exit;
  end;
  Word := GetWordHitInfoAt(Hit.Position);
  if Word.Word <> '' then begin GoToRange(Word.Range); Exit; end;
  Text := FDocument.GetLineText(Hit.Position.LineIndex); if Text = '' then Exit;
  First := Hit.Position.ColumnIndex; if First >= Length(Text) then First := CodePreviousTextElement(Text, Length(Text));
  Last := CodeNextTextElement(Text, First);
  if Text[First + 1].IsWhiteSpace then
  begin
    while (First > 0) and Text[First].IsWhiteSpace do Dec(First);
    while (Last < Length(Text)) and Text[Last + 1].IsWhiteSpace do Inc(Last);
  end
  else if CharInSet(Text[First + 1], [':', '=', '+', '-', '*', '/', '<', '>', '!', '&', '|', '^', '%']) then
  begin
    while (First > 0) and CharInSet(Text[First], [':', '=', '+', '-', '*', '/', '<', '>', '!', '&', '|', '^', '%']) do Dec(First);
    while (Last < Length(Text)) and CharInSet(Text[Last + 1], [':', '=', '+', '-', '*', '/', '<', '>', '!', '&', '|', '^', '%']) do Inc(Last);
  end;
  GoToRange(TCodeDocumentRange.Create(TCodeDocumentPosition.Create(Hit.Position.LineIndex, First), TCodeDocumentPosition.Create(Hit.Position.LineIndex, Last)));
end;
procedure TCustomThemedCodeEditor.DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var Editor: TCustomThemedCodeEditor; Hit: TCodeEditorHitInfo;
begin
  Accept := False;
  if (Source is TCustomThemedCodeEditor) and Enabled and not ReadOnly then
  begin
    Editor := TCustomThemedCodeEditor(Source); Hit := HitTest(Point(X, Y));
    Accept := (Editor.FTextDragText <> '') and (Editor.FTextDragVersion = Editor.Document.Version) and (Hit.Area = chaText);
    if Accept then FCaret.Position := Hit.Position;
  end;
  if Assigned(OnDragOver) then inherited;
end;
procedure TCustomThemedCodeEditor.DragDrop(Source: TObject; X, Y: Integer);
var Editor: TCustomThemedCodeEditor; Hit: TCodeEditorHitInfo; Position: TCodeDocumentPosition;
begin
  if (Source is TCustomThemedCodeEditor) and Enabled and not ReadOnly then
  begin
    Editor := TCustomThemedCodeEditor(Source);
    Hit := HitTest(Point(X, Y));
    if (Editor.FTextDragText <> '') and (Editor.FTextDragVersion = Editor.Document.Version) and (Hit.Area = chaText) then
    begin
      Position := Hit.Position;
      if Editor = Self then DropSelectedText(Position, GetKeyState(VK_CONTROL) < 0)
      else begin GoToRange(TCodeDocumentRange.Create(Position, Position)); InsertText(Editor.FTextDragText, 'Drop text'); end;
    end;
  end;
  inherited;
end;
procedure TCustomThemedCodeEditor.DoEndDrag(Target: TObject; X, Y: Integer);
begin FPendingTextDrag := False; FTextDragText := ''; FDragging := False; inherited; end;
function TCustomThemedCodeEditor.DropSelectedText(const Position: TCodeDocumentPosition; const CopyText: Boolean): Boolean;
var Text: string; Range: TCodeDocumentRange; Offset, First, Last: Integer; Target: TCodeDocumentPosition;
begin
  Result := False; if ReadOnly or FSelection.IsEmpty or (FSelectionMode <> csmNormal) then Exit;
  Range := FSelection.Range; Text := FDocument.GetTextRange(Range); if Text = '' then Exit;
  Offset := FDocument.GetOffset(ClampCaret(Position)); First := FDocument.GetOffset(Range.Start); Last := FDocument.GetOffset(Range.Finish);
  if not CopyText and (Offset >= First) and (Offset <= Last) then Exit;
  FUndo.BeginGroup(FDocument, 'Drop text');
  try
    if not CopyText then
    begin ReplaceRange(Range, '', 'Move text'); if Offset > Last then Dec(Offset, Last - First); end;
    Target := FDocument.GetPosition(Offset); GoToRange(TCodeDocumentRange.Create(Target, Target)); InsertText(Text, 'Drop text');
  finally FUndo.EndGroup(FDocument); end;
  GoToRange(TCodeDocumentRange.Create(FDocument.GetPosition(Offset), FDocument.GetPosition(Offset + Length(Text)))); Result := True;
end;
procedure TCustomThemedCodeEditor.CMMouseLeave(var Message: TMessage);
var HadHover: Boolean;
begin
  inherited; FHoverTick := 0; HadHover := FHasNavigationHover; FHasNavigationHover := False;
  if FToolTip <> nil then FToolTip.HideHint; Cursor := crIBeam; if HadHover then InvalidateContent;
end;
function TCustomThemedCodeEditor.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
var Steps: Integer;
begin
  if not Enabled then Exit(inherited DoMouseWheel(Shift, WheelDelta, MousePos));
  if FWheelShift <> Shift then begin FWheelRemainder := 0; FWheelShift := Shift; end;
  Inc(FWheelRemainder, WheelDelta); Steps := FWheelRemainder div WHEEL_DELTA;
  FWheelRemainder := FWheelRemainder mod WHEEL_DELTA;
  if Steps <> 0 then
    if ssCtrl in Shift then Zoom := FZoom + Steps * 10
    else if ssShift in Shift then SetHorizontalOffset(FHorizontalOffset - Steps * Round(FMetrics.CharWidth * 3))
    else SetFirstVisibleLine(FFirstVisibleLine - Steps * 3);
  Result := True;
end;

procedure TCustomThemedCodeEditor.LoadFromFile(const Path: string; const Encoding: TCodeTextEncoding);
begin HideCompletion; FDocument.LoadFromFile(Path, Encoding, FOptions.LargeFileThresholdBytes); SetLanguageByExtension(TPath.GetExtension(Path)); FUndo.Clear; StateChanged; end;
procedure TCustomThemedCodeEditor.SaveToFile(const Path: string);
begin FDocument.SaveToFile(Path); FUndo.BreakMerge; StateChanged; end;
function TCustomThemedCodeEditor.FindAll(const Pattern: string; const MatchCase: Boolean): TArray<TCodeSearchMatch>;
var Options: TCodeSearchOptions;
begin Options := TCodeSearchOptions.Create(Pattern); Options.MatchCase := MatchCase; Result := FindAll(Options); end;
function TCustomThemedCodeEditor.FindAll(const Options: TCodeSearchOptions): TArray<TCodeSearchMatch>;
var Search: TCodeSearchOptions;
begin
  Search := Options;
  if Search.MaxResults = 0 then if IsLargeFileMode then Search.MaxResults := FOptions.MaximumSearchResultsInLargeFiles else Search.MaxResults := FOptions.MaximumSearchResults;
  Result := TCodeSearchEngine.Search(FDocument, Search); SetSearchMatches(Result);
end;
procedure TCustomThemedCodeEditor.SetSearchMatches(const Matches: TArray<TCodeSearchMatch>);
begin FSearchMatches := System.Copy(Matches); FActiveSearch := -1; RebuildMarkers; Invalidate; end;
procedure TCustomThemedCodeEditor.ClearSearchMatches;
begin SetSearchMatches(nil); end;
function TCustomThemedCodeEditor.FindNext(const Forward: Boolean): Boolean;
begin
  Result := Length(FSearchMatches) > 0; if not Result then Exit;
  if Forward then FActiveSearch := (FActiveSearch + 1) mod Length(FSearchMatches)
  else if FActiveSearch < 0 then FActiveSearch := High(FSearchMatches)
  else FActiveSearch := (FActiveSearch + Length(FSearchMatches) - 1) mod Length(FSearchMatches);
  GoToRange(FSearchMatches[FActiveSearch].Range);
end;
function TCustomThemedCodeEditor.ReplaceAll(const Options: TCodeSearchOptions; const Replacement: string): Integer;
var Hits: TArray<TCodeSearchMatch>; I: Integer;
begin
  Result := 0; if ReadOnly then Exit; Hits := TCodeSearchEngine.Search(FDocument, Options);
  FUndo.BeginGroup(FDocument, 'Replace All');
  try for I := High(Hits) downto 0 do ReplaceRange(Hits[I].Range, Replacement, 'Replace'); Result := Length(Hits);
  finally FUndo.EndGroup(FDocument); end;
end;
procedure TCustomThemedCodeEditor.ToggleFold;
var Index: Integer; Region: TCodeFoldRegion;
begin
  Index := FFolds.FindHeader(FCaret.Position.LineIndex);
  if Index < 0 then for Region in FFolds.Regions do if Region.Range.Contains(FCaret.Position) then begin Index := FFolds.FindHeader(Region.Range.Start.LineIndex); Break; end;
  FFolds.Toggle(Index);
  if FFolds.IsHidden(FCaret.Position.LineIndex) and (Index >= 0) then SetCaretPosition(FFolds.Regions[Index].Range.Start, False);
end;
procedure TCustomThemedCodeEditor.CollapseAllFolds;
begin FFolds.SetAllCollapsed(True); SetCaretPosition(TCodeDocumentPosition.Create(0, 0), False); end;
procedure TCustomThemedCodeEditor.ExpandAllFolds;
begin FFolds.SetAllCollapsed(False); end;
procedure TCustomThemedCodeEditor.RebuildSymbolIndex;
begin ScheduleAnalysis; end;
function TCustomThemedCodeEditor.GetWordHitInfoAt(const Position: TCodeDocumentPosition): TCodeEditorWordHitInfo;
begin Result := CodeWordAt(FDocument, FDocument.Clamp(Position)); end;
function TCustomThemedCodeEditor.GetContainingSymbol(const Position: TCodeDocumentPosition; out Symbol: TCodeEditorSymbolInfo): Boolean;
begin Result := FSymbolIndex.GetContaining(Position, Symbol); end;
function TCustomThemedCodeEditor.GetTextRange(const Range: TCodeDocumentRange): string;
begin Result := FDocument.GetTextRange(Range); end;
procedure TCustomThemedCodeEditor.GoToRange(const Range: TCodeDocumentRange);
begin SetCaretPosition(Range.Start, False); FAnchor := FCaret.Position; FSelection.SetSelection(ClampCaret(Range.Start), ClampCaret(Range.Finish, not Range.IsEmpty)); end;
procedure TCustomThemedCodeEditor.GoToLine(const LineIndex: Integer);
begin SetCaretPosition(TCodeDocumentPosition.Create(LineIndex, 0), False); end;
procedure TCustomThemedCodeEditor.ToggleBookmark;
begin FBookmarks.Toggle(FCaret.Position); end;
procedure TCustomThemedCodeEditor.NextBookmark;
var B: TCodeBookmark;
begin if FBookmarks.Next(FCaret.Position.LineIndex, True, B) then GoToLine(B.LineIndex); end;
procedure TCustomThemedCodeEditor.PreviousBookmark;
var B: TCodeBookmark;
begin if FBookmarks.Next(FCaret.Position.LineIndex, False, B) then GoToLine(B.LineIndex); end;
procedure TCustomThemedCodeEditor.Undo;
var P: TCodeDocumentPosition;
begin HideCompletion; if FUndo.Undo(FDocument, P) then SetCaretPosition(P, False); end;
procedure TCustomThemedCodeEditor.Redo;
var P: TCodeDocumentPosition;
begin HideCompletion; if FUndo.Redo(FDocument, P) then SetCaretPosition(P, False); end;
function TCustomThemedCodeEditor.SelectionText: string;
var R: TCodeDocumentRange; I, First, Count: Integer; Builder: TStringBuilder;
begin
  R := FSelection.Range; if FSelectionMode <> csmColumn then Exit(FDocument.GetTextRange(R));
  First := Min(R.Start.ColumnIndex, R.Finish.ColumnIndex); Count := Abs(R.Start.ColumnIndex - R.Finish.ColumnIndex);
  Builder := TStringBuilder.Create;
  try
    for I := R.Start.LineIndex to R.Finish.LineIndex do begin if I > R.Start.LineIndex then Builder.Append(sLineBreak); Builder.Append(System.Copy(FDocument.GetLineText(I), First + 1, Count)); end;
    Result := Builder.ToString;
  finally Builder.Free; end;
end;
procedure TCustomThemedCodeEditor.Copy;
begin if not FSelection.IsEmpty then Clipboard.AsText := CodeNormalizeNewLines(SelectionText).Replace(#10, sLineBreak); end;
procedure TCustomThemedCodeEditor.Cut;
begin if ReadOnly then Exit; Copy; if not FSelection.IsEmpty then InsertText('', 'Cut'); end;
procedure TCustomThemedCodeEditor.Paste;
begin if not ReadOnly and Clipboard.HasFormat(CF_UNICODETEXT) then InsertText(Clipboard.AsText, 'Paste'); end;
procedure TCustomThemedCodeEditor.SelectAll;
begin FSelectionMode := csmNormal; GoToRange(TCodeDocumentRange.Create(TCodeDocumentPosition.Create(0, 0), FDocument.GetPosition(FDocument.TextLength))); end;

procedure TCustomThemedCodeEditor.TriggerCompletion(const Trigger: TCodeEditorCompletionTrigger);
var Items: TList<TCodeCompletionItem>; Provider: ICodeCompletionProvider; Keyword: ICodeCompletionProvider;
  Symbol: TCodeEditorSymbolInfo; Item: TCodeCompletionItem;
begin
  if ReadOnly or not Enabled then Exit;
  if CanFocus then SetFocus;
  Items := TList<TCodeCompletionItem>.Create;
  try
    Keyword := TKeywordCompletionProvider.Create(FLanguage); Items.AddRange(Keyword.GetCompletions(FDocument, FCaret.Position, Trigger));
    for Provider in FCompletionProviders do Items.AddRange(Provider.GetCompletions(FDocument, FCaret.Position, Trigger));
    for Symbol in FSymbolIndex.Items do
    begin Item := Default(TCodeCompletionItem); Item.DisplayText := Symbol.Name; Item.InsertText := Symbol.Name; Item.FilterText := Symbol.Name; Item.SortText := Symbol.Name; Item.Description := Symbol.SignatureText; Item.Kind := cciMethod; Items.Add(Item); end;
    FCompletions := Items.ToArray;
    if Assigned(FOnCompletion) then FOnCompletion(Self, FCaret.Position, FCompletions);
    FCompletionStart := CodeWordAt(FDocument, FCaret.Position, True).Range.Start; UpdateCompletionFilter;
  finally Items.Free; end;
end;
procedure TCustomThemedCodeEditor.UpdateCompletionFilter;
var Item: TCodeCompletionItem; Row: TThemedDropdownItem; I, J: Integer; Filter, Compare: string;
  P: TPoint; Bounds: TRect; Monitor: TMonitor;
begin
  if not HandleAllocated or (Parent = nil) then Exit;
  if FPopup = nil then
  begin
    FPopup := TThemedDropdownPopupForm.Create(Self); FPopup.OnItemSelected := CompletionInvoked;
    TCodeDropdownListAccess(FPopup.ListControl).Font.Assign(Font);
    FApplicationEvents := TApplicationEvents.Create(Self); FApplicationEvents.OnMessage := PopupMessage;
    FApplicationEvents.OnDeactivate := ApplicationDeactivated;
  end;
  FPopup.ApplyTheme(Palette); FPopup.ListControl.ItemHeight := FOptions.CompletionItemHeight;
  Filter := LowerCase(FDocument.GetTextRange(TCodeDocumentRange.Create(FCompletionStart, FCaret.Position)));
  FCompletionRows.Clear; FPopup.ListControl.SetItems(FCompletionRows); FCompletionCollection.Clear;
  for I := 0 to High(FCompletions) do
  begin
    Item := FCompletions[I]; Compare := Item.FilterText; if Compare = '' then Compare := Item.DisplayText;
    if (Filter <> '') and not LowerCase(Compare).StartsWith(Filter) then Continue;
    Row := FCompletionCollection.AddItem(Item.DisplayText); Row.Tag := I; FCompletionRows.Add(Row);
    if Item.Image <> nil then Row.Image.Assign(Item.Image);
  end;
  for I := 1 to FCompletionRows.Count - 1 do
  begin
    Row := FCompletionRows[I]; J := I - 1;
    while (J >= 0) and ((FCompletions[FCompletionRows[J].Tag].Priority < FCompletions[Row.Tag].Priority) or
      ((FCompletions[FCompletionRows[J].Tag].Priority = FCompletions[Row.Tag].Priority) and (CompareText(FCompletionRows[J].Text, Row.Text) > 0))) do
    begin FCompletionRows[J + 1] := FCompletionRows[J]; Dec(J); end;
    FCompletionRows[J + 1] := Row;
  end;
  if FCompletionRows.Count = 0 then begin HideCompletion; Exit; end;
  FPopup.ListControl.SetItems(FCompletionRows); FPopup.ListControl.SelectedIndex := 0;
  P := CodePositionPoint(FCaret.Position, FMetrics, FMap, FDocument, FFirstVisibleLine, FHorizontalOffset, FOptions.TabSize);
  P.Y := P.Y + FMetrics.LineHeight; P := ClientToScreen(P); FPopup.SyncSize(ScaleValue(360));
  Bounds := Rect(P.X, P.Y, P.X + FPopup.Width, P.Y + FPopup.Height); Monitor := Screen.MonitorFromPoint(P);
  if Bounds.Right > Monitor.WorkareaRect.Right then OffsetRect(Bounds, Monitor.WorkareaRect.Right - Bounds.Right, 0);
  if Bounds.Bottom > Monitor.WorkareaRect.Bottom then OffsetRect(Bounds, 0, -Bounds.Height - FMetrics.LineHeight);
  if Bounds.Left < Monitor.WorkareaRect.Left then OffsetRect(Bounds, Monitor.WorkareaRect.Left - Bounds.Left, 0);
  FPopup.ShowPopup(Self, Bounds);
end;
procedure TCustomThemedCodeEditor.CompletionInvoked(Sender: TObject; Item: TThemedDropdownItem);
var Completion: TCodeCompletionItem; Range: TCodeDocumentRange;
begin
  if (Item.Tag < 0) or (Item.Tag >= Length(FCompletions)) then Exit;
  Completion := FCompletions[Item.Tag]; Range := TCodeDocumentRange.Create(FCompletionStart, FCaret.Position);
  HideCompletion; ReplaceRange(Range, Completion.InsertText, 'Completion');
end;
procedure TCustomThemedCodeEditor.HideCompletion;
begin FCompletionTick := 0; if FPopup <> nil then FPopup.ClosePopup; end;
procedure TCustomThemedCodeEditor.PopupMessage(var Message: TMsg; var Handled: Boolean);
var EditorBounds: TRect; P: TPoint;
begin
  if (FPopup = nil) or not FPopup.PopupVisible then Exit;
  case Message.message of
    WM_LBUTTONDOWN, WM_RBUTTONDOWN, WM_MBUTTONDOWN, WM_NCLBUTTONDOWN, WM_NCRBUTTONDOWN:
    begin
    P := ClientToScreen(Point(0, 0)); EditorBounds := Rect(P.X, P.Y, P.X + Width, P.Y + Height);
    if not PtInRect(FPopup.BoundsRect, Message.pt) and not PtInRect(EditorBounds, Message.pt) then HideCompletion;
    end;
  end;
end;
procedure TCustomThemedCodeEditor.ApplicationDeactivated(Sender: TObject);
begin HideCompletion; end;
procedure TCustomThemedCodeEditor.SetDiagnostics(const Diagnostics: TArray<TCodeDiagnostic>);
begin FDiagnostics := System.Copy(Diagnostics); RebuildMarkers; Invalidate; end;
function TCustomThemedCodeEditor.TryNavigateFromPosition(const Position: TCodeDocumentPosition): Boolean;
var Word: TCodeEditorWordHitInfo; Navigation: TCodeEditorNavigationResult; Handled: Boolean;
  Provider: ICodeEditorNavigationProvider; Symbol: TCodeEditorSymbolInfo;
begin
  Word := GetWordHitInfoAt(Position); Navigation := Default(TCodeEditorNavigationResult); Handled := False;
  if Assigned(FOnNavigate) then FOnNavigate(Self, Word, Navigation, Handled);
  if not Handled then for Provider in FNavigationProviders do if Provider.TryNavigate(FDocument, Word, Navigation) then begin Handled := True; Break; end;
  if not Handled and FSymbolIndex.Find(Word.Word, Symbol) then begin Navigation.Found := True; Navigation.Range := Symbol.NameRange; end;
  Result := Navigation.Found or Navigation.Success;
  if Result and ((Navigation.FileName = '') or SameText(Navigation.FileName, FDocument.FileName)) then GoToRange(Navigation.Range);
end;
procedure TCustomThemedCodeEditor.UpdateHover;
var Hit: TCodeEditorHitInfo; Word: TCodeEditorWordHitInfo; Info: TCodeEditorQuickInfo;
  Provider: ICodeEditorQuickInfoProvider; Handled: Boolean; Symbol: TCodeEditorSymbolInfo; Text: string; Fold: Integer;
  Diagnostic: TCodeDiagnostic; Breakpoint: TCodeBreakpoint;
begin
  Hit := HitTest(FMousePoint); Text := ''; Handled := False;
  if Hit.Area = chaBreakpointGutter then
  begin
    if FBreakpoints.TryGet(Hit.Position.LineIndex, Breakpoint) then
    begin
      Text := 'Breakpoint: enabled=' + BoolToStr(Breakpoint.Enabled, True);
      if Breakpoint.Condition <> '' then Text := Text + sLineBreak + 'Condition: ' + Breakpoint.Condition;
      if Breakpoint.HitCount > 0 then Text := Text + sLineBreak + 'Hit count: ' + IntToStr(Breakpoint.HitCount);
      if Breakpoint.LogMessage <> '' then Text := Text + sLineBreak + 'Log: ' + Breakpoint.LogMessage;
    end
    else for Diagnostic in FDiagnostics do
      if (Diagnostic.Range.Start.LineIndex = Hit.Position.LineIndex) and (Diagnostic.Severity <> cdsHidden) then Text := Text + Diagnostic.Code + ' ' + Diagnostic.MessageText + sLineBreak;
  end
  else if Hit.Area = chaFoldingGutter then
  begin Fold := FFolds.FindHeader(Hit.Position.LineIndex); if Fold >= 0 then Text := FFolds.Regions[Fold].PreviewText; end
  else if Hit.Area = chaText then
  begin
    for Diagnostic in FDiagnostics do
      if (Diagnostic.Severity <> cdsHidden) and Diagnostic.Range.Contains(Hit.Position) then Text := Text + Diagnostic.Code + ' ' + Diagnostic.MessageText + sLineBreak;
    if Text = '' then
    begin
    Word := GetWordHitInfoAt(Hit.Position); if Word.Word = '' then Exit;
    if Assigned(FOnSymbolHover) then FOnSymbolHover(Self, Word);
    Info := Default(TCodeEditorQuickInfo);
    if Assigned(FOnQuickInfo) then FOnQuickInfo(Self, Word, Info, Handled);
    if not Handled then for Provider in FQuickInfoProviders do if Provider.TryGetQuickInfo(FDocument, Word, Info) then begin Handled := True; Break; end;
    if not Handled and FSymbolIndex.Find(Word.Word, Symbol) then begin Info.Title := Symbol.Name; Info.SignatureText := Symbol.SignatureText; Info.Footer := Symbol.LanguageName; Handled := True; end;
    if not Handled and (FLanguage <> nil) and (FLanguage.Classify(Word.Word) <> chtIdentifier) then
    begin Info.Title := 'Keyword ' + Word.Word; Info.Description := 'Language keyword in ' + FLanguage.DisplayName; Info.Footer := FLanguage.Name; Handled := True; end;
    if Info.Title = '' then Info.Title := Info.Caption;
    if Handled then Text := Info.Title + sLineBreak + Info.SignatureText + sLineBreak + Info.Description + sLineBreak + Info.Footer;
    end;
  end;
  if Text = '' then Exit;
  if FToolTip = nil then begin FToolTip := TThemedToolTip.Create(Self); FToolTip.UseMarkup := False; FToolTip.ApplyTheme(Palette); end;
  if Text <> FHoverText then begin FHoverText := Text; FToolTip.SetToolTip(Self, Text); end;
  FToolTip.ShowForControl(Self, Rect(FMousePoint.X, FMousePoint.Y, FMousePoint.X + 1, FMousePoint.Y + ScaleValue(16)));
end;

function TCustomThemedCodeEditor.GetStatusInfo: TCodeEditorStatusInfo;
var I: Integer; Text: string; Tabs, Spaces: Boolean;
begin
  Result := Default(TCodeEditorStatusInfo); Result.Line := FCaret.Position.LineIndex + 1; Result.Column := FCaret.Position.ColumnIndex + 1;
  Result.LineCount := FDocument.LineCount; Result.TextLength := FDocument.TextLength; Result.LanguageName := GetLanguageName;
  Result.EncodingName := TNimbusLogTextCodec.Name(FDocument.Encoding); Result.EncodingReason := FDocument.EncodingReason;
  Result.FileName := FDocument.FileName; Result.HasByteOrderMark := FDocument.HasByteOrderMark;
  Result.EncodingConfidenceHigh := FDocument.EncodingConfidenceHigh; Result.LoadedByteLength := FDocument.LoadedByteLength;
  Result.NewLineKind := FDocument.NewLineKind; Result.HasMixedNewLines := Result.NewLineKind = cnkMixed;
  Result.IsModified := FDocument.IsModified; Result.IsReadOnly := ReadOnly; Result.IsLargeFile := IsLargeFileMode;
  Result.SelectionLength := Abs(FDocument.GetOffset(FSelection.Range.Finish) - FDocument.GetOffset(FSelection.Range.Start));
  if not FSelection.IsEmpty then Result.SelectionLineCount := FSelection.Range.Finish.LineIndex - FSelection.Range.Start.LineIndex + 1;
  if FStatusVersion <> FDocument.Version then
  begin
    FStatusIssues := []; Tabs := False; Spaces := False;
    for I := 0 to FDocument.LineCount - 1 do
    begin
      Text := FDocument.GetLineText(I); if Text.StartsWith(#9) then Tabs := True; if Text.StartsWith(' ') then Spaces := True;
      if (Text <> '') and CharInSet(Text[Length(Text)], [' ', #9]) then Include(FStatusIssues, cdiTrailingWhitespace);
    end;
    if Tabs and Spaces then Include(FStatusIssues, cdiMixedIndentation);
    if FDocument.GetLineLength(FDocument.LineCount - 1) > 0 then Include(FStatusIssues, cdiMissingFinalNewLine);
    FStatusVersion := FDocument.Version;
  end;
  Result.Issues := FStatusIssues;
  if Result.HasByteOrderMark then Include(Result.Issues, cdiHasBom);
  if not Result.EncodingConfidenceHigh then Include(Result.Issues, cdiEncodingLowConfidence);
  if Result.HasMixedNewLines then Include(Result.Issues, cdiMixedLineEndings);
  if Result.IsLargeFile then Include(Result.Issues, cdiLargeFileMode);
  if Result.IsReadOnly then Include(Result.Issues, cdiReadOnly);
  if Result.IsModified then Include(Result.Issues, cdiModified);
end;
procedure TCustomThemedCodeEditor.CleanupText(const Options: TCodeEditorTextCleanupOptions);
var Lines: TArray<string>; I, J, Columns, Spaces, K: Integer; Text, Next: string;
begin
  if ReadOnly or (Options = []) then Exit;
  Lines := FDocument.Text.Split([#10]);
  for I := 0 to High(Lines) do
  begin
    Text := Lines[I]; if ctcTrimTrailingWhitespace in Options then Text := TrimRight(Text);
    if ctcConvertTabsToSpaces in Options then
    begin
      Next := ''; Columns := 0;
      for J := 1 to Length(Text) do if Text[J] = #9 then begin Spaces := FOptions.TabSize - Columns mod FOptions.TabSize; Next := Next + StringOfChar(' ', Spaces); Inc(Columns, Spaces); end else begin Next := Next + Text[J]; Inc(Columns); end;
      Text := Next;
    end;
    if ctcConvertSpacesToTabs in Options then
    begin
      J := 1; while (J <= Length(Text)) and (Text[J] = ' ') do Inc(J); K := J - 1;
      Text := StringOfChar(#9, K div FOptions.TabSize) + StringOfChar(' ', K mod FOptions.TabSize) + System.Copy(Text, J, MaxInt);
    end;
    Lines[I] := Text;
  end;
  Next := string.Join(#10, Lines); if (ctcEnsureFinalNewLine in Options) and not Next.EndsWith(#10) then Next := Next + #10;
  ReplaceRange(TCodeDocumentRange.Create(TCodeDocumentPosition.Create(0, 0), FDocument.GetPosition(FDocument.TextLength)), Next, 'Cleanup');
end;
procedure TCustomThemedCodeEditor.TrimTrailingWhitespace;
begin CleanupText([ctcTrimTrailingWhitespace]); end;
procedure TCustomThemedCodeEditor.ConvertTabsToSpaces;
begin CleanupText([ctcConvertTabsToSpaces]); end;
procedure TCustomThemedCodeEditor.ConvertSpacesToTabs;
begin CleanupText([ctcConvertSpacesToTabs]); end;
procedure TCustomThemedCodeEditor.EnsureFinalNewLine;
begin CleanupText([ctcEnsureFinalNewLine]); end;

end.

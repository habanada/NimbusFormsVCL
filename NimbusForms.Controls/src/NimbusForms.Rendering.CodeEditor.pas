{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.CodeEditor;

interface

uses Winapi.Windows, System.Classes, System.SysUtils, System.Types, System.Generics.Collections,
  Vcl.Graphics, NimbusForms.Theming.Types, NimbusForms.Theming.Palette, NimbusForms.Rendering.Canvas,
  NimbusForms.Controls.CodeEditor.Types, NimbusForms.Controls.CodeEditor.Options,
  NimbusForms.Controls.CodeEditor.Theme, NimbusForms.Controls.CodeEditor.Document,
  NimbusForms.Controls.CodeEditor.Syntax, NimbusForms.Controls.CodeEditor.Services,
  NimbusForms.Controls.CodeEditor.Layout, NimbusForms.Controls.CodeEditor.Breakpoints;

type
  ICodeEditorRenderBackend = interface
    ['{D1A45955-3645-48BD-82AD-DA53D9D137AD}']
    procedure BeginFrame(const Canvas: TCanvas; const Bounds: TRect; const PPI: Integer);
    procedure EndFrame;
    procedure FillRect(const Bounds: TRect; const Color: TThemeColor);
    procedure StrokeRect(const Bounds: TRect; const Color: TThemeColor; const Width: Single);
    procedure Line(const A, B: TPoint; const Color: TThemeColor; const Width: Single);
    procedure Text(const Value: string; const Font: TFont; const Bounds: TRect; const Color: TThemeColor);
    function Measure(const Value: string; const Font: TFont): TSize;
    procedure PushClip(const Bounds: TRect);
    procedure PopClip;
  end;
  TCodeEditorGDIPlusBackend = class(TInterfacedObject, ICodeEditorRenderBackend)
  private
    FCanvas: INimbusRenderCanvas;
  public
    constructor Create(const Canvas: INimbusRenderCanvas);
    procedure BeginFrame(const Canvas: TCanvas; const Bounds: TRect; const PPI: Integer);
    procedure EndFrame;
    procedure FillRect(const Bounds: TRect; const Color: TThemeColor);
    procedure StrokeRect(const Bounds: TRect; const Color: TThemeColor; const Width: Single);
    procedure Line(const A, B: TPoint; const Color: TThemeColor; const Width: Single);
    procedure Text(const Value: string; const Font: TFont; const Bounds: TRect; const Color: TThemeColor);
    function Measure(const Value: string; const Font: TFont): TSize;
    procedure PushClip(const Bounds: TRect);
    procedure PopClip;
  end;
  TCodeCommentAdornmentStyle = class(TPersistent)
  public
    ForeColor, BackColor, BorderColor: TThemeColor;
    FontStyle: TFontStyles;
    FontScale: Single;
    RightSpacingColumns: Integer;
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  end;
  TCodeCommentAdornmentRule = class(TCollectionItem)
  private
    FKeyword: string;
    FForeColor, FBackColor, FBorderColor: TThemeColor;
    FFontStyle: TFontStyles;
    FFontScale: Single;
    FMatchCase, FWholeWord: Boolean;
    FStyle: TCodeCommentAdornmentStyle;
    FOwnsStyle: Boolean;
    procedure SetStyle(const Value: TCodeCommentAdornmentStyle);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Keyword: string read FKeyword write FKeyword;
    property ForeColor: TThemeColor read FForeColor write FForeColor;
    property BackColor: TThemeColor read FBackColor write FBackColor;
    property BorderColor: TThemeColor read FBorderColor write FBorderColor;
    property FontStyle: TFontStyles read FFontStyle write FFontStyle;
    property FontScale: Single read FFontScale write FFontScale;
    property MatchCase: Boolean read FMatchCase write FMatchCase default False;
    property WholeWord: Boolean read FWholeWord write FWholeWord default True;
    property Style: TCodeCommentAdornmentStyle read FStyle write SetStyle;
  end;
  TCodeCommentStyles = class(TOwnedCollection)
  private
    FStyles: array[0..7] of TCodeCommentAdornmentStyle;
    function GetRule(const Index: Integer): TCodeCommentAdornmentRule;
    function GetStyle(const Index: Integer): TCodeCommentAdornmentStyle;
  public
    constructor Create(Owner: TPersistent);
    destructor Destroy; override;
    function AddKeyword(const Keyword: string; const ForeColor, BackColor, BorderColor: TThemeColor): TCodeCommentAdornmentRule; overload;
    function AddKeyword(const Keyword: string; Style: TCodeCommentAdornmentStyle): TCodeCommentAdornmentRule; overload;
    procedure ResetDefaultRules;
    function Find(const Word: string): TCodeCommentAdornmentRule;
    property Rules[const Index: Integer]: TCodeCommentAdornmentRule read GetRule; default;
    property Todo: TCodeCommentAdornmentStyle index 0 read GetStyle;
    property Note: TCodeCommentAdornmentStyle index 1 read GetStyle;
    property Fixme: TCodeCommentAdornmentStyle index 2 read GetStyle;
    property Hack: TCodeCommentAdornmentStyle index 3 read GetStyle;
    property Warning: TCodeCommentAdornmentStyle index 4 read GetStyle;
    property XmlDocTag: TCodeCommentAdornmentStyle index 5 read GetStyle;
    property XmlDocName: TCodeCommentAdornmentStyle index 6 read GetStyle;
    property XmlDocValue: TCodeCommentAdornmentStyle index 7 read GetStyle;
  end;
  TCodeEditorRenderContext = record
    Source: ICodeVirtualTextSource;
    Font: TFont;
    Palette: TThemePalette;
    Options: TThemedCodeEditorOptions;
    Theme: TThemedCodeEditorTheme;
    Metrics: TCodeEditorRenderMetrics;
    Map: TCodeEditorVisualLineMap;
    Highlights: TCodeHighlightCache;
    Bookmarks: TCodeBookmarkManager;
    Breakpoints: TCodeBreakpointManager;
    ExecutionLine: Integer;
    HasExecutionLine: Boolean;
    Folds: TCodeFoldManager;
    Pairs: TArray<TCodeBracketPair>;
    PairColors: TDictionary<Int64, Integer>;
    SearchMatches: TArray<TCodeSearchMatch>;
    Diagnostics: TArray<TCodeDiagnostic>;
    CommentStyles: TCodeCommentStyles;
    Caret: TCodeDocumentPosition;
    Selection: TCodeDocumentRange;
    SelectionMode: TCodeEditorSelectionMode;
    CaretStyle: TCodeEditorCaretStyle;
    NavigationRange: TCodeDocumentRange;
    HasNavigationHover, Focused, Enabled, CaretVisible: Boolean;
    FirstVisibleLine, HorizontalOffset: Integer;
  end;
  ICodeEditorRenderer = interface
    ['{FA3283B0-A5B4-4991-B586-047E0C947B81}']
    function Measure(const Backend: ICodeEditorRenderBackend; const Font: TFont; const Bounds: TRect;
      const PPI, LineCount: Integer; Options: TThemedCodeEditorOptions): TCodeEditorRenderMetrics;
    procedure Render(const Backend: ICodeEditorRenderBackend; const Context: TCodeEditorRenderContext);
  end;
  TThemedCodeEditorRenderer = class(TInterfacedObject, ICodeEditorRenderer)
  public
    function Measure(const Backend: ICodeEditorRenderBackend; const Font: TFont; const Bounds: TRect;
      const PPI, LineCount: Integer; Options: TThemedCodeEditorOptions): TCodeEditorRenderMetrics;
    procedure Render(const Backend: ICodeEditorRenderBackend; const Context: TCodeEditorRenderContext);
  end;

implementation

uses System.Math, System.Character, NimbusForms.Rendering.Types, NimbusForms.Rendering.UnicodeText;

constructor TCodeEditorGDIPlusBackend.Create(const Canvas: INimbusRenderCanvas);
begin inherited Create; FCanvas := Canvas; if FCanvas = nil then FCanvas := TNimbusRenderCanvas.Create; end;
procedure TCodeEditorGDIPlusBackend.BeginFrame(const Canvas: TCanvas; const Bounds: TRect; const PPI: Integer);
begin FCanvas.BeginRender(Canvas); end;
procedure TCodeEditorGDIPlusBackend.EndFrame;
begin FCanvas.EndRender; end;
procedure TCodeEditorGDIPlusBackend.FillRect(const Bounds: TRect; const Color: TThemeColor);
begin FCanvas.FillRectangle(Color, Bounds); end;
procedure TCodeEditorGDIPlusBackend.StrokeRect(const Bounds: TRect; const Color: TThemeColor; const Width: Single);
begin FCanvas.DrawRectangle(Color, Bounds, Width); end;
procedure TCodeEditorGDIPlusBackend.Line(const A, B: TPoint; const Color: TThemeColor; const Width: Single);
begin FCanvas.DrawLine(Color, A.X, A.Y, B.X, B.Y, Width); end;
procedure TCodeEditorGDIPlusBackend.Text(const Value: string; const Font: TFont; const Bounds: TRect; const Color: TThemeColor);
begin NimbusDrawMonospacedText(FCanvas, Value, Font, Bounds, Color); end;
function TCodeEditorGDIPlusBackend.Measure(const Value: string; const Font: TFont): TSize;
begin Result := FCanvas.MeasureText(Value, Font, 0, [ntfSingleLine, ntfTypographic, ntfNoPrefix]); end;
procedure TCodeEditorGDIPlusBackend.PushClip(const Bounds: TRect);
begin FCanvas.PushClip(Bounds); end;
procedure TCodeEditorGDIPlusBackend.PopClip;
begin FCanvas.PopClip; end;

constructor TCodeCommentAdornmentStyle.Create;
begin inherited; FontStyle := [fsBold]; FontScale := 1; RightSpacingColumns := 1; end;
procedure TCodeCommentAdornmentStyle.Assign(Source: TPersistent);
var S: TCodeCommentAdornmentStyle;
begin
  if not (Source is TCodeCommentAdornmentStyle) then begin inherited; Exit; end;
  S := TCodeCommentAdornmentStyle(Source); ForeColor := S.ForeColor; BackColor := S.BackColor; BorderColor := S.BorderColor;
  FontStyle := S.FontStyle; FontScale := S.FontScale; RightSpacingColumns := S.RightSpacingColumns;
end;
constructor TCodeCommentAdornmentRule.Create(Collection: TCollection);
begin inherited; FFontStyle := [fsBold]; FFontScale := 1; FWholeWord := True; end;
destructor TCodeCommentAdornmentRule.Destroy;
begin if FOwnsStyle then FStyle.Free; inherited; end;
procedure TCodeCommentAdornmentRule.SetStyle(const Value: TCodeCommentAdornmentStyle);
begin
  if Value = FStyle then Exit;
  if FOwnsStyle then FreeAndNil(FStyle);
  FStyle := nil; FOwnsStyle := Value <> nil;
  if Value <> nil then begin FStyle := TCodeCommentAdornmentStyle.Create; FStyle.Assign(Value); end;
end;
procedure TCodeCommentAdornmentRule.Assign(Source: TPersistent);
var R: TCodeCommentAdornmentRule;
begin
  if not (Source is TCodeCommentAdornmentRule) then begin inherited; Exit; end;
  R := TCodeCommentAdornmentRule(Source); FKeyword := R.FKeyword; FForeColor := R.FForeColor;
  FBackColor := R.FBackColor; FBorderColor := R.FBorderColor; FFontStyle := R.FFontStyle;
  FFontScale := R.FFontScale; FMatchCase := R.FMatchCase; FWholeWord := R.FWholeWord; SetStyle(R.Style);
end;
constructor TCodeCommentStyles.Create(Owner: TPersistent);
const Fores: array[0..7] of Cardinal = ($FFFFD700, $FF569CD6, $FFF48771, $FFC586C0, $FFFFA040, $FF569CD6, $FF9CDCFE, $FFCE9178);
  Backs: array[0..7] of Cardinal = ($2AFFD700, $22569CD6, $2AF48771, $26C586C0, $2CFFA040, 0, 0, 0);
  Borders: array[0..7] of Cardinal = ($78FFD700, $6E569CD6, $78F48771, $6EC586C0, $82FFA040, 0, 0, 0);
var I: Integer;
begin
  inherited Create(Owner, TCodeCommentAdornmentRule);
  for I := 0 to 7 do
  begin
    FStyles[I] := TCodeCommentAdornmentStyle.Create; FStyles[I].ForeColor := Fores[I];
    FStyles[I].BackColor := Backs[I]; FStyles[I].BorderColor := Borders[I];
    if I >= 5 then begin FStyles[I].FontScale := 0.95; FStyles[I].RightSpacingColumns := 0; if I <> 6 then FStyles[I].FontStyle := []; end;
  end;
  Warning.RightSpacingColumns := 2; ResetDefaultRules;
end;
destructor TCodeCommentStyles.Destroy;
var I: Integer;
begin Clear; for I := 0 to 7 do FStyles[I].Free; inherited; end;
function TCodeCommentStyles.GetStyle(const Index: Integer): TCodeCommentAdornmentStyle;
begin Result := FStyles[Index]; end;
function TCodeCommentStyles.GetRule(const Index: Integer): TCodeCommentAdornmentRule;
begin Result := TCodeCommentAdornmentRule(Items[Index]); end;
function TCodeCommentStyles.AddKeyword(const Keyword: string; const ForeColor, BackColor, BorderColor: TThemeColor): TCodeCommentAdornmentRule;
begin Result := TCodeCommentAdornmentRule(Add); Result.Keyword := Keyword; Result.ForeColor := ForeColor; Result.BackColor := BackColor; Result.BorderColor := BorderColor; end;
function TCodeCommentStyles.AddKeyword(const Keyword: string; Style: TCodeCommentAdornmentStyle): TCodeCommentAdornmentRule;
begin Result := TCodeCommentAdornmentRule(Add); Result.Keyword := Keyword; Result.Style := Style; end;
procedure TCodeCommentStyles.ResetDefaultRules;
begin
  Clear;
  AddKeyword('TODO', 0, 0, 0).FStyle := Todo;
  AddKeyword('FIXME', 0, 0, 0).FStyle := Fixme;
  AddKeyword('WARNING', 0, 0, 0).FStyle := Warning;
  AddKeyword('WARN', 0, 0, 0).FStyle := Warning;
  AddKeyword('NOTE', 0, 0, 0).FStyle := Note;
  AddKeyword('HACK', 0, 0, 0).FStyle := Hack;
end;
function TCodeCommentStyles.Find(const Word: string): TCodeCommentAdornmentRule;
var I: Integer; R: TCodeCommentAdornmentRule;
begin Result := nil; for I := 0 to Count - 1 do begin R := Rules[I]; if (R.MatchCase and (R.Keyword = Word)) or (not R.MatchCase and SameText(R.Keyword, Word)) then Exit(R); end; end;

function TThemedCodeEditorRenderer.Measure(const Backend: ICodeEditorRenderBackend; const Font: TFont; const Bounds: TRect;
  const PPI, LineCount: Integer; Options: TThemedCodeEditorOptions): TCodeEditorRenderMetrics;
var Size: TSize; X, Width: Integer;
begin
  Result := Default(TCodeEditorRenderMetrics); Result.Bounds := Bounds;
  Size := Backend.Measure(StringOfChar('0', 64), Font); Result.CharWidth := Max(1, Size.cx / 64.0);
  Result.LineHeight := Max(1, Size.cy + NimbusScaleValue(4, PPI)); Result.TextInset := NimbusScaleValue(4, PPI);
  X := Bounds.Left;
  if Options.ShowBreakpoints then Width := NimbusScaleValue(16, PPI) else Width := 0;
  Result.BreakpointBounds := Rect(X, Bounds.Top, X + Width, Bounds.Bottom); Inc(X, Width);
  if Options.ShowBookmarks then Width := NimbusScaleValue(16, PPI) else Width := 0;
  Result.BookmarkBounds := Rect(X, Bounds.Top, X + Width, Bounds.Bottom); Inc(X, Width);
  if Options.ShowLineNumbers then Width := Ceil((Length(IntToStr(Max(1, LineCount))) + 2) * Result.CharWidth) else Width := 0;
  Result.LineNumberBounds := Rect(X, Bounds.Top, X + Width, Bounds.Bottom); Inc(X, Width);
  if Options.ShowFoldingMargin then Width := NimbusScaleValue(16, PPI) else Width := 0;
  Result.FoldingBounds := Rect(X, Bounds.Top, X + Width, Bounds.Bottom); Inc(X, Width);
  Inc(X, NimbusScaleValue(5, PPI)); Result.TextBounds := Rect(X, Bounds.Top, Bounds.Right, Bounds.Bottom);
  Result.VisibleRows := Max(1, Bounds.Height div Result.LineHeight);
end;

procedure TThemedCodeEditorRenderer.Render(const Backend: ICodeEditorRenderBackend; const Context: TCodeEditorRenderContext);
var
  C: TCodeEditorRenderContext; Visual, Last, Y, X, I, J, LeftDisplay, RightDisplay, Display, First, EndChar,
  SpanStart, SpanEnd, StartDisplay, EndDisplay, SelectionStart, SelectionEnd, Indent, Col, PairColor, TrailingStart,
  RuleIndex, MatchPosition: Integer;
  Row: TCodeVisualLine; Text, Slice, Word, CommentText, Needle: string; R, Body: TRect;
  Back, Fore, Color, GutterBack: TThemeColor; Highlight: TCodeHighlightResult;
  Span: TCodeHighlightSpan; Hit: TCodeSearchMatch; Pair: TCodeBracketPair; Diagnostic: TCodeDiagnostic;
  SymbolPair: TCodeBracketPair; Fold: TCodeFoldRegion; Rule: TCodeCommentAdornmentRule; TempFont: TFont;
  DocStyle: TCodeCommentAdornmentStyle;
  Breakpoint: TCodeBreakpoint;
  RowSeverity: TCodeEditorDiagnosticSeverity; HasBreakpoint: Boolean;
  P: TPoint; BracketPosition: TCodeDocumentPosition;
  MatchBracket, HasMatchedPair: Boolean; MatchedPair: TCodeBracketPair;
  procedure BreakpointGlyph(const Bounds: TRect; const Filled, Diamond: Boolean; const GlyphColor: TThemeColor);
  var K, Radius, CenterX, CenterY: Integer; A, B: TPoint;
  begin
    Radius := Max(2, Min(Bounds.Width, Bounds.Height) div 2 - 2);
    CenterX := (Bounds.Left + Bounds.Right) div 2; CenterY := (Bounds.Top + Bounds.Bottom) div 2;
    if Filled then
      for K := -Radius to Radius do
      begin
        if Diamond then
          Backend.Line(Point(CenterX - Radius + Abs(K), CenterY + K), Point(CenterX + Radius - Abs(K), CenterY + K), GlyphColor, 1)
        else Backend.Line(Point(CenterX - Round(Sqrt(Max(0, Radius * Radius - K * K))), CenterY + K),
          Point(CenterX + Round(Sqrt(Max(0, Radius * Radius - K * K))), CenterY + K), GlyphColor, 1);
      end
    else if Diamond then
      for K := 0 to 3 do
      begin
        A := Point(CenterX + Round(Cos(K * Pi / 2) * Radius), CenterY + Round(Sin(K * Pi / 2) * Radius));
        B := Point(CenterX + Round(Cos((K + 1) * Pi / 2) * Radius), CenterY + Round(Sin((K + 1) * Pi / 2) * Radius));
        Backend.Line(A, B, GlyphColor, 1);
      end
    else
      for K := 0 to 7 do
      begin
        A := Point(CenterX + Round(Cos(K * Pi / 4) * Radius), CenterY + Round(Sin(K * Pi / 4) * Radius));
        B := Point(CenterX + Round(Cos((K + 1) * Pi / 4) * Radius), CenterY + Round(Sin((K + 1) * Pi / 4) * Radius));
        Backend.Line(A, B, GlyphColor, 1);
      end;
  end;
  function RowX(const Column: Integer): Integer;
  begin Result := X + Round(C.Map.TextX(Text, Row.DocumentLine, Column, C.Options.TabSize, C.Metrics.CharWidth) - C.Map.TextX(Text, Row.DocumentLine, Row.StartColumn, C.Options.TabSize, C.Metrics.CharWidth)); end;
  procedure RangeRect(const Range: TCodeDocumentRange; const FillColor, BorderColor: TThemeColor);
  var A, B: Integer; Box: TRect;
  begin
    if (Row.DocumentLine < Range.Start.LineIndex) or (Row.DocumentLine > Range.Finish.LineIndex) then Exit;
    A := Row.StartColumn; B := Row.EndColumn;
    if Row.DocumentLine = Range.Start.LineIndex then A := Max(A, Range.Start.ColumnIndex);
    if Row.DocumentLine = Range.Finish.LineIndex then B := Min(B, Range.Finish.ColumnIndex);
    if B < A then Exit;
    Box := Rect(RowX(A), Y + 1, Max(RowX(A) + 2, RowX(B)), Y + C.Metrics.LineHeight - 1);
    if FillColor <> 0 then Backend.FillRect(Box, FillColor);
    if BorderColor <> 0 then Backend.StrokeRect(Box, BorderColor, 1);
  end;
  procedure StyledText(const FirstChar, Count: Integer; Style: TCodeCommentAdornmentStyle);
  var Box: TRect;
  begin
    Box := Rect(RowX(FirstChar - 1), Y + 1, RowX(FirstChar + Count - 1), Y + C.Metrics.LineHeight - 1);
    if Style.BackColor <> 0 then Backend.FillRect(Box, Style.BackColor);
    if Style.BorderColor <> 0 then Backend.StrokeRect(Box, Style.BorderColor, 1);
    TempFont.Assign(C.Font); TempFont.Style := Style.FontStyle; TempFont.Height := Round(C.Font.Height * Max(0.5, Style.FontScale));
    Backend.Text(Copy(Text, FirstChar, Count), TempFont, Box, Style.ForeColor);
  end;
  function ScopeColor(const PairValue: TCodeBracketPair): TThemeColor;
  var Header: string; LineIndex: Integer;
  begin
    LineIndex := PairValue.OpenPosition.LineIndex; Header := LowerCase(Trim(C.Source.GetLineText(LineIndex)));
    if Header = '{' then while LineIndex > 0 do begin Dec(LineIndex); Header := LowerCase(Trim(C.Source.GetLineText(LineIndex))); if Header <> '' then Break; end;
    Result := C.Theme.Resolve(C.Theme.OtherScopeGuideColor, NimbusBlendColor(Back, Fore, 20));
    if Header.Contains('namespace ') then Result := C.Theme.Resolve(C.Theme.NamespaceGuideColor, $FF4B6EAF)
    else if Header.Contains('class ') or Header.Contains('struct ') or Header.Contains('interface ') or Header.Contains('enum ') then Result := C.Theme.Resolve(C.Theme.TypeGuideColor, $FF4EC9B0)
    else if Header.StartsWith('if') or Header.StartsWith('else') then Result := C.Theme.Resolve(C.Theme.ConditionalGuideColor, $FFC586C0)
    else if Header.StartsWith('for') or Header.StartsWith('while') or Header.StartsWith('do') then Result := C.Theme.Resolve(C.Theme.LoopGuideColor, $FFB5CEA8)
    else if Header.StartsWith('switch') then Result := C.Theme.Resolve(C.Theme.SwitchGuideColor, $FF569CD6)
    else if Header.StartsWith('try') or Header.StartsWith('catch') or Header.StartsWith('finally') then Result := C.Theme.Resolve(C.Theme.TryCatchGuideColor, $FFD69D85)
    else if Header.StartsWith('using') then Result := C.Theme.Resolve(C.Theme.UsingGuideColor, $FF9B9B9B)
    else if Header.Contains('(') then Result := C.Theme.Resolve(C.Theme.MemberGuideColor, $FFDCDCAA);
  end;
begin
  C := Context; Back := C.Theme.Resolve(C.Theme.BackColor, NimbusInputBackColor(C.Palette));
  Fore := C.Theme.Resolve(C.Theme.ForeColor, NimbusControlForeColor(C.Palette));
  if not C.Enabled then Fore := NimbusDisabledForeColor(C.Palette);
  GutterBack := C.Theme.Resolve(C.Theme.GutterBackColor, NimbusControlBackColor(C.Palette));
  Backend.FillRect(C.Metrics.Bounds, Back);
  if (C.Source = nil) or (C.Map.Count = 0) then Exit;
  Backend.FillRect(Rect(C.Metrics.Bounds.Left, C.Metrics.Bounds.Top, C.Metrics.TextBounds.Left, C.Metrics.Bounds.Bottom), GutterBack);
  Last := Min(C.Map.Count - 1, C.FirstVisibleLine + C.Metrics.VisibleRows);
  HasMatchedPair := False; MatchedPair := Default(TCodeBracketPair);
  if C.Options.HighlightMatchingBrackets then for Pair in C.Pairs do
  begin
    MatchBracket := (Pair.OpenPosition.Compare(C.Caret) = 0) or (Pair.ClosePosition.Compare(C.Caret) = 0) or
      ((Pair.OpenPosition.LineIndex = C.Caret.LineIndex) and (Pair.OpenPosition.ColumnIndex + 1 = C.Caret.ColumnIndex)) or
      ((Pair.ClosePosition.LineIndex = C.Caret.LineIndex) and (Pair.ClosePosition.ColumnIndex + 1 = C.Caret.ColumnIndex));
    if MatchBracket then begin MatchedPair := Pair; HasMatchedPair := True; Break; end;
  end;
  TempFont := TFont.Create;
  try
    for Visual := C.FirstVisibleLine to Last do
    begin
      Row := C.Map.GetRow(Visual); Text := C.Source.GetLineText(Row.DocumentLine);
      TrailingStart := Length(Text); while (TrailingStart > 0) and CharInSet(Text[TrailingStart], [' ', #9]) do Dec(TrailingStart);
      Y := C.Metrics.Bounds.Top + (Visual - C.FirstVisibleLine) * C.Metrics.LineHeight;
      X := C.Metrics.TextBounds.Left + C.Metrics.TextInset - C.HorizontalOffset;
      Body := Rect(C.Metrics.TextBounds.Left, Y, C.Metrics.TextBounds.Right, Y + C.Metrics.LineHeight);
      if C.Options.HighlightCurrentLine and (C.Caret.LineIndex = Row.DocumentLine) then
        Backend.FillRect(Body, C.Theme.Resolve(C.Theme.CurrentLineBackColor, NimbusBlendColor(Back, NimbusAccentColor(C.Palette), 12)));
      if C.HasExecutionLine and (C.ExecutionLine = Row.DocumentLine) then
        Backend.FillRect(Body, NimbusBlendColor(Back, C.Theme.Resolve(C.Theme.ExecutionLineColor, $FFFFD700), 18));
      if C.Options.ShowBreakpoints and (Row.StartColumn = 0) then
      begin
        R := C.Metrics.BreakpointBounds; R.Top := Y; R.Bottom := Y + C.Metrics.LineHeight;
        HasBreakpoint := (C.Breakpoints <> nil) and C.Breakpoints.TryGet(Row.DocumentLine, Breakpoint);
        if HasBreakpoint then
        begin
          Color := C.Theme.Resolve(C.Theme.BreakpointColor, $FFE35B66);
          if Breakpoint.LogMessage <> '' then Color := C.Theme.Resolve(C.Theme.InfoColor, $FF3F9AD8);
          if not Breakpoint.Enabled then Color := C.Theme.Resolve(C.Theme.DisabledBreakpointColor, $FF9B9B9B);
          BreakpointGlyph(R, Breakpoint.Enabled, Breakpoint.LogMessage <> '', Color);
          if (Breakpoint.Condition <> '') or (Breakpoint.HitCount > 0) then
          begin
            Col := (R.Left + R.Right) div 2;
            Color := Fore; if Breakpoint.Enabled then Color := $FFFFFFFF;
            Backend.Line(Point(Col - 2, (R.Top + R.Bottom) div 2), Point(Col + 2, (R.Top + R.Bottom) div 2), Color, 1);
            Backend.Line(Point(Col, (R.Top + R.Bottom) div 2 - 2), Point(Col, (R.Top + R.Bottom) div 2 + 2), Color, 1);
          end;
        end;
        if C.HasExecutionLine and (C.ExecutionLine = Row.DocumentLine) then
        begin
          Color := C.Theme.Resolve(C.Theme.ExecutionLineColor, $FFFFD700); Col := (R.Top + R.Bottom) div 2;
          Backend.Line(Point(R.Left + 2, Col), Point(R.Right - 3, Col), Color, 2);
          Backend.Line(Point(R.Right - 7, Col - 4), Point(R.Right - 3, Col), Color, 2);
          Backend.Line(Point(R.Right - 7, Col + 4), Point(R.Right - 3, Col), Color, 2);
        end
        else if not HasBreakpoint then
        begin
          RowSeverity := cdsHidden;
          for Diagnostic in C.Diagnostics do
            if (Diagnostic.Range.Start.LineIndex = Row.DocumentLine) and (Diagnostic.Severity > RowSeverity) then RowSeverity := Diagnostic.Severity;
          if RowSeverity <> cdsHidden then
          begin
            Color := C.Theme.Resolve(C.Theme.InfoColor, $FF3F9AD8); Slice := 'i';
            if RowSeverity = cdsError then begin Color := C.Theme.Resolve(C.Theme.ErrorColor, NimbusDangerColor); Slice := '!'; end
            else if RowSeverity = cdsWarning then begin Color := C.Theme.Resolve(C.Theme.WarningColor, NimbusWarningColor); Slice := '!'; end;
            Backend.Text(Slice, C.Font, R, Color);
          end;
        end;
      end;
      if C.Options.ShowLineNumbers and (Row.StartColumn = 0) then
      begin
        R := C.Metrics.LineNumberBounds; R.Top := Y; R.Bottom := Y + C.Metrics.LineHeight;
        Slice := IntToStr(Row.DocumentLine + 1); R.Left := R.Right - Ceil((Length(Slice) + 1) * C.Metrics.CharWidth);
        Backend.Text(Slice, C.Font, R, C.Theme.Resolve(C.Theme.GutterForeColor, NimbusMutedForeColor(C.Palette)));
      end;
      if C.Options.ShowBookmarks and (Row.StartColumn = 0) and (C.Bookmarks.FindAtLine(Row.DocumentLine) >= 0) then
      begin R := Rect(C.Metrics.BookmarkBounds.Left + 4, Y + 4, C.Metrics.BookmarkBounds.Right - 4, Y + C.Metrics.LineHeight - 4); Backend.FillRect(R, C.Theme.Resolve(C.Theme.BookmarkColor, NimbusAccentColor(C.Palette))); end;
      if C.Options.ShowFoldingMargin and (Row.FoldIndex >= 0) then
      begin
        Fold := C.Folds.Regions[Row.FoldIndex]; R := Rect(C.Metrics.FoldingBounds.Left + 3, Y + (C.Metrics.LineHeight - 9) div 2, C.Metrics.FoldingBounds.Left + 12, Y + (C.Metrics.LineHeight - 9) div 2 + 9);
        Color := C.Theme.Resolve(C.Theme.FoldGlyphColor, NimbusMutedForeColor(C.Palette)); Backend.StrokeRect(R, Color, 1);
        Backend.Line(Point(R.Left + 2, R.Top + 4), Point(R.Right - 2, R.Top + 4), Color, 1);
        if Fold.IsCollapsed then Backend.Line(Point(R.Left + 4, R.Top + 2), Point(R.Left + 4, R.Bottom - 2), Color, 1);
      end;
      Backend.PushClip(Body);
      try
        if not C.Selection.IsEmpty and (Row.DocumentLine >= C.Selection.Start.LineIndex) and (Row.DocumentLine <= C.Selection.Finish.LineIndex) then
        begin
          if C.SelectionMode = csmColumn then
          begin
            SelectionStart := Min(C.Selection.Start.ColumnIndex, C.Selection.Finish.ColumnIndex);
            SelectionEnd := Max(C.Selection.Start.ColumnIndex, C.Selection.Finish.ColumnIndex);
            RangeRect(TCodeDocumentRange.Create(TCodeDocumentPosition.Create(Row.DocumentLine, SelectionStart), TCodeDocumentPosition.Create(Row.DocumentLine, SelectionEnd)), C.Theme.Resolve(C.Theme.SelectionBackColor, NimbusMenuSelectedBackColor(C.Palette)), 0);
          end
          else RangeRect(C.Selection, C.Theme.Resolve(C.Theme.SelectionBackColor, NimbusMenuSelectedBackColor(C.Palette)), 0);
        end;
        if C.Options.ShowSearchMatches then for Hit in C.SearchMatches do
          if Hit.Range.Start.LineIndex = Row.DocumentLine then RangeRect(Hit.Range, C.Theme.Resolve(C.Theme.SearchMatchBackColor, NimbusBlendColor(Back, NimbusWarningColor, 45)), C.Theme.Resolve(C.Theme.SearchMatchBorderColor, NimbusWarningColor));
        if HasMatchedPair then
          begin
              BracketPosition := MatchedPair.OpenPosition; RangeRect(TCodeDocumentRange.Create(BracketPosition, TCodeDocumentPosition.Create(BracketPosition.LineIndex, BracketPosition.ColumnIndex + 1)), C.Theme.Resolve(C.Theme.BracketMatchBackColor, NimbusBlendColor(Back, NimbusAccentColor(C.Palette), 30)), NimbusAccentColor(C.Palette));
              BracketPosition := MatchedPair.ClosePosition; RangeRect(TCodeDocumentRange.Create(BracketPosition, TCodeDocumentPosition.Create(BracketPosition.LineIndex, BracketPosition.ColumnIndex + 1)), C.Theme.Resolve(C.Theme.BracketMatchBackColor, NimbusBlendColor(Back, NimbusAccentColor(C.Palette), 30)), NimbusAccentColor(C.Palette));
          end;
        if C.HasNavigationHover then RangeRect(C.NavigationRange, C.Theme.Resolve(C.Theme.NavigationLinkHoverBackColor, NimbusBlendColor(Back, NimbusAccentColor(C.Palette), 20)), 0);
        if C.Options.ShowIndentGuides then
        begin
          Indent := CodeLeadingColumns(Text, C.Options.TabSize);
          for I := 1 to Indent div C.Options.IndentSize do
          begin Col := X + Round((I * C.Options.IndentSize - Row.StartDisplayColumn) * C.Metrics.CharWidth); Backend.Line(Point(Col, Y), Point(Col, Y + C.Metrics.LineHeight), C.Theme.Resolve(C.Theme.IndentGuideColor, NimbusBlendColor(Back, Fore, 15)), 1); end;
        end;
        if C.Options.ShowScopeGuides then for SymbolPair in C.Pairs do
          if (SymbolPair.OpenChar = '{') and (Row.DocumentLine > SymbolPair.OpenPosition.LineIndex) and (Row.DocumentLine < SymbolPair.ClosePosition.LineIndex) then
          begin
            Col := CodeLeadingColumns(C.Source.GetLineText(SymbolPair.OpenPosition.LineIndex), C.Options.TabSize);
            Col := X + Round((Col - Row.StartDisplayColumn + 1) * C.Metrics.CharWidth);
            Backend.Line(Point(Col, Y), Point(Col, Y + C.Metrics.LineHeight), ScopeColor(SymbolPair), 1);
          end;
        LeftDisplay := Row.StartDisplayColumn + Max(0, Floor(C.HorizontalOffset / C.Metrics.CharWidth));
        RightDisplay := Row.StartDisplayColumn + Ceil((C.HorizontalOffset + Body.Width) / C.Metrics.CharWidth);
        Highlight := C.Highlights.GetLine(Row.DocumentLine); Display := 0;
        if Length(Highlight.Spans) = 0 then
        begin Span.Start := 0; Span.Length := Length(Text); Span.Kind := chtText; Highlight.Spans := TArray<TCodeHighlightSpan>.Create(Span); end;
        for Span in Highlight.Spans do
        begin
          if Span.Start >= Row.EndColumn then Break;
          if RowX(Span.Start) >= Body.Right then Break;
          SpanStart := Span.Start + 1; SpanEnd := Min(Length(Text), Span.Start + Span.Length); First := 0; StartDisplay := Display;
          J := SpanStart;
          while (J <= SpanEnd) and (RowX(J - 1) < Body.Right) do
          begin
            EndDisplay := Display + 1; if Text[J] = #9 then EndDisplay := Display + C.Options.TabSize - Display mod C.Options.TabSize;
            if (First = 0) and (RowX(J) > Body.Left) and (J > Row.StartColumn) then begin First := J; StartDisplay := Display; end;
            Display := EndDisplay; Inc(J); if J > Row.EndColumn then Break;
          end;
          if First = 0 then Continue;
          if (First > SpanStart) and (Ord(Text[First]) >= $DC00) and (Ord(Text[First]) <= $DFFF) and
            (Ord(Text[First - 1]) >= $D800) and (Ord(Text[First - 1]) <= $DBFF) then begin Dec(First); Dec(StartDisplay); end;
          if (J <= SpanEnd) and (Ord(Text[J - 1]) >= $D800) and (Ord(Text[J - 1]) <= $DBFF) and
            (Ord(Text[J]) >= $DC00) and (Ord(Text[J]) <= $DFFF) then begin Inc(J); Inc(Display); end;
          EndChar := J; Slice := ''; EndDisplay := StartDisplay;
          for I := First to EndChar - 1 do
            if Text[I] = #9 then
            begin Slice := Slice + StringOfChar(' ', C.Options.TabSize - EndDisplay mod C.Options.TabSize); Inc(EndDisplay, C.Options.TabSize - EndDisplay mod C.Options.TabSize); end
            else begin Slice := Slice + Text[I]; Inc(EndDisplay); end;
          Color := Fore; if C.Enabled then Color := C.Theme.TokenColor(Span.Kind, C.Palette);
          if C.Options.ShowBracketPairColorization and (Span.Kind in [chtParenthesis, chtBrace, chtBracket]) and
            (C.PairColors <> nil) and C.PairColors.TryGetValue((Int64(Row.DocumentLine) shl 32) or Cardinal(Span.Start), PairColor) then
            begin
              case PairColor of 0: Color := C.Theme.Resolve(C.Theme.BracketPairColor1, $FFFFD700); 1: Color := C.Theme.Resolve(C.Theme.BracketPairColor2, $FFDA70D6); 2: Color := C.Theme.Resolve(C.Theme.BracketPairColor3, $FF569CD6); 3: Color := C.Theme.Resolve(C.Theme.BracketPairColor4, $FFB5CEA8); end;
            end;
          R := Rect(RowX(First - 1), Y, RowX(EndChar - 1) + 2, Y + C.Metrics.LineHeight);
          DocStyle := nil;
          if C.Options.ShowCommentAdornments then
            case Span.Kind of
              chtXmlDocTag: if C.Theme.XmlDocTagColor = 0 then DocStyle := C.CommentStyles.XmlDocTag;
              chtXmlDocAttribute: if C.Theme.XmlDocAttributeColor = 0 then DocStyle := C.CommentStyles.XmlDocName;
              chtXmlDocValue: if C.Theme.XmlDocValueColor = 0 then DocStyle := C.CommentStyles.XmlDocValue;
            end;
          if DocStyle <> nil then
          begin
            TempFont.Assign(C.Font); TempFont.Style := DocStyle.FontStyle;
            TempFont.Height := Round(C.Font.Height * Max(0.5, DocStyle.FontScale));
            if C.Enabled and (DocStyle.ForeColor <> 0) then Color := DocStyle.ForeColor;
            if DocStyle.BackColor <> 0 then Backend.FillRect(R, DocStyle.BackColor);
            Backend.Text(Slice, TempFont, R, Color);
          end
          else Backend.Text(Slice, C.Font, R, Color);
          if C.Options.ShowCommentAdornments and (Span.Kind in [chtComment, chtDocumentationComment, chtXmlDocComment]) then
          begin
            CommentText := Copy(Text, First, EndChar - First);
            for RuleIndex := 0 to C.CommentStyles.Count - 1 do
            begin
              Rule := C.CommentStyles[RuleIndex]; if Rule.Keyword = '' then Continue;
              Needle := Rule.Keyword; Word := CommentText;
              if not Rule.MatchCase then begin Needle := UpperCase(Needle); Word := UpperCase(Word); end;
              MatchPosition := Pos(Needle, Word);
              while MatchPosition > 0 do
              begin
                I := First + MatchPosition - 1; J := I + Length(Needle);
                if not Rule.WholeWord or (((I <= 1) or not CodeIsWord(Text[I - 1])) and ((J > Length(Text)) or not CodeIsWord(Text[J]))) then
                begin
                  if Rule.Style <> nil then StyledText(I, Length(Needle), Rule.Style)
                  else
                  begin
                    R := Rect(RowX(I - 1), Y + 1, RowX(J - 1), Y + C.Metrics.LineHeight - 1);
                    if Rule.BackColor <> 0 then Backend.FillRect(R, Rule.BackColor);
                    if Rule.BorderColor <> 0 then Backend.StrokeRect(R, Rule.BorderColor, 1);
                    TempFont.Assign(C.Font); TempFont.Style := Rule.FontStyle; TempFont.Height := Round(C.Font.Height * Max(0.5, Rule.FontScale));
                    Backend.Text(Copy(Text, I, Length(Needle)), TempFont, R, Rule.ForeColor);
                  end;
                end;
                MatchPosition := Pos(Needle, Word, MatchPosition + Length(Needle));
              end;
            end;
          end;
          if C.Options.ShowSpaces or C.Options.ShowTabs or C.Options.ShowTrailingSpaces then
            for I := First to EndChar - 1 do
            begin
              P := Point(RowX(I - 1), Y + C.Metrics.LineHeight div 2);
              if (Text[I] = ' ') and (C.Options.ShowSpaces or (C.Options.ShowTrailingSpaces and (I > TrailingStart))) then
                Backend.FillRect(Rect(P.X + Round(C.Metrics.CharWidth / 2), P.Y, P.X + Round(C.Metrics.CharWidth / 2) + 1, P.Y + 1), NimbusMutedForeColor(C.Palette));
              if (Text[I] = #9) and (C.Options.ShowTabs or (C.Options.ShowTrailingSpaces and (I > TrailingStart))) then
              begin
                Col := Max(P.X + 2, RowX(I) - 2); Color := NimbusMutedForeColor(C.Palette);
                Backend.Line(Point(P.X + 1, P.Y), Point(Col, P.Y), Color, 1);
                Backend.Line(Point(Col - 2, P.Y - 2), Point(Col, P.Y), Color, 1);
                Backend.Line(Point(Col - 2, P.Y + 2), Point(Col, P.Y), Color, 1);
              end;
            end;
        end;
        if C.Options.ShowEndOfLine and (Row.EndColumn = Length(Text)) then
        begin
          Slice := '';
          case C.Source.GetLineEndingKind(Row.DocumentLine) of cnkWindows: Slice := 'CRLF'; cnkUnix: Slice := 'LF'; cnkMacintosh: Slice := 'CR'; cnkMixed: Slice := 'EOL'; end;
          if Slice <> '' then Backend.Text(Slice, C.Font, Rect(RowX(Length(Text)) + Ceil(C.Metrics.CharWidth), Y,
            RowX(Length(Text)) + Ceil(C.Metrics.CharWidth * (Length(Slice) + 2)), Y + C.Metrics.LineHeight), NimbusMutedForeColor(C.Palette));
        end;
        if C.HasNavigationHover and (C.NavigationRange.Start.LineIndex = Row.DocumentLine) then
          Backend.Line(Point(RowX(C.NavigationRange.Start.ColumnIndex), Y + C.Metrics.LineHeight - 2),
            Point(RowX(C.NavigationRange.Finish.ColumnIndex), Y + C.Metrics.LineHeight - 2), C.Theme.Resolve(C.Theme.NavigationLinkUnderlineColor, NimbusAccentColor(C.Palette)), 1);
        if (Row.FoldIndex >= 0) and C.Folds.Regions[Row.FoldIndex].IsCollapsed then
        begin
          R := Rect(RowX(Length(Text)) + 4, Y + 2, RowX(Length(Text)) + Ceil(C.Metrics.CharWidth * 4) + 4, Y + C.Metrics.LineHeight - 2);
          Color := C.Theme.Resolve(C.Theme.FoldTextColor, NimbusMutedForeColor(C.Palette)); Backend.StrokeRect(R, Color, 1); Backend.Text('...', C.Font, R, Color);
        end;
        for Diagnostic in C.Diagnostics do if (Diagnostic.Range.Start.LineIndex = Row.DocumentLine) and (Diagnostic.Severity <> cdsHidden) then
        begin
          Color := C.Theme.Resolve(C.Theme.InfoColor, $FF3F9AD8);
          if Diagnostic.Severity = cdsError then Color := C.Theme.Resolve(C.Theme.ErrorColor, NimbusDangerColor)
          else if Diagnostic.Severity = cdsWarning then Color := C.Theme.Resolve(C.Theme.WarningColor, NimbusWarningColor);
          I := RowX(Diagnostic.Range.Start.ColumnIndex); J := Max(I + 3, RowX(Diagnostic.Range.Finish.ColumnIndex));
          while I < J do begin Backend.Line(Point(I, Y + C.Metrics.LineHeight - 3), Point(I + 2, Y + C.Metrics.LineHeight - 1), Color, 1); Backend.Line(Point(I + 2, Y + C.Metrics.LineHeight - 1), Point(I + 4, Y + C.Metrics.LineHeight - 3), Color, 1); Inc(I, 4); end;
        end;
        if C.CaretVisible and C.Focused and (C.Map.GetVisualLine(C.Caret) = Visual) then
        begin
          P := CodePositionPoint(C.Caret, C.Metrics, C.Map, C.Source, C.FirstVisibleLine, C.HorizontalOffset, C.Options.TabSize);
          R := Rect(P.X, P.Y + 1, P.X + 1, P.Y + C.Metrics.LineHeight - 1);
          if C.CaretStyle = ccsBlock then R.Right := R.Left + Ceil(C.Metrics.CharWidth);
          if C.CaretStyle = ccsUnderline then begin R.Top := R.Bottom - 2; R.Right := R.Left + Ceil(C.Metrics.CharWidth); end;
          Backend.FillRect(R, C.Theme.Resolve(C.Theme.CaretColor, NimbusControlForeColor(C.Palette)));
        end;
      finally Backend.PopClip; end;
    end;
  finally TempFont.Free; end;
end;

end.

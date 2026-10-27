{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

program NimbusCodeEditorTests;

{$APPTYPE CONSOLE}

uses Winapi.Windows, Winapi.Messages, System.Classes, System.SysUtils, System.Types, System.Math, System.IOUtils,
  System.Generics.Collections, System.Diagnostics, System.JSON, Vcl.Forms, Vcl.Graphics, Vcl.Controls,
  NimbusForms.Controls.CodeEditor, NimbusForms.Controls.CodeEditor.Types,
  NimbusForms.Controls.CodeEditor.Document, NimbusForms.Controls.CodeEditor.Syntax,
  NimbusForms.Controls.CodeEditor.Services, NimbusForms.Controls.CodeEditor.Layout,
  NimbusForms.Controls.CodeEditor.Analysis, NimbusForms.Controls.CodeEditor.Actions,
  NimbusForms.Controls.CodeEditor.Breakpoints,
  NimbusForms.Controls.CodeEditor.PieceTable, NimbusForms.Controls.CodeEditor.LineIndex,
  NimbusForms.Controls.LogViewer.Types, NimbusForms.Controls.DropdownPopup, NimbusForms.Rendering.Canvas,
  NimbusForms.Rendering.CodeEditor, NimbusForms.Rendering.CodeEditor.DLL, NimbusForms.Rendering.UnicodeText,
  NimbusForms.Controls.CodeEditor.Unicode, NimbusCodeStructureChecks;

type
  TCodeEditorInputProbe = class(TThemedCodeEditor)
  public
    procedure Press(const Key: Word);
    procedure TypeChar(const Value: Char);
    procedure ZoomKey(const Key: Word);
    procedure Wheel(const Delta: Integer; const Shift: TShiftState);
    procedure PrepareTextDrag(const At: TPoint);
    procedure StartNativeTextDrag(const At: TPoint);
    function AcceptsTextDrop(Source: TObject; const At: TPoint): Boolean;
    procedure FinishTextDrag;
    procedure RejectTextDrop(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
  end;
  TPopupLifecycleProbe = class
  public
    Popup: TThemedDropdownPopupForm;
    CloseOnShow: Boolean;
    ShowCount, HideCount: Integer;
    procedure Shown(Sender: TObject);
    procedure Hidden(Sender: TObject);
  end;

procedure TCodeEditorInputProbe.Press(const Key: Word);
var Value: Word;
begin Value := Key; KeyDown(Value, []); end;
procedure TCodeEditorInputProbe.TypeChar(const Value: Char);
var Key: Char;
begin Key := Value; KeyPress(Key); end;
procedure TCodeEditorInputProbe.ZoomKey(const Key: Word);
var Value: Word;
begin Value := Key; KeyDown(Value, [ssCtrl]); end;
procedure TCodeEditorInputProbe.Wheel(const Delta: Integer; const Shift: TShiftState);
begin DoMouseWheel(Shift, Delta, Point(0, 0)); end;
procedure TCodeEditorInputProbe.PrepareTextDrag(const At: TPoint);
begin MouseDown(mbLeft, [], At.X, At.Y); MouseCapture := False; end;
procedure TCodeEditorInputProbe.StartNativeTextDrag(const At: TPoint);
var Coordinates: LPARAM;
begin
  Coordinates := LPARAM((At.Y shl 16) or At.X);
  Perform(WM_LBUTTONDOWN, MK_LBUTTON, Coordinates);
  Coordinates := LPARAM((At.Y shl 16) or (At.X + GetSystemMetrics(SM_CXDRAG) + 1));
  Perform(WM_MOUSEMOVE, MK_LBUTTON, Coordinates);
end;
function TCodeEditorInputProbe.AcceptsTextDrop(Source: TObject; const At: TPoint): Boolean;
begin Result := False; DragOver(Source, At.X, At.Y, dsDragMove, Result); end;
procedure TCodeEditorInputProbe.FinishTextDrag;
begin DoEndDrag(nil, 0, 0); end;
procedure TCodeEditorInputProbe.RejectTextDrop(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin Accept := False; end;

procedure TPopupLifecycleProbe.Shown(Sender: TObject);
begin Inc(ShowCount); if CloseOnShow then Popup.ClosePopup; end;

procedure TPopupLifecycleProbe.Hidden(Sender: TObject);
begin Inc(HideCount); end;

procedure Check(const Value: Boolean; const MessageText: string);
begin if not Value then raise Exception.Create(MessageText); end;

{$I NimbusTestPaths.inc}

function Range(const L1, C1, L2, C2: Integer): TCodeDocumentRange;
begin Result := TCodeDocumentRange.Create(TCodeDocumentPosition.Create(L1, C1), TCodeDocumentPosition.Create(L2, C2)); end;

procedure PieceTableReferenceChecks;
var Table: TCodePieceTable; Root: TJSONValue; Steps, Lines, Starts, Lengths, Positions: TJSONArray;
  Step, Item: TJSONObject; I, J: Integer; Operation, Removed, FixturePath: string; Position: TCodeDocumentPosition;
begin
  FixturePath := TPath.Combine(TestProjectRoot, 'NimbusForms.Controls\tests\piece_table_reference.json');
  Root := TJSONObject.ParseJSONValue(TFile.ReadAllText(FixturePath, TEncoding.UTF8)); Table := TCodePieceTable.Create;
  try
    Check(Root is TJSONArray, 'C# reference fixture array'); Steps := TJSONArray(Root);
    for I := 0 to Steps.Count - 1 do
    begin
      Step := TJSONObject(Steps.Items[I]); Operation := Step.GetValue<string>('op'); Removed := '';
      if Operation = 'set' then Table.Text := Step.GetValue<string>('value')
      else if Operation = 'insert' then Table.Insert(Step.GetValue<Integer>('offset'), Step.GetValue<string>('value'))
      else if Operation = 'delete' then Removed := Table.Delete(Step.GetValue<Integer>('offset'), Step.GetValue<Integer>('count'));
      Table.ValidateStructure;
      Check((Table.Text = Step.GetValue<string>('text')) and (Removed = Step.GetValue<string>('removed')), 'C# piece-table text/deletion parity at step ' + IntToStr(I));
      Lines := TJSONArray(Step.GetValue('lines')); Starts := TJSONArray(Step.GetValue('starts')); Lengths := TJSONArray(Step.GetValue('lengths'));
      Check(Table.LineCount = Lines.Count, 'C# line count parity');
      for J := 0 to Lines.Count - 1 do
      begin
        Check(Table.GetLineText(J) = Lines.Items[J].Value, 'C# line text parity');
        Check(Table.GetLineStartOffset(J) = StrToInt(Starts.Items[J].Value), 'C# line start parity');
        Check(Table.GetLineLength(J) = StrToInt(Lengths.Items[J].Value), 'C# line length parity');
      end;
      Positions := TJSONArray(Step.GetValue('positions'));
      for J := 0 to Positions.Count - 1 do
      begin
        Item := TJSONObject(Positions.Items[J]); Position := Table.GetPositionFromOffset(Item.GetValue<Integer>('offset'));
        Check((Position.LineIndex = Item.GetValue<Integer>('line')) and (Position.ColumnIndex = Item.GetValue<Integer>('column')), 'C# offset-to-position parity');
        Check(Table.GetOffsetFromPosition(Position) = Item.GetValue<Integer>('roundTrip'), 'C# position-to-offset parity');
      end;
    end;
    Writeln('Executed C# reference fixture steps against Delphi: ' + IntToStr(Steps.Count));
  finally Table.Free; Root.Free; end;
end;

procedure PieceTableChecks;
var Table, Snapshot: TCodePieceTable; Oracle, Inserted, Removed, BeforeSnapshot: string;
  I, Offset, Count, ExpectedLines, Start, Last, Line: Integer; Position: TCodeDocumentPosition;
  Seed: Cardinal; Rejected: Boolean;
  function Next(const Limit: Integer): Integer;
  var Value: UInt64;
  begin Value := UInt64(Seed) * 1664525 + 1013904223; Seed := Cardinal(Value and $FFFFFFFF); Result := Integer(Seed mod Cardinal(Max(1, Limit))); end;
  procedure Verify;
  var J: Integer;
  begin
    Table.ValidateStructure; Check(Table.Text = Oracle, 'randomized piece text'); Check(Table.Length = Length(Oracle), 'randomized piece length');
    ExpectedLines := 1; for J := 1 to Length(Oracle) do if Oracle[J] = #10 then Inc(ExpectedLines);
    Check(Table.LineCount = ExpectedLines, 'randomized piece line count');
    for J := 0 to 7 do
    begin
      Offset := Next(Length(Oracle) + 1); Position := Table.GetPositionFromOffset(Offset);
      Check(Table.GetOffsetFromPosition(Position) = Offset, 'randomized LF position/offset inversion');
    end;
  end;
begin
  Table := TCodePieceTable.Create(#10); Snapshot := nil; Seed := 123456;
  try
    Table.Text := StringOfChar('a', 8192 * 15); Table.Delete(24576, 8192); Table.ValidateStructure;
    Check((Table.Length = 8192 * 14) and (Table.Text = StringOfChar('a', 8192 * 14)), 'deep successor deletion returns with valid metadata');
    Table.Text := 'seed'; Oracle := 'seed';
    for I := 1 to 3000 do
    begin
      Offset := Next(Length(Oracle) + 1);
      if Next(3) <> 0 then
      begin
        Inserted := 'x' + IntToStr(Next(100)); if I mod 7 = 0 then Inserted := Inserted + #13#10;
        if I mod 31 = 0 then Inserted := Inserted + Char($03A9) + Char($D83D) + Char($DE00);
        Table.Insert(Offset, Inserted); Inserted := CodeNormalizeNewLines(Inserted);
        Oracle := Copy(Oracle, 1, Offset) + Inserted + Copy(Oracle, Offset + 1, MaxInt);
      end
      else
      begin
        Count := Next(19); Removed := Table.Delete(Offset, Count); Count := Min(Count, Length(Oracle) - Offset);
        Check(Removed = Copy(Oracle, Offset + 1, Count), 'randomized deleted text'); Delete(Oracle, Offset + 1, Count);
      end;
      Verify;
    end;
    Start := 0; Line := 0;
    for I := 1 to Length(Oracle) + 1 do
      if (I > Length(Oracle)) or (Oracle[I] = #10) then
      begin
        Last := I - 1; Check(Table.GetLineStartOffset(Line) = Start, 'naive line index start');
        Check(Table.GetLineText(Line) = Copy(Oracle, Start + 1, Last - Start), 'naive line text');
        Start := I; Inc(Line);
      end;
    Table.Text := ''; Table.Insert(0, 'a'#10'b'); Snapshot := Table.CreateSnapshot;
    Table.Insert(Table.Length, #10'c'); Table.ValidateStructure; Snapshot.ValidateStructure;
    Check((Table.PieceCount = 1) and (Table.LineCount = 3), 'extended add piece refreshes line index');
    Check((Snapshot.LineCount = 2) and (Snapshot.GetLineStartOffset(1) = 2) and (Snapshot.GetLineText(1) = 'b'), 'shared line index remains immutable after piece extension');
    Check(Snapshot.GetPositionFromOffset(2).LineIndex = 1, 'snapshot indexed offset after source extension');
    Snapshot.Free; Snapshot := nil;
    Table.Text := ''; Table.Insert(0, StringOfChar('a', 65535) + #10 + StringOfChar('b', 65537));
    BeforeSnapshot := Table.Text; Snapshot := Table.CreateSnapshot;
    Table.Insert(Table.Length, StringOfChar('c', 70000)); Table.Delete(8190, 25); Table.Text := 'replacement'; Table.Insert(0, 'new');
    Snapshot.ValidateStructure; Check(Snapshot.Text = BeforeSnapshot, 'piece snapshot survives append, delete and reset');
    Rejected := False; try Snapshot.Insert(0, 'blocked'); except on E: EInvalidOpException do Rejected := True; end;
    Check(Rejected, 'piece snapshot rejects mutation');
    Table.Free; Table := nil; Check(Snapshot.Text = BeforeSnapshot, 'piece snapshot survives source destruction');
  finally Snapshot.Free; Table.Free; end;
end;

procedure AppendBufferChecks;
var Buffer, Snapshot: TCodeChunkedAppendBuffer; Text: string; Builder: TStringBuilder; Count: Integer;
begin
  Buffer := TCodeChunkedAppendBuffer.Create(65536); Snapshot := nil; Builder := TStringBuilder.Create;
  try
    Text := StringOfChar('a', 65535) + #10 + StringOfChar('b', 65537) + #10;
    Check(Buffer.Append(Text) = 0, 'raw append starts at zero');
    Buffer.AppendTo(Builder, 0, Buffer.Length); Check(Builder.ToString = Text, 'raw append crosses distinct chunks');
    Check((Buffer.CountLineFeeds(0, Buffer.Length) = 2) and (Buffer.FindLineFeed(0, Buffer.Length, 0) = 65535), 'chunk newline lookup');
    Snapshot := Buffer.Snapshot; Buffer.AppendNormalized('c'#13#10'd'#13'e'#10, #13#10, Count);
    Check(Count = 9, 'normalized append CRLF length'); Buffer.Clear;
    Check((Snapshot.GetChar(0) = 'a') and (Snapshot.GetChar(65536) = 'b'), 'shared append snapshot survives clear');
    Builder.Clear; Snapshot.AppendTo(Builder, 0, Snapshot.Length); Check(Builder.ToString = Text, 'append snapshot retains full text');
  finally Builder.Free; Snapshot.Free; Buffer.Free; end;
end;

procedure DocumentChecks;
var Document: TCodeDocument; Snapshot: ICodeVirtualTextSource; I: Integer; Rejected: Boolean;
begin
  Document := TCodeDocument.Create(nil);
  try
    Document.Text := 'alpha' + #13#10 + 'beta' + #13 + 'gamma' + #10;
    Check((Document.LineCount = 4) and (Document.Text = 'alpha' + #10 + 'beta' + #10 + 'gamma' + #10), 'normalized multiline document');
    for I := 0 to Document.TextLength do Check(Document.GetOffset(Document.GetPosition(I)) = I, 'position/offset inversion');
    Snapshot := Document.GetSnapshot;
    Document.Replace(Range(0, 2, 2, 2), 'X' + #10 + 'Y');
    Check(Document.Text = 'alX' + #10 + 'Ymma' + #10, 'multiline replacement preserves suffix');
    Check((Snapshot.LineCount = 4) and (Snapshot.GetLineText(0) = 'alpha'), 'snapshot stays immutable after editing');
    Document.ReadOnly := True; Rejected := False;
    try Document.Insert(TCodeDocumentPosition.Create(0, 0), 'x'); except on E: EInvalidOpException do Rejected := True; end;
    Check(Rejected and (Document.GetLineText(0) = 'alX'), 'read-only protects model edits');
    Check(Document.IsModified, 'edited document is modified');
    Document.ValidateStorage;
  finally Snapshot := nil; Document.Free; end;
end;

procedure EditingChecks;
var Editor: TThemedCodeEditor; Options: TCodeSearchOptions; Hits: TArray<TCodeSearchMatch>;
begin
  Editor := TThemedCodeEditor.Create(nil);
  try
    Editor.Document.MarkSaved; Editor.InsertText('alpha'); Editor.InsertText(' beta');
    Check(Editor.Text = 'alpha beta', 'text input'); Editor.Undo;
    Check((Editor.Text = '') and not Editor.Document.IsModified, 'typing merge and clean undo');
    Editor.Redo; Check(Editor.Text = 'alpha beta', 'redo typing');
    Editor.GoToRange(Range(0, 0, 0, 5)); Editor.ReplaceSelection('gamma');
    Editor.Undo; Check(Editor.Text = 'alpha beta', 'selection replacement is one undo unit');
    Editor.Text := 'one one' + #10 + 'stone One' + #10;
    Options := TCodeSearchOptions.Create('one'); Options.WholeWord := True;
    Hits := Editor.FindAll(Options); Check(Length(Hits) = 3, 'whole-word case-insensitive search');
    Check(Editor.FindNext and (Editor.SelectionText = 'one'), 'search navigation');
    Check(Editor.ReplaceAll(Options, 'two') = 3, 'replace-all count'); Editor.Undo;
    Check(Editor.Text = 'one one' + #10 + 'stone One' + #10, 'replace-all undo group');
    Options.UseRegex := True; Options.Pattern := '(?i)\bone\b';
    Check(Length(Editor.FindAll(Options)) = 3, 'regex search parity');
    Editor.Text := 'abcdef' + #10 + 'uvwxyz'; Editor.SelectionMode := csmColumn;
    Editor.Selection.SetSelection(TCodeDocumentPosition.Create(0, 1), TCodeDocumentPosition.Create(1, 3));
    Check(Editor.SelectionText = 'bc' + sLineBreak + 'vw', 'column selection text');
    Editor.InsertText('!'); Check(Editor.Text = 'a!def' + #10 + 'u!xyz', 'column editing');
    Editor.Undo; Check(Editor.Text = 'abcdef' + #10 + 'uvwxyz', 'column editing undo');
    Editor.ReadOnly := True; Editor.InsertText('blocked'); Check(Editor.Text = 'abcdef' + #10 + 'uvwxyz', 'read-only UI editing');
    Editor.ReadOnly := False; Editor.Text := #9 + 'text  ';
    Editor.CleanupText([ctcTrimTrailingWhitespace, ctcConvertTabsToSpaces, ctcEnsureFinalNewLine]);
    Check(Editor.Text = '    text' + #10, 'cleanup and tab settings'); Editor.Undo;
    Check(Editor.Text = #9 + 'text  ', 'cleanup undo');
    Check(not Editor.HandleAllocated, 'model operations do not force an editor handle');
  finally Editor.Free; end;
end;

procedure TextGeometryAndDropChecks;
var Editor: TThemedCodeEditor; Document: TCodeDocument; Map: TCodeEditorVisualLineMap;
  Metrics: TCodeEditorRenderMetrics; Emoji, Joined: string; Hit: TCodeEditorWordHitInfo; PointValue: TPoint;
begin
  Editor := TThemedCodeEditor.Create(nil); Document := TCodeDocument.Create(nil); Map := TCodeEditorVisualLineMap.Create;
  try
    Emoji := Char($D83D) + Char($DE00); Joined := Char($D83D) + Char($DC69) + Char($200D) + Char($D83D) + Char($DCBB);
    Document.Text := 'a' + Emoji + 'b' + Joined + 'c';
    Map.MeasureLine := function(const Text: string; const TabSize: Integer; const CharWidth: Single): TArray<Single>
      var I, Last, J: Integer; X, Width: Single;
      begin
        SetLength(Result, Length(Text) + 1); I := 0; X := 0;
        while I < Length(Text) do
        begin
          Last := CodeTextElementEnd(Text, I); Width := CharWidth;
          if Last - I = 2 then Width := 15.25 else if Last - I = 5 then Width := 19.5;
          for J := I + 1 to Last do Result[J] := X + Width * (J - I) / (Last - I);
          X := X + Width; I := Last;
        end;
      end;
    Map.Rebuild(Document, nil, False, False, 80, 4);
    Check(Abs(Map.TextX(Document.GetLineText(0), 0, 3, 4, 7) - 22.25) < 0.001, 'measured emoji advance');
    Check(Abs(Map.TextX(Document.GetLineText(0), 0, 9, 4, 7) - 48.75) < 0.001, 'measured joined emoji advance');
    Metrics := Default(TCodeEditorRenderMetrics); Metrics.Bounds := Rect(0, 0, 200, 20); Metrics.TextBounds := Metrics.Bounds;
    Metrics.CharWidth := 7; Metrics.LineHeight := 20; Metrics.VisibleRows := 1;
    PointValue := CodePositionPoint(TCodeDocumentPosition.Create(0, 9), Metrics, Map, Document, 0, 0, 4);
    Check(PointValue.X = 49, 'caret uses measured prefix width');
    Check(CodeHitTest(Point(14, 1), Metrics, Map, Document, 0, 0, 4).Position.ColumnIndex = 1, 'emoji hit left half');
    Check(CodeHitTest(Point(16, 1), Metrics, Map, Document, 0, 0, 4).Position.ColumnIndex = 3, 'emoji hit right half');
    Document.Text := 'procedure Run(value: TForm); left := right;';
    Hit := CodeWordAt(Document, TCodeDocumentPosition.Create(0, Pos('Run', Document.Text))); Check(Hit.Word = 'Run', 'function word selection stops at parenthesis');
    Hit := CodeWordAt(Document, TCodeDocumentPosition.Create(0, Pos(':', Document.Text) - 1)); Check(Hit.Word = '', 'colon is a word separator');
    Hit := CodeWordAt(Document, TCodeDocumentPosition.Create(0, Pos('left', Document.Text))); Check(Hit.Word = 'left', 'assignment identifier selection');
    Editor.Text := 'abcXYZdef'; Editor.GoToRange(Range(0, 3, 0, 6));
    Check(Editor.DropSelectedText(TCodeDocumentPosition.Create(0, 9)), 'move selected text');
    Check(Editor.Text = 'abcdefXYZ', 'moving adjusts destination after source deletion');
    Editor.Undo; Check(Editor.Text = 'abcXYZdef', 'move is one undo operation');
    Editor.GoToRange(Range(0, 3, 0, 6)); Check(Editor.DropSelectedText(TCodeDocumentPosition.Create(0, 0), True), 'copy selected text');
    Check(Editor.Text = 'XYZabcXYZdef', 'copy preserves source selection text');
    Editor.Undo; Editor.GoToRange(Range(0, 3, 0, 6));
    Check(not Editor.DropSelectedText(TCodeDocumentPosition.Create(0, 4)), 'move into source selection is rejected');
    Editor.ReadOnly := True; Check(not Editor.DropSelectedText(TCodeDocumentPosition.Create(0, 0)), 'readonly rejects drops');
  finally Map.Free; Document.Free; Editor.Free; end;
end;

procedure UnicodeEditingChecks;
var Editor: TCodeEditorInputProbe; Elements: TArray<string>; Element, Emoji: string; I: Integer;
begin
  Emoji := Char($D83D) + Char($DE00);
  Elements := TArray<string>.Create(Emoji, 'e' + Char($0301),
    Char($D83D) + Char($DC4D) + Char($D83C) + Char($DFFB),
    Char($D83D) + Char($DC69) + Char($200D) + Char($D83D) + Char($DCBB),
    Char($D83C) + Char($DDE9) + Char($D83C) + Char($DDEA),
    '1' + Char($FE0F) + Char($20E3));
  Editor := TCodeEditorInputProbe.Create(nil);
  try
    for Element in Elements do
    begin
      Check(CodeNextTextElement(Element, 0) = Length(Element), 'next complete Unicode text element');
      Check(CodePreviousTextElement(Element, Length(Element)) = 0, 'previous complete Unicode text element');
      for I := 1 to Length(Element) - 1 do
      begin
        Check(CodeClampTextElement(Element, I) = 0, 'interior position snaps before text element');
        Check(CodeClampTextElement(Element, I, True) = Length(Element), 'interior range end snaps after text element');
      end;
      Editor.Text := 'x' + Element + 'y'; Editor.GoToRange(Range(0, 1, 0, 1));
      Editor.Press(VK_RIGHT); Check(Editor.Caret.Position.ColumnIndex = Length(Element) + 1, 'right moves over complete text element');
      Editor.Press(VK_LEFT); Check(Editor.Caret.Position.ColumnIndex = 1, 'left moves over complete text element');
      Editor.Press(VK_DELETE); Check(Editor.Text = 'xy', 'delete removes complete text element');
      Editor.Undo; Check(Editor.Text = 'x' + Element + 'y', 'Unicode deletion undo');
      Editor.GoToRange(Range(0, Length(Element) + 1, 0, Length(Element) + 1));
      Editor.Press(VK_BACK); Check(Editor.Text = 'xy', 'backspace removes complete text element');
      Editor.Text := Element; Editor.Caret.Position := TCodeDocumentPosition.Create(0, 1);
      Editor.TypeChar(' '); Check(Editor.Text = ' ' + Element, 'space insertion cannot split a text element');
      Check(CodeCharacterColumn(Element, 1, 4) in [0, Length(Element)], 'mouse hit never enters text element');
    end;
    Editor.Text := ''; Editor.TypeChar(Char($D83D)); Check(Editor.Text = '', 'high surrogate waits for low surrogate');
    Editor.TypeChar(Char($DE00)); Check(Editor.Text = Emoji, 'UTF-16 keyboard messages insert one complete scalar');
    Check(Editor.Caret.Position.ColumnIndex = 2, 'typed emoji caret follows complete pair');
    Editor.Press(VK_BACK); Check(Editor.Text = '', 'typed emoji backspace');
    Check(not Editor.HandleAllocated, 'Unicode editing does not force an HWND');
  finally Editor.Free; end;
end;

procedure DeletionChecks;
var Document: TCodeDocument; Editor: TThemedCodeEditor;
begin
  Document := TCodeDocument.Create(nil); Editor := TThemedCodeEditor.Create(nil);
  try
    Document.Text := 'abc'#13#10'def'#10'ghi';
    Check(Document.Delete(Range(0, 1, 0, 2)) = 'b', 'single character deletion returns removed text');
    Check(Document.Text = 'ac'#10'def'#10'ghi', 'single character deletion preserves other lines');
    Document.Delete(Range(0, 1, 1, 2));
    Check((Document.Text = 'af'#10'ghi') and (Document.GetLineEndingKind(0) = cnkUnix), 'multiline deletion joins suffix and preserves ending');
    Document.Delete(Range(0, 0, 1, 3));
    Check((Document.Text = '') and (Document.LineCount = 1) and (Document.TextLength = 0), 'deleting all text retains one empty line');
    Check(Document.GetLineEndingKind(0) = cnkUnknown, 'empty document has no line ending');
    Editor.Text := 'abc'#13#10#13#10'def';
    Editor.GoToRange(Range(0, 1, 2, 2)); Editor.InsertText('', 'Delete Selection');
    Check(Editor.Text = 'af', 'empty replacement deletes selected multiline text');
    Editor.Undo;
    Check((Editor.Text = 'abc'#10#10'def') and (Editor.Document.GetLineEndingKind(0) = cnkWindows), 'deletion undo restores text and endings');
    Editor.Redo; Check(Editor.Text = 'af', 'deletion redo');
    Editor.SelectAll; Editor.InsertText('', 'Delete Selection');
    Check((Editor.Text = '') and (Editor.Document.LineCount = 1), 'select-all deletion empties editor');
    Editor.Undo; Check(Editor.Text = 'af', 'select-all deletion undo');
  finally Editor.Free; Document.Free; end;
end;

procedure LanguageChecks;
var Registry: TCodeLanguageRegistry; Document: TCodeDocument; Language: ICodeLanguageDefinition;
  Highlighter: ICodeSyntaxHighlighter; Highlight: TCodeHighlightResult; Span: TCodeHighlightSpan;
  Keywords, Declarations, Strings, Comments: Boolean; EmojiText: string; Units: Integer;
begin
  Registry := TCodeLanguageRegistry.Create; Document := TCodeDocument.Create(nil);
  try
    Check(Registry.Languages.Count = 12, 'eight original and four additional language definitions');
    Check(Registry.FindByExtension('pas').Name = 'delphi', 'Delphi extension');
    Check(Registry.FindByExtension('.ps1').Name = 'powershell', 'PowerShell extension');
    Language := Registry.FindByName('C#'); Highlighter := TLanguageBasedCodeSyntaxHighlighter.Create(Language);
    Document.Text := 'public class Sample { string value = "text"; /* comment' + #10 + 'continued */ }';
    Highlight := Highlighter.HighlightLine(Document, 0, Default(TCodeHighlightState));
    Keywords := False; Declarations := False; Strings := False; Comments := False;
    for Span in Highlight.Spans do
    begin
      if Span.Kind = chtAccessKeyword then Keywords := True;
      if Span.Kind = chtClassName then Declarations := True;
      if Span.Kind = chtString then Strings := True;
      if Span.Kind = chtComment then Comments := True;
    end;
    Check(Keywords and Declarations and Strings and Comments, 'semantic token categories');
    Highlight := Highlighter.HighlightLine(Document, 1, Highlight.State);
    Check((Highlight.Spans[0].Kind = chtComment) and (Highlight.State.BlockEnd = ''), 'multiline comment state');
    EmojiText := Char($D83D) + Char($DE00); Document.Text := EmojiText;
    Highlight := Highlighter.HighlightLine(Document, 0, Default(TCodeHighlightState));
    Check((Length(Highlight.Spans) = 1) and (Highlight.Spans[0].Length = 2), 'emoji surrogate pair stays in one syntax span');
    Check(NimbusEmojiAt(EmojiText, 1, Units) and (Units = 2), 'supplementary emoji font run');
    Check(not NimbusEmojiAt(Char($D840) + Char($DC00), 1, Units) and (Units = 2), 'supplementary CJK preserves pair without emoji font');
    Check(not NimbusEmojiAt(Char($D83D), 1, Units) and (Units = 1), 'incomplete surrogate is not an emoji');
    Document.Text := EmojiText + Char($200D) + EmojiText;
    Highlight := Highlighter.HighlightLine(Document, 0, Default(TCodeHighlightState));
    Check((Length(Highlight.Spans) = 1) and (Highlight.Spans[0].Length = 5), 'joined emoji sequence stays in one syntax span');
  finally Highlighter := nil; Language := nil; Document.Free; Registry.Free; end;
end;

procedure SemanticChecks;
var Registry: TCodeLanguageRegistry; Document: TCodeDocument; Highlighter: ICodeSyntaxHighlighter;
  Highlight: TCodeHighlightResult; State: TCodeHighlightState; Span: TCodeHighlightSpan; Offset, Last: Integer;
  procedure Line(const Language, Text: string);
  begin
    Highlighter := TLanguageBasedCodeSyntaxHighlighter.Create(Registry.FindByName(Language));
    Document.Text := Text; Highlight := Highlighter.HighlightLine(Document, 0, State); State := Highlight.State;
    Last := 0;
    for Span in Highlight.Spans do
    begin Check((Span.Start = Last) and (Span.Length > 0), 'highlight spans are contiguous and do not overlap'); Inc(Last, Span.Length); end;
    Check(Last = Length(Text), 'highlight spans cover complete source line');
  end;
  procedure Token(const Text, Word: string; const Kind: TCodeEditorHighlightTokenKind);
  var Span: TCodeHighlightSpan; Found: Boolean;
  begin
    Offset := Pos(Word, Text) - 1; Found := False;
    for Span in Highlight.Spans do if (Offset >= Span.Start) and (Offset < Span.Start + Span.Length) then
    begin Check(Span.Kind = Kind, 'token category for ' + Word); Found := True; Break; end;
    Check(Found, 'token exists for ' + Word);
  end;
begin
  Registry := TCodeLanguageRegistry.Create; Document := TCodeDocument.Create(nil);
  try
    State := Default(TCodeHighlightState);
    Line('delphi', 'uses System.SysUtils;'); Token(Document.Text, 'uses', chtImportKeyword); Token(Document.Text, 'System', chtImportName);
    Line('delphi', 'OptionsDialog: TForm;'); Token(Document.Text, 'OptionsDialog', chtVariableName); Token(Document.Text, 'TForm', chtClassName);
    Line('delphi', 'OptionsDialog.Show;'); Token(Document.Text, 'OptionsDialog', chtVariableName);
    Line('delphi', 'procedure Run(ADialog: TForm; Count: Integer);');
    Token(Document.Text, 'procedure', chtDeclarationKeyword); Token(Document.Text, 'ADialog', chtParameterName);
    Token(Document.Text, 'TForm', chtClassName); Token(Document.Text, 'Count', chtParameterName); Token(Document.Text, 'Integer', chtTypeKeyword);
    Line('delphi', 'begin for I := 1 to 10 do Result := I; end;'); Token(Document.Text, 'begin', chtBlockKeyword); Token(Document.Text, 'for', chtLoopKeyword); Token(Document.Text, 'Result', chtResultName);
    Line('delphi', '{$IFDEF DEBUG}'); Token(Document.Text, 'DEBUG', chtPreprocessor);
    State := Default(TCodeHighlightState);
    Line('csharp', 'const int Limit = 10;'); Token(Document.Text, 'int', chtTypeKeyword); Token(Document.Text, 'Limit', chtConstantName);
    Line('csharp', 'value = Limit;'); Token(Document.Text, 'Limit', chtConstantName);
    Line('csharp', 'void Run(int count) { }'); Token(Document.Text, 'count', chtParameterName);
    Line('csharp', '/// <summary name="x">Text</summary>'); Token(Document.Text, 'summary', chtXmlDocTag); Token(Document.Text, 'name', chtXmlDocAttribute); Token(Document.Text, '"x"', chtXmlDocValue);
    State := Default(TCodeHighlightState);
    Line('rust', 'fn run(count: usize) { }'); Token(Document.Text, 'count', chtParameterName); Token(Document.Text, 'usize', chtTypeKeyword);
    Line('rust', 'let text = r#"raw {'); Check(State.RawStringEnd <> '', 'Rust raw string continues across lines');
    Line('rust', '}"#;'); Check(State.RawStringEnd = '', 'Rust raw string closes');
    Line('rust', '/* outer /* nested */'); Check(State.BlockDepth = 1, 'Rust nested comment depth');
    Line('rust', 'outer */'); Check(State.BlockEnd = '', 'Rust nested comment closes');
    Line('rust', 'for i in 0..count { }'); Token(Document.Text, 'count', chtParameterName);
    State := Default(TCodeHighlightState);
    Line('javascript', 'const count = 10;'); Token(Document.Text, 'count', chtConstantName);
    Line('javascript', 'const text = `first'); Check(State.StringQuote = '`', 'JavaScript template continues across lines');
    Line('javascript', 'last`;'); Check(State.StringQuote = #0, 'JavaScript template closes');
    State := Default(TCodeHighlightState);
    Line('vb', 'Dim dialog As Form'); Token(Document.Text, 'dialog', chtVariableName); Token(Document.Text, 'Form', chtClassName);
    State := Default(TCodeHighlightState);
    Line('powershell', 'foreach ($item in $items) { }'); Token(Document.Text, 'foreach', chtLoopKeyword); Token(Document.Text, '$item', chtVariableName);
    State := Default(TCodeHighlightState);
    Line('batch', 'echo %NAME%'); Token(Document.Text, '%NAME%', chtVariableName);
    Line('batch', 'rem INFO sample'); Token(Document.Text, 'INFO', chtComment);
    State := Default(TCodeHighlightState);
    Line('markdown', '# Heading'); Token(Document.Text, 'Heading', chtMarkdownHeading);
    Line('markdown', '```pascal'); Line('markdown', 'Result := 42;'); Token(Document.Text, 'Result', chtMarkdownCode);
    Line('markdown', '```'); Check(State.MarkdownFence = '', 'Markdown fence closes');
    Check(Registry.FindByExtension('.rs').Name = 'rust', 'Rust extension'); Check(Registry.FindByExtension('.js').Name = 'javascript', 'JavaScript extension');
    Check(Registry.FindByExtension('.md').Name = 'markdown', 'Markdown extension'); Check(Registry.FindByExtension('.cmd').Name = 'batch', 'Batch extension');
  finally Highlighter := nil; Document.Free; Registry.Free; end;
end;

procedure BreakpointChecks;
var Editor: TThemedCodeEditor; Breakpoint: TCodeBreakpoint;
begin
  Editor := TThemedCodeEditor.Create(nil);
  try
    Editor.Text := 'first'#10'second'#10'third'; Editor.GoToLine(1); Editor.ToggleBreakpoint;
    Check(Editor.Breakpoints.TryGet(1, Breakpoint) and Breakpoint.Enabled, 'breakpoint toggle adds enabled breakpoint');
    Breakpoint.Condition := 'count > 5'; Breakpoint.HitCount := 3; Breakpoint.LogMessage := 'Hit {count}'; Editor.Breakpoints.Put(Breakpoint);
    Editor.Breakpoints.SetEnabled(1, False); Editor.ExecutionLine := 1;
    Editor.Document.Insert(TCodeDocumentPosition.Create(0, 0), 'inserted'#10);
    Check(Editor.Breakpoints.TryGet(2, Breakpoint) and not Breakpoint.Enabled and (Breakpoint.Condition = 'count > 5') and (Breakpoint.HitCount = 3), 'breakpoint metadata follows inserted lines');
    Check(Editor.ExecutionLine = 2, 'execution line follows inserted lines');
    Editor.Document.Delete(Range(0, 0, 3, 0)); Check(Length(Editor.Breakpoints.Items) = 0, 'breakpoint removed with deleted source line');
    Check(Editor.ExecutionLine = -1, 'execution line cleared when removed');
    Editor.Text := 'new'; Check(Length(Editor.Breakpoints.Items) = 0, 'new document clears breakpoints');
    Check(not Editor.HandleAllocated, 'debug models do not require a window handle');
  finally Editor.Free; end;
end;

procedure AnalysisChecks;
var Document: TCodeDocument; Registry: TCodeLanguageRegistry; Patterns: TCodeEditorSymbolPatternRegistry;
  Highlighter: ICodeSyntaxHighlighter; Analyzer: TCodeEditorAnalyzer; FoldManager: TCodeFoldManager;
  Map: TCodeEditorVisualLineMap; Job: TCodeEditorAnalysisJob; Result: TCodeEditorAnalysisResult;
  Providers: TArray<ICodeEditorSymbolProvider>; I: Integer; Pair: TCodeBracketPair; HasRun: Boolean;
begin
  Document := TCodeDocument.Create(nil); Registry := TCodeLanguageRegistry.Create;
  Patterns := TCodeEditorSymbolPatternRegistry.Create; Analyzer := TCodeEditorAnalyzer.Create;
  FoldManager := TCodeFoldManager.Create(nil); Map := TCodeEditorVisualLineMap.Create; Job := nil;
  try
    Document.Text := 'public class Sample' + #10 + '{' + #10 +
      '    public void Run()' + #10 + '    {' + #10 + '        var text = "{ ignored }";' + #10 +
      '        if (true) { Value(42); }' + #10 + '    }' + #10 + '}';
    Highlighter := TLanguageBasedCodeSyntaxHighlighter.Create(Registry.FindByName('csharp'));
    Analyzer.Start(Document.GetSnapshot, Highlighter);
    while not Analyzer.Complete do Analyzer.Advance(1, 10);
    Check(Analyzer.Folds.Count >= 2, 'brace folding regions');
    for Pair in Analyzer.Pairs do Check(Pair.OpenPosition.LineIndex <> 4, 'brackets in strings are ignored');
    FoldManager.SetRegions(Analyzer.Folds.ToArray); FoldManager.SetAllCollapsed(True);
    Map.Rebuild(Document, FoldManager, True, False, 80, 4); Check(Map.Count < Document.LineCount, 'collapsed visual line map');
    FoldManager.Reveal(TCodeDocumentPosition.Create(5, 10));
    Map.Rebuild(Document, FoldManager, True, True, 20, 4); Check(Map.Count > 1, 'reveal and wrapped visual rows');
    Providers := TArray<ICodeEditorSymbolProvider>.Create(TLocalCodeSymbolProvider.Create(Patterns));
    Job := TCodeEditorAnalysisJob.Create(Document.GetSnapshot, Highlighter, 'csharp', nil, Providers, nil, True, True, True);
    Job.Start; Job.WaitFor; Result := Job.TakeResult;
    Check(Result.ErrorText = '', 'background analysis: ' + Result.ErrorText);
    HasRun := False;
    for I := 0 to High(Result.Symbols) do if Result.Symbols[I].Name = 'Run' then
    begin HasRun := True; Check(Result.Symbols[I].ParentIndex >= 0, 'nested symbol hierarchy'); end;
    Check(HasRun and (Result.Version = Document.Version), 'original C# method symbol pattern');
  finally
    if Job <> nil then begin Job.Terminate; Job.WaitFor; Job.Free; end;
    Providers := nil; Highlighter := nil; Map.Free; FoldManager.Free; Analyzer.Free;
    Patterns.Free; Registry.Free; Document.Free;
  end;
end;

procedure FileChecks;
var Document, Loaded: TCodeDocument; Root, Path, Text, AddonPath: string; G: TGUID;
  Encoding: TCodeTextEncoding; Rejected: Boolean; Registry: TCodeLanguageRegistry;
begin
  Root := TestFixtureRoot;
  ForceDirectories(Root); CreateGUID(G); Path := TPath.Combine(Root, GUIDToString(G) + '.txt'); AddonPath := Path + '.nclang';
  Document := TCodeDocument.Create(nil); Loaded := TCodeDocument.Create(nil); Registry := TCodeLanguageRegistry.Create;
  try
    Text := 'class ' + Char($03A9) + ' ' + Char($4E2D) + Char($D83D) + Char($DE00) + #10 + 'tail' + #10;
    Document.Text := Text; Document.HasByteOrderMark := True; Document.NewLineMode := cnmUnix;
    for Encoding := nlfeUTF8 to nlfeUTF32BE do
    begin
      if Encoding in [nlfeANSI, nlfeASCII] then Continue;
      Document.Encoding := Encoding; Document.SaveToFile(Path); Loaded.LoadFromFile(Path);
      Check((Loaded.Text = Text) and Loaded.HasByteOrderMark and (Loaded.NewLineKind = cnkUnix), 'Unicode file roundtrip and metadata');
    end;
    Loaded.Encoding := nlfeASCII; Rejected := False;
    try Loaded.SaveToFile(Path); except on E: EConvertError do Rejected := True; end;
    Check(Rejected, 'lossy save rejected'); Document.LoadFromFile(Path); Check(Document.Text = Text, 'failed save preserves destination');
    TFile.WriteAllText(Path, 'a' + #13#10 + 'b' + #10 + 'c' + #13, TEncoding.UTF8); Loaded.LoadFromFile(Path);
    Check((Loaded.NewLineKind = cnkMixed) and (Loaded.LineCount = 4), 'mixed endings and final empty line');
    TFile.WriteAllText(AddonPath, 'name=demo' + #10 + 'extensions=.demo' + #10 + 'lineComment=//' + #10 + 'keywords=rule,when,end' + #10 + 'classKeywords=entity', TEncoding.UTF8);
    Check(Registry.RegisterFromFile(AddonPath), 'nclang loading'); Check(Registry.FindByExtension('.demo').Classify('rule') = chtKeyword, 'dynamic language keyword');
  finally
    if TFile.Exists(Path) then TFile.Delete(Path); if TFile.Exists(AddonPath) then TFile.Delete(AddonPath);
    Registry.Free; Loaded.Free; Document.Free;
  end;
end;

procedure RendererChecks;
var Editor: TThemedCodeEditor; Bitmap: Vcl.Graphics.TBitmap; Backend: ICodeEditorRenderBackend;
  Renderer: ICodeEditorRenderer; Metrics: TCodeEditorRenderMetrics; Map: TCodeEditorVisualLineMap;
  Cache: TCodeHighlightCache; Context: TCodeEditorRenderContext; Highlighter: ICodeSyntaxHighlighter;
  Point: TPoint; Hit: TCodeEditorHitInfo; Text: TStringBuilder; I: Integer; Watch: TStopwatch; Failed: Boolean;
begin
  Editor := TThemedCodeEditor.Create(nil); Bitmap := Vcl.Graphics.TBitmap.Create;
  Map := TCodeEditorVisualLineMap.Create; Cache := TCodeHighlightCache.Create; Text := TStringBuilder.Create;
  try
    for I := 1 to 20000 do Text.Append('Value(42);' + #9);
    Editor.Text := Text.ToString; Bitmap.SetSize(640, 240);
    Backend := TCodeEditorGDIPlusBackend.Create(TNimbusRenderCanvas.Create); Renderer := TThemedCodeEditorRenderer.Create;
    Highlighter := TLanguageBasedCodeSyntaxHighlighter.Create(Editor.Language); Cache.Attach(Editor.Document, Highlighter);
    Backend.BeginFrame(Bitmap.Canvas, Rect(0, 0, 640, 240), 96);
    try
      Metrics := Renderer.Measure(Backend, Editor.Font, Rect(0, 0, 640, 240), 96, 1, Editor.Options);
      Map.Rebuild(Editor.Document, Editor.FoldManager, True, False, 80, Editor.Options.TabSize);
      Point := CodePositionPoint(TCodeDocumentPosition.Create(0, 5), Metrics, Map, Editor.Document, 0, 0, 4);
      Hit := CodeHitTest(Point, Metrics, Map, Editor.Document, 0, 0, 4);
      Check(Hit.Position.ColumnIndex = 5, 'shared paint/hit geometry');
      Context := Default(TCodeEditorRenderContext); Context.Source := Editor.Document; Context.Font := Editor.Font;
      Context.Options := Editor.Options; Context.Theme := Editor.Theme; Context.Metrics := Metrics; Context.Map := Map;
      Context.Highlights := Cache; Context.Bookmarks := Editor.Bookmarks; Context.Folds := Editor.FoldManager;
      Context.CommentStyles := Editor.CommentStyles; Context.Enabled := True;
      Watch := TStopwatch.StartNew; Renderer.Render(Backend, Context); Watch.Stop;
      Writeln('Long source row render milliseconds: ' + IntToStr(Watch.ElapsedMilliseconds));
    finally Backend.EndFrame; end;
    Editor.RenderBackend := Backend; Editor.Renderer := Renderer;
    Failed := False;
    try Backend := TCodeEditorDLLBackend.Create(TPath.Combine(ExtractFilePath(ParamStr(0)), 'missing-renderer.dll')); except on E: EOSError do Failed := True; end;
    Check(Failed, 'missing DLL is rejected');
    Check(Editor.RenderBackend <> nil, 'failed DLL load preserves selected backend');
  finally
    Context.Source := nil; Backend := nil; Renderer := nil; Highlighter := nil;
    Text.Free; Cache.Free; Map.Free; Bitmap.Free; Editor.Free;
  end;
end;

procedure MouseInteractionChecks;
var Host: TForm; Editor: TCodeEditorInputProbe; At, Target: TPoint; Offset: Integer;
  function TextPoint(const Column: Integer): TPoint;
  var X: Integer; Hit: TCodeEditorHitInfo;
  begin
    for X := 0 to Editor.ClientWidth - 1 do
    begin
      Hit := Editor.HitTest(Point(X, 5));
      if (Hit.Area = chaText) and (Hit.Position.ColumnIndex = Column) then Exit(Point(X, 5));
    end;
    raise Exception.Create('Text column is not visible');
  end;
  procedure DoubleClickAt(const Column: Integer; const Keys: WPARAM = MK_LBUTTON; const FirstClick: Boolean = False);
  var At: TPoint; Coordinates: LPARAM;
  begin
    At := TextPoint(Column); Coordinates := LPARAM((At.Y shl 16) or At.X);
    if FirstClick then
    begin Editor.Perform(WM_LBUTTONDOWN, Keys, Coordinates); Editor.Perform(WM_LBUTTONUP, 0, Coordinates); end;
    Editor.Perform(WM_LBUTTONDBLCLK, Keys, Coordinates);
    Editor.Perform(WM_LBUTTONUP, 0, Coordinates);
  end;
begin
  Host := TForm.CreateNew(nil);
  try
    Editor := TCodeEditorInputProbe.Create(Host); Editor.Parent := Host; Editor.SetBounds(0, 0, 640, 240);
    Check(Editor.Handle <> 0, 'mouse interaction test HWND');
    Editor.Text := 'alpha beta gamma'; DoubleClickAt(8);
    Check(Editor.SelectionText = 'beta', 'native double click selects the clicked word');
    Editor.ReadOnly := True; DoubleClickAt(2);
    Check(Editor.SelectionText = 'alpha', 'double click selection works read only');
    Editor.ReadOnly := False; Editor.Text := 'if (value == other)'; DoubleClickAt(1);
    Check(Editor.SelectionText = 'if', 'double click selects keywords');
    Editor.Zoom := 200; DoubleClickAt(6);
    Check(Editor.SelectionText = 'value', 'double click uses zoomed hit testing');
    Editor.ResetZoom; Editor.Text := '{ { beta; } }'; Editor.GoToRange(Range(0, 4, 0, 8));
    DoubleClickAt(6, MK_LBUTTON, True);
    Check(Editor.SelectionText = '{ beta; }', 'native first click preserves selection for enclosing block double click');
    Editor.ReadOnly := True; DoubleClickAt(6, MK_LBUTTON, True);
    Check(Editor.SelectionText = Editor.Text, 'read only double click expands to parent block');
    Editor.ReadOnly := False; Editor.Text := 'for (int i=0; i<3; i++) { Work(); }';
    Offset := Pos('Work', Editor.Text) - 1; Editor.GoToRange(Range(0, Offset, 0, Offset + 4));
    DoubleClickAt(Offset + 1, MK_LBUTTON, True);
    Check(Editor.SelectionText = Editor.Text, 'native double click includes C# loop header');
    Editor.Text := 'var a = new[] { 11, 22 };'; Offset := Pos('22', Editor.Text) - 1;
    Editor.GoToRange(Range(0, Offset, 0, Offset + 2)); DoubleClickAt(Offset, MK_LBUTTON, True);
    Check(Editor.SelectionText = 'new[] { 11, 22 }', 'native double click selects complete array initializer');
    Editor.SetLanguage('delphi'); Editor.Text := 'procedure Run; begin Work; end;'; Offset := Pos('Work', Editor.Text) - 1;
    Editor.GoToRange(Range(0, Offset, 0, Offset + 4)); DoubleClickAt(Offset + 1, MK_LBUTTON, True);
    Check(Editor.SelectionText = Editor.Text, 'native double click includes Delphi routine declaration');
    Editor.SetLanguage('csharp');
    Editor.ReadOnly := False; Editor.Text := 'alpha beta gamma'#10'tail'; Editor.GoToRange(Range(0, 6, 0, 10));
    DoubleClickAt(8, MK_LBUTTON or MK_SHIFT, True);
    Check(CodeNormalizeNewLines(Editor.SelectionText) = 'alpha beta gamma'#10, 'shift double click selects only clicked logical line');
    Editor.Text := 'last line'; DoubleClickAt(2, MK_LBUTTON or MK_SHIFT);
    Check(Editor.SelectionText = 'last line', 'shift double click selects final line without extra newline');
    Editor.Text := 'alpha beta gamma'; Editor.GoToRange(Range(0, 6, 0, 10)); DoubleClickAt(8, MK_LBUTTON, True);
    Check(Editor.SelectionText = 'beta', 'missing code block preserves existing selection');
    Editor.ResetZoom; Editor.Text := 'abcXYZdef'; Editor.GoToRange(Range(0, 3, 0, 6));
    At := TextPoint(4); Target := TextPoint(9); Editor.PrepareTextDrag(At);
    Check(Editor.AcceptsTextDrop(Editor, Target), 'internal text drag accepted without OnDragOver handler');
    Editor.OnDragOver := Editor.RejectTextDrop;
    Check(not Editor.AcceptsTextDrop(Editor, Target), 'OnDragOver can veto internal text drag');
    Editor.OnDragOver := nil;
    Check(not Editor.AcceptsTextDrop(Editor, Point(0, 5)), 'gutter rejects internal text drag');
    Editor.ReadOnly := True;
    Check(not Editor.AcceptsTextDrop(Editor, Target), 'readonly target rejects internal text drag');
    Editor.ReadOnly := False; Editor.DragDrop(Editor, Target.X, Target.Y); Editor.FinishTextDrag;
    Check(Editor.Text = 'abcdefXYZ', 'mouse drop moves selected text');
    Editor.Undo; Check(Editor.Text = 'abcXYZdef', 'mouse drop is one undo operation');
    Editor.GoToRange(Range(0, 3, 0, 6)); Target := TextPoint(0); Editor.PrepareTextDrag(TextPoint(4));
    Check(Editor.AcceptsTextDrop(Editor, Target), 'moving selected text backwards accepted');
    Editor.DragDrop(Editor, Target.X, Target.Y); Editor.FinishTextDrag;
    Check(Editor.Text = 'XYZabcdef', 'mouse drop moves selected text backwards');
    Editor.Undo; Editor.GoToRange(Range(0, 3, 0, 6)); Editor.PrepareTextDrag(TextPoint(4));
    Editor.Text := Editor.Text + '!';
    Check(not Editor.AcceptsTextDrop(Editor, TextPoint(0)), 'document edit invalidates pending text drag');
    Editor.FinishTextDrag;
    Editor.Text := 'abcXYZdef'; Editor.GoToRange(Range(0, 3, 0, 6)); Target := TextPoint(9);
    Editor.StartNativeTextDrag(TextPoint(4));
    try
      Check(Editor.Dragging, 'native mouse messages start VCL dragging');
      Check(Editor.SelectionText = 'XYZ', 'native drag start preserves the selection');
      Check(Editor.AcceptsTextDrop(Editor, Target), 'native drag start preserves text payload through MouseUp');
      Editor.DragDrop(Editor, Target.X, Target.Y);
      Check(Editor.Text = 'abcdefXYZ', 'native drag payload can be moved');
    finally Editor.EndDrag(False); end;
    Check(not Editor.Dragging and not Editor.AcceptsTextDrop(Editor, Target), 'drag end clears native drag payload');
    Editor.Undo; Check(Editor.Text = 'abcXYZdef', 'native drag move remains one undo operation');
    Editor.GoToRange(Range(0, 3, 0, 6)); Editor.StartNativeTextDrag(TextPoint(4));
    Editor.EndDrag(False);
    Check((Editor.Text = 'abcXYZdef') and (Editor.SelectionText = 'XYZ'), 'native drag cancellation preserves text and selection');
  finally Host.Free; end;
end;

procedure ZoomChecks;
var Host: TForm; Editor: TCodeEditorInputProbe; Loaded: TThemedCodeEditor; Stream: TMemoryStream;
  Height, Version, Column: Integer; Hit: TCodeEditorHitInfo;
begin
  Host := TForm.CreateNew(nil);
  try
    Editor := TCodeEditorInputProbe.Create(Host);
    Check((Editor.Zoom = 100) and not Editor.HandleAllocated, 'zoom defaults without HWND');
    Editor.Text := StringOfChar('x', 100) + #10 + StringOfChar('x', 100);
    Height := Editor.Font.Height; Version := Editor.Document.Version;
    Editor.Zoom := 200; Check(Editor.Font.Height = Height, 'zoom preserves base font');
    Editor.Font.Name := 'Courier New'; Editor.Font.Size := 12; Height := Editor.Font.Height;
    Check(Editor.Zoom = 200, 'font assignment preserves zoom');
    Editor.Zoom := -100; Check(Editor.Zoom = 25, 'minimum zoom');
    Editor.ZoomOut; Check(Editor.Zoom = 25, 'zoom out at minimum');
    Editor.Zoom := MaxInt; Check(Editor.Zoom = 400, 'maximum zoom');
    Editor.ZoomIn; Check(Editor.Zoom = 400, 'zoom in at maximum');
    Editor.ResetZoom; Editor.ReadOnly := True;
    Editor.ZoomKey(VK_ADD); Check(Editor.Zoom = 110, 'keyboard zoom in read only mode');
    Editor.ZoomKey(VK_OEM_MINUS); Check(Editor.Zoom = 100, 'main keyboard zoom out');
    Editor.Wheel(60, [ssCtrl]); Check(Editor.Zoom = 100, 'partial wheel delta retained');
    Editor.Wheel(60, [ssCtrl]); Check(Editor.Zoom = 110, 'partial wheel deltas accumulate');
    Editor.Wheel(60, [ssCtrl]); Editor.Wheel(60, []); Editor.Wheel(60, [ssCtrl]);
    Check(Editor.Zoom = 110, 'modifier changes discard previous partial wheel delta');
    Editor.Wheel(-60, [ssCtrl]); Check(Editor.Zoom = 110, 'opposite partial deltas cancel');
    Editor.ZoomKey(Ord('0')); Check(Editor.Zoom = 100, 'keyboard zoom reset');
    Check((Editor.Font.Height = Height) and (Editor.Document.Version = Version) and not Editor.UndoManager.CanUndo,
      'view changes preserve font, document and undo history');
    Check(not Editor.HandleAllocated, 'zoom and font changes do not create HWND');
    Stream := TMemoryStream.Create;
    try
      Editor.Zoom := 175; Stream.WriteComponent(Editor); Stream.Position := 0;
      Loaded := TCodeEditorInputProbe.Create(nil);
      try
        Stream.ReadComponent(Loaded);
        Check((Loaded.Zoom = 175) and (Loaded.Font.Name = Editor.Font.Name) and (Loaded.Font.Height = Editor.Font.Height),
          'component streaming preserves zoom and base font');
        Check(not Loaded.HandleAllocated, 'component streaming does not create HWND');
      finally Loaded.Free; end;
    finally Stream.Free; end;
    Editor.ResetZoom;
    Editor.Parent := Host; Editor.SetBounds(0, 0, 640, 240);
    Check(Editor.Handle <> 0, 'geometry test HWND');
    Hit := Editor.HitTest(Point(300, 5)); Column := Hit.Position.ColumnIndex;
    Editor.Zoom := 200; Hit := Editor.HitTest(Point(300, 5));
    Check((Hit.Position.ColumnIndex > 0) and (Hit.Position.ColumnIndex < Column), 'zoom updates hit test metrics');
    Editor.ResetZoom; Hit := Editor.HitTest(Point(300, 5));
    Check(Hit.Position.ColumnIndex = Column, 'zoom reset restores hit test metrics');
  finally Host.Free; end;
end;

procedure PopupChecks;
var Host: TForm; Editor: TThemedCodeEditor; Popup: TThemedDropdownPopupForm;
  Probe: TPopupLifecycleProbe; ActiveWindow, FocusWindow: HWND;
begin
  Host := TForm.CreateNew(nil); Probe := TPopupLifecycleProbe.Create;
  try
    Editor := TThemedCodeEditor.Create(Host); Editor.Parent := Host;
    Host.Show; Editor.SetFocus;
    ActiveWindow := GetActiveWindow; FocusWindow := GetFocus;
    Popup := TThemedDropdownPopupForm.Create(Host); Probe.Popup := Popup;
    Popup.OnShow := Probe.Shown; Popup.OnHide := Probe.Hidden;
    Popup.ShowPopup(Editor, Rect(50, 50, 350, 200));
    Check(Popup.Visible and Popup.PopupVisible, 'completion popup stays visible');
    Check((GetActiveWindow = ActiveWindow) and (GetFocus = FocusWindow), 'completion popup preserves activation and editor focus');
    Popup.ShowPopup(Editor, Rect(60, 60, 360, 210));
    Check(Probe.ShowCount = 1, 'filtering repositions without reopening');
    Popup.ClosePopup;
    Check(not Popup.Visible and not Popup.PopupVisible and (Probe.HideCount = 1), 'popup close state and hide event');
    Probe.CloseOnShow := True; Popup.ShowPopup(Editor, Rect(50, 50, 350, 200));
    Check(not Popup.Visible and not Popup.PopupVisible, 'reentrant close during show is deferred safely');
    Check((Probe.ShowCount = 2) and (Probe.HideCount = 2), 'reentrant close preserves show and hide events');
    Popup.OnShow := nil; Popup.OnHide := nil;
  finally Host.Free; Probe.Free; end;
end;

begin
  try
    Application.Initialize;
    PieceTableReferenceChecks; PieceTableChecks; AppendBufferChecks; DocumentChecks; EditingChecks; TextGeometryAndDropChecks; UnicodeEditingChecks; DeletionChecks; LanguageChecks; SemanticChecks; BreakpointChecks; AnalysisChecks; FileChecks; RendererChecks; PopupChecks;
    RunCodeStructureChecks; ZoomChecks; MouseInteractionChecks;
    Writeln('CodeEditor checks passed');
  except on E: Exception do begin Writeln(E.ClassName + ': ' + E.Message); ExitCode := 1; end; end;
end.

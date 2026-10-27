{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Demo.CodeBasic;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.IOUtils,
  System.DateUtils,
  System.Variants,
  System.TypInfo,
  System.Math,
  System.Classes,
  System.Rtti,
  System.Generics.Collections,
  System.Types,
  Vcl.Forms,
  Vcl.ActnList,
  Vcl.Dialogs,
  Vcl.Clipbrd,
  Vcl.ExtCtrls,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Graphics,
  Vcl.ComCtrls,
  Vcl.Menus,
  Vcl.ImgList,
  Vcl.Imaging.jpeg,
  System.UITypes,
  System.Actions,
  NimbusForms.Controls.Types,
  NimbusForms.Controls.ToolButton,
  NimbusForms.Controls.ToolBar,
  NimbusForms.Controls.MenuBar,
  NimbusForms.Controls.IdeStatusBar,
  NimbusForms.Controls.Panel,
  NimbusForms.Controls.CheckBox,
  NimbusForms.Controls.ThemedLabel,
  NimbusForms.Controls.ComboBox,
  NimbusForms.Controls.TextBox,
  NimbusForms.Controls.CodeEditor.Types,
  NimbusForms.Controls.CodeEditor.Document,
  NimbusForms.Controls.CodeEditor.Syntax,
  NimbusForms.Controls.CodeEditor.Breakpoints,
  NimbusForms.Controls.CodeEditor.Services,
  NimbusForms.Rendering.CodeEditor.DLL,
  NimbusForms.Controls.CodeEditor,
  NimbusForms.Controls.CodeEditor.Actions,
  NimbusForms.Controls.TabControl,
  NimbusForms.Menus.PopupMenu,
  NimbusForms.Demo.Strings,
  NimbusForms.Demo.Host;

type
  TCodeEditorDemoDiagnostics = class(TInterfacedObject, ICodeDiagnosticProvider)
  public
    function GetDiagnostics(const Source: ICodeVirtualTextSource): TArray<TCodeDiagnostic>;
  end;

  TCodeEditorDemo = class(TThemedPanel)
  private
    FEditor: TThemedCodeEditor;
    FStatus: TThemedIdeStatusBar;
    FEvent: TThemedLabel;
    FSearch, FReplace: TThemedTextBox;
    FLanguage, FEncoding: TThemedComboBox;
    FActions: TActionList;
    FOpen: TOpenDialog;
    FSave: TSaveDialog;
    FBuilding: Boolean;
    FSearchCase, FSearchRegex, FSearchWord: Boolean;
    FWhitespaceBoxes: array[0..3] of TThemedCheckBox;
    FSyncWhitespace: Boolean;
    procedure Build;
    procedure Command(Sender: TObject);
    procedure Changed(Sender: TObject);
    procedure LanguageChanged(Sender: TObject);
    procedure EncodingChanged(Sender: TObject);
    procedure SearchChanged(Sender: TObject);
    procedure EditorKey(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Error(Sender: TObject; const MessageText: string);
    procedure Completion(Sender: TObject; const Position: TCodeDocumentPosition; var Items: TArray<TCodeCompletionItem>);
    procedure Navigate(Sender: TObject; const Word: TCodeEditorWordHitInfo; var Result: TCodeEditorNavigationResult; var Handled: Boolean);
    procedure QuickInfo(Sender: TObject; const Word: TCodeEditorWordHitInfo; var Info: TCodeEditorQuickInfo; var Handled: Boolean);
    procedure Sample(const Delphi: Boolean);
    procedure SampleCurrentLanguage;
    procedure MarkerExamples;
    procedure WhitespaceChanged(Sender: TObject);
    procedure BreakpointChanged(Sender: TObject; const Breakpoint: TCodeBreakpoint; const Change: TCodeBreakpointChange);
    function SearchOptions: TCodeSearchOptions;
  protected
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
    property Editor: TThemedCodeEditor read FEditor;
  end;



  TCodeBasicForm = class(TDemoHostForm)
  private
    FDemo: TCodeEditorDemo;
    procedure HandleCloseQuery(Sender: TObject; var CanClose: Boolean);
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
  end;

implementation

resourcestring
  SCodeBasicCloseTitle = 'Unsaved document';
  SCodeBasicCloseText = 'Save changes before closing?';

function TCodeEditorDemoDiagnostics.GetDiagnostics(const Source: ICodeVirtualTextSource): TArray<TCodeDiagnostic>;
var I, P: Integer; Text: string; D: TCodeDiagnostic; Items: TList<TCodeDiagnostic>;
begin
  Items := TList<TCodeDiagnostic>.Create;
  try
    for I := 0 to Source.LineCount - 1 do
    begin
      Text := Source.GetLineText(I); P := Pos('TODO', Text);
      D := Default(TCodeDiagnostic); D.Severity := cdsWarning; D.Code := 'DEMO001'; D.MessageText := 'Demo task marker';
      if P = 0 then
      begin P := Pos('ERROR', Text); D.Severity := cdsError; D.Code := 'DEMO002'; D.MessageText := 'Demo error marker'; end;
      if P = 0 then
      begin P := Pos('INFO', Text); D.Severity := cdsInfo; D.Code := 'DEMO003'; D.MessageText := 'Demo informational marker'; end;
      if P = 0 then Continue;
      D.Source := 'Demo marker provider';
      D.Range := TCodeDocumentRange.Create(TCodeDocumentPosition.Create(I, P - 1), TCodeDocumentPosition.Create(I, P + 3));
      Items.Add(D);
    end;
    Result := Items.ToArray;
  finally Items.Free; end;
end;

constructor TCodeEditorDemo.Create(AOwner: TComponent);
begin inherited; Align := alClient; end;

procedure TCodeEditorDemo.SetParent(AParent: TWinControl);
begin
  inherited;
  if (AParent = nil) or (FEditor <> nil) or FBuilding or (csDestroying in ComponentState) then Exit;
  FBuilding := True; try Build; finally FBuilding := False; end; Changed(Self);
end;

procedure TCodeEditorDemo.Build;
const WhitespaceNames: array[0..3] of string = ('Spaces', 'Tabs', 'CRLF / LF / CR', 'Trailing spaces');
var Menu: TThemedMenuBar; Tools: TThemedToolBar; SearchBar: TThemedPanel; Popup: TThemedPopupMenu;
  NativeActions: TArray<TCodeEditorAction>; Action: TAction; Item: TMenuItem;
  Language: ICodeLanguageDefinition; I: Integer;
  function MenuGroup(const ACaption: string): TThemedPopupMenu;
  begin
    Result := TThemedPopupMenu.Create(Self);
    Menu.LeftItems.Add.Caption := ACaption;
    Menu.LeftItems[Menu.LeftItems.Count - 1].DropDownMenu := Result;
  end;
  procedure MenuAction(const AAction: TAction);
  begin Item := TMenuItem.Create(Popup); Item.Action := AAction; Popup.Items.Add(Item); end;
  function DemoAction(const Caption: string; const Tag: Integer): TAction;
  begin
    Result := TAction.Create(FActions); Result.ActionList := FActions;
    Result.Caption := Caption; Result.Tag := Tag; Result.OnExecute := Command; MenuAction(Result);
  end;
  procedure Tool(const AAction: TAction);
  var Button: TThemedToolButton;
  begin Button := TThemedToolButton.Create(Tools); Button.Parent := Tools; Button.AutoSize := True; Button.Action := AAction; end;
begin
  FStatus := TThemedIdeStatusBar.Create(Self); FStatus.Parent := Self; FStatus.Align := alBottom;
  for I := 0 to 5 do FStatus.LeftItems.Add;
  FEvent := TThemedLabel.Create(Self); FEvent.Parent := Self; FEvent.Align := alBottom;
  FEvent.AutoSize := False; FEvent.Height := 24;
  FEvent.Caption := 'Double-click words | Drag selected text to move; Ctrl+drag to copy | Alt+drag column selection';
  Menu := TThemedMenuBar.Create(Self); Menu.Parent := Self; Menu.Align := alTop; Menu.Height := 28;
  Tools := TThemedToolBar.Create(Self); Tools.Parent := Self; Tools.Align := alTop; Tools.Top := 28;
  Tools.StyleMode := stCompact; Tools.ShowOverflow := True; Tools.AutoSize := True;
  SearchBar := TThemedPanel.Create(Self); SearchBar.Parent := Self; SearchBar.Align := alTop; SearchBar.Top := 64; SearchBar.Height := 100;
  FSearch := TThemedTextBox.Create(Self); FSearch.Parent := SearchBar; FSearch.SetBounds(8, 4, 200, 28);
  FSearch.StyleMode := stCompact; FSearch.PlaceholderText := 'Find text or regular expression'; FSearch.OnChange := SearchChanged; FSearch.OnKeyDown := EditorKey;
  FReplace := TThemedTextBox.Create(Self); FReplace.Parent := SearchBar; FReplace.SetBounds(216, 4, 200, 28);
  FReplace.StyleMode := stCompact; FReplace.PlaceholderText := 'Replacement';
  FLanguage := TThemedComboBox.Create(Self); FLanguage.Parent := SearchBar; FLanguage.SetBounds(8, 36, 200, 28);
  FLanguage.Style := csDropDownList; FLanguage.OnChange := LanguageChanged;
  FEncoding := TThemedComboBox.Create(Self); FEncoding.Parent := SearchBar; FEncoding.SetBounds(216, 36, 200, 28);
  FEncoding.Style := csDropDownList;
  FEncoding.Items.Text := 'Auto'#13#10'UTF-8'#13#10'UTF-16 LE'#13#10'UTF-16 BE'#13#10'ANSI'#13#10'ASCII'#13#10'UTF-32 LE'#13#10'UTF-32 BE'#13#10'Latin-1'#13#10'Windows-1252';
  FEncoding.ItemIndex := 1; FEncoding.OnChange := EncodingChanged;
  FEditor := TThemedCodeEditor.Create(Self); FEditor.Parent := Self; FEditor.Align := alClient;
  FEditor.Options.InvisibleCharacters := [cicSpaces, cicTabs, cicEndOfLine, cicTrailingSpaces];
  for I := 0 to 3 do
  begin
    FWhitespaceBoxes[I] := TThemedCheckBox.Create(Self); FWhitespaceBoxes[I].Parent := SearchBar;
    FWhitespaceBoxes[I].SetBounds(8 + I * 152, 70, 146, 24); FWhitespaceBoxes[I].StyleMode := stCompact;
    FWhitespaceBoxes[I].Caption := WhitespaceNames[I]; FWhitespaceBoxes[I].Tag := 30 + I;
    FWhitespaceBoxes[I].Checked := True; FWhitespaceBoxes[I].OnCheckedChanged := WhitespaceChanged;
  end;
  FEditor.Font.Name := 'Consolas'; FEditor.Font.Size := 11;
  FEditor.OnChange := Changed; FEditor.OnSelectionChanged := Changed; FEditor.OnStatusChanged := Changed;
  FEditor.OnAnalysisCompleted := Changed; FEditor.OnError := Error; FEditor.OnKeyDown := EditorKey;
  FEditor.OnCompletionRequested := Completion; FEditor.OnNavigateToDefinitionRequested := Navigate;
  FEditor.OnQuickInfoRequested := QuickInfo; FEditor.DiagnosticProviders.Add(TCodeEditorDemoDiagnostics.Create);
  FEditor.OnBreakpointChanged := BreakpointChanged;
  for Language in FEditor.LanguageRegistry.Languages do FLanguage.Items.Add(Language.DisplayName);
  FOpen := TOpenDialog.Create(Self); FOpen.Filter := 'Source files|*.cs;*.pas;*.dpr;*.vb;*.ps1;*.cpp;*.h;*.java;*.pl;*.au3|All files|*.*';
  FSave := TSaveDialog.Create(Self); FSave.Filter := 'Source files|*.cs;*.pas;*.txt|All files|*.*'; FSave.Options := FSave.Options + [ofOverwritePrompt];
  FActions := TActionList.Create(Self); NativeActions := AttachCodeEditorActions(FActions, FEditor);
  Popup := MenuGroup('File'); Tool(DemoAction('New', 0)); Tool(DemoAction('Open', 1)); Tool(DemoAction('Save', 2));
  DemoAction('C# sample', 5); DemoAction('Delphi sample', 6); DemoAction('Sample for selected language', 22); DemoAction('Load language definition', 15); DemoAction('Toggle BOM', 18);
  Popup := MenuGroup('Edit');
  for I := Ord(cecUndo) to Ord(cecSelectAll) do MenuAction(NativeActions[I]);
  Tool(NativeActions[Ord(cecUndo)]); Tool(NativeActions[Ord(cecRedo)]); Tool(NativeActions[Ord(cecToggleBookmark)]);
  DemoAction('Trim trailing whitespace', 11);
  Popup := MenuGroup('Search'); Tool(DemoAction('Find', 12)); Tool(DemoAction('Replace', 13)); DemoAction('Replace all', 14);
  DemoAction('Match case', 19); DemoAction('Whole word', 20); DemoAction('Regular expression', 21);
  MenuAction(NativeActions[Ord(cecNextMatch)]); MenuAction(NativeActions[Ord(cecPreviousMatch)]);
  Action := DemoAction(SCodeEditorGoToLine, 40); Action.ShortCut := Vcl.Menus.ShortCut(Ord('G'), [ssCtrl]);
  Popup := MenuGroup('View'); DemoAction(SCodeEditorFont, 39);
  for I := Ord(cecZoomIn) to Ord(cecToggleIndentGuides) do MenuAction(NativeActions[I]);
  Tool(NativeActions[Ord(cecZoomOut)]); Tool(NativeActions[Ord(cecZoomIn)]); Tool(NativeActions[Ord(cecResetZoom)]);
  DemoAction('Read only', 7); DemoAction('All invisible characters', 9);
  DemoAction('Spaces', 30); DemoAction('Tabs', 31); DemoAction('Line endings (CRLF / LF / CR)', 32);
  DemoAction('Trailing whitespace', 33); DemoAction('Breakpoint gutter', 36); DemoAction('Bookmark gutter', 37);
  DemoAction('Overview markers', 10); DemoAction('Scope guides', 16);
  for I := Ord(cecTriggerCompletion) to Ord(cecGoToDefinition) do MenuAction(NativeActions[I]);
  Popup := MenuGroup('Debug'); MenuAction(NativeActions[Ord(cecToggleBreakpoint)]); Tool(NativeActions[Ord(cecToggleBreakpoint)]);
  DemoAction('Enable / disable current breakpoint', 23); DemoAction('Clear breakpoints', 24);
  DemoAction('Show demo execution line', 25); DemoAction('Advance demo execution line', 26); DemoAction('Clear execution line', 27);
  DemoAction('Conditional breakpoint example', 28); DemoAction('Logpoint example', 29);
  DemoAction('Hit-count breakpoint example', 35); DemoAction('Restore marker examples', 34);
  Popup := MenuGroup('Renderer'); Action := DemoAction('Load renderer DLL (Skia / custom)', 3); Tool(Action); DemoAction('Nimbus GDI+', 4);
  DemoAction('Unicode / color emoji sample', 38);
  Sample(False);
end;

procedure TCodeEditorDemo.Sample(const Delphi: Boolean);
begin
  if Delphi then
  begin
    FEditor.SetLanguage('delphi'); FEditor.Text := 'unit Sample;'#13#10#13#10'interface'#13#10#13#10'type'#13#10'  TService = class'#13#10'  public'#13#10'    procedure Run;'#13#10'  end;'#13#10#13#10'implementation'#13#10#13#10'procedure TService.Run;'#13#10'var I: Integer;'#13#10'begin'#13#10'  // TODO: connect the service'#13#10'  for I := 1 to 10 do'#13#10'  begin'#13#10'    WriteLn(''Message '', I);'#13#10'  end;'#13#10'end;'#13#10#13#10'end.'#13#10;
  end
  else
  begin
    FEditor.SetLanguage('csharp'); FEditor.Text := 'using System;'#13#10#13#10'namespace Nimbus.Demo'#13#10'{'#13#10'    /// <summary>Interactive editor sample</summary>'#13#10'    public class Service'#13#10'    {'#13#10'        public string Name { get; set; } = "Nimbus";'#13#10#13#10'        public void Run(int count)'#13#10'        {'#13#10'            // TODO: connect the service'#13#10'            for (int i = 0; i < count; i++)'#13#10'            {'#13#10'                Console.WriteLine($"Message {i}: {Name}");'#13#10'            }'#13#10'            // ERROR: demonstration diagnostic, not a compiler result'#13#10'        }'#13#10'    }'#13#10'}'#13#10;
  end;
  FEditor.Text := FEditor.Text.Replace(#10, #13#10) + #9'// Tab and trailing spaces sample' + '  '#10'// CRLF sample'#13#10;
  FLanguage.ItemIndex := Ord(Delphi); MarkerExamples; FEditor.GoToLine(0); Changed(Self);
end;

procedure TCodeEditorDemo.MarkerExamples;
var Breakpoint: TCodeBreakpoint; Bookmark: TCodeBookmark;
begin
  if FEditor.Document.LineCount < 9 then
  begin FEvent.Caption := 'Marker examples need at least nine lines'; Exit; end;
  FEditor.Breakpoints.Clear; FEditor.Bookmarks.Clear;
  Breakpoint := Default(TCodeBreakpoint); Breakpoint.Enabled := True;
  Breakpoint.LineIndex := 0; FEditor.Breakpoints.Put(Breakpoint);
  Breakpoint.LineIndex := 2; Breakpoint.Condition := 'count >= 5'; FEditor.Breakpoints.Put(Breakpoint);
  Breakpoint.LineIndex := 4; Breakpoint.Condition := ''; Breakpoint.HitCount := 3; FEditor.Breakpoints.Put(Breakpoint);
  Breakpoint.LineIndex := 6; Breakpoint.HitCount := 0; Breakpoint.LogMessage := 'Message {count}'; FEditor.Breakpoints.Put(Breakpoint);
  Breakpoint.LineIndex := 8; Breakpoint.LogMessage := ''; Breakpoint.Enabled := False; FEditor.Breakpoints.Put(Breakpoint);
  Bookmark := Default(TCodeBookmark); Bookmark.LineIndex := 1; Bookmark.Name := 'Sample entry'; FEditor.Bookmarks.Add(Bookmark);
  Bookmark.LineIndex := 3; Bookmark.Name := 'Sample declaration'; FEditor.Bookmarks.Add(Bookmark);
  FEvent.Caption := 'Markers: regular, conditional (+), hit count (+), logpoint (diamond), disabled; two bookmarks';
end;

procedure TCodeEditorDemo.SampleCurrentLanguage;
var Name: string;
begin
  Name := FEditor.LanguageName;
  if Name = 'csharp' then Sample(False)
  else if Name = 'delphi' then Sample(True)
  else if Name = 'vb' then FEditor.Text := 'Imports System'#13#10'Public Class Service'#13#10'    Private Name As String = "Nimbus"'#13#10'    Public Sub Run(ByVal count As Integer)'#13#10'        '' INFO: demonstration message'#13#10'        For i As Integer = 0 To count'#13#10'            Console.WriteLine(Name)'#13#10'        Next'#13#10'    End Sub'#13#10'End Class'#13#10
  else if Name = 'rust' then FEditor.Text := 'use std::collections::HashMap;'#13#10'pub struct Service { name: String }'#13#10'impl Service {'#13#10'    pub fn run(&self, count: usize) {'#13#10'        const LIMIT: usize = 10;'#13#10'        // INFO: demonstration message'#13#10'        for i in 0..count {'#13#10'            println!("Message {}", i);'#13#10'        }'#13#10'    }'#13#10'}'#13#10
  else if Name = 'javascript' then FEditor.Text := 'import { readFile } from "node:fs/promises";'#13#10'/** <summary>JavaScript sample</summary> */'#13#10'class Service {'#13#10'    async run(count) {'#13#10'        const limit = 10;'#13#10'        // INFO: demonstration message'#13#10'        for (let i = 0; i < count; i++) {'#13#10'            console.log(`Message ${i}`);'#13#10'        }'#13#10'    }'#13#10'}'#13#10
  else if Name = 'powershell' then FEditor.Text := 'using namespace System'#13#10'function Invoke-Service {'#13#10'    param([int]$Count = 10)'#13#10'    # INFO: demonstration message'#13#10'    foreach ($item in 1..$Count) {'#13#10'        Write-Host "Message $item"'#13#10'    }'#13#10'}'#13#10'Invoke-Service -Count 5'#13#10
  else if Name = 'batch' then FEditor.Text := '@echo off'#13#10'setlocal enabledelayedexpansion'#13#10'set "NAME=Nimbus"'#13#10'rem INFO: demonstration message'#13#10'for /L %%i in (1,1,10) do ('#13#10'    echo Message %%i from %NAME%'#13#10')'#13#10':done'#13#10'endlocal'#13#10
  else if Name = 'markdown' then FEditor.Text := '# Nimbus editor'#13#10#13#10'An **interactive** editor with *syntax colors* and `inline code`.'#13#10#13#10'[Project documentation](https://example.com/docs)'#13#10#13#10'```delphi'#13#10'OptionsDialog: TForm;'#13#10'```'#13#10#13#10'- INFO: demonstration message'#13#10;
  FEditor.GoToLine(0); Changed(Self);
end;

procedure TCodeEditorDemo.BreakpointChanged(Sender: TObject; const Breakpoint: TCodeBreakpoint; const Change: TCodeBreakpointChange);
const Names: array[TCodeBreakpointChange] of string = ('added', 'changed', 'removed', 'reset');
begin
  FEvent.Caption := Format('Breakpoint %s: line %d, enabled=%s, condition="%s", hits=%d; %d total',
    [Names[Change], Breakpoint.LineIndex + 1, BoolToStr(Breakpoint.Enabled, True), Breakpoint.Condition, Breakpoint.HitCount, Length(FEditor.Breakpoints.Items)]);
end;

function TCodeEditorDemo.SearchOptions: TCodeSearchOptions;
begin
  Result := TCodeSearchOptions.Create(FSearch.Text); Result.MatchCase := FSearchCase;
  Result.WholeWord := FSearchWord; Result.UseRegex := FSearchRegex;
end;

procedure TCodeEditorDemo.Command(Sender: TObject);
var Dialog: TOpenDialog; FontDialog: TFontDialog; Count, Line: Integer; LineText: string; Breakpoint: TCodeBreakpoint;
begin
  try
    case TComponent(Sender).Tag of
      0: FEditor.Text := '';
      1: if FOpen.Execute then
        begin FEditor.LoadFromFile(FOpen.FileName, TCodeTextEncoding(FEncoding.ItemIndex)); FEncoding.ItemIndex := Ord(FEditor.Document.Encoding); end;
      2: begin FSave.FileName := FEditor.Document.FileName; if FSave.Execute then FEditor.SaveToFile(FSave.FileName); end;
      3, 15:
        begin
          Dialog := TOpenDialog.Create(Self);
          try
            if TComponent(Sender).Tag = 3 then Dialog.Filter := 'Nimbus renderer bridge|*.dll' else Dialog.Filter := 'Language definition|*.nclang';
            if Dialog.Execute then
              if TComponent(Sender).Tag = 3 then
              begin FEditor.RenderBackend := TCodeEditorDLLBackend.Create(Dialog.FileName); FEvent.Caption := 'Renderer bridge loaded: ' + ExtractFileName(Dialog.FileName); end
              else if FEditor.RegisterLanguageDefinitionFile(Dialog.FileName) then
              begin
                FLanguage.Items.Add(FEditor.LanguageRegistry.Languages.Last.DisplayName);
                FLanguage.ItemIndex := FLanguage.Items.Count - 1; LanguageChanged(Self);
              end;
          finally Dialog.Free; end;
        end;
      4: begin FEditor.TextRenderBackend := crbClassicGdi; FEvent.Caption := 'Nimbus GDI+ renderer selected'; end;
      5: Sample(False);
      6: Sample(True);
      7: FEditor.ReadOnly := not FEditor.ReadOnly;
      8: FEditor.Options.WordWrap := not FEditor.Options.WordWrap;
      9: if FEditor.Options.InvisibleCharacters = [cicSpaces, cicTabs, cicEndOfLine, cicTrailingSpaces] then FEditor.Options.InvisibleCharacters := []
        else FEditor.Options.InvisibleCharacters := [cicSpaces, cicTabs, cicEndOfLine, cicTrailingSpaces];
      10: FEditor.Options.ShowOverviewRuler := not FEditor.Options.ShowOverviewRuler;
      11: FEditor.TrimTrailingWhitespace;
      12: begin SearchChanged(Self); FEditor.FindNext; end;
      13: FEditor.ReplaceSelection(FReplace.Text);
      14: begin Count := FEditor.ReplaceAll(SearchOptions, FReplace.Text); FEvent.Caption := Format('Replaced %d matches', [Count]); end;
      16: FEditor.Options.ShowScopeGuides := not FEditor.Options.ShowScopeGuides;
      18: FEditor.Document.HasByteOrderMark := not FEditor.Document.HasByteOrderMark;
      19: begin FSearchCase := not FSearchCase; SearchChanged(Self); end;
      20: begin FSearchWord := not FSearchWord; SearchChanged(Self); end;
      21: begin FSearchRegex := not FSearchRegex; SearchChanged(Self); end;
      22: SampleCurrentLanguage;
      23: if FEditor.Breakpoints.TryGet(FEditor.Caret.Position.LineIndex, Breakpoint) then FEditor.Breakpoints.SetEnabled(Breakpoint.LineIndex, not Breakpoint.Enabled);
      24: FEditor.Breakpoints.Clear;
      25: begin FEditor.ExecutionLine := FEditor.Caret.Position.LineIndex; FEvent.Caption := 'Demo execution marker set; connect a debugger through the editor API'; end;
      26: begin FEditor.ExecutionLine := FEditor.ExecutionLine + 1; FEditor.GoToLine(FEditor.ExecutionLine); FEvent.Caption := 'Demo execution marker advanced'; end;
      27: FEditor.ExecutionLine := -1;
      28:
        begin
          Breakpoint := Default(TCodeBreakpoint); Breakpoint.LineIndex := FEditor.Caret.Position.LineIndex;
          Breakpoint.Enabled := True; Breakpoint.Condition := 'count >= 5';
          FEditor.Breakpoints.Put(Breakpoint);
        end;
      29:
        begin
          Breakpoint := Default(TCodeBreakpoint); Breakpoint.LineIndex := FEditor.Caret.Position.LineIndex;
          Breakpoint.Enabled := True; Breakpoint.LogMessage := 'Message {count}'; FEditor.Breakpoints.Put(Breakpoint);
        end;
      30: FEditor.Options.ShowSpaces := not FEditor.Options.ShowSpaces;
      31: FEditor.Options.ShowTabs := not FEditor.Options.ShowTabs;
      32: FEditor.Options.ShowEndOfLine := not FEditor.Options.ShowEndOfLine;
      33: FEditor.Options.ShowTrailingSpaces := not FEditor.Options.ShowTrailingSpaces;
      34: MarkerExamples;
      35:
        begin
          Breakpoint := Default(TCodeBreakpoint); Breakpoint.LineIndex := FEditor.Caret.Position.LineIndex;
          Breakpoint.Enabled := True; Breakpoint.HitCount := 3; FEditor.Breakpoints.Put(Breakpoint);
        end;
      36: FEditor.Options.ShowBreakpoints := not FEditor.Options.ShowBreakpoints;
      37: FEditor.Options.ShowBookmarks := not FEditor.Options.ShowBookmarks;
      38:
        begin
          FEditor.SetLanguage('csharp');
          FEditor.Text := '// Unicode renderer sample'#13#10 +
            'string text = "Latin: ' + Char($00E4) + Char($00F6) + Char($00FC) + ' Greek: ' + Char($03A9) +
            ' CJK: ' + Char($4E2D) + Char($6587) + '";'#13#10 +
            'string emoji = "' + Char($D83D) + Char($DE00) + ' ' + Char($D83C) + Char($DF08) + ' ' +
            Char($D83D) + Char($DC69) + Char($200D) + Char($D83D) + Char($DCBB) + '";'#13#10;
          FEvent.Caption := 'The selected renderer draws this sample; load the Skia DLL for colored emoji';
        end;
      39:
        begin
          FontDialog := TFontDialog.Create(Self);
          try
            FontDialog.Font.Assign(FEditor.Font); FontDialog.Options := FontDialog.Options + [fdFixedPitchOnly];
            if FontDialog.Execute then FEditor.Font.Assign(FontDialog.Font);
          finally FontDialog.Free; end;
        end;
      40:
        begin
          LineText := IntToStr(FEditor.Caret.Position.LineIndex + 1);
          if DemoInputQuery(SCodeEditorGoToLine, Format(SCodeEditorLinePrompt, [FEditor.Document.LineCount]), LineText) then
          begin
            if not TryStrToInt(Trim(LineText), Line) or (Line < 1) or (Line > FEditor.Document.LineCount) then
              raise EConvertError.CreateFmt(SCodeEditorLineRange, [FEditor.Document.LineCount]);
            FEditor.GoToLine(Line - 1); if FEditor.CanFocus then FEditor.SetFocus;
          end;
        end;
    end;
    Changed(Self);
  except on E: Exception do Error(Self, E.Message); end;
end;

procedure TCodeEditorDemo.Changed(Sender: TObject);
var Info: TCodeEditorStatusInfo; I: Integer; Action: TAction;
begin
  if FBuilding or (FEditor = nil) or (FStatus = nil) or (csDestroying in ComponentState) then Exit;
  Info := FEditor.GetStatusInfo;
  FStatus.LeftItems[0].Text := Format('Ln %d, Col %d', [Info.Line, Info.Column]);
  FStatus.LeftItems[1].Text := Info.LanguageName;
  FStatus.LeftItems[2].Text := Info.EncodingName + ' BOM=' + BoolToStr(Info.HasByteOrderMark, True);
  FStatus.LeftItems[3].Text := Format('%d lines, %d matches, %d diagnostics, %d pieces', [Info.LineCount, Length(FEditor.SearchMatches), Length(FEditor.Diagnostics), FEditor.Document.StoragePieceCount]);
  FStatus.LeftItems[4].Text := 'Modified=' + BoolToStr(Info.IsModified, True) + ' Read only=' + BoolToStr(Info.IsReadOnly, True);
  FStatus.LeftItems[5].Text := Format(SCodeEditorZoomStatus, [FEditor.Zoom, FEditor.Font.Name, FEditor.Font.Size]);
  for I := 0 to FActions.ActionCount - 1 do
  begin
    Action := TAction(FActions.Actions[I]);
    case Action.Tag of
      7: Action.Checked := FEditor.ReadOnly;
      8: Action.Checked := FEditor.Options.WordWrap;
      9: Action.Checked := FEditor.Options.InvisibleCharacters = [cicSpaces, cicTabs, cicEndOfLine, cicTrailingSpaces];
      10: Action.Checked := FEditor.Options.ShowOverviewRuler;
      16: Action.Checked := FEditor.Options.ShowScopeGuides;
      30: Action.Checked := FEditor.Options.ShowSpaces;
      31: Action.Checked := FEditor.Options.ShowTabs;
      32: Action.Checked := FEditor.Options.ShowEndOfLine;
      33: Action.Checked := FEditor.Options.ShowTrailingSpaces;
      36: Action.Checked := FEditor.Options.ShowBreakpoints;
      37: Action.Checked := FEditor.Options.ShowBookmarks;
    end;
  end;
  FSyncWhitespace := True;
  try
    FWhitespaceBoxes[0].Checked := FEditor.Options.ShowSpaces; FWhitespaceBoxes[1].Checked := FEditor.Options.ShowTabs;
    FWhitespaceBoxes[2].Checked := FEditor.Options.ShowEndOfLine; FWhitespaceBoxes[3].Checked := FEditor.Options.ShowTrailingSpaces;
  finally FSyncWhitespace := False; end;
end;
procedure TCodeEditorDemo.WhitespaceChanged(Sender: TObject);
var Box: TThemedCheckBox;
begin
  if FBuilding or FSyncWhitespace or (FEditor = nil) then Exit; Box := TThemedCheckBox(Sender);
  case Box.Tag of
    30: FEditor.Options.ShowSpaces := Box.Checked;
    31: FEditor.Options.ShowTabs := Box.Checked;
    32: FEditor.Options.ShowEndOfLine := Box.Checked;
    33: FEditor.Options.ShowTrailingSpaces := Box.Checked;
  end;
  Changed(Self);
end;

procedure TCodeEditorDemo.LanguageChanged(Sender: TObject);
begin
  if FBuilding or (FLanguage.ItemIndex < 0) then Exit;
  FEditor.SetLanguage(FEditor.LanguageRegistry.Languages[FLanguage.ItemIndex].Name); Changed(Self);
end;

procedure TCodeEditorDemo.EncodingChanged(Sender: TObject);
begin
  if FBuilding or (FEncoding.ItemIndex <= 0) then Exit;
  FEditor.Document.Encoding := TCodeTextEncoding(FEncoding.ItemIndex); Changed(Self);
end;

procedure TCodeEditorDemo.SearchChanged(Sender: TObject);
begin
  if FBuilding or (FEditor = nil) then Exit;
  try
    if FSearch.Text = '' then FEditor.ClearSearchMatches else FEditor.SetSearchMatches(FEditor.FindAll(SearchOptions));
    FEvent.Caption := Format('Search: %d matches; case=%s word=%s regex=%s', [Length(FEditor.SearchMatches), BoolToStr(FSearchCase, True), BoolToStr(FSearchWord, True), BoolToStr(FSearchRegex, True)]);
  except on E: Exception do Error(Self, E.Message); end;
  Changed(Self);
end;

procedure TCodeEditorDemo.EditorKey(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = Ord('F')) and (ssCtrl in Shift) then begin FSearch.SetFocus; Key := 0; end
  else if (Sender = FSearch) and (Key = VK_RETURN) then begin SearchChanged(Self); FEditor.FindNext(not (ssShift in Shift)); Key := 0; end;
end;

procedure TCodeEditorDemo.Error(Sender: TObject; const MessageText: string);
begin FEvent.Caption := 'Editor error: ' + MessageText; end;

procedure TCodeEditorDemo.Completion(Sender: TObject; const Position: TCodeDocumentPosition; var Items: TArray<TCodeCompletionItem>);
var Item: TCodeCompletionItem;
begin
  Item := Default(TCodeCompletionItem); Item.DisplayText := 'Log message'; Item.FilterText := 'log';
  Item.InsertText := 'Console.WriteLine("Message");'; if FEditor.LanguageName = 'delphi' then Item.InsertText := 'WriteLn(''Message'');';
  Item.Description := 'Application supplied completion'; Item.Kind := cciSnippet; Item.Priority := 100;
  SetLength(Items, Length(Items) + 1); Items[High(Items)] := Item;
  FEvent.Caption := Format('Completion requested at line %d, column %d', [Position.LineIndex + 1, Position.ColumnIndex + 1]);
end;

procedure TCodeEditorDemo.Navigate(Sender: TObject; const Word: TCodeEditorWordHitInfo; var Result: TCodeEditorNavigationResult; var Handled: Boolean);
begin FEvent.Caption := 'Definition requested: ' + Word.Word; end;

procedure TCodeEditorDemo.QuickInfo(Sender: TObject; const Word: TCodeEditorWordHitInfo; var Info: TCodeEditorQuickInfo; var Handled: Boolean);
begin FEvent.Caption := 'Quick info requested: ' + Word.Word; end;

procedure AddCodeEditorDemo(const ATabs: TPageControl);
var Page: TTabSheet; Demo: TCodeEditorDemo;
begin
  Page := TTabSheet.Create(ATabs); Page.PageControl := ATabs; Page.Caption := 'Code Editor';
  Demo := TCodeEditorDemo.Create(Page); Demo.Parent := Page;
  if ATabs is TThemedTabControl then TThemedTabControl(ATabs).SetTabClosable(Page, False);
end;


constructor TCodeBasicForm.CreateNew(AOwner: TComponent; Dummy: Integer);
begin
  inherited; FDemo := TCodeEditorDemo.Create(Self); FDemo.Parent := Body; FDemo.Align := alClient;
  FDemo.Editor.Document.MarkSaved; OnCloseQuery := HandleCloseQuery;
end;
procedure TCodeBasicForm.HandleCloseQuery(Sender: TObject; var CanClose: Boolean);
var Dialog: TSaveDialog; Choice: TModalResult;
begin
  CanClose := True; if not FDemo.Editor.Document.IsModified then Exit;
  Choice := DemoQuestion(SCodeBasicCloseTitle, SCodeBasicCloseText);
  if Choice = mrCancel then begin CanClose := False; Exit; end;
  if Choice <> mrYes then Exit;
  Dialog := TSaveDialog.Create(Self);
  try
    Dialog.Options := Dialog.Options + [ofOverwritePrompt]; Dialog.FileName := FDemo.Editor.Document.FileName;
    CanClose := Dialog.Execute; if CanClose then FDemo.Editor.SaveToFile(Dialog.FileName);
  finally Dialog.Free; end;
end;

end.

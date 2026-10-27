{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Demo.CodeStudio;

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
  NimbusForms.Controls.LogViewer,
  NimbusForms.Controls.Button,
  NimbusForms.Controls.IdeStatusBar,
  NimbusForms.Controls.Splitter,
  NimbusForms.Controls.Panel,
  NimbusForms.Controls.TextBox,
  NimbusForms.Controls.CodeEditor.Types,
  NimbusForms.Controls.CodeEditor.Services,
  NimbusForms.Controls.TabControl,
  NimbusForms.Controls.TreeView,
  NimbusForms.Demo.Host,
  NimbusForms.Demo.CodeBasic;

type
  TStudioLocation = class
    DocumentIndex: Integer;
    Range: TCodeDocumentRange;
  end;
  TCodeStudioForm = class(TDemoHostForm)
  private
    FTabs, FBottomTabs: TThemedTabControl;
    FExplorer, FResults, FOutline: TThemedTreeView;
    FOutput: TThemedLogViewer;
    FSearch: TThemedTextBox;
    FDocuments: TList<TCodeEditorDemo>;
    FNames: TStringList;
    FLocations: TObjectList<TStudioLocation>;
    FOutlineRanges: TArray<TCodeDocumentRange>;
    FOutlineDocument: Integer;
    procedure AddDocument(const Name, Language, Text: string);
    procedure Command(Sender: TObject);
    procedure ExplorerClick(Sender: TObject; Node: TTreeNode; const Location: TPoint; Button: TMouseButton; Clicks: Integer);
    procedure ResultClick(Sender: TObject; Node: TTreeNode; const Location: TPoint; Button: TMouseButton; Clicks: Integer);
    procedure OutlineClick(Sender: TObject; Node: TTreeNode; const Location: TPoint; Button: TMouseButton; Clicks: Integer);
    procedure DocumentTabChanged(Sender: TObject);
    procedure RefreshOutline;
    procedure HandleCloseQuery(Sender: TObject; var CanClose: Boolean);
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
    destructor Destroy; override;
  end;

implementation

resourcestring
  SNew = 'New file';
  SFind = 'Find all';
  SOutline = 'Outline';
  SExplorer = 'Explorer';
  SOutput = 'Output';
  SResults = 'Search results';
  SSearch = 'Search all open documents';
  SProject = 'Demo workspace';
  SUntitled = 'Untitled%d.cs';
  SHit = '%s (%d,%d): %s';
  SFound = 'Information Search: %d matches in %d documents';
  SIndexed = 'Information Indexed %d symbols in %s';
  SSaveQuestion = 'Save changes to %s before closing?';
  SSaveTitle = 'Unsaved documents';
  SReady = 'Information Ready. Search, completion, folding, breakpoints, navigation and renderer selection are available in each document.';
  SMainSample = 'using System;'#13#10'class ApplicationDemo'#13#10'{'#13#10'    public void Run()'#13#10'    {'#13#10'        for (int index = 0; index < 10; index++)'#13#10'        {'#13#10'            Console.WriteLine(index);'#13#10'        }'#13#10'    }'#13#10'}';
  SDelphiSample = 'unit Demo.Service;'#13#10'interface'#13#10'type'#13#10'  TDemoService = class'#13#10'  public'#13#10'    procedure Run;'#13#10'  end;'#13#10'implementation'#13#10'procedure TDemoService.Run;'#13#10'begin'#13#10'end;'#13#10'end.';
  SReadme = '# NimbusForms workspace'#13#10#13#10'Search all open documents with the top search box.'#13#10'Use the document menus for editing, rendering and breakpoint features.';

constructor TCodeStudioForm.CreateNew(AOwner: TComponent; Dummy: Integer);
var Bar, Main: TThemedPanel; Splitter: TThemedSplitter; Tab: TTabSheet; Button: TThemedButton; I: Integer;
begin
  inherited;
  FDocuments := TList<TCodeEditorDemo>.Create; FNames := TStringList.Create;
  FLocations := TObjectList<TStudioLocation>.Create(True); FOutlineDocument := -1;
  Bar := TThemedPanel.Create(Self); Bar.Parent := Body; Bar.Align := alTop; Bar.Height := 48;
  FSearch := TThemedTextBox.Create(Self); FSearch.Parent := Bar; FSearch.SetBounds(10, 8, 280, 30); FSearch.PlaceholderText := SSearch;
  for I := 0 to 4 do
  begin
    Button := TThemedButton.Create(Self); Button.Parent := Bar; Button.SetBounds(302 + I * 106, 8, 100, 30); Button.Tag := I; Button.OnClick := Command;
    case I of 0: Button.Caption := SNew; 1: Button.Caption := SFind; 2: Button.Caption := SOutline; 3: Button.Caption := SExplorer; 4: Button.Caption := SOutput; end;
  end;
  Main := TThemedPanel.Create(Self); Main.Parent := Body; Main.Align := alClient; Main.DisableAlign;
  try
    FExplorer := TThemedTreeView.Create(Self); FExplorer.Parent := Main; FExplorer.Align := alLeft; FExplorer.Width := 200; FExplorer.Left := 0; FExplorer.OnNodeClickedEx := ExplorerClick;
    FExplorer.Items.Add(nil, SProject);
    Splitter := TThemedSplitter.Create(Self); Splitter.Parent := Main; Splitter.Left := 200; Splitter.ResizeControl := FExplorer;
    FBottomTabs := TThemedTabControl.Create(Self); FBottomTabs.Parent := Main; FBottomTabs.Align := alBottom; FBottomTabs.Height := 200; FBottomTabs.Top := 2000;
    Splitter := TThemedSplitter.Create(Self); Splitter.Parent := Main; Splitter.Align := alBottom; Splitter.Top := 1900; Splitter.ResizeControl := FBottomTabs;
    Tab := TTabSheet.Create(FBottomTabs); Tab.PageControl := FBottomTabs; Tab.Caption := SOutput;
    FOutput := TThemedLogViewer.Create(Self); FOutput.Parent := Tab; FOutput.Align := alClient;
    Tab := TTabSheet.Create(FBottomTabs); Tab.PageControl := FBottomTabs; Tab.Caption := SResults;
    FResults := TThemedTreeView.Create(Self); FResults.Parent := Tab; FResults.Align := alClient; FResults.OnNodeClickedEx := ResultClick;
    FOutline := TThemedTreeView.Create(Self); FOutline.Parent := Main; FOutline.Align := alRight; FOutline.Width := 210; FOutline.Left := 2000; FOutline.OnNodeClickedEx := OutlineClick;
    Splitter := TThemedSplitter.Create(Self); Splitter.Parent := Main; Splitter.Align := alRight; Splitter.Left := 1900; Splitter.ResizeControl := FOutline;
    FTabs := TThemedTabControl.Create(Self); FTabs.Parent := Main; FTabs.Align := alClient; FTabs.OnChange := DocumentTabChanged;
  finally Main.EnableAlign; end;
  AddDocument('Application.cs', 'csharp', SMainSample); AddDocument('Service.pas', 'delphi', SDelphiSample); AddDocument('README.md', 'markdown', SReadme);
  FTabs.ActivePageIndex := 0; RefreshOutline; FOutput.AppendLog(SReady); OnCloseQuery := HandleCloseQuery;
end;

destructor TCodeStudioForm.Destroy;
begin if FTabs <> nil then FTabs.OnChange := nil; FLocations.Free; FNames.Free; FDocuments.Free; inherited; end;

procedure TCodeStudioForm.AddDocument(const Name, Language, Text: string);
var Tab: TTabSheet; Demo: TCodeEditorDemo; Node: TTreeNode;
begin
  Tab := TTabSheet.Create(FTabs); Tab.PageControl := FTabs; Tab.Caption := Name;
  Demo := TCodeEditorDemo.Create(Tab); Demo.Parent := Tab; Demo.Align := alClient;
  Demo.Editor.SetLanguage(Language); Demo.Editor.Text := Text; Demo.Editor.Document.MarkSaved;
  FDocuments.Add(Demo); FNames.Add(Name);
  Node := FExplorer.Items.AddChild(FExplorer.Items.GetFirstNode, Name); Node.Data := Pointer(NativeInt(FDocuments.Count));
  FExplorer.Items.GetFirstNode.Expand(False);
end;

procedure TCodeStudioForm.Command(Sender: TObject);
var I: Integer; Match: TCodeSearchMatch; Hit: TStudioLocation; Node: TTreeNode;
begin
  case TComponent(Sender).Tag of
    0: begin AddDocument(Format(SUntitled, [FDocuments.Count + 1]), 'csharp', ''); FTabs.ActivePageIndex := FTabs.PageCount - 1; end;
    1:
      begin
        FResults.Items.Clear; FLocations.Clear;
        for I := 0 to FDocuments.Count - 1 do
          for Match in FDocuments[I].Editor.FindAll(FSearch.Text) do
          begin
            Hit := TStudioLocation.Create; Hit.DocumentIndex := I; Hit.Range := Match.Range; FLocations.Add(Hit);
            Node := FResults.Items.Add(nil, Format(SHit, [FNames[I], Match.Range.Start.LineIndex + 1, Match.Range.Start.ColumnIndex + 1, Match.Text])); Node.Data := Pointer(Hit);
          end;
        FBottomTabs.Visible := True; FBottomTabs.ActivePageIndex := 1;
        FOutput.AppendLog(Format(SFound, [FLocations.Count, FDocuments.Count]));
      end;
    2: RefreshOutline;
    3: FExplorer.Visible := not FExplorer.Visible;
    4: FBottomTabs.Visible := not FBottomTabs.Visible;
  end;
end;

procedure TCodeStudioForm.ExplorerClick(Sender: TObject; Node: TTreeNode; const Location: TPoint; Button: TMouseButton; Clicks: Integer);
var Index: NativeInt;
begin
  if Node = nil then Exit; Index := NativeInt(Node.Data) - 1;
  if (Index >= 0) and (Index < FDocuments.Count) then begin FTabs.ActivePageIndex := Index; RefreshOutline; end;
end;
procedure TCodeStudioForm.ResultClick(Sender: TObject; Node: TTreeNode; const Location: TPoint; Button: TMouseButton; Clicks: Integer);
var Hit: TStudioLocation;
begin
  if (Node = nil) or (Node.Data = nil) then Exit; Hit := TStudioLocation(Node.Data);
  FTabs.ActivePageIndex := Hit.DocumentIndex; FDocuments[Hit.DocumentIndex].Editor.GoToRange(Hit.Range);
  if FDocuments[Hit.DocumentIndex].Editor.CanFocus then FDocuments[Hit.DocumentIndex].Editor.SetFocus;
end;
procedure TCodeStudioForm.OutlineClick(Sender: TObject; Node: TTreeNode; const Location: TPoint; Button: TMouseButton; Clicks: Integer);
var Index: NativeInt;
begin
  if (Node = nil) or (FOutlineDocument < 0) then Exit; Index := NativeInt(Node.Data) - 1;
  if (Index >= 0) and (Index < Length(FOutlineRanges)) then begin FTabs.ActivePageIndex := FOutlineDocument; FDocuments[FOutlineDocument].Editor.GoToRange(FOutlineRanges[Index]); end;
end;
procedure TCodeStudioForm.DocumentTabChanged(Sender: TObject);
begin RefreshOutline; end;
procedure TCodeStudioForm.RefreshOutline;
var Demo: TCodeEditorDemo; I: Integer; Symbol: TCodeEditorSymbolInfo; Node: TTreeNode;
begin
  if (FTabs = nil) or (FTabs.ActivePageIndex < 0) or (FTabs.ActivePageIndex >= FDocuments.Count) then Exit;
  FOutlineDocument := FTabs.ActivePageIndex; Demo := FDocuments[FOutlineDocument]; Demo.Editor.RebuildSymbolIndex;
  FOutline.Items.Clear; SetLength(FOutlineRanges, Demo.Editor.SymbolIndex.Items.Count);
  for I := 0 to Demo.Editor.SymbolIndex.Items.Count - 1 do
  begin
    Symbol := Demo.Editor.SymbolIndex.Items[I]; FOutlineRanges[I] := Symbol.NameRange;
    Node := FOutline.Items.Add(nil, Symbol.Name); Node.Data := Pointer(NativeInt(I + 1));
  end;
  FOutput.AppendLog(Format(SIndexed, [Length(FOutlineRanges), FNames[FOutlineDocument]]));
end;

procedure TCodeStudioForm.HandleCloseQuery(Sender: TObject; var CanClose: Boolean);
var I: Integer; Dialog: TSaveDialog; Choice: TModalResult;
begin
  CanClose := False;
  for I := 0 to FDocuments.Count - 1 do
    if FDocuments[I].Editor.Document.IsModified then
    begin
      Choice := DemoQuestion(SSaveTitle, Format(SSaveQuestion, [FNames[I]]));
      if Choice = mrCancel then Exit;
      if Choice = mrYes then
      begin
        Dialog := TSaveDialog.Create(Self);
        try
          Dialog.Options := Dialog.Options + [ofOverwritePrompt]; Dialog.FileName := FDocuments[I].Editor.Document.FileName;
          if Dialog.FileName = '' then Dialog.FileName := FNames[I];
          if not Dialog.Execute then Exit; FDocuments[I].Editor.SaveToFile(Dialog.FileName);
        finally Dialog.Free; end;
      end;
    end;
  CanClose := True;
end;

end.

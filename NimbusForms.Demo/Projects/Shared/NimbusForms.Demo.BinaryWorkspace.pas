{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Demo.BinaryWorkspace;

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
  NimbusForms.Theming.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.Theming.Manager,
  NimbusForms.Controls.Button,
  NimbusForms.Controls.ToolButton,
  NimbusForms.Controls.ToolBar,
  NimbusForms.Controls.MenuBar,
  NimbusForms.Controls.IdeStatusBar,
  NimbusForms.Controls.Panel,
  NimbusForms.Controls.ThemedLabel,
  NimbusForms.Controls.ComboBox,
  NimbusForms.Controls.TextBox,
  NimbusForms.Menus.PopupMenu,
  NimbusForms.HexEditor.Types,
  NimbusForms.HexEditor.Strings,
  NimbusForms.HexEditor.DataSource,
  NimbusForms.HexEditor.FileDataSource,
  NimbusForms.HexEditor.Pieces,
  NimbusForms.HexEditor.Document,
  NimbusForms.HexEditor.Bookmarks,
  NimbusForms.HexEditor.Search,
  NimbusForms.HexEditor.SearchService,
  NimbusForms.HexEditor.Pattern,
  NimbusForms.HexEditor.PatternParser,
  NimbusForms.HexEditor.PatternSearch,
  NimbusForms.HexEditor.RuleEngine,
  NimbusForms.HexEditor.Inspector,
  NimbusForms.HexEditor.InspectorControl,
  NimbusForms.HexEditor.Tooltip,
  NimbusForms.HexEditor.BookmarkList,
  NimbusForms.HexEditor.Export,
  NimbusForms.HexEditor.Patch,
  NimbusForms.HexEditor.Undo,
  NimbusForms.HexEditor.Options,
  NimbusForms.HexEditor.Theme,
  NimbusForms.HexEditor.RenderSurface,
  NimbusForms.HexEditor.ScrollBar,
  NimbusForms.HexEditor.RenderContext,
  NimbusForms.HexEditor.Renderers,
  NimbusForms.HexEditor.Clipboard,
  NimbusForms.HexEditor.Encoding,
  NimbusForms.HexEditor.FindReplace,
  NimbusForms.HexEditor.SearchProviders,
  NimbusForms.HexEditor.Session,
  NimbusForms.HexEditor.Control,
  NimbusForms.Demo.Strings,
  NimbusForms.Demo.Host;

type
  THexDemoMarkerProvider = class(TInterfacedObject, IHexSearchProvider)
  public
    function GetName: string;
    function Search(const ASource: IHexDataSource; const AQuery: THexSearchQuery): TObjectList<THexSearchMatch>;
  end;

  TAdvancedHexDemo = class(TThemedPanel)
  private
    FEditor: TThemedHexEditor;
    FInspector: TThemedHexInspector;
    FBookmarks: TThemedHexBookmarkList;
    FActions: TActionList;
    FQuery: TThemedTextBox;
    FSearchMode: TThemedComboBox;
    FEncoding: TThemedComboBox;
    FProviders: TThemedComboBox;
    FStatus: TThemedLabel;
    FFileLabel: TThemedLabel;
    FResults: TThemedLabel;
    FFileName: string;
    FBuilding: Boolean;
    FSaveDialog: TSaveDialog;
    FOpenDialog: TOpenDialog;
    function NewAction(const ACaption: string; const ACommand: Integer; const AShortcut: TShortCut = 0): TAction;
    function Prompt(const ACaption: string; var AValue: string): Boolean;
    function ChooseSave(const AFilter: string; out APath: string): Boolean;
    function ChooseOpen(const AFilter: string; out APath: string): Boolean;
    procedure BuildControls;
    procedure NewSample;
    procedure CommandExecute(Sender: TObject);
    procedure CommandUpdate(Sender: TObject);
    procedure EditorChanged(Sender: TObject);
    procedure BookmarksChanged(Sender: TObject);
    procedure QueryEnter(Sender: TObject);
    procedure EncodingChanged(Sender: TObject);
    procedure WorkspaceKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure RequestGoto(Sender: TObject);
    procedure RequestSearch(Sender: TObject);
    procedure RequestReplace(Sender: TObject);
    procedure RequestNext(Sender: TObject);
    procedure RequestPrevious(Sender: TObject);
    procedure BookmarkActivate(Sender: TObject; const AOffset: Int64);
    procedure BookmarkRemove(Sender: TObject; const AOffset: Int64);
    procedure SaveDocument;
  protected
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
    function ConfirmChanges: Boolean;
  end;

  TAdvancedHexForm = class(TDemoHostForm)
  private
    FWorkspace: TAdvancedHexDemo;
    procedure WorkspaceCloseQuery(Sender: TObject; var CanClose: Boolean);
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette);
  end;



  TBinaryWorkspaceForm = class(TDemoHostForm)
  private
    FDemo: TAdvancedHexDemo;
    procedure HandleCloseQuery(Sender: TObject; var CanClose: Boolean);
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
  end;

implementation

function THexDemoMarkerProvider.GetName: string;
begin
  Result := 'Demo markers';
end;

function THexDemoMarkerProvider.Search(const ASource: IHexDataSource;
  const AQuery: THexSearchQuery): TObjectList<THexSearchMatch>;
var
  LQuery: THexSearchQuery;
  LNative: IHexSearchProvider;
begin
  LQuery := AQuery.Clone;
  try
    LQuery.Mode := hsmText;
    LQuery.Patterns := nil;
    LQuery.RawBytes := nil;
    LQuery.Text := 'Nimbus';
    LQuery.EncodingName := 'UTF-8';
    LNative := THexNativeSearchProvider.Create;
    Result := LNative.Search(ASource, LQuery);
  finally
    LQuery.Free;
  end;
end;

constructor TAdvancedHexDemo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Align := alClient;
  FActions := TActionList.Create(Self);
end;

procedure TAdvancedHexDemo.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  if (AParent <> nil) and (FActions <> nil) and (FEditor = nil) and not FBuilding and
    not (csDestroying in ComponentState) then
  begin
    FBuilding := True;
    try BuildControls; finally FBuilding := False; end;
  end;
end;

function TAdvancedHexDemo.NewAction(const ACaption: string; const ACommand: Integer;
  const AShortcut: TShortCut): TAction;
begin
  Result := TAction.Create(Self);
  Result.ActionList := FActions;
  Result.Caption := ACaption;
  Result.Tag := ACommand;
  Result.ShortCut := AShortcut;
  Result.OnExecute := CommandExecute;
  Result.OnUpdate := CommandUpdate;
end;

procedure TAdvancedHexDemo.BuildControls;
var
  LBody, LSide, LQueryPanel, LStatusPanel: TThemedPanel;
  LMenuBar: TThemedMenuBar;
  LToolBar: TThemedToolBar;
  LLabel: TThemedLabel;
  LButton: TThemedButton;
  LMenu: TThemedPopupMenu;
  LMenuItem: TMenuItem;
  LBarItem: TThemedMenuBarItem;
  LNames: TArray<string>;
  I: Integer;
  LFindAction: TAction;
  function Menu(const ACaption: string): TThemedPopupMenu;
  begin
    Result := TThemedPopupMenu.Create(Self);
    LBarItem := LMenuBar.LeftItems.Add;
    LBarItem.Caption := ACaption;
    LBarItem.DropDownMenu := Result;
  end;
  function Command(const AMenu: TThemedPopupMenu; const ACaption: string; const ATag: Integer;
    const AShortcut: TShortCut = 0): TAction;
  begin
    Result := NewAction(ACaption, ATag, AShortcut);
    LMenuItem := TMenuItem.Create(AMenu);
    LMenuItem.Action := Result;
    AMenu.Items.Add(LMenuItem);
  end;
  procedure Tool(const AAction: TAction);
  var
    LTool: TThemedToolButton;
  begin
    LTool := TThemedToolButton.Create(LToolBar);
    LTool.Parent := LToolBar;
    LTool.Width := 90;
    LTool.Action := AAction;
  end;
begin
  FOpenDialog := TOpenDialog.Create(Self);
  FOpenDialog.Options := FOpenDialog.Options + [ofFileMustExist];
  FSaveDialog := TSaveDialog.Create(Self);
  FSaveDialog.Options := FSaveDialog.Options + [ofOverwritePrompt];
  LBody := TThemedPanel.Create(Self);
  LBody.Parent := Self;
  LBody.Align := alClient;
  LStatusPanel := TThemedPanel.Create(Self);
  LStatusPanel.Parent := Self;
  LStatusPanel.Align := alBottom;
  LStatusPanel.Height := 54;
  FFileLabel := TThemedLabel.Create(Self);
  FFileLabel.Parent := LStatusPanel;
  FFileLabel.Align := alTop;
  FFileLabel.Height := 25;
  FFileLabel.AutoSize := False;
  FStatus := TThemedLabel.Create(Self);
  FStatus.Parent := LStatusPanel;
  FStatus.Align := alClient;
  FStatus.AutoSize := False;
  LSide := TThemedPanel.Create(Self);
  LSide.Parent := LBody;
  LSide.Align := alRight;
  LSide.Width := 285;
  FInspector := TThemedHexInspector.Create(Self);
  FInspector.Parent := LSide;
  FInspector.Align := alTop;
  FInspector.Height := 310;
  LLabel := TThemedLabel.Create(Self);
  LLabel.Parent := LSide;
  LLabel.Align := alTop;
  LLabel.Top := 310;
  LLabel.Height := 26;
  LLabel.AutoSize := False;
  LLabel.Caption := 'Bookmarks';
  FBookmarks := TThemedHexBookmarkList.Create(Self);
  FBookmarks.Parent := LSide;
  FBookmarks.Align := alClient;
  FBookmarks.OnBookmarkActivated := BookmarkActivate;
  FBookmarks.OnBookmarkRemoveRequested := BookmarkRemove;
  FEditor := TThemedHexEditor.Create(Self);
  FEditor.Parent := LBody;
  FEditor.Align := alClient;
  FEditor.SearchProviders.Add(THexDemoMarkerProvider.Create);
  LMenuBar := TThemedMenuBar.Create(Self);
  LMenuBar.Parent := Self;
  LMenuBar.Align := alTop;
  LMenuBar.Top := 0;
  LMenuBar.Height := 30;
  LToolBar := TThemedToolBar.Create(Self);
  LToolBar.Parent := Self;
  LToolBar.Align := alTop;
  LToolBar.Top := 30;
  LToolBar.ShowGrip := False;
  LToolBar.ShowOverflow := True;
  LMenu := Menu('&File');
  Tool(Command(LMenu, 'New sample', 0, ShortCut(Ord('N'), [ssCtrl])));
  Tool(Command(LMenu, 'Open', 1, ShortCut(Ord('O'), [ssCtrl])));
  Tool(Command(LMenu, 'Save', 2, ShortCut(Ord('S'), [ssCtrl])));
  Command(LMenu, 'Save as...', 3);
  Command(LMenu, 'Open session...', 4);
  Command(LMenu, 'Save session...', 5);
  Command(LMenu, 'Open project...', 6);
  Command(LMenu, 'Save project...', 7);
  Command(LMenu, 'Save patch...', 38);
  Command(LMenu, 'Apply patch...', 39);
  LMenu := Menu('&Edit');
  Tool(Command(LMenu, 'Undo', 8, ShortCut(Ord('Z'), [ssCtrl])));
  Tool(Command(LMenu, 'Redo', 9, ShortCut(Ord('Y'), [ssCtrl])));
  Command(LMenu, 'Copy hex', 10, ShortCut(Ord('C'), [ssCtrl]));
  Command(LMenu, 'Copy raw bytes', 11);
  Command(LMenu, 'Copy text', 12);
  Command(LMenu, 'Cut', 13, ShortCut(Ord('X'), [ssCtrl]));
  Tool(Command(LMenu, 'Paste', 14, ShortCut(Ord('V'), [ssCtrl])));
  Command(LMenu, 'Paste insert', 15);
  Command(LMenu, 'Select all', 16, ShortCut(Ord('A'), [ssCtrl]));
  Command(LMenu, 'Read only', 32);
  Command(LMenu, 'Insert mode', 33, ShortCut(VK_INSERT, []));
  LMenu := Menu('&Search');
  Tool(Command(LMenu, 'Find...', 17, ShortCut(Ord('F'), [ssCtrl])));
  Tool(Command(LMenu, 'Replace...', 18, ShortCut(Ord('H'), [ssCtrl])));
  Command(LMenu, 'Next match', 19, ShortCut(VK_F3, []));
  Command(LMenu, 'Previous match', 20, ShortCut(VK_F3, [ssShift]));
  Command(LMenu, 'Go to offset...', 21, ShortCut(Ord('G'), [ssCtrl]));
  Command(LMenu, 'Find multiple texts...', 35);
  Command(LMenu, 'Approximate byte search...', 36);
  Command(LMenu, 'Run sample rule', 37);
  Command(LMenu, 'Approximate signature search...', 52);
  Command(LMenu, 'Select match by index...', 53);
  Command(LMenu, 'Use integrated find dialog', 55);
  LMenu := Menu('&Bookmarks');
  Tool(Command(LMenu, 'Bookmark', 22));
  Command(LMenu, 'Next bookmark', 23);
  Command(LMenu, 'Previous bookmark', 24);
  Command(LMenu, 'Rename bookmark...', 25);
  Command(LMenu, 'Remove bookmark', 26);
  Command(LMenu, 'Move bookmark...', 54);
  LMenu := Menu('E&xport');
  Command(LMenu, 'Selection as hex...', 27);
  Command(LMenu, 'Selection as C# array...', 28);
  Command(LMenu, 'Selection as HTML...', 29);
  Command(LMenu, 'Selection as JSON...', 30);
  Command(LMenu, 'Selection as Base64...', 31);
  Command(LMenu, 'Detect encoding', 34);
  LMenu := Menu('&View');
  Command(LMenu, '8 bytes per row', 42);
  Command(LMenu, '16 bytes per row', 43);
  Command(LMenu, '32 bytes per row', 44);
  Command(LMenu, 'ASCII column', 45);
  Command(LMenu, 'Grid lines', 46);
  Command(LMenu, 'Inspector', 47);
  Command(LMenu, 'Bookmark list', 48);
  Command(LMenu, 'Open another editor window', 51);
  LQueryPanel := TThemedPanel.Create(Self);
  LQueryPanel.Parent := Self;
  LQueryPanel.Align := alTop;
  LQueryPanel.Top := 70;
  LQueryPanel.Height := 44;
  FQuery := TThemedTextBox.Create(Self);
  FQuery.Parent := LQueryPanel;
  FQuery.SetBounds(8, 7, 260, 30);
  FQuery.Text := '4E 69 6D 62 75 73';
  FQuery.OnEnterPressed := QueryEnter;
  FSearchMode := TThemedComboBox.Create(Self);
  FSearchMode.Parent := LQueryPanel;
  FSearchMode.SetBounds(278, 8, 110, 28);
  FSearchMode.Style := csDropDownList;
  FSearchMode.Items.Add('Hex bytes');
  FSearchMode.Items.Add('Text');
  FSearchMode.Items.Add('Pattern');
  FSearchMode.ItemIndex := 0;
  FProviders := TThemedComboBox.Create(Self);
  FProviders.Parent := LQueryPanel;
  FProviders.SetBounds(398, 8, 145, 28);
  FProviders.Style := csDropDownList;
  LNames := FEditor.SearchProviders.Names;
  for I := 0 to High(LNames) do FProviders.Items.Add(LNames[I]);
  FProviders.ItemIndex := 0;
  LFindAction := NewAction('Search', 40);
  LButton := TThemedButton.Create(Self);
  LButton.Parent := LQueryPanel;
  LButton.SetBounds(553, 6, 86, 31);
  LButton.Action := LFindAction;
  FEncoding := TThemedComboBox.Create(Self);
  FEncoding.Parent := LQueryPanel;
  FEncoding.SetBounds(649, 8, 130, 28);
  FEncoding.Style := csDropDownList;
  LNames := FEditor.GetSupportedEncodings;
  for I := 0 to High(LNames) do FEncoding.Items.Add(LNames[I]);
  FEncoding.ItemIndex := 0;
  FEncoding.OnChange := EncodingChanged;
  FResults := TThemedLabel.Create(Self);
  FResults.Parent := LQueryPanel;
  FResults.AutoSize := False;
  FResults.SetBounds(790, 10, 260, 24);
  FEditor.OnCursorChange := EditorChanged;
  FEditor.OnSelectionChange := EditorChanged;
  FEditor.OnModifiedChange := EditorChanged;
  FEditor.OnUndoRedoStateChange := EditorChanged;
  FEditor.OnBookmarksChange := BookmarksChanged;
  FEditor.OnSearchChange := EditorChanged;
  FEditor.OnDataSourceChange := BookmarksChanged;
  FEditor.OnEditModeChange := EditorChanged;
  FEditor.OnKeyDown := WorkspaceKeyDown;
  FEditor.OnRequestGotoOffset := RequestGoto;
  FEditor.OnRequestFind := RequestSearch;
  FEditor.OnRequestReplace := RequestReplace;
  FEditor.OnRequestFindNext := RequestNext;
  FEditor.OnRequestFindPrevious := RequestPrevious;
  NewSample;
end;

procedure TAdvancedHexDemo.NewSample;
var
  LBytes, LMarker: TBytes;
  I, J: Integer;
begin
  SetLength(LBytes, 16384);
  for I := 0 to High(LBytes) do LBytes[I] := Byte(I and $FF);
  LMarker := TEncoding.UTF8.GetBytes('NimbusForms sample data');
  for I := 0 to 15 do
    for J := 0 to High(LMarker) do LBytes[I * 1024 + J] := LMarker[J];
  FEditor.LoadBytes(LBytes);
  FEditor.Options.ReadOnly := False;
  FEditor.GotoOffset(0);
  FEditor.AddBookmark(0, 'File header', ThemeColor(255, 86, 156, 214));
  FEditor.AddBookmark(1024, 'Data block', ThemeColor(255, 78, 201, 176));
  FFileName := 'Untitled sample';
  EditorChanged(Self);
end;

function TAdvancedHexDemo.Prompt(const ACaption: string; var AValue: string): Boolean;
var
  LForm: TForm;
  LPanel: TThemedPanel;
  LText: TThemedTextBox;
  LButton: TThemedButton;
begin
  LForm := TForm.CreateNew(Self);
  try
    LForm.Caption := ACaption;
    LForm.Position := poScreenCenter;
    LForm.BorderStyle := bsDialog;
    LForm.ClientWidth := 460;
    LForm.ClientHeight := 115;
    LPanel := TThemedPanel.Create(LForm);
    LPanel.Parent := LForm;
    LPanel.Align := alClient;
    LText := TThemedTextBox.Create(LForm);
    LText.Parent := LPanel;
    LText.SetBounds(12, 12, 436, 30);
    LText.Text := AValue;
    LButton := TThemedButton.Create(LForm);
    LButton.Parent := LPanel;
    LButton.SetBounds(244, 62, 96, 30);
    LButton.Caption := 'OK';
    LButton.ModalResult := mrOk;
    LButton := TThemedButton.Create(LForm);
    LButton.Parent := LPanel;
    LButton.SetBounds(352, 62, 96, 30);
    LButton.Caption := 'Cancel';
    LButton.ModalResult := mrCancel;
    ThemeManager.ApplyCurrent(LForm);
    Result := LForm.ShowModal = mrOk;
    if Result then AValue := LText.Text;
  finally
    LForm.Free;
  end;
end;

function TAdvancedHexDemo.ChooseSave(const AFilter: string; out APath: string): Boolean;
begin
  FSaveDialog.Filter := AFilter;
  FSaveDialog.DefaultExt := '';
  if Pos('*.nhsession', AFilter) > 0 then FSaveDialog.DefaultExt := 'nhsession'
  else if Pos('*.nhproject', AFilter) > 0 then FSaveDialog.DefaultExt := 'nhproject'
  else if Pos('*.nhpatch', AFilter) > 0 then FSaveDialog.DefaultExt := 'nhpatch';
  FSaveDialog.FileName := '';
  Result := FSaveDialog.Execute;
  if Result then APath := FSaveDialog.FileName else APath := '';
end;

function TAdvancedHexDemo.ChooseOpen(const AFilter: string; out APath: string): Boolean;
begin
  FOpenDialog.Filter := AFilter;
  Result := FOpenDialog.Execute;
  if Result then APath := FOpenDialog.FileName else APath := '';
end;

procedure TAdvancedHexDemo.SaveDocument;
var
  LPath: string;
begin
  if FEditor.CanSave then FEditor.Save
  else if ChooseSave('Binary files|*.*', LPath) then
  begin
    FEditor.SaveAs(LPath);
    FFileName := LPath;
  end;
  EditorChanged(Self);
end;

function TAdvancedHexDemo.ConfirmChanges: Boolean;
var
  LForm: TForm;
  LPanel: TThemedPanel;
  LLabel: TThemedLabel;
  LButton: TThemedButton;
  LResult: Integer;
  I: Integer;
begin
  Result := True;
  if (FEditor = nil) or not FEditor.Modified then Exit;
  LForm := TForm.CreateNew(Self);
  try
    LForm.Caption := 'Unsaved changes';
    LForm.Position := poScreenCenter;
    LForm.BorderStyle := bsDialog;
    LForm.ClientWidth := 470;
    LForm.ClientHeight := 120;
    LPanel := TThemedPanel.Create(LForm);
    LPanel.Parent := LForm;
    LPanel.Align := alClient;
    LLabel := TThemedLabel.Create(LForm);
    LLabel.Parent := LPanel;
    LLabel.Caption := 'Save document changes before continuing?';
    LLabel.SetBounds(12, 18, 440, 24);
    for I := 0 to 2 do
    begin
      LButton := TThemedButton.Create(LForm);
      LButton.Parent := LPanel;
      LButton.SetBounds(144 + I * 106, 70, 96, 30);
      case I of
        0: begin LButton.Caption := 'Save'; LButton.ModalResult := mrYes; end;
        1: begin LButton.Caption := 'Discard'; LButton.ModalResult := mrNo; end;
        2: begin LButton.Caption := 'Cancel'; LButton.ModalResult := mrCancel; end;
      end;
    end;
    ThemeManager.ApplyCurrent(LForm);
    LResult := LForm.ShowModal;
  finally
    LForm.Free;
  end;
  if LResult = mrYes then
  begin
    SaveDocument;
    Result := not FEditor.Modified;
  end
  else Result := LResult = mrNo;
end;

procedure TAdvancedHexDemo.CommandExecute(Sender: TObject);
var
  LPath, LText, LFormat: string;
  LOffset: Int64;
  LQuery: THexSearchQuery;
  LMatches: TObjectList<THexSearchMatch>;
  LRule: THexSearchRule;
  LPatch: THexPatchFile;
  LWindow: TAdvancedHexForm;
begin
  try
    case TComponent(Sender).Tag of
      0: if ConfirmChanges then NewSample;
      1: if ConfirmChanges and ChooseOpen('All files|*.*', LPath) then
        begin FEditor.LoadFile(LPath); FFileName := LPath; end;
      2: SaveDocument;
      3: if ChooseSave('Binary files|*.*', LPath) then begin FEditor.SaveAs(LPath); FFileName := LPath; end;
      4: if ConfirmChanges and ChooseOpen('Hex sessions|*.nhsession|All files|*.*', LPath) then
        begin FEditor.RestoreSessionFile(LPath); FFileName := LPath; end;
      5: if ChooseSave('Hex sessions|*.nhsession', LPath) then FEditor.SaveSession(LPath);
      6: if ConfirmChanges and ChooseOpen('Hex projects|*.nhproject|All files|*.*', LPath) then
        begin FEditor.RestoreProjectFile(LPath); FFileName := LPath; end;
      7: if ChooseSave('Hex projects|*.nhproject', LPath) then FEditor.SaveProject(LPath, ExtractFileName(LPath));
      8: FEditor.Undo;
      9: FEditor.Redo;
      10: FEditor.CopyHexSelection;
      11: FEditor.CopyRawSelection;
      12: FEditor.CopyAsciiSelection;
      13: begin FEditor.CopyRawSelection; FEditor.DeleteSelection; end;
      14: if FEditor.InsertMode then FEditor.PasteInsert else FEditor.PasteOverwrite;
      15: FEditor.PasteInsert;
      16: FEditor.SelectAllBytes;
      17: FEditor.RequestFind;
      18: FEditor.RequestReplace;
      19: FEditor.RequestFindNext;
      20: FEditor.RequestFindPrevious;
      21:
        begin
          LText := '$' + IntToHex(FEditor.CursorPosition, 8);
          if Prompt('Go to offset (decimal or $hex)', LText) then
          begin
            if not TryStrToInt64(LText, LOffset) or (LOffset < 0) or (LOffset >= FEditor.DataLength) then
              raise EConvertError.Create('Offset is outside the document');
            FEditor.GotoOffset(LOffset);
          end;
        end;
      22: FEditor.ToggleBookmark(FEditor.CursorPosition);
      23: FEditor.GoToNextBookmark;
      24: FEditor.GoToPreviousBookmark;
      25:
        begin
          LText := 'Bookmark';
          if Prompt('Bookmark name', LText) then FEditor.RenameBookmark(FBookmarks.SelectedOffset, LText);
        end;
      26: FEditor.RemoveBookmark(FBookmarks.SelectedOffset);
      27..31:
        begin
          case TComponent(Sender).Tag of
            27: LFormat := 'hex';
            28: LFormat := 'csharp';
            29: LFormat := 'html';
            30: LFormat := 'json';
          else LFormat := 'base64';
          end;
          LText := FEditor.ExportSelection(LFormat);
          if ChooseSave('Export file|*.*', LPath) then TFile.WriteAllText(LPath, LText, TEncoding.UTF8);
        end;
      32: begin FEditor.Options.ReadOnly := not FEditor.Options.ReadOnly; FEditor.Invalidate; end;
      33: FEditor.InsertMode := not FEditor.InsertMode;
      34:
        begin
          FEditor.EncodingName := FEditor.DetectEncodingName;
          FEncoding.ItemIndex := FEncoding.Items.IndexOf(FEditor.EncodingName);
        end;
      35:
        begin
          LText := 'Nimbus;Forms;sample';
          if Prompt('Find texts separated by semicolons', LText) then
          begin
            LMatches := FEditor.SearchAnyText(LText.Split([';']));
            try FEditor.SetAdvancedSearchMatches(LMatches); finally LMatches.Free; end;
          end;
        end;
      36:
        begin
          LText := '4E 69 6D 62 75 73';
          if Prompt('Approximate bytes (maximum one different byte)', LText) then
          begin
            LQuery := THexSearchQuery.Create;
            try
              LQuery.Text := LText;
              if not THexSearchService.TryParseHexBytes(LText, LQuery.RawBytes) then raise EConvertError.Create('Invalid hex bytes');
              LMatches := FEditor.SearchApproximate(LQuery.RawBytes, 1);
              try FEditor.SetAdvancedSearchMatches(LMatches); finally LMatches.Free; end;
            finally LQuery.Free; end;
          end;
        end;
      37:
        begin
          LRule := THexSearchRule.Create;
          try
            LRule.Name := 'Nimbus followed by Forms';
            LRule.AddPattern('Nimbus', '4E 69 6D 62 75 73');
            with LRule.AddPattern('Forms', '46 6F 72 6D 73') do
            begin RelativeToPatternName := 'Nimbus'; MinRelativeOffset := 6; MaxRelativeOffset := 6; end;
            FEditor.SearchRule(LRule);
          finally LRule.Free; end;
        end;
      38: if ChooseSave('Hex patch|*.nhpatch', LPath) then FEditor.SavePatch(LPath);
      39: if ChooseOpen('Hex patch|*.nhpatch|All files|*.*', LPath) then
        begin
          LPatch := THexPatchSerializer.Load(LPath);
          try FEditor.ApplyPatch(LPatch); finally LPatch.Free; end;
        end;
      52:
        begin
          LText := '4E 69 ?? 62 75 72';
          if Prompt('Signature (maximum one mismatched token)', LText) then
          begin
            LMatches := FEditor.SearchPattern(LText, 0, -1, 1);
            try FEditor.SetAdvancedSearchMatches(LMatches); finally LMatches.Free; end;
          end;
        end;
      53:
        begin
          LText := IntToStr(FEditor.ActiveAdvancedSearchMatchIndex);
          if Prompt('Search match index (zero based)', LText) then
          begin
            if not TryStrToInt64(LText, LOffset) or (LOffset < 0) or (LOffset > MaxInt) then
              raise EConvertError.Create('Invalid match index');
            if not FEditor.SetActiveAdvancedSearchMatchIndex(Integer(LOffset)) then
              raise EArgumentOutOfRangeException.Create('No match at this index');
          end;
        end;
      54:
        begin
          LText := IntToStr(FBookmarks.SelectedOffset);
          if Prompt('New bookmark offset (decimal or $hex)', LText) then
          begin
            if not TryStrToInt64(LText, LOffset) then raise EConvertError.Create('Invalid offset');
            if not FEditor.MoveBookmark(FBookmarks.SelectedOffset, LOffset) then
              raise EArgumentException.Create('Bookmark is missing, outside the document or the target is occupied');
          end;
        end;
      55: FEditor.UseIntegratedFindReplaceDialog := not FEditor.UseIntegratedFindReplaceDialog;
      40:
        begin
          LQuery := THexSearchQuery.Create;
          try
            LQuery.Text := FQuery.Text;
            LQuery.EncodingName := FEditor.EncodingName;
            LQuery.MaxResults := 0;
            case FSearchMode.ItemIndex of
              0: LQuery.Mode := hsmHex;
              1: LQuery.Mode := hsmText;
            else LQuery.Mode := hsmPattern;
            end;
            LMatches := FEditor.SearchWithProvider(FProviders.Text, LQuery);
            try FEditor.SetAdvancedSearchMatches(LMatches); finally LMatches.Free; end;
          finally LQuery.Free; end;
        end;
      42..44:
        begin
          FEditor.Options.BytesPerRow := 8 shl (TComponent(Sender).Tag - 42);
          FEditor.RefreshLayout;
        end;
      45:
        begin
          FEditor.Options.ShowAscii := not FEditor.Options.ShowAscii;
          if not FEditor.Options.ShowAscii then FEditor.ActiveEditArea := hhaHexCell;
          FEditor.RefreshLayout;
        end;
      46: begin FEditor.Options.ShowGridLines := not FEditor.Options.ShowGridLines; FEditor.Invalidate; end;
      47: FInspector.Visible := not FInspector.Visible;
      48: FBookmarks.Visible := not FBookmarks.Visible;
      51:
        begin
          LWindow := TAdvancedHexForm.CreateNew(Self);
          try LWindow.ShowModal; finally LWindow.Free; end;
        end;
    end;
    EditorChanged(Self);
  except
    on E: Exception do FResults.Caption := E.Message;
  end;
end;

procedure TAdvancedHexDemo.CommandUpdate(Sender: TObject);
var
  LAction: TAction;
  LLoaded, LWritable, LSelected: Boolean;
begin
  LAction := TAction(Sender);
  LLoaded := (FEditor <> nil) and (FEditor.DataSource <> nil);
  LWritable := LLoaded;
  LSelected := False;
  if LLoaded then
  begin
    LWritable := FEditor.DataSource.CanWrite and not FEditor.Options.ReadOnly;
    LSelected := not FEditor.Selection.IsEmpty;
  end;
  case LAction.Tag of
    0, 1, 4, 6: LAction.Enabled := True;
    8: LAction.Enabled := LWritable and FEditor.CanUndo;
    9: LAction.Enabled := LWritable and FEditor.CanRedo;
    10..12, 27..31: LAction.Enabled := LSelected;
    13: LAction.Enabled := LWritable and LSelected;
    14, 15, 18, 39: LAction.Enabled := LWritable;
    25, 26, 54: LAction.Enabled := LLoaded and (FBookmarks.SelectedOffset >= 0);
    53: LAction.Enabled := LLoaded and (FEditor.SearchMatchCount > 0);
  else LAction.Enabled := LLoaded;
  end;
  if FEditor <> nil then
  begin
    if LAction.Tag = 32 then LAction.Checked := FEditor.Options.ReadOnly;
    if LAction.Tag = 33 then LAction.Checked := FEditor.InsertMode;
    if LAction.Tag = 55 then LAction.Checked := FEditor.UseIntegratedFindReplaceDialog;
    if LAction.Tag in [42, 43, 44] then LAction.Checked := FEditor.Options.BytesPerRow = (8 shl (LAction.Tag - 42));
    if LAction.Tag = 45 then LAction.Checked := FEditor.Options.ShowAscii;
    if LAction.Tag = 46 then LAction.Checked := FEditor.Options.ShowGridLines;
    if LAction.Tag = 47 then LAction.Checked := FInspector.Visible;
    if LAction.Tag = 48 then LAction.Checked := FBookmarks.Visible;
  end;
end;

procedure TAdvancedHexDemo.EditorChanged(Sender: TObject);
var
  LMode, LAccess: string;
begin
  if (FEditor = nil) or (FStatus = nil) then Exit;
  FInspector.ShowOffset(FEditor.DataSource, FEditor.CursorPosition);
  FFileLabel.Caption := FFileName;
  if FEditor.Modified then FFileLabel.Caption := FFileName + ' *';
  if FEditor.InsertMode then LMode := 'INS' else LMode := 'OVR';
  if FEditor.Options.ReadOnly then LAccess := 'Read only' else LAccess := 'Editable';
  FStatus.Caption := Format('Offset: 0x%s   Selection: %d bytes   Length: %d bytes   %s   %s   %s',
    [IntToHex(FEditor.CursorPosition, 8), FEditor.Selection.Length, FEditor.DataLength, LMode, LAccess, FEditor.EncodingName]);
  FResults.Caption := Format('%d search matches', [FEditor.SearchMatchCount]);
end;

procedure TAdvancedHexDemo.BookmarksChanged(Sender: TObject);
begin
  FBookmarks.SetBookmarks(FEditor.Bookmarks);
  EditorChanged(Sender);
end;

procedure TAdvancedHexDemo.QueryEnter(Sender: TObject);
var
  LAction: TAction;
begin
  LAction := TAction.Create(nil);
  try LAction.Tag := 40; CommandExecute(LAction); finally LAction.Free; end;
end;

procedure TAdvancedHexDemo.WorkspaceKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  I: Integer;
begin
  if (Key = Ord('S')) and (ssCtrl in Shift) then
    for I := 0 to FActions.ActionCount - 1 do
      if TAction(FActions.Actions[I]).Tag = 2 then
      begin
        TAction(FActions.Actions[I]).Execute;
        Key := 0;
        Exit;
      end;
end;

procedure TAdvancedHexDemo.RequestGoto(Sender: TObject);
var
  LAction: TAction;
begin
  LAction := TAction.Create(nil);
  try LAction.Tag := 21; CommandExecute(LAction); finally LAction.Free; end;
end;

procedure TAdvancedHexDemo.RequestSearch(Sender: TObject);
begin
  if FQuery.CanFocus then FQuery.SetFocus;
  QueryEnter(Sender);
end;

procedure TAdvancedHexDemo.RequestReplace(Sender: TObject);
begin
  FEditor.ShowReplaceDialog;
end;

procedure TAdvancedHexDemo.RequestNext(Sender: TObject);
begin
  FEditor.FindNext;
end;

procedure TAdvancedHexDemo.RequestPrevious(Sender: TObject);
begin
  FEditor.FindPrevious;
end;

procedure TAdvancedHexDemo.EncodingChanged(Sender: TObject);
begin
  if FEncoding.ItemIndex < 0 then Exit;
  FEditor.EncodingName := FEncoding.Text;
  EditorChanged(Self);
end;

procedure TAdvancedHexDemo.BookmarkActivate(Sender: TObject; const AOffset: Int64);
begin
  FEditor.GoToBookmark(AOffset);
end;

procedure TAdvancedHexDemo.BookmarkRemove(Sender: TObject; const AOffset: Int64);
begin
  FEditor.RemoveBookmark(AOffset);
end;

constructor TAdvancedHexForm.CreateNew(AOwner: TComponent; Dummy: Integer);
begin
  inherited CreateNew(AOwner, Dummy);
  Caption := 'NimbusForms HexEditor';
  Position := poScreenCenter;
  ClientWidth := 1240;
  ClientHeight := 780;
  Constraints.MinWidth := 1000;
  Constraints.MinHeight := 600;
  FWorkspace := TAdvancedHexDemo.Create(Self);
  FWorkspace.Parent := Body;
  OnCloseQuery := WorkspaceCloseQuery;
  ThemeManager.RegisterAware(Self);
end;

destructor TAdvancedHexForm.Destroy;
begin
  ThemeManager.UnregisterAware(Self);
  inherited Destroy;
end;

procedure TAdvancedHexForm.ApplyTheme(const APalette: TThemePalette);
begin
  if APalette = nil then Exit;
  Color := ThemeColorToColor(APalette.ControlBackColor);
  Font.Color := ThemeColorToColor(APalette.ControlForeColor);
end;

procedure TAdvancedHexForm.WorkspaceCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := FWorkspace.ConfirmChanges;
end;


constructor TBinaryWorkspaceForm.CreateNew(AOwner: TComponent; Dummy: Integer);
begin inherited; FDemo := TAdvancedHexDemo.Create(Self); FDemo.Parent := Body; FDemo.Align := alClient; OnCloseQuery := HandleCloseQuery; end;
procedure TBinaryWorkspaceForm.HandleCloseQuery(Sender: TObject; var CanClose: Boolean);
begin CanClose := FDemo.ConfirmChanges; end;

end.

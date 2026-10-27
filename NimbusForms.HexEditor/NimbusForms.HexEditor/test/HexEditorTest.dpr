program HexEditorTest;

{$APPTYPE GUI}

uses
  Winapi.Windows,
  System.SysUtils,
  System.Types,
  System.Classes,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Dialogs,
  Vcl.Clipbrd,
  Vcl.Graphics,
  NimbusForms.Theming.Types in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.Types.pas',
  NimbusForms.Theming.Palette in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.Palette.pas',
  NimbusForms.Theming.Strings in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.Strings.pas',
  NimbusForms.Theming.WinVersion in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.WinVersion.pas',
  NimbusForms.Theming.Win32 in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.Win32.pas',
  NimbusForms.Theming.PresetFactory in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.PresetFactory.pas',
  NimbusForms.Theming.Serializer in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.Serializer.pas',
  NimbusForms.Theming.Presets in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.Presets.pas',
  NimbusForms.Theming.Manager in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.Manager.pas',
  NativePattern in '..\..\NativePattern\src\NativePattern.pas',
  NativePattern.AhoCorasick in '..\..\NativePattern\src\NativePattern.AhoCorasick.pas',
  NativePattern.Avx2 in '..\..\NativePattern\src\NativePattern.Avx2.pas',
  NativePattern.Bitap in '..\..\NativePattern\src\NativePattern.Bitap.pas',
  NativePattern.BoyerMooreHorspool in '..\..\NativePattern\src\NativePattern.BoyerMooreHorspool.pas',
  NativePattern.CommentzWalter in '..\..\NativePattern\src\NativePattern.CommentzWalter.pas',
  NativePattern.Core in '..\..\NativePattern\src\NativePattern.Core.pas',
  NativePattern.Levenshtein in '..\..\NativePattern\src\NativePattern.Levenshtein.pas',
  NativePattern.Myers in '..\..\NativePattern\src\NativePattern.Myers.pas',
  NativePattern.RabinKarp in '..\..\NativePattern\src\NativePattern.RabinKarp.pas',
  NativePattern.Sbndm in '..\..\NativePattern\src\NativePattern.Sbndm.pas',
  NativePattern.TwoWay in '..\..\NativePattern\src\NativePattern.TwoWay.pas',
  NimbusForms.HexEditor.BookmarkList in '..\src\NimbusForms.HexEditor.BookmarkList.pas',
  NimbusForms.HexEditor.Bookmarks in '..\src\NimbusForms.HexEditor.Bookmarks.pas',
  NimbusForms.HexEditor.Control in '..\src\NimbusForms.HexEditor.Control.pas',
  NimbusForms.HexEditor.DataSource in '..\src\NimbusForms.HexEditor.DataSource.pas',
  NimbusForms.HexEditor.Document in '..\src\NimbusForms.HexEditor.Document.pas',
  NimbusForms.HexEditor.Export in '..\src\NimbusForms.HexEditor.Export.pas',
  NimbusForms.HexEditor.FileDataSource in '..\src\NimbusForms.HexEditor.FileDataSource.pas',
  NimbusForms.HexEditor.FindReplaceAdapter in '..\src\NimbusForms.HexEditor.FindReplaceAdapter.pas',
  NimbusForms.HexEditor.FindReplaceDialog in '..\src\NimbusForms.HexEditor.FindReplaceDialog.pas',
  NimbusForms.HexEditor.FindReplaceTypes in '..\src\NimbusForms.HexEditor.FindReplaceTypes.pas',
  NimbusForms.HexEditor.Inspector in '..\src\NimbusForms.HexEditor.Inspector.pas',
  NimbusForms.HexEditor.InspectorControl in '..\src\NimbusForms.HexEditor.InspectorControl.pas',
  NimbusForms.HexEditor.Options in '..\src\NimbusForms.HexEditor.Options.pas',
  NimbusForms.HexEditor.Patch in '..\src\NimbusForms.HexEditor.Patch.pas',
  NimbusForms.HexEditor.Pattern in '..\src\NimbusForms.HexEditor.Pattern.pas',
  NimbusForms.HexEditor.PatternParser in '..\src\NimbusForms.HexEditor.PatternParser.pas',
  NimbusForms.HexEditor.PatternSearch in '..\src\NimbusForms.HexEditor.PatternSearch.pas',
  NimbusForms.HexEditor.Pieces in '..\src\NimbusForms.HexEditor.Pieces.pas',
  NimbusForms.HexEditor.ProjectSerializer in '..\src\NimbusForms.HexEditor.ProjectSerializer.pas',
  NimbusForms.HexEditor.RenderContext in '..\src\NimbusForms.HexEditor.RenderContext.pas',
  NimbusForms.HexEditor.Renderers in '..\src\NimbusForms.HexEditor.Renderers.pas',
  NimbusForms.HexEditor.RenderSurface in '..\src\NimbusForms.HexEditor.RenderSurface.pas',
  NimbusForms.HexEditor.RuleEngine in '..\src\NimbusForms.HexEditor.RuleEngine.pas',
  NimbusForms.HexEditor.ScrollBar in '..\src\NimbusForms.HexEditor.ScrollBar.pas',
  NimbusForms.HexEditor.Search in '..\src\NimbusForms.HexEditor.Search.pas',
  NimbusForms.HexEditor.SearchService in '..\src\NimbusForms.HexEditor.SearchService.pas',
  NimbusForms.HexEditor.Session in '..\src\NimbusForms.HexEditor.Session.pas',
  NimbusForms.HexEditor.SessionSerializer in '..\src\NimbusForms.HexEditor.SessionSerializer.pas',
  NimbusForms.HexEditor.Strings in '..\src\NimbusForms.HexEditor.Strings.pas',
  NimbusForms.HexEditor.Theme in '..\src\NimbusForms.HexEditor.Theme.pas',
  NimbusForms.HexEditor.Tooltip in '..\src\NimbusForms.HexEditor.Tooltip.pas',
  NimbusForms.HexEditor.Types in '..\src\NimbusForms.HexEditor.Types.pas',
  NimbusForms.HexEditor.Undo in '..\src\NimbusForms.HexEditor.Undo.pas';

type
  TMainForm = class(TForm)
  private
    FTop: TPanel;
    FCombo: TComboBox;
    FOpen: TButton;
    FSearch: TEdit;
    FFind: TButton;
    FNext: TButton;
    FExport: TButton;
    FBookmark: TButton;
    FRight: TPanel;
    FBookmarkList: TThemedHexBookmarkList;
    FEditor: TThemedHexEditor;
    FInspector: TThemedHexInspector;
    procedure ComboChange(Sender: TObject);
    procedure CursorChange(Sender: TObject);
    procedure OpenClick(Sender: TObject);
    procedure FindClick(Sender: TObject);
    procedure NextClick(Sender: TObject);
    procedure ExportClick(Sender: TObject);
    procedure ModifiedChange(Sender: TObject);
    procedure BookmarkClick(Sender: TObject);
    procedure BookmarksChanged(Sender: TObject);
    procedure BookmarkActivated(Sender: TObject; const AOffset: Int64);
    procedure BookmarkRemove(Sender: TObject; const AOffset: Int64);
    procedure LoadSample;
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
  end;

constructor TMainForm.CreateNew(AOwner: TComponent; Dummy: Integer);
var
  LName: string;
begin
  inherited CreateNew(AOwner, Dummy);
  Caption := 'NimbusForms HexEditor';
  Width := 960;
  Height := 680;
  Position := poScreenCenter;

  FTop := TPanel.Create(Self);
  FTop.Parent := Self;
  FTop.Align := alTop;
  FTop.Height := 40;
  FTop.BevelOuter := bvNone;

  FCombo := TComboBox.Create(Self);
  FCombo.Parent := FTop;
  FCombo.Style := csDropDownList;
  FCombo.SetBounds(8, 8, 240, 24);
  FCombo.OnChange := ComboChange;
  for LName in TThemePresets.GetNames do
    FCombo.Items.Add(LName);

  FOpen := TButton.Create(Self);
  FOpen.Parent := FTop;
  FOpen.SetBounds(256, 7, 120, 26);
  FOpen.Caption := 'Open File...';
  FOpen.OnClick := OpenClick;

  FSearch := TEdit.Create(Self);
  FSearch.Parent := FTop;
  FSearch.SetBounds(392, 8, 200, 24);
  FSearch.TextHint := 'hex / sig 48 8B ?? / dsl 48 [0-4] (8B|8D)';

  FFind := TButton.Create(Self);
  FFind.Parent := FTop;
  FFind.SetBounds(600, 7, 80, 26);
  FFind.Caption := 'Find';
  FFind.OnClick := FindClick;

  FNext := TButton.Create(Self);
  FNext.Parent := FTop;
  FNext.SetBounds(684, 7, 80, 26);
  FNext.Caption := 'Next';
  FNext.OnClick := NextClick;

  FExport := TButton.Create(Self);
  FExport.Parent := FTop;
  FExport.SetBounds(768, 7, 90, 26);
  FExport.Caption := 'Export C#';
  FExport.OnClick := ExportClick;

  FBookmark := TButton.Create(Self);
  FBookmark.Parent := FTop;
  FBookmark.SetBounds(862, 7, 90, 26);
  FBookmark.Caption := 'Bookmark';
  FBookmark.OnClick := BookmarkClick;

  FRight := TPanel.Create(Self);
  FRight.Parent := Self;
  FRight.Align := alRight;
  FRight.Width := 240;
  FRight.BevelOuter := bvNone;

  FInspector := TThemedHexInspector.Create(Self);
  FInspector.Parent := FRight;
  FInspector.Align := alTop;
  FInspector.Height := 280;

  FBookmarkList := TThemedHexBookmarkList.Create(Self);
  FBookmarkList.Parent := FRight;
  FBookmarkList.Align := alClient;
  FBookmarkList.OnBookmarkActivated := BookmarkActivated;
  FBookmarkList.OnBookmarkRemoveRequested := BookmarkRemove;

  FEditor := TThemedHexEditor.Create(Self);
  FEditor.Parent := Self;
  FEditor.Align := alClient;
  FEditor.OnCursorChange := CursorChange;
  FEditor.OnModifiedChange := ModifiedChange;
  FEditor.OnBookmarksChange := BookmarksChanged;

  LoadSample;

  FCombo.ItemIndex := FCombo.Items.IndexOf('Dark');
  if FCombo.ItemIndex < 0 then
    FCombo.ItemIndex := 0;
  ComboChange(nil);
end;

procedure TMainForm.LoadSample;
var
  LData: TBytes;
  I: Integer;
begin
  SetLength(LData, 4096);
  for I := 0 to High(LData) do
    LData[I] := Byte(I * 7 + (I div 16) * 3);
  LData[16] := 13; LData[17] := 10;
  LData[32] := 9; LData[33] := 32; LData[34] := 0;
  FEditor.LoadBytes(LData);
end;

procedure TMainForm.ComboChange(Sender: TObject);
var
  LPalette: TThemePalette;
begin
  LPalette := TThemePresets.GetByName(FCombo.Text);
  try
    ThemeManager.ApplyGlobal(LPalette);
  finally
    LPalette.Free;
  end;
end;

procedure TMainForm.OpenClick(Sender: TObject);
var
  LDialog: TOpenDialog;
begin
  LDialog := TOpenDialog.Create(Self);
  try
    if LDialog.Execute then
      FEditor.LoadFromDataSource(THexDocument.Create(LDialog.FileName) as IHexDataSource);
  finally
    LDialog.Free;
  end;
end;

procedure TMainForm.CursorChange(Sender: TObject);
begin
  FInspector.ShowOffset(FEditor.DataSource, FEditor.CursorPosition);
end;

procedure TMainForm.FindClick(Sender: TObject);
var
  LKind: THexSearchKind;
begin
  if THexSearchService.IsPattern(FSearch.Text) then
    LKind := hskPattern
  else if THexSearchService.IsSignature(FSearch.Text) then
    LKind := hskSignature
  else
    LKind := hskHexBytes;
  FEditor.Search(FSearch.Text, LKind);
  Caption := Format('NimbusForms HexEditor  -  %d matches', [FEditor.SearchMatchCount]);
end;

procedure TMainForm.NextClick(Sender: TObject);
begin
  FEditor.FindNext;
end;

procedure TMainForm.ExportClick(Sender: TObject);
begin
  Clipboard.AsText := THexExporter.ToCSharpArray(FEditor.ReadAllBytes, 'rawData');
  Caption := 'NimbusForms HexEditor  -  C# array copied to clipboard';
end;

procedure TMainForm.ModifiedChange(Sender: TObject);
begin
  Caption := Format('NimbusForms HexEditor  -  %d modified bytes', [FEditor.GetModifiedCount]);
end;

procedure TMainForm.BookmarkClick(Sender: TObject);
begin
  FEditor.ToggleBookmark(FEditor.CursorPosition);
end;

procedure TMainForm.BookmarksChanged(Sender: TObject);
begin
  FBookmarkList.SetBookmarks(FEditor.Bookmarks);
end;

procedure TMainForm.BookmarkActivated(Sender: TObject; const AOffset: Int64);
begin
  FEditor.GotoOffset(AOffset);
  if FEditor.CanFocus then
    FEditor.SetFocus;
end;

procedure TMainForm.BookmarkRemove(Sender: TObject; const AOffset: Int64);
begin
  FEditor.ToggleBookmark(AOffset);
end;

var
  LForm: TMainForm;
begin
  Application.Initialize;
  Application.Title := 'NimbusForms HexEditor';
  LForm := TMainForm.CreateNew(nil);
  try
    LForm.ShowModal;
  finally
    LForm.Free;
  end;
end.

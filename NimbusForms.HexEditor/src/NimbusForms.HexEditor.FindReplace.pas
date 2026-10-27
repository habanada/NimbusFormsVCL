unit NimbusForms.HexEditor.FindReplace;

interface

uses
  System.Classes, System.SysUtils, Vcl.Forms, Vcl.Controls,
  NimbusForms.Theming.Palette, NimbusForms.Controls.TextBox, NimbusForms.Controls.ComboBox,
  NimbusForms.Controls.Button, NimbusForms.Controls.ThemedLabel, NimbusForms.HexEditor.Control;

type
  TThemedHexFindReplaceForm = class(TForm, IThemeAware)
  private
    FEditor: TCustomThemedHexEditor;
    FFind: TThemedTextBox;
    FReplacement: TThemedTextBox;
    FMode: TThemedComboBox;
    FStatus: TThemedLabel;
    FReplaceButton: TThemedButton;
    FNextButton: TThemedButton;
    FReplaceAllButton: TThemedButton;
    FLastPattern: string;
    function ReadBytes(const AText: string): TBytes;
    procedure CommandClick(Sender: TObject);
    procedure CloseForm(Sender: TObject; var Action: TCloseAction);
    procedure FindEnter(Sender: TObject);
    procedure ReplaceEnter(Sender: TObject);
    procedure DialogKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  public
    constructor CreateForEditor(const AEditor: TCustomThemedHexEditor);
    destructor Destroy; override;
    procedure Open(const AReplace: Boolean);
    procedure ApplyTheme(const APalette: TThemePalette);
  end;

implementation

uses
  Winapi.Windows, System.UITypes, Vcl.Graphics, Vcl.StdCtrls, NimbusForms.Theming.Types, NimbusForms.Theming.Manager,
  NimbusForms.Controls.Panel, NimbusForms.HexEditor.SearchService;

constructor TThemedHexFindReplaceForm.CreateForEditor(const AEditor: TCustomThemedHexEditor);
var
  LPanel: TThemedPanel;
  LLabel: TThemedLabel;
  LButton: TThemedButton;
  procedure AddButton(const ACaption: string; const ATag, AX: Integer; out AButton: TThemedButton);
  begin
    AButton := TThemedButton.Create(Self);
    AButton.Parent := LPanel;
    AButton.SetBounds(AX, 172, 120, 30);
    AButton.Caption := ACaption;
    AButton.Tag := ATag;
    AButton.OnClick := CommandClick;
  end;
begin
  inherited CreateNew(AEditor);
  FEditor := AEditor;
  BorderStyle := bsDialog;
  Position := poScreenCenter;
  ClientWidth := 550;
  ClientHeight := 258;
  OnClose := CloseForm;
  KeyPreview := True;
  OnKeyDown := DialogKeyDown;
  LPanel := TThemedPanel.Create(Self);
  LPanel.Parent := Self;
  LPanel.Align := alClient;
  LLabel := TThemedLabel.Create(Self);
  LLabel.Parent := LPanel;
  LLabel.SetBounds(16, 14, 100, 20);
  LLabel.Caption := 'Find';
  FFind := TThemedTextBox.Create(Self);
  FFind.Parent := LPanel;
  FFind.SetBounds(16, 36, 516, 30);
  FFind.Text := '4E 69 6D 62 75 73';
  FFind.OnEnterPressed := FindEnter;
  LLabel := TThemedLabel.Create(Self);
  LLabel.Parent := LPanel;
  LLabel.SetBounds(16, 76, 130, 20);
  LLabel.Caption := 'Replace with';
  FReplacement := TThemedTextBox.Create(Self);
  FReplacement.Parent := LPanel;
  FReplacement.SetBounds(16, 98, 516, 30);
  FReplacement.OnEnterPressed := ReplaceEnter;
  FMode := TThemedComboBox.Create(Self);
  FMode.Parent := LPanel;
  FMode.SetBounds(16, 136, 235, 28);
  FMode.Style := csDropDownList;
  FMode.Items.Add('Hex bytes');
  FMode.Items.Add('Text (editor encoding)');
  FMode.Items.Add('Pattern / signature');
  FMode.ItemIndex := 0;
  AddButton('Previous', 1, 16, LButton);
  AddButton('Find next', 2, 146, FNextButton);
  AddButton('Replace', 3, 276, FReplaceButton);
  AddButton('Replace all', 4, 406, FReplaceAllButton);
  FStatus := TThemedLabel.Create(Self);
  FStatus.Parent := LPanel;
  FStatus.AutoSize := False;
  FStatus.SetBounds(16, 216, 516, 28);
  ThemeManager.RegisterAware(Self);
end;

destructor TThemedHexFindReplaceForm.Destroy;
begin
  ThemeManager.UnregisterAware(Self);
  inherited Destroy;
end;

procedure TThemedHexFindReplaceForm.ApplyTheme(const APalette: TThemePalette);
begin
  if APalette = nil then Exit;
  Color := ThemeColorToColor(APalette.ControlBackColor);
  Font.Color := ThemeColorToColor(APalette.ControlForeColor);
end;

procedure TThemedHexFindReplaceForm.CloseForm(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TThemedHexFindReplaceForm.FindEnter(Sender: TObject);
begin
  CommandClick(FNextButton);
end;

procedure TThemedHexFindReplaceForm.ReplaceEnter(Sender: TObject);
begin
  if FReplaceButton.Enabled then CommandClick(FReplaceButton) else CommandClick(FNextButton);
end;

procedure TThemedHexFindReplaceForm.DialogKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Close;
    Key := 0;
  end;
end;

procedure TThemedHexFindReplaceForm.Open(const AReplace: Boolean);
begin
  if AReplace then Caption := 'Find and replace' else Caption := 'Find';
  FReplacement.Enabled := AReplace and (FEditor.DataSource <> nil) and
    FEditor.DataSource.CanWrite and not FEditor.Options.ReadOnly;
  FReplaceButton.Enabled := FReplacement.Enabled;
  FReplaceAllButton.Enabled := FReplacement.Enabled;
  Show;
  BringToFront;
  if FFind.CanFocus then FFind.SetFocus;
end;

function TThemedHexFindReplaceForm.ReadBytes(const AText: string): TBytes;
begin
  if FMode.ItemIndex = 1 then Result := FEditor.TextEncoding.GetBytes(AText)
  else if Trim(AText) = '' then Result := nil
  else if not THexSearchService.TryParseHexBytes(AText, Result) then
    raise EConvertError.Create('Enter complete hexadecimal bytes');
end;

procedure TThemedHexFindReplaceForm.CommandClick(Sender: TObject);
var
  LFind, LReplacement: TBytes;
  LFound: Boolean;
  LCommand: Integer;
begin
  try
    LCommand := TComponent(Sender).Tag;
    if FMode.ItemIndex = 2 then
    begin
      if LCommand >= 3 then raise EInvalidOperation.Create('Replace requires exact bytes or text');
      if (FLastPattern <> FFind.Text) or (FEditor.SearchMatchCount = 0) then
      begin
        FEditor.Search(FFind.Text, hskPattern);
        FLastPattern := FFind.Text;
        LFound := FEditor.SearchMatchCount > 0;
      end
      else if LCommand = 1 then LFound := FEditor.FindPrevious else LFound := FEditor.FindNext;
    end
    else
    begin
      FLastPattern := '';
      LFind := ReadBytes(FFind.Text);
      if Length(LFind) = 0 then raise EConvertError.Create('A search value is required');
      if LCommand = 4 then
      begin
        FStatus.Caption := Format('%d occurrences replaced', [FEditor.ReplaceAll(LFind, ReadBytes(FReplacement.Text))]);
        Exit;
      end;
      if LCommand = 3 then
      begin
        LReplacement := ReadBytes(FReplacement.Text);
        if not FEditor.ReplaceSelection(LFind, LReplacement) then
        begin
          FStatus.Caption := 'Find and select an occurrence before replacing';
          Exit;
        end;
      end;
      LFound := FEditor.FindBytes(LFind, LCommand <> 1);
    end;
    if LFound then FStatus.Caption := Format('Found at offset 0x%s', [IntToHex(FEditor.CursorPosition, 8)])
    else FStatus.Caption := 'No matching bytes found';
  except
    on E: Exception do FStatus.Caption := E.Message;
  end;
end;

end.

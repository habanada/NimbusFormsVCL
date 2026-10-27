program ThemingTest;

{$APPTYPE GUI}

uses
  Winapi.Windows,
  System.SysUtils,
  System.IOUtils,
  System.Classes,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Graphics,
  NimbusForms.Theming.Types in '..\src\NimbusForms.Theming.Types.pas',
  NimbusForms.Theming.Palette in '..\src\NimbusForms.Theming.Palette.pas',
  NimbusForms.Theming.Strings in '..\src\NimbusForms.Theming.Strings.pas',
  NimbusForms.Theming.WinVersion in '..\src\NimbusForms.Theming.WinVersion.pas',
  NimbusForms.Theming.Win32 in '..\src\NimbusForms.Theming.Win32.pas',
  NimbusForms.Theming.PresetFactory in '..\src\NimbusForms.Theming.PresetFactory.pas',
  NimbusForms.Theming.Serializer in '..\src\NimbusForms.Theming.Serializer.pas',
  NimbusForms.Theming.Presets in '..\src\NimbusForms.Theming.Presets.pas',
  NimbusForms.Theming.Manager in '..\src\NimbusForms.Theming.Manager.pas';

type
  TTestForm = class(TForm)
  private
    FCombo: TComboBox;
    FPrev: TButton;
    FNext: TButton;
    FRoundtrip: TButton;
    FSaveLoad: TButton;
    FInfo: TLabel;
    FDemoPanel: TPanel;
    FDemoLabel: TLabel;
    FDemoEdit: TEdit;
    FDemoMemo: TMemo;
    FDemoList: TListBox;
    FStatus: TMemo;
    procedure BuildUI;
    procedure Log(const AText: string);
    procedure ApplyByName(const AName: string);
    procedure ComboChange(Sender: TObject);
    procedure PrevClick(Sender: TObject);
    procedure NextClick(Sender: TObject);
    procedure RoundtripClick(Sender: TObject);
    procedure SaveLoadClick(Sender: TObject);
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
  end;

function ColorsEqual(const APalette, BPalette: TThemePalette): Boolean;
begin
  Result :=
    (APalette.IsDark = BPalette.IsDark) and
    (APalette.BackColor = BPalette.BackColor) and
    (APalette.ForeColor = BPalette.ForeColor) and
    (APalette.AccentColor = BPalette.AccentColor) and
    (APalette.InputBackColor = BPalette.InputBackColor) and
    (APalette.DockDropPreviewBackColor = BPalette.DockDropPreviewBackColor) and
    (APalette.DockDropPreviewBorderColor = BPalette.DockDropPreviewBorderColor);
end;

constructor TTestForm.CreateNew(AOwner: TComponent; Dummy: Integer);
begin
  inherited CreateNew(AOwner, Dummy);
  BuildUI;
end;

procedure TTestForm.BuildUI;
var
  LNames: TArray<string>;
  LName: string;
begin
  Caption := 'NimbusForms Theming Test';
  Width := 820;
  Height := 560;
  Position := poScreenCenter;
  Font.Name := 'Segoe UI';
  Font.Size := 9;

  FCombo := TComboBox.Create(Self);
  FCombo.Parent := Self;
  FCombo.Style := csDropDownList;
  FCombo.SetBounds(12, 12, 240, 24);
  FCombo.OnChange := ComboChange;

  FPrev := TButton.Create(Self);
  FPrev.Parent := Self;
  FPrev.SetBounds(262, 11, 90, 26);
  FPrev.Caption := 'Previous';
  FPrev.OnClick := PrevClick;

  FNext := TButton.Create(Self);
  FNext.Parent := Self;
  FNext.SetBounds(358, 11, 90, 26);
  FNext.Caption := 'Next';
  FNext.OnClick := NextClick;

  FRoundtrip := TButton.Create(Self);
  FRoundtrip.Parent := Self;
  FRoundtrip.SetBounds(460, 11, 160, 26);
  FRoundtrip.Caption := 'JSON Roundtrip (all)';
  FRoundtrip.OnClick := RoundtripClick;

  FSaveLoad := TButton.Create(Self);
  FSaveLoad.Parent := Self;
  FSaveLoad.SetBounds(628, 11, 160, 26);
  FSaveLoad.Caption := 'Save/Load File';
  FSaveLoad.OnClick := SaveLoadClick;

  FInfo := TLabel.Create(Self);
  FInfo.Parent := Self;
  FInfo.SetBounds(12, 46, 790, 18);
  FInfo.AutoSize := False;

  FDemoPanel := TPanel.Create(Self);
  FDemoPanel.Parent := Self;
  FDemoPanel.SetBounds(12, 72, 380, 220);
  FDemoPanel.Caption := '';
  FDemoPanel.BevelOuter := bvNone;

  FDemoLabel := TLabel.Create(Self);
  FDemoLabel.Parent := FDemoPanel;
  FDemoLabel.SetBounds(16, 16, 300, 18);
  FDemoLabel.Caption := 'Demo label on panel';

  FDemoEdit := TEdit.Create(Self);
  FDemoEdit.Parent := FDemoPanel;
  FDemoEdit.SetBounds(16, 44, 340, 24);
  FDemoEdit.Text := 'Edit control';

  FDemoMemo := TMemo.Create(Self);
  FDemoMemo.Parent := FDemoPanel;
  FDemoMemo.SetBounds(16, 76, 340, 60);
  FDemoMemo.Lines.Text := 'Memo line 1'#13#10'Memo line 2';

  FDemoList := TListBox.Create(Self);
  FDemoList.Parent := FDemoPanel;
  FDemoList.SetBounds(16, 144, 340, 60);
  FDemoList.Items.Add('List item A');
  FDemoList.Items.Add('List item B');
  FDemoList.Items.Add('List item C');

  FStatus := TMemo.Create(Self);
  FStatus.Parent := Self;
  FStatus.SetBounds(404, 72, 398, 450);
  FStatus.ReadOnly := True;
  FStatus.ScrollBars := ssVertical;
  FStatus.Font.Name := 'Consolas';
  FStatus.Font.Size := 9;

  LNames := TThemePresets.GetNames;
  for LName in LNames do
    FCombo.Items.Add(LName);

  Log(Format('Presets registered: %d', [Length(LNames)]));
  Log(Format('Windows 11 or later: %s', [BoolToStr(TWinVersion.IsWindows11OrLater, True)]));
  Log('');

  if FCombo.Items.Count > 0 then
  begin
    FCombo.ItemIndex := FCombo.Items.IndexOf(TThemePresets.DefaultThemeName);
    if FCombo.ItemIndex < 0 then
      FCombo.ItemIndex := 0;
    ApplyByName(FCombo.Text);
  end;
end;

procedure TTestForm.Log(const AText: string);
begin
  FStatus.Lines.Add(AText);
end;

procedure TTestForm.ApplyByName(const AName: string);
var
  LPalette: TThemePalette;
begin
  LPalette := TThemePresets.GetByName(AName);
  if LPalette = nil then
  begin
    Log('FAILED GetByName: ' + AName);
    Exit;
  end;
  try
    ThemeManager.ApplyGlobal(LPalette);
  finally
    LPalette.Free;
  end;
  FInfo.Caption := Format('Active: %s   IsDark=%s   Accent=#%s',
    [AName, BoolToStr(ThemeManager.CurrentTheme.IsDark, True),
     IntToHex(Cardinal(ThemeManager.CurrentTheme.AccentColor), 8)]);
end;

procedure TTestForm.ComboChange(Sender: TObject);
begin
  ApplyByName(FCombo.Text);
end;

procedure TTestForm.PrevClick(Sender: TObject);
var
  LName: string;
begin
  LName := TThemePresets.GetPreviousName(FCombo.Text);
  FCombo.ItemIndex := FCombo.Items.IndexOf(LName);
  ApplyByName(LName);
end;

procedure TTestForm.NextClick(Sender: TObject);
var
  LName: string;
begin
  LName := TThemePresets.GetNextName(FCombo.Text);
  FCombo.ItemIndex := FCombo.Items.IndexOf(LName);
  ApplyByName(LName);
end;

procedure TTestForm.RoundtripClick(Sender: TObject);
var
  LNames: TArray<string>;
  LName, LJson: string;
  LOriginal, LRestored: TThemePalette;
  LOk, LFail: Integer;
begin
  LOk := 0;
  LFail := 0;
  LNames := TThemePresets.GetNames;
  for LName in LNames do
  begin
    LOriginal := TThemePresets.GetByName(LName);
    if LOriginal = nil then
    begin
      Inc(LFail);
      Continue;
    end;
    try
      LJson := TThemePaletteSerializer.ToJson(LName, LOriginal);
      LRestored := TThemePaletteSerializer.FromJson(LJson);
      try
        if (LRestored <> nil) and ColorsEqual(LOriginal, LRestored) then
          Inc(LOk)
        else
        begin
          Inc(LFail);
          Log('Roundtrip MISMATCH: ' + LName);
        end;
      finally
        LRestored.Free;
      end;
    finally
      LOriginal.Free;
    end;
  end;
  Log(Format('JSON roundtrip: %d OK, %d FAIL', [LOk, LFail]));
end;

procedure TTestForm.SaveLoadClick(Sender: TObject);
var
  LDir, LFile, LLoadedName: string;
  LOriginal, LLoaded: TThemePalette;
begin
  LDir := TPath.Combine(TPath.GetTempPath, 'NimbusThemeTest');
  LOriginal := TThemePresets.GetByName(FCombo.Text);
  if LOriginal = nil then
    Exit;
  try
    if TThemePresets.SaveCustomTheme(LDir, 'RoundtripTheme', LOriginal) then
      Log('SaveCustomTheme OK -> ' + LDir)
    else
    begin
      Log('SaveCustomTheme FAILED');
      Exit;
    end;
  finally
    LOriginal.Free;
  end;

  LFile := TPath.Combine(LDir, 'RoundtripTheme.json');
  if not TFile.Exists(LFile) then
  begin
    Log('File not found: ' + LFile);
    Exit;
  end;

  if TThemePaletteSerializer.LoadName(LFile, LLoadedName) then
    Log('LoadName OK: ' + LLoadedName)
  else
    Log('LoadName FAILED');

  LLoaded := TThemePaletteSerializer.LoadFromFile(LFile);
  try
    if LLoaded <> nil then
      Log('LoadFromFile OK, IsDark=' + BoolToStr(LLoaded.IsDark, True))
    else
      Log('LoadFromFile FAILED');
  finally
    LLoaded.Free;
  end;

  if TThemePresets.Contains('RoundtripTheme') then
    Log('Registered as custom theme OK');
  Log('Custom themes now: ' + IntToStr(Length(TThemePresets.GetCustom)));
end;

var
  LForm: TTestForm;
begin
  Application.Initialize;
  Application.Title := 'NimbusForms Theming Test';
  LForm := TTestForm.CreateNew(nil);
  try
    LForm.Position := poScreenCenter;
    LForm.ShowModal;
  finally
    LForm.Free;
  end;
end.

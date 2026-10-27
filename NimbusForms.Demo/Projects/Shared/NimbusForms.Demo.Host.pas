{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Demo.Host;

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
  NimbusForms.Theming.Presets,
  NimbusForms.Theming.Manager,
  NimbusForms.Controls.Button,
  NimbusForms.Controls.Panel,
  NimbusForms.Controls.ThemedLabel,
  NimbusForms.Controls.ComboBox,
  NimbusForms.Controls.TextBox;

type
  TDemoHostForm = class(TForm, IThemeAware)
  private
    FThemeCombo: TThemedComboBox;
    FBody: TThemedPanel;
    procedure ThemeChanged(Sender: TObject);
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette);
    property Body: TThemedPanel read FBody;
  end;

function DemoQuestion(const Title, Text: string): TModalResult;
function DemoInputQuery(const Title, Prompt: string; var Value: string): Boolean;

implementation

resourcestring
  SSave = 'Save';
  SDiscard = 'Discard';
  SCancel = 'Cancel';
  SOk = 'OK';

constructor TDemoHostForm.CreateNew(AOwner: TComponent; Dummy: Integer);
var Bar: TThemedPanel; Title: TThemedLabel; Name, Directory: string;
begin
  inherited CreateNew(AOwner, Dummy);
  Caption := Application.Title; Position := poScreenCenter; Scaled := True; DoubleBuffered := True;
  ClientWidth := 1280; ClientHeight := 850; Constraints.MinWidth := 960; Constraints.MinHeight := 640;
  Bar := TThemedPanel.Create(Self); Bar.Parent := Self; Bar.Align := alTop; Bar.Height := 52; Bar.ShowBorder := False;
  Bar.Padding.Left := 12; Bar.Padding.Top := 8; Bar.Padding.Right := 12; Bar.Padding.Bottom := 8;
  FThemeCombo := TThemedComboBox.Create(Self); FThemeCombo.Parent := Bar; FThemeCombo.Align := alRight; FThemeCombo.Width := 260; FThemeCombo.Style := csDropDownList;
  Directory := TPath.Combine(ExtractFilePath(ParamStr(0)), 'Palettes');
  if TDirectory.Exists(Directory) then TThemePresets.LoadFromDirectory(Directory);
  for Name in TThemePresets.GetNames do FThemeCombo.Items.Add(Name);
  FThemeCombo.ItemIndex := FThemeCombo.Items.IndexOf('Dark');
  if (FThemeCombo.ItemIndex < 0) and (FThemeCombo.Items.Count > 0) then FThemeCombo.ItemIndex := 0;
  FThemeCombo.OnChange := ThemeChanged;
  Title := TThemedLabel.Create(Self); Title.Parent := Bar; Title.Align := alClient; Title.AutoSize := False; Title.Layout := tlCenter; Title.Font.Style := [fsBold]; Title.Caption := Caption;
  FBody := TThemedPanel.Create(Self); FBody.Parent := Self; FBody.Align := alClient; FBody.ShowBorder := False;
  ThemeManager.RegisterAware(Self); ThemeChanged(Self);
end;

destructor TDemoHostForm.Destroy;
begin ThemeManager.UnregisterAware(Self); inherited; end;

procedure TDemoHostForm.ThemeChanged(Sender: TObject);
begin
  if FThemeCombo.ItemIndex < 0 then Exit;
  if ThemeManager.SetThemeByName(FThemeCombo.Items[FThemeCombo.ItemIndex]) then ThemeManager.ApplyCurrent(Self);
end;

procedure TDemoHostForm.ApplyTheme(const APalette: TThemePalette);
begin
  if APalette = nil then Exit;
  Color := ThemeColorToColor(APalette.ControlBackColor); Font.Color := ThemeColorToColor(APalette.ControlForeColor);
end;

function DemoQuestion(const Title, Text: string): TModalResult;
var Dialog: TForm; Surface: TThemedPanel; LabelControl: TThemedLabel; Button: TThemedButton; I: Integer;
begin
  Dialog := TForm.CreateNew(nil);
  try
    Dialog.Caption := Title; Dialog.Position := poScreenCenter; Dialog.BorderStyle := bsDialog; Dialog.ClientWidth := 480; Dialog.ClientHeight := 190;
    Surface := TThemedPanel.Create(Dialog); Surface.Parent := Dialog; Surface.Align := alClient;
    LabelControl := TThemedLabel.Create(Dialog); LabelControl.Parent := Surface; LabelControl.SetBounds(18, 18, 440, 100); LabelControl.AutoSize := False; LabelControl.WordWrap := True; LabelControl.Caption := Text;
    for I := 0 to 2 do
    begin
      Button := TThemedButton.Create(Dialog); Button.Parent := Surface; Button.SetBounds(142 + I * 106, 142, 96, 30);
      case I of
        0: begin Button.Caption := SSave; Button.ModalResult := mrYes; Button.Default := True; end;
        1: begin Button.Caption := SDiscard; Button.ModalResult := mrNo; end;
        2: begin Button.Caption := SCancel; Button.ModalResult := mrCancel; Button.Cancel := True; end;
      end;
    end;
    ThemeManager.ApplyCurrent(Dialog); Result := Dialog.ShowModal;
  finally Dialog.Free; end;
end;

function DemoInputQuery(const Title, Prompt: string; var Value: string): Boolean;
var Dialog: TForm; Surface: TThemedPanel; LabelControl: TThemedLabel; Input: TThemedTextBox; Button: TThemedButton;
begin
  Dialog := TForm.CreateNew(nil);
  try
    Dialog.Caption := Title; Dialog.Position := poScreenCenter; Dialog.BorderStyle := bsDialog; Dialog.ClientWidth := 480; Dialog.ClientHeight := 170;
    Surface := TThemedPanel.Create(Dialog); Surface.Parent := Dialog; Surface.Align := alClient;
    LabelControl := TThemedLabel.Create(Dialog); LabelControl.Parent := Surface; LabelControl.SetBounds(18, 16, 440, 36); LabelControl.AutoSize := False; LabelControl.WordWrap := True; LabelControl.Caption := Prompt;
    Input := TThemedTextBox.Create(Dialog); Input.Parent := Surface; Input.SetBounds(18, 62, 440, 32); Input.Text := Value;
    Button := TThemedButton.Create(Dialog); Button.Parent := Surface; Button.SetBounds(254, 120, 96, 30); Button.Caption := SOk; Button.ModalResult := mrOk; Button.Default := True;
    Button := TThemedButton.Create(Dialog); Button.Parent := Surface; Button.SetBounds(362, 120, 96, 30); Button.Caption := SCancel; Button.ModalResult := mrCancel; Button.Cancel := True;
    Dialog.ActiveControl := Input; ThemeManager.ApplyCurrent(Dialog); Result := Dialog.ShowModal = mrOk;
    if Result then Value := Input.Text;
  finally Dialog.Free; end;
end;

end.

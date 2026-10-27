{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Demo.Standard;

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
  NimbusForms.Controls.Button,
  NimbusForms.Controls.ToolButton,
  NimbusForms.Controls.ToolBar,
  NimbusForms.Controls.MenuBar,
  NimbusForms.Controls.IdeStatusBar,
  NimbusForms.Controls.BreadcrumbBar,
  NimbusForms.Controls.TagInput,
  NimbusForms.Controls.Splitter,
  NimbusForms.Rendering.BadgeLabel,
  NimbusForms.Controls.ToolTip,
  NimbusForms.Controls.Panel,
  NimbusForms.Controls.CheckBox,
  NimbusForms.Controls.ToggleBox,
  NimbusForms.Controls.ThemedLabel,
  NimbusForms.Controls.RadioButton,
  NimbusForms.Controls.ProgressBar,
  NimbusForms.Controls.RichEdit,
  NimbusForms.Controls.ComboBox,
  NimbusForms.Controls.ListBox,
  NimbusForms.Controls.TrackBar,
  NimbusForms.Controls.TextBox,
  NimbusForms.Controls.NumericUpDown,
  NimbusForms.Controls.Rating,
  NimbusForms.Controls.TabControl,
  NimbusForms.Controls.TreeView,
  NimbusForms.Controls.DatePicker,
  NimbusForms.Controls.DateRange,
  NimbusForms.Controls.IdeColorPicker,
  NimbusForms.Menus.PopupMenu,
  NimbusForms.Demo.Host,
  NimbusForms.Demo.Avatars;

type
  TStandardDemoForm = class(TDemoHostForm)
  private
    FStatus: TThemedLabel;
    FProgress: TThemedProgressBar;
    procedure Command(Sender: TObject);
    procedure Changed(Sender: TObject);
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
  end;

implementation

resourcestring
  SButtons = 'Buttons and states';
  SInputs = 'Text and choices';
  SLayout = 'Tree and splitters';
  SAction = 'Action %d';
  SCheck = 'Three-state check box';
  SToggle = 'Toggle state';
  SRadio = 'Radio option %d';
  SChanged = 'State changed: %s';
  SClicked = 'Button command %d';
  SPlaceholder = 'Type here; use the clear button';
  SRichText = 'NimbusForms rich text editor. Select text, edit and use the clipboard.';
  STreeRoot = 'NimbusForms controls';
  SSplitText = 'Drag the standalone splitters. Escape restores the original size.';
  SOutput = 'Output panel';
  SMore = 'Navigation, colors and ranges';
  STools = 'Menus and toolbars';
  SColorHint = 'Select a theme-aware color';
  SChoices = 'Ready'#13#10'Working'#13#10'Complete';

constructor TStandardDemoForm.CreateNew(AOwner: TComponent; Dummy: Integer);
var Tabs: TThemedTabControl; Panel, Client, Output: TThemedPanel; Button: TThemedButton;
  Check: TThemedCheckBox; Toggle: TThemedToggleBox; Radio: TThemedRadioButton; TextBox: TThemedTextBox;
  Combo: TThemedComboBox; List: TThemedListBox; Rich: TThemedRichEdit; Tree: TThemedTreeView;
  Splitter: TThemedSplitter; LabelControl: TThemedLabel; DatePicker: TThemedDatePicker;
  Number: TThemedNumericUpDown; I: Integer; Root: TTreeNode; Track: TThemedTrackBar;
  Rating: TThemedRatingControl; Breadcrumb: TThemedBreadcrumbBar; Tags: TThemedTagInput;
  DateRange: TThemedDateRangePicker; ColorPicker: TThemedIdeColorPickerButton; ToolTip: TThemedToolTip;
  Tools: TThemedToolBar; ToolButton: TThemedToolButton; MenuBar: TThemedMenuBar; Menu: TThemedPopupMenu; Item: TMenuItem;
  function Page(const Title: string): TThemedPanel;
  var Tab: TTabSheet;
  begin
    Tab := TTabSheet.Create(Tabs); Tab.PageControl := Tabs; Tab.Caption := Title;
    Result := TThemedPanel.Create(Tab); Result.Parent := Tab; Result.Align := alClient;
  end;
begin
  inherited;
  FStatus := TThemedLabel.Create(Self); FStatus.Parent := Body; FStatus.Align := alBottom; FStatus.AutoSize := False; FStatus.Height := 28;
  Tabs := TThemedTabControl.Create(Self); Tabs.Parent := Body; Tabs.Align := alClient;
  Panel := Page(SButtons);
  for I := 0 to 3 do
  begin
    Button := TThemedButton.Create(Self); Button.Parent := Panel; Button.SetBounds(20 + I * 180, 20, 160, 36);
    Button.Caption := Format(SAction, [I + 1]); Button.Tag := I + 1; Button.OnClick := Command;
    case I of
      1: Button.ButtonKind := NimbusForms.Controls.Types.tbkPrimary;
      2: Button.ButtonKind := NimbusForms.Controls.Types.tbkSuccess;
      3: Button.ButtonKind := NimbusForms.Controls.Types.tbkGhost;
    end;
  end;
  Check := TThemedCheckBox.Create(Self); Check.Parent := Panel; Check.SetBounds(20, 85, 300, 28); Check.Caption := SCheck; Check.AllowGrayed := True; Check.OnCheckedChanged := Changed;
  Toggle := TThemedToggleBox.Create(Self); Toggle.Parent := Panel; Toggle.SetBounds(20, 135, 300, 28); Toggle.Caption := SToggle; Toggle.OnCheckedChanged := Changed;
  for I := 0 to 1 do
  begin
    Radio := TThemedRadioButton.Create(Self); Radio.Parent := Panel; Radio.SetBounds(20, 185 + I * 42, 300, 28); Radio.Caption := Format(SRadio, [I + 1]); Radio.OnCheckedChanged := Changed;
  end;
  FProgress := TThemedProgressBar.Create(Self); FProgress.Parent := Panel; FProgress.SetBounds(20, 300, 500, 28); FProgress.ShowPercentage := True; FProgress.Position := 35;
  Track := TThemedTrackBar.Create(Self); Track.Parent := Panel; Track.SetBounds(20, 350, 500, 30); Track.Value := 35; Track.OnValueChanged := Changed;
  Rating := TThemedRatingControl.Create(Self); Rating.Parent := Panel; Rating.SetBounds(20, 410, 260, 34); Rating.RatingValue := 3.5; Rating.ShowValueText := True; Rating.OnValueChanged := Changed;
  Panel := Page(SInputs);
  TextBox := TThemedTextBox.Create(Self); TextBox.Parent := Panel; TextBox.SetBounds(20, 20, 480, 32); TextBox.PlaceholderText := SPlaceholder; TextBox.OnChange := Changed;
  Combo := TThemedComboBox.Create(Self); Combo.Parent := Panel; Combo.SetBounds(20, 80, 220, 32); Combo.Style := csDropDownList; Combo.Items.Text := SChoices; Combo.ItemIndex := 0; Combo.OnChange := Changed;
  List := TThemedListBox.Create(Self); List.Parent := Panel; List.SetBounds(20, 140, 220, 220); List.Items.Assign(Combo.Items); List.OnClick := Changed;
  Number := TThemedNumericUpDown.Create(Self); Number.Parent := Panel; Number.SetBounds(270, 80, 230, 32);
  DatePicker := TThemedDatePicker.Create(Self); DatePicker.Parent := Panel; DatePicker.SetBounds(270, 140, 300, 32);
  Rich := TThemedRichEdit.Create(Self); Rich.Parent := Panel; Rich.SetBounds(270, 200, 650, 300); Rich.Lines.Text := SRichText;
  Panel := Page(SLayout); Panel.DisableAlign;
  try
    Tree := TThemedTreeView.Create(Self); Tree.Parent := Panel; Tree.Align := alLeft; Tree.Width := 260; Tree.Left := 0;
    Root := Tree.Items.Add(nil, STreeRoot); Tree.Items.AddChild(Root, SButtons); Tree.Items.AddChild(Root, SInputs); Root.Expand(False);
    Splitter := TThemedSplitter.Create(Self); Splitter.Parent := Panel; Splitter.Left := 260; Splitter.ResizeControl := Tree;
    Client := TThemedPanel.Create(Self); Client.Parent := Panel; Client.Align := alClient;
  finally Panel.EnableAlign; end;
  Client.DisableAlign;
  try
    Output := TThemedPanel.Create(Self); Output.Parent := Client; Output.Align := alBottom; Output.Height := 150; Output.Top := 1000;
    Splitter := TThemedSplitter.Create(Self); Splitter.Parent := Client; Splitter.Align := alBottom; Splitter.Top := 900; Splitter.ResizeControl := Output;
    LabelControl := TThemedLabel.Create(Self); LabelControl.Parent := Client; LabelControl.Align := alClient; LabelControl.AutoSize := False; LabelControl.Caption := SSplitText;
    LabelControl := TThemedLabel.Create(Self); LabelControl.Parent := Output; LabelControl.Align := alClient; LabelControl.AutoSize := False; LabelControl.Caption := SOutput;
  finally Client.EnableAlign; end;
  Panel := Page(SMore);
  Breadcrumb := TThemedBreadcrumbBar.Create(Self); Breadcrumb.Parent := Panel; Breadcrumb.SetBounds(20, 20, 800, 36); Breadcrumb.Path := 'Projects\NimbusForms\Controls';
  Tags := TThemedTagInput.Create(Self); Tags.Parent := Panel; Tags.SetBounds(20, 90, 700, 38); Tags.AddTag('NimbusForms'); Tags.AddTag('Delphi'); Tags.AddTag('VCL'); Tags.OnTagsChanged := Changed;
  DateRange := TThemedDateRangePicker.Create(Self); DateRange.Parent := Panel; DateRange.SetBounds(20, 165, 500, 36);
  ColorPicker := TThemedIdeColorPickerButton.Create(Self); ColorPicker.Parent := Panel; ColorPicker.SetBounds(20, 240, 280, 36);
  ToolTip := TThemedToolTip.Create(Self); ToolTip.SetToolTip(ColorPicker, SColorHint);
  Panel := Page(STools);
  Menu := TThemedPopupMenu.Create(Self);
  for I := 0 to 3 do
  begin Item := TMenuItem.Create(Menu); Item.Caption := Format(SAction, [I + 1]); Item.Tag := I + 1; Item.OnClick := Command; Menu.Items.Add(Item); end;
  MenuBar := TThemedMenuBar.Create(Self); MenuBar.Parent := Panel; MenuBar.Align := alTop; MenuBar.Height := 30;
  MenuBar.LeftItems.Add.Caption := SButtons; MenuBar.LeftItems[0].DropDownMenu := Menu;
  Tools := TThemedToolBar.Create(Self); Tools.Parent := Panel; Tools.Top := 32; Tools.Align := alTop; Tools.AutoSize := True; Tools.ShowOverflow := True;
  for I := 0 to 9 do
  begin
    ToolButton := TThemedToolButton.Create(Tools); ToolButton.Parent := Tools; ToolButton.AutoSize := True;
    ToolButton.Caption := Format(SAction, [I + 1]); ToolButton.Tag := I + 1; ToolButton.OnClick := Command;
  end;
  AddNimbusAvatarDemo(Tabs);
end;

procedure TStandardDemoForm.Command(Sender: TObject);
begin FProgress.Position := (FProgress.Position + 15) mod 101; FStatus.Caption := Format(SClicked, [TComponent(Sender).Tag]); end;
procedure TStandardDemoForm.Changed(Sender: TObject);
begin if Sender is TThemedTrackBar then FProgress.Position := TThemedTrackBar(Sender).Value; FStatus.Caption := Format(SChanged, [Sender.ClassName]); end;

end.

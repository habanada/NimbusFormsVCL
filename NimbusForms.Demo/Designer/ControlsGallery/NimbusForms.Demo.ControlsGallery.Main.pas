unit NimbusForms.Demo.ControlsGallery.Main;

interface

uses
  System.Classes, System.SysUtils, System.IOUtils,
  Vcl.Forms, Vcl.Controls, Vcl.ComCtrls,
  NimbusForms.Theming.Manager, NimbusForms.Theming.Presets,
  NimbusForms.Controls.Button, NimbusForms.Controls.CheckBox, NimbusForms.Controls.ToggleBox,
  NimbusForms.Controls.TabControl, NimbusForms.Controls.Panel, NimbusForms.Controls.GroupBox, NimbusForms.Controls.ThemedLabel,
  NimbusForms.Controls.TextBox, NimbusForms.Controls.ComboBox, NimbusForms.Controls.NumericUpDown,
  NimbusForms.Controls.Rating, NimbusForms.Controls.ProgressBar, NimbusForms.Controls.DatePicker;

type
  TControlsGalleryForm = class(TForm)
    pnlHeader: TThemedPanel;
    lblTitle: TThemedLabel;
    cmbTheme: TThemedComboBox;
    Pages: TThemedTabControl;
    tabButtons: TTabSheet;
    grpButtonStates: TThemedGroupBox;
    btnPrimary: TThemedButton;
    btnToggleEnabled: TThemedButton;
    btnCheckable: TThemedButton;
    btnReset: TThemedButton;
    chkEnabled: TThemedCheckBox;
    toggleActive: TThemedToggleBox;
    tabInputs: TTabSheet;
    grpText: TThemedGroupBox;
    lblName: TThemedLabel;
    txtName: TThemedTextBox;
    lblDepartment: TThemedLabel;
    cmbDepartment: TThemedComboBox;
    lblQuantity: TThemedLabel;
    numQuantity: TThemedNumericUpDown;
    grpDates: TThemedGroupBox;
    lblDeadline: TThemedLabel;
    dateDeadline: TThemedDatePicker;
    tabFeedback: TTabSheet;
    grpRating: TThemedGroupBox;
    rating: TThemedRatingControl;
    lblRating: TThemedLabel;
    grpProgress: TThemedGroupBox;
    progress: TThemedProgressBar;
    btnProgress: TThemedButton;
    btnClearProgress: TThemedButton;
    lblProgress: TThemedLabel;
    pnlFooter: TThemedPanel;
    lblEvents: TThemedLabel;
    procedure FormCreate(Sender: TObject);
    procedure ThemeChanged(Sender: TObject);
    procedure ButtonClicked(Sender: TObject);
    procedure ValueChanged(Sender: TObject);
  private
    procedure Report(const AText: string);
  end;

var
  ControlsGalleryForm: TControlsGalleryForm;

implementation

{$R *.dfm}

resourcestring
  SReady = 'Select a control and change its state. All page contents are saved in the text DFM.';

procedure TControlsGalleryForm.Report(const AText: string);
begin
  lblEvents.Caption := AText;
end;

procedure TControlsGalleryForm.FormCreate(Sender: TObject);
var Name, Directory: string;
begin
  Directory := TPath.Combine(ExtractFilePath(ParamStr(0)), 'Palettes');
  if TDirectory.Exists(Directory) then TThemePresets.LoadFromDirectory(Directory);
  for Name in TThemePresets.GetNames do cmbTheme.Items.Add(Name);
  cmbTheme.ItemIndex := cmbTheme.Items.IndexOf('Dark');
  if (cmbTheme.ItemIndex < 0) and (cmbTheme.Items.Count > 0) then cmbTheme.ItemIndex := 0;
  cmbDepartment.Items.Add('Engineering'); cmbDepartment.Items.Add('Design'); cmbDepartment.Items.Add('QA'); cmbDepartment.Items.Add('Operations');
  cmbDepartment.ItemIndex := 0;
  dateDeadline.Value := Date + 14;
  ThemeChanged(cmbTheme);
  Report(SReady);
end;

procedure TControlsGalleryForm.ThemeChanged(Sender: TObject);
begin
  if cmbTheme.ItemIndex < 0 then Exit;
  if ThemeManager.SetThemeByName(cmbTheme.Items[cmbTheme.ItemIndex]) then ThemeManager.ApplyCurrent(Self);
end;

procedure TControlsGalleryForm.ButtonClicked(Sender: TObject);
begin
  if Sender = btnPrimary then Report('Primary button clicked')
  else if Sender = btnToggleEnabled then begin chkEnabled.Checked := not chkEnabled.Checked; Report('Checkbox changed from button'); end
  else if Sender = btnCheckable then Report(Format('Checkable button: %s', [BoolToStr(btnCheckable.Checked, True)]))
  else if Sender = btnReset then
  begin
    chkEnabled.Checked := True; toggleActive.Checked := False; btnCheckable.Checked := False;
    txtName.Text := 'Nimbus User'; cmbDepartment.ItemIndex := 0; numQuantity.Value := 25;
    rating.RatingValue := 3.5; progress.Position := 45; Report('Demo controls reset');
  end
  else if Sender = btnProgress then begin progress.StepBy(10); Report(Format('Progress: %d%%', [progress.Position])); end
  else if Sender = btnClearProgress then begin progress.Position := 0; Report('Progress reset'); end;
end;

procedure TControlsGalleryForm.ValueChanged(Sender: TObject);
begin
  if Sender = chkEnabled then Report(Format('Checkbox enabled: %s', [BoolToStr(chkEnabled.Checked, True)]))
  else if Sender = toggleActive then Report(Format('Toggle active: %s', [BoolToStr(toggleActive.Checked, True)]))
  else if Sender = txtName then Report('Name: ' + txtName.Text)
  else if Sender = cmbDepartment then Report('Department: ' + cmbDepartment.Text)
  else if Sender = numQuantity then Report(Format('Quantity: %.0f', [numQuantity.Value]))
  else if Sender = dateDeadline then Report('Deadline: ' + DateToStr(dateDeadline.Value))
  else if Sender = rating then Report(Format('Rating: %.1f / %d', [rating.RatingValue, rating.Maximum]));
end;

end.

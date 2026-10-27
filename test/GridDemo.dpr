program GridDemo;

{$APPTYPE GUI}

uses
  Winapi.Windows,
  System.SysUtils,
  System.Types,
  System.Classes,
  System.Rtti,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.Graphics,
  NimbusForms.Theming.Types in '..\NimbusForms.Theming\src\NimbusForms.Theming.Types.pas',
  NimbusForms.Theming.Palette in '..\NimbusForms.Theming\src\NimbusForms.Theming.Palette.pas',
  NimbusForms.Theming.Strings in '..\NimbusForms.Theming\src\NimbusForms.Theming.Strings.pas',
  NimbusForms.Theming.WinVersion in '..\NimbusForms.Theming\src\NimbusForms.Theming.WinVersion.pas',
  NimbusForms.Theming.Win32 in '..\NimbusForms.Theming\src\NimbusForms.Theming.Win32.pas',
  NimbusForms.Theming.PresetFactory in '..\NimbusForms.Theming\src\NimbusForms.Theming.PresetFactory.pas',
  NimbusForms.Theming.Serializer in '..\NimbusForms.Theming\src\NimbusForms.Theming.Serializer.pas',
  NimbusForms.Theming.Presets in '..\NimbusForms.Theming\src\NimbusForms.Theming.Presets.pas',
  NimbusForms.Theming.Manager in '..\NimbusForms.Theming\src\NimbusForms.Theming.Manager.pas',
  NimbusForms.Grid.Cell in '..\NimbusForms.Grid\src\NimbusForms.Grid.Cell.pas',
  NimbusForms.Grid.CellMetadata in '..\NimbusForms.Grid\src\NimbusForms.Grid.CellMetadata.pas',
  NimbusForms.Grid.CellRenderer in '..\NimbusForms.Grid\src\NimbusForms.Grid.CellRenderer.pas',
  NimbusForms.Grid.CellRendererIntf in '..\NimbusForms.Grid\src\NimbusForms.Grid.CellRendererIntf.pas',
  NimbusForms.Grid.CellRendererParts in '..\NimbusForms.Grid\src\NimbusForms.Grid.CellRendererParts.pas',
  NimbusForms.Grid.CellRenderers in '..\NimbusForms.Grid\src\NimbusForms.Grid.CellRenderers.pas',
  NimbusForms.Grid.CellRenderers.Content in '..\NimbusForms.Grid\src\NimbusForms.Grid.CellRenderers.Content.pas',
  NimbusForms.Grid.CellRenderers.Input in '..\NimbusForms.Grid\src\NimbusForms.Grid.CellRenderers.Input.pas',
  NimbusForms.Grid.CellRenderers.Visual in '..\NimbusForms.Grid\src\NimbusForms.Grid.CellRenderers.Visual.pas',
  NimbusForms.Grid.ColorValue in '..\NimbusForms.Grid\src\NimbusForms.Grid.ColorValue.pas',
  NimbusForms.Grid.Column in '..\NimbusForms.Grid\src\NimbusForms.Grid.Column.pas',
  NimbusForms.Grid.ColumnBand in '..\NimbusForms.Grid\src\NimbusForms.Grid.ColumnBand.pas',
  NimbusForms.Grid.ValueFormatter in '..\NimbusForms.Grid\src\NimbusForms.Grid.ValueFormatter.pas',
  NimbusForms.Grid.VisualImage in '..\NimbusForms.Grid\src\NimbusForms.Grid.VisualImage.pas',
  NimbusForms.Grid.VisualImageRenderer in '..\NimbusForms.Grid\src\NimbusForms.Grid.VisualImageRenderer.pas',
  NimbusForms.Grid.VisualStrings in '..\NimbusForms.Grid\src\NimbusForms.Grid.VisualStrings.pas',
  NimbusForms.Grid.CellVisual in '..\NimbusForms.Grid\src\NimbusForms.Grid.CellVisual.pas',
  NimbusForms.Grid.CellVisualRenderer in '..\NimbusForms.Grid\src\NimbusForms.Grid.CellVisualRenderer.pas',
  NimbusForms.Grid.ClipboardExporter in '..\NimbusForms.Grid\src\NimbusForms.Grid.ClipboardExporter.pas',
  NimbusForms.Grid.ClipboardOptions in '..\NimbusForms.Grid\src\NimbusForms.Grid.ClipboardOptions.pas',
  NimbusForms.Grid.ClipboardParser in '..\NimbusForms.Grid\src\NimbusForms.Grid.ClipboardParser.pas';

type
  TMainForm = class(TForm)
  private
    FView: TThemedGridSimpleView;
    procedure BuildColumns;
    procedure BuildRows;
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
  end;

constructor TMainForm.CreateNew(AOwner: TComponent; Dummy: Integer);
var
  LPalette: TThemePalette;
begin
  inherited CreateNew(AOwner, Dummy);
  Caption := 'NimbusForms Grid Demo';
  Width := 820;
  Height := 460;
  Position := poScreenCenter;

  FView := TThemedGridSimpleView.Create(Self);
  FView.Parent := Self;
  FView.Align := alClient;

  BuildColumns;
  BuildRows;

  LPalette := TThemePresets.GetByName('Dark');
  try
    ThemeManager.ApplyGlobal(LPalette);
    FView.SetPalette(ThemeManager.CurrentTheme);
  finally
    LPalette.Free;
  end;
end;

procedure TMainForm.BuildColumns;
var
  LColumn: TThemedGridColumn;
begin
  FView.Columns.AddText('Name', 'Name', 'Name').Width := 150;

  LColumn := FView.Columns.AddNumber('Age', 'Age', '0');
  LColumn.Width := 70;

  LColumn := FView.Columns.AddCheck('Active', 'Active');
  LColumn.HeaderText := 'Active';
  LColumn.Width := 80;

  LColumn := FView.Columns.Add('Progress', 'Progress', 'Progress');
  LColumn.RenderKind := TThemedGridCellRenderKind.ProgressBar;
  LColumn.EditorOptions.SetRange(0, 100);
  LColumn.Width := 140;

  LColumn := FView.Columns.Add('Rating', 'Rating', 'Rating');
  LColumn.RenderKind := TThemedGridCellRenderKind.Rating;
  LColumn.EditorOptions.Maximum := 5;
  LColumn.Width := 120;

  LColumn := FView.Columns.Add('Status', 'Status', 'Status');
  LColumn.RenderKind := TThemedGridCellRenderKind.Badge;
  LColumn.Width := 110;

  LColumn := FView.Columns.Add('Color', 'Color', 'Color');
  LColumn.RenderKind := TThemedGridCellRenderKind.ColorSwatch;
  LColumn.Width := 130;
end;

procedure TMainForm.BuildRows;
begin
  FView.AddRow([TValue.From<string>('Alice Weber'), TValue.From<Integer>(34),
    TValue.From<Boolean>(True), TValue.From<Integer>(75), TValue.From<Integer>(4),
    TValue.From<string>('Active'), TValue.From<TThemeColor>(ThemeColor(255, 86, 156, 214))]);
  FView.AddRow([TValue.From<string>('Bob Schmidt'), TValue.From<Integer>(28),
    TValue.From<Boolean>(False), TValue.From<Integer>(40), TValue.From<Integer>(2),
    TValue.From<string>('Blocked'), TValue.From<TThemeColor>(ThemeColor(255, 244, 71, 71))]);
  FView.AddRow([TValue.From<string>('Carol Meyer'), TValue.From<Integer>(45),
    TValue.From<Boolean>(True), TValue.From<Integer>(100), TValue.From<Integer>(5),
    TValue.From<string>('Done'), TValue.From<TThemeColor>(ThemeColor(255, 78, 201, 176))]);
  FView.AddRow([TValue.From<string>('David Klein'), TValue.From<Integer>(52),
    TValue.From<Boolean>(True), TValue.From<Integer>(60), TValue.From<Integer>(3),
    TValue.From<string>('Review'), TValue.From<TThemeColor>(ThemeColor(255, 220, 220, 170))]);
  FView.AddRow([TValue.From<string>('Eva Fischer'), TValue.From<Integer>(39),
    TValue.From<Boolean>(False), TValue.From<Integer>(20), TValue.From<Integer>(1),
    TValue.From<string>('Running'), TValue.From<TThemeColor>(ThemeColor(255, 147, 112, 219))]);
end;

var
  LForm: TMainForm;
begin
  Application.Initialize;
  Application.Title := 'NimbusForms Grid Demo';
  LForm := TMainForm.CreateNew(nil);
  try
    LForm.ShowModal;
  finally
    LForm.Free;
  end;
end.

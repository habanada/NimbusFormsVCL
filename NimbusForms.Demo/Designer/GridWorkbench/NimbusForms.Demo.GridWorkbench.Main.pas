unit NimbusForms.Demo.GridWorkbench.Main;

interface

uses
  System.Classes, System.SysUtils, System.Rtti, System.TypInfo, System.Generics.Collections, System.IOUtils,
  Vcl.Forms, Vcl.Controls, Vcl.ComCtrls, Vcl.Dialogs,
  NimbusForms.Theming.Manager, NimbusForms.Theming.Presets,
  NimbusForms.Controls.Button, NimbusForms.Controls.TextBox, NimbusForms.Controls.ComboBox,
  NimbusForms.Controls.TabControl, NimbusForms.Controls.Panel, NimbusForms.Controls.ThemedLabel,
  NimbusForms.Controls.ProgressBar, NimbusForms.Controls.BadgeLabel,
  NimbusForms.Controls.GridEditors, NimbusForms.Controls.GridTypes,
  NimbusForms.Grid.View, NimbusForms.Grid.RowList, NimbusForms.Grid.Column,
  NimbusForms.Grid.Types, NimbusForms.Grid.Events, NimbusForms.Grid.Events.MasterDetail,
  NimbusForms.Grid.Events.Visual, NimbusForms.Grid.CellVisual,
  NimbusForms.Grid.FormatCondition, NimbusForms.Theming.Types,
  NimbusForms.Grid.FormatStyle;

type
  TGridWorkbenchRow = class
  public
    Customer: string;
    Status: string;
    Approved: Boolean;
    Active: Boolean;
    Rating: Double;
    Deadline: TDateTime;
    Amount: Double;
  end;

  TShowcaseRow = class
  public
    Id: Integer;
    Progress: Integer;
    Rating: Double;
    Amount: Double;
  end;

  TShowcaseDetailRow = class
  private
    FProduct: string;
    FDescription: string;
    FQuantity: Integer;
    FUnitPrice: Double;
  public
    property Product: string read FProduct write FProduct;
    property Description: string read FDescription write FDescription;
    property Quantity: Integer read FQuantity write FQuantity;
    property UnitPrice: Double read FUnitPrice write FUnitPrice;
  end;

  TGridWorkbenchForm = class(TForm)
    pnlHeader: TThemedPanel;
    lblTitle: TThemedLabel;
    cmbTheme: TThemedComboBox;
    Pages: TThemedTabControl;
    tabEditing: TTabSheet;
    pnlEditing: TThemedPanel;
    btnUndo: TThemedButton;
    btnRedo: TThemedButton;
    btnReadOnly: TThemedButton;
    btnCopySelection: TThemedButton;
    btnPaste: TThemedButton;
    gridEditing: TThemedGridView;
    tabQueries: TTabSheet;
    pnlQueries: TThemedPanel;
    txtSearch: TThemedTextBox;
    btnGroupStatus: TThemedButton;
    btnGroupApproved: TThemedButton;
    btnUngroup: TThemedButton;
    btnFilterApproved: TThemedButton;
    btnClearFilters: TThemedButton;
    gridQueries: TThemedGridView;
    tabPresentation: TTabSheet;
    pnlPresentation: TThemedPanel;
    btnFreeze: TThemedButton;
    btnUnfreeze: TThemedButton;
    btnBands: TThemedButton;
    btnFormats: TThemedButton;
    btnHideAmount: TThemedButton;
    btnShowAll: TThemedButton;
    gridPresentation: TThemedGridView;
    tabExport: TTabSheet;
    pnlExport: TThemedPanel;
    btnCsv: TThemedButton;
    btnJson: TThemedButton;
    btnHtml: TThemedButton;
    btnClipboard: TThemedButton;
    btnFind: TThemedButton;
    gridExport: TThemedGridView;
    tabShowcase: TTabSheet;
    pnlShowcaseHero: TThemedPanel;
    lblShowcaseTitle: TThemedLabel;
    lblShowcaseSubtitle: TThemedLabel;
    badgeVolume: TThemedBadgeLabel;
    badgeDetails: TThemedBadgeLabel;
    badgeVisuals: TThemedBadgeLabel;
    lblShowcaseHealth: TThemedLabel;
    progressShowcase: TThemedProgressBar;
    pnlShowcaseTools: TThemedPanel;
    btnShowcaseReload: TThemedButton;
    btnShowcaseExpand: TThemedButton;
    btnShowcaseCollapse: TThemedButton;
    btnShowcaseFreeze: TThemedButton;
    btnShowcaseHighlights: TThemedButton;
    btnShowcaseVisuals: TThemedButton;
    gridShowcase: TThemedGridView;
    pnlFooter: TThemedPanel;
    lblStatus: TThemedLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Command(Sender: TObject);
    procedure SearchChanged(Sender: TObject);
    procedure ThemeChanged(Sender: TObject);
    procedure PageChanged(Sender: TObject);
    procedure ShowcaseCommand(Sender: TObject);
    procedure ShowcaseVisualNeeded(Sender: TObject; const AArgs: TThemedGridCellVisualNeededEventArgs);
    procedure ShowcaseDetailNeeded(Sender: TObject; const AArgs: TThemedGridMasterDetailDataNeededEventArgs);
    procedure CellValidating(Sender: TObject; const AArgs: TThemedGridCellValidatingEventArgs);
    procedure CellChanged(Sender: TObject; const AArgs: TThemedGridCellValueChangedEventArgs);
  private
    FRows: array[0..3] of TObjectList<TGridWorkbenchRow>;
    FEditors: TList<TNimbusGridControlEditor>;
    FStatuses: TStringList;
    FReadOnly: Boolean;
    FBands: Boolean;
    FShowcaseLoaded: Boolean;
    FShowcaseVisuals: Boolean;
    FShowcaseFrozen: Boolean;
    FShowcaseRows: TObjectList<TShowcaseRow>;
    FShowcaseDetails: TObjectDictionary<Integer, TObjectList<TShowcaseDetailRow>>;
    FAvatarSvgs: array[0..7] of string;
    FTrendSvgs: array[0..7] of string;
    function ActiveGrid: TThemedGridView;
    procedure PopulateRows(const AIndex: Integer);
    procedure ConfigureGrid(const AGrid: TThemedGridView; const AIndex: Integer);
    procedure CreateFormatRules;
    procedure SaveExport(const AExtension, AFilter, AContent: string);
    procedure Report(const AText: string);
    procedure ConfigureShowcase;
    procedure LoadShowcase;
    procedure CreateShowcaseIcons;
    function GetShowcaseDetails(const AId: Integer): TObjectList<TShowcaseDetailRow>;
  end;

var
  GridWorkbenchForm: TGridWorkbenchForm;

implementation

{$R *.dfm}

resourcestring
  SReady = 'Four focused 2,000-row labs plus the 200,000-row visual showcase. Select a feature tab to begin.';
  SValidation = 'Customer name must not be empty.';
  SOperationFailed = 'Operation failed: %s';
  SCommitted = 'Committed %s: %s -> %s';
  SMatches = 'Search: %d matching cells';
  SExported = 'Saved %s';
  SReadOnlyOn = 'Editing disabled';
  SReadOnlyOff = 'Editing enabled';
  SShowcaseReady = '200,000 synthetic records loaded | embedded detail grid | native progress, badges, ratings, color swatches and SVG';

function WorkbenchValue(const ARow: TValue; const AField: Integer): TValue;
var R: TGridWorkbenchRow;
begin
  R := TGridWorkbenchRow(ARow.AsObject);
  case AField of
    0: Result := TValue.From<string>(R.Customer);
    1: Result := TValue.From<string>(R.Status);
    2: Result := TValue.From<Boolean>(R.Approved);
    3: Result := TValue.From<Boolean>(R.Active);
    4: Result := TValue.From<Double>(R.Rating);
    5: Result := TValue.From<TDateTime>(R.Deadline);
    6: Result := TValue.From<Double>(R.Amount);
  else
    Result := TValue.Empty;
  end;
end;

procedure SetWorkbenchValue(const ARow, AValue: TValue; const AField: Integer);
var R: TGridWorkbenchRow;
begin
  R := TGridWorkbenchRow(ARow.AsObject);
  case AField of
    0: R.Customer := AValue.AsString;
    1: R.Status := AValue.AsString;
    2: R.Approved := AValue.AsBoolean;
    3: R.Active := AValue.AsBoolean;
    4: R.Rating := AValue.AsExtended;
    5: R.Deadline := AValue.AsExtended;
    6: R.Amount := AValue.AsExtended;
  end;
end;

procedure TGridWorkbenchForm.Report(const AText: string);
begin
  lblStatus.Caption := AText;
end;

procedure TGridWorkbenchForm.PopulateRows(const AIndex: Integer);
var I: Integer; R: TGridWorkbenchRow;
begin
  FRows[AIndex] := TObjectList<TGridWorkbenchRow>.Create(True);
  for I := 0 to 1999 do
  begin
    R := TGridWorkbenchRow.Create;
    R.Customer := Format('Nimbus Customer %.4d', [I + 1]);
    R.Status := FStatuses[I mod FStatuses.Count];
    R.Approved := I mod 3 <> 0;
    R.Active := I mod 5 <> 0;
    R.Rating := 1 + I mod 5;
    R.Deadline := Date + I mod 120;
    R.Amount := 49.95 + (I mod 200) * 37.25;
    FRows[AIndex].Add(R);
  end;
end;

procedure TGridWorkbenchForm.ConfigureGrid(const AGrid: TThemedGridView; const AIndex: Integer);
var Col: TThemedGridColumn;
  function AddColumn(const AName: string; const AField, AWidth: Integer; const AType: PTypeInfo): TThemedGridColumn;
  begin
    Result := AGrid.Columns.Add(AName, AName, AName);
    Result.Width := AWidth;
    Result.ValueType := AType;
    Result.ValueGetter := function(const ARow: TValue): TValue
      begin
        Result := WorkbenchValue(ARow, AField);
      end;
    Result.ValueSetter := procedure(const ARow, AValue: TValue)
      begin
        SetWorkbenchValue(ARow, AValue, AField);
      end;
  end;
  procedure RegisterEditor(const AColumn: TThemedGridColumn; const AKind: TNimbusGridControlKind);
  begin
    FEditors.Add(TNimbusGridControlEditor.Bind(AColumn, AKind));
  end;
begin
  AGrid.AutoGenerateColumns := False;
  AGrid.RowHeight := 34;
  AGrid.AllowColumnReorder := True;
  AGrid.EditOptions.EditOnSingleClick := True;
  AGrid.OnCellValidating := CellValidating;
  AGrid.OnCellValueChanged := CellChanged;
  AddColumn('Customer', 0, 210, TypeInfo(string));
  Col := AddColumn('Status', 1, 140, TypeInfo(string));
  if AIndex = 0 then begin Col.EditorOptions.DataSource := FStatuses; RegisterEditor(Col, ngckComboBox); end;
  Col := AddColumn('Approved', 2, 100, TypeInfo(Boolean));
  if AIndex = 0 then RegisterEditor(Col, ngckCheckBox);
  Col := AddColumn('Active', 3, 95, TypeInfo(Boolean));
  if AIndex = 0 then RegisterEditor(Col, ngckToggle);
  Col := AddColumn('Rating', 4, 120, TypeInfo(Double));
  Col.EditorOptions.Maximum := 5;
  if AIndex = 0 then RegisterEditor(Col, ngckRating);
  Col := AddColumn('Deadline', 5, 160, TypeInfo(TDateTime));
  Col.FormatString := 'yyyy-mm-dd';
  if AIndex = 0 then RegisterEditor(Col, ngckDateTime);
  Col := AddColumn('Amount', 6, 130, TypeInfo(Double));
  Col.FormatString := '#,##0.00';
  PopulateRows(AIndex);
  AGrid.SetRows(TThemedGridListAdapter<TGridWorkbenchRow>.Create(FRows[AIndex]));
end;

procedure TGridWorkbenchForm.CreateFormatRules;
var Rule: TThemedGridFormatCondition;
begin
  Rule := TThemedGridFormatCondition.Create;
  try
    Rule.ColumnName := 'Rating';
    Rule.TargetColumnName := 'Rating';
    Rule.Operator := TThemedGridFormatConditionOperator.GreaterOrEqual;
    Rule.Value := TValue.From<Double>(4);
    Rule.Style := TThemedGridFormatStyle.Create;
    Rule.Style.Bold := True;
    Rule.Style.ForeColor := $FF4EC9B0;
    gridPresentation.FormatConditions.Add(Rule);
    Rule := nil;
  finally Rule.Free; end;
end;

procedure TGridWorkbenchForm.FormCreate(Sender: TObject);
var Name, Directory: string;
begin
  FEditors := TList<TNimbusGridControlEditor>.Create;
  FStatuses := TStringList.Create;
  FStatuses.Add('Ready'); FStatuses.Add('In progress'); FStatuses.Add('Review'); FStatuses.Add('Done');
  FShowcaseVisuals := True;
  FShowcaseDetails := TObjectDictionary<Integer, TObjectList<TShowcaseDetailRow>>.Create([doOwnsValues]);
  CreateShowcaseIcons;
  ConfigureShowcase;
  ConfigureGrid(gridEditing, 0);
  ConfigureGrid(gridQueries, 1);
  ConfigureGrid(gridPresentation, 2);
  ConfigureGrid(gridExport, 3);
  CreateFormatRules;
  Directory := TPath.Combine(ExtractFilePath(ParamStr(0)), 'Palettes');
  if TDirectory.Exists(Directory) then TThemePresets.LoadFromDirectory(Directory);
  for Name in TThemePresets.GetNames do cmbTheme.Items.Add(Name);
  cmbTheme.ItemIndex := cmbTheme.Items.IndexOf('Dark');
  if (cmbTheme.ItemIndex < 0) and (cmbTheme.Items.Count > 0) then cmbTheme.ItemIndex := 0;
  ThemeChanged(cmbTheme);
  Report(SReady);
end;

procedure TGridWorkbenchForm.FormDestroy(Sender: TObject);
var I: Integer;
begin
  FreeAndNil(gridShowcase);
  FreeAndNil(gridEditing); FreeAndNil(gridQueries); FreeAndNil(gridPresentation); FreeAndNil(gridExport);
  FShowcaseDetails.Free;
  FShowcaseRows.Free;
  FEditors.Free;
  for I := Low(FRows) to High(FRows) do FRows[I].Free;
  FStatuses.Free;
end;

function TGridWorkbenchForm.ActiveGrid: TThemedGridView;
begin
  if Pages.ActivePage = tabEditing then Result := gridEditing
  else if Pages.ActivePage = tabQueries then Result := gridQueries
  else if Pages.ActivePage = tabPresentation then Result := gridPresentation
  else if Pages.ActivePage = tabShowcase then Result := gridShowcase
  else Result := gridExport;
end;

procedure TGridWorkbenchForm.ThemeChanged(Sender: TObject);
begin
  if cmbTheme.ItemIndex < 0 then Exit;
  if ThemeManager.SetThemeByName(cmbTheme.Items[cmbTheme.ItemIndex]) then ThemeManager.ApplyCurrent(Self);
end;

procedure TGridWorkbenchForm.SearchChanged(Sender: TObject);
begin
  Report(Format(SMatches, [gridQueries.Search(txtSearch.Text)]));
end;

procedure TGridWorkbenchForm.CellValidating(Sender: TObject; const AArgs: TThemedGridCellValidatingEventArgs);
begin
  if (AArgs.Column.Name = 'Customer') and (Trim(AArgs.NewValue.ToString) = '') then
  begin
    AArgs.Cancel := True;
    AArgs.ErrorText := SValidation;
    Report(SValidation);
  end;
end;

procedure TGridWorkbenchForm.CellChanged(Sender: TObject; const AArgs: TThemedGridCellValueChangedEventArgs);
begin
  Report(Format(SCommitted, [AArgs.Column.HeaderText, AArgs.OldValue.ToString, AArgs.NewValue.ToString]));
end;

procedure TGridWorkbenchForm.SaveExport(const AExtension, AFilter, AContent: string);
var Dialog: TSaveDialog;
begin
  Dialog := TSaveDialog.Create(Self);
  try
    Dialog.Options := [ofOverwritePrompt];
    Dialog.Filter := AFilter;
    Dialog.DefaultExt := AExtension;
    Dialog.FileName := 'NimbusGrid.' + AExtension;
    if Dialog.Execute then
    begin
      TFile.WriteAllText(Dialog.FileName, AContent, TEncoding.UTF8);
      Report(Format(SExported, [Dialog.FileName]));
    end;
  finally
    Dialog.Free;
  end;
end;

procedure TGridWorkbenchForm.Command(Sender: TObject);
var B: TComponent; G: TThemedGridView;
begin
  B := TComponent(Sender);
  G := ActiveGrid;
  try
    if not G.CommitEdit then Exit;
    if B = btnUndo then begin if G.CanUndo then G.Undo; end
    else if B = btnRedo then begin if G.CanRedo then G.Redo; end
    else if B = btnReadOnly then begin FReadOnly := not FReadOnly; gridEditing.EditOptions.AllowEdit := not FReadOnly; if FReadOnly then Report(SReadOnlyOn) else Report(SReadOnlyOff); end
    else if B = btnCopySelection then gridEditing.CopySelectedToClipboard
    else if B = btnPaste then begin if gridEditing.PasteFromClipboard then Report('Clipboard data pasted'); end
    else if B = btnGroupStatus then gridQueries.GroupBy('Status')
    else if B = btnGroupApproved then gridQueries.GroupBy('Approved')
    else if B = btnUngroup then gridQueries.ClearGrouping
    else if B = btnFilterApproved then gridQueries.ApplyFilter('Approved', TThemedGridFilterOperator.Equals, TValue.From<Boolean>(True))
    else if B = btnClearFilters then gridQueries.ClearFilters
    else if B = btnFreeze then gridPresentation.FreezeColumnsLeft(2)
    else if B = btnUnfreeze then gridPresentation.ClearFrozenColumns
    else if B = btnBands then
    begin
      FBands := not FBands;
      if FBands then
      begin
        gridPresentation.SetColumnBand('Customer', 'Customer');
        gridPresentation.SetColumnBand('Status', 'Workflow');
        gridPresentation.SetColumnBand('Approved', 'Workflow');
        gridPresentation.SetColumnBand('Active', 'Workflow');
        gridPresentation.SetColumnBand('Rating', 'Performance');
        gridPresentation.SetColumnBand('Deadline', 'Performance');
        gridPresentation.SetColumnBand('Amount', 'Performance');
      end
      else gridPresentation.ClearColumnBands;
      gridPresentation.ShowColumnBandHeaders := FBands;
    end
    else if B = btnFormats then gridPresentation.FormatConditionsEnabled := not gridPresentation.FormatConditionsEnabled
    else if B = btnHideAmount then gridPresentation.HideColumn('Amount')
    else if B = btnShowAll then gridPresentation.ShowAllColumns
    else if B = btnCsv then SaveExport('csv', 'CSV files|*.csv', gridExport.ExportToCsv)
    else if B = btnJson then SaveExport('json', 'JSON files|*.json', gridExport.ExportToJson)
    else if B = btnHtml then SaveExport('html', 'HTML files|*.html', gridExport.ExportToHtml)
    else if B = btnClipboard then gridExport.CopyExportToClipboard
    else if B = btnFind then begin if gridExport.FindPanelVisible then gridExport.HideFindPanel else gridExport.ShowFindPanel; end;
  except on E: Exception do Report(Format(SOperationFailed, [E.Message])); end;
end;


function ShowcaseValue(const ARow: TValue; const AField: Integer): TValue;
const
  States: array[0..3] of string = ('Done', 'Running', 'Review', 'Blocked');
  Segments: array[0..5] of string = ('Enterprise', 'Commerce', 'Cloud', 'Healthcare', 'Finance', 'Platform');
  Colors: array[0..7] of TThemeColor = ($FF60A5FA, $FF34D399, $FFFBBF24, $FFF472B6, $FFA78BFA, $FF2DD4BF, $FFFB7185, $FF818CF8);
var R: TShowcaseRow;
begin
  R := TShowcaseRow(ARow.AsObject);
  case AField of
    0: Result := TValue.From<string>(IntToStr(R.Id mod 8));
    1: Result := TValue.From<string>(Format('Aurora Account %.6d', [R.Id]));
    2: Result := TValue.From<string>(States[R.Id mod Length(States)]);
    3: Result := TValue.From<Double>(R.Progress);
    4: Result := TValue.From<string>(States[(R.Id div 7) mod Length(States)]);
    5: Result := TValue.From<Double>(R.Amount);
    6: Result := TValue.From<Double>(R.Rating);
    7: Result := TValue.From<TThemeColor>(Colors[R.Id mod Length(Colors)]);
    8: Result := TValue.From<string>(IntToStr(R.Id mod 8));
    9: Result := TValue.From<string>(Segments[R.Id mod Length(Segments)]);
  else
    Result := TValue.Empty;
  end;
end;

procedure TGridWorkbenchForm.CreateShowcaseIcons;
const
  Colors: array[0..7] of string = ('#60A5FA', '#34D399', '#FBBF24', '#F472B6', '#A78BFA', '#2DD4BF', '#FB7185', '#818CF8');
var I, J, Y: Integer; Points: string;
begin
  for I := 0 to 7 do
  begin
    FAvatarSvgs[I] := Format('<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64"><rect x="1" y="1" width="62" height="62" rx="19" fill="%s"/><circle cx="32" cy="25" r="11" fill="#ffffff" opacity=".94"/><path d="M12 57c3-13 11-20 20-20s17 7 20 20" fill="#ffffff" opacity=".94"/></svg>', [Colors[I]]);
    Points := '';
    for J := 0 to 6 do
    begin
      Y := 26 - ((J * (I + 3) * 7 + J * J * 3 + I * 11) mod 20);
      if J > 0 then Points := Points + ' ';
      Points := Points + Format('%d,%d', [5 + J * 8, Y]);
    end;
    FTrendSvgs[I] := Format('<svg xmlns="http://www.w3.org/2000/svg" width="64" height="40" viewBox="0 0 64 40"><polyline points="%s" fill="none" stroke="%s" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/></svg>', [Points, Colors[I]]);
  end;
end;

procedure TGridWorkbenchForm.ConfigureShowcase;
var C: TThemedGridColumn;
  function Add(const AName, AHeader: string; const AField, AWidth: Integer; const AType: PTypeInfo;
    const ARender: TThemedGridCellRenderKind): TThemedGridColumn;
  begin
    Result := gridShowcase.Columns.Add(AName, AName, AHeader);
    Result.Width := AWidth;
    Result.ValueType := AType;
    Result.ReadOnly := True;
    Result.RenderKind := ARender;
    Result.ValueGetter := function(const ARow: TValue): TValue
      begin
        Result := ShowcaseValue(ARow, AField);
      end;
  end;
begin
  gridShowcase.AutoGenerateColumns := False;
  gridShowcase.RowHeight := 46;
  gridShowcase.HeaderHeight := 36;
  gridShowcase.AllowColumnReorder := True;
  gridShowcase.EditOptions.AllowEdit := False;
  gridShowcase.DetailOptions.Enabled := True;
  gridShowcase.DetailOptions.AllowCollapse := True;
  gridShowcase.DetailOptions.AutoRowHeight := True;
  gridShowcase.DetailOptions.DetailRowHeight := 170;
  gridShowcase.DetailOptions.Relations.Add('Orders', 'Order line items');
  gridShowcase.OnMasterDetailDataNeeded := ShowcaseDetailNeeded;
  gridShowcase.OnCellVisualNeeded := ShowcaseVisualNeeded;
  Add('Profile', 'AVATAR', 0, 100, TypeInfo(string), TThemedGridCellRenderKind.Text);
  Add('Account', 'CUSTOMER / ACCOUNT', 1, 240, TypeInfo(string), TThemedGridCellRenderKind.Text);
  Add('Status', 'WORKFLOW', 2, 115, TypeInfo(string), TThemedGridCellRenderKind.Badge);
  C := Add('Progress', 'COMPLETION', 3, 195, TypeInfo(Double), TThemedGridCellRenderKind.ProgressBar);
  C.EditorOptions.Minimum := 0;
  C.EditorOptions.Maximum := 100;
  C.EditorOptions.ValueScale := 1;
  C.FormatString := '0"%"';
  Add('Risk', 'RISK / HEALTH', 4, 118, TypeInfo(string), TThemedGridCellRenderKind.Badge);
  C := Add('Revenue', 'PIPELINE VALUE', 5, 145, TypeInfo(Double), TThemedGridCellRenderKind.Currency);
  C.FormatString := '#,##0.00';
  C := Add('Rating', 'QUALITY', 6, 130, TypeInfo(Double), TThemedGridCellRenderKind.Rating);
  C.EditorOptions.Maximum := 5;
  Add('Brand', 'BRAND COLOR', 7, 120, TypeInfo(TThemeColor), TThemedGridCellRenderKind.ColorSwatch);
  Add('Trend', 'TREND / SVG', 8, 95, TypeInfo(string), TThemedGridCellRenderKind.Text);
  Add('Segment', 'INDUSTRY', 9, 135, TypeInfo(string), TThemedGridCellRenderKind.Text);
  gridShowcase.SetColumnBand('Profile', 'CUSTOMER 360');
  gridShowcase.SetColumnBand('Account', 'CUSTOMER 360');
  gridShowcase.SetColumnBand('Status', 'OPERATIONS');
  gridShowcase.SetColumnBand('Progress', 'OPERATIONS');
  gridShowcase.SetColumnBand('Risk', 'OPERATIONS');
  gridShowcase.SetColumnBand('Revenue', 'PERFORMANCE');
  gridShowcase.SetColumnBand('Rating', 'PERFORMANCE');
  gridShowcase.SetColumnBand('Brand', 'VISUALS');
  gridShowcase.SetColumnBand('Trend', 'VISUALS');
  gridShowcase.SetColumnBand('Segment', 'VISUALS');
  gridShowcase.ShowColumnBandHeaders := True;
  gridShowcase.AddFormatCondition('Revenue', TThemedGridFormatConditionOperator.GreaterOrEqual,
    TValue.From<Double>(20000), TThemedGridFormatStyle.BackFore($FF153D35, $FF6EE7B7));
  gridShowcase.AddFormatCondition('Revenue', TThemedGridFormatConditionOperator.LessThan,
    TValue.From<Double>(3000), TThemedGridFormatStyle.BackFore($FF482B34, $FFFDA4AF));
end;

procedure TGridWorkbenchForm.LoadShowcase;
var I: Integer; R: TShowcaseRow;
begin
  if FShowcaseLoaded then Exit;
  if FShowcaseRows <> nil then FreeAndNil(FShowcaseRows);
  lblShowcaseSubtitle.Caption := 'Preparing 200,000 generated rows for the NimbusForms grid...';
  FShowcaseRows := TObjectList<TShowcaseRow>.Create(True);
  FShowcaseRows.Capacity := 200000;
  try
    for I := 1 to 200000 do
    begin
      R := TShowcaseRow.Create;
      R.Id := I;
      R.Progress := (I * 37 + I div 11) mod 101;
      R.Rating := 1 + (I mod 5);
      R.Amount := 450 + (I * 131 mod 25500) + (I mod 10) * 0.75;
      FShowcaseRows.Add(R);
    end;
    gridShowcase.SetRows(TThemedGridListAdapter<TShowcaseRow>.Create(FShowcaseRows));
    gridShowcase.ExpandDetailRow(0);
    FShowcaseLoaded := True;
    progressShowcase.Position := 78;
    lblShowcaseSubtitle.Caption := '200,000 in-memory rows | first order expanded | click any row expander for nested grids';
    Report(SShowcaseReady);
  except
    gridShowcase.DataSource := TValue.Empty;
    FreeAndNil(FShowcaseRows);
    raise;
  end;
end;

function TGridWorkbenchForm.GetShowcaseDetails(const AId: Integer): TObjectList<TShowcaseDetailRow>;
var I: Integer; R: TShowcaseDetailRow;
begin
  if FShowcaseDetails.TryGetValue(AId, Result) then Exit;
  Result := TObjectList<TShowcaseDetailRow>.Create(True);
  for I := 1 to 4 do
  begin
    R := TShowcaseDetailRow.Create;
    R.Product := Format('NF-SKU-%4.4d', [((AId * 7 + I * 13) mod 9000) + 1000]);
    R.Description := Format('NimbusForms visual bundle %d', [I]);
    R.Quantity := 1 + (AId + I) mod 12;
    R.UnitPrice := 59.90 + ((AId + I * 17) mod 300) * 4.5;
    Result.Add(R);
  end;
  FShowcaseDetails.Add(AId, Result);
end;

procedure TGridWorkbenchForm.ShowcaseDetailNeeded(Sender: TObject;
  const AArgs: TThemedGridMasterDetailDataNeededEventArgs);
var R: TShowcaseRow; Rows: IThemedGridRowList;
begin
  if not AArgs.ParentRowObject.IsObject or not (AArgs.ParentRowObject.AsObject is TShowcaseRow) then Exit;
  R := TShowcaseRow(AArgs.ParentRowObject.AsObject);
  Rows := TThemedGridListAdapter<TShowcaseDetailRow>.Create(GetShowcaseDetails(R.Id));
  AArgs.DetailGridDataSource := TValue.From<IThemedGridRowList>(Rows);
  AArgs.DetailGridOptions.HeaderVisible := True;
  AArgs.DetailGridOptions.MaxVisibleRows := 4;
  AArgs.DetailGridOptions.RowHeight := 30;
  AArgs.DetailGridOptions.AutoGenerateColumns := False;
  AArgs.DetailGridColumns.Add('Product', 'SKU', 'Product', 150);
  AArgs.DetailGridColumns.Add('Description', 'PRODUCT / SERVICE', 'Description', 310);
  AArgs.DetailGridColumns.Add('Quantity', 'QTY', 'Quantity', 80);
  AArgs.DetailGridColumns.Add('UnitPrice', 'UNIT PRICE', 'UnitPrice', 130);
  AArgs.Handled := True;
end;

procedure TGridWorkbenchForm.ShowcaseVisualNeeded(Sender: TObject;
  const AArgs: TThemedGridCellVisualNeededEventArgs);
var R: TShowcaseRow; IconIndex, ImageIndex: Integer;
begin
  if not FShowcaseVisuals or (AArgs.Column = nil) or not AArgs.RowObject.IsObject or
    not (AArgs.RowObject.AsObject is TShowcaseRow) then Exit;
  R := TShowcaseRow(AArgs.RowObject.AsObject);
  IconIndex := R.Id mod 8;
  if AArgs.Column.Name = 'Profile' then
  begin
    AArgs.Visual.Text := Format(' %2.2d', [IconIndex + 11]);
    AArgs.Visual.ToolTip := Format('SVG avatar for account %d', [R.Id]);
    AArgs.Visual.ImageSize := 30;
    AArgs.Visual.AddSvgText('account', FAvatarSvgs[IconIndex]);
    AArgs.Handled := True;
  end
  else if AArgs.Column.Name = 'Trend' then
  begin
    AArgs.Visual.Text := Format('%d%%', [62 + (R.Id mod 37)]);
    AArgs.Visual.ImageSize := 28;
    ImageIndex := AArgs.Visual.AddSvgText('sparkline', FTrendSvgs[IconIndex]);
    AArgs.Visual.SetImageSize(ImageIndex, 28);
    AArgs.Visual.ToolTip := 'Synthetic pipeline trend (SVG)';
    AArgs.Handled := True;
  end;
end;

procedure TGridWorkbenchForm.PageChanged(Sender: TObject);
begin
  if (Pages.ActivePage = tabShowcase) and not FShowcaseLoaded then
    try
      LoadShowcase;
    except
      on E: Exception do Report(Format(SOperationFailed, [E.Message]));
    end;
end;

procedure TGridWorkbenchForm.ShowcaseCommand(Sender: TObject);
begin
  try
    if not FShowcaseLoaded then LoadShowcase;
    if Sender = btnShowcaseReload then
    begin
      gridShowcase.Reload;
      gridShowcase.ExpandDetailRow(0);
      Report(Format('Grid reload completed: %d rows', [gridShowcase.RowCount]));
    end
    else if Sender = btnShowcaseExpand then
    begin
      gridShowcase.ExpandDetailRow(0);
      Report('Embedded order grid expanded for the first account');
    end
    else if Sender = btnShowcaseCollapse then
    begin
      gridShowcase.CollapseDetailRow(0);
      Report('Embedded order grid collapsed');
    end
    else if Sender = btnShowcaseFreeze then
    begin
      FShowcaseFrozen := not FShowcaseFrozen;
      if FShowcaseFrozen then gridShowcase.FreezeColumnsLeft(2) else gridShowcase.ClearFrozenColumns;
      Report('Frozen columns toggled');
    end
    else if Sender = btnShowcaseHighlights then
    begin
      gridShowcase.FormatConditionsEnabled := not gridShowcase.FormatConditionsEnabled;
      Report('Conditional color highlights toggled');
    end
    else if Sender = btnShowcaseVisuals then
    begin
      FShowcaseVisuals := not FShowcaseVisuals;
      gridShowcase.ClearVisualCache;
      Report('SVG cell images toggled');
    end;
  except
    on E: Exception do Report(Format(SOperationFailed, [E.Message]));
  end;
end;

end.

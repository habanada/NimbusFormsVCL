program GridDemo;

{$APPTYPE GUI}

uses
  Winapi.Windows,
  System.SysUtils,
  System.Types,
  System.Math,
  System.Classes,
  System.Rtti,
  System.Generics.Collections,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  NimbusForms.Grid.Cell in '..\src\NimbusForms.Grid.Cell.pas',
  NimbusForms.Grid.CellMetadata in '..\src\NimbusForms.Grid.CellMetadata.pas',
  NimbusForms.Grid.CellRenderer in '..\src\NimbusForms.Grid.CellRenderer.pas',
  NimbusForms.Grid.CellRendererIntf in '..\src\NimbusForms.Grid.CellRendererIntf.pas',
  NimbusForms.Grid.CellRendererParts in '..\src\NimbusForms.Grid.CellRendererParts.pas',
  NimbusForms.Grid.CellRenderers in '..\src\NimbusForms.Grid.CellRenderers.pas',
  NimbusForms.Grid.CellRenderers.Content in '..\src\NimbusForms.Grid.CellRenderers.Content.pas',
  NimbusForms.Grid.CellRenderers.Input in '..\src\NimbusForms.Grid.CellRenderers.Input.pas',
  NimbusForms.Grid.CellRenderers.Visual in '..\src\NimbusForms.Grid.CellRenderers.Visual.pas',
  NimbusForms.Grid.CellVisual in '..\src\NimbusForms.Grid.CellVisual.pas',
  NimbusForms.Grid.CellVisualRenderer in '..\src\NimbusForms.Grid.CellVisualRenderer.pas',
  NimbusForms.Grid.ClipboardExporter in '..\src\NimbusForms.Grid.ClipboardExporter.pas',
  NimbusForms.Grid.ClipboardOptions in '..\src\NimbusForms.Grid.ClipboardOptions.pas',
  NimbusForms.Grid.ClipboardParser in '..\src\NimbusForms.Grid.ClipboardParser.pas',
  NimbusForms.Grid.ColorValue in '..\src\NimbusForms.Grid.ColorValue.pas',
  NimbusForms.Grid.Column in '..\src\NimbusForms.Grid.Column.pas',
  NimbusForms.Grid.ColumnBand in '..\src\NimbusForms.Grid.ColumnBand.pas',
  NimbusForms.Grid.ColumnBandCollection in '..\src\NimbusForms.Grid.ColumnBandCollection.pas',
  NimbusForms.Grid.ColumnCollection in '..\src\NimbusForms.Grid.ColumnCollection.pas',
  NimbusForms.Grid.ControlApi in '..\src\NimbusForms.Grid.ControlApi.pas',
  NimbusForms.Grid.ControlAutoSize in '..\src\NimbusForms.Grid.ControlAutoSize.pas',
  NimbusForms.Grid.ControlBase in '..\src\NimbusForms.Grid.ControlBase.pas',
  NimbusForms.Grid.ControlCells in '..\src\NimbusForms.Grid.ControlCells.pas',
  NimbusForms.Grid.ControlClipboard in '..\src\NimbusForms.Grid.ControlClipboard.pas',
  NimbusForms.Grid.ControlDrag in '..\src\NimbusForms.Grid.ControlDrag.pas',
  NimbusForms.Grid.ControlEdit in '..\src\NimbusForms.Grid.ControlEdit.pas',
  NimbusForms.Grid.ControlFilter in '..\src\NimbusForms.Grid.ControlFilter.pas',
  NimbusForms.Grid.ControlFormatConditions in '..\src\NimbusForms.Grid.ControlFormatConditions.pas',
  NimbusForms.Grid.ControlHit in '..\src\NimbusForms.Grid.ControlHit.pas',
  NimbusForms.Grid.ControlKeys in '..\src\NimbusForms.Grid.ControlKeys.pas',
  NimbusForms.Grid.ControlLayout in '..\src\NimbusForms.Grid.ControlLayout.pas',
  NimbusForms.Grid.ControlMasterDetail in '..\src\NimbusForms.Grid.ControlMasterDetail.pas',
  NimbusForms.Grid.ControlMouse in '..\src\NimbusForms.Grid.ControlMouse.pas',
  NimbusForms.Grid.ControlPaint in '..\src\NimbusForms.Grid.ControlPaint.pas',
  NimbusForms.Grid.ControlRows in '..\src\NimbusForms.Grid.ControlRows.pas',
  NimbusForms.Grid.ControlSearch in '..\src\NimbusForms.Grid.ControlSearch.pas',
  NimbusForms.Grid.ControlSummary in '..\src\NimbusForms.Grid.ControlSummary.pas',
  NimbusForms.Grid.ControlUndo in '..\src\NimbusForms.Grid.ControlUndo.pas',
  NimbusForms.Grid.ControlVisual in '..\src\NimbusForms.Grid.ControlVisual.pas',
  NimbusForms.Grid.CsvExporter in '..\src\NimbusForms.Grid.CsvExporter.pas',
  NimbusForms.Grid.DataControllerBase in '..\src\NimbusForms.Grid.DataControllerBase.pas',
  NimbusForms.Grid.DataControllerIntf in '..\src\NimbusForms.Grid.DataControllerIntf.pas',
  NimbusForms.Grid.DataSetController in '..\src\NimbusForms.Grid.DataSetController.pas',
  NimbusForms.Grid.DataSourceResolver in '..\src\NimbusForms.Grid.DataSourceResolver.pas',
  NimbusForms.Grid.DataStrings in '..\src\NimbusForms.Grid.DataStrings.pas',
  NimbusForms.Grid.DetailGridColumn in '..\src\NimbusForms.Grid.DetailGridColumn.pas',
  NimbusForms.Grid.DetailGridHitInfo in '..\src\NimbusForms.Grid.DetailGridHitInfo.pas',
  NimbusForms.Grid.DetailGridOptions in '..\src\NimbusForms.Grid.DetailGridOptions.pas',
  NimbusForms.Grid.DetailGridRowVisual in '..\src\NimbusForms.Grid.DetailGridRowVisual.pas',
  NimbusForms.Grid.DetailItem in '..\src\NimbusForms.Grid.DetailItem.pas',
  NimbusForms.Grid.DetailItemCollection in '..\src\NimbusForms.Grid.DetailItemCollection.pas',
  NimbusForms.Grid.DetailOptions in '..\src\NimbusForms.Grid.DetailOptions.pas',
  NimbusForms.Grid.DetailRelation in '..\src\NimbusForms.Grid.DetailRelation.pas',
  NimbusForms.Grid.DetailRelationCollection in '..\src\NimbusForms.Grid.DetailRelationCollection.pas',
  NimbusForms.Grid.DetailStrings in '..\src\NimbusForms.Grid.DetailStrings.pas',
  NimbusForms.Grid.DistinctValue in '..\src\NimbusForms.Grid.DistinctValue.pas',
  NimbusForms.Grid.DistinctValueList in '..\src\NimbusForms.Grid.DistinctValueList.pas',
  NimbusForms.Grid.DistinctValueProvider in '..\src\NimbusForms.Grid.DistinctValueProvider.pas',
  NimbusForms.Grid.DragData in '..\src\NimbusForms.Grid.DragData.pas',
  NimbusForms.Grid.DragDropOptions in '..\src\NimbusForms.Grid.DragDropOptions.pas',
  NimbusForms.Grid.EditOptions in '..\src\NimbusForms.Grid.EditOptions.pas',
  NimbusForms.Grid.Editor.Choice in '..\src\NimbusForms.Grid.Editor.Choice.pas',
  NimbusForms.Grid.Editor.Text in '..\src\NimbusForms.Grid.Editor.Text.pas',
  NimbusForms.Grid.Editor.Value in '..\src\NimbusForms.Grid.Editor.Value.pas',
  NimbusForms.Grid.EditorBase in '..\src\NimbusForms.Grid.EditorBase.pas',
  NimbusForms.Grid.EditorControls in '..\src\NimbusForms.Grid.EditorControls.pas',
  NimbusForms.Grid.EditorFactory in '..\src\NimbusForms.Grid.EditorFactory.pas',
  NimbusForms.Grid.EditorHost in '..\src\NimbusForms.Grid.EditorHost.pas',
  NimbusForms.Grid.EditorIntf in '..\src\NimbusForms.Grid.EditorIntf.pas',
  NimbusForms.Grid.EditorOptions in '..\src\NimbusForms.Grid.EditorOptions.pas',
  NimbusForms.Grid.EditorSupport in '..\src\NimbusForms.Grid.EditorSupport.pas',
  NimbusForms.Grid.EditStrings in '..\src\NimbusForms.Grid.EditStrings.pas',
  NimbusForms.Grid.Events in '..\src\NimbusForms.Grid.Events.pas',
  NimbusForms.Grid.Events.DragDrop in '..\src\NimbusForms.Grid.Events.DragDrop.pas',
  NimbusForms.Grid.Events.MasterDetail in '..\src\NimbusForms.Grid.Events.MasterDetail.pas',
  NimbusForms.Grid.Events.Paste in '..\src\NimbusForms.Grid.Events.Paste.pas',
  NimbusForms.Grid.Events.Rows in '..\src\NimbusForms.Grid.Events.Rows.pas',
  NimbusForms.Grid.Events.Search in '..\src\NimbusForms.Grid.Events.Search.pas',
  NimbusForms.Grid.Events.Undo in '..\src\NimbusForms.Grid.Events.Undo.pas',
  NimbusForms.Grid.Events.Visual in '..\src\NimbusForms.Grid.Events.Visual.pas',
  NimbusForms.Grid.Export in '..\src\NimbusForms.Grid.Export.pas',
  NimbusForms.Grid.ExportData in '..\src\NimbusForms.Grid.ExportData.pas',
  NimbusForms.Grid.ExportIntf in '..\src\NimbusForms.Grid.ExportIntf.pas',
  NimbusForms.Grid.ExportOptions in '..\src\NimbusForms.Grid.ExportOptions.pas',
  NimbusForms.Grid.ExportSupport in '..\src\NimbusForms.Grid.ExportSupport.pas',
  NimbusForms.Grid.FilterDescriptor in '..\src\NimbusForms.Grid.FilterDescriptor.pas',
  NimbusForms.Grid.FilterEvaluator in '..\src\NimbusForms.Grid.FilterEvaluator.pas',
  NimbusForms.Grid.FilterStrings in '..\src\NimbusForms.Grid.FilterStrings.pas',
  NimbusForms.Grid.FormatCondition in '..\src\NimbusForms.Grid.FormatCondition.pas',
  NimbusForms.Grid.FormatConditionCollection in '..\src\NimbusForms.Grid.FormatConditionCollection.pas',
  NimbusForms.Grid.FormatConditionContext in '..\src\NimbusForms.Grid.FormatConditionContext.pas',
  NimbusForms.Grid.FormatConditionDesigner in '..\src\NimbusForms.Grid.FormatConditionDesigner.pas',
  NimbusForms.Grid.FormatConditionEvaluator in '..\src\NimbusForms.Grid.FormatConditionEvaluator.pas',
  NimbusForms.Grid.FormatConditionEvents in '..\src\NimbusForms.Grid.FormatConditionEvents.pas',
  NimbusForms.Grid.FormatConditionModel in '..\src\NimbusForms.Grid.FormatConditionModel.pas',
  NimbusForms.Grid.FormatConditionSerializer in '..\src\NimbusForms.Grid.FormatConditionSerializer.pas',
  NimbusForms.Grid.FormatConditionSetModel in '..\src\NimbusForms.Grid.FormatConditionSetModel.pas',
  NimbusForms.Grid.FormatConditionStrings in '..\src\NimbusForms.Grid.FormatConditionStrings.pas',
  NimbusForms.Grid.FormatConditionTypes in '..\src\NimbusForms.Grid.FormatConditionTypes.pas',
  NimbusForms.Grid.FormatConditionValidation in '..\src\NimbusForms.Grid.FormatConditionValidation.pas',
  NimbusForms.Grid.FormatDesignerControls in '..\src\NimbusForms.Grid.FormatDesignerControls.pas',
  NimbusForms.Grid.FormatDesignerStrings in '..\src\NimbusForms.Grid.FormatDesignerStrings.pas',
  NimbusForms.Grid.FormatStyle in '..\src\NimbusForms.Grid.FormatStyle.pas',
  NimbusForms.Grid.FormatStyleModel in '..\src\NimbusForms.Grid.FormatStyleModel.pas',
  NimbusForms.Grid.GdiCache in '..\src\NimbusForms.Grid.GdiCache.pas',
  NimbusForms.Grid.GdiText in '..\src\NimbusForms.Grid.GdiText.pas',
  NimbusForms.Grid.GridFilter in '..\src\NimbusForms.Grid.GridFilter.pas',
  NimbusForms.Grid.GroupDescriptor in '..\src\NimbusForms.Grid.GroupDescriptor.pas',
  NimbusForms.Grid.GroupDescriptorCollection in '..\src\NimbusForms.Grid.GroupDescriptorCollection.pas',
  NimbusForms.Grid.GroupingOptions in '..\src\NimbusForms.Grid.GroupingOptions.pas',
  NimbusForms.Grid.HeaderFilterPopup in '..\src\NimbusForms.Grid.HeaderFilterPopup.pas',
  NimbusForms.Grid.HeaderRenderer in '..\src\NimbusForms.Grid.HeaderRenderer.pas',
  NimbusForms.Grid.HitInfo in '..\src\NimbusForms.Grid.HitInfo.pas',
  NimbusForms.Grid.HtmlExporter in '..\src\NimbusForms.Grid.HtmlExporter.pas',
  NimbusForms.Grid.InlineEditorGeometry in '..\src\NimbusForms.Grid.InlineEditorGeometry.pas',
  NimbusForms.Grid.JsonExporter in '..\src\NimbusForms.Grid.JsonExporter.pas',
  NimbusForms.Grid.ListDataController in '..\src\NimbusForms.Grid.ListDataController.pas',
  NimbusForms.Grid.MasterDetailCache in '..\src\NimbusForms.Grid.MasterDetailCache.pas',
  NimbusForms.Grid.MasterDetailData in '..\src\NimbusForms.Grid.MasterDetailData.pas',
  NimbusForms.Grid.MasterDetailStrings in '..\src\NimbusForms.Grid.MasterDetailStrings.pas',
  NimbusForms.Grid.NumericRange in '..\src\NimbusForms.Grid.NumericRange.pas',
  NimbusForms.Grid.OleDragDrop in '..\src\NimbusForms.Grid.OleDragDrop.pas',
  NimbusForms.Grid.PaintStrings in '..\src\NimbusForms.Grid.PaintStrings.pas',
  NimbusForms.Grid.Primitives in '..\src\NimbusForms.Grid.Primitives.pas',
  NimbusForms.Grid.RenderContext in '..\src\NimbusForms.Grid.RenderContext.pas',
  NimbusForms.Grid.Renderer in '..\src\NimbusForms.Grid.Renderer.pas',
  NimbusForms.Grid.RenderMetrics in '..\src\NimbusForms.Grid.RenderMetrics.pas',
  NimbusForms.Grid.Row in '..\src\NimbusForms.Grid.Row.pas',
  NimbusForms.Grid.RowActionOptions in '..\src\NimbusForms.Grid.RowActionOptions.pas',
  NimbusForms.Grid.RowList in '..\src\NimbusForms.Grid.RowList.pas',
  NimbusForms.Grid.RowMoveOptions in '..\src\NimbusForms.Grid.RowMoveOptions.pas',
  NimbusForms.Grid.RowView in '..\src\NimbusForms.Grid.RowView.pas',
  NimbusForms.Grid.RowViewBuilder in '..\src\NimbusForms.Grid.RowViewBuilder.pas',
  NimbusForms.Grid.SearchEngine in '..\src\NimbusForms.Grid.SearchEngine.pas',
  NimbusForms.Grid.SearchMatch in '..\src\NimbusForms.Grid.SearchMatch.pas',
  NimbusForms.Grid.SearchOptions in '..\src\NimbusForms.Grid.SearchOptions.pas',
  NimbusForms.Grid.SearchPanel in '..\src\NimbusForms.Grid.SearchPanel.pas',
  NimbusForms.Grid.SearchResult in '..\src\NimbusForms.Grid.SearchResult.pas',
  NimbusForms.Grid.SearchStrings in '..\src\NimbusForms.Grid.SearchStrings.pas',
  NimbusForms.Grid.SelectionModel in '..\src\NimbusForms.Grid.SelectionModel.pas',
  NimbusForms.Grid.SelectionOptions in '..\src\NimbusForms.Grid.SelectionOptions.pas',
  NimbusForms.Grid.SelectionRenderer in '..\src\NimbusForms.Grid.SelectionRenderer.pas',
  NimbusForms.Grid.SimpleView in '..\src\NimbusForms.Grid.SimpleView.pas',
  NimbusForms.Grid.StringSet in '..\src\NimbusForms.Grid.StringSet.pas',
  NimbusForms.Grid.SvgDocument in '..\src\NimbusForms.Grid.SvgDocument.pas',
  NimbusForms.Grid.SvgIconCache in '..\src\NimbusForms.Grid.SvgIconCache.pas',
  NimbusForms.Grid.SvgPath in '..\src\NimbusForms.Grid.SvgPath.pas',
  NimbusForms.Grid.SvgRenderer in '..\src\NimbusForms.Grid.SvgRenderer.pas',
  NimbusForms.Grid.SvgValues in '..\src\NimbusForms.Grid.SvgValues.pas',
  NimbusForms.Grid.SvgXml in '..\src\NimbusForms.Grid.SvgXml.pas',
  NimbusForms.Grid.ToolTipHost in '..\src\NimbusForms.Grid.ToolTipHost.pas',
  NimbusForms.Grid.Types in '..\src\NimbusForms.Grid.Types.pas',
  NimbusForms.Grid.UndoManager in '..\src\NimbusForms.Grid.UndoManager.pas',
  NimbusForms.Grid.UndoOptions in '..\src\NimbusForms.Grid.UndoOptions.pas',
  NimbusForms.Grid.UndoStrings in '..\src\NimbusForms.Grid.UndoStrings.pas',
  NimbusForms.Grid.UndoTypes in '..\src\NimbusForms.Grid.UndoTypes.pas',
  NimbusForms.Grid.ValueAccessor in '..\src\NimbusForms.Grid.ValueAccessor.pas',
  NimbusForms.Grid.ValueConverter in '..\src\NimbusForms.Grid.ValueConverter.pas',
  NimbusForms.Grid.ValueFormatter in '..\src\NimbusForms.Grid.ValueFormatter.pas',
  NimbusForms.Grid.View in '..\src\NimbusForms.Grid.View.pas',
  NimbusForms.Grid.ViewRow in '..\src\NimbusForms.Grid.ViewRow.pas',
  NimbusForms.Grid.VisualAction in '..\src\NimbusForms.Grid.VisualAction.pas',
  NimbusForms.Grid.VisualActionCommand in '..\src\NimbusForms.Grid.VisualActionCommand.pas',
  NimbusForms.Grid.VisualImage in '..\src\NimbusForms.Grid.VisualImage.pas',
  NimbusForms.Grid.VisualImageRenderer in '..\src\NimbusForms.Grid.VisualImageRenderer.pas',
  NimbusForms.Grid.VisualStrings in '..\src\NimbusForms.Grid.VisualStrings.pas',
  NimbusForms.Theming.Manager in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.Manager.pas',
  NimbusForms.Theming.Palette in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.Palette.pas',
  NimbusForms.Theming.PresetFactory in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.PresetFactory.pas',
  NimbusForms.Theming.Presets in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.Presets.pas',
  NimbusForms.Theming.Serializer in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.Serializer.pas',
  NimbusForms.Theming.Strings in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.Strings.pas',
  NimbusForms.Theming.Types in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.Types.pas',
  NimbusForms.Theming.Win32 in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.Win32.pas',
  NimbusForms.Theming.WinVersion in '..\..\NimbusForms.Theming\src\NimbusForms.Theming.WinVersion.pas';

type
  TOrder = class
  private
    FNumber: string;
    FAmount: Double;
    FDone: Boolean;
    FProgress: Integer;
  public
    constructor Create(const ANumber: string; const AAmount: Double; const ADone: Boolean; const AProgress: Integer);
    property Number: string read FNumber write FNumber;
    property Amount: Double read FAmount write FAmount;
    property Done: Boolean read FDone write FDone;
    property Progress: Integer read FProgress write FProgress;
  end;

  TPerson = class
  private
    FOrders: TObjectList<TOrder>;
    FName: string;
    FAge: Integer;
    FActive: Boolean;
    FProgress: Integer;
    FRating: Integer;
    FStatus: string;
    FColor: TThemeColor;
  public
    constructor Create(const AName: string; const AAge: Integer; const AActive: Boolean;
      const AProgress, ARating: Integer; const AStatus: string; const AColor: TThemeColor);
    destructor Destroy; override;
    property Name: string read FName write FName;
    property Age: Integer read FAge write FAge;
    property Active: Boolean read FActive write FActive;
    property Progress: Integer read FProgress write FProgress;
    property Rating: Integer read FRating write FRating;
    property Status: string read FStatus write FStatus;
    property Color: TThemeColor read FColor write FColor;
    property Orders: TObjectList<TOrder> read FOrders;
  end;

  TMainForm = class(TForm)
  private
    FTop: TPanel;
    FFilterEdit: TEdit;
    FGroupCheck: TCheckBox;
    FDesignerButton: TButton;
    FView: TThemedGridView;
    FPeople: TObjectList<TPerson>;
    FStatuses: TStringList;
    procedure BuildColumns;
    procedure BuildRows;
    procedure FilterChanged(Sender: TObject);
    procedure GroupChanged(Sender: TObject);
    procedure DesignerClick(Sender: TObject);
    procedure RowAdding(ASender: TObject; const AArgs: TThemedGridRowAddingEventArgs);
    procedure DetailDataNeeded(ASender: TObject; const AArgs: TThemedGridMasterDetailDataNeededEventArgs);
    procedure DetailRowHeightNeeded(ASender: TObject; const AArgs: TThemedGridDetailRowHeightNeededEventArgs);
    procedure DetailItemClick(ASender: TObject; const AArgs: TThemedGridDetailItemEventArgs);
    procedure CellVisualNeeded(ASender: TObject; const AArgs: TThemedGridCellVisualNeededEventArgs);
    procedure VisualClick(ASender: TObject; const AArgs: TThemedGridVisualMouseEventArgs);
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
    destructor Destroy; override;
  end;

constructor TOrder.Create(const ANumber: string; const AAmount: Double; const ADone: Boolean; const AProgress: Integer);
begin
  inherited Create;
  FNumber := ANumber;
  FAmount := AAmount;
  FDone := ADone;
  FProgress := AProgress;
end;

constructor TPerson.Create(const AName: string; const AAge: Integer; const AActive: Boolean;
  const AProgress, ARating: Integer; const AStatus: string; const AColor: TThemeColor);
begin
  inherited Create;
  FName := AName;
  FAge := AAge;
  FActive := AActive;
  FProgress := AProgress;
  FRating := ARating;
  FStatus := AStatus;
  FColor := AColor;
  FOrders := TObjectList<TOrder>.Create(True);
  FOrders.Add(TOrder.Create(Format('A-%d01', [AAge]), AAge * 12.5, True, 100));
  FOrders.Add(TOrder.Create(Format('A-%d02', [AAge]), AAge * 7.25, False, AProgress));
  if AActive then
    FOrders.Add(TOrder.Create(Format('A-%d03', [AAge]), AAge * 3.1, False, 10));
end;

destructor TPerson.Destroy;
begin
  FOrders.Free;
  inherited Destroy;
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
  FPeople := TObjectList<TPerson>.Create(True);
  FStatuses := TStringList.Create;
  FStatuses.AddStrings(['Active', 'Blocked', 'Done', 'Review', 'Running']);

  FTop := TPanel.Create(Self);
  FTop.Parent := Self;
  FTop.Align := alTop;
  FTop.Height := 36;
  FTop.BevelOuter := bvNone;

  FFilterEdit := TEdit.Create(Self);
  FFilterEdit.Parent := FTop;
  FFilterEdit.SetBounds(8, 6, 260, 24);
  FFilterEdit.TextHint := 'Filter: Name enthaelt ...';
  FFilterEdit.OnChange := FilterChanged;

  FGroupCheck := TCheckBox.Create(Self);
  FGroupCheck.Parent := FTop;
  FGroupCheck.SetBounds(284, 8, 200, 20);
  FGroupCheck.Caption := 'Gruppieren nach Status';
  FGroupCheck.OnClick := GroupChanged;

  FDesignerButton := TButton.Create(Self);
  FDesignerButton.Parent := FTop;
  FDesignerButton.SetBounds(500, 6, 160, 24);
  FDesignerButton.Caption := 'Format-Designer';
  FDesignerButton.OnClick := DesignerClick;

  FView := TThemedGridView.Create(Self);
  FView.Parent := Self;
  FView.Align := alClient;

  BuildColumns;
  BuildRows;

  LPalette := TThemePresets.GetByName('Dark');
  try
    ThemeManager.ApplyGlobal(LPalette);
  finally
    LPalette.Free;
  end;
end;

destructor TMainForm.Destroy;
begin
  inherited Destroy;
  FPeople.Free;
  FStatuses.Free;
end;

procedure TMainForm.BuildColumns;
var
  LColumn: TThemedGridColumn;
begin
  FView.EditOptions.AllowEdit := True;
  FView.EditOptions.UseRowTransactions := True;
  FView.RowActionOptions.AllowAddRows := True;
  FView.RowMoveOptions.AllowRowMove := True;
  FView.DragDropOptions.AllowDrag := True;
  FView.DragDropOptions.AllowDrop := True;
  FView.RowActionOptions.AllowRemoveRows := True;
  FView.OnRowAdding := RowAdding;
  FView.DetailOptions.Enabled := True;
  FView.DetailOptions.Relations.Add('Orders', 'Orders').MaxVisibleRows := 4;
  FView.OnMasterDetailDataNeeded := DetailDataNeeded;
  FView.OnDetailRowHeightNeeded := DetailRowHeightNeeded;
  FView.OnDetailItemClick := DetailItemClick;
  FView.OnCellVisualNeeded := CellVisualNeeded;
  FView.OnVisualClick := VisualClick;

  LColumn := FView.Columns.AddText('Name', 'Name', 'Name');
  LColumn.Width := 150;
  LColumn.EditorKind := TThemedGridEditorKind.TextBox;

  LColumn := FView.Columns.AddNumber('Age', 'Age', '0');
  LColumn.Width := 70;
  LColumn.EditorKind := TThemedGridEditorKind.Numeric;
  LColumn.EditorOptions.SetRange(0, 120);

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
  LColumn.EditorKind := TThemedGridEditorKind.Rating;

  LColumn := FView.Columns.Add('Status', 'Status', 'Status');
  LColumn.RenderKind := TThemedGridCellRenderKind.Badge;
  LColumn.Width := 110;
  LColumn.EditorKind := TThemedGridEditorKind.ComboBox;
  LColumn.EditorOptions.DataSource := FStatuses;

  LColumn := FView.Columns.Add('Color', 'Color', 'Color');
  LColumn.RenderKind := TThemedGridCellRenderKind.ColorSwatch;
  LColumn.Width := 130;
  LColumn.EditorKind := TThemedGridEditorKind.ColorPicker;
end;

procedure TMainForm.BuildRows;
begin
  FPeople.Add(TPerson.Create('Alice Weber', 34, True, 75, 4, 'Active', ThemeColor(255, 86, 156, 214)));
  FPeople.Add(TPerson.Create('Bob Schmidt', 28, False, 40, 2, 'Blocked', ThemeColor(255, 244, 71, 71)));
  FPeople.Add(TPerson.Create('Carol Meyer', 45, True, 100, 5, 'Done', ThemeColor(255, 78, 201, 176)));
  FPeople.Add(TPerson.Create('David Klein', 52, True, 60, 3, 'Review', ThemeColor(255, 220, 220, 170)));
  FPeople.Add(TPerson.Create('Eva Fischer', 39, False, 20, 1, 'Running', ThemeColor(255, 147, 112, 219)));
  FPeople.Add(TPerson.Create('Frank Wagner', 31, True, 85, 4, 'Active', ThemeColor(255, 86, 156, 214)));
  FPeople.Add(TPerson.Create('Greta Becker', 47, True, 55, 3, 'Review', ThemeColor(255, 220, 220, 170)));
  FPeople.Add(TPerson.Create('Hans Hoffmann', 23, False, 10, 1, 'Blocked', ThemeColor(255, 244, 71, 71)));
  FPeople.Add(TPerson.Create('Ina Schulz', 36, True, 95, 5, 'Done', ThemeColor(255, 78, 201, 176)));
  FPeople.Add(TPerson.Create('Jonas Koch', 29, True, 70, 4, 'Running', ThemeColor(255, 147, 112, 219)));
  FPeople.Add(TPerson.Create('Karla Richter', 58, False, 35, 2, 'Review', ThemeColor(255, 220, 220, 170)));
  FPeople.Add(TPerson.Create('Lukas Bauer', 41, True, 80, 4, 'Active', ThemeColor(255, 86, 156, 214)));
  FView.SetRows(TThemedGridListAdapter<TPerson>.Create(FPeople));
end;

procedure TMainForm.DesignerClick(Sender: TObject);
begin
  FView.ShowFormatConditionDesigner(Self);
end;

procedure TMainForm.FilterChanged(Sender: TObject);
begin
  if Trim(FFilterEdit.Text) = '' then
    FView.ClearFilters
  else
    FView.ApplyFilter('Name', TThemedGridFilterOperator.Contains, TValue.From<string>(Trim(FFilterEdit.Text)));
end;

procedure TMainForm.RowAdding(ASender: TObject; const AArgs: TThemedGridRowAddingEventArgs);
begin
  AArgs.RowObject := TValue.From<TPerson>(
    TPerson.Create('New person', 18, True, 0, 0, 'Active', ThemeColor(255, 86, 156, 214)));
end;

procedure TMainForm.DetailDataNeeded(ASender: TObject; const AArgs: TThemedGridMasterDetailDataNeededEventArgs);
var
  LPerson: TPerson;
begin
  if not AArgs.ParentRowObject.IsObject then
    Exit;
  LPerson := TPerson(AArgs.ParentRowObject.AsObject);
  AArgs.DetailItems.AddBadge('Status', LPerson.Status, 90);
  AArgs.DetailItems.AddProgress('Progress', LPerson.Progress / 100, 140);
  AArgs.DetailItems.AddRating('Rating', LPerson.Rating, 110);
  AArgs.DetailItems.AddButton('Mail', 'Mail', 70);
  AArgs.DetailGridDataSource := TValue.From<IThemedGridRowList>(
    TThemedGridListAdapter<TOrder>.Create(LPerson.Orders));
  AArgs.DetailGridColumns.Add('Number', 'Order', 'Number', 110);
  AArgs.DetailGridColumns.Add('Amount', 'Amount', 'Amount', 100);
  AArgs.DetailGridColumns.Add('Done', 'Done', 'Done', 70, TThemedGridCellRenderKind.CheckBox);
  AArgs.DetailGridColumns.Add('Progress', 'Progress', 'Progress', 140, TThemedGridCellRenderKind.ProgressBar);
  AArgs.EmptyText := 'No orders';
  AArgs.Handled := True;
end;

procedure TMainForm.DetailRowHeightNeeded(ASender: TObject; const AArgs: TThemedGridDetailRowHeightNeededEventArgs);
const
  CBaseHeight = 112;
  COrderRowHeight = 24;
  CMaxOrderRows = 4;
var
  LPerson: TPerson;
begin
  if not AArgs.ParentRowObject.IsObject then
    Exit;
  LPerson := TPerson(AArgs.ParentRowObject.AsObject);
  AArgs.Height := CBaseHeight + Min(Max(LPerson.Orders.Count, 1), CMaxOrderRows) * COrderRowHeight;
end;

procedure TMainForm.DetailItemClick(ASender: TObject; const AArgs: TThemedGridDetailItemEventArgs);
begin
  if AArgs.ItemKey = 'Mail' then
    Caption := 'NimbusForms Grid Demo - Mail: ' + TPerson(AArgs.ParentRowObject.AsObject).Name;
end;

procedure TMainForm.CellVisualNeeded(ASender: TObject; const AArgs: TThemedGridCellVisualNeededEventArgs);
const
  CDot = '<svg viewBox="0 0 16 16"><circle cx="8" cy="8" r="6" fill="currentColor"/>' +
    '<path d="M5 8.5 L7 10.5 L11 5.5" fill="none" stroke="#ffffff" stroke-width="1.6"/></svg>';
var
  LIndex: Integer;
begin
  if (AArgs.Column = nil) or (AArgs.Column.Name <> 'Status') then
    Exit;
  LIndex := AArgs.Visual.AddSvgText('dot', CDot);
  AArgs.Visual.Images[LIndex].Clickable := True;
  AArgs.Visual.Images[LIndex].ToolTip := 'Status ' + AArgs.Visual.Text;
  AArgs.Visual.Images[LIndex].Tag := TValue.From<string>(AArgs.Visual.Text);
  AArgs.Visual.ImageSize := 14;
  if AArgs.Visual.Text = 'Blocked' then
    AArgs.Visual.CurrentColor := ThemeColor(255, 229, 83, 83)
  else if AArgs.Visual.Text = 'Done' then
    AArgs.Visual.CurrentColor := ThemeColor(255, 76, 175, 80)
  else
    AArgs.Visual.CurrentColor := ThemeColor(255, 86, 156, 214);
  AArgs.Handled := True;
end;

procedure TMainForm.VisualClick(ASender: TObject; const AArgs: TThemedGridVisualMouseEventArgs);
begin
  if AArgs.Tag.TypeInfo <> nil then
    Caption := 'NimbusForms Grid Demo - Visual: ' + AArgs.Tag.ToString;
end;

procedure TMainForm.GroupChanged(Sender: TObject);
begin
  if FGroupCheck.Checked then
    FView.GroupBy('Status')
  else
    FView.ClearGrouping;
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

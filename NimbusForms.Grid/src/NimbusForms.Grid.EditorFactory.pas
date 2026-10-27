unit NimbusForms.Grid.EditorFactory;

{$SCOPEDENUMS ON}

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Cell,
  NimbusForms.Grid.EditorIntf;

type
  TThemedGridEditorFactory = class
  private
    FCache: TDictionary<TThemedGridEditorKind, IThemedGridCellEditor>;
    function CreateEditorCore(const AEditorKind: TThemedGridEditorKind): IThemedGridCellEditor;
  public
    constructor Create;
    destructor Destroy; override;
    function CreateEditor(const ACell: TThemedGridCell): IThemedGridCellEditor;
    procedure Clear;
  end;

implementation

uses
  NimbusForms.Grid.EditorControls,
  NimbusForms.Grid.Editor.Text,
  NimbusForms.Grid.Editor.Value,
  NimbusForms.Grid.Editor.Choice;

constructor TThemedGridEditorFactory.Create;
begin
  inherited Create;
  FCache := TDictionary<TThemedGridEditorKind, IThemedGridCellEditor>.Create;
end;

destructor TThemedGridEditorFactory.Destroy;
begin
  Clear;
  FCache.Free;
  inherited Destroy;
end;

procedure TThemedGridEditorFactory.Clear;
begin
  FCache.Clear;
end;

function TThemedGridEditorFactory.CreateEditor(const ACell: TThemedGridCell): IThemedGridCellEditor;
var
  LCustom: IThemedGridCellEditor;
begin
  Result := nil;
  if (ACell = nil) or (ACell.Column = nil) then
    Exit;
  if (ACell.Column.Editor <> nil) and Supports(ACell.Column.Editor, IThemedGridCellEditor, LCustom) then
    Exit(LCustom);
  if ACell.Column.EditorKind = TThemedGridEditorKind.None then
    Exit;
  if FCache.TryGetValue(ACell.Column.EditorKind, Result) then
    Exit;
  Result := CreateEditorCore(ACell.Column.EditorKind);
  if Result <> nil then
    FCache.Add(ACell.Column.EditorKind, Result);
end;

function TThemedGridEditorFactory.CreateEditorCore(const AEditorKind: TThemedGridEditorKind): IThemedGridCellEditor;
begin
  case AEditorKind of
    TThemedGridEditorKind.CheckBox: Result := TThemedGridBooleanEditor.Create(TThemedGridToggleStyle.CheckBox);
    TThemedGridEditorKind.ToggleSwitch: Result := TThemedGridBooleanEditor.Create(TThemedGridToggleStyle.Switch);
    TThemedGridEditorKind.Numeric: Result := TThemedGridNumericEditor.Create;
    TThemedGridEditorKind.Slider: Result := TThemedGridSliderEditor.Create;
    TThemedGridEditorKind.Rating: Result := TThemedGridRatingEditor.Create;
    TThemedGridEditorKind.DatePicker: Result := TThemedGridDateTimeEditor.Create(False);
    TThemedGridEditorKind.TimePicker: Result := TThemedGridDateTimeEditor.Create(True);
    TThemedGridEditorKind.ComboBox, TThemedGridEditorKind.Lookup: Result := TThemedGridComboBoxEditor.Create;
    TThemedGridEditorKind.ColorPicker: Result := TThemedGridColorEditor.Create;
    TThemedGridEditorKind.Memo: Result := TThemedGridTextEditor.Create(True);
    TThemedGridEditorKind.TextBox: Result := TThemedGridTextEditor.Create(False);
  else
    Result := nil;
  end;
end;

end.

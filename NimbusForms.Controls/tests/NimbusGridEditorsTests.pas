{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

program NimbusGridEditorsTests;

{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.Classes, System.Rtti, System.TypInfo, System.Types,
  Vcl.Forms, Vcl.Controls, NimbusForms.Controls.GridTypes, NimbusForms.Controls.GridEditors,
  NimbusForms.Controls.CheckBox, NimbusForms.Controls.ToggleBox, NimbusForms.Controls.Rating,
  NimbusForms.Controls.ComboBox, NimbusForms.Grid.Column, NimbusForms.Grid.Cell,
  NimbusForms.Controls.TextBox,
  NimbusForms.Grid.EditorIntf, NimbusForms.Grid.CellRendererIntf,
  NimbusForms.Grid.View, NimbusForms.Grid.RowList, NimbusForms.Grid.Events;

type
  TTestRow = class
  public
    Checked: Boolean;
  end;

  TValidationProbe = class
  public
    Reject: Boolean;
    Count: Integer;
    procedure Validate(Sender: TObject; const Args: TThemedGridCellValidatingEventArgs);
  end;

procedure Check(const Condition: Boolean; const MessageText: string);
begin
  if not Condition then raise Exception.Create(MessageText);
end;

procedure TValidationProbe.Validate(Sender: TObject; const Args: TThemedGridCellValidatingEventArgs);
begin
  Inc(Count);
  Args.Cancel := Reject;
end;

procedure TestAdapter(const Kind: TNimbusGridControlKind; const ValueType: PTypeInfo;
  const Original: TValue);
var
  Column: TThemedGridColumn;
  Adapter: TNimbusGridControlEditor;
  Editor: IThemedGridCellEditor;
  Renderer: IThemedGridCellRenderer;
  Context: TThemedGridCellEditContext;
  Choices: TStringList;
begin
  Column := TThemedGridColumn.Create;
  Choices := TStringList.Create;
  Context := TThemedGridCellEditContext.Create;
  try
    Choices.Add('Ready');
    Choices.Add('Done');
    Column.ValueType := ValueType;
    Column.EditorOptions.DataSource := Choices;
    Adapter := TNimbusGridControlEditor.Bind(Column, Kind);
    Check(Supports(Column.Editor, IThemedGridCellEditor, Editor), 'Editor registration');
    Check(Supports(Column.Renderer, IThemedGridCellRenderer, Renderer), 'Renderer registration');
    Check(not Adapter.Control.HandleAllocated, 'Constructor must not allocate an HWND');
    Context.Column := Column;
    Context.ValueType := ValueType;
    Context.Value := Original;
    Context.Cell := TThemedGridCell.Create;
    Context.Cell.Column := Column;
    Editor.BeginEdit(Context);
    case Kind of
      ngckCheckBox: TThemedCheckBox(Adapter.Control).Checked := False;
      ngckToggle: TThemedToggleBox(Adapter.Control).Checked := False;
      ngckRating: TThemedRatingControl(Adapter.Control).RatingValue := 3;
      ngckComboBox: TThemedComboBox(Adapter.Control).ItemIndex := 1;
    end;
    Check(Editor.GetValue.ToString <> Original.ToString, 'Native value must be read from the control');
    Editor.CancelEdit;
    Check(Editor.GetValue.ToString = Original.ToString, 'Cancel must restore the original value');
    if Kind = ngckComboBox then
    begin
      Choices.Add('Review');
      Editor.BeginEdit(Context);
      Check(TThemedComboBox(Adapter.Control).Items.Count = 3, 'Choice source must refresh on each edit');
    end;
  finally
    if Editor <> nil then Editor.AttachHooks(nil, nil);
    Context.Free;
    Column.Free;
    Renderer := nil;
    Editor := nil;
    Choices.Free;
  end;
end;

procedure TestGridPipeline;
var
  Form: TForm;
  Grid: TThemedGridView;
  Column: TThemedGridColumn;
  Row: TTestRow;
  Probe: TValidationProbe;
  Adapter: TNimbusGridControlEditor;
  Applied: TValue;
begin
  Form := TForm.CreateNew(nil);
  Row := TTestRow.Create;
  Probe := TValidationProbe.Create;
  try
    Grid := TThemedGridView.Create(Form);
    Grid.Parent := Form;
    Grid.AutoGenerateColumns := False;
    Column := Grid.Columns.Add('Checked', 'Checked', 'Checked');
    Column.ValueType := TypeInfo(Boolean);
    Column.ValueGetter := function(const ARow: TValue): TValue
      begin
        Result := TValue.From<Boolean>(TTestRow(ARow.AsObject).Checked);
      end;
    Column.ValueSetter := procedure(const ARow, AValue: TValue)
      begin
        TTestRow(ARow.AsObject).Checked := AValue.AsBoolean;
      end;
    Adapter := TNimbusGridControlEditor.Bind(Column, ngckCheckBox);
    Grid.SetRows(TThemedGridArrayAdapter<TTestRow>.Create(TArray<TTestRow>.Create(Row)));
    Grid.OnCellValidating := Probe.Validate;
    Probe.Reject := True;
    Check(not Grid.TrySetCellValue(0, 0, TValue.From<Boolean>(True), 'test', False, Applied), 'Validation rejection');
    Check(not Row.Checked, 'Rejected values must not reach the data source');
    Probe.Reject := False;
    Check(Grid.TrySetCellValue(0, 0, TValue.From<Boolean>(True), 'test', False, Applied), 'Validated value commit');
    Check(Row.Checked and (Probe.Count = 2), 'Shared validation pipeline');
    Check(Grid.Undo and not Row.Checked, 'Undo must restore the previous value');
    Check(Grid.Redo and Row.Checked, 'Redo must restore the edited value');
    Grid.SetCurrentCell(0, 0);
    Grid.BeginEditCurrentCell;
    Check(Grid.Editing, 'The grid must host the Nimbus editor');
    TThemedCheckBox(Adapter.Control).Checked := False;
    Grid.CancelEdit;
    Check(Row.Checked, 'Cancel must not alter row data');
    Check((Adapter.Control.Parent = nil) and (Adapter.Context = nil), 'Editor must detach after cancel');
    Grid.BeginEditCurrentCell;
    TThemedCheckBox(Adapter.Control).Checked := False;
    Check(Grid.CommitEdit and not Row.Checked, 'Hosted editor must commit through the data pipeline');
    Check(Grid.Undo and Row.Checked, 'Hosted edits must participate in undo');
    Column.ReadOnly := True;
    Check(not Grid.TrySetCellValue(0, 0, TValue.From<Boolean>(False), 'test', False, Applied), 'Column read only');
    Column.ReadOnly := False;
    Grid.EditOptions.AllowEdit := False;
    Grid.SetCurrentCell(0, 0);
    Grid.BeginEditCurrentCell;
    Check(not Grid.Editing, 'Grid read only must prevent editing');
  finally
    Form.Free;
    Probe.Free;
    Row.Free;
  end;
end;

procedure TestUnparentedEventControl;
var
  TextBox: TThemedTextBox;
  Adapter: TNimbusGridControlEditor;
  Editor: IThemedGridCellEditor;
  ForeignControl: TWinControl;
  Rejected: Boolean;
begin
  TextBox := TThemedTextBox.Create(nil);
  Adapter := TNimbusGridControlEditor.Create(TextBox,
    function(const AControl: TWinControl): TValue
    begin
      Result := TValue.From<string>(TThemedTextBox(AControl).Text);
    end,
    procedure(const AControl: TWinControl; const AValue: TValue)
    begin
      TThemedTextBox(AControl).Text := AValue.ToString;
    end);
  Editor := Adapter;
  ForeignControl := TWinControl.Create(nil);
  try
    Check(TextBox.Editor.Parent = nil, 'The inner editor must remain detached before hosting');
    Adapter.SetEventControl(TextBox.Editor);
    Check(Adapter.EventControl = TextBox.Editor, 'Owned inner editors must be accepted before parenting');
    Check(not TextBox.HandleAllocated and not TextBox.Editor.HandleAllocated, 'Event binding must not create windows');
    Rejected := False;
    try
      Adapter.SetEventControl(ForeignControl);
    except
      on E: EArgumentException do Rejected := True;
    end;
    Check(Rejected, 'Unrelated event controls must still be rejected');
    Check(Adapter.EventControl = TextBox.Editor, 'Rejected binding must preserve the previous event control');
  finally
    ForeignControl.Free;
    Editor := nil;
  end;
end;

procedure TestUnparentedGridLayout;
var
  Host: TWinControl;
  Grid: TThemedGridView;
begin
  Host := TWinControl.Create(nil);
  try
    Grid := TThemedGridView.Create(Host);
    Grid.Parent := Host;
    Grid.RowHeight := 42;
    Grid.Columns.Add('Value', 'Value', 'Value').Width := 160;
    Check(Grid.RowHeight = 42, 'Layout properties must work before the host receives a parent');
    Check(not Host.HandleAllocated and not Grid.HandleAllocated, 'Layout must not create windows');
  finally
    Host.Free;
  end;
end;

begin
  try
    Application.Initialize;
    TestUnparentedEventControl;
    TestUnparentedGridLayout;
    TestAdapter(ngckCheckBox, TypeInfo(Boolean), TValue.From<Boolean>(True));
    TestAdapter(ngckToggle, TypeInfo(Boolean), TValue.From<Boolean>(True));
    TestAdapter(ngckRating, TypeInfo(Integer), TValue.From<Integer>(4));
    TestAdapter(ngckComboBox, TypeInfo(string), TValue.From<string>('Ready'));
    TestGridPipeline;
    Writeln('Nimbus Grid editor tests passed');
  except
    on E: Exception do
    begin
      Writeln(E.ClassName + ': ' + E.Message);
      ExitCode := 1;
    end;
  end;
end.

{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Demo.GridEditors;

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
  NimbusForms.Grid.Column,
  NimbusForms.Grid.EditorIntf,
  NimbusForms.Grid.Events,
  NimbusForms.Grid.RowList,
  NimbusForms.Grid.View,
  NimbusForms.Controls.GridTypes,
  NimbusForms.Controls.GridEditors,
  NimbusForms.Controls.Button,
  NimbusForms.Controls.Avatar,
  NimbusForms.Controls.Panel,
  NimbusForms.Controls.CheckBox,
  NimbusForms.Controls.ToggleBox,
  NimbusForms.Controls.ThemedLabel,
  NimbusForms.Controls.ComboBox,
  NimbusForms.Controls.TextBox,
  NimbusForms.Controls.Rating,
  NimbusForms.Controls.DatePicker,
  NimbusForms.Demo.Strings;

type
  TInteractiveGridDemoRow = class
  public
    PersonName: string;
    Approved: Boolean;
    Active: Boolean;
    Rating: Double;
    Status: string;
    Deadline: TDateTime;
  end;

  TInteractiveGridDemo = class(TThemedPanel)
  private
    FGrid: TThemedGridView;
    FRows: TObjectList<TInteractiveGridDemoRow>;
    FChoices: TStringList;
    FEditors: TList<TNimbusGridControlEditor>;
    FStatus: TThemedLabel;
    FReadOnly: TThemedCheckBox;
    FRatingReadOnly: TThemedCheckBox;
    function FindEditor(Sender: TObject): TNimbusGridControlEditor;
    procedure ConfigureEditor(Sender: TObject; const AControl: TWinControl; const AContext: TThemedGridCellEditContext);
    procedure NativeChanged(Sender: TObject);
    procedure NativeAction(Sender: TObject);
    procedure ComboClosed(Sender: TObject);
    procedure ReadOnlyChanged(Sender: TObject);
    procedure RatingReadOnlyChanged(Sender: TObject);
    procedure UndoClick(Sender: TObject);
    procedure RedoClick(Sender: TObject);
    procedure CellChanged(Sender: TObject; const AArgs: TThemedGridCellValueChangedEventArgs);
    procedure ValidateCell(Sender: TObject; const AArgs: TThemedGridCellValidatingEventArgs);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Grid: TThemedGridView read FGrid;
  end;



implementation

function InteractiveGridValue(const ARow: TValue; const AField: Integer): TValue;
var
  LRow: TInteractiveGridDemoRow;
begin
  LRow := TInteractiveGridDemoRow(ARow.AsObject);
  case AField of
    0, 1: Result := TValue.From<string>(LRow.PersonName);
    2: Result := TValue.From<Boolean>(LRow.Approved);
    3: Result := TValue.From<Boolean>(LRow.Active);
    4: Result := TValue.From<Double>(LRow.Rating);
    5: Result := TValue.From<string>(LRow.Status);
    6: Result := TValue.From<TDateTime>(LRow.Deadline);
  else
    Result := TValue.From<string>('Open');
  end;
end;

procedure SetInteractiveGridValue(const ARow, AValue: TValue; const AField: Integer);
var
  LRow: TInteractiveGridDemoRow;
begin
  LRow := TInteractiveGridDemoRow(ARow.AsObject);
  case AField of
    1: LRow.PersonName := AValue.AsString;
    2: LRow.Approved := AValue.AsBoolean;
    3: LRow.Active := AValue.AsBoolean;
    4: LRow.Rating := AValue.AsExtended;
    5: LRow.Status := AValue.AsString;
    6: LRow.Deadline := AValue.AsExtended;
  end;
end;

constructor TInteractiveGridDemo.Create(AOwner: TComponent);
var
  LToolbar: TThemedPanel;
  LButton: TThemedButton;
  LRow: TInteractiveGridDemoRow;
  LColumn: TThemedGridColumn;
  LEditor: TNimbusGridControlEditor;
  LText: TThemedTextBox;
  I: Integer;
  function AddColumn(const AName: string; const AField, AWidth: Integer; const AType: PTypeInfo): TThemedGridColumn;
  begin
    Result := FGrid.Columns.Add(AName, AName, AName);
    Result.Width := AWidth;
    Result.ValueType := AType;
    Result.ValueGetter := function(const ARow: TValue): TValue
      begin
        Result := InteractiveGridValue(ARow, AField);
      end;
    Result.ValueSetter := procedure(const ARow, AValue: TValue)
      begin
        SetInteractiveGridValue(ARow, AValue, AField);
      end;
  end;
  procedure AddEditor(const AColumn: TThemedGridColumn; const AKind: TNimbusGridControlKind);
  var
    LAdapter: TNimbusGridControlEditor;
  begin
    LAdapter := TNimbusGridControlEditor.Bind(AColumn, AKind);
    LAdapter.OnConfigure := ConfigureEditor;
    FEditors.Add(LAdapter);
  end;
begin
  inherited Create(AOwner);
  Align := alClient;
  FRows := TObjectList<TInteractiveGridDemoRow>.Create(True);
  FChoices := TStringList.Create;
  FChoices.Add('Ready');
  FChoices.Add('In progress');
  FChoices.Add('Review');
  FChoices.Add('Done');
  FEditors := TList<TNimbusGridControlEditor>.Create;
  LToolbar := TThemedPanel.Create(Self);
  LToolbar.Parent := Self;
  LToolbar.Align := alTop;
  LToolbar.Height := 86;
  FReadOnly := TThemedCheckBox.Create(Self);
  FReadOnly.Parent := LToolbar;
  FReadOnly.SetBounds(12, 10, 180, 24);
  FReadOnly.Caption := 'Grid read only';
  FReadOnly.OnCheckedChanged := ReadOnlyChanged;
  FRatingReadOnly := TThemedCheckBox.Create(Self);
  FRatingReadOnly.Parent := LToolbar;
  FRatingReadOnly.SetBounds(205, 10, 190, 24);
  FRatingReadOnly.Caption := 'Ratings read only';
  FRatingReadOnly.OnCheckedChanged := RatingReadOnlyChanged;
  LButton := TThemedButton.Create(Self);
  LButton.Parent := LToolbar;
  LButton.SetBounds(415, 8, 90, 28);
  LButton.Caption := 'Undo';
  LButton.OnClick := UndoClick;
  LButton := TThemedButton.Create(Self);
  LButton.Parent := LToolbar;
  LButton.SetBounds(515, 8, 90, 28);
  LButton.Caption := 'Redo';
  LButton.OnClick := RedoClick;
  FStatus := TThemedLabel.Create(Self);
  FStatus.Parent := LToolbar;
  FStatus.AutoSize := False;
  FStatus.SetBounds(12, 46, 1100, 28);
  FStatus.Anchors := [akLeft, akTop, akRight];
  FStatus.Caption := 'Click to edit. Enter commits, Escape cancels. Sort headers and scroll to test the editors.';
  FGrid := TThemedGridView.Create(Self);
  FGrid.Parent := Self;
  FGrid.Align := alClient;
  FGrid.AutoGenerateColumns := False;
  FGrid.RowHeight := 42;
  FGrid.EditOptions.EditOnSingleClick := True;
  FGrid.OnCellValueChanged := CellChanged;
  FGrid.OnCellValidating := ValidateCell;
  AddEditor(AddColumn('Avatar', 0, 70, TypeInfo(string)), ngckAvatar);
  LColumn := AddColumn('Name', 1, 180, TypeInfo(string));
  LText := TThemedTextBox.Create(nil);
  LEditor := TNimbusGridControlEditor.Create(LText,
    function(const AControl: TWinControl): TValue
    begin
      Result := TValue.From<string>(TThemedTextBox(AControl).Text);
    end,
    procedure(const AControl: TWinControl; const AValue: TValue)
    begin
      TThemedTextBox(AControl).Text := AValue.ToString;
    end);
  LEditor.BindColumn(LColumn);
  LEditor.SetEventControl(LText.Editor);
  LEditor.OnConfigure := ConfigureEditor;
  FEditors.Add(LEditor);
  AddEditor(AddColumn('Approved', 2, 90, TypeInfo(Boolean)), ngckCheckBox);
  AddEditor(AddColumn('Active', 3, 90, TypeInfo(Boolean)), ngckToggle);
  LColumn := AddColumn('Rating', 4, 160, TypeInfo(Double));
  LColumn.EditorOptions.Maximum := 5;
  AddEditor(LColumn, ngckRating);
  LColumn := AddColumn('Status', 5, 150, TypeInfo(string));
  LColumn.EditorOptions.DataSource := FChoices;
  AddEditor(LColumn, ngckComboBox);
  LColumn := AddColumn('Deadline', 6, 200, TypeInfo(TDateTime));
  LColumn.FormatString := 'yyyy-mm-dd hh:nn';
  LColumn.EditorOptions.ShowTime := True;
  AddEditor(LColumn, ngckDateTime);
  AddEditor(AddColumn('Action', 7, 90, TypeInfo(string)), ngckButton);
  for I := 0 to 1999 do
  begin
    LRow := TInteractiveGridDemoRow.Create;
    LRow.PersonName := Format('Nimbus User %.2d', [I + 1]);
    LRow.Approved := I mod 3 <> 0;
    LRow.Active := I mod 2 = 0;
    LRow.Rating := 1 + I mod 5;
    LRow.Status := FChoices[I mod FChoices.Count];
    LRow.Deadline := Date + I + EncodeTime(9 + I mod 8, 30, 0, 0);
    FRows.Add(LRow);
  end;
  FGrid.SetRows(TThemedGridListAdapter<TInteractiveGridDemoRow>.Create(FRows));
end;

destructor TInteractiveGridDemo.Destroy;
begin
  FGrid.Free;
  FGrid := nil;
  FEditors.Free;
  FRows.Free;
  FChoices.Free;
  inherited Destroy;
end;

function TInteractiveGridDemo.FindEditor(Sender: TObject): TNimbusGridControlEditor;
var
  LEditor: TNimbusGridControlEditor;
begin
  Result := nil;
  for LEditor in FEditors do
    if (LEditor.Control = Sender) and not LEditor.Loading and (LEditor.Context <> nil) then Exit(LEditor);
end;

procedure TInteractiveGridDemo.ConfigureEditor(Sender: TObject; const AControl: TWinControl;
  const AContext: TThemedGridCellEditContext);
begin
  if AControl is TThemedCheckBox then TThemedCheckBox(AControl).OnCheckedChanged := NativeChanged
  else if AControl is TThemedToggleBox then TThemedToggleBox(AControl).OnCheckedChanged := NativeChanged
  else if AControl is TThemedRatingControl then
  begin
    TThemedRatingControl(AControl).Precision := rpHalf;
    TThemedRatingControl(AControl).OnValueChanged := NativeChanged;
  end
  else if AControl is TThemedComboBox then
  begin
    TThemedComboBox(AControl).OnChange := NativeChanged;
    TThemedComboBox(AControl).OnCloseUp := ComboClosed;
  end
  else if AControl is TThemedDatePicker then TThemedDatePicker(AControl).OnValueChanged := NativeChanged
  else if AControl is TThemedAvatar then
  begin
    TThemedAvatar(AControl).OnClick := NativeAction;
    TThemedAvatar(AControl).OnBadgeClick := NativeAction;
  end
  else if AControl is TThemedButton then TThemedButton(AControl).OnButtonClicked := NativeAction;
end;

procedure TInteractiveGridDemo.NativeChanged(Sender: TObject);
var
  LEditor: TNimbusGridControlEditor;
begin
  LEditor := FindEditor(Sender);
  if LEditor = nil then Exit;
  FStatus.Caption := Format('Native %s event for %s. Grid validation runs when the value is committed.',
    [LEditor.Context.Column.HeaderText, TInteractiveGridDemoRow(LEditor.Context.RowObject.AsObject).PersonName]);
end;

procedure TInteractiveGridDemo.NativeAction(Sender: TObject);
var
  LEditor: TNimbusGridControlEditor;
begin
  LEditor := FindEditor(Sender);
  if LEditor = nil then Exit;
  FStatus.Caption := Format('%s clicked for %s', [LEditor.Context.Column.HeaderText,
    TInteractiveGridDemoRow(LEditor.Context.RowObject.AsObject).PersonName]);
  LEditor.RequestCommit;
end;

procedure TInteractiveGridDemo.ComboClosed(Sender: TObject);
var
  LEditor: TNimbusGridControlEditor;
begin
  LEditor := FindEditor(Sender);
  if LEditor <> nil then LEditor.RequestCommit;
end;

procedure TInteractiveGridDemo.ReadOnlyChanged(Sender: TObject);
begin
  FGrid.CancelEdit;
  FGrid.EditOptions.AllowEdit := not FReadOnly.Checked;
  FGrid.Invalidate;
end;

procedure TInteractiveGridDemo.RatingReadOnlyChanged(Sender: TObject);
begin
  FGrid.CancelEdit;
  FGrid.Columns.FindByName('Rating').ReadOnly := FRatingReadOnly.Checked;
  FGrid.Invalidate;
end;

procedure TInteractiveGridDemo.UndoClick(Sender: TObject);
begin
  if FGrid.CommitEdit then FGrid.Undo;
end;

procedure TInteractiveGridDemo.RedoClick(Sender: TObject);
begin
  if FGrid.CommitEdit then FGrid.Redo;
end;

procedure TInteractiveGridDemo.CellChanged(Sender: TObject; const AArgs: TThemedGridCellValueChangedEventArgs);
begin
  FStatus.Caption := Format('Committed %s: %s -> %s',
    [AArgs.Column.HeaderText, AArgs.OldValue.ToString, AArgs.NewValue.ToString]);
end;

procedure TInteractiveGridDemo.ValidateCell(Sender: TObject; const AArgs: TThemedGridCellValidatingEventArgs);
begin
  if (AArgs.Column.Name = 'Name') and (Trim(AArgs.NewValue.ToString) = '') then
  begin
    AArgs.Cancel := True;
    AArgs.ErrorText := 'A name is required';
  end;
end;

procedure AddInteractiveNimbusGridDemo(const ATabs: TPageControl);
var
  LPage: TTabSheet;
  LDemo: TInteractiveGridDemo;
begin
  LPage := TTabSheet.Create(ATabs);
  LPage.PageControl := ATabs;
  LPage.Caption := 'Interactive Grid';
  LDemo := TInteractiveGridDemo.Create(LPage);
  LDemo.Parent := LPage;
end;


end.

unit NimbusForms.Grid.FormatConditionDesigner;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  System.Types,
  System.Math,
  System.Rtti,
  System.TypInfo,
  System.Generics.Collections,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Dialogs,
  NimbusForms.Theming.Types,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.ColumnCollection,
  NimbusForms.Grid.FormatConditionTypes,
  NimbusForms.Grid.FormatCondition,
  NimbusForms.Grid.FormatConditionValidation,
  NimbusForms.Grid.FormatConditionCollection,
  NimbusForms.Grid.FormatConditionModel,
  NimbusForms.Grid.FormatConditionSetModel,
  NimbusForms.Grid.FormatStyleModel,
  NimbusForms.Grid.FormatDesignerControls;

type
  TThemedGridFormatStyleAssign = reference to procedure(const AStyle: TThemedGridFormatStyleModel;
    const AHex: string);

  TThemedGridFormatConditionDesignerDialog = class(TForm)
  private
    FColumns: TThemedGridColumnCollection;
    FTargetConditions: TThemedGridFormatConditionCollection;
    FModel: TThemedGridFormatConditionSetModel;
    FPresets: TObjectList<TThemedGridDesignerPreset>;
    FPixelsPerInch: Integer;
    FLoading: Boolean;
    FBuilt: Boolean;
    FSelectedIndex: Integer;
    FBottomPanel: TPanel;
    FBodyPanel: TPanel;
    FLeftPanel: TPanel;
    FCenterPanel: TPanel;
    FSidePanel: TPanel;
    FRightPanel: TPanel;
    FDiagnosticsPanel: TPanel;
    FPresetsPanel: TPanel;
    FTitleLabel: TLabel;
    FDetailsLabel: TLabel;
    FStatusLabel: TLabel;
    FDiagnosticsLabel: TLabel;
    FPresetsLabel: TLabel;
    FEditorLabels: array[0..9] of TLabel;
    FEditorControls: array[0..9] of TControl;
    FNameEdit: TEdit;
    FValueEdit: TEdit;
    FValue2Edit: TEdit;
    FValuesEdit: TEdit;
    FEnabledBox: TComboBox;
    FScopeBox: TComboBox;
    FColumnBox: TComboBox;
    FTargetColumnBox: TComboBox;
    FOperatorBox: TComboBox;
    FValueTypeBox: TComboBox;
    FRuleList: TThemedGridDesignerRuleList;
    FValidationList: TThemedGridDesignerValidationList;
    FPresetList: TThemedGridDesignerPresetList;
    FPreview: TPaintBox;
    FAddButton: TThemedGridDesignerButton;
    FDuplicateButton: TThemedGridDesignerButton;
    FRemoveButton: TThemedGridDesignerButton;
    FMoveUpButton: TThemedGridDesignerButton;
    FMoveDownButton: TThemedGridDesignerButton;
    FBoldButton: TThemedGridDesignerButton;
    FItalicButton: TThemedGridDesignerButton;
    FImportButton: TThemedGridDesignerButton;
    FExportButton: TThemedGridDesignerButton;
    FValidateButton: TThemedGridDesignerButton;
    FApplyPresetButton: TThemedGridDesignerButton;
    FRefreshButton: TThemedGridDesignerButton;
    FApplyButton: TThemedGridDesignerButton;
    FOkButton: TThemedGridDesignerButton;
    FCancelButton: TThemedGridDesignerButton;
    FBackColorButton: TThemedGridDesignerColorButton;
    FForeColorButton: TThemedGridDesignerColorButton;
    FBorderColorButton: TThemedGridDesignerColorButton;
    FSelectionBackColorButton: TThemedGridDesignerColorButton;
    FHoverBackColorButton: TThemedGridDesignerColorButton;
    function S(const AValue: Integer): Integer;
    function CreatePanel(const AParent: TWinControl; const AColor: TColor): TPanel;
    function CreateLabel(const AParent: TWinControl; const AText: string; const AHeader: Boolean): TLabel;
    function CreateEdit(const AParent: TWinControl): TEdit;
    function CreateCombo(const AParent: TWinControl): TComboBox;
    function CreateButton(const AParent: TWinControl; const AText: string): TThemedGridDesignerButton;
    function CreateColorButton(const AParent: TWinControl; const AText: string): TThemedGridDesignerColorButton;
    procedure BuildLayout;
    procedure BuildDropDowns;
    procedure WireEvents;
    procedure LayoutAll;
    procedure LayoutLeft;
    procedure LayoutRight;
    procedure LayoutSide;
    procedure LayoutBottom;
    procedure AddOrdinal(const ABox: TComboBox; const AText: string; const AOrdinal: Integer);
    procedure SelectOrdinal(const ABox: TComboBox; const AOrdinal: Integer);
    function GetOrdinal(const ABox: TComboBox): Integer;
    procedure SelectText(const ABox: TComboBox; const AText: string);
    function GetText(const ABox: TComboBox): string;
    procedure RefreshRuleList;
    procedure RefreshDiagnostics;
    procedure SelectRule(const AIndex: Integer);
    procedure LoadRuleToEditors(const ARule: TThemedGridFormatConditionModel);
    procedure SaveEditorsToSelectedRule;
    function GetSelectedRule: TThemedGridFormatConditionModel;
    procedure AddNewRule;
    procedure DuplicateSelectedRule;
    procedure RemoveSelectedRule;
    procedure MoveSelectedRule(const ADirection: Integer);
    procedure ApplyToTarget;
    procedure ValidateCurrentRules;
    function BuildValidationMessage(const AResult: TThemedGridFormatConditionValidationResult): string;
    procedure ImportRules;
    procedure ExportRules;
    procedure LoadPresetList;
    function CreatePreset(const AName, APreferredColumn: string; const AScope: TThemedGridFormatConditionScope;
      const AOperator: TThemedGridFormatConditionOperator; const AValue: string;
      const AValueType: TThemedGridFormatConditionValueType; const ABackColor, AForeColor, ABorderColor: string;
      const ABold, AItalic: Boolean): TThemedGridDesignerPreset;
    function ResolvePresetColumn(const APreferredColumn: string): string;
    function BlendHex(const ASourceHex, ATargetHex: string; const AAmount: Integer): string;
    procedure ApplySelectedPreset;
    procedure UpdateStyleButtonStates(const ARule: TThemedGridFormatConditionModel);
    procedure ApplyColorButtonState(const AButton: TThemedGridDesignerColorButton; const AColor: string;
      const AFallback: TColor);
    procedure ApplySelectedColorToRule(const AColor: TColor; const AAssign: TThemedGridFormatStyleAssign);
    procedure UpdateStatus(const AText: string);
    function ColorToHex(const AColor: TColor): string;
    function ResolvePreviewText(const ARule: TThemedGridFormatConditionModel): string;
    procedure RuleListChanged(ASender: TObject);
    procedure PresetListActivate(ASender: TObject);
    procedure EditorValueChanged(ASender: TObject);
    procedure AddClick(ASender: TObject);
    procedure DuplicateClick(ASender: TObject);
    procedure RemoveClick(ASender: TObject);
    procedure MoveUpClick(ASender: TObject);
    procedure MoveDownClick(ASender: TObject);
    procedure BoldClick(ASender: TObject);
    procedure ItalicClick(ASender: TObject);
    procedure ImportClick(ASender: TObject);
    procedure ExportClick(ASender: TObject);
    procedure ValidateClick(ASender: TObject);
    procedure ApplyClick(ASender: TObject);
    procedure OkClick(ASender: TObject);
    procedure CancelClick(ASender: TObject);
    procedure ApplyPresetClick(ASender: TObject);
    procedure RefreshClick(ASender: TObject);
    procedure BackColorSelected(ASender: TObject; const AColor: TColor);
    procedure ForeColorSelected(ASender: TObject; const AColor: TColor);
    procedure BorderColorSelected(ASender: TObject; const AColor: TColor);
    procedure SelectionBackColorSelected(ASender: TObject; const AColor: TColor);
    procedure HoverBackColorSelected(ASender: TObject; const AColor: TColor);
    procedure PreviewPaint(ASender: TObject);
    procedure PanelResize(ASender: TObject);
    procedure FormKeyDown(ASender: TObject; var AKey: Word; AShift: TShiftState);
  protected
    procedure Resize; override;
    procedure DoShow; override;
  public
    constructor CreateDesigner(const AOwner: TComponent; const AColumns: TThemedGridColumnCollection;
      const AConditions: TThemedGridFormatConditionCollection; const APixelsPerInch: Integer);
    destructor Destroy; override;
    property ResultModel: TThemedGridFormatConditionSetModel read FModel;
  end;

implementation

uses
  NimbusForms.Grid.Column,
  NimbusForms.Grid.ColorValue,
  NimbusForms.Grid.FormatStyle,
  NimbusForms.Grid.FormatConditionSerializer,
  NimbusForms.Grid.FormatDesignerStrings;

type
  TStr = ThemedGridFormatDesignerStrings;

const
  COperatorOrder: array[0..16] of TThemedGridFormatConditionOperator = (
    TThemedGridFormatConditionOperator.Equals,
    TThemedGridFormatConditionOperator.NotEquals,
    TThemedGridFormatConditionOperator.Contains,
    TThemedGridFormatConditionOperator.NotContains,
    TThemedGridFormatConditionOperator.StartsWith,
    TThemedGridFormatConditionOperator.EndsWith,
    TThemedGridFormatConditionOperator.GreaterThan,
    TThemedGridFormatConditionOperator.GreaterOrEqual,
    TThemedGridFormatConditionOperator.LessThan,
    TThemedGridFormatConditionOperator.LessOrEqual,
    TThemedGridFormatConditionOperator.Between,
    TThemedGridFormatConditionOperator.&In,
    TThemedGridFormatConditionOperator.NotIn,
    TThemedGridFormatConditionOperator.IsNull,
    TThemedGridFormatConditionOperator.IsNotNull,
    TThemedGridFormatConditionOperator.IsEmpty,
    TThemedGridFormatConditionOperator.IsNotEmpty);

constructor TThemedGridFormatConditionDesignerDialog.CreateDesigner(const AOwner: TComponent;
  const AColumns: TThemedGridColumnCollection; const AConditions: TThemedGridFormatConditionCollection;
  const APixelsPerInch: Integer);
begin
  inherited CreateNew(AOwner);
  Scaled := False;
  FPixelsPerInch := APixelsPerInch;
  if FPixelsPerInch <= 0 then
    FPixelsPerInch := Screen.PixelsPerInch;
  FColumns := AColumns;
  FTargetConditions := AConditions;
  FModel := TThemedGridFormatConditionSerializer.ToModel(AConditions);
  FPresets := TObjectList<TThemedGridDesignerPreset>.Create(True);
  FSelectedIndex := -1;
  Caption := TStr.FormTitle;
  Position := poOwnerFormCenter;
  BorderStyle := bsSizeable;
  BorderIcons := [biSystemMenu, biMaximize];
  KeyPreview := True;
  Color := DesignerGray(30);
  Font.Name := TStr.FontName;
  Font.Height := -MulDiv(9, FPixelsPerInch, 72);
  Font.Color := DesignerGray(230);
  ClientWidth := S(1160);
  ClientHeight := S(700);
  Constraints.MinWidth := S(980);
  Constraints.MinHeight := S(620);
  OnKeyDown := FormKeyDown;
  BuildLayout;
  BuildDropDowns;
  WireEvents;
  LoadPresetList;
  RefreshRuleList;
  if FModel.Conditions.Count > 0 then
    SelectRule(0)
  else
    AddNewRule;
  UpdateStatus(TStr.StatusReady);
end;

destructor TThemedGridFormatConditionDesignerDialog.Destroy;
begin
  FModel.Free;
  FPresets.Free;
  inherited Destroy;
end;

function TThemedGridFormatConditionDesignerDialog.S(const AValue: Integer): Integer;
begin
  Result := MulDiv(AValue, FPixelsPerInch, 96);
end;

function TThemedGridFormatConditionDesignerDialog.CreatePanel(const AParent: TWinControl;
  const AColor: TColor): TPanel;
begin
  Result := TPanel.Create(Self);
  Result.BevelOuter := bvNone;
  Result.ParentBackground := False;
  Result.ShowCaption := False;
  Result.Color := AColor;
  Result.Parent := AParent;
end;

function TThemedGridFormatConditionDesignerDialog.CreateLabel(const AParent: TWinControl; const AText: string;
  const AHeader: Boolean): TLabel;
begin
  Result := TLabel.Create(Self);
  Result.AutoSize := False;
  Result.Transparent := True;
  Result.Layout := tlCenter;
  if AHeader then
  begin
    Result.Font.Style := [fsBold];
    Result.Font.Color := clWhite;
  end
  else
    Result.Font.Color := DesignerGray(210);
  Result.Parent := AParent;
  Result.Caption := AText;
end;

function TThemedGridFormatConditionDesignerDialog.CreateEdit(const AParent: TWinControl): TEdit;
begin
  Result := TEdit.Create(Self);
  Result.AutoSize := False;
  Result.BorderStyle := bsSingle;
  Result.StyleElements := [];
  Result.Color := TColor($00373333);
  Result.Font.Color := DesignerGray(230);
  Result.Height := S(28);
  Result.Parent := AParent;
end;

function TThemedGridFormatConditionDesignerDialog.CreateCombo(const AParent: TWinControl): TComboBox;
begin
  Result := TComboBox.Create(Self);
  Result.Style := csDropDownList;
  Result.StyleElements := [];
  Result.Color := TColor($00373333);
  Result.Font.Color := DesignerGray(230);
  Result.DropDownCount := 20;
  Result.Parent := AParent;
end;

function TThemedGridFormatConditionDesignerDialog.CreateButton(const AParent: TWinControl;
  const AText: string): TThemedGridDesignerButton;
begin
  Result := TThemedGridDesignerButton.Create(Self);
  Result.Font.Name := TStr.FontName;
  Result.Font.Height := -MulDiv(9, FPixelsPerInch, 72);
  Result.SetBounds(0, 0, S(86), S(28));
  Result.Parent := AParent;
  Result.Caption := AText;
end;

function TThemedGridFormatConditionDesignerDialog.CreateColorButton(const AParent: TWinControl;
  const AText: string): TThemedGridDesignerColorButton;
begin
  Result := TThemedGridDesignerColorButton.Create(Self);
  Result.Font.Name := TStr.FontName;
  Result.Font.Height := -MulDiv(9, FPixelsPerInch, 72);
  Result.SetBounds(0, 0, S(92), S(28));
  Result.Parent := AParent;
  Result.Caption := AText;
end;

procedure TThemedGridFormatConditionDesignerDialog.BuildLayout;
begin
  FBottomPanel := CreatePanel(Self, DesignerGray(37));
  FBottomPanel.Align := alBottom;
  FBottomPanel.Height := S(54);
  FBodyPanel := CreatePanel(Self, DesignerGray(30));
  FBodyPanel.Align := alClient;
  FLeftPanel := CreatePanel(FBodyPanel, DesignerGray(30));
  FLeftPanel.Align := alLeft;
  FLeftPanel.Width := S(330);
  FCenterPanel := CreatePanel(FBodyPanel, DesignerGray(30));
  FCenterPanel.Align := alClient;
  FSidePanel := CreatePanel(FCenterPanel, DesignerGray(27));
  FSidePanel.Align := alRight;
  FSidePanel.Width := S(330);
  FRightPanel := CreatePanel(FCenterPanel, DesignerGray(30));
  FRightPanel.Align := alClient;

  FTitleLabel := CreateLabel(FLeftPanel, TStr.RulesTitle, True);
  FRuleList := TThemedGridDesignerRuleList.Create(Self, FPixelsPerInch);
  FRuleList.Parent := FLeftPanel;
  FAddButton := CreateButton(FLeftPanel, TStr.ButtonNew);
  FDuplicateButton := CreateButton(FLeftPanel, TStr.ButtonDuplicate);
  FRemoveButton := CreateButton(FLeftPanel, TStr.ButtonRemove);
  FMoveUpButton := CreateButton(FLeftPanel, TStr.ButtonMoveUp);
  FMoveDownButton := CreateButton(FLeftPanel, TStr.ButtonMoveDown);

  FDetailsLabel := CreateLabel(FRightPanel, TStr.DetailsTitle, True);
  FNameEdit := CreateEdit(FRightPanel);
  FValueEdit := CreateEdit(FRightPanel);
  FValue2Edit := CreateEdit(FRightPanel);
  FValuesEdit := CreateEdit(FRightPanel);
  FEnabledBox := CreateCombo(FRightPanel);
  FScopeBox := CreateCombo(FRightPanel);
  FColumnBox := CreateCombo(FRightPanel);
  FTargetColumnBox := CreateCombo(FRightPanel);
  FOperatorBox := CreateCombo(FRightPanel);
  FValueTypeBox := CreateCombo(FRightPanel);

  FEditorLabels[0] := CreateLabel(FRightPanel, TStr.LabelName, False);
  FEditorControls[0] := FNameEdit;
  FEditorLabels[1] := CreateLabel(FRightPanel, TStr.LabelEnabled, False);
  FEditorControls[1] := FEnabledBox;
  FEditorLabels[2] := CreateLabel(FRightPanel, TStr.LabelScope, False);
  FEditorControls[2] := FScopeBox;
  FEditorLabels[3] := CreateLabel(FRightPanel, TStr.LabelOperator, False);
  FEditorControls[3] := FOperatorBox;
  FEditorLabels[4] := CreateLabel(FRightPanel, TStr.LabelSourceColumn, False);
  FEditorControls[4] := FColumnBox;
  FEditorLabels[5] := CreateLabel(FRightPanel, TStr.LabelTargetColumn, False);
  FEditorControls[5] := FTargetColumnBox;
  FEditorLabels[6] := CreateLabel(FRightPanel, TStr.LabelValueType, False);
  FEditorControls[6] := FValueTypeBox;
  FEditorLabels[7] := CreateLabel(FRightPanel, TStr.LabelValue, False);
  FEditorControls[7] := FValueEdit;
  FEditorLabels[8] := CreateLabel(FRightPanel, TStr.LabelValue2, False);
  FEditorControls[8] := FValue2Edit;
  FEditorLabels[9] := CreateLabel(FRightPanel, TStr.LabelValues, False);
  FEditorControls[9] := FValuesEdit;

  FBackColorButton := CreateColorButton(FRightPanel, TStr.ButtonBack);
  FForeColorButton := CreateColorButton(FRightPanel, TStr.ButtonText);
  FBorderColorButton := CreateColorButton(FRightPanel, TStr.ButtonBorder);
  FSelectionBackColorButton := CreateColorButton(FRightPanel, TStr.ButtonSelect);
  FHoverBackColorButton := CreateColorButton(FRightPanel, TStr.ButtonHover);
  FBoldButton := CreateButton(FRightPanel, TStr.ButtonBold);
  FItalicButton := CreateButton(FRightPanel, TStr.ButtonItalic);
  FPreview := TPaintBox.Create(Self);
  FPreview.Parent := FRightPanel;

  FDiagnosticsLabel := CreateLabel(FSidePanel, TStr.DiagnosticsTitle, True);
  FRefreshButton := CreateButton(FSidePanel, TStr.ButtonRefresh);
  FDiagnosticsPanel := CreatePanel(FSidePanel, TColor($00221F20));
  FValidationList := TThemedGridDesignerValidationList.Create(Self, FPixelsPerInch);
  FValidationList.Parent := FDiagnosticsPanel;
  FPresetsLabel := CreateLabel(FSidePanel, TStr.PresetsTitle, True);
  FPresetsPanel := CreatePanel(FSidePanel, TColor($00221F20));
  FPresetList := TThemedGridDesignerPresetList.Create(Self, FPixelsPerInch);
  FPresetList.Parent := FPresetsPanel;
  FApplyPresetButton := CreateButton(FPresetsPanel, TStr.ButtonApplyPreset);

  FStatusLabel := CreateLabel(FBottomPanel, '', False);
  FImportButton := CreateButton(FBottomPanel, TStr.ButtonImport);
  FExportButton := CreateButton(FBottomPanel, TStr.ButtonExport);
  FValidateButton := CreateButton(FBottomPanel, TStr.ButtonValidate);
  FApplyButton := CreateButton(FBottomPanel, TStr.ButtonApply);
  FOkButton := CreateButton(FBottomPanel, TStr.ButtonOk);
  FCancelButton := CreateButton(FBottomPanel, TStr.ButtonCancel);

  FBottomPanel.OnResize := PanelResize;
  FLeftPanel.OnResize := PanelResize;
  FRightPanel.OnResize := PanelResize;
  FSidePanel.OnResize := PanelResize;
  FPreview.OnPaint := PreviewPaint;
  FBuilt := True;
  LayoutAll;
end;

procedure TThemedGridFormatConditionDesignerDialog.BuildDropDowns;
var
  I: Integer;
  LColumn: TThemedGridColumn;
  LName: string;
begin
  AddOrdinal(FEnabledBox, TStr.ItemActive, 1);
  AddOrdinal(FEnabledBox, TStr.ItemInactive, 0);
  FEnabledBox.ItemIndex := 0;

  for I := Ord(Low(TThemedGridFormatConditionScope)) to Ord(High(TThemedGridFormatConditionScope)) do
    AddOrdinal(FScopeBox, GetEnumName(TypeInfo(TThemedGridFormatConditionScope), I), I);

  for I := Low(COperatorOrder) to High(COperatorOrder) do
    AddOrdinal(FOperatorBox, DesignerOperatorName(COperatorOrder[I]), Ord(COperatorOrder[I]));

  for I := Ord(Low(TThemedGridFormatConditionValueType)) to Ord(High(TThemedGridFormatConditionValueType)) do
    AddOrdinal(FValueTypeBox, GetEnumName(TypeInfo(TThemedGridFormatConditionValueType), I), I);

  FColumnBox.Items.Add(TStr.ItemNoColumn);
  FTargetColumnBox.Items.Add(TStr.ItemRowWide);

  if FColumns <> nil then
    for I := 0 to FColumns.Count - 1 do
    begin
      LColumn := FColumns[I];
      if LColumn = nil then
        Continue;
      if LColumn.Name <> '' then
        LName := LColumn.Name
      else
        LName := LColumn.FieldName;
      if LName = '' then
        LName := LColumn.HeaderText;
      if LName = '' then
        Continue;
      FColumnBox.Items.Add(LName);
      FTargetColumnBox.Items.Add(LName);
    end;

  FScopeBox.ItemIndex := 0;
  FOperatorBox.ItemIndex := 0;
  FValueTypeBox.ItemIndex := 0;
  FColumnBox.ItemIndex := 0;
  FTargetColumnBox.ItemIndex := 0;
end;

procedure TThemedGridFormatConditionDesignerDialog.WireEvents;
begin
  FRuleList.OnSelectedIndexChanged := RuleListChanged;
  FPresetList.OnItemActivate := PresetListActivate;
  FAddButton.OnClick := AddClick;
  FDuplicateButton.OnClick := DuplicateClick;
  FRemoveButton.OnClick := RemoveClick;
  FMoveUpButton.OnClick := MoveUpClick;
  FMoveDownButton.OnClick := MoveDownClick;
  FBackColorButton.OnColorSelected := BackColorSelected;
  FForeColorButton.OnColorSelected := ForeColorSelected;
  FBorderColorButton.OnColorSelected := BorderColorSelected;
  FSelectionBackColorButton.OnColorSelected := SelectionBackColorSelected;
  FHoverBackColorButton.OnColorSelected := HoverBackColorSelected;
  FBoldButton.OnClick := BoldClick;
  FItalicButton.OnClick := ItalicClick;
  FImportButton.OnClick := ImportClick;
  FExportButton.OnClick := ExportClick;
  FValidateButton.OnClick := ValidateClick;
  FApplyButton.OnClick := ApplyClick;
  FOkButton.OnClick := OkClick;
  FCancelButton.OnClick := CancelClick;
  FApplyPresetButton.OnClick := ApplyPresetClick;
  FRefreshButton.OnClick := RefreshClick;
  FNameEdit.OnChange := EditorValueChanged;
  FValueEdit.OnChange := EditorValueChanged;
  FValue2Edit.OnChange := EditorValueChanged;
  FValuesEdit.OnChange := EditorValueChanged;
  FEnabledBox.OnChange := EditorValueChanged;
  FScopeBox.OnChange := EditorValueChanged;
  FColumnBox.OnChange := EditorValueChanged;
  FTargetColumnBox.OnChange := EditorValueChanged;
  FOperatorBox.OnChange := EditorValueChanged;
  FValueTypeBox.OnChange := EditorValueChanged;
end;

procedure TThemedGridFormatConditionDesignerDialog.LayoutAll;
begin
  if not FBuilt then
    Exit;
  LayoutLeft;
  LayoutRight;
  LayoutSide;
  LayoutBottom;
end;

procedure TThemedGridFormatConditionDesignerDialog.LayoutLeft;
var
  LWidth: Integer;
  LButtonsTop: Integer;
  LButtonWidth: Integer;
  LButtonHeight: Integer;
  LGap: Integer;
  LButtons: array[0..4] of TThemedGridDesignerButton;
  LColumns: array[0..4] of Integer;
  LRows: array[0..4] of Integer;
  I: Integer;
begin
  LWidth := FLeftPanel.ClientWidth;
  LButtonsTop := FLeftPanel.ClientHeight - S(10) - S(110);
  FTitleLabel.SetBounds(S(10), S(10), Max(0, LWidth - S(20)), S(28));
  FRuleList.SetBounds(S(10), S(38), Max(0, LWidth - S(20)), Max(0, LButtonsTop - S(38)));
  LButtonWidth := S(145);
  LButtonHeight := S(28);
  LGap := S(6);
  LButtons[0] := FAddButton;
  LButtons[1] := FDuplicateButton;
  LButtons[2] := FRemoveButton;
  LButtons[3] := FMoveUpButton;
  LButtons[4] := FMoveDownButton;
  LColumns[0] := 0;
  LColumns[1] := 1;
  LColumns[2] := 0;
  LColumns[3] := 1;
  LColumns[4] := 0;
  LRows[0] := 0;
  LRows[1] := 0;
  LRows[2] := 1;
  LRows[3] := 1;
  LRows[4] := 2;
  for I := 0 to 4 do
    LButtons[I].SetBounds(S(10) + LColumns[I] * (LButtonWidth + LGap), LButtonsTop + LRows[I] * (LButtonHeight + LGap),
      LButtonWidth, LButtonHeight);
end;

procedure TThemedGridFormatConditionDesignerDialog.LayoutRight;
var
  LWidth: Integer;
  LLeft: Integer;
  LLabelWidth: Integer;
  LEditWidth: Integer;
  LColumnLeft: Integer;
  LRowTop: Integer;
  LRow: Integer;
  LColumn: Integer;
  LControl: TControl;
  LStyleTop: Integer;
  LFlowX: Integer;
  LFlowY: Integer;
  LStyleButtons: array[0..6] of TThemedGridDesignerButton;
  I: Integer;
begin
  LWidth := Max(0, FRightPanel.ClientWidth - S(24));
  LLeft := S(12);
  FDetailsLabel.SetBounds(LLeft, S(10), LWidth, S(28));
  LLabelWidth := S(112);
  LEditWidth := Max(S(40), (LWidth - 2 * LLabelWidth) div 2);
  for I := 0 to 9 do
  begin
    LRow := I div 2;
    LColumn := I mod 2;
    LRowTop := S(38) + LRow * S(36);
    if LColumn = 0 then
    begin
      LColumnLeft := LLeft;
      FEditorLabels[I].SetBounds(LColumnLeft, LRowTop + S(4), LLabelWidth - S(8), S(28));
    end
    else
    begin
      LColumnLeft := LLeft + LLabelWidth + LEditWidth;
      FEditorLabels[I].SetBounds(LColumnLeft + S(12), LRowTop + S(4), LLabelWidth - S(20), S(28));
    end;
    LControl := FEditorControls[I];
    LControl.SetBounds(LColumnLeft + LLabelWidth, LRowTop + (S(36) - LControl.Height) div 2, LEditWidth,
      LControl.Height);
  end;
  LStyleTop := S(38) + S(188) + S(8);
  LStyleButtons[0] := FBackColorButton;
  LStyleButtons[1] := FForeColorButton;
  LStyleButtons[2] := FBorderColorButton;
  LStyleButtons[3] := FSelectionBackColorButton;
  LStyleButtons[4] := FHoverBackColorButton;
  LStyleButtons[5] := FBoldButton;
  LStyleButtons[6] := FItalicButton;
  LFlowX := 0;
  LFlowY := 0;
  for I := 0 to 6 do
  begin
    if (LFlowX > 0) and (LFlowX + LStyleButtons[I].Width + S(6) > LWidth) then
    begin
      LFlowX := 0;
      Inc(LFlowY, S(34));
    end;
    LStyleButtons[I].SetBounds(LLeft + LFlowX + S(3), LStyleTop + LFlowY + S(3), LStyleButtons[I].Width,
      LStyleButtons[I].Height);
    Inc(LFlowX, LStyleButtons[I].Width + S(6));
  end;
  FPreview.SetBounds(LLeft, S(38) + S(188) + S(82), LWidth, S(88));
end;

procedure TThemedGridFormatConditionDesignerDialog.LayoutSide;
var
  LWidth: Integer;
  LLeft: Integer;
  LPresetsTop: Integer;
  LPresetsHeight: Integer;
begin
  LWidth := Max(0, FSidePanel.ClientWidth - S(20));
  LLeft := S(10);
  FDiagnosticsLabel.SetBounds(LLeft, S(10), LWidth, S(26));
  FRefreshButton.SetBounds(LLeft, S(10) + S(26) + S(3), S(86), S(28));
  FDiagnosticsPanel.SetBounds(LLeft, S(72), LWidth, S(210));
  FValidationList.SetBounds(0, S(4), LWidth, S(210) - S(12));
  FPresetsLabel.SetBounds(LLeft, S(72) + S(210) + S(8), LWidth, S(26));
  LPresetsTop := S(72) + S(210) + S(34);
  LPresetsHeight := Max(S(120), FSidePanel.ClientHeight - S(10) - LPresetsTop);
  FPresetsPanel.SetBounds(LLeft, LPresetsTop, LWidth, LPresetsHeight);
  FPresetList.SetBounds(0, S(4), LWidth, Max(0, LPresetsHeight - S(4) - S(40)));
  FApplyPresetButton.SetBounds(0, LPresetsHeight - S(40) + S(6), S(132), S(28));
end;

procedure TThemedGridFormatConditionDesignerDialog.LayoutBottom;
var
  LRight: Integer;
  LButtons: array[0..5] of TThemedGridDesignerButton;
  I: Integer;
begin
  LButtons[0] := FCancelButton;
  LButtons[1] := FOkButton;
  LButtons[2] := FApplyButton;
  LButtons[3] := FValidateButton;
  LButtons[4] := FExportButton;
  LButtons[5] := FImportButton;
  LRight := FBottomPanel.ClientWidth - S(10);
  for I := 0 to 5 do
  begin
    LButtons[I].SetBounds(LRight - S(3) - S(86), S(8) + S(3), S(86), S(28));
    Dec(LRight, S(92));
  end;
  FStatusLabel.SetBounds(S(12), S(8), Max(0, FBottomPanel.ClientWidth - S(10) - S(570) - S(12)), S(38));
end;

procedure TThemedGridFormatConditionDesignerDialog.PanelResize(ASender: TObject);
begin
  LayoutAll;
end;

procedure TThemedGridFormatConditionDesignerDialog.Resize;
begin
  inherited Resize;
  LayoutAll;
end;

procedure TThemedGridFormatConditionDesignerDialog.DoShow;
begin
  LayoutAll;
  inherited DoShow;
end;

procedure TThemedGridFormatConditionDesignerDialog.AddOrdinal(const ABox: TComboBox; const AText: string;
  const AOrdinal: Integer);
begin
  ABox.Items.AddObject(AText, TObject(NativeInt(AOrdinal)));
end;

procedure TThemedGridFormatConditionDesignerDialog.SelectOrdinal(const ABox: TComboBox; const AOrdinal: Integer);
var
  I: Integer;
begin
  for I := 0 to ABox.Items.Count - 1 do
    if Integer(NativeInt(ABox.Items.Objects[I])) = AOrdinal then
    begin
      ABox.ItemIndex := I;
      Exit;
    end;
  if ABox.Items.Count > 0 then
    ABox.ItemIndex := 0
  else
    ABox.ItemIndex := -1;
end;

function TThemedGridFormatConditionDesignerDialog.GetOrdinal(const ABox: TComboBox): Integer;
begin
  if ABox.ItemIndex < 0 then
    Exit(0);
  Result := Integer(NativeInt(ABox.Items.Objects[ABox.ItemIndex]));
end;

procedure TThemedGridFormatConditionDesignerDialog.SelectText(const ABox: TComboBox; const AText: string);
var
  I: Integer;
begin
  if AText = '' then
  begin
    ABox.ItemIndex := 0;
    Exit;
  end;
  for I := 1 to ABox.Items.Count - 1 do
    if ABox.Items[I] = AText then
    begin
      ABox.ItemIndex := I;
      Exit;
    end;
  ABox.ItemIndex := ABox.Items.Add(AText);
end;

function TThemedGridFormatConditionDesignerDialog.GetText(const ABox: TComboBox): string;
begin
  if ABox.ItemIndex <= 0 then
    Exit('');
  Result := ABox.Items[ABox.ItemIndex];
end;

procedure TThemedGridFormatConditionDesignerDialog.RefreshRuleList;
begin
  FRuleList.SetItems(FModel.Conditions, FColumns);
  RefreshDiagnostics;
end;

procedure TThemedGridFormatConditionDesignerDialog.RefreshDiagnostics;
var
  LCollection: TThemedGridFormatConditionCollection;
  LResult: TThemedGridFormatConditionValidationResult;
begin
  if FValidationList = nil then
    Exit;
  LCollection := TThemedGridFormatConditionSerializer.FromModel(FModel);
  try
    LResult := TThemedGridFormatConditionSerializer.Validate(LCollection, FColumns);
    try
      FValidationList.SetResult(LResult);
    finally
      LResult.Free;
    end;
  finally
    LCollection.Free;
  end;
end;

procedure TThemedGridFormatConditionDesignerDialog.SelectRule(const AIndex: Integer);
begin
  if (AIndex < 0) or (AIndex >= FModel.Conditions.Count) then
  begin
    FSelectedIndex := -1;
    FRuleList.SetSelectedIndexSilent(-1);
    LoadRuleToEditors(nil);
    Exit;
  end;
  FSelectedIndex := AIndex;
  FRuleList.SetSelectedIndexSilent(AIndex);
  LoadRuleToEditors(FModel.Conditions[AIndex]);
end;

procedure TThemedGridFormatConditionDesignerDialog.LoadRuleToEditors(const ARule: TThemedGridFormatConditionModel);
var
  I: Integer;
  LJoined: string;
begin
  FLoading := True;
  try
    if ARule = nil then
    begin
      FNameEdit.Text := '';
      FValueEdit.Text := '';
      FValue2Edit.Text := '';
      FValuesEdit.Text := '';
      Exit;
    end;
    FNameEdit.Text := ARule.Name;
    SelectOrdinal(FEnabledBox, Ord(ARule.Enabled));
    SelectOrdinal(FScopeBox, Ord(ARule.Scope));
    SelectOrdinal(FOperatorBox, Ord(ARule.Operator));
    SelectOrdinal(FValueTypeBox, Ord(ARule.ValueType));
    SelectText(FColumnBox, ARule.ColumnName);
    SelectText(FTargetColumnBox, ARule.TargetColumnName);
    FValueEdit.Text := DesignerValueText(ARule.Value);
    FValue2Edit.Text := DesignerValueText(ARule.Value2);
    LJoined := '';
    for I := 0 to ARule.Values.Count - 1 do
    begin
      if I > 0 then
        LJoined := LJoined + TStr.ValuesSeparator;
      LJoined := LJoined + DesignerValueText(ARule.Values[I]);
    end;
    FValuesEdit.Text := LJoined;
    UpdateStyleButtonStates(ARule);
    FPreview.Invalidate;
  finally
    FLoading := False;
  end;
end;

procedure TThemedGridFormatConditionDesignerDialog.SaveEditorsToSelectedRule;
var
  LRule: TThemedGridFormatConditionModel;
  LParts: TArray<string>;
  LText: string;
  I: Integer;
begin
  if FLoading then
    Exit;
  LRule := GetSelectedRule;
  if LRule = nil then
    Exit;
  LRule.Name := FNameEdit.Text;
  LRule.Enabled := GetOrdinal(FEnabledBox) = 1;
  LRule.Scope := TThemedGridFormatConditionScope(GetOrdinal(FScopeBox));
  LRule.Operator := TThemedGridFormatConditionOperator(GetOrdinal(FOperatorBox));
  LRule.ValueType := TThemedGridFormatConditionValueType(GetOrdinal(FValueTypeBox));
  LRule.ColumnName := GetText(FColumnBox);
  LRule.TargetColumnName := GetText(FTargetColumnBox);
  LRule.Value := TValue.From<string>(FValueEdit.Text);
  LRule.Value2 := TValue.From<string>(FValue2Edit.Text);
  if LRule.Scope = TThemedGridFormatConditionScope.Row then
    LRule.TargetColumnName := '';
  LRule.Values.Clear;
  LText := FValuesEdit.Text;
  LParts := LText.Split([';', #10, #13], TStringSplitOptions.ExcludeEmpty);
  for I := 0 to High(LParts) do
    LRule.Values.Add(TValue.From<string>(Trim(LParts[I])));
  RefreshRuleList;
  FPreview.Invalidate;
end;

function TThemedGridFormatConditionDesignerDialog.GetSelectedRule: TThemedGridFormatConditionModel;
begin
  if (FSelectedIndex < 0) or (FSelectedIndex >= FModel.Conditions.Count) then
    Exit(nil);
  Result := FModel.Conditions[FSelectedIndex];
end;

procedure TThemedGridFormatConditionDesignerDialog.AddNewRule;
var
  LRule: TThemedGridFormatConditionModel;
begin
  LRule := TThemedGridFormatConditionModel.Create;
  LRule.Name := TStr.NewRuleName;
  LRule.Enabled := True;
  LRule.Scope := TThemedGridFormatConditionScope.Cell;
  LRule.Operator := TThemedGridFormatConditionOperator.Equals;
  LRule.ValueType := TThemedGridFormatConditionValueType.Auto;
  LRule.Style := TThemedGridFormatStyleModel.Create;
  LRule.Style.BackColor := TStr.NewRuleBackColor;
  LRule.Style.ForeColor := TStr.NewRuleForeColor;
  FModel.Conditions.Add(LRule);
  RefreshRuleList;
  SelectRule(FModel.Conditions.Count - 1);
  UpdateStatus(TStr.StatusRuleCreated);
end;

procedure TThemedGridFormatConditionDesignerDialog.DuplicateSelectedRule;
var
  LSelected: TThemedGridFormatConditionModel;
  LCondition: TThemedGridFormatCondition;
  LClone: TThemedGridFormatConditionModel;
  LInsertIndex: Integer;
begin
  LSelected := GetSelectedRule;
  if LSelected = nil then
    Exit;
  LCondition := TThemedGridFormatConditionSerializer.FromModel(LSelected);
  try
    LClone := TThemedGridFormatConditionSerializer.ToModel(LCondition);
  finally
    LCondition.Free;
  end;
  if LClone.Name = '' then
    LClone.Name := TStr.DefaultRuleName;
  LClone.Name := LClone.Name + TStr.RuleCopySuffix;
  LInsertIndex := FSelectedIndex + 1;
  FModel.Conditions.Insert(LInsertIndex, LClone);
  RefreshRuleList;
  SelectRule(LInsertIndex);
  UpdateStatus(TStr.StatusRuleDuplicated);
end;

procedure TThemedGridFormatConditionDesignerDialog.RemoveSelectedRule;
var
  LNextIndex: Integer;
begin
  if (FSelectedIndex < 0) or (FSelectedIndex >= FModel.Conditions.Count) then
    Exit;
  FModel.Conditions.Delete(FSelectedIndex);
  LNextIndex := FSelectedIndex;
  if LNextIndex >= FModel.Conditions.Count then
    LNextIndex := FModel.Conditions.Count - 1;
  RefreshRuleList;
  SelectRule(LNextIndex);
  UpdateStatus(TStr.StatusRuleRemoved);
end;

procedure TThemedGridFormatConditionDesignerDialog.MoveSelectedRule(const ADirection: Integer);
var
  LNewIndex: Integer;
begin
  if (FSelectedIndex < 0) or (FSelectedIndex >= FModel.Conditions.Count) then
    Exit;
  LNewIndex := FSelectedIndex + ADirection;
  if (LNewIndex < 0) or (LNewIndex >= FModel.Conditions.Count) then
    Exit;
  FModel.Conditions.Move(FSelectedIndex, LNewIndex);
  RefreshRuleList;
  SelectRule(LNewIndex);
  UpdateStatus(TStr.StatusRuleMoved);
end;

procedure TThemedGridFormatConditionDesignerDialog.ApplyToTarget;
var
  LCollection: TThemedGridFormatConditionCollection;
begin
  SaveEditorsToSelectedRule;
  LCollection := TThemedGridFormatConditionSerializer.FromModel(FModel);
  try
    FTargetConditions.ReplaceAllFrom(LCollection);
    FTargetConditions.SetEnabled(FModel.Enabled);
  finally
    LCollection.Free;
  end;
  UpdateStatus(TStr.StatusApplied);
end;

function TThemedGridFormatConditionDesignerDialog.BuildValidationMessage(
  const AResult: TThemedGridFormatConditionValidationResult): string;
var
  LIssue: TThemedGridFormatConditionValidationIssue;
  LKind: string;
  I: Integer;
begin
  Result := '';
  for I := 0 to AResult.Issues.Count - 1 do
  begin
    LIssue := AResult.Issues[I];
    if LIssue = nil then
      Continue;
    if LIssue.IsError then
      LKind := TStr.IssueError
    else
      LKind := TStr.IssueHint;
    if Result <> '' then
      Result := Result + sLineBreak;
    Result := Result + Format(TStr.IssueLineFormat, [LKind, LIssue.Index, LIssue.Message]);
  end;
end;

procedure TThemedGridFormatConditionDesignerDialog.ValidateCurrentRules;
var
  LCollection: TThemedGridFormatConditionCollection;
  LResult: TThemedGridFormatConditionValidationResult;
  LFlags: UINT;
begin
  SaveEditorsToSelectedRule;
  LCollection := TThemedGridFormatConditionSerializer.FromModel(FModel);
  try
    LResult := TThemedGridFormatConditionSerializer.Validate(LCollection, FColumns);
    try
      FValidationList.SetResult(LResult);
      if LResult.Issues.Count = 0 then
      begin
        UpdateStatus(TStr.StatusValidationClean);
        Winapi.Windows.MessageBox(Handle, PChar(TStr.MessageAllValid), PChar(TStr.MessageTitle),
          MB_OK or MB_ICONINFORMATION);
        Exit;
      end;
      UpdateStatus(Format(TStr.StatusValidationIssues, [LResult.Issues.Count]));
      if LResult.HasErrors then
        LFlags := MB_OK or MB_ICONERROR
      else
        LFlags := MB_OK or MB_ICONWARNING;
      Winapi.Windows.MessageBox(Handle, PChar(BuildValidationMessage(LResult)),
        PChar(TStr.MessageValidationTitle), LFlags);
    finally
      LResult.Free;
    end;
  finally
    LCollection.Free;
  end;
end;

procedure TThemedGridFormatConditionDesignerDialog.ImportRules;
var
  LDialog: TOpenDialog;
  LLoaded: TThemedGridFormatConditionCollection;
  LLoadedModel: TThemedGridFormatConditionSetModel;
begin
  LDialog := TOpenDialog.Create(Self);
  try
    LDialog.Filter := TStr.JsonFilter;
    if not LDialog.Execute(Handle) then
      Exit;
    try
      LLoaded := TThemedGridFormatConditionSerializer.LoadFromFile(LDialog.FileName);
    except
      on E: Exception do
      begin
        UpdateStatus(Format(TStr.StatusImportFailed, [E.Message]));
        Exit;
      end;
    end;
    try
      LLoadedModel := TThemedGridFormatConditionSerializer.ToModel(LLoaded);
      try
        FSelectedIndex := -1;
        FRuleList.SetItems(nil, FColumns);
        FModel.Conditions.Clear;
        while LLoadedModel.Conditions.Count > 0 do
          FModel.Conditions.Add(LLoadedModel.Conditions.Extract(LLoadedModel.Conditions[0]));
        FModel.Enabled := LLoadedModel.Enabled;
      finally
        LLoadedModel.Free;
      end;
    finally
      LLoaded.Free;
    end;
    RefreshRuleList;
    if FModel.Conditions.Count > 0 then
      SelectRule(0)
    else
      SelectRule(-1);
    UpdateStatus(TStr.StatusImportDone);
  finally
    LDialog.Free;
  end;
end;

procedure TThemedGridFormatConditionDesignerDialog.ExportRules;
var
  LDialog: TSaveDialog;
  LCollection: TThemedGridFormatConditionCollection;
begin
  SaveEditorsToSelectedRule;
  LDialog := TSaveDialog.Create(Self);
  try
    LDialog.Filter := TStr.JsonFilter;
    LDialog.FileName := TStr.ExportFileName;
    if not LDialog.Execute(Handle) then
      Exit;
    LCollection := TThemedGridFormatConditionSerializer.FromModel(FModel);
    try
      TThemedGridFormatConditionSerializer.SaveToFile(LCollection, LDialog.FileName);
    finally
      LCollection.Free;
    end;
    UpdateStatus(TStr.StatusExportDone);
  finally
    LDialog.Free;
  end;
end;

function TThemedGridFormatConditionDesignerDialog.ResolvePresetColumn(const APreferredColumn: string): string;
var
  I: Integer;
  LColumn: TThemedGridColumn;
begin
  if DesignerColumnExists(FColumns, APreferredColumn) then
    Exit(APreferredColumn);
  if (FColumns <> nil) and (FColumns.Count > 0) then
    for I := 0 to FColumns.Count - 1 do
    begin
      LColumn := FColumns[I];
      if LColumn = nil then
        Continue;
      if LColumn.Name <> '' then
        Exit(LColumn.Name);
      if LColumn.FieldName <> '' then
        Exit(LColumn.FieldName);
      if LColumn.HeaderText <> '' then
        Exit(LColumn.HeaderText);
    end;
  Result := APreferredColumn;
end;

function TThemedGridFormatConditionDesignerDialog.BlendHex(const ASourceHex, ATargetHex: string;
  const AAmount: Integer): string;
var
  LSource: TThemeColor;
  LTarget: TThemeColor;
  LAmount: Integer;
  LRed: Integer;
  LGreen: Integer;
  LBlue: Integer;
begin
  if not TThemedGridColorValue.TryParse(ASourceHex, LSource) then
    LSource := ThemeColor(255, 45, 45, 48);
  if not TThemedGridColorValue.TryParse(ATargetHex, LTarget) then
    LTarget := ThemeColor(255, 255, 255, 255);
  LAmount := EnsureRange(AAmount, 0, 255);
  LRed := ThemeColorRed(LSource) + ((ThemeColorRed(LTarget) - ThemeColorRed(LSource)) * LAmount div 255);
  LGreen := ThemeColorGreen(LSource) + ((ThemeColorGreen(LTarget) - ThemeColorGreen(LSource)) * LAmount div 255);
  LBlue := ThemeColorBlue(LSource) + ((ThemeColorBlue(LTarget) - ThemeColorBlue(LSource)) * LAmount div 255);
  Result := Format(TStr.HexFormat, [LRed, LGreen, LBlue]);
end;

function TThemedGridFormatConditionDesignerDialog.CreatePreset(const AName, APreferredColumn: string;
  const AScope: TThemedGridFormatConditionScope; const AOperator: TThemedGridFormatConditionOperator;
  const AValue: string; const AValueType: TThemedGridFormatConditionValueType;
  const ABackColor, AForeColor, ABorderColor: string; const ABold, AItalic: Boolean): TThemedGridDesignerPreset;
var
  LModel: TThemedGridFormatConditionModel;
begin
  LModel := TThemedGridFormatConditionModel.Create;
  LModel.Name := AName;
  LModel.Enabled := True;
  LModel.Scope := AScope;
  LModel.ColumnName := ResolvePresetColumn(APreferredColumn);
  if AScope = TThemedGridFormatConditionScope.Row then
    LModel.TargetColumnName := ''
  else
    LModel.TargetColumnName := LModel.ColumnName;
  LModel.Operator := AOperator;
  LModel.Value := TValue.From<string>(AValue);
  LModel.ValueType := AValueType;
  LModel.Style := TThemedGridFormatStyleModel.Create;
  LModel.Style.BackColor := ABackColor;
  LModel.Style.ForeColor := AForeColor;
  LModel.Style.BorderColor := ABorderColor;
  LModel.Style.SelectionBackColor := BlendHex(ABackColor, TStr.HexWhite, 42);
  LModel.Style.HoverBackColor := BlendHex(ABackColor, TStr.HexWhite, 22);
  LModel.Style.Bold := ABold;
  LModel.Style.Italic := AItalic;
  Result := TThemedGridDesignerPreset.Create(AName,
    Format(TStr.PresetDescriptionFormat, [APreferredColumn, DesignerOperatorName(AOperator), AValue]), LModel);
end;

procedure TThemedGridFormatConditionDesignerDialog.LoadPresetList;
var
  LItems: TList<TThemedGridDesignerPreset>;
begin
  FPresets.Clear;
  FPresets.Add(CreatePreset(TStr.PresetStatusBlocked, TStr.ColumnStatus, TThemedGridFormatConditionScope.Cell,
    TThemedGridFormatConditionOperator.Equals, TStr.ValueBlocked, TThemedGridFormatConditionValueType.&String,
    '#5A2D2D', '#FFD2D2', '#B85F5F', True, False));
  FPresets.Add(CreatePreset(TStr.PresetStatusDone, TStr.ColumnStatus, TThemedGridFormatConditionScope.Cell,
    TThemedGridFormatConditionOperator.Equals, TStr.ValueDone, TThemedGridFormatConditionValueType.&String,
    '#234B2D', '#D2FFDC', '#5EAA73', False, False));
  FPresets.Add(CreatePreset(TStr.PresetAmountHigh, TStr.ColumnAmount, TThemedGridFormatConditionScope.Cell,
    TThemedGridFormatConditionOperator.GreaterThan, TStr.ValueAmountHigh,
    TThemedGridFormatConditionValueType.&Decimal, '#3C411E', '#FFF0AA', '#AF872D', True, False));
  FPresets.Add(CreatePreset(TStr.PresetProgressLow, TStr.ColumnProgress, TThemedGridFormatConditionScope.Cell,
    TThemedGridFormatConditionOperator.LessThan, TStr.ValueProgressLow,
    TThemedGridFormatConditionValueType.&Decimal, '#55461E', '#FFEBAA', '#B87832', True, False));
  FPresets.Add(CreatePreset(TStr.PresetRatingStrong, TStr.ColumnRating, TThemedGridFormatConditionScope.Cell,
    TThemedGridFormatConditionOperator.GreaterOrEqual, TStr.ValueRatingStrong,
    TThemedGridFormatConditionValueType.&Decimal, '#284B5F', '#D2F0FF', '#69A9CB', True, False));
  FPresets.Add(CreatePreset(TStr.PresetActiveFalse, TStr.ColumnActive, TThemedGridFormatConditionScope.Cell,
    TThemedGridFormatConditionOperator.Equals, TStr.ValueFalse, TThemedGridFormatConditionValueType.Boolean,
    '#3C3C3C', '#AAAAAA', '#707070', False, False));
  FPresets.Add(CreatePreset(TStr.PresetBlockedRow, TStr.ColumnStatus, TThemedGridFormatConditionScope.Row,
    TThemedGridFormatConditionOperator.Equals, TStr.ValueBlocked, TThemedGridFormatConditionValueType.&String,
    '#2D1E1E', '#F5DCDC', '#693737', True, False));
  FPresets.Add(CreatePreset(TStr.PresetReviewTarget, TStr.ColumnStatus,
    TThemedGridFormatConditionScope.TargetColumn, TThemedGridFormatConditionOperator.Equals, TStr.ValueReview,
    TThemedGridFormatConditionValueType.&String, '#372D5A', '#E6DCFF', '#695AAA', False, True));
  LItems := TList<TThemedGridDesignerPreset>.Create;
  try
    LItems.AddRange(FPresets);
    FPresetList.SetItems(LItems);
  finally
    LItems.Free;
  end;
end;

procedure TThemedGridFormatConditionDesignerDialog.ApplySelectedPreset;
var
  LPreset: TThemedGridDesignerPreset;
  LCondition: TThemedGridFormatCondition;
  LModel: TThemedGridFormatConditionModel;
begin
  LPreset := FPresetList.SelectedPreset;
  if (LPreset = nil) or (LPreset.Model = nil) then
    Exit;
  LCondition := TThemedGridFormatConditionSerializer.FromModel(LPreset.Model);
  try
    LModel := TThemedGridFormatConditionSerializer.ToModel(LCondition);
  finally
    LCondition.Free;
  end;
  if LModel = nil then
    Exit;
  if LModel.Name = '' then
    LModel.Name := LPreset.Name;
  FModel.Conditions.Add(LModel);
  RefreshRuleList;
  SelectRule(FModel.Conditions.Count - 1);
  UpdateStatus(Format(TStr.StatusPresetApplied, [LPreset.Name]));
end;

function TThemedGridFormatConditionDesignerDialog.ColorToHex(const AColor: TColor): string;
var
  LRgb: Integer;
begin
  LRgb := ColorToRGB(AColor);
  Result := Format(TStr.HexFormat, [GetRValue(LRgb), GetGValue(LRgb), GetBValue(LRgb)]);
end;

procedure TThemedGridFormatConditionDesignerDialog.UpdateStyleButtonStates(const ARule: TThemedGridFormatConditionModel);
var
  LStyle: TThemedGridFormatStyleModel;
begin
  if ARule <> nil then
    LStyle := ARule.Style
  else
    LStyle := nil;
  if LStyle <> nil then
  begin
    ApplyColorButtonState(FBackColorButton, LStyle.BackColor, TColor(RGB(60, 65, 30)));
    ApplyColorButtonState(FForeColorButton, LStyle.ForeColor, TColor(RGB(255, 240, 170)));
    ApplyColorButtonState(FBorderColorButton, LStyle.BorderColor, TColor(RGB(110, 110, 110)));
    ApplyColorButtonState(FSelectionBackColorButton, LStyle.SelectionBackColor, TColor(RGB(80, 120, 170)));
    ApplyColorButtonState(FHoverBackColorButton, LStyle.HoverBackColor, TColor(RGB(55, 55, 58)));
  end
  else
  begin
    ApplyColorButtonState(FBackColorButton, '', TColor(RGB(60, 65, 30)));
    ApplyColorButtonState(FForeColorButton, '', TColor(RGB(255, 240, 170)));
    ApplyColorButtonState(FBorderColorButton, '', TColor(RGB(110, 110, 110)));
    ApplyColorButtonState(FSelectionBackColorButton, '', TColor(RGB(80, 120, 170)));
    ApplyColorButtonState(FHoverBackColorButton, '', TColor(RGB(55, 55, 58)));
  end;
  if (LStyle <> nil) and LStyle.Bold then
    FBoldButton.Caption := TStr.ButtonBoldOn
  else
    FBoldButton.Caption := TStr.ButtonBold;
  if (LStyle <> nil) and LStyle.Italic then
    FItalicButton.Caption := TStr.ButtonItalicOn
  else
    FItalicButton.Caption := TStr.ButtonItalic;
end;

procedure TThemedGridFormatConditionDesignerDialog.ApplyColorButtonState(const AButton: TThemedGridDesignerColorButton;
  const AColor: string; const AFallback: TColor);
var
  LParsed: TThemeColor;
begin
  if TThemedGridColorValue.TryParse(AColor, LParsed) then
    AButton.SelectedColor := ThemeColorToColor(LParsed)
  else
    AButton.SelectedColor := AFallback;
end;

procedure TThemedGridFormatConditionDesignerDialog.ApplySelectedColorToRule(const AColor: TColor;
  const AAssign: TThemedGridFormatStyleAssign);
var
  LRule: TThemedGridFormatConditionModel;
begin
  LRule := GetSelectedRule;
  if (LRule = nil) or not Assigned(AAssign) then
    Exit;
  if LRule.Style = nil then
    LRule.Style := TThemedGridFormatStyleModel.Create;
  AAssign(LRule.Style, ColorToHex(AColor));
  UpdateStyleButtonStates(LRule);
  FPreview.Invalidate;
  RefreshRuleList;
end;

procedure TThemedGridFormatConditionDesignerDialog.BackColorSelected(ASender: TObject; const AColor: TColor);
begin
  ApplySelectedColorToRule(AColor,
    procedure(const AStyle: TThemedGridFormatStyleModel; const AHex: string)
    begin
      AStyle.BackColor := AHex;
    end);
end;

procedure TThemedGridFormatConditionDesignerDialog.ForeColorSelected(ASender: TObject; const AColor: TColor);
begin
  ApplySelectedColorToRule(AColor,
    procedure(const AStyle: TThemedGridFormatStyleModel; const AHex: string)
    begin
      AStyle.ForeColor := AHex;
    end);
end;

procedure TThemedGridFormatConditionDesignerDialog.BorderColorSelected(ASender: TObject; const AColor: TColor);
begin
  ApplySelectedColorToRule(AColor,
    procedure(const AStyle: TThemedGridFormatStyleModel; const AHex: string)
    begin
      AStyle.BorderColor := AHex;
    end);
end;

procedure TThemedGridFormatConditionDesignerDialog.SelectionBackColorSelected(ASender: TObject;
  const AColor: TColor);
begin
  ApplySelectedColorToRule(AColor,
    procedure(const AStyle: TThemedGridFormatStyleModel; const AHex: string)
    begin
      AStyle.SelectionBackColor := AHex;
    end);
end;

procedure TThemedGridFormatConditionDesignerDialog.HoverBackColorSelected(ASender: TObject; const AColor: TColor);
begin
  ApplySelectedColorToRule(AColor,
    procedure(const AStyle: TThemedGridFormatStyleModel; const AHex: string)
    begin
      AStyle.HoverBackColor := AHex;
    end);
end;

procedure TThemedGridFormatConditionDesignerDialog.UpdateStatus(const AText: string);
begin
  FStatusLabel.Caption := AText;
end;

function TThemedGridFormatConditionDesignerDialog.ResolvePreviewText(const ARule: TThemedGridFormatConditionModel): string;
var
  LName: string;
  LColumn: string;
begin
  if ARule.Name = '' then
    LName := TStr.PreviewDefaultName
  else
    LName := ARule.Name;
  if ARule.ColumnName = '' then
    LColumn := TStr.PreviewMissingSource
  else
    LColumn := ARule.ColumnName;
  Result := Format(TStr.PreviewFormat, [LName, LColumn, DesignerOperatorName(ARule.Operator),
    DesignerValueText(ARule.Value)]);
end;

procedure TThemedGridFormatConditionDesignerDialog.PreviewPaint(ASender: TObject);
var
  LRule: TThemedGridFormatConditionModel;
  LStyle: TThemedGridFormatStyle;
  LBack: TColor;
  LFore: TColor;
  LBorder: TColor;
  LBounds: TRect;
  LText: string;
  LFontStyles: TFontStyles;
begin
  LRule := GetSelectedRule;
  if (LRule <> nil) and (LRule.Style <> nil) then
    LStyle := LRule.Style.ToStyle
  else
    LStyle := TThemedGridFormatStyle.Create;
  try
    LBack := TColor(RGB(45, 45, 48));
    LFore := DesignerGray(230);
    LBorder := DesignerGray(80);
    if LStyle.HasBackColor then
      LBack := ThemeColorToColor(LStyle.BackColor);
    if LStyle.HasForeColor then
      LFore := ThemeColorToColor(LStyle.ForeColor);
    if LStyle.HasBorderColor then
      LBorder := ThemeColorToColor(LStyle.BorderColor);
    FPreview.Canvas.Brush.Style := bsSolid;
    FPreview.Canvas.Brush.Color := DesignerGray(30);
    FPreview.Canvas.FillRect(Rect(0, 0, FPreview.Width, FPreview.Height));
    LBounds := Rect(S(2), S(10), FPreview.Width - S(2), FPreview.Height - S(8));
    FPreview.Canvas.Brush.Color := LBack;
    FPreview.Canvas.Pen.Color := LBorder;
    FPreview.Canvas.Rectangle(LBounds);
    FPreview.Canvas.Font.Assign(Font);
    LFontStyles := [];
    if LStyle.Bold then
      Include(LFontStyles, fsBold);
    if LStyle.Italic then
      Include(LFontStyles, fsItalic);
    FPreview.Canvas.Font.Style := LFontStyles;
    FPreview.Canvas.Font.Color := LFore;
    FPreview.Canvas.Brush.Style := bsClear;
    if LRule <> nil then
      LText := ResolvePreviewText(LRule)
    else
      LText := TStr.PreviewText;
    FPreview.Canvas.TextRect(LBounds, LText, [tfCenter, tfVerticalCenter, tfSingleLine, tfEndEllipsis, tfNoPrefix]);
    FPreview.Canvas.Brush.Style := bsSolid;
  finally
    LStyle.Free;
  end;
end;

procedure TThemedGridFormatConditionDesignerDialog.FormKeyDown(ASender: TObject; var AKey: Word;
  AShift: TShiftState);
begin
  if AKey = VK_ESCAPE then
  begin
    ModalResult := mrCancel;
    AKey := 0;
    Exit;
  end;
  if (ssCtrl in AShift) and (AKey = Ord('S')) then
  begin
    ApplyToTarget;
    AKey := 0;
    Exit;
  end;
  if (ssCtrl in AShift) and (AKey = Ord('N')) then
  begin
    AddNewRule;
    AKey := 0;
    Exit;
  end;
  if (AKey = VK_DELETE) and FRuleList.Focused then
  begin
    RemoveSelectedRule;
    AKey := 0;
  end;
end;

procedure TThemedGridFormatConditionDesignerDialog.RuleListChanged(ASender: TObject);
var
  LNewIndex: Integer;
begin
  if FLoading then
    Exit;
  LNewIndex := FRuleList.SelectedIndex;
  SaveEditorsToSelectedRule;
  SelectRule(LNewIndex);
end;

procedure TThemedGridFormatConditionDesignerDialog.PresetListActivate(ASender: TObject);
begin
  ApplySelectedPreset;
end;

procedure TThemedGridFormatConditionDesignerDialog.EditorValueChanged(ASender: TObject);
begin
  SaveEditorsToSelectedRule;
end;

procedure TThemedGridFormatConditionDesignerDialog.AddClick(ASender: TObject);
begin
  AddNewRule;
end;

procedure TThemedGridFormatConditionDesignerDialog.DuplicateClick(ASender: TObject);
begin
  DuplicateSelectedRule;
end;

procedure TThemedGridFormatConditionDesignerDialog.RemoveClick(ASender: TObject);
begin
  RemoveSelectedRule;
end;

procedure TThemedGridFormatConditionDesignerDialog.MoveUpClick(ASender: TObject);
begin
  MoveSelectedRule(-1);
end;

procedure TThemedGridFormatConditionDesignerDialog.MoveDownClick(ASender: TObject);
begin
  MoveSelectedRule(1);
end;

procedure TThemedGridFormatConditionDesignerDialog.BoldClick(ASender: TObject);
var
  LRule: TThemedGridFormatConditionModel;
begin
  LRule := GetSelectedRule;
  if LRule = nil then
    Exit;
  if LRule.Style = nil then
    LRule.Style := TThemedGridFormatStyleModel.Create;
  LRule.Style.Bold := not LRule.Style.Bold;
  UpdateStyleButtonStates(LRule);
  FPreview.Invalidate;
end;

procedure TThemedGridFormatConditionDesignerDialog.ItalicClick(ASender: TObject);
var
  LRule: TThemedGridFormatConditionModel;
begin
  LRule := GetSelectedRule;
  if LRule = nil then
    Exit;
  if LRule.Style = nil then
    LRule.Style := TThemedGridFormatStyleModel.Create;
  LRule.Style.Italic := not LRule.Style.Italic;
  UpdateStyleButtonStates(LRule);
  FPreview.Invalidate;
end;

procedure TThemedGridFormatConditionDesignerDialog.ImportClick(ASender: TObject);
begin
  ImportRules;
end;

procedure TThemedGridFormatConditionDesignerDialog.ExportClick(ASender: TObject);
begin
  ExportRules;
end;

procedure TThemedGridFormatConditionDesignerDialog.ValidateClick(ASender: TObject);
begin
  ValidateCurrentRules;
end;

procedure TThemedGridFormatConditionDesignerDialog.ApplyClick(ASender: TObject);
begin
  ApplyToTarget;
end;

procedure TThemedGridFormatConditionDesignerDialog.OkClick(ASender: TObject);
begin
  ApplyToTarget;
  ModalResult := mrOk;
end;

procedure TThemedGridFormatConditionDesignerDialog.CancelClick(ASender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TThemedGridFormatConditionDesignerDialog.ApplyPresetClick(ASender: TObject);
begin
  ApplySelectedPreset;
end;

procedure TThemedGridFormatConditionDesignerDialog.RefreshClick(ASender: TObject);
begin
  SaveEditorsToSelectedRule;
  RefreshDiagnostics;
  UpdateStatus(TStr.StatusDiagnosticsRefreshed);
end;

end.

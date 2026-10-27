unit NimbusForms.Grid.HeaderFilterPopup;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  System.Types,
  System.Rtti,
  System.TypInfo,
  System.Math,
  System.Generics.Collections,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Graphics,
  System.UITypes,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Buttons,
  Vcl.ComCtrls,
  NimbusForms.Theming.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.FilterDescriptor,
  NimbusForms.Grid.DistinctValue,
  NimbusForms.Grid.DistinctValueList;

type
  TThemedGridDistinctValueLoader = reference to function: TObjectList<TThemedGridDistinctValue>;

  TThemedGridFilterEditorKind = (Text, Number, Date, Bool);

  TThemedGridHeaderFilterPopup = class(TForm)
  private
    FColumn: TThemedGridColumn;
    FValueType: PTypeInfo;
    FKind: TThemedGridFilterEditorKind;
    FCurrentFilter: TThemedGridFilterDescriptor;
    FLoader: TThemedGridDistinctValueLoader;
    FFilter: TThemedGridFilterDescriptor;
    FPixelsPerInch: Integer;
    FClearRequested: Boolean;
    FDistinctLoaded: Boolean;
    FUpdatingOperator: Boolean;
    FAccentColor: TColor;
    FContent: TPanel;
    FTitlePanel: TPanel;
    FTitleLabel: TLabel;
    FCloseButton: TSpeedButton;
    FOperatorLabel: TLabel;
    FValueLabel: TLabel;
    FValue2Label: TLabel;
    FSelectionStateLabel: TLabel;
    FOperatorBox: TComboBox;
    FTextValueBox: TEdit;
    FTextValue2Box: TEdit;
    FNumberValueBox: TEdit;
    FNumberValue2Box: TEdit;
    FDateValueBox: TDateTimePicker;
    FDateValue2Box: TDateTimePicker;
    FBoolValueBox: TCheckBox;
    FDistinctSearchBox: TEdit;
    FDistinctList: TThemedGridDistinctValueList;
    FSelectAllButton: TButton;
    FSelectNoneButton: TButton;
    FOkButton: TButton;
    FClearButton: TButton;
    FCancelButton: TButton;
    function S(const AValue: Integer): Integer;
    procedure Place(const AControl: TControl; const AX, AY, AWidth, AHeight: Integer);
    function CreateLabel(const AText: string; const AX, AY, AWidth, AHeight: Integer): TLabel;
    function CreateTextBox(const AX, AY, AWidth, AHeight: Integer; const ACue: string): TEdit;
    function CreateDateBox(const AX, AY, AWidth, AHeight: Integer): TDateTimePicker;
    function CreateButton(const AText: string; const AX, AY, AWidth, AHeight: Integer): TButton;
    procedure ResolveKind;
    function IsDateTimeWithTime: Boolean;
    procedure FillOperators;
    procedure AddOperator(const AOperator: TThemedGridFilterOperator; const AText: string);
    function GetSelectedOperator: TThemedGridFilterOperator;
    procedure SelectOperator(const AOperator: TThemedGridFilterOperator);
    procedure LoadFilter(const AFilter: TThemedGridFilterDescriptor);
    procedure SetEditorValue(const AValue: TValue; const ASecondValue: Boolean);
    function TryGetEditorValue(const ASecondValue: Boolean; out AValue: TValue): Boolean;
    procedure UpdateValueEditors;
    procedure ApplyNormalLayout(const ANeedsSecondValue: Boolean);
    procedure ApplyDistinctLayout;
    procedure EnsureDistinctValuesLoaded;
    procedure UpdateSelectionState;
    procedure ShowSelectionMessage(const AText: string; const AColor: TColor);
    procedure CommitFilter;
    procedure OperatorBoxChange(ASender: TObject);
    procedure DistinctSearchChange(ASender: TObject);
    procedure SelectAllClick(ASender: TObject);
    procedure SelectNoneClick(ASender: TObject);
    procedure DistinctSelectionChanged(ASender: TObject);
    procedure OkClick(ASender: TObject);
    procedure ClearClick(ASender: TObject);
    procedure CancelClick(ASender: TObject);
    procedure FormDeactivate(ASender: TObject);
    procedure FormKeyDown(ASender: TObject; var AKey: Word; AShift: TShiftState);
    class function NeedsValue(const AOperator: TThemedGridFilterOperator): Boolean; static;
  public
    constructor CreatePopup(const AOwner: TComponent; const AColumn: TThemedGridColumn;
      const AValueType: PTypeInfo; const ACurrentFilter: TThemedGridFilterDescriptor;
      const ALoader: TThemedGridDistinctValueLoader; const APixelsPerInch: Integer);
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette);
    property Filter: TThemedGridFilterDescriptor read FFilter;
    property ClearRequested: Boolean read FClearRequested;
  end;

implementation

uses
  NimbusForms.Grid.ValueConverter,
  NimbusForms.Grid.ValueFormatter,
  NimbusForms.Grid.EditorSupport,
  NimbusForms.Grid.FilterStrings;

const
  CTitleHeight = 28;
  CWarningColor = TColor($0000A5FF);
  CSuccessColor = TColor($0050AF4C);
  CErrorColor = TColor($005353E5);

type
  TStr = ThemedGridFilterStrings;

constructor TThemedGridHeaderFilterPopup.CreatePopup(const AOwner: TComponent; const AColumn: TThemedGridColumn;
  const AValueType: PTypeInfo; const ACurrentFilter: TThemedGridFilterDescriptor;
  const ALoader: TThemedGridDistinctValueLoader; const APixelsPerInch: Integer);
begin
  inherited CreateNew(AOwner);
  Scaled := False;
  Name := TStr.PopupName;
  FColumn := AColumn;
  FValueType := AValueType;
  FLoader := ALoader;
  FPixelsPerInch := Max(96, APixelsPerInch);
  if ACurrentFilter <> nil then
    FCurrentFilter := ACurrentFilter.Clone;
  FAccentColor := clHighlight;
  ResolveKind;

  BorderStyle := bsNone;
  Position := poDesigned;
  KeyPreview := True;
  Font.Name := 'Segoe UI';
  Font.Height := -MulDiv(12, FPixelsPerInch, 96);
  Color := clBtnShadow;
  OnDeactivate := FormDeactivate;
  OnKeyDown := FormKeyDown;
  ClientWidth := S(360);
  ClientHeight := S(210);

  FContent := TPanel.Create(Self);
  FContent.Parent := Self;
  FContent.Align := alClient;
  FContent.AlignWithMargins := True;
  FContent.Margins.SetBounds(1, 1, 1, 1);
  FContent.BevelOuter := bvNone;
  FContent.ParentBackground := False;
  FContent.ShowCaption := False;

  FTitlePanel := TPanel.Create(Self);
  FTitlePanel.Parent := FContent;
  FTitlePanel.Align := alTop;
  FTitlePanel.Height := S(CTitleHeight);
  FTitlePanel.BevelOuter := bvNone;
  FTitlePanel.ParentBackground := False;
  FTitlePanel.ShowCaption := False;

  FTitleLabel := TLabel.Create(Self);
  FTitleLabel.AutoSize := False;
  FTitleLabel.Parent := FTitlePanel;
  FTitleLabel.Caption := AColumn.GetBestHeaderText;
  FTitleLabel.Font.Style := [fsBold];
  FTitleLabel.Transparent := True;
  FTitleLabel.AutoSize := False;
  FTitleLabel.Layout := tlCenter;
  FTitleLabel.SetBounds(S(10), 0, S(300), S(CTitleHeight));

  FCloseButton := TSpeedButton.Create(Self);
  FCloseButton.Parent := FTitlePanel;
  FCloseButton.Flat := True;
  FCloseButton.Caption := TStr.CloseGlyph;
  FCloseButton.SetBounds(S(330), 0, S(28), S(CTitleHeight));
  FCloseButton.OnClick := CancelClick;

  FOperatorLabel := CreateLabel(TStr.OperatorLabel, 12, 12, 78, 24);
  FOperatorBox := TComboBox.Create(Self);
  FOperatorBox.Parent := FContent;
  FOperatorBox.Style := csDropDownList;
  Place(FOperatorBox, 96, 12, 232, 24);
  FOperatorBox.OnChange := OperatorBoxChange;

  FValueLabel := CreateLabel(TStr.ValueLabel, 12, 46, 78, 24);
  FTextValueBox := CreateTextBox(96, 46, 232, 26, TStr.ValueCue);
  FNumberValueBox := CreateTextBox(96, 46, 232, 26, TStr.ValueCue);
  FDateValueBox := CreateDateBox(96, 46, 232, 26);
  FBoolValueBox := TCheckBox.Create(Self);
  FBoolValueBox.Parent := FContent;
  FBoolValueBox.Caption := TStr.BoolCaption;
  Place(FBoolValueBox, 96, 48, 232, 26);

  FValue2Label := CreateLabel(TStr.SecondValueLabel, 12, 80, 78, 24);
  FTextValue2Box := CreateTextBox(96, 80, 232, 26, TStr.SecondValueCue);
  FNumberValue2Box := CreateTextBox(96, 80, 232, 26, TStr.SecondValueCue);
  FDateValue2Box := CreateDateBox(96, 80, 232, 26);

  FDistinctSearchBox := CreateTextBox(12, 46, 316, 26, TStr.SearchValuesCue);
  FDistinctSearchBox.OnChange := DistinctSearchChange;

  FSelectAllButton := CreateButton(TStr.SelectAll, 12, 80, 72, 26);
  FSelectAllButton.OnClick := SelectAllClick;
  FSelectNoneButton := CreateButton(TStr.SelectNone, 88, 80, 72, 26);
  FSelectNoneButton.OnClick := SelectNoneClick;
  FSelectionStateLabel := CreateLabel('', 166, 80, 162, 26);

  FDistinctList := TThemedGridDistinctValueList.Create(Self);
  FDistinctList.Parent := FContent;
  Place(FDistinctList, 12, 114, 316, 202);
  FDistinctList.OnSelectionChanged := DistinctSelectionChanged;

  FOkButton := CreateButton(TStr.ButtonOk, 100, 327, 72, 26);
  FOkButton.Default := True;
  FOkButton.OnClick := OkClick;
  FClearButton := CreateButton(TStr.ButtonClear, 176, 327, 72, 26);
  FClearButton.OnClick := ClearClick;
  FCancelButton := CreateButton(TStr.ButtonCancel, 252, 327, 76, 26);
  FCancelButton.Cancel := True;
  FCancelButton.OnClick := CancelClick;

  FillOperators;
  LoadFilter(FCurrentFilter);
  UpdateValueEditors;
end;

destructor TThemedGridHeaderFilterPopup.Destroy;
begin
  FFilter.Free;
  FCurrentFilter.Free;
  inherited Destroy;
end;

function TThemedGridHeaderFilterPopup.S(const AValue: Integer): Integer;
begin
  Result := MulDiv(AValue, FPixelsPerInch, 96);
end;

procedure TThemedGridHeaderFilterPopup.Place(const AControl: TControl; const AX, AY, AWidth, AHeight: Integer);
begin
  AControl.SetBounds(S(AX), S(CTitleHeight + AY), S(AWidth), S(AHeight));
end;

function TThemedGridHeaderFilterPopup.CreateLabel(const AText: string; const AX, AY, AWidth,
  AHeight: Integer): TLabel;
begin
  Result := TLabel.Create(Self);
  Result.AutoSize := False;
  Result.Parent := FContent;
  Result.Caption := AText;
  Result.Layout := tlCenter;
  Result.Transparent := True;
  Place(Result, AX, AY, AWidth, AHeight);
end;

function TThemedGridHeaderFilterPopup.CreateTextBox(const AX, AY, AWidth, AHeight: Integer;
  const ACue: string): TEdit;
begin
  Result := TEdit.Create(Self);
  Result.Parent := FContent;
  Result.TextHint := ACue;
  Place(Result, AX, AY, AWidth, AHeight);
end;

function TThemedGridHeaderFilterPopup.CreateDateBox(const AX, AY, AWidth, AHeight: Integer): TDateTimePicker;
begin
  Result := TDateTimePicker.Create(Self);
  Result.Parent := FContent;
  if FValueType = TypeInfo(TTime) then
  begin
    Result.Kind := dtkTime;
    Result.Format := TStr.TimeOnlyFormat;
  end
  else
  begin
    Result.Kind := dtkDate;
    if IsDateTimeWithTime then
      Result.Format := TStr.DateTimeFormat
    else
      Result.Format := TStr.DateOnlyFormat;
  end;
  Result.DateTime := Now;
  Place(Result, AX, AY, AWidth, AHeight);
end;

function TThemedGridHeaderFilterPopup.CreateButton(const AText: string; const AX, AY, AWidth,
  AHeight: Integer): TButton;
begin
  Result := TButton.Create(Self);
  Result.Parent := FContent;
  Result.Caption := AText;
  Place(Result, AX, AY, AWidth, AHeight);
end;

procedure TThemedGridHeaderFilterPopup.ResolveKind;
var
  LTypeData: PTypeData;
begin
  FKind := TThemedGridFilterEditorKind.Text;
  if FValueType = nil then
    Exit;
  if (FValueType = TypeInfo(TDateTime)) or (FValueType = TypeInfo(TDate)) or (FValueType = TypeInfo(TTime)) then
  begin
    FKind := TThemedGridFilterEditorKind.Date;
    Exit;
  end;
  if FValueType.Kind = tkEnumeration then
  begin
    LTypeData := GetTypeData(FValueType);
    if (FValueType = TypeInfo(Boolean)) or ((LTypeData <> nil) and (LTypeData.BaseType <> nil) and
      (LTypeData.BaseType^ = TypeInfo(Boolean))) then
      FKind := TThemedGridFilterEditorKind.Bool;
    Exit;
  end;
  if FValueType.Kind in [tkInteger, tkInt64, tkFloat] then
    FKind := TThemedGridFilterEditorKind.Number;
end;

function TThemedGridHeaderFilterPopup.IsDateTimeWithTime: Boolean;
var
  LFormat: string;
begin
  if FColumn = nil then
    Exit(False);
  if FColumn.RenderKind in [TThemedGridCellRenderKind.DateTime, TThemedGridCellRenderKind.Time] then
    Exit(True);
  LFormat := FColumn.FormatString;
  if LFormat = '' then
    Exit(False);
  Result := (Pos('H', LFormat) > 0) or (Pos('h', LFormat) > 0) or (Pos('m', LFormat) > 0) or
    (Pos('s', LFormat) > 0);
end;

procedure TThemedGridHeaderFilterPopup.AddOperator(const AOperator: TThemedGridFilterOperator; const AText: string);
begin
  FOperatorBox.Items.AddObject(AText, TObject(NativeInt(Ord(AOperator))));
end;

procedure TThemedGridHeaderFilterPopup.FillOperators;
begin
  FUpdatingOperator := True;
  try
    FOperatorBox.Items.BeginUpdate;
    try
      FOperatorBox.Items.Clear;
      case FKind of
        TThemedGridFilterEditorKind.Bool:
          begin
            AddOperator(TThemedGridFilterOperator.Equals, TStr.OperatorEquals);
            AddOperator(TThemedGridFilterOperator.NotEquals, TStr.OperatorNotEquals);
            AddOperator(TThemedGridFilterOperator.IsNull, TStr.OperatorIsNull);
            AddOperator(TThemedGridFilterOperator.IsNotNull, TStr.OperatorIsNotNull);
          end;
        TThemedGridFilterEditorKind.Date:
          begin
            AddOperator(TThemedGridFilterOperator.Equals, TStr.OperatorEquals);
            AddOperator(TThemedGridFilterOperator.NotEquals, TStr.OperatorNotEquals);
            AddOperator(TThemedGridFilterOperator.GreaterThan, TStr.OperatorAfter);
            AddOperator(TThemedGridFilterOperator.GreaterOrEqual, TStr.OperatorFrom);
            AddOperator(TThemedGridFilterOperator.LessThan, TStr.OperatorBefore);
            AddOperator(TThemedGridFilterOperator.LessOrEqual, TStr.OperatorUntil);
            AddOperator(TThemedGridFilterOperator.Between, TStr.OperatorBetween);
            AddOperator(TThemedGridFilterOperator.Today, TStr.OperatorToday);
            AddOperator(TThemedGridFilterOperator.Yesterday, TStr.OperatorYesterday);
            AddOperator(TThemedGridFilterOperator.ThisWeek, TStr.OperatorThisWeek);
            AddOperator(TThemedGridFilterOperator.ThisMonth, TStr.OperatorThisMonth);
            AddOperator(TThemedGridFilterOperator.ThisYear, TStr.OperatorThisYear);
            AddOperator(TThemedGridFilterOperator.IsNull, TStr.OperatorIsNull);
            AddOperator(TThemedGridFilterOperator.IsNotNull, TStr.OperatorIsNotNull);
          end;
        TThemedGridFilterEditorKind.Number:
          begin
            AddOperator(TThemedGridFilterOperator.Equals, TStr.OperatorEquals);
            AddOperator(TThemedGridFilterOperator.NotEquals, TStr.OperatorNotEquals);
            AddOperator(TThemedGridFilterOperator.GreaterThan, TStr.OperatorGreaterThan);
            AddOperator(TThemedGridFilterOperator.GreaterOrEqual, TStr.OperatorGreaterOrEqual);
            AddOperator(TThemedGridFilterOperator.LessThan, TStr.OperatorLessThan);
            AddOperator(TThemedGridFilterOperator.LessOrEqual, TStr.OperatorLessOrEqual);
            AddOperator(TThemedGridFilterOperator.Between, TStr.OperatorBetween);
            AddOperator(TThemedGridFilterOperator.IsNull, TStr.OperatorIsNull);
            AddOperator(TThemedGridFilterOperator.IsNotNull, TStr.OperatorIsNotNull);
          end;
      else
        AddOperator(TThemedGridFilterOperator.Contains, TStr.OperatorContains);
        AddOperator(TThemedGridFilterOperator.NotContains, TStr.OperatorNotContains);
        AddOperator(TThemedGridFilterOperator.StartsWith, TStr.OperatorStartsWith);
        AddOperator(TThemedGridFilterOperator.EndsWith, TStr.OperatorEndsWith);
        AddOperator(TThemedGridFilterOperator.Equals, TStr.OperatorEquals);
        AddOperator(TThemedGridFilterOperator.NotEquals, TStr.OperatorNotEquals);
        AddOperator(TThemedGridFilterOperator.IsEmpty, TStr.OperatorIsEmpty);
        AddOperator(TThemedGridFilterOperator.IsNotEmpty, TStr.OperatorIsNotEmpty);
        AddOperator(TThemedGridFilterOperator.IsNull, TStr.OperatorIsNull);
        AddOperator(TThemedGridFilterOperator.IsNotNull, TStr.OperatorIsNotNull);
      end;
      AddOperator(TThemedGridFilterOperator.&In, TStr.OperatorIn);
      AddOperator(TThemedGridFilterOperator.NotIn, TStr.OperatorNotIn);
    finally
      FOperatorBox.Items.EndUpdate;
    end;
    if FOperatorBox.Items.Count > 0 then
      FOperatorBox.ItemIndex := 0;
  finally
    FUpdatingOperator := False;
  end;
end;

function TThemedGridHeaderFilterPopup.GetSelectedOperator: TThemedGridFilterOperator;
begin
  if FOperatorBox.ItemIndex < 0 then
    Exit(TThemedGridFilterOperator.Equals);
  Result := TThemedGridFilterOperator(NativeInt(FOperatorBox.Items.Objects[FOperatorBox.ItemIndex]));
end;

procedure TThemedGridHeaderFilterPopup.SelectOperator(const AOperator: TThemedGridFilterOperator);
var
  I: Integer;
begin
  for I := 0 to FOperatorBox.Items.Count - 1 do
    if TThemedGridFilterOperator(NativeInt(FOperatorBox.Items.Objects[I])) = AOperator then
    begin
      FOperatorBox.ItemIndex := I;
      Exit;
    end;
end;

procedure TThemedGridHeaderFilterPopup.LoadFilter(const AFilter: TThemedGridFilterDescriptor);
begin
  if AFilter = nil then
    Exit;
  SelectOperator(AFilter.Operator);
  if (AFilter.Operator = TThemedGridFilterOperator.&In) or (AFilter.Operator = TThemedGridFilterOperator.NotIn) then
    Exit;
  SetEditorValue(AFilter.Value, False);
  SetEditorValue(AFilter.Value2, True);
end;

procedure TThemedGridHeaderFilterPopup.SetEditorValue(const AValue: TValue; const ASecondValue: Boolean);
var
  LBoolean: Boolean;
  LDate: TDateTime;
  LNumber: Extended;
begin
  if TThemedGridValueConverter.IsNull(AValue) then
    Exit;
  case FKind of
    TThemedGridFilterEditorKind.Bool:
      if TThemedGridValueFormatter.TryGetBoolean(AValue, LBoolean) then
        FBoolValueBox.Checked := LBoolean;
    TThemedGridFilterEditorKind.Date:
      if TThemedGridValueConverter.TryGetDate(AValue, LDate) then
      begin
        if ASecondValue then
          FDateValue2Box.DateTime := LDate
        else
          FDateValueBox.DateTime := LDate;
      end;
    TThemedGridFilterEditorKind.Number:
      if TThemedGridValueConverter.TryToNumber(AValue, LNumber) then
      begin
        if ASecondValue then
          FNumberValue2Box.Text := FloatToStr(LNumber)
        else
          FNumberValueBox.Text := FloatToStr(LNumber);
      end;
  else
    if ASecondValue then
      FTextValue2Box.Text := TThemedGridValueConverter.ToText(AValue)
    else
      FTextValueBox.Text := TThemedGridValueConverter.ToText(AValue);
  end;
end;

function TThemedGridHeaderFilterPopup.TryGetEditorValue(const ASecondValue: Boolean; out AValue: TValue): Boolean;
var
  LNumber: Extended;
  LText: string;
  LConverted: TValue;
  LDate: TDateTime;
begin
  AValue := TValue.Empty;
  Result := True;
  case FKind of
    TThemedGridFilterEditorKind.Bool:
      AValue := TValue.From<Boolean>(FBoolValueBox.Checked);
    TThemedGridFilterEditorKind.Date:
      begin
        if ASecondValue then
          LDate := FDateValue2Box.DateTime
        else
          LDate := FDateValueBox.DateTime;
        AValue := TValue.From<TDateTime>(LDate);
      end;
    TThemedGridFilterEditorKind.Number:
      begin
        if ASecondValue then
          LText := Trim(FNumberValue2Box.Text)
        else
          LText := Trim(FNumberValueBox.Text);
        if LText = '' then
          LNumber := 0
        else if not TryStrToFloat(LText, LNumber) then
          Exit(False);
        if TThemedGridValueConverter.TryConvert(TValue.From<Extended>(LNumber), FValueType, LConverted) then
          AValue := LConverted
        else
          AValue := TValue.From<Extended>(LNumber);
      end;
  else
    if ASecondValue then
      LText := FTextValue2Box.Text
    else
      LText := FTextValueBox.Text;
    AValue := TValue.From<string>(LText);
    if (FValueType <> nil) and not (FValueType.Kind in [tkString, tkLString, tkWString, tkUString]) and
      TThemedGridValueConverter.TryConvert(AValue, FValueType, LConverted) then
      AValue := LConverted;
  end;
end;

class function TThemedGridHeaderFilterPopup.NeedsValue(const AOperator: TThemedGridFilterOperator): Boolean;
begin
  Result := not (AOperator in [TThemedGridFilterOperator.IsNull, TThemedGridFilterOperator.IsNotNull,
    TThemedGridFilterOperator.IsEmpty, TThemedGridFilterOperator.IsNotEmpty, TThemedGridFilterOperator.Today,
    TThemedGridFilterOperator.Yesterday, TThemedGridFilterOperator.ThisWeek, TThemedGridFilterOperator.ThisMonth,
    TThemedGridFilterOperator.ThisYear]);
end;

procedure TThemedGridHeaderFilterPopup.UpdateValueEditors;
var
  LOperator: TThemedGridFilterOperator;
  LDistinctMode, LNeedsValue, LNeedsSecond: Boolean;
begin
  LOperator := GetSelectedOperator;
  LDistinctMode := (LOperator = TThemedGridFilterOperator.&In) or (LOperator = TThemedGridFilterOperator.NotIn);
  LNeedsValue := NeedsValue(LOperator) and not LDistinctMode;
  LNeedsSecond := LOperator = TThemedGridFilterOperator.Between;

  FValueLabel.Visible := LNeedsValue;
  FValue2Label.Visible := LNeedsSecond;
  FTextValueBox.Visible := False;
  FTextValue2Box.Visible := False;
  FNumberValueBox.Visible := False;
  FNumberValue2Box.Visible := False;
  FDateValueBox.Visible := False;
  FDateValue2Box.Visible := False;
  FBoolValueBox.Visible := False;
  FDistinctSearchBox.Visible := LDistinctMode;
  FDistinctList.Visible := LDistinctMode;
  FSelectAllButton.Visible := LDistinctMode;
  FSelectNoneButton.Visible := LDistinctMode;
  FSelectionStateLabel.Visible := LDistinctMode;

  if LDistinctMode then
  begin
    ApplyDistinctLayout;
    EnsureDistinctValuesLoaded;
    UpdateSelectionState;
    Exit;
  end;

  ApplyNormalLayout(LNeedsSecond);
  if not LNeedsValue then
    Exit;

  case FKind of
    TThemedGridFilterEditorKind.Bool:
      FBoolValueBox.Visible := True;
    TThemedGridFilterEditorKind.Date:
      begin
        FDateValueBox.Visible := True;
        FDateValue2Box.Visible := LNeedsSecond;
      end;
    TThemedGridFilterEditorKind.Number:
      begin
        FNumberValueBox.Visible := True;
        FNumberValue2Box.Visible := LNeedsSecond;
      end;
  else
    FTextValueBox.Visible := True;
    FTextValue2Box.Visible := LNeedsSecond;
  end;
end;

procedure TThemedGridHeaderFilterPopup.ApplyNormalLayout(const ANeedsSecondValue: Boolean);
var
  LButtonTop: Integer;
begin
  if ANeedsSecondValue then
    LButtonTop := 174
  else
    LButtonTop := 144;
  ClientHeight := S(CTitleHeight + LButtonTop - 5 + 26 + 14);
  Place(FOkButton, 100, LButtonTop - 5, 72, 26);
  Place(FClearButton, 176, LButtonTop - 5, 72, 26);
  Place(FCancelButton, 252, LButtonTop - 5, 76, 26);
end;

procedure TThemedGridHeaderFilterPopup.ApplyDistinctLayout;
begin
  ClientHeight := S(CTitleHeight + 327 + 26 + 14);
  Place(FOkButton, 100, 327, 72, 26);
  Place(FClearButton, 176, 327, 72, 26);
  Place(FCancelButton, 252, 327, 76, 26);
end;

procedure TThemedGridHeaderFilterPopup.EnsureDistinctValuesLoaded;
var
  LValues: TObjectList<TThemedGridDistinctValue>;
begin
  if FDistinctLoaded then
    Exit;
  FDistinctLoaded := True;
  if Assigned(FLoader) then
  begin
    LValues := FLoader();
    try
      FDistinctList.SetValues(LValues);
    finally
      LValues.Free;
    end;
  end
  else
    FDistinctList.SetValues(nil);
  if (FCurrentFilter <> nil) and
    ((FCurrentFilter.Operator = TThemedGridFilterOperator.&In) or
     (FCurrentFilter.Operator = TThemedGridFilterOperator.NotIn)) and (FCurrentFilter.Values.Count > 0) then
    FDistinctList.SetCheckedValues(FCurrentFilter.Values);
  UpdateSelectionState;
end;

procedure TThemedGridHeaderFilterPopup.ShowSelectionMessage(const AText: string; const AColor: TColor);
begin
  FSelectionStateLabel.Caption := AText;
  FSelectionStateLabel.Font.Color := AColor;
end;

procedure TThemedGridHeaderFilterPopup.UpdateSelectionState;
var
  LChecked, LTotal: Integer;
  LColor: TColor;
begin
  LChecked := FDistinctList.CheckedCount;
  LTotal := FDistinctList.TotalCount;
  if LChecked = 0 then
    LColor := CWarningColor
  else if (LTotal > 0) and (LChecked = LTotal) then
    LColor := CSuccessColor
  else
    LColor := FAccentColor;
  ShowSelectionMessage(Format(TStr.SelectionStateFormat, [LChecked, LTotal]), LColor);
end;

procedure TThemedGridHeaderFilterPopup.CommitFilter;
var
  LFilter: TThemedGridFilterDescriptor;
  LOperator: TThemedGridFilterOperator;
  LChecked: TList<TValue>;
  LValue: TValue;
begin
  LOperator := GetSelectedOperator;
  LFilter := TThemedGridFilterDescriptor.Create;
  try
    LFilter.Column := FColumn;
    LFilter.ColumnName := FColumn.Name;
    LFilter.Operator := LOperator;
    if (LOperator = TThemedGridFilterOperator.&In) or (LOperator = TThemedGridFilterOperator.NotIn) then
    begin
      EnsureDistinctValuesLoaded;
      LChecked := FDistinctList.GetCheckedValues;
      try
        LFilter.Values.AddRange(LChecked);
      finally
        LChecked.Free;
      end;
      if LFilter.Values.Count = 0 then
      begin
        ShowSelectionMessage(TStr.SelectAtLeastOne, CErrorColor);
        Exit;
      end;
    end
    else
    begin
      if NeedsValue(LOperator) then
      begin
        if not TryGetEditorValue(False, LValue) then
        begin
          FNumberValueBox.SetFocus;
          Exit;
        end;
        LFilter.Value := LValue;
      end;
      if LOperator = TThemedGridFilterOperator.Between then
      begin
        if not TryGetEditorValue(True, LValue) then
        begin
          FNumberValue2Box.SetFocus;
          Exit;
        end;
        LFilter.Value2 := LValue;
      end;
    end;
    FFilter.Free;
    FFilter := LFilter;
    LFilter := nil;
    FClearRequested := False;
    ModalResult := mrOk;
  finally
    LFilter.Free;
  end;
end;

procedure TThemedGridHeaderFilterPopup.ApplyTheme(const APalette: TThemePalette);
var
  LControl: TControl;
  I: Integer;
begin
  if APalette = nil then
    Exit;
  FAccentColor := ThemeColorToColor(APalette.AccentColor);
  Color := ThemeColorToColor(APalette.ControlBorderColor);
  FContent.Color := ThemeColorToColor(APalette.ControlBackColor);
  FContent.Font.Color := ThemeColorToColor(APalette.ControlForeColor);
  FTitlePanel.Color := ThemeColorToColor(APalette.PanelBackColor);
  FTitleLabel.Font.Color := ThemeColorToColor(APalette.ControlForeColor);
  FCloseButton.Font.Color := ThemeColorToColor(APalette.ControlForeColor);
  for I := 0 to FContent.ControlCount - 1 do
  begin
    LControl := FContent.Controls[I];
    if (LControl is TEdit) or (LControl is TComboBox) or (LControl is TDateTimePicker) then
      TThemedGridEditorSupport.ApplyInputColors(LControl, APalette);
  end;
  FOperatorLabel.Font.Color := ThemeColorToColor(APalette.MutedForeColor);
  FValueLabel.Font.Color := ThemeColorToColor(APalette.MutedForeColor);
  FValue2Label.Font.Color := ThemeColorToColor(APalette.MutedForeColor);
  FBoolValueBox.Font.Color := ThemeColorToColor(APalette.ControlForeColor);
  FDistinctList.ApplyTheme(APalette);
  if FDistinctList.Visible then
    UpdateSelectionState;
end;

procedure TThemedGridHeaderFilterPopup.OperatorBoxChange(ASender: TObject);
begin
  if FUpdatingOperator then
    Exit;
  UpdateValueEditors;
end;

procedure TThemedGridHeaderFilterPopup.DistinctSearchChange(ASender: TObject);
begin
  FDistinctList.SetFilterText(FDistinctSearchBox.Text);
  UpdateSelectionState;
end;

procedure TThemedGridHeaderFilterPopup.SelectAllClick(ASender: TObject);
begin
  FDistinctList.SetAllVisibleChecked(True);
  UpdateSelectionState;
end;

procedure TThemedGridHeaderFilterPopup.SelectNoneClick(ASender: TObject);
begin
  FDistinctList.SetAllVisibleChecked(False);
  UpdateSelectionState;
end;

procedure TThemedGridHeaderFilterPopup.DistinctSelectionChanged(ASender: TObject);
begin
  UpdateSelectionState;
end;

procedure TThemedGridHeaderFilterPopup.OkClick(ASender: TObject);
begin
  CommitFilter;
end;

procedure TThemedGridHeaderFilterPopup.ClearClick(ASender: TObject);
begin
  FreeAndNil(FFilter);
  FClearRequested := True;
  ModalResult := mrOk;
end;

procedure TThemedGridHeaderFilterPopup.CancelClick(ASender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TThemedGridHeaderFilterPopup.FormDeactivate(ASender: TObject);
begin
  if Visible and (ModalResult = mrNone) then
    ModalResult := mrCancel;
end;

procedure TThemedGridHeaderFilterPopup.FormKeyDown(ASender: TObject; var AKey: Word; AShift: TShiftState);
begin
  if AKey = VK_ESCAPE then
  begin
    ModalResult := mrCancel;
    AKey := 0;
    Exit;
  end;
  if (AKey = VK_RETURN) and not (ActiveControl is TButton) then
  begin
    CommitFilter;
    AKey := 0;
  end;
end;

end.

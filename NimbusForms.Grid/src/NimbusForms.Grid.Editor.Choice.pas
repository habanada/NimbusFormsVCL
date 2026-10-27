unit NimbusForms.Grid.Editor.Choice;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  Winapi.CommCtrl,
  System.Classes,
  System.SysUtils,
  System.Rtti,
  System.TypInfo,
  System.Generics.Collections,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.Graphics,
  NimbusForms.Grid.EditorIntf,
  NimbusForms.Grid.EditorBase,
  NimbusForms.Grid.EditorControls,
  NimbusForms.Grid.Column;

type
  TThemedGridComboBoxEditor = class(TThemedGridEditorBase, IThemedGridEditorPopupState)
  private
    FCombo: TThemedGridEditorComboBox;
    FValues: TList<TValue>;
    FAppliedSource: TObject;
    FAppliedDisplayMember: string;
    FAppliedValueMember: string;
    FAppliedEnumType: PTypeInfo;
    FHasValueMember: Boolean;
    function GetIsPopupOpen: Boolean;
    procedure ClearItems;
    procedure ApplyItemSource(const AColumn: TThemedGridColumn);
    procedure LoadFromSource(const ASource: TObject; const ADisplayMember, AValueMember: string);
    procedure LoadFromEnum(const AEnumType: PTypeInfo);
    procedure LoadFromEnumerator(const AContext: TRttiContext; const ASource: TObject;
      const ADisplayMember, AValueMember: string);
    procedure AddItem(const AText: string; const AValue: TValue);
    function FindItemIndex(const AValue: TValue): Integer;
    function ConvertSelection(const ASelection: TValue): TValue;
    function IsDropDownList: Boolean;
  protected
    procedure DoBeginEdit(const AContext: TThemedGridCellEditContext); override;
    function GetValue: TValue; override;
    procedure SetValue(const AValue: TValue); override;
    function CommitEdit: Boolean; override;
    procedure CancelEdit; override;
    procedure AttachHooks(const AKeyDown: TKeyEvent; const AExit: TNotifyEvent); override;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TThemedGridDateTimeEditor = class(TThemedGridEditorBase, IThemedGridEditorPopupState)
  private
    FPicker: TThemedGridEditorDatePicker;
    FIncludeTime: Boolean;
    FShowTime: Boolean;
    FMinDate: TDateTime;
    FMaxDate: TDateTime;
    FOpenDropDownOnBeginEdit: Boolean;
    FHostKeyDown: TKeyEvent;
    function GetIsPopupOpen: Boolean;
    procedure PickerKeyDown(ASender: TObject; var AKey: Word; AShift: TShiftState);
    procedure ApplyOptions(const AColumn: TThemedGridColumn);
    procedure ApplyFormat(const AColumn: TThemedGridColumn);
    function ClampDate(const AValue: TDateTime): TDateTime;
    function TryGetDateTime(const AValue: TValue; out AResult: TDateTime): Boolean;
    function IsTimeOnlyType: Boolean;
  protected
    procedure DoBeginEdit(const AContext: TThemedGridCellEditContext); override;
    function GetValue: TValue; override;
    procedure SetValue(const AValue: TValue); override;
    function CommitEdit: Boolean; override;
    procedure CancelEdit; override;
    procedure AttachHooks(const AKeyDown: TKeyEvent; const AExit: TNotifyEvent); override;
  public
    constructor Create(const AIncludeTime: Boolean);
    property OpenDropDownOnBeginEdit: Boolean read FOpenDropDownOnBeginEdit write FOpenDropDownOnBeginEdit;
  end;

  TThemedGridColorEditor = class(TThemedGridEditorBase, IThemedGridEditorPopupState)
  private
    FButton: TThemedGridColorButton;
    FOpenDialogOnBeginEdit: Boolean;
    function GetIsPopupOpen: Boolean;
  protected
    procedure DoBeginEdit(const AContext: TThemedGridCellEditContext); override;
    function GetValue: TValue; override;
    procedure SetValue(const AValue: TValue); override;
    function CommitEdit: Boolean; override;
    procedure AttachHooks(const AKeyDown: TKeyEvent; const AExit: TNotifyEvent); override;
  public
    constructor Create;
    property OpenDialogOnBeginEdit: Boolean read FOpenDialogOnBeginEdit write FOpenDialogOnBeginEdit;
  end;

implementation

uses
  System.Character,
  System.UITypes,
  System.StrUtils,
  System.DateUtils,
  System.Math,
  NimbusForms.Theming.Types,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.EditorOptions,
  NimbusForms.Grid.ValueAccessor,
  NimbusForms.Grid.ValueConverter,
  NimbusForms.Grid.ColorValue,
  NimbusForms.Grid.EditStrings,
  NimbusForms.Grid.EditorSupport;

const
  CDtmCloseMonthCal = DTM_FIRST + 13;

function ReadMember(const AInstance: TValue; const AMember: string): TValue;
begin
  if (AMember = '') or (AInstance.TypeInfo = nil) then
    Exit(AInstance);
  Result := TThemedGridValueAccessorCache.GetAccessor(AInstance, AMember).GetValue(AInstance);
end;

constructor TThemedGridComboBoxEditor.Create;
begin
  inherited Create;
  FValues := TList<TValue>.Create;
  FCombo := TThemedGridEditorComboBox.Create(nil);
  FCombo.Style := csDropDown;
  FCombo.DropDownCount := 12;
  FCombo.AutoComplete := True;
  InitControl(FCombo);
end;

destructor TThemedGridComboBoxEditor.Destroy;
begin
  inherited Destroy;
  FValues.Free;
end;

function TThemedGridComboBoxEditor.GetIsPopupOpen: Boolean;
begin
  Result := FCombo.IsDroppedDown;
end;

function TThemedGridComboBoxEditor.IsDropDownList: Boolean;
begin
  Result := FCombo.Style = csDropDownList;
end;

procedure TThemedGridComboBoxEditor.ClearItems;
begin
  FCombo.Items.Clear;
  FValues.Clear;
end;

procedure TThemedGridComboBoxEditor.AddItem(const AText: string; const AValue: TValue);
begin
  FCombo.Items.Add(AText);
  FValues.Add(AValue);
end;

procedure TThemedGridComboBoxEditor.LoadFromEnum(const AEnumType: PTypeInfo);
var
  LData: PTypeData;
  I: Integer;
begin
  LData := GetTypeData(AEnumType);
  FCombo.Items.BeginUpdate;
  try
    ClearItems;
    for I := LData.MinValue to LData.MaxValue do
      AddItem(GetEnumName(AEnumType, I), TValue.FromOrdinal(AEnumType, I));
  finally
    FCombo.Items.EndUpdate;
  end;
end;

procedure TThemedGridComboBoxEditor.LoadFromSource(const ASource: TObject; const ADisplayMember,
  AValueMember: string);
var
  LStrings: TStrings;
  LContext: TRttiContext;
  I: Integer;
begin
  FCombo.Items.BeginUpdate;
  try
    ClearItems;
    if ASource is TStrings then
    begin
      LStrings := TStrings(ASource);
      for I := 0 to LStrings.Count - 1 do
        AddItem(LStrings[I], TValue.From<string>(LStrings[I]));
      Exit;
    end;
    LContext := TRttiContext.Create;
    try
      LoadFromEnumerator(LContext, ASource, ADisplayMember, AValueMember);
    finally
      LContext.Free;
    end;
  finally
    FCombo.Items.EndUpdate;
  end;
end;

procedure TThemedGridComboBoxEditor.LoadFromEnumerator(const AContext: TRttiContext; const ASource: TObject;
  const ADisplayMember, AValueMember: string);
var
  LType, LEnumType: TRttiType;
  LGetEnumerator, LMoveNext: TRttiMethod;
  LCurrent: TRttiProperty;
  LEnumerator, LItem, LDisplay, LValue: TValue;
  LEnumObject: TObject;
begin
  LType := AContext.GetType(ASource.ClassType);
  if LType = nil then
    Exit;
  LGetEnumerator := LType.GetMethod('GetEnumerator');
  if LGetEnumerator = nil then
    Exit;
  LEnumerator := LGetEnumerator.Invoke(ASource, []);
  if LEnumerator.Kind <> tkClass then
    Exit;
  LEnumObject := LEnumerator.AsObject;
  if LEnumObject = nil then
    Exit;
  try
    LEnumType := AContext.GetType(LEnumObject.ClassType);
    if LEnumType = nil then
      Exit;
    LMoveNext := LEnumType.GetMethod('MoveNext');
    LCurrent := LEnumType.GetProperty('Current');
    if (LMoveNext = nil) or (LCurrent = nil) then
      Exit;
    while LMoveNext.Invoke(LEnumObject, []).AsBoolean do
    begin
      LItem := LCurrent.GetValue(LEnumObject);
      if ADisplayMember <> '' then
        LDisplay := ReadMember(LItem, ADisplayMember)
      else
        LDisplay := LItem;
      if AValueMember <> '' then
        LValue := ReadMember(LItem, AValueMember)
      else
        LValue := LItem;
      AddItem(TThemedGridValueConverter.ToText(LDisplay), LValue);
    end;
  finally
    LEnumObject.Free;
  end;
end;

procedure TThemedGridComboBoxEditor.ApplyItemSource(const AColumn: TThemedGridColumn);
var
  LOptions: TThemedGridEditorOptions;
  LSource: TObject;
  LDisplayMember, LValueMember: string;
  LEnumType: PTypeInfo;
begin
  LOptions := nil;
  LSource := nil;
  LDisplayMember := '';
  LValueMember := '';
  if AColumn <> nil then
    LOptions := AColumn.EditorOptions;
  if LOptions <> nil then
  begin
    LSource := LOptions.DataSource;
    LDisplayMember := LOptions.DisplayMember;
    LValueMember := LOptions.ValueMember;
  end;

  if LSource <> nil then
  begin
    FHasValueMember := LValueMember <> '';
    if (FAppliedSource <> LSource) or (FAppliedDisplayMember <> LDisplayMember) or
      (FAppliedValueMember <> LValueMember) then
    begin
      LoadFromSource(LSource, LDisplayMember, LValueMember);
      FAppliedSource := LSource;
      FAppliedDisplayMember := LDisplayMember;
      FAppliedValueMember := LValueMember;
      FAppliedEnumType := nil;
    end;
    FCombo.Style := csDropDownList;
    FCombo.AutoComplete := False;
    Exit;
  end;

  FHasValueMember := False;
  LEnumType := ValueType;
  if (LEnumType <> nil) and (LEnumType.Kind = tkEnumeration) then
  begin
    if FAppliedEnumType <> LEnumType then
    begin
      LoadFromEnum(LEnumType);
      FAppliedEnumType := LEnumType;
      FAppliedSource := nil;
      FAppliedDisplayMember := '';
      FAppliedValueMember := '';
    end;
    FCombo.Style := csDropDownList;
    FCombo.AutoComplete := False;
    Exit;
  end;

  if (FAppliedSource <> nil) or (FAppliedEnumType <> nil) or (FCombo.Items.Count > 0) then
  begin
    ClearItems;
    FAppliedSource := nil;
    FAppliedDisplayMember := '';
    FAppliedValueMember := '';
    FAppliedEnumType := nil;
  end;
  FCombo.Style := csDropDown;
  FCombo.AutoComplete := True;
end;

function TThemedGridComboBoxEditor.FindItemIndex(const AValue: TValue): Integer;
var
  I: Integer;
  LText: string;
begin
  for I := 0 to FValues.Count - 1 do
    if TThemedGridEditorSupport.ValuesEqual(FValues[I], AValue) then
      Exit(I);
  LText := TThemedGridValueConverter.ToText(AValue);
  if LText = '' then
    Exit(-1);
  for I := 0 to FCombo.Items.Count - 1 do
    if SameText(FCombo.Items[I], LText) then
      Exit(I);
  Result := -1;
end;

function TThemedGridComboBoxEditor.ConvertSelection(const ASelection: TValue): TValue;
var
  LConverted: TValue;
begin
  if ValueType = nil then
    Exit(ASelection);
  if ASelection.TypeInfo = ValueType then
    Exit(ASelection);
  if TThemedGridValueConverter.TryConvert(ASelection, ValueType, LConverted) and (LConverted.TypeInfo <> nil) then
    Exit(LConverted);
  Result := ASelection;
end;

procedure TThemedGridComboBoxEditor.DoBeginEdit(const AContext: TThemedGridCellEditContext);
var
  LColumn: TThemedGridColumn;
begin
  LColumn := nil;
  if AContext <> nil then
    LColumn := AContext.Column;
  ApplyItemSource(LColumn);
  SetValue(OriginalValue);
  FocusEditor;
  if not IsDropDownList then
    FCombo.SelectAll;
end;

function TThemedGridComboBoxEditor.GetValue: TValue;
var
  LText: string;
begin
  if FCombo.ItemIndex >= 0 then
  begin
    if FHasValueMember then
      Exit(FValues[FCombo.ItemIndex]);
    Exit(ConvertSelection(FValues[FCombo.ItemIndex]));
  end;
  if IsDropDownList then
  begin
    if AllowNull then
      Exit(TValue.Empty);
    Exit(OriginalValue);
  end;
  LText := Trim(FCombo.Text);
  if LText = '' then
  begin
    if AllowNull then
      Exit(TValue.Empty);
    Exit(OriginalValue);
  end;
  Result := ConvertSelection(TValue.From<string>(LText));
end;

procedure TThemedGridComboBoxEditor.SetValue(const AValue: TValue);
var
  LIndex: Integer;
begin
  if TThemedGridValueConverter.IsNull(AValue) then
  begin
    FCombo.ItemIndex := -1;
    if not IsDropDownList then
      FCombo.Text := '';
    Exit;
  end;
  LIndex := FindItemIndex(AValue);
  if LIndex >= 0 then
  begin
    FCombo.ItemIndex := LIndex;
    Exit;
  end;
  FCombo.ItemIndex := -1;
  if IsDropDownList then
    Exit;
  FCombo.Text := TThemedGridValueConverter.ToText(AValue);
end;

function TThemedGridComboBoxEditor.CommitEdit: Boolean;
begin
  FCombo.CloseDropDown;
  Result := True;
end;

procedure TThemedGridComboBoxEditor.CancelEdit;
begin
  FCombo.CloseDropDown;
  SetValue(OriginalValue);
end;

procedure TThemedGridComboBoxEditor.AttachHooks(const AKeyDown: TKeyEvent; const AExit: TNotifyEvent);
begin
  FCombo.OnKeyDown := AKeyDown;
  FCombo.OnExit := AExit;
end;

function ConvertDelphiDatePattern(const APattern: string): string;
var
  I: Integer;
  LInQuote: Boolean;
  LChar: Char;
begin
  Result := '';
  LInQuote := False;
  for I := 1 to Length(APattern) do
  begin
    LChar := APattern[I];
    if LChar = '''' then
    begin
      LInQuote := not LInQuote;
      Result := Result + LChar;
    end
    else if LInQuote then
      Result := Result + LChar
    else if (LChar = 'm') or (LChar = 'M') then
      Result := Result + 'M'
    else if LChar = '/' then
      Result := Result + FormatSettings.DateSeparator
    else
      Result := Result + LChar;
  end;
end;

function ConvertDelphiTimePattern(const APattern: string): string;
var
  LPattern: string;
  LTwelveHour: Boolean;
  I: Integer;
  LInQuote: Boolean;
  LChar: Char;
begin
  LPattern := APattern;
  LTwelveHour := ContainsText(LPattern, 'am/pm') or ContainsText(LPattern, 'ampm') or ContainsText(LPattern, 'a/p');
  LPattern := StringReplace(LPattern, 'AMPM', 'tt', [rfReplaceAll, rfIgnoreCase]);
  LPattern := StringReplace(LPattern, 'AM/PM', 'tt', [rfReplaceAll, rfIgnoreCase]);
  LPattern := StringReplace(LPattern, 'A/P', 't', [rfReplaceAll, rfIgnoreCase]);
  Result := '';
  LInQuote := False;
  for I := 1 to Length(LPattern) do
  begin
    LChar := LPattern[I];
    if LChar = '''' then
    begin
      LInQuote := not LInQuote;
      Result := Result + LChar;
    end
    else if LInQuote then
      Result := Result + LChar
    else if LChar = 'n' then
      Result := Result + 'm'
    else if (LChar = 'h') or (LChar = 'H') then
    begin
      if LTwelveHour then
        Result := Result + 'h'
      else
        Result := Result + 'H';
    end
    else if LChar = ':' then
      Result := Result + FormatSettings.TimeSeparator
    else if (LChar = 'z') or (LChar = 'Z') then
      Result := Result
    else
      Result := Result + LChar;
  end;
end;

function BuildDefaultDateFormat: string;
begin
  Result := ConvertDelphiDatePattern(FormatSettings.ShortDateFormat);
end;

function BuildDefaultFormat(const AIncludeTime: Boolean): string;
begin
  Result := BuildDefaultDateFormat;
  if AIncludeTime then
    Result := Result + ' ' + ConvertDelphiTimePattern(FormatSettings.ShortTimeFormat);
end;

function BuildStandardFormat(const ASpecifier: Char; const AIncludeTime: Boolean): string;
var
  LShortDate, LShortTime, LLongTime, LLongDate: string;
begin
  LShortDate := ConvertDelphiDatePattern(FormatSettings.ShortDateFormat);
  LLongDate := ConvertDelphiDatePattern(FormatSettings.LongDateFormat);
  LShortTime := ConvertDelphiTimePattern(FormatSettings.ShortTimeFormat);
  LLongTime := ConvertDelphiTimePattern(FormatSettings.LongTimeFormat);
  case ASpecifier of
    'd': Result := LShortDate;
    'D': Result := LLongDate;
    't': Result := LShortTime;
    'T': Result := LLongTime;
    'g': Result := LShortDate + ' ' + LShortTime;
    'G', 'F', 'U', 's', 'u': Result := LShortDate + ' ' + LLongTime;
    'f': Result := LLongDate + ' ' + LShortTime;
  else
    Result := BuildDefaultFormat(AIncludeTime);
  end;
end;

function IsValidPickerFormat(const AFormat: string): Boolean;
var
  I: Integer;
  LInQuote: Boolean;
  LChar: Char;
begin
  if AFormat = '' then
    Exit(False);
  LInQuote := False;
  for I := 1 to Length(AFormat) do
  begin
    LChar := AFormat[I];
    if LChar = '''' then
      LInQuote := not LInQuote
    else if (not LInQuote) and LChar.IsLetter and
      (Pos(LChar, TThemedGridEditStrings.DateFormatLetters) = 0) then
      Exit(False);
  end;
  Result := not LInQuote;
end;

constructor TThemedGridDateTimeEditor.Create(const AIncludeTime: Boolean);
begin
  inherited Create;
  FIncludeTime := AIncludeTime;
  FShowTime := AIncludeTime;
  FOpenDropDownOnBeginEdit := True;
  FPicker := TThemedGridEditorDatePicker.Create(nil);
  FPicker.Kind := dtkDate;
  FPicker.DateMode := dmComboBox;
  FPicker.ParseInput := False;
  FPicker.OnKeyDown := PickerKeyDown;
  InitControl(FPicker);
end;

function TThemedGridDateTimeEditor.GetIsPopupOpen: Boolean;
begin
  Result := FPicker.IsDroppedDown;
end;

function TThemedGridDateTimeEditor.IsTimeOnlyType: Boolean;
begin
  Result := ValueType = System.TypeInfo(TTime);
end;

procedure TThemedGridDateTimeEditor.PickerKeyDown(ASender: TObject; var AKey: Word; AShift: TShiftState);
begin
  if ((AKey = VK_DELETE) or (AKey = VK_BACK)) and AllowNull and not FPicker.IsDroppedDown then
  begin
    FPicker.Checked := False;
    AKey := 0;
  end;
  if Assigned(FHostKeyDown) then
    FHostKeyDown(ASender, AKey, AShift);
end;

procedure TThemedGridDateTimeEditor.ApplyOptions(const AColumn: TThemedGridColumn);
var
  LOptions: TThemedGridEditorOptions;
begin
  LOptions := nil;
  if AColumn <> nil then
    LOptions := AColumn.EditorOptions;
  FMinDate := EncodeDate(1753, 1, 1);
  FMaxDate := EncodeDate(9998, 12, 31);
  if (LOptions <> nil) and LOptions.HasMinDate then
    FMinDate := Max(FMinDate, LOptions.MinDate);
  if (LOptions <> nil) and LOptions.HasMaxDate then
    FMaxDate := Min(FMaxDate, LOptions.MaxDate);
  if FMaxDate < FMinDate then
    FMaxDate := FMinDate;
  FShowTime := FIncludeTime;
  if (LOptions <> nil) and LOptions.HasShowTime then
    FShowTime := LOptions.ShowTime;
  try
    FPicker.MaxDate := 0;
    FPicker.MinDate := 0;
    if (LOptions <> nil) and LOptions.HasMaxDate then
      FPicker.MaxDate := FMaxDate;
    if (LOptions <> nil) and LOptions.HasMinDate then
      FPicker.MinDate := FMinDate;
  except
    on EDateTimeError do
    begin
      FPicker.MaxDate := 0;
      FPicker.MinDate := 0;
    end;
  end;
end;

procedure TThemedGridDateTimeEditor.ApplyFormat(const AColumn: TThemedGridColumn);
var
  LFormatString, LFormat: string;
begin
  LFormatString := '';
  if AColumn <> nil then
    LFormatString := AColumn.FormatString;
  if LFormatString = '' then
    LFormat := BuildDefaultFormat(FShowTime)
  else if (Length(LFormatString) = 1) and LFormatString[1].IsLetter then
    LFormat := BuildStandardFormat(LFormatString[1], FShowTime)
  else
    LFormat := LFormatString;
  if not IsValidPickerFormat(LFormat) then
    LFormat := BuildDefaultFormat(FShowTime);
  FPicker.Format := LFormat;
end;

function TThemedGridDateTimeEditor.ClampDate(const AValue: TDateTime): TDateTime;
begin
  Result := AValue;
  if Result < FMinDate then
    Result := FMinDate;
  if Result > FMaxDate then
    Result := FMaxDate;
end;

function TThemedGridDateTimeEditor.TryGetDateTime(const AValue: TValue; out AResult: TDateTime): Boolean;
begin
  AResult := Date;
  if TThemedGridValueConverter.IsNull(AValue) then
    Exit(False);
  if not TThemedGridValueConverter.TryGetDate(AValue, AResult) then
    Exit(False);
  if IsTimeOnlyType then
    AResult := Date + Frac(AResult);
  Result := True;
end;

procedure TThemedGridDateTimeEditor.DoBeginEdit(const AContext: TThemedGridCellEditContext);
var
  LColumn: TThemedGridColumn;
begin
  LColumn := nil;
  if AContext <> nil then
    LColumn := AContext.Column;
  ApplyOptions(LColumn);
  ApplyFormat(LColumn);
  FPicker.ShowCheckbox := AllowNull;
  SetValue(OriginalValue);
  FocusEditor;
  if FOpenDropDownOnBeginEdit then
    FPicker.OpenDropDown;
end;

function TThemedGridDateTimeEditor.GetValue: TValue;
var
  LDate: TDateTime;
begin
  if FPicker.ShowCheckbox and not FPicker.Checked then
    Exit(TValue.Empty);
  LDate := FPicker.DateTime;
  if IsTimeOnlyType then
    LDate := Frac(LDate);
  Result := TValue.From<TDateTime>(LDate);
end;

procedure TThemedGridDateTimeEditor.SetValue(const AValue: TValue);
var
  LDate: TDateTime;
begin
  if TryGetDateTime(AValue, LDate) then
  begin
    FPicker.DateTime := ClampDate(LDate);
    if FPicker.ShowCheckbox then
      FPicker.Checked := True;
    Exit;
  end;
  FPicker.DateTime := ClampDate(Date);
  if FPicker.ShowCheckbox then
    FPicker.Checked := False;
end;

function TThemedGridDateTimeEditor.CommitEdit: Boolean;
begin
  if FPicker.IsDroppedDown then
    SendMessage(FPicker.Handle, CDtmCloseMonthCal, 0, 0);
  Result := True;
end;

procedure TThemedGridDateTimeEditor.CancelEdit;
begin
  if FPicker.IsDroppedDown then
    SendMessage(FPicker.Handle, CDtmCloseMonthCal, 0, 0);
  SetValue(OriginalValue);
end;

procedure TThemedGridDateTimeEditor.AttachHooks(const AKeyDown: TKeyEvent; const AExit: TNotifyEvent);
begin
  FHostKeyDown := AKeyDown;
  FPicker.OnExit := AExit;
end;

constructor TThemedGridColorEditor.Create;
begin
  inherited Create;
  FOpenDialogOnBeginEdit := True;
  FButton := TThemedGridColorButton.Create(nil);
  InitControl(FButton);
end;

function TThemedGridColorEditor.GetIsPopupOpen: Boolean;
begin
  Result := FButton.IsDialogActive;
end;

procedure TThemedGridColorEditor.DoBeginEdit(const AContext: TThemedGridCellEditContext);
begin
  FButton.AllowClear := AllowNull;
  SetValue(OriginalValue);
  FocusEditor;
  if FOpenDialogOnBeginEdit then
    FButton.OpenDialogDeferred;
end;

function TThemedGridColorEditor.GetValue: TValue;
var
  LColor: TThemeColor;
begin
  if (not FButton.HasValue) and AllowNull then
    Exit(TValue.Empty);
  LColor := ColorToThemeColor(FButton.Color);
  if (ValueType = nil) or (ValueType = System.TypeInfo(TThemeColor)) then
    Exit(TValue.From<TThemeColor>(LColor));
  case ValueType.Kind of
    tkInteger: Exit(TValue.FromOrdinal(ValueType, Int64(Cardinal(LColor))));
    tkInt64: Exit(TValue.From<Int64>(Int64(Cardinal(LColor))));
    tkUString, tkLString, tkWString, tkString:
      Exit(TValue.From<string>(TThemedGridColorValue.Format(LColor)));
  end;
  Result := TValue.From<TThemeColor>(LColor);
end;

procedure TThemedGridColorEditor.SetValue(const AValue: TValue);
var
  LColor: TThemeColor;
begin
  if TThemedGridColorValue.TryGetColor(AValue, LColor) then
  begin
    FButton.Color := ThemeColorToColor(LColor);
    FButton.HasValue := True;
    Exit;
  end;
  FButton.Color := clWhite;
  FButton.HasValue := not AllowNull;
end;

function TThemedGridColorEditor.CommitEdit: Boolean;
begin
  Result := True;
end;

procedure TThemedGridColorEditor.AttachHooks(const AKeyDown: TKeyEvent; const AExit: TNotifyEvent);
begin
  FButton.OnEditorKeyDown := AKeyDown;
  FButton.OnEditorExit := AExit;
end;

end.

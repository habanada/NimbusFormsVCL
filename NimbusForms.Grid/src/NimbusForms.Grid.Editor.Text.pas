unit NimbusForms.Grid.Editor.Text;

{$SCOPEDENUMS ON}

interface

uses
  System.Classes,
  System.SysUtils,
  System.Rtti,
  Vcl.Controls,
  Vcl.StdCtrls,
  NimbusForms.Grid.EditorIntf,
  NimbusForms.Grid.EditorBase,
  NimbusForms.Grid.EditorControls,
  NimbusForms.Grid.NumericRange;

type
  TThemedGridTextEditor = class(TThemedGridEditorBase)
  private
    FEdit: TThemedGridEditorEdit;
    FMemo: TThemedGridEditorMemo;
    FMultiline: Boolean;
  protected
    procedure DoBeginEdit(const AContext: TThemedGridCellEditContext); override;
    function GetValue: TValue; override;
    procedure SetValue(const AValue: TValue); override;
    procedure AttachHooks(const AKeyDown: TKeyEvent; const AExit: TNotifyEvent); override;
  public
    constructor Create(const AMultiline: Boolean);
  end;

  TThemedGridNumericEditor = class(TThemedGridEditorBase)
  private
    FEdit: TThemedGridEditorEdit;
    FRange: TThemedGridNumericRange;
    procedure EditArrow(ASender: TObject; const ADirection: Integer);
    procedure EditFilterChar(ASender: TObject; var AKey: Char);
  protected
    procedure DoBeginEdit(const AContext: TThemedGridCellEditContext); override;
    function GetValue: TValue; override;
    procedure SetValue(const AValue: TValue); override;
    procedure AttachHooks(const AKeyDown: TKeyEvent; const AExit: TNotifyEvent); override;
  public
    constructor Create;
  end;

implementation

uses
  System.TypInfo,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.ValueConverter,
  NimbusForms.Grid.EditorSupport;

constructor TThemedGridTextEditor.Create(const AMultiline: Boolean);
begin
  inherited Create;
  FMultiline := AMultiline;
  if AMultiline then
  begin
    FMemo := TThemedGridEditorMemo.Create(nil);
    FMemo.ScrollBars := ssVertical;
    FMemo.WantReturns := False;
    FMemo.WantTabs := False;
    FMemo.WordWrap := True;
    InitControl(FMemo);
  end
  else
  begin
    FEdit := TThemedGridEditorEdit.Create(nil);
    FEdit.AutoSize := False;
    InitControl(FEdit);
  end;
end;

procedure TThemedGridTextEditor.DoBeginEdit(const AContext: TThemedGridCellEditContext);
var
  LAlignment: TAlignment;
begin
  LAlignment := taLeftJustify;
  if (AContext <> nil) and (AContext.Column <> nil) then
    LAlignment := TThemedGridEditorSupport.ToAlignment(AContext.Column.TextAlignment);
  if FMultiline then
    FMemo.Alignment := LAlignment
  else
    FEdit.Alignment := LAlignment;
  SetValue(OriginalValue);
  FocusEditor;
  if FMultiline then
    FMemo.SelectAll
  else
    FEdit.SelectAll;
end;

function TThemedGridTextEditor.GetValue: TValue;
begin
  if FMultiline then
    Result := TValue.From<string>(FMemo.Text)
  else
    Result := TValue.From<string>(FEdit.Text);
end;

procedure TThemedGridTextEditor.SetValue(const AValue: TValue);
var
  LText: string;
begin
  if TThemedGridValueConverter.IsNull(AValue) then
    LText := ''
  else
    LText := TThemedGridValueConverter.ToText(AValue);
  if FMultiline then
    FMemo.Text := LText
  else
    FEdit.Text := LText;
end;

procedure TThemedGridTextEditor.AttachHooks(const AKeyDown: TKeyEvent; const AExit: TNotifyEvent);
begin
  if FMultiline then
  begin
    FMemo.OnKeyDown := AKeyDown;
    FMemo.OnExit := AExit;
  end
  else
  begin
    FEdit.OnKeyDown := AKeyDown;
    FEdit.OnExit := AExit;
  end;
end;

constructor TThemedGridNumericEditor.Create;
begin
  inherited Create;
  FRange := TThemedGridNumericRange.Resolve(nil, System.TypeInfo(Extended));
  FEdit := TThemedGridEditorEdit.Create(nil);
  FEdit.AutoSize := False;
  FEdit.Alignment := taRightJustify;
  FEdit.OnArrow := EditArrow;
  FEdit.OnFilterChar := EditFilterChar;
  InitControl(FEdit);
end;

procedure TThemedGridNumericEditor.DoBeginEdit(const AContext: TThemedGridCellEditContext);
var
  LColumn: TThemedGridColumn;
  LValueType: PTypeInfo;
begin
  LColumn := nil;
  LValueType := ValueType;
  if AContext <> nil then
    LColumn := AContext.Column;
  if LValueType = nil then
    LValueType := System.TypeInfo(Extended);
  FRange := TThemedGridNumericRange.Resolve(LColumn, LValueType);
  if LColumn <> nil then
    FEdit.Alignment := TThemedGridEditorSupport.ToAlignment(LColumn.TextAlignment)
  else
    FEdit.Alignment := taRightJustify;
  SetValue(OriginalValue);
  FocusEditor;
  FEdit.SelectAll;
end;

function TThemedGridNumericEditor.GetValue: TValue;
var
  LText: string;
  LDisplay: Extended;
begin
  LText := Trim(FEdit.Text);
  if LText = '' then
  begin
    if AllowNull then
      Exit(TValue.Empty);
    Exit(OriginalValue);
  end;
  if not FRange.TryParseDisplayValue(LText, LDisplay) then
    Exit(OriginalValue);
  LDisplay := FRange.ClampDisplayValue(FRange.RoundDisplayValue(LDisplay));
  Result := FRange.ConvertToValueType(FRange.ToStoredValue(LDisplay));
end;

procedure TThemedGridNumericEditor.SetValue(const AValue: TValue);
var
  LDisplay: Extended;
begin
  if TThemedGridValueConverter.IsNull(AValue) then
  begin
    FEdit.Text := '';
    Exit;
  end;
  LDisplay := FRange.ClampDisplayValue(FRange.ToDisplayValue(AValue));
  FEdit.Text := FRange.FormatDisplayValue(LDisplay);
end;

procedure TThemedGridNumericEditor.AttachHooks(const AKeyDown: TKeyEvent; const AExit: TNotifyEvent);
begin
  FEdit.OnKeyDown := AKeyDown;
  FEdit.OnExit := AExit;
end;

procedure TThemedGridNumericEditor.EditArrow(ASender: TObject; const ADirection: Integer);
var
  LDisplay: Extended;
begin
  if not FRange.TryParseDisplayValue(FEdit.Text, LDisplay) then
    LDisplay := FRange.ClampDisplayValue(0);
  LDisplay := LDisplay + FRange.Increment * ADirection;
  LDisplay := FRange.ClampDisplayValue(FRange.RoundDisplayValue(LDisplay));
  FEdit.Text := FRange.FormatDisplayValue(LDisplay);
  FEdit.SelStart := Length(FEdit.Text);
  FEdit.SelLength := 0;
end;

procedure TThemedGridNumericEditor.EditFilterChar(ASender: TObject; var AKey: Char);
begin
  if CharInSet(AKey, ['0'..'9']) then
    Exit;
  if (AKey = '.') or (AKey = ',') then
  begin
    if FRange.DecimalPlaces <= 0 then
      AKey := #0;
    Exit;
  end;
  if (AKey = '-') or (AKey = '+') then
  begin
    if FRange.HasRange and (FRange.Minimum >= 0) then
      AKey := #0;
    Exit;
  end;
  if AKey = '%' then
    Exit;
  AKey := #0;
end;

end.

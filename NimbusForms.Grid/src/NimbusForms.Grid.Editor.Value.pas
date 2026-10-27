unit NimbusForms.Grid.Editor.Value;

{$SCOPEDENUMS ON}

interface

uses
  System.Classes,
  System.SysUtils,
  System.Math,
  System.Rtti,
  Vcl.Controls,
  NimbusForms.Grid.EditorIntf,
  NimbusForms.Grid.EditorBase,
  NimbusForms.Grid.EditorControls,
  NimbusForms.Grid.EditorOptions;

type
  TThemedGridBooleanEditor = class(TThemedGridEditorBase)
  private
    FToggle: TThemedGridToggleControl;
  protected
    procedure DoBeginEdit(const AContext: TThemedGridCellEditContext); override;
    function GetValue: TValue; override;
    procedure SetValue(const AValue: TValue); override;
    procedure AttachHooks(const AKeyDown: TKeyEvent; const AExit: TNotifyEvent); override;
  public
    constructor Create(const AStyle: TThemedGridToggleStyle);
  end;

  TThemedGridSliderEditor = class(TThemedGridEditorBase)
  private
    FSlider: TThemedGridSliderControl;
    FScale: Extended;
    function SafeInt(const AValue: Extended): Integer;
  protected
    procedure DoBeginEdit(const AContext: TThemedGridCellEditContext); override;
    function GetValue: TValue; override;
    procedure SetValue(const AValue: TValue); override;
    procedure AttachHooks(const AKeyDown: TKeyEvent; const AExit: TNotifyEvent); override;
  public
    constructor Create;
  end;

  TThemedGridRatingEditor = class(TThemedGridEditorBase)
  private
    FRating: TThemedGridRatingControl;
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
  NimbusForms.Grid.ValueFormatter,
  NimbusForms.Grid.EditorSupport;

constructor TThemedGridBooleanEditor.Create(const AStyle: TThemedGridToggleStyle);
begin
  inherited Create;
  FToggle := TThemedGridToggleControl.Create(nil);
  FToggle.Style := AStyle;
  InitControl(FToggle);
end;

procedure TThemedGridBooleanEditor.DoBeginEdit(const AContext: TThemedGridCellEditContext);
begin
  SetValue(OriginalValue);
  FocusEditor;
end;

function TThemedGridBooleanEditor.GetValue: TValue;
begin
  Result := TValue.From<Boolean>(FToggle.Checked);
end;

procedure TThemedGridBooleanEditor.SetValue(const AValue: TValue);
var
  LBoolean: Boolean;
begin
  if not TThemedGridValueFormatter.TryGetBoolean(AValue, LBoolean) then
    LBoolean := False;
  FToggle.Checked := LBoolean;
end;

procedure TThemedGridBooleanEditor.AttachHooks(const AKeyDown: TKeyEvent; const AExit: TNotifyEvent);
begin
  FToggle.OnEditorKeyDown := AKeyDown;
  FToggle.OnEditorExit := AExit;
end;

constructor TThemedGridSliderEditor.Create;
begin
  inherited Create;
  FScale := 1;
  FSlider := TThemedGridSliderControl.Create(nil);
  InitControl(FSlider);
end;

function TThemedGridSliderEditor.SafeInt(const AValue: Extended): Integer;
begin
  if AValue > High(Integer) then
    Exit(High(Integer));
  if AValue < Low(Integer) then
    Exit(Low(Integer));
  Result := Integer(Round(TThemedGridEditorSupport.RoundAway(AValue)));
end;

procedure TThemedGridSliderEditor.DoBeginEdit(const AContext: TThemedGridCellEditContext);
var
  LOptions: TThemedGridEditorOptions;
  LOwned: TThemedGridEditorOptions;
  LMinimum, LMaximum: Extended;
begin
  LOwned := nil;
  LOptions := nil;
  if (AContext <> nil) and (AContext.Column <> nil) then
    LOptions := AContext.Column.EditorOptions;
  if LOptions = nil then
  begin
    LOwned := TThemedGridEditorOptions.Create;
    LOptions := LOwned;
  end;
  try
    LMinimum := LOptions.Minimum;
    LMaximum := LOptions.Maximum;
    FScale := LOptions.ValueScale;
  finally
    LOwned.Free;
  end;
  if FScale = 0 then
    FScale := 1;
  if LMaximum < LMinimum then
    LMaximum := LMinimum;
  FSlider.SetRange(SafeInt(LMinimum), SafeInt(LMaximum));
  SetValue(OriginalValue);
  FocusEditor;
end;

function TThemedGridSliderEditor.GetValue: TValue;
var
  LValue: Extended;
begin
  LValue := FSlider.Position;
  if FScale <> 0 then
    LValue := LValue / FScale;
  Result := TThemedGridEditorSupport.ConvertNumber(LValue, ValueType);
end;

procedure TThemedGridSliderEditor.SetValue(const AValue: TValue);
var
  LValue: Extended;
begin
  LValue := TThemedGridValueFormatter.ToDecimal(AValue);
  if FScale <> 0 then
    LValue := LValue * FScale;
  FSlider.Position := SafeInt(LValue);
end;

procedure TThemedGridSliderEditor.AttachHooks(const AKeyDown: TKeyEvent; const AExit: TNotifyEvent);
begin
  FSlider.OnEditorKeyDown := AKeyDown;
  FSlider.OnEditorExit := AExit;
end;

constructor TThemedGridRatingEditor.Create;
begin
  inherited Create;
  FRating := TThemedGridRatingControl.Create(nil);
  InitControl(FRating);
end;

procedure TThemedGridRatingEditor.DoBeginEdit(const AContext: TThemedGridCellEditContext);
var
  LMaximum: Extended;
begin
  if (AContext <> nil) and (AContext.Column <> nil) then
  begin
    LMaximum := AContext.Column.EditorOptions.Maximum;
    if (LMaximum >= 1) and (LMaximum <= 20) then
      FRating.Maximum := Integer(Round(TThemedGridEditorSupport.RoundAway(LMaximum)));
  end;
  SetValue(OriginalValue);
  FocusEditor;
end;

function TThemedGridRatingEditor.GetValue: TValue;
begin
  Result := TThemedGridEditorSupport.ConvertNumber(FRating.Rating, ValueType);
end;

procedure TThemedGridRatingEditor.SetValue(const AValue: TValue);
begin
  FRating.Rating := TThemedGridValueFormatter.ToDecimal(AValue);
end;

procedure TThemedGridRatingEditor.AttachHooks(const AKeyDown: TKeyEvent; const AExit: TNotifyEvent);
begin
  FRating.OnEditorKeyDown := AKeyDown;
  FRating.OnEditorExit := AExit;
end;

end.

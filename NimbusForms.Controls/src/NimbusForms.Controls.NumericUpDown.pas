{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.NumericUpDown;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.Types,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  NimbusForms.Theming.Palette,
  NimbusForms.Controls.Types,
  NimbusForms.Controls.Base,
  NimbusForms.Rendering.NumericUpDown;

type
  TCustomThemedNumericUpDown = class(TCustomNimbusControl)
  private
    FEditor: TEdit;
    FValue: Extended;
    FMinimum: Extended;
    FMaximum: Extended;
    FIncrement: Extended;
    FDecimalPlaces: Integer;
    FHovered: Boolean;
    FFocused: Boolean;
    FHoverUp: Boolean;
    FHoverDown: Boolean;
    FPressedUp: Boolean;
    FPressedDown: Boolean;
    FUpdatingText: Boolean;
    FNormalizeTextOnExit: Boolean;
    FRepeatTimer: TTimer;
    FRepeatFast: Boolean;
    FLogicalBorderThickness: Integer;
    FLogicalButtonWidth: Integer;
    FLogicalPaddingLeft: Integer;
    FLogicalPaddingTop: Integer;
    FLogicalPaddingRight: Integer;
    FLogicalPaddingBottom: Integer;
    FCompactNormalHeight: Integer;
    FCompactAppliedHeight: Integer;
    FOnValueChanged: TNotifyEvent;
    procedure SetValue(const AValue: Extended);
    procedure SetMinimum(const AValue: Extended);
    procedure SetMaximum(const AValue: Extended);
    procedure SetIncrement(const AValue: Extended);
    procedure SetDecimalPlaces(const AValue: Integer);
    function GetTextAlign: TAlignment;
    procedure SetTextAlign(const AValue: TAlignment);
    procedure UpdateText;
    procedure UpdateEditorBounds;
    procedure UpdateEditorTheme;
    function BuildRenderContext: TThemedNumericUpDownRenderContext;
    procedure EditorChange(Sender: TObject);
    procedure EditorEnter(Sender: TObject);
    procedure EditorExit(Sender: TObject);
    procedure EditorMouseEnter(Sender: TObject);
    procedure EditorMouseLeave(Sender: TObject);
    procedure EditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure RepeatTick(Sender: TObject);
    procedure StopRepeat;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMCaptureChanged(var Message: TMessage); message WM_CAPTURECHANGED;
  protected
    procedure StyleModeChanged; override;
    procedure SetParent(AParent: TWinControl); override;
    procedure Paint; override;
    procedure Resize; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DoEnter; override;
    procedure DoValueChanged; virtual;
    property Value: Extended read FValue write SetValue;
    property Minimum: Extended read FMinimum write SetMinimum;
    property Maximum: Extended read FMaximum write SetMaximum;
    property Increment: Extended read FIncrement write SetIncrement;
    property DecimalPlaces: Integer read FDecimalPlaces write SetDecimalPlaces default 0;
    property TextAlign: TAlignment read GetTextAlign write SetTextAlign default taLeftJustify;
    property OnValueChanged: TNotifyEvent read FOnValueChanged write FOnValueChanged;
    property NormalizeTextOnExit: Boolean read FNormalizeTextOnExit write FNormalizeTextOnExit default True;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette); override;
    procedure ResetEditorText;
    property Editor: TEdit read FEditor;
  end;

  TThemedNumericUpDown = class(TCustomThemedNumericUpDown)
  published
    property StyleMode;
    property Align;
    property Anchors;
    property BiDiMode;
    property Constraints;
    property DecimalPlaces;
    property Enabled;
    property Font;
    property Increment;
    property Maximum;
    property Minimum;
    property NormalizeTextOnExit;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property TextAlign;
    property Value;
    property Visible;
    property OnContextPopup;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnValueChanged;
  end;

implementation

uses
  System.UITypes,
  System.SysUtils,
  System.Math,
  Vcl.Forms,
  Vcl.Graphics,
  NimbusForms.Theming.Types,
  NimbusForms.Rendering.Types,
  NimbusForms.Controls.KeyboardEdit;

constructor TCustomThemedNumericUpDown.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csCaptureMouse];
  Width := 160;
  Height := 28;
  TabStop := True;
  FValue := 0;
  FMinimum := 0;
  FMaximum := 100;
  FIncrement := 1;
  FDecimalPlaces := 0;
  FNormalizeTextOnExit := True;
  FLogicalBorderThickness := 1;
  FLogicalButtonWidth := 18;
  FLogicalPaddingLeft := 6;
  FLogicalPaddingTop := 5;
  FLogicalPaddingRight := 24;
  FLogicalPaddingBottom := 5;
  FEditor := TNimbusKeyboardEdit.Create(Self);
  FEditor.BorderStyle := Vcl.Forms.bsNone;
  FEditor.ParentFont := False;
  FEditor.Font.Assign(Font);
  FEditor.ParentColor := False;
  FEditor.TabStop := False;
  FEditor.AutoSize := False;
  FEditor.Alignment := taLeftJustify;
  FEditor.StyleElements := [];
  FEditor.OnChange := EditorChange;
  FEditor.OnEnter := EditorEnter;
  FEditor.OnExit := EditorExit;
  FEditor.OnMouseEnter := EditorMouseEnter;
  FEditor.OnMouseLeave := EditorMouseLeave;
  FEditor.OnKeyDown := EditorKeyDown;
  FRepeatTimer := TTimer.Create(Self);
  FRepeatTimer.Enabled := False;
  FRepeatTimer.Interval := 420;
  FRepeatTimer.OnTimer := RepeatTick;
  UpdateText;
end;

destructor TCustomThemedNumericUpDown.Destroy;
begin
  StopRepeat;
  if FRepeatTimer <> nil then FRepeatTimer.OnTimer := nil;
  inherited Destroy;
end;

procedure TCustomThemedNumericUpDown.ApplyTheme(const APalette: TThemePalette);
begin
  inherited ApplyTheme(APalette);
  UpdateEditorTheme;
end;

procedure TCustomThemedNumericUpDown.StyleModeChanged;
begin
  inherited StyleModeChanged;
  if Align = alNone then
  begin
    if StyleMode = stCompact then
    begin
      if Height > 0 then
      begin
        FCompactNormalHeight := Height;
        FCompactAppliedHeight := Max(ScaleValue(20), (Height * 23 + 28 div 2) div 28);
        Height := FCompactAppliedHeight;
      end;
    end
    else if FCompactNormalHeight > 0 then
    begin
      if Height = FCompactAppliedHeight then Height := FCompactNormalHeight;
      FCompactNormalHeight := 0;
      FCompactAppliedHeight := 0;
    end;
  end;
  UpdateEditorBounds;
end;

procedure TCustomThemedNumericUpDown.SetParent(AParent: TWinControl);
begin
  if AParent = nil then StopRepeat;
  if (AParent = nil) and (FEditor <> nil) and (FEditor.Parent = Self) then FEditor.Parent := nil;
  inherited SetParent(AParent);
  if (AParent <> nil) and (FEditor <> nil) and (FEditor.Parent <> Self) then
  begin
    FEditor.Parent := Self;
    UpdateEditorBounds;
    UpdateEditorTheme;
  end;
end;

procedure TCustomThemedNumericUpDown.SetValue(const AValue: Extended);
var
  LValue: Extended;
begin
  LValue := AValue;
  if LValue < FMinimum then LValue := FMinimum;
  if LValue > FMaximum then LValue := FMaximum;
  if SameValue(FValue, LValue) then
    Exit;
  FValue := LValue;
  UpdateText;
  DoValueChanged;
end;

procedure TCustomThemedNumericUpDown.SetMinimum(const AValue: Extended);
begin
  if SameValue(FMinimum, AValue) then
    Exit;
  FMinimum := AValue;
  if FMaximum < FMinimum then FMaximum := FMinimum;
  if FValue < FMinimum then Value := FMinimum else UpdateText;
end;

procedure TCustomThemedNumericUpDown.SetMaximum(const AValue: Extended);
begin
  if SameValue(FMaximum, AValue) then
    Exit;
  FMaximum := AValue;
  if FMinimum > FMaximum then FMinimum := FMaximum;
  if FValue > FMaximum then Value := FMaximum else UpdateText;
end;

procedure TCustomThemedNumericUpDown.SetIncrement(const AValue: Extended);
begin
  if SameValue(FIncrement, AValue) then
    Exit;
  FIncrement := AValue;
end;

procedure TCustomThemedNumericUpDown.SetDecimalPlaces(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 0 then LValue := 0;
  if LValue > 15 then LValue := 15;
  if FDecimalPlaces = LValue then
    Exit;
  FDecimalPlaces := LValue;
  UpdateText;
end;

function TCustomThemedNumericUpDown.GetTextAlign: TAlignment;
begin
  Result := FEditor.Alignment;
end;

procedure TCustomThemedNumericUpDown.SetTextAlign(const AValue: TAlignment);
begin
  if FEditor.Alignment = AValue then
    Exit;
  FEditor.Alignment := AValue;
end;

procedure TCustomThemedNumericUpDown.ResetEditorText;
begin
  UpdateText;
end;

procedure TCustomThemedNumericUpDown.UpdateText;
var
  LText: string;
  LFormat: TFormatSettings;
begin
  LFormat := TFormatSettings.Create;
  LText := FloatToStrF(FValue, ffFixed, 18, FDecimalPlaces, LFormat);
  if FEditor.Text = LText then
    Exit;
  FUpdatingText := True;
  try
    FEditor.Text := LText;
  finally
    FUpdatingText := False;
  end;
end;

procedure TCustomThemedNumericUpDown.UpdateEditorBounds;
var
  LBorder, LLeft, LTop, LRight, LBottom, LHeight, LTextHeight: Integer;
begin
  if (FEditor = nil) or (FEditor.Parent <> Self) or (Parent = nil) then
    Exit;
  LBorder := ScaleValue(FLogicalBorderThickness);
  LLeft := LBorder + ScaleValue(FLogicalPaddingLeft - Ord(StyleMode = stCompact) * 2);
  LTop := LBorder + ScaleValue(Max(1, FLogicalPaddingTop - Ord(StyleMode = stCompact) * 2));
  LRight := Width - LBorder - ScaleValue(FLogicalPaddingRight - Ord(StyleMode = stCompact) * 5);
  LBottom := Height - LBorder - ScaleValue(Max(1, FLogicalPaddingBottom - Ord(StyleMode = stCompact) * 2));
  if LRight <= LLeft then LRight := LLeft + 1;
  if LBottom <= LTop then LBottom := LTop + 1;
  LHeight := LBottom - LTop;
  LTextHeight := Abs(Font.Height) + ScaleValue(6);
  if LTextHeight < 1 then LTextHeight := 1;
  if LTextHeight > LHeight then LTextHeight := LHeight;
  LTop := (Height - LTextHeight) div 2;
  FEditor.SetBounds(LLeft, LTop, Max(1, LRight - LLeft), LTextHeight);
end;

procedure TCustomThemedNumericUpDown.UpdateEditorTheme;
var
  LBack, LFore: TThemeColor;
begin
  if (FEditor = nil) or (FEditor.Parent <> Self) or (Parent = nil) then
    Exit;
  if Enabled then
  begin
    LBack := NimbusInputBackColor(Palette);
    LFore := NimbusInputForeColor(Palette);
  end
  else
  begin
    LBack := NimbusDisabledBackColor(Palette);
    LFore := NimbusDisabledForeColor(Palette);
  end;
  FEditor.Color := ThemeColorToColor(LBack);
  FEditor.Font.Color := ThemeColorToColor(LFore);
  FEditor.Enabled := Enabled;
  FEditor.Invalidate;
end;

function TCustomThemedNumericUpDown.BuildRenderContext: TThemedNumericUpDownRenderContext;
begin
  Result.Bounds := ClientRect;
  Result.Palette := Palette;
  Result.BorderThickness := ScaleValue(FLogicalBorderThickness);
  Result.ButtonWidth := ScaleValue(FLogicalButtonWidth - Ord(StyleMode = stCompact) * 2);
  Result.Enabled := Enabled;
  Result.Focused := FFocused;
  Result.Hovered := FHovered;
  Result.HoverUp := FHoverUp;
  Result.HoverDown := FHoverDown;
  Result.PressedUp := FPressedUp;
  Result.PressedDown := FPressedDown;
end;

procedure TCustomThemedNumericUpDown.EditorChange(Sender: TObject);
var
  LValue: Extended;
  LFormat: TFormatSettings;
begin
  if FUpdatingText then
    Exit;
  LFormat := TFormatSettings.Create;
  if TryStrToFloat(FEditor.Text, LValue, LFormat) and (LValue >= FMinimum) and (LValue <= FMaximum) and not SameValue(FValue, LValue) then
  begin
    FValue := LValue;
    DoValueChanged;
  end;
end;

procedure TCustomThemedNumericUpDown.EditorEnter(Sender: TObject);
begin
  FFocused := True;
  Invalidate;
end;

procedure TCustomThemedNumericUpDown.EditorExit(Sender: TObject);
begin
  FFocused := False;
  if FNormalizeTextOnExit then UpdateText;
  Invalidate;
end;

procedure TCustomThemedNumericUpDown.EditorMouseEnter(Sender: TObject);
begin
  FHovered := True;
  Invalidate;
end;

procedure TCustomThemedNumericUpDown.EditorMouseLeave(Sender: TObject);
begin
  if not PtInRect(ClientRect, ScreenToClient(Mouse.CursorPos)) then
  begin
    FHovered := False;
    FHoverUp := False;
    FHoverDown := False;
    Invalidate;
  end;
end;

procedure TCustomThemedNumericUpDown.EditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_UP:
      begin
        Value := FValue + FIncrement;
        Key := 0;
      end;
    VK_DOWN:
      begin
        Value := FValue - FIncrement;
        Key := 0;
      end;
  else
    KeyDown(Key, Shift);
  end;
end;

procedure TCustomThemedNumericUpDown.StopRepeat;
begin
  if FRepeatTimer <> nil then FRepeatTimer.Enabled := False;
  FRepeatFast := False;
end;

procedure TCustomThemedNumericUpDown.RepeatTick(Sender: TObject);
var
  LPoint: TPoint;
  LContext: TThemedNumericUpDownRenderContext;
begin
  if (csDestroying in ComponentState) or not Enabled or (Parent = nil) or not MouseCapture or
    not (FPressedUp or FPressedDown) then
  begin
    StopRepeat;
    Exit;
  end;
  if not FRepeatFast then
  begin
    FRepeatFast := True;
    FRepeatTimer.Interval := 70;
  end;
  LPoint := ScreenToClient(Mouse.CursorPos);
  LContext := BuildRenderContext;
  if FPressedUp and PtInRect(TThemedNumericUpDownRenderer.CalculateUpRect(LContext), LPoint) then Value := FValue + FIncrement
  else if FPressedDown and PtInRect(TThemedNumericUpDownRenderer.CalculateDownRect(LContext), LPoint) then Value := FValue - FIncrement;
end;

procedure TCustomThemedNumericUpDown.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  if not Enabled then
  begin
    StopRepeat;
    FPressedUp := False;
    FPressedDown := False;
    if MouseCapture then MouseCapture := False;
  end;
  UpdateEditorTheme;
  Invalidate;
end;

procedure TCustomThemedNumericUpDown.CMFontChanged(var Message: TMessage);
begin
  inherited;
  if FEditor <> nil then FEditor.Font.Assign(Font);
  UpdateEditorBounds;
end;

procedure TCustomThemedNumericUpDown.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if not PtInRect(ClientRect, ScreenToClient(Mouse.CursorPos)) then
  begin
    FHovered := False;
    FHoverUp := False;
    FHoverDown := False;
    if not MouseCapture then
    begin
      FPressedUp := False;
      FPressedDown := False;
    end;
    Invalidate;
  end;
end;

procedure TCustomThemedNumericUpDown.WMCaptureChanged(var Message: TMessage);
begin
  inherited;
  StopRepeat;
  FPressedUp := False;
  FPressedDown := False;
  Invalidate;
end;

procedure TCustomThemedNumericUpDown.Resize;
begin
  inherited Resize;
  UpdateEditorBounds;
  Invalidate;
end;

procedure TCustomThemedNumericUpDown.DoEnter;
begin
  inherited DoEnter;
  if (FEditor.Parent = Self) and FEditor.CanFocus then FEditor.SetFocus;
end;

procedure TCustomThemedNumericUpDown.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LContext: TThemedNumericUpDownRenderContext;
  LPoint: TPoint;
  LUp, LDown: Boolean;
begin
  inherited MouseMove(Shift, X, Y);
  FHovered := True;
  LContext := BuildRenderContext;
  LPoint := Point(X, Y);
  LUp := PtInRect(TThemedNumericUpDownRenderer.CalculateUpRect(LContext), LPoint);
  LDown := PtInRect(TThemedNumericUpDownRenderer.CalculateDownRect(LContext), LPoint);
  if (FHoverUp <> LUp) or (FHoverDown <> LDown) then
  begin
    FHoverUp := LUp;
    FHoverDown := LDown;
    Invalidate;
  end;
end;

procedure TCustomThemedNumericUpDown.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LContext: TThemedNumericUpDownRenderContext;
  LPoint: TPoint;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button <> mbLeft) or not Enabled then
    Exit;
  LContext := BuildRenderContext;
  LPoint := Point(X, Y);
  if PtInRect(TThemedNumericUpDownRenderer.CalculateUpRect(LContext), LPoint) then
  begin
    FPressedUp := True;
    Value := FValue + FIncrement;
    MouseCapture := True;
    FRepeatFast := False;
    FRepeatTimer.Interval := 420;
    FRepeatTimer.Enabled := True;
  end
  else if PtInRect(TThemedNumericUpDownRenderer.CalculateDownRect(LContext), LPoint) then
  begin
    FPressedDown := True;
    Value := FValue - FIncrement;
    MouseCapture := True;
    FRepeatFast := False;
    FRepeatTimer.Interval := 420;
    FRepeatTimer.Enabled := True;
  end
  else if (FEditor.Parent = Self) and FEditor.CanFocus then
    FEditor.SetFocus;
  Invalidate;
end;

procedure TCustomThemedNumericUpDown.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if Button <> mbLeft then Exit;
  StopRepeat;
  FPressedUp := False;
  FPressedDown := False;
  MouseCapture := False;
  Invalidate;
end;

procedure TCustomThemedNumericUpDown.DoValueChanged;
begin
  if Assigned(FOnValueChanged) then FOnValueChanged(Self);
end;

procedure TCustomThemedNumericUpDown.Paint;
var
  LContext: TThemedNumericUpDownRenderContext;
begin
  RenderCanvas.BeginRender(Canvas);
  try
    LContext := BuildRenderContext;
    TThemedNumericUpDownRenderer.Render(RenderCanvas, LContext);
  finally
    RenderCanvas.EndRender;
  end;
end;

end.

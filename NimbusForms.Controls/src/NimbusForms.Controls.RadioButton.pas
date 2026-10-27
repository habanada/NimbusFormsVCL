{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.RadioButton;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  Vcl.Controls,
  NimbusForms.Controls.Types,
  NimbusForms.Controls.Base;

type
  TCustomThemedRadioButton = class(TCustomNimbusControl)
  private
    FChecked: Boolean;
    FAutoCheck: Boolean;
    FHot: Boolean;
    FPressed: Boolean;
    FIndicatorSize: Integer;
    FSpacing: Integer;
    FOnCheckedChanged: TNotifyEvent;
    procedure SetChecked(const AValue: Boolean);
    procedure SetAutoCheck(const AValue: Boolean);
    procedure SetIndicatorSize(const AValue: Integer);
    procedure SetSpacing(const AValue: Integer);
    procedure TurnSiblingsOff;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
  protected
    procedure StyleModeChanged; override;
    procedure DoCheckedChanged; virtual;
    procedure Paint; override;
    procedure Click; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure DoEnter; override;
    procedure DoExit; override;
    property Checked: Boolean read FChecked write SetChecked default False;
    property AutoCheck: Boolean read FAutoCheck write SetAutoCheck default True;
    property IndicatorSize: Integer read FIndicatorSize write SetIndicatorSize default 15;
    property Spacing: Integer read FSpacing write SetSpacing default 6;
    property OnCheckedChanged: TNotifyEvent read FOnCheckedChanged write FOnCheckedChanged;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TThemedRadioButton = class(TCustomThemedRadioButton)
  published
    property StyleMode;
    property Action;
    property Align;
    property Anchors;
    property AutoCheck;
    property BiDiMode;
    property Caption;
    property Checked;
    property Constraints;
    property Enabled;
    property Font;
    property IndicatorSize;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Spacing;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property OnCheckedChanged;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
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
  end;

implementation

uses
  System.Math,
  Vcl.Forms,
  NimbusForms.Rendering.Types,
  NimbusForms.Rendering.RadioButton;

constructor TCustomThemedRadioButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 120;
  Height := 24;
  Constraints.MinWidth := 20;
  Constraints.MinHeight := 20;
  TabStop := True;
  FChecked := False;
  FAutoCheck := True;
  FIndicatorSize := 15;
  FSpacing := 6;
end;

procedure TCustomThemedRadioButton.StyleModeChanged;
begin
  inherited StyleModeChanged;
  UpdateStyleHeight(24, 20);
end;

procedure TCustomThemedRadioButton.SetChecked(const AValue: Boolean);
begin
  if FChecked = AValue then
    Exit;
  if AValue then
    TurnSiblingsOff;
  FChecked := AValue;
  Invalidate;
  DoCheckedChanged;
end;

procedure TCustomThemedRadioButton.DoCheckedChanged;
begin
  if Assigned(FOnCheckedChanged) then
    FOnCheckedChanged(Self);
end;

procedure TCustomThemedRadioButton.SetAutoCheck(const AValue: Boolean);
begin
  if FAutoCheck = AValue then
    Exit;
  FAutoCheck := AValue;
end;

procedure TCustomThemedRadioButton.SetIndicatorSize(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 8 then LValue := 8;
  if FIndicatorSize = LValue then
    Exit;
  FIndicatorSize := LValue;
  Invalidate;
end;

procedure TCustomThemedRadioButton.SetSpacing(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 0 then LValue := 0;
  if FSpacing = LValue then
    Exit;
  FSpacing := LValue;
  Invalidate;
end;

procedure TCustomThemedRadioButton.TurnSiblingsOff;
var
  I: Integer;
  LControl: TControl;
begin
  if Parent = nil then
    Exit;
  for I := 0 to Parent.ControlCount - 1 do
  begin
    LControl := Parent.Controls[I];
    if (LControl <> Self) and (LControl is TCustomThemedRadioButton) then
      TCustomThemedRadioButton(LControl).SetChecked(False);
  end;
end;

procedure TCustomThemedRadioButton.Click;
begin
  if Enabled and FAutoCheck then
    SetChecked(True);
  inherited Click;
end;

procedure TCustomThemedRadioButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if not FHot then
  begin
    FHot := True;
    Invalidate;
  end;
end;

procedure TCustomThemedRadioButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if FHot or FPressed then
  begin
    FHot := False;
    FPressed := False;
    Invalidate;
  end;
end;

procedure TCustomThemedRadioButton.CMDialogChar(var Message: TCMDialogChar);
begin
  if Enabled and Vcl.Forms.IsAccel(Message.CharCode, Caption) then
  begin
    if CanFocus then SetFocus;
    Click;
    Message.Result := 1;
    Exit;
  end;
  inherited;
end;

procedure TCustomThemedRadioButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button = mbLeft) and Enabled then
  begin
    if CanFocus then SetFocus;
    FPressed := True;
    Invalidate;
  end;
end;

procedure TCustomThemedRadioButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if (Button = mbLeft) and FPressed then
  begin
    FPressed := False;
    Invalidate;
  end;
end;

procedure TCustomThemedRadioButton.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if Enabled and (Key = VK_SPACE) and not FPressed then
  begin
    FPressed := True;
    Invalidate;
    Key := 0;
  end;
end;

procedure TCustomThemedRadioButton.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited KeyUp(Key, Shift);
  if Enabled and (Key = VK_SPACE) and FPressed then
  begin
    FPressed := False;
    Invalidate;
    Click;
    Key := 0;
  end;
end;

procedure TCustomThemedRadioButton.DoEnter;
begin
  inherited DoEnter;
  Invalidate;
end;

procedure TCustomThemedRadioButton.DoExit;
begin
  FPressed := False;
  inherited DoExit;
  Invalidate;
end;

procedure TCustomThemedRadioButton.Paint;
var
  LContext: TThemedRadioButtonRenderContext;
  LBorderThickness: Single;
begin
  RenderCanvas.BeginRender(Canvas);
  try
    LBorderThickness := 1.5 * CurrentPPI / 96.0;
    if LBorderThickness < 1.0 then LBorderThickness := 1.0;
    LContext.Bounds := ClientRect;
    LContext.Caption := Caption;
    LContext.Font := Font;
    LContext.Palette := Palette;
    if not Enabled then
      LContext.State := nvsDisabled
    else if FPressed then
      LContext.State := nvsPressed
    else if FHot then
      LContext.State := nvsHot
    else if Focused then
      LContext.State := nvsFocused
    else
      LContext.State := nvsNormal;
    LContext.Checked := FChecked;
    LContext.CircleSize := ScaleValue(Max(8, FIndicatorSize - Ord(StyleMode = stCompact) * 2));
    LContext.CircleOffsetX := ScaleValue(2);
    LContext.TextSpacing := ScaleValue(Max(0, FSpacing - Ord(StyleMode = stCompact) * 2));
    LContext.DotSize := ScaleValue(7);
    LContext.CircleBorderThickness := LBorderThickness;
    LContext.Focused := Focused;
    LContext.RightToLeft := UseRightToLeftAlignment;
    TThemedRadioButtonRenderer.Render(RenderCanvas, LContext);
  finally
    RenderCanvas.EndRender;
  end;
end;

end.

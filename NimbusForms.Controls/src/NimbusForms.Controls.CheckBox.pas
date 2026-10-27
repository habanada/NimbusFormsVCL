{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.CheckBox;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  Vcl.Controls,
  Vcl.StdCtrls,
  NimbusForms.Controls.Types,
  NimbusForms.Controls.Base;

type
  TCustomThemedCheckBox = class(TCustomNimbusControl)
  private
    FState: TCheckBoxState;
    FAllowGrayed: Boolean;
    FHot: Boolean;
    FPressed: Boolean;
    FBoxSize: Integer;
    FSpacing: Integer;
    FCornerRadius: Integer;
    FOnCheckedChanged: TNotifyEvent;
    function GetChecked: Boolean;
    procedure SetChecked(const AValue: Boolean);
    procedure SetState(const AValue: TCheckBoxState);
    procedure SetAllowGrayed(const AValue: Boolean);
    procedure SetBoxSize(const AValue: Integer);
    procedure SetSpacing(const AValue: Integer);
    procedure SetCornerRadius(const AValue: Integer);
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure AdvanceState;
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
    property Checked: Boolean read GetChecked write SetChecked default False;
    property State: TCheckBoxState read FState write SetState default cbUnchecked;
    property AllowGrayed: Boolean read FAllowGrayed write SetAllowGrayed default False;
    property BoxSize: Integer read FBoxSize write SetBoxSize default 15;
    property Spacing: Integer read FSpacing write SetSpacing default 6;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 3;
    property OnCheckedChanged: TNotifyEvent read FOnCheckedChanged write FOnCheckedChanged;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TThemedCheckBox = class(TCustomThemedCheckBox)
  published
    property StyleMode;
    property Action;
    property Align;
    property AllowGrayed;
    property Anchors;
    property BiDiMode;
    property BoxSize;
    property Caption;
    property Checked;
    property Constraints;
    property CornerRadius;
    property Enabled;
    property Font;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Spacing;
    property State;
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
  NimbusForms.Rendering.CheckBox;

constructor TCustomThemedCheckBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 120;
  Height := 24;
  TabStop := True;
  FState := cbUnchecked;
  FAllowGrayed := False;
  FBoxSize := 15;
  FSpacing := 6;
  FCornerRadius := 3;
end;

function TCustomThemedCheckBox.GetChecked: Boolean;
begin
  Result := FState = cbChecked;
end;

procedure TCustomThemedCheckBox.StyleModeChanged;
begin
  inherited StyleModeChanged;
  UpdateStyleHeight(24, 20);
end;

procedure TCustomThemedCheckBox.SetChecked(const AValue: Boolean);
begin
  if AValue then
    SetState(cbChecked)
  else
    SetState(cbUnchecked);
end;

procedure TCustomThemedCheckBox.SetState(const AValue: TCheckBoxState);
var
  LValue: TCheckBoxState;
begin
  LValue := AValue;
  if (LValue = cbGrayed) and not FAllowGrayed then
    LValue := cbUnchecked;
  if FState = LValue then
    Exit;
  FState := LValue;
  Invalidate;
  DoCheckedChanged;
end;

procedure TCustomThemedCheckBox.SetAllowGrayed(const AValue: Boolean);
begin
  if FAllowGrayed = AValue then
    Exit;
  FAllowGrayed := AValue;
  if not FAllowGrayed and (FState = cbGrayed) then
    SetState(cbUnchecked);
end;

procedure TCustomThemedCheckBox.SetBoxSize(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 8 then LValue := 8;
  if FBoxSize = LValue then
    Exit;
  FBoxSize := LValue;
  Invalidate;
end;

procedure TCustomThemedCheckBox.SetSpacing(const AValue: Integer);
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

procedure TCustomThemedCheckBox.SetCornerRadius(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 0 then LValue := 0;
  if FCornerRadius = LValue then
    Exit;
  FCornerRadius := LValue;
  Invalidate;
end;

procedure TCustomThemedCheckBox.DoCheckedChanged;
begin
  if Assigned(FOnCheckedChanged) then
    FOnCheckedChanged(Self);
end;

procedure TCustomThemedCheckBox.AdvanceState;
begin
  if FAllowGrayed then
    case FState of
      cbUnchecked: SetState(cbChecked);
      cbChecked: SetState(cbGrayed);
      cbGrayed: SetState(cbUnchecked);
    end
  else
    SetChecked(not Checked);
end;

procedure TCustomThemedCheckBox.Click;
begin
  if Enabled then
    AdvanceState;
  inherited Click;
end;

procedure TCustomThemedCheckBox.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if not FHot then
  begin
    FHot := True;
    Invalidate;
  end;
end;

procedure TCustomThemedCheckBox.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if FHot or FPressed then
  begin
    FHot := False;
    FPressed := False;
    Invalidate;
  end;
end;

procedure TCustomThemedCheckBox.CMDialogChar(var Message: TCMDialogChar);
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

procedure TCustomThemedCheckBox.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button = mbLeft) and Enabled then
  begin
    if CanFocus then SetFocus;
    FPressed := True;
    Invalidate;
  end;
end;

procedure TCustomThemedCheckBox.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if (Button = mbLeft) and FPressed then
  begin
    FPressed := False;
    Invalidate;
  end;
end;

procedure TCustomThemedCheckBox.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if Enabled and (Key = VK_SPACE) and not FPressed then
  begin
    FPressed := True;
    Invalidate;
    Key := 0;
  end;
end;

procedure TCustomThemedCheckBox.KeyUp(var Key: Word; Shift: TShiftState);
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

procedure TCustomThemedCheckBox.DoEnter;
begin
  inherited DoEnter;
  Invalidate;
end;

procedure TCustomThemedCheckBox.DoExit;
begin
  FPressed := False;
  inherited DoExit;
  Invalidate;
end;

procedure TCustomThemedCheckBox.Paint;
var
  LContext: TThemedCheckBoxRenderContext;
begin
  RenderCanvas.BeginRender(Canvas);
  try
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
    LContext.CheckState := FState;
    LContext.BoxSize := ScaleValue(Max(8, FBoxSize - Ord(StyleMode = stCompact) * 2));
    LContext.Spacing := ScaleValue(Max(0, FSpacing - Ord(StyleMode = stCompact) * 2));
    LContext.CornerRadius := ScaleValue(FCornerRadius);
    LContext.Focused := Focused;
    LContext.RightToLeft := UseRightToLeftAlignment;
    TThemedCheckBoxRenderer.Render(RenderCanvas, LContext);
  finally
    RenderCanvas.EndRender;
  end;
end;

end.

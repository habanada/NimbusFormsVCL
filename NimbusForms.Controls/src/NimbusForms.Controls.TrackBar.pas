{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.TrackBar;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.Types,
  Vcl.Controls,
  NimbusForms.Controls.Base, NimbusForms.Controls.Types;

type
  TCustomThemedTrackBar = class(TCustomNimbusControl)
  private
    FMinimum: Integer;
    FMaximum: Integer;
    FValue: Integer;
    FDragging: Boolean;
    FHovered: Boolean;
    FLogicalThumbSize: Integer;
    FLogicalTrackThickness: Integer;
    FOnValueChanged: TNotifyEvent;
    procedure SetMinimum(const AValue: Integer);
    procedure SetMaximum(const AValue: Integer);
    procedure SetValue(const AValue: Integer);
    procedure UpdateValueFromMouse(const AX: Integer);
    function GetThumbRect: TRect;
    procedure WMCaptureChanged(var Message: TMessage); message WM_CAPTURECHANGED;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
  protected
    procedure StyleModeChanged; override;
    procedure Paint; override;
    procedure Resize; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure DoValueChanged; virtual;
    property Minimum: Integer read FMinimum write SetMinimum default 0;
    property Maximum: Integer read FMaximum write SetMaximum default 100;
    property Value: Integer read FValue write SetValue default 0;
    property OnValueChanged: TNotifyEvent read FOnValueChanged write FOnValueChanged;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TThemedTrackBar = class(TCustomThemedTrackBar)
  published
    property StyleMode;
    property Align;
    property Anchors;
    property BiDiMode;
    property Constraints;
    property Enabled;
    property Maximum;
    property Minimum;
    property ParentBiDiMode;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
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
  System.Math,
  NimbusForms.Rendering.TrackBar;

constructor TCustomThemedTrackBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csCaptureMouse];
  Width := 150;
  Height := 24;
  TabStop := True;
  FMinimum := 0;
  FMaximum := 100;
  FValue := 0;
  FLogicalThumbSize := 16;
  FLogicalTrackThickness := 4;
end;

procedure TCustomThemedTrackBar.StyleModeChanged;
begin
  inherited StyleModeChanged;
  UpdateStyleHeight(24, 20);
end;

procedure TCustomThemedTrackBar.SetMinimum(const AValue: Integer);
begin
  if FMinimum = AValue then
    Exit;
  FMinimum := AValue;
  if FMaximum < FMinimum then FMaximum := FMinimum;
  if FValue < FMinimum then
    SetValue(FMinimum)
  else
    Invalidate;
end;

procedure TCustomThemedTrackBar.SetMaximum(const AValue: Integer);
begin
  if FMaximum = AValue then
    Exit;
  FMaximum := AValue;
  if FMinimum > FMaximum then FMinimum := FMaximum;
  if FValue > FMaximum then
    SetValue(FMaximum)
  else
    Invalidate;
end;

procedure TCustomThemedTrackBar.SetValue(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < FMinimum then LValue := FMinimum;
  if LValue > FMaximum then LValue := FMaximum;
  if FValue = LValue then
    Exit;
  FValue := LValue;
  Invalidate;
  DoValueChanged;
end;

procedure TCustomThemedTrackBar.DoValueChanged;
begin
  if Assigned(FOnValueChanged) then
    FOnValueChanged(Self);
end;

procedure TCustomThemedTrackBar.UpdateValueFromMouse(const AX: Integer);
var
  LThumbSize, LTrackWidth, LX, LRange: Integer;
  LRatio: Double;
begin
  LThumbSize := ScaleValue(FLogicalThumbSize);
  LTrackWidth := Width - LThumbSize;
  if LTrackWidth <= 0 then
    Exit;
  LX := AX - LThumbSize div 2;
  LRatio := LX / LTrackWidth;
  if LRatio < 0 then LRatio := 0;
  if LRatio > 1 then LRatio := 1;
  LRange := FMaximum - FMinimum;
  if LRange <= 0 then
    Value := FMinimum
  else
    Value := FMinimum + Round(LRatio * LRange);
end;

function TCustomThemedTrackBar.GetThumbRect: TRect;
var
  LContext: TThemedTrackBarRenderContext;
begin
  LContext.Bounds := ClientRect;
  LContext.Palette := Palette;
  LContext.Minimum := FMinimum;
  LContext.Maximum := FMaximum;
  LContext.Value := FValue;
  LContext.ThumbSize := ScaleValue(FLogicalThumbSize - Ord(StyleMode = stCompact) * 4);
  LContext.TrackThickness := ScaleValue(FLogicalTrackThickness - Ord(StyleMode = stCompact));
  LContext.Enabled := Enabled;
  LContext.Hovered := FHovered;
  LContext.Dragging := FDragging;
  LContext.Focused := Focused;
  Result := TThemedTrackBarRenderer.CalculateThumbRect(LContext);
end;

procedure TCustomThemedTrackBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button <> mbLeft) or not Enabled then
    Exit;
  if CanFocus then SetFocus;
  MouseCapture := True;
  FDragging := True;
  Invalidate;
  UpdateValueFromMouse(X);
end;

procedure TCustomThemedTrackBar.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LHovered: Boolean;
begin
  inherited MouseMove(Shift, X, Y);
  if FDragging then UpdateValueFromMouse(X);
  LHovered := PtInRect(GetThumbRect, Point(X, Y));
  if FHovered <> LHovered then
  begin
    FHovered := LHovered;
    Invalidate;
  end;
end;

procedure TCustomThemedTrackBar.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if (Button = mbLeft) and FDragging then
  begin
    FDragging := False;
    MouseCapture := False;
    FHovered := PtInRect(GetThumbRect, Point(X, Y));
    Invalidate;
  end;
end;

procedure TCustomThemedTrackBar.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if not FDragging and FHovered then
  begin
    FHovered := False;
    Invalidate;
  end;
end;

procedure TCustomThemedTrackBar.WMCaptureChanged(var Message: TMessage);
begin
  if FDragging then
  begin
    FDragging := False;
    Invalidate;
  end;
end;

procedure TCustomThemedTrackBar.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  if not Enabled then
  begin
    FDragging := False;
    FHovered := False;
    MouseCapture := False;
  end;
  Invalidate;
end;

procedure TCustomThemedTrackBar.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if not Enabled then
    Exit;
  case Key of
    VK_LEFT, VK_DOWN:
      begin
        Value := FValue - 1;
        Key := 0;
      end;
    VK_RIGHT, VK_UP:
      begin
        Value := FValue + 1;
        Key := 0;
      end;
    VK_HOME:
      begin
        Value := FMinimum;
        Key := 0;
      end;
    VK_END:
      begin
        Value := FMaximum;
        Key := 0;
      end;
  end;
end;

procedure TCustomThemedTrackBar.Resize;
begin
  inherited Resize;
  Invalidate;
end;

procedure TCustomThemedTrackBar.DoEnter;
begin
  Invalidate;
  inherited DoEnter;
end;

procedure TCustomThemedTrackBar.DoExit;
begin
  FDragging := False;
  MouseCapture := False;
  Invalidate;
  inherited DoExit;
end;

procedure TCustomThemedTrackBar.Paint;
var
  LContext: TThemedTrackBarRenderContext;
begin
  RenderCanvas.BeginRender(Canvas);
  try
    LContext.Bounds := ClientRect;
    LContext.Palette := Palette;
    LContext.Minimum := FMinimum;
    LContext.Maximum := FMaximum;
    LContext.Value := FValue;
    LContext.ThumbSize := ScaleValue(FLogicalThumbSize - Ord(StyleMode = stCompact) * 4);
    LContext.TrackThickness := ScaleValue(FLogicalTrackThickness - Ord(StyleMode = stCompact));
    if LContext.ThumbSize < 1 then LContext.ThumbSize := 1;
    if LContext.TrackThickness < 1 then LContext.TrackThickness := 1;
    LContext.Enabled := Enabled;
    LContext.Hovered := FHovered;
    LContext.Dragging := FDragging;
    LContext.Focused := Focused;
    TThemedTrackBarRenderer.Render(RenderCanvas, LContext);
  finally
    RenderCanvas.EndRender;
  end;
end;

end.

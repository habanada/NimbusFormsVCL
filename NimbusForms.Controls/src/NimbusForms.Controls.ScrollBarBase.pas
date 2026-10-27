{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.ScrollBarBase;

interface

uses
  Winapi.Messages,
  System.Classes,
  System.Types,
  Vcl.Controls,
  NimbusForms.Controls.Base,
  NimbusForms.Controls.Types,
  NimbusForms.Rendering.ScrollBar,
  NimbusForms.Rendering.Canvas;

type
  TCustomThemedScrollBar = class(TCustomNimbusControl)
  private
    FOrientation: TNimbusScrollBarOrientation;
    FMinimum: Integer;
    FMaximum: Integer;
    FValue: Integer;
    FSmallChange: Integer;
    FLargeChange: Integer;
    FButtonSize: Integer;
    FMinimumThumbSize: Integer;
    FCompactNormalThickness: Integer;
    FCompactAppliedThickness: Integer;
    FHoverPart: TNimbusScrollBarPart;
    FPressedPart: TNimbusScrollBarPart;
    FDragging: Boolean;
    FDragOffset: Integer;
    FOnValueChanged: TNotifyEvent;
    procedure SetMinimum(const AValue: Integer);
    procedure SetMaximum(const AValue: Integer);
    procedure SetValue(const AValue: Integer);
    procedure SetSmallChange(const AValue: Integer);
    procedure SetLargeChange(const AValue: Integer);
    procedure SetButtonSize(const AValue: Integer);
    procedure SetMinimumThumbSize(const AValue: Integer);
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure WMCaptureChanged(var Message: TMessage); message WM_CAPTURECHANGED;
    function GetEffectiveMaximum: Integer;
    function GetPointerPosition(const AX, AY: Integer): Integer;
    function GetThumbStart(const ALayout: TNimbusScrollBarLayout): Integer;
    procedure ClampStoredValue;
    procedure ChangeValueBy(const ADelta: Int64);
    procedure UpdateHover(const AX, AY: Integer);
  protected
    function BuildRenderContext: TNimbusScrollBarRenderContext;
    procedure RenderOverlay(const ACanvas: INimbusRenderCanvas; const AContext: TNimbusScrollBarRenderContext); virtual;
    procedure StyleModeChanged; override;
    procedure InitializeOrientation(const AOrientation: TNimbusScrollBarOrientation);
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DoValueChanged; virtual;
    property Orientation: TNimbusScrollBarOrientation read FOrientation;
    property Minimum: Integer read FMinimum write SetMinimum default 0;
    property Maximum: Integer read FMaximum write SetMaximum default 100;
    property Value: Integer read FValue write SetValue default 0;
    property SmallChange: Integer read FSmallChange write SetSmallChange default 1;
    property LargeChange: Integer read FLargeChange write SetLargeChange default 10;
    property ButtonSize: Integer read FButtonSize write SetButtonSize default 18;
    property MinimumThumbSize: Integer read FMinimumThumbSize write SetMinimumThumbSize default 24;
    property OnValueChanged: TNotifyEvent read FOnValueChanged write FOnValueChanged;
  public
    constructor Create(AOwner: TComponent); override;
    procedure ScrollSmallBackward;
    procedure ScrollSmallForward;
    procedure ScrollLargeBackward;
    procedure ScrollLargeForward;
    property EffectiveMaximum: Integer read GetEffectiveMaximum;
  end;


implementation

uses
  Winapi.Windows,
  System.Math,
  NimbusForms.Rendering.Types;

constructor TCustomThemedScrollBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csCaptureMouse, csClickEvents];
  TabStop := False;
  FOrientation := nsboHorizontal;
  FMinimum := 0;
  FMaximum := 100;
  FValue := 0;
  FSmallChange := 1;
  FLargeChange := 10;
  FButtonSize := 18;
  FMinimumThumbSize := 24;
  FHoverPart := nsbpNone;
  FPressedPart := nsbpNone;
  Width := 100;
  Height := 18;
end;

procedure TCustomThemedScrollBar.StyleModeChanged;
var
  LThickness: Integer;
begin
  inherited StyleModeChanged;
  if Align <> alNone then Exit;
  if StyleMode = stCompact then
  begin
    if FOrientation = nsboHorizontal then LThickness := Height else LThickness := Width;
    if LThickness <= 0 then Exit;
    FCompactNormalThickness := LThickness;
    FCompactAppliedThickness := Max(ScaleValue(12), (LThickness * 14 + 9) div 18);
    if FOrientation = nsboHorizontal then Height := FCompactAppliedThickness
    else Width := FCompactAppliedThickness;
  end
  else if FCompactNormalThickness > 0 then
  begin
    if FOrientation = nsboHorizontal then
    begin
      if Height = FCompactAppliedThickness then Height := FCompactNormalThickness;
    end
    else if Width = FCompactAppliedThickness then Width := FCompactNormalThickness;
    FCompactNormalThickness := 0;
    FCompactAppliedThickness := 0;
  end;
end;

procedure TCustomThemedScrollBar.InitializeOrientation(const AOrientation: TNimbusScrollBarOrientation);
begin
  FOrientation := AOrientation;
  Invalidate;
end;

function TCustomThemedScrollBar.GetEffectiveMaximum: Integer;
begin
  Result := TThemedScrollBarRenderer.EffectiveMaximum(FMinimum, FMaximum, FLargeChange);
end;

procedure TCustomThemedScrollBar.ClampStoredValue;
var
  LMaximum: Integer;
begin
  LMaximum := GetEffectiveMaximum;
  if FValue < FMinimum then FValue := FMinimum;
  if FValue > LMaximum then FValue := LMaximum;
end;

procedure TCustomThemedScrollBar.SetMinimum(const AValue: Integer);
begin
  if FMinimum = AValue then Exit;
  FMinimum := AValue;
  if FMaximum < FMinimum then FMaximum := FMinimum;
  ClampStoredValue;
  Invalidate;
end;

procedure TCustomThemedScrollBar.SetMaximum(const AValue: Integer);
begin
  if FMaximum = AValue then Exit;
  if AValue < FMinimum then FMaximum := FMinimum else FMaximum := AValue;
  ClampStoredValue;
  Invalidate;
end;

procedure TCustomThemedScrollBar.SetValue(const AValue: Integer);
var
  LValue, LMaximum: Integer;
begin
  LMaximum := GetEffectiveMaximum;
  LValue := AValue;
  if LValue < FMinimum then LValue := FMinimum;
  if LValue > LMaximum then LValue := LMaximum;
  if FValue = LValue then Exit;
  FValue := LValue;
  Invalidate;
  DoValueChanged;
end;

procedure TCustomThemedScrollBar.SetSmallChange(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 1 then LValue := 1;
  if FSmallChange = LValue then Exit;
  FSmallChange := LValue;
end;

procedure TCustomThemedScrollBar.SetLargeChange(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 1 then LValue := 1;
  if FLargeChange = LValue then Exit;
  FLargeChange := LValue;
  ClampStoredValue;
  Invalidate;
end;

procedure TCustomThemedScrollBar.SetButtonSize(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 12 then LValue := 12;
  if FButtonSize = LValue then Exit;
  FButtonSize := LValue;
  Invalidate;
end;

procedure TCustomThemedScrollBar.SetMinimumThumbSize(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 12 then LValue := 12;
  if FMinimumThumbSize = LValue then Exit;
  FMinimumThumbSize := LValue;
  Invalidate;
end;

procedure TCustomThemedScrollBar.DoValueChanged;
begin
  if Assigned(FOnValueChanged) then FOnValueChanged(Self);
end;

procedure TCustomThemedScrollBar.ChangeValueBy(const ADelta: Int64);
var
  LValue: Int64;
begin
  LValue := Int64(FValue) + ADelta;
  if LValue < FMinimum then LValue := FMinimum;
  if LValue > GetEffectiveMaximum then LValue := GetEffectiveMaximum;
  Value := Integer(LValue);
end;

procedure TCustomThemedScrollBar.ScrollSmallBackward;
begin
  ChangeValueBy(-Int64(FSmallChange));
end;

procedure TCustomThemedScrollBar.ScrollSmallForward;
begin
  ChangeValueBy(FSmallChange);
end;

procedure TCustomThemedScrollBar.ScrollLargeBackward;
begin
  ChangeValueBy(-Int64(FLargeChange));
end;

procedure TCustomThemedScrollBar.ScrollLargeForward;
begin
  ChangeValueBy(FLargeChange);
end;

function TCustomThemedScrollBar.BuildRenderContext: TNimbusScrollBarRenderContext;
begin
  Result.Bounds := ClientRect;
  Result.Palette := Palette;
  Result.Orientation := FOrientation;
  Result.Minimum := FMinimum;
  Result.Maximum := FMaximum;
  Result.Value := FValue;
  Result.LargeChange := FLargeChange;
  Result.ButtonSize := ScaleValue(FButtonSize - Ord(StyleMode = stCompact) * 4);
  Result.MinimumThumbSize := ScaleValue(FMinimumThumbSize - Ord(StyleMode = stCompact) * 6);
  Result.ArrowMinorSize := ScaleValue(2);
  Result.ArrowMajorSize := ScaleValue(4);
  if Result.ArrowMinorSize < 1 then Result.ArrowMinorSize := 1;
  if Result.ArrowMajorSize < 2 then Result.ArrowMajorSize := 2;
  Result.Enabled := Enabled;
  Result.HoverDecrease := FHoverPart = nsbpDecreaseButton;
  Result.HoverIncrease := FHoverPart = nsbpIncreaseButton;
  Result.HoverThumb := (FHoverPart = nsbpThumb) or FDragging;
  Result.PressedDecrease := FPressedPart = nsbpDecreaseButton;
  Result.PressedIncrease := FPressedPart = nsbpIncreaseButton;
  Result.PressedThumb := FPressedPart = nsbpThumb;
end;

function TCustomThemedScrollBar.GetPointerPosition(const AX, AY: Integer): Integer;
begin
  if FOrientation = nsboHorizontal then Result := AX else Result := AY;
end;

function TCustomThemedScrollBar.GetThumbStart(const ALayout: TNimbusScrollBarLayout): Integer;
begin
  if FOrientation = nsboHorizontal then Result := ALayout.ThumbRect.Left else Result := ALayout.ThumbRect.Top;
end;

procedure TCustomThemedScrollBar.UpdateHover(const AX, AY: Integer);
var
  LPart: TNimbusScrollBarPart;
begin
  LPart := TThemedScrollBarRenderer.HitTest(BuildRenderContext, Point(AX, AY));
  if FDragging then LPart := nsbpThumb;
  if FHoverPart = LPart then Exit;
  FHoverPart := LPart;
  Invalidate;
end;

procedure TCustomThemedScrollBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LContext: TNimbusScrollBarRenderContext;
  LLayout: TNimbusScrollBarLayout;
  LPart: TNimbusScrollBarPart;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button <> mbLeft) or not Enabled then Exit;
  LContext := BuildRenderContext;
  LPart := TThemedScrollBarRenderer.HitTest(LContext, Point(X, Y));
  FPressedPart := LPart;
  FHoverPart := LPart;
  case LPart of
    nsbpDecreaseButton: ScrollSmallBackward;
    nsbpIncreaseButton: ScrollSmallForward;
    nsbpThumb:
      begin
        TThemedScrollBarRenderer.CalculateLayout(LContext, LLayout);
        FDragging := True;
        FDragOffset := GetPointerPosition(X, Y) - GetThumbStart(LLayout);
      end;
    nsbpTrackBefore: ScrollLargeBackward;
    nsbpTrackAfter: ScrollLargeForward;
  end;
  MouseCapture := True;
  Invalidate;
end;

procedure TCustomThemedScrollBar.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LContext: TNimbusScrollBarRenderContext;
  LPosition: Integer;
begin
  inherited MouseMove(Shift, X, Y);
  if FDragging then
  begin
    LContext := BuildRenderContext;
    LPosition := GetPointerPosition(X, Y) - FDragOffset;
    Value := TThemedScrollBarRenderer.ValueFromThumbPosition(LContext, LPosition);
  end;
  UpdateHover(X, Y);
end;

procedure TCustomThemedScrollBar.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if Button <> mbLeft then Exit;
  FDragging := False;
  FPressedPart := nsbpNone;
  UpdateHover(X, Y);
  if MouseCapture then MouseCapture := False;
  Invalidate;
end;

procedure TCustomThemedScrollBar.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if FDragging then Exit;
  if (FHoverPart <> nsbpNone) or (FPressedPart <> nsbpNone) then
  begin
    FHoverPart := nsbpNone;
    FPressedPart := nsbpNone;
    Invalidate;
  end;
end;

procedure TCustomThemedScrollBar.WMCaptureChanged(var Message: TMessage);
begin
  if FDragging or (FPressedPart <> nsbpNone) then
  begin
    FDragging := False;
    FPressedPart := nsbpNone;
    Invalidate;
  end;
end;

procedure TCustomThemedScrollBar.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  if not Enabled then
  begin
    FDragging := False;
    FHoverPart := nsbpNone;
    FPressedPart := nsbpNone;
    if MouseCapture then MouseCapture := False;
  end;
  Invalidate;
end;

function TCustomThemedScrollBar.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
begin
  Result := inherited DoMouseWheel(Shift, WheelDelta, MousePos);
  if Result or not Enabled or (WheelDelta = 0) then Exit;
  if WheelDelta > 0 then ScrollSmallBackward else ScrollSmallForward;
  Result := True;
end;

procedure TCustomThemedScrollBar.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if not Enabled then Exit;
  case Key of
    VK_LEFT, VK_UP:
      begin
        ScrollSmallBackward;
        Key := 0;
      end;
    VK_RIGHT, VK_DOWN:
      begin
        ScrollSmallForward;
        Key := 0;
      end;
    VK_PRIOR:
      begin
        ScrollLargeBackward;
        Key := 0;
      end;
    VK_NEXT:
      begin
        ScrollLargeForward;
        Key := 0;
      end;
    VK_HOME:
      begin
        Value := FMinimum;
        Key := 0;
      end;
    VK_END:
      begin
        Value := GetEffectiveMaximum;
        Key := 0;
      end;
  end;
end;

procedure TCustomThemedScrollBar.RenderOverlay(const ACanvas: INimbusRenderCanvas; const AContext: TNimbusScrollBarRenderContext);
begin
end;

procedure TCustomThemedScrollBar.Paint;
var
  LContext: TNimbusScrollBarRenderContext;
begin
  RenderCanvas.BeginRender(Canvas);
  try
    LContext := BuildRenderContext;
    TThemedScrollBarRenderer.Render(RenderCanvas, LContext);
    RenderOverlay(RenderCanvas, LContext);
  finally
    RenderCanvas.EndRender;
  end;
end;

end.

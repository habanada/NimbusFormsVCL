{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.RangeTrackBar;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.Types,
  Vcl.Controls,
  NimbusForms.Controls.Base, NimbusForms.Controls.Types,
  NimbusForms.Rendering.RangeTrackBar;

type
  TRangeDragTarget = (rdtNone, rdtStartThumb, rdtEndThumb);

  TCustomThemedRangeTrackBar = class(TCustomNimbusControl)
  private
    FMinimum: Integer;
    FMaximum: Integer;
    FStartValue: Integer;
    FEndValue: Integer;
    FShowValueLabels: Boolean;
    FStartLabelPrefix: string;
    FEndLabelPrefix: string;
    FStartDisplayText: string;
    FEndDisplayText: string;
    FDragTarget: TRangeDragTarget;
    FHoverStart: Boolean;
    FHoverEnd: Boolean;
    FLogicalThumbSize: Integer;
    FLogicalTrackThickness: Integer;
    FLogicalSidePadding: Integer;
    FLogicalTopPadding: Integer;
    FLogicalLabelSpacing: Integer;
    FLogicalLabelHorizontalPadding: Integer;
    FOnRangeChanged: TNotifyEvent;
    FOnStartValueChanged: TNotifyEvent;
    FOnEndValueChanged: TNotifyEvent;
    procedure SetMinimum(const AValue: Integer);
    procedure SetMaximum(const AValue: Integer);
    procedure SetStartValue(const AValue: Integer);
    procedure SetEndValue(const AValue: Integer);
    procedure SetShowValueLabels(const AValue: Boolean);
    procedure SetStartLabelPrefix(const AValue: string);
    procedure SetEndLabelPrefix(const AValue: string);
    procedure UpdateDisplayTexts;
    function BuildRenderContext: TThemedRangeTrackBarRenderContext;
    function GetStartThumbRect: TRect;
    function GetEndThumbRect: TRect;
    function GetNearestThumb(const AX: Integer): TRangeDragTarget;
    function PositionToValue(const AX: Integer): Integer;
    procedure UpdateValueFromMouse(const AX: Integer; const ATarget: TRangeDragTarget);
    procedure UpdateHoverState(const APoint: TPoint);
    procedure WMCaptureChanged(var Message: TMessage); message WM_CAPTURECHANGED;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  protected
    procedure StyleModeChanged; override;
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure DoRangeChanged; virtual;
    procedure DoStartValueChanged; virtual;
    procedure DoEndValueChanged; virtual;
    property Minimum: Integer read FMinimum write SetMinimum default 0;
    property Maximum: Integer read FMaximum write SetMaximum default 100;
    property StartValue: Integer read FStartValue write SetStartValue default 25;
    property EndValue: Integer read FEndValue write SetEndValue default 75;
    property ShowValueLabels: Boolean read FShowValueLabels write SetShowValueLabels default True;
    property StartLabelPrefix: string read FStartLabelPrefix write SetStartLabelPrefix;
    property EndLabelPrefix: string read FEndLabelPrefix write SetEndLabelPrefix;
    property OnRangeChanged: TNotifyEvent read FOnRangeChanged write FOnRangeChanged;
    property OnStartValueChanged: TNotifyEvent read FOnStartValueChanged write FOnStartValueChanged;
    property OnEndValueChanged: TNotifyEvent read FOnEndValueChanged write FOnEndValueChanged;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TThemedRangeTrackBar = class(TCustomThemedRangeTrackBar)
  published
    property StyleMode;
    property Align;
    property Anchors;
    property BiDiMode;
    property Constraints;
    property Enabled;
    property EndLabelPrefix;
    property EndValue;
    property Font;
    property Maximum;
    property Minimum;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property ShowValueLabels;
    property StartLabelPrefix;
    property StartValue;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property OnContextPopup;
    property OnEndValueChanged;
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
    property OnRangeChanged;
    property OnStartValueChanged;
  end;

implementation

uses
  System.SysUtils,
  System.Math,
  NimbusForms.Controls.Strings;

constructor TCustomThemedRangeTrackBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csCaptureMouse];
  Width := 220;
  Height := 56;
  TabStop := True;
  FMinimum := 0;
  FMaximum := 100;
  FStartValue := 25;
  FEndValue := 75;
  FShowValueLabels := True;
  FStartLabelPrefix := SRangeStartPrefix;
  FEndLabelPrefix := SRangeEndPrefix;
  FLogicalThumbSize := 16;
  FLogicalTrackThickness := 4;
  FLogicalSidePadding := 8;
  FLogicalTopPadding := 8;
  FLogicalLabelSpacing := 8;
  FLogicalLabelHorizontalPadding := 2;
  UpdateDisplayTexts;
end;

procedure TCustomThemedRangeTrackBar.StyleModeChanged;
begin
  inherited StyleModeChanged;
  UpdateStyleHeight(56, 44);
end;

procedure TCustomThemedRangeTrackBar.SetMinimum(const AValue: Integer);
var
  LStartChanged, LEndChanged: Boolean;
begin
  if FMinimum = AValue then
    Exit;
  FMinimum := AValue;
  if FMaximum < FMinimum then FMaximum := FMinimum;
  LStartChanged := False;
  LEndChanged := False;
  if FStartValue < FMinimum then
  begin
    FStartValue := FMinimum;
    LStartChanged := True;
  end;
  if FEndValue < FStartValue then
  begin
    FEndValue := FStartValue;
    LEndChanged := True;
  end;
  UpdateDisplayTexts;
  if LStartChanged then DoStartValueChanged;
  if LEndChanged then DoEndValueChanged;
  if LStartChanged or LEndChanged then DoRangeChanged;
  Invalidate;
end;

procedure TCustomThemedRangeTrackBar.SetMaximum(const AValue: Integer);
var
  LValue: Integer;
  LStartChanged, LEndChanged: Boolean;
begin
  LValue := AValue;
  if LValue < FMinimum then LValue := FMinimum;
  if FMaximum = LValue then
    Exit;
  FMaximum := LValue;
  LStartChanged := False;
  LEndChanged := False;
  if FEndValue > FMaximum then
  begin
    FEndValue := FMaximum;
    LEndChanged := True;
  end;
  if FStartValue > FEndValue then
  begin
    FStartValue := FEndValue;
    LStartChanged := True;
  end;
  UpdateDisplayTexts;
  if LStartChanged then DoStartValueChanged;
  if LEndChanged then DoEndValueChanged;
  if LStartChanged or LEndChanged then DoRangeChanged;
  Invalidate;
end;

procedure TCustomThemedRangeTrackBar.SetStartValue(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < FMinimum then LValue := FMinimum;
  if LValue > FEndValue then LValue := FEndValue;
  if FStartValue = LValue then
    Exit;
  FStartValue := LValue;
  UpdateDisplayTexts;
  DoStartValueChanged;
  DoRangeChanged;
  Invalidate;
end;

procedure TCustomThemedRangeTrackBar.SetEndValue(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue > FMaximum then LValue := FMaximum;
  if LValue < FStartValue then LValue := FStartValue;
  if FEndValue = LValue then
    Exit;
  FEndValue := LValue;
  UpdateDisplayTexts;
  DoEndValueChanged;
  DoRangeChanged;
  Invalidate;
end;

procedure TCustomThemedRangeTrackBar.SetShowValueLabels(const AValue: Boolean);
begin
  if FShowValueLabels = AValue then
    Exit;
  FShowValueLabels := AValue;
  Invalidate;
end;

procedure TCustomThemedRangeTrackBar.SetStartLabelPrefix(const AValue: string);
begin
  if FStartLabelPrefix = AValue then
    Exit;
  FStartLabelPrefix := AValue;
  UpdateDisplayTexts;
  Invalidate;
end;

procedure TCustomThemedRangeTrackBar.SetEndLabelPrefix(const AValue: string);
begin
  if FEndLabelPrefix = AValue then
    Exit;
  FEndLabelPrefix := AValue;
  UpdateDisplayTexts;
  Invalidate;
end;

procedure TCustomThemedRangeTrackBar.UpdateDisplayTexts;
begin
  FStartDisplayText := FStartLabelPrefix + IntToStr(FStartValue);
  FEndDisplayText := FEndLabelPrefix + IntToStr(FEndValue);
end;

procedure TCustomThemedRangeTrackBar.DoRangeChanged;
begin
  if Assigned(FOnRangeChanged) then FOnRangeChanged(Self);
end;

procedure TCustomThemedRangeTrackBar.DoStartValueChanged;
begin
  if Assigned(FOnStartValueChanged) then FOnStartValueChanged(Self);
end;

procedure TCustomThemedRangeTrackBar.DoEndValueChanged;
begin
  if Assigned(FOnEndValueChanged) then FOnEndValueChanged(Self);
end;

function TCustomThemedRangeTrackBar.BuildRenderContext: TThemedRangeTrackBarRenderContext;
begin
  Result.Bounds := ClientRect;
  Result.Font := Font;
  Result.Palette := Palette;
  Result.Minimum := FMinimum;
  Result.Maximum := FMaximum;
  Result.StartValue := FStartValue;
  Result.EndValue := FEndValue;
  Result.ThumbSize := ScaleValue(FLogicalThumbSize - Ord(StyleMode = stCompact) * 4);
  Result.TrackThickness := ScaleValue(FLogicalTrackThickness - Ord(StyleMode = stCompact) * 1);
  Result.SidePadding := ScaleValue(FLogicalSidePadding - Ord(StyleMode = stCompact) * 2);
  Result.TopPadding := ScaleValue(FLogicalTopPadding - Ord(StyleMode = stCompact) * 2);
  Result.LabelSpacing := ScaleValue(FLogicalLabelSpacing - Ord(StyleMode = stCompact) * 3);
  Result.LabelHorizontalPadding := ScaleValue(FLogicalLabelHorizontalPadding);
  Result.StartText := FStartDisplayText;
  Result.EndText := FEndDisplayText;
  Result.ShowValueLabels := FShowValueLabels;
  Result.Enabled := Enabled;
  Result.Focused := Focused;
  Result.HoverStart := FHoverStart;
  Result.HoverEnd := FHoverEnd;
  Result.DragStart := FDragTarget = rdtStartThumb;
  Result.DragEnd := FDragTarget = rdtEndThumb;
  Result.RightToLeft := UseRightToLeftReading;
end;

function TCustomThemedRangeTrackBar.GetStartThumbRect: TRect;
begin
  Result := TThemedRangeTrackBarRenderer.CalculateThumbRect(BuildRenderContext, FStartValue);
end;

function TCustomThemedRangeTrackBar.GetEndThumbRect: TRect;
begin
  Result := TThemedRangeTrackBarRenderer.CalculateThumbRect(BuildRenderContext, FEndValue);
end;

function TCustomThemedRangeTrackBar.GetNearestThumb(const AX: Integer): TRangeDragTarget;
var
  LStart, LEnd: TRect;
  LStartCenter, LEndCenter: Integer;
begin
  LStart := GetStartThumbRect;
  LEnd := GetEndThumbRect;
  LStartCenter := LStart.Left + LStart.Width div 2;
  LEndCenter := LEnd.Left + LEnd.Width div 2;
  if Abs(AX - LStartCenter) <= Abs(AX - LEndCenter) then Result := rdtStartThumb else Result := rdtEndThumb;
end;

function TCustomThemedRangeTrackBar.PositionToValue(const AX: Integer): Integer;
var
  LContext: TThemedRangeTrackBarRenderContext;
  LTrack: TRect;
  LX, LRange: Integer;
  LRatio: Double;
begin
  LContext := BuildRenderContext;
  LTrack := TThemedRangeTrackBarRenderer.CalculateTrackRect(LContext);
  LX := AX;
  if LX < LTrack.Left then LX := LTrack.Left;
  if LX > LTrack.Right then LX := LTrack.Right;
  if LTrack.Width > 0 then LRatio := (LX - LTrack.Left) / LTrack.Width else LRatio := 0;
  LRange := FMaximum - FMinimum;
  Result := FMinimum + Round(LRange * LRatio);
end;

procedure TCustomThemedRangeTrackBar.UpdateValueFromMouse(const AX: Integer; const ATarget: TRangeDragTarget);
var
  LValue: Integer;
begin
  LValue := PositionToValue(AX);
  if ATarget = rdtStartThumb then StartValue := LValue
  else if ATarget = rdtEndThumb then EndValue := LValue;
end;

procedure TCustomThemedRangeTrackBar.UpdateHoverState(const APoint: TPoint);
var
  LStart, LEnd: Boolean;
begin
  LStart := PtInRect(GetStartThumbRect, APoint);
  LEnd := PtInRect(GetEndThumbRect, APoint);
  if (FHoverStart = LStart) and (FHoverEnd = LEnd) then
    Exit;
  FHoverStart := LStart;
  FHoverEnd := LEnd;
  Invalidate;
end;

procedure TCustomThemedRangeTrackBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LPoint: TPoint;
  LStart, LEnd: TRect;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button <> mbLeft) or not Enabled then
    Exit;
  LPoint := Point(X, Y);
  LStart := GetStartThumbRect;
  LEnd := GetEndThumbRect;
  if PtInRect(LStart, LPoint) and PtInRect(LEnd, LPoint) then FDragTarget := GetNearestThumb(X)
  else if PtInRect(LStart, LPoint) then FDragTarget := rdtStartThumb
  else if PtInRect(LEnd, LPoint) then FDragTarget := rdtEndThumb
  else
  begin
    FDragTarget := GetNearestThumb(X);
    UpdateValueFromMouse(X, FDragTarget);
  end;
  MouseCapture := True;
  if CanFocus then SetFocus;
  UpdateHoverState(LPoint);
  Invalidate;
end;

procedure TCustomThemedRangeTrackBar.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  if FDragTarget <> rdtNone then UpdateValueFromMouse(X, FDragTarget);
  UpdateHoverState(Point(X, Y));
end;

procedure TCustomThemedRangeTrackBar.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if (Button = mbLeft) and (FDragTarget <> rdtNone) then
  begin
    FDragTarget := rdtNone;
    MouseCapture := False;
    UpdateHoverState(Point(X, Y));
    Invalidate;
  end;
end;

procedure TCustomThemedRangeTrackBar.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if FDragTarget = rdtNone then
  begin
    FHoverStart := False;
    FHoverEnd := False;
    Invalidate;
  end;
end;

procedure TCustomThemedRangeTrackBar.WMCaptureChanged(var Message: TMessage);
begin
  inherited;
  if FDragTarget <> rdtNone then
  begin
    FDragTarget := rdtNone;
    Invalidate;
  end;
end;

procedure TCustomThemedRangeTrackBar.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if not Enabled then
    Exit;
  case Key of
    VK_LEFT:
      begin
        if ssShift in Shift then EndValue := FEndValue - 1 else StartValue := FStartValue - 1;
        Key := 0;
      end;
    VK_RIGHT:
      begin
        if ssShift in Shift then EndValue := FEndValue + 1 else StartValue := FStartValue + 1;
        Key := 0;
      end;
    VK_HOME:
      begin
        StartValue := FMinimum;
        Key := 0;
      end;
    VK_END:
      begin
        EndValue := FMaximum;
        Key := 0;
      end;
  end;
end;

procedure TCustomThemedRangeTrackBar.DoEnter;
begin
  inherited DoEnter;
  Invalidate;
end;

procedure TCustomThemedRangeTrackBar.DoExit;
begin
  FDragTarget := rdtNone;
  MouseCapture := False;
  inherited DoExit;
  Invalidate;
end;

procedure TCustomThemedRangeTrackBar.Paint;
var
  LContext: TThemedRangeTrackBarRenderContext;
begin
  RenderCanvas.BeginRender(Canvas);
  try
    LContext := BuildRenderContext;
    TThemedRangeTrackBarRenderer.Render(RenderCanvas, LContext);
  finally
    RenderCanvas.EndRender;
  end;
end;

end.

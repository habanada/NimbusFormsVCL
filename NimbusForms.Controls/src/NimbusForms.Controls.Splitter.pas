{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.Splitter;

interface

uses Winapi.Windows, Winapi.Messages, System.Classes, System.Types, System.UITypes, Vcl.Controls,
  NimbusForms.Controls.Base;

type
  TThemedSplitterCanResizeEvent = procedure(Sender: TObject; var NewSize: Integer; var Accept: Boolean) of object;
  TCustomThemedSplitter = class(TCustomNimbusControl)
  private
    FResizeControl, FDragTarget: TControl;
    FDragOrigin: TPoint;
    FDragAlign, FLayoutAlign: TAlign;
    FStartSize, FMinSize, FMinRemainingSize, FThickness, FKeyboardStep: Integer;
    FResizing, FHovered, FShowGrip, FShowLine: Boolean;
    FOnCanResize: TThemedSplitterCanResizeEvent;
    FOnMoved: TNotifyEvent;
    procedure SetResizeControl(const Value: TControl);
    procedure SetMinSize(const Value: Integer);
    procedure SetMinRemainingSize(const Value: Integer);
    procedure SetThickness(const Value: Integer);
    procedure SetKeyboardStep(const Value: Integer);
    procedure SetShowGrip(const Value: Boolean);
    procedure SetShowLine(const Value: Boolean);
    procedure UpdateThickness;
    function FindResizeControl: TControl;
    function GetSizeLimits(Target: TControl; out Minimum, Maximum: Integer): Boolean;
    function ValidDragTarget: Boolean;
    function BeginResize(const ScreenPoint: TPoint): Boolean;
    procedure ResizeTarget(const NewSize: Integer);
    procedure FinishResize(const Cancel: Boolean);
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMCaptureChanged(var Message: TMessage); message WM_CAPTURECHANGED;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
  protected
    procedure RequestAlign; override;
    procedure Paint; override;
    procedure SetParent(AParent: TWinControl); override;
    procedure DestroyWnd; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Resizing: Boolean read FResizing;
    property ResizeControl: TControl read FResizeControl write SetResizeControl;
    property MinSize: Integer read FMinSize write SetMinSize default 30;
    property MinRemainingSize: Integer read FMinRemainingSize write SetMinRemainingSize default 30;
    property Thickness: Integer read FThickness write SetThickness default 7;
    property KeyboardStep: Integer read FKeyboardStep write SetKeyboardStep default 8;
    property ShowGrip: Boolean read FShowGrip write SetShowGrip default True;
    property ShowLine: Boolean read FShowLine write SetShowLine default True;
    property OnCanResize: TThemedSplitterCanResizeEvent read FOnCanResize write FOnCanResize;
    property OnMoved: TNotifyEvent read FOnMoved write FOnMoved;
  end;
  TThemedSplitter = class(TCustomThemedSplitter)
  published
    property Align default alLeft;
    property AlignWithMargins;
    property Anchors;
    property Margins;
    property Constraints;
    property Enabled;
    property Visible;
    property TabStop default True;
    property TabOrder;
    property Hint;
    property ShowHint;
    property ParentShowHint;
    property PopupMenu;
    property ResizeControl;
    property MinSize;
    property MinRemainingSize;
    property Thickness;
    property KeyboardStep;
    property ShowGrip;
    property ShowLine;
    property OnCanResize;
    property OnMoved;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnKeyDown;
    property OnEnter;
    property OnExit;
    property OnClick;
    property OnDblClick;
  end;

implementation

uses System.Math, NimbusForms.Rendering.Splitter;

type TSplitterParentAccess = class(TWinControl);

constructor TCustomThemedSplitter.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := ControlStyle - [csCaptureMouse];
  FMinSize := 30; FMinRemainingSize := 30; FThickness := 7; FKeyboardStep := 8;
  FShowGrip := True; FShowLine := True; TabStop := True;
  SetBounds(0, 0, 7, 100); Align := alLeft;
end;

destructor TCustomThemedSplitter.Destroy;
begin FinishResize(False); inherited; end;

procedure TCustomThemedSplitter.Paint;
var Context: TThemedSplitterRenderContext;
begin
  Context := Default(TThemedSplitterRenderContext); Context.Bounds := ClientRect;
  Context.Palette := Palette; Context.PPI := CurrentPPI; Context.Vertical := Align in [alLeft, alRight];
  Context.Enabled := Enabled; Context.Hovered := FHovered; Context.Pressed := FResizing; Context.Focused := Focused;
  Context.ShowGrip := FShowGrip; Context.ShowLine := FShowLine;
  RenderCanvas.BeginRender(Canvas);
  try TThemedSplitterRenderer.Render(RenderCanvas, Context); finally RenderCanvas.EndRender; end;
end;

procedure TCustomThemedSplitter.SetParent(AParent: TWinControl);
begin if AParent <> Parent then FinishResize(True); inherited; end;

procedure TCustomThemedSplitter.DestroyWnd;
begin FinishResize(True); inherited; end;

procedure TCustomThemedSplitter.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if Operation <> opRemove then Exit;
  if AComponent = FResizeControl then FResizeControl := nil;
  if AComponent = FDragTarget then begin FDragTarget := nil; FinishResize(False); end;
end;

procedure TCustomThemedSplitter.SetResizeControl(const Value: TControl);
begin
  if (Value = Self) or (FResizeControl = Value) then Exit;
  FinishResize(True);
  if FResizeControl <> nil then FResizeControl.RemoveFreeNotification(Self);
  FResizeControl := Value;
  if FResizeControl <> nil then FResizeControl.FreeNotification(Self);
end;

procedure TCustomThemedSplitter.SetMinSize(const Value: Integer);
begin if FMinSize = Max(0, Value) then Exit; FinishResize(True); FMinSize := Max(0, Value); end;
procedure TCustomThemedSplitter.SetMinRemainingSize(const Value: Integer);
begin if FMinRemainingSize = Max(0, Value) then Exit; FinishResize(True); FMinRemainingSize := Max(0, Value); end;
procedure TCustomThemedSplitter.SetThickness(const Value: Integer);
begin if FThickness = Max(3, Value) then Exit; FinishResize(True); FThickness := Max(3, Value); UpdateThickness; end;
procedure TCustomThemedSplitter.SetKeyboardStep(const Value: Integer);
begin FKeyboardStep := Max(1, Value); end;
procedure TCustomThemedSplitter.SetShowGrip(const Value: Boolean);
begin if FShowGrip = Value then Exit; FShowGrip := Value; Invalidate; end;
procedure TCustomThemedSplitter.SetShowLine(const Value: Boolean);
begin if FShowLine = Value then Exit; FShowLine := Value; Invalidate; end;

procedure TCustomThemedSplitter.UpdateThickness;
begin
  if Align in [alLeft, alRight] then begin Cursor := crHSplit; Width := ScaleValue(FThickness); end
  else if Align in [alTop, alBottom] then begin Cursor := crVSplit; Height := ScaleValue(FThickness); end
  else Cursor := crDefault;
end;

procedure TCustomThemedSplitter.RequestAlign;
begin
  if Align <> FLayoutAlign then
  begin
    FLayoutAlign := Align; FinishResize(True);
    if FThickness > 0 then UpdateThickness;
    Invalidate;
  end;
  inherited;
end;
procedure TCustomThemedSplitter.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin FinishResize(True); inherited; UpdateThickness; end;
procedure TCustomThemedSplitter.CMEnabledChanged(var Message: TMessage);
begin inherited; if not Enabled then FinishResize(True); end;
procedure TCustomThemedSplitter.CMMouseEnter(var Message: TMessage);
begin inherited; FHovered := True; Invalidate; end;
procedure TCustomThemedSplitter.CMMouseLeave(var Message: TMessage);
begin inherited; FHovered := False; Invalidate; end;
procedure TCustomThemedSplitter.WMCaptureChanged(var Message: TMessage);
begin inherited; if FResizing then FinishResize(True); end;
procedure TCustomThemedSplitter.WMKillFocus(var Message: TWMKillFocus);
begin inherited; FinishResize(True); Invalidate; end;
procedure TCustomThemedSplitter.WMSetFocus(var Message: TWMSetFocus);
begin inherited; Invalidate; end;
procedure TCustomThemedSplitter.WMGetDlgCode(var Message: TWMGetDlgCode);
begin inherited; Message.Result := Message.Result or DLGC_WANTARROWS; if FResizing then Message.Result := Message.Result or DLGC_WANTALLKEYS; end;

function TCustomThemedSplitter.FindResizeControl: TControl;
var I, Distance, Best: Integer; Candidate: TControl; Overlaps: Boolean;
begin
  Result := nil; if (Parent = nil) or not (Align in [alLeft, alRight, alTop, alBottom]) then Exit;
  if FResizeControl <> nil then
  begin
    if (FResizeControl.Parent = Parent) and FResizeControl.Visible and (FResizeControl.Align = Align) and
      not (csDestroying in FResizeControl.ComponentState) then Result := FResizeControl;
    Exit;
  end;
  Best := MaxInt;
  for I := 0 to Parent.ControlCount - 1 do
  begin
    Candidate := Parent.Controls[I];
    if (Candidate = Self) or not Candidate.Visible or (Candidate.Align <> Align) or (Candidate is TCustomThemedSplitter) or
      (csDestroying in Candidate.ComponentState) then Continue;
    if Align in [alLeft, alRight] then Overlaps := (Candidate.Top < Top + Height) and (Candidate.Top + Candidate.Height > Top)
    else Overlaps := (Candidate.Left < Left + Width) and (Candidate.Left + Candidate.Width > Left);
    if not Overlaps then Continue;
    case Align of
      alLeft: Distance := Left - Candidate.Left - Candidate.Width;
      alRight: Distance := Candidate.Left - Left - Width;
      alTop: Distance := Top - Candidate.Top - Candidate.Height;
    else Distance := Candidate.Top - Top - Height;
    end;
    if (Distance >= 0) and (Distance < Best) then begin Best := Distance; Result := Candidate; end;
  end;
end;

function TCustomThemedSplitter.GetSizeLimits(Target: TControl; out Minimum, Maximum: Integer): Boolean;
var I, FixedSize, Remaining, ClientMinimum, ConstraintMaximum: Integer; Candidate: TControl; Bounds: TRect;
begin
  Result := False; Minimum := 0; Maximum := 0;
  if (Target = nil) or (Parent = nil) or (Target.Parent <> Parent) or (Target.Align <> Align) or
    not (Align in [alLeft, alRight, alTop, alBottom]) or (csDestroying in Target.ComponentState) or
    (csDestroying in Parent.ComponentState) then Exit;
  Bounds := Parent.ClientRect; TSplitterParentAccess(Parent).AdjustClientRect(Bounds); Remaining := ScaleValue(FMinRemainingSize);
  if Align in [alLeft, alRight] then
  begin
    FixedSize := Width; Minimum := Max(ScaleValue(FMinSize), Target.Constraints.MinWidth); ConstraintMaximum := Target.Constraints.MaxWidth;
    if AlignWithMargins then Inc(FixedSize, Margins.Left + Margins.Right);
    if Target.AlignWithMargins then Inc(FixedSize, Target.Margins.Left + Target.Margins.Right);
  end
  else
  begin
    FixedSize := Height; Minimum := Max(ScaleValue(FMinSize), Target.Constraints.MinHeight); ConstraintMaximum := Target.Constraints.MaxHeight;
    if AlignWithMargins then Inc(FixedSize, Margins.Top + Margins.Bottom);
    if Target.AlignWithMargins then Inc(FixedSize, Target.Margins.Top + Target.Margins.Bottom);
  end;
  for I := 0 to Parent.ControlCount - 1 do
  begin
    Candidate := Parent.Controls[I]; if (Candidate = Self) or (Candidate = Target) or not Candidate.Visible then Continue;
    if Candidate.Align = alClient then
    begin
      if Align in [alLeft, alRight] then
      begin
        ClientMinimum := Candidate.Constraints.MinWidth;
        if Candidate.AlignWithMargins then Inc(ClientMinimum, Candidate.Margins.Left + Candidate.Margins.Right);
      end
      else
      begin
        ClientMinimum := Candidate.Constraints.MinHeight;
        if Candidate.AlignWithMargins then Inc(ClientMinimum, Candidate.Margins.Top + Candidate.Margins.Bottom);
      end;
      Remaining := Max(Remaining, ClientMinimum);
    end;
    if (Align in [alLeft, alRight]) and (Candidate.Align in [alLeft, alRight]) then
    begin
      Inc(FixedSize, Candidate.Width);
      if Candidate.AlignWithMargins then Inc(FixedSize, Candidate.Margins.Left + Candidate.Margins.Right);
    end
    else if (Align in [alTop, alBottom]) and (Candidate.Align in [alTop, alBottom]) then
    begin
      Inc(FixedSize, Candidate.Height);
      if Candidate.AlignWithMargins then Inc(FixedSize, Candidate.Margins.Top + Candidate.Margins.Bottom);
    end;
  end;
  if Align in [alLeft, alRight] then Maximum := Bounds.Width - FixedSize - Remaining
  else Maximum := Bounds.Height - FixedSize - Remaining;
  if ConstraintMaximum > 0 then Maximum := Min(Maximum, ConstraintMaximum);
  Result := Maximum >= Minimum;
end;

function TCustomThemedSplitter.ValidDragTarget: Boolean;
begin
  Result := (FDragTarget <> nil) and (Parent <> nil) and (Align = FDragAlign) and (FDragTarget.Parent = Parent) and
    (FDragTarget.Align = FDragAlign) and not (csDestroying in ComponentState) and
    not (csDestroying in FDragTarget.ComponentState) and not (csDestroying in Parent.ComponentState);
end;

function TCustomThemedSplitter.BeginResize(const ScreenPoint: TPoint): Boolean;
var Target: TControl; Minimum, Maximum: Integer;
begin
  Result := False; if not Enabled or FResizing or (csDesigning in ComponentState) then Exit;
  Target := FindResizeControl; if not GetSizeLimits(Target, Minimum, Maximum) then Exit;
  FDragTarget := Target; FDragTarget.FreeNotification(Self); FDragOrigin := ScreenPoint; FDragAlign := Align;
  if Align in [alLeft, alRight] then FStartSize := Target.Width else FStartSize := Target.Height;
  FResizing := True; Invalidate; Result := True;
end;

procedure TCustomThemedSplitter.ResizeTarget(const NewSize: Integer);
var Minimum, Maximum, Size: Integer; Accept: Boolean;
begin
  if not FResizing then Exit;
  if not ValidDragTarget or not GetSizeLimits(FDragTarget, Minimum, Maximum) then begin FinishResize(True); Exit; end;
  Size := EnsureRange(NewSize, Minimum, Maximum); Accept := True;
  if Assigned(FOnCanResize) then FOnCanResize(Self, Size, Accept);
  if not Accept or not FResizing or not ValidDragTarget then Exit;
  if not GetSizeLimits(FDragTarget, Minimum, Maximum) then Exit;
  Size := EnsureRange(Size, Minimum, Maximum);
  if Align in [alLeft, alRight] then FDragTarget.Width := Size else FDragTarget.Height := Size;
end;

procedure TCustomThemedSplitter.FinishResize(const Cancel: Boolean);
var Changed: Boolean; Target: TControl;
begin
  if not FResizing then Exit; FResizing := False; Changed := False;
  try
    if ValidDragTarget then
      if FDragAlign in [alLeft, alRight] then
      begin Changed := FDragTarget.Width <> FStartSize; if Cancel then FDragTarget.Width := FStartSize; end
      else
      begin Changed := FDragTarget.Height <> FStartSize; if Cancel then FDragTarget.Height := FStartSize; end;
  finally
    Target := FDragTarget; FDragTarget := nil;
    if (Target <> nil) and (Target <> FResizeControl) then Target.RemoveFreeNotification(Self);
    MouseCapture := False; Invalidate;
  end;
  if Changed and not Cancel and not (csDestroying in ComponentState) and Assigned(FOnMoved) then FOnMoved(Self);
end;

procedure TCustomThemedSplitter.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited; if (Button <> mbLeft) or not Enabled or (Parent = nil) or not HandleAllocated then Exit;
  if CanFocus then SetFocus;
  if BeginResize(ClientToScreen(Point(X, Y))) then MouseCapture := True;
end;
procedure TCustomThemedSplitter.MouseMove(Shift: TShiftState; X, Y: Integer);
var Position: TPoint; Delta: Integer;
begin
  inherited; if not FResizing then Exit;
  Position := ClientToScreen(Point(X, Y));
  if FDragAlign in [alLeft, alRight] then Delta := Position.X - FDragOrigin.X else Delta := Position.Y - FDragOrigin.Y;
  if FDragAlign in [alRight, alBottom] then Delta := -Delta;
  try ResizeTarget(FStartSize + Delta);
  except FinishResize(True); raise; end;
end;
procedure TCustomThemedSplitter.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin inherited; if Button = mbLeft then FinishResize(False); end;
procedure TCustomThemedSplitter.KeyDown(var Key: Word; Shift: TShiftState);
var Delta, Size: Integer;
begin
  inherited; if (Key = 0) or not Enabled then Exit;
  if (Key = VK_ESCAPE) and FResizing then begin FinishResize(True); Key := 0; Exit; end;
  if FResizing then Exit;
  Delta := 0;
  if Align in [alLeft, alRight] then
    case Key of VK_LEFT: Delta := -1; VK_RIGHT: Delta := 1; end
  else if Align in [alTop, alBottom] then
    case Key of VK_UP: Delta := -1; VK_DOWN: Delta := 1; end;
  if (Delta = 0) or not BeginResize(Point(0, 0)) then Exit;
  if ssShift in Shift then Delta := Delta * Max(1, ScaleValue(1)) else Delta := Delta * ScaleValue(FKeyboardStep);
  if Align in [alRight, alBottom] then Delta := -Delta;
  if Align in [alLeft, alRight] then Size := FDragTarget.Width else Size := FDragTarget.Height;
  try ResizeTarget(Size + Delta); FinishResize(False);
  except FinishResize(True); raise; end;
  Key := 0;
end;

end.

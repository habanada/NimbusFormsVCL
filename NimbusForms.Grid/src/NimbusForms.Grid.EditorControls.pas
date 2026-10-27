unit NimbusForms.Grid.EditorControls;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  Winapi.CommCtrl,
  System.Types,
  System.Classes,
  System.SysUtils,
  System.Math,
  System.UITypes,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.Dialogs,
  NimbusForms.Theming.Types,
  NimbusForms.Theming.Palette;

const
  WM_OPENCOLORDIALOG = WM_USER + 301;
  CKeyUpFlags = $C000;

type
  TThemedGridEditorArrowEvent = procedure(ASender: TObject; const ADirection: Integer) of object;
  TThemedGridEditorCharEvent = procedure(ASender: TObject; var AKey: Char) of object;

  TThemedGridEditorEdit = class(TEdit)
  private
    FAlignment: TAlignment;
    FOnArrow: TThemedGridEditorArrowEvent;
    FOnFilterChar: TThemedGridEditorCharEvent;
    procedure SetAlignment(const AValue: TAlignment);
    procedure CMWantSpecialKey(var AMessage: TCMWantSpecialKey); message CM_WANTSPECIALKEY;
  protected
    procedure CreateParams(var AParams: TCreateParams); override;
    procedure KeyDown(var AKey: Word; AShift: TShiftState); override;
    procedure KeyPress(var AKey: Char); override;
  public
    property Alignment: TAlignment read FAlignment write SetAlignment;
    property OnArrow: TThemedGridEditorArrowEvent read FOnArrow write FOnArrow;
    property OnFilterChar: TThemedGridEditorCharEvent read FOnFilterChar write FOnFilterChar;
  end;

  TThemedGridEditorMemo = class(TMemo)
  private
    procedure CMWantSpecialKey(var AMessage: TCMWantSpecialKey); message CM_WANTSPECIALKEY;
  end;

  TThemedGridEditorComboBox = class(TComboBox)
  private
    procedure CMWantSpecialKey(var AMessage: TCMWantSpecialKey); message CM_WANTSPECIALKEY;
  public
    function IsDroppedDown: Boolean;
    procedure CloseDropDown;
  end;

  TThemedGridEditorDatePicker = class(TDateTimePicker)
  private
    procedure CMWantSpecialKey(var AMessage: TCMWantSpecialKey); message CM_WANTSPECIALKEY;
  public
    function IsDroppedDown: Boolean;
    procedure OpenDropDown;
    procedure CloseDropDown;
  end;

  TThemedGridEditorControl = class(TCustomControl)
  private
    FBackColor: TColor;
    FForeColor: TColor;
    FBorderColor: TColor;
    FAccentColor: TColor;
    FOnEditorKeyDown: TKeyEvent;
    FOnEditorExit: TNotifyEvent;
    procedure WMGetDlgCode(var AMessage: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMSetFocus(var AMessage: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var AMessage: TWMKillFocus); message WM_KILLFOCUS;
    procedure CMWantSpecialKey(var AMessage: TCMWantSpecialKey); message CM_WANTSPECIALKEY;
  protected
    procedure KeyDown(var AKey: Word; AShift: TShiftState); override;
    procedure DoExit; override;
    procedure Paint; override;
    procedure PaintContent(const ARect: TRect); virtual; abstract;
    property BackColor: TColor read FBackColor;
    property ForeColor: TColor read FForeColor;
    property BorderColor: TColor read FBorderColor;
    property AccentColor: TColor read FAccentColor;
  public
    constructor Create(AOwner: TComponent); override;
    procedure ApplyPalette(const APalette: TThemePalette); virtual;
    property OnEditorKeyDown: TKeyEvent read FOnEditorKeyDown write FOnEditorKeyDown;
    property OnEditorExit: TNotifyEvent read FOnEditorExit write FOnEditorExit;
  end;

  TThemedGridRatingControl = class(TThemedGridEditorControl)
  private
    FMaximum: Integer;
    FRating: Extended;
    procedure SetMaximum(const AValue: Integer);
    procedure SetRating(const AValue: Extended);
  protected
    procedure PaintContent(const ARect: TRect); override;
    procedure MouseDown(AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer); override;
    procedure KeyDown(var AKey: Word; AShift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
    property Maximum: Integer read FMaximum write SetMaximum;
    property Rating: Extended read FRating write SetRating;
  end;

  TThemedGridSliderControl = class(TThemedGridEditorControl)
  private
    FMinimum: Integer;
    FMaximum: Integer;
    FPosition: Integer;
    FDragging: Boolean;
    procedure SetMinimum(const AValue: Integer);
    procedure SetMaximum(const AValue: Integer);
    procedure SetPosition(const AValue: Integer);
    procedure UpdateFromPoint(const ALocation: TPoint);
  protected
    procedure PaintContent(const ARect: TRect); override;
    procedure MouseDown(AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer); override;
    procedure MouseMove(AShift: TShiftState; AX, AY: Integer); override;
    procedure MouseUp(AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer); override;
    procedure KeyDown(var AKey: Word; AShift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetRange(const AMinimum, AMaximum: Integer);
    property Minimum: Integer read FMinimum write SetMinimum;
    property Maximum: Integer read FMaximum write SetMaximum;
    property Position: Integer read FPosition write SetPosition;
  end;

  TThemedGridToggleStyle = (Switch, CheckBox);

  TThemedGridToggleControl = class(TThemedGridEditorControl)
  private
    FChecked: Boolean;
    FStyle: TThemedGridToggleStyle;
    procedure SetChecked(const AValue: Boolean);
    procedure SetStyle(const AValue: TThemedGridToggleStyle);
  protected
    procedure PaintContent(const ARect: TRect); override;
    procedure MouseDown(AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer); override;
    procedure KeyDown(var AKey: Word; AShift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
    property Checked: Boolean read FChecked write SetChecked;
    property Style: TThemedGridToggleStyle read FStyle write SetStyle;
  end;

  TThemedGridColorButton = class(TThemedGridEditorControl)
  private
    FColor: TColor;
    FHasValue: Boolean;
    FAllowClear: Boolean;
    FDialogOpen: Boolean;
    FDialogPending: Boolean;
    FOnColorChosen: TNotifyEvent;
    procedure SetColor(const AValue: TColor);
    procedure SetHasValue(const AValue: Boolean);
    procedure RunDialog;
    function GetIsDialogActive: Boolean;
    procedure WMOpenColorDialog(var AMessage: TMessage); message WM_OPENCOLORDIALOG;
  protected
    procedure PaintContent(const ARect: TRect); override;
    procedure MouseDown(AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer); override;
    procedure KeyDown(var AKey: Word; AShift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure OpenDialogDeferred;
    property Color: TColor read FColor write SetColor;
    property HasValue: Boolean read FHasValue write SetHasValue;
    property AllowClear: Boolean read FAllowClear write FAllowClear;
    property IsDialogActive: Boolean read GetIsDialogActive;
    property OnColorChosen: TNotifyEvent read FOnColorChosen write FOnColorChosen;
  end;

implementation

uses
  NimbusForms.Grid.InlineEditorGeometry;

function WantsSpecialKey(const ACharCode: Word): Boolean;
begin
  Result := (ACharCode = VK_RETURN) or (ACharCode = VK_ESCAPE);
end;

procedure TThemedGridEditorEdit.CMWantSpecialKey(var AMessage: TCMWantSpecialKey);
begin
  if WantsSpecialKey(AMessage.CharCode) then
    AMessage.Result := 1
  else
    inherited;
end;

procedure TThemedGridEditorEdit.SetAlignment(const AValue: TAlignment);
begin
  if FAlignment = AValue then
    Exit;
  FAlignment := AValue;
  if HandleAllocated then
    RecreateWnd;
end;

procedure TThemedGridEditorEdit.CreateParams(var AParams: TCreateParams);
begin
  inherited CreateParams(AParams);
  AParams.Style := AParams.Style and not (ES_LEFT or ES_CENTER or ES_RIGHT);
  case FAlignment of
    taRightJustify: AParams.Style := AParams.Style or ES_RIGHT;
    taCenter: AParams.Style := AParams.Style or ES_CENTER;
  else
    AParams.Style := AParams.Style or ES_LEFT;
  end;
end;

procedure TThemedGridEditorEdit.KeyDown(var AKey: Word; AShift: TShiftState);
begin
  inherited KeyDown(AKey, AShift);
  if Assigned(FOnArrow) and (AShift = []) then
  begin
    if AKey = VK_UP then
    begin
      FOnArrow(Self, 1);
      AKey := 0;
    end
    else if AKey = VK_DOWN then
    begin
      FOnArrow(Self, -1);
      AKey := 0;
    end;
  end;
end;

procedure TThemedGridEditorEdit.KeyPress(var AKey: Char);
begin
  if (AKey >= ' ') and Assigned(FOnFilterChar) then
    FOnFilterChar(Self, AKey);
  if AKey = #0 then
    Exit;
  inherited KeyPress(AKey);
end;

procedure TThemedGridEditorMemo.CMWantSpecialKey(var AMessage: TCMWantSpecialKey);
begin
  if WantsSpecialKey(AMessage.CharCode) then
    AMessage.Result := 1
  else
    inherited;
end;

procedure TThemedGridEditorComboBox.CMWantSpecialKey(var AMessage: TCMWantSpecialKey);
begin
  if WantsSpecialKey(AMessage.CharCode) then
    AMessage.Result := 1
  else
    inherited;
end;

function TThemedGridEditorComboBox.IsDroppedDown: Boolean;
begin
  Result := HandleAllocated and (SendMessage(Handle, CB_GETDROPPEDSTATE, 0, 0) <> 0);
end;

procedure TThemedGridEditorComboBox.CloseDropDown;
begin
  if IsDroppedDown then
    SendMessage(Handle, CB_SHOWDROPDOWN, 0, 0);
end;

procedure TThemedGridEditorDatePicker.CMWantSpecialKey(var AMessage: TCMWantSpecialKey);
begin
  if WantsSpecialKey(AMessage.CharCode) then
    AMessage.Result := 1
  else
    inherited;
end;

function TThemedGridEditorDatePicker.IsDroppedDown: Boolean;
var
  LCalendar: HWND;
begin
  Result := False;
  if not HandleAllocated then
    Exit;
  LCalendar := HWND(SendMessage(Handle, DTM_GETMONTHCAL, 0, 0));
  Result := (LCalendar <> 0) and IsWindowVisible(LCalendar);
end;

procedure TThemedGridEditorDatePicker.OpenDropDown;
begin
  if HandleAllocated and not IsDroppedDown then
  begin
    SetFocus;
    PostMessage(Handle, WM_KEYDOWN, VK_F4, 0);
    PostMessage(Handle, WM_KEYUP, VK_F4, MakeLParam(0, CKeyUpFlags));
  end;
end;

procedure TThemedGridEditorDatePicker.CloseDropDown;
begin
  if IsDroppedDown then
    SendMessage(Handle, WM_CANCELMODE, 0, 0);
end;

constructor TThemedGridEditorControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csCaptureMouse];
  TabStop := True;
  DoubleBuffered := True;
  FBackColor := clWindow;
  FForeColor := clWindowText;
  FBorderColor := clBtnShadow;
  FAccentColor := clHighlight;
end;

procedure TThemedGridEditorControl.ApplyPalette(const APalette: TThemePalette);
begin
  if APalette = nil then
    Exit;
  FBackColor := ThemeColorToColor(APalette.InputBackColor);
  FForeColor := ThemeColorToColor(APalette.InputForeColor);
  FBorderColor := ThemeColorToColor(APalette.InputBorderColor);
  FAccentColor := ThemeColorToColor(APalette.AccentColor);
  Invalidate;
end;

procedure TThemedGridEditorControl.WMGetDlgCode(var AMessage: TWMGetDlgCode);
begin
  AMessage.Result := DLGC_WANTARROWS or DLGC_WANTCHARS;
end;

procedure TThemedGridEditorControl.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

procedure TThemedGridEditorControl.WMSetFocus(var AMessage: TWMSetFocus);
begin
  inherited;
  Invalidate;
end;

procedure TThemedGridEditorControl.WMKillFocus(var AMessage: TWMKillFocus);
begin
  inherited;
  Invalidate;
end;

procedure TThemedGridEditorControl.CMWantSpecialKey(var AMessage: TCMWantSpecialKey);
begin
  if WantsSpecialKey(AMessage.CharCode) then
    AMessage.Result := 1
  else
    inherited;
end;

procedure TThemedGridEditorControl.KeyDown(var AKey: Word; AShift: TShiftState);
begin
  inherited KeyDown(AKey, AShift);
  if Assigned(FOnEditorKeyDown) then
    FOnEditorKeyDown(Self, AKey, AShift);
end;

procedure TThemedGridEditorControl.DoExit;
begin
  inherited DoExit;
  if Assigned(FOnEditorExit) then
    FOnEditorExit(Self);
end;

procedure TThemedGridEditorControl.Paint;
var
  LRect: TRect;
begin
  LRect := ClientRect;
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := FBackColor;
  Canvas.FillRect(LRect);
  Canvas.Font.Assign(Font);
  Canvas.Font.Color := FForeColor;
  PaintContent(LRect);
  Canvas.Brush.Style := bsClear;
  if Focused then
    Canvas.Pen.Color := FAccentColor
  else
    Canvas.Pen.Color := FBorderColor;
  Canvas.Pen.Width := 1;
  Canvas.Pen.Style := psSolid;
  Canvas.Rectangle(LRect);
end;

procedure DrawStar(const ACanvas: TCanvas; const ABounds: TRect; const AFilled: Boolean;
  const AFill, ALine: TColor);
var
  LPoints: array[0..9] of TPoint;
  LCenterX, LCenterY, LOuter, LInner, I: Integer;
  LAngle, LRadius: Double;
begin
  LCenterX := (ABounds.Left + ABounds.Right) div 2;
  LCenterY := (ABounds.Top + ABounds.Bottom) div 2;
  LOuter := Min(ABounds.Width, ABounds.Height) div 2;
  LInner := Max(1, (LOuter * 2) div 5);
  for I := 0 to 9 do
  begin
    if Odd(I) then
      LRadius := LInner
    else
      LRadius := LOuter;
    LAngle := -Pi / 2 + I * Pi / 5;
    LPoints[I] := Point(LCenterX + Round(LRadius * Cos(LAngle)), LCenterY + Round(LRadius * Sin(LAngle)));
  end;
  ACanvas.Pen.Color := ALine;
  if AFilled then
  begin
    ACanvas.Brush.Style := bsSolid;
    ACanvas.Brush.Color := AFill;
  end
  else
    ACanvas.Brush.Style := bsClear;
  ACanvas.Polygon(LPoints);
end;

constructor TThemedGridRatingControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMaximum := TThemedGridInlineEditorGeometry.RatingDefaultMaximum;
end;

procedure TThemedGridRatingControl.SetMaximum(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := EnsureRange(AValue, TThemedGridInlineEditorGeometry.RatingMinimumMaximum,
    TThemedGridInlineEditorGeometry.RatingMaximumMaximum);
  if FMaximum = LValue then
    Exit;
  FMaximum := LValue;
  if FRating > FMaximum then
    FRating := FMaximum;
  Invalidate;
end;

procedure TThemedGridRatingControl.SetRating(const AValue: Extended);
var
  LValue: Extended;
begin
  LValue := EnsureRange(AValue, 0, FMaximum);
  if FRating = LValue then
    Exit;
  FRating := LValue;
  Invalidate;
end;

procedure TThemedGridRatingControl.PaintContent(const ARect: TRect);
var
  I, LFilled: Integer;
begin
  LFilled := Round(FRating);
  for I := 0 to FMaximum - 1 do
    DrawStar(Canvas, TThemedGridInlineEditorGeometry.GetRatingItemBounds(ARect, FMaximum, I),
      I < LFilled, AccentColor, AccentColor);
end;

procedure TThemedGridRatingControl.MouseDown(AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer);
begin
  inherited MouseDown(AButton, AShift, AX, AY);
  if not Focused then
    SetFocus;
  if AButton = mbLeft then
    Rating := TThemedGridInlineEditorGeometry.GetRatingValueFromPoint(ClientRect, FMaximum, Point(AX, AY));
end;

procedure TThemedGridRatingControl.KeyDown(var AKey: Word; AShift: TShiftState);
begin
  case AKey of
    VK_LEFT, VK_DOWN: begin Rating := Round(FRating) - 1; AKey := 0; end;
    VK_RIGHT, VK_UP: begin Rating := Round(FRating) + 1; AKey := 0; end;
    VK_HOME: begin Rating := 0; AKey := 0; end;
    VK_END: begin Rating := FMaximum; AKey := 0; end;
  end;
  inherited KeyDown(AKey, AShift);
end;

constructor TThemedGridSliderControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMinimum := 0;
  FMaximum := 100;
  FPosition := 0;
end;

procedure TThemedGridSliderControl.SetRange(const AMinimum, AMaximum: Integer);
begin
  FMinimum := AMinimum;
  FMaximum := Max(AMinimum, AMaximum);
  FPosition := EnsureRange(FPosition, FMinimum, FMaximum);
  Invalidate;
end;

procedure TThemedGridSliderControl.SetMinimum(const AValue: Integer);
begin
  SetRange(AValue, FMaximum);
end;

procedure TThemedGridSliderControl.SetMaximum(const AValue: Integer);
begin
  SetRange(FMinimum, AValue);
end;

procedure TThemedGridSliderControl.SetPosition(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := EnsureRange(AValue, FMinimum, FMaximum);
  if FPosition = LValue then
    Exit;
  FPosition := LValue;
  Invalidate;
end;

procedure TThemedGridSliderControl.PaintContent(const ARect: TRect);
var
  LTrack, LThumb, LFill: TRect;
  LNormalized: Extended;
begin
  LTrack := TThemedGridInlineEditorGeometry.GetSliderTrackBounds(ARect);
  if FMaximum > FMinimum then
    LNormalized := (FPosition - FMinimum) / (FMaximum - FMinimum)
  else
    LNormalized := 0;
  LThumb := TThemedGridInlineEditorGeometry.GetSliderThumbBounds(ARect, LNormalized);
  Canvas.Brush.Style := bsSolid;
  Canvas.Pen.Style := psClear;
  Canvas.Brush.Color := BorderColor;
  Canvas.RoundRect(LTrack.Left, LTrack.Top, LTrack.Right, LTrack.Bottom, 4, 4);
  LFill := TRect.Create(LTrack.Left, LTrack.Top, LThumb.Left + LThumb.Width div 2, LTrack.Bottom);
  if LFill.Width > 0 then
  begin
    Canvas.Brush.Color := AccentColor;
    Canvas.RoundRect(LFill.Left, LFill.Top, LFill.Right, LFill.Bottom, 4, 4);
  end;
  Canvas.Brush.Color := AccentColor;
  Canvas.Ellipse(LThumb.Left, LThumb.Top, LThumb.Right, LThumb.Bottom);
  Canvas.Pen.Style := psSolid;
end;

procedure TThemedGridSliderControl.UpdateFromPoint(const ALocation: TPoint);
var
  LRatio: Extended;
begin
  LRatio := TThemedGridInlineEditorGeometry.GetSliderRatioFromPoint(ClientRect, ALocation);
  Position := FMinimum + Round((FMaximum - FMinimum) * LRatio);
end;

procedure TThemedGridSliderControl.MouseDown(AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer);
begin
  inherited MouseDown(AButton, AShift, AX, AY);
  if not Focused then
    SetFocus;
  if AButton = mbLeft then
  begin
    FDragging := True;
    UpdateFromPoint(Point(AX, AY));
  end;
end;

procedure TThemedGridSliderControl.MouseMove(AShift: TShiftState; AX, AY: Integer);
begin
  inherited MouseMove(AShift, AX, AY);
  if FDragging then
    UpdateFromPoint(Point(AX, AY));
end;

procedure TThemedGridSliderControl.MouseUp(AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer);
begin
  FDragging := False;
  inherited MouseUp(AButton, AShift, AX, AY);
end;

procedure TThemedGridSliderControl.KeyDown(var AKey: Word; AShift: TShiftState);
var
  LPage: Integer;
begin
  LPage := Max(1, (FMaximum - FMinimum) div 10);
  case AKey of
    VK_LEFT, VK_DOWN: begin Position := FPosition - 1; AKey := 0; end;
    VK_RIGHT, VK_UP: begin Position := FPosition + 1; AKey := 0; end;
    VK_PRIOR: begin Position := FPosition + LPage; AKey := 0; end;
    VK_NEXT: begin Position := FPosition - LPage; AKey := 0; end;
    VK_HOME: begin Position := FMinimum; AKey := 0; end;
    VK_END: begin Position := FMaximum; AKey := 0; end;
  end;
  inherited KeyDown(AKey, AShift);
end;

constructor TThemedGridToggleControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FStyle := TThemedGridToggleStyle.Switch;
end;

procedure TThemedGridToggleControl.SetChecked(const AValue: Boolean);
begin
  if FChecked = AValue then
    Exit;
  FChecked := AValue;
  Invalidate;
end;

procedure TThemedGridToggleControl.SetStyle(const AValue: TThemedGridToggleStyle);
begin
  if FStyle = AValue then
    Exit;
  FStyle := AValue;
  Invalidate;
end;

procedure TThemedGridToggleControl.PaintContent(const ARect: TRect);
var
  LBox, LTrack: TRect;
  LSize, LThumb: Integer;
begin
  Canvas.Brush.Style := bsSolid;
  if FStyle = TThemedGridToggleStyle.CheckBox then
  begin
    LSize := Min(14, Min(ARect.Width, ARect.Height) - 4);
    LBox := TRect.Create(ARect.Left + (ARect.Width - LSize) div 2, ARect.Top + (ARect.Height - LSize) div 2,
      ARect.Left + (ARect.Width - LSize) div 2 + LSize, ARect.Top + (ARect.Height - LSize) div 2 + LSize);
    Canvas.Pen.Color := BorderColor;
    Canvas.Brush.Color := BackColor;
    if FChecked then
      Canvas.Brush.Color := AccentColor;
    Canvas.Rectangle(LBox);
    if FChecked then
    begin
      Canvas.Pen.Color := BackColor;
      Canvas.Pen.Width := 2;
      Canvas.MoveTo(LBox.Left + 3, LBox.Top + LSize div 2);
      Canvas.LineTo(LBox.Left + LSize div 2 - 1, LBox.Bottom - 4);
      Canvas.LineTo(LBox.Right - 3, LBox.Top + 3);
      Canvas.Pen.Width := 1;
    end;
    Exit;
  end;
  LTrack := TThemedGridInlineEditorGeometry.GetToggleBounds(ARect);
  LThumb := LTrack.Height - 4;
  Canvas.Pen.Style := psClear;
  if FChecked then
    Canvas.Brush.Color := AccentColor
  else
    Canvas.Brush.Color := BorderColor;
  Canvas.RoundRect(LTrack.Left, LTrack.Top, LTrack.Right, LTrack.Bottom, LTrack.Height, LTrack.Height);
  Canvas.Brush.Color := BackColor;
  if FChecked then
    Canvas.Ellipse(LTrack.Right - 2 - LThumb, LTrack.Top + 2, LTrack.Right - 2, LTrack.Top + 2 + LThumb)
  else
    Canvas.Ellipse(LTrack.Left + 2, LTrack.Top + 2, LTrack.Left + 2 + LThumb, LTrack.Top + 2 + LThumb);
  Canvas.Pen.Style := psSolid;
end;

procedure TThemedGridToggleControl.MouseDown(AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer);
begin
  inherited MouseDown(AButton, AShift, AX, AY);
  if not Focused then
    SetFocus;
  if AButton = mbLeft then
    Checked := not FChecked;
end;

procedure TThemedGridToggleControl.KeyDown(var AKey: Word; AShift: TShiftState);
begin
  if AKey = VK_SPACE then
  begin
    Checked := not FChecked;
    AKey := 0;
  end;
  inherited KeyDown(AKey, AShift);
end;

constructor TThemedGridColorButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FColor := clWhite;
end;

procedure TThemedGridColorButton.SetColor(const AValue: TColor);
begin
  if FColor = AValue then
    Exit;
  FColor := AValue;
  Invalidate;
end;

procedure TThemedGridColorButton.SetHasValue(const AValue: Boolean);
begin
  if FHasValue = AValue then
    Exit;
  FHasValue := AValue;
  Invalidate;
end;

procedure TThemedGridColorButton.PaintContent(const ARect: TRect);
var
  LSwatch, LText: TRect;
  LCaption: string;
  LRGB: Integer;
begin
  LSwatch := TRect.Create(ARect.Left + 4, ARect.Top + 3, ARect.Left + 4 + 28, ARect.Bottom - 3);
  if FHasValue then
  begin
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := FColor;
    Canvas.Pen.Color := BorderColor;
    Canvas.Rectangle(LSwatch);
    LRGB := ColorToRGB(FColor);
    LCaption := '#' + IntToHex(GetRValue(LRGB), 2) + IntToHex(GetGValue(LRGB), 2) + IntToHex(GetBValue(LRGB), 2);
  end
  else
    LCaption := '';
  LText := TRect.Create(LSwatch.Right + 6, ARect.Top, ARect.Right - 4, ARect.Bottom);
  Canvas.Brush.Style := bsClear;
  DrawText(Canvas.Handle, PChar(LCaption), Length(LCaption), LText,
    DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_NOPREFIX);
end;

function TThemedGridColorButton.GetIsDialogActive: Boolean;
begin
  Result := FDialogOpen or FDialogPending;
end;

procedure TThemedGridColorButton.RunDialog;
var
  LDialog: TColorDialog;
begin
  FDialogPending := False;
  if FDialogOpen or (csDestroying in ComponentState) or not HandleAllocated or (Parent = nil) then
    Exit;
  FDialogOpen := True;
  LDialog := TColorDialog.Create(nil);
  try
    LDialog.Color := FColor;
    LDialog.Options := [cdFullOpen];
    if LDialog.Execute(Handle) then
    begin
      FColor := LDialog.Color;
      FHasValue := True;
      Invalidate;
      if Assigned(FOnColorChosen) then
        FOnColorChosen(Self);
    end;
  finally
    LDialog.Free;
    FDialogOpen := False;
  end;
  if HandleAllocated and (Parent <> nil) and CanFocus then
    SetFocus;
end;

procedure TThemedGridColorButton.WMOpenColorDialog(var AMessage: TMessage);
begin
  RunDialog;
end;

procedure TThemedGridColorButton.OpenDialogDeferred;
begin
  if FDialogPending or FDialogOpen or not HandleAllocated then
    Exit;
  FDialogPending := True;
  PostMessage(Handle, WM_OPENCOLORDIALOG, 0, 0);
end;

procedure TThemedGridColorButton.MouseDown(AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer);
begin
  inherited MouseDown(AButton, AShift, AX, AY);
  if not Focused then
    SetFocus;
  if AButton = mbLeft then
    OpenDialogDeferred;
end;

procedure TThemedGridColorButton.KeyDown(var AKey: Word; AShift: TShiftState);
begin
  case AKey of
    VK_SPACE, VK_F4:
      begin
        OpenDialogDeferred;
        AKey := 0;
      end;
    VK_DELETE, VK_BACK:
      if FAllowClear then
      begin
        HasValue := False;
        AKey := 0;
      end;
  end;
  inherited KeyDown(AKey, AShift);
end;

end.

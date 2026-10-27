{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.Rating;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.Types,
  System.UITypes,
  Vcl.Controls,
  Vcl.Graphics,
  NimbusForms.Controls.Base,
  NimbusForms.Controls.Types;

type
  TRatingValueChangingEvent = procedure(Sender: TObject; const AOldValue: Double; var ANewValue: Double; var AAllow: Boolean) of object;
  TRatingValueChangedEvent = procedure(Sender: TObject; const AOldValue, ANewValue: Double) of object;

  TCustomThemedRatingControl = class(TCustomNimbusControl)
  private
    FMaximum: Integer;
    FRatingValue: Double;
    FHoverValue: Double;
    FIsHovered: Boolean;
    FReadOnly: Boolean;
    FAllowClear: Boolean;
    FClearOnSecondClick: Boolean;
    FShowValueText: Boolean;
    FShowOutline: Boolean;
    FValueTextFormat: string;
    FPrecision: TRatingPrecision;
    FRatingShape: TRatingShape;
    FStarSpacing: Integer;
    FItemSize: Integer;
    FStyleSavedHeight: Integer;
    FStyleAppliedHeight: Integer;
    FStyleAdjustedHeight: Boolean;
    FActiveColor: TColor;
    FInactiveColor: TColor;
    FHoverColor: TColor;
    FOutlineColor: TColor;
    FActiveImage: Vcl.Graphics.TBitmap;
    FInactiveImage: Vcl.Graphics.TBitmap;
    FHoverImage: Vcl.Graphics.TBitmap;
    FMeasureBitmap: Vcl.Graphics.TBitmap;
    FOnValueChanged: TNotifyEvent;
    FOnValueChanging: TRatingValueChangingEvent;
    FOnRatingClicked: TRatingValueChangedEvent;
    FOnHoverValueChanged: TRatingValueChangedEvent;
    function GetValue: Integer;
    procedure SetValue(const AValue: Integer);
    procedure SetMaximum(const AValue: Integer);
    procedure SetRatingValue(const AValue: Double);
    procedure SetPrecision(const AValue: TRatingPrecision);
    procedure SetRatingShape(const AValue: TRatingShape);
    procedure SetReadOnly(const AValue: Boolean);
    procedure SetAllowClear(const AValue: Boolean);
    procedure SetClearOnSecondClick(const AValue: Boolean);
    procedure SetShowValueText(const AValue: Boolean);
    procedure SetValueTextFormat(const AValue: string);
    procedure SetShowOutline(const AValue: Boolean);
    procedure SetStarSpacing(const AValue: Integer);
    procedure SetItemSize(const AValue: Integer);
    procedure SetActiveColor(const AValue: TColor);
    procedure SetInactiveColor(const AValue: TColor);
    procedure SetHoverColor(const AValue: TColor);
    procedure SetOutlineColor(const AValue: TColor);
    procedure SetActiveImage(const AValue: Vcl.Graphics.TBitmap);
    procedure SetInactiveImage(const AValue: Vcl.Graphics.TBitmap);
    procedure SetHoverImage(const AValue: Vcl.Graphics.TBitmap);
    procedure ImageChanged(Sender: TObject);
    function IsRatingValueStored: Boolean;
    function IsValueTextFormatStored: Boolean;
    function ChangeRatingValue(const AValue: Double; const ARaiseEvents: Boolean): Boolean;
    function RoundByPrecision(const AValue: Double): Double;
    function PrecisionStep: Double;
    function GetValueFromPoint(const APoint: TPoint): Double;
    function EffectiveItemSize: Integer;
    function EffectiveStarSpacing: Integer;
    function EffectiveTextSpacing: Integer;
    function FormatRatingValue: string;
    procedure UpdateAutoSize;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
  protected
    procedure StyleModeChanged; override;
    function CanAutoSize(var NewWidth, NewHeight: Integer): Boolean; override;
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
    procedure DoValueChanged; virtual;
    procedure DoValueChanging(const AOldValue: Double; var ANewValue: Double; var AAllow: Boolean); virtual;
    procedure DoRatingClicked(const AOldValue, ANewValue: Double); virtual;
    procedure DoHoverValueChanged(const AOldValue, ANewValue: Double); virtual;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Paint; override;
    property Maximum: Integer read FMaximum write SetMaximum default 5;
    property Value: Integer read GetValue write SetValue stored False;
    property RatingValue: Double read FRatingValue write SetRatingValue stored IsRatingValueStored;
    property Precision: TRatingPrecision read FPrecision write SetPrecision default rpFull;
    property RatingShape: TRatingShape read FRatingShape write SetRatingShape default rsStar;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default False;
    property AllowClear: Boolean read FAllowClear write SetAllowClear default True;
    property ClearOnSecondClick: Boolean read FClearOnSecondClick write SetClearOnSecondClick default True;
    property ShowValueText: Boolean read FShowValueText write SetShowValueText default False;
    property ValueTextFormat: string read FValueTextFormat write SetValueTextFormat stored IsValueTextFormatStored;
    property ShowOutline: Boolean read FShowOutline write SetShowOutline default True;
    property StarSpacing: Integer read FStarSpacing write SetStarSpacing default 4;
    property ItemSize: Integer read FItemSize write SetItemSize default 24;
    property ActiveColor: TColor read FActiveColor write SetActiveColor default clNone;
    property InactiveColor: TColor read FInactiveColor write SetInactiveColor default clNone;
    property HoverColor: TColor read FHoverColor write SetHoverColor default clNone;
    property OutlineColor: TColor read FOutlineColor write SetOutlineColor default clNone;
    property ActiveImage: Vcl.Graphics.TBitmap read FActiveImage write SetActiveImage;
    property InactiveImage: Vcl.Graphics.TBitmap read FInactiveImage write SetInactiveImage;
    property HoverImage: Vcl.Graphics.TBitmap read FHoverImage write SetHoverImage;
    property OnValueChanged: TNotifyEvent read FOnValueChanged write FOnValueChanged;
    property OnValueChanging: TRatingValueChangingEvent read FOnValueChanging write FOnValueChanging;
    property OnRatingClicked: TRatingValueChangedEvent read FOnRatingClicked write FOnRatingClicked;
    property OnHoverValueChanged: TRatingValueChangedEvent read FOnHoverValueChanged write FOnHoverValueChanged;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure BindAction(const AAction: TBasicAction);
    procedure UnbindAction;
    procedure SyncAction;
  end;

  TThemedRatingControl = class(TCustomThemedRatingControl)
  published
    property StyleMode;
    property Action;
    property ActiveColor;
    property ActiveImage;
    property Align;
    property AllowClear;
    property Anchors;
    property AutoSize;
    property BiDiMode;
    property ClearOnSecondClick;
    property Constraints;
    property Enabled;
    property Font;
    property HoverColor;
    property HoverImage;
    property InactiveColor;
    property InactiveImage;
    property ItemSize;
    property Maximum;
    property OutlineColor;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Precision;
    property RatingShape;
    property RatingValue;
    property ReadOnly;
    property ShowHint;
    property ShowOutline;
    property ShowValueText;
    property StarSpacing;
    property TabOrder;
    property TabStop default True;
    property Value;
    property ValueTextFormat;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnHoverValueChanged;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnRatingClicked;
    property OnValueChanged;
    property OnValueChanging;
  end;

implementation

uses
  System.SysUtils,
  System.Math,
  NimbusForms.Rendering.Types,
  NimbusForms.Rendering.Rating;

const
  DefaultRatingValueTextFormat = '{0:0.#}';
  RatingDefaultHeight = 24;
  RatingTextSpacing = 8;
  RatingEpsilon = 0.0001;

constructor TCustomThemedRatingControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csCaptureMouse];
  Width := 136;
  Height := RatingDefaultHeight;
  TabStop := True;
  FMaximum := 5;
  FRatingValue := 0;
  FHoverValue := 0;
  FIsHovered := False;
  FReadOnly := False;
  FAllowClear := True;
  FClearOnSecondClick := True;
  FShowValueText := False;
  FShowOutline := True;
  FValueTextFormat := DefaultRatingValueTextFormat;
  FPrecision := rpFull;
  FRatingShape := rsStar;
  FStarSpacing := 4;
  FItemSize := 24;
  FActiveColor := clNone;
  FInactiveColor := clNone;
  FHoverColor := clNone;
  FOutlineColor := clNone;
  FActiveImage := Vcl.Graphics.TBitmap.Create;
  FInactiveImage := Vcl.Graphics.TBitmap.Create;
  FHoverImage := Vcl.Graphics.TBitmap.Create;
  FActiveImage.OnChange := ImageChanged;
  FInactiveImage.OnChange := ImageChanged;
  FHoverImage.OnChange := ImageChanged;
  FMeasureBitmap := Vcl.Graphics.TBitmap.Create;
  FMeasureBitmap.PixelFormat := pf32bit;
  FMeasureBitmap.SetSize(4, 4);
end;

destructor TCustomThemedRatingControl.Destroy;
begin
  FMeasureBitmap.Free;
  FHoverImage.Free;
  FInactiveImage.Free;
  FActiveImage.Free;
  inherited Destroy;
end;

procedure TCustomThemedRatingControl.BindAction(const AAction: TBasicAction);
begin
  Action := AAction;
end;

procedure TCustomThemedRatingControl.UnbindAction;
begin
  Action := nil;
end;

procedure TCustomThemedRatingControl.SyncAction;
begin
  InitiateAction;
end;

function TCustomThemedRatingControl.GetValue: Integer;
begin
  Result := Round(FRatingValue);
end;

procedure TCustomThemedRatingControl.SetValue(const AValue: Integer);
begin
  SetRatingValue(AValue);
end;

procedure TCustomThemedRatingControl.SetMaximum(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 1 then LValue := 1;
  if FMaximum = LValue then Exit;
  FMaximum := LValue;
  if FRatingValue > FMaximum then ChangeRatingValue(FMaximum, True);
  if FHoverValue > FMaximum then FHoverValue := FMaximum;
  UpdateAutoSize;
  Invalidate;
end;

procedure TCustomThemedRatingControl.SetRatingValue(const AValue: Double);
begin
  ChangeRatingValue(AValue, True);
end;

procedure TCustomThemedRatingControl.SetPrecision(const AValue: TRatingPrecision);
begin
  if FPrecision = AValue then Exit;
  FPrecision := AValue;
  ChangeRatingValue(FRatingValue, True);
  if FIsHovered then FHoverValue := EnsureRange(RoundByPrecision(FHoverValue), 0.0, FMaximum);
  Invalidate;
end;

procedure TCustomThemedRatingControl.SetRatingShape(const AValue: TRatingShape);
begin
  if FRatingShape = AValue then Exit;
  FRatingShape := AValue;
  Invalidate;
end;

procedure TCustomThemedRatingControl.SetReadOnly(const AValue: Boolean);
begin
  if FReadOnly = AValue then Exit;
  FReadOnly := AValue;
  Invalidate;
end;

procedure TCustomThemedRatingControl.SetAllowClear(const AValue: Boolean);
begin
  if FAllowClear = AValue then Exit;
  FAllowClear := AValue;
end;

procedure TCustomThemedRatingControl.SetClearOnSecondClick(const AValue: Boolean);
begin
  if FClearOnSecondClick = AValue then Exit;
  FClearOnSecondClick := AValue;
end;

procedure TCustomThemedRatingControl.SetShowValueText(const AValue: Boolean);
begin
  if FShowValueText = AValue then Exit;
  FShowValueText := AValue;
  UpdateAutoSize;
  Invalidate;
end;

procedure TCustomThemedRatingControl.SetValueTextFormat(const AValue: string);
var
  LValue: string;
begin
  LValue := AValue;
  if LValue = '' then LValue := DefaultRatingValueTextFormat;
  if FValueTextFormat = LValue then Exit;
  FValueTextFormat := LValue;
  UpdateAutoSize;
  Invalidate;
end;

procedure TCustomThemedRatingControl.SetShowOutline(const AValue: Boolean);
begin
  if FShowOutline = AValue then Exit;
  FShowOutline := AValue;
  Invalidate;
end;

procedure TCustomThemedRatingControl.SetStarSpacing(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 0 then LValue := 0;
  if FStarSpacing = LValue then Exit;
  FStarSpacing := LValue;
  UpdateAutoSize;
  Invalidate;
end;

procedure TCustomThemedRatingControl.SetItemSize(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 8 then LValue := 8;
  if FItemSize = LValue then Exit;
  FItemSize := LValue;
  UpdateAutoSize;
  Invalidate;
end;

procedure TCustomThemedRatingControl.SetActiveColor(const AValue: TColor);
begin
  if FActiveColor = AValue then Exit;
  FActiveColor := AValue;
  Invalidate;
end;

procedure TCustomThemedRatingControl.SetInactiveColor(const AValue: TColor);
begin
  if FInactiveColor = AValue then Exit;
  FInactiveColor := AValue;
  Invalidate;
end;

procedure TCustomThemedRatingControl.SetHoverColor(const AValue: TColor);
begin
  if FHoverColor = AValue then Exit;
  FHoverColor := AValue;
  Invalidate;
end;

procedure TCustomThemedRatingControl.SetOutlineColor(const AValue: TColor);
begin
  if FOutlineColor = AValue then Exit;
  FOutlineColor := AValue;
  Invalidate;
end;

procedure TCustomThemedRatingControl.SetActiveImage(const AValue: Vcl.Graphics.TBitmap);
begin
  FActiveImage.Assign(AValue);
end;

procedure TCustomThemedRatingControl.SetInactiveImage(const AValue: Vcl.Graphics.TBitmap);
begin
  FInactiveImage.Assign(AValue);
end;

procedure TCustomThemedRatingControl.SetHoverImage(const AValue: Vcl.Graphics.TBitmap);
begin
  FHoverImage.Assign(AValue);
end;

procedure TCustomThemedRatingControl.ImageChanged(Sender: TObject);
begin
  Invalidate;
end;

function TCustomThemedRatingControl.IsRatingValueStored: Boolean;
begin
  Result := not SameValue(FRatingValue, 0.0, RatingEpsilon);
end;

function TCustomThemedRatingControl.IsValueTextFormatStored: Boolean;
begin
  Result := FValueTextFormat <> DefaultRatingValueTextFormat;
end;

function TCustomThemedRatingControl.RoundByPrecision(const AValue: Double): Double;
var
  LStep, LScaled: Double;
begin
  if FPrecision = rpExact then Exit(AValue);
  LStep := PrecisionStep;
  if LStep <= 0 then LStep := 1;
  LScaled := AValue / LStep;
  if LScaled >= 0 then
    Result := Floor(LScaled + 0.5) * LStep
  else
    Result := Ceil(LScaled - 0.5) * LStep;
end;

function TCustomThemedRatingControl.PrecisionStep: Double;
begin
  case FPrecision of
    rpHalf: Result := 0.5;
    rpQuarter: Result := 0.25;
    rpExact: Result := 0.1;
  else
    Result := 1.0;
  end;
end;

function TCustomThemedRatingControl.ChangeRatingValue(const AValue: Double; const ARaiseEvents: Boolean): Boolean;
var
  LOldValue, LNewValue: Double;
  LAllow: Boolean;
begin
  Result := False;
  LNewValue := EnsureRange(RoundByPrecision(AValue), 0.0, FMaximum);
  if SameValue(FRatingValue, LNewValue, RatingEpsilon) then Exit;
  LOldValue := FRatingValue;

  if ARaiseEvents and not (csLoading in ComponentState) and not (csReading in ComponentState) then
  begin
    LAllow := True;
    DoValueChanging(LOldValue, LNewValue, LAllow);
    if not LAllow then Exit;
    LNewValue := EnsureRange(RoundByPrecision(LNewValue), 0.0, FMaximum);
  end;

  FRatingValue := LNewValue;
  if FShowValueText then UpdateAutoSize;
  Invalidate;
  if ARaiseEvents and not (csLoading in ComponentState) and not (csReading in ComponentState) then DoValueChanged;
  Result := True;
end;

function TCustomThemedRatingControl.EffectiveItemSize: Integer;
begin
  Result := ScaleValue(FItemSize - Ord(StyleMode = stCompact) * Max(2, FItemSize div 4));
  Result := Max(ScaleValue(8), Result);
end;

function TCustomThemedRatingControl.EffectiveStarSpacing: Integer;
begin
  Result := ScaleValue(Max(0, FStarSpacing - Ord((StyleMode = stCompact) and (FStarSpacing > 0))));
end;

function TCustomThemedRatingControl.EffectiveTextSpacing: Integer;
begin
  Result := ScaleValue(RatingTextSpacing - Ord(StyleMode = stCompact) * 2);
end;

function TCustomThemedRatingControl.GetValueFromPoint(const APoint: TPoint): Double;
var
  I, LItemSize, LSpacing: Integer;
  LRect: TRect;
  LPart: Double;
begin
  if APoint.X < 0 then Exit(0);
  LItemSize := EffectiveItemSize;
  LSpacing := EffectiveStarSpacing;
  for I := 0 to FMaximum - 1 do
  begin
    LRect := TThemedRatingRenderer.CalculateItemRect(ClientRect, I, LItemSize, LSpacing);
    LRect.Top := 0;
    LRect.Bottom := ClientHeight;
    if PtInRect(LRect, APoint) then
    begin
      LPart := (APoint.X - LRect.Left) / LItemSize;
      Exit(RoundByPrecision(I + LPart));
    end;
    if (APoint.X >= LRect.Right) and (APoint.X < LRect.Right + LSpacing) then Exit(I + 1);
  end;
  Result := FMaximum;
end;

function TCustomThemedRatingControl.FormatRatingValue: string;
var
  LRemaining, LToken, LPattern, LFormatted: string;
  LStart, LClose: Integer;
begin
  Result := '';
  LRemaining := FValueTextFormat;
  while LRemaining <> '' do
  begin
    LStart := Pos('{0', LRemaining);
    if LStart = 0 then
    begin
      Result := Result + LRemaining;
      Break;
    end;
    Result := Result + Copy(LRemaining, 1, LStart - 1);
    LClose := Pos('}', Copy(LRemaining, LStart, MaxInt));
    if LClose = 0 then
    begin
      Result := Result + Copy(LRemaining, LStart, MaxInt);
      Break;
    end;
    LClose := LStart + LClose - 1;
    LToken := Copy(LRemaining, LStart, LClose - LStart + 1);
    if LToken = '{0}' then
      LFormatted := FloatToStr(FRatingValue)
    else if (Length(LToken) >= 5) and (Copy(LToken, 1, 3) = '{0:') then
    begin
      LPattern := Copy(LToken, 4, Length(LToken) - 4);
      LFormatted := FormatFloat(LPattern, FRatingValue);
    end
    else
      LFormatted := LToken;
    Result := Result + LFormatted;
    LRemaining := Copy(LRemaining, LClose + 1, MaxInt);
  end;
end;

procedure TCustomThemedRatingControl.StyleModeChanged;
var
  LHeight: Integer;
begin
  inherited StyleModeChanged;
  if StyleMode = stCompact then
  begin
    FStyleAdjustedHeight := False;
    if not AutoSize and (Align in [alNone, alTop, alBottom]) then
    begin
      FStyleSavedHeight := Height;
      LHeight := Max(ScaleValue(18), Height - ScaleValue(6));
      if LHeight < Height then
      begin
        Height := LHeight;
        FStyleAppliedHeight := Height;
        FStyleAdjustedHeight := True;
      end;
    end;
  end
  else
  begin
    if FStyleAdjustedHeight and (Align in [alNone, alTop, alBottom]) and (Height = FStyleAppliedHeight) then
      Height := FStyleSavedHeight;
    FStyleAdjustedHeight := False;
  end;
  UpdateAutoSize;
  Invalidate;
end;

procedure TCustomThemedRatingControl.UpdateAutoSize;
begin
  if AutoSize and not (csLoading in ComponentState) and not (csReading in ComponentState) then AdjustSize;
end;

function TCustomThemedRatingControl.CanAutoSize(var NewWidth, NewHeight: Integer): Boolean;
var
  LItemSize, LSpacing, LTextSpacing: Integer;
  LTextSize: TSize;
  LText: string;
begin
  Result := inherited CanAutoSize(NewWidth, NewHeight);
  if not Result then Exit;
  LItemSize := EffectiveItemSize;
  LSpacing := EffectiveStarSpacing;
  LTextSpacing := EffectiveTextSpacing;
  NewWidth := TThemedRatingRenderer.CalculateItemsWidth(FMaximum, LItemSize, LSpacing);
  NewHeight := Max(LItemSize, ScaleValue(RatingDefaultHeight - Ord(StyleMode = stCompact) * 6));
  if not FShowValueText then Exit;
  LText := FormatRatingValue;
  if LText = '' then Exit;
  RenderCanvas.BeginRender(FMeasureBitmap.Canvas);
  try
    LTextSize := RenderCanvas.MeasureText(LText, Font, 32767, [ntfSingleLine, ntfNoPrefix]);
  finally
    RenderCanvas.EndRender;
  end;
  NewWidth := NewWidth + LTextSpacing + LTextSize.cx;
  if LTextSize.cy > NewHeight then NewHeight := LTextSize.cy;
end;

procedure TCustomThemedRatingControl.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited ChangeScale(M, D, isDpiChange);
  UpdateAutoSize;
  Invalidate;
end;

procedure TCustomThemedRatingControl.DoValueChanged;
begin
  if Assigned(FOnValueChanged) then FOnValueChanged(Self);
end;

procedure TCustomThemedRatingControl.DoValueChanging(const AOldValue: Double; var ANewValue: Double; var AAllow: Boolean);
begin
  if Assigned(FOnValueChanging) then FOnValueChanging(Self, AOldValue, ANewValue, AAllow);
end;

procedure TCustomThemedRatingControl.DoRatingClicked(const AOldValue, ANewValue: Double);
begin
  if Assigned(FOnRatingClicked) then FOnRatingClicked(Self, AOldValue, ANewValue);
end;

procedure TCustomThemedRatingControl.DoHoverValueChanged(const AOldValue, ANewValue: Double);
begin
  if Assigned(FOnHoverValueChanged) then FOnHoverValueChanged(Self, AOldValue, ANewValue);
end;

procedure TCustomThemedRatingControl.CMMouseLeave(var Message: TMessage);
var
  LOldValue: Double;
begin
  inherited;
  if not FIsHovered and SameValue(FHoverValue, 0.0, RatingEpsilon) then Exit;
  LOldValue := FHoverValue;
  FIsHovered := False;
  FHoverValue := 0;
  DoHoverValueChanged(LOldValue, 0);
  Invalidate;
end;

procedure TCustomThemedRatingControl.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  if not Enabled then
  begin
    FIsHovered := False;
    FHoverValue := 0;
  end;
  Invalidate;
end;

procedure TCustomThemedRatingControl.CMFontChanged(var Message: TMessage);
begin
  inherited;
  UpdateAutoSize;
  Invalidate;
end;

procedure TCustomThemedRatingControl.DoEnter;
begin
  inherited DoEnter;
  Invalidate;
end;

procedure TCustomThemedRatingControl.DoExit;
begin
  inherited DoExit;
  Invalidate;
end;

procedure TCustomThemedRatingControl.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LOldValue, LNewValue: Double;
begin
  inherited MouseMove(Shift, X, Y);
  if FReadOnly or not Enabled then Exit;
  FIsHovered := True;
  LNewValue := EnsureRange(GetValueFromPoint(Point(X, Y)), 0.0, FMaximum);
  if SameValue(FHoverValue, LNewValue, RatingEpsilon) then Exit;
  LOldValue := FHoverValue;
  FHoverValue := LNewValue;
  DoHoverValueChanged(LOldValue, FHoverValue);
  Invalidate;
end;

procedure TCustomThemedRatingControl.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LClickedValue, LOldValue: Double;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button <> mbLeft) or FReadOnly or not Enabled then Exit;
  if CanFocus then SetFocus;
  LClickedValue := EnsureRange(GetValueFromPoint(Point(X, Y)), 0.0, FMaximum);
  if FAllowClear and FClearOnSecondClick and SameValue(LClickedValue, FRatingValue, RatingEpsilon) then LClickedValue := 0;
  LOldValue := FRatingValue;
  if ChangeRatingValue(LClickedValue, True) then DoRatingClicked(LOldValue, FRatingValue);
end;

procedure TCustomThemedRatingControl.KeyDown(var Key: Word; Shift: TShiftState);
var
  LStep: Double;
begin
  inherited KeyDown(Key, Shift);
  if FReadOnly or not Enabled then Exit;
  LStep := PrecisionStep;
  case Key of
    VK_RIGHT, VK_UP, VK_ADD, VK_OEM_PLUS:
      begin
        ChangeRatingValue(FRatingValue + LStep, True);
        Key := 0;
      end;
    VK_LEFT, VK_DOWN, VK_SUBTRACT, VK_OEM_MINUS:
      begin
        ChangeRatingValue(FRatingValue - LStep, True);
        Key := 0;
      end;
    VK_DELETE, VK_BACK:
      if FAllowClear then
      begin
        ChangeRatingValue(0, True);
        Key := 0;
      end;
  end;
end;

procedure TCustomThemedRatingControl.Paint;
var
  LContext: TThemedRatingRenderContext;
begin
  RenderCanvas.BeginRender(Canvas);
  try
    LContext.Bounds := ClientRect;
    LContext.Font := Font;
    LContext.Palette := Palette;
    LContext.Enabled := Enabled;
    LContext.Focused := Focused;
    LContext.ReadOnly := FReadOnly;
    LContext.IsHovered := FIsHovered;
    LContext.ShowValueText := FShowValueText;
    LContext.ShowOutline := FShowOutline;
    LContext.Maximum := FMaximum;
    LContext.RatingValue := FRatingValue;
    LContext.HoverValue := FHoverValue;
    LContext.RatingShape := FRatingShape;
    LContext.ItemSize := EffectiveItemSize;
    LContext.ItemSpacing := EffectiveStarSpacing;
    LContext.TextSpacing := EffectiveTextSpacing;
    LContext.HoverOutlineWidth := 2.0 * CurrentPPI / 96;
    if LContext.HoverOutlineWidth < 1 then LContext.HoverOutlineWidth := 1;
    LContext.ValueText := FormatRatingValue;
    LContext.ForeColor := Font.Color;
    LContext.ActiveColor := FActiveColor;
    LContext.InactiveColor := FInactiveColor;
    LContext.HoverColor := FHoverColor;
    LContext.OutlineColor := FOutlineColor;
    LContext.ActiveImage := FActiveImage;
    LContext.InactiveImage := FInactiveImage;
    LContext.HoverImage := FHoverImage;
    TThemedRatingRenderer.Render(RenderCanvas, LContext);
  finally
    RenderCanvas.EndRender;
  end;
end;

end.

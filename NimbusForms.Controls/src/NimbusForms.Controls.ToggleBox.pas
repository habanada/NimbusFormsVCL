{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.ToggleBox;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.Types,
  System.UITypes,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.ExtCtrls,
  NimbusForms.Controls.Types,
  NimbusForms.Controls.Base,
  NimbusForms.Rendering.ToggleBox;

type
  TToggleCheckedChangingEvent = procedure(Sender: TObject; const AOldValue, ANewValue: Boolean;
    const ASource: TToggleChangeSource; var AAllow: Boolean) of object;
  TToggleClickedEvent = procedure(Sender: TObject; const AOldValue, ANewValue: Boolean;
    const ASource: TToggleChangeSource) of object;

  TCustomThemedToggleBox = class(TCustomNimbusControl)
  private
    FChecked: Boolean;
    FReadOnly: Boolean;
    FHot: Boolean;
    FPressed: Boolean;
    FShowBorder: Boolean;
    FShowFocusCue: Boolean;
    FFocusCueStyle: TToggleFocusCueStyle;
    FAnimate: Boolean;
    FSynchronizeCheckedWithAction: Boolean;
    FSynchronizingAction: Boolean;
    FTextMode: TToggleTextMode;
    FLabelPosition: TToggleLabelPosition;
    FSwitchAlignment: TToggleSwitchAlignment;
    FTrackWidth: Integer;
    FTrackWidthWithText: Integer;
    FTrackHeight: Integer;
    FSpacing: Integer;
    FPaddingSmall: Integer;
    FInnerOffset: Integer;
    FThumbInset: Integer;
    FOnText: string;
    FOffText: string;
    FOnBackColor: TColor;
    FOffBackColor: TColor;
    FThumbColor: TColor;
    FBorderColor: TColor;
    FAnimationValue: Single;
    FAnimationStartValue: Single;
    FAnimationStartTick: UInt64;
    FAnimationTimer: TTimer;
    FInnerFont: TFont;
    FMeasureBitmap: Vcl.Graphics.TBitmap;
    FClickSource: TToggleChangeSource;
    FOnCheckedChanged: TNotifyEvent;
    FOnCheckedChanging: TToggleCheckedChangingEvent;
    FOnToggleClicked: TToggleClickedEvent;
    procedure SetChecked(const AValue: Boolean);
    procedure SetReadOnly(const AValue: Boolean);
    procedure SetShowBorder(const AValue: Boolean);
    procedure SetShowFocusCue(const AValue: Boolean);
    procedure SetFocusCueStyle(const AValue: TToggleFocusCueStyle);
    procedure SetAnimate(const AValue: Boolean);
    procedure SetSynchronizeCheckedWithAction(const AValue: Boolean);
    procedure SetTextMode(const AValue: TToggleTextMode);
    procedure SetLabelPosition(const AValue: TToggleLabelPosition);
    procedure SetSwitchAlignment(const AValue: TToggleSwitchAlignment);
    procedure SetTrackWidth(const AValue: Integer);
    procedure SetTrackHeight(const AValue: Integer);
    procedure SetSpacing(const AValue: Integer);
    procedure SetOnText(const AValue: string);
    procedure SetOffText(const AValue: string);
    procedure SetOnBackColor(const AValue: TColor);
    procedure SetOffBackColor(const AValue: TColor);
    procedure SetThumbColor(const AValue: TColor);
    procedure SetBorderColor(const AValue: TColor);
    function GetShowStateText: Boolean;
    procedure SetShowStateText(const AValue: Boolean);
    function GetCheckedText: string;
    procedure SetCheckedText(const AValue: string);
    function GetUncheckedText: string;
    procedure SetUncheckedText(const AValue: string);
    procedure AnimationTimer(Sender: TObject);
    procedure UpdateInnerFont;
    procedure UpdateAutoSize;
    function ChangeChecked(const AValue: Boolean; const ASource: TToggleChangeSource): Boolean;
    procedure ToggleByUser(const ASource: TToggleChangeSource);
    procedure SynchronizeCheckedToAction;
    function StateText(const AChecked: Boolean): string;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
  protected
    procedure StyleModeChanged; override;
    function CanAutoSize(var NewWidth, NewHeight: Integer): Boolean; override;
    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean); override;
    procedure Paint; override;
    procedure Click; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure DoCheckedChanging(const AOldValue, ANewValue: Boolean; const ASource: TToggleChangeSource; var AAllow: Boolean); virtual;
    procedure DoCheckedChanged; virtual;
    procedure DoToggleClicked(const AOldValue, ANewValue: Boolean; const ASource: TToggleChangeSource); virtual;
    property Checked: Boolean read FChecked write SetChecked default False;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default False;
    property ShowBorder: Boolean read FShowBorder write SetShowBorder default True;
    property ShowFocusCue: Boolean read FShowFocusCue write SetShowFocusCue default True;
    property FocusCueStyle: TToggleFocusCueStyle read FFocusCueStyle write SetFocusCueStyle default tfcsBorder;
    property Animate: Boolean read FAnimate write SetAnimate default True;
    property SynchronizeCheckedWithAction: Boolean read FSynchronizeCheckedWithAction write SetSynchronizeCheckedWithAction default True;
    property TextMode: TToggleTextMode read FTextMode write SetTextMode default ttmNone;
    property LabelPosition: TToggleLabelPosition read FLabelPosition write SetLabelPosition default tlpRight;
    property SwitchAlignment: TToggleSwitchAlignment read FSwitchAlignment write SetSwitchAlignment default tsaLeft;
    property OnText: string read FOnText write SetOnText;
    property OffText: string read FOffText write SetOffText;
    property OnBackColor: TColor read FOnBackColor write SetOnBackColor default clNone;
    property OffBackColor: TColor read FOffBackColor write SetOffBackColor default clNone;
    property ThumbColor: TColor read FThumbColor write SetThumbColor default clNone;
    property BorderColor: TColor read FBorderColor write SetBorderColor default clNone;
    property TrackWidth: Integer read FTrackWidth write SetTrackWidth default 44;
    property TrackHeight: Integer read FTrackHeight write SetTrackHeight default 22;
    property Spacing: Integer read FSpacing write SetSpacing default 8;
    property ShowStateText: Boolean read GetShowStateText write SetShowStateText default False;
    property CheckedText: string read GetCheckedText write SetCheckedText;
    property UncheckedText: string read GetUncheckedText write SetUncheckedText;
    property OnCheckedChanging: TToggleCheckedChangingEvent read FOnCheckedChanging write FOnCheckedChanging;
    property OnCheckedChanged: TNotifyEvent read FOnCheckedChanged write FOnCheckedChanged;
    property OnToggleClicked: TToggleClickedEvent read FOnToggleClicked write FOnToggleClicked;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Toggle;
  end;

  TThemedToggleBox = class(TCustomThemedToggleBox)
  published
    property StyleMode;
    property Action;
    property Align;
    property Anchors;
    property AutoSize;
    property BiDiMode;
    property Caption;
    property Checked;
    property CheckedText;
    property Constraints;
    property Enabled;
    property Font;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property ShowStateText;
    property ShowBorder;
    property ShowFocusCue;
    property FocusCueStyle;
    property Animate;
    property SynchronizeCheckedWithAction;
    property TextMode;
    property LabelPosition;
    property SwitchAlignment;
    property OnText;
    property OffText;
    property OnBackColor;
    property OffBackColor;
    property ThumbColor;
    property BorderColor;
    property Spacing;
    property TabOrder;
    property TabStop default True;
    property TrackHeight;
    property TrackWidth;
    property UncheckedText;
    property Visible;
    property OnCheckedChanging;
    property OnCheckedChanged;
    property OnToggleClicked;
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

  TThemedToggleSwitch = class(TThemedToggleBox);

implementation

uses
  System.Math,
  Vcl.Forms,
  Vcl.ActnList,
  NimbusForms.Controls.Strings,
  NimbusForms.Rendering.Types;

const
  ToggleAnimationDuration = 140;

constructor TCustomThemedToggleBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 140;
  Height := 24;
  TabStop := True;
  FChecked := False;
  FReadOnly := False;
  FShowBorder := True;
  FShowFocusCue := True;
  FFocusCueStyle := tfcsBorder;
  FAnimate := True;
  FSynchronizeCheckedWithAction := True;
  FSynchronizingAction := False;
  FTextMode := ttmNone;
  FLabelPosition := tlpRight;
  FSwitchAlignment := tsaLeft;
  FTrackWidth := 44;
  FTrackWidthWithText := 54;
  FTrackHeight := 22;
  FSpacing := 8;
  FPaddingSmall := 3;
  FInnerOffset := 5;
  FThumbInset := 6;
  FOnText := SThemedToggleOn;
  FOffText := SThemedToggleOff;
  FOnBackColor := clNone;
  FOffBackColor := clNone;
  FThumbColor := clNone;
  FBorderColor := clNone;
  FAnimationValue := 0;
  FClickSource := tcsCode;
  FInnerFont := TFont.Create;
  FMeasureBitmap := Vcl.Graphics.TBitmap.Create;
  FMeasureBitmap.PixelFormat := pf32bit;
  FMeasureBitmap.SetSize(4, 4);
  FAnimationTimer := TTimer.Create(nil);
  FAnimationTimer.Enabled := False;
  FAnimationTimer.Interval := 15;
  FAnimationTimer.OnTimer := AnimationTimer;
  UpdateInnerFont;
end;

destructor TCustomThemedToggleBox.Destroy;
begin
  FAnimationTimer.Free;
  FMeasureBitmap.Free;
  FInnerFont.Free;
  inherited Destroy;
end;

procedure TCustomThemedToggleBox.UpdateInnerFont;
begin
  FInnerFont.Assign(Font);
  if FInnerFont.Size > 2 then
    FInnerFont.Size := FInnerFont.Size - 2
  else
    FInnerFont.Size := 1;
  FInnerFont.Style := FInnerFont.Style + [fsBold];
end;

procedure TCustomThemedToggleBox.StyleModeChanged;
begin
  inherited StyleModeChanged;
  UpdateStyleHeight(24, 20);
  UpdateAutoSize;
end;

procedure TCustomThemedToggleBox.UpdateAutoSize;
begin
  if AutoSize and not (csLoading in ComponentState) then
    AdjustSize;
end;

function TCustomThemedToggleBox.CanAutoSize(var NewWidth, NewHeight: Integer): Boolean;
var
  LSwitchWidth, LSwitchHeight, LPadding: Integer;
  LTextSize: TSize;
begin
  Result := inherited CanAutoSize(NewWidth, NewHeight);
  if not Result then
    Exit;

  if FTextMode = ttmNone then
    LSwitchWidth := ScaleValue(FTrackWidth)
  else
    LSwitchWidth := ScaleValue(FTrackWidthWithText);
  LSwitchHeight := ScaleValue(Max(12, FTrackHeight - Ord(StyleMode = stCompact) * 4));
  LPadding := ScaleValue(Max(0, FSpacing - Ord(StyleMode = stCompact) * 2));
  LTextSize.cx := 0;
  LTextSize.cy := 0;

  if (Caption <> '') and (FLabelPosition <> tlpHidden) then
  begin
    RenderCanvas.BeginRender(FMeasureBitmap.Canvas);
    try
      LTextSize := RenderCanvas.MeasureText(Caption, Font, 32767, [ntfSingleLine, ntfNoPrefix]);
    finally
      RenderCanvas.EndRender;
    end;
  end;

  NewWidth := LSwitchWidth;
  NewHeight := LSwitchHeight;
  if (LTextSize.cx > 0) and (LTextSize.cy > 0) then
  begin
    if FLabelPosition in [tlpLeft, tlpRight] then
    begin
      NewWidth := LSwitchWidth + LPadding + LTextSize.cx;
      if LTextSize.cy > NewHeight then NewHeight := LTextSize.cy;
    end
    else if FLabelPosition in [tlpTop, tlpBottom] then
    begin
      if LTextSize.cx > NewWidth then NewWidth := LTextSize.cx;
      NewHeight := LSwitchHeight + LPadding + LTextSize.cy;
    end;
  end;
end;

procedure TCustomThemedToggleBox.SetChecked(const AValue: Boolean);
begin
  ChangeChecked(AValue, tcsCode);
end;

function TCustomThemedToggleBox.ChangeChecked(const AValue: Boolean; const ASource: TToggleChangeSource): Boolean;
var
  LAllow: Boolean;
begin
  Result := False;
  if FChecked = AValue then
    Exit;
  if csLoading in ComponentState then
  begin
    FChecked := AValue;
    if FChecked then FAnimationValue := 1 else FAnimationValue := 0;
    Result := True;
    Exit;
  end;
  LAllow := True;
  DoCheckedChanging(FChecked, AValue, ASource, LAllow);
  if not LAllow then
    Exit;
  FChecked := AValue;
  SynchronizeCheckedToAction;
  if FAnimate and HandleAllocated and not (csDesigning in ComponentState) then
  begin
    FAnimationStartValue := FAnimationValue;
    FAnimationStartTick := GetTickCount64;
    FAnimationTimer.Enabled := True;
  end
  else
  begin
    FAnimationTimer.Enabled := False;
    if FChecked then FAnimationValue := 1 else FAnimationValue := 0;
  end;
  Invalidate;
  DoCheckedChanged;
  Result := True;
end;

procedure TCustomThemedToggleBox.Toggle;
begin
  ChangeChecked(not FChecked, tcsCode);
end;

procedure TCustomThemedToggleBox.ToggleByUser(const ASource: TToggleChangeSource);
var
  LOldValue: Boolean;
begin
  if FReadOnly or not Enabled then
    Exit;
  LOldValue := FChecked;
  if ChangeChecked(not FChecked, ASource) then
    DoToggleClicked(LOldValue, FChecked, ASource);
end;

procedure TCustomThemedToggleBox.AnimationTimer(Sender: TObject);
var
  LElapsed: UInt64;
  LProgress, LInverse, LEased, LTarget: Single;
begin
  LElapsed := GetTickCount64 - FAnimationStartTick;
  LProgress := LElapsed / ToggleAnimationDuration;
  if LProgress > 1 then LProgress := 1;
  LInverse := 1 - LProgress;
  LEased := 1 - LInverse * LInverse * LInverse;
  if FChecked then LTarget := 1 else LTarget := 0;
  FAnimationValue := FAnimationStartValue + (LTarget - FAnimationStartValue) * LEased;
  if LProgress >= 1 then
  begin
    FAnimationValue := LTarget;
    FAnimationTimer.Enabled := False;
  end;
  Invalidate;
end;

procedure TCustomThemedToggleBox.SetReadOnly(const AValue: Boolean);
begin
  if FReadOnly = AValue then Exit;
  FReadOnly := AValue;
  Invalidate;
end;

procedure TCustomThemedToggleBox.SetShowBorder(const AValue: Boolean);
begin
  if FShowBorder = AValue then Exit;
  FShowBorder := AValue;
  Invalidate;
end;

procedure TCustomThemedToggleBox.SetShowFocusCue(const AValue: Boolean);
begin
  if FShowFocusCue = AValue then Exit;
  FShowFocusCue := AValue;
  Invalidate;
end;

procedure TCustomThemedToggleBox.SetFocusCueStyle(const AValue: TToggleFocusCueStyle);
begin
  if FFocusCueStyle = AValue then Exit;
  FFocusCueStyle := AValue;
  Invalidate;
end;

procedure TCustomThemedToggleBox.SetAnimate(const AValue: Boolean);
begin
  if FAnimate = AValue then Exit;
  FAnimate := AValue;
  if not FAnimate then
  begin
    FAnimationTimer.Enabled := False;
    if FChecked then FAnimationValue := 1 else FAnimationValue := 0;
  end;
  Invalidate;
end;


procedure TCustomThemedToggleBox.SetSynchronizeCheckedWithAction(const AValue: Boolean);
begin
  if FSynchronizeCheckedWithAction = AValue then Exit;
  FSynchronizeCheckedWithAction := AValue;
  if FSynchronizeCheckedWithAction then
    SynchronizeCheckedToAction;
end;

procedure TCustomThemedToggleBox.SynchronizeCheckedToAction;
var
  LAction: TCustomAction;
begin
  if not FSynchronizeCheckedWithAction or FSynchronizingAction or not (Action is TCustomAction) then
    Exit;
  LAction := TCustomAction(Action);
  if LAction.Checked = FChecked then
    Exit;
  FSynchronizingAction := True;
  try
    LAction.Checked := FChecked;
  finally
    FSynchronizingAction := False;
  end;
end;

procedure TCustomThemedToggleBox.ActionChange(Sender: TObject; CheckDefaults: Boolean);
var
  LAction: TCustomAction;
begin
  inherited ActionChange(Sender, CheckDefaults);
  if not FSynchronizeCheckedWithAction or FSynchronizingAction or not (Sender is TCustomAction) then
    Exit;
  LAction := TCustomAction(Sender);
  if FChecked = LAction.Checked then
    Exit;
  FSynchronizingAction := True;
  try
    ChangeChecked(LAction.Checked, tcsCode);
  finally
    FSynchronizingAction := False;
  end;
end;

procedure TCustomThemedToggleBox.SetTextMode(const AValue: TToggleTextMode);
begin
  if FTextMode = AValue then Exit;
  FTextMode := AValue;
  UpdateAutoSize;
  Invalidate;
end;

procedure TCustomThemedToggleBox.SetLabelPosition(const AValue: TToggleLabelPosition);
begin
  if FLabelPosition = AValue then Exit;
  FLabelPosition := AValue;
  UpdateAutoSize;
  Invalidate;
end;

procedure TCustomThemedToggleBox.SetSwitchAlignment(const AValue: TToggleSwitchAlignment);
begin
  if FSwitchAlignment = AValue then Exit;
  FSwitchAlignment := AValue;
  Invalidate;
end;

procedure TCustomThemedToggleBox.SetTrackWidth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 24 then LValue := 24;
  if FTrackWidth = LValue then Exit;
  FTrackWidth := LValue;
  UpdateAutoSize;
  Invalidate;
end;

procedure TCustomThemedToggleBox.SetTrackHeight(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 14 then LValue := 14;
  if FTrackHeight = LValue then Exit;
  FTrackHeight := LValue;
  UpdateAutoSize;
  Invalidate;
end;

procedure TCustomThemedToggleBox.SetSpacing(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 0 then LValue := 0;
  if FSpacing = LValue then Exit;
  FSpacing := LValue;
  UpdateAutoSize;
  Invalidate;
end;

procedure TCustomThemedToggleBox.SetOnText(const AValue: string);
begin
  if FOnText = AValue then Exit;
  FOnText := AValue;
  UpdateAutoSize;
  Invalidate;
end;

procedure TCustomThemedToggleBox.SetOffText(const AValue: string);
begin
  if FOffText = AValue then Exit;
  FOffText := AValue;
  UpdateAutoSize;
  Invalidate;
end;

procedure TCustomThemedToggleBox.SetOnBackColor(const AValue: TColor);
begin
  if FOnBackColor = AValue then Exit;
  FOnBackColor := AValue;
  Invalidate;
end;

procedure TCustomThemedToggleBox.SetOffBackColor(const AValue: TColor);
begin
  if FOffBackColor = AValue then Exit;
  FOffBackColor := AValue;
  Invalidate;
end;

procedure TCustomThemedToggleBox.SetThumbColor(const AValue: TColor);
begin
  if FThumbColor = AValue then Exit;
  FThumbColor := AValue;
  Invalidate;
end;

procedure TCustomThemedToggleBox.SetBorderColor(const AValue: TColor);
begin
  if FBorderColor = AValue then Exit;
  FBorderColor := AValue;
  Invalidate;
end;

function TCustomThemedToggleBox.GetShowStateText: Boolean;
begin
  Result := FTextMode <> ttmNone;
end;

procedure TCustomThemedToggleBox.SetShowStateText(const AValue: Boolean);
begin
  if AValue then
  begin
    if FTextMode = ttmNone then SetTextMode(ttmCustom);
  end
  else if FTextMode <> ttmNone then
    SetTextMode(ttmNone);
end;

function TCustomThemedToggleBox.GetCheckedText: string;
begin
  Result := FOnText;
end;

procedure TCustomThemedToggleBox.SetCheckedText(const AValue: string);
begin
  SetOnText(AValue);
end;

function TCustomThemedToggleBox.GetUncheckedText: string;
begin
  Result := FOffText;
end;

procedure TCustomThemedToggleBox.SetUncheckedText(const AValue: string);
begin
  SetOffText(AValue);
end;

function TCustomThemedToggleBox.StateText(const AChecked: Boolean): string;
begin
  case FTextMode of
    ttmOnOff: if AChecked then Result := SThemedToggleOn else Result := SThemedToggleOff;
    ttmYesNo: if AChecked then Result := SThemedToggleYes else Result := SThemedToggleNo;
    ttmIO: if AChecked then Result := SThemedToggleI else Result := SThemedToggleO;
    ttmCustom: if AChecked then Result := FOnText else Result := FOffText;
  else
    Result := '';
  end;
end;

procedure TCustomThemedToggleBox.DoCheckedChanging(const AOldValue, ANewValue: Boolean;
  const ASource: TToggleChangeSource; var AAllow: Boolean);
begin
  if Assigned(FOnCheckedChanging) then
    FOnCheckedChanging(Self, AOldValue, ANewValue, ASource, AAllow);
end;

procedure TCustomThemedToggleBox.DoCheckedChanged;
begin
  if Assigned(FOnCheckedChanged) then
    FOnCheckedChanged(Self);
end;

procedure TCustomThemedToggleBox.DoToggleClicked(const AOldValue, ANewValue: Boolean; const ASource: TToggleChangeSource);
begin
  if Assigned(FOnToggleClicked) then
    FOnToggleClicked(Self, AOldValue, ANewValue, ASource);
end;

procedure TCustomThemedToggleBox.Click;
var
  LSource: TToggleChangeSource;
begin
  LSource := FClickSource;
  FClickSource := tcsCode;
  ToggleByUser(LSource);
  inherited Click;
end;

procedure TCustomThemedToggleBox.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if not FHot then
  begin
    FHot := True;
    Invalidate;
  end;
end;

procedure TCustomThemedToggleBox.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if FHot or FPressed then
  begin
    FHot := False;
    FPressed := False;
    Invalidate;
  end;
end;

procedure TCustomThemedToggleBox.CMDialogChar(var Message: TCMDialogChar);
begin
  if Enabled and Vcl.Forms.IsAccel(Message.CharCode, Caption) then
  begin
    if CanFocus then SetFocus;
    FClickSource := tcsKeyboard;
    Click;
    Message.Result := 1;
    Exit;
  end;
  inherited;
end;

procedure TCustomThemedToggleBox.CMFontChanged(var Message: TMessage);
begin
  inherited;
  UpdateInnerFont;
  UpdateAutoSize;
  Invalidate;
end;

procedure TCustomThemedToggleBox.CMTextChanged(var Message: TMessage);
begin
  inherited;
  UpdateAutoSize;
  Invalidate;
end;

procedure TCustomThemedToggleBox.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  if not Enabled then
    FPressed := False;
  Invalidate;
end;

procedure TCustomThemedToggleBox.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button = mbLeft) and Enabled then
  begin
    if CanFocus then SetFocus;
    FClickSource := tcsMouse;
    FPressed := True;
    Invalidate;
  end;
end;

procedure TCustomThemedToggleBox.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FClickSource := tcsCode;
    if FPressed then
    begin
      FPressed := False;
      Invalidate;
    end;
  end;
  inherited MouseUp(Button, Shift, X, Y);
end;

procedure TCustomThemedToggleBox.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if Enabled and ((Key = VK_SPACE) or (Key = VK_RETURN)) then
  begin
    FClickSource := tcsKeyboard;
    Click;
    Key := 0;
  end;
end;

procedure TCustomThemedToggleBox.DoEnter;
begin
  inherited DoEnter;
  Invalidate;
end;

procedure TCustomThemedToggleBox.DoExit;
begin
  FPressed := False;
  FClickSource := tcsCode;
  inherited DoExit;
  Invalidate;
end;

procedure TCustomThemedToggleBox.Paint;
var
  LContext: TThemedToggleBoxRenderContext;
begin
  RenderCanvas.BeginRender(Canvas);
  try
    LContext.Bounds := ClientRect;
    LContext.Caption := Caption;
    LContext.OnText := StateText(True);
    LContext.OffText := StateText(False);
    LContext.Font := Font;
    LContext.InnerFont := FInnerFont;
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
    LContext.Enabled := Enabled;
    LContext.Hovered := FHot;
    LContext.Pressed := FPressed;
    LContext.Checked := FChecked;
    LContext.ReadOnly := FReadOnly;
    LContext.ShowBorder := FShowBorder;
    LContext.ShowFocusCue := FShowFocusCue;
    LContext.FocusCueStyle := FFocusCueStyle;
    LContext.TextMode := FTextMode;
    LContext.LabelPosition := FLabelPosition;
    LContext.SwitchAlignment := FSwitchAlignment;
    LContext.SwitchWidth := ScaleValue(FTrackWidth);
    LContext.SwitchWidthWithText := ScaleValue(FTrackWidthWithText);
    LContext.SwitchHeight := ScaleValue(Max(12, FTrackHeight - Ord(StyleMode = stCompact) * 4));
    LContext.PaddingSmall := ScaleValue(FPaddingSmall);
    LContext.PaddingText := ScaleValue(Max(0, FSpacing - Ord(StyleMode = stCompact) * 2));
    LContext.InnerOffset := ScaleValue(FInnerOffset);
    LContext.ThumbInset := ScaleValue(FThumbInset);
    LContext.AnimationValue := FAnimationValue;
    LContext.OnBackColor := FOnBackColor;
    LContext.OffBackColor := FOffBackColor;
    LContext.ThumbColor := FThumbColor;
    LContext.BorderColor := FBorderColor;
    LContext.Focused := Focused;
    LContext.RightToLeft := UseRightToLeftAlignment;
    TThemedToggleBoxRenderer.Render(RenderCanvas, LContext);
  finally
    RenderCanvas.EndRender;
  end;
end;

end.

{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.ToolButton;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.Types,
  System.UITypes,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Menus,
  Vcl.ImgList,
  NimbusForms.Theming.Types,
  NimbusForms.Controls.Types,
  NimbusForms.Controls.Base,
  NimbusForms.Rendering.ToolButton;

type
  TThemedToolButtonDropDownEvent = procedure(Sender: TObject; const APart: TThemedToolButtonPart) of object;

  TCustomThemedToolButton = class(TCustomNimbusControl)
  private
    FButtonStyle: TThemedToolButtonStyle;
    FHighlightStyle: TThemedToolButtonHighlightStyle;
    FImagePlacement: TThemedToolButtonImagePlacement;
    FDropDownMode: TThemedToolButtonDropDownMode;
    FTextAlign: TThemedContentAlignment;
    FImageAlign: TThemedContentAlignment;
    FContentPadding: TPadding;
    FDropDownMenu: TPopupMenu;
    FIcon: TIcon;
    FImages: TCustomImageList;
    FImageIndex: System.UITypes.TImageIndex;
    FImageChangeLink: TChangeLink;
    FImageListIcon: TIcon;
    FTextOffset: TPoint;
    FImageOffset: TPoint;
    FImageSize: Integer;
    FImageTextSpacing: Integer;
    FCornerRadius: Integer;
    FSplitButtonWidth: Integer;
    FMultiline: Boolean;
    FAutoEllipsis: Boolean;
    FCheckable: Boolean;
    FChecked: Boolean;
    FShowFocusRectangle: Boolean;
    FUseThemeAccent: Boolean;
    FCurrentColor: TThemeColor;
    FHot: Boolean;
    FPressed: Boolean;
    FDropDownHot: Boolean;
    FDropDownPressed: Boolean;
    FSpacePressed: Boolean;
    FInitialized: Boolean;
    FOnDropDownClick: TThemedToolButtonDropDownEvent;
    FOnCheckedChanged: TNotifyEvent;
    procedure SetButtonStyle(const AValue: TThemedToolButtonStyle);
    procedure SetHighlightStyle(const AValue: TThemedToolButtonHighlightStyle);
    procedure SetImagePlacement(const AValue: TThemedToolButtonImagePlacement);
    procedure SetDropDownMode(const AValue: TThemedToolButtonDropDownMode);
    procedure SetTextAlign(const AValue: TThemedContentAlignment);
    procedure SetImageAlign(const AValue: TThemedContentAlignment);
    procedure SetContentPadding(const AValue: TPadding);
    procedure ContentPaddingChanged(Sender: TObject);
    procedure SetDropDownMenu(const AValue: TPopupMenu);
    procedure SetIcon(const AValue: TIcon);
    procedure IconChanged(Sender: TObject);
    procedure SetImages(const AValue: TCustomImageList);
    procedure SetImageIndex(const AValue: System.UITypes.TImageIndex);
    procedure ImageListChanged(Sender: TObject);
    procedure RefreshImageListIcon;
    procedure SetTextOffset(const AValue: TPoint);
    procedure SetImageOffset(const AValue: TPoint);
    procedure SetImageSize(const AValue: Integer);
    procedure SetImageTextSpacing(const AValue: Integer);
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetSplitButtonWidth(const AValue: Integer);
    procedure SetMultiline(const AValue: Boolean);
    procedure SetAutoEllipsis(const AValue: Boolean);
    procedure SetCheckable(const AValue: Boolean);
    procedure SetChecked(const AValue: Boolean);
    procedure SetShowFocusRectangle(const AValue: Boolean);
    procedure SetUseThemeAccent(const AValue: Boolean);
    procedure SetCurrentColor(const AValue: TThemeColor);
    function CurrentIconHandle: HICON;
    function HitTest(const APoint: TPoint): TThemedToolButtonPart;
    procedure ExecuteDropDown(const APart: TThemedToolButtonPart);
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMDialogKey(var Message: TCMDialogKey); message CM_DIALOGKEY;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure WMCaptureChanged(var Message: TMessage); message WM_CAPTURECHANGED;
  protected
    procedure StyleModeChanged; override;
    function CanAutoSize(var NewWidth, NewHeight: Integer): Boolean; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Paint; override;
    procedure Click; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure DoDropDownClick(const APart: TThemedToolButtonPart); virtual;
    procedure DoCheckedChanged; virtual;
    property ButtonStyle: TThemedToolButtonStyle read FButtonStyle write SetButtonStyle default ttbsFlat;
    property HighlightStyle: TThemedToolButtonHighlightStyle read FHighlightStyle write SetHighlightStyle default ttbhsDelphiToolButton;
    property ImagePlacement: TThemedToolButtonImagePlacement read FImagePlacement write SetImagePlacement default ttbipLeft;
    property DropDownMode: TThemedToolButtonDropDownMode read FDropDownMode write SetDropDownMode default ttbddNone;
    property TextAlign: TThemedContentAlignment read FTextAlign write SetTextAlign default tcaMiddleCenter;
    property ImageAlign: TThemedContentAlignment read FImageAlign write SetImageAlign default tcaMiddleCenter;
    property ContentPadding: TPadding read FContentPadding write SetContentPadding;
    property DropDownMenu: TPopupMenu read FDropDownMenu write SetDropDownMenu;
    property Icon: TIcon read FIcon write SetIcon;
    property Images: TCustomImageList read FImages write SetImages;
    property ImageIndex: System.UITypes.TImageIndex read FImageIndex write SetImageIndex default -1;
    property ImageSize: Integer read FImageSize write SetImageSize default 16;
    property ImageTextSpacing: Integer read FImageTextSpacing write SetImageTextSpacing default 6;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 3;
    property SplitButtonWidth: Integer read FSplitButtonWidth write SetSplitButtonWidth default 20;
    property Multiline: Boolean read FMultiline write SetMultiline default False;
    property AutoEllipsis: Boolean read FAutoEllipsis write SetAutoEllipsis default True;
    property Checkable: Boolean read FCheckable write SetCheckable default False;
    property Checked: Boolean read FChecked write SetChecked default False;
    property ShowFocusRectangle: Boolean read FShowFocusRectangle write SetShowFocusRectangle default True;
    property UseThemeAccent: Boolean read FUseThemeAccent write SetUseThemeAccent default False;
    property CurrentColor: TThemeColor read FCurrentColor write SetCurrentColor default 0;
    property OnDropDownClick: TThemedToolButtonDropDownEvent read FOnDropDownClick write FOnDropDownClick;
    property OnCheckedChanged: TNotifyEvent read FOnCheckedChanged write FOnCheckedChanged;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure PerformClick;
    procedure PerformDropDownClick;
    procedure ShowDropDown;
    property IsHot: Boolean read FHot;
    property IsPressed: Boolean read FPressed;
    property IsDropDownHot: Boolean read FDropDownHot;
    property IsDropDownPressed: Boolean read FDropDownPressed;
    property TextOffset: TPoint read FTextOffset write SetTextOffset;
    property ImageOffset: TPoint read FImageOffset write SetImageOffset;
  end;

  TThemedToolButton = class(TCustomThemedToolButton)
  published
    property StyleMode;
    property Action;
    property Align;
    property Anchors;
    property AutoSize;
    property BiDiMode;
    property ButtonStyle;
    property HighlightStyle;
    property ImagePlacement;
    property DropDownMode;
    property TextAlign;
    property ImageAlign;
    property ContentPadding;
    property DropDownMenu;
    property Icon;
    property Images;
    property ImageIndex;
    property Caption;
    property ImageSize;
    property ImageTextSpacing;
    property CornerRadius;
    property SplitButtonWidth;
    property Multiline;
    property AutoEllipsis;
    property Checkable;
    property Checked;
    property ShowFocusRectangle;
    property UseThemeAccent;
    property CurrentColor;
    property Constraints;
    property Enabled;
    property Font;
    property Hint;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property OnDropDownClick;
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
  NimbusForms.Rendering.Types;

constructor TCustomThemedToolButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csCaptureMouse, csClickEvents];
  Width := 96;
  Height := 28;
  TabStop := True;
  Font.Name := 'Segoe UI';
  Font.Size := 9;
  FButtonStyle := ttbsFlat;
  FHighlightStyle := ttbhsDelphiToolButton;
  FImagePlacement := ttbipLeft;
  FDropDownMode := ttbddNone;
  FTextAlign := tcaMiddleCenter;
  FImageAlign := tcaMiddleCenter;
  FContentPadding := TPadding.Create(Self);
  FContentPadding.SetBounds(6, 3, 6, 3);
  FContentPadding.OnChange := ContentPaddingChanged;
  FIcon := TIcon.Create;
  FIcon.OnChange := IconChanged;
  FImageListIcon := TIcon.Create;
  FImageChangeLink := TChangeLink.Create;
  FImageChangeLink.OnChange := ImageListChanged;
  FImageIndex := -1;
  FImageSize := 16;
  FImageTextSpacing := 6;
  FCornerRadius := 3;
  FSplitButtonWidth := 20;
  FAutoEllipsis := True;
  FShowFocusRectangle := True;
  FInitialized := True;
end;

destructor TCustomThemedToolButton.Destroy;
begin
  FInitialized := False;
  if FImages <> nil then
  begin
    FImages.UnRegisterChanges(FImageChangeLink);
    FImages.RemoveFreeNotification(Self);
  end;
  if FDropDownMenu <> nil then FDropDownMenu.RemoveFreeNotification(Self);
  FImageChangeLink.Free;
  FImageListIcon.Free;
  FIcon.Free;
  FContentPadding.Free;
  inherited Destroy;
end;

procedure TCustomThemedToolButton.SetButtonStyle(const AValue: TThemedToolButtonStyle);
begin
  if FButtonStyle = AValue then Exit;
  FButtonStyle := AValue;
  Invalidate;
end;

procedure TCustomThemedToolButton.SetHighlightStyle(const AValue: TThemedToolButtonHighlightStyle);
begin
  if FHighlightStyle = AValue then Exit;
  FHighlightStyle := AValue;
  Invalidate;
end;

procedure TCustomThemedToolButton.SetImagePlacement(const AValue: TThemedToolButtonImagePlacement);
begin
  if FImagePlacement = AValue then Exit;
  FImagePlacement := AValue;
  AdjustSize;
  Invalidate;
end;

procedure TCustomThemedToolButton.SetDropDownMode(const AValue: TThemedToolButtonDropDownMode);
begin
  if FDropDownMode = AValue then Exit;
  FDropDownMode := AValue;
  FDropDownHot := False;
  FDropDownPressed := False;
  AdjustSize;
  Invalidate;
end;

procedure TCustomThemedToolButton.SetTextAlign(const AValue: TThemedContentAlignment);
begin
  if FTextAlign = AValue then Exit;
  FTextAlign := AValue;
  Invalidate;
end;

procedure TCustomThemedToolButton.SetImageAlign(const AValue: TThemedContentAlignment);
begin
  if FImageAlign = AValue then Exit;
  FImageAlign := AValue;
  Invalidate;
end;

procedure TCustomThemedToolButton.SetContentPadding(const AValue: TPadding);
begin
  if AValue <> nil then FContentPadding.Assign(AValue);
end;

procedure TCustomThemedToolButton.ContentPaddingChanged(Sender: TObject);
begin
  AdjustSize;
  Invalidate;
end;

procedure TCustomThemedToolButton.SetDropDownMenu(const AValue: TPopupMenu);
begin
  if FDropDownMenu = AValue then Exit;
  if FDropDownMenu <> nil then FDropDownMenu.RemoveFreeNotification(Self);
  FDropDownMenu := AValue;
  if FDropDownMenu <> nil then FDropDownMenu.FreeNotification(Self);
end;

procedure TCustomThemedToolButton.SetIcon(const AValue: TIcon);
begin
  if AValue = nil then FIcon.Handle := 0 else FIcon.Assign(AValue);
end;

procedure TCustomThemedToolButton.IconChanged(Sender: TObject);
begin
  AdjustSize;
  Invalidate;
end;

procedure TCustomThemedToolButton.SetImages(const AValue: TCustomImageList);
begin
  if FImages = AValue then Exit;
  if FImages <> nil then
  begin
    FImages.UnRegisterChanges(FImageChangeLink);
    FImages.RemoveFreeNotification(Self);
  end;
  FImages := AValue;
  if FImages <> nil then
  begin
    FImages.RegisterChanges(FImageChangeLink);
    FImages.FreeNotification(Self);
  end;
  RefreshImageListIcon;
end;

procedure TCustomThemedToolButton.SetImageIndex(const AValue: System.UITypes.TImageIndex);
begin
  if FImageIndex = AValue then Exit;
  FImageIndex := AValue;
  RefreshImageListIcon;
end;

procedure TCustomThemedToolButton.ImageListChanged(Sender: TObject);
begin
  RefreshImageListIcon;
end;

procedure TCustomThemedToolButton.RefreshImageListIcon;
begin
  FImageListIcon.Handle := 0;
  if (FImages <> nil) and (FImageIndex >= 0) and (FImageIndex < FImages.Count) then FImages.GetIcon(FImageIndex, FImageListIcon);
  AdjustSize;
  Invalidate;
end;

procedure TCustomThemedToolButton.SetTextOffset(const AValue: TPoint);
begin
  if FTextOffset = AValue then Exit;
  FTextOffset := AValue;
  Invalidate;
end;

procedure TCustomThemedToolButton.SetImageOffset(const AValue: TPoint);
begin
  if FImageOffset = AValue then Exit;
  FImageOffset := AValue;
  Invalidate;
end;

procedure TCustomThemedToolButton.SetImageSize(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(1, AValue);
  if FImageSize = LValue then Exit;
  FImageSize := LValue;
  AdjustSize;
  Invalidate;
end;

procedure TCustomThemedToolButton.SetImageTextSpacing(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(0, AValue);
  if FImageTextSpacing = LValue then Exit;
  FImageTextSpacing := LValue;
  AdjustSize;
  Invalidate;
end;

procedure TCustomThemedToolButton.SetCornerRadius(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(0, AValue);
  if FCornerRadius = LValue then Exit;
  FCornerRadius := LValue;
  Invalidate;
end;

procedure TCustomThemedToolButton.SetSplitButtonWidth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(10, AValue);
  if FSplitButtonWidth = LValue then Exit;
  FSplitButtonWidth := LValue;
  AdjustSize;
  Invalidate;
end;

procedure TCustomThemedToolButton.SetMultiline(const AValue: Boolean);
begin
  if FMultiline = AValue then Exit;
  FMultiline := AValue;
  AdjustSize;
  Invalidate;
end;

procedure TCustomThemedToolButton.SetAutoEllipsis(const AValue: Boolean);
begin
  if FAutoEllipsis = AValue then Exit;
  FAutoEllipsis := AValue;
  Invalidate;
end;

procedure TCustomThemedToolButton.SetCheckable(const AValue: Boolean);
begin
  if FCheckable = AValue then Exit;
  FCheckable := AValue;
  Invalidate;
end;

procedure TCustomThemedToolButton.SetChecked(const AValue: Boolean);
begin
  if FChecked = AValue then Exit;
  FChecked := AValue;
  DoCheckedChanged;
  Invalidate;
end;

procedure TCustomThemedToolButton.SetShowFocusRectangle(const AValue: Boolean);
begin
  if FShowFocusRectangle = AValue then Exit;
  FShowFocusRectangle := AValue;
  Invalidate;
end;

procedure TCustomThemedToolButton.SetUseThemeAccent(const AValue: Boolean);
begin
  if FUseThemeAccent = AValue then Exit;
  FUseThemeAccent := AValue;
  Invalidate;
end;

procedure TCustomThemedToolButton.SetCurrentColor(const AValue: TThemeColor);
begin
  if FCurrentColor = AValue then Exit;
  FCurrentColor := AValue;
  Invalidate;
end;

function TCustomThemedToolButton.CurrentIconHandle: HICON;
begin
  if not FIcon.Empty then Result := FIcon.Handle else if not FImageListIcon.Empty then Result := FImageListIcon.Handle else Result := 0;
end;

function TCustomThemedToolButton.HitTest(const APoint: TPoint): TThemedToolButtonPart;
var
  LWidth: Integer;
  LRect: TRect;
begin
  Result := ttbpNone;
  if (APoint.X < 0) or (APoint.Y < 0) or (APoint.X >= Width) or (APoint.Y >= Height) then Exit;
  if FDropDownMode = ttbddSplit then
  begin
    LWidth := Min(ScaleValue(FSplitButtonWidth), Max(1, Width div 2));
    if BiDiMode = bdRightToLeft then LRect := Rect(0, 0, LWidth, Height) else LRect := Rect(Width - LWidth, 0, Width, Height);
    if PtInRect(LRect, APoint) then Exit(ttbpDropDown);
  end;
  Result := ttbpMain;
end;

procedure TCustomThemedToolButton.ExecuteDropDown(const APart: TThemedToolButtonPart);
var
  LPoint: TPoint;
begin
  if not Enabled or (FDropDownMode = ttbddNone) then Exit;
  DoDropDownClick(APart);
  if FDropDownMenu = nil then Exit;
  FDropDownPressed := True;
  Invalidate;
  if BiDiMode = bdRightToLeft then LPoint := ClientToScreen(Point(Width, Height)) else LPoint := ClientToScreen(Point(0, Height));
  try
    FDropDownMenu.Popup(LPoint.X, LPoint.Y);
  finally
    FDropDownPressed := False;
    Invalidate;
  end;
end;

procedure TCustomThemedToolButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if not FHot then
  begin
    FHot := True;
    Invalidate;
  end;
end;

procedure TCustomThemedToolButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if FHot or FDropDownHot then
  begin
    FHot := False;
    FDropDownHot := False;
    if not MouseCapture then
    begin
      FPressed := False;
      FDropDownPressed := False;
    end;
    Invalidate;
  end;
end;

procedure TCustomThemedToolButton.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  if not Enabled then
  begin
    FSpacePressed := False;
    FPressed := False;
    FDropDownPressed := False;
    FDropDownHot := False;
    if MouseCapture then MouseCapture := False;
  end;
  Invalidate;
end;

procedure TCustomThemedToolButton.CMFontChanged(var Message: TMessage);
begin
  inherited;
  if FInitialized then AdjustSize;
  Invalidate;
end;

procedure TCustomThemedToolButton.CMDialogKey(var Message: TCMDialogKey);
var
  LShift: TShiftState;
begin
  LShift := KeyDataToShiftState(Message.KeyData);
  if Enabled and Focused and (Message.CharCode = VK_RETURN) and (LShift = []) then
  begin
    PerformClick;
    Message.Result := 1;
    Exit;
  end;
  if Enabled and (FDropDownMode <> ttbddNone) and (Message.CharCode = VK_DOWN) and (ssAlt in LShift) then
  begin
    PerformDropDownClick;
    Message.Result := 1;
    Exit;
  end;
  inherited;
end;

procedure TCustomThemedToolButton.CMTextChanged(var Message: TMessage);
begin
  inherited;
  AdjustSize;
  Invalidate;
end;

procedure TCustomThemedToolButton.WMCaptureChanged(var Message: TMessage);
begin
  inherited;
  if not MouseCapture and (FPressed or FDropDownPressed) then
  begin
    FPressed := False;
    FDropDownPressed := False;
    Invalidate;
  end;
end;

function TCustomThemedToolButton.CanAutoSize(var NewWidth, NewHeight: Integer): Boolean;
var
  LTextSize: TSize;
  LWidth, LHeight, LImage, LSpacing: Integer;
  LHasImage: Boolean;
begin
  if not FInitialized then
  begin
    Result := inherited CanAutoSize(NewWidth, NewHeight);
    Exit;
  end;
  Result := True;
  if Parent = nil then Exit;
  RenderCanvas.BeginRender(Canvas);
  try
    if Caption <> '' then LTextSize := RenderCanvas.MeasureText(Caption, Font, 10000, [ntfSingleLine, ntfNoPrefix]) else LTextSize := TSize.Create(0, 0);
    LWidth := ScaleValue(FContentPadding.Left + FContentPadding.Right) + LTextSize.cx;
    LHeight := ScaleValue(FContentPadding.Top + FContentPadding.Bottom) + LTextSize.cy;
    LHasImage := CurrentIconHandle <> 0;
    LImage := ScaleValue(FImageSize);
    LSpacing := ScaleValue(FImageTextSpacing);
    if LHasImage then
    begin
      if Caption = '' then
      begin
        Inc(LWidth, LImage);
        LHeight := Max(LHeight, ScaleValue(FContentPadding.Top + FContentPadding.Bottom) + LImage);
      end
      else if FImagePlacement in [ttbipTop, ttbipBottom] then
      begin
        LWidth := Max(LWidth, ScaleValue(FContentPadding.Left + FContentPadding.Right) + LImage);
        Inc(LHeight, LImage + LSpacing);
      end
      else if FImagePlacement <> ttbipOverlay then
      begin
        Inc(LWidth, LImage + LSpacing);
        LHeight := Max(LHeight, ScaleValue(FContentPadding.Top + FContentPadding.Bottom) + LImage);
      end;
    end;
    if FDropDownMode = ttbddSplit then Inc(LWidth, ScaleValue(FSplitButtonWidth)) else if FDropDownMode = ttbddArrow then Inc(LWidth, ScaleValue(18));
    if StyleMode = stCompact then
    begin
      Dec(LWidth, ScaleValue(4));
      Dec(LHeight, ScaleValue(2));
    end;
    NewWidth := Max(ScaleValue(24), LWidth);
    NewHeight := Max(ScaleValue(24), LHeight);
  finally
    RenderCanvas.EndRender;
  end;
end;

procedure TCustomThemedToolButton.StyleModeChanged;
begin
  inherited StyleModeChanged;
  UpdateStyleHeight(28, 24);
  if AutoSize then AdjustSize;
end;

procedure TCustomThemedToolButton.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation <> opRemove then Exit;
  if AComponent = FDropDownMenu then SetDropDownMenu(nil);
  if AComponent = FImages then SetImages(nil);
end;

procedure TCustomThemedToolButton.Paint;
var
  LContext: TThemedToolButtonRenderContext;
begin
  RenderCanvas.BeginRender(Canvas);
  try
    LContext := System.Default(TThemedToolButtonRenderContext);
    LContext.Bounds := ClientRect;
    LContext.Caption := Caption;
    LContext.Font := Font;
    LContext.Palette := Palette;
    LContext.IconHandle := CurrentIconHandle;
    LContext.ButtonStyle := FButtonStyle;
    LContext.HighlightStyle := FHighlightStyle;
    LContext.ImagePlacement := FImagePlacement;
    LContext.DropDownMode := FDropDownMode;
    LContext.TextAlign := FTextAlign;
    LContext.ImageAlign := FImageAlign;
    LContext.PaddingLeft := Max(0, FContentPadding.Left - Ord(StyleMode = stCompact) * 2);
    LContext.PaddingTop := Max(0, FContentPadding.Top - Ord(StyleMode = stCompact) * 1);
    LContext.PaddingRight := Max(0, FContentPadding.Right - Ord(StyleMode = stCompact) * 2);
    LContext.PaddingBottom := Max(0, FContentPadding.Bottom - Ord(StyleMode = stCompact) * 1);
    LContext.TextOffset := FTextOffset;
    LContext.ImageOffset := FImageOffset;
    LContext.ImageSize := FImageSize;
    LContext.ImageTextSpacing := FImageTextSpacing;
    LContext.CornerRadius := FCornerRadius;
    LContext.SplitButtonWidth := FSplitButtonWidth;
    LContext.PPI := CurrentPPI;
    LContext.CurrentColor := FCurrentColor;
    LContext.Enabled := Enabled;
    LContext.Hot := FHot;
    LContext.Pressed := FPressed;
    LContext.DropDownHot := FDropDownHot;
    LContext.DropDownPressed := FDropDownPressed;
    LContext.Checkable := FCheckable;
    LContext.Checked := FChecked;
    LContext.Focused := Focused;
    LContext.ShowFocusRectangle := FShowFocusRectangle;
    LContext.Multiline := FMultiline;
    LContext.AutoEllipsis := FAutoEllipsis;
    LContext.UseThemeAccent := FUseThemeAccent;
    LContext.RightToLeft := BiDiMode = bdRightToLeft;
    TThemedToolButtonRenderer.Render(RenderCanvas, LContext);
  finally
    RenderCanvas.EndRender;
  end;
end;

procedure TCustomThemedToolButton.Click;
begin
  if not Enabled then Exit;
  if FCheckable then Checked := not Checked;
  inherited Click;
end;

procedure TCustomThemedToolButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LPart: TThemedToolButtonPart;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button <> mbLeft) or not Enabled then Exit;
  if CanFocus then SetFocus;
  LPart := HitTest(Point(X, Y));
  if LPart = ttbpDropDown then FDropDownPressed := True else if LPart = ttbpMain then FPressed := True;
  if LPart <> ttbpNone then MouseCapture := True;
  Invalidate;
end;

procedure TCustomThemedToolButton.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LDropHot: Boolean;
begin
  inherited MouseMove(Shift, X, Y);
  LDropHot := Enabled and (HitTest(Point(X, Y)) = ttbpDropDown);
  if FDropDownHot <> LDropHot then
  begin
    FDropDownHot := LDropHot;
    Invalidate;
  end;
end;

procedure TCustomThemedToolButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LMainPressed, LDropPressed: Boolean;
  LPart: TThemedToolButtonPart;
begin
  inherited MouseUp(Button, Shift, X, Y);
  if Button <> mbLeft then Exit;
  LMainPressed := FPressed;
  LDropPressed := FDropDownPressed;
  LPart := HitTest(Point(X, Y));
  FPressed := False;
  FDropDownPressed := False;
  if MouseCapture then MouseCapture := False;
  Invalidate;
  if not Enabled then Exit;
  if LDropPressed and (LPart = ttbpDropDown) then
  begin
    ExecuteDropDown(ttbpDropDown);
    Exit;
  end;
  if LMainPressed and (LPart = ttbpMain) then
  begin
    if FDropDownMode = ttbddArrow then ExecuteDropDown(ttbpMain) else PerformClick;
  end;
end;

procedure TCustomThemedToolButton.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if not Enabled then Exit;
  if (Key = VK_SPACE) and not FSpacePressed then
  begin
    FSpacePressed := True;
    FPressed := True;
    Invalidate;
    Key := 0;
  end
  else if (FDropDownMode <> ttbddNone) and ((Key = VK_F4) or ((Key = VK_DOWN) and (ssAlt in Shift))) then
  begin
    PerformDropDownClick;
    Key := 0;
  end;
end;

procedure TCustomThemedToolButton.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited KeyUp(Key, Shift);
  if (Key = VK_SPACE) and FSpacePressed then
  begin
    FSpacePressed := False;
    FPressed := False;
    Invalidate;
    PerformClick;
    Key := 0;
  end;
end;

procedure TCustomThemedToolButton.DoEnter;
begin
  inherited DoEnter;
  Invalidate;
end;

procedure TCustomThemedToolButton.DoExit;
begin
  FSpacePressed := False;
  FPressed := False;
  FDropDownPressed := False;
  inherited DoExit;
  Invalidate;
end;

procedure TCustomThemedToolButton.DoDropDownClick(const APart: TThemedToolButtonPart);
begin
  if Assigned(FOnDropDownClick) then FOnDropDownClick(Self, APart);
end;

procedure TCustomThemedToolButton.DoCheckedChanged;
begin
  if Assigned(FOnCheckedChanged) then FOnCheckedChanged(Self);
end;

procedure TCustomThemedToolButton.PerformClick;
begin
  if Enabled then Click;
end;

procedure TCustomThemedToolButton.PerformDropDownClick;
begin
  ExecuteDropDown(ttbpDropDown);
end;

procedure TCustomThemedToolButton.ShowDropDown;
begin
  PerformDropDownClick;
end;

end.

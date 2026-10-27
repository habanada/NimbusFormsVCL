{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.SplitButton;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.Types,
  System.UITypes,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Forms,
  Vcl.Menus,
  Vcl.ImgList,
  NimbusForms.Controls.Types,
  NimbusForms.Controls.Base,
  NimbusForms.Rendering.SplitButton;

type
  TThemedSplitButtonCancelEvent = procedure(Sender: TObject; var ACancel: Boolean) of object;

  TCustomThemedSplitButton = class(TCustomNimbusControl)
  private
    FSplitWidth: Integer;
    FHoverMain: Boolean;
    FHoverSplit: Boolean;
    FPressedMain: Boolean;
    FPressedSplit: Boolean;
    FSpacePressed: Boolean;
    FDropDownMenu: TPopupMenu;
    FDropDownAction: TBasicAction;
    FIcon: TIcon;
    FImages: TCustomImageList;
    FImageIndex: System.UITypes.TImageIndex;
    FImageChangeLink: TChangeLink;
    FImageListIcon: TIcon;
    FDefault: Boolean;
    FCancel: Boolean;
    FModalResult: TModalResult;
    FOnDropDownClick: TNotifyEvent;
    FOnDropDownOpening: TThemedSplitButtonCancelEvent;
    FOnDropDownOpened: TNotifyEvent;
    FOnDropDownClosed: TNotifyEvent;
    procedure SetSplitWidth(const AValue: Integer);
    procedure SetDropDownMenu(const AValue: TPopupMenu);
    procedure SetDropDownAction(const AValue: TBasicAction);
    procedure SetIcon(const AValue: TIcon);
    procedure IconChanged(Sender: TObject);
    procedure SetImages(const AValue: TCustomImageList);
    procedure SetImageIndex(const AValue: System.UITypes.TImageIndex);
    procedure ImageListChanged(Sender: TObject);
    procedure RefreshImageListIcon;
    procedure SetDefault(const AValue: Boolean);
    procedure SetCancel(const AValue: Boolean);
    function CurrentIconHandle: HICON;
    function CurrentIconWidth: Integer;
    function CurrentIconHeight: Integer;
    function GetMainRect: TRect;
    function GetSplitRect: TRect;
    function IsSplitPoint(const APoint: TPoint): Boolean;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
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
    function DoDropDownOpening: Boolean; virtual;
    procedure DoDropDownClick; virtual;
    property SplitWidth: Integer read FSplitWidth write SetSplitWidth default 24;
    property DropDownMenu: TPopupMenu read FDropDownMenu write SetDropDownMenu;
    property DropDownAction: TBasicAction read FDropDownAction write SetDropDownAction;
    property Icon: TIcon read FIcon write SetIcon;
    property Images: TCustomImageList read FImages write SetImages;
    property ImageIndex: System.UITypes.TImageIndex read FImageIndex write SetImageIndex default -1;
    property Default: Boolean read FDefault write SetDefault default False;
    property Cancel: Boolean read FCancel write SetCancel default False;
    property ModalResult: TModalResult read FModalResult write FModalResult default 0;
    property OnDropDownClick: TNotifyEvent read FOnDropDownClick write FOnDropDownClick;
    property OnDropDownOpening: TThemedSplitButtonCancelEvent read FOnDropDownOpening write FOnDropDownOpening;
    property OnDropDownOpened: TNotifyEvent read FOnDropDownOpened write FOnDropDownOpened;
    property OnDropDownClosed: TNotifyEvent read FOnDropDownClosed write FOnDropDownClosed;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure BindAction(const AAction: TBasicAction);
    procedure UnbindAction;
    procedure SyncAction;
    procedure ShowDropDown;
    procedure PerformClick;
    property IsMainHot: Boolean read FHoverMain;
    property IsSplitHot: Boolean read FHoverSplit;
    property IsMainPressed: Boolean read FPressedMain;
    property IsSplitPressed: Boolean read FPressedSplit;
  end;

  TThemedSplitButton = class(TCustomThemedSplitButton)
  published
    property StyleMode;
    property Action;
    property Align;
    property Anchors;
    property AutoSize;
    property BiDiMode;
    property Caption;
    property Constraints;
    property Default;
    property Cancel;
    property DropDownAction;
    property DropDownMenu;
    property Enabled;
    property Font;
    property Icon;
    property Images;
    property ImageIndex;
    property ModalResult;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property SplitWidth;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnDropDownClick;
    property OnDropDownOpening;
    property OnDropDownOpened;
    property OnDropDownClosed;
  end;

implementation

uses
  System.Math,
  NimbusForms.Rendering.Types;

constructor TCustomThemedSplitButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csCaptureMouse, csClickEvents];
  Width := 110;
  Height := 34;
  Constraints.MinWidth := 40;
  Constraints.MinHeight := 24;
  TabStop := True;
  Font.Name := 'Segoe UI';
  Font.Size := 9;
  FSplitWidth := 24;
  FImageIndex := -1;
  FIcon := TIcon.Create;
  FIcon.OnChange := IconChanged;
  FImageListIcon := TIcon.Create;
  FImageChangeLink := TChangeLink.Create;
  FImageChangeLink.OnChange := ImageListChanged;
end;

destructor TCustomThemedSplitButton.Destroy;
begin
  if FImages <> nil then
  begin
    FImages.UnRegisterChanges(FImageChangeLink);
    FImages.RemoveFreeNotification(Self);
  end;
  if FDropDownMenu <> nil then FDropDownMenu.RemoveFreeNotification(Self);
  if FDropDownAction <> nil then FDropDownAction.RemoveFreeNotification(Self);
  FImageChangeLink.Free;
  FImageListIcon.Free;
  FIcon.Free;
  inherited Destroy;
end;

procedure TCustomThemedSplitButton.SetSplitWidth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(1, AValue);
  if FSplitWidth = LValue then Exit;
  FSplitWidth := LValue;
  AdjustSize;
  Invalidate;
end;

procedure TCustomThemedSplitButton.SetDropDownMenu(const AValue: TPopupMenu);
begin
  if FDropDownMenu = AValue then Exit;
  if FDropDownMenu <> nil then FDropDownMenu.RemoveFreeNotification(Self);
  FDropDownMenu := AValue;
  if FDropDownMenu <> nil then FDropDownMenu.FreeNotification(Self);
end;

procedure TCustomThemedSplitButton.SetDropDownAction(const AValue: TBasicAction);
begin
  if FDropDownAction = AValue then Exit;
  if FDropDownAction <> nil then FDropDownAction.RemoveFreeNotification(Self);
  FDropDownAction := AValue;
  if FDropDownAction <> nil then FDropDownAction.FreeNotification(Self);
end;

procedure TCustomThemedSplitButton.SetIcon(const AValue: TIcon);
begin
  FIcon.Assign(AValue);
end;

procedure TCustomThemedSplitButton.IconChanged(Sender: TObject);
begin
  AdjustSize;
  Invalidate;
end;

procedure TCustomThemedSplitButton.SetImages(const AValue: TCustomImageList);
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

procedure TCustomThemedSplitButton.SetImageIndex(const AValue: System.UITypes.TImageIndex);
begin
  if FImageIndex = AValue then Exit;
  FImageIndex := AValue;
  RefreshImageListIcon;
end;

procedure TCustomThemedSplitButton.ImageListChanged(Sender: TObject);
begin
  RefreshImageListIcon;
end;

procedure TCustomThemedSplitButton.RefreshImageListIcon;
begin
  FImageListIcon.Handle := 0;
  if (FImages <> nil) and (FImageIndex >= 0) and (FImageIndex < FImages.Count) then FImages.GetIcon(FImageIndex, FImageListIcon);
  AdjustSize;
  Invalidate;
end;

procedure TCustomThemedSplitButton.SetDefault(const AValue: Boolean);
begin
  if FDefault = AValue then Exit;
  FDefault := AValue;
  Invalidate;
end;

procedure TCustomThemedSplitButton.SetCancel(const AValue: Boolean);
begin
  FCancel := AValue;
end;

function TCustomThemedSplitButton.CurrentIconHandle: HICON;
begin
  if not FIcon.Empty then Result := FIcon.Handle else if not FImageListIcon.Empty then Result := FImageListIcon.Handle else Result := 0;
end;

function TCustomThemedSplitButton.CurrentIconWidth: Integer;
begin
  if not FIcon.Empty then Result := FIcon.Width else if not FImageListIcon.Empty then Result := FImageListIcon.Width else Result := 0;
end;

function TCustomThemedSplitButton.CurrentIconHeight: Integer;
begin
  if not FIcon.Empty then Result := FIcon.Height else if not FImageListIcon.Empty then Result := FImageListIcon.Height else Result := 0;
end;

function TCustomThemedSplitButton.GetMainRect: TRect;
var
  LSplitWidth: Integer;
begin
  LSplitWidth := Min(Width, ScaleValue(Max(12, FSplitWidth - Ord(StyleMode = stCompact) * 4)));
  Result := Rect(0, 0, Max(0, Width - LSplitWidth), Height);
end;

function TCustomThemedSplitButton.GetSplitRect: TRect;
var
  LSplitWidth: Integer;
begin
  LSplitWidth := Min(Width, ScaleValue(Max(12, FSplitWidth - Ord(StyleMode = stCompact) * 4)));
  Result := Rect(Max(0, Width - LSplitWidth), 0, Width, Height);
end;

function TCustomThemedSplitButton.IsSplitPoint(const APoint: TPoint): Boolean;
begin
  Result := PtInRect(GetSplitRect, APoint);
end;

function TCustomThemedSplitButton.CanAutoSize(var NewWidth, NewHeight: Integer): Boolean;
var
  LTextSize: TSize;
  LContentWidth, LContentHeight: Integer;
begin
  Result := True;
  if Parent = nil then Exit;
  RenderCanvas.BeginRender(Canvas);
  try
    LTextSize := RenderCanvas.MeasureText(Caption, Font, 10000, [ntfSingleLine]);
  finally
    RenderCanvas.EndRender;
  end;
  LContentWidth := Max(LTextSize.cx, ScaleValue(CurrentIconWidth));
  LContentHeight := Max(LTextSize.cy, ScaleValue(CurrentIconHeight));
  NewWidth := Max(ScaleValue(40), LContentWidth + ScaleValue(4) + ScaleValue(Max(12, FSplitWidth - Ord(StyleMode = stCompact) * 4)));
  NewHeight := Max(ScaleValue(24), LContentHeight + ScaleValue(4));
end;

procedure TCustomThemedSplitButton.StyleModeChanged;
begin
  inherited StyleModeChanged;
  UpdateStyleHeight(34, 26);
  if AutoSize then AdjustSize;
end;

procedure TCustomThemedSplitButton.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation <> opRemove then Exit;
  if AComponent = FDropDownMenu then SetDropDownMenu(nil);
  if AComponent = FDropDownAction then SetDropDownAction(nil);
  if AComponent = FImages then SetImages(nil);
end;

procedure TCustomThemedSplitButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  FHoverMain := False;
  FHoverSplit := False;
  if not MouseCapture then FPressedMain := False;
  Invalidate;
end;

procedure TCustomThemedSplitButton.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  if not Enabled then
  begin
    FHoverMain := False;
    FHoverSplit := False;
    FPressedMain := False;
    FPressedSplit := False;
    FSpacePressed := False;
    if MouseCapture then MouseCapture := False;
  end;
  Invalidate;
end;

procedure TCustomThemedSplitButton.CMDialogChar(var Message: TCMDialogChar);
begin
  if Enabled and Vcl.Forms.IsAccel(Message.CharCode, Caption) then
  begin
    if CanFocus then SetFocus;
    PerformClick;
    Message.Result := 1;
    Exit;
  end;
  inherited;
end;

procedure TCustomThemedSplitButton.CMDialogKey(var Message: TCMDialogKey);
var
  LShift: TShiftState;
begin
  LShift := KeyDataToShiftState(Message.KeyData);
  if Enabled and (LShift = []) and (((Message.CharCode = VK_RETURN) and (Focused or FDefault)) or ((Message.CharCode = VK_ESCAPE) and FCancel)) then
  begin
    PerformClick;
    Message.Result := 1;
    Exit;
  end;
  inherited;
end;

procedure TCustomThemedSplitButton.CMTextChanged(var Message: TMessage);
begin
  inherited;
  AdjustSize;
  Invalidate;
end;

procedure TCustomThemedSplitButton.WMCaptureChanged(var Message: TMessage);
begin
  inherited;
  if not MouseCapture and FPressedMain then
  begin
    FPressedMain := False;
    Invalidate;
  end;
end;

procedure TCustomThemedSplitButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button <> mbLeft) or not Enabled then Exit;
  if CanFocus then SetFocus;
  if IsSplitPoint(Point(X, Y)) then
  begin
    FPressedSplit := True;
    Invalidate;
    ShowDropDown;
  end
  else
  begin
    FPressedMain := True;
    MouseCapture := True;
    Invalidate;
  end;
end;

procedure TCustomThemedSplitButton.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LSplit, LMain: Boolean;
begin
  inherited MouseMove(Shift, X, Y);
  LSplit := IsSplitPoint(Point(X, Y));
  LMain := not LSplit and PtInRect(ClientRect, Point(X, Y));
  if (FHoverSplit <> LSplit) or (FHoverMain <> LMain) then
  begin
    FHoverSplit := LSplit;
    FHoverMain := LMain;
    Invalidate;
  end;
end;

procedure TCustomThemedSplitButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LPressedMain: Boolean;
begin
  LPressedMain := FPressedMain;
  FPressedMain := False;
  if MouseCapture then MouseCapture := False;
  Invalidate;
  inherited MouseUp(Button, Shift, X, Y);
  if (Button = mbLeft) and Enabled and LPressedMain and not IsSplitPoint(Point(X, Y)) and PtInRect(ClientRect, Point(X, Y)) then PerformClick;
end;

procedure TCustomThemedSplitButton.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if not Enabled then Exit;
  if (Key = VK_SPACE) and not FSpacePressed then
  begin
    FSpacePressed := True;
    FPressedMain := True;
    Invalidate;
    Key := 0;
  end
  else if (Key = VK_F4) or ((Key = VK_DOWN) and (ssAlt in Shift)) then
  begin
    ShowDropDown;
    Key := 0;
  end;
end;

procedure TCustomThemedSplitButton.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited KeyUp(Key, Shift);
  if (Key = VK_SPACE) and FSpacePressed then
  begin
    FSpacePressed := False;
    FPressedMain := False;
    Invalidate;
    PerformClick;
    Key := 0;
  end;
end;

procedure TCustomThemedSplitButton.DoEnter;
begin
  inherited DoEnter;
  Invalidate;
end;

procedure TCustomThemedSplitButton.DoExit;
begin
  FSpacePressed := False;
  FPressedMain := False;
  inherited DoExit;
  Invalidate;
end;

function TCustomThemedSplitButton.DoDropDownOpening: Boolean;
var
  LCancel: Boolean;
begin
  LCancel := False;
  if Assigned(FOnDropDownOpening) then FOnDropDownOpening(Self, LCancel);
  Result := not LCancel;
end;

procedure TCustomThemedSplitButton.DoDropDownClick;
begin
  if Assigned(FOnDropDownClick) then FOnDropDownClick(Self);
end;

procedure TCustomThemedSplitButton.BindAction(const AAction: TBasicAction);
begin
  Action := AAction;
end;

procedure TCustomThemedSplitButton.UnbindAction;
begin
  Action := nil;
end;

procedure TCustomThemedSplitButton.SyncAction;
begin
  InitiateAction;
end;

procedure TCustomThemedSplitButton.ShowDropDown;
var
  LPoint: TPoint;
begin
  if not Enabled or not DoDropDownOpening then
  begin
    FPressedSplit := False;
    Invalidate;
    Exit;
  end;
  DoDropDownClick;
  if FDropDownAction <> nil then FDropDownAction.Execute;
  if FDropDownMenu <> nil then
  begin
    LPoint := ClientToScreen(Point(0, Height));
    if Assigned(FOnDropDownOpened) then FOnDropDownOpened(Self);
    try
      FDropDownMenu.Popup(LPoint.X, LPoint.Y);
    finally
      if Assigned(FOnDropDownClosed) then FOnDropDownClosed(Self);
    end;
  end;
  FPressedSplit := False;
  Invalidate;
end;

procedure TCustomThemedSplitButton.PerformClick;
begin
  if Enabled then Click;
end;

procedure TCustomThemedSplitButton.Click;
var
  LForm: TCustomForm;
begin
  if not Enabled then Exit;
  if FModalResult <> mrNone then
  begin
    LForm := GetParentForm(Self);
    if LForm <> nil then LForm.ModalResult := FModalResult;
  end;
  inherited Click;
end;

procedure TCustomThemedSplitButton.Paint;
var
  LContext: TThemedSplitButtonRenderContext;
begin
  RenderCanvas.BeginRender(Canvas);
  try
    LContext := System.Default(TThemedSplitButtonRenderContext);
    LContext.Bounds := ClientRect;
    LContext.MainBounds := GetMainRect;
    LContext.SplitBounds := GetSplitRect;
    LContext.Caption := Caption;
    LContext.Font := Font;
    LContext.Palette := Palette;
    LContext.IconHandle := CurrentIconHandle;
    LContext.IconWidth := ScaleValue(CurrentIconWidth);
    LContext.IconHeight := ScaleValue(CurrentIconHeight);
    LContext.ArrowWidth := ScaleValue(8);
    LContext.ArrowHeight := ScaleValue(4);
    LContext.TextPadding := ScaleValue(2 - Ord(StyleMode = stCompact));
    LContext.FocusPadding := ScaleValue(4 - Ord(StyleMode = stCompact));
    LContext.Enabled := Enabled;
    LContext.HoverMain := FHoverMain;
    LContext.HoverSplit := FHoverSplit;
    LContext.PressedMain := FPressedMain;
    LContext.PressedSplit := FPressedSplit;
    LContext.Focused := Focused;
    LContext.RightToLeft := UseRightToLeftReading;
    TThemedSplitButtonRenderer.Render(RenderCanvas, LContext);
  finally
    RenderCanvas.EndRender;
  end;
end;

end.

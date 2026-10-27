{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.NotificationBar;

interface

uses Winapi.Messages, System.Classes, System.Types, System.SysUtils, Vcl.Controls, Vcl.Graphics,
  Vcl.ExtCtrls, NimbusForms.Controls.Base, NimbusForms.Controls.NotificationBar.Types,
  NimbusForms.Rendering.NotificationBar;

type
  TCustomThemedIdeNotificationBar = class(TCustomNimbusControl)
  private
    FMessages: TThemedIdeNotificationMessages;
    FTimer: TTimer;
    FViews: TNimbusNotificationViews;
    FDisplayMode: TNimbusNotificationDisplayMode;
    FCarouselIndex, FMaxStackItems: Integer;
    FShowCloseButton, FShowCountdown, FMultiline, FCompactMode, FAutoHeight: Boolean;
    FDirty, FUpdating: Boolean;
    FHotView, FHotAction, FFocusView, FFocusAction, FPressedView, FPressedAction: Integer;
    FPressedActionID: Integer;
    FHoveredLink, FPressedLink, FPressedID: string;
    FOnDismissed, FOnExpired: TNimbusNotificationDismissEvent;
    FOnClosing: TNimbusNotificationClosingEvent;
    FOnAction: TNimbusNotificationActionEvent;
    FOnLinkClicked: TNimbusNotificationLinkEvent;
    FOnNavigation: TNimbusNotificationNavigationEvent;
    function GetCurrentMessageID: string;
    procedure DoNavigation;
    procedure MessagesChanged(Sender: TObject);
    procedure TimerTick(Sender: TObject);
    procedure EnsureLayout;
    procedure Hit(const P: TPoint; out AView, AAction: Integer; out ALink: string);
    procedure Activate(const AView, AAction: Integer; const ALink: string);
    procedure MoveFocus(const AForward: Boolean);
    procedure SetMessages(const AValue: TThemedIdeNotificationMessages);
    procedure SetDisplayMode(const AValue: TNimbusNotificationDisplayMode);
    procedure SetMaxStackItems(const AValue: Integer);
    procedure SetShowCloseButton(const AValue: Boolean);
    procedure SetShowCountdown(const AValue: Boolean);
    procedure SetMultiline(const AValue: Boolean);
    procedure SetCompactMode(const AValue: Boolean);
    procedure SetAutoHeight(const AValue: Boolean);
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMCaptureChanged(var Message: TMessage); message WM_CAPTURECHANGED;
    procedure WMCancelMode(var Message: TMessage); message WM_CANCELMODE;
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DoEnter; override;
    procedure DoExit; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ShowNotification(const AText: string; const ASeverity: TNimbusNotificationSeverity = nnsInfo;
      const AUseMarkdown: Boolean = False; const AAutoDismissMilliseconds: Integer = 0): TThemedIdeNotificationMessage;
    function Dismiss(const AID: string; const AReason: TNimbusNotificationDismissReason = nndrManual): Boolean;
    procedure DismissAll;
    procedure Next;
    procedure Previous;
    procedure RefreshNotifications;
    property Messages: TThemedIdeNotificationMessages read FMessages write SetMessages;
    property DisplayMode: TNimbusNotificationDisplayMode read FDisplayMode write SetDisplayMode default nndStack;
    property MaxStackItems: Integer read FMaxStackItems write SetMaxStackItems default 5;
    property ShowCloseButton: Boolean read FShowCloseButton write SetShowCloseButton default True;
    property ShowCountdown: Boolean read FShowCountdown write SetShowCountdown default True;
    property Multiline: Boolean read FMultiline write SetMultiline default True;
    property CompactMode: Boolean read FCompactMode write SetCompactMode default False;
    property AutoHeight: Boolean read FAutoHeight write SetAutoHeight default True;
    property OnClosing: TNimbusNotificationClosingEvent read FOnClosing write FOnClosing;
    property OnDismissed: TNimbusNotificationDismissEvent read FOnDismissed write FOnDismissed;
    property OnExpired: TNimbusNotificationDismissEvent read FOnExpired write FOnExpired;
    property OnAction: TNimbusNotificationActionEvent read FOnAction write FOnAction;
    property OnLinkClicked: TNimbusNotificationLinkEvent read FOnLinkClicked write FOnLinkClicked;
    property OnNavigation: TNimbusNotificationNavigationEvent read FOnNavigation write FOnNavigation;
    property CurrentMessageID: string read GetCurrentMessageID;
    property CurrentMessageIndex: Integer read FCarouselIndex;
  end;

  TThemedIdeNotificationBar = class(TCustomThemedIdeNotificationBar)
  published
    property Align;
    property Anchors;
    property Constraints;
    property Font;
    property ParentFont;
    property Enabled;
    property Visible;
    property TabOrder;
    property TabStop default True;
    property PopupMenu;
    property Messages;
    property DisplayMode;
    property MaxStackItems;
    property ShowCloseButton;
    property ShowCountdown;
    property Multiline;
    property CompactMode;
    property AutoHeight;
    property OnClosing;
    property OnDismissed;
    property OnExpired;
    property OnAction;
    property OnLinkClicked;
    property OnNavigation;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

implementation

uses Winapi.Windows, System.Math, Vcl.ActnList, Vcl.StdCtrls, NimbusForms.Rendering.Types;

constructor TCustomThemedIdeNotificationBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csCaptureMouse];
  FMessages := TThemedIdeNotificationMessages.Create(Self, MessagesChanged);
  FTimer := TTimer.Create(Self);
  FTimer.Enabled := False;
  FTimer.Interval := 100;
  FTimer.OnTimer := TimerTick;
  FMaxStackItems := 5;
  FShowCloseButton := True;
  FShowCountdown := True;
  FMultiline := True;
  FAutoHeight := True;
  FDirty := True;
  FHotView := -1;
  FHotAction := -1;
  FFocusView := -1;
  FFocusAction := -1;
  FPressedView := -1;
  FPressedAction := -1;
  TabStop := True;
  Width := 640;
  Height := 34;
end;

destructor TCustomThemedIdeNotificationBar.Destroy;
begin
  if FTimer <> nil then
  begin
    FTimer.Enabled := False;
    FTimer.OnTimer := nil;
  end;
  FreeAndNil(FMessages);
  inherited Destroy;
end;

procedure TCustomThemedIdeNotificationBar.MessagesChanged(Sender: TObject);
var I, J: Integer; Ready: Boolean;
begin
  if (csDestroying in ComponentState) or (FMessages = nil) then Exit;
  FDirty := True;
  FFocusView := -1;
  FFocusAction := -1;
  FHotView := -1;
  FHoveredLink := '';
  Ready := True;
  for I := 0 to FMessages.Count - 1 do
    if (FMessages[I].Actions <> nil) and not FMessages[I].Destroying then
    begin
      for J := 0 to FMessages[I].Actions.Count - 1 do
        if FMessages[I].Actions[J].Action <> nil then FMessages[I].Actions[J].Action.FreeNotification(Self);
    end
    else Ready := False;
  if FTimer <> nil then FTimer.Enabled := HandleAllocated and (FMessages.Count > 0) and not (csDesigning in ComponentState);
  Invalidate;
  if Ready and not (csLoading in ComponentState) and not (csReading in ComponentState) then EnsureLayout;
end;

procedure TCustomThemedIdeNotificationBar.RefreshNotifications;
begin
  MessagesChanged(Self);
end;

procedure TCustomThemedIdeNotificationBar.EnsureLayout;
var H: Integer;
begin
  if not FDirty or FUpdating or not HandleAllocated then Exit;
  FUpdating := True;
  try
    RenderCanvas.BeginRender(Canvas);
    try
      H := TThemedIdeNotificationBarRenderer.Layout(RenderCanvas, Font, FMessages,
        ClientWidth, CurrentPPI, FMaxStackItems, FCarouselIndex, FDisplayMode,
        FCompactMode, FMultiline, FShowCloseButton, FViews);
    finally RenderCanvas.EndRender; end;
    FDirty := False;
    if FAutoHeight and not (csDesigning in ComponentState) then Height := H;
  finally FUpdating := False; end;
end;

procedure TCustomThemedIdeNotificationBar.Paint;
begin
  EnsureLayout;
  RenderCanvas.BeginRender(Canvas);
  try
    RenderCanvas.FillRectangle(NimbusPanelBackColor(Palette), ClientRect);
    RenderCanvas.PushClip(ClientRect);
    try
      TThemedIdeNotificationBarRenderer.Render(RenderCanvas, Font, Palette, FMessages, FViews,
        CurrentPPI, FHotView, FHotAction, FFocusView, FFocusAction, Enabled, FShowCountdown, FHoveredLink);
    finally RenderCanvas.PopClip; end;
  finally RenderCanvas.EndRender; end;
end;

procedure TCustomThemedIdeNotificationBar.Resize;
begin
  inherited;
  if not FUpdating then FDirty := True;
  Invalidate;
end;

procedure TCustomThemedIdeNotificationBar.CreateWnd;
begin
  inherited;
  FDirty := True;
  FTimer.Enabled := (FMessages.Count > 0) and not (csDesigning in ComponentState);
end;

procedure TCustomThemedIdeNotificationBar.DestroyWnd;
begin
  FTimer.Enabled := False;
  FPressedID := '';
  FPressedView := -1;
  FPressedLink := '';
  FViews := nil;
  FDirty := True;
  inherited;
end;

procedure TCustomThemedIdeNotificationBar.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited;
  FDirty := True;
  Invalidate;
end;

procedure TCustomThemedIdeNotificationBar.CMFontChanged(var Message: TMessage);
begin
  inherited;
  FDirty := True;
end;

procedure TCustomThemedIdeNotificationBar.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  FHotView := -1;
  FHoveredLink := '';
  Cursor := crDefault;
  Invalidate;
end;

procedure TCustomThemedIdeNotificationBar.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  Message.Result := Message.Result or DLGC_WANTARROWS or DLGC_WANTCHARS;
end;

procedure TCustomThemedIdeNotificationBar.WMCaptureChanged(var Message: TMessage);
begin
  inherited;
  FPressedView := -1;
  FPressedID := '';
  FPressedLink := '';
end;

procedure TCustomThemedIdeNotificationBar.WMCancelMode(var Message: TMessage);
begin
  inherited;
  FPressedView := -1;
  FPressedID := '';
  FPressedLink := '';
  MouseCapture := False;
end;

procedure TCustomThemedIdeNotificationBar.Notification(AComponent: TComponent; Operation: TOperation);
var I, J: Integer;
begin
  inherited;
  if (Operation <> opRemove) or (FMessages = nil) then Exit;
  for I := 0 to FMessages.Count - 1 do
    for J := 0 to FMessages[I].Actions.Count - 1 do
      if FMessages[I].Actions[J].Action = AComponent then FMessages[I].Actions[J].Action := nil;
end;

function TCustomThemedIdeNotificationBar.ShowNotification(const AText: string;
  const ASeverity: TNimbusNotificationSeverity; const AUseMarkdown: Boolean;
  const AAutoDismissMilliseconds: Integer): TThemedIdeNotificationMessage;
begin
  if AAutoDismissMilliseconds < 0 then raise EArgumentOutOfRangeException.Create('AutoDismissMilliseconds');
  FMessages.BeginUpdate;
  try
    Result := FMessages.Add;
    Result.Text := AText;
    Result.Severity := ASeverity;
    Result.UseMarkdown := AUseMarkdown;
    Result.AutoDismissMilliseconds := AAutoDismissMilliseconds;
  finally FMessages.EndUpdate; end;
end;

function TCustomThemedIdeNotificationBar.Dismiss(const AID: string; const AReason: TNimbusNotificationDismissReason): Boolean;
var M: TThemedIdeNotificationMessage; Allow: Boolean; ID: string;
begin
  Result := False;
  ID := AID;
  M := FMessages.FindID(ID);
  if M = nil then Exit;
  Allow := True;
  if Assigned(FOnClosing) then FOnClosing(Self, M, AReason, Allow);
  if not Allow then Exit;
  M := FMessages.FindID(ID);
  if M = nil then Exit;
  M.Free;
  FCarouselIndex := EnsureRange(FCarouselIndex, 0, Max(0, FMessages.Count - 1));
  if AReason = nndrExpired then
    if Assigned(FOnExpired) then FOnExpired(Self, ID, AReason);
  if Assigned(FOnDismissed) then FOnDismissed(Self, ID, AReason);
  Result := True;
end;

procedure TCustomThemedIdeNotificationBar.DismissAll;
var IDs: TArray<string>; I: Integer;
begin
  SetLength(IDs, FMessages.Count);
  for I := 0 to High(IDs) do IDs[I] := FMessages[I].ID;
  for I := 0 to High(IDs) do Dismiss(IDs[I], nndrDismissAll);
end;

procedure TCustomThemedIdeNotificationBar.TimerTick(Sender: TObject);
var IDs: TArray<string>; I, N: Integer; NowTick: UInt64; M: TThemedIdeNotificationMessage;
begin
  NowTick := GetTickCount64;
  SetLength(IDs, FMessages.Count);
  N := 0;
  for I := 0 to FMessages.Count - 1 do
  begin
    M := FMessages[I];
    if not M.Sticky and (M.AutoDismissMilliseconds > 0) and
      (NowTick - M.CreatedTick >= UInt64(M.AutoDismissMilliseconds)) then
    begin IDs[N] := M.ID; Inc(N); end;
  end;
  for I := 0 to N - 1 do Dismiss(IDs[I], nndrExpired);
  if Showing then begin FDirty := True; Invalidate; end;
end;

function TCustomThemedIdeNotificationBar.GetCurrentMessageID: string;
var Order: TArray<Integer>; Index: Integer;
begin
  Result := '';
  Order := FMessages.DisplayOrder;
  if Length(Order) = 0 then Exit;
  Index := 0;
  if FDisplayMode = nndCarousel then Index := EnsureRange(FCarouselIndex, 0, High(Order));
  Result := FMessages[Order[Index]].ID;
end;

procedure TCustomThemedIdeNotificationBar.DoNavigation;
begin
  if Assigned(FOnNavigation) then FOnNavigation(Self, GetCurrentMessageID, FCarouselIndex, FMessages.Count);
end;

procedure TCustomThemedIdeNotificationBar.Next;
begin
  if FMessages.Count = 0 then Exit;
  FCarouselIndex := (FCarouselIndex + 1) mod FMessages.Count;
  MessagesChanged(Self);
  DoNavigation;
end;

procedure TCustomThemedIdeNotificationBar.Previous;
begin
  if FMessages.Count = 0 then Exit;
  FCarouselIndex := (FCarouselIndex + FMessages.Count - 1) mod FMessages.Count;
  MessagesChanged(Self);
  DoNavigation;
end;

procedure TCustomThemedIdeNotificationBar.Hit(const P: TPoint; out AView, AAction: Integer; out ALink: string);
var I, J: Integer; V: TNimbusNotificationView;
begin
  EnsureLayout;
  AView := -1; AAction := -1; ALink := '';
  for I := 0 to High(FViews) do
  begin
    V := FViews[I];
    if not PtInRect(V.Bounds, P) then Continue;
    AView := I;
    if PtInRect(V.CloseBounds, P) then AAction := -2
    else if PtInRect(V.PreviousBounds, P) then AAction := -3
    else if PtInRect(V.NextBounds, P) then AAction := -4
    else
    begin
      for J := 0 to High(V.ActionBounds) do
        if PtInRect(V.ActionBounds[J], P) then begin AAction := J; Exit; end;
      ALink := FMessages[V.MessageIndex].PrepareText(Font).HitTestLink(P, V.TextBounds,
        taLeftJustify, tlTop, 0, False);
    end;
    Exit;
  end;
end;

procedure TCustomThemedIdeNotificationBar.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  Hit(Point(X, Y), FHotView, FHotAction, FHoveredLink);
  if Enabled and ((FHotAction <> -1) or (FHoveredLink <> '')) then Cursor := crHandPoint else Cursor := crDefault;
  if (FHotView >= 0) and (FHotAction >= 0) and
    not FMessages[FViews[FHotView].MessageIndex].Actions[FHotAction].IsEnabled then Cursor := crDefault;
  Invalidate;
end;

procedure TCustomThemedIdeNotificationBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if (Button <> mbLeft) or not Enabled then Exit;
  if CanFocus then SetFocus;
  Hit(Point(X, Y), FPressedView, FPressedAction, FPressedLink);
  FPressedID := '';
  FPressedActionID := -1;
  if FPressedView >= 0 then
  begin
    FPressedID := FMessages[FViews[FPressedView].MessageIndex].ID;
    if FPressedAction >= 0 then FPressedActionID := FMessages[FViews[FPressedView].MessageIndex].Actions[FPressedAction].ID;
  end;
  FFocusView := FPressedView;
  FFocusAction := FPressedAction;
  MouseCapture := True;
  Invalidate;
end;

procedure TCustomThemedIdeNotificationBar.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var V, A: Integer; URL, ID: string; Valid: Boolean;
begin
  inherited;
  if Button <> mbLeft then Exit;
  Hit(Point(X, Y), V, A, URL);
  ID := '';
  if V >= 0 then ID := FMessages[FViews[V].MessageIndex].ID;
  Valid := Enabled and (ID <> '') and (ID = FPressedID) and (A = FPressedAction) and (URL = FPressedLink);
  if Valid and (A >= 0) then Valid := FMessages[FViews[V].MessageIndex].Actions[A].ID = FPressedActionID;
  FPressedView := -1;
  FPressedID := '';
  MouseCapture := False;
  if Valid then Activate(V, A, URL);
end;

procedure TCustomThemedIdeNotificationBar.Activate(const AView, AAction: Integer; const ALink: string);
var M: TThemedIdeNotificationMessage; A: TThemedIdeNotificationAction; ID: string; Close: Boolean;
  Links: TArray<string>; LinkIndex, ActionID: Integer;
begin
  if not Enabled or (AView < 0) or (AView >= Length(FViews)) then Exit;
  M := FMessages[FViews[AView].MessageIndex];
  ID := M.ID;
  if AAction <= -5 then
  begin
    Links := M.PrepareText(Font).LinkTargets;
    LinkIndex := -5 - AAction;
    if (LinkIndex < Length(Links)) and Assigned(FOnLinkClicked) then FOnLinkClicked(Self, ID, Links[LinkIndex]);
    Exit;
  end;
  case AAction of
    -2: Dismiss(ID);
    -3: Previous;
    -4: Next;
    -1: if (ALink <> '') and Assigned(FOnLinkClicked) then FOnLinkClicked(Self, ID, ALink);
  else
    if (AAction >= 0) and (AAction < M.Actions.Count) then
    begin
      A := M.Actions[AAction];
      if not A.IsEnabled or not A.IsVisible then Exit;
      ActionID := A.ID;
      Close := A.ClosesNotification;
      if Assigned(FOnAction) then FOnAction(Self, M, A);
      M := FMessages.FindID(ID);
      if (M <> nil) and (AAction < M.Actions.Count) and (M.Actions[AAction].ID = ActionID) then M.Actions[AAction].Execute(Self);
      if Close then Dismiss(ID, nndrAction);
    end;
  end;
  Invalidate;
end;

procedure TCustomThemedIdeNotificationBar.MoveFocus(const AForward: Boolean);
type TTarget = record View, Action: Integer; end;
var Targets: TArray<TTarget>; I, J, K, N: Integer; Links: TArray<string>;
  procedure Add(const V, A: Integer);
  begin
    N := Length(Targets); SetLength(Targets, N + 1);
    Targets[N].View := V; Targets[N].Action := A;
  end;
begin
  EnsureLayout;
  Targets := nil;
  for I := 0 to High(FViews) do
  begin
    Links := FMessages[FViews[I].MessageIndex].PrepareText(Font).LinkTargets;
    for J := 0 to High(Links) do Add(I, -5 - J);
    for J := 0 to High(FViews[I].ActionBounds) do
      if not IsRectEmpty(FViews[I].ActionBounds[J]) and FMessages[FViews[I].MessageIndex].Actions[J].IsEnabled then Add(I, J);
    if FShowCloseButton then Add(I, -2);
    if (FDisplayMode = nndCarousel) and (FMessages.Count > 1) then begin Add(I, -3); Add(I, -4); end;
  end;
  if Length(Targets) = 0 then Exit;
  K := -1;
  for I := 0 to High(Targets) do
    if (Targets[I].View = FFocusView) and (Targets[I].Action = FFocusAction) then K := I;
  if AForward then K := (K + 1) mod Length(Targets)
  else if K < 0 then K := High(Targets) else K := (K + Length(Targets) - 1) mod Length(Targets);
  FFocusView := Targets[K].View; FFocusAction := Targets[K].Action;
  Invalidate;
end;

procedure TCustomThemedIdeNotificationBar.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if not Enabled or (Key = 0) then Exit;
  case Key of
    VK_RIGHT, VK_DOWN: begin MoveFocus(True); Key := 0; end;
    VK_LEFT, VK_UP: begin MoveFocus(False); Key := 0; end;
    VK_RETURN, VK_SPACE: begin Activate(FFocusView, FFocusAction, ''); Key := 0; end;
    VK_ESCAPE:
      if (FFocusView >= 0) and FShowCloseButton then begin Activate(FFocusView, -2, ''); Key := 0; end;
  end;
end;

procedure TCustomThemedIdeNotificationBar.DoEnter;
begin
  inherited;
  if FFocusView < 0 then MoveFocus(True);
  Invalidate;
end;

procedure TCustomThemedIdeNotificationBar.DoExit;
begin
  inherited;
  FFocusView := -1;
  FFocusAction := -1;
  Invalidate;
end;

procedure TCustomThemedIdeNotificationBar.SetMessages(const AValue: TThemedIdeNotificationMessages);
begin
  FMessages.Assign(AValue);
end;

procedure TCustomThemedIdeNotificationBar.SetDisplayMode(const AValue: TNimbusNotificationDisplayMode);
begin
  if FDisplayMode = AValue then Exit;
  FDisplayMode := AValue;
  FCarouselIndex := 0;
  MessagesChanged(Self);
  DoNavigation;
end;

procedure TCustomThemedIdeNotificationBar.SetMaxStackItems(const AValue: Integer);
begin
  if AValue < 1 then raise EArgumentOutOfRangeException.Create('MaxStackItems');
  if FMaxStackItems = AValue then Exit;
  FMaxStackItems := AValue;
  MessagesChanged(Self);
end;

procedure TCustomThemedIdeNotificationBar.SetShowCloseButton(const AValue: Boolean);
begin
  if FShowCloseButton = AValue then Exit;
  FShowCloseButton := AValue;
  MessagesChanged(Self);
end;

procedure TCustomThemedIdeNotificationBar.SetShowCountdown(const AValue: Boolean);
begin
  if FShowCountdown = AValue then Exit;
  FShowCountdown := AValue;
  MessagesChanged(Self);
end;

procedure TCustomThemedIdeNotificationBar.SetMultiline(const AValue: Boolean);
begin
  if FMultiline = AValue then Exit;
  FMultiline := AValue;
  MessagesChanged(Self);
end;

procedure TCustomThemedIdeNotificationBar.SetCompactMode(const AValue: Boolean);
begin
  if FCompactMode = AValue then Exit;
  FCompactMode := AValue;
  MessagesChanged(Self);
end;

procedure TCustomThemedIdeNotificationBar.SetAutoHeight(const AValue: Boolean);
begin
  if FAutoHeight = AValue then Exit;
  FAutoHeight := AValue;
  MessagesChanged(Self);
end;

end.

{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.Avatar;

interface

uses
  System.Classes, System.Types, System.UITypes, Winapi.Messages, Vcl.Controls, Vcl.Graphics, Vcl.ImgList,
  NimbusForms.Controls.Base, NimbusForms.Rendering.Avatar, NimbusForms.Controls.Avatar.Badges,
  NimbusForms.Controls.ToolTip;

type
  TThemedAvatarBadgeEvent = procedure(Sender: TObject; const Hit: TThemedAvatarHitInfo) of object;
  TThemedAvatarBadgeActivatingEvent = procedure(Sender: TObject; const Hit: TThemedAvatarHitInfo; var Allow: Boolean) of object;
  TThemedAvatarBadgeContextEvent = procedure(Sender: TObject; const Hit: TThemedAvatarHitInfo;
    const MousePos: TPoint; var Handled: Boolean) of object;
  TThemedAvatarStatusEvent = procedure(Sender: TObject; OldStatus, NewStatus: TThemedAvatarStatus) of object;
  TThemedAvatarCounterEvent = procedure(Sender: TObject; OldCount, NewCount: Integer) of object;

  TCustomThemedAvatar = class(TCustomNimbusControl)
  private
    FPicture: TPicture;
    FImages: TCustomImageList;
    FImageIndex: System.UITypes.TImageIndex;
    FImageChangeLink: TChangeLink;
    FImageBuffer: Vcl.Graphics.TBitmap;
    FBufferDirty: Boolean;
    FText: string;
    FShowInitials: Boolean;
    FShape: TThemedAvatarShape;
    FSizeMode: TThemedAvatarSize;
    FStatus: TThemedAvatarStatus;
    FShowStatus: Boolean;
    FCounter: Integer;
    FShowCounter: Boolean;
    FShowStar: Boolean;
    FCustomAvatarColor: TColor;
    FBorderWidth: Integer;
    FOnBadgeClick: TNotifyEvent;
    FBadgeRect: TRect;
    FBadges: TThemedAvatarBadges;
    FBadgeFont: TFont;
    FLayout: TArray<TThemedAvatarBadgeLayout>;
    FLayoutDirty, FShowBadgeHints, FPressed, FDoubleClick, FKeyboardPressed: Boolean;
    FHotHit, FPressedHit: TThemedAvatarHitInfo;
    FFocusID, FCounterLimit: Integer;
    FShowZeroCounter, FStatusEnabled, FCounterEnabled, FStarEnabled: Boolean;
    FStatusHint, FCounterHint, FStarHint: string;
    FBadgeToolTip: TThemedToolTip;
    FBodyCursor: TCursor;
    FBadgeCursorActive: Boolean;
    FOnBadgeClickEx, FOnBadgeDblClick, FOnBadgeMouseEnter, FOnBadgeMouseLeave: TThemedAvatarBadgeEvent;
    FOnBadgeActivating: TThemedAvatarBadgeActivatingEvent;
    FOnBadgeContextPopup: TThemedAvatarBadgeContextEvent;
    FOnStatusClick, FOnCounterClick, FOnStarClick, FOnBadgesChanged: TNotifyEvent;
    FOnStatusChanged: TThemedAvatarStatusEvent;
    FOnCounterChanged: TThemedAvatarCounterEvent;
    procedure SetBadges(const Value: TThemedAvatarBadges);
    procedure SetBadgeFont(const Value: TFont);
    procedure BadgesChanged(Sender: TObject);
    procedure BadgeFontChanged(Sender: TObject);
    procedure InvalidateLayout;
    procedure EnsureLayout;
    function BadgeItems: TArray<TThemedAvatarBadgeInfo>;
    function FocusHit: TThemedAvatarHitInfo;
    function ResolveHit(ID: Integer): TThemedAvatarHitInfo;
    procedure SetHotHit(const Hit: TThemedAvatarHitInfo);
    procedure ActivateHit(const Hit: TThemedAvatarHitInfo);
    procedure CancelBadgeInteraction;
    procedure SetCounterLimit(Value: Integer);
    procedure SetShowZeroCounter(Value: Boolean);
    procedure SetShowBadgeHints(Value: Boolean);
    procedure SetStatusEnabled(Value: Boolean);
    procedure SetCounterEnabled(Value: Boolean);
    procedure SetStarEnabled(Value: Boolean);
    procedure SetStatusHint(const Value: string);
    procedure SetCounterHint(const Value: string);
    procedure SetStarHint(const Value: string);
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMCancelMode(var Message: TCMCancelMode); message CM_CANCELMODE;
    procedure CMVisibleChanged(var Message: TMessage); message CM_VISIBLECHANGED;
    procedure WMCaptureChanged(var Message: TMessage); message WM_CAPTURECHANGED;
    procedure WMLButtonDblClk(var Message: TMessage); message WM_LBUTTONDBLCLK;
    procedure WMCancelMode(var Message: TMessage); message WM_CANCELMODE;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure CMDialogKey(var Message: TCMDialogKey); message CM_DIALOGKEY;
    procedure SetPicture(const AValue: TPicture);
    procedure PictureChanged(Sender: TObject);
    procedure SetImages(const AValue: TCustomImageList);
    procedure ImagesChanged(Sender: TObject);
    procedure SetImageIndex(const AValue: System.UITypes.TImageIndex);
    procedure SetText(const AValue: string);
    procedure SetShowInitials(const AValue: Boolean);
    procedure SetShape(const AValue: TThemedAvatarShape);
    procedure SetSizeMode(const AValue: TThemedAvatarSize);
    procedure SetStatus(const AValue: TThemedAvatarStatus);
    procedure SetShowStatus(const AValue: Boolean);
    procedure SetCounter(const AValue: Integer);
    procedure SetShowCounter(const AValue: Boolean);
    procedure SetShowStar(const AValue: Boolean);
    procedure SetCustomAvatarColor(const AValue: TColor);
    procedure SetBorderWidth(const AValue: Integer);
    procedure UpdateImageBuffer(const ASize: Integer = 0);
    procedure InvalidateImage;
    function GetInitials: string;
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
    procedure SetParent(AParent: TWinControl); override;
    procedure DestroyWnd; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DblClick; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure DoContextPopup(MousePos: TPoint; var Handled: Boolean); override;
    property Picture: TPicture read FPicture write SetPicture;
    property Images: TCustomImageList read FImages write SetImages;
    property ImageIndex: System.UITypes.TImageIndex read FImageIndex write SetImageIndex default -1;
    property Text: string read FText write SetText;
    property ShowInitials: Boolean read FShowInitials write SetShowInitials default True;
    property Shape: TThemedAvatarShape read FShape write SetShape default tasCircle;
    property SizeMode: TThemedAvatarSize read FSizeMode write SetSizeMode default tavNormal;
    property Status: TThemedAvatarStatus read FStatus write SetStatus default tavsNone;
    property ShowStatus: Boolean read FShowStatus write SetShowStatus default False;
    property Counter: Integer read FCounter write SetCounter default 0;
    property ShowCounter: Boolean read FShowCounter write SetShowCounter default False;
    property ShowStar: Boolean read FShowStar write SetShowStar default False;
    property CustomAvatarColor: TColor read FCustomAvatarColor write SetCustomAvatarColor default clNone;
    property BorderWidth: Integer read FBorderWidth write SetBorderWidth default 1;
    property OnBadgeClick: TNotifyEvent read FOnBadgeClick write FOnBadgeClick;
    property Badges: TThemedAvatarBadges read FBadges write SetBadges;
    property BadgeFont: TFont read FBadgeFont write SetBadgeFont;
    property CounterLimit: Integer read FCounterLimit write SetCounterLimit default 99;
    property ShowZeroCounter: Boolean read FShowZeroCounter write SetShowZeroCounter default False;
    property ShowBadgeHints: Boolean read FShowBadgeHints write SetShowBadgeHints default True;
    property StatusEnabled: Boolean read FStatusEnabled write SetStatusEnabled default True;
    property CounterEnabled: Boolean read FCounterEnabled write SetCounterEnabled default True;
    property StarEnabled: Boolean read FStarEnabled write SetStarEnabled default True;
    property StatusHint: string read FStatusHint write SetStatusHint;
    property CounterHint: string read FCounterHint write SetCounterHint;
    property StarHint: string read FStarHint write SetStarHint;
    property OnBadgeClickEx: TThemedAvatarBadgeEvent read FOnBadgeClickEx write FOnBadgeClickEx;
    property OnBadgeDblClick: TThemedAvatarBadgeEvent read FOnBadgeDblClick write FOnBadgeDblClick;
    property OnBadgeMouseEnter: TThemedAvatarBadgeEvent read FOnBadgeMouseEnter write FOnBadgeMouseEnter;
    property OnBadgeMouseLeave: TThemedAvatarBadgeEvent read FOnBadgeMouseLeave write FOnBadgeMouseLeave;
    property OnBadgeActivating: TThemedAvatarBadgeActivatingEvent read FOnBadgeActivating write FOnBadgeActivating;
    property OnBadgeContextPopup: TThemedAvatarBadgeContextEvent read FOnBadgeContextPopup write FOnBadgeContextPopup;
    property OnStatusClick: TNotifyEvent read FOnStatusClick write FOnStatusClick;
    property OnCounterClick: TNotifyEvent read FOnCounterClick write FOnCounterClick;
    property OnStarClick: TNotifyEvent read FOnStarClick write FOnStarClick;
    property OnBadgesChanged: TNotifyEvent read FOnBadgesChanged write FOnBadgesChanged;
    property OnStatusChanged: TThemedAvatarStatusEvent read FOnStatusChanged write FOnStatusChanged;
    property OnCounterChanged: TThemedAvatarCounterEvent read FOnCounterChanged write FOnCounterChanged;
  public
    constructor Create(AOwner: TComponent); override;
    class function InitialsForText(const AText: string): string; static;
    function GetRenderImage(const ASize: Integer): Vcl.Graphics.TBitmap;
    destructor Destroy; override;
    procedure ClearImage;
    function HitTest(const Point: TPoint): TThemedAvatarHitInfo;
    function BadgeBounds(const Key: string): TRect;
    procedure SetPresence(Value: TThemedAvatarStatus);
    procedure SetUnreadCount(Value: Integer);
    procedure IncrementCounter(Delta: Integer = 1);
    procedure ClearCounter;
    procedure ToggleStar;
    function SetBadgeCounter(const Key: string; Value: Integer; Tone: TThemedAvatarBadgeTone = tabtDanger;
      Anchor: TThemedAvatarBadgeAnchor = tabaTopRight): TThemedAvatarBadge;
    function SetBadgeText(const Key, Value: string; Tone: TThemedAvatarBadgeTone = tabtInfo;
      Anchor: TThemedAvatarBadgeAnchor = tabaBottomRight): TThemedAvatarBadge;
    function SetBadgeDot(const Key: string; Tone: TThemedAvatarBadgeTone = tabtSuccess;
      Anchor: TThemedAvatarBadgeAnchor = tabaBottomLeft): TThemedAvatarBadge;
    function RemoveBadge(const Key: string): Boolean;
  end;

  TThemedAvatar = class(TCustomThemedAvatar)
  published
    property Align;
    property Anchors;
    property Constraints;
    property Font;
    property ParentFont;
    property Enabled;
    property Visible;
    property Hint;
    property ShowHint;
    property ParentShowHint;
    property PopupMenu;
    property Picture;
    property Images;
    property ImageIndex;
    property Text;
    property ShowInitials;
    property Shape;
    property SizeMode;
    property Status;
    property ShowStatus;
    property Counter;
    property ShowCounter;
    property ShowStar;
    property CustomAvatarColor;
    property BorderWidth;
    property Badges;
    property BadgeFont;
    property CounterLimit;
    property ShowZeroCounter;
    property ShowBadgeHints;
    property StatusEnabled;
    property CounterEnabled;
    property StarEnabled;
    property StatusHint;
    property CounterHint;
    property StarHint;
    property OnBadgeClick;
    property OnBadgeClickEx;
    property OnBadgeDblClick;
    property OnBadgeMouseEnter;
    property OnBadgeMouseLeave;
    property OnBadgeActivating;
    property OnBadgeContextPopup;
    property OnStatusClick;
    property OnCounterClick;
    property OnStarClick;
    property OnBadgesChanged;
    property OnStatusChanged;
    property OnCounterChanged;
    property TabStop default True;
    property TabOrder;
    property OnClick;
    property OnDblClick;
    property OnContextPopup;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;
  end;

implementation

uses
  System.SysUtils, System.Math, Winapi.Windows, Vcl.Imaging.pngimage, Vcl.Imaging.jpeg, NimbusForms.Rendering.Types;

resourcestring
  SOnline = 'Online';
  SAway = 'Away';
  SBusy = 'Busy';
  SOffline = 'Offline';
  SConnecting = 'Connecting';
  SDoNotDisturb = 'Do not disturb';
  SInvisible = 'Invisible';
  SUnread = '%d unread messages';
  SFavorite = 'Favorite';

procedure TCustomThemedAvatar.SetBadges(const Value: TThemedAvatarBadges);
begin FBadges.Assign(Value); end;
procedure TCustomThemedAvatar.SetBadgeFont(const Value: TFont);
begin FBadgeFont.Assign(Value); end;
procedure TCustomThemedAvatar.BadgeFontChanged(Sender: TObject);
begin InvalidateLayout; end;
procedure TCustomThemedAvatar.BadgesChanged(Sender: TObject);
begin
  InvalidateLayout;
  if Assigned(FOnBadgesChanged) and not (csLoading in ComponentState) and not (csDestroying in ComponentState) then FOnBadgesChanged(Self);
end;
procedure TCustomThemedAvatar.SetCounterLimit(Value: Integer);
begin Value := Max(1, Value); if FCounterLimit = Value then Exit; FCounterLimit := Value; InvalidateLayout; end;
procedure TCustomThemedAvatar.SetShowZeroCounter(Value: Boolean);
begin if FShowZeroCounter = Value then Exit; FShowZeroCounter := Value; InvalidateLayout; end;
procedure TCustomThemedAvatar.SetShowBadgeHints(Value: Boolean);
begin if FShowBadgeHints = Value then Exit; FShowBadgeHints := Value; InvalidateLayout; end;
procedure TCustomThemedAvatar.SetStatusEnabled(Value: Boolean);
begin if FStatusEnabled = Value then Exit; FStatusEnabled := Value; InvalidateLayout; end;
procedure TCustomThemedAvatar.SetCounterEnabled(Value: Boolean);
begin if FCounterEnabled = Value then Exit; FCounterEnabled := Value; InvalidateLayout; end;
procedure TCustomThemedAvatar.SetStarEnabled(Value: Boolean);
begin if FStarEnabled = Value then Exit; FStarEnabled := Value; InvalidateLayout; end;
procedure TCustomThemedAvatar.SetStatusHint(const Value: string);
begin if FStatusHint = Value then Exit; FStatusHint := Value; InvalidateLayout; end;
procedure TCustomThemedAvatar.SetCounterHint(const Value: string);
begin if FCounterHint = Value then Exit; FCounterHint := Value; InvalidateLayout; end;
procedure TCustomThemedAvatar.SetStarHint(const Value: string);
begin if FStarHint = Value then Exit; FStarHint := Value; InvalidateLayout; end;

procedure TCustomThemedAvatar.CancelBadgeInteraction;
begin
  FPressed := False; FKeyboardPressed := False; FDoubleClick := False;
  FPressedHit := Default(TThemedAvatarHitInfo); FPressedHit.BadgeID := -1;
  FHotHit := Default(TThemedAvatarHitInfo); FHotHit.BadgeID := -1;
  if FBadgeToolTip <> nil then FBadgeToolTip.HideHint;
  if FBadgeCursorActive then begin Cursor := FBodyCursor; FBadgeCursorActive := False; end;
  if HandleAllocated and MouseCapture then MouseCapture := False;
end;

procedure TCustomThemedAvatar.InvalidateLayout;
begin FLayoutDirty := True; CancelBadgeInteraction; Invalidate; end;

function TCustomThemedAvatar.BadgeItems: TArray<TThemedAvatarBadgeInfo>;
var Info: TThemedAvatarBadgeInfo; N, I: Integer;
  procedure Append;
  begin N := Length(Result); SetLength(Result, N + 1); Result[N] := Info; end;
begin
  Result := nil;
  Info := Default(TThemedAvatarBadgeInfo); Info.Color := clNone; Info.TextColor := clNone;
  Info.Enabled := FStatusEnabled; Info.Visible := FShowStatus and (FStatus <> tavsNone);
  Info.Part := tapStatus; Info.ID := -3; Info.Key := 'status'; Info.Anchor := tabaBottomLeft;
  case FStatus of
    tavsOnline: begin Info.Tone := tabtSuccess; Info.Hint := SOnline; end;
    tavsAway: begin Info.Tone := tabtWarning; Info.Hint := SAway; end;
    tavsBusy: begin Info.Tone := tabtDanger; Info.Hint := SBusy; end;
    tavsConnecting: begin Info.Tone := tabtInfo; Info.Hint := SConnecting; end;
    tavsDoNotDisturb: begin Info.Tone := tabtDanger; Info.Hint := SDoNotDisturb; end;
    tavsInvisible: begin Info.Tone := tabtNeutral; Info.Hint := SInvisible; end;
  else Info.Tone := tabtNeutral; Info.Hint := SOffline;
  end;
  if FStatusHint <> '' then Info.Hint := FStatusHint;
  Append;
  Info := Default(TThemedAvatarBadgeInfo); Info.Color := clNone; Info.TextColor := clNone;
  Info.Part := tapCounter; Info.ID := -4; Info.Key := 'counter'; Info.Kind := tabkCounter; Info.Tone := tabtDanger;
  Info.Anchor := tabaTopRight; Info.Count := FCounter; Info.Limit := FCounterLimit; Info.HideWhenZero := not FShowZeroCounter;
  Info.Visible := FShowCounter; Info.Enabled := FCounterEnabled; Info.Hint := FCounterHint;
  if Info.Hint = '' then Info.Hint := Format(SUnread, [FCounter]);
  Append;
  Info := Default(TThemedAvatarBadgeInfo); Info.Color := clNone; Info.TextColor := clNone;
  Info.Part := tapStar; Info.ID := -5; Info.Key := 'star'; Info.Kind := tabkStar; Info.Tone := tabtWarning;
  Info.Anchor := tabaBottomRight; Info.Visible := FShowStar; Info.Enabled := FStarEnabled; Info.Hint := FStarHint;
  if Info.Hint = '' then Info.Hint := SFavorite;
  Append;
  if FBadges <> nil then for I := 0 to FBadges.Count - 1 do begin Info := FBadges[I].RenderInfo; Append; end;
end;

procedure TCustomThemedAvatar.EnsureLayout;
begin
  if not FLayoutDirty or not HandleAllocated or (FBadgeFont = nil) then Exit;
  RenderCanvas.BeginRender(Canvas);
  try FLayout := TThemedAvatarRenderer.BuildBadgeLayout(RenderCanvas, ClientRect, FBadgeFont, CurrentPPI, BadgeItems);
  finally RenderCanvas.EndRender; end;
  FLayoutDirty := False;
end;

function TCustomThemedAvatar.HitTest(const Point: TPoint): TThemedAvatarHitInfo;
begin
  Result := Default(TThemedAvatarHitInfo); Result.BadgeID := -1;
  if not HandleAllocated then Exit;
  EnsureLayout; Result := TThemedAvatarRenderer.HitTest(Point, ClientRect, FShape, FLayout);
  Result.Enabled := Result.Enabled and Enabled;
end;

function TCustomThemedAvatar.BadgeBounds(const Key: string): TRect;
var Entry: TThemedAvatarBadgeLayout;
begin
  Result := Rect(0, 0, 0, 0); EnsureLayout;
  for Entry in FLayout do if SameText(Entry.Info.Key, Key) and (Entry.Info.Part = tapBadge) then Exit(Entry.Bounds);
end;

procedure TCustomThemedAvatar.SetPresence(Value: TThemedAvatarStatus);
begin SetShowStatus(Value <> tavsNone); SetStatus(Value); end;
procedure TCustomThemedAvatar.SetUnreadCount(Value: Integer);
begin SetShowCounter(True); SetCounter(Value); end;
procedure TCustomThemedAvatar.IncrementCounter(Delta: Integer);
begin SetUnreadCount(Integer(EnsureRange(Int64(FCounter) + Delta, Int64(0), Int64(MaxInt)))); end;
procedure TCustomThemedAvatar.ClearCounter;
begin SetCounter(0); end;
procedure TCustomThemedAvatar.ToggleStar;
begin SetShowStar(not FShowStar); end;

function TCustomThemedAvatar.SetBadgeCounter(const Key: string; Value: Integer; Tone: TThemedAvatarBadgeTone;
  Anchor: TThemedAvatarBadgeAnchor): TThemedAvatarBadge;
begin
  FBadges.BeginUpdate;
  try Result := FBadges.Ensure(Key); Result.Kind := tabkCounter; Result.Tone := Tone; Result.Anchor := Anchor; Result.Count := Value; Result.Visible := True;
  finally FBadges.EndUpdate; end;
end;
function TCustomThemedAvatar.SetBadgeText(const Key, Value: string; Tone: TThemedAvatarBadgeTone;
  Anchor: TThemedAvatarBadgeAnchor): TThemedAvatarBadge;
begin
  FBadges.BeginUpdate;
  try Result := FBadges.Ensure(Key); Result.Kind := tabkText; Result.Tone := Tone; Result.Anchor := Anchor; Result.Text := Value; Result.Visible := True;
  finally FBadges.EndUpdate; end;
end;
function TCustomThemedAvatar.SetBadgeDot(const Key: string; Tone: TThemedAvatarBadgeTone;
  Anchor: TThemedAvatarBadgeAnchor): TThemedAvatarBadge;
begin
  FBadges.BeginUpdate;
  try Result := FBadges.Ensure(Key); Result.Kind := tabkDot; Result.Tone := Tone; Result.Anchor := Anchor; Result.Visible := True;
  finally FBadges.EndUpdate; end;
end;
function TCustomThemedAvatar.RemoveBadge(const Key: string): Boolean;
var Badge: TThemedAvatarBadge;
begin Badge := FBadges.Find(Key); Result := Badge <> nil; Badge.Free; end;

function TCustomThemedAvatar.ResolveHit(ID: Integer): TThemedAvatarHitInfo;
var Entry: TThemedAvatarBadgeLayout;
begin
  Result := Default(TThemedAvatarHitInfo); Result.BadgeID := -1; EnsureLayout;
  if ID = -2 then
  begin
    Result.Part := tapAvatar; Result.BadgeID := -2; Result.Bounds := TThemedAvatarRenderer.AvatarBounds(ClientRect);
    Result.Enabled := Enabled; Exit;
  end;
  for Entry in FLayout do
    if Entry.Info.ID = ID then
    begin
      Result := TThemedAvatarRenderer.HitTest(Point((Entry.Bounds.Left + Entry.Bounds.Right) div 2,
        (Entry.Bounds.Top + Entry.Bounds.Bottom) div 2), ClientRect, FShape, FLayout);
      Result.Enabled := Result.Enabled and Enabled; Exit;
    end;
end;

function TCustomThemedAvatar.FocusHit: TThemedAvatarHitInfo;
begin
  Result := ResolveHit(FFocusID);
  if (Result.Part = tapNone) or not Result.Enabled then begin FFocusID := -2; Result := ResolveHit(FFocusID); end;
end;

procedure TCustomThemedAvatar.SetHotHit(const Hit: TThemedAvatarHitInfo);
var Old: TThemedAvatarHitInfo;
begin
  if (FHotHit.Part = Hit.Part) and (FHotHit.BadgeID = Hit.BadgeID) then Exit;
  Old := FHotHit; FHotHit := Hit;
  if FBadgeToolTip <> nil then FBadgeToolTip.HideHint;
  if (Hit.Part in [tapStatus, tapCounter, tapStar, tapBadge]) and Hit.Enabled then
  begin
    if not FBadgeCursorActive then begin FBodyCursor := Cursor; FBadgeCursorActive := True; end;
    Cursor := crHandPoint;
  end
  else if FBadgeCursorActive then begin Cursor := FBodyCursor; FBadgeCursorActive := False; end;
  if (Hit.Part in [tapStatus, tapCounter, tapStar, tapBadge]) and (Hit.Hint <> '') and FShowBadgeHints then
  begin
    if FBadgeToolTip = nil then FBadgeToolTip := TThemedToolTip.Create(Self);
    FBadgeToolTip.UseMarkup := False;
    FBadgeToolTip.ShowTextForControl(Self, Hit.Hint, Hit.Bounds);
  end;
  Invalidate;
  if (Old.Part in [tapStatus, tapCounter, tapStar, tapBadge]) and Assigned(FOnBadgeMouseLeave) then FOnBadgeMouseLeave(Self, Old);
  if (Hit.Part in [tapStatus, tapCounter, tapStar, tapBadge]) and Assigned(FOnBadgeMouseEnter) and
    (FHotHit.BadgeID = Hit.BadgeID) then FOnBadgeMouseEnter(Self, Hit);
end;

procedure TCustomThemedAvatar.ActivateHit(const Hit: TThemedAvatarHitInfo);
var Current: TThemedAvatarHitInfo; Allow: Boolean;
begin
  if not Enabled or (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
  Current := ResolveHit(Hit.BadgeID);
  if (Current.Part <> Hit.Part) or (Current.Part = tapNone) or not Current.Enabled then Exit;
  if Current.Part = tapAvatar then begin Click; Exit; end;
  Allow := True; if Assigned(FOnBadgeActivating) then FOnBadgeActivating(Self, Current, Allow);
  if not Allow then Exit;
  Current := ResolveHit(Hit.BadgeID);
  if (Current.Part <> Hit.Part) or not Current.Enabled then Exit;
  case Current.Part of
    tapStatus: if Assigned(FOnStatusClick) then FOnStatusClick(Self);
    tapCounter: if Assigned(FOnCounterClick) then FOnCounterClick(Self);
    tapStar: if Assigned(FOnStarClick) then FOnStarClick(Self);
  end;
  if Assigned(FOnBadgeClickEx) then FOnBadgeClickEx(Self, Current);
  if Assigned(FOnBadgeClick) then FOnBadgeClick(Self);
end;

procedure TCustomThemedAvatar.SetParent(AParent: TWinControl);
begin CancelBadgeInteraction; inherited; FLayout := nil; FLayoutDirty := True; end;
procedure TCustomThemedAvatar.DestroyWnd;
begin CancelBadgeInteraction; FLayout := nil; FLayoutDirty := True; inherited; end;
procedure TCustomThemedAvatar.CMMouseLeave(var Message: TMessage);
var Hit: TThemedAvatarHitInfo;
begin inherited; Hit := Default(TThemedAvatarHitInfo); Hit.BadgeID := -1; SetHotHit(Hit); end;
procedure TCustomThemedAvatar.CMEnabledChanged(var Message: TMessage);
begin inherited; InvalidateLayout; end;
procedure TCustomThemedAvatar.CMCancelMode(var Message: TCMCancelMode);
begin inherited; if Message.Sender <> Self then begin CancelBadgeInteraction; Invalidate; end; end;
procedure TCustomThemedAvatar.CMVisibleChanged(var Message: TMessage);
begin inherited; if not Visible then CancelBadgeInteraction; end;
procedure TCustomThemedAvatar.WMCaptureChanged(var Message: TMessage);
begin inherited; if not MouseCapture and FPressed then begin CancelBadgeInteraction; Invalidate; end; end;
procedure TCustomThemedAvatar.WMLButtonDblClk(var Message: TMessage);
begin DblClick; inherited; end;
procedure TCustomThemedAvatar.WMCancelMode(var Message: TMessage);
begin CancelBadgeInteraction; Invalidate; inherited; end;
procedure TCustomThemedAvatar.WMKillFocus(var Message: TWMKillFocus);
begin CancelBadgeInteraction; Invalidate; inherited; end;
procedure TCustomThemedAvatar.WMSetFocus(var Message: TWMSetFocus);
begin inherited; Invalidate; end;
procedure TCustomThemedAvatar.WMGetDlgCode(var Message: TWMGetDlgCode);
begin inherited; Message.Result := Message.Result or DLGC_WANTARROWS; end;
procedure TCustomThemedAvatar.CMDialogKey(var Message: TCMDialogKey);
begin
  if Focused and Enabled and (Message.CharCode = VK_RETURN) then
  begin ActivateHit(FocusHit); Message.Result := 1; Exit; end;
  inherited;
end;

procedure TCustomThemedAvatar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var Hit: TThemedAvatarHitInfo;
begin
  inherited;
  if (Button <> mbLeft) or not Enabled or (csDesigning in ComponentState) then Exit;
  if CanFocus then SetFocus;
  Hit := HitTest(Point(X, Y));
  if (Hit.Part = tapNone) or not Hit.Enabled then Exit;
  FPressedHit := Hit; FFocusID := Hit.BadgeID; FPressed := True; FKeyboardPressed := False; FDoubleClick := ssDouble in Shift;
  MouseCapture := True; if FBadgeToolTip <> nil then FBadgeToolTip.HideHint; Invalidate;
end;
procedure TCustomThemedAvatar.MouseMove(Shift: TShiftState; X, Y: Integer);
begin inherited; if not (csDesigning in ComponentState) then SetHotHit(HitTest(Point(X, Y))); end;
procedure TCustomThemedAvatar.DblClick;
var P: TPoint; Hit: TThemedAvatarHitInfo; Allow: Boolean;
begin
  if not GetCursorPos(P) then Exit; P := ScreenToClient(P); Hit := HitTest(P);
  if not Hit.Enabled then Exit;
  if Hit.Part = tapAvatar then inherited
  else if Hit.Part <> tapNone then
  begin
    Allow := True; if Assigned(FOnBadgeActivating) then FOnBadgeActivating(Self, Hit, Allow);
    if not Allow then Exit; Hit := ResolveHit(Hit.BadgeID);
    if Hit.Enabled and (Hit.Part <> tapNone) and Assigned(FOnBadgeDblClick) then FOnBadgeDblClick(Self, Hit);
  end;
end;

procedure TCustomThemedAvatar.KeyDown(var Key: Word; Shift: TShiftState);
var IDs: TArray<Integer>; Entry: TThemedAvatarBadgeLayout; Index, I: Integer;
begin
  inherited;
  if not Enabled or (Shift <> []) then Exit;
  if Key = VK_ESCAPE then begin CancelBadgeInteraction; Invalidate; Key := 0; Exit; end;
  if Key = VK_SPACE then
  begin
    if not FKeyboardPressed then begin FPressedHit := FocusHit; FKeyboardPressed := True; Invalidate; end;
    Key := 0; Exit;
  end;
  if not (Key in [VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN, VK_HOME, VK_END]) then Exit;
  EnsureLayout; SetLength(IDs, 1); IDs[0] := -2;
  for Entry in FLayout do if Entry.Info.Enabled then begin I := Length(IDs); SetLength(IDs, I + 1); IDs[I] := Entry.Info.ID; end;
  Index := 0; for I := 0 to High(IDs) do if IDs[I] = FFocusID then begin Index := I; Break; end;
  case Key of
    VK_LEFT, VK_UP: Index := (Index + Length(IDs) - 1) mod Length(IDs);
    VK_RIGHT, VK_DOWN: Index := (Index + 1) mod Length(IDs);
    VK_HOME: Index := 0;
    VK_END: Index := High(IDs);
  end;
  FFocusID := IDs[Index]; FKeyboardPressed := False; Invalidate; Key := 0;
end;
procedure TCustomThemedAvatar.KeyUp(var Key: Word; Shift: TShiftState);
var Hit: TThemedAvatarHitInfo;
begin
  inherited;
  if (Key = VK_SPACE) and FKeyboardPressed then
  begin Hit := FPressedHit; FKeyboardPressed := False; Invalidate; Key := 0; ActivateHit(Hit); end;
end;
procedure TCustomThemedAvatar.DoContextPopup(MousePos: TPoint; var Handled: Boolean);
var Hit: TThemedAvatarHitInfo;
begin
  if (MousePos.X = -1) and (MousePos.Y = -1) then Hit := FocusHit else Hit := HitTest(MousePos);
  if Enabled and (Hit.Part in [tapStatus, tapCounter, tapStar, tapBadge]) and Assigned(FOnBadgeContextPopup) then
    FOnBadgeContextPopup(Self, Hit, MousePos, Handled);
  if not Handled then inherited;
end;

constructor TCustomThemedAvatar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := (ControlStyle - [csOpaque, csCaptureMouse, csClickEvents]) + [csDoubleClicks, csParentBackground];
  TabStop := True; FFocusID := -2; FHotHit.BadgeID := -1; FPressedHit.BadgeID := -1;
  FCounterLimit := 99; FStatusEnabled := True; FCounterEnabled := True; FStarEnabled := True; FShowBadgeHints := True;
  FLayoutDirty := True;
  FBadges := TThemedAvatarBadges.Create(Self); FBadges.OnChange := BadgesChanged;
  FBadgeFont := TFont.Create; FBadgeFont.Name := 'Segoe UI'; FBadgeFont.Size := 8; FBadgeFont.Style := [fsBold];
  FBadgeFont.OnChange := BadgeFontChanged;
  SetBounds(Left, Top, 48, 48);
  FImageIndex := -1;
  FShowInitials := True;
  FShape := tasCircle;
  FSizeMode := tavNormal;
  FBorderWidth := 1;
  FCustomAvatarColor := clNone;
  FBufferDirty := True;
  FPicture := TPicture.Create;
  FPicture.OnChange := PictureChanged;
  FImageChangeLink := TChangeLink.Create;
  FImageChangeLink.OnChange := ImagesChanged;
  FImageBuffer := Vcl.Graphics.TBitmap.Create;
  Font.Name := 'Segoe UI';
  Font.Style := [fsBold];
end;

destructor TCustomThemedAvatar.Destroy;
begin
  if FBadges <> nil then FBadges.OnChange := nil;
  CancelBadgeInteraction;
  FreeAndNil(FBadgeToolTip);
  FBadges.Free; FBadges := nil;
  FBadgeFont.Free; FBadgeFont := nil;
  if FImages <> nil then
  begin
    FImages.UnRegisterChanges(FImageChangeLink);
    FImages.RemoveFreeNotification(Self);
  end;
  FImageBuffer.Free;
  FImageChangeLink.Free;
  FPicture.Free;
  inherited Destroy;
end;

procedure TCustomThemedAvatar.InvalidateImage;
begin
  FBufferDirty := True;
  Invalidate;
end;

procedure TCustomThemedAvatar.PictureChanged(Sender: TObject);
begin
  InvalidateImage;
end;

procedure TCustomThemedAvatar.SetPicture(const AValue: TPicture);
begin
  FPicture.Assign(AValue);
end;

procedure TCustomThemedAvatar.SetImages(const AValue: TCustomImageList);
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
  InvalidateImage;
end;

procedure TCustomThemedAvatar.ImagesChanged(Sender: TObject);
begin
  InvalidateImage;
end;

procedure TCustomThemedAvatar.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FImages) then
  begin
    FImages := nil;
    InvalidateImage;
  end;
end;

procedure TCustomThemedAvatar.SetImageIndex(const AValue: System.UITypes.TImageIndex);
begin
  if FImageIndex = AValue then Exit;
  FImageIndex := AValue;
  InvalidateImage;
end;

procedure TCustomThemedAvatar.SetText(const AValue: string);
begin
  if FText = AValue then Exit;
  FText := AValue;
  Invalidate;
end;

procedure TCustomThemedAvatar.SetShowInitials(const AValue: Boolean);
begin
  if FShowInitials = AValue then Exit;
  FShowInitials := AValue;
  Invalidate;
end;

procedure TCustomThemedAvatar.SetShape(const AValue: TThemedAvatarShape);
begin
  if FShape = AValue then Exit;
  FShape := AValue;
  InvalidateLayout;
  InvalidateImage;
end;

procedure TCustomThemedAvatar.SetSizeMode(const AValue: TThemedAvatarSize);
var LSize: Integer;
begin
  if FSizeMode = AValue then Exit;
  FSizeMode := AValue;
  case FSizeMode of
    tavCompact: LSize := 32;
    tavNormal: LSize := 48;
    tavLarge: LSize := 72;
  else
    LSize := 48;
  end;
  SetBounds(Left, Top, ScaleValue(LSize), ScaleValue(LSize));
  InvalidateImage;
end;

procedure TCustomThemedAvatar.SetStatus(const AValue: TThemedAvatarStatus);
var Old: TThemedAvatarStatus;
begin
  if FStatus = AValue then Exit;
  Old := FStatus; FStatus := AValue; InvalidateLayout;
  if Assigned(FOnStatusChanged) and not (csLoading in ComponentState) then FOnStatusChanged(Self, Old, FStatus);
end;

procedure TCustomThemedAvatar.SetShowStatus(const AValue: Boolean);
begin
  if FShowStatus = AValue then Exit;
  FShowStatus := AValue;
  InvalidateLayout;
end;

procedure TCustomThemedAvatar.SetCounter(const AValue: Integer);
var Value, Old: Integer;
begin
  Value := Max(0, AValue); if FCounter = Value then Exit;
  Old := FCounter; FCounter := Value; InvalidateLayout;
  if Assigned(FOnCounterChanged) and not (csLoading in ComponentState) then FOnCounterChanged(Self, Old, FCounter);
end;

procedure TCustomThemedAvatar.SetShowCounter(const AValue: Boolean);
begin
  if FShowCounter = AValue then Exit;
  FShowCounter := AValue;
  InvalidateLayout;
end;

procedure TCustomThemedAvatar.SetShowStar(const AValue: Boolean);
begin
  if FShowStar = AValue then Exit;
  FShowStar := AValue;
  InvalidateLayout;
end;

procedure TCustomThemedAvatar.SetCustomAvatarColor(const AValue: TColor);
begin
  if FCustomAvatarColor = AValue then Exit;
  FCustomAvatarColor := AValue;
  Invalidate;
end;

procedure TCustomThemedAvatar.SetBorderWidth(const AValue: Integer);
var LValue: Integer;
begin
  LValue := EnsureRange(AValue, 0, 8);
  if FBorderWidth = LValue then Exit;
  FBorderWidth := LValue;
  Invalidate;
end;

function TCustomThemedAvatar.GetInitials: string;
begin
  Result := InitialsForText(FText);
end;

class function TCustomThemedAvatar.InitialsForText(const AText: string): string;
var S: string; I: Integer; Next: Boolean;
begin
  Result := '';
  S := Trim(AText);
  Next := True;
  for I := 1 to Length(S) do
  begin
    if CharInSet(S[I], [' ', '-', '_', '.']) then Next := True
    else if Next then
    begin
      Result := Result + UpCase(S[I]);
      Next := False;
      if Length(Result) >= 2 then Break;
    end;
  end;
end;

procedure TCustomThemedAvatar.Resize;
begin
  inherited Resize;
  FBufferDirty := True;
  InvalidateLayout;
end;

procedure TCustomThemedAvatar.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited ChangeScale(M, D, isDpiChange);
  if FBadgeFont <> nil then FBadgeFont.Height := MulDiv(FBadgeFont.Height, M, D);
  FBufferDirty := True;
  InvalidateLayout;
end;

function TCustomThemedAvatar.GetRenderImage(const ASize: Integer): Vcl.Graphics.TBitmap;
begin
  if ASize <= 0 then Exit(nil);
  if ((FImages = nil) or (FImageIndex < 0) or (FImageIndex >= FImages.Count)) and
    ((FPicture.Graphic = nil) or FPicture.Graphic.Empty) then
  begin
    FBufferDirty := False;
    FImageBuffer.SetSize(0, 0);
    Exit(nil);
  end;
  if FBufferDirty or (FImageBuffer.Width <> ASize) or (FImageBuffer.Height <> ASize) then
    UpdateImageBuffer(ASize);
  Result := FImageBuffer;
end;

procedure TCustomThemedAvatar.UpdateImageBuffer(const ASize: Integer);
var Source: Vcl.Graphics.TBitmap; Size: Integer; Icon: TIcon;
begin
  FBufferDirty := False;
  Size := ASize;
  if Size <= 0 then Size := Min(ClientWidth, ClientHeight);
  if Size <= 0 then Exit;
  FImageBuffer.SetSize(Size, Size);
  FImageBuffer.PixelFormat := pf32bit;
  FImageBuffer.AlphaFormat := afPremultiplied;
  FImageBuffer.Canvas.Brush.Color := clBlack;
  FImageBuffer.Canvas.FillRect(Rect(0, 0, Size, Size));
  Source := Vcl.Graphics.TBitmap.Create;
  try
    if (FImages <> nil) and (FImageIndex >= 0) and (FImageIndex < FImages.Count) then
    begin
      Source.SetSize(Size, Size);
      Source.PixelFormat := pf32bit;
      Source.AlphaFormat := afPremultiplied;
      FImages.Draw(Source.Canvas, 0, 0, FImageIndex, True);
    end
    else if (FPicture.Graphic <> nil) and not FPicture.Graphic.Empty then
    begin
      if FPicture.Graphic is TIcon then
      begin
        Icon := TIcon(FPicture.Graphic);
        Source.SetSize(Size, Size);
        Source.Canvas.Draw(0, 0, Icon);
      end
      else if (FPicture.Graphic is TPngImage) or (FPicture.Graphic is TJPEGImage) then
      begin
        TThemedAvatarRenderer.PrepareImage(FPicture.Graphic, FImageBuffer, FShape);
        Exit;
      end
      else Source.Assign(FPicture.Graphic);
    end
    else
    begin
      FImageBuffer.SetSize(0, 0);
      Exit;
    end;
    TThemedAvatarRenderer.PrepareImage(Source, FImageBuffer, FShape);
  finally
    Source.Free;
  end;
end;

procedure TCustomThemedAvatar.ClearImage;
begin
  FPicture.Assign(nil);
  ImageIndex := -1;
  InvalidateImage;
end;

procedure TCustomThemedAvatar.Paint;
var FocusID, PressedID, SavedDC: Integer; DC: HDC; Origin: TPoint;
begin
  if csDestroying in ComponentState then Exit;
  inherited Paint;
  if (Parent <> nil) and Parent.HandleAllocated then
  begin
    DC := Canvas.Handle; SavedDC := SaveDC(DC);
    if SavedDC <> 0 then
    try
      GetViewportOrgEx(DC, Origin);
      SetViewportOrgEx(DC, Origin.X - Left, Origin.Y - Top, nil);
      IntersectClipRect(DC, Left, Top, Left + ClientWidth, Top + ClientHeight);
      Parent.Perform(WM_ERASEBKGND, WPARAM(DC), 0);
      Parent.Perform(WM_PRINTCLIENT, WPARAM(DC), PRF_CLIENT);
    finally
      RestoreDC(DC, SavedDC);
    end;
  end
  else
  begin
    Canvas.Brush.Color := Color;
    Canvas.FillRect(ClientRect);
  end;
  if FBufferDirty then UpdateImageBuffer;
  EnsureLayout;
  RenderCanvas.BeginRender(Canvas);
  try
    TThemedAvatarRenderer.Render(RenderCanvas, ClientRect, Palette, Font, GetInitials, FShowInitials, Enabled,
      FShape, FStatus, False, FCounter, False, False, FCustomAvatarColor, ScaleValue(FBorderWidth), FImageBuffer, FBadgeRect);
    FocusID := -1; PressedID := -1;
    if Focused then FocusID := FocusHit.BadgeID;
    if FPressed or FKeyboardPressed then PressedID := FPressedHit.BadgeID;
    TThemedAvatarRenderer.RenderBadges(RenderCanvas, Palette, FBadgeFont, FLayout, Enabled,
      FHotHit.BadgeID, PressedID, FocusID, CurrentPPI);
    if Focused and (FocusID = -2) then
      TThemedAvatarRenderer.RenderFocus(RenderCanvas, ClientRect, Palette, FShape, CurrentPPI);
  finally
    RenderCanvas.EndRender;
  end;
end;

procedure TCustomThemedAvatar.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var PressedHit, Hit: TThemedAvatarHitInfo; Activate: Boolean;
begin
  PressedHit := FPressedHit;
  Activate := (Button = mbLeft) and FPressed and not FDoubleClick;
  if Button = mbLeft then
  begin FPressed := False; FDoubleClick := False; FPressedHit := Default(TThemedAvatarHitInfo); FPressedHit.BadgeID := -1; MouseCapture := False; Invalidate; end;
  inherited MouseUp(Button, Shift, X, Y);
  Hit := HitTest(Point(X, Y));
  if Activate and (PressedHit.Part = Hit.Part) and (PressedHit.BadgeID = Hit.BadgeID) then ActivateHit(Hit);
end;

end.

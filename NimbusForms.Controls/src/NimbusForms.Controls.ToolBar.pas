{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.ToolBar;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.Types,
  System.UITypes,
  System.Generics.Collections,
  Vcl.Controls,
  Vcl.Menus,
  NimbusForms.Controls.Base,
  NimbusForms.Controls.ToolButton,
  NimbusForms.Controls.Separator,
  NimbusForms.Menus.PopupMenu;

type
  TCustomThemedToolBar = class;

  TThemedToolBarSpacer = class(TGraphicControl)
  private
    FFlexible: Boolean;
    FMinimumWidth: Integer;
    procedure SetFlexible(const AValue: Boolean);
    procedure SetMinimumWidth(const AValue: Integer);
    procedure NotifyToolBar;
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Anchors;
    property Flexible: Boolean read FFlexible write SetFlexible default True;
    property MinimumWidth: Integer read FMinimumWidth write SetMinimumWidth default 8;
    property Visible;
    property Width default 8;
  end;

  TCustomThemedToolBar = class(TCustomNimbusControl)
  private
    FAutoArrange: Boolean;
    FShowBorder: Boolean;
    FShowGrip: Boolean;
    FShowOverflow: Boolean;
    FKeyboardNavigation: Boolean;
    FWrapKeyboardNavigation: Boolean;
    FItemHeight: Integer;
    FItemSpacing: Integer;
    FGripWidth: Integer;
    FOverflowButtonWidth: Integer;
    FSeparatorWidth: Integer;
    FContentPadding: TPadding;
    FManagedOrder: TList<TControl>;
    FOverflowControls: TList<TControl>;
    FOverflowMenu: TThemedPopupMenu;
    FGripBounds: TRect;
    FOverflowButtonBounds: TRect;
    FOverflowHot: Boolean;
    FOverflowPressed: Boolean;
    FLayouting: Boolean;
    FInitialized: Boolean;
    FUpdateCount: Integer;
    FLayoutPending: Boolean;
    FCompactOverrides: Byte;
    FOnOverflowOpening: TNotifyEvent;
    FOnOverflowClosed: TNotifyEvent;
    procedure SetAutoArrange(const AValue: Boolean);
    procedure SetShowBorder(const AValue: Boolean);
    procedure SetShowGrip(const AValue: Boolean);
    procedure SetShowOverflow(const AValue: Boolean);
    procedure SetKeyboardNavigation(const AValue: Boolean);
    procedure SetWrapKeyboardNavigation(const AValue: Boolean);
    procedure SetItemHeight(const AValue: Integer);
    procedure SetItemSpacing(const AValue: Integer);
    procedure SetGripWidth(const AValue: Integer);
    procedure SetOverflowButtonWidth(const AValue: Integer);
    procedure SetSeparatorWidth(const AValue: Integer);
    procedure SetContentPadding(const AValue: TPadding);
    procedure ContentPaddingChanged(Sender: TObject);
    function IsManagedControl(const AControl: TControl): Boolean;
    function IsHostedControl(const AControl: TControl): Boolean;
    function IsFlexibleSpacer(const AControl: TControl): Boolean;
    function GetControlExtent(const AControl: TControl): Integer;
    procedure SyncManagedOrder;
    procedure RestoreOverflowControls;
    procedure BuildOverflowMenu;
    procedure AddOverflowButtonItem(const AButton: TThemedToolButton);
    function AddOverflowHostedControl(const AControl: TControl): Boolean;
    procedure AssignOverflowItemImage(const AItem: TMenuItem; const AButton: TThemedToolButton);
    procedure CloneDropDownItems(const ATarget: TMenuItem; const ASource: TMenuItem);
    procedure OverflowButtonItemClick(Sender: TObject);
    procedure OverflowComboBoxItemClick(Sender: TObject);
    procedure OverflowSourceMenuItemClick(Sender: TObject);
    function GetOverflowCount: Integer;
    function GetItemCount: Integer;
    function GetItem(AIndex: Integer): TControl;
    function IsKeyboardTarget(const AControl: TControl): Boolean;
    function FocusRelativeItem(const ASender: TWinControl; const ADelta: Integer): Boolean;
    function FocusEdgeItem(const AFirst: Boolean): Boolean;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMControlChange(var Message: TCMControlChange); message CM_CONTROLCHANGE;
    procedure CMChildKey(var Message: TCMChildKey); message CM_CHILDKEY;
    procedure CMBiDiModeChanged(var Message: TMessage); message CM_BIDIMODECHANGED;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure WMCaptureChanged(var Message: TMessage); message WM_CAPTURECHANGED;
  protected
    function CanAutoSize(var NewWidth, NewHeight: Integer): Boolean; override;
    procedure Loaded; override;
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
    procedure Paint; override;
    procedure Resize; override;
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
    procedure StyleModeChanged; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    property AutoArrange: Boolean read FAutoArrange write SetAutoArrange default True;
    property ShowBorder: Boolean read FShowBorder write SetShowBorder default True;
    property ShowGrip: Boolean read FShowGrip write SetShowGrip default True;
    property ShowOverflow: Boolean read FShowOverflow write SetShowOverflow default True;
    property KeyboardNavigation: Boolean read FKeyboardNavigation write SetKeyboardNavigation default True;
    property WrapKeyboardNavigation: Boolean read FWrapKeyboardNavigation write SetWrapKeyboardNavigation default True;
    property ItemHeight: Integer read FItemHeight write SetItemHeight default 28;
    property ItemSpacing: Integer read FItemSpacing write SetItemSpacing default 2;
    property GripWidth: Integer read FGripWidth write SetGripWidth default 12;
    property OverflowButtonWidth: Integer read FOverflowButtonWidth write SetOverflowButtonWidth default 22;
    property SeparatorWidth: Integer read FSeparatorWidth write SetSeparatorWidth default 8;
    property ContentPadding: TPadding read FContentPadding write SetContentPadding;
    property OnOverflowOpening: TNotifyEvent read FOnOverflowOpening write FOnOverflowOpening;
    property OnOverflowClosed: TNotifyEvent read FOnOverflowClosed write FOnOverflowClosed;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure RealignItems;
    procedure ShowOverflowMenu;
    procedure FocusFirstItem;
    procedure FocusLastItem;
    function IndexOfItem(const AControl: TControl): Integer;
    procedure SetItemIndex(const AControl: TControl; const AIndex: Integer);
    procedure MoveItem(const AFromIndex, AToIndex: Integer);
    property ItemCount: Integer read GetItemCount;
    property Items[AIndex: Integer]: TControl read GetItem;
    property GripBounds: TRect read FGripBounds;
    property OverflowButtonBounds: TRect read FOverflowButtonBounds;
    property OverflowCount: Integer read GetOverflowCount;
  end;

  TThemedToolBar = class(TCustomThemedToolBar)
  published
    property Align;
    property Anchors;
    property AutoArrange;
    property AutoSize;
    property BiDiMode;
    property Constraints;
    property ContentPadding;
    property StyleMode;
    property Enabled;
    property Font;
    property Hint;
    property GripWidth;
    property ItemHeight;
    property ItemSpacing;
    property KeyboardNavigation;
    property OverflowButtonWidth;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property SeparatorWidth;
    property ShowBorder;
    property ShowGrip;
    property ShowHint;
    property ShowOverflow;
    property TabOrder;
    property TabStop default False;
    property Visible;
    property WrapKeyboardNavigation;
    property OnOverflowOpening;
    property OnOverflowClosed;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
  end;

implementation

uses
  System.Math,
  Vcl.Graphics,
  Vcl.ImgList,
  Vcl.Forms,
  NimbusForms.Controls.Types,
  NimbusForms.Controls.ThemedLabel,
  NimbusForms.Controls.TextBox,
  NimbusForms.Controls.ComboBox,
  NimbusForms.Rendering.ToolBar;

type
  TThemedComboBoxAccess = class(TThemedComboBox)
  public
    procedure NotifyToolbarSelectionChanged;
  end;

procedure TThemedComboBoxAccess.NotifyToolbarSelectionChanged;
begin
  Click;
  Select;
end;

constructor TThemedToolBarSpacer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 8;
  Height := 24;
  FFlexible := True;
  FMinimumWidth := 8;
end;

procedure TThemedToolBarSpacer.NotifyToolBar;
begin
  if Parent is TCustomThemedToolBar then TCustomThemedToolBar(Parent).RealignItems;
end;

procedure TThemedToolBarSpacer.SetFlexible(const AValue: Boolean);
begin
  if FFlexible = AValue then Exit;
  FFlexible := AValue;
  NotifyToolBar;
end;

procedure TThemedToolBarSpacer.SetMinimumWidth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := EnsureRange(AValue, 0, 256);
  if FMinimumWidth = LValue then Exit;
  FMinimumWidth := LValue;
  NotifyToolBar;
end;

procedure TThemedToolBarSpacer.SetParent(AParent: TWinControl);
var
  LOldParent: TWinControl;
begin
  LOldParent := Parent;
  inherited SetParent(AParent);
  if LOldParent is TCustomThemedToolBar then TCustomThemedToolBar(LOldParent).RealignItems;
  NotifyToolBar;
end;

procedure TThemedToolBarSpacer.Resize;
begin
  inherited Resize;
  if not FFlexible then NotifyToolBar;
end;

procedure TThemedToolBarSpacer.Paint;
begin
end;

constructor TCustomThemedToolBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := (ControlStyle + [csAcceptsControls]) - [csCaptureMouse];
  Width := 500;
  Height := 32;
  TabStop := False;
  FAutoArrange := True;
  FShowBorder := True;
  FShowGrip := True;
  FShowOverflow := True;
  FKeyboardNavigation := True;
  FWrapKeyboardNavigation := True;
  FItemHeight := 28;
  FItemSpacing := 2;
  FGripWidth := 12;
  FOverflowButtonWidth := 22;
  FSeparatorWidth := 8;
  FContentPadding := TPadding.Create(Self);
  FContentPadding.SetBounds(2, 2, 2, 2);
  FContentPadding.OnChange := ContentPaddingChanged;
  FManagedOrder := TList<TControl>.Create;
  FOverflowControls := TList<TControl>.Create;
  FOverflowMenu := TThemedPopupMenu.Create(Self);
  FUpdateCount := 0;
  FLayoutPending := False;
  FInitialized := True;
end;

destructor TCustomThemedToolBar.Destroy;
begin
  FInitialized := False;
  if MouseCapture then MouseCapture := False;
  FOverflowControls.Free;
  FOverflowControls := nil;
  FManagedOrder.Free;
  FManagedOrder := nil;
  FContentPadding.Free;
  FContentPadding := nil;
  inherited Destroy;
end;

procedure TCustomThemedToolBar.StyleModeChanged;
begin
  inherited StyleModeChanged;
  BeginUpdate;
  try
    if StyleMode = stCompact then
    begin
      FCompactOverrides := 0;
      if FItemHeight = 28 then begin FItemHeight := 24; FCompactOverrides := FCompactOverrides or 1; end;
      if FItemSpacing = 2 then begin FItemSpacing := 1; FCompactOverrides := FCompactOverrides or 2; end;
      if FGripWidth = 12 then begin FGripWidth := 8; FCompactOverrides := FCompactOverrides or 4; end;
      if FOverflowButtonWidth = 22 then begin FOverflowButtonWidth := 18; FCompactOverrides := FCompactOverrides or 8; end;
      if FSeparatorWidth = 8 then begin FSeparatorWidth := 6; FCompactOverrides := FCompactOverrides or 16; end;
      if (FContentPadding.Left = 2) and (FContentPadding.Right = 2) and
        (FContentPadding.Top = 2) and (FContentPadding.Bottom = 2) then
      begin
        FContentPadding.SetBounds(1, 1, 1, 1);
        FCompactOverrides := FCompactOverrides or 32;
      end;
      if Height = ScaleValue(32) then
      begin
        Height := ScaleValue(26);
        FCompactOverrides := FCompactOverrides or 64;
      end;
    end
    else
    begin
      if ((FCompactOverrides and 1) <> 0) and (FItemHeight = 24) then FItemHeight := 28;
      if ((FCompactOverrides and 2) <> 0) and (FItemSpacing = 1) then FItemSpacing := 2;
      if ((FCompactOverrides and 4) <> 0) and (FGripWidth = 8) then FGripWidth := 12;
      if ((FCompactOverrides and 8) <> 0) and (FOverflowButtonWidth = 18) then FOverflowButtonWidth := 22;
      if ((FCompactOverrides and 16) <> 0) and (FSeparatorWidth = 6) then FSeparatorWidth := 8;
      if ((FCompactOverrides and 32) <> 0) and
        (FContentPadding.Left = 1) and (FContentPadding.Right = 1) and
        (FContentPadding.Top = 1) and (FContentPadding.Bottom = 1) then
        FContentPadding.SetBounds(2, 2, 2, 2);
      if ((FCompactOverrides and 64) <> 0) and (Height = ScaleValue(26)) then Height := ScaleValue(32);
      FCompactOverrides := 0;
    end;
    if AutoSize then AdjustSize;
  finally
    EndUpdate;
  end;
  RealignItems;
end;

function TCustomThemedToolBar.CanAutoSize(var NewWidth, NewHeight: Integer): Boolean;
begin
  Result := inherited CanAutoSize(NewWidth, NewHeight);
  if Result and FInitialized then NewHeight := ScaleValue(FItemHeight + FContentPadding.Top + FContentPadding.Bottom);
end;

procedure TCustomThemedToolBar.Loaded;
begin
  inherited Loaded;
  RealignItems;
end;

procedure TCustomThemedToolBar.SetAutoArrange(const AValue: Boolean);
begin
  if FAutoArrange = AValue then Exit;
  FAutoArrange := AValue;
  RealignItems;
end;

procedure TCustomThemedToolBar.SetShowBorder(const AValue: Boolean);
begin
  if FShowBorder = AValue then Exit;
  FShowBorder := AValue;
  Invalidate;
end;

procedure TCustomThemedToolBar.SetShowGrip(const AValue: Boolean);
begin
  if FShowGrip = AValue then Exit;
  FShowGrip := AValue;
  RealignItems;
end;

procedure TCustomThemedToolBar.SetShowOverflow(const AValue: Boolean);
begin
  if FShowOverflow = AValue then Exit;
  FShowOverflow := AValue;
  RealignItems;
end;

procedure TCustomThemedToolBar.SetKeyboardNavigation(const AValue: Boolean);
begin
  FKeyboardNavigation := AValue;
end;

procedure TCustomThemedToolBar.SetWrapKeyboardNavigation(const AValue: Boolean);
begin
  FWrapKeyboardNavigation := AValue;
end;

procedure TCustomThemedToolBar.SetItemHeight(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := EnsureRange(AValue, 18, 96);
  if FItemHeight = LValue then Exit;
  FItemHeight := LValue;
  if AutoSize then AdjustSize;
  RealignItems;
end;

procedure TCustomThemedToolBar.SetItemSpacing(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := EnsureRange(AValue, 0, 32);
  if FItemSpacing = LValue then Exit;
  FItemSpacing := LValue;
  RealignItems;
end;

procedure TCustomThemedToolBar.SetGripWidth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := EnsureRange(AValue, 6, 48);
  if FGripWidth = LValue then Exit;
  FGripWidth := LValue;
  RealignItems;
end;

procedure TCustomThemedToolBar.SetOverflowButtonWidth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := EnsureRange(AValue, 16, 64);
  if FOverflowButtonWidth = LValue then Exit;
  FOverflowButtonWidth := LValue;
  RealignItems;
end;

procedure TCustomThemedToolBar.SetSeparatorWidth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := EnsureRange(AValue, 4, 32);
  if FSeparatorWidth = LValue then Exit;
  FSeparatorWidth := LValue;
  RealignItems;
end;

procedure TCustomThemedToolBar.SetContentPadding(const AValue: TPadding);
begin
  FContentPadding.Assign(AValue);
end;

procedure TCustomThemedToolBar.ContentPaddingChanged(Sender: TObject);
begin
  if AutoSize then AdjustSize;
  RealignItems;
end;

function TCustomThemedToolBar.IsManagedControl(const AControl: TControl): Boolean;
begin
  Result := (AControl is TThemedToolButton) or (AControl is TThemedSeparator) or
    (AControl is TThemedToolBarSpacer) or IsHostedControl(AControl);
end;

function TCustomThemedToolBar.IsHostedControl(const AControl: TControl): Boolean;
begin
  Result := (AControl is TThemedLabel) or (AControl is TThemedTextBox) or
    (AControl is TThemedComboBox);
end;

function TCustomThemedToolBar.IsFlexibleSpacer(const AControl: TControl): Boolean;
begin
  Result := (AControl is TThemedToolBarSpacer) and TThemedToolBarSpacer(AControl).Flexible;
end;

function TCustomThemedToolBar.GetControlExtent(const AControl: TControl): Integer;
begin
  if AControl is TThemedSeparator then
    Result := ScaleValue(FSeparatorWidth)
  else if IsFlexibleSpacer(AControl) then
    Result := ScaleValue(TThemedToolBarSpacer(AControl).MinimumWidth)
  else
    Result := Max(1, AControl.Width);
end;

function TCustomThemedToolBar.GetOverflowCount: Integer;
begin
  Result := FOverflowControls.Count;
end;

function TCustomThemedToolBar.GetItemCount: Integer;
begin
  SyncManagedOrder;
  Result := FManagedOrder.Count;
end;

function TCustomThemedToolBar.GetItem(AIndex: Integer): TControl;
begin
  SyncManagedOrder;
  Result := FManagedOrder[AIndex];
end;

procedure TCustomThemedToolBar.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TCustomThemedToolBar.EndUpdate;
begin
  if FUpdateCount <= 0 then Exit;
  Dec(FUpdateCount);
  if (FUpdateCount = 0) and FLayoutPending then
  begin
    FLayoutPending := False;
    RealignItems;
  end;
end;

function TCustomThemedToolBar.IndexOfItem(const AControl: TControl): Integer;
begin
  SyncManagedOrder;
  Result := FManagedOrder.IndexOf(AControl);
end;

procedure TCustomThemedToolBar.SetItemIndex(const AControl: TControl; const AIndex: Integer);
var
  LCurrent, LTarget: Integer;
begin
  if (AControl = nil) or (AControl.Parent <> Self) or not IsManagedControl(AControl) then Exit;
  SyncManagedOrder;
  LCurrent := FManagedOrder.IndexOf(AControl);
  if LCurrent < 0 then Exit;
  LTarget := EnsureRange(AIndex, 0, FManagedOrder.Count - 1);
  if LCurrent = LTarget then Exit;
  FManagedOrder.Delete(LCurrent);
  if LTarget > FManagedOrder.Count then LTarget := FManagedOrder.Count;
  FManagedOrder.Insert(LTarget, AControl);
  RealignItems;
end;

procedure TCustomThemedToolBar.MoveItem(const AFromIndex, AToIndex: Integer);
var
  LControl: TControl;
begin
  SyncManagedOrder;
  if (AFromIndex < 0) or (AFromIndex >= FManagedOrder.Count) then Exit;
  LControl := FManagedOrder[AFromIndex];
  SetItemIndex(LControl, AToIndex);
end;

procedure TCustomThemedToolBar.SyncManagedOrder;
var
  I: Integer;
  LControl: TControl;
begin
  for I := FManagedOrder.Count - 1 downto 0 do
  begin
    LControl := FManagedOrder[I];
    if (LControl = nil) or (LControl.Parent <> Self) or not IsManagedControl(LControl) then
      FManagedOrder.Delete(I);
  end;
  for I := 0 to ControlCount - 1 do
  begin
    LControl := Controls[I];
    if IsManagedControl(LControl) and (FManagedOrder.IndexOf(LControl) < 0) then
      FManagedOrder.Add(LControl);
  end;
end;

procedure TCustomThemedToolBar.RestoreOverflowControls;
var
  I: Integer;
  LControl: TControl;
begin
  for I := 0 to FOverflowControls.Count - 1 do
  begin
    LControl := FOverflowControls[I];
    if (LControl <> nil) and (LControl.Parent = Self) then LControl.Visible := True;
  end;
  FOverflowControls.Clear;
end;

procedure TCustomThemedToolBar.RealignItems;
var
  LItems: TList<TControl>;
  LContent: TRect;
  LControl: TControl;
  LHidden: array of Boolean;
  I, LSpacing, LGrip, LOverflowWidth, LAvailable, LTargetWidth, LLayoutWidth, LFocusIndex: Integer;
  LExtent, LPos, LTop, LHeight, LFlexCount, LExtra, LShare, LRemainder: Integer;
  LRTL, LNeedOverflow: Boolean;

  function RequiredWidth: Integer;
  var
    K, LCount: Integer;
  begin
    Result := LGrip;
    LCount := 0;
    for K := 0 to LItems.Count - 1 do
    begin
      if LHidden[K] then Continue;
      if LCount > 0 then
        Inc(Result, LSpacing)
      else if LGrip > 0 then
        Inc(Result, LSpacing);
      Inc(Result, GetControlExtent(LItems[K]));
      Inc(LCount);
    end;
  end;

  function HasVisibleContentBefore(const AIndex: Integer): Boolean;
  var
    K: Integer;
  begin
    Result := False;
    for K := AIndex - 1 downto 0 do
    begin
      if LHidden[K] then Continue;
      if IsFlexibleSpacer(LItems[K]) then Exit;
      if not (LItems[K] is TThemedSeparator) then Exit(True);
    end;
  end;

  function HasVisibleContentAfter(const AIndex: Integer): Boolean;
  var
    K: Integer;
  begin
    Result := False;
    for K := AIndex + 1 to LItems.Count - 1 do
    begin
      if LHidden[K] then Continue;
      if IsFlexibleSpacer(LItems[K]) then Exit;
      if not (LItems[K] is TThemedSeparator) then Exit(True);
    end;
  end;

  procedure HideCandidate(const AIndex: Integer);
  begin
    if (AIndex < 0) or (AIndex >= LItems.Count) or LHidden[AIndex] then Exit;
    if LItems[AIndex] is TThemedToolBarSpacer then Exit;
    LHidden[AIndex] := True;
  end;

  procedure NormalizeSeparators;
  var
    K: Integer;
  begin
    for K := 0 to LItems.Count - 1 do
      if not LHidden[K] and (LItems[K] is TThemedSeparator) and
        (not HasVisibleContentBefore(K) or not HasVisibleContentAfter(K)) then
        LHidden[K] := True;
  end;

  function LayoutExtent(const AIndex: Integer): Integer;
  begin
    Result := GetControlExtent(LItems[AIndex]);
    if IsFlexibleSpacer(LItems[AIndex]) and (LFlexCount > 0) then
    begin
      Inc(Result, LShare);
      if LRemainder > 0 then
      begin
        Inc(Result);
        Dec(LRemainder);
      end;
    end;
  end;

  function ContainsActiveControl(const AControl: TControl): Boolean;
  var
    LActive: TWinControl;
  begin
    Result := False;
    if not (AControl is TWinControl) then Exit;
    LActive := Screen.ActiveControl;
    while LActive <> nil do
    begin
      if LActive = AControl then Exit(True);
      LActive := LActive.Parent;
    end;
  end;

  procedure FocusNearestVisible(const AIndex: Integer);
  var
    K: Integer;
  begin
    for K := AIndex - 1 downto 0 do
      if not LHidden[K] and IsKeyboardTarget(LItems[K]) then
      begin
        TWinControl(LItems[K]).SetFocus;
        Exit;
      end;
    for K := AIndex + 1 to LItems.Count - 1 do
      if not LHidden[K] and IsKeyboardTarget(LItems[K]) then
      begin
        TWinControl(LItems[K]).SetFocus;
        Exit;
      end;
  end;

begin
  if not FInitialized or (csDestroying in ComponentState) then Exit;
  if FUpdateCount > 0 then
  begin
    FLayoutPending := True;
    Exit;
  end;
  if FLayouting then Exit;
  FLayoutPending := False;
  FLayouting := True;
  try
    RestoreOverflowControls;
    FGripBounds := Rect(0, 0, 0, 0);
    FOverflowButtonBounds := Rect(0, 0, 0, 0);
    FOverflowHot := False;
    FOverflowPressed := False;
    if not FAutoArrange then
    begin
      Invalidate;
      Exit;
    end;
    LContent := ClientRect;
    Inc(LContent.Left, ScaleValue(FContentPadding.Left));
    Inc(LContent.Top, ScaleValue(FContentPadding.Top));
    Dec(LContent.Right, ScaleValue(FContentPadding.Right));
    Dec(LContent.Bottom, ScaleValue(FContentPadding.Bottom));
    if (LContent.Width <= 0) or (LContent.Height <= 0) then
    begin
      Invalidate;
      Exit;
    end;
    LItems := TList<TControl>.Create;
    try
      SyncManagedOrder;
      for I := 0 to FManagedOrder.Count - 1 do
      begin
        LControl := FManagedOrder[I];
        if LControl.Visible then LItems.Add(LControl);
      end;
      SetLength(LHidden, LItems.Count);
      LFocusIndex := -1;
      for I := 0 to LItems.Count - 1 do
        if ContainsActiveControl(LItems[I]) then
        begin
          LFocusIndex := I;
          Break;
        end;
      LSpacing := ScaleValue(FItemSpacing);
      LGrip := 0;
      if FShowGrip then LGrip := ScaleValue(FGripWidth);
      LAvailable := LContent.Width;
      LOverflowWidth := ScaleValue(FOverflowButtonWidth);
      LNeedOverflow := FShowOverflow and not (csDesigning in ComponentState) and
        (LItems.Count > 0) and (RequiredWidth > LAvailable);
      if LNeedOverflow then
      begin
        LTargetWidth := Max(0, LAvailable - LOverflowWidth - LSpacing);
        I := LItems.Count - 1;
        while (I >= 0) and (RequiredWidth > LTargetWidth) do
        begin
          HideCandidate(I);
          NormalizeSeparators;
          Dec(I);
        end;
        NormalizeSeparators;
        for I := 0 to LItems.Count - 1 do
          if LHidden[I] then
          begin
            FOverflowControls.Add(LItems[I]);
            LItems[I].Visible := False;
          end;
        if (LFocusIndex >= 0) and LHidden[LFocusIndex] then FocusNearestVisible(LFocusIndex);
      end;
      LRTL := BiDiMode = bdRightToLeft;
      if FShowGrip then
      begin
        if LRTL then FGripBounds := Rect(LContent.Right - LGrip, LContent.Top, LContent.Right, LContent.Bottom)
        else FGripBounds := Rect(LContent.Left, LContent.Top, LContent.Left + LGrip, LContent.Bottom);
      end;
      if FOverflowControls.Count > 0 then
      begin
        if LRTL then FOverflowButtonBounds := Rect(LContent.Left, LContent.Top, LContent.Left + LOverflowWidth, LContent.Bottom)
        else FOverflowButtonBounds := Rect(LContent.Right - LOverflowWidth, LContent.Top, LContent.Right, LContent.Bottom);
      end;
      LLayoutWidth := LAvailable;
      if FOverflowControls.Count > 0 then LLayoutWidth := Max(0, LLayoutWidth - LOverflowWidth - LSpacing);
      LFlexCount := 0;
      for I := 0 to LItems.Count - 1 do
        if not LHidden[I] and IsFlexibleSpacer(LItems[I]) then Inc(LFlexCount);
      LExtra := Max(0, LLayoutWidth - RequiredWidth);
      LShare := 0;
      LRemainder := 0;
      if LFlexCount > 0 then
      begin
        LShare := LExtra div LFlexCount;
        LRemainder := LExtra mod LFlexCount;
      end;
      LHeight := Min(ScaleValue(FItemHeight), LContent.Height);
      LTop := LContent.Top + (LContent.Height - LHeight) div 2;
      if LRTL then
      begin
        LPos := LContent.Right;
        if FShowGrip then Dec(LPos, LGrip + LSpacing);
        for I := 0 to LItems.Count - 1 do
        begin
          if LHidden[I] then Continue;
          LControl := LItems[I];
          LExtent := LayoutExtent(I);
          Dec(LPos, LExtent);
          if LControl is TThemedSeparator then
          begin
            TThemedSeparator(LControl).Orientation := tsoVertical;
            LControl.SetBounds(LPos, LContent.Top, LExtent, LContent.Height);
          end
          else if LControl is TThemedToolBarSpacer then
            LControl.SetBounds(LPos, LContent.Top, LExtent, LContent.Height)
          else
            LControl.SetBounds(LPos, LTop, LExtent, LHeight);
          Dec(LPos, LSpacing);
        end;
      end
      else
      begin
        LPos := LContent.Left;
        if FShowGrip then Inc(LPos, LGrip + LSpacing);
        for I := 0 to LItems.Count - 1 do
        begin
          if LHidden[I] then Continue;
          LControl := LItems[I];
          LExtent := LayoutExtent(I);
          if LControl is TThemedSeparator then
          begin
            TThemedSeparator(LControl).Orientation := tsoVertical;
            LControl.SetBounds(LPos, LContent.Top, LExtent, LContent.Height);
          end
          else if LControl is TThemedToolBarSpacer then
            LControl.SetBounds(LPos, LContent.Top, LExtent, LContent.Height)
          else
            LControl.SetBounds(LPos, LTop, LExtent, LHeight);
          Inc(LPos, LExtent + LSpacing);
        end;
      end;
    finally
      LItems.Free;
    end;
  finally
    FLayouting := False;
  end;
  Invalidate;
end;

procedure TCustomThemedToolBar.AlignControls(AControl: TControl; var Rect: TRect);
begin
  inherited AlignControls(AControl, Rect);
  if FInitialized and FAutoArrange and not FLayouting then RealignItems;
end;

procedure TCustomThemedToolBar.Resize;
begin
  inherited Resize;
  RealignItems;
end;

procedure TCustomThemedToolBar.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited ChangeScale(M, D, isDpiChange);
  RealignItems;
end;

procedure TCustomThemedToolBar.CMControlChange(var Message: TCMControlChange);
begin
  if FManagedOrder <> nil then
  begin
    if Message.Inserting then
    begin
      if (Message.Control <> nil) and IsManagedControl(Message.Control) and
        (FManagedOrder.IndexOf(Message.Control) < 0) then
        FManagedOrder.Add(Message.Control);
    end
    else if Message.Control <> nil then
    begin
      FManagedOrder.Remove(Message.Control);
      if FOverflowControls <> nil then FOverflowControls.Remove(Message.Control);
    end;
  end;
  inherited;
  if FInitialized and not FLayouting then RealignItems;
end;

function TCustomThemedToolBar.IsKeyboardTarget(const AControl: TControl): Boolean;
begin
  Result := (AControl is TWinControl) and IsManagedControl(AControl) and
    not (AControl is TThemedSeparator) and not (AControl is TThemedToolBarSpacer) and
    AControl.Visible and AControl.Enabled and TWinControl(AControl).CanFocus;
end;

function TCustomThemedToolBar.FocusRelativeItem(const ASender: TWinControl; const ADelta: Integer): Boolean;
var
  LControls: TList<TWinControl>;
  I, LIndex, LNext: Integer;
  LControl: TWinControl;
begin
  Result := False;
  if ADelta = 0 then Exit;
  LControls := TList<TWinControl>.Create;
  try
    SyncManagedOrder;
    for I := 0 to FManagedOrder.Count - 1 do
      if IsKeyboardTarget(FManagedOrder[I]) then LControls.Add(TWinControl(FManagedOrder[I]));
    if LControls.Count = 0 then Exit;
    LIndex := LControls.IndexOf(ASender);
    if LIndex < 0 then
    begin
      if ADelta > 0 then LNext := 0 else LNext := LControls.Count - 1;
    end
    else
    begin
      LNext := LIndex + ADelta;
      if FWrapKeyboardNavigation then
      begin
        if LNext < 0 then LNext := LControls.Count - 1;
        if LNext >= LControls.Count then LNext := 0;
      end
      else if (LNext < 0) or (LNext >= LControls.Count) then
        Exit;
    end;
    LControl := LControls[LNext];
    if LControl.CanFocus then
    begin
      LControl.SetFocus;
      Result := True;
    end;
  finally
    LControls.Free;
  end;
end;

function TCustomThemedToolBar.FocusEdgeItem(const AFirst: Boolean): Boolean;
var
  I, LStart, LStop, LStep: Integer;
  LControl: TWinControl;
begin
  Result := False;
  SyncManagedOrder;
  if AFirst then
  begin
    LStart := 0;
    LStop := FManagedOrder.Count - 1;
    LStep := 1;
  end
  else
  begin
    LStart := FManagedOrder.Count - 1;
    LStop := 0;
    LStep := -1;
  end;
  I := LStart;
  while ((LStep > 0) and (I <= LStop)) or ((LStep < 0) and (I >= LStop)) do
  begin
    if IsKeyboardTarget(FManagedOrder[I]) then
    begin
      LControl := TWinControl(FManagedOrder[I]);
      LControl.SetFocus;
      Exit(True);
    end;
    Inc(I, LStep);
  end;
end;

procedure TCustomThemedToolBar.FocusFirstItem;
begin
  FocusEdgeItem(True);
end;

procedure TCustomThemedToolBar.FocusLastItem;
begin
  FocusEdgeItem(False);
end;

procedure TCustomThemedToolBar.CMChildKey(var Message: TCMChildKey);
var
  LDelta: Integer;
  LButton: TThemedToolButton;
begin
  if FKeyboardNavigation and Enabled and (Message.Sender is TThemedToolButton) and (Message.Sender.Parent = Self) then
  begin
    LButton := TThemedToolButton(Message.Sender);
    case Message.CharCode of
      VK_LEFT:
        begin
          if BiDiMode = bdRightToLeft then LDelta := 1 else LDelta := -1;
          if FocusRelativeItem(Message.Sender, LDelta) then
          begin
            Message.Result := 1;
            Exit;
          end;
        end;
      VK_RIGHT:
        begin
          if BiDiMode = bdRightToLeft then LDelta := -1 else LDelta := 1;
          if FocusRelativeItem(Message.Sender, LDelta) then
          begin
            Message.Result := 1;
            Exit;
          end;
        end;
      VK_HOME:
        if FocusEdgeItem(True) then
        begin
          Message.Result := 1;
          Exit;
        end;
      VK_END:
        if FocusEdgeItem(False) then
        begin
          Message.Result := 1;
          Exit;
        end;
      VK_DOWN:
        begin
          if LButton.DropDownMode <> ttbddNone then
          begin
            LButton.ShowDropDown;
            Message.Result := 1;
            Exit;
          end;
          if FOverflowControls.Count > 0 then
          begin
            ShowOverflowMenu;
            Message.Result := 1;
            Exit;
          end;
        end;
    end;
  end;
  inherited;
end;

procedure TCustomThemedToolBar.CMBiDiModeChanged(var Message: TMessage);
begin
  inherited;
  RealignItems;
end;

procedure TCustomThemedToolBar.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  if not Enabled then
  begin
    FOverflowHot := False;
    FOverflowPressed := False;
    if MouseCapture then MouseCapture := False;
  end;
  Invalidate;
end;

procedure TCustomThemedToolBar.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if not MouseCapture and FOverflowHot then
  begin
    FOverflowHot := False;
    Invalidate;
  end;
end;

procedure TCustomThemedToolBar.WMCaptureChanged(var Message: TMessage);
begin
  inherited;
  if not MouseCapture and FOverflowPressed then
  begin
    FOverflowPressed := False;
    Invalidate;
  end;
end;

procedure TCustomThemedToolBar.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LHot: Boolean;
begin
  inherited MouseMove(Shift, X, Y);
  LHot := Enabled and (FOverflowControls.Count > 0) and PtInRect(FOverflowButtonBounds, Point(X, Y));
  if FOverflowHot <> LHot then
  begin
    FOverflowHot := LHot;
    Invalidate;
  end;
end;

procedure TCustomThemedToolBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button = mbLeft) and Enabled and (FOverflowControls.Count > 0) and PtInRect(FOverflowButtonBounds, Point(X, Y)) then
  begin
    FOverflowPressed := True;
    MouseCapture := True;
    Invalidate;
  end;
end;

procedure TCustomThemedToolBar.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LPressed, LInside: Boolean;
begin
  inherited MouseUp(Button, Shift, X, Y);
  if Button <> mbLeft then Exit;
  LPressed := FOverflowPressed;
  LInside := PtInRect(FOverflowButtonBounds, Point(X, Y));
  FOverflowPressed := False;
  if MouseCapture then MouseCapture := False;
  Invalidate;
  if LPressed and LInside then ShowOverflowMenu;
end;

procedure TCustomThemedToolBar.AssignOverflowItemImage(const AItem: TMenuItem; const AButton: TThemedToolButton);
begin
  if (AItem = nil) or (AButton = nil) then Exit;
  if (AButton.Icon <> nil) and not AButton.Icon.Empty then
    AItem.Bitmap.Assign(AButton.Icon)
  else if (AButton.Images <> nil) and (AButton.ImageIndex >= 0) and (AButton.ImageIndex < AButton.Images.Count) then
    AButton.Images.GetBitmap(AButton.ImageIndex, AItem.Bitmap);
end;

procedure TCustomThemedToolBar.CloneDropDownItems(const ATarget: TMenuItem; const ASource: TMenuItem);
var
  I: Integer;
  LSource, LItem: TMenuItem;
begin
  if (ATarget = nil) or (ASource = nil) then Exit;
  for I := 0 to ASource.Count - 1 do
  begin
    LSource := ASource[I];
    if not LSource.Visible then Continue;
    LItem := TMenuItem.Create(FOverflowMenu);
    LItem.Caption := LSource.Caption;
    LItem.Enabled := LSource.Enabled;
    LItem.Checked := LSource.Checked;
    LItem.AutoCheck := LSource.AutoCheck;
    LItem.Default := LSource.Default;
    LItem.RadioItem := LSource.RadioItem;
    LItem.GroupIndex := LSource.GroupIndex;
    LItem.ShortCut := LSource.ShortCut;
    LItem.Hint := LSource.Hint;
    LItem.HelpContext := LSource.HelpContext;
    if not LSource.Bitmap.Empty then LItem.Bitmap.Assign(LSource.Bitmap);
    if LSource.Caption <> '-' then
    begin
      LItem.Tag := NativeInt(LSource);
      if LSource.Count = 0 then LItem.OnClick := OverflowSourceMenuItemClick;
    end;
    ATarget.Add(LItem);
    if LSource.Count > 0 then CloneDropDownItems(LItem, LSource);
  end;
end;

procedure TCustomThemedToolBar.AddOverflowButtonItem(const AButton: TThemedToolButton);
var
  LRoot, LAction, LSeparator: TMenuItem;
  LCaption: string;
begin
  if AButton = nil then Exit;
  LCaption := AButton.Caption;
  if LCaption = '' then LCaption := AButton.Name;
  if (AButton.DropDownMode <> ttbddNone) and (AButton.DropDownMenu <> nil) and (AButton.DropDownMenu.Items.Count > 0) then
  begin
    LRoot := TMenuItem.Create(FOverflowMenu);
    LRoot.Caption := LCaption;
    LRoot.Enabled := AButton.Enabled;
    LRoot.Hint := AButton.Hint;
    AssignOverflowItemImage(LRoot, AButton);
    FOverflowMenu.Items.Add(LRoot);
    if AButton.DropDownMode = ttbddSplit then
    begin
      LAction := TMenuItem.Create(FOverflowMenu);
      LAction.Caption := LCaption;
      LAction.Enabled := AButton.Enabled;
      LAction.Checked := AButton.Checkable and AButton.Checked;
      LAction.AutoCheck := AButton.Checkable;
      LAction.Hint := AButton.Hint;
      AssignOverflowItemImage(LAction, AButton);
      LAction.Tag := NativeInt(AButton);
      LAction.OnClick := OverflowButtonItemClick;
      LRoot.Add(LAction);
      LSeparator := TMenuItem.Create(FOverflowMenu);
      LSeparator.Caption := '-';
      LRoot.Add(LSeparator);
    end;
    CloneDropDownItems(LRoot, AButton.DropDownMenu.Items);
  end
  else
  begin
    LRoot := TMenuItem.Create(FOverflowMenu);
    LRoot.Caption := LCaption;
    LRoot.Enabled := AButton.Enabled;
    LRoot.Checked := AButton.Checkable and AButton.Checked;
    LRoot.AutoCheck := AButton.Checkable;
    LRoot.Hint := AButton.Hint;
    AssignOverflowItemImage(LRoot, AButton);
    LRoot.Tag := NativeInt(AButton);
    LRoot.OnClick := OverflowButtonItemClick;
    FOverflowMenu.Items.Add(LRoot);
  end;
end;

function TCustomThemedToolBar.AddOverflowHostedControl(const AControl: TControl): Boolean;
var
  LItem, LChild: TMenuItem;
  LLabel: TThemedLabel;
  LTextBox: TThemedTextBox;
  LComboBox: TThemedComboBox;
  LCaption: string;
  I: Integer;
begin
  Result := False;
  if AControl is TThemedLabel then
  begin
    LLabel := TThemedLabel(AControl);
    LCaption := LLabel.Caption;
    if LCaption = '' then LCaption := LLabel.Name;
    if LCaption = '' then Exit;
    LItem := TMenuItem.Create(FOverflowMenu);
    LItem.Caption := LCaption;
    LItem.Enabled := False;
    LItem.Hint := LLabel.Hint;
    FOverflowMenu.Items.Add(LItem);
    Exit(True);
  end;
  if AControl is TThemedTextBox then
  begin
    LTextBox := TThemedTextBox(AControl);
    LCaption := LTextBox.Text;
    if LCaption = '' then LCaption := LTextBox.PlaceholderText;
    if LCaption = '' then LCaption := LTextBox.Name;
    if LCaption = '' then Exit;
    LItem := TMenuItem.Create(FOverflowMenu);
    LItem.Caption := LCaption;
    LItem.Enabled := False;
    LItem.Hint := LTextBox.Hint;
    FOverflowMenu.Items.Add(LItem);
    Exit(True);
  end;
  if AControl is TThemedComboBox then
  begin
    LComboBox := TThemedComboBox(AControl);
    LCaption := LComboBox.Text;
    if LCaption = '' then LCaption := LComboBox.Name;
    if LCaption = '' then LCaption := LComboBox.ClassName;
    LItem := TMenuItem.Create(FOverflowMenu);
    LItem.Caption := LCaption;
    LItem.Enabled := LComboBox.Enabled and (LComboBox.Items.Count > 0);
    LItem.Hint := LComboBox.Hint;
    LItem.Tag := NativeInt(LComboBox);
    FOverflowMenu.Items.Add(LItem);
    for I := 0 to LComboBox.Items.Count - 1 do
    begin
      LChild := TMenuItem.Create(FOverflowMenu);
      LChild.Caption := LComboBox.Items[I];
      LChild.Enabled := LComboBox.Enabled;
      LChild.Checked := I = LComboBox.ItemIndex;
      LChild.RadioItem := True;
      LChild.Tag := I + 1;
      LChild.OnClick := OverflowComboBoxItemClick;
      LItem.Add(LChild);
    end;
    Exit(True);
  end;
end;

procedure TCustomThemedToolBar.BuildOverflowMenu;
var
  I: Integer;
  LControl: TControl;
  LItem: TMenuItem;
  LLastSeparator: Boolean;
begin
  FOverflowMenu.Items.Clear;
  LLastSeparator := True;
  for I := 0 to FOverflowControls.Count - 1 do
  begin
    LControl := FOverflowControls[I];
    if LControl is TThemedSeparator then
    begin
      if not LLastSeparator and (I < FOverflowControls.Count - 1) then
      begin
        LItem := TMenuItem.Create(FOverflowMenu);
        LItem.Caption := '-';
        FOverflowMenu.Items.Add(LItem);
        LLastSeparator := True;
      end;
    end
    else if LControl is TThemedToolButton then
    begin
      AddOverflowButtonItem(TThemedToolButton(LControl));
      LLastSeparator := False;
    end
    else if AddOverflowHostedControl(LControl) then
      LLastSeparator := False;
  end;
  if (FOverflowMenu.Items.Count > 0) and (FOverflowMenu.Items[FOverflowMenu.Items.Count - 1].Caption = '-') then FOverflowMenu.Items.Delete(FOverflowMenu.Items.Count - 1);
end;

procedure TCustomThemedToolBar.OverflowButtonItemClick(Sender: TObject);
var
  LButton: TThemedToolButton;
begin
  if not (Sender is TMenuItem) or (TMenuItem(Sender).Tag = 0) then Exit;
  LButton := TThemedToolButton(Pointer(TMenuItem(Sender).Tag));
  if (LButton = nil) or (LButton.Parent <> Self) or not LButton.Enabled then Exit;
  if LButton.DropDownMode = ttbddArrow then LButton.PerformDropDownClick else LButton.PerformClick;
end;

procedure TCustomThemedToolBar.OverflowComboBoxItemClick(Sender: TObject);
var
  LItem, LRoot: TMenuItem;
  LComboBox: TThemedComboBox;
  LIndex: Integer;
begin
  if not (Sender is TMenuItem) then Exit;
  LItem := TMenuItem(Sender);
  if (LItem.Parent = nil) or (LItem.Parent.Tag = 0) or (LItem.Tag <= 0) then Exit;
  LRoot := LItem.Parent;
  LComboBox := TThemedComboBox(Pointer(LRoot.Tag));
  LIndex := LItem.Tag - 1;
  if (LComboBox = nil) or (LComboBox.Parent <> Self) or not LComboBox.Enabled or
    (LIndex < 0) or (LIndex >= LComboBox.Items.Count) then Exit;
  LComboBox.ItemIndex := LIndex;
  TThemedComboBoxAccess(LComboBox).NotifyToolbarSelectionChanged;
end;

procedure TCustomThemedToolBar.OverflowSourceMenuItemClick(Sender: TObject);
var
  LSource: TMenuItem;
begin
  if not (Sender is TMenuItem) or (TMenuItem(Sender).Tag = 0) then Exit;
  LSource := TMenuItem(Pointer(TMenuItem(Sender).Tag));
  if LSource <> nil then LSource.Click;
end;

procedure TCustomThemedToolBar.ShowOverflowMenu;
var
  LPoint: TPoint;
begin
  if not Enabled or (FOverflowControls.Count = 0) then Exit;
  if Assigned(FOnOverflowOpening) then FOnOverflowOpening(Self);
  BuildOverflowMenu;
  if FOverflowMenu.Items.Count = 0 then
  begin
    if Assigned(FOnOverflowClosed) then FOnOverflowClosed(Self);
    Exit;
  end;
  FOverflowMenu.BiDiMode := BiDiMode;
  FOverflowPressed := True;
  Invalidate;
  if BiDiMode = bdRightToLeft then LPoint := ClientToScreen(Point(FOverflowButtonBounds.Right, FOverflowButtonBounds.Bottom))
  else LPoint := ClientToScreen(Point(FOverflowButtonBounds.Left, FOverflowButtonBounds.Bottom));
  try
    FOverflowMenu.Popup(LPoint.X, LPoint.Y);
  finally
    FOverflowPressed := False;
    FOverflowHot := False;
    Invalidate;
    if Assigned(FOnOverflowClosed) then FOnOverflowClosed(Self);
  end;
end;

procedure TCustomThemedToolBar.Paint;
var
  LContext: TThemedToolBarRenderContext;
begin
  RenderCanvas.BeginRender(Canvas);
  try
    LContext := System.Default(TThemedToolBarRenderContext);
    LContext.Bounds := ClientRect;
    LContext.GripBounds := FGripBounds;
    LContext.OverflowBounds := FOverflowButtonBounds;
    LContext.Palette := Palette;
    LContext.ShowBorder := FShowBorder;
    LContext.ShowGrip := FShowGrip;
    LContext.ShowOverflowButton := FOverflowControls.Count > 0;
    LContext.OverflowHot := FOverflowHot;
    LContext.OverflowPressed := FOverflowPressed;
    LContext.Enabled := Enabled;
    LContext.PPI := CurrentPPI;
    TThemedToolBarRenderer.Render(RenderCanvas, LContext);
  finally
    RenderCanvas.EndRender;
  end;
end;

end.

{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.IdeStatusBar;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, System.Types, System.UITypes,
  Vcl.Controls, Vcl.Graphics, Vcl.ImgList, Vcl.Menus,
  NimbusForms.Controls.Base, NimbusForms.Controls.Types, NimbusForms.Rendering.Canvas, NimbusForms.Theming.Palette,
  NimbusForms.Menus.PopupMenu;

type
  TCustomThemedIdeStatusBar = class;
  TThemedIdeStatusBarItem = class;
  TThemedIdeStatusBarItemKind = (sikLabel, sikButton, sikToggleButton, sikCheckBox, sikDropDown, sikProgress, sikSeparator, sikSpring, sikCustom);
  TThemedIdeStatusBarDisplayStyle = (sdsText, sdsImage, sdsImageAndText);
  TThemedIdeStatusBarAlignment = (siaLeft, siaCenter, siaRight);
  TThemedIdeStatusBarItemEvent = procedure(Sender: TObject; AItem: TThemedIdeStatusBarItem) of object;

  TThemedIdeStatusBarItems = class(TOwnedCollection)
  private
    function GetItem(AIndex: Integer): TThemedIdeStatusBarItem;
    procedure SetItem(AIndex: Integer; const AValue: TThemedIdeStatusBarItem);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TCustomThemedIdeStatusBar);
    function Add: TThemedIdeStatusBarItem;
    property Items[AIndex: Integer]: TThemedIdeStatusBarItem read GetItem write SetItem; default;
  end;

  TThemedIdeStatusBarItem = class(TCollectionItem)
  private
    FText: string;
    FName: string;
    FHint: string;
    FKind: TThemedIdeStatusBarItemKind;
    FDisplayStyle: TThemedIdeStatusBarDisplayStyle;
    FEnabled: Boolean;
    FVisible: Boolean;
    FChecked: Boolean;
    FCheckable: Boolean;
    FWidth: Integer;
    FMinimumWidth: Integer;
    FMaximumWidth: Integer;
    FImageIndex: System.UITypes.TImageIndex;
    FProgressMinimum: Integer;
    FProgressMaximum: Integer;
    FProgressValue: Integer;
    FDropDownItems: TStringList;
    FSelectedIndex: Integer;
    FTag: NativeInt;
    FBounds: TRect;
    FOnClick: TNotifyEvent;
    FOnCheckedChanged: TNotifyEvent;
    FOnSelectedIndexChanged: TNotifyEvent;
    procedure SetName(const AValue: string);
    procedure SetText(const AValue: string);
    procedure SetHint(const AValue: string);
    procedure SetKind(const AValue: TThemedIdeStatusBarItemKind);
    procedure SetDisplayStyle(const AValue: TThemedIdeStatusBarDisplayStyle);
    procedure SetEnabled(const AValue: Boolean);
    procedure SetVisible(const AValue: Boolean);
    procedure SetChecked(const AValue: Boolean);
    procedure SetCheckable(const AValue: Boolean);
    procedure SetWidth(const AValue: Integer);
    procedure SetMinimumWidth(const AValue: Integer);
    procedure SetMaximumWidth(const AValue: Integer);
    procedure SetImageIndex(const AValue: System.UITypes.TImageIndex);
    procedure SetProgressMinimum(const AValue: Integer);
    procedure SetProgressMaximum(const AValue: Integer);
    procedure SetProgressValue(const AValue: Integer);
    procedure SetSelectedIndex(const AValue: Integer);
    function GetDropDownItems: TStrings;
    procedure SetDropDownItems(const AValue: TStrings);
    procedure ListChanged(Sender: TObject);
    procedure Changed;
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Click;
    property Bounds: TRect read FBounds;
  published
    property Name: string read FName write SetName;
    property Text: string read FText write SetText;
    property Hint: string read FHint write SetHint;
    property Kind: TThemedIdeStatusBarItemKind read FKind write SetKind default sikLabel;
    property DisplayStyle: TThemedIdeStatusBarDisplayStyle read FDisplayStyle write SetDisplayStyle default sdsImageAndText;
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property Visible: Boolean read FVisible write SetVisible default True;
    property Checked: Boolean read FChecked write SetChecked default False;
    property Checkable: Boolean read FCheckable write SetCheckable default False;
    property Width: Integer read FWidth write SetWidth default 0;
    property MinimumWidth: Integer read FMinimumWidth write SetMinimumWidth default 0;
    property MaximumWidth: Integer read FMaximumWidth write SetMaximumWidth default 0;
    property ImageIndex: System.UITypes.TImageIndex read FImageIndex write SetImageIndex default -1;
    property ProgressMinimum: Integer read FProgressMinimum write SetProgressMinimum default 0;
    property ProgressMaximum: Integer read FProgressMaximum write SetProgressMaximum default 100;
    property ProgressValue: Integer read FProgressValue write SetProgressValue default 0;
    property DropDownItems: TStrings read GetDropDownItems write SetDropDownItems;
    property SelectedIndex: Integer read FSelectedIndex write SetSelectedIndex default -1;
    property Tag: NativeInt read FTag write FTag default 0;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnCheckedChanged: TNotifyEvent read FOnCheckedChanged write FOnCheckedChanged;
    property OnSelectedIndexChanged: TNotifyEvent read FOnSelectedIndexChanged write FOnSelectedIndexChanged;
  end;

  TCustomThemedIdeStatusBar = class(TCustomNimbusControl)
  private
    FLeftItems: TThemedIdeStatusBarItems;
    FCenterItems: TThemedIdeStatusBarItems;
    FRightItems: TThemedIdeStatusBarItems;
    FImages: TCustomImageList;
    FShowTopBorder: Boolean;
    FItemHeight: Integer;
    FImageSize: Integer;
    FImageTextSpacing: Integer;
    FArrowSize: Integer;
    FIconBuffer: Vcl.Graphics.TBitmap;
    FHoverItem: TThemedIdeStatusBarItem;
    FPressedItem: TThemedIdeStatusBarItem;
    FFocusedItem: TThemedIdeStatusBarItem;
    FPopup: TThemedPopupMenu;
    FCompactOverrides: Byte;
    FOnItemClicked: TThemedIdeStatusBarItemEvent;
    FOnItemCheckedChanged: TThemedIdeStatusBarItemEvent;
    FOnItemSelectedIndexChanged: TThemedIdeStatusBarItemEvent;
    procedure SetImages(const AValue: TCustomImageList);
    procedure SetShowTopBorder(const AValue: Boolean);
    procedure SetItemHeight(const AValue: Integer);
    procedure SetImageSize(const AValue: Integer);
    procedure SetImageTextSpacing(const AValue: Integer);
    procedure SetArrowSize(const AValue: Integer);
    procedure PopupItemClick(Sender: TObject);
    function GetItemWidth(AItem: TThemedIdeStatusBarItem): Integer;
    function HitItem(const APoint: TPoint): TThemedIdeStatusBarItem;
    function ContainsItem(AItem: TThemedIdeStatusBarItem): Boolean;
    procedure LayoutItems;
    procedure ExecuteItem(AItem: TThemedIdeStatusBarItem);
    procedure ShowItemDropDown(AItem: TThemedIdeStatusBarItem);
    procedure CMDialogKey(var Message: TCMDialogKey); message CM_DIALOGKEY;
    procedure CMHintShow(var Message: TCMHintShow); message CM_HINTSHOW;
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
    procedure StyleModeChanged; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: NimbusForms.Theming.Palette.TThemePalette); override;
    procedure ItemsChanged;
    function FindItem(const AName: string): TThemedIdeStatusBarItem;
  published
    property LeftItems: TThemedIdeStatusBarItems read FLeftItems;
    property CenterItems: TThemedIdeStatusBarItems read FCenterItems;
    property RightItems: TThemedIdeStatusBarItems read FRightItems;
    property Align default alBottom;
    property Anchors;
    property Enabled;
    property Visible;
    property Font;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property TabStop default True;
    property TabOrder;
    property Images: TCustomImageList read FImages write SetImages;
    property ShowTopBorder: Boolean read FShowTopBorder write SetShowTopBorder default True;
    property StyleMode;
    property ItemHeight: Integer read FItemHeight write SetItemHeight default 20;
    property ImageSize: Integer read FImageSize write SetImageSize default 16;
    property ImageTextSpacing: Integer read FImageTextSpacing write SetImageTextSpacing default 3;
    property ArrowSize: Integer read FArrowSize write SetArrowSize default 6;
    property OnItemClicked: TThemedIdeStatusBarItemEvent read FOnItemClicked write FOnItemClicked;
    property OnItemCheckedChanged: TThemedIdeStatusBarItemEvent read FOnItemCheckedChanged write FOnItemCheckedChanged;
    property OnItemSelectedIndexChanged: TThemedIdeStatusBarItemEvent read FOnItemSelectedIndexChanged write FOnItemSelectedIndexChanged;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

  TThemedIdeStatusBar = class(TCustomThemedIdeStatusBar);

implementation

uses
  System.SysUtils, System.Math, NimbusForms.Rendering.Types, NimbusForms.Rendering.IdeStatusBar;

constructor TThemedIdeStatusBarItems.Create(AOwner: TCustomThemedIdeStatusBar);
begin
  inherited Create(AOwner, TThemedIdeStatusBarItem);
end;

function TThemedIdeStatusBarItems.Add: TThemedIdeStatusBarItem;
begin
  Result := TThemedIdeStatusBarItem(inherited Add);
end;

function TThemedIdeStatusBarItems.GetItem(AIndex: Integer): TThemedIdeStatusBarItem;
begin
  Result := TThemedIdeStatusBarItem(inherited Items[AIndex]);
end;

procedure TThemedIdeStatusBarItems.SetItem(AIndex: Integer; const AValue: TThemedIdeStatusBarItem);
begin
  inherited Items[AIndex] := AValue;
end;

procedure TThemedIdeStatusBarItems.Update(Item: TCollectionItem);
begin
  inherited;
  if GetOwner is TCustomThemedIdeStatusBar then TCustomThemedIdeStatusBar(GetOwner).ItemsChanged;
end;

constructor TThemedIdeStatusBarItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FEnabled := True;
  FVisible := True;
  FDisplayStyle := sdsImageAndText;
  FImageIndex := -1;
  FProgressMaximum := 100;
  FSelectedIndex := -1;
  FDropDownItems := TStringList.Create;
  FDropDownItems.OnChange := ListChanged;
end;

destructor TThemedIdeStatusBarItem.Destroy;
begin
  FDropDownItems.Free;
  inherited Destroy;
end;

procedure TThemedIdeStatusBarItem.Changed;
begin
  if Collection <> nil then inherited Changed(False);
end;

procedure TThemedIdeStatusBarItem.ListChanged(Sender: TObject);
begin
  if FSelectedIndex >= FDropDownItems.Count then FSelectedIndex := -1;
  Changed;
end;

function TThemedIdeStatusBarItem.GetDisplayName: string;
begin
  if FText <> '' then Result := FText else Result := inherited GetDisplayName;
end;

procedure TThemedIdeStatusBarItem.Assign(Source: TPersistent);
var L: TThemedIdeStatusBarItem;
begin
  if Source is TThemedIdeStatusBarItem then
  begin
    L := TThemedIdeStatusBarItem(Source);
    FName := L.FName; FText := L.FText; FHint := L.FHint; FKind := L.FKind; FDisplayStyle := L.FDisplayStyle;
    FEnabled := L.FEnabled; FVisible := L.FVisible; FChecked := L.FChecked; FCheckable := L.FCheckable;
    FWidth := L.FWidth; FMinimumWidth := L.FMinimumWidth; FMaximumWidth := L.FMaximumWidth;
    FImageIndex := L.FImageIndex; FProgressMinimum := L.FProgressMinimum;
    FProgressMaximum := L.FProgressMaximum; FProgressValue := L.FProgressValue;
    FDropDownItems.Assign(L.FDropDownItems); FSelectedIndex := L.FSelectedIndex; FTag := L.FTag;
    Changed;
  end else inherited Assign(Source);
end;

procedure TThemedIdeStatusBarItem.SetName(const AValue: string);
begin if FName <> AValue then begin FName := AValue; Changed; end; end;

procedure TThemedIdeStatusBarItem.SetText(const AValue: string);
begin if FText <> AValue then begin FText := AValue; Changed; end; end;
procedure TThemedIdeStatusBarItem.SetHint(const AValue: string);
begin if FHint <> AValue then begin FHint := AValue; Changed; end; end;
procedure TThemedIdeStatusBarItem.SetKind(const AValue: TThemedIdeStatusBarItemKind);
begin if FKind <> AValue then begin FKind := AValue; FCheckable := AValue in [sikToggleButton, sikCheckBox]; Changed; end; end;
procedure TThemedIdeStatusBarItem.SetDisplayStyle(const AValue: TThemedIdeStatusBarDisplayStyle);
begin if FDisplayStyle <> AValue then begin FDisplayStyle := AValue; Changed; end; end;
procedure TThemedIdeStatusBarItem.SetEnabled(const AValue: Boolean);
begin if FEnabled <> AValue then begin FEnabled := AValue; Changed; end; end;
procedure TThemedIdeStatusBarItem.SetVisible(const AValue: Boolean);
begin if FVisible <> AValue then begin FVisible := AValue; Changed; end; end;
procedure TThemedIdeStatusBarItem.SetChecked(const AValue: Boolean);
begin if FChecked <> AValue then begin FChecked := AValue; Changed; if Assigned(FOnCheckedChanged) then FOnCheckedChanged(Self); end; end;
procedure TThemedIdeStatusBarItem.SetCheckable(const AValue: Boolean);
begin if FCheckable <> AValue then begin FCheckable := AValue; Changed; end; end;
procedure TThemedIdeStatusBarItem.SetWidth(const AValue: Integer);
begin if FWidth <> Max(0,AValue) then begin FWidth := Max(0,AValue); Changed; end; end;
procedure TThemedIdeStatusBarItem.SetMinimumWidth(const AValue: Integer);
begin if FMinimumWidth <> Max(0,AValue) then begin FMinimumWidth := Max(0,AValue); Changed; end; end;
procedure TThemedIdeStatusBarItem.SetMaximumWidth(const AValue: Integer);
begin if FMaximumWidth <> Max(0,AValue) then begin FMaximumWidth := Max(0,AValue); Changed; end; end;
procedure TThemedIdeStatusBarItem.SetImageIndex(const AValue: System.UITypes.TImageIndex);
begin if FImageIndex <> AValue then begin FImageIndex := AValue; Changed; end; end;
procedure TThemedIdeStatusBarItem.SetProgressMinimum(const AValue: Integer);
begin if FProgressMinimum <> AValue then begin FProgressMinimum := AValue; if FProgressMaximum <= AValue then FProgressMaximum := AValue + 1; FProgressValue := EnsureRange(FProgressValue,FProgressMinimum,FProgressMaximum); Changed; end; end;
procedure TThemedIdeStatusBarItem.SetProgressMaximum(const AValue: Integer);
begin if FProgressMaximum <> Max(FProgressMinimum+1,AValue) then begin FProgressMaximum := Max(FProgressMinimum+1,AValue); FProgressValue := EnsureRange(FProgressValue,FProgressMinimum,FProgressMaximum); Changed; end; end;
procedure TThemedIdeStatusBarItem.SetProgressValue(const AValue: Integer);
begin if FProgressValue <> EnsureRange(AValue,FProgressMinimum,FProgressMaximum) then begin FProgressValue := EnsureRange(AValue,FProgressMinimum,FProgressMaximum); Changed; end; end;
procedure TThemedIdeStatusBarItem.SetSelectedIndex(const AValue: Integer);
var LValue: Integer;
begin
  LValue := AValue;
  if (LValue < -1) or (LValue >= FDropDownItems.Count) then LValue := -1;
  if FSelectedIndex <> LValue then begin FSelectedIndex := LValue; Changed; if Assigned(FOnSelectedIndexChanged) then FOnSelectedIndexChanged(Self); end;
end;
function TThemedIdeStatusBarItem.GetDropDownItems: TStrings;
begin Result := FDropDownItems; end;

procedure TThemedIdeStatusBarItem.SetDropDownItems(const AValue: TStrings);
begin if AValue <> nil then FDropDownItems.Assign(AValue) else FDropDownItems.Clear; end;
procedure TThemedIdeStatusBarItem.Click;
begin if Assigned(FOnClick) then FOnClick(Self); end;

constructor TCustomThemedIdeStatusBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Align := alBottom;
  Height := 21;
  TabStop := True;
  ShowHint := True;
  FShowTopBorder := True;
  FItemHeight := 20;
  FImageSize := 16;
  FImageTextSpacing := 3;
  FArrowSize := 6;
  FIconBuffer := Vcl.Graphics.TBitmap.Create;
  FLeftItems := TThemedIdeStatusBarItems.Create(Self);
  FCenterItems := TThemedIdeStatusBarItems.Create(Self);
  FRightItems := TThemedIdeStatusBarItems.Create(Self);
  FPopup := TThemedPopupMenu.Create(Self);
end;

procedure TCustomThemedIdeStatusBar.StyleModeChanged;
begin
  inherited StyleModeChanged;
  if StyleMode = stCompact then
  begin
    FCompactOverrides := 0;
    if FItemHeight = 20 then begin FItemHeight := 18; FCompactOverrides := FCompactOverrides or 1; end;
    if FImageTextSpacing = 3 then begin FImageTextSpacing := 2; FCompactOverrides := FCompactOverrides or 2; end;
    if Height = ScaleValue(21) then
    begin
      Height := ScaleValue(19);
      FCompactOverrides := FCompactOverrides or 4;
    end;
  end
  else
  begin
    if ((FCompactOverrides and 1) <> 0) and (FItemHeight = 18) then FItemHeight := 20;
    if ((FCompactOverrides and 2) <> 0) and (FImageTextSpacing = 2) then FImageTextSpacing := 3;
    if ((FCompactOverrides and 4) <> 0) and (Height = ScaleValue(19)) then Height := ScaleValue(21);
    FCompactOverrides := 0;
  end;
  ItemsChanged;
end;

destructor TCustomThemedIdeStatusBar.Destroy;
begin
  if FImages <> nil then FImages.RemoveFreeNotification(Self);
  FImages := nil;
  FPopup.Free;
  FIconBuffer.Free;
  FRightItems.Free;
  FCenterItems.Free;
  FLeftItems.Free;
  inherited Destroy;
end;

procedure TCustomThemedIdeStatusBar.SetImages(const AValue: TCustomImageList);
begin
  if FImages = AValue then Exit;
  if FImages <> nil then FImages.RemoveFreeNotification(Self);
  FImages := AValue;
  if FImages <> nil then FImages.FreeNotification(Self);
  ItemsChanged;
end;

procedure TCustomThemedIdeStatusBar.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FImages) then begin FImages := nil; ItemsChanged; end;
end;

procedure TCustomThemedIdeStatusBar.SetShowTopBorder(const AValue: Boolean);
begin if FShowTopBorder <> AValue then begin FShowTopBorder := AValue; Invalidate; end; end;
procedure TCustomThemedIdeStatusBar.SetItemHeight(const AValue: Integer);
begin if FItemHeight <> Max(18,AValue) then begin FItemHeight := Max(18,AValue); ItemsChanged; end; end;
procedure TCustomThemedIdeStatusBar.SetImageSize(const AValue: Integer);
begin if FImageSize <> Max(1,AValue) then begin FImageSize := Max(1,AValue); ItemsChanged; end; end;
procedure TCustomThemedIdeStatusBar.SetImageTextSpacing(const AValue: Integer);
begin if FImageTextSpacing <> Max(0,AValue) then begin FImageTextSpacing := Max(0,AValue); ItemsChanged; end; end;
procedure TCustomThemedIdeStatusBar.SetArrowSize(const AValue: Integer);
begin if FArrowSize <> Max(2,AValue) then begin FArrowSize := Max(2,AValue); ItemsChanged; end; end;
function TCustomThemedIdeStatusBar.ContainsItem(AItem: TThemedIdeStatusBarItem): Boolean;
var
  C: TThemedIdeStatusBarItems;
  I, G: Integer;
begin
  Result := False;
  if AItem = nil then Exit;
  for G := 0 to 2 do
  begin
    case G of
      0: C := FLeftItems;
      1: C := FCenterItems;
    else
      C := FRightItems;
    end;
    if C = nil then Continue;
    for I := 0 to C.Count - 1 do
      if C[I] = AItem then Exit(True);
  end;
end;

function TCustomThemedIdeStatusBar.FindItem(const AName: string): TThemedIdeStatusBarItem;
var
  C: TThemedIdeStatusBarItems;
  I, G: Integer;
begin
  Result := nil;
  if AName = '' then Exit;
  for G := 0 to 2 do
  begin
    case G of
      0: C := FLeftItems;
      1: C := FCenterItems;
    else
      C := FRightItems;
    end;
    for I := 0 to C.Count - 1 do
      if SameText(C[I].Name, AName) then Exit(C[I]);
  end;
end;

procedure TCustomThemedIdeStatusBar.ItemsChanged;
begin
  if csDestroying in ComponentState then Exit;
  if not ContainsItem(FHoverItem) then FHoverItem := nil;
  if not ContainsItem(FPressedItem) then FPressedItem := nil;
  if not ContainsItem(FFocusedItem) then FFocusedItem := nil;
  LayoutItems;
  Invalidate;
end;

function TCustomThemedIdeStatusBar.GetItemWidth(AItem: TThemedIdeStatusBarItem): Integer;
var L: Integer;
begin
  if AItem.Kind = sikSpring then Exit(0);
  if AItem.Width > 0 then Exit(ScaleValue(AItem.Width));
  if AItem.Kind = sikSeparator then Exit(ScaleValue(7));
  if AItem.Kind = sikProgress then Exit(ScaleValue(120));
  L := ScaleValue(12);
  if (AItem.ImageIndex >= 0) and (FImages <> nil) and (AItem.ImageIndex < FImages.Count) and (AItem.DisplayStyle <> sdsText) then Inc(L, ScaleValue(FImageSize + FImageTextSpacing));
  if AItem.Kind = sikCheckBox then Inc(L, ScaleValue(FImageSize + FImageTextSpacing));
  if (AItem.Text <> '') and (AItem.DisplayStyle <> sdsImage) then Inc(L, Length(AItem.Text) * ScaleValue(7) + ScaleValue(4));
  if AItem.Kind = sikDropDown then Inc(L, ScaleValue(FArrowSize + 8));
  Result := Max(ScaleValue(34), L);
  if AItem.MinimumWidth > 0 then Result := Max(Result, ScaleValue(AItem.MinimumWidth));
  if AItem.MaximumWidth > 0 then Result := Min(Result, ScaleValue(AItem.MaximumWidth));
end;

procedure TCustomThemedIdeStatusBar.LayoutItems;
var
  I, X, Y, R, W, RightWidth, CenterWidth, CenterStart, LeftWidth, SpringCount, SpringWidth, Available, Gap: Integer;
  A: TThemedIdeStatusBarItem;
begin
  if (FLeftItems = nil) or (FCenterItems = nil) or (FRightItems = nil) then Exit;
  Y := Max(0, (ClientHeight - ScaleValue(FItemHeight)) div 2);
  Gap := ScaleValue(4);
  R := Max(0, ClientWidth - ScaleValue(2));
  RightWidth := 0;
  for I := 0 to FRightItems.Count - 1 do
  begin
    A := FRightItems[I];
    A.FBounds := Rect(0, 0, 0, 0);
    if A.Visible and (A.Kind <> sikSpring) then Inc(RightWidth, GetItemWidth(A));
  end;
  X := Max(ScaleValue(2), R - RightWidth);
  for I := 0 to FRightItems.Count - 1 do
  begin
    A := FRightItems[I];
    if not A.Visible or (A.Kind = sikSpring) then Continue;
    W := GetItemWidth(A);
    if (X + W <= R) and (X + W <= ClientWidth) then A.FBounds := Rect(X, Y, X + W, Y + ScaleValue(FItemHeight));
    Inc(X, W);
  end;
  R := Max(ScaleValue(2), R - RightWidth - Gap);
  CenterWidth := 0;
  for I := 0 to FCenterItems.Count - 1 do
  begin
    A := FCenterItems[I];
    A.FBounds := Rect(0, 0, 0, 0);
    if A.Visible and (A.Kind <> sikSpring) then Inc(CenterWidth, GetItemWidth(A));
  end;
  CenterStart := Max(ScaleValue(2), (ClientWidth - CenterWidth) div 2);
  if CenterStart + CenterWidth > R then CenterStart := Max(ScaleValue(2), R - CenterWidth);
  X := CenterStart;
  for I := 0 to FCenterItems.Count - 1 do
  begin
    A := FCenterItems[I];
    if not A.Visible or (A.Kind = sikSpring) then Continue;
    W := GetItemWidth(A);
    if (X + W <= R) and (X >= ScaleValue(2)) then A.FBounds := Rect(X, Y, X + W, Y + ScaleValue(FItemHeight));
    Inc(X, W);
  end;
  LeftWidth := 0;
  SpringCount := 0;
  for I := 0 to FLeftItems.Count - 1 do
  begin
    A := FLeftItems[I];
    A.FBounds := Rect(0, 0, 0, 0);
    if not A.Visible then Continue;
    if A.Kind = sikSpring then Inc(SpringCount) else Inc(LeftWidth, GetItemWidth(A));
  end;
  Available := R;
  if CenterWidth > 0 then Available := Min(Available, CenterStart - Gap);
  SpringWidth := 0;
  if SpringCount > 0 then SpringWidth := Max(0, (Available - ScaleValue(2) - LeftWidth) div SpringCount);
  X := ScaleValue(2);
  for I := 0 to FLeftItems.Count - 1 do
  begin
    A := FLeftItems[I];
    if not A.Visible then Continue;
    if A.Kind = sikSpring then W := SpringWidth else W := GetItemWidth(A);
    if (W > 0) and (X + W <= Available) then A.FBounds := Rect(X, Y, X + W, Y + ScaleValue(FItemHeight));
    Inc(X, W);
  end;
end;

function TCustomThemedIdeStatusBar.HitItem(const APoint: TPoint): TThemedIdeStatusBarItem;
var C: TThemedIdeStatusBarItems; I, IGroup: Integer; A: TThemedIdeStatusBarItem;
begin
  Result := nil;
  for IGroup := 0 to 2 do
  begin
    case IGroup of 0: C := FLeftItems; 1: C := FCenterItems; else C := FRightItems; end;
    for I := 0 to C.Count-1 do
  begin
    A := C[I];
    if A.Visible and A.Enabled and (A.Kind in [sikButton,sikToggleButton,sikCheckBox,sikDropDown,sikCustom]) and PtInRect(A.Bounds,APoint) then Exit(A);
    end;
  end;
end;

procedure TCustomThemedIdeStatusBar.Paint;
var C: TThemedIdeStatusBarItems; I, IGroup: Integer; A: TThemedIdeStatusBarItem;
begin
  RenderCanvas.BeginRender(Canvas);
  try
    TThemedIdeStatusBarRenderer.Background(RenderCanvas,ClientRect,Palette,FShowTopBorder);
    for IGroup := 0 to 2 do
  begin
    case IGroup of 0: C := FLeftItems; 1: C := FCenterItems; else C := FRightItems; end;
    for I := 0 to C.Count-1 do
    begin
      A := C[I];
      if A.Visible and not IsRectEmpty(A.Bounds) then
        TThemedIdeStatusBarRenderer.Item(RenderCanvas,A,Font,Palette,Enabled,A=FHoverItem,A=FPressedItem,A=FFocusedItem,CurrentPPI,FImages,FIconBuffer,FImageSize,FImageTextSpacing,FArrowSize);
    end;
    end;
  finally
    RenderCanvas.EndRender;
  end;
end;

procedure TCustomThemedIdeStatusBar.Resize;
begin inherited; ItemsChanged; end;
procedure TCustomThemedIdeStatusBar.ApplyTheme(const APalette: TThemePalette);
begin
  inherited ApplyTheme(APalette);
  FPopup.ApplyTheme(Palette);
  ItemsChanged;
end;
procedure TCustomThemedIdeStatusBar.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin inherited; ItemsChanged; end;

procedure TCustomThemedIdeStatusBar.MouseMove(Shift: TShiftState; X, Y: Integer);
var A: TThemedIdeStatusBarItem;
begin
  inherited;
  A := HitItem(Point(X,Y));
  if FHoverItem <> A then begin FHoverItem := A; Invalidate; end;
  if FHoverItem <> nil then Cursor := crHandPoint else Cursor := crDefault;
end;
procedure TCustomThemedIdeStatusBar.CMMouseLeave(var Message: TMessage);
begin inherited; FHoverItem := nil; FPressedItem := nil; Cursor := crDefault; Invalidate; end;
procedure TCustomThemedIdeStatusBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X,Y: Integer);
begin
  inherited;
  if Button <> mbLeft then Exit;
  if CanFocus then SetFocus;
  FPressedItem := HitItem(Point(X,Y));
  FFocusedItem := FPressedItem;
  Invalidate;
end;
procedure TCustomThemedIdeStatusBar.MouseUp(Button: TMouseButton; Shift: TShiftState; X,Y: Integer);
var A: TThemedIdeStatusBarItem;
begin
  A := FPressedItem; FPressedItem := nil;
  inherited;
  if (Button = mbLeft) and ContainsItem(A) and (A = HitItem(Point(X,Y))) then ExecuteItem(A);
  Invalidate;
end;

procedure TCustomThemedIdeStatusBar.ExecuteItem(AItem: TThemedIdeStatusBarItem);
begin
  if (AItem = nil) or not Enabled or not AItem.Enabled or not AItem.Visible or (csDestroying in ComponentState) then Exit;
  FFocusedItem := AItem;
  if AItem.Checkable or (AItem.Kind in [sikToggleButton,sikCheckBox]) then
  begin
    AItem.Checked := not AItem.Checked;
    if Assigned(FOnItemCheckedChanged) then FOnItemCheckedChanged(Self,AItem);
  end;
  if AItem.Kind = sikDropDown then ShowItemDropDown(AItem);
  AItem.Click;
  if Assigned(FOnItemClicked) then FOnItemClicked(Self,AItem);
  Invalidate;
end;

procedure TCustomThemedIdeStatusBar.ShowItemDropDown(AItem: TThemedIdeStatusBarItem);
var I: Integer; M: TMenuItem; P: TPoint;
begin
  if (AItem = nil) or (AItem.FDropDownItems.Count = 0) then Exit;
  FPopup.Items.Clear;
  for I := 0 to AItem.FDropDownItems.Count-1 do
  begin
    M := TMenuItem.Create(FPopup);
    M.Caption := AItem.FDropDownItems[I];
    M.Tag := I;
    M.Checked := I = AItem.SelectedIndex;
    M.OnClick := PopupItemClick;
    FPopup.Items.Add(M);
  end;
  FFocusedItem := AItem;
  FPopup.Images := FImages;
  P := ClientToScreen(Point(AItem.Bounds.Left,AItem.Bounds.Top));
  FPopup.Popup(P.X,P.Y);
end;

procedure TCustomThemedIdeStatusBar.PopupItemClick(Sender: TObject);
begin
  if not ContainsItem(FFocusedItem) or not (Sender is TMenuItem) or (csDestroying in ComponentState) then Exit;
  FFocusedItem.SelectedIndex := TMenuItem(Sender).Tag;
  if Assigned(FOnItemSelectedIndexChanged) then FOnItemSelectedIndexChanged(Self,FFocusedItem);
end;

procedure TCustomThemedIdeStatusBar.KeyDown(var Key: Word; Shift: TShiftState);
var C: TThemedIdeStatusBarItems; I, IGroup, N, P: Integer; A: TThemedIdeStatusBarItem; L: TList;
begin
  inherited;
  if Key = VK_ESCAPE then begin Winapi.Windows.EndMenu; Key := 0; Exit; end;
  if Key in [VK_LEFT,VK_RIGHT,VK_HOME,VK_END,VK_RETURN,VK_SPACE,VK_DOWN] then
  begin
    L := TList.Create;
    try
      for IGroup := 0 to 2 do
  begin
    case IGroup of 0: C := FLeftItems; 1: C := FCenterItems; else C := FRightItems; end;
    for I := 0 to C.Count-1 do
      begin
        A := C[I]; if A.Visible and A.Enabled and (A.Kind in [sikButton,sikToggleButton,sikCheckBox,sikDropDown,sikCustom]) and not IsRectEmpty(A.Bounds) then L.Add(A);
      end;
      end;
      N := L.Count;
      if N = 0 then Exit;
      P := L.IndexOf(FFocusedItem);
      case Key of
        VK_LEFT: if P < 0 then P := N-1 else P := (P+N-1) mod N;
        VK_RIGHT: if P < 0 then P := 0 else P := (P+1) mod N;
        VK_HOME: P := 0;
        VK_END: P := N-1;
        VK_RETURN,VK_SPACE,VK_DOWN: begin if P >= 0 then ExecuteItem(TThemedIdeStatusBarItem(L[P])); Key := 0; Exit; end;
      end;
      FFocusedItem := TThemedIdeStatusBarItem(L[P]); Invalidate; Key := 0;
    finally L.Free; end;
  end;
end;

procedure TCustomThemedIdeStatusBar.CMDialogKey(var Message: TCMDialogKey);
var K: Word;
begin
  if Focused and (Message.CharCode in [VK_LEFT,VK_RIGHT,VK_RETURN,VK_SPACE,VK_DOWN,VK_HOME,VK_END]) then
  begin K := Message.CharCode; KeyDown(K,[]); Message.Result := 1; end
  else inherited;
end;

procedure TCustomThemedIdeStatusBar.CMHintShow(var Message: TCMHintShow);
var A: TThemedIdeStatusBarItem;
begin
  inherited;
  if Message.HintInfo = nil then Exit;
  A := HitItem(ScreenToClient(Message.HintInfo.CursorPos));
  if (A <> nil) and (A.Hint <> '') then begin Message.HintInfo.HintStr := A.Hint; Message.Result := 0; end;
end;

end.

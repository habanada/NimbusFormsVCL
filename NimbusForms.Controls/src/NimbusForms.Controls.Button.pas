{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.Button;

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
  Vcl.Menus,
  Vcl.ImgList,
  NimbusForms.Theming.Types,
  NimbusForms.Controls.Types,
  NimbusForms.Controls.Base,
  NimbusForms.Rendering.Button;

type
  TThemedButtonDropDownEvent = procedure(Sender: TObject; const APart: TThemedButtonPart) of object;
  TThemedButtonCancelEvent = procedure(Sender: TObject; var ACancel: Boolean) of object;

  TCustomThemedButton = class(TCustomNimbusControl)
  private
    FButtonKind: TThemedButtonKind;
    FButtonStyle: TThemedButtonStyle;
    FHighlightStyle: TThemedButtonHighlightStyle;
    FDisplayMode: TThemedButtonDisplayMode;
    FIndicatorPlacement: TThemedButtonIndicatorPlacement;
    FButtonShape: TThemedButtonShape;
    FDropDownMode: TThemedButtonDropDownMode;
    FImagePlacement: TThemedButtonImagePlacement;
    FColorMode: TThemedButtonColorMode;
    FAnimationMode: TThemedButtonAnimationMode;
    FFocusStyle: TThemedButtonFocusStyle;
    FTextAlign: TThemedContentAlignment;
    FImageAlign: TThemedContentAlignment;
    FContentPadding: TPadding;
    FDropDownMenu: TPopupMenu;
    FIcon: TIcon;
    FImages: TCustomImageList;
    FImageIndex: System.UITypes.TImageIndex;
    FImageChangeLink: TChangeLink;
    FImageListIcon: TIcon;
    FCheckable: Boolean;
    FChecked: Boolean;
    FAutoCheck: Boolean;
    FLoading: Boolean;
    FShowBorder: Boolean;
    FShowFocusIndicator: Boolean;
    FMultiline: Boolean;
    FAutoEllipsis: Boolean;
    FUseMnemonic: Boolean;
    FAnimationsEnabled: Boolean;
    FConfirmClick: Boolean;
    FPressedOffset: Boolean;
    FIndicatorVisible: Boolean;
    FDefault: Boolean;
    FCancel: Boolean;
    FHot: Boolean;
    FPressed: Boolean;
    FDropDownHot: Boolean;
    FDropDownPressed: Boolean;
    FSpacePressed: Boolean;
    FLoadingText: string;
    FShortcutText: string;
    FBadgeText: string;
    FBorderThickness: Integer;
    FCornerRadius: Integer;
    FImageSize: Integer;
    FImageTextSpacing: Integer;
    FDropDownWidth: Integer;
    FBadgeHeight: Integer;
    FBadgePadding: Integer;
    FSpinnerSize: Integer;
    FIndicatorThickness: Integer;
    FAnimationDuration: Integer;
    FMinButtonWidth: Integer;
    FMaxButtonWidth: Integer;
    FSpinnerAngle: Single;
    FAnimationProgress: Single;
    FAnimationStartTick: UInt64;
    FTextOffset: TPoint;
    FImageOffset: TPoint;
    FCustomBackColor: TThemeColor;
    FCustomForeColor: TThemeColor;
    FCustomBorderColor: TThemeColor;
    FCustomHoverBackColor: TThemeColor;
    FCustomPressedBackColor: TThemeColor;
    FCustomCheckedBackColor: TThemeColor;
    FBadgeBackColor: TThemeColor;
    FBadgeForeColor: TThemeColor;
    FIndicatorColor: TThemeColor;
    FModalResult: TModalResult;
    FAnimationTimer: TTimer;
    FLoadingTimer: TTimer;
    FOnButtonClicked: TNotifyEvent;
    FOnCheckedChanged: TNotifyEvent;
    FOnDropDownClick: TThemedButtonDropDownEvent;
    FOnDropDownOpening: TThemedButtonCancelEvent;
    FOnConfirmClicking: TThemedButtonCancelEvent;
    FOnDropDownOpened: TNotifyEvent;
    FOnDropDownClosed: TNotifyEvent;
    procedure SetButtonKind(const AValue: TThemedButtonKind);
    procedure SetButtonStyle(const AValue: TThemedButtonStyle);
    procedure SetHighlightStyle(const AValue: TThemedButtonHighlightStyle);
    procedure SetDisplayMode(const AValue: TThemedButtonDisplayMode);
    procedure SetIndicatorPlacement(const AValue: TThemedButtonIndicatorPlacement);
    procedure SetButtonShape(const AValue: TThemedButtonShape);
    procedure SetDropDownMode(const AValue: TThemedButtonDropDownMode);
    procedure SetImagePlacement(const AValue: TThemedButtonImagePlacement);
    procedure SetColorMode(const AValue: TThemedButtonColorMode);
    procedure SetAnimationMode(const AValue: TThemedButtonAnimationMode);
    procedure SetFocusStyle(const AValue: TThemedButtonFocusStyle);
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
    procedure SetCheckable(const AValue: Boolean);
    procedure SetChecked(const AValue: Boolean);
    procedure SetAutoCheck(const AValue: Boolean);
    procedure SetLoading(const AValue: Boolean);
    procedure SetLoadingText(const AValue: string);
    procedure SetShortcutText(const AValue: string);
    procedure SetBadgeText(const AValue: string);
    procedure SetShowBorder(const AValue: Boolean);
    procedure SetShowFocusIndicator(const AValue: Boolean);
    procedure SetMultiline(const AValue: Boolean);
    procedure SetAutoEllipsis(const AValue: Boolean);
    procedure SetUseMnemonic(const AValue: Boolean);
    procedure SetAnimationsEnabled(const AValue: Boolean);
    procedure SetConfirmClick(const AValue: Boolean);
    procedure SetPressedOffset(const AValue: Boolean);
    procedure SetIndicatorVisible(const AValue: Boolean);
    procedure SetDefault(const AValue: Boolean);
    procedure SetCancel(const AValue: Boolean);
    procedure SetBorderThickness(const AValue: Integer);
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetImageSize(const AValue: Integer);
    procedure SetImageTextSpacing(const AValue: Integer);
    procedure SetDropDownWidth(const AValue: Integer);
    procedure SetIndicatorThickness(const AValue: Integer);
    procedure SetAnimationDuration(const AValue: Integer);
    procedure SetMinButtonWidth(const AValue: Integer);
    procedure SetMaxButtonWidth(const AValue: Integer);
    procedure SetTextOffset(const AValue: TPoint);
    procedure SetImageOffset(const AValue: TPoint);
    procedure SetCustomBackColor(const AValue: TThemeColor);
    procedure SetCustomForeColor(const AValue: TThemeColor);
    procedure SetCustomBorderColor(const AValue: TThemeColor);
    procedure SetCustomHoverBackColor(const AValue: TThemeColor);
    procedure SetCustomPressedBackColor(const AValue: TThemeColor);
    procedure SetCustomCheckedBackColor(const AValue: TThemeColor);
    procedure SetBadgeBackColor(const AValue: TThemeColor);
    procedure SetBadgeForeColor(const AValue: TThemeColor);
    procedure SetIndicatorColor(const AValue: TThemeColor);
    procedure AnimationTimer(Sender: TObject);
    procedure LoadingTimer(Sender: TObject);
    procedure StartAnimation;
    function ResolvePressScale: Single;
    function CurrentIconHandle: HICON;
    function HitTest(const APoint: TPoint): TThemedButtonPart;
    function IndicatorRect: TRect;
    procedure CalculateLayout(var AContext: TThemedButtonRenderContext);
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
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
    procedure DoCheckedChanged; virtual;
    procedure DoButtonClicked; virtual;
    procedure DoDropDownClick(const APart: TThemedButtonPart); virtual;
    function DoDropDownOpening: Boolean; virtual;
    function DoConfirmClicking: Boolean; virtual;
    property ButtonKind: TThemedButtonKind read FButtonKind write SetButtonKind default tbkNormal;
    property ButtonStyle: TThemedButtonStyle read FButtonStyle write SetButtonStyle default tbstFilled;
    property HighlightStyle: TThemedButtonHighlightStyle read FHighlightStyle write SetHighlightStyle default tbhsSubtle;
    property DisplayMode: TThemedButtonDisplayMode read FDisplayMode write SetDisplayMode default tbdmAuto;
    property IndicatorPlacement: TThemedButtonIndicatorPlacement read FIndicatorPlacement write SetIndicatorPlacement default tbipNone;
    property ButtonShape: TThemedButtonShape read FButtonShape write SetButtonShape default tbsRounded;
    property DropDownMode: TThemedButtonDropDownMode read FDropDownMode write SetDropDownMode default tbddNone;
    property ImagePlacement: TThemedButtonImagePlacement read FImagePlacement write SetImagePlacement default tbimgLeft;
    property ColorMode: TThemedButtonColorMode read FColorMode write SetColorMode default tbcmTheme;
    property AnimationMode: TThemedButtonAnimationMode read FAnimationMode write SetAnimationMode default tbamColorFadeAndPress;
    property FocusStyle: TThemedButtonFocusStyle read FFocusStyle write SetFocusStyle default tbfsInnerBorder;
    property TextAlign: TThemedContentAlignment read FTextAlign write SetTextAlign default tcaMiddleCenter;
    property ImageAlign: TThemedContentAlignment read FImageAlign write SetImageAlign default tcaMiddleCenter;
    property ContentPadding: TPadding read FContentPadding write SetContentPadding;
    property DropDownMenu: TPopupMenu read FDropDownMenu write SetDropDownMenu;
    property Icon: TIcon read FIcon write SetIcon;
    property Images: TCustomImageList read FImages write SetImages;
    property ImageIndex: System.UITypes.TImageIndex read FImageIndex write SetImageIndex default -1;
    property Checkable: Boolean read FCheckable write SetCheckable default False;
    property Checked: Boolean read FChecked write SetChecked default False;
    property AutoCheck: Boolean read FAutoCheck write SetAutoCheck default True;
    property Loading: Boolean read FLoading write SetLoading default False;
    property LoadingText: string read FLoadingText write SetLoadingText;
    property ShortcutText: string read FShortcutText write SetShortcutText;
    property BadgeText: string read FBadgeText write SetBadgeText;
    property ShowBorder: Boolean read FShowBorder write SetShowBorder default True;
    property ShowFocusIndicator: Boolean read FShowFocusIndicator write SetShowFocusIndicator default True;
    property Multiline: Boolean read FMultiline write SetMultiline default False;
    property AutoEllipsis: Boolean read FAutoEllipsis write SetAutoEllipsis default True;
    property UseMnemonic: Boolean read FUseMnemonic write SetUseMnemonic default True;
    property AnimationsEnabled: Boolean read FAnimationsEnabled write SetAnimationsEnabled default True;
    property ConfirmClick: Boolean read FConfirmClick write SetConfirmClick default False;
    property PressedOffset: Boolean read FPressedOffset write SetPressedOffset default True;
    property IndicatorVisible: Boolean read FIndicatorVisible write SetIndicatorVisible default False;
    property Default: Boolean read FDefault write SetDefault default False;
    property Cancel: Boolean read FCancel write SetCancel default False;
    property BorderThickness: Integer read FBorderThickness write SetBorderThickness default 1;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 6;
    property ImageSize: Integer read FImageSize write SetImageSize default 16;
    property ImageTextSpacing: Integer read FImageTextSpacing write SetImageTextSpacing default 6;
    property DropDownWidth: Integer read FDropDownWidth write SetDropDownWidth default 28;
    property IndicatorThickness: Integer read FIndicatorThickness write SetIndicatorThickness default 3;
    property AnimationDuration: Integer read FAnimationDuration write SetAnimationDuration default 120;
    property MinButtonWidth: Integer read FMinButtonWidth write SetMinButtonWidth default 0;
    property MaxButtonWidth: Integer read FMaxButtonWidth write SetMaxButtonWidth default 0;
    property CustomBackColor: TThemeColor read FCustomBackColor write SetCustomBackColor default 0;
    property CustomForeColor: TThemeColor read FCustomForeColor write SetCustomForeColor default 0;
    property CustomBorderColor: TThemeColor read FCustomBorderColor write SetCustomBorderColor default 0;
    property HoverBackColor: TThemeColor read FCustomHoverBackColor write SetCustomHoverBackColor default 0;
    property PressedBackColor: TThemeColor read FCustomPressedBackColor write SetCustomPressedBackColor default 0;
    property CheckedBackColor: TThemeColor read FCustomCheckedBackColor write SetCustomCheckedBackColor default 0;
    property BadgeBackColor: TThemeColor read FBadgeBackColor write SetBadgeBackColor default 0;
    property BadgeForeColor: TThemeColor read FBadgeForeColor write SetBadgeForeColor default 0;
    property IndicatorColor: TThemeColor read FIndicatorColor write SetIndicatorColor default 0;
    property ModalResult: TModalResult read FModalResult write FModalResult default 0;
    property OnButtonClicked: TNotifyEvent read FOnButtonClicked write FOnButtonClicked;
    property OnCheckedChanged: TNotifyEvent read FOnCheckedChanged write FOnCheckedChanged;
    property OnDropDownClick: TThemedButtonDropDownEvent read FOnDropDownClick write FOnDropDownClick;
    property OnDropDownOpening: TThemedButtonCancelEvent read FOnDropDownOpening write FOnDropDownOpening;
    property OnConfirmClicking: TThemedButtonCancelEvent read FOnConfirmClicking write FOnConfirmClicking;
    property OnDropDownOpened: TNotifyEvent read FOnDropDownOpened write FOnDropDownOpened;
    property OnDropDownClosed: TNotifyEvent read FOnDropDownClosed write FOnDropDownClosed;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Toggle;
    procedure BeginLoading(const AText: string = '');
    procedure EndLoading;
    procedure ShowDropDown;
    procedure PerformClick;
    property IsHot: Boolean read FHot;
    property IsPressed: Boolean read FPressed;
    property IsDropDownHot: Boolean read FDropDownHot;
    property IsDropDownPressed: Boolean read FDropDownPressed;
    property TextOffset: TPoint read FTextOffset write SetTextOffset;
    property ImageOffset: TPoint read FImageOffset write SetImageOffset;
  end;

  TThemedButton = class(TCustomThemedButton)
  published
    property StyleMode;
    property Action;
    property Align;
    property Anchors;
    property AutoSize;
    property BiDiMode;
    property ButtonKind;
    property ButtonStyle;
    property HighlightStyle;
    property DisplayMode;
    property IndicatorPlacement;
    property ButtonShape;
    property DropDownMode;
    property ImagePlacement;
    property ColorMode;
    property AnimationMode;
    property FocusStyle;
    property TextAlign;
    property ImageAlign;
    property ContentPadding;
    property DropDownMenu;
    property Icon;
    property Images;
    property ImageIndex;
    property Caption;
    property Checkable;
    property Checked;
    property AutoCheck;
    property Constraints;
    property Loading;
    property LoadingText;
    property ShortcutText;
    property BadgeText;
    property ShowBorder;
    property ShowFocusIndicator;
    property Multiline;
    property AutoEllipsis;
    property UseMnemonic;
    property AnimationsEnabled;
    property ConfirmClick;
    property PressedOffset;
    property IndicatorVisible;
    property Default;
    property Cancel;
    property BorderThickness;
    property CornerRadius;
    property ImageSize;
    property ImageTextSpacing;
    property DropDownWidth;
    property IndicatorThickness;
    property AnimationDuration;
    property MinButtonWidth;
    property MaxButtonWidth;
    property CustomBackColor;
    property CustomBorderColor;
    property CustomForeColor;
    property HoverBackColor;
    property PressedBackColor;
    property CheckedBackColor;
    property BadgeBackColor;
    property BadgeForeColor;
    property IndicatorColor;
    property ModalResult;
    property Enabled;
    property Font;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property OnButtonClicked;
    property OnCheckedChanged;
    property OnDropDownClick;
    property OnDropDownOpening;
    property OnConfirmClicking;
    property OnDropDownOpened;
    property OnDropDownClosed;
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

constructor TCustomThemedButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csCaptureMouse, csClickEvents];
  Width := 110;
  Height := 34;
  Constraints.MinWidth := 24;
  Constraints.MinHeight := 24;
  TabStop := True;
  Font.Name := 'Segoe UI';
  Font.Size := 9;
  FButtonKind := tbkNormal;
  FButtonStyle := tbstFilled;
  FHighlightStyle := tbhsSubtle;
  FDisplayMode := tbdmAuto;
  FIndicatorPlacement := tbipNone;
  FButtonShape := tbsRounded;
  FDropDownMode := tbddNone;
  FImagePlacement := tbimgLeft;
  FColorMode := tbcmTheme;
  FAnimationMode := tbamColorFadeAndPress;
  FFocusStyle := tbfsInnerBorder;
  FTextAlign := tcaMiddleCenter;
  FImageAlign := tcaMiddleCenter;
  FContentPadding := TPadding.Create(Self);
  FContentPadding.SetBounds(10, 5, 10, 5);
  FContentPadding.OnChange := ContentPaddingChanged;
  FIcon := TIcon.Create;
  FIcon.OnChange := IconChanged;
  FImageListIcon := TIcon.Create;
  FImageIndex := -1;
  FImageChangeLink := TChangeLink.Create;
  FImageChangeLink.OnChange := ImageListChanged;
  FAutoCheck := True;
  FShowBorder := True;
  FShowFocusIndicator := True;
  FAutoEllipsis := True;
  FUseMnemonic := True;
  FAnimationsEnabled := True;
  FPressedOffset := True;
  FBorderThickness := 1;
  FCornerRadius := 6;
  FImageSize := 16;
  FImageTextSpacing := 6;
  FDropDownWidth := 28;
  FBadgeHeight := 16;
  FBadgePadding := 8;
  FSpinnerSize := 16;
  FIndicatorThickness := 3;
  FAnimationDuration := 120;
  FAnimationProgress := 1.0;
  FAnimationTimer := TTimer.Create(Self);
  FAnimationTimer.Enabled := False;
  FAnimationTimer.Interval := 15;
  FAnimationTimer.OnTimer := AnimationTimer;
  FLoadingTimer := TTimer.Create(Self);
  FLoadingTimer.Enabled := False;
  FLoadingTimer.Interval := 40;
  FLoadingTimer.OnTimer := LoadingTimer;
end;

destructor TCustomThemedButton.Destroy;
begin
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

procedure TCustomThemedButton.SetButtonKind(const AValue: TThemedButtonKind);
begin
  if FButtonKind = AValue then Exit;
  FButtonKind := AValue;
  Invalidate;
end;

procedure TCustomThemedButton.SetButtonStyle(const AValue: TThemedButtonStyle);
begin
  if FButtonStyle = AValue then Exit;
  FButtonStyle := AValue;
  Invalidate;
end;

procedure TCustomThemedButton.SetHighlightStyle(const AValue: TThemedButtonHighlightStyle);
begin
  if FHighlightStyle = AValue then Exit;
  FHighlightStyle := AValue;
  Invalidate;
end;

procedure TCustomThemedButton.SetDisplayMode(const AValue: TThemedButtonDisplayMode);
begin
  if FDisplayMode = AValue then Exit;
  FDisplayMode := AValue;
  AdjustSize;
  Invalidate;
end;

procedure TCustomThemedButton.SetIndicatorPlacement(const AValue: TThemedButtonIndicatorPlacement);
begin
  if FIndicatorPlacement = AValue then Exit;
  FIndicatorPlacement := AValue;
  Invalidate;
end;

procedure TCustomThemedButton.SetButtonShape(const AValue: TThemedButtonShape);
begin
  if FButtonShape = AValue then Exit;
  FButtonShape := AValue;
  Invalidate;
end;

procedure TCustomThemedButton.SetDropDownMode(const AValue: TThemedButtonDropDownMode);
begin
  if FDropDownMode = AValue then Exit;
  FDropDownMode := AValue;
  AdjustSize;
  Invalidate;
end;

procedure TCustomThemedButton.SetImagePlacement(const AValue: TThemedButtonImagePlacement);
begin
  if FImagePlacement = AValue then Exit;
  FImagePlacement := AValue;
  AdjustSize;
  Invalidate;
end;

procedure TCustomThemedButton.SetColorMode(const AValue: TThemedButtonColorMode);
begin
  if FColorMode = AValue then Exit;
  FColorMode := AValue;
  Invalidate;
end;

procedure TCustomThemedButton.SetAnimationMode(const AValue: TThemedButtonAnimationMode);
begin
  if FAnimationMode = AValue then Exit;
  FAnimationMode := AValue;
  Invalidate;
end;

procedure TCustomThemedButton.SetFocusStyle(const AValue: TThemedButtonFocusStyle);
begin
  if FFocusStyle = AValue then Exit;
  FFocusStyle := AValue;
  Invalidate;
end;

procedure TCustomThemedButton.SetTextAlign(const AValue: TThemedContentAlignment);
begin
  if FTextAlign = AValue then Exit;
  FTextAlign := AValue;
  Invalidate;
end;

procedure TCustomThemedButton.SetImageAlign(const AValue: TThemedContentAlignment);
begin
  if FImageAlign = AValue then Exit;
  FImageAlign := AValue;
  Invalidate;
end;

procedure TCustomThemedButton.SetContentPadding(const AValue: TPadding);
begin
  if AValue <> nil then FContentPadding.Assign(AValue);
end;

procedure TCustomThemedButton.ContentPaddingChanged(Sender: TObject);
begin
  AdjustSize;
  Invalidate;
end;

procedure TCustomThemedButton.SetDropDownMenu(const AValue: TPopupMenu);
begin
  if FDropDownMenu = AValue then Exit;
  if FDropDownMenu <> nil then FDropDownMenu.RemoveFreeNotification(Self);
  FDropDownMenu := AValue;
  if FDropDownMenu <> nil then FDropDownMenu.FreeNotification(Self);
end;

procedure TCustomThemedButton.SetIcon(const AValue: TIcon);
begin
  if AValue = nil then FIcon.Handle := 0 else FIcon.Assign(AValue);
end;

procedure TCustomThemedButton.IconChanged(Sender: TObject);
begin
  AdjustSize;
  Invalidate;
end;

procedure TCustomThemedButton.SetImages(const AValue: TCustomImageList);
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

procedure TCustomThemedButton.SetImageIndex(const AValue: System.UITypes.TImageIndex);
begin
  if FImageIndex = AValue then Exit;
  FImageIndex := AValue;
  RefreshImageListIcon;
end;

procedure TCustomThemedButton.ImageListChanged(Sender: TObject);
begin
  RefreshImageListIcon;
end;

procedure TCustomThemedButton.RefreshImageListIcon;
begin
  FImageListIcon.Handle := 0;
  if (FImages <> nil) and (FImageIndex >= 0) and (FImageIndex < FImages.Count) then FImages.GetIcon(FImageIndex, FImageListIcon);
  AdjustSize;
  Invalidate;
end;

procedure TCustomThemedButton.SetCheckable(const AValue: Boolean);
begin
  if FCheckable = AValue then Exit;
  FCheckable := AValue;
  if not FCheckable then Checked := False;
  Invalidate;
end;

procedure TCustomThemedButton.SetChecked(const AValue: Boolean);
begin
  if FChecked = AValue then Exit;
  FChecked := AValue;
  StartAnimation;
  DoCheckedChanged;
end;

procedure TCustomThemedButton.SetAutoCheck(const AValue: Boolean);
begin
  FAutoCheck := AValue;
end;

procedure TCustomThemedButton.SetLoading(const AValue: Boolean);
begin
  if FLoading = AValue then Exit;
  FLoading := AValue;
  FLoadingTimer.Enabled := FLoading;
  if not FLoading then FSpinnerAngle := 0;
  Invalidate;
end;

procedure TCustomThemedButton.SetLoadingText(const AValue: string);
begin
  if FLoadingText = AValue then Exit;
  FLoadingText := AValue;
  AdjustSize;
  Invalidate;
end;

procedure TCustomThemedButton.SetShortcutText(const AValue: string);
begin
  if FShortcutText = AValue then Exit;
  FShortcutText := AValue;
  AdjustSize;
  Invalidate;
end;

procedure TCustomThemedButton.SetBadgeText(const AValue: string);
begin
  if FBadgeText = AValue then Exit;
  FBadgeText := AValue;
  AdjustSize;
  Invalidate;
end;

procedure TCustomThemedButton.SetShowBorder(const AValue: Boolean);
begin
  if FShowBorder = AValue then Exit;
  FShowBorder := AValue;
  Invalidate;
end;

procedure TCustomThemedButton.SetShowFocusIndicator(const AValue: Boolean);
begin
  if FShowFocusIndicator = AValue then Exit;
  FShowFocusIndicator := AValue;
  Invalidate;
end;

procedure TCustomThemedButton.SetMultiline(const AValue: Boolean);
begin
  if FMultiline = AValue then Exit;
  FMultiline := AValue;
  AdjustSize;
  Invalidate;
end;

procedure TCustomThemedButton.SetAutoEllipsis(const AValue: Boolean);
begin
  if FAutoEllipsis = AValue then Exit;
  FAutoEllipsis := AValue;
  Invalidate;
end;

procedure TCustomThemedButton.SetUseMnemonic(const AValue: Boolean);
begin
  if FUseMnemonic = AValue then Exit;
  FUseMnemonic := AValue;
  Invalidate;
end;

procedure TCustomThemedButton.SetAnimationsEnabled(const AValue: Boolean);
begin
  if FAnimationsEnabled = AValue then Exit;
  FAnimationsEnabled := AValue;
  if not FAnimationsEnabled then
  begin
    FAnimationTimer.Enabled := False;
    FAnimationProgress := 1.0;
  end;
  Invalidate;
end;

procedure TCustomThemedButton.SetConfirmClick(const AValue: Boolean);
begin
  FConfirmClick := AValue;
end;

procedure TCustomThemedButton.SetPressedOffset(const AValue: Boolean);
begin
  if FPressedOffset = AValue then Exit;
  FPressedOffset := AValue;
  Invalidate;
end;

procedure TCustomThemedButton.SetIndicatorVisible(const AValue: Boolean);
begin
  if FIndicatorVisible = AValue then Exit;
  FIndicatorVisible := AValue;
  Invalidate;
end;

procedure TCustomThemedButton.SetDefault(const AValue: Boolean);
begin
  if FDefault = AValue then Exit;
  FDefault := AValue;
  Invalidate;
end;

procedure TCustomThemedButton.SetCancel(const AValue: Boolean);
begin
  FCancel := AValue;
end;

procedure TCustomThemedButton.SetBorderThickness(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(1, AValue);
  if FBorderThickness = LValue then Exit;
  FBorderThickness := LValue;
  Invalidate;
end;

procedure TCustomThemedButton.SetCornerRadius(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(0, AValue);
  if FCornerRadius = LValue then Exit;
  FCornerRadius := LValue;
  Invalidate;
end;

procedure TCustomThemedButton.SetImageSize(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(1, AValue);
  if FImageSize = LValue then Exit;
  FImageSize := LValue;
  AdjustSize;
  Invalidate;
end;

procedure TCustomThemedButton.SetImageTextSpacing(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(0, AValue);
  if FImageTextSpacing = LValue then Exit;
  FImageTextSpacing := LValue;
  AdjustSize;
  Invalidate;
end;

procedure TCustomThemedButton.SetDropDownWidth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(12, AValue);
  if FDropDownWidth = LValue then Exit;
  FDropDownWidth := LValue;
  AdjustSize;
  Invalidate;
end;

procedure TCustomThemedButton.SetIndicatorThickness(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(1, AValue);
  if FIndicatorThickness = LValue then Exit;
  FIndicatorThickness := LValue;
  Invalidate;
end;

procedure TCustomThemedButton.SetAnimationDuration(const AValue: Integer);
begin
  FAnimationDuration := Max(1, AValue);
end;

procedure TCustomThemedButton.SetMinButtonWidth(const AValue: Integer);
begin
  FMinButtonWidth := Max(0, AValue);
  AdjustSize;
end;

procedure TCustomThemedButton.SetMaxButtonWidth(const AValue: Integer);
begin
  FMaxButtonWidth := Max(0, AValue);
  AdjustSize;
end;

procedure TCustomThemedButton.SetTextOffset(const AValue: TPoint);
begin
  if (FTextOffset.X = AValue.X) and (FTextOffset.Y = AValue.Y) then Exit;
  FTextOffset := AValue;
  Invalidate;
end;

procedure TCustomThemedButton.SetImageOffset(const AValue: TPoint);
begin
  if (FImageOffset.X = AValue.X) and (FImageOffset.Y = AValue.Y) then Exit;
  FImageOffset := AValue;
  Invalidate;
end;

procedure TCustomThemedButton.SetCustomBackColor(const AValue: TThemeColor);
begin
  if FCustomBackColor = AValue then Exit;
  FCustomBackColor := AValue;
  Invalidate;
end;

procedure TCustomThemedButton.SetCustomForeColor(const AValue: TThemeColor);
begin
  if FCustomForeColor = AValue then Exit;
  FCustomForeColor := AValue;
  Invalidate;
end;

procedure TCustomThemedButton.SetCustomBorderColor(const AValue: TThemeColor);
begin
  if FCustomBorderColor = AValue then Exit;
  FCustomBorderColor := AValue;
  Invalidate;
end;

procedure TCustomThemedButton.SetCustomHoverBackColor(const AValue: TThemeColor);
begin
  if FCustomHoverBackColor = AValue then Exit;
  FCustomHoverBackColor := AValue;
  Invalidate;
end;

procedure TCustomThemedButton.SetCustomPressedBackColor(const AValue: TThemeColor);
begin
  if FCustomPressedBackColor = AValue then Exit;
  FCustomPressedBackColor := AValue;
  Invalidate;
end;

procedure TCustomThemedButton.SetCustomCheckedBackColor(const AValue: TThemeColor);
begin
  if FCustomCheckedBackColor = AValue then Exit;
  FCustomCheckedBackColor := AValue;
  Invalidate;
end;

procedure TCustomThemedButton.SetBadgeBackColor(const AValue: TThemeColor);
begin
  if FBadgeBackColor = AValue then Exit;
  FBadgeBackColor := AValue;
  Invalidate;
end;

procedure TCustomThemedButton.SetBadgeForeColor(const AValue: TThemeColor);
begin
  if FBadgeForeColor = AValue then Exit;
  FBadgeForeColor := AValue;
  Invalidate;
end;

procedure TCustomThemedButton.SetIndicatorColor(const AValue: TThemeColor);
begin
  if FIndicatorColor = AValue then Exit;
  FIndicatorColor := AValue;
  Invalidate;
end;

procedure TCustomThemedButton.AnimationTimer(Sender: TObject);
var
  LElapsed: UInt64;
begin
  LElapsed := GetTickCount64 - FAnimationStartTick;
  FAnimationProgress := LElapsed / FAnimationDuration;
  if FAnimationProgress >= 1.0 then
  begin
    FAnimationProgress := 1.0;
    FAnimationTimer.Enabled := False;
  end;
  Invalidate;
end;

procedure TCustomThemedButton.LoadingTimer(Sender: TObject);
begin
  FSpinnerAngle := FSpinnerAngle + 24.0;
  if FSpinnerAngle >= 360.0 then FSpinnerAngle := FSpinnerAngle - 360.0;
  Invalidate;
end;

procedure TCustomThemedButton.StartAnimation;
begin
  if not FAnimationsEnabled or (FAnimationMode = tbamNone) then
  begin
    FAnimationTimer.Enabled := False;
    FAnimationProgress := 1.0;
    Invalidate;
    Exit;
  end;
  FAnimationStartTick := GetTickCount64;
  FAnimationProgress := 0.0;
  FAnimationTimer.Enabled := True;
  Invalidate;
end;

function TCustomThemedButton.ResolvePressScale: Single;
begin
  Result := 1.0;
  if not FPressedOffset or not FAnimationsEnabled or not (FAnimationMode in [tbamPress, tbamColorFadeAndPress]) then Exit;
  if not FPressed and not FDropDownPressed then Exit;
  Result := 0.98 + 0.02 * FAnimationProgress;
end;

function TCustomThemedButton.CurrentIconHandle: HICON;
begin
  if not FIcon.Empty then Result := FIcon.Handle else if not FImageListIcon.Empty then Result := FImageListIcon.Handle else Result := 0;
end;

function TCustomThemedButton.HitTest(const APoint: TPoint): TThemedButtonPart;
var
  LWidth: Integer;
  LRect: TRect;
begin
  Result := tbpNone;
  if (APoint.X < 0) or (APoint.Y < 0) or (APoint.X >= Width) or (APoint.Y >= Height) then Exit;
  if FDropDownMode <> tbddNone then
  begin
    LWidth := Min(ScaleValue(Max(12, FDropDownWidth - Ord(StyleMode = stCompact) * 6)), Width);
    LRect := Rect(Width - LWidth, 0, Width, Height);
    if PtInRect(LRect, APoint) then Exit(tbpDropDown);
  end;
  Result := tbpMain;
end;

function TCustomThemedButton.IndicatorRect: TRect;
var
  LThickness: Integer;
begin
  Result := Rect(0, 0, Width, Height);
  if not FIndicatorVisible or (FIndicatorPlacement = tbipNone) then Exit(Rect(0, 0, 0, 0));
  LThickness := ScaleValue(FIndicatorThickness);
  case FIndicatorPlacement of
    tbipLeft: Result.Right := Result.Left + LThickness;
    tbipTop: Result.Bottom := Result.Top + LThickness;
    tbipRight: Result.Left := Result.Right - LThickness;
    tbipBottom: Result.Top := Result.Bottom - LThickness;
  end;
end;

procedure TCustomThemedButton.CalculateLayout(var AContext: TThemedButtonRenderContext);
  function AlignSquare(const ABounds: TRect; const ASize: Integer; const AAlignment: TThemedContentAlignment): TRect;
  var
    X, Y: Integer;
  begin
    X := ABounds.Left;
    Y := ABounds.Top;
    case AAlignment of
      tcaTopCenter, tcaMiddleCenter, tcaBottomCenter: X := ABounds.Left + (ABounds.Width - ASize) div 2;
      tcaTopRight, tcaMiddleRight, tcaBottomRight: X := ABounds.Right - ASize;
    end;
    case AAlignment of
      tcaMiddleLeft, tcaMiddleCenter, tcaMiddleRight: Y := ABounds.Top + (ABounds.Height - ASize) div 2;
      tcaBottomLeft, tcaBottomCenter, tcaBottomRight: Y := ABounds.Bottom - ASize;
    end;
    Result := Rect(X, Y, X + ASize, Y + ASize);
  end;
var
  LMain, LContent: TRect;
  LBadgeSize, LShortcutSize: TSize;
  LBadgeWidth, LShortcutWidth, LSize, LSpacing, LSpinnerWidth: Integer;
  LShowText, LShowImage, LHasImage: Boolean;
begin
  LMain := AContext.Bounds;
  if FDropDownMode <> tbddNone then
  begin
    AContext.DropDownBounds := Rect(Max(0, AContext.Bounds.Right - AContext.DropDownWidth), AContext.Bounds.Top, AContext.Bounds.Right, AContext.Bounds.Bottom);
    LMain.Right := Max(LMain.Left, LMain.Right - AContext.DropDownBounds.Width);
  end;
  AContext.MainBounds := LMain;
  LContent := Rect(LMain.Left + ScaleValue(Max(0, FContentPadding.Left - Ord(StyleMode = stCompact) * 4)),
    LMain.Top + ScaleValue(Max(0, FContentPadding.Top - Ord(StyleMode = stCompact) * 3)),
    LMain.Right - ScaleValue(Max(0, FContentPadding.Right - Ord(StyleMode = stCompact) * 4)),
    LMain.Bottom - ScaleValue(Max(0, FContentPadding.Bottom - Ord(StyleMode = stCompact) * 3)));
  if LContent.Right < LContent.Left then LContent.Right := LContent.Left;
  if LContent.Bottom < LContent.Top then LContent.Bottom := LContent.Top;
  LSpacing := AContext.ImageTextSpacing;
  if FBadgeText <> '' then
  begin
    LBadgeSize := RenderCanvas.MeasureText(FBadgeText, Font, 10000, [ntfSingleLine, ntfNoPrefix]);
    LBadgeWidth := Max(ScaleValue(FBadgeHeight), LBadgeSize.cx + ScaleValue(FBadgePadding));
    AContext.BadgeBounds := Rect(Max(LContent.Left, LContent.Right - LBadgeWidth), LContent.Top + (LContent.Height - ScaleValue(FBadgeHeight)) div 2, LContent.Right, LContent.Top + (LContent.Height - ScaleValue(FBadgeHeight)) div 2 + ScaleValue(FBadgeHeight));
    LContent.Right := Max(LContent.Left, AContext.BadgeBounds.Left - LSpacing);
  end;
  if FShortcutText <> '' then
  begin
    LShortcutSize := RenderCanvas.MeasureText(FShortcutText, Font, 10000, [ntfSingleLine, ntfNoPrefix]);
    LShortcutWidth := LShortcutSize.cx;
    AContext.ShortcutBounds := Rect(Max(LContent.Left, LContent.Right - LShortcutWidth), LContent.Top, LContent.Right, LContent.Bottom);
    LContent.Right := Max(LContent.Left, AContext.ShortcutBounds.Left - LSpacing);
  end;
  AContext.ContentBounds := LContent;
  AContext.TextBounds := LContent;
  LShowText := FDisplayMode <> tbdmImage;
  LShowImage := FDisplayMode <> tbdmText;
  if not LShowText then AContext.TextBounds := Rect(0, 0, 0, 0);
  LHasImage := LShowImage and not FLoading and (CurrentIconHandle <> 0);
  if FLoading then
  begin
    LSpinnerWidth := AContext.SpinnerSize + LSpacing;
    AContext.TextBounds.Left := Min(AContext.TextBounds.Right, AContext.TextBounds.Left + LSpinnerWidth);
  end
  else if LHasImage then
  begin
    LSize := Min(AContext.ImageSize, Min(LContent.Width, LContent.Height));
    if LSize > 0 then
    begin
      case FImagePlacement of
        tbimgLeft:
          begin
            AContext.ImageBounds := Rect(LContent.Left, LContent.Top + (LContent.Height - LSize) div 2, LContent.Left + LSize, LContent.Top + (LContent.Height - LSize) div 2 + LSize);
            AContext.TextBounds.Left := Min(AContext.TextBounds.Right, AContext.ImageBounds.Right + LSpacing);
          end;
        tbimgRight:
          begin
            AContext.ImageBounds := Rect(LContent.Right - LSize, LContent.Top + (LContent.Height - LSize) div 2, LContent.Right, LContent.Top + (LContent.Height - LSize) div 2 + LSize);
            AContext.TextBounds.Right := Max(AContext.TextBounds.Left, AContext.ImageBounds.Left - LSpacing);
          end;
        tbimgTop:
          begin
            AContext.ImageBounds := Rect(LContent.Left + (LContent.Width - LSize) div 2, LContent.Top, LContent.Left + (LContent.Width - LSize) div 2 + LSize, LContent.Top + LSize);
            AContext.TextBounds.Top := Min(AContext.TextBounds.Bottom, AContext.ImageBounds.Bottom + LSpacing);
          end;
        tbimgBottom:
          begin
            AContext.ImageBounds := Rect(LContent.Left + (LContent.Width - LSize) div 2, LContent.Bottom - LSize, LContent.Left + (LContent.Width - LSize) div 2 + LSize, LContent.Bottom);
            AContext.TextBounds.Bottom := Max(AContext.TextBounds.Top, AContext.ImageBounds.Top - LSpacing);
          end;
        tbimgOverlay: AContext.ImageBounds := AlignSquare(LContent, LSize, FImageAlign);
      end;
      OffsetRect(AContext.ImageBounds, ScaleValue(FImageOffset.X), ScaleValue(FImageOffset.Y));
    end;
  end;
  if not NimbusRectIsEmpty(AContext.TextBounds) then OffsetRect(AContext.TextBounds, ScaleValue(FTextOffset.X), ScaleValue(FTextOffset.Y));
end;

function TCustomThemedButton.CanAutoSize(var NewWidth, NewHeight: Integer): Boolean;
var
  LCaption: string;
  LSize, LShortcut, LBadge: TSize;
  LWidth, LHeight: Integer;
  LHasImage: Boolean;
begin
  Result := True;
  if Parent = nil then Exit;
  RenderCanvas.BeginRender(Canvas);
  try
    if FLoading and (FLoadingText <> '') then LCaption := FLoadingText else LCaption := Caption;
    if LCaption <> '' then LSize := RenderCanvas.MeasureText(LCaption, Font, 10000, [ntfSingleLine]) else begin LSize.cx := 0; LSize.cy := 0; end;
    LWidth := ScaleValue(FContentPadding.Left + FContentPadding.Right) + LSize.cx;
    LHeight := ScaleValue(FContentPadding.Top + FContentPadding.Bottom) + Max(LSize.cy, ScaleValue(FImageSize));
    LHasImage := not FLoading and (CurrentIconHandle <> 0) and (FDisplayMode <> tbdmText);
    if LHasImage then
    begin
      if FImagePlacement in [tbimgTop, tbimgBottom] then
      begin
        LWidth := Max(LWidth, ScaleValue(FContentPadding.Left + FContentPadding.Right + FImageSize));
        Inc(LHeight, ScaleValue(FImageSize + FImageTextSpacing));
      end
      else if FImagePlacement <> tbimgOverlay then
        Inc(LWidth, ScaleValue(FImageSize + FImageTextSpacing));
    end;
    if FLoading then Inc(LWidth, ScaleValue(FSpinnerSize + FImageTextSpacing));
    if FShortcutText <> '' then
    begin
      LShortcut := RenderCanvas.MeasureText(FShortcutText, Font, 10000, [ntfSingleLine, ntfNoPrefix]);
      Inc(LWidth, LShortcut.cx + ScaleValue(FImageTextSpacing));
    end;
    if FBadgeText <> '' then
    begin
      LBadge := RenderCanvas.MeasureText(FBadgeText, Font, 10000, [ntfSingleLine, ntfNoPrefix]);
      Inc(LWidth, Max(ScaleValue(FBadgeHeight), LBadge.cx + ScaleValue(FBadgePadding)) + ScaleValue(FImageTextSpacing));
    end;
    if FDropDownMode <> tbddNone then Inc(LWidth, ScaleValue(Max(12, FDropDownWidth - Ord(StyleMode = stCompact) * 6)));
    if StyleMode = stCompact then
    begin
      Dec(LWidth, ScaleValue(8));
      Dec(LHeight, ScaleValue(6));
    end;
    LWidth := Max(ScaleValue(24), LWidth);
    LHeight := Max(ScaleValue(24), LHeight);
    if FMinButtonWidth > 0 then LWidth := Max(LWidth, ScaleValue(FMinButtonWidth));
    if FMaxButtonWidth > 0 then LWidth := Min(LWidth, ScaleValue(FMaxButtonWidth));
    NewWidth := LWidth;
    NewHeight := LHeight;
  finally
    RenderCanvas.EndRender;
  end;
end;

procedure TCustomThemedButton.StyleModeChanged;
begin
  inherited StyleModeChanged;
  UpdateStyleHeight(34, 26);
  if AutoSize then AdjustSize;
end;

procedure TCustomThemedButton.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation <> opRemove then Exit;
  if AComponent = FDropDownMenu then SetDropDownMenu(nil);
  if AComponent = FImages then SetImages(nil);
end;

procedure TCustomThemedButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if not FHot then
  begin
    FHot := True;
    StartAnimation;
  end;
end;

procedure TCustomThemedButton.CMMouseLeave(var Message: TMessage);
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
    StartAnimation;
  end;
end;

procedure TCustomThemedButton.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  if not Enabled then
  begin
    FSpacePressed := False;
    FPressed := False;
    FDropDownPressed := False;
    if MouseCapture then MouseCapture := False;
  end;
  Invalidate;
end;

procedure TCustomThemedButton.CMDialogChar(var Message: TCMDialogChar);
begin
  if Enabled and not FLoading and FUseMnemonic and Vcl.Forms.IsAccel(Message.CharCode, Caption) then
  begin
    if CanFocus then SetFocus;
    PerformClick;
    Message.Result := 1;
    Exit;
  end;
  inherited;
end;

procedure TCustomThemedButton.CMDialogKey(var Message: TCMDialogKey);
var
  LShift: TShiftState;
begin
  LShift := KeyDataToShiftState(Message.KeyData);
  if Enabled and not FLoading and (LShift = []) and (((Message.CharCode = VK_RETURN) and (Focused or FDefault)) or ((Message.CharCode = VK_ESCAPE) and FCancel)) then
  begin
    PerformClick;
    Message.Result := 1;
    Exit;
  end;
  inherited;
end;

procedure TCustomThemedButton.CMTextChanged(var Message: TMessage);
begin
  inherited;
  AdjustSize;
  Invalidate;
end;

procedure TCustomThemedButton.WMCaptureChanged(var Message: TMessage);
begin
  inherited;
  if not MouseCapture and (FPressed or FDropDownPressed) then
  begin
    FPressed := False;
    FDropDownPressed := False;
    StartAnimation;
  end;
end;

procedure TCustomThemedButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LPart: TThemedButtonPart;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button <> mbLeft) or not Enabled or FLoading then Exit;
  if CanFocus then SetFocus;
  LPart := HitTest(Point(X, Y));
  if LPart = tbpDropDown then FDropDownPressed := True else if LPart = tbpMain then FPressed := True;
  MouseCapture := True;
  StartAnimation;
end;

procedure TCustomThemedButton.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LDropHot: Boolean;
begin
  inherited MouseMove(Shift, X, Y);
  LDropHot := HitTest(Point(X, Y)) = tbpDropDown;
  if FDropDownHot <> LDropHot then
  begin
    FDropDownHot := LDropHot;
    Invalidate;
  end;
end;

procedure TCustomThemedButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LMainPressed, LDropPressed: Boolean;
  LPart: TThemedButtonPart;
begin
  inherited MouseUp(Button, Shift, X, Y);
  if Button = mbLeft then
  begin
    LMainPressed := FPressed;
    LDropPressed := FDropDownPressed;
    LPart := HitTest(Point(X, Y));
    FPressed := False;
    FDropDownPressed := False;
    MouseCapture := False;
    StartAnimation;
    if Enabled and not FLoading then
    begin
      if LDropPressed and (LPart = tbpDropDown) then
      begin
        ShowDropDown;
        Exit;
      end;
      if LMainPressed and (LPart = tbpMain) then
      begin
        if FIndicatorVisible and PtInRect(IndicatorRect, Point(X, Y)) then
        begin
          PerformClick;
          Exit;
        end;
        if FDropDownMode = tbddDropDown then ShowDropDown else PerformClick;
        Exit;
      end;
    end;
  end;
end;

procedure TCustomThemedButton.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if not Enabled or FLoading then Exit;
  if (Key = VK_SPACE) and not FSpacePressed then
  begin
    FSpacePressed := True;
    FPressed := True;
    StartAnimation;
    Key := 0;
  end
  else if (FDropDownMode <> tbddNone) and ((Key = VK_F4) or ((Key = VK_DOWN) and (ssAlt in Shift))) then
  begin
    ShowDropDown;
    Key := 0;
  end;
end;

procedure TCustomThemedButton.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited KeyUp(Key, Shift);
  if (Key = VK_SPACE) and FSpacePressed then
  begin
    FSpacePressed := False;
    FPressed := False;
    StartAnimation;
    PerformClick;
    Key := 0;
  end;
end;

procedure TCustomThemedButton.DoEnter;
begin
  inherited DoEnter;
  Invalidate;
end;

procedure TCustomThemedButton.DoExit;
begin
  FSpacePressed := False;
  FPressed := False;
  FDropDownPressed := False;
  inherited DoExit;
  Invalidate;
end;

procedure TCustomThemedButton.DoCheckedChanged;
begin
  if Assigned(FOnCheckedChanged) then FOnCheckedChanged(Self);
end;

procedure TCustomThemedButton.DoButtonClicked;
begin
  if Assigned(FOnButtonClicked) then FOnButtonClicked(Self);
end;

procedure TCustomThemedButton.DoDropDownClick(const APart: TThemedButtonPart);
begin
  if Assigned(FOnDropDownClick) then FOnDropDownClick(Self, APart);
end;

function TCustomThemedButton.DoDropDownOpening: Boolean;
var
  LCancel: Boolean;
begin
  LCancel := False;
  if Assigned(FOnDropDownOpening) then FOnDropDownOpening(Self, LCancel);
  Result := not LCancel;
end;

function TCustomThemedButton.DoConfirmClicking: Boolean;
var
  LCancel: Boolean;
begin
  LCancel := False;
  if Assigned(FOnConfirmClicking) then FOnConfirmClicking(Self, LCancel);
  Result := not LCancel;
end;

procedure TCustomThemedButton.Click;
var
  LForm: TCustomForm;
begin
  if not Enabled or FLoading then Exit;
  if FConfirmClick and not DoConfirmClicking then Exit;
  if FCheckable and FAutoCheck then Checked := not Checked;
  if FModalResult <> mrNone then
  begin
    LForm := GetParentForm(Self);
    if LForm <> nil then LForm.ModalResult := FModalResult;
  end;
  DoButtonClicked;
  inherited Click;
end;

procedure TCustomThemedButton.Toggle;
begin
  if FCheckable then Checked := not Checked;
end;

procedure TCustomThemedButton.BeginLoading(const AText: string);
begin
  if AText <> '' then LoadingText := AText;
  Loading := True;
end;

procedure TCustomThemedButton.EndLoading;
begin
  Loading := False;
end;

procedure TCustomThemedButton.PerformClick;
begin
  if Enabled and not FLoading then Click;
end;

procedure TCustomThemedButton.ShowDropDown;
var
  LPoint: TPoint;
begin
  if not Enabled or FLoading or (FDropDownMode = tbddNone) then Exit;
  if not DoDropDownOpening then Exit;
  DoDropDownClick(tbpDropDown);
  if FDropDownMenu = nil then Exit;
  FDropDownPressed := True;
  Invalidate;
  LPoint := ClientToScreen(Point(0, Height));
  if Assigned(FOnDropDownOpened) then FOnDropDownOpened(Self);
  try
    FDropDownMenu.Popup(LPoint.X, LPoint.Y);
  finally
    FDropDownPressed := False;
    Invalidate;
    if Assigned(FOnDropDownClosed) then FOnDropDownClosed(Self);
  end;
end;

procedure TCustomThemedButton.Paint;
var
  LContext: TThemedButtonRenderContext;
begin
  RenderCanvas.BeginRender(Canvas);
  try
    LContext := System.Default(TThemedButtonRenderContext);
    LContext.Bounds := ClientRect;
    LContext.Caption := Caption;
    LContext.LoadingText := FLoadingText;
    LContext.ShortcutText := FShortcutText;
    LContext.BadgeText := FBadgeText;
    LContext.Font := Font;
    LContext.Palette := Palette;
    LContext.IconHandle := CurrentIconHandle;
    LContext.Kind := FButtonKind;
    LContext.Style := FButtonStyle;
    LContext.HighlightStyle := FHighlightStyle;
    LContext.DisplayMode := FDisplayMode;
    LContext.IndicatorPlacement := FIndicatorPlacement;
    LContext.Shape := FButtonShape;
    LContext.DropDownMode := FDropDownMode;
    LContext.ImagePlacement := FImagePlacement;
    LContext.ColorMode := FColorMode;
    LContext.AnimationMode := FAnimationMode;
    LContext.FocusStyle := FFocusStyle;
    LContext.TextAlign := FTextAlign;
    LContext.BorderThickness := ScaleValue(FBorderThickness);
    LContext.CornerRadius := ScaleValue(FCornerRadius);
    LContext.SpinnerSize := ScaleValue(FSpinnerSize);
    LContext.ImageTextSpacing := ScaleValue(FImageTextSpacing);
    LContext.IndicatorThickness := ScaleValue(FIndicatorThickness);
    LContext.SpinnerAngle := FSpinnerAngle;
    LContext.AnimationProgress := FAnimationProgress;
    LContext.PressScale := ResolvePressScale;
    LContext.Enabled := Enabled;
    LContext.Hot := FHot;
    LContext.Pressed := FPressed;
    LContext.DropDownHot := FDropDownHot;
    LContext.DropDownPressed := FDropDownPressed;
    LContext.Checked := FChecked;
    LContext.Loading := FLoading;
    LContext.ShowBorder := FShowBorder or FDefault;
    LContext.ShowFocusIndicator := FShowFocusIndicator;
    LContext.Focused := Focused;
    LContext.Multiline := FMultiline;
    LContext.AutoEllipsis := FAutoEllipsis;
    LContext.UseMnemonic := FUseMnemonic;
    LContext.IndicatorVisible := FIndicatorVisible;
    LContext.RightToLeft := UseRightToLeftReading;
    LContext.SurfaceBackColor := NimbusPanelBackColor(Palette);
    LContext.CustomBackColor := FCustomBackColor;
    LContext.CustomForeColor := FCustomForeColor;
    LContext.CustomBorderColor := FCustomBorderColor;
    LContext.CustomHoverBackColor := FCustomHoverBackColor;
    LContext.CustomPressedBackColor := FCustomPressedBackColor;
    LContext.CustomCheckedBackColor := FCustomCheckedBackColor;
    LContext.BadgeBackColor := FBadgeBackColor;
    LContext.BadgeForeColor := FBadgeForeColor;
    LContext.IndicatorColor := FIndicatorColor;
    LContext.ImageSize := ScaleValue(FImageSize);
    LContext.DropDownWidth := ScaleValue(Max(12, FDropDownWidth - Ord(StyleMode = stCompact) * 6));
    CalculateLayout(LContext);
    TThemedButtonRenderer.Render(RenderCanvas, LContext);
  finally
    RenderCanvas.EndRender;
  end;
end;

end.

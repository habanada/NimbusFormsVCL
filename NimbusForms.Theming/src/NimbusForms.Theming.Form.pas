{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Theming.Form;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.UITypes,
  System.SysUtils,
  System.Types,
  System.Math,
  System.Generics.Collections,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Winapi.GDIPOBJ,
  Winapi.GDIPAPI,
  NimbusForms.Theming.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.Theming.Manager,
  NimbusForms.Theming.Win32,
  NimbusForms.Theming.Form.Strings,
  NimbusForms.Theming.Form.Types,
  NimbusForms.Theming.Form.Native,
  NimbusForms.Theming.Form.Accessibility;

type
  TThemedModernForm = class;

  TThemedModernFormHostControlEvent = procedure(const ASender: TObject; const AControl: TControl;
    const AInserting: Boolean) of object;

  TThemedModernFormHostPanel = class(TPanel, IThemeAware)
  strict private
    FOnControlListChange: TThemedModernFormHostControlEvent;
    procedure CMControlListChange(var AMessage: TMessage); message CM_CONTROLLISTCHANGE;
  protected
    procedure ApplyTheme(const APalette: TThemePalette);
  public
    constructor Create(AOwner: TComponent); override;
    property OnControlListChange: TThemedModernFormHostControlEvent read FOnControlListChange
      write FOnControlListChange;
  end;

  TThemedModernFormChildHook = class(TComponent)
  strict private
    FForm: TThemedModernForm;
    FControl: TControl;
    FOldProc: TWndMethod;
    FActive: Boolean;
    procedure HookProc(var AMessage: TMessage);
  protected
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
  public
    constructor Create(const AForm: TThemedModernForm; const AControl: TControl); reintroduce;
    function Release: Boolean;
    property Control: TControl read FControl;
  end;

  TThemedModernForm = class(TForm, IThemeAware)
  private
  const
    LogicalDpi = 96;
  private
    FPalette: TThemedModernFormPalette;
    FThemePalette: TThemePalette;
    FMetrics: TThemedModernFormChromeMetrics;
    FHoverButton: TThemedModernFormWindowButton;
    FPressedButton: TThemedModernFormWindowButton;
    FCornerMode: TThemedModernFormCornerMode;
    FChromeState: TThemedModernFormChromeState;
    FTitleBarMode: TThemedModernFormTitleBarMode;
    FHitTestModes: TDictionary<TControl, TThemedModernFormTitleBarHitTestMode>;
    FHooks: TDictionary<TControl, TThemedModernFormChildHook>;
    FHookStore: TObjectList<TThemedModernFormChildHook>;
    FTitleBarOverlay: TThemedModernFormHostPanel;
    FTitleBarLeftHost: TThemedModernFormHostPanel;
    FTitleBarCenterHost: TThemedModernFormHostPanel;
    FTitleBarRightHost: TThemedModernFormHostPanel;
    FRemovingControl: TControl;
    FActive: Boolean;
    FAllowCustomChrome: Boolean;
    FUseNativeSnapLayout: Boolean;
    FChromeSyncPending: Boolean;
    FChromeSyncInProgress: Boolean;
    FHideNativeBorder: Boolean;
    FCustomChromeStatusColor: TThemeColor;
    FAutoApplyCurrentTheme: Boolean;
    FApplyThemeToChildControls: Boolean;
    FClipWindowToChromeCorners: Boolean;
    FShowChromeIcon: Boolean;
    FShowChromeTitle: Boolean;
    FShowMinimizeButton: Boolean;
    FShowMaximizeButton: Boolean;
    FShowCloseButton: Boolean;
    FAllowResize: Boolean;
    FAllowDragMove: Boolean;
    FDrawAccentLine: Boolean;
    FDrawOuterBorder: Boolean;
    FDrawRoundedChromeBorder: Boolean;
    FChromeStatusBorderThickness: Integer;
    FCurrentDpi: Integer;
    FUpdatingChromeRegion: Boolean;
    FUpdatingTitleBarHostsLayout: Boolean;
    FLastWindowState: TWindowState;
    FLastRegionWidth: Integer;
    FLastRegionHeight: Integer;
    FLastRegionRadius: Integer;
    FLastRegionCleared: Boolean;
    FAccessibilityHost: IThemedModernFormAccessibilityHost;
    FAccessible: IThemedAccessible;
    FOnChromeDpiChanged: TNotifyEvent;
    procedure SetChromePalette(const AValue: TThemedModernFormPalette);
    procedure SetAutoApplyCurrentTheme(const AValue: Boolean);
    procedure SetApplyThemeToChildControls(const AValue: Boolean);
    procedure SetChromeState(const AValue: TThemedModernFormChromeState);
    procedure SetTitleBarMode(const AValue: TThemedModernFormTitleBarMode);
    procedure SetCustomChromeStatusColor(const AValue: TThemeColor);
    procedure SetAllowCustomChrome(const AValue: Boolean);
    procedure SetUseNativeSnapLayout(const AValue: Boolean);
    procedure SetCornerMode(const AValue: TThemedModernFormCornerMode);
    procedure SetHideNativeBorder(const AValue: Boolean);
    procedure SetShowChromeIcon(const AValue: Boolean);
    procedure SetShowChromeTitle(const AValue: Boolean);
    procedure SetShowMinimizeButton(const AValue: Boolean);
    procedure SetShowMaximizeButton(const AValue: Boolean);
    procedure SetShowCloseButton(const AValue: Boolean);
    procedure SetAllowResize(const AValue: Boolean);
    procedure SetAllowDragMove(const AValue: Boolean);
    procedure SetDrawAccentLine(const AValue: Boolean);
    procedure SetDrawOuterBorder(const AValue: Boolean);
    procedure SetDrawRoundedChromeBorder(const AValue: Boolean);
    procedure SetClipWindowToChromeCorners(const AValue: Boolean);
    procedure SetChromeStatusBorderThickness(const AValue: Integer);
    function GetTitleBarBounds: TRect;
    function GetClientContentBounds: TRect;
    function GetDpiScaleFactor: Single;
    function GetMinimizeBox: Boolean;
    function GetMaximizeBox: Boolean;
    function GetIconHandle: HICON;
    function HasChromeIcon: Boolean;
    procedure InvalidateRectSafe(const ARect: TRect);
    procedure InvalidateTitleBar;
    procedure InvalidateAll;
    procedure CMControlListChange(var AMessage: TMessage); message CM_CONTROLLISTCHANGE;
    procedure CMMouseLeave(var AMessage: TMessage); message CM_MOUSELEAVE;
    procedure CMTextChanged(var AMessage: TMessage); message CM_TEXTCHANGED;
    procedure CMFontChanged(var AMessage: TMessage); message CM_FONTCHANGED;
    procedure CMVisibleChanged(var AMessage: TMessage); message CM_VISIBLECHANGED;
    procedure SyncChromeNow;
    procedure RequestChromeSync;
    procedure UpdateChromeHostColors;
    procedure ApplyThemeToToolBar(const AToolBar: TToolBar; const APalette: TThemePalette);
    function GetDpiFromMessage(const AMessage: TMessage): Integer;
    function TryProcessDwmHitTest(var AMessage: TMessage): Boolean;
    procedure ForwardNonClientMessageToDwm(const AMessage: TMessage);
    procedure WmNcHitTest(var AMessage: TMessage);
    procedure WmGetMinMaxInfo(var AMessage: TMessage);
    procedure WmSysCommand(var AMessage: TMessage; out AHandled: Boolean);
    procedure WmNcButtons(var AMessage: TMessage; out AHandled: Boolean);
    function GetSystemMenuLaunchPoint: TPoint;
    function GetTitleBarPaintBounds: TRect;
    function GetDwmMaskedAccentInnerBounds: TGPRectF;
    function GetDwmMaskedAccentInnerRadius: Single;
    function GetDwmMaskedAccentVisualThickness: Single;
    function GetDwmMaskedAccentTopInset: Single;
    function GetChromeOutlineBounds: TRect;
    function GetChromeBorderThickness: Integer;
    function IsNativeDwmRoundingActive: Boolean;
    function IsDwmMaskedAccentBorderActive: Boolean;
    function CreateRoundRectanglePath(const ABounds: TRect; ARadius: Integer): TGPGraphicsPath; overload;
    function CreateRoundRectanglePath(const ABounds: TGPRectF; ARadius: Single): TGPGraphicsPath; overload;
    procedure FillRectColor(const AGraphics: TGPGraphics; const AColor: TThemeColor; const ARect: TRect);
    procedure CreateTitleBarHosts;
    function CreateTitleBarPanel(const AName: string): TThemedModernFormHostPanel;
    procedure ConfigureTitleBarHost(const AHost: TThemedModernFormHostPanel);
    procedure TitleBarOverlayControlListChange(const ASender: TObject; const AControl: TControl;
      const AInserting: Boolean);
    procedure TitleBarHostControlListChange(const ASender: TObject; const AControl: TControl;
      const AInserting: Boolean);
    procedure TitleBarOverlayMouseDown(ASender: TObject; AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer);
    procedure TitleBarHostMouseDown(ASender: TObject; AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer);
    procedure TitleBarOverlayDblClick(ASender: TObject);
    procedure TitleBarHostDblClick(ASender: TObject);
    function IsLiveChild(const AControl: TControl): Boolean;
    function HasTitleBarOverlayContent: Boolean;
    function HasTitleBarHostContent(const AHost: TThemedModernFormHostPanel): Boolean;
    procedure AttachTitleBarChild(const AControl: TControl);
    procedure DetachTitleBarChild(const AControl: TControl);
    procedure AttachHook(const AControl: TControl);
    procedure DetachHook(const AControl: TControl);
    procedure ForgetHook(const AControl: TControl);
    procedure ChildMessage(const AControl: TControl; var AMessage: TMessage);
    procedure UpdateTitleBarHostPanelsLayout;
    function GetTitleBarHostPreferredWidth(const AHost: TThemedModernFormHostPanel): Integer;
    procedure HandleTitleBarBackgroundMouseDown;
    function IsPointOverOverlayChild(const AOverlayPoint: TPoint): Boolean;
    function IsPointOverHostedControl(const AHost: TWinControl; const AHostPoint: TPoint): Boolean;
    function IsPointOverTitleBarClientControl(const AControl: TControl; const AControlPoint: TPoint): Boolean;
    function GetDeepestTitleBarControlAtPoint(const AParent: TControl; const APoint: TPoint): TControl;
    function ResolveTitleBarHitTestMode(const AControl: TControl): TThemedModernFormTitleBarHitTestMode;
    function TryGetExplicitTitleBarHitTestMode(const AControl: TControl;
      out AMode: TThemedModernFormTitleBarHitTestMode): Boolean;
    procedure UpdateNativeButtonHover(const AHit: Integer);
    procedure ClearButtonState;
    procedure OnWindowButtonConfigurationChanged;
    procedure EnsureDpiMetricsCurrent;
    function GetWindowDpiSafe: Integer;
    procedure UpdateDpiMetrics(ADpi: Integer; const AForceLayout: Boolean);
    procedure NotifyChromeAccessibilityChanged;
    procedure NotifyChromeAccessibilityNameChanged;
    procedure NormalizeChromeMetrics;
    procedure UpdatePadding;
    function GetTitleBarHeight: Integer;
    function GetTitleBarButtonWidth: Integer;
    function GetTitleBarIconSize: Integer;
    function GetTitleBarCaptionLeftPadding: Integer;
    function GetTitleBarCaptionRightPadding: Integer;
    function GetTitleBarOverlayTopPadding: Integer;
    function GetTitleBarOverlayVerticalPadding: Integer;
    function GetTitleBarOverlayHorizontalGap: Integer;
    function GetAccessibleContentControlCount: Integer;
    function GetAccessibleContentControlAt(const AIndex: Integer): TWinControl;
    function IsWindowButtonVisible(const AButton: TThemedModernFormWindowButton): Boolean;
    function IsWindowButtonAvailable(const AButton: TThemedModernFormWindowButton): Boolean;
    function IsSystemMenuAccessibleVisible: Boolean;
    function Scale(const AValue: Integer): Integer;
    function GetScaleFactorSafe: Single;
    function ClientOriginPoint: TPoint;
    procedure EnsureAccessible;
  protected
    procedure CreateParams(var AParams: TCreateParams); override;
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure Loaded; override;
    procedure DoShow; override;
    procedure Resize; override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure Paint; override;
    procedure MouseMove(AShift: TShiftState; AX, AY: Integer); override;
    procedure MouseDown(AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer); override;
    procedure MouseUp(AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer); override;
    procedure DblClick; override;
    procedure WndProc(var AMessage: TMessage); override;
    procedure ApplyChromePalette; virtual;
    procedure OnChromePaletteChanged; virtual;
    function GetChromeStatusColor: TThemeColor; virtual;
    procedure ApplyDwmColors; virtual;
    procedure ApplyDwmShadow; virtual;
    procedure ApplyDwmCornerMode; virtual;
    procedure ApplyThemeToChildren(const APalette: TThemePalette); virtual;
    procedure ApplyThemeToControl(const AControl: TControl; const APalette: TThemePalette); virtual;
    procedure UpdateChromeRegion; virtual;
    procedure ClearChromeRegion; virtual;
    procedure DrawChrome(const AGraphics: TGPGraphics); virtual;
    procedure DrawChromeBackground(const AGraphics: TGPGraphics); virtual;
    procedure DrawTitleBar(const AGraphics: TGPGraphics); virtual;
    procedure DrawWindowButtons(const AGraphics: TGPGraphics); virtual;
    procedure DrawWindowButton(const AGraphics: TGPGraphics; const AButton: TThemedModernFormWindowButton;
      const ABounds: TRect); virtual;
    procedure DrawMinimizeGlyph(const AGraphics: TGPGraphics; const APen: TGPPen; const ABounds: TRect); virtual;
    procedure DrawMaximizeRestoreGlyph(const AGraphics: TGPGraphics; const APen: TGPPen; const ABounds: TRect); virtual;
    procedure DrawCloseGlyph(const AGraphics: TGPGraphics; const APen: TGPPen; const ABounds: TRect); virtual;
    procedure DrawAccent(const AGraphics: TGPGraphics); virtual;
    procedure DrawBorder(const AGraphics: TGPGraphics); virtual;
    function GetButtonRectangle(const AButton: TThemedModernFormWindowButton): TRect; virtual;
    function GetAllButtonsRectangle: TRect; virtual;
    function GetIconRectangle: TRect; virtual;
    function GetChromeTopInset: Integer; virtual;
    function GetRightChromeInset: Integer; virtual;
    function GetLeftChromeInset: Integer; virtual;
    function GetChromeCornerRadius: Integer; virtual;
    function HitTestButton(const APoint: TPoint): TThemedModernFormWindowButton; virtual;
    function IsPointInDraggableTitleBar(const APoint: TPoint): Boolean; virtual;
    procedure ExecuteWindowButton(const AButton: TThemedModernFormWindowButton); virtual;
    procedure ToggleMaximizeRestore; virtual;
    function IsCustomMaximized: Boolean; virtual;
    procedure MaximizeToWorkingArea; virtual;
    procedure RestoreFromCustomMaximize; virtual;
    procedure BeginWindowMove; virtual;
    function GetResizeHitTest(const APoint: TPoint): Integer; virtual;
    function GetResizable: Boolean; virtual;
    procedure UpdateTitleBarHostsLayout; virtual;
    function IsPointOverTitleBarHostControl(const APoint: TPoint): Boolean; virtual;
    procedure ShowSystemMenu(const AScreenLocation: TPoint); virtual;
    procedure UpdateSystemMenuState; virtual;
    procedure DoChromeDpiChanged; virtual;
    property Resizable: Boolean read GetResizable;
    property MinimizeBox: Boolean read GetMinimizeBox;
    property MaximizeBox: Boolean read GetMaximizeBox;
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette);
    procedure ApplyThemePalette(const APalette: TThemePalette);
    procedure RefreshChromeMetrics;
    procedure ResetChromeMetrics;
    procedure RefreshTitleBarHosts;
    procedure SetTitleBarHitTestMode(const AControl: TControl; const AMode: TThemedModernFormTitleBarHitTestMode);
    function GetTitleBarHitTestMode(const AControl: TControl): TThemedModernFormTitleBarHitTestMode;
    property ChromeMetrics: TThemedModernFormChromeMetrics read FMetrics;
    property TitleBarBounds: TRect read GetTitleBarBounds;
    property ClientContentBounds: TRect read GetClientContentBounds;
    property TitleBarOverlay: TThemedModernFormHostPanel read FTitleBarOverlay;
    property TitleBarLeftHost: TThemedModernFormHostPanel read FTitleBarLeftHost;
    property TitleBarCenterHost: TThemedModernFormHostPanel read FTitleBarCenterHost;
    property TitleBarRightHost: TThemedModernFormHostPanel read FTitleBarRightHost;
    property ChromePalette: TThemedModernFormPalette read FPalette write SetChromePalette;
    property ThemePalette: TThemePalette read FThemePalette;
    property CurrentDpi: Integer read FCurrentDpi;
    property DpiScaleFactor: Single read GetDpiScaleFactor;
    property CustomChromeStatusColor: TThemeColor read FCustomChromeStatusColor write SetCustomChromeStatusColor;
    property OnChromeDpiChanged: TNotifyEvent read FOnChromeDpiChanged write FOnChromeDpiChanged;
  published
    property AutoApplyCurrentTheme: Boolean read FAutoApplyCurrentTheme write SetAutoApplyCurrentTheme default True;
    property ApplyThemeToChildControls: Boolean read FApplyThemeToChildControls
      write SetApplyThemeToChildControls default True;
    property ChromeState: TThemedModernFormChromeState read FChromeState write SetChromeState default TThemedModernFormChromeState.Normal;
    property TitleBarMode: TThemedModernFormTitleBarMode read FTitleBarMode write SetTitleBarMode default TThemedModernFormTitleBarMode.Normal;
    property AllowCustomChrome: Boolean read FAllowCustomChrome write SetAllowCustomChrome default True;
    property UseNativeSnapLayout: Boolean read FUseNativeSnapLayout write SetUseNativeSnapLayout default True;
    property CornerMode: TThemedModernFormCornerMode read FCornerMode write SetCornerMode default TThemedModernFormCornerMode.Round;
    property HideNativeBorder: Boolean read FHideNativeBorder write SetHideNativeBorder default True;
    property ShowChromeIcon: Boolean read FShowChromeIcon write SetShowChromeIcon default True;
    property ShowChromeTitle: Boolean read FShowChromeTitle write SetShowChromeTitle default True;
    property ShowMinimizeButton: Boolean read FShowMinimizeButton write SetShowMinimizeButton default True;
    property ShowMaximizeButton: Boolean read FShowMaximizeButton write SetShowMaximizeButton default True;
    property ShowCloseButton: Boolean read FShowCloseButton write SetShowCloseButton default True;
    property AllowResize: Boolean read FAllowResize write SetAllowResize default True;
    property AllowDragMove: Boolean read FAllowDragMove write SetAllowDragMove default True;
    property DrawAccentLine: Boolean read FDrawAccentLine write SetDrawAccentLine default True;
    property DrawOuterBorder: Boolean read FDrawOuterBorder write SetDrawOuterBorder default True;
    property DrawRoundedChromeBorder: Boolean read FDrawRoundedChromeBorder
      write SetDrawRoundedChromeBorder default True;
    property ClipWindowToChromeCorners: Boolean read FClipWindowToChromeCorners
      write SetClipWindowToChromeCorners default False;
    property ChromeStatusBorderThickness: Integer read FChromeStatusBorderThickness
      write SetChromeStatusBorderThickness default 2;
  end;

implementation

type
  TControlCracker = class(TControl);

  TThemedModernFormAccessibilityAdapter = class(TInterfacedObject, IThemedModernFormAccessibilityHost)
  strict private
    FForm: TThemedModernForm;
  public
    constructor Create(const AForm: TThemedModernForm);
    procedure Detach;
    function GetWindowHandle: HWND;
    function GetCaptionText: string;
    function GetCustomChrome: Boolean;
    function GetFormVisible: Boolean;
    function GetMaximized: Boolean;
    function GetFormScreenBounds: TRect;
    function GetTitleBarScreenBounds: TRect;
    function GetSystemMenuScreenBounds: TRect;
    function IsSystemMenuVisible: Boolean;
    function IsButtonVisible(const AButton: TThemedModernFormWindowButton): Boolean;
    function IsButtonAvailable(const AButton: TThemedModernFormWindowButton): Boolean;
    function IsButtonHot(const AButton: TThemedModernFormWindowButton): Boolean;
    function IsButtonPressed(const AButton: TThemedModernFormWindowButton): Boolean;
    function GetButtonScreenBounds(const AButton: TThemedModernFormWindowButton): TRect;
    procedure ShowSystemMenu;
    procedure ExecuteButton(const AButton: TThemedModernFormWindowButton);
    function GetContentWindowCount: Integer;
    function GetContentWindowHandle(const AIndex: Integer): HWND;
  end;

function GetXLParam(const ALParam: LPARAM): Integer;
begin
  Result := SmallInt(LoWord(DWORD(ALParam)));
end;

function GetYLParam(const ALParam: LPARAM): Integer;
begin
  Result := SmallInt(HiWord(DWORD(ALParam)));
end;

constructor TThemedModernFormHostPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  BevelOuter := bvNone;
  BorderWidth := 0;
  ShowCaption := False;
  Caption := '';
  ParentBackground := False;
  TabStop := False;
  Margins.SetBounds(0, 0, 0, 0);
  Padding.SetBounds(0, 0, 0, 0);
end;

procedure TThemedModernFormHostPanel.ApplyTheme(const APalette: TThemePalette);
begin
end;

procedure TThemedModernFormHostPanel.CMControlListChange(var AMessage: TMessage);
begin
  inherited;
  if Assigned(FOnControlListChange) then
    FOnControlListChange(Self, TControl(AMessage.WParam), AMessage.LParam <> 0);
end;

constructor TThemedModernFormChildHook.Create(const AForm: TThemedModernForm; const AControl: TControl);
begin
  inherited Create(nil);
  FForm := AForm;
  FControl := AControl;
  FOldProc := AControl.WindowProc;
  FActive := True;
  AControl.WindowProc := HookProc;
  AControl.FreeNotification(Self);
end;

procedure TThemedModernFormChildHook.HookProc(var AMessage: TMessage);
begin
  FOldProc(AMessage);
  if FActive and (FControl <> nil) and (FForm <> nil) then
    FForm.ChildMessage(FControl, AMessage);
end;

procedure TThemedModernFormChildHook.Notification(AComponent: TComponent; AOperation: TOperation);
begin
  inherited Notification(AComponent, AOperation);
  if (AOperation = opRemove) and (AComponent = FControl) then
  begin
    FActive := False;
    FControl := nil;
    if FForm <> nil then
      FForm.ForgetHook(TControl(AComponent));
  end;
end;

function TThemedModernFormChildHook.Release: Boolean;
var
  LCurrent: TWndMethod;
  LHook: TWndMethod;
begin
  Result := True;
  FActive := False;
  if FControl = nil then
    Exit;
  LCurrent := FControl.WindowProc;
  LHook := HookProc;
  if (TMethod(LCurrent).Code = TMethod(LHook).Code) and (TMethod(LCurrent).Data = TMethod(LHook).Data) then
    FControl.WindowProc := FOldProc
  else
    Result := False;
  FControl.RemoveFreeNotification(Self);
  FControl := nil;
end;

constructor TThemedModernFormAccessibilityAdapter.Create(const AForm: TThemedModernForm);
begin
  inherited Create;
  FForm := AForm;
end;

procedure TThemedModernFormAccessibilityAdapter.Detach;
begin
  FForm := nil;
end;

function TThemedModernFormAccessibilityAdapter.GetWindowHandle: HWND;
begin
  if (FForm <> nil) and FForm.HandleAllocated then
    Result := FForm.Handle
  else
    Result := 0;
end;

function TThemedModernFormAccessibilityAdapter.GetCaptionText: string;
begin
  if FForm = nil then
    Result := ''
  else
    Result := FForm.Caption;
end;

function TThemedModernFormAccessibilityAdapter.GetCustomChrome: Boolean;
begin
  Result := (FForm <> nil) and FForm.FAllowCustomChrome;
end;

function TThemedModernFormAccessibilityAdapter.GetFormVisible: Boolean;
begin
  Result := (FForm <> nil) and FForm.Visible;
end;

function TThemedModernFormAccessibilityAdapter.GetMaximized: Boolean;
begin
  Result := (FForm <> nil) and (FForm.WindowState = wsMaximized);
end;

function TThemedModernFormAccessibilityAdapter.GetFormScreenBounds: TRect;
begin
  if (FForm = nil) or not FForm.HandleAllocated then
    Exit(Rect(0, 0, 0, 0));
  Result := Rect(FForm.Left, FForm.Top, FForm.Left + FForm.Width, FForm.Top + FForm.Height);
end;

function TThemedModernFormAccessibilityAdapter.GetTitleBarScreenBounds: TRect;
var
  LOrigin: TPoint;
begin
  if (FForm = nil) or not FForm.HandleAllocated or not FForm.FAllowCustomChrome then
    Exit(Rect(0, 0, 0, 0));
  LOrigin := FForm.ClientOriginPoint;
  Result := FForm.TitleBarBounds;
  OffsetRect(Result, LOrigin.X, LOrigin.Y);
end;

function TThemedModernFormAccessibilityAdapter.GetSystemMenuScreenBounds: TRect;
var
  LOrigin: TPoint;
begin
  if (FForm = nil) or not FForm.HandleAllocated or not FForm.IsSystemMenuAccessibleVisible then
    Exit(Rect(0, 0, 0, 0));
  LOrigin := FForm.ClientOriginPoint;
  Result := FForm.GetIconRectangle;
  OffsetRect(Result, LOrigin.X, LOrigin.Y);
end;

function TThemedModernFormAccessibilityAdapter.IsSystemMenuVisible: Boolean;
begin
  Result := (FForm <> nil) and FForm.IsSystemMenuAccessibleVisible;
end;

function TThemedModernFormAccessibilityAdapter.IsButtonVisible(const AButton: TThemedModernFormWindowButton): Boolean;
begin
  Result := (FForm <> nil) and FForm.IsWindowButtonVisible(AButton);
end;

function TThemedModernFormAccessibilityAdapter.IsButtonAvailable(const AButton: TThemedModernFormWindowButton): Boolean;
begin
  Result := (FForm <> nil) and FForm.IsWindowButtonAvailable(AButton);
end;

function TThemedModernFormAccessibilityAdapter.IsButtonHot(const AButton: TThemedModernFormWindowButton): Boolean;
begin
  Result := (FForm <> nil) and (FForm.FHoverButton = AButton);
end;

function TThemedModernFormAccessibilityAdapter.IsButtonPressed(const AButton: TThemedModernFormWindowButton): Boolean;
begin
  Result := (FForm <> nil) and (FForm.FPressedButton = AButton);
end;

function TThemedModernFormAccessibilityAdapter.GetButtonScreenBounds(
  const AButton: TThemedModernFormWindowButton): TRect;
var
  LOrigin: TPoint;
begin
  if (FForm = nil) or not FForm.HandleAllocated then
    Exit(Rect(0, 0, 0, 0));
  LOrigin := FForm.ClientOriginPoint;
  Result := FForm.GetButtonRectangle(AButton);
  OffsetRect(Result, LOrigin.X, LOrigin.Y);
end;

procedure TThemedModernFormAccessibilityAdapter.ShowSystemMenu;
var
  LPoint: TPoint;
begin
  if (FForm = nil) or not FForm.HandleAllocated then
    Exit;
  LPoint := FForm.GetSystemMenuLaunchPoint;
  Winapi.Windows.ClientToScreen(FForm.Handle, LPoint);
  FForm.ShowSystemMenu(LPoint);
end;

procedure TThemedModernFormAccessibilityAdapter.ExecuteButton(const AButton: TThemedModernFormWindowButton);
begin
  if (FForm <> nil) and FForm.HandleAllocated then
    FForm.ExecuteWindowButton(AButton);
end;

function TThemedModernFormAccessibilityAdapter.GetContentWindowCount: Integer;
begin
  if FForm = nil then
    Result := 0
  else
    Result := FForm.GetAccessibleContentControlCount;
end;

function TThemedModernFormAccessibilityAdapter.GetContentWindowHandle(const AIndex: Integer): HWND;
var
  LControl: TWinControl;
begin
  Result := 0;
  if FForm = nil then
    Exit;
  LControl := FForm.GetAccessibleContentControlAt(AIndex);
  if (LControl <> nil) and LControl.HandleAllocated then
    Result := LControl.Handle;
end;

constructor TThemedModernForm.CreateNew(AOwner: TComponent; Dummy: Integer);
begin
  inherited CreateNew(AOwner, Dummy);
  FCurrentDpi := LogicalDpi;
  FHitTestModes := TDictionary<TControl, TThemedModernFormTitleBarHitTestMode>.Create;
  FHooks := TDictionary<TControl, TThemedModernFormChildHook>.Create;
  FHookStore := TObjectList<TThemedModernFormChildHook>.Create(True);
  if ThemeManager.CurrentTheme <> nil then
    FThemePalette := ThemeManager.CurrentTheme.Clone;
  FPalette := TThemedModernFormPalette.FromThemePalette(FThemePalette);
  FMetrics := TThemedModernFormChromeMetrics.CreateDefault(1);
  FHoverButton := TThemedModernFormWindowButton.None;
  FPressedButton := TThemedModernFormWindowButton.None;
  FCornerMode := TThemedModernFormCornerMode.Round;
  FChromeState := TThemedModernFormChromeState.Normal;
  FTitleBarMode := TThemedModernFormTitleBarMode.Normal;
  FActive := True;
  FAllowCustomChrome := True;
  FUseNativeSnapLayout := True;
  FHideNativeBorder := True;
  FCustomChromeStatusColor := 0;
  FAutoApplyCurrentTheme := True;
  FApplyThemeToChildControls := True;
  FClipWindowToChromeCorners := False;
  FShowChromeIcon := True;
  FShowChromeTitle := True;
  FShowMinimizeButton := True;
  FShowMaximizeButton := True;
  FShowCloseButton := True;
  FAllowResize := True;
  FAllowDragMove := True;
  FDrawAccentLine := True;
  FDrawOuterBorder := True;
  FDrawRoundedChromeBorder := True;
  FChromeStatusBorderThickness := 2;
  FLastWindowState := wsNormal;
  FLastRegionWidth := -1;
  FLastRegionHeight := -1;
  FLastRegionRadius := -1;
  FLastRegionCleared := False;
  DoubleBuffered := True;
  BorderStyle := bsNone;
  Position := poScreenCenter;
  Constraints.MinWidth := 320;
  Constraints.MinHeight := 180;
  Color := ThemeColorToColor(FPalette.BackColor);
  Font.Name := ThemedModernFormTexts.DefaultFontName;
  Font.Size := 9;
  UpdatePadding;
  CreateTitleBarHosts;
  ThemeManager.RegisterAware(Self);
end;

destructor TThemedModernForm.Destroy;
var
  I: Integer;
begin
  ThemeManager.UnregisterAware(Self);
  if FHookStore <> nil then
    for I := 0 to FHookStore.Count - 1 do
      FHookStore[I].Release;
  if FAccessibilityHost <> nil then
    TThemedModernFormAccessibilityAdapter(FAccessibilityHost as TObject).Detach;
  if FAccessible <> nil then
    TThemedModernFormAccessibility.Detach(FAccessible);
  FAccessible := nil;
  FAccessibilityHost := nil;
  FHooks.Free;
  FHookStore.Free;
  FHitTestModes.Free;
  inherited Destroy;
  FPalette.Free;
  FThemePalette.Free;
  FMetrics.Free;
end;

function TThemedModernForm.GetMinimizeBox: Boolean;
begin
  Result := biMinimize in BorderIcons;
end;

function TThemedModernForm.GetMaximizeBox: Boolean;
begin
  Result := biMaximize in BorderIcons;
end;

function TThemedModernForm.GetIconHandle: HICON;
begin
  Result := 0;
  if Icon.HandleAllocated then
    Exit(Icon.Handle);
  if Application.Icon.HandleAllocated then
    Result := Application.Icon.Handle;
end;

function TThemedModernForm.HasChromeIcon: Boolean;
begin
  Result := FShowChromeIcon and (GetIconHandle <> 0);
end;

function TThemedModernForm.ClientOriginPoint: TPoint;
begin
  Result := Point(0, 0);
  if HandleAllocated then
    Winapi.Windows.ClientToScreen(Handle, Result);
end;

function TThemedModernForm.GetTitleBarBounds: TRect;
begin
  Result := Rect(0, 0, Width, GetTitleBarHeight + FMetrics.BorderThickness);
end;

function TThemedModernForm.GetClientContentBounds: TRect;
begin
  Result := Rect(Padding.Left, Padding.Top, Padding.Left + Max(0, ClientWidth - Padding.Left - Padding.Right),
    Padding.Top + Max(0, ClientHeight - Padding.Top - Padding.Bottom));
end;

function TThemedModernForm.GetDpiScaleFactor: Single;
begin
  Result := FCurrentDpi / LogicalDpi;
end;

function TThemedModernForm.GetScaleFactorSafe: Single;
begin
  if FCurrentDpi > 0 then
    Result := FCurrentDpi / LogicalDpi
  else
    Result := 1;
end;

function TThemedModernForm.Scale(const AValue: Integer): Integer;
begin
  if AValue = 0 then
    Exit(0);
  Result := Max(1, RoundAwayFromZero(AValue * GetScaleFactorSafe));
end;

procedure TThemedModernForm.InvalidateRectSafe(const ARect: TRect);
var
  LRect: TRect;
begin
  if not HandleAllocated then
    Exit;
  LRect := ARect;
  InvalidateRect(Handle, @LRect, False);
end;

procedure TThemedModernForm.InvalidateTitleBar;
begin
  InvalidateRectSafe(TitleBarBounds);
end;

procedure TThemedModernForm.InvalidateAll;
begin
  if not HandleAllocated then
    Exit;
  RedrawWindow(Handle, nil, 0, RDW_INVALIDATE or RDW_ALLCHILDREN);
end;

procedure TThemedModernForm.SetChromePalette(const AValue: TThemedModernFormPalette);
var
  LNew: TThemedModernFormPalette;
begin
  if AValue = FPalette then
    Exit;
  if AValue = nil then
    LNew := TThemedModernFormPalette.CreateDark
  else
    LNew := AValue.Clone;
  FPalette.Free;
  FPalette := LNew;
  ApplyChromePalette;
end;

procedure TThemedModernForm.SetAutoApplyCurrentTheme(const AValue: Boolean);
begin
  if FAutoApplyCurrentTheme = AValue then
    Exit;
  FAutoApplyCurrentTheme := AValue;
  if FAutoApplyCurrentTheme then
    ApplyThemePalette(ThemeManager.CurrentTheme);
end;

procedure TThemedModernForm.SetApplyThemeToChildControls(const AValue: Boolean);
begin
  if FApplyThemeToChildControls = AValue then
    Exit;
  FApplyThemeToChildControls := AValue;
  if FApplyThemeToChildControls and (FThemePalette <> nil) then
    ApplyThemeToChildren(FThemePalette);
end;

procedure TThemedModernForm.SetChromeState(const AValue: TThemedModernFormChromeState);
begin
  if FChromeState = AValue then
    Exit;
  FChromeState := AValue;
  ApplyDwmColors;
  Invalidate;
end;

procedure TThemedModernForm.SetTitleBarMode(const AValue: TThemedModernFormTitleBarMode);
begin
  if FTitleBarMode = AValue then
    Exit;
  FTitleBarMode := AValue;
  UpdatePadding;
  RefreshTitleBarHosts;
  NotifyChromeAccessibilityChanged;
  InvalidateAll;
end;

procedure TThemedModernForm.SetCustomChromeStatusColor(const AValue: TThemeColor);
begin
  if (FCustomChromeStatusColor = AValue) and (FChromeState = TThemedModernFormChromeState.Custom) then
    Exit;
  FCustomChromeStatusColor := AValue;
  FChromeState := TThemedModernFormChromeState.Custom;
  ApplyDwmColors;
  Invalidate;
end;

procedure TThemedModernForm.SetAllowCustomChrome(const AValue: Boolean);
begin
  if FAllowCustomChrome = AValue then
    Exit;
  FAllowCustomChrome := AValue;
  if AValue then
    BorderStyle := bsNone
  else
    BorderStyle := bsSizeable;
  UpdatePadding;
  UpdateTitleBarHostsLayout;
  UpdateChromeRegion;
  NotifyChromeAccessibilityChanged;
  if HandleAllocated then
    RequestChromeSync;
  InvalidateAll;
end;

procedure TThemedModernForm.SetUseNativeSnapLayout(const AValue: Boolean);
begin
  if FUseNativeSnapLayout = AValue then
    Exit;
  FUseNativeSnapLayout := AValue;
  ClearButtonState;
  InvalidateTitleBar;
end;

procedure TThemedModernForm.SetCornerMode(const AValue: TThemedModernFormCornerMode);
begin
  if FCornerMode = AValue then
    Exit;
  FCornerMode := AValue;
  ApplyDwmCornerMode;
  UpdateChromeRegion;
  Invalidate;
end;

procedure TThemedModernForm.SetHideNativeBorder(const AValue: Boolean);
begin
  if FHideNativeBorder = AValue then
    Exit;
  FHideNativeBorder := AValue;
  ApplyDwmColors;
  Invalidate;
end;

procedure TThemedModernForm.SetShowChromeIcon(const AValue: Boolean);
begin
  if FShowChromeIcon = AValue then
    Exit;
  FShowChromeIcon := AValue;
  RefreshTitleBarHosts;
  NotifyChromeAccessibilityChanged;
end;

procedure TThemedModernForm.SetShowChromeTitle(const AValue: Boolean);
begin
  if FShowChromeTitle = AValue then
    Exit;
  FShowChromeTitle := AValue;
  InvalidateTitleBar;
  NotifyChromeAccessibilityChanged;
end;

procedure TThemedModernForm.SetShowMinimizeButton(const AValue: Boolean);
begin
  if FShowMinimizeButton = AValue then
    Exit;
  FShowMinimizeButton := AValue;
  OnWindowButtonConfigurationChanged;
end;

procedure TThemedModernForm.SetShowMaximizeButton(const AValue: Boolean);
begin
  if FShowMaximizeButton = AValue then
    Exit;
  FShowMaximizeButton := AValue;
  OnWindowButtonConfigurationChanged;
end;

procedure TThemedModernForm.SetShowCloseButton(const AValue: Boolean);
begin
  if FShowCloseButton = AValue then
    Exit;
  FShowCloseButton := AValue;
  OnWindowButtonConfigurationChanged;
end;

procedure TThemedModernForm.SetAllowResize(const AValue: Boolean);
begin
  if FAllowResize = AValue then
    Exit;
  FAllowResize := AValue;
  UpdateSystemMenuState;
  Invalidate;
end;

procedure TThemedModernForm.SetAllowDragMove(const AValue: Boolean);
begin
  if FAllowDragMove = AValue then
    Exit;
  FAllowDragMove := AValue;
  UpdateSystemMenuState;
end;

procedure TThemedModernForm.SetDrawAccentLine(const AValue: Boolean);
begin
  if FDrawAccentLine = AValue then
    Exit;
  FDrawAccentLine := AValue;
  Invalidate;
end;

procedure TThemedModernForm.SetDrawOuterBorder(const AValue: Boolean);
begin
  if FDrawOuterBorder = AValue then
    Exit;
  FDrawOuterBorder := AValue;
  UpdatePadding;
  UpdateChromeRegion;
  InvalidateAll;
end;

procedure TThemedModernForm.SetDrawRoundedChromeBorder(const AValue: Boolean);
begin
  if FDrawRoundedChromeBorder = AValue then
    Exit;
  FDrawRoundedChromeBorder := AValue;
  Invalidate;
end;

procedure TThemedModernForm.SetClipWindowToChromeCorners(const AValue: Boolean);
begin
  if FClipWindowToChromeCorners = AValue then
    Exit;
  FClipWindowToChromeCorners := AValue;
  UpdateChromeRegion;
  ApplyDwmCornerMode;
  UpdatePadding;
  RefreshTitleBarHosts;
  InvalidateAll;
end;

procedure TThemedModernForm.SetChromeStatusBorderThickness(const AValue: Integer);
var
  LResolved: Integer;
begin
  LResolved := Max(0, AValue);
  if FChromeStatusBorderThickness = LResolved then
    Exit;
  FChromeStatusBorderThickness := LResolved;
  UpdatePadding;
  UpdateChromeRegion;
  InvalidateAll;
end;

procedure TThemedModernForm.RefreshChromeMetrics;
begin
  NormalizeChromeMetrics;
  UpdatePadding;
  RefreshTitleBarHosts;
  UpdateChromeRegion;
  NotifyChromeAccessibilityChanged;
  InvalidateAll;
end;

procedure TThemedModernForm.ResetChromeMetrics;
begin
  FMetrics.Free;
  FMetrics := TThemedModernFormChromeMetrics.CreateDefault(GetScaleFactorSafe);
  RefreshChromeMetrics;
end;

procedure TThemedModernForm.SetTitleBarHitTestMode(const AControl: TControl;
  const AMode: TThemedModernFormTitleBarHitTestMode);
begin
  if AControl = nil then
    raise EArgumentNilException.Create('AControl');
  if AMode = TThemedModernFormTitleBarHitTestMode.Auto then
  begin
    FHitTestModes.Remove(AControl);
    Exit;
  end;
  FHitTestModes.AddOrSetValue(AControl, AMode);
end;

function TThemedModernForm.GetTitleBarHitTestMode(const AControl: TControl): TThemedModernFormTitleBarHitTestMode;
begin
  if AControl = nil then
    raise EArgumentNilException.Create('AControl');
  Result := ResolveTitleBarHitTestMode(AControl);
end;

procedure TThemedModernForm.ApplyTheme(const APalette: TThemePalette);
begin
  if not FAutoApplyCurrentTheme then
    Exit;
  ApplyThemePalette(APalette);
end;

procedure TThemedModernForm.ApplyThemePalette(const APalette: TThemePalette);
var
  LSource: TThemePalette;
  LClone: TThemePalette;
begin
  LSource := APalette;
  if LSource = nil then
    LSource := ThemeManager.CurrentTheme;
  if LSource = nil then
    Exit;
  LClone := LSource.Clone;
  FThemePalette.Free;
  FThemePalette := LClone;
  FPalette.Free;
  FPalette := TThemedModernFormPalette.FromThemePalette(FThemePalette);
  ApplyChromePalette;
  if FApplyThemeToChildControls then
    ApplyThemeToChildren(FThemePalette);
end;

procedure TThemedModernForm.ApplyChromePalette;
begin
  Color := ThemeColorToColor(FPalette.BackColor);
  Font.Color := ThemeColorToColor(FPalette.TitleBarForeColor);
  UpdateChromeHostColors;
  if FThemePalette <> nil then
    TWin32ThemeHelper.ApplyImmersiveDarkMode(Self, FThemePalette.IsDark);
  ApplyDwmColors;
  OnChromePaletteChanged;
  InvalidateAll;
end;

procedure TThemedModernForm.OnChromePaletteChanged;
begin
end;

function TThemedModernForm.GetChromeStatusColor: TThemeColor;
begin
  if not FActive then
    Exit(FPalette.BorderInactiveColor);
  if (FChromeState = TThemedModernFormChromeState.Custom) and (FCustomChromeStatusColor <> 0) then
    Exit(FCustomChromeStatusColor);
  case FChromeState of
    TThemedModernFormChromeState.Success: Result := ThemeColor(255, 22, 163, 74);
    TThemedModernFormChromeState.Warning: Result := ThemeColor(255, 245, 158, 11);
    TThemedModernFormChromeState.Error: Result := ThemeColor(255, 220, 38, 38);
    TThemedModernFormChromeState.Debug: Result := ThemeColor(255, 168, 85, 247);
  else
    Result := FPalette.BorderColor;
  end;
end;

procedure TThemedModernForm.ApplyDwmColors;
var
  LBorder: Integer;
begin
  if (not HandleAllocated) or (not TThemedModernFormNative.SupportsDwmWindowAttributes) then
    Exit;
  if FHideNativeBorder then
    LBorder := TThemedModernFormNative.DWMWA_COLOR_NONE
  else
    LBorder := TThemedModernFormNative.ToColorRef(GetChromeStatusColor);
  TThemedModernFormNative.TrySetDwmWindowAttribute(Handle, TThemedModernFormNative.DWMWA_BORDER_COLOR, LBorder);
  TThemedModernFormNative.TrySetDwmWindowAttribute(Handle, TThemedModernFormNative.DWMWA_CAPTION_COLOR,
    TThemedModernFormNative.ToColorRef(FPalette.TitleBarBackColor));
  TThemedModernFormNative.TrySetDwmWindowAttribute(Handle, TThemedModernFormNative.DWMWA_TEXT_COLOR,
    TThemedModernFormNative.ToColorRef(FPalette.TitleBarForeColor));
end;

procedure TThemedModernForm.ApplyDwmShadow;
begin
  if (not HandleAllocated) or (not FAllowCustomChrome) or (not TThemedModernFormNative.IsDwmCompositionEnabled) then
    Exit;
  TThemedModernFormNative.TrySetDwmWindowAttribute(Handle, TThemedModernFormNative.DWMWA_NCRENDERING_POLICY,
    TThemedModernFormNative.DWMNCRP_ENABLED);
end;

procedure TThemedModernForm.ApplyDwmCornerMode;
var
  LValue: Integer;
begin
  if (not HandleAllocated) or (not TThemedModernFormNative.SupportsDwmWindowAttributes) then
    Exit;
  if (not FAllowCustomChrome) or (WindowState = wsMaximized) then
    LValue := TThemedModernFormNative.DWMWCP_DEFAULT
  else if FCornerMode = TThemedModernFormCornerMode.Square then
    LValue := TThemedModernFormNative.DWMWCP_DONOTROUND
  else if FCornerMode = TThemedModernFormCornerMode.RoundSmall then
    LValue := TThemedModernFormNative.DWMWCP_ROUNDSMALL
  else
    LValue := TThemedModernFormNative.DWMWCP_ROUND;
  TThemedModernFormNative.TrySetDwmWindowAttribute(Handle,
    TThemedModernFormNative.DWMWA_WINDOW_CORNER_PREFERENCE, LValue);
end;

procedure TThemedModernForm.SyncChromeNow;
begin
  if (FMetrics = nil) or (not HandleAllocated) or (csDestroying in ComponentState) or FChromeSyncInProgress then
    Exit;
  FChromeSyncInProgress := True;
  try
    EnsureDpiMetricsCurrent;
    ApplyDwmShadow;
    ApplyDwmCornerMode;
    ApplyDwmColors;
    UpdateSystemMenuState;
    UpdateChromeRegion;
    UpdateChromeHostColors;
    RefreshTitleBarHosts;
    InvalidateAll;
  finally
    FChromeSyncInProgress := False;
  end;
end;

procedure TThemedModernForm.RequestChromeSync;
begin
  if FChromeSyncPending or FChromeSyncInProgress or (csDestroying in ComponentState) or (not HandleAllocated) then
    Exit;
  FChromeSyncPending := True;
  if not PostMessage(Handle, TThemedModernFormNative.WM_CHROME_SYNC, 0, 0) then
    FChromeSyncPending := False;
end;

procedure TThemedModernForm.ApplyThemeToChildren(const APalette: TThemePalette);
var
  I: Integer;
  LChild: TControl;
begin
  if APalette = nil then
    Exit;
  for I := 0 to ControlCount - 1 do
  begin
    LChild := Controls[I];
    if (LChild = nil) or (LChild = FTitleBarOverlay) then
      Continue;
    ApplyThemeToControl(LChild, APalette);
  end;
end;

procedure TThemedModernForm.ApplyThemeToControl(const AControl: TControl; const APalette: TThemePalette);
var
  LAware: IThemeAware;
  LCracker: TControlCracker;
  I: Integer;
begin
  if (AControl = nil) or (APalette = nil) or (csDestroying in AControl.ComponentState) then
    Exit;
  LCracker := TControlCracker(AControl);
  if Supports(AControl, IThemeAware, LAware) then
    LAware.ApplyTheme(APalette)
  else if AControl is TToolBar then
    ApplyThemeToToolBar(TToolBar(AControl), APalette)
  else if (AControl is TCustomEdit) or (AControl is TCustomComboBox) or (AControl is TCustomListBox) or
    (AControl is TCustomListView) or (AControl is TCustomTreeView) then
  begin
    LCracker.Color := ThemeColorToColor(APalette.InputBackColor);
    LCracker.Font.Color := ThemeColorToColor(APalette.InputForeColor);
  end
  else if AControl is TCustomButton then
  begin
    LCracker.Color := ThemeColorToColor(APalette.ControlBackColor);
    LCracker.Font.Color := ThemeColorToColor(APalette.ControlForeColor);
  end
  else
  begin
    LCracker.Color := ThemeColorToColor(APalette.PanelBackColor);
    LCracker.Font.Color := ThemeColorToColor(APalette.ControlForeColor);
  end;
  if AControl is TWinControl then
    for I := 0 to TWinControl(AControl).ControlCount - 1 do
      ApplyThemeToControl(TWinControl(AControl).Controls[I], APalette);
end;

procedure TThemedModernForm.ApplyThemeToToolBar(const AToolBar: TToolBar; const APalette: TThemePalette);
begin
  AToolBar.Color := ThemeColorToColor(APalette.MenuBackColor);
  AToolBar.Font.Color := ThemeColorToColor(APalette.MenuForeColor);
end;

procedure TThemedModernForm.UpdateChromeHostColors;
var
  LColor: TColor;
begin
  LColor := ThemeColorToColor(FPalette.TitleBarBackColor);
  if FTitleBarOverlay <> nil then
    FTitleBarOverlay.Color := LColor;
  if FTitleBarLeftHost <> nil then
    FTitleBarLeftHost.Color := LColor;
  if FTitleBarCenterHost <> nil then
    FTitleBarCenterHost.Color := LColor;
  if FTitleBarRightHost <> nil then
    FTitleBarRightHost.Color := LColor;
end;

procedure TThemedModernForm.CreateParams(var AParams: TCreateParams);
begin
  inherited CreateParams(AParams);
  if FAllowCustomChrome then
  begin
    AParams.Style := AParams.Style or WS_SYSMENU or WS_THICKFRAME;
    if MinimizeBox then
      AParams.Style := AParams.Style or WS_MINIMIZEBOX;
    if MaximizeBox then
      AParams.Style := AParams.Style or WS_MAXIMIZEBOX;
  end;
end;

procedure TThemedModernForm.CreateWnd;
begin
  inherited CreateWnd;
  if FMetrics = nil then
    Exit;
  UpdateDpiMetrics(GetWindowDpiSafe, False);
  if FAutoApplyCurrentTheme and (ThemeManager.CurrentTheme <> nil) then
    ApplyThemePalette(ThemeManager.CurrentTheme);
  SyncChromeNow;
  RequestChromeSync;
end;

procedure TThemedModernForm.DestroyWnd;
begin
  FLastRegionCleared := False;
  FLastRegionWidth := -1;
  FLastRegionHeight := -1;
  FLastRegionRadius := -1;
  inherited DestroyWnd;
end;

procedure TThemedModernForm.Loaded;
begin
  inherited Loaded;
  if FAllowCustomChrome and (BorderStyle <> bsNone) then
    BorderStyle := bsNone;
  UpdatePadding;
  if FApplyThemeToChildControls and (FThemePalette <> nil) then
    ApplyThemeToChildren(FThemePalette);
end;

procedure TThemedModernForm.DoShow;
begin
  inherited DoShow;
  UpdatePadding;
  SyncChromeNow;
  RequestChromeSync;
end;

procedure TThemedModernForm.Resize;
begin
  inherited Resize;
  if FMetrics = nil then
    Exit;
  if FLastWindowState <> WindowState then
  begin
    FLastWindowState := WindowState;
    UpdatePadding;
    UpdateSystemMenuState;
    NotifyChromeAccessibilityChanged;
  end;
  RefreshTitleBarHosts;
  ApplyDwmColors;
  UpdateChromeRegion;
  Invalidate;
end;

procedure TThemedModernForm.Activate;
begin
  inherited Activate;
  FActive := True;
  SyncChromeNow;
end;

procedure TThemedModernForm.Deactivate;
begin
  inherited Deactivate;
  FActive := False;
  FHoverButton := TThemedModernFormWindowButton.None;
  FPressedButton := TThemedModernFormWindowButton.None;
  SyncChromeNow;
end;

procedure TThemedModernForm.CMControlListChange(var AMessage: TMessage);
var
  LControl: TControl;
begin
  inherited;
  if (FMetrics = nil) or (csDestroying in ComponentState) or (csLoading in ComponentState) then
    Exit;
  LControl := TControl(AMessage.WParam);
  if (LControl = nil) or (LControl = FTitleBarOverlay) or (AMessage.LParam = 0) then
    Exit;
  if FApplyThemeToChildControls and (FThemePalette <> nil) then
    ApplyThemeToControl(LControl, FThemePalette);
  RefreshTitleBarHosts;
end;

procedure TThemedModernForm.CMMouseLeave(var AMessage: TMessage);
begin
  inherited;
  if (FHoverButton <> TThemedModernFormWindowButton.None) or (FPressedButton <> TThemedModernFormWindowButton.None) then
  begin
    FHoverButton := TThemedModernFormWindowButton.None;
    FPressedButton := TThemedModernFormWindowButton.None;
    InvalidateTitleBar;
  end;
end;

procedure TThemedModernForm.CMTextChanged(var AMessage: TMessage);
begin
  inherited;
  if FMetrics = nil then
    Exit;
  InvalidateTitleBar;
  NotifyChromeAccessibilityNameChanged;
end;

procedure TThemedModernForm.CMFontChanged(var AMessage: TMessage);
begin
  inherited;
  if FMetrics = nil then
    Exit;
  InvalidateTitleBar;
end;

procedure TThemedModernForm.CMVisibleChanged(var AMessage: TMessage);
begin
  inherited;
  if (FMetrics <> nil) and Visible then
  begin
    UpdateChromeRegion;
    RequestChromeSync;
  end;
end;

procedure TThemedModernForm.Paint;
var
  LGraphics: TGPGraphics;
begin
  inherited Paint;
  if (FMetrics = nil) or (not FAllowCustomChrome) then
    Exit;
  LGraphics := TGPGraphics.Create(Canvas.Handle);
  try
    DrawChrome(LGraphics);
  finally
    LGraphics.Free;
  end;
end;

procedure TThemedModernForm.MouseMove(AShift: TShiftState; AX, AY: Integer);
var
  LButton: TThemedModernFormWindowButton;
begin
  inherited MouseMove(AShift, AX, AY);
  if (not FAllowCustomChrome) or FUseNativeSnapLayout then
    Exit;
  LButton := HitTestButton(Point(AX, AY));
  if FHoverButton <> LButton then
  begin
    FHoverButton := LButton;
    InvalidateTitleBar;
  end;
end;

procedure TThemedModernForm.MouseDown(AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer);
var
  LButton: TThemedModernFormWindowButton;
begin
  inherited MouseDown(AButton, AShift, AX, AY);
  if (not FAllowCustomChrome) or (AButton <> mbLeft) then
    Exit;
  LButton := HitTestButton(Point(AX, AY));
  if FUseNativeSnapLayout and (LButton <> TThemedModernFormWindowButton.None) then
    Exit;
  if not FUseNativeSnapLayout then
    if LButton <> TThemedModernFormWindowButton.None then
    begin
      FPressedButton := LButton;
      InvalidateTitleBar;
      Exit;
    end;
  if FAllowDragMove and IsPointInDraggableTitleBar(Point(AX, AY)) then
    BeginWindowMove;
end;

procedure TThemedModernForm.MouseUp(AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer);
var
  LPressed: TThemedModernFormWindowButton;
  LReleased: TThemedModernFormWindowButton;
begin
  inherited MouseUp(AButton, AShift, AX, AY);
  if (not FAllowCustomChrome) or (AButton <> mbLeft) or FUseNativeSnapLayout then
    Exit;
  LPressed := FPressedButton;
  LReleased := HitTestButton(Point(AX, AY));
  FPressedButton := TThemedModernFormWindowButton.None;
  InvalidateTitleBar;
  if (LPressed = TThemedModernFormWindowButton.None) or (LPressed <> LReleased) then
    Exit;
  ExecuteWindowButton(LPressed);
end;

procedure TThemedModernForm.DblClick;
var
  LPoint: TPoint;
begin
  inherited DblClick;
  if not FAllowCustomChrome then
    Exit;
  LPoint := ScreenToClient(Mouse.CursorPos);
  if HitTestButton(LPoint) <> TThemedModernFormWindowButton.None then
    Exit;
  if FShowMaximizeButton and MaximizeBox and IsPointInDraggableTitleBar(LPoint) then
    ToggleMaximizeRestore;
end;

procedure TThemedModernForm.EnsureAccessible;
begin
  if FAccessible <> nil then
    Exit;
  FAccessibilityHost := TThemedModernFormAccessibilityAdapter.Create(Self);
  FAccessible := TThemedModernFormAccessibility.CreateRoot(FAccessibilityHost);
end;

procedure TThemedModernForm.WndProc(var AMessage: TMessage);
var
  LDpi: Integer;
  LOutResult: LRESULT;
  LHandled: Boolean;
begin
  if FMetrics = nil then
  begin
    inherited WndProc(AMessage);
    Exit;
  end;
  if AMessage.Msg = TThemedModernFormNative.WM_CHROME_SYNC then
  begin
    FChromeSyncPending := False;
    SyncChromeNow;
    Exit;
  end;
  if AMessage.Msg = WM_DPICHANGED then
  begin
    LDpi := GetDpiFromMessage(AMessage);
    inherited WndProc(AMessage);
    UpdateDpiMetrics(LDpi, True);
    RequestChromeSync;
    Exit;
  end;
  if (AMessage.Msg = WM_GETOBJECT) and HandleAllocated then
  begin
    EnsureAccessible;
    if TThemedModernFormAccessibility.HandleGetObject(Handle, AMessage.WParam, AMessage.LParam, FAccessible,
      LOutResult) then
    begin
      AMessage.Result := LOutResult;
      Exit;
    end;
  end;
  if FAllowCustomChrome then
  begin
    case AMessage.Msg of
      WM_NCACTIVATE:
        begin
          ForwardNonClientMessageToDwm(AMessage);
          AMessage.Result := 1;
          RequestChromeSync;
          Exit;
        end;
      WM_DWMCOMPOSITIONCHANGED:
        SyncChromeNow;
      WM_DISPLAYCHANGE, WM_WINDOWPOSCHANGED, WM_SIZE, WM_MOVE:
        RequestChromeSync;
      WM_NCCALCSIZE:
        begin
          AMessage.Result := 0;
          Exit;
        end;
      WM_NCHITTEST:
        begin
          if not TryProcessDwmHitTest(AMessage) then
            WmNcHitTest(AMessage);
          Exit;
        end;
      WM_NCLBUTTONDOWN, WM_NCLBUTTONUP, WM_NCRBUTTONUP, WM_NCLBUTTONDBLCLK, WM_NCMOUSEMOVE, WM_NCMOUSELEAVE:
        begin
          LHandled := False;
          WmNcButtons(AMessage, LHandled);
          if LHandled then
            Exit;
        end;
      WM_GETMINMAXINFO:
        begin
          WmGetMinMaxInfo(AMessage);
          Exit;
        end;
      WM_SYSCOMMAND:
        begin
          LHandled := False;
          WmSysCommand(AMessage, LHandled);
          if LHandled then
            Exit;
        end;
    end;
  end;
  inherited WndProc(AMessage);
end;

function TThemedModernForm.GetDpiFromMessage(const AMessage: TMessage): Integer;
begin
  Result := LoWord(DWORD(AMessage.WParam));
  if Result <= 0 then
    Result := GetWindowDpiSafe;
end;

function TThemedModernForm.TryProcessDwmHitTest(var AMessage: TMessage): Boolean;
var
  LOutResult: LRESULT;
  LHit: Integer;
begin
  Result := False;
  if not HandleAllocated then
    Exit;
  if not TThemedModernFormNative.TryDwmDefWindowProc(Handle, AMessage.Msg, AMessage.WParam, AMessage.LParam,
    LOutResult) then
    Exit;
  LHit := Integer(LOutResult);
  if ((LHit = HTMINBUTTON) and FShowMinimizeButton and MinimizeBox) or
    ((LHit = HTMAXBUTTON) and FShowMaximizeButton and MaximizeBox) or
    ((LHit = HTCLOSE) and FShowCloseButton) or
    ((LHit = HTSYSMENU) and HasChromeIcon) then
  begin
    AMessage.Result := LOutResult;
    Result := True;
  end;
end;

procedure TThemedModernForm.ForwardNonClientMessageToDwm(const AMessage: TMessage);
var
  LOutResult: LRESULT;
begin
  if not HandleAllocated then
    Exit;
  TThemedModernFormNative.TryDwmDefWindowProc(Handle, AMessage.Msg, AMessage.WParam, AMessage.LParam, LOutResult);
end;

procedure TThemedModernForm.WmNcButtons(var AMessage: TMessage; out AHandled: Boolean);
var
  LHit: Integer;
  LPressed: TThemedModernFormWindowButton;
  LPoint: TPoint;
begin
  AHandled := False;
  LHit := Integer(AMessage.WParam);
  case AMessage.Msg of
    WM_NCLBUTTONDOWN:
      begin
        ForwardNonClientMessageToDwm(AMessage);
        if LHit = HTSYSMENU then
        begin
          LPoint := GetSystemMenuLaunchPoint;
          Winapi.Windows.ClientToScreen(Handle, LPoint);
          ShowSystemMenu(LPoint);
          AHandled := True;
        end
        else if (LHit = HTMINBUTTON) and FShowMinimizeButton and MinimizeBox then
        begin
          FPressedButton := TThemedModernFormWindowButton.Minimize;
          FHoverButton := TThemedModernFormWindowButton.Minimize;
          InvalidateTitleBar;
          AHandled := True;
        end
        else if (LHit = HTMAXBUTTON) and FShowMaximizeButton and MaximizeBox then
        begin
          FPressedButton := TThemedModernFormWindowButton.MaximizeRestore;
          FHoverButton := TThemedModernFormWindowButton.MaximizeRestore;
          InvalidateTitleBar;
          AHandled := True;
        end
        else if (LHit = HTCLOSE) and FShowCloseButton then
        begin
          FPressedButton := TThemedModernFormWindowButton.Close;
          FHoverButton := TThemedModernFormWindowButton.Close;
          InvalidateTitleBar;
          AHandled := True;
        end;
      end;
    WM_NCLBUTTONUP:
      begin
        ForwardNonClientMessageToDwm(AMessage);
        LPressed := FPressedButton;
        FPressedButton := TThemedModernFormWindowButton.None;
        InvalidateTitleBar;
        if (LHit = HTMINBUTTON) and (LPressed = TThemedModernFormWindowButton.Minimize) then
        begin
          ExecuteWindowButton(TThemedModernFormWindowButton.Minimize);
          AHandled := True;
        end
        else if (LHit = HTMAXBUTTON) and (LPressed = TThemedModernFormWindowButton.MaximizeRestore) then
        begin
          ExecuteWindowButton(TThemedModernFormWindowButton.MaximizeRestore);
          AHandled := True;
        end
        else if (LHit = HTCLOSE) and (LPressed = TThemedModernFormWindowButton.Close) then
        begin
          ExecuteWindowButton(TThemedModernFormWindowButton.Close);
          AHandled := True;
        end;
      end;
    WM_NCRBUTTONUP:
      if (LHit = HTCAPTION) or (LHit = HTSYSMENU) then
      begin
        ShowSystemMenu(Point(GetXLParam(AMessage.LParam), GetYLParam(AMessage.LParam)));
        AHandled := True;
      end;
    WM_NCLBUTTONDBLCLK:
      if LHit = HTSYSMENU then
      begin
        Close;
        AHandled := True;
      end;
    WM_NCMOUSEMOVE:
      begin
        ForwardNonClientMessageToDwm(AMessage);
        UpdateNativeButtonHover(LHit);
      end;
    WM_NCMOUSELEAVE:
      begin
        ForwardNonClientMessageToDwm(AMessage);
        ClearButtonState;
      end;
  end;
end;

procedure TThemedModernForm.WmSysCommand(var AMessage: TMessage; out AHandled: Boolean);
var
  LCommand: Integer;
begin
  AHandled := False;
  LCommand := Integer(AMessage.WParam) and $FFF0;
  if LCommand = SC_MAXIMIZE then
  begin
    if MaximizeBox and (WindowState <> wsMaximized) then
      MaximizeToWorkingArea;
    AHandled := True;
  end
  else if LCommand = SC_RESTORE then
  begin
    if WindowState <> wsNormal then
      RestoreFromCustomMaximize;
    AHandled := True;
  end
  else if LCommand = SC_MINIMIZE then
  begin
    if MinimizeBox then
      WindowState := wsMinimized;
    AHandled := True;
  end
  else if LCommand = SC_CLOSE then
  begin
    Close;
    AHandled := True;
  end
  else if (LCommand = SC_SIZE) and (not Resizable) then
    AHandled := True
  else if (LCommand = SC_MOVE) and (not FAllowDragMove) then
    AHandled := True;
end;

procedure TThemedModernForm.WmNcHitTest(var AMessage: TMessage);
var
  LClient: TPoint;
  LHit: Integer;
begin
  LClient := ScreenToClient(Point(GetXLParam(AMessage.LParam), GetYLParam(AMessage.LParam)));
  LHit := GetResizeHitTest(LClient);
  if LHit <> HTCLIENT then
  begin
    AMessage.Result := LHit;
    Exit;
  end;
  if HasChromeIcon and PtInRect(GetIconRectangle, LClient) then
  begin
    AMessage.Result := HTSYSMENU;
    Exit;
  end;
  if FUseNativeSnapLayout then
  begin
    if FShowCloseButton and PtInRect(GetButtonRectangle(TThemedModernFormWindowButton.Close), LClient) then
    begin
      AMessage.Result := HTCLOSE;
      Exit;
    end;
    if FShowMaximizeButton and MaximizeBox and
      PtInRect(GetButtonRectangle(TThemedModernFormWindowButton.MaximizeRestore), LClient) then
    begin
      AMessage.Result := HTMAXBUTTON;
      Exit;
    end;
    if FShowMinimizeButton and MinimizeBox and
      PtInRect(GetButtonRectangle(TThemedModernFormWindowButton.Minimize), LClient) then
    begin
      AMessage.Result := HTMINBUTTON;
      Exit;
    end;
  end;
  if IsPointOverTitleBarHostControl(LClient) then
  begin
    AMessage.Result := HTCLIENT;
    Exit;
  end;
  if IsPointInDraggableTitleBar(LClient) then
  begin
    AMessage.Result := HTCAPTION;
    Exit;
  end;
  AMessage.Result := HTCLIENT;
end;

procedure TThemedModernForm.WmGetMinMaxInfo(var AMessage: TMessage);
var
  LInfo: PMinMaxInfo;
  LMonitor: TMonitor;
  LWork: TRect;
  LBounds: TRect;
begin
  LMonitor := Screen.MonitorFromWindow(Handle, mdNearest);
  if LMonitor = nil then
  begin
    inherited WndProc(AMessage);
    Exit;
  end;
  LInfo := PMinMaxInfo(AMessage.LParam);
  LWork := LMonitor.WorkareaRect;
  LBounds := LMonitor.BoundsRect;
  LInfo^.ptMaxPosition.X := Abs(LWork.Left - LBounds.Left);
  LInfo^.ptMaxPosition.Y := Abs(LWork.Top - LBounds.Top);
  LInfo^.ptMaxSize.X := Abs(LWork.Right - LWork.Left);
  LInfo^.ptMaxSize.Y := Abs(LWork.Bottom - LWork.Top);
  if Constraints.MinWidth > 0 then
    LInfo^.ptMinTrackSize.X := Constraints.MinWidth;
  if Constraints.MinHeight > 0 then
    LInfo^.ptMinTrackSize.Y := Constraints.MinHeight;
  if Constraints.MaxWidth > 0 then
    LInfo^.ptMaxTrackSize.X := Constraints.MaxWidth;
  if Constraints.MaxHeight > 0 then
    LInfo^.ptMaxTrackSize.Y := Constraints.MaxHeight;
  AMessage.Result := 0;
end;

function TThemedModernForm.GetSystemMenuLaunchPoint: TPoint;
var
  LIcon: TRect;
begin
  LIcon := GetIconRectangle;
  Result := Point(LIcon.Left, GetTitleBarHeight + GetChromeTopInset);
end;

procedure TThemedModernForm.ShowSystemMenu(const AScreenLocation: TPoint);
var
  LMenu: HMENU;
  LCommand: Integer;
begin
  if not HandleAllocated then
    Exit;
  UpdateSystemMenuState;
  LMenu := GetSystemMenu(Handle, False);
  if LMenu = 0 then
    Exit;
  LCommand := Integer(TrackPopupMenuEx(LMenu, TPM_LEFTBUTTON or TPM_RETURNCMD, AScreenLocation.X,
    AScreenLocation.Y, Handle, nil));
  if LCommand = 0 then
    Exit;
  PostMessage(Handle, WM_SYSCOMMAND, WPARAM(LCommand), 0);
end;

procedure TThemedModernForm.UpdateSystemMenuState;
var
  LMenu: HMENU;
  LNormal: Boolean;
  LMinimized: Boolean;
  LMaximized: Boolean;
begin
  if not HandleAllocated then
    Exit;
  LMenu := GetSystemMenu(Handle, False);
  if LMenu = 0 then
    Exit;
  LNormal := WindowState = wsNormal;
  LMinimized := WindowState = wsMinimized;
  LMaximized := WindowState = wsMaximized;
  TThemedModernFormNative.SetSystemMenuItemEnabled(LMenu, SC_RESTORE, not LNormal);
  TThemedModernFormNative.SetSystemMenuItemEnabled(LMenu, SC_SIZE, Resizable);
  TThemedModernFormNative.SetSystemMenuItemEnabled(LMenu, SC_MOVE, FAllowDragMove and LNormal);
  TThemedModernFormNative.SetSystemMenuItemEnabled(LMenu, SC_MINIMIZE, MinimizeBox and (not LMinimized));
  TThemedModernFormNative.SetSystemMenuItemEnabled(LMenu, SC_MAXIMIZE, MaximizeBox and (not LMaximized));
  TThemedModernFormNative.SetSystemMenuItemEnabled(LMenu, SC_CLOSE, True);
end;

procedure TThemedModernForm.UpdateNativeButtonHover(const AHit: Integer);
var
  LButton: TThemedModernFormWindowButton;
begin
  if not FUseNativeSnapLayout then
    Exit;
  LButton := TThemedModernFormWindowButton.None;
  if AHit = HTMINBUTTON then
    LButton := TThemedModernFormWindowButton.Minimize;
  if AHit = HTMAXBUTTON then
    LButton := TThemedModernFormWindowButton.MaximizeRestore;
  if AHit = HTCLOSE then
    LButton := TThemedModernFormWindowButton.Close;
  if FHoverButton <> LButton then
  begin
    FHoverButton := LButton;
    InvalidateTitleBar;
  end;
end;

procedure TThemedModernForm.ClearButtonState;
begin
  if (FHoverButton = TThemedModernFormWindowButton.None) and (FPressedButton = TThemedModernFormWindowButton.None) then
    Exit;
  FHoverButton := TThemedModernFormWindowButton.None;
  FPressedButton := TThemedModernFormWindowButton.None;
  InvalidateTitleBar;
end;

procedure TThemedModernForm.OnWindowButtonConfigurationChanged;
begin
  if ((not FShowMinimizeButton) and (FHoverButton = TThemedModernFormWindowButton.Minimize)) or
    ((not FShowMaximizeButton) and (FHoverButton = TThemedModernFormWindowButton.MaximizeRestore)) or
    ((not FShowCloseButton) and (FHoverButton = TThemedModernFormWindowButton.Close)) then
    FHoverButton := TThemedModernFormWindowButton.None;
  if ((not FShowMinimizeButton) and (FPressedButton = TThemedModernFormWindowButton.Minimize)) or
    ((not FShowMaximizeButton) and (FPressedButton = TThemedModernFormWindowButton.MaximizeRestore)) or
    ((not FShowCloseButton) and (FPressedButton = TThemedModernFormWindowButton.Close)) then
    FPressedButton := TThemedModernFormWindowButton.None;
  RefreshTitleBarHosts;
  UpdateSystemMenuState;
  NotifyChromeAccessibilityChanged;
  InvalidateTitleBar;
end;

procedure TThemedModernForm.UpdateChromeRegion;
var
  LRadius: Integer;
  LBounds: TRect;
  LDiameter: Integer;
  LRegion: HRGN;
begin
  if (not HandleAllocated) or FUpdatingChromeRegion then
    Exit;
  if (not FAllowCustomChrome) or (not FClipWindowToChromeCorners) or IsNativeDwmRoundingActive or
    (WindowState = wsMaximized) or (FCornerMode = TThemedModernFormCornerMode.Square) then
  begin
    ClearChromeRegion;
    Exit;
  end;
  LRadius := GetChromeCornerRadius;
  LBounds := GetChromeOutlineBounds;
  if (not FLastRegionCleared) and (LBounds.Right - LBounds.Left = FLastRegionWidth) and
    (LBounds.Bottom - LBounds.Top = FLastRegionHeight) and (LRadius = FLastRegionRadius) then
    Exit;
  FUpdatingChromeRegion := True;
  try
    LDiameter := Max(1, LRadius * 2 + 1);
    LRegion := CreateRoundRectRgn(LBounds.Left, LBounds.Top, LBounds.Right + 1, LBounds.Bottom + 1, LDiameter,
      LDiameter);
    if LRegion = 0 then
    begin
      FUpdatingChromeRegion := False;
      ClearChromeRegion;
      Exit;
    end;
    SetWindowRgn(Handle, LRegion, True);
    FLastRegionWidth := LBounds.Right - LBounds.Left;
    FLastRegionHeight := LBounds.Bottom - LBounds.Top;
    FLastRegionRadius := LRadius;
    FLastRegionCleared := False;
  finally
    FUpdatingChromeRegion := False;
  end;
end;

procedure TThemedModernForm.ClearChromeRegion;
begin
  if HandleAllocated and (not FLastRegionCleared) then
  begin
    FUpdatingChromeRegion := True;
    try
      SetWindowRgn(Handle, 0, True);
    finally
      FUpdatingChromeRegion := False;
    end;
  end;
  FLastRegionCleared := True;
  FLastRegionWidth := -1;
  FLastRegionHeight := -1;
  FLastRegionRadius := -1;
end;

procedure TThemedModernForm.BeginWindowMove;
var
  LMouse: TPoint;
  LRatio: Single;
begin
  if WindowState = wsMaximized then
  begin
    LMouse := Mouse.CursorPos;
    if Width <= 0 then
      LRatio := 0.5
    else
      LRatio := ScreenToClient(LMouse).X / Width;
    WindowState := wsNormal;
    Left := LMouse.X - Trunc(Width * LRatio);
    Top := LMouse.Y - GetTitleBarHeight div 2;
  end;
  ReleaseCapture;
  SendMessage(Handle, WM_NCLBUTTONDOWN, HTCAPTION, 0);
end;

procedure TThemedModernForm.ExecuteWindowButton(const AButton: TThemedModernFormWindowButton);
begin
  if AButton = TThemedModernFormWindowButton.Minimize then
    WindowState := wsMinimized
  else if AButton = TThemedModernFormWindowButton.MaximizeRestore then
    ToggleMaximizeRestore
  else if AButton = TThemedModernFormWindowButton.Close then
    Close;
end;

procedure TThemedModernForm.ToggleMaximizeRestore;
begin
  if not MaximizeBox then
    Exit;
  if WindowState = wsMaximized then
    WindowState := wsNormal
  else
    WindowState := wsMaximized;
  Invalidate;
end;

function TThemedModernForm.IsCustomMaximized: Boolean;
begin
  Result := WindowState = wsMaximized;
end;

procedure TThemedModernForm.MaximizeToWorkingArea;
begin
  WindowState := wsMaximized;
  Invalidate;
end;

procedure TThemedModernForm.RestoreFromCustomMaximize;
begin
  WindowState := wsNormal;
  Invalidate;
end;

function TThemedModernForm.GetResizable: Boolean;
begin
  Result := FAllowCustomChrome and FAllowResize and (WindowState = wsNormal);
end;

function TThemedModernForm.GetResizeHitTest(const APoint: TPoint): Integer;
var
  LGrip: Integer;
  LLeft: Boolean;
  LRight: Boolean;
  LTop: Boolean;
  LBottom: Boolean;
begin
  if (not FAllowResize) or (not Resizable) then
    Exit(HTCLIENT);
  LGrip := FMetrics.ResizeGripSize;
  LLeft := APoint.X <= LGrip;
  LRight := APoint.X >= Width - LGrip;
  LTop := APoint.Y <= LGrip;
  LBottom := APoint.Y >= Height - LGrip;
  if LLeft and LTop then
    Exit(HTTOPLEFT);
  if LRight and LTop then
    Exit(HTTOPRIGHT);
  if LLeft and LBottom then
    Exit(HTBOTTOMLEFT);
  if LRight and LBottom then
    Exit(HTBOTTOMRIGHT);
  if LLeft then
    Exit(HTLEFT);
  if LRight then
    Exit(HTRIGHT);
  if LTop then
    Exit(HTTOP);
  if LBottom then
    Exit(HTBOTTOM);
  Result := HTCLIENT;
end;

procedure TThemedModernForm.FillRectColor(const AGraphics: TGPGraphics; const AColor: TThemeColor;
  const ARect: TRect);
var
  LBrush: TGPSolidBrush;
begin
  LBrush := TGPSolidBrush.Create(TGPColor(Cardinal(AColor)));
  try
    AGraphics.FillRectangle(LBrush, ARect.Left, ARect.Top, ARect.Right - ARect.Left, ARect.Bottom - ARect.Top);
  finally
    LBrush.Free;
  end;
end;

function TThemedModernForm.CreateRoundRectanglePath(const ABounds: TRect; ARadius: Integer): TGPGraphicsPath;
var
  LWidth: Integer;
  LHeight: Integer;
  LDiameter: Integer;
begin
  Result := TGPGraphicsPath.Create;
  LWidth := ABounds.Right - ABounds.Left;
  LHeight := ABounds.Bottom - ABounds.Top;
  if (LWidth <= 0) or (LHeight <= 0) then
  begin
    Result.AddRectangle(MakeRect(0, 0, 0, 0));
    Result.CloseFigure;
    Exit;
  end;
  ARadius := Max(0, Min(ARadius, Min(LWidth, LHeight) div 2));
  if ARadius <= 0 then
  begin
    Result.AddRectangle(MakeRect(ABounds.Left, ABounds.Top, LWidth, LHeight));
    Result.CloseFigure;
    Exit;
  end;
  LDiameter := ARadius * 2;
  Result.StartFigure;
  Result.AddArc(ABounds.Left, ABounds.Top, LDiameter, LDiameter, 180, 90);
  Result.AddArc(ABounds.Right - LDiameter, ABounds.Top, LDiameter, LDiameter, 270, 90);
  Result.AddArc(ABounds.Right - LDiameter, ABounds.Bottom - LDiameter, LDiameter, LDiameter, 0, 90);
  Result.AddArc(ABounds.Left, ABounds.Bottom - LDiameter, LDiameter, LDiameter, 90, 90);
  Result.CloseFigure;
end;

function TThemedModernForm.CreateRoundRectanglePath(const ABounds: TGPRectF; ARadius: Single): TGPGraphicsPath;
var
  LDiameter: Single;
  LRight: Single;
  LBottom: Single;
begin
  Result := TGPGraphicsPath.Create;
  if (ABounds.Width <= 0) or (ABounds.Height <= 0) then
  begin
    Result.AddRectangle(MakeRect(Single(0), Single(0), Single(0), Single(0)));
    Result.CloseFigure;
    Exit;
  end;
  ARadius := Max(Single(0), Min(ARadius, Min(ABounds.Width, ABounds.Height) / 2));
  if ARadius <= 0 then
  begin
    Result.AddRectangle(ABounds);
    Result.CloseFigure;
    Exit;
  end;
  LDiameter := ARadius * 2;
  LRight := ABounds.X + ABounds.Width;
  LBottom := ABounds.Y + ABounds.Height;
  Result.StartFigure;
  Result.AddArc(ABounds.X, ABounds.Y, LDiameter, LDiameter, Single(180), Single(90));
  Result.AddArc(LRight - LDiameter, ABounds.Y, LDiameter, LDiameter, Single(270), Single(90));
  Result.AddArc(LRight - LDiameter, LBottom - LDiameter, LDiameter, LDiameter, Single(0), Single(90));
  Result.AddArc(ABounds.X, LBottom - LDiameter, LDiameter, LDiameter, Single(90), Single(90));
  Result.CloseFigure;
end;

procedure TThemedModernForm.DrawChrome(const AGraphics: TGPGraphics);
var
  LState: GraphicsState;
begin
  LState := AGraphics.Save;
  try
    AGraphics.SetSmoothingMode(SmoothingModeAntiAlias);
    AGraphics.SetPixelOffsetMode(PixelOffsetModeHighQuality);
    AGraphics.SetCompositingQuality(CompositingQualityHighQuality);
    DrawChromeBackground(AGraphics);
    DrawTitleBar(AGraphics);
    DrawWindowButtons(AGraphics);
    if FDrawAccentLine then
      DrawAccent(AGraphics);
    if FDrawOuterBorder then
      DrawBorder(AGraphics);
  finally
    AGraphics.Restore(LState);
  end;
end;

procedure TThemedModernForm.DrawChromeBackground(const AGraphics: TGPGraphics);
var
  LInner: TGPRectF;
  LPath: TGPGraphicsPath;
  LBrush: TGPSolidBrush;
begin
  if not IsDwmMaskedAccentBorderActive then
    Exit;
  if (ClientWidth <= 0) or (ClientHeight <= 0) then
    Exit;
  FillRectColor(AGraphics, GetChromeStatusColor, Rect(0, 0, ClientWidth, ClientHeight));
  LInner := GetDwmMaskedAccentInnerBounds;
  if (LInner.Width <= 0) or (LInner.Height <= 0) then
    Exit;
  LPath := CreateRoundRectanglePath(LInner, GetDwmMaskedAccentInnerRadius);
  LBrush := TGPSolidBrush.Create(TGPColor(Cardinal(FPalette.BackColor)));
  try
    AGraphics.FillPath(LBrush, LPath);
  finally
    LBrush.Free;
    LPath.Free;
  end;
end;

procedure TThemedModernForm.DrawTitleBar(const AGraphics: TGPGraphics);
var
  LTitle: TRect;
  LPath: TGPGraphicsPath;
  LState: GraphicsState;
  LX: Integer;
  LIconRect: TRect;
  LButtons: TRect;
  LRight: Integer;
  LText: TRect;
  LCaption: string;
  LColor: TThemeColor;
begin
  LTitle := GetTitleBarPaintBounds;
  if (LTitle.Right - LTitle.Left <= 0) or (LTitle.Bottom - LTitle.Top <= 0) then
    Exit;
  if IsDwmMaskedAccentBorderActive then
  begin
    LPath := CreateRoundRectanglePath(GetDwmMaskedAccentInnerBounds, GetDwmMaskedAccentInnerRadius);
    LState := AGraphics.Save;
    try
      AGraphics.SetClip(LPath, CombineModeIntersect);
      FillRectColor(AGraphics, FPalette.TitleBarBackColor, LTitle);
    finally
      AGraphics.Restore(LState);
      LPath.Free;
    end;
  end
  else
    FillRectColor(AGraphics, FPalette.TitleBarBackColor, LTitle);
  LX := GetTitleBarCaptionLeftPadding + GetLeftChromeInset;
  if HasChromeIcon then
  begin
    LIconRect := GetIconRectangle;
    AGraphics.Flush;
    DrawIconEx(Canvas.Handle, LIconRect.Left, LIconRect.Top, GetIconHandle, LIconRect.Right - LIconRect.Left,
      LIconRect.Bottom - LIconRect.Top, 0, 0, DI_NORMAL);
    LX := LIconRect.Right + GetTitleBarCaptionLeftPadding;
  end;
  if not FShowChromeTitle then
    Exit;
  LButtons := GetAllButtonsRectangle;
  if LButtons.Left > 0 then
    LRight := LButtons.Left
  else
    LRight := Width - GetRightChromeInset;
  if FTitleBarOverlay.Visible and (FTitleBarOverlay.Left > LX) then
    LRight := Min(LRight, FTitleBarOverlay.Left - Scale(4));
  LText := Rect(LX, GetChromeTopInset, LX + Max(0, LRight - LX - GetTitleBarCaptionRightPadding),
    GetChromeTopInset + GetTitleBarHeight);
  if LText.Right - LText.Left <= 0 then
    Exit;
  if FActive then
    LColor := FPalette.TitleBarForeColor
  else
    LColor := FPalette.TitleBarInactiveForeColor;
  AGraphics.Flush;
  LCaption := Caption;
  Canvas.Font.Assign(Font);
  Canvas.Font.Color := ThemeColorToColor(LColor);
  Canvas.Brush.Style := bsClear;
  Canvas.TextRect(LText, LCaption, [tfSingleLine, tfVerticalCenter, tfEndEllipsis, tfNoPrefix]);
end;

procedure TThemedModernForm.DrawWindowButtons(const AGraphics: TGPGraphics);
begin
  if FShowMinimizeButton then
    DrawWindowButton(AGraphics, TThemedModernFormWindowButton.Minimize,
      GetButtonRectangle(TThemedModernFormWindowButton.Minimize));
  if FShowMaximizeButton then
    DrawWindowButton(AGraphics, TThemedModernFormWindowButton.MaximizeRestore,
      GetButtonRectangle(TThemedModernFormWindowButton.MaximizeRestore));
  if FShowCloseButton then
    DrawWindowButton(AGraphics, TThemedModernFormWindowButton.Close,
      GetButtonRectangle(TThemedModernFormWindowButton.Close));
end;

procedure TThemedModernForm.DrawWindowButton(const AGraphics: TGPGraphics;
  const AButton: TThemedModernFormWindowButton; const ABounds: TRect);
var
  LEnabled: Boolean;
  LHover: Boolean;
  LPressed: Boolean;
  LBack: TThemeColor;
  LFill: TRect;
  LGlyph: TThemeColor;
  LPen: TGPPen;
begin
  if (ABounds.Right - ABounds.Left <= 0) or (ABounds.Bottom - ABounds.Top <= 0) then
    Exit;
  LEnabled := IsWindowButtonAvailable(AButton);
  LHover := LEnabled and (FHoverButton = AButton);
  LPressed := LEnabled and (FPressedButton = AButton);
  LBack := 0;
  if AButton = TThemedModernFormWindowButton.Close then
  begin
    if LPressed then
      LBack := FPalette.CloseButtonPressedBackColor
    else if LHover then
      LBack := FPalette.CloseButtonHoverBackColor;
  end
  else
  begin
    if LPressed then
      LBack := FPalette.ButtonPressedBackColor
    else if LHover then
      LBack := FPalette.ButtonHoverBackColor;
  end;
  if LBack <> 0 then
  begin
    LFill := ABounds;
    if (AButton = TThemedModernFormWindowButton.Close) and (FCornerMode <> TThemedModernFormCornerMode.Square) and
      (WindowState <> wsMaximized) then
      LFill.Right := LFill.Left + Max(0, (LFill.Right - LFill.Left) - GetRightChromeInset);
    FillRectColor(AGraphics, LBack, LFill);
  end;
  if LEnabled and FActive then
    LGlyph := FPalette.ButtonGlyphColor
  else
    LGlyph := FPalette.ButtonGlyphInactiveColor;
  if LEnabled and (AButton = TThemedModernFormWindowButton.Close) and LHover then
    LGlyph := $FFFFFFFF;
  LPen := TGPPen.Create(TGPColor(Cardinal(LGlyph)), 1.4);
  try
    LPen.SetStartCap(LineCapSquare);
    LPen.SetEndCap(LineCapSquare);
    if AButton = TThemedModernFormWindowButton.Minimize then
      DrawMinimizeGlyph(AGraphics, LPen, ABounds);
    if AButton = TThemedModernFormWindowButton.MaximizeRestore then
      DrawMaximizeRestoreGlyph(AGraphics, LPen, ABounds);
    if AButton = TThemedModernFormWindowButton.Close then
      DrawCloseGlyph(AGraphics, LPen, ABounds);
  finally
    LPen.Free;
  end;
end;

procedure TThemedModernForm.DrawMinimizeGlyph(const AGraphics: TGPGraphics; const APen: TGPPen;
  const ABounds: TRect);
var
  LW: Integer;
  LX: Integer;
  LY: Integer;
begin
  LW := Scale(10);
  LY := ABounds.Top + (ABounds.Bottom - ABounds.Top) div 2 + Scale(4);
  LX := ABounds.Left + ((ABounds.Right - ABounds.Left) - LW) div 2;
  AGraphics.DrawLine(APen, LX, LY, LX + LW, LY);
end;

procedure TThemedModernForm.DrawMaximizeRestoreGlyph(const AGraphics: TGPGraphics; const APen: TGPPen;
  const ABounds: TRect);
var
  LW: Integer;
  LH: Integer;
  LX: Integer;
  LY: Integer;
  LBrush: TGPSolidBrush;
begin
  LW := Scale(10);
  LH := Scale(10);
  LX := ABounds.Left + ((ABounds.Right - ABounds.Left) - LW) div 2;
  LY := ABounds.Top + ((ABounds.Bottom - ABounds.Top) - LH) div 2;
  if IsCustomMaximized then
  begin
    AGraphics.DrawRectangle(APen, LX + Scale(3), LY - Scale(3), LW, LH);
    LBrush := TGPSolidBrush.Create(TGPColor(Cardinal(FPalette.TitleBarBackColor)));
    try
      AGraphics.FillRectangle(LBrush, LX - 1, LY - 1, LW + 2, LH + 2);
    finally
      LBrush.Free;
    end;
    AGraphics.DrawRectangle(APen, LX, LY, LW, LH);
  end
  else
    AGraphics.DrawRectangle(APen, LX, LY, LW, LH);
end;

procedure TThemedModernForm.DrawCloseGlyph(const AGraphics: TGPGraphics; const APen: TGPPen;
  const ABounds: TRect);
var
  LW: Integer;
  LH: Integer;
  LX: Integer;
  LY: Integer;
begin
  LW := Scale(10);
  LH := Scale(10);
  LX := ABounds.Left + ((ABounds.Right - ABounds.Left) - LW) div 2;
  LY := ABounds.Top + ((ABounds.Bottom - ABounds.Top) - LH) div 2;
  AGraphics.DrawLine(APen, LX, LY, LX + LW, LY + LH);
  AGraphics.DrawLine(APen, LX + LW, LY, LX, LY + LH);
end;

procedure TThemedModernForm.DrawAccent(const AGraphics: TGPGraphics);
var
  LThickness: Integer;
  LInset: Integer;
  LY: Integer;
  LWidth: Integer;
begin
  if FChromeStatusBorderThickness <= 0 then
    Exit;
  LThickness := Max(1, Scale(2));
  if IsDwmMaskedAccentBorderActive then
    LInset := GetChromeBorderThickness
  else
    LInset := 0;
  LY := GetTitleBarHeight + GetChromeTopInset;
  LWidth := Max(0, ClientWidth - LInset - LInset);
  if (LWidth <= 0) or (ClientHeight <= 0) then
    Exit;
  FillRectColor(AGraphics, GetChromeStatusColor, Rect(LInset, LY, LInset + LWidth, LY + LThickness));
end;

procedure TThemedModernForm.DrawBorder(const AGraphics: TGPGraphics);
var
  LThickness: Integer;
  LInset: Integer;
  LBounds: TRect;
  LPen: TGPPen;
  LPath: TGPGraphicsPath;
  LRadius: Integer;
begin
  if (WindowState = wsMaximized) or (FChromeStatusBorderThickness <= 0) then
    Exit;
  if IsDwmMaskedAccentBorderActive then
    Exit;
  LThickness := GetChromeBorderThickness;
  LInset := Max(1, Ceil(LThickness / 2));
  LBounds := Rect(LInset, LInset, LInset + Max(0, ClientWidth - LInset - LInset - 1),
    LInset + Max(0, ClientHeight - LInset - LInset - 1));
  if (LBounds.Right - LBounds.Left <= 0) or (LBounds.Bottom - LBounds.Top <= 0) then
    Exit;
  LPen := TGPPen.Create(TGPColor(Cardinal(GetChromeStatusColor)), LThickness);
  try
    LPen.SetAlignment(PenAlignmentCenter);
    LPen.SetLineJoin(LineJoinRound);
    if (FCornerMode = TThemedModernFormCornerMode.Square) or (not FDrawRoundedChromeBorder) or
      IsNativeDwmRoundingActive then
    begin
      AGraphics.DrawRectangle(LPen, LBounds.Left, LBounds.Top, LBounds.Right - LBounds.Left,
        LBounds.Bottom - LBounds.Top);
      Exit;
    end;
    LRadius := Max(1, GetChromeCornerRadius - LInset);
    LPath := CreateRoundRectanglePath(LBounds, LRadius);
    try
      AGraphics.DrawPath(LPen, LPath);
    finally
      LPath.Free;
    end;
  finally
    LPen.Free;
  end;
end;

function TThemedModernForm.GetTitleBarPaintBounds: TRect;
var
  LBounds: TRect;
  LTop: Integer;
begin
  LBounds := TitleBarBounds;
  if not IsDwmMaskedAccentBorderActive then
    Exit(LBounds);
  LTop := Ceil(GetDwmMaskedAccentTopInset);
  Result := Rect(0, LTop, Max(0, ClientWidth), LTop + Max(0, (LBounds.Bottom - LBounds.Top) - LTop));
end;

function TThemedModernForm.GetDwmMaskedAccentInnerBounds: TGPRectF;
var
  LSide: Single;
  LTop: Single;
begin
  LSide := GetDwmMaskedAccentVisualThickness;
  LTop := GetDwmMaskedAccentTopInset;
  Result := MakeRect(LSide, LTop, Max(Single(1), Single(ClientWidth - LSide - LSide)),
    Max(Single(1), Single(ClientHeight - LTop - LSide)));
end;

function TThemedModernForm.GetDwmMaskedAccentInnerRadius: Single;
var
  LThickness: Single;
  LBoost: Single;
begin
  LThickness := GetDwmMaskedAccentVisualThickness;
  LBoost := Max(Single(Scale(4)), LThickness * 1.75);
  Result := Max(Single(1), GetChromeCornerRadius + LBoost - 4);
end;

function TThemedModernForm.GetDwmMaskedAccentVisualThickness: Single;
var
  LThickness: Single;
begin
  LThickness := GetChromeBorderThickness;
  if LThickness <= 1 then
    Exit(1);
  if LThickness <= 2 then
    Exit(1.15);
  Result := Max(Single(1.65), LThickness - 1.15);
end;

function TThemedModernForm.GetDwmMaskedAccentTopInset: Single;
var
  LThickness: Single;
begin
  LThickness := GetChromeBorderThickness;
  if LThickness <= 1 then
    Exit(0.75);
  if LThickness <= 2 then
    Exit(0.5);
  Result := Max(Single(0.75), GetDwmMaskedAccentVisualThickness - 1);
end;

function TThemedModernForm.GetChromeOutlineBounds: TRect;
begin
  Result := Rect(0, 0, Max(1, ClientWidth), Max(1, ClientHeight));
end;

function TThemedModernForm.GetChromeBorderThickness: Integer;
begin
  Result := Max(1, FChromeStatusBorderThickness);
end;

function TThemedModernForm.IsNativeDwmRoundingActive: Boolean;
begin
  Result := FAllowCustomChrome and TThemedModernFormNative.SupportsDwmWindowAttributes and
    (not FClipWindowToChromeCorners) and (WindowState <> wsMaximized) and
    (FCornerMode <> TThemedModernFormCornerMode.Square);
end;

function TThemedModernForm.IsDwmMaskedAccentBorderActive: Boolean;
begin
  Result := IsNativeDwmRoundingActive and FDrawOuterBorder and FDrawRoundedChromeBorder and
    (FChromeStatusBorderThickness > 0);
end;

function TThemedModernForm.GetButtonRectangle(const AButton: TThemedModernFormWindowButton): TRect;
var
  LRight: Integer;
  LTop: Integer;
  LW: Integer;
  LH: Integer;
begin
  LRight := Width - GetRightChromeInset;
  LTop := GetChromeTopInset;
  LW := GetTitleBarButtonWidth;
  LH := GetTitleBarHeight;
  if FShowCloseButton then
  begin
    if AButton = TThemedModernFormWindowButton.Close then
      Exit(Rect(LRight - LW, LTop, LRight, LTop + LH));
    Dec(LRight, LW);
  end;
  if FShowMaximizeButton then
  begin
    if AButton = TThemedModernFormWindowButton.MaximizeRestore then
      Exit(Rect(LRight - LW, LTop, LRight, LTop + LH));
    Dec(LRight, LW);
  end;
  if FShowMinimizeButton then
    if AButton = TThemedModernFormWindowButton.Minimize then
      Exit(Rect(LRight - LW, LTop, LRight, LTop + LH));
  Result := Rect(0, 0, 0, 0);
end;

function TThemedModernForm.GetAllButtonsRectangle: TRect;
var
  LCount: Integer;
  LWidth: Integer;
  LLeft: Integer;
  LTop: Integer;
begin
  LCount := 0;
  if FShowMinimizeButton then
    Inc(LCount);
  if FShowMaximizeButton then
    Inc(LCount);
  if FShowCloseButton then
    Inc(LCount);
  if LCount = 0 then
    Exit(Rect(0, 0, 0, 0));
  LWidth := LCount * GetTitleBarButtonWidth;
  LLeft := Width - GetRightChromeInset - LWidth;
  LTop := GetChromeTopInset;
  Result := Rect(LLeft, LTop, LLeft + LWidth, LTop + GetTitleBarHeight);
end;

function TThemedModernForm.GetIconRectangle: TRect;
var
  LSize: Integer;
  LX: Integer;
  LY: Integer;
begin
  LSize := GetTitleBarIconSize;
  LX := GetTitleBarCaptionLeftPadding + GetLeftChromeInset;
  LY := GetChromeTopInset + (GetTitleBarHeight - LSize) div 2;
  Result := Rect(LX, LY, LX + LSize, LY + LSize);
end;

function TThemedModernForm.GetChromeTopInset: Integer;
begin
  if WindowState = wsMaximized then
    Exit(0);
  if IsDwmMaskedAccentBorderActive then
    Exit(GetChromeBorderThickness);
  Result := FMetrics.BorderThickness;
end;

function TThemedModernForm.GetRightChromeInset: Integer;
begin
  if (WindowState = wsMaximized) or (FCornerMode = TThemedModernFormCornerMode.Square) then
    Exit(0);
  if IsDwmMaskedAccentBorderActive then
    Exit(GetChromeBorderThickness);
  if IsNativeDwmRoundingActive then
    Exit(0);
  Result := GetChromeCornerRadius;
end;

function TThemedModernForm.GetLeftChromeInset: Integer;
begin
  Result := GetRightChromeInset;
end;

function TThemedModernForm.GetChromeCornerRadius: Integer;
begin
  if WindowState = wsMaximized then
    Exit(0);
  if FCornerMode = TThemedModernFormCornerMode.Square then
    Exit(0);
  if FCornerMode = TThemedModernFormCornerMode.RoundSmall then
    Exit(Scale(7));
  Result := Scale(9);
end;

function TThemedModernForm.HitTestButton(const APoint: TPoint): TThemedModernFormWindowButton;
begin
  if FShowCloseButton and PtInRect(GetButtonRectangle(TThemedModernFormWindowButton.Close), APoint) then
    Exit(TThemedModernFormWindowButton.Close);
  if FShowMaximizeButton and MaximizeBox and
    PtInRect(GetButtonRectangle(TThemedModernFormWindowButton.MaximizeRestore), APoint) then
    Exit(TThemedModernFormWindowButton.MaximizeRestore);
  if FShowMinimizeButton and MinimizeBox and
    PtInRect(GetButtonRectangle(TThemedModernFormWindowButton.Minimize), APoint) then
    Exit(TThemedModernFormWindowButton.Minimize);
  Result := TThemedModernFormWindowButton.None;
end;

function TThemedModernForm.IsPointInDraggableTitleBar(const APoint: TPoint): Boolean;
begin
  if not PtInRect(TitleBarBounds, APoint) then
    Exit(False);
  if HitTestButton(APoint) <> TThemedModernFormWindowButton.None then
    Exit(False);
  if IsPointOverTitleBarHostControl(APoint) then
    Exit(False);
  Result := True;
end;

function TThemedModernForm.IsLiveChild(const AControl: TControl): Boolean;
begin
  Result := (AControl <> nil) and (AControl <> FRemovingControl) and
    (not (csDestroying in AControl.ComponentState));
end;

function TThemedModernForm.CreateTitleBarPanel(const AName: string): TThemedModernFormHostPanel;
begin
  Result := TThemedModernFormHostPanel.Create(nil);
  Result.Name := AName;
  Result.Color := ThemeColorToColor(FPalette.TitleBarBackColor);
end;

procedure TThemedModernForm.ConfigureTitleBarHost(const AHost: TThemedModernFormHostPanel);
begin
  if AHost = nil then
    Exit;
  AHost.Visible := False;
  AHost.SetBounds(0, 0, 0, 0);
  AHost.OnControlListChange := TitleBarHostControlListChange;
  AHost.OnMouseDown := TitleBarHostMouseDown;
  AHost.OnDblClick := TitleBarHostDblClick;
end;

procedure TThemedModernForm.CreateTitleBarHosts;
begin
  FTitleBarOverlay := CreateTitleBarPanel(ThemedModernFormTexts.TitleBarOverlayName);
  FTitleBarOverlay.OnMouseDown := TitleBarOverlayMouseDown;
  FTitleBarOverlay.OnDblClick := TitleBarOverlayDblClick;
  FTitleBarLeftHost := CreateTitleBarPanel(ThemedModernFormTexts.TitleBarLeftHostName);
  FTitleBarCenterHost := CreateTitleBarPanel(ThemedModernFormTexts.TitleBarCenterHostName);
  FTitleBarRightHost := CreateTitleBarPanel(ThemedModernFormTexts.TitleBarRightHostName);
  ConfigureTitleBarHost(FTitleBarLeftHost);
  ConfigureTitleBarHost(FTitleBarCenterHost);
  ConfigureTitleBarHost(FTitleBarRightHost);
  FTitleBarCenterHost.Parent := FTitleBarOverlay;
  FTitleBarRightHost.Parent := FTitleBarOverlay;
  FTitleBarLeftHost.Parent := FTitleBarOverlay;
  FTitleBarOverlay.OnControlListChange := TitleBarOverlayControlListChange;
  FTitleBarOverlay.Visible := False;
  FTitleBarOverlay.Parent := Self;
  UpdateTitleBarHostsLayout;
end;

function TThemedModernForm.HasTitleBarHostContent(const AHost: TThemedModernFormHostPanel): Boolean;
var
  I: Integer;
begin
  Result := False;
  if (AHost = nil) or (csDestroying in AHost.ComponentState) then
    Exit;
  for I := 0 to AHost.ControlCount - 1 do
    if IsLiveChild(AHost.Controls[I]) then
      Exit(True);
end;

function TThemedModernForm.HasTitleBarOverlayContent: Boolean;
var
  I: Integer;
  LChild: TControl;
begin
  Result := False;
  if FTitleBarOverlay = nil then
    Exit;
  if HasTitleBarHostContent(FTitleBarLeftHost) or HasTitleBarHostContent(FTitleBarCenterHost) or
    HasTitleBarHostContent(FTitleBarRightHost) then
    Exit(True);
  for I := 0 to FTitleBarOverlay.ControlCount - 1 do
  begin
    LChild := FTitleBarOverlay.Controls[I];
    if (LChild = FTitleBarLeftHost) or (LChild = FTitleBarCenterHost) or (LChild = FTitleBarRightHost) then
      Continue;
    if IsLiveChild(LChild) then
      Exit(True);
  end;
end;

procedure TThemedModernForm.TitleBarOverlayControlListChange(const ASender: TObject; const AControl: TControl;
  const AInserting: Boolean);
begin
  if (FMetrics = nil) or (csDestroying in ComponentState) or (AControl = nil) then
    Exit;
  if (AControl = FTitleBarLeftHost) or (AControl = FTitleBarCenterHost) or (AControl = FTitleBarRightHost) then
    Exit;
  if AInserting then
  begin
    AttachTitleBarChild(AControl);
    if FApplyThemeToChildControls and (FThemePalette <> nil) then
      ApplyThemeToControl(AControl, FThemePalette);
    UpdateTitleBarHostsLayout;
  end
  else
  begin
    FRemovingControl := AControl;
    try
      DetachTitleBarChild(AControl);
      UpdateTitleBarHostsLayout;
    finally
      FRemovingControl := nil;
    end;
  end;
end;

procedure TThemedModernForm.TitleBarHostControlListChange(const ASender: TObject; const AControl: TControl;
  const AInserting: Boolean);
var
  LHost: TThemedModernFormHostPanel;
begin
  if (FMetrics = nil) or (csDestroying in ComponentState) or (AControl = nil) then
    Exit;
  LHost := ASender as TThemedModernFormHostPanel;
  if AInserting then
  begin
    AttachTitleBarChild(AControl);
    if FApplyThemeToChildControls and (FThemePalette <> nil) then
      ApplyThemeToControl(AControl, FThemePalette);
    LHost.Visible := True;
    UpdateTitleBarHostsLayout;
  end
  else
  begin
    FRemovingControl := AControl;
    try
      DetachTitleBarChild(AControl);
      if not HasTitleBarHostContent(LHost) then
        LHost.Visible := False;
      UpdateTitleBarHostsLayout;
    finally
      FRemovingControl := nil;
    end;
  end;
end;

procedure TThemedModernForm.AttachTitleBarChild(const AControl: TControl);
begin
  AttachHook(AControl);
end;

procedure TThemedModernForm.DetachTitleBarChild(const AControl: TControl);
begin
  DetachHook(AControl);
end;

procedure TThemedModernForm.AttachHook(const AControl: TControl);
var
  LHook: TThemedModernFormChildHook;
  I: Integer;
begin
  if (AControl = nil) or (csDestroying in AControl.ComponentState) then
    Exit;
  if not FHooks.ContainsKey(AControl) then
  begin
    LHook := TThemedModernFormChildHook.Create(Self, AControl);
    FHooks.Add(AControl, LHook);
    FHookStore.Add(LHook);
  end;
  if AControl is TWinControl then
    for I := 0 to TWinControl(AControl).ControlCount - 1 do
      AttachHook(TWinControl(AControl).Controls[I]);
end;

procedure TThemedModernForm.DetachHook(const AControl: TControl);
var
  LHook: TThemedModernFormChildHook;
  I: Integer;
begin
  if AControl = nil then
    Exit;
  if AControl is TWinControl then
    for I := 0 to TWinControl(AControl).ControlCount - 1 do
      DetachHook(TWinControl(AControl).Controls[I]);
  FHitTestModes.Remove(AControl);
  if FHooks.TryGetValue(AControl, LHook) then
  begin
    FHooks.Remove(AControl);
    if LHook.Release then
      FHookStore.Remove(LHook);
  end;
end;

procedure TThemedModernForm.ForgetHook(const AControl: TControl);
begin
  if FHooks <> nil then
    FHooks.Remove(AControl);
  if FHitTestModes <> nil then
    FHitTestModes.Remove(AControl);
end;

procedure TThemedModernForm.ChildMessage(const AControl: TControl; var AMessage: TMessage);
var
  LControl: TControl;
begin
  if (FMetrics = nil) or (csDestroying in ComponentState) then
    Exit;
  case AMessage.Msg of
    WM_WINDOWPOSCHANGED, CM_VISIBLECHANGED:
      UpdateTitleBarHostsLayout;
    CM_CONTROLLISTCHANGE:
      begin
        LControl := TControl(AMessage.WParam);
        if AMessage.LParam <> 0 then
          AttachHook(LControl)
        else
        begin
          FRemovingControl := LControl;
          try
            DetachHook(LControl);
          finally
            FRemovingControl := nil;
          end;
        end;
      end;
    WM_LBUTTONDOWN:
      if FAllowCustomChrome and FAllowDragMove and
        (ResolveTitleBarHitTestMode(AControl) = TThemedModernFormTitleBarHitTestMode.Caption) then
        BeginWindowMove;
    WM_LBUTTONDBLCLK:
      if FAllowCustomChrome and FShowMaximizeButton and MaximizeBox and
        (ResolveTitleBarHitTestMode(AControl) = TThemedModernFormTitleBarHitTestMode.Caption) then
        ToggleMaximizeRestore;
  end;
end;

procedure TThemedModernForm.RefreshTitleBarHosts;
begin
  if FTitleBarOverlay = nil then
    Exit;
  UpdateTitleBarHostsLayout;
  FTitleBarOverlay.BringToFront;
  InvalidateTitleBar;
end;

procedure TThemedModernForm.UpdateTitleBarHostsLayout;
var
  LTop: Integer;
  LHeight: Integer;
  LButtonsLeft: Integer;
  LIconRight: Integer;
  LLeft: Integer;
  LRight: Integer;
  LWidth: Integer;
  LHasContent: Boolean;
begin
  if (FTitleBarOverlay = nil) or FUpdatingTitleBarHostsLayout or (csDestroying in ComponentState) then
    Exit;
  FUpdatingTitleBarHostsLayout := True;
  try
    LTop := GetChromeTopInset + GetTitleBarOverlayTopPadding;
    LHeight := Max(1, GetTitleBarHeight - GetTitleBarOverlayVerticalPadding);
    LButtonsLeft := GetAllButtonsRectangle.Left;
    if LButtonsLeft <= 0 then
      LButtonsLeft := Width;
    if HasChromeIcon then
      LIconRight := GetIconRectangle.Right + GetTitleBarCaptionLeftPadding
    else
      LIconRight := GetTitleBarCaptionLeftPadding + GetLeftChromeInset;
    LLeft := LIconRight + GetTitleBarOverlayHorizontalGap;
    LRight := LButtonsLeft - GetTitleBarOverlayHorizontalGap;
    LWidth := Max(0, LRight - LLeft);
    LHasContent := HasTitleBarOverlayContent;
    FTitleBarOverlay.SetBounds(LLeft, LTop, LWidth, LHeight);
    FTitleBarOverlay.Visible := (LWidth > 0) and (LHeight > 0) and LHasContent;
    FTitleBarOverlay.Color := ThemeColorToColor(FPalette.TitleBarBackColor);
    UpdateTitleBarHostPanelsLayout;
    if FTitleBarOverlay.Visible then
      FTitleBarOverlay.BringToFront;
  finally
    FUpdatingTitleBarHostsLayout := False;
  end;
end;

function TThemedModernForm.GetTitleBarHostPreferredWidth(const AHost: TThemedModernFormHostPanel): Integer;
var
  I: Integer;
  LChild: TControl;
begin
  if AHost = nil then
    Exit(0);
  Result := 0;
  for I := 0 to AHost.ControlCount - 1 do
  begin
    LChild := AHost.Controls[I];
    if (not IsLiveChild(LChild)) or (not LChild.Visible) then
      Continue;
    Result := Max(Result, LChild.Left + LChild.Width + LChild.Margins.Right);
  end;
  if Result <= 0 then
    Result := AHost.Width;
  if (Result <= 0) and (AHost.Constraints.MinWidth > 0) then
    Result := AHost.Constraints.MinWidth;
  Result := Max(0, Min(Result, Max(0, FTitleBarOverlay.ClientWidth)));
end;

procedure TThemedModernForm.UpdateTitleBarHostPanelsLayout;
var
  LWidth: Integer;
  LHeight: Integer;
  LGap: Integer;
  LLeftWidth: Integer;
  LRightWidth: Integer;
  LTotalGap: Integer;
  LAvailable: Integer;
  LCenterX: Integer;
  LRightX: Integer;
  LCenterWidth: Integer;
begin
  if (FTitleBarOverlay = nil) or (FTitleBarLeftHost = nil) or (FTitleBarCenterHost = nil) or
    (FTitleBarRightHost = nil) then
    Exit;
  LWidth := Max(0, FTitleBarOverlay.ClientWidth);
  LHeight := Max(0, FTitleBarOverlay.ClientHeight);
  LGap := GetTitleBarOverlayHorizontalGap;
  LLeftWidth := 0;
  LRightWidth := 0;
  if FTitleBarLeftHost.Visible then
    LLeftWidth := GetTitleBarHostPreferredWidth(FTitleBarLeftHost);
  if FTitleBarRightHost.Visible then
    LRightWidth := GetTitleBarHostPreferredWidth(FTitleBarRightHost);
  LTotalGap := 0;
  if FTitleBarLeftHost.Visible and (FTitleBarCenterHost.Visible or FTitleBarRightHost.Visible) then
    Inc(LTotalGap, LGap);
  if FTitleBarRightHost.Visible and (FTitleBarCenterHost.Visible or FTitleBarLeftHost.Visible) then
    Inc(LTotalGap, LGap);
  LAvailable := Max(0, LWidth - LTotalGap);
  LLeftWidth := Min(LLeftWidth, LAvailable);
  Dec(LAvailable, LLeftWidth);
  LRightWidth := Min(LRightWidth, LAvailable);
  LCenterX := LLeftWidth;
  if FTitleBarLeftHost.Visible and (FTitleBarCenterHost.Visible or FTitleBarRightHost.Visible) then
    Inc(LCenterX, LGap);
  LRightX := LWidth - LRightWidth;
  if FTitleBarRightHost.Visible and (FTitleBarCenterHost.Visible or FTitleBarLeftHost.Visible) then
    Dec(LRightX, LGap);
  LCenterWidth := Max(0, LRightX - LCenterX);
  FTitleBarLeftHost.SetBounds(0, 0, LLeftWidth, LHeight);
  FTitleBarCenterHost.SetBounds(LCenterX, 0, LCenterWidth, LHeight);
  FTitleBarRightHost.SetBounds(LWidth - LRightWidth, 0, LRightWidth, LHeight);
end;

procedure TThemedModernForm.TitleBarOverlayMouseDown(ASender: TObject; AButton: TMouseButton;
  AShift: TShiftState; AX, AY: Integer);
begin
  if (not FAllowCustomChrome) or (AButton <> mbLeft) or (ssDouble in AShift) then
    Exit;
  if IsPointOverOverlayChild(Point(AX, AY)) then
    Exit;
  HandleTitleBarBackgroundMouseDown;
end;

procedure TThemedModernForm.TitleBarOverlayDblClick(ASender: TObject);
var
  LPoint: TPoint;
begin
  if not FAllowCustomChrome then
    Exit;
  LPoint := FTitleBarOverlay.ScreenToClient(Mouse.CursorPos);
  if IsPointOverOverlayChild(LPoint) then
    Exit;
  if FShowMaximizeButton and MaximizeBox then
    ToggleMaximizeRestore;
end;

procedure TThemedModernForm.TitleBarHostMouseDown(ASender: TObject; AButton: TMouseButton;
  AShift: TShiftState; AX, AY: Integer);
begin
  if (not FAllowCustomChrome) or (AButton <> mbLeft) or (ssDouble in AShift) then
    Exit;
  if IsPointOverHostedControl(ASender as TWinControl, Point(AX, AY)) then
    Exit;
  HandleTitleBarBackgroundMouseDown;
end;

procedure TThemedModernForm.TitleBarHostDblClick(ASender: TObject);
var
  LHost: TWinControl;
begin
  if not FAllowCustomChrome then
    Exit;
  LHost := ASender as TWinControl;
  if IsPointOverHostedControl(LHost, LHost.ScreenToClient(Mouse.CursorPos)) then
    Exit;
  if FShowMaximizeButton and MaximizeBox then
    ToggleMaximizeRestore;
end;

procedure TThemedModernForm.HandleTitleBarBackgroundMouseDown;
begin
  if FAllowDragMove then
    BeginWindowMove;
end;

function TThemedModernForm.IsPointOverTitleBarHostControl(const APoint: TPoint): Boolean;
var
  LOverlayPoint: TPoint;
begin
  Result := False;
  if (FTitleBarOverlay = nil) or (not FTitleBarOverlay.Visible) then
    Exit;
  LOverlayPoint := Point(APoint.X - FTitleBarOverlay.Left, APoint.Y - FTitleBarOverlay.Top);
  if not PtInRect(FTitleBarOverlay.ClientRect, LOverlayPoint) then
    Exit;
  Result := IsPointOverOverlayChild(LOverlayPoint);
end;

function TThemedModernForm.IsPointOverOverlayChild(const AOverlayPoint: TPoint): Boolean;
var
  I: Integer;
  LChild: TControl;
  LChildPoint: TPoint;
begin
  Result := False;
  if (FTitleBarOverlay = nil) or (FTitleBarOverlay.ControlCount = 0) then
    Exit;
  for I := FTitleBarOverlay.ControlCount - 1 downto 0 do
  begin
    LChild := FTitleBarOverlay.Controls[I];
    if (not IsLiveChild(LChild)) or (not LChild.Visible) or (not LChild.Enabled) or
      (not PtInRect(LChild.BoundsRect, AOverlayPoint)) then
      Continue;
    LChildPoint := Point(AOverlayPoint.X - LChild.Left, AOverlayPoint.Y - LChild.Top);
    if (LChild = FTitleBarLeftHost) or (LChild = FTitleBarCenterHost) or (LChild = FTitleBarRightHost) then
    begin
      if IsPointOverHostedControl(TWinControl(LChild), LChildPoint) then
        Exit(True);
      Continue;
    end;
    Exit(IsPointOverTitleBarClientControl(LChild, LChildPoint));
  end;
end;

function TThemedModernForm.IsPointOverHostedControl(const AHost: TWinControl; const AHostPoint: TPoint): Boolean;
var
  I: Integer;
  LChild: TControl;
begin
  Result := False;
  if (AHost = nil) or (AHost.ControlCount = 0) then
    Exit;
  for I := AHost.ControlCount - 1 downto 0 do
  begin
    LChild := AHost.Controls[I];
    if (not IsLiveChild(LChild)) or (not LChild.Visible) or (not LChild.Enabled) or
      (not PtInRect(LChild.BoundsRect, AHostPoint)) then
      Continue;
    Exit(IsPointOverTitleBarClientControl(LChild, Point(AHostPoint.X - LChild.Left, AHostPoint.Y - LChild.Top)));
  end;
end;

function TThemedModernForm.IsPointOverTitleBarClientControl(const AControl: TControl;
  const AControlPoint: TPoint): Boolean;
var
  LHit: TControl;
begin
  LHit := GetDeepestTitleBarControlAtPoint(AControl, AControlPoint);
  if LHit = nil then
    LHit := AControl;
  Result := ResolveTitleBarHitTestMode(LHit) = TThemedModernFormTitleBarHitTestMode.Client;
end;

function TThemedModernForm.GetDeepestTitleBarControlAtPoint(const AParent: TControl; const APoint: TPoint): TControl;
var
  I: Integer;
  LChild: TControl;
  LNested: TControl;
begin
  Result := nil;
  if (AParent = nil) or (not (AParent is TWinControl)) or (TWinControl(AParent).ControlCount = 0) then
    Exit;
  for I := TWinControl(AParent).ControlCount - 1 downto 0 do
  begin
    LChild := TWinControl(AParent).Controls[I];
    if (not IsLiveChild(LChild)) or (not LChild.Visible) or (not LChild.Enabled) or
      (not PtInRect(LChild.BoundsRect, APoint)) then
      Continue;
    LNested := GetDeepestTitleBarControlAtPoint(LChild, Point(APoint.X - LChild.Left, APoint.Y - LChild.Top));
    if LNested <> nil then
      Exit(LNested);
    Exit(LChild);
  end;
end;

function TThemedModernForm.ResolveTitleBarHitTestMode(const AControl: TControl): TThemedModernFormTitleBarHitTestMode;
var
  LCurrent: TControl;
  LMode: TThemedModernFormTitleBarHitTestMode;
  LAuto: IThemedModernFormTitleBarHitTestAutoProvider;
begin
  if AControl = nil then
    Exit(TThemedModernFormTitleBarHitTestMode.Client);
  LCurrent := AControl;
  while (LCurrent <> nil) and (LCurrent <> FTitleBarOverlay) do
  begin
    if TryGetExplicitTitleBarHitTestMode(LCurrent, LMode) then
      Exit(LMode);
    LCurrent := LCurrent.Parent;
  end;
  if Supports(AControl, IThemedModernFormTitleBarHitTestAutoProvider, LAuto) then
  begin
    LMode := LAuto.GetAutoTitleBarHitTestMode;
    if (LMode = TThemedModernFormTitleBarHitTestMode.Caption) or
      (LMode = TThemedModernFormTitleBarHitTestMode.Client) then
      Exit(LMode);
  end;
  if AControl is TCustomLabel then
    Exit(TThemedModernFormTitleBarHitTestMode.Caption);
  Result := TThemedModernFormTitleBarHitTestMode.Client;
end;

function TThemedModernForm.TryGetExplicitTitleBarHitTestMode(const AControl: TControl;
  out AMode: TThemedModernFormTitleBarHitTestMode): Boolean;
var
  LProvider: IThemedModernFormTitleBarHitTest;
begin
  if FHitTestModes.TryGetValue(AControl, AMode) then
    Exit((AMode = TThemedModernFormTitleBarHitTestMode.Caption) or
      (AMode = TThemedModernFormTitleBarHitTestMode.Client));
  if Supports(AControl, IThemedModernFormTitleBarHitTest, LProvider) then
  begin
    AMode := LProvider.GetTitleBarHitTestMode;
    if (AMode = TThemedModernFormTitleBarHitTestMode.Caption) or
      (AMode = TThemedModernFormTitleBarHitTestMode.Client) then
      Exit(True);
  end;
  AMode := TThemedModernFormTitleBarHitTestMode.Auto;
  Result := False;
end;

procedure TThemedModernForm.EnsureDpiMetricsCurrent;
var
  LDpi: Integer;
begin
  if not HandleAllocated then
    Exit;
  LDpi := GetWindowDpiSafe;
  if LDpi <> FCurrentDpi then
    UpdateDpiMetrics(LDpi, True);
end;

function TThemedModernForm.GetWindowDpiSafe: Integer;
var
  LDpi: Integer;
  LDC: HDC;
begin
  if HandleAllocated and TThemedModernFormNative.TryGetWindowDpi(Handle, LDpi) and (LDpi > 0) then
    Exit(LDpi);
  if HandleAllocated then
  begin
    LDC := GetDC(Handle);
    if LDC <> 0 then
      try
        LDpi := GetDeviceCaps(LDC, LOGPIXELSX);
        if LDpi > 0 then
          Exit(Max(LogicalDpi, LDpi));
      finally
        ReleaseDC(Handle, LDC);
      end;
  end;
  if FCurrentDpi > 0 then
    Result := FCurrentDpi
  else
    Result := LogicalDpi;
end;

procedure TThemedModernForm.UpdateDpiMetrics(ADpi: Integer; const AForceLayout: Boolean);
var
  LOldDpi: Integer;
  LChanged: Boolean;
  LScaled: TThemedModernFormChromeMetrics;
  LFactor: Single;
begin
  if ADpi <= 0 then
    ADpi := LogicalDpi;
  if FCurrentDpi > 0 then
    LOldDpi := FCurrentDpi
  else
    LOldDpi := LogicalDpi;
  LChanged := LOldDpi <> ADpi;
  if (not LChanged) and (not AForceLayout) then
    Exit;
  if LChanged then
  begin
    LScaled := FMetrics.ScaleForDpi(LOldDpi, ADpi);
    FMetrics.Free;
    FMetrics := LScaled;
    if FChromeStatusBorderThickness > 0 then
    begin
      LFactor := ADpi / LOldDpi;
      FChromeStatusBorderThickness := Max(1, RoundAwayFromZero(FChromeStatusBorderThickness * LFactor));
    end;
    FCurrentDpi := ADpi;
  end;
  UpdatePadding;
  UpdateTitleBarHostsLayout;
  UpdateChromeRegion;
  NotifyChromeAccessibilityChanged;
  DoChromeDpiChanged;
  InvalidateAll;
end;

procedure TThemedModernForm.DoChromeDpiChanged;
begin
  if Assigned(FOnChromeDpiChanged) then
    FOnChromeDpiChanged(Self);
end;

procedure TThemedModernForm.NotifyChromeAccessibilityChanged;
begin
  if (not HandleAllocated) or (csDestroying in ComponentState) then
    Exit;
  TThemedModernFormAccessibility.NotifyStructureChanged(Handle);
end;

procedure TThemedModernForm.NotifyChromeAccessibilityNameChanged;
begin
  if (not HandleAllocated) or (csDestroying in ComponentState) then
    Exit;
  TThemedModernFormAccessibility.NotifyNameChanged(Handle);
end;

procedure TThemedModernForm.NormalizeChromeMetrics;
begin
  if FMetrics = nil then
  begin
    FMetrics := TThemedModernFormChromeMetrics.CreateDefault(GetScaleFactorSafe);
    Exit;
  end;
  FMetrics.BorderThickness := Max(1, FMetrics.BorderThickness);
  FMetrics.ResizeGripSize := Max(1, FMetrics.ResizeGripSize);
  FMetrics.TitleBarHeight := Max(1, FMetrics.TitleBarHeight);
  FMetrics.ButtonWidth := Max(1, FMetrics.ButtonWidth);
  FMetrics.IconSize := Max(1, FMetrics.IconSize);
  FMetrics.CaptionLeftPadding := Max(0, FMetrics.CaptionLeftPadding);
  FMetrics.CaptionRightPadding := Max(0, FMetrics.CaptionRightPadding);
  FMetrics.CaptionTopPadding := Max(0, FMetrics.CaptionTopPadding);
end;

procedure TThemedModernForm.UpdatePadding;
var
  LBorder: Integer;
begin
  if FMetrics = nil then
    Exit;
  if not FAllowCustomChrome then
  begin
    Padding.SetBounds(0, 0, 0, 0);
    Exit;
  end;
  if WindowState = wsMaximized then
  begin
    Padding.SetBounds(0, GetTitleBarHeight, 0, 0);
    Exit;
  end;
  LBorder := FMetrics.BorderThickness;
  if FDrawOuterBorder and (FChromeStatusBorderThickness > 0) then
    LBorder := Max(LBorder, FChromeStatusBorderThickness);
  Padding.SetBounds(LBorder, GetTitleBarHeight + LBorder, LBorder, LBorder);
end;

function TThemedModernForm.GetTitleBarHeight: Integer;
begin
  if FTitleBarMode = TThemedModernFormTitleBarMode.Compact then
    Exit(Max(Scale(24), FMetrics.TitleBarHeight - Scale(14)));
  if FTitleBarMode = TThemedModernFormTitleBarMode.Spacious then
    Exit(FMetrics.TitleBarHeight + Scale(8));
  Result := FMetrics.TitleBarHeight;
end;

function TThemedModernForm.GetTitleBarButtonWidth: Integer;
begin
  if FTitleBarMode = TThemedModernFormTitleBarMode.Compact then
    Exit(Max(Scale(34), FMetrics.ButtonWidth - Scale(12)));
  if FTitleBarMode = TThemedModernFormTitleBarMode.Spacious then
    Exit(FMetrics.ButtonWidth + Scale(6));
  Result := FMetrics.ButtonWidth;
end;

function TThemedModernForm.GetTitleBarIconSize: Integer;
begin
  if FTitleBarMode = TThemedModernFormTitleBarMode.Compact then
    Exit(Max(Scale(12), Min(FMetrics.IconSize - Scale(4), GetTitleBarHeight - Scale(8))));
  if FTitleBarMode = TThemedModernFormTitleBarMode.Spacious then
    Exit(Min(FMetrics.IconSize + Scale(2), GetTitleBarHeight - Scale(10)));
  Result := Min(FMetrics.IconSize, GetTitleBarHeight - Scale(8));
end;

function TThemedModernForm.GetTitleBarCaptionLeftPadding: Integer;
begin
  if FTitleBarMode = TThemedModernFormTitleBarMode.Compact then
    Exit(Max(Scale(8), FMetrics.CaptionLeftPadding - Scale(4)));
  if FTitleBarMode = TThemedModernFormTitleBarMode.Spacious then
    Exit(FMetrics.CaptionLeftPadding + Scale(4));
  Result := FMetrics.CaptionLeftPadding;
end;

function TThemedModernForm.GetTitleBarCaptionRightPadding: Integer;
begin
  if FTitleBarMode = TThemedModernFormTitleBarMode.Compact then
    Exit(Max(Scale(6), FMetrics.CaptionRightPadding - Scale(4)));
  if FTitleBarMode = TThemedModernFormTitleBarMode.Spacious then
    Exit(FMetrics.CaptionRightPadding + Scale(4));
  Result := FMetrics.CaptionRightPadding;
end;

function TThemedModernForm.GetTitleBarOverlayTopPadding: Integer;
begin
  if FTitleBarMode = TThemedModernFormTitleBarMode.Compact then
    Exit(Scale(1));
  if FTitleBarMode = TThemedModernFormTitleBarMode.Spacious then
    Exit(Scale(5));
  Result := Scale(3);
end;

function TThemedModernForm.GetTitleBarOverlayVerticalPadding: Integer;
begin
  if FTitleBarMode = TThemedModernFormTitleBarMode.Compact then
    Exit(Scale(3));
  if FTitleBarMode = TThemedModernFormTitleBarMode.Spacious then
    Exit(Scale(8));
  Result := Scale(6);
end;

function TThemedModernForm.GetTitleBarOverlayHorizontalGap: Integer;
begin
  if FTitleBarMode = TThemedModernFormTitleBarMode.Compact then
    Exit(Scale(6));
  if FTitleBarMode = TThemedModernFormTitleBarMode.Spacious then
    Exit(Scale(10));
  Result := Scale(8);
end;

function TThemedModernForm.GetAccessibleContentControlCount: Integer;
var
  I: Integer;
  LControl: TControl;
begin
  Result := 0;
  for I := 0 to ControlCount - 1 do
  begin
    LControl := Controls[I];
    if not (LControl is TWinControl) then
      Continue;
    if (LControl = FTitleBarOverlay) and (not HasTitleBarOverlayContent) then
      Continue;
    Inc(Result);
  end;
end;

function TThemedModernForm.GetAccessibleContentControlAt(const AIndex: Integer): TWinControl;
var
  I: Integer;
  LCurrent: Integer;
  LControl: TControl;
begin
  Result := nil;
  if AIndex < 0 then
    Exit;
  LCurrent := 0;
  for I := 0 to ControlCount - 1 do
  begin
    LControl := Controls[I];
    if not (LControl is TWinControl) then
      Continue;
    if (LControl = FTitleBarOverlay) and (not HasTitleBarOverlayContent) then
      Continue;
    if LCurrent = AIndex then
      Exit(TWinControl(LControl));
    Inc(LCurrent);
  end;
end;

function TThemedModernForm.IsWindowButtonVisible(const AButton: TThemedModernFormWindowButton): Boolean;
begin
  case AButton of
    TThemedModernFormWindowButton.Minimize: Result := FShowMinimizeButton;
    TThemedModernFormWindowButton.MaximizeRestore: Result := FShowMaximizeButton;
    TThemedModernFormWindowButton.Close: Result := FShowCloseButton;
  else
    Result := False;
  end;
end;

function TThemedModernForm.IsWindowButtonAvailable(const AButton: TThemedModernFormWindowButton): Boolean;
begin
  if not IsWindowButtonVisible(AButton) then
    Exit(False);
  case AButton of
    TThemedModernFormWindowButton.Minimize: Result := MinimizeBox;
    TThemedModernFormWindowButton.MaximizeRestore: Result := MaximizeBox;
  else
    Result := AButton = TThemedModernFormWindowButton.Close;
  end;
end;

function TThemedModernForm.IsSystemMenuAccessibleVisible: Boolean;
begin
  Result := FAllowCustomChrome and HasChromeIcon;
end;

end.

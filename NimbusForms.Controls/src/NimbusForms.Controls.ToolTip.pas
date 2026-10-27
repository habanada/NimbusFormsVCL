{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.ToolTip;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.Generics.Collections,
  Vcl.Controls,
  Vcl.Graphics,
  NimbusForms.Controls.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Canvas,
  NimbusForms.Rendering.ToolTip;

type
  TThemedToolTip = class;

  TThemedToolTipInfo = class
  private
    FOwner: TThemedToolTip;
    FControl: TControl;
    FOldWindowProc: TWndMethod;
    FOriginalHint: string;
    FOriginalShowHint: Boolean;
    FOriginalParentShowHint: Boolean;
    FOriginalCustomHint: TCustomHint;
    FBoundHint: string;
    FAttached: Boolean;
    FTitle: string;
    FDescription: string;
    FToolTipText: string;
    FIcon: TThemedToolTipIcon;
    FImage: Vcl.Graphics.TBitmap;
    FUseMarkup: Boolean;
    FUseGlobalMarkup: Boolean;
    procedure WindowProc(var Message: TMessage);
    function HasContent: Boolean;
  public
    constructor Create(AOwner: TThemedToolTip; AControl: TControl);
    destructor Destroy; override;
    procedure UpdateBinding;
    procedure ReleaseControl(const AControlDestroying: Boolean);
    property Control: TControl read FControl;
    property Title: string read FTitle write FTitle;
    property Description: string read FDescription write FDescription;
    property ToolTipText: string read FToolTipText write FToolTipText;
    property Icon: TThemedToolTipIcon read FIcon write FIcon;
    property Image: Vcl.Graphics.TBitmap read FImage;
    property UseMarkup: Boolean read FUseMarkup write FUseMarkup;
    property UseGlobalMarkup: Boolean read FUseGlobalMarkup write FUseGlobalMarkup;
  end;

  TThemedToolTipWindowLayout = class
  public
    WindowHandle: HWND;
    Layout: TThemedToolTipLayout;
    destructor Destroy; override;
  end;

  TThemedToolTip = class(TCustomHint, IThemeAware)
  private
    FInfos: TObjectList<TThemedToolTipInfo>;
    FPalette: TThemePalette;
    FRenderCanvas: INimbusRenderCanvas;
    FRenderer: TThemedToolTipRenderer;
    FWindowLayouts: TObjectList<TThemedToolTipWindowLayout>;
    FFont: TFont;
    FCurrentControl: TControl;
    FAnchorBounds: TRect;
    FHasAnchorBounds: Boolean;
    FTransientText: string;
    FUseTransientText: Boolean;
    FThemeRegistered: Boolean;
    FUseMarkup: Boolean;
    FShowBorder: Boolean;
    FShowTitleSeparator: Boolean;
    FRoundedCorners: Boolean;
    FShowAlways: Boolean;
    FPaddingSize: Integer;
    FMaxWidth: Integer;
    FCornerRadius: Integer;
    FInitialDelay: Cardinal;
    FReshowDelay: Cardinal;
    FAutoPopDelay: Integer;
    FLastLeaveTick: Cardinal;
    FDpiInitialized: Boolean;
    FDpiPPI: Integer;
    FMetrics: TThemedToolTipMetrics;
    function FindInfo(AControl: TControl): TThemedToolTipInfo;
    function FindWindowLayout(const AHandle: HWND): TThemedToolTipLayout;
    procedure SetWindowLayout(const AHandle: HWND; ALayout: TThemedToolTipLayout);
    procedure CleanupWindowLayouts;
    function GetInfo(AControl: TControl; const ACreate: Boolean = True): TThemedToolTipInfo;
    procedure RegisterThemeAware;
    procedure FontChanged(Sender: TObject);
    procedure SetFont(const AValue: TFont);
    procedure SetGlobalUseMarkup(const AValue: Boolean);
    procedure SetShowBorder(const AValue: Boolean);
    procedure SetShowTitleSeparator(const AValue: Boolean);
    procedure SetRoundedCorners(const AValue: Boolean);
    procedure SetPaddingSize(const AValue: Integer);
    procedure SetMaxWidth(const AValue: Integer);
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetInitialDelay(const AValue: Cardinal);
    procedure SetReshowDelay(const AValue: Cardinal);
    procedure SetAutoPopDelay(const AValue: Integer);
    function GetRenderPPI: Integer;
    procedure ApplyDpiScaling;
    procedure ControlMouseEnter(AControl: TControl);
    procedure ControlMouseLeave(AControl: TControl);
    function CanShowNow: Boolean;
    function BuildContent: TThemedToolTipContent;
    procedure ApplyHintRegion(AHintWindow: TCustomHintWindow);
    procedure PositionHintWindow(AHintWindow: TCustomHintWindow);
  protected
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    procedure PaintHint(HintWindow: TCustomHintWindow); override;
    procedure SetHintSize(HintWindow: TCustomHintWindow); override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette); virtual;
    procedure SetToolTip(AControl: TControl; const AText: string); overload;
    procedure SetToolTip(AControl: TControl; const ATitle, ADescription: string; const AIcon: TThemedToolTipIcon); overload;
    function GetToolTip(AControl: TControl): string;
    procedure SetTitle(AControl: TControl; const ATitle: string);
    function GetTitle(AControl: TControl): string;
    procedure SetDescription(AControl: TControl; const ADescription: string);
    function GetDescription(AControl: TControl): string;
    procedure SetIcon(AControl: TControl; const AIcon: TThemedToolTipIcon);
    function GetIcon(AControl: TControl): TThemedToolTipIcon;
    procedure SetUseMarkup(AControl: TControl; const AUseMarkup: Boolean); overload;
    function GetUseMarkup(AControl: TControl): Boolean;
    procedure ResetUseMarkup(AControl: TControl);
    procedure SetImage(AControl: TControl; AImage: TGraphic);
    function GetImage(AControl: TControl): TGraphic;
    procedure ClearInfo(AControl: TControl);
    procedure ShowForControl(AControl: TControl); overload;
    procedure ShowForControl(AControl: TControl; const AClientAnchorBounds: TRect); overload;
    procedure ShowTextForControl(AControl: TControl; const AText: string; const AClientAnchorBounds: TRect);
  published
    property Font: TFont read FFont write SetFont;
    property UseMarkup: Boolean read FUseMarkup write SetGlobalUseMarkup default True;
    property ShowBorder: Boolean read FShowBorder write SetShowBorder default True;
    property ShowTitleSeparator: Boolean read FShowTitleSeparator write SetShowTitleSeparator default False;
    property RoundedCorners: Boolean read FRoundedCorners write SetRoundedCorners default True;
    property PaddingSize: Integer read FPaddingSize write SetPaddingSize default 8;
    property MaxWidth: Integer read FMaxWidth write SetMaxWidth default 400;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 4;
    property InitialDelay: Cardinal read FInitialDelay write SetInitialDelay default 500;
    property ReshowDelay: Cardinal read FReshowDelay write SetReshowDelay default 100;
    property AutoPopDelay: Integer read FAutoPopDelay write SetAutoPopDelay default 8000;
    property ShowAlways: Boolean read FShowAlways write FShowAlways default True;
    property Position;
  end;

implementation

uses
  System.Math,
  System.Types,
  Vcl.Forms,
  NimbusForms.Theming.Manager;

type
  TControlAccess = class(TControl);
  TCustomHintWindowAccess = class(TCustomHintWindow);

destructor TThemedToolTipWindowLayout.Destroy;
begin
  Layout.Free;
  inherited Destroy;
end;

constructor TThemedToolTipInfo.Create(AOwner: TThemedToolTip; AControl: TControl);
begin
  inherited Create;
  FOwner := AOwner;
  FControl := AControl;
  FIcon := ttiNone;
  FUseMarkup := True;
  FUseGlobalMarkup := True;
  FImage := Vcl.Graphics.TBitmap.Create;
end;

destructor TThemedToolTipInfo.Destroy;
begin
  ReleaseControl(False);
  FImage.Free;
  inherited Destroy;
end;

function TThemedToolTipInfo.HasContent: Boolean;
begin
  Result := (FTitle <> '') or (FDescription <> '') or (FToolTipText <> '');
end;


procedure TThemedToolTipInfo.UpdateBinding;
begin
  if FControl = nil then Exit;
  if not HasContent then
  begin
    if FAttached then ReleaseControl(False);
    Exit;
  end;
  if not FAttached then
  begin
    FOldWindowProc := FControl.WindowProc;
    FOriginalHint := FControl.Hint;
    FOriginalShowHint := FControl.ShowHint;
    FOriginalParentShowHint := TControlAccess(FControl).ParentShowHint;
    FOriginalCustomHint := FControl.CustomHint;
    FControl.FreeNotification(FOwner);
    FControl.WindowProc := WindowProc;
    FAttached := True;
  end;
  FBoundHint := #1;
  FControl.CustomHint := FOwner;
  FControl.ShowHint := True;
  FControl.Hint := FBoundHint;
end;

procedure TThemedToolTipInfo.ReleaseControl(const AControlDestroying: Boolean);
var
  LCurrent, LHook: TWndMethod;
begin
  if (FControl = nil) or not FAttached then
  begin
    if AControlDestroying then FControl := nil;
    Exit;
  end;
  LCurrent := FControl.WindowProc;
  LHook := WindowProc;
  if (TMethod(LCurrent).Code = TMethod(LHook).Code) and (TMethod(LCurrent).Data = TMethod(LHook).Data) then FControl.WindowProc := FOldWindowProc;
  if not AControlDestroying then
  begin
    if FControl.CustomHint = FOwner then FControl.CustomHint := FOriginalCustomHint;
    if FControl.Hint = FBoundHint then FControl.Hint := FOriginalHint;
    FControl.ShowHint := FOriginalShowHint;
    TControlAccess(FControl).ParentShowHint := FOriginalParentShowHint;
    FControl.RemoveFreeNotification(FOwner);
  end;
  FAttached := False;
  if AControlDestroying then FControl := nil;
end;

procedure TThemedToolTipInfo.WindowProc(var Message: TMessage);
var
  LShowHint, LParentShowHint: Boolean;
begin
  if FControl = nil then Exit;
  case Message.Msg of
    CM_MOUSEENTER:
      begin
        FOwner.ControlMouseEnter(FControl);
        if not FOwner.CanShowNow then
        begin
          LShowHint := FControl.ShowHint;
          LParentShowHint := TControlAccess(FControl).ParentShowHint;
          FControl.ShowHint := False;
          try
            FOldWindowProc(Message);
          finally
            FControl.ShowHint := LShowHint;
            TControlAccess(FControl).ParentShowHint := LParentShowHint;
          end;
          Exit;
        end;
      end;
    CM_MOUSELEAVE:
      FOwner.ControlMouseLeave(FControl);
    CM_VISIBLECHANGED, CM_ENABLEDCHANGED:
      if not FControl.Visible or not FControl.Enabled then FOwner.HideHint(FControl);
  end;
  FOldWindowProc(Message);
end;

constructor TThemedToolTip.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FInfos := TObjectList<TThemedToolTipInfo>.Create(True);
  FRenderCanvas := TNimbusRenderCanvas.Create;
  FRenderer := TThemedToolTipRenderer.Create;
  FWindowLayouts := TObjectList<TThemedToolTipWindowLayout>.Create(True);
  FFont := TFont.Create;
  FFont.Name := 'Segoe UI';
  FFont.Size := 9;
  FFont.OnChange := FontChanged;
  FUseMarkup := True;
  FShowBorder := True;
  FShowTitleSeparator := False;
  FRoundedCorners := True;
  FShowAlways := True;
  FPaddingSize := 8;
  FMaxWidth := 400;
  FCornerRadius := 4;
  FInitialDelay := 500;
  FReshowDelay := 100;
  FAutoPopDelay := 8000;
  Style := bhsStandard;
  Delay := FInitialDelay;
  HideAfter := FAutoPopDelay;
  Position := hpAutoFromBottom;
  if not (csDesigning in ComponentState) and ((AOwner = nil) or not (csLoading in AOwner.ComponentState)) then RegisterThemeAware;
end;

destructor TThemedToolTip.Destroy;
begin
  if FThemeRegistered then
  begin
    ThemeManager.UnregisterAware(Self);
    FThemeRegistered := False;
  end;
  HideHint;
  FWindowLayouts.Free;
  FInfos.Free;
  FFont.Free;
  FRenderer.Free;
  FRenderCanvas := nil;
  FPalette.Free;
  inherited Destroy;
end;

procedure TThemedToolTip.RegisterThemeAware;
begin
  if FThemeRegistered or (csDesigning in ComponentState) or (csDestroying in ComponentState) then Exit;
  ThemeManager.RegisterAware(Self);
  FThemeRegistered := True;
end;

procedure TThemedToolTip.Loaded;
begin
  inherited Loaded;
  RegisterThemeAware;
end;

procedure TThemedToolTip.ApplyTheme(const APalette: TThemePalette);
begin
  if APalette = nil then Exit;
  if FPalette = nil then FPalette := APalette.Clone else FPalette.Assign(APalette);
end;

function TThemedToolTip.FindInfo(AControl: TControl): TThemedToolTipInfo;
var
  I: Integer;
begin
  Result := nil;
  if AControl = nil then Exit;
  for I := 0 to FInfos.Count - 1 do
    if FInfos[I].Control = AControl then Exit(FInfos[I]);
end;

function TThemedToolTip.FindWindowLayout(const AHandle: HWND): TThemedToolTipLayout;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FWindowLayouts.Count - 1 do
    if FWindowLayouts[I].WindowHandle = AHandle then Exit(FWindowLayouts[I].Layout);
end;

procedure TThemedToolTip.SetWindowLayout(const AHandle: HWND; ALayout: TThemedToolTipLayout);
var
  I: Integer;
  LItem: TThemedToolTipWindowLayout;
begin
  for I := FWindowLayouts.Count - 1 downto 0 do
    if FWindowLayouts[I].WindowHandle = AHandle then FWindowLayouts.Delete(I);
  if ALayout = nil then Exit;
  LItem := TThemedToolTipWindowLayout.Create;
  LItem.WindowHandle := AHandle;
  LItem.Layout := ALayout;
  FWindowLayouts.Add(LItem);
end;

procedure TThemedToolTip.CleanupWindowLayouts;
var
  I: Integer;
begin
  for I := FWindowLayouts.Count - 1 downto 0 do
    if (FWindowLayouts[I].WindowHandle = 0) or not IsWindow(FWindowLayouts[I].WindowHandle) then FWindowLayouts.Delete(I);
end;

function TThemedToolTip.GetInfo(AControl: TControl; const ACreate: Boolean): TThemedToolTipInfo;
begin
  Result := FindInfo(AControl);
  if (Result = nil) and ACreate and (AControl <> nil) then
  begin
    Result := TThemedToolTipInfo.Create(Self, AControl);
    FInfos.Add(Result);
  end;
end;

procedure TThemedToolTip.Notification(AComponent: TComponent; Operation: TOperation);
var
  I: Integer;
  LInfo: TThemedToolTipInfo;
begin
  inherited Notification(AComponent, Operation);
  if (Operation <> opRemove) or not (AComponent is TControl) then Exit;
  if FCurrentControl = AComponent then begin HideHint; FCurrentControl := nil; end;
  for I := FInfos.Count - 1 downto 0 do
  begin
    LInfo := FInfos[I];
    if LInfo.Control = AComponent then
    begin
      LInfo.ReleaseControl(True);
      FInfos.Delete(I);
    end;
  end;
end;

procedure TThemedToolTip.FontChanged(Sender: TObject);
begin
  FDpiInitialized := False;
  HideHint;
end;

procedure TThemedToolTip.SetFont(const AValue: TFont);
begin
  if AValue = nil then Exit;
  FFont.Assign(AValue);
end;

procedure TThemedToolTip.SetGlobalUseMarkup(const AValue: Boolean);
begin
  if FUseMarkup = AValue then Exit;
  FUseMarkup := AValue;
  HideHint;
end;

procedure TThemedToolTip.SetShowBorder(const AValue: Boolean);
begin
  if FShowBorder = AValue then Exit;
  FShowBorder := AValue;
  HideHint;
end;

procedure TThemedToolTip.SetShowTitleSeparator(const AValue: Boolean);
begin
  if FShowTitleSeparator = AValue then Exit;
  FShowTitleSeparator := AValue;
  HideHint;
end;

procedure TThemedToolTip.SetRoundedCorners(const AValue: Boolean);
begin
  if FRoundedCorners = AValue then Exit;
  FRoundedCorners := AValue;
  HideHint;
end;

procedure TThemedToolTip.SetPaddingSize(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(0, AValue);
  if FPaddingSize = LValue then Exit;
  FPaddingSize := LValue;
  FDpiInitialized := False;
  HideHint;
end;

procedure TThemedToolTip.SetMaxWidth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(80, AValue);
  if FMaxWidth = LValue then Exit;
  FMaxWidth := LValue;
  FDpiInitialized := False;
  HideHint;
end;

procedure TThemedToolTip.SetCornerRadius(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(0, AValue);
  if FCornerRadius = LValue then Exit;
  FCornerRadius := LValue;
  FDpiInitialized := False;
  HideHint;
end;

procedure TThemedToolTip.SetInitialDelay(const AValue: Cardinal);
begin
  if FInitialDelay = AValue then Exit;
  FInitialDelay := AValue;
  Delay := AValue;
end;

procedure TThemedToolTip.SetReshowDelay(const AValue: Cardinal);
begin
  if FReshowDelay = AValue then Exit;
  FReshowDelay := AValue;
end;

procedure TThemedToolTip.SetAutoPopDelay(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < -1 then LValue := -1;
  if FAutoPopDelay = LValue then Exit;
  FAutoPopDelay := LValue;
  HideAfter := LValue;
end;

function TThemedToolTip.GetRenderPPI: Integer;
begin
  if FCurrentControl <> nil then Result := FCurrentControl.CurrentPPI
  else if Owner is TControl then Result := TControl(Owner).CurrentPPI
  else Result := CurrentPPI;
  if Result <= 0 then Result := 96;
end;

procedure TThemedToolTip.ApplyDpiScaling;
var
  LPPI, LFontSize: Integer;
begin
  LPPI := GetRenderPPI;
  if FDpiInitialized and (FDpiPPI = LPPI) then Exit;
  FDpiInitialized := True;
  FDpiPPI := LPPI;
  FMetrics.Padding := MulDiv(FPaddingSize, LPPI, 96);
  FMetrics.MaxWidth := MulDiv(FMaxWidth, LPPI, 96);
  FMetrics.BorderThickness := Max(1, MulDiv(1, LPPI, 96));
  FMetrics.CornerRadius := MulDiv(FCornerRadius, LPPI, 96);
  FMetrics.IconSize := MulDiv(18, LPPI, 96);
  FMetrics.Gap := MulDiv(8, LPPI, 96);
  FMetrics.TitleSpacing := MulDiv(4, LPPI, 96);
  FMetrics.SeparatorSpacing := MulDiv(6, LPPI, 96);
  LFontSize := FFont.Size;
  FFont.OnChange := nil;
  try
    FFont.PixelsPerInch := LPPI;
    FFont.Size := LFontSize;
  finally
    FFont.OnChange := FontChanged;
  end;
end;

procedure TThemedToolTip.ControlMouseEnter(AControl: TControl);
var
  LNow: Cardinal;
begin
  FCurrentControl := AControl;
  FUseTransientText := False;
  FHasAnchorBounds := False;
  FDpiInitialized := False;
  LNow := GetTickCount;
  if (FLastLeaveTick <> 0) and (LNow - FLastLeaveTick <= FInitialDelay) then Delay := FReshowDelay else Delay := FInitialDelay;
end;

procedure TThemedToolTip.ShowForControl(AControl: TControl);
begin
  if (AControl = nil) or (csDestroying in AControl.ComponentState) or not CanShowNow then Exit;
  if FindInfo(AControl) = nil then Exit;
  ControlMouseEnter(AControl);
  ShowHint(AControl);
end;

procedure TThemedToolTip.ShowForControl(AControl: TControl; const AClientAnchorBounds: TRect);
begin
  if (AControl = nil) or (csDestroying in AControl.ComponentState) or not CanShowNow then Exit;
  if FindInfo(AControl) = nil then Exit;
  ControlMouseEnter(AControl); FAnchorBounds := AClientAnchorBounds; FHasAnchorBounds := True;
  ShowHint(AControl);
end;

procedure TThemedToolTip.ShowTextForControl(AControl: TControl; const AText: string; const AClientAnchorBounds: TRect);
var ScreenBounds: TRect;
begin
  if (AControl = nil) or (csDestroying in AControl.ComponentState) or not CanShowNow then Exit;
  if AText = '' then begin HideHint; Exit; end;
  AControl.FreeNotification(Self); ControlMouseEnter(AControl);
  FTransientText := AText; FUseTransientText := True;
  FAnchorBounds := AClientAnchorBounds; FHasAnchorBounds := True;
  Title := ''; Description := AText;
  ScreenBounds.TopLeft := AControl.ClientToScreen(AClientAnchorBounds.TopLeft);
  ScreenBounds.BottomRight := AControl.ClientToScreen(AClientAnchorBounds.BottomRight);
  ShowHint(ScreenBounds);
end;

procedure TThemedToolTip.ControlMouseLeave(AControl: TControl);
begin
  if AControl = nil then Exit;
  FLastLeaveTick := GetTickCount;
end;

function TThemedToolTip.CanShowNow: Boolean;
begin
  Result := FShowAlways or Application.Active;
end;

function TThemedToolTip.BuildContent: TThemedToolTipContent;
var
  LInfo: TThemedToolTipInfo;
begin
  Result.Title := '';
  Result.Text := '';
  Result.Icon := ttiNone;
  Result.Image := nil;
  Result.UseMarkup := FUseMarkup;
  if FUseTransientText then begin Result.Text := FTransientText; Exit; end;
  LInfo := FindInfo(FCurrentControl);
  if LInfo = nil then
  begin
    Result.Title := Title;
    Result.Text := Description;
    Exit;
  end;
  Result.Title := LInfo.Title;
  Result.Text := LInfo.Description;
  if Result.Text = '' then Result.Text := LInfo.ToolTipText;
  Result.Icon := LInfo.Icon;
  if (LInfo.Image <> nil) and not LInfo.Image.Empty then Result.Image := LInfo.Image;
  if LInfo.UseGlobalMarkup then Result.UseMarkup := FUseMarkup else Result.UseMarkup := LInfo.UseMarkup;
end;

procedure TThemedToolTip.ApplyHintRegion(AHintWindow: TCustomHintWindow);
var
  LRegion: HRGN;
  LRadius: Integer;
begin
  if (AHintWindow = nil) or not AHintWindow.HandleAllocated then Exit;
  if not FRoundedCorners or (FMetrics.CornerRadius <= 0) then
  begin
    SetWindowRgn(AHintWindow.Handle, 0, True);
    Exit;
  end;
  LRadius := FMetrics.CornerRadius * 2;
  LRegion := CreateRoundRectRgn(0, 0, AHintWindow.Width + 1, AHintWindow.Height + 1, LRadius, LRadius);
  if LRegion = 0 then Exit;
  if SetWindowRgn(AHintWindow.Handle, LRegion, True) = 0 then DeleteObject(LRegion);
end;

procedure TThemedToolTip.PositionHintWindow(AHintWindow: TCustomHintWindow);
var
  LTopLeft, LBottomRight: TPoint;
  LControlRect, LWorkArea: TRect;
  LMonitor: TMonitor;
  LGap, LLeft, LTop, LSpaceAbove, LSpaceBelow: Integer;
  LAbove: Boolean;
begin
  if (AHintWindow = nil) or not AHintWindow.HandleAllocated or (FCurrentControl = nil) then Exit;
  if FHasAnchorBounds then
  begin
    LTopLeft := FCurrentControl.ClientToScreen(FAnchorBounds.TopLeft);
    LBottomRight := FCurrentControl.ClientToScreen(FAnchorBounds.BottomRight);
  end
  else
  begin
    LTopLeft := FCurrentControl.ClientToScreen(Point(0, 0));
    LBottomRight := FCurrentControl.ClientToScreen(Point(FCurrentControl.Width, FCurrentControl.Height));
  end;
  LControlRect := Rect(LTopLeft.X, LTopLeft.Y, LBottomRight.X, LBottomRight.Y);
  LMonitor := Screen.MonitorFromRect(LControlRect);
  if LMonitor <> nil then LWorkArea := LMonitor.WorkareaRect else LWorkArea := Screen.WorkAreaRect;
  LGap := Max(2, MulDiv(6, GetRenderPPI, 96));
  LSpaceAbove := LControlRect.Top - LWorkArea.Top;
  LSpaceBelow := LWorkArea.Bottom - LControlRect.Bottom;
  case Position of
    hpAbove: LAbove := True;
    hpBelow: LAbove := False;
  else
    if LSpaceBelow >= AHintWindow.Height + LGap then LAbove := False
    else if LSpaceAbove >= AHintWindow.Height + LGap then LAbove := True
    else LAbove := LSpaceAbove > LSpaceBelow;
  end;
  if FHasAnchorBounds then LLeft := LControlRect.Left
  else LLeft := LControlRect.Left + (LControlRect.Width - AHintWindow.Width) div 2;
  if AHintWindow.Width >= LWorkArea.Width then LLeft := LWorkArea.Left
  else
  begin
    if LLeft < LWorkArea.Left then LLeft := LWorkArea.Left;
    if LLeft + AHintWindow.Width > LWorkArea.Right then LLeft := LWorkArea.Right - AHintWindow.Width;
  end;
  if LAbove then LTop := LControlRect.Top - AHintWindow.Height - LGap else LTop := LControlRect.Bottom + LGap;
  if LTop < LWorkArea.Top then LTop := LWorkArea.Top;
  if LTop + AHintWindow.Height > LWorkArea.Bottom then LTop := LWorkArea.Bottom - AHintWindow.Height;
  SetWindowPos(AHintWindow.Handle, 0, LLeft, LTop, 0, 0, SWP_NOSIZE or SWP_NOACTIVATE or SWP_NOZORDER);
end;

procedure TThemedToolTip.SetHintSize(HintWindow: TCustomHintWindow);
var
  LContent: TThemedToolTipContent;
  LMetrics: TThemedToolTipMetrics;
  LLayout: TThemedToolTipLayout;
begin
  if HintWindow = nil then Exit;
  ApplyDpiScaling;
  CleanupWindowLayouts;
  LContent := BuildContent;
  LMetrics := FMetrics;
  if not FShowTitleSeparator then LMetrics.SeparatorSpacing := 0;
  FRenderCanvas.BeginRender(TCustomHintWindowAccess(HintWindow).Canvas);
  try
    LLayout := FRenderer.BuildLayout(FRenderCanvas, LContent, FFont, LMetrics);
  finally
    FRenderCanvas.EndRender;
  end;
  if LLayout = nil then
  begin
    HintWindow.Width := 20;
    HintWindow.Height := 20;
  end
  else
  begin
    HintWindow.Width := LLayout.Size.cx;
    HintWindow.Height := LLayout.Size.cy;
  end;
  SetWindowLayout(HintWindow.Handle, LLayout);
  ApplyHintRegion(HintWindow);
end;

procedure TThemedToolTip.PaintHint(HintWindow: TCustomHintWindow);
var
  LMetrics: TThemedToolTipMetrics;
  LLayout: TThemedToolTipLayout;
begin
  if HintWindow = nil then Exit;
  PositionHintWindow(HintWindow);
  LLayout := FindWindowLayout(HintWindow.Handle);
  if LLayout = nil then Exit;
  LMetrics := FMetrics;
  if not FShowTitleSeparator then LMetrics.SeparatorSpacing := 0;
  FRenderCanvas.BeginRender(TCustomHintWindowAccess(HintWindow).Canvas);
  try
    FRenderer.Render(FRenderCanvas, LLayout, FPalette, LMetrics, FShowBorder, FShowTitleSeparator, FRoundedCorners);
  finally
    FRenderCanvas.EndRender;
  end;
end;

procedure TThemedToolTip.SetToolTip(AControl: TControl; const AText: string);
var
  LInfo: TThemedToolTipInfo;
begin
  if AControl = nil then Exit;
  LInfo := GetInfo(AControl);
  LInfo.ToolTipText := AText;
  LInfo.UpdateBinding;
end;

procedure TThemedToolTip.SetToolTip(AControl: TControl; const ATitle, ADescription: string; const AIcon: TThemedToolTipIcon);
var
  LInfo: TThemedToolTipInfo;
begin
  if AControl = nil then Exit;
  LInfo := GetInfo(AControl);
  LInfo.Title := ATitle;
  LInfo.Description := ADescription;
  LInfo.ToolTipText := ADescription;
  LInfo.Icon := AIcon;
  LInfo.UpdateBinding;
end;

function TThemedToolTip.GetToolTip(AControl: TControl): string;
var
  LInfo: TThemedToolTipInfo;
begin
  LInfo := GetInfo(AControl, False);
  if LInfo <> nil then Result := LInfo.ToolTipText else Result := '';
end;

procedure TThemedToolTip.SetTitle(AControl: TControl; const ATitle: string);
var
  LInfo: TThemedToolTipInfo;
begin
  if AControl = nil then Exit;
  LInfo := GetInfo(AControl);
  LInfo.Title := ATitle;
  LInfo.UpdateBinding;
end;

function TThemedToolTip.GetTitle(AControl: TControl): string;
var
  LInfo: TThemedToolTipInfo;
begin
  LInfo := GetInfo(AControl, False);
  if LInfo <> nil then Result := LInfo.Title else Result := '';
end;

procedure TThemedToolTip.SetDescription(AControl: TControl; const ADescription: string);
var
  LInfo: TThemedToolTipInfo;
begin
  if AControl = nil then Exit;
  LInfo := GetInfo(AControl);
  LInfo.Description := ADescription;
  LInfo.UpdateBinding;
end;

function TThemedToolTip.GetDescription(AControl: TControl): string;
var
  LInfo: TThemedToolTipInfo;
begin
  LInfo := GetInfo(AControl, False);
  if LInfo <> nil then Result := LInfo.Description else Result := '';
end;

procedure TThemedToolTip.SetIcon(AControl: TControl; const AIcon: TThemedToolTipIcon);
var
  LInfo: TThemedToolTipInfo;
begin
  if AControl = nil then Exit;
  LInfo := GetInfo(AControl);
  LInfo.Icon := AIcon;
  LInfo.UpdateBinding;
end;

function TThemedToolTip.GetIcon(AControl: TControl): TThemedToolTipIcon;
var
  LInfo: TThemedToolTipInfo;
begin
  LInfo := GetInfo(AControl, False);
  if LInfo <> nil then Result := LInfo.Icon else Result := ttiNone;
end;

procedure TThemedToolTip.SetUseMarkup(AControl: TControl; const AUseMarkup: Boolean);
var
  LInfo: TThemedToolTipInfo;
begin
  if AControl = nil then Exit;
  LInfo := GetInfo(AControl);
  LInfo.UseMarkup := AUseMarkup;
  LInfo.UseGlobalMarkup := False;
end;

function TThemedToolTip.GetUseMarkup(AControl: TControl): Boolean;
var
  LInfo: TThemedToolTipInfo;
begin
  LInfo := GetInfo(AControl, False);
  if LInfo = nil then Exit(FUseMarkup);
  if LInfo.UseGlobalMarkup then Result := FUseMarkup else Result := LInfo.UseMarkup;
end;

procedure TThemedToolTip.ResetUseMarkup(AControl: TControl);
var
  LInfo: TThemedToolTipInfo;
begin
  LInfo := GetInfo(AControl, False);
  if LInfo <> nil then LInfo.UseGlobalMarkup := True;
end;

procedure TThemedToolTip.SetImage(AControl: TControl; AImage: TGraphic);
var
  LInfo: TThemedToolTipInfo;
begin
  if AControl = nil then Exit;
  LInfo := GetInfo(AControl);
  if AImage = nil then
    LInfo.Image.SetSize(0, 0)
  else if AImage is Vcl.Graphics.TBitmap then
    LInfo.Image.Assign(AImage)
  else
  begin
    LInfo.Image.PixelFormat := pf32bit;
    LInfo.Image.SetSize(AImage.Width, AImage.Height);
    LInfo.Image.Canvas.Brush.Color := clBlack;
    LInfo.Image.Canvas.FillRect(Rect(0, 0, AImage.Width, AImage.Height));
    LInfo.Image.Canvas.Draw(0, 0, AImage);
  end;
  LInfo.UpdateBinding;
end;

function TThemedToolTip.GetImage(AControl: TControl): TGraphic;
var
  LInfo: TThemedToolTipInfo;
begin
  LInfo := GetInfo(AControl, False);
  if (LInfo <> nil) and (LInfo.Image <> nil) and not LInfo.Image.Empty then Result := LInfo.Image else Result := nil;
end;

procedure TThemedToolTip.ClearInfo(AControl: TControl);
var
  I: Integer;
begin
  if AControl = nil then Exit;
  for I := FInfos.Count - 1 downto 0 do
    if FInfos[I].Control = AControl then
    begin
      if FCurrentControl = AControl then
      begin
        HideHint;
        FCurrentControl := nil;
      end;
      FInfos.Delete(I);
      Exit;
    end;
end;

end.

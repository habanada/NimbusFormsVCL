{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Theming.Form.Types;

{$SCOPEDENUMS ON}

interface

uses
  System.SysUtils,
  NimbusForms.Theming.Types,
  NimbusForms.Theming.Palette;

type
  TThemedModernFormTitleBarMode = (Normal, Compact, Spacious);

  TThemedModernFormTitleBarHitTestMode = (Auto, Caption, Client);

  TThemedModernFormCornerMode = (Default, Square, Round, RoundSmall);

  TThemedModernFormChromeState = (Normal, Success, Warning, Error, Debug, Custom);

  TThemedModernFormWindowButton = (None, Minimize, MaximizeRestore, Close);

  IThemedModernFormTitleBarHitTest = interface
    ['{7A1D5B0E-6B9C-4F8E-8E3A-2C51D0A94B11}']
    function GetTitleBarHitTestMode: TThemedModernFormTitleBarHitTestMode;
  end;

  IThemedModernFormTitleBarHitTestAutoProvider = interface
    ['{C3E8A7D2-1F40-4B6A-9D55-0E7B2A6F3C98}']
    function GetAutoTitleBarHitTestMode: TThemedModernFormTitleBarHitTestMode;
  end;

  TThemedModernFormChromeMetrics = class
  private
    FBorderThickness: Integer;
    FResizeGripSize: Integer;
    FTitleBarHeight: Integer;
    FButtonWidth: Integer;
    FIconSize: Integer;
    FCaptionLeftPadding: Integer;
    FCaptionRightPadding: Integer;
    FCaptionTopPadding: Integer;
    class function ScaleLogical(const AValue: Integer; const AScale: Single): Integer; static;
    class function ScaleExisting(const AValue: Integer; const AFactor: Single): Integer; static;
  public
    function Clone: TThemedModernFormChromeMetrics;
    function ScaleForDpi(const AOldDpi, ANewDpi: Integer): TThemedModernFormChromeMetrics;
    class function CreateDefault(const AScale: Single): TThemedModernFormChromeMetrics; static;
    property BorderThickness: Integer read FBorderThickness write FBorderThickness;
    property ResizeGripSize: Integer read FResizeGripSize write FResizeGripSize;
    property TitleBarHeight: Integer read FTitleBarHeight write FTitleBarHeight;
    property ButtonWidth: Integer read FButtonWidth write FButtonWidth;
    property IconSize: Integer read FIconSize write FIconSize;
    property CaptionLeftPadding: Integer read FCaptionLeftPadding write FCaptionLeftPadding;
    property CaptionRightPadding: Integer read FCaptionRightPadding write FCaptionRightPadding;
    property CaptionTopPadding: Integer read FCaptionTopPadding write FCaptionTopPadding;
  end;

  TThemedModernFormPalette = class
  private
    FBackColor: TThemeColor;
    FTitleBarBackColor: TThemeColor;
    FTitleBarForeColor: TThemeColor;
    FTitleBarInactiveForeColor: TThemeColor;
    FBorderColor: TThemeColor;
    FBorderInactiveColor: TThemeColor;
    FAccentColor: TThemeColor;
    FButtonHoverBackColor: TThemeColor;
    FButtonPressedBackColor: TThemeColor;
    FCloseButtonHoverBackColor: TThemeColor;
    FCloseButtonPressedBackColor: TThemeColor;
    FButtonGlyphColor: TThemeColor;
    FButtonGlyphInactiveColor: TThemeColor;
    class function Resolve(const APrimary, ASecondary, AFallback: TThemeColor): TThemeColor; static;
    class function IsUnset(const AColor: TThemeColor): Boolean; static;
  public
    function Clone: TThemedModernFormPalette;
    class function FromThemePalette(const ATheme: TThemePalette): TThemedModernFormPalette; static;
    class function CreateDark: TThemedModernFormPalette; static;
    class function CreateLight: TThemedModernFormPalette; static;
    property BackColor: TThemeColor read FBackColor write FBackColor;
    property TitleBarBackColor: TThemeColor read FTitleBarBackColor write FTitleBarBackColor;
    property TitleBarForeColor: TThemeColor read FTitleBarForeColor write FTitleBarForeColor;
    property TitleBarInactiveForeColor: TThemeColor read FTitleBarInactiveForeColor write FTitleBarInactiveForeColor;
    property BorderColor: TThemeColor read FBorderColor write FBorderColor;
    property BorderInactiveColor: TThemeColor read FBorderInactiveColor write FBorderInactiveColor;
    property AccentColor: TThemeColor read FAccentColor write FAccentColor;
    property ButtonHoverBackColor: TThemeColor read FButtonHoverBackColor write FButtonHoverBackColor;
    property ButtonPressedBackColor: TThemeColor read FButtonPressedBackColor write FButtonPressedBackColor;
    property CloseButtonHoverBackColor: TThemeColor read FCloseButtonHoverBackColor write FCloseButtonHoverBackColor;
    property CloseButtonPressedBackColor: TThemeColor read FCloseButtonPressedBackColor write FCloseButtonPressedBackColor;
    property ButtonGlyphColor: TThemeColor read FButtonGlyphColor write FButtonGlyphColor;
    property ButtonGlyphInactiveColor: TThemeColor read FButtonGlyphInactiveColor write FButtonGlyphInactiveColor;
  end;

function RoundAwayFromZero(const AValue: Double): Integer;

implementation

function RoundAwayFromZero(const AValue: Double): Integer;
begin
  if AValue >= 0 then
    Result := Trunc(AValue + 0.5)
  else
    Result := -Trunc(-AValue + 0.5);
end;

class function TThemedModernFormChromeMetrics.ScaleLogical(const AValue: Integer; const AScale: Single): Integer;
begin
  if AValue = 0 then
    Exit(0);
  Result := RoundAwayFromZero(AValue * AScale);
  if Result < 1 then
    Result := 1;
end;

class function TThemedModernFormChromeMetrics.ScaleExisting(const AValue: Integer; const AFactor: Single): Integer;
begin
  if AValue = 0 then
    Exit(0);
  Result := RoundAwayFromZero(AValue * AFactor);
  if Result < 1 then
    Result := 1;
end;

function TThemedModernFormChromeMetrics.Clone: TThemedModernFormChromeMetrics;
begin
  Result := TThemedModernFormChromeMetrics.Create;
  Result.FBorderThickness := FBorderThickness;
  Result.FResizeGripSize := FResizeGripSize;
  Result.FTitleBarHeight := FTitleBarHeight;
  Result.FButtonWidth := FButtonWidth;
  Result.FIconSize := FIconSize;
  Result.FCaptionLeftPadding := FCaptionLeftPadding;
  Result.FCaptionRightPadding := FCaptionRightPadding;
  Result.FCaptionTopPadding := FCaptionTopPadding;
end;

function TThemedModernFormChromeMetrics.ScaleForDpi(const AOldDpi, ANewDpi: Integer): TThemedModernFormChromeMetrics;
var
  LOldDpi: Integer;
  LNewDpi: Integer;
  LFactor: Single;
begin
  LOldDpi := AOldDpi;
  LNewDpi := ANewDpi;
  if LOldDpi <= 0 then
    LOldDpi := 96;
  if LNewDpi <= 0 then
    LNewDpi := 96;
  if LOldDpi = LNewDpi then
    Exit(Clone);
  LFactor := LNewDpi / LOldDpi;
  Result := TThemedModernFormChromeMetrics.Create;
  Result.FBorderThickness := ScaleExisting(FBorderThickness, LFactor);
  Result.FResizeGripSize := ScaleExisting(FResizeGripSize, LFactor);
  Result.FTitleBarHeight := ScaleExisting(FTitleBarHeight, LFactor);
  Result.FButtonWidth := ScaleExisting(FButtonWidth, LFactor);
  Result.FIconSize := ScaleExisting(FIconSize, LFactor);
  Result.FCaptionLeftPadding := ScaleExisting(FCaptionLeftPadding, LFactor);
  Result.FCaptionRightPadding := ScaleExisting(FCaptionRightPadding, LFactor);
  Result.FCaptionTopPadding := ScaleExisting(FCaptionTopPadding, LFactor);
end;

class function TThemedModernFormChromeMetrics.CreateDefault(const AScale: Single): TThemedModernFormChromeMetrics;
var
  LScale: Single;
begin
  LScale := AScale;
  if LScale <= 0 then
    LScale := 1;
  Result := TThemedModernFormChromeMetrics.Create;
  Result.FBorderThickness := ScaleLogical(1, LScale);
  Result.FResizeGripSize := ScaleLogical(7, LScale);
  Result.FTitleBarHeight := ScaleLogical(40, LScale);
  Result.FButtonWidth := ScaleLogical(46, LScale);
  Result.FIconSize := ScaleLogical(18, LScale);
  Result.FCaptionLeftPadding := ScaleLogical(12, LScale);
  Result.FCaptionRightPadding := ScaleLogical(10, LScale);
  Result.FCaptionTopPadding := ScaleLogical(0, LScale);
end;

class function TThemedModernFormPalette.IsUnset(const AColor: TThemeColor): Boolean;
begin
  Result := ThemeColorAlpha(AColor) = 0;
end;

class function TThemedModernFormPalette.Resolve(const APrimary, ASecondary, AFallback: TThemeColor): TThemeColor;
begin
  if not IsUnset(APrimary) then
    Exit(APrimary);
  if not IsUnset(ASecondary) then
    Exit(ASecondary);
  Result := AFallback;
end;

function TThemedModernFormPalette.Clone: TThemedModernFormPalette;
begin
  Result := TThemedModernFormPalette.Create;
  Result.FBackColor := FBackColor;
  Result.FTitleBarBackColor := FTitleBarBackColor;
  Result.FTitleBarForeColor := FTitleBarForeColor;
  Result.FTitleBarInactiveForeColor := FTitleBarInactiveForeColor;
  Result.FBorderColor := FBorderColor;
  Result.FBorderInactiveColor := FBorderInactiveColor;
  Result.FAccentColor := FAccentColor;
  Result.FButtonHoverBackColor := FButtonHoverBackColor;
  Result.FButtonPressedBackColor := FButtonPressedBackColor;
  Result.FCloseButtonHoverBackColor := FCloseButtonHoverBackColor;
  Result.FCloseButtonPressedBackColor := FCloseButtonPressedBackColor;
  Result.FButtonGlyphColor := FButtonGlyphColor;
  Result.FButtonGlyphInactiveColor := FButtonGlyphInactiveColor;
end;

class function TThemedModernFormPalette.FromThemePalette(const ATheme: TThemePalette): TThemedModernFormPalette;
var
  LDark: Boolean;
  LPanelBack: TThemeColor;
  LControlBack: TThemeColor;
  LControlFore: TThemeColor;
  LMutedFore: TThemeColor;
  LBorder: TThemeColor;
  LInactiveBorder: TThemeColor;
  LHover: TThemeColor;
  LPressed: TThemeColor;
  LAccent: TThemeColor;
  LTitleBack: TThemeColor;
  LTitleFore: TThemeColor;

  function Pick(const ADark, ALight: TThemeColor): TThemeColor;
  begin
    if LDark then
      Result := ADark
    else
      Result := ALight;
  end;

begin
  if ATheme = nil then
    Exit(CreateDark);
  LDark := ATheme.IsDark;
  LPanelBack := Resolve(ATheme.PanelBackColor, ATheme.BackColor,
    Pick(ThemeColor(255, 30, 30, 30), ThemeColor(255, 245, 245, 245)));
  LControlBack := Resolve(ATheme.ControlBackColor, LPanelBack,
    Pick(ThemeColor(255, 37, 37, 38), ThemeColor(255, 243, 243, 243)));
  LControlFore := Resolve(ATheme.ControlForeColor, ATheme.ForeColor,
    Pick(ThemeColor(255, 241, 241, 241), ThemeColor(255, 30, 30, 30)));
  LMutedFore := Resolve(ATheme.MutedForeColor, ATheme.DisabledForeColor,
    Pick(ThemeColor(255, 145, 145, 145), ThemeColor(255, 120, 120, 120)));
  LBorder := Resolve(ATheme.FocusBorderColor, ATheme.AccentColor, ATheme.ControlBorderColor);
  LInactiveBorder := Resolve(ATheme.ControlBorderColor, ATheme.SeparatorColor,
    Pick(ThemeColor(255, 63, 63, 70), ThemeColor(255, 200, 200, 200)));
  LHover := Resolve(ATheme.HoverBackColor, ATheme.ControlBackColor,
    Pick(ThemeColor(255, 63, 63, 70), ThemeColor(255, 225, 225, 225)));
  LPressed := Resolve(ATheme.PressedBackColor, ATheme.SelectedBackColor, ATheme.AccentColor);
  LAccent := Resolve(ATheme.AccentColor, LBorder, ThemeColor(255, 0, 122, 204));
  LTitleBack := Resolve(ATheme.DockHeaderBackColor, ATheme.MenuBackColor, LControlBack);
  LTitleFore := Resolve(ATheme.DockHeaderForeColor, LControlFore, ATheme.ForeColor);
  if IsUnset(LTitleBack) or (LTitleBack = $00FFFFFF) then
    LTitleBack := LControlBack;
  if IsUnset(LTitleFore) or (LTitleFore = $00FFFFFF) then
    LTitleFore := LControlFore;
  Result := TThemedModernFormPalette.Create;
  Result.FBackColor := LPanelBack;
  Result.FTitleBarBackColor := LTitleBack;
  Result.FTitleBarForeColor := LTitleFore;
  Result.FTitleBarInactiveForeColor := LMutedFore;
  Result.FBorderColor := LBorder;
  Result.FBorderInactiveColor := LInactiveBorder;
  Result.FAccentColor := LAccent;
  Result.FButtonHoverBackColor := LHover;
  Result.FButtonPressedBackColor := LPressed;
  Result.FCloseButtonHoverBackColor := ThemeColor(255, 232, 17, 35);
  Result.FCloseButtonPressedBackColor := ThemeColor(255, 180, 0, 20);
  Result.FButtonGlyphColor := LTitleFore;
  Result.FButtonGlyphInactiveColor := LMutedFore;
end;

class function TThemedModernFormPalette.CreateDark: TThemedModernFormPalette;
begin
  Result := TThemedModernFormPalette.Create;
  Result.FBackColor := ThemeColor(255, 30, 30, 30);
  Result.FTitleBarBackColor := ThemeColor(255, 37, 37, 38);
  Result.FTitleBarForeColor := ThemeColor(255, 241, 241, 241);
  Result.FTitleBarInactiveForeColor := ThemeColor(255, 150, 150, 150);
  Result.FBorderColor := ThemeColor(255, 0, 122, 204);
  Result.FBorderInactiveColor := ThemeColor(255, 63, 63, 70);
  Result.FAccentColor := ThemeColor(255, 0, 122, 204);
  Result.FButtonHoverBackColor := ThemeColor(255, 63, 63, 70);
  Result.FButtonPressedBackColor := ThemeColor(255, 0, 122, 204);
  Result.FCloseButtonHoverBackColor := ThemeColor(255, 232, 17, 35);
  Result.FCloseButtonPressedBackColor := ThemeColor(255, 180, 0, 20);
  Result.FButtonGlyphColor := ThemeColor(255, 241, 241, 241);
  Result.FButtonGlyphInactiveColor := ThemeColor(255, 145, 145, 145);
end;

class function TThemedModernFormPalette.CreateLight: TThemedModernFormPalette;
begin
  Result := TThemedModernFormPalette.Create;
  Result.FBackColor := ThemeColor(255, 245, 245, 245);
  Result.FTitleBarBackColor := ThemeColor(255, 243, 243, 243);
  Result.FTitleBarForeColor := ThemeColor(255, 30, 30, 30);
  Result.FTitleBarInactiveForeColor := ThemeColor(255, 120, 120, 120);
  Result.FBorderColor := ThemeColor(255, 0, 122, 204);
  Result.FBorderInactiveColor := ThemeColor(255, 200, 200, 200);
  Result.FAccentColor := ThemeColor(255, 0, 122, 204);
  Result.FButtonHoverBackColor := ThemeColor(255, 225, 225, 225);
  Result.FButtonPressedBackColor := ThemeColor(255, 204, 232, 255);
  Result.FCloseButtonHoverBackColor := ThemeColor(255, 232, 17, 35);
  Result.FCloseButtonPressedBackColor := ThemeColor(255, 180, 0, 20);
  Result.FButtonGlyphColor := ThemeColor(255, 30, 30, 30);
  Result.FButtonGlyphInactiveColor := ThemeColor(255, 120, 120, 120);
end;

end.

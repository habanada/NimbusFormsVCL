{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.Types;

interface

uses
  Winapi.Windows,
  System.Types,
  Vcl.Graphics,
  NimbusForms.Theming.Types,
  NimbusForms.Theming.Palette;

type
  TNimbusVisualState = (nvsNormal, nvsHot, nvsPressed, nvsFocused, nvsDisabled);

  TNimbusTextFlag = (ntfCenter, ntfRight, ntfVCenter, ntfBottom, ntfSingleLine,
    ntfWordWrap, ntfEndEllipsis, ntfNoPrefix, ntfRightToLeft, ntfTypographic);
  TNimbusTextFlags = set of TNimbusTextFlag;

function NimbusScaleValue(const AValue, APPI: Integer): Integer; inline;
function NimbusRectIsEmpty(const ARect: TRect): Boolean; inline;
function NimbusBlendColor(const AColor1, AColor2: TThemeColor; const AWeight: Byte): TThemeColor;
function NimbusDarkenColor(const AColor: TThemeColor; const AAmount: Byte): TThemeColor;
function NimbusColorWithAlpha(const AColor: TThemeColor; const AAlpha: Byte): TThemeColor; inline;
function NimbusPanelBackColor(const APalette: TThemePalette): TThemeColor;
function NimbusControlBackColor(const APalette: TThemePalette): TThemeColor;
function NimbusControlForeColor(const APalette: TThemePalette): TThemeColor;
function NimbusControlBorderColor(const APalette: TThemePalette): TThemeColor;
function NimbusAccentColor(const APalette: TThemePalette): TThemeColor;
function NimbusSelectedForeColor(const APalette: TThemePalette): TThemeColor;
function NimbusHoverBackColor(const APalette: TThemePalette): TThemeColor;
function NimbusPressedBackColor(const APalette: TThemePalette): TThemeColor;
function NimbusDisabledBackColor(const APalette: TThemePalette): TThemeColor;
function NimbusDisabledForeColor(const APalette: TThemePalette): TThemeColor;
function NimbusFocusBorderColor(const APalette: TThemePalette): TThemeColor;
function NimbusInputBackColor(const APalette: TThemePalette): TThemeColor;
function NimbusInputForeColor(const APalette: TThemePalette): TThemeColor;
function NimbusInputBorderColor(const APalette: TThemePalette): TThemeColor;
function NimbusMutedForeColor(const APalette: TThemePalette): TThemeColor;
function NimbusMenuBackColor(const APalette: TThemePalette): TThemeColor;
function NimbusMenuForeColor(const APalette: TThemePalette): TThemeColor;
function NimbusMenuBorderColor(const APalette: TThemePalette): TThemeColor;
function NimbusMenuSelectedBackColor(const APalette: TThemePalette): TThemeColor;
function NimbusProgressBackColor(const APalette: TThemePalette): TThemeColor;
function NimbusProgressFillColor(const APalette: TThemePalette): TThemeColor;
function NimbusSeparatorColor(const APalette: TThemePalette): TThemeColor;

const
  NimbusSuccessColor = TThemeColor($FF37A05A);
  NimbusWarningColor = TThemeColor($FFDA9200);
  NimbusDangerColor = TThemeColor($FFD24040);

implementation

uses
  System.UITypes;

function NimbusScaleValue(const AValue, APPI: Integer): Integer;
begin
  if APPI <= 0 then
    Result := AValue
  else
    Result := MulDiv(AValue, APPI, 96);
end;

function NimbusRectIsEmpty(const ARect: TRect): Boolean;
begin
  Result := (ARect.Right <= ARect.Left) or (ARect.Bottom <= ARect.Top);
end;

function NimbusBlendColor(const AColor1, AColor2: TThemeColor; const AWeight: Byte): TThemeColor;
var
  LInverse: Integer;
  LA, LR, LG, LB: Integer;
begin
  LInverse := 255 - AWeight;
  LA := (ThemeColorAlpha(AColor1) * LInverse + ThemeColorAlpha(AColor2) * AWeight) div 255;
  LR := (ThemeColorRed(AColor1) * LInverse + ThemeColorRed(AColor2) * AWeight) div 255;
  LG := (ThemeColorGreen(AColor1) * LInverse + ThemeColorGreen(AColor2) * AWeight) div 255;
  LB := (ThemeColorBlue(AColor1) * LInverse + ThemeColorBlue(AColor2) * AWeight) div 255;
  Result := ThemeColor(Byte(LA), Byte(LR), Byte(LG), Byte(LB));
end;

function NimbusDarkenColor(const AColor: TThemeColor; const AAmount: Byte): TThemeColor;
var
  LR, LG, LB: Integer;
begin
  LR := ThemeColorRed(AColor) - AAmount;
  LG := ThemeColorGreen(AColor) - AAmount;
  LB := ThemeColorBlue(AColor) - AAmount;
  if LR < 0 then LR := 0;
  if LG < 0 then LG := 0;
  if LB < 0 then LB := 0;
  Result := ThemeColor(ThemeColorAlpha(AColor), Byte(LR), Byte(LG), Byte(LB));
end;

function NimbusColorWithAlpha(const AColor: TThemeColor; const AAlpha: Byte): TThemeColor;
begin
  Result := ThemeColor(AAlpha, ThemeColorRed(AColor), ThemeColorGreen(AColor), ThemeColorBlue(AColor));
end;

function NimbusPanelBackColor(const APalette: TThemePalette): TThemeColor;
begin
  if APalette <> nil then Result := APalette.PanelBackColor else Result := ColorToThemeColor(clBtnFace);
end;

function NimbusControlBackColor(const APalette: TThemePalette): TThemeColor;
begin
  if APalette <> nil then Result := APalette.ControlBackColor else Result := ColorToThemeColor(clBtnFace);
end;

function NimbusControlForeColor(const APalette: TThemePalette): TThemeColor;
begin
  if APalette <> nil then Result := APalette.ControlForeColor else Result := ColorToThemeColor(clBtnText);
end;

function NimbusControlBorderColor(const APalette: TThemePalette): TThemeColor;
begin
  if APalette <> nil then Result := APalette.ControlBorderColor else Result := ColorToThemeColor(clBtnShadow);
end;

function NimbusAccentColor(const APalette: TThemePalette): TThemeColor;
begin
  if APalette <> nil then Result := APalette.AccentColor else Result := ColorToThemeColor(clHighlight);
end;

function NimbusSelectedForeColor(const APalette: TThemePalette): TThemeColor;
begin
  if APalette <> nil then Result := APalette.SelectedForeColor else Result := ColorToThemeColor(clHighlightText);
end;

function NimbusHoverBackColor(const APalette: TThemePalette): TThemeColor;
begin
  if APalette <> nil then Result := APalette.HoverBackColor else Result := ColorToThemeColor(clBtnHighlight);
end;

function NimbusPressedBackColor(const APalette: TThemePalette): TThemeColor;
begin
  if APalette <> nil then Result := APalette.PressedBackColor else Result := ColorToThemeColor(clBtnShadow);
end;

function NimbusDisabledBackColor(const APalette: TThemePalette): TThemeColor;
begin
  if APalette <> nil then Result := APalette.DisabledBackColor else Result := ColorToThemeColor(clBtnFace);
end;

function NimbusDisabledForeColor(const APalette: TThemePalette): TThemeColor;
begin
  if APalette <> nil then Result := APalette.DisabledForeColor else Result := ColorToThemeColor(clGrayText);
end;

function NimbusFocusBorderColor(const APalette: TThemePalette): TThemeColor;
begin
  if APalette <> nil then Result := APalette.FocusBorderColor else Result := ColorToThemeColor(clHighlight);
end;

function NimbusInputBackColor(const APalette: TThemePalette): TThemeColor;
begin
  if APalette <> nil then Result := APalette.InputBackColor else Result := ColorToThemeColor(clWindow);
end;

function NimbusInputForeColor(const APalette: TThemePalette): TThemeColor;
begin
  if APalette <> nil then Result := APalette.InputForeColor else Result := ColorToThemeColor(clWindowText);
end;

function NimbusInputBorderColor(const APalette: TThemePalette): TThemeColor;
begin
  if APalette <> nil then Result := APalette.InputBorderColor else Result := ColorToThemeColor(clWindowFrame);
end;

function NimbusMutedForeColor(const APalette: TThemePalette): TThemeColor;
begin
  if APalette <> nil then Result := APalette.MutedForeColor else Result := ColorToThemeColor(clGrayText);
end;

function NimbusMenuBackColor(const APalette: TThemePalette): TThemeColor;
begin
  if APalette <> nil then Result := APalette.MenuBackColor else Result := ColorToThemeColor(clMenu);
end;

function NimbusMenuForeColor(const APalette: TThemePalette): TThemeColor;
begin
  if APalette <> nil then Result := APalette.MenuForeColor else Result := ColorToThemeColor(clMenuText);
end;

function NimbusMenuBorderColor(const APalette: TThemePalette): TThemeColor;
begin
  if APalette <> nil then Result := APalette.MenuBorderColor else Result := ColorToThemeColor(clBtnShadow);
end;

function NimbusMenuSelectedBackColor(const APalette: TThemePalette): TThemeColor;
begin
  if APalette <> nil then Result := APalette.MenuSelectedBackColor else Result := ColorToThemeColor(clHighlight);
end;

function NimbusProgressBackColor(const APalette: TThemePalette): TThemeColor;
begin
  if APalette <> nil then Result := APalette.ProgressBackColor else Result := ColorToThemeColor(clBtnFace);
end;

function NimbusProgressFillColor(const APalette: TThemePalette): TThemeColor;
begin
  if APalette <> nil then Result := APalette.ProgressFillColor else Result := ColorToThemeColor(clHighlight);
end;

function NimbusSeparatorColor(const APalette: TThemePalette): TThemeColor;
begin
  if APalette <> nil then Result := APalette.SeparatorColor else Result := ColorToThemeColor(clBtnShadow);
end;

end.

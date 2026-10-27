{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Theming.Serializer;

interface

uses
  NimbusForms.Theming.Palette;

type
  TThemePaletteSerializer = class
  public
    class procedure SaveToFile(const AFilePath, AThemeName: string; const APalette: TThemePalette); static;
    class function LoadFromFile(const AFilePath: string): TThemePalette; static;
    class function LoadName(const AFilePath: string; out AName: string): Boolean; static;
    class function ToJson(const AThemeName: string; const APalette: TThemePalette): string; static;
    class function FromJson(const AJson: string): TThemePalette; static;
  end;

implementation

uses
  System.SysUtils,
  System.IOUtils,
  System.JSON,
  NimbusForms.Theming.Types,
  NimbusForms.Theming.Strings;

function ColorToHex(const AColor: TThemeColor): string;
begin
  Result := Format('#%2.2X%2.2X%2.2X%2.2X', [ThemeColorAlpha(AColor),
    ThemeColorRed(AColor), ThemeColorGreen(AColor), ThemeColorBlue(AColor)]);
end;

function HexToColor(const AValue: string): TThemeColor;
var
  LText: string;
  LA, LR, LG, LB: Integer;
begin
  if Trim(AValue) = '' then
    Exit(TThemeColor(0));
  LText := Trim(AValue);
  if (Length(LText) > 0) and (LText[1] = '#') then
    LText := Copy(LText, 2, Length(LText) - 1);
  if Length(LText) = 6 then
    LText := 'FF' + LText;
  if Length(LText) <> 8 then
    raise EConvertError.Create(ThemeStrings.ErrInvalidColorFormat);
  LA := StrToInt('$' + Copy(LText, 1, 2));
  LR := StrToInt('$' + Copy(LText, 3, 2));
  LG := StrToInt('$' + Copy(LText, 5, 2));
  LB := StrToInt('$' + Copy(LText, 7, 2));
  Result := ThemeColor(LA, LR, LG, LB);
end;

function ReadColor(const AObject: TJSONObject; const AKey: string): TThemeColor;
var
  LValue: string;
begin
  if AObject.TryGetValue<string>(AKey, LValue) then
    Result := HexToColor(LValue)
  else
    Result := TThemeColor(0);
end;

class function TThemePaletteSerializer.ToJson(const AThemeName: string;
  const APalette: TThemePalette): string;
var
  LObject: TJSONObject;
begin
  LObject := TJSONObject.Create;
  try
    LObject.AddPair(ThemeStrings.JsonName, AThemeName);
    LObject.AddPair(ThemeStrings.JsonIsDark, TJSONBool.Create(APalette.IsDark));
    LObject.AddPair(ThemeStrings.JsonBackColor, ColorToHex(APalette.BackColor));
    LObject.AddPair(ThemeStrings.JsonForeColor, ColorToHex(APalette.ForeColor));
    LObject.AddPair(ThemeStrings.JsonControlBackColor, ColorToHex(APalette.ControlBackColor));
    LObject.AddPair(ThemeStrings.JsonControlForeColor, ColorToHex(APalette.ControlForeColor));
    LObject.AddPair(ThemeStrings.JsonControlBorderColor, ColorToHex(APalette.ControlBorderColor));
    LObject.AddPair(ThemeStrings.JsonAccentColor, ColorToHex(APalette.AccentColor));
    LObject.AddPair(ThemeStrings.JsonMutedForeColor, ColorToHex(APalette.MutedForeColor));
    LObject.AddPair(ThemeStrings.JsonDisabledForeColor, ColorToHex(APalette.DisabledForeColor));
    LObject.AddPair(ThemeStrings.JsonDisabledBackColor, ColorToHex(APalette.DisabledBackColor));
    LObject.AddPair(ThemeStrings.JsonHoverBackColor, ColorToHex(APalette.HoverBackColor));
    LObject.AddPair(ThemeStrings.JsonPressedBackColor, ColorToHex(APalette.PressedBackColor));
    LObject.AddPair(ThemeStrings.JsonSelectedBackColor, ColorToHex(APalette.SelectedBackColor));
    LObject.AddPair(ThemeStrings.JsonSelectedForeColor, ColorToHex(APalette.SelectedForeColor));
    LObject.AddPair(ThemeStrings.JsonFocusBorderColor, ColorToHex(APalette.FocusBorderColor));
    LObject.AddPair(ThemeStrings.JsonInputBackColor, ColorToHex(APalette.InputBackColor));
    LObject.AddPair(ThemeStrings.JsonInputForeColor, ColorToHex(APalette.InputForeColor));
    LObject.AddPair(ThemeStrings.JsonInputBorderColor, ColorToHex(APalette.InputBorderColor));
    LObject.AddPair(ThemeStrings.JsonMenuBackColor, ColorToHex(APalette.MenuBackColor));
    LObject.AddPair(ThemeStrings.JsonMenuForeColor, ColorToHex(APalette.MenuForeColor));
    LObject.AddPair(ThemeStrings.JsonMenuBorderColor, ColorToHex(APalette.MenuBorderColor));
    LObject.AddPair(ThemeStrings.JsonMenuSelectedBackColor, ColorToHex(APalette.MenuSelectedBackColor));
    LObject.AddPair(ThemeStrings.JsonPanelBackColor, ColorToHex(APalette.PanelBackColor));
    LObject.AddPair(ThemeStrings.JsonGroupBoxBorderColor, ColorToHex(APalette.GroupBoxBorderColor));
    LObject.AddPair(ThemeStrings.JsonTabBackColor, ColorToHex(APalette.TabBackColor));
    LObject.AddPair(ThemeStrings.JsonTabForeColor, ColorToHex(APalette.TabForeColor));
    LObject.AddPair(ThemeStrings.JsonActiveTabBackColor, ColorToHex(APalette.ActiveTabBackColor));
    LObject.AddPair(ThemeStrings.JsonActiveTabForeColor, ColorToHex(APalette.ActiveTabForeColor));
    LObject.AddPair(ThemeStrings.JsonProgressBackColor, ColorToHex(APalette.ProgressBackColor));
    LObject.AddPair(ThemeStrings.JsonProgressFillColor, ColorToHex(APalette.ProgressFillColor));
    LObject.AddPair(ThemeStrings.JsonStatusBackColor, ColorToHex(APalette.StatusBackColor));
    LObject.AddPair(ThemeStrings.JsonStatusForeColor, ColorToHex(APalette.StatusForeColor));
    LObject.AddPair(ThemeStrings.JsonSeparatorColor, ColorToHex(APalette.SeparatorColor));
    LObject.AddPair(ThemeStrings.JsonDockHostBackColor, ColorToHex(APalette.DockHostBackColor));
    LObject.AddPair(ThemeStrings.JsonDockPaneBackColor, ColorToHex(APalette.DockPaneBackColor));
    LObject.AddPair(ThemeStrings.JsonDockPaneBorderColor, ColorToHex(APalette.DockPaneBorderColor));
    LObject.AddPair(ThemeStrings.JsonDockHeaderBackColor, ColorToHex(APalette.DockHeaderBackColor));
    LObject.AddPair(ThemeStrings.JsonDockHeaderForeColor, ColorToHex(APalette.DockHeaderForeColor));
    LObject.AddPair(ThemeStrings.JsonDockTabBackColor, ColorToHex(APalette.DockTabBackColor));
    LObject.AddPair(ThemeStrings.JsonDockTabHoverBackColor, ColorToHex(APalette.DockTabHoverBackColor));
    LObject.AddPair(ThemeStrings.JsonDockTabActiveBackColor, ColorToHex(APalette.DockTabActiveBackColor));
    LObject.AddPair(ThemeStrings.JsonDockTabBorderColor, ColorToHex(APalette.DockTabBorderColor));
    LObject.AddPair(ThemeStrings.JsonDockTabActiveBorderColor, ColorToHex(APalette.DockTabActiveBorderColor));
    LObject.AddPair(ThemeStrings.JsonDockTabForeColor, ColorToHex(APalette.DockTabForeColor));
    LObject.AddPair(ThemeStrings.JsonDockTabActiveForeColor, ColorToHex(APalette.DockTabActiveForeColor));
    LObject.AddPair(ThemeStrings.JsonDockTabMutedForeColor, ColorToHex(APalette.DockTabMutedForeColor));
    LObject.AddPair(ThemeStrings.JsonDockSplitterBackColor, ColorToHex(APalette.DockSplitterBackColor));
    LObject.AddPair(ThemeStrings.JsonDockSplitterHoverBackColor, ColorToHex(APalette.DockSplitterHoverBackColor));
    LObject.AddPair(ThemeStrings.JsonDockDropTargetBackColor, ColorToHex(APalette.DockDropTargetBackColor));
    LObject.AddPair(ThemeStrings.JsonDockDropTargetBorderColor, ColorToHex(APalette.DockDropTargetBorderColor));
    LObject.AddPair(ThemeStrings.JsonDockDropTargetHoverBackColor, ColorToHex(APalette.DockDropTargetHoverBackColor));
    LObject.AddPair(ThemeStrings.JsonDockDropTargetHoverBorderColor, ColorToHex(APalette.DockDropTargetHoverBorderColor));
    LObject.AddPair(ThemeStrings.JsonDockDropPreviewBackColor, ColorToHex(APalette.DockDropPreviewBackColor));
    LObject.AddPair(ThemeStrings.JsonDockDropPreviewBorderColor, ColorToHex(APalette.DockDropPreviewBorderColor));
    Result := LObject.Format(2);
  finally
    LObject.Free;
  end;
end;

class function TThemePaletteSerializer.FromJson(const AJson: string): TThemePalette;
var
  LValue: TJSONValue;
  LObject: TJSONObject;
  LBool: Boolean;
begin
  Result := nil;
  LValue := TJSONObject.ParseJSONValue(AJson);
  if LValue = nil then
    Exit;
  try
    if not (LValue is TJSONObject) then
      Exit;
    LObject := TJSONObject(LValue);
    Result := TThemePalette.Create;
    try
      if LObject.TryGetValue<Boolean>(ThemeStrings.JsonIsDark, LBool) then
        Result.IsDark := LBool;
      Result.BackColor := ReadColor(LObject, ThemeStrings.JsonBackColor);
      Result.ForeColor := ReadColor(LObject, ThemeStrings.JsonForeColor);
      Result.ControlBackColor := ReadColor(LObject, ThemeStrings.JsonControlBackColor);
      Result.ControlForeColor := ReadColor(LObject, ThemeStrings.JsonControlForeColor);
      Result.ControlBorderColor := ReadColor(LObject, ThemeStrings.JsonControlBorderColor);
      Result.AccentColor := ReadColor(LObject, ThemeStrings.JsonAccentColor);
      Result.MutedForeColor := ReadColor(LObject, ThemeStrings.JsonMutedForeColor);
      Result.DisabledForeColor := ReadColor(LObject, ThemeStrings.JsonDisabledForeColor);
      Result.DisabledBackColor := ReadColor(LObject, ThemeStrings.JsonDisabledBackColor);
      Result.HoverBackColor := ReadColor(LObject, ThemeStrings.JsonHoverBackColor);
      Result.PressedBackColor := ReadColor(LObject, ThemeStrings.JsonPressedBackColor);
      Result.SelectedBackColor := ReadColor(LObject, ThemeStrings.JsonSelectedBackColor);
      Result.SelectedForeColor := ReadColor(LObject, ThemeStrings.JsonSelectedForeColor);
      Result.FocusBorderColor := ReadColor(LObject, ThemeStrings.JsonFocusBorderColor);
      Result.InputBackColor := ReadColor(LObject, ThemeStrings.JsonInputBackColor);
      Result.InputForeColor := ReadColor(LObject, ThemeStrings.JsonInputForeColor);
      Result.InputBorderColor := ReadColor(LObject, ThemeStrings.JsonInputBorderColor);
      Result.MenuBackColor := ReadColor(LObject, ThemeStrings.JsonMenuBackColor);
      Result.MenuForeColor := ReadColor(LObject, ThemeStrings.JsonMenuForeColor);
      Result.MenuBorderColor := ReadColor(LObject, ThemeStrings.JsonMenuBorderColor);
      Result.MenuSelectedBackColor := ReadColor(LObject, ThemeStrings.JsonMenuSelectedBackColor);
      Result.PanelBackColor := ReadColor(LObject, ThemeStrings.JsonPanelBackColor);
      Result.GroupBoxBorderColor := ReadColor(LObject, ThemeStrings.JsonGroupBoxBorderColor);
      Result.TabBackColor := ReadColor(LObject, ThemeStrings.JsonTabBackColor);
      Result.TabForeColor := ReadColor(LObject, ThemeStrings.JsonTabForeColor);
      Result.ActiveTabBackColor := ReadColor(LObject, ThemeStrings.JsonActiveTabBackColor);
      Result.ActiveTabForeColor := ReadColor(LObject, ThemeStrings.JsonActiveTabForeColor);
      Result.ProgressBackColor := ReadColor(LObject, ThemeStrings.JsonProgressBackColor);
      Result.ProgressFillColor := ReadColor(LObject, ThemeStrings.JsonProgressFillColor);
      Result.StatusBackColor := ReadColor(LObject, ThemeStrings.JsonStatusBackColor);
      Result.StatusForeColor := ReadColor(LObject, ThemeStrings.JsonStatusForeColor);
      Result.SeparatorColor := ReadColor(LObject, ThemeStrings.JsonSeparatorColor);
      Result.DockHostBackColor := ReadColor(LObject, ThemeStrings.JsonDockHostBackColor);
      Result.DockPaneBackColor := ReadColor(LObject, ThemeStrings.JsonDockPaneBackColor);
      Result.DockPaneBorderColor := ReadColor(LObject, ThemeStrings.JsonDockPaneBorderColor);
      Result.DockHeaderBackColor := ReadColor(LObject, ThemeStrings.JsonDockHeaderBackColor);
      Result.DockHeaderForeColor := ReadColor(LObject, ThemeStrings.JsonDockHeaderForeColor);
      Result.DockTabBackColor := ReadColor(LObject, ThemeStrings.JsonDockTabBackColor);
      Result.DockTabHoverBackColor := ReadColor(LObject, ThemeStrings.JsonDockTabHoverBackColor);
      Result.DockTabActiveBackColor := ReadColor(LObject, ThemeStrings.JsonDockTabActiveBackColor);
      Result.DockTabBorderColor := ReadColor(LObject, ThemeStrings.JsonDockTabBorderColor);
      Result.DockTabActiveBorderColor := ReadColor(LObject, ThemeStrings.JsonDockTabActiveBorderColor);
      Result.DockTabForeColor := ReadColor(LObject, ThemeStrings.JsonDockTabForeColor);
      Result.DockTabActiveForeColor := ReadColor(LObject, ThemeStrings.JsonDockTabActiveForeColor);
      Result.DockTabMutedForeColor := ReadColor(LObject, ThemeStrings.JsonDockTabMutedForeColor);
      Result.DockSplitterBackColor := ReadColor(LObject, ThemeStrings.JsonDockSplitterBackColor);
      Result.DockSplitterHoverBackColor := ReadColor(LObject, ThemeStrings.JsonDockSplitterHoverBackColor);
      Result.DockDropTargetBackColor := ReadColor(LObject, ThemeStrings.JsonDockDropTargetBackColor);
      Result.DockDropTargetBorderColor := ReadColor(LObject, ThemeStrings.JsonDockDropTargetBorderColor);
      Result.DockDropTargetHoverBackColor := ReadColor(LObject, ThemeStrings.JsonDockDropTargetHoverBackColor);
      Result.DockDropTargetHoverBorderColor := ReadColor(LObject, ThemeStrings.JsonDockDropTargetHoverBorderColor);
      Result.DockDropPreviewBackColor := ReadColor(LObject, ThemeStrings.JsonDockDropPreviewBackColor);
      Result.DockDropPreviewBorderColor := ReadColor(LObject, ThemeStrings.JsonDockDropPreviewBorderColor);
    except
      Result.Free;
      raise;
    end;
  finally
    LValue.Free;
  end;
end;

class procedure TThemePaletteSerializer.SaveToFile(const AFilePath, AThemeName: string;
  const APalette: TThemePalette);
begin
  if Trim(AFilePath) = '' then
    raise EArgumentException.Create(ThemeStrings.ErrEmptyFilePath);
  if APalette = nil then
    raise EArgumentNilException.Create(ThemeStrings.ErrNilPalette);
  TFile.WriteAllBytes(AFilePath, TEncoding.UTF8.GetBytes(ToJson(AThemeName, APalette)));
end;

class function TThemePaletteSerializer.LoadFromFile(const AFilePath: string): TThemePalette;
begin
  if Trim(AFilePath) = '' then
    raise EArgumentException.Create(ThemeStrings.ErrEmptyFilePath);
  if not TFile.Exists(AFilePath) then
    Exit(nil);
  Result := FromJson(TFile.ReadAllText(AFilePath, TEncoding.UTF8));
end;

class function TThemePaletteSerializer.LoadName(const AFilePath: string;
  out AName: string): Boolean;
var
  LValue: TJSONValue;
  LObject: TJSONObject;
  LName: string;
begin
  AName := '';
  Result := False;
  if not TFile.Exists(AFilePath) then
    Exit;
  LValue := TJSONObject.ParseJSONValue(TFile.ReadAllText(AFilePath, TEncoding.UTF8));
  if LValue = nil then
    Exit;
  try
    if not (LValue is TJSONObject) then
      Exit;
    LObject := TJSONObject(LValue);
    if LObject.TryGetValue<string>(ThemeStrings.JsonName, LName) then
    begin
      AName := LName;
      Result := True;
    end;
  finally
    LValue.Free;
  end;
end;

end.

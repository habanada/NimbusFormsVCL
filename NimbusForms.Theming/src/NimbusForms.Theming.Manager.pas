{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Theming.Manager;

interface

uses
  System.Classes,
  System.Generics.Collections,
  Vcl.Controls,
  NimbusForms.Theming.Types,
  NimbusForms.Theming.Palette;

type
  TThemeChangedEvent = procedure(Sender: TObject; const APalette: TThemePalette) of object;

  TThemeManager = class
  strict private
    FCurrentTheme: TThemePalette;
    FAware: TList<IThemeAware>;
    FOnThemeChanged: TThemeChangedEvent;
    FApplying: Boolean;
    procedure NotifyAware;
    procedure ApplyToControl(const AControl: TControl; const APalette: TThemePalette);
    procedure ApplyFallbackColors(const AControl: TControl; const APalette: TThemePalette);
    procedure ApplyToChildren(const AControl: TWinControl; const APalette: TThemePalette);
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterAware(const AAware: IThemeAware);
    procedure UnregisterAware(const AAware: IThemeAware);
    procedure Apply(const AControl: TControl; const APalette: TThemePalette;
      const AScope: TThemeScope = tsSelfAndChildren);
    procedure ApplyCurrent(const AControl: TControl);
    procedure ApplyGlobal(const APalette: TThemePalette);
    function SetThemeByName(const AName: string): Boolean;
    property CurrentTheme: TThemePalette read FCurrentTheme;
    property OnThemeChanged: TThemeChangedEvent read FOnThemeChanged write FOnThemeChanged;
  end;

function ThemeManager: TThemeManager;

implementation

uses
  System.SysUtils,
  System.TypInfo,
  System.UITypes,
  Vcl.Graphics,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  NimbusForms.Theming.Win32,
  NimbusForms.Theming.Presets;

var
  GThemeManager: TThemeManager;

function ThemeManager: TThemeManager;
begin
  if GThemeManager = nil then
    GThemeManager := TThemeManager.Create;
  Result := GThemeManager;
end;

constructor TThemeManager.Create;
begin
  inherited Create;
  FAware := TList<IThemeAware>.Create;
end;

destructor TThemeManager.Destroy;
begin
  FAware.Free;
  FCurrentTheme.Free;
  inherited Destroy;
end;

procedure TThemeManager.RegisterAware(const AAware: IThemeAware);
begin
  if AAware = nil then
    Exit;
  if not FAware.Contains(AAware) then
    FAware.Add(AAware);
  if FCurrentTheme <> nil then
    AAware.ApplyTheme(FCurrentTheme);
end;

procedure TThemeManager.UnregisterAware(const AAware: IThemeAware);
begin
  if AAware = nil then
    Exit;
  FAware.Remove(AAware);
end;

procedure TThemeManager.NotifyAware;
var
  I: Integer;
begin
  for I := FAware.Count - 1 downto 0 do
    if FCurrentTheme <> nil then
      FAware[I].ApplyTheme(FCurrentTheme);
end;

procedure TThemeManager.ApplyGlobal(const APalette: TThemePalette);
var
  I: Integer;
  LForm: TForm;
begin
  if APalette = nil then
    Exit;
  if FCurrentTheme <> APalette then
  begin
    FCurrentTheme.Free;
    FCurrentTheme := APalette.Clone;
  end;
  NotifyAware;
  for I := 0 to Screen.FormCount - 1 do
  begin
    LForm := Screen.Forms[I];
    if (LForm <> nil) and (not (csDestroying in LForm.ComponentState)) then
      Apply(LForm, FCurrentTheme);
  end;
  if Assigned(FOnThemeChanged) then
    FOnThemeChanged(Self, FCurrentTheme);
end;

procedure TThemeManager.ApplyCurrent(const AControl: TControl);
begin
  if (FCurrentTheme = nil) or (AControl = nil) then
    Exit;
  Apply(AControl, FCurrentTheme);
end;

function TThemeManager.SetThemeByName(const AName: string): Boolean;
var
  LPalette: TThemePalette;
begin
  LPalette := TThemePresets.GetByName(AName);
  if LPalette = nil then
    Exit(False);
  try
    ApplyGlobal(LPalette);
  finally
    LPalette.Free;
  end;
  Result := True;
end;

procedure TThemeManager.Apply(const AControl: TControl; const APalette: TThemePalette;
  const AScope: TThemeScope);
var
  LForm: TCustomForm;
  LOldApplying: Boolean;
begin
  if (AControl = nil) or (APalette = nil) then
    Exit;
  if csDestroying in AControl.ComponentState then
    Exit;
  LOldApplying := FApplying;
  FApplying := True;
  try
    if AControl is TCustomForm then
    begin
      LForm := TCustomForm(AControl);
      TWin32ThemeHelper.ApplyImmersiveDarkMode(LForm, APalette.IsDark);
      LForm.Color := ThemeColorToColor(APalette.PanelBackColor);
      LForm.Font.Color := ThemeColorToColor(APalette.ControlForeColor);
    end;
    if AScope in [tsSelf, tsSelfAndChildren] then
      ApplyToControl(AControl, APalette);
    if (AScope in [tsChildren, tsSelfAndChildren]) and (AControl is TWinControl) then
      ApplyToChildren(TWinControl(AControl), APalette);
  finally
    FApplying := LOldApplying;
  end;
end;

procedure TThemeManager.ApplyToChildren(const AControl: TWinControl;
  const APalette: TThemePalette);
var
  I: Integer;
  LChild: TControl;
begin
  for I := 0 to AControl.ControlCount - 1 do
  begin
    LChild := AControl.Controls[I];
    ApplyToControl(LChild, APalette);
    if LChild is TWinControl then
      ApplyToChildren(TWinControl(LChild), APalette);
  end;
end;

procedure TThemeManager.ApplyToControl(const AControl: TControl;
  const APalette: TThemePalette);
var
  LAware: IThemeAware;
begin
  if AControl = nil then
    Exit;
  if csDestroying in AControl.ComponentState then
    Exit;
  if Supports(AControl, IThemeAware, LAware) then
  begin
    LAware.ApplyTheme(APalette);
    Exit;
  end;
  ApplyFallbackColors(AControl, APalette);
end;

procedure TThemeManager.ApplyFallbackColors(const AControl: TControl;
  const APalette: TThemePalette);

  procedure SetBack(const AColor: TThemeColor);
  begin
    if IsPublishedProp(AControl, 'Color') then
      SetOrdProp(AControl, 'Color', ThemeColorToColor(AColor));
  end;

  procedure SetFore(const AColor: TThemeColor);
  var
    LFont: TObject;
  begin
    if IsPublishedProp(AControl, 'Font') then
    begin
      LFont := GetObjectProp(AControl, 'Font');
      if LFont is TFont then
        TFont(LFont).Color := ThemeColorToColor(AColor);
    end;
  end;

begin
  if (AControl is TCustomForm) or (AControl is TCustomPanel) then
  begin
    SetBack(APalette.PanelBackColor);
    SetFore(APalette.ForeColor);
    Exit;
  end;
  if AControl is TCustomLabel then
  begin
    SetFore(APalette.ForeColor);
    Exit;
  end;
  if (AControl is TCustomEdit) or (AControl is TCustomMemo) or
     (AControl is TCustomComboBox) or (AControl is TCustomListBox) then
  begin
    SetBack(APalette.InputBackColor);
    SetFore(APalette.InputForeColor);
    Exit;
  end;
  SetBack(APalette.ControlBackColor);
  SetFore(APalette.ControlForeColor);
end;

initialization

finalization
  GThemeManager.Free;
  GThemeManager := nil;

end.

{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Theming.Form.Native;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  NimbusForms.Theming.Types;

type
  TThemedModernFormNative = class
  private
    class var FInitialized: Boolean;
    class var FWindows10OrLater: Boolean;
    class var FWindows11OrLater: Boolean;
    class var FImmersiveDarkModeSupported: Boolean;
    class procedure EnsureInitialized; static;
  public
  const
    WM_CHROME_SYNC = WM_APP + $0301;
    DWMWA_NCRENDERING_POLICY = 2;
    DWMWA_WINDOW_CORNER_PREFERENCE = 33;
    DWMWA_BORDER_COLOR = 34;
    DWMWA_CAPTION_COLOR = 35;
    DWMWA_TEXT_COLOR = 36;
    DWMNCRP_ENABLED = 2;
    DWMWCP_DEFAULT = 0;
    DWMWCP_DONOTROUND = 1;
    DWMWCP_ROUND = 2;
    DWMWCP_ROUNDSMALL = 3;
    DWMWA_COLOR_DEFAULT = -1;
    DWMWA_COLOR_NONE = -2;
    EVENT_OBJECT_REORDER = $8004;
    EVENT_OBJECT_STATECHANGE = $800A;
    EVENT_OBJECT_NAMECHANGE = $800C;
    class function IsWindows10OrLater: Boolean; static;
    class function IsWindows11OrLater: Boolean; static;
    class function SupportsImmersiveDarkMode: Boolean; static;
    class function SupportsDwmWindowAttributes: Boolean; static;
    class function IsDwmCompositionEnabled: Boolean; static;
    class function TryGetWindowDpi(const AWnd: HWND; out ADpi: Integer): Boolean; static;
    class function TrySetDwmWindowAttribute(const AWnd: HWND; const AAttribute, AValue: Integer): Boolean; static;
    class function TryDwmDefWindowProc(const AWnd: HWND; const AMessage: UINT; const AWParam: WPARAM;
      const ALParam: LPARAM; out AResult: LRESULT): Boolean; static;
    class procedure SetSystemMenuItemEnabled(const AMenu: HMENU; const ACommand: Integer;
      const AEnabled: Boolean); static;
    class function ToColorRef(const AColor: TThemeColor): Integer; static;
  end;

implementation

uses
  System.SysUtils,
  NimbusForms.Theming.WinVersion;

function DwmSetWindowAttributeNative(AWnd: HWND; AAttribute: DWORD; AValue: Pointer;
  ASize: DWORD): HRESULT; stdcall; external 'dwmapi.dll' name 'DwmSetWindowAttribute' delayed;

function DwmDefWindowProcNative(AWnd: HWND; AMessage: UINT; AWParam: WPARAM; ALParam: LPARAM;
  out AResult: LRESULT): BOOL; stdcall; external 'dwmapi.dll' name 'DwmDefWindowProc' delayed;

function DwmIsCompositionEnabledNative(out AEnabled: BOOL): HRESULT; stdcall;
  external 'dwmapi.dll' name 'DwmIsCompositionEnabled' delayed;

function GetDpiForWindowNative(AWnd: HWND): UINT; stdcall;
  external 'user32.dll' name 'GetDpiForWindow' delayed;

class procedure TThemedModernFormNative.EnsureInitialized;
var
  LInfo: TWinVersionInfo;
begin
  if FInitialized then
    Exit;
  FInitialized := True;
  if not TWinVersion.GetVersion(LInfo) then
    Exit;
  FWindows10OrLater := LInfo.Major >= 10;
  FWindows11OrLater := FWindows10OrLater and (LInfo.BuildNumber >= TWinVersion.BuildWindows11_21H2);
  FImmersiveDarkModeSupported := FWindows10OrLater and (LInfo.BuildNumber >= TWinVersion.BuildWindows10_1809);
end;

class function TThemedModernFormNative.IsWindows10OrLater: Boolean;
begin
  EnsureInitialized;
  Result := FWindows10OrLater;
end;

class function TThemedModernFormNative.IsWindows11OrLater: Boolean;
begin
  EnsureInitialized;
  Result := FWindows11OrLater;
end;

class function TThemedModernFormNative.SupportsImmersiveDarkMode: Boolean;
begin
  EnsureInitialized;
  Result := FImmersiveDarkModeSupported;
end;

class function TThemedModernFormNative.SupportsDwmWindowAttributes: Boolean;
begin
  EnsureInitialized;
  Result := FWindows11OrLater;
end;

class function TThemedModernFormNative.IsDwmCompositionEnabled: Boolean;
var
  LEnabled: BOOL;
begin
  Result := False;
  try
    LEnabled := False;
    Result := (DwmIsCompositionEnabledNative(LEnabled) = S_OK) and LEnabled;
  except
    Result := False;
  end;
end;

class function TThemedModernFormNative.TryGetWindowDpi(const AWnd: HWND; out ADpi: Integer): Boolean;
var
  LValue: UINT;
begin
  ADpi := 96;
  Result := False;
  if (AWnd = 0) or (not IsWindows10OrLater) then
    Exit;
  try
    LValue := GetDpiForWindowNative(AWnd);
    if LValue = 0 then
      Exit;
    ADpi := Integer(LValue);
    Result := True;
  except
    Result := False;
  end;
end;

class function TThemedModernFormNative.TrySetDwmWindowAttribute(const AWnd: HWND;
  const AAttribute, AValue: Integer): Boolean;
var
  LValue: Integer;
begin
  Result := False;
  if AWnd = 0 then
    Exit;
  LValue := AValue;
  try
    Result := DwmSetWindowAttributeNative(AWnd, DWORD(AAttribute), @LValue, SizeOf(LValue)) = S_OK;
  except
    Result := False;
  end;
end;

class function TThemedModernFormNative.TryDwmDefWindowProc(const AWnd: HWND; const AMessage: UINT;
  const AWParam: WPARAM; const ALParam: LPARAM; out AResult: LRESULT): Boolean;
begin
  AResult := 0;
  Result := False;
  if AWnd = 0 then
    Exit;
  try
    Result := DwmDefWindowProcNative(AWnd, AMessage, AWParam, ALParam, AResult);
  except
    Result := False;
  end;
end;

class procedure TThemedModernFormNative.SetSystemMenuItemEnabled(const AMenu: HMENU;
  const ACommand: Integer; const AEnabled: Boolean);
var
  LState: UINT;
begin
  if AMenu = 0 then
    Exit;
  LState := MF_BYCOMMAND;
  if AEnabled then
    LState := LState or MF_ENABLED
  else
    LState := LState or MF_GRAYED;
  EnableMenuItem(AMenu, UINT(ACommand), LState);
end;

class function TThemedModernFormNative.ToColorRef(const AColor: TThemeColor): Integer;
begin
  Result := ThemeColorRed(AColor) or (ThemeColorGreen(AColor) shl 8) or (ThemeColorBlue(AColor) shl 16);
end;

end.

{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Theming.Win32;

interface

uses
  Winapi.Windows,
  Vcl.Forms;

type
  TWin32ThemeHelper = class
  public
    const
      DWMWA_USE_IMMERSIVE_DARK_MODE_OLD = 19;
      DWMWA_USE_IMMERSIVE_DARK_MODE = 20;
    class function SupportsImmersiveDarkMode: Boolean; static;
    class procedure ApplyImmersiveDarkMode(const AHandle: HWND; const AIsDark: Boolean); overload; static;
    class procedure ApplyImmersiveDarkMode(const AForm: TCustomForm; const AIsDark: Boolean); overload; static;
  end;

implementation

uses
  NimbusForms.Theming.WinVersion;

function DwmSetWindowAttribute(hwnd: HWND; dwAttribute: Cardinal;
  pvAttribute: Pointer; cbAttribute: Cardinal): HRESULT; stdcall;
  external 'dwmapi.dll' name 'DwmSetWindowAttribute';

class function TWin32ThemeHelper.SupportsImmersiveDarkMode: Boolean;
begin
  Result := TWinVersion.IsBuildNumberGreaterOrEqual(TWinVersion.BuildWindows10_1809);
end;

class procedure TWin32ThemeHelper.ApplyImmersiveDarkMode(const AHandle: HWND;
  const AIsDark: Boolean);
var
  LValue: BOOL;
begin
  if (AHandle = 0) or (not SupportsImmersiveDarkMode) then
    Exit;
  LValue := AIsDark;
  if Failed(DwmSetWindowAttribute(AHandle, DWMWA_USE_IMMERSIVE_DARK_MODE,
    @LValue, SizeOf(LValue))) then
    DwmSetWindowAttribute(AHandle, DWMWA_USE_IMMERSIVE_DARK_MODE_OLD,
      @LValue, SizeOf(LValue));
end;

class procedure TWin32ThemeHelper.ApplyImmersiveDarkMode(const AForm: TCustomForm;
  const AIsDark: Boolean);
begin
  if (AForm = nil) or (not AForm.HandleAllocated) then
    Exit;
  ApplyImmersiveDarkMode(AForm.Handle, AIsDark);
end;

end.

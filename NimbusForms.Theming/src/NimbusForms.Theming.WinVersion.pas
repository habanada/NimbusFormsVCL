{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Theming.WinVersion;

interface

uses
  Winapi.Windows;

type
  TWinVersionInfo = record
    Major: Cardinal;
    Minor: Cardinal;
    BuildNumber: Cardinal;
  end;

  TWinVersion = class
  public
    const
      BuildWindows10_1809 = 17763;
      BuildWindows10_2004 = 19041;
      BuildWindows11_21H2 = 22000;
    class function GetVersion(out AInfo: TWinVersionInfo): Boolean; static;
    class function IsBuildNumberGreaterOrEqual(const ABuildNumber: Cardinal): Boolean; static;
    class function IsWindows11OrLater: Boolean; static;
  end;

implementation

type
  TOSVersionInfoExW = record
    dwOSVersionInfoSize: Cardinal;
    dwMajorVersion: Cardinal;
    dwMinorVersion: Cardinal;
    dwBuildNumber: Cardinal;
    dwPlatformId: Cardinal;
    szCSDVersion: array[0..127] of WideChar;
    wServicePackMajor: Word;
    wServicePackMinor: Word;
    wSuiteMask: Word;
    wProductType: Byte;
    wReserved: Byte;
  end;

function RtlGetVersion(var AVersionInformation: TOSVersionInfoExW): LongInt; stdcall;
  external 'ntdll.dll' name 'RtlGetVersion';

class function TWinVersion.GetVersion(out AInfo: TWinVersionInfo): Boolean;
var
  LInfo: TOSVersionInfoExW;
begin
  AInfo.Major := 0;
  AInfo.Minor := 0;
  AInfo.BuildNumber := 0;
  FillChar(LInfo, SizeOf(LInfo), 0);
  LInfo.dwOSVersionInfoSize := SizeOf(LInfo);
  if RtlGetVersion(LInfo) = 0 then
  begin
    AInfo.Major := LInfo.dwMajorVersion;
    AInfo.Minor := LInfo.dwMinorVersion;
    AInfo.BuildNumber := LInfo.dwBuildNumber;
    Result := True;
  end
  else
    Result := False;
end;

class function TWinVersion.IsBuildNumberGreaterOrEqual(const ABuildNumber: Cardinal): Boolean;
var
  LInfo: TWinVersionInfo;
begin
  if GetVersion(LInfo) then
    Result := LInfo.BuildNumber >= ABuildNumber
  else
    Result := False;
end;

class function TWinVersion.IsWindows11OrLater: Boolean;
begin
  Result := IsBuildNumberGreaterOrEqual(BuildWindows11_21H2);
end;

end.

{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.LogViewer.Monitor;

interface

uses System.Classes, System.SysUtils, NimbusForms.Controls.LogViewer.Types,
  NimbusForms.Controls.LogViewer.Encoding;

type
  TNimbusLogMonitorLineEvent = procedure(const AText: string) of object;
  TNimbusLogFileMonitor = class
  private
    FPath, FIdentity: string;
    FOffset, FInitialSize: Int64;
    FEncoding, FRequestedEncoding: TNimbusLogFileEncoding;
    FDecoder: TNimbusLogLineDecoder;
    FRunning, FFromEnd, FInitialized, FHaveInitialSize: Boolean;
    procedure ProcessBytes(const ABytes: TBytes; const ACount: Integer; const AOnLine: TNimbusLogMonitorLineEvent);
  public
    destructor Destroy; override;
    procedure Start(const APath: string; const AFromEnd: Boolean = True;
      const AEncoding: TNimbusLogFileEncoding = nlfeAuto);
    procedure Stop;
    function Poll(const AOnLine: TNimbusLogMonitorLineEvent): Integer;
    property Path: string read FPath;
    property Offset: Int64 read FOffset;
    property Running: Boolean read FRunning;
    property DetectedEncoding: TNimbusLogFileEncoding read FEncoding;
  end;

implementation

uses Winapi.Windows, System.Math;

destructor TNimbusLogFileMonitor.Destroy;
begin FDecoder.Free; inherited; end;

procedure TNimbusLogFileMonitor.Start(const APath: string; const AFromEnd: Boolean;
  const AEncoding: TNimbusLogFileEncoding);
begin
  if Trim(APath) = '' then raise EArgumentException.Create('A log file path is required');
  Stop;
  FPath := APath; FFromEnd := AFromEnd; FRequestedEncoding := AEncoding;
  FRunning := True;
end;

procedure TNimbusLogFileMonitor.Stop;
begin
  FRunning := False; FOffset := 0; FIdentity := '';
  FInitialized := False; FHaveInitialSize := False; FInitialSize := 0;
  FEncoding := nlfeAuto;
  FreeAndNil(FDecoder);
end;

procedure TNimbusLogFileMonitor.ProcessBytes(const ABytes: TBytes; const ACount: Integer;
  const AOnLine: TNimbusLogMonitorLineEvent);
var Lines: TArray<string>; Line: string;
begin
  try
    Lines := FDecoder.Feed(ABytes, ACount);
    for Line in Lines do if Assigned(AOnLine) then AOnLine(Line);
  except
    on E: EConvertError do begin FRunning := False; raise; end;
    on E: EReadError do begin FRunning := False; raise; end;
  end;
end;

function TNimbusLogFileMonitor.Poll(const AOnLine: TNimbusLogMonitorLineEvent): Integer;
var
  Handle: THandle;
  Info: TByHandleFileInformation;
  Identity: string;
  Size, Seek, Baseline: Int64;
  ReadCount: DWORD;
  Buffer, Sample: TBytes;
  UnitSize, BOMSize, I: Integer;
  IsNew, SkipFragment, SkipLF: Boolean;
  LastUnit: Cardinal;
begin
  Result := 0;
  if not FRunning then Exit;
  Handle := CreateFile(PChar(FPath), GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE,
    nil, OPEN_EXISTING, FILE_FLAG_SEQUENTIAL_SCAN, 0);
  if Handle = INVALID_HANDLE_VALUE then RaiseLastOSError;
  try
    if not GetFileInformationByHandle(Handle, Info) or not GetFileSizeEx(Handle, Size) then RaiseLastOSError;
    if not FHaveInitialSize then begin FInitialSize := Size; FHaveInitialSize := True; end;
    Identity := IntToHex(Info.dwVolumeSerialNumber, 8) + IntToHex(Info.nFileIndexHigh, 8) + IntToHex(Info.nFileIndexLow, 8);
    IsNew := not FInitialized;
    if IsNew or (FIdentity <> Identity) or (Size < FOffset) then
    begin
      SetLength(Buffer, 4096);
      if not ReadFile(Handle, Buffer[0], Length(Buffer), ReadCount, nil) then RaiseLastOSError;
      Sample := Copy(Buffer, 0, Integer(ReadCount));
      if (FRequestedEncoding = nlfeAuto) and TNimbusLogTextCodec.PartialBOM(Sample) then Exit;
      if (FRequestedEncoding = nlfeAuto) and (Length(Sample) < 4) then Exit;
      try FEncoding := TNimbusLogTextCodec.Detect(Sample, FRequestedEncoding, BOMSize);
      except on E: EConvertError do begin FRunning := False; raise; end; end;
      if (FRequestedEncoding = nlfeAuto) and (BOMSize = 0) and (Length(Sample) < 8) then
        for I := 0 to High(Sample) do if Sample[I] = 0 then Exit;
      UnitSize := TNimbusLogTextCodec.UnitSize(FEncoding);
      if (Size - BOMSize < UnitSize) and (Size > BOMSize) then Exit;
      FOffset := BOMSize; SkipFragment := False; SkipLF := False;
      if IsNew and FFromEnd then
      begin
        Baseline := Max(Int64(BOMSize), Min(FInitialSize, Size));
        FOffset := BOMSize + ((Baseline - BOMSize) div UnitSize) * UnitSize;
        SkipFragment := FOffset <> Baseline;
        if FOffset >= BOMSize + UnitSize then
        begin
          Seek := FOffset - UnitSize;
          if not SetFilePointerEx(Handle, Seek, nil, FILE_BEGIN) then RaiseLastOSError;
          if not ReadFile(Handle, Buffer[0], UnitSize, ReadCount, nil) then RaiseLastOSError;
          if ReadCount = DWORD(UnitSize) then
          begin
            LastUnit := TNimbusLogTextCodec.ReadUnit(Buffer, 0, FEncoding);
            SkipFragment := SkipFragment or not ((LastUnit = 10) or (LastUnit = 13));
            SkipLF := LastUnit = 13;
          end;
        end;
      end;
      FreeAndNil(FDecoder);
      FDecoder := TNimbusLogLineDecoder.Create(FEncoding, SkipLF, SkipFragment);
      FIdentity := Identity; FInitialized := True;
    end;
    Seek := FOffset;
    if not SetFilePointerEx(Handle, Seek, nil, FILE_BEGIN) then RaiseLastOSError;
    SetLength(Buffer, 262144);
    if not ReadFile(Handle, Buffer[0], Length(Buffer), ReadCount, nil) then RaiseLastOSError;
    Inc(FOffset, ReadCount);
    ProcessBytes(Buffer, Integer(ReadCount), AOnLine);
    Result := Integer(ReadCount);
  finally CloseHandle(Handle); end;
end;

end.

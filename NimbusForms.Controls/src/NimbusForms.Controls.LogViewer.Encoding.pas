{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.LogViewer.Encoding;

interface

uses System.SysUtils, NimbusForms.Controls.LogViewer.Types;

type
  TNimbusLogTextCodec = class
  private
    class procedure ValidateText(const AText: string); static;
    class function ValidUTF8(const ABytes: TBytes; const AAllowIncomplete: Boolean): Boolean; static;
  public
    class function Name(const AEncoding: TNimbusLogFileEncoding): string; static;
    class function UnitSize(const AEncoding: TNimbusLogFileEncoding): Integer; static;
    class function ReadUnit(const ABytes: TBytes; const AOffset: Integer; const AEncoding: TNimbusLogFileEncoding): Cardinal; static;
    class function Detect(const ASample: TBytes; const ARequested: TNimbusLogFileEncoding; out ABOMSize: Integer): TNimbusLogFileEncoding; static;
    class function PartialBOM(const ASample: TBytes): Boolean; static;
    class function Preamble(const AEncoding: TNimbusLogFileEncoding): TBytes; static;
    class function Encode(const AText: string; const AEncoding: TNimbusLogFileEncoding): TBytes; static;
    class function Decode(const ABytes: TBytes; const AEncoding: TNimbusLogFileEncoding): string; static;
  end;

  TNimbusLogLineDecoder = class
  private
    FEncoding: TNimbusLogFileEncoding;
    FPending: TBytes;
    FPendingCount, FScanOffset: Integer;
    FSkipLF: Boolean;
    FSkipFirstLine: Boolean;
  public
    constructor Create(const AEncoding: TNimbusLogFileEncoding; const ASkipLF: Boolean = False; const ASkipFirstLine: Boolean = False);
    function Feed(const ABytes: TBytes; const ACount: Integer; const AFinal: Boolean = False): TArray<string>;
  end;

implementation

uses System.Classes, System.Math, System.Generics.Collections;

class function TNimbusLogTextCodec.Name(const AEncoding: TNimbusLogFileEncoding): string;
begin
  case AEncoding of
    nlfeAuto: Result := 'Auto';
    nlfeUTF8: Result := 'UTF-8';
    nlfeUTF16LE: Result := 'UTF-16 LE';
    nlfeUTF16BE: Result := 'UTF-16 BE';
    nlfeUTF32LE: Result := 'UTF-32 LE';
    nlfeUTF32BE: Result := 'UTF-32 BE';
    nlfeASCII: Result := 'ASCII';
    nlfeANSI: Result := 'ANSI (system)';
    nlfeLatin1: Result := 'ISO-8859-1';
    nlfeWindows1252: Result := 'Windows-1252';
  end;
end;

class function TNimbusLogTextCodec.UnitSize(const AEncoding: TNimbusLogFileEncoding): Integer;
begin
  Result := 1;
  if AEncoding in [nlfeUTF16LE, nlfeUTF16BE] then Result := 2
  else if AEncoding in [nlfeUTF32LE, nlfeUTF32BE] then Result := 4;
end;

class function TNimbusLogTextCodec.ReadUnit(const ABytes: TBytes; const AOffset: Integer;
  const AEncoding: TNimbusLogFileEncoding): Cardinal;
var I, Size: Integer;
begin
  Size := UnitSize(AEncoding);
  if (AOffset < 0) or (AOffset > Length(ABytes) - Size) then raise EConvertError.Create('Incomplete encoded character');
  Result := 0;
  for I := 0 to Size - 1 do
    if AEncoding in [nlfeUTF16BE, nlfeUTF32BE] then Result := (Result shl 8) or ABytes[AOffset + I]
    else Result := Result or (Cardinal(ABytes[AOffset + I]) shl (I * 8));
end;

class procedure TNimbusLogTextCodec.ValidateText(const AText: string);
var I, C: Integer;
begin
  I := 1;
  while I <= Length(AText) do
  begin
    C := Ord(AText[I]);
    if (C >= $D800) and (C <= $DBFF) then
    begin
      Inc(I);
      if (I > Length(AText)) or (Ord(AText[I]) < $DC00) or (Ord(AText[I]) > $DFFF) then
        raise EConvertError.Create('Invalid UTF-16 surrogate pair');
    end
    else if (C >= $DC00) and (C <= $DFFF) then raise EConvertError.Create('Unpaired UTF-16 surrogate');
    Inc(I);
  end;
end;

class function TNimbusLogTextCodec.ValidUTF8(const ABytes: TBytes; const AAllowIncomplete: Boolean): Boolean;
var I, J, N: Integer; C, Minimum: Cardinal;
begin
  Result := False; I := 0;
  while I < Length(ABytes) do
  begin
    if ABytes[I] < $80 then begin Inc(I); Continue; end;
    if (ABytes[I] >= $C2) and (ABytes[I] <= $DF) then begin N := 2; C := ABytes[I] and $1F; Minimum := $80; end
    else if (ABytes[I] >= $E0) and (ABytes[I] <= $EF) then begin N := 3; C := ABytes[I] and $0F; Minimum := $800; end
    else if (ABytes[I] >= $F0) and (ABytes[I] <= $F4) then begin N := 4; C := ABytes[I] and $07; Minimum := $10000; end
    else Exit;
    if I + N > Length(ABytes) then
    begin
      for J := I + 1 to High(ABytes) do if (ABytes[J] and $C0) <> $80 then Exit;
      if I + 1 < Length(ABytes) then
      begin
        if (ABytes[I] = $E0) and (ABytes[I + 1] < $A0) then Exit;
        if (ABytes[I] = $ED) and (ABytes[I + 1] > $9F) then Exit;
        if (ABytes[I] = $F0) and (ABytes[I + 1] < $90) then Exit;
        if (ABytes[I] = $F4) and (ABytes[I + 1] > $8F) then Exit;
      end;
      Exit(AAllowIncomplete);
    end;
    for J := 1 to N - 1 do
    begin
      if (ABytes[I + J] and $C0) <> $80 then Exit;
      C := (C shl 6) or (ABytes[I + J] and $3F);
    end;
    if (C < Minimum) or (C > $10FFFF) or ((C >= $D800) and (C <= $DFFF)) then Exit;
    Inc(I, N);
  end;
  Result := True;
end;

class function TNimbusLogTextCodec.PartialBOM(const ASample: TBytes): Boolean;
var P: TBytes; E: TNimbusLogFileEncoding; I: Integer; Same: Boolean;
begin
  Result := False;
  if Length(ASample) = 0 then Exit(True);
  for E := Low(TNimbusLogFileEncoding) to High(TNimbusLogFileEncoding) do
  begin
    P := Preamble(E);
    if Length(ASample) >= Length(P) then Continue;
    Same := True;
    for I := 0 to High(ASample) do if ASample[I] <> P[I] then Same := False;
    if Same then Exit(True);
  end;
end;

class function TNimbusLogTextCodec.Detect(const ASample: TBytes; const ARequested: TNimbusLogFileEncoding;
  out ABOMSize: Integer): TNimbusLogFileEncoding;
var Detected: TNimbusLogFileEncoding; I, Count, LE, BE: Integer;
begin
  ABOMSize := 0; Detected := nlfeAuto;
  if (Length(ASample) >= 4) and (ASample[0] = $FF) and (ASample[1] = $FE) and (ASample[2] = 0) and (ASample[3] = 0) then
  begin Detected := nlfeUTF32LE; ABOMSize := 4; end
  else if (Length(ASample) >= 4) and (ASample[0] = 0) and (ASample[1] = 0) and (ASample[2] = $FE) and (ASample[3] = $FF) then
  begin Detected := nlfeUTF32BE; ABOMSize := 4; end
  else if (Length(ASample) >= 3) and (ASample[0] = $EF) and (ASample[1] = $BB) and (ASample[2] = $BF) then
  begin Detected := nlfeUTF8; ABOMSize := 3; end
  else if (Length(ASample) >= 2) and (ASample[0] = $FF) and (ASample[1] = $FE) then
  begin Detected := nlfeUTF16LE; ABOMSize := 2; end
  else if (Length(ASample) >= 2) and (ASample[0] = $FE) and (ASample[1] = $FF) then
  begin Detected := nlfeUTF16BE; ABOMSize := 2; end;
  if Detected <> nlfeAuto then
  begin
    if (ARequested <> nlfeAuto) and (ARequested <> Detected) then
      raise EConvertError.Create('File BOM is ' + Name(Detected) + ', selected encoding is ' + Name(ARequested));
    Exit(Detected);
  end;
  if ARequested <> nlfeAuto then Exit(ARequested);
  Count := Length(ASample) div 4; LE := 0; BE := 0;
  for I := 0 to Count - 1 do
  begin
    if (ASample[I * 4 + 2] = 0) and (ASample[I * 4 + 3] = 0) then Inc(LE);
    if (ASample[I * 4] = 0) and (ASample[I * 4 + 1] = 0) then Inc(BE);
  end;
  if Count >= 2 then
  begin
    if (LE * 4 >= Count * 3) and (LE > BE) then Exit(nlfeUTF32LE);
    if (BE * 4 >= Count * 3) and (BE > LE) then Exit(nlfeUTF32BE);
  end;
  Count := Length(ASample) div 2; LE := 0; BE := 0;
  for I := 0 to Count - 1 do
  begin
    if (ASample[I * 2 + 1] = 0) and (ASample[I * 2] <> 0) then Inc(LE);
    if (ASample[I * 2] = 0) and (ASample[I * 2 + 1] <> 0) then Inc(BE);
  end;
  if Count >= 2 then
  begin
    if (LE * 3 >= Count) and (LE > BE * 2) then Exit(nlfeUTF16LE);
    if (BE * 3 >= Count) and (BE > LE * 2) then Exit(nlfeUTF16BE);
  end;
  if ValidUTF8(ASample, True) then Result := nlfeUTF8 else Result := nlfeANSI;
end;

class function TNimbusLogTextCodec.Preamble(const AEncoding: TNimbusLogFileEncoding): TBytes;
begin
  case AEncoding of
    nlfeUTF8: Result := TBytes.Create($EF, $BB, $BF);
    nlfeUTF16LE: Result := TBytes.Create($FF, $FE);
    nlfeUTF16BE: Result := TBytes.Create($FE, $FF);
    nlfeUTF32LE: Result := TBytes.Create($FF, $FE, 0, 0);
    nlfeUTF32BE: Result := TBytes.Create(0, 0, $FE, $FF);
  else Result := nil;
  end;
end;

class function TNimbusLogTextCodec.Encode(const AText: string; const AEncoding: TNimbusLogFileEncoding): TBytes;
var I, J, Index: Integer; C: Cardinal; Native: TEncoding;
begin
  ValidateText(AText);
  if AEncoding in [nlfeUTF32LE, nlfeUTF32BE] then
  begin
    if Length(AText) > MaxInt div 4 then raise ERangeError.Create('Text too large');
    SetLength(Result, Length(AText) * 4); I := 1; Index := 0;
    while I <= Length(AText) do
    begin
      C := Ord(AText[I]);
      if (C >= $D800) and (C <= $DBFF) then
      begin Inc(I); C := $10000 + (C - $D800) * $400 + Ord(AText[I]) - $DC00; end;
      for J := 0 to 3 do
        if AEncoding = nlfeUTF32BE then Result[Index + J] := Byte((C shr ((3 - J) * 8)) and $FF)
        else Result[Index + J] := Byte((C shr (J * 8)) and $FF);
      Inc(Index, 4); Inc(I);
    end;
    SetLength(Result, Index); Exit;
  end;
  if AEncoding in [nlfeLatin1, nlfeASCII] then
  begin
    SetLength(Result, Length(AText));
    for I := 1 to Length(AText) do
    begin
      C := Ord(AText[I]);
      if (C > 255) or ((AEncoding = nlfeASCII) and (C > 127)) then
        raise EConvertError.Create('Text cannot be represented in ' + Name(AEncoding));
      Result[I - 1] := Byte(C);
    end;
    Exit;
  end;
  case AEncoding of
    nlfeUTF16LE: Native := TEncoding.Unicode;
    nlfeUTF16BE: Native := TEncoding.BigEndianUnicode;
    nlfeANSI: Native := TEncoding.Default;
    nlfeWindows1252: Native := TEncoding.GetEncoding(1252);
  else Native := TEncoding.UTF8;
  end;
  try
    Result := Native.GetBytes(AText);
    if Native.GetString(Result) <> AText then raise EConvertError.Create('Text cannot be represented in ' + Name(AEncoding));
  finally if AEncoding = nlfeWindows1252 then Native.Free; end;
end;

class function TNimbusLogTextCodec.Decode(const ABytes: TBytes; const AEncoding: TNimbusLogFileEncoding): string;
var I, Index, Size: Integer; C: Cardinal; Native: TEncoding;
begin
  Size := UnitSize(AEncoding);
  if Length(ABytes) mod Size <> 0 then raise EConvertError.Create('Incomplete ' + Name(AEncoding) + ' code unit');
  if AEncoding in [nlfeUTF32LE, nlfeUTF32BE] then
  begin
    SetLength(Result, Length(ABytes) div 2); Index := 1; I := 0;
    while I < Length(ABytes) do
    begin
      C := ReadUnit(ABytes, I, AEncoding);
      if (C > $10FFFF) or ((C >= $D800) and (C <= $DFFF)) then raise EConvertError.Create('Invalid UTF-32 scalar');
      if C <= $FFFF then begin Result[Index] := Char(C); Inc(Index); end
      else
      begin
        Dec(C, $10000); Result[Index] := Char($D800 + (C shr 10));
        Result[Index + 1] := Char($DC00 + (C and $3FF)); Inc(Index, 2);
      end;
      Inc(I, 4);
    end;
    SetLength(Result, Index - 1); Exit;
  end;
  if AEncoding in [nlfeLatin1, nlfeASCII] then
  begin
    SetLength(Result, Length(ABytes));
    for I := 0 to High(ABytes) do
    begin
      if (AEncoding = nlfeASCII) and (ABytes[I] > 127) then raise EConvertError.Create('Invalid ASCII byte');
      Result[I + 1] := Char(ABytes[I]);
    end;
    Exit;
  end;
  if (AEncoding in [nlfeUTF8, nlfeAuto]) and not ValidUTF8(ABytes, False) then
    raise EConvertError.Create('Invalid UTF-8 sequence; select the correct file encoding');
  if AEncoding in [nlfeUTF16LE, nlfeUTF16BE] then
  begin
    SetLength(Result, Length(ABytes) div 2);
    for I := 1 to Length(Result) do Result[I] := Char(ReadUnit(ABytes, (I - 1) * 2, AEncoding));
    ValidateText(Result);
    Exit;
  end;
  case AEncoding of
    nlfeUTF16LE: Native := TEncoding.Unicode;
    nlfeUTF16BE: Native := TEncoding.BigEndianUnicode;
    nlfeANSI: Native := TEncoding.Default;
    nlfeWindows1252: Native := TEncoding.GetEncoding(1252);
  else Native := TEncoding.UTF8;
  end;
  try Result := Native.GetString(ABytes); finally if AEncoding = nlfeWindows1252 then Native.Free; end;
  ValidateText(Result);
end;

constructor TNimbusLogLineDecoder.Create(const AEncoding: TNimbusLogFileEncoding; const ASkipLF, ASkipFirstLine: Boolean);
begin inherited Create; FEncoding := AEncoding; FSkipLF := ASkipLF; FSkipFirstLine := ASkipFirstLine; end;

function TNimbusLogLineDecoder.Feed(const ABytes: TBytes; const ACount: Integer;
  const AFinal: Boolean): TArray<string>;
var Lines: TList<string>; I, Start, Size, Old, Needed, Capacity: Integer; C: Cardinal;
begin
  if (ACount < 0) or (ACount > Length(ABytes)) then raise EArgumentOutOfRangeException.Create('Byte count');
  Old := FPendingCount;
  if Old > 67108864 - ACount then raise EReadError.Create('An encoded log record exceeds 64 MB');
  Needed := Old + ACount;
  if Needed > Length(FPending) then
  begin
    Capacity := Max(4096, Length(FPending));
    while Capacity < Needed do Capacity := Min(67108864, Capacity * 2);
    SetLength(FPending, Capacity);
  end;
  if ACount > 0 then Move(ABytes[0], FPending[Old], ACount);
  FPendingCount := Needed;
  Lines := TList<string>.Create;
  try
    Size := TNimbusLogTextCodec.UnitSize(FEncoding); I := FScanOffset; Start := 0;
    while I + Size <= FPendingCount do
    begin
      C := TNimbusLogTextCodec.ReadUnit(FPending, I, FEncoding);
      if FSkipLF and (C = 10) then begin FSkipLF := False; Inc(I, Size); Start := I; Continue; end;
      FSkipLF := False;
      if (C = 10) or (C = 13) then
      begin
        if FSkipFirstLine then FSkipFirstLine := False
        else Lines.Add(TNimbusLogTextCodec.Decode(Copy(FPending, Start, I - Start), FEncoding));
        FSkipLF := C = 13; Inc(I, Size); Start := I;
      end
      else Inc(I, Size);
    end;
    FScanOffset := I - Start;
    if Start > 0 then
    begin
      Dec(FPendingCount, Start);
      if FPendingCount > 0 then Move(FPending[Start], FPending[0], FPendingCount);
    end;
    if AFinal and (FPendingCount > 0) and not FSkipFirstLine then
    begin
      Lines.Add(TNimbusLogTextCodec.Decode(Copy(FPending, 0, FPendingCount), FEncoding));
      FPendingCount := 0; FScanOffset := 0;
    end;
    Result := Lines.ToArray;
  finally Lines.Free; end;
end;

end.

unit NimbusForms.HexEditor.Clipboard;

interface

uses
  System.SysUtils;

type
  THexClipboard = class
  public
    class procedure WriteBytes(const ABytes: TBytes); static;
    class function TryReadBytes(out ABytes: TBytes): Boolean; static;
  end;

implementation

uses
  Winapi.Windows, Vcl.Forms, NimbusForms.HexEditor.Export;

function RawFormat: UINT;
begin
  Result := RegisterClipboardFormat('NimbusForms.VCL.HexEditor.RawBytes.v1');
end;

procedure PutData(const AFormat: UINT; const AData: TBytes);
var
  LHandle: HGLOBAL;
  LPointer: Pointer;
begin
  LHandle := GlobalAlloc(GMEM_MOVEABLE or GMEM_ZEROINIT, Length(AData));
  if LHandle = 0 then RaiseLastOSError;
  try
    LPointer := GlobalLock(LHandle);
    if LPointer = nil then RaiseLastOSError;
    try
      if Length(AData) > 0 then Move(AData[0], LPointer^, Length(AData));
    finally
      GlobalUnlock(LHandle);
    end;
    if SetClipboardData(AFormat, LHandle) = 0 then RaiseLastOSError;
    LHandle := 0;
  finally
    if LHandle <> 0 then GlobalFree(LHandle);
  end;
end;

class procedure THexClipboard.WriteBytes(const ABytes: TBytes);
var
  LRaw, LText: TBytes;
  LLength: UInt64;
begin
  if Length(ABytes) > MaxInt - SizeOf(UInt64) then raise ERangeError.Create('Clipboard data is too large');
  LLength := Length(ABytes);
  SetLength(LRaw, Length(ABytes) + SizeOf(UInt64));
  Move(LLength, LRaw[0], SizeOf(UInt64));
  if Length(ABytes) > 0 then Move(ABytes[0], LRaw[SizeOf(UInt64)], Length(ABytes));
  LText := TEncoding.Unicode.GetBytes(THexExporter.ToPlainHex(ABytes) + #0);
  if not OpenClipboard(Application.Handle) then RaiseLastOSError;
  try
    if not EmptyClipboard then RaiseLastOSError;
    PutData(CF_UNICODETEXT, LText);
    PutData(RawFormat, LRaw);
  finally
    CloseClipboard;
  end;
end;

class function THexClipboard.TryReadBytes(out ABytes: TBytes): Boolean;
var
  LHandle: HGLOBAL;
  LPointer: Pointer;
  LLength: UInt64;
  LSize: NativeUInt;
begin
  ABytes := nil;
  Result := False;
  if not IsClipboardFormatAvailable(RawFormat) then Exit;
  if not OpenClipboard(Application.Handle) then RaiseLastOSError;
  try
    LHandle := GetClipboardData(RawFormat);
    if LHandle = 0 then RaiseLastOSError;
    LSize := GlobalSize(LHandle);
    if LSize < SizeOf(UInt64) then raise EConvertError.Create('Invalid raw clipboard data');
    LPointer := GlobalLock(LHandle);
    if LPointer = nil then RaiseLastOSError;
    try
      Move(LPointer^, LLength, SizeOf(UInt64));
      if (LLength > MaxInt) or (LLength > LSize - SizeOf(UInt64)) then
        raise EConvertError.Create('Invalid raw clipboard length');
      SetLength(ABytes, Integer(LLength));
      if LLength > 0 then Move(PByte(NativeUInt(LPointer) + SizeOf(UInt64))^, ABytes[0], Integer(LLength));
      Result := True;
    finally
      GlobalUnlock(LHandle);
    end;
  finally
    CloseClipboard;
  end;
end;

end.

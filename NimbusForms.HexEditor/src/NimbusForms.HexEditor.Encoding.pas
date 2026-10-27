unit NimbusForms.HexEditor.Encoding;

interface

uses
  System.SysUtils;

type
  THexTextEncoding = class
  private
    FName: string;
  public
    constructor Create(const AName: string = 'UTF-8');
    procedure SetName(const AName: string);
    function GetBytes(const AText: string): TBytes;
    function GetString(const ABytes: TBytes): string;
    class function Encode(const AText, AName: string): TBytes; static;
    class function Decode(const ABytes: TBytes; const AName: string): string; static;
    property Name: string read FName;
  end;

implementation

constructor THexTextEncoding.Create(const AName: string);
begin
  inherited Create;
  SetName(AName);
end;

procedure THexTextEncoding.SetName(const AName: string);
begin
  if SameText(AName, 'UTF-8') then FName := 'UTF-8'
  else if SameText(AName, 'UTF-16LE') then FName := 'UTF-16LE'
  else if SameText(AName, 'UTF-16BE') then FName := 'UTF-16BE'
  else if SameText(AName, 'UTF-32') or SameText(AName, 'UTF-32LE') then FName := 'UTF-32LE'
  else if SameText(AName, 'UTF-32BE') then FName := 'UTF-32BE'
  else if SameText(AName, 'ISO-8859-1') then FName := 'ISO-8859-1'
  else if SameText(AName, 'ASCII') then FName := 'ASCII'
  else if SameText(AName, 'ANSI') then FName := 'ANSI'
  else raise EArgumentException.Create('Unsupported text encoding: ' + AName);
end;

function THexTextEncoding.GetBytes(const AText: string): TBytes;
begin
  Result := Encode(AText, FName);
end;

function THexTextEncoding.GetString(const ABytes: TBytes): string;
begin
  Result := Decode(ABytes, FName);
end;

class function THexTextEncoding.Encode(const AText, AName: string): TBytes;
var
  I, J, LIndex: Integer;
  LPoint: Cardinal;
  LBigEndian: Boolean;
begin
  if SameText(AName, 'UTF-8') then Exit(TEncoding.UTF8.GetBytes(AText));
  if SameText(AName, 'UTF-16LE') then Exit(TEncoding.Unicode.GetBytes(AText));
  if SameText(AName, 'UTF-16BE') then Exit(TEncoding.BigEndianUnicode.GetBytes(AText));
  if SameText(AName, 'ASCII') then Exit(TEncoding.ASCII.GetBytes(AText));
  if SameText(AName, 'ANSI') then Exit(TEncoding.ANSI.GetBytes(AText));
  if SameText(AName, 'ISO-8859-1') then
  begin
    SetLength(Result, Length(AText));
    for I := 1 to Length(AText) do
      if Ord(AText[I]) <= 255 then Result[I - 1] := Byte(Ord(AText[I])) else Result[I - 1] := Ord('?');
    Exit;
  end;
  if not SameText(AName, 'UTF-32LE') and not SameText(AName, 'UTF-32BE') and not SameText(AName, 'UTF-32') then
    raise EArgumentException.Create('Unknown encoding');
  if Length(AText) > MaxInt div 4 then raise ERangeError.Create('Text is too large');
  SetLength(Result, Length(AText) * 4);
  LBigEndian := SameText(AName, 'UTF-32BE');
  LIndex := 0;
  I := 1;
  while I <= Length(AText) do
  begin
    LPoint := Ord(AText[I]);
    if (LPoint >= $D800) and (LPoint <= $DBFF) and (I < Length(AText)) and
      (Ord(AText[I + 1]) >= $DC00) and (Ord(AText[I + 1]) <= $DFFF) then
    begin
      LPoint := $10000 + (LPoint - $D800) * $400 + Ord(AText[I + 1]) - $DC00;
      Inc(I);
    end
    else if (LPoint >= $D800) and (LPoint <= $DFFF) then LPoint := $FFFD;
    for J := 0 to 3 do
      if LBigEndian then Result[LIndex + J] := Byte((LPoint shr ((3 - J) * 8)) and $FF)
      else Result[LIndex + J] := Byte((LPoint shr (J * 8)) and $FF);
    Inc(LIndex, 4);
    Inc(I);
  end;
  SetLength(Result, LIndex);
end;

class function THexTextEncoding.Decode(const ABytes: TBytes; const AName: string): string;
var
  I, J: Integer;
  LPoint: Cardinal;
  LBigEndian: Boolean;
  LBuilder: TStringBuilder;
begin
  if SameText(AName, 'UTF-8') then Exit(TEncoding.UTF8.GetString(ABytes));
  if SameText(AName, 'UTF-16LE') then Exit(TEncoding.Unicode.GetString(ABytes));
  if SameText(AName, 'UTF-16BE') then Exit(TEncoding.BigEndianUnicode.GetString(ABytes));
  if SameText(AName, 'ASCII') then Exit(TEncoding.ASCII.GetString(ABytes));
  if SameText(AName, 'ANSI') then Exit(TEncoding.ANSI.GetString(ABytes));
  if SameText(AName, 'ISO-8859-1') then
  begin
    SetLength(Result, Length(ABytes));
    for I := 0 to High(ABytes) do Result[I + 1] := Char(ABytes[I]);
    Exit;
  end;
  if not SameText(AName, 'UTF-32LE') and not SameText(AName, 'UTF-32BE') and not SameText(AName, 'UTF-32') then
    raise EArgumentException.Create('Unknown encoding');
  LBuilder := TStringBuilder.Create;
  try
    LBigEndian := SameText(AName, 'UTF-32BE');
    I := 0;
    while I + 3 < Length(ABytes) do
    begin
      LPoint := 0;
      for J := 0 to 3 do
        if LBigEndian then LPoint := (LPoint shl 8) or ABytes[I + J]
        else LPoint := LPoint or (Cardinal(ABytes[I + J]) shl (J * 8));
      if (LPoint > $10FFFF) or ((LPoint >= $D800) and (LPoint <= $DFFF)) then LPoint := $FFFD;
      if LPoint <= $FFFF then LBuilder.Append(Char(LPoint))
      else
      begin
        Dec(LPoint, $10000);
        LBuilder.Append(Char($D800 + (LPoint shr 10)));
        LBuilder.Append(Char($DC00 + (LPoint and $3FF)));
      end;
      Inc(I, 4);
    end;
    if I < Length(ABytes) then LBuilder.Append(Char($FFFD));
    Result := LBuilder.ToString;
  finally
    LBuilder.Free;
  end;
end;

end.

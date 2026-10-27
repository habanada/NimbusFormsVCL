unit NimbusForms.HexEditor.Export;

interface

uses
  System.SysUtils;

type
  THexExporter = class
  public
    class function ToCSharpArray(const AData: TBytes; const AName: string = 'rawData'): string; static;
    class function ToCSharpReadOnlyArray(const AData: TBytes; const AName: string = 'rawData'): string; static;
    class function ToTextDump(const AData: TBytes; const AStartOffset: Int64; const ABytesPerRow: Integer = 16): string; static;
    class function ToHtmlTable(const AData: TBytes; const AStartOffset: Int64; const ABytesPerRow: Integer = 16): string; static;
    class function ToJsonArray(const AData: TBytes): string; static;
    class function ToBase64(const AData: TBytes): string; static;
    class function ToSqlVarBinary(const AData: TBytes): string; static;
    class function ToPlainHex(const AData: TBytes): string; static;
    class function ToAscii(const AData: TBytes): string; static;
  end;

implementation

uses
  System.Math,
  System.NetEncoding;

const
  CDefaultBytesPerRow = 16;
  CCSharpBytesPerLine = 12;
  CJsonBytesPerLine = 16;

function NormalizeBytesPerRow(const ABytesPerRow: Integer): Integer;
begin
  if ABytesPerRow < 1 then
    Exit(CDefaultBytesPerRow);
  if ABytesPerRow > 64 then
    Exit(64);
  Result := ABytesPerRow;
end;

function ToAsciiChar(const AValue: Byte): Char;
begin
  if (AValue >= 32) and (AValue <= 126) then
    Result := Char(AValue)
  else
    Result := '.';
end;

function NormalizeIdentifier(const AValue, AFallback: string): string;
var
  LBuilder: TStringBuilder;
  I: Integer;
  C: Char;
begin
  if AValue = '' then
    Exit(AFallback);
  LBuilder := TStringBuilder.Create;
  try
    for I := 1 to Length(AValue) do
    begin
      C := AValue[I];
      if I = 1 then
      begin
        if CharInSet(C, ['A'..'Z', 'a'..'z', '_']) then
          LBuilder.Append(C)
        else
          LBuilder.Append('_');
        Continue;
      end;
      if CharInSet(C, ['A'..'Z', 'a'..'z', '0'..'9', '_']) then
        LBuilder.Append(C)
      else
        LBuilder.Append('_');
    end;
    if LBuilder.Length = 0 then
      Exit(AFallback);
    Result := LBuilder.ToString;
  finally
    LBuilder.Free;
  end;
end;

function HtmlEncode(const AValue: string): string;
var
  LBuilder: TStringBuilder;
  I: Integer;
  C: Char;
begin
  if AValue = '' then
    Exit('');
  LBuilder := TStringBuilder.Create;
  try
    for I := 1 to Length(AValue) do
    begin
      C := AValue[I];
      case C of
        '&': LBuilder.Append('&amp;');
        '<': LBuilder.Append('&lt;');
        '>': LBuilder.Append('&gt;');
        '"': LBuilder.Append('&quot;');
        '''': LBuilder.Append('&#39;');
      else
        LBuilder.Append(C);
      end;
    end;
    Result := LBuilder.ToString;
  finally
    LBuilder.Free;
  end;
end;

class function THexExporter.ToCSharpArray(const AData: TBytes; const AName: string): string;
var
  LName: string;
  LBuilder: TStringBuilder;
  I: Integer;
begin
  LName := NormalizeIdentifier(AName, 'rawData');
  if Length(AData) = 0 then
    Exit('byte[] ' + LName + ' = new byte[0];');
  LBuilder := TStringBuilder.Create;
  try
    LBuilder.Append('byte[] ').Append(LName).AppendLine(' = new byte[]');
    LBuilder.AppendLine('{');
    for I := 0 to High(AData) do
    begin
      if I mod CCSharpBytesPerLine = 0 then
        LBuilder.Append('    ');
      LBuilder.Append('0x').Append(IntToHex(AData[I], 2));
      if I < High(AData) then
        LBuilder.Append(', ');
      if ((I + 1) mod CCSharpBytesPerLine = 0) or (I = High(AData)) then
        LBuilder.AppendLine;
    end;
    LBuilder.AppendLine('};');
    Result := LBuilder.ToString;
  finally
    LBuilder.Free;
  end;
end;

class function THexExporter.ToCSharpReadOnlyArray(const AData: TBytes; const AName: string): string;
var
  LName: string;
  LBuilder: TStringBuilder;
  I: Integer;
begin
  LName := NormalizeIdentifier(AName, 'rawData');
  if Length(AData) = 0 then
    Exit('private static readonly byte[] ' + LName + ' = new byte[0];');
  LBuilder := TStringBuilder.Create;
  try
    LBuilder.Append('private static readonly byte[] ').Append(LName).AppendLine(' =');
    LBuilder.AppendLine('{');
    for I := 0 to High(AData) do
    begin
      if I mod CCSharpBytesPerLine = 0 then
        LBuilder.Append('    ');
      LBuilder.Append('0x').Append(IntToHex(AData[I], 2));
      if I < High(AData) then
        LBuilder.Append(', ');
      if ((I + 1) mod CCSharpBytesPerLine = 0) or (I = High(AData)) then
        LBuilder.AppendLine;
    end;
    LBuilder.AppendLine('};');
    Result := LBuilder.ToString;
  finally
    LBuilder.Free;
  end;
end;

class function THexExporter.ToTextDump(const AData: TBytes; const AStartOffset: Int64; const ABytesPerRow: Integer): string;
var
  LBuilder: TStringBuilder;
  LBytesPerRow, LChunk, I, J: Integer;
begin
  if Length(AData) = 0 then
    Exit('');
  LBytesPerRow := NormalizeBytesPerRow(ABytesPerRow);
  LBuilder := TStringBuilder.Create;
  try
    I := 0;
    while I < Length(AData) do
    begin
      LChunk := Min(LBytesPerRow, Length(AData) - I);
      LBuilder.Append(IntToHex(AStartOffset + I, 8)).Append('  ');
      for J := 0 to LBytesPerRow - 1 do
      begin
        if J < LChunk then
          LBuilder.Append(IntToHex(AData[I + J], 2)).Append(' ')
        else
          LBuilder.Append('   ');
        if J = 7 then
          LBuilder.Append(' ');
      end;
      LBuilder.Append(' |');
      for J := 0 to LChunk - 1 do
        LBuilder.Append(ToAsciiChar(AData[I + J]));
      LBuilder.AppendLine('|');
      Inc(I, LBytesPerRow);
    end;
    Result := LBuilder.ToString;
  finally
    LBuilder.Free;
  end;
end;

class function THexExporter.ToHtmlTable(const AData: TBytes; const AStartOffset: Int64; const ABytesPerRow: Integer): string;
var
  LBuilder: TStringBuilder;
  LBytesPerRow, LChunk, I, J: Integer;
begin
  if Length(AData) = 0 then
    Exit('<p>No data</p>');
  LBytesPerRow := NormalizeBytesPerRow(ABytesPerRow);
  LBuilder := TStringBuilder.Create;
  try
    LBuilder.AppendLine('<table style="font-family: Consolas, ''Courier New'', monospace; border-collapse: collapse; font-size: 12px;">');
    LBuilder.AppendLine('<thead>');
    LBuilder.AppendLine('<tr style="background: #f0f0f0;"><th style="border: 1px solid #c8c8c8; padding: 4px 8px; text-align: left;">Offset</th><th style="border: 1px solid #c8c8c8; padding: 4px 8px; text-align: left;">Hex</th><th style="border: 1px solid #c8c8c8; padding: 4px 8px; text-align: left;">ASCII</th></tr>');
    LBuilder.AppendLine('</thead>');
    LBuilder.AppendLine('<tbody>');
    I := 0;
    while I < Length(AData) do
    begin
      LChunk := Min(LBytesPerRow, Length(AData) - I);
      LBuilder.Append('<tr>');
      LBuilder.Append('<td style="border: 1px solid #d8d8d8; padding: 4px 8px; white-space: nowrap;">');
      LBuilder.Append(HtmlEncode(IntToHex(AStartOffset + I, 8)));
      LBuilder.Append('</td>');
      LBuilder.Append('<td style="border: 1px solid #d8d8d8; padding: 4px 8px; white-space: nowrap;">');
      for J := 0 to LChunk - 1 do
      begin
        if J > 0 then
          LBuilder.Append(' ');
        LBuilder.Append(IntToHex(AData[I + J], 2));
      end;
      LBuilder.Append('</td>');
      LBuilder.Append('<td style="border: 1px solid #d8d8d8; padding: 4px 8px; white-space: nowrap;">');
      for J := 0 to LChunk - 1 do
        LBuilder.Append(HtmlEncode(ToAsciiChar(AData[I + J])));
      LBuilder.Append('</td>');
      LBuilder.AppendLine('</tr>');
      Inc(I, LBytesPerRow);
    end;
    LBuilder.AppendLine('</tbody>');
    LBuilder.AppendLine('</table>');
    Result := LBuilder.ToString;
  finally
    LBuilder.Free;
  end;
end;

class function THexExporter.ToJsonArray(const AData: TBytes): string;
var
  LBuilder: TStringBuilder;
  I: Integer;
begin
  if Length(AData) = 0 then
    Exit('[]');
  LBuilder := TStringBuilder.Create;
  try
    LBuilder.AppendLine('[');
    for I := 0 to High(AData) do
    begin
      if I mod CJsonBytesPerLine = 0 then
        LBuilder.Append('  ');
      LBuilder.Append(IntToStr(AData[I]));
      if I < High(AData) then
        LBuilder.Append(', ');
      if ((I + 1) mod CJsonBytesPerLine = 0) or (I = High(AData)) then
        LBuilder.AppendLine;
    end;
    LBuilder.Append(']');
    Result := LBuilder.ToString;
  finally
    LBuilder.Free;
  end;
end;

class function THexExporter.ToBase64(const AData: TBytes): string;
var
  LEncoding: TBase64Encoding;
begin
  if Length(AData) = 0 then
    Exit('');
  LEncoding := TBase64Encoding.Create(0);
  try
    Result := LEncoding.EncodeBytesToString(AData);
  finally
    LEncoding.Free;
  end;
end;

class function THexExporter.ToSqlVarBinary(const AData: TBytes): string;
var
  LBuilder: TStringBuilder;
  I: Integer;
begin
  if Length(AData) = 0 then
    Exit('0x');
  LBuilder := TStringBuilder.Create;
  try
    LBuilder.Append('0x');
    for I := 0 to High(AData) do
      LBuilder.Append(IntToHex(AData[I], 2));
    Result := LBuilder.ToString;
  finally
    LBuilder.Free;
  end;
end;

class function THexExporter.ToPlainHex(const AData: TBytes): string;
var
  LBuilder: TStringBuilder;
  I: Integer;
begin
  if Length(AData) = 0 then
    Exit('');
  LBuilder := TStringBuilder.Create;
  try
    for I := 0 to High(AData) do
    begin
      if I > 0 then
        LBuilder.Append(' ');
      LBuilder.Append(IntToHex(AData[I], 2));
    end;
    Result := LBuilder.ToString;
  finally
    LBuilder.Free;
  end;
end;

class function THexExporter.ToAscii(const AData: TBytes): string;
var
  LBuilder: TStringBuilder;
  I: Integer;
begin
  if Length(AData) = 0 then
    Exit('');
  LBuilder := TStringBuilder.Create;
  try
    for I := 0 to High(AData) do
      LBuilder.Append(ToAsciiChar(AData[I]));
    Result := LBuilder.ToString;
  finally
    LBuilder.Free;
  end;
end;

end.

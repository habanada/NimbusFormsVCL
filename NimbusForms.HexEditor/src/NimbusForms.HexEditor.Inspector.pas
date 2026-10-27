unit NimbusForms.HexEditor.Inspector;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  NimbusForms.HexEditor.DataSource;

type
  TInspectorRow = record
    Name: string;
    Value: string;
  end;

  THexDataInspector = class
  public
    class function Inspect(const ADataSource: IHexDataSource; const AOffset: Int64;
      const ABigEndian: Boolean): TArray<TInspectorRow>; static;
  end;

implementation

const
  CInspectorStrings: array[0..11] of string = (
    'Int8', 'UInt8', 'Int16', 'UInt16', 'Int32', 'UInt32',
    'Int64', 'UInt64', 'Float32', 'Float64', 'Char', 'Binary');

function ReadBytes(const ADataSource: IHexDataSource; const AOffset: Int64;
  const ACount: Integer; const ABigEndian: Boolean; out ABytes: TBytes): Boolean;
var
  I: Integer;
  LTemp: Byte;
begin
  SetLength(ABytes, ACount);
  if (ADataSource = nil) or (AOffset < 0) or (AOffset + ACount > ADataSource.Length) then
    Exit(False);
  if ADataSource.Read(AOffset, ABytes, ACount) <> ACount then
    Exit(False);
  if ABigEndian then
    for I := 0 to (ACount div 2) - 1 do
    begin
      LTemp := ABytes[I];
      ABytes[I] := ABytes[ACount - 1 - I];
      ABytes[ACount - 1 - I] := LTemp;
    end;
  Result := True;
end;

function BinaryString(const AValue: Byte): string;
var
  I: Integer;
begin
  Result := '';
  for I := 7 downto 0 do
    if (AValue shr I) and 1 = 1 then
      Result := Result + '1'
    else
      Result := Result + '0';
end;

class function THexDataInspector.Inspect(const ADataSource: IHexDataSource;
  const AOffset: Int64; const ABigEndian: Boolean): TArray<TInspectorRow>;
var
  LRows: TList<TInspectorRow>;
  LBytes: TBytes;

  procedure AddRow(const AName, AValue: string);
  var
    LRow: TInspectorRow;
  begin
    LRow.Name := AName;
    LRow.Value := AValue;
    LRows.Add(LRow);
  end;

var
  LI8: Int8;
  LU8: UInt8;
  LI16: Int16;
  LU16: UInt16;
  LI32: Int32;
  LU32: UInt32;
  LI64: Int64;
  LU64: UInt64;
  LF32: Single;
  LF64: Double;
begin
  LRows := TList<TInspectorRow>.Create;
  try
    if ReadBytes(ADataSource, AOffset, 1, ABigEndian, LBytes) then
    begin
      LI8 := Int8(LBytes[0]);
      LU8 := LBytes[0];
      AddRow(CInspectorStrings[0], IntToStr(LI8));
      AddRow(CInspectorStrings[1], IntToStr(LU8));
      if (LBytes[0] >= 32) and (LBytes[0] <= 126) then
        AddRow(CInspectorStrings[10], Char(LBytes[0]))
      else
        AddRow(CInspectorStrings[10], '.');
      AddRow(CInspectorStrings[11], BinaryString(LBytes[0]));
    end
    else
    begin
      AddRow(CInspectorStrings[0], '-');
      AddRow(CInspectorStrings[1], '-');
      AddRow(CInspectorStrings[10], '-');
      AddRow(CInspectorStrings[11], '-');
    end;

    if ReadBytes(ADataSource, AOffset, 2, ABigEndian, LBytes) then
    begin
      Move(LBytes[0], LI16, 2);
      Move(LBytes[0], LU16, 2);
      AddRow(CInspectorStrings[2], IntToStr(LI16));
      AddRow(CInspectorStrings[3], IntToStr(LU16));
    end
    else
    begin
      AddRow(CInspectorStrings[2], '-');
      AddRow(CInspectorStrings[3], '-');
    end;

    if ReadBytes(ADataSource, AOffset, 4, ABigEndian, LBytes) then
    begin
      Move(LBytes[0], LI32, 4);
      Move(LBytes[0], LU32, 4);
      Move(LBytes[0], LF32, 4);
      AddRow(CInspectorStrings[4], IntToStr(LI32));
      AddRow(CInspectorStrings[5], UIntToStr(LU32));
      AddRow(CInspectorStrings[8], FloatToStrF(LF32, ffGeneral, 7, 0));
    end
    else
    begin
      AddRow(CInspectorStrings[4], '-');
      AddRow(CInspectorStrings[5], '-');
      AddRow(CInspectorStrings[8], '-');
    end;

    if ReadBytes(ADataSource, AOffset, 8, ABigEndian, LBytes) then
    begin
      Move(LBytes[0], LI64, 8);
      Move(LBytes[0], LU64, 8);
      Move(LBytes[0], LF64, 8);
      AddRow(CInspectorStrings[6], IntToStr(LI64));
      AddRow(CInspectorStrings[7], UIntToStr(LU64));
      AddRow(CInspectorStrings[9], FloatToStrF(LF64, ffGeneral, 15, 0));
    end
    else
    begin
      AddRow(CInspectorStrings[6], '-');
      AddRow(CInspectorStrings[7], '-');
      AddRow(CInspectorStrings[9], '-');
    end;

    Result := LRows.ToArray;
  finally
    LRows.Free;
  end;
end;

end.

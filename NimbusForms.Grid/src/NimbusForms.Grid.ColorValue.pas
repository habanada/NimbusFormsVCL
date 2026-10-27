unit NimbusForms.Grid.ColorValue;

interface

uses
  System.TypInfo,
  System.SysUtils,
  System.Rtti,
  NimbusForms.Theming.Types;

type
  TThemedGridColorValue = class
  public
    const
      HexPrefix = '#';
      EmptyColorText = '';
    class function TryParse(const AText: string; out AResult: TThemeColor): Boolean; static;
    class function Format(const AColor: TThemeColor): string; static;
    class function IsEmpty(const AColor: TThemeColor): Boolean; static;
    class function TryGetName(const AColor: TThemeColor; out AName: string): Boolean; static;
    class function TryGetColor(const AValue: TValue; out AResult: TThemeColor): Boolean; static;
    class function TryFromName(const AName: string; out AResult: TThemeColor): Boolean; static;
  end;

implementation

type
  TNamedColor = record
    Name: string;
    Value: TThemeColor;
  end;

const
  CNamedColors: array[0..140] of TNamedColor = (
    (Name: 'AliceBlue'; Value: $FFF0F8FF),
    (Name: 'AntiqueWhite'; Value: $FFFAEBD7),
    (Name: 'Aqua'; Value: $FF00FFFF),
    (Name: 'Aquamarine'; Value: $FF7FFFD4),
    (Name: 'Azure'; Value: $FFF0FFFF),
    (Name: 'Beige'; Value: $FFF5F5DC),
    (Name: 'Bisque'; Value: $FFFFE4C4),
    (Name: 'Black'; Value: $FF000000),
    (Name: 'BlanchedAlmond'; Value: $FFFFEBCD),
    (Name: 'Blue'; Value: $FF0000FF),
    (Name: 'BlueViolet'; Value: $FF8A2BE2),
    (Name: 'Brown'; Value: $FFA52A2A),
    (Name: 'BurlyWood'; Value: $FFDEB887),
    (Name: 'CadetBlue'; Value: $FF5F9EA0),
    (Name: 'Chartreuse'; Value: $FF7FFF00),
    (Name: 'Chocolate'; Value: $FFD2691E),
    (Name: 'Coral'; Value: $FFFF7F50),
    (Name: 'CornflowerBlue'; Value: $FF6495ED),
    (Name: 'Cornsilk'; Value: $FFFFF8DC),
    (Name: 'Crimson'; Value: $FFDC143C),
    (Name: 'Cyan'; Value: $FF00FFFF),
    (Name: 'DarkBlue'; Value: $FF00008B),
    (Name: 'DarkCyan'; Value: $FF008B8B),
    (Name: 'DarkGoldenrod'; Value: $FFB8860B),
    (Name: 'DarkGray'; Value: $FFA9A9A9),
    (Name: 'DarkGreen'; Value: $FF006400),
    (Name: 'DarkKhaki'; Value: $FFBDB76B),
    (Name: 'DarkMagenta'; Value: $FF8B008B),
    (Name: 'DarkOliveGreen'; Value: $FF556B2F),
    (Name: 'DarkOrange'; Value: $FFFF8C00),
    (Name: 'DarkOrchid'; Value: $FF9932CC),
    (Name: 'DarkRed'; Value: $FF8B0000),
    (Name: 'DarkSalmon'; Value: $FFE9967A),
    (Name: 'DarkSeaGreen'; Value: $FF8FBC8B),
    (Name: 'DarkSlateBlue'; Value: $FF483D8B),
    (Name: 'DarkSlateGray'; Value: $FF2F4F4F),
    (Name: 'DarkTurquoise'; Value: $FF00CED1),
    (Name: 'DarkViolet'; Value: $FF9400D3),
    (Name: 'DeepPink'; Value: $FFFF1493),
    (Name: 'DeepSkyBlue'; Value: $FF00BFFF),
    (Name: 'DimGray'; Value: $FF696969),
    (Name: 'DodgerBlue'; Value: $FF1E90FF),
    (Name: 'Firebrick'; Value: $FFB22222),
    (Name: 'FloralWhite'; Value: $FFFFFAF0),
    (Name: 'ForestGreen'; Value: $FF228B22),
    (Name: 'Fuchsia'; Value: $FFFF00FF),
    (Name: 'Gainsboro'; Value: $FFDCDCDC),
    (Name: 'GhostWhite'; Value: $FFF8F8FF),
    (Name: 'Gold'; Value: $FFFFD700),
    (Name: 'Goldenrod'; Value: $FFDAA520),
    (Name: 'Gray'; Value: $FF808080),
    (Name: 'Green'; Value: $FF008000),
    (Name: 'GreenYellow'; Value: $FFADFF2F),
    (Name: 'Honeydew'; Value: $FFF0FFF0),
    (Name: 'HotPink'; Value: $FFFF69B4),
    (Name: 'IndianRed'; Value: $FFCD5C5C),
    (Name: 'Indigo'; Value: $FF4B0082),
    (Name: 'Ivory'; Value: $FFFFFFF0),
    (Name: 'Khaki'; Value: $FFF0E68C),
    (Name: 'Lavender'; Value: $FFE6E6FA),
    (Name: 'LavenderBlush'; Value: $FFFFF0F5),
    (Name: 'LawnGreen'; Value: $FF7CFC00),
    (Name: 'LemonChiffon'; Value: $FFFFFACD),
    (Name: 'LightBlue'; Value: $FFADD8E6),
    (Name: 'LightCoral'; Value: $FFF08080),
    (Name: 'LightCyan'; Value: $FFE0FFFF),
    (Name: 'LightGoldenrodYellow'; Value: $FFFAFAD2),
    (Name: 'LightGray'; Value: $FFD3D3D3),
    (Name: 'LightGreen'; Value: $FF90EE90),
    (Name: 'LightPink'; Value: $FFFFB6C1),
    (Name: 'LightSalmon'; Value: $FFFFA07A),
    (Name: 'LightSeaGreen'; Value: $FF20B2AA),
    (Name: 'LightSkyBlue'; Value: $FF87CEFA),
    (Name: 'LightSlateGray'; Value: $FF778899),
    (Name: 'LightSteelBlue'; Value: $FFB0C4DE),
    (Name: 'LightYellow'; Value: $FFFFFFE0),
    (Name: 'Lime'; Value: $FF00FF00),
    (Name: 'LimeGreen'; Value: $FF32CD32),
    (Name: 'Linen'; Value: $FFFAF0E6),
    (Name: 'Magenta'; Value: $FFFF00FF),
    (Name: 'Maroon'; Value: $FF800000),
    (Name: 'MediumAquamarine'; Value: $FF66CDAA),
    (Name: 'MediumBlue'; Value: $FF0000CD),
    (Name: 'MediumOrchid'; Value: $FFBA55D3),
    (Name: 'MediumPurple'; Value: $FF9370DB),
    (Name: 'MediumSeaGreen'; Value: $FF3CB371),
    (Name: 'MediumSlateBlue'; Value: $FF7B68EE),
    (Name: 'MediumSpringGreen'; Value: $FF00FA9A),
    (Name: 'MediumTurquoise'; Value: $FF48D1CC),
    (Name: 'MediumVioletRed'; Value: $FFC71585),
    (Name: 'MidnightBlue'; Value: $FF191970),
    (Name: 'MintCream'; Value: $FFF5FFFA),
    (Name: 'MistyRose'; Value: $FFFFE4E1),
    (Name: 'Moccasin'; Value: $FFFFE4B5),
    (Name: 'NavajoWhite'; Value: $FFFFDEAD),
    (Name: 'Navy'; Value: $FF000080),
    (Name: 'OldLace'; Value: $FFFDF5E6),
    (Name: 'Olive'; Value: $FF808000),
    (Name: 'OliveDrab'; Value: $FF6B8E23),
    (Name: 'Orange'; Value: $FFFFA500),
    (Name: 'OrangeRed'; Value: $FFFF4500),
    (Name: 'Orchid'; Value: $FFDA70D6),
    (Name: 'PaleGoldenrod'; Value: $FFEEE8AA),
    (Name: 'PaleGreen'; Value: $FF98FB98),
    (Name: 'PaleTurquoise'; Value: $FFAFEEEE),
    (Name: 'PaleVioletRed'; Value: $FFDB7093),
    (Name: 'PapayaWhip'; Value: $FFFFEFD5),
    (Name: 'PeachPuff'; Value: $FFFFDAB9),
    (Name: 'Peru'; Value: $FFCD853F),
    (Name: 'Pink'; Value: $FFFFC0CB),
    (Name: 'Plum'; Value: $FFDDA0DD),
    (Name: 'PowderBlue'; Value: $FFB0E0E6),
    (Name: 'Purple'; Value: $FF800080),
    (Name: 'Red'; Value: $FFFF0000),
    (Name: 'RosyBrown'; Value: $FFBC8F8F),
    (Name: 'RoyalBlue'; Value: $FF4169E1),
    (Name: 'SaddleBrown'; Value: $FF8B4513),
    (Name: 'Salmon'; Value: $FFFA8072),
    (Name: 'SandyBrown'; Value: $FFF4A460),
    (Name: 'SeaGreen'; Value: $FF2E8B57),
    (Name: 'SeaShell'; Value: $FFFFF5EE),
    (Name: 'Sienna'; Value: $FFA0522D),
    (Name: 'Silver'; Value: $FFC0C0C0),
    (Name: 'SkyBlue'; Value: $FF87CEEB),
    (Name: 'SlateBlue'; Value: $FF6A5ACD),
    (Name: 'SlateGray'; Value: $FF708090),
    (Name: 'Snow'; Value: $FFFFFAFA),
    (Name: 'SpringGreen'; Value: $FF00FF7F),
    (Name: 'SteelBlue'; Value: $FF4682B4),
    (Name: 'Tan'; Value: $FFD2B48C),
    (Name: 'Teal'; Value: $FF008080),
    (Name: 'Thistle'; Value: $FFD8BFD8),
    (Name: 'Tomato'; Value: $FFFF6347),
    (Name: 'Turquoise'; Value: $FF40E0D0),
    (Name: 'Violet'; Value: $FFEE82EE),
    (Name: 'Wheat'; Value: $FFF5DEB3),
    (Name: 'White'; Value: $FFFFFFFF),
    (Name: 'WhiteSmoke'; Value: $FFF5F5F5),
    (Name: 'Yellow'; Value: $FFFFFF00),
    (Name: 'YellowGreen'; Value: $FF9ACD32),
    (Name: 'Transparent'; Value: $00FFFFFF)
  );

function TryParseHexPair(const AText: string; out AValue: Integer): Boolean;
begin
  Result := TryStrToInt('$' + AText, AValue);
end;

function TryParseHex(const AText: string; out AResult: TThemeColor): Boolean;
var
  LOffset, LAlpha, R, G, B: Integer;
begin
  AResult := TThemeColor(0);
  if AText = '' then
    Exit(False);
  if System.Length(AText) = 3 then
  begin
    if not TryParseHexPair(AText[1] + AText[1], R) or
       not TryParseHexPair(AText[2] + AText[2], G) or
       not TryParseHexPair(AText[3] + AText[3], B) then
      Exit(False);
    AResult := ThemeColor(255, Byte(R), Byte(G), Byte(B));
    Exit(True);
  end;
  if (System.Length(AText) = 6) or (System.Length(AText) = 8) then
  begin
    if System.Length(AText) = 8 then
      LOffset := 2
    else
      LOffset := 0;
    LAlpha := 255;
    if (LOffset = 2) and not TryParseHexPair(Copy(AText, 1, 2), LAlpha) then
      Exit(False);
    if not TryParseHexPair(Copy(AText, LOffset + 1, 2), R) or
       not TryParseHexPair(Copy(AText, LOffset + 3, 2), G) or
       not TryParseHexPair(Copy(AText, LOffset + 5, 2), B) then
      Exit(False);
    AResult := ThemeColor(Byte(LAlpha), Byte(R), Byte(G), Byte(B));
    Exit(True);
  end;
  Result := False;
end;

function TryParseComponents(const AText: string; out AResult: TThemeColor): Boolean;
var
  LParts: TArray<string>;
  LValues: array of Integer;
  I, LComponent: Integer;
begin
  AResult := TThemeColor(0);
  LParts := AText.Split([',']);
  if (System.Length(LParts) <> 3) and (System.Length(LParts) <> 4) then
    Exit(False);
  SetLength(LValues, System.Length(LParts));
  for I := 0 to High(LParts) do
  begin
    if not TryStrToInt(Trim(LParts[I]), LComponent) then
      Exit(False);
    if (LComponent < 0) or (LComponent > 255) then
      Exit(False);
    LValues[I] := LComponent;
  end;
  if System.Length(LValues) = 3 then
    AResult := ThemeColor(255, Byte(LValues[0]), Byte(LValues[1]), Byte(LValues[2]))
  else
    AResult := ThemeColor(Byte(LValues[0]), Byte(LValues[1]), Byte(LValues[2]), Byte(LValues[3]));
  Result := True;
end;

function TryParseNamed(const AText: string; out AResult: TThemeColor): Boolean;
var
  I: Integer;
begin
  AResult := TThemeColor(0);
  for I := Low(CNamedColors) to High(CNamedColors) do
    if SameText(CNamedColors[I].Name, AText) then
    begin
      AResult := CNamedColors[I].Value;
      Exit(True);
    end;
  Result := False;
end;

class function TThemedGridColorValue.IsEmpty(const AColor: TThemeColor): Boolean;
begin
  Result := Cardinal(AColor) = 0;
end;

class function TThemedGridColorValue.TryGetName(const AColor: TThemeColor; out AName: string): Boolean;
var
  I: Integer;
begin
  AName := '';
  for I := Low(CNamedColors) to High(CNamedColors) do
    if Cardinal(CNamedColors[I].Value) = Cardinal(AColor) then
    begin
      AName := CNamedColors[I].Name;
      Exit(True);
    end;
  Result := False;
end;

class function TThemedGridColorValue.TryParse(const AText: string; out AResult: TThemeColor): Boolean;
var
  LText: string;
  LNumeric: Integer;
begin
  AResult := TThemeColor(0);
  if AText = '' then
    Exit(False);
  LText := Trim(AText);
  if LText = '' then
    Exit(False);
  if LText[1] = '#' then
    Exit(TryParseHex(Copy(LText, 2, System.Length(LText) - 1), AResult));
  if (System.Length(LText) > 2) and (LText[1] = '0') and (CharInSet(LText[2], ['x', 'X'])) then
    Exit(TryParseHex(Copy(LText, 3, System.Length(LText) - 2), AResult));
  if Pos(',', LText) > 0 then
    Exit(TryParseComponents(LText, AResult));
  if TryStrToInt(LText, LNumeric) then
  begin
    AResult := TThemeColor(Cardinal(LNumeric));
    Exit(True);
  end;
  Result := TryParseNamed(LText, AResult);
end;

class function TThemedGridColorValue.Format(const AColor: TThemeColor): string;
var
  LName: string;
begin
  if IsEmpty(AColor) then
    Exit(EmptyColorText);
  if TryGetName(AColor, LName) then
    Exit(LName);
  if ThemeColorAlpha(AColor) = 255 then
    Result := HexPrefix +
      IntToHex(ThemeColorRed(AColor), 2) +
      IntToHex(ThemeColorGreen(AColor), 2) +
      IntToHex(ThemeColorBlue(AColor), 2)
  else
    Result := HexPrefix +
      IntToHex(ThemeColorAlpha(AColor), 2) +
      IntToHex(ThemeColorRed(AColor), 2) +
      IntToHex(ThemeColorGreen(AColor), 2) +
      IntToHex(ThemeColorBlue(AColor), 2);
end;

class function TThemedGridColorValue.TryGetColor(const AValue: TValue; out AResult: TThemeColor): Boolean;
begin
  AResult := TThemeColor(0);
  if AValue.IsEmpty then
    Exit(False);
  if (AValue.TypeInfo <> nil) and (AValue.TypeInfo = System.TypeInfo(TThemeColor)) then
  begin
    AResult := TThemeColor(Cardinal(AValue.AsOrdinal));
    Exit(not IsEmpty(AResult));
  end;
  case AValue.Kind of
    tkInteger:
      begin
        AResult := TThemeColor(Cardinal(AValue.AsInteger));
        Exit(True);
      end;
    tkInt64:
      begin
        AResult := TThemeColor(Cardinal(AValue.AsInt64));
        Exit(True);
      end;
  end;
  Result := TryParse(AValue.ToString, AResult);
end;

class function TThemedGridColorValue.TryFromName(const AName: string; out AResult: TThemeColor): Boolean;
begin
  Result := TryParseNamed(AName, AResult);
end;

end.

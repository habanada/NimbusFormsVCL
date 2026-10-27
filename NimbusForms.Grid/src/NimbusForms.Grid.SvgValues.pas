unit NimbusForms.Grid.SvgValues;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  NimbusForms.Theming.Types;

type
  TThemedSvgPaintKind = (Unset, None, Color, Reference);

  TThemedSvgPaint = record
    Kind: TThemedSvgPaintKind;
    Color: TThemeColor;
    ReferenceId: string;
    FallbackColor: TThemeColor;
    HasFallback: Boolean;
    class function Unset: TThemedSvgPaint; static;
    class function None: TThemedSvgPaint; static;
    class function FromColor(const AColor: TThemeColor): TThemedSvgPaint; static;
  end;

  TThemedSvgValues = class sealed
  strict private
    class var FNamedColors: TDictionary<string, Cardinal>;
    class procedure EnsureColors; static;
  public
    class destructor Destroy;
    class function TryParseColor(const AText: string; const ACurrentColor: TThemeColor;
      out AColor: TThemeColor): Boolean; static;
    class function ParsePaint(const AText: string; const ACurrentColor: TThemeColor): TThemedSvgPaint; static;
    class function ParseNumber(const AText: string; const ADefault: Double): Double; static;
    class function ParseLength(const AText: string; const ADefault, AReference: Double): Double; static;
    class function ParseFraction(const AText: string; const ADefault: Double): Double; static;
    class function SplitNumbers(const AText: string): TArray<Double>; static;
    class function ParseUrlReference(const AText: string): string; static;
    class function ParseDeclarations(const AText: string): TDictionary<string, string>; static;
  end;

implementation

uses
  System.Math,
  NimbusForms.Grid.VisualStrings;

const
  CNamedColorList =
    'aliceblue=F0F8FF,antiquewhite=FAEBD7,aqua=00FFFF,aquamarine=7FFFD4,azure=F0FFFF,beige=F5F5DC,' +
    'bisque=FFE4C4,black=000000,blanchedalmond=FFEBCD,blue=0000FF,blueviolet=8A2BE2,brown=A52A2A,' +
    'burlywood=DEB887,cadetblue=5F9EA0,chartreuse=7FFF00,chocolate=D2691E,coral=FF7F50,' +
    'cornflowerblue=6495ED,cornsilk=FFF8DC,crimson=DC143C,cyan=00FFFF,darkblue=00008B,darkcyan=008B8B,' +
    'darkgoldenrod=B8860B,darkgray=A9A9A9,darkgreen=006400,darkgrey=A9A9A9,darkkhaki=BDB76B,' +
    'darkmagenta=8B008B,darkolivegreen=556B2F,darkorange=FF8C00,darkorchid=9932CC,darkred=8B0000,' +
    'darksalmon=E9967A,darkseagreen=8FBC8F,darkslateblue=483D8B,darkslategray=2F4F4F,' +
    'darkslategrey=2F4F4F,darkturquoise=00CED1,darkviolet=9400D3,deeppink=FF1493,deepskyblue=00BFFF,' +
    'dimgray=696969,dimgrey=696969,dodgerblue=1E90FF,firebrick=B22222,floralwhite=FFFAF0,' +
    'forestgreen=228B22,fuchsia=FF00FF,gainsboro=DCDCDC,ghostwhite=F8F8FF,gold=FFD700,' +
    'goldenrod=DAA520,gray=808080,grey=808080,green=008000,greenyellow=ADFF2F,honeydew=F0FFF0,' +
    'hotpink=FF69B4,indianred=CD5C5C,indigo=4B0082,ivory=FFFFF0,khaki=F0E68C,lavender=E6E6FA,' +
    'lavenderblush=FFF0F5,lawngreen=7CFC00,lemonchiffon=FFFACD,lightblue=ADD8E6,lightcoral=F08080,' +
    'lightcyan=E0FFFF,lightgoldenrodyellow=FAFAD2,lightgray=D3D3D3,lightgreen=90EE90,lightgrey=D3D3D3,' +
    'lightpink=FFB6C1,lightsalmon=FFA07A,lightseagreen=20B2AA,lightskyblue=87CEFA,' +
    'lightslategray=778899,lightslategrey=778899,lightsteelblue=B0C4DE,lightyellow=FFFFE0,lime=00FF00,' +
    'limegreen=32CD32,linen=FAF0E6,magenta=FF00FF,maroon=800000,mediumaquamarine=66CDAA,' +
    'mediumblue=0000CD,mediumorchid=BA55D3,mediumpurple=9370DB,mediumseagreen=3CB371,' +
    'mediumslateblue=7B68EE,mediumspringgreen=00FA9A,mediumturquoise=48D1CC,mediumvioletred=C71585,' +
    'midnightblue=191970,mintcream=F5FFFA,mistyrose=FFE4E1,moccasin=FFE4B5,navajowhite=FFDEAD,' +
    'navy=000080,oldlace=FDF5E6,olive=808000,olivedrab=6B8E23,orange=FFA500,orangered=FF4500,' +
    'orchid=DA70D6,palegoldenrod=EEE8AA,palegreen=98FB98,paleturquoise=AFEEEE,palevioletred=DB7093,' +
    'papayawhip=FFEFD5,peachpuff=FFDAB9,peru=CD853F,pink=FFC0CB,plum=DDA0DD,powderblue=B0E0E6,' +
    'purple=800080,rebeccapurple=663399,red=FF0000,rosybrown=BC8F8F,royalblue=4169E1,' +
    'saddlebrown=8B4513,salmon=FA8072,sandybrown=F4A460,seagreen=2E8B57,seashell=FFF5EE,' +
    'sienna=A0522D,silver=C0C0C0,skyblue=87CEEB,slateblue=6A5ACD,slategray=708090,slategrey=708090,' +
    'snow=FFFAFA,springgreen=00FF7F,steelblue=4682B4,tan=D2B48C,teal=008080,thistle=D8BFD8,' +
    'tomato=FF6347,turquoise=40E0D0,violet=EE82EE,wheat=F5DEB3,white=FFFFFF,whitesmoke=F5F5F5,' +
    'yellow=FFFF00,yellowgreen=9ACD32';

class function TThemedSvgPaint.Unset: TThemedSvgPaint;
begin
  Result := Default(TThemedSvgPaint);
  Result.Kind := TThemedSvgPaintKind.Unset;
end;

class function TThemedSvgPaint.None: TThemedSvgPaint;
begin
  Result := Default(TThemedSvgPaint);
  Result.Kind := TThemedSvgPaintKind.None;
end;

class function TThemedSvgPaint.FromColor(const AColor: TThemeColor): TThemedSvgPaint;
begin
  Result := Default(TThemedSvgPaint);
  Result.Kind := TThemedSvgPaintKind.Color;
  Result.Color := AColor;
end;

class destructor TThemedSvgValues.Destroy;
begin
  FNamedColors.Free;
end;

class procedure TThemedSvgValues.EnsureColors;
var
  LItems: TArray<string>;
  LItem: string;
  LSeparator: Integer;
begin
  if FNamedColors <> nil then
    Exit;
  FNamedColors := TDictionary<string, Cardinal>.Create;
  LItems := CNamedColorList.Split([',']);
  for LItem in LItems do
  begin
    LSeparator := Pos('=', LItem);
    FNamedColors.AddOrSetValue(Copy(LItem, 1, LSeparator - 1),
      Cardinal(StrToInt('$' + Copy(LItem, LSeparator + 1, MaxInt))));
  end;
end;

class function TThemedSvgValues.ParseNumber(const AText: string; const ADefault: Double): Double;
var
  LText: string;
  LFormat: TFormatSettings;
begin
  LText := Trim(AText);
  if LText = '' then
    Exit(ADefault);
  LFormat := TFormatSettings.Invariant;
  if not TryStrToFloat(LText, Result, LFormat) then
    Result := ADefault;
end;

class function TThemedSvgValues.ParseLength(const AText: string; const ADefault, AReference: Double): Double;
var
  LText, LUnit: string;
  LNumberLength: Integer;
  LValue: Double;
begin
  LText := LowerCase(Trim(AText));
  if LText = '' then
    Exit(ADefault);
  LNumberLength := Length(LText);
  while (LNumberLength > 0) and CharInSet(LText[LNumberLength], ['a'..'z', '%']) do
    Dec(LNumberLength);
  LUnit := Copy(LText, LNumberLength + 1, MaxInt);
  LValue := ParseNumber(Copy(LText, 1, LNumberLength), NaN);
  if IsNan(LValue) then
    Exit(ADefault);
  if LUnit = '%' then
    Result := LValue * AReference / 100
  else if LUnit = 'pt' then
    Result := LValue * 4 / 3
  else if LUnit = 'pc' then
    Result := LValue * 16
  else if LUnit = 'mm' then
    Result := LValue * 96 / 25.4
  else if LUnit = 'cm' then
    Result := LValue * 96 / 2.54
  else if LUnit = 'in' then
    Result := LValue * 96
  else if (LUnit = 'em') or (LUnit = 'rem') then
    Result := LValue * 16
  else
    Result := LValue;
end;

class function TThemedSvgValues.ParseFraction(const AText: string; const ADefault: Double): Double;
var
  LText: string;
begin
  LText := Trim(AText);
  if LText = '' then
    Exit(ADefault);
  if LText[Length(LText)] = '%' then
    Result := ParseNumber(Copy(LText, 1, Length(LText) - 1), ADefault * 100) / 100
  else
    Result := ParseNumber(LText, ADefault);
end;

class function TThemedSvgValues.SplitNumbers(const AText: string): TArray<Double>;
var
  LList: TList<Double>;
  I, LStart: Integer;
  LValue: Double;
  LHasDot, LHasExp: Boolean;
begin
  LList := TList<Double>.Create;
  try
    I := 1;
    while I <= Length(AText) do
    begin
      if CharInSet(AText[I], ['0'..'9', '+', '-', '.']) then
      begin
        LStart := I;
        LHasDot := AText[I] = '.';
        LHasExp := False;
        Inc(I);
        while I <= Length(AText) do
        begin
          if CharInSet(AText[I], ['0'..'9']) then
            Inc(I)
          else if (AText[I] = '.') and not LHasDot and not LHasExp then
          begin
            LHasDot := True;
            Inc(I);
          end
          else if CharInSet(AText[I], ['e', 'E']) and not LHasExp then
          begin
            LHasExp := True;
            Inc(I);
            if (I <= Length(AText)) and CharInSet(AText[I], ['+', '-']) then
              Inc(I);
          end
          else
            Break;
        end;
        LValue := ParseNumber(Copy(AText, LStart, I - LStart), NaN);
        if not IsNan(LValue) then
          LList.Add(LValue);
      end
      else
        Inc(I);
    end;
    Result := LList.ToArray;
  finally
    LList.Free;
  end;
end;

class function TThemedSvgValues.ParseUrlReference(const AText: string): string;
var
  LStart, LEnd: Integer;
  LText: string;
begin
  Result := '';
  LText := Trim(AText);
  if not LText.StartsWith('url(', True) then
    Exit;
  LStart := Pos('#', LText);
  LEnd := Pos(')', LText);
  if (LStart = 0) or (LEnd <= LStart) then
    Exit;
  Result := Trim(Copy(LText, LStart + 1, LEnd - LStart - 1));
  Result := Result.TrimRight(['''', '"']);
end;

class function TThemedSvgValues.TryParseColor(const AText: string; const ACurrentColor: TThemeColor;
  out AColor: TThemeColor): Boolean;
var
  LText, LBody: string;
  LParts: TArray<string>;
  LValue: Cardinal;
  LR, LG, LB, LA: Integer;
  LAlpha: Double;

  function Channel(const APart: string): Integer;
  var
    LPart: string;
  begin
    LPart := Trim(APart);
    if LPart.EndsWith('%') then
      Result := Round(ParseNumber(Copy(LPart, 1, Length(LPart) - 1), 0) * 2.55)
    else
      Result := Round(ParseNumber(LPart, 0));
    Result := Max(0, Min(255, Result));
  end;

begin
  Result := False;
  AColor := 0;
  LText := LowerCase(Trim(AText));
  if LText = '' then
    Exit;
  if LText = 'currentcolor' then
  begin
    AColor := ACurrentColor;
    Exit(True);
  end;
  if LText = 'transparent' then
  begin
    AColor := 0;
    Exit(True);
  end;
  if LText[1] = '#' then
  begin
    LBody := Copy(LText, 2, MaxInt);
    if LBody = '' then
      Exit;
    if not CharInSet(LBody[1], ['0'..'9', 'a'..'f']) then
      Exit;
    case Length(LBody) of
      3:
        LBody := LBody[1] + LBody[1] + LBody[2] + LBody[2] + LBody[3] + LBody[3];
      4:
        LBody := LBody[1] + LBody[1] + LBody[2] + LBody[2] + LBody[3] + LBody[3] + LBody[4] + LBody[4];
    end;
    if not (Length(LBody) in [6, 8]) then
      Exit;
    if not TryStrToUInt('$' + LBody, LValue) then
      Exit;
    if Length(LBody) = 6 then
      AColor := TThemeColor($FF000000 or LValue)
    else
      AColor := ThemeColor(Byte(LValue and $FF), Byte((LValue shr 24) and $FF),
        Byte((LValue shr 16) and $FF), Byte((LValue shr 8) and $FF));
    Exit(True);
  end;
  if LText.StartsWith('rgb') then
  begin
    LBody := Copy(LText, Pos('(', LText) + 1, MaxInt);
    LBody := Copy(LBody, 1, Pos(')', LBody) - 1);
    LParts := LBody.Replace('/', ',').Replace(' ', ',').Split([','], TStringSplitOptions.ExcludeEmpty);
    if Length(LParts) < 3 then
      Exit;
    LR := Channel(LParts[0]);
    LG := Channel(LParts[1]);
    LB := Channel(LParts[2]);
    LA := 255;
    if Length(LParts) > 3 then
    begin
      LAlpha := ParseFraction(LParts[3], 1);
      LA := Max(0, Min(255, Round(LAlpha * 255)));
    end;
    AColor := ThemeColor(Byte(LA), Byte(LR), Byte(LG), Byte(LB));
    Exit(True);
  end;
  EnsureColors;
  if FNamedColors.TryGetValue(LText, LValue) then
  begin
    AColor := TThemeColor($FF000000 or LValue);
    Exit(True);
  end;
end;

class function TThemedSvgValues.ParsePaint(const AText: string; const ACurrentColor: TThemeColor): TThemedSvgPaint;
var
  LText, LId, LFallback: string;
  LColor: TThemeColor;
  LClose: Integer;
begin
  LText := Trim(AText);
  if (LText = '') or SameText(LText, 'inherit') then
    Exit(TThemedSvgPaint.Unset);
  if SameText(LText, 'none') then
    Exit(TThemedSvgPaint.None);
  if LText.StartsWith('url(', True) then
  begin
    LId := ParseUrlReference(LText);
    if LId = '' then
      Exit(TThemedSvgPaint.Unset);
    Result := Default(TThemedSvgPaint);
    Result.Kind := TThemedSvgPaintKind.Reference;
    Result.ReferenceId := LId;
    LClose := Pos(')', LText);
    LFallback := Trim(Copy(LText, LClose + 1, MaxInt));
    if (LFallback <> '') and TryParseColor(LFallback, ACurrentColor, LColor) then
    begin
      Result.FallbackColor := LColor;
      Result.HasFallback := True;
    end;
    Exit;
  end;
  if TryParseColor(LText, ACurrentColor, LColor) then
    Exit(TThemedSvgPaint.FromColor(LColor));
  Result := TThemedSvgPaint.Unset;
end;

class function TThemedSvgValues.ParseDeclarations(const AText: string): TDictionary<string, string>;
var
  LItems: TArray<string>;
  LItem, LName: string;
  LSeparator: Integer;
begin
  Result := TDictionary<string, string>.Create;
  LItems := AText.Split([';']);
  for LItem in LItems do
  begin
    LSeparator := Pos(':', LItem);
    if LSeparator <= 1 then
      Continue;
    LName := LowerCase(Trim(Copy(LItem, 1, LSeparator - 1)));
    Result.AddOrSetValue(LName, Trim(Copy(LItem, LSeparator + 1, MaxInt)).Replace('!important', '').Trim);
  end;
end;

end.

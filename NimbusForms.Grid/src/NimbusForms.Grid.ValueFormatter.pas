unit NimbusForms.Grid.ValueFormatter;

interface

uses
  System.SysUtils,
  System.Variants,
  System.Rtti,
  System.TypInfo,
  NimbusForms.Theming.Types,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.CellMetadata;

type
  TThemedGridValueFormatter = class
  public
    const
      BooleanTrueText = 'True';
      BooleanFalseText = 'False';
      DefaultPercentFormat = 'P0';
      DefaultCurrencyFormat = 'C2';
      DefaultDateFormat = 'd';
      DefaultTimeFormat = 'T';
      DefaultDateTimeFormat = 'g';
      NullDashText = '-';
    class function Format(const AValue: TValue; const AColumn: TThemedGridColumn;
      const AMetadata: TThemedGridCellMetadata): string; static;
    class function ResolveDefaultFormatString(const AColumn: TThemedGridColumn): string; static;
    class function ResolveRenderKind(const AValue: TValue; const AValueType: PTypeInfo;
      const AColumn: TThemedGridColumn; const AMetadata: TThemedGridCellMetadata): TThemedGridCellRenderKind; static;
    class function FormatByString(const AValue: TValue; const AFormat: string;
      const AFormatSettings: TFormatSettings; out AHandled: Boolean): string; static;
    class function TryGetBoolean(const AValue: TValue; out AResult: Boolean): Boolean; static;
    class function ToDecimal(const AValue: TValue): Extended; static;
  end;

implementation

uses
  NimbusForms.Grid.ColorValue;

function IsNullValue(const AValue: TValue): Boolean;
begin
  Result := AValue.TypeInfo = nil;
  if not Result and (AValue.Kind = tkVariant) then
    Result := VarIsClear(AValue.AsVariant) or VarIsNull(AValue.AsVariant);
end;

function UnderlyingType(const ATypeInfo: PTypeInfo): PTypeInfo;
begin
  Result := ATypeInfo;
end;

function IsIntegralType(const ATypeInfo: PTypeInfo): Boolean;
begin
  Result := (ATypeInfo <> nil) and (ATypeInfo.Kind in [tkInteger, tkInt64]);
end;

function ResolveDigits(const ADigits, ADefault: Integer): Integer;
begin
  if ADigits < 0 then
    Result := ADefault
  else
    Result := ADigits;
end;

function ValueToExtended(const AValue: TValue): Extended;
begin
  case AValue.Kind of
    tkInteger: Result := AValue.AsInteger;
    tkInt64: Result := AValue.AsInt64;
    tkFloat:
      if AValue.TypeInfo = System.TypeInfo(Currency) then
        Result := AValue.AsCurrency
      else
        Result := AValue.AsExtended;
  else
    Result := AValue.AsExtended;
  end;
end;

function TranslateNumeric(const AValue: Extended; const AFormat: string;
  const AFormatSettings: TFormatSettings): string;
var
  LSpecifier: Char;
  LDigitsText: string;
  LDigits: Integer;
begin
  if AFormat = '' then
    Exit(FloatToStrF(AValue, ffGeneral, 15, 0, AFormatSettings));
  LSpecifier := AFormat[1];
  LDigitsText := Trim(Copy(AFormat, 2, Length(AFormat) - 1));
  if not TryStrToInt(LDigitsText, LDigits) then
    LDigits := -1;
  case LSpecifier of
    'N', 'n':
      Result := FloatToStrF(AValue, ffNumber, 18, ResolveDigits(LDigits, 2), AFormatSettings);
    'F', 'f':
      Result := FloatToStrF(AValue, ffFixed, 18, ResolveDigits(LDigits, 2), AFormatSettings);
    'C', 'c':
      Result := FloatToStrF(AValue, ffCurrency, 18, ResolveDigits(LDigits, AFormatSettings.CurrencyDecimals), AFormatSettings);
    'P', 'p':
      Result := FloatToStrF(AValue * 100, ffFixed, 18, ResolveDigits(LDigits, 2), AFormatSettings) + ' %';
    'E', 'e':
      Result := FloatToStrF(AValue, ffExponent, ResolveDigits(LDigits, 6), 0, AFormatSettings);
  else
    try
      Result := FormatFloat(AFormat, AValue, AFormatSettings);
    except
      Result := FloatToStrF(AValue, ffGeneral, 15, 0, AFormatSettings);
    end;
  end;
end;

function TranslateDateCustom(const AFormat: string): string;
var
  I: Integer;
  C: Char;
begin
  Result := '';
  for I := 1 to Length(AFormat) do
  begin
    C := AFormat[I];
    case C of
      'M': Result := Result + 'm';
      'm': Result := Result + 'n';
      'H': Result := Result + 'h';
      't': Result := Result + 'am/pm';
    else
      Result := Result + C;
    end;
  end;
end;

function TranslateDate(const AValue: TDateTime; const AFormat: string;
  const AFormatSettings: TFormatSettings): string;
var
  LPattern: string;
begin
  if Length(AFormat) = 1 then
  begin
    case AFormat[1] of
      'd': LPattern := AFormatSettings.ShortDateFormat;
      'D': LPattern := AFormatSettings.LongDateFormat;
      't': LPattern := AFormatSettings.ShortTimeFormat;
      'T': LPattern := AFormatSettings.LongTimeFormat;
      'f': LPattern := AFormatSettings.LongDateFormat + ' ' + AFormatSettings.ShortTimeFormat;
      'F': LPattern := AFormatSettings.LongDateFormat + ' ' + AFormatSettings.LongTimeFormat;
      'g': LPattern := AFormatSettings.ShortDateFormat + ' ' + AFormatSettings.ShortTimeFormat;
      'G': LPattern := AFormatSettings.ShortDateFormat + ' ' + AFormatSettings.LongTimeFormat;
      'M', 'm': LPattern := 'mmmm d';
      'Y', 'y': LPattern := 'mmmm yyyy';
      's': LPattern := 'yyyy-mm-dd"T"hh:nn:ss';
    else
      LPattern := AFormatSettings.ShortDateFormat;
    end;
  end
  else
    LPattern := TranslateDateCustom(AFormat);
  Result := FormatDateTime(LPattern, AValue, AFormatSettings);
end;

function FormatValueByType(const AValue: TValue; const AFormat: string;
  const AFormatSettings: TFormatSettings; out AHandled: Boolean): string;
begin
  AHandled := True;
  if (AValue.TypeInfo <> nil) and (AValue.TypeInfo = System.TypeInfo(TDateTime)) then
    Exit(TranslateDate(AValue.AsExtended, AFormat, AFormatSettings));
  case AValue.Kind of
    tkInteger, tkInt64, tkFloat:
      Exit(TranslateNumeric(ValueToExtended(AValue), AFormat, AFormatSettings));
  end;
  AHandled := False;
  Result := '';
end;

class function TThemedGridValueFormatter.FormatByString(const AValue: TValue; const AFormat: string;
  const AFormatSettings: TFormatSettings; out AHandled: Boolean): string;
begin
  Result := FormatValueByType(AValue, AFormat, AFormatSettings, AHandled);
end;

class function TThemedGridValueFormatter.TryGetBoolean(const AValue: TValue; out AResult: Boolean): Boolean;
var
  LText: string;
begin
  AResult := False;
  if IsNullValue(AValue) then
    Exit(False);
  if AValue.IsType<Boolean> then
  begin
    AResult := AValue.AsBoolean;
    Exit(True);
  end;
  LText := AValue.ToString;
  if SameText(LText, '1') then
  begin
    AResult := True;
    Exit(True);
  end;
  if SameText(LText, '0') then
  begin
    AResult := False;
    Exit(True);
  end;
  Result := TryStrToBool(LText, AResult);
end;

class function TThemedGridValueFormatter.ToDecimal(const AValue: TValue): Extended;
var
  LText: string;
  LFloat: Extended;
begin
  if IsNullValue(AValue) then
    Exit(0);
  case AValue.Kind of
    tkInteger, tkInt64, tkFloat:
      Exit(ValueToExtended(AValue));
  end;
  if AValue.IsType<Boolean> then
  begin
    if AValue.AsBoolean then
      Exit(1)
    else
      Exit(0);
  end;
  LText := AValue.ToString;
  if TryStrToFloat(LText, LFloat, FormatSettings) then
    Exit(LFloat);
  if TryStrToFloat(LText, LFloat, TFormatSettings.Invariant) then
    Exit(LFloat);
  Result := 0;
end;

class function TThemedGridValueFormatter.ResolveDefaultFormatString(const AColumn: TThemedGridColumn): string;
begin
  if AColumn = nil then
    Exit('');
  case AColumn.RenderKind of
    TThemedGridCellRenderKind.Percent: Result := DefaultPercentFormat;
    TThemedGridCellRenderKind.Currency: Result := DefaultCurrencyFormat;
    TThemedGridCellRenderKind.Date: Result := DefaultDateFormat;
    TThemedGridCellRenderKind.Time: Result := DefaultTimeFormat;
    TThemedGridCellRenderKind.DateTime: Result := DefaultDateTimeFormat;
  else
    Result := '';
  end;
end;

class function TThemedGridValueFormatter.ResolveRenderKind(const AValue: TValue;
  const AValueType: PTypeInfo; const AColumn: TThemedGridColumn;
  const AMetadata: TThemedGridCellMetadata): TThemedGridCellRenderKind;
var
  LType: PTypeInfo;
begin
  if (AMetadata <> nil) and AMetadata.HasRenderKind then
    Exit(AMetadata.RenderKind);
  if (AColumn <> nil) and (AColumn.RenderKind <> TThemedGridCellRenderKind.Auto) then
    Exit(AColumn.RenderKind);
  LType := AValueType;
  if LType = nil then
    LType := AValue.TypeInfo;
  if LType = nil then
    Exit(TThemedGridCellRenderKind.Text);
  if LType = System.TypeInfo(Boolean) then
    Exit(TThemedGridCellRenderKind.CheckBox);
  if LType = System.TypeInfo(TDateTime) then
    Exit(TThemedGridCellRenderKind.DateTime);
  if LType = System.TypeInfo(TThemeColor) then
    Exit(TThemedGridCellRenderKind.ColorSwatch);
  case LType.Kind of
    tkFloat, tkInteger, tkInt64:
      Exit(TThemedGridCellRenderKind.Number);
    tkEnumeration:
      Exit(TThemedGridCellRenderKind.ComboText);
  end;
  Result := TThemedGridCellRenderKind.Text;
end;

function FormatNull(const AColumn: TThemedGridColumn; const AMetadata: TThemedGridCellMetadata): string;
var
  LNullText: string;
begin
  if (AMetadata <> nil) and (AMetadata.NullText <> '') then
    LNullText := AMetadata.NullText
  else if AColumn <> nil then
    LNullText := AColumn.NullText
  else
    LNullText := '';
  if AColumn = nil then
    Exit(LNullText);
  case AColumn.NullDisplayMode of
    TThemedGridNullDisplayMode.Dash:
      Result := TThemedGridValueFormatter.NullDashText;
    TThemedGridNullDisplayMode.NullText,
    TThemedGridNullDisplayMode.Placeholder,
    TThemedGridNullDisplayMode.Custom:
      Result := LNullText;
  else
    Result := '';
  end;
end;

class function TThemedGridValueFormatter.Format(const AValue: TValue;
  const AColumn: TThemedGridColumn; const AMetadata: TThemedGridCellMetadata): string;
var
  LFormatString: string;
  LSettings: TFormatSettings;
  LHandled, LBool: Boolean;
begin
  if IsNullValue(AValue) then
    Exit(FormatNull(AColumn, AMetadata));

  if (AMetadata <> nil) and (AMetadata.FormatString <> '') then
    LFormatString := AMetadata.FormatString
  else if AColumn <> nil then
    LFormatString := AColumn.FormatString
  else
    LFormatString := '';

  if (AColumn <> nil) and AColumn.HasFormatProvider then
    LSettings := AColumn.FormatProvider
  else
    LSettings := FormatSettings;

  if LFormatString = '' then
    LFormatString := ResolveDefaultFormatString(AColumn);

  if LFormatString <> '' then
  begin
    Result := FormatValueByType(AValue, LFormatString, LSettings, LHandled);
    if LHandled then
      Exit;
  end;

  if TryGetBoolean(AValue, LBool) then
    if (AColumn <> nil) and (AColumn.RenderKind = TThemedGridCellRenderKind.BooleanText) then
    begin
      if LBool then
        Exit(BooleanTrueText)
      else
        Exit(BooleanFalseText);
    end;

  if (AValue.TypeInfo <> nil) and (AValue.TypeInfo = System.TypeInfo(TThemeColor)) then
    Exit(TThemedGridColorValue.Format(TThemeColor(AValue.AsOrdinal)));

  Result := AValue.ToString;
end;

end.

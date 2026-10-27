unit NimbusForms.Grid.ValueConverter;

{$SCOPEDENUMS ON}

interface

uses
  System.SysUtils,
  System.Rtti,
  System.TypInfo;

type
  TThemedGridValueConverter = class
  private
    class function IsNumeric(const AValue: TValue): Boolean; static;
    class function IsDateValue(const AValue: TValue): Boolean; static;
    class function IsTextValue(const AValue: TValue): Boolean; static;
    class function IsDateType(const ATypeInfo: PTypeInfo): Boolean; static;
    class function NumberOf(const AValue: TValue): Extended; static;
    class function CompareNumbers(const ALeft, ARight: Extended): Integer; static;
    class function ConvertCore(const AValue: TValue; const ATargetType: PTypeInfo): TValue; static;
  public
    class function TryToNumber(const AValue: TValue; out ANumber: Extended): Boolean; static;
    class function IsNull(const AValue: TValue): Boolean; static;
    class function ToText(const AValue: TValue): string; static;
    class function ToTextInvariant(const AValue: TValue): string; static;
    class function IsValueType(const ATypeInfo: PTypeInfo): Boolean; static;
    class function DefaultOf(const ATypeInfo: PTypeInfo): TValue; static;
    class function TryConvert(const AValue: TValue; const ATargetType: PTypeInfo; out AResult: TValue): Boolean; static;
    class function Convert(const AValue: TValue; const ATargetType: PTypeInfo): TValue; static;
    class function TryCompare(const ALeft, ARight: TValue; out AResult: Integer): Boolean; static;
    class function Compare(const ALeft, ARight: TValue): Integer; static;
    class function TryGetDate(const AValue: TValue; out ADate: TDateTime): Boolean; static;
  end;

implementation

uses
  System.Math,
  System.Variants,
  NimbusForms.Theming.Types,
  NimbusForms.Grid.ColorValue,
  NimbusForms.Grid.ValueFormatter,
  NimbusForms.Grid.DataStrings;

type
  TStr = ThemedGridDataStrings;

function TryTextToGuid(const AText: string; out AGuid: TGUID): Boolean;
var
  LText: string;
begin
  LText := Trim(AText);
  if (LText <> '') and (LText[1] <> '{') then
    LText := '{' + LText + '}';
  try
    AGuid := StringToGUID(LText);
    Result := True;
  except
    on EConvertError do
      Result := False;
  end;
end;

class function TThemedGridValueConverter.IsNull(const AValue: TValue): Boolean;
begin
  Result := AValue.TypeInfo = nil;
  if Result then
    Exit;
  case AValue.Kind of
    tkVariant:
      Result := VarIsClear(AValue.AsVariant) or VarIsNull(AValue.AsVariant);
    tkClass:
      Result := AValue.AsObject = nil;
    tkInterface:
      Result := AValue.IsEmpty;
  end;
end;

class function TThemedGridValueConverter.IsDateType(const ATypeInfo: PTypeInfo): Boolean;
begin
  Result := (ATypeInfo = System.TypeInfo(TDateTime)) or (ATypeInfo = System.TypeInfo(TDate)) or
    (ATypeInfo = System.TypeInfo(TTime));
end;

class function TThemedGridValueConverter.IsDateValue(const AValue: TValue): Boolean;
begin
  Result := IsDateType(AValue.TypeInfo);
end;

class function TThemedGridValueConverter.IsNumeric(const AValue: TValue): Boolean;
begin
  Result := (AValue.Kind in [tkInteger, tkInt64]) or ((AValue.Kind = tkFloat) and (not IsDateValue(AValue)));
end;

class function TThemedGridValueConverter.IsTextValue(const AValue: TValue): Boolean;
begin
  Result := AValue.Kind in [tkString, tkLString, tkWString, tkUString];
end;

class function TThemedGridValueConverter.NumberOf(const AValue: TValue): Extended;
begin
  case AValue.Kind of
    tkInteger, tkInt64:
      Result := AValue.AsOrdinal;
    tkFloat:
      if AValue.TypeInfo = System.TypeInfo(Currency) then
        Result := AValue.AsCurrency
      else
        Result := AValue.AsExtended;
  else
    Result := 0;
  end;
end;

class function TThemedGridValueConverter.TryToNumber(const AValue: TValue; out ANumber: Extended): Boolean;
var
  LText: string;
begin
  ANumber := 0;
  if IsNumeric(AValue) then
  begin
    ANumber := NumberOf(AValue);
    Exit(True);
  end;
  if AValue.TypeInfo = System.TypeInfo(Boolean) then
  begin
    if AValue.AsBoolean then
      ANumber := 1;
    Exit(True);
  end;
  if IsTextValue(AValue) then
  begin
    LText := Trim(AValue.AsString);
    if TryStrToFloat(LText, ANumber, FormatSettings) then
      Exit(True);
    Exit(TryStrToFloat(LText, ANumber, TFormatSettings.Invariant));
  end;
  Result := False;
end;

class function TThemedGridValueConverter.ToText(const AValue: TValue): string;
begin
  if IsNull(AValue) then
    Exit('');
  if AValue.Kind = tkVariant then
    Exit(VarToStr(AValue.AsVariant));
  if AValue.TypeInfo = System.TypeInfo(Boolean) then
  begin
    if AValue.AsBoolean then
      Exit(TStr.BooleanTrueText);
    Exit(TStr.BooleanFalseText);
  end;
  if IsDateValue(AValue) then
    Exit(DateTimeToStr(AValue.AsType<TDateTime>));
  if AValue.Kind = tkFloat then
  begin
    if AValue.TypeInfo = System.TypeInfo(Currency) then
      Exit(CurrToStr(AValue.AsCurrency));
    Exit(FloatToStrF(AValue.AsExtended, ffGeneral, 15, 0));
  end;
  Result := AValue.ToString;
end;

class function TThemedGridValueConverter.ToTextInvariant(const AValue: TValue): string;
begin
  if IsNull(AValue) then
    Exit('');
  if AValue.Kind = tkVariant then
    Exit(VarToStr(AValue.AsVariant));
  if AValue.TypeInfo = System.TypeInfo(Boolean) then
  begin
    if AValue.AsBoolean then
      Exit(TStr.BooleanTrueText);
    Exit(TStr.BooleanFalseText);
  end;
  if IsDateValue(AValue) then
    Exit(DateTimeToStr(AValue.AsType<TDateTime>, TFormatSettings.Invariant));
  if AValue.Kind = tkFloat then
  begin
    if AValue.TypeInfo = System.TypeInfo(Currency) then
      Exit(CurrToStr(AValue.AsCurrency, TFormatSettings.Invariant));
    Exit(FloatToStrF(AValue.AsExtended, ffGeneral, 15, 0, TFormatSettings.Invariant));
  end;
  Result := AValue.ToString;
end;

class function TThemedGridValueConverter.IsValueType(const ATypeInfo: PTypeInfo): Boolean;
begin
  Result := (ATypeInfo <> nil) and
    (ATypeInfo.Kind in [tkInteger, tkInt64, tkFloat, tkEnumeration, tkSet, tkRecord, tkChar, tkWChar]);
end;

class function TThemedGridValueConverter.DefaultOf(const ATypeInfo: PTypeInfo): TValue;
begin
  Result := TValue.Empty;
  if ATypeInfo = nil then
    Exit;
  if ATypeInfo = System.TypeInfo(Boolean) then
    Exit(TValue.From<Boolean>(False));
  case ATypeInfo.Kind of
    tkInteger, tkEnumeration, tkChar, tkWChar:
      Result := TValue.FromOrdinal(ATypeInfo, 0);
    tkInt64:
      Result := TValue.From<Int64>(0);
    tkFloat:
      begin
        if ATypeInfo = System.TypeInfo(Currency) then
          Exit(TValue.From<Currency>(0));
        if ATypeInfo = System.TypeInfo(Single) then
          Exit(TValue.From<Single>(0));
        if IsDateType(ATypeInfo) then
          Exit(TValue.From<TDateTime>(0));
        Result := TValue.From<Double>(0);
      end;
  end;
end;

class function TThemedGridValueConverter.TryGetDate(const AValue: TValue; out ADate: TDateTime): Boolean;
var
  LText: string;
begin
  ADate := 0;
  if IsNull(AValue) then
    Exit(False);
  if IsDateValue(AValue) then
  begin
    ADate := AValue.AsType<TDateTime>;
    Exit(True);
  end;
  LText := ToText(AValue);
  if TryStrToDateTime(LText, ADate, FormatSettings) then
    Exit(True);
  Result := TryStrToDateTime(LText, ADate, TFormatSettings.Invariant);
end;

class function TThemedGridValueConverter.CompareNumbers(const ALeft, ARight: Extended): Integer;
begin
  if ALeft < ARight then
    Exit(-1);
  if ALeft > ARight then
    Exit(1);
  Result := 0;
end;

class function TThemedGridValueConverter.TryCompare(const ALeft, ARight: TValue; out AResult: Integer): Boolean;
var
  LLeftGuid, LRightGuid: TGUID;
begin
  AResult := 0;
  if IsNumeric(ALeft) and IsNumeric(ARight) then
  begin
    AResult := CompareNumbers(NumberOf(ALeft), NumberOf(ARight));
    Exit(True);
  end;
  if IsDateValue(ALeft) and IsDateValue(ARight) then
  begin
    AResult := CompareNumbers(ALeft.AsType<TDateTime>, ARight.AsType<TDateTime>);
    Exit(True);
  end;
  if (ALeft.TypeInfo = System.TypeInfo(Boolean)) and (ARight.TypeInfo = System.TypeInfo(Boolean)) then
  begin
    AResult := CompareNumbers(ALeft.AsOrdinal, ARight.AsOrdinal);
    Exit(True);
  end;
  if IsTextValue(ALeft) and IsTextValue(ARight) then
  begin
    AResult := Sign(CompareStr(ALeft.AsString, ARight.AsString, loUserLocale));
    Exit(True);
  end;
  if (ALeft.Kind = tkEnumeration) and (ALeft.TypeInfo = ARight.TypeInfo) then
  begin
    AResult := CompareNumbers(ALeft.AsOrdinal, ARight.AsOrdinal);
    Exit(True);
  end;
  if (ALeft.TypeInfo = System.TypeInfo(TGUID)) and (ARight.TypeInfo = System.TypeInfo(TGUID)) then
  begin
    LLeftGuid := ALeft.AsType<TGUID>;
    LRightGuid := ARight.AsType<TGUID>;
    AResult := Sign(CompareStr(GUIDToString(LLeftGuid), GUIDToString(LRightGuid)));
    Exit(True);
  end;
  Result := False;
end;

class function TThemedGridValueConverter.Compare(const ALeft, ARight: TValue): Integer;
var
  LLeftNull, LRightNull: Boolean;
begin
  LLeftNull := IsNull(ALeft);
  LRightNull := IsNull(ARight);
  if LLeftNull and LRightNull then
    Exit(0);
  if LLeftNull then
    Exit(-1);
  if LRightNull then
    Exit(1);
  if TryCompare(ALeft, ARight, Result) then
    Exit;
  Result := Sign(CompareText(ToText(ALeft), ToText(ARight), loUserLocale));
end;

class function TThemedGridValueConverter.ConvertCore(const AValue: TValue; const ATargetType: PTypeInfo): TValue;
var
  LNumber: Extended;
  LOrdinal: Int64;
  LData: PTypeData;
  LColor: TThemeColor;
  LBool: Boolean;
  LGuid: TGUID;
  LDate: TDateTime;
  LCast: TValue;
begin
  if ATargetType = System.TypeInfo(TThemeColor) then
  begin
    if TThemedGridColorValue.TryGetColor(AValue, LColor) then
      Exit(TValue.From<TThemeColor>(LColor));
    raise EConvertError.Create(TStr.ErrCannotConvert);
  end;

  if ATargetType = System.TypeInfo(Boolean) then
  begin
    if TThemedGridValueFormatter.TryGetBoolean(AValue, LBool) then
      Exit(TValue.From<Boolean>(LBool));
    raise EConvertError.Create(TStr.ErrCannotConvert);
  end;

  if ATargetType = System.TypeInfo(TGUID) then
  begin
    if IsTextValue(AValue) and TryTextToGuid(AValue.AsString, LGuid) then
      Exit(TValue.From<TGUID>(LGuid));
    raise EConvertError.Create(TStr.ErrCannotConvert);
  end;

  if IsDateType(ATargetType) then
  begin
    if TryGetDate(AValue, LDate) then
      Exit(TValue.From<TDateTime>(LDate));
    if TryToNumber(AValue, LNumber) then
      Exit(TValue.From<TDateTime>(LNumber));
    raise EConvertError.Create(TStr.ErrCannotConvert);
  end;

  case ATargetType.Kind of
    tkInteger:
      begin
        if not TryToNumber(AValue, LNumber) then
          raise EConvertError.Create(TStr.ErrCannotConvert);
        LOrdinal := Round(LNumber);
        LData := GetTypeData(ATargetType);
        case LData.OrdType of
          otSByte, otUByte, otSWord, otUWord, otSLong:
            if (LOrdinal < LData.MinValue) or (LOrdinal > LData.MaxValue) then
              raise EConvertError.Create(TStr.ErrCannotConvert);
        end;
        Exit(TValue.FromOrdinal(ATargetType, LOrdinal));
      end;
    tkInt64:
      begin
        if not TryToNumber(AValue, LNumber) then
          raise EConvertError.Create(TStr.ErrCannotConvert);
        Exit(TValue.From<Int64>(Round(LNumber)));
      end;
    tkFloat:
      begin
        if not TryToNumber(AValue, LNumber) then
          raise EConvertError.Create(TStr.ErrCannotConvert);
        if ATargetType = System.TypeInfo(Currency) then
          Exit(TValue.From<Currency>(LNumber));
        if ATargetType = System.TypeInfo(Single) then
          Exit(TValue.From<Single>(LNumber));
        if ATargetType = System.TypeInfo(Double) then
          Exit(TValue.From<Double>(LNumber));
        Exit(TValue.From<Extended>(LNumber));
      end;
    tkEnumeration:
      begin
        if IsTextValue(AValue) then
        begin
          LOrdinal := GetEnumValue(ATargetType, Trim(AValue.AsString));
          if LOrdinal < 0 then
            raise EConvertError.Create(TStr.ErrCannotConvert);
          Exit(TValue.FromOrdinal(ATargetType, LOrdinal));
        end;
        if not TryToNumber(AValue, LNumber) then
          raise EConvertError.Create(TStr.ErrCannotConvert);
        LOrdinal := Round(LNumber);
        LData := GetTypeData(ATargetType);
        if (LOrdinal < LData.MinValue) or (LOrdinal > LData.MaxValue) then
          raise EConvertError.Create(TStr.ErrCannotConvert);
        Exit(TValue.FromOrdinal(ATargetType, LOrdinal));
      end;
    tkString, tkLString, tkWString, tkUString:
      Exit(TValue.From<string>(ToText(AValue)));
  end;

  if AValue.TryCast(ATargetType, LCast) then
    Exit(LCast);
  raise EConvertError.Create(TStr.ErrCannotConvert);
end;

class function TThemedGridValueConverter.TryConvert(const AValue: TValue; const ATargetType: PTypeInfo;
  out AResult: TValue): Boolean;
begin
  AResult := TValue.Empty;
  if ATargetType = nil then
  begin
    AResult := AValue;
    Exit(True);
  end;
  if IsNull(AValue) then
    Exit(True);
  if AValue.TypeInfo = ATargetType then
  begin
    AResult := AValue;
    Exit(True);
  end;
  try
    AResult := ConvertCore(AValue, ATargetType);
    Result := True;
  except
    on Exception do
    begin
      AResult := TValue.Empty;
      Result := False;
    end;
  end;
end;

class function TThemedGridValueConverter.Convert(const AValue: TValue; const ATargetType: PTypeInfo): TValue;
begin
  if ATargetType = nil then
    Exit(AValue);
  if IsNull(AValue) then
  begin
    if IsValueType(ATargetType) then
      Exit(DefaultOf(ATargetType));
    Exit(TValue.Empty);
  end;
  if AValue.TypeInfo = ATargetType then
    Exit(AValue);
  Result := ConvertCore(AValue, ATargetType);
end;

end.

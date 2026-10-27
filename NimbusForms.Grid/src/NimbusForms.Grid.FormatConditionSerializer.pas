unit NimbusForms.Grid.FormatConditionSerializer;

{$SCOPEDENUMS ON}

interface

uses
  System.SysUtils,
  System.Rtti,
  System.JSON,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.ColumnCollection,
  NimbusForms.Grid.FormatCondition,
  NimbusForms.Grid.FormatConditionCollection,
  NimbusForms.Grid.FormatConditionTypes,
  NimbusForms.Grid.FormatConditionModel,
  NimbusForms.Grid.FormatConditionSetModel,
  NimbusForms.Grid.FormatConditionValidation,
  NimbusForms.Grid.FormatStyleModel;

type
  TThemedGridFormatConditionSerializer = class
  private
    class function ConvertValueToString(const AValue: TValue): TValue; static;
    class function ConvertStringToValue(const AValue: TValue; const AValueType: TThemedGridFormatConditionValueType): TValue; static;
    class function ResolveValueType(const AValue: TValue): TThemedGridFormatConditionValueType; static;
    class function ResolveTargetColumnName(const AModel: TThemedGridFormatConditionModel): string; static;
    class function ColumnExists(const AColumns: TThemedGridColumnCollection; const AColumnName: string): Boolean; static;
    class procedure ValidateCondition(const AResult: TThemedGridFormatConditionValidationResult; const AIndex: Integer;
      const ACondition: TThemedGridFormatCondition; const AColumns: TThemedGridColumnCollection); static;
    class function SetModelToJson(const AModel: TThemedGridFormatConditionSetModel): string; static;
    class function JsonToSetModel(const AJson: string): TThemedGridFormatConditionSetModel; static;
  public
    class function ToModel(const AConditions: TThemedGridFormatConditionCollection): TThemedGridFormatConditionSetModel; overload; static;
    class function ToModel(const ACondition: TThemedGridFormatCondition): TThemedGridFormatConditionModel; overload; static;
    class function FromModel(const AModel: TThemedGridFormatConditionSetModel): TThemedGridFormatConditionCollection; overload; static;
    class function FromModel(const AModel: TThemedGridFormatConditionModel): TThemedGridFormatCondition; overload; static;
    class function SaveToJson(const AConditions: TThemedGridFormatConditionCollection): string; static;
    class function LoadFromJson(const AJson: string): TThemedGridFormatConditionCollection; static;
    class procedure SaveToFile(const AConditions: TThemedGridFormatConditionCollection; const AFileName: string); static;
    class function LoadFromFile(const AFileName: string): TThemedGridFormatConditionCollection; static;
    class function Validate(const AConditions: TThemedGridFormatConditionCollection;
      const AColumns: TThemedGridColumnCollection): TThemedGridFormatConditionValidationResult; static;
  end;

implementation

uses
  System.Classes,
  System.IOUtils,
  System.TypInfo,
  System.Variants,
  System.DateUtils,
  System.Generics.Collections,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.FormatConditionStrings;

type
  TStr = ThemedGridFormatConditionStrings;

function IsNullValue(const AValue: TValue): Boolean;
begin
  Result := AValue.TypeInfo = nil;
  if (not Result) and (AValue.Kind = tkVariant) then
    Result := VarIsClear(AValue.AsVariant) or VarIsNull(AValue.AsVariant);
end;

function NullableToText(const AValue: TValue): string;
begin
  if AValue.TypeInfo = nil then
    Result := ''
  else
    Result := AValue.AsString;
end;

function TextToNullable(const AText: string): TValue;
begin
  Result := TValue.From<string>(AText);
end;

function IsDateType(const ATypeInfo: PTypeInfo): Boolean;
begin
  Result := (ATypeInfo = System.TypeInfo(TDateTime)) or (ATypeInfo = System.TypeInfo(TDate));
end;

function GuidToPlainText(const AGuid: TGUID): string;
begin
  Result := LowerCase(GUIDToString(AGuid));
  Result := Copy(Result, 2, Length(Result) - 2);
end;

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

function TryParseInvariantDateTime(const AText: string; out ADate: TDateTime): Boolean;
begin
  if TryStrToDateTime(AText, ADate, TFormatSettings.Invariant) then
    Exit(True);
  if TryISO8601ToDate(AText, ADate, False) then
    Exit(True);
  Result := TryStrToDateTime(AText, ADate, FormatSettings);
end;

class function TThemedGridFormatConditionSerializer.ConvertValueToString(const AValue: TValue): TValue;
var
  LType: PTypeInfo;
  LGuid: TGUID;
  LPrecision: Integer;
begin
  if IsNullValue(AValue) then
    Exit(TValue.Empty);
  LType := AValue.TypeInfo;

  if LType = System.TypeInfo(Boolean) then
  begin
    if AValue.AsBoolean then
      Exit(TextToNullable(TStr.BooleanTrueText));
    Exit(TextToNullable(TStr.BooleanFalseText));
  end;

  if IsDateType(LType) then
    Exit(TextToNullable(FormatDateTime(TStr.DateTimeFormat, AValue.AsType<TDateTime>, TFormatSettings.Invariant)));

  if LType = System.TypeInfo(TTime) then
    Exit(TextToNullable(FormatDateTime(TStr.TimeSpanFormat, AValue.AsType<TDateTime>, TFormatSettings.Invariant)));

  if LType = System.TypeInfo(TGUID) then
  begin
    LGuid := AValue.AsType<TGUID>;
    Exit(TextToNullable(GuidToPlainText(LGuid)));
  end;

  case AValue.Kind of
    tkInteger, tkInt64:
      Exit(TextToNullable(IntToStr(AValue.AsOrdinal)));
    tkFloat:
      begin
        if LType = System.TypeInfo(Currency) then
          Exit(TextToNullable(CurrToStr(AValue.AsCurrency, TFormatSettings.Invariant)));
        if LType = System.TypeInfo(Single) then
          LPrecision := 7
        else
          LPrecision := 15;
        Exit(TextToNullable(FloatToStrF(AValue.AsExtended, ffGeneral, LPrecision, 0, TFormatSettings.Invariant)));
      end;
    tkEnumeration:
      Exit(TextToNullable(GetEnumName(LType, Integer(AValue.AsOrdinal))));
  end;

  Result := TextToNullable(AValue.ToString);
end;

class function TThemedGridFormatConditionSerializer.ConvertStringToValue(const AValue: TValue;
  const AValueType: TThemedGridFormatConditionValueType): TValue;
var
  LText: string;
  LDouble: Double;
  LInt64: Int64;
  LDate: TDateTime;
  LGuid: TGUID;
begin
  if AValue.TypeInfo = nil then
    Exit(TValue.Empty);
  LText := AValue.AsString;

  case AValueType of
    TThemedGridFormatConditionValueType.&Decimal:
      if TryStrToFloat(Trim(LText), LDouble, TFormatSettings.Invariant) then
        Exit(TValue.From<Double>(LDouble));
    TThemedGridFormatConditionValueType.Integer:
      if TryStrToInt64(Trim(LText), LInt64) then
        Exit(TValue.From<Int64>(LInt64));
    TThemedGridFormatConditionValueType.Boolean:
      begin
        if SameText(Trim(LText), TStr.BooleanTrueText) then
          Exit(TValue.From<Boolean>(True));
        if SameText(Trim(LText), TStr.BooleanFalseText) then
          Exit(TValue.From<Boolean>(False));
      end;
    TThemedGridFormatConditionValueType.DateTime:
      if TryParseInvariantDateTime(Trim(LText), LDate) then
        Exit(TValue.From<TDateTime>(LDate));
    TThemedGridFormatConditionValueType.TimeSpan:
      if TryStrToTime(Trim(LText), LDate, TFormatSettings.Invariant) then
        Exit(TValue.From<TTime>(LDate));
    TThemedGridFormatConditionValueType.Guid:
      if TryTextToGuid(LText, LGuid) then
        Exit(TValue.From<TGUID>(LGuid));
  end;

  Result := AValue;
end;

class function TThemedGridFormatConditionSerializer.ResolveValueType(const AValue: TValue): TThemedGridFormatConditionValueType;
var
  LType: PTypeInfo;
begin
  if IsNullValue(AValue) then
    Exit(TThemedGridFormatConditionValueType.Auto);
  LType := AValue.TypeInfo;

  if LType = System.TypeInfo(Boolean) then
    Exit(TThemedGridFormatConditionValueType.Boolean);
  if IsDateType(LType) then
    Exit(TThemedGridFormatConditionValueType.DateTime);
  if LType = System.TypeInfo(TTime) then
    Exit(TThemedGridFormatConditionValueType.TimeSpan);
  if LType = System.TypeInfo(TGUID) then
    Exit(TThemedGridFormatConditionValueType.Guid);

  case AValue.Kind of
    tkString, tkLString, tkWString, tkUString, tkChar, tkWChar:
      Exit(TThemedGridFormatConditionValueType.&String);
    tkInteger, tkInt64:
      Exit(TThemedGridFormatConditionValueType.Integer);
    tkFloat:
      Exit(TThemedGridFormatConditionValueType.&Decimal);
    tkEnumeration:
      Exit(TThemedGridFormatConditionValueType.Enum);
  end;

  Result := TThemedGridFormatConditionValueType.Auto;
end;

class function TThemedGridFormatConditionSerializer.ResolveTargetColumnName(const AModel: TThemedGridFormatConditionModel): string;
begin
  if AModel = nil then
    Exit('');
  if AModel.Scope = TThemedGridFormatConditionScope.Row then
    Exit('');
  if AModel.TargetColumnName <> '' then
    Exit(AModel.TargetColumnName);
  Result := AModel.ColumnName;
end;

class function TThemedGridFormatConditionSerializer.ToModel(const AConditions: TThemedGridFormatConditionCollection): TThemedGridFormatConditionSetModel;
var
  I: Integer;
  LCondition: TThemedGridFormatCondition;
begin
  Result := TThemedGridFormatConditionSetModel.Create;
  if AConditions = nil then
    Exit;
  Result.Enabled := AConditions.Enabled;
  for I := 0 to AConditions.Count - 1 do
  begin
    LCondition := AConditions[I];
    if LCondition = nil then
      Continue;
    Result.Conditions.Add(ToModel(LCondition));
  end;
end;

class function TThemedGridFormatConditionSerializer.ToModel(const ACondition: TThemedGridFormatCondition): TThemedGridFormatConditionModel;
var
  I: Integer;
  LName: string;
begin
  if ACondition = nil then
    Exit(nil);
  Result := TThemedGridFormatConditionModel.Create;
  LName := NullableToText(ConvertValueToString(ACondition.Tag));
  Result.Name := LName;
  Result.Enabled := ACondition.Enabled;
  Result.ColumnName := ACondition.ColumnName;
  Result.TargetColumnName := ACondition.TargetColumnName;
  Result.Operator := ACondition.Operator;
  Result.Value := ConvertValueToString(ACondition.Value);
  Result.Value2 := ConvertValueToString(ACondition.Value2);
  Result.ValueType := ResolveValueType(ACondition.Value);
  Result.Style := TThemedGridFormatStyleModel.FromStyle(ACondition.Style);
  Result.Tag := ACondition.Tag;

  if ACondition.TargetColumnName = '' then
    Result.Scope := TThemedGridFormatConditionScope.Row
  else if not SameText(ACondition.TargetColumnName, ACondition.ColumnName) then
    Result.Scope := TThemedGridFormatConditionScope.TargetColumn
  else
    Result.Scope := TThemedGridFormatConditionScope.Cell;

  for I := 0 to ACondition.Values.Count - 1 do
    Result.Values.Add(ConvertValueToString(ACondition.Values[I]));

  if Assigned(ACondition.Predicate) then
    Result.PredicateKey := LName;
end;

class function TThemedGridFormatConditionSerializer.FromModel(const AModel: TThemedGridFormatConditionSetModel): TThemedGridFormatConditionCollection;
var
  I: Integer;
  LCondition: TThemedGridFormatCondition;
begin
  Result := TThemedGridFormatConditionCollection.Create;
  if AModel = nil then
    Exit;
  Result.BeginUpdate;
  try
    Result.SetEnabled(AModel.Enabled);
    for I := 0 to AModel.Conditions.Count - 1 do
    begin
      LCondition := FromModel(AModel.Conditions[I]);
      if LCondition <> nil then
        Result.Add(LCondition);
    end;
  finally
    Result.EndUpdate;
  end;
end;

class function TThemedGridFormatConditionSerializer.FromModel(const AModel: TThemedGridFormatConditionModel): TThemedGridFormatCondition;
var
  I: Integer;
begin
  if AModel = nil then
    Exit(nil);
  Result := TThemedGridFormatCondition.Create;
  Result.Enabled := AModel.Enabled;
  Result.ColumnName := AModel.ColumnName;
  Result.TargetColumnName := ResolveTargetColumnName(AModel);
  Result.Operator := AModel.Operator;
  Result.Value := ConvertStringToValue(AModel.Value, AModel.ValueType);
  Result.Value2 := ConvertStringToValue(AModel.Value2, AModel.ValueType);
  if AModel.Style <> nil then
    Result.Style := AModel.Style.ToStyle;
  Result.Tag := TValue.From<string>(AModel.Name);
  for I := 0 to AModel.Values.Count - 1 do
    Result.Values.Add(ConvertStringToValue(AModel.Values[I], AModel.ValueType));
end;

function StringOrNull(const AText: string): TJSONValue;
begin
  if AText = '' then
    Result := TJSONNull.Create
  else
    Result := TJSONString.Create(AText);
end;

function NullableOrNull(const AValue: TValue): TJSONValue;
begin
  if AValue.TypeInfo = nil then
    Result := TJSONNull.Create
  else
    Result := TJSONString.Create(AValue.AsString);
end;

function TagToJson(const ATag: TValue): TJSONValue;
begin
  if ATag.TypeInfo = nil then
    Exit(TJSONNull.Create);
  if ATag.TypeInfo = System.TypeInfo(Boolean) then
    Exit(TJSONBool.Create(ATag.AsBoolean));
  case ATag.Kind of
    tkInteger, tkInt64:
      Exit(TJSONNumber.Create(ATag.AsOrdinal));
    tkFloat:
      Exit(TJSONNumber.Create(ATag.AsExtended));
  end;
  Result := TJSONString.Create(ATag.ToString);
end;

function StyleToJson(const AStyle: TThemedGridFormatStyleModel): TJSONValue;
var
  LObject: TJSONObject;
begin
  if AStyle = nil then
    Exit(TJSONNull.Create);
  LObject := TJSONObject.Create;
  LObject.AddPair(TStr.JsonBackColor, StringOrNull(AStyle.BackColor));
  LObject.AddPair(TStr.JsonForeColor, StringOrNull(AStyle.ForeColor));
  LObject.AddPair(TStr.JsonBorderColor, StringOrNull(AStyle.BorderColor));
  LObject.AddPair(TStr.JsonSelectionBackColor, StringOrNull(AStyle.SelectionBackColor));
  LObject.AddPair(TStr.JsonSelectionForeColor, StringOrNull(AStyle.SelectionForeColor));
  LObject.AddPair(TStr.JsonHoverBackColor, StringOrNull(AStyle.HoverBackColor));
  LObject.AddPair(TStr.JsonHoverForeColor, StringOrNull(AStyle.HoverForeColor));
  LObject.AddPair(TStr.JsonCurrentBorderColor, StringOrNull(AStyle.CurrentBorderColor));
  LObject.AddPair(TStr.JsonBold, TJSONBool.Create(AStyle.Bold));
  LObject.AddPair(TStr.JsonItalic, TJSONBool.Create(AStyle.Italic));
  Result := LObject;
end;

function ConditionToJson(const AModel: TThemedGridFormatConditionModel): TJSONObject;
var
  LValues: TJSONArray;
  I: Integer;
begin
  Result := TJSONObject.Create;
  Result.AddPair(TStr.JsonName, TJSONString.Create(AModel.Name));
  Result.AddPair(TStr.JsonEnabled, TJSONBool.Create(AModel.Enabled));
  Result.AddPair(TStr.JsonScope, TJSONNumber.Create(Ord(AModel.Scope)));
  Result.AddPair(TStr.JsonColumnName, StringOrNull(AModel.ColumnName));
  Result.AddPair(TStr.JsonTargetColumnName, StringOrNull(AModel.TargetColumnName));
  Result.AddPair(TStr.JsonOperator, TJSONNumber.Create(Ord(AModel.Operator)));
  Result.AddPair(TStr.JsonValue, NullableOrNull(AModel.Value));
  Result.AddPair(TStr.JsonValue2, NullableOrNull(AModel.Value2));
  LValues := TJSONArray.Create;
  for I := 0 to AModel.Values.Count - 1 do
    LValues.AddElement(NullableOrNull(AModel.Values[I]));
  Result.AddPair(TStr.JsonValues, LValues);
  Result.AddPair(TStr.JsonValueType, TJSONNumber.Create(Ord(AModel.ValueType)));
  Result.AddPair(TStr.JsonPredicateKey, StringOrNull(AModel.PredicateKey));
  Result.AddPair(TStr.JsonStyle, StyleToJson(AModel.Style));
  Result.AddPair(TStr.JsonTag, TagToJson(AModel.Tag));
end;

function ReadText(const AObject: TJSONObject; const AKey: string): string;
var
  LValue: TJSONValue;
begin
  LValue := AObject.GetValue(AKey);
  if (LValue = nil) or (LValue is TJSONNull) then
    Exit('');
  Result := LValue.Value;
end;

function ReadNullable(const AObject: TJSONObject; const AKey: string): TValue;
var
  LValue: TJSONValue;
begin
  LValue := AObject.GetValue(AKey);
  if (LValue = nil) or (LValue is TJSONNull) then
    Exit(TValue.Empty);
  Result := TValue.From<string>(LValue.Value);
end;

function ReadBool(const AObject: TJSONObject; const AKey: string; const ADefault: Boolean): Boolean;
var
  LValue: TJSONValue;
begin
  LValue := AObject.GetValue(AKey);
  if LValue is TJSONBool then
    Exit(TJSONBool(LValue).AsBoolean);
  Result := ADefault;
end;

function ReadEnumOrdinal(const AObject: TJSONObject; const AKey: string; const ATypeInfo: PTypeInfo;
  const ADefault: Integer): Integer;
var
  LValue: TJSONValue;
  LData: PTypeData;
  LNumber: Int64;
  LParsed: Integer;
begin
  Result := ADefault;
  LValue := AObject.GetValue(AKey);
  if (LValue = nil) or (LValue is TJSONNull) then
    Exit;
  LData := GetTypeData(ATypeInfo);
  if LValue is TJSONNumber then
  begin
    LNumber := TJSONNumber(LValue).AsInt64;
    if (LNumber >= LData.MinValue) and (LNumber <= LData.MaxValue) then
      Result := Integer(LNumber);
    Exit;
  end;
  if LValue is TJSONString then
  begin
    LParsed := GetEnumValue(ATypeInfo, TJSONString(LValue).Value);
    if LParsed >= 0 then
      Result := LParsed;
  end;
end;

function ReadTag(const AObject: TJSONObject; const AKey: string): TValue;
var
  LValue: TJSONValue;
  LNumber: TJSONNumber;
begin
  LValue := AObject.GetValue(AKey);
  if (LValue = nil) or (LValue is TJSONNull) then
    Exit(TValue.Empty);
  if LValue is TJSONBool then
    Exit(TValue.From<Boolean>(TJSONBool(LValue).AsBoolean));
  if LValue is TJSONNumber then
  begin
    LNumber := TJSONNumber(LValue);
    if Pos('.', LNumber.Value) > 0 then
      Exit(TValue.From<Double>(LNumber.AsDouble));
    Exit(TValue.From<Int64>(LNumber.AsInt64));
  end;
  Result := TValue.From<string>(LValue.Value);
end;

function JsonToStyle(const AValue: TJSONValue): TThemedGridFormatStyleModel;
var
  LObject: TJSONObject;
begin
  if not (AValue is TJSONObject) then
    Exit(nil);
  LObject := TJSONObject(AValue);
  Result := TThemedGridFormatStyleModel.Create;
  Result.BackColor := ReadText(LObject, TStr.JsonBackColor);
  Result.ForeColor := ReadText(LObject, TStr.JsonForeColor);
  Result.BorderColor := ReadText(LObject, TStr.JsonBorderColor);
  Result.SelectionBackColor := ReadText(LObject, TStr.JsonSelectionBackColor);
  Result.SelectionForeColor := ReadText(LObject, TStr.JsonSelectionForeColor);
  Result.HoverBackColor := ReadText(LObject, TStr.JsonHoverBackColor);
  Result.HoverForeColor := ReadText(LObject, TStr.JsonHoverForeColor);
  Result.CurrentBorderColor := ReadText(LObject, TStr.JsonCurrentBorderColor);
  Result.Bold := ReadBool(LObject, TStr.JsonBold, False);
  Result.Italic := ReadBool(LObject, TStr.JsonItalic, False);
end;

function JsonToCondition(const AObject: TJSONObject): TThemedGridFormatConditionModel;
var
  LValues: TJSONValue;
  LElement: TJSONValue;
begin
  Result := TThemedGridFormatConditionModel.Create;
  Result.Name := ReadText(AObject, TStr.JsonName);
  Result.Enabled := ReadBool(AObject, TStr.JsonEnabled, True);
  Result.Scope := TThemedGridFormatConditionScope(ReadEnumOrdinal(AObject, TStr.JsonScope,
    System.TypeInfo(TThemedGridFormatConditionScope), Ord(TThemedGridFormatConditionScope.Cell)));
  Result.ColumnName := ReadText(AObject, TStr.JsonColumnName);
  Result.TargetColumnName := ReadText(AObject, TStr.JsonTargetColumnName);
  Result.Operator := TThemedGridFormatConditionOperator(ReadEnumOrdinal(AObject, TStr.JsonOperator,
    System.TypeInfo(TThemedGridFormatConditionOperator), Ord(TThemedGridFormatConditionOperator.Equals)));
  Result.Value := ReadNullable(AObject, TStr.JsonValue);
  Result.Value2 := ReadNullable(AObject, TStr.JsonValue2);
  Result.ValueType := TThemedGridFormatConditionValueType(ReadEnumOrdinal(AObject, TStr.JsonValueType,
    System.TypeInfo(TThemedGridFormatConditionValueType), Ord(TThemedGridFormatConditionValueType.Auto)));
  Result.PredicateKey := ReadText(AObject, TStr.JsonPredicateKey);
  Result.Style := JsonToStyle(AObject.GetValue(TStr.JsonStyle));
  Result.Tag := ReadTag(AObject, TStr.JsonTag);
  LValues := AObject.GetValue(TStr.JsonValues);
  if LValues is TJSONArray then
    for LElement in TJSONArray(LValues) do
      if (LElement = nil) or (LElement is TJSONNull) then
        Result.Values.Add(TValue.Empty)
      else
        Result.Values.Add(TValue.From<string>(LElement.Value));
end;

class function TThemedGridFormatConditionSerializer.SetModelToJson(const AModel: TThemedGridFormatConditionSetModel): string;
var
  LRoot: TJSONObject;
  LConditions: TJSONArray;
  I: Integer;
begin
  LRoot := TJSONObject.Create;
  try
    LRoot.AddPair(TStr.JsonVersion, TJSONNumber.Create(AModel.Version));
    LRoot.AddPair(TStr.JsonName, StringOrNull(AModel.Name));
    LRoot.AddPair(TStr.JsonEnabled, TJSONBool.Create(AModel.Enabled));
    LConditions := TJSONArray.Create;
    for I := 0 to AModel.Conditions.Count - 1 do
      LConditions.AddElement(ConditionToJson(AModel.Conditions[I]));
    LRoot.AddPair(TStr.JsonConditions, LConditions);
    Result := LRoot.Format(2);
  finally
    LRoot.Free;
  end;
end;

class function TThemedGridFormatConditionSerializer.JsonToSetModel(const AJson: string): TThemedGridFormatConditionSetModel;
var
  LValue: TJSONValue;
  LRoot: TJSONObject;
  LConditions: TJSONValue;
  LElement: TJSONValue;
  LNumber: Int64;
begin
  LValue := TJSONObject.ParseJSONValue(AJson);
  if LValue = nil then
    raise EJSONException.Create(TStr.ErrInvalidJson);
  try
    if LValue is TJSONNull then
      Exit(nil);
    if not (LValue is TJSONObject) then
      raise EJSONException.Create(TStr.ErrInvalidJson);
    LRoot := TJSONObject(LValue);
    Result := TThemedGridFormatConditionSetModel.Create;
    try
      if LRoot.TryGetValue<Int64>(TStr.JsonVersion, LNumber) then
        Result.Version := Integer(LNumber);
      Result.Name := ReadText(LRoot, TStr.JsonName);
      Result.Enabled := ReadBool(LRoot, TStr.JsonEnabled, True);
      LConditions := LRoot.GetValue(TStr.JsonConditions);
      if LConditions is TJSONArray then
        for LElement in TJSONArray(LConditions) do
          if LElement is TJSONObject then
            Result.Conditions.Add(JsonToCondition(TJSONObject(LElement)));
    except
      Result.Free;
      raise;
    end;
  finally
    LValue.Free;
  end;
end;

class function TThemedGridFormatConditionSerializer.SaveToJson(const AConditions: TThemedGridFormatConditionCollection): string;
var
  LModel: TThemedGridFormatConditionSetModel;
begin
  LModel := ToModel(AConditions);
  try
    Result := SetModelToJson(LModel);
  finally
    LModel.Free;
  end;
end;

class function TThemedGridFormatConditionSerializer.LoadFromJson(const AJson: string): TThemedGridFormatConditionCollection;
var
  LModel: TThemedGridFormatConditionSetModel;
begin
  if Trim(AJson) = '' then
    Exit(TThemedGridFormatConditionCollection.Create);
  LModel := JsonToSetModel(AJson);
  try
    Result := FromModel(LModel);
  finally
    LModel.Free;
  end;
end;

class procedure TThemedGridFormatConditionSerializer.SaveToFile(const AConditions: TThemedGridFormatConditionCollection;
  const AFileName: string);
begin
  TFile.WriteAllBytes(AFileName, TEncoding.UTF8.GetBytes(SaveToJson(AConditions)));
end;

class function TThemedGridFormatConditionSerializer.LoadFromFile(const AFileName: string): TThemedGridFormatConditionCollection;
begin
  Result := LoadFromJson(TFile.ReadAllText(AFileName, TEncoding.UTF8));
end;

class function TThemedGridFormatConditionSerializer.ColumnExists(const AColumns: TThemedGridColumnCollection;
  const AColumnName: string): Boolean;
var
  I: Integer;
  LColumn: TThemedGridColumn;
begin
  if (AColumns = nil) or (AColumnName = '') then
    Exit(False);
  for I := 0 to AColumns.Count - 1 do
  begin
    LColumn := AColumns[I];
    if LColumn = nil then
      Continue;
    if SameText(LColumn.Name, AColumnName) or SameText(LColumn.FieldName, AColumnName) or
       SameText(LColumn.HeaderText, AColumnName) then
      Exit(True);
  end;
  Result := False;
end;

class procedure TThemedGridFormatConditionSerializer.ValidateCondition(const AResult: TThemedGridFormatConditionValidationResult;
  const AIndex: Integer; const ACondition: TThemedGridFormatCondition; const AColumns: TThemedGridColumnCollection);
var
  LName: string;
begin
  if ACondition = nil then
  begin
    AResult.AddWarning(AIndex, '', '', '', TStr.WarnRuleEmpty);
    Exit;
  end;
  LName := NullableToText(ConvertValueToString(ACondition.Tag));

  if (ACondition.ColumnName = '') and (ACondition.Operator <> TThemedGridFormatConditionOperator.Custom) then
    AResult.AddWarning(AIndex, LName, ACondition.ColumnName, ACondition.TargetColumnName, TStr.WarnSourceColumnMissing);

  if (ACondition.ColumnName <> '') and (not ColumnExists(AColumns, ACondition.ColumnName)) then
    AResult.AddWarning(AIndex, LName, ACondition.ColumnName, ACondition.TargetColumnName, TStr.WarnSourceColumnUnknown);

  if (ACondition.TargetColumnName <> '') and (not ColumnExists(AColumns, ACondition.TargetColumnName)) then
    AResult.AddWarning(AIndex, LName, ACondition.ColumnName, ACondition.TargetColumnName, TStr.WarnTargetColumnUnknown);

  if ACondition.Style = nil then
    AResult.AddWarning(AIndex, LName, ACondition.ColumnName, ACondition.TargetColumnName, TStr.WarnStyleMissing);
end;

class function TThemedGridFormatConditionSerializer.Validate(const AConditions: TThemedGridFormatConditionCollection;
  const AColumns: TThemedGridColumnCollection): TThemedGridFormatConditionValidationResult;
var
  I: Integer;
begin
  Result := TThemedGridFormatConditionValidationResult.Create;
  if AConditions = nil then
    Exit;
  for I := 0 to AConditions.Count - 1 do
    ValidateCondition(Result, I, AConditions[I], AColumns);
end;

end.

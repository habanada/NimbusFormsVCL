unit NimbusForms.Charts.Financial.Profiles;

interface

uses System.SysUtils, System.Classes, System.JSON, System.TypInfo, System.Math,
  NimbusForms.Charts.Financial.Workspace, NimbusForms.Charts.Financial.Business.Types;

type
  TNimbusFinancialProfiles = class sealed
  public
    class function Save(Workspace: TNimbusFinancialWorkspace; const LayoutOnly: Boolean): string; static;
    class procedure Load(Workspace: TNimbusFinancialWorkspace; const Text: string; const LayoutOnly: Boolean); static;
  end;

implementation

function WritePersistent(Value: TPersistent): TJSONValue;
var ObjectValue: TJSONObject; ArrayValue: TJSONArray; Properties: PPropList; Prop: PPropInfo;
  I, Count: Integer; Child: TObject; Data: TArray<Double>;
begin
  if Value is TCollection then
  begin
    ArrayValue := TJSONArray.Create;
    try for I := 0 to TCollection(Value).Count - 1 do ArrayValue.AddElement(WritePersistent(TCollection(Value).Items[I])); Result := ArrayValue
    except ArrayValue.Free; raise end;
    Exit;
  end;
  ObjectValue := TJSONObject.Create;
  try
    Properties := nil; Count := GetPropList(Value.ClassInfo, tkAny, nil);
    if Count > 0 then begin GetMem(Properties, Count * SizeOf(PPropInfo)); GetPropList(Value.ClassInfo, tkAny, Properties) end;
    try
      for I := 0 to Count - 1 do
      begin
        Prop := Properties[I];
        case Prop.PropType^.Kind of
          tkInteger, tkEnumeration, tkChar, tkWChar, tkSet: ObjectValue.AddPair(string(Prop.Name), TJSONNumber.Create(GetOrdProp(Value, Prop)));
          tkInt64: ObjectValue.AddPair(string(Prop.Name), TJSONNumber.Create(GetInt64Prop(Value, Prop)));
          tkFloat: ObjectValue.AddPair(string(Prop.Name), TJSONNumber.Create(GetFloatProp(Value, Prop)));
          tkString, tkLString, tkWString, tkUString: ObjectValue.AddPair(string(Prop.Name), GetStrProp(Value, Prop));
          tkClass:
            begin Child := GetObjectProp(Value, Prop); if Child is TPersistent then ObjectValue.AddPair(string(Prop.Name), WritePersistent(TPersistent(Child))) end;
        end;
      end;
    finally if Count > 0 then FreeMem(Properties) end;
    Data := nil;
    if Value is TNimbusFinancialIndicator then Data := TNimbusFinancialIndicator(Value).Values
    else if Value is TNimbusFinancialPanelItem then Data := TNimbusFinancialPanelItem(Value).Values;
    if Length(Data) > 0 then
    begin
      ArrayValue := TJSONArray.Create;
      for var Number in Data do if IsNan(Number) or IsInfinite(Number) then ArrayValue.AddElement(TJSONNull.Create) else ArrayValue.Add(Number);
      ObjectValue.AddPair('Values', ArrayValue);
    end;
    Result := ObjectValue;
  except ObjectValue.Free; raise end;
end;

procedure ReadPersistent(Value: TPersistent; Json: TJSONValue);
var ObjectValue: TJSONObject; ArrayValue: TJSONArray; Pair: TJSONPair; Prop: PPropInfo; I: Integer;
  Child: TObject; IntegerValue: Int64; Number: Double; Values: TArray<Double>;
begin
  if Value is TCollection then
  begin
    if not (Json is TJSONArray) then raise EConvertError.Create('Expected a collection in financial profile');
    ArrayValue := TJSONArray(Json); if ArrayValue.Count > 10000 then raise EConvertError.Create('Financial profile collection is too large');
    TCollection(Value).BeginUpdate;
    try TCollection(Value).Clear; for I := 0 to ArrayValue.Count - 1 do ReadPersistent(TCollection(Value).Add, ArrayValue.Items[I])
    finally TCollection(Value).EndUpdate end;
    Exit;
  end;
  if not (Json is TJSONObject) then raise EConvertError.Create('Expected an object in financial profile');
  ObjectValue := TJSONObject(Json);
  for Pair in ObjectValue do
  begin
    if SameText(Pair.JsonString.Value, 'Values') and (Pair.JsonValue is TJSONArray) then
    begin
      ArrayValue := TJSONArray(Pair.JsonValue); if ArrayValue.Count > 1000000 then raise EConvertError.Create('Too many custom indicator samples');
      SetLength(Values, ArrayValue.Count);
      for I := 0 to High(Values) do
        if ArrayValue.Items[I] is TJSONNull then Values[I] := NaN
        else if ArrayValue.Items[I] is TJSONNumber then Values[I] := TJSONNumber(ArrayValue.Items[I]).AsDouble
        else raise EConvertError.Create('Invalid custom indicator value');
      if Value is TNimbusFinancialIndicator then TNimbusFinancialIndicator(Value).Values := Values
      else if Value is TNimbusFinancialPanelItem then TNimbusFinancialPanelItem(Value).Values := Values;
      Continue;
    end;
    Prop := GetPropInfo(Value, Pair.JsonString.Value); if Prop = nil then Continue;
    case Prop.PropType^.Kind of
      tkInteger, tkEnumeration, tkChar, tkWChar, tkSet, tkInt64:
        begin
          if not (Pair.JsonValue is TJSONNumber) then raise EConvertError.Create('Invalid integer financial profile property');
          if not TryStrToInt64(Pair.JsonValue.Value, IntegerValue) then raise EConvertError.Create('Financial profile integer is out of range');
          if Prop.PropType^.Kind in [tkEnumeration, tkChar, tkWChar] then
            if (IntegerValue < GetTypeData(Prop.PropType^).MinValue) or (IntegerValue > GetTypeData(Prop.PropType^).MaxValue) then raise EConvertError.Create('Invalid financial profile enum value');
          if Prop.PropType^.Kind = tkInt64 then SetInt64Prop(Value, Prop, IntegerValue) else SetOrdProp(Value, Prop, IntegerValue);
        end;
      tkFloat:
        begin
          if not (Pair.JsonValue is TJSONNumber) then raise EConvertError.Create('Invalid numeric financial profile property');
          Number := TJSONNumber(Pair.JsonValue).AsDouble; if IsNan(Number) or IsInfinite(Number) then raise EConvertError.Create('Non-finite financial profile property');
          SetFloatProp(Value, Prop, Number);
        end;
      tkString, tkLString, tkWString, tkUString:
        begin if not (Pair.JsonValue is TJSONString) then raise EConvertError.Create('Invalid text financial profile property'); SetStrProp(Value, Prop, Pair.JsonValue.Value) end;
      tkClass:
        begin Child := GetObjectProp(Value, Prop); if Child is TPersistent then ReadPersistent(TPersistent(Child), Pair.JsonValue) end;
    end;
  end;
end;

class function TNimbusFinancialProfiles.Save(Workspace: TNimbusFinancialWorkspace; const LayoutOnly: Boolean): string;
var Root: TJSONObject;
begin
  if Workspace = nil then raise EArgumentNilException.Create('Workspace'); Root := TJSONObject.Create;
  try
    Root.AddPair('Version', TJSONNumber.Create(1)); Root.AddPair('Panels', WritePersistent(Workspace.Panels));
    if not LayoutOnly then
    begin
      Root.AddPair('Options', WritePersistent(Workspace.Options)); Root.AddPair('Indicators', WritePersistent(Workspace.Indicators));
      Root.AddPair('SidePanels', WritePersistent(Workspace.SidePanels)); Root.AddPair('RangeSelector', WritePersistent(Workspace.RangeSelector));
      Root.AddPair('Palette', WritePersistent(Workspace.Palette)); Root.AddPair('Interaction', WritePersistent(Workspace.InteractionOptions));
      Root.AddPair('Accessibility', WritePersistent(Workspace.AccessibilityOptions));
    end;
    Result := Root.ToJSON;
  finally Root.Free end;
end;

class procedure TNimbusFinancialProfiles.Load(Workspace: TNimbusFinancialWorkspace; const Text: string; const LayoutOnly: Boolean);
var Json: TJSONValue; Root: TJSONObject; Temporary: TNimbusFinancialWorkspace; Pair: TJSONValue;
  procedure Read(const Name: string; ObjectValue: TPersistent);
  var V: TJSONValue;
  begin V := Root.GetValue(Name); if V <> nil then ReadPersistent(ObjectValue, V) end;
begin
  if Workspace = nil then raise EArgumentNilException.Create('Workspace');
  if Length(Text) > 16777216 then raise EConvertError.Create('Financial profile exceeds 16 MB');
  Json := TJSONObject.ParseJSONValue(Text);
  try
    if not (Json is TJSONObject) then raise EConvertError.Create('Invalid financial profile JSON'); Root := TJSONObject(Json);
    Pair := Root.GetValue('Version'); if not (Pair is TJSONNumber) then raise EConvertError.Create('Missing financial profile version');
    if TJSONNumber(Pair).AsInt <> 1 then raise EConvertError.Create('Unsupported financial profile version');
    Temporary := TNimbusFinancialWorkspace.Create;
    try
      Temporary.Viewport.SetDataCount(Workspace.Viewport.DataCount);
      Temporary.Assign(Workspace); Read('Panels', Temporary.Panels);
      if Temporary.Panels.FindByKey('price') = nil then raise EConvertError.Create('A financial profile must retain the price panel');
      if not LayoutOnly then
      begin
        Read('Options', Temporary.Options); Read('Indicators', Temporary.Indicators); Read('SidePanels', Temporary.SidePanels);
        Read('RangeSelector', Temporary.RangeSelector); Read('Palette', Temporary.Palette);
        Read('Interaction', Temporary.InteractionOptions); Read('Accessibility', Temporary.AccessibilityOptions);
      end;
      Workspace.Assign(Temporary);
    finally Temporary.Free end;
  finally Json.Free end;
end;

end.

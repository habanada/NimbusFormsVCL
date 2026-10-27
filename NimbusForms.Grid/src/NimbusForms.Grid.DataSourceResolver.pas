unit NimbusForms.Grid.DataSourceResolver;

{$SCOPEDENUMS ON}

interface

uses
  System.SysUtils,
  System.Classes,
  System.Rtti,
  System.TypInfo,
  System.Generics.Collections,
  Data.DB,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.ColumnCollection,
  NimbusForms.Grid.RowList,
  NimbusForms.Grid.DataControllerIntf;

type
  TThemedGridDataSourceResolver = class
  private
    class function AsRowList(const ADataSource: TValue): IThemedGridRowList; static;
  public
    class function Resolve(const ADataSource: TValue): IThemedGridDataController; static;
    class function FromRowList(const ARows: IThemedGridRowList): IThemedGridDataController; static;
    class function FromList<T>(const AList: TList<T>): IThemedGridDataController; static;
    class function CreateColumns(const ADataSource: TValue): TList<TThemedGridColumn>; static;
    class function CreateColumnsFromRowList(const ARows: IThemedGridRowList): TList<TThemedGridColumn>; static;
    class function CreateColumnsFromDataSet(const ADataSet: TDataSet): TList<TThemedGridColumn>; static;
    class procedure AddColumns(const ADataSource: TValue; const AColumns: TThemedGridColumnCollection); static;
    class function CreateColumn(const AFieldName: string; const AValueType: PTypeInfo): TThemedGridColumn; static;
  end;

implementation

uses
  Vcl.Graphics,
  NimbusForms.Theming.Types,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.ListDataController,
  NimbusForms.Grid.DataSetController,
  NimbusForms.Grid.ValueConverter,
  NimbusForms.Grid.DataStrings;

type
  TKind = (Text, Number, Check, DateTime, Time, Image, Icon, Color, Enum);

function ClassifyType(const AValueType: PTypeInfo): TKind;
var
  LClass: TClass;
begin
  if AValueType = nil then
    Exit(TKind.Text);
  if AValueType = System.TypeInfo(Boolean) then
    Exit(TKind.Check);
  if (AValueType = System.TypeInfo(TDateTime)) or (AValueType = System.TypeInfo(TDate)) then
    Exit(TKind.DateTime);
  if AValueType = System.TypeInfo(TTime) then
    Exit(TKind.Time);
  if AValueType = System.TypeInfo(TThemeColor) then
    Exit(TKind.Color);
  case AValueType.Kind of
    tkInteger, tkInt64, tkFloat:
      Exit(TKind.Number);
    tkEnumeration:
      Exit(TKind.Enum);
    tkClass:
      begin
        LClass := GetTypeData(AValueType).ClassType;
        if (LClass <> nil) and LClass.InheritsFrom(TIcon) then
          Exit(TKind.Icon);
        if (LClass <> nil) and LClass.InheritsFrom(TGraphic) then
          Exit(TKind.Image);
      end;
  end;
  Result := TKind.Text;
end;

class function TThemedGridDataSourceResolver.AsRowList(const ADataSource: TValue): IThemedGridRowList;
var
  LObject: TObject;
begin
  Result := nil;
  if ADataSource.Kind = tkInterface then
  begin
    if Supports(ADataSource.AsInterface, IThemedGridRowList, Result) then
      Exit;
    Exit(nil);
  end;
  if ADataSource.Kind <> tkClass then
    Exit(nil);
  LObject := ADataSource.AsObject;
  if LObject is TList<TObject> then
    Exit(TThemedGridListAdapter<TObject>.Create(TList<TObject>(LObject)));
  if LObject is TList<TValue> then
    Exit(TThemedGridValueListAdapter.Create(TList<TValue>(LObject)));
end;

class function TThemedGridDataSourceResolver.FromRowList(const ARows: IThemedGridRowList): IThemedGridDataController;
begin
  Result := TThemedGridListDataController.Create(ARows);
end;

class function TThemedGridDataSourceResolver.FromList<T>(const AList: TList<T>): IThemedGridDataController;
begin
  Result := TThemedGridListDataController.Create(TThemedGridListAdapter<T>.Create(AList));
end;

class function TThemedGridDataSourceResolver.Resolve(const ADataSource: TValue): IThemedGridDataController;
var
  LController: IThemedGridDataController;
  LRows: IThemedGridRowList;
begin
  if TThemedGridValueConverter.IsNull(ADataSource) then
    Exit(TThemedGridListDataController.Create(TThemedGridValueListAdapter.Create(TList<TValue>.Create, True)));
  if (ADataSource.Kind = tkInterface) and Supports(ADataSource.AsInterface, IThemedGridDataController, LController) then
    Exit(LController);
  if (ADataSource.Kind = tkClass) and (ADataSource.AsObject is TDataSet) then
    Exit(TThemedGridDataSetController.Create(TDataSet(ADataSource.AsObject)));
  LRows := AsRowList(ADataSource);
  if LRows <> nil then
    Exit(TThemedGridListDataController.Create(LRows));
  raise ENotSupportedException.Create(ThemedGridDataStrings.ErrDataSourceNotSupported);
end;

class function TThemedGridDataSourceResolver.CreateColumn(const AFieldName: string;
  const AValueType: PTypeInfo): TThemedGridColumn;
begin
  Result := TThemedGridColumn.Create(AFieldName, AFieldName, AFieldName);
  Result.ValueType := AValueType;
  case ClassifyType(AValueType) of
    TKind.Check:
      begin
        Result.RenderKind := TThemedGridCellRenderKind.CheckBox;
        Result.EditorKind := TThemedGridEditorKind.CheckBox;
        Result.TextAlignment := TThemedGridContentAlignment.MiddleCenter;
      end;
    TKind.DateTime:
      begin
        Result.RenderKind := TThemedGridCellRenderKind.DateTime;
        Result.EditorKind := TThemedGridEditorKind.DatePicker;
        Result.FormatString := 'g';
      end;
    TKind.Time:
      begin
        Result.RenderKind := TThemedGridCellRenderKind.Time;
        Result.EditorKind := TThemedGridEditorKind.TextBox;
      end;
    TKind.Number:
      begin
        Result.RenderKind := TThemedGridCellRenderKind.Number;
        Result.EditorKind := TThemedGridEditorKind.Numeric;
        Result.TextAlignment := TThemedGridContentAlignment.MiddleRight;
        if (AValueType.Kind = tkFloat) then
          Result.FormatString := 'N2';
      end;
    TKind.Image:
      begin
        Result.RenderKind := TThemedGridCellRenderKind.Image;
        Result.EditorKind := TThemedGridEditorKind.ImagePicker;
        Result.TextAlignment := TThemedGridContentAlignment.MiddleCenter;
      end;
    TKind.Icon:
      begin
        Result.RenderKind := TThemedGridCellRenderKind.Icon;
        Result.EditorKind := TThemedGridEditorKind.TextBox;
        Result.TextAlignment := TThemedGridContentAlignment.MiddleCenter;
      end;
    TKind.Color:
      begin
        Result.RenderKind := TThemedGridCellRenderKind.ColorSwatch;
        Result.EditorKind := TThemedGridEditorKind.ColorPicker;
        Result.TextAlignment := TThemedGridContentAlignment.MiddleCenter;
      end;
    TKind.Enum:
      begin
        Result.RenderKind := TThemedGridCellRenderKind.ComboText;
        Result.EditorKind := TThemedGridEditorKind.ComboBox;
      end;
  else
    begin
      Result.RenderKind := TThemedGridCellRenderKind.Text;
      Result.EditorKind := TThemedGridEditorKind.TextBox;
    end;
  end;
end;

class function TThemedGridDataSourceResolver.CreateColumnsFromRowList(
  const ARows: IThemedGridRowList): TList<TThemedGridColumn>;
var
  LFirst: TValue;
  LContext: TRttiContext;
  LType: TRttiType;
  LProperty: TRttiProperty;
  LField: TRttiField;
  LDictionary: TDictionary<string, TValue>;
  LPair: TPair<string, TValue>;
  LValueType: PTypeInfo;
begin
  Result := TList<TThemedGridColumn>.Create;
  if (ARows = nil) or (ARows.Count = 0) then
    Exit;
  LFirst := ARows[0];
  if TThemedGridValueConverter.IsNull(LFirst) then
    Exit;

  if (LFirst.Kind = tkClass) and (LFirst.AsObject is TDictionary<string, TValue>) then
  begin
    LDictionary := TDictionary<string, TValue>(LFirst.AsObject);
    for LPair in LDictionary do
    begin
      if TThemedGridValueConverter.IsNull(LPair.Value) then
        LValueType := nil
      else
        LValueType := LPair.Value.TypeInfo;
      Result.Add(CreateColumn(LPair.Key, LValueType));
    end;
    Exit;
  end;

  LContext := TRttiContext.Create;
  try
    if LFirst.Kind = tkClass then
      LType := LContext.GetType(LFirst.AsObject.ClassType)
    else if LFirst.Kind = tkRecord then
      LType := LContext.GetType(LFirst.TypeInfo)
    else
      LType := nil;
    if LType = nil then
      Exit;
    for LProperty in LType.GetProperties do
    begin
      if not (LProperty.Visibility in [mvPublic, mvPublished]) then
        Continue;
      if not LProperty.IsReadable then
        Continue;
      if LProperty.PropertyType <> nil then
        LValueType := LProperty.PropertyType.Handle
      else
        LValueType := nil;
      Result.Add(CreateColumn(LProperty.Name, LValueType));
    end;
    if (Result.Count = 0) and LType.IsRecord then
      for LField in LType.GetFields do
      begin
        if LField.FieldType <> nil then
          LValueType := LField.FieldType.Handle
        else
          LValueType := nil;
        Result.Add(CreateColumn(LField.Name, LValueType));
      end;
  finally
    LContext.Free;
  end;
end;

class function TThemedGridDataSourceResolver.CreateColumnsFromDataSet(const ADataSet: TDataSet): TList<TThemedGridColumn>;
var
  I: Integer;
  LField: TField;
begin
  Result := TList<TThemedGridColumn>.Create;
  if ADataSet = nil then
    Exit;
  if ADataSet.FieldCount > 0 then
  begin
    for I := 0 to ADataSet.FieldCount - 1 do
    begin
      LField := ADataSet.Fields[I];
      if LField.Visible then
        Result.Add(CreateColumn(LField.FieldName, ThemedGridFieldValueType(LField)));
    end;
    Exit;
  end;
  for I := 0 to ADataSet.FieldDefs.Count - 1 do
    Result.Add(CreateColumn(ADataSet.FieldDefs[I].Name, ThemedGridFieldTypeInfo(ADataSet.FieldDefs[I].DataType)));
end;

class function TThemedGridDataSourceResolver.CreateColumns(const ADataSource: TValue): TList<TThemedGridColumn>;
var
  LRows: IThemedGridRowList;
begin
  if TThemedGridValueConverter.IsNull(ADataSource) then
    Exit(TList<TThemedGridColumn>.Create);
  if (ADataSource.Kind = tkClass) and (ADataSource.AsObject is TDataSet) then
    Exit(CreateColumnsFromDataSet(TDataSet(ADataSource.AsObject)));
  LRows := AsRowList(ADataSource);
  Result := CreateColumnsFromRowList(LRows);
end;

class procedure TThemedGridDataSourceResolver.AddColumns(const ADataSource: TValue;
  const AColumns: TThemedGridColumnCollection);
var
  LColumns: TList<TThemedGridColumn>;
  I: Integer;
begin
  if AColumns = nil then
    Exit;
  LColumns := CreateColumns(ADataSource);
  try
    for I := 0 to LColumns.Count - 1 do
      AColumns.Add(LColumns[I]);
  finally
    LColumns.Free;
  end;
end;

end.

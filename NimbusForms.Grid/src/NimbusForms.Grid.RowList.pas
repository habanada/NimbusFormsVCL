unit NimbusForms.Grid.RowList;

interface

uses
  System.SysUtils,
  System.Rtti,
  System.TypInfo,
  System.Generics.Collections;

type
  IThemedGridRowList = interface
    ['{7D3A9C52-1B4E-4F68-A2D7-8E0C5B6F1A94}']
    function GetCount: Integer;
    function GetItem(const AIndex: Integer): TValue;
    function GetIsReadOnly: Boolean;
    function GetIsFixedSize: Boolean;
    function GetItemType: PTypeInfo;
    function GetSource: TValue;
    function GetOwnsItems: Boolean;
    function CreateItem: TValue;
    procedure Insert(const AIndex: Integer; const AItem: TValue);
    procedure Delete(const AIndex: Integer);
    function Extract(const AIndex: Integer): TValue;
    procedure Move(const AFromIndex, AToIndex: Integer);
    property Count: Integer read GetCount;
    property Items[const AIndex: Integer]: TValue read GetItem; default;
    property IsReadOnly: Boolean read GetIsReadOnly;
    property IsFixedSize: Boolean read GetIsFixedSize;
    property OwnsItems: Boolean read GetOwnsItems;
    property ItemType: PTypeInfo read GetItemType;
    property Source: TValue read GetSource;
  end;

  TThemedGridListAdapter<T> = class(TInterfacedObject, IThemedGridRowList)
  private
    FList: TList<T>;
    function GetCount: Integer;
    function GetItem(const AIndex: Integer): TValue;
    function GetIsReadOnly: Boolean;
    function GetIsFixedSize: Boolean;
    function GetItemType: PTypeInfo;
    function GetSource: TValue;
    function GetOwnsItems: Boolean;
    function CreateItem: TValue;
    procedure Insert(const AIndex: Integer; const AItem: TValue);
    procedure Delete(const AIndex: Integer);
    function Extract(const AIndex: Integer): TValue;
    procedure Move(const AFromIndex, AToIndex: Integer);
  public
    constructor Create(const AList: TList<T>);
  end;

  TThemedGridValueListAdapter = class(TInterfacedObject, IThemedGridRowList)
  private
    FList: TList<TValue>;
    FOwnsList: Boolean;
    function GetCount: Integer;
    function GetItem(const AIndex: Integer): TValue;
    function GetIsReadOnly: Boolean;
    function GetIsFixedSize: Boolean;
    function GetItemType: PTypeInfo;
    function GetSource: TValue;
    function GetOwnsItems: Boolean;
    function CreateItem: TValue;
    procedure Insert(const AIndex: Integer; const AItem: TValue);
    procedure Delete(const AIndex: Integer);
    function Extract(const AIndex: Integer): TValue;
    procedure Move(const AFromIndex, AToIndex: Integer);
  public
    constructor Create(const AList: TList<TValue>; const AOwnsList: Boolean = False);
    destructor Destroy; override;
  end;

  TThemedGridArrayAdapter<T> = class(TInterfacedObject, IThemedGridRowList)
  private
    FArray: TArray<T>;
    function GetCount: Integer;
    function GetItem(const AIndex: Integer): TValue;
    function GetIsReadOnly: Boolean;
    function GetIsFixedSize: Boolean;
    function GetItemType: PTypeInfo;
    function GetSource: TValue;
    function GetOwnsItems: Boolean;
    function CreateItem: TValue;
    procedure Insert(const AIndex: Integer; const AItem: TValue);
    procedure Delete(const AIndex: Integer);
    function Extract(const AIndex: Integer): TValue;
    procedure Move(const AFromIndex, AToIndex: Integer);
  public
    constructor Create(const AArray: TArray<T>);
  end;

function ThemedGridCreateInstance(const ATypeInfo: PTypeInfo): TValue;
function ThemedGridRuntimeTypeOf(const AValue: TValue): PTypeInfo;
function ThemedGridResolveItemType(const AStaticType: PTypeInfo; const AFirst: TValue): PTypeInfo;

implementation

uses
  NimbusForms.Grid.DataStrings,
  NimbusForms.Grid.ValueConverter;

function ThemedGridRuntimeTypeOf(const AValue: TValue): PTypeInfo;
var
  LContext: TRttiContext;
  LType: TRttiType;
begin
  Result := nil;
  if TThemedGridValueConverter.IsNull(AValue) then
    Exit;
  if AValue.Kind = tkClass then
  begin
    LContext := TRttiContext.Create;
    try
      LType := LContext.GetType(AValue.AsObject.ClassType);
      if LType <> nil then
        Result := LType.Handle;
    finally
      LContext.Free;
    end;
    Exit;
  end;
  Result := AValue.TypeInfo;
end;

function ThemedGridCreateInstance(const ATypeInfo: PTypeInfo): TValue;
var
  LContext: TRttiContext;
  LType: TRttiType;
  LMethod: TRttiMethod;
begin
  Result := TValue.Empty;
  if (ATypeInfo = nil) or (ATypeInfo.Kind <> tkClass) then
    Exit;
  LContext := TRttiContext.Create;
  try
    LType := LContext.GetType(ATypeInfo);
    if (LType = nil) or (LType.AsInstance = nil) then
      Exit;
    try
      for LMethod in LType.GetMethods do
        if LMethod.IsConstructor and (Length(LMethod.GetParameters) = 0) and
           (LMethod.Visibility in [mvPublic, mvPublished]) then
          Exit(LMethod.Invoke(LType.AsInstance.MetaclassType, []));
    except
      on Exception do
        Result := TValue.Empty;
    end;
  finally
    LContext.Free;
  end;
end;

function ThemedGridResolveItemType(const AStaticType: PTypeInfo; const AFirst: TValue): PTypeInfo;
begin
  Result := AStaticType;
  if (AStaticType = System.TypeInfo(TObject)) or (AStaticType = System.TypeInfo(TValue)) then
    Result := ThemedGridRuntimeTypeOf(AFirst);
end;


constructor TThemedGridListAdapter<T>.Create(const AList: TList<T>);
begin
  if AList = nil then
    raise EArgumentNilException.Create(ThemedGridDataStrings.ErrListRequired);
  inherited Create;
  FList := AList;
end;

function TThemedGridListAdapter<T>.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TThemedGridListAdapter<T>.GetItem(const AIndex: Integer): TValue;
begin
  Result := TValue.From<T>(FList[AIndex]);
end;

function TThemedGridListAdapter<T>.GetIsReadOnly: Boolean;
begin
  Result := False;
end;

function TThemedGridListAdapter<T>.GetIsFixedSize: Boolean;
begin
  Result := False;
end;

function TThemedGridListAdapter<T>.GetItemType: PTypeInfo;
var
  I: Integer;
  LItem: TValue;
begin
  Result := System.TypeInfo(T);
  if (Result <> System.TypeInfo(TObject)) then
    Exit;
  for I := 0 to FList.Count - 1 do
  begin
    LItem := TValue.From<T>(FList[I]);
    if not TThemedGridValueConverter.IsNull(LItem) then
      Exit(ThemedGridResolveItemType(Result, LItem));
  end;
end;

function TThemedGridListAdapter<T>.GetSource: TValue;
begin
  Result := TValue.From<TObject>(FList);
end;

function TThemedGridListAdapter<T>.CreateItem: TValue;
var
  LType: PTypeInfo;
begin
  LType := GetItemType;
  if LType = nil then
    Exit(TValue.Empty);
  if LType.Kind = tkClass then
    Exit(ThemedGridCreateInstance(LType));
  if (LType.Kind = tkRecord) and (LType = System.TypeInfo(T)) then
    Exit(TValue.From<T>(Default(T)));
  Result := TValue.Empty;
end;

procedure TThemedGridListAdapter<T>.Insert(const AIndex: Integer; const AItem: TValue);
begin
  FList.Insert(AIndex, AItem.AsType<T>);
end;

procedure TThemedGridListAdapter<T>.Delete(const AIndex: Integer);
begin
  FList.Delete(AIndex);
end;

function TThemedGridListAdapter<T>.GetOwnsItems: Boolean;
var
  LContext: TRttiContext;
  LProperty: TRttiProperty;
begin
  Result := False;
  LContext := TRttiContext.Create;
  try
    LProperty := LContext.GetType(FList.ClassType).GetProperty('OwnsObjects');
    if LProperty <> nil then
      Result := LProperty.GetValue(FList).AsBoolean;
  finally
    LContext.Free;
  end;
end;

function TThemedGridListAdapter<T>.Extract(const AIndex: Integer): TValue;
var
  LItem: T;
begin
  LItem := FList[AIndex];
  Result := TValue.From<T>(LItem);
  if GetOwnsItems and (FList.IndexOf(LItem) = AIndex) then
    FList.Extract(LItem)
  else
    FList.Delete(AIndex);
end;

procedure TThemedGridListAdapter<T>.Move(const AFromIndex, AToIndex: Integer);
begin
  FList.Move(AFromIndex, AToIndex);
end;


constructor TThemedGridValueListAdapter.Create(const AList: TList<TValue>; const AOwnsList: Boolean);
begin
  if AList = nil then
    raise EArgumentNilException.Create(ThemedGridDataStrings.ErrListRequired);
  inherited Create;
  FList := AList;
  FOwnsList := AOwnsList;
end;

destructor TThemedGridValueListAdapter.Destroy;
begin
  if FOwnsList then
    FList.Free;
  inherited Destroy;
end;

function TThemedGridValueListAdapter.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TThemedGridValueListAdapter.GetItem(const AIndex: Integer): TValue;
begin
  Result := FList[AIndex];
end;

function TThemedGridValueListAdapter.GetIsReadOnly: Boolean;
begin
  Result := False;
end;

function TThemedGridValueListAdapter.GetIsFixedSize: Boolean;
begin
  Result := False;
end;

function TThemedGridValueListAdapter.GetItemType: PTypeInfo;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FList.Count - 1 do
    if not TThemedGridValueConverter.IsNull(FList[I]) then
      Exit(ThemedGridRuntimeTypeOf(FList[I]));
end;

function TThemedGridValueListAdapter.GetSource: TValue;
begin
  Result := TValue.From<TObject>(FList);
end;

function TThemedGridValueListAdapter.CreateItem: TValue;
begin
  Result := ThemedGridCreateInstance(GetItemType);
end;

procedure TThemedGridValueListAdapter.Insert(const AIndex: Integer; const AItem: TValue);
begin
  FList.Insert(AIndex, AItem);
end;

procedure TThemedGridValueListAdapter.Delete(const AIndex: Integer);
begin
  FList.Delete(AIndex);
end;

function TThemedGridValueListAdapter.GetOwnsItems: Boolean;
begin
  Result := False;
end;

function TThemedGridValueListAdapter.Extract(const AIndex: Integer): TValue;
begin
  Result := FList[AIndex];
  FList.Delete(AIndex);
end;

procedure TThemedGridValueListAdapter.Move(const AFromIndex, AToIndex: Integer);
begin
  FList.Move(AFromIndex, AToIndex);
end;


constructor TThemedGridArrayAdapter<T>.Create(const AArray: TArray<T>);
begin
  inherited Create;
  FArray := AArray;
end;

function TThemedGridArrayAdapter<T>.GetCount: Integer;
begin
  Result := Length(FArray);
end;

function TThemedGridArrayAdapter<T>.GetItem(const AIndex: Integer): TValue;
begin
  Result := TValue.From<T>(FArray[AIndex]);
end;

function TThemedGridArrayAdapter<T>.GetIsReadOnly: Boolean;
begin
  Result := False;
end;

function TThemedGridArrayAdapter<T>.GetIsFixedSize: Boolean;
begin
  Result := True;
end;

function TThemedGridArrayAdapter<T>.GetItemType: PTypeInfo;
begin
  Result := System.TypeInfo(T);
end;

function TThemedGridArrayAdapter<T>.GetSource: TValue;
begin
  Result := TValue.From<TArray<T>>(FArray);
end;

function TThemedGridArrayAdapter<T>.CreateItem: TValue;
begin
  Result := TValue.Empty;
end;

procedure TThemedGridArrayAdapter<T>.Insert(const AIndex: Integer; const AItem: TValue);
begin
  raise ENotSupportedException.Create(ThemedGridDataStrings.ErrCannotConvert);
end;

procedure TThemedGridArrayAdapter<T>.Delete(const AIndex: Integer);
begin
  raise ENotSupportedException.Create(ThemedGridDataStrings.ErrCannotConvert);
end;

function TThemedGridArrayAdapter<T>.GetOwnsItems: Boolean;
begin
  Result := False;
end;

function TThemedGridArrayAdapter<T>.Extract(const AIndex: Integer): TValue;
begin
  raise ENotSupportedException.Create(ThemedGridDataStrings.ErrCannotConvert);
end;

procedure TThemedGridArrayAdapter<T>.Move(const AFromIndex, AToIndex: Integer);
begin
  raise ENotSupportedException.Create(ThemedGridDataStrings.ErrCannotConvert);
end;

end.

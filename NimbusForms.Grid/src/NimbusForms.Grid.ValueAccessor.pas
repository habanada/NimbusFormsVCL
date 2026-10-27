unit NimbusForms.Grid.ValueAccessor;

interface

uses
  System.SysUtils,
  System.Rtti,
  System.TypInfo,
  System.SyncObjs,
  System.Generics.Collections;

type
  IThemedGridValueAccessor = interface
    ['{4B2E6F1A-7C3D-4E85-9A10-5D6B8C2F3E71}']
    function GetValueType: PTypeInfo;
    function GetCanRead: Boolean;
    function GetCanWrite: Boolean;
    function GetIsDictionary: Boolean;
    function GetValue(const AInstance: TValue): TValue;
    function SetValue(const AInstance, AValue: TValue): Boolean;
    property ValueType: PTypeInfo read GetValueType;
    property CanRead: Boolean read GetCanRead;
    property CanWrite: Boolean read GetCanWrite;
    property IsDictionary: Boolean read GetIsDictionary;
  end;

  TThemedGridValueAccessorCache = class
  strict private
    class var FAccessors: TDictionary<string, IThemedGridValueAccessor>;
    class var FLock: TCriticalSection;
    class var FContext: TRttiContext;
    class var FEmpty: IThemedGridValueAccessor;
    class function CreateKey(const AInstance: TValue; const AFieldName: string): string; static;
    class function CreateAccessor(const AInstance: TValue; const AFieldName: string): IThemedGridValueAccessor; static;
  public
    class constructor Create;
    class destructor Destroy;
    class function Empty: IThemedGridValueAccessor; static;
    class function GetAccessor(const AInstance: TValue; const AFieldName: string): IThemedGridValueAccessor; static;
    class procedure Clear; static;
  end;

implementation

type
  TAccessorBase = class(TInterfacedObject, IThemedGridValueAccessor)
  protected
    FValueType: PTypeInfo;
    FCanRead: Boolean;
    FCanWrite: Boolean;
    FIsDictionary: Boolean;
    function GetValueType: PTypeInfo;
    function GetCanRead: Boolean;
    function GetCanWrite: Boolean;
    function GetIsDictionary: Boolean;
    function GetValue(const AInstance: TValue): TValue; virtual;
    function SetValue(const AInstance, AValue: TValue): Boolean; virtual;
  end;

  TEmptyAccessor = class(TAccessorBase);

  TPropertyAccessor = class(TAccessorBase)
  private
    FProperty: TRttiProperty;
  protected
    function GetValue(const AInstance: TValue): TValue; override;
    function SetValue(const AInstance, AValue: TValue): Boolean; override;
  public
    constructor Create(const AProperty: TRttiProperty; const AAllowWrite: Boolean);
  end;

  TFieldAccessor = class(TAccessorBase)
  private
    FField: TRttiField;
  protected
    function GetValue(const AInstance: TValue): TValue; override;
  public
    constructor Create(const AField: TRttiField);
  end;

  TDictionaryAccessor = class(TAccessorBase)
  private
    FKey: string;
  protected
    function GetValue(const AInstance: TValue): TValue; override;
    function SetValue(const AInstance, AValue: TValue): Boolean; override;
  public
    constructor Create(const AKey: string);
  end;

function InstancePointer(const AInstance: TValue): Pointer;
begin
  if AInstance.Kind = tkClass then
    Exit(Pointer(AInstance.AsObject));
  if AInstance.Kind = tkRecord then
    Exit(AInstance.GetReferenceToRawData);
  Result := nil;
end;

function AsDictionary(const AInstance: TValue): TDictionary<string, TValue>;
begin
  Result := nil;
  if (AInstance.Kind = tkClass) and (AInstance.AsObject is TDictionary<string, TValue>) then
    Result := TDictionary<string, TValue>(AInstance.AsObject);
end;

{ TAccessorBase }

function TAccessorBase.GetValueType: PTypeInfo;
begin
  Result := FValueType;
end;

function TAccessorBase.GetCanRead: Boolean;
begin
  Result := FCanRead;
end;

function TAccessorBase.GetCanWrite: Boolean;
begin
  Result := FCanWrite;
end;

function TAccessorBase.GetIsDictionary: Boolean;
begin
  Result := FIsDictionary;
end;

function TAccessorBase.GetValue(const AInstance: TValue): TValue;
begin
  Result := TValue.Empty;
end;

function TAccessorBase.SetValue(const AInstance, AValue: TValue): Boolean;
begin
  Result := False;
end;

{ TPropertyAccessor }

constructor TPropertyAccessor.Create(const AProperty: TRttiProperty; const AAllowWrite: Boolean);
begin
  inherited Create;
  FProperty := AProperty;
  if AProperty.PropertyType <> nil then
    FValueType := AProperty.PropertyType.Handle;
  FCanRead := AProperty.IsReadable;
  FCanWrite := AAllowWrite and AProperty.IsWritable;
end;

function TPropertyAccessor.GetValue(const AInstance: TValue): TValue;
var
  LPointer: Pointer;
begin
  Result := TValue.Empty;
  LPointer := InstancePointer(AInstance);
  if (not FCanRead) or (LPointer = nil) then
    Exit;
  Result := FProperty.GetValue(LPointer);
end;

function TPropertyAccessor.SetValue(const AInstance, AValue: TValue): Boolean;
var
  LPointer: Pointer;
begin
  LPointer := InstancePointer(AInstance);
  if (not FCanWrite) or (LPointer = nil) then
    Exit(False);
  FProperty.SetValue(LPointer, AValue);
  Result := True;
end;

{ TFieldAccessor }

constructor TFieldAccessor.Create(const AField: TRttiField);
begin
  inherited Create;
  FField := AField;
  if AField.FieldType <> nil then
    FValueType := AField.FieldType.Handle;
  FCanRead := True;
  FCanWrite := False;
end;

function TFieldAccessor.GetValue(const AInstance: TValue): TValue;
var
  LPointer: Pointer;
begin
  Result := TValue.Empty;
  LPointer := InstancePointer(AInstance);
  if LPointer = nil then
    Exit;
  Result := FField.GetValue(LPointer);
end;

{ TDictionaryAccessor }

constructor TDictionaryAccessor.Create(const AKey: string);
begin
  inherited Create;
  FKey := AKey;
  FValueType := nil;
  FCanRead := True;
  FCanWrite := True;
  FIsDictionary := True;
end;

function TDictionaryAccessor.GetValue(const AInstance: TValue): TValue;
var
  LDictionary: TDictionary<string, TValue>;
begin
  Result := TValue.Empty;
  LDictionary := AsDictionary(AInstance);
  if LDictionary = nil then
    Exit;
  if not LDictionary.TryGetValue(FKey, Result) then
    Result := TValue.Empty;
end;

function TDictionaryAccessor.SetValue(const AInstance, AValue: TValue): Boolean;
var
  LDictionary: TDictionary<string, TValue>;
begin
  LDictionary := AsDictionary(AInstance);
  if (LDictionary = nil) or (not LDictionary.ContainsKey(FKey)) then
    Exit(False);
  LDictionary[FKey] := AValue;
  Result := True;
end;

{ TThemedGridValueAccessorCache }

class constructor TThemedGridValueAccessorCache.Create;
begin
  FAccessors := TDictionary<string, IThemedGridValueAccessor>.Create;
  FLock := TCriticalSection.Create;
  FContext := TRttiContext.Create;
  FEmpty := TEmptyAccessor.Create;
end;

class destructor TThemedGridValueAccessorCache.Destroy;
begin
  FEmpty := nil;
  FAccessors.Free;
  FLock.Free;
  FContext.Free;
end;

class function TThemedGridValueAccessorCache.Empty: IThemedGridValueAccessor;
begin
  Result := FEmpty;
end;

class function TThemedGridValueAccessorCache.CreateKey(const AInstance: TValue; const AFieldName: string): string;
var
  LTypeKey: Pointer;
begin
  if (AInstance.Kind = tkClass) and (AInstance.AsObject <> nil) then
    LTypeKey := Pointer(AInstance.AsObject.ClassType)
  else
    LTypeKey := Pointer(AInstance.TypeInfo);
  Result := IntToHex(NativeUInt(LTypeKey), SizeOf(NativeUInt) * 2) + '|' + AFieldName;
end;

class function TThemedGridValueAccessorCache.CreateAccessor(const AInstance: TValue;
  const AFieldName: string): IThemedGridValueAccessor;
var
  LType: TRttiType;
  LProperty: TRttiProperty;
  LField: TRttiField;
begin
  if AsDictionary(AInstance) <> nil then
    Exit(TDictionaryAccessor.Create(AFieldName));

  if (AInstance.Kind = tkClass) and (AInstance.AsObject <> nil) then
    LType := FContext.GetType(AInstance.AsObject.ClassType)
  else if AInstance.Kind = tkRecord then
    LType := FContext.GetType(AInstance.TypeInfo)
  else
    LType := nil;
  if LType = nil then
    Exit(FEmpty);

  for LProperty in LType.GetProperties do
    if SameText(LProperty.Name, AFieldName) and (LProperty.Visibility in [mvPublic, mvPublished]) then
      Exit(TPropertyAccessor.Create(LProperty, not LType.IsRecord));

  if LType.IsRecord then
    for LField in LType.GetFields do
      if SameText(LField.Name, AFieldName) then
        Exit(TFieldAccessor.Create(LField));

  Result := FEmpty;
end;

class function TThemedGridValueAccessorCache.GetAccessor(const AInstance: TValue;
  const AFieldName: string): IThemedGridValueAccessor;
var
  LKey: string;
begin
  if (AInstance.TypeInfo = nil) or (AFieldName = '') then
    Exit(FEmpty);
  LKey := CreateKey(AInstance, AFieldName);
  FLock.Enter;
  try
    if FAccessors.TryGetValue(LKey, Result) then
      Exit;
    Result := CreateAccessor(AInstance, AFieldName);
    FAccessors.Add(LKey, Result);
  finally
    FLock.Leave;
  end;
end;

class procedure TThemedGridValueAccessorCache.Clear;
begin
  FLock.Enter;
  try
    FAccessors.Clear;
  finally
    FLock.Leave;
  end;
end;

end.

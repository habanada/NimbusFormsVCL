unit NimbusForms.HexEditor.Patch;

interface

uses
  System.SysUtils,
  System.Generics.Collections;

type
  THexPatchOperationType = (hpoWrite, hpoInsert, hpoDelete);

  THexPatchOperation = class
  private
    FOperationType: THexPatchOperationType;
    FOffset: Int64;
    FData: TBytes;
    FLength: Int64;
  public
    property OperationType: THexPatchOperationType read FOperationType write FOperationType;
    property Offset: Int64 read FOffset write FOffset;
    property Data: TBytes read FData write FData;
    property Length: Int64 read FLength write FLength;
  end;

  THexPatchFile = class
  private
    FOriginalFilePath: string;
    FOriginalLength: Int64;
    FOperations: TObjectList<THexPatchOperation>;
  public
    constructor Create;
    destructor Destroy; override;
    property OriginalFilePath: string read FOriginalFilePath write FOriginalFilePath;
    property OriginalLength: Int64 read FOriginalLength write FOriginalLength;
    property Operations: TObjectList<THexPatchOperation> read FOperations;
  end;

  THexPatchSerializer = class
  public
    class function ToJson(const APatch: THexPatchFile): string; static;
    class function FromJson(const AJson: string): THexPatchFile; static;
    class procedure Save(const AFilePath: string; const APatch: THexPatchFile); static;
    class function Load(const AFilePath: string): THexPatchFile; static;
  end;

implementation

uses
  System.IOUtils,
  System.NetEncoding,
  System.JSON;

const
  CKeyOriginalFilePath = 'OriginalFilePath';
  CKeyOriginalLength = 'OriginalLength';
  CKeyOperations = 'Operations';
  CKeyType = 'Type';
  CKeyOffset = 'Offset';
  CKeyData = 'Data';
  CKeyLength = 'Length';
  SPatchJsonRequired = 'json';
  SPatchPathRequired = 'filePath';

constructor THexPatchFile.Create;
begin
  inherited Create;
  FOperations := TObjectList<THexPatchOperation>.Create(True);
end;

destructor THexPatchFile.Destroy;
begin
  FOperations.Free;
  inherited Destroy;
end;

function Base64Encode(const AData: TBytes): string;
var
  LEncoding: TBase64Encoding;
begin
  LEncoding := TBase64Encoding.Create(0);
  try
    Result := LEncoding.EncodeBytesToString(AData);
  finally
    LEncoding.Free;
  end;
end;

function Base64Decode(const AText: string): TBytes;
var
  LEncoding: TBase64Encoding;
begin
  LEncoding := TBase64Encoding.Create(0);
  try
    Result := LEncoding.DecodeStringToBytes(AText);
  finally
    LEncoding.Free;
  end;
end;

class function THexPatchSerializer.ToJson(const APatch: THexPatchFile): string;
var
  LRoot: TJSONObject;
  LArray: TJSONArray;
  LOp: THexPatchOperation;
  LOpObject: TJSONObject;
begin
  if APatch = nil then
    raise EArgumentNilException.Create('patch');
  LRoot := TJSONObject.Create;
  try
    LRoot.AddPair(CKeyOriginalFilePath, APatch.OriginalFilePath);
    LRoot.AddPair(CKeyOriginalLength, TJSONNumber.Create(APatch.OriginalLength));
    LArray := TJSONArray.Create;
    for LOp in APatch.Operations do
    begin
      LOpObject := TJSONObject.Create;
      LOpObject.AddPair(CKeyType, TJSONNumber.Create(Ord(LOp.OperationType)));
      LOpObject.AddPair(CKeyOffset, TJSONNumber.Create(LOp.Offset));
      LOpObject.AddPair(CKeyLength, TJSONNumber.Create(LOp.Length));
      if System.Length(LOp.Data) > 0 then
        LOpObject.AddPair(CKeyData, Base64Encode(LOp.Data));
      LArray.AddElement(LOpObject);
    end;
    LRoot.AddPair(CKeyOperations, LArray);
    Result := LRoot.Format(2);
  finally
    LRoot.Free;
  end;
end;

class function THexPatchSerializer.FromJson(const AJson: string): THexPatchFile;
var
  LValue: TJSONValue;
  LRoot: TJSONObject;
  LArray: TJSONArray;
  LElement: TJSONValue;
  LOpObject: TJSONObject;
  LOp: THexPatchOperation;
  LText: string;
  LNumber: Int64;
  LInt: Integer;
begin
  if Trim(AJson) = '' then
    raise EArgumentException.Create(SPatchJsonRequired);
  LValue := TJSONObject.ParseJSONValue(AJson);
  if (LValue = nil) or (not (LValue is TJSONObject)) then
  begin
    LValue.Free;
    raise EArgumentException.Create(SPatchJsonRequired);
  end;
  Result := THexPatchFile.Create;
  try
    try
      LRoot := TJSONObject(LValue);
      if LRoot.TryGetValue<string>(CKeyOriginalFilePath, LText) then
        Result.OriginalFilePath := LText;
      if LRoot.TryGetValue<Int64>(CKeyOriginalLength, LNumber) then
        Result.OriginalLength := LNumber;
      if LRoot.TryGetValue<TJSONArray>(CKeyOperations, LArray) then
        for LElement in LArray do
        begin
          if not (LElement is TJSONObject) then
            Continue;
          LOpObject := TJSONObject(LElement);
          LOp := THexPatchOperation.Create;
          if LOpObject.TryGetValue<Integer>(CKeyType, LInt) then
            LOp.OperationType := THexPatchOperationType(LInt);
          if LOpObject.TryGetValue<Int64>(CKeyOffset, LNumber) then
            LOp.Offset := LNumber;
          if LOpObject.TryGetValue<Int64>(CKeyLength, LNumber) then
            LOp.Length := LNumber;
          if LOpObject.TryGetValue<string>(CKeyData, LText) and (LText <> '') then
            LOp.Data := Base64Decode(LText);
          Result.Operations.Add(LOp);
        end;
    except
      Result.Free;
      raise;
    end;
  finally
    LValue.Free;
  end;
end;

class procedure THexPatchSerializer.Save(const AFilePath: string; const APatch: THexPatchFile);
begin
  if Trim(AFilePath) = '' then
    raise EArgumentException.Create(SPatchPathRequired);
  TFile.WriteAllText(AFilePath, ToJson(APatch), TEncoding.UTF8);
end;

class function THexPatchSerializer.Load(const AFilePath: string): THexPatchFile;
begin
  if Trim(AFilePath) = '' then
    raise EArgumentException.Create(SPatchPathRequired);
  Result := FromJson(TFile.ReadAllText(AFilePath, TEncoding.UTF8));
end;

end.

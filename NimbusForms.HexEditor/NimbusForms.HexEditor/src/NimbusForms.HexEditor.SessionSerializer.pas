unit NimbusForms.HexEditor.SessionSerializer;

interface

uses
  System.SysUtils,
  NimbusForms.HexEditor.Session;

type
  THexSessionSerializer = class
  public
    class function ToJson(const ASession: THexSessionData): string; static;
    class function FromJson(const AJson: string): THexSessionData; static;
    class procedure Save(const AFilePath: string; const ASession: THexSessionData); static;
    class function Load(const AFilePath: string): THexSessionData; static;
  end;

implementation

uses
  System.Classes,
  System.IOUtils,
  System.NetEncoding,
  System.JSON,
  System.Generics.Collections,
  NimbusForms.HexEditor.Pieces;

const
  SJsonRequired = 'json';
  SPathRequired = 'filePath';

function Base64Encode(const AData: TBytes): string;
var
  LEncoding: TBase64Encoding;
begin
  if AData = nil then
    Exit('');
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
  if AText = '' then
    Exit(nil);
  LEncoding := TBase64Encoding.Create(0);
  try
    Result := LEncoding.DecodeStringToBytes(AText);
  finally
    LEncoding.Free;
  end;
end;

function PieceToJson(const APiece: THexPieceInfo): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('Source', TJSONNumber.Create(Ord(APiece.Source)));
  Result.AddPair('SourceOffset', TJSONNumber.Create(APiece.SourceOffset));
  Result.AddPair('Length', TJSONNumber.Create(APiece.Length));
end;

procedure JsonToPiece(const AObject: TJSONObject; const ATarget: TObjectList<THexPieceInfo>);
var
  LPiece: THexPieceInfo;
  LInt: Integer;
  LNum: Int64;
begin
  LPiece := THexPieceInfo.Create;
  if AObject.TryGetValue<Integer>('Source', LInt) then
    LPiece.Source := THexPieceSource(LInt);
  if AObject.TryGetValue<Int64>('SourceOffset', LNum) then
    LPiece.SourceOffset := LNum;
  if AObject.TryGetValue<Int64>('Length', LNum) then
    LPiece.Length := LNum;
  ATarget.Add(LPiece);
end;

function PiecesToJson(const APieces: TObjectList<THexPieceInfo>): TJSONArray;
var
  I: Integer;
begin
  Result := TJSONArray.Create;
  for I := 0 to APieces.Count - 1 do
    Result.AddElement(PieceToJson(APieces[I]));
end;

procedure JsonToPieces(const AArray: TJSONArray; const ATarget: TObjectList<THexPieceInfo>);
var
  LValue: TJSONValue;
begin
  if AArray = nil then
    Exit;
  for LValue in AArray do
    if LValue is TJSONObject then
      JsonToPiece(TJSONObject(LValue), ATarget);
end;

function OperationToJson(const AOp: THexEditOperation): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('Type', TJSONNumber.Create(Ord(AOp.OperationType)));
  Result.AddPair('Offset', TJSONNumber.Create(AOp.Offset));
  Result.AddPair('OldLength', TJSONNumber.Create(AOp.OldLength));
  Result.AddPair('NewLength', TJSONNumber.Create(AOp.NewLength));
  Result.AddPair('OldPieces', PiecesToJson(AOp.OldPieces));
  Result.AddPair('NewPieces', PiecesToJson(AOp.NewPieces));
end;

procedure JsonToOperations(const AArray: TJSONArray; const ATarget: TObjectList<THexEditOperation>);
var
  LValue: TJSONValue;
  LObject: TJSONObject;
  LOp: THexEditOperation;
  LInt: Integer;
  LNum: Int64;
  LPieces: TJSONArray;
begin
  if AArray = nil then
    Exit;
  for LValue in AArray do
  begin
    if not (LValue is TJSONObject) then
      Continue;
    LObject := TJSONObject(LValue);
    LOp := THexEditOperation.Create;
    if LObject.TryGetValue<Integer>('Type', LInt) then
      LOp.OperationType := THexEditOperationType(LInt);
    if LObject.TryGetValue<Int64>('Offset', LNum) then
      LOp.Offset := LNum;
    if LObject.TryGetValue<Int64>('OldLength', LNum) then
      LOp.OldLength := LNum;
    if LObject.TryGetValue<Int64>('NewLength', LNum) then
      LOp.NewLength := LNum;
    if LObject.TryGetValue<TJSONArray>('OldPieces', LPieces) then
      JsonToPieces(LPieces, LOp.OldPieces);
    if LObject.TryGetValue<TJSONArray>('NewPieces', LPieces) then
      JsonToPieces(LPieces, LOp.NewPieces);
    ATarget.Add(LOp);
  end;
end;

function OperationsToJson(const AOperations: TObjectList<THexEditOperation>): TJSONArray;
var
  I: Integer;
begin
  Result := TJSONArray.Create;
  for I := 0 to AOperations.Count - 1 do
    Result.AddElement(OperationToJson(AOperations[I]));
end;

function BookmarksToJson(const ABookmarks: TObjectList<THexBookmarkData>): TJSONArray;
var
  I: Integer;
  LObj: TJSONObject;
begin
  Result := TJSONArray.Create;
  for I := 0 to ABookmarks.Count - 1 do
  begin
    LObj := TJSONObject.Create;
    LObj.AddPair('Offset', TJSONNumber.Create(ABookmarks[I].Offset));
    LObj.AddPair('Argb', TJSONNumber.Create(ABookmarks[I].Argb));
    LObj.AddPair('Name', ABookmarks[I].Name);
    Result.AddElement(LObj);
  end;
end;

procedure JsonToBookmarks(const AArray: TJSONArray; const ATarget: TObjectList<THexBookmarkData>);
var
  LValue: TJSONValue;
  LObject: TJSONObject;
  LBookmark: THexBookmarkData;
  LInt: Integer;
  LNum: Int64;
  LText: string;
begin
  if AArray = nil then
    Exit;
  for LValue in AArray do
  begin
    if not (LValue is TJSONObject) then
      Continue;
    LObject := TJSONObject(LValue);
    LBookmark := THexBookmarkData.Create;
    if LObject.TryGetValue<Int64>('Offset', LNum) then
      LBookmark.Offset := LNum;
    if LObject.TryGetValue<Integer>('Argb', LInt) then
      LBookmark.Argb := LInt;
    if LObject.TryGetValue<string>('Name', LText) then
      LBookmark.Name := LText;
    ATarget.Add(LBookmark);
  end;
end;

class function THexSessionSerializer.ToJson(const ASession: THexSessionData): string;
var
  LRoot: TJSONObject;
begin
  if ASession = nil then
    raise EArgumentNilException.Create('session');
  LRoot := TJSONObject.Create;
  try
    LRoot.AddPair('OriginalFilePath', ASession.OriginalFilePath);
    LRoot.AddPair('CreateBackup', TJSONBool.Create(ASession.CreateBackup));
    LRoot.AddPair('MemoryBuffer', Base64Encode(ASession.MemoryBuffer));
    LRoot.AddPair('Pieces', PiecesToJson(ASession.Pieces));
    LRoot.AddPair('UndoStack', OperationsToJson(ASession.UndoStack));
    LRoot.AddPair('RedoStack', OperationsToJson(ASession.RedoStack));
    LRoot.AddPair('CursorOffset', TJSONNumber.Create(ASession.CursorOffset));
    LRoot.AddPair('SelectionStart', TJSONNumber.Create(ASession.SelectionStart));
    LRoot.AddPair('SelectionLength', TJSONNumber.Create(ASession.SelectionLength));
    LRoot.AddPair('Bookmarks', BookmarksToJson(ASession.Bookmarks));
    Result := LRoot.Format(2);
  finally
    LRoot.Free;
  end;
end;

class function THexSessionSerializer.FromJson(const AJson: string): THexSessionData;
var
  LValue: TJSONValue;
  LRoot: TJSONObject;
  LText: string;
  LBool: Boolean;
  LNum: Int64;
  LArray: TJSONArray;
begin
  if Trim(AJson) = '' then
    raise EArgumentException.Create(SJsonRequired);
  LValue := TJSONObject.ParseJSONValue(AJson);
  if (LValue = nil) or not (LValue is TJSONObject) then
  begin
    LValue.Free;
    raise EArgumentException.Create(SJsonRequired);
  end;
  Result := THexSessionData.Create;
  try
    try
      LRoot := TJSONObject(LValue);
      if LRoot.TryGetValue<string>('OriginalFilePath', LText) then
        Result.OriginalFilePath := LText;
      if LRoot.TryGetValue<Boolean>('CreateBackup', LBool) then
        Result.CreateBackup := LBool;
      if LRoot.TryGetValue<string>('MemoryBuffer', LText) then
        Result.MemoryBuffer := Base64Decode(LText);
      if LRoot.TryGetValue<TJSONArray>('Pieces', LArray) then
        JsonToPieces(LArray, Result.Pieces);
      if LRoot.TryGetValue<TJSONArray>('UndoStack', LArray) then
        JsonToOperations(LArray, Result.UndoStack);
      if LRoot.TryGetValue<TJSONArray>('RedoStack', LArray) then
        JsonToOperations(LArray, Result.RedoStack);
      if LRoot.TryGetValue<Int64>('CursorOffset', LNum) then
        Result.CursorOffset := LNum;
      if LRoot.TryGetValue<Int64>('SelectionStart', LNum) then
        Result.SelectionStart := LNum;
      if LRoot.TryGetValue<Int64>('SelectionLength', LNum) then
        Result.SelectionLength := LNum;
      if LRoot.TryGetValue<TJSONArray>('Bookmarks', LArray) then
        JsonToBookmarks(LArray, Result.Bookmarks);
    except
      Result.Free;
      raise;
    end;
  finally
    LValue.Free;
  end;
end;

class procedure THexSessionSerializer.Save(const AFilePath: string; const ASession: THexSessionData);
begin
  if Trim(AFilePath) = '' then
    raise EArgumentException.Create(SPathRequired);
  TFile.WriteAllText(AFilePath, ToJson(ASession), TEncoding.UTF8);
end;

class function THexSessionSerializer.Load(const AFilePath: string): THexSessionData;
begin
  if Trim(AFilePath) = '' then
    raise EArgumentException.Create(SPathRequired);
  Result := FromJson(TFile.ReadAllText(AFilePath, TEncoding.UTF8));
end;

end.

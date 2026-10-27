unit NimbusForms.HexEditor.Session;

interface

uses
  System.SysUtils, System.Generics.Collections, NimbusForms.Theming.Types,
  NimbusForms.HexEditor.DataSource, NimbusForms.HexEditor.Pieces, NimbusForms.HexEditor.Undo;

type
  THexSessionBookmark = record
    Offset: Int64;
    Name: string;
    Color: TThemeColor;
    HasColor: Boolean;
  end;

  THexSessionData = class
  public
    OriginalFilePath: string;
    CreateBackup: Boolean;
    OriginalData: TBytes;
    MemoryBuffer: TBytes;
    Pieces: TObjectList<THexPieceInfo>;
    UndoStack: TObjectList<TEditCommand>;
    RedoStack: TObjectList<TEditCommand>;
    Bookmarks: TArray<THexSessionBookmark>;
    ModifiedOffsets: TArray<Int64>;
    CursorOffset: Int64;
    SelectionStart: Int64;
    SelectionLength: Int64;
    TopRow: Int64;
    HorizontalOffset: Integer;
    InsertMode: Boolean;
    AsciiArea: Boolean;
    ReadOnly: Boolean;
    BytesPerRow: Integer;
    ByteGroupSize: Integer;
    EncodingName: string;
    constructor Create;
    destructor Destroy; override;
    class function Capture(const ASource: IHexDataSource): THexSessionData; static;
    function RestoreSource: IHexDataSource;
    procedure Validate;
  end;

  THexProjectData = class
  public
    ProjectName: string;
    Session: THexSessionData;
    constructor Create;
    destructor Destroy; override;
  end;

  THexSessionSerializer = class
  public
    class function ToJson(const AData: THexSessionData): string; static;
    class function FromJson(const AJson: string): THexSessionData; static;
    class procedure Save(const APath: string; const AData: THexSessionData); static;
    class function Load(const APath: string): THexSessionData; static;
  end;

  THexProjectSerializer = class
  public
    class function ToJson(const AData: THexProjectData): string; static;
    class function FromJson(const AJson: string): THexProjectData; static;
    class procedure Save(const APath: string; const AData: THexProjectData); static;
    class function Load(const APath: string): THexProjectData; static;
  end;

implementation

uses
  System.Classes, System.JSON, System.IOUtils, System.NetEncoding,
  NimbusForms.HexEditor.Document, NimbusForms.HexEditor.SearchService, NimbusForms.HexEditor.Encoding;

constructor THexSessionData.Create;
begin
  inherited Create;
  Pieces := TObjectList<THexPieceInfo>.Create(True);
  UndoStack := TObjectList<TEditCommand>.Create(True);
  RedoStack := TObjectList<TEditCommand>.Create(True);
  CursorOffset := -1;
  CreateBackup := True;
  BytesPerRow := 16;
  ByteGroupSize := 4;
  EncodingName := 'UTF-8';
end;

destructor THexSessionData.Destroy;
begin
  RedoStack.Free;
  UndoStack.Free;
  Pieces.Free;
  inherited Destroy;
end;

class function THexSessionData.Capture(const ASource: IHexDataSource): THexSessionData;
var
  LDocument: IHexDocumentAccess;
  LOriginal: IHexDataSource;
  LInfo: THexPieceInfo;
  LExport: TObjectList<THexPieceInfo>;
begin
  if ASource = nil then raise EArgumentNilException.Create('ASource');
  Result := THexSessionData.Create;
  try
    LOriginal := ASource;
    if Supports(ASource, IHexDocumentAccess, LDocument) then
    begin
      Result.OriginalFilePath := LDocument.GetFilePath;
      Result.CreateBackup := LDocument.GetBackup;
      LOriginal := LDocument.GetOriginalSource;
      Result.MemoryBuffer := LDocument.ExportMemoryBuffer;
      LExport := LDocument.ExportPieces;
      try
        for LInfo in LExport do Result.Pieces.Add(LInfo.Clone);
      finally
        LExport.Free;
      end;
    end
    else if ASource.Length > 0 then
    begin
      LInfo := THexPieceInfo.Create;
      LInfo.Source := hpsOriginal;
      LInfo.SourceOffset := 0;
      LInfo.Length := ASource.Length;
      Result.Pieces.Add(LInfo);
    end;
    if Result.OriginalFilePath = '' then Result.OriginalData := THexSearchService.ReadAll(LOriginal);
  except
    Result.Free;
    raise;
  end;
end;

function THexSessionData.RestoreSource: IHexDataSource;
var
  LDocument: THexDocument;
begin
  if OriginalFilePath <> '' then LDocument := THexDocument.Create(OriginalFilePath)
  else LDocument := THexDocument.Create(TBytesHexDataSource.Create(OriginalData));
  Result := LDocument;
  LDocument.CreateBackup := CreateBackup;
  LDocument.RestoreState(MemoryBuffer, Pieces);
end;

procedure THexSessionData.Validate;
var
  LSource: IHexDataSource;
  LDocument: IHexDocumentAccess;
  LCodec: THexTextEncoding;
  LCommand: TEditCommand;
  LExpected, LReplacement, LActual: TBytes;
  LBookmark: THexSessionBookmark;
  LOffset: Int64;
  LRead: Integer;
  I, J: Integer;
  LStack: TObjectList<TEditCommand>;
begin
  if (BytesPerRow < 1) or (BytesPerRow > 64) or (ByteGroupSize < 1) or (ByteGroupSize > 16) or
    (TopRow < 0) or (HorizontalOffset < 0) then raise EConvertError.Create('Invalid session options');
  LCodec := THexTextEncoding.Create(EncodingName);
  LCodec.Free;
  LSource := RestoreSource;
  if (SelectionStart < 0) or (SelectionStart > LSource.Length) or (SelectionLength < 0) or
    (SelectionLength > LSource.Length - SelectionStart) or (CursorOffset < -1) or (CursorOffset > LSource.Length) then
    raise EConvertError.Create('Invalid session selection');
  for LBookmark in Bookmarks do
    if (LBookmark.Offset < 0) or (LBookmark.Offset >= LSource.Length) then raise EConvertError.Create('Invalid session bookmark');
  for LOffset in ModifiedOffsets do
    if (LOffset < 0) or (LOffset >= LSource.Length) then raise EConvertError.Create('Invalid modified offset');
  for J := 0 to 1 do
  begin
    LSource := RestoreSource;
    Supports(LSource, IHexDocumentAccess, LDocument);
    if J = 0 then LStack := UndoStack else LStack := RedoStack;
    for I := LStack.Count - 1 downto 0 do
    begin
      LCommand := LStack[I];
      if (LCommand.Offset < 0) or (LCommand.Offset > LSource.Length) then raise EConvertError.Create('Invalid history offset');
      if J = 0 then
      begin LExpected := LCommand.NewData; LReplacement := LCommand.OldData; end
      else begin LExpected := LCommand.OldData; LReplacement := LCommand.NewData; end;
      case LCommand.Kind of
        ekOverwrite: if Length(LExpected) <> Length(LReplacement) then raise EConvertError.Create('Invalid overwrite command');
        ekInsert: if Length(LCommand.OldData) <> 0 then raise EConvertError.Create('Invalid insert command');
        ekDelete: if Length(LCommand.NewData) <> 0 then raise EConvertError.Create('Invalid delete command');
        ekReplace: ;
      else raise EConvertError.Create('Invalid history kind');
      end;
      if Length(LExpected) > LSource.Length - LCommand.Offset then raise EConvertError.Create('History exceeds document');
      if Length(LExpected) > 0 then
      begin
        SetLength(LActual, Length(LExpected));
        LRead := LSource.Read(LCommand.Offset, LActual, Length(LExpected));
        if (LRead <> Length(LExpected)) or not CompareMem(@LActual[0], @LExpected[0], Length(LExpected)) then
          raise EConvertError.Create('History does not match document bytes');
      end;
      LDocument.ReplaceBytes(LCommand.Offset, Length(LExpected), LReplacement);
    end;
  end;
end;

constructor THexProjectData.Create;
begin
  inherited Create;
  Session := THexSessionData.Create;
end;

destructor THexProjectData.Destroy;
begin
  Session.Free;
  inherited Destroy;
end;

function Required(const AObject: TJSONObject; const AName: string): TJSONValue;
begin
  Result := AObject.GetValue(AName);
  if Result = nil then raise EConvertError.Create('Missing session field: ' + AName);
end;

function Number(const AObject: TJSONObject; const AName: string): Int64;
begin
  Result := StrToInt64(Required(AObject, AName).Value);
end;

function Bytes(const AObject: TJSONObject; const AName: string): TBytes;
begin
  Result := TNetEncoding.Base64.DecodeStringToBytes(Required(AObject, AName).Value);
end;

function CommandsToJson(const ACommands: TObjectList<TEditCommand>): TJSONArray;
var
  LCommand: TEditCommand;
  LObject: TJSONObject;
begin
  Result := TJSONArray.Create;
  try
    for LCommand in ACommands do
    begin
      LObject := TJSONObject.Create;
      Result.AddElement(LObject);
      LObject.AddPair('Kind', TJSONNumber.Create(Ord(LCommand.Kind)));
      LObject.AddPair('Offset', TJSONNumber.Create(LCommand.Offset));
      LObject.AddPair('OldData', TNetEncoding.Base64.EncodeBytesToString(LCommand.OldData));
      LObject.AddPair('NewData', TNetEncoding.Base64.EncodeBytesToString(LCommand.NewData));
    end;
  except
    Result.Free;
    raise;
  end;
end;

procedure CommandsFromJson(const AArray: TJSONArray; const ACommands: TObjectList<TEditCommand>);
var
  LValue: TJSONValue;
  LObject: TJSONObject;
  LKind: Int64;
begin
  for LValue in AArray do
  begin
    if not (LValue is TJSONObject) then raise EConvertError.Create('Invalid command');
    LObject := TJSONObject(LValue);
    LKind := Number(LObject, 'Kind');
    if (LKind < Ord(Low(TEditKind))) or (LKind > Ord(High(TEditKind))) or (Number(LObject, 'Offset') < 0) then
      raise EConvertError.Create('Invalid command kind or offset');
    ACommands.Add(TEditCommand.Create(TEditKind(LKind), Number(LObject, 'Offset'), Bytes(LObject, 'OldData'), Bytes(LObject, 'NewData')));
  end;
end;

class function THexSessionSerializer.ToJson(const AData: THexSessionData): string;
var
  LRoot, LObject: TJSONObject;
  LPieces, LBookmarks, LModified: TJSONArray;
  LInfo: THexPieceInfo;
  LBookmark: THexSessionBookmark;
  LOffset: Int64;
begin
  if AData = nil then raise EArgumentNilException.Create('AData');
  LRoot := TJSONObject.Create;
  try
    LRoot.AddPair('Format', 'NimbusForms VCL Hex Session');
    LRoot.AddPair('Version', TJSONNumber.Create(1));
    LRoot.AddPair('OriginalFilePath', AData.OriginalFilePath);
    LRoot.AddPair('CreateBackup', TJSONBool.Create(AData.CreateBackup));
    LRoot.AddPair('OriginalData', TNetEncoding.Base64.EncodeBytesToString(AData.OriginalData));
    LRoot.AddPair('MemoryBuffer', TNetEncoding.Base64.EncodeBytesToString(AData.MemoryBuffer));
    LRoot.AddPair('CursorOffset', TJSONNumber.Create(AData.CursorOffset));
    LRoot.AddPair('SelectionStart', TJSONNumber.Create(AData.SelectionStart));
    LRoot.AddPair('SelectionLength', TJSONNumber.Create(AData.SelectionLength));
    LRoot.AddPair('TopRow', TJSONNumber.Create(AData.TopRow));
    LRoot.AddPair('HorizontalOffset', TJSONNumber.Create(AData.HorizontalOffset));
    LRoot.AddPair('InsertMode', TJSONBool.Create(AData.InsertMode));
    LRoot.AddPair('AsciiArea', TJSONBool.Create(AData.AsciiArea));
    LRoot.AddPair('ReadOnly', TJSONBool.Create(AData.ReadOnly));
    LRoot.AddPair('BytesPerRow', TJSONNumber.Create(AData.BytesPerRow));
    LRoot.AddPair('ByteGroupSize', TJSONNumber.Create(AData.ByteGroupSize));
    LRoot.AddPair('EncodingName', AData.EncodingName);
    LPieces := TJSONArray.Create;
    LRoot.AddPair('Pieces', LPieces);
    for LInfo in AData.Pieces do
    begin
      LObject := TJSONObject.Create;
      LPieces.AddElement(LObject);
      LObject.AddPair('Source', TJSONNumber.Create(Ord(LInfo.Source)));
      LObject.AddPair('SourceOffset', TJSONNumber.Create(LInfo.SourceOffset));
      LObject.AddPair('Length', TJSONNumber.Create(LInfo.Length));
    end;
    LRoot.AddPair('UndoStack', CommandsToJson(AData.UndoStack));
    LRoot.AddPair('RedoStack', CommandsToJson(AData.RedoStack));
    LBookmarks := TJSONArray.Create;
    LRoot.AddPair('Bookmarks', LBookmarks);
    for LBookmark in AData.Bookmarks do
    begin
      LObject := TJSONObject.Create;
      LBookmarks.AddElement(LObject);
      LObject.AddPair('Offset', TJSONNumber.Create(LBookmark.Offset));
      LObject.AddPair('Name', LBookmark.Name);
      LObject.AddPair('Color', TJSONNumber.Create(Int64(LBookmark.Color)));
      LObject.AddPair('HasColor', TJSONBool.Create(LBookmark.HasColor));
    end;
    LModified := TJSONArray.Create;
    LRoot.AddPair('ModifiedOffsets', LModified);
    for LOffset in AData.ModifiedOffsets do LModified.AddElement(TJSONNumber.Create(LOffset));
    Result := LRoot.ToJSON;
  finally
    LRoot.Free;
  end;
end;

class function THexSessionSerializer.FromJson(const AJson: string): THexSessionData;
var
  LValue, LEntry: TJSONValue;
  LRoot, LObject: TJSONObject;
  LInfo: THexPieceInfo;
  LArray: TJSONArray;
  LSource: Int64;
  I: Integer;
begin
  Result := nil;
  LValue := TJSONObject.ParseJSONValue(AJson);
  try
    if not (LValue is TJSONObject) then raise EConvertError.Create('Invalid session JSON');
    LRoot := TJSONObject(LValue);
    if (Required(LRoot, 'Format').Value <> 'NimbusForms VCL Hex Session') or (Number(LRoot, 'Version') <> 1) then
      raise EConvertError.Create('Unsupported session format');
    Result := THexSessionData.Create;
    try
      Result.OriginalFilePath := Required(LRoot, 'OriginalFilePath').Value;
      Result.CreateBackup := Required(LRoot, 'CreateBackup').Value = 'true';
      Result.OriginalData := Bytes(LRoot, 'OriginalData');
      Result.MemoryBuffer := Bytes(LRoot, 'MemoryBuffer');
      Result.CursorOffset := Number(LRoot, 'CursorOffset');
      Result.SelectionStart := Number(LRoot, 'SelectionStart');
      Result.SelectionLength := Number(LRoot, 'SelectionLength');
      Result.TopRow := Number(LRoot, 'TopRow');
      Result.HorizontalOffset := Number(LRoot, 'HorizontalOffset');
      Result.InsertMode := (Required(LRoot, 'InsertMode').Value = 'true');
      Result.AsciiArea := (Required(LRoot, 'AsciiArea').Value = 'true');
      Result.ReadOnly := (Required(LRoot, 'ReadOnly').Value = 'true');
      Result.BytesPerRow := Number(LRoot, 'BytesPerRow');
      Result.ByteGroupSize := Number(LRoot, 'ByteGroupSize');
      Result.EncodingName := Required(LRoot, 'EncodingName').Value;
      if (Result.SelectionStart < 0) or (Result.SelectionLength < 0) or (Result.CursorOffset < -1) or
        (Result.TopRow < 0) or (Result.HorizontalOffset < 0) or (Result.BytesPerRow < 1) or
        (Result.BytesPerRow > 64) or (Result.ByteGroupSize < 1) or (Result.ByteGroupSize > 16) then
        raise EConvertError.Create('Invalid session state');
      for LEntry in Required(LRoot, 'Pieces') as TJSONArray do
      begin
        LObject := LEntry as TJSONObject;
        LSource := Number(LObject, 'Source');
        if (LSource < 0) or (LSource > Ord(High(THexPieceSource))) then raise EConvertError.Create('Invalid piece source');
        LInfo := THexPieceInfo.Create;
        Result.Pieces.Add(LInfo);
        LInfo.Source := THexPieceSource(LSource);
        LInfo.SourceOffset := Number(LObject, 'SourceOffset');
        LInfo.Length := Number(LObject, 'Length');
      end;
      CommandsFromJson(Required(LRoot, 'UndoStack') as TJSONArray, Result.UndoStack);
      CommandsFromJson(Required(LRoot, 'RedoStack') as TJSONArray, Result.RedoStack);
      LArray := Required(LRoot, 'Bookmarks') as TJSONArray;
      SetLength(Result.Bookmarks, LArray.Count);
      for I := 0 to LArray.Count - 1 do
      begin
        LObject := LArray.Items[I] as TJSONObject;
        Result.Bookmarks[I].Offset := Number(LObject, 'Offset');
        Result.Bookmarks[I].Name := Required(LObject, 'Name').Value;
        Result.Bookmarks[I].Color := TThemeColor(Number(LObject, 'Color'));
        Result.Bookmarks[I].HasColor := (Required(LObject, 'HasColor').Value = 'true');
      end;
      LArray := Required(LRoot, 'ModifiedOffsets') as TJSONArray;
      SetLength(Result.ModifiedOffsets, LArray.Count);
      for I := 0 to LArray.Count - 1 do Result.ModifiedOffsets[I] := StrToInt64(LArray.Items[I].Value);
    except
      Result.Free;
      Result := nil;
      raise;
    end;
  finally
    LValue.Free;
  end;
end;

class procedure THexSessionSerializer.Save(const APath: string; const AData: THexSessionData);
begin
  TFile.WriteAllText(APath, ToJson(AData), TEncoding.UTF8);
end;

class function THexSessionSerializer.Load(const APath: string): THexSessionData;
begin
  Result := FromJson(TFile.ReadAllText(APath, TEncoding.UTF8));
end;

class function THexProjectSerializer.ToJson(const AData: THexProjectData): string;
var
  LRoot: TJSONObject;
begin
  if AData = nil then raise EArgumentNilException.Create('AData');
  LRoot := TJSONObject.Create;
  try
    LRoot.AddPair('Format', 'NimbusForms VCL Hex Project');
    LRoot.AddPair('Version', TJSONNumber.Create(1));
    LRoot.AddPair('ProjectName', AData.ProjectName);
    LRoot.AddPair('Session', TJSONObject.ParseJSONValue(THexSessionSerializer.ToJson(AData.Session)));
    Result := LRoot.ToJSON;
  finally
    LRoot.Free;
  end;
end;

class function THexProjectSerializer.FromJson(const AJson: string): THexProjectData;
var
  LValue: TJSONValue;
  LRoot: TJSONObject;
begin
  LValue := TJSONObject.ParseJSONValue(AJson);
  try
    if not (LValue is TJSONObject) then raise EConvertError.Create('Invalid project JSON');
    LRoot := TJSONObject(LValue);
    if (Required(LRoot, 'Format').Value <> 'NimbusForms VCL Hex Project') or (Number(LRoot, 'Version') <> 1) then
      raise EConvertError.Create('Unsupported project format');
    Result := THexProjectData.Create;
    try
      Result.ProjectName := Required(LRoot, 'ProjectName').Value;
      Result.Session.Free;
      Result.Session := nil;
      Result.Session := THexSessionSerializer.FromJson(Required(LRoot, 'Session').ToJSON);
    except
      Result.Free;
      raise;
    end;
  finally
    LValue.Free;
  end;
end;

class procedure THexProjectSerializer.Save(const APath: string; const AData: THexProjectData);
begin
  TFile.WriteAllText(APath, ToJson(AData), TEncoding.UTF8);
end;

class function THexProjectSerializer.Load(const APath: string): THexProjectData;
begin
  Result := FromJson(TFile.ReadAllText(APath, TEncoding.UTF8));
end;

end.

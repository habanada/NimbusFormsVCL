unit NimbusForms.Grid.DragData;

interface

uses
  System.SysUtils;

type
  TThemedGridDragData = class sealed
  private
    FSourceId: TGUID;
    FText: string;
    FRowCount: Integer;
    FColumnCount: Integer;
    FColumnNames: TArray<string>;
    FSourceRowIndex: Integer;
    FSourceColumnIndex: Integer;
    FSourceDataSourceIndexes: TArray<Integer>;
  public
    const
      DataFormatName = 'NimbusForms.ThemedGrid.CellBlock';
    constructor Create;
    function SaveToBytes: TBytes;
    class function TryLoadFromBytes(const ABytes: TBytes): TThemedGridDragData; static;
    property SourceId: TGUID read FSourceId write FSourceId;
    property Text: string read FText write FText;
    property RowCount: Integer read FRowCount write FRowCount;
    property ColumnCount: Integer read FColumnCount write FColumnCount;
    property ColumnNames: TArray<string> read FColumnNames write FColumnNames;
    property SourceRowIndex: Integer read FSourceRowIndex write FSourceRowIndex;
    property SourceColumnIndex: Integer read FSourceColumnIndex write FSourceColumnIndex;
    property SourceDataSourceIndexes: TArray<Integer> read FSourceDataSourceIndexes write FSourceDataSourceIndexes;
  end;

  TThemedGridRowMoveData = class sealed
  private
    FSourceId: TGUID;
    FSourceRowIndex: Integer;
    FSourceDataSourceIndex: Integer;
    FText: string;
  public
    const
      DataFormatName = 'NimbusForms.ThemedGrid.RowMove';
    constructor Create;
    function SaveToBytes: TBytes;
    class function TryLoadFromBytes(const ABytes: TBytes): TThemedGridRowMoveData; static;
    property SourceId: TGUID read FSourceId write FSourceId;
    property SourceRowIndex: Integer read FSourceRowIndex write FSourceRowIndex;
    property SourceDataSourceIndex: Integer read FSourceDataSourceIndex write FSourceDataSourceIndex;
    property Text: string read FText write FText;
  end;

implementation

uses
  System.Classes;

constructor TThemedGridDragData.Create;
begin
  inherited Create;
  FSourceId := Default(TGUID);
  FSourceRowIndex := -1;
  FSourceColumnIndex := -1;
end;

function TThemedGridDragData.SaveToBytes: TBytes;
var
  LStream: TBytesStream;
  LWriter: TBinaryWriter;
  I: Integer;
begin
  LStream := TBytesStream.Create;
  try
    LWriter := TBinaryWriter.Create(LStream, TEncoding.UTF8, False);
    try
      LWriter.Write(GUIDToString(FSourceId));
      LWriter.Write(FText);
      LWriter.Write(FRowCount);
      LWriter.Write(FColumnCount);
      LWriter.Write(FSourceRowIndex);
      LWriter.Write(FSourceColumnIndex);
      LWriter.Write(Length(FColumnNames));
      for I := 0 to High(FColumnNames) do
        LWriter.Write(FColumnNames[I]);
      LWriter.Write(Length(FSourceDataSourceIndexes));
      for I := 0 to High(FSourceDataSourceIndexes) do
        LWriter.Write(FSourceDataSourceIndexes[I]);
    finally
      LWriter.Free;
    end;
    Result := Copy(LStream.Bytes, 0, LStream.Size);
  finally
    LStream.Free;
  end;
end;

class function TThemedGridDragData.TryLoadFromBytes(const ABytes: TBytes): TThemedGridDragData;
var
  LStream: TBytesStream;
  LReader: TBinaryReader;
  LCount, I: Integer;
begin
  Result := nil;
  if Length(ABytes) = 0 then
    Exit;
  LStream := TBytesStream.Create(ABytes);
  try
    LReader := TBinaryReader.Create(LStream, TEncoding.UTF8, False);
    try
      Result := TThemedGridDragData.Create;
      try
        Result.FSourceId := StringToGUID(LReader.ReadString);
        Result.FText := LReader.ReadString;
        Result.FRowCount := LReader.ReadInteger;
        Result.FColumnCount := LReader.ReadInteger;
        Result.FSourceRowIndex := LReader.ReadInteger;
        Result.FSourceColumnIndex := LReader.ReadInteger;
        LCount := LReader.ReadInteger;
        if (LCount < 0) or (LCount > 100000) then
          Abort;
        SetLength(Result.FColumnNames, LCount);
        for I := 0 to LCount - 1 do
          Result.FColumnNames[I] := LReader.ReadString;
        LCount := LReader.ReadInteger;
        if (LCount < 0) or (LCount > 10000000) then
          Abort;
        SetLength(Result.FSourceDataSourceIndexes, LCount);
        for I := 0 to LCount - 1 do
          Result.FSourceDataSourceIndexes[I] := LReader.ReadInteger;
      except
        FreeAndNil(Result);
      end;
    finally
      LReader.Free;
    end;
  finally
    LStream.Free;
  end;
end;

constructor TThemedGridRowMoveData.Create;
begin
  inherited Create;
  FSourceId := Default(TGUID);
  FSourceRowIndex := -1;
  FSourceDataSourceIndex := -1;
end;

function TThemedGridRowMoveData.SaveToBytes: TBytes;
var
  LStream: TBytesStream;
  LWriter: TBinaryWriter;
begin
  LStream := TBytesStream.Create;
  try
    LWriter := TBinaryWriter.Create(LStream, TEncoding.UTF8, False);
    try
      LWriter.Write(GUIDToString(FSourceId));
      LWriter.Write(FSourceRowIndex);
      LWriter.Write(FSourceDataSourceIndex);
      LWriter.Write(FText);
    finally
      LWriter.Free;
    end;
    Result := Copy(LStream.Bytes, 0, LStream.Size);
  finally
    LStream.Free;
  end;
end;

class function TThemedGridRowMoveData.TryLoadFromBytes(const ABytes: TBytes): TThemedGridRowMoveData;
var
  LStream: TBytesStream;
  LReader: TBinaryReader;
begin
  Result := nil;
  if Length(ABytes) = 0 then
    Exit;
  LStream := TBytesStream.Create(ABytes);
  try
    LReader := TBinaryReader.Create(LStream, TEncoding.UTF8, False);
    try
      Result := TThemedGridRowMoveData.Create;
      try
        Result.FSourceId := StringToGUID(LReader.ReadString);
        Result.FSourceRowIndex := LReader.ReadInteger;
        Result.FSourceDataSourceIndex := LReader.ReadInteger;
        Result.FText := LReader.ReadString;
      except
        FreeAndNil(Result);
      end;
    finally
      LReader.Free;
    end;
  finally
    LStream.Free;
  end;
end;

end.

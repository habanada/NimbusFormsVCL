unit NimbusForms.HexEditor.Pieces;

interface

uses
  System.Generics.Collections;

type
  THexPieceSource = (hpsOriginal, hpsMemory);

  THexPieceInfo = class
  private
    FSource: THexPieceSource;
    FSourceOffset: Int64;
    FLength: Int64;
  public
    function Clone: THexPieceInfo;
    property Source: THexPieceSource read FSource write FSource;
    property SourceOffset: Int64 read FSourceOffset write FSourceOffset;
    property Length: Int64 read FLength write FLength;
  end;

  THexEditOperationType = (heoWrite, heoInsert, heoDelete);

  THexEditOperation = class
  private
    FOperationType: THexEditOperationType;
    FOffset: Int64;
    FOldLength: Int64;
    FNewLength: Int64;
    FOldPieces: TObjectList<THexPieceInfo>;
    FNewPieces: TObjectList<THexPieceInfo>;
  public
    constructor Create;
    destructor Destroy; override;
    function Clone: THexEditOperation;
    property OperationType: THexEditOperationType read FOperationType write FOperationType;
    property Offset: Int64 read FOffset write FOffset;
    property OldLength: Int64 read FOldLength write FOldLength;
    property NewLength: Int64 read FNewLength write FNewLength;
    property OldPieces: TObjectList<THexPieceInfo> read FOldPieces;
    property NewPieces: TObjectList<THexPieceInfo> read FNewPieces;
  end;

implementation

function THexPieceInfo.Clone: THexPieceInfo;
begin
  Result := THexPieceInfo.Create;
  Result.FSource := FSource;
  Result.FSourceOffset := FSourceOffset;
  Result.FLength := FLength;
end;

constructor THexEditOperation.Create;
begin
  inherited Create;
  FOldPieces := TObjectList<THexPieceInfo>.Create(True);
  FNewPieces := TObjectList<THexPieceInfo>.Create(True);
end;

destructor THexEditOperation.Destroy;
begin
  FOldPieces.Free;
  FNewPieces.Free;
  inherited Destroy;
end;

function THexEditOperation.Clone: THexEditOperation;
var
  LInfo: THexPieceInfo;
begin
  Result := THexEditOperation.Create;
  Result.FOperationType := FOperationType;
  Result.FOffset := FOffset;
  Result.FOldLength := FOldLength;
  Result.FNewLength := FNewLength;
  for LInfo in FOldPieces do
    Result.FOldPieces.Add(LInfo.Clone);
  for LInfo in FNewPieces do
    Result.FNewPieces.Add(LInfo.Clone);
end;

end.

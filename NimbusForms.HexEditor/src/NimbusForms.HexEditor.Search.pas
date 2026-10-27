unit NimbusForms.HexEditor.Search;

interface

type
  THexSearchMatch = class
  private
    FOffset: Int64;
    FLength: Integer;
    FPatternIndex: Integer;
    FHammingDistance: Integer;
    function GetEndOffset: Int64;
  public
    constructor Create(const AOffset: Int64; const ALength: Integer);
    function Contains(const AOffset: Int64): Boolean;
    function Clone: THexSearchMatch;
    property PatternIndex: Integer read FPatternIndex write FPatternIndex;
    property HammingDistance: Integer read FHammingDistance write FHammingDistance;
    property Offset: Int64 read FOffset;
    property Length: Integer read FLength;
    property EndOffset: Int64 read GetEndOffset;
  end;

implementation

constructor THexSearchMatch.Create(const AOffset: Int64; const ALength: Integer);
begin
  inherited Create;
  FOffset := AOffset;
  FLength := ALength;
end;

function THexSearchMatch.Clone: THexSearchMatch;
begin
  Result := THexSearchMatch.Create(FOffset, FLength);
  Result.PatternIndex := FPatternIndex;
  Result.HammingDistance := FHammingDistance;
end;

function THexSearchMatch.GetEndOffset: Int64;
begin
  Result := FOffset + FLength - 1;
end;

function THexSearchMatch.Contains(const AOffset: Int64): Boolean;
begin
  Result := (AOffset >= FOffset) and (AOffset <= GetEndOffset);
end;

end.

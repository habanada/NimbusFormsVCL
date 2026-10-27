unit NimbusForms.HexEditor.PatternSearch;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  NimbusForms.HexEditor.DataSource,
  NimbusForms.HexEditor.Search,
  NimbusForms.HexEditor.Pattern;

type
  THexPatternSearch = class
  private
    class function TryMatchAt(const ADataSource: IHexDataSource; const APattern: THexSearchPattern;
      const AOffset: Int64; out AMatch: THexPatternMatchInfo): Boolean; static;
  public
    class function SearchRich(const ADataSource: IHexDataSource; const APattern: THexSearchPattern;
      const AStartOffset, AEndOffset: Int64; const AMaxResults: Integer): TObjectList<THexPatternMatchInfo>; static;
    class function Search(const ADataSource: IHexDataSource; const APattern: THexSearchPattern;
      const AStartOffset, AEndOffset: Int64; const AMaxResults: Integer): TObjectList<THexSearchMatch>; static;
  end;

implementation

uses
  System.Math;

const
  CDefaultBufferSize = 1048576;

class function THexPatternSearch.TryMatchAt(const ADataSource: IHexDataSource;
  const APattern: THexSearchPattern; const AOffset: Int64; out AMatch: THexPatternMatchInfo): Boolean;
var
  LMaxLength, LRead: Integer;
  LBuffer: TBytes;
  LLocal: THexPatternMatchInfo;
begin
  AMatch := nil;
  if (ADataSource = nil) or (APattern = nil) or (AOffset < 0) or (AOffset >= ADataSource.Length) then
    Exit(False);
  LMaxLength := Integer(Min(Int64(APattern.MaxLength), ADataSource.Length - AOffset));
  if LMaxLength < APattern.MinLength then
    Exit(False);
  SetLength(LBuffer, LMaxLength);
  LRead := ADataSource.Read(AOffset, LBuffer, LMaxLength);
  if LRead < APattern.MinLength then
    Exit(False);
  if LRead <> System.Length(LBuffer) then
    SetLength(LBuffer, LRead);
  if not APattern.TryMatch(LBuffer, 0, LLocal) then
    Exit(False);
  try
    AMatch := LLocal.WithOffset(AOffset);
  finally
    LLocal.Free;
  end;
  Result := True;
end;

class function THexPatternSearch.SearchRich(const ADataSource: IHexDataSource;
  const APattern: THexSearchPattern; const AStartOffset, AEndOffset: Int64;
  const AMaxResults: Integer): TObjectList<THexPatternMatchInfo>;
var
  LStart, LEnd, LPosition: Int64;
  LMaxResults, LMaxPatternLength, LBufferSize, LOverlap, LBytesToRead, LBytesRead, LLimit, I: Integer;
  LBuffer: TBytes;
  LMatch, LShifted: THexPatternMatchInfo;
  LAnchored: THexPatternMatchInfo;
begin
  Result := TObjectList<THexPatternMatchInfo>.Create(True);
  if (ADataSource = nil) or (ADataSource.Length <= 0) or (APattern = nil) then
    Exit;
  if (APattern.MinLength <= 0) or (APattern.MaxLength <= 0) then
    Exit;

  LStart := Max(Int64(0), AStartOffset);
  if AEndOffset >= 0 then
    LEnd := Min(AEndOffset, ADataSource.Length)
  else
    LEnd := ADataSource.Length;
  if AMaxResults <= 0 then
    LMaxResults := MaxInt
  else
    LMaxResults := AMaxResults;
  if LEnd <= LStart then
    Exit;

  if APattern.HasAnchor then
  begin
    if TryMatchAt(ADataSource, APattern, APattern.AnchorOffset, LAnchored) then
      Result.Add(LAnchored);
    Exit;
  end;

  LMaxPatternLength := Max(1, APattern.MaxLength);
  LBufferSize := Max(CDefaultBufferSize, LMaxPatternLength * 2);
  SetLength(LBuffer, LBufferSize);
  LPosition := LStart;
  LOverlap := Max(0, LMaxPatternLength - 1);

  while (LPosition < LEnd) and (Result.Count < LMaxResults) do
  begin
    LBytesToRead := Integer(Min(Int64(System.Length(LBuffer)), LEnd - LPosition));
    LBytesRead := ADataSource.Read(LPosition, LBuffer, LBytesToRead);
    if LBytesRead < APattern.MinLength then
      Break;
    LLimit := LBytesRead - APattern.MinLength;
    I := 0;
    while (I <= LLimit) and (Result.Count < LMaxResults) do
    begin
      if APattern.TryMatch(LBuffer, I, LMatch) then
      begin
        LShifted := LMatch.WithOffset(LPosition + I);
        LMatch.Free;
        Result.Add(LShifted);
      end;
      Inc(I);
    end;
    if LPosition + LBytesRead >= LEnd then
      Break;
    Inc(LPosition, Max(1, LBytesRead - LOverlap));
  end;
end;

class function THexPatternSearch.Search(const ADataSource: IHexDataSource;
  const APattern: THexSearchPattern; const AStartOffset, AEndOffset: Int64;
  const AMaxResults: Integer): TObjectList<THexSearchMatch>;
var
  LRich: TObjectList<THexPatternMatchInfo>;
  I: Integer;
begin
  Result := TObjectList<THexSearchMatch>.Create(True);
  LRich := SearchRich(ADataSource, APattern, AStartOffset, AEndOffset, AMaxResults);
  try
    for I := 0 to LRich.Count - 1 do
      Result.Add(LRich[I].ToSearchMatch);
  finally
    LRich.Free;
  end;
end;

end.

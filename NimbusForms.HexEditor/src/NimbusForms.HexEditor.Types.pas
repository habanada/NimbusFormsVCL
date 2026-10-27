unit NimbusForms.HexEditor.Types;

interface

type
  THexOffsetFormat = (hofHex8, hofHex16, hofDecimal);

  THexHitArea = (hhaNone, hhaHeader, hhaGutter, hhaHexCell, hhaAsciiCell);

  THexTextFlag = (htfLeft, htfRight, htfHCenter, htfVCenter, htfNoPadding);
  THexTextFlags = set of THexTextFlag;

  THexHitInfo = record
    Area: THexHitArea;
    Offset: Int64;
    RowIndex: Integer;
    ColumnIndex: Integer;
    function IsByte: Boolean;
  end;

  THexSelection = class
  private
    FStart: Int64;
    FLength: Int64;
    function GetIsEmpty: Boolean;
    function GetEndOffset: Int64;
  public
    function Contains(const AOffset: Int64): Boolean;
    procedure Clear(const ACursorOffset: Int64);
    procedure SetRange(const AStart, ALength: Int64);
    property Start: Int64 read FStart write FStart;
    property Length: Int64 read FLength write FLength;
    property IsEmpty: Boolean read GetIsEmpty;
    property EndOffset: Int64 read GetEndOffset;
  end;

implementation

function THexHitInfo.IsByte: Boolean;
begin
  Result := (Area = hhaHexCell) or (Area = hhaAsciiCell);
end;

function THexSelection.GetIsEmpty: Boolean;
begin
  Result := FLength <= 0;
end;

function THexSelection.GetEndOffset: Int64;
begin
  if FLength <= 0 then
    Result := FStart
  else
    Result := FStart + FLength - 1;
end;

function THexSelection.Contains(const AOffset: Int64): Boolean;
begin
  Result := (FLength > 0) and (AOffset >= FStart) and (AOffset <= GetEndOffset);
end;

procedure THexSelection.Clear(const ACursorOffset: Int64);
begin
  if ACursorOffset < 0 then
    FStart := 0
  else
    FStart := ACursorOffset;
  FLength := 0;
end;

procedure THexSelection.SetRange(const AStart, ALength: Int64);
begin
  if AStart < 0 then
    FStart := 0
  else
    FStart := AStart;
  if ALength < 0 then
    FLength := 0
  else
    FLength := ALength;
end;

end.

unit NimbusForms.Grid.Primitives;

interface

uses
  System.SysUtils,
  System.Math;

type
  TThemedGridCellKey = record
    DataSourceIndex: Integer;
    ColumnName: string;
    constructor Create(const ADataSourceIndex: Integer; const AColumnName: string);
    function Equals(const AOther: TThemedGridCellKey): Boolean;
    function GetHashCode: Integer;
    function ToString: string;
    class operator Equal(const A, B: TThemedGridCellKey): Boolean;
    class operator NotEqual(const A, B: TThemedGridCellKey): Boolean;
  end;

  TThemedGridCellRange = record
    Row1: Integer;
    Column1: Integer;
    Row2: Integer;
    Column2: Integer;
    constructor Create(const ARow1, AColumn1, ARow2, AColumn2: Integer);
    function GetRowCount: Integer;
    function GetColumnCount: Integer;
    function GetIsValid: Boolean;
    function Contains(const ARowIndex, AColumnIndex: Integer): Boolean;
    function Equals(const AOther: TThemedGridCellRange): Boolean;
    property RowCount: Integer read GetRowCount;
    property ColumnCount: Integer read GetColumnCount;
    property IsValid: Boolean read GetIsValid;
    class function Empty: TThemedGridCellRange; static;
    class operator Equal(const A, B: TThemedGridCellRange): Boolean;
    class operator NotEqual(const A, B: TThemedGridCellRange): Boolean;
  end;

  TThemedGridCurrentCell = record
    RowIndex: Integer;
    ColumnIndex: Integer;
    constructor Create(const ARowIndex, AColumnIndex: Integer);
    function GetIsValid: Boolean;
    function Equals(const AOther: TThemedGridCurrentCell): Boolean;
    property IsValid: Boolean read GetIsValid;
    class function Empty: TThemedGridCurrentCell; static;
    class operator Equal(const A, B: TThemedGridCurrentCell): Boolean;
    class operator NotEqual(const A, B: TThemedGridCurrentCell): Boolean;
  end;

implementation

{ TThemedGridCellKey }

constructor TThemedGridCellKey.Create(const ADataSourceIndex: Integer; const AColumnName: string);
begin
  DataSourceIndex := ADataSourceIndex;
  ColumnName := AColumnName;
end;

function TThemedGridCellKey.Equals(const AOther: TThemedGridCellKey): Boolean;
begin
  Result := (DataSourceIndex = AOther.DataSourceIndex) and SameText(ColumnName, AOther.ColumnName);
end;

function TThemedGridCellKey.GetHashCode: Integer;
begin
  Result := DataSourceIndex;
  if ColumnName <> '' then
    Result := (Result * 397) xor Integer(string(LowerCase(ColumnName)).GetHashCode);
end;

function TThemedGridCellKey.ToString: string;
begin
  Result := IntToStr(DataSourceIndex) + ':' + ColumnName;
end;

class operator TThemedGridCellKey.Equal(const A, B: TThemedGridCellKey): Boolean;
begin
  Result := A.Equals(B);
end;

class operator TThemedGridCellKey.NotEqual(const A, B: TThemedGridCellKey): Boolean;
begin
  Result := not A.Equals(B);
end;

{ TThemedGridCellRange }

constructor TThemedGridCellRange.Create(const ARow1, AColumn1, ARow2, AColumn2: Integer);
begin
  Row1 := Min(ARow1, ARow2);
  Row2 := Max(ARow1, ARow2);
  Column1 := Min(AColumn1, AColumn2);
  Column2 := Max(AColumn1, AColumn2);
end;

function TThemedGridCellRange.GetIsValid: Boolean;
begin
  Result := (Row1 >= 0) and (Column1 >= 0) and (Row2 >= Row1) and (Column2 >= Column1);
end;

function TThemedGridCellRange.GetRowCount: Integer;
begin
  if GetIsValid then
    Result := Row2 - Row1 + 1
  else
    Result := 0;
end;

function TThemedGridCellRange.GetColumnCount: Integer;
begin
  if GetIsValid then
    Result := Column2 - Column1 + 1
  else
    Result := 0;
end;

function TThemedGridCellRange.Contains(const ARowIndex, AColumnIndex: Integer): Boolean;
begin
  if not GetIsValid then
    Exit(False);
  Result := (ARowIndex >= Row1) and (ARowIndex <= Row2) and
    (AColumnIndex >= Column1) and (AColumnIndex <= Column2);
end;

function TThemedGridCellRange.Equals(const AOther: TThemedGridCellRange): Boolean;
begin
  Result := (Row1 = AOther.Row1) and (Column1 = AOther.Column1) and
    (Row2 = AOther.Row2) and (Column2 = AOther.Column2);
end;

class function TThemedGridCellRange.Empty: TThemedGridCellRange;
begin
  Result := TThemedGridCellRange.Create(-1, -1, -1, -1);
end;

class operator TThemedGridCellRange.Equal(const A, B: TThemedGridCellRange): Boolean;
begin
  Result := A.Equals(B);
end;

class operator TThemedGridCellRange.NotEqual(const A, B: TThemedGridCellRange): Boolean;
begin
  Result := not A.Equals(B);
end;

{ TThemedGridCurrentCell }

constructor TThemedGridCurrentCell.Create(const ARowIndex, AColumnIndex: Integer);
begin
  RowIndex := ARowIndex;
  ColumnIndex := AColumnIndex;
end;

function TThemedGridCurrentCell.GetIsValid: Boolean;
begin
  Result := (RowIndex >= 0) and (ColumnIndex >= 0);
end;

function TThemedGridCurrentCell.Equals(const AOther: TThemedGridCurrentCell): Boolean;
begin
  Result := (RowIndex = AOther.RowIndex) and (ColumnIndex = AOther.ColumnIndex);
end;

class function TThemedGridCurrentCell.Empty: TThemedGridCurrentCell;
begin
  Result := TThemedGridCurrentCell.Create(-1, -1);
end;

class operator TThemedGridCurrentCell.Equal(const A, B: TThemedGridCurrentCell): Boolean;
begin
  Result := A.Equals(B);
end;

class operator TThemedGridCurrentCell.NotEqual(const A, B: TThemedGridCurrentCell): Boolean;
begin
  Result := not A.Equals(B);
end;

end.

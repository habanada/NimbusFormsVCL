unit NimbusForms.Grid.SelectionModel;

interface

uses
  System.Classes,
  System.Generics.Collections,
  NimbusForms.Grid.Primitives;

type
  TThemedGridSelectionModel = class
  private
    FRanges: TList<TThemedGridCellRange>;
    FRows: TDictionary<Integer, Boolean>;
    FColumns: TDictionary<Integer, Boolean>;
    FCurrentCell: TThemedGridCurrentCell;
    FAnchorCell: TThemedGridCurrentCell;
    FOnChanged: TNotifyEvent;
    procedure DoChanged;
    function GetHasSelection: Boolean;
    function GetPrimaryRange: TThemedGridCellRange;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SetCurrentCell(const ARowIndex, AColumnIndex: Integer; const ASelect: Boolean);
    procedure SelectCell(const ARowIndex, AColumnIndex: Integer);
    procedure AddCell(const ARowIndex, AColumnIndex: Integer);
    procedure ToggleCell(const ARowIndex, AColumnIndex: Integer);
    procedure SelectRange(const ARow1, AColumn1, ARow2, AColumn2: Integer);
    procedure SelectRow(const ARowIndex: Integer);
    procedure AddRow(const ARowIndex: Integer);
    procedure ToggleRow(const ARowIndex: Integer);
    procedure SelectColumn(const AColumnIndex: Integer);
    procedure AddColumn(const AColumnIndex: Integer);
    procedure ToggleColumn(const AColumnIndex: Integer);
    procedure Clear;
    function IsCellSelected(const ARowIndex, AColumnIndex: Integer): Boolean;
    function IsRowSelected(const ARowIndex: Integer): Boolean;
    function IsColumnSelected(const AColumnIndex: Integer): Boolean;
    property CurrentCell: TThemedGridCurrentCell read FCurrentCell;
    property AnchorCell: TThemedGridCurrentCell read FAnchorCell;
    property Ranges: TList<TThemedGridCellRange> read FRanges;
    property HasSelection: Boolean read GetHasSelection;
    property PrimaryRange: TThemedGridCellRange read GetPrimaryRange;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

implementation

constructor TThemedGridSelectionModel.Create;
begin
  inherited Create;
  FRanges := TList<TThemedGridCellRange>.Create;
  FRows := TDictionary<Integer, Boolean>.Create;
  FColumns := TDictionary<Integer, Boolean>.Create;
  FCurrentCell := TThemedGridCurrentCell.Empty;
  FAnchorCell := TThemedGridCurrentCell.Empty;
end;

destructor TThemedGridSelectionModel.Destroy;
begin
  FColumns.Free;
  FRows.Free;
  FRanges.Free;
  inherited Destroy;
end;

procedure TThemedGridSelectionModel.DoChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

function TThemedGridSelectionModel.GetHasSelection: Boolean;
begin
  Result := FCurrentCell.IsValid or (FRanges.Count > 0) or (FRows.Count > 0) or (FColumns.Count > 0);
end;

function TThemedGridSelectionModel.GetPrimaryRange: TThemedGridCellRange;
begin
  if FRanges.Count = 0 then
    Result := TThemedGridCellRange.Empty
  else
    Result := FRanges[0];
end;

procedure TThemedGridSelectionModel.SetCurrentCell(const ARowIndex, AColumnIndex: Integer; const ASelect: Boolean);
begin
  FCurrentCell := TThemedGridCurrentCell.Create(ARowIndex, AColumnIndex);
  if (not FAnchorCell.IsValid) or ASelect then
    FAnchorCell := FCurrentCell;
  if ASelect then
  begin
    FRanges.Clear;
    FRows.Clear;
    FColumns.Clear;
    if FCurrentCell.IsValid then
      FRanges.Add(TThemedGridCellRange.Create(ARowIndex, AColumnIndex, ARowIndex, AColumnIndex));
  end;
  DoChanged;
end;

procedure TThemedGridSelectionModel.SelectCell(const ARowIndex, AColumnIndex: Integer);
begin
  FCurrentCell := TThemedGridCurrentCell.Create(ARowIndex, AColumnIndex);
  FAnchorCell := FCurrentCell;
  FRanges.Clear;
  FRows.Clear;
  FColumns.Clear;
  if FCurrentCell.IsValid then
    FRanges.Add(TThemedGridCellRange.Create(ARowIndex, AColumnIndex, ARowIndex, AColumnIndex));
  DoChanged;
end;

procedure TThemedGridSelectionModel.AddCell(const ARowIndex, AColumnIndex: Integer);
begin
  if (ARowIndex < 0) or (AColumnIndex < 0) then
    Exit;
  FCurrentCell := TThemedGridCurrentCell.Create(ARowIndex, AColumnIndex);
  if not FAnchorCell.IsValid then
    FAnchorCell := FCurrentCell;
  FRanges.Add(TThemedGridCellRange.Create(ARowIndex, AColumnIndex, ARowIndex, AColumnIndex));
  DoChanged;
end;

procedure TThemedGridSelectionModel.ToggleCell(const ARowIndex, AColumnIndex: Integer);
var
  I: Integer;
  LRange: TThemedGridCellRange;
begin
  if (ARowIndex < 0) or (AColumnIndex < 0) then
    Exit;
  FCurrentCell := TThemedGridCurrentCell.Create(ARowIndex, AColumnIndex);
  if not FAnchorCell.IsValid then
    FAnchorCell := FCurrentCell;
  for I := FRanges.Count - 1 downto 0 do
  begin
    LRange := FRanges[I];
    if (LRange.Row1 = ARowIndex) and (LRange.Row2 = ARowIndex) and
       (LRange.Column1 = AColumnIndex) and (LRange.Column2 = AColumnIndex) then
    begin
      FRanges.Delete(I);
      DoChanged;
      Exit;
    end;
  end;
  FRanges.Add(TThemedGridCellRange.Create(ARowIndex, AColumnIndex, ARowIndex, AColumnIndex));
  DoChanged;
end;

procedure TThemedGridSelectionModel.SelectRange(const ARow1, AColumn1, ARow2, AColumn2: Integer);
var
  LRange: TThemedGridCellRange;
begin
  LRange := TThemedGridCellRange.Create(ARow1, AColumn1, ARow2, AColumn2);
  FRanges.Clear;
  FRows.Clear;
  FColumns.Clear;
  if LRange.IsValid then
  begin
    FRanges.Add(LRange);
    FCurrentCell := TThemedGridCurrentCell.Create(ARow2, AColumn2);
    FAnchorCell := TThemedGridCurrentCell.Create(ARow1, AColumn1);
  end
  else
  begin
    FCurrentCell := TThemedGridCurrentCell.Empty;
    FAnchorCell := TThemedGridCurrentCell.Empty;
  end;
  DoChanged;
end;

procedure TThemedGridSelectionModel.SelectRow(const ARowIndex: Integer);
begin
  FRanges.Clear;
  FRows.Clear;
  FColumns.Clear;
  if ARowIndex >= 0 then
  begin
    FRows.AddOrSetValue(ARowIndex, True);
    FCurrentCell := TThemedGridCurrentCell.Create(ARowIndex, 0);
    FAnchorCell := FCurrentCell;
  end;
  DoChanged;
end;

procedure TThemedGridSelectionModel.AddRow(const ARowIndex: Integer);
begin
  if ARowIndex < 0 then
    Exit;
  FRows.AddOrSetValue(ARowIndex, True);
  FCurrentCell := TThemedGridCurrentCell.Create(ARowIndex, 0);
  if not FAnchorCell.IsValid then
    FAnchorCell := FCurrentCell;
  DoChanged;
end;

procedure TThemedGridSelectionModel.ToggleRow(const ARowIndex: Integer);
begin
  if ARowIndex < 0 then
    Exit;
  if FRows.ContainsKey(ARowIndex) then
    FRows.Remove(ARowIndex)
  else
    FRows.AddOrSetValue(ARowIndex, True);
  FCurrentCell := TThemedGridCurrentCell.Create(ARowIndex, 0);
  if not FAnchorCell.IsValid then
    FAnchorCell := FCurrentCell;
  DoChanged;
end;

procedure TThemedGridSelectionModel.SelectColumn(const AColumnIndex: Integer);
begin
  FRanges.Clear;
  FRows.Clear;
  FColumns.Clear;
  if AColumnIndex >= 0 then
  begin
    FColumns.AddOrSetValue(AColumnIndex, True);
    FCurrentCell := TThemedGridCurrentCell.Create(0, AColumnIndex);
    FAnchorCell := FCurrentCell;
  end;
  DoChanged;
end;

procedure TThemedGridSelectionModel.AddColumn(const AColumnIndex: Integer);
begin
  if AColumnIndex < 0 then
    Exit;
  FColumns.AddOrSetValue(AColumnIndex, True);
  FCurrentCell := TThemedGridCurrentCell.Create(0, AColumnIndex);
  if not FAnchorCell.IsValid then
    FAnchorCell := FCurrentCell;
  DoChanged;
end;

procedure TThemedGridSelectionModel.ToggleColumn(const AColumnIndex: Integer);
begin
  if AColumnIndex < 0 then
    Exit;
  if FColumns.ContainsKey(AColumnIndex) then
    FColumns.Remove(AColumnIndex)
  else
    FColumns.AddOrSetValue(AColumnIndex, True);
  FCurrentCell := TThemedGridCurrentCell.Create(0, AColumnIndex);
  if not FAnchorCell.IsValid then
    FAnchorCell := FCurrentCell;
  DoChanged;
end;

procedure TThemedGridSelectionModel.Clear;
begin
  FRanges.Clear;
  FRows.Clear;
  FColumns.Clear;
  FCurrentCell := TThemedGridCurrentCell.Empty;
  FAnchorCell := TThemedGridCurrentCell.Empty;
  DoChanged;
end;

function TThemedGridSelectionModel.IsCellSelected(const ARowIndex, AColumnIndex: Integer): Boolean;
var
  I: Integer;
begin
  if (ARowIndex < 0) or (AColumnIndex < 0) then
    Exit(False);
  if FRows.ContainsKey(ARowIndex) then
    Exit(True);
  if FColumns.ContainsKey(AColumnIndex) then
    Exit(True);
  for I := 0 to FRanges.Count - 1 do
    if FRanges[I].Contains(ARowIndex, AColumnIndex) then
      Exit(True);
  Result := False;
end;

function TThemedGridSelectionModel.IsRowSelected(const ARowIndex: Integer): Boolean;
begin
  Result := FRows.ContainsKey(ARowIndex);
end;

function TThemedGridSelectionModel.IsColumnSelected(const AColumnIndex: Integer): Boolean;
begin
  Result := FColumns.ContainsKey(AColumnIndex);
end;

end.

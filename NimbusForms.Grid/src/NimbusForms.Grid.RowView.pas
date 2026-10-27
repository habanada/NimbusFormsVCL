unit NimbusForms.Grid.RowView;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  NimbusForms.Grid.ViewRow;

type
  IThemedGridRowViewProvider = interface
    ['{5C9E1B74-2A38-4D6F-8E05-3B7A4C1D9F62}']
    function GetCount: Integer;
    function GetVersion: Integer;
    function GetDataRowCount: Integer;
    function GetTotalHeight: Integer;
    function GetRow(const AIndex: Integer): TThemedGridViewRow;
    function GetEstimatedRowHeight(const AIndex: Integer): Integer;
    function GetRowTop(const AIndex: Integer): Integer;
    function GetRowIndexAtVirtualY(const AVirtualY: Integer): Integer;
    property Count: Integer read GetCount;
    property Version: Integer read GetVersion;
    property DataRowCount: Integer read GetDataRowCount;
    property TotalHeight: Integer read GetTotalHeight;
  end;

  TThemedGridDetailHeightMap = class
  private
    FHeights: TDictionary<Integer, Integer>;
    FVersion: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function SetHeight(const ADataSourceIndex, AHeight: Integer): Boolean;
    function GetHeight(const ADataSourceIndex, ADefaultHeight: Integer): Integer;
    property Version: Integer read FVersion;
  end;

  TThemedGridRowView = class
  private
    const
      RecentRowCapacity = 512;
  private
    FRows: TObjectList<TThemedGridViewRow>;
    FRecentRows: TObjectList<TThemedGridViewRow>;
    FRecentNext: Integer;
    FProvider: IThemedGridRowViewProvider;
    FDetailHeights: TThemedGridDetailHeightMap;
    FVersion: Integer;
    FDataRowCount: Integer;
    function GetCount: Integer;
    function GetVersion: Integer;
    procedure SetVersion(const AValue: Integer);
    function GetDataRowCount: Integer;
    procedure SetDataRowCount(const AValue: Integer);
    function GetIsVirtual: Boolean;
    procedure KeepRecent(const ARow: TThemedGridViewRow);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Add(const ARow: TThemedGridViewRow);
    procedure SetProvider(const AProvider: IThemedGridRowViewProvider);
    function GetRow(const AIndex: Integer): TThemedGridViewRow;
    function GetEstimatedRowHeight(const AIndex, ADefaultHeight: Integer): Integer;
    function GetRowTop(const AIndex, ADefaultHeight: Integer): Integer;
    function GetRowsTotalHeight(const ADefaultHeight: Integer): Integer;
    function GetRowIndexAtVirtualY(const AVirtualY, ADefaultHeight: Integer): Integer;
    property DetailHeights: TThemedGridDetailHeightMap read FDetailHeights;
    property Count: Integer read GetCount;
    property Version: Integer read GetVersion write SetVersion;
    property DataRowCount: Integer read GetDataRowCount write SetDataRowCount;
    property IsVirtual: Boolean read GetIsVirtual;
    property Items[const AIndex: Integer]: TThemedGridViewRow read GetRow; default;
  end;

implementation

constructor TThemedGridDetailHeightMap.Create;
begin
  inherited Create;
  FHeights := TDictionary<Integer, Integer>.Create;
end;

destructor TThemedGridDetailHeightMap.Destroy;
begin
  FHeights.Free;
  inherited Destroy;
end;

procedure TThemedGridDetailHeightMap.Clear;
begin
  if FHeights.Count = 0 then
    Exit;
  FHeights.Clear;
  Inc(FVersion);
end;

function TThemedGridDetailHeightMap.SetHeight(const ADataSourceIndex, AHeight: Integer): Boolean;
var
  LCurrent: Integer;
begin
  if FHeights.TryGetValue(ADataSourceIndex, LCurrent) and (LCurrent = AHeight) then
    Exit(False);
  FHeights.AddOrSetValue(ADataSourceIndex, AHeight);
  Inc(FVersion);
  Result := True;
end;

function TThemedGridDetailHeightMap.GetHeight(const ADataSourceIndex, ADefaultHeight: Integer): Integer;
begin
  if not FHeights.TryGetValue(ADataSourceIndex, Result) then
    Result := ADefaultHeight;
end;

constructor TThemedGridRowView.Create;
begin
  inherited Create;
  FRows := TObjectList<TThemedGridViewRow>.Create(True);
  FRecentRows := TObjectList<TThemedGridViewRow>.Create(True);
  FDetailHeights := TThemedGridDetailHeightMap.Create;
  FVersion := -1;
  FDataRowCount := 0;
end;

destructor TThemedGridRowView.Destroy;
begin
  FProvider := nil;
  FDetailHeights.Free;
  FRecentRows.Free;
  FRows.Free;
  inherited Destroy;
end;

function TThemedGridRowView.GetCount: Integer;
begin
  if FProvider <> nil then
    Exit(FProvider.Count);
  Result := FRows.Count;
end;

function TThemedGridRowView.GetVersion: Integer;
begin
  if FProvider <> nil then
    Exit(FProvider.Version);
  Result := FVersion;
end;

procedure TThemedGridRowView.SetVersion(const AValue: Integer);
begin
  FVersion := AValue;
end;

function TThemedGridRowView.GetDataRowCount: Integer;
begin
  if FProvider <> nil then
    Exit(FProvider.DataRowCount);
  Result := FDataRowCount;
end;

procedure TThemedGridRowView.SetDataRowCount(const AValue: Integer);
begin
  FDataRowCount := AValue;
end;

function TThemedGridRowView.GetIsVirtual: Boolean;
begin
  Result := FProvider <> nil;
end;

procedure TThemedGridRowView.Clear;
begin
  FProvider := nil;
  FRows.Clear;
  FRecentRows.Clear;
  FRecentNext := 0;
  FVersion := -1;
  FDataRowCount := 0;
end;

procedure TThemedGridRowView.Add(const ARow: TThemedGridViewRow);
begin
  if ARow = nil then
    Exit;
  FProvider := nil;
  ARow.ViewIndex := FRows.Count;
  FRows.Add(ARow);
  if ARow.IsDataRow then
    Inc(FDataRowCount);
end;

procedure TThemedGridRowView.SetProvider(const AProvider: IThemedGridRowViewProvider);
begin
  FRows.Clear;
  FRecentRows.Clear;
  FRecentNext := 0;
  FProvider := AProvider;
  if AProvider <> nil then
  begin
    FVersion := AProvider.Version;
    FDataRowCount := AProvider.DataRowCount;
  end
  else
  begin
    FVersion := -1;
    FDataRowCount := 0;
  end;
end;

procedure TThemedGridRowView.KeepRecent(const ARow: TThemedGridViewRow);
begin
  if FRecentRows.Count < RecentRowCapacity then
  begin
    FRecentRows.Add(ARow);
    Exit;
  end;
  FRecentRows[FRecentNext] := ARow;
  FRecentNext := (FRecentNext + 1) mod RecentRowCapacity;
end;

function TThemedGridRowView.GetRow(const AIndex: Integer): TThemedGridViewRow;
begin
  if FProvider <> nil then
  begin
    Result := FProvider.GetRow(AIndex);
    if Result <> nil then
    begin
      Result.ViewIndex := AIndex;
      KeepRecent(Result);
    end;
    Exit;
  end;
  if (AIndex < 0) or (AIndex >= FRows.Count) then
    Exit(nil);
  Result := FRows[AIndex];
end;

function TThemedGridRowView.GetEstimatedRowHeight(const AIndex, ADefaultHeight: Integer): Integer;
var
  LRow: TThemedGridViewRow;
begin
  if FProvider <> nil then
    Exit(FProvider.GetEstimatedRowHeight(AIndex));
  if (AIndex < 0) or (AIndex >= FRows.Count) then
    Exit(ADefaultHeight);
  LRow := FRows[AIndex];
  if (LRow <> nil) and (LRow.Height > 0) then
    Exit(LRow.Height);
  Result := ADefaultHeight;
end;

function TThemedGridRowView.GetRowTop(const AIndex, ADefaultHeight: Integer): Integer;
var
  I, LIndex: Integer;
  LRow: TThemedGridViewRow;
begin
  if FProvider <> nil then
    Exit(FProvider.GetRowTop(AIndex));
  if AIndex <= 0 then
    Exit(0);
  LIndex := AIndex;
  if LIndex > FRows.Count then
    LIndex := FRows.Count;
  Result := 0;
  for I := 0 to LIndex - 1 do
  begin
    LRow := FRows[I];
    if (LRow <> nil) and (LRow.Height > 0) then
      Inc(Result, LRow.Height)
    else
      Inc(Result, ADefaultHeight);
  end;
end;

function TThemedGridRowView.GetRowsTotalHeight(const ADefaultHeight: Integer): Integer;
var
  I: Integer;
  LRow: TThemedGridViewRow;
begin
  if FProvider <> nil then
    Exit(FProvider.TotalHeight);
  Result := 0;
  for I := 0 to FRows.Count - 1 do
  begin
    LRow := FRows[I];
    if (LRow <> nil) and (LRow.Height > 0) then
      Inc(Result, LRow.Height)
    else
      Inc(Result, ADefaultHeight);
  end;
end;

function TThemedGridRowView.GetRowIndexAtVirtualY(const AVirtualY, ADefaultHeight: Integer): Integer;
var
  I, LTop, LHeight: Integer;
begin
  if FProvider <> nil then
    Exit(FProvider.GetRowIndexAtVirtualY(AVirtualY));
  if FRows.Count <= 0 then
    Exit(-1);
  if AVirtualY <= 0 then
    Exit(0);
  LTop := 0;
  for I := 0 to FRows.Count - 1 do
  begin
    LHeight := GetEstimatedRowHeight(I, ADefaultHeight);
    if (AVirtualY >= LTop) and (AVirtualY < LTop + LHeight) then
      Exit(I);
    Inc(LTop, LHeight);
  end;
  Result := FRows.Count - 1;
end;

end.

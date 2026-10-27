unit NimbusForms.Grid.DetailGridHitInfo;

{$SCOPEDENUMS ON}

interface

uses
  System.Types,
  System.Rtti,
  NimbusForms.Grid.ViewRow,
  NimbusForms.Grid.DetailGridColumn;

type
  TThemedGridDetailGridHitInfo = class
  private
    FHit: Boolean;
    FViewRow: TThemedGridViewRow;
    FViewRowIndex: Integer;
    FParentDataSourceIndex: Integer;
    FParentRowObject: TValue;
    FRelationName: string;
    FRelationIndex: Integer;
    FDetailRowIndex: Integer;
    FDetailColumnIndex: Integer;
    FDetailRowObject: TValue;
    FValue: TValue;
    FColumn: TThemedGridDetailGridColumn;
    FGridBounds: TRect;
    FRowBounds: TRect;
    FCellBounds: TRect;
    FIsHeader: Boolean;
  public
    constructor Create;
    procedure SetHeader(const AViewRow: TThemedGridViewRow; const AViewRowIndex, AParentDataSourceIndex: Integer;
      const AParentRowObject: TValue; const ARelationName: string; const ARelationIndex, ADetailColumnIndex: Integer;
      const AColumn: TThemedGridDetailGridColumn; const AGridBounds, ACellBounds: TRect);
    procedure SetCell(const AViewRow: TThemedGridViewRow; const AViewRowIndex, AParentDataSourceIndex: Integer;
      const AParentRowObject: TValue; const ARelationName: string; const ARelationIndex, ADetailRowIndex,
      ADetailColumnIndex: Integer; const ADetailRowObject, AValue: TValue;
      const AColumn: TThemedGridDetailGridColumn; const AGridBounds, ARowBounds, ACellBounds: TRect);
    procedure Clear;
    property Hit: Boolean read FHit;
    property ViewRow: TThemedGridViewRow read FViewRow;
    property ViewRowIndex: Integer read FViewRowIndex;
    property ParentDataSourceIndex: Integer read FParentDataSourceIndex;
    property ParentRowObject: TValue read FParentRowObject;
    property RelationName: string read FRelationName;
    property RelationIndex: Integer read FRelationIndex;
    property DetailRowIndex: Integer read FDetailRowIndex;
    property DetailColumnIndex: Integer read FDetailColumnIndex;
    property DetailRowObject: TValue read FDetailRowObject;
    property Value: TValue read FValue;
    property Column: TThemedGridDetailGridColumn read FColumn;
    property GridBounds: TRect read FGridBounds;
    property RowBounds: TRect read FRowBounds;
    property CellBounds: TRect read FCellBounds;
    property IsHeader: Boolean read FIsHeader;
  end;

implementation

uses
  NimbusForms.Grid.MasterDetailStrings;

constructor TThemedGridDetailGridHitInfo.Create;
begin
  inherited Create;
  Clear;
end;

procedure TThemedGridDetailGridHitInfo.SetHeader(const AViewRow: TThemedGridViewRow; const AViewRowIndex,
  AParentDataSourceIndex: Integer; const AParentRowObject: TValue; const ARelationName: string;
  const ARelationIndex, ADetailColumnIndex: Integer; const AColumn: TThemedGridDetailGridColumn;
  const AGridBounds, ACellBounds: TRect);
begin
  FHit := True;
  FViewRow := AViewRow;
  FViewRowIndex := AViewRowIndex;
  FParentDataSourceIndex := AParentDataSourceIndex;
  FParentRowObject := AParentRowObject;
  if ARelationName = '' then
    FRelationName := ThemedGridMasterDetailStrings.DefaultRelationName
  else
    FRelationName := ARelationName;
  FRelationIndex := ARelationIndex;
  FDetailRowIndex := -1;
  FDetailColumnIndex := ADetailColumnIndex;
  FDetailRowObject := TValue.Empty;
  FValue := TValue.Empty;
  FColumn := AColumn;
  FGridBounds := AGridBounds;
  FRowBounds := TRect.Empty;
  FCellBounds := ACellBounds;
  FIsHeader := True;
end;

procedure TThemedGridDetailGridHitInfo.SetCell(const AViewRow: TThemedGridViewRow; const AViewRowIndex,
  AParentDataSourceIndex: Integer; const AParentRowObject: TValue; const ARelationName: string;
  const ARelationIndex, ADetailRowIndex, ADetailColumnIndex: Integer; const ADetailRowObject, AValue: TValue;
  const AColumn: TThemedGridDetailGridColumn; const AGridBounds, ARowBounds, ACellBounds: TRect);
begin
  FHit := True;
  FViewRow := AViewRow;
  FViewRowIndex := AViewRowIndex;
  FParentDataSourceIndex := AParentDataSourceIndex;
  FParentRowObject := AParentRowObject;
  if ARelationName = '' then
    FRelationName := ThemedGridMasterDetailStrings.DefaultRelationName
  else
    FRelationName := ARelationName;
  FRelationIndex := ARelationIndex;
  FDetailRowIndex := ADetailRowIndex;
  FDetailColumnIndex := ADetailColumnIndex;
  FDetailRowObject := ADetailRowObject;
  FValue := AValue;
  FColumn := AColumn;
  FGridBounds := AGridBounds;
  FRowBounds := ARowBounds;
  FCellBounds := ACellBounds;
  FIsHeader := False;
end;

procedure TThemedGridDetailGridHitInfo.Clear;
begin
  FHit := False;
  FViewRow := nil;
  FViewRowIndex := -1;
  FParentDataSourceIndex := -1;
  FParentRowObject := TValue.Empty;
  FRelationName := ThemedGridMasterDetailStrings.DefaultRelationName;
  FRelationIndex := 0;
  FDetailRowIndex := -1;
  FDetailColumnIndex := -1;
  FDetailRowObject := TValue.Empty;
  FValue := TValue.Empty;
  FColumn := nil;
  FGridBounds := TRect.Empty;
  FRowBounds := TRect.Empty;
  FCellBounds := TRect.Empty;
  FIsHeader := False;
end;

end.

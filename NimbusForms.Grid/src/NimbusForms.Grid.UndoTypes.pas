unit NimbusForms.Grid.UndoTypes;

interface

uses
  System.Rtti,
  System.Generics.Collections;

type
  TThemedGridRowStateDisposer = reference to procedure(const ARowState: TValue);

  TThemedGridUndoCellChange = class sealed
  private
    FDataSourceIndex: Integer;
    FColumnName: string;
    FOldValue: TValue;
    FNewValue: TValue;
  public
    constructor Create(const ADataSourceIndex: Integer; const AColumnName: string;
      const AOldValue, ANewValue: TValue);
    property DataSourceIndex: Integer read FDataSourceIndex;
    property ColumnName: string read FColumnName;
    property OldValue: TValue read FOldValue;
    property NewValue: TValue read FNewValue;
  end;

  TThemedGridUndoRowMove = class sealed
  private
    FFromDataSourceIndex: Integer;
    FToDataSourceIndex: Integer;
  public
    constructor Create(const AFromDataSourceIndex, AToDataSourceIndex: Integer);
    property FromDataSourceIndex: Integer read FFromDataSourceIndex;
    property ToDataSourceIndex: Integer read FToDataSourceIndex;
  end;

  TThemedGridUndoRowAction = class sealed
  private
    FAdded: Boolean;
    FDataSourceIndex: Integer;
    FRowState: TValue;
    FDisposer: TThemedGridRowStateDisposer;
    FOwnsState: Boolean;
  public
    constructor Create(const AAdded: Boolean; const ADataSourceIndex: Integer; const ARowState: TValue;
      const ADisposer: TThemedGridRowStateDisposer; const AOwnsState: Boolean);
    destructor Destroy; override;
    property Added: Boolean read FAdded;
    property DataSourceIndex: Integer read FDataSourceIndex;
    property RowState: TValue read FRowState;
    property OwnsState: Boolean read FOwnsState write FOwnsState;
  end;

  TThemedGridUndoUnit = class sealed
  private
    FName: string;
    FChanges: TObjectList<TThemedGridUndoCellChange>;
    FRowMoves: TObjectList<TThemedGridUndoRowMove>;
    FRowActions: TObjectList<TThemedGridUndoRowAction>;
    function GetCount: Integer;
  public
    constructor Create(const AName: string);
    destructor Destroy; override;
    procedure Add(const AChange: TThemedGridUndoCellChange); overload;
    procedure Add(const ARowMove: TThemedGridUndoRowMove); overload;
    procedure Add(const ARowAction: TThemedGridUndoRowAction); overload;
    property Name: string read FName;
    property Count: Integer read GetCount;
    property Changes: TObjectList<TThemedGridUndoCellChange> read FChanges;
    property RowMoves: TObjectList<TThemedGridUndoRowMove> read FRowMoves;
    property RowActions: TObjectList<TThemedGridUndoRowAction> read FRowActions;
  end;

implementation

constructor TThemedGridUndoCellChange.Create(const ADataSourceIndex: Integer; const AColumnName: string;
  const AOldValue, ANewValue: TValue);
begin
  inherited Create;
  FDataSourceIndex := ADataSourceIndex;
  FColumnName := AColumnName;
  FOldValue := AOldValue;
  FNewValue := ANewValue;
end;

constructor TThemedGridUndoRowMove.Create(const AFromDataSourceIndex, AToDataSourceIndex: Integer);
begin
  inherited Create;
  FFromDataSourceIndex := AFromDataSourceIndex;
  FToDataSourceIndex := AToDataSourceIndex;
end;

constructor TThemedGridUndoRowAction.Create(const AAdded: Boolean; const ADataSourceIndex: Integer;
  const ARowState: TValue; const ADisposer: TThemedGridRowStateDisposer; const AOwnsState: Boolean);
begin
  inherited Create;
  FAdded := AAdded;
  FDataSourceIndex := ADataSourceIndex;
  FRowState := ARowState;
  FDisposer := ADisposer;
  FOwnsState := AOwnsState;
end;

destructor TThemedGridUndoRowAction.Destroy;
begin
  if FOwnsState and Assigned(FDisposer) then
    FDisposer(FRowState);
  inherited Destroy;
end;

constructor TThemedGridUndoUnit.Create(const AName: string);
begin
  inherited Create;
  FName := AName;
  FChanges := TObjectList<TThemedGridUndoCellChange>.Create(True);
  FRowMoves := TObjectList<TThemedGridUndoRowMove>.Create(True);
  FRowActions := TObjectList<TThemedGridUndoRowAction>.Create(True);
end;

destructor TThemedGridUndoUnit.Destroy;
begin
  FRowActions.Free;
  FRowMoves.Free;
  FChanges.Free;
  inherited Destroy;
end;

function TThemedGridUndoUnit.GetCount: Integer;
begin
  Result := FChanges.Count + FRowMoves.Count + FRowActions.Count;
end;

procedure TThemedGridUndoUnit.Add(const AChange: TThemedGridUndoCellChange);
begin
  if AChange <> nil then
    FChanges.Add(AChange);
end;

procedure TThemedGridUndoUnit.Add(const ARowMove: TThemedGridUndoRowMove);
begin
  if ARowMove <> nil then
    FRowMoves.Add(ARowMove);
end;

procedure TThemedGridUndoUnit.Add(const ARowAction: TThemedGridUndoRowAction);
begin
  if ARowAction <> nil then
    FRowActions.Add(ARowAction);
end;

end.

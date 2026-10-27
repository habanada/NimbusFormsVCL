unit NimbusForms.Grid.ControlRows;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  System.Rtti,
  System.Generics.Collections,
  NimbusForms.Grid.Events.Rows,
  NimbusForms.Grid.RowActionOptions,
  NimbusForms.Grid.ControlUndo;

type
  TThemedGridControlRows = class(TThemedGridControlUndo)
  private
    FRowActionOptions: TThemedGridRowActionOptions;
    FOnRowAdding: TThemedGridRowAddingEvent;
    FOnRowAdded: TThemedGridRowAddedEvent;
    FOnRowRemoving: TThemedGridRowRemovingEvent;
    FOnRowRemoved: TThemedGridRowRemovedEvent;
    procedure RowActionOptionsChanged(ASender: TObject);
    function GetCanAddRows: Boolean;
    function GetCanRemoveRows: Boolean;
    function GetSelectedDataRowIndexes: TArray<Integer>;
    function ConfirmRemoveRows(const ARowCount: Integer): Boolean;
  protected
    function TryHandleExtendedKey(var AKey: Word; const AShift: TShiftState): Boolean; override;
    procedure DoRowAdding(const AArgs: TThemedGridRowAddingEventArgs); virtual;
    procedure DoRowAdded(const AArgs: TThemedGridRowAddedEventArgs); virtual;
    procedure DoRowRemoving(const AArgs: TThemedGridRowRemovingEventArgs); virtual;
    procedure DoRowRemoved(const AArgs: TThemedGridRowRemovedEventArgs); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function AddRowAtEnd: Integer;
    function AddRowBelowCurrent: Integer;
    function AddRow(const AInsertBeforeRowIndex: Integer): Integer;
    function RemoveCurrentRow: Boolean;
    function RemoveSelectedRows: Boolean;
    function RemoveRows(const ARowIndexes: array of Integer): Boolean;
    property RowActionOptions: TThemedGridRowActionOptions read FRowActionOptions;
    property CanAddRows: Boolean read GetCanAddRows;
    property CanRemoveRows: Boolean read GetCanRemoveRows;
    property OnRowAdding: TThemedGridRowAddingEvent read FOnRowAdding write FOnRowAdding;
    property OnRowAdded: TThemedGridRowAddedEvent read FOnRowAdded write FOnRowAdded;
    property OnRowRemoving: TThemedGridRowRemovingEvent read FOnRowRemoving write FOnRowRemoving;
    property OnRowRemoved: TThemedGridRowRemovedEvent read FOnRowRemoved write FOnRowRemoved;
  end;

implementation

uses
  System.Generics.Defaults,
  NimbusForms.Grid.UndoTypes,
  NimbusForms.Grid.UndoStrings;

type
  TUStr = TThemedGridUndoStrings;

constructor TThemedGridControlRows.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRowActionOptions := TThemedGridRowActionOptions.Create;
  FRowActionOptions.OnChanged := RowActionOptionsChanged;
end;

destructor TThemedGridControlRows.Destroy;
begin
  FRowActionOptions.Free;
  inherited Destroy;
end;

procedure TThemedGridControlRows.RowActionOptionsChanged(ASender: TObject);
begin
  Invalidate;
end;

function TThemedGridControlRows.GetCanAddRows: Boolean;
begin
  Result := FRowActionOptions.AllowAddRows and (DataController <> nil) and DataController.CanAddRows;
end;

function TThemedGridControlRows.GetCanRemoveRows: Boolean;
begin
  Result := FRowActionOptions.AllowRemoveRows and (DataController <> nil) and DataController.CanRemoveRows;
end;

procedure TThemedGridControlRows.DoRowAdding(const AArgs: TThemedGridRowAddingEventArgs);
begin
  if Assigned(FOnRowAdding) then
    FOnRowAdding(Self, AArgs);
end;

procedure TThemedGridControlRows.DoRowAdded(const AArgs: TThemedGridRowAddedEventArgs);
begin
  if Assigned(FOnRowAdded) then
    FOnRowAdded(Self, AArgs);
end;

procedure TThemedGridControlRows.DoRowRemoving(const AArgs: TThemedGridRowRemovingEventArgs);
begin
  if Assigned(FOnRowRemoving) then
    FOnRowRemoving(Self, AArgs);
end;

procedure TThemedGridControlRows.DoRowRemoved(const AArgs: TThemedGridRowRemovedEventArgs);
begin
  if Assigned(FOnRowRemoved) then
    FOnRowRemoved(Self, AArgs);
end;

function TThemedGridControlRows.AddRowAtEnd: Integer;
begin
  Result := AddRow(-1);
end;

function TThemedGridControlRows.AddRowBelowCurrent: Integer;
var
  LNextRowIndex: Integer;
begin
  if CurrentRowIndex < 0 then
    Exit(AddRow(-1));
  if CurrentRowIndex + 1 < RowCount then
    LNextRowIndex := FindDataViewRow(CurrentRowIndex + 1, 1)
  else
    LNextRowIndex := -1;
  Result := AddRow(LNextRowIndex);
end;

function TThemedGridControlRows.AddRow(const AInsertBeforeRowIndex: Integer): Integer;
var
  LInsertIndex, LNewDataSourceIndex, LNewRowIndex, LColumnIndex: Integer;
  LRowState: TValue;
  LAdding: TThemedGridRowAddingEventArgs;
  LAdded: TThemedGridRowAddedEventArgs;
  LCancel: Boolean;
begin
  Result := -1;
  if not CanAddRows then
    Exit;

  if (AInsertBeforeRowIndex >= 0) and (AInsertBeforeRowIndex < RowCount) then
    LInsertIndex := GetViewRowDataSourceIndex(AInsertBeforeRowIndex)
  else
    LInsertIndex := -1;

  LAdding := TThemedGridRowAddingEventArgs.Create;
  try
    LAdding.InsertIndex := LInsertIndex;
    LAdding.TargetRowIndex := AInsertBeforeRowIndex;
    LAdding.RowObject := TValue.Empty;
    DoRowAdding(LAdding);
    LCancel := LAdding.Cancel;
    LInsertIndex := LAdding.InsertIndex;
    LRowState := LAdding.RowObject;
  finally
    LAdding.Free;
  end;
  if LCancel then
    Exit;

  if IsEditing then
    CommitEdit;
  if IsRowEditing then
    EndRowEdit(True);

  UndoManager.BeginTransaction(TUStr.UnitNameRowAdd);
  BeginUpdate;
  try
    LNewDataSourceIndex := DataController.AddRow(LInsertIndex, LRowState);
    if (LNewDataSourceIndex >= 0) and UndoOptions.Enabled and not UndoManager.IsSuspended then
      UndoManager.RecordRowAction(
        TThemedGridUndoRowAction.Create(True, LNewDataSourceIndex,
          DataController.CloneRowState(LNewDataSourceIndex), CreateRowStateDisposer(), False),
        TUStr.UnitNameRowAdd);
  finally
    EndUpdate;
    UndoManager.EndTransaction;
  end;

  if LNewDataSourceIndex < 0 then
    Exit;

  RefreshAfterRowStructureChanged;

  LNewRowIndex := FindDataViewRowByDataSourceIndex(LNewDataSourceIndex);
  if FRowActionOptions.SelectAddedRow and (LNewRowIndex >= 0) then
  begin
    if CurrentColumnIndex >= 0 then
      LColumnIndex := CurrentColumnIndex
    else
      LColumnIndex := 0;
    SetCurrentCell(LNewRowIndex, LColumnIndex);
    EnsureVisible(LNewRowIndex, LColumnIndex);
  end;

  LAdded := TThemedGridRowAddedEventArgs.Create;
  try
    LAdded.RowIndex := LNewRowIndex;
    LAdded.DataSourceIndex := LNewDataSourceIndex;
    LAdded.RowObject := DataController.GetRowObject(LNewDataSourceIndex);
    DoRowAdded(LAdded);
  finally
    LAdded.Free;
  end;
  Result := LNewDataSourceIndex;
end;

function TThemedGridControlRows.RemoveCurrentRow: Boolean;
begin
  if CurrentRowIndex < 0 then
    Exit(False);
  Result := RemoveRows([CurrentRowIndex]);
end;

function TThemedGridControlRows.GetSelectedDataRowIndexes: TArray<Integer>;
var
  LList: TList<Integer>;
  LRowIndex: Integer;
begin
  LList := TList<Integer>.Create;
  try
    for LRowIndex := 0 to RowCount - 1 do
    begin
      if not IsDataViewRow(LRowIndex) then
        Continue;
      if IsRowSelected(LRowIndex) then
        LList.Add(LRowIndex);
    end;
    Result := LList.ToArray;
  finally
    LList.Free;
  end;
end;

function TThemedGridControlRows.RemoveSelectedRows: Boolean;
var
  LIndexes: TArray<Integer>;
begin
  LIndexes := GetSelectedDataRowIndexes;
  if Length(LIndexes) = 0 then
    Exit(RemoveCurrentRow);
  Result := RemoveRows(LIndexes);
end;

function TThemedGridControlRows.ConfirmRemoveRows(const ARowCount: Integer): Boolean;
var
  LText: string;
begin
  if ARowCount = 1 then
    LText := TUStr.RemoveConfirmSingleText
  else
    LText := Format(TUStr.RemoveConfirmMultipleText, [ARowCount]);
  Result := MessageBox(Handle, PChar(LText), PChar(TUStr.RemoveConfirmCaption), MB_YESNO or MB_ICONQUESTION) = IDYES;
end;

function TThemedGridControlRows.RemoveRows(const ARowIndexes: array of Integer): Boolean;
var
  LDataSourceIndexes: TList<Integer>;
  LDataSourceIndex, I, LRemoved, LFirstRowIndex: Integer;
  LRowState, LFirstRowObject: TValue;
  LRemoving: TThemedGridRowRemovingEventArgs;
  LRemovedArgs: TThemedGridRowRemovedEventArgs;
  LCancel: Boolean;
  LFirstDataSourceIndex: Integer;
  LDisposer: TThemedGridRowStateDisposer;
begin
  Result := False;
  if not CanRemoveRows or (Length(ARowIndexes) = 0) then
    Exit;

  LDataSourceIndexes := TList<Integer>.Create;
  try
    LFirstRowIndex := ARowIndexes[0];
    for I := 0 to High(ARowIndexes) do
    begin
      LDataSourceIndex := GetViewRowDataSourceIndex(ARowIndexes[I]);
      if (LDataSourceIndex >= 0) and not LDataSourceIndexes.Contains(LDataSourceIndex) then
        LDataSourceIndexes.Add(LDataSourceIndex);
    end;
    if LDataSourceIndexes.Count = 0 then
      Exit;

    LFirstDataSourceIndex := LDataSourceIndexes[0];
    LFirstRowObject := DataController.GetRowObject(LFirstDataSourceIndex);

    LRemoving := TThemedGridRowRemovingEventArgs.Create;
    try
      LRemoving.RowIndex := LFirstRowIndex;
      LRemoving.DataSourceIndex := LFirstDataSourceIndex;
      LRemoving.RowObject := LFirstRowObject;
      LRemoving.RowCount := LDataSourceIndexes.Count;
      DoRowRemoving(LRemoving);
      LCancel := LRemoving.Cancel;
    finally
      LRemoving.Free;
    end;
    if LCancel then
      Exit;

    if FRowActionOptions.ConfirmRemove and not ConfirmRemoveRows(LDataSourceIndexes.Count) then
      Exit;

    if IsEditing then
      CommitEdit;
    if IsRowEditing then
      EndRowEdit(True);

    LDataSourceIndexes.Sort;
    LRemoved := 0;

    UndoManager.BeginTransaction(TUStr.UnitNameRowRemove);
    BeginUpdate;
    try
      for I := LDataSourceIndexes.Count - 1 downto 0 do
      begin
        LDataSourceIndex := LDataSourceIndexes[I];
        LRowState := DataController.CloneRowState(LDataSourceIndex);
        if not DataController.RemoveRow(LDataSourceIndex) then
          Continue;
        Inc(LRemoved);
        if UndoOptions.Enabled and not UndoManager.IsSuspended then
          UndoManager.RecordRowAction(
            TThemedGridUndoRowAction.Create(False, LDataSourceIndex, LRowState, CreateRowStateDisposer(), True),
            TUStr.UnitNameRowRemove)
        else
        begin
          LDisposer := CreateRowStateDisposer();
          if Assigned(LDisposer) then
            LDisposer(LRowState);
        end;
      end;
    finally
      EndUpdate;
      UndoManager.EndTransaction;
    end;

    if LRemoved = 0 then
      Exit;

    RefreshAfterRowStructureChanged;
    NormalizeCurrentCellAfterRemove;

    LRemovedArgs := TThemedGridRowRemovedEventArgs.Create;
    try
      LRemovedArgs.DataSourceIndex := LFirstDataSourceIndex;
      LRemovedArgs.RowObject := LFirstRowObject;
      LRemovedArgs.RemovedRowCount := LRemoved;
      DoRowRemoved(LRemovedArgs);
    finally
      LRemovedArgs.Free;
    end;
    Result := True;
  finally
    LDataSourceIndexes.Free;
  end;
end;

function TThemedGridControlRows.TryHandleExtendedKey(var AKey: Word; const AShift: TShiftState): Boolean;
begin
  if not IsEditing then
  begin
    if (AShift = []) and (AKey = VK_INSERT) and FRowActionOptions.InsertKeyAddsRow and CanAddRows then
    begin
      AddRowBelowCurrent;
      Exit(True);
    end;
    if not (ssCtrl in AShift) and not (ssAlt in AShift) and (AKey = VK_DELETE) and
      FRowActionOptions.DeleteKeyRemovesRow and CanRemoveRows then
    begin
      RemoveSelectedRows;
      Exit(True);
    end;
  end;
  Result := inherited TryHandleExtendedKey(AKey, AShift);
end;

end.

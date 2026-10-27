unit NimbusForms.Grid.ControlUndo;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  System.Rtti,
  System.Generics.Collections,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.DataControllerIntf,
  NimbusForms.Grid.Events,
  NimbusForms.Grid.Events.Rows,
  NimbusForms.Grid.Events.Undo,
  NimbusForms.Grid.UndoTypes,
  NimbusForms.Grid.UndoManager,
  NimbusForms.Grid.UndoOptions,
  NimbusForms.Grid.ControlEdit;

type
  TThemedGridRowEditOriginal = record
    ColumnName: string;
    Value: TValue;
  end;

  TThemedGridControlUndo = class(TThemedGridControlEdit)
  private
    FUndoManager: TThemedGridUndoManager;
    FUndoOptions: TThemedGridUndoOptions;
    FUpdateCount: Integer;
    FPendingRowsChanged: Boolean;
    FRowEditActive: Boolean;
    FEndingRowEdit: Boolean;
    FRowEditModified: Boolean;
    FRowEditDataSourceIndex: Integer;
    FRowEditRowIndex: Integer;
    FRowEditUndoMark: Integer;
    FRowEditOriginals: TList<TThemedGridRowEditOriginal>;
    FOnUndoStackChanged: TNotifyEvent;
    FOnUndoExecuted: TThemedGridUndoEvent;
    FOnRowValidating: TThemedGridRowValidatingEvent;
    FOnRowUpdated: TThemedGridRowEvent;
    FOnRowChangesCanceled: TThemedGridRowEvent;
    procedure UndoManagerChanged(ASender: TObject);
    procedure UndoOptionsChanged(ASender: TObject);
    function GetCanUndo: Boolean;
    function GetCanRedo: Boolean;
    function GetIsUpdating: Boolean;
    function ApplyUndoUnit(const AUnit: TThemedGridUndoUnit; const ARedo: Boolean): Integer;
    function ApplyUndoRowAction(const ARowAction: TThemedGridUndoRowAction; const AInvert: Boolean): Boolean;
    function ApplyUndoRowMove(const AFromDataSourceIndex, AToDataSourceIndex: Integer): Boolean;
    function ApplyUndoChange(const AChange: TThemedGridUndoCellChange; const AValue: TValue): Boolean;
    procedure RevertRowEdit(const ADataSourceIndex: Integer);
    procedure ResetRowEditState;
  protected
    procedure DoRowsChanged; override;
    procedure DoDataSourceChanging(const AArgs: TThemedGridDataSourceChangingEventArgs); override;
    procedure DataSourceReset; override;
    function EndRowEditForRow(const ARowIndex: Integer): Boolean; override;
    function TryHandleExtendedKey(var AKey: Word; const AShift: TShiftState): Boolean; override;
    procedure BeginRowEdit(const ARowIndex, ADataSourceIndex: Integer; const ARowObject: TValue); override;
    procedure MarkRowEditModified(const ADataSourceIndex: Integer); override;
    procedure RecordCellChange(const ADataSourceIndex: Integer; const AColumn: TThemedGridColumn;
      const AOldValue, ANewValue: TValue; const AChangeReason: string); override;
    function CreateRowStateDisposer: TThemedGridRowStateDisposer;
    procedure RefreshAfterRowStructureChanged;
    procedure NormalizeCurrentCellAfterRemove;
    procedure DoUndoStackChanged; virtual;
    procedure DoUndoExecuted(const AArgs: TThemedGridUndoEventArgs); virtual;
    procedure DoRowValidating(const AArgs: TThemedGridRowValidatingEventArgs); virtual;
    procedure DoRowUpdated(const AArgs: TThemedGridRowEventArgs); virtual;
    procedure DoRowChangesCanceled(const AArgs: TThemedGridRowEventArgs); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure CancelUpdate;
    procedure BeginUndoTransaction(const AName: string);
    procedure EndUndoTransaction;
    procedure ClearUndoHistory;
    function Undo: Boolean;
    function Redo: Boolean;
    function EndRowEdit(const ACommit: Boolean = True): Boolean;
    function CancelRowEdit: Boolean;
    property IsUpdating: Boolean read GetIsUpdating;
    property UndoManager: TThemedGridUndoManager read FUndoManager;
    property UndoOptions: TThemedGridUndoOptions read FUndoOptions;
    property CanUndo: Boolean read GetCanUndo;
    property CanRedo: Boolean read GetCanRedo;
    property IsRowEditing: Boolean read FRowEditActive;
    property EditingRowDataSourceIndex: Integer read FRowEditDataSourceIndex;
    property OnUndoStackChanged: TNotifyEvent read FOnUndoStackChanged write FOnUndoStackChanged;
    property OnUndoExecuted: TThemedGridUndoEvent read FOnUndoExecuted write FOnUndoExecuted;
    property OnRowValidating: TThemedGridRowValidatingEvent read FOnRowValidating write FOnRowValidating;
    property OnRowUpdated: TThemedGridRowEvent read FOnRowUpdated write FOnRowUpdated;
    property OnRowChangesCanceled: TThemedGridRowEvent read FOnRowChangesCanceled write FOnRowChangesCanceled;
  end;

implementation

uses
  System.Math,
  NimbusForms.Grid.UndoStrings;

type
  TUStr = TThemedGridUndoStrings;

constructor TThemedGridControlUndo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRowEditDataSourceIndex := -1;
  FRowEditRowIndex := -1;
  FRowEditOriginals := TList<TThemedGridRowEditOriginal>.Create;
  FUndoManager := TThemedGridUndoManager.Create;
  FUndoManager.OnChanged := UndoManagerChanged;
  FUndoOptions := TThemedGridUndoOptions.Create;
  FUndoOptions.OnChanged := UndoOptionsChanged;
end;

destructor TThemedGridControlUndo.Destroy;
begin
  FUndoManager.OnChanged := nil;
  FUndoOptions.Free;
  FUndoManager.Free;
  FRowEditOriginals.Free;
  inherited Destroy;
end;

procedure TThemedGridControlUndo.UndoManagerChanged(ASender: TObject);
begin
  DoUndoStackChanged;
end;

procedure TThemedGridControlUndo.UndoOptionsChanged(ASender: TObject);
begin
  FUndoManager.MaxDepth := FUndoOptions.MaxDepth;
  if not FUndoOptions.Enabled then
    FUndoManager.Clear;
end;

function TThemedGridControlUndo.GetCanUndo: Boolean;
begin
  Result := FUndoOptions.Enabled and FUndoManager.CanUndo and (DataController <> nil);
end;

function TThemedGridControlUndo.GetCanRedo: Boolean;
begin
  Result := FUndoOptions.Enabled and FUndoManager.CanRedo and (DataController <> nil);
end;

function TThemedGridControlUndo.GetIsUpdating: Boolean;
begin
  Result := FUpdateCount > 0;
end;

procedure TThemedGridControlUndo.DoUndoStackChanged;
begin
  if Assigned(FOnUndoStackChanged) then
    FOnUndoStackChanged(Self);
end;

procedure TThemedGridControlUndo.DoUndoExecuted(const AArgs: TThemedGridUndoEventArgs);
begin
  if Assigned(FOnUndoExecuted) then
    FOnUndoExecuted(Self, AArgs);
end;

procedure TThemedGridControlUndo.DoRowValidating(const AArgs: TThemedGridRowValidatingEventArgs);
begin
  if Assigned(FOnRowValidating) then
    FOnRowValidating(Self, AArgs);
end;

procedure TThemedGridControlUndo.DoRowUpdated(const AArgs: TThemedGridRowEventArgs);
begin
  if Assigned(FOnRowUpdated) then
    FOnRowUpdated(Self, AArgs);
end;

procedure TThemedGridControlUndo.DoRowChangesCanceled(const AArgs: TThemedGridRowEventArgs);
begin
  if Assigned(FOnRowChangesCanceled) then
    FOnRowChangesCanceled(Self, AArgs);
end;

procedure TThemedGridControlUndo.DoRowsChanged;
begin
  if FUpdateCount > 0 then
  begin
    FPendingRowsChanged := True;
    Exit;
  end;
  inherited DoRowsChanged;
end;

procedure TThemedGridControlUndo.DoDataSourceChanging(const AArgs: TThemedGridDataSourceChangingEventArgs);
begin
  inherited DoDataSourceChanging(AArgs);
  if AArgs.Cancel then
    Exit;
  EndRowEdit(True);
  FUndoManager.Clear;
end;

procedure TThemedGridControlUndo.ResetRowEditState;
begin
  FRowEditActive := False;
  FRowEditModified := False;
  FRowEditDataSourceIndex := -1;
  FRowEditRowIndex := -1;
  FRowEditUndoMark := 0;
  FRowEditOriginals.Clear;
end;

procedure TThemedGridControlUndo.DataSourceReset;
begin
  inherited DataSourceReset;
  ResetRowEditState;
  FUndoManager.Clear;
end;

procedure TThemedGridControlUndo.BeginUpdate;
begin
  if (FUpdateCount = 0) and IsEditing then
    CommitEdit;
  Inc(FUpdateCount);
  FUndoManager.BeginTransaction(TUStr.UnitNameBatch);
end;

procedure TThemedGridControlUndo.EndUpdate;
var
  LRowsChanged: Boolean;
begin
  if FUpdateCount <= 0 then
    Exit;
  Dec(FUpdateCount);
  FUndoManager.EndTransaction;
  if FUpdateCount > 0 then
    Exit;
  LRowsChanged := FPendingRowsChanged;
  FPendingRowsChanged := False;
  InvalidateRowView;
  ClearSummaryCache;
  NormalizeScrollValues;
  if LRowsChanged then
    DoRowsChanged;
  Invalidate;
end;

procedure TThemedGridControlUndo.CancelUpdate;
begin
  if FUpdateCount <= 0 then
    Exit;
  FUpdateCount := 0;
  FPendingRowsChanged := False;
  FUndoManager.CancelTransaction;
end;

procedure TThemedGridControlUndo.BeginUndoTransaction(const AName: string);
begin
  FUndoManager.BeginTransaction(AName);
end;

procedure TThemedGridControlUndo.EndUndoTransaction;
begin
  FUndoManager.EndTransaction;
end;

procedure TThemedGridControlUndo.ClearUndoHistory;
begin
  FUndoManager.Clear;
end;

function TThemedGridControlUndo.CreateRowStateDisposer: TThemedGridRowStateDisposer;
var
  LOwner: IThemedGridRowStateOwner;
begin
  Result := nil;
  if (DataController <> nil) and Supports(DataController, IThemedGridRowStateOwner, LOwner) and
    LOwner.OwnsRemovedRows then
    Result :=
      procedure(const ARowState: TValue)
      begin
        LOwner.DisposeRowState(ARowState);
      end;
end;

procedure TThemedGridControlUndo.RefreshAfterRowStructureChanged;
begin
  if DataController = nil then
    Exit;
  DataController.Refresh;
  InvalidateRowView;
  ClearSummaryCache;
  NormalizeScrollValues;
  CheckRowsChanged;
  Invalidate;
end;

procedure TThemedGridControlUndo.NormalizeCurrentCellAfterRemove;
var
  LRowCount, LRowIndex, LColumnIndex: Integer;
begin
  LRowCount := RowCount;
  if LRowCount <= 0 then
  begin
    CurrentRowIndex := -1;
    CurrentColumnIndex := -1;
    SelectionModel.Clear;
    Exit;
  end;
  LRowIndex := CurrentRowIndex;
  if LRowIndex >= LRowCount then
    LRowIndex := LRowCount - 1;
  LRowIndex := NormalizeCellRowIndex(LRowIndex, 1);
  if LRowIndex < 0 then
  begin
    CurrentRowIndex := -1;
    Exit;
  end;
  if CurrentColumnIndex >= 0 then
    LColumnIndex := CurrentColumnIndex
  else
    LColumnIndex := 0;
  CurrentRowIndex := LRowIndex;
  CurrentColumnIndex := LColumnIndex;
  SelectionModel.SelectCell(LRowIndex, LColumnIndex);
  EnsureVisible(LRowIndex, LColumnIndex);
end;

function TThemedGridControlUndo.ApplyUndoChange(const AChange: TThemedGridUndoCellChange;
  const AValue: TValue): Boolean;
var
  LColumn: TThemedGridColumn;
begin
  Result := False;
  if (AChange = nil) or (AChange.DataSourceIndex < 0) or (DataController = nil) then
    Exit;
  LColumn := GetColumn(AChange.ColumnName);
  if (LColumn = nil) or LColumn.ReadOnly then
    Exit;
  if not DataController.CanSetValue(LColumn) then
    Exit;
  DataController.SetValue(AChange.DataSourceIndex, LColumn, AValue);
  Result := True;
end;

function TThemedGridControlUndo.ApplyUndoRowAction(const ARowAction: TThemedGridUndoRowAction;
  const AInvert: Boolean): Boolean;
var
  LAdd: Boolean;
begin
  Result := False;
  if (ARowAction = nil) or (DataController = nil) then
    Exit;
  LAdd := ARowAction.Added xor AInvert;
  if LAdd then
  begin
    if not DataController.CanAddRows then
      Exit;
    Result := DataController.AddRow(ARowAction.DataSourceIndex, ARowAction.RowState) >= 0;
    if Result then
      ARowAction.OwnsState := False;
    Exit;
  end;
  if not DataController.CanRemoveRows then
    Exit;
  Result := DataController.RemoveRow(ARowAction.DataSourceIndex);
  if Result then
    ARowAction.OwnsState := True;
end;

function TThemedGridControlUndo.ApplyUndoRowMove(const AFromDataSourceIndex, AToDataSourceIndex: Integer): Boolean;
begin
  Result := False;
  if (DataController = nil) or not DataController.CanMoveRows then
    Exit;
  if (AFromDataSourceIndex < 0) or (AToDataSourceIndex < 0) then
    Exit;
  Result := DataController.MoveRow(AFromDataSourceIndex, AToDataSourceIndex);
end;

function TThemedGridControlUndo.ApplyUndoUnit(const AUnit: TThemedGridUndoUnit; const ARedo: Boolean): Integer;
var
  I: Integer;
  LRowsMoved: Boolean;
begin
  Result := 0;
  if AUnit = nil then
    Exit;
  if IsEditing then
    CommitEdit;
  if FRowEditActive then
    EndRowEdit(True);

  LRowsMoved := False;
  FUndoManager.Suspend;
  BeginUpdate;
  try
    if ARedo then
    begin
      for I := 0 to AUnit.Changes.Count - 1 do
        if ApplyUndoChange(AUnit.Changes[I], AUnit.Changes[I].NewValue) then
          Inc(Result);
      for I := 0 to AUnit.RowMoves.Count - 1 do
        if ApplyUndoRowMove(AUnit.RowMoves[I].FromDataSourceIndex, AUnit.RowMoves[I].ToDataSourceIndex) then
        begin
          Inc(Result);
          LRowsMoved := True;
        end;
      for I := 0 to AUnit.RowActions.Count - 1 do
        if ApplyUndoRowAction(AUnit.RowActions[I], False) then
        begin
          Inc(Result);
          LRowsMoved := True;
        end;
    end
    else
    begin
      for I := AUnit.RowActions.Count - 1 downto 0 do
        if ApplyUndoRowAction(AUnit.RowActions[I], True) then
        begin
          Inc(Result);
          LRowsMoved := True;
        end;
      for I := AUnit.RowMoves.Count - 1 downto 0 do
        if ApplyUndoRowMove(AUnit.RowMoves[I].ToDataSourceIndex, AUnit.RowMoves[I].FromDataSourceIndex) then
        begin
          Inc(Result);
          LRowsMoved := True;
        end;
      for I := AUnit.Changes.Count - 1 downto 0 do
        if ApplyUndoChange(AUnit.Changes[I], AUnit.Changes[I].OldValue) then
          Inc(Result);
    end;
  finally
    EndUpdate;
    FUndoManager.Resume;
  end;

  if LRowsMoved and (DataController <> nil) then
  begin
    RefreshAfterRowStructureChanged;
    NormalizeCurrentCellAfterRemove;
  end;
end;

function TThemedGridControlUndo.Undo: Boolean;
var
  LUnit: TThemedGridUndoUnit;
  LArgs: TThemedGridUndoEventArgs;
begin
  if not CanUndo then
    Exit(False);
  LUnit := FUndoManager.PopUndo;
  if LUnit = nil then
    Exit(False);
  LArgs := TThemedGridUndoEventArgs.Create(LUnit, False);
  try
    try
      LArgs.AppliedCellCount := ApplyUndoUnit(LUnit, False);
    finally
      FUndoManager.PushRedo(LUnit);
    end;
    LArgs.SkippedCellCount := LUnit.Count - LArgs.AppliedCellCount;
    DoUndoExecuted(LArgs);
  finally
    LArgs.Free;
  end;
  Result := True;
end;

function TThemedGridControlUndo.Redo: Boolean;
var
  LUnit: TThemedGridUndoUnit;
  LArgs: TThemedGridUndoEventArgs;
begin
  if not CanRedo then
    Exit(False);
  LUnit := FUndoManager.PopRedo;
  if LUnit = nil then
    Exit(False);
  LArgs := TThemedGridUndoEventArgs.Create(LUnit, True);
  try
    try
      LArgs.AppliedCellCount := ApplyUndoUnit(LUnit, True);
    finally
      FUndoManager.PushUndo(LUnit);
    end;
    LArgs.SkippedCellCount := LUnit.Count - LArgs.AppliedCellCount;
    DoUndoExecuted(LArgs);
  finally
    LArgs.Free;
  end;
  Result := True;
end;

procedure TThemedGridControlUndo.BeginRowEdit(const ARowIndex, ADataSourceIndex: Integer; const ARowObject: TValue);
begin
  if not EditOptions.UseRowTransactions then
    Exit;
  if (ADataSourceIndex < 0) or FEndingRowEdit then
    Exit;
  if FRowEditActive and (FRowEditDataSourceIndex = ADataSourceIndex) then
  begin
    FRowEditRowIndex := ARowIndex;
    Exit;
  end;
  if FRowEditActive and not EndRowEdit(True) then
    Exit;
  FRowEditDataSourceIndex := ADataSourceIndex;
  FRowEditRowIndex := ARowIndex;
  FRowEditActive := True;
  FRowEditModified := False;
  FRowEditOriginals.Clear;
  FRowEditUndoMark := FUndoManager.UndoCount;
end;

procedure TThemedGridControlUndo.MarkRowEditModified(const ADataSourceIndex: Integer);
begin
  if FRowEditActive and (FRowEditDataSourceIndex = ADataSourceIndex) then
    FRowEditModified := True;
end;

procedure TThemedGridControlUndo.RecordCellChange(const ADataSourceIndex: Integer; const AColumn: TThemedGridColumn;
  const AOldValue, ANewValue: TValue; const AChangeReason: string);
var
  I: Integer;
  LKnown: Boolean;
  LOriginal: TThemedGridRowEditOriginal;
begin
  if FRowEditActive and (FRowEditDataSourceIndex = ADataSourceIndex) then
  begin
    LKnown := False;
    for I := 0 to FRowEditOriginals.Count - 1 do
      if SameText(FRowEditOriginals[I].ColumnName, AColumn.Name) then
      begin
        LKnown := True;
        Break;
      end;
    if not LKnown then
    begin
      LOriginal.ColumnName := AColumn.Name;
      LOriginal.Value := AOldValue;
      FRowEditOriginals.Add(LOriginal);
    end;
  end;
  if FUndoOptions.Enabled and not FUndoManager.IsSuspended then
    FUndoManager.RecordChange(
      TThemedGridUndoCellChange.Create(ADataSourceIndex, AColumn.Name, AOldValue, ANewValue), AChangeReason);
end;

procedure TThemedGridControlUndo.RevertRowEdit(const ADataSourceIndex: Integer);
var
  I: Integer;
  LColumn: TThemedGridColumn;
begin
  if DataController = nil then
    Exit;
  for I := FRowEditOriginals.Count - 1 downto 0 do
  begin
    LColumn := GetColumn(FRowEditOriginals[I].ColumnName);
    if (LColumn <> nil) and DataController.CanSetValue(LColumn) then
      DataController.SetValue(ADataSourceIndex, LColumn, FRowEditOriginals[I].Value);
    DropCellError(ADataSourceIndex, FRowEditOriginals[I].ColumnName);
  end;
  FUndoManager.TruncateUndo(FRowEditUndoMark);
end;

function TThemedGridControlUndo.EndRowEdit(const ACommit: Boolean): Boolean;
var
  LDataSourceIndex, LRowIndex: Integer;
  LModified, LCancel: Boolean;
  LRowObject: TValue;
  LValidating: TThemedGridRowValidatingEventArgs;
  LArgs: TThemedGridRowEventArgs;
begin
  if not FRowEditActive or FEndingRowEdit then
    Exit(True);

  LDataSourceIndex := FRowEditDataSourceIndex;
  LRowIndex := FRowEditRowIndex;
  LModified := FRowEditModified;
  if DataController <> nil then
    LRowObject := DataController.GetRowObject(LDataSourceIndex)
  else
    LRowObject := TValue.Empty;

  FEndingRowEdit := True;
  try
    if ACommit and LModified then
    begin
      LValidating := TThemedGridRowValidatingEventArgs.Create;
      try
        LValidating.RowIndex := LRowIndex;
        LValidating.DataSourceIndex := LDataSourceIndex;
        LValidating.RowObject := LRowObject;
        DoRowValidating(LValidating);
        LCancel := LValidating.Cancel;
      finally
        LValidating.Free;
      end;
      if LCancel then
        Exit(False);
    end;

    if not ACommit then
      RevertRowEdit(LDataSourceIndex);

    ResetRowEditState;

    if not LModified then
      Exit(True);

    LArgs := TThemedGridRowEventArgs.Create;
    try
      LArgs.RowIndex := LRowIndex;
      LArgs.DataSourceIndex := LDataSourceIndex;
      LArgs.RowObject := LRowObject;
      if ACommit then
        DoRowUpdated(LArgs)
      else
      begin
        InvalidateRowView;
        ClearSummaryCache;
        DoRowChangesCanceled(LArgs);
        Invalidate;
      end;
    finally
      LArgs.Free;
    end;
    Result := True;
  finally
    FEndingRowEdit := False;
  end;
end;

function TThemedGridControlUndo.CancelRowEdit: Boolean;
begin
  Result := EndRowEdit(False);
end;

function TThemedGridControlUndo.EndRowEditForRow(const ARowIndex: Integer): Boolean;
var
  LDataSourceIndex: Integer;
begin
  if not FRowEditActive or FEndingRowEdit then
    Exit(True);
  LDataSourceIndex := GetViewRowDataSourceIndex(ARowIndex);
  if (LDataSourceIndex >= 0) and (LDataSourceIndex = FRowEditDataSourceIndex) then
    Exit(True);
  Result := EndRowEdit(True);
end;

function TThemedGridControlUndo.TryHandleExtendedKey(var AKey: Word; const AShift: TShiftState): Boolean;
begin
  if not IsEditing then
  begin
    if (ssCtrl in AShift) and not (ssAlt in AShift) and (AKey = Ord('Z')) then
    begin
      if ssShift in AShift then
        Redo
      else
        Undo;
      Exit(True);
    end;
    if (AShift = [ssCtrl]) and (AKey = Ord('Y')) then
    begin
      Redo;
      Exit(True);
    end;
    if (AShift = []) and (AKey = VK_ESCAPE) and FRowEditActive then
    begin
      CancelRowEdit;
      Exit(True);
    end;
  end;
  Result := inherited TryHandleExtendedKey(AKey, AShift);
end;

end.

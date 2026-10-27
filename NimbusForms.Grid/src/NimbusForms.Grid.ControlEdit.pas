unit NimbusForms.Grid.ControlEdit;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Types,
  System.Classes,
  System.SysUtils,
  System.Rtti,
  System.TypInfo,
  Vcl.Controls,
  NimbusForms.Theming.Palette,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.Cell,
  NimbusForms.Grid.HitInfo,
  NimbusForms.Grid.Events,
  NimbusForms.Grid.EditorIntf,
  NimbusForms.Grid.EditorHost,
  NimbusForms.Grid.EditorFactory,
  NimbusForms.Grid.ControlKeys;

const
  WM_GRID_EDITOR_COMMIT = WM_USER + 401;
  WM_GRID_EDITOR_CANCEL = WM_USER + 402;
  WM_GRID_EDITOR_LOSTFOCUS = WM_USER + 403;

type
  TThemedGridControlEdit = class(TThemedGridControlKeys)
  private
    FEditorHost: TThemedGridEditorHost;
    FEditorFactory: TThemedGridEditorFactory;
    FEditToken: Integer;
    FCommitting: Boolean;
    FSliderDragging: Boolean;
    FSliderRowIndex: Integer;
    FSliderColumnIndex: Integer;
    FOnCellValidating: TThemedGridCellValidatingEvent;
    FOnCellValueChanging: TThemedGridCellValueChangingEvent;
    FOnCellValueChanged: TThemedGridCellValueChangedEvent;
    FOnCellEditCommitted: TThemedGridCellEditEvent;
    FOnCellEditCanceled: TThemedGridCellEditEvent;
    procedure WMEditorCommit(var AMessage: TMessage); message WM_GRID_EDITOR_COMMIT;
    procedure WMEditorCancel(var AMessage: TMessage); message WM_GRID_EDITOR_CANCEL;
    procedure WMEditorLostFocus(var AMessage: TMessage); message WM_GRID_EDITOR_LOSTFOCUS;
    procedure EditorKeyDown(ASender: TObject; var AKey: Word; AShift: TShiftState);
    procedure EditorExit(ASender: TObject);
    function ContainsFocusWindow: Boolean;
    function CreateEditContext(const ACell: TThemedGridCell): TThemedGridCellEditContext;
    function CanEditColumn(const AColumn: TThemedGridColumn): Boolean;
    function ToggleBooleanAt(const ARowIndex, AColumnIndex: Integer; const AReason: string): Boolean;
    function TryHandleDirectCheckBoxClick(const AHit: TThemedGridHitInfo; const ALocation: TPoint): Boolean;
    function TryHandleDirectToggleClick(const AHit: TThemedGridHitInfo): Boolean;
    function TryHandleDirectRatingClick(const AHit: TThemedGridHitInfo; const ALocation: TPoint): Boolean;
    function TryHandleDirectSliderClick(const AHit: TThemedGridHitInfo; const ALocation: TPoint;
      const ABeginDrag: Boolean): Boolean;
    procedure UpdateSliderDrag(const ALocation: TPoint);
    procedure EndSliderDrag;
    procedure FinishEditorClose(const AHadFocus: Boolean);
    function GetEditing: Boolean;
  protected
    procedure ApplyTheme(const APalette: TThemePalette); override;
    procedure DataSourceReset; override;
    procedure ColumnsStructureChanged; override;
    procedure Resize; override;
    procedure MouseMove(AShift: TShiftState; AX, AY: Integer); override;
    procedure MouseUp(AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer); override;
    function IsEditing: Boolean; override;
    procedure UpdateEditorBounds; override;
    function CanBeginEditFromHit(const AHit: TThemedGridHitInfo): Boolean; override;
    function HitTestDirectValueGlyph(const AHit: TThemedGridHitInfo; const ALocation: TPoint): Boolean; override;
    function TryHandleDirectValueClick(const AHit: TThemedGridHitInfo; const ALocation: TPoint): Boolean; override;
    function ResolveCellCursor(const AHit: TThemedGridHitInfo; const ALocation: TPoint): TCursor; override;
    function TryHandleExtendedKey(var AKey: Word; const AShift: TShiftState): Boolean; override;
    function ToggleCurrentCellBooleanValue: Boolean; override;
    function TryStepCurrentCellValue(const ADirection: Integer): Boolean; override;
    function CanBeginEditCurrentCell: Boolean; override;
    function ConvertEditorValue(const AValue: TValue; const ATargetType: PTypeInfo): TValue; virtual;
    function ResolveValueType(const AColumn: TThemedGridColumn): PTypeInfo;
    function IsColumnStructuralForCurrentView(const AColumn: TThemedGridColumn): Boolean;
    procedure StoreCellError(const ADataSourceIndex: Integer; const AColumnName, AErrorText: string);
    procedure DropCellError(const ADataSourceIndex: Integer; const AColumnName: string);
    procedure BeginRowEdit(const ARowIndex, ADataSourceIndex: Integer; const ARowObject: TValue); virtual;
    procedure MarkRowEditModified(const ADataSourceIndex: Integer); virtual;
    procedure RecordCellChange(const ADataSourceIndex: Integer; const AColumn: TThemedGridColumn;
      const AOldValue, ANewValue: TValue; const AChangeReason: string); virtual;
    procedure DoCellValidating(const AArgs: TThemedGridCellValidatingEventArgs); virtual;
    procedure DoCellValueChanging(const AArgs: TThemedGridCellValueChangingEventArgs); virtual;
    procedure DoCellValueChanged(const AArgs: TThemedGridCellValueChangedEventArgs); virtual;
    procedure DoCellEditCommitted(const AArgs: TThemedGridCellEditEventArgs); virtual;
    procedure DoCellEditCanceled(const AArgs: TThemedGridCellEditEventArgs); virtual;
    property EditorHost: TThemedGridEditorHost read FEditorHost;
    property EditorFactory: TThemedGridEditorFactory read FEditorFactory;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure BeginEditCurrentCell; override;
    function CommitEdit: Boolean; override;
    procedure CancelEdit;
    function TrySetCellValue(const ARowIndex, AColumnIndex: Integer; const ANewValue: TValue;
      const AChangeReason: string; const AInvalidateRow: Boolean; out AAppliedValue: TValue): Boolean;
    function GetValue(const ARowIndex, AColumnIndex: Integer): TValue; overload;
    function GetValue(const ARowIndex: Integer; const AColumnName: string): TValue; overload;
    procedure SetValue(const ARowIndex, AColumnIndex: Integer; const AValue: TValue); overload;
    procedure SetValue(const ARowIndex: Integer; const AColumnName: string; const AValue: TValue); overload;
    function GetCellError(const ARowIndex, AColumnIndex: Integer): string;
    procedure SetCellError(const ARowIndex, AColumnIndex: Integer; const AErrorText: string);
    procedure ClearCellError(const ARowIndex, AColumnIndex: Integer);
    property Editing: Boolean read GetEditing;
    property OnCellValidating: TThemedGridCellValidatingEvent read FOnCellValidating write FOnCellValidating;
    property OnCellValueChanging: TThemedGridCellValueChangingEvent read FOnCellValueChanging write FOnCellValueChanging;
    property OnCellValueChanged: TThemedGridCellValueChangedEvent read FOnCellValueChanged write FOnCellValueChanged;
    property OnCellEditCommitted: TThemedGridCellEditEvent read FOnCellEditCommitted write FOnCellEditCommitted;
    property OnCellEditCanceled: TThemedGridCellEditEvent read FOnCellEditCanceled write FOnCellEditCanceled;
  end;

implementation

uses
  System.Math,
  NimbusForms.Grid.ViewRow,
  NimbusForms.Grid.CellMetadata,
  NimbusForms.Grid.FilterDescriptor,
  NimbusForms.Grid.GroupDescriptor,
  NimbusForms.Grid.NumericRange,
  NimbusForms.Grid.InlineEditorGeometry,
  NimbusForms.Grid.ValueConverter,
  NimbusForms.Grid.ValueFormatter,
  NimbusForms.Grid.EditStrings,
  NimbusForms.Grid.EditorSupport;

type
  TStr = TThemedGridEditStrings;

constructor TThemedGridControlEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSliderRowIndex := -1;
  FSliderColumnIndex := -1;
  FEditorFactory := TThemedGridEditorFactory.Create;
  FEditorHost := TThemedGridEditorHost.Create(Self);
  FEditorHost.OnEditorKeyDown := EditorKeyDown;
  FEditorHost.OnEditLostFocus := EditorExit;
end;

destructor TThemedGridControlEdit.Destroy;
begin
  FEditorHost.Close;
  FreeAndNil(FEditorHost);
  FreeAndNil(FEditorFactory);
  inherited Destroy;
end;

function TThemedGridControlEdit.GetEditing: Boolean;
begin
  Result := IsEditing;
end;

function TThemedGridControlEdit.IsEditing: Boolean;
begin
  Result := (FEditorHost <> nil) and FEditorHost.IsEditing;
end;

procedure TThemedGridControlEdit.ApplyTheme(const APalette: TThemePalette);
begin
  inherited ApplyTheme(APalette);
  if (FEditorHost <> nil) and (FEditorHost.Editor <> nil) then
    FEditorHost.Editor.ApplyTheme(APalette);
end;

procedure TThemedGridControlEdit.DataSourceReset;
begin
  if FEditorHost <> nil then
    FEditorHost.Close;
  inherited DataSourceReset;
end;

procedure TThemedGridControlEdit.ColumnsStructureChanged;
begin
  if FEditorHost <> nil then
    FEditorHost.Close;
  inherited ColumnsStructureChanged;
end;

procedure TThemedGridControlEdit.Resize;
begin
  inherited Resize;
  UpdateEditorBounds;
end;

function TThemedGridControlEdit.ContainsFocusWindow: Boolean;
var
  LFocus: HWND;
begin
  Result := False;
  if not HandleAllocated then
    Exit;
  LFocus := GetFocus;
  Result := (LFocus <> 0) and ((LFocus = Handle) or IsChild(Handle, LFocus));
end;

procedure TThemedGridControlEdit.WMEditorCommit(var AMessage: TMessage);
begin
  if IsEditing and (Integer(AMessage.WParam) = FEditToken) then
    CommitEdit;
end;

procedure TThemedGridControlEdit.WMEditorCancel(var AMessage: TMessage);
begin
  if IsEditing and (Integer(AMessage.WParam) = FEditToken) then
    CancelEdit;
end;

procedure TThemedGridControlEdit.WMEditorLostFocus(var AMessage: TMessage);
begin
  if not IsEditing then
    Exit;
  if not EditOptions.CommitOnLeave then
    Exit;
  if Integer(AMessage.WParam) <> FEditToken then
    Exit;
  if ContainsFocusWindow then
    Exit;
  if FEditorHost.IsPopupOpen then
    Exit;
  CommitEdit;
end;

procedure TThemedGridControlEdit.EditorKeyDown(ASender: TObject; var AKey: Word; AShift: TShiftState);
begin
  if not HandleAllocated then
    Exit;
  if AKey = VK_RETURN then
  begin
    PostMessage(Handle, WM_GRID_EDITOR_COMMIT, WPARAM(FEditToken), 0);
    AKey := 0;
  end
  else if AKey = VK_ESCAPE then
  begin
    PostMessage(Handle, WM_GRID_EDITOR_CANCEL, WPARAM(FEditToken), 0);
    AKey := 0;
  end;
end;

procedure TThemedGridControlEdit.EditorExit(ASender: TObject);
begin
  if HandleAllocated and not (csDestroying in ComponentState) then
    PostMessage(Handle, WM_GRID_EDITOR_LOSTFOCUS, WPARAM(FEditToken), 0);
end;

function TThemedGridControlEdit.ResolveValueType(const AColumn: TThemedGridColumn): PTypeInfo;
begin
  Result := nil;
  if AColumn = nil then
    Exit;
  Result := AColumn.ValueType;
  if (Result = nil) and (DataController <> nil) then
    Result := DataController.GetValueType(AColumn);
end;

function TThemedGridControlEdit.CanEditColumn(const AColumn: TThemedGridColumn): Boolean;
begin
  Result := EditOptions.AllowEdit and (AColumn <> nil) and not AColumn.ReadOnly and
    (DataController <> nil) and DataController.CanSetValue(AColumn);
end;

function TThemedGridControlEdit.CreateEditContext(const ACell: TThemedGridCell): TThemedGridCellEditContext;
begin
  Result := TThemedGridCellEditContext.Create;
  Result.Grid := Self;
  Result.Cell := ACell;
  Result.Column := ACell.Column;
  Result.RowObject := ACell.RowObject;
  Result.Value := ACell.Value;
  Result.ValueType := ResolveValueType(ACell.Column);
  Result.Bounds := ACell.Bounds;
end;

procedure TThemedGridControlEdit.BeginEditCurrentCell;
var
  LViewRow: TThemedGridViewRow;
  LCell: TThemedGridCell;
  LEditor: IThemedGridCellEditor;
  LContext: TThemedGridCellEditContext;
begin
  if not EditOptions.AllowEdit then
    Exit;
  if (CurrentRowIndex < 0) or (CurrentColumnIndex < 0) then
    Exit;
  LViewRow := GetViewRow(CurrentRowIndex);
  if (LViewRow = nil) or not LViewRow.CanEditCells then
    Exit;
  LCell := GetCell(CurrentRowIndex, CurrentColumnIndex);
  if LCell = nil then
    Exit;
  if (LCell.Column = nil) or LCell.IsReadOnly or (DataController = nil) or
    not DataController.CanSetValue(LCell.Column) then
  begin
    LCell.Free;
    Exit;
  end;
  LEditor := FEditorFactory.CreateEditor(LCell);
  if LEditor = nil then
  begin
    LCell.Free;
    Exit;
  end;
  LContext := CreateEditContext(LCell);
  Inc(FEditToken);
  FEditorHost.BeginEdit(LEditor, LContext, Palette);
end;

procedure TThemedGridControlEdit.FinishEditorClose(const AHadFocus: Boolean);
begin
  Update;
  if AHadFocus and CanFocus and not (csDestroying in ComponentState) then
    SetFocus;
end;

function TThemedGridControlEdit.CommitEdit: Boolean;
var
  LContext: TThemedGridCellEditContext;
  LViewRow: TThemedGridViewRow;
  LEditorValue, LOldValue, LNewValue, LApplied: TValue;
  LDataSourceIndex, LRowIndex, LColumnIndex: Integer;
  LColumn: TThemedGridColumn;
  LRequiresFullRefresh, LHadFocus: Boolean;
  LArgs: TThemedGridCellEditEventArgs;
begin
  if not IsEditing then
    Exit(True);
  if FCommitting then
    Exit(True);
  if not EditOptions.AllowEdit then
  begin
    CancelEdit;
    Exit(True);
  end;
  FCommitting := True;
  try
    LContext := FEditorHost.Context;
    LHadFocus := FEditorHost.ControlHasFocus;
    if (LContext = nil) or (LContext.Cell = nil) or (LContext.Column = nil) then
    begin
      FEditorHost.Close;
      FinishEditorClose(LHadFocus);
      Exit(True);
    end;
    LViewRow := GetViewRow(LContext.Cell.RowIndex);
    if (LViewRow = nil) or not LViewRow.CanEditCells then
    begin
      FEditorHost.Close;
      FinishEditorClose(LHadFocus);
      Exit(True);
    end;
    if not FEditorHost.CommitEdit then
      Exit(False);

    LEditorValue := FEditorHost.GetValue;
    LDataSourceIndex := LViewRow.DataSourceIndex;
    LRowIndex := LContext.Cell.RowIndex;
    LColumnIndex := LContext.Cell.ColumnIndex;
    LColumn := LContext.Column;
    LOldValue := LContext.Value;
    LNewValue := ConvertEditorValue(LEditorValue, LContext.ValueType);
    LRequiresFullRefresh := IsColumnStructuralForCurrentView(LColumn);

    LContext := FEditorHost.TakeContext;
    try
      FinishEditorClose(LHadFocus);
      if (LDataSourceIndex < 0) or (DataController = nil) then
        Exit(True);
      if not TrySetCellValue(LRowIndex, LColumnIndex, LNewValue, TStr.ChangeReasonEditor,
        LRequiresFullRefresh, LApplied) then
        Exit(True);

      if LRequiresFullRefresh then
      begin
        DataController.Refresh;
        InvalidateRowView;
        ClearSummaryCache;
        Invalidate;
      end
      else
      begin
        ClearSummaryCache;
        InvalidateCell(LRowIndex, LColumnIndex);
      end;

      LArgs := TThemedGridCellEditEventArgs.Create;
      try
        FillCellEventArgs(LArgs, LContext.Cell);
        LArgs.Value := LApplied;
        LArgs.OldValue := LOldValue;
        LArgs.NewValue := LApplied;
        DoCellEditCommitted(LArgs);
      finally
        LArgs.Free;
      end;
    finally
      LContext.Free;
    end;
    Result := True;
  finally
    FCommitting := False;
  end;
end;

procedure TThemedGridControlEdit.CancelEdit;
var
  LContext: TThemedGridCellEditContext;
  LArgs: TThemedGridCellEditEventArgs;
  LHadFocus: Boolean;
begin
  if not IsEditing then
    Exit;
  LContext := FEditorHost.Context;
  LHadFocus := FEditorHost.ControlHasFocus;
  if (LContext <> nil) and (LContext.Cell <> nil) then
  begin
    LArgs := TThemedGridCellEditEventArgs.Create;
    try
      FillCellEventArgs(LArgs, LContext.Cell);
      LArgs.Value := LContext.Value;
      LArgs.OldValue := LContext.Value;
      LArgs.NewValue := LContext.Value;
      DoCellEditCanceled(LArgs);
    finally
      LArgs.Free;
    end;
  end;
  FEditorHost.CancelEdit;
  FinishEditorClose(LHadFocus);
  Invalidate;
end;

procedure TThemedGridControlEdit.UpdateEditorBounds;
var
  LContext: TThemedGridCellEditContext;
  LViewRow: TThemedGridViewRow;
begin
  if not IsEditing then
    Exit;
  LContext := FEditorHost.Context;
  if (LContext = nil) or (LContext.Cell = nil) then
    Exit;
  LViewRow := GetViewRow(LContext.Cell.RowIndex);
  if (LViewRow = nil) or not LViewRow.CanEditCells then
  begin
    FEditorHost.Close;
    Exit;
  end;
  FEditorHost.UpdateBounds(GetCellBounds(LContext.Cell.RowIndex, LContext.Cell.ColumnIndex));
end;

function TThemedGridControlEdit.ConvertEditorValue(const AValue: TValue; const ATargetType: PTypeInfo): TValue;
var
  LConverted: TValue;
begin
  if TThemedGridValueConverter.IsNull(AValue) then
    Exit(TValue.Empty);
  if ATargetType = nil then
    Exit(AValue);
  if AValue.TypeInfo = ATargetType then
    Exit(AValue);
  if TThemedGridValueConverter.TryConvert(AValue, ATargetType, LConverted) and (LConverted.TypeInfo <> nil) then
    Exit(LConverted);
  Result := AValue;
end;

function TThemedGridControlEdit.IsColumnStructuralForCurrentView(const AColumn: TThemedGridColumn): Boolean;
var
  LFilters: TArray<TThemedGridFilterDescriptor>;
  LFilter: TThemedGridFilterDescriptor;
  LGroup: TThemedGridGroupDescriptor;
  I: Integer;
begin
  if AColumn = nil then
    Exit(True);
  if DataController <> nil then
  begin
    if DataController.IsSorted and (DataController.SortColumn = AColumn) then
      Exit(True);
    if DataController.IsFiltered then
    begin
      LFilters := DataController.Filters;
      for I := 0 to High(LFilters) do
      begin
        LFilter := LFilters[I];
        if LFilter = nil then
          Continue;
        if LFilter.Column = AColumn then
          Exit(True);
        if (LFilter.ColumnName <> '') and SameText(LFilter.ColumnName, AColumn.Name) then
          Exit(True);
      end;
    end;
  end;
  if GroupingOptions.Enabled then
    for I := 0 to Groups.Count - 1 do
    begin
      LGroup := Groups[I];
      if LGroup = nil then
        Continue;
      if LGroup.Column = AColumn then
        Exit(True);
      if (LGroup.ColumnName <> '') and SameText(LGroup.ColumnName, AColumn.Name) then
        Exit(True);
    end;
  Result := False;
end;

procedure TThemedGridControlEdit.StoreCellError(const ADataSourceIndex: Integer; const AColumnName,
  AErrorText: string);
var
  LMetadata: TThemedGridCellMetadata;
begin
  if AColumnName = '' then
    Exit;
  LMetadata := GetMetadata(ADataSourceIndex, AColumnName, True);
  if AErrorText = '' then
    LMetadata.ErrorText := TStr.InvalidValue
  else
    LMetadata.ErrorText := AErrorText;
end;

procedure TThemedGridControlEdit.DropCellError(const ADataSourceIndex: Integer; const AColumnName: string);
var
  LMetadata: TThemedGridCellMetadata;
begin
  if AColumnName = '' then
    Exit;
  LMetadata := GetMetadata(ADataSourceIndex, AColumnName, False);
  if LMetadata <> nil then
    LMetadata.ErrorText := '';
end;

procedure TThemedGridControlEdit.BeginRowEdit(const ARowIndex, ADataSourceIndex: Integer; const ARowObject: TValue);
begin
end;

procedure TThemedGridControlEdit.MarkRowEditModified(const ADataSourceIndex: Integer);
begin
end;

procedure TThemedGridControlEdit.RecordCellChange(const ADataSourceIndex: Integer; const AColumn: TThemedGridColumn;
  const AOldValue, ANewValue: TValue; const AChangeReason: string);
begin
end;

procedure TThemedGridControlEdit.DoCellValidating(const AArgs: TThemedGridCellValidatingEventArgs);
begin
  if Assigned(FOnCellValidating) then
    FOnCellValidating(Self, AArgs);
end;

procedure TThemedGridControlEdit.DoCellValueChanging(const AArgs: TThemedGridCellValueChangingEventArgs);
begin
  if Assigned(FOnCellValueChanging) then
    FOnCellValueChanging(Self, AArgs);
end;

procedure TThemedGridControlEdit.DoCellValueChanged(const AArgs: TThemedGridCellValueChangedEventArgs);
begin
  if Assigned(FOnCellValueChanged) then
    FOnCellValueChanged(Self, AArgs);
end;

procedure TThemedGridControlEdit.DoCellEditCommitted(const AArgs: TThemedGridCellEditEventArgs);
begin
  if Assigned(FOnCellEditCommitted) then
    FOnCellEditCommitted(Self, AArgs);
end;

procedure TThemedGridControlEdit.DoCellEditCanceled(const AArgs: TThemedGridCellEditEventArgs);
begin
  if Assigned(FOnCellEditCanceled) then
    FOnCellEditCanceled(Self, AArgs);
end;

function TThemedGridControlEdit.TrySetCellValue(const ARowIndex, AColumnIndex: Integer; const ANewValue: TValue;
  const AChangeReason: string; const AInvalidateRow: Boolean; out AAppliedValue: TValue): Boolean;
var
  LColumn: TThemedGridColumn;
  LViewRow: TThemedGridViewRow;
  LCell, LChangedCell: TThemedGridCell;
  LDataSourceIndex: Integer;
  LOldValue, LNewValue: TValue;
  LValidating: TThemedGridCellValidatingEventArgs;
  LChanging: TThemedGridCellValueChangingEventArgs;
  LChanged: TThemedGridCellValueChangedEventArgs;
  LCancel, LOwnsChanged: Boolean;
  LErrorText: string;
begin
  AAppliedValue := ANewValue;
  Result := False;
  if DataController = nil then
    Exit;
  LColumn := GetColumn(AColumnIndex);
  if (LColumn = nil) or LColumn.ReadOnly then
    Exit;
  if not DataController.CanSetValue(LColumn) then
    Exit;
  LViewRow := GetViewRow(ARowIndex);
  if (LViewRow = nil) or not LViewRow.CanEditCells then
    Exit;
  LCell := GetCell(ARowIndex, AColumnIndex);
  if LCell = nil then
    Exit;
  try
    LDataSourceIndex := LCell.DataSourceIndex;
    if LCell.IsReadOnly then Exit;
    if LDataSourceIndex < 0 then
      Exit;

    BeginRowEdit(ARowIndex, LDataSourceIndex, LCell.RowObject);
    LOldValue := LCell.Value;
    LNewValue := ANewValue;

    LValidating := TThemedGridCellValidatingEventArgs.Create;
    try
      FillCellEventArgs(LValidating, LCell);
      LValidating.NewValue := LNewValue;
      DoCellValidating(LValidating);
      LCancel := LValidating.Cancel;
      LErrorText := LValidating.ErrorText;
      LNewValue := LValidating.NewValue;
    finally
      LValidating.Free;
    end;
    if LCancel then
    begin
      StoreCellError(LDataSourceIndex, LColumn.Name, LErrorText);
      InvalidateCell(ARowIndex, AColumnIndex);
      Exit;
    end;
    AAppliedValue := LNewValue;

    LChanging := TThemedGridCellValueChangingEventArgs.Create;
    try
      FillCellEventArgs(LChanging, LCell);
      LChanging.Value := LOldValue;
      LChanging.OldValue := LOldValue;
      LChanging.NewValue := LNewValue;
      LChanging.ChangeReason := AChangeReason;
      DoCellValueChanging(LChanging);
      LCancel := LChanging.Cancel;
      LErrorText := LChanging.ErrorText;
      LNewValue := LChanging.NewValue;
    finally
      LChanging.Free;
    end;
    if LCancel then
    begin
      StoreCellError(LDataSourceIndex, LColumn.Name, LErrorText);
      InvalidateCell(ARowIndex, AColumnIndex);
      Exit;
    end;
    AAppliedValue := LNewValue;

    if TThemedGridEditorSupport.ValuesEqual(LOldValue, LNewValue) then
    begin
      DropCellError(LDataSourceIndex, LColumn.Name);
      InvalidateCell(ARowIndex, AColumnIndex);
      Exit(True);
    end;

    DropCellError(LDataSourceIndex, LColumn.Name);
    DataController.SetValue(LDataSourceIndex, LColumn, LNewValue);

    LChangedCell := GetCell(ARowIndex, AColumnIndex);
    LOwnsChanged := LChangedCell <> nil;
    if not LOwnsChanged then
      LChangedCell := LCell;
    try
      AAppliedValue := LChangedCell.Value;
      MarkRowEditModified(LDataSourceIndex);
      RecordCellChange(LDataSourceIndex, LColumn, LOldValue, AAppliedValue, AChangeReason);

      LChanged := TThemedGridCellValueChangedEventArgs.Create;
      try
        FillCellEventArgs(LChanged, LChangedCell);
        LChanged.Value := AAppliedValue;
        LChanged.OldValue := LOldValue;
        LChanged.NewValue := AAppliedValue;
        LChanged.ChangeReason := AChangeReason;
        DoCellValueChanged(LChanged);
      finally
        LChanged.Free;
      end;
    finally
      if LOwnsChanged then
        LChangedCell.Free;
    end;

    CheckRowsChanged;

    if AInvalidateRow then
      InvalidateRow(ARowIndex)
    else
      InvalidateCell(ARowIndex, AColumnIndex);
    Result := True;
  finally
    LCell.Free;
  end;
end;

function TThemedGridControlEdit.GetValue(const ARowIndex, AColumnIndex: Integer): TValue;
var
  LCell: TThemedGridCell;
begin
  Result := TValue.Empty;
  LCell := GetCell(ARowIndex, AColumnIndex);
  if LCell = nil then
    Exit;
  try
    Result := LCell.Value;
  finally
    LCell.Free;
  end;
end;

function TThemedGridControlEdit.GetValue(const ARowIndex: Integer; const AColumnName: string): TValue;
var
  LColumn: TThemedGridColumn;
  LDataSourceIndex: Integer;
begin
  Result := TValue.Empty;
  if DataController = nil then
    Exit;
  LColumn := GetColumn(AColumnName);
  if LColumn = nil then
    Exit;
  LDataSourceIndex := GetViewRowDataSourceIndex(ARowIndex);
  if LDataSourceIndex < 0 then
    Exit;
  Result := DataController.GetValue(LDataSourceIndex, LColumn);
end;

procedure TThemedGridControlEdit.SetValue(const ARowIndex, AColumnIndex: Integer; const AValue: TValue);
var
  LApplied: TValue;
begin
  TrySetCellValue(ARowIndex, AColumnIndex, AValue, TStr.ChangeReasonSetValue, True, LApplied);
end;

procedure TThemedGridControlEdit.SetValue(const ARowIndex: Integer; const AColumnName: string;
  const AValue: TValue);
var
  LColumn: TThemedGridColumn;
  LColumnIndex: Integer;
begin
  if DataController = nil then
    Exit;
  LColumn := GetColumn(AColumnName);
  if LColumn = nil then
    Exit;
  LColumnIndex := GetColumnIndex(LColumn);
  if LColumnIndex < 0 then
    Exit;
  SetValue(ARowIndex, LColumnIndex, AValue);
end;

function TThemedGridControlEdit.GetCellError(const ARowIndex, AColumnIndex: Integer): string;
var
  LCell: TThemedGridCell;
  LMetadata: TThemedGridCellMetadata;
begin
  Result := '';
  LCell := GetCell(ARowIndex, AColumnIndex);
  if LCell = nil then
    Exit;
  try
    if LCell.Column = nil then
      Exit;
    LMetadata := GetMetadata(LCell.DataSourceIndex, LCell.Column.Name, False);
    if LMetadata <> nil then
      Result := LMetadata.ErrorText;
  finally
    LCell.Free;
  end;
end;

procedure TThemedGridControlEdit.SetCellError(const ARowIndex, AColumnIndex: Integer; const AErrorText: string);
var
  LCell: TThemedGridCell;
begin
  LCell := GetCell(ARowIndex, AColumnIndex);
  if LCell = nil then
    Exit;
  try
    if LCell.Column = nil then
      Exit;
    StoreCellError(LCell.DataSourceIndex, LCell.Column.Name, AErrorText);
  finally
    LCell.Free;
  end;
  InvalidateCell(ARowIndex, AColumnIndex);
end;

procedure TThemedGridControlEdit.ClearCellError(const ARowIndex, AColumnIndex: Integer);
var
  LCell: TThemedGridCell;
begin
  LCell := GetCell(ARowIndex, AColumnIndex);
  if LCell = nil then
    Exit;
  try
    if LCell.Column = nil then
      Exit;
    DropCellError(LCell.DataSourceIndex, LCell.Column.Name);
  finally
    LCell.Free;
  end;
  InvalidateCell(ARowIndex, AColumnIndex);
end;

function TThemedGridControlEdit.CanBeginEditFromHit(const AHit: TThemedGridHitInfo): Boolean;
var
  LInteractive: IThemedGridInteractiveCellEditor;
begin
  Result := False;
  if AHit = nil then
    Exit;
  if not (AHit.IsCell or (AHit.HitArea = TThemedGridHitArea.Editor)) then
    Exit;
  if not IsDataViewRow(AHit.RowIndex) then
    Exit;
  if not EditOptions.AllowEdit then
    Exit;
  if (AHit.Column = nil) or AHit.Column.ReadOnly then
    Exit;
  if (AHit.Column.Editor = nil) and (AHit.Column.EditorKind = TThemedGridEditorKind.None) then
    Exit;
  if not Supports(AHit.Column.Editor, IThemedGridInteractiveCellEditor, LInteractive) and
    TThemedGridEditorSupport.IsDirectInlineKind(AHit.Column.RenderKind) then
    Exit;
  if not Supports(AHit.Column.Editor, IThemedGridInteractiveCellEditor, LInteractive) and
    TThemedGridEditorSupport.IsCommandKind(AHit.Column.RenderKind) then
    Exit;
  Result := (DataController <> nil) and DataController.CanSetValue(AHit.Column);
end;

function TThemedGridControlEdit.CanBeginEditCurrentCell: Boolean;
var
  LInteractive: IThemedGridInteractiveCellEditor;
  LColumn: TThemedGridColumn;
  LViewRow: TThemedGridViewRow;
begin
  Result := False;
  if not EditOptions.AllowEdit then
    Exit;
  if (CurrentRowIndex < 0) or (CurrentColumnIndex < 0) then
    Exit;
  if not IsDataViewRow(CurrentRowIndex) then
    Exit;
  LColumn := GetColumn(CurrentColumnIndex);
  if (LColumn = nil) or LColumn.ReadOnly then
    Exit;
  if (LColumn.Editor = nil) and (LColumn.EditorKind = TThemedGridEditorKind.None) then
    Exit;
  if not Supports(LColumn.Editor, IThemedGridInteractiveCellEditor, LInteractive) and
    (TThemedGridEditorSupport.IsDirectInlineKind(LColumn.RenderKind) or
    TThemedGridEditorSupport.IsCommandKind(LColumn.RenderKind)) then
    Exit;
  if (DataController = nil) or not DataController.CanSetValue(LColumn) then
    Exit;
  LViewRow := GetViewRow(CurrentRowIndex);
  Result := (LViewRow <> nil) and LViewRow.CanEditCells;
end;

function TThemedGridControlEdit.HitTestDirectValueGlyph(const AHit: TThemedGridHitInfo;
  const ALocation: TPoint): Boolean;
var
  LBounds: TRect;
  LInteractive: IThemedGridInteractiveCellEditor;
begin
  Result := False;
  if (AHit = nil) or (AHit.Column = nil) then
    Exit;
  if (AHit.RowIndex < 0) or (AHit.ColumnIndex < 0) then
    Exit;
  LBounds := AHit.Bounds;
  if (LBounds.Width <= 0) or (LBounds.Height <= 0) then
    Exit;
  if Supports(AHit.Column.Editor, IThemedGridInteractiveCellEditor, LInteractive) then
    Exit(LInteractive.HitTest(LBounds, ALocation));
  case AHit.Column.RenderKind of
    TThemedGridCellRenderKind.CheckBox:
      Result := TThemedGridInlineEditorGeometry.HitTestCheckBox(LBounds, Metrics.CheckBoxSize, ALocation);
    TThemedGridCellRenderKind.Toggle:
      Result := TThemedGridInlineEditorGeometry.HitTestToggle(LBounds, ALocation);
    TThemedGridCellRenderKind.Rating:
      Result := TThemedGridInlineEditorGeometry.HitTestRating(LBounds,
        TThemedGridInlineEditorGeometry.ResolveRatingMaximum(AHit.Column), ALocation);
    TThemedGridCellRenderKind.Slider:
      Result := TThemedGridInlineEditorGeometry.HitTestSlider(LBounds, ALocation);
  end;
end;

function TThemedGridControlEdit.ToggleBooleanAt(const ARowIndex, AColumnIndex: Integer;
  const AReason: string): Boolean;
var
  LCurrent: Boolean;
  LApplied: TValue;
begin
  if not TThemedGridValueFormatter.TryGetBoolean(GetValue(ARowIndex, AColumnIndex), LCurrent) then
    LCurrent := False;
  Result := TrySetCellValue(ARowIndex, AColumnIndex, TValue.From<Boolean>(not LCurrent), AReason, False, LApplied);
end;

function TThemedGridControlEdit.TryHandleDirectCheckBoxClick(const AHit: TThemedGridHitInfo;
  const ALocation: TPoint): Boolean;
begin
  Result := False;
  if (AHit = nil) or (AHit.Column = nil) then
    Exit;
  if (AHit.RowIndex < 0) or (AHit.ColumnIndex < 0) then
    Exit;
  if AHit.Column.RenderKind <> TThemedGridCellRenderKind.CheckBox then
    Exit;
  if not TThemedGridInlineEditorGeometry.HitTestCheckBox(AHit.Bounds, Metrics.CheckBoxSize, ALocation) then
    Exit;
  Result := True;
  if not CanEditColumn(AHit.Column) then
    Exit;
  ToggleBooleanAt(AHit.RowIndex, AHit.ColumnIndex, TStr.ChangeReasonDirectCheckBox);
end;

function TThemedGridControlEdit.TryHandleDirectToggleClick(const AHit: TThemedGridHitInfo): Boolean;
begin
  Result := False;
  if (AHit = nil) or (AHit.Column = nil) then
    Exit;
  if (AHit.RowIndex < 0) or (AHit.ColumnIndex < 0) then
    Exit;
  if AHit.Column.RenderKind <> TThemedGridCellRenderKind.Toggle then
    Exit;
  Result := True;
  if not CanEditColumn(AHit.Column) then
    Exit;
  ToggleBooleanAt(AHit.RowIndex, AHit.ColumnIndex, TStr.ChangeReasonDirectToggle);
end;

function TThemedGridControlEdit.TryHandleDirectRatingClick(const AHit: TThemedGridHitInfo;
  const ALocation: TPoint): Boolean;
var
  LMaximum: Integer;
  LNewRating, LOldRating: Extended;
  LApplied: TValue;
begin
  Result := False;
  if (AHit = nil) or (AHit.Column = nil) then
    Exit;
  if (AHit.RowIndex < 0) or (AHit.ColumnIndex < 0) then
    Exit;
  if AHit.Column.RenderKind <> TThemedGridCellRenderKind.Rating then
    Exit;
  Result := True;
  if not CanEditColumn(AHit.Column) then
    Exit;
  if (AHit.Bounds.Width <= 0) or (AHit.Bounds.Height <= 0) then
    Exit;
  LMaximum := TThemedGridInlineEditorGeometry.ResolveRatingMaximum(AHit.Column);
  LNewRating := TThemedGridInlineEditorGeometry.GetRatingValueFromPoint(AHit.Bounds, LMaximum, ALocation);
  LOldRating := TThemedGridValueFormatter.ToDecimal(GetValue(AHit.RowIndex, AHit.ColumnIndex));
  if LOldRating = LNewRating then
    LNewRating := 0;
  TrySetCellValue(AHit.RowIndex, AHit.ColumnIndex,
    TThemedGridEditorSupport.ConvertNumber(LNewRating, ResolveValueType(AHit.Column)),
    TStr.ChangeReasonDirectRating, False, LApplied);
end;

function TThemedGridControlEdit.TryHandleDirectSliderClick(const AHit: TThemedGridHitInfo;
  const ALocation: TPoint; const ABeginDrag: Boolean): Boolean;
var
  LValueType: PTypeInfo;
  LRange: TThemedGridNumericRange;
  LCurrent, LApplied: TValue;
  LRatio, LDisplay, LStored: Extended;
begin
  Result := False;
  if (AHit = nil) or (AHit.Column = nil) then
    Exit;
  if (AHit.RowIndex < 0) or (AHit.ColumnIndex < 0) then
    Exit;
  if AHit.Column.RenderKind <> TThemedGridCellRenderKind.Slider then
    Exit;
  Result := True;
  if not CanEditColumn(AHit.Column) then
    Exit;
  if (AHit.Bounds.Width <= 0) or (AHit.Bounds.Height <= 0) then
    Exit;
  LValueType := ResolveValueType(AHit.Column);
  LRange := TThemedGridNumericRange.Resolve(AHit.Column, LValueType);
  LCurrent := GetValue(AHit.RowIndex, AHit.ColumnIndex);
  LRatio := TThemedGridInlineEditorGeometry.GetSliderRatioFromPoint(AHit.Bounds, ALocation);
  LDisplay := LRange.GetDisplayValueFromRatio(LRatio, LCurrent);
  LStored := LRange.ToStoredValue(LDisplay);
  TrySetCellValue(AHit.RowIndex, AHit.ColumnIndex, TThemedGridEditorSupport.ConvertNumber(LStored, LValueType),
    TStr.ChangeReasonDirectSlider, False, LApplied);
  if ABeginDrag then
  begin
    FSliderDragging := True;
    FSliderRowIndex := AHit.RowIndex;
    FSliderColumnIndex := AHit.ColumnIndex;
    MouseCapture := True;
  end;
end;

function TThemedGridControlEdit.TryHandleDirectValueClick(const AHit: TThemedGridHitInfo;
  const ALocation: TPoint): Boolean;
var
  LInteractive: IThemedGridInteractiveCellEditor;
begin
  if (AHit <> nil) and (AHit.Column <> nil) and
    Supports(AHit.Column.Editor, IThemedGridInteractiveCellEditor, LInteractive) then
  begin
    Result := True;
    if not CanBeginEditFromHit(AHit) then Exit;
    if IsEditing and not CommitEdit then Exit;
    BeginEditCurrentCell;
    if IsEditing and Supports(FEditorHost.Editor, IThemedGridInteractiveCellEditor, LInteractive) then
      LInteractive.Activate(ALocation);
    Exit;
  end;
  Result := TryHandleDirectCheckBoxClick(AHit, ALocation) or
    TryHandleDirectToggleClick(AHit) or
    TryHandleDirectRatingClick(AHit, ALocation) or
    TryHandleDirectSliderClick(AHit, ALocation, True);
end;

procedure TThemedGridControlEdit.UpdateSliderDrag(const ALocation: TPoint);
var
  LHit, LFallback: TThemedGridHitInfo;
begin
  LHit := HitTest(ALocation);
  try
    if (LHit <> nil) and (LHit.RowIndex = FSliderRowIndex) and (LHit.ColumnIndex = FSliderColumnIndex) then
      TryHandleDirectSliderClick(LHit, ALocation, False)
    else
    begin
      LFallback := TThemedGridHitInfo.Create;
      try
        LFallback.HitArea := TThemedGridHitArea.Cell;
        LFallback.RowIndex := FSliderRowIndex;
        LFallback.ColumnIndex := FSliderColumnIndex;
        LFallback.Column := GetColumn(FSliderColumnIndex);
        LFallback.Bounds := GetCellBounds(FSliderRowIndex, FSliderColumnIndex);
        LFallback.Location := ALocation;
        TryHandleDirectSliderClick(LFallback, ALocation, False);
      finally
        LFallback.Free;
      end;
    end;
  finally
    LHit.Free;
  end;
end;

procedure TThemedGridControlEdit.EndSliderDrag;
begin
  FSliderDragging := False;
  FSliderRowIndex := -1;
  FSliderColumnIndex := -1;
  if MouseCapture then
    MouseCapture := False;
end;

procedure TThemedGridControlEdit.MouseMove(AShift: TShiftState; AX, AY: Integer);
begin
  if FSliderDragging then
  begin
    UpdateSliderDrag(Point(AX, AY));
    Exit;
  end;
  inherited MouseMove(AShift, AX, AY);
end;

procedure TThemedGridControlEdit.MouseUp(AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer);
begin
  if FSliderDragging then
    EndSliderDrag;
  inherited MouseUp(AButton, AShift, AX, AY);
end;

function TThemedGridControlEdit.ResolveCellCursor(const AHit: TThemedGridHitInfo; const ALocation: TPoint): TCursor;
begin
  Result := crDefault;
  if AHit = nil then
    Exit;
  if AHit.HitArea = TThemedGridHitArea.Editor then
    Exit(crHandPoint);
  if (AHit.Column <> nil) and TThemedGridEditorSupport.IsDirectInlineKind(AHit.Column.RenderKind) and
    EditOptions.AllowEdit and not AHit.Column.ReadOnly and HitTestDirectValueGlyph(AHit, ALocation) then
    Result := crHandPoint;
end;

function TThemedGridControlEdit.ToggleCurrentCellBooleanValue: Boolean;
var
  LColumn: TThemedGridColumn;
begin
  Result := False;
  if not EditOptions.AllowEdit then
    Exit;
  if (CurrentRowIndex < 0) or (CurrentColumnIndex < 0) then
    Exit;
  if not IsDataViewRow(CurrentRowIndex) then
    Exit;
  LColumn := GetColumn(CurrentColumnIndex);
  if (LColumn = nil) or LColumn.ReadOnly then
    Exit;
  if not (LColumn.RenderKind in [TThemedGridCellRenderKind.CheckBox, TThemedGridCellRenderKind.Toggle]) then
    Exit;
  if (DataController = nil) or not DataController.CanSetValue(LColumn) then
    Exit;
  Result := ToggleBooleanAt(CurrentRowIndex, CurrentColumnIndex, TStr.ChangeReasonDirectCheckBox);
end;

function TThemedGridControlEdit.TryStepCurrentCellValue(const ADirection: Integer): Boolean;
var
  LColumn: TThemedGridColumn;
  LValueType: PTypeInfo;
  LCurrent, LApplied: TValue;
  LMaximum: Integer;
  LRating: Extended;
  LRange: TThemedGridNumericRange;
  LDisplay, LMinimum, LMaximumDisplay: Extended;
begin
  Result := False;
  if (not EditOptions.AllowEdit) or (ADirection = 0) then
    Exit;
  if (CurrentRowIndex < 0) or (CurrentColumnIndex < 0) then
    Exit;
  if not IsDataViewRow(CurrentRowIndex) then
    Exit;
  LColumn := GetColumn(CurrentColumnIndex);
  if (LColumn = nil) or LColumn.ReadOnly then
    Exit;
  if not (LColumn.RenderKind in [TThemedGridCellRenderKind.Rating, TThemedGridCellRenderKind.Slider,
    TThemedGridCellRenderKind.ProgressBar]) then
    Exit;
  if (DataController = nil) or not DataController.CanSetValue(LColumn) then
    Exit;
  LValueType := ResolveValueType(LColumn);
  LCurrent := GetValue(CurrentRowIndex, CurrentColumnIndex);

  if LColumn.RenderKind = TThemedGridCellRenderKind.Rating then
  begin
    LMaximum := TThemedGridInlineEditorGeometry.ResolveRatingMaximum(LColumn);
    LRating := TThemedGridValueFormatter.ToDecimal(LCurrent) + ADirection;
    if LRating < 0 then
      LRating := 0;
    if LRating > LMaximum then
      LRating := LMaximum;
    Exit(TrySetCellValue(CurrentRowIndex, CurrentColumnIndex,
      TThemedGridEditorSupport.ConvertNumber(LRating, LValueType),
      TStr.ChangeReasonDirectRating, False, LApplied));
  end;

  LRange := TThemedGridNumericRange.Resolve(LColumn, LValueType);
  LDisplay := LRange.ToDisplayValue(LCurrent) + LRange.Increment * ADirection;
  LDisplay := LRange.ClampDisplayValue(LRange.RoundDisplayValue(LDisplay));
  LMinimum := LRange.GetEffectiveMinimum;
  LMaximumDisplay := LRange.GetEffectiveMaximum(LCurrent);
  if LDisplay < LMinimum then
    LDisplay := LMinimum;
  if LDisplay > LMaximumDisplay then
    LDisplay := LMaximumDisplay;
  Result := TrySetCellValue(CurrentRowIndex, CurrentColumnIndex,
    TThemedGridEditorSupport.ConvertNumber(LRange.ToStoredValue(LDisplay), LValueType),
    TStr.ChangeReasonDirectSlider, False, LApplied);
end;

function TThemedGridControlEdit.TryHandleExtendedKey(var AKey: Word; const AShift: TShiftState): Boolean;
begin
  Result := False;
  if IsEditing then
  begin
    if AKey = VK_RETURN then
    begin
      CommitEdit;
      if CanFocus and not Focused then
        SetFocus;
      Exit(True);
    end;
    if AKey = VK_ESCAPE then
    begin
      CancelEdit;
      if CanFocus and not Focused then
        SetFocus;
      Exit(True);
    end;
    Exit;
  end;
  if (AShift = []) and (AKey = VK_SPACE) and ToggleCurrentCellBooleanValue then
    Exit(True);
  Result := inherited TryHandleExtendedKey(AKey, AShift);
end;

end.

unit NimbusForms.Grid.ControlClipboard;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  System.Rtti,
  System.TypInfo,
  System.Generics.Collections,
  NimbusForms.Grid.Primitives,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.Cell,
  NimbusForms.Grid.Events.Paste,
  NimbusForms.Grid.ClipboardParser,
  NimbusForms.Grid.ControlRows;

type
  TThemedGridControlClipboard = class(TThemedGridControlRows)
  private
    FOnPasteExecuting: TThemedGridPasteEvent;
    FOnPasteExecuted: TThemedGridPasteCompletedEvent;
    function GetCanPaste: Boolean;
    function ApplyPasteValue(const ARowIndex, AColumnIndex: Integer; const AColumn: TThemedGridColumn;
      const ASourceText: string): Boolean;
    function ConvertPasteText(const ASourceText: string; const AValueType: PTypeInfo;
      const AColumn: TThemedGridColumn): TValue;
    class function TryGetClipboardText: string; static;
    class procedure SetClipboardText(const AText: string); static;
  protected
    function GetClipboardText(const ACell: TThemedGridCell): string;
    function EscapeClipboardValue(const AValue: string): string;
    function BuildRowClipboardText(const ARowIndex: Integer): string;
    function TryHandleExtendedKey(var AKey: Word; const AShift: TShiftState): Boolean; override;
    procedure ApplyValueBlock(const ABlock: TThemedGridClipboardBlock; const AAnchorRowIndex,
      AAnchorColumnIndex, ABlockRowCount, ABlockColumnCount: Integer; const AFillSelection: Boolean;
      const AChangeReason, AUndoName: string; const AWrittenCells: TList<TThemedGridCellKey>;
      out AAppliedCellCount, ASkippedCellCount: Integer);
    procedure DoPasteExecuting(const AArgs: TThemedGridPasteEventArgs); virtual;
    procedure DoPasteExecuted(const AArgs: TThemedGridPasteCompletedEventArgs); virtual;
  public
    procedure CopySelectedToClipboard;
    procedure CopyCurrentCellToClipboard;
    procedure CopyCurrentRowToClipboard;
    procedure CopyRowToClipboard(const ARowIndex: Integer; const AIncludeHeaders: Boolean);
    procedure CopyRangeToClipboard(const ARow1, AColumn1, ARow2, AColumn2: Integer; const AIncludeHeaders: Boolean);
    function PasteFromClipboard: Boolean;
    property CanPaste: Boolean read GetCanPaste;
    property OnPasteExecuting: TThemedGridPasteEvent read FOnPasteExecuting write FOnPasteExecuting;
    property OnPasteExecuted: TThemedGridPasteCompletedEvent read FOnPasteExecuted write FOnPasteExecuted;
  end;

implementation

uses
  System.Math,
  Vcl.Clipbrd,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.ViewRow,
  NimbusForms.Grid.NumericRange,
  NimbusForms.Grid.ValueConverter,
  NimbusForms.Grid.ValueFormatter,
  NimbusForms.Grid.EditStrings,
  NimbusForms.Grid.UndoStrings;

type
  TEStr = TThemedGridEditStrings;
  TUStr = TThemedGridUndoStrings;

class function TThemedGridControlClipboard.TryGetClipboardText: string;
begin
  Result := '';
  try
    if Clipboard.HasFormat(CF_UNICODETEXT) or Clipboard.HasFormat(CF_TEXT) then
      Result := Clipboard.AsText;
  except
    Result := '';
  end;
end;

class procedure TThemedGridControlClipboard.SetClipboardText(const AText: string);
begin
  Clipboard.AsText := AText;
end;

function TThemedGridControlClipboard.GetCanPaste: Boolean;
begin
  Result := False;
  if not EditOptions.AllowEdit or not ClipboardOptions.AllowPaste then
    Exit;
  if DataController = nil then
    Exit;
  if GetVisibleColumns.Count = 0 then
    Exit;
  if (CurrentRowIndex < 0) or (CurrentColumnIndex < 0) then
    Exit;
  Result := TryGetClipboardText <> '';
end;

function TThemedGridControlClipboard.GetClipboardText(const ACell: TThemedGridCell): string;
begin
  if ACell = nil then
    Exit(ClipboardOptions.NullText);
  if ACell.DisplayText <> '' then
    Exit(ACell.DisplayText);
  if not TThemedGridValueConverter.IsNull(ACell.Value) then
    Exit(ACell.Value.ToString);
  Result := ClipboardOptions.NullText;
end;

function TThemedGridControlClipboard.EscapeClipboardValue(const AValue: string): string;
begin
  Result := StringReplace(AValue, #13, ' ', [rfReplaceAll]);
  Result := StringReplace(Result, #10, ' ', [rfReplaceAll]);
  Result := StringReplace(Result, #9, ' ', [rfReplaceAll]);
end;

function TThemedGridControlClipboard.BuildRowClipboardText(const ARowIndex: Integer): string;
var
  LColumns: TList<TThemedGridColumn>;
  LValues: TArray<string>;
  LViewRow: TThemedGridViewRow;
  LCell: TThemedGridCell;
  LColumnIndex: Integer;
begin
  Result := '';
  LColumns := GetVisibleColumns;
  SetLength(LValues, LColumns.Count);
  LViewRow := GetViewRow(ARowIndex);

  if (LViewRow <> nil) and (LViewRow.Kind = TThemedGridViewRowKind.GroupHeader) then
  begin
    for LColumnIndex := 0 to LColumns.Count - 1 do
      if LColumnIndex = 0 then
        LValues[LColumnIndex] := EscapeClipboardValue(LViewRow.DisplayText)
      else
        LValues[LColumnIndex] := '';
    Exit(string.Join(ClipboardOptions.ColumnSeparator, LValues));
  end;

  if (LViewRow = nil) or not LViewRow.IsDataRow then
    Exit;

  for LColumnIndex := 0 to LColumns.Count - 1 do
  begin
    LCell := GetCell(ARowIndex, LColumnIndex);
    try
      LValues[LColumnIndex] := EscapeClipboardValue(GetClipboardText(LCell));
    finally
      LCell.Free;
    end;
  end;
  Result := string.Join(ClipboardOptions.ColumnSeparator, LValues);
end;

procedure TThemedGridControlClipboard.CopySelectedToClipboard;
var
  LRange: TThemedGridCellRange;
begin
  LRange := SelectionModel.PrimaryRange;
  if LRange.IsValid and ((LRange.RowCount > 1) or (LRange.ColumnCount > 1)) then
  begin
    CopyRangeToClipboard(LRange.Row1, LRange.Column1, LRange.Row2, LRange.Column2, ClipboardOptions.IncludeHeaders);
    Exit;
  end;

  if (CurrentRowIndex >= 0) and
    ((SelectionMode = TThemedGridSelectionMode.Row) or (SelectionMode = TThemedGridSelectionMode.RowRange) or
     SelectionModel.IsRowSelected(CurrentRowIndex) or IsGroupViewRow(CurrentRowIndex)) then
  begin
    CopyCurrentRowToClipboard;
    Exit;
  end;

  CopyCurrentCellToClipboard;
end;

procedure TThemedGridControlClipboard.CopyCurrentCellToClipboard;
var
  LCell: TThemedGridCell;
  LText: string;
begin
  if (CurrentRowIndex >= 0) and IsGroupViewRow(CurrentRowIndex) then
  begin
    CopyCurrentRowToClipboard;
    Exit;
  end;

  LCell := GetCurrentCell;
  if LCell = nil then
    Exit;
  try
    LText := LCell.DisplayText;
    if (LText = '') and not TThemedGridValueConverter.IsNull(LCell.Value) then
      LText := LCell.Value.ToString;
  finally
    LCell.Free;
  end;
  SetClipboardText(LText);
end;

procedure TThemedGridControlClipboard.CopyCurrentRowToClipboard;
begin
  if CurrentRowIndex < 0 then
    Exit;
  CopyRowToClipboard(CurrentRowIndex, False);
end;

procedure TThemedGridControlClipboard.CopyRowToClipboard(const ARowIndex: Integer; const AIncludeHeaders: Boolean);
var
  LColumns: TList<TThemedGridColumn>;
  LValues: TArray<string>;
  I: Integer;
begin
  if (ARowIndex < 0) or (ARowIndex >= RowCount) then
    Exit;
  if AIncludeHeaders then
  begin
    LColumns := GetVisibleColumns;
    SetLength(LValues, LColumns.Count);
    for I := 0 to LColumns.Count - 1 do
      LValues[I] := EscapeClipboardValue(LColumns[I].GetBestHeaderText);
    SetClipboardText(string.Join(ClipboardOptions.ColumnSeparator, LValues) + ClipboardOptions.RowSeparator +
      BuildRowClipboardText(ARowIndex));
    Exit;
  end;
  SetClipboardText(BuildRowClipboardText(ARowIndex));
end;

procedure TThemedGridControlClipboard.CopyRangeToClipboard(const ARow1, AColumn1, ARow2, AColumn2: Integer;
  const AIncludeHeaders: Boolean);
var
  LColumns: TList<TThemedGridColumn>;
  LLines: TList<string>;
  LValues: TArray<string>;
  LViewRow: TThemedGridViewRow;
  LCell: TThemedGridCell;
  LMinRow, LMaxRow, LMinColumn, LMaxColumn, LRowIndex, LColumnIndex, LValueIndex: Integer;
  LText: string;
begin
  if RowCount <= 0 then
    Exit;
  LMinRow := Min(ARow1, ARow2);
  LMaxRow := Max(ARow1, ARow2);
  LMinColumn := Min(AColumn1, AColumn2);
  LMaxColumn := Max(AColumn1, AColumn2);
  if LMinRow < 0 then
    LMinRow := 0;
  if LMaxRow >= RowCount then
    LMaxRow := RowCount - 1;

  LColumns := GetVisibleColumns;
  if LColumns.Count = 0 then
    Exit;
  if LMinColumn < 0 then
    LMinColumn := 0;
  if LMaxColumn >= LColumns.Count then
    LMaxColumn := LColumns.Count - 1;

  LLines := TList<string>.Create;
  try
    SetLength(LValues, LMaxColumn - LMinColumn + 1);

    if AIncludeHeaders then
    begin
      for LColumnIndex := LMinColumn to LMaxColumn do
        LValues[LColumnIndex - LMinColumn] := EscapeClipboardValue(LColumns[LColumnIndex].GetBestHeaderText);
      LLines.Add(string.Join(ClipboardOptions.ColumnSeparator, LValues));
    end;

    for LRowIndex := LMinRow to LMaxRow do
    begin
      LViewRow := GetViewRow(LRowIndex);
      if LViewRow = nil then
        Continue;

      if LViewRow.Kind = TThemedGridViewRowKind.GroupHeader then
      begin
        for LColumnIndex := LMinColumn to LMaxColumn do
        begin
          if LColumnIndex = LMinColumn then
            LText := LViewRow.DisplayText
          else
            LText := '';
          LValues[LColumnIndex - LMinColumn] := EscapeClipboardValue(LText);
        end;
        LLines.Add(string.Join(ClipboardOptions.ColumnSeparator, LValues));
        Continue;
      end;

      if not LViewRow.IsDataRow then
        Continue;

      for LColumnIndex := LMinColumn to LMaxColumn do
      begin
        LValueIndex := LColumnIndex - LMinColumn;
        LCell := GetCell(LRowIndex, LColumnIndex);
        try
          LValues[LValueIndex] := EscapeClipboardValue(GetClipboardText(LCell));
        finally
          LCell.Free;
        end;
      end;
      LLines.Add(string.Join(ClipboardOptions.ColumnSeparator, LValues));
    end;

    if LLines.Count > 0 then
      SetClipboardText(string.Join(ClipboardOptions.RowSeparator, LLines.ToArray));
  finally
    LLines.Free;
  end;
end;

procedure TThemedGridControlClipboard.DoPasteExecuting(const AArgs: TThemedGridPasteEventArgs);
begin
  if Assigned(FOnPasteExecuting) then
    FOnPasteExecuting(Self, AArgs);
end;

procedure TThemedGridControlClipboard.DoPasteExecuted(const AArgs: TThemedGridPasteCompletedEventArgs);
begin
  if Assigned(FOnPasteExecuted) then
    FOnPasteExecuted(Self, AArgs);
end;

function TThemedGridControlClipboard.ConvertPasteText(const ASourceText: string; const AValueType: PTypeInfo;
  const AColumn: TThemedGridColumn): TValue;
var
  LText: string;
  LBoolean: Boolean;
  LRange: TThemedGridNumericRange;
  LDisplay: Extended;
begin
  LText := Trim(ASourceText);
  if LText = '' then
    Exit(TValue.Empty);

  if AValueType = TypeInfo(Boolean) then
  begin
    if TThemedGridValueFormatter.TryGetBoolean(TValue.From<string>(LText), LBoolean) then
      Exit(TValue.From<Boolean>(LBoolean));
    Exit(TValue.Empty);
  end;

  if TThemedGridNumericRange.IsNumericType(AValueType) and (AValueType <> TypeInfo(TDateTime)) then
  begin
    LRange := TThemedGridNumericRange.Resolve(AColumn, AValueType);
    if not LRange.TryParseDisplayValue(LText, LDisplay) then
      Exit(TValue.Empty);
    LDisplay := LRange.ClampDisplayValue(LRange.RoundDisplayValue(LDisplay));
    Exit(LRange.ConvertToValueType(LRange.ToStoredValue(LDisplay)));
  end;

  Result := ConvertEditorValue(TValue.From<string>(LText), AValueType);
end;

function TThemedGridControlClipboard.ApplyPasteValue(const ARowIndex, AColumnIndex: Integer;
  const AColumn: TThemedGridColumn; const ASourceText: string): Boolean;
var
  LValueType: PTypeInfo;
  LValue, LApplied: TValue;
begin
  Result := False;
  if (AColumn = nil) or AColumn.ReadOnly then
    Exit;
  if (DataController = nil) or not DataController.CanSetValue(AColumn) then
    Exit;
  if IsCommandRenderColumn(AColumn) then
    Exit;
  LValueType := ResolveValueType(AColumn);
  LValue := ConvertPasteText(ASourceText, LValueType, AColumn);
  Result := TrySetCellValue(ARowIndex, AColumnIndex, LValue, TEStr.ChangeReasonPaste, False, LApplied);
end;

procedure TThemedGridControlClipboard.ApplyValueBlock(const ABlock: TThemedGridClipboardBlock;
  const AAnchorRowIndex, AAnchorColumnIndex, ABlockRowCount, ABlockColumnCount: Integer;
  const AFillSelection: Boolean; const AChangeReason, AUndoName: string;
  const AWrittenCells: TList<TThemedGridCellKey>; out AAppliedCellCount, ASkippedCellCount: Integer);
var
  LColumns: TList<TThemedGridColumn>;
  LRowIndex, LRowCount, LBlockRow, LBlockColumn, LColumnIndex, LDataSourceIndex: Integer;
  LSourceRow: TArray<string>;
  LHasSourceRow, LHasText: Boolean;
  LSourceText: string;
  LColumn: TThemedGridColumn;
begin
  AAppliedCellCount := 0;
  ASkippedCellCount := 0;
  if Length(ABlock) = 0 then
    Exit;
  LColumns := GetVisibleColumns;
  if LColumns.Count = 0 then
    Exit;
  if IsEditing then
    CommitEdit;

  LRowCount := RowCount;

  UndoManager.BeginTransaction(AUndoName);
  BeginUpdate;
  try
    LRowIndex := AAnchorRowIndex;
    for LBlockRow := 0 to ABlockRowCount - 1 do
    begin
      if LRowIndex < 0 then
      begin
        Inc(ASkippedCellCount, ABlockColumnCount);
        Continue;
      end;

      LHasSourceRow := False;
      if AFillSelection then
      begin
        LSourceRow := ABlock[0];
        LHasSourceRow := True;
      end
      else if LBlockRow < Length(ABlock) then
      begin
        LSourceRow := ABlock[LBlockRow];
        LHasSourceRow := True;
      end;

      for LBlockColumn := 0 to ABlockColumnCount - 1 do
      begin
        LColumnIndex := AAnchorColumnIndex + LBlockColumn;
        if LColumnIndex >= LColumns.Count then
        begin
          Inc(ASkippedCellCount);
          Continue;
        end;

        LHasText := False;
        LSourceText := '';
        if LHasSourceRow then
        begin
          if AFillSelection then
          begin
            if Length(LSourceRow) > 0 then
            begin
              LSourceText := LSourceRow[0];
              LHasText := True;
            end;
          end
          else if LBlockColumn < Length(LSourceRow) then
          begin
            LSourceText := LSourceRow[LBlockColumn];
            LHasText := True;
          end;
        end;

        if not LHasText then
        begin
          Inc(ASkippedCellCount);
          Continue;
        end;

        LColumn := LColumns[LColumnIndex];
        if ApplyPasteValue(LRowIndex, LColumnIndex, LColumn, LSourceText) then
        begin
          Inc(AAppliedCellCount);
          if AWrittenCells <> nil then
          begin
            LDataSourceIndex := GetViewRowDataSourceIndex(LRowIndex);
            if LDataSourceIndex >= 0 then
              AWrittenCells.Add(TThemedGridCellKey.Create(LDataSourceIndex, LColumn.Name));
          end;
        end
        else
          Inc(ASkippedCellCount);
      end;

      if LRowIndex + 1 < LRowCount then
        LRowIndex := FindDataViewRow(LRowIndex + 1, 1)
      else
        LRowIndex := -1;
    end;
  finally
    EndUpdate;
    UndoManager.EndTransaction;
  end;
end;

function TThemedGridControlClipboard.PasteFromClipboard: Boolean;
var
  LColumns: TList<TThemedGridColumn>;
  LText: string;
  LBlock: TThemedGridClipboardBlock;
  LRange: TThemedGridCellRange;
  LAnchorRow, LAnchorColumn, LSelectionRows, LSelectionColumns, LBlockRows, LBlockColumns: Integer;
  LApplied, LSkipped: Integer;
  LFillSelection, LCancel: Boolean;
  LExecuting: TThemedGridPasteEventArgs;
  LCompleted: TThemedGridPasteCompletedEventArgs;
begin
  Result := False;
  if not EditOptions.AllowEdit or not ClipboardOptions.AllowPaste then
    Exit;
  if DataController = nil then
    Exit;
  LColumns := GetVisibleColumns;
  if LColumns.Count = 0 then
    Exit;

  LText := TryGetClipboardText;
  if LText = '' then
    Exit;

  LBlock := TThemedGridClipboardParser.Parse(LText, ClipboardOptions.ColumnSeparator, ClipboardOptions.RowSeparator);
  if Length(LBlock) = 0 then
    Exit;

  LAnchorRow := CurrentRowIndex;
  LAnchorColumn := CurrentColumnIndex;
  LFillSelection := False;
  LSelectionRows := 0;
  LSelectionColumns := 0;

  LRange := SelectionModel.PrimaryRange;
  if LRange.IsValid then
  begin
    LAnchorRow := Min(LRange.Row1, LRange.Row2);
    LAnchorColumn := Min(LRange.Column1, LRange.Column2);
    LSelectionRows := LRange.RowCount;
    LSelectionColumns := LRange.ColumnCount;
    LFillSelection := ClipboardOptions.PasteFillsSelection and (Length(LBlock) = 1) and (Length(LBlock[0]) = 1) and
      ((LSelectionRows > 1) or (LSelectionColumns > 1));
  end;

  LAnchorRow := NormalizeCellRowIndex(LAnchorRow, 1);
  if (LAnchorRow < 0) or (LAnchorColumn < 0) then
    Exit;
  if LAnchorColumn >= LColumns.Count then
    Exit;

  if LFillSelection then
  begin
    LBlockRows := LSelectionRows;
    LBlockColumns := LSelectionColumns;
  end
  else
  begin
    LBlockRows := Length(LBlock);
    LBlockColumns := TThemedGridClipboardParser.GetMaxColumnCount(LBlock);
  end;
  if (LBlockRows <= 0) or (LBlockColumns <= 0) then
    Exit;

  LExecuting := TThemedGridPasteEventArgs.Create;
  try
    LExecuting.RowIndex := LAnchorRow;
    LExecuting.ColumnIndex := LAnchorColumn;
    LExecuting.RowCount := LBlockRows;
    LExecuting.ColumnCount := LBlockColumns;
    LExecuting.Text := LText;
    DoPasteExecuting(LExecuting);
    LCancel := LExecuting.Cancel;
  finally
    LExecuting.Free;
  end;
  if LCancel then
    Exit;

  ApplyValueBlock(LBlock, LAnchorRow, LAnchorColumn, LBlockRows, LBlockColumns, LFillSelection,
    TEStr.ChangeReasonPaste, TUStr.UnitNamePaste, nil, LApplied, LSkipped);

  LCompleted := TThemedGridPasteCompletedEventArgs.Create;
  try
    LCompleted.RowIndex := LAnchorRow;
    LCompleted.ColumnIndex := LAnchorColumn;
    LCompleted.AppliedCellCount := LApplied;
    LCompleted.SkippedCellCount := LSkipped;
    DoPasteExecuted(LCompleted);
  finally
    LCompleted.Free;
  end;

  Result := LApplied > 0;
end;

function TThemedGridControlClipboard.TryHandleExtendedKey(var AKey: Word; const AShift: TShiftState): Boolean;
begin
  if (ssCtrl in AShift) and (AKey = Ord('C')) then
  begin
    CopySelectedToClipboard;
    Exit(True);
  end;
  if (ssCtrl in AShift) and (AKey = Ord('V')) and not IsEditing then
  begin
    PasteFromClipboard;
    Exit(True);
  end;
  Result := inherited TryHandleExtendedKey(AKey, AShift);
end;

end.

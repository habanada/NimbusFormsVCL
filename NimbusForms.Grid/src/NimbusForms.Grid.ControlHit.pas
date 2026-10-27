unit NimbusForms.Grid.ControlHit;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  System.Classes,
  System.Rtti,
  System.TypInfo,
  System.SysUtils,
  System.Types,
  System.Math,
  Vcl.Controls,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Primitives,
  NimbusForms.Grid.Cell,
  NimbusForms.Grid.ViewRow,
  NimbusForms.Grid.HitInfo,
  NimbusForms.Grid.Events,
  NimbusForms.Grid.ControlPaint;

type
  TThemedGridControlHit = class(TThemedGridControlPaint)
  private
    FOnCurrentCellChanged: TThemedGridCurrentCellChangedEvent;
    function GetFocusedRowIndex: Integer;
    function GetFocusedColumnIndex: Integer;
    function FillRowKindHit(const AHit: TThemedGridHitInfo; const ARowIndex: Integer;
      const AViewRow: TThemedGridViewRow; const ABounds: TRect): Boolean;
    function GetDetailParentDataSourceIndexForRow(const ARowIndex: Integer): Integer;
  protected
    function FindDataViewRow(const AStartRowIndex, ADirection: Integer): Integer;
    function FindDataViewRowByDataSourceIndex(const ADataSourceIndex: Integer): Integer;
    function NormalizeCellRowIndex(const ARowIndex, ADirection: Integer): Integer;
    function SelectDetailParentRow(const ADetailRowIndex: Integer): Boolean;
    procedure InvalidateBounds(const ABounds: TRect);
    function CaptureCurrentCell: TThemedGridCell;
    procedure NotifyCurrentCellChanged(const AOldCell: TThemedGridCell);
    procedure DoCurrentCellChanged(const AOldCell, ANewCell: TThemedGridCell); virtual;
    procedure ApplyMouseCellSelection(const ARowIndex, AColumnIndex: Integer; const AShift, AControl: Boolean);
    procedure ApplyMouseRowSelection(const ARowIndex: Integer; const AShift, AControl: Boolean);
    function TryToggleGroupRow(const ARowIndex: Integer; const ALocation: TPoint): Boolean;
    function IsEditing: Boolean; virtual;
    procedure UpdateEditorBounds; virtual;
    function CommitEdit: Boolean; virtual;
    function EndRowEditForRow(const ARowIndex: Integer): Boolean; virtual;
    function HasEmbeddedDetailGrids: Boolean; virtual;
    procedure RemoveEmbeddedDetailGridByDataSourceIndex(const ADataSourceIndex: Integer); virtual;
    procedure ClearEmbeddedDetailGrids; virtual;
  public
    function HitTest(const ALocation: TPoint): TThemedGridHitInfo;
    function GetCurrentCell: TThemedGridCell;
    procedure SetCurrentCell(const ARowIndex, AColumnIndex: Integer);
    procedure ClearSelection;
    procedure SelectCell(const ARowIndex, AColumnIndex: Integer);
    procedure SelectRange(const ARow1, AColumn1, ARow2, AColumn2: Integer);
    procedure InvalidateRow(const ARowIndex: Integer);
    procedure InvalidateCell(const ARowIndex, AColumnIndex: Integer);
    function ToggleDetailRow(const ARowIndex: Integer): Boolean;
    function ExpandDetailRow(const ARowIndex: Integer): Boolean;
    function CollapseDetailRow(const ARowIndex: Integer): Boolean;
    function ExpandDetailByDataSourceIndex(const ADataSourceIndex: Integer): Boolean;
    function CollapseDetailByDataSourceIndex(const ADataSourceIndex: Integer): Boolean;
    procedure CollapseAllDetails;
    property FocusedRowIndex: Integer read GetFocusedRowIndex;
    property FocusedColumnIndex: Integer read GetFocusedColumnIndex;
    property OnCurrentCellChanged: TThemedGridCurrentCellChangedEvent
      read FOnCurrentCellChanged write FOnCurrentCellChanged;
  end;

implementation

uses
  NimbusForms.Grid.RowViewBuilder,
  NimbusForms.Grid.CellRendererIntf,
  NimbusForms.Grid.InlineEditorGeometry;

function IsEmptyRect(const ARect: TRect): Boolean;
begin
  Result := (ARect.Right <= ARect.Left) or (ARect.Bottom <= ARect.Top);
end;

function TThemedGridControlHit.GetFocusedRowIndex: Integer;
begin
  Result := CurrentRowIndex;
end;

function TThemedGridControlHit.GetFocusedColumnIndex: Integer;
begin
  Result := CurrentColumnIndex;
end;

function TThemedGridControlHit.IsEditing: Boolean;
begin
  Result := False;
end;

procedure TThemedGridControlHit.UpdateEditorBounds;
begin
end;

function TThemedGridControlHit.CommitEdit: Boolean;
begin
  Result := True;
end;

function TThemedGridControlHit.EndRowEditForRow(const ARowIndex: Integer): Boolean;
begin
  Result := True;
end;

function TThemedGridControlHit.HasEmbeddedDetailGrids: Boolean;
begin
  Result := False;
end;

procedure TThemedGridControlHit.RemoveEmbeddedDetailGridByDataSourceIndex(const ADataSourceIndex: Integer);
begin
end;

procedure TThemedGridControlHit.ClearEmbeddedDetailGrids;
begin
end;

function TThemedGridControlHit.FindDataViewRow(const AStartRowIndex, ADirection: Integer): Integer;
var
  LRowCount, LRowIndex, LStart, LDirection: Integer;
begin
  LRowCount := RowCount;
  if LRowCount <= 0 then
    Exit(-1);
  LDirection := ADirection;
  if LDirection = 0 then
    LDirection := 1;
  LStart := AStartRowIndex;
  if LStart < 0 then
  begin
    if LDirection > 0 then
      LStart := 0
    else
      LStart := LRowCount - 1;
  end;
  if LStart >= LRowCount then
    LStart := LRowCount - 1;
  LRowIndex := LStart;
  while (LRowIndex >= 0) and (LRowIndex < LRowCount) do
  begin
    if IsDataViewRow(LRowIndex) then
      Exit(LRowIndex);
    Inc(LRowIndex, LDirection);
  end;
  Result := -1;
end;

function TThemedGridControlHit.FindDataViewRowByDataSourceIndex(const ADataSourceIndex: Integer): Integer;
var
  I, LRowCount: Integer;
  LViewRow: TThemedGridViewRow;
begin
  if ADataSourceIndex < 0 then
    Exit(-1);
  LRowCount := RowCount;
  for I := 0 to LRowCount - 1 do
  begin
    LViewRow := GetViewRow(I);
    if (LViewRow <> nil) and LViewRow.IsDataRow and (LViewRow.DataSourceIndex = ADataSourceIndex) then
      Exit(I);
  end;
  Result := -1;
end;

function TThemedGridControlHit.NormalizeCellRowIndex(const ARowIndex, ADirection: Integer): Integer;
var
  LRowCount, LRowIndex: Integer;
begin
  LRowCount := RowCount;
  if LRowCount <= 0 then
    Exit(-1);
  LRowIndex := ARowIndex;
  if LRowIndex < 0 then
    LRowIndex := 0;
  if LRowIndex >= LRowCount then
    LRowIndex := LRowCount - 1;
  if IsDataViewRow(LRowIndex) then
    Exit(LRowIndex);
  Result := FindDataViewRow(LRowIndex, ADirection);
  if Result >= 0 then
    Exit;
  Result := FindDataViewRow(LRowIndex, -ADirection);
end;

function TThemedGridControlHit.SelectDetailParentRow(const ADetailRowIndex: Integer): Boolean;
var
  LDetailRow: TThemedGridViewRow;
  LParentIndex: Integer;
begin
  LDetailRow := GetViewRow(ADetailRowIndex);
  if (LDetailRow = nil) or not LDetailRow.IsDetailRow or (LDetailRow.ParentDataSourceIndex < 0) then
    Exit(False);
  LParentIndex := FindDataViewRowByDataSourceIndex(LDetailRow.ParentDataSourceIndex);
  if LParentIndex < 0 then
    Exit(False);
  FocusedDetailParentDataSourceIndex := LDetailRow.ParentDataSourceIndex;
  CurrentRowIndex := LParentIndex;
  if GetVisibleColumns.Count > 0 then
    CurrentColumnIndex := 0
  else
    CurrentColumnIndex := -1;
  if SelectionOptions.AllowRowSelection then
    SelectionModel.SelectRow(LParentIndex);
  if CurrentColumnIndex >= 0 then
    EnsureVisible(LParentIndex, CurrentColumnIndex)
  else
    EnsureVisible(LParentIndex, -1);
  Result := True;
end;

procedure TThemedGridControlHit.InvalidateBounds(const ABounds: TRect);
var
  LBounds: TRect;
begin
  if not HandleAllocated then
    Exit;
  LBounds := ABounds;
  InvalidateRect(Handle, @LBounds, False);
end;

procedure TThemedGridControlHit.InvalidateRow(const ARowIndex: Integer);
var
  LBounds: TRect;
begin
  LBounds := GetRowBounds(ARowIndex);
  if not IsEmptyRect(LBounds) then
    InvalidateBounds(LBounds)
  else
    Invalidate;
end;

procedure TThemedGridControlHit.InvalidateCell(const ARowIndex, AColumnIndex: Integer);
var
  LBounds: TRect;
begin
  LBounds := GetCellBounds(ARowIndex, AColumnIndex);
  if not IsEmptyRect(LBounds) then
    InvalidateBounds(LBounds)
  else
    Invalidate;
end;

function TThemedGridControlHit.FillRowKindHit(const AHit: TThemedGridHitInfo; const ARowIndex: Integer;
  const AViewRow: TThemedGridViewRow; const ABounds: TRect): Boolean;
begin
  Result := False;
  if AViewRow = nil then
    Exit;
  if AViewRow.Kind = TThemedGridViewRowKind.GroupHeader then
  begin
    AHit.HitArea := TThemedGridHitArea.GroupRow;
    AHit.RowIndex := ARowIndex;
    AHit.ColumnIndex := -1;
    AHit.DataSourceIndex := -1;
    AHit.OwnRow(GetRow(ARowIndex));
    AHit.Bounds := ABounds;
    Exit(True);
  end;
  if AViewRow.Kind = TThemedGridViewRowKind.Detail then
  begin
    AHit.HitArea := TThemedGridHitArea.DetailRow;
    AHit.RowIndex := ARowIndex;
    AHit.ColumnIndex := -1;
    AHit.DataSourceIndex := -1;
    AHit.Bounds := ABounds;
    Result := True;
  end;
end;

function TThemedGridControlHit.HitTest(const ALocation: TPoint): TThemedGridHitInfo;
var
  LRowIndex, LColumnIndex, LIndex: Integer;
  LViewRow: TThemedGridViewRow;
  LHeaderCellBounds: TRect;
  LCell: TThemedGridCell;
  LRenderer: IThemedGridCellRenderer;
  LCellHit: TThemedGridHitInfo;
begin
  CalculateLayout;
  Result := TThemedGridHitInfo.Create;
  Result.Location := ALocation;

  if VerticalScrollVisible and PtInRect(VerticalScrollBarBounds, ALocation) then
  begin
    Result.HitArea := TThemedGridHitArea.VerticalScrollBar;
    Result.Bounds := VerticalScrollBarBounds;
    Exit;
  end;

  if HorizontalScrollVisible and PtInRect(HorizontalScrollBarBounds, ALocation) then
  begin
    Result.HitArea := TThemedGridHitArea.HorizontalScrollBar;
    Result.Bounds := HorizontalScrollBarBounds;
    Exit;
  end;

  if PtInRect(ScrollCornerBounds, ALocation) then
  begin
    Result.HitArea := TThemedGridHitArea.ScrollCorner;
    Result.Bounds := ScrollCornerBounds;
    Exit;
  end;

  if ShowColumnHeaders and PtInRect(HeaderBounds, ALocation) then
  begin
    LIndex := -1;
    if AllowColumnResize then
      LIndex := GetColumnResizeGripIndex(ALocation);
    if LIndex >= 0 then
    begin
      Result.HitArea := TThemedGridHitArea.ResizeGrip;
      Result.ColumnIndex := LIndex;
      Result.Column := GetColumn(LIndex);
      Result.Bounds := GetColumnResizeGripBounds(LIndex);
      Exit;
    end;

    LIndex := GetColumnFilterButtonIndex(ALocation);
    if LIndex >= 0 then
    begin
      Result.HitArea := TThemedGridHitArea.FilterButton;
      Result.ColumnIndex := LIndex;
      Result.Column := GetColumn(LIndex);
      Result.Bounds := GetColumnFilterButtonBounds(LIndex);
      Exit;
    end;

    LColumnIndex := GetColumnIndexAtX(ALocation.X);
    if LColumnIndex >= 0 then
    begin
      Result.HitArea := TThemedGridHitArea.ColumnHeader;
      Result.ColumnIndex := LColumnIndex;
      Result.Column := GetColumn(LColumnIndex);
      Result.Bounds := GetHeaderCellBounds(LColumnIndex);
      Exit;
    end;

    Result.HitArea := TThemedGridHitArea.ColumnHeader;
    Result.Bounds := HeaderBounds;
    Exit;
  end;

  if ShowRowHeaders and PtInRect(RowHeaderBounds, ALocation) then
  begin
    LRowIndex := GetRowIndexAtY(ALocation.Y);
    if LRowIndex >= 0 then
    begin
      LViewRow := GetViewRow(LRowIndex);
      LHeaderCellBounds := GetRowHeaderCellBounds(LRowIndex);
      if FillRowKindHit(Result, LRowIndex, LViewRow, LHeaderCellBounds) then
        Exit;

      if IsDetailExpanderVisible(LRowIndex) and
        TThemedGridInlineEditorGeometry.HitTestDetailExpander(LHeaderCellBounds, ALocation) then
      begin
        Result.HitArea := TThemedGridHitArea.DetailExpander;
        Result.RowIndex := LRowIndex;
        Result.ColumnIndex := -1;
        Result.DataSourceIndex := GetViewRowDataSourceIndex(LRowIndex);
        Result.OwnRow(GetRow(LRowIndex));
        Result.Bounds := LHeaderCellBounds;
        Exit;
      end;

      Result.HitArea := TThemedGridHitArea.RowHeader;
      Result.RowIndex := LRowIndex;
      Result.DataSourceIndex := GetViewRowDataSourceIndex(LRowIndex);
      Result.OwnRow(GetRow(LRowIndex));
      Result.Bounds := LHeaderCellBounds;
      Exit;
    end;

    Result.HitArea := TThemedGridHitArea.RowHeader;
    Result.Bounds := RowHeaderBounds;
    Exit;
  end;

  if ShowSummaryFooter and not IsEmptyRect(SummaryFooterBounds) and PtInRect(SummaryFooterBounds, ALocation) then
  begin
    LColumnIndex := GetSummaryFooterColumnIndex(ALocation);
    Result.HitArea := TThemedGridHitArea.SummaryFooter;
    Result.RowIndex := -1;
    Result.ColumnIndex := LColumnIndex;
    Result.DataSourceIndex := -1;
    if LColumnIndex >= 0 then
    begin
      Result.Column := GetColumn(LColumnIndex);
      Result.Bounds := GetSummaryFooterCellBounds(LColumnIndex);
    end
    else
      Result.Bounds := SummaryFooterBounds;
    Exit;
  end;

  if PtInRect(DataBounds, ALocation) then
  begin
    LRowIndex := GetRowIndexAtY(ALocation.Y);
    if LRowIndex >= 0 then
    begin
      LViewRow := GetViewRow(LRowIndex);
      if FillRowKindHit(Result, LRowIndex, LViewRow, GetRowBounds(LRowIndex)) then
        Exit;
    end;

    LColumnIndex := GetColumnIndexAtX(ALocation.X);
    if (LRowIndex >= 0) and (LColumnIndex >= 0) then
    begin
      LCell := GetCell(LRowIndex, LColumnIndex);
      if LCell <> nil then
      begin
        LRenderer := Renderer.ResolveCellRenderer(LCell);
        LCellHit := LRenderer.HitTestContent(nil, LCell, ALocation);
        if LCellHit = nil then
        begin
          LCell.Free;
          Exit;
        end;
        if LCellHit.Cell = LCell then
          LCellHit.OwnCell(LCell)
        else
          LCell.Free;
        Result.Free;
        Result := LCellHit;
        Exit;
      end;

      Result.HitArea := TThemedGridHitArea.Cell;
      Result.RowIndex := LRowIndex;
      Result.ColumnIndex := LColumnIndex;
      Result.DataSourceIndex := GetViewRowDataSourceIndex(LRowIndex);
      Result.Bounds := TRect.Empty;
      Exit;
    end;

    Result.HitArea := TThemedGridHitArea.None;
    Result.Bounds := DataBounds;
  end;
end;

function TThemedGridControlHit.GetCurrentCell: TThemedGridCell;
begin
  Result := nil;
  if (CurrentRowIndex < 0) or (CurrentColumnIndex < 0) then
    Exit;
  if not IsDataViewRow(CurrentRowIndex) then
    Exit;
  Result := GetCell(CurrentRowIndex, CurrentColumnIndex);
end;

function TThemedGridControlHit.CaptureCurrentCell: TThemedGridCell;
begin
  if Assigned(FOnCurrentCellChanged) then
    Result := GetCurrentCell
  else
    Result := nil;
end;

procedure TThemedGridControlHit.NotifyCurrentCellChanged(const AOldCell: TThemedGridCell);
var
  LNewCell: TThemedGridCell;
begin
  if not Assigned(FOnCurrentCellChanged) then
  begin
    AOldCell.Free;
    Exit;
  end;
  LNewCell := GetCurrentCell;
  try
    DoCurrentCellChanged(AOldCell, LNewCell);
  finally
    LNewCell.Free;
    AOldCell.Free;
  end;
end;

procedure TThemedGridControlHit.DoCurrentCellChanged(const AOldCell, ANewCell: TThemedGridCell);
var
  LArgs: TThemedGridCurrentCellChangedEventArgs;
begin
  if not Assigned(FOnCurrentCellChanged) then
    Exit;
  LArgs := TThemedGridCurrentCellChangedEventArgs.Create(AOldCell, ANewCell);
  try
    FOnCurrentCellChanged(Self, LArgs);
  finally
    LArgs.Free;
  end;
end;

procedure TThemedGridControlHit.SetCurrentCell(const ARowIndex, AColumnIndex: Integer);
var
  LRowIndex, LColumnIndex, LRowCount, LColumnCount: Integer;
  LOldCell: TThemedGridCell;
begin
  if IsEditing then
    CommitEdit;
  if not EndRowEditForRow(ARowIndex) then
    Exit;

  LRowIndex := ARowIndex;
  LColumnIndex := AColumnIndex;
  LRowCount := RowCount;
  LColumnCount := GetVisibleColumns.Count;

  if LRowIndex >= LRowCount then
    LRowIndex := LRowCount - 1;
  if LColumnIndex >= LColumnCount then
    LColumnIndex := LColumnCount - 1;
  if (LRowIndex >= 0) and (LColumnIndex >= 0) then
    LRowIndex := NormalizeCellRowIndex(LRowIndex, 1);

  if (LRowIndex < 0) or (LColumnIndex < 0) or (LRowCount <= 0) or (LColumnCount <= 0) then
  begin
    LOldCell := CaptureCurrentCell;
    CurrentRowIndex := -1;
    CurrentColumnIndex := -1;
    SelectionModel.SetCurrentCell(-1, -1, False);
    NotifyCurrentCellChanged(LOldCell);
    Invalidate;
    Exit;
  end;

  if (CurrentRowIndex = LRowIndex) and (CurrentColumnIndex = LColumnIndex) then
    Exit;

  LOldCell := CaptureCurrentCell;
  CurrentRowIndex := LRowIndex;
  CurrentColumnIndex := LColumnIndex;
  SelectionModel.SetCurrentCell(LRowIndex, LColumnIndex, True);
  EnsureVisible(LRowIndex, LColumnIndex);
  NotifyCurrentCellChanged(LOldCell);
  Invalidate;
end;

procedure TThemedGridControlHit.ClearSelection;
begin
  CurrentRowIndex := -1;
  CurrentColumnIndex := -1;
  SelectionModel.Clear;
  Invalidate;
end;

procedure TThemedGridControlHit.SelectCell(const ARowIndex, AColumnIndex: Integer);
var
  LRowIndex: Integer;
begin
  LRowIndex := ARowIndex;
  if not IsDataViewRow(LRowIndex) then
    LRowIndex := NormalizeCellRowIndex(LRowIndex, 1);
  if LRowIndex < 0 then
    Exit;
  SetCurrentCell(LRowIndex, AColumnIndex);
  SelectionModel.SelectCell(LRowIndex, AColumnIndex);
  Invalidate;
end;

procedure TThemedGridControlHit.SelectRange(const ARow1, AColumn1, ARow2, AColumn2: Integer);
var
  LRow1, LRow2, LDirection: Integer;
  LCurrent: TThemedGridCurrentCell;
begin
  if not SelectionOptions.AllowRangeSelection then
    Exit;
  if ARow1 <= ARow2 then
    LDirection := 1
  else
    LDirection := -1;
  LRow1 := NormalizeCellRowIndex(ARow1, LDirection);
  LRow2 := NormalizeCellRowIndex(ARow2, LDirection);
  if (LRow1 < 0) or (LRow2 < 0) then
    Exit;
  SelectionModel.SelectRange(LRow1, AColumn1, LRow2, AColumn2);
  LCurrent := SelectionModel.CurrentCell;
  if LCurrent.IsValid and IsDataViewRow(LCurrent.RowIndex) then
  begin
    CurrentRowIndex := LCurrent.RowIndex;
    CurrentColumnIndex := LCurrent.ColumnIndex;
    EnsureVisible(CurrentRowIndex, CurrentColumnIndex);
  end;
  Invalidate;
end;

procedure TThemedGridControlHit.ApplyMouseCellSelection(const ARowIndex, AColumnIndex: Integer;
  const AShift, AControl: Boolean);
var
  LOldCell: TThemedGridCell;
  LAnchor: TThemedGridCurrentCell;
begin
  if (ARowIndex < 0) or (AColumnIndex < 0) then
    Exit;
  if IsEditing then
    CommitEdit;
  if not EndRowEditForRow(ARowIndex) then
    Exit;

  LOldCell := CaptureCurrentCell;
  CurrentRowIndex := ARowIndex;
  CurrentColumnIndex := AColumnIndex;

  if AShift and SelectionOptions.AllowRangeSelection then
  begin
    LAnchor := SelectionModel.AnchorCell;
    if not LAnchor.IsValid then
      LAnchor := TThemedGridCurrentCell.Create(ARowIndex, AColumnIndex);
    SelectionModel.SelectRange(LAnchor.RowIndex, LAnchor.ColumnIndex, ARowIndex, AColumnIndex);
  end
  else if AControl then
    SelectionModel.ToggleCell(ARowIndex, AColumnIndex)
  else
    SelectionModel.SelectCell(ARowIndex, AColumnIndex);

  EnsureVisible(ARowIndex, AColumnIndex);
  NotifyCurrentCellChanged(LOldCell);
  Invalidate;
end;

procedure TThemedGridControlHit.ApplyMouseRowSelection(const ARowIndex: Integer; const AShift, AControl: Boolean);
var
  LColumnIndex, LFirstColumn, LLastColumn: Integer;
  LAnchor: TThemedGridCurrentCell;
begin
  if ARowIndex < 0 then
    Exit;
  if IsEditing then
    CommitEdit;
  if not EndRowEditForRow(ARowIndex) then
    Exit;

  if CurrentColumnIndex >= 0 then
    LColumnIndex := CurrentColumnIndex
  else
    LColumnIndex := 0;

  if AShift and SelectionOptions.AllowRangeSelection then
  begin
    LAnchor := SelectionModel.AnchorCell;
    if not LAnchor.IsValid then
      LAnchor := TThemedGridCurrentCell.Create(ARowIndex, LColumnIndex);
    LFirstColumn := 0;
    LLastColumn := Max(0, GetVisibleColumns.Count - 1);
    SelectionModel.SelectRange(LAnchor.RowIndex, LFirstColumn, ARowIndex, LLastColumn);
  end
  else if AControl then
    SelectionModel.ToggleRow(ARowIndex)
  else
    SelectionModel.SelectRow(ARowIndex);

  CurrentRowIndex := ARowIndex;
  if IsDataViewRow(ARowIndex) and (GetVisibleColumns.Count > 0) then
    CurrentColumnIndex := LColumnIndex
  else
    CurrentColumnIndex := -1;

  if (CurrentRowIndex >= 0) and (CurrentColumnIndex >= 0) then
    EnsureVisible(CurrentRowIndex, CurrentColumnIndex);

  Invalidate;
end;

function TThemedGridControlHit.TryToggleGroupRow(const ARowIndex: Integer; const ALocation: TPoint): Boolean;
var
  LViewRow: TThemedGridViewRow;
  LKey: string;
begin
  if (GroupingOptions = nil) or not GroupingOptions.AllowCollapse then
    Exit(False);
  LViewRow := GetViewRow(ARowIndex);
  if (LViewRow = nil) or (LViewRow.Kind <> TThemedGridViewRowKind.GroupHeader) then
    Exit(False);
  if not PtInRect(GetGroupGlyphBounds(LViewRow, ARowIndex), ALocation) and
    not PtInRect(GetRowBounds(ARowIndex), ALocation) then
    Exit(False);
  LKey := '';
  if LViewRow.Key.TypeInfo <> nil then
    LKey := LViewRow.Key.ToString;
  if LKey = '' then
    Exit(False);
  if CollapsedGroupKeys.Contains(LKey) then
    CollapsedGroupKeys.Remove(LKey)
  else
    CollapsedGroupKeys.Add(LKey);
  InvalidateRowView;
  NormalizeScrollValues;
  Invalidate;
  Result := True;
end;

function TThemedGridControlHit.GetDetailParentDataSourceIndexForRow(const ARowIndex: Integer): Integer;
var
  LViewRow: TThemedGridViewRow;
begin
  Result := -1;
  LViewRow := GetViewRow(ARowIndex);
  if LViewRow = nil then
    Exit;
  if LViewRow.IsDataRow then
    Result := LViewRow.DataSourceIndex
  else if LViewRow.IsDetailRow then
    Result := LViewRow.ParentDataSourceIndex;
end;

function TThemedGridControlHit.ToggleDetailRow(const ARowIndex: Integer): Boolean;
var
  LDataSourceIndex: Integer;
  LKey: string;
begin
  if (DetailOptions = nil) or not DetailOptions.Enabled or not DetailOptions.AllowCollapse then
    Exit(False);
  LDataSourceIndex := GetDetailParentDataSourceIndexForRow(ARowIndex);
  if LDataSourceIndex < 0 then
    Exit(False);
  LKey := TThemedGridRowViewBuilder.CreateDetailKey(LDataSourceIndex);
  if ExpandedDetailKeys.Contains(LKey) then
  begin
    ExpandedDetailKeys.Remove(LKey);
    RemoveEmbeddedDetailGridByDataSourceIndex(LDataSourceIndex);
  end
  else
    ExpandedDetailKeys.Add(LKey);
  InvalidateRowView;
  NormalizeScrollValues;
  Invalidate;
  Result := True;
end;

function TThemedGridControlHit.ExpandDetailRow(const ARowIndex: Integer): Boolean;
var
  LDataSourceIndex: Integer;
begin
  if (DetailOptions = nil) or not DetailOptions.Enabled then
    Exit(False);
  LDataSourceIndex := GetDetailParentDataSourceIndexForRow(ARowIndex);
  if LDataSourceIndex < 0 then
    Exit(False);
  Result := ExpandDetailByDataSourceIndex(LDataSourceIndex);
end;

function TThemedGridControlHit.CollapseDetailRow(const ARowIndex: Integer): Boolean;
var
  LDataSourceIndex: Integer;
begin
  LDataSourceIndex := GetDetailParentDataSourceIndexForRow(ARowIndex);
  if LDataSourceIndex < 0 then
    Exit(False);
  Result := CollapseDetailByDataSourceIndex(LDataSourceIndex);
end;

function TThemedGridControlHit.ExpandDetailByDataSourceIndex(const ADataSourceIndex: Integer): Boolean;
var
  LKey: string;
begin
  if (DetailOptions = nil) or not DetailOptions.Enabled then
    Exit(False);
  if ADataSourceIndex < 0 then
    Exit(False);
  LKey := TThemedGridRowViewBuilder.CreateDetailKey(ADataSourceIndex);
  if ExpandedDetailKeys.Contains(LKey) then
    Exit(True);
  ExpandedDetailKeys.Add(LKey);
  InvalidateRowView;
  NormalizeScrollValues;
  Invalidate;
  Result := True;
end;

function TThemedGridControlHit.CollapseDetailByDataSourceIndex(const ADataSourceIndex: Integer): Boolean;
var
  LKey: string;
begin
  if ADataSourceIndex < 0 then
    Exit(False);
  LKey := TThemedGridRowViewBuilder.CreateDetailKey(ADataSourceIndex);
  if not ExpandedDetailKeys.Contains(LKey) then
  begin
    RemoveEmbeddedDetailGridByDataSourceIndex(ADataSourceIndex);
    Exit(True);
  end;
  ExpandedDetailKeys.Remove(LKey);
  RemoveEmbeddedDetailGridByDataSourceIndex(ADataSourceIndex);
  InvalidateRowView;
  NormalizeScrollValues;
  Invalidate;
  Result := True;
end;

procedure TThemedGridControlHit.CollapseAllDetails;
begin
  if (ExpandedDetailKeys.Count = 0) and not HasEmbeddedDetailGrids then
    Exit;
  ExpandedDetailKeys.Clear;
  ClearEmbeddedDetailGrids;
  InvalidateRowView;
  NormalizeScrollValues;
  Invalidate;
end;

end.

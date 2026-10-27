unit NimbusForms.Grid.ControlAutoSize;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  System.Types,
  System.Generics.Collections,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.ControlSummary;

type
  TThemedGridControlAutoSize = class(TThemedGridControlSummary)
  private
    procedure ApplyFillColumns;
    procedure SetBestFitWidth(const AColumn: TThemedGridColumn; const AWidth: Integer);
  protected
    procedure ApplyAutoSizeModes; override;
    procedure RowsChangedByVersion; override;
    function MeasureHeaderWidth(const AColumn: TThemedGridColumn): Integer;
  public
    procedure BestFitColumn(const AColumnIndex: Integer); overload;
    procedure BestFitColumn(const AColumnName: string); overload;
    procedure BestFitColumn(const AColumn: TThemedGridColumn); overload;
    procedure BestFitAllColumns;
    procedure InvalidateColumnMeasure(const AColumn: TThemedGridColumn);
  end;

implementation

uses
  System.Math,
  Vcl.Graphics,
  NimbusForms.Grid.Cell,
  NimbusForms.Grid.CellRendererIntf,
  NimbusForms.Grid.RenderContext;

procedure TThemedGridControlAutoSize.RowsChangedByVersion;
begin
  inherited RowsChangedByVersion;
  InvalidateSummaryCache;
end;

procedure TThemedGridControlAutoSize.ApplyAutoSizeModes;
var
  LColumns: TList<TThemedGridColumn>;
  I: Integer;
  LColumn: TThemedGridColumn;
  LMode: TThemedGridAutoSizeMode;
begin
  if (not AutoSizePending) or UpdatingAutoSize then
    Exit;
  AutoSizePending := False;
  UpdatingAutoSize := True;
  try
    LColumns := TList<TThemedGridColumn>.Create(GetVisibleColumns);
    try
      for I := 0 to LColumns.Count - 1 do
      begin
        LColumn := LColumns[I];
        if (not LColumn.AutoSize) and (LColumn.AutoSizeMode = TThemedGridAutoSizeMode.None) then
          Continue;
        LMode := LColumn.AutoSizeMode;
        if (LMode = TThemedGridAutoSizeMode.None) and LColumn.AutoSize then
          LMode := TThemedGridAutoSizeMode.VisibleCells;
        if LMode = TThemedGridAutoSizeMode.Fill then
          Continue;
        if LMode = TThemedGridAutoSizeMode.Header then
        begin
          SetBestFitWidth(LColumn, MeasureHeaderWidth(LColumn));
          Continue;
        end;
        if (LMode = TThemedGridAutoSizeMode.VisibleCells) or (LMode = TThemedGridAutoSizeMode.DisplayedCells) or
           (LMode = TThemedGridAutoSizeMode.ContentAndHeader) then
          BestFitColumn(LColumn);
      end;
    finally
      LColumns.Free;
    end;
    ApplyFillColumns;
  finally
    UpdatingAutoSize := False;
  end;
end;

procedure TThemedGridControlAutoSize.ApplyFillColumns;
var
  LColumns, LFill: TList<TThemedGridColumn>;
  I, LFixedWidth, LNonFillWidth, LTotalWeight, LAvailable, LAssigned, LWidth: Integer;
  LColumn: TThemedGridColumn;
begin
  LColumns := TList<TThemedGridColumn>.Create(GetVisibleColumns);
  LFill := TList<TThemedGridColumn>.Create;
  try
    LFixedWidth := GetFixedLeftWidth + GetFixedRightWidth;
    LNonFillWidth := 0;
    LTotalWeight := 0;
    for I := 0 to LColumns.Count - 1 do
    begin
      LColumn := LColumns[I];
      if LColumn.FixedStyle <> TThemedGridColumnFixedStyle.None then
        Continue;
      if LColumn.AutoSizeMode = TThemedGridAutoSizeMode.Fill then
      begin
        LFill.Add(LColumn);
        Inc(LTotalWeight, LColumn.FillWeight);
      end
      else
        Inc(LNonFillWidth, LColumn.Width);
    end;
    if LFill.Count = 0 then
      Exit;
    if LTotalWeight <= 0 then
      LTotalWeight := LFill.Count;
    LAvailable := DataBounds.Right - DataBounds.Left - LFixedWidth - LNonFillWidth;
    if LAvailable < 0 then
      LAvailable := 0;
    LAssigned := 0;
    for I := 0 to LFill.Count - 1 do
    begin
      LColumn := LFill[I];
      if I = LFill.Count - 1 then
        LWidth := LAvailable - LAssigned
      else
        LWidth := LAvailable * LColumn.FillWeight div LTotalWeight;
      if LWidth < LColumn.MinWidth then
        LWidth := LColumn.MinWidth;
      if LWidth > LColumn.MaxWidth then
        LWidth := LColumn.MaxWidth;
      Inc(LAssigned, LWidth);
      LColumn.Width := LWidth;
    end;
  finally
    LFill.Free;
    LColumns.Free;
  end;
end;

procedure TThemedGridControlAutoSize.SetBestFitWidth(const AColumn: TThemedGridColumn; const AWidth: Integer);
var
  LWidth: Integer;
begin
  if AColumn = nil then
    Exit;
  LWidth := AWidth + 4;
  if LWidth < AColumn.MinWidth then
    LWidth := AColumn.MinWidth;
  if LWidth > AColumn.MaxWidth then
    LWidth := AColumn.MaxWidth;
  AColumn.Width := LWidth;
end;

function TThemedGridControlAutoSize.MeasureHeaderWidth(const AColumn: TThemedGridColumn): Integer;
begin
  if AColumn = nil then
    Exit(0);
  Canvas.Font.Assign(Font);
  Result := Canvas.TextWidth(AColumn.GetBestHeaderText) + Metrics.HeaderPadding.Left +
    Metrics.HeaderPadding.Right + 4;
end;

procedure TThemedGridControlAutoSize.BestFitColumn(const AColumnIndex: Integer);
var
  LColumn: TThemedGridColumn;
begin
  LColumn := GetColumn(AColumnIndex);
  if LColumn <> nil then
    BestFitColumn(LColumn);
end;

procedure TThemedGridControlAutoSize.BestFitColumn(const AColumnName: string);
var
  LColumn: TThemedGridColumn;
begin
  LColumn := GetColumn(AColumnName);
  if LColumn <> nil then
    BestFitColumn(LColumn);
end;

procedure TThemedGridControlAutoSize.BestFitColumn(const AColumn: TThemedGridColumn);
var
  LColumnIndex, LWidth, LFirst, LLast, LRowIndex: Integer;
  LContext: TThemedGridRenderContext;
  LCell: TThemedGridCell;
  LRenderer: IThemedGridCellRenderer;
  LSize: TSize;
begin
  if AColumn = nil then
    Exit;
  CalculateLayout;
  LColumnIndex := GetColumnVisibleIndex(AColumn.Name);
  if LColumnIndex < 0 then
    Exit;
  LWidth := MeasureHeaderWidth(AColumn);
  LFirst := FirstVisibleRowIndex;
  LLast := Min(RowCount - 1, LFirst + GetVisibleRowCapacity);
  Canvas.Font.Assign(Font);
  LContext := TThemedGridRenderContext.Create(Canvas.Handle, ClientRect, Font, Palette, Metrics);
  try
    for LRowIndex := LFirst to LLast do
    begin
      LCell := GetCell(LRowIndex, LColumnIndex);
      if LCell = nil then
        Continue;
      try
        LRenderer := Renderer.ResolveCellRenderer(LCell);
        LSize := LRenderer.Measure(LContext, LCell);
        if LSize.cx > LWidth then
          LWidth := LSize.cx;
      finally
        LCell.Free;
      end;
    end;
  finally
    LContext.Free;
  end;
  SetBestFitWidth(AColumn, LWidth);
  NormalizeScrollValues;
  Invalidate;
end;

procedure TThemedGridControlAutoSize.BestFitAllColumns;
var
  LColumns: TList<TThemedGridColumn>;
  I: Integer;
begin
  LColumns := TList<TThemedGridColumn>.Create(GetVisibleColumns);
  try
    for I := 0 to LColumns.Count - 1 do
      BestFitColumn(LColumns[I]);
  finally
    LColumns.Free;
  end;
end;

procedure TThemedGridControlAutoSize.InvalidateColumnMeasure(const AColumn: TThemedGridColumn);
begin
  Invalidate;
end;

end.

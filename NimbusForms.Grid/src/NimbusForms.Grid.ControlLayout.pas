unit NimbusForms.Grid.ControlLayout;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  System.Math,
  System.Types,
  System.Generics.Collections,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Column,
  NimbusForms.Grid.ControlBase;

type
  TThemedGridControlLayout = class(TThemedGridControlBase)
  protected
    const
      ColumnResizeGripWidth = 6;
    function GetSearchPanelHeight: Integer; virtual;
    procedure CalculateLayout;
    function GetEffectiveHeaderHeight: Integer;
    procedure CalculateScrollThumbs;
    procedure NormalizeScrollValues; override;
    function GetVisibleRowCapacity: Integer;
    function GetVerticalScrollLargeChange: Integer;
    function GetMaxFirstVisibleRow: Integer;
    function GetViewRowHeight(const ARowIndex: Integer): Integer;
    function GetRowsTotalHeight: Integer;
    function GetViewRowTop(const ARowIndex: Integer): Integer;
    function GetRowIndexAtVirtualY(const AVirtualY: Integer): Integer;
    procedure GetVisibleRowRange(out AFirst, ALast, AUsedBottom: Integer);
    function GetMaxHorizontalOffset: Integer;
    function GetRowBounds(const ARowIndex: Integer): TRect;
    function GetRowHeaderCellBounds(const ARowIndex: Integer): TRect;
    function GetHeaderCellBounds(const AColumnIndex: Integer): TRect;
    function GetCellBounds(const ARowIndex, AColumnIndex: Integer): TRect;
    function GetColumnLeft(const AColumnIndex: Integer): Integer;
    function GetFixedLeftWidth: Integer;
    function GetFixedRightWidth: Integer;
    function GetScrollableColumnsWidth: Integer;
    function GetScrollableColumnLeft(const AColumnIndex: Integer): Integer;
    function GetFixedColumnLeft(const AColumnIndex: Integer): Integer;
    function GetFixedRightColumnLeft(const AColumnIndex: Integer): Integer;
    function GetFixedLeftViewportBounds: TRect;
    function GetFixedRightViewportBounds: TRect;
    function GetScrollableViewportBounds: TRect;
    function GetFixedLeftHeaderViewportBounds: TRect;
    function GetFixedRightHeaderViewportBounds: TRect;
    function GetScrollableHeaderViewportBounds: TRect;
    function GetColumnIndexAtX(const AX: Integer): Integer;
    function GetRowIndexAtY(const AY: Integer): Integer;
    function GetColumnResizeGripIndex(const ALocation: TPoint): Integer;
    function GetColumnResizeGripBounds(const AColumnIndex: Integer): TRect;
  public
    procedure EnsureVisible(const ARowIndex: Integer); overload;
    procedure EnsureVisible(const ARowIndex, AColumnIndex: Integer); overload;
  end;

implementation

function EmptyRect: TRect;
begin
  Result := Rect(0, 0, 0, 0);
end;

function IsEmptyRect(const ARect: TRect): Boolean;
begin
  Result := (ARect.Right <= ARect.Left) or (ARect.Bottom <= ARect.Top);
end;

function TThemedGridControlLayout.GetSearchPanelHeight: Integer;
begin
  Result := 0;
end;

procedure TThemedGridControlLayout.CalculateLayout;
var
  LWidth, LHeight, LSearchHeight, LHeaderHeight, LRowHeaderWidth, LScrollSize, LFooterHeight: Integer;
  LAvailableWidth, LAvailableHeight: Integer;
  LFixedWidth, LScrollableWidth, LAvailableScrollableWidth, LAvailableBodyHeight, LTotalRowsHeight: Integer;
  LVertical, LHorizontal: Boolean;
  LDataWidth, LFullDataHeight, LDataHeight: Integer;
begin
  if HandleAllocated then
  begin
    LWidth := ClientWidth;
    LHeight := ClientHeight;
  end
  else
  begin
    LWidth := Width;
    LHeight := Height;
  end;
  LSearchHeight := GetSearchPanelHeight;
  if ShowColumnHeaders then
    LHeaderHeight := GetEffectiveHeaderHeight
  else
    LHeaderHeight := 0;
  if ShowRowHeaders then
    LRowHeaderWidth := Metrics.RowHeaderWidth
  else
    LRowHeaderWidth := 0;
  LScrollSize := Metrics.ScrollBarSize;
  if ShowSummaryFooter then
    LFooterHeight := SummaryFooterHeight
  else
    LFooterHeight := 0;

  LAvailableWidth := Max(0, LWidth - LRowHeaderWidth);
  LAvailableHeight := Max(0, LHeight - LSearchHeight - LHeaderHeight);

  LFixedWidth := GetFixedLeftWidth + GetFixedRightWidth;
  LScrollableWidth := GetScrollableColumnsWidth;
  LAvailableScrollableWidth := Max(0, LAvailableWidth - LFixedWidth);

  LAvailableBodyHeight := Max(0, LAvailableHeight - LFooterHeight);
  LTotalRowsHeight := GetRowsTotalHeight;

  LVertical := ShowVerticalScrollBar and (LTotalRowsHeight > LAvailableBodyHeight);
  LHorizontal := ShowHorizontalScrollBar and (LScrollableWidth > LAvailableScrollableWidth);

  if LVertical and (not LHorizontal) then
    LHorizontal := ShowHorizontalScrollBar and (LScrollableWidth > Max(0, LAvailableWidth - LScrollSize - LFixedWidth));

  if LHorizontal and (not LVertical) then
    LVertical := ShowVerticalScrollBar and (LTotalRowsHeight > Max(0, LAvailableBodyHeight - LScrollSize));

  LDataWidth := LAvailableWidth;
  if LVertical then
    Dec(LDataWidth, LScrollSize);
  LFullDataHeight := LAvailableHeight;
  if LHorizontal then
    Dec(LFullDataHeight, LScrollSize);
  if LDataWidth < 0 then
    LDataWidth := 0;
  if LFullDataHeight < 0 then
    LFullDataHeight := 0;

  if ShowSummaryFooter then
    LFooterHeight := Min(SummaryFooterHeight, LFullDataHeight)
  else
    LFooterHeight := 0;
  LDataHeight := Max(0, LFullDataHeight - LFooterHeight);

  HeaderBounds := Rect(LRowHeaderWidth, LSearchHeight, LRowHeaderWidth + LDataWidth, LSearchHeight + LHeaderHeight);
  DataBounds := Rect(LRowHeaderWidth, LSearchHeight + LHeaderHeight, LRowHeaderWidth + LDataWidth,
    LSearchHeight + LHeaderHeight + LDataHeight);
  if LFooterHeight > 0 then
    SummaryFooterBounds := Rect(LRowHeaderWidth, DataBounds.Bottom, LRowHeaderWidth + LDataWidth,
      DataBounds.Bottom + LFooterHeight)
  else
    SummaryFooterBounds := EmptyRect;
  RowHeaderBounds := Rect(0, LSearchHeight + LHeaderHeight, LRowHeaderWidth,
    LSearchHeight + LHeaderHeight + LDataHeight);

  VerticalScrollVisible := LVertical;
  HorizontalScrollVisible := LHorizontal;

  if LVertical then
    VerticalScrollBarBounds := Rect(LRowHeaderWidth + LDataWidth, LSearchHeight + LHeaderHeight,
      LRowHeaderWidth + LDataWidth + LScrollSize, LSearchHeight + LHeaderHeight + LDataHeight + LFooterHeight)
  else
    VerticalScrollBarBounds := EmptyRect;

  if LHorizontal then
    HorizontalScrollBarBounds := Rect(LRowHeaderWidth, LSearchHeight + LHeaderHeight + LDataHeight + LFooterHeight,
      LRowHeaderWidth + LDataWidth, LSearchHeight + LHeaderHeight + LDataHeight + LFooterHeight + LScrollSize)
  else
    HorizontalScrollBarBounds := EmptyRect;

  if LVertical and LHorizontal then
    ScrollCornerBounds := Rect(LRowHeaderWidth + LDataWidth, LSearchHeight + LHeaderHeight + LDataHeight + LFooterHeight,
      LRowHeaderWidth + LDataWidth + LScrollSize, LSearchHeight + LHeaderHeight + LDataHeight + LFooterHeight + LScrollSize)
  else
    ScrollCornerBounds := EmptyRect;

  CalculateScrollThumbs;
end;

function TThemedGridControlLayout.GetEffectiveHeaderHeight: Integer;
begin
  if not ShowColumnHeaders then
    Exit(0);
  if not ShowColumnBandHeaders then
    Exit(Metrics.HeaderHeight);
  Result := Metrics.HeaderHeight + ColumnBandHeaderHeight;
end;

procedure TThemedGridControlLayout.CalculateScrollThumbs;
var
  LRowCount, LMaxFirst, LPageRows, LTrackHeight, LThumbHeight, LMovable, LFirst, LTop: Integer;
  LScrollableWidth, LViewportWidth, LMaxOffset, LTrackWidth, LThumbWidth, LLeft: Integer;
  LBar, LViewportRect: TRect;
begin
  VerticalScrollThumbBounds := EmptyRect;
  HorizontalScrollThumbBounds := EmptyRect;

  LBar := VerticalScrollBarBounds;
  if VerticalScrollVisible and ((LBar.Bottom - LBar.Top) > 0) and (RowCount > 0) then
  begin
    LRowCount := Max(0, RowCount);
    LMaxFirst := GetMaxFirstVisibleRow;
    LPageRows := GetVerticalScrollLargeChange;
    LTrackHeight := Max(1, LBar.Bottom - LBar.Top);
    if (LMaxFirst <= 0) or (LRowCount <= LPageRows) then
      VerticalScrollThumbBounds := LBar
    else
    begin
      LThumbHeight := Integer(Max(Int64(18), Int64(LTrackHeight) * LPageRows div Max(1, LRowCount)));
      if LThumbHeight > LTrackHeight then
        LThumbHeight := LTrackHeight;
      LMovable := Max(1, LTrackHeight - LThumbHeight);
      LFirst := FirstVisibleRowIndex;
      if LFirst < 0 then
        LFirst := 0;
      if LFirst > LMaxFirst then
        LFirst := LMaxFirst;
      LTop := LBar.Top + Integer(Int64(LMovable) * LFirst div Max(1, LMaxFirst));
      VerticalScrollThumbBounds := Rect(LBar.Left, LTop, LBar.Right, LTop + LThumbHeight);
    end;
  end;

  LBar := HorizontalScrollBarBounds;
  if HorizontalScrollVisible and ((LBar.Right - LBar.Left) > 0) then
  begin
    LScrollableWidth := Max(1, GetScrollableColumnsWidth);
    LViewportRect := GetScrollableViewportBounds;
    LViewportWidth := Max(1, LViewportRect.Right - LViewportRect.Left);
    LMaxOffset := GetMaxHorizontalOffset;
    if LMaxOffset <= 0 then
      HorizontalScrollThumbBounds := LBar
    else
    begin
      LTrackWidth := Max(1, LBar.Right - LBar.Left);
      LThumbWidth := Max(18, Integer(Int64(LTrackWidth) * LViewportWidth div Max(LViewportWidth, LScrollableWidth)));
      if LThumbWidth > LTrackWidth then
        LThumbWidth := LTrackWidth;
      LMovable := Max(1, LTrackWidth - LThumbWidth);
      LLeft := LBar.Left + Integer(Int64(LMovable) * HorizontalOffset div LMaxOffset);
      HorizontalScrollThumbBounds := Rect(LLeft, LBar.Top, LLeft + LThumbWidth, LBar.Bottom);
    end;
  end;
end;

procedure TThemedGridControlLayout.NormalizeScrollValues;
var
  LMaxFirst, LMaxOffset: Integer;
begin
  CalculateLayout;
  LMaxFirst := GetMaxFirstVisibleRow;
  if FirstVisibleRowIndex < 0 then
    FirstVisibleRowIndex := 0;
  if FirstVisibleRowIndex > LMaxFirst then
    FirstVisibleRowIndex := LMaxFirst;
  LMaxOffset := GetMaxHorizontalOffset;
  if HorizontalOffset < 0 then
    HorizontalOffset := 0;
  if HorizontalOffset > LMaxOffset then
    HorizontalOffset := LMaxOffset;
  CalculateScrollThumbs;
end;

function TThemedGridControlLayout.GetVisibleRowCapacity: Integer;
var
  LRowCount, LFirst, LViewportBottom, I: Integer;
begin
  EnsureRowTopCache;
  LRowCount := RowCount;
  if (LRowCount <= 0) or ((DataBounds.Bottom - DataBounds.Top) <= 0) then
    Exit(0);
  LFirst := FirstVisibleRowIndex;
  if LFirst < 0 then
    LFirst := 0;
  if LFirst >= LRowCount then
    LFirst := LRowCount - 1;
  LViewportBottom := GetViewRowTop(LFirst) + (DataBounds.Bottom - DataBounds.Top);
  Result := 0;
  for I := LFirst to LRowCount - 1 do
  begin
    if GetViewRowTop(I) >= LViewportBottom then
      Break;
    Inc(Result);
  end;
end;

function TThemedGridControlLayout.GetVerticalScrollLargeChange: Integer;
var
  LRowHeight, LRowCount: Integer;
begin
  Result := GetVisibleRowCapacity;
  if Result <= 0 then
  begin
    LRowHeight := Max(12, Metrics.RowHeight);
    if (DataBounds.Bottom - DataBounds.Top) > 0 then
      Result := (DataBounds.Bottom - DataBounds.Top) div LRowHeight
    else
      Result := 1;
  end;
  if Result <= 0 then
    Result := 1;
  LRowCount := RowCount;
  if (LRowCount > 0) and (Result > LRowCount) then
    Result := LRowCount;
end;

function TThemedGridControlLayout.GetMaxFirstVisibleRow: Integer;
var
  LRowCount: Integer;
begin
  LRowCount := RowCount;
  if LRowCount <= 0 then
    Exit(0);
  Result := LRowCount - GetVerticalScrollLargeChange;
  if Result < 0 then
    Result := 0;
end;

function TThemedGridControlLayout.GetViewRowHeight(const ARowIndex: Integer): Integer;
var
  LDefault: Integer;
begin
  EnsureRowView;
  LDefault := Max(12, Metrics.RowHeight);
  if RowView = nil then
    Exit(LDefault);
  Result := RowView.GetEstimatedRowHeight(ARowIndex, LDefault);
end;

function TThemedGridControlLayout.GetRowsTotalHeight: Integer;
begin
  EnsureRowTopCache;
  Result := RowTopCacheTotalHeight;
end;

function TThemedGridControlLayout.GetViewRowTop(const ARowIndex: Integer): Integer;
begin
  EnsureRowTopCache;
  if ARowIndex <= 0 then
    Exit(0);
  if RowView = nil then
    Exit(0);
  if ARowIndex >= RowTopCacheRowCount then
    Exit(RowTopCacheTotalHeight);
  Result := RowView.GetRowTop(ARowIndex, RowTopCacheBaseHeight);
end;

function TThemedGridControlLayout.GetRowIndexAtVirtualY(const AVirtualY: Integer): Integer;
var
  LRowCount: Integer;
begin
  EnsureRowTopCache;
  LRowCount := RowCount;
  if LRowCount <= 0 then
    Exit(-1);
  if AVirtualY <= 0 then
    Exit(0);
  if AVirtualY >= GetRowsTotalHeight then
    Exit(LRowCount - 1);
  if RowView = nil then
    Exit(-1);
  Result := RowView.GetRowIndexAtVirtualY(AVirtualY, RowTopCacheBaseHeight);
end;

procedure TThemedGridControlLayout.GetVisibleRowRange(out AFirst, ALast, AUsedBottom: Integer);
var
  LRowCount, LNormalizedFirst, LFirstTop, LViewportBottom, I: Integer;
begin
  EnsureRowTopCache;
  LRowCount := RowCount;
  AFirst := -1;
  ALast := -1;
  AUsedBottom := DataBounds.Top;
  if (LRowCount <= 0) or ((DataBounds.Bottom - DataBounds.Top) <= 0) then
    Exit;
  LNormalizedFirst := FirstVisibleRowIndex;
  if LNormalizedFirst < 0 then
    LNormalizedFirst := 0;
  if LNormalizedFirst >= LRowCount then
    LNormalizedFirst := LRowCount - 1;
  LFirstTop := GetViewRowTop(LNormalizedFirst);
  LViewportBottom := LFirstTop + (DataBounds.Bottom - DataBounds.Top);
  AFirst := LNormalizedFirst;
  for I := AFirst to LRowCount - 1 do
  begin
    if GetViewRowTop(I) >= LViewportBottom then
      Break;
    ALast := I;
  end;
  if ALast >= AFirst then
    AUsedBottom := DataBounds.Top + GetViewRowTop(ALast) + GetViewRowHeight(ALast) - LFirstTop;
  if AUsedBottom > DataBounds.Bottom then
    AUsedBottom := DataBounds.Bottom;
end;

function TThemedGridControlLayout.GetMaxHorizontalOffset: Integer;
var
  LViewport: TRect;
  LViewportWidth: Integer;
begin
  LViewport := GetScrollableViewportBounds;
  LViewportWidth := LViewport.Right - LViewport.Left;
  if LViewportWidth <= 0 then
    Exit(0);
  Result := Max(0, GetScrollableColumnsWidth - LViewportWidth);
end;

function TThemedGridControlLayout.GetRowBounds(const ARowIndex: Integer): TRect;
var
  LFirstTop, LRowTop, LHeight, LY: Integer;
begin
  CalculateLayout;
  if (ARowIndex < 0) or (ARowIndex >= RowCount) then
    Exit(EmptyRect);
  LFirstTop := GetViewRowTop(FirstVisibleRowIndex);
  LRowTop := GetViewRowTop(ARowIndex);
  LHeight := GetViewRowHeight(ARowIndex);
  LY := DataBounds.Top + LRowTop - LFirstTop;
  if LY >= DataBounds.Bottom then
    Exit(EmptyRect);
  if LY + LHeight <= DataBounds.Top then
    Exit(EmptyRect);
  Result := Rect(0, LY, ClientWidth, LY + LHeight);
end;

function TThemedGridControlLayout.GetRowHeaderCellBounds(const ARowIndex: Integer): TRect;
var
  LFirstTop, LRowTop, LHeight, LY: Integer;
begin
  CalculateLayout;
  if not ShowRowHeaders then
    Exit(EmptyRect);
  if (ARowIndex < 0) or (ARowIndex >= RowCount) then
    Exit(EmptyRect);
  LFirstTop := GetViewRowTop(FirstVisibleRowIndex);
  LRowTop := GetViewRowTop(ARowIndex);
  LHeight := GetViewRowHeight(ARowIndex);
  LY := DataBounds.Top + LRowTop - LFirstTop;
  if (LY >= DataBounds.Bottom) or (LY + LHeight <= DataBounds.Top) then
    Exit(EmptyRect);
  Result := Rect(0, LY, Metrics.RowHeaderWidth, LY + LHeight);
end;

function TThemedGridControlLayout.GetHeaderCellBounds(const AColumnIndex: Integer): TRect;
var
  LColumn: TThemedGridColumn;
  LLeft, LBandHeight, LColumnHeaderHeight: Integer;
begin
  CalculateLayout;
  LColumn := GetColumn(AColumnIndex);
  if LColumn = nil then
    Exit(EmptyRect);
  if LColumn.FixedStyle = TThemedGridColumnFixedStyle.Left then
    LLeft := DataBounds.Left + GetFixedColumnLeft(AColumnIndex)
  else if LColumn.FixedStyle = TThemedGridColumnFixedStyle.Right then
    LLeft := DataBounds.Right - GetFixedRightWidth + GetFixedRightColumnLeft(AColumnIndex)
  else
    LLeft := GetScrollableViewportBounds.Left + GetScrollableColumnLeft(AColumnIndex) - HorizontalOffset;
  if ShowColumnBandHeaders then
    LBandHeight := ColumnBandHeaderHeight
  else
    LBandHeight := 0;
  LColumnHeaderHeight := Max(0, Metrics.HeaderHeight - LBandHeight);
  Result := Rect(LLeft, HeaderBounds.Top + LBandHeight, LLeft + LColumn.Width,
    HeaderBounds.Top + LBandHeight + LColumnHeaderHeight);
end;

function TThemedGridControlLayout.GetCellBounds(const ARowIndex, AColumnIndex: Integer): TRect;
var
  LColumn: TThemedGridColumn;
  LX, LFirstTop, LRowTop, LHeight, LY: Integer;
begin
  CalculateLayout;
  LColumn := GetColumn(AColumnIndex);
  if LColumn = nil then
    Exit(EmptyRect);
  if (ARowIndex < 0) or (ARowIndex >= RowCount) then
    Exit(EmptyRect);
  if LColumn.FixedStyle = TThemedGridColumnFixedStyle.Left then
    LX := DataBounds.Left + GetFixedColumnLeft(AColumnIndex)
  else if LColumn.FixedStyle = TThemedGridColumnFixedStyle.Right then
    LX := DataBounds.Right - GetFixedRightWidth + GetFixedRightColumnLeft(AColumnIndex)
  else
    LX := GetScrollableViewportBounds.Left + GetScrollableColumnLeft(AColumnIndex) - HorizontalOffset;
  LFirstTop := GetViewRowTop(FirstVisibleRowIndex);
  LRowTop := GetViewRowTop(ARowIndex);
  LHeight := GetViewRowHeight(ARowIndex);
  LY := DataBounds.Top + LRowTop - LFirstTop;
  Result := Rect(LX, LY, LX + LColumn.Width, LY + LHeight);
end;

function TThemedGridControlLayout.GetColumnLeft(const AColumnIndex: Integer): Integer;
var
  LColumns: TList<TThemedGridColumn>;
  I: Integer;
begin
  LColumns := GetVisibleColumns;
  Result := 0;
  I := 0;
  while (I < AColumnIndex) and (I < LColumns.Count) do
  begin
    Inc(Result, LColumns[I].Width);
    Inc(I);
  end;
end;

function TThemedGridControlLayout.GetFixedLeftWidth: Integer;
var
  LColumns: TList<TThemedGridColumn>;
  I: Integer;
begin
  LColumns := GetVisibleColumns;
  Result := 0;
  for I := 0 to LColumns.Count - 1 do
    if LColumns[I].FixedStyle = TThemedGridColumnFixedStyle.Left then
      Inc(Result, LColumns[I].Width);
end;

function TThemedGridControlLayout.GetFixedRightWidth: Integer;
var
  LColumns: TList<TThemedGridColumn>;
  I: Integer;
begin
  LColumns := GetVisibleColumns;
  Result := 0;
  for I := 0 to LColumns.Count - 1 do
    if LColumns[I].FixedStyle = TThemedGridColumnFixedStyle.Right then
      Inc(Result, LColumns[I].Width);
end;

function TThemedGridControlLayout.GetScrollableColumnsWidth: Integer;
var
  LColumns: TList<TThemedGridColumn>;
  I: Integer;
begin
  LColumns := GetVisibleColumns;
  Result := 0;
  for I := 0 to LColumns.Count - 1 do
    if LColumns[I].FixedStyle = TThemedGridColumnFixedStyle.None then
      Inc(Result, LColumns[I].Width);
end;

function TThemedGridControlLayout.GetScrollableColumnLeft(const AColumnIndex: Integer): Integer;
var
  LColumns: TList<TThemedGridColumn>;
  I: Integer;
begin
  LColumns := GetVisibleColumns;
  Result := 0;
  I := 0;
  while (I < AColumnIndex) and (I < LColumns.Count) do
  begin
    if LColumns[I].FixedStyle = TThemedGridColumnFixedStyle.None then
      Inc(Result, LColumns[I].Width);
    Inc(I);
  end;
end;

function TThemedGridControlLayout.GetFixedColumnLeft(const AColumnIndex: Integer): Integer;
var
  LColumns: TList<TThemedGridColumn>;
  I: Integer;
begin
  LColumns := GetVisibleColumns;
  Result := 0;
  I := 0;
  while (I < AColumnIndex) and (I < LColumns.Count) do
  begin
    if LColumns[I].FixedStyle = TThemedGridColumnFixedStyle.Left then
      Inc(Result, LColumns[I].Width);
    Inc(I);
  end;
end;

function TThemedGridControlLayout.GetFixedRightColumnLeft(const AColumnIndex: Integer): Integer;
var
  LColumns: TList<TThemedGridColumn>;
  I: Integer;
begin
  LColumns := GetVisibleColumns;
  Result := 0;
  I := 0;
  while (I < AColumnIndex) and (I < LColumns.Count) do
  begin
    if LColumns[I].FixedStyle = TThemedGridColumnFixedStyle.Right then
      Inc(Result, LColumns[I].Width);
    Inc(I);
  end;
end;

function TThemedGridControlLayout.GetFixedLeftViewportBounds: TRect;
var
  LWidth: Integer;
begin
  LWidth := Min(GetFixedLeftWidth, DataBounds.Right - DataBounds.Left);
  if LWidth <= 0 then
    Exit(EmptyRect);
  Result := Rect(DataBounds.Left, DataBounds.Top, DataBounds.Left + LWidth, DataBounds.Bottom);
end;

function TThemedGridControlLayout.GetFixedRightViewportBounds: TRect;
var
  LWidth: Integer;
begin
  LWidth := Min(GetFixedRightWidth, DataBounds.Right - DataBounds.Left);
  if LWidth <= 0 then
    Exit(EmptyRect);
  Result := Rect(DataBounds.Right - LWidth, DataBounds.Top, DataBounds.Right, DataBounds.Bottom);
end;

function TThemedGridControlLayout.GetScrollableViewportBounds: TRect;
var
  LLeftWidth, LRemaining, LRightWidth, LLeft, LRight: Integer;
begin
  LLeftWidth := Min(GetFixedLeftWidth, DataBounds.Right - DataBounds.Left);
  LRemaining := Max(0, DataBounds.Right - DataBounds.Left - LLeftWidth);
  LRightWidth := Min(GetFixedRightWidth, LRemaining);
  LLeft := DataBounds.Left + LLeftWidth;
  LRight := DataBounds.Right - LRightWidth;
  if LRight < LLeft then
    LRight := LLeft;
  Result := Rect(LLeft, DataBounds.Top, LRight, DataBounds.Bottom);
end;

function TThemedGridControlLayout.GetFixedLeftHeaderViewportBounds: TRect;
var
  LWidth: Integer;
begin
  LWidth := Min(GetFixedLeftWidth, HeaderBounds.Right - HeaderBounds.Left);
  if LWidth <= 0 then
    Exit(EmptyRect);
  Result := Rect(HeaderBounds.Left, HeaderBounds.Top, HeaderBounds.Left + LWidth, HeaderBounds.Bottom);
end;

function TThemedGridControlLayout.GetFixedRightHeaderViewportBounds: TRect;
var
  LWidth: Integer;
begin
  LWidth := Min(GetFixedRightWidth, HeaderBounds.Right - HeaderBounds.Left);
  if LWidth <= 0 then
    Exit(EmptyRect);
  Result := Rect(HeaderBounds.Right - LWidth, HeaderBounds.Top, HeaderBounds.Right, HeaderBounds.Bottom);
end;

function TThemedGridControlLayout.GetScrollableHeaderViewportBounds: TRect;
var
  LLeftWidth, LRemaining, LRightWidth, LLeft, LRight: Integer;
begin
  LLeftWidth := Min(GetFixedLeftWidth, HeaderBounds.Right - HeaderBounds.Left);
  LRemaining := Max(0, HeaderBounds.Right - HeaderBounds.Left - LLeftWidth);
  LRightWidth := Min(GetFixedRightWidth, LRemaining);
  LLeft := HeaderBounds.Left + LLeftWidth;
  LRight := HeaderBounds.Right - LRightWidth;
  if LRight < LLeft then
    LRight := LLeft;
  Result := Rect(LLeft, HeaderBounds.Top, LRight, HeaderBounds.Bottom);
end;

function TThemedGridControlLayout.GetColumnIndexAtX(const AX: Integer): Integer;
var
  LColumns: TList<TThemedGridColumn>;
  LFixedLeft, LFixedRight, LScrollable: TRect;
  LLeft, LRight, LVirtualX, I: Integer;
  LColumn: TThemedGridColumn;
begin
  if (AX < DataBounds.Left) or (AX >= DataBounds.Right) then
    Exit(-1);
  LColumns := GetVisibleColumns;

  LFixedLeft := GetFixedLeftViewportBounds;
  if (AX >= LFixedLeft.Left) and (AX < LFixedLeft.Right) then
  begin
    LLeft := LFixedLeft.Left;
    for I := 0 to LColumns.Count - 1 do
    begin
      LColumn := LColumns[I];
      if LColumn.FixedStyle <> TThemedGridColumnFixedStyle.Left then
        Continue;
      LRight := LLeft + LColumn.Width;
      if (AX >= LLeft) and (AX < LRight) then
        Exit(I);
      LLeft := LRight;
    end;
  end;

  LFixedRight := GetFixedRightViewportBounds;
  if (AX >= LFixedRight.Left) and (AX < LFixedRight.Right) then
  begin
    LLeft := LFixedRight.Left;
    for I := 0 to LColumns.Count - 1 do
    begin
      LColumn := LColumns[I];
      if LColumn.FixedStyle <> TThemedGridColumnFixedStyle.Right then
        Continue;
      LRight := LLeft + LColumn.Width;
      if (AX >= LLeft) and (AX < LRight) then
        Exit(I);
      LLeft := LRight;
    end;
  end;

  LScrollable := GetScrollableViewportBounds;
  if (AX < LScrollable.Left) or (AX >= LScrollable.Right) then
    Exit(-1);
  LVirtualX := AX - LScrollable.Left + HorizontalOffset;
  LLeft := 0;
  for I := 0 to LColumns.Count - 1 do
  begin
    LColumn := LColumns[I];
    if LColumn.FixedStyle <> TThemedGridColumnFixedStyle.None then
      Continue;
    LRight := LLeft + LColumn.Width;
    if (LVirtualX >= LLeft) and (LVirtualX < LRight) then
      Exit(I);
    LLeft := LRight;
  end;
  Result := -1;
end;

function TThemedGridControlLayout.GetRowIndexAtY(const AY: Integer): Integer;
var
  LRowCount, LFirstTop, LVirtualY, LRowTop, LRowBottom: Integer;
begin
  if (AY < DataBounds.Top) or (AY >= DataBounds.Bottom) then
    Exit(-1);
  LRowCount := RowCount;
  if LRowCount <= 0 then
    Exit(-1);
  EnsureRowTopCache;
  LFirstTop := GetViewRowTop(FirstVisibleRowIndex);
  LVirtualY := LFirstTop + AY - DataBounds.Top;
  Result := GetRowIndexAtVirtualY(LVirtualY);
  if (Result < 0) or (Result >= LRowCount) then
    Exit(-1);
  LRowTop := GetViewRowTop(Result);
  LRowBottom := LRowTop + GetViewRowHeight(Result);
  if (LVirtualY < LRowTop) or (LVirtualY >= LRowBottom) then
    Result := -1;
end;

function TThemedGridControlLayout.GetColumnResizeGripIndex(const ALocation: TPoint): Integer;
var
  LColumns: TList<TThemedGridColumn>;
  I: Integer;
  LGrip: TRect;
begin
  if not ShowColumnHeaders then
    Exit(-1);
  if (ALocation.Y < HeaderBounds.Top) or (ALocation.Y >= HeaderBounds.Bottom) then
    Exit(-1);
  LColumns := GetVisibleColumns;
  for I := 0 to LColumns.Count - 1 do
  begin
    LGrip := GetColumnResizeGripBounds(I);
    if PtInRect(LGrip, ALocation) then
      Exit(I);
  end;
  Result := -1;
end;

function TThemedGridControlLayout.GetColumnResizeGripBounds(const AColumnIndex: Integer): TRect;
var
  LBounds: TRect;
  LLeft: Integer;
begin
  LBounds := GetHeaderCellBounds(AColumnIndex);
  if IsEmptyRect(LBounds) then
    Exit(EmptyRect);
  LLeft := LBounds.Right - ColumnResizeGripWidth div 2;
  Result := Rect(LLeft, LBounds.Top, LLeft + ColumnResizeGripWidth, LBounds.Bottom);
end;

procedure TThemedGridControlLayout.EnsureVisible(const ARowIndex: Integer);
begin
  EnsureVisible(ARowIndex, CurrentColumnIndex);
end;

procedure TThemedGridControlLayout.EnsureVisible(const ARowIndex, AColumnIndex: Integer);
var
  LRowIndex, LRowCount, LFirstTop, LRowTop, LRowBottom, LViewportHeight: Integer;
  LColumn: TThemedGridColumn;
  LScrollable, LBounds: TRect;
  LBoundsRow: Integer;
begin
  CalculateLayout;
  LRowIndex := ARowIndex;
  if LRowIndex >= 0 then
  begin
    EnsureRowTopCache;
    LRowCount := RowCount;
    if LRowCount > 0 then
    begin
      if LRowIndex >= LRowCount then
        LRowIndex := LRowCount - 1;
      LFirstTop := GetViewRowTop(FirstVisibleRowIndex);
      LRowTop := GetViewRowTop(LRowIndex);
      LRowBottom := LRowTop + GetViewRowHeight(LRowIndex);
      LViewportHeight := Max(0, DataBounds.Bottom - DataBounds.Top);
      if LRowTop < LFirstTop then
        FirstVisibleRowIndex := LRowIndex
      else if (LViewportHeight > 0) and (LRowBottom > LFirstTop + LViewportHeight) then
        FirstVisibleRowIndex := GetRowIndexAtVirtualY(LRowBottom - LViewportHeight);
    end;
  end;

  if AColumnIndex >= 0 then
  begin
    LColumn := GetColumn(AColumnIndex);
    if (LColumn <> nil) and (LColumn.FixedStyle = TThemedGridColumnFixedStyle.None) then
    begin
      LScrollable := GetScrollableViewportBounds;
      if LRowIndex >= 0 then
        LBoundsRow := LRowIndex
      else
        LBoundsRow := FirstVisibleRowIndex;
      LBounds := GetCellBounds(LBoundsRow, AColumnIndex);
      if LBounds.Left < LScrollable.Left then
        HorizontalOffset := HorizontalOffset - (LScrollable.Left - LBounds.Left);
      if LBounds.Right > LScrollable.Right then
        HorizontalOffset := HorizontalOffset + (LBounds.Right - LScrollable.Right);
    end;
  end;

  NormalizeScrollValues;
  Invalidate;
end;

end.

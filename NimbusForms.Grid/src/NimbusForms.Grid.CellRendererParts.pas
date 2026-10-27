unit NimbusForms.Grid.CellRendererParts;

{$SCOPEDENUMS ON}

interface

uses
  System.UITypes,
  Winapi.Windows,
  System.Types,
  System.Math,
  Vcl.Graphics,
  Winapi.GDIPOBJ,
  Winapi.GDIPAPI,
  NimbusForms.Theming.Types,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Cell,
  NimbusForms.Grid.HitInfo,
  NimbusForms.Grid.GdiCache,
  NimbusForms.Grid.FormatStyle,
  NimbusForms.Grid.RenderContext;

type
  TThemedGridCellRendererParts = class
  public
    class function GetFormatStyle(const ACell: TThemedGridCell): TThemedGridFormatStyle; static;
    class function GetCellBackColor(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell): TThemeColor; static;
    class function GetCellForeColor(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell): TThemeColor; static;
    class function GetCellBorderColor(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell): TThemeColor; static;
    class function GetCurrentBorderColor(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell): TThemeColor; static;
    class function GetCellFont(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell): TFont; static;
    class function RequiresDisposableFont(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell; const AFont: TFont): Boolean; static;
    class procedure FillCell(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell); static;
    class procedure DrawGridLines(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell); overload; static;
    class procedure DrawGridLines(const AContext: TThemedGridRenderContext; const ABounds: TRect); overload; static;
    class procedure DrawFocus(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell); static;
    class procedure DrawError(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell); static;
    class procedure DrawSearchHighlight(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell); static;
    class function GetContentBounds(const AContext: TThemedGridRenderContext; const ABounds: TRect): TRect; static;
    class function CreateCellHit(const ACell: TThemedGridCell; const ALocation: TPoint): TThemedGridHitInfo; static;
  end;

implementation

const
  CErrorColor = TThemeColor($FFF44747);

class function TThemedGridCellRendererParts.GetFormatStyle(const ACell: TThemedGridCell): TThemedGridFormatStyle;
begin
  Result := nil;
  if (ACell = nil) or (ACell.Metadata = nil) then
    Exit;
  if ACell.Metadata.Style.IsObject and (ACell.Metadata.Style.AsObject is TThemedGridFormatStyle) then
    Result := TThemedGridFormatStyle(ACell.Metadata.Style.AsObject);
end;

class function TThemedGridCellRendererParts.GetCellBackColor(const AContext: TThemedGridRenderContext;
  const ACell: TThemedGridCell): TThemeColor;
var
  LStyle: TThemedGridFormatStyle;
begin
  Result := AContext.BackColor;
  LStyle := GetFormatStyle(ACell);
  if (LStyle <> nil) and LStyle.HasBackColor then
    Result := LStyle.BackColor;
  if (ACell <> nil) and ACell.IsHovered then
  begin
    if (LStyle <> nil) and LStyle.HasHoverBackColor then
      Result := LStyle.HoverBackColor
    else
      Result := AContext.HoverBackColor;
  end;
  if (ACell <> nil) and ACell.IsSelected then
  begin
    if (LStyle <> nil) and LStyle.HasSelectionBackColor then
      Result := LStyle.SelectionBackColor
    else
      Result := AContext.SelectionBackColor;
  end;
end;

class function TThemedGridCellRendererParts.GetCellForeColor(const AContext: TThemedGridRenderContext;
  const ACell: TThemedGridCell): TThemeColor;
var
  LStyle: TThemedGridFormatStyle;
begin
  Result := AContext.ForeColor;
  LStyle := GetFormatStyle(ACell);
  if (LStyle <> nil) and LStyle.HasForeColor then
    Result := LStyle.ForeColor;
  if (ACell <> nil) and ACell.IsHovered then
    if (LStyle <> nil) and LStyle.HasHoverForeColor then
      Result := LStyle.HoverForeColor;
  if (ACell <> nil) and ACell.IsSelected then
  begin
    if (LStyle <> nil) and LStyle.HasSelectionForeColor then
      Result := LStyle.SelectionForeColor
    else
      Result := AContext.SelectionForeColor;
  end;
end;

class function TThemedGridCellRendererParts.GetCellBorderColor(const AContext: TThemedGridRenderContext;
  const ACell: TThemedGridCell): TThemeColor;
var
  LStyle: TThemedGridFormatStyle;
begin
  LStyle := GetFormatStyle(ACell);
  if (LStyle <> nil) and LStyle.HasBorderColor then
    Exit(LStyle.BorderColor);
  Result := AContext.GridLineColor;
end;

class function TThemedGridCellRendererParts.GetCurrentBorderColor(const AContext: TThemedGridRenderContext;
  const ACell: TThemedGridCell): TThemeColor;
var
  LStyle: TThemedGridFormatStyle;
begin
  LStyle := GetFormatStyle(ACell);
  if (LStyle <> nil) and LStyle.HasCurrentBorderColor then
    Exit(LStyle.CurrentBorderColor);
  Result := AContext.FocusColor;
end;

class function TThemedGridCellRendererParts.GetCellFont(const AContext: TThemedGridRenderContext;
  const ACell: TThemedGridCell): TFont;
var
  LStyle: TThemedGridFormatStyle;
  LFont: TFont;
begin
  Result := AContext.Font;
  if Result = nil then
    Exit;
  LStyle := GetFormatStyle(ACell);
  if (LStyle = nil) or (not LStyle.Bold and not LStyle.Italic) then
    Exit;
  LFont := TFont.Create;
  LFont.Assign(AContext.Font);
  if LStyle.Bold then
    LFont.Style := LFont.Style + [fsBold];
  if LStyle.Italic then
    LFont.Style := LFont.Style + [fsItalic];
  Result := LFont;
end;

class function TThemedGridCellRendererParts.RequiresDisposableFont(const AContext: TThemedGridRenderContext;
  const ACell: TThemedGridCell; const AFont: TFont): Boolean;
begin
  if (AContext = nil) or (AFont = nil) then
    Exit(False);
  Result := AContext.Font <> AFont;
end;

class procedure TThemedGridCellRendererParts.FillCell(const AContext: TThemedGridRenderContext;
  const ACell: TThemedGridCell);
var
  LBounds: TRect;
begin
  if (AContext = nil) or (AContext.Graphics = nil) or (ACell = nil) then
    Exit;
  LBounds := ACell.Bounds;
  AContext.Graphics.FillRectangle(TThemedGridGdiCache.Brush(GetCellBackColor(AContext, ACell)),
    LBounds.Left, LBounds.Top, LBounds.Width, LBounds.Height);
end;

class procedure TThemedGridCellRendererParts.DrawGridLines(const AContext: TThemedGridRenderContext;
  const ACell: TThemedGridCell);
var
  LBounds: TRect;
  LPen: TGPPen;
begin
  if (AContext = nil) or (AContext.Graphics = nil) or (ACell = nil) then
    Exit;
  LBounds := ACell.Bounds;
  LPen := TThemedGridGdiCache.Pen(GetCellBorderColor(AContext, ACell));
  AContext.Graphics.DrawLine(LPen, LBounds.Left, LBounds.Bottom - 1, LBounds.Right, LBounds.Bottom - 1);
  AContext.Graphics.DrawLine(LPen, LBounds.Right - 1, LBounds.Top, LBounds.Right - 1, LBounds.Bottom);
end;

class procedure TThemedGridCellRendererParts.DrawGridLines(const AContext: TThemedGridRenderContext;
  const ABounds: TRect);
var
  LPen: TGPPen;
begin
  if (AContext = nil) or (AContext.Graphics = nil) then
    Exit;
  LPen := TThemedGridGdiCache.Pen(AContext.GridLineColor);
  AContext.Graphics.DrawLine(LPen, ABounds.Left, ABounds.Bottom - 1, ABounds.Right, ABounds.Bottom - 1);
  AContext.Graphics.DrawLine(LPen, ABounds.Right - 1, ABounds.Top, ABounds.Right - 1, ABounds.Bottom);
end;

class procedure TThemedGridCellRendererParts.DrawFocus(const AContext: TThemedGridRenderContext;
  const ACell: TThemedGridCell);
var
  LFocus: TRect;
  LInset: Integer;
begin
  if (AContext = nil) or (AContext.Graphics = nil) or (ACell = nil) then
    Exit;
  if not ACell.IsCurrent then
    Exit;
  LInset := AContext.Metrics.FocusInset;
  LFocus := ACell.Bounds;
  LFocus.Inflate(-LInset, -LInset);
  AContext.Graphics.DrawRectangle(TThemedGridGdiCache.Pen(GetCurrentBorderColor(AContext, ACell)),
    LFocus.Left, LFocus.Top, LFocus.Width - 1, LFocus.Height - 1);
end;

class procedure TThemedGridCellRendererParts.DrawError(const AContext: TThemedGridRenderContext;
  const ACell: TThemedGridCell);
var
  LBounds: TRect;
  LTriangle: array[0..2] of TGPPoint;
begin
  if (AContext = nil) or (AContext.Graphics = nil) or (ACell = nil) then
    Exit;
  if not (TThemedGridCellStateFlag.Error in ACell.State) then
    Exit;
  LBounds := ACell.Bounds;
  AContext.Graphics.DrawRectangle(TThemedGridGdiCache.Pen(CErrorColor),
    LBounds.Left, LBounds.Top, LBounds.Width - 1, LBounds.Height - 1);
  LTriangle[0] := MakePoint(LBounds.Right - 9, LBounds.Top);
  LTriangle[1] := MakePoint(LBounds.Right - 1, LBounds.Top);
  LTriangle[2] := MakePoint(LBounds.Right - 1, LBounds.Top + 8);
  AContext.Graphics.FillPolygon(TThemedGridGdiCache.Brush(CErrorColor), PGPPoint(@LTriangle[0]), 3);
end;

class procedure TThemedGridCellRendererParts.DrawSearchHighlight(const AContext: TThemedGridRenderContext;
  const ACell: TThemedGridCell);
var
  LBounds: TRect;
  LColor: TThemeColor;
begin
  if (AContext = nil) or (AContext.Graphics = nil) or (ACell = nil) then
    Exit;
  if (ACell.SearchMatches = nil) or (ACell.SearchMatches.Count = 0) then
    Exit;
  LBounds := GetContentBounds(AContext, ACell.Bounds);
  if (LBounds.Width <= 0) or (LBounds.Height <= 0) then
    Exit;
  if ACell.IsSelected then
    LColor := ThemeColor(70, 255, 230, 80)
  else
    LColor := ThemeColor(90, 255, 230, 80);
  AContext.Graphics.FillRectangle(TThemedGridGdiCache.Brush(LColor),
    LBounds.Left, LBounds.Top, LBounds.Width, LBounds.Height);
end;

class function TThemedGridCellRendererParts.GetContentBounds(const AContext: TThemedGridRenderContext;
  const ABounds: TRect): TRect;
begin
  Result := TRect.Create(
    ABounds.Left + AContext.Metrics.CellPadding.Left,
    ABounds.Top + AContext.Metrics.CellPadding.Top,
    ABounds.Right - AContext.Metrics.CellPadding.Right,
    ABounds.Bottom - AContext.Metrics.CellPadding.Bottom);
end;

class function TThemedGridCellRendererParts.CreateCellHit(const ACell: TThemedGridCell;
  const ALocation: TPoint): TThemedGridHitInfo;
begin
  Result := TThemedGridHitInfo.Create;
  Result.HitArea := TThemedGridHitArea.Cell;
  Result.Location := ALocation;
  if ACell <> nil then
  begin
    Result.RowIndex := ACell.RowIndex;
    Result.ColumnIndex := ACell.ColumnIndex;
    Result.DataSourceIndex := ACell.DataSourceIndex;
    Result.Column := ACell.Column;
    Result.Row := ACell.Row;
    Result.Cell := ACell;
    Result.Bounds := ACell.Bounds;
  end;
end;

end.

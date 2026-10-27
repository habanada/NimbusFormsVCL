unit NimbusForms.HexEditor.Renderers;

interface

uses
  System.SysUtils,
  System.Math,
  System.Types,
  Vcl.Graphics,
  NimbusForms.Theming.Types,
  NimbusForms.HexEditor.Types,
  NimbusForms.HexEditor.Strings,
  NimbusForms.HexEditor.Options,
  NimbusForms.HexEditor.Theme,
  NimbusForms.HexEditor.DataSource,
  NimbusForms.HexEditor.Bookmarks,
  NimbusForms.HexEditor.Search,
  NimbusForms.HexEditor.RenderContext;

type
  THexCaretRenderer = class
  public
    procedure Render(const AContext: THexRenderContext; const ABounds: TRect; const AAscii: Boolean);
  end;

  THexCellRenderer = class
  private
    FCaretRenderer: THexCaretRenderer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RenderByteCell(const AContext: THexRenderContext; const ABounds, AFillBounds: TRect;
      const AText: string; const ABackColor, AForeColor: TThemeColor;
      const ACursor, AAscii: Boolean);
    procedure RenderBookmarkGlyph(const AContext: THexRenderContext; const ABounds: TRect;
      const AColor: TThemeColor);
    procedure RenderEmptyCell(const AContext: THexRenderContext; const ABounds: TRect);
  end;

  THexGutterRenderer = class
  public
    procedure Render(const AContext: THexRenderContext; const AMetrics: THexRenderMetrics;
      const ARowOffset: Int64; const AY: Integer);
  end;

  THexHeaderRenderer = class
  public
    procedure Render(const AContext: THexRenderContext; const AMetrics: THexRenderMetrics);
  end;

  THexRenderer = class
  private
    FHeaderRenderer: THexHeaderRenderer;
    FGutterRenderer: THexGutterRenderer;
    FCellRenderer: THexCellRenderer;
    procedure RenderRows(const AContext: THexRenderContext; const AMetrics: THexRenderMetrics);
    procedure RenderRow(const AContext: THexRenderContext; const AMetrics: THexRenderMetrics;
      const ARowOffset: Int64; const ARowBuffer: TBytes; const ARead, AY: Integer);
    procedure RenderEmptyText(const AContext: THexRenderContext; const AMetrics: THexRenderMetrics);
    procedure RenderBorder(const AContext: THexRenderContext);
  public
    constructor Create;
    destructor Destroy; override;
    function Measure(const AContext: THexRenderContext): THexRenderMetrics;
    function MeasureContentWidth(const AContext: THexRenderContext): Integer;
    function MeasureRowHeight(const AContext: THexRenderContext): Integer;
    procedure Render(const AContext: THexRenderContext);
  end;

implementation

const
  CMinimumRowHeight = 18;
  CHorizontalPadding = 8;
  CHeaderPadding = 4;

type
  THexLineBreakKind = (lbkNone, lbkCarriageReturn, lbkLineFeed,
    lbkCarriageReturnLineFeedStart, lbkCarriageReturnLineFeedEnd);

function IsControlByte(const AValue: Byte): Boolean;
begin
  Result := (AValue < 32) and (AValue <> 9) and (AValue <> 10) and (AValue <> 13);
end;

function GetAsciiChar(const AValue: Byte): Char;
begin
  if (AValue >= 32) and (AValue <= 126) then
    Result := Char(AValue)
  else
    Result := '.';
end;

function ResolveBookmarkColor(const AContext: THexRenderContext;
  const ABookmark: THexBookmark): TThemeColor;
begin
  if (ABookmark = nil) or (not ABookmark.HasColor) then
    Result := AContext.Theme.BookmarkColor
  else
    Result := ABookmark.Color;
end;

{ THexCaretRenderer }

procedure THexCaretRenderer.Render(const AContext: THexRenderContext;
  const ABounds: TRect; const AAscii: Boolean);
var
  LHalfWidth, LX, LY: Integer;
  LCaret: TRect;
begin
  if (AContext = nil) or (AContext.Surface = nil) or (not AContext.Focused) then
    Exit;

  if AContext.InsertMode then
  begin
    LY := ABounds.Bottom - 3;
    AContext.Surface.DrawLine(AContext.Theme.CaretColor, ABounds.Left + 1, LY, ABounds.Right - 2, LY);
    AContext.Surface.DrawLine(AContext.Theme.CaretColor, ABounds.Left + 1, LY - 1, ABounds.Right - 2, LY - 1);
    Exit;
  end;

  if AAscii then
  begin
    LX := ABounds.Left + 1;
    AContext.Surface.DrawLine(AContext.Theme.CaretColor, LX, ABounds.Top + 3, LX, ABounds.Bottom - 4);
    Exit;
  end;

  LHalfWidth := Max(2, (ABounds.Right - ABounds.Left) div 2);
  if AContext.IsHighNibble then
    LCaret := Rect(ABounds.Left, ABounds.Top + 1, ABounds.Left + LHalfWidth,
      ABounds.Top + 1 + Max(1, (ABounds.Bottom - ABounds.Top) - 3))
  else
    LCaret := Rect(ABounds.Left + LHalfWidth, ABounds.Top + 1,
      ABounds.Left + LHalfWidth + Max(2, (ABounds.Right - ABounds.Left) - LHalfWidth - 1),
      ABounds.Top + 1 + Max(1, (ABounds.Bottom - ABounds.Top) - 3));
  AContext.Surface.DrawRectangle(AContext.Theme.CaretColor, LCaret);
end;

{ THexCellRenderer }

constructor THexCellRenderer.Create;
begin
  inherited Create;
  FCaretRenderer := THexCaretRenderer.Create;
end;

destructor THexCellRenderer.Destroy;
begin
  FCaretRenderer.Free;
  inherited Destroy;
end;

procedure THexCellRenderer.RenderByteCell(const AContext: THexRenderContext;
  const ABounds, AFillBounds: TRect; const AText: string; const ABackColor, AForeColor: TThemeColor;
  const ACursor, AAscii: Boolean);
var
  LFore: TThemeColor;
begin
  if (AContext = nil) or (AContext.Surface = nil) then
    Exit;
  LFore := AForeColor;
  if not AContext.Enabled then
    LFore := AContext.Theme.DisabledForeColor;
  AContext.Surface.FillRectangle(ABackColor, AFillBounds);
  AContext.Surface.DrawText(AText, ABounds, LFore, [htfVCenter, htfLeft, htfNoPadding]);
  if ACursor then
    FCaretRenderer.Render(AContext, ABounds, AAscii);
end;

procedure THexCellRenderer.RenderBookmarkGlyph(const AContext: THexRenderContext;
  const ABounds: TRect; const AColor: TThemeColor);
var
  LSize: Integer;
  LGlyph: TRect;
begin
  if (AContext = nil) or (AContext.Surface = nil) then
    Exit;
  LSize := 7;
  LGlyph := Rect(ABounds.Right - LSize - 2, ABounds.Top + 2, ABounds.Right - 2, ABounds.Top + 2 + LSize);
  AContext.Surface.FillTriangle(AColor,
    Point(LGlyph.Left, LGlyph.Top),
    Point(LGlyph.Right, LGlyph.Top),
    Point(LGlyph.Right, LGlyph.Bottom));
end;

procedure THexCellRenderer.RenderEmptyCell(const AContext: THexRenderContext;
  const ABounds: TRect);
begin
  if (AContext = nil) or (AContext.Surface = nil) then
    Exit;
  AContext.Surface.FillRectangle(AContext.Theme.EofBackColor, ABounds);
end;

{ THexGutterRenderer }

function FormatOffset(const AOffset: Int64; const AFormat: THexOffsetFormat): string;
begin
  case AFormat of
    hofDecimal: Result := IntToStr(AOffset);
    hofHex16: Result := IntToHex(AOffset, 16);
  else
    Result := IntToHex(AOffset, 8);
  end;
end;

procedure THexGutterRenderer.Render(const AContext: THexRenderContext;
  const AMetrics: THexRenderMetrics; const ARowOffset: Int64; const AY: Integer);
var
  LGutter, LMarker, LCountBounds, LTextBounds: TRect;
  LFirst, LBookmark: THexBookmark;
  LCount: Integer;
  LColor: TThemeColor;
  LRowEnd: Int64;
begin
  if (AContext = nil) or (AContext.Surface = nil) or (AContext.Options = nil) or
     (not AContext.Options.ShowGutter) then
    Exit;

  LGutter := Rect(AContext.Bounds.Left, AY, AContext.Bounds.Left + AMetrics.GutterWidth, AY + AMetrics.RowHeight);
  AContext.Surface.FillRectangle(AContext.Theme.GutterBackColor, LGutter);

  LFirst := nil;
  LCount := 0;
  if AContext.Options.ShowBookmarks and (AContext.Bookmarks <> nil) then
  begin
    LRowEnd := ARowOffset + AContext.Options.BytesPerRow;
    for LBookmark in AContext.Bookmarks.Values do
    begin
      if LBookmark = nil then
        Continue;
      if (LBookmark.Offset >= ARowOffset) and (LBookmark.Offset < LRowEnd) then
      begin
        if LFirst = nil then
          LFirst := LBookmark;
        Inc(LCount);
      end;
    end;
  end;

  if LFirst <> nil then
  begin
    LColor := ResolveBookmarkColor(AContext, LFirst);
    LMarker := Rect(4, AY + 4, 13, AY + 4 + Max(8, AMetrics.RowHeight - 8));
    AContext.Surface.FillRoundedRectangle(LColor, LMarker, 3);
    if LCount > 1 then
    begin
      LCountBounds := Rect(0, AY, 18, AY + AMetrics.RowHeight);
      AContext.Surface.DrawText(IntToStr(LCount), LCountBounds, AContext.Theme.SelectionForeColor,
        [htfHCenter, htfVCenter, htfNoPadding]);
    end;
  end;

  LTextBounds := Rect(18, AY, 18 + AMetrics.GutterWidth - 22, AY + AMetrics.RowHeight);
  AContext.Surface.DrawText(FormatOffset(ARowOffset, AContext.Options.OffsetFormat),
    LTextBounds, AContext.Theme.GutterForeColor, [htfVCenter, htfRight, htfNoPadding]);
end;

{ THexHeaderRenderer }

function GetActiveColumn(const AContext: THexRenderContext): Integer;
begin
  if (AContext = nil) or (AContext.CursorOffset < 0) or (AContext.Options = nil) or
     (AContext.Options.BytesPerRow <= 0) then
    Exit(-1);
  Result := Integer(AContext.CursorOffset mod AContext.Options.BytesPerRow);
end;

procedure THexHeaderRenderer.Render(const AContext: THexRenderContext;
  const AMetrics: THexRenderMetrics);
var
  LHeader, LCell, LScrollClip, LAscii, LActiveAscii: TRect;
  LGroupSize, LActiveColumn, I, LActiveAsciiX: Integer;
begin
  if (AContext = nil) or (AContext.Surface = nil) or (AContext.Options = nil) or
     (not AContext.Options.ShowHeader) then
    Exit;

  LHeader := Rect(AContext.Bounds.Left, AContext.Bounds.Top,
    AContext.Bounds.Right, AContext.Bounds.Top + AMetrics.HeaderHeight);
  AContext.Surface.FillRectangle(AContext.Theme.HeaderBackColor, LHeader);
  AContext.Surface.DrawLine(AContext.Theme.GridLineColor, LHeader.Left, LHeader.Bottom - 1,
    LHeader.Right, LHeader.Bottom - 1);

  AContext.Surface.DrawText(HexEditorTexts.OffsetHeader,
    Rect(CHeaderPadding, LHeader.Top, CHeaderPadding + AMetrics.GutterWidth - CHeaderPadding, LHeader.Bottom),
    AContext.Theme.HeaderForeColor, [htfVCenter, htfLeft, htfNoPadding]);

  LScrollClip := Rect(AMetrics.GutterWidth, LHeader.Top,
    AMetrics.GutterWidth + Max(0, (LHeader.Right - LHeader.Left) - AMetrics.GutterWidth), LHeader.Bottom);
  AContext.Surface.PushClip(LScrollClip);
  try
    if AContext.Options.ShowByteGroups then
      LGroupSize := AContext.Options.ByteGroupSize
    else
      LGroupSize := AContext.Options.BytesPerRow + 1;
    LActiveColumn := GetActiveColumn(AContext);

    for I := 0 to AContext.Options.BytesPerRow - 1 do
    begin
      LCell := Rect(AMetrics.GetHexCellX(I, LGroupSize), LHeader.Top,
        AMetrics.GetHexCellX(I, LGroupSize) + AMetrics.CellWidth, LHeader.Bottom);
      if (LCell.Right >= LScrollClip.Left) and (LCell.Left <= LScrollClip.Right) then
      begin
        if AContext.Options.ShowActiveHeaderHighlight and (LActiveColumn = I) and
           (AContext.ActiveEditArea <> hhaAsciiCell) then
          AContext.Surface.FillRectangle(AContext.Theme.ActiveHeaderBackColor, LCell);
        AContext.Surface.DrawText(IntToHex(I, 2), LCell, AContext.Theme.HeaderForeColor,
          [htfVCenter, htfLeft, htfNoPadding]);
      end;
    end;

    if AContext.Options.ShowAscii then
    begin
      LAscii := Rect(AMetrics.AsciiStartX, LHeader.Top, AContext.Bounds.Right, LHeader.Bottom);
      if (LAscii.Right >= LScrollClip.Left) and (LAscii.Left <= LScrollClip.Right) then
      begin
        if AContext.Options.ShowActiveHeaderHighlight and (AContext.ActiveEditArea = hhaAsciiCell) then
        begin
          LActiveAsciiX := AMetrics.GetAsciiCellX(LActiveColumn);
          LActiveAscii := Rect(LActiveAsciiX, LHeader.Top,
            LActiveAsciiX + Max(AMetrics.AsciiCellWidth, AMetrics.CharWidth), LHeader.Bottom);
          AContext.Surface.FillRectangle(AContext.Theme.ActiveHeaderBackColor, LActiveAscii);
        end;
        AContext.Surface.DrawText(HexEditorTexts.AsciiHeader, LAscii, AContext.Theme.HeaderForeColor,
          [htfVCenter, htfLeft, htfNoPadding]);
      end;
    end;
  finally
    AContext.Surface.PopClip;
  end;
end;

{ THexRenderer }

constructor THexRenderer.Create;
begin
  inherited Create;
  FHeaderRenderer := THexHeaderRenderer.Create;
  FGutterRenderer := THexGutterRenderer.Create;
  FCellRenderer := THexCellRenderer.Create;
end;

destructor THexRenderer.Destroy;
begin
  FCellRenderer.Free;
  FGutterRenderer.Free;
  FHeaderRenderer.Free;
  inherited Destroy;
end;

function GetEffectiveByteGroupSize(const AContext: THexRenderContext): Integer;
begin
  if (AContext = nil) or (AContext.Options = nil) or (not AContext.Options.ShowByteGroups) then
    Exit(MaxInt);
  if AContext.Options.ByteGroupSize < 1 then
    Exit(1);
  Result := AContext.Options.ByteGroupSize;
end;

function GetGutterWidth(const AContext: THexRenderContext; const ACharWidth: Integer): Integer;
begin
  if not AContext.Options.ShowGutter then
    Exit(CHorizontalPadding);
  if AContext.Options.OffsetFormat = hofHex16 then
    Exit(Max(128, ACharWidth * 18));
  if AContext.Options.OffsetFormat = hofDecimal then
    Exit(Max(96, ACharWidth * 14));
  Result := Max(72, ACharWidth * 10);
end;

function THexRenderer.Measure(const AContext: THexRenderContext): THexRenderMetrics;
var
  LTextSize: TSize;
  LCharWidth, LRowHeight, LHeaderHeight, LGutterWidth, LCellWidth, LAsciiCellWidth: Integer;
  LGroupSize, LGroupCount, LByteGroupSpacing, LHexContentWidth, LHexStartX, LAsciiStartX: Integer;
begin
  if AContext = nil then
    raise EArgumentNilException.Create('context');

  LTextSize := AContext.Surface.MeasureText('FF');
  LCharWidth := Max(1, AContext.Surface.MeasureText('0').cx - 1);
  LRowHeight := Max(CMinimumRowHeight, LTextSize.cy + 4);
  if AContext.Options.ShowHeader then
    LHeaderHeight := LRowHeight + 2
  else
    LHeaderHeight := 0;
  LGutterWidth := GetGutterWidth(AContext, LCharWidth);
  LCellWidth := Max(20, LCharWidth * 3);
  if AContext.Options.ShowSpecialByteLabels then
    LAsciiCellWidth := Max(LCharWidth * 2 + 4, 16)
  else
    LAsciiCellWidth := Max(LCharWidth, 8);
  LGroupSize := GetEffectiveByteGroupSize(AContext);
  if AContext.Options.ShowByteGroups then
    LGroupCount := Max(0, (AContext.Options.BytesPerRow - 1) div LGroupSize)
  else
    LGroupCount := 0;
  if AContext.Options.ShowByteGroups then
    LByteGroupSpacing := Max(4, LCharWidth)
  else
    LByteGroupSpacing := 0;
  LHexContentWidth := AContext.Options.BytesPerRow * LCellWidth + LGroupCount * LByteGroupSpacing;
  LHexStartX := LGutterWidth + CHorizontalPadding - AContext.HorizontalScrollValue;
  LAsciiStartX := LHexStartX + LHexContentWidth + LCharWidth * 2;

  Result := THexRenderMetrics.Create;
  Result.HeaderHeight := LHeaderHeight;
  Result.RowHeight := LRowHeight;
  Result.GutterWidth := LGutterWidth;
  Result.HexStartX := LHexStartX;
  Result.AsciiStartX := LAsciiStartX;
  Result.CellWidth := LCellWidth;
  Result.AsciiCellWidth := LAsciiCellWidth;
  Result.ByteGroupWidth := LCellWidth;
  Result.ByteGroupSpacing := LByteGroupSpacing;
  Result.CharWidth := LCharWidth;
  Result.HexContentWidth := LHexContentWidth;
  Result.ContentBounds := Rect(AContext.Bounds.Left, AContext.Bounds.Top + LHeaderHeight,
    AContext.Bounds.Right, AContext.Bounds.Top + LHeaderHeight +
    Max(0, (AContext.Bounds.Bottom - AContext.Bounds.Top) - LHeaderHeight));
end;

function THexRenderer.MeasureContentWidth(const AContext: THexRenderContext): Integer;
var
  LMetrics: THexRenderMetrics;
  LGutterWidth, LAsciiWidth: Integer;
begin
  LMetrics := Measure(AContext);
  try
    if AContext.Options.ShowGutter then
      LGutterWidth := LMetrics.GutterWidth
    else
      LGutterWidth := CHorizontalPadding;
    if AContext.Options.ShowAscii then
      LAsciiWidth := AContext.Options.BytesPerRow * LMetrics.AsciiCellWidth + LMetrics.CharWidth * 2
    else
      LAsciiWidth := 0;
    Result := LGutterWidth + CHorizontalPadding + LMetrics.HexContentWidth + LAsciiWidth + CHorizontalPadding;
  finally
    LMetrics.Free;
  end;
end;

function THexRenderer.MeasureRowHeight(const AContext: THexRenderContext): Integer;
var
  LMetrics: THexRenderMetrics;
begin
  LMetrics := Measure(AContext);
  try
    Result := LMetrics.RowHeight;
  finally
    LMetrics.Free;
  end;
end;

procedure THexRenderer.Render(const AContext: THexRenderContext);
var
  LMetrics: THexRenderMetrics;
begin
  if (AContext = nil) or (AContext.Surface = nil) then
    Exit;
  LMetrics := Measure(AContext);
  try
    AContext.Surface.FillRectangle(AContext.Theme.BackColor, AContext.Bounds);
    FHeaderRenderer.Render(AContext, LMetrics);
    RenderRows(AContext, LMetrics);
    RenderBorder(AContext);
  finally
    LMetrics.Free;
  end;
end;

procedure THexRenderer.RenderRows(const AContext: THexRenderContext;
  const AMetrics: THexRenderMetrics);
var
  LRowCount, LRow, LCount, LRead, LY: Integer;
  LRowOffset: Int64;
  LRowBuffer: TBytes;
begin
  if (AContext.DataSource = nil) or (AContext.DataSource.Length <= 0) then
  begin
    RenderEmptyText(AContext, AMetrics);
    Exit;
  end;

  LRowCount := Max(0, (AMetrics.ContentBounds.Bottom - AMetrics.ContentBounds.Top) div AMetrics.RowHeight + 1);
  SetLength(LRowBuffer, AContext.Options.BytesPerRow);

  for LRow := 0 to LRowCount - 1 do
  begin
    LRowOffset := AContext.FirstVisibleOffset + Int64(LRow) * AContext.Options.BytesPerRow;
    if LRowOffset >= AContext.DataSource.Length then
      Break;
    LCount := Integer(Min(Int64(AContext.Options.BytesPerRow), AContext.DataSource.Length - LRowOffset));
    LRead := AContext.DataSource.Read(LRowOffset, LRowBuffer, LCount);
    if LRead <= 0 then
      Break;
    LY := AMetrics.ContentBounds.Top + LRow * AMetrics.RowHeight;
    RenderRow(AContext, AMetrics, LRowOffset, LRowBuffer, LRead, LY);
  end;
end;

function TryReadByte(const AContext: THexRenderContext; const ARowOffset: Int64;
  const ARowBuffer: TBytes; const AIndex, ARead: Integer; out AValue: Byte): Boolean;
var
  LOffset: Int64;
  LBuffer: TBytes;
begin
  AValue := 0;
  if (ARowBuffer <> nil) and (AIndex >= 0) and (AIndex < ARead) then
  begin
    AValue := ARowBuffer[AIndex];
    Exit(True);
  end;
  if (AContext = nil) or (AContext.DataSource = nil) then
    Exit(False);
  LOffset := ARowOffset + AIndex;
  if (LOffset < 0) or (LOffset >= AContext.DataSource.Length) then
    Exit(False);
  SetLength(LBuffer, 1);
  if AContext.DataSource.Read(LOffset, LBuffer, 1) <> 1 then
    Exit(False);
  AValue := LBuffer[0];
  Result := True;
end;

function GetLineBreakKind(const AContext: THexRenderContext; const ARowOffset: Int64;
  const ARowBuffer: TBytes; const AIndex, ARead: Integer): THexLineBreakKind;
var
  LValue, LNext, LPrev: Byte;
begin
  if (ARowBuffer = nil) or (AIndex < 0) or (AIndex >= ARead) then
    Exit(lbkNone);
  LValue := ARowBuffer[AIndex];
  if LValue = 13 then
  begin
    if TryReadByte(AContext, ARowOffset, ARowBuffer, AIndex + 1, ARead, LNext) and (LNext = 10) then
      Exit(lbkCarriageReturnLineFeedStart);
    Exit(lbkCarriageReturn);
  end;
  if LValue = 10 then
  begin
    if TryReadByte(AContext, ARowOffset, ARowBuffer, AIndex - 1, ARead, LPrev) and (LPrev = 13) then
      Exit(lbkCarriageReturnLineFeedEnd);
    Exit(lbkLineFeed);
  end;
  Result := lbkNone;
end;

function GetAsciiText(const AContext: THexRenderContext; const AValue: Byte;
  const ALineBreakKind: THexLineBreakKind): string;
begin
  if (AContext = nil) or (AContext.Options = nil) or (not AContext.Options.ShowSpecialByteLabels) then
    Exit(GetAsciiChar(AValue));
  if (ALineBreakKind = lbkCarriageReturn) or (ALineBreakKind = lbkCarriageReturnLineFeedStart) then
    Exit(HexEditorTexts.SpecialByteCarriageReturn);
  if (ALineBreakKind = lbkLineFeed) or (ALineBreakKind = lbkCarriageReturnLineFeedEnd) then
    Exit(HexEditorTexts.SpecialByteLineFeed);
  if AValue = 9 then
    Exit(HexEditorTexts.SpecialByteTab);
  if AValue = 32 then
    Exit(HexEditorTexts.SpecialByteSpace);
  if AValue = 0 then
    Exit(HexEditorTexts.SpecialByteNull);
  if IsControlByte(AValue) then
    Exit(HexEditorTexts.SpecialByteControl);
  Result := GetAsciiChar(AValue);
end;

function GetRowBackColor(const AContext: THexRenderContext; const ARowOffset: Int64): TThemeColor;
var
  LRowIndex: Int64;
begin
  if AContext.Options.ShowCursorRowHighlight and (AContext.CursorOffset >= ARowOffset) and
     (AContext.CursorOffset < ARowOffset + AContext.Options.BytesPerRow) then
    Exit(AContext.Theme.CursorRowBackColor);
  if AContext.Options.ShowAlternateRows then
  begin
    LRowIndex := ARowOffset div AContext.Options.BytesPerRow;
    if (LRowIndex and Int64(1)) = Int64(1) then
      Exit(AContext.Theme.AlternateRowBackColor);
  end;
  Result := AContext.Theme.CellBackColor;
end;

function GetByteBackColor(const AContext: THexRenderContext; const ARowBackColor: TThemeColor;
  const AValue: Byte; const ASelected, AHighlighted, AActiveColumn, AModified, ALineBreak,
  AHover: Boolean): TThemeColor;
begin
  if ASelected then
    Exit(AContext.Theme.SelectionBackColor);
  if AHighlighted then
    Exit(AContext.Theme.SearchHighlightBackColor);
  if AModified then
    Exit(AContext.Theme.ModifiedByteBackColor);
  if ALineBreak then
    Exit(AContext.Theme.LineBreakBackColor);
  if AHover then
    Exit(AContext.Theme.ActiveHeaderBackColor);
  if AContext.Options.HighlightControlByteBackground and IsControlByte(AValue) then
    Exit(AContext.Theme.ControlByteBackColor);
  if AActiveColumn then
    Exit(AContext.Theme.ActiveColumnBackColor);
  Result := ARowBackColor;
end;

function GetByteForeColor(const AContext: THexRenderContext; const AValue: Byte;
  const ASelected, AHighlighted, AAscii, AModified, ALineBreak: Boolean): TThemeColor;
begin
  if ASelected then
    Exit(AContext.Theme.SelectionForeColor);
  if AHighlighted then
    Exit(AContext.Theme.SearchHighlightForeColor);
  if AModified then
    Exit(AContext.Theme.ModifiedByteForeColor);
  if ALineBreak then
    Exit(AContext.Theme.LineBreakForeColor);
  if AContext.Options.HighlightTabs and (AValue = 9) then
    Exit(AContext.Theme.TabColor);
  if AContext.Options.HighlightSpaces and (AValue = 32) then
    Exit(AContext.Theme.SpaceColor);
  if AContext.Options.HighlightNullBytes and (AValue = 0) then
    Exit(AContext.Theme.NullByteColor);
  if AAscii then
    Result := AContext.Theme.AsciiForeColor
  else
    Result := AContext.Theme.CellForeColor;
end;

function IsAdvancedSearchHighlighted(const AContext: THexRenderContext; const AOffset: Int64): Boolean;
var
  I: Integer;
  LMatch: THexSearchMatch;
begin
  if (AContext = nil) or (AContext.AdvancedSearchMatches = nil) or
     (AContext.AdvancedSearchMatches.Count = 0) then
    Exit(False);
  for I := 0 to AContext.AdvancedSearchMatches.Count - 1 do
  begin
    LMatch := AContext.AdvancedSearchMatches[I];
    if (LMatch <> nil) and LMatch.Contains(AOffset) then
      Exit(True);
  end;
  Result := False;
end;

function GetBookmark(const AContext: THexRenderContext; const AOffset: Int64): THexBookmark;
var
  LBookmark: THexBookmark;
begin
  if (AContext = nil) or (AContext.Bookmarks = nil) or (not AContext.Options.ShowBookmarks) then
    Exit(nil);
  if AContext.Bookmarks.TryGet(AOffset, LBookmark) then
    Exit(LBookmark);
  Result := nil;
end;

procedure THexRenderer.RenderRow(const AContext: THexRenderContext;
  const AMetrics: THexRenderMetrics; const ARowOffset: Int64; const ARowBuffer: TBytes;
  const ARead, AY: Integer);
var
  LRowBounds, LScrollClip, LHexBounds, LHexFillBounds, LAsciiBounds, LEofAscii: TRect;
  LRowBackColor, LHexBack, LHexFore, LAsciiBack, LAsciiFore: TThemeColor;
  LGroupSize, LActiveColumn, I: Integer;
  LOffset: Int64;
  LValue: Byte;
  LLineBreakKind: THexLineBreakKind;
  LSelected, LBasic, LAdvanced, LHighlighted, LActiveCol, LModified, LLineBreak, LHover: Boolean;
  LNextSelected: Boolean;
  LHexCursor, LAsciiCursor: Boolean;
  LBookmark: THexBookmark;
  LAsciiText: string;
begin
  LRowBounds := Rect(AContext.Bounds.Left, AY, AContext.Bounds.Right, AY + AMetrics.RowHeight);
  LRowBackColor := GetRowBackColor(AContext, ARowOffset);
  AContext.Surface.FillRectangle(LRowBackColor, LRowBounds);
  FGutterRenderer.Render(AContext, AMetrics, ARowOffset, AY);

  LScrollClip := Rect(AMetrics.GutterWidth, AY,
    AMetrics.GutterWidth + Max(0, (AContext.Bounds.Right - AContext.Bounds.Left) - AMetrics.GutterWidth),
    AY + AMetrics.RowHeight);
  AContext.Surface.PushClip(LScrollClip);
  try
    LGroupSize := GetEffectiveByteGroupSize(AContext);
    LActiveColumn := GetActiveColumn(AContext);

    for I := 0 to AContext.Options.BytesPerRow - 1 do
    begin
      LOffset := ARowOffset + I;
      LHexBounds := Rect(AMetrics.GetHexCellX(I, LGroupSize), AY,
        AMetrics.GetHexCellX(I, LGroupSize) + AMetrics.CellWidth, AY + AMetrics.RowHeight);

      if I >= ARead then
      begin
        if AContext.Options.ShowEofShade and (LHexBounds.Right >= LScrollClip.Left) and
           (LHexBounds.Left <= LScrollClip.Right) then
          FCellRenderer.RenderEmptyCell(AContext, LHexBounds);
        if AContext.Options.ShowAscii then
        begin
          LEofAscii := Rect(AMetrics.GetAsciiCellX(I), AY,
            AMetrics.GetAsciiCellX(I) + AMetrics.AsciiCellWidth, AY + AMetrics.RowHeight);
          if (LEofAscii.Right >= LScrollClip.Left) and (LEofAscii.Left <= LScrollClip.Right) then
            FCellRenderer.RenderEmptyCell(AContext, LEofAscii);
        end;
        Continue;
      end;

      LValue := ARowBuffer[I];
      LLineBreakKind := GetLineBreakKind(AContext, ARowOffset, ARowBuffer, I, ARead);
      LSelected := (AContext.Selection <> nil) and AContext.Selection.Contains(LOffset);
      LBasic := (AContext.ActiveSearchMatch <> nil) and AContext.ActiveSearchMatch.Contains(LOffset);
      LAdvanced := IsAdvancedSearchHighlighted(AContext, LOffset);
      LHighlighted := LBasic or LAdvanced;
      LActiveCol := AContext.Options.ShowActiveColumnHighlight and (LActiveColumn = I);
      LModified := AContext.Options.ShowModifiedByteHighlight and (AContext.ModifiedOffsets <> nil) and
        AContext.ModifiedOffsets.ContainsKey(LOffset);
      LLineBreak := AContext.Options.HighlightLineBreaks and (LLineBreakKind <> lbkNone);
      LHover := AContext.Options.ShowHoverHighlight and (AContext.HoverOffset = LOffset);
      LHexCursor := AContext.Focused and (AContext.CursorOffset = LOffset) and
        (AContext.ActiveEditArea <> hhaAsciiCell);
      LAsciiCursor := AContext.Focused and (AContext.CursorOffset = LOffset) and
        (AContext.ActiveEditArea = hhaAsciiCell);
      LBookmark := GetBookmark(AContext, LOffset);

      LHexBack := GetByteBackColor(AContext, LRowBackColor, LValue, LSelected, LHighlighted,
        LActiveCol, LModified, LLineBreak, LHover);
      LHexFore := GetByteForeColor(AContext, LValue, LSelected, LHighlighted, False, LModified, LLineBreak);

      LHexFillBounds := LHexBounds;
      if LSelected then
      begin
        LNextSelected := (I < AContext.Options.BytesPerRow - 1) and (I + 1 < ARead) and
          (AContext.Selection <> nil) and AContext.Selection.Contains(LOffset + 1);
        if not LNextSelected then
          LHexFillBounds.Right := LHexBounds.Left + AMetrics.CharWidth * 2 + (AMetrics.CharWidth div 2);
      end;
      if (LHexBounds.Right >= LScrollClip.Left) and (LHexBounds.Left <= LScrollClip.Right) then
      begin
        FCellRenderer.RenderByteCell(AContext, LHexBounds, LHexFillBounds, IntToHex(LValue, 2),
          LHexBack, LHexFore, LHexCursor, False);
        if LBookmark <> nil then
          FCellRenderer.RenderBookmarkGlyph(AContext, LHexBounds, ResolveBookmarkColor(AContext, LBookmark));
      end;

      if AContext.Options.ShowAscii then
      begin
        LAsciiBounds := Rect(AMetrics.GetAsciiCellX(I), AY,
          AMetrics.GetAsciiCellX(I) + AMetrics.AsciiCellWidth, AY + AMetrics.RowHeight);
        LAsciiText := GetAsciiText(AContext, LValue, LLineBreakKind);
        LAsciiBack := GetByteBackColor(AContext, LRowBackColor, LValue, LSelected, LHighlighted,
          LActiveCol, LModified, LLineBreak, LHover);
        LAsciiFore := GetByteForeColor(AContext, LValue, LSelected, LHighlighted, True, LModified, LLineBreak);
        if (LAsciiBounds.Right >= LScrollClip.Left) and (LAsciiBounds.Left <= LScrollClip.Right) then
        begin
          FCellRenderer.RenderByteCell(AContext, LAsciiBounds, LAsciiBounds, LAsciiText,
            LAsciiBack, LAsciiFore, LAsciiCursor, True);
          if LBookmark <> nil then
            FCellRenderer.RenderBookmarkGlyph(AContext, LAsciiBounds, ResolveBookmarkColor(AContext, LBookmark));
        end;
      end;
    end;
  finally
    AContext.Surface.PopClip;
  end;

  if AContext.Options.ShowGridLines then
    AContext.Surface.DrawLine(AContext.Theme.GridLineColor, LRowBounds.Left, LRowBounds.Bottom - 1,
      LRowBounds.Right, LRowBounds.Bottom - 1);
end;

procedure THexRenderer.RenderEmptyText(const AContext: THexRenderContext;
  const AMetrics: THexRenderMetrics);
begin
  AContext.Surface.DrawText(HexEditorTexts.NoData, AMetrics.ContentBounds,
    AContext.Theme.DisabledForeColor, [htfHCenter, htfVCenter, htfNoPadding]);
end;

procedure THexRenderer.RenderBorder(const AContext: THexRenderContext);
begin
  AContext.Surface.DrawRectangle(AContext.Theme.BorderColor,
    Rect(AContext.Bounds.Left, AContext.Bounds.Top,
      AContext.Bounds.Right - 1, AContext.Bounds.Bottom - 1));
end;

end.

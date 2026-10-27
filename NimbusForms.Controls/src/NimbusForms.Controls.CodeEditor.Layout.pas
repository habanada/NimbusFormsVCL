{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.CodeEditor.Layout;

interface

uses System.Types, System.SysUtils, System.Generics.Collections, NimbusForms.Controls.CodeEditor.Types,
  NimbusForms.Controls.CodeEditor.Document, NimbusForms.Controls.CodeEditor.Services;

type
  TCodeMeasureLine = reference to function(const Text: string; const TabSize: Integer; const CharWidth: Single): TArray<Single>;
  TCodeEditorRenderMetrics = record
    Bounds, TextBounds, BookmarkBounds, BreakpointBounds, FoldingBounds, LineNumberBounds: TRect;
    CharWidth: Single;
    LineHeight, TextInset, VisibleRows: Integer;
  end;
  TCodeVisualLine = record
    DocumentLine, StartColumn, EndColumn, StartDisplayColumn, EndDisplayColumn, FoldIndex: Integer;
  end;
  TCodeEditorVisualLineMap = class
  private
    FRows: TList<TCodeVisualLine>;
    FFirstRows: TArray<Integer>;
    FMaxColumns: Integer;
    FAdvances: TDictionary<Integer, TArray<Single>>;
    FAdvanceBytes: Int64;
    FMeasureLine: TCodeMeasureLine;
    function Advances(const Text: string; const Line, TabSize: Integer; const CharWidth: Single): TArray<Single>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Rebuild(const Source: ICodeVirtualTextSource; Folds: TCodeFoldManager;
      const Folding, Wrap: Boolean; const WrapColumns, TabSize: Integer);
    function GetRow(const Index: Integer): TCodeVisualLine;
    function GetVisualLine(const Position: TCodeDocumentPosition): Integer;
    function Count: Integer;
    function TextX(const Text: string; const Line, Column, TabSize: Integer; const CharWidth: Single): Single;
    function TextColumn(const Text: string; const Line, TabSize: Integer; const X, CharWidth: Single): Integer;
    property MeasureLine: TCodeMeasureLine read FMeasureLine write FMeasureLine;
    property MaxColumns: Integer read FMaxColumns;
  end;

function CodeDisplayColumn(const Text: string; const Column, TabSize: Integer): Integer;
function CodeCharacterColumn(const Text: string; const DisplayColumn, TabSize: Integer): Integer;
function CodeHitTest(const Point: TPoint; const Metrics: TCodeEditorRenderMetrics;
  Map: TCodeEditorVisualLineMap; const Source: ICodeVirtualTextSource;
  const FirstVisibleLine, HorizontalOffset, TabSize: Integer): TCodeEditorHitInfo;
function CodePositionPoint(const Position: TCodeDocumentPosition; const Metrics: TCodeEditorRenderMetrics;
  Map: TCodeEditorVisualLineMap; const Source: ICodeVirtualTextSource;
  const FirstVisibleLine, HorizontalOffset, TabSize: Integer): TPoint;

implementation

uses System.Math, NimbusForms.Controls.CodeEditor.Unicode;

function CodeDisplayColumn(const Text: string; const Column, TabSize: Integer): Integer;
var I: Integer;
begin Result := 0; for I := 1 to Min(Column, Length(Text)) do if Text[I] = #9 then Inc(Result, TabSize - Result mod TabSize) else Inc(Result); end;
function CodeCharacterColumn(const Text: string; const DisplayColumn, TabSize: Integer): Integer;
var I, Current, Next, First, Last: Integer;
begin
  Current := 0; Result := 0;
  for I := 1 to Length(Text) do
  begin
    Next := Current + 1; if Text[I] = #9 then Next := Current + TabSize - Current mod TabSize;
    if DisplayColumn < Next then
    begin
      if DisplayColumn - Current >= (Next - Current) / 2 then Result := I else Result := I - 1;
      First := CodeClampTextElement(Text, Result); Last := CodeClampTextElement(Text, Result, True);
      Current := CodeDisplayColumn(Text, First, TabSize); Next := CodeDisplayColumn(Text, Last, TabSize);
      if DisplayColumn - Current >= (Next - Current) / 2 then Result := Last else Result := First;
      Exit;
    end;
    Current := Next; Result := I;
  end;
end;
constructor TCodeEditorVisualLineMap.Create;
begin inherited Create; FRows := TList<TCodeVisualLine>.Create; FAdvances := TDictionary<Integer, TArray<Single>>.Create; end;
destructor TCodeEditorVisualLineMap.Destroy;
begin FMeasureLine := nil; FAdvances.Free; FRows.Free; inherited; end;
function TCodeEditorVisualLineMap.Advances(const Text: string; const Line, TabSize: Integer; const CharWidth: Single): TArray<Single>;
var I, Display: Integer; Unicode: Boolean;
begin
  Result := nil;
  if FAdvances.TryGetValue(Line, Result) then Exit;
  Unicode := False; for I := 1 to Length(Text) do if Ord(Text[I]) >= 128 then begin Unicode := True; Break; end;
  if Unicode and Assigned(FMeasureLine) then Result := FMeasureLine(Text, TabSize, CharWidth)
  else
  begin
    SetLength(Result, Length(Text) + 1); Display := 0;
    for I := 1 to Length(Text) do
    begin if Text[I] = #9 then Inc(Display, TabSize - Display mod TabSize) else Inc(Display); Result[I] := Display * CharWidth; end;
  end;
  if Length(Result) <> Length(Text) + 1 then raise EInvalidOpException.Create('Invalid text advance array');
  if (FAdvances.Count >= 256) or ((FAdvances.Count > 0) and (FAdvanceBytes + Int64(Length(Result)) * SizeOf(Single) > 4194304)) then
  begin FAdvances.Clear; FAdvanceBytes := 0; end;
  Inc(FAdvanceBytes, Int64(Length(Result)) * SizeOf(Single));
  FAdvances.Add(Line, Result);
end;
function TCodeEditorVisualLineMap.TextX(const Text: string; const Line, Column, TabSize: Integer; const CharWidth: Single): Single;
var Positions: TArray<Single>;
begin
  Positions := Advances(Text, Line, TabSize, CharWidth);
  if Positions = nil then Result := CodeDisplayColumn(Text, Column, TabSize) * CharWidth
  else Result := Positions[EnsureRange(Column, 0, Length(Text))];
end;
function TCodeEditorVisualLineMap.TextColumn(const Text: string; const Line, TabSize: Integer; const X, CharWidth: Single): Integer;
var Positions: TArray<Single>; Low, High, Mid, First, Last: Integer;
begin
  Positions := Advances(Text, Line, TabSize, CharWidth);
  if Positions = nil then Exit(CodeCharacterColumn(Text, Max(0, Round(X / CharWidth)), TabSize));
  Low := 0; High := Length(Text);
  while Low < High do begin Mid := Low + (High - Low) div 2; if Positions[Mid] < X then Low := Mid + 1 else High := Mid; end;
  First := CodeClampTextElement(Text, Max(0, Low - 1)); Last := CodeClampTextElement(Text, Low, True);
  if X - Positions[First] >= (Positions[Last] - Positions[First]) / 2 then Result := Last else Result := First;
end;
function TCodeEditorVisualLineMap.Count: Integer;
begin Result := FRows.Count; end;
function TCodeEditorVisualLineMap.GetRow(const Index: Integer): TCodeVisualLine;
begin Result := FRows[EnsureRange(Index, 0, FRows.Count - 1)]; end;
procedure TCodeEditorVisualLineMap.Rebuild(const Source: ICodeVirtualTextSource; Folds: TCodeFoldManager;
  const Folding, Wrap: Boolean; const WrapColumns, TabSize: Integer);
var Hidden, Headers: TArray<Integer>; Region: TCodeFoldRegion; I, J, Active, Display, Next, WrapAt: Integer;
  Row: TCodeVisualLine; Text: string;
begin
  FRows.Clear; FMaxColumns := 0; FAdvances.Clear; FAdvanceBytes := 0;
  if (Source = nil) or (Source.LineCount = 0) then begin FFirstRows := nil; Exit; end;
  SetLength(Hidden, Source.LineCount + 1); SetLength(Headers, Source.LineCount);
  SetLength(FFirstRows, Source.LineCount); FillChar(Headers[0], Length(Headers) * SizeOf(Integer), $FF);
  if Folding and (Folds <> nil) then
    for I := 0 to Folds.Regions.Count - 1 do
    begin
      Region := Folds.Regions[I];
      if (Region.Range.Start.LineIndex < 0) or (Region.Range.Start.LineIndex >= Source.LineCount) then Continue;
      Headers[Region.Range.Start.LineIndex] := I;
      if Region.IsCollapsed then
      begin
        Inc(Hidden[Min(Source.LineCount, Region.Range.Start.LineIndex + 1)]);
        Dec(Hidden[Min(Source.LineCount, Region.Range.Finish.LineIndex + 1)]);
      end;
    end;
  Active := 0;
  for I := 0 to Source.LineCount - 1 do
  begin
    Inc(Active, Hidden[I]); FFirstRows[I] := Max(0, FRows.Count - 1);
    if Active > 0 then Continue;
    FFirstRows[I] := FRows.Count; Text := Source.GetLineText(I);
    Row := Default(TCodeVisualLine); Row.DocumentLine := I; Row.FoldIndex := Headers[I];
    Display := 0; WrapAt := Max(1, WrapColumns);
    for J := 1 to Length(Text) do
    begin
      Next := Display + 1; if Text[J] = #9 then Next := Display + TabSize - Display mod TabSize;
      if Wrap and (Display > Row.StartDisplayColumn) and (Next - Row.StartDisplayColumn > WrapAt) and
        (CodeClampTextElement(Text, J - 1) = J - 1) then
      begin
        Row.EndColumn := J - 1; Row.EndDisplayColumn := Display; FRows.Add(Row);
        Row.StartColumn := J - 1; Row.StartDisplayColumn := Display; Row.FoldIndex := -1;
      end;
      Display := Next;
    end;
    Row.EndColumn := Length(Text); Row.EndDisplayColumn := Display; FRows.Add(Row);
    FMaxColumns := Max(FMaxColumns, Display);
  end;
end;

function TCodeEditorVisualLineMap.GetVisualLine(const Position: TCodeDocumentPosition): Integer;
var I: Integer; Row: TCodeVisualLine;
begin
  Result := 0; if Length(FFirstRows) = 0 then Exit;
  Result := FFirstRows[EnsureRange(Position.LineIndex, 0, High(FFirstRows))];
  for I := Result to FRows.Count - 1 do
  begin
    Row := FRows[I]; if Row.DocumentLine <> Position.LineIndex then Break;
    Result := I; if (Position.ColumnIndex < Row.EndColumn) or (I = FRows.Count - 1) then Break;
    if FRows[I + 1].DocumentLine <> Position.LineIndex then Break;
  end;
end;

function CodeHitTest(const Point: TPoint; const Metrics: TCodeEditorRenderMetrics;
  Map: TCodeEditorVisualLineMap; const Source: ICodeVirtualTextSource;
  const FirstVisibleLine, HorizontalOffset, TabSize: Integer): TCodeEditorHitInfo;
var Visual: Integer; Row: TCodeVisualLine; Text: string; X: Single;
begin
  Result := Default(TCodeEditorHitInfo); Result.Area := chaNone;
  if (Map.Count = 0) or not PtInRect(Metrics.Bounds, Point) then Exit;
  Visual := EnsureRange(FirstVisibleLine + (Point.Y - Metrics.Bounds.Top) div Max(1, Metrics.LineHeight), 0, Map.Count - 1);
  Row := Map.GetRow(Visual); Result.VisualIndex := Visual;
  Text := Source.GetLineText(Row.DocumentLine);
  X := Map.TextX(Text, Row.DocumentLine, Row.StartColumn, TabSize, Metrics.CharWidth) + Point.X - Metrics.TextBounds.Left - Metrics.TextInset + HorizontalOffset;
  Result.Position := TCodeDocumentPosition.Create(Row.DocumentLine,
    EnsureRange(Map.TextColumn(Text, Row.DocumentLine, TabSize, X, Metrics.CharWidth), Row.StartColumn, Row.EndColumn));
  if PtInRect(Metrics.BreakpointBounds, Point) then Result.Area := chaBreakpointGutter
  else if PtInRect(Metrics.BookmarkBounds, Point) then Result.Area := chaBookmarkGutter
  else if PtInRect(Metrics.FoldingBounds, Point) then Result.Area := chaFoldingGutter
  else if PtInRect(Metrics.LineNumberBounds, Point) then Result.Area := chaLineNumber
  else if Point.X < Metrics.TextBounds.Left then Result.Area := chaSelectionMargin
  else Result.Area := chaText;
end;

function CodePositionPoint(const Position: TCodeDocumentPosition; const Metrics: TCodeEditorRenderMetrics;
  Map: TCodeEditorVisualLineMap; const Source: ICodeVirtualTextSource;
  const FirstVisibleLine, HorizontalOffset, TabSize: Integer): TPoint;
var Visual: Integer; Row: TCodeVisualLine; Text: string;
begin
  Visual := Map.GetVisualLine(Position); Row := Map.GetRow(Visual);
  Text := Source.GetLineText(Position.LineIndex);
  Result.X := Metrics.TextBounds.Left + Metrics.TextInset - HorizontalOffset +
    Round(Map.TextX(Text, Position.LineIndex, Position.ColumnIndex, TabSize, Metrics.CharWidth) - Map.TextX(Text, Position.LineIndex, Row.StartColumn, TabSize, Metrics.CharWidth));
  Result.Y := Metrics.Bounds.Top + (Visual - FirstVisibleLine) * Metrics.LineHeight;
end;

end.

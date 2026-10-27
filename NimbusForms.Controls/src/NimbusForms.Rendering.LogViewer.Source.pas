unit NimbusForms.Rendering.LogViewer.Source;

interface

uses System.Types, Vcl.Graphics, NimbusForms.Theming.Types, NimbusForms.Theming.Palette, NimbusForms.Rendering.Canvas,
  NimbusForms.Controls.LogViewer.Types, NimbusForms.Controls.LogViewer.Model,
  NimbusForms.Rendering.LogViewer;

type
  TThemedVirtualLogViewerRenderer = class
  public
    class function Measure64(const ACanvas: INimbusRenderCanvas; const AFont: TFont;
      const ABounds: TRect; const APPI: Integer; const ACompact, ALineNumbers: Boolean;
      const ACount: Int64): TNimbusLogMetrics; static;
    class function RowAt64(const P: TPoint; const AMetrics: TNimbusLogMetrics;
      const ATopRow, ACount: Int64): Int64; static;
    class function ColumnAtX(const AText: string; const AX, AHorizontalOffset: Integer;
      const AMetrics: TNimbusLogMetrics): Integer; static;
    class procedure RenderSource(const ACanvas: INimbusRenderCanvas; const AFont: TFont;
      const APalette: TThemePalette; const ASource: TNimbusCustomLogSource; const AIndices: TArray<Int64>;
      const AIdentityMap: Boolean; const AVisibleCount: Int64; const AMetrics: TNimbusLogMetrics;
      const AOptions: TNimbusLogHighlightOptions; const ATopRow: Int64; const AHorizontalOffset: Integer;
      const ASelectionFirst, ASelectionLast: Int64; const AHits: TArray<TNimbusLogSearchHit>;
      const AActiveHit: Integer; const AEnabled: Boolean; Sender: TObject;
      const AOnDraw: TNimbusLogDrawRowEvent; const AOnColors: TNimbusLogRowColorsEvent); static;
  end;

implementation

uses Winapi.Windows, System.SysUtils, System.Math, NimbusForms.Rendering.Types,
  NimbusForms.Rendering.UnicodeText, NimbusForms.Controls.LogViewer.Links;

class function TThemedVirtualLogViewerRenderer.Measure64(const ACanvas: INimbusRenderCanvas;
  const AFont: TFont; const ABounds: TRect; const APPI: Integer; const ACompact,
  ALineNumbers: Boolean; const ACount: Int64): TNimbusLogMetrics;
var S: TSize; Padding, Digits: Integer; CountText: string;
begin
  Result.Bounds := ABounds;
  Result.HasLineNumbers := ALineNumbers;
  S := ACanvas.MeasureText(StringOfChar('0', 64), AFont, 0, [ntfSingleLine, ntfTypographic, ntfNoPrefix]);
  Result.CharWidth := Max(1.0, S.cx / 64.0);
  Padding := 6;
  if ACompact then Padding := 2;
  Result.RowHeight := Max(1, S.cy + NimbusScaleValue(Padding, APPI));
  Result.GutterWidth := NimbusScaleValue(8, APPI);
  if ALineNumbers then
  begin
    CountText := IntToStr(Max(Int64(1), ACount));
    Digits := Length(CountText);
    Result.GutterWidth := Ceil((Digits + 2) * Result.CharWidth) + NimbusScaleValue(8, APPI);
  end;
end;

class function TThemedVirtualLogViewerRenderer.RowAt64(const P: TPoint;
  const AMetrics: TNimbusLogMetrics; const ATopRow, ACount: Int64): Int64;
begin
  Result := -1;
  if not PtInRect(AMetrics.Bounds, P) then Exit;
  Result := ATopRow + (P.Y - AMetrics.Bounds.Top) div Max(1, AMetrics.RowHeight);
  if Result >= ACount then Result := -1;
end;

class function TThemedVirtualLogViewerRenderer.ColumnAtX(const AText: string; const AX,
  AHorizontalOffset: Integer; const AMetrics: TNimbusLogMetrics): Integer;
var Target, I, DisplayColumn, Width: Integer;
begin
  Result := -1;
  Target := AX - AMetrics.Bounds.Left - AMetrics.GutterWidth + AHorizontalOffset;
  if Target < 0 then Exit;
  DisplayColumn := 0;
  for I := 1 to Length(AText) do
  begin
    Width := 1;
    if AText[I] = #9 then Width := 4;
    if Target < Round((DisplayColumn + Width) * AMetrics.CharWidth) then Exit(I - 1);
    Inc(DisplayColumn, Width);
  end;
  Result := Length(AText);
end;

class procedure TThemedVirtualLogViewerRenderer.RenderSource(const ACanvas: INimbusRenderCanvas;
  const AFont: TFont; const APalette: TThemePalette; const ASource: TNimbusCustomLogSource;
  const AIndices: TArray<Int64>; const AIdentityMap: Boolean; const AVisibleCount: Int64;
  const AMetrics: TNimbusLogMetrics; const AOptions: TNimbusLogHighlightOptions;
  const ATopRow: Int64; const AHorizontalOffset: Integer; const ASelectionFirst,
  ASelectionLast: Int64; const AHits: TArray<TNimbusLogSearchHit>; const AActiveHit: Integer;
  const AEnabled: Boolean; Sender: TObject; const AOnDraw: TNimbusLogDrawRowEvent;
  const AOnColors: TNimbusLogRowColorsEvent);
var
  I, Last, SourceIndex: Int64;
  J, X, StartX, EndX, HitIndex, DisplayColumn, LeftColumn, RightColumn: Integer;
  CharIndex, CharWidth, FirstChar, FirstColumn, LastChar: Integer;
  Info: TNimbusLogRowInfo;
  Back, Fore, Color: TThemeColor;
  Token: TNimbusLogToken;
  R: TRect;
  Text: string;
  Handled: Boolean;
  Run: TNimbusLogInteractiveRun;

  function SourceAt(const AVisibleIndex: Int64): Int64;
  begin
    if AIdentityMap then Result := AVisibleIndex
    else if (AVisibleIndex >= 0) and (AVisibleIndex < Length(AIndices)) then Result := AIndices[AVisibleIndex]
    else Result := -1;
  end;

begin
  ACanvas.FillRectangle(NimbusInputBackColor(APalette), AMetrics.Bounds);
  if (ASource = nil) or (AVisibleCount <= 0) then Exit;
  ACanvas.PushClip(AMetrics.Bounds);
  try
    Last := Min(AVisibleCount - 1, ATopRow + AMetrics.Bounds.Height div Max(1, AMetrics.RowHeight));
    HitIndex := 0;
    for I := ATopRow to Last do
    begin
      SourceIndex := SourceAt(I);
      if (SourceIndex < 0) or (SourceIndex >= ASource.Count64) then Continue;
      Info.SourceIndex := Integer(Min(Int64(MaxInt), SourceIndex));
      Info.VisibleIndex := Integer(Min(Int64(MaxInt), I));
      Info.Line := ASource.Lines64[SourceIndex];
      Info.Bounds := Rect(AMetrics.Bounds.Left, AMetrics.Bounds.Top + Integer(I - ATopRow) * AMetrics.RowHeight,
        AMetrics.Bounds.Right, AMetrics.Bounds.Top + (Integer(I - ATopRow) + 1) * AMetrics.RowHeight);
      Info.Selected := (ASelectionFirst >= 0) and (I >= ASelectionFirst) and (I <= ASelectionLast);
      Back := NimbusInputBackColor(APalette);
      Fore := NimbusControlForeColor(APalette);
      if AOptions.ColorizeMessageText then Fore := AOptions.LevelColor(Info.Line.Level, APalette);
      if Info.Selected then Back := NimbusMenuSelectedBackColor(APalette);
      if not AEnabled then Fore := NimbusDisabledForeColor(APalette);
      if Assigned(AOnColors) then AOnColors(Sender, Info, Back, Fore);
      Info.BackColor := Back;
      Info.ForeColor := Fore;
      ACanvas.FillRectangle(Back, Info.Bounds);
      ACanvas.FillRectangle(AOptions.LevelColor(Info.Line.Level, APalette), Rect(Info.Bounds.Left, Info.Bounds.Top, Info.Bounds.Left + 2, Info.Bounds.Bottom));
      Handled := False;
      if Assigned(AOnDraw) then AOnDraw(Sender, ACanvas, Info, Handled);
      if Handled then Continue;
      if AMetrics.HasLineNumbers then
      begin
        R := Rect(Info.Bounds.Left + 4, Info.Bounds.Top, Info.Bounds.Left + AMetrics.GutterWidth - 5, Info.Bounds.Bottom);
        ACanvas.DrawText(IntToStr(SourceIndex + 1), AFont, NimbusMutedForeColor(APalette), R, [ntfRight, ntfVCenter, ntfSingleLine, ntfNoPrefix]);
      end;
      X := Info.Bounds.Left + AMetrics.GutterWidth - AHorizontalOffset;
      ACanvas.PushClip(Rect(Info.Bounds.Left + AMetrics.GutterWidth, Info.Bounds.Top, Info.Bounds.Right, Info.Bounds.Bottom));
      try
        while (HitIndex < Length(AHits)) and (AHits[HitIndex].VisibleIndex64 < I) do Inc(HitIndex);
        J := HitIndex;
        while (J < Length(AHits)) and (AHits[J].VisibleIndex64 = I) do
        begin
          StartX := X + TThemedLogViewerRenderer.ColumnX(Info.Line.Text, AHits[J].Column, AMetrics);
          EndX := X + TThemedLogViewerRenderer.ColumnX(Info.Line.Text, AHits[J].Column + AHits[J].Length, AMetrics);
          R := Rect(StartX, Info.Bounds.Top + 1, Max(StartX + 2, EndX), Info.Bounds.Bottom - 1);
          if AHits[J].Length > 0 then ACanvas.FillRectangle(NimbusBlendColor(Back, NimbusWarningColor, 70), R);
          if J = AActiveHit then ACanvas.DrawRectangle(NimbusAccentColor(APalette), R);
          Inc(J);
        end;
        DisplayColumn := 0;
        LeftColumn := Max(0, Floor(AHorizontalOffset / AMetrics.CharWidth));
        RightColumn := Max(LeftColumn + 1, Ceil((AHorizontalOffset + Info.Bounds.Width - AMetrics.GutterWidth) / AMetrics.CharWidth));
        for Token in Info.Line.Tokens do
        begin
          if DisplayColumn >= RightColumn then Break;
          FirstChar := 0;
          FirstColumn := DisplayColumn;
          CharIndex := Token.Start + 1;
          LastChar := Token.Start + Token.Length;
          while (CharIndex <= LastChar) and (DisplayColumn < RightColumn) do
          begin
            CharWidth := 1;
            if Info.Line.Text[CharIndex] = #9 then CharWidth := 4;
            if (FirstChar = 0) and (DisplayColumn + CharWidth > LeftColumn) then
            begin
              FirstChar := CharIndex;
              FirstColumn := DisplayColumn;
            end;
            Inc(DisplayColumn, CharWidth);
            Inc(CharIndex);
          end;
          if FirstChar = 0 then Continue;
          if (FirstChar > 1) and (Ord(Info.Line.Text[FirstChar]) >= $DC00) and (Ord(Info.Line.Text[FirstChar]) <= $DFFF) and
            (Ord(Info.Line.Text[FirstChar - 1]) >= $D800) and (Ord(Info.Line.Text[FirstChar - 1]) <= $DBFF) then
          begin
            Dec(FirstChar);
            Dec(FirstColumn);
          end;
          if (CharIndex <= LastChar) and (Ord(Info.Line.Text[CharIndex - 1]) >= $D800) and
            (Ord(Info.Line.Text[CharIndex - 1]) <= $DBFF) and (Ord(Info.Line.Text[CharIndex]) >= $DC00) and
            (Ord(Info.Line.Text[CharIndex]) <= $DFFF) then
          begin
            Inc(CharIndex);
            Inc(DisplayColumn);
          end;
          Text := Copy(Info.Line.Text, FirstChar, CharIndex - FirstChar).Replace(#9, '    ');
          StartX := X + Round(FirstColumn * AMetrics.CharWidth);
          EndX := X + Round(DisplayColumn * AMetrics.CharWidth);
          Color := Fore;
          if AEnabled then
            if Token.Kind = nltkLevel then Color := AOptions.TokenColor(Token.Kind, Token.Level, APalette, Fore)
            else Color := AOptions.TokenColor(Token.Kind, Info.Line.Level, APalette, Fore);
          NimbusDrawMonospacedText(ACanvas, Text, AFont, Rect(StartX, Info.Bounds.Top, EndX + 2, Info.Bounds.Bottom), Color, AMetrics.CharWidth);
        end;
        if AEnabled then
          for Run in Info.Line.InteractiveRuns do
          begin
            StartX := X + TThemedLogViewerRenderer.ColumnX(Info.Line.Text, Run.Start, AMetrics);
            EndX := X + TThemedLogViewerRenderer.ColumnX(Info.Line.Text, Run.Start + Run.Length, AMetrics);
            if (EndX >= Info.Bounds.Left + AMetrics.GutterWidth) and (StartX <= Info.Bounds.Right) then
              ACanvas.DrawLine(NimbusAccentColor(APalette), StartX, Info.Bounds.Bottom - 3, EndX, Info.Bounds.Bottom - 3);
          end;
      finally
        ACanvas.PopClip;
      end;
    end;
  finally
    ACanvas.PopClip;
  end;
end;

end.

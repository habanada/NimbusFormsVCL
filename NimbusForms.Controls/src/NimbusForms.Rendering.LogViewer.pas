{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.LogViewer;

interface

uses System.Types, Vcl.Graphics, NimbusForms.Theming.Types, NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Canvas, NimbusForms.Controls.LogViewer.Types, NimbusForms.Controls.LogViewer.Model;

type
  TNimbusLogMetrics = record
    RowHeight, GutterWidth: Integer;
    CharWidth: Single;
    HasLineNumbers: Boolean;
    Bounds: TRect;
  end;
  TNimbusLogRowInfo = record
    Line: TNimbusLogLine;
    SourceIndex, VisibleIndex: Integer;
    Bounds: TRect;
    Selected: Boolean;
    BackColor, ForeColor: TThemeColor;
  end;
  TNimbusLogDrawRowEvent = procedure(Sender: TObject; const ACanvas: INimbusRenderCanvas;
    const AInfo: TNimbusLogRowInfo; var AHandled: Boolean) of object;
  TNimbusLogRowColorsEvent = procedure(Sender: TObject; const AInfo: TNimbusLogRowInfo;
    var ABackColor, AForeColor: TThemeColor) of object;

  TThemedLogViewerRenderer = class
  public
    class function Measure(const ACanvas: INimbusRenderCanvas; const AFont: TFont;
      const ABounds: TRect; const APPI: Integer; const ACompact, ALineNumbers: Boolean;
      const ACount: Integer): TNimbusLogMetrics; static;
    class function RowAt(const P: TPoint; const AMetrics: TNimbusLogMetrics; const ATopRow, ACount: Integer): Integer; static;
    class function ColumnX(const AText: string; const AColumn: Integer; const AMetrics: TNimbusLogMetrics): Integer; static;
    class procedure DrawTaggedRow(const ACanvas: INimbusRenderCanvas; const AFont: TFont;
      const AInfo: TNimbusLogRowInfo; const ATag: string; const AColor: TThemeColor); static;
    class procedure Render(const ACanvas: INimbusRenderCanvas; const AFont: TFont;
      const APalette: TThemePalette; const AModel: TNimbusLogModel; const AIndices: TArray<Integer>;
      const AMetrics: TNimbusLogMetrics; const AOptions: TNimbusLogHighlightOptions;
      const ATopRow, AHorizontalOffset, ASelectionFirst, ASelectionLast: Integer;
      const AHits: TArray<TNimbusLogSearchHit>; const AActiveHit: Integer; const AEnabled: Boolean;
      Sender: TObject; const AOnDraw: TNimbusLogDrawRowEvent; const AOnColors: TNimbusLogRowColorsEvent); static;
  end;

implementation

uses Winapi.Windows, System.Classes, System.SysUtils, System.Math, System.UITypes, NimbusForms.Rendering.Types,
  NimbusForms.Rendering.UnicodeText;

class function TThemedLogViewerRenderer.Measure(const ACanvas: INimbusRenderCanvas; const AFont: TFont;
  const ABounds: TRect; const APPI: Integer; const ACompact, ALineNumbers: Boolean;
  const ACount: Integer): TNimbusLogMetrics;
var S: TSize; Padding: Integer;
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
    Result.GutterWidth := Ceil((Length(IntToStr(Max(1, ACount))) + 2) * Result.CharWidth) + NimbusScaleValue(8, APPI);
end;

class function TThemedLogViewerRenderer.RowAt(const P: TPoint; const AMetrics: TNimbusLogMetrics;
  const ATopRow, ACount: Integer): Integer;
begin
  Result := -1;
  if not PtInRect(AMetrics.Bounds, P) then Exit;
  Result := ATopRow + (P.Y - AMetrics.Bounds.Top) div Max(1, AMetrics.RowHeight);
  if Result >= ACount then Result := -1;
end;

class function TThemedLogViewerRenderer.ColumnX(const AText: string; const AColumn: Integer;
  const AMetrics: TNimbusLogMetrics): Integer;
var I, Count: Integer;
begin
  Count := 0;
  for I := 1 to Min(AColumn, Length(AText)) do
    if AText[I] = #9 then Inc(Count, 4) else Inc(Count);
  Result := Round(Count * AMetrics.CharWidth);
end;

class procedure TThemedLogViewerRenderer.DrawTaggedRow(const ACanvas: INimbusRenderCanvas; const AFont: TFont;
  const AInfo: TNimbusLogRowInfo; const ATag: string; const AColor: TThemeColor);
var B, T: TRect; S: TSize;
begin
  S := ACanvas.MeasureText(ATag, AFont, 0, [ntfSingleLine, ntfNoPrefix]);
  B := Rect(AInfo.Bounds.Left + 8, AInfo.Bounds.Top + 2, AInfo.Bounds.Left + S.cx + 20, AInfo.Bounds.Bottom - 2);
  ACanvas.FillRoundedRectangle(NimbusBlendColor(AInfo.BackColor, AColor, 40), B, 3);
  ACanvas.DrawText(ATag, AFont, AColor, B, [ntfCenter, ntfVCenter, ntfSingleLine, ntfNoPrefix]);
  T := Rect(B.Right + 8, AInfo.Bounds.Top, AInfo.Bounds.Right, AInfo.Bounds.Bottom);
  ACanvas.DrawText(AInfo.Line.Text, AFont, AInfo.ForeColor, T, [ntfSingleLine, ntfVCenter, ntfEndEllipsis, ntfNoPrefix]);
end;

class procedure TThemedLogViewerRenderer.Render(const ACanvas: INimbusRenderCanvas; const AFont: TFont;
  const APalette: TThemePalette; const AModel: TNimbusLogModel; const AIndices: TArray<Integer>;
  const AMetrics: TNimbusLogMetrics; const AOptions: TNimbusLogHighlightOptions;
  const ATopRow, AHorizontalOffset, ASelectionFirst, ASelectionLast: Integer;
  const AHits: TArray<TNimbusLogSearchHit>; const AActiveHit: Integer; const AEnabled: Boolean;
  Sender: TObject; const AOnDraw: TNimbusLogDrawRowEvent; const AOnColors: TNimbusLogRowColorsEvent);
var
  I, Last, J, X, StartX, EndX, HitIndex, DisplayColumn, LeftColumn, RightColumn: Integer;
  CharIndex, CharWidth, FirstChar, FirstColumn, LastChar: Integer;
  Info: TNimbusLogRowInfo;
  Back, Fore, Color: TThemeColor;
  Token: TNimbusLogToken;
  R: TRect;
  Text: string;
  Handled: Boolean;
begin
  ACanvas.FillRectangle(NimbusInputBackColor(APalette), AMetrics.Bounds);
  ACanvas.PushClip(AMetrics.Bounds);
  try
    Last := Min(High(AIndices), ATopRow + AMetrics.Bounds.Height div Max(1, AMetrics.RowHeight));
    HitIndex := 0;
    for I := ATopRow to Last do
    begin
      Info.SourceIndex := AIndices[I]; Info.VisibleIndex := I; Info.Line := AModel[AIndices[I]];
      Info.Bounds := Rect(AMetrics.Bounds.Left, AMetrics.Bounds.Top + (I - ATopRow) * AMetrics.RowHeight,
        AMetrics.Bounds.Right, AMetrics.Bounds.Top + (I - ATopRow + 1) * AMetrics.RowHeight);
      Info.Selected := (ASelectionFirst >= 0) and (I >= ASelectionFirst) and (I <= ASelectionLast);
      Back := NimbusInputBackColor(APalette); Fore := NimbusControlForeColor(APalette);
      if AOptions.ColorizeMessageText then Fore := AOptions.LevelColor(Info.Line.Level, APalette);
      if Info.Selected then Back := NimbusMenuSelectedBackColor(APalette);
      if not AEnabled then Fore := NimbusDisabledForeColor(APalette);
      if Assigned(AOnColors) then AOnColors(Sender, Info, Back, Fore);
      Info.BackColor := Back; Info.ForeColor := Fore;
      ACanvas.FillRectangle(Back, Info.Bounds);
      ACanvas.FillRectangle(AOptions.LevelColor(Info.Line.Level, APalette),
        Rect(Info.Bounds.Left, Info.Bounds.Top, Info.Bounds.Left + 2, Info.Bounds.Bottom));
      Handled := False;
      if Assigned(AOnDraw) then AOnDraw(Sender, ACanvas, Info, Handled);
      if Handled then Continue;
      if AMetrics.HasLineNumbers then
      begin
        R := Rect(Info.Bounds.Left + 4, Info.Bounds.Top, Info.Bounds.Left + AMetrics.GutterWidth - 5, Info.Bounds.Bottom);
        ACanvas.DrawText(IntToStr(Info.SourceIndex + 1), AFont, NimbusMutedForeColor(APalette), R,
          [ntfRight, ntfVCenter, ntfSingleLine, ntfNoPrefix]);
      end;
      X := Info.Bounds.Left + AMetrics.GutterWidth - AHorizontalOffset;
      ACanvas.PushClip(Rect(Info.Bounds.Left + AMetrics.GutterWidth, Info.Bounds.Top, Info.Bounds.Right, Info.Bounds.Bottom));
      try
        while (HitIndex < Length(AHits)) and (AHits[HitIndex].VisibleIndex < I) do Inc(HitIndex);
        J := HitIndex;
        while (J < Length(AHits)) and (AHits[J].VisibleIndex = I) do
        begin
          StartX := X + ColumnX(Info.Line.Text, AHits[J].Column, AMetrics);
          EndX := X + ColumnX(Info.Line.Text, AHits[J].Column + AHits[J].Length, AMetrics);
          R := Rect(StartX, Info.Bounds.Top + 1, Max(StartX + 2, EndX), Info.Bounds.Bottom - 1);
          ACanvas.FillRectangle(NimbusBlendColor(Back, NimbusWarningColor, 70), R);
          if J = AActiveHit then ACanvas.DrawRectangle(NimbusAccentColor(APalette), R);
          Inc(J);
        end;
        DisplayColumn := 0;
        LeftColumn := Max(0, Floor(AHorizontalOffset / AMetrics.CharWidth));
        RightColumn := Max(LeftColumn + 1, Ceil((AHorizontalOffset + Info.Bounds.Width - AMetrics.GutterWidth) / AMetrics.CharWidth));
        for Token in Info.Line.Tokens do
        begin
          if DisplayColumn >= RightColumn then Break;
          FirstChar := 0; FirstColumn := DisplayColumn;
          CharIndex := Token.Start + 1;
          LastChar := Token.Start + Token.Length;
          while (CharIndex <= LastChar) and (DisplayColumn < RightColumn) do
          begin
            CharWidth := 1; if Info.Line.Text[CharIndex] = #9 then CharWidth := 4;
            if (FirstChar = 0) and (DisplayColumn + CharWidth > LeftColumn) then
            begin FirstChar := CharIndex; FirstColumn := DisplayColumn; end;
            Inc(DisplayColumn, CharWidth); Inc(CharIndex);
          end;
          if FirstChar = 0 then Continue;
          if (FirstChar > 1) and (Ord(Info.Line.Text[FirstChar]) >= $DC00) and
            (Ord(Info.Line.Text[FirstChar]) <= $DFFF) and (Ord(Info.Line.Text[FirstChar - 1]) >= $D800) and
            (Ord(Info.Line.Text[FirstChar - 1]) <= $DBFF) then
          begin Dec(FirstChar); Dec(FirstColumn); end;
          if (CharIndex <= LastChar) and (Ord(Info.Line.Text[CharIndex - 1]) >= $D800) and
            (Ord(Info.Line.Text[CharIndex - 1]) <= $DBFF) and (Ord(Info.Line.Text[CharIndex]) >= $DC00) and
            (Ord(Info.Line.Text[CharIndex]) <= $DFFF) then
          begin Inc(CharIndex); Inc(DisplayColumn); end;
          Text := Copy(Info.Line.Text, FirstChar, CharIndex - FirstChar).Replace(#9, '    ');
          StartX := X + Round(FirstColumn * AMetrics.CharWidth);
          EndX := X + Round(DisplayColumn * AMetrics.CharWidth);
          Color := Fore;
          if AEnabled then
            if Token.Kind = nltkLevel then Color := AOptions.TokenColor(Token.Kind, Token.Level, APalette, Fore)
            else Color := AOptions.TokenColor(Token.Kind, Info.Line.Level, APalette, Fore);
          NimbusDrawMonospacedText(ACanvas, Text, AFont, Rect(StartX, Info.Bounds.Top, EndX + 2, Info.Bounds.Bottom), Color, AMetrics.CharWidth);
        end;
      finally ACanvas.PopClip; end;
    end;
  finally ACanvas.PopClip; end;
end;

end.

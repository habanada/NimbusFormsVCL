{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.Markup;

interface

uses
  System.Classes,
  System.Types,
  System.UITypes,
  Vcl.Graphics,
  Vcl.StdCtrls,
  NimbusForms.Theming.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.Rendering.Canvas;

type
  TNimbusMarkupVariant = (nmvNormal, nmvHeading, nmvMuted, nmvAccent, nmvSuccess, nmvWarning, nmvError, nmvCustom);
  TThemedMarkupStyleElement = (tmseBold, tmseItalic, tmseUnderline);
  TThemedMarkupStyle = set of TThemedMarkupStyleElement;
  TThemedMarkupColorRole = (tmcrDefault, tmcrMuted, tmcrAccent, tmcrSuccess, tmcrWarning, tmcrError);
  TThemedMarkupSpanKind = (tmskText, tmskLineBreak);
  TThemedMarkupInlineKind = (tmikNone, tmikCode, tmikKeyboard);

  TThemedMarkupSpan = record
    Kind: TThemedMarkupSpanKind;
    Text: string;
    Style: TThemedMarkupStyle;
    ColorRole: TThemedMarkupColorRole;
    HeadingLevel: Byte;
    InlineKind: TThemedMarkupInlineKind;
    LinkTarget: string;
  end;

  TThemedMarkupRun = record
    Text: string;
    Style: TThemedMarkupStyle;
    ColorRole: TThemedMarkupColorRole;
    HeadingLevel: Byte;
    InlineKind: TThemedMarkupInlineKind;
    LinkTarget: string;
    Width: Integer;
    Height: Integer;
    Bounds: TRect;
  end;

  TThemedMarkupLine = record
    StartRun: Integer;
    RunCount: Integer;
    Width: Integer;
    Height: Integer;
  end;

  TThemedMarkupRenderer = class
  private
    FText: string;
    FUseMarkup: Boolean;
    FCustomSpans: Boolean;
    FSpans: TArray<TThemedMarkupSpan>;
    FRuns: array of TThemedMarkupRun;
    FLines: array of TThemedMarkupLine;
    FFonts: array[0..2, 0..7] of TFont;
    FCodeFonts: array[0..7] of TFont;
    FFontName: string;
    FFontHeight: Integer;
    FFontStyle: TFontStyles;
    FFontCharset: TFontCharset;
    FFontPPI: Integer;
    FLayoutWidth: Integer;
    FLayoutWordWrap: Boolean;
    FLayoutMaxLines: Integer;
    FLayoutLineSpacing: Integer;
    FLayoutShowAccelChar: Boolean;
    FLayoutRightToLeft: Boolean;
    FLayoutEllipsisPosition: TEllipsisPosition;
    FLayoutVariant: TNimbusMarkupVariant;
    FLayoutValid: Boolean;
    FMeasuredSize: TSize;
    procedure InvalidateLayout;
    procedure Parse;
    procedure AppendSpan(const AText: string; const AStyle: TThemedMarkupStyle; const AColorRole: TThemedMarkupColorRole; const AHeadingLevel: Byte; const AInlineKind: TThemedMarkupInlineKind; const ALinkTarget: string);
    procedure AppendLineBreak;
    procedure RebuildFonts(const AFont: TFont);
    function FontIndex(const AStyle: TThemedMarkupStyle): Integer;
    function ResolveFont(const AStyle: TThemedMarkupStyle; const AHeadingLevel: Byte; const AVariant: TNimbusMarkupVariant; const AInlineKind: TThemedMarkupInlineKind): TFont;
    function InlinePaddingX(const AInlineKind: TThemedMarkupInlineKind): Integer;
    function InlinePaddingY(const AInlineKind: TThemedMarkupInlineKind): Integer;
    function MeasureRun(const ACanvas: INimbusRenderCanvas; const AText: string; const AStyle: TThemedMarkupStyle; const AHeadingLevel: Byte; const AVariant: TNimbusMarkupVariant; const AInlineKind: TThemedMarkupInlineKind; const AShowAccelChar, ARightToLeft: Boolean): TSize;
    procedure AddRun(const AText: string; const AStyle: TThemedMarkupStyle; const AColorRole: TThemedMarkupColorRole; const AHeadingLevel: Byte; const AInlineKind: TThemedMarkupInlineKind; const ALinkTarget: string; const ASize: TSize);
    procedure AddLine(const AStartRun, ARunCount, AWidth, AHeight: Integer);
    function BaseLineHeight(const ACanvas: INimbusRenderCanvas; const AVariant: TNimbusMarkupVariant; const AShowAccelChar, ARightToLeft: Boolean): Integer;
    function FitPrefix(const ACanvas: INimbusRenderCanvas; const AText: string; const AStyle: TThemedMarkupStyle; const AHeadingLevel: Byte; const AVariant: TNimbusMarkupVariant; const AInlineKind: TThemedMarkupInlineKind; const AMaxWidth: Integer; const AShowAccelChar, ARightToLeft: Boolean): Integer;
    procedure ApplyEllipsis(const ACanvas: INimbusRenderCanvas; const ALineIndex, AMaxWidth: Integer; const AShowAccelChar, ARightToLeft: Boolean; const AVariant: TNimbusMarkupVariant);
    procedure RecalculateMeasuredSize(const ALineSpacing: Integer);
    procedure PositionRuns(const ABounds: TRect; const AAlignment: TAlignment; const ALayout: TTextLayout; const ALineSpacing: Integer; const ARightToLeft: Boolean);
    function ResolveColor(const AColorRole: TThemedMarkupColorRole; const AVariant: TNimbusMarkupVariant; const APalette: TThemePalette; const AEnabled: Boolean; const ACustomForeColor: TColor): TThemeColor;
    procedure DrawInlineBackground(const ACanvas: INimbusRenderCanvas; const ARun: TThemedMarkupRun; const APalette: TThemePalette; const AEnabled: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure SetText(const AText: string; const AUseMarkup: Boolean);
    procedure SetSpans(const ASpans: TArray<TThemedMarkupSpan>);
    procedure SetFont(const AFont: TFont);
    procedure PrepareLayout(const ACanvas: INimbusRenderCanvas; const AWidth: Integer; const AWordWrap: Boolean; const AMaxLines, ALineSpacing: Integer; const AShowAccelChar, ARightToLeft: Boolean; const AEllipsisPosition: TEllipsisPosition; const AVariant: TNimbusMarkupVariant);
    function Measure: TSize;
    function LinkTargets: TArray<string>;
    function HitTestLink(const APoint: TPoint; const ABounds: TRect; const AAlignment: TAlignment; const ALayout: TTextLayout; const ALineSpacing: Integer; const ARightToLeft: Boolean): string;
    procedure Render(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AAlignment: TAlignment; const ALayout: TTextLayout; const AWordWrap: Boolean; const AMaxLines, ALineSpacing: Integer; const AShowAccelChar, AEnabled, ARightToLeft: Boolean; const AEllipsisPosition: TEllipsisPosition; const AVariant: TNimbusMarkupVariant; const APalette: TThemePalette; const ACustomForeColor: TColor); overload;
    procedure Render(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AAlignment: TAlignment; const ALayout: TTextLayout; const AWordWrap: Boolean; const AMaxLines, ALineSpacing: Integer; const AShowAccelChar, AEnabled, ARightToLeft: Boolean; const AEllipsisPosition: TEllipsisPosition; const AVariant: TNimbusMarkupVariant; const APalette: TThemePalette; const ACustomForeColor: TColor; const AHoveredLink: string); overload;
    property LayoutValid: Boolean read FLayoutValid;
  end;

implementation

uses
  Winapi.Windows,
  System.SysUtils,
  System.Math,
  NimbusForms.Rendering.Types;

constructor TThemedMarkupRenderer.Create;
var
  LLevel, LStyle: Integer;
begin
  inherited Create;
  for LLevel := 0 to 2 do
    for LStyle := 0 to 7 do
      FFonts[LLevel, LStyle] := TFont.Create;
  for LStyle := 0 to 7 do FCodeFonts[LStyle] := TFont.Create;
  FFontHeight := MaxInt;
end;

destructor TThemedMarkupRenderer.Destroy;
var
  LLevel, LStyle: Integer;
begin
  for LStyle := 0 to 7 do FCodeFonts[LStyle].Free;
  for LLevel := 0 to 2 do
    for LStyle := 0 to 7 do
      FFonts[LLevel, LStyle].Free;
  inherited Destroy;
end;

procedure TThemedMarkupRenderer.InvalidateLayout;
begin
  FLayoutValid := False;
end;

procedure TThemedMarkupRenderer.SetText(const AText: string; const AUseMarkup: Boolean);
begin
  if not FCustomSpans and (FText = AText) and (FUseMarkup = AUseMarkup) then Exit;
  FCustomSpans := False;
  FText := AText;
  FUseMarkup := AUseMarkup;
  Parse;
  InvalidateLayout;
end;

procedure TThemedMarkupRenderer.SetSpans(const ASpans: TArray<TThemedMarkupSpan>);
begin
  FSpans := Copy(ASpans);
  FCustomSpans := True;
  InvalidateLayout;
end;

function TThemedMarkupRenderer.LinkTargets: TArray<string>;
var I, J: Integer; Found: Boolean;
begin
  Result := nil;
  for I := 0 to High(FRuns) do
    if FRuns[I].LinkTarget <> '' then
    begin
      Found := False;
      for J := 0 to High(Result) do if Result[J] = FRuns[I].LinkTarget then Found := True;
      if not Found then
      begin
        SetLength(Result, Length(Result) + 1);
        Result[High(Result)] := FRuns[I].LinkTarget;
      end;
    end;
end;

procedure TThemedMarkupRenderer.SetFont(const AFont: TFont);
begin
  if AFont = nil then Exit;
  if (FFontName = AFont.Name) and (FFontHeight = AFont.Height) and (FFontStyle = AFont.Style) and
    (FFontCharset = AFont.Charset) and (FFontPPI = AFont.PixelsPerInch) then Exit;
  FFontName := AFont.Name;
  FFontHeight := AFont.Height;
  FFontStyle := AFont.Style;
  FFontCharset := AFont.Charset;
  FFontPPI := AFont.PixelsPerInch;
  RebuildFonts(AFont);
  InvalidateLayout;
end;

procedure TThemedMarkupRenderer.AppendSpan(const AText: string; const AStyle: TThemedMarkupStyle; const AColorRole: TThemedMarkupColorRole; const AHeadingLevel: Byte; const AInlineKind: TThemedMarkupInlineKind; const ALinkTarget: string);
var
  LIndex: Integer;
begin
  if AText = '' then Exit;
  LIndex := Length(FSpans);
  SetLength(FSpans, LIndex + 1);
  FSpans[LIndex].Kind := tmskText;
  FSpans[LIndex].Text := AText;
  FSpans[LIndex].Style := AStyle;
  FSpans[LIndex].ColorRole := AColorRole;
  FSpans[LIndex].HeadingLevel := AHeadingLevel;
  FSpans[LIndex].InlineKind := AInlineKind;
  FSpans[LIndex].LinkTarget := ALinkTarget;
end;

procedure TThemedMarkupRenderer.AppendLineBreak;
var
  LIndex: Integer;
begin
  LIndex := Length(FSpans);
  SetLength(FSpans, LIndex + 1);
  FSpans[LIndex].Kind := tmskLineBreak;
  FSpans[LIndex].Text := '';
  FSpans[LIndex].Style := [];
  FSpans[LIndex].ColorRole := tmcrDefault;
  FSpans[LIndex].HeadingLevel := 0;
  FSpans[LIndex].InlineKind := tmikNone;
  FSpans[LIndex].LinkTarget := '';
end;

procedure TThemedMarkupRenderer.Parse;
type
  TParserFrame = record
    TagName: string;
    Style: TThemedMarkupStyle;
    ColorRole: TThemedMarkupColorRole;
    HeadingLevel: Byte;
    InlineKind: TThemedMarkupInlineKind;
    LinkTarget: string;
  end;
var
  I, LEnd, LEqual, LFrameIndex: Integer;
  LBuffer, LRawTag, LTag, LTagName, LTarget: string;
  LStyle: TThemedMarkupStyle;
  LColorRole: TThemedMarkupColorRole;
  LHeadingLevel: Byte;
  LInlineKind: TThemedMarkupInlineKind;
  LLinkTarget: string;
  LFrames: array of TParserFrame;

  procedure Flush;
  begin
    AppendSpan(LBuffer, LStyle, LColorRole, LHeadingLevel, LInlineKind, LLinkTarget);
    LBuffer := '';
  end;

  procedure PushFrame(const ATagName: string);
  var
    LIndex: Integer;
  begin
    LIndex := Length(LFrames);
    SetLength(LFrames, LIndex + 1);
    LFrames[LIndex].TagName := ATagName;
    LFrames[LIndex].Style := LStyle;
    LFrames[LIndex].ColorRole := LColorRole;
    LFrames[LIndex].HeadingLevel := LHeadingLevel;
    LFrames[LIndex].InlineKind := LInlineKind;
    LFrames[LIndex].LinkTarget := LLinkTarget;
  end;

  function PopFrame(const ATagName: string): Boolean;
  var
    LIndex: Integer;
  begin
    Result := False;
    LIndex := Length(LFrames) - 1;
    if (LIndex < 0) or (LFrames[LIndex].TagName <> ATagName) then Exit;
    LStyle := LFrames[LIndex].Style;
    LColorRole := LFrames[LIndex].ColorRole;
    LHeadingLevel := LFrames[LIndex].HeadingLevel;
    LInlineKind := LFrames[LIndex].InlineKind;
    LLinkTarget := LFrames[LIndex].LinkTarget;
    SetLength(LFrames, LIndex);
    Result := True;
  end;

  function StripQuotes(const AValue: string): string;
  begin
    Result := Trim(AValue);
    if Length(Result) < 2 then Exit;
    if ((Result[1] = '"') and (Result[Length(Result)] = '"')) or
      ((Ord(Result[1]) = 39) and (Ord(Result[Length(Result)]) = 39)) then
      Result := Copy(Result, 2, Length(Result) - 2);
  end;

begin
  SetLength(FSpans, 0);
  SetLength(LFrames, 0);
  if FText = '' then Exit;
  LStyle := [];
  LColorRole := tmcrDefault;
  LHeadingLevel := 0;
  LInlineKind := tmikNone;
  LLinkTarget := '';
  LBuffer := '';
  I := 1;
  while I <= Length(FText) do
  begin
    if FText[I] = #13 then
    begin
      Flush;
      AppendLineBreak;
      if (I < Length(FText)) and (FText[I + 1] = #10) then Inc(I);
      Inc(I);
      Continue;
    end;
    if FText[I] = #10 then
    begin
      Flush;
      AppendLineBreak;
      Inc(I);
      Continue;
    end;
    if FUseMarkup and (FText[I] = '<') then
    begin
      LEnd := I + 1;
      while (LEnd <= Length(FText)) and (FText[LEnd] <> '>') do Inc(LEnd);
      if LEnd <= Length(FText) then
      begin
        LRawTag := Trim(Copy(FText, I + 1, LEnd - I - 1));
        LTag := LowerCase(LRawTag);
        if (LTag = 'br') or (LTag = 'br/') or (LTag = 'br /') then
        begin
          Flush;
          AppendLineBreak;
          I := LEnd + 1;
          Continue;
        end;
        if (Length(LTag) > 1) and (LTag[1] = '/') then
        begin
          LTagName := Trim(Copy(LTag, 2, MaxInt));
          if (LTagName = 'b') or (LTagName = 'i') or (LTagName = 'u') or (LTagName = 'h1') or
            (LTagName = 'h2') or (LTagName = 'muted') or (LTagName = 'accent') or
            (LTagName = 'success') or (LTagName = 'warning') or (LTagName = 'error') or
            (LTagName = 'code') or (LTagName = 'kbd') or (LTagName = 'link') then
          begin
            LFrameIndex := Length(LFrames) - 1;
            if (LFrameIndex >= 0) and (LFrames[LFrameIndex].TagName = LTagName) then
            begin
              Flush;
              PopFrame(LTagName);
              I := LEnd + 1;
              Continue;
            end;
          end;
        end
        else
        begin
          LEqual := Pos('=', LRawTag);
          if LEqual > 0 then LTagName := LowerCase(Trim(Copy(LRawTag, 1, LEqual - 1))) else LTagName := LTag;
          if (LTagName = 'b') or (LTagName = 'i') or (LTagName = 'u') or (LTagName = 'h1') or
            (LTagName = 'h2') or (LTagName = 'muted') or (LTagName = 'accent') or
            (LTagName = 'success') or (LTagName = 'warning') or (LTagName = 'error') or
            (LTagName = 'code') or (LTagName = 'kbd') or ((LTagName = 'link') and (LEqual > 0)) then
          begin
            if LTagName = 'link' then
            begin
              LTarget := StripQuotes(Copy(LRawTag, LEqual + 1, MaxInt));
              if LTarget = '' then
              begin
                LBuffer := LBuffer + Copy(FText, I, LEnd - I + 1);
                I := LEnd + 1;
                Continue;
              end;
            end
            else
              LTarget := '';
            Flush;
            PushFrame(LTagName);
            if LTagName = 'b' then Include(LStyle, tmseBold)
            else if LTagName = 'i' then Include(LStyle, tmseItalic)
            else if LTagName = 'u' then Include(LStyle, tmseUnderline)
            else if LTagName = 'h1' then LHeadingLevel := 1
            else if LTagName = 'h2' then LHeadingLevel := 2
            else if LTagName = 'muted' then LColorRole := tmcrMuted
            else if LTagName = 'accent' then LColorRole := tmcrAccent
            else if LTagName = 'success' then LColorRole := tmcrSuccess
            else if LTagName = 'warning' then LColorRole := tmcrWarning
            else if LTagName = 'error' then LColorRole := tmcrError
            else if LTagName = 'code' then LInlineKind := tmikCode
            else if LTagName = 'kbd' then LInlineKind := tmikKeyboard
            else if LTagName = 'link' then
            begin
              LLinkTarget := LTarget;
              LColorRole := tmcrAccent;
              Include(LStyle, tmseUnderline);
            end;
            I := LEnd + 1;
            Continue;
          end;
        end;
        LBuffer := LBuffer + Copy(FText, I, LEnd - I + 1);
        I := LEnd + 1;
        Continue;
      end;
    end;
    LBuffer := LBuffer + FText[I];
    Inc(I);
  end;
  Flush;
end;

procedure TThemedMarkupRenderer.RebuildFonts(const AFont: TFont);
var
  LLevel, LMask: Integer;
  LStyle: TFontStyles;
  LHeight: Integer;
begin
  for LLevel := 0 to 2 do
    for LMask := 0 to 7 do
    begin
      FFonts[LLevel, LMask].Assign(AFont);
      LStyle := AFont.Style;
      if (LMask and 1) <> 0 then Include(LStyle, fsBold);
      if (LMask and 2) <> 0 then Include(LStyle, fsItalic);
      if (LMask and 4) <> 0 then Include(LStyle, fsUnderline);
      if LLevel > 0 then Include(LStyle, fsBold);
      FFonts[LLevel, LMask].Style := LStyle;
      LHeight := AFont.Height;
      if LLevel = 1 then LHeight := MulDiv(LHeight, 150, 100)
      else if LLevel = 2 then LHeight := MulDiv(LHeight, 120, 100);
      if LHeight = 0 then LHeight := AFont.Height;
      FFonts[LLevel, LMask].Height := LHeight;
    end;
  for LMask := 0 to 7 do
  begin
    FCodeFonts[LMask].Assign(AFont);
    FCodeFonts[LMask].Name := 'Consolas';
    LStyle := AFont.Style;
    if (LMask and 1) <> 0 then Include(LStyle, fsBold);
    if (LMask and 2) <> 0 then Include(LStyle, fsItalic);
    if (LMask and 4) <> 0 then Include(LStyle, fsUnderline);
    FCodeFonts[LMask].Style := LStyle;
  end;
end;

function TThemedMarkupRenderer.FontIndex(const AStyle: TThemedMarkupStyle): Integer;
begin
  Result := 0;
  if tmseBold in AStyle then Result := Result or 1;
  if tmseItalic in AStyle then Result := Result or 2;
  if tmseUnderline in AStyle then Result := Result or 4;
end;

function TThemedMarkupRenderer.ResolveFont(const AStyle: TThemedMarkupStyle; const AHeadingLevel: Byte; const AVariant: TNimbusMarkupVariant; const AInlineKind: TThemedMarkupInlineKind): TFont;
var
  LLevel, LIndex: Integer;
begin
  LIndex := FontIndex(AStyle);
  if AInlineKind <> tmikNone then
  begin
    if AInlineKind = tmikKeyboard then LIndex := LIndex or 1;
    Exit(FCodeFonts[LIndex]);
  end;
  LLevel := AHeadingLevel;
  if LLevel > 2 then LLevel := 2;
  if (LLevel = 0) and (AVariant = nmvHeading) then LLevel := 1;
  Result := FFonts[LLevel, LIndex];
end;

function TThemedMarkupRenderer.InlinePaddingX(const AInlineKind: TThemedMarkupInlineKind): Integer;
var
  LPPI: Integer;
begin
  LPPI := FFontPPI;
  if LPPI <= 0 then LPPI := 96;
  case AInlineKind of
    tmikCode: Result := NimbusScaleValue(3, LPPI);
    tmikKeyboard: Result := NimbusScaleValue(4, LPPI);
  else
    Result := 0;
  end;
end;

function TThemedMarkupRenderer.InlinePaddingY(const AInlineKind: TThemedMarkupInlineKind): Integer;
var
  LPPI: Integer;
begin
  LPPI := FFontPPI;
  if LPPI <= 0 then LPPI := 96;
  case AInlineKind of
    tmikCode: Result := NimbusScaleValue(1, LPPI);
    tmikKeyboard: Result := NimbusScaleValue(2, LPPI);
  else
    Result := 0;
  end;
end;

function TThemedMarkupRenderer.MeasureRun(const ACanvas: INimbusRenderCanvas; const AText: string; const AStyle: TThemedMarkupStyle; const AHeadingLevel: Byte; const AVariant: TNimbusMarkupVariant; const AInlineKind: TThemedMarkupInlineKind; const AShowAccelChar, ARightToLeft: Boolean): TSize;
var
  LFlags: TNimbusTextFlags;
begin
  LFlags := [ntfSingleLine, ntfTypographic];
  if not AShowAccelChar then Include(LFlags, ntfNoPrefix);
  if ARightToLeft then Include(LFlags, ntfRightToLeft);
  Result := ACanvas.MeasureText(AText, ResolveFont(AStyle, AHeadingLevel, AVariant, AInlineKind), 1000000, LFlags);
  Inc(Result.cx, InlinePaddingX(AInlineKind) * 2);
  Inc(Result.cy, InlinePaddingY(AInlineKind) * 2);
end;

procedure TThemedMarkupRenderer.AddRun(const AText: string; const AStyle: TThemedMarkupStyle; const AColorRole: TThemedMarkupColorRole; const AHeadingLevel: Byte; const AInlineKind: TThemedMarkupInlineKind; const ALinkTarget: string; const ASize: TSize);
var
  LIndex: Integer;
begin
  if AText = '' then Exit;
  LIndex := Length(FRuns);
  SetLength(FRuns, LIndex + 1);
  FRuns[LIndex].Text := AText;
  FRuns[LIndex].Style := AStyle;
  FRuns[LIndex].ColorRole := AColorRole;
  FRuns[LIndex].HeadingLevel := AHeadingLevel;
  FRuns[LIndex].InlineKind := AInlineKind;
  FRuns[LIndex].LinkTarget := ALinkTarget;
  FRuns[LIndex].Width := ASize.cx;
  FRuns[LIndex].Height := ASize.cy;
  FRuns[LIndex].Bounds := Rect(0, 0, 0, 0);
end;

procedure TThemedMarkupRenderer.AddLine(const AStartRun, ARunCount, AWidth, AHeight: Integer);
var
  LIndex: Integer;
begin
  LIndex := Length(FLines);
  SetLength(FLines, LIndex + 1);
  FLines[LIndex].StartRun := AStartRun;
  FLines[LIndex].RunCount := ARunCount;
  FLines[LIndex].Width := AWidth;
  FLines[LIndex].Height := AHeight;
end;

function TThemedMarkupRenderer.BaseLineHeight(const ACanvas: INimbusRenderCanvas; const AVariant: TNimbusMarkupVariant; const AShowAccelChar, ARightToLeft: Boolean): Integer;
var
  LSize: TSize;
begin
  LSize := MeasureRun(ACanvas, 'Mg', [], 0, AVariant, tmikNone, AShowAccelChar, ARightToLeft);
  Result := Max(1, LSize.cy);
end;

function TThemedMarkupRenderer.FitPrefix(const ACanvas: INimbusRenderCanvas; const AText: string; const AStyle: TThemedMarkupStyle; const AHeadingLevel: Byte; const AVariant: TNimbusMarkupVariant; const AInlineKind: TThemedMarkupInlineKind; const AMaxWidth: Integer; const AShowAccelChar, ARightToLeft: Boolean): Integer;
var
  LLow, LHigh, LMid: Integer;
begin
  Result := 0;
  LLow := 1;
  LHigh := Length(AText);
  while LLow <= LHigh do
  begin
    LMid := (LLow + LHigh) div 2;
    if MeasureRun(ACanvas, Copy(AText, 1, LMid), AStyle, AHeadingLevel, AVariant, AInlineKind, AShowAccelChar, ARightToLeft).cx <= AMaxWidth then
    begin
      Result := LMid;
      LLow := LMid + 1;
    end
    else
      LHigh := LMid - 1;
  end;
end;

procedure TThemedMarkupRenderer.ApplyEllipsis(const ACanvas: INimbusRenderCanvas; const ALineIndex, AMaxWidth: Integer; const AShowAccelChar, ARightToLeft: Boolean; const AVariant: TNimbusMarkupVariant);
var
  LLine: TThemedMarkupLine;
  LRunIndex, LPrefixLength: Integer;
  LEllipsis, LText: string;
  LSize: TSize;
begin
  if (ALineIndex < 0) or (ALineIndex >= Length(FLines)) or (AMaxWidth <= 0) then Exit;
  LEllipsis := '...';
  LLine := FLines[ALineIndex];
  while LLine.RunCount > 0 do
  begin
    LRunIndex := LLine.StartRun + LLine.RunCount - 1;
    LText := FRuns[LRunIndex].Text;
    LPrefixLength := Length(LText);
    while LPrefixLength >= 0 do
    begin
      LSize := MeasureRun(ACanvas, Copy(LText, 1, LPrefixLength) + LEllipsis, FRuns[LRunIndex].Style,
        FRuns[LRunIndex].HeadingLevel, AVariant, FRuns[LRunIndex].InlineKind, AShowAccelChar, ARightToLeft);
      if LLine.Width - FRuns[LRunIndex].Width + LSize.cx <= AMaxWidth then
      begin
        FRuns[LRunIndex].Text := Copy(LText, 1, LPrefixLength) + LEllipsis;
        LLine.Width := LLine.Width - FRuns[LRunIndex].Width + LSize.cx;
        FRuns[LRunIndex].Width := LSize.cx;
        FRuns[LRunIndex].Height := LSize.cy;
        if LSize.cy > LLine.Height then LLine.Height := LSize.cy;
        FLines[ALineIndex] := LLine;
        Exit;
      end;
      Dec(LPrefixLength);
    end;
    Dec(LLine.RunCount);
    SetLength(FRuns, LLine.StartRun + LLine.RunCount);
    if LLine.RunCount > 0 then
    begin
      LLine.Width := 0;
      for LRunIndex := LLine.StartRun to LLine.StartRun + LLine.RunCount - 1 do Inc(LLine.Width, FRuns[LRunIndex].Width);
    end
    else
      LLine.Width := 0;
  end;
  FLines[ALineIndex] := LLine;
end;

procedure TThemedMarkupRenderer.RecalculateMeasuredSize(const ALineSpacing: Integer);
var
  I: Integer;
begin
  FMeasuredSize := TSize.Create(0, 0);
  for I := 0 to High(FLines) do
  begin
    if FLines[I].Width > FMeasuredSize.cx then FMeasuredSize.cx := FLines[I].Width;
    Inc(FMeasuredSize.cy, FLines[I].Height);
    if I < High(FLines) then Inc(FMeasuredSize.cy, ALineSpacing);
  end;
end;

procedure TThemedMarkupRenderer.PrepareLayout(const ACanvas: INimbusRenderCanvas; const AWidth: Integer; const AWordWrap: Boolean; const AMaxLines, ALineSpacing: Integer; const AShowAccelChar, ARightToLeft: Boolean; const AEllipsisPosition: TEllipsisPosition; const AVariant: TNimbusMarkupVariant);
var
  LSpanIndex, I, LLineStart, LLineWidth, LLineHeight, LPieceStart, LMaxWidth, LKeepLines, LRunEnd: Integer;
  LText, LPiece: string;
  LSize: TSize;
  LSpan: TThemedMarkupSpan;

  procedure CommitLine(const AForce: Boolean);
  var
    LCount: Integer;
  begin
    LCount := Length(FRuns) - LLineStart;
    if AForce or (LCount > 0) then
    begin
      if LLineHeight <= 0 then LLineHeight := BaseLineHeight(ACanvas, AVariant, AShowAccelChar, ARightToLeft);
      AddLine(LLineStart, LCount, LLineWidth, LLineHeight);
    end;
    LLineStart := Length(FRuns);
    LLineWidth := 0;
    LLineHeight := 0;
  end;

  function CanMergeLastRun(const ASpan: TThemedMarkupSpan): Boolean;
  var
    LIndex: Integer;
  begin
    LIndex := Length(FRuns) - 1;
    Result := (LIndex >= LLineStart) and (LIndex >= 0) and
      (FRuns[LIndex].Style = ASpan.Style) and
      (FRuns[LIndex].ColorRole = ASpan.ColorRole) and
      (FRuns[LIndex].HeadingLevel = ASpan.HeadingLevel) and
      (FRuns[LIndex].InlineKind = ASpan.InlineKind) and
      (FRuns[LIndex].LinkTarget = ASpan.LinkTarget);
  end;

  function CandidateLineWidth(const AValue: string; const ASpan: TThemedMarkupSpan; out ASize: TSize): Integer;
  var
    LIndex: Integer;
  begin
    if CanMergeLastRun(ASpan) then
    begin
      LIndex := Length(FRuns) - 1;
      ASize := MeasureRun(ACanvas, FRuns[LIndex].Text + AValue, ASpan.Style, ASpan.HeadingLevel, AVariant, ASpan.InlineKind, AShowAccelChar, ARightToLeft);
      Result := LLineWidth - FRuns[LIndex].Width + ASize.cx;
    end
    else
    begin
      ASize := MeasureRun(ACanvas, AValue, ASpan.Style, ASpan.HeadingLevel, AVariant, ASpan.InlineKind, AShowAccelChar, ARightToLeft);
      Result := LLineWidth + ASize.cx;
    end;
  end;

  procedure AppendRun(const AValue: string; const ASpan: TThemedMarkupSpan; const ASize: TSize);
  var
    LIndex: Integer;
  begin
    if CanMergeLastRun(ASpan) then
    begin
      LIndex := Length(FRuns) - 1;
      Dec(LLineWidth, FRuns[LIndex].Width);
      FRuns[LIndex].Text := FRuns[LIndex].Text + AValue;
      FRuns[LIndex].Width := ASize.cx;
      FRuns[LIndex].Height := ASize.cy;
      Inc(LLineWidth, FRuns[LIndex].Width);
    end
    else
    begin
      AddRun(AValue, ASpan.Style, ASpan.ColorRole, ASpan.HeadingLevel, ASpan.InlineKind, ASpan.LinkTarget, ASize);
      Inc(LLineWidth, ASize.cx);
    end;
    if ASize.cy > LLineHeight then LLineHeight := ASize.cy;
  end;

  procedure AddPiece(const AValue: string; const ASpan: TThemedMarkupSpan);
  var
    LLocal, LPart: string;
    LPartSize: TSize;
    LPrefix, LCandidateWidth: Integer;
  begin
    if AValue = '' then Exit;
    LLocal := AValue;
    while LLocal <> '' do
    begin
      LCandidateWidth := CandidateLineWidth(LLocal, ASpan, LPartSize);
      if AWordWrap and (LMaxWidth > 0) and (LLineWidth > 0) and (LCandidateWidth > LMaxWidth) then
      begin
        CommitLine(False);
        if ASpan.InlineKind = tmikNone then
          while (LLocal <> '') and ((LLocal[1] = ' ') or (LLocal[1] = #9)) do Delete(LLocal, 1, 1);
        Continue;
      end;
      if AWordWrap and (LMaxWidth > 0) and (LPartSize.cx > LMaxWidth) then
      begin
        LPrefix := FitPrefix(ACanvas, LLocal, ASpan.Style, ASpan.HeadingLevel, AVariant, ASpan.InlineKind, LMaxWidth, AShowAccelChar, ARightToLeft);
        if LPrefix <= 0 then LPrefix := 1;
        LPart := Copy(LLocal, 1, LPrefix);
        LPartSize := MeasureRun(ACanvas, LPart, ASpan.Style, ASpan.HeadingLevel, AVariant, ASpan.InlineKind, AShowAccelChar, ARightToLeft);
        AppendRun(LPart, ASpan, LPartSize);
        Delete(LLocal, 1, LPrefix);
        if LLocal <> '' then CommitLine(False);
        Continue;
      end;
      AppendRun(LLocal, ASpan, LPartSize);
      Break;
    end;
  end;

begin
  if ACanvas = nil then Exit;
  LMaxWidth := Max(1, AWidth);
  if FLayoutValid and (FLayoutWidth = LMaxWidth) and (FLayoutWordWrap = AWordWrap) and
    (FLayoutMaxLines = AMaxLines) and (FLayoutLineSpacing = ALineSpacing) and
    (FLayoutShowAccelChar = AShowAccelChar) and (FLayoutRightToLeft = ARightToLeft) and
    (FLayoutEllipsisPosition = AEllipsisPosition) and (FLayoutVariant = AVariant) then Exit;
  SetLength(FRuns, 0);
  SetLength(FLines, 0);
  if Length(FSpans) = 0 then
  begin
    FMeasuredSize := TSize.Create(0, 0);
    FLayoutWidth := LMaxWidth;
    FLayoutWordWrap := AWordWrap;
    FLayoutMaxLines := AMaxLines;
    FLayoutLineSpacing := ALineSpacing;
    FLayoutShowAccelChar := AShowAccelChar;
    FLayoutRightToLeft := ARightToLeft;
    FLayoutEllipsisPosition := AEllipsisPosition;
    FLayoutVariant := AVariant;
    FLayoutValid := True;
    Exit;
  end;
  LLineStart := 0;
  LLineWidth := 0;
  LLineHeight := 0;
  for LSpanIndex := 0 to High(FSpans) do
  begin
    LSpan := FSpans[LSpanIndex];
    if LSpan.Kind = tmskLineBreak then
    begin
      CommitLine(True);
      Continue;
    end;
    LText := LSpan.Text;
    if not AWordWrap then
    begin
      LSize := MeasureRun(ACanvas, LText, LSpan.Style, LSpan.HeadingLevel, AVariant, LSpan.InlineKind, AShowAccelChar, ARightToLeft);
      AddRun(LText, LSpan.Style, LSpan.ColorRole, LSpan.HeadingLevel, LSpan.InlineKind, LSpan.LinkTarget, LSize);
      Inc(LLineWidth, LSize.cx);
      if LSize.cy > LLineHeight then LLineHeight := LSize.cy;
      Continue;
    end;
    if LSpan.InlineKind <> tmikNone then
    begin
      AddPiece(LText, LSpan);
      Continue;
    end;
    I := 1;
    while I <= Length(LText) do
    begin
      LPieceStart := I;
      if (LText[I] = ' ') or (LText[I] = #9) then
      begin
        while (I <= Length(LText)) and ((LText[I] = ' ') or (LText[I] = #9)) do Inc(I);
      end
      else
      begin
        while (I <= Length(LText)) and (LText[I] <> ' ') and (LText[I] <> #9) do Inc(I);
        while (I <= Length(LText)) and ((LText[I] = ' ') or (LText[I] = #9)) do Inc(I);
      end;
      LPiece := Copy(LText, LPieceStart, I - LPieceStart);
      AddPiece(LPiece, LSpan);
    end;
  end;
  if (LLineStart < Length(FRuns)) or (Length(FLines) = 0) then CommitLine(Length(FLines) = 0);
  if (AMaxLines > 0) and (Length(FLines) > AMaxLines) then
  begin
    LKeepLines := AMaxLines;
    LRunEnd := FLines[LKeepLines - 1].StartRun + FLines[LKeepLines - 1].RunCount;
    SetLength(FLines, LKeepLines);
    SetLength(FRuns, LRunEnd);
    ApplyEllipsis(ACanvas, LKeepLines - 1, LMaxWidth, AShowAccelChar, ARightToLeft, AVariant);
  end
  else if (not AWordWrap) and (AEllipsisPosition <> epNone) and (Length(FLines) > 0) and (FLines[0].Width > LMaxWidth) then
    ApplyEllipsis(ACanvas, 0, LMaxWidth, AShowAccelChar, ARightToLeft, AVariant);
  RecalculateMeasuredSize(ALineSpacing);
  FLayoutWidth := LMaxWidth;
  FLayoutWordWrap := AWordWrap;
  FLayoutMaxLines := AMaxLines;
  FLayoutLineSpacing := ALineSpacing;
  FLayoutShowAccelChar := AShowAccelChar;
  FLayoutRightToLeft := ARightToLeft;
  FLayoutEllipsisPosition := AEllipsisPosition;
  FLayoutVariant := AVariant;
  FLayoutValid := True;
end;

function TThemedMarkupRenderer.Measure: TSize;
begin
  Result := FMeasuredSize;
end;

procedure TThemedMarkupRenderer.PositionRuns(const ABounds: TRect; const AAlignment: TAlignment; const ALayout: TTextLayout; const ALineSpacing: Integer; const ARightToLeft: Boolean);
var
  LLineIndex, LRunIndex, LFirstRun, LLastRun, LX, LY, LBlockTop, LLineLeft, LRunY, I: Integer;
  LLine: TThemedMarkupLine;
  LAlignment: TAlignment;
begin
  for I := 0 to High(FRuns) do FRuns[I].Bounds := Rect(0, 0, 0, 0);
  case ALayout of
    tlCenter: LBlockTop := ABounds.Top + Max(0, (ABounds.Height - FMeasuredSize.cy) div 2);
    tlBottom: LBlockTop := ABounds.Bottom - FMeasuredSize.cy;
  else
    LBlockTop := ABounds.Top;
  end;
  if LBlockTop < ABounds.Top then LBlockTop := ABounds.Top;
  LAlignment := AAlignment;
  if ARightToLeft then
    case LAlignment of
      taLeftJustify: LAlignment := taRightJustify;
      taRightJustify: LAlignment := taLeftJustify;
    end;
  LY := LBlockTop;
  for LLineIndex := 0 to High(FLines) do
  begin
    LLine := FLines[LLineIndex];
    case LAlignment of
      taCenter: LLineLeft := ABounds.Left + (ABounds.Width - LLine.Width) div 2;
      taRightJustify: LLineLeft := ABounds.Right - LLine.Width;
    else
      LLineLeft := ABounds.Left;
    end;
    LFirstRun := LLine.StartRun;
    LLastRun := LLine.StartRun + LLine.RunCount - 1;
    if ARightToLeft then LX := LLineLeft + LLine.Width else LX := LLineLeft;
    for LRunIndex := LFirstRun to LLastRun do
    begin
      if ARightToLeft then Dec(LX, FRuns[LRunIndex].Width);
      LRunY := LY + Max(0, (LLine.Height - FRuns[LRunIndex].Height) div 2);
      FRuns[LRunIndex].Bounds := Rect(LX, LRunY, LX + FRuns[LRunIndex].Width, LRunY + FRuns[LRunIndex].Height);
      if not ARightToLeft then Inc(LX, FRuns[LRunIndex].Width);
    end;
    Inc(LY, LLine.Height);
    if LLineIndex < High(FLines) then Inc(LY, ALineSpacing);
  end;
end;

function TThemedMarkupRenderer.ResolveColor(const AColorRole: TThemedMarkupColorRole; const AVariant: TNimbusMarkupVariant; const APalette: TThemePalette; const AEnabled: Boolean; const ACustomForeColor: TColor): TThemeColor;
var
  LRole: TThemedMarkupColorRole;
begin
  if not AEnabled then Exit(NimbusDisabledForeColor(APalette));
  LRole := AColorRole;
  if LRole = tmcrDefault then
    case AVariant of
      nmvMuted: LRole := tmcrMuted;
      nmvAccent: LRole := tmcrAccent;
      nmvSuccess: LRole := tmcrSuccess;
      nmvWarning: LRole := tmcrWarning;
      nmvError: LRole := tmcrError;
      nmvCustom:
        begin
          if ACustomForeColor <> clNone then Exit(ColorToThemeColor(ACustomForeColor));
          Exit(NimbusControlForeColor(APalette));
        end;
    end;
  case LRole of
    tmcrMuted: Result := NimbusMutedForeColor(APalette);
    tmcrAccent: Result := NimbusAccentColor(APalette);
    tmcrSuccess: Result := NimbusSuccessColor;
    tmcrWarning: Result := NimbusWarningColor;
    tmcrError: Result := NimbusDangerColor;
  else
    Result := NimbusControlForeColor(APalette);
  end;
end;

procedure TThemedMarkupRenderer.DrawInlineBackground(const ACanvas: INimbusRenderCanvas; const ARun: TThemedMarkupRun; const APalette: TThemePalette; const AEnabled: Boolean);
var
  LBack, LBorder, LFore: TThemeColor;
  LRadius: Integer;
begin
  if (ACanvas = nil) or (ARun.InlineKind = tmikNone) or NimbusRectIsEmpty(ARun.Bounds) then Exit;
  if AEnabled then LFore := NimbusControlForeColor(APalette) else LFore := NimbusDisabledForeColor(APalette);
  LRadius := NimbusScaleValue(3, Max(96, FFontPPI));
  case ARun.InlineKind of
    tmikCode:
      begin
        LBack := NimbusColorWithAlpha(LFore, 20);
        LBorder := NimbusColorWithAlpha(LFore, 44);
        ACanvas.FillRoundedRectangle(LBack, ARun.Bounds, LRadius);
        ACanvas.DrawRoundedRectangle(LBorder, ARun.Bounds, LRadius);
      end;
    tmikKeyboard:
      begin
        LBack := NimbusColorWithAlpha(LFore, 30);
        LBorder := NimbusColorWithAlpha(LFore, 92);
        ACanvas.FillRoundedRectangle(LBack, ARun.Bounds, LRadius);
        ACanvas.DrawRoundedRectangle(LBorder, ARun.Bounds, LRadius);
      end;
  end;
end;

function TThemedMarkupRenderer.HitTestLink(const APoint: TPoint; const ABounds: TRect; const AAlignment: TAlignment; const ALayout: TTextLayout; const ALineSpacing: Integer; const ARightToLeft: Boolean): string;
var
  I: Integer;
  LRect: TRect;
begin
  Result := '';
  if not FLayoutValid then Exit;
  if (APoint.X < ABounds.Left) or (APoint.X >= ABounds.Right) or (APoint.Y < ABounds.Top) or (APoint.Y >= ABounds.Bottom) then Exit;
  PositionRuns(ABounds, AAlignment, ALayout, ALineSpacing, ARightToLeft);
  for I := 0 to High(FRuns) do
  begin
    if FRuns[I].LinkTarget = '' then Continue;
    LRect := FRuns[I].Bounds;
    if (APoint.X >= LRect.Left) and (APoint.X < LRect.Right) and (APoint.Y >= LRect.Top) and (APoint.Y < LRect.Bottom) then Exit(FRuns[I].LinkTarget);
  end;
end;

procedure TThemedMarkupRenderer.Render(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AAlignment: TAlignment; const ALayout: TTextLayout; const AWordWrap: Boolean; const AMaxLines, ALineSpacing: Integer; const AShowAccelChar, AEnabled, ARightToLeft: Boolean; const AEllipsisPosition: TEllipsisPosition; const AVariant: TNimbusMarkupVariant; const APalette: TThemePalette; const ACustomForeColor: TColor);
begin
  Render(ACanvas, ABounds, AAlignment, ALayout, AWordWrap, AMaxLines, ALineSpacing, AShowAccelChar,
    AEnabled, ARightToLeft, AEllipsisPosition, AVariant, APalette, ACustomForeColor, '');
end;

procedure TThemedMarkupRenderer.Render(const ACanvas: INimbusRenderCanvas; const ABounds: TRect; const AAlignment: TAlignment; const ALayout: TTextLayout; const AWordWrap: Boolean; const AMaxLines, ALineSpacing: Integer; const AShowAccelChar, AEnabled, ARightToLeft: Boolean; const AEllipsisPosition: TEllipsisPosition; const AVariant: TNimbusMarkupVariant; const APalette: TThemePalette; const ACustomForeColor: TColor; const AHoveredLink: string);
var
  I, LPaddingX, LPaddingY: Integer;
  LRun: TThemedMarkupRun;
  LRect: TRect;
  LFlags: TNimbusTextFlags;
  LColor: TThemeColor;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(ABounds) then Exit;
  PrepareLayout(ACanvas, Max(1, ABounds.Width), AWordWrap, AMaxLines, ALineSpacing, AShowAccelChar, ARightToLeft, AEllipsisPosition, AVariant);
  if Length(FLines) = 0 then Exit;
  PositionRuns(ABounds, AAlignment, ALayout, ALineSpacing, ARightToLeft);
  LFlags := [ntfSingleLine, ntfTypographic];
  if not AShowAccelChar then Include(LFlags, ntfNoPrefix);
  if ARightToLeft then Include(LFlags, ntfRightToLeft);
  for I := 0 to High(FRuns) do
  begin
    LRun := FRuns[I];
    if (LRun.Bounds.Bottom <= ABounds.Top) or (LRun.Bounds.Top >= ABounds.Bottom) or
      (LRun.Bounds.Right <= ABounds.Left) or (LRun.Bounds.Left >= ABounds.Right) then Continue;
    DrawInlineBackground(ACanvas, LRun, APalette, AEnabled);
    LPaddingX := InlinePaddingX(LRun.InlineKind);
    LPaddingY := InlinePaddingY(LRun.InlineKind);
    LRect := LRun.Bounds;
    Inc(LRect.Left, LPaddingX);
    Inc(LRect.Top, LPaddingY);
    Dec(LRect.Right, LPaddingX);
    Dec(LRect.Bottom, LPaddingY);
    Inc(LRect.Right);
    Inc(LRect.Bottom);
    if LRun.LinkTarget <> '' then
    begin
      if AEnabled then
      begin
        LColor := NimbusAccentColor(APalette);
        if (AHoveredLink <> '') and (LRun.LinkTarget = AHoveredLink) then
          LColor := NimbusBlendColor(LColor, NimbusControlForeColor(APalette), 56);
      end
      else
        LColor := NimbusDisabledForeColor(APalette);
    end
    else
      LColor := ResolveColor(LRun.ColorRole, AVariant, APalette, AEnabled, ACustomForeColor);
    ACanvas.DrawText(LRun.Text, ResolveFont(LRun.Style, LRun.HeadingLevel, AVariant, LRun.InlineKind), LColor, LRect, LFlags);
  end;
end;

end.

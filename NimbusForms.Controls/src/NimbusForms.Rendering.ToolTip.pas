{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.ToolTip;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.Types,
  System.UITypes,
  Vcl.Graphics,
  NimbusForms.Controls.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.Theming.Types,
  NimbusForms.Rendering.Canvas,
  NimbusForms.Rendering.Types;

type
  TThemedToolTipMetrics = record
    Padding: Integer;
    MaxWidth: Integer;
    BorderThickness: Integer;
    CornerRadius: Integer;
    IconSize: Integer;
    Gap: Integer;
    TitleSpacing: Integer;
    SeparatorSpacing: Integer;
  end;

  TThemedToolTipContent = record
    Title: string;
    Text: string;
    Icon: TThemedToolTipIcon;
    Image: Vcl.Graphics.TBitmap;
    UseMarkup: Boolean;
  end;

  TThemedToolTipLayoutPart = class
  public
    Text: string;
    Bounds: TRect;
    FontIndex: Integer;
    HasColor: Boolean;
    Color: TThemeColor;
  end;

  TThemedToolTipLayout = class
  private
    FParts: TObjectList<TThemedToolTipLayoutPart>;
    FImage: Vcl.Graphics.TBitmap;
  public
    Size: TSize;
    TitleRect: TRect;
    BodyRect: TRect;
    IconRect: TRect;
    SeparatorY: Integer;
    Content: TThemedToolTipContent;
    constructor Create;
    destructor Destroy; override;
    property Parts: TObjectList<TThemedToolTipLayoutPart> read FParts;
  end;

  TThemedToolTipRenderer = class
  private
    FFonts: array[0..15] of TFont;
    FTitleFont: TFont;
    FBaseName: string;
    FBaseHeight: Integer;
    FBaseStyle: TFontStyles;
    FBaseCharset: TFontCharset;
    FBasePPI: Integer;
    procedure UpdateFonts(const ABaseFont: TFont);
    function RunFont(const AIndex: Integer): TFont;
    function ParseColor(const AValue: string; out AColor: TThemeColor): Boolean;
    procedure BuildMarkup(const ACanvas: INimbusRenderCanvas; const AText: string; const AMaxWidth: Integer; const ALayout: TThemedToolTipLayout; out AWidth, AHeight: Integer);
    procedure DrawIcon(const ACanvas: INimbusRenderCanvas; const ARect: TRect; const AIcon: TThemedToolTipIcon; const AColor: TThemeColor; const ALineWidth: Single);
  public
    constructor Create;
    destructor Destroy; override;
    function BuildLayout(const ACanvas: INimbusRenderCanvas; const AContent: TThemedToolTipContent; const AFont: TFont; const AMetrics: TThemedToolTipMetrics): TThemedToolTipLayout;
    procedure Render(const ACanvas: INimbusRenderCanvas; const ALayout: TThemedToolTipLayout; const APalette: TThemePalette; const AMetrics: TThemedToolTipMetrics; const AShowBorder, AShowTitleSeparator, ARoundedCorners: Boolean);
  end;

implementation

uses
  System.Math,
  System.SysUtils;

type
  TMiniMarkupRun = class
  public
    Text: string;
    Bold: Boolean;
    Italic: Boolean;
    Underline: Boolean;
    Code: Boolean;
    HasColor: Boolean;
    Color: TThemeColor;
    LineBreak: Boolean;
  end;

constructor TThemedToolTipLayout.Create;
begin
  inherited Create;
  FParts := TObjectList<TThemedToolTipLayoutPart>.Create(True);
  FImage := Vcl.Graphics.TBitmap.Create;
  SeparatorY := -1;
end;

destructor TThemedToolTipLayout.Destroy;
begin
  FImage.Free;
  FParts.Free;
  inherited Destroy;
end;

constructor TThemedToolTipRenderer.Create;
var
  I: Integer;
begin
  inherited Create;
  for I := Low(FFonts) to High(FFonts) do FFonts[I] := TFont.Create;
  FTitleFont := TFont.Create;
end;

destructor TThemedToolTipRenderer.Destroy;
var
  I: Integer;
begin
  FTitleFont.Free;
  for I := High(FFonts) downto Low(FFonts) do FFonts[I].Free;
  inherited Destroy;
end;

procedure TThemedToolTipRenderer.UpdateFonts(const ABaseFont: TFont);
var
  I: Integer;
  LStyle: TFontStyles;
begin
  if ABaseFont = nil then Exit;
  if (FBaseName = ABaseFont.Name) and (FBaseHeight = ABaseFont.Height) and (FBaseStyle = ABaseFont.Style) and (FBaseCharset = ABaseFont.Charset) and (FBasePPI = ABaseFont.PixelsPerInch) then Exit;
  FBaseName := ABaseFont.Name;
  FBaseHeight := ABaseFont.Height;
  FBaseStyle := ABaseFont.Style;
  FBaseCharset := ABaseFont.Charset;
  FBasePPI := ABaseFont.PixelsPerInch;
  for I := Low(FFonts) to High(FFonts) do
  begin
    if (I and 8) <> 0 then
    begin
      FFonts[I].Assign(ABaseFont);
      FFonts[I].Name := 'Consolas';
      FFonts[I].Style := [];
    end
    else
      FFonts[I].Assign(ABaseFont);
    LStyle := FFonts[I].Style;
    if (I and 1) <> 0 then Include(LStyle, fsBold);
    if (I and 2) <> 0 then Include(LStyle, fsItalic);
    if (I and 4) <> 0 then Include(LStyle, fsUnderline);
    FFonts[I].Style := LStyle;
  end;
  FTitleFont.Assign(ABaseFont);
  FTitleFont.Size := ABaseFont.Size + 1;
  FTitleFont.Style := FTitleFont.Style + [fsBold];
end;

function TThemedToolTipRenderer.RunFont(const AIndex: Integer): TFont;
begin
  Result := FFonts[AIndex and 15];
end;

function TThemedToolTipRenderer.ParseColor(const AValue: string; out AColor: TThemeColor): Boolean;
var
  S: string;
  V: UInt64;
begin
  Result := False;
  S := Trim(AValue);
  if (Length(S) >= 2) and (((S[1] = '"') and (S[Length(S)] = '"')) or ((S[1] = '''') and (S[Length(S)] = ''''))) then S := Copy(S, 2, Length(S) - 2);
  if (Length(S) = 7) and (S[1] = '#') and TryStrToUInt64('$' + Copy(S, 2, 6), V) then
  begin
    AColor := ThemeColor($FF, Byte((V shr 16) and $FF), Byte((V shr 8) and $FF), Byte(V and $FF));
    Exit(True);
  end;
  if (Length(S) = 9) and (S[1] = '#') and TryStrToUInt64('$' + Copy(S, 2, 8), V) then
  begin
    AColor := ThemeColor(Byte((V shr 24) and $FF), Byte((V shr 16) and $FF), Byte((V shr 8) and $FF), Byte(V and $FF));
    Exit(True);
  end;
  if SameText(S, 'black') then AColor := ThemeColor($FF, 0, 0, 0)
  else if SameText(S, 'white') then AColor := ThemeColor($FF, 255, 255, 255)
  else if SameText(S, 'red') then AColor := ThemeColor($FF, 255, 0, 0)
  else if SameText(S, 'green') then AColor := ThemeColor($FF, 0, 128, 0)
  else if SameText(S, 'blue') then AColor := ThemeColor($FF, 0, 0, 255)
  else if SameText(S, 'yellow') then AColor := ThemeColor($FF, 255, 255, 0)
  else if SameText(S, 'orange') then AColor := ThemeColor($FF, 255, 165, 0)
  else if SameText(S, 'gray') or SameText(S, 'grey') then AColor := ThemeColor($FF, 128, 128, 128)
  else Exit;
  Result := True;
end;

procedure TThemedToolTipRenderer.BuildMarkup(const ACanvas: INimbusRenderCanvas; const AText: string; const AMaxWidth: Integer; const ALayout: TThemedToolTipLayout; out AWidth, AHeight: Integer);
var
  LRuns: TObjectList<TMiniMarkupRun>;
  LRun: TMiniMarkupRun;
  LBuffer, LTag, LToken, LCandidate: string;
  LBold, LItalic, LUnderline, LCode, LHasColor, LTagHandled: Boolean;
  LColor: TThemeColor;
  I, J, LClose, LFontIndex, LX, LY, LLineHeight, LCurrentHeight, LBaseLineHeight: Integer;
  LSize, LCandidateSize: TSize;
  LPart, LActivePart: TThemedToolTipLayoutPart;

  procedure FlushBuffer;
  var
    R: TMiniMarkupRun;
  begin
    if LBuffer = '' then Exit;
    R := TMiniMarkupRun.Create;
    R.Text := LBuffer;
    R.Bold := LBold;
    R.Italic := LItalic;
    R.Underline := LUnderline;
    R.Code := LCode;
    R.HasColor := LHasColor;
    R.Color := LColor;
    LRuns.Add(R);
    LBuffer := '';
  end;

  procedure AddLineBreak;
  var
    R: TMiniMarkupRun;
  begin
    R := TMiniMarkupRun.Create;
    R.LineBreak := True;
    LRuns.Add(R);
  end;

  procedure NextLine;
  begin
    LX := 0;
    Inc(LY, LLineHeight);
    LLineHeight := LBaseLineHeight;
    LActivePart := nil;
  end;

  function HasVisibleText(const AValue: string): Boolean;
  var
    K: Integer;
  begin
    Result := False;
    for K := 1 to Length(AValue) do
      if AValue[K] > ' ' then Exit(True);
  end;

  function StripLeadingSpace(const AValue: string): string;
  var
    K: Integer;
  begin
    K := 1;
    while (K <= Length(AValue)) and (AValue[K] <= ' ') do Inc(K);
    Result := Copy(AValue, K, MaxInt);
  end;

begin
  AWidth := 0;
  AHeight := 0;
  if (ACanvas = nil) or (AText = '') then Exit;
  LRuns := TObjectList<TMiniMarkupRun>.Create(True);
  try
    LBold := False;
    LItalic := False;
    LUnderline := False;
    LCode := False;
    LHasColor := False;
    LColor := 0;
    LBuffer := '';
    I := 1;
    while I <= Length(AText) do
    begin
      if AText[I] = '<' then
      begin
        LClose := I + 1;
        while (LClose <= Length(AText)) and (AText[LClose] <> '>') do Inc(LClose);
        if LClose <= Length(AText) then
        begin
          LTag := Trim(Copy(AText, I + 1, LClose - I - 1));
          LTagHandled := SameText(LTag, 'b') or SameText(LTag, '/b') or SameText(LTag, 'i') or SameText(LTag, '/i') or SameText(LTag, 'u') or SameText(LTag, '/u') or SameText(LTag, 'code') or SameText(LTag, '/code') or SameText(LTag, 'br') or SameText(LTag, 'br/') or SameText(LTag, '/color') or SameText(Copy(LTag, 1, 6), 'color=');
          if LTagHandled then
          begin
            FlushBuffer;
            if SameText(LTag, 'b') then LBold := True
            else if SameText(LTag, '/b') then LBold := False
            else if SameText(LTag, 'i') then LItalic := True
            else if SameText(LTag, '/i') then LItalic := False
            else if SameText(LTag, 'u') then LUnderline := True
            else if SameText(LTag, '/u') then LUnderline := False
            else if SameText(LTag, 'code') then LCode := True
            else if SameText(LTag, '/code') then LCode := False
            else if SameText(LTag, 'br') or SameText(LTag, 'br/') then AddLineBreak
            else if SameText(LTag, '/color') then LHasColor := False
            else if SameText(Copy(LTag, 1, 6), 'color=') then LHasColor := ParseColor(Copy(LTag, 7, MaxInt), LColor);
            I := LClose + 1;
            Continue;
          end;
        end;
      end;
      LBuffer := LBuffer + AText[I];
      Inc(I);
    end;
    FlushBuffer;
    LX := 0;
    LY := 0;
    LSize := ACanvas.MeasureText('Ag', RunFont(0), 32767, [ntfSingleLine, ntfNoPrefix]);
    LBaseLineHeight := Max(1, LSize.cy);
    LLineHeight := LBaseLineHeight;
    LActivePart := nil;
    for LRun in LRuns do
    begin
      if LRun.LineBreak then
      begin
        NextLine;
        Continue;
      end;
      LFontIndex := 0;
      if LRun.Bold then LFontIndex := LFontIndex or 1;
      if LRun.Italic then LFontIndex := LFontIndex or 2;
      if LRun.Underline then LFontIndex := LFontIndex or 4;
      if LRun.Code then LFontIndex := LFontIndex or 8;
      LSize := ACanvas.MeasureText('Ag', RunFont(LFontIndex), 32767, [ntfSingleLine, ntfNoPrefix]);
      LCurrentHeight := Max(1, LSize.cy);
      LActivePart := nil;
      J := 1;
      while J <= Length(LRun.Text) do
      begin
        I := J;
        if LRun.Text[I] <= ' ' then
          while (I <= Length(LRun.Text)) and (LRun.Text[I] <= ' ') do Inc(I);
        while (I <= Length(LRun.Text)) and (LRun.Text[I] > ' ') do Inc(I);
        while (I <= Length(LRun.Text)) and (LRun.Text[I] <= ' ') do Inc(I);
        LToken := Copy(LRun.Text, J, I - J);
        if (LX = 0) and not HasVisibleText(LToken) then
        begin
          J := I;
          Continue;
        end;
        if LActivePart <> nil then
        begin
          LCandidate := LActivePart.Text + LToken;
          LCandidateSize := ACanvas.MeasureText(LCandidate, RunFont(LFontIndex), 32767, [ntfSingleLine, ntfNoPrefix]);
          if HasVisibleText(LToken) and (LActivePart.Bounds.Left + LCandidateSize.cx > AMaxWidth) then
          begin
            NextLine;
            LToken := StripLeadingSpace(LToken);
          end
          else
          begin
            LActivePart.Text := LCandidate;
            LActivePart.Bounds.Right := LActivePart.Bounds.Left + LCandidateSize.cx;
            LActivePart.Bounds.Bottom := LActivePart.Bounds.Top + LCurrentHeight;
            LX := LActivePart.Bounds.Right;
            LLineHeight := Max(LLineHeight, LCurrentHeight);
            AWidth := Max(AWidth, LX);
            J := I;
            Continue;
          end;
        end;
        if LToken <> '' then
        begin
          LSize := ACanvas.MeasureText(LToken, RunFont(LFontIndex), 32767, [ntfSingleLine, ntfNoPrefix]);
          if (LX > 0) and HasVisibleText(LToken) and (LX + LSize.cx > AMaxWidth) then
          begin
            NextLine;
            LToken := StripLeadingSpace(LToken);
            if LToken <> '' then LSize := ACanvas.MeasureText(LToken, RunFont(LFontIndex), 32767, [ntfSingleLine, ntfNoPrefix]);
          end;
          if LToken <> '' then
          begin
            LPart := TThemedToolTipLayoutPart.Create;
            LPart.Text := LToken;
            LPart.Bounds := Rect(LX, LY, LX + LSize.cx, LY + LCurrentHeight);
            LPart.FontIndex := LFontIndex;
            LPart.HasColor := LRun.HasColor;
            LPart.Color := LRun.Color;
            ALayout.Parts.Add(LPart);
            LActivePart := LPart;
            LX := LPart.Bounds.Right;
            LLineHeight := Max(LLineHeight, LCurrentHeight);
            AWidth := Max(AWidth, LX);
          end;
        end;
        J := I;
      end;
    end;
    AHeight := LY + LLineHeight;
    if AWidth < 1 then AWidth := 1;
    if AHeight < 1 then AHeight := 1;
  finally
    LRuns.Free;
  end;
end;

function TThemedToolTipRenderer.BuildLayout(const ACanvas: INimbusRenderCanvas; const AContent: TThemedToolTipContent; const AFont: TFont; const AMetrics: TThemedToolTipMetrics): TThemedToolTipLayout;
var
  LAvailableWidth, LIconExtra, LTitleWidth, LTitleHeight, LBodyWidth, LBodyHeight: Integer;
  LTextWidth, LTextHeight, LBodyTop, I: Integer;
  LSize: TSize;
  LPart: TThemedToolTipLayoutPart;
begin
  Result := TThemedToolTipLayout.Create;
  Result.Content := AContent;
  if (AContent.Image <> nil) and not AContent.Image.Empty then
  begin
    Result.FImage.Assign(AContent.Image);
    Result.Content.Image := Result.FImage;
  end;
  UpdateFonts(AFont);
  LIconExtra := 0;
  if (AContent.Icon <> ttiNone) or ((AContent.Image <> nil) and not AContent.Image.Empty) then LIconExtra := AMetrics.IconSize + AMetrics.Gap;
  LAvailableWidth := AMetrics.MaxWidth - AMetrics.Padding * 2 - LIconExtra;
  if LAvailableWidth < 40 then LAvailableWidth := 40;
  LTitleWidth := 0;
  LTitleHeight := 0;
  LBodyWidth := 0;
  LBodyHeight := 0;
  if AContent.Title <> '' then
  begin
    LSize := ACanvas.MeasureText(AContent.Title, FTitleFont, LAvailableWidth, [ntfWordWrap, ntfNoPrefix]);
    LTitleWidth := LSize.cx;
    LTitleHeight := LSize.cy;
  end;
  if AContent.Text <> '' then
  begin
    if AContent.UseMarkup then
      BuildMarkup(ACanvas, AContent.Text, LAvailableWidth, Result, LBodyWidth, LBodyHeight)
    else
    begin
      LSize := ACanvas.MeasureText(AContent.Text, AFont, LAvailableWidth, [ntfWordWrap, ntfNoPrefix]);
      LBodyWidth := LSize.cx;
      LBodyHeight := LSize.cy;
    end;
  end;
  LTextWidth := Max(LTitleWidth, LBodyWidth);
  LTextHeight := 0;
  if AContent.Title <> '' then
  begin
    Inc(LTextHeight, LTitleHeight + AMetrics.TitleSpacing);
    if (AContent.Text <> '') and (AMetrics.SeparatorSpacing > 0) then Inc(LTextHeight, 0);
  end;
  LBodyTop := LTextHeight;
  if AContent.Text <> '' then Inc(LTextHeight, LBodyHeight);
  if (AContent.Title <> '') and (AContent.Text <> '') and (AMetrics.SeparatorSpacing > 0) then
  begin
    Result.SeparatorY := AMetrics.Padding + LTitleHeight + AMetrics.TitleSpacing + AMetrics.SeparatorSpacing div 2;
    LBodyTop := LBodyTop + AMetrics.SeparatorSpacing + AMetrics.BorderThickness;
    Inc(LTextHeight, AMetrics.SeparatorSpacing + AMetrics.BorderThickness);
  end;
  Result.Size.cx := LTextWidth + LIconExtra + AMetrics.Padding * 2;
  Result.Size.cy := Max(LTextHeight, AMetrics.IconSize) + AMetrics.Padding * 2;
  if Result.Size.cx < 20 then Result.Size.cx := 20;
  if Result.Size.cy < 20 then Result.Size.cy := 20;
  if LIconExtra > 0 then Result.IconRect := Rect(AMetrics.Padding, AMetrics.Padding + 1, AMetrics.Padding + AMetrics.IconSize, AMetrics.Padding + 1 + AMetrics.IconSize);
  LTextWidth := Result.Size.cx - AMetrics.Padding * 2 - LIconExtra;
  Result.TitleRect := Rect(AMetrics.Padding + LIconExtra, AMetrics.Padding, AMetrics.Padding + LIconExtra + LTextWidth, AMetrics.Padding + LTitleHeight);
  Result.BodyRect := Rect(AMetrics.Padding + LIconExtra, AMetrics.Padding + LBodyTop, AMetrics.Padding + LIconExtra + LTextWidth, AMetrics.Padding + LBodyTop + LBodyHeight);
  if AContent.UseMarkup then
    for I := 0 to Result.Parts.Count - 1 do
    begin
      LPart := Result.Parts[I];
      OffsetRect(LPart.Bounds, Result.BodyRect.Left, Result.BodyRect.Top);
    end;
end;

procedure TThemedToolTipRenderer.DrawIcon(const ACanvas: INimbusRenderCanvas; const ARect: TRect; const AIcon: TThemedToolTipIcon; const AColor: TThemeColor; const ALineWidth: Single);
var
  CX, CY, L, T, R, B: Integer;
begin
  if (ACanvas = nil) or NimbusRectIsEmpty(ARect) or (AIcon = ttiNone) then Exit;
  CX := (ARect.Left + ARect.Right) div 2;
  CY := (ARect.Top + ARect.Bottom) div 2;
  L := ARect.Left;
  T := ARect.Top;
  R := ARect.Right - 1;
  B := ARect.Bottom - 1;
  if AIcon = ttiWarning then
  begin
    ACanvas.FillTriangle(AColor, Point(CX, T), Point(R, B), Point(L, B));
    ACanvas.DrawLine(TThemeColor($FFFFFFFF), CX, T + Max(4, ARect.Height div 4), CX, B - Max(5, ARect.Height div 4), ALineWidth);
    ACanvas.FillEllipse(TThemeColor($FFFFFFFF), Rect(CX - 1, B - 4, CX + 2, B - 1));
    Exit;
  end;
  ACanvas.FillEllipse(AColor, ARect);
  case AIcon of
    ttiInfo:
      begin
        ACanvas.DrawLine(TThemeColor($FFFFFFFF), CX, T + 7, CX, B - 4, ALineWidth);
        ACanvas.FillEllipse(TThemeColor($FFFFFFFF), Rect(CX - 1, T + 4, CX + 2, T + 7));
      end;
    ttiError:
      begin
        ACanvas.DrawLine(TThemeColor($FFFFFFFF), L + 5, T + 5, R - 5, B - 5, ALineWidth);
        ACanvas.DrawLine(TThemeColor($FFFFFFFF), R - 5, T + 5, L + 5, B - 5, ALineWidth);
      end;
    ttiSuccess:
      begin
        ACanvas.DrawLine(TThemeColor($FFFFFFFF), L + 4, CY, CX - 1, B - 5, ALineWidth);
        ACanvas.DrawLine(TThemeColor($FFFFFFFF), CX - 1, B - 5, R - 4, T + 5, ALineWidth);
      end;
  end;
end;

procedure TThemedToolTipRenderer.Render(const ACanvas: INimbusRenderCanvas; const ALayout: TThemedToolTipLayout; const APalette: TThemePalette; const AMetrics: TThemedToolTipMetrics; const AShowBorder, AShowTitleSeparator, ARoundedCorners: Boolean);
var
  LBounds, LCodeRect: TRect;
  LBack, LFore, LBorder, LTitle, LMuted, LAccent, LIconColor, LPartColor: TThemeColor;
  I: Integer;
  LPart: TThemedToolTipLayoutPart;
begin
  if (ACanvas = nil) or (ALayout = nil) then Exit;
  LBack := NimbusMenuBackColor(APalette);
  LFore := NimbusMenuForeColor(APalette);
  LBorder := NimbusMenuBorderColor(APalette);
  if APalette <> nil then LTitle := APalette.ForeColor else LTitle := LFore;
  LMuted := NimbusMutedForeColor(APalette);
  LAccent := NimbusAccentColor(APalette);
  LBounds := Rect(0, 0, ALayout.Size.cx, ALayout.Size.cy);
  if ARoundedCorners and (AMetrics.CornerRadius > 0) then ACanvas.FillRoundedRectangle(LBack, LBounds, AMetrics.CornerRadius) else ACanvas.FillRectangle(LBack, LBounds);
  if AShowBorder then
  begin
    if ARoundedCorners and (AMetrics.CornerRadius > 0) then ACanvas.DrawRoundedRectangle(LBorder, LBounds, AMetrics.CornerRadius, AMetrics.BorderThickness) else ACanvas.DrawRectangle(LBorder, LBounds, AMetrics.BorderThickness);
  end;
  if (ALayout.Content.Image <> nil) and not ALayout.Content.Image.Empty then
    ACanvas.DrawBitmap(ALayout.Content.Image, ALayout.IconRect)
  else if ALayout.Content.Icon <> ttiNone then
  begin
    LIconColor := LAccent;
    case ALayout.Content.Icon of
      ttiWarning: LIconColor := NimbusWarningColor;
      ttiError: LIconColor := NimbusDangerColor;
      ttiSuccess: LIconColor := NimbusSuccessColor;
    end;
    DrawIcon(ACanvas, ALayout.IconRect, ALayout.Content.Icon, LIconColor, AMetrics.BorderThickness);
  end;
  if ALayout.Content.Title <> '' then ACanvas.DrawText(ALayout.Content.Title, FTitleFont, LTitle, ALayout.TitleRect, [ntfWordWrap, ntfNoPrefix]);
  if AShowTitleSeparator and (ALayout.Content.Title <> '') and (ALayout.Content.Text <> '') and (ALayout.SeparatorY >= 0) then ACanvas.DrawLine(LBorder, ALayout.BodyRect.Left, ALayout.SeparatorY, ALayout.BodyRect.Right, ALayout.SeparatorY, AMetrics.BorderThickness);
  if ALayout.Content.Text = '' then Exit;
  if not ALayout.Content.UseMarkup then
  begin
    ACanvas.DrawText(ALayout.Content.Text, RunFont(0), LFore, ALayout.BodyRect, [ntfWordWrap, ntfNoPrefix]);
    Exit;
  end;
  for I := 0 to ALayout.Parts.Count - 1 do
  begin
    LPart := ALayout.Parts[I];
    if (LPart.FontIndex and 8) <> 0 then
    begin
      LCodeRect := LPart.Bounds;
      ACanvas.FillRectangle(NimbusColorWithAlpha(LMuted, 32), LCodeRect);
    end;
    if LPart.HasColor then LPartColor := LPart.Color else LPartColor := LFore;
    ACanvas.DrawText(LPart.Text, RunFont(LPart.FontIndex), LPartColor, LPart.Bounds, [ntfSingleLine, ntfNoPrefix]);
  end;
end;

end.

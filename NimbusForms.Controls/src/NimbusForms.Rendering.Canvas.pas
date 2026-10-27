{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.Canvas;

interface

uses
  Winapi.Windows,
  Winapi.GDIPAPI,
  Winapi.GDIPOBJ,
  System.Types,
  System.UITypes,
  Vcl.Graphics,
  NimbusForms.Theming.Types,
  NimbusForms.Rendering.Types;

type
  TNimbusPointBuffer = array[0..255] of TPoint;
  PNimbusPointBuffer = ^TNimbusPointBuffer;

  INimbusRenderClipExclusion = interface
    ['{A9F7319D-AF9B-4393-ABFD-8378DBC86078}']
    procedure ExcludeClip(const ARect: TRect);
  end;

  INimbusRenderCanvas = interface
    ['{E2C8B329-9AB4-4F3D-92ED-DCE5B7DAFD92}']
    procedure BeginRender(const ACanvas: TCanvas);
    procedure EndRender;
    procedure SaveState;
    procedure RestoreState;
    procedure PushClip(const ARect: TRect);
    procedure PopClip;
    procedure DrawPolyline(const AColor: TThemeColor; const APoints: array of TPointF; const AWidth: Single = 1.0);
    procedure FillPolygonF(const AColor: TThemeColor; const APoints: array of TPointF);
    procedure FillPolygonGradient(const ATopColor, ABottomColor: TThemeColor; const APoints: array of TPointF; const ABounds: TRect);
    procedure FillPie(const AColor: TThemeColor; const ARect: TRect; const AStartAngle, ASweepAngle: Single);
    procedure DrawDashedLine(const AColor: TThemeColor; const AX1, AY1, AX2, AY2: Integer; const AWidth: Single; const ADashStyle: Integer);

    procedure Clear(const AColor: TThemeColor; const ARect: TRect);
    procedure FillRectangle(const AColor: TThemeColor; const ARect: TRect);
    procedure DrawRectangle(const AColor: TThemeColor; const ARect: TRect; const AWidth: Single = 1.0);
    procedure FillRoundedRectangle(const AColor: TThemeColor; const ARect: TRect; const ARadius: Integer);
    procedure DrawRoundedRectangle(const AColor: TThemeColor; const ARect: TRect; const ARadius: Integer; const AWidth: Single = 1.0);
    procedure FillEllipse(const AColor: TThemeColor; const ARect: TRect);
    procedure DrawEllipse(const AColor: TThemeColor; const ARect: TRect; const AWidth: Single = 1.0);
    procedure DrawLine(const AColor: TThemeColor; const AX1, AY1, AX2, AY2: Integer; const AWidth: Single = 1.0);
    procedure DrawArc(const AColor: TThemeColor; const ARect: TRect; const AStartAngle, ASweepAngle, AWidth: Single);
    procedure DrawDashedRectangle(const AColor: TThemeColor; const ARect: TRect; const AWidth: Single = 1.0);
    procedure FillTriangle(const AColor: TThemeColor; const APoint1, APoint2, APoint3: TPoint);
    procedure FillPolygon(const AColor: TThemeColor; const APoints: PNimbusPointBuffer; const ACount: Integer);
    procedure DrawPolygon(const AColor: TThemeColor; const APoints: PNimbusPointBuffer; const ACount: Integer; const AWidth: Single = 1.0);
    procedure DrawFocusRectangle(const AColor: TThemeColor; const ARect: TRect);
    procedure DrawIcon(const AIcon: HICON; const ARect: TRect);
    procedure DrawBitmap(const ABitmap: Vcl.Graphics.TBitmap; const ARect: TRect);
    procedure DrawBitmapPart(const ABitmap: Vcl.Graphics.TBitmap; const ADestRect, ASourceRect: TRect);
    procedure DrawText(const AText: string; const AFont: TFont; const AColor: TThemeColor; const ARect: TRect; const AFlags: TNimbusTextFlags);
    function MeasureText(const AText: string; const AFont: TFont; const AMaxWidth: Integer; const AFlags: TNimbusTextFlags): TSize;
  end;

  TNimbusRenderCanvas = class(TInterfacedObject, INimbusRenderCanvas, INimbusRenderClipExclusion)
  private
    FCanvas: TCanvas;
    FDC: HDC;
    FBorrowedGraphics: Boolean;
    FGraphicsState: Cardinal;
    FStates: TArray<Cardinal>;
    FGraphics: TGPGraphics;
    FPen: TGPPen;
    FBrush: TGPSolidBrush;
    FPath: TGPGraphicsPath;
    FStringFormat: TGPStringFormat;
    FTextFont: TGPFont;
    FTextFontHandle: HFONT;
    FTextFontName: string;
    FTextFontHeight: Integer;
    FTextFontStyle: TFontStyles;
    FTextFontCharset: TFontCharset;
    FTextFontPPI: Integer;
    FIconBitmap: TGPBitmap;
    FIconBitmapHandle: HICON;
    FBitmapImage: TGPBitmap;
    FBitmapHandle: HBITMAP;
    FBitmapPalette: HPALETTE;
    procedure SetBrushColor(const AColor: TThemeColor);
    procedure SetPen(const AColor: TThemeColor; const AWidth: Single);
    procedure BuildRoundedPath(const ARect: TRect; const ARadius: Integer);
    procedure EnsureTextFont(const AFont: TFont);
    procedure EnsureBitmapImage(const ABitmap: Vcl.Graphics.TBitmap);
    procedure ConfigureStringFormat(const AFlags: TNimbusTextFlags; const AMeasure: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure BeginRender(const ACanvas: TCanvas);
    procedure BeginRenderGraphics(const AGraphics: TGPGraphics; const ADC: HDC);
    procedure ExcludeClip(const ARect: TRect);
    procedure EndRender;
    procedure SaveState;
    procedure RestoreState;
    procedure PushClip(const ARect: TRect);
    procedure PopClip;
    procedure DrawPolyline(const AColor: TThemeColor; const APoints: array of TPointF; const AWidth: Single = 1.0);
    procedure FillPolygonF(const AColor: TThemeColor; const APoints: array of TPointF);
    procedure FillPolygonGradient(const ATopColor, ABottomColor: TThemeColor; const APoints: array of TPointF; const ABounds: TRect);
    procedure FillPie(const AColor: TThemeColor; const ARect: TRect; const AStartAngle, ASweepAngle: Single);
    procedure DrawDashedLine(const AColor: TThemeColor; const AX1, AY1, AX2, AY2: Integer; const AWidth: Single; const ADashStyle: Integer);

    procedure Clear(const AColor: TThemeColor; const ARect: TRect);
    procedure FillRectangle(const AColor: TThemeColor; const ARect: TRect);
    procedure DrawRectangle(const AColor: TThemeColor; const ARect: TRect; const AWidth: Single = 1.0);
    procedure FillRoundedRectangle(const AColor: TThemeColor; const ARect: TRect; const ARadius: Integer);
    procedure DrawRoundedRectangle(const AColor: TThemeColor; const ARect: TRect; const ARadius: Integer; const AWidth: Single = 1.0);
    procedure FillEllipse(const AColor: TThemeColor; const ARect: TRect);
    procedure DrawEllipse(const AColor: TThemeColor; const ARect: TRect; const AWidth: Single = 1.0);
    procedure DrawLine(const AColor: TThemeColor; const AX1, AY1, AX2, AY2: Integer; const AWidth: Single = 1.0);
    procedure DrawArc(const AColor: TThemeColor; const ARect: TRect; const AStartAngle, ASweepAngle, AWidth: Single);
    procedure DrawDashedRectangle(const AColor: TThemeColor; const ARect: TRect; const AWidth: Single = 1.0);
    procedure FillTriangle(const AColor: TThemeColor; const APoint1, APoint2, APoint3: TPoint);
    procedure FillPolygon(const AColor: TThemeColor; const APoints: PNimbusPointBuffer; const ACount: Integer);
    procedure DrawPolygon(const AColor: TThemeColor; const APoints: PNimbusPointBuffer; const ACount: Integer; const AWidth: Single = 1.0);
    procedure DrawFocusRectangle(const AColor: TThemeColor; const ARect: TRect);
    procedure DrawIcon(const AIcon: HICON; const ARect: TRect);
    procedure DrawBitmap(const ABitmap: Vcl.Graphics.TBitmap; const ARect: TRect);
    procedure DrawBitmapPart(const ABitmap: Vcl.Graphics.TBitmap; const ADestRect, ASourceRect: TRect);
    procedure DrawText(const AText: string; const AFont: TFont; const AColor: TThemeColor; const ARect: TRect; const AFlags: TNimbusTextFlags);
    function MeasureText(const AText: string; const AFont: TFont; const AMaxWidth: Integer; const AFlags: TNimbusTextFlags): TSize;
  end;

implementation

uses
  System.Math,
  System.SysUtils;

constructor TNimbusRenderCanvas.Create;
begin
  inherited Create;
  FPen := TGPPen.Create(0, 1.0);
  FBrush := TGPSolidBrush.Create(0);
  FPath := TGPGraphicsPath.Create;
  FStringFormat := TGPStringFormat.Create;
end;

destructor TNimbusRenderCanvas.Destroy;
begin
  EndRender;
  FBitmapImage.Free;
  FIconBitmap.Free;
  FTextFont.Free;
  FStringFormat.Free;
  FPath.Free;
  FBrush.Free;
  FPen.Free;
  inherited Destroy;
end;

procedure TNimbusRenderCanvas.BeginRender(const ACanvas: TCanvas);
begin
  EndRender;
  FCanvas := ACanvas;
  if FCanvas = nil then
    Exit;
  FDC := FCanvas.Handle;
  FGraphics := TGPGraphics.Create(FDC);
  FGraphics.SetPageUnit(UnitPixel);
  FGraphics.SetSmoothingMode(SmoothingModeAntiAlias);
  FGraphics.SetPixelOffsetMode(PixelOffsetModeHighQuality);
  FGraphics.SetInterpolationMode(InterpolationModeHighQualityBicubic);
  FGraphics.SetCompositingQuality(CompositingQualityHighQuality);
  FGraphics.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);
end;

procedure TNimbusRenderCanvas.EndRender;
begin
  if FBorrowedGraphics and (FGraphics <> nil) then
    FGraphics.Restore(FGraphicsState)
  else
    FGraphics.Free;
  FBorrowedGraphics := False;
  FDC := 0;
  FGraphics := nil;
  FCanvas := nil;
  FStates := nil;
end;

procedure TNimbusRenderCanvas.BeginRenderGraphics(const AGraphics: TGPGraphics; const ADC: HDC);
begin
  EndRender;
  if AGraphics = nil then Exit;
  FGraphics := AGraphics;
  FDC := ADC;
  FBorrowedGraphics := True;
  FGraphicsState := FGraphics.Save;
end;

procedure TNimbusRenderCanvas.SaveState;
var N: Integer;
begin
  if FGraphics = nil then Exit;
  N := Length(FStates);
  SetLength(FStates, N + 1);
  FStates[N] := FGraphics.Save;
end;

procedure TNimbusRenderCanvas.RestoreState;
var N: Integer;
begin
  N := Length(FStates);
  if (FGraphics = nil) or (N = 0) then Exit;
  FGraphics.Restore(FStates[N - 1]);
  SetLength(FStates, N - 1);
end;

procedure TNimbusRenderCanvas.PushClip(const ARect: TRect);
var R: TGPRect;
begin
  if FGraphics = nil then Exit;
  SaveState;
  R.X := ARect.Left; R.Y := ARect.Top;
  R.Width := Max(0, ARect.Width); R.Height := Max(0, ARect.Height);
  FGraphics.SetClip(R, CombineModeIntersect);
end;

procedure TNimbusRenderCanvas.PopClip;
begin
  RestoreState;
end;

procedure TNimbusRenderCanvas.ExcludeClip(const ARect: TRect);
var R: TGPRect;
begin
  if (FGraphics = nil) or ARect.IsEmpty then Exit;
  R.X := ARect.Left; R.Y := ARect.Top; R.Width := ARect.Width; R.Height := ARect.Height;
  FGraphics.SetClip(R, CombineModeExclude);
end;

procedure TNimbusRenderCanvas.DrawPolyline(const AColor: TThemeColor; const APoints: array of TPointF; const AWidth: Single);
var P: TArray<TGPPointF>; I: Integer;
begin
  if (FGraphics = nil) or (Length(APoints) < 2) or (AWidth <= 0) then Exit;
  SetLength(P, Length(APoints));
  for I := 0 to High(P) do begin P[I].X := APoints[I].X; P[I].Y := APoints[I].Y end;
  SetPen(AColor, AWidth);
  FPen.SetDashStyle(DashStyleSolid);
  FPen.SetStartCap(LineCapFlat); FPen.SetEndCap(LineCapFlat);
  FGraphics.DrawLines(FPen, PGPPointF(@P[0]), Length(P));
end;

procedure TNimbusRenderCanvas.FillPolygonF(const AColor: TThemeColor; const APoints: array of TPointF);
var P: TArray<TGPPointF>; I: Integer;
begin
  if (FGraphics = nil) or (Length(APoints) < 3) then Exit;
  SetLength(P, Length(APoints));
  for I := 0 to High(P) do begin P[I].X := APoints[I].X; P[I].Y := APoints[I].Y end;
  SetBrushColor(AColor);
  FGraphics.FillPolygon(FBrush, PGPPointF(@P[0]), Length(P));
end;

procedure TNimbusRenderCanvas.FillPolygonGradient(const ATopColor, ABottomColor: TThemeColor; const APoints: array of TPointF; const ABounds: TRect);
var P: TArray<TGPPointF>; I: Integer; R: TGPRectF; B: TGPLinearGradientBrush;
begin
  if (FGraphics = nil) or (Length(APoints) < 3) or NimbusRectIsEmpty(ABounds) then Exit;
  SetLength(P, Length(APoints));
  for I := 0 to High(P) do begin P[I].X := APoints[I].X; P[I].Y := APoints[I].Y end;
  R.X := ABounds.Left; R.Y := ABounds.Top; R.Width := ABounds.Width; R.Height := ABounds.Height;
  B := TGPLinearGradientBrush.Create(R, ARGB(ATopColor), ARGB(ABottomColor), Single(90), True);
  try FGraphics.FillPolygon(B, PGPPointF(@P[0]), Length(P)) finally B.Free end;
end;

procedure TNimbusRenderCanvas.FillPie(const AColor: TThemeColor; const ARect: TRect; const AStartAngle, ASweepAngle: Single);
begin
  if (FGraphics = nil) or NimbusRectIsEmpty(ARect) then Exit;
  SetBrushColor(AColor);
  FGraphics.FillPie(FBrush, ARect.Left, ARect.Top, ARect.Width, ARect.Height, AStartAngle, ASweepAngle);
end;

procedure TNimbusRenderCanvas.DrawDashedLine(const AColor: TThemeColor; const AX1, AY1, AX2, AY2: Integer; const AWidth: Single; const ADashStyle: Integer);
begin
  if (FGraphics = nil) or (AWidth <= 0) then Exit;
  SetPen(AColor, AWidth);
  FPen.SetDashStyle(TDashStyle(EnsureRange(ADashStyle, 0, 4)));
  FPen.SetStartCap(LineCapFlat); FPen.SetEndCap(LineCapFlat);
  FGraphics.DrawLine(FPen, AX1, AY1, AX2, AY2);
  FPen.SetDashStyle(DashStyleSolid);
end;

procedure TNimbusRenderCanvas.SetBrushColor(const AColor: TThemeColor);
begin
  FBrush.SetColor(ARGB(AColor));
end;

procedure TNimbusRenderCanvas.SetPen(const AColor: TThemeColor; const AWidth: Single);
begin
  FPen.SetColor(ARGB(AColor));
  FPen.SetWidth(AWidth);
end;

procedure TNimbusRenderCanvas.BuildRoundedPath(const ARect: TRect; const ARadius: Integer);
var
  LRadius, LDiameter: Integer;
begin
  FPath.Reset;
  LRadius := ARadius;
  if LRadius < 0 then LRadius := 0;
  if LRadius > ARect.Width div 2 then LRadius := ARect.Width div 2;
  if LRadius > ARect.Height div 2 then LRadius := ARect.Height div 2;
  if LRadius = 0 then
    Exit;
  LDiameter := LRadius * 2;
  FPath.AddArc(ARect.Left, ARect.Top, LDiameter, LDiameter, 180, 90);
  FPath.AddArc(ARect.Right - LDiameter, ARect.Top, LDiameter, LDiameter, 270, 90);
  FPath.AddArc(ARect.Right - LDiameter, ARect.Bottom - LDiameter, LDiameter, LDiameter, 0, 90);
  FPath.AddArc(ARect.Left, ARect.Bottom - LDiameter, LDiameter, LDiameter, 90, 90);
  FPath.CloseFigure;
end;

procedure TNimbusRenderCanvas.EnsureTextFont(const AFont: TFont);
begin
  if (FGraphics = nil) or (FDC = 0) or (AFont = nil) then
    Exit;
  if (FTextFont <> nil) and (FTextFontHandle = AFont.Handle) and (FTextFontName = AFont.Name) and
    (FTextFontHeight = AFont.Height) and (FTextFontStyle = AFont.Style) and
    (FTextFontCharset = AFont.Charset) and (FTextFontPPI = AFont.PixelsPerInch) then
    Exit;
  FTextFont.Free;
  FTextFont := TGPFont.Create(FDC, AFont.Handle);
  FTextFontHandle := AFont.Handle;
  FTextFontName := AFont.Name;
  FTextFontHeight := AFont.Height;
  FTextFontStyle := AFont.Style;
  FTextFontCharset := AFont.Charset;
  FTextFontPPI := AFont.PixelsPerInch;
end;

procedure TNimbusRenderCanvas.EnsureBitmapImage(const ABitmap: Vcl.Graphics.TBitmap);
var
  LHandle: HBITMAP;
  LPalette: HPALETTE;
  LData: TBitmapData;
  LRect: TGPRect;
  LRow: Integer;
  LAlphaBitmap: Boolean;
begin
  if (ABitmap = nil) or ABitmap.Empty then Exit;
  LHandle := ABitmap.Handle;
  LPalette := ABitmap.Palette;
  LAlphaBitmap := (ABitmap.PixelFormat = pf32bit) and (ABitmap.AlphaFormat = afPremultiplied);
  if not LAlphaBitmap then
  begin
    if (FBitmapImage <> nil) and (FBitmapHandle = LHandle) and (FBitmapPalette = LPalette) then Exit;
    FreeAndNil(FBitmapImage);
    FBitmapImage := TGPBitmap.Create(LHandle, LPalette);
  end
  else
  begin
    if (FBitmapImage = nil) or (FBitmapHandle <> LHandle) or (FBitmapImage.GetWidth <> Cardinal(ABitmap.Width)) or (FBitmapImage.GetHeight <> Cardinal(ABitmap.Height)) then
    begin
      FreeAndNil(FBitmapImage);
      FBitmapImage := TGPBitmap.Create(ABitmap.Width, ABitmap.Height, PixelFormat32bppPARGB);
    end;
    LRect.X := 0;
    LRect.Y := 0;
    LRect.Width := ABitmap.Width;
    LRect.Height := ABitmap.Height;
    if FBitmapImage.LockBits(LRect, ImageLockModeWrite, PixelFormat32bppPARGB, LData) <> Ok then
    begin
      FreeAndNil(FBitmapImage);
      FBitmapHandle := 0;
      FBitmapPalette := 0;
      Exit;
    end;
    try
      for LRow := 0 to ABitmap.Height - 1 do
        Move(ABitmap.ScanLine[LRow]^, PByte(NativeInt(LData.Scan0) + NativeInt(LRow) * LData.Stride)^, ABitmap.Width * 4);
    finally
      FBitmapImage.UnlockBits(LData);
    end;
  end;
  FBitmapHandle := LHandle;
  FBitmapPalette := LPalette;
end;

procedure TNimbusRenderCanvas.ConfigureStringFormat(const AFlags: TNimbusTextFlags; const AMeasure: Boolean);
var
  LFormatFlags: Integer;
begin
  LFormatFlags := 0;
  if ntfSingleLine in AFlags then LFormatFlags := LFormatFlags or StringFormatFlagsNoWrap;
  if ntfRightToLeft in AFlags then LFormatFlags := LFormatFlags or StringFormatFlagsDirectionRightToLeft;
  if ntfTypographic in AFlags then LFormatFlags := LFormatFlags or StringFormatFlagsNoFitBlackBox or StringFormatFlagsNoClip;
  if AMeasure then LFormatFlags := LFormatFlags or StringFormatFlagsMeasureTrailingSpaces;
  FStringFormat.SetFormatFlags(LFormatFlags);
  if ntfCenter in AFlags then
    FStringFormat.SetAlignment(StringAlignmentCenter)
  else if ntfRight in AFlags then
    FStringFormat.SetAlignment(StringAlignmentFar)
  else
    FStringFormat.SetAlignment(StringAlignmentNear);
  if ntfVCenter in AFlags then
    FStringFormat.SetLineAlignment(StringAlignmentCenter)
  else if ntfBottom in AFlags then
    FStringFormat.SetLineAlignment(StringAlignmentFar)
  else
    FStringFormat.SetLineAlignment(StringAlignmentNear);
  if ntfEndEllipsis in AFlags then
    FStringFormat.SetTrimming(StringTrimmingEllipsisCharacter)
  else
    FStringFormat.SetTrimming(StringTrimmingNone);
  if ntfNoPrefix in AFlags then
    FStringFormat.SetHotkeyPrefix(HotkeyPrefixNone)
  else
    FStringFormat.SetHotkeyPrefix(HotkeyPrefixShow);
end;

procedure TNimbusRenderCanvas.Clear(const AColor: TThemeColor; const ARect: TRect);
begin
  FillRectangle(AColor, ARect);
end;

procedure TNimbusRenderCanvas.FillRectangle(const AColor: TThemeColor; const ARect: TRect);
begin
  if (FGraphics = nil) or NimbusRectIsEmpty(ARect) then
    Exit;
  SetBrushColor(AColor);
  FGraphics.FillRectangle(FBrush, ARect.Left, ARect.Top, ARect.Width, ARect.Height);
end;

procedure TNimbusRenderCanvas.DrawRectangle(const AColor: TThemeColor; const ARect: TRect; const AWidth: Single);
begin
  if (FGraphics = nil) or NimbusRectIsEmpty(ARect) or (AWidth <= 0) then
    Exit;
  SetPen(AColor, AWidth);
  FGraphics.DrawRectangle(FPen, ARect.Left, ARect.Top, ARect.Width - 1, ARect.Height - 1);
end;

procedure TNimbusRenderCanvas.FillRoundedRectangle(const AColor: TThemeColor; const ARect: TRect; const ARadius: Integer);
begin
  if (FGraphics = nil) or NimbusRectIsEmpty(ARect) then
    Exit;
  if ARadius <= 0 then
  begin
    FillRectangle(AColor, ARect);
    Exit;
  end;
  BuildRoundedPath(ARect, ARadius);
  SetBrushColor(AColor);
  FGraphics.FillPath(FBrush, FPath);
end;

procedure TNimbusRenderCanvas.DrawRoundedRectangle(const AColor: TThemeColor; const ARect: TRect; const ARadius: Integer; const AWidth: Single);
begin
  if (FGraphics = nil) or NimbusRectIsEmpty(ARect) or (AWidth <= 0) then
    Exit;
  if ARadius <= 0 then
  begin
    DrawRectangle(AColor, ARect, AWidth);
    Exit;
  end;
  BuildRoundedPath(ARect, ARadius);
  SetPen(AColor, AWidth);
  FGraphics.DrawPath(FPen, FPath);
end;

procedure TNimbusRenderCanvas.FillEllipse(const AColor: TThemeColor; const ARect: TRect);
begin
  if (FGraphics = nil) or NimbusRectIsEmpty(ARect) then
    Exit;
  SetBrushColor(AColor);
  FGraphics.FillEllipse(FBrush, ARect.Left, ARect.Top, ARect.Width, ARect.Height);
end;

procedure TNimbusRenderCanvas.DrawEllipse(const AColor: TThemeColor; const ARect: TRect; const AWidth: Single);
begin
  if (FGraphics = nil) or NimbusRectIsEmpty(ARect) or (AWidth <= 0) then
    Exit;
  SetPen(AColor, AWidth);
  FGraphics.DrawEllipse(FPen, ARect.Left, ARect.Top, ARect.Width - 1, ARect.Height - 1);
end;

procedure TNimbusRenderCanvas.DrawLine(const AColor: TThemeColor; const AX1, AY1, AX2, AY2: Integer; const AWidth: Single);
begin
  if (FGraphics = nil) or (AWidth <= 0) then
    Exit;
  SetPen(AColor, AWidth);
  FPen.SetDashStyle(DashStyleSolid);
  FPen.SetStartCap(LineCapFlat);
  FPen.SetEndCap(LineCapFlat);
  FGraphics.DrawLine(FPen, AX1, AY1, AX2, AY2);
end;

procedure TNimbusRenderCanvas.DrawArc(const AColor: TThemeColor; const ARect: TRect; const AStartAngle, ASweepAngle, AWidth: Single);
begin
  if (FGraphics = nil) or NimbusRectIsEmpty(ARect) or (AWidth <= 0) then
    Exit;
  SetPen(AColor, AWidth);
  FPen.SetDashStyle(DashStyleSolid);
  FPen.SetStartCap(LineCapRound);
  FPen.SetEndCap(LineCapRound);
  FGraphics.DrawArc(FPen, ARect.Left, ARect.Top, ARect.Width - 1, ARect.Height - 1, AStartAngle, ASweepAngle);
  FPen.SetStartCap(LineCapFlat);
  FPen.SetEndCap(LineCapFlat);
end;

procedure TNimbusRenderCanvas.DrawDashedRectangle(const AColor: TThemeColor; const ARect: TRect; const AWidth: Single);
begin
  if (FGraphics = nil) or NimbusRectIsEmpty(ARect) or (AWidth <= 0) then
    Exit;
  SetPen(AColor, AWidth);
  FPen.SetDashStyle(DashStyleDot);
  FPen.SetStartCap(LineCapFlat);
  FPen.SetEndCap(LineCapFlat);
  FGraphics.DrawRectangle(FPen, ARect.Left, ARect.Top, ARect.Width - 1, ARect.Height - 1);
  FPen.SetDashStyle(DashStyleSolid);
end;

procedure TNimbusRenderCanvas.FillTriangle(const AColor: TThemeColor; const APoint1, APoint2, APoint3: TPoint);
var
  LPoints: array[0..2] of TGPPoint;
begin
  if FGraphics = nil then
    Exit;
  LPoints[0].X := APoint1.X;
  LPoints[0].Y := APoint1.Y;
  LPoints[1].X := APoint2.X;
  LPoints[1].Y := APoint2.Y;
  LPoints[2].X := APoint3.X;
  LPoints[2].Y := APoint3.Y;
  SetBrushColor(AColor);
  FGraphics.FillPolygon(FBrush, PGPPoint(@LPoints[0]), Length(LPoints));
end;

procedure TNimbusRenderCanvas.FillPolygon(const AColor: TThemeColor; const APoints: PNimbusPointBuffer; const ACount: Integer);
var
  LPoints: array[0..255] of TGPPoint;
  I: Integer;
begin
  if (FGraphics = nil) or (APoints = nil) or (ACount < 3) or (ACount > Length(LPoints)) then
    Exit;
  for I := 0 to ACount - 1 do
  begin
    LPoints[I].X := APoints^[I].X;
    LPoints[I].Y := APoints^[I].Y;
  end;
  SetBrushColor(AColor);
  FGraphics.FillPolygon(FBrush, PGPPoint(@LPoints[0]), ACount);
end;

procedure TNimbusRenderCanvas.DrawPolygon(const AColor: TThemeColor; const APoints: PNimbusPointBuffer; const ACount: Integer; const AWidth: Single);
var
  LPoints: array[0..255] of TGPPoint;
  I: Integer;
begin
  if (FGraphics = nil) or (APoints = nil) or (ACount < 2) or (ACount > Length(LPoints)) or (AWidth <= 0) then
    Exit;
  for I := 0 to ACount - 1 do
  begin
    LPoints[I].X := APoints^[I].X;
    LPoints[I].Y := APoints^[I].Y;
  end;
  SetPen(AColor, AWidth);
  FPen.SetDashStyle(DashStyleSolid);
  FPen.SetStartCap(LineCapFlat);
  FPen.SetEndCap(LineCapFlat);
  FGraphics.DrawPolygon(FPen, PGPPoint(@LPoints[0]), ACount);
end;

procedure TNimbusRenderCanvas.DrawFocusRectangle(const AColor: TThemeColor; const ARect: TRect);
begin
  DrawRectangle(AColor, ARect, 1.0);
end;

procedure TNimbusRenderCanvas.DrawIcon(const AIcon: HICON; const ARect: TRect);
begin
  if (FGraphics = nil) or (AIcon = 0) or NimbusRectIsEmpty(ARect) then Exit;
  if (FIconBitmap = nil) or (FIconBitmapHandle <> AIcon) then
  begin
    FIconBitmap.Free;
    FIconBitmap := TGPBitmap.Create(AIcon);
    FIconBitmapHandle := AIcon;
  end;
  FGraphics.DrawImage(FIconBitmap, ARect.Left, ARect.Top, ARect.Width, ARect.Height);
end;

procedure TNimbusRenderCanvas.DrawBitmap(const ABitmap: Vcl.Graphics.TBitmap; const ARect: TRect);
begin
  if (FGraphics = nil) or (ABitmap = nil) or ABitmap.Empty or NimbusRectIsEmpty(ARect) then
    Exit;
  EnsureBitmapImage(ABitmap);
  if FBitmapImage = nil then
    Exit;
  FGraphics.DrawImage(FBitmapImage, ARect.Left, ARect.Top, ARect.Width, ARect.Height);
end;

procedure TNimbusRenderCanvas.DrawBitmapPart(const ABitmap: Vcl.Graphics.TBitmap; const ADestRect, ASourceRect: TRect);
var
  LDestRect: TGPRectF;
begin
  if (FGraphics = nil) or (ABitmap = nil) or ABitmap.Empty or NimbusRectIsEmpty(ADestRect) or NimbusRectIsEmpty(ASourceRect) then
    Exit;
  EnsureBitmapImage(ABitmap);
  if FBitmapImage = nil then
    Exit;
  LDestRect.X := ADestRect.Left;
  LDestRect.Y := ADestRect.Top;
  LDestRect.Width := ADestRect.Width;
  LDestRect.Height := ADestRect.Height;
  FGraphics.DrawImage(FBitmapImage, LDestRect, Single(ASourceRect.Left), Single(ASourceRect.Top),
    Single(ASourceRect.Width), Single(ASourceRect.Height), UnitPixel);
end;

procedure TNimbusRenderCanvas.DrawText(const AText: string; const AFont: TFont; const AColor: TThemeColor; const ARect: TRect; const AFlags: TNimbusTextFlags);
var
  LRect: TGPRectF;
begin
  if (FGraphics = nil) or (AFont = nil) or (AText = '') or NimbusRectIsEmpty(ARect) then
    Exit;
  EnsureTextFont(AFont);
  if FTextFont = nil then
    Exit;
  ConfigureStringFormat(AFlags, False);
  SetBrushColor(AColor);
  LRect.X := ARect.Left;
  LRect.Y := ARect.Top;
  LRect.Width := ARect.Width;
  LRect.Height := ARect.Height;
  FGraphics.DrawString(AText, Length(AText), FTextFont, LRect, FStringFormat, FBrush);
end;

function TNimbusRenderCanvas.MeasureText(const AText: string; const AFont: TFont; const AMaxWidth: Integer; const AFlags: TNimbusTextFlags): TSize;
var
  LLayout, LBounds: TGPRectF;
begin
  Result.cx := 0;
  Result.cy := 0;
  if (FGraphics = nil) or (AFont = nil) or (AText = '') then
    Exit;
  EnsureTextFont(AFont);
  if FTextFont = nil then
    Exit;
  ConfigureStringFormat(AFlags, True);
  LLayout.X := 0;
  LLayout.Y := 0;
  if AMaxWidth > 0 then LLayout.Width := AMaxWidth else LLayout.Width := 32767;
  LLayout.Height := 32767;
  FGraphics.MeasureString(AText, Length(AText), FTextFont, LLayout, FStringFormat, LBounds);
  Result.cx := Ceil(LBounds.Width);
  Result.cy := Ceil(LBounds.Height);
end;

end.

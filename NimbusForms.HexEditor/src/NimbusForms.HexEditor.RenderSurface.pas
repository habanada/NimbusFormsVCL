unit NimbusForms.HexEditor.RenderSurface;

interface

uses
  Winapi.Windows,
  Winapi.GDIPAPI,
  Winapi.GDIPOBJ,
  System.Types,
  System.UITypes,
  System.Generics.Collections,
  Vcl.Graphics,
  NimbusForms.Theming.Types,
  NimbusForms.HexEditor.Types;

type
  IHexRenderSurface = interface
    ['{2A9F4C31-5B7E-4D28-9A16-8C3B2E5D7F41}']
    procedure BeginRender(const ACanvas: TCanvas);
    procedure EndRender;
    procedure SetFont(const AFont: TFont);
    function MeasureText(const AText: string): TSize;
    procedure FillRectangle(const AColor: TThemeColor; const ARect: TRect);
    procedure DrawRectangle(const AColor: TThemeColor; const ARect: TRect);
    procedure DrawLine(const AColor: TThemeColor; const AX1, AY1, AX2, AY2: Integer);
    procedure DrawText(const AText: string; const ARect: TRect; const AColor: TThemeColor; const AFlags: THexTextFlags);
    procedure FillTriangle(const AColor: TThemeColor; const AP1, AP2, AP3: TPoint);
    procedure FillRoundedRectangle(const AColor: TThemeColor; const ARect: TRect; const ARadius: Integer);
    procedure PushClip(const ARect: TRect);
    procedure PopClip;
  end;

  TGdiPlusHexRenderSurface = class(TInterfacedObject, IHexRenderSurface)
  private
    FCanvas: TCanvas;
    FGraphics: TGPGraphics;
    FPen: TGPPen;
    FBrush: TGPSolidBrush;
    FPath: TGPGraphicsPath;
    FStringFormat: TGPStringFormat;
    FFont: TGPFont;
    FFontHandle: HFONT;
    FFontName: string;
    FFontHeight: Integer;
    FFontStyle: TFontStyles;
    FFontCharset: TFontCharset;
    FFontPPI: Integer;
    FClipStack: TStack<GraphicsState>;
    procedure SetBrushColor(const AColor: TThemeColor);
    procedure SetPenColor(const AColor: TThemeColor);
    procedure ConfigureTextFormat(const AFlags: THexTextFlags; const AMeasure: Boolean);
    procedure BuildRoundedPath(const ARect: TRect; const ARadius: Integer);
  public
    constructor Create; overload;
    constructor Create(const ACanvas: TCanvas); overload;
    destructor Destroy; override;
    procedure BeginRender(const ACanvas: TCanvas);
    procedure EndRender;
    procedure SetFont(const AFont: TFont);
    function MeasureText(const AText: string): TSize;
    procedure FillRectangle(const AColor: TThemeColor; const ARect: TRect);
    procedure DrawRectangle(const AColor: TThemeColor; const ARect: TRect);
    procedure DrawLine(const AColor: TThemeColor; const AX1, AY1, AX2, AY2: Integer);
    procedure DrawText(const AText: string; const ARect: TRect; const AColor: TThemeColor; const AFlags: THexTextFlags);
    procedure FillTriangle(const AColor: TThemeColor; const AP1, AP2, AP3: TPoint);
    procedure FillRoundedRectangle(const AColor: TThemeColor; const ARect: TRect; const ARadius: Integer);
    procedure PushClip(const ARect: TRect);
    procedure PopClip;
  end;

  TGdiHexRenderSurface = TGdiPlusHexRenderSurface;

implementation

uses
  System.Math;

constructor TGdiPlusHexRenderSurface.Create;
begin
  inherited Create;
  FPen := TGPPen.Create(0, 1.0);
  FBrush := TGPSolidBrush.Create(0);
  FPath := TGPGraphicsPath.Create;
  FStringFormat := TGPStringFormat.Create;
  FClipStack := TStack<GraphicsState>.Create;
end;

constructor TGdiPlusHexRenderSurface.Create(const ACanvas: TCanvas);
begin
  Create;
  BeginRender(ACanvas);
end;

destructor TGdiPlusHexRenderSurface.Destroy;
begin
  EndRender;
  FFont.Free;
  FStringFormat.Free;
  FPath.Free;
  FBrush.Free;
  FPen.Free;
  FClipStack.Free;
  inherited Destroy;
end;

procedure TGdiPlusHexRenderSurface.BeginRender(const ACanvas: TCanvas);
begin
  EndRender;
  FCanvas := ACanvas;
  if FCanvas = nil then
    Exit;
  FGraphics := TGPGraphics.Create(FCanvas.Handle);
  FGraphics.SetPageUnit(UnitPixel);
  FGraphics.SetSmoothingMode(SmoothingModeAntiAlias);
  FGraphics.SetPixelOffsetMode(PixelOffsetModeHighQuality);
  FGraphics.SetInterpolationMode(InterpolationModeHighQualityBicubic);
  FGraphics.SetCompositingQuality(CompositingQualityHighQuality);
  FGraphics.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);
end;

procedure TGdiPlusHexRenderSurface.EndRender;
begin
  FClipStack.Clear;
  FGraphics.Free;
  FGraphics := nil;
  FCanvas := nil;
end;

procedure TGdiPlusHexRenderSurface.SetBrushColor(const AColor: TThemeColor);
begin
  FBrush.SetColor(ARGB(AColor));
end;

procedure TGdiPlusHexRenderSurface.SetPenColor(const AColor: TThemeColor);
begin
  FPen.SetColor(ARGB(AColor));
  FPen.SetWidth(1.0);
end;

procedure TGdiPlusHexRenderSurface.SetFont(const AFont: TFont);
begin
  if (FGraphics = nil) or (FCanvas = nil) or (AFont = nil) then
    Exit;
  if (FFont <> nil) and (FFontHandle = AFont.Handle) and (FFontName = AFont.Name) and
    (FFontHeight = AFont.Height) and (FFontStyle = AFont.Style) and
    (FFontCharset = AFont.Charset) and (FFontPPI = AFont.PixelsPerInch) then
    Exit;
  FFont.Free;
  FFont := TGPFont.Create(FCanvas.Handle, AFont.Handle);
  FFontHandle := AFont.Handle;
  FFontName := AFont.Name;
  FFontHeight := AFont.Height;
  FFontStyle := AFont.Style;
  FFontCharset := AFont.Charset;
  FFontPPI := AFont.PixelsPerInch;
end;

procedure TGdiPlusHexRenderSurface.ConfigureTextFormat(const AFlags: THexTextFlags; const AMeasure: Boolean);
var
  LFormatFlags: Integer;
begin
  LFormatFlags := StringFormatFlagsNoWrap;
  if AMeasure then LFormatFlags := LFormatFlags or StringFormatFlagsMeasureTrailingSpaces;
  FStringFormat.SetFormatFlags(LFormatFlags);
  if htfRight in AFlags then
    FStringFormat.SetAlignment(StringAlignmentFar)
  else if htfHCenter in AFlags then
    FStringFormat.SetAlignment(StringAlignmentCenter)
  else
    FStringFormat.SetAlignment(StringAlignmentNear);
  if htfVCenter in AFlags then
    FStringFormat.SetLineAlignment(StringAlignmentCenter)
  else
    FStringFormat.SetLineAlignment(StringAlignmentNear);
  FStringFormat.SetTrimming(StringTrimmingNone);
  FStringFormat.SetHotkeyPrefix(HotkeyPrefixNone);
end;

function TGdiPlusHexRenderSurface.MeasureText(const AText: string): TSize;
var
  LLayout, LBounds: TGPRectF;
begin
  Result.cx := 0;
  Result.cy := 0;
  if (FGraphics = nil) or (FFont = nil) or (AText = '') then
    Exit;
  ConfigureTextFormat([htfLeft, htfNoPadding], True);
  LLayout.X := 0;
  LLayout.Y := 0;
  LLayout.Width := 32767;
  LLayout.Height := 32767;
  FGraphics.MeasureString(AText, Length(AText), FFont, LLayout, FStringFormat, LBounds);
  Result.cx := Ceil(LBounds.Width);
  Result.cy := Ceil(LBounds.Height);
end;

procedure TGdiPlusHexRenderSurface.FillRectangle(const AColor: TThemeColor; const ARect: TRect);
begin
  if (FGraphics = nil) or (ARect.Right <= ARect.Left) or (ARect.Bottom <= ARect.Top) then
    Exit;
  SetBrushColor(AColor);
  FGraphics.FillRectangle(FBrush, ARect.Left, ARect.Top, ARect.Width, ARect.Height);
end;

procedure TGdiPlusHexRenderSurface.DrawRectangle(const AColor: TThemeColor; const ARect: TRect);
begin
  if (FGraphics = nil) or (ARect.Right <= ARect.Left) or (ARect.Bottom <= ARect.Top) then
    Exit;
  SetPenColor(AColor);
  FGraphics.DrawRectangle(FPen, ARect.Left, ARect.Top, ARect.Width - 1, ARect.Height - 1);
end;

procedure TGdiPlusHexRenderSurface.DrawLine(const AColor: TThemeColor; const AX1, AY1, AX2, AY2: Integer);
begin
  if FGraphics = nil then
    Exit;
  SetPenColor(AColor);
  FGraphics.DrawLine(FPen, AX1, AY1, AX2, AY2);
end;

procedure TGdiPlusHexRenderSurface.DrawText(const AText: string; const ARect: TRect; const AColor: TThemeColor; const AFlags: THexTextFlags);
var
  LRect: TGPRectF;
begin
  if (FGraphics = nil) or (FFont = nil) or (AText = '') or (ARect.Right <= ARect.Left) or (ARect.Bottom <= ARect.Top) then
    Exit;
  ConfigureTextFormat(AFlags, False);
  SetBrushColor(AColor);
  LRect.X := ARect.Left;
  LRect.Y := ARect.Top;
  LRect.Width := ARect.Width;
  LRect.Height := ARect.Height;
  FGraphics.DrawString(AText, Length(AText), FFont, LRect, FStringFormat, FBrush);
end;

procedure TGdiPlusHexRenderSurface.FillTriangle(const AColor: TThemeColor; const AP1, AP2, AP3: TPoint);
var
  LPoints: array[0..2] of TGPPoint;
begin
  if FGraphics = nil then
    Exit;
  LPoints[0].X := AP1.X;
  LPoints[0].Y := AP1.Y;
  LPoints[1].X := AP2.X;
  LPoints[1].Y := AP2.Y;
  LPoints[2].X := AP3.X;
  LPoints[2].Y := AP3.Y;
  SetBrushColor(AColor);
  FGraphics.FillPolygon(FBrush, PGPPoint(@LPoints[0]), Length(LPoints));
end;

procedure TGdiPlusHexRenderSurface.BuildRoundedPath(const ARect: TRect; const ARadius: Integer);
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

procedure TGdiPlusHexRenderSurface.FillRoundedRectangle(const AColor: TThemeColor; const ARect: TRect; const ARadius: Integer);
begin
  if (FGraphics = nil) or (ARect.Right <= ARect.Left) or (ARect.Bottom <= ARect.Top) then
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

procedure TGdiPlusHexRenderSurface.PushClip(const ARect: TRect);
var
  LState: GraphicsState;
  LRect: TGPRect;
begin
  if FGraphics = nil then
    Exit;
  LState := FGraphics.Save;
  FClipStack.Push(LState);
  LRect.X := ARect.Left;
  LRect.Y := ARect.Top;
  LRect.Width := ARect.Width;
  LRect.Height := ARect.Height;
  FGraphics.SetClip(LRect, CombineModeIntersect);
end;

procedure TGdiPlusHexRenderSurface.PopClip;
var
  LState: GraphicsState;
begin
  if (FGraphics = nil) or (FClipStack.Count = 0) then
    Exit;
  LState := FClipStack.Pop;
  FGraphics.Restore(LState);
end;

end.

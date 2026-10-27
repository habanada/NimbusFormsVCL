{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.

  Optional graphics dependencies (licensed separately):
  Skia4Delphi: Copyright (c) 2021-2026 Skia4Delphi.
  License: MIT. See LICENSES/Skia4Delphi-MIT.txt.
  https://github.com/skia4delphi/skia4delphi
  Skia: Copyright (c) 2011 Google Inc. All rights reserved.
  License: BSD-3-Clause. See LICENSES/Skia-BSD-3-Clause.txt.
  https://github.com/google/skia
  NimbusForms does not distribute Skia binaries.
}

unit NimbusForms.Rendering.CodeEditor.SkiaBridge;

interface

function NimbusCodeRendererGetAPI(Version: Cardinal; API: Pointer; APISize: Cardinal): Integer; cdecl;

implementation

uses Winapi.Windows, System.SysUtils, System.Types, System.Math, System.UITypes,
  System.Generics.Collections, System.Skia, NimbusForms.Rendering.CodeEditor.DLL.Types;

type
  PCodeRendererDLLFont = ^TCodeRendererDLLFont;
  PCodeRendererDLLAPI = ^TCodeRendererDLLAPI;
  TSkiaCodeRenderer = class
  private
    FSurface: ISkSurface;
    FPaint: ISkPaint;
    FParagraphs: TDictionary<string, ISkParagraph>;
    FMemoryDC, FTargetDC: HDC;
    FRuntime: HMODULE;
    FBitmap: HBITMAP;
    FPreviousBitmap: HGDIOBJ;
    FPixels: Pointer;
    FWidth, FHeight, FClipDepth: Integer;
    FBounds: TRect;
    FActive: Boolean;
    procedure ReleaseBuffer;
    procedure RequireFrame;
    procedure SetPaint(const Color: Cardinal; const Width: Single; const Stroke: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure BeginFrame(const DC: HDC; const Bounds: TRect);
    procedure EndFrame;
    function Paragraph(const Value: string; Font: PCodeRendererDLLFont; const Color: Cardinal): ISkParagraph;
    procedure Fill(const Bounds: TRect; const Color: Cardinal);
    procedure Stroke(const Bounds: TRect; const Color: Cardinal; const Width: Single);
    procedure Line(const X1, Y1, X2, Y2: Integer; const Color: Cardinal; const Width: Single);
    procedure Text(const Value: string; Font: PCodeRendererDLLFont; const Bounds: TRect; const Color: Cardinal);
    procedure PushClip(const Bounds: TRect);
    procedure PopClip;
  end;

constructor TSkiaCodeRenderer.Create;
var Buffer: array[0..32767] of Char; Count: DWORD; Path: string;
begin
  inherited;
  Count := GetModuleFileName(HInstance, PChar(@Buffer[0]), Length(Buffer));
  if Count = 0 then RaiseLastOSError;
  if Count >= DWORD(Length(Buffer)) then raise EInvalidOpException.Create('Renderer module path is too long');
  SetString(Path, PChar(@Buffer[0]), Count); Path := ExtractFilePath(Path) + 'sk4d.dll';
  FRuntime := LoadLibraryEx(PChar(Path), 0, $00000100 or $00001000);
  if FRuntime = 0 then RaiseLastOSError;
  if GetModuleHandle('sk4d.dll') <> FRuntime then raise EInvalidOpException.Create('Another Skia runtime is already loaded');
  FParagraphs := TDictionary<string, ISkParagraph>.Create; FPaint := TSkPaint.Create;
  FPaint.AntiAlias := True;
end;
destructor TSkiaCodeRenderer.Destroy;
begin
  ReleaseBuffer; if FMemoryDC <> 0 then DeleteDC(FMemoryDC);
  FParagraphs.Free; FPaint := nil; if FRuntime <> 0 then FreeLibrary(FRuntime); inherited;
end;
procedure TSkiaCodeRenderer.ReleaseBuffer;
begin
  FSurface := nil;
  if FBitmap <> 0 then
  begin SelectObject(FMemoryDC, FPreviousBitmap); DeleteObject(FBitmap); FBitmap := 0; end;
  FPixels := nil; FWidth := 0; FHeight := 0; FPreviousBitmap := 0;
end;
procedure TSkiaCodeRenderer.RequireFrame;
begin if not FActive then raise EInvalidOpException.Create('Skia frame is not active'); end;
procedure TSkiaCodeRenderer.BeginFrame(const DC: HDC; const Bounds: TRect);
var Info: TBitmapInfo; Width, Height: Integer;
begin
  if FActive then raise EInvalidOpException.Create('Skia frame is already active');
  Width := Bounds.Width; Height := Bounds.Height;
  if (DC = 0) or (Width <= 0) or (Height <= 0) or (Int64(Width) * Height > 134217728) then
    raise EArgumentException.Create('Invalid Skia frame bounds');
  if FMemoryDC = 0 then begin FMemoryDC := CreateCompatibleDC(DC); if FMemoryDC = 0 then RaiseLastOSError; end;
  if (Width <> FWidth) or (Height <> FHeight) or (FSurface = nil) then
  begin
    ReleaseBuffer; Info := Default(TBitmapInfo); Info.bmiHeader.biSize := SizeOf(TBitmapInfoHeader);
    Info.bmiHeader.biWidth := Width; Info.bmiHeader.biHeight := -Height;
    Info.bmiHeader.biPlanes := 1; Info.bmiHeader.biBitCount := 32; Info.bmiHeader.biCompression := BI_RGB;
    FBitmap := CreateDIBSection(FMemoryDC, Info, DIB_RGB_COLORS, FPixels, 0, 0);
    if FBitmap = 0 then RaiseLastOSError;
    FPreviousBitmap := SelectObject(FMemoryDC, FBitmap); FWidth := Width; FHeight := Height;
    FSurface := TSkSurface.MakeRasterDirect(TSkImageInfo.Create(Width, Height, TSkColorType.BGRA8888, TSkAlphaType.Opaque), FPixels, NativeUInt(Width) * 4);
    if FSurface = nil then raise EInvalidOpException.Create('Skia raster surface creation failed');
  end;
  if not BitBlt(FMemoryDC, 0, 0, Width, Height, DC, Bounds.Left, Bounds.Top, SRCCOPY) then RaiseLastOSError;
  FBounds := Bounds; FTargetDC := DC; FClipDepth := 0;
  FSurface.Canvas.RestoreToCount(1); FSurface.Canvas.Save;
  FSurface.Canvas.Translate(-Bounds.Left, -Bounds.Top); FActive := True;
end;
procedure TSkiaCodeRenderer.EndFrame;
begin
  RequireFrame;
  try
    FSurface.Canvas.RestoreToCount(1); FClipDepth := 0;
    if not BitBlt(FTargetDC, FBounds.Left, FBounds.Top, FWidth, FHeight, FMemoryDC, 0, 0, SRCCOPY) then RaiseLastOSError;
  finally FActive := False; FTargetDC := 0; end;
end;
procedure TSkiaCodeRenderer.SetPaint(const Color: Cardinal; const Width: Single; const Stroke: Boolean);
begin
  RequireFrame; FPaint.Color := TAlphaColor(Color); FPaint.StrokeWidth := Width;
  if Stroke then FPaint.Style := TSkPaintStyle.Stroke else FPaint.Style := TSkPaintStyle.Fill;
end;
procedure TSkiaCodeRenderer.Fill(const Bounds: TRect; const Color: Cardinal);
begin SetPaint(Color, 1, False); FSurface.Canvas.DrawRect(TRectF.Create(Bounds), FPaint); end;
procedure TSkiaCodeRenderer.Stroke(const Bounds: TRect; const Color: Cardinal; const Width: Single);
var R: TRectF;
begin
  if IsNan(Width) or IsInfinite(Width) or (Width <= 0) then raise EArgumentException.Create('Invalid stroke width');
  SetPaint(Color, Width, True); R := TRectF.Create(Bounds); R.Inflate(-Width / 2, -Width / 2);
  if (R.Width > 0) and (R.Height > 0) then FSurface.Canvas.DrawRect(R, FPaint);
end;
procedure TSkiaCodeRenderer.Line(const X1, Y1, X2, Y2: Integer; const Color: Cardinal; const Width: Single);
begin
  if IsNan(Width) or IsInfinite(Width) or (Width <= 0) then raise EArgumentException.Create('Invalid line width');
  SetPaint(Color, Width, True); FSurface.Canvas.DrawLine(X1, Y1, X2, Y2, FPaint);
end;
function TSkiaCodeRenderer.Paragraph(const Value: string; Font: PCodeRendererDLLFont; const Color: Cardinal): ISkParagraph;
var Name, Key: string; Style: ISkTextStyle; ParagraphStyle: ISkParagraphStyle; Builder: ISkParagraphBuilder;
  Weight: TSkFontWeight; Slant: TSkFontSlant; Decorations: TSkTextDecorations;
begin
  if (Font = nil) or (Font.StructSize <> SizeOf(TCodeRendererDLLFont)) or (Font.NameLength > 256) or
    ((Font.Name = nil) and (Font.NameLength <> 0)) or (Font.PixelHeight <= 0) or (Font.PixelHeight > 4096) then
    raise EArgumentException.Create('Invalid renderer font');
  SetString(Name, Font.Name, Font.NameLength); if Name = '' then Name := 'Consolas';
  Key := IntToStr(Font.PixelHeight) + ':' + UIntToStr(Font.Style) + ':' + UIntToStr(Color) + ':' + IntToStr(Length(Name)) + ':' + Name + Value;
  if FParagraphs.TryGetValue(Key, Result) then Exit;
  Style := TSkTextStyle.Create; Style.Color := TAlphaColor(Color); Style.FontSize := Font.PixelHeight;
  Style.FontFamilies := TArray<string>.Create(Name, 'Segoe UI Emoji', 'Segoe UI Symbol');
  Weight := TSkFontWeight.Normal; if Font.Style and 1 <> 0 then Weight := TSkFontWeight.Bold;
  Slant := TSkFontSlant.Upright; if Font.Style and 2 <> 0 then Slant := TSkFontSlant.Italic;
  Style.FontStyle := TSkFontStyle.Create(Weight, TSkFontWidth.Normal, Slant);
  Decorations := []; if Font.Style and 4 <> 0 then Include(Decorations, TSkTextDecoration.Underline);
  if Font.Style and 8 <> 0 then Include(Decorations, TSkTextDecoration.LineThrough);
  Style.Decorations := Decorations; Style.DecorationColor := TAlphaColor(Color);
  Style.AddFontFeature('liga', 0); Style.AddFontFeature('calt', 0);
  ParagraphStyle := TSkParagraphStyle.Create; ParagraphStyle.MaxLines := 1;
  ParagraphStyle.TextStyle := Style; Builder := TSkParagraphBuilder.Create(ParagraphStyle);
  Builder.PushStyle(Style); Builder.AddText(Value); Result := Builder.Build; Result.Layout(1000000);
  if FParagraphs.Count >= 512 then FParagraphs.Clear;
  if Length(Value) <= 4096 then FParagraphs.Add(Key, Result);
end;
procedure TSkiaCodeRenderer.Text(const Value: string; Font: PCodeRendererDLLFont; const Bounds: TRect; const Color: Cardinal);
var P: ISkParagraph;
begin
  RequireFrame; if Value = '' then Exit; P := Paragraph(Value, Font, Color);
  P.Paint(FSurface.Canvas, Bounds.Left, Bounds.Top + (Bounds.Height - P.Height) / 2);
end;
procedure TSkiaCodeRenderer.PushClip(const Bounds: TRect);
begin RequireFrame; FSurface.Canvas.Save; FSurface.Canvas.ClipRect(TRectF.Create(Bounds)); Inc(FClipDepth); end;
procedure TSkiaCodeRenderer.PopClip;
begin
  RequireFrame; if FClipDepth = 0 then raise EInvalidOpException.Create('Unbalanced Skia clip stack');
  FSurface.Canvas.Restore; Dec(FClipDepth);
end;

function Renderer(Instance: Pointer): TSkiaCodeRenderer;
begin if Instance = nil then raise EArgumentNilException.Create('Renderer instance'); Result := TSkiaCodeRenderer(Instance); end;
function ReadText(Value: PWideChar; const Length: Cardinal): string;
begin
  if (Length > 16777216) or ((Value = nil) and (Length <> 0)) then raise EArgumentException.Create('Invalid text buffer');
  SetString(Result, Value, Length);
end;
function ReadBounds(Bounds: PRect): TRect;
begin if Bounds = nil then raise EArgumentNilException.Create('Bounds'); Result := Bounds^; end;
function BridgeCreate: Pointer; cdecl;
begin try Result := TSkiaCodeRenderer.Create; except Result := nil; end; end;
procedure BridgeDestroy(Instance: Pointer); cdecl;
begin try TSkiaCodeRenderer(Instance).Free; except SetLastError(ERROR_GEN_FAILURE); end; end;
function BridgeBegin(Instance: Pointer; DC: HDC; Bounds: PRect; PPI: Cardinal): Integer; cdecl;
begin try Renderer(Instance).BeginFrame(DC, ReadBounds(Bounds)); Result := 0; except Result := -1; end; end;
function BridgeEnd(Instance: Pointer): Integer; cdecl;
begin try Renderer(Instance).EndFrame; Result := 0; except Result := -1; end; end;
function BridgeFill(Instance: Pointer; Bounds: PRect; Color: Cardinal): Integer; cdecl;
begin try Renderer(Instance).Fill(ReadBounds(Bounds), Color); Result := 0; except Result := -1; end; end;
function BridgeStroke(Instance: Pointer; Bounds: PRect; Color: Cardinal; Width: Single): Integer; cdecl;
begin try Renderer(Instance).Stroke(ReadBounds(Bounds), Color, Width); Result := 0; except Result := -1; end; end;
function BridgeLine(Instance: Pointer; X1, Y1, X2, Y2: Integer; Color: Cardinal; Width: Single): Integer; cdecl;
begin try Renderer(Instance).Line(X1, Y1, X2, Y2, Color, Width); Result := 0; except Result := -1; end; end;
function BridgeText(Instance: Pointer; Value: PWideChar; Length: Cardinal; Font: Pointer; Bounds: PRect; Color: Cardinal): Integer; cdecl;
begin try Renderer(Instance).Text(ReadText(Value, Length), PCodeRendererDLLFont(Font), ReadBounds(Bounds), Color); Result := 0; except Result := -1; end; end;
function BridgeMeasure(Instance: Pointer; Value: PWideChar; Length: Cardinal; Font: Pointer; Width, Height: PInteger): Integer; cdecl;
var P: ISkParagraph;
begin
  try
    if (Width = nil) or (Height = nil) then raise EArgumentNilException.Create('Measurement output');
    P := Renderer(Instance).Paragraph(ReadText(Value, Length), PCodeRendererDLLFont(Font), $FFFFFFFF);
    Width^ := Ceil(P.MaxIntrinsicWidth); Height^ := Ceil(P.Height); Result := 0;
  except Result := -1; end;
end;
function BridgeClip(Instance: Pointer; Bounds: PRect): Integer; cdecl;
begin try Renderer(Instance).PushClip(ReadBounds(Bounds)); Result := 0; except Result := -1; end; end;
function BridgePop(Instance: Pointer): Integer; cdecl;
begin try Renderer(Instance).PopClip; Result := 0; except Result := -1; end; end;
function NimbusCodeRendererGetAPI(Version: Cardinal; API: Pointer; APISize: Cardinal): Integer; cdecl;
var Value: TCodeRendererDLLAPI;
begin
  Result := -2; if (Version <> 1) or (API = nil) or (APISize <> SizeOf(Value)) then Exit;
  Value := Default(TCodeRendererDLLAPI); Value.StructSize := SizeOf(Value); Value.Version := 1;
  Value.CreateInstance := BridgeCreate; Value.DestroyInstance := BridgeDestroy;
  Value.BeginFrame := BridgeBegin; Value.EndFrame := BridgeEnd; Value.FillRectangle := BridgeFill;
  Value.StrokeRectangle := BridgeStroke; Value.DrawLine := BridgeLine; Value.DrawText := BridgeText;
  Value.MeasureText := BridgeMeasure; Value.PushClip := BridgeClip; Value.PopClip := BridgePop;
  PCodeRendererDLLAPI(API)^ := Value; Result := 0;
end;

end.

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

program NimbusSkiaBridgeTests;

{$APPTYPE CONSOLE}

uses Winapi.Windows, System.SysUtils, System.Types, Vcl.Graphics,
  NimbusForms.Rendering.CodeEditor.DLL.Types;

procedure Check(const Value: Boolean; const MessageText: string);
begin if not Value then raise EInvalidOpException.Create(MessageText); end;

procedure Run;
var Module: HMODULE; GetAPI: TCodeRendererDLLGetAPI; API: TCodeRendererDLLAPI;
  Instance: Pointer; Bitmap: TBitmap; Bounds, Clip, TextBounds: TRect; Font: TCodeRendererDLLFont;
  Name, Text: string; Width, Height, X, Y: Integer; Pixel: COLORREF; ColorFound, Active: Boolean;
begin
  Check(ParamCount = 1, 'Pass the absolute renderer DLL path');
  Module := LoadLibraryEx(PChar(ExpandFileName(ParamStr(1))), 0, $00000100 or $00001000);
  if Module = 0 then RaiseLastOSError;
  Instance := nil; Bitmap := nil; Active := False;
  try
    GetAPI := TCodeRendererDLLGetAPI(GetProcAddress(Module, 'NimbusCodeRendererGetAPI'));
    Check(Assigned(GetAPI), 'Missing renderer API export');
    API := Default(TCodeRendererDLLAPI);
    Check(GetAPI(2, @API, SizeOf(API)) <> 0, 'Unsupported ABI version must be rejected');
    Check(GetAPI(1, @API, SizeOf(API) - 1) <> 0, 'Incorrect ABI size must be rejected');
    Check(GetAPI(1, @API, SizeOf(API)) = 0, 'Renderer ABI negotiation');
    Check((API.Version = 1) and (API.StructSize = SizeOf(API)), 'Renderer ABI metadata');
    Instance := API.CreateInstance(); Check(Instance <> nil, 'Skia instance creation');
    Bitmap := TBitmap.Create; Bitmap.PixelFormat := pf32bit; Bitmap.SetSize(320, 96);
    Bounds := Rect(0, 0, 320, 96); Clip := Rect(0, 0, 20, 20); TextBounds := Rect(120, 4, 300, 92);
    Check(API.BeginFrame(Instance, Bitmap.Canvas.Handle, @Bounds, 96) = 0, 'Skia frame creation'); Active := True;
    Check(API.PopClip(Instance) <> 0, 'Clip underflow must be rejected');
    Check(API.FillRectangle(Instance, @Bounds, $FF202020) = 0, 'Background fill');
    Check(API.PushClip(Instance, @Clip) = 0, 'Clip push');
    Check(API.FillRectangle(Instance, @Bounds, $FFFF0000) = 0, 'Clipped fill');
    Check(API.PopClip(Instance) = 0, 'Clip pop');
    Name := 'Consolas'; Font := Default(TCodeRendererDLLFont); Font.StructSize := SizeOf(Font);
    Font.Name := PWideChar(Name); Font.NameLength := Length(Name); Font.PixelHeight := 48; Font.PPI := 96;
    Text := '00000000';
    Check(API.MeasureText(Instance, PWideChar(Text), Length(Text), @Font, @Width, @Height) = 0, 'Skia text measurement');
    Check((Width > 0) and (Height > 0), 'Positive Skia text dimensions');
    Text := Char($D83C) + Char($DF08);
    Check(API.DrawText(Instance, PWideChar(Text), Length(Text), @Font, @TextBounds, $FFFFFFFF) = 0, 'Color emoji paragraph');
    Check(API.EndFrame(Instance) = 0, 'Frame presentation'); Active := False;
    Check(Bitmap.Canvas.Pixels[5, 5] = RGB(255, 0, 0), 'Clip interior color');
    Check(Bitmap.Canvas.Pixels[30, 5] = RGB(32, 32, 32), 'Clip excludes outside pixels');
    ColorFound := False;
    for Y := 4 to 91 do for X := 120 to 299 do
    begin
      Pixel := ColorToRGB(Bitmap.Canvas.Pixels[X, Y]);
      if (GetRValue(Pixel) <> GetGValue(Pixel)) or (GetGValue(Pixel) <> GetBValue(Pixel)) then ColorFound := True;
    end;
    Check(ColorFound, 'Rainbow emoji must contain colored pixels with the installed emoji font');
    Writeln('Skia DLL ABI, measurement, clipping, presentation and color emoji checks passed');
  finally
    if Instance <> nil then
    begin if Active then API.EndFrame(Instance); API.DestroyInstance(Instance); end;
    Bitmap.Free; FreeLibrary(Module);
  end;
end;

begin
  try Run; except on E: Exception do begin Writeln(E.ClassName + ': ' + E.Message); ExitCode := 1; end; end;
end.

{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.CodeEditor.DLL.Types;

interface

uses Winapi.Windows, System.Types;

type
  TCodeRendererDLLFont = record
    StructSize: Cardinal;
    Name: PWideChar;
    NameLength: Cardinal;
    PixelHeight: Integer;
    Style, PPI: Cardinal;
  end;
  TCodeRendererDLLCreate = function: Pointer; cdecl;
  TCodeRendererDLLDestroy = procedure(Instance: Pointer); cdecl;
  TCodeRendererDLLBegin = function(Instance: Pointer; DC: HDC; Bounds: PRect; PPI: Cardinal): Integer; cdecl;
  TCodeRendererDLLEnd = function(Instance: Pointer): Integer; cdecl;
  TCodeRendererDLLFill = function(Instance: Pointer; Bounds: PRect; Color: Cardinal): Integer; cdecl;
  TCodeRendererDLLStroke = function(Instance: Pointer; Bounds: PRect; Color: Cardinal; Width: Single): Integer; cdecl;
  TCodeRendererDLLLine = function(Instance: Pointer; X1, Y1, X2, Y2: Integer; Color: Cardinal; Width: Single): Integer; cdecl;
  TCodeRendererDLLText = function(Instance: Pointer; Value: PWideChar; Length: Cardinal;
    Font: Pointer; Bounds: PRect; Color: Cardinal): Integer; cdecl;
  TCodeRendererDLLMeasure = function(Instance: Pointer; Value: PWideChar; Length: Cardinal;
    Font: Pointer; Width, Height: PInteger): Integer; cdecl;
  TCodeRendererDLLClip = function(Instance: Pointer; Bounds: PRect): Integer; cdecl;
  TCodeRendererDLLAPI = record
    StructSize, Version: Cardinal;
    CreateInstance: TCodeRendererDLLCreate;
    DestroyInstance: TCodeRendererDLLDestroy;
    BeginFrame: TCodeRendererDLLBegin;
    EndFrame: TCodeRendererDLLEnd;
    FillRectangle: TCodeRendererDLLFill;
    StrokeRectangle: TCodeRendererDLLStroke;
    DrawLine: TCodeRendererDLLLine;
    DrawText: TCodeRendererDLLText;
    MeasureText: TCodeRendererDLLMeasure;
    PushClip: TCodeRendererDLLClip;
    PopClip: TCodeRendererDLLEnd;
  end;
  TCodeRendererDLLGetAPI = function(Version: Cardinal; API: Pointer; APISize: Cardinal): Integer; cdecl;

implementation

end.

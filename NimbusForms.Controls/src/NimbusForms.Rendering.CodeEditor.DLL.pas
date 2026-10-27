{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.CodeEditor.DLL;

interface

uses Winapi.Windows, System.SysUtils, System.Types, Vcl.Graphics,
  NimbusForms.Theming.Types, NimbusForms.Rendering.CodeEditor, NimbusForms.Rendering.CodeEditor.DLL.Types;

type
  TCodeRendererDLLFont = NimbusForms.Rendering.CodeEditor.DLL.Types.TCodeRendererDLLFont;
  TCodeRendererDLLCreate = NimbusForms.Rendering.CodeEditor.DLL.Types.TCodeRendererDLLCreate;
  TCodeRendererDLLDestroy = NimbusForms.Rendering.CodeEditor.DLL.Types.TCodeRendererDLLDestroy;
  TCodeRendererDLLBegin = NimbusForms.Rendering.CodeEditor.DLL.Types.TCodeRendererDLLBegin;
  TCodeRendererDLLEnd = NimbusForms.Rendering.CodeEditor.DLL.Types.TCodeRendererDLLEnd;
  TCodeRendererDLLFill = NimbusForms.Rendering.CodeEditor.DLL.Types.TCodeRendererDLLFill;
  TCodeRendererDLLStroke = NimbusForms.Rendering.CodeEditor.DLL.Types.TCodeRendererDLLStroke;
  TCodeRendererDLLLine = NimbusForms.Rendering.CodeEditor.DLL.Types.TCodeRendererDLLLine;
  TCodeRendererDLLText = NimbusForms.Rendering.CodeEditor.DLL.Types.TCodeRendererDLLText;
  TCodeRendererDLLMeasure = NimbusForms.Rendering.CodeEditor.DLL.Types.TCodeRendererDLLMeasure;
  TCodeRendererDLLClip = NimbusForms.Rendering.CodeEditor.DLL.Types.TCodeRendererDLLClip;
  TCodeRendererDLLAPI = NimbusForms.Rendering.CodeEditor.DLL.Types.TCodeRendererDLLAPI;
  TCodeRendererDLLGetAPI = NimbusForms.Rendering.CodeEditor.DLL.Types.TCodeRendererDLLGetAPI;
  TCodeEditorDLLBackend = class(TInterfacedObject, ICodeEditorRenderBackend)
  private
    FModule: HMODULE;
    FInstance: Pointer;
    FAPI: TCodeRendererDLLAPI;
    FPPI: Cardinal;
    FInFrame: Boolean;
    function FontInfo(const Font: TFont): TCodeRendererDLLFont;
    procedure Check(const Status: Integer; const Operation: string);
  public
    constructor Create(const LibraryPath: string);
    destructor Destroy; override;
    procedure BeginFrame(const Canvas: TCanvas; const Bounds: TRect; const PPI: Integer);
    procedure EndFrame;
    procedure FillRect(const Bounds: TRect; const Color: TThemeColor);
    procedure StrokeRect(const Bounds: TRect; const Color: TThemeColor; const Width: Single);
    procedure Line(const A, B: TPoint; const Color: TThemeColor; const Width: Single);
    procedure Text(const Value: string; const Font: TFont; const Bounds: TRect; const Color: TThemeColor);
    function Measure(const Value: string; const Font: TFont): TSize;
    procedure PushClip(const Bounds: TRect);
    procedure PopClip;
  end;

implementation

uses System.IOUtils, System.Math, System.UITypes;

constructor TCodeEditorDLLBackend.Create(const LibraryPath: string);
const
  CodeLoadLibrarySearchDLLLoadDir: DWORD = $00000100;
  CodeLoadLibrarySearchDefaultDirs: DWORD = $00001000;
var GetAPI: TCodeRendererDLLGetAPI; Path: string;
begin
  inherited Create; FPPI := 96; Path := TPath.GetFullPath(LibraryPath);
  FModule := LoadLibraryEx(PChar(Path), 0, CodeLoadLibrarySearchDLLLoadDir or CodeLoadLibrarySearchDefaultDirs);
  if FModule = 0 then RaiseLastOSError;
  GetAPI := TCodeRendererDLLGetAPI(GetProcAddress(FModule, 'NimbusCodeRendererGetAPI'));
  if not Assigned(GetAPI) then raise EInvalidOpException.Create('Renderer DLL must export NimbusCodeRendererGetAPI');
  FAPI.StructSize := SizeOf(FAPI); FAPI.Version := 1;
  Check(GetAPI(1, @FAPI, SizeOf(FAPI)), 'GetAPI');
  if (FAPI.Version <> 1) or (FAPI.StructSize <> SizeOf(FAPI)) or not Assigned(FAPI.CreateInstance) or
    not Assigned(FAPI.DestroyInstance) or not Assigned(FAPI.BeginFrame) or not Assigned(FAPI.EndFrame) or
    not Assigned(FAPI.FillRectangle) or not Assigned(FAPI.StrokeRectangle) or not Assigned(FAPI.DrawLine) or
    not Assigned(FAPI.DrawText) or not Assigned(FAPI.MeasureText) or not Assigned(FAPI.PushClip) or not Assigned(FAPI.PopClip) then
    raise EInvalidOpException.Create('Incomplete renderer DLL API version 1');
  FInstance := FAPI.CreateInstance();
  if FInstance = nil then raise EInvalidOpException.Create('Renderer DLL could not create an instance');
end;
destructor TCodeEditorDLLBackend.Destroy;
begin
  if (FInstance <> nil) and Assigned(FAPI.DestroyInstance) then
  begin if FInFrame and Assigned(FAPI.EndFrame) then FAPI.EndFrame(FInstance); FAPI.DestroyInstance(FInstance); end;
  if FModule <> 0 then FreeLibrary(FModule);
  inherited;
end;
procedure TCodeEditorDLLBackend.Check(const Status: Integer; const Operation: string);
begin if Status <> 0 then raise EInvalidOpException.CreateFmt('Renderer DLL %s failed (%d)', [Operation, Status]); end;
function TCodeEditorDLLBackend.FontInfo(const Font: TFont): TCodeRendererDLLFont;
begin
  Result := Default(TCodeRendererDLLFont); Result.StructSize := SizeOf(Result);
  Result.NameLength := Length(Font.Name);
  Result.PixelHeight := Abs(Font.Height); Result.PPI := FPPI;
  if fsBold in Font.Style then Result.Style := Result.Style or 1;
  if fsItalic in Font.Style then Result.Style := Result.Style or 2;
  if fsUnderline in Font.Style then Result.Style := Result.Style or 4;
  if fsStrikeOut in Font.Style then Result.Style := Result.Style or 8;
end;
procedure TCodeEditorDLLBackend.BeginFrame(const Canvas: TCanvas; const Bounds: TRect; const PPI: Integer);
begin
  if FInFrame then raise EInvalidOpException.Create('Renderer frame already active');
  FPPI := Max(1, PPI); Check(FAPI.BeginFrame(FInstance, Canvas.Handle, @Bounds, FPPI), 'BeginFrame'); FInFrame := True;
end;
procedure TCodeEditorDLLBackend.EndFrame;
begin if not FInFrame then Exit; FInFrame := False; Check(FAPI.EndFrame(FInstance), 'EndFrame'); end;
procedure TCodeEditorDLLBackend.FillRect(const Bounds: TRect; const Color: TThemeColor);
begin Check(FAPI.FillRectangle(FInstance, @Bounds, Color), 'FillRectangle'); end;
procedure TCodeEditorDLLBackend.StrokeRect(const Bounds: TRect; const Color: TThemeColor; const Width: Single);
begin Check(FAPI.StrokeRectangle(FInstance, @Bounds, Color, Width), 'StrokeRectangle'); end;
procedure TCodeEditorDLLBackend.Line(const A, B: TPoint; const Color: TThemeColor; const Width: Single);
begin Check(FAPI.DrawLine(FInstance, A.X, A.Y, B.X, B.Y, Color, Width), 'DrawLine'); end;
procedure TCodeEditorDLLBackend.Text(const Value: string; const Font: TFont; const Bounds: TRect; const Color: TThemeColor);
var Info: TCodeRendererDLLFont; Name: string;
begin Name := Font.Name; Info := FontInfo(Font); Info.Name := PWideChar(Name); Check(FAPI.DrawText(FInstance, PWideChar(Value), Length(Value), @Info, @Bounds, Color), 'DrawText'); end;
function TCodeEditorDLLBackend.Measure(const Value: string; const Font: TFont): TSize;
var Info: TCodeRendererDLLFont; Name: string;
begin
  Name := Font.Name; Info := FontInfo(Font); Info.Name := PWideChar(Name);
  Result := TSize.Create(0, 0); Check(FAPI.MeasureText(FInstance, PWideChar(Value), Length(Value), @Info, @Result.cx, @Result.cy), 'MeasureText');
end;
procedure TCodeEditorDLLBackend.PushClip(const Bounds: TRect);
begin Check(FAPI.PushClip(FInstance, @Bounds), 'PushClip'); end;
procedure TCodeEditorDLLBackend.PopClip;
begin Check(FAPI.PopClip(FInstance), 'PopClip'); end;

end.

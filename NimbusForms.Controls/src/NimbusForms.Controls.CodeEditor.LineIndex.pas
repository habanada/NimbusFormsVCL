{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.CodeEditor.LineIndex;

interface

uses System.SysUtils, System.Generics.Collections, NimbusForms.Controls.CodeEditor.Types,
  NimbusForms.Controls.CodeEditor.PieceTable;

type
  TCodeLineIndex = class
  private
    FTable: TCodePieceTable;
    function GetLineCount: Integer;
  public
    constructor Create(Table: TCodePieceTable);
    function GetOffset(const Position: TCodeDocumentPosition): Integer;
    function GetPosition(const Offset: Integer): TCodeDocumentPosition;
    property LineCount: Integer read GetLineCount;
  end;
  TCodeDocumentLineTextCache = class
  private
    FItems: TDictionary<Integer, string>;
    FMaximumLines: Integer;
    procedure Trim;
    procedure SetMaximumLines(const Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    function TryGet(const LineIndex: Integer; out Text: string): Boolean;
    procedure Put(const LineIndex: Integer; const Text: string);
    procedure InvalidateFromLine(const LineIndex: Integer);
    procedure Clear;
    property MaximumLines: Integer read FMaximumLines write SetMaximumLines;
  end;

implementation

uses System.Math;

constructor TCodeLineIndex.Create(Table: TCodePieceTable);
begin inherited Create; if Table = nil then raise EArgumentNilException.Create('Table'); FTable := Table; end;
function TCodeLineIndex.GetLineCount: Integer;
begin Result := FTable.LineCount; end;
function TCodeLineIndex.GetOffset(const Position: TCodeDocumentPosition): Integer;
begin Result := FTable.GetOffsetFromPosition(Position); end;
function TCodeLineIndex.GetPosition(const Offset: Integer): TCodeDocumentPosition;
begin Result := FTable.GetPositionFromOffset(Offset); end;

constructor TCodeDocumentLineTextCache.Create;
begin inherited Create; FItems := TDictionary<Integer, string>.Create; FMaximumLines := 2048; end;
destructor TCodeDocumentLineTextCache.Destroy;
begin FItems.Free; inherited; end;
procedure TCodeDocumentLineTextCache.Trim;
begin if FItems.Count > FMaximumLines then FItems.Clear; end;
procedure TCodeDocumentLineTextCache.SetMaximumLines(const Value: Integer);
begin FMaximumLines := Max(128, Value); Trim; end;
function TCodeDocumentLineTextCache.TryGet(const LineIndex: Integer; out Text: string): Boolean;
begin Text := ''; Result := (LineIndex >= 0) and FItems.TryGetValue(LineIndex, Text); end;
procedure TCodeDocumentLineTextCache.Put(const LineIndex: Integer; const Text: string);
begin if LineIndex < 0 then Exit; FItems.AddOrSetValue(LineIndex, Text); Trim; end;
procedure TCodeDocumentLineTextCache.InvalidateFromLine(const LineIndex: Integer);
var Key: Integer; Keys: TArray<Integer>;
begin
  if LineIndex <= 0 then begin Clear; Exit; end;
  Keys := FItems.Keys.ToArray; for Key in Keys do if Key >= LineIndex then FItems.Remove(Key);
end;
procedure TCodeDocumentLineTextCache.Clear;
begin FItems.Clear; end;

end.

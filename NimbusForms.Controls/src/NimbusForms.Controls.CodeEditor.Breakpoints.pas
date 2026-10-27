{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.CodeEditor.Breakpoints;

interface

uses System.Classes, System.SysUtils, System.Generics.Collections,
  NimbusForms.Controls.CodeEditor.Types, NimbusForms.Controls.CodeEditor.Document;

type
  TCodeBreakpoint = record
    LineIndex: Integer;
    Enabled: Boolean;
    Condition: string;
    HitCount: Integer;
    LogMessage: string;
  end;
  TCodeBreakpointChange = (bpcAdded, bpcChanged, bpcRemoved, bpcReset);
  TCodeBreakpointEvent = procedure(Sender: TObject; const Breakpoint: TCodeBreakpoint; const Change: TCodeBreakpointChange) of object;
  TCodeBreakpointManager = class
  private
    FItems: TList<TCodeBreakpoint>;
    FOnChange: TCodeBreakpointEvent;
    function Find(const LineIndex: Integer): Integer;
    procedure Notify(const Breakpoint: TCodeBreakpoint; const Change: TCodeBreakpointChange);
    function GetItems: TArray<TCodeBreakpoint>;
  public
    constructor Create(const OnChange: TCodeBreakpointEvent);
    destructor Destroy; override;
    function TryGet(const LineIndex: Integer; out Breakpoint: TCodeBreakpoint): Boolean;
    procedure Put(const Breakpoint: TCodeBreakpoint);
    procedure Toggle(const LineIndex: Integer);
    procedure Remove(const LineIndex: Integer);
    procedure SetEnabled(const LineIndex: Integer; const Enabled: Boolean);
    procedure Clear;
    procedure ApplyChange(const Source: ICodeVirtualTextSource; const Change: TCodeDocumentChange);
    property Items: TArray<TCodeBreakpoint> read GetItems;
  end;

implementation

constructor TCodeBreakpointManager.Create(const OnChange: TCodeBreakpointEvent);
begin inherited Create; FItems := TList<TCodeBreakpoint>.Create; FOnChange := OnChange; end;
destructor TCodeBreakpointManager.Destroy;
begin FItems.Free; inherited; end;
function TCodeBreakpointManager.Find(const LineIndex: Integer): Integer;
var I: Integer;
begin Result := -1; for I := 0 to FItems.Count - 1 do if FItems[I].LineIndex = LineIndex then Exit(I); end;
function TCodeBreakpointManager.GetItems: TArray<TCodeBreakpoint>;
begin Result := FItems.ToArray; end;
procedure TCodeBreakpointManager.Notify(const Breakpoint: TCodeBreakpoint; const Change: TCodeBreakpointChange);
begin if Assigned(FOnChange) then FOnChange(Self, Breakpoint, Change); end;
function TCodeBreakpointManager.TryGet(const LineIndex: Integer; out Breakpoint: TCodeBreakpoint): Boolean;
var I: Integer;
begin I := Find(LineIndex); Result := I >= 0; Breakpoint := Default(TCodeBreakpoint); if Result then Breakpoint := FItems[I]; end;
procedure TCodeBreakpointManager.Put(const Breakpoint: TCodeBreakpoint);
var I: Integer;
begin
  if Breakpoint.LineIndex < 0 then raise EArgumentOutOfRangeException.Create('Breakpoint line index');
  if Breakpoint.HitCount < 0 then raise EArgumentOutOfRangeException.Create('Breakpoint hit count');
  I := Find(Breakpoint.LineIndex);
  if I < 0 then begin FItems.Add(Breakpoint); Notify(Breakpoint, bpcAdded); end
  else begin FItems[I] := Breakpoint; Notify(Breakpoint, bpcChanged); end;
end;
procedure TCodeBreakpointManager.Toggle(const LineIndex: Integer);
var Breakpoint: TCodeBreakpoint;
begin
  if TryGet(LineIndex, Breakpoint) then Remove(LineIndex)
  else begin Breakpoint := Default(TCodeBreakpoint); Breakpoint.LineIndex := LineIndex; Breakpoint.Enabled := True; Put(Breakpoint); end;
end;
procedure TCodeBreakpointManager.Remove(const LineIndex: Integer);
var I: Integer; Breakpoint: TCodeBreakpoint;
begin I := Find(LineIndex); if I < 0 then Exit; Breakpoint := FItems[I]; FItems.Delete(I); Notify(Breakpoint, bpcRemoved); end;
procedure TCodeBreakpointManager.SetEnabled(const LineIndex: Integer; const Enabled: Boolean);
var Breakpoint: TCodeBreakpoint;
begin if not TryGet(LineIndex, Breakpoint) or (Breakpoint.Enabled = Enabled) then Exit; Breakpoint.Enabled := Enabled; Put(Breakpoint); end;
procedure TCodeBreakpointManager.Clear;
var Breakpoint: TCodeBreakpoint;
begin
  if FItems.Count = 0 then Exit; FItems.Clear; Breakpoint := Default(TCodeBreakpoint); Breakpoint.LineIndex := -1;
  Notify(Breakpoint, bpcReset);
end;
procedure TCodeBreakpointManager.ApplyChange(const Source: ICodeVirtualTextSource; const Change: TCodeDocumentChange);
var I, Delta, LastOld: Integer; C: Char; Breakpoint: TCodeBreakpoint; Changed: Boolean;
begin
  if Change.Reset then begin Clear; Exit; end;
  Delta := 0; LastOld := Change.Range.Start.LineIndex; Changed := False;
  for C in Change.NewText do if C = #10 then Inc(Delta);
  for C in Change.OldText do if C = #10 then begin Dec(Delta); Inc(LastOld); end;
  for I := FItems.Count - 1 downto 0 do
  begin
    Breakpoint := FItems[I];
    if (Breakpoint.LineIndex > Change.Range.Start.LineIndex) and (Breakpoint.LineIndex <= LastOld) then
    begin FItems.Delete(I); Changed := True; Continue; end;
    if Breakpoint.LineIndex > LastOld then Inc(Breakpoint.LineIndex, Delta);
    if Breakpoint.LineIndex >= Source.LineCount then Breakpoint.LineIndex := Source.LineCount - 1;
    if Breakpoint.LineIndex <> FItems[I].LineIndex then begin FItems[I] := Breakpoint; Changed := True; end;
  end;
  if Changed then begin Breakpoint := Default(TCodeBreakpoint); Breakpoint.LineIndex := -1; Notify(Breakpoint, bpcReset); end;
end;

end.

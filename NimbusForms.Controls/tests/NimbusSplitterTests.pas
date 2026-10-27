{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

program NimbusSplitterTests;

{$APPTYPE CONSOLE}

uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Types,
  Vcl.Forms, Vcl.Controls, Vcl.ExtCtrls, NimbusForms.Controls.Splitter,
  NimbusSplitContainerStreamingChecks;

type
  TSplitterProbe = class(TThemedSplitter)
  private
    FOrigin: TPoint;
  public
    procedure Start;
    procedure MoveBy(const X, Y: Integer);
    procedure Stop;
    procedure Press(const Code: Word);
  end;
  TSplitterEvents = class
  public
    Moves: Integer;
    Veto: Boolean;
    procedure CanResize(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
    procedure Moved(Sender: TObject);
  end;

procedure Check(const Value: Boolean; const MessageText: string);
begin if not Value then raise Exception.Create(MessageText); end;
procedure TSplitterProbe.Start;
begin FOrigin := ClientToScreen(Point(Width div 2, Height div 2)); MouseDown(mbLeft, [], Width div 2, Height div 2); end;
procedure TSplitterProbe.MoveBy(const X, Y: Integer);
var Position: TPoint;
begin Position := ScreenToClient(Point(FOrigin.X + X, FOrigin.Y + Y)); MouseMove([ssLeft], Position.X, Position.Y); end;
procedure TSplitterProbe.Stop;
begin MouseUp(mbLeft, [], 0, 0); end;
procedure TSplitterProbe.Press(const Code: Word);
var Key: Word;
begin Key := Code; KeyDown(Key, []); end;
procedure TSplitterEvents.CanResize(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
begin Accept := not Veto; end;
procedure TSplitterEvents.Moved(Sender: TObject);
begin Inc(Moves); end;

procedure ConstructorChecks;
var Splitter: TThemedSplitter;
begin
  Splitter := TThemedSplitter.Create(nil);
  try
    Check(not Splitter.HandleAllocated, 'splitter construction is handleless');
    Check((Splitter.Align = alLeft) and (Splitter.Thickness = 7) and Splitter.ShowGrip, 'splitter defaults');
    Splitter.Align := alTop;
    Check((Splitter.Height = 7) and not Splitter.HandleAllocated, 'horizontal alignment keeps logical thickness without HWND');
    Splitter.Thickness := 9;
    Check((Splitter.Height = 9) and not Splitter.HandleAllocated, 'thickness updates without HWND');
  finally Splitter.Free; end;
end;

procedure InteractionChecks(const Side: TAlign);
var Host: TForm; Target, Content: TPanel; Splitter: TSplitterProbe; Events: TSplitterEvents;
  Vertical: Boolean; StartSize, Direction, Key: Integer;
  function Size: Integer;
  begin if Vertical then Result := Target.Width else Result := Target.Height; end;
  procedure Move(const Delta: Integer);
  begin if Vertical then Splitter.MoveBy(Delta * Direction, 0) else Splitter.MoveBy(0, Delta * Direction); end;
begin
  Host := TForm.CreateNew(nil); Events := TSplitterEvents.Create;
  try
    Host.ClientWidth := 640; Host.ClientHeight := 480; Vertical := Side in [alLeft, alRight];
    Direction := 1; if Side in [alRight, alBottom] then Direction := -1;
    Host.DisableAlign;
    try
      Target := TPanel.Create(Host); Target.Parent := Host; Target.BevelOuter := bvNone;
      Target.SetBounds(0, 0, 200, 200); Target.Align := Side;
      Splitter := TSplitterProbe.Create(Host); Splitter.Parent := Host; Splitter.Align := Side;
      case Side of
        alLeft: begin Target.Left := 0; Splitter.Left := 200; end;
        alRight: begin Target.Left := 440; Splitter.Left := 433; end;
        alTop: begin Target.Top := 0; Splitter.Top := 200; end;
        alBottom: begin Target.Top := 280; Splitter.Top := 273; end;
      end;
      Content := TPanel.Create(Host); Content.Parent := Host; Content.Align := alClient; Content.BevelOuter := bvNone;
      Content.Constraints.MinWidth := 120; Content.Constraints.MinHeight := 100;
      Splitter.OnCanResize := Events.CanResize; Splitter.OnMoved := Events.Moved;
    finally Host.EnableAlign; end;
    Check(Splitter.Handle <> 0, 'interaction HWND'); StartSize := Size;
    Splitter.Start; Check(Splitter.Resizing, 'automatic adjacent control detection');
    Move(40); Check(Size = StartSize + 40, 'live resize direction');
    Move(60); Check(Size = StartSize + 60, 'drag uses stable screen origin');
    Splitter.Stop; Check((Events.Moves = 1) and not Splitter.Resizing, 'one moved event after commit');
    StartSize := Size; Splitter.Start; Move(-20); Splitter.Press(VK_ESCAPE);
    Check((Size = StartSize) and (Events.Moves = 1) and not Splitter.Resizing, 'Escape restores original size');
    Events.Veto := True; Splitter.Start; Move(40); Splitter.Stop;
    Check((Size = StartSize) and (Events.Moves = 1), 'resize event veto'); Events.Veto := False;
    Target.Constraints.MinWidth := 80; Target.Constraints.MinHeight := 80;
    Target.Constraints.MaxWidth := 300; Target.Constraints.MaxHeight := 300;
    Splitter.Start; Move(-10000); Splitter.Stop; Check(Size = 80, 'target minimum constraint');
    Splitter.Start; Move(10000); Splitter.Stop; Check(Size <= 300, 'target maximum constraint');
    if Vertical then Check(Content.Width >= 120, 'remaining width constraint') else Check(Content.Height >= 100, 'remaining height constraint');
    if Vertical then
      if Side = alLeft then Key := VK_LEFT else Key := VK_RIGHT
    else
      if Side = alTop then Key := VK_UP else Key := VK_DOWN;
    StartSize := Size; Splitter.Press(Key);
    Check(Size = StartSize - MulDiv(Splitter.KeyboardStep, Splitter.CurrentPPI, 96), 'keyboard resizes the adjacent control');
    StartSize := Size;
    Splitter.ResizeControl := Target; Splitter.Start; Move(-20);
    Splitter.Perform(WM_CAPTURECHANGED, 0, 0);
    Check((Size = StartSize) and not Splitter.Resizing, 'capture loss restores size and ends resize');
    StartSize := Size; Splitter.Start; Move(-10); Splitter.Parent := nil;
    Check((Size = StartSize) and not Splitter.Resizing, 'detaching splitter cancels resize'); Splitter.Parent := Host;
    Splitter.Enabled := False; Splitter.Start; Check(not Splitter.Resizing, 'disabled splitter cannot resize'); Splitter.Enabled := True;
    Splitter.Start; Target.Free;
    Check((Splitter.ResizeControl = nil) and not Splitter.Resizing, 'target destruction clears references and capture');
  finally Host.Free; Events.Free; end;
end;

begin
  try
    Application.Initialize; ConstructorChecks; RunSplitContainerStreamingChecks;
    InteractionChecks(alLeft); InteractionChecks(alRight); InteractionChecks(alTop); InteractionChecks(alBottom);
    Writeln('Standalone splitter checks passed');
  except on E: Exception do begin Writeln(E.ClassName + ': ' + E.Message); ExitCode := 1; end; end;
end.

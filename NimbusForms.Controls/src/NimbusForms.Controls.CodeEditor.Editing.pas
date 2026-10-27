{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.CodeEditor.Editing;

interface

uses System.Classes, NimbusForms.Controls.CodeEditor.Types;

type
  TCodeEditorCaret = class(TPersistent)
  private
    FPosition: TCodeDocumentPosition;
    FPreferredColumn: Integer;
    FOnChange: TNotifyEvent;
    procedure SetPosition(const Value: TCodeDocumentPosition);
  public
    constructor Create(const OnChange: TNotifyEvent);
    property Position: TCodeDocumentPosition read FPosition write SetPosition;
    property PreferredColumn: Integer read FPreferredColumn write FPreferredColumn;
    property OnPositionChanged: TNotifyEvent read FOnChange write FOnChange;
  end;
  TCodeEditorSelection = class(TPersistent)
  private
    FRange: TCodeDocumentRange;
    FOnChange: TNotifyEvent;
    procedure SetRange(const Value: TCodeDocumentRange);
    function GetEmpty: Boolean;
  public
    constructor Create(const OnChange: TNotifyEvent);
    procedure Clear(const Position: TCodeDocumentPosition);
    procedure SetSelection(const Start, Finish: TCodeDocumentPosition);
    property Range: TCodeDocumentRange read FRange write SetRange;
    property IsEmpty: Boolean read GetEmpty;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

implementation

constructor TCodeEditorCaret.Create(const OnChange: TNotifyEvent);
begin inherited Create; FOnChange := OnChange; FPreferredColumn := -1; end;
procedure TCodeEditorCaret.SetPosition(const Value: TCodeDocumentPosition);
begin if FPosition.Compare(Value) = 0 then Exit; FPosition := Value; if Assigned(FOnChange) then FOnChange(Self); end;
constructor TCodeEditorSelection.Create(const OnChange: TNotifyEvent);
begin inherited Create; FOnChange := OnChange; end;
function TCodeEditorSelection.GetEmpty: Boolean;
begin Result := FRange.IsEmpty; end;
procedure TCodeEditorSelection.SetRange(const Value: TCodeDocumentRange);
var Next: TCodeDocumentRange;
begin
  Next := TCodeDocumentRange.Create(Value.Start, Value.Finish);
  if (FRange.Start.Compare(Next.Start) = 0) and (FRange.Finish.Compare(Next.Finish) = 0) then Exit;
  FRange := Next; if Assigned(FOnChange) then FOnChange(Self);
end;
procedure TCodeEditorSelection.Clear(const Position: TCodeDocumentPosition);
begin SetRange(TCodeDocumentRange.Create(Position, Position)); end;
procedure TCodeEditorSelection.SetSelection(const Start, Finish: TCodeDocumentPosition);
begin SetRange(TCodeDocumentRange.Create(Start, Finish)); end;

end.

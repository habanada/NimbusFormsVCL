{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Controls.CodeEditor.Unicode;

interface

function CodeNextTextElement(const Text: string; const Column: Integer): Integer;
function CodeTextElementEnd(const Text: string; const Column: Integer): Integer;
function CodePreviousTextElement(const Text: string; const Column: Integer): Integer;
function CodeClampTextElement(const Text: string; const Column: Integer; const Forward: Boolean = False): Integer;

implementation

uses System.SysUtils, System.Math, System.Character;

function Scalar(const Text: string; const Column: Integer; out Units: Integer): Cardinal;
begin
  Units := 1; Result := Ord(Text[Column + 1]);
  if (Result >= $D800) and (Result <= $DBFF) and (Column + 1 < Length(Text)) and
    (Ord(Text[Column + 2]) >= $DC00) and (Ord(Text[Column + 2]) <= $DFFF) then
  begin Units := 2; Result := $10000 + ((Result - $D800) shl 10) + Ord(Text[Column + 2]) - $DC00; end;
end;
function Extend(const C: Cardinal): Boolean;
begin
  Result := (C = $200C) or ((C >= $FE00) and (C <= $FE0F)) or ((C >= $E0100) and (C <= $E01EF)) or
    ((C >= $1F3FB) and (C <= $1F3FF)) or ((C >= $E0020) and (C <= $E007F));
  if not Result and (C >= 128) then Result := Char.GetUnicodeCategory(UCS4Char(C)) in
    [TUnicodeCategory.ucNonSpacingMark, TUnicodeCategory.ucEnclosingMark, TUnicodeCategory.ucCombiningMark];
end;
function Pictograph(const C: Cardinal): Boolean;
begin
  Result := ((C >= $1F000) and (C <= $1FAFF)) or ((C >= $2600) and (C <= $27BF)) or
    (C = $00A9) or (C = $00AE) or (C = $203C) or (C = $2049) or (C = $2122) or (C = $2139);
end;
function Regional(const C: Cardinal): Boolean;
begin Result := (C >= $1F1E6) and (C <= $1F1FF); end;
function Prepend(const C: Cardinal): Boolean;
begin Result := ((C >= $0600) and (C <= $0605)) or (C = $06DD) or (C = $070F) or (C = $08E2) or (C = $110BD) or (C = $110CD); end;
function Hangul(const C: Cardinal): Integer;
begin
  Result := 0;
  if ((C >= $1100) and (C <= $115F)) or ((C >= $A960) and (C <= $A97C)) then Result := 1
  else if ((C >= $1160) and (C <= $11A7)) or ((C >= $D7B0) and (C <= $D7C6)) then Result := 2
  else if ((C >= $11A8) and (C <= $11FF)) or ((C >= $D7CB) and (C <= $D7FB)) then Result := 3
  else if (C >= $AC00) and (C <= $D7A3) then begin if (C - $AC00) mod 28 = 0 then Result := 4 else Result := 5; end;
end;
function Control(const C: Cardinal): Boolean;
begin
  Result := (C < 32) or ((C >= $7F) and (C <= $9F)) or (C = $2028) or (C = $2029);
end;
function NextBoundary(const Text: string; const Column: Integer): Integer;
var Previous, Current, Base: Cardinal; Units, Flags, H1, H2: Integer; Join, AfterJoiner: Boolean;
begin
  Result := Column; if Result >= Length(Text) then Exit;
  Previous := Scalar(Text, Result, Units); Inc(Result, Units); Base := Previous;
  Flags := Ord(Regional(Previous)); AfterJoiner := False;
  while Result < Length(Text) do
  begin
    Current := Scalar(Text, Result, Units); H1 := Hangul(Previous); H2 := Hangul(Current);
    Join := (Previous = 13) and (Current = 10);
    if not Control(Previous) and not Control(Current) then
      Join := Extend(Current) or (Current = $200D) or Prepend(Previous) or
        (AfterJoiner and Pictograph(Current)) or (Regional(Previous) and Regional(Current) and Odd(Flags)) or
        ((H1 = 1) and (H2 in [1, 2, 4, 5])) or ((H1 in [2, 4]) and (H2 in [2, 3])) or ((H1 in [3, 5]) and (H2 = 3));
    if not Join then Break;
    if Current = $200D then AfterJoiner := Pictograph(Base)
    else if not Extend(Current) then begin AfterJoiner := False; Base := Current; end;
    if Regional(Current) then Inc(Flags);
    Previous := Current; Inc(Result, Units);
  end;
end;
function Anchor(const Text: string; const Column: Integer): Integer;
begin
  Result := EnsureRange(Column, 0, Length(Text));
  while (Result > 0) and (Ord(Text[Result]) >= 128) do Dec(Result);
  if Result > 0 then Dec(Result);
end;
function CodeClampTextElement(const Text: string; const Column: Integer; const Forward: Boolean): Integer;
var Target, Next: Integer;
begin
  Target := EnsureRange(Column, 0, Length(Text)); Result := Anchor(Text, Target);
  while Result < Target do
  begin
    Next := NextBoundary(Text, Result);
    if Next > Target then begin if Forward then Result := Next; Exit; end;
    Result := Next;
  end;
end;
function CodeNextTextElement(const Text: string; const Column: Integer): Integer;
begin Result := NextBoundary(Text, CodeClampTextElement(Text, Column)); end;
function CodeTextElementEnd(const Text: string; const Column: Integer): Integer;
begin Result := NextBoundary(Text, EnsureRange(Column, 0, Length(Text))); end;
function CodePreviousTextElement(const Text: string; const Column: Integer): Integer;
var Target, Next: Integer;
begin
  Target := EnsureRange(Column, 0, Length(Text)); Result := Anchor(Text, Target);
  while Result < Target do
  begin Next := NextBoundary(Text, Result); if Next >= Target then Exit; Result := Next; end;
end;

end.

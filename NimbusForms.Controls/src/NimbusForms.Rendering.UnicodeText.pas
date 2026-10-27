{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.UnicodeText;

interface

uses System.Types, Vcl.Graphics, NimbusForms.Rendering.Canvas, NimbusForms.Theming.Types;

function NimbusEmojiAt(const Text: string; const Index: Integer; out Units: Integer): Boolean;
procedure NimbusDrawMonospacedText(const Canvas: INimbusRenderCanvas; const Text: string;
  const Font: TFont; const Bounds: TRect; const Color: TThemeColor; const CharWidth: Single = 0);

implementation

uses System.SysUtils, System.Math, NimbusForms.Rendering.Types;

function NimbusEmojiAt(const Text: string; const Index: Integer; out Units: Integer): Boolean;
var C: Cardinal;
begin
  Units := 1; Result := False; if (Index < 1) or (Index > Length(Text)) then Exit;
  C := Ord(Text[Index]);
  if (C >= $D800) and (C <= $DBFF) and (Index < Length(Text)) and
    (Ord(Text[Index + 1]) >= $DC00) and (Ord(Text[Index + 1]) <= $DFFF) then
  begin Units := 2; C := $10000 + ((C - $D800) shl 10) + Ord(Text[Index + 1]) - $DC00; end;
  Result := ((C >= $1F000) and (C <= $1FAFF)) or ((C >= $2600) and (C <= $27BF));
end;

procedure NimbusDrawMonospacedText(const Canvas: INimbusRenderCanvas; const Text: string;
  const Font: TFont; const Bounds: TRect; const Color: TThemeColor; const CharWidth: Single);
var I, Units, First: Integer; Width: Single; Emoji, NextEmoji, HasEmoji: Boolean;
  EmojiFont: TFont; RunFont: TFont; Box: TRect; Size: TSize;
begin
  if Text = '' then Exit;
  I := 1; HasEmoji := False;
  while I <= Length(Text) do
  begin
    if NimbusEmojiAt(Text, I, Units) then begin HasEmoji := True; Break; end;
    Inc(I, Units);
  end;
  if not HasEmoji then
  begin Canvas.DrawText(Text, Font, Color, Bounds, [ntfSingleLine, ntfVCenter, ntfTypographic, ntfNoPrefix]); Exit; end;
  Width := CharWidth;
  if Width <= 0 then
  begin
    Size := Canvas.MeasureText(StringOfChar('0', 64), Font, 0, [ntfSingleLine, ntfTypographic, ntfNoPrefix]);
    Width := Max(1.0, Size.cx / 64.0);
  end;
  EmojiFont := TFont.Create;
  try
    EmojiFont.Assign(Font); EmojiFont.Name := 'Segoe UI Emoji'; EmojiFont.Style := [];
    First := 1; I := 1; Emoji := NimbusEmojiAt(Text, I, Units);
    while I <= Length(Text) do
    begin
      NextEmoji := NimbusEmojiAt(Text, I, Units);
      if Emoji and ((Ord(Text[I]) = $200D) or (Ord(Text[I]) = $FE0E) or (Ord(Text[I]) = $FE0F)) then NextEmoji := True;
      if (I > First) and (NextEmoji <> Emoji) then
      begin
        Box := Rect(Bounds.Left + Round((First - 1) * Width), Bounds.Top,
          Bounds.Left + Round((I - 1) * Width) + 2, Bounds.Bottom);
        RunFont := Font; if Emoji then RunFont := EmojiFont;
        Canvas.DrawText(Copy(Text, First, I - First), RunFont, Color, Box, [ntfSingleLine, ntfVCenter, ntfTypographic, ntfNoPrefix]);
        First := I;
      end;
      Emoji := NextEmoji; Inc(I, Units);
    end;
    Box := Rect(Bounds.Left + Round((First - 1) * Width), Bounds.Top, Bounds.Right, Bounds.Bottom);
    RunFont := Font; if Emoji then RunFont := EmojiFont;
    Canvas.DrawText(Copy(Text, First, MaxInt), RunFont, Color, Box, [ntfSingleLine, ntfVCenter, ntfTypographic, ntfNoPrefix]);
  finally EmojiFont.Free; end;
end;

end.

{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

unit NimbusForms.Rendering.Markdown;

interface

uses System.SysUtils, NimbusForms.Rendering.Markup;

type
  TNimbusMarkdownParser = class
  public
    class function Parse(const AText: string): TArray<TThemedMarkupSpan>; static;
  end;

implementation

uses System.Generics.Collections;

class function TNimbusMarkdownParser.Parse(const AText: string): TArray<TThemedMarkupSpan>;
var
  LSpans: TList<TThemedMarkupSpan>;
  LLines: TArray<string>;
  LLine: string;
  I, J: Integer;
  Span: TThemedMarkupSpan;

  procedure Add(const S: string; const Style: TThemedMarkupStyle; const Level: Byte;
    const InlineKind: TThemedMarkupInlineKind; const URL: string);
  var Span: TThemedMarkupSpan;
  begin
    if S = '' then Exit;
    Span := Default(TThemedMarkupSpan);
    Span.Text := S;
    Span.Style := Style;
    Span.HeadingLevel := Level;
    Span.InlineKind := InlineKind;
    Span.LinkTarget := URL;
    LSpans.Add(Span);
  end;

  procedure ParseInline(const S: string; const Style: TThemedMarkupStyle; const Level: Byte;
    const URL: string; const Depth: Integer);
  var
    P, Q, R, N: Integer;
    Buffer, Marker, Target: string;
    NextStyle: TThemedMarkupStyle;

    procedure Flush;
    begin
      Add(Buffer, Style, Level, tmikNone, URL);
      Buffer := '';
    end;

    function Closing(const Delimiter: string; const Start: Integer): Integer;
    var K: Integer;
    begin
      Result := 0;
      K := Start;
      while K <= Length(S) - Length(Delimiter) + 1 do
      begin
        if S[K] = '\' then Inc(K, 2)
        else if Copy(S, K, Length(Delimiter)) = Delimiter then Exit(K)
        else Inc(K);
      end;
    end;

  begin
    if Depth > 16 then begin Add(S, Style, Level, tmikNone, URL); Exit; end;
    P := 1;
    Buffer := '';
    while P <= Length(S) do
    begin
      if (S[P] = '\') and (P < Length(S)) then
      begin
        Buffer := Buffer + S[P + 1];
        Inc(P, 2);
        Continue;
      end;
      if S[P] = '`' then
      begin
        Q := Closing('`', P + 1);
        if Q > P + 1 then
        begin
          Flush;
          Add(Copy(S, P + 1, Q - P - 1), Style, Level, tmikCode, URL);
          P := Q + 1;
          Continue;
        end;
      end;
      if (S[P] = '[') and (URL = '') then
      begin
        Q := Closing('](', P + 1);
        if Q > P + 1 then
        begin
          R := Closing(')', Q + 2);
          if R > Q + 2 then
          begin
            Target := Trim(Copy(S, Q + 2, R - Q - 2));
            Flush;
            ParseInline(Copy(S, P + 1, Q - P - 1), Style + [tmseUnderline], Level, Target, Depth + 1);
            P := R + 1;
            Continue;
          end;
        end;
      end;
      if CharInSet(S[P], ['*', '_']) then
      begin
        N := 1;
        if (P < Length(S)) and (S[P + 1] = S[P]) then N := 2;
        Marker := Copy(S, P, N);
        Q := Closing(Marker, P + N);
        if (Q > P + N) and ((S[P] <> '_') or (P = 1) or not CharInSet(S[P - 1], ['a'..'z', 'A'..'Z', '0'..'9'])) then
        begin
          Flush;
          NextStyle := Style;
          if N = 2 then Include(NextStyle, tmseBold) else Include(NextStyle, tmseItalic);
          ParseInline(Copy(S, P + N, Q - P - N), NextStyle, Level, URL, Depth + 1);
          P := Q + N;
          Continue;
        end;
      end;
      Buffer := Buffer + S[P];
      Inc(P);
    end;
    Flush;
  end;

begin
  LSpans := TList<TThemedMarkupSpan>.Create;
  try
    LLines := AText.Replace(#13#10, #10).Replace(#13, #10).Split([#10]);
    for I := 0 to High(LLines) do
    begin
      LLine := LLines[I];
      J := 0;
      while (J < Length(LLine)) and (J < 6) and (LLine[J + 1] = '#') do Inc(J);
      if (J > 0) and (J < Length(LLine)) and (LLine[J + 1] = ' ') then
        ParseInline(Copy(LLine, J + 2, MaxInt), [], Byte(1 + Ord(J > 1)), '', 0)
      else
      begin
        if (Copy(LLine, 1, 2) = '- ') or (Copy(LLine, 1, 2) = '* ') then
          LLine := Char($2022) + ' ' + Copy(LLine, 3, MaxInt);
        ParseInline(LLine, [], 0, '', 0);
      end;
      if I < High(LLines) then
      begin
        Span := Default(TThemedMarkupSpan);
        Span.Kind := tmskLineBreak;
        LSpans.Add(Span);
      end;
    end;
    Result := LSpans.ToArray;
  finally LSpans.Free; end;
end;

end.

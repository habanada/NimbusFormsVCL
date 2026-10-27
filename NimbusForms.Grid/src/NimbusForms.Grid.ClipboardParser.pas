unit NimbusForms.Grid.ClipboardParser;

interface

type
  TThemedGridClipboardBlock = TArray<TArray<string>>;

  TThemedGridClipboardParser = class sealed
  private
    class function GetRowBreakLength(const AText: string; const AIndex: Integer;
      const ARowSeparator: string): Integer; static;
    class function MatchesAt(const AText: string; const AIndex: Integer; const AValue: string): Boolean; static;
    class function IsEmptyRow(const ARow: TArray<string>): Boolean; static;
  public
    const
      DefaultColumnSeparator = #9;
      DefaultRowSeparator = #13#10;
    class function Parse(const AText, AColumnSeparator, ARowSeparator: string): TThemedGridClipboardBlock; static;
    class function GetMaxColumnCount(const ARows: TThemedGridClipboardBlock): Integer; static;
  end;

implementation

uses
  System.SysUtils,
  System.Generics.Collections;

class function TThemedGridClipboardParser.Parse(const AText, AColumnSeparator,
  ARowSeparator: string): TThemedGridClipboardBlock;
var
  LRows: TList<TArray<string>>;
  LCurrentRow: TList<string>;
  LField: TStringBuilder;
  LColumnSeparator, LRowSeparator: string;
  LInQuotes: Boolean;
  LIndex, LRowBreakLength: Integer;
  LChar: Char;
begin
  SetLength(Result, 0);
  if AText = '' then
    Exit;

  LColumnSeparator := AColumnSeparator;
  if LColumnSeparator = '' then
    LColumnSeparator := DefaultColumnSeparator;
  LRowSeparator := ARowSeparator;
  if LRowSeparator = '' then
    LRowSeparator := DefaultRowSeparator;

  LRows := TList<TArray<string>>.Create;
  LCurrentRow := TList<string>.Create;
  LField := TStringBuilder.Create;
  try
    LInQuotes := False;
    LIndex := 1;
    while LIndex <= Length(AText) do
    begin
      LChar := AText[LIndex];

      if LInQuotes then
      begin
        if LChar = '"' then
        begin
          if (LIndex < Length(AText)) and (AText[LIndex + 1] = '"') then
          begin
            LField.Append('"');
            Inc(LIndex, 2);
            Continue;
          end;
          LInQuotes := False;
          Inc(LIndex);
          Continue;
        end;
        LField.Append(LChar);
        Inc(LIndex);
        Continue;
      end;

      if (LChar = '"') and (LField.Length = 0) then
      begin
        LInQuotes := True;
        Inc(LIndex);
        Continue;
      end;

      LRowBreakLength := GetRowBreakLength(AText, LIndex, LRowSeparator);
      if LRowBreakLength > 0 then
      begin
        LCurrentRow.Add(LField.ToString);
        LField.Clear;
        LRows.Add(LCurrentRow.ToArray);
        LCurrentRow.Clear;
        Inc(LIndex, LRowBreakLength);
        Continue;
      end;

      if MatchesAt(AText, LIndex, LColumnSeparator) then
      begin
        LCurrentRow.Add(LField.ToString);
        LField.Clear;
        Inc(LIndex, Length(LColumnSeparator));
        Continue;
      end;

      LField.Append(LChar);
      Inc(LIndex);
    end;

    if (LField.Length > 0) or (LCurrentRow.Count > 0) then
    begin
      LCurrentRow.Add(LField.ToString);
      LRows.Add(LCurrentRow.ToArray);
    end;

    while (LRows.Count > 0) and IsEmptyRow(LRows[LRows.Count - 1]) do
      LRows.Delete(LRows.Count - 1);

    Result := LRows.ToArray;
  finally
    LField.Free;
    LCurrentRow.Free;
    LRows.Free;
  end;
end;

class function TThemedGridClipboardParser.GetMaxColumnCount(const ARows: TThemedGridClipboardBlock): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to High(ARows) do
    if Length(ARows[I]) > Result then
      Result := Length(ARows[I]);
end;

class function TThemedGridClipboardParser.IsEmptyRow(const ARow: TArray<string>): Boolean;
var
  I: Integer;
begin
  for I := 0 to High(ARow) do
    if ARow[I] <> '' then
      Exit(False);
  Result := True;
end;

class function TThemedGridClipboardParser.GetRowBreakLength(const AText: string; const AIndex: Integer;
  const ARowSeparator: string): Integer;
var
  LChar: Char;
begin
  if MatchesAt(AText, AIndex, ARowSeparator) then
    Exit(Length(ARowSeparator));
  LChar := AText[AIndex];
  if LChar = #13 then
  begin
    if (AIndex < Length(AText)) and (AText[AIndex + 1] = #10) then
      Exit(2);
    Exit(1);
  end;
  if LChar = #10 then
    Exit(1);
  Result := 0;
end;

class function TThemedGridClipboardParser.MatchesAt(const AText: string; const AIndex: Integer;
  const AValue: string): Boolean;
var
  I: Integer;
begin
  if AValue = '' then
    Exit(False);
  if AIndex + Length(AValue) - 1 > Length(AText) then
    Exit(False);
  for I := 1 to Length(AValue) do
    if AText[AIndex + I - 1] <> AValue[I] then
      Exit(False);
  Result := True;
end;

end.

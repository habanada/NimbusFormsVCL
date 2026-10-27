unit NimbusPieceTableStressChecks;

interface

procedure RunPieceTableStressChecks(const FirstSeed, SeedCount, Steps: Integer);

implementation

uses System.SysUtils, System.Math, System.Classes, System.NetEncoding,
  NimbusForms.Controls.CodeEditor.Types, NimbusForms.Controls.CodeEditor.PieceTable;

type
  TStressRun = class
  private
    FState: Cardinal;
    FSeed, FStep: Integer;
    FMode: string;
    FHistory: TStringList;
    FChecks, FOperations: Int64;
    function Next(const Limit: Integer): Integer;
    function Normalize(const S: string): string;
    function Payload: string;
    function Boundary(const Size: Integer): Integer;
    procedure Check(const Condition: Boolean; const Name: string);
    procedure RecordOp(const Name: string; const Offset, Count: Integer; const Value: string);
    procedure Verify(Table: TCodePieceTable; const Oracle: string; const Exhaustive: Boolean);
    procedure ReadOnlyChecks(Table: TCodePieceTable);
    procedure Scenario(const Seed, Steps: Integer; const NewLine: string);
    procedure Boundaries;
    procedure BufferChecks;
    procedure BufferRangeChecks;
    procedure ExhaustiveEdits;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Run(const FirstSeed, SeedCount, Steps: Integer);
  end;

constructor TStressRun.Create;
begin inherited; FHistory := TStringList.Create; end;

destructor TStressRun.Destroy;
begin FHistory.Free; inherited; end;

function TStressRun.Next(const Limit: Integer): Integer;
begin
  FState := Cardinal((UInt64(FState) * 1664525 + 1013904223) and $FFFFFFFF);
  Result := Integer(FState mod Cardinal(Max(1, Limit)));
end;

function TStressRun.Normalize(const S: string): string;
var I: Integer; B: TStringBuilder;
begin
  B := TStringBuilder.Create;
  try
    I := 1;
    while I <= Length(S) do
    begin
      if S[I] = #13 then
      begin
        B.Append(FMode);
        if (I < Length(S)) and (S[I + 1] = #10) then Inc(I);
      end
      else if S[I] = #10 then B.Append(FMode) else B.Append(S[I]);
      Inc(I);
    end;
    Result := B.ToString;
  finally B.Free; end;
end;

function TStressRun.Payload: string;
var I: Integer;
begin
  Result := '';
  for I := 1 to Next(24) do
    case Next(12) of
      0: Result := Result + #13;
      1: Result := Result + #10;
      2: Result := Result + #13#10;
      3: Result := Result + #0;
      4: Result := Result + #9;
      5: Result := Result + Char($D83D) + Char($DE00);
      6: Result := Result + Char($D800);
      7: Result := Result + Char($DC00);
      8: Result := Result + 'e' + Char($0301);
      9: Result := Result + Char($2028) + Char($2029);
      else Result := Result + Char(Ord('a') + Next(26));
    end;
end;

function TStressRun.Boundary(const Size: Integer): Integer;
begin
  case Next(10) of
    0: Result := Low(Integer);
    1: Result := -1;
    2: Result := 0;
    3: Result := Size;
    4: Result := Size + 1;
    5: Result := MaxInt;
    else Result := Next(Size + 1);
  end;
end;

procedure TStressRun.Check(const Condition: Boolean; const Name: string);
begin
  Inc(FChecks);
  if not Condition then raise EInvalidOpException.Create(Name);
end;

procedure TStressRun.RecordOp(const Name: string; const Offset, Count: Integer; const Value: string);
var Bytes: TBytes;
begin
  SetLength(Bytes, Length(Value) * SizeOf(Char));
  if Length(Bytes) > 0 then Move(Value[1], Bytes[0], Length(Bytes));
  FHistory.Add(Format('%d %s offset=%d count=%d utf16le=%s',
    [FStep, Name, Offset, Count, TNetEncoding.Base64.EncodeBytesToString(Bytes)]));
  if FHistory.Count > 32 then FHistory.Delete(0);
  Inc(FOperations);
end;

procedure TStressRun.Verify(Table: TCodePieceTable; const Oracle: string; const Exhaustive: Boolean);
var Starts, Sizes: TArray<Integer>; Lines: TArray<string>;
  I, N, Start, Finish, Offset, ExpectedLine, Column, Line, Count: Integer;
  Position: TCodeDocumentPosition;
begin
  Table.ValidateStructure;
  Check(Table.Text = Oracle, 'full UTF-16 text');
  Check(Table.Length = Length(Oracle), 'length');
  N := 1;
  for I := 1 to Length(Oracle) do if Oracle[I] = #10 then Inc(N);
  SetLength(Starts, N); SetLength(Sizes, N); Line := 0;
  for I := 1 to Length(Oracle) do
    if Oracle[I] = #10 then begin Inc(Line); Starts[Line] := I; end;
  for Line := 0 to N - 1 do
  begin
    Start := Starts[Line];
    if Line + 1 < N then Finish := Starts[Line + 1] else Finish := Length(Oracle);
    if (Finish > Start) and (Oracle[Finish] = #10) then Dec(Finish);
    if (Finish > Start) and (Oracle[Finish] = #13) then Dec(Finish);
    Sizes[Line] := Finish - Start;
  end;
  Check(Table.LineCount = N, 'LF line count');
  Check((Table.PieceCount >= 0) and (Table.PieceCount <= Length(Oracle)), 'piece count bound');
  Lines := Table.GetLineArray;
  Check(Length(Lines) = N, 'line array count');
  for Line := 0 to N - 1 do
  begin
    Check(Table.GetLineStartOffset(Line) = Starts[Line], 'line start');
    Check(Table.GetLineLength(Line) = Sizes[Line], 'line length');
    Check(Table.GetLineText(Line) = Copy(Oracle, Starts[Line] + 1, Sizes[Line]), 'line text');
    Check(Lines[Line] = Table.GetLineText(Line), 'line array text');
  end;
  Check(Table.GetLineStartOffset(-1) = 0, 'negative line start');
  Check(Table.GetLineStartOffset(MaxInt) = Length(Oracle), 'past end line start');
  Check((Table.GetLineText(-1) = '') and (Table.GetLineLength(MaxInt) = 0), 'invalid line');
  Count := 8;
  if Exhaustive then Count := Length(Oracle) + 3;
  for I := 0 to Count do
  begin
    if Exhaustive then Offset := I - 1
    else case I of
      0: Offset := Low(Integer);
      1: Offset := MaxInt;
      else Offset := Integer((Int64(I) * 7919 + FStep) mod (Length(Oracle) + 1));
    end;
    if (Offset < 0) or (Offset >= Length(Oracle)) then
      Check(Table.GetCharAt(Offset) = #0, 'invalid char sentinel')
    else Check(Table.GetCharAt(Offset) = Oracle[Offset + 1], 'UTF-16 char');
    Offset := EnsureRange(Offset, 0, Length(Oracle)); ExpectedLine := 0;
    while (ExpectedLine + 1 < N) and (Starts[ExpectedLine + 1] <= Offset) do Inc(ExpectedLine);
    Column := Min(Offset - Starts[ExpectedLine], Sizes[ExpectedLine]);
    Position := Table.GetPositionFromOffset(Offset);
    Check((Position.LineIndex = ExpectedLine) and (Position.ColumnIndex = Column), 'offset position');
    Check(Table.GetOffsetFromPosition(Position) = Starts[ExpectedLine] + Column, 'canonical round trip');
    Check(Table.GetText(Offset, MaxInt) = Copy(Oracle, Offset + 1, MaxInt), 'suffix slice');
    Check(Table.GetText(Offset, -1) = '', 'negative slice count');
  end;
  Position := Table.GetPositionFromOffset(Low(Integer));
  Check((Position.LineIndex = 0) and (Position.ColumnIndex = 0), 'negative offset position');
  Position := TCodeDocumentPosition.Create(MaxInt, MaxInt);
  Check(Table.GetOffsetFromPosition(Position) = Starts[N - 1] + Sizes[N - 1], 'high position clamp');
  Position := TCodeDocumentPosition.Create(Low(Integer), Low(Integer));
  Check(Table.GetOffsetFromPosition(Position) = 0, 'low position clamp');
  Check(Table.GetText(Low(Integer), MaxInt) = Oracle, 'low slice clamp');
  Check(Table.GetText(MaxInt, MaxInt) = '', 'high slice clamp');
end;

procedure TStressRun.ReadOnlyChecks(Table: TCodePieceTable);
var Rejected: Boolean;
begin
  Rejected := False;
  try Table.Insert(0, ''); except on E: EInvalidOpException do Rejected := True; end;
  Check(Rejected, 'snapshot empty insert rejected');
  Rejected := False;
  try Table.Delete(0, 0); except on E: EInvalidOpException do Rejected := True; end;
  Check(Rejected, 'snapshot empty delete rejected');
  Rejected := False;
  try Table.Text := 'blocked'; except on E: EInvalidOpException do Rejected := True; end;
  Check(Rejected, 'snapshot reset rejected');
  Rejected := False;
  try Table.Insert(0, 'blocked'); except on E: EInvalidOpException do Rejected := True; end;
  Check(Rejected, 'snapshot insert rejected');
  Rejected := False;
  try Table.Delete(0, MaxInt); except on E: EInvalidOpException do Rejected := True; end;
  Check(Rejected, 'snapshot delete rejected');
end;

procedure TStressRun.Scenario(const Seed, Steps: Integer; const NewLine: string);
var Table, Nested: TCodePieceTable; Snapshots: array[0..3] of TCodePieceTable;
  Saved: array[0..3] of string; Oracle, Value, Removed: string;
  Offset, Count, At, Size, Slot, Op, I, Step: Integer;
begin
  FSeed := Seed; FState := Cardinal(Seed); FMode := NewLine; FHistory.Clear;
  Table := TCodePieceTable.Create(NewLine); Nested := nil;
  for I := 0 to High(Snapshots) do Snapshots[I] := nil;
  try
    Oracle := '';
    for Step := 1 to Steps do
    begin
      FStep := Step;
      Offset := Boundary(Length(Oracle)); Count := Boundary(Length(Oracle));
      At := EnsureRange(Offset, 0, Length(Oracle)); Size := Min(Max(0, Count), Length(Oracle) - At);
      Op := Next(12); Value := Payload;
      if Length(Oracle) > 4096 then Op := 3;
      case Op of
        0..4:
          if Op = 3 then
          begin
            RecordOp('delete', Offset, Count, ''); Removed := Table.Delete(Offset, Count);
            Check(Removed = Copy(Oracle, At + 1, Size), 'delete result'); Delete(Oracle, At + 1, Size);
          end
          else
          begin
            if Op = 0 then begin Offset := 0; At := 0; end;
            if Op = 1 then begin Offset := Length(Oracle); At := Offset; end;
            RecordOp('insert', Offset, 0, Value); Table.Insert(Offset, Value);
            Oracle := Copy(Oracle, 1, At) + Normalize(Value) + Copy(Oracle, At + 1, MaxInt);
          end;
        5, 6:
          begin
            RecordOp('delete', Offset, Count, ''); Removed := Table.Delete(Offset, Count);
            Check(Removed = Copy(Oracle, At + 1, Size), 'delete result'); Delete(Oracle, At + 1, Size);
          end;
        7:
          begin RecordOp('set', 0, 0, Value); Table.Text := Value; Oracle := Normalize(Value); end;
        8, 9:
          begin
            Slot := Next(4); RecordOp('snapshot', Slot, 0, '');
            Snapshots[Slot].Free; Snapshots[Slot] := nil;
            Snapshots[Slot] := Table.CreateSnapshot; Saved[Slot] := Oracle;
            ReadOnlyChecks(Snapshots[Slot]);
          end;
        else
          begin RecordOp('slice', Offset, Count, ''); Check(Table.GetText(Offset, Count) = Copy(Oracle, At + 1, Size), 'slice'); end;
      end;
      Verify(Table, Oracle, FStep mod 97 = 0);
      for I := 0 to High(Snapshots) do
        if Snapshots[I] <> nil then Verify(Snapshots[I], Saved[I], False);
    end;
    Nested := Table.CreateSnapshot; Table.Free; Table := nil;
    for I := 0 to High(Snapshots) do
      if Snapshots[I] <> nil then Verify(Snapshots[I], Saved[I], False);
    Verify(Nested, Oracle, True); ReadOnlyChecks(Nested);
    Table := Nested.CreateSnapshot; Nested.Free; Nested := nil;
    Verify(Table, Oracle, True); ReadOnlyChecks(Table);
  finally
    Table.Free; Nested.Free;
    for I := 0 to High(Snapshots) do Snapshots[I].Free;
  end;
end;

procedure TStressRun.Boundaries;
const Sizes: array[0..10] of Integer = (0, 1, 2, 8191, 8192, 8193, 65535, 65536, 65537, 122880, 1048576);
var Table, Snapshot: TCodePieceTable; Oracle, Value, Saved: string; I, J, At, Count: Integer;
begin
  FSeed := 0; FHistory.Clear;
  Table := TCodePieceTable.Create(FMode); Snapshot := nil;
  try
    for I := Low(Sizes) to High(Sizes) do
    begin
      FStep := I; Value := StringOfChar('a', Sizes[I]) + #13#10 + Char($D83D) + Char($DE00) + #0;
      RecordOp('boundary-set', 0, Sizes[I], ''); Table.Text := Value; Oracle := Normalize(Value);
      Verify(Table, Oracle, False);
      Snapshot.Free; Snapshot := nil; Snapshot := Table.CreateSnapshot; Saved := Oracle;
      for J := 0 to 15 do
      begin
        At := Min(Length(Oracle), Max(0, Sizes[I] - J)); Value := #13#10'x'#10;
        RecordOp('boundary-insert', At, 0, Value); Table.Insert(At, Value);
        Oracle := Copy(Oracle, 1, At) + Normalize(Value) + Copy(Oracle, At + 1, MaxInt);
        Count := Min(8193, Length(Oracle) - At);
        RecordOp('boundary-delete', At, Count, '');
        Check(Table.Delete(At, Count) = Copy(Oracle, At + 1, Count), 'boundary deletion');
        Delete(Oracle, At + 1, Count); Verify(Table, Oracle, False); Verify(Snapshot, Saved, False);
      end;
      Table.Text := ''; Table.Insert(0, StringOfChar('b', Sizes[I]));
      Verify(Table, StringOfChar('b', Sizes[I]), False); Verify(Snapshot, Saved, False);
    end;
    Table.Text := StringOfChar('a', 8192 * 15);
    Check(Table.Delete(24576, 8192) = StringOfChar('a', 8192), 'deep successor delete');
    Verify(Table, StringOfChar('a', 8192 * 14), False);
    Table.Text := StringOfChar('a', 8192);
    for J := 1 to 2048 do begin Table.Insert(4096, 'x'); Table.ValidateStructure; end;
    Verify(Table, StringOfChar('a', 4096) + StringOfChar('x', 2048) + StringOfChar('a', 4096), False);
    for J := 1 to 2048 do begin Table.Delete(4096, 1); Table.ValidateStructure; end;
    Verify(Table, StringOfChar('a', 8192), False);
  finally Snapshot.Free; Table.Free; end;
end;

procedure TStressRun.BufferChecks;
var Buffer, Snapshot: TCodeChunkedAppendBuffer; B: TStringBuilder;
  Oracle, Value, Saved: string; ChunkSize, I, Offset, Count, Appended, J, Expected: Integer;
  Rejected: Boolean;
begin
  FSeed := 0; FState := 987654321; FHistory.Clear;
  Rejected := False;
  try Buffer := TCodeChunkedAppendBuffer.Create(0); Buffer.Free;
  except on E: EArgumentOutOfRangeException do Rejected := True; end;
  Check(Rejected, 'zero chunk size rejected');
  for ChunkSize in [1, 2, 3, 7, 64] do
  begin
    Buffer := TCodeChunkedAppendBuffer.Create(ChunkSize); Snapshot := nil; B := TStringBuilder.Create;
    try
      Oracle := '';
      for I := 1 to 300 do
      begin
        FStep := I; Value := Payload;
        RecordOp('buffer-append', ChunkSize, 0, Value);
        if I mod 2 = 0 then
        begin
          Check(Buffer.AppendNormalized(Value, FMode, Appended) = Length(Oracle), 'normalized append offset');
          Check(Appended = Length(Normalize(Value)), 'normalized append count'); Oracle := Oracle + Normalize(Value);
        end
        else begin Check(Buffer.Append(Value) = Length(Oracle), 'raw append offset'); Oracle := Oracle + Value; end;
        B.Clear; Buffer.AppendTo(B, 0, MaxInt); Check(B.ToString = Oracle, 'buffer text');
        Check(Buffer.Length = Length(Oracle), 'buffer length');
        Offset := Next(Length(Oracle) + 1); Count := Next(Length(Oracle) + 1); Count := Min(Count, Length(Oracle) - Offset);
        Expected := 0;
        for J := 1 to Count do if Oracle[Offset + J] = #10 then
        begin Check(Buffer.FindLineFeed(Offset, Count, Expected) = J - 1, 'buffer LF lookup'); Inc(Expected); end;
        Check(Buffer.CountLineFeeds(Offset, Count) = Expected, 'buffer LF count');
        Check(Buffer.FindLineFeed(Offset, Count, Expected) = -1, 'missing LF');
        if I mod 17 = 0 then
        begin Snapshot.Free; Snapshot := nil; Snapshot := Buffer.Snapshot; Saved := Oracle; end;
        if Snapshot <> nil then
        begin B.Clear; Snapshot.AppendTo(B, 0, MaxInt); Check(B.ToString = Saved, 'buffer snapshot'); end;
        if I mod 43 = 0 then begin Buffer.Clear; Oracle := ''; end;
      end;
      Buffer.Free; Buffer := nil;
      if Snapshot <> nil then
      begin
        B.Clear; Snapshot.AppendTo(B, 0, MaxInt); Check(B.ToString = Saved, 'buffer snapshot after source destruction');
        Rejected := False;
        try Snapshot.Clear; except on E: EInvalidOpException do Rejected := True; end;
        Check(Rejected, 'buffer snapshot clear rejected');
        Rejected := False;
        try Snapshot.Append('x'); except on E: EInvalidOpException do Rejected := True; end;
        Check(Rejected, 'buffer snapshot append rejected');
        Rejected := False;
        try Snapshot.AppendNormalized('', FMode, Appended); except on E: EInvalidOpException do Rejected := True; end;
        Check(Rejected, 'buffer snapshot normalized append rejected');
      end;
    finally B.Free; Snapshot.Free; Buffer.Free; end;
  end;
end;

procedure TStressRun.ExhaustiveEdits;
const Alphabet: array[0..3] of Char = ('x', #13, #10, #0);
  Counts: array[0..4] of Integer = (Low(Integer), -1, 0, 1, MaxInt);
var Table: TCodePieceTable; Raw, Oracle, Expected, Value: string;
  Width, Combinations, Code, Digits, J, Offset, At, Count, Size, Kind: Integer;
  Rejected: Boolean;
begin
  FSeed := 0; FStep := 0; FHistory.Clear;
  Rejected := False;
  try Table := TCodePieceTable.Create(''); Table.Free;
  except on E: EArgumentException do Rejected := True; end;
  Check(Rejected, 'empty newline mode rejected');
  Rejected := False;
  try Table := TCodePieceTable.Create(#13); Table.Free;
  except on E: EArgumentException do Rejected := True; end;
  Check(Rejected, 'CR newline mode rejected');
  Table := TCodePieceTable.Create(FMode);
  try
    Combinations := 1;
    for Width := 0 to 4 do
    begin
      for Code := 0 to Combinations - 1 do
      begin
        Raw := ''; Digits := Code;
        for J := 1 to Width do begin Raw := Raw + Alphabet[Digits mod 4]; Digits := Digits div 4; end;
        Oracle := Normalize(Raw);
        for Offset := -1 to Length(Oracle) + 1 do
        begin
          At := EnsureRange(Offset, 0, Length(Oracle));
          for Count in Counts do
          begin
            Inc(FStep); Table.Text := Raw;
            RecordOp('exhaustive-set', 0, 0, Raw); RecordOp('exhaustive-delete', Offset, Count, '');
            Size := Min(Max(0, Count), Length(Oracle) - At);
            Check(Table.Delete(Offset, Count) = Copy(Oracle, At + 1, Size), 'exhaustive delete return');
            Expected := Oracle; Delete(Expected, At + 1, Size); Verify(Table, Expected, True);
          end;
          for Kind := 0 to 3 do
          begin
            case Kind of
              0: Value := '';
              1: Value := #13#10;
              2: Value := #10#13;
              else Value := Char($D800) + #0 + 'x';
            end;
            Inc(FStep); Table.Text := Raw;
            RecordOp('exhaustive-set', 0, 0, Raw); RecordOp('exhaustive-insert', Offset, 0, Value);
            Table.Insert(Offset, Value);
            Expected := Copy(Oracle, 1, At) + Normalize(Value) + Copy(Oracle, At + 1, MaxInt);
            Verify(Table, Expected, True);
          end;
        end;
      end;
      Combinations := Combinations * 4;
    end;
  finally Table.Free; end;
end;

procedure TStressRun.BufferRangeChecks;
const Offsets: array[0..6] of Integer = (Low(Integer), -2, -1, 0, 1, 6, MaxInt);
  Counts: array[0..5] of Integer = (Low(Integer), -1, 0, 1, 6, MaxInt);
  Text = 'a'#10#0'b'#13#10;
var Buffer: TCodeChunkedAppendBuffer; Builder: TStringBuilder;
  Offset, Count, Start, Size, Expected, I: Integer; Available: Int64;
begin
  FSeed := 0; FStep := 0; FHistory.Clear;
  Buffer := TCodeChunkedAppendBuffer.Create(2); Builder := TStringBuilder.Create;
  try
    Buffer.Append(Text);
    for Offset in Offsets do
      for Count in Counts do
      begin
        Inc(FStep); RecordOp('buffer-range', Offset, Count, '');
        Start := EnsureRange(Offset, 0, Length(Text));
        Builder.Clear; Buffer.AppendTo(Builder, Offset, Count);
        Check(Builder.ToString = Copy(Text, Start + 1, Max(0, Count)), 'buffer clamped slice');
        Available := Count;
        if Offset < 0 then Available := Available + Int64(Offset);
        Available := Max(Int64(0), Min(Available, Int64(Length(Text)) - Max(0, Offset)));
        Size := Integer(Available); Expected := 0;
        for I := 1 to Size do
          if Text[Start + I] = #10 then
          begin
            Check(Buffer.FindLineFeed(Offset, Count, Expected) = I - 1, 'buffer extreme LF offset');
            Inc(Expected);
          end;
        Check(Buffer.CountLineFeeds(Offset, Count) = Expected, 'buffer extreme LF count');
        Check(Buffer.FindLineFeed(Offset, Count, Expected) = -1, 'buffer extreme missing LF');
        Check(Buffer.FindLineFeed(Offset, Count, -1) = -1, 'buffer negative LF index');
      end;
  finally Builder.Free; Buffer.Free; end;
end;

procedure TStressRun.Run(const FirstSeed, SeedCount, Steps: Integer);
var Mode, Seed, Stage, Failures: Integer;
begin
  if (FirstSeed < 1) or (SeedCount < 1) or (Steps < 1) or (FirstSeed > MaxInt - SeedCount) then
    raise EArgumentOutOfRangeException.Create('Positive seeds/steps required without seed overflow');
  Failures := 0;
  for Mode := 0 to 1 do
  begin
    if Mode = 0 then FMode := #10 else FMode := #13#10;
    for Stage := 0 to 3 do
    begin
      try
        case Stage of 0: ExhaustiveEdits; 1: Boundaries; 2: BufferChecks; 3: BufferRangeChecks; end;
      except on E: Exception do
        begin Inc(Failures); Writeln('FAIL deterministic stage=', Stage, ' mode=', Mode, ' step=', FStep, ' ', E.ClassName, ': ', E.Message); Writeln(FHistory.Text); end;
      end;
    end;
    for Seed := FirstSeed to FirstSeed + SeedCount - 1 do
    begin
      try
        if Mode = 0 then Scenario(Seed, Steps, #10) else Scenario(Seed, Steps, #13#10);
      except on E: Exception do
        begin
          Inc(Failures); Writeln('FAIL seed=', FSeed, ' mode=', Mode, ' step=', FStep, ' ', E.ClassName, ': ', E.Message);
          Writeln(FHistory.Text);
        end;
      end;
      if (Seed - FirstSeed) mod 16 = 0 then Writeln('Progress mode=', Mode, ' seed=', Seed, ' checks=', FChecks);
    end;
  end;
  Writeln('RESULT random_steps_requested=', Int64(SeedCount) * Steps * 2,
    ' recorded_operations=', FOperations, ' assertions=', FChecks, ' failed_scenarios=', Failures);
  if Failures <> 0 then raise EInvalidOpException.CreateFmt('%d stress scenarios failed', [Failures]);
end;

procedure RunPieceTableStressChecks(const FirstSeed, SeedCount, Steps: Integer);
var Run: TStressRun;
begin
  Run := TStressRun.Create;
  try Run.Run(FirstSeed, SeedCount, Steps); finally Run.Free; end;
end;

end.

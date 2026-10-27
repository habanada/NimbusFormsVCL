{
  SPDX-FileCopyrightText: 2026 Selahattin Erkoc
  SPDX-License-Identifier: MIT

  This file is part of NimbusForms.
  See LICENSE and THIRD-PARTY-NOTICES.md in the repository root.
}

program NimbusLogViewerTests;

{$APPTYPE CONSOLE}

uses System.SysUtils, System.Classes, System.Types, System.Math, System.IOUtils,
  System.Diagnostics,
  Vcl.Forms, Vcl.Graphics, NimbusForms.Controls.LogViewer.Types, NimbusForms.Controls.LogViewer.Model,
  NimbusForms.Controls.LogViewer.Monitor, NimbusForms.Controls.LogViewer.View, NimbusForms.Controls.LogViewer,
  NimbusForms.Controls.LogViewer.Encoding,
  NimbusForms.Rendering.LogViewer, NimbusForms.Rendering.Canvas, NimbusForms.Controls.Types;

procedure Check(const AValue: Boolean; const AText: string);
begin if not AValue then raise Exception.Create(AText); end;

{$I NimbusTestPaths.inc}

type
  TLineCollector = class
  public
    Lines: TStringList;
    constructor Create;
    destructor Destroy; override;
    procedure Add(const AText: string);
  end;

constructor TLineCollector.Create;
begin inherited; Lines := TStringList.Create; end;

destructor TLineCollector.Destroy;
begin Lines.Free; inherited; end;

procedure TLineCollector.Add(const AText: string);
begin Lines.Add(AText); end;

procedure LexerChecks;
var Tokens: TNimbusLogTokens; Token: TNimbusLogToken; Level: TNimbusLogLevel;
  Kinds: TNimbusLogHighlightKinds; Count: Integer; EmojiText: string;
begin
  Check(TNimbusLogLexer.LevelOf('err') = nllError, 'err alias');
  Check(TNimbusLogLexer.LevelOf('ERROR') = nllError, 'error alias');
  Check(TNimbusLogLexer.LevelOf('Warning') = nllWarning, 'warning alias');
  Check(TNimbusLogLexer.LevelOf('Information') = nllInfo, 'information alias');
  Check(TNimbusLogLexer.LevelOf('dbg') = nllDebug, 'debug alias');
  Check(TNimbusLogLexer.LevelOf('information2') = nllUnknown, 'whole level words');
  Tokens := TNimbusLogLexer.Parse('2026-10-14T12:34:56.123Z [WARN] amount=-12.75 sample=1e-3 hex=0xFF (pid=12) {"text":"hello"}', Level);
  Kinds := []; Count := 0;
  for Token in Tokens do
  begin Include(Kinds, Token.Kind); Inc(Count, Token.Length); end;
  Check(Level = nllWarning, 'line severity inference');
  Check([nltkDateTime, nltkLevel, nltkNumber, nltkString, nltkParenthesis, nltkBracket, nltkBrace] <= Kinds, 'syntax token kinds');
  Check(Count = Length('2026-10-14T12:34:56.123Z [WARN] amount=-12.75 sample=1e-3 hex=0xFF (pid=12) {"text":"hello"}'), 'tokens cover original text');
  Tokens := TNimbusLogLexer.Parse('"ERROR" [Info] details=warning', Level);
  Check(Level = nllInfo, 'quoted severity must not classify the line');
  Count := 0;
  for Token in Tokens do if Token.Kind = nltkLevel then
  begin
    if Count = 0 then Check(Token.Level = nllInfo, 'per-token info severity')
    else Check(Token.Level = nllWarning, 'per-token warning severity');
    Inc(Count);
  end;
  Check(Count = 2, 'two level tokens');
  EmojiText := Char($D83D) + Char($DE00);
  Tokens := TNimbusLogLexer.Parse(EmojiText, Level);
  Check((Length(Tokens) = 1) and (Tokens[0].Length = 2), 'log emoji surrogate pair stays in one token');
end;

procedure ModelChecks;
var M: TNimbusLogModel; Last: UInt64;
begin
  M := TNimbusLogModel.Create(nil);
  try
    M.MaxLines := 3;
    M.AddText('one' + #13#10 + 'two' + #10 + 'three' + #10);
    Check((M.Count = 3) and (M[2].Text = 'three'), 'split without phantom terminal line');
    Last := M[2].ID;
    M.AddLine('four');
    Check((M.Count = 3) and (M[0].Text = 'two') and (M[2].Text = 'four'), 'bottom ring retention');
    M.InsertMode := nlimTop;
    M.AddText('five' + #10 + 'six');
    Check((M[0].Text = 'six') and (M[1].Text = 'five') and (M[2].Text = 'two'), 'top ring retention');
    Check(M[0].ID > Last, 'stable monotonic IDs');
    M.MaxLines := 2;
    Check((M.Count = 2) and (M[1].Text = 'five'), 'shrinking top retention');
    M.Clear;
    M.InsertMode := nlimBottom;
    M.AddText('a' + #10 + #10 + 'b');
    Check((M.Count = 2) and (M[0].Text = '') and (M[1].Text = 'b'), 'empty physical lines preserved');
  finally M.Free; end;
end;

procedure SearchChecks;
var M: TNimbusLogModel; Options: TNimbusLogHighlightOptions; View: TCustomNimbusLogView;
  Rejected: Boolean;
begin
  M := TNimbusLogModel.Create(nil); Options := TNimbusLogHighlightOptions.Create(nil);
  View := TCustomNimbusLogView.Create(nil);
  try
    M.AddText('[ERROR] file failed' + #10 + '[Information] done' + #10 + '[err] another file failed');
    View.Attach(M, Options);
    View.ConfigureSearch('FILE', False, False, True);
    Check((View.VisibleCount = 2) and (View.MatchCount = 2), 'literal case insensitive filtering');
    Check(View.FindNext, 'search navigation');
    Check(Pos('ERROR', View.SelectionText) > 0, 'search selects matching row');
    View.ConfigureSearch('file', True, False, False);
    Check(View.MatchCount = 2, 'case sensitive search');
    View.ConfigureSearch('failed$', False, True, True);
    Check(View.VisibleCount = 2, 'regex search');
    Rejected := False;
    try View.ConfigureSearch('[', False, True, False); except on E: Exception do Rejected := True; end;
    Check(Rejected, 'invalid regex accepted');
    Check(View.VisibleCount = 2, 'invalid regex leaves previous view intact');
    View.SetLevels([nllInfo]);
    View.ConfigureSearch('', False, False, False);
    Check(View.VisibleCount = 1, 'level filter');
    Check(not View.HandleAllocated, 'search/model setup must not force a window handle');
  finally View.Free; Options.Free; M.Free; end;
end;

procedure AppendBytes(const APath: string; const ABytes: TBytes);
var Stream: TFileStream;
begin
  Stream := TFileStream.Create(APath, fmOpenReadWrite or fmShareDenyNone);
  try Stream.Seek(0, soEnd); if Length(ABytes) > 0 then Stream.WriteBuffer(ABytes[0], Length(ABytes));
  finally Stream.Free; end;
end;

procedure FileChecks;
var Root, Path, Rotated: string; G: TGUID; M, CopyModel: TNimbusLogModel;
  Monitor: TNimbusLogFileMonitor; Collector: TLineCollector;
begin
  Root := TestFixtureRoot;
  ForceDirectories(Root); CreateGUID(G);
  Path := TPath.Combine(Root, 'logviewer-' + GUIDToString(G) + '.log');
  Rotated := Path + '.old';
  M := TNimbusLogModel.Create(nil); CopyModel := TNimbusLogModel.Create(nil);
  Monitor := TNimbusLogFileMonitor.Create; Collector := TLineCollector.Create;
  try
    M.AddText('Information ' + Char($00E4) + #10 + 'ERROR second');
    M.SaveFile(Path);
    CopyModel.InsertMode := nlimTop;
    CopyModel.LoadFile(Path);
    Check((CopyModel.Count = 2) and (CopyModel[0].Text = M[0].Text), 'UTF-8 roundtrip preserves stored order');
    M.SaveFile(Path, nlfeUTF16BE); CopyModel.LoadFile(Path);
    Check(CopyModel[0].Text = M[0].Text, 'BOM detection UTF-16BE');
    TFile.WriteAllBytes(Path, TBytes.Create($EF, $BB, $BF));
    Monitor.Start(Path, False); Monitor.Poll(Collector.Add);
    AppendBytes(Path, TBytes.Create($C3)); Monitor.Poll(Collector.Add);
    Check(Collector.Lines.Count = 0, 'partial UTF-8 line remains buffered');
    AppendBytes(Path, TBytes.Create($A4, 13, 10)); Monitor.Poll(Collector.Add);
    Check((Collector.Lines.Count = 1) and (Collector.Lines[0] = Char($00E4)), 'UTF-8 bytes spanning polls');
    TFile.Move(Path, Rotated);
    TFile.WriteAllText(Path, 'new file' + #10, TEncoding.UTF8);
    Monitor.Poll(Collector.Add);
    Check(Collector.Lines[1] = 'new file', 'rotated file reopened by identity');
    TFile.WriteAllText(Path, 'x' + #10, TEncoding.UTF8); Monitor.Poll(Collector.Add);
    Check(Collector.Lines[2] = 'x', 'truncation resets reader');
    Monitor.Stop; Collector.Lines.Clear;
    TFile.WriteAllText(Path, 'old partial', TEncoding.UTF8); Monitor.Start(Path, True); Monitor.Poll(Collector.Add);
    AppendBytes(Path, TEncoding.UTF8.GetBytes(' rest' + #10 + 'complete' + #10)); Monitor.Poll(Collector.Add);
    Check((Collector.Lines.Count = 1) and (Collector.Lines[0] = 'complete'), 'from-end ignores preexisting partial record');
    Monitor.Stop;
    TFile.WriteAllText(Path, 'wide' + #10, TEncoding.Unicode);
    Monitor.Start(Path, False); Collector.Lines.Clear; Monitor.Poll(Collector.Add);
    Check((Collector.Lines.Count = 1) and (Collector.Lines[0] = 'wide'), 'UTF-16 monitored newline framing');
  finally Collector.Free; Monitor.Free; CopyModel.Free; M.Free; end;
end;

procedure EncodingChecks;
var
  E: TNimbusLogFileEncoding;
  B, I, BOMSize: Integer;
  Text, Root, Path, Line: string;
  Bytes, Header, Saved: TBytes;
  G: TGUID;
  Decoder: TNimbusLogLineDecoder;
  Decoded: TArray<string>;
  All: TStringList;
  M, Loaded: TNimbusLogModel;
  Monitor: TNimbusLogFileMonitor;
  Collector: TLineCollector;
  Viewer: TThemedLogViewer;
  Rejected: Boolean;
begin
  Text := 'Information ' + Char($00E4) + Char($03A9) + Char($4E2D) + Char($D83D) + Char($DE00);
  for E := nlfeUTF8 to nlfeUTF32BE do
  begin
    if E in [nlfeANSI, nlfeASCII] then Continue;
    Bytes := TNimbusLogTextCodec.Encode(Text, E);
    Check(TNimbusLogTextCodec.Decode(Bytes, E) = Text, 'Unicode codec roundtrip: ' + TNimbusLogTextCodec.Name(E));
    Check(TNimbusLogTextCodec.Detect(Bytes, nlfeAuto, BOMSize) = E, 'BOM-less Unicode detection: ' + TNimbusLogTextCodec.Name(E));
    Header := TNimbusLogTextCodec.Preamble(E);
    Check(TNimbusLogTextCodec.Detect(Header, nlfeAuto, BOMSize) = E, 'BOM priority: ' + TNimbusLogTextCodec.Name(E));
    Check(BOMSize = Length(Header), 'BOM byte count');
    Bytes := TNimbusLogTextCodec.Encode(Text + #13#10 + 'second' + #13 + 'third' + #10 + 'last', E);
    Decoder := TNimbusLogLineDecoder.Create(E);
    All := TStringList.Create;
    try
      for I := 0 to High(Bytes) do
      begin
        Decoded := Decoder.Feed(TBytes.Create(Bytes[I]), 1);
        for Line in Decoded do All.Add(Line);
      end;
      Decoded := Decoder.Feed(nil, 0, True);
      for Line in Decoded do All.Add(Line);
      Check((All.Count = 4) and (All[0] = Text) and (All[3] = 'last'), 'Single-byte chunks and CR/LF framing');
    finally All.Free; Decoder.Free; end;
  end;
  Rejected := False;
  try TNimbusLogTextCodec.Encode(Char($00E4), nlfeASCII); except on Err: EConvertError do Rejected := True; end;
  Check(Rejected, 'ASCII export must reject lossy characters');
  Bytes := TNimbusLogTextCodec.Encode(Char($00E4), nlfeLatin1);
  Check((Bytes[0] = $E4) and (TNimbusLogTextCodec.Decode(Bytes, nlfeLatin1) = Char($00E4)), 'Latin-1 mapping');
  Bytes := TNimbusLogTextCodec.Encode(Char($20AC), nlfeWindows1252);
  Check((Bytes[0] = $80) and (TNimbusLogTextCodec.Decode(Bytes, nlfeWindows1252) = Char($20AC)), 'Windows-1252 euro');
  Rejected := False;
  try TNimbusLogTextCodec.Decode(TBytes.Create($00, $D8), nlfeUTF16LE); except on Err: EConvertError do Rejected := True; end;
  Check(Rejected, 'unpaired UTF-16 surrogate rejected');
  Rejected := False;
  try TNimbusLogTextCodec.Decode(TBytes.Create($00, $00, $11, $00), nlfeUTF32LE); except on Err: EConvertError do Rejected := True; end;
  Check(Rejected, 'out-of-range UTF-32 scalar rejected');
  Root := TestFixtureRoot;
  ForceDirectories(Root); CreateGUID(G); Path := TPath.Combine(Root, 'encoding-' + GUIDToString(G) + '.log');
  M := TNimbusLogModel.Create(nil); Loaded := TNimbusLogModel.Create(nil);
  Monitor := TNimbusLogFileMonitor.Create; Collector := TLineCollector.Create;
  try
    M.AddLine(Text); M.AddLine('ERROR second');
    for E := nlfeUTF8 to nlfeUTF32BE do
    begin
      if E in [nlfeANSI, nlfeASCII] then Continue;
      for B := 0 to 1 do
      begin
        M.SaveFile(Path, E, B = 1);
        Loaded.LoadFile(Path);
        Check((Loaded.LoadedEncoding = E) and (Loaded.Count = 2) and (Loaded[0].Text = Text), 'Unicode file roundtrip');
        Collector.Lines.Clear;
        Monitor.Start(Path, False); Monitor.Poll(Collector.Add);
        Check((Monitor.DetectedEncoding = E) and (Collector.Lines.Count = 2) and (Collector.Lines[0] = Text), 'Unicode monitoring');
        Monitor.Stop;
      end;
    end;
    Saved := TFile.ReadAllBytes(Path);
    Rejected := False;
    try M.SaveFile(Path, nlfeASCII); except on Err: EConvertError do Rejected := True; end;
    Check(Rejected, 'Lossy save rejected');
    Bytes := TFile.ReadAllBytes(Path);
    Check((Length(Bytes) = Length(Saved)) and CompareMem(@Bytes[0], @Saved[0], Length(Bytes)), 'Rejected save preserves destination');
    for E := nlfeANSI to nlfeWindows1252 do
      if E in [nlfeANSI, nlfeASCII, nlfeLatin1, nlfeWindows1252] then
      begin
        M.Clear; M.AddLine('INFO ascii-safe text');
        M.SaveFile(Path, E, False); Loaded.LoadFile(Path, E);
        Check(Loaded[0].Text = M[0].Text, 'Legacy encoding file roundtrip');
      end;
    TFile.WriteAllBytes(Path, nil);
    Monitor.Start(Path, True); Monitor.Poll(Collector.Add);
    Collector.Lines.Clear;
    AppendBytes(Path, TNimbusLogTextCodec.Encode(Text + #10, nlfeUTF32BE));
    Monitor.Poll(Collector.Add);
    Check((Collector.Lines.Count = 1) and (Collector.Lines[0] = Text), 'Watching an initially empty UTF-32 file');
    Monitor.Stop;
    Viewer := TThemedLogViewer.Create(nil);
    try
      Viewer.AppendLog(Text);
      Viewer.FileEncoding := nlfeUTF32LE; Viewer.WriteBOM := False; Viewer.SaveFile(Path);
      Viewer.FileEncoding := nlfeAuto; Viewer.LoadFile(Path);
      Check((Viewer.DetectedFileEncoding = nlfeUTF32LE) and (Viewer.Model[0].Text = Text), 'Control file encoding selection');
      Viewer.SaveFile(Path);
      Loaded.LoadFile(Path);
      Check(Loaded.LoadedEncoding = nlfeUTF32LE, 'Auto save preserves loaded format');
      Check(not Viewer.HandleAllocated, 'encoding operations must not force HWND');
    finally Viewer.Free; end;
  finally Collector.Free; Monitor.Free; Loaded.Free; M.Free; end;
end;

procedure QueueChecks;
var Viewer: TThemedLogViewer; Worker: TThread;
begin
  Viewer := TThemedLogViewer.Create(nil);
  try
    Worker := TThread.CreateAnonymousThread(
      procedure
      var I: Integer;
      begin for I := 1 to 100 do Viewer.QueueLog('DEBUG worker record ' + IntToStr(I)); end);
    Worker.FreeOnTerminate := False;
    try Worker.Start; Worker.WaitFor; finally Worker.Free; end;
    Check(Viewer.PendingLogCount = 100, 'background queue count');
    Check(Viewer.Model.Count = 0, 'background thread must not directly modify VCL/model');
    Viewer.FlushPendingLogs;
    Check((Viewer.Model.Count = 100) and (Viewer.PendingLogCount = 0), 'GUI thread batch drain');
    Check(not Viewer.HandleAllocated, 'queue and flush must not create control handles');
    Viewer.Paused := True;
    Viewer.QueueLog('INFO paused record');
    Check(Viewer.PendingLogCount = 1, 'paused entries remain queued');
  finally Viewer.Free; end;
end;

procedure SourceFileChecks;
var Root, Path, Source, Line: string; G: TGUID; Model, Loaded: TNimbusLogModel;
  Decoder: TNimbusLogLineDecoder; Bytes, Chunk: TBytes; Lines: TArray<string>;
  Collector: TStringList; I, Position, Count: Integer; Rejected: Boolean;
  Encoding: TNimbusLogFileEncoding; Watch: TStopwatch; Tokens: TNimbusLogTokens;
begin
  Root := TestFixtureRoot;
  ForceDirectories(Root); CreateGUID(G);
  Path := TPath.Combine(Root, 'source-' + GUIDToString(G) + '.pas');
  Source := StringOfChar('x', 131071) + #9 + StringOfChar('y', 131071) + ' (123.45) [value] {item}';
  Model := TNimbusLogModel.Create(nil); Loaded := TNimbusLogModel.Create(nil);
  Collector := TStringList.Create;
  try
    for I := 1 to 10000 do Model.AddLine(Format('procedure Service%d.Execute(const AValue: Integer); begin Value := 123.45; end;', [I]));
    Model.AddLine(Source); Model.AddLine('2026-10-14 10:12:13.123 [WARNING] completed');
    for Encoding := nlfeUTF8 to nlfeUTF16BE do
    begin
      Model.SaveFile(Path, Encoding);
      Watch := TStopwatch.StartNew;
      Loaded.LoadFile(Path);
      Watch.Stop;
      Writeln(TNimbusLogTextCodec.Name(Encoding) + ' source load milliseconds: ' + IntToStr(Watch.ElapsedMilliseconds));
      Check((Loaded.Count = Model.Count) and (Loaded[10000].Text = Source), 'long source line and file order survive loading');
      Check(Loaded[10001].Level = nllWarning, 'cached date matcher preserves severity');
      Tokens := Loaded[10000].Tokens; Count := 0;
      for I := 0 to High(Tokens) do Inc(Count, Tokens[I].Length);
      Check(Count = Length(Source), 'transferred source tokens cover full line');
      Check(Loaded[0].ID < Loaded[10001].ID, 'loaded rows receive ordered unique IDs');
      Bytes := TNimbusLogTextCodec.Encode(Source + #13#10 + 'tail', Encoding);
      Decoder := TNimbusLogLineDecoder.Create(Encoding);
      Collector.Clear;
      try
        Position := 0;
        while Position < Length(Bytes) do
        begin
          Count := Min(997, Length(Bytes) - Position);
          Chunk := Copy(Bytes, Position, Count);
          Lines := Decoder.Feed(Chunk, Count);
          for Line in Lines do Collector.Add(Line);
          Inc(Position, Count);
        end;
        Lines := Decoder.Feed(nil, 0, True);
        for Line in Lines do Collector.Add(Line);
        Check((Collector.Count = 2) and (Collector[0] = Source) and (Collector[1] = 'tail'), 'long UTF source lines across unaligned chunks');
      finally Decoder.Free; end;
    end;
    TFile.WriteAllBytes(Path, TBytes.Create($FF, $FE, $41));
    Count := Loaded.Count;
    Rejected := False;
    try Loaded.LoadFile(Path); except on E: EConvertError do Rejected := True; end;
    Check(Rejected, 'invalid source encoding is rejected');
    Check((Loaded.Count = Count) and (Loaded[10000].Text = Source), 'failed source load preserves model ownership');
  finally
    if TFile.Exists(Path) then TFile.Delete(Path);
    Collector.Free; Loaded.Free; Model.Free;
  end;
end;

procedure MarkerChecks;
var Model: TNimbusLogModel; View: TCustomNimbusLogView; Rows: TArray<Integer>; I: Integer;
begin
  Model := TNimbusLogModel.Create(nil); View := TCustomNimbusLogView.Create(nil);
  try
    Model.AddLine('INFO startup'); Model.AddLine('WARN first');
    Model.AddLine('ERROR second'); Model.AddLine('CRITICAL third');
    View.Attach(Model, nil);
    Rows := View.MarkerRows;
    Check((Length(Rows) = 3) and (Rows[0] = 1) and (Rows[1] = 2) and (Rows[2] = 3), 'severity overview positions');
    View.SetLevels([nllError, nllFatal]); Rows := View.MarkerRows;
    Check((Length(Rows) = 2) and (Rows[0] = 0) and (Rows[1] = 1), 'marker positions use filtered row indices');
    View.ConfigureSearch('third', False, False, True); Rows := View.MarkerRows;
    Check((Length(Rows) = 1) and (Rows[0] = 0), 'match filtering changes overview positions');
    View.SetScrollBarLevels([nllWarning]);
    Check(Length(View.MarkerRows) = 0, 'excluded levels leave no markers');
    View.ConfigureSearch('', False, False, False);
    View.SetLevels([Low(TNimbusLogLevel)..High(TNimbusLogLevel)]);
    View.SetScrollBarLevels([nllWarning, nllError, nllFatal]);
    Model.Clear;
    for I := 1 to 10000 do Model.AddLine('ERROR batch');
    Model.AddLine('WARN isolated'); Model.AddLine('CRITICAL isolated');
    View.Rebuild; Rows := View.MarkerRows;
    Check(Length(Rows) <= 514, 'large logs have bounded severity marker storage');
    Check((Rows[0] = 10000) and (Rows[High(Rows)] = 10001), 'dense errors preserve other severity levels');
    Model.MaxLines := 2; View.Rebuild; Rows := View.MarkerRows;
    Check((Length(Rows) = 2) and (Rows[0] = 0) and (Rows[1] = 1), 'retention rebuilds overview');
    Model.Clear; View.Rebuild;
    Check(Length(View.MarkerRows) = 0, 'clear removes overview');
    Check(not View.HandleAllocated, 'overview construction does not create handles');
  finally View.Free; Model.Free; end;
end;

procedure LongRowRenderChecks;
var LongModel, ShortModel: TNimbusLogModel; Options: TNimbusLogHighlightOptions;
  LongBitmap, ShortBitmap: Vcl.Graphics.TBitmap; Font: TFont; Canvas: INimbusRenderCanvas;
  Metrics: TNimbusLogMetrics; Indices: TArray<Integer>; Hits: TArray<TNimbusLogSearchHit>;
  Text: TStringBuilder; I, X, Y: Integer; Watch: TStopwatch;
begin
  LongModel := TNimbusLogModel.Create(nil); ShortModel := TNimbusLogModel.Create(nil);
  Options := TNimbusLogHighlightOptions.Create(nil); Font := TFont.Create;
  LongBitmap := Vcl.Graphics.TBitmap.Create; ShortBitmap := Vcl.Graphics.TBitmap.Create;
  Text := TStringBuilder.Create; Canvas := TNimbusRenderCanvas.Create;
  try
    for I := 1 to 20000 do Text.Append('value=(123);' + #9);
    LongModel.AddLine(Text.ToString);
    ShortModel.AddLine(Copy(LongModel[0].Text, 1, 2048));
    Indices := TArray<Integer>.Create(0); Hits := nil;
    LongBitmap.SetSize(640, 40); ShortBitmap.SetSize(640, 40);
    Font.Name := 'Consolas'; Font.Size := 9;
    Canvas.BeginRender(LongBitmap.Canvas);
    try
      Metrics := TThemedLogViewerRenderer.Measure(Canvas, Font, Rect(0, 0, 640, 40), 96, False, True, 1);
      Watch := TStopwatch.StartNew;
      TThemedLogViewerRenderer.Render(Canvas, Font, nil, LongModel, Indices, Metrics, Options,
        0, 0, -1, -1, Hits, -1, True, nil, nil, nil);
      Watch.Stop;
      Writeln('Long source row render milliseconds: ' + IntToStr(Watch.ElapsedMilliseconds));
    finally Canvas.EndRender; end;
    Canvas.BeginRender(ShortBitmap.Canvas);
    try
      TThemedLogViewerRenderer.Render(Canvas, Font, nil, ShortModel, Indices, Metrics, Options,
        0, 0, -1, -1, Hits, -1, True, nil, nil, nil);
    finally Canvas.EndRender; end;
    for Y := 0 to 39 do
      for X := 0 to 639 do
        Check(LongBitmap.Canvas.Pixels[X, Y] = ShortBitmap.Canvas.Pixels[X, Y], 'long tokenized row matches clipped short reference');
    Canvas.BeginRender(LongBitmap.Canvas);
    try
      TThemedLogViewerRenderer.Render(Canvas, Font, nil, LongModel, Indices, Metrics, Options,
        0, 100000, -1, -1, Hits, -1, True, nil, nil, nil);
    finally Canvas.EndRender; end;
  finally
    Canvas := nil; Text.Free; LongBitmap.Free; ShortBitmap.Free; Font.Free;
    Options.Free; ShortModel.Free; LongModel.Free;
  end;
end;

procedure RendererChecks;
var Bitmap: Vcl.Graphics.TBitmap; Font: TFont; Canvas: INimbusRenderCanvas;
  Normal, Compact: TNimbusLogMetrics;
begin
  Bitmap := Vcl.Graphics.TBitmap.Create; Font := TFont.Create; Canvas := TNimbusRenderCanvas.Create;
  try
    Bitmap.SetSize(640, 240); Font.Name := 'Consolas'; Font.Size := 9;
    Canvas.BeginRender(Bitmap.Canvas);
    try
      Normal := TThemedLogViewerRenderer.Measure(Canvas, Font, Rect(0, 0, 640, 240), 96, False, True, 100);
      Compact := TThemedLogViewerRenderer.Measure(Canvas, Font, Rect(0, 0, 640, 240), 96, True, True, 100);
      Check(Compact.RowHeight < Normal.RowHeight, 'compact metrics');
      Check(TThemedLogViewerRenderer.RowAt(Point(100, Normal.RowHeight + 1), Normal, 3, 100) = 4, 'paint/hit row geometry');
      Check(TThemedLogViewerRenderer.ColumnX('a' + #9 + 'b', 2, Normal) > 4 * Normal.CharWidth, 'tab column geometry');
    finally Canvas.EndRender; end;
  finally Canvas := nil; Font.Free; Bitmap.Free; end;
end;

begin
  try
    Application.Initialize;
    LexerChecks; ModelChecks; SearchChecks; FileChecks; RendererChecks; QueueChecks; EncodingChecks; MarkerChecks; SourceFileChecks; LongRowRenderChecks;
    Writeln('LogViewer checks passed');
  except on E: Exception do begin Writeln(E.ClassName + ': ' + E.Message); ExitCode := 1; end; end;
end.

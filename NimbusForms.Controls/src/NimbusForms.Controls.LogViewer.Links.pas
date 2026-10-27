unit NimbusForms.Controls.LogViewer.Links;

interface

uses System.SysUtils, System.Generics.Collections;

type
  TNimbusLogInteractiveKind = (nlikNone, nlikURL, nlikFilePath, nlikSourceLocation);

  TNimbusLogSourceLocation = record
    FilePath: string;
    LineNumber: Integer;
    ColumnNumber: Integer;
    EndLineNumber: Integer;
    EndColumnNumber: Integer;
    function IsValid: Boolean;
  end;

  TNimbusLogInteractiveRun = class
  private
    FStart: Integer;
    FLength: Integer;
    FKind: TNimbusLogInteractiveKind;
    FText: string;
    FTarget: string;
    FFilePath: string;
    FLineNumber: Integer;
    FColumnNumber: Integer;
    FEndLineNumber: Integer;
    FEndColumnNumber: Integer;
  public
    function ContainsColumn(const AColumn: Integer): Boolean;
    function SourceLocation: TNimbusLogSourceLocation;
    property Start: Integer read FStart write FStart;
    property Length: Integer read FLength write FLength;
    property Kind: TNimbusLogInteractiveKind read FKind write FKind;
    property Text: string read FText write FText;
    property Target: string read FTarget write FTarget;
    property FilePath: string read FFilePath write FFilePath;
    property LineNumber: Integer read FLineNumber write FLineNumber;
    property ColumnNumber: Integer read FColumnNumber write FColumnNumber;
    property EndLineNumber: Integer read FEndLineNumber write FEndLineNumber;
    property EndColumnNumber: Integer read FEndColumnNumber write FEndColumnNumber;
  end;

  TNimbusLogInteractiveRuns = TObjectList<TNimbusLogInteractiveRun>;

  TNimbusLogInteractiveRunDetector = class
  private
    class function IsOverlapping(const ARuns: TNimbusLogInteractiveRuns; const AStart, ALength: Integer): Boolean; static;
    class function PositiveInt(const AValue: string): Integer; static;
    class procedure AddSourceMatches(const AText, APattern: string; const ARuns: TNimbusLogInteractiveRuns;
      const APathGroup, ALineGroup, AColumnGroup, AEndLineGroup, AEndColumnGroup: string); static;
    class procedure AddURLs(const AText: string; const ARuns: TNimbusLogInteractiveRuns); static;
    class procedure AddFilePaths(const AText: string; const ARuns: TNimbusLogInteractiveRuns); static;
  public
    class function Detect(const AText: string): TNimbusLogInteractiveRuns; static;
    class function HitTest(const ARuns: TNimbusLogInteractiveRuns; const AColumn: Integer): TNimbusLogInteractiveRun; static;
  end;

implementation

uses System.RegularExpressions, System.Generics.Defaults;

function TNimbusLogSourceLocation.IsValid: Boolean;
begin
  Result := (FilePath <> '') and (LineNumber > 0);
end;

function TNimbusLogInteractiveRun.ContainsColumn(const AColumn: Integer): Boolean;
begin
  Result := (AColumn >= FStart) and (AColumn < FStart + FLength);
end;

function TNimbusLogInteractiveRun.SourceLocation: TNimbusLogSourceLocation;
begin
  Result := Default(TNimbusLogSourceLocation);
  Result.FilePath := FFilePath;
  Result.LineNumber := FLineNumber;
  Result.ColumnNumber := FColumnNumber;
  Result.EndLineNumber := FEndLineNumber;
  Result.EndColumnNumber := FEndColumnNumber;
end;

class function TNimbusLogInteractiveRunDetector.PositiveInt(const AValue: string): Integer;
begin
  if not TryStrToInt(AValue, Result) or (Result < 1) then Result := 0;
end;

class function TNimbusLogInteractiveRunDetector.IsOverlapping(const ARuns: TNimbusLogInteractiveRuns;
  const AStart, ALength: Integer): Boolean;
var Run: TNimbusLogInteractiveRun; AEnd: Integer;
begin
  Result := False;
  AEnd := AStart + ALength;
  for Run in ARuns do
    if (AStart < Run.Start + Run.Length) and (AEnd > Run.Start) then Exit(True);
end;

class procedure TNimbusLogInteractiveRunDetector.AddSourceMatches(const AText, APattern: string;
  const ARuns: TNimbusLogInteractiveRuns; const APathGroup, ALineGroup, AColumnGroup,
  AEndLineGroup, AEndColumnGroup: string);
var Matches: TMatchCollection; Match: TMatch; Run: TNimbusLogInteractiveRun; G: TGroup;
begin
  Matches := TRegEx.Matches(AText, APattern, [roIgnoreCase]);
  for Match in Matches do
  begin
    if IsOverlapping(ARuns, Match.Index, Match.Length) then Continue;
    G := Match.Groups[APathGroup];
    if not G.Success then Continue;
    Run := TNimbusLogInteractiveRun.Create;
    Run.Start := Match.Index;
    Run.Length := Match.Length;
    Run.Kind := nlikSourceLocation;
    Run.Text := Match.Value;
    Run.Target := G.Value;
    Run.FilePath := G.Value.Trim(['"', #39]);
    G := Match.Groups[ALineGroup]; if G.Success then Run.LineNumber := PositiveInt(G.Value);
    if AColumnGroup <> '' then begin G := Match.Groups[AColumnGroup]; if G.Success then Run.ColumnNumber := PositiveInt(G.Value); end;
    if AEndLineGroup <> '' then begin G := Match.Groups[AEndLineGroup]; if G.Success then Run.EndLineNumber := PositiveInt(G.Value); end;
    if AEndColumnGroup <> '' then begin G := Match.Groups[AEndColumnGroup]; if G.Success then Run.EndColumnNumber := PositiveInt(G.Value); end;
    if Run.EndLineNumber = 0 then Run.EndLineNumber := Run.LineNumber;
    if Run.EndColumnNumber = 0 then Run.EndColumnNumber := Run.ColumnNumber;
    ARuns.Add(Run);
  end;
end;

class procedure TNimbusLogInteractiveRunDetector.AddURLs(const AText: string; const ARuns: TNimbusLogInteractiveRuns);
var Matches: TMatchCollection; Match: TMatch; Run: TNimbusLogInteractiveRun; Value: string; L: Integer;
begin
  Matches := TRegEx.Matches(AText, 'https?://[^\s<>"'']+', [roIgnoreCase]);
  for Match in Matches do
  begin
    Value := Match.Value;
    L := Length(Value);
    while (L > 0) and CharInSet(Value[L], ['.', ',', ';', ':', ')', ']', '}']) do Dec(L);
    if (L = 0) or IsOverlapping(ARuns, Match.Index, L) then Continue;
    Run := TNimbusLogInteractiveRun.Create;
    Run.Start := Match.Index;
    Run.Length := L;
    Run.Kind := nlikURL;
    Run.Text := Copy(Value, 1, L);
    Run.Target := Run.Text;
    ARuns.Add(Run);
  end;
end;

class procedure TNimbusLogInteractiveRunDetector.AddFilePaths(const AText: string; const ARuns: TNimbusLogInteractiveRuns);
var Matches: TMatchCollection; Match: TMatch; Run: TNimbusLogInteractiveRun;
begin
  Matches := TRegEx.Matches(AText, '(?:(?:[A-Za-z]:[\\/]|\\\\|/|\.\.?[\\/])(?:[^\r\n\t"<>|:*?]+[\\/])*(?:[^\r\n\t"<>|:*?]+\.[A-Za-z0-9_+-]{1,16})|(?:[A-Za-z0-9_.$ @#+''-]+[\\/])+(?:[A-Za-z0-9_.$ @#+''-]+\.[A-Za-z0-9_+-]{1,16}))', []);
  for Match in Matches do
  begin
    if IsOverlapping(ARuns, Match.Index, Match.Length) then Continue;
    Run := TNimbusLogInteractiveRun.Create;
    Run.Start := Match.Index;
    Run.Length := Match.Length;
    Run.Kind := nlikFilePath;
    Run.Text := Match.Value;
    Run.Target := Match.Value;
    Run.FilePath := Match.Value;
    ARuns.Add(Run);
  end;
end;

class function TNimbusLogInteractiveRunDetector.Detect(const AText: string): TNimbusLogInteractiveRuns;
begin
  Result := TNimbusLogInteractiveRuns.Create(True);
  if AText = '' then Exit;
  AddSourceMatches(AText,
    '(?<path>(?:(?:[A-Za-z]:[\\/]|\\\\|/|\.\.?[\\/])?(?:[A-Za-z0-9_.$ @#+''-]+[\\/])*[A-Za-z0-9_.$ @#+''-]+\.[A-Za-z0-9_+-]{1,16}))\((?<line>\d+)(?:\s*,\s*(?<column>\d+))?\)(?:\s*-\s*\((?<endline>\d+)(?:\s*,\s*(?<endcolumn>\d+))?\))?',
    Result, 'path', 'line', 'column', 'endline', 'endcolumn');
  AddSourceMatches(AText,
    '(?<path>(?:(?:[A-Za-z]:[\\/]|\\\\|/|\.\.?[\\/])?(?:[A-Za-z0-9_.$ @#+''-]+[\\/])*[A-Za-z0-9_.$ @#+''-]+\.[A-Za-z0-9_+-]{1,16})):(?<line>\d+)(?::(?<column>\d+))?(?:-(?<endline>\d+)(?::(?<endcolumn>\d+))?)?',
    Result, 'path', 'line', 'column', 'endline', 'endcolumn');
  AddSourceMatches(AText,
    '\bin\s+(?<path>(?:[A-Za-z]:[\\/]|\\\\|/).+?):(?:line|zeile)\s+(?<line>\d+)',
    Result, 'path', 'line', '', '', '');
  AddSourceMatches(AText,
    'File\s+["''](?<path>[^"'']+\.py)["'']\s*,\s*line\s+(?<line>\d+)',
    Result, 'path', 'line', '', '', '');
  AddSourceMatches(AText,
    '(?:-->|\bat\s+)\s*(?<path>(?:[A-Za-z]:[\\/]|\\\\|/|\.\.?[\\/])?[^\s():]+\.(?:rs|c|cc|cpp|cxx|h|hpp|java|kt|pas|dpr|cs|fs|vb|py|js|ts|tsx|jsx)):(?<line>\d+)(?::(?<column>\d+))?',
    Result, 'path', 'line', 'column', '', '');
  AddSourceMatches(AText,
    '\bat\s+[^\r\n()]+\((?<path>[^():]+\.(?:java|kt)):(?<line>\d+)\)',
    Result, 'path', 'line', '', '', '');
  AddURLs(AText, Result);
  AddFilePaths(AText, Result);
  Result.Sort(TComparer<TNimbusLogInteractiveRun>.Construct(
    function(const A, B: TNimbusLogInteractiveRun): Integer
    begin Result := A.Start - B.Start; end));
end;

class function TNimbusLogInteractiveRunDetector.HitTest(const ARuns: TNimbusLogInteractiveRuns;
  const AColumn: Integer): TNimbusLogInteractiveRun;
var Run: TNimbusLogInteractiveRun;
begin
  Result := nil;
  if ARuns = nil then Exit;
  for Run in ARuns do if Run.ContainsColumn(AColumn) then Exit(Run);
end;

end.

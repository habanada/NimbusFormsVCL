unit NimbusForms.Grid.SvgXml;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections;

type
  EThemedSvgError = class(Exception);

  TThemedSvgNode = class
  private
    FName: string;
    FText: string;
    FParent: TThemedSvgNode;
    FAttributes: TDictionary<string, string>;
    FChildren: TObjectList<TThemedSvgNode>;
  public
    constructor Create(const AName: string; const AParent: TThemedSvgNode);
    destructor Destroy; override;
    function TryGetAttribute(const AName: string; out AValue: string): Boolean;
    function GetAttribute(const AName: string; const ADefault: string = ''): string;
    function HasAttribute(const AName: string): Boolean;
    procedure SetAttribute(const AName, AValue: string);
    procedure AppendText(const AText: string);
    property Name: string read FName;
    property Text: string read FText;
    property Parent: TThemedSvgNode read FParent;
    property Attributes: TDictionary<string, string> read FAttributes;
    property Children: TObjectList<TThemedSvgNode> read FChildren;
  end;

  TThemedSvgXmlParser = class sealed
  private
    FText: string;
    FPos: Integer;
    function AtEnd: Boolean; inline;
    function StartsWith(const AValue: string): Boolean;
    procedure SkipWhiteSpace;
    function ReadName: string;
    function ReadAttributeValue: string;
    procedure SkipPast(const AMarker: string);
    procedure SkipDoctype;
    function StripPrefix(const AName: string): string;
    function NormalizeAttributeName(const AName: string): string;
    function ParseDocument: TThemedSvgNode;
    class function DecodeEntities(const AText: string): string; static;
  public
    class function Parse(const AText: string): TThemedSvgNode; static;
  end;

implementation

uses
  System.Character,
  NimbusForms.Grid.VisualStrings;

constructor TThemedSvgNode.Create(const AName: string; const AParent: TThemedSvgNode);
begin
  inherited Create;
  FName := AName;
  FParent := AParent;
  FAttributes := TDictionary<string, string>.Create;
  FChildren := TObjectList<TThemedSvgNode>.Create(True);
end;

destructor TThemedSvgNode.Destroy;
begin
  FChildren.Free;
  FAttributes.Free;
  inherited Destroy;
end;

function TThemedSvgNode.TryGetAttribute(const AName: string; out AValue: string): Boolean;
begin
  Result := FAttributes.TryGetValue(AName, AValue);
end;

function TThemedSvgNode.GetAttribute(const AName: string; const ADefault: string): string;
begin
  if not FAttributes.TryGetValue(AName, Result) then
    Result := ADefault;
end;

function TThemedSvgNode.HasAttribute(const AName: string): Boolean;
begin
  Result := FAttributes.ContainsKey(AName);
end;

procedure TThemedSvgNode.SetAttribute(const AName, AValue: string);
begin
  FAttributes.AddOrSetValue(AName, AValue);
end;

procedure TThemedSvgNode.AppendText(const AText: string);
begin
  FText := FText + AText;
end;

class function TThemedSvgXmlParser.Parse(const AText: string): TThemedSvgNode;
var
  LParser: TThemedSvgXmlParser;
begin
  if Trim(AText) = '' then
    raise EThemedSvgError.Create(ThemedGridVisualStrings.ErrSvgEmpty);
  LParser := TThemedSvgXmlParser.Create;
  try
    LParser.FText := AText;
    LParser.FPos := 1;
    Result := LParser.ParseDocument;
  finally
    LParser.Free;
  end;
end;

function TThemedSvgXmlParser.AtEnd: Boolean;
begin
  Result := FPos > Length(FText);
end;

function TThemedSvgXmlParser.StartsWith(const AValue: string): Boolean;
begin
  Result := (FPos + Length(AValue) - 1 <= Length(FText)) and
    (Copy(FText, FPos, Length(AValue)) = AValue);
end;

procedure TThemedSvgXmlParser.SkipWhiteSpace;
begin
  while (not AtEnd) and (FText[FPos] <= ' ') do
    Inc(FPos);
end;

function TThemedSvgXmlParser.ReadName: string;
var
  LStart: Integer;
begin
  LStart := FPos;
  while (not AtEnd) and not CharInSet(FText[FPos], [#0..' ', '=', '>', '/', '<', '"', '''']) do
    Inc(FPos);
  Result := Copy(FText, LStart, FPos - LStart);
end;

function TThemedSvgXmlParser.ReadAttributeValue: string;
var
  LQuote: Char;
  LStart: Integer;
begin
  Result := '';
  SkipWhiteSpace;
  if AtEnd then
    Exit;
  LQuote := FText[FPos];
  if (LQuote <> '"') and (LQuote <> '''') then
  begin
    LStart := FPos;
    while (not AtEnd) and not CharInSet(FText[FPos], [#0..' ', '>', '/']) do
      Inc(FPos);
    Exit(DecodeEntities(Copy(FText, LStart, FPos - LStart)));
  end;
  Inc(FPos);
  LStart := FPos;
  while (not AtEnd) and (FText[FPos] <> LQuote) do
    Inc(FPos);
  if AtEnd then
    raise EThemedSvgError.Create(ThemedGridVisualStrings.ErrSvgMalformed);
  Result := DecodeEntities(Copy(FText, LStart, FPos - LStart));
  Inc(FPos);
end;

procedure TThemedSvgXmlParser.SkipPast(const AMarker: string);
var
  LIndex: Integer;
begin
  LIndex := Pos(AMarker, FText, FPos);
  if LIndex = 0 then
    raise EThemedSvgError.Create(ThemedGridVisualStrings.ErrSvgMalformed);
  FPos := LIndex + Length(AMarker);
end;

procedure TThemedSvgXmlParser.SkipDoctype;
var
  LDepth: Integer;
begin
  LDepth := 0;
  while not AtEnd do
  begin
    case FText[FPos] of
      '[':
        Inc(LDepth);
      ']':
        Dec(LDepth);
      '>':
        if LDepth <= 0 then
        begin
          Inc(FPos);
          Exit;
        end;
    end;
    Inc(FPos);
  end;
  raise EThemedSvgError.Create(ThemedGridVisualStrings.ErrSvgMalformed);
end;

function TThemedSvgXmlParser.StripPrefix(const AName: string): string;
var
  LIndex: Integer;
begin
  LIndex := Pos(ThemedGridVisualStrings.SvgNamespaceSeparator, AName);
  if LIndex > 0 then
    Result := Copy(AName, LIndex + 1, MaxInt)
  else
    Result := AName;
end;

function TThemedSvgXmlParser.NormalizeAttributeName(const AName: string): string;
begin
  if AName.StartsWith(ThemedGridVisualStrings.SvgXlinkPrefix) then
    Result := ThemedGridVisualStrings.SvgHrefName
  else
    Result := AName;
end;

class function TThemedSvgXmlParser.DecodeEntities(const AText: string): string;
var
  LBuilder: TStringBuilder;
  I, LEnd, LCode: Integer;
  LEntity: string;
begin
  if Pos('&', AText) = 0 then
    Exit(AText);
  LBuilder := TStringBuilder.Create;
  try
    I := 1;
    while I <= Length(AText) do
    begin
      if AText[I] = '&' then
      begin
        LEnd := Pos(';', AText, I);
        if (LEnd > I) and (LEnd - I <= 10) then
        begin
          LEntity := Copy(AText, I + 1, LEnd - I - 1);
          if LEntity = 'amp' then
            LBuilder.Append('&')
          else if LEntity = 'lt' then
            LBuilder.Append('<')
          else if LEntity = 'gt' then
            LBuilder.Append('>')
          else if LEntity = 'quot' then
            LBuilder.Append('"')
          else if LEntity = 'apos' then
            LBuilder.Append('''')
          else if (Length(LEntity) > 1) and (LEntity[1] = '#') then
          begin
            if CharInSet(LEntity[2], ['x', 'X']) then
              LCode := StrToIntDef('$' + Copy(LEntity, 3, MaxInt), -1)
            else
              LCode := StrToIntDef(Copy(LEntity, 2, MaxInt), -1);
            if (LCode > 0) and (LCode < $110000) then
              LBuilder.Append(Char.ConvertFromUtf32(LCode));
          end
          else
            LBuilder.Append(Copy(AText, I, LEnd - I + 1));
          I := LEnd + 1;
          Continue;
        end;
      end;
      LBuilder.Append(AText[I]);
      Inc(I);
    end;
    Result := LBuilder.ToString;
  finally
    LBuilder.Free;
  end;
end;

function TThemedSvgXmlParser.ParseDocument: TThemedSvgNode;
var
  LRoot, LCurrent, LNode: TThemedSvgNode;
  LName, LAttrName, LTextValue: string;
  LSelfClosing: Boolean;
  LStart: Integer;
begin
  LRoot := nil;
  LCurrent := nil;
  try
    while not AtEnd do
    begin
      if FText[FPos] <> '<' then
      begin
        LStart := FPos;
        while (not AtEnd) and (FText[FPos] <> '<') do
          Inc(FPos);
        if LCurrent <> nil then
        begin
          LTextValue := Copy(FText, LStart, FPos - LStart);
          LCurrent.AppendText(DecodeEntities(LTextValue));
        end;
        Continue;
      end;
      if StartsWith('<!--') then
      begin
        SkipPast('-->');
        Continue;
      end;
      if StartsWith('<![CDATA[') then
      begin
        LStart := FPos + 9;
        SkipPast(']]>');
        if LCurrent <> nil then
          LCurrent.AppendText(Copy(FText, LStart, FPos - 3 - LStart));
        Continue;
      end;
      if StartsWith('<?') then
      begin
        SkipPast('?>');
        Continue;
      end;
      if StartsWith('<!') then
      begin
        Inc(FPos, 2);
        SkipDoctype;
        Continue;
      end;
      if StartsWith('</') then
      begin
        SkipPast('>');
        if LCurrent <> nil then
          LCurrent := LCurrent.Parent;
        if (LCurrent = nil) and (LRoot <> nil) then
          Break;
        Continue;
      end;
      Inc(FPos);
      LName := StripPrefix(ReadName);
      if LName = '' then
        raise EThemedSvgError.Create(ThemedGridVisualStrings.ErrSvgMalformed);
      if LCurrent = nil then
      begin
        if LRoot <> nil then
          Break;
        LNode := TThemedSvgNode.Create(LName, nil);
        LRoot := LNode;
      end
      else
      begin
        LNode := TThemedSvgNode.Create(LName, LCurrent);
        LCurrent.Children.Add(LNode);
      end;
      LSelfClosing := False;
      while True do
      begin
        SkipWhiteSpace;
        if AtEnd then
          raise EThemedSvgError.Create(ThemedGridVisualStrings.ErrSvgMalformed);
        if FText[FPos] = '>' then
        begin
          Inc(FPos);
          Break;
        end;
        if StartsWith('/>') then
        begin
          Inc(FPos, 2);
          LSelfClosing := True;
          Break;
        end;
        LAttrName := ReadName;
        if LAttrName = '' then
          raise EThemedSvgError.Create(ThemedGridVisualStrings.ErrSvgMalformed);
        SkipWhiteSpace;
        if (not AtEnd) and (FText[FPos] = '=') then
        begin
          Inc(FPos);
          LNode.SetAttribute(NormalizeAttributeName(LAttrName), ReadAttributeValue);
        end
        else
          LNode.SetAttribute(NormalizeAttributeName(LAttrName), '');
      end;
      if not LSelfClosing then
        LCurrent := LNode
      else if LCurrent = nil then
        Break;
    end;
    if LRoot = nil then
      raise EThemedSvgError.Create(ThemedGridVisualStrings.ErrSvgNoRoot);
    Result := LRoot;
  except
    LRoot.Free;
    raise;
  end;
end;

end.

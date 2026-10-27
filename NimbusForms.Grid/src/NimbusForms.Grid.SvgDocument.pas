unit NimbusForms.Grid.SvgDocument;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  NimbusForms.Grid.SvgXml;

type
  TThemedSvgCssRule = class
  private
    FTag: string;
    FCssClass: string;
    FId: string;
    FSpecificity: Integer;
    FDeclarations: TDictionary<string, string>;
  public
    constructor Create(const ATag, ACssClass, AId: string; const ADeclarations: TDictionary<string, string>);
    destructor Destroy; override;
    function Matches(const ANode: TThemedSvgNode): Boolean;
    property Specificity: Integer read FSpecificity;
    property Declarations: TDictionary<string, string> read FDeclarations;
  end;

  TThemedSvgDocument = class
  private
    FRoot: TThemedSvgNode;
    FIds: TDictionary<string, TThemedSvgNode>;
    FRules: TObjectList<TThemedSvgCssRule>;
    FStyleCache: TObjectDictionary<TThemedSvgNode, TDictionary<string, string>>;
    FViewBoxX: Double;
    FViewBoxY: Double;
    FViewBoxWidth: Double;
    FViewBoxHeight: Double;
    FHasViewBox: Boolean;
    FWidth: Double;
    FHeight: Double;
    constructor Create(const ARoot: TThemedSvgNode);
    procedure IndexNode(const ANode: TThemedSvgNode);
    procedure ParseStyleSheet(const AText: string);
    procedure AddRule(const ASelector: string; const ADeclarations: string);
    procedure ReadGeometry;
    function GetInlineStyle(const ANode: TThemedSvgNode): TDictionary<string, string>;
  public
    class function FromText(const AText: string): TThemedSvgDocument; static;
    class function FromFile(const AFileName: string): TThemedSvgDocument; static;
    destructor Destroy; override;
    function FindById(const AId: string): TThemedSvgNode;
    function TryGetProperty(const ANode: TThemedSvgNode; const AName: string; out AValue: string): Boolean;
    property Root: TThemedSvgNode read FRoot;
    property HasViewBox: Boolean read FHasViewBox;
    property ViewBoxX: Double read FViewBoxX;
    property ViewBoxY: Double read FViewBoxY;
    property ViewBoxWidth: Double read FViewBoxWidth;
    property ViewBoxHeight: Double read FViewBoxHeight;
    property Width: Double read FWidth;
    property Height: Double read FHeight;
  end;

implementation

uses
  System.IOUtils,
  NimbusForms.Grid.SvgValues,
  NimbusForms.Grid.VisualStrings;

const
  CDefaultIconSize = 24;

constructor TThemedSvgCssRule.Create(const ATag, ACssClass, AId: string;
  const ADeclarations: TDictionary<string, string>);
begin
  inherited Create;
  FTag := ATag;
  FCssClass := ACssClass;
  FId := AId;
  FDeclarations := ADeclarations;
  FSpecificity := 0;
  if FTag <> '' then
    Inc(FSpecificity, 1);
  if FCssClass <> '' then
    Inc(FSpecificity, 10);
  if FId <> '' then
    Inc(FSpecificity, 100);
end;

destructor TThemedSvgCssRule.Destroy;
begin
  FDeclarations.Free;
  inherited Destroy;
end;

function TThemedSvgCssRule.Matches(const ANode: TThemedSvgNode): Boolean;
var
  LClasses: TArray<string>;
  LClass, LValue: string;
  LFound: Boolean;
begin
  if ANode = nil then
    Exit(False);
  if (FTag <> '') and (FTag <> ANode.Name) then
    Exit(False);
  if (FId <> '') and (ANode.GetAttribute('id') <> FId) then
    Exit(False);
  if FCssClass <> '' then
  begin
    LValue := ANode.GetAttribute('class');
    LClasses := LValue.Split([' '], TStringSplitOptions.ExcludeEmpty);
    LFound := False;
    for LClass in LClasses do
      if LClass = FCssClass then
      begin
        LFound := True;
        Break;
      end;
    if not LFound then
      Exit(False);
  end;
  Result := True;
end;

constructor TThemedSvgDocument.Create(const ARoot: TThemedSvgNode);
begin
  inherited Create;
  FRoot := ARoot;
  FIds := TDictionary<string, TThemedSvgNode>.Create;
  FRules := TObjectList<TThemedSvgCssRule>.Create(True);
  FStyleCache := TObjectDictionary<TThemedSvgNode, TDictionary<string, string>>.Create([doOwnsValues]);
  IndexNode(FRoot);
  ReadGeometry;
end;

destructor TThemedSvgDocument.Destroy;
begin
  FStyleCache.Free;
  FRules.Free;
  FIds.Free;
  FRoot.Free;
  inherited Destroy;
end;

class function TThemedSvgDocument.FromText(const AText: string): TThemedSvgDocument;
var
  LRoot: TThemedSvgNode;
begin
  LRoot := TThemedSvgXmlParser.Parse(AText);
  if LRoot.Name <> ThemedGridVisualStrings.SvgRootName then
  begin
    LRoot.Free;
    raise EThemedSvgError.Create(ThemedGridVisualStrings.ErrSvgNotSvg);
  end;
  Result := TThemedSvgDocument.Create(LRoot);
end;

class function TThemedSvgDocument.FromFile(const AFileName: string): TThemedSvgDocument;
begin
  if not TFile.Exists(AFileName) then
    raise EThemedSvgError.CreateFmt(ThemedGridVisualStrings.ErrSvgFileNotFound, [AFileName]);
  Result := FromText(TFile.ReadAllText(AFileName, TEncoding.UTF8));
end;

procedure TThemedSvgDocument.IndexNode(const ANode: TThemedSvgNode);
var
  LId: string;
  LChild: TThemedSvgNode;
begin
  if ANode.TryGetAttribute('id', LId) and (LId <> '') then
    FIds.AddOrSetValue(LId, ANode);
  if ANode.Name = 'style' then
    ParseStyleSheet(ANode.Text);
  for LChild in ANode.Children do
    IndexNode(LChild);
end;

procedure TThemedSvgDocument.ParseStyleSheet(const AText: string);
var
  LText: string;
  LStart, LEnd, LOpen, LClose, LDepth: Integer;
  LSelector, LBody: string;
begin
  LText := AText;
  LStart := Pos('/*', LText);
  while LStart > 0 do
  begin
    LEnd := Pos('*/', LText, LStart + 2);
    if LEnd = 0 then
    begin
      LText := Copy(LText, 1, LStart - 1);
      Break;
    end;
    Delete(LText, LStart, LEnd + 2 - LStart);
    LStart := Pos('/*', LText);
  end;
  LStart := 1;
  while LStart <= Length(LText) do
  begin
    LOpen := Pos('{', LText, LStart);
    if LOpen = 0 then
      Break;
    LSelector := Trim(Copy(LText, LStart, LOpen - LStart));
    LDepth := 1;
    LClose := LOpen + 1;
    while (LClose <= Length(LText)) and (LDepth > 0) do
    begin
      if LText[LClose] = '{' then
        Inc(LDepth)
      else if LText[LClose] = '}' then
        Dec(LDepth);
      Inc(LClose);
    end;
    LBody := Copy(LText, LOpen + 1, LClose - LOpen - 2);
    LStart := LClose;
    if (LSelector = '') or (LSelector[1] = '@') then
      Continue;
    AddRule(LSelector, LBody);
  end;
end;

procedure TThemedSvgDocument.AddRule(const ASelector: string; const ADeclarations: string);
var
  LSelectors: TArray<string>;
  LSelector, LTag, LClass, LId, LRest: string;
  LIndex: Integer;
  LDeclarations: TDictionary<string, string>;
  LCopy: TDictionary<string, string>;
  LPair: TPair<string, string>;
begin
  LDeclarations := TThemedSvgValues.ParseDeclarations(ADeclarations);
  try
    LSelectors := ASelector.Split([',']);
    for LSelector in LSelectors do
    begin
      LRest := Trim(LSelector);
      if (LRest = '') or (LRest.IndexOfAny([' ', '>', '+', '~', ':', '[']) >= 0) then
        Continue;
      LTag := '';
      LClass := '';
      LId := '';
      LIndex := LRest.IndexOfAny(['.', '#']);
      if LIndex < 0 then
        LTag := LRest
      else
      begin
        LTag := Copy(LRest, 1, LIndex);
        LRest := Copy(LRest, LIndex + 1, MaxInt);
        if LRest[1] = '.' then
        begin
          LRest := Copy(LRest, 2, MaxInt);
          LIndex := LRest.IndexOf('#');
          if LIndex >= 0 then
          begin
            LClass := Copy(LRest, 1, LIndex);
            LId := Copy(LRest, LIndex + 2, MaxInt);
          end
          else
            LClass := LRest;
        end
        else
        begin
          LRest := Copy(LRest, 2, MaxInt);
          LIndex := LRest.IndexOf('.');
          if LIndex >= 0 then
          begin
            LId := Copy(LRest, 1, LIndex);
            LClass := Copy(LRest, LIndex + 2, MaxInt);
          end
          else
            LId := LRest;
        end;
      end;
      if LTag = '*' then
        LTag := '';
      LCopy := TDictionary<string, string>.Create;
      for LPair in LDeclarations do
        LCopy.AddOrSetValue(LPair.Key, LPair.Value);
      FRules.Add(TThemedSvgCssRule.Create(LTag, LClass, LId, LCopy));
    end;
  finally
    LDeclarations.Free;
  end;
end;

procedure TThemedSvgDocument.ReadGeometry;
var
  LParts: TArray<Double>;
  LValue: string;
begin
  FHasViewBox := False;
  if FRoot.TryGetAttribute('viewBox', LValue) then
  begin
    LParts := TThemedSvgValues.SplitNumbers(LValue);
    if (Length(LParts) = 4) and (LParts[2] > 0) and (LParts[3] > 0) then
    begin
      FHasViewBox := True;
      FViewBoxX := LParts[0];
      FViewBoxY := LParts[1];
      FViewBoxWidth := LParts[2];
      FViewBoxHeight := LParts[3];
    end;
  end;
  FWidth := 0;
  FHeight := 0;
  if FRoot.TryGetAttribute('width', LValue) and not LValue.EndsWith('%') then
    FWidth := TThemedSvgValues.ParseLength(LValue, 0, 0);
  if FRoot.TryGetAttribute('height', LValue) and not LValue.EndsWith('%') then
    FHeight := TThemedSvgValues.ParseLength(LValue, 0, 0);
  if FWidth <= 0 then
  begin
    if FHasViewBox then
      FWidth := FViewBoxWidth
    else
      FWidth := CDefaultIconSize;
  end;
  if FHeight <= 0 then
  begin
    if FHasViewBox then
      FHeight := FViewBoxHeight
    else
      FHeight := CDefaultIconSize;
  end;
end;

function TThemedSvgDocument.FindById(const AId: string): TThemedSvgNode;
begin
  if not FIds.TryGetValue(AId, Result) then
    Result := nil;
end;

function TThemedSvgDocument.GetInlineStyle(const ANode: TThemedSvgNode): TDictionary<string, string>;
var
  LStyle: string;
begin
  if FStyleCache.TryGetValue(ANode, Result) then
    Exit;
  if ANode.TryGetAttribute('style', LStyle) then
    Result := TThemedSvgValues.ParseDeclarations(LStyle)
  else
    Result := TDictionary<string, string>.Create;
  FStyleCache.Add(ANode, Result);
end;

function TThemedSvgDocument.TryGetProperty(const ANode: TThemedSvgNode; const AName: string;
  out AValue: string): Boolean;
var
  LStyle: TDictionary<string, string>;
  LRule: TThemedSvgCssRule;
  LBestSpecificity: Integer;
  LRuleValue: string;
  LFound: Boolean;
begin
  AValue := '';
  if ANode = nil then
    Exit(False);
  LStyle := GetInlineStyle(ANode);
  if LStyle.TryGetValue(AName, AValue) then
    Exit(True);
  LBestSpecificity := -1;
  LFound := False;
  for LRule in FRules do
  begin
    if (LRule.Specificity >= LBestSpecificity) and LRule.Declarations.TryGetValue(AName, LRuleValue) and
      LRule.Matches(ANode) then
    begin
      AValue := LRuleValue;
      LBestSpecificity := LRule.Specificity;
      LFound := True;
    end;
  end;
  if LFound then
    Exit(True);
  Result := ANode.TryGetAttribute(AName, AValue);
end;

end.

unit NimbusForms.Grid.VisualImageRenderer;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  Winapi.ActiveX,
  System.SysUtils,
  System.Types,
  System.Classes,
  System.Math,
  System.Hash,
  System.IOUtils,
  System.Generics.Collections,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.ImgList,
  Vcl.VirtualImageList,
  Winapi.GDIPOBJ,
  Winapi.GDIPAPI,
  NimbusForms.Theming.Types,
  NimbusForms.Grid.SvgDocument,
  NimbusForms.Grid.SvgRenderer,
  NimbusForms.Grid.VisualImage;

type
  TThemedVisualImageRenderer = class
  private
    const
      MaxBitmaps = 512;
      DisabledOpacity = 0.45;
    var
      FDocuments: TObjectDictionary<string, TThemedSvgDocument>;
      FBitmaps: TObjectDictionary<string, TGPBitmap>;
      FUseBitmapCache: Boolean;
    function ResolveDocument(const AImage: TThemedVisualImage; out AKey: string): TThemedSvgDocument;
    function ResolveBitmap(const AImage: TThemedVisualImage; const AWidth, AHeight: Integer;
      const ACurrentColor: TThemeColor; const AImageList: TCustomImageList; out AOwned: Boolean): TGPBitmap;
    function CreateSvgBitmap(const AImage: TThemedVisualImage; const AWidth, AHeight: Integer;
      const ACurrentColor: TThemeColor): TGPBitmap;
    function CreateRasterBitmap(const AImage: TThemedVisualImage; const AImageList: TCustomImageList): TGPBitmap;
    function BuildCacheKey(const AImage: TThemedVisualImage; const AWidth, AHeight: Integer;
      const ACurrentColor: TThemeColor; const AImageList: TCustomImageList): string;
    class function BitmapToGdi(const ABitmap: Vcl.Graphics.TBitmap): TGPBitmap; static;
    class function Detach(const ASource: TGPBitmap): TGPBitmap; static;
    class function GraphicToGdi(const AGraphic: TGraphic): TGPBitmap; static;
    class function ImageListToGdi(const AImageList: TCustomImageList; const AKey: string): TGPBitmap; static;
    class function FitRect(const ABounds: TRect; const AWidth, AHeight: Integer): TRect; static;
    class procedure DrawBitmap(const AGraphics: TGPGraphics; const ABitmap: TGPBitmap; const ADestination: TRect;
      const AEnabled: Boolean); static;
  public
    constructor Create;
    destructor Destroy; override;
    procedure DrawImage(const AGraphics: TGPGraphics; const ABounds: TRect; const AImage: TThemedVisualImage;
      const ACurrentColor: TThemeColor; const AEnabled: Boolean; const AImageList: TCustomImageList);
    procedure ClearCache;
    procedure ClearBitmapCache;
    property UseBitmapCache: Boolean read FUseBitmapCache write FUseBitmapCache;
  end;

implementation

constructor TThemedVisualImageRenderer.Create;
begin
  inherited Create;
  FDocuments := TObjectDictionary<string, TThemedSvgDocument>.Create([doOwnsValues]);
  FBitmaps := TObjectDictionary<string, TGPBitmap>.Create([doOwnsValues]);
  FUseBitmapCache := True;
end;

destructor TThemedVisualImageRenderer.Destroy;
begin
  FBitmaps.Free;
  FDocuments.Free;
  inherited Destroy;
end;

procedure TThemedVisualImageRenderer.ClearCache;
begin
  FBitmaps.Clear;
  FDocuments.Clear;
end;

procedure TThemedVisualImageRenderer.ClearBitmapCache;
begin
  FBitmaps.Clear;
end;

class function TThemedVisualImageRenderer.FitRect(const ABounds: TRect; const AWidth, AHeight: Integer): TRect;
var
  LScale: Double;
  LWidth, LHeight: Integer;
begin
  if (AWidth <= 0) or (AHeight <= 0) then
    Exit(ABounds);
  LScale := Min(ABounds.Width / AWidth, ABounds.Height / AHeight);
  LWidth := Max(1, Round(AWidth * LScale));
  LHeight := Max(1, Round(AHeight * LScale));
  Result := Rect(ABounds.Left + (ABounds.Width - LWidth) div 2, ABounds.Top + (ABounds.Height - LHeight) div 2,
    ABounds.Left + (ABounds.Width - LWidth) div 2 + LWidth, ABounds.Top + (ABounds.Height - LHeight) div 2 + LHeight);
end;

class function TThemedVisualImageRenderer.Detach(const ASource: TGPBitmap): TGPBitmap;
var
  LGraphics: TGPGraphics;
begin
  Result := nil;
  if ASource = nil then
    Exit;
  if (ASource.GetWidth = 0) or (ASource.GetHeight = 0) then
    Exit;
  Result := TGPBitmap.Create(Integer(ASource.GetWidth), Integer(ASource.GetHeight), PixelFormat32bppPARGB);
  LGraphics := TGPGraphics.Create(Result);
  try
    LGraphics.SetCompositingMode(CompositingModeSourceCopy);
    LGraphics.DrawImage(ASource, 0, 0, Integer(ASource.GetWidth), Integer(ASource.GetHeight));
  finally
    LGraphics.Free;
  end;
end;

class function TThemedVisualImageRenderer.BitmapToGdi(const ABitmap: Vcl.Graphics.TBitmap): TGPBitmap;
var
  LCopy: Vcl.Graphics.TBitmap;
  LData: TBitmapData;
  LFormat: TPixelFormat;
  Y: Integer;
begin
  Result := nil;
  if (ABitmap = nil) or ABitmap.Empty or (ABitmap.Width <= 0) or (ABitmap.Height <= 0) then
    Exit;
  LCopy := Vcl.Graphics.TBitmap.Create;
  try
    LCopy.Assign(ABitmap);
    if (LCopy.PixelFormat = pf32bit) and (LCopy.AlphaFormat = afDefined) then
      LFormat := PixelFormat32bppPARGB
    else
    begin
      LCopy.AlphaFormat := afIgnored;
      LCopy.PixelFormat := pf32bit;
      LFormat := PixelFormat32bppRGB;
    end;
    Result := TGPBitmap.Create(LCopy.Width, LCopy.Height, LFormat);
    if Result.LockBits(MakeRect(0, 0, LCopy.Width, LCopy.Height), ImageLockModeWrite, LFormat, LData) <> Ok then
    begin
      FreeAndNil(Result);
      Exit;
    end;
    try
      for Y := 0 to LCopy.Height - 1 do
        Move(LCopy.ScanLine[Y]^, PByte(LData.Scan0)[Y * LData.Stride], LCopy.Width * 4);
    finally
      Result.UnlockBits(LData);
    end;
  finally
    LCopy.Free;
  end;
end;

class function TThemedVisualImageRenderer.GraphicToGdi(const AGraphic: TGraphic): TGPBitmap;
var
  LStream: TMemoryStream;
  LAdapter: IStream;
  LSource: TGPBitmap;
begin
  Result := nil;
  if (AGraphic = nil) or AGraphic.Empty then
    Exit;
  if AGraphic is Vcl.Graphics.TBitmap then
    Exit(BitmapToGdi(Vcl.Graphics.TBitmap(AGraphic)));
  LStream := TMemoryStream.Create;
  try
    AGraphic.SaveToStream(LStream);
    LStream.Position := 0;
    LAdapter := TStreamAdapter.Create(LStream, soReference);
    LSource := TGPBitmap.Create(LAdapter);
    try
      Result := Detach(LSource);
    finally
      LSource.Free;
    end;
  finally
    LStream.Free;
  end;
end;

class function TThemedVisualImageRenderer.ImageListToGdi(const AImageList: TCustomImageList;
  const AKey: string): TGPBitmap;
var
  LIndex: Integer;
  LBitmap: Vcl.Graphics.TBitmap;
begin
  Result := nil;
  if AImageList = nil then
    Exit;
  LIndex := StrToIntDef(AKey, -1);
  if (LIndex < 0) and (AImageList is TVirtualImageList) then
    LIndex := TVirtualImageList(AImageList).GetIndexByName(AKey);
  if (LIndex < 0) or (LIndex >= AImageList.Count) then
    Exit;
  LBitmap := Vcl.Graphics.TBitmap.Create;
  try
    LBitmap.PixelFormat := pf32bit;
    LBitmap.AlphaFormat := afDefined;
    AImageList.GetBitmap(LIndex, LBitmap);
    Result := BitmapToGdi(LBitmap);
  finally
    LBitmap.Free;
  end;
end;

function TThemedVisualImageRenderer.ResolveDocument(const AImage: TThemedVisualImage;
  out AKey: string): TThemedSvgDocument;
var
  LStamp: string;
begin
  Result := nil;
  AKey := '';
  case AImage.Kind of
    TThemedVisualImageKind.SvgFile:
      begin
        if TFile.Exists(AImage.Source) then
          LStamp := IntToStr(Round(TFile.GetLastWriteTimeUtc(AImage.Source) * 86400000))
        else
          LStamp := '0';
        AKey := 'f|' + AImage.Source + '|' + LStamp;
      end;
    TThemedVisualImageKind.SvgText:
      AKey := 't|' + IntToHex(THashBobJenkins.GetHashValue(AImage.Source), 8) + '|' + IntToStr(Length(AImage.Source));
  else
    Exit;
  end;
  if FDocuments.TryGetValue(AKey, Result) then
    Exit;
  try
    if AImage.Kind = TThemedVisualImageKind.SvgFile then
      Result := TThemedSvgDocument.FromFile(AImage.Source)
    else
      Result := TThemedSvgDocument.FromText(AImage.Source);
  except
    Result := nil;
  end;
  FDocuments.Add(AKey, Result);
end;

function TThemedVisualImageRenderer.BuildCacheKey(const AImage: TThemedVisualImage; const AWidth, AHeight: Integer;
  const ACurrentColor: TThemeColor; const AImageList: TCustomImageList): string;
var
  LDocumentKey: string;
begin
  case AImage.Kind of
    TThemedVisualImageKind.SvgFile, TThemedVisualImageKind.SvgText:
      begin
        ResolveDocument(AImage, LDocumentKey);
        Result := LDocumentKey + '|' + IntToStr(AWidth) + 'x' + IntToStr(AHeight) + '|' + IntToHex(Cardinal(ACurrentColor), 8);
      end;
    TThemedVisualImageKind.ImageFile:
      begin
        if TFile.Exists(AImage.Source) then
          Result := 'i|' + AImage.Source + '|' + IntToStr(Round(TFile.GetLastWriteTimeUtc(AImage.Source) * 86400000))
        else
          Result := 'i|' + AImage.Source + '|0';
      end;
    TThemedVisualImageKind.Graphic:
      Result := 'g|' + AImage.Key + '|' + IntToHex(NativeUInt(AImage.Graphic), 16);
    TThemedVisualImageKind.ImageListKey:
      Result := 'l|' + IntToHex(NativeUInt(AImageList), 16) + '|' + AImage.Source;
  else
    Result := '';
  end;
end;

function TThemedVisualImageRenderer.CreateSvgBitmap(const AImage: TThemedVisualImage; const AWidth, AHeight: Integer;
  const ACurrentColor: TThemeColor): TGPBitmap;
var
  LKey: string;
  LDocument: TThemedSvgDocument;
begin
  LDocument := ResolveDocument(AImage, LKey);
  if LDocument = nil then
    Exit(nil);
  Result := TThemedSvgRenderer.RenderToBitmap(LDocument, AWidth, AHeight, ACurrentColor);
end;

function TThemedVisualImageRenderer.CreateRasterBitmap(const AImage: TThemedVisualImage;
  const AImageList: TCustomImageList): TGPBitmap;
var
  LSource: TGPBitmap;
begin
  Result := nil;
  case AImage.Kind of
    TThemedVisualImageKind.ImageFile:
      if TFile.Exists(AImage.Source) then
      begin
        LSource := TGPBitmap.Create(AImage.Source);
        try
          Result := Detach(LSource);
        finally
          LSource.Free;
        end;
      end;
    TThemedVisualImageKind.Graphic:
      Result := GraphicToGdi(AImage.Graphic);
    TThemedVisualImageKind.ImageListKey:
      Result := ImageListToGdi(AImageList, AImage.Source);
  end;
end;

function TThemedVisualImageRenderer.ResolveBitmap(const AImage: TThemedVisualImage; const AWidth, AHeight: Integer;
  const ACurrentColor: TThemeColor; const AImageList: TCustomImageList; out AOwned: Boolean): TGPBitmap;
var
  LKey: string;
  LIsSvg: Boolean;
begin
  AOwned := False;
  Result := nil;
  LKey := '';
  LIsSvg := AImage.Kind in [TThemedVisualImageKind.SvgFile, TThemedVisualImageKind.SvgText];
  if FUseBitmapCache then
  begin
    LKey := BuildCacheKey(AImage, AWidth, AHeight, ACurrentColor, AImageList);
    if (LKey <> '') and FBitmaps.TryGetValue(LKey, Result) then
      Exit;
  end;
  if LIsSvg then
    Result := CreateSvgBitmap(AImage, AWidth, AHeight, ACurrentColor)
  else
    Result := CreateRasterBitmap(AImage, AImageList);
  if Result = nil then
    Exit;
  if FUseBitmapCache and (LKey <> '') then
  begin
    if FBitmaps.Count >= MaxBitmaps then
      FBitmaps.Clear;
    FBitmaps.Add(LKey, Result);
  end
  else
    AOwned := True;
end;

class procedure TThemedVisualImageRenderer.DrawBitmap(const AGraphics: TGPGraphics; const ABitmap: TGPBitmap;
  const ADestination: TRect; const AEnabled: Boolean);
var
  LAttributes: TGPImageAttributes;
  LMatrix: TColorMatrix;
  I, J: Integer;
begin
  if AEnabled then
  begin
    AGraphics.DrawImage(ABitmap, ADestination.Left, ADestination.Top, ADestination.Width, ADestination.Height);
    Exit;
  end;
  for I := 0 to 4 do
    for J := 0 to 4 do
      if I = J then
        LMatrix[I, J] := 1
      else
        LMatrix[I, J] := 0;
  LMatrix[3, 3] := DisabledOpacity;
  LAttributes := TGPImageAttributes.Create;
  try
    LAttributes.SetColorMatrix(LMatrix);
    AGraphics.DrawImage(ABitmap, MakeRect(ADestination.Left, ADestination.Top, ADestination.Width, ADestination.Height),
      0, 0, Integer(ABitmap.GetWidth), Integer(ABitmap.GetHeight), UnitPixel, LAttributes);
  finally
    LAttributes.Free;
  end;
end;

procedure TThemedVisualImageRenderer.DrawImage(const AGraphics: TGPGraphics; const ABounds: TRect;
  const AImage: TThemedVisualImage; const ACurrentColor: TThemeColor; const AEnabled: Boolean;
  const AImageList: TCustomImageList);
var
  LColor: TThemeColor;
  LBitmap: TGPBitmap;
  LOwned: Boolean;
  LDestination: TRect;
begin
  if (AGraphics = nil) or (AImage = nil) or not AImage.HasImage then
    Exit;
  if (ABounds.Width <= 0) or (ABounds.Height <= 0) then
    Exit;
  if AImage.HasCurrentColor then
    LColor := AImage.CurrentColor
  else
    LColor := ACurrentColor;
  LBitmap := ResolveBitmap(AImage, ABounds.Width, ABounds.Height, LColor, AImageList, LOwned);
  if LBitmap = nil then
    Exit;
  try
    if AImage.Kind in [TThemedVisualImageKind.SvgFile, TThemedVisualImageKind.SvgText] then
      LDestination := ABounds
    else
      LDestination := FitRect(ABounds, Integer(LBitmap.GetWidth), Integer(LBitmap.GetHeight));
    DrawBitmap(AGraphics, LBitmap, LDestination, AEnabled);
  finally
    if LOwned then
      LBitmap.Free;
  end;
end;

end.

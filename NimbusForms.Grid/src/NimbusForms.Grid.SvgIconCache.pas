unit NimbusForms.Grid.SvgIconCache;

interface

uses
  System.SysUtils,
  System.Types,
  System.SyncObjs,
  System.Generics.Collections,
  Winapi.GDIPOBJ,
  NimbusForms.Theming.Types,
  NimbusForms.Grid.SvgDocument,
  NimbusForms.Grid.SvgRenderer;

type
  TThemedSvgIconCache = class
  private
    FLock: TCriticalSection;
    FDocuments: TObjectDictionary<string, TThemedSvgDocument>;
    FBitmaps: TObjectDictionary<string, TGPBitmap>;
    FOrder: TQueue<string>;
    FMaximumBitmapCacheEntries: Integer;
    FLastError: string;
    procedure SetMaximumBitmapCacheEntries(const AValue: Integer);
    procedure TrimBitmapCacheCore;
    function CreateBitmap(const ADocument: TThemedSvgDocument; const ASize: TSize;
      const ACurrentColor: TThemeColor; const AOptions: TThemedSvgRenderOptions): TGPBitmap;
    class function CreateBitmapKey(const AIconKey: string; const ASize: TSize; const ACurrentColor: TThemeColor;
      const ADpiScale: Single; const AOptions: TThemedSvgRenderOptions): string; static;
  public
    constructor Create;
    destructor Destroy; override;
    function GetDocumentFromFile(const AFileName: string): TThemedSvgDocument;
    function GetDocumentFromString(const AKey, ASvg: string): TThemedSvgDocument;
    function GetBitmap(const AIconKey: string; const ADocument: TThemedSvgDocument; const ASize: TSize;
      const ACurrentColor: TThemeColor; const ADpiScale: Single): TGPBitmap; overload;
    function GetBitmap(const AIconKey: string; const ADocument: TThemedSvgDocument; const ASize: TSize;
      const ACurrentColor: TThemeColor; const ADpiScale: Single;
      const AOptions: TThemedSvgRenderOptions): TGPBitmap; overload;
    procedure ClearBitmaps;
    procedure ClearDocuments;
    procedure Clear;
    property MaximumBitmapCacheEntries: Integer read FMaximumBitmapCacheEntries write SetMaximumBitmapCacheEntries;
    property LastError: string read FLastError;
  end;

implementation

uses
  NimbusForms.Grid.VisualStrings;

const
  CMinimumBitmapCacheEntries = 16;
  CDefaultBitmapCacheEntries = 512;

constructor TThemedSvgIconCache.Create;
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FDocuments := TObjectDictionary<string, TThemedSvgDocument>.Create([doOwnsValues]);
  FBitmaps := TObjectDictionary<string, TGPBitmap>.Create([doOwnsValues]);
  FOrder := TQueue<string>.Create;
  FMaximumBitmapCacheEntries := CDefaultBitmapCacheEntries;
end;

destructor TThemedSvgIconCache.Destroy;
begin
  Clear;
  FOrder.Free;
  FBitmaps.Free;
  FDocuments.Free;
  FLock.Free;
  inherited Destroy;
end;

procedure TThemedSvgIconCache.SetMaximumBitmapCacheEntries(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < CMinimumBitmapCacheEntries then
    LValue := CMinimumBitmapCacheEntries;
  FLock.Enter;
  try
    if FMaximumBitmapCacheEntries = LValue then
      Exit;
    FMaximumBitmapCacheEntries := LValue;
    TrimBitmapCacheCore;
  finally
    FLock.Leave;
  end;
end;

procedure TThemedSvgIconCache.TrimBitmapCacheCore;
var
  LKey: string;
begin
  while (FBitmaps.Count > FMaximumBitmapCacheEntries) and (FOrder.Count > 0) do
  begin
    LKey := FOrder.Dequeue;
    FBitmaps.Remove(LKey);
  end;
end;

function TThemedSvgIconCache.GetDocumentFromFile(const AFileName: string): TThemedSvgDocument;
var
  LKey: string;
  LCreated: TThemedSvgDocument;
begin
  FLastError := '';
  Result := nil;
  if AFileName = '' then
  begin
    FLastError := ThemedGridVisualStrings.ErrIconFileNameEmpty;
    Exit;
  end;
  LKey := ThemedGridVisualStrings.IconCacheFilePrefix + ExpandFileName(AFileName);
  FLock.Enter;
  try
    if FDocuments.TryGetValue(LKey, Result) then
      Exit;
  finally
    FLock.Leave;
  end;
  if not FileExists(AFileName) then
  begin
    FLastError := Format(ThemedGridVisualStrings.ErrIconFileMissing, [AFileName]);
    Exit;
  end;
  try
    LCreated := TThemedSvgDocument.FromFile(AFileName);
  except
    on E: Exception do
    begin
      FLastError := E.ClassName + ': ' + E.Message;
      Exit;
    end;
  end;
  FLock.Enter;
  try
    if FDocuments.TryGetValue(LKey, Result) then
      LCreated.Free
    else
    begin
      FDocuments.Add(LKey, LCreated);
      Result := LCreated;
    end;
  finally
    FLock.Leave;
  end;
end;

function TThemedSvgIconCache.GetDocumentFromString(const AKey, ASvg: string): TThemedSvgDocument;
var
  LKey: string;
  LCreated: TThemedSvgDocument;
begin
  FLastError := '';
  Result := nil;
  if (AKey = '') or (Trim(ASvg) = '') then
  begin
    FLastError := ThemedGridVisualStrings.ErrIconKeyOrSvgEmpty;
    Exit;
  end;
  LKey := ThemedGridVisualStrings.IconCacheTextPrefix + AKey;
  FLock.Enter;
  try
    if FDocuments.TryGetValue(LKey, Result) then
      Exit;
  finally
    FLock.Leave;
  end;
  try
    LCreated := TThemedSvgDocument.FromText(ASvg);
  except
    on E: Exception do
    begin
      FLastError := E.ClassName + ': ' + E.Message;
      Exit;
    end;
  end;
  FLock.Enter;
  try
    if FDocuments.TryGetValue(LKey, Result) then
      LCreated.Free
    else
    begin
      FDocuments.Add(LKey, LCreated);
      Result := LCreated;
    end;
  finally
    FLock.Leave;
  end;
end;

function TThemedSvgIconCache.GetBitmap(const AIconKey: string; const ADocument: TThemedSvgDocument;
  const ASize: TSize; const ACurrentColor: TThemeColor; const ADpiScale: Single): TGPBitmap;
begin
  Result := GetBitmap(AIconKey, ADocument, ASize, ACurrentColor, ADpiScale, TThemedSvgRenderOptions.Standard);
end;

function TThemedSvgIconCache.GetBitmap(const AIconKey: string; const ADocument: TThemedSvgDocument;
  const ASize: TSize; const ACurrentColor: TThemeColor; const ADpiScale: Single;
  const AOptions: TThemedSvgRenderOptions): TGPBitmap;
var
  LKey: string;
  LCreated: TGPBitmap;
  LScale: Single;
begin
  Result := nil;
  if (ADocument = nil) or (ASize.cx <= 0) or (ASize.cy <= 0) then
    Exit;
  LScale := ADpiScale;
  if LScale <= 0 then
    LScale := 1;
  LKey := CreateBitmapKey(AIconKey, ASize, ACurrentColor, LScale, AOptions);
  FLock.Enter;
  try
    if FBitmaps.TryGetValue(LKey, Result) then
      Exit;
  finally
    FLock.Leave;
  end;
  LCreated := CreateBitmap(ADocument, ASize, ACurrentColor, AOptions);
  if LCreated = nil then
    Exit;
  FLock.Enter;
  try
    if FBitmaps.TryGetValue(LKey, Result) then
      LCreated.Free
    else
    begin
      FBitmaps.Add(LKey, LCreated);
      FOrder.Enqueue(LKey);
      Result := LCreated;
      TrimBitmapCacheCore;
    end;
  finally
    FLock.Leave;
  end;
end;

procedure TThemedSvgIconCache.ClearBitmaps;
begin
  FLock.Enter;
  try
    FBitmaps.Clear;
    FOrder.Clear;
  finally
    FLock.Leave;
  end;
end;

procedure TThemedSvgIconCache.ClearDocuments;
begin
  FLock.Enter;
  try
    FDocuments.Clear;
  finally
    FLock.Leave;
  end;
end;

procedure TThemedSvgIconCache.Clear;
begin
  FLastError := '';
  ClearBitmaps;
  ClearDocuments;
end;

function TThemedSvgIconCache.CreateBitmap(const ADocument: TThemedSvgDocument; const ASize: TSize;
  const ACurrentColor: TThemeColor; const AOptions: TThemedSvgRenderOptions): TGPBitmap;
begin
  FLastError := '';
  try
    Result := TThemedSvgRenderer.RenderToBitmap(ADocument, ASize.cx, ASize.cy, ACurrentColor, AOptions);
  except
    on E: Exception do
    begin
      FLastError := E.ClassName + ': ' + E.Message;
      Result := nil;
    end;
  end;
end;

class function TThemedSvgIconCache.CreateBitmapKey(const AIconKey: string; const ASize: TSize;
  const ACurrentColor: TThemeColor; const ADpiScale: Single; const AOptions: TThemedSvgRenderOptions): string;
const
  CFlags: array[Boolean] of string = ('0', '1');
begin
  Result := AIconKey + '|' + IntToStr(ASize.cx) + 'x' + IntToStr(ASize.cy) + '|' +
    IntToHex(Cardinal(ACurrentColor), 8) + '|' + FormatFloat('0.###', ADpiScale, TFormatSettings.Invariant) + '|' +
    CFlags[AOptions.PreserveAspectRatio] + '|' + CFlags[AOptions.Center] + '|' +
    FormatFloat('0.###', AOptions.DefaultOpacity, TFormatSettings.Invariant) + '|' +
    FormatFloat('0.###', AOptions.DefaultStrokeWidth, TFormatSettings.Invariant) + '|' +
    CFlags[AOptions.PixelSnapBounds] + '|' + CFlags[AOptions.ForceCurrentColor] + '|' +
    CFlags[AOptions.CurrentColorOverridesFill] + '|' + CFlags[AOptions.CurrentColorOverridesStroke];
end;

end.

unit NimbusForms.Grid.GdiCache;

interface

uses
  System.SysUtils,
  System.SyncObjs,
  System.Generics.Collections,
  Winapi.GDIPOBJ,
  Winapi.GDIPAPI,
  NimbusForms.Theming.Types;

type
  TThemedGridGdiCache = class
  strict private
    class var FBrushes: TDictionary<Cardinal, TGPSolidBrush>;
    class var FPens: TDictionary<string, TGPPen>;
    class var FLock: TCriticalSection;
    class procedure ClearBrushes; static;
    class procedure ClearPens; static;
  public
    const
      MaxBrushes = 128;
      MaxPens = 192;
    class constructor Create;
    class destructor Destroy;
    class function Brush(const AColor: TThemeColor): TGPSolidBrush; static;
    class function Pen(const AColor: TThemeColor): TGPPen; overload; static;
    class function Pen(const AColor: TThemeColor; const AWidth: Single): TGPPen; overload; static;
    class procedure Clear; static;
  end;

implementation

class constructor TThemedGridGdiCache.Create;
begin
  FBrushes := TDictionary<Cardinal, TGPSolidBrush>.Create;
  FPens := TDictionary<string, TGPPen>.Create;
  FLock := TCriticalSection.Create;
end;

class destructor TThemedGridGdiCache.Destroy;
begin
  Clear;
  FBrushes.Free;
  FPens.Free;
  FLock.Free;
end;

class procedure TThemedGridGdiCache.ClearBrushes;
var
  LPair: TPair<Cardinal, TGPSolidBrush>;
begin
  for LPair in FBrushes do
    LPair.Value.Free;
  FBrushes.Clear;
end;

class procedure TThemedGridGdiCache.ClearPens;
var
  LPair: TPair<string, TGPPen>;
begin
  for LPair in FPens do
    LPair.Value.Free;
  FPens.Clear;
end;

class function TThemedGridGdiCache.Brush(const AColor: TThemeColor): TGPSolidBrush;
var
  LKey: Cardinal;
begin
  LKey := Cardinal(AColor);
  FLock.Enter;
  try
    if FBrushes.TryGetValue(LKey, Result) then
      Exit;
    if FBrushes.Count >= MaxBrushes then
      ClearBrushes;
    Result := TGPSolidBrush.Create(TGPColor(LKey));
    FBrushes.Add(LKey, Result);
  finally
    FLock.Leave;
  end;
end;

class function TThemedGridGdiCache.Pen(const AColor: TThemeColor): TGPPen;
begin
  Result := Pen(AColor, 1.0);
end;

class function TThemedGridGdiCache.Pen(const AColor: TThemeColor; const AWidth: Single): TGPPen;
var
  LKey: string;
begin
  LKey := UIntToStr(Cardinal(AColor)) + '|' + FormatFloat('0.###', AWidth, TFormatSettings.Invariant);
  FLock.Enter;
  try
    if FPens.TryGetValue(LKey, Result) then
      Exit;
    if FPens.Count >= MaxPens then
      ClearPens;
    Result := TGPPen.Create(TGPColor(Cardinal(AColor)), AWidth);
    FPens.Add(LKey, Result);
  finally
    FLock.Leave;
  end;
end;

class procedure TThemedGridGdiCache.Clear;
begin
  FLock.Enter;
  try
    ClearBrushes;
    ClearPens;
  finally
    FLock.Leave;
  end;
end;

end.

unit NimbusForms.HexEditor.RenderSurface;

interface

uses
  Winapi.Windows,
  System.Types,
  System.Generics.Collections,
  Vcl.Graphics,
  NimbusForms.Theming.Types,
  NimbusForms.HexEditor.Types;

type
  IHexRenderSurface = interface
    ['{2A9F4C31-5B7E-4D28-9A16-8C3B2E5D7F41}']
    procedure SetFont(const AFont: TFont);
    function MeasureText(const AText: string): TSize;
    procedure FillRectangle(const AColor: TThemeColor; const ARect: TRect);
    procedure DrawRectangle(const AColor: TThemeColor; const ARect: TRect);
    procedure DrawLine(const AColor: TThemeColor; const AX1, AY1, AX2, AY2: Integer);
    procedure DrawText(const AText: string; const ARect: TRect;
      const AColor: TThemeColor; const AFlags: THexTextFlags);
    procedure FillTriangle(const AColor: TThemeColor; const AP1, AP2, AP3: TPoint);
    procedure FillRoundedRectangle(const AColor: TThemeColor; const ARect: TRect;
      const ARadius: Integer);
    procedure PushClip(const ARect: TRect);
    procedure PopClip;
  end;

  TGdiHexRenderSurface = class(TInterfacedObject, IHexRenderSurface)
  private
    FCanvas: TCanvas;
    FClipStack: TStack<Integer>;
    function FlagsToDraw(const AFlags: THexTextFlags): UINT;
  public
    constructor Create(const ACanvas: TCanvas);
    destructor Destroy; override;
    procedure SetFont(const AFont: TFont);
    function MeasureText(const AText: string): TSize;
    procedure FillRectangle(const AColor: TThemeColor; const ARect: TRect);
    procedure DrawRectangle(const AColor: TThemeColor; const ARect: TRect);
    procedure DrawLine(const AColor: TThemeColor; const AX1, AY1, AX2, AY2: Integer);
    procedure DrawText(const AText: string; const ARect: TRect;
      const AColor: TThemeColor; const AFlags: THexTextFlags);
    procedure FillTriangle(const AColor: TThemeColor; const AP1, AP2, AP3: TPoint);
    procedure FillRoundedRectangle(const AColor: TThemeColor; const ARect: TRect;
      const ARadius: Integer);
    procedure PushClip(const ARect: TRect);
    procedure PopClip;
  end;

implementation

constructor TGdiHexRenderSurface.Create(const ACanvas: TCanvas);
begin
  inherited Create;
  FCanvas := ACanvas;
  FClipStack := TStack<Integer>.Create;
end;

destructor TGdiHexRenderSurface.Destroy;
begin
  FClipStack.Free;
  inherited Destroy;
end;

procedure TGdiHexRenderSurface.SetFont(const AFont: TFont);
begin
  FCanvas.Font.Assign(AFont);
end;

function TGdiHexRenderSurface.MeasureText(const AText: string): TSize;
begin
  Result.cx := 0;
  Result.cy := 0;
  GetTextExtentPoint32(FCanvas.Handle, PChar(AText), Length(AText), Result);
end;

function TGdiHexRenderSurface.FlagsToDraw(const AFlags: THexTextFlags): UINT;
begin
  Result := DT_NOPREFIX;
  if htfRight in AFlags then
    Result := Result or DT_RIGHT
  else if htfHCenter in AFlags then
    Result := Result or DT_CENTER
  else
    Result := Result or DT_LEFT;
  if htfVCenter in AFlags then
    Result := Result or DT_VCENTER or DT_SINGLELINE;
end;

procedure TGdiHexRenderSurface.FillRectangle(const AColor: TThemeColor;
  const ARect: TRect);
begin
  FCanvas.Brush.Style := bsSolid;
  FCanvas.Brush.Color := ThemeColorToColor(AColor);
  FCanvas.FillRect(ARect);
end;

procedure TGdiHexRenderSurface.DrawRectangle(const AColor: TThemeColor;
  const ARect: TRect);
begin
  FCanvas.Brush.Style := bsClear;
  FCanvas.Pen.Style := psSolid;
  FCanvas.Pen.Width := 1;
  FCanvas.Pen.Color := ThemeColorToColor(AColor);
  FCanvas.Rectangle(ARect.Left, ARect.Top, ARect.Right + 1, ARect.Bottom + 1);
  FCanvas.Brush.Style := bsSolid;
end;

procedure TGdiHexRenderSurface.DrawLine(const AColor: TThemeColor;
  const AX1, AY1, AX2, AY2: Integer);
begin
  FCanvas.Pen.Style := psSolid;
  FCanvas.Pen.Width := 1;
  FCanvas.Pen.Color := ThemeColorToColor(AColor);
  FCanvas.MoveTo(AX1, AY1);
  FCanvas.LineTo(AX2, AY2);
end;

procedure TGdiHexRenderSurface.DrawText(const AText: string; const ARect: TRect;
  const AColor: TThemeColor; const AFlags: THexTextFlags);
var
  LRect: TRect;
begin
  if AText = '' then
    Exit;
  LRect := ARect;
  SetBkMode(FCanvas.Handle, TRANSPARENT);
  SetTextColor(FCanvas.Handle, ThemeColorToColorRef(AColor));
  Winapi.Windows.DrawTextW(FCanvas.Handle, PChar(AText), Length(AText), LRect,
    FlagsToDraw(AFlags));
end;

procedure TGdiHexRenderSurface.FillTriangle(const AColor: TThemeColor;
  const AP1, AP2, AP3: TPoint);
var
  LPoints: array[0..2] of TPoint;
begin
  LPoints[0] := AP1;
  LPoints[1] := AP2;
  LPoints[2] := AP3;
  FCanvas.Brush.Style := bsSolid;
  FCanvas.Brush.Color := ThemeColorToColor(AColor);
  FCanvas.Pen.Style := psClear;
  FCanvas.Polygon(LPoints);
  FCanvas.Pen.Style := psSolid;
end;

procedure TGdiHexRenderSurface.FillRoundedRectangle(const AColor: TThemeColor;
  const ARect: TRect; const ARadius: Integer);
begin
  FCanvas.Brush.Style := bsSolid;
  FCanvas.Brush.Color := ThemeColorToColor(AColor);
  FCanvas.Pen.Style := psClear;
  FCanvas.RoundRect(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom,
    ARadius * 2, ARadius * 2);
  FCanvas.Pen.Style := psSolid;
end;

procedure TGdiHexRenderSurface.PushClip(const ARect: TRect);
var
  LSaved: Integer;
begin
  LSaved := SaveDC(FCanvas.Handle);
  FClipStack.Push(LSaved);
  IntersectClipRect(FCanvas.Handle, ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
end;

procedure TGdiHexRenderSurface.PopClip;
var
  LSaved: Integer;
begin
  if FClipStack.Count = 0 then
    Exit;
  LSaved := FClipStack.Pop;
  RestoreDC(FCanvas.Handle, LSaved);
end;

end.

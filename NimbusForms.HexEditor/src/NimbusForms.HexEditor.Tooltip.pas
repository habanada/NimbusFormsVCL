unit NimbusForms.HexEditor.Tooltip;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.SysUtils,
  System.Types,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Forms,
  NimbusForms.Theming.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.HexEditor.Types,
  NimbusForms.HexEditor.Theme,
  NimbusForms.HexEditor.RenderSurface;

type
  TThemedHexTooltip = class(TCustomControl, IThemeAware)
  private
    FTheme: THexTheme;
    FRenderSurface: IHexRenderSurface;
    FMeasureSurface: IHexRenderSurface;
    FMeasureBitmap: Vcl.Graphics.TBitmap;
    FLines: TArray<string>;
    FPadding: Integer;
    FLineSpacing: Integer;
    procedure ComputeSize(out AWidth, AHeight: Integer);
    function MeasureLine(const ASurface: IHexRenderSurface; const AText: string): TSize;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const APalette: TThemePalette);
    procedure ShowText(const AText: string; const AScreenPos: TPoint);
    procedure HideTooltip;
  end;

implementation

uses
  System.Math,
  System.StrUtils,
  NimbusForms.Theming.Manager;

const
  CDefaultPadding = 8;
  CDefaultLineSpacing = 2;
  CMaxWidth = 480;

constructor TThemedHexTooltip.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csOpaque];
  DoubleBuffered := True;
  FTheme := THexTheme.FromPalette(ThemeManager.CurrentTheme);
  FRenderSurface := TGdiPlusHexRenderSurface.Create;
  FMeasureSurface := TGdiPlusHexRenderSurface.Create;
  FMeasureBitmap := Vcl.Graphics.TBitmap.Create;
  FMeasureBitmap.PixelFormat := pf32bit;
  FMeasureBitmap.SetSize(8, 8);
  FMeasureSurface.BeginRender(FMeasureBitmap.Canvas);
  FPadding := CDefaultPadding;
  FLineSpacing := CDefaultLineSpacing;
  Visible := False;
  Font.Name := 'Segoe UI';
  Font.Size := 9;
  ThemeManager.RegisterAware(Self);
end;

destructor TThemedHexTooltip.Destroy;
begin
  ThemeManager.UnregisterAware(Self);
  if FRenderSurface <> nil then FRenderSurface.EndRender;
  if FMeasureSurface <> nil then FMeasureSurface.EndRender;
  FRenderSurface := nil;
  FMeasureSurface := nil;
  FMeasureBitmap.Free;
  FTheme.Free;
  inherited Destroy;
end;

procedure TThemedHexTooltip.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := WS_POPUP;
  Params.ExStyle := Params.ExStyle or WS_EX_TOOLWINDOW or WS_EX_NOACTIVATE or WS_EX_TOPMOST;
  Params.WindowClass.style := Params.WindowClass.style or CS_DROPSHADOW;
end;

procedure TThemedHexTooltip.ApplyTheme(const APalette: TThemePalette);
begin
  FTheme.Free;
  FTheme := THexTheme.FromPalette(APalette);
  if Visible then
    Invalidate;
end;

function TThemedHexTooltip.MeasureLine(const ASurface: IHexRenderSurface; const AText: string): TSize;
begin
  Result.cx := 0;
  Result.cy := Abs(Font.Height) + 2;
  if (ASurface <> nil) and (AText <> '') then
    Result := ASurface.MeasureText(AText);
  if Result.cy <= 0 then
    Result.cy := Abs(Font.Height) + 2;
end;

procedure TThemedHexTooltip.ComputeSize(out AWidth, AHeight: Integer);
var
  I: Integer;
  LSize: TSize;
  LMaxWidth, LTotalHeight, LLineHeight: Integer;
begin
  FMeasureSurface.SetFont(Font);
  LMaxWidth := 0;
  LLineHeight := Abs(Font.Height) + 4;
  LTotalHeight := 0;
  for I := 0 to High(FLines) do
  begin
    LSize := MeasureLine(FMeasureSurface, FLines[I]);
    if LSize.cx > LMaxWidth then
      LMaxWidth := LSize.cx;
    if LSize.cy > LLineHeight then
      LLineHeight := LSize.cy;
    Inc(LTotalHeight, LSize.cy + FLineSpacing);
  end;
  if LMaxWidth > CMaxWidth then
    LMaxWidth := CMaxWidth;
  AWidth := LMaxWidth + FPadding * 2;
  AHeight := LTotalHeight + FPadding * 2;
  if AHeight < LLineHeight + FPadding * 2 then
    AHeight := LLineHeight + FPadding * 2;
end;

procedure TThemedHexTooltip.ShowText(const AText: string; const AScreenPos: TPoint);
var
  LWidth, LHeight, LX, LY: Integer;
  LMonitor: TMonitor;
begin
  if Trim(AText) = '' then
  begin
    HideTooltip;
    Exit;
  end;
  FLines := SplitString(StringReplace(AText, #13#10, #10, [rfReplaceAll]), #10);
  ComputeSize(LWidth, LHeight);

  LX := AScreenPos.X;
  LY := AScreenPos.Y;
  LMonitor := Screen.MonitorFromPoint(AScreenPos);
  if LMonitor <> nil then
  begin
    if LX + LWidth > LMonitor.WorkareaRect.Right then
      LX := LMonitor.WorkareaRect.Right - LWidth;
    if LY + LHeight > LMonitor.WorkareaRect.Bottom then
      LY := AScreenPos.Y - LHeight - 24;
    if LX < LMonitor.WorkareaRect.Left then
      LX := LMonitor.WorkareaRect.Left;
    if LY < LMonitor.WorkareaRect.Top then
      LY := LMonitor.WorkareaRect.Top;
  end;

  SetWindowPos(Handle, HWND_TOPMOST, LX, LY, LWidth, LHeight,
    SWP_NOACTIVATE or SWP_SHOWWINDOW);
  Visible := True;
  Invalidate;
end;

procedure TThemedHexTooltip.HideTooltip;
begin
  if HandleAllocated then
    ShowWindow(Handle, SW_HIDE);
  Visible := False;
end;

procedure TThemedHexTooltip.Paint;
var
  I, LY, LLineHeight: Integer;
begin
  FRenderSurface.BeginRender(Canvas);
  try
    FRenderSurface.SetFont(Font);
    FRenderSurface.FillRectangle(FTheme.HeaderBackColor, ClientRect);
    FRenderSurface.DrawRectangle(FTheme.BorderColor, Rect(0, 0, ClientWidth - 1, ClientHeight - 1));
    LLineHeight := Abs(Font.Height) + 4;
    LY := FPadding;
    for I := 0 to High(FLines) do
    begin
      FRenderSurface.DrawText(FLines[I], Rect(FPadding, LY, ClientWidth - FPadding, LY + LLineHeight),
        FTheme.ForeColor, [htfVCenter, htfLeft, htfNoPadding]);
      Inc(LY, LLineHeight + FLineSpacing);
    end;
  finally
    FRenderSurface.EndRender;
  end;
end;

procedure TThemedHexTooltip.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

end.

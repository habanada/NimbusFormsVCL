unit NimbusForms.Grid.SelectionRenderer;

interface

uses
  System.Types,
  NimbusForms.Theming.Types,
  NimbusForms.Grid.RenderContext;

type
  TThemedGridSelectionRenderer = class
  public
    procedure DrawRange(const AContext: TThemedGridRenderContext; const ABounds: TRect);
    procedure DrawRow(const AContext: TThemedGridRenderContext; const ABounds: TRect);
    procedure DrawColumn(const AContext: TThemedGridRenderContext; const ABounds: TRect);
    procedure DrawAnchor(const AContext: TThemedGridRenderContext; const ABounds: TRect);
  end;

implementation

uses
  Winapi.GDIPOBJ,
  NimbusForms.Grid.GdiCache;

function WithAlpha(const AColor: TThemeColor; const AAlpha: Byte): TThemeColor;
begin
  Result := ThemeColor(AAlpha, ThemeColorRed(AColor), ThemeColorGreen(AColor), ThemeColorBlue(AColor));
end;

procedure TThemedGridSelectionRenderer.DrawRange(const AContext: TThemedGridRenderContext; const ABounds: TRect);
var
  LBorderColor, LFillColor: TThemeColor;
begin
  if (AContext = nil) or (AContext.Graphics = nil) then
    Exit;
  if (ABounds.Width <= 0) or (ABounds.Height <= 0) then
    Exit;
  LBorderColor := AContext.FocusColor;
  LFillColor := WithAlpha(LBorderColor, 54);
  AContext.Graphics.FillRectangle(TThemedGridGdiCache.Brush(LFillColor), ABounds.Left, ABounds.Top, ABounds.Width, ABounds.Height);
  AContext.Graphics.DrawRectangle(TThemedGridGdiCache.Pen(LBorderColor), ABounds.Left, ABounds.Top, ABounds.Width - 1, ABounds.Height - 1);
  AContext.Graphics.DrawRectangle(TThemedGridGdiCache.Pen(WithAlpha(LBorderColor, 150), 2.0), ABounds.Left + 1, ABounds.Top + 1, ABounds.Width - 3, ABounds.Height - 3);
end;

procedure TThemedGridSelectionRenderer.DrawRow(const AContext: TThemedGridRenderContext; const ABounds: TRect);
var
  LBorderColor, LFillColor: TThemeColor;
begin
  if (AContext = nil) or (AContext.Graphics = nil) then
    Exit;
  if (ABounds.Width <= 0) or (ABounds.Height <= 0) then
    Exit;
  LBorderColor := AContext.FocusColor;
  LFillColor := WithAlpha(LBorderColor, 34);
  AContext.Graphics.FillRectangle(TThemedGridGdiCache.Brush(LFillColor), ABounds.Left, ABounds.Top, ABounds.Width, ABounds.Height);
  AContext.Graphics.DrawRectangle(TThemedGridGdiCache.Pen(LBorderColor), ABounds.Left, ABounds.Top, ABounds.Width - 1, ABounds.Height - 1);
end;

procedure TThemedGridSelectionRenderer.DrawColumn(const AContext: TThemedGridRenderContext; const ABounds: TRect);
var
  LBorderColor, LFillColor: TThemeColor;
begin
  if (AContext = nil) or (AContext.Graphics = nil) then
    Exit;
  if (ABounds.Width <= 0) or (ABounds.Height <= 0) then
    Exit;
  LBorderColor := AContext.FocusColor;
  LFillColor := WithAlpha(LBorderColor, 30);
  AContext.Graphics.FillRectangle(TThemedGridGdiCache.Brush(LFillColor), ABounds.Left, ABounds.Top, ABounds.Width, ABounds.Height);
  AContext.Graphics.DrawRectangle(TThemedGridGdiCache.Pen(LBorderColor), ABounds.Left, ABounds.Top, ABounds.Width - 1, ABounds.Height - 1);
end;

procedure TThemedGridSelectionRenderer.DrawAnchor(const AContext: TThemedGridRenderContext; const ABounds: TRect);
var
  LAnchorBounds: TRect;
begin
  if (AContext = nil) or (AContext.Graphics = nil) then
    Exit;
  if (ABounds.Width <= 0) or (ABounds.Height <= 0) then
    Exit;
  LAnchorBounds := ABounds;
  LAnchorBounds.Inflate(-2, -2);
  AContext.Graphics.DrawRectangle(TThemedGridGdiCache.Pen(AContext.FocusColor, 2.0), LAnchorBounds.Left, LAnchorBounds.Top, LAnchorBounds.Width - 1, LAnchorBounds.Height - 1);
end;

end.

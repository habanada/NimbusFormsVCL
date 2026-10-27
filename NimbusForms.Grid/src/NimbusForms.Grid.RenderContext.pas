unit NimbusForms.Grid.RenderContext;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  System.Types,
  Vcl.Graphics,
  Winapi.GDIPOBJ,
  Winapi.GDIPAPI,
  NimbusForms.Theming.Types,
  NimbusForms.Theming.Palette,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.RenderMetrics;

type
  TThemedGridRenderContext = class
  private
    FGraphics: TGPGraphics;
    FOwnsGraphics: Boolean;
    FDC: HDC;
    FBounds: TRect;
    FFont: TFont;
    FPalette: TThemePalette;
    FMetrics: TThemedGridRenderMetrics;
    FOwnsMetrics: Boolean;
    FHorizontalOffset: Integer;
    FFirstVisibleRowIndex: Integer;
    FHeaderBounds: TRect;
    FRowHeaderBounds: TRect;
    FDataBounds: TRect;
    FVerticalScrollBarBounds: TRect;
    FHorizontalScrollBarBounds: TRect;
    FScrollCornerBounds: TRect;
    function GetBackColor: TThemeColor;
    function GetForeColor: TThemeColor;
    function GetBorderColor: TThemeColor;
    function GetHeaderBackColor: TThemeColor;
    function GetHeaderForeColor: TThemeColor;
    function GetGridLineColor: TThemeColor;
    function GetSelectionBackColor: TThemeColor;
    function GetSelectionForeColor: TThemeColor;
    function GetHoverBackColor: TThemeColor;
    function GetFocusColor: TThemeColor;
  public
    constructor Create(const ADC: HDC; const ABounds: TRect; const AFont: TFont;
      const APalette: TThemePalette; const AMetrics: TThemedGridRenderMetrics);
    destructor Destroy; override;
    procedure ApplyQuality;
    function CreateStringFormat(const AAlignment: TThemedGridContentAlignment; const AEllipsis: Boolean): TGPStringFormat;
    property Graphics: TGPGraphics read FGraphics;
    property DC: HDC read FDC;
    property Bounds: TRect read FBounds;
    property Font: TFont read FFont;
    property Palette: TThemePalette read FPalette;
    property Metrics: TThemedGridRenderMetrics read FMetrics;
    property HorizontalOffset: Integer read FHorizontalOffset write FHorizontalOffset;
    property FirstVisibleRowIndex: Integer read FFirstVisibleRowIndex write FFirstVisibleRowIndex;
    property HeaderBounds: TRect read FHeaderBounds write FHeaderBounds;
    property RowHeaderBounds: TRect read FRowHeaderBounds write FRowHeaderBounds;
    property DataBounds: TRect read FDataBounds write FDataBounds;
    property VerticalScrollBarBounds: TRect read FVerticalScrollBarBounds write FVerticalScrollBarBounds;
    property HorizontalScrollBarBounds: TRect read FHorizontalScrollBarBounds write FHorizontalScrollBarBounds;
    property ScrollCornerBounds: TRect read FScrollCornerBounds write FScrollCornerBounds;
    property BackColor: TThemeColor read GetBackColor;
    property ForeColor: TThemeColor read GetForeColor;
    property BorderColor: TThemeColor read GetBorderColor;
    property HeaderBackColor: TThemeColor read GetHeaderBackColor;
    property HeaderForeColor: TThemeColor read GetHeaderForeColor;
    property GridLineColor: TThemeColor read GetGridLineColor;
    property SelectionBackColor: TThemeColor read GetSelectionBackColor;
    property SelectionForeColor: TThemeColor read GetSelectionForeColor;
    property HoverBackColor: TThemeColor read GetHoverBackColor;
    property FocusColor: TThemeColor read GetFocusColor;
  end;

implementation

const
  CFallbackWindow = TThemeColor($FFFFFFFF);
  CFallbackControl = TThemeColor($FFF0F0F0);
  CFallbackControlText = TThemeColor($FF000000);
  CFallbackControlDark = TThemeColor($FFA0A0A0);
  CFallbackControlLight = TThemeColor($FFE3E3E3);
  CFallbackHighlight = TThemeColor($FF3399FF);
  CFallbackHighlightText = TThemeColor($FFFFFFFF);

constructor TThemedGridRenderContext.Create(const ADC: HDC; const ABounds: TRect;
  const AFont: TFont; const APalette: TThemePalette; const AMetrics: TThemedGridRenderMetrics);
begin
  inherited Create;
  FDC := ADC;
  FBounds := ABounds;
  FFont := AFont;
  FPalette := APalette;
  if AMetrics <> nil then
    FMetrics := AMetrics
  else
  begin
    FMetrics := TThemedGridRenderMetrics.Create;
    FOwnsMetrics := True;
  end;
  if ADC <> 0 then
  begin
    FGraphics := TGPGraphics.Create(ADC);
    FOwnsGraphics := True;
    ApplyQuality;
  end;
end;

destructor TThemedGridRenderContext.Destroy;
begin
  if FOwnsGraphics then
    FGraphics.Free;
  if FOwnsMetrics then
    FMetrics.Free;
  inherited Destroy;
end;

procedure TThemedGridRenderContext.ApplyQuality;
begin
  if FGraphics = nil then
    Exit;
  FGraphics.SetSmoothingMode(SmoothingModeAntiAlias);
  FGraphics.SetInterpolationMode(InterpolationModeHighQualityBicubic);
  FGraphics.SetPixelOffsetMode(PixelOffsetModeHighQuality);
  FGraphics.SetCompositingQuality(CompositingQualityHighQuality);
  FGraphics.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);
end;

function TThemedGridRenderContext.GetBackColor: TThemeColor;
begin
  if FPalette <> nil then
    Result := FPalette.ControlBackColor
  else
    Result := CFallbackWindow;
end;

function TThemedGridRenderContext.GetForeColor: TThemeColor;
begin
  if FPalette <> nil then
    Result := FPalette.ControlForeColor
  else
    Result := CFallbackControlText;
end;

function TThemedGridRenderContext.GetBorderColor: TThemeColor;
begin
  if FPalette <> nil then
    Result := FPalette.ControlBorderColor
  else
    Result := CFallbackControlDark;
end;

function TThemedGridRenderContext.GetHeaderBackColor: TThemeColor;
begin
  if FPalette <> nil then
    Result := FPalette.DockHeaderBackColor
  else
    Result := CFallbackControl;
end;

function TThemedGridRenderContext.GetHeaderForeColor: TThemeColor;
begin
  if FPalette <> nil then
    Result := FPalette.DockHeaderForeColor
  else
    Result := CFallbackControlText;
end;

function TThemedGridRenderContext.GetGridLineColor: TThemeColor;
begin
  if FPalette <> nil then
    Result := FPalette.SeparatorColor
  else
    Result := CFallbackControlLight;
end;

function TThemedGridRenderContext.GetSelectionBackColor: TThemeColor;
begin
  if FPalette <> nil then
    Result := FPalette.SelectedBackColor
  else
    Result := CFallbackHighlight;
end;

function TThemedGridRenderContext.GetSelectionForeColor: TThemeColor;
begin
  if FPalette <> nil then
    Result := FPalette.SelectedForeColor
  else
    Result := CFallbackHighlightText;
end;

function TThemedGridRenderContext.GetHoverBackColor: TThemeColor;
begin
  if FPalette <> nil then
    Result := FPalette.HoverBackColor
  else
    Result := CFallbackControlLight;
end;

function TThemedGridRenderContext.GetFocusColor: TThemeColor;
begin
  if FPalette <> nil then
    Result := FPalette.FocusBorderColor
  else
    Result := CFallbackHighlight;
end;

function TThemedGridRenderContext.CreateStringFormat(const AAlignment: TThemedGridContentAlignment;
  const AEllipsis: Boolean): TGPStringFormat;
var
  LAlign, LLineAlign: TStringAlignment;
begin
  Result := TGPStringFormat.Create;
  if AEllipsis then
    Result.SetTrimming(StringTrimmingEllipsisCharacter)
  else
    Result.SetTrimming(StringTrimmingNone);
  Result.SetFormatFlags(StringFormatFlagsNoWrap);

  case AAlignment of
    TThemedGridContentAlignment.BottomCenter,
    TThemedGridContentAlignment.MiddleCenter,
    TThemedGridContentAlignment.TopCenter:
      LAlign := StringAlignmentCenter;
    TThemedGridContentAlignment.BottomRight,
    TThemedGridContentAlignment.MiddleRight,
    TThemedGridContentAlignment.TopRight:
      LAlign := StringAlignmentFar;
  else
    LAlign := StringAlignmentNear;
  end;

  case AAlignment of
    TThemedGridContentAlignment.BottomCenter,
    TThemedGridContentAlignment.BottomLeft,
    TThemedGridContentAlignment.BottomRight:
      LLineAlign := StringAlignmentFar;
    TThemedGridContentAlignment.TopCenter,
    TThemedGridContentAlignment.TopLeft,
    TThemedGridContentAlignment.TopRight:
      LLineAlign := StringAlignmentNear;
  else
    LLineAlign := StringAlignmentCenter;
  end;

  Result.SetAlignment(LAlign);
  Result.SetLineAlignment(LLineAlign);
end;

end.

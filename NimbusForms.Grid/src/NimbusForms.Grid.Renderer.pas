unit NimbusForms.Grid.Renderer;

{$SCOPEDENUMS ON}

interface

uses
  System.Types,
  System.SysUtils,
  System.TypInfo,
  NimbusForms.Theming.Types,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Cell,
  NimbusForms.Grid.RenderContext,
  NimbusForms.Grid.CellRendererIntf,
  NimbusForms.Grid.CellRenderer,
  NimbusForms.Grid.CellRenderers,
  NimbusForms.Grid.HeaderRenderer;

type
  TThemedGridRenderer = class
  private
    FHeaderRenderer: TThemedGridHeaderRenderer;
    FCellRenderer: IThemedGridCellRenderer;
    FCellRenderers: TThemedGridCellRenderers;
  public
    constructor Create;
    destructor Destroy; override;
    function ResolveCellRenderer(const ACell: TThemedGridCell): IThemedGridCellRenderer;
    procedure DrawBackground(const AContext: TThemedGridRenderContext);
    procedure DrawBorder(const AContext: TThemedGridRenderContext);
    procedure DrawEmptyArea(const AContext: TThemedGridRenderContext; const ABounds: TRect);
    procedure DrawScrollBarTrack(const AContext: TThemedGridRenderContext; const ABounds: TRect; const AVertical: Boolean);
    procedure DrawScrollBarThumb(const AContext: TThemedGridRenderContext; const ABounds: TRect; const AHovered, ADragging: Boolean);
    procedure DrawScrollCorner(const AContext: TThemedGridRenderContext; const ABounds: TRect);
    property HeaderRenderer: TThemedGridHeaderRenderer read FHeaderRenderer;
    property CellRenderers: TThemedGridCellRenderers read FCellRenderers;
  end;

implementation

uses
  Winapi.GDIPOBJ,
  NimbusForms.Grid.ValueFormatter,
  NimbusForms.Grid.GdiCache;

constructor TThemedGridRenderer.Create;
begin
  inherited Create;
  FHeaderRenderer := TThemedGridHeaderRenderer.Create;
  FCellRenderer := TThemedGridCellRenderer.Create;
  FCellRenderers := TThemedGridCellRenderers.Create;
end;

destructor TThemedGridRenderer.Destroy;
begin
  FCellRenderers.Free;
  FCellRenderer := nil;
  FHeaderRenderer.Free;
  inherited Destroy;
end;

function TThemedGridRenderer.ResolveCellRenderer(const ACell: TThemedGridCell): IThemedGridCellRenderer;
var
  LCustom: IThemedGridCellRenderer;
  LRenderKind: TThemedGridCellRenderKind;
  LValueType: PTypeInfo;
begin
  if ACell = nil then
    Exit(FCellRenderer);
  if (ACell.Column <> nil) and (ACell.Column.Renderer <> nil) and
     Supports(ACell.Column.Renderer, IThemedGridCellRenderer, LCustom) then
    Exit(LCustom);
  if ACell.Column <> nil then
    LValueType := ACell.Column.ValueType
  else
    LValueType := nil;
  LRenderKind := TThemedGridValueFormatter.ResolveRenderKind(ACell.Value, LValueType, ACell.Column, ACell.Metadata);
  Result := FCellRenderers.GetRenderer(LRenderKind);
end;

procedure TThemedGridRenderer.DrawBackground(const AContext: TThemedGridRenderContext);
begin
  if (AContext = nil) or (AContext.Graphics = nil) then
    Exit;
  AContext.Graphics.FillRectangle(TThemedGridGdiCache.Brush(AContext.BackColor),
    AContext.Bounds.Left, AContext.Bounds.Top, AContext.Bounds.Width, AContext.Bounds.Height);
end;

procedure TThemedGridRenderer.DrawBorder(const AContext: TThemedGridRenderContext);
begin
  if (AContext = nil) or (AContext.Graphics = nil) then
    Exit;
  AContext.Graphics.DrawRectangle(TThemedGridGdiCache.Pen(AContext.BorderColor),
    AContext.Bounds.Left, AContext.Bounds.Top, AContext.Bounds.Width - 1, AContext.Bounds.Height - 1);
end;

procedure TThemedGridRenderer.DrawEmptyArea(const AContext: TThemedGridRenderContext; const ABounds: TRect);
begin
  if (AContext = nil) or (AContext.Graphics = nil) or (ABounds.Width <= 0) or (ABounds.Height <= 0) then
    Exit;
  AContext.Graphics.FillRectangle(TThemedGridGdiCache.Brush(AContext.BackColor),
    ABounds.Left, ABounds.Top, ABounds.Width, ABounds.Height);
end;

procedure TThemedGridRenderer.DrawScrollBarTrack(const AContext: TThemedGridRenderContext; const ABounds: TRect; const AVertical: Boolean);
var
  LColor: TThemeColor;
begin
  if (AContext = nil) or (AContext.Graphics = nil) or (ABounds.Width <= 0) or (ABounds.Height <= 0) then
    Exit;
  if AContext.Palette <> nil then
    LColor := AContext.Palette.PanelBackColor
  else
    LColor := AContext.BackColor;
  AContext.Graphics.FillRectangle(TThemedGridGdiCache.Brush(LColor), ABounds.Left, ABounds.Top, ABounds.Width, ABounds.Height);
end;

procedure TThemedGridRenderer.DrawScrollBarThumb(const AContext: TThemedGridRenderContext; const ABounds: TRect; const AHovered, ADragging: Boolean);
var
  LColor: TThemeColor;
  LThumb: TRect;
begin
  if (AContext = nil) or (AContext.Graphics = nil) or (ABounds.Width <= 0) or (ABounds.Height <= 0) then
    Exit;
  if AContext.Palette <> nil then
    LColor := AContext.Palette.MutedForeColor
  else
    LColor := AContext.BorderColor;
  if ADragging then
  begin
    if AContext.Palette <> nil then
      LColor := AContext.Palette.PressedBackColor;
  end
  else if AHovered then
  begin
    if AContext.Palette <> nil then
      LColor := AContext.Palette.AccentColor;
  end;
  LThumb := ABounds;
  LThumb.Inflate(-2, -2);
  AContext.Graphics.FillRectangle(TThemedGridGdiCache.Brush(LColor), LThumb.Left, LThumb.Top, LThumb.Width, LThumb.Height);
end;

procedure TThemedGridRenderer.DrawScrollCorner(const AContext: TThemedGridRenderContext; const ABounds: TRect);
var
  LColor: TThemeColor;
begin
  if (AContext = nil) or (AContext.Graphics = nil) or (ABounds.Width <= 0) or (ABounds.Height <= 0) then
    Exit;
  if AContext.Palette <> nil then
    LColor := AContext.Palette.PanelBackColor
  else
    LColor := AContext.BackColor;
  AContext.Graphics.FillRectangle(TThemedGridGdiCache.Brush(LColor), ABounds.Left, ABounds.Top, ABounds.Width, ABounds.Height);
end;

end.

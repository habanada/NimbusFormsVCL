unit NimbusForms.Grid.RenderMetrics;

interface

type
  TThemedGridPadding = record
    Left: Integer;
    Top: Integer;
    Right: Integer;
    Bottom: Integer;
    constructor Create(const ALeft, ATop, ARight, ABottom: Integer);
    function Horizontal: Integer;
    function Vertical: Integer;
  end;

  TThemedGridRenderMetrics = class
  private
    FHeaderHeight: Integer;
    FRowHeight: Integer;
    FRowHeaderWidth: Integer;
    FScrollBarSize: Integer;
    FCellPadding: TThemedGridPadding;
    FHeaderPadding: TThemedGridPadding;
    FGridLineWidth: Integer;
    FCheckBoxSize: Integer;
    FGlyphSize: Integer;
    FFocusInset: Integer;
  public
    constructor Create;
    property HeaderHeight: Integer read FHeaderHeight write FHeaderHeight;
    property RowHeight: Integer read FRowHeight write FRowHeight;
    property RowHeaderWidth: Integer read FRowHeaderWidth write FRowHeaderWidth;
    property ScrollBarSize: Integer read FScrollBarSize write FScrollBarSize;
    property CellPadding: TThemedGridPadding read FCellPadding write FCellPadding;
    property HeaderPadding: TThemedGridPadding read FHeaderPadding write FHeaderPadding;
    property GridLineWidth: Integer read FGridLineWidth write FGridLineWidth;
    property CheckBoxSize: Integer read FCheckBoxSize write FCheckBoxSize;
    property GlyphSize: Integer read FGlyphSize write FGlyphSize;
    property FocusInset: Integer read FFocusInset write FFocusInset;
  end;

implementation

constructor TThemedGridPadding.Create(const ALeft, ATop, ARight, ABottom: Integer);
begin
  Left := ALeft;
  Top := ATop;
  Right := ARight;
  Bottom := ABottom;
end;

function TThemedGridPadding.Horizontal: Integer;
begin
  Result := Left + Right;
end;

function TThemedGridPadding.Vertical: Integer;
begin
  Result := Top + Bottom;
end;

constructor TThemedGridRenderMetrics.Create;
begin
  inherited Create;
  FHeaderHeight := 26;
  FRowHeight := 24;
  FRowHeaderWidth := 34;
  FScrollBarSize := 10;
  FCellPadding := TThemedGridPadding.Create(6, 0, 6, 0);
  FHeaderPadding := TThemedGridPadding.Create(8, 0, 8, 0);
  FGridLineWidth := 1;
  FCheckBoxSize := 14;
  FGlyphSize := 16;
  FFocusInset := 1;
end;

end.

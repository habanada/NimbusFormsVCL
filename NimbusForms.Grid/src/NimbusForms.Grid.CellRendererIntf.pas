unit NimbusForms.Grid.CellRendererIntf;

interface

uses
  System.Types,
  NimbusForms.Grid.Cell,
  NimbusForms.Grid.HitInfo,
  NimbusForms.Grid.RenderContext;

type
  IThemedGridCellRenderer = interface
    ['{9B2C7A41-5D8E-4F31-8C2A-7E1D9B3F6A52}']
    procedure Draw(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell);
    function Measure(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell): TSize;
    function HitTestContent(const AContext: TThemedGridRenderContext; const ACell: TThemedGridCell;
      const ALocation: TPoint): TThemedGridHitInfo;
  end;

implementation

end.

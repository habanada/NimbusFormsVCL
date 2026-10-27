unit NimbusForms.HexEditor.RenderContext;

interface

uses
  System.Types,
  System.Generics.Collections,
  NimbusForms.HexEditor.Types,
  NimbusForms.HexEditor.Options,
  NimbusForms.HexEditor.Theme,
  NimbusForms.HexEditor.DataSource,
  NimbusForms.HexEditor.Bookmarks,
  NimbusForms.HexEditor.Search,
  NimbusForms.HexEditor.RenderSurface;

type
  THexRenderMetrics = class
  public
    HeaderHeight: Integer;
    RowHeight: Integer;
    GutterWidth: Integer;
    HexStartX: Integer;
    AsciiStartX: Integer;
    CellWidth: Integer;
    AsciiCellWidth: Integer;
    ByteGroupWidth: Integer;
    ByteGroupSpacing: Integer;
    CharWidth: Integer;
    HexContentWidth: Integer;
    ContentBounds: TRect;
    function GetHexCellX(const AColumnIndex, AByteGroupSize: Integer): Integer;
    function GetAsciiCellX(const AColumnIndex: Integer): Integer;
  end;

  THexRenderContext = class
  public
    Surface: IHexRenderSurface;
    Bounds: TRect;
    DataSource: IHexDataSource;
    Options: THexEditorOptions;
    Theme: THexTheme;
    Selection: THexSelection;
    Bookmarks: THexBookmarkManager;
    ActiveSearchMatch: THexSearchMatch;
    AdvancedSearchMatches: TList<THexSearchMatch>;
    ActiveAdvancedSearchMatch: THexSearchMatch;
    ModifiedOffsets: TDictionary<Int64, Boolean>;
    FirstVisibleOffset: Int64;
    CursorOffset: Int64;
    HoverOffset: Int64;
    VerticalScrollValue: Integer;
    HorizontalScrollValue: Integer;
    Focused: Boolean;
    Enabled: Boolean;
    IsHighNibble: Boolean;
    InsertMode: Boolean;
    ActiveEditArea: THexHitArea;
    constructor Create;
  end;

implementation

function THexRenderMetrics.GetHexCellX(const AColumnIndex,
  AByteGroupSize: Integer): Integer;
var
  LColumn, LGroupSize, LGroupOffset: Integer;
begin
  LColumn := AColumnIndex;
  if LColumn < 0 then
    LColumn := 0;
  LGroupSize := AByteGroupSize;
  if LGroupSize < 1 then
    LGroupSize := 1;
  LGroupOffset := LColumn div LGroupSize;
  Result := HexStartX + LColumn * CellWidth + LGroupOffset * ByteGroupSpacing;
end;

function THexRenderMetrics.GetAsciiCellX(const AColumnIndex: Integer): Integer;
var
  LColumn: Integer;
begin
  LColumn := AColumnIndex;
  if LColumn < 0 then
    LColumn := 0;
  Result := AsciiStartX + LColumn * AsciiCellWidth;
end;

constructor THexRenderContext.Create;
begin
  inherited Create;
  CursorOffset := -1;
  HoverOffset := -1;
  Enabled := True;
  IsHighNibble := True;
  ActiveEditArea := hhaHexCell;
end;

end.

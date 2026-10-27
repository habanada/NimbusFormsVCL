unit NimbusForms.Grid.SearchResult;

interface

uses
  System.Generics.Collections,
  NimbusForms.Grid.SearchMatch;

type
  TThemedGridSearchResult = class
  private
    FRowIndex: Integer;
    FColumnIndex: Integer;
    FDataSourceIndex: Integer;
    FScore: Integer;
    FMatches: TObjectList<TThemedGridSearchMatch>;
  public
    constructor Create;
    destructor Destroy; override;
    property RowIndex: Integer read FRowIndex write FRowIndex;
    property ColumnIndex: Integer read FColumnIndex write FColumnIndex;
    property DataSourceIndex: Integer read FDataSourceIndex write FDataSourceIndex;
    property Score: Integer read FScore write FScore;
    property Matches: TObjectList<TThemedGridSearchMatch> read FMatches;
  end;

implementation

constructor TThemedGridSearchResult.Create;
begin
  inherited Create;
  FMatches := TObjectList<TThemedGridSearchMatch>.Create(True);
end;

destructor TThemedGridSearchResult.Destroy;
begin
  FMatches.Free;
  inherited Destroy;
end;

end.

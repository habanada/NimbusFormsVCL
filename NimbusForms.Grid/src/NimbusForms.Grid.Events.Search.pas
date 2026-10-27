unit NimbusForms.Grid.Events.Search;

interface

uses
  NimbusForms.Grid.Events,
  NimbusForms.Grid.SearchResult;

type
  TThemedGridSearchResultChangedEventArgs = class sealed(TThemedGridEventArgs)
  private
    FResult: TThemedGridSearchResult;
    FIndex: Integer;
    FCount: Integer;
  public
    constructor Create(const AResult: TThemedGridSearchResult; const AIndex, ACount: Integer);
    property Result: TThemedGridSearchResult read FResult;
    property Index: Integer read FIndex;
    property Count: Integer read FCount;
  end;

  TThemedGridSearchResultChangedEvent = procedure(ASender: TObject;
    const AArgs: TThemedGridSearchResultChangedEventArgs) of object;

implementation

constructor TThemedGridSearchResultChangedEventArgs.Create(const AResult: TThemedGridSearchResult;
  const AIndex, ACount: Integer);
begin
  inherited Create;
  FResult := AResult;
  FIndex := AIndex;
  FCount := ACount;
end;

end.

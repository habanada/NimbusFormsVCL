unit NimbusForms.Grid.SearchMatch;

interface

type
  TThemedGridSearchMatch = class
  private
    FStartIndex: Integer;
    FLength: Integer;
  public
    property StartIndex: Integer read FStartIndex write FStartIndex;
    property Length: Integer read FLength write FLength;
  end;

implementation

end.

unit NimbusForms.Grid.DistinctValue;

interface

uses
  System.Rtti;

type
  TThemedGridDistinctValue = class
  private
    FValue: TValue;
    FDisplayText: string;
    FCount: Integer;
  public
    constructor Create;
    function ToString: string; override;
    function Clone: TThemedGridDistinctValue;
    property Value: TValue read FValue write FValue;
    property DisplayText: string read FDisplayText write FDisplayText;
    property Count: Integer read FCount write FCount;
  end;

implementation

constructor TThemedGridDistinctValue.Create;
begin
  inherited Create;
  FValue := TValue.Empty;
end;

function TThemedGridDistinctValue.ToString: string;
begin
  Result := FDisplayText;
end;

function TThemedGridDistinctValue.Clone: TThemedGridDistinctValue;
begin
  Result := TThemedGridDistinctValue.Create;
  Result.FValue := FValue;
  Result.FDisplayText := FDisplayText;
  Result.FCount := FCount;
end;

end.

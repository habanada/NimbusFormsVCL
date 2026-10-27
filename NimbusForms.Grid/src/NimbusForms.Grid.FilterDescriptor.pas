unit NimbusForms.Grid.FilterDescriptor;

{$SCOPEDENUMS ON}

interface

uses
  System.Rtti,
  System.Generics.Collections,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Column;

type
  TThemedGridFilterDescriptor = class
  private
    FValues: TList<TValue>;
    FColumnName: string;
    FColumn: TThemedGridColumn;
    FOperator: TThemedGridFilterOperator;
    FValue: TValue;
    FValue2: TValue;
    FCaseSensitive: Boolean;
    FTag: TValue;
    function GetIsActive: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function Clone: TThemedGridFilterDescriptor;
    property ColumnName: string read FColumnName write FColumnName;
    property Column: TThemedGridColumn read FColumn write FColumn;
    property Operator: TThemedGridFilterOperator read FOperator write FOperator;
    property Value: TValue read FValue write FValue;
    property Value2: TValue read FValue2 write FValue2;
    property Values: TList<TValue> read FValues;
    property CaseSensitive: Boolean read FCaseSensitive write FCaseSensitive;
    property Tag: TValue read FTag write FTag;
    property IsActive: Boolean read GetIsActive;
  end;

implementation

constructor TThemedGridFilterDescriptor.Create;
begin
  inherited Create;
  FValues := TList<TValue>.Create;
  FOperator := TThemedGridFilterOperator.None;
end;

destructor TThemedGridFilterDescriptor.Destroy;
begin
  FValues.Free;
  inherited Destroy;
end;

function TThemedGridFilterDescriptor.GetIsActive: Boolean;
begin
  if FOperator = TThemedGridFilterOperator.None then
    Exit(False);
  if (FOperator = TThemedGridFilterOperator.&In) or (FOperator = TThemedGridFilterOperator.NotIn) then
    Exit(FValues.Count > 0);
  Result := True;
end;

function TThemedGridFilterDescriptor.Clone: TThemedGridFilterDescriptor;
var
  I: Integer;
begin
  Result := TThemedGridFilterDescriptor.Create;
  Result.FColumnName := FColumnName;
  Result.FColumn := FColumn;
  Result.FOperator := FOperator;
  Result.FValue := FValue;
  Result.FValue2 := FValue2;
  Result.FCaseSensitive := FCaseSensitive;
  Result.FTag := FTag;
  for I := 0 to FValues.Count - 1 do
    Result.FValues.Add(FValues[I]);
end;

end.

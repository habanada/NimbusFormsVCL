unit NimbusForms.Grid.FormatConditionModel;

{$SCOPEDENUMS ON}

interface

uses
  System.Rtti,
  System.Generics.Collections,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.FormatConditionTypes,
  NimbusForms.Grid.FormatStyleModel;

type
  TThemedGridFormatConditionModel = class
  private
    FName: string;
    FEnabled: Boolean;
    FScope: TThemedGridFormatConditionScope;
    FColumnName: string;
    FTargetColumnName: string;
    FOperator: TThemedGridFormatConditionOperator;
    FValue: TValue;
    FValue2: TValue;
    FValues: TList<TValue>;
    FValueType: TThemedGridFormatConditionValueType;
    FPredicateKey: string;
    FStyle: TThemedGridFormatStyleModel;
    FTag: TValue;
    procedure SetStyle(const AValue: TThemedGridFormatStyleModel);
  public
    constructor Create;
    destructor Destroy; override;
    property Name: string read FName write FName;
    property Enabled: Boolean read FEnabled write FEnabled;
    property Scope: TThemedGridFormatConditionScope read FScope write FScope;
    property ColumnName: string read FColumnName write FColumnName;
    property TargetColumnName: string read FTargetColumnName write FTargetColumnName;
    property Operator: TThemedGridFormatConditionOperator read FOperator write FOperator;
    property Value: TValue read FValue write FValue;
    property Value2: TValue read FValue2 write FValue2;
    property Values: TList<TValue> read FValues;
    property ValueType: TThemedGridFormatConditionValueType read FValueType write FValueType;
    property PredicateKey: string read FPredicateKey write FPredicateKey;
    property Style: TThemedGridFormatStyleModel read FStyle write SetStyle;
    property Tag: TValue read FTag write FTag;
  end;

implementation

constructor TThemedGridFormatConditionModel.Create;
begin
  inherited Create;
  FValues := TList<TValue>.Create;
  FEnabled := True;
  FScope := TThemedGridFormatConditionScope.Cell;
  FValueType := TThemedGridFormatConditionValueType.Auto;
end;

destructor TThemedGridFormatConditionModel.Destroy;
begin
  FStyle.Free;
  FValues.Free;
  inherited Destroy;
end;

procedure TThemedGridFormatConditionModel.SetStyle(const AValue: TThemedGridFormatStyleModel);
begin
  if FStyle = AValue then
    Exit;
  FStyle.Free;
  FStyle := AValue;
end;

end.

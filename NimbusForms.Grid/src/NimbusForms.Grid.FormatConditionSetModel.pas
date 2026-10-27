unit NimbusForms.Grid.FormatConditionSetModel;

interface

uses
  System.Generics.Collections,
  NimbusForms.Grid.FormatConditionModel;

type
  TThemedGridFormatConditionSetModel = class
  private
    FVersion: Integer;
    FName: string;
    FEnabled: Boolean;
    FConditions: TObjectList<TThemedGridFormatConditionModel>;
  public
    constructor Create;
    destructor Destroy; override;
    property Version: Integer read FVersion write FVersion;
    property Name: string read FName write FName;
    property Enabled: Boolean read FEnabled write FEnabled;
    property Conditions: TObjectList<TThemedGridFormatConditionModel> read FConditions;
  end;

implementation

constructor TThemedGridFormatConditionSetModel.Create;
begin
  inherited Create;
  FVersion := 1;
  FEnabled := True;
  FConditions := TObjectList<TThemedGridFormatConditionModel>.Create(True);
end;

destructor TThemedGridFormatConditionSetModel.Destroy;
begin
  FConditions.Free;
  inherited Destroy;
end;

end.

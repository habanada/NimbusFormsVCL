unit NimbusForms.Grid.DetailRelation;

interface

uses
  System.Rtti;

type
  TThemedGridDetailRelation = class
  private
    FName: string;
    FCaption: string;
    FEnabled: Boolean;
    FMaxVisibleRows: Integer;
    FTag: TValue;
    procedure SetName(const AValue: string);
    procedure SetMaxVisibleRows(const AValue: Integer);
  public
    constructor Create; overload;
    constructor Create(const AName, ACaption: string); overload;
    function ToString: string; override;
    property Name: string read FName write SetName;
    property Caption: string read FCaption write FCaption;
    property Enabled: Boolean read FEnabled write FEnabled;
    property MaxVisibleRows: Integer read FMaxVisibleRows write SetMaxVisibleRows;
    property Tag: TValue read FTag write FTag;
  end;

implementation

uses
  NimbusForms.Grid.MasterDetailStrings;

constructor TThemedGridDetailRelation.Create;
begin
  Create(ThemedGridMasterDetailStrings.DefaultRelationName, ThemedGridMasterDetailStrings.DefaultRelationName);
end;

constructor TThemedGridDetailRelation.Create(const AName, ACaption: string);
begin
  inherited Create;
  if AName = '' then
    FName := ThemedGridMasterDetailStrings.DefaultRelationName
  else
    FName := AName;
  FCaption := ACaption;
  FEnabled := True;
  FMaxVisibleRows := 6;
end;

procedure TThemedGridDetailRelation.SetName(const AValue: string);
begin
  if AValue = '' then
    FName := ThemedGridMasterDetailStrings.DefaultRelationName
  else
    FName := AValue;
end;

procedure TThemedGridDetailRelation.SetMaxVisibleRows(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 1 then
    LValue := 1;
  if LValue > 100 then
    LValue := 100;
  FMaxVisibleRows := LValue;
end;

function TThemedGridDetailRelation.ToString: string;
begin
  if FCaption = '' then
    Result := FName
  else
    Result := FCaption;
end;

end.

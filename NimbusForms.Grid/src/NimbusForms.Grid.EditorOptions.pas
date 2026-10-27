unit NimbusForms.Grid.EditorOptions;

interface

type
  TThemedGridEditorOptions = class
  private
    FMinimum: Extended;
    FMaximum: Extended;
    FIncrement: Extended;
    FValueScale: Extended;
    FDecimalPlaces: Integer;
    FHasMinimum: Boolean;
    FHasMaximum: Boolean;
    FHasIncrement: Boolean;
    FHasValueScale: Boolean;
    FHasDecimalPlaces: Boolean;
    FMinDate: TDateTime;
    FMaxDate: TDateTime;
    FHasMinDate: Boolean;
    FHasMaxDate: Boolean;
    FShowTime: Boolean;
    FHasShowTime: Boolean;
    FDataSource: TObject;
    FDisplayMember: string;
    FValueMember: string;
    FTag: TObject;
    procedure SetMinimum(const AValue: Extended);
    procedure SetMaximum(const AValue: Extended);
    procedure SetIncrement(const AValue: Extended);
    procedure SetValueScale(const AValue: Extended);
    procedure SetDecimalPlaces(const AValue: Integer);
    procedure SetMinDate(const AValue: TDateTime);
    procedure SetMaxDate(const AValue: TDateTime);
    procedure SetShowTime(const AValue: Boolean);
    function GetHasRange: Boolean;
    function GetHasDateRange: Boolean;
  public
    constructor Create;
    procedure ResetRange;
    procedure SetRange(const AMinimum, AMaximum: Extended);
    procedure ResetDateRange;
    procedure SetDateRange(const AMinimum, AMaximum: TDateTime);
    procedure ResetShowTime;
    property Minimum: Extended read FMinimum write SetMinimum;
    property Maximum: Extended read FMaximum write SetMaximum;
    property Increment: Extended read FIncrement write SetIncrement;
    property ValueScale: Extended read FValueScale write SetValueScale;
    property DecimalPlaces: Integer read FDecimalPlaces write SetDecimalPlaces;
    property HasMinimum: Boolean read FHasMinimum;
    property HasMaximum: Boolean read FHasMaximum;
    property HasIncrement: Boolean read FHasIncrement;
    property HasValueScale: Boolean read FHasValueScale;
    property HasDecimalPlaces: Boolean read FHasDecimalPlaces;
    property HasRange: Boolean read GetHasRange;
    property MinDate: TDateTime read FMinDate write SetMinDate;
    property MaxDate: TDateTime read FMaxDate write SetMaxDate;
    property HasMinDate: Boolean read FHasMinDate;
    property HasMaxDate: Boolean read FHasMaxDate;
    property HasDateRange: Boolean read GetHasDateRange;
    property ShowTime: Boolean read FShowTime write SetShowTime;
    property HasShowTime: Boolean read FHasShowTime;
    property DataSource: TObject read FDataSource write FDataSource;
    property DisplayMember: string read FDisplayMember write FDisplayMember;
    property ValueMember: string read FValueMember write FValueMember;
    property Tag: TObject read FTag write FTag;
  end;

implementation

const
  CMinDate: TDateTime = -657434.0;
  CMaxDate: TDateTime = 2958465.99999;

constructor TThemedGridEditorOptions.Create;
begin
  inherited Create;
  FMinimum := 0;
  FMaximum := 100;
  FIncrement := 1;
  FValueScale := 1;
  FDecimalPlaces := 0;
  FMinDate := CMinDate;
  FMaxDate := CMaxDate;
  FShowTime := False;
end;

procedure TThemedGridEditorOptions.SetMinimum(const AValue: Extended);
begin
  FMinimum := AValue;
  FHasMinimum := True;
end;

procedure TThemedGridEditorOptions.SetMaximum(const AValue: Extended);
begin
  FMaximum := AValue;
  FHasMaximum := True;
end;

procedure TThemedGridEditorOptions.SetIncrement(const AValue: Extended);
var
  LValue: Extended;
begin
  LValue := AValue;
  if LValue <= 0 then
    LValue := 1;
  FIncrement := LValue;
  FHasIncrement := True;
end;

procedure TThemedGridEditorOptions.SetValueScale(const AValue: Extended);
var
  LValue: Extended;
begin
  LValue := AValue;
  if LValue = 0 then
    LValue := 1;
  FValueScale := LValue;
  FHasValueScale := True;
end;

procedure TThemedGridEditorOptions.SetDecimalPlaces(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 0 then
    LValue := 0;
  if LValue > 6 then
    LValue := 6;
  FDecimalPlaces := LValue;
  FHasDecimalPlaces := True;
end;

procedure TThemedGridEditorOptions.SetMinDate(const AValue: TDateTime);
begin
  FMinDate := AValue;
  FHasMinDate := True;
end;

procedure TThemedGridEditorOptions.SetMaxDate(const AValue: TDateTime);
begin
  FMaxDate := AValue;
  FHasMaxDate := True;
end;

procedure TThemedGridEditorOptions.SetShowTime(const AValue: Boolean);
begin
  FShowTime := AValue;
  FHasShowTime := True;
end;

function TThemedGridEditorOptions.GetHasRange: Boolean;
begin
  Result := FHasMinimum or FHasMaximum;
end;

function TThemedGridEditorOptions.GetHasDateRange: Boolean;
begin
  Result := FHasMinDate or FHasMaxDate;
end;

procedure TThemedGridEditorOptions.ResetRange;
begin
  FMinimum := 0;
  FMaximum := 100;
  FHasMinimum := False;
  FHasMaximum := False;
end;

procedure TThemedGridEditorOptions.SetRange(const AMinimum, AMaximum: Extended);
var
  LMax: Extended;
begin
  LMax := AMaximum;
  if LMax < AMinimum then
    LMax := AMinimum;
  SetMinimum(AMinimum);
  SetMaximum(LMax);
end;

procedure TThemedGridEditorOptions.ResetDateRange;
begin
  FMinDate := CMinDate;
  FMaxDate := CMaxDate;
  FHasMinDate := False;
  FHasMaxDate := False;
end;

procedure TThemedGridEditorOptions.SetDateRange(const AMinimum, AMaximum: TDateTime);
var
  LMax: TDateTime;
begin
  LMax := AMaximum;
  if LMax < AMinimum then
    LMax := AMinimum;
  SetMinDate(AMinimum);
  SetMaxDate(LMax);
end;

procedure TThemedGridEditorOptions.ResetShowTime;
begin
  FShowTime := False;
  FHasShowTime := False;
end;

end.

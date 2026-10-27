unit NimbusForms.Grid.GroupDescriptor;

{$SCOPEDENUMS ON}

interface

uses
  System.Classes,
  NimbusForms.Grid.Types,
  NimbusForms.Grid.Column;

type
  TThemedGridGroupDescriptor = class
  private
    FColumnName: string;
    FColumn: TThemedGridColumn;
    FSortDirection: TThemedGridSortDirection;
    FExpanded: Boolean;
    FOnChanged: TNotifyEvent;
    procedure SetColumnName(const AValue: string);
    procedure SetColumn(const AValue: TThemedGridColumn);
    procedure SetSortDirection(const AValue: TThemedGridSortDirection);
    procedure SetExpanded(const AValue: Boolean);
    function GetIsValid: Boolean;
    procedure DoChanged;
  public
    constructor Create; overload;
    constructor Create(const AColumnName: string); overload;
    function Clone: TThemedGridGroupDescriptor;
    property ColumnName: string read FColumnName write SetColumnName;
    property Column: TThemedGridColumn read FColumn write SetColumn;
    property SortDirection: TThemedGridSortDirection read FSortDirection write SetSortDirection;
    property Expanded: Boolean read FExpanded write SetExpanded;
    property IsValid: Boolean read GetIsValid;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

implementation

constructor TThemedGridGroupDescriptor.Create;
begin
  inherited Create;
  FSortDirection := TThemedGridSortDirection.Ascending;
  FExpanded := True;
end;

constructor TThemedGridGroupDescriptor.Create(const AColumnName: string);
begin
  Create;
  FColumnName := AColumnName;
end;

procedure TThemedGridGroupDescriptor.DoChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TThemedGridGroupDescriptor.SetColumnName(const AValue: string);
begin
  if FColumnName = AValue then
    Exit;
  FColumnName := AValue;
  DoChanged;
end;

procedure TThemedGridGroupDescriptor.SetColumn(const AValue: TThemedGridColumn);
begin
  if FColumn = AValue then
    Exit;
  FColumn := AValue;
  DoChanged;
end;

procedure TThemedGridGroupDescriptor.SetSortDirection(const AValue: TThemedGridSortDirection);
begin
  if FSortDirection = AValue then
    Exit;
  FSortDirection := AValue;
  DoChanged;
end;

procedure TThemedGridGroupDescriptor.SetExpanded(const AValue: Boolean);
begin
  if FExpanded = AValue then
    Exit;
  FExpanded := AValue;
  DoChanged;
end;

function TThemedGridGroupDescriptor.GetIsValid: Boolean;
begin
  Result := (FColumn <> nil) or (FColumnName <> '');
end;

function TThemedGridGroupDescriptor.Clone: TThemedGridGroupDescriptor;
begin
  Result := TThemedGridGroupDescriptor.Create;
  Result.ColumnName := FColumnName;
  Result.Column := FColumn;
  Result.SortDirection := FSortDirection;
  Result.Expanded := FExpanded;
end;

end.

unit NimbusForms.Grid.SearchOptions;

{$SCOPEDENUMS ON}

interface

uses
  System.Classes,
  NimbusForms.Grid.Types;

type
  TThemedGridSearchOptions = class
  private
    FMode: TThemedGridSearchMode;
    FCaseSensitive: Boolean;
    FIncludeHiddenColumns: Boolean;
    FHighlightMatches: Boolean;
    FMaxResults: Integer;
    FMinimumSearchLength: Integer;
    FOnChanged: TNotifyEvent;
    procedure SetMode(const AValue: TThemedGridSearchMode);
    procedure SetCaseSensitive(const AValue: Boolean);
    procedure SetIncludeHiddenColumns(const AValue: Boolean);
    procedure SetHighlightMatches(const AValue: Boolean);
    procedure SetMaxResults(const AValue: Integer);
    procedure SetMinimumSearchLength(const AValue: Integer);
    procedure DoChanged;
  public
    constructor Create;
    property Mode: TThemedGridSearchMode read FMode write SetMode;
    property CaseSensitive: Boolean read FCaseSensitive write SetCaseSensitive;
    property IncludeHiddenColumns: Boolean read FIncludeHiddenColumns write SetIncludeHiddenColumns;
    property HighlightMatches: Boolean read FHighlightMatches write SetHighlightMatches;
    property MaxResults: Integer read FMaxResults write SetMaxResults;
    property MinimumSearchLength: Integer read FMinimumSearchLength write SetMinimumSearchLength;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

implementation

constructor TThemedGridSearchOptions.Create;
begin
  inherited Create;
  FMode := TThemedGridSearchMode.Contains;
  FHighlightMatches := True;
  FMaxResults := 5000;
  FMinimumSearchLength := 1;
end;

procedure TThemedGridSearchOptions.DoChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TThemedGridSearchOptions.SetMode(const AValue: TThemedGridSearchMode);
begin
  if FMode = AValue then Exit;
  FMode := AValue; DoChanged;
end;

procedure TThemedGridSearchOptions.SetCaseSensitive(const AValue: Boolean);
begin
  if FCaseSensitive = AValue then Exit;
  FCaseSensitive := AValue; DoChanged;
end;

procedure TThemedGridSearchOptions.SetIncludeHiddenColumns(const AValue: Boolean);
begin
  if FIncludeHiddenColumns = AValue then Exit;
  FIncludeHiddenColumns := AValue; DoChanged;
end;

procedure TThemedGridSearchOptions.SetHighlightMatches(const AValue: Boolean);
begin
  if FHighlightMatches = AValue then Exit;
  FHighlightMatches := AValue; DoChanged;
end;

procedure TThemedGridSearchOptions.SetMaxResults(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 100 then
    LValue := 100;
  if FMaxResults = LValue then Exit;
  FMaxResults := LValue; DoChanged;
end;

procedure TThemedGridSearchOptions.SetMinimumSearchLength(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 1 then
    LValue := 1;
  if FMinimumSearchLength = LValue then Exit;
  FMinimumSearchLength := LValue; DoChanged;
end;

end.

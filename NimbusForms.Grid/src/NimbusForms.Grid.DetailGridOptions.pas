unit NimbusForms.Grid.DetailGridOptions;

interface

type
  TThemedGridDetailGridOptions = class
  private
    FEnabled: Boolean;
    FHeaderVisible: Boolean;
    FAutoGenerateColumns: Boolean;
    FShowColumnLines: Boolean;
    FShowRowLines: Boolean;
    FShowBorder: Boolean;
    FMaxVisibleRows: Integer;
    FRowHeight: Integer;
    FHeaderHeight: Integer;
    FIndent: Integer;
    FSpacingBefore: Integer;
    FSpacingAfter: Integer;
    procedure SetMaxVisibleRows(const AValue: Integer);
    procedure SetRowHeight(const AValue: Integer);
    procedure SetHeaderHeight(const AValue: Integer);
    procedure SetIndent(const AValue: Integer);
    procedure SetSpacingBefore(const AValue: Integer);
    procedure SetSpacingAfter(const AValue: Integer);
  public
    constructor Create;
    procedure Reset;
    property Enabled: Boolean read FEnabled write FEnabled;
    property HeaderVisible: Boolean read FHeaderVisible write FHeaderVisible;
    property AutoGenerateColumns: Boolean read FAutoGenerateColumns write FAutoGenerateColumns;
    property ShowColumnLines: Boolean read FShowColumnLines write FShowColumnLines;
    property ShowRowLines: Boolean read FShowRowLines write FShowRowLines;
    property ShowBorder: Boolean read FShowBorder write FShowBorder;
    property MaxVisibleRows: Integer read FMaxVisibleRows write SetMaxVisibleRows;
    property RowHeight: Integer read FRowHeight write SetRowHeight;
    property HeaderHeight: Integer read FHeaderHeight write SetHeaderHeight;
    property Indent: Integer read FIndent write SetIndent;
    property SpacingBefore: Integer read FSpacingBefore write SetSpacingBefore;
    property SpacingAfter: Integer read FSpacingAfter write SetSpacingAfter;
  end;

const
  CThemedGridDetailGridMinimumMaxVisibleRows = 1;
  CThemedGridDetailGridMaximumMaxVisibleRows = 100;
  CThemedGridDetailGridDefaultMaxVisibleRows = 6;
  CThemedGridDetailGridMinimumRowHeight = 16;
  CThemedGridDetailGridMaximumRowHeight = 120;
  CThemedGridDetailGridDefaultRowHeight = 24;
  CThemedGridDetailGridDefaultHeaderHeight = 25;
  CThemedGridDetailGridMaximumIndent = 400;
  CThemedGridDetailGridDefaultIndent = 24;
  CThemedGridDetailGridMaximumSpacing = 80;
  CThemedGridDetailGridDefaultSpacingBefore = 6;
  CThemedGridDetailGridDefaultSpacingAfter = 8;

implementation

function Clamp(const AValue, AMinimum, AMaximum: Integer): Integer;
begin
  if AValue < AMinimum then
    Result := AMinimum
  else if AValue > AMaximum then
    Result := AMaximum
  else
    Result := AValue;
end;

constructor TThemedGridDetailGridOptions.Create;
begin
  inherited Create;
  Reset;
end;

procedure TThemedGridDetailGridOptions.Reset;
begin
  FEnabled := True;
  FHeaderVisible := True;
  FAutoGenerateColumns := True;
  FShowColumnLines := True;
  FShowRowLines := True;
  FShowBorder := True;
  FMaxVisibleRows := CThemedGridDetailGridDefaultMaxVisibleRows;
  FRowHeight := CThemedGridDetailGridDefaultRowHeight;
  FHeaderHeight := CThemedGridDetailGridDefaultHeaderHeight;
  FIndent := CThemedGridDetailGridDefaultIndent;
  FSpacingBefore := CThemedGridDetailGridDefaultSpacingBefore;
  FSpacingAfter := CThemedGridDetailGridDefaultSpacingAfter;
end;

procedure TThemedGridDetailGridOptions.SetMaxVisibleRows(const AValue: Integer);
begin
  FMaxVisibleRows := Clamp(AValue, CThemedGridDetailGridMinimumMaxVisibleRows,
    CThemedGridDetailGridMaximumMaxVisibleRows);
end;

procedure TThemedGridDetailGridOptions.SetRowHeight(const AValue: Integer);
begin
  FRowHeight := Clamp(AValue, CThemedGridDetailGridMinimumRowHeight, CThemedGridDetailGridMaximumRowHeight);
end;

procedure TThemedGridDetailGridOptions.SetHeaderHeight(const AValue: Integer);
begin
  FHeaderHeight := Clamp(AValue, CThemedGridDetailGridMinimumRowHeight, CThemedGridDetailGridMaximumRowHeight);
end;

procedure TThemedGridDetailGridOptions.SetIndent(const AValue: Integer);
begin
  FIndent := Clamp(AValue, 0, CThemedGridDetailGridMaximumIndent);
end;

procedure TThemedGridDetailGridOptions.SetSpacingBefore(const AValue: Integer);
begin
  FSpacingBefore := Clamp(AValue, 0, CThemedGridDetailGridMaximumSpacing);
end;

procedure TThemedGridDetailGridOptions.SetSpacingAfter(const AValue: Integer);
begin
  FSpacingAfter := Clamp(AValue, 0, CThemedGridDetailGridMaximumSpacing);
end;

end.

unit NimbusForms.Grid.SelectionOptions;

{$SCOPEDENUMS ON}

interface

uses
  System.Classes,
  NimbusForms.Grid.Types;

type
  TThemedGridSelectionOptions = class
  private
    FMode: TThemedGridSelectionMode;
    FMultiSelect: Boolean;
    FAllowRangeSelection: Boolean;
    FAllowRowSelection: Boolean;
    FAllowColumnSelection: Boolean;
    FOnChanged: TNotifyEvent;
    procedure SetMode(const AValue: TThemedGridSelectionMode);
    procedure SetMultiSelect(const AValue: Boolean);
    procedure SetAllowRangeSelection(const AValue: Boolean);
    procedure SetAllowRowSelection(const AValue: Boolean);
    procedure SetAllowColumnSelection(const AValue: Boolean);
    procedure DoChanged;
  public
    constructor Create;
    property Mode: TThemedGridSelectionMode read FMode write SetMode;
    property MultiSelect: Boolean read FMultiSelect write SetMultiSelect;
    property AllowRangeSelection: Boolean read FAllowRangeSelection write SetAllowRangeSelection;
    property AllowRowSelection: Boolean read FAllowRowSelection write SetAllowRowSelection;
    property AllowColumnSelection: Boolean read FAllowColumnSelection write SetAllowColumnSelection;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

implementation

constructor TThemedGridSelectionOptions.Create;
begin
  inherited Create;
  FMode := TThemedGridSelectionMode.Cell;
  FMultiSelect := True;
  FAllowRangeSelection := True;
  FAllowRowSelection := True;
  FAllowColumnSelection := True;
end;

procedure TThemedGridSelectionOptions.DoChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TThemedGridSelectionOptions.SetMode(const AValue: TThemedGridSelectionMode);
begin
  if FMode = AValue then
    Exit;
  FMode := AValue;
  DoChanged;
end;

procedure TThemedGridSelectionOptions.SetMultiSelect(const AValue: Boolean);
begin
  if FMultiSelect = AValue then
    Exit;
  FMultiSelect := AValue;
  DoChanged;
end;

procedure TThemedGridSelectionOptions.SetAllowRangeSelection(const AValue: Boolean);
begin
  if FAllowRangeSelection = AValue then
    Exit;
  FAllowRangeSelection := AValue;
  DoChanged;
end;

procedure TThemedGridSelectionOptions.SetAllowRowSelection(const AValue: Boolean);
begin
  if FAllowRowSelection = AValue then
    Exit;
  FAllowRowSelection := AValue;
  DoChanged;
end;

procedure TThemedGridSelectionOptions.SetAllowColumnSelection(const AValue: Boolean);
begin
  if FAllowColumnSelection = AValue then
    Exit;
  FAllowColumnSelection := AValue;
  DoChanged;
end;

end.

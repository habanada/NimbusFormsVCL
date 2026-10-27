unit NimbusForms.Grid.GroupingOptions;

interface

uses
  System.Classes;

type
  TThemedGridGroupingOptions = class
  private
    FEnabled: Boolean;
    FShowGroupCount: Boolean;
    FAllowCollapse: Boolean;
    FIndentWidth: Integer;
    FGlyphSize: Integer;
    FNullText: string;
    FEmptyText: string;
    FOnChanged: TNotifyEvent;
    procedure SetEnabled(const AValue: Boolean);
    procedure SetShowGroupCount(const AValue: Boolean);
    procedure SetAllowCollapse(const AValue: Boolean);
    procedure SetIndentWidth(const AValue: Integer);
    procedure SetGlyphSize(const AValue: Integer);
    procedure SetNullText(const AValue: string);
    procedure SetEmptyText(const AValue: string);
    procedure DoChanged;
  public
    constructor Create;
    property Enabled: Boolean read FEnabled write SetEnabled;
    property ShowGroupCount: Boolean read FShowGroupCount write SetShowGroupCount;
    property AllowCollapse: Boolean read FAllowCollapse write SetAllowCollapse;
    property IndentWidth: Integer read FIndentWidth write SetIndentWidth;
    property GlyphSize: Integer read FGlyphSize write SetGlyphSize;
    property NullText: string read FNullText write SetNullText;
    property EmptyText: string read FEmptyText write SetEmptyText;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

implementation

constructor TThemedGridGroupingOptions.Create;
begin
  inherited Create;
  FEnabled := True;
  FShowGroupCount := True;
  FAllowCollapse := True;
  FIndentWidth := 18;
  FGlyphSize := 11;
  FNullText := '(Null)';
  FEmptyText := '(Empty)';
end;

procedure TThemedGridGroupingOptions.DoChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TThemedGridGroupingOptions.SetEnabled(const AValue: Boolean);
begin
  if FEnabled = AValue then
    Exit;
  FEnabled := AValue;
  DoChanged;
end;

procedure TThemedGridGroupingOptions.SetShowGroupCount(const AValue: Boolean);
begin
  if FShowGroupCount = AValue then
    Exit;
  FShowGroupCount := AValue;
  DoChanged;
end;

procedure TThemedGridGroupingOptions.SetAllowCollapse(const AValue: Boolean);
begin
  if FAllowCollapse = AValue then
    Exit;
  FAllowCollapse := AValue;
  DoChanged;
end;

procedure TThemedGridGroupingOptions.SetIndentWidth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 0 then
    LValue := 0;
  if LValue > 80 then
    LValue := 80;
  if FIndentWidth = LValue then
    Exit;
  FIndentWidth := LValue;
  DoChanged;
end;

procedure TThemedGridGroupingOptions.SetGlyphSize(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := AValue;
  if LValue < 7 then
    LValue := 7;
  if LValue > 24 then
    LValue := 24;
  if FGlyphSize = LValue then
    Exit;
  FGlyphSize := LValue;
  DoChanged;
end;

procedure TThemedGridGroupingOptions.SetNullText(const AValue: string);
begin
  if FNullText = AValue then
    Exit;
  FNullText := AValue;
  DoChanged;
end;

procedure TThemedGridGroupingOptions.SetEmptyText(const AValue: string);
begin
  if FEmptyText = AValue then
    Exit;
  FEmptyText := AValue;
  DoChanged;
end;

end.

unit NimbusForms.Grid.ColumnBand;

interface

uses
  System.Classes,
  System.Rtti,
  NimbusForms.Theming.Types;

type
  TThemedGridColumnBand = class
  private
    FName: string;
    FText: string;
    FVisible: Boolean;
    FDisplayIndex: Integer;
    FBackColor: TThemeColor;
    FForeColor: TThemeColor;
    FBorderColor: TThemeColor;
    FTag: TValue;
    FOnChanged: TNotifyEvent;
    procedure SetName(const AValue: string);
    procedure SetText(const AValue: string);
    procedure SetVisible(const AValue: Boolean);
    procedure SetDisplayIndex(const AValue: Integer);
    procedure SetBackColor(const AValue: TThemeColor);
    procedure SetForeColor(const AValue: TThemeColor);
    procedure SetBorderColor(const AValue: TThemeColor);
    procedure SetTag(const AValue: TValue);
    procedure DoChanged;
  public
    constructor Create;
    function GetBestText: string;
    property Name: string read FName write SetName;
    property Text: string read FText write SetText;
    property Visible: Boolean read FVisible write SetVisible;
    property DisplayIndex: Integer read FDisplayIndex write SetDisplayIndex;
    property BackColor: TThemeColor read FBackColor write SetBackColor;
    property ForeColor: TThemeColor read FForeColor write SetForeColor;
    property BorderColor: TThemeColor read FBorderColor write SetBorderColor;
    property Tag: TValue read FTag write SetTag;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

implementation

constructor TThemedGridColumnBand.Create;
begin
  inherited Create;
  FVisible := True;
  FDisplayIndex := -1;
  FBackColor := TThemeColor(0);
  FForeColor := TThemeColor(0);
  FBorderColor := TThemeColor(0);
end;

procedure TThemedGridColumnBand.DoChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TThemedGridColumnBand.SetName(const AValue: string);
begin
  if FName = AValue then
    Exit;
  FName := AValue;
  DoChanged;
end;

procedure TThemedGridColumnBand.SetText(const AValue: string);
begin
  if FText = AValue then
    Exit;
  FText := AValue;
  DoChanged;
end;

procedure TThemedGridColumnBand.SetVisible(const AValue: Boolean);
begin
  if FVisible = AValue then
    Exit;
  FVisible := AValue;
  DoChanged;
end;

procedure TThemedGridColumnBand.SetDisplayIndex(const AValue: Integer);
begin
  if FDisplayIndex = AValue then
    Exit;
  FDisplayIndex := AValue;
  DoChanged;
end;

procedure TThemedGridColumnBand.SetBackColor(const AValue: TThemeColor);
begin
  if Cardinal(FBackColor) = Cardinal(AValue) then
    Exit;
  FBackColor := AValue;
  DoChanged;
end;

procedure TThemedGridColumnBand.SetForeColor(const AValue: TThemeColor);
begin
  if Cardinal(FForeColor) = Cardinal(AValue) then
    Exit;
  FForeColor := AValue;
  DoChanged;
end;

procedure TThemedGridColumnBand.SetBorderColor(const AValue: TThemeColor);
begin
  if Cardinal(FBorderColor) = Cardinal(AValue) then
    Exit;
  FBorderColor := AValue;
  DoChanged;
end;

procedure TThemedGridColumnBand.SetTag(const AValue: TValue);
begin
  FTag := AValue;
  DoChanged;
end;

function TThemedGridColumnBand.GetBestText: string;
begin
  if FText <> '' then
    Exit(FText);
  Result := FName;
end;

end.

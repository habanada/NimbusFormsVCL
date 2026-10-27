unit NimbusForms.Grid.DetailGridRowVisual;

{$SCOPEDENUMS ON}

interface

uses
  System.Rtti,
  NimbusForms.Theming.Types;

type
  TThemedGridDetailGridRowVisual = class
  private
    FBackColor: TThemeColor;
    FForeColor: TThemeColor;
    FBorderColor: TThemeColor;
    FHasBackColor: Boolean;
    FHasForeColor: Boolean;
    FHasBorderColor: Boolean;
    FBold: Boolean;
    FItalic: Boolean;
    FEnabled: Boolean;
    FTag: TValue;
    procedure SetBackColor(const AValue: TThemeColor);
    procedure SetForeColor(const AValue: TThemeColor);
    procedure SetBorderColor(const AValue: TThemeColor);
  public
    constructor Create;
    procedure Clear;
    property BackColor: TThemeColor read FBackColor write SetBackColor;
    property ForeColor: TThemeColor read FForeColor write SetForeColor;
    property BorderColor: TThemeColor read FBorderColor write SetBorderColor;
    property HasBackColor: Boolean read FHasBackColor;
    property HasForeColor: Boolean read FHasForeColor;
    property HasBorderColor: Boolean read FHasBorderColor;
    property Bold: Boolean read FBold write FBold;
    property Italic: Boolean read FItalic write FItalic;
    property Enabled: Boolean read FEnabled write FEnabled;
    property Tag: TValue read FTag write FTag;
  end;

implementation

constructor TThemedGridDetailGridRowVisual.Create;
begin
  inherited Create;
  Clear;
end;

procedure TThemedGridDetailGridRowVisual.Clear;
begin
  FBackColor := 0;
  FForeColor := 0;
  FBorderColor := 0;
  FHasBackColor := False;
  FHasForeColor := False;
  FHasBorderColor := False;
  FBold := False;
  FItalic := False;
  FEnabled := True;
  FTag := TValue.Empty;
end;

procedure TThemedGridDetailGridRowVisual.SetBackColor(const AValue: TThemeColor);
begin
  FBackColor := AValue;
  FHasBackColor := True;
end;

procedure TThemedGridDetailGridRowVisual.SetForeColor(const AValue: TThemeColor);
begin
  FForeColor := AValue;
  FHasForeColor := True;
end;

procedure TThemedGridDetailGridRowVisual.SetBorderColor(const AValue: TThemeColor);
begin
  FBorderColor := AValue;
  FHasBorderColor := True;
end;

end.

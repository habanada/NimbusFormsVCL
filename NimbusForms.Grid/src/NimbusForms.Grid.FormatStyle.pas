unit NimbusForms.Grid.FormatStyle;

interface

uses
  System.Rtti,
  NimbusForms.Theming.Types;

type
  TThemedGridFormatStyle = class
  private
    FBackColor: TThemeColor;
    FForeColor: TThemeColor;
    FBorderColor: TThemeColor;
    FSelectionBackColor: TThemeColor;
    FSelectionForeColor: TThemeColor;
    FHoverBackColor: TThemeColor;
    FHoverForeColor: TThemeColor;
    FCurrentBorderColor: TThemeColor;
    FHasBackColor: Boolean;
    FHasForeColor: Boolean;
    FHasBorderColor: Boolean;
    FHasSelectionBackColor: Boolean;
    FHasSelectionForeColor: Boolean;
    FHasHoverBackColor: Boolean;
    FHasHoverForeColor: Boolean;
    FHasCurrentBorderColor: Boolean;
    FBold: Boolean;
    FItalic: Boolean;
    FTag: TValue;
    procedure SetBackColor(const AValue: TThemeColor);
    procedure SetForeColor(const AValue: TThemeColor);
    procedure SetBorderColor(const AValue: TThemeColor);
    procedure SetSelectionBackColor(const AValue: TThemeColor);
    procedure SetSelectionForeColor(const AValue: TThemeColor);
    procedure SetHoverBackColor(const AValue: TThemeColor);
    procedure SetHoverForeColor(const AValue: TThemeColor);
    procedure SetCurrentBorderColor(const AValue: TThemeColor);
  public
    function Clone: TThemedGridFormatStyle;
    procedure MergeFrom(const AStyle: TThemedGridFormatStyle);
    class function Back(const AColor: TThemeColor): TThemedGridFormatStyle; static;
    class function Fore(const AColor: TThemeColor): TThemedGridFormatStyle; static;
    class function BackFore(const ABackColor, AForeColor: TThemeColor): TThemedGridFormatStyle; static;
    class function Selection(const ABackColor, AForeColor: TThemeColor): TThemedGridFormatStyle; static;
    class function Hover(const ABackColor, AForeColor: TThemeColor): TThemedGridFormatStyle; static;
    class function Border(const AColor: TThemeColor): TThemedGridFormatStyle; static;
    class function Font(const ABold, AItalic: Boolean): TThemedGridFormatStyle; static;
    property BackColor: TThemeColor read FBackColor write SetBackColor;
    property ForeColor: TThemeColor read FForeColor write SetForeColor;
    property BorderColor: TThemeColor read FBorderColor write SetBorderColor;
    property SelectionBackColor: TThemeColor read FSelectionBackColor write SetSelectionBackColor;
    property SelectionForeColor: TThemeColor read FSelectionForeColor write SetSelectionForeColor;
    property HoverBackColor: TThemeColor read FHoverBackColor write SetHoverBackColor;
    property HoverForeColor: TThemeColor read FHoverForeColor write SetHoverForeColor;
    property CurrentBorderColor: TThemeColor read FCurrentBorderColor write SetCurrentBorderColor;
    property HasBackColor: Boolean read FHasBackColor;
    property HasForeColor: Boolean read FHasForeColor;
    property HasBorderColor: Boolean read FHasBorderColor;
    property HasSelectionBackColor: Boolean read FHasSelectionBackColor;
    property HasSelectionForeColor: Boolean read FHasSelectionForeColor;
    property HasHoverBackColor: Boolean read FHasHoverBackColor;
    property HasHoverForeColor: Boolean read FHasHoverForeColor;
    property HasCurrentBorderColor: Boolean read FHasCurrentBorderColor;
    property Bold: Boolean read FBold write FBold;
    property Italic: Boolean read FItalic write FItalic;
    property Tag: TValue read FTag write FTag;
  end;

implementation

procedure TThemedGridFormatStyle.SetBackColor(const AValue: TThemeColor);
begin
  FBackColor := AValue;
  FHasBackColor := True;
end;

procedure TThemedGridFormatStyle.SetForeColor(const AValue: TThemeColor);
begin
  FForeColor := AValue;
  FHasForeColor := True;
end;

procedure TThemedGridFormatStyle.SetBorderColor(const AValue: TThemeColor);
begin
  FBorderColor := AValue;
  FHasBorderColor := True;
end;

procedure TThemedGridFormatStyle.SetSelectionBackColor(const AValue: TThemeColor);
begin
  FSelectionBackColor := AValue;
  FHasSelectionBackColor := True;
end;

procedure TThemedGridFormatStyle.SetSelectionForeColor(const AValue: TThemeColor);
begin
  FSelectionForeColor := AValue;
  FHasSelectionForeColor := True;
end;

procedure TThemedGridFormatStyle.SetHoverBackColor(const AValue: TThemeColor);
begin
  FHoverBackColor := AValue;
  FHasHoverBackColor := True;
end;

procedure TThemedGridFormatStyle.SetHoverForeColor(const AValue: TThemeColor);
begin
  FHoverForeColor := AValue;
  FHasHoverForeColor := True;
end;

procedure TThemedGridFormatStyle.SetCurrentBorderColor(const AValue: TThemeColor);
begin
  FCurrentBorderColor := AValue;
  FHasCurrentBorderColor := True;
end;

function TThemedGridFormatStyle.Clone: TThemedGridFormatStyle;
begin
  Result := TThemedGridFormatStyle.Create;
  Result.FBackColor := FBackColor;
  Result.FForeColor := FForeColor;
  Result.FBorderColor := FBorderColor;
  Result.FSelectionBackColor := FSelectionBackColor;
  Result.FSelectionForeColor := FSelectionForeColor;
  Result.FHoverBackColor := FHoverBackColor;
  Result.FHoverForeColor := FHoverForeColor;
  Result.FCurrentBorderColor := FCurrentBorderColor;
  Result.FHasBackColor := FHasBackColor;
  Result.FHasForeColor := FHasForeColor;
  Result.FHasBorderColor := FHasBorderColor;
  Result.FHasSelectionBackColor := FHasSelectionBackColor;
  Result.FHasSelectionForeColor := FHasSelectionForeColor;
  Result.FHasHoverBackColor := FHasHoverBackColor;
  Result.FHasHoverForeColor := FHasHoverForeColor;
  Result.FHasCurrentBorderColor := FHasCurrentBorderColor;
  Result.FBold := FBold;
  Result.FItalic := FItalic;
  Result.FTag := FTag;
end;

procedure TThemedGridFormatStyle.MergeFrom(const AStyle: TThemedGridFormatStyle);
begin
  if AStyle = nil then
    Exit;
  if AStyle.FHasBackColor then
    SetBackColor(AStyle.FBackColor);
  if AStyle.FHasForeColor then
    SetForeColor(AStyle.FForeColor);
  if AStyle.FHasBorderColor then
    SetBorderColor(AStyle.FBorderColor);
  if AStyle.FHasSelectionBackColor then
    SetSelectionBackColor(AStyle.FSelectionBackColor);
  if AStyle.FHasSelectionForeColor then
    SetSelectionForeColor(AStyle.FSelectionForeColor);
  if AStyle.FHasHoverBackColor then
    SetHoverBackColor(AStyle.FHoverBackColor);
  if AStyle.FHasHoverForeColor then
    SetHoverForeColor(AStyle.FHoverForeColor);
  if AStyle.FHasCurrentBorderColor then
    SetCurrentBorderColor(AStyle.FCurrentBorderColor);
  if AStyle.FBold then
    FBold := True;
  if AStyle.FItalic then
    FItalic := True;
  if not AStyle.FTag.IsEmpty then
    FTag := AStyle.FTag;
end;

class function TThemedGridFormatStyle.Back(const AColor: TThemeColor): TThemedGridFormatStyle;
begin
  Result := TThemedGridFormatStyle.Create;
  Result.SetBackColor(AColor);
end;

class function TThemedGridFormatStyle.Fore(const AColor: TThemeColor): TThemedGridFormatStyle;
begin
  Result := TThemedGridFormatStyle.Create;
  Result.SetForeColor(AColor);
end;

class function TThemedGridFormatStyle.BackFore(const ABackColor, AForeColor: TThemeColor): TThemedGridFormatStyle;
begin
  Result := TThemedGridFormatStyle.Create;
  Result.SetBackColor(ABackColor);
  Result.SetForeColor(AForeColor);
end;

class function TThemedGridFormatStyle.Selection(const ABackColor, AForeColor: TThemeColor): TThemedGridFormatStyle;
begin
  Result := TThemedGridFormatStyle.Create;
  Result.SetSelectionBackColor(ABackColor);
  Result.SetSelectionForeColor(AForeColor);
end;

class function TThemedGridFormatStyle.Hover(const ABackColor, AForeColor: TThemeColor): TThemedGridFormatStyle;
begin
  Result := TThemedGridFormatStyle.Create;
  Result.SetHoverBackColor(ABackColor);
  Result.SetHoverForeColor(AForeColor);
end;

class function TThemedGridFormatStyle.Border(const AColor: TThemeColor): TThemedGridFormatStyle;
begin
  Result := TThemedGridFormatStyle.Create;
  Result.SetBorderColor(AColor);
end;

class function TThemedGridFormatStyle.Font(const ABold, AItalic: Boolean): TThemedGridFormatStyle;
begin
  Result := TThemedGridFormatStyle.Create;
  Result.FBold := ABold;
  Result.FItalic := AItalic;
end;

end.

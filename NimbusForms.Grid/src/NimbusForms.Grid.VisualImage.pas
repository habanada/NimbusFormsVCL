unit NimbusForms.Grid.VisualImage;

{$SCOPEDENUMS ON}

interface

uses
  System.SysUtils,
  System.Rtti,
  Vcl.Graphics,
  NimbusForms.Theming.Types;

type
  TThemedVisualImageKind = (None, SvgFile, SvgText, ImageFile, Graphic, ImageListKey);

  TThemedVisualImage = class
  private
    FKey: string;
    FKind: TThemedVisualImageKind;
    FSource: string;
    FGraphic: TGraphic;
    FClickable: Boolean;
    FToolTip: string;
    FTag: TValue;
    FCurrentColor: TThemeColor;
    FHasCurrentColor: Boolean;
    FActionIndex: Integer;
    procedure SetCurrentColor(const AValue: TThemeColor);
  public
    constructor Create(const AKey: string);
    class function FromSvgFile(const AKey, AFileName: string): TThemedVisualImage; static;
    class function FromSvgText(const AKey, ASvgText: string): TThemedVisualImage; static;
    class function FromImageFile(const AKey, AFileName: string): TThemedVisualImage; static;
    class function FromImage(const AKey: string; const AGraphic: TGraphic): TThemedVisualImage; static;
    class function FromImageListKey(const AKey, AImageListKey: string): TThemedVisualImage; static;
    function HasImage: Boolean;
    function Clone: TThemedVisualImage;
    procedure ClearCurrentColor;
    property Key: string read FKey write FKey;
    property Kind: TThemedVisualImageKind read FKind;
    property Source: string read FSource;
    property Graphic: TGraphic read FGraphic;
    property Clickable: Boolean read FClickable write FClickable;
    property ToolTip: string read FToolTip write FToolTip;
    property Tag: TValue read FTag write FTag;
    property CurrentColor: TThemeColor read FCurrentColor write SetCurrentColor;
    property HasCurrentColor: Boolean read FHasCurrentColor;
    property ActionIndex: Integer read FActionIndex write FActionIndex;
  end;

implementation

constructor TThemedVisualImage.Create(const AKey: string);
begin
  inherited Create;
  FKey := AKey;
  FKind := TThemedVisualImageKind.None;
  FActionIndex := -1;
end;

class function TThemedVisualImage.FromSvgFile(const AKey, AFileName: string): TThemedVisualImage;
begin
  Result := TThemedVisualImage.Create(AKey);
  if AFileName <> '' then
  begin
    Result.FKind := TThemedVisualImageKind.SvgFile;
    Result.FSource := AFileName;
  end;
end;

class function TThemedVisualImage.FromSvgText(const AKey, ASvgText: string): TThemedVisualImage;
begin
  Result := TThemedVisualImage.Create(AKey);
  if ASvgText <> '' then
  begin
    Result.FKind := TThemedVisualImageKind.SvgText;
    Result.FSource := ASvgText;
  end;
end;

class function TThemedVisualImage.FromImageFile(const AKey, AFileName: string): TThemedVisualImage;
begin
  Result := TThemedVisualImage.Create(AKey);
  if AFileName <> '' then
  begin
    Result.FKind := TThemedVisualImageKind.ImageFile;
    Result.FSource := AFileName;
  end;
end;

class function TThemedVisualImage.FromImage(const AKey: string; const AGraphic: TGraphic): TThemedVisualImage;
begin
  Result := TThemedVisualImage.Create(AKey);
  if AGraphic <> nil then
  begin
    Result.FKind := TThemedVisualImageKind.Graphic;
    Result.FGraphic := AGraphic;
  end;
end;

class function TThemedVisualImage.FromImageListKey(const AKey, AImageListKey: string): TThemedVisualImage;
begin
  Result := TThemedVisualImage.Create(AKey);
  if AImageListKey <> '' then
  begin
    Result.FKind := TThemedVisualImageKind.ImageListKey;
    Result.FSource := AImageListKey;
  end;
end;

function TThemedVisualImage.HasImage: Boolean;
begin
  Result := FKind <> TThemedVisualImageKind.None;
end;

procedure TThemedVisualImage.SetCurrentColor(const AValue: TThemeColor);
begin
  FCurrentColor := AValue;
  FHasCurrentColor := True;
end;

procedure TThemedVisualImage.ClearCurrentColor;
begin
  FCurrentColor := 0;
  FHasCurrentColor := False;
end;

function TThemedVisualImage.Clone: TThemedVisualImage;
begin
  Result := TThemedVisualImage.Create(FKey);
  Result.FKind := FKind;
  Result.FSource := FSource;
  Result.FGraphic := FGraphic;
  Result.FClickable := FClickable;
  Result.FToolTip := FToolTip;
  Result.FTag := FTag;
  Result.FCurrentColor := FCurrentColor;
  Result.FHasCurrentColor := FHasCurrentColor;
  Result.FActionIndex := FActionIndex;
end;

end.

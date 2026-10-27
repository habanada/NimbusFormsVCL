unit NimbusForms.Grid.VisualAction;

{$SCOPEDENUMS ON}

interface

uses
  System.SysUtils,
  System.Rtti,
  System.Generics.Collections,
  Vcl.Graphics,
  NimbusForms.Theming.Types;

type
  TThemedGridVisualAction = class
  private
    FKey: string;
    FText: string;
    FToolTip: string;
    FSvgFile: string;
    FImageFile: string;
    FImageListKey: string;
    FImage: TGraphic;
    FImageSize: Integer;
    FVisible: Boolean;
    FEnabled: Boolean;
    FClickable: Boolean;
    FForeColor: TThemeColor;
    FHasForeColor: Boolean;
    FTag: TValue;
    function GetHasImage: Boolean;
    procedure SetForeColor(const AValue: TThemeColor);
  public
    constructor Create;
    function Clone: TThemedGridVisualAction;
    procedure ClearForeColor;
    property Key: string read FKey write FKey;
    property Text: string read FText write FText;
    property ToolTip: string read FToolTip write FToolTip;
    property SvgFile: string read FSvgFile write FSvgFile;
    property ImageFile: string read FImageFile write FImageFile;
    property ImageListKey: string read FImageListKey write FImageListKey;
    property Image: TGraphic read FImage write FImage;
    property ImageSize: Integer read FImageSize write FImageSize;
    property Visible: Boolean read FVisible write FVisible;
    property Enabled: Boolean read FEnabled write FEnabled;
    property Clickable: Boolean read FClickable write FClickable;
    property ForeColor: TThemeColor read FForeColor write SetForeColor;
    property HasForeColor: Boolean read FHasForeColor;
    property Tag: TValue read FTag write FTag;
    property HasImage: Boolean read GetHasImage;
  end;

  TThemedGridVisualActionCollection = class(TObjectList<TThemedGridVisualAction>)
  private
    function NewAction(const AKey, AText, AToolTip: string; const AImageSize: Integer;
      const ATag: TValue): TThemedGridVisualAction;
  public
    constructor Create; reintroduce;
    function AddSvgFile(const AKey, AText, AToolTip, ASvgFile: string; const AImageSize: Integer;
      const ATag: TValue): TThemedGridVisualAction;
    function AddImageFile(const AKey, AText, AToolTip, AImageFile: string; const AImageSize: Integer;
      const ATag: TValue): TThemedGridVisualAction;
    function AddImage(const AKey, AText, AToolTip: string; const AImage: TGraphic; const AImageSize: Integer;
      const ATag: TValue): TThemedGridVisualAction;
    function AddImageListKey(const AKey, AText, AToolTip, AImageListKey: string; const AImageSize: Integer;
      const ATag: TValue): TThemedGridVisualAction;
    function Clone: TThemedGridVisualActionCollection;
  end;

implementation

constructor TThemedGridVisualAction.Create;
begin
  inherited Create;
  FVisible := True;
  FEnabled := True;
  FClickable := True;
end;

function TThemedGridVisualAction.GetHasImage: Boolean;
begin
  Result := (FImage <> nil) or (FSvgFile <> '') or (FImageFile <> '') or (FImageListKey <> '');
end;

procedure TThemedGridVisualAction.SetForeColor(const AValue: TThemeColor);
begin
  FForeColor := AValue;
  FHasForeColor := True;
end;

procedure TThemedGridVisualAction.ClearForeColor;
begin
  FForeColor := 0;
  FHasForeColor := False;
end;

function TThemedGridVisualAction.Clone: TThemedGridVisualAction;
begin
  Result := TThemedGridVisualAction.Create;
  Result.FKey := FKey;
  Result.FText := FText;
  Result.FToolTip := FToolTip;
  Result.FSvgFile := FSvgFile;
  Result.FImageFile := FImageFile;
  Result.FImageListKey := FImageListKey;
  Result.FImage := FImage;
  Result.FImageSize := FImageSize;
  Result.FVisible := FVisible;
  Result.FEnabled := FEnabled;
  Result.FClickable := FClickable;
  Result.FForeColor := FForeColor;
  Result.FHasForeColor := FHasForeColor;
  Result.FTag := FTag;
end;

constructor TThemedGridVisualActionCollection.Create;
begin
  inherited Create(True);
end;

function TThemedGridVisualActionCollection.NewAction(const AKey, AText, AToolTip: string; const AImageSize: Integer;
  const ATag: TValue): TThemedGridVisualAction;
begin
  Result := TThemedGridVisualAction.Create;
  Result.Key := AKey;
  Result.Text := AText;
  Result.ToolTip := AToolTip;
  Result.ImageSize := AImageSize;
  Result.Tag := ATag;
end;

function TThemedGridVisualActionCollection.AddSvgFile(const AKey, AText, AToolTip, ASvgFile: string;
  const AImageSize: Integer; const ATag: TValue): TThemedGridVisualAction;
begin
  Result := NewAction(AKey, AText, AToolTip, AImageSize, ATag);
  Result.SvgFile := ASvgFile;
  Add(Result);
end;

function TThemedGridVisualActionCollection.AddImageFile(const AKey, AText, AToolTip, AImageFile: string;
  const AImageSize: Integer; const ATag: TValue): TThemedGridVisualAction;
begin
  Result := NewAction(AKey, AText, AToolTip, AImageSize, ATag);
  Result.ImageFile := AImageFile;
  Add(Result);
end;

function TThemedGridVisualActionCollection.AddImage(const AKey, AText, AToolTip: string; const AImage: TGraphic;
  const AImageSize: Integer; const ATag: TValue): TThemedGridVisualAction;
begin
  Result := NewAction(AKey, AText, AToolTip, AImageSize, ATag);
  Result.Image := AImage;
  Add(Result);
end;

function TThemedGridVisualActionCollection.AddImageListKey(const AKey, AText, AToolTip, AImageListKey: string;
  const AImageSize: Integer; const ATag: TValue): TThemedGridVisualAction;
begin
  Result := NewAction(AKey, AText, AToolTip, AImageSize, ATag);
  Result.ImageListKey := AImageListKey;
  Add(Result);
end;

function TThemedGridVisualActionCollection.Clone: TThemedGridVisualActionCollection;
var
  LAction: TThemedGridVisualAction;
begin
  Result := TThemedGridVisualActionCollection.Create;
  for LAction in Self do
    Result.Add(LAction.Clone);
end;

end.
